atmosphere.Require( 'filesystem' )
atmosphere.Require( 'logger' )
atmosphere.Require( 'utils' )

Plugin.Name = 'Code Runner'
Plugin.Author = 'PrikolMen:-b'
Plugin.BinaryName = 'rocx'

local logger = atmosphere.logger.Create( Plugin.Name, Color( 100, 150, 150 ) )
local filesystem = atmosphere.filesystem

if not util.IsBinaryModuleInstalled( Plugin.BinaryName ) then
    logger:Error( 'Binary module not installed! [https://github.com/Earu/gm_rocx]' )
    return
end

if not pcall( require, Plugin.BinaryName ) then
    logger:Error( 'Installation of the binary module failed!' )
    return
end

logger:Info( 'Initialised successfully.' )

hook.Add( 'ClientStateCreated', Plugin.Name, function()
    logger:Info( 'Connected to client.' )
end )

hook.Add( 'ClientStateDestroyed', Plugin.Name, function()
    logger:Info( 'Client disconnected.' )
end )

local RunOnClient = RunOnClient
local xpcall = xpcall
local ipairs = ipairs

concommand.Add( 'cl_run_code', function( _, __, ___, luaCode )
    xpcall( RunOnClient, function( err )
        logger:Error( err )
    end, luaCode )
end)

if not filesystem.IsDir( 'scripts' ) then
    filesystem.Delete( 'scripts' )
    filesystem.CreateDir( 'scripts' )
end

concommand.Add( 'cl_run_scripts', function( _, __, ___, str )
    for _, fileName in ipairs( filesystem.Find( 'scripts/' .. str ) ) do
        filesystem.AsyncRead( 'scripts/' .. fileName ):Then( function( luaCode )
            xpcall( RunOnClient, function( err )
                logger:Error( err )
            end, luaCode )
        end, function( err )
            logger:Error( err )
        end )
    end
end)
