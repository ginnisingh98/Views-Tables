--------------------------------------------------------
--  DDL for Package Body BIS_BIA_RSG_CUSTOM_API_MGMNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BIA_RSG_CUSTOM_API_MGMNT" AS
/*$Header: BISCAPIB.pls 120.1 2005/07/12 16:37:48 tiwang noship $*/

PROCEDURE DEBUG(
  P_TEXT VARCHAR2
, P_IDENT NUMBER DEFAULT 3)
IS
BEGIN
  BIS_COLLECTION_UTILITIES.debug(P_TEXT, P_IDENT);
  --DBMS_OUTPUT.PUT_LINE(P_TEXT);
END;

PROCEDURE LOG(
  P_TEXT VARCHAR2 )
IS
BEGIN
  BIS_COLLECTION_UTILITIES.put_line('   ' || P_TEXT);
  --DBMS_OUTPUT.PUT_LINE(P_TEXT);
END;


PROCEDURE OUTPUT_PARAM (
    p_parameter_tbl IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL
) IS
  l_name            varchar2(32767);
  l_value           varchar2(32767);
BEGIN
  FOR i IN 1..p_parameter_tbl.count LOOP
         l_name  := p_parameter_tbl(i).parameter_name;
         l_value := p_parameter_tbl(i).parameter_value;
         DEBUG( '( name, value) = (' || l_name ||', ' || l_value ||')' );
  END LOOP;
END;


PROCEDURE ADD_PARAM (
     p_parameter_tbl 	   IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL,
     p_param_name          IN VARCHAR2,
     p_param_value         IN VARCHAR2
) IS
  l_parameter_rec   BIS_BIA_RSG_PARAMETER_REC := BIS_BIA_RSG_PARAMETER_REC(TO_CHAR(null),TO_CHAR(null));
BEGIN
  l_parameter_rec.parameter_name  := p_param_name;
  l_parameter_rec.parameter_value := p_param_value;
  p_parameter_tbl.extend;
  p_parameter_tbl(p_parameter_tbl.LAST) := l_parameter_rec;

  DEBUG('Added Parameter ('|| p_param_name ||', ' || p_param_value || ')' );

END;

FUNCTION GET_PARAM (
     p_parameter_tbl 	   IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL,
     p_param_name          IN VARCHAR2
) RETURN VARCHAR2
IS
  l_parameter_rec   BIS_BIA_RSG_PARAMETER_REC := BIS_BIA_RSG_PARAMETER_REC(TO_CHAR(null),TO_CHAR(null));
  l_name            varchar2(32767);
  l_value           varchar2(32767) := null;
BEGIN
  FOR i IN 1..p_parameter_tbl.count LOOP
    if p_param_name = p_parameter_tbl(i).parameter_name then
       l_value := p_parameter_tbl(i).parameter_value;
       LOG('Retrieved Parameter ('|| p_param_name ||', ' || l_value || ')' );
       EXIT;
    end if;
  END LOOP;
  return l_value;
END;


PROCEDURE SET_PARAM (
     p_parameter_tbl 	   IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL,
     p_param_name          IN VARCHAR2,
     p_param_value         IN VARCHAR2
) IS
  l_parameter_rec   BIS_BIA_RSG_PARAMETER_REC := BIS_BIA_RSG_PARAMETER_REC(TO_CHAR(null),TO_CHAR(null));
  l_name            varchar2(32767);
  l_value            varchar2(32767);
BEGIN
  FOR i IN 1..p_parameter_tbl.count LOOP
         l_name  := p_parameter_tbl(i).parameter_name;
         l_value := p_parameter_tbl(i).parameter_value;

         if l_name = p_param_name then
            p_parameter_tbl(i).parameter_value := p_param_value;
            LOG('Value of ' || l_name || ' was changed from ' || NVL(l_value, 'NULL') || ' to ' || p_parameter_tbl(i).parameter_value);
         end if;

  END LOOP;
END;


PROCEDURE INIT_PARAMS (
    p_parameter_tbl IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL,
    P_API_TYPE      IN 	VARCHAR2,
    P_OBJ_NAME      IN 	VARCHAR2,
    P_OBJ_TYPE      IN 	VARCHAR2,
    P_MODE          IN 	VARCHAR2,
    P_MV_REF_METHOD IN  VARCHAR2
) IS
  l_parameter_rec   BIS_BIA_RSG_PARAMETER_REC := BIS_BIA_RSG_PARAMETER_REC(TO_CHAR(null),TO_CHAR(null));
