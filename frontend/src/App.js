import React, { useState, useEffect } from "react";
import "./App.css";
import { Accordion, Card } from "react-bootstrap";
import * as moment from 'moment'
import axios from "axios";

const App = () => {
  const [transactionData, setTransactionData] = useState([]);

  const tData = async () => {
    const response = await axios.get(
      "http://localhost:5000/api/transactions"
    );

    setTransactionData(response.data);
  };

  const renderAccordion = (t, index) => {
    return (        
      <Accordion key={index}>
        <Card style={{backgroundColor: t.type == 'credit' ? '#aaaaaa' : '#ffffff'}}>
          <Accordion.Toggle as={Card.Header} eventKey={t}>
            {t.type} - ${t.amount}<i>+</i>
          </Accordion.Toggle>
          <Accordion.Collapse eventKey={t}>
            <Card.Body>
              <ul>
                <li>Id: {t.tx_id}</li>
                <li>Type: {t.type}</li>
                <li>Amount: {t.amount}</li>
                <li>Date: {moment.unix(parseInt(t.timestamp)).format('LLLL')}</li>                
              </ul>
            </Card.Body>
          </Accordion.Collapse>
        </Card>
      </Accordion>
    );
  };

  useEffect(() => {
    tData();
  }, []);

  return <div className="App">{transactionData.map(renderAccordion)}</div>;
};

export default App;
