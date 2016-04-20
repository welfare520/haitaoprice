# encoding: UTF-8

require 'date'
require 'time'
require 'erb'
require 'json'
require 'sinatra'
require "sinatra/namespace"
require 'sinatra/async'
require 'yaml'
require 'virtus'
require 'fileutils'
require 'mysql2'
require 'csv'
# require 'big_query'
require 'mail'
require 'mongo'
require 'impala'

ENV['RACK_ENV'] ||= 'development'

Dir.glob('./{config,lib,models,middleware,helpers,controllers}/*.rb').each { |file| require file }

# use Login
# use Authentication 
run ApplicationController
