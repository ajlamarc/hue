// @ts-nocheck
import React, { useEffect, useState } from 'react';
import Urbit from '@urbit/http-api';
import { MantineProvider, Image, Switch, Slider, Button, Card, Tabs, ScrollArea, Select, Table, Loader } from '@mantine/core';
import hue_off from "./assets/hue-off.png";
import hue_on from "./assets/hue-on.png";

const api = new Urbit('', '', window.desk);
api.ship = window.ship;

// see https://stackoverflow.com/a/68146412
/** Convert a 2D array into a CSV string
 */
function arrayToCsv(data) {
  return data.map(row =>
    row
      .map(String)  // convert every value to String
      .map(v => v.replaceAll('"', '""'))  // escape double colons
      .map(v => `"${v}"`)  // quote it
      .join(',')  // comma-separated
  ).join('\r\n');  // rows starting on new lines
}

/** Download contents as a file
 * Source: https://stackoverflow.com/questions/14964035/how-to-export-javascript-array-info-to-csv-on-client-side
 */
function downloadBlob(content, filename, contentType) {
  // Create a blob
  var blob = new Blob([content], { type: contentType });
  var url = URL.createObjectURL(blob);

  // Create a link to download it
  var pom = document.createElement('a');
  pom.href = url;
  pom.setAttribute('download', filename);
  pom.click();
}

const groupsToData = (groups: Object) => {
  const data = [{ value: '0', label: 'All' }];
  for (const [key, value] of Object.entries(groups)) {
    data.push({ value: key, label: value });
  }
  return data;
}

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

export function App() {
  const [loading, setLoading] = useState(false);
  const [configured, setConfigured] = useState(false);
  const [on, setOn] = useState(false);
  const [bri, setBri] = useState(254);
  const [logs, setLogs] = useState([]);
  const [group, setGroup] = useState('0');
  const [data, setData] = useState({ value: '0', label: 'All' });
  const redirect_url_base = window.location.href
  const setupLink = `https://account.meethue.com/get-token/?client_id=eazPdMZBG9LHfGBoid7tDmZrzCe7EF3V&response_type=code&devicename=urbhue-device-app&appid=urbhue&deviceid=urbhue-device&redirect_url_base=${redirect_url_base}&app_name=UrbHue`;

  useEffect(() => {
    // scry for initial state and set it
    api.scry({ app: 'hue', path: '/update' }).then((data) => {
      console.log(data);
      setOn(data['on']);
      setBri(data['bri']);
      setData(groupsToData(data['group-names']));
      setGroup(data['group']);
      getLogs();
      // getGroups();
      const agentCode = data['code'];

      const queryString = window.location.search;
      const urlParams = new URLSearchParams(queryString);
      if (agentCode !== '') {
        setConfigured(true);
      }
      else if (urlParams.has('code') && agentCode == '') { // register code
        const newCode = urlParams.get('code');
        submitCode(newCode);
      }
    });
  }, []);

  const getLogs = async () => {
    await sleep(1000);  // let the new card be executed first

    api.scry({ app: 'hue', path: '/logs' }).then((logs) => {
      setLogs(logs);
    });
  }

  const changeCurrGroup = async (group: string) => {
    api.poke({
      app: 'hue',
      mark: 'hue-action',
      json: { group: group }
    });
    setGroup(group);
    // scry for /update again (on and bri)? after they have been updated for the changed group.
    await sleep(500);
    api.scry({ app: 'hue', path: '/update' }).then((data) => {
      console.log(data);
      setOn(data['on']);
      setBri(data['bri']);
      setData(groupsToData(data['group-names']));
    });
  }

  const toggle = (_on: boolean) => {
    api.poke({
      app: 'hue',
      mark: 'hue-action',
      json: { toggle: _on },
      onSuccess: () => { setOn(_on); getLogs(); },
    })
  }

  const set_bri = (_bri: number) => {
    api.poke({
      app: 'hue',
      mark: 'hue-action',
      json: { bri: _bri },
      onSuccess: () => { setBri(_bri); getLogs(); },
    })
  }

  const submitCode = async (_code: string) => {
    setLoading(true);
    api.poke({
      app: 'hue',
      mark: 'hue-action',
      json: { code: _code },
    })
    await sleep(10000);
    api.scry({ app: 'hue', path: '/update' }).then((data) => {
      console.log(data);
      setOn(data['on']);
      setBri(data['bri']);
      setData(groupsToData(data['group-names']));
      setGroup(data['group']);
      getLogs();
      setConfigured(true);
      setLoading(false);
    });
  }

  return (
    <MantineProvider withGlobalStyles withNormalizeCSS>
      <div className='flex items-center justify-center h-screen'>
        <div className='w-96'>
          <Card shadow="sm" p="lg" radius="md" withBorder className='flex flex-col'>
            <Tabs color='yellow' defaultValue='light'>
              <Tabs.List>
                <Tabs.Tab value='light'>Lights</Tabs.Tab>
                <Tabs.Tab value='logs'>Logs</Tabs.Tab>
              </Tabs.List>

              <Tabs.Panel value='light' pt='xs'>
                <Card.Section>
                  <Image
                    src={on ? hue_on : hue_off}
                    alt="lightbulb"
                  />
                </Card.Section>
                {configured ? (
                  <div className='pt-6'>
                    <div className='flex'>
                      <Switch color='yellow' className='flex-grow' checked={on} onChange={(e) => toggle(e.currentTarget.checked)} />
                      <Select color='yellow' placeholder='Choose Group' value={group} data={data} onChange={changeCurrGroup} />
                    </div>

                    <Slider color='yellow' className='pt-6' label={null} value={bri} min={1} max={254} disabled={!on} onChange={setBri} onChangeEnd={set_bri} />
                  </div>
                ) : (<Button variant="light" color="yellow" fullWidth mt="md" radius="md" onClick={() => {
                  window.open(setupLink, '_self');
                }}>
                  {loading ? <Loader color='yellow' size='sm' /> : 'Setup'}
                </Button>)}
              </Tabs.Panel>

              <Tabs.Panel value='logs' pt='xs' className='h-96'>
                <ScrollArea style={{ height: 325 }} type='auto'>
                  <Table>
                    <thead>
                      <tr>
                        <th>Time</th>
                        <th>Group</th>
                        <th>On</th>
                        <th>Bri</th>
                      </tr>
                    </thead>
                    <tbody>{
                      logs.map((log, i) => (
                        <tr key={i}>
                          <td>{log[0]}</td>
                          <td>{log[1]}</td>
                          <td>{log[2].toString()}</td>
                          <td>{log[3]}</td>
                        </tr>
                      )
                      )
                    }</tbody>
                  </Table>
                </ScrollArea>
                <div className='flex pt-6'>
                  <a href="" className='flex-grow text-blue-600' onClick={() => downloadBlob(arrayToCsv(logs), 'export.csv', 'text/csv;charset=utf-8;')}>Export logs to CSV</a>
                  <a href='https://account.meethue.com/homes' target='_blank' className='text-rose-600'>Unlink</a>
                </div>
              </Tabs.Panel>
            </Tabs>
          </Card>
        </div>
      </div>

    </MantineProvider>
  );
}
