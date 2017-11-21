/*
---------------------------------------------------------
----         Bezier Curve Library v1.21 (BASIC)      ----
----            By Clonkex aka David Hynd            ----
----           Created 12/03/14 - 11/04/14           ----
---------------------------------------------------------

Legal:

Do what you want with it. Have fun! xD


Changes:

[20/03/14] 1.0  - Public release
[21/03/14] 1.1  - Fixed closed curves (so they actually work and all that)
[22/03/14] 1.11 - Tiny eency little fix (forgot to change an X to a Y)
[22/03/14] 1.2  - Fixed some floats not being floats and wrote the C++ version of the library
[11/04/14] 1.21 - Fixed some bugs in the C++ version related to for-loops


Usage:

Coming soon (i.e. when I feel like writing it). For now look at the example.


Function list:

BC_AddCurvePoint(posx#,posy#)                  -- Adds a new point to the curve at the specified position
BC_RemoveCurvePoints()                         -- Removes all points from the curve
BC_CalculatePointOnOpenCurve(t#)               -- Finds a point on the curve from distance along it in a range of 0-1; calculates an open-ended curve
BC_CalculatePointOnClosedCurve(t#)             -- Finds a point on the curve from distance along it in a range of 0-1; calculates a closed curve
BC_GetCurvePointCount()                        -- Returns the number of points currently making up the curve
BC_GetCurvePointX()                            -- Returns the last calculated position from BC_CalculatePointOnXXXCurve()
BC_GetCurvePointY()                            -- Returns the last calculated position from BC_CalculatePointOnXXXCurve()
BC_CalculateClosestPointToCurve(x#,y#)         -- Finds the closest point on the curve to the position; call BC_CalculateXXXCurveSegmentPoints() first!
BC_GetClosestPointX()                          -- Returns the last calculated closest position from BC_CalculateClosestPointToCurve()
BC_GetClosestPointY()                          -- Returns the last calculated closest position from BC_CalculateClosestPointToCurve()
BC_GetClosestPointDistance()                   -- Returns the distance to the last calculated closest position from BC_CalculateClosestPointToCurve()
BC_GetClosestPointIndex()                      -- Returns the index of the last calculated segment point from BC_CalculateClosestPointToCurve()
BC_SetCurveSegmentPointCount(count)            -- Sets how many segment points should be created from the curve
BC_GetCurveSegmentPointCount()                 -- Returns the number generated of segment points
BC_GetCurveSegmentPointX(index)                -- Returns the position of a specific segment point
BC_GetCurveSegmentPointY(index)                -- Returns the position of a specific segment point
BC_CalculateOpenCurveSegmentPoints()           -- Cuts up a curve into a set number of points (segment points) making straight lines
BC_CalculateClosedCurveSegmentPoints()         -- Cuts up a curve into a set number of points (segment points) making straight lines
BC_Distance(x1#,y1#,x2#,y2#)                   -- Used internally; calculates the distance between two 2D points
BC_PointOnLineX(x1#,y1#,x2#,y2#,percent#)      -- Used internally; calculates a position based on a distance along a 2D line
BC_PointOnLineY(x1#,y1#,x2#,y2#,percent#)      -- Used internally; calculates a position based on a distance along a 2D line

*/


_BC_Setup:
global bc_lastcurvepointx#=0.0
global bc_lastcurvepointy#=0.0
global bc_curvepointcount=0
global bc_distanceiterations=50
global bc_closestdistance#=0.0
global bc_closestpointx#=0.0
global bc_closestpointy#=0.0
global bc_closestindex=0
global bc_curvesegmentpointcount=0
type bc_curvepointinfo
 posx# as float
 posy# as float
endtype
type bc_curvesegmentpointinfo
 posx# as float
 posy# as float
endtype
dim bc_curvepoint[0] as bc_curvepointinfo
dim bc_curvesegmentpoint[0] as bc_curvesegmentpointinfo
return

