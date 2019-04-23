FROM paperbenni/heroku
COPY start.sh start.sh

RUN wget https://raw.githubusercontent.com/paperbenni/bash/master/heroku/login.sh && \
chmod +x start.sh login.sh
