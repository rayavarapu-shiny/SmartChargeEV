import requests

url = "https://maps.mail.ru/osm/tools/overpass/api/interpreter"

query = """
[out:json][timeout:15];

node["amenity"="charging_station"]
(around:3000,16.3067,80.4365);

out;
"""

headers = {
    "User-Agent": "SmartChargeEV/1.0 (college project)",
    "Accept": "application/json"
}

try:
    response = requests.post(
        url,
        data={"data": query},
        headers=headers,
        timeout=30
    )

    print("Status:", response.status_code)
    print(response.text[:5000])

except requests.exceptions.Timeout:
    print("ERROR: Server response timeout")

except requests.exceptions.RequestException as e:
    print("ERROR:", e)