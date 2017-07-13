require 'paths'
paths.dofile('util.lua')
paths.dofile('img.lua')

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

set = arg[1]

if set == 'demo' then
    a = loadAnnotations('valid')
    idxs = torch.range(29369,30944)	-- frames corresponding to Posing_1 
    set = 'valid'
else
    a = loadAnnotations(set)
    idxs = torch.range(1,a.nsamples)
end

m = torch.load('umich-stacked-hourglass.t7')   -- Load pre-trained model
m:evaluate()
m:cuda()

nsamples = idxs:nElement() 
-- Displays a convenient progress bar
xlua.progress(0,nsamples)
predHMs = torch.Tensor(1,16,64,64)

os.execute('mkdir -p preds')

--------------------------------------------------------------------------------
-- Main loop
--------------------------------------------------------------------------------

for i = 1,nsamples do
    -- Set up input image
    local im = image.load('images/' .. a['images'][idxs[i]])
    local center = a['center'][idxs[i]]
    local scale = a['scale'][idxs[i]]
    local inp = crop(im, center, scale, 0, 256)

    -- Get network output
    local out = m:forward(inp:view(1,3,256,256):cuda())
    out = applyFn(function (x) return x:clone() end, out[#out])
    local flippedOut = m:forward(flip(inp:view(1,3,256,256):cuda()))
    flippedOut = applyFn(function (x) return flip(shuffleLR(x)) end, flippedOut[#flippedOut])
    out = applyFn(function (x,y) return x:add(y):div(2) end, out, flippedOut)
    cutorch.synchronize()

    predHMs:copy(out)

    local predFile = hdf5.open('preds/' .. set .. '_' .. idxs[i] .. '.h5', 'w')
    predFile:write('heatmaps', predHMs)
    predFile:close()

    xlua.progress(i,nsamples)

    collectgarbage()
end

