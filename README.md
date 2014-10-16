# Shinken + influxdb + grafana

## Requirements
- docker

## Getting started
-  ``` make run ```

# View the following
- Grafana: http://[CONTAINER IP]:3000
- Mod-webui: http://[CONTAINER IP]:7767 (user:admin pass:admin)
- influxdb: http://[CONTAINER IP]:8083/ (user:root pass:root)

# Make graphs
- Go to grafana
- Add panel -> Graph
- Edit
- Metrics tab -> Enter 'google_com.store.time' in series name
- You should figure out the rest!
