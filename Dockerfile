FROM femtopixel/google-chrome-headless

ENV VERSION=v5.3.0 \
  RUBY_VERSION=2.6.1

LABEL maintainer="Jay MOULIN <jaymoulin@gmail.com> <http://twitter.com/MoulinJay>"
LABEL version="${VERSION}"

USER root

# Install deps + add Chrome Stable + purge all the things
#libgdbm3 
RUN rm -rf /var/lib/apt/lists/* && \
  apt-get update && \
  apt-get remove gnupg -y && apt-get install --reinstall gnupg2 dirmngr --allow-unauthenticated -y && \
  apt-get autoclean && apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg --no-install-recommends && \
  curl -sSL https://deb.nodesource.com/setup_11.x | bash - && \
  apt-get install -y nodejs git curl libssl-dev libreadline-dev \
  zlib1g-dev autoconf bison build-essential libyaml-dev libreadline6-dev \
  libncurses5-dev libffi-dev libgdbm-dev --no-install-recommends && \
  npm --global install npm && \
  npm --global install yarn && \
  # apt-get purge --auto-remove -y curl gnupg && \
  # rm -rf /var/lib/apt/lists/* && \
  npm install --global lighthouse && \
  mkdir -p /home/chrome/reports && chown -R chrome:chrome /home/chrome

RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN /root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh && \
  echo 'eval "$(rbenv init -)"' >> /root/.bashrc && \
  rbenv install 2.6.1 && rbenv global 2.6.1 && \
  rbenv rehash

RUN /root/.rbenv/shims/gem install sinatra puma

VOLUME /root/reports
WORKDIR /root/reports

COPY app/lighthouse_api.rb /root/lighthouse_api.rb
COPY app/config.ru /root/config.ru

EXPOSE 4567
CMD ["/root/.rbenv/shims/ruby", "/root/lighthouse_api.rb", "--host", "0.0.0.0"]
