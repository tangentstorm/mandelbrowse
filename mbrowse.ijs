NB. -----------------------------------------------
NB.
NB. Mandelbrowse
NB.
NB. A visual Mandelbrot set explorer written in J.
NB. See README.md for instructions.
NB. -----------------------------------------------
NB. Copyright © 2016 Michal J Wallace
NB. Available for public use under the MIT license.
NB. -----------------------------------------------


NB. == dependencies ===============================
coclass 'mbrowse'
coinsert'jviewmat' [ load 'viewmat'

NB. !! this is a workaround for a j8 bug (as of 01/02/2016)
NB. (without this fix, it won't redraw the viewmat control)
viewmatcc =: glpaint_jgl2_@viewmatcc_jviewmat_

NB. verb to convert space-separated hex strings into rgb triples:
rgb =: (3$256) #: [: dfh;._1 ' ',]

NB. == configuration ==============================

reset =: 3 : 0
  ITERS =: 24              NB. # of iterations of the formula.
  CENTER =: _1j0           NB. center of the view
  SHAPE =: 160 120         NB. width, height of the data array
  GRAIN =: 4               NB. pixels per array entry
  STEP  =: {. 4 3 % SHAPE  NB. initial step between array units
  SCALE =: 1               NB. user zoom factor
  CENTERS =: ,CENTER       NB. stack of center values
  HIRES =: 0               NB. toggle with space key for high resolution
)

NB. color scheme: black, white, golds and blues
pal =: rgb '0 ffffff ffd21d b28f00 400fe8 1d2799 000055 000033'

NB. == mandelbrot verbs ===========================

NB. mbrot y  → 0 if bounded
NB. else number of iterations where value was > 2
iters =: 1 : 0
  NB. calling 'm iters' rebuilds the 'mbrot' verb.
  NB. (you can't define verbs inside a verb so it has to be an adverb)
  ITERS =: m
  mbrot =: [: +/ 2 <&| ((+ *:) :: _:)"0^:(<ITERS) & 0
)

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

mw =: 3 : 0  NB. mouse position in world cordinates
  mxy =. 2 {. _".sysdata
  c2w j./ GRAIN (<.@%)~ mxy
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
  cn =. ' center: ', ": +. CENTER
  hl =. ' [', ' res] ',~ > HIRES { 'lo';'hi'
  it =. ' iterations: ', ": ITERS
  wd 'set sb setlabel text "', hl, it, sc, cn, mp, '";'
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

w_g_char =: 3 : 0 NB. keypress handler
  select. {. sysdata NB. head so we can compare against individual characters

  NB. space toggles low resolution for faster drawing
  case. ' ' do.
    HIRES =: -. HIRES
    if. HIRES do. SCALE =: -: SCALE [ GRAIN =: -: GRAIN [ SHAPE =: +: SHAPE
    else.  SCALE =: +: SCALE [ GRAIN =: +: GRAIN [ SHAPE =: -: SHAPE end.

  NB. +/- key change number of iterations, to change level of detail
  case. '+' do. (ITERS + 8) iters
  case. '-' do. (1 >. ITERS - 8) iters
  end.

  repaint [ render''
)

NB. == launch window and draw =====================

create =: (3 : 0)
  reset''
  ITERS iters
  wd 'pc w closeok; minwh ', (": SHAPE * GRAIN), ';'
  wd 'pn mandelbrowse;'
  wd 'cc g isidraw;'
  wd 'cc sb statusbar; set sb addlabel text;'
  wd 'pcenter; pshow;'
  repaint [ render''
)

NB. debug verb to see just corners of a big 2d array:
corners =: [: ({.,:{:) ({.,{:)"1


NB. Register a global constructor, so you can launch like this:
NB.
NB.     m =: mbrowse''
NB.
NB. You can then type `cocurrent > m` to enter the application's locale in the J terminal.
NB.
NB. Once you've closed the window, you can type `cocurrent 'base'`
NB. (to re-enter the default locale), and then `codestroy__m''` to
NB. destroy the object.
NB.
mbrowse_z_ =: conew & 'mbrowse'
