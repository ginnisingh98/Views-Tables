--------------------------------------------------------
--  DDL for Package Body WSH_CC_RESPONSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CC_RESPONSE_PKG" AS
/* $Header: WSHGTRPB.pls 115.3 2002/06/03 12:31:07 pkm ship       $ */

  SUCCESS_ERROR    CONSTANT VARCHAR2(10) := 'SUCCESS';
  ONHOLD_ERROR    CONSTANT VARCHAR2(10) := 'ON_HOLD';
  DATA_ERROR    CONSTANT VARCHAR2(10) := 'DATA';
  SYSTEM_ERROR    CONSTANT VARCHAR2(10) := 'SYSTEM';


  -- Name
  --   INTERPRET_ERROR
  -- Purpose
  --   Internal. On passing the interpreted error, it sets the result code
  --   based on the priority of the code
  -- Arguments
  --   fetch_interpreted_code      Interpreted code got from the rule
  --   interpreted_code            Interpreted code to be returned

  PROCEDURE INTERPRET_ERROR (
    fetch_interpreted_code IN WSH_GTC_RESPONSE_RULES.INTERPRETED_VALUE_CODE%TYPE,
    interpreted_code IN OUT WSH_GTC_RESPONSE_RULES.INTERPRETED_VALUE_CODE%TYPE)
  IS
    interpreted_string   VARCHAR2(30);
  BEGIN
      IF(fetch_interpreted_code = SYSTEM_ERROR) THEN
           interpreted_code := SYSTEM_ERROR;
      ELSIF(fetch_interpreted_code = DATA_ERROR) AND (interpreted_code <> SYSTEM_ERROR) THEN
           interpreted_code := DATA_ERROR;
      ELSIF(fetch_interpreted_code = ONHOLD_ERROR) AND  (interpreted_code NOT IN (SYSTEM_ERROR, DATA_ERROR) ) THEN
           interpreted_code := ONHOLD_ERROR;
      END IF;
  END;


  -- Name
  --   ONT_RESPONSE_ANALYSER
  -- Purpose
  --   On passing the transaction_control_id of a request this package returns
  --   the interpreted status of the request based on the rules defined
  -- Arguments
  --   trans_control_id            transaction_control_id of a request
  --   response_header_id          transaction_control_id of a request
  --   result_status               status returned as record T_RESULT_STATUS_REC
  -- Notes
  --   Refer the record T_RESULT_STATUS_REC
  PROCEDURE ONT_RESPONSE_ANALYSER (
    trans_control_id IN NUMBER,
    response_header_id IN NUMBER,
    result_status OUT t_result_status_rec)
  IS

    fetch_interpreted_code  WSH_GTC_RESPONSE_RULES.INTERPRETED_VALUE_CODE%TYPE;
    fetch_error_code  WSH_CC_RESPONSE_LINES.ERROR_CODE%TYPE;
    fetch_error_type  WSH_CC_RESPONSE_LINES.ERROR_TYPE%TYPE;
    response_hdr_id NUMBER;

    CURSOR Get_Response_Header( trans_control_id NUMBER) IS
    SELECT response_header_id, c.error_code, interpreted_value_code
    FROM WSH_CC_TRANS_CONTROL c, WSH_GTC_RESPONSE_RULES r
    WHERE transaction_control_id = trans_control_id and c.error_code = r.error_code(+) ;


    CURSOR Get_Response_Line_Details( resp_header_id NUMBER) IS
    SELECT l.error_code error_code, l.error_type error_type,
              denied_party_flag, embargo_flag, license_required
    FROM WSH_CC_RESPONSE_LINES l
    WHERE response_header_id = resp_header_id;

    CURSOR Get_Interpreted_code(p_error_code VARCHAR2, p_error_type VARCHAR2) IS
    SELECT interpreted_value_code
    FROM WSH_GTC_RESPONSE_RULES
    WHERE error_type = p_error_type and nvl(error_code,p_error_code) = p_error_code
    ORDER BY error_code;

  BEGIN
    oe_debug_pub.add('***Inside the procedure ONT_RESPONSE_ANALYSER***');
    result_status.status_code := SUCCESS_ERROR;
    result_status.dp_flag := 'N';
    result_status.em_flag := 'N';
    result_status.ld_flag := 'N';

    OPEN Get_Response_Header(trans_control_id);

    FETCH Get_Response_Header INTO response_hdr_id, fetch_error_code, fetch_interpreted_code;

    IF Get_Response_Header%NOTFOUND THEN
        oe_debug_pub.Add('Trans Control Id is not Found');
      --Invalid trans control
      result_status.status_code := SYSTEM_ERROR;
      return;
    END IF;

    CLOSE Get_Response_Header;
    IF (fetch_error_code is not NULL) AND (fetch_interpreted_code is NULL) THEN --Rule not found
        oe_debug_pub.Add('Error in the Trans Control and There Is no Rule Defined');
        fetch_interpreted_code := DATA_ERROR;                                   --Default is DATA ERR
    END IF;
    IF fetch_interpreted_code is not NULL THEN
       oe_debug_pub.Add('Interpreted Error in the Trans Control - ' || fetch_interpreted_code );
       interpret_error(fetch_interpreted_code, result_status.status_code ) ;
      IF(result_status.status_code = SYSTEM_ERROR) THEN
           return;
      END IF;
    END IF;

    FOR resp IN Get_Response_Line_Details(response_hdr_id) LOOP
      IF ((resp.error_code is not NULL) OR (resp.error_type is not NULL)) THEN
          OPEN Get_Interpreted_code(resp.error_code, resp.error_type);
          FETCH Get_Interpreted_code INTO fetch_interpreted_code;
          IF Get_Interpreted_code%NOTFOUND THEN               --Rule not found
                fetch_interpreted_code := DATA_ERROR;         --Default is DATA ERR
                oe_debug_pub.Add('Reponse Line Error, Rule Nof Found for Code ' || resp.error_code || ' Type ' || resp.error_type );
          END IF;
          oe_debug_pub.Add('Reponse Line Error, Interpreted Code - ' || fetch_interpreted_code );
          interpret_error(fetch_interpreted_code, result_status.status_code ) ;
      END IF;

      IF resp.denied_party_flag = 'Y' THEN
        oe_debug_pub.Add('Denied Party is found' );
        result_status.dp_flag := 'Y';
      END IF;
      IF resp.embargo_flag = 'Y' THEN
        oe_debug_pub.Add('Embargo is found' );
        result_status.em_flag := 'Y';
      END IF;
      IF resp.license_required = 'Y' THEN
        oe_debug_pub.Add('License Required' );
        result_status.ld_flag := 'Y';
      END IF;
      IF(result_status.status_code = SYSTEM_ERROR) THEN
           return;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      oe_debug_pub.Add('Unknown Exception has occoured' );
      result_status.status_code := SYSTEM_ERROR;
  END ONT_RESPONSE_ANALYSER;


END WSH_CC_RESPONSE_PKG;

/
