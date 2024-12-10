link to video presentation: https://drive.google.com/file/d/1YAPIoK3sQGOzoSMxqd4rkPl8W30eKr68/view?usp=sharing



####WYMAGANIA####

Należy wykonać odpowiednio na ocenę poszczególne zadania (wyższa ocena wymaga wykonania wszystkich poprzednich):
3.0 Ma zaimplementowane minimum 3 ścieżki (stories)
3.5 Wyświetla listę dostępnych rozgrywek
4.0 Dodaje zawodnika do rozgrywki
4.5 Potwierdza dodanie zawodnika wraz z numerem oraz szczegółami turnieju
5.0 Wywietlenie wszystkich drużyn, stanu rozgrywki oraz wszystkich zawodników w rozgrywce

#####START########
CMD1:
rasa train
rasa run actions

CMD2:
rasa run

CMD3:
ngrok

CONFIG:
api.slack ->  Event Subscriptions
paste ngrok url/webhooks/slack/webhook
