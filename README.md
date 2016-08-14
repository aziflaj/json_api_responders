# JsonApiResponders

[![Gem Version](https://badge.fury.io/rb/json_api_responders.svg)](https://badge.fury.io/rb/json_api_responders)
[![Build Status](https://semaphoreci.com/api/v1/infinum/json_api_responders/branches/features-missing_responses/shields_badge.svg)](https://semaphoreci.com/infinum/json_api_responders)
[![Code Climate](https://codeclimate.com/repos/57b0be0a598ebc4f2300120c/badges/b652f337b8c8bed28660/gpa.svg)](https://codeclimate.com/repos/57b0be0a598ebc4f2300120c/feed)
This gem gives a few convinient methods for working with JSONAPI. It is inspired by responders gem.
[![Test Coverage](https://codeclimate.com/repos/57b0be0a598ebc4f2300120c/badges/b652f337b8c8bed28660/coverage.svg)](https://codeclimate.com/repos/57b0be0a598ebc4f2300120c/coverage)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_api_responders'
```

And then execute:

    $ bundle

## Usage

    user = User.first
    respond_with user
    respond_with user, on_error: { status: :unauthorized, detail: 'Invalid user or password' }
    respond_with_error, status: 401, detail: 'Bad credentials'

whatever can be passed to controller.render can be passed here:

        respond_with user, serializer: UserSerializer

## Responses

### index

    render json: resource, status: 200

### show

    render json: resource, status: 200

### create

    if resource.valid?
      render json: resource, status: 201
    else
      render error: errors, status: 409

### update

    if resource.valid?
      render json: resource, status: 200
    else
      render error: errors, status: 409

### destroy

    head status: 204

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/infinum/json_api_responders.
