# Battleship

Battleship game made using Elixir & Phoenix framework ❤️

You can:

- Play against computer
- Play against another player in real-time

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

- Add flow diagram in README
- Ability to invite other player(through a room)
