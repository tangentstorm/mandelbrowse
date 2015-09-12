NB. -----------------------------------------------
NB.
NB. Mandelbrowse
NB.
NB. A visual Mandelbrot set explorer written in J.
NB.
NB. -----------------------------------------------
NB. Copyright © 2015 Michal J Wallace
NB. Available for public use under the MIT license.
NB. -----------------------------------------------


NB. == configuration ==============================

reset =: 3 : 0 ''
  ITERS =: 32              NB. # of iterations of the formula.
  START =: _2.5j_1.5       NB. lower left corner of view
  SHAPE =: 48 64           NB. should have a 3:4 aspect ratio
  SCALE0=: {. SHAPE % 3 4
  SCALE =: 1               NB. increase to zoom in
)

NB. color scheme: black, white, golds and blues 
pal =: rgb '0 ffffff ffd21d b28f00 400fe8 1d2799 000055 000033'

NB. == dependencies

coinsert'jviewmat' [ load 'viewmat'

NB. !! this is a workaround for a j8 bug (as of 09/12/2015)
viewmatcc =: glpaint_jgl2_@viewmatcc_jviewmat_

NB. == mandelbrot verbs ===========================

NB. mbrot y  → 0 if bounded
NB. else number of iterations where value was > 2
mbrot =: [: +/ 2 <&| ([ + *:@] :: _:)"0^:(<ITERS)~

NB. draw our zoomed in section of the complex plane
plane =: 3 : 0
  START + (SCALE * SCALE0) %~ j.~/&i./ SHAPE
)

NB. verb to convert space-separated hex strings into rgb triples:
rgb =: (3$256) #: [: dfh;._1 ' ',] 

render =: 3 : 0
  img =: mbrot plane''
)

NB. === gui stuff =================================

w_cancel =: 3 : 0
  wd 'pclose'
)

w_g_mblup =: 3 : 0 NB. left mouse button
  (? 8 3 $ 256) viewmatcc img;'g'
)

w_g_mbrup =: 3 : 0 NB. right mouse button
  pal viewmatcc img;'g'
)

NB. == launch window and draw =====================

wd 0 : 0
  pc w closeok; minwh 640 480;
  pn mandelbrowse;
  cc g isidraw;
  pcenter; pshow;
)

pal viewmatcc (render'');'g'


NB. debug verb to see just corners of a big 2d array:
corners =: [: ({.,:{:) ({.,{:)"1
