from fastapi import FastAPI
import requests

app = FastAPI()


def get_weather(location: str):
    api_key = "89be9949d4f3e957623120d37377899f"
    response = requests.get(f"http://api.openweathermap.org/geo/1.0/zip?zip={location},US&appid={api_key}")
    data = response.json()
    lat = data["lat"]
    lon = data["lon"]
    weather_response = requests.get(f"http://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={api_key}&units=imperial")
    weather_data = weather_response.json()
    return weather_data


@app.get("/current_weather/{location}")
def current_weather(location: str):
    weather_data = get_weather(location)
    return "Expect " + str(weather_data["weather"][0]["description"]) + " with an average temperature of " + str(weather_data["main"]["temp"]) + " degrees Fahrenheit."



