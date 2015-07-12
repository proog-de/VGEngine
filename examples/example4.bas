'FreeBASIC
'vge (vector graphics engine)
'taken from Train Simulator

'Anti Aliasing Test
#define AA_on

#include "vge.bas"


'################################################
'## Definitions and constants
'################################################

Const AAmax=4

#ifdef AA_on
  Dim Shared As Integer AA                  'AntiAliasing / smooth graphics
  Dim Shared As Integer AAsqu
#else
  Const AA=1
#endif

Const NULL As Any Ptr = 0
Const m=1000  '1 Meter
Const ZoomMinLevel=10        '1 pixel = 10mm
Const ZoomMaxLevel=100000    '1 pixel = 100m
Const GroundColor = &H106010 'Default Ground Color
Const MaxModels=100             'vector model (building, train, ...)


'Keyboard control
'Const K_F1=Chr$(255)+Chr$(59)               'F1
'Const K_F2=Chr$(255)+Chr$(60)               'F2
'Const K_F3=Chr$(255)+Chr$(61)               'F3
'Const K_Insert=Chr$(255)+"R"                'Insert
'Const K_Delete=Chr$(255)+"S"                'Delete
'Const K_BackSp=Chr$(8)                      'Backcpace
'Const K_Pos1=Chr$(255)+"G"                  'Pos1
'Const K_End=Chr$(255)+"O"                   'End

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
'## Types
'################################################

Type PModel As TModel Ptr
Type TModel                         'Vector graphics model
  As String mType
  As String mName
  As String mBuild                  'vector graphics commands
End Type

Type TWorld                         'The world
 As PModel Model(MaxModels)
End Type



'################################################
'## Variables
'################################################


'Graphics screen pointer
Dim Shared As Any Ptr window1, window_aa


'The world
Dim Shared As TWorld w
Dim Shared As TView v


'Global stuff
Dim Shared As String ks   'user input from keyboard
Dim As Integer i, j       'temporary variables
Dim As Integer mo         'model number
Dim As Integer ani        'animation

Dim Shared As Integer MainViewW
Dim Shared As Integer MainViewH
Dim As Integer mousex, mousey, mousewh, mousebt


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


'################################################
'## Init
'################################################

ScreenInit(640,480)
Cls


'################################################
'## View init
'################################################


'window1=imagecreate(MainViewW*AA,MainViewH*AA)
window1=imagecreate(MainViewW*AAmax,MainViewH*AAmax)

V.WinX=MainViewW*AAmax
V.WinY=MainViewH*AAmax

Color &Heeeeee,&H204020
Cls


'################################################
'## Build Items for drwaing (Train, House)
'################################################


i=0

'Building: race car
i+=1
w.model(i)=new TModel
w.model(i)->mType="vehicle"
w.model(i)->mName="Racer"

w.model(i)->mBuild= _
  VectVehicle _
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

'Building: House
i+=1
w.model(i)=new TModel
w.model(i)->mType="building"
w.model(i)->mName="House"
w.model(i)->mBuild= _
   VectZoomOut(255) _
  +VectColor(&H800000) _
  +VectLine(0,-125,0,125) _
  +VectExit _
  +VectEndZoom _
  +VectZoomIn(255) _
  +VectColor(&H801515) _
  +VectFBox(-50,-125,50,125) _
  +VectEndZoom _
  +VectZoomIn(80) _
  +VectColor(1) _
  +VectLine(-50,-125,0,-100) _
  +VectLine(0,-100,50,-125) _
  +VectLine(-50,125,0,100) _
  +VectLine(0,100,50,125) _
  +VectLine(0,-100,0,100) _
  +VectEndZoom _
  +VectZoomIn(10) _
  +VectColor(&H808000) _
  +VectFCircle(25,0,10) _
  +VectEndZoom _

'forest
i+=1
w.model(i)=new TModel
w.model(i)->mType="vegetation"
w.model(i)->mName="Forest"
w.model(i)->mBuild=VectColor(&H008040)
For j=1 To 30
  w.model(i)->mBuild=w.model(i)->mBuild+VectFCircle(20+Rnd*210-125,25+Rnd*200-125,5+Rnd*10)
Next
w.model(i)->mBuild=w.model(i)->mBuild+VectColor(&H00a030)
For j=1 To 20
  w.model(i)->mBuild=w.model(i)->mBuild+VectFCircle(20+Rnd*210-125,25+Rnd*200-125,5+Rnd*10)
Next


