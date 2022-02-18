import React from 'react'
import Message, { MessageData } from './message'
import MessageForm from './message-form';

type Props = {};
type Messages = {
  messages: Array<MessageData>
}

class MessageList extends React.Component<Props, Messages> {
  constructor(props: Props) {
    super(props)
    this.state = {
      messages: []
    }
    this.getMessages()
    this.onClick = this.onClick.bind(this);
  }

  getMessages() {
    const req = (): Promise<Array<MessageData>> => fetch("/api/messages").then((x) => x.json());
    req().then(data => data.forEach(m => this.addMessage(m)))
  }

  addMessage(m: MessageData) {
    console.log(m);
    let newMessages = this.state.messages.concat();
    newMessages.push(m);
    this.setState({
      messages: newMessages
    })
  }

  onClick(content: string) {
    let options = {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ content: content })
    }

    const req = (): Promise<MessageData> => fetch("/api/messages", options).then((x) => x.json());
    req().then(m => this.addMessage(m))
  }

  render() {
    return (
      <div className="content">
        <div className="message-list">
          {this.state.messages.map((msg: MessageData) => (
            (new Message(msg)).render()
          ))}
        </div>

        <MessageForm onClick={this.onClick} />
      </div>
    )
  }
}

export default MessageList;
