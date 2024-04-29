--------------------------------------------------------
--  DDL for Package Body QP_JAVA_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_JAVA_ENGINE" AS
/* $Header: QPXINTJB.pls 120.0 2005/06/02 00:17:07 appldev noship $ */

l_debug VARCHAR2(3);
TYPE PROFNAME_TYPE       IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE PROFVALUE_TYPE       IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

G_PROFILE_NAMES PROFNAME_TYPE;
G_PROFILE_VALUES PROFVALUE_TYPE;
G_PROFILE_STR varchar2(32767);

/*+----------------------------------------------------------------------
  | PROCEDURE insert_profs2_AT
  | This procedure insert profile name/value pairs into interface table
  | qp_int_prof_t using AUTONOMONOUS TRANSACTION
  +----------------------------------------------------------------------
*/
PROCEDURE Insert_Profs2_AT(
              p_request_id IN NUMBER,
              x_status_code                 OUT NOCOPY VARCHAR2,
              x_status_text                 OUT NOCOPY VARCHAR2)
AS
PRAGMA AUTONOMOUS_TRANSACTION;
 l_routine VARCHAR2(240):='Routine:QP_JAVA_ENGINE.INSERT_PROFS2_AT';

CURSOR qp_profs_cur is
select PROFILE_OPTION_NAME
from FND_PROFILE_OPTIONS
where (APPLICATION_ID = 661 or
       PROFILE_OPTION_NAME = 'ORG_ID') and
 START_DATE_ACTIVE <=sysdate and
 nvl(END_DATE_ACTIVE,sysdate) >= sysdate and
 (APP_ENABLED_FLAG <> 'N' or
  RESP_ENABLED_FLAG <>'N' or
  USER_ENABLED_FLAG <>'N');

--l_profile_names QP_PREQ_GRP.VARCHAR_TYPE;

BEGIN
l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

x_status_code := FND_API.G_RET_STS_SUCCESS;

IF G_PROFILE_NAMES.count = 0 THEN
  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('G_PROFILE_NAMES cache is empty and needs warming it up.');
  END IF;
  OPEN qp_profs_cur;
  G_PROFILE_NAMES.delete;
  FETCH qp_profs_cur BULK COLLECT INTO
  G_PROFILE_NAMES;

  FOR i in G_PROFILE_NAMES.FIRST..G_PROFILE_NAMES.LAST
  LOOP
    G_PROFILE_VALUES(i) := FND_PROFILE.value(G_PROFILE_NAMES(i));
  END LOOP;
ELSE
  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('G_PROFILE_NAMES cache has been warmed up and reuse it.');
  END IF;
END IF;

IF l_debug = FND_API.G_TRUE THEN
  --FOR i in l_profile_names.FIRST..l_profile_names.LAST
  FOR i in G_PROFILE_NAMES.FIRST..G_PROFILE_NAMES.LAST
  LOOP
     --QP_PREQ_GRP.engine_debug('profile name:'||l_profile_names(i)||' value:'||FND_PROFILE.value(l_profile_names(i)));
     QP_PREQ_GRP.engine_debug('profile name:'||G_PROFILE_NAMES(i)||' value:'||G_PROFILE_VALUES(i));
  END LOOP;
END IF;

--FORALL i in l_profile_names.FIRST..l_profile_names.LAST
FORALL i in G_PROFILE_NAMES.FIRST..G_PROFILE_NAMES.LAST
INSERT INTO QP_INT_PROFS_T
( REQUEST_ID,
  PROFILE_OPTION_NAME,
 PROFILE_OPTION_VALUE)
VALUES ( p_request_id,
         --l_profile_names(i),
         --FND_PROFILE.value(l_profile_names(i))
         G_PROFILE_NAMES(i),
         G_PROFILE_VALUES(i)
            );
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  x_status_code := FND_API.G_RET_STS_ERROR;
  x_status_text :=l_routine||' '||SQLERRM;
  IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug(l_routine||' '||SQLERRM);
    QP_PREQ_GRP.engine_debug(SQLERRM);
  END IF;
END;

/*+----------------------------------------------------------------------
  | FUNCTION Get_Prof_String
  | Output: HTTP request parameter string for Profile Option Values
  |        e.g., G_PARAM_NAME_PROFL_PATN=N|N|Y|Y|Y|N|N|N|N|N
  | This function contructs parameter string for user-level Profile Option
  | Values, which will be used for UTL_HTTP call
  +----------------------------------------------------------------------
*/
FUNCTION Get_Prof_String
 RETURN varchar2 IS