'Building: Zoomtest
i+=1
w.model(i)=new TModel
w.model(i)->mType="building"
w.model(i)->mName="Zoomtest"
w.model(i)->mBuild= _
   VectZoomOut(250)+VectColor(&H800000)+VectFBox(-125,-125,0,-100)+VectEndZoom _
  +VectZoomIn (250)+VectColor(&H800000)+VectFBox(0,-125,125,-100)+VectEndZoom _
  +VectZoomOut(150)+VectColor(&H008000)+VectFBox(-125,-100,0,-75)+VectEndZoom _
  +VectZoomIn (150)+VectColor(&H008000)+VectFBox(0,-100,125,-75)+VectEndZoom _
  +VectZoomOut( 90)+VectColor(&H800080)+VectFBox(-125,-75,0,-50)+VectEndZoom _
  +VectZoomIn ( 90)+VectColor(&H800080)+VectFBox(0,-75,125,-50)+VectEndZoom _
  +VectZoomOut( 50)+VectColor(&H808000)+VectFBox(-125,-50,0,-25)+VectEndZoom _
  +VectZoomIn ( 50)+VectColor(&H808000)+VectFBox(0,-50,125,-25)+VectEndZoom _
  +VectZoomOut( 25)+VectColor(&H008080)+VectFBox(-125,-25,0,0)+VectEndZoom _
  +VectZoomIn ( 25)+VectColor(&H008080)+VectFBox(0,-25,125,0)+VectEndZoom _
  +VectZoomOut( 15)+VectColor(&H800000)+VectFBox(-125,0,0,25)+VectEndZoom _
  +VectZoomIn ( 15)+VectColor(&H800000)+VectFBox(0,0,125,25)+VectEndZoom _
  +VectZoomOut(  8)+VectColor(&H008000)+VectFBox(-125,25,0,50)+VectEndZoom _
  +VectZoomIn (  8)+VectColor(&H008000)+VectFBox(0,25,125,50)+VectEndZoom _
  +VectZoomOut(  4)+VectColor(&H800080)+VectFBox(-125,50,0,75)+VectEndZoom _
  +VectZoomIn (  4)+VectColor(&H800080)+VectFBox(0,50,125,75)+VectEndZoom _
  +VectZoomOut(  2)+VectColor(&H808000)+VectFBox(-125,75,0,100)+VectEndZoom _
  +VectZoomIn (  2)+VectColor(&H808000)+VectFBox(0,75,125,100)+VectEndZoom _
  +VectZoomOut(  1)+VectColor(&H008080)+VectFBox(-125,100,0,125)+VectEndZoom _
  +VectZoomIn (  1)+VectColor(&H008080)+VectFBox(0,100,125,125)+VectEndZoom

'Building: ZoomRange
i+=1
w.model(i)=new TModel
w.model(i)->mType="building"
w.model(i)->mName="ZoomRange"
w.model(i)->mBuild= _
   VectColor(&H808080)+VectFBox(-25,-125,25,125)+VectEndZoom _
  +VectColor(&H800000) _
  +VectZoomRange(1,2)+VectFBox(-125,-120,125,-90)+VectEndZoom _
  +VectZoomRange(2,4)+VectFBox(-125,-90,125,-60)+VectEndZoom _
  +VectZoomRange(4,8)+VectFBox(-125,-60,125,-30)+VectEndZoom _
  +VectZoomRange(8,16)+VectFBox(-125,-30,125,0)+VectEndZoom _
  +VectZoomRange(16,32)+VectFBox(-125,0,125,30)+VectEndZoom _
  +VectZoomRange(32,64)+VectFBox(-125,30,125,60)+VectEndZoom _
  +VectZoomRange(64,128)+VectFBox(-125,60,125,90)+VectEndZoom _
  +VectZoomRange(128,255)+VectFBox(-125,90,125,120)+VectEndZoom _
  +VectColor(&H000080) _
  +VectFCircle(0,-105,10) _
  +VectFCircle(0,-75,10) _
  +VectFCircle(0,-45,10) _
  +VectFCircle(0,-15,10) _
  +VectFCircle(0, 15,10) _
  +VectFCircle(0, 45,10) _
  +VectFCircle(0, 75,10) _
  +VectFCircle(0, 105,10) 


'################################################
'## Init
'################################################

Color &Hf0f0f0,GroundColor
Cls

'screen zoom setup
V.Scale=m
v.Debug=-1

mo=4                      'Model, moved by cursor


#ifdef AA_on
AA=1                      'AntiAliasing / smooth graphics
AAsqu=AA*AA
#endif
V.WinX=MainViewW*AA
V.WinY=MainViewH*AA
ScreenCenter(200*m,200*m,v)      