BEGIN
  /*
    'MV_LOG_MGT'-----Drop and create MV log
    'MV_INDEX_MGT'---Drop and create MV index
    'MV_THRESHOLD'---Using threshold at runtime to decide the MV refresh method
    This parameter value will be passed in the custom API
  */
  ADD_PARAM(p_parameter_tbl, PARA_API_TYPE, P_API_TYPE );
  /*
    'BEFORE'-----Calling the API before the MV or table refresh
    'AFTER'---Calling the API after the MV or table refresh
    This parameter value will be passed in the custom API
  */
  ADD_PARAM(p_parameter_tbl, PARA_MODE, P_MODE );
  /*
    The table or MV name
    This parameter value will be passed in the custom API
  */
  ADD_PARAM(p_parameter_tbl, PARA_OBJECT_NAME, P_OBJ_NAME ) ; --'BIS_TEST_TABLE' );
  /*
    'TABLE' or 'MV'
    This parameter value will be passed in the custom API
  */
  ADD_PARAM(p_parameter_tbl, PARA_OBJECT_TYPE, P_OBJ_TYPE) ; --'TABLE'  );
  /*
    This is an in/out parameter. ---modified for enhancement 4423644
    The custom API can code logic based on this value OR set value for it.
    After checking the threshold, if the MV should be complete refreshed,
    then the parameter value is 'COMPLETE', otherwise the value is 'FAST'
  */
  ADD_PARAM(p_parameter_tbl, PARA_MV_REFRESH_METHOD, P_MV_REF_METHOD);
  /*
   This is an out parameter.
   The custom API will set value for it based on if the process is successful or not
   It has value
     0---success
     1-failure
     null---the logic has not been implemented
  */
  ADD_PARAM(p_parameter_tbl, PARA_COMPLETE_STATUS, TO_CHAR(null) );
  /*
    This is an out parameter.
    The custom API will set value for it if the above status has value 1---failure
  */
  ADD_PARAM(p_parameter_tbl, PARA_MESSAGE, TO_CHAR(null) );

END;

PROCEDURE INVOKE_API_DYNAMICALLY (
    p_parameter_tbl IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL,
    P_API 	        IN 	VARCHAR2
) IS
  l_dynamic_sql     varchar2(32767);
BEGIN
  l_dynamic_sql := 'BEGIN '|| P_API ||' (:1); END;';
  LOG('Executing ' || l_dynamic_sql);
  LOG('************entering '||P_API||'*********************************');
  execute immediate l_dynamic_sql using IN OUT p_parameter_tbl ;
  LOG('************end of '||P_API||'*********************************');

EXCEPTION WHEN OTHERS THEN
  LOG('CUSTOM API Error!!!!!');
  LOG(sqlerrm);
  RAISE;
END;

PROCEDURE INVOKE_CUSTOM_API (
    RTNBUF  		IN OUT NOCOPY VARCHAR2,
    RETCODE		    OUT NOCOPY VARCHAR2,
    P_API 	        IN 	VARCHAR2,
    P_API_TYPE      IN 	VARCHAR2,
    P_OBJ_NAME      IN 	VARCHAR2,
    P_OBJ_TYPE      IN 	VARCHAR2,
    P_MODE          IN 	VARCHAR2
) IS
  l_parameter_tbl   BIS_BIA_RSG_PARAMETER_TBL := BIS_BIA_RSG_PARAMETER_TBL();
  l_complete_status VARCHAR2(32767);
  l_mv_refresh_method VARCHAR2(32767);
  l_message  VARCHAR2(32767);
  l_api      VARCHAR2(32767);
BEGIN
  l_api := P_API;

  if (l_api is null) then
    select custom_api into l_api
    from bis_obj_properties
    where object_name = P_OBJ_NAME
    and object_type = P_OBJ_TYPE;
  end if;

  IF (BIS_COLLECTION_UTILITIES.g_object_name is NULL) THEN
    IF (Not BIS_COLLECTION_UTILITIES.setup(l_API)) THEN
      RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || sqlerrm);
      return;
    END IF;
  END IF;

  INIT_PARAMS(l_parameter_tbl, P_API_TYPE, P_OBJ_NAME, P_OBJ_TYPE, P_MODE,RTNBUF);
  if (l_api is null) then
    LOG('no custime API defined in RSG for ' || P_OBJ_NAME );
    return;
  end if;

  ---LOG('Before calling ' || l_api );
  INVOKE_API_DYNAMICALLY(l_parameter_tbl, l_api);
  ---  LOG('After calling ' || l_api );
  OUTPUT_PARAM(l_parameter_tbl);

  l_complete_status := GET_PARAM(l_parameter_tbl, PARA_COMPLETE_STATUS);
  l_message := GET_PARAM(l_parameter_tbl, PARA_MESSAGE);
  l_mv_refresh_method := GET_PARAM(l_parameter_tbl, PARA_MV_REFRESH_METHOD);

  RTNBUF := l_mv_refresh_method;
  RETCODE := l_complete_status;

  IF ( l_complete_status is NULL )  THEN
    LOG( l_api || ' did not implement ' || P_API_TYPE || ', ' || P_MODE );
  ELSIF ( l_complete_status = STATUS_SUCCESS )  THEN
    LOG( l_api || ' succeeded running, ' || P_API_TYPE || ', ' || P_MODE );
  ELSIF ( l_complete_status = STATUS_FAILURE )  THEN
    LOG( l_api || ' failed running, ' || P_API_TYPE || ', ' || P_MODE );
    RTNBUF := l_message;
    RAISE_APPLICATION_ERROR(-20000, l_message);
  END IF;

 --- LOG('Completed INVOKE_CUSTOME_API ' || P_API );
EXCEPTION WHEN OTHERS THEN
    RTNBUF := sqlerrm;
    RETCODE	:= sqlcode;
    RAISE;
END INVOKE_CUSTOM_API;



END BIS_BIA_RSG_CUSTOM_API_MGMNT; -- Package Body BIS_BIA_RSG_CUSTOM_API_MGMNT

/
