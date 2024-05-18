#!/usr/bin/env bash
export ENABLE_DEBUG=${ENABLE_DEBUG:-"FALSE"}
export ENABLE_SSH=${ENABLE_SSH:-"FALSE"}
export ENABLE_LOOP_ONLY=${ENABLE_LOOP_ONLY:-"FALSE"}

ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ > /etc/timezone

#cp /home/node/app/docker-build-files/supervisord_base.conf /supervisord.conf
cp /supervisord_base.conf /supervisord.conf

## Rotate logs at start just in case
/usr/sbin/logrotate -vf /etc/logrotate.d/*.auto &

/usr/bin/supervisord -n -c /supervisord.conf

if [[ "${ENABLE_SSH}" = "TRUE" ]]; then
  sed -E -i -e 's/ENABLE_SSH/1/' /supervisord.conf
else
  sed -E -i -e 's/ENABLE_SSH/0/' /supervisord.conf
fi

mkdir -p /root/.ssh
mkdir -p "${WEB_HOME_DIR}"/.ssh

if [[ -n "${SSH_AUTHORIZED_KEYS}" ]];then
  mkdir -p /root/.ssh
  echo "${SSH_AUTHORIZED_KEYS}" >> /root/.ssh/authorized_keys

  mkdir -p /home/node/.ssh
  chown -R "node:" /home/node/.ssh
  echo "${SSH_AUTHORIZED_KEYS}" >> /home/node/.ssh/authorized_keys
  chmod 600 /home/node/.ssh/authorized_keys
fi

chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
chown -R root: /root/.ssh

while :
  do
    echo "Press [CTRL+C] to stop.."
    sleep 10
  done
