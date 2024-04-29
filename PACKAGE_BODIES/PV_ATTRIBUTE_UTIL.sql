--------------------------------------------------------
--  DDL for Package Body PV_ATTRIBUTE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ATTRIBUTE_UTIL" as
/* $Header: pvxvautb.pls 120.4 2005/12/20 22:30:08 amaram ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_ATTRIBUTE_UTIL
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

FUNCTION MAP_CODE_TO_VALUE (        code     VARCHAR2,
                                    lov_tbl      lov_data_tbl_type
				    )
RETURN VARCHAR2;

FUNCTION MAP_CODE_TO_VALUE1 (        code     VARCHAR2,
                                     attribute_id NUMBER,
                                     lov_string     VARCHAR2
				    )
RETURN VARCHAR2;


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_ATTRIBUTE_UTIL';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvautb.pls';

G_USER_ID         NUMBER := NVL(FND_GLOBAL.USER_ID, -1);
G_LOGIN_ID        NUMBER := NVL(FND_GLOBAL.CONC_LOGIN_ID, -1);

---------------------------------------------------------------------
-- FUNCTION
--    GET_ATTR_VALUES_HISTORY
--
-- PURPOSE
--    Based on the attribute_id, entity, entity_id, version This function returns the attribute values appended with comma.
--
-- PARAMETERS
--    attribute_id, entity, entity_id
--    returns values separated by comma as varchar2
--
-- NOTES
--
---------------------------------------------------------------------


FUNCTION GET_ATTR_VALUES_HISTORY (      p_attribute_id     NUMBER,
                                        p_entity   VARCHAR2,
                                        p_entity_id     NUMBER,
					p_version	NUMBER,
					p_attr_data_type VARCHAR2,
					p_lov_string	VARCHAR2,
					p_user_date_format VARCHAR2
				 )
RETURN VARCHAR2
AS

--CURSOR  lc_history_values (pc_attribute_id NUMBER, pc_entity VARCHAR2, pc_entity_id NUMBER, --pc_version NUMBER ) IS

l_attr_history_values_sql VARCHAR2(32000):=

'SELECT  ' ||
'ATTR.ATTRIBUTE_ID "attributeID",  '||
'ATTR.ATTRIBUTE_TYPE "attributeType", '||
'ATTR.DISPLAY_STYLE "displayStyle", '||
--ENTY.ATTR_DATA_TYPE "attrDataType",
--ENTY.LOV_STRING "lovString",
'VAL.ATTR_VALUE "attrValue", '||
'VAL.ATTR_VALUE_EXTN "attrValueExtn", '||
--CODE.DESCRIPTION "CodeName",
--nvl(CODE.DESCRIPTION,VAL.ATTR_VALUE || ' (' || fnd_message.get_String('PV','PV_INVALID_VALUE')  || ')') "CodeName",
'case when VAL.ATTR_VALUE  is null   then ''''  '||
'	 when CODE.ATTR_CODE = VAL.ATTR_VALUE then  CODE.DESCRIPTION  '||
'	else VAL.ATTR_VALUE || '' ('' || fnd_message.get_String(''PV'',''PV_INVALID_VALUE'') || '')''  '||
'	end  ' ||
'	"CodeName", '||

'VAL.LAST_UPDATE_DATE "date" ' ||
'FROM ' ||
'PV_ATTRIBUTES_VL ATTR, ' ||
'PV_ENTY_ATTR_VALUES VAL,  ' ||
'PV_ENTITY_ATTRS ENTY, ' ||
'PV_ATTRIBUTE_CODES_VL CODE ' ||
'WHERE  ' ||
'ATTR.ATTRIBUTE_ID = :1 AND ' ||
'ATTR.ATTRIBUTE_ID = ENTY.ATTRIBUTE_ID AND ' ||
'ATTR.ATTRIBUTE_ID = VAL.ATTRIBUTE_ID AND ' ||
'ENTY.ENTITY = :2 AND ' ||
'VAL.ENTITY = ENTY.ENTITY AND ' ||
'VAL.ENTITY_ID = :3 AND ' ||
'VAL.VERSION = :4 AND ' ||
'CODE.ATTRIBUTE_ID(+)= VAL.ATTRIBUTE_ID AND ' ||
'CODE.ATTR_CODE (+)= VAL.ATTR_VALUE  ' ||
'ORDER BY  ' ||
'VAL.LAST_UPDATE_DATE '
;


l_attribute_id		NUMBER;
l_attribute_type	VARCHAR2(30);
l_display_style		VARCHAR2(30);
l_attr_data_type	VARCHAR2(30) := p_attr_data_type;
l_lov_string		VARCHAR2(2000):= p_lov_string;
l_attr_value		VARCHAR2(2000);
l_attr_value_extn	VARCHAR2(4000);
l_code_name		VARCHAR2(2500);
l_last_update_date	DATE;

l_value			VARCHAR2(32000) := '';

l_lov_data_rec  lov_data_rec_type := g_miss_lov_data_rec;
l_lov_data_tbl  lov_data_tbl_type:= g_miss_lov_data_tbl;


TYPE t_lov_cursor IS REF CURSOR;
v_lov_cursor t_lov_cursor;
lc_history_values t_lov_cursor;



l_counter NUMBER := 0;
l_curr_value VARCHAR2(80);
l_curr_code VARCHAR2(15);
BEGIN


    begin
	    if(l_attr_data_type is null) then
		l_value:= ', ';
	    elsif(l_attr_data_type = 'EXTERNAL' OR l_attr_data_type = 'INT_EXT') then
		OPEN v_lov_cursor FOR replace(l_lov_string,'?',':1') using p_attribute_id;
		loop
			FETCH v_lov_cursor INTO l_lov_data_rec;
			EXIT WHEN v_lov_cursor%NOTFOUND;

			l_counter :=l_counter+1;
			l_lov_data_tbl(l_counter) := l_lov_data_rec;

		end loop;
	    end if;

		OPEN lc_history_values FOR l_attr_history_values_sql using p_attribute_id, p_entity, p_entity_id,p_version;

		LOOP


		FETCH lc_history_values INTO  l_attribute_id, l_attribute_type, l_display_style,   l_attr_value, l_attr_value_extn, l_code_name, l_last_update_date;
		EXIT WHEN lc_history_values%NOTFOUND;

			if (l_attribute_type is null or l_attribute_type ='') then
				l_value:= '';
			elsif (l_attribute_type ='DROPDOWN') then

				if(l_attr_data_type is null) then
					l_value:= ', ';
				elsif(l_attr_data_type = 'INTERNAL' OR l_attr_data_type = 'EXT_INT') then
					if (l_display_style is null) then
						l_value:= ', ';
					elsif (l_display_style = 'PERCENTAGE' ) then
						l_value := l_value || l_code_name || '(' || l_attr_value_extn || '%), ';
					elsif(l_display_style = 'RADIO' or
					      l_display_style = 'SINGLE' or
					      l_display_style = 'MULTI' or
					      l_display_style = 'CHECK') then

						l_value := l_value || l_code_name || ', ';

					else
						l_value:= ', ';
					end if;

				elsif(l_attr_data_type = 'EXTERNAL' OR l_attr_data_type = 'INT_EXT') then
					--has to be processed
					if(l_attr_value is not null) then
						l_value := l_value ||	MAP_CODE_TO_VALUE1(l_attr_value,p_attribute_id, l_lov_string) || ', ';
					end if;
				else
					l_value:= ', ';
				end if;


			else
				if (l_display_style is null) then
					l_value:= ', ';
				elsif (l_display_style = 'DATE') then
					l_value:= TO_CHAR(TO_DATE(l_attr_value, 'YYYYMMDDHH24MISS'), p_user_date_format) || ', ';
				elsif (l_display_style = 'CURRENCY') then


					begin
						l_curr_code := SUBSTR(l_attr_value, INSTR(l_attr_value, ':::') + 3,INSTR(l_attr_value, ':::', 1, 2) - (INSTR(l_attr_value, ':::') + 3));

						select name into l_curr_value from fnd_currencies_vl
						where currency_code=l_curr_code;



						--l_value:= SUBSTR(l_attr_value, 1, INSTR(l_attr_value, ':::') - 1) ||
						--	  ':::' || l_curr_code || ':::' || l_curr_value || ', ';

						l_value:= SUBSTR(l_attr_value, 1, INSTR(l_attr_value, ':::') - 1) ||
							  '  ' || l_curr_code || ', ';

						/*
						l_value := pv_check_match_pub.Currency_Conversion(
							to_number(SUBSTR(l_attr_value, 1, INSTR(l_attr_value, ':::') - 1)),
							l_curr_code,
							--p_currency_conversion_date IN DATE := SYSDATE,
							gl_user_currency_code

							) || '  ' || gl_user_currency_code || ', ';

						l_value := pv_check_match_pub.Currency_Conversion(
							l_attr_value,
							gl_user_currency_code

							) || '  ' || gl_user_currency_code || ', ';

						*/


					exception
					when others then
						l_value:= ', ';
					end;

				else
					l_value:= l_attr_value || ', ';
				end if;

			end if;



		END LOOP;

	    CLOSE lc_history_values;

	EXCEPTION
	when others then
		l_value := ', ';

	end;

	return  substr(l_value, 1, length(l_value)-2);



