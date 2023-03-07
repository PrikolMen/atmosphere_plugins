atmosphere.Require( 'logger' )
atmosphere.Require( 'utils' )

Plugin.Name = 'Shaders'
Plugin.Author = 'PrikolMen:-b'
Plugin.BinaryName = 'egsm'

local logger = atmosphere.logger.Create( Plugin.Name, Color( 150, 150, 100 ) )

if not util.IsBinaryModuleInstalled( Plugin.BinaryName ) then
    logger:Error( 'Binary module not installed! [https://github.com/devonium/EGSM]' )
    return
end

if not pcall( require, Plugin.BinaryName ) then
    logger:Error( 'Installation of the binary module failed!' )
    return
end

logger:Info( 'Initialised successfully.' )
