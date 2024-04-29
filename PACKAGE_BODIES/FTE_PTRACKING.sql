--------------------------------------------------------
--  DDL for Package Body FTE_PTRACKING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_PTRACKING" AS
/* $Header: FTEPTRKB.pls 120.3 2005/08/18 22:10:00 shravisa noship $ */

--===================
-- TYPES
--===================


--===================
-- PROCEDURES
--===================



PROCEDURE GetParam(
		p_key_list		IN KeyTable,
		p_value_list		IN ValueTable,
		p_type_list		IN TypeTable,
		p_key			IN VARCHAR2,
		x_value			OUT NOCOPY VARCHAR2,
		x_type  		OUT NOCOPY VARCHAR2) IS

    i BINARY_INTEGER := 0;

-- This procedure finds the value corresponding to a key given a list of keys and values

BEGIN

    -- dbms_output.put_line('-- IN GetParam ');
    -- dbms_output.put_line('    p_key '|| p_key);

    LOOP
	i := i + 1;
	IF p_key_list(i) = p_key
	THEN
	    x_value := p_value_list(i);
	    x_type := p_type_list(i);
	    EXIT;
	END IF;
    END LOOP;


    -- dbms_output.put_line('  x_value '|| x_value);
    -- dbms_output.put_line('   x_type '|| x_type);
    -- dbms_output.put_line('-- LEAVING GetParam ');


    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_value := null;
        x_type := 'NONE';
        -- dbms_output.put_line('-- LEAVING GetParam with exception: '||x_type);

END GetParam;


PROCEDURE GetTokenValue(
		p_table			IN VARCHAR2,
		p_column		IN VARCHAR2,
		p_kc1			IN VARCHAR2,
		p_kc2			IN VARCHAR2,
		p_kc3			IN VARCHAR2,
		p_kc4			IN VARCHAR2,
		p_kc5			IN VARCHAR2,
		p_key_list		IN KeyTable,
		p_value_list		IN ValueTable,
		p_type_list		IN TypeTable,
		x_token_value		OUT NOCOPY VARCHAR2,
		x_return_status         OUT NOCOPY VARCHAR2,
		x_err_msg               OUT NOCOPY VARCHAR2) IS

-- This procedure takes a table, a source column, and a set of keys and values to
-- make a query to extract the contents of the source column from the source table
-- satisfying the set of keys.

    l_k1 VARCHAR2(100) := null;
    l_k2 VARCHAR2(100) := null;
    l_k3 VARCHAR2(100) := null;
    l_k4 VARCHAR2(100) := null;
    l_k5 VARCHAR2(100) := null;

    l_query VARCHAR2(2500) := null;
    l_param VARCHAR2(100);
    l_param1 VARCHAR2(100) := null;
    l_param2 VARCHAR2(100) := null;
    l_param3 VARCHAR2(100) := null;
    l_param4 VARCHAR2(100) := null;
    l_param5 VARCHAR2(100) := null;
    l_type VARCHAR2(10);


    KEY_MISSING EXCEPTION;

BEGIN

-- should check data integrity. Make sure token is built correctly: can't have first kc null.

