require('hs.ipc')
require('hs.mouse')

PaperWM = hs.loadSpoon("PaperWM")
PaperWM:bindHotkeys({
  -- switch to a new focused window in tiled grid
  focus_left     = { { "ctrl", "alt", "cmd" }, "left" },
  focus_right    = { { "ctrl", "alt", "cmd" }, "right" },
  focus_up       = { { "ctrl", "alt", "cmd" }, "up" },
  focus_down     = { { "ctrl", "alt", "cmd" }, "down" },

  -- move windows around in tiled grid
  swap_left      = { { "ctrl", "alt", "cmd", "shift" }, "h" },
  swap_right     = { { "ctrl", "alt", "cmd", "shift" }, "l" },
  swap_up        = { { "ctrl", "alt", "cmd", "shift" }, "up" },
  swap_down      = { { "ctrl", "alt", "cmd", "shift" }, "down" },

  -- position and resize focused window
  center_window  = { { "ctrl", "alt", "cmd", "shift" }, "c" },
  full_width     = { { "ctrl", "alt", "cmd" }, "f" },
  cycle_width    = { { "ctrl", "alt", "cmd" }, "r" },
  cycle_height   = { { "ctrl", "alt", "cmd", "shift" }, "r" },

  -- move focused window into / out of a column
  slurp_in       = { { "ctrl", "alt", "cmd", "shift" }, "s" },
  barf_out       = { { "ctrl", "alt", "cmd", "shift" }, "b" },

  -- switch to a new Mission Control space
  switch_space_1 = { { "ctrl", "alt", "cmd" }, "1" },
  switch_space_2 = { { "ctrl", "alt", "cmd" }, "2" },
  switch_space_3 = { { "ctrl", "alt", "cmd" }, "3" },
  switch_space_4 = { { "ctrl", "alt", "cmd" }, "4" },
  switch_space_5 = { { "ctrl", "alt", "cmd" }, "5" },
  switch_space_6 = { { "ctrl", "alt", "cmd" }, "6" },
  switch_space_7 = { { "ctrl", "alt", "cmd" }, "7" },
  switch_space_8 = { { "ctrl", "alt", "cmd" }, "8" },
  switch_space_9 = { { "ctrl", "alt", "cmd" }, "9" },

  -- move focused window to a new space and tile
  move_window_1  = { { "ctrl", "alt", "cmd", "shift" }, "1" },
  move_window_2  = { { "ctrl", "alt", "cmd", "shift" }, "2" },
  move_window_3  = { { "ctrl", "alt", "cmd", "shift" }, "3" },
  move_window_4  = { { "ctrl", "alt", "cmd", "shift" }, "4" },
  move_window_5  = { { "ctrl", "alt", "cmd", "shift" }, "5" },
  move_window_6  = { { "ctrl", "alt", "cmd", "shift" }, "6" },
  move_window_7  = { { "ctrl", "alt", "cmd", "shift" }, "7" },
  move_window_8  = { { "ctrl", "alt", "cmd", "shift" }, "8" },
  move_window_9  = { { "ctrl", "alt", "cmd", "shift" }, "9" }
})

PaperWM.window_filter = PaperWM.window_filter:setAppFilter("Electron", false)

PaperWM:start()

hs.mouse.getCurrentScreen()

local function shiftTilingBy(value)
  local screen = hs.mouse.getCurrentScreen()

  if screen == nil then
    return
  end

  local space = hs.spaces.activeSpaceOnScreen(screen)

  PaperWM:shiftSpace(space, value)
end

local shiftAmount = 0

local function shiftThrottled(value)
  shiftAmount = shiftAmount + value
  if not ShiftTimer:running() then
    ShiftTimer:start()
  end
end

ShiftTimer = hs.timer.doEvery(0.016, function()
  if shiftAmount ~= 0 then
    shiftTilingBy(shiftAmount)
    ShiftTimer:stop()
    shiftAmount = 0
  end
end)

ShiftTimer:start()


local touchPrev = {}

local function averageOfTable(table)
  local sum = 0

  for _, value in ipairs(table) do
    sum = sum + value
  end

  return sum / #table
end

local function maxOfTable(table)
  local max = nil
  for _, value in ipairs(table) do
    if max == nil or value > max then
      max = value
    end
  end
  return max
end

