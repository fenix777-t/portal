Rails.application.routes.draw do
	root "requests#index"
	get "/list", to: "requests#list"
	post "/list", to: "requests#list"
	get "/erase", to: "requests#erase"
	get "/list/:id", to: "requests#show"
	post "/upload_xsd", to: "requests#upload_xsd"
	
	get "/types", to: "requests#types"
	get "/types/:id", to: "requests#tshow"
	
	get "/params", to: "requests#plist"
	
end
