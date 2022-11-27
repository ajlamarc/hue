import React, { useEffect, useState } from 'react';
import Urbit from '@urbit/http-api';
import { MantineProvider, Image, Switch, Slider, Button, Card, Tabs, ScrollArea } from '@mantine/core';
import hue_off from "./assets/hue-off.jpeg";
import hue_on from "./assets/hue-on.jpeg";
import { SelectPopover } from '@mantine/core/lib/Select/SelectPopover/SelectPopover';

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

export function App() {
  const [configured, setConfigured] = useState(false);
  const [on, setOn] = useState(false);
  const [bri, setBri] = useState(254);
  const [logs, setLogs] = useState([]);
  const redirect_url_base = window.location.href
  const setupLink = `https://account.meethue.com/get-token/?client_id=eazPdMZBG9LHfGBoid7tDmZrzCe7EF3V&response_type=code&devicename=urbhue-device-app&appid=urbhue&deviceid=urbhue-device&redirect_url_base=${redirect_url_base}&app_name=UrbHue`;

  useEffect(() => {
    // scry for initial state and set it
    api.scry({ app: 'hue', path: '/update' }).then((data) => {
      console.log(data);
      setOn(data['on']);
      setBri(data['bri']);
      getLogs();
      const agentCode = data['code'];

      const queryString = window.location.search;
      const urlParams = new URLSearchParams(queryString);
      if (agentCode !== '') {
        setConfigured(true);
      }
      else if (urlParams.has('code') && agentCode == '') { // register code
        const newCode = urlParams.get('code');
        submitCode(newCode);
        setConfigured(true);
      }
    });
  }, []);

  const getLogs = async () => {
    const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));
    await sleep(1000);  // let the new card be executed first

    api.scry({ app: 'hue', path: '/logs' }).then((logs) => {
      setLogs(logs);
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

  const submitCode = (_code: string) => {
    api.poke({
      app: 'hue',
      mark: 'hue-action',
      json: { code: _code },
    })
  }

  return (
    <MantineProvider withGlobalStyles withNormalizeCSS>
      <div className='flex items-center justify-center h-screen'>
        <div className='w-96'>
          <Card shadow="sm" p="lg" radius="md" withBorder className='flex flex-col'>
            <Tabs defaultValue='light'>
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
                  <>
                    <Switch checked={on} onChange={(e) => toggle(e.currentTarget.checked)} />
                    <Slider value={bri} min={1} max={254} disabled={!on} onChange={setBri} onChangeEnd={set_bri} />
                  </>
                ) : (<Button variant="light" color="blue" fullWidth mt="md" radius="md" onClick={() => {
                  window.open(setupLink, '_self');
                }}>
                  Setup
                </Button>)}
              </Tabs.Panel>

              <Tabs.Panel value='logs' pt='xs' className='h-96'>
                <ScrollArea style={{ height: 325 }} type='auto'>
                  {logs.map((log, i) => (
                    <p key={i}>time:{log[0]} on:{log[1].toString()} brightness:{log[2]}</p>
                  )
                  )}
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
