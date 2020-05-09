export type State = {
  who: string
}

export type Actions = {
  hello: {
  who: string
}
}

export type ActionName = keyof Actions

export type Action = <T extends ActionName>(
  action: T,
  params: Actions[T]
) => Promise<null>
