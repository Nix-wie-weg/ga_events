Dummy::Application.routes.draw do
  root 'tests#test'

  get 'tests/test' => 'tests#test'
end