--prof_str varchar2(32767);
prof_pattern varchar2(32767);
BEGIN
  IF(G_PROFILE_STR IS NULL) THEN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('G_PROFILE_STR is empty and needs initialization.');
    END IF;

    --prof_str := G_PARAM_NAME_PROFL_PATN||'=';
    G_PROFILE_STR := G_PARAM_NAME_PROFL_PATN||'=';

    /*Profile Option Values Pattern:
     (QP_DEBUG|QP_INV_DECIMAL_PRECISION|QP_LIMIT_EXCEED_ACTION|
    |QP_QUALIFY_SECONDARY_PRICE_LISTS|QP_RETURN_MANUAL_DISCOUNTS|
    QP_SATIS_QUALS_OPT|QP_SET_REQUEST_NAME|QP_SOURCE_SYSTEM_CODE|
    QP_TIME_UOM_CONVERSION|QP_FLEX_VALUESET_RESTRICT) */

    prof_pattern := FND_PROFILE.VALUE('QP_DEBUG')||G_PATN_SEPERATOR;
    prof_pattern := prof_pattern||FND_PROFILE.VALUE('QP_INV_DECIMAL_PRECISION')||G_PATN_SEPERATOR;
    prof_pattern := prof_pattern||FND_PROFILE.VALUE('QP_LIMIT_EXCEED_ACTION')||G_PATN_SEPERATOR;
    prof_pattern := prof_pattern||FND_PROFILE.VALUE('QP_QUALIFY_SECONDARY_PRICE_LISTS')||G_PATN_SEPERATOR;
    prof_pattern := prof_pattern||FND_PROFILE.VALUE('QP_RETURN_MANUAL_DISCOUNTS')||G_PATN_SEPERATOR;
    prof_pattern := prof_pattern||FND_PROFILE.VALUE('QP_SATIS_QUALS_OPT')||G_PATN_SEPERATOR;
    prof_pattern := prof_pattern||FND_PROFILE.VALUE('QP_SET_REQUEST_NAME')||G_PATN_SEPERATOR;
    prof_pattern := prof_pattern||FND_PROFILE.VALUE('QP_SOURCE_SYSTEM_CODE')||G_PATN_SEPERATOR;
    prof_pattern := prof_pattern||FND_PROFILE.VALUE('QP_TIME_UOM_CONVERSION')||G_PATN_SEPERATOR;

    prof_pattern := prof_pattern||FND_PROFILE.VALUE('QP_FLEX_VALUESET_RESTRICT');

    --prof_str := prof_str||prof_pattern;
    G_PROFILE_STR := G_PROFILE_STR||prof_pattern;
  END IF;

  --RETURN prof_str;
  RETURN G_PROFILE_STR;
END Get_Prof_String;

/*+----------------------------------------------------------------------
  | FUNCTION Get_Ctrl_String
  | Output: HTTP request parameter string for Control Record
  |        e.g., G_PARAM_NAME_CTRL_PATN=
  |               BATCH|Y|Y|Y|Y|Y|N|Y|Y|Y|Y|ONT|Y|Y|Y|Y|1.0|XY|USD
  | This function contructs parameter string for Control Record based on
  | p_control_rec information, which will be used for UTL_HTTP call
  +----------------------------------------------------------------------
*/
FUNCTION Get_Ctrl_String(p_control_rec IN QP_PREQ_GRP.CONTROL_RECORD_TYPE)
 RETURN varchar2 IS
p_ctrl_str varchar2(32767);
p_control_pattern varchar2(32767);

BEGIN
  p_ctrl_str := G_PARAM_NAME_CTRL_PATN||'=';
  /*Control Pattern:
    PRICING_EVENT|CALCULATE_FLAG|SIMULATION_FLAG|ROUNDING_FLAG|
    GSA_CHECK_FLAG|GSA_DUP_CHECK_FLAG|MANUAL_DISCOUNT_FLAG|DEBUG_FLAG|
    SOURCE_ORDER_AMOUNT_FLAG|MANUAL_ADJUSTMENTS_CALL_FLAG|GET_FREIGHT_FLAG|
    REQUEST_TYPE_CODE|VIEW_CODE|CHECK_CUST_VIEW_FLAG|FULL_PRICING_CALL|
    USE_MULTI_CURRENCY|USER_CONVERSION_RATE|USER_CONVERSION_TYPE|
    FUNCTION_CURRENCY*/
  /*TEMP_TABLE_INSERT_FLAG,PUBLIC_API_CALL_FLAG from p_control_rec not passed*/
  p_control_pattern := p_control_rec.PRICING_EVENT||G_PATN_SEPERATOR;
  p_control_pattern := p_control_pattern||p_control_rec.CALCULATE_FLAG||G_PATN_SEPERATOR;
  p_control_pattern := p_control_pattern||p_control_rec.SIMULATION_FLAG||G_PATN_SEPERATOR;
  p_control_pattern := p_control_pattern||p_control_rec.ROUNDING_FLAG||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.GSA_CHECK_FLAG||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.GSA_DUP_CHECK_FLAG||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.MANUAL_DISCOUNT_FLAG||G_PATN_SEPERATOR;

  --p_control_pattern := p_control_pattern||p_control_rec.DEBUG_FLAG||G_PATN_SEPERATOR;
  --debug control from QP_PREQ_GRP.G_DEBUG_ENGINE
  p_control_pattern := p_control_pattern||QP_PREQ_GRP.G_DEBUG_ENGINE||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.SOURCE_ORDER_AMOUNT_FLAG||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.MANUAL_ADJUSTMENTS_CALL_FLAG||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.GET_FREIGHT_FLAG||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.REQUEST_TYPE_CODE||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.VIEW_CODE||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.CHECK_CUST_VIEW_FLAG||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.FULL_PRICING_CALL||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.USE_MULTI_CURRENCY||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.USER_CONVERSION_RATE||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.USER_CONVERSION_TYPE||G_PATN_SEPERATOR;

  p_control_pattern := p_control_pattern||p_control_rec.FUNCTION_CURRENCY;

  p_ctrl_str := p_ctrl_str||p_control_pattern;
  RETURN p_ctrl_str;
