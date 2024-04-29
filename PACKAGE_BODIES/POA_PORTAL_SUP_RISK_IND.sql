--------------------------------------------------------
--  DDL for Package Body POA_PORTAL_SUP_RISK_IND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_PORTAL_SUP_RISK_IND" AS
/* $Header: poapsrdb.pls 115.3 2002/01/24 16:19:02 pkm ship      $ */

g_target_level_id number := NULL;
g_initialized_target   BOOLEAN := FALSE;
g_target_short_namet VARCHAR2(30) := 'POA_PORTAL_SUP_TOTAL_CAT';
g_target_short_namep VARCHAR2(30) := 'POA_PORTAL_SUP_PRICE_CAT';
g_target_short_nameq VARCHAR2(30) := 'POA_PORTAL_SUP_QUALITY_CAT';
g_target_short_named VARCHAR2(30) := 'POA_PORTAL_SUP_DELIVERY_CAT';
g_target_short_names VARCHAR2(30) := 'POA_PORTAL_SUP_SERVICE_CAT';
g_plan_id VARCHAR2(30) := 'STANDARD';
g_Dim1_Level_Value_ID number := 1;


g_range1_lowd number;
g_range1_highd number;
g_range2_lowd number;
g_range2_highd number;
g_range3_lowd number;
g_range3_highd number;

g_range1_lows number;
g_range1_highs number;
g_range2_lows number;
g_range2_highs number;
g_range3_lows number;
g_range3_highs number;

g_range1_lowq number;
g_range1_highq number;
g_range2_lowq number;
g_range2_highq number;
g_range3_lowq number;
g_range3_highq number;

g_range1_lowp number;
g_range1_highp number;
g_range2_lowp number;
g_range2_highp number;
g_range3_lowp number;
g_range3_highp number;

g_range1_lowt number;
g_range1_hight number;
g_range2_lowt number;
g_range2_hight number;
g_range3_lowt number;
g_range3_hight number;

PROCEDURE init_categories IS

  x_no_data_found       EXCEPTION;
  x_null_value          EXCEPTION;

vTargetRec1     BIS_TARGET_PUB.Target_Rec_Type;
vRstatus1       varchar2(1);
vErrorTbl1      BIS_UTILITIES_PUB.Error_Tbl_Type;
vTargetRec2     BIS_TARGET_PUB.Target_Rec_Type;
vRstatus2       varchar2(1);
vErrorTbl2      BIS_UTILITIES_PUB.Error_Tbl_Type;
vTargetRec3     BIS_TARGET_PUB.Target_Rec_Type;
vRstatus3       varchar2(1);
vErrorTbl3      BIS_UTILITIES_PUB.Error_Tbl_Type;
vTargetRec4     BIS_TARGET_PUB.Target_Rec_Type;
vRstatus4       varchar2(1);
vErrorTbl4      BIS_UTILITIES_PUB.Error_Tbl_Type;
vTargetRec5     BIS_TARGET_PUB.Target_Rec_Type;
vRstatus5       varchar2(1);
vErrorTbl5      BIS_UTILITIES_PUB.Error_Tbl_Type;

cursor c1 is
  select target_level_id from
  bisfv_target_levels
  where measure_short_name = g_target_short_namet;

cursor c2 is
  select target_level_id from
  bisfv_target_levels
  where measure_short_name = g_target_short_namep;

cursor c3 is
  select target_level_id from
  bisfv_target_levels
  where measure_short_name = g_target_short_nameq;

cursor c4 is
  select target_level_id from
  bisfv_target_levels
  where measure_short_name = g_target_short_named;

cursor c5 is
  select target_level_id from
  bisfv_target_levels
  where measure_short_name = g_target_short_names;

