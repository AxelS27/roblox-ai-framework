--!strict
--[=[
    @class Registry
    @shared
    Central database for all instantiated Services, Controllers, and Components.
    Enables dynamic runtime resolution of modules without direct requiring,
    avoiding circular dependency lockups.
]=]
local Registry = {}

local _services: { [string]: any } = {}
local _controllers: { [string]: any } = {}
local _components: { [string]: any } = {}

-- Service APIs
function Registry:RegisterService(service: any)
    if typeof(service) == "table" and typeof(service.Name) == "string" then
        _services[service.Name] = service
    end
end

function Registry:GetService(name: string): any
    local service = _services[name]
    if not service then
        error(string.format("Service '%s' is not registered", name), 2)
    end
    return service
end

-- Controller APIs
function Registry:RegisterController(controller: any)
    if typeof(controller) == "table" and typeof(controller.Name) == "string" then
        _controllers[controller.Name] = controller
    end
end

function Registry:GetController(name: string): any
    local controller = _controllers[name]
    if not controller then
        error(string.format("Controller '%s' is not registered", name), 2)
    end
    return controller
end

-- Component APIs
function Registry:RegisterComponent(component: any, componentName: string)
    assert(typeof(component) == "table", "Component must be a table")
    _components[componentName] = component
end

function Registry:GetComponent(name: string): any
    local component = _components[name]
    if not component then
        error(string.format("Component '%s' is not registered", name), 2)
    end
    return component
end

return Registry
