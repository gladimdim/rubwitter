#!/usr/bin/env ruby
require "twitter_oauth"
require "yaml"
require "open3"
RUBWITTER_LIBRARY_PATH = File.dirname(__FILE__)  + "../lib/".to_s
$:.unshift(RUBWITTER_LIBRARY_PATH)
require "rubwitter"
include Rubwitter
Rubwitter.start_app()
