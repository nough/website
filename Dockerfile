# syntax=docker/dockerfile:1

FROM python:slim
# WORKDIR /app
COPY . .
# RUN apt-get update && apt-get install -y python3.11 python3-pip
ENV PIP_ROOT_USER_ACTION=ignore
RUN pip install -r requirements.txt
ENV FLASK_APP hackspace_website:create_app
ENV FLASK_ENV development
EXPOSE 5000
EXPOSE 8000
#CMD ["flask"]
# ENTRYPOINT ["flask", "run", "--host=0.0.0.0"]
CMD ["gunicorn", "hackspace_website:create_app()", "-b", "0.0.0.0"]
# "-w", "4", "-c", "gunicorn.config.py",
