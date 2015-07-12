'vge (vector graphics engine)
'example program


#include "vge.bas"

'################################################
'## Definitions and constants
'################################################


Const NULL As Any Ptr = 0
Const m=1000  '1 Meter
Const ZoomMinLevel=10        '1 pixel = 10mm
Const ZoomMaxLevel=100000    '1 pixel = 100m
Const GroundColor = &H404040 'Default Ground Color


'Keyboard control
Const K_zoomin=Chr$(255)+"I"                'Pg-Up
Const K_zoomout=Chr$(255)+"Q"               'Pg-Down
Const K_CursUp=Chr$(255)+"H"                'Cursor up
Const K_CursDn=Chr$(255)+"P"                'Cursor down
Const K_CursLt=Chr$(255)+"K"                'Cursor left
Const K_CursRt=Chr$(255)+"M"                'Cursor right
Const K_Plus="+"
Const K_Minus="-"
Const K_center="c"
Const K_debug="d"
Const K_Quit=Chr$(27)                       'Esc
Const K_Quit2=Chr$(255)+"k"                 'Window Close-Button


'################################################
'## Variables
'################################################


'Graphics screen pointer
Dim Shared As Any Ptr window1, window_aa


Dim Shared As TView v     'the world

Dim Shared As String ks   'user input from keyboard
Dim As Double ani         'animation counter
Dim Shared As String Racer, Plane 'vector models

Dim Shared As Integer MainViewW
Dim Shared As Integer MainViewH


'################################################
'## Little helper
'################################################


Sub ScreenInit(ScreenWidth As Integer, ScreenHeight As Integer)
  If (ScreenWidth>=640) AndAlso (ScreenWidth<=1920) _
  AndAlso (ScreenHeight>=480) AndAlso (ScreenHeight<=1200) _
  Then
    MainViewW=ScreenWidth
    MainViewH=ScreenHeight
  Else
    MainViewW=640
    MainViewH=480
  EndIf
  screenres MainViewW,MainViewH,24
End Sub


'################################################
'## Main
'################################################

ScreenInit(640,480)
window1=imagecreate(MainViewW,MainViewH)
V.WinX=MainViewW
V.WinY=MainViewH
Color &Heeeeee,&H204020
Cls


'################################################
'## Define Race Car
'################################################


Racer=VectVehicle _
  +VectRem("Simple line when zoomed out") _
  +VectZoomOut(255) _
    +VectColor(1) _
    +VectLine(0,-90,0,80) _
    +VectExit _
  +VectEndZoom _
  +""_
  +VectZoomIn(150) _
    +VectRem("front air dam") _
    +VectColor(&Hc0c0c0) _
    +VectFBox(-30,-85,30,-75) _
  +VectEndZoom _
  +""_
  +VectZoomIn(255) _
    +VectRem("car body") _
    +VectColor(1) _
    +VectFBox(-10,-90,10,70) _
    +VectFBox(-20,0,20,70) _
  +VectEndZoom _
  +""_
  +VectZoomOut(150) _
    +VectRem("Zoom out wheel block") _
    +VectColor(&H202020) _
    +VectFBox(-30,-60,-20,60) _
    +VectFBox(30,-60,20,60) _
    +VectExit _
  +VectEndZoom _
  +""_
  +VectZoomIn(150) _
    +VectRem("wheels") _
    +VectColor(&H000000) _
    +VectFBox(-40,-65,-25,-35) _
    +VectFBox(40,-65,25,-35) _
    +VectFBox(-55,65,-25,35) _
    +VectFBox(55,65,25,35) _
    +VectRem("rear air dam") _
    +VectColor(&Hc0c0c0) _
    +VectFBox(-50,70,50,95) _
  +VectEndZoom _
  +""_
  +VectZoomIn(30) _
    +VectRem("pilot") _
    +VectColor(&H1010a0) _
    +VectFCircle(0,12,10) _
    +VectRem("engine") _
    +VectColor(&H606060) _
    +VectFBox(-8,30,8,65) _
  +VectEndZoom


'################################################
'## Define Airplane
'################################################


Plane=VectVehicle _
  +VectRem("two lines when zoomed out") _
  +VectZoomOut(255) _
    +VectColor(&Hc0c0c0) _
    +VectLine(0,-70,0,110) _
    +VectLine(-100,10,100,10) _
    +VectExit _
  +VectEndZoom _
  +""_
  +VectZoomIn(255) _
    +VectRem("wings") _
    +VectColor(&Hc0c0c0) _
    +VectFTri(-100,40,0,60,0,10) _
    +VectFTri(100,40,0,60,0,10) _
    +VectFTri(-100,40,-100,70,0,60) _
    +VectFTri(100,40,100,70,0,60) _
  +VectEndZoom _
  +""_
  +VectZoomIn(30) _
    +VectRem("thin line in wings") _
    +VectColor(&H808080) _
    +VectLine(-90,60,-20,50) _
    +VectLine(90,60,20,50) _
  +VectEndZoom _
  +""_
  +VectZoomIn(255) _
    +VectRem("body") _
    +VectColor(1) _
    +VectFCircle(0,-70,9) _
    +VectFBox(-10,-70,10,110) _
    +VectRem("rear wings") _
    +VectColor(&Hc0c0c0) _
    +VectFTri(-40,115,0,120,0,105) _
    +VectFTri(40,115,0,120,0,105) _
    +VectFTri(-40,115,-40,125,0,120) _
    +VectFTri(40,115,40,125,0,120) _
  +VectEndZoom _
  +""_
  +VectZoomIn(5) _
    +VectRem("Cockpit Windows visible when zoomed very near") _
    +VectColor(&Hc0c0c0) _
    +VectFTri(2,-70,2,-72,8,-69) _
    +VectFTri(2,-72,8,-69,7,-71) _
    +VectFTri(-2,-70,-2,-72,-8,-69) _
    +VectFTri(-2,-72,-8,-69,-7,-71) _
  +VectEndZoom


