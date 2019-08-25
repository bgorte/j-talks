NB. ------------------------------------------------------------
NB. sandcalc : a sandpile calculator
NB.
NB. (c) copyright 2019 michal j. wallace
NB. http://tangentstorm.com
NB.
NB. available for use under the MIT licence
NB. ------------------------------------------------------------
NB. Quick Sandpile References:
NB. https://en.wikipedia.org/wiki/Abelian_sandpile_model
NB. https://www.youtube.com/watch?v=1MtEUErz7Gg (numberphile)
NB. ------------------------------------------------------------

require 'viewmat'
coinsert 'jviewmat jgl2'
require '~JTalks/s1e1-sandpiles/sandpiles.ijs'


NB. main animation logic ---------------------------------------

stl =: settle^:_
NxN =: 5 5
ZSP =: stl (4 - stl) NxN $ 4    NB. "zero": https://hal.archives-ouvertes.fr/hal-00016378

pen =: 0                        NB. color to draw with
sp0 =: NxN $ 0
sp1 =: NxN $ 3
sp2 =: ZSP

update =: verb define
  sp3 =: stl sp0 + sp1 + sp2
)

render =: verb define
  spcc 'scw';'sp0';sp0
  spcc 'scw';'sp1';sp1
  spcc 'scw';'sp2';sp2
  spcc 'scw';'sp3';sp3
)


NB. create the window ------------------------------------------

scw_close =: verb define
 wd 'psel scw; pclose;'
 wd 'timer 0'
)

NB. Recycle window if we run multiple times:
scw_close^:(wdisparent'scw')''

wd (0 : 0)
pc scw closebutton; pn "sandcalc - a sandpile calculator";
bin h;
  minwh 50 200; cc pal isigraph;
  minwh 200 200; cc sp0 isidraw;
  cc "+" static;
  minwh 200 200; cc sp1 isidraw;
  cc "+" static;
  minwh 200 200; cc sp2 isidraw;
  cc "=" static;
  minwh 200 200; cc sp3 isidraw;
bin z;
pcenter;
rem pmove 250 1000 0 0;
pshow
)


NB. palette to show/select drawing color -----------------------

scw_pal_paint =: verb define
  'rgb' vmcc (,.lo);'pal'
  glfont 'consolas 12'
  glpen 1 [ glbrush glrgb 0 0 0
  gltextcolor glrgb 255 255 255
  for_i. i.4 do.
    yy =. (12+50*i)
    glrect   18, (yy+1), 15 21
    gltextxy 20, yy
    gltext ":i
  end.
  NB. highlight current pen:
  glbrush glrgba 0 0 0 0
  glrect 3, (3+pen*50), 45 45 [ glpen 5 [ glrgb 0 0 0
  glrect 3, (3+pen*50), 45 45 [ glpen 1 [ glrgb 3 $ 255
)


NB. mouse events -----------------------------------------------

whichbox =: verb : '|. <. y %~ 2 {. ".sysdata'
button  =: verb : 'y { 4 }. ".sysdata'
boxsize =: 200 %{.NxN
mousedraw =: dyad : 'pen (<0>.(<:$x)<.whichbox y) } x'

NB. click the palette to change current pen
scw_pal_mblup =: verb : 'glpaint glsel ''pal'' [ pen =: {. whichbox 50'

NB. mouse wheel on any input pile rotates through palette
scw_pal_mwheel =: verb define
  pen =: 4|pen-*{:".sysdata NB. absolute val of last item is wheel dir
  glpaint glsel'pal'
)
scw_sp0_mwheel =: scw_sp1_mwheel =: scw_sp2_mwheel =: scw_pal_mwheel

NB. left click draws on the input
scw_sp0_mblup =: verb : 'sp0 =: sp0 mousedraw boxsize'
scw_sp1_mblup =: verb : 'sp1 =: sp1 mousedraw boxsize'
scw_sp2_mblup =: verb : 'sp2 =: sp2 mousedraw boxsize'

NB. left drag does the same
scw_sp0_mmove =: verb : 'if. button 0 do. scw_sp0_mblup _ end.'
scw_sp1_mmove =: verb : 'if. button 0 do. scw_sp1_mblup _ end.'
scw_sp2_mmove =: verb : 'if. button 0 do. scw_sp2_mblup _ end.'

NB. right click to copy the sum to an input
scw_sp0_mbrup =: verb : 'sp0 =: sp3'
scw_sp1_mbrup =: verb : 'sp1 =: sp3'
scw_sp2_mbrup =: verb : 'sp2 =: sp3'

NB. middle click to reset the input
scw_sp0_mbmup =: verb : 'sp0 =: NxN$0'
scw_sp1_mbmup =: verb : 'sp1 =: NxN$3'
scw_sp2_mbmup =: verb : 'sp2 =: ZSP'


NB. animation engine -------------------------------------------

step =: render @ update         NB. glpaint is in each spcc call
sys_timer_z_ =: step_base_
wd 'timer 100'