/*
    dbms_output.put_line('-- IN GetTokenValue ');
    dbms_output.put_line('          p_table '|| p_table);
    dbms_output.put_line('         p_column '|| p_column);
    dbms_output.put_line('            p_kc1 '|| p_kc1);
    dbms_output.put_line('            p_kc2 '|| p_kc2);
    dbms_output.put_line('            p_kc3 '|| p_kc3);
    dbms_output.put_line('            p_kc4 '|| p_kc4);
    dbms_output.put_line('            p_kc5 '|| p_kc5);
*/

    l_query := 'SELECT ' ||p_column || ' FROM ' || p_table;

    IF p_kc1 is null THEN
        GOTO after_query;
    ELSE

        GetParam(p_key_list, p_value_list, p_type_list, p_kc1, l_param1, l_type);

        IF l_type = 'NONE' THEN l_type := p_kc1; RAISE KEY_MISSING;
        ELSIF l_type = 'SYSDATE' THEN l_query := l_query || ' WHERE ' || p_kc1 || ' = sysdate';
        ELSIF l_type = 'DATE' THEN
            l_query := l_query || ' WHERE ' || p_kc1 || ' = to_date(:1 , ''dd-mm-yyyy hh24:mi:ss'')';
        ELSIF l_type = 'VARCHAR2' OR l_type = 'NUMBER' THEN  l_query := l_query || ' WHERE ' || p_kc1 || ' = :1 ';
        END IF;
        l_param := l_param1;

    END IF;



    IF p_kc2 is null THEN

	BEGIN
        EXECUTE IMMEDIATE l_query INTO x_token_value USING l_param1;
	EXCEPTION
	WHEN OTHERS THEN
		NULL;
	END;


        GOTO after_query;
    ELSE
        GetParam(p_key_list, p_value_list, p_type_list,  p_kc2, l_param2, l_type);
        IF l_type = 'NONE' THEN l_type := p_kc2; RAISE KEY_MISSING;
        ELSIF l_type = 'SYSDATE' THEN l_query := l_query || ' AND ' || p_kc2 || ' = sysdate';
        ELSIF l_type = 'DATE' THEN
            l_query := l_query || ' AND ' || p_kc2 || ' = to_date( :2, ''dd-mm-yyyy hh24:mi:ss'')';
        ELSIF l_type = 'VARCHAR2' OR l_type = 'NUMBER' THEN l_query := l_query || ' AND ' || p_kc2 || ' = :2 ';
        END IF;
        l_param := l_param2;
    END IF;

    IF p_kc3 is null THEN
	begin
		EXECUTE IMMEDIATE l_query INTO x_token_value USING l_param1, l_param2;
	EXCEPTION
	WHEN OTHERS THEN
		NULL;
	END;
	GOTO after_query;
    ELSE
        GetParam(p_key_list, p_value_list, p_type_list,  p_kc3, l_param3, l_type);
        IF l_type = 'NONE' THEN l_type := p_kc3; RAISE KEY_MISSING;
        ELSIF l_type = 'SYSDATE' THEN l_query := l_query || ' AND ' || p_kc3 || ' = sysdate';
        ELSIF l_type = 'DATE' THEN
            l_query := l_query || ' AND ' || p_kc3 || ' = to_date(:3, ''dd-mm-yyyy hh24:mi:ss'')';
        ELSIF l_type = 'VARCHAR2' OR l_type = 'NUMBER' THEN l_query := l_query || ' AND ' || p_kc3 || ' = :3 ';
        END IF;
        l_param := l_param3;
    END IF;

    IF p_kc4 is null THEN
	begin
		EXECUTE IMMEDIATE l_query INTO x_token_value USING l_param1, l_param2, l_param3;
	EXCEPTION
	WHEN OTHERS THEN
		NULL;
	END;
        GOTO after_query;
    ELSE
        GetParam(p_key_list, p_value_list, p_type_list,  p_kc4, l_param4, l_type);
        IF l_type = 'NONE' THEN l_type := p_kc4; RAISE KEY_MISSING;
        ELSIF l_type = 'SYSDATE' THEN l_query := l_query || ' AND ' || p_kc4 || ' = sysdate';
        ELSIF l_type = 'DATE' THEN
            l_query := l_query || ' AND ' || p_kc4 || ' = to_date( :4, ''dd-mm-yyyy hh24:mi:ss'')';
        ELSIF l_type = 'VARCHAR2' OR l_type = 'NUMBER' THEN l_query := l_query || ' AND ' || p_kc4 || ' = :4 ';
        END IF;
        l_param := l_param4;
    END IF;

    IF p_kc5 is null THEN
	BEGIN
	EXECUTE IMMEDIATE l_query INTO x_token_value USING l_param1, l_param2, l_param3, l_param4;
	EXCEPTION
	WHEN OTHERS THEN
		NULL;
	END;
        GOTO after_query;
    ELSE
        GetParam(p_key_list, p_value_list, p_type_list,  p_kc5, l_param5, l_type);
        IF l_type = 'NONE' THEN l_type := p_kc5; RAISE KEY_MISSING;
        ELSIF l_type = 'SYSDATE' THEN l_query := l_query || ' AND ' || p_kc5 || ' = sysdate';
        ELSIF l_type = 'DATE' THEN
            l_query := l_query || ' AND ' || p_kc5 || ' = to_date( :5, ''dd-mm-yyyy hh24:mi:ss'')';
        ELSIF l_type = 'VARCHAR2' OR l_type = 'NUMBER' THEN l_query := l_query || ' AND ' || p_kc5 || ' = :5 ';
        END IF;
	BEGIN
        EXECUTE IMMEDIATE l_query INTO x_token_value USING l_param1, l_param2, l_param3, l_param4, l_param5;
	EXCEPTION
	WHEN OTHERS THEN
		NULL;
	END;
        l_param := l_param5;
    END IF;


    <<after_query>>

    x_return_status := 'S';

    /*
    dbms_output.put_line('         l_query :');
    IF LENGTH(l_query)<256 THEN dbms_output.put_line(l_query);
     ELSE
        dbms_output.put_line(SUBSTR(l_query,0,255));
        IF LENGTH(l_query)>512 THEN dbms_output.put_line(SUBSTR(l_query,256,255));
        ELSE
            dbms_output.put_line(SUBSTR(l_query,256));
        END IF;
    END IF;

    dbms_output.put_line('   x_token_value '|| x_token_value);
    dbms_output.put_line(' x_return_status '|| x_return_status);
    dbms_output.put_line('       x_err_msg '|| x_err_msg);
    dbms_output.put_line('-- LEAVING GetTokenValue');
    */

    EXCEPTION
        WHEN KEY_MISSING THEN
            x_return_status := 'E';
            x_err_msg := 'MISSING KEY PARAM: ' || l_param;
            -- dbms_output.put_line('-- LEAVING GetTokenValue with exception: '||x_err_msg);
        --WHEN OTHERS THEN
        --    x_return_status := 'E';
        --    x_err_msg := 'UNKNOWN ERROR';
        --    dbms_output.put_line('-- LEAVING GetTokenValue with exception: '||x_err_msg);