'################################################
'## Init
'################################################

Color &Hf0f0f0,GroundColor
Cls

'screen zoom setup
V.Scale=m
v.Debug=0

V.WinX=MainViewW
V.WinY=MainViewH
ScreenCenter(200*m,200*m,v)      


Do
  
  '################################################
  '## Main Loop
  '################################################
  
  
  ks=InKey$
  
  'Center screen
  If ks=K_center Then ScreenCenter(200*m,200*m,v)
  
  'Switch debug on/off
  If ks=K_debug Then v.Debug=(v.Debug=0)
  
  'Zoom in to center of screen
  If Right$(ks,2)=k_zoomin Then    'PG up
    If v.Scale>ZoomMinLevel Then
      var i=p2wx(v.WinX/2) 'Screen Center X
      var j=p2wy(v.WinY/2) 'Screen Center Y
      v.Scale=v.Scale*9/10
      ScreenCenter(i,j,v)
    EndIf
  EndIf
  
  'Zoom out to center of screen
  If Right$(ks,2)=k_zoomout Then  'PG down
    If v.Scale<ZoomMaxLevel Then
      var i=p2wx(v.WinX/2) 'Screen Center X
      var j=p2wy(v.WinY/2) 'Screen Center Y
      v.Scale=v.Scale*10/9
      ScreenCenter(i,j,v)
    EndIf
  EndIf
  
  'Move map with cursor
  If Right$(ks,2)=K_CursUp Then: v.Offy=v.Offy+v.winy/30: endif 'up
  If Right$(ks,2)=K_CursDn Then: v.Offy=v.Offy-v.winy/30: endif 'down
  If Right$(ks,2)=K_CursLt Then: v.Offx=v.Offx+v.winx/30: endif 'left
  If Right$(ks,2)=K_CursRt Then: v.Offx=v.Offx-v.winx/30: endif 'right
  
  'Close window by Close button
  If Right$(ks,2)=K_Quit2 Then ks=K_Quit
  
  'Close window by ALT+F4
  If MultiKey(&h38) AndAlso MultiKey(&h3E) Then ks=K_Quit
  
  
  '################################################
  '## Draw models
  '################################################
    
  'clear window1 buffer
  Line window1,(0,0)-(v.WinX-1,v.WinY-1),GroundColor,BF
  
  ani+=0.005
  
  'draw red cars
  
  For i As Integer=0 To 9
    DrawModel(100*m+200*m*Sin(ani-i/4),    200*m+200*m*Cos(ani-i/4), _
              100*m+200*m*Sin(ani-.1-i/4), 200*m+200*m*Cos(ani-.1-i/4), _
              Racer, v, &Hff0000, 0, window1)
  Next i
  
  'draw yellow cars
  
  For i As Integer=0 To 11
    DrawModel(120*m+100*m*Sin(-ani+i/2),    200*m+100*m*Cos(-ani+i/2), _
              120*m+100*m*Sin(-ani+i/2+.2), 200*m+100*m*Cos(-ani+i/2+.2), _
              Racer, v, &H111100*(15-i), 0, window1)
  Next i
  
  'draw green car
  
  DrawModel(400*m+100*m*Sin(ani),    300*m+100*m*Cos(ani), _
            400*m+100*m*Sin(ani-.4), 300*m+100*m*Cos(ani-.4), _
            Racer, v, &H20f020, 0, window1)
  
  'draw airplane
  
  DrawModel(350*m+100*m*Sin(ani),    140*m+100*m*Cos(ani), _
            350*m+100*m*Sin(ani-.7), 140*m+100*m*Cos(ani-.2), _
            Plane, v, &H6060ff, 0, window1)
  
  'print status and onscreen help
  If v.Scale<10*m Then
    Draw String window1, (0,0)," Zoom = "+str(Int(v.Scale/10))+"." _
      + str(v.Scale Mod 10) +" cm/Pixel"
  Else
    Draw String window1, (0,0)," Zoom = "+str(Int(v.Scale/1000))+"." _
      + str((v.Scale/100) Mod 10) +" m/Pixel"
  EndIf
  Draw String window1, (0,10), " PgUp = Zoom In"
  Draw String window1, (0,20), " PgDn = Zoom Out"
  Draw String window1, (0,30), "Cursor= Move Map"
  Draw String window1, (0,40), "  d   = Debug View"
  Draw String window1, (0,60), " Esc  = Exit Program"
  
  'Put main window on screen
  Put(0,0),window1,PSet
  Sleep 10
  
Loop Until (Right$(ks,1)=K_Quit)
imagedestroy window1
End