function BC_AddCurvePoint(posx#,posy#)
 bc_curvepointcount=bc_curvepointcount+1
 dim bc_curvepoint[bc_curvepointcount] as bc_curvepointinfo
 bc_curvepoint[bc_curvepointcount-1].posx#=posx#
 bc_curvepoint[bc_curvepointcount-1].posy#=posy#
endfunction

function BC_RemoveCurvePoints()
 bc_curvepointcount=0
 dim bc_curvepoint[bc_curvepointcount] as bc_curvepointinfo
 bc_curvesegmentpointcount=0
 dim bc_curvesegmentpoint[bc_curvesegmentpointcount] as bc_curvesegmentpointinfo
endfunction

function BC_CalculatePointOnOpenCurve(t#) //t# is the percentage of the way along the line in a range of 0-1
 if bc_curvepointcount>1
	totalt# as float
  totalt#=t#*(bc_curvepointcount-1)
  i as integer
  i=trunc(totalt#)
  realt# as float
  realt#=totalt#-i
  p1posx# as float
  p1posy# as float
  p2posx# as float
  p2posy# as float
  p1posx#=bc_pointonlinex(bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,0.3333)
  p1posy#=bc_pointonliney(bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,0.3333)
  p2posx#=bc_pointonlinex(bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,0.3333)
  p2posy#=bc_pointonliney(bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,0.3333)
  
  p0posx# as float
  p0posy# as float
  if i=0
   p0posx#=bc_curvepoint[i].posx#
   p0posy#=bc_curvepoint[i].posy#
  else
   tempx#=bc_pointonlinex(bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,bc_curvepoint[i-1].posx#,bc_curvepoint[i-1].posy#,0.3333)
   tempy#=bc_pointonliney(bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,bc_curvepoint[i-1].posx#,bc_curvepoint[i-1].posy#,0.3333)
   p0posx#=bc_pointonlinex(tempx#,tempy#,p1posx#,p1posy#,0.5)
   p0posy#=bc_pointonliney(tempx#,tempy#,p1posx#,p1posy#,0.5)
  endif
  if i=bc_curvepointcount-2
   p3posx#=bc_curvepoint[i+1].posx#
   p3posy#=bc_curvepoint[i+1].posy#
  else
   tempx#=bc_pointonlinex(bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,bc_curvepoint[i+2].posx#,bc_curvepoint[i+2].posy#,0.3333)
   tempy#=bc_pointonliney(bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,bc_curvepoint[i+2].posx#,bc_curvepoint[i+2].posy#,0.3333)
   p3posx#=bc_pointonlinex(p2posx#,p2posy#,tempx#,tempy#,0.5)
   p3posy#=bc_pointonliney(p2posx#,p2posy#,tempx#,tempy#,0.5)
  endif
  //begin calculations (conveniently adapted from http://devmag.org.za/2011/04/05/bzier-curves-a-tutorial/):
  u#=1-realt#
  tt#=realt#*realt#
  uu#=u#*u#
  uuu#=uu#*u#
  ttt#=tt#*realt#
  bc_lastcurvepointx#=uuu#*p0posx# //first term
  bc_lastcurvepointy#=uuu#*p0posy# //first term
  bc_lastcurvepointx#=bc_lastcurvepointx#+3*uu#*realt#*p1posx# //second term
  bc_lastcurvepointy#=bc_lastcurvepointy#+3*uu#*realt#*p1posy# //second term
  bc_lastcurvepointx#=bc_lastcurvepointx#+3*u#*tt#*p2posx# //third term
  bc_lastcurvepointy#=bc_lastcurvepointy#+3*u#*tt#*p2posy# //third term
  bc_lastcurvepointx#=bc_lastcurvepointx#+ttt#*p3posx# //fourth term
  bc_lastcurvepointy#=bc_lastcurvepointy#+ttt#*p3posy# //fourth term
 else
  if bc_curvepointcount>0
   bc_lastcurvepointx#=bc_curvepoint[0].posx#
   bc_lastcurvepointy#=bc_curvepoint[0].posy#
  else
   message("Bezier Curve Library: Tried to calculate a curve with no points! You douchebag!")
   end
  endif
 endif
endfunction

function BC_CalculatePointOnClosedCurve(t#) //t# is the percentage of the way along the line in a range of 0-1
 if bc_curvepointcount>1
	 totalt# as float
  totalt#=t#*bc_curvepointcount
  i as integer
  i=trunc(totalt#)
  realt# as float
  realt#=totalt#-i
   p1posx# as float
    p1posy# as float
    p2posx# as float
    p2posy# as float
  if i=bc_curvepointcount-1
   p1posx#=bc_pointonlinex(bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,bc_curvepoint[0].posx#,bc_curvepoint[0].posy#,0.3333)
   p1posy#=bc_pointonliney(bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,bc_curvepoint[0].posx#,bc_curvepoint[0].posy#,0.3333)
   p2posx#=bc_pointonlinex(bc_curvepoint[0].posx#,bc_curvepoint[0].posy#,bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,0.3333)
   p2posy#=bc_pointonliney(bc_curvepoint[0].posx#,bc_curvepoint[0].posy#,bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,0.3333)
  else
   p1posx#=bc_pointonlinex(bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,0.3333)
   p1posy#=bc_pointonliney(bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,0.3333)
   p2posx#=bc_pointonlinex(bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,0.3333)
   p2posy#=bc_pointonliney(bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,0.3333)
  endif
  tempx# as float
  tempy# as float
  p0posx# as float
  p0posy# as float
  if i=0
   tempx#=bc_pointonlinex(bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,bc_curvepoint[bc_curvepointcount-1].posx#,bc_curvepoint[bc_curvepointcount-1].posy#,0.3333)
   tempy#=bc_pointonliney(bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,bc_curvepoint[bc_curvepointcount-1].posx#,bc_curvepoint[bc_curvepointcount-1].posy#,0.3333)
   p0posx#=bc_pointonlinex(tempx#,tempy#,p1posx#,p1posy#,0.5)
   p0posy#=bc_pointonliney(tempx#,tempy#,p1posx#,p1posy#,0.5)
  else
   tempx#=bc_pointonlinex(bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,bc_curvepoint[i-1].posx#,bc_curvepoint[i-1].posy#,0.3333)
   tempy#=bc_pointonliney(bc_curvepoint[i].posx#,bc_curvepoint[i].posy#,bc_curvepoint[i-1].posx#,bc_curvepoint[i-1].posy#,0.3333)
   p0posx#=bc_pointonlinex(tempx#,tempy#,p1posx#,p1posy#,0.5)
   p0posy#=bc_pointonliney(tempx#,tempy#,p1posx#,p1posy#,0.5)
  endif
  p3posx# as float
  p3posy# as float
  if i=bc_curvepointcount-2
   tempx#=bc_pointonlinex(bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,bc_curvepoint[0].posx#,bc_curvepoint[0].posy#,0.3333)
   tempy#=bc_pointonliney(bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,bc_curvepoint[0].posx#,bc_curvepoint[0].posy#,0.3333)
   p3posx#=bc_pointonlinex(p2posx#,p2posy#,tempx#,tempy#,0.5)
   p3posy#=bc_pointonliney(p2posx#,p2posy#,tempx#,tempy#,0.5)
  else
   if i=bc_curvepointcount-1
    tempx#=bc_pointonlinex(bc_curvepoint[0].posx#,bc_curvepoint[0].posy#,bc_curvepoint[1].posx#,bc_curvepoint[1].posy#,0.3333)
    tempy#=bc_pointonliney(bc_curvepoint[0].posx#,bc_curvepoint[0].posy#,bc_curvepoint[1].posx#,bc_curvepoint[1].posy#,0.3333)
    p3posx#=bc_pointonlinex(p2posx#,p2posy#,tempx#,tempy#,0.5)
    p3posy#=bc_pointonliney(p2posx#,p2posy#,tempx#,tempy#,0.5)
   else
    tempx#=bc_pointonlinex(bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,bc_curvepoint[i+2].posx#,bc_curvepoint[i+2].posy#,0.3333)
    tempy#=bc_pointonliney(bc_curvepoint[i+1].posx#,bc_curvepoint[i+1].posy#,bc_curvepoint[i+2].posx#,bc_curvepoint[i+2].posy#,0.3333)
    p3posx#=bc_pointonlinex(p2posx#,p2posy#,tempx#,tempy#,0.5)
    p3posy#=bc_pointonliney(p2posx#,p2posy#,tempx#,tempy#,0.5)
   endif
  endif
  //begin calculations (conveniently adapted from http://devmag.org.za/2011/04/05/bzier-curves-a-tutorial/):
  u# as float
  u#=1-realt#
  tt# as float
  tt#=realt#*realt#
  uu# as float
  uu#=u#*u#
  uuu# as float
  uuu#=uu#*u#
  ttt# as float
  ttt#=tt#*realt#
  bc_lastcurvepointx#=uuu#*p0posx# //first term
  bc_lastcurvepointy#=uuu#*p0posy# //first term
  bc_lastcurvepointx#=bc_lastcurvepointx#+3*uu#*realt#*p1posx# //second term
  bc_lastcurvepointy#=bc_lastcurvepointy#+3*uu#*realt#*p1posy# //second term
  bc_lastcurvepointx#=bc_lastcurvepointx#+3*u#*tt#*p2posx# //third term
  bc_lastcurvepointy#=bc_lastcurvepointy#+3*u#*tt#*p2posy# //third term
  bc_lastcurvepointx#=bc_lastcurvepointx#+ttt#*p3posx# //fourth term
  bc_lastcurvepointy#=bc_lastcurvepointy#+ttt#*p3posy# //fourth term
 else
  if bc_curvepointcount>0
   bc_lastcurvepointx#=bc_curvepoint[0].posx#
   bc_lastcurvepointy#=bc_curvepoint[0].posy#
  else
   message("Bezier Curve Library: Tried to calculate a curve with no points! You douchebag!")
   end
  endif
 endif
endfunction

function BC_GetCurvePointCount()
endfunction bc_curvepointcount

function BC_GetCurvePointX()
endfunction bc_lastcurvepointx#

function BC_GetCurvePointY()
endfunction bc_lastcurvepointy#

function BC_CalculateClosestPointToCurve(posx#,posy#) //x# and y# are the point from which we're searching
 bc_closestdistance#=1000000 //hack, but basically could never be larger than this anyway
 distance# as float
 if bc_curvepointcount>0
  bc_closestpointx#=0
  bc_closestpointy#=0
  i as integer
  for i=0 to bc_distanceiterations-1
   distance#=bc_distance(posx#,posy#,bc_curvesegmentpoint[i].posx#,bc_curvesegmentpoint[i].posy#)
   if distance#<bc_closestdistance#
    bc_closestdistance#=distance#
    bc_closestpointx#=bc_curvesegmentpoint[i].posx#
    bc_closestpointy#=bc_curvesegmentpoint[i].posy#
    bc_closestindex=i
   endif
  next i
 else
  bc_closestpointx#=0
  bc_closestpointy#=0
 endif
endfunction

function BC_GetClosestPointX()
endfunction bc_closestpointx#

function BC_GetClosestPointY()
endfunction bc_closestpointy#

function BC_GetClosestPointDistance()
endfunction bc_closestdistance#

function BC_GetClosestPointIndex()
endfunction bc_closestindex

function BC_SetCurveSegmentPointCount(count)
 bc_distanceiterations=count
endfunction

function BC_GetCurveSegmentPointCount()
endfunction bc_curvesegmentpointcount

function BC_GetCurveSegmentPointX(index)
x# as float
 x#=bc_curvesegmentpoint[index].posx#
endfunction x#

function BC_GetCurveSegmentPointY(index)
	y# as float
 y#=bc_curvesegmentpoint[index].posy#
endfunction y#

function BC_CalculateOpenCurveSegmentPoints()
 bc_curvesegmentpointcount=bc_distanceiterations
 dim bc_curvesegmentpoint[bc_curvesegmentpointcount] as bc_curvesegmentpointinfo
 if bc_curvepointcount>0
	add# as float
  add#=1.0/bc_distanceiterations
  t# as float
  t#=0
  i as integer
  for i=0 to bc_curvesegmentpointcount-1
   bc_calculatepointonopencurve(t#)
   bc_curvesegmentpoint[i].posx#=bc_lastcurvepointx#
   bc_curvesegmentpoint[i].posy#=bc_lastcurvepointy#
   t#=t#+add#
  next i
 endif
endfunction

function BC_CalculateClosedCurveSegmentPoints()
 bc_curvesegmentpointcount=bc_distanceiterations
 dim bc_curvesegmentpoint[bc_curvesegmentpointcount] as bc_curvesegmentpointinfo
 
 if bc_curvepointcount>0
  add# as float
  add# =1.0/bc_distanceiterations
  t# as float=0
  i as integer
  for i=0 to bc_curvesegmentpointcount-1
   if i=bc_distanceiterations-1 then t#=0.9999999
   bc_calculatepointonclosedcurve(t#)
   bc_curvesegmentpoint[i].posx#=bc_lastcurvepointx#
   bc_curvesegmentpoint[i].posy#=bc_lastcurvepointy#
   t#=t#+add#
  next i
 endif
endfunction

function BC_Distance(x1#,y1#,x2#,y2#)
 distance# as float
 dx#=x1#-x2#
 dy#=y1#-y2#
 distance#=sqrt(dx#*dx#+dy#*dy#)
endfunction distance#

function BC_PointOnLineX(x1#,y1#,x2#,y2#,percent#)
 px# as float
 px#=x1#+((x2#-x1#)*percent#)
endfunction px#

function BC_PointOnLineY(x1#,y1#,x2#,y2#,percent#)
py# as float
 py#=y1#+((y2#-y1#)*percent#)
endfunction py#