END GetTokenValue;


FUNCTION InstallCheck return VARCHAR2 IS

l_fte_install_status VARCHAR2(10):= null;
l_industry VARCHAR2(50):= null;

BEGIN

    IF(TRUE) THEN RETURN 'Y'; -- added to remove functionality 5/14
    END IF;

    IF (fnd_installation.get(716, 716,l_fte_install_status,l_industry)) THEN
        IF (l_fte_install_status = 'I') THEN
            RETURN 'Y';
        ELSE
            RETURN 'N';
        END IF;
    END IF;
END InstallCheck;


PROCEDURE Validate(
		p_application_id	IN NUMBER,
		p_org_id                IN NUMBER,
		p_carrier_id		IN NUMBER,
		p_tracking_event	IN VARCHAR2,
		p_granularity		IN NUMBER,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_page_id		OUT NOCOPY NUMBER,
		x_base_url		OUT NOCOPY VARCHAR2,
		x_request_method	OUT NOCOPY VARCHAR2,
		x_name			OUT NOCOPY VARCHAR2,
		x_description		OUT NOCOPY VARCHAR2,
		x_token                 OUT NOCOPY VARCHAR2
		) IS

-- this procedure returns a stored page if this granularity, tracking_event and
-- application combination is valid and includes information for this carrier and organization.

               l_org_id                 NUMBER;


