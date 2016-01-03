NB. -----------------------------------------------
NB.
NB. Mandelbrowse
NB.
NB. A visual Mandelbrot set explorer written in J.
NB.
NB. -----------------------------------------------
NB. Copyright © 2016 Michal J Wallace
NB. Available for public use under the MIT license.
NB. -----------------------------------------------

NB. == dependencies ===============================

coinsert'jviewmat' [ load 'viewmat'

NB. !! this is a workaround for a j8 bug (as of 09/12/2015)
viewmatcc =: glpaint_jgl2_@viewmatcc_jviewmat_

NB. verb to convert space-separated hex strings into rgb triples:
rgb =: (3$256) #: [: dfh;._1 ' ',]

NB. == configuration ==============================

reset =: 3 : 0
  ITERS =: 32              NB. # of iterations of the formula.
  CENTER =: _1j0           NB. center of the view
  SHAPE =: 320 240         NB. width, height of the data array
  GRAIN =: 2               NB. pixels per array entry
  STEP  =: {. 4 3 % SHAPE  NB. initial step between array units
  SCALE =: 1               NB. user zoom factor
  CENTERS =: ,CENTER       NB. stack of center values
  LOWRES =: 0              NB. toggle for low resolution
)
reset''

NB. color scheme: black, white, golds and blues
pal =: rgb '0 ffffff ffd21d b28f00 400fe8 1d2799 000055 000033'

NB. == mandelbrot verbs ===========================

NB. mbrot y  → 0 if bounded
NB. else number of iterations where value was > 2
mbrot =: [: +/ 2 <&| ((+ *:) :: _:)"0^:(<ITERS) & 0

c2w =: 3 : 0 NB. camera [0j0 in upper left] to world (centered,zoomed)
  CENTER + SCALE * STEP * (-: j./<:SHAPE) -~ y
)

NB. draw our zoomed in section of the complex plane
plane =: 3 : 0
  c2w (j.~/&i.~/ SHAPE)
)

NB. == graphics ====================================

render =: 3 : 0
  img =: mbrot plane''
)

NB. === event handlers =============================

div =: <.@%

mw =: 3 : 0  NB. mouse position in world cordinates
  mxy =. 2 {. _".sysdata
  c2w j./ GRAIN div~ mxy
)

w_cancel =: 3 : 0
  wd 'pclose'
)

repaint =: 3 : 0
  pal viewmatcc (render'');'g'
  update_status''
)

update_status =: 3 : 0
  mp =. ' pos: ', ": 8j5 ": +. mw''
  sc =. ' scale: ', ": SCALE
  ll =. ' center: ', ": +. CENTER
  lo =. ' [', ' res] ',~ > LOWRES { 'hi';'lo'
  wd 'set sb setlabel text "', ll, sc, lo, mp, '";'
)

w_g_mblup =: 3 : 0 NB. left mouse button
  CENTERS =: CENTER, CENTERS
  CENTER =: mw''
  repaint [ SCALE =: -: SCALE
)

w_g_mbrup =: 3 : 0 NB. right mouse button
  CENTER =: {. CENTERS
  if. (# CENTERS) > 1 do. CENTERS =: }. CENTERS end.
  repaint [ SCALE =: +: SCALE
)

w_g_mmove =: 3 : 0
  update_status''
)

w_g_char =: 3 : 0 NB. keypress
  if. ' ' = sysdata do.
    NB. space toggles low resolution for faster drawing
    LOWRES =: -. LOWRES
    if. LOWRES do. SCALE =: +: SCALE [ GRAIN =: +: GRAIN [ SHAPE =: -: SHAPE
    else. SCALE =: -: SCALE [ GRAIN =: -: GRAIN [ SHAPE =: +: SHAPE end.
    repaint [ render''
  end.
)

NB. == launch window and draw =====================

(3 : 0)''
  wd 'pc w closeok; minwh ', (": SHAPE * GRAIN), ';'
  wd 'pn mandelbrowse;'
  wd 'cc g isidraw;'
  wd 'cc sb statusbar; set sb addlabel text;'
  wd 'pcenter; pshow;'
  repaint [ render''
)

NB. debug verb to see just corners of a big 2d array:
corners =: [: ({.,:{:) ({.,{:)"1
