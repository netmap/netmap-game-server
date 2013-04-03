# Idempotent VM setup steps.

# Git URL that allows un-authenticated pulls.
GIT_PUBLIC_URL=git://github.com/netmap/netmap-server.git

# Git URL that allows pushes, but requires authentication.
GIT_PUSH_URL=git@github.com:netmap/netmap-server.git


set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# If the server repository is already checked out, run the script from there.
if [ -f ~/netmap/doc/vm-server-update.sh ] ; then
  if [ "$*" != "git-pulled" ] ; then
    cd ~/netmap
    git checkout master
    git pull "$GIT_PUBLIC_URL" master
    exec ~/netmap/doc/vm-server-update.sh git-pulled
  fi
fi

# Password-less sudo.
if ! sudo grep "netmap ALL=[\(]ALL:ALL[\)] NOPASSWD: ALL" /etc/sudoers ; then
  # This line should only be added once.
  sudo sh -c "echo netmap ALL=\(ALL:ALL\) NOPASSWD: ALL >> /etc/sudoers"
fi

# Generic update.
sudo apt-get update -qq
sudo apt-get -y dist-upgrade

# Build environment.
sudo apt-get install -y build-essential

# Easy way to add PPAs.
sudo apt-get install -y software-properties-common

# Git.
sudo apt-get install -y git

# Postgresql.
sudo apt-get install -y libpq-dev postgresql postgresql-client \
    postgresql-contrib postgresql-server-dev-all
if sudo -u postgres createuser --superuser $USER; then
  # Don't attempt to re-create the user's database if the user already exists.
  createdb $USER
fi

# PostGIS 2.
sudo add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
sudo apt-get update -qq
sudo apt-get install -y postgis

# osm2pgsql
sudo add-apt-repository -y ppa:kakrueger/openstreetmap  # osm2pgsql 0.81
sudo apt-get update -qq
sudo apt-get install -y osm2pgsql

# SQLite, because Rails is uncomfortable without it.
sudo apt-get install -y libsqlite3-dev sqlite3

# Ruby and Rubygems, used to run Rails.
sudo apt-get install -y ruby ruby-dev
sudo env REALLY_GEM_UPDATE_SYSTEM=1 gem update --system 1.8.25

# Bundler, used to install all the gems in a Gemfile.
sudo gem install bundler

# libv8, used by the therubyracer, chokes when installed by bundler.
sudo gem install therubyracer


# Mapnik, used to render map tiles.
sudo add-apt-repository -y ppa:mapnik/v2.1.0
sudo apt-get update -qq
sudo apt-get install -y libmapnik-dev mapnik-utils
sudo gem install ruby_mapnik

# If the repository is already checked out, update the code.
if [ -d ~/netmap ] ; then
  cd ~/netmap
  git checkout master
  git pull "$GIT_PUBLIC_URL" master
  bundle install
  rake db:migrate db:seed
fi

# Otherwise, check out the repository.
if [ ! -d ~/netmap ] ; then
  cd ~
  git clone "$GIT_PUBLIC_URL" netmap
  cd ~/netmap
  bundle install
  rake db:create db:migrate db:seed
  rake osm:create osm:load

  # Switch the repository URL to the one that accepts pushes.
  git remote rm origin
  git remote add origin "$GIT_PUSH_URL"
fi