END GET_ATTR_VALUES_HISTORY;




FUNCTION GET_ATTR_VALUES (		p_attribute_id     NUMBER,
                                        p_entity   VARCHAR2,
                                        p_entity_id     NUMBER,
					p_attr_data_type VARCHAR2,
					p_lov_string	VARCHAR2,
					p_is_snap_shot	VARCHAR2,
					p_snap_shot_date  VARCHAR2,
					p_user_date_format  VARCHAR2
				 )
RETURN VARCHAR2
AS

--CURSOR  lc_attr_values (pc_attribute_id NUMBER, pc_entity VARCHAR2, pc_entity_id NUMBER ) IS

l_attr_values_sql VARCHAR2(32000):=

	'SELECT '||
	'ATTR.ATTRIBUTE_ID "attributeID", '||
	'ATTR.ATTRIBUTE_TYPE "attributeType", '||
	'ATTR.DISPLAY_STYLE "displayStyle", '||
	'VAL.ATTR_VALUE "attrValue", '||
	'VAL.ATTR_VALUE_EXTN "attrValueExtn", '||
	--'CODE.DESCRIPTION "CodeName", '||
	--'nvl(CODE.DESCRIPTION,VAL.ATTR_VALUE || '' ('' || fnd_message.get_String(''PV'',''PV_INVALID_VALUE'')  || '')'') "CodeName", ' ||
	--'decode(CODE.DESCRIPTION,null,'',VAL.ATTR_VALUE || '' ('' || fnd_message.get_String(''PV'',''PV_INVALID_VALUE'')  || '')'') "CodeName", ' ||
	'case when VAL.ATTR_VALUE  is null   then '''' ' ||
		 'when CODE.ATTR_CODE = VAL.ATTR_VALUE then  CODE.DESCRIPTION ' ||
		 'else VAL.ATTR_VALUE || '' ('' || fnd_message.get_String(''PV'',''PV_INVALID_VALUE'') || '')'' ' ||
		 ' end ' ||

		 ' "CodeName", ' ||


	'VAL.LAST_UPDATE_DATE "date" '||
	'FROM '||
	'PV_ATTRIBUTES_VL ATTR, '||
	'PV_ENTY_ATTR_VALUES VAL, '||
	'PV_ENTITY_ATTRS ENTY, '||
	'PV_ATTRIBUTE_CODES_VL CODE '||
	'WHERE '||
	'ATTR.ATTRIBUTE_ID = :1 AND '||
	'ATTR.ATTRIBUTE_ID = ENTY.ATTRIBUTE_ID AND '||
	'ATTR.ATTRIBUTE_ID = VAL.ATTRIBUTE_ID AND '||
	'ENTY.ENTITY = :2 AND '||
	'VAL.ENTITY = ENTY.ENTITY AND '||
	'VAL.ENTITY_ID = :3 AND '||
	'ATTR.ATTRIBUTE_TYPE in (' || '''' || 'DROPDOWN' || '''' || ',' || '''' || 'TEXT' || '''' || ') AND '||
	'VAL.LATEST_FLAG(+) =' || '''' || 'Y'|| '''' || ' AND '||
	'CODE.ATTRIBUTE_ID(+)= VAL.ATTRIBUTE_ID AND '||
	'CODE.ATTR_CODE (+)= VAL.ATTR_VALUE  '||

	'UNION '||

	'SELECT '||
	'ATTR.ATTRIBUTE_ID "attributeID",  '||
	'ATTR.ATTRIBUTE_TYPE "attributeType", '||
	'ATTR.DISPLAY_STYLE "displayStyle",  '||
	'DECODE(ATTR.RETURN_TYPE, ' || '''' || 'NUMBER' || '''' || ', to_char(VAL.attr_value), VAL.attr_text) "attrValue", '||
	'''' || '' || '''' || ' "attrValueExtn", '||
	--'CODE.DESCRIPTION "CodeName", '||
	--'nvl(CODE.DESCRIPTION,VAL.ATTR_TEXT || '' ('' || fnd_message.get_String(''PV'',''PV_INVALID_VALUE'')  || '')'') "CodeName", ' ||
	'case when VAL.ATTR_TEXT  is null   then '''' ' ||
		 'when CODE.ATTR_CODE = VAL.ATTR_TEXT then  CODE.DESCRIPTION ' ||
		 'else VAL.ATTR_TEXT || '' ('' || fnd_message.get_String(''PV'',''PV_INVALID_VALUE'') || '')'' ' ||
		 ' end ' ||

		 ' "CodeName", ' ||

	'VAL.LAST_UPDATE_DATE "date" '||
	'FROM '||
	'PV_ATTRIBUTES_VL ATTR, '||
	'PV_SEARCH_ATTR_VALUES VAL, '||
	'PV_ENTITY_ATTRS ENTY, '||
	'PV_ATTRIBUTE_CODES_VL CODE '||
	'WHERE '||
	'ATTR.ATTRIBUTE_ID = :4 AND '||
	'ATTR.ATTRIBUTE_ID = ENTY.ATTRIBUTE_ID AND '||
	'ATTR.ATTRIBUTE_ID = VAL.ATTRIBUTE_ID AND '||
	'ENTY.ENTITY =  :5 AND '||
	'VAL.PARTY_ID = :6 AND '||
	'ENTY.DISPLAY_EXTERNAL_VALUE_FLAG = ' || '''' || 'Y' || '''' || ' AND '||
	'CODE.ATTRIBUTE_ID(+)= VAL.ATTRIBUTE_ID AND '||
	'CODE.ATTR_CODE (+)= VAL.ATTR_TEXT '
	;
