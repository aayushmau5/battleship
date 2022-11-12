# Battleship

Battleship game made using Elixir & Phoenix framework ❤️

You can:

- Play against computer
- Play against another player in real-time
- Create private rooms to play against a particular player

## Deployment

Deployed on [fly.io](https://fly.io) 💪

Live at https://aayush-battleship.fly.dev/ 😎

## Setup

Checkout the setup guide for Phoenix: https://hexdocs.pm/phoenix/installation.html

## Internals

### Approach(logical)

- Start with a 10 x 10 matrix(all 0)
- 4 types of ships based on their length(all different)
- When user places a ship of certain length, we set the length in the given matrix at the desired position
- If a ship is hit, we set -1 at that position, if it is a miss, we assign -2 at that position
- Check the matrix for any natural number(> 0), if there is none, user has won the game

## TODO

- Refactor game logic and main game server
- Add internal workings in readme

<!-- ### Workflow

Phoenix creates a process for each client connected to the server, so we use process to process communication through Phoenix PubSub.

Here's a high level overview of how it works:

![High level overview](https://user-images.githubusercontent.com/54525741/199268118-fc78a57c-883a-4533-ac6f-5969d45b8797.png)

Having every client with their own process unlocks a powerful way of organizing the workflow.

With the help of Phoenix Presence, and Phoenix PubSub

// More details here
// About handshake
// About generating room
// About know full room -->