SwipeGestureTap = hs.eventtap.new({ hs.eventtap.event.types.gesture }, function(event)
  local touches = event:getTouches()

  -- matching a three finger gesture
  if #touches == 3 then
    local deltas = {}

    -- get the touches that have a previous value, add the delta to deltas
    for _, touch in ipairs(touches) do
      -- your code her
      local prev = touchPrev[touch.identity]
      local current = touch.normalizedPosition

      if prev ~= nil then
        local deltaX = current.x - prev.x

        table.insert(deltas, deltaX)
      end

      touchPrev[touch.identity] = touch.normalizedPosition
    end

    -- make sure we have three deltas
    if #deltas ~= 3 then
      return
    end

    -- If one of the touches has 30% the movement of the maxDelta, we
    -- won't consider this three-finger swipe (the touches aren't 
    -- moving at the same speed)
    local deltaEquivalenceThreshold = 0.3
    local maxDelta = maxOfTable(deltas)

    for _, delta in ipairs(deltas) do
      if (delta / maxDelta) < deltaEquivalenceThreshold then
        return
      end
    end

    -- shift the windows the average delta
    shiftThrottled(averageOfTable(deltas) * 3000)
  else
    touchPrev = {}
  end
end)

SwipeGestureTap:start()



--print(task:waitUntilExit())


-- hs.window.animationDuration = 0

-- function alignWindows ()
--   local mouseScreen = hs.mouse.getCurrentScreen()
--   local screenFrame = mouseScreen:frame()

--   local focusedWindow = hs.window.focusedWindow()

--   if focusedWindow == nil then
--     focusedWindow = hs.window.allWindows()[0]
--   end

--   if focusedWindow == nil then
--     return
--   end

--   local xBeforeFocused = 0
--   for _, window in ipairs(hs.window.allWindows()) do
--     if window == focusedWindow then
--       break
--     end

--     xBeforeFocused = xBeforeFocused + win dow:size().w
--   end


--   local lastWindowX = focusedWindow:topLeft().x - xBeforeFocused

--   hs.fnutils.each(hs.window.allWindows(), function(window)
--     local windowSize = window:size()
--     local position = window:topLeft()

--     if window ~= focusedWindow then
--       window:setTopLeft(hs.geometry.point(lastWindowX, screenFrame.y))
--       window:setSize(hs.geometry.size(windowSize.w, screenFrame.h))
--     end

--     lastWindowX = lastWindowX + windowSize.w
--   end)
-- end

-- alignWindows()


-- -- local touchdevice = require("hs._asm.undocumented.touchdevice")
-- -- touchdevice.watcher.new(function(...)
-- --   for _, v in ipairs(touchdevice.devices()) do
-- --     touchdevice.forDeviceID(v):frameCallback(function(_, touches, _, _)
-- --       local nFingers = #touches

-- --       print(nFingers)

-- --       if nFingers == 3 then
-- --         print(nFingers)
-- --       end
-- --     end):start()
-- --   end
-- -- end):start()

-- local events = hs.uielement.watcher

-- watchers = {}

-- function init()
--   appsWatcher = hs.application.watcher.new(handleGlobalAppEvent)
--   appsWatcher:start()

--   -- Watch any apps that already exist
--   local apps = hs.application.runningApplications()
--   for i = 1, #apps do
--     if apps[i]:title() ~= "Hammerspoon" then
--       watchApp(apps[i], true)
--     end
--   end
-- end

-- function handleGlobalAppEvent(name, event, app)
--   if     event == hs.application.watcher.launched then
--     watchApp(app)
--   elseif event == hs.application.watcher.terminated then
--     -- Clean up
--     local appWatcher = watchers[app:pid()]
--     if appWatcher then
--       appWatcher.watcher:stop()
--       for id, watcher in pairs(appWatcher.windows) do
--         watcher:stop()
--       end
--       watchers[app:pid()] = nil
--     end
--   end
-- end

-- function watchApp(app, initializing)
--   if watchers[app:pid()] then return end

--   local watcher = app:newWatcher(handleAppEvent)
--   watchers[app:pid()] = {watcher = watcher, windows = {}}

--   watcher:start({events.windowCreated, events.focusedWindowChanged})

--   -- Watch any windows that already exist
--   for i, window in pairs(app:allWindows()) do
--     watchWindow(window, initializing)
--   end
-- end

-- function handleAppEvent(element, event)
--   if event == events.windowCreated then
--     watchWindow(element)
--   elseif event == events.focusedWindowChanged then
--     -- Handle window change
--   end
-- end

-- function watchWindow(win, initializing)
--   local appWindows = watchers[win:application():pid()].windows
--   if win:isStandard() and not appWindows[win:id()] then
--     local watcher = win:newWatcher(handleWindowEvent, {pid=win:pid(), id=win:id()})
--     appWindows[win:id()] = watcher

--     watcher:start({events.elementDestroyed, events.windowResized, events.windowMoved})

--     if not initializing then
--       --hs.alert.show('window created: '..win:id()..' with title: '..win:title())
--     end
--   end
-- end

-- function handleWindowEvent(win, event, watcher, info)
--   if event == events.elementDestroyed then
--     watcher:stop()
--     watchers[info.pid].windows[info.id] = nil
--   end

--   alignWindows()

--   --hs.alert.show('window event '..event..' on '..info.id)
-- end

-- init()