/*
'SELECT ' ||
'ATTR.ATTRIBUTE_ID "attributeID", ' ||
'ATTR.ATTRIBUTE_TYPE "attributeType", '||
'ATTR.DISPLAY_STYLE "displayStyle", ' ||
'VAL.ATTR_VALUE "attrValue", ' ||
'VAL.ATTR_VALUE_EXTN "attrValueExtn", '||
'CODE.DESCRIPTION "CodeName", '||
'VAL.LAST_UPDATE_DATE "date" ' ||
'FROM ' ||
'PV_ATTRIBUTES_VL ATTR, '||
'PV_ENTY_ATTR_VALUES VAL,  '||
'PV_ENTITY_ATTRS ENTY, ' ||
'PV_ATTRIBUTE_CODES_VL CODE '||
'WHERE ' ||
'ATTR.ATTRIBUTE_ID = :1 AND ' ||
'ATTR.ATTRIBUTE_ID = ENTY.ATTRIBUTE_ID AND ' ||
'ATTR.ATTRIBUTE_ID = VAL.ATTRIBUTE_ID AND ' ||
'ENTY.ENTITY = :2 AND ' ||
'VAL.ENTITY = ENTY.ENTITY AND ' ||
'VAL.ENTITY_ID = :3 AND ' ||
'VAL.LATEST_FLAG(+) =' || '''' || 'Y'|| '''' || ' AND ' ||
'CODE.ATTRIBUTE_ID(+)= VAL.ATTRIBUTE_ID AND ' ||
'CODE.ATTR_CODE (+)= VAL.ATTR_VALUE ' ||

'ORDER BY '||
'VAL.LAST_UPDATE_DATE ';
*/

