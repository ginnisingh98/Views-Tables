--------------------------------------------------------
--  DDL for Package Body CCT_VALIDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_VALIDATION_PUB" as
/* $Header: cctpvalb.pls 115.18 2004/07/12 21:54:09 svinamda noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30) :='CCT_VALIDATION_PUB';

PROCEDURE VALIDATE_OTM_PARAMS
(
  p_server_group_id IN NUMBER,
  p_server_id IN NUMBER,
  p_env_lang IN VARCHAR2, -- language
  p_param_ids IN IEO_STRING_VARR, -- list of param ids
  p_param_values IN IEO_STRING_VARR, -- list of param values
  x_err_msg_count OUT NOCOPY NUMBER, -- number of error messages
  x_err_msgs OUT NOCOPY IEO_STRING_VARR, -- list of error messages.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
)
IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'VALIDATE_OTM_PARAMS';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
l_preview_enabled NUMBER;
l_preview_wc_idx NUMBER;
l_iqd_web_callback VARCHAR2(256);
l_max_preview_time_idx NUMBER;
l_msg_code VARCHAR2(256);

BEGIN
	-- Standard Start of API savepoint

  SAVEPOINT	VALIDATE_OTM_PARAMS_PUB;

	--  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := null;
  x_err_msg_count := 0;
  x_err_msgs := IEO_STRING_VARR();

	-- API body

  l_preview_wc_idx := -1;
  l_max_preview_time_idx := -1;

  FOR i IN 1..p_param_ids.count LOOP
    if (p_param_ids(i) = 10201) then
      l_preview_wc_idx := i;
    elsif (p_param_ids(i) = 10202) then
      l_max_preview_time_idx := i;
    end if;
  END LOOP;
  l_preview_enabled := 0;
  if ((l_preview_wc_idx > 0) and
      (UPPER(p_param_values(l_preview_wc_idx)) = UPPER('true'))) then
    l_preview_enabled := 1;
    -- preview webcallback should be true only if iqd web callback is enabled
    begin
      select value into l_iqd_web_callback from ieo_svr_values
      where server_id =
        (select server_id from ieo_svr_servers
         where type_id = 10110
          and member_svr_group_id =  p_server_group_id)
        and param_id = 10026;
    exception
    when NO_DATA_FOUND  then
      begin
      select value into l_iqd_web_callback from ieo_svr_values
      where server_id =
        (select server_id from ieo_svr_servers
         where type_id = 10110
          and member_svr_group_id =
            (select group_group_id from ieo_svr_groups where
             server_group_id = p_server_group_id))
        and param_id = 10026;
      exception
      when NO_DATA_FOUND  then
        l_iqd_web_callback := null;
      end;
    end;
    if ((l_iqd_web_callback is null) or
       (UPPER(l_iqd_web_callback) <> UPPER('true'))) then
      x_err_msg_count := x_err_msg_count + 1;
      x_err_msgs.extend();
      l_msg_code := 'CCT_PARAM_ERR_PREVIEW_WC';
      SELECT MESSAGE_TEXT into x_err_msgs(x_err_msgs.count)
        FROM FND_NEW_MESSAGES
        WHERE LANGUAGE_CODE = p_env_lang
--        (SELECT LANGUAGE_CODE
--          FROM FND_LANGUAGES
--          WHERE NLS_LANGUAGE = p_env_lang)
        AND APPLICATION_ID = 172
      AND MESSAGE_NAME = l_msg_code;
    end if;
  end if;

  if ((l_max_preview_time_idx > 0) and
      (p_param_values(l_max_preview_time_idx) is not null) and
      (l_preview_enabled = 0)) then
  -- max preview time should be set only if preview web callback is enabled.
    x_err_msg_count := x_err_msg_count + 1;
    x_err_msgs.extend();
    l_msg_code := 'CCT_PARAM_ERR_MAX_PREVIEW_TIME';
    SELECT MESSAGE_TEXT into x_err_msgs(x_err_msgs.count)
      FROM FND_NEW_MESSAGES
      WHERE LANGUAGE_CODE = p_env_lang
--      (SELECT LANGUAGE_CODE
--        FROM FND_LANGUAGES
--        WHERE NLS_LANGUAGE = p_env_lang)
      AND APPLICATION_ID = 172
    AND MESSAGE_NAME = l_msg_code;
  end if;
	-- End of API body.
EXCEPTION

	WHEN OTHERS THEN
    ROLLBACK TO VALIDATE_OTM_PARAMS_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
    x_msg_count := 1;
    x_err_num := SQLCODE;
    x_err_msg := SUBSTR(SQLERRM, 1, 100);
    x_msg_data := 'CCT_VALIDATION_PUB: CCT_ERROR '
                    || ' ErrorCode = ' || x_err_num
                    || ' ErrorMsg = ' || x_err_msg;


  --dbms_output.put_line(x_msg_data);

END VALIDATE_OTM_PARAMS;


FUNCTION GetParamID(
	p_param_name	IN	VARCHAR,
	p_type_id	IN	NUMBER
)
RETURN NUMBER IS

  l_param_id		NUMBER;

BEGIN

  select param_id into l_param_id
    from IEO_SVR_PARAMS
    where param_name = p_param_name
	  AND type_id = p_type_id;

  return l_param_id;

EXCEPTION
  WHEN OTHERS THEN
    return -1;

END GetParamID;


PROCEDURE VALIDATE_ITS_PARAMS
(
  p_server_group_id IN NUMBER,
  p_server_id IN NUMBER,
  p_env_lang IN VARCHAR2, -- language
  p_param_ids IN IEO_STRING_VARR, -- list of param ids
  p_param_values IN IEO_STRING_VARR, -- list of param values
  x_err_msg_count OUT NOCOPY NUMBER, -- number of error messages
  x_err_msgs OUT NOCOPY IEO_STRING_VARR,  -- list of error messages.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
)
IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'VALIDATE_ITS_PARAMS';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);

l_rp_param_id			VARCHAR(30) := null;
l_mw_param_id			VARCHAR(30) := null;
l_rp_param_name			CONSTANT VARCHAR(30)	:= 'ROUTE_POINTS';
l_mw_param_name			CONSTANT VARCHAR(30)	:= 'TELE_MIDDLEWARE_CONFIG';
l_mw_param_pos			NUMBER			:= 0;
l_rp_param_pos			NUMBER 			:= 0;
l_rp_params			IEO_STRING_VARR		:= IEO_STRING_VARR();
l_mw_param			VARCHAR(50) := null;
l_temp				VARCHAR(500) := null;
l_temp1				VARCHAR(500) := null;
l_tempNum			NUMBER			:= 0;
l_tempNum1			NUMBER			:= 0;
l_temp_varray			IEO_STRING_VARR		:= IEO_STRING_VARR();
l_begPos	NUMBER := 1;
l_endPos	NUMBER := 1;
l_currVal	VARCHAR(500);
l_rpCount	NUMBER := 1;
l_length	NUMBER := 0;
l_msg_code VARCHAR2(256);
l_comma_str VARCHAR2(1);
l_its_server_type NUMBER := 10090;

BEGIN
	-- Standard Start of API savepoint

  SAVEPOINT	VALIDATE_ITS_PARAMS_PUB;

	--  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := null;
  x_err_msg_count := 0;
  x_err_msgs := IEO_STRING_VARR();

	-- API body

  -- If no param_ids passed, return
  IF p_param_ids.count <= 0 THEN
    --dbms_output.put_line('Params Id count <= 0');
    RETURN;
  END IF;

  l_rp_param_id := to_char(GetParamID(l_rp_param_name, 10090));
  l_mw_param_id := to_char(GetParamID(l_mw_param_name, 10090));
  --dbms_output.put_line('RP Param ID: ' || l_rp_param_id || ', MW Param ID: ' || l_mw_param_id);

  -- Gather the paramter values that need to be validated
  -- Route points and middleware configs
  FOR i IN p_param_ids.first..p_param_ids.last LOOP
     --dbms_output.put_line('Current param id:' || p_param_ids(i));
     IF p_param_ids(i) = l_rp_param_id THEN
	-- param is 'ROUTE_POINT'
	-- dbms_output.put_line('param is route point');
	l_rp_param_pos := i;
	l_temp1 := p_param_values(i);

        IF l_temp1 = ' ' THEN
	   --x_msg_data := 'l_temp1 is empty1';
	   NULL;
        ELSIF l_temp1 is NULL THEN
	   --x_msg_data := 'l_temp1 is empty2';
 	   NULL;
	ELSE
	  select LENGTH(l_temp1) into l_length from DUAL;
	  LOOP

	    IF l_length < l_begPos THEN EXIT;
	    END IF;

      l_comma_str := ',';
	    select INSTR(l_temp1, l_comma_str , l_begPos, 1) into l_endPos from DUAL;

	    IF l_endPos = 0 THEN
	      select SUBSTR(l_temp1, l_begPos) into l_currVal from DUAL;
	      IF l_currVal is NULL THEN
        x_err_msgs.EXTEND;
        l_msg_code := 'CCT_PARAM_ERR_ITS_RP_MISMATCH';
    		SELECT MESSAGE_TEXT into x_err_msgs(x_err_msgs.count)
      	  	FROM FND_NEW_MESSAGES
      	  	WHERE LANGUAGE_CODE = p_env_lang
--      		(SELECT LANGUAGE_CODE
--        	   	FROM FND_LANGUAGES
--        	   	WHERE NLS_LANGUAGE = p_env_lang)
      			AND APPLICATION_ID = 172
   			AND MESSAGE_NAME = l_msg_code;
        x_err_msg_count := x_err_msg_count + 1;
	    	RETURN;
	      END IF;
	      IF l_currVal = ' ' THEN
        x_err_msgs.EXTEND;
        l_msg_code := 'CCT_PARAM_ERR_ITS_RP_MISMATCH';
    		SELECT MESSAGE_TEXT into x_err_msgs(x_err_msgs.count)
      	  	FROM FND_NEW_MESSAGES
      	  	WHERE LANGUAGE_CODE = p_env_lang
--      		(SELECT LANGUAGE_CODE
--        	   	FROM FND_LANGUAGES
--        	   	WHERE NLS_LANGUAGE = p_env_lang)
      			AND APPLICATION_ID = 172
   			AND MESSAGE_NAME = l_msg_code;
		x_err_msg_count := x_err_msg_count + 1;
	    	RETURN;
	      END IF;


	      l_rp_params.EXTEND;
	      l_rp_params(l_rpCount) := l_currVal;
	      l_rpCount := l_rpCount + 1;
	      --dbms_output.put_line('l_begPos: ' || l_begPos);
	      --dbms_output.put_line('l_endPos: ' || l_endPos);
	      --dbms_output.put_line('l_currVal: ' || l_currVal);
	      EXIT;
	    ELSE
	      select SUBSTR(l_temp1, l_begPos, l_endPos - l_begPos) into l_currVal from DUAL;
	      IF l_currVal is NULL THEN
		x_err_msgs.EXTEND;
    l_msg_code := 'CCT_PARAM_ERR_ITS_RP_MISMATCH';
    		SELECT MESSAGE_TEXT into x_err_msgs(x_err_msgs.count)
      	  	FROM FND_NEW_MESSAGES
      	  	WHERE LANGUAGE_CODE = p_env_lang
--      		(SELECT LANGUAGE_CODE
--        	   	FROM FND_LANGUAGES
--        	   	WHERE NLS_LANGUAGE = p_env_lang)
      			AND APPLICATION_ID = 172
   			AND MESSAGE_NAME = l_msg_code;
		x_err_msg_count := x_err_msg_count + 1;
	    	RETURN;
	      END IF;
	      IF l_currVal = ' ' THEN
		x_err_msgs.EXTEND;
    l_msg_code := 'CCT_PARAM_ERR_ITS_RP_MISMATCH';
    		SELECT MESSAGE_TEXT into x_err_msgs(x_err_msgs.count)
      	  	FROM FND_NEW_MESSAGES
      	  	WHERE LANGUAGE_CODE = p_env_lang
--      		(SELECT LANGUAGE_CODE
--        	   	FROM FND_LANGUAGES
--        	   	WHERE NLS_LANGUAGE = p_env_lang)
      			AND APPLICATION_ID = 172
   			AND MESSAGE_NAME = l_msg_code;
		x_err_msg_count := x_err_msg_count + 1;
	    	RETURN;
	      END IF;

	      l_rp_params.EXTEND;
	      l_rp_params(l_rpCount) := l_currVal;
	      l_rpCount := l_rpCount + 1;

	      --dbms_output.put_line('l_begPos: ' || l_begPos);
	      --dbms_output.put_line('l_endPos: ' || l_endPos);
	      --dbms_output.put_line('l_currVal: ' || l_currVal);
	      l_begPos := l_endPos + 1;
	    END IF;
	  END LOOP;
	END IF;
     ELSIF p_param_ids(i) = l_mw_param_id THEN
	-- param is 'TELE_MIDDLEWARE_CONFIG'
	l_mw_param_pos := i;
	-- dbms_output.put_line('param is mw config');
	l_mw_param := p_param_values(i);
     END IF;
  END LOOP;

  -- Validated the collected Route points and middleware config paramters
  --dbms_output.put_line('Before checking route point varray');
  IF l_rp_params.count <= 0 THEN
    -- No route point defined => Make sure no other ITS Servers
    -- has the same MW defined
    --dbms_output.put_line('l_rp_params.count <= 0 ');
    select count(*) into l_tempNum
      from IEO_SVR_VALUES vals, IEO_SVR_SERVERS servers
      where vals.server_id = servers.server_id
	    AND servers.type_id = l_its_server_type
	    AND vals.server_id <> p_server_id
            AND servers.member_svr_group_id = p_server_group_id
	    AND vals.param_id = l_mw_param_id
	    AND vals.value = l_mw_param;
    --dbms_output.put_line('l_tempNum: ' || l_tempNum);
    IF l_tempNum > 0 THEN
	x_err_msgs.EXTEND;
  l_msg_code := 'CCT_PARAM_ERR_ITS_MW_MONITERED';
    	SELECT MESSAGE_TEXT into x_err_msgs(x_err_msgs.count)
      	  FROM FND_NEW_MESSAGES
      	  WHERE LANGUAGE_CODE = p_env_lang
--      		(SELECT LANGUAGE_CODE
--        	   FROM FND_LANGUAGES
--        	   WHERE NLS_LANGUAGE = p_env_lang)
      		AND APPLICATION_ID = 172
   		AND MESSAGE_NAME = l_msg_code;
	x_err_msg_count := x_err_msg_count + 1;
    END IF;
    RETURN;
  ELSE
    -- Retrieve the number of other ITS Servers
    -- monitoring the same middlewares and monitoring
    -- all the route points
    select count(*) into l_tempNum
      from IEO_SVR_VALUES vals, IEO_SVR_SERVERS servers
      where vals.server_id = servers.server_id
	    AND servers.type_id = l_its_server_type
	    AND servers.server_id <> p_server_id
            AND servers.member_svr_group_id = p_server_group_id
	    AND vals.param_id = l_mw_param_id
	    AND vals.value = l_mw_param
	    AND not exists (
		select 1
		  from IEO_SVR_VALUES v
		  where v.server_id = servers.server_id
		        AND v.param_id = l_rp_param_id);

    IF l_tempNum > 0 THEN
	x_err_msgs.EXTEND;
  l_msg_code := 'CCT_PARAM_ERR_ITS_RP_MONITERED';
    	SELECT MESSAGE_TEXT into x_err_msgs(x_err_msgs.count)
      	  FROM FND_NEW_MESSAGES
      	  WHERE LANGUAGE_CODE = p_env_lang
--      		(SELECT LANGUAGE_CODE
--        	   FROM FND_LANGUAGES
--        	   WHERE NLS_LANGUAGE = p_env_lang)
      		AND APPLICATION_ID = 172
   		AND MESSAGE_NAME = l_msg_code;
	x_err_msg_count := x_err_msg_count + 1;
	RETURN;
    END IF;
  END IF;

  IF l_mw_param is null THEN
    -- Has route point defined, but no mw
    x_err_msgs.EXTEND;
    l_msg_code := 'CCT_PARAM_ERR_ITS_MW_UNDEFINED';
    SELECT MESSAGE_TEXT into x_err_msgs(x_err_msgs.count)
      FROM FND_NEW_MESSAGES
      	  WHERE LANGUAGE_CODE = p_env_lang
--      		(SELECT LANGUAGE_CODE
--        	   FROM FND_LANGUAGES
--        	   WHERE NLS_LANGUAGE = p_env_lang)
        AND APPLICATION_ID = 172
   	AND MESSAGE_NAME = l_msg_code;
    x_err_msg_count := x_err_msg_count + 1;
    RETURN;
  END IF;

  FOR i IN l_rp_params.first..l_rp_params.last LOOP
    l_temp := l_rp_params(i);
    --dbms_output.put_line('Checking route point:' || l_temp || ' with mwconfig:' || l_mw_param);
    -- 1) Check if route point selected is namespaced with the same mw config
    select INSTR(l_temp, l_mw_param, 1, 1) into l_endPos from DUAL;
    IF l_endPos = 0 THEN
	--dbms_output.put_line('route pt and mw do not matched!!! rp param:' || l_rp_param_pos);
	x_err_msgs.EXTEND;
  l_msg_code := 'CCT_PARAM_ERR_ITS_RP_MISMATCH';
    	SELECT MESSAGE_TEXT into x_err_msgs(x_err_msgs.count)
      	  FROM FND_NEW_MESSAGES
      	  WHERE LANGUAGE_CODE = p_env_lang
--      		(SELECT LANGUAGE_CODE
--        	   FROM FND_LANGUAGES
--        	   WHERE NLS_LANGUAGE = p_env_lang)
      		AND APPLICATION_ID = 172
   		AND MESSAGE_NAME = l_msg_code;
	x_err_msg_count := x_err_msg_count + 1;
	RETURN;
    END IF;

    -- 2) Check if the route point is already taken by other ITS Servers
    select count(*) into l_tempNum
      from IEO_SVR_VALUES vals, IEO_SVR_SERVERS servers
      where vals.server_id = servers.server_id
	    AND vals.server_id <> p_server_id
            AND servers.member_svr_group_id = p_server_group_id
	    AND vals.param_id = l_rp_param_id
	    AND vals.value like  '%' || l_rp_params(i) || '%';
    IF l_tempNum > 0 THEN
	-- Route Points taken by some other ITS
	x_err_msgs.EXTEND;
  l_msg_code := 'CCT_PARAM_ERR_ITS_RP_MONITERED';
    	SELECT MESSAGE_TEXT into x_err_msgs(x_err_msgs.count)
      	  FROM FND_NEW_MESSAGES
      	  WHERE LANGUAGE_CODE = p_env_lang
--      		(SELECT LANGUAGE_CODE
--        	   FROM FND_LANGUAGES
--        	   WHERE NLS_LANGUAGE = p_env_lang)
      		AND APPLICATION_ID = 172
   		AND MESSAGE_NAME = l_msg_code;
	x_err_msg_count := x_err_msg_count + 1;
	RETURN;
    END IF;
  END LOOP;

EXCEPTION

	WHEN OTHERS THEN
    ROLLBACK TO VALIDATE_ITS_PARAMS_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
    x_msg_count := 1;
    x_err_num := SQLCODE;
    x_err_msg := SUBSTR(SQLERRM, 1, 100);
    x_msg_data := 'CCT_VALIDATION_PUB: CCT_ERROR '
                    || ' ErrorCode = ' || x_err_num
                    || ' ErrorMsg = ' || x_err_msg;
  --dbms_output.put_line(x_msg_data);

END VALIDATE_ITS_PARAMS;




PROCEDURE VALIDATE_IQD_PARAMS
(
  p_server_group_id IN NUMBER,
  p_server_id IN NUMBER,
  p_env_lang IN VARCHAR2, -- language
  p_param_ids IN IEO_STRING_VARR, -- list of param ids
  p_param_values IN IEO_STRING_VARR, -- list of param values
  x_err_msg_count OUT NOCOPY NUMBER, -- number of error messages
  x_err_msgs OUT NOCOPY IEO_STRING_VARR,  -- list of error messages.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
)
IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'VALIDATE_IQD_PARAMS';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
l_priority_queueing_idx NUMBER;
l_default_priority_timeout_idx NUMBER;
l_priority_queueing_enabled NUMBER;
l_web_callback_idx NUMBER;
l_send_error NUMBER;
l_msg_code VARCHAR2(256);

BEGIN
	-- Standard Start of API savepoint

  SAVEPOINT	VALIDATE_IQD_PARAMS_PUB;

	--  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := null;
  x_err_msg_count := 0;
  x_err_msgs := IEO_STRING_VARR();

	-- API body

  l_priority_queueing_idx := -1;
  l_default_priority_timeout_idx := -1;

  FOR i IN 1..p_param_ids.count LOOP
    if (p_param_ids(i) = 10211) then
      l_priority_queueing_idx := i;
    elsif (p_param_ids(i) = 10212) then
      l_default_priority_timeout_idx := i;
    elsif (p_param_ids(i) = 10026) then
      l_web_callback_idx := i;
    end if;
  END LOOP;

  l_priority_queueing_enabled := 0;
  if ((l_priority_queueing_idx > 0) and
      (UPPER(p_param_values(l_priority_queueing_idx)) = UPPER('true'))) then
  -- preview webcallback should be true only if iqd web callback is enabled
    l_priority_queueing_enabled := 1;
  end if;


  if ((l_default_priority_timeout_idx > 0) and
      (p_param_values(l_default_priority_timeout_idx) is not null) and
      (l_priority_queueing_enabled = 0)) then
  -- default priority timeout should be set only if priority queueing is enabled.
    x_err_msg_count := x_err_msg_count + 1;
    x_err_msgs.extend();
    l_msg_code := 'CCT_PARAM_ERR_PRIORITY_TIMEOUT';
    SELECT MESSAGE_TEXT into x_err_msgs(x_err_msgs.count)
      FROM FND_NEW_MESSAGES
      WHERE LANGUAGE_CODE = p_env_lang
--      (SELECT LANGUAGE_CODE
--        FROM FND_LANGUAGES
--        WHERE NLS_LANGUAGE = p_env_lang)
      AND APPLICATION_ID = 172
    AND MESSAGE_NAME = l_msg_code;
  end if;

  if ((l_web_callback_idx > 0) and
      (p_param_values(l_web_callback_idx) is null) or
      (UPPER(p_param_values(l_web_callback_idx)) = UPPER('false')))
  then
  begin
    l_send_error := 0;
    declare cursor c1 is
    select value from ieo_svr_values
    where server_id in
    (select server_id from ieo_svr_servers
     where type_id = 10001
      and member_svr_group_id =  p_server_group_id)
    and param_id = 10201;
    -- OTM PREVIEW MODE PARAM

    begin
    for c1_rec in c1 loop
      if (UPPER(c1_rec.value) = UPPER('true')) then
        l_send_error := 1;
      end if;
    end loop;
    end;

    declare cursor c2 is
    select value from ieo_svr_values
    where server_id in
    (select server_id from ieo_svr_servers
     where type_id = 10001
      and member_svr_group_id =  p_server_group_id)
    and param_id = 10202;
    -- OTM Param Max Preview Time
    begin
    for c2_rec in c2 loop
      if (c2_rec.value is not null) then
      l_send_error := 1;
      end if;
    end loop;
    end;

    if (l_send_error = 1)
    then
      x_err_msg_count := x_err_msg_count + 1;
      x_err_msgs.extend();
      l_msg_code := 'CCT_PARAM_ERR_WC';
      SELECT MESSAGE_TEXT into x_err_msgs(x_err_msgs.count)
        FROM FND_NEW_MESSAGES
        WHERE LANGUAGE_CODE = p_env_lang
      AND APPLICATION_ID = 172
      AND MESSAGE_NAME = l_msg_code;
    end if;
  end;
  end if;

	-- End of API body.

EXCEPTION

	WHEN OTHERS THEN
    ROLLBACK TO VALIDATE_IQD_PARAMS_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
    x_msg_count := 1;
    x_err_num := SQLCODE;
    x_err_msg := SUBSTR(SQLERRM, 1, 100);
    x_msg_data := 'CCT_VALIDATION_PUB: CCT_ERROR '
                    || ' ErrorCode = ' || x_err_num
                    || ' ErrorMsg = ' || x_err_msg;
  --dbms_output.put_line(x_msg_data);

END VALIDATE_IQD_PARAMS;

END CCT_VALIDATION_PUB;

/
