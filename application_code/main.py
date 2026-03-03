from fastapi import FastAPI
from pydantic import BaseModel
import requests

app = FastAPI()


def get_weather():
    location = input("Enter your zip code: ")
    api_key = "89be9949d4f3e957623120d37377899f"
    response = requests.get(f"http://api.openweathermap.org/geo/1.0/zip?zip={location},US&appid={api_key}")
    data = response.json()
    lat = data["lat"]
    lon = data["lon"]
    weather_response = requests.get(f"http://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={api_key}&units=imperial")
    weather_data = weather_response.json()
    return weather_data


@app.get("/current_weather")
def current_weather():
    weather_data = get_weather()
    print("Expect " + str(weather_data["weather"][0]["description"]) + " with an average temperature of " + str(weather_data["main"]["temp"]) + " degrees Fahrenheit.")
    return "Expect " + str(weather_data["weather"][0]["description"]) + " with an average temperature of " + str(weather_data["main"]["temp"]) + " degrees Fahrenheit."

current_weather()



"""
class Item(BaseModel):
    name: str
    price: float
    is_offer: bool | None = None

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str | None = None):
    return {"item_id": item_id, "q": q}

@app.put("/items/{item_id}")
def update_item(item_id: int, item: Item):
    return {"item_name": item.name, "item_id": item_id}
"""