--CURSOR  lc_snap_shot_attr_values (pc_attribute_id NUMBER, pc_entity VARCHAR2, pc_entity_id NUMBER, pc_date VARCHAR2 ) IS
l_snap_shot_attr_values_sql VARCHAR2(32000):=
	'select attributeID, attributeType, displayStyle, attrValue, attrValueExtn, CodeName, updateDate from' ||
	' (select * from ' ||	'( SELECT ' ||
	'ATTR.ATTRIBUTE_ID attributeID,  ' ||
	'ATTR.ATTRIBUTE_TYPE attributeType, ' ||
	'ATTR.DISPLAY_STYLE displayStyle, ' ||
	'VAL.ATTR_VALUE attrValue, ' ||
	'VAL.ATTR_VALUE_EXTN attrValueExtn,  ' ||
	--'CODE.DESCRIPTION CodeName, ' ||
	--'nvl(CODE.DESCRIPTION,VAL.ATTR_VALUE || '' ('' || fnd_message.get_String(''PV'',''PV_INVALID_VALUE'')  || '')'') "CodeName", ' ||
	'case when VAL.ATTR_VALUE  is null   then '''' ' ||
		 'when CODE.ATTR_CODE = VAL.ATTR_VALUE then  CODE.DESCRIPTION ' ||
		 'else VAL.ATTR_VALUE || '' ('' || fnd_message.get_String(''PV'',''PV_INVALID_VALUE'') || '')'' ' ||
		 ' end ' ||

		 ' CodeName, ' ||

	'VAL.LAST_UPDATE_DATE updateDate, ' ||
	'(MAX(VAL.VERSION) OVER (PARTITION BY VAL.ATTRIBUTE_ID)) MaxVersion, ' ||
	'VAL.VERSION version ' ||
	'FROM  ' ||
	'PV_ATTRIBUTES_VL ATTR,  ' ||
	'PV_ENTY_ATTR_VALUES VAL,  ' ||
	'PV_ENTITY_ATTRS ENTY, ' ||
	'PV_ATTRIBUTE_CODES_VL CODE ' ||
	'WHERE  ' ||
	'ATTR.ATTRIBUTE_ID = :1 AND ' ||
	'ATTR.ATTRIBUTE_ID = ENTY.ATTRIBUTE_ID AND ' ||
	'ATTR.ATTRIBUTE_ID = VAL.ATTRIBUTE_ID AND ' ||
	'ENTY.ENTITY = :2 AND ' ||
	'VAL.ENTITY = ENTY.ENTITY AND ' ||
	'VAL.ENTITY_ID = :3 AND ' ||
	--VAL.LATEST_FLAG(+) ='Y' AND
	--'VAL.LAST_UPDATE_DATE (+) <= to_date(pc_date,'dd-mon-yy hh:mi:ss') and ' ||
	--'VAL.LAST_UPDATE_DATE (+) <= to_date(:4,' || '''' || 'dd-mon-yy hh:mi:ss'|| '''' || ') and ' ||
	'VAL.LAST_UPDATE_DATE (+) <= to_date(:4,:5) and ' ||
	'CODE.ATTRIBUTE_ID(+)= VAL.ATTRIBUTE_ID AND ' ||
	'CODE.ATTR_CODE (+)= VAL.ATTR_VALUE  ' ||
	'ORDER BY VAL.LAST_UPDATE_DATE ' ||
	') ' ||
	'where NVL(version,0) = NVL(MaxVersion,0)  ' ||
	') ' ||

	'UNION '||

	'SELECT '||
	'ATTR.ATTRIBUTE_ID "attributeID",  '||
	'ATTR.ATTRIBUTE_TYPE "attributeType", '||
	'ATTR.DISPLAY_STYLE "displayStyle",  '||
	'DECODE(ATTR.RETURN_TYPE, ' || '''' || 'NUMBER' || '''' || ', to_char(VAL.attr_value), VAL.attr_text) "attrValue", '||
	'''' || '' || '''' || ' "attrValueExtn", '||
	--'CODE.DESCRIPTION "CodeName", '||
	--'nvl(CODE.DESCRIPTION,VAL.ATTR_TEXT || '' ('' || fnd_message.get_String(''PV'',''PV_INVALID_VALUE'')  || '')'') "CodeName", ' ||
	'case when VAL.ATTR_TEXT  is null   then '''' ' ||
		 'when CODE.ATTR_CODE = VAL.ATTR_TEXT then  CODE.DESCRIPTION ' ||
		 'else VAL.ATTR_TEXT || '' ('' || fnd_message.get_String(''PV'',''PV_INVALID_VALUE'') || '')'' ' ||
		 ' end ' ||

		 ' "CodeName", ' ||

	'VAL.LAST_UPDATE_DATE "date" '||
	'FROM '||
	'PV_ATTRIBUTES_VL ATTR, '||
	'PV_SEARCH_ATTR_VALUES VAL, '||
	'PV_ENTITY_ATTRS ENTY, '||
	'PV_ATTRIBUTE_CODES_VL CODE '||
	'WHERE '||
	'ATTR.ATTRIBUTE_ID = :6 AND '||
	'ATTR.ATTRIBUTE_ID = ENTY.ATTRIBUTE_ID AND '||
	'ATTR.ATTRIBUTE_ID = VAL.ATTRIBUTE_ID AND '||
	'ENTY.ENTITY =  :7 AND '||
	'VAL.PARTY_ID = :8 AND '||
	'ENTY.DISPLAY_EXTERNAL_VALUE_FLAG = ' || '''' || 'Y' || '''' || ' AND '||
	'CODE.ATTRIBUTE_ID(+)= VAL.ATTRIBUTE_ID AND '||
	'CODE.ATTR_CODE (+)= VAL.ATTR_TEXT '
	;




