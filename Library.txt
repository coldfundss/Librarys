-- ╔══════════════════════════════════════════════════════════════════╗
-- ║                  PuppyUI  ·  Library.lua  ·  v3.0              ║
-- ║         Pixel-perfect Lua port of the HTML/CSS design          ║
-- ╚══════════════════════════════════════════════════════════════════╝
--
--  USAGE:
--    local Library = loadstring(game:HttpGet("YOUR_RAW_URL"))()
--    local UI      = Library.new("my ui", "v1.0")
--    local tab     = UI:AddTab("main")
--    local sec     = UI:AddSection(tab, "general")
--    sec:AddToggle("my toggle", false, function(v) end)
--    UI:Notify("hello", "world", 2.5)

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local LocalPlayer      = Players.LocalPlayer

-- ── Theme  (:root CSS variables) ──────────────────────────────────
local T = {
    bg       = Color3.fromHex("0f0f13"),
    surface  = Color3.fromHex("18181f"),
    surface2 = Color3.fromHex("1e1e27"),
    surface3 = Color3.fromHex("252530"),
    border   = Color3.fromHex("2a2a38"),
    accent   = Color3.fromHex("7c5cbf"),
    accent2  = Color3.fromHex("9b7de0"),
    text     = Color3.fromHex("e2e2f0"),
    text2    = Color3.fromHex("8888a8"),
    text3    = Color3.fromHex("555570"),
}

-- ── Helpers ────────────────────────────────────────────────────────
local function tw(obj, props, t, es, ed)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.15, es or Enum.EasingStyle.Quad, ed or Enum.EasingDirection.Out),
        props):Play()
end

local function new(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function rnd(r, p)   return new("UICorner",  {CornerRadius=UDim.new(0,r)}, p) end
local function brdr(c,t,p) return new("UIStroke",  {Color=c,Thickness=t or 1},  p) end
local function pdg(a,b,c,d,p)
    return new("UIPadding",{
        PaddingTop=UDim.new(0,a),PaddingBottom=UDim.new(0,b),
        PaddingLeft=UDim.new(0,c),PaddingRight=UDim.new(0,d)},p)
end
local function vlist(gap, p)
    return new("UIListLayout",{
        FillDirection=Enum.FillDirection.Vertical,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,gap or 0)},p)
end
local function hlist(gap, p)
    return new("UIListLayout",{
        FillDirection=Enum.FillDirection.Horizontal,
        VerticalAlignment=Enum.VerticalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,gap or 0)},p)
end

local function rowHover(f)
    f.MouseEnter:Connect(function()
        f.BackgroundTransparency = 0.98
        f.BackgroundColor3 = Color3.new(1,1,1)
    end)
    f.MouseLeave:Connect(function()
        f.BackgroundTransparency = 1
    end)
end

-- ══════════════════════════════════════════════════════════════════
-- LIBRARY
-- ══════════════════════════════════════════════════════════════════
local Library = {}
Library.__index = Library

