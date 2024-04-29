--------------------------------------------------------
--  DDL for Package Body CST_BIS_ALERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_BIS_ALERT" AS
/* $Header: CSTBIALB.pls 120.1 2005/10/04 17:58:41 julzhang noship $ */



FUNCTION GET_SEGMENT( str IN VARCHAR2,
                      delim IN VARCHAR2,
                      segment_num IN NUMBER ) RETURN VARCHAR2 IS
BEGIN
    return 'null';
END Get_Segment;






/*
 * Notify
 *   Spawns the Workflow process.
 */

procedure Notify( p_measure_short_name in varchar2,
                  p_target_level_id in number,
                  notify_resp_short_name in varchar2,
                  p_plan_id in number,
                  time_level_value_id in varchar2,
                  org_level_value_id in varchar2,
                  dim1_level_value_id in varchar2,
                  dim2_level_value_id in varchar2,
                  dim3_level_value_id in varchar2,
                  target in number,
                  actual_value in number,
                  time_level in number,
                  org_level in number,
                  dim1_level in number,
                  dim2_level in number,
                  dim3_level in number,
                  target_min in number,
                  target_max in number )
is

begin

    return;

end Notify;





/*
 * PostActual
 *   Called by Alert_Check to post actuals to the BIS table.
 *   The posting is done by calling BIS API (BIS_ACTUAL_PUB).
 */

PROCEDURE PostActual( target_level_id  in number,
                      time_value in varchar2,
                      org_value  in varchar2,
                      dim1_value in varchar2,
                      dim2_value in varchar2,
                      dim3_value in varchar2,
                      dim4_value in varchar2,
                      dim5_value in varchar2,
                      time_level in number,
                      org_level  in number,
                      dim1_level in number,
                      dim2_level in number,
                      dim3_level in number,
                      dim4_level in number,
                      dim5_level in number,
                      actual     in number ) IS
BEGIN

    return;

END PostActual;



/*
 * PostLevelActuals
 *   Will post all actuals for the given dim level combination.
 *   The dim level should be 0 for ALL, and increasing for
 *   finer levels.
 *   e.g.
 *     time_level = 0 : TOTAL_TIME
 *     time_level = 1 : YEAR
 *     time_level = 2 : QUARTER
 *     time_level = 3 : MONTH
 */

PROCEDURE PostLevelActuals( p_measure_short_name in varchar2,
                            target_level_id  in number,
                            time_level       in number,
                            org_level        in number,
                            dim1_level in number,
                            dim2_level in number,
                            dim3_level in number,
                            dim4_level in number,
                            dim5_level in number ) IS

BEGIN

    return;

END PostLevelActuals;




procedure PostMeasureActuals( p_measure_short_name in varchar2 )
is
begin

    return;

end PostMeasureActuals;




PROCEDURE CompareLevelTargets( p_measure_short_name in varchar2,
                               target_level_id  in number,
                               time_level       in number,
                               org_level        in number,
                               dim1_level in number,
                               dim2_level in number,
                               dim3_level in number,
                               dim4_level in number,
                               dim5_level in number )
IS

begin

    return;

end CompareLevelTargets;





procedure CompareMeasureTargets( p_measure_short_name in varchar2 )
is
begin

    return;

end CompareMeasureTargets;





procedure Alert_Check( p_measure_short_name in varchar2 )
is
begin

    return;

end Alert_Check;




END CST_BIS_ALERT;

/
