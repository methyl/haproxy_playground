export type State = {
  config: string
}

export type Actions = {

}

export type ActionName = keyof Actions

export type Action = <T extends ActionName>(
  action: T,
  params: Actions[T]
) => Promise<null>
