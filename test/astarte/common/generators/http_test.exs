#
# This file is part of Astarte.
#
# Copyright 2025 SECO Mind Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

defmodule Astarte.Common.Generators.HTTPTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Astarte.Common.Generators.HTTP

  @moduletag :common
  @moduletag :http

  @valid_http_methods [
    "get",
    "head",
    "options",
    "trace",
    "put",
    "delete",
    "post",
    "patch",
    "connect"
  ]

  describe "url generator" do
    property "generates valid urls" do
      check all url <- HTTP.url(), max_runs: 100 do
        assert %URI{scheme: scheme, authority: authority} = URI.parse(url)

        assert scheme != nil
        assert authority != nil
      end
    end
  end

  describe "method generator" do
    property "generates valid http methods" do
      check all method <- HTTP.method() do
        assert method in @valid_http_methods
      end
    end
  end
end
