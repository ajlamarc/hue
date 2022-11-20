import React, { useEffect, useState } from 'react';
import Urbit from '@urbit/http-api';
import { MantineProvider, Image, Switch, Slider, Button, Card, Tabs, ScrollArea } from '@mantine/core';
import hue_off from "./assets/hue-off.jpeg";
import hue_on from "./assets/hue-on.jpeg";

const api = new Urbit('', '', window.desk);
api.ship = window.ship;

export function App() {
  const [configured, setConfigured] = useState(false);
  const [on, setOn] = useState(false);
  const [bri, setBri] = useState(254);
  const redirect_url_base = window.location.href
  const setupLink = `https://account.meethue.com/get-token/?client_id=eazPdMZBG9LHfGBoid7tDmZrzCe7EF3V&response_type=code&devicename=urbhue-device-app&appid=urbhue&deviceid=urbhue-device&redirect_url_base=${redirect_url_base}&app_name=UrbHue`;

  useEffect(() => {
    // on-init (see create-landscape-app)
    // scry for initial state and set it
    api.scry({ app: 'hue', path: '/update' }).then((data) => {
      console.log(data);
      setOn(data['on']);
      setBri(data['bri']);
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

  const toggle = (_on: boolean) => {
    api.poke({
      app: 'hue',
      mark: 'hue-action',
      json: { toggle: _on },
      onSuccess: () => setOn(_on),
    })
  }

  const set_bri = (_bri: number) => {
    api.poke({
      app: 'hue',
      mark: 'hue-action',
      json: { bri: _bri },
      onSuccess: () => { setBri(_bri); },
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
      <div className='flex h-screen justify-center items-center'>
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
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>earl</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                  <p>test log</p>
                </ScrollArea>
                <div className='pt-6 flex'>
                  <a className='text-blue-600 flex-grow'>Export logs to CSV</a>
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
