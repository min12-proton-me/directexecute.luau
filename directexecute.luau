
--// Configuration
local UpdateInterval = 7
local APIUrl = "http://localhost:3001/api/directexecute"
local ScriptUrl = "http://localhost:3001/api/script-download?id="

--// Executor compatability
cloneref = cloneref or function(...) return ... end

--// Services
local HttpService = cloneref(game:GetService("HttpService"))

local function ExecuteScript(Id)
    local Url = ScriptUrl .. Id
    local Closure = loadstring(game:HttpGet(Url))

    --// Syntax check
    if not Closure then return end

    task.defer(Closure)
end

local function ExecuteScriptQueue(Queue)

    for _, ScriptId in next, Queue do
        pcall(ExecuteScript, ScriptId) -- TODO Error handling?
    end
end

local function FetchScriptsQueue()
    local Queue = request({
        Url = APIUrl,
        Method = "GET",
        Headers = {
            ["mzdx_token"] = MZSCRIPTS_TOKEN
        }
    })

    --// Error handling
    if not Queue.Success then return end
    if Queue.StatusCode ~= 200 then return end 

    local JSONBody = HttpService:JSONDecode(Queue.Body)
    return JSONBody.queue -- { "queue": [ScriptID: string] }
end

--// Execute loop
task.spawn(function()
    while task.wait(UpdateInterval) do
        local Queue = FetchScriptsQueue()
        ExecuteScriptQueue(Queue)
    end
end)