l_attribute_id		NUMBER;
l_attribute_type	VARCHAR2(30);
l_display_style		VARCHAR2(30);
l_attr_data_type	VARCHAR2(30) := p_attr_data_type;
l_lov_string		VARCHAR2(2000):= p_lov_string;
l_attr_value		VARCHAR2(2000);
l_attr_value_extn	VARCHAR2(4000);
l_code_name		VARCHAR2(2500);
l_last_update_date	DATE;

l_value			VARCHAR2(32000) := '';

l_lov_data_rec  lov_data_rec_type := g_miss_lov_data_rec;
l_lov_data_tbl  lov_data_tbl_type:= g_miss_lov_data_tbl;

TYPE t_lov_cursor IS REF CURSOR;
v_lov_cursor t_lov_cursor;
lc_attr_values t_lov_cursor;

l_counter NUMBER := 0;
l_decimal_points NUMBER :=2;
l_curr_value VARCHAR2(80);
l_curr_code VARCHAR2(15);

l_query	varchar2(32000);

l_display_external_value_flag varchar2(1);

gl_user_currency_code       VARCHAR(30)	:=nvl(fnd_profile.value('ICX_PREFERRED_CURRENCY'), 'USD');

--l_attribute_type varchar2(30);

CURSOR c_get_attr_details(cv_attribute_id NUMBER, pc_entity VARCHAR2) IS
		SELECT attr.attribute_type,attr.decimal_points, enty.DISPLAY_EXTERNAL_VALUE_FLAG
		FROM  PV_ATTRIBUTES_VL attr, pv_entity_attrs enty
		WHERE attr.attribute_id =  cv_attribute_id and
		      attr.attribute_id= enty.attribute_id and
		      enty.entity=pc_entity
		      ;


