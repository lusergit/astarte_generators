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

defmodule Astarte.Core.Generators.TriggersTest do
  @moduledoc """
  Tests for Astarte Triggers generators.
  """
  alias Astarte.Core.Triggers.SimpleTriggerConfig
  alias Astarte.Core.Generators.Triggers

  use ExUnit.Case, async: true
  use ExUnitProperties

  @moduletag :triggers

  describe "trigger generator" do
    @describetag :success
    @describetag :ut

    setup :validation_fixture

    defp validation_helper(trigger) do
      changes = Map.from_struct(trigger)

      %SimpleTriggerConfig{}
      |> SimpleTriggerConfig.changeset(changes)
    end

    defp validation_fixture(_context), do: {:ok, validate: &validation_helper/1}

    property "is valid according to Triggers Changeset", %{validate: validate} do
      check all trigger <- Triggers.trigger(),
                changeset = validate.(trigger) do
        assert changeset.valid?, "Invalid trigger #{inspect(changeset.errors)}"
      end
    end
  end
end
