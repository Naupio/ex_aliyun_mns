defmodule ExAliyun.MNS do
  @moduledoc """
  [Alibaba Cloud Message Service](https://www.alibabacloud.com/help/doc-detail/27414.htm)

  ## for Queue APIs

    * `create_queue/2`
    * `set_queue_attributes/2`
    * `get_queue_attributes/2`
    * `list_queues/1`
    * `delete_queue/2`
    * `send_message/3`
    * `batch_send_message/2`
    * `batch_delete_message/3`
    * `receive_message/2`
    * `peek_message/2`
    * `change_message_visibility/4`
  
  ## for Topic APIs
  
    * `create_topic/2`
    * `set_topic_attributes/2`
    * `get_topic_attributes/1`
    * `delete_topic/1`
    * `list_topics/1`
    * `subscribe/4`
    * `set_subscription_attributes/4`
    * `get_subscription_attributes/3`
    * `unsubscribe/3`
    * `list_subscriptions/2`
    * `publish_topic_message/3`
  """

  alias ExAliyun.MNS.{Topic, Queue, Client, Config}

  defmodule Operation do
    @moduledoc false
    defstruct [
      :params,
      :action,
      :headers
    ]
  end

  @type result :: {:ok, map()} | {:error, map()} | {:error, term()}

  @doc """

  `config_overrides` options:

    * `access_key_id`;
    * `access_key_secret`;
    * `host`, for example: "https://xxxx.mns.us-east-1.aliyuncs.com"
  """
  @spec request(operation :: Operation.t(), config_overrides :: Keyword.t()) :: result
  def request(operation, config_overrides \\ []) do
    Client.request(operation, Config.new(config_overrides))
  end

  @doc """
  Create a new message queue, the message queue name should be no more than 256 characters, and constituted by letters, digits, or hyphens (-), while the first character must be a letter.

  [Alibaba Cloud API Docs](https://www.alibabacloud.com/help/doc-detail/35129.htm)

  ## Options

    * `:delay_seconds`, optional, default is 0;
    * `:maximum_message_size`, optional, default is 65536 (64 KB);
    * `:message_retention_period`, optional, default is 604_800 (7 days);
    * `:visibility_timeout`, optional, valid value range in 1..43200 (12 hours), by default is 30 seconds;
    * `:polling_wait_seconds`, optional, default is 0;
    * `:logging_enabled`, optional, default is false.

  """
  @spec create_queue(queue_name :: String.t(), opts :: Keyword.t()) :: result
  def create_queue(queue_name, opts \\ []) do
    {config_overrides, opts} = Keyword.pop(opts, :config_overrides, [])
    Queue.create(queue_name, opts) |> request(config_overrides)
  end

  @spec set_queue_attributes(queue_url :: String.t(), opts :: Keyword.t()) :: result
  def set_queue_attributes(queue_url, opts \\ []) do
    {config_overrides, opts} = Keyword.pop(opts, :config_overrides, [])
    Queue.set_queue_attributes(queue_url, opts) |> request(config_overrides)
  end

  @spec get_queue_attributes(queue_url :: String.t(), opts :: Keyword.t()) :: result
  def get_queue_attributes(queue_url, opts \\ []) do
    config_overrides = Keyword.get(opts, :config_overrides, [])
    Queue.get_queue_attributes(queue_url) |> request(config_overrides)
  end

  @doc """

  ## Options
  
    * `:queue_name_prefix`
    * `:number`
    * `:marker`
  """
  @spec list_queues(opts :: Keyword.t()) :: result 
  def list_queues(opts \\ []) do
    {config_overrides, opts} = Keyword.pop(opts, :config_overrides, [])
    Queue.list_queues(opts) |> request(config_overrides)
  end

  @spec delete_queue(queue_url :: String.t(), opts :: Keyword.t()) :: result
  def delete_queue(queue_url, opts \\ []) do
    config_overrides = Keyword.get(opts, :config_overrides, [])
    Queue.delete(queue_url) |> request(config_overrides)
  end

  @doc """
  Sand a message to MNS Queue

  [Alibaba Cloud API Docs](https://www.alibabacloud.com/help/doc-detail/35134.htm)

  ## Options
  
    * `:delay_seconds`
    * `:priority`

  """
  @spec send_message(queue_url :: String.t(), message_body :: String.t(), opts :: Keyword.t()) :: result
  def send_message(queue_url, message_body, opts \\ []) do
    {config_overrides, opts} = Keyword.pop(opts, :config_overrides, [])
    Queue.send_message(queue_url, message_body, opts) |> request(config_overrides)
  end

  @type mns_batch_message :: String.t() | [
      {:message_body, String.t()},
      {:delay_seconds, 0..604800},
      {:priority, 1..16}
    ]

  @doc """
  Send up to 16 messages to a MNS Queue in a single request

  [Aliyun API Docs](https://help.aliyun.com/document_detail/35135.html)
  """
  @spec batch_send_message(queue_url :: String.t(), messages :: [mns_batch_message]) :: result
  def batch_send_message(queue_url, messages, opts \\ []) when is_list(messages) do
    config_overrides = Keyword.get(opts, :config_overrides, [])
    Queue.batch_send_message(queue_url, messages) |> request(config_overrides)
  end

  @doc """
  Delete a message from a MNS Queue

  [Aliyun API Docs](https://help.aliyun.com/document_detail/35138.html)
  """
  @spec delete_message(queue_url :: String.t(), receipt_handle :: String.t(), opts :: Keyword.t()) :: result
  def delete_message(queue_url, receipt_handle, opts \\ []) do
    config_overrides = Keyword.get(opts, :config_overrides, [])
    Queue.delete_message(queue_url, receipt_handle) |> request(config_overrides)
  end

  @doc """
  Delete a list of messages from a MNS Queue in a single request

  [Aliyun API Docs](https://help.aliyun.com/document_detail/35139.html)
  """
  @spec batch_delete_message(queue_url :: String.t(), receipt_handles :: [String.t()], opts :: Keyword.t()) :: result
  def batch_delete_message(queue_url, receipt_handles, opts \\ []) do
    config_overrides = Keyword.get(opts, :config_overrides, [])
    Queue.batch_delete_message(queue_url, receipt_handles) |> request(config_overrides)
  end

  @doc """
  Read message(s) from a MNS Queue

  [Aliyun API Docs](https://help.aliyun.com/document_detail/35136.html)

  ## Options

    * `:wait_time_seconds`, optional, the maximum wait time for polling message in current request, settable value range is 0..30 (seconds),
    if not set will use Queue's `polling_wait_seconds` attribute (see `create_queue`) as default.
    * `:number`, optional, receive up to 16 messages ([doc](https://help.aliyun.com/document_detail/35137.html)) from a MNS Queue in a single request, by default as 1.
  """
  @spec receive_message(queue_url :: String.t(), opts :: Keyword.t()) :: result
  def receive_message(queue_url, opts \\ []) do
    {config_overrides, opts} = Keyword.pop(opts, :config_overrides, [])
    Queue.receive_message(queue_url, opts) |> request(config_overrides)
  end

  @doc """
  View message(s) from a MNS Queue but do not change message(s) status.

  [Aliyun API Docs](https://help.aliyun.com/document_detail/35140.html)

  ## Options
  
    * `:number`, optional, maximum number of messages can be viewed for the current operation ([see BatchPeekMessage doc](https://www.alibabacloud.com/help/doc-detail/35141.htm)), the default number is 1, the maximum number is 16.
  """
  @spec peek_message(queue_url :: String.t(), opts :: Keyword.t()) :: result
  def peek_message(queue_url, opts \\ [number: nil]) do
    {config_overrides, opts} = Keyword.pop(opts, :config_overrides, [])
    Queue.peek_message(queue_url, opts) |> request(config_overrides)
  end

  @doc """
  Modify the next consumable time of a message which has been consumed and is still in `inactive` status. After `VisibilityTimeout` of the message is modified successfully, a new ReceiptHandle will be returned.

  [Aliyun API Docs](https://www.alibabacloud.com/help/doc-detail/35142.htm)
  """
  @spec change_message_visibility(queue_url :: String.t(), receipt_handle :: String.t(), visibility_timeout :: integer(), opts :: Keyword.t()) :: result
  def change_message_visibility(queue_url, receipt_handle, visibility_timeout, opts \\ []) do
    config_overrides = Keyword.get(opts, :config_overrides, [])
    Queue.change_message_visibility(queue_url, receipt_handle, visibility_timeout) |> request(config_overrides)
  end


  @doc """
  Create a new topic, a topic name is a string of no more than 256 characters, including letters, numbers, and hyphens (-). It must start with a letter or number.

  [Alibaba Cloud API Docs](https://www.alibabacloud.com/help/doc-detail/27495.htm)

  ## Options

    * `:maximum_message_size`, optional, default is 65536 (64 KB);
    * `:logging_enabled`, optional, default is false
    * `:config_overrides`, optional, see `request/2` for details
  """
  @spec create_topic(topic_name :: String.t(), opts :: Keyword.t()) :: result
  def create_topic(topic_name, opts \\ []) do
    {config_overrides, opts} = Keyword.pop(opts, :config_overrides, [])
    Topic.create(topic_name, opts) |> request(config_overrides)
  end

  @doc """
  Modify the attributes of an existing topic.

  [Alibaba Cloud API Docs](https://www.alibabacloud.com/help/doc-detail/140704.htm)

  ## Options

    * `:maximum_message_size`, optional;
    * `:logging_enabled`, optional;
    * `:config_overrides`, optional, see `request/2` for details;
  """
  @spec set_topic_attributes(topic_url :: String.t(), opts :: Keyword.t()) :: result
  def set_topic_attributes(topic_url, opts) do
    {config_overrides, opts} = Keyword.pop(opts, :config_overrides, [])

    Topic.set_topic_attributes(topic_url, opts) |> request(config_overrides)
  end

  @doc """
  Get the attributes of an existing topic.

  [Alibaba Cloud API Docs](https://www.alibabacloud.com/help/doc-detail/140711.htm)
  """
  @spec get_topic_attributes(topic_url :: String.t()) :: result
  def get_topic_attributes(topic_url, opts \\ []) do
    config_overrides = Keyword.get(opts, :config_overrides, [])

    Topic.get_topic_attributes(topic_url) |> request(config_overrides)
  end

  @doc """
  Delete an existing topic.

  [Alibaba Cloud API Docs](https://www.alibabacloud.com/help/doc-detail/140713.htm)
  """
  @spec delete_topic(topic_url :: String.t()) :: result
  def delete_topic(topic_url, opts \\ []) do
    config_overrides = Keyword.get(opts, :config_overrides, [])

    Topic.delete(topic_url) |> request(config_overrides)
  end

  @doc """
  List the topics of an account.

  [Alibaba Cloud API Docs](https://www.alibabacloud.com/help/doc-detail/140714.htm)

  ## Options

    * `:topic_name_prefix`
    * `:number`
    * `:marker`
  """
  @spec list_topics(opts :: Keyword.t()) :: result
  def list_topics(opts \\ []) do
    {config_overrides, opts} = Keyword.pop(opts, :config_overrides, [])
    Topic.list_topics(opts) |> request(config_overrides)
  end

  @doc """
  Create a subscription to a topic.

  [Alibaba Cloud API Docs](https://www.alibabacloud.com/help/doc-detail/27496.htm)

  ## Options

    * `:filter_tag`, optional, a string no more than 16 characters, there is no message filter set by default;
    * `:notify_strategy`, optional, `"BACKOFF_RETRY"` or `"EXPONENTIAL_DECAY_RETRY"`, as `"BACKOFF_RETRY"` by default;
    * `:notify_content_format`, optional, `"XML"`, `"JSON"`, or `"SIMPLIFIED"`, as `"XML"` by default
  """
  @spec subscribe(
          topic_url :: String.t(),
          subscription_name :: String.t(),
          endpoint :: String.t(),
          opts :: Keyword.t()
        ) :: result
  def subscribe(topic_url, subscription_name, endpoint, opts \\ []) do
    {config_overrides, opts} = Keyword.pop(opts, :config_overrides, [])
    Topic.subscribe(topic_url, subscription_name, endpoint, opts) |> request(config_overrides)
  end

  @doc """
  Modify `notify_strategy` of subscription attribute, the value of `notify_strategy`
  can be set as `"BACKOFF_RETRY"` or `"EXPONENTIAL_DECAY_RETRY"`

  [Alibaba Cloud API Docs](https://www.alibabacloud.com/help/doc-detail/140719.htm)
  """
  @spec set_subscription_attributes(
          topic_url :: String.t(),
          subscription_name :: String.t(),
          notify_strategy :: String.t(),
          opts :: Keyword.t()
        ) :: result
  def set_subscription_attributes(topic_url, subscription_name, notify_strategy, opts \\ []) do
    config_overrides = Keyword.get(opts, :config_overrides, [])

    topic_url
    |> Topic.set_subscription_attributes(subscription_name, notify_strategy)
    |> request(config_overrides)
  end

  @doc """
  Get subscription attributes

  [Alibaba Cloud API Docs](https://www.alibabacloud.com/help/doc-detail/140720.htm)
  """
  @spec get_subscription_attributes(topic_url :: String.t(), subscription_name :: String.t(), opts :: Keyword.t()) :: result
  def get_subscription_attributes(topic_url, subscription_name, opts \\ []) do
    config_overrides = Keyword.get(opts, :config_overrides, [])

    topic_url
    |> Topic.get_subscription_attributes(subscription_name)
    |> request(config_overrides)
  end

  @doc """
  Cancel a subscription.

  [Alibaba Cloud API Docs](https://www.alibabacloud.com/help/doc-detail/140721.htm)
  """
  @spec unsubscribe(topic_url :: String.t(), subscription_name :: String.t(), opts :: Keyword.t()) :: result
  def unsubscribe(topic_url, subscription_name, opts \\ []) do
    config_overrides = Keyword.get(opts, :config_overrides, [])

    Topic.unsubscribe(topic_url, subscription_name) |> request(config_overrides)
  end

  @doc """
  List the subscriptions to a topic, support pagination query.

  [Alibaba Cloud API Docs](https://www.alibabacloud.com/help/doc-detail/140718.htm)

  ## Options
  
    * `:subscription_name_prefix`, optional
    * `:number`, optional
    * `:marker`, optional
  """
  @spec list_subscriptions(topic_url :: String.t(), opts :: Keyword.t()) :: result
  def list_subscriptions(topic_url, opts \\ []) do
    {config_overrides, opts} = Keyword.pop(opts, :config_overrides, [])

    Topic.list_subscriptions(topic_url, opts) |> request(config_overrides)
  end

  @doc """
  Publish a message to a specified topic, the message is pushed to endpoints for consumption.

  [Alibaba Cloud API Docs](https://www.alibabacloud.com/help/doc-detail/27497.htm)

  ## Options
  
    * `:message_tag`, optional, a string no more than 16 characters, there is no message tag set by default;
    * `:message_attributes`, optional, a string of message attributes, only be useable for email or SMS push, please see API documents for details.
  """
  @spec publish_topic_message(topic_url :: String.t(), message_body :: String.t(), opts :: Keyword.t()) :: result
  def publish_topic_message(topic_url, message_body, opts \\ []) do
    {config_overrides, opts} = Keyword.pop(opts, :config_overrides, [])

    Topic.publish_message(topic_url, message_body, opts) |> request(config_overrides)
  end

  @doc false
  def format_opts_to_headers(opts) do
    Enum.reduce(opts, [], fn({key, value}, acc) ->
      header = format_header(key, value)
      if header != nil, do: [header | acc], else: acc
    end)
  end

  @doc false
  defp format_header(:topic_name_prefix, value) do
    {"x-mns-prefix", "#{value}"}
  end
  defp format_header(:queue_name_prefix, value) do
    {"x-mns-prefix", "#{value}"}
  end
  defp format_header(:subscription_name_prefix, value) do
    {"x-mns-prefix", "#{value}"}
  end
  defp format_header(:number, value) do
    {"x-mns-ret-number", "#{value}"}
  end
  defp format_header(:marker, value) do
    {"x-mns-marker", value}
  end
  defp format_header(_key, _value) do
    nil
  end

end