CURSOR get_page(x_org_id NUMBER) IS
SELECT page_id, base_url, request_method, name, description FROM FTE_PTRK_PAGES
WHERE STATUS = 'COMPLETED'
AND OWNER_APPLICATION_ID = p_application_id
AND CARRIER_PARTY_ID = p_carrier_id
AND GRANULARITY <= p_granularity
AND BUSINESS_CONCEPTS like ('%'||p_tracking_event||'%')
AND ORGANIZATIONS like ('%'||x_org_id||'%')
ORDER BY ORGANIZATIONS ASC;  -- this forces the most restrictive page record.

CURSOR get_token(l_page_id NUMBER) IS
SELECT --p.param_id, p.param_name,
  s.token_name
FROM fte_ptrk_params p, fte_ptrk_sources s
WHERE  p.token_id = s.token_id
AND    p.flag = 'Y'
AND    p.page_id = l_page_id;


BEGIN

    IF (InstallCheck() = 'N')
    THEN
        x_return_status := 'E';
        x_page_id := null;
        x_base_url := null;
        x_request_method := null;
        x_name := null;
        x_description := null;
        x_token := null;

	RETURN;

    END IF;


    -- dbms_output.put_line('-- IN Validate ');
    -- dbms_output.put_line(' p_application_id '|| p_application_id);
    -- dbms_output.put_line('         p_org_id '|| p_org_id);
    -- dbms_output.put_line('     p_carrier_id '|| p_carrier_id);
    -- dbms_output.put_line(' p_tracking_event '|| p_tracking_event);
    -- dbms_output.put_line('    p_granularity '|| p_granularity);

--------------------------------------------------
-- removed for pack J

--    SELECT organization_id into l_org_id
--    FROM wsh_new_deliveries
--    WHERE delivery_id = p_org_id;

--------------------------------------------------



    OPEN get_page(p_org_id); -- changed from l_org_id for packJ
    FETCH get_page
	INTO x_page_id, x_base_url, x_request_method, x_name, x_description;

    IF (get_page%NOTFOUND) THEN
        x_return_status := 'NO_PAGE';
    ELSE
        x_return_status := 'VALID';
        OPEN get_token(x_page_id);
        FETCH get_token INTO x_token;
        IF (get_token%NOTFOUND) THEN x_token := null; END IF;
	CLOSE get_token;
    END IF;
    CLOSE get_page;


    -- dbms_output.put_line('  x_return_status '|| x_return_status);
    -- dbms_output.put_line('        x_page_id '|| x_page_id);
    -- dbms_output.put_line('       x_base_url '|| x_base_url);
    -- dbms_output.put_line(' x_request_method '|| x_request_method);
    -- dbms_output.put_line('           x_name '|| x_name);
    -- dbms_output.put_line('    x_description '|| x_description);
    -- dbms_output.put_line('-- LEAVING Validate');

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := 'ERROR';
            -- dbms_output.put_line('-- LEAVING Validate with exception: '|| SQLERRM);



END Validate;

PROCEDURE ParseParamList(
		p_param_list	IN VARCHAR2,
		x_keyTable      OUT NOCOPY KeyTable,
		x_valueTable	OUT NOCOPY ValueTable,
		x_typeTable	OUT NOCOPY TypeTable
		) IS



l_key VARCHAR2(50);
l_value VARCHAR2(100);
l_type VARCHAR2(20);

i NUMBER := 0;
j NUMBER := 1;
k NUMBER := 0;
l NUMBER := 0;
c  CHAR  := ' ';
c2 CHAR  :=' ';

--type KeyTable is TABLE OF VARCHAR2(64) INDEX BY BINARY_INTEGER;
--type ValueTable is TABLE OF VARCHAR2(64) INDEX BY BINARY_INTEGER;
--type TypeTable is TABLE OF VARCHAR2(64) INDEX BY BINARY_INTEGER;