BEGIN


	begin

	    for x in c_get_attr_details(cv_attribute_id => p_attribute_id, pc_entity => p_entity )
	    loop
		l_attribute_type := x.attribute_type;
		l_decimal_points := x.decimal_points;
		l_display_external_value_flag := x.display_external_value_flag;
	    end loop;

	    if(l_decimal_points is  null or l_decimal_points = '') then
		l_decimal_points := 2;
	    end if;

	    if (l_display_external_value_flag  is null or l_display_external_value_flag ='' ) then
		l_display_external_value_flag := 'N';
	    end if;

	    --select attribute_type from pv_attributes_b into l_attribute_type where attribute_id = p_attribute_id;

	   /*
	    if(l_attr_data_type is  null) then
		l_value:= ', ';
	    elsif(l_attribute_type= 'DROPDOWN' and (l_attr_data_type = 'EXTERNAL' OR l_attr_data_type = 'INT_EXT')) then
		OPEN v_lov_cursor FOR replace(l_lov_string,'?',':1') using p_attribute_id;
		loop
			FETCH v_lov_cursor INTO l_lov_data_rec;
			EXIT WHEN v_lov_cursor%NOTFOUND;

			l_counter :=l_counter+1;
			l_lov_data_tbl(l_counter) := l_lov_data_rec;

		end loop;
		CLOSE v_lov_cursor;
	    end if;
            */

	    if(p_is_snap_shot is  null or p_is_snap_shot = '' or p_is_snap_shot = 'N') then

		l_query := l_attr_values_sql;
	    else
		l_query := l_snap_shot_attr_values_sql;

	   end if;


	  -- dbms_output.put_line('Before Opening cursor::' );

	   if(p_is_snap_shot is  null or  p_is_snap_shot= '' or p_is_snap_shot= 'N') then
		OPEN lc_attr_values FOR l_query using p_attribute_id, p_entity, p_entity_id,p_attribute_id, p_entity, p_entity_id;
	    else
		OPEN lc_attr_values FOR l_query using p_attribute_id, p_entity, p_entity_id,p_snap_shot_date,p_user_date_format,p_attribute_id, p_entity, p_entity_id;
	   end if;

		LOOP
		--dbms_output.put_line('Before fetching');

		FETCH lc_attr_values INTO  l_attribute_id, l_attribute_type, l_display_style,   l_attr_value, l_attr_value_extn, l_code_name, l_last_update_date;
		--dbms_output.put_line('fetched:'||l_attribute_id||':'||l_attribute_type ||':'|| l_display_style || ':'||l_attr_value);
		EXIT WHEN lc_attr_values%NOTFOUND;

			--dbms_output.put_line('inside cursor loop');

			if (l_attribute_type is  null or l_attribute_type ='') then
				l_value:= '';
			elsif (l_attribute_type ='DROPDOWN') then

				if(l_attr_data_type is  null) then
					l_value:= ', ';
				elsif(l_attr_data_type = 'INTERNAL' OR l_attr_data_type = 'EXT_INT') then
					if (l_display_style is null) then
						l_value:= ', ';
					elsif (l_display_style = 'PERCENTAGE' ) then
						l_value := l_value || l_code_name || '(' || l_attr_value_extn || '%), ';
					elsif(l_display_style = 'RADIO' or
					      l_display_style = 'SINGLE' or
					      l_display_style = 'MULTI' or
					      l_display_style = 'CHECK') then

						l_value := l_value || l_code_name || ', ';

					else
						l_value:= ', ';
					end if;

				elsif(l_attr_data_type = 'EXTERNAL' OR l_attr_data_type = 'INT_EXT') then
					--has to be processed

					if(l_attr_value is not null) then
						l_value := l_value ||	MAP_CODE_TO_VALUE1(l_attr_value,p_attribute_id, l_lov_string) || ', ';
					end if;
				else
					l_value:= ', ';
				end if;
			elsif (l_attribute_type ='FUNCTION' and
			       (l_display_style is not null and
			        l_display_style='LOV'
			        )
			       ) then

				if(l_attr_data_type is  null) then
					l_value:= ', ';
				elsif(l_attr_data_type = 'INTERNAL' OR l_attr_data_type = 'EXT_INT') then
					l_value := l_value || l_code_name || ', ';
				elsif(l_attr_data_type = 'EXTERNAL' OR l_attr_data_type = 'INT_EXT') then
					--has to be processed

					l_value := l_value ||	MAP_CODE_TO_VALUE1(l_attr_value,p_attribute_id, l_lov_string) || ', ';

				else
					l_value:= ', ';
				end if;

			elsif (l_attribute_type ='FUNCTION' ) then

				if (l_display_style is  null) then
					l_value:= ', ';
				elsif (l_display_style = 'DATE') then

					l_value:= l_value || TO_CHAR(TO_DATE(l_attr_value, 'YYYYMMDDHH24MISS'), p_user_date_format) || ', ';
				elsif (l_display_style = 'PERCENTAGE') then
					--l_value:=', ';
					begin
						if(l_attr_value is null or l_attr_value = '') then
							l_value:= ', ';
						else
							l_value := l_value || to_number(ROUND(l_attr_value, l_decimal_points))*100 || ' %' ||', ';
						end if;
					exception
					when others then
						--dbms_output.put_line('error:' || SQLERRM);

						l_value:= ', ';
					end;
				elsif (l_display_style = 'NUMBER') then
					--l_value:=', ';
					begin
						if(l_attr_value is null or l_attr_value = '') then
							l_value:= ', ';
						else
							l_value := l_value || ROUND(l_attr_value, l_decimal_points) ||', ';
						end if;
					exception
					when others then
						--dbms_output.put_line('error:' || SQLERRM);

						l_value:= ', ';
					end;

				elsif (l_display_style = 'CURRENCY') then

					begin
						if(l_display_external_value_flag = 'N') then
							l_curr_code := l_value || SUBSTR(l_attr_value, INSTR(l_attr_value, ':::') + 3,INSTR(l_attr_value, ':::', 1, 2) - (INSTR(l_attr_value, ':::') + 3));

							select name into l_curr_value from fnd_currencies_vl
							where currency_code=l_curr_code;
							--dbms_output.put_line('curr_val:' || l_curr_value);


							l_value:= l_value || SUBSTR(l_attr_value, 1, INSTR(l_attr_value, ':::') - 1) ||
								  ':::' || l_curr_code || ':::' || l_curr_value || ', ';

						else
							select name into l_curr_value from fnd_currencies_vl
							where currency_code=gl_user_currency_code;

							l_value := l_value || pv_check_match_pub.Currency_Conversion(
							l_attr_value,
							gl_user_currency_code

							) || ':::' || gl_user_currency_code || ':::' || l_curr_value || ', ';

						end if;




					exception
					when others then
						--dbms_output.put_line('error:' || SQLERRM);

						l_value:= ', ';
					end;

				else
					l_value:= l_value || l_attr_value || ', ';
				end if;




			else
				if (l_display_style is  null) then
					l_value:= ', ';
				elsif (l_display_style = 'DATE') then

					l_value:= TO_CHAR(TO_DATE(l_attr_value, 'YYYYMMDDHH24MISS'), p_user_date_format) || ', ';
				elsif (l_display_style = 'PERCENTAGE') then
					l_value:=', ';
					begin
						if(l_attr_value is null or l_attr_value = '') then
							l_value:= ', ';
						else
							l_value := to_number(ROUND(l_attr_value, l_decimal_points))*100 || ' %' ||', ';
						end if;
					exception
					when others then
						--dbms_output.put_line('error:' || SQLERRM);

						l_value:= ', ';
					end;
				elsif (l_display_style = 'NUMBER') then
					l_value:=', ';
					begin
						if(l_attr_value is null or l_attr_value = '') then
							l_value:= ', ';
						else
							l_value := ROUND(l_attr_value, l_decimal_points) ||', ';
						end if;
					exception
					when others then
						--dbms_output.put_line('error:' || SQLERRM);

						l_value:= ', ';
					end;

				elsif (l_display_style = 'CURRENCY') then

					begin
						if(l_display_external_value_flag = 'N') then
							l_curr_code := SUBSTR(l_attr_value, INSTR(l_attr_value, ':::') + 3,INSTR(l_attr_value, ':::', 1, 2) - (INSTR(l_attr_value, ':::') + 3));

							select name into l_curr_value from fnd_currencies_vl
							where currency_code=l_curr_code;
							--dbms_output.put_line('curr_val:' || l_curr_value);


							l_value:= SUBSTR(l_attr_value, 1, INSTR(l_attr_value, ':::') - 1) ||
								  ':::' || l_curr_code || ':::' || l_curr_value || ', ';
							/*
							l_value:= SUBSTR(l_attr_value, 1, INSTR(l_attr_value, ':::') - 1) ||
								  ':::' || l_curr_code || ', ';
							*/
							--dbms_output.put_line('curr_val:' || l_value);
							/*
							l_value := pv_check_match_pub.Currency_Conversion(
								to_number(SUBSTR(l_attr_value, 1, INSTR(l_attr_value, ':::') - 1)),
								l_curr_code,
								--p_currency_conversion_date IN DATE := SYSDATE,
								gl_user_currency_code

								) || '  ' || gl_user_currency_code || ', ';
							*/
						else
							select name into l_curr_value from fnd_currencies_vl
							where currency_code=gl_user_currency_code;

							l_value := pv_check_match_pub.Currency_Conversion(
							l_attr_value,
							gl_user_currency_code

							) || ':::' || gl_user_currency_code || ':::' || l_curr_value || ', ';

						end if;




					exception
					when others then
						--dbms_output.put_line('error:' || SQLERRM);

						l_value:= ', ';
					end;

				else
					l_value:= l_attr_value || ', ';
				end if;

			end if;


		if(length(l_value)> 3999) then
			raise VALUE_ERROR;
		end if;

		END LOOP;

	    CLOSE lc_attr_values;



	EXCEPTION

	when others then
           --dbms_output.put_line('in exception::: ' || SQLERRM || ':::'|| SQLCODE);
	   if SQLCODE = -6502 then
		if( length(l_value) > 3999 ) then
		l_value := rpad(substr(l_value, 1, 3994),3999,'.');
		else
		l_value := '';
		end if;
		--dbms_output.put_line('in exception::: ' || SQLERRM);
           end if;

	--l_value := '';
	end;
