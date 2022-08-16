# Battleship

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix

## Flow

- A front page:
  - showing all the users who are playing the game
  - an input box for name input
- After entering their name, user press play. They are taken to a page where they enter their preferred ship position.
- After successful entry, they are matched against another play available(if not available, give an option to play against a computer). The opposite players are matched automatically.
- After successful match, the user is redirected to a play page where they against another player(handle cases: what if a player leaves a game in middle).

## Approach(logical)

- 10 x 10 matrix(all zero)
- 4 types of ships based on their length(all different)
- When user places a ship of certain length, we set the length in the given matrix at the desired position
- If a ship is hit, we set -1 at that position, if it is a miss, we assign -2 at that position
- Check the matrix for any natural number, if there is none, user has won the game

## Approach(application)

- When a user plays a game against another player, they will generate a "room id", which is will be stored in an :ets table(or mnesia). When another player also plays a game, our application will look up on the table to see any free room. On a free room, user will join that room. At this point, we will remove that room id from the table.
- Perhaps check and use Pheonix channels. Checkout the YT video to see the preferred approach.
- On enemy board click, send the row and col id to another processes liveview, and attack at the position. Need to handle styles for hit, and miss.

## Todo

- Add computer player
- Add the ability to play against another player
- If a player leaves the game, another player should be joined with a new player. But remove all the attacks from current player, and preserve their ship position.(Basically resetting the game without remove the ship positions)
- Set pubsub in board component, and let it all handle the internal logic