l_keyTable KeyTable;
l_valueTable ValueTable;
l_typeTable TypeTable;

param_index NUMBER := 1;
l_param_list VARCHAR2(10000);


BEGIN

    l_param_list := p_param_list || ';';
    FOR i IN 1..(LENGTH(l_param_list)) LOOP
        c2 := c;
	c := SUBSTR(l_param_list, i, 1);
        IF c = ';' AND c2 <> '\' THEN
            l_key := SUBSTR(l_param_list, j, k-j-1);
	    l_value := SUBSTR(l_param_list, k, l-k-1);
	    l_type  := SUBSTR(l_param_list, l, i-l);
	    l_keyTable(param_index) := l_key;
	    l_valueTable(param_index) := l_value;
	    l_typeTable(param_index) := l_type;
	    param_index := param_index + 1;
            j := i+1;
            -- dbms_output.put_line('    l_key, l_value, l_type:'||
            --                     l_key ||','|| l_value ||','|| l_type);
	ELSIF c = ','  AND c2 <> '\' THEN
	    IF l < k THEN l := i + 1;
	    ELSE k := i + 1;
            END IF;
        END IF;
    END LOOP;

    x_keyTable   := l_keyTable;
    x_valueTable := l_valueTable;
    x_typeTable  := l_typeTable;


END ParseParamList;



PROCEDURE Punchout(
		p_application_id	IN NUMBER,
		p_org_id                IN NUMBER,
		p_carrier_id		IN NUMBER,
		p_tracking_event	IN VARCHAR2,
		p_granularity		IN NUMBER,
		p_param_list		IN VARCHAR2,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_err_msg		OUT NOCOPY VARCHAR2,
		x_form_output		OUT NOCOPY VARCHAR2) IS

-- Punchout takes in an application, organization, carrier, tracking event, granularity
-- and a list of key parameters from the user in order to create a form to punch out to a
-- remote carrier's tracking site. This differs from the other overloaded call in that the
-- key/value pairs are represented in a single long VARCHAR2.


--type KeyTable is TABLE OF VARCHAR2(64) INDEX BY BINARY_INTEGER;
--type ValueTable is TABLE OF VARCHAR2(64) INDEX BY BINARY_INTEGER;
--type TypeTable is TABLE OF VARCHAR2(64) INDEX BY BINARY_INTEGER;

l_keyTable KeyTable;
l_valueTable ValueTable;
l_typeTable TypeTable;


BEGIN

    IF (InstallCheck() = 'N')
    THEN
        x_return_status := 'E';
        x_err_msg := 'FTE Not Installed';
        x_form_output := null;

	RETURN;

    END IF;

    -- dbms_output.put_line('-- IN Punchout (1)');
    -- dbms_output.put_line('-- app_id : ' || p_application_id);
    -- dbms_output.put_line('-- org_id : ' || p_org_id);
    -- dbms_output.put_line('-- carrier_id : ' || p_carrier_id);
    -- dbms_output.put_line('-- tracking_event : ' || p_tracking_event);
    -- dbms_output.put_line('-- granularity : ' || p_granularity);
    -- dbms_output.put_line('-- param_list : ' || p_param_list);

    ParseParamList(p_param_list, l_keyTable, l_valueTable, l_typeTable);

    Punchout(
		p_application_id,
		p_org_id,
		p_carrier_id,
		p_tracking_event,
		p_granularity,
		l_keyTable,
		l_valueTable,
		l_typeTable,
		x_return_status,
		x_err_msg,
		x_form_output);


END Punchout;







PROCEDURE FindTokenValue(
		p_application_id	IN NUMBER,
		p_token_name		IN VARCHAR2,
		p_param_list            IN VARCHAR2,
		x_token_value		OUT NOCOPY VARCHAR2,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_err_msg		OUT NOCOPY VARCHAR2
		) IS

