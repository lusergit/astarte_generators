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
# SPDX-License-Identifier: Apache-2.0
#

defmodule Astarte.Core.Generators.Triggers do
  @moduledoc """
  This module provides generators for Astarte Triggers

  See https://docs.astarte-platform.org/astarte/latest/060-triggers.html
  """
  alias Astarte.Core.Generators.Device
  alias Astarte.Core.Generators.Interface
  alias Astarte.Core.Triggers.SimpleTriggerConfig
  alias Astarte.Generators.Utilities.ParamsGen
  use ExUnitProperties
  import ParamsGen

  @doc """
  Generates a valid Astarte Trigger.

  https://github.com/astarte-platform/astarte_core/blob/master/lib/astarte_core/interface.ex
  """
  def trigger(params \\ []) do
    one_of([device_trigger(params), data_trigger(params)])
  end

  defp device_trigger(params) do
    params gen all on <- device_on(),
                   device_id <- Device.id(),
                   group_name <- string(:utf8),
                   params: params do
      struct(%SimpleTriggerConfig{
        type: "device_trigger",
        on: on,
        device_id: device_id,
        group_name: group_name
      })
    end
  end

  defp data_trigger(params) do
    params gen all device_id <- binary(),
                   group_name <- string(:utf8),
                   on <- data_on(),
                   interface_name <- Interface.name(),
                   interface_major <- integer(0..9),
                   match_path <- Interface.endpoint_prefix(),
                   value_match_operator <- value_match_operator(),
                   known_value <- known_value(value_match_operator),
                   params: params do
      struct(%SimpleTriggerConfig{
        type: "data_trigger",
        device_id: device_id,
        group_name: group_name,
        on: on,
        interface_name: interface_name,
        interface_major: interface_major,
        match_path: match_path,
        value_match_operator: value_match_operator,
        known_value: known_value
      })
    end
  end

  defp known_value(operator) do
    case operator do
      :ANY -> nil
      :EQUAL_TO -> one_of([integer(), string(:utf8)])
      :NOT_EQUAL_TO -> one_of([integer(), string(:utf8)])
      :GREATER_THAN -> integer()
      :GREATER_OR_EQUAL_TO -> integer()
      :LESS_THAN -> integer()
      :LESS_OR_EQUAL_TO -> integer()
      :CONTAINS -> string(:utf8)
      :NOT_CONTAINS -> string(:utf8)
    end
  end

  defp value_match_operator,
    do:
      member_of([
        :ANY,
        :EQUAL_TO,
        :NOT_EQUAL_TO,
        :GREATER_THAN,
        :GREATER_OR_EQUAL_TO,
        :LESS_THAN,
        :LESS_OR_EQUAL_TO,
        :CONTAINS,
        :NOT_CONTAINS
      ])

  defp data_on,
    do:
      member_of([
        "incoming_data",
        "value_stored",
        "value_change",
        "value_change_applied",
        "path_created",
        "path_removed"
      ])

  defp device_on,
    do:
      member_of([
        "device_connected",
        "device_disconnected",
        "device_error"
      ])

  defp action(params) do
    params gen all http_url <- valid_url(),
                   http_method <- http_method(),
                   ignore_ssl_errors <- member_of([true, false]),
                   params: params do
      %{
        http_url: http_url,
        http_method: http_method,
        ignore_ssl_errors: ignore_ssl_errors
      }
    end
  end

  defp valid_url do
    gen all domain <- string([?a..?z], length: 5..10),
            tdl <- string([?a..?z], length: 3..4),
            path <-
              string([?a..?z], length: 2..10)
              |> list_of(min_length: 1, max_length: 10)
              |> map(&Enum.join(&1, "/")) do
      "http://#{domain}.#{tdl}/#{path}"
    end
  end

  defp http_method,
    do:
      member_of(["get", "head", "post", "put", "delete", "connect", "options", "trace", "patch"])
end
