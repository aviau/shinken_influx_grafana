build:
	sudo docker build -t mon_image .

kill:
	- sudo docker stop mon
	- sudo docker rm mon

volume_permissions:
	sudo chown -R 1050:1050 influxdb_data

run: kill build volume_permissions
	sudo docker run -d -t -v ${PWD}/influxdb_data:/opt/influxdb/shared/data/db --name mon mon_image
	sudo docker inspect --format='{{.NetworkSettings.IPAddress}}' mon

run-interactive: kill build volume_permissions
	sudo docker run -i -t -v ${PWD}/influxdb_data:/opt/influxdb/shared/data/db --name mon mon_image bash	

prod: kill build volume_permissions
	sudo docker run -d -t -v ${PWD}/influxdb_data:/opt/influxdb/shared/data/db -p 7767:7767 -p 7760:7760 -p 8083:8083 -p 8086:8086 -p 8080:80 --name mon mon_image
	sudo docker inspect --format='{{.NetworkSettings.IPAddress}}' mon