function Library.new(title, version)
    local self = setmetatable({}, Library)
    self.Tabs      = {}
    self.ActiveTab = nil
    self.Visible   = true
    self._tq       = {}
    self._tbusy    = false
    self.Theme     = T

    -- ── ScreenGui ────────────────────────────────────────────────
    local ok, hui = pcall(gethui)
    local gui = new("ScreenGui",{
        Name="PuppyUI", ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=999,
    }, ok and hui or LocalPlayer:WaitForChild("PlayerGui"))
    self.Gui = gui

    -- ── Toggle button (#toggle-btn) ──────────────────────────────
    local toggleBtn = new("TextButton",{
        Name="ToggleBtn",
        Size=UDim2.new(0,100,0,28),
        Position=UDim2.new(0,16,0,16),
        BackgroundColor3=T.surface,
        Text="  ui library",
        TextColor3=T.text2,
        TextSize=11, Font=Enum.Font.Code,
        AutoButtonColor=false, ZIndex=500,
    }, gui)
    rnd(6,toggleBtn)
    local togS = brdr(T.border,1,toggleBtn)

    local togDot = new("Frame",{
        Size=UDim2.new(0,6,0,6),
        Position=UDim2.new(0,10,0.5,-3),
        BackgroundColor3=T.accent2, ZIndex=501,
    }, toggleBtn)
    rnd(999,togDot)

    toggleBtn.MouseEnter:Connect(function()
        tw(toggleBtn,{TextColor3=T.text},0.12)
        tw(togS,{Color=T.accent},0.12)
    end)
    toggleBtn.MouseLeave:Connect(function()
        tw(toggleBtn,{TextColor3=T.text2},0.12)
        tw(togS,{Color=T.border},0.12)
    end)
    toggleBtn.MouseButton1Click:Connect(function() self:Toggle() end)

    -- ── Window (#window) ─────────────────────────────────────────
    local win = new("Frame",{
        Name="Window",
        Size=UDim2.new(0,640,0,420),
        Position=UDim2.new(0.5,-320,0.5,-210),
        BackgroundColor3=T.surface,
        ClipsDescendants=true,
    }, gui)
    rnd(8,win); brdr(T.border,1,win)
    self.Window = win

    -- shadow
    local shadow = new("ImageLabel",{
        Size=UDim2.new(1,40,1,40),
        Position=UDim2.new(0,-20,0,-20),
        BackgroundTransparency=1,
        Image="rbxassetid://6014261993",
        ImageColor3=Color3.new(0,0,0),
        ImageTransparency=0.4,
        ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(49,49,450,450),
        ZIndex=0,
    }, win)

    if gui.AbsoluteSize.X < 500 then
        win.Size     = UDim2.new(0.97,0,0,400)
        win.Position = UDim2.new(0.015,0,0.5,-200)
    end

    vlist(0,win)

    -- ── Titlebar (.titlebar) ─────────────────────────────────────
    local tb = new("Frame",{
        Name="Titlebar", LayoutOrder=1,
        Size=UDim2.new(1,0,0,38),
        BackgroundColor3=T.surface2,
    }, win)
    brdr(T.border,1,tb)

    local tbL = new("Frame",{
        Size=UDim2.new(1,-50,1,0),
        BackgroundTransparency=1,
    }, tb)
    hlist(8,tbL); pdg(0,0,12,0,tbL)

    local tbDot = new("Frame",{
        Size=UDim2.new(0,7,0,7),
        BackgroundColor3=T.accent2,
    }, tbL)
    rnd(999,tbDot)

    new("TextLabel",{
        Size=UDim2.new(0,130,1,0),
        BackgroundTransparency=1,
        Text=title or "example ui",
        TextColor3=T.text,
        TextSize=11, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, tbL)

    new("TextLabel",{
        Size=UDim2.new(0,40,1,0),
        BackgroundTransparency=1,
        Text=version or "v1.0",
        TextColor3=T.text3,
        TextSize=9, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, tbL)

    -- .titlebar-close
    local closeBtn = new("TextButton",{
        Size=UDim2.new(0,18,0,18),
        Position=UDim2.new(1,-28,0.5,-9),
        BackgroundColor3=T.surface3,
        Text="✕", TextColor3=T.text3,
        TextSize=10, Font=Enum.Font.Code,
        AutoButtonColor=false,
    }, tb)
    rnd(3,closeBtn); brdr(T.border,1,closeBtn)

    closeBtn.MouseEnter:Connect(function()
        tw(closeBtn,{BackgroundColor3=Color3.fromHex("3a1a1a"),TextColor3=Color3.fromHex("ff6666")},0.1)
    end)
    closeBtn.MouseLeave:Connect(function()
        tw(closeBtn,{BackgroundColor3=T.surface3,TextColor3=T.text3},0.1)
    end)
    closeBtn.MouseButton1Click:Connect(function() self:Toggle() end)

    -- dragging
    local _drag,_ds,_dp = false,nil,nil
    tb.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            _drag=true; _ds=i.Position; _dp=win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if _drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-_ds
            win.Position=UDim2.new(_dp.X.Scale,_dp.X.Offset+d.X,_dp.Y.Scale,_dp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then _drag=false end
    end)

    -- ── Tabbar (.tabbar) ─────────────────────────────────────────
    local tabbar = new("Frame",{
        Name="Tabbar", LayoutOrder=2,
        Size=UDim2.new(1,0,0,30),
        BackgroundColor3=T.surface2,
        ClipsDescendants=true,
    }, win)
    brdr(T.border,1,tabbar)
    hlist(2,tabbar); pdg(0,0,8,8,tabbar)
    self.Tabbar = tabbar

    -- ── Content (.content) ───────────────────────────────────────
    local content = new("ScrollingFrame",{
        Name="Content", LayoutOrder=3,
        Size=UDim2.new(1,0,1,-68),
        BackgroundTransparency=1,
        ScrollBarThickness=3,
        ScrollBarImageColor3=T.surface3,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        BorderSizePixel=0,
    }, win)
    self.Content = content

    -- ── Toast (#toast) ────────────────────────────────────────────
    local toast = new("Frame",{
        Name="Toast",
        Size=UDim2.new(0,220,0,58),
        Position=UDim2.new(1,-236,1,-74),
        BackgroundColor3=T.surface2,
        BackgroundTransparency=1,
        Visible=false, ZIndex=900,
    }, gui)
    rnd(6,toast); brdr(T.border,1,toast)
    self.Toast = toast

    new("Frame",{
        Size=UDim2.new(0,3,1,0),
        BackgroundColor3=T.accent, ZIndex=901,
    }, toast)

    self._tTitle = new("TextLabel",{
        Size=UDim2.new(1,-14,0,16),
        Position=UDim2.new(0,12,0,10),
        BackgroundTransparency=1,
        Text="", TextColor3=T.accent2,
        TextSize=10, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=902,
    }, toast)

    self._tBody = new("TextLabel",{
        Size=UDim2.new(1,-14,0,14),
        Position=UDim2.new(0,12,0,30),
        BackgroundTransparency=1,
        Text="", TextColor3=T.text2,
        TextSize=10, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=902,
    }, toast)

    -- open animation
    win.Size = UDim2.new(0,640,0,0)
    tw(win,{Size=UDim2.new(0,640,0,420)},0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out)

    return self
end

-- ── Toggle window ─────────────────────────────────────────────────
function Library:Toggle()
    self.Visible = not self.Visible
    if self.Visible then
        self.Window.Visible = true
        tw(self.Window,{Size=UDim2.new(0,640,0,420)},0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    else
        tw(self.Window,{Size=UDim2.new(0,640,0,0)},0.15)
        task.delay(0.16,function() self.Window.Visible=false end)
    end
end

-- ── Toast ─────────────────────────────────────────────────────────
function Library:Notify(title, body, dur)
    table.insert(self._tq,{title=title,body=body,dur=dur or 2.5})
    if not self._tbusy then self:_nextToast() end
end

function Library:_nextToast()
    if #self._tq==0 then self._tbusy=false return end
    self._tbusy=true
    local it=table.remove(self._tq,1)
    self._tTitle.Text=it.title
    self._tBody.Text =it.body
    self.Toast.Visible=true
    self.Toast.Position=UDim2.new(1,-236,1,-66)
    tw(self.Toast,{BackgroundTransparency=0,Position=UDim2.new(1,-236,1,-74)},0.2)
    task.delay(it.dur,function()
        tw(self.Toast,{BackgroundTransparency=1,Position=UDim2.new(1,-236,1,-66)},0.2)
        task.wait(0.22); self.Toast.Visible=false
        self:_nextToast()
    end)
end

-- ── Add tab ───────────────────────────────────────────────────────
function Library:AddTab(name)
    local tab={Name=name}

    local page = new("Frame",{
        Name=name,
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Visible=false,
    }, self.Content)

    new("UIGridLayout",{
        CellPadding=UDim2.new(0,8,0,8),
        CellSize=UDim2.new(0.5,-12,0,1),
        AutomaticCellSize=Enum.AutomaticSize.Y,
        SortOrder=Enum.SortOrder.LayoutOrder,
        FillDirectionMaxCells=2,
    }, page)
    pdg(10,10,10,10,page)
    tab.Page=page

    local btn = new("TextButton",{
        Size=UDim2.new(0,0,1,0),
        AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1,
        Text=name,
        TextColor3=T.text3,
        TextSize=10, Font=Enum.Font.Code,
        AutoButtonColor=false,
    }, self.Tabbar)
    pdg(0,0,12,12,btn)

    local ul = new("Frame",{
        Size=UDim2.new(1,0,0,2),
        Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=T.accent,
        BackgroundTransparency=1,
    }, btn)

    btn.MouseEnter:Connect(function()
        if self.ActiveTab~=tab then tw(btn,{TextColor3=T.text2},0.1) end
    end)
    btn.MouseLeave:Connect(function()
        if self.ActiveTab~=tab then tw(btn,{TextColor3=T.text3},0.1) end
    end)
    btn.MouseButton1Click:Connect(function() self:SelectTab(tab) end)

    tab.Btn=btn; tab.UL=ul
    table.insert(self.Tabs,tab)
    if #self.Tabs==1 then self:SelectTab(tab) end
    return tab
end

function Library:SelectTab(t)
    for _,x in ipairs(self.Tabs) do
        x.Page.Visible=false
        tw(x.Btn,{TextColor3=T.text3},0.12)
        tw(x.UL, {BackgroundTransparency=1},0.12)
    end
    t.Page.Visible=true
    tw(t.Btn,{TextColor3=T.accent2},0.12)
    tw(t.UL, {BackgroundTransparency=0},0.12)
    self.ActiveTab=t
end

-- ══════════════════════════════════════════════════════════════════
-- SECTION
-- ══════════════════════════════════════════════════════════════════
local Section={}
Section.__index=Section

function Library:AddSection(tab, name)
    local s=setmetatable({},Section)
    s._lib=self

    local frame=new("Frame",{
        Name=name,
        BackgroundColor3=T.surface2,
        AutomaticSize=Enum.AutomaticSize.Y,
        Size=UDim2.new(1,0,0,0),
    }, tab.Page)
    rnd(6,frame); brdr(T.border,1,frame)

    local hdr=new("Frame",{
        Name="Header",
        Size=UDim2.new(1,0,0,26),
        BackgroundColor3=T.surface3,
    }, frame)
    rnd(6,hdr); brdr(T.border,1,hdr)
    new("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=string.upper(name),
        TextColor3=T.text3,
        TextSize=9, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, hdr)
    pdg(0,0,10,10,hdr)

    local body=new("Frame",{
        Name="Body",
        Size=UDim2.new(1,0,0,0),
        Position=UDim2.new(0,0,0,26),
        BackgroundTransparency=1,
        AutomaticSize=Enum.AutomaticSize.Y,
    }, frame)
    vlist(0,body)
    pdg(4,4,0,0,body)

    s.Body=body; s.Frame=frame
    return s
end

local function mkRow(parent)
    local r=new("Frame",{
        Size=UDim2.new(1,0,0,30),
        BackgroundColor3=Color3.new(1,1,1),
        BackgroundTransparency=1,
    }, parent)
    hlist(8,r); pdg(0,0,10,10,r)
    rowHover(r)
    return r
end

local function mkLabel(text,parent,sz)
    return new("TextLabel",{
        Size=sz or UDim2.new(1,-50,1,0),
        BackgroundTransparency=1,
        Text=text, TextColor3=T.text2,
        TextSize=11, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, parent)
end

-- ══════════════════════════════════════════════════════════════════
-- TOGGLE
-- ══════════════════════════════════════════════════════════════════
function Section:AddToggle(text, default, cb)
    local row=mkRow(self.Body)
    mkLabel(text,row)

    local track=new("TextButton",{
        Size=UDim2.new(0,32,0,16),
        BackgroundColor3=T.surface3,
        Text="", AutoButtonColor=false,
    }, row)
    rnd(999,track)
    local ts=brdr(T.border,1,track)

    local knob=new("Frame",{
        Size=UDim2.new(0,10,0,10),
        Position=UDim2.new(0,2,0.5,-5),
        BackgroundColor3=T.text3,
    }, track)
    rnd(999,knob)

    local state=default or false
    local function set(v,silent)
        state=v
        if state then
            tw(track,{BackgroundColor3=Color3.fromHex("7c5cbf"),BackgroundTransparency=0.75},0.15)
            tw(ts,{Color=T.accent},0.15)
            tw(knob,{Position=UDim2.new(0,20,0.5,-5),BackgroundColor3=T.accent2},0.15)
        else
            tw(track,{BackgroundColor3=T.surface3,BackgroundTransparency=0},0.15)
            tw(ts,{Color=T.border},0.15)
            tw(knob,{Position=UDim2.new(0,2,0.5,-5),BackgroundColor3=T.text3},0.15)
        end
        if not silent and cb then cb(state) end
    end
    set(state,true)
    track.MouseButton1Click:Connect(function() set(not state) end)

    return {GetState=function() return state end, SetState=function(v) set(v) end}
end

-- ══════════════════════════════════════════════════════════════════
-- SLIDER
-- ══════════════════════════════════════════════════════════════════
function Section:AddSlider(text, min, max, default, cb)
    local wrap=new("Frame",{
        Size=UDim2.new(1,0,0,48),
        BackgroundColor3=Color3.new(1,1,1),
        BackgroundTransparency=1,
    }, self.Body)
    vlist(4,wrap); pdg(6,6,10,10,wrap)
    rowHover(wrap)

    local top=new("Frame",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1},wrap)

    new("TextLabel",{
        Size=UDim2.new(0.7,0,1,0),
        BackgroundTransparency=1,
        Text=text, TextColor3=T.text2,
        TextSize=11, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, top)

    local valLbl=new("TextLabel",{
        Size=UDim2.new(0.3,0,1,0),
        Position=UDim2.new(0.7,0,0,0),
        BackgroundTransparency=1,
        Text=tostring(default or min),
        TextColor3=T.accent2,
        TextSize=10, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Right,
    }, top)

    local trackBg=new("Frame",{
        Size=UDim2.new(1,0,0,3),
        BackgroundColor3=T.surface3,
    }, wrap)
    rnd(2,trackBg)

    local fill=new("Frame",{
        Size=UDim2.new(0,0,1,0),
        BackgroundColor3=T.accent2,
    }, trackBg)
    rnd(2,fill)

    local knob=new("Frame",{
        Size=UDim2.new(0,12,0,12),
        Position=UDim2.new(0,-6,0.5,-6),
        BackgroundColor3=T.accent2, ZIndex=2,
    }, trackBg)
    rnd(999,knob)

    local val=default or min
    local dragging=false

    local function setVal(v,silent)
        v=math.clamp(math.round(v),min,max)
        val=v
        local pct=(v-min)/(max-min)
        fill.Size=UDim2.new(pct,0,1,0)
        knob.Position=UDim2.new(pct,-6,0.5,-6)
        valLbl.Text=tostring(v)
        if not silent and cb then cb(v) end
    end
    setVal(val,true)

    local function fromInput(i)
        local rel=math.clamp((i.Position.X-trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X,0,1)
        setVal(min+(max-min)*rel)
    end

    trackBg.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; tw(knob,{Size=UDim2.new(0,14,0,14)},0.07); fromInput(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then fromInput(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if (i.UserInputType==Enum.UserInputType.MouseButton1
        or  i.UserInputType==Enum.UserInputType.Touch) and dragging then
            dragging=false; tw(knob,{Size=UDim2.new(0,12,0,12)},0.07)
        end
    end)

    return {GetValue=function() return val end, SetValue=function(v) setVal(v) end}
end

-- ══════════════════════════════════════════════════════════════════
-- DROPDOWN
-- ══════════════════════════════════════════════════════════════════
function Section:AddDropdown(text, opts, default, cb)
    local wrap=new("Frame",{
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,
    }, self.Body)
    vlist(4,wrap); pdg(6,6,10,10,wrap)

    new("TextLabel",{
        Size=UDim2.new(1,0,0,14),
        BackgroundTransparency=1,
        Text=text, TextColor3=T.text2,
        TextSize=11, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, wrap)

    local sel=default or opts[1]

    local btn=new("TextButton",{
        Size=UDim2.new(1,0,0,26),
        BackgroundColor3=T.surface3,
        Text=sel.."  ▾",
        TextColor3=T.text,
        TextSize=10, Font=Enum.Font.Code,
        AutoButtonColor=false,
    }, wrap)
    rnd(4,btn)
    local bs=brdr(T.border,1,btn)

    btn.MouseEnter:Connect(function() tw(bs,{Color=T.accent},0.1) end)
    btn.MouseLeave:Connect(function() tw(bs,{Color=T.border},0.1) end)

    local open=false
    local list=new("Frame",{
        Size=UDim2.new(1,0,0,0),
        BackgroundColor3=T.surface2,
        ClipsDescendants=true,
        ZIndex=50, Visible=false,
    }, wrap)
    rnd(4,list); brdr(T.border,1,list)
    vlist(0,list)

    for _,opt in ipairs(opts) do
        local ob=new("TextButton",{
            Size=UDim2.new(1,0,0,26),
            BackgroundColor3=T.surface2,
            BackgroundTransparency=opt==sel and 0.6 or 1,
            Text=opt,
            TextColor3=opt==sel and T.accent2 or T.text2,
            TextSize=10, Font=Enum.Font.Code,
            AutoButtonColor=false, ZIndex=51,
        }, list)
        pdg(0,0,10,10,ob)

        ob.MouseEnter:Connect(function()
            tw(ob,{BackgroundTransparency=0.85,TextColor3=T.text},0.08)
        end)
        ob.MouseLeave:Connect(function()
            tw(ob,{BackgroundTransparency=opt==sel and 0.6 or 1,TextColor3=opt==sel and T.accent2 or T.text2},0.08)
        end)
        ob.MouseButton1Click:Connect(function()
            for _,c in ipairs(list:GetChildren()) do
                if c:IsA("TextButton") then tw(c,{TextColor3=T.text2,BackgroundTransparency=1},0.08) end
            end
            sel=opt; btn.Text=opt.."  ▾"
            tw(ob,{TextColor3=T.accent2,BackgroundTransparency=0.6},0.08)
            open=false
            tw(list,{Size=UDim2.new(1,0,0,0)},0.12)
            task.wait(0.13); list.Visible=false
            if cb then cb(opt) end
        end)
    end

    btn.MouseButton1Click:Connect(function()
        open=not open
        if open then
            list.Visible=true
            tw(list,{Size=UDim2.new(1,0,0,#opts*26)},0.14,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        else
            tw(list,{Size=UDim2.new(1,0,0,0)},0.12)
            task.wait(0.13); list.Visible=false
        end
    end)

    return {GetValue=function() return sel end}
end

-- ══════════════════════════════════════════════════════════════════
-- BUTTON
-- ══════════════════════════════════════════════════════════════════
function Section:AddButton(text, cb)
    local wrap=new("Frame",{
        Size=UDim2.new(1,0,0,34),
        BackgroundTransparency=1,
    }, self.Body)
    pdg(4,4,10,10,wrap)

    local btn=new("TextButton",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=T.surface3,
        Text=text, TextColor3=T.text2,
        TextSize=10, Font=Enum.Font.Code,
        AutoButtonColor=false,
    }, wrap)
    rnd(4,btn)
    local bs=brdr(T.border,1,btn)

    btn.MouseEnter:Connect(function()
        tw(btn,{BackgroundColor3=Color3.fromHex("7c5cbf"),BackgroundTransparency=0.92,TextColor3=T.accent2},0.12)
        tw(bs,{Color=T.accent},0.12)
    end)
    btn.MouseLeave:Connect(function()
        tw(btn,{BackgroundColor3=T.surface3,BackgroundTransparency=0,TextColor3=T.text2},0.12)
        tw(bs,{Color=T.border},0.12)
    end)
    btn.MouseButton1Down:Connect(function()
        tw(btn,{Size=UDim2.new(0.98,0,0.94,0),Position=UDim2.new(0.01,0,0.03,0)},0.06)
    end)
    btn.MouseButton1Up:Connect(function()
        tw(btn,{Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,0,0,0)},0.06)
        if cb then cb() end
    end)

    return {Fire=function() if cb then cb() end end}
end

-- ══════════════════════════════════════════════════════════════════
-- KEYBIND
-- ══════════════════════════════════════════════════════════════════
function Section:AddKeybind(text, default, cb)
    local row=mkRow(self.Body)
    mkLabel(text,row)

    local kd=new("TextButton",{
        Size=UDim2.new(0,52,0,20),
        BackgroundColor3=T.surface3,
        Text=default and default.Name:upper():sub(1,6) or "NONE",
        TextColor3=T.accent2,
        TextSize=9, Font=Enum.Font.Code,
        AutoButtonColor=false,
    }, row)
    rnd(3,kd)
    local ks=brdr(T.border,1,kd)

    local listening=false
    local curKey=default

    kd.MouseEnter:Connect(function() tw(ks,{Color=T.accent},0.1) end)
    kd.MouseLeave:Connect(function() if not listening then tw(ks,{Color=T.border},0.1) end end)

    kd.MouseButton1Click:Connect(function()
        if listening then return end
        listening=true
        kd.Text="..."; kd.TextColor3=T.text3
        tw(ks,{Color=T.accent},0.1)
    end)

    UserInputService.InputBegan:Connect(function(inp,proc)
        if listening and not proc then
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                listening=false; curKey=inp.KeyCode
                kd.Text=inp.KeyCode.Name:upper():sub(1,6)
                kd.TextColor3=T.accent2
                tw(ks,{Color=T.border},0.1)
                if cb then cb(inp.KeyCode) end
            end
        elseif not proc and curKey and inp.KeyCode==curKey then
            if cb then cb(inp.KeyCode) end
        end
    end)

    return {
        GetKey=function() return curKey end,
        SetKey=function(kc) curKey=kc; kd.Text=kc and kc.Name:upper():sub(1,6) or "NONE" end,
    }
end

-- ══════════════════════════════════════════════════════════════════
-- COLOR PICKER
-- ══════════════════════════════════════════════════════════════════
function Section:AddColorpicker(text, default, cb)
    local cur=default or T.accent

    local row=mkRow(self.Body)
    mkLabel(text,row)

    local swatch=new("TextButton",{
        Size=UDim2.new(0,24,0,18),
        BackgroundColor3=cur,
        Text="", AutoButtonColor=false,
    }, row)
    rnd(3,swatch)
    local ss=brdr(T.border,1,swatch)

    swatch.MouseEnter:Connect(function() tw(ss,{Color=T.accent},0.1) end)
    swatch.MouseLeave:Connect(function() tw(ss,{Color=T.border},0.1) end)

    local panel=new("Frame",{
        Size=UDim2.new(1,-20,0,0),
        Position=UDim2.new(0,10,0,0),
        BackgroundColor3=T.surface3,
        ClipsDescendants=true,
        Visible=false, ZIndex=30,
    }, self.Body)
    rnd(4,panel); brdr(T.border,1,panel)

    local pl=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},panel)
    vlist(6,pl); pdg(8,8,10,10,pl)

    local h,s,v=Color3.toHSV(cur)
    local function rebuild()
        cur=Color3.fromHSV(h,s,v)
        swatch.BackgroundColor3=cur
        if cb then cb(cur) end
    end

    local function hsvSlider(lbl,init,tColor,onChange)
        local sf=new("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1},pl)
        vlist(3,sf)
        new("TextLabel",{
            Size=UDim2.new(1,0,0,11),
            BackgroundTransparency=1,
            Text=lbl, TextColor3=T.text3,
            TextSize=9, Font=Enum.Font.Code,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, sf)
        local tbg=new("Frame",{Size=UDim2.new(1,0,0,4),BackgroundColor3=T.surface2},sf)
        rnd(2,tbg)
        local tf=new("Frame",{Size=UDim2.new(init,0,1,0),BackgroundColor3=tColor},tbg)
        rnd(2,tf)
        local tk=new("Frame",{
            Size=UDim2.new(0,10,0,10),
            Position=UDim2.new(init,-5,0.5,-5),
            BackgroundColor3=Color3.new(1,1,1), ZIndex=2,
        },tbg)
        rnd(999,tk)
        local dg=false
        tbg.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dg=true
                local r=math.clamp((i.Position.X-tbg.AbsolutePosition.X)/tbg.AbsoluteSize.X,0,1)
                tf.Size=UDim2.new(r,0,1,0); tk.Position=UDim2.new(r,-5,0.5,-5); onChange(r)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local r=math.clamp((i.Position.X-tbg.AbsolutePosition.X)/tbg.AbsoluteSize.X,0,1)
                tf.Size=UDim2.new(r,0,1,0); tk.Position=UDim2.new(r,-5,0.5,-5); onChange(r)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end
        end)
    end

    hsvSlider("H",h,T.accent2,function(r) h=r rebuild() end)
    hsvSlider("S",s,T.accent, function(r) s=r rebuild() end)
    hsvSlider("V",v,T.text2,  function(r) v=r rebuild() end)

    local open=false
    swatch.MouseButton1Click:Connect(function()
        open=not open
        if open then
            panel.Visible=true
            tw(panel,{Size=UDim2.new(1,-20,0,108)},0.14,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        else
            tw(panel,{Size=UDim2.new(1,-20,0,0)},0.12)
            task.wait(0.13); panel.Visible=false
        end
    end)

    return {
        GetColor=function() return cur end,
        SetColor=function(c)
            cur=c; swatch.BackgroundColor3=c
            h,s,v=Color3.toHSV(c)
            if cb then cb(c) end
        end,
    }
end

-- ══════════════════════════════════════════════════════════════════
-- SEPARATOR
-- ══════════════════════════════════════════════════════════════════
function Section:AddSeparator()
    new("Frame",{
        Size=UDim2.new(1,-20,0,1),
        Position=UDim2.new(0,10,0,0),
        BackgroundColor3=T.border,
        BackgroundTransparency=0.5,
    }, self.Body)
end

-- ══════════════════════════════════════════════════════════════════
-- LABEL
-- ══════════════════════════════════════════════════════════════════
function Section:AddLabel(text)
    local f=new("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1},self.Body)
    pdg(0,0,10,10,f)
    local lbl=new("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=text, TextColor3=T.text3,
        TextSize=10, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true,
    },f)
    return {SetText=function(t) lbl.Text=t end, GetText=function() return lbl.Text end}
end

-- ══════════════════════════════════════════════════════════════════
-- INPUT
-- ══════════════════════════════════════════════════════════════════
function Section:AddInput(text, placeholder, cb)
    local wrap=new("Frame",{
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,
    },self.Body)
    vlist(4,wrap); pdg(6,6,10,10,wrap)
    new("TextLabel",{
        Size=UDim2.new(1,0,0,14),
        BackgroundTransparency=1,
        Text=text, TextColor3=T.text2,
        TextSize=11, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left,
    },wrap)
    local box=new("TextBox",{
        Size=UDim2.new(1,0,0,26),
        BackgroundColor3=T.surface3,
        Text="", PlaceholderText=placeholder or "",
        PlaceholderColor3=T.text3,
        TextColor3=T.text,
        TextSize=10, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left,
        ClearTextOnFocus=false,
    },wrap)
    rnd(4,box)
    local bs=brdr(T.border,1,box)
    pdg(0,0,8,8,box)
    box.Focused:Connect(function() tw(bs,{Color=T.accent},0.12) end)
    box.FocusLost:Connect(function(enter)
        tw(bs,{Color=T.border},0.12)
        if cb then cb(box.Text,enter) end
    end)
    return {GetValue=function() return box.Text end, SetValue=function(v) box.Text=v end}
end

return Library