BEGIN
  OPEN c1;
  FETCH c1 into g_target_level_id;

  IF c1%NOTFOUND THEN
    CLOSE c1;
    RAISE x_no_data_found;
  END IF;

  CLOSE c1;

  vTargetRec1.Target_Level_ID := g_target_level_id;
  vTargetRec1.Plan_Short_name := g_plan_id;
  vTargetRec1.Dim1_Level_Value_ID := g_Dim1_Level_Value_ID;
  BIS_TARGET_PUB.Retrieve_Target(p_api_version => 1.0,
                                    p_Target_Rec => vTargetRec1,
                                    p_all_info => FND_API.G_FALSE,
                                    x_Target_Rec => vTargetRec1,
                                    x_return_status => vRstatus1,
                                    x_error_Tbl => vErrorTbl1);

  if vRstatus1 = FND_API.G_RET_STS_ERROR then
     RAISE x_null_value;
  else
     g_range1_lowt := vTargetRec1.Range1_low;
     g_range1_hight := vTargetRec1.Range1_high;
     g_range2_lowt := vTargetRec1.Range2_low;
     g_range2_hight := vTargetRec1.Range2_high;
     g_range3_lowt := vTargetRec1.Range3_low;
     g_range3_hight := vTargetRec1.Range3_high;
  end if;

  OPEN c2;
  FETCH c2 into g_target_level_id;

  IF c2%NOTFOUND THEN
    CLOSE c2;
    RAISE x_no_data_found;
  END IF;

  CLOSE c2;

  vTargetRec2.Target_Level_ID := g_target_level_id;
  vTargetRec2.Plan_Short_name := g_plan_id;
  vTargetRec2.Dim1_Level_Value_ID := g_Dim1_Level_Value_ID;
  BIS_TARGET_PUB.Retrieve_Target(p_api_version => 1.0,
                                    p_Target_Rec => vTargetRec2,
                                    p_all_info => FND_API.G_FALSE,
                                    x_Target_Rec => vTargetRec2,
                                    x_return_status => vRstatus2,
                                    x_error_Tbl => vErrorTbl2);

     if vRstatus2 = FND_API.G_RET_STS_ERROR then
        RAISE x_null_value;
     else
        g_range1_lowp := vTargetRec2.Range1_low;
        g_range1_highp := vTargetRec2.Range1_high;
        g_range2_lowp := vTargetRec2.Range2_low;
        g_range2_highp := vTargetRec2.Range2_high;
        g_range3_lowp := vTargetRec2.Range3_low;
        g_range3_highp := vTargetRec2.Range3_high;
     end if;

  OPEN c3;
  FETCH c3 into g_target_level_id;

  IF c3%NOTFOUND THEN
    CLOSE c3;
    RAISE x_no_data_found;
  END IF;

  CLOSE c3;

  vTargetRec3.Target_Level_ID := g_target_level_id;
  vTargetRec3.Plan_Short_name := g_plan_id;
  vTargetRec3.Dim1_Level_Value_ID := g_Dim1_Level_Value_ID;
  BIS_TARGET_PUB.Retrieve_Target(p_api_version => 1.0,
                                    p_Target_Rec => vTargetRec3,
                                    p_all_info => FND_API.G_FALSE,
                                    x_Target_Rec => vTargetRec3,
                                    x_return_status => vRstatus3,
                                    x_error_Tbl => vErrorTbl3);

     if vRstatus3 = FND_API.G_RET_STS_ERROR then
        RAISE x_null_value;
     else
        g_range1_lowq := vTargetRec3.Range1_low;
        g_range1_highq := vTargetRec3.Range1_high;
        g_range2_lowq := vTargetRec3.Range2_low;
        g_range2_highq := vTargetRec3.Range2_high;
        g_range3_lowq := vTargetRec3.Range3_low;
        g_range3_highq := vTargetRec3.Range3_high;
     end if;

  OPEN c4;
  FETCH c4 into g_target_level_id;

  IF c4%NOTFOUND THEN
    CLOSE c4;
    RAISE x_no_data_found;
  END IF;

  CLOSE c4;

  vTargetRec4.Target_Level_ID := g_target_level_id;
  vTargetRec4.Plan_Short_name := g_plan_id;
  vTargetRec4.Dim1_Level_Value_ID := g_Dim1_Level_Value_ID;
  BIS_TARGET_PUB.Retrieve_Target(p_api_version => 1.0,
                                    p_Target_Rec => vTargetRec4,
                                    p_all_info => FND_API.G_FALSE,
                                    x_Target_Rec => vTargetRec4,
                                    x_return_status => vRstatus4,
                                    x_error_Tbl => vErrorTbl4);

     if vRstatus4 = FND_API.G_RET_STS_ERROR then
        RAISE x_null_value;
     else
        g_range1_lowd := vTargetRec4.Range1_low;
        g_range1_highd := vTargetRec4.Range1_high;
        g_range2_lowd := vTargetRec4.Range2_low;
        g_range2_highd := vTargetRec4.Range2_high;
        g_range3_lowd := vTargetRec4.Range3_low;
        g_range3_highd := vTargetRec4.Range3_high;
     end if;

  OPEN c5;
  FETCH c5 into g_target_level_id;

  IF c5%NOTFOUND THEN
    CLOSE c5;
    RAISE x_no_data_found;
  END IF;

  CLOSE c5;

  vTargetRec5.Target_Level_ID := g_target_level_id;
  vTargetRec5.Plan_Short_name := g_plan_id;
  vTargetRec5.Dim1_Level_Value_ID := g_Dim1_Level_Value_ID;
  BIS_TARGET_PUB.Retrieve_Target(p_api_version => 1.0,
                                    p_Target_Rec => vTargetRec5,
                                    p_all_info => FND_API.G_FALSE,
                                    x_Target_Rec => vTargetRec5,
                                    x_return_status => vRstatus5,
                                    x_error_Tbl => vErrorTbl5);

     if vRstatus5 = FND_API.G_RET_STS_ERROR then
        RAISE x_null_value;
     else
        g_range1_lows := vTargetRec5.Range1_low;
        g_range1_highs := vTargetRec5.Range1_high;
        g_range2_lows := vTargetRec5.Range2_low;
        g_range2_highs := vTargetRec5.Range2_high;
        g_range3_lows := vTargetRec5.Range3_low;
        g_range3_highs := vTargetRec5.Range3_high;
     end if;

  g_initialized_target := TRUE;