l_source_table              VARCHAR2(30);
l_source_column	            VARCHAR2(30);
l_static_value              VARCHAR2(100);
l_key_column1               VARCHAR2(50);
l_key_column2               VARCHAR2(50);
l_key_column3               VARCHAR2(50);
l_key_column4               VARCHAR2(50);
l_key_column5               VARCHAR2(50);

l_keyTable KeyTable;
l_valueTable ValueTable;
l_typeTable TypeTable;

l_token_value               VARCHAR2(100);

CURSOR c_token IS
SELECT t.source_table, t.source_column, t.key_column1, t.key_column2, t.key_column3, t.key_column4, t.key_column5
FROM FTE_PTRK_SOURCES t
WHERE t.owner_application_id = p_application_id
AND t.token_name = p_token_name;


BEGIN

    IF (InstallCheck() = 'N')
    THEN
        x_return_status := 'E';
        x_err_msg := 'FTE Not Installed';
        x_token_value := null;

	RETURN;

    END IF;

    OPEN c_token;
    FETCH c_token INTO l_source_table, l_source_column,
	    l_key_column1, l_key_column2, l_key_column3, l_key_column4, l_key_column5;
    CLOSE c_token;


    ParseParamList(p_param_list, l_keyTable, l_valueTable, l_typeTable);


    GetTokenValue(
		l_source_table,	l_source_column,
		l_key_column1, l_key_column2, l_key_column3, l_key_column4, l_key_column5,
		l_keyTable, l_valueTable, l_typeTable,
		l_token_value,	x_return_status, x_err_msg);

    -- dbms_output.put_line('---- l_source_table '|| l_source_table);
    -- dbms_output.put_line('--- l_source_column '|| l_source_column);
    -- dbms_output.put_line('----  l_key_column1 '|| l_key_column1);
    -- dbms_output.put_line('----  l_key_column2 '|| l_key_column2);
    -- dbms_output.put_line('----  l_key_column3 '|| l_key_column3);
    -- dbms_output.put_line('----  l_key_column4 '|| l_key_column4);
    -- dbms_output.put_line('----  l_key_column5 '|| l_key_column5);
    -- dbms_output.put_line('----  l_token_value '|| l_token_value);
    -- dbms_output.put_line('--- x_return_status '|| x_return_status);
    -- dbms_output.put_line('----      x_err_msg '|| x_err_msg);


    x_token_value := l_token_value;


END FindTokenValue;







PROCEDURE Punchout(
		p_application_id	IN NUMBER,
		p_org_id                IN NUMBER,
		p_carrier_id		IN NUMBER,
		p_tracking_event	IN VARCHAR2,
		p_granularity		IN NUMBER,
		p_key_list		IN KeyTable,
		p_value_list		IN ValueTable,
		p_type_list		IN TypeTable,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_err_msg		OUT NOCOPY VARCHAR2,
		x_form_output		OUT NOCOPY VARCHAR2) IS

-- Punchout takes in an application, organization, carrier, tracking event, granularity
-- and a list of key parameters from the user in order to create a form to punch out to a
-- remote carrier's tracking site. This differs from the other overloaded call in that the
-- key/value pairs are represented in two PL/SQL tables.

    l_page_id			NUMBER;
    l_base_url			VARCHAR2(200);
    l_request_method		VARCHAR2(10);
    l_page_name			VARCHAR2(30);
    l_page_description		VARCHAR2(200);
    l_prefix                    VARCHAR2(10);
    l_token                     VARCHAR2(30);

    l_validity                  VARCHAR2(30);
    l_param_name                VARCHAR2(30);
    l_param_value               VARCHAR2(300);
    l_return_status             VARCHAR2(10);
    l_err_msg     		VARCHAR2(50);
    l_source_table              VARCHAR2(30);
    l_source_column		VARCHAR2(30);
    l_static_value              VARCHAR2(100);
    l_key_column1               VARCHAR2(50);
    l_key_column2               VARCHAR2(50);
    l_key_column3               VARCHAR2(50);
    l_key_column4               VARCHAR2(50);
    l_key_column5               VARCHAR2(50);

    l_token_name                VARCHAR2(50);
    l_token_id                  NUMBER;


    CURSOR c_params(p_page_id IN NUMBER) IS
    SELECT p.param_name, p.static_value, t.token_id, t.token_name, t.source_table, t.source_column,
           t.key_column1, t.key_column2, t.key_column3, t.key_column4, t.key_column5
    FROM FTE_PTRK_PARAMS p, FTE_PTRK_SOURCES t
    WHERE p.page_id = p_page_id
    and p.token_id = t.token_id (+);

    INVALID_INPUT EXCEPTION;
    TOKEN_ERROR   EXCEPTION;

    br VARCHAR2(2) := '