--dbms_output.put_line('Before returning');
	return  substr(l_value, 1, length(l_value)-2);




END GET_ATTR_VALUES;


FUNCTION MAP_CODE_TO_VALUE (        code     VARCHAR2,
                                    lov_tbl      lov_data_tbl_type
			    )
RETURN VARCHAR2

AS



BEGIN

	FOR i in 1..lov_tbl.count LOOP

		if(rtrim(lov_tbl(i).code) = rtrim(code)) then
			return rtrim(lov_tbl(i).meaning);
		end if;

	END LOOP;

	--if(rtrim(code) = '' or code = null) then
	--	return '';
	--else
		return code || ' (' || fnd_message.get_String('PV','PV_INVALID_VALUE') || ')';
	--end if;

END MAP_CODE_TO_VALUE;


FUNCTION MAP_CODE_TO_VALUE1 (        code     VARCHAR2,
                                     attribute_id NUMBER,
                                     lov_string     VARCHAR2
				    )
RETURN VARCHAR2

AS

TYPE t_lov_cursor IS REF CURSOR;
v_lov_cursor t_lov_cursor;
l_attr_value VARCHAR2(2000);
l_lov_data_rec  lov_data_rec_type := g_miss_lov_data_rec;
l_lov_string		VARCHAR2(2000);


BEGIN

     l_lov_string := 'select * from ( ' || replace(lov_string,'?',':1') || ' ) where code = :2 ';

     --dbms_output.put_line('l_lov_string:' || l_lov_string);

     begin

	     OPEN v_lov_cursor FOR l_lov_string using attribute_id, code;
	     LOOP
		FETCH v_lov_cursor INTO l_lov_data_rec;
		EXIT WHEN v_lov_cursor%NOTFOUND;
			l_attr_value := l_lov_data_rec.meaning;
	     END LOOP;
	     CLOSE v_lov_cursor;
	     --dbms_output.put_line('l_attr_value:' || l_attr_value);

     exception
     when others then
	--dbms_output.put_line('error:' || SQLERRM);
	l_attr_value:= code || ' (' || fnd_message.get_String('PV','PV_INVALID_VALUE') || ')';
      end;

     if l_attr_value is not null then
	return l_attr_value;
     end if;

     return code || ' (' || fnd_message.get_String('PV','PV_INVALID_VALUE') || ')';


END MAP_CODE_TO_VALUE1;





END PV_ATTRIBUTE_UTIL;

/
