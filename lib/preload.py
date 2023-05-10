from requests import get


def getRandomCarImages():
    images = []
    imagesToGet = 5

    while imagesToGet > 0:
        response = get("https://www.reddit.com/r/shootingcars/random.json?limit=1", headers={"User-Agent": "Flask Webserver"}).json()
        print(f"Getting image {imagesToGet}")
        try:
            # get thumbnail url
            images.append(
                {
                    "url": response[0]["data"]["children"][0]["data"]["preview"]["images"][0]["source"]["url"],
                    "author": response[0]["data"]["children"][0]["data"]["author"],
                }
            )
            imagesToGet -= 1
        except:
            print(f"Couldn't find image {imagesToGet}. Retrying...")
            pass

    return images
