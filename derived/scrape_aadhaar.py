import requests as r
import os
from pandas.io.json import json_normalize

action_postURL = 'https://geoportal.nic.in/portal/sharing/rest/content/items/966ba393cb514107b233fb251d8d78a0/data?f=json'

res = r.get(action_postURL)

search_cookies = res.cookies 

