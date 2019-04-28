FROM paperbenni/heroku
COPY start.sh start.sh

RUN chmod +x start.sh
CMD ./start.sh
