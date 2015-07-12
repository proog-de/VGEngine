'vge (vector graphics engine)
'simple example

#include "vge.bas"
Const m=1000  '1 Meter
Const MainViewW=640
Const MainViewH=480

Dim As TView V

screenres MainViewW,MainViewH,24
Color &Hf0f0f0,&H106010
Cls

V.Scale=1*m
V.Debug=-1
V.WinX=MainViewW
V.WinY=MainViewH
ScreenCenter 0*m, 0*m, V


'################################################
'## vector model build and draw
'################################################

var house=VectColor(&H801515)+VectFBox(-50,-125,50,125)

DrawModel 0*m, -50*m, 0*m, 50*m, house, V

Sleep
End