';
       -- CHR(13)||CHR(10);


BEGIN

    IF (InstallCheck() = 'N')
    THEN
        x_return_status := 'E';
        x_err_msg := 'FTE Not Installed';
        x_form_output := null;

	RETURN;

    END IF;

    Validate(p_application_id, p_org_id, p_carrier_id, p_tracking_event, p_granularity,
	l_validity, l_page_id, l_base_url, l_request_method, l_page_name, l_page_description, l_token);

    IF l_validity <> 'VALID' THEN RAISE INVALID_INPUT; END IF;

    IF (UPPER(SUBSTR(l_base_url,1,4)) <> 'HTTP') THEN l_prefix := 'http://'; ELSE l_prefix := ''; END IF;

    x_form_output := '<FORM ACTION="'|| l_prefix || l_base_url || '" METHOD="' || l_request_method ||
                     --'" NAME="' || l_page_name || '" >' || br;
                     '" NAME="TheForm" >' || br;


    OPEN c_params(l_page_id);
    LOOP
        FETCH c_params INTO l_param_name, l_static_value, l_token_id, l_token_name, l_source_table, l_source_column,
	    l_key_column1, l_key_column2, l_key_column3, l_key_column4, l_key_column5;


        EXIT WHEN c_params%NOTFOUND;

        IF l_token_id is not null THEN -- find token value

            --dbms_output.put_line('$$ TOKEN FOUND: ' || l_param_name || ' ' || to_char(l_token_id) || ' ' || l_token_name);
            GetTokenValue(l_source_table, l_source_column,
		l_key_column1, l_key_column2, l_key_column3, l_key_column4, l_key_column5,
		p_key_list, p_value_list, p_type_list, l_param_value, l_return_status, l_err_msg);

            IF l_return_status = 'E' THEN RAISE TOKEN_ERROR; END IF;

		    IF (l_param_value is not NULL) THEN

			    x_form_output := x_form_output ||
			     '  <INPUT TYPE="HIDDEN" NAME="' || l_param_name ||
				 '" VALUE="' || l_param_value || '" >' || br;

		        -- ELSIF l_static_value is not null THEN  -- take static value
		        ELSIF (l_static_value is not  null) THEN
			            --dbms_output.put_line('$$ STATIC FOUND: ' || l_param_name || ' ' || l_static_value);
			            x_form_output := x_form_output ||
			            '  <INPUT TYPE="HIDDEN" NAME="' || l_param_name ||
				     '" VALUE="' || l_static_value || '" >' || br;

  	          END IF ;
        END IF;

    END LOOP;

    CLOSE c_params;

    x_form_output := x_form_output || '</FORM>';
    EXCEPTION
        WHEN INVALID_INPUT THEN
            x_return_status := 'INVALID_INPUT';
	    x_err_msg := 'INVALID INPUT ' || l_validity;
	WHEN TOKEN_ERROR THEN
	    x_return_status := l_return_status;
	    x_err_msg := l_err_msg;

END Punchout;



END FTE_PTRACKING;

/
