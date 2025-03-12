import React, { useState, useEffect } from 'react';
import { Layout, Card, Input, Button, List, message, Typography } from 'antd';
import { PlusOutlined, DeleteOutlined } from '@ant-design/icons';
import './App.css';

const { Header, Content } = Layout;
const { Title } = Typography;

interface StockAlert {
  stock_code: string;
  alerts: string[];
  current_price: number;
  current_volume: number;
  timestamp: string;
}

function App() {
  const [stockCode, setStockCode] = useState('');
  const [monitoredStocks, setMonitoredStocks] = useState<string[]>([]);
  const [alerts, setAlerts] = useState<StockAlert[]>([]);
  const [ws, setWs] = useState<WebSocket | null>(null);

  useEffect(() => {
    const websocket = new WebSocket('ws://localhost:8888/ws');
    
    websocket.onopen = () => {
      console.log('Connected to server');
      websocket.send(JSON.stringify({ action: 'get_monitored_stocks' }));
    };

    websocket.onmessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.status === 'success') {
        if (data.stocks) {
          setMonitoredStocks(data.stocks);
        }
      } else if (data.alerts) {
        setAlerts(prev => [data, ...prev].slice(0, 50)); // 保留最近50条预警
      }
    };

    websocket.onclose = () => {
      console.log('Disconnected from server');
      setTimeout(() => {
        window.location.reload();
      }, 1000);
    };

    setWs(websocket);

    return () => {
      websocket.close();
    };
  }, []);

  const addStock = () => {
    if (!stockCode) {
      message.error('请输入股票代码');
      return;
    }

    if (monitoredStocks.length >= 10) {
      message.error('最多只能监控10个股票');
      return;
    }

    if (monitoredStocks.includes(stockCode)) {
      message.error('该股票已在监控列表中');
      return;
    }

    ws?.send(JSON.stringify({
      action: 'add_stock',
      stock_code: stockCode
    }));
    setStockCode('');
  };

  const removeStock = (code: string) => {
    ws?.send(JSON.stringify({
      action: 'remove_stock',
      stock_code: code
    }));
  };

  return (
    <Layout className="layout" style={{ minHeight: '100vh' }}>
      <Header style={{ background: '#fff', padding: '0 50px' }}>
        <Title level={2} style={{ margin: '16px 0' }}>股票监控系统</Title>
      </Header>
      <Content style={{ padding: '0 50px' }}>
        <div style={{ background: '#fff', padding: 24, minHeight: 280 }}>
          <Card title="添加监控股票">
            <Input.Group compact>
              <Input
                style={{ width: 'calc(100% - 200px)' }}
                placeholder="请输入股票代码（例如：sh.600000）"
                value={stockCode}
                onChange={(e) => setStockCode(e.target.value)}
                onPressEnter={addStock}
              />
              <Button type="primary" icon={<PlusOutlined />} onClick={addStock}>
                添加监控
              </Button>
            </Input.Group>
          </Card>

          <Card title="监控列表" style={{ marginTop: 16 }}>
            <List
              size="small"
              bordered
              dataSource={monitoredStocks}
              renderItem={item => (
                <List.Item
                  actions={[
                    <Button
                      type="text"
                      danger
                      icon={<DeleteOutlined />}
                      onClick={() => removeStock(item)}
                    >
                      删除
                    </Button>
                  ]}
                >
                  {item}
                </List.Item>
              )}
            />
          </Card>

          <Card title="预警信息" style={{ marginTop: 16 }}>
            <List
              size="small"
              bordered
              dataSource={alerts}
              renderItem={item => (
                <List.Item>
                  <div>
                    <p>股票代码: {item.stock_code}</p>
                    <p>预警信息: {item.alerts.join(', ')}</p>
                    <p>当前价格: {item.current_price}</p>
                    <p>当前成交量: {item.current_volume}</p>
                    <p>时间: {item.timestamp}</p>
                  </div>
                </List.Item>
              )}
            />
          </Card>
        </div>
      </Content>
    </Layout>
  );
}

export default App; 