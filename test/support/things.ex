defmodule Things do
  use Absinthe.Schema
  alias Absinthe.Type

  @db %{
    "foo" => %{id: "foo", name: "Foo", value: 4},
    "bar" => %{id: "bar", name: "Bar", value: 5}
  }

  mutation do

    field :update_thing,
      type: :thing,
      args: [
        id: [type: non_null(:string)],
        thing: [type: non_null(:input_thing)]
      ],
      resolve: fn
        %{id: id, thing: %{value: val}}, _ ->
          found = @db |> Map.get(id)
        {:ok, %{found | value: val}}
        %{id: id, thing: fields}, _ ->
          found = @db |> Map.get(id)
        {:ok, found |> Map.merge(fields)}
      end

  end

  query do

    field :version, :string

    field :bad_resolution,
      type: :thing,
      resolve: fn(_, _) ->
        :not_expected
      end

    field :number,
      type: :string,
      args: [
        val: [type: non_null(:integer)]
      ],
      resolve: fn
       %{val: v} -> v |> to_string
      end

    field :thing_by_context,
      type: :thing,
      resolve: fn
        _, %{context: %{thing: id}} ->
          {:ok, @db |> Map.get(id)}
        _, _ ->
          {:error, "No :id context provided"}
      end

    field :thing,
      type: :thing,
      args: [
        id: [
          description: "id of the thing",
          type: non_null(:string)
        ],
        deprecated_arg: deprecate([
          description: "This is a deprecated arg",
          type: :string
        ]),
        deprecated_non_null_arg: deprecate([
          description: "This is a non-null deprecated arg",
          type: non_null(:string)
        ]),
        deprecated_arg_with_reason: deprecate([
          description: "This is a deprecated arg with a reason",
          type: :string
        ], reason: "reason"),
        deprecated_non_null_arg_with_reason: deprecate([
          description: "This is a non-null deprecated arg with a reasor",
          type: non_null(:string)
        ], reason: "reason"),
      ],
      resolve: fn
        %{id: id}, _ ->
          {:ok, @db |> Map.get(id)}
      end

    field :deprecated_thing,
      type: :thing,
      args: [
        id: [
          description: "id of the thing",
          type: non_null(:string)
        ]
      ],
      resolve: fn
        %{id: id}, _ ->
          {:ok, @db |> Map.get(id)}
      end,
      deprecate: true

    field :deprecated_thing_with_reason,
      type: :thing,
      args: [
        id: [
          description: "id of the thing",
          type: non_null(:string)
        ]
      ],
      deprecate: "use `thing' instead",
      resolve: fn
        %{id: id}, _ ->
          {:ok, @db |> Map.get(id)}
      end

  end

  @doc "A thing as input"
  input_object :input_thing do
    field :value, :integer
    field :deprecated_field, :string, deprecate: true
    field :deprecated_field_with_reason, :string, deprecate: "reason"
    field :deprecated_non_null_field, non_null(:string), deprecate: true
    field :deprecated_non_null_field_with_reason, :string, deprecate: "reason"
  end

  @doc "A thing"
  object :thing do

    @doc "The ID of the thing"
    field :id, non_null(:string)

    @doc "The name of the thing"
    field :name, :string

    @doc "The value of the thing"
    field :value, :integer

    field :other_thing,
      type: :thing,
      resolve: fn (_, %{source: %{id: id}}) ->
        case id do
          "foo" -> {:ok, @db |> Map.get("bar")}
          "bar" -> {:ok, @db |> Map.get("foo")}
        end
      end

  end

end
