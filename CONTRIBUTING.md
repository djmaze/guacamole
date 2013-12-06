# Contributing

When you want to write code for the project, please follow these guidelines:

1. **Claim** the ticket: Tell us that you want to work on a certain ticket, we will assign it to you (We don't want two people to work on the same thing :wink: )
2. **Fork** your feature branch from the `master` branch
3. Write an **acceptance test**: Describe what you want to do (our acceptance tests touch the database)
4. **Implement** it: Write a unit test, check that it fails, make the test pass – repeat (our unit tests don't touch the database)
5. Write **documentation** for it.
6. Check with `bundle exec rake ci` (you need to have ArangoDB running for that) that everything is fine and send the pull request to the `master` branch :)

## Setup

Nothing special:

* Clone the project
* `cd` into the folder and run `bundle` 
* `bundle exec rake ci` and see all tests passing (you need to have ArangoDB running for that)
* Happy hacking!

## Guard

Guard is a tool for comfortable development. If you want to use it, you have to first start an instance of ArangoDB and then start guard with `bundle exec guard`. This will:

* Run `bundle` whenever you change the dependencies
* Run the **unit tests** whenever you change a file in the lib or spec directory
