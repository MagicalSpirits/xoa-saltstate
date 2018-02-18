xoa-install-dir:
  file.directory:
    - name: /opt/xoa
xoa-node-repo:
  pkgrepo.managed:
    - humanname: NodeSource
    - name: deb https://deb.nodesource.com/node_7.x jessie main
    - file: /etc/apt/sources.list.d/nodesource.list
    - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
xoa-yarn-repo:
  pkgrepo.managed:
    - humanname: Yarn
    - name: deb https://dl.yarnpkg.com/debian/ stable main
    - file: /etc/apt/sources.list.d/yarn.list
    - key_url: https://dl.yarnpkg.com/debian/pubkey.gpg
xoa-prereq: 
  pkg.installed:
    - names:
      - build-essential
      - nodejs
      - redis-server
      - libpng-dev
      - git
      - python-minimal
      - yarn
      - curl
    - require: 
      - xoa-node-repo
      - xoa-yarn-repo
xoa-server-git:
  git.latest:
    - target: /opt/xoa/xo-server
    - name: http://github.com/vatesfr/xo-server
    - branch: stable
    - require: 
      - xoa-install-dir 
      - xoa-prereq
xoa-server-build:
  cmd.run:
    - cwd: /opt/xoa/xo-server
    - names:
      - yarn run index-modules
      - yarn
    - require:
      - xoa-server-git
    - creates: /opt/xoa/xo-server/dist
xoa-web-git:
  git.latest:
    - target: /opt/xoa/xo-web
    - name: http://github.com/vatesfr/xo-web
    - branch: stable
    - require: 
      - xoa-install-dir
      - xoa-prereq
xoa-web-build:
  cmd.run:
    - cwd: /opt/xoa/xo-web
    - names:
      - yarn run index-modules
      - yarn
    - require:
      - xoa-web-git
    - creates: /opt/xoa/xo-web/dist
xoa-config:
  cmd.run:
    - name: curl -L https://raw.githubusercontent.com/hackmods/autoXOA/master/config/xo-server.yaml -o /opt/xoa/xo-server/.xo-server.yaml
    - creates: /opt/xoa/xo-server/.xo-server.yaml
    - require: 
      - xoa-prereq
      - xoa-install-dir 
xoa-service:
  cmd.run:
    - cwd: /opt/xoa/xo-server
    - names:
      - yarn global add forever
      - forever start bin/xo-server
    - require:
      - xoa-config
      - xoa-web-build
      - xoa-server-build 