Do


  
  '################################################
  '## Keyboard control
  '################################################
  
  
  GetMouse MouseX, MouseY, MouseWh, MouseBt
  ks=InKey$
  
  #ifdef AA_on
    'Switch Anti-Aliasing
    If ks>="1" And ks<="4" Then
      'save screen center coordinates (i,j)
      i=p2wx(v.WinX/2) 'Screen Center X
      j=p2wy(v.WinY/2) 'Screen Center Y
      'change AntiAliasing bitmap size
      AA=Asc(ks)-Asc("1")+1
      V.WinX=MainViewW*AA
      V.WinY=MainViewH*AA
      'center to saved coordinates
      ScreenCenter(i,j,v)
    EndIf
    AAsqu=AA*AA           'AntiAliasing / smooth graphics
  #endif
  
  'Center screen
  If ks=K_center Then ScreenCenter(200*m,200*m,v)
  
  'Switch debug on/off
  If ks=K_debug Then v.Debug=(v.Debug=0)
  
  'Zoom in to center of screen
  If Right$(ks,2)=k_zoomin Then    'PG up
    If v.Scale>ZoomMinLevel Then
      i=p2wx(v.WinX/2) 'Screen Center X
      j=p2wy(v.WinY/2) 'Screen Center Y
      v.Scale=v.Scale*9/10
      ScreenCenter(i,j,v)
    EndIf
  EndIf
  
  'Zoom out to center of screen
  If Right$(ks,2)=k_zoomout Then  'PG down
    If v.Scale<ZoomMaxLevel Then
      i=p2wx(v.WinX/2) 'Screen Center X
      j=p2wy(v.WinY/2) 'Screen Center Y
      v.Scale=v.Scale*10/9
      ScreenCenter(i,j,v)
    EndIf
  EndIf
  
  'Change model
  If (ks=K_Plus) AndAlso (w.Model(mo+1)<>NULL) Then mo += 1
  If (ks=K_Minus) AndAlso (w.Model(mo-1)<>NULL) Then mo -= 1
  
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
  
  'draw models
  
  ani+=1

  DrawModel(50*m, 200*m, 100*m, 300*m, _
    w.model(1)->mBuild, v, &Hff0000 , , window1)
  DrawModel(150*m+100*m*Sin(ani/1000), 100*m, 200*m+50*m*Sin(ani/100), 100*m+50*m*Cos(ani/100), _
    w.model(2)->mBuild, v, , , window1)
  DrawModel(300*m, 300*m, 500*m, 300*m, _
    w.model(3)->mBuild, v, , , window1)
  If MouseX<>-1 Then
    DrawModel(200*m, 200*m, p2wx(MouseX*AA), p2wy(MouseY*AA), _
      w.model(mo)->mBuild, v, , , window1)
  EndIf

  'print help
  If v.Scale<10*m Then
    Draw String window1, (0,0)," Zoom = "+str(Int(v.Scale/10))+"." _
      + str(v.Scale Mod 10) +" cm/Pixel"
  Else
    Draw String window1, (0,0)," Zoom = "+str(Int(v.Scale/1000))+"." _
      + str((v.Scale/100) Mod 10) +" m/Pixel"
  EndIf
  Draw String window1, (0,10), " PgUp = Zoom In"
  Draw String window1, (0,20), " PgDn = Zoom Out"
  Draw String window1, (0,30), " +/-  = Change Model"
  Draw String window1, (0,40), "Cursor= Move Map"
  Draw String window1, (0,50), "  d   = Debug View"
  Draw String window1, (0,60), " 1-4  = AntiAliasing Test"
  Draw String window1, (0,80), " Esc  = Exit Program"
  
  #ifdef AA_on
  
  Dim As Integer x, y, aax, aay, c, r, g, b
  Dim As Integer pitch
  Dim As Any Ptr pictstart
  
  
  
  '################################################
  '##
  '## Anti-Aliasing test
  '##
  '## resample graphics from high to low resolution
  '## it's much too slow to be useful
  '##
  '################################################
  
  If AA>1 Then
    
    'from FreeBASIC ImageInfo example
    If 0 <> ImageInfo( window1, ,,, pitch, pictstart ) Then
      Print "unable to retrieve image information."
      Sleep
      End
    End If
    window_aa=imagecreate(MainViewW,MainViewH)
    For x=0 To MainViewW-1
      For y=0 To MainViewH-1
        r=0
        g=0
        b=0
        For aay=0 To AA-1
          Dim row As UInteger Ptr = pictstart + (y*AA+aay) * pitch
          For aax=0 To AA-1
            'from FreeBASIC ImageInfo example
            c=row[x*AA+aax]
            r+=c Shr 16 And &Hff
            g+=c Shr 8 And &Hff
            b+=c And &Hff
          Next aax
        Next aay
        c=RGB(R/AAsqu, g/AAsqu, b/AAsqu)
        PSet window_aa,(x,y),c
      Next y
    Next x
    Put(0,0),window_aa,PSet
    imagedestroy window_aa
  Else
    Put(0,0),window1,PSet
  EndIf
  
  'Main window
  
  #else

  'Main window
  Put(0,0),window1,PSet
  
  #endif

  Sleep 10
  
Loop Until (Right$(ks,1)=K_Quit)
imagedestroy window1
End
