# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions


# This is a simple example for a custom action which utters "Hello World!"

# from typing import Any, Text, Dict, List
#
# from rasa_sdk import Action, Tracker
# from rasa_sdk.executor import CollectingDispatcher
#
#
# class ActionHelloWorld(Action):
#
#     def name(self) -> Text:
#         return "action_hello_world"
#
#     def run(self, dispatcher: CollectingDispatcher,
#             tracker: Tracker,
#             domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
#
#         dispatcher.utter_message(text="Hello World!")
#
#         return []

import json
from typing import Any, Text, List, Dict
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.events import SlotSet

DATA_FILE = "data.json"

class ActionShowTournaments(Action):
    def name(self) -> Text:
        return "action_show_tournaments"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        with open(DATA_FILE, 'r') as file:
            data = json.load(file)

        tournament_list = []
        for tournament in data['tournaments']:
            tournament_list.append(f"{tournament['name']} (ID: {tournament['id']})")

        response_message = "Here are the tournaments and their IDs:\n"
        response_message += "\n".join(tournament_list)

        dispatcher.utter_message(text=response_message)

        return []

class ActionAddPlayerToTournament(Action):
    def name(self) -> Text:
        return "action_add_player_to_tournament"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        tournament_id = tracker.get_slot("tournament_id")
        player_name = tracker.get_slot("player_name")
        
        tournament_id = int(tournament_id)

        with open(DATA_FILE, 'r') as file:
            data = json.load(file)
        
        tournament = None
        for t in data["tournaments"]:
            if t["id"] == tournament_id:
                tournament = t
                break

        if tournament:
            tournament['players'].append(player_name)

            with open(DATA_FILE, 'w') as file:
                json.dump(data, file, indent=4)
                
            
            dispatcher.utter_message(
                text=f"Player {player_name} has been added to the tournament:\nID: {tournament['id']}\nName: {tournament['name']}\nState: {tournament['state']}\nTeams: {tournament['teams']}\nPlayers: {tournament['players']}"
                )
            
            
            return [SlotSet("tournament_id", None), SlotSet("player_name", None)]
        else:
            dispatcher.utter_message(
                text=f"Sorry, no tournament found with ID {tournament_id}."
            )
            return [SlotSet("tournament_id", None), SlotSet("player_name", None)]
        
        
class ActionShowTournaments(Action):
    def name(self) -> Text:
        return "action_show_tournament_details"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        tournament_id = tracker.get_slot("tournament_id")
        
        tournament_id = int(tournament_id)

        with open(DATA_FILE, 'r') as file:
            data = json.load(file)
            
        tournament = None
        for t in data["tournaments"]:
            if t["id"] == tournament_id:
                tournament = t
                break

        dispatcher.utter_message(
            text=f"Here are tournament details:\nID: {tournament['id']}\nName: {tournament['name']}\nState: {tournament['state']}\nTeams: {tournament['teams']}\nPlayers: {tournament['players']}"
            )

        return [SlotSet("tournament_id", None), SlotSet("player_name", None)]