END Get_Ctrl_String;

PROCEDURE REQUEST_PRICE(request_id IN NUMBER,
			p_control_rec IN   QP_PREQ_GRP.CONTROL_RECORD_TYPE,
			x_return_status          OUT NOCOPY  VARCHAR2,
			x_return_status_text     OUT NOCOPY  VARCHAR2)
IS
l_routine VARCHAR2(240):='Routine:QP_JAVA_ENGINE.REQUEST_PRICE';
p_ctrl_str varchar2(32767);

l_pricing_start_time number;
l_pricing_end_time number;
l_return_status VARCHAR2(240);
--l_status_text   VARCHAR2(240);
l_status_text   VARCHAR2(32767);
url_param_string varchar2(32767);
l_action_type varchar2(10) := 'PRICE';
l_session_id number := FND_GLOBAL.SESSION_ID;

E_ROUTINE_ERRORS EXCEPTION;
BEGIN
l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

IF l_debug = FND_API.G_TRUE THEN
        l_pricing_start_time := dbms_utility.get_time;
	QP_PREQ_GRP.engine_debug('Inside ' || l_routine);
        QP_PREQ_GRP.engine_debug('calc_flag:' ||p_control_rec.CALCULATE_FLAG);
END IF;

  /*Construct request parameter string CtrlPatn*/
  p_ctrl_str := Get_Ctrl_String(p_control_rec);
IF l_debug = FND_API.G_TRUE THEN
	QP_PREQ_GRP.engine_debug('Ctrl_Str:'||p_ctrl_str);
END IF;

  /*Store QP Profiles*/
  Insert_Profs2_AT(request_id, l_return_status,l_status_text);
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE E_ROUTINE_ERRORS;
  END IF;

  --/*Construct request parameter string ContextConfig*/
  --p_ctxt_str := Get_Context_Params;

  /*Send Request To Java Engine*/
  url_param_string := G_PARAM_NAME_REQUEST_ID||'='||request_id||G_HARD_CHAR||p_ctrl_str||G_HARD_CHAR||QP_JAVA_ENGINE_UTIL_PUB.G_PARAM_NAME_ACTION||'='||l_action_type||G_HARD_CHAR;

  url_param_string := url_param_string||'n1='||QP_PREQ_GRP.G_INT_LINES_NO||G_HARD_CHAR||'n2='||QP_PREQ_GRP.G_INT_LDETS_NO||G_HARD_CHAR||'n3='||QP_PREQ_GRP.G_INT_ATTRS_NO||G_HARD_CHAR||'n4='||QP_PREQ_GRP.G_INT_RELS_NO;

  IF(QP_PREQ_GRP.G_INT_LINES_NO < G_JPE_LINES_THRESHOLD) THEN
    QP_JAVA_ENGINE_UTIL_PUB.Send_Java_Engine_Request(url_param_string, l_return_status,l_status_text, 60, FND_API.G_FALSE, FND_API.G_TRUE);
  ELSE
    QP_JAVA_ENGINE_UTIL_PUB.Send_Java_Engine_Request(url_param_string, l_return_status,l_status_text, -1, FND_API.G_TRUE, FND_API.G_TRUE);
  END IF;
  --IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     --RAISE E_ROUTINE_ERRORS;
  --END IF;
   x_return_status := l_return_status;
   x_return_status_text := substr(l_status_text, 1, 240);

  IF l_debug = FND_API.G_TRUE THEN
    l_pricing_end_time := dbms_utility.get_time;
    QP_PREQ_GRP.engine_debug('Total time in '||l_routine||': '||(l_pricing_end_time - l_pricing_start_time)/100);
  END IF;

  IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('Request Id:'||request_id||' has finished with status_code='||x_return_status||' status_text='||x_return_status_text);
  END IF;
EXCEPTION
    WHEN E_ROUTINE_ERRORS THEN
    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug(l_routine||': '||l_status_text);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     --x_return_status_text := l_routine||': '||l_status_text;
     x_return_status_text := l_status_text;
    WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP','QP_JPE_UNEXPECTED_ERROR');
    x_return_status_text := FND_MESSAGE.get;
    --x_return_status_text := 'Java Engine call failed unexpectedly. Please contact system administrator!';
    IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('Request Id:'||request_id||' failed unexpectedly!' );
    END IF;
END;
END QP_JAVA_ENGINE;

/
