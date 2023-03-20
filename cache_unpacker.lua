local filesystem = atmosphere.Require( 'filesystem' )
atmosphere.Require( 'server' )

Plugin.Name = 'Cache Unpacker'
Plugin.Author = 'PrikolMen:-b'

local workFolder = 'cache_unpacked/'
if not filesystem.IsDir( workFolder ) then
    filesystem.Delete( workFolder )
    filesystem.CreateDir( workFolder )
end

local stopWatch = nil
hook.Add( 'LoadingStarted', Plugin.Name, function()
    stopWatch = os.time()
end )

local activeFolder = nil
hook.Add( 'GameDetails', Plugin.Name, function( serverName )
    activeFolder = workFolder .. string.Trim( string.gsub( serverName, '[%c%p%s]+', '_' ) )
    if filesystem.Exists( activeFolder ) then return end
    filesystem.CreateDir( activeFolder )
end )

local cacheFolder = 'cache/lua/'
local skipLenght = 4 * 8

local function saveResults()
    if not stopWatch then return end
    if not activeFolder then return end

    local files, _ = filesystem.Find( cacheFolder .. '*', 'GAME' )
    for _, fileName in ipairs( files ) do
        local filePath = cacheFolder .. fileName
        if ( filesystem.Time( filePath, 'GAME' ) >= stopWatch ) then
            local fileClass = filesystem.Open( filePath, 'rb', 'GAME' )
            if not fileClass then continue end
            fileClass:Skip( skipLenght )
            local content = fileClass:Read( fileClass:Size() )
            fileClass:Close()

            if not content then continue end
            local luaCode = util.Decompress( content )
            if not luaCode then continue end

            filesystem.AsyncWrite( activeFolder .. '/' .. fileName, string.sub( luaCode, 1, #luaCode - 1 ) )
        end
    end
end

hook.Add( 'ClientConnected', Plugin.Name, saveResults )
hook.Add( 'ClientDisconnected', Plugin.Name, function()
    saveResults()
    activeFolder = nil
    stopWatch = nil
end )