exception
  when x_no_data_found then
        raise_application_error(-20000, 'No data found');
  when x_null_value then
        raise_application_error(-20001, 'Null Values' || g_target_level_id ||
             g_plan_id);
  when others then
        if c1%ISOPEN then
                close c1;
        end if;
        raise_application_error(-20002, 'Other Error');
end init_categories;


FUNCTION get_target_level_id return number IS
BEGIN
  IF (NOT g_initialized_target) THEN
    init_categories;
  END IF;
  RETURN(g_target_level_id);
END get_target_level_id;


FUNCTION get_range1_low(Id IN Number) return number IS
BEGIN
  IF (NOT g_initialized_target) THEN
    init_categories;
  END IF;

  if (id = 1) THEN
    RETURN(g_range1_lowt);
  ELSIF (id = 2) THEN
    RETURN(g_range1_lowp);
  ELSIF (id = 3) THEN
    RETURN(g_range1_lowq);
  ELSIF (id = 4) THEN
    RETURN(g_range1_lowd);
  ELSIF (id = 5) THEN
    RETURN(g_range1_lows);
  END IF;

 RETURN(g_range1_lowt);

END get_range1_low;

FUNCTION get_range1_high(Id IN Number) return number IS
BEGIN
  IF (NOT g_initialized_target) THEN
    init_categories;
  END IF;

  IF (id = 1) THEN
    RETURN(g_range1_hight);
  ELSIF (id =2) THEN
    RETURN(g_range1_highp);
  ELSIF (id = 3) THEN
    RETURN(g_range1_highq);
  ELSIF (id = 4) THEN
    RETURN(g_range1_highd);
  ELSIF (id = 5) THEN
    RETURN(g_range1_highs);
  END IF;

  RETURN(g_range1_hight);

END get_range1_high;

FUNCTION get_range2_low(Id IN Number) return number IS
BEGIN
  IF (NOT g_initialized_target) THEN
    init_categories;
  END IF;
  IF (id = 1) THEN
    RETURN(g_range2_lowt);
  ELSIF (id = 2) THEN
    RETURN(g_range2_lowp);
  ELSIF (id = 3) THEN
    RETURN(g_range2_lowq);
  ELSIF (id = 4) THEN
    RETURN(g_range2_lowd);
  ELSIF (id = 5) THEN
    RETURN(g_range2_lows);
  END IF;

  RETURN(g_range2_lowt);
END get_range2_low;

FUNCTION get_range2_high(Id IN Number) return number IS
BEGIN
  IF (NOT g_initialized_target) THEN
    init_categories;
  END IF;
  IF (id = 1) THEN
    RETURN(g_range2_hight);
  ELSIF (id = 2) THEN
    RETURN(g_range2_highp);
  ELSIF (id = 3) THEN
    RETURN(g_range2_highq);
  ELSIF (id = 4) THEN
    RETURN(g_range2_highd);
  ELSIF (id = 5) THEN
    RETURN(g_range2_highs);
  END IF;

  RETURN(g_range2_hight);
END get_range2_high;

FUNCTION get_range3_low(Id IN Number) return number IS
BEGIN
  IF (NOT g_initialized_target) THEN
    init_categories;
  END IF;
  IF (id = 1) THEN
    RETURN(g_range3_lowt);
  ELSIF (id = 2) THEN
    RETURN(g_range3_lowp);
  ELSIF (id = 3) THEN
    RETURN(g_range3_lowq);
  ELSIF (id = 4) THEN
    RETURN(g_range3_lowd);
  ELSIF (id = 5) THEN
    RETURN(g_range3_lows);
  END IF;

  RETURN(g_range3_lowt);
END get_range3_low;

FUNCTION get_range3_high(Id IN Number) return number IS
BEGIN
  IF (NOT g_initialized_target) THEN
    init_categories;
  END IF;
 IF (id =1) THEN
    RETURN(g_range3_hight);
  ELSIF (id = 2) THEN
    RETURN(g_range3_highp);
  ELSIF (id = 3) THEN
    RETURN(g_range3_highq);
  ELSIF (id = 4) THEN
    RETURN(g_range3_highd);
  ELSIF (id = 5) THEN
    RETURN(g_range3_highs);
  END IF;

  RETURN(g_range3_hight);
END get_range3_high;

end;


/
