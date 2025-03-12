from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from typing import List, Dict, Set
import asyncio
import baostock as bs
import pandas as pd
from datetime import datetime, timedelta
import json

app = FastAPI()

# 存储活跃的WebSocket连接
active_connections: List[WebSocket] = []
# 存储用户监控的股票
monitored_stocks: Set[str] = set()
# 存储股票的历史数据
stock_history: Dict[str, dict] = {}

async def get_stock_data(stock_code: str) -> dict:
    """获取股票数据"""
    lg = bs.login()
    if lg.error_code != '0':
        return None
    
    # 获取实时数据
    rs = bs.query_rt_data(code=stock_code)
    if rs.error_code != '0':
        bs.logout()
        return None
    
    data_list = []
    while (rs.error_code == '0') & rs.next():
        data_list.append(rs.get_row_data())
    
    if not data_list:
        bs.logout()
        return None
        
    current_data = {
        'code': stock_code,
        'price': float(data_list[0][5]),
        'volume': float(data_list[0][6]),
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }
    
    bs.logout()
    return current_data

async def monitor_stocks():
    """监控股票价格和交易量的变化"""
    while True:
        if not monitored_stocks:
            await asyncio.sleep(1)
            continue
            
        for stock_code in monitored_stocks:
            current_data = await get_stock_data(stock_code)
            if not current_data:
                continue
                
            if stock_code not in stock_history:
                stock_history[stock_code] = current_data
                continue
                
            history = stock_history[stock_code]
            price_change = (current_data['price'] - history['price']) / history['price'] * 100
            volume_ratio = current_data['volume'] / history['volume'] if history['volume'] > 0 else 1
            
            # 检查预警条件
            alerts = []
            if abs(price_change) >= 3:
                alerts.append(f"价格变动: {price_change:.2f}%")
            if volume_ratio >= 2:
                alerts.append(f"成交量放大: {volume_ratio:.2f}倍")
                
            if alerts:
                alert_message = {
                    'stock_code': stock_code,
                    'alerts': alerts,
                    'current_price': current_data['price'],
                    'current_volume': current_data['volume'],
                    'timestamp': current_data['timestamp']
                }
                
                # 向所有连接的客户端发送预警
                for connection in active_connections:
                    try:
                        await connection.send_json(alert_message)
                    except:
                        pass
                        
            stock_history[stock_code] = current_data
            
        await asyncio.sleep(5)  # 每5秒更新一次数据

@app.on_event("startup")
async def startup_event():
    """启动时初始化baostock并开始监控任务"""
    asyncio.create_task(monitor_stocks())

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    active_connections.append(websocket)
    try:
        while True:
            data = await websocket.receive_json()
            if 'action' in data:
                if data['action'] == 'add_stock':
                    stock_code = data['stock_code']
                    if len(monitored_stocks) < 10:  # 限制最多10个股票
                        monitored_stocks.add(stock_code)
                        await websocket.send_json({
                            'status': 'success',
                            'message': f'Added stock {stock_code}'
                        })
                    else:
                        await websocket.send_json({
                            'status': 'error',
                            'message': 'Maximum number of stocks (10) reached'
                        })
                elif data['action'] == 'remove_stock':
                    stock_code = data['stock_code']
                    if stock_code in monitored_stocks:
                        monitored_stocks.remove(stock_code)
                        if stock_code in stock_history:
                            del stock_history[stock_code]
                        await websocket.send_json({
                            'status': 'success',
                            'message': f'Removed stock {stock_code}'
                        })
                elif data['action'] == 'get_monitored_stocks':
                    await websocket.send_json({
                        'status': 'success',
                        'stocks': list(monitored_stocks)
                    })
    except WebSocketDisconnect:
        active_connections.remove(websocket)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True) 