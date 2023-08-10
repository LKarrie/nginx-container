#!/bin/sh

if [ -n "${SYSTEM}" -a -n "${APP}" -a -n "${POD_NAME}" ]
then
  echo "change logpath to logs/${SYSTEM}/${APP}/${POD_NAME}/nginx"
  sed -i -e '/_log /s/logs\//\/app\/logs\/'${SYSTEM}'\/'${APP}'\/'${POD_NAME}'\/nginx\//g' /app/nginx/conf/nginx.conf
  mkdir -p /app/logs/${SYSTEM}/${APP}/${POD_NAME}/nginx
else
  echo "env ['SYSTEM', 'APP', 'POD_NAME'] is not defined, logpath not changed"
fi

