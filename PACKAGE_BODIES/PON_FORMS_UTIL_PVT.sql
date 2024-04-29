--------------------------------------------------------
--  DDL for Package Body PON_FORMS_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_FORMS_UTIL_PVT" as
/* $Header: PONFMUTB.pls 120.9 2006/03/21 04:43:19 ukottama noship $ */

g_jrad_rgn_pkg_name	CONSTANT VARCHAR2(50) := '/oracle/apps/pon/forms/jrad/webui/';

g_fnd_debug 		CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name 		CONSTANT VARCHAR2(30) := 'PON_FORMS_UTIL_PVT';
g_module_prefix 	CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';


g_newline Varchar2(10);
g_alias_counter number :=0;
g_bind_char Varchar2(10) := ':';
g_mode Varchar2(10):='XML';
g_dummy_char Varchar2(10) := 'Y#X';
g_dummy_num Number := 1025;
g_dummy_PK  Varchar2(10) := '-9998';

g_date_sequence_number         NUMBER;

g_number_sequence_number 	 NUMBER;

g_text_sequence_number 	 NUMBER;

g_internal_sequence_number	 NUMBER;



--------------------------  HELPER FUNCTIONS ----------------------------------

PROCEDURE printClobOut(result IN CLOB);
PROCEDURE printLong(result IN Varchar2);

PROCEDURE  INSERT_LEVEL1_SECTION_IN_FORM(p_form_id	IN	NUMBER,
                        p_level1_section_id	IN	NUMBER);

PROCEDURE  INSERT_LEVEL2_SECTION_IN_FORM(p_form_id	IN	NUMBER,
                        p_level1_section_id	IN	NUMBER,
                        p_level2_section_id	IN	NUMBER);

Procedure GetValSetTBLQuery(
          p_value_set_name  in Varchar2,
          p_query_stmt      in out NOCOPY Varchar2,
          p_orderby         in out NOCOPY Varchar2,
          p_id_column_exists OUT NOCOPY Varchar2,
          p_error OUT NOCOPY VARCHAR2,
          p_result OUT NOCOPY number -- 0: Success, 1: failure
          );



Procedure CreateDummyRowForXML(
          p_value_pk_id Number,
          p_form_id  number,
          p_section_id Number,
          p_parent_fk_id Number,
          p_level1_section_id Number,
          p_level2_section_id Number,
          p_error IN OUT NOCOPY VARCHAR2,
          p_result IN OUT NOCOPY number -- 0: Success, 1: failure
	);
--------------------------  END HELPER FUNCTIONS ------------------------------



/*======================================================================
 FUNCTON:  getDataEntryRegionName	PRIVATE
   PARAMETERS:
   COMMENT   :
======================================================================*/

FUNCTION getDataEntryRegionName(p_form_id IN NUMBER) RETURN VARCHAR2 IS

v_form_code 	PON_FORMS_SECTIONS.FORM_CODE%TYPE;
v_form_version 	PON_FORMS_SECTIONS.FORM_VERSION%TYPE;
v_type		PON_FORMS_SECTIONS.TYPE%TYPE;

l_api_name	CONSTANT VARCHAR2(30) := 'getDataEntryRegionName';

BEGIN

print_debug_log(l_api_name, 'BEGIN- p_form_id = '||p_form_id);

select 	form_code , form_version , type
into   	v_form_code, v_form_version, v_type
from 	pon_forms_sections where form_id = p_form_id;

print_debug_log(l_api_name, 'END- DataEntryRegionName = '|| g_jrad_rgn_pkg_name || 'pon_'|| v_form_code || '_V' || to_char(v_form_version) || '_RG');

return g_jrad_rgn_pkg_name || 'pon_'|| v_form_code || '_V' || to_char(v_form_version) || '_RG';

END getDataEntryRegionName;

/*======================================================================
 FUNCTON:  getReadOnlyRegionName	PRIVATE
   PARAMETERS:
   COMMENT   :
======================================================================*/

FUNCTION getReadOnlyRegionName(p_form_id IN NUMBER) RETURN VARCHAR2 IS

v_form_code 	PON_FORMS_SECTIONS.FORM_CODE%TYPE;
v_form_version 	PON_FORMS_SECTIONS.FORM_VERSION%TYPE;
v_type		PON_FORMS_SECTIONS.TYPE%TYPE;

l_api_name	CONSTANT VARCHAR2(30) := 'getReadOnlyRegionName';

BEGIN

print_debug_log(l_api_name, 'BEGIN- p_form_id = '||p_form_id);

select form_code , form_version , type
into   v_form_code, v_form_version, v_type
from pon_forms_sections where form_id = p_form_id;

print_debug_log(l_api_name, 'END- ReadOnlyRegionName = '||g_jrad_rgn_pkg_name || 'pon_'|| v_form_code || '_V' || to_char(v_form_version) || '_DSP_RG');

return g_jrad_rgn_pkg_name || 'pon_'|| v_form_code || '_V' || to_char(v_form_version) || '_DSP_RG';

END getReadOnlyRegionName;


/*======================================================================
 FUNCTON:  getFlexValuePVT	PRIVATE
   PARAMETERS:
   COMMENT   :
======================================================================*/


FUNCTION getFlexValuePVT(p_field_code IN VARCHAR2, p_field_value IN VARCHAR2) RETURN VARCHAR2 IS

l_validation_type VARCHAR2(1);
l_ret_val	  VARCHAR2(2000);
l_vset_name 	PON_FIELDS.VALUE_SET_NAME%TYPE;
l_err_num   NUMBER;
l_err_msg   VARCHAR2(200);
l_api_name	CONSTANT VARCHAR2(30) := 'getFlexValuePVT';
BEGIN

 print_debug_log(l_api_name, 'BEGIN- p_field_code = '||p_field_code||' p_field_value = '||p_field_value);

	-- just in case something bad happens
	l_ret_val := p_field_value;

	SELECT 	fnd_flex_value_sets.VALIDATION_TYPE, fnd_flex_value_sets.flex_value_set_name
	INTO	l_validation_type, l_vset_name
	FROM	fnd_flex_value_sets, pon_fields
	WHERE 	fnd_flex_value_sets.FLEX_VALUE_SET_NAME  = pon_fields.VALUE_SET_NAME
	AND	pon_fields.FIELD_CODE = P_FIELD_CODE;

	IF(l_validation_type = 'F') THEN
		l_ret_val := PON_FORMS_UTIL_PVT.getFlexTblValue(p_field_code, p_field_value);
	ELSIF ((l_validation_type = 'X') or (l_validation_type = 'I')) THEN
		l_ret_val := PON_FORMS_UTIL_PVT.GetFLEXINDENDENTVALUE(l_vset_name, p_field_value);
	END IF;

	print_debug_log(l_api_name, 'END l_ret_val = '||l_ret_val);

	return l_ret_val;

	EXCEPTION
		WHEN OTHERS THEN
    l_err_num := SQLCODE;
    l_err_msg := SUBSTR(SQLERRM, 1, 200);
    print_error_log(l_api_name ,'EXCEPTION for p_field_code = '||p_field_code||' p_field_value = '||p_field_value||' l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);

		RETURN P_FIELD_VALUE;
END getFlexValuePvt;

/*======================================================================
 FUNCTON:  getFlexValue		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/


FUNCTION getFlexValue(p_field_code IN VARCHAR2, p_mapping_column IN VARCHAR2, p_form_field_id IN NUMBER) RETURN VARCHAR2 IS

l_query_stmt  VARCHAR2(1000);
l_field_value VARCHAR2(2000);
l_display_value VARCHAR2(2000);
l_err_num   NUMBER;
l_err_msg   VARCHAR2(200);
l_api_name	CONSTANT VARCHAR2(30) := 'getFlexValue';

BEGIN

	print_debug_log(l_api_name, 'BEGIN- p_field_code = '||p_field_code||' p_mapping_column = '||p_mapping_column);

	l_display_value := to_char(null);
	l_query_stmt := 'select ' || upper(p_mapping_column) || ' from pon_form_field_values where form_field_value_id = :1' ;

	EXECUTE IMMEDIATE l_query_stmt INTO l_field_value USING p_form_field_id;

	--dbms_output.put_line(l_api_name || ' ' || l_field_value);

	IF(nvl(l_field_value, 'xYz') <> 'xYz') THEN
	      l_display_value := getFlexValuePvt(p_field_code, l_field_value);
	END IF;

  print_debug_log(l_api_name, 'END l_display_value = '||l_display_value);

	RETURN l_display_value;

	EXCEPTION
		WHEN OTHERS THEN

    l_err_num := SQLCODE;
    l_err_msg := SUBSTR(SQLERRM, 1, 200);
		print_error_log(l_api_name ,'EXCEPTION for p_field_code = '||p_field_code||' p_mapping_column = '||p_mapping_column||' l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);

		RETURN L_FIELD_VALUE;
END getFlexValue;



/*======================================================================
 FUNCTON:  GetMappingColumn		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
Procedure GetMappingColumn(p_datatype in Varchar2,
                p_mapping_column in out NOCOPY Varchar2) is

l_api_name	CONSTANT VARCHAR2(30) := 'GetMappingColumn';

Begin

print_debug_log(l_api_name, 'BEGIN- p_datatype = '||p_datatype||' p_mapping_column = '||p_mapping_column);

            if p_datatype = 'TEXT'  then

              g_text_sequence_number := g_text_sequence_number + 1;
              p_mapping_column := 'Textcol'||g_text_sequence_number;

            elsif p_datatype = 'DATE' or p_datatype = 'DATETIME' then

              g_date_sequence_number := g_date_sequence_number + 1;
              p_mapping_column := 'Datecol'||g_date_sequence_number;

            else

              g_number_sequence_number := g_number_sequence_number + 1;
              p_mapping_column := 'Numbercol'||g_number_sequence_number;

            end if;

print_debug_log(l_api_name, 'END- p_datatype = '||p_datatype||' p_mapping_column = '||p_mapping_column);

end GetMappingColumn;



/*======================================================================
 FUNCTON:  InsertCompiledRow		PRIVATE
   PARAMETERS:
   COMMENT   :
======================================================================*/
Procedure InsertCompiledRow( p_FORM_SECTION_FIELD_ID Number,
                           p_form_id Number,
                           p_type Varchar2,
                           p_field_code Varchar2,
                           p_INTERNAL_SEQUENCE_NUMBER Number,
                           p_MAPPING_FIELD_VALUE_COLUMN Varchar2,
                           p_REQUIRED Varchar2,
                           p_LEVEL1_SECTION_ID Number,
                           p_LEVEL2_SECTION_ID Number,
                           p_REPEATING_SECTION_ID Number,
                           p_DISPLAY_ON_MAIN_PAGE Varchar2,
                           p_ENABLED  Varchar2) is

l_api_name	CONSTANT VARCHAR2(30) := 'InsertCompiledRow';

begin

print_debug_log(l_api_name, 'BEGIN- p_FORM_SECTION_FIELD_ID = '||p_FORM_SECTION_FIELD_ID||'
                p_form_id = '||p_form_id||'
                p_type = '||p_type||'
                p_field_code = '||p_field_code||'
                p_INTERNAL_SEQUENCE_NUMBER = '||p_INTERNAL_SEQUENCE_NUMBER||'
                p_REQUIRED = '||p_REQUIRED||'
                p_MAPPING_FIELD_VALUE_COLUMN = '||p_MAPPING_FIELD_VALUE_COLUMN||'
                p_LEVEL1_SECTION_ID = '||p_LEVEL1_SECTION_ID||'
                p_LEVEL2_SECTION_ID = '||p_LEVEL2_SECTION_ID||'
                p_REPEATING_SECTION_ID = '||p_REPEATING_SECTION_ID||'
                p_DISPLAY_ON_MAIN_PAGE = '||p_DISPLAY_ON_MAIN_PAGE||'
                p_ENABLED = '||p_ENABLED);

               insert into pon_form_section_compiled
               (FORM_SECTION_FIELD_ID,
                FORM_ID,
                TYPE,
                FIELD_CODE,
                INTERNAL_SEQUENCE_NUMBER,
                MAPPING_FIELD_VALUE_COLUMN,
                REQUIRED,
                LEVEL1_SECTION_ID,
                LEVEL2_SECTION_ID,
                REPEATING_SECTION_ID,
                DISPLAY_ON_MAIN_PAGE,
                ENABLED,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN)
                values
                ( p_FORM_SECTION_FIELD_ID ,
                  p_form_id ,
                  p_type,
                  p_field_code ,
                  p_INTERNAL_SEQUENCE_NUMBER ,
                  p_MAPPING_FIELD_VALUE_COLUMN ,
                  p_REQUIRED ,
                  p_LEVEL1_SECTION_ID ,
                  p_LEVEL2_SECTION_ID ,
                  p_REPEATING_SECTION_ID ,
                  p_DISPLAY_ON_MAIN_PAGE,
                  p_ENABLED,
                  sysdate,
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.user_id,
                  fnd_global.user_id
                );

print_debug_log(l_api_name, 'END ');

end InsertCompiledRow;

PROCEDURE printClobOut(result IN CLOB) is
xmlstr varchar2(32767);
line varchar2(2000);
l_index Number;
begin
 g_newline := fnd_global.newline();
  xmlstr := dbms_lob.SUBSTR(result,32767);
  loop
    exit when xmlstr is null;
    l_index := instr(xmlstr,g_newline);
    line := substr(xmlstr,1,l_index-1);
    --dbms_output.put_line(line);
    xmlstr := substr(xmlstr,l_index+1);
  end loop;
End;

PROCEDURE printLong(result IN Varchar2) is
xmlstr Varchar2(31500);
line varchar2(2000);
l_index Number;
begin
 xmlstr := result;
 g_newline := fnd_global.newline();
  loop
    exit when xmlstr is null;
    l_index := instr(xmlstr,g_newline);
    line := substr(xmlstr,1,l_index-1);
    --dbms_output.put_line(line);
    xmlstr := substr(xmlstr,l_index+1);
  end loop;
End;


/*======================================================================
 FUNCTON:  Get_Freight		PRIVATE
   PARAMETERS:
   COMMENT   :
======================================================================*/
Function Get_Freight(p_carrier_code IN Varchar2,
                    p_inventory_organization_id IN Number)
     return Varchar2 is
rt_value Varchar2(80);
l_err_num               NUMBER;
l_err_msg               VARCHAR2(200);

l_api_name	CONSTANT VARCHAR2(30) := 'Get_Freight';

Begin

print_debug_log(l_api_name, 'BEGIN- p_carrier_code = '||p_carrier_code||'
                p_inventory_organization_id = '||p_inventory_organization_id);

select description
into rt_value
from org_freight_tl
where LANGUAGE			= userenv('LANG')
and ORGANIZATION_ID	= p_inventory_organization_id
and  FREIGHT_CODE = p_carrier_code;

print_debug_log(l_api_name, 'END rt_value = '||rt_value);

return rt_value;

exception when others then
 l_err_num := SQLCODE;
 l_err_msg := SUBSTR(SQLERRM, 1, 200);
 print_error_log(l_api_name ,'EXCEPTION for p_carrier_code = '||p_carrier_code||' l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);
 return p_carrier_code;
End;



/*======================================================================
 FUNCTON:  GetSYSTEMDate		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
Function GetSYSTEMDate(p_field_code in Varchar2,
                       p_id in Varchar2) return Date is
rt_date Date;
l_stmt Varchar2(250);
l_err_num               NUMBER;
l_err_msg               VARCHAR2(200);
l_api_name	CONSTANT VARCHAR2(30) := 'GetSYSTEMDate';

begin

print_debug_log(l_api_name, 'BEGIN- p_field_code = '||p_field_code||'
                p_id = '||p_id);

if p_id=g_dummy_pk then

print_debug_log(l_api_name, 'END rt_date (g_dummy_pk)= '||sysdate);

return(sysdate);

end if;

l_stmt := 'Selecting ' || p_field_code || ' with auction_header_id = to_number('||p_id||')';

print_debug_log(l_api_name, 'l_stmt = '||l_stmt);


if p_field_code = 'AWARD_DATE' then

  select AWARD_BY_DATE into rt_date from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'CLOSE_DATE' then

  select CLOSE_BIDDING_DATE into rt_date from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'OPEN_DATE' then

  select OPEN_BIDDING_DATE into rt_date from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'PREVIEW_DATE' then

  select VIEW_BY_DATE into rt_date from pon_auction_headers_all where auction_header_id = to_number(p_id);

end if;

print_debug_log(l_api_name, 'END rt_date = '||rt_date);

return rt_date;
exception when others then

  l_err_num := SQLCODE;
  l_err_msg := SUBSTR(SQLERRM, 1, 200);
  print_error_log(l_api_name ,'EXCEPTION for p_field_code = '||p_field_code||' p_id = '||p_id||' l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);

  return TO_DATE(NULL) ;
end;


/*======================================================================
 FUNCTON:  GetSYSTEMNumber		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
Function GetSYSTEMNumber(p_field_code in Varchar2,
                       p_id in Varchar2) return Number is
rt_value Number;
l_stmt Varchar2(250);

l_err_num               NUMBER;
l_err_msg               VARCHAR2(200);
l_api_name	CONSTANT VARCHAR2(30) := 'GetSYSTEMNumber';

begin

print_debug_log(l_api_name, 'BEGIN- p_field_code = '||p_field_code||'
                p_id = '||p_id);

if p_id=g_dummy_pk then

print_debug_log(l_api_name, 'END rt_value (g_dummy_num)= '||g_dummy_num);
return g_dummy_num;

end if;
l_stmt := 'Selecting ' || p_field_code || ' with auction_header_id = to_number('||p_id||')';

print_debug_log(l_api_name, 'l_stmt = '||l_stmt);

if p_field_code = 'PAYMENT_TERMS' then

  select PAYMENT_TERMS_ID into rt_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'ORGANIZATION' then

  select ORG_ID into rt_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'AUCTION_HEADER_ID' then

  select AUCTION_HEADER_ID into rt_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

end if;

print_debug_log(l_api_name, 'END rt_value = '||rt_value);

return rt_value;

exception when others then

  l_err_num := SQLCODE;
  l_err_msg := SUBSTR(SQLERRM, 1, 200);
  print_error_log(l_api_name ,'EXCEPTION for p_field_code = '||p_field_code||' p_id = '||p_id||' l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);
  return TO_NUMBER(NULL) ;

end;


/*======================================================================
 FUNCTON:  GetSYSTEMChar		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
Function GetSYSTEMChar(p_field_code in Varchar2,
                       p_id in Varchar2) return Varchar2 is
rt_value Varchar2(500);
rt_large_value Varchar2(4000);
l_stmt Varchar2(250);

l_api_name	CONSTANT VARCHAR2(30) := 'GetSYSTEMChar';
l_err_num               NUMBER;
l_err_msg               VARCHAR2(200);
begin

print_debug_log(l_api_name, 'BEGIN- p_field_code = '||p_field_code||'
                p_id = '||p_id);

if p_id=g_dummy_pk then

print_debug_log(l_api_name, 'END rt_value (g_dummy_pk)= Dummy data');

return('Dummy data');

end if;

l_stmt := 'Selecting ' || p_field_code || ' with auction_header_id = to_number('||p_id||')';

print_debug_log(l_api_name, 'l_stmt = '||l_stmt);

if p_field_code = 'ABSTRACT_STATUS' then

  select ABSTRACT_STATUS into rt_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'AMENDMENT_DESCRIPTION' then

  select AMENDMENT_DESCRIPTION into rt_large_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'TITLE' then

  select AUCTION_TITLE into rt_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'STYLE' then

  select BID_VISIBILITY_CODE into rt_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'CARRIER' then

  select CARRIER_CODE into rt_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'NEGOTIATION_CURR' then

  select CURRENCY_CODE into rt_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'NEGOTIATION_NUM' then

  select DOCUMENT_NUMBER into rt_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'EVENT' then

  select EVENT_TITLE into rt_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'FOB' then

  select FOB_CODE into rt_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'FREIGHT_TERMS' then

  select FREIGHT_TERMS_CODE into rt_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'BUYER' then

  select DOCUMENT_NUMBER into rt_value from pon_auction_headers_all where auction_header_id = to_number(p_id);

elsif p_field_code = 'PAYMENT_TERMS_NAME' then

  select atvl_1.NAME
  into rt_value
  from
  PON_AUCTION_HEADERS_ALL ah,
  AP_TERMS_VL atvl_1
  where
  ah.auction_header_id = to_number(p_id)
  and atvl_1.TERM_ID(+) = ah.PAYMENT_TERMS_ID;

elsif p_field_code = 'CARRIER_NAME' then

  select
  PON_FORMS_UTIL_PVT.GET_FREIGHT(ah.carrier_code, fsp.inventory_organization_id)
  into rt_large_value
  from pon_auction_headers_all ah,
  financials_system_params_all fsp
  where ah.auction_header_id = to_number(p_id)
  and fsp.org_id(+) = ah.org_id;

elsif p_field_code = 'DISPLAY_PDF_FLAG' then

  select
  decode( nvl(ah.INCLUDE_PDF_IN_EXTERNAL_PAGE, 'N'), 'Y', 'SHOW_PDF', 'HIDE_PDF') DISPLAY_PDF_FLAG
  into rt_value
  from pon_auction_headers_all ah
  where ah.auction_header_id = to_number(p_id);

elsif p_field_code = 'NEGOTIATION_TYPE' then

  select doc.internal_name
  into rt_value
  from
  pon_auction_headers_all ah,
  PON_AUC_DOCTYPES doc
  where
  ah.auction_header_id = to_number(p_id)
  and ah.DOCTYPE_ID = doc.DOCTYPE_ID;

elsif p_field_code = 'NEGOTIATION_TYPE_NAME' then

  select doctl.NAME
  into rt_value
  from pon_auction_headers_all ah,
  PON_AUC_DOCTYPES_TL doctl
  where
  ah.auction_header_id = to_number(p_id)
  and ah.DOCTYPE_ID = doctl.DOCTYPE_ID
  and doctl.LANGUAGE = userenv('LANG');

elsif p_field_code = 'STYLE_NAME' then

  select
  lookup_1.MEANING
  into
  rt_value
  from pon_auction_headers_all ah,
  FND_LOOKUP_VALUES lookup_1
  where
  ah.auction_header_id = to_number(p_id)
  and lookup_1.LOOKUP_CODE(+) = ah.BID_VISIBILITY_CODE
  and lookup_1.VIEW_APPLICATION_ID (+) = 0
  and lookup_1.SECURITY_GROUP_ID (+) = 0
  and lookup_1.LOOKUP_TYPE(+) = 'PON_BID_VISIBILITY_CODE'
  and lookup_1.LANGUAGE(+) = userenv('LANG');

elsif p_field_code = 'FOB_NAME' then

  select
  lookup_2.MEANING
  into rt_value
  from pon_auction_headers_all ah,
  FND_LOOKUP_VALUES lookup_2
  where ah.auction_header_id = to_number(p_id)
  and lookup_2.lookup_code(+) = ah.fob_code
  and lookup_2.LOOKUP_TYPE(+) = 'FOB'
  and lookup_2.LANGUAGE(+) = userenv('LANG')
  and lookup_2.SECURITY_GROUP_ID (+) = 0
  and lookup_2.VIEW_APPLICATION_ID(+) = 201;

elsif p_field_code = 'FREIGHT_TERMS_NAME' then

  select
  lookup_3.MEANING
  into
  rt_value
  from pon_auction_headers_all ah,
  FND_LOOKUP_VALUES lookup_3
  where ah.auction_header_id = to_number(p_id)
  and lookup_3.LOOKUP_CODE(+) = ah.FREIGHT_TERMS_CODE
  and lookup_3.lookup_type ='FREIGHT TERMS'
  and lookup_3.LANGUAGE(+) = userenv('LANG')
  and lookup_3.SECURITY_GROUP_ID (+) = 0
  and lookup_3.VIEW_APPLICATION_ID(+) = 201;

elsif p_field_code = 'ORGANIZATION_NAME' then

  select
  org.NAME
  into
  rt_value
  from pon_auction_headers_all ah,
  HR_ALL_ORGANIZATION_UNITS_TL org
  where ah.auction_header_id = to_number(p_id)
  and org.ORGANIZATION_ID = ah.ORG_ID
  and org.LANGUAGE = userenv('LANG');
end if;

if (p_field_code = 'CARRIER_NAME' or p_field_code = 'AMENDMENT_DESCRIPTION') then
		print_debug_log(l_api_name, 'END rt_large_value = '||rt_large_value);
		return rt_large_value;
else
		print_debug_log(l_api_name, 'END rt_value = '||rt_value);
		return rt_value;
end if;

exception when others then
  l_err_num := SQLCODE;
  l_err_msg := SUBSTR(SQLERRM, 1, 200);
  print_error_log(l_api_name ,'EXCEPTION for p_field_code = '||p_field_code||' p_id = '||p_id||' l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);
  return NULL ;
end;


/*======================================================================
 FUNCTON:  GetValSetQueryIdOrder		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
Procedure GetValSetQueryIdOrder (
          p_value_set_name IN VARCHAR2,
          p_query_stmt OUT NOCOPY Varchar2,
          p_orderby OUT NOCOPY Varchar2,
          p_id_column_exists OUT NOCOPY Varchar2,
          p_is_table_based OUT NOCOPY VARCHAR2,
          p_error OUT NOCOPY Varchar2,
          p_result OUT NOCOPY number
          ) IS
l_value_set_type Varchar2(10);
l_err_num               NUMBER;
l_err_msg               VARCHAR2(200);
l_api_name	CONSTANT VARCHAR2(30) := 'GetValSetQueryIdOrder';

Begin

p_result := 0;

print_debug_log(l_api_name, 'BEGIN- p_value_set_name = '||p_value_set_name);

    select validation_type
    into l_value_set_type
    from  fnd_flex_value_sets
    where FLEX_VALUE_SET_NAME = p_value_set_name;

    if (l_value_set_type = 'F') then
       GetValSetTBLQuery (p_value_set_name =>p_value_set_name,
			  p_query_stmt => p_query_stmt,
			  p_orderby => p_orderby,
			  p_id_column_exists=> p_id_column_exists,
			  p_error => p_error,
			  p_result => p_result);
       p_is_table_based := 'Y';
    else
       p_is_table_based := 'N';
    end if;

   print_debug_log(l_api_name, 'END p_query_stmt = '||p_query_stmt ||'
          p_orderby = '|| p_orderby ||'
          p_id_column_exists = '|| p_id_column_exists ||'
          p_is_table_based = '|| p_is_table_based ||'
          p_error = '|| p_error ||'
          p_result = '|| p_result);

EXCEPTION when others then
	p_result := 1;
  p_error := PON_AUCTION_PKG.getMessage ('PON_INVALID_VALSET_DEF');
  l_err_num := SQLCODE;
  l_err_msg := SUBSTR(SQLERRM, 1, 200);
  print_error_log(l_api_name ,'EXCEPTION for GetValSetQueryIdOrder p_value_set_name= '|| p_value_set_name ||' l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);
End GetValSetQueryIdOrder;


/*======================================================================
 FUNCTON:  GetValSetTBLQuery		PRIVATE
   PARAMETERS:
   COMMENT   :
======================================================================*/
Procedure GetValSetTBLQuery(
          p_value_set_name  in Varchar2,
          p_query_stmt      in out NOCOPY Varchar2,
          p_orderby         in out NOCOPY Varchar2,
          p_id_column_exists OUT NOCOPY Varchar2,
          p_error OUT NOCOPY VARCHAR2,
          p_result OUT NOCOPY number -- 0: Success, 1: failure
          ) IS
l_query_stmt Varchar2(4000);
l_success  Number;
l_id_column_name Varchar2(240) := NULL;
l_value_column_name Varchar2(240) := NULL;
l_mapping_code  Varchar2(80);
l_from_index    Number;
l_orderby_index    Number;
l_where_index	NUMBER;
l_where_clause  VARCHAR2(4000);

l_api_name	CONSTANT VARCHAR2(30) := 'GetValSetTBLQuery';
PON_INVALID_VALSET_EXCEPTION EXCEPTION;

Begin

p_result := 0;

print_debug_log(l_api_name, 'BEGIN- p_value_set_name = '||p_value_set_name||'
                p_query_stmt = '||p_query_stmt||'
                p_orderby = '||p_orderby);

 select VALUE_COLUMN_NAME, ID_COLUMN_NAME
            into l_value_column_name,l_id_column_name
            from fnd_flex_validation_tables tbl, fnd_flex_value_sets val
            where tbl.flex_value_set_id  =val.flex_value_set_id
            and val.flex_value_set_name = p_value_set_name;

 print_debug_log(l_api_name, ' l_value_column_name = '||l_value_column_name||'
                l_id_column_name = '||l_id_column_name);

    fnd_flex_val_api.get_table_vset_select( p_value_set_name =>p_value_set_name,
                                        x_select        => l_query_stmt,
                                        x_mapping_code  => l_mapping_code,
                                        x_success       => l_success);

 print_debug_log(l_api_name, ' l_query_stmt = '||l_query_stmt);

l_query_stmt := upper(l_query_stmt);
l_from_index := instr(l_query_stmt,'FROM');
l_where_index := instr (l_query_stmt, 'WHERE');
l_orderby_index := instr(l_query_stmt,'ORDER BY') ;

print_debug_log(l_api_name, ' l_query_stmt = '||l_query_stmt||' l_from_index = '||l_from_index||' l_orderby_index = '||l_orderby_index);

if l_where_index > l_from_index then
  if (l_orderby_index > l_where_index) then
    l_where_clause := substr (l_query_stmt, l_where_index, l_orderby_index - l_where_index -1);
  else
    l_where_clause := substr (l_query_stmt, l_where_index);
  end if;

  print_debug_log(l_api_name, 'index of $ = ' ||  instr (l_where_clause, '$'));

  if (instr (l_where_clause, '$') <> 0 OR instr (l_where_index, ':') <> 0) then
    RAISE PON_INVALID_VALSET_EXCEPTION;
  end if;
end if;

if L_ID_COLUMN_NAME is not null then
  p_id_column_exists := 'Y';
  p_query_stmt := 'Select ' || L_ID_COLUMN_NAME || ' AS ID_COLUMN ,'
                    || g_newline || substr(l_value_column_name,1,500) || ' AS VALUE_COLUMN ';
else
  p_id_column_exists := 'N';
  -- if the ID column does not exist, just return the same column twice
  p_query_stmt := 'Select ' || l_value_column_name || ' AS ID_COLUMN ,'
			|| g_newline || l_value_column_name ||  ' AS VALUE_COLUMN ';
end if;

print_debug_log(l_api_name, 'p_id_column_exists = '||p_id_column_exists ||' p_query_stmt = '||p_query_stmt);

if l_orderby_index >l_from_index then
   p_query_stmt := p_query_stmt || g_newline ||
        substr(l_query_stmt,l_from_index,l_orderby_index-l_from_index - 1);
p_orderby := substr(l_query_stmt,l_orderby_index);
else
   p_query_stmt := p_query_stmt || g_newline ||
        substr(l_query_stmt,l_from_index);
p_orderby := NULL;
end if;

print_debug_log(l_api_name, ' END =
           p_query_stmt = '|| p_query_stmt ||'
           p_orderby = '|| p_orderby ||'
           p_id_column_exists = '|| p_id_column_exists ||'
           p_error = '|| p_error ||'
           p_result = '|| p_result);

EXCEPTION when PON_INVALID_VALSET_EXCEPTION then
	p_result := 1;
        p_error := PON_AUCTION_PKG.getMessage ('PON_INVALID_VALSET_DEF');
End GetValSetTBLQuery;



/*======================================================================
 FUNCTON:  GetFLEXINDENDENTVALUE		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
Function GetFLEXINDENDENTVALUE(p_value_set_name in varchar2,
                               p_id_value in Varchar2) Return Varchar2 IS
l_err_num               NUMBER;
l_err_msg               VARCHAR2(200);
rt_value Varchar2(150);
cursor get_value is
select tl.FLEX_VALUE_MEANING
from fnd_flex_values_tl tl,
     fnd_flex_values val,
     fnd_flex_value_sets valset
where tl.flex_value_id = val.flex_value_id
and   tl.language = USERENV('LANG')
and   val.flex_value_set_id = valset.flex_value_set_id
and   valset.flex_value_set_name = p_value_set_name
and   val.FLEX_VALUE    = p_id_value;

l_api_name	CONSTANT VARCHAR2(30) := 'GetFLEXINDENDENTVALUE';

Begin

print_debug_log(l_api_name, 'BEGIN- p_value_set_name = '||p_value_set_name||'
                p_id_value = '||p_id_value);

if p_id_value = g_dummy_char then
  rt_value := p_id_value;
else
  open get_value;
  fetch get_value into rt_value;
  close get_value;
end if;

print_debug_log(l_api_name, ' END  rt_value = '|| rt_value );

return rt_value;

exception when others then
l_err_num := SQLCODE;
l_err_msg := SUBSTR(SQLERRM, 1, 200);
print_error_log(l_api_name ,'EXCEPTION for p_value_set_name = '||p_value_set_name||' p_id_value = '||p_id_value||' l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);

return p_id_value;

End GetFLEXINDENDENTVALUE;



/*======================================================================
 FUNCTON:  GetFLEXTBLVALUE		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
Function GetFLEXTBLVALUE(p_field_code in varchar2,
                         p_id_value in Varchar2) Return Varchar2 IS

l_err_num               NUMBER;
l_err_msg               VARCHAR2(200);
rt_value 		Varchar2(500);
l_query_stmt 		Varchar2(4000);
l_success  		Number;
l_value_column_name 	VARCHAR2(240) := NULL;
l_id_column_name 	Varchar2(240) := NULL;
l_id_column_exists 	Varchar2(10) := NULL;
l_mapping_code  	Varchar2(80);
l_id_value      	Varchar2(500);

l_api_name	CONSTANT VARCHAR2(30) := 'GetFLEXTBLVALUE';

Begin

print_debug_log(l_api_name, 'BEGIN- p_field_code = '||p_field_code||'
                p_id_value = '||p_id_value);

if p_id_value = g_dummy_char then
  rt_value := p_id_value;
else
   select 	tbl.ID_COLUMN_NAME, tbl.VALUE_COLUMN_NAME, fld.VALUE_SET_QUERY,	fld.VALUE_SET_ID_EXISTS
   into 	l_id_column_name,   l_value_column_name,   l_query_stmt,	l_id_column_exists
   from 	fnd_flex_validation_tables tbl,
        	fnd_flex_value_sets val,
        	pon_fields fld
   where 	tbl.flex_value_set_id  	= val.flex_value_set_id
   and 		val.flex_value_set_name = fld.value_set_name
   and 		fld.field_code 		= p_field_code;

   print_debug_log(l_api_name, 'l_id_column_name = '|| l_id_column_name ||'
                                l_query_stmt = '||l_query_stmt ||'
                                l_id_column_exists = '||l_id_column_exists);

   if L_ID_COLUMN_NAME is null then
      rt_value := p_id_value;
   elsif L_ID_COLUMN_NAME is not null and l_id_column_exists ='N' then
      rt_value := p_id_value;
   else
     if instr(l_query_stmt,'WHERE') >0 then
        l_query_stmt := l_query_stmt ||  g_newline || ' AND ' || l_value_column_name ||  ' = :1';
     else
        l_query_stmt := l_query_stmt ||  g_newline || ' WHERE ' || l_value_column_name ||  ' = :1';
     end if;

     l_query_stmt := l_query_stmt || ' AND ROWNUM = 1';

     print_debug_log(l_api_name, 'l_query_stmt = '|| l_query_stmt );

     EXECUTE IMMEDIATE l_query_stmt INTO rt_value, l_id_value USING p_id_value;
   end if;
end if;

print_debug_log(l_api_name, ' END  rt_value = '|| rt_value );

return rt_value;

exception when others then

l_err_num := SQLCODE;
l_err_msg := SUBSTR(SQLERRM, 1, 200);
print_error_log(l_api_name ,'EXCEPTION for p_field_code = '||p_field_code||' p_id_value = '||p_id_value||' l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);

return p_id_value;

End GetFLEXTBLVALUE;


/*======================================================================
 PROCEDURE:  ADDSTMTVALUESET		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
Procedure ADDSTMTVALUESET(p_field_code in Varchar2,
               p_value_alias in Varchar2,
               p_value_column in Varchar2,
               p_value_set_name in Varchar2,
               p_query_stmt in out nocopy Varchar2,
	             p_error IN OUT NOCOPY VARCHAR2,
	             p_result IN OUT NOCOPY number -- 0: Success, 1: failure
	             ) IS
l_err_num               NUMBER;
l_err_msg               VARCHAR2(200);
l_value_set_type Varchar2(10);
l_id_column_name Varchar2(240);
l_value_column_name Varchar2(240);

l_api_name	CONSTANT VARCHAR2(30) := 'ADDSTMTVALUESET';

Begin

print_debug_log(l_api_name, 'BEGIN- p_field_code = '||p_field_code||'
                p_value_alias = '||p_value_alias||'
                p_value_column = '||p_value_column||'
                p_value_set_name = '||p_value_set_name||'
                p_query_stmt = '||p_query_stmt);

select validation_type
into l_value_set_type
from  fnd_flex_value_sets
where FLEX_VALUE_SET_NAME = p_value_set_name;

print_debug_log(l_api_name, 'l_value_set_type = '||l_value_set_type);

if l_value_set_type in ('I','X') then
    p_query_stmt := p_query_stmt || g_newline || ',' || p_value_alias ||'.' ||p_value_column || ' AS ' || p_field_code
                   || g_newline || ',PON_FORMS_UTIL_PVT.GetFLEXINDENDENTVALUE('''|| p_value_set_name || ''','
                   || g_newline || '        ' ||  p_value_alias ||'.'|| p_value_column || ') AS ' || p_field_code || '_NM';
/* ==============================================================================
    p_query_stmt := p_query_stmt || g_newline || ',xmlelement("FIELDVALUE"'
                    || '  ,xmlattributes(' || p_value_alias ||'.' ||p_value_column || ' AS "CODE"'
                    || g_newline || '     ,PON_FORMS_UTIL_PVT.GetFLEXINDENDENTVALUE('''
                    || p_value_set_name || ''',' ||  p_value_alias ||'.'
                    || p_value_column || ') AS "DESCRIPTION"'
                    || ')) AS ' || p_field_code;
 ============================================================================== */
elsif l_value_set_type = 'F' then

      select VALUE_COLUMN_NAME, ID_COLUMN_NAME
      into l_value_column_name,l_id_column_name
       from fnd_flex_validation_tables tbl, fnd_flex_value_sets val
      where tbl.flex_value_set_id  =val.flex_value_set_id
      and val.flex_value_set_name = p_value_set_name;

      print_debug_log(l_api_name, 'l_value_column_name = '||l_value_column_name ||' l_id_column_name = '||l_id_column_name);

      if l_id_column_name is null then -- this is a single column value set

        p_query_stmt := p_query_stmt || g_newline || ',' || p_value_alias || '.'
                                  || p_value_column || ' AS ' || p_field_code;

      else

          p_query_stmt := p_query_stmt || g_newline || ',' || p_value_alias ||'.' ||p_value_column || ' AS ' || p_field_code
                   || g_newline || ',PON_FORMS_UTIL_PVT.GetFLEXTBLVALUE('''|| p_field_code || ''','
                   || g_newline || '    ' ||  p_value_alias ||'.'|| p_value_column || ') AS ' || p_field_code || '_NM';
/* ==============================================================================
          p_query_stmt := p_query_stmt || g_newline || ',xmlelement("FIELDVALUE"'
                    || '  ,xmlattributes(' || p_value_alias ||'.' ||p_value_column || ' AS "CODE"'
                    || g_newline || '     ,PON_FORMS_UTIL_PVT.GetFLEXTBLVALUE('''
                    || p_field_code || ''',' ||  p_value_alias ||'.' ||p_value_column
                    || ') AS "DESCRIPTION"'
                    || ')) AS ' || p_field_code;
 ============================================================================== */

      end if;

else

        p_query_stmt := p_query_stmt || g_newline || ',' || p_value_alias || '.' ||
                                  p_value_column || ' AS ' || p_field_code;

end if;

print_debug_log(l_api_name, 'END- p_query_stmt = '||p_query_stmt);

EXCEPTION
       WHEN OTHERS THEN
     p_result := 1;
     l_err_num := SQLCODE;
     l_err_msg := SUBSTR(SQLERRM, 1, 200);
   	print_error_log(l_api_name, 'EXCEPTION l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);
   	p_error := PON_AUCTION_PKG.getMessage ('PON_INVALID_VALSET_DEF');

End ADDSTMTVALUESET;



/*======================================================================
 PROCEDURE:  ADDSTMTFIELD		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
Procedure  ADDSTMTFIELD(p_field_code in Varchar2,
               p_datatype in Varchar2,
               p_value_alias in Varchar2,
               p_value_column in Varchar2,
               p_value_set_name in Varchar2,
               p_query_stmt in  out nocopy Varchar2,
	             p_error IN OUT NOCOPY VARCHAR2,
	             p_result IN OUT NOCOPY number -- 0: Success, 1: failure
	             ) IS

l_err_num               NUMBER;
l_err_msg               VARCHAR2(200);
l_date_value_column Varchar2(60);

l_api_name	CONSTANT VARCHAR2(30) := 'ADDSTMTFIELD';

Begin

print_debug_log(l_api_name, 'BEGIN- p_field_code = '||p_field_code||'
                p_datatype = '||p_datatype||'
                p_value_alias = '||p_value_alias||'
                p_value_column = '||p_value_column||'
                p_value_set_name = '||p_value_set_name||'
                p_query_stmt = '||p_query_stmt);

if p_datatype = 'NUMBER' then

   p_query_stmt := p_query_stmt || g_newline || ',' || p_value_alias || '.' ||
                                  p_value_column || ' AS ' || p_field_code;
elsif p_datatype = 'AMOUNT' then

   p_query_stmt := p_query_stmt || g_newline || ',' || p_value_alias || '.' ||
                                  p_value_column || ' AS ' || p_field_code;

elsif p_datatype = 'DATE' then

   l_date_value_column := p_value_alias || '.' ||p_value_column;

   p_query_stmt := p_query_stmt || g_newline || ',' || l_date_value_column || ' AS ' || p_field_code;

   p_query_stmt := p_query_stmt || g_newline || ',cursor (select to_char(' || l_date_value_column || ',''YYYY'') AS "YYYY"'
                    || g_newline || '    ,to_char(' || l_date_value_column || ',''MM'') AS "MM"'
                    || g_newline || '    ,to_char(' || l_date_value_column || ',''DD'') AS "DD"'
                    || g_newline || ' from dual) AS ' || p_field_code ||'_NM';


elsif p_datatype = 'DATETIME' then
   l_date_value_column := p_value_alias || '.' ||p_value_column;

   p_query_stmt := p_query_stmt || g_newline || ',' || l_date_value_column || ' AS ' || p_field_code;

   p_query_stmt := p_query_stmt || g_newline || ',cursor (select to_char(' || l_date_value_column || ',''YYYY'') AS "YYYY"'
                    || g_newline || '    ,to_char(' || l_date_value_column || ',''MM'') AS "MM"'
                    || g_newline || '    ,to_char(' || l_date_value_column || ',''DD'') AS "DD"'
                    || g_newline || '    ,to_char(' || l_date_value_column || ',''HH'') AS "HH"'
                    || g_newline || '    ,to_char(' || l_date_value_column || ',''MI'') AS "MI"'
                    || g_newline || '    ,to_char(' || l_date_value_column || ',''SS'') AS "SS"'
                    || g_newline || ' from dual) AS ' || p_field_code ||'_NM';
 elsif p_datatype = 'TEXT' then

     if p_value_set_name is null then

        print_debug_log(l_api_name, ' p_field_code = '||p_field_code||' value set name is null');

        p_query_stmt := p_query_stmt || g_newline || ',' || p_value_alias || '.' ||
                                  p_value_column || ' AS ' || p_field_code;

     else

         print_debug_log(l_api_name, ' p_field_code = '||p_field_code||' calling ADDSTMTVALUESET');

         ADDSTMTVALUESET(p_field_code => p_field_code,
               p_value_alias =>p_value_alias,
               p_value_column => p_value_column,
               p_value_set_name =>p_value_set_name,
               p_query_stmt => p_query_stmt,
               p_error => p_error,
               p_result => p_result);

        if p_result = 1 then
        	return;
        end if;

     end if;

end if;

print_debug_log(l_api_name, 'END p_query_stmt = '||p_query_stmt);

    EXCEPTION
       WHEN OTHERS THEN
     p_result := 1;
     l_err_num := SQLCODE;
     l_err_msg := SUBSTR(SQLERRM, 1, 200);
   	print_error_log(l_api_name, 'EXCEPTION l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);
   	p_error := PON_AUCTION_PKG.getMessage ('PON_FM_UNABLE_TO_ADD_FIELD');

end ADDSTMTFIELD;


/*======================================================================
 PROCEDURE:  ADDVIEWFORSECTION		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
Procedure ADDVIEWFORSECTION(
                     p_form_id in Number,
                     p_section_id in Number,
                     p_LEVEL1_SECTION_ID in Number,
                     p_LEVEL2_SECTION_ID in Number,
                     p_section_code in Varchar2,
                     p_parent_alias in Varchar2,
                     p_parent_fk_id in Number,
	                   p_query_stmt in out nocopy Varchar2,
	                   p_error IN OUT NOCOPY VARCHAR2,
	                   p_result IN OUT NOCOPY number -- 0: Success, 1: failure
                     ) is

l_value_alias Varchar2(30);

Cursor Section_field is
select rs.form_code repeating_section_code,
       ff.TYPE,
       ff.FIELD_CODE,
       ff.LEVEL1_SECTION_ID,
       ff.LEVEL2_SECTION_ID,
       ff.repeating_section_id repeating_section_id,
       ff.MAPPING_FIELD_VALUE_COLUMN,
       f.datatype,
       f.value_set_name,
       valset.flex_value_set_id value_set_id,
       valset.VALIDATION_TYPE
from pon_form_section_compiled ff,
      pon_forms_sections rs,
     pon_fields f,
     fnd_flex_value_sets valset
where ff.form_id = p_section_id
and rs.form_id(+) = ff.repeating_section_id
and ff.enabled ='Y'
and f.field_code(+) = ff.field_code
and f.value_set_name = valset.flex_value_set_name(+)
order by INTERNAL_SEQUENCE_NUMBER;
l_schema_pk_id Number;

l_api_name	CONSTANT VARCHAR2(30) := 'ADDVIEWFORSECTION';

Begin

p_result := 0;

print_debug_log(l_api_name, 'BEGIN- p_form_id = '||p_form_id||'
                p_section_id = '||p_section_id||'
                p_LEVEL1_SECTION_ID = '||p_LEVEL1_SECTION_ID||'
                p_LEVEL2_SECTION_ID = '||p_LEVEL2_SECTION_ID||'
                p_section_code = '||p_section_code||'
                p_parent_alias = '||p_parent_alias||'
                p_parent_fk_id = '||p_parent_fk_id||'
                g_mode = '||g_mode);

 l_value_alias := 'V_'|| to_char(g_alias_counter);
 if g_mode = 'SCHEMA' then
    l_schema_pk_id := g_alias_counter * -1;
   CreateDummyRowForXML(
          p_value_pk_id => l_schema_pk_id,
          p_form_id  => p_form_id,
          p_section_id => p_section_id,
          p_parent_fk_id => p_parent_fk_id,
          p_level1_section_id => p_level1_section_id,
          p_level2_section_id => p_level2_section_id,
          p_error => p_error,
          p_result => p_result);

          if p_result = 1 then
          	return;
          end if;
 end if;

 g_alias_counter := g_alias_counter + 1;

p_query_stmt := p_query_stmt || g_newline || ',Cursor (SELECT ' || l_value_alias || '.' || 'FORM_FIELD_VALUE_ID AS SECTION_PK_ID,'
                          || g_newline || l_value_alias || '.' || 'PARENT_FIELD_VALUES_FK AS PARENT_FK_ID' ;

print_debug_log(l_api_name, ' p_query_stmt = '||p_query_stmt);

for r1 in Section_field loop

    print_debug_log(l_api_name, 'p_form_id = '||p_form_id||'
                     r1.field_code = '||r1.field_code||'
                     r1.repeating_section_id = '||r1.repeating_section_id);

    if r1.field_code is not null then

    print_debug_log(l_api_name, 'p_form_id = '||p_form_id||'
                     ADDSTMTFIELD : r1.field_code = '||r1.field_code);

        ADDSTMTFIELD(p_field_code => r1.field_code,
                    p_datatype => r1.datatype,
                    p_value_alias => l_value_alias,
                    p_value_column => r1.MAPPING_FIELD_VALUE_COLUMN,
                    p_value_set_name => r1.value_set_name,
                    p_query_stmt=> p_query_stmt,
                    p_error => p_error,
                    p_result => p_result);

        if p_result = 1 then
        	return;
        end if;

    elsif r1.repeating_section_id is not null then
          -- recursively call the ADDVIEWFORSECTION API
        ADDVIEWFORSECTION( p_form_id => p_form_id,
                           p_section_id => r1.repeating_section_id,
                           p_LEVEL1_SECTION_ID => r1.LEVEL1_SECTION_ID,
                           p_LEVEL2_SECTION_ID => r1.LEVEL2_SECTION_ID,
                           p_section_code => r1.repeating_section_code,
                           p_parent_alias => l_value_alias,
                           p_parent_fk_id => l_schema_pk_id,
                           p_query_stmt=> p_query_stmt,
                           p_error => p_error,
                           p_result => p_result);

        if p_result = 1 then
        	return;
        end if;
    end if;
end loop;

p_query_stmt := p_query_stmt || ' from pon_form_field_values ' || l_value_alias
                  || g_newline || ' where ' ||  l_value_alias || '.PARENT_FIELD_VALUES_FK=' ||p_parent_alias||'.' ||'FORM_FIELD_VALUE_ID'
                  || g_newline || ' and ' ||  l_value_alias || '.section_id=' || to_char(p_section_id)
                  || g_newline || ' and nvl(' ||  l_value_alias || '.LEVEL1_SECTION_ID,-1)= ' || to_char(nvl(p_LEVEL1_SECTION_ID,-1))
                  || g_newline || ' and nvl(' ||  l_value_alias || '.LEVEL2_SECTION_ID,-1)= ' || to_char(nvl(p_LEVEL2_SECTION_ID,-1))
                  || g_newline || ' order by ' ||  l_value_alias || '.FORM_FIELD_VALUE_ID'
                  || g_newline || '        ) AS ' || p_Section_code;

print_debug_log(l_api_name, ' END p_query_stmt = '||p_query_stmt);

END ADDVIEWFORSECTION;


/*======================================================================
 PROCEDURE:  GENERATE_XMLQUERY		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
Procedure GENERATE_XMLQUERY (p_form_id  in Number, -- top form
                        p_query_stmt in out NOCOPY Varchar2,
                        p_error IN OUT NOCOPY VARCHAR2,
                        p_result IN OUT NOCOPY number -- 0: Success, 1: failure
                       ) IS

l_flex_val_alias Varchar2(30);
l_flex_val_tl_alias Varchar2(30);
l_value_column_size number;
l_id_column_size number;
l_tablebasedvalset_query        Varchar2(2000);
l_success NUMBER;
L_ID_COLUMN_exists  varchar2(10);
l_value_alias Varchar2(30);
l_prev_level1section_code Varchar2(30) := NULL;
l_prev_section_code Varchar2(30) := NULL;
l_form_code Varchar2(30);
l_schema_pk_id Number;

cursor l_form_entry_cursor is
select ff.TYPE,
       ts.form_code LEVEL1_SECTION_CODE,
       isec.form_code LEVEL2_SECTION_code,
       rs.form_code repeating_section_code,
       ff.LEVEL1_SECTION_ID  LEVEL1_SECTION_ID,
       ff.LEVEL2_SECTION_ID LEVEL2_SECTION_ID,
       ff.repeating_section_id repeating_section_id,
       ff.FIELD_CODE,
       ff.MAPPING_FIELD_VALUE_COLUMN,
       f.datatype,
       f.value_set_name,
       f.system_flag,
       f.SYSTEM_FIELD_LOV_FLAG,
       valset.flex_value_set_id value_set_id,
       valset.VALIDATION_TYPE
from pon_form_section_compiled ff,
     PON_FORMS_SECTIONS ts,
     PON_FORMS_SECTIONS isec,
     PON_FORMS_SECTIONS rs,
     pon_fields f,
     fnd_flex_value_sets valset
where ts.form_id(+) = ff.LEVEL1_SECTION_ID
and isec.form_id(+) = ff.LEVEL2_SECTION_ID
and rs.form_id(+) = ff.repeating_section_id
and ff.form_id = p_form_id
and ff.enabled ='Y'
and ff.field_code =f.field_code(+)
and f.value_set_name = valset.flex_value_set_name(+)
order by INTERNAL_SEQUENCE_NUMBER;

l_api_name	CONSTANT VARCHAR2(30) := 'GENERATE_XMLQUERY';

begin

p_result := 0;

print_debug_log(l_api_name, 'BEGIN- p_form_id = '||p_form_id||'
                p_query_stmt = '||p_query_stmt||'
                g_mode = '||g_mode);

 g_newline := fnd_global.newline();
 g_alias_counter :=1;
 l_value_alias := 'V_'|| to_char(g_alias_counter);

print_debug_log(l_api_name, 'l_value_alias = '||l_value_alias||' g_mode = '||g_mode);

 if g_mode = 'SCHEMA' then

    l_schema_pk_id := g_alias_counter * -1;

    print_debug_log(l_api_name, 'l_schema_pk_id = '||l_schema_pk_id);

    CreateDummyRowForXML(
          p_value_pk_id => l_schema_pk_id,
          p_form_id  => p_form_id,
          p_section_id =>-1,
          p_parent_fk_id => NULL,
          p_level1_section_id => NULL,
          p_level2_section_id => NULL,
          p_error => p_error,
          p_result => p_result);

          if p_result = 1 then
          	return;
          end if;

    print_debug_log(l_api_name, 'Inserted Dummy Row l_schema_pk_id = '||l_schema_pk_id||' p_form_id = '||p_form_id||' p_section_id = -1 p_parent_fk_id = NULL');

 end if;

 g_alias_counter := g_alias_counter + 1;

select form_code
into l_form_code
from PON_FORMS_SECTIONS
where form_id = p_form_id;

print_debug_log(l_api_name, 'l_form_code = '||l_form_code||' g_alias_counter = '||g_alias_counter);

--
p_query_stmt := 'SELECT ' || l_value_alias || '.' || 'FORM_FIELD_VALUE_ID AS FORM_PK_VALUE,'
                          || g_newline || l_value_alias || '.' || 'OWNING_ENTITY_CODE,'
                          || g_newline || l_value_alias || '.' || 'ENTITY_PK1';

print_debug_log(l_api_name, 'p_query_stmt = '|| p_query_stmt);

for r1 in l_form_entry_cursor loop

    print_debug_log(l_api_name, 'r1.TYPE = '||r1.TYPE ||'
       r1.LEVEL1_SECTION_CODE = '||r1.LEVEL1_SECTION_CODE ||'
       r1.LEVEL2_SECTION_code = '||r1.LEVEL2_SECTION_code ||'
       r1.repeating_section_code = '||r1.repeating_section_code ||'
       r1.LEVEL1_SECTION_ID = '||r1.LEVEL1_SECTION_ID ||'
       r1.LEVEL2_SECTION_ID = '||r1.LEVEL2_SECTION_ID ||'
       r1.repeating_section_id = '||r1.repeating_section_id ||'
       r1.FIELD_CODE = '||r1.FIELD_CODE ||'
       r1.MAPPING_FIELD_VALUE_COLUMN = '||r1.MAPPING_FIELD_VALUE_COLUMN ||'
       r1.datatype = '||r1.datatype ||'
       r1.value_set_name = '||r1.value_set_name ||'
       r1.system_flag = '||r1.system_flag ||'
       r1.SYSTEM_FIELD_LOV_FLAG = '||r1.SYSTEM_FIELD_LOV_FLAG ||'
       r1.value_set_id = '||r1.value_set_id ||'
       r1.VALIDATION_TYPE = '||r1.VALIDATION_TYPE||'
       l_prev_level1section_code = '||l_prev_level1section_code ||'
       l_prev_section_code = '||l_prev_section_code);


   if nvl(r1.LEVEL1_SECTION_CODE,'#x#') <> nvl(l_prev_level1section_code,'#x#') then

          if nvl(r1.LEVEL2_SECTION_code,'#x#') <> nvl(l_prev_section_code,'#x#') then

             if l_prev_section_code is not null then

                p_query_stmt := p_query_stmt || g_newline || ' from dual ) as ' || l_prev_section_code || ' ';

             end if;

             l_prev_section_code := r1.LEVEL2_SECTION_code;

          end if;

          if l_prev_level1section_code is not null then
                p_query_stmt := p_query_stmt || g_newline || ' from dual ) as ' || l_prev_level1section_code || ' ';
          end if;

          if r1.LEVEL1_SECTION_CODE is not null then
                p_query_stmt := p_query_stmt || g_newline || ' ,cursor (select 1 AS row_num';
          end if;

          if r1.LEVEL2_SECTION_code is not null then
                p_query_stmt := p_query_stmt || g_newline || ' ,cursor (select 1 AS row_num';
          end if;

          l_prev_level1section_code := r1.LEVEL1_SECTION_CODE;

          print_debug_log(l_api_name, 'First if : p_query_stmt = '||p_query_stmt);

   end if;

   if nvl(r1.LEVEL2_SECTION_code,'#x#') <> nvl(l_prev_section_code,'#x#') then

          print_debug_log(l_api_name, 'r1.LEVEL2_SECTION_code = '||r1.LEVEL2_SECTION_code||'
                                       l_prev_section_code = '|| l_prev_section_code);

          if l_prev_section_code is not null then

             p_query_stmt := p_query_stmt || g_newline || ' from dual ) as ' || l_prev_section_code || ' ';

          end if;

          l_prev_section_code := r1.LEVEL2_SECTION_code;

          if r1.LEVEL2_SECTION_code is not null then

                p_query_stmt := p_query_stmt || g_newline || ' ,cursor (select 1 AS row_num';

          end if;

          print_debug_log(l_api_name, 'Second if : p_query_stmt = '||p_query_stmt);
   end if;



   if  r1.repeating_section_code is not null then

        print_debug_log(l_api_name, ' Calling ADDVIEWFORSECTION for p_form_id = '|| p_form_id ||'
                                                      r1.repeating_section_id = '|| r1.repeating_section_id ||'
                                                      r1.LEVEL1_SECTION_ID = '||r1.LEVEL1_SECTION_ID ||'
                                                      r1.LEVEL2_SECTION_ID = '|| r1.LEVEL2_SECTION_ID ||'
                                                      r1.repeating_section_code = '||r1.repeating_section_code );

        ADDVIEWFORSECTION(p_form_id => p_form_id,
                          p_section_id => r1.repeating_section_id,
                          p_LEVEL1_SECTION_ID => r1.LEVEL1_SECTION_ID,
                          p_LEVEL2_SECTION_ID => r1.LEVEL2_SECTION_ID,
                          p_section_code => r1.repeating_section_code,
                          p_parent_alias => l_value_alias,
                          p_parent_fk_id => l_schema_pk_id,
                          p_query_stmt=> p_query_stmt,
                          p_error => p_error,
                          p_result => p_result);

        if p_result = 1 then
        	return;
        end if;

        print_debug_log(l_api_name, 'Third if : p_query_stmt = '||p_query_stmt);

   end if;

   if r1.field_code is not null then

      if r1.system_flag = 'Y' then

         if r1.SYSTEM_FIELD_LOV_FLAG ='Y' then

             p_query_stmt := p_query_stmt || g_newline || ',PON_FORMS_UTIL_PVT.GetSYSTEMChar(''' || r1.field_code || '_NAME'',v_1.entity_pk1)'
                                  || ' AS ' ||  r1.field_code || '_NAME';

         end if;

         if r1.datatype in ('DATE','DATETIME') then

             p_query_stmt := p_query_stmt || g_newline || ',PON_FORMS_UTIL_PVT.GetSYSTEMDate(''' || r1.field_code || ''',v_1.entity_pk1)'
                                  || ' AS ' ||  r1.field_code ;

         elsif r1.datatype in ( 'NUMBER','AMOUNT') then

             p_query_stmt := p_query_stmt || g_newline || ',PON_FORMS_UTIL_PVT.GetSYSTEMNumber(''' || r1.field_code || ''',v_1.entity_pk1)'
                                  || ' AS ' ||  r1.field_code ;

         else

             p_query_stmt := p_query_stmt || g_newline || ',PON_FORMS_UTIL_PVT.GetSYSTEMChar(''' || r1.field_code || ''',v_1.entity_pk1)'
                                  || ' AS ' ||  r1.field_code ;

         end if;

         print_debug_log(l_api_name, 'Fourth if : p_query_stmt = '||p_query_stmt);

      else

         print_debug_log(l_api_name, ' Calling ADDSTMTFIELD for r1.field_code = '|| r1.field_code);

         ADDSTMTFIELD(p_field_code => r1.field_code,
                    p_datatype => r1.datatype,
                    p_value_alias => l_value_alias,
                    p_value_column => r1.MAPPING_FIELD_VALUE_COLUMN,
                    p_value_set_name => r1.value_set_name,
                    p_query_stmt=> p_query_stmt,
                    p_error => p_error,
                    p_result => p_result);

        if p_result = 1 then
        	return;
        end if;

         print_debug_log(l_api_name, 'Fifth if : p_query_stmt = '||p_query_stmt);
      end if;

   end if; -- Field Code Not null

end loop;

        print_debug_log(l_api_name, 'l_prev_section_code = '||l_prev_section_code||'
                                     l_prev_level1section_code = '||l_prev_level1section_code);

        if l_prev_section_code is not null then

           p_query_stmt := p_query_stmt || g_newline || ' from dual ) as ' || l_prev_section_code || ' ';

        end if;

        if l_prev_level1section_code is not null then

           p_query_stmt := p_query_stmt || g_newline || ' from dual ) as ' || l_prev_level1section_code || ' ';

        end if;

        print_debug_log(l_api_name, 'Last if : p_query_stmt = '||p_query_stmt);

-- from and where clause for the form
p_query_stmt := p_query_stmt || g_newline || ' from pon_form_field_values ' || l_value_alias;

p_query_stmt := p_query_stmt || g_newline || ' where ' ||  l_value_alias ||'.OWNING_ENTITY_CODE =:ENTITY_CODE'
                               || g_newline || ' and ' ||  l_value_alias ||'.ENTITY_PK1 =:ENTITY_PK1'
                               || g_newline || ' and ' ||  l_value_alias ||'.form_id =' || to_char(p_form_id)
                               || g_newline || ' and ' ||  l_value_alias ||'.section_id  =-1' || g_newline;

print_debug_log(l_api_name, 'END = '||p_query_stmt);


End GENERATE_XMLQUERY;


/*======================================================================
 PROCEDURE:  GENERATE_XMLSCHEMA		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
Procedure GENERATE_XMLSCHEMA (p_form_id  in Number, -- top form
                        p_schema OUT NOCOPY CLOB,
                        p_error IN OUT NOCOPY VARCHAR2,
                        p_result IN OUT NOCOPY number, -- 0: Success, 1: failure
                        x_xml_query OUT NOCOPY VARCHAR2     -- The xml query
                       ) IS

l_err_num               NUMBER;
l_err_msg               VARCHAR2(200);
ldoc Varchar2(4000) :='<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsd="http://www.w3.org/2000/10/XMLSchema">
<xsl:output method="xml" omit-xml-declaration="no" indent="yes"/>
<xsl:template match="/">
<xsl:apply-templates select="DOCUMENT/xsd:schema"/>
</xsl:template>
<xsl:template match="xsd:schema">
<xsl:copy-of select="."/>
</xsl:template>
</xsl:stylesheet>';

l_xml_query Varchar2(31500);
l_form_code Varchar2(30);
l_queryCtx DBMS_XMLquery.ctxType;

l_schemOffset Number;
l_xmlTagOffset INTEGER;
l_documentOffset BINARY_INTEGER;
l_documentTagLength BINARY_INTEGER;
l_blankTextForDocumentTag VARCHAR2(100);
l_count NUMBER;

l_api_name	CONSTANT VARCHAR2(30) := 'GENERATE_XMLSCHEMA';

Begin

print_debug_log(l_api_name, 'BEGIN- p_form_id = '||p_form_id);

p_result := 0;

SAVEPOINT PON_XMLSCHEMA;
g_mode := 'SCHEMA';
select form_code
into l_form_code
from pon_forms_sections
where form_id = p_form_id;

print_debug_log(l_api_name, 'g_mode = '||g_mode||' l_form_code = '||l_form_code);

GENERATE_XMLQUERY (p_form_id,
l_xml_query,
p_error,
p_result);

if p_result = 1 then
  return;
end if;

x_xml_query := l_xml_query;

 print_debug_log(l_api_name, 'p_form_id = '||p_form_id||' GOT QUERY FORM SCHEMA ');

l_queryCtx := DBMS_XMLquery.newContext(l_xml_query);
DBMS_XMLQuery.setDateFormat(l_queryCtx,'dd/mm/yyyy HH:mm:ss'); -- sets the row tag name
DBMS_XMLQuery.setRowTag(l_queryCtx,l_form_code || '_ROW'); -- sets the row tag name
DBMS_XMLQuery.setRowSetTag(l_queryCtx,l_form_code);
DBMS_XMLQuery.setBindValue(l_queryCtx,'ENTITY_CODE','XML_SCHEMA_GENERATION');
DBMS_XMLQuery.setBindValue(l_queryCtx,'ENTITY_PK1',g_dummy_pk);
-- DBMS_XMLquery.setXSLT(l_queryCtx,ldoc );

print_debug_log(l_api_name, 'p_form_id = '||p_form_id||' STARTING SCHEMA GENERATION');

p_schema:=DBMS_XMLquery.GETXML(l_queryCtx,2);

print_debug_log(l_api_name, 'p_form_id = '||p_form_id||' GOT SCHEMA ');

g_mode := 'XML';

 rollback to SAVEPOINT PON_XMLSCHEMA;

DBMS_XMLQUERY.closecontext(l_queryCtx);

l_schemOffset := DBMS_LOB.INSTR(p_schema,'</xsd:schema>')+12;
DBMS_LOB.TRIM(p_schema,l_schemOffset);

--The code below removed the <DOCUMENT xmlns:xsd="http://www.w3.org/2000/10/XMLSchema">
-- from the xsd

-- Get the length of tag for <?xml version = '1.0'?>
l_xmlTagOffset := DBMS_LOB.INSTR(p_schema,'>');

-- Get the position where <DOCUMENT xmlns:xsd="http://www.w3.org/2000/10/XMLSchema">
-- ends
l_documentOffset := DBMS_LOB.INSTR(p_schema,'>',1,2);

-- length of <DOCUMENT xmlns:xsd="http://www.w3.org/2000/10/XMLSchema">
l_documentTagLength := l_documentOffset-l_xmlTagOffset;
l_blankTextForDocumentTag := '';
l_count := 0;

loop
  exit when l_count > l_documentTagLength;
  l_blankTextForDocumentTag := l_blankTextForDocumentTag ||' ';
  l_count := l_count+1;
end loop;

dbms_lob.write(p_schema,l_documentTagLength,l_xmlTagOffset+1,l_blankTextForDocumentTag);

print_debug_log(l_api_name, 'END ');

exception
when others then
  l_err_num := SQLCODE;
  l_err_msg := SUBSTR(SQLERRM, 1, 200);
  print_error_log(l_api_name, 'p_form_id = '||p_form_id||' SCHEMA GENERATION FAILED l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);
  p_result := 1;
  p_error := PON_AUCTION_PKG.getMessage ('PON_FM_SCHEMA_GENERATION_FAIL');
  DBMS_XMLquery.closecontext (l_queryCtx);

End GENERATE_XMLSCHEMA;



/*======================================================================
 PROCEDURE:  GENERATE_XML         PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
Procedure GENERATE_XML(p_form_id  in Number, -- top form
                        p_entity_code Varchar2,
                        p_entity_pk1  Varchar2,
                        p_xml OUT NOCOPY CLOB,
                        p_xdo_stylesheet_code OUT NOCOPY VARCHAR2,
                        p_error OUT NOCOPY VARCHAR2,
                        p_result OUT NOCOPY number -- 0: Success, 1: failure
                       ) IS
l_err_num               NUMBER;
l_err_msg               VARCHAR2(200);
l_xml_query Varchar2(31500);
l_form_code Varchar2(30);
l_queryCtx DBMS_XMLquery.ctxType;

l_api_name	CONSTANT VARCHAR2(30) := 'GENERATE_XML';

Begin

p_result := 0;

print_debug_log(l_api_name, 'BEGIN- p_form_id = '||p_form_id||'
                p_entity_code = '||p_entity_code||'
                p_entity_pk1 = '||p_entity_pk1);

g_mode := 'XML';

select
xdo_stylesheet_code,
form_code
into
p_xdo_stylesheet_code,
l_form_code
from pon_forms_sections
where form_id = p_form_id;


    GENERATE_XMLQUERY(p_form_id,
                      l_xml_query,
                      p_error,
                      p_result);

 if p_result = 1 then
   return;
 end if;

print_debug_log(l_api_name, 'Got Xml Query for GENERATE_XML p_form_id = '||p_form_id);

l_queryCtx := DBMS_XMLquery.newContext(l_xml_query);
DBMS_XMLQuery.setDateFormat(l_queryCtx,'dd/mm/yyyy HH:mm:ss'); -- sets the row tag name
DBMS_XMLQuery.setRowTag(l_queryCtx,l_form_code || '_ROW'); -- sets the row tag name
DBMS_XMLQuery.setRowSetTag(l_queryCtx,l_form_code);
DBMS_XMLQuery.setBindValue(l_queryCtx,'ENTITY_CODE',p_entity_code);
DBMS_XMLQuery.setBindValue(l_queryCtx,'ENTITY_PK1',p_entity_pk1);

print_debug_log(l_api_name, 'All values bound for GENERATE_XML  p_form_id = '||p_form_id);

p_xml:=DBMS_XMLquery.GETXML(l_queryCtx, 0);
DBMS_XMLQUERY.closecontext(l_queryCtx);

exception
when others then
  l_err_num := SQLCODE;
  l_err_msg := SUBSTR(SQLERRM, 1, 200);
  print_error_log(l_api_name, 'p_form_id = '||p_form_id||' GENERATE_XML FAILED  l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);
  p_result := 1;
  p_error := PON_AUCTION_PKG.getMessage ('PON_FM_XML_GENERATION_FAIL');
  DBMS_XMLquery.closecontext (l_queryCtx);

End GENERATE_XML;



/*======================================================================
 PROCEDURE:  CreateDummyRowForXML		PRIVATE
   PARAMETERS:
   COMMENT   :
======================================================================*/
Procedure CreateDummyRowForXML(
          p_value_pk_id Number,
          p_form_id  number,
          p_section_id Number,
          p_parent_fk_id Number,
          p_level1_section_id Number,
          p_level2_section_id Number,
          p_error IN OUT NOCOPY VARCHAR2,
          p_result IN OUT NOCOPY number -- 0: Success, 1: failure
	) is
l_err_num               NUMBER;
l_err_msg               VARCHAR2(200);
l_api_name	CONSTANT VARCHAR2(30) := 'CreateDummyRowForXML';

Begin

p_result := 0;

print_debug_log(l_api_name, 'BEGIN- p_value_pk_id = '||p_value_pk_id||'
                p_form_id = '||p_form_id||'
                p_section_id = '||p_section_id||'
                p_parent_fk_id = '||p_parent_fk_id||'
                p_level1_section_id = '||p_level1_section_id||'
                p_level2_section_id = '||p_level2_section_id||'
                g_dummy_pk = '||g_dummy_pk||'
                g_dummy_char = '||g_dummy_char||'
                g_dummy_num = '||g_dummy_num);

insert into  pon_form_field_values
(FORM_FIELD_VALUE_ID,
FORM_ID,
OWNING_ENTITY_CODE,
ENTITY_PK1,
SECTION_ID,
PARENT_FIELD_VALUES_FK,
TEXTCOL1,
TEXTCOL2,
TEXTCOL3,
TEXTCOL4,
TEXTCOL5,
TEXTCOL6,
TEXTCOL7,
TEXTCOL8,
TEXTCOL9,
TEXTCOL10,
TEXTCOL11,
TEXTCOL12,
TEXTCOL13,
TEXTCOL14,
TEXTCOL15,
TEXTCOL16,
TEXTCOL17,
TEXTCOL18,
TEXTCOL19,
TEXTCOL20,
TEXTCOL21,
TEXTCOL22,
TEXTCOL23,
TEXTCOL24,
TEXTCOL25,
TEXTCOL26,
TEXTCOL27,
TEXTCOL28,
TEXTCOL29,
TEXTCOL30,
TEXTCOL31,
TEXTCOL32,
TEXTCOL33,
TEXTCOL34,
TEXTCOL35,
TEXTCOL36,
TEXTCOL37,
TEXTCOL38,
TEXTCOL39,
TEXTCOL40,
TEXTCOL41,
TEXTCOL42,
TEXTCOL43,
TEXTCOL44,
TEXTCOL45,
TEXTCOL46,
TEXTCOL47,
TEXTCOL48,
TEXTCOL49,
TEXTCOL50,
TEXTCOL51,
TEXTCOL52,
TEXTCOL53,
TEXTCOL54,
TEXTCOL55,
TEXTCOL56,
TEXTCOL57,
TEXTCOL58,
TEXTCOL59,
TEXTCOL60,
TEXTCOL61,
TEXTCOL62,
TEXTCOL63,
TEXTCOL64,
TEXTCOL65,
TEXTCOL66,
TEXTCOL67,
TEXTCOL68,
TEXTCOL69,
TEXTCOL70,
TEXTCOL71,
TEXTCOL72,
TEXTCOL73,
TEXTCOL74,
TEXTCOL75,
TEXTCOL76,
TEXTCOL77,
TEXTCOL78,
TEXTCOL79,
TEXTCOL80,
TEXTCOL81,
TEXTCOL82,
TEXTCOL83,
TEXTCOL84,
TEXTCOL85,
TEXTCOL86,
TEXTCOL87,
TEXTCOL88,
TEXTCOL89,
TEXTCOL90,
TEXTCOL91,
TEXTCOL92,
TEXTCOL93,
TEXTCOL94,
TEXTCOL95,
TEXTCOL96,
TEXTCOL97,
TEXTCOL98,
TEXTCOL99,
TEXTCOL100,
TEXTCOL101,
TEXTCOL102,
TEXTCOL103,
TEXTCOL104,
TEXTCOL105,
TEXTCOL106,
TEXTCOL107,
TEXTCOL108,
TEXTCOL109,
TEXTCOL110,
TEXTCOL111,
TEXTCOL112,
TEXTCOL113,
TEXTCOL114,
TEXTCOL115,
TEXTCOL116,
TEXTCOL117,
TEXTCOL118,
TEXTCOL119,
TEXTCOL120,
TEXTCOL121,
TEXTCOL122,
TEXTCOL123,
TEXTCOL124,
TEXTCOL125,
TEXTCOL126,
TEXTCOL127,
TEXTCOL128,
TEXTCOL129,
TEXTCOL130,
TEXTCOL131,
TEXTCOL132,
TEXTCOL133,
TEXTCOL134,
TEXTCOL135,
TEXTCOL136,
TEXTCOL137,
TEXTCOL138,
TEXTCOL139,
TEXTCOL140,
TEXTCOL141,
TEXTCOL142,
TEXTCOL143,
TEXTCOL144,
TEXTCOL145,
TEXTCOL146,
TEXTCOL147,
TEXTCOL148,
TEXTCOL149,
TEXTCOL150,
TEXTCOL151,
TEXTCOL152,
TEXTCOL153,
TEXTCOL154,
TEXTCOL155,
TEXTCOL156,
TEXTCOL157,
TEXTCOL158,
TEXTCOL159,
TEXTCOL160,
TEXTCOL161,
TEXTCOL162,
TEXTCOL163,
TEXTCOL164,
TEXTCOL165,
TEXTCOL166,
TEXTCOL167,
TEXTCOL168,
TEXTCOL169,
TEXTCOL170,
TEXTCOL171,
TEXTCOL172,
TEXTCOL173,
TEXTCOL174,
TEXTCOL175,
TEXTCOL176,
TEXTCOL177,
TEXTCOL178,
TEXTCOL179,
TEXTCOL180,
TEXTCOL181,
TEXTCOL182,
TEXTCOL183,
TEXTCOL184,
TEXTCOL185,
TEXTCOL186,
TEXTCOL187,
TEXTCOL188,
TEXTCOL189,
TEXTCOL190,
TEXTCOL191,
TEXTCOL192,
TEXTCOL193,
TEXTCOL194,
TEXTCOL195,
TEXTCOL196,
TEXTCOL197,
TEXTCOL198,
TEXTCOL199,
TEXTCOL200,
TEXTCOL201,
TEXTCOL202,
TEXTCOL203,
TEXTCOL204,
TEXTCOL205,
TEXTCOL206,
TEXTCOL207,
TEXTCOL208,
TEXTCOL209,
TEXTCOL210,
TEXTCOL211,
TEXTCOL212,
TEXTCOL213,
TEXTCOL214,
TEXTCOL215,
TEXTCOL216,
TEXTCOL217,
TEXTCOL218,
TEXTCOL219,
TEXTCOL220,
TEXTCOL221,
TEXTCOL222,
TEXTCOL223,
TEXTCOL224,
TEXTCOL225,
TEXTCOL226,
TEXTCOL227,
TEXTCOL228,
TEXTCOL229,
TEXTCOL230,
TEXTCOL231,
TEXTCOL232,
TEXTCOL233,
TEXTCOL234,
TEXTCOL235,
TEXTCOL236,
TEXTCOL237,
TEXTCOL238,
TEXTCOL239,
TEXTCOL240,
TEXTCOL241,
TEXTCOL242,
TEXTCOL243,
TEXTCOL244,
TEXTCOL245,
TEXTCOL246,
TEXTCOL247,
TEXTCOL248,
TEXTCOL249,
TEXTCOL250,
DATECOL1,
DATECOL2,
DATECOL3,
DATECOL4,
DATECOL5,
DATECOL6,
DATECOL7,
DATECOL8,
DATECOL9,
DATECOL10,
DATECOL11,
DATECOL12,
DATECOL13,
DATECOL14,
DATECOL15,
DATECOL16,
DATECOL17,
DATECOL18,
DATECOL19,
DATECOL20,
DATECOL21,
DATECOL22,
DATECOL23,
DATECOL24,
DATECOL25,
DATECOL26,
DATECOL27,
DATECOL28,
DATECOL29,
DATECOL30,
DATECOL31,
DATECOL32,
DATECOL33,
DATECOL34,
DATECOL35,
DATECOL36,
DATECOL37,
DATECOL38,
DATECOL39,
DATECOL40,
DATECOL41,
DATECOL42,
DATECOL43,
DATECOL44,
DATECOL45,
DATECOL46,
DATECOL47,
DATECOL48,
DATECOL49,
DATECOL50,
NUMBERCOL1,
NUMBERCOL2,
NUMBERCOL3,
NUMBERCOL4,
NUMBERCOL5,
NUMBERCOL6,
NUMBERCOL7,
NUMBERCOL8,
NUMBERCOL9,
NUMBERCOL10,
NUMBERCOL11,
NUMBERCOL12,
NUMBERCOL13,
NUMBERCOL14,
NUMBERCOL15,
NUMBERCOL16,
NUMBERCOL17,
NUMBERCOL18,
NUMBERCOL19,
NUMBERCOL20,
NUMBERCOL21,
NUMBERCOL22,
NUMBERCOL23,
NUMBERCOL24,
NUMBERCOL25,
NUMBERCOL26,
NUMBERCOL27,
NUMBERCOL28,
NUMBERCOL29,
NUMBERCOL30,
NUMBERCOL31,
NUMBERCOL32,
NUMBERCOL33,
NUMBERCOL34,
NUMBERCOL35,
NUMBERCOL36,
NUMBERCOL37,
NUMBERCOL38,
NUMBERCOL39,
NUMBERCOL40,
NUMBERCOL41,
NUMBERCOL42,
NUMBERCOL43,
NUMBERCOL44,
NUMBERCOL45,
NUMBERCOL46,
NUMBERCOL47,
NUMBERCOL48,
NUMBERCOL49,
NUMBERCOL50,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
LEVEL1_SECTION_ID,
LEVEL2_SECTION_ID)
values(
 p_value_pk_id
 ,p_FORM_ID
 ,'XML_SCHEMA_GENERATION'
, g_dummy_pk
 ,p_SECTION_ID
 ,p_parent_fk_id
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,g_dummy_char
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,sysdate -200
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,g_dummy_num
,sysdate
 ,0
 ,sysdate
,0
 ,0
,p_level1_section_id
,p_level2_section_id);

 print_debug_log(l_api_name, 'END '||l_api_name);

exception
when others then
  l_err_num := SQLCODE;
  l_err_msg := SUBSTR(SQLERRM, 1, 200);
  print_error_log(l_api_name, 'p_form_id = '||p_form_id||' CreateDummyRowForXML FAILED l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);
  p_result := 1;
  p_error := PON_AUCTION_PKG.getMessage ('PON_FM_CREATE_DUMMY_ROW_ERROR');

End CreateDummyRowForXML;



/*======================================================================
 PROCEDURE:  COMPILE_FORM		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
PROCEDURE  COMPILE_FORM(p_form_id	IN	NUMBER) IS

  x_section_id                   NUMBER;

  x_is_repeating_section_flag    VARCHAR2(1);

  x_form_section_field_id        NUMBER;

  x_mapping_column               PON_FORM_SECTION_COMPILED.MAPPING_FIELD_VALUE_COLUMN%TYPE;

  CURSOR c1_form_section_fields IS
          select
          ff.FORM_SECTION_FIELD_ID,
          ff.FORM_ID,
          ff.TYPE,
          ff.FIELD_CODE,
          ff.SEQUENCE_NUMBER,
          ff.REQUIRED,
          ff.SECTION_ID,
          ff.DISPLAY_ON_MAIN_PAGE,
          ff.ENABLED,
          f.datatype,
          f.system_flag
          from pon_form_section_fields ff,
               pon_fields f
          where form_id = p_form_id
          and f.field_code(+) = ff.field_code
          order by sequence_number;


l_api_name	CONSTANT VARCHAR2(30) := 'COMPILE_FORM';

begin

print_debug_log(l_api_name, 'BEGIN- p_form_id = '||p_form_id);

      g_date_sequence_number := 0;

      g_number_sequence_number := 0;

      g_text_sequence_number := 0;

      g_internal_sequence_number := 10;

Delete pon_form_section_compiled
where form_id = p_form_id;
-- Inser a row for the form
	    InsertCompiledRow( p_FORM_SECTION_FIELD_ID => null,
		           p_form_id => p_form_id,
                           p_type =>  'FORM',
                           p_field_code => null,
                           p_INTERNAL_SEQUENCE_NUMBER =>0,
                           p_MAPPING_FIELD_VALUE_COLUMN =>null,
                           p_REQUIRED => null,
                           p_LEVEL1_SECTION_ID => null,
                           p_LEVEL2_SECTION_ID => null,
                           p_REPEATING_SECTION_ID => null,
                           p_DISPLAY_ON_MAIN_PAGE =>null,
                           p_ENABLED  =>'Y');

      for form_section_compiled in c1_form_section_fields LOOP

         if form_section_compiled.TYPE = 'FIELD' then
            x_mapping_column := null;
            if form_section_compiled.system_flag ='N' then
            GetMappingColumn(p_datatype => form_section_compiled.datatype,
                             p_mapping_column => x_mapping_column);
            end if;

	    InsertCompiledRow( p_FORM_SECTION_FIELD_ID => form_section_compiled.FORM_SECTION_FIELD_ID,
		           p_form_id => form_section_compiled.FORM_ID,
                           p_type =>  'FORM_FIELD',
                           p_field_code =>  form_section_compiled.FIELD_CODE,
                           p_INTERNAL_SEQUENCE_NUMBER =>g_internal_sequence_number,
                           p_MAPPING_FIELD_VALUE_COLUMN =>x_mapping_column,
                           p_REQUIRED => form_section_compiled.REQUIRED,
                           p_LEVEL1_SECTION_ID => null,
                           p_LEVEL2_SECTION_ID => null,
                           p_REPEATING_SECTION_ID => null,
                           p_DISPLAY_ON_MAIN_PAGE =>form_section_compiled.DISPLAY_ON_MAIN_PAGE,
                           p_ENABLED  =>form_section_compiled.ENABLED);

            g_internal_sequence_number := g_internal_sequence_number + 10;

         elsif form_section_compiled.TYPE = 'SECTION' then

            x_section_id := form_section_compiled.section_id;

            select
            nvl(is_repeating_section_flag,'N')
            into
            x_is_repeating_section_flag
            from
            pon_forms_sections
            where
            FORM_ID = x_section_id;

            if x_is_repeating_section_flag = 'Y' then

	    InsertCompiledRow( p_FORM_SECTION_FIELD_ID => form_section_compiled.FORM_SECTION_FIELD_ID,
		           p_form_id => form_section_compiled.FORM_ID,
                           p_type =>  'REPEAT_SECTION',
                           p_field_code => null,
                           p_INTERNAL_SEQUENCE_NUMBER =>g_internal_sequence_number,
                           p_MAPPING_FIELD_VALUE_COLUMN =>null,
                           p_REQUIRED => null,
                           p_LEVEL1_SECTION_ID => null,
                           p_LEVEL2_SECTION_ID => null,
                           p_REPEATING_SECTION_ID => form_section_compiled.SECTION_ID,
                           p_DISPLAY_ON_MAIN_PAGE =>form_section_compiled.DISPLAY_ON_MAIN_PAGE,
                           p_ENABLED  =>form_section_compiled.ENABLED);

               g_internal_sequence_number := g_internal_sequence_number + 10;
            else
	    InsertCompiledRow( p_FORM_SECTION_FIELD_ID => form_section_compiled.FORM_SECTION_FIELD_ID,
		           p_form_id => form_section_compiled.FORM_ID,
                           p_type =>  'NORMAL_SECTION',
                           p_field_code => null,
                           p_INTERNAL_SEQUENCE_NUMBER =>g_internal_sequence_number,
                           p_MAPPING_FIELD_VALUE_COLUMN =>null,
                           p_REQUIRED => null,
                           p_LEVEL1_SECTION_ID => form_section_compiled.SECTION_ID,
                           p_LEVEL2_SECTION_ID => null,
                           p_REPEATING_SECTION_ID => null,
                           p_DISPLAY_ON_MAIN_PAGE =>form_section_compiled.DISPLAY_ON_MAIN_PAGE,
                           p_ENABLED  =>form_section_compiled.ENABLED);

               g_internal_sequence_number := g_internal_sequence_number + 10;

               INSERT_LEVEL1_SECTION_IN_FORM(p_form_id,form_section_compiled.SECTION_ID);

               if form_section_compiled.ENABLED = 'N' then

                   update pon_form_section_compiled
                   set enabled = 'N'
                   where form_id = p_form_id
                   and level1_section_id = form_section_compiled.SECTION_ID;

               end if;

            end if;

         end if;

      END LOOP;

      print_debug_log(l_api_name, 'END '||l_api_name);

 END COMPILE_FORM;



/*======================================================================
 PROCEDURE:  INSERT_LEVEL1_SECTION_IN_FORM		PRIVATE
   PARAMETERS:
   COMMENT   :
======================================================================*/
 PROCEDURE  INSERT_LEVEL1_SECTION_IN_FORM(p_form_id	IN	NUMBER,
                        p_level1_section_id	IN	NUMBER) IS

  x_section_id                   NUMBER;

  x_is_repeating_section_flag    VARCHAR2(1);

  x_form_section_field_id        NUMBER;


  x_mapping_column               PON_FORM_SECTION_COMPILED.MAPPING_FIELD_VALUE_COLUMN%TYPE;

  l_api_name	CONSTANT VARCHAR2(30) := 'INSERT_LEVEL1_SECTION_IN_FORM';

  CURSOR LEVEL1_SECTION_fields IS
          select
          ff.FORM_SECTION_FIELD_ID,
          ff.FORM_ID,
          ff.TYPE,
          ff.FIELD_CODE,
          ff.SEQUENCE_NUMBER,
          ff.REQUIRED,
          ff.SECTION_ID,
          ff.DISPLAY_ON_MAIN_PAGE,
          ff.ENABLED,
          f.datatype,
          f.system_flag
          from pon_form_section_fields ff,
               pon_fields f
          where form_id = p_level1_section_id
          and f.field_code(+) = ff.field_code
          order by sequence_number;

  BEGIN

  print_debug_log(l_api_name, 'BEGIN- p_form_id = '||p_form_id||'
	                p_level1_section_id = '||p_level1_section_id);

      for LEVEL1_SECTION_fields_record in LEVEL1_SECTION_fields LOOP

         if LEVEL1_SECTION_fields_record.TYPE = 'FIELD' then
            x_mapping_column := null;
            if LEVEL1_SECTION_fields_record.system_flag ='N' then

            GetMappingColumn(p_datatype => LEVEL1_SECTION_fields_record.datatype,
                             p_mapping_column => x_mapping_column);
            end if;

	    InsertCompiledRow( p_FORM_SECTION_FIELD_ID => LEVEL1_SECTION_fields_record.FORM_SECTION_FIELD_ID,
		           p_form_id => p_form_id,
                           p_type =>  'SECTION_FIELD',
                           p_field_code => LEVEL1_SECTION_fields_record.FIELD_CODE,
                           p_INTERNAL_SEQUENCE_NUMBER =>g_internal_sequence_number,
                           p_MAPPING_FIELD_VALUE_COLUMN =>x_mapping_column,
                           p_REQUIRED => LEVEL1_SECTION_fields_record.REQUIRED,
                           p_LEVEL1_SECTION_ID => p_level1_section_id,
                           p_LEVEL2_SECTION_ID => null,
                           p_REPEATING_SECTION_ID => null,
                           p_DISPLAY_ON_MAIN_PAGE =>LEVEL1_SECTION_fields_record.DISPLAY_ON_MAIN_PAGE,
                           p_ENABLED  =>LEVEL1_SECTION_fields_record.ENABLED);

            g_internal_sequence_number := g_internal_sequence_number + 10;

         elsif LEVEL1_SECTION_fields_record.TYPE = 'SECTION' then

            x_section_id := LEVEL1_SECTION_fields_record.section_id;

            select
            nvl(is_repeating_section_flag,'N')
            into
            x_is_repeating_section_flag
            from
            pon_forms_sections
            where
            FORM_ID = x_section_id;

            if x_is_repeating_section_flag = 'Y' then

    InsertCompiledRow( p_FORM_SECTION_FIELD_ID => LEVEL1_SECTION_fields_record.FORM_SECTION_FIELD_ID,
		           p_form_id => p_form_id,
                           p_type =>  'INNER_REPEAT_SECTION',
                           p_field_code => null,
                           p_INTERNAL_SEQUENCE_NUMBER =>g_internal_sequence_number,
                           p_MAPPING_FIELD_VALUE_COLUMN =>null,
                           p_REQUIRED => null,
                           p_LEVEL1_SECTION_ID => p_level1_section_id,
                           p_LEVEL2_SECTION_ID => null,
                           p_REPEATING_SECTION_ID => LEVEL1_SECTION_fields_record.SECTION_ID,
                           p_DISPLAY_ON_MAIN_PAGE =>LEVEL1_SECTION_fields_record.DISPLAY_ON_MAIN_PAGE,
                           p_ENABLED  =>LEVEL1_SECTION_fields_record.ENABLED);

               g_internal_sequence_number := g_internal_sequence_number + 10;
            else

    InsertCompiledRow( p_FORM_SECTION_FIELD_ID => LEVEL1_SECTION_fields_record.FORM_SECTION_FIELD_ID,
		           p_form_id => p_form_id,
                           p_type =>  'INNER_NORMAL_SECTION',
                           p_field_code => null,
                           p_INTERNAL_SEQUENCE_NUMBER =>g_internal_sequence_number,
                           p_MAPPING_FIELD_VALUE_COLUMN =>null,
                           p_REQUIRED => null,
                           p_LEVEL1_SECTION_ID => p_level1_section_id,
                           p_LEVEL2_SECTION_ID => LEVEL1_SECTION_fields_record.SECTION_ID,
                           p_REPEATING_SECTION_ID => null,
                           p_DISPLAY_ON_MAIN_PAGE =>LEVEL1_SECTION_fields_record.DISPLAY_ON_MAIN_PAGE,
                           p_ENABLED  =>LEVEL1_SECTION_fields_record.ENABLED);

               g_internal_sequence_number := g_internal_sequence_number + 10;

               INSERT_LEVEL2_SECTION_IN_FORM(p_form_id,
                                            p_level1_section_id,
                                            LEVEL1_SECTION_fields_record.SECTION_ID);

            end if;

          end if;

      end loop;

      print_debug_log(l_api_name, 'END '||l_api_name);

  END INSERT_LEVEL1_SECTION_IN_FORM;



/*======================================================================
 PROCEDURE:  INSERT_LEVEL2_SECTION_IN_FORM		PRIVATE
   PARAMETERS:
   COMMENT   :
======================================================================*/
  PROCEDURE  INSERT_LEVEL2_SECTION_IN_FORM(p_form_id	IN	NUMBER,
                        p_level1_section_id	IN	NUMBER,
                        p_level2_section_id	IN	NUMBER) IS

  x_section_id                   NUMBER;

  x_is_repeating_section_flag    VARCHAR2(1);

  x_form_section_field_id        NUMBER;


  x_mapping_column               PON_FORM_SECTION_COMPILED.MAPPING_FIELD_VALUE_COLUMN%TYPE;

  l_api_name	CONSTANT VARCHAR2(30) := 'INSERT_LEVEL2_SECTION_IN_FORM';

  CURSOR inner_section_fields IS
          select
          ff.FORM_SECTION_FIELD_ID,
          ff.FORM_ID,
          ff.TYPE,
          ff.FIELD_CODE,
          ff.SEQUENCE_NUMBER,
          ff.REQUIRED,
          ff.SECTION_ID,
          ff.DISPLAY_ON_MAIN_PAGE,
          ff.ENABLED,
          f.datatype,
          f.system_flag
          from pon_form_section_fields ff,
               pon_fields f
          where form_id = p_level2_section_id
          and f.field_code(+) = ff.field_code
          order by sequence_number;

  BEGIN

print_debug_log(l_api_name, 'BEGIN- p_form_id = '||p_form_id||'
                p_level1_section_id = '||p_level1_section_id||'
                p_level2_section_id = '||p_level2_section_id);

      for inner_section_fields_record in inner_section_fields LOOP

         if inner_section_fields_record.TYPE = 'FIELD' then

            x_mapping_column := null;
            if inner_section_fields_record.system_flag ='N' then

            GetMappingColumn(p_datatype => inner_section_fields_record.datatype,
                             p_mapping_column => x_mapping_column);
            end if;

    InsertCompiledRow( p_FORM_SECTION_FIELD_ID => inner_section_fields_record.FORM_SECTION_FIELD_ID,
		           p_form_id => p_form_id,
                           p_type =>  'INNER_SECTION_FIELD',
                           p_field_code => inner_section_fields_record.FIELD_CODE,
                           p_INTERNAL_SEQUENCE_NUMBER =>g_internal_sequence_number,
                           p_MAPPING_FIELD_VALUE_COLUMN =>x_mapping_column,
                           p_REQUIRED => inner_section_fields_record.REQUIRED,
                           p_LEVEL1_SECTION_ID => p_level1_section_id,
                           p_LEVEL2_SECTION_ID => p_level2_section_id,
                           p_REPEATING_SECTION_ID => null,
                           p_DISPLAY_ON_MAIN_PAGE =>inner_section_fields_record.DISPLAY_ON_MAIN_PAGE,
                           p_ENABLED  =>inner_section_fields_record.ENABLED);

            g_internal_sequence_number := g_internal_sequence_number + 10;

         else
         -- inner section can have a field or repeatable sections only

    InsertCompiledRow( p_FORM_SECTION_FIELD_ID => inner_section_fields_record.FORM_SECTION_FIELD_ID,
		           p_form_id => p_form_id,
                           p_type =>  'INNER_SECTION_REPEAT_SECTION',
                           p_field_code => null,
                           p_INTERNAL_SEQUENCE_NUMBER =>g_internal_sequence_number,
                           p_MAPPING_FIELD_VALUE_COLUMN =>null,
                           p_REQUIRED => null,
                           p_LEVEL1_SECTION_ID => p_level1_section_id,
                           p_LEVEL2_SECTION_ID => p_level2_section_id,
                           p_REPEATING_SECTION_ID => inner_section_fields_record.SECTION_ID,
                           p_DISPLAY_ON_MAIN_PAGE =>inner_section_fields_record.DISPLAY_ON_MAIN_PAGE,
                           p_ENABLED  =>inner_section_fields_record.ENABLED);

               g_internal_sequence_number := g_internal_sequence_number + 10;

         end if;

      end loop;

      print_debug_log(l_api_name, 'END '||l_api_name);

  END INSERT_LEVEL2_SECTION_IN_FORM;

  /*======================================================================
   PROCEDURE : GENERATE_REPEATING_SECTIONS
   PARAMETERS: p_form_id: The id of the form.
   COMMENT   : This procedure will call the COMPILE_FORM and
               PON_FORMS_JRAD_PVT.CREATE_JRAD procedures for all the
               repeating sections included in this form.
  ======================================================================*/
  PROCEDURE GENERATE_REPEATING_SECTIONS (p_form_id IN NUMBER,
                                         p_generate_mode IN VARCHAR2,  -- ALL, JRAD, XSD
                                         p_error   IN OUT NOCOPY VARCHAR2,
                                         p_result  IN OUT NOCOPY NUMBER) IS

  l_err_num               NUMBER;
  l_err_msg               VARCHAR2(200);
  l_api_name	CONSTANT VARCHAR2(30) := 'GENERATE_REPEATING_SECTIONS';
  CURSOR v_repeating_section_id_cursor is
         SELECT
             DISTINCT FS.FORM_ID SECTION_ID
	 FROM
             PON_FORM_SECTION_FIELDS FSF,
             PON_FORMS_SECTIONS FS
	 WHERE
             FSF.SECTION_ID = FS.FORM_ID
             AND
             FS.IS_REPEATING_SECTION_FLAG = 'Y'
             AND
             (FS.JRAD_XML_REGION_NAME IS NULL
              OR
              FS.JRAD_XML_REGION_NAME_DISP IS NULL)
	 START WITH
             FSF.FORM_ID = p_form_id
	 CONNECT
             BY PRIOR FSF.SECTION_ID = FSF.FORM_ID;

  v_repeating_section_id v_repeating_section_id_cursor%ROWTYPE;
  v_section_id           PON_FORMS_SECTIONS.FORM_ID%TYPE;
  x_error_message        VARCHAR2(100);
  x_error_code           VARCHAR2(100);
  x_result               VARCHAR2(100);
  v_read_only_region_name VARCHAR2(100);
  v_edit_region_name     VARCHAR2(100);

  BEGIN

  p_result := 0;

  print_debug_log (l_api_name, 'BEGIN- p_form_id = ' || p_form_id);

  FOR v_repeating_section_id IN v_repeating_section_id_cursor LOOP

    v_section_id := v_repeating_section_id.section_id;

    print_debug_log (l_api_name, 'Calling COMPILE_FORM for section id = ' || v_section_id);
    COMPILE_FORM (v_section_id);

    -- if we need to generate everything or only the JRAD region
    IF (p_generate_mode IN ('ALL', 'JRAD')) THEN
      print_debug_log (l_api_name, 'Calling CREATE_JRAD for section id = ' || v_section_id);
      PON_FORMS_JRAD_PVT.CREATE_JRAD (v_section_id, x_result, x_error_code, x_error_message);

      print_debug_log (l_api_name, 'Return values from create_jrad: x_result = ' ||
                                    x_result || ', x_error_message = ' ||
                                    x_error_message || ', x_err_code = ' ||
                                    x_error_code);

      if(x_result = fnd_api.g_ret_sts_success) then
        p_result := 0;
      else
        p_result := 1;
        p_error  := x_error_message;
        return;
      end if;

      -- update the JRAD region references
      -- if the form/abstract/section is active
      v_read_only_region_name := getReadOnlyRegionName (v_section_id);
      v_edit_region_name := getDataEntryRegionName (v_section_id);

      UPDATE PON_FORMS_SECTIONS
      SET
           JRAD_XML_REGION_NAME_DISP = v_read_only_region_name,
           JRAD_XML_REGION_NAME = v_edit_region_name
      WHERE
             FORM_ID = v_section_id
        AND  STATUS = 'ACTIVE';
    END IF;

  END LOOP;

  print_debug_log (l_api_name, 'END ' || l_api_name);

  EXCEPTION
    WHEN OTHERS THEN
        l_err_num := SQLCODE;
        l_err_msg := SUBSTR(SQLERRM, 1, 200);
	      print_error_log(l_api_name, 'EXCEPTION While Creating Jrad l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);
        p_result := 1;
        p_error := PON_AUCTION_PKG.getMessage ('PON_FM_UNABLE_TO_CREATE_JRAD');

  END GENERATE_REPEATING_SECTIONS;


/*======================================================================
 PROCEDURE:  GENERATE_FORM_DETAILS		PUBLIC
   PARAMETERS:
   COMMENT   :
======================================================================*/
  PROCEDURE GENERATE_FORM_DETAILS(p_form_id IN NUMBER,
          p_generate_mode IN VARCHAR2, -- ALL, XSD, JRAD
					p_schema OUT NOCOPY CLOB,
					p_error IN OUT NOCOPY VARCHAR2,
					p_result IN OUT NOCOPY NUMBER -- 0: success, 1 - failure
					) IS

  l_err_num               NUMBER;
  l_err_msg               VARCHAR2(200);
  x_form_code VARCHAR2(20);
  x_form_version NUMBER;
  x_type VARCHAR2(30);
  x_data_entry_region_name VARCHAR2(100);
  x_read_only_region_name_disp VARCHAR2(100);
  x_query_stmt PON_FORMS_SECTIONS.XML_QUERY%TYPE;
  x_error_message VARCHAR2(100);
  x_error_code VARCHAR2(100);
  x_result VARCHAR2(100);
  l_api_name	CONSTANT VARCHAR2(30) := 'GENERATE_FORM_DETAILS';
  l_version VARCHAR2(20);
  l_compatibility VARCHAR2(20);
  l_majorVersion NUMBER;

  BEGIN

  p_result := 0;

  print_debug_log(l_api_name, 'BEGIN- p_form_id = '||p_form_id);

  DBMS_UTILITY.DB_VERSION(l_version, l_compatibility);
  l_majorVersion := to_number(substr(l_version, 1, instr(l_version,'.')-1));

  print_debug_log (l_api_name, 'l_version = ' || l_version || ', l_majorVersion = ' || l_majorVersion );

            select
              type,
              jrad_xml_region_name,
              jrad_xml_region_name_disp
            into
              x_type,
              x_data_entry_region_name,
              x_read_only_region_name_disp
            from
            pon_forms_sections
            where
            FORM_ID = p_form_id;

            -- generate inner repeating sections
            -- for forms and abstract, as well as sections
            GENERATE_REPEATING_SECTIONS (p_form_id, p_generate_mode, p_error, p_result);
            print_debug_log(l_api_name, 'GENERATE_REPEATING_SECTIONS p_result = '||p_result);

            if (p_result = 1) then
              return;
            end if;

            IF (x_data_entry_region_name IS NULL OR x_read_only_region_name_disp IS NULL OR x_type = 'ABSTRACT') THEN
              COMPILE_FORM (p_form_id);
              print_debug_log(l_api_name, 'COMPILE_FORM p_form_id = '|| p_form_id);
            END IF;

            -- if we need to generate either just the XSD or everything
            -- then need to generate xml query and schema
            IF x_type = 'FORM' AND p_generate_mode IN ('ALL', 'XSD') THEN

               print_debug_log(l_api_name, 'inside generate xml quer if x_type = ' || x_type || ', p_generate_mode = ' || p_generate_mode);
               if (l_majorVersion >= 9) then
                 print_debug_log(l_api_name, 'major version is greater than 9');

                 GENERATE_XMLSCHEMA (p_form_id => p_form_id,
                   p_schema => p_schema,
                   p_error => p_error,
                   p_result => p_result,
                   x_xml_query => x_query_stmt);

                 if (p_result = 1) then
                   return;
                 end if;

                 update
                   pon_forms_sections
                 set
                   xml_query = x_query_stmt
                 where
                   form_id = p_form_id;

                 print_debug_log(l_api_name, 'GENERATE_XMLSCHEMA  p_result = '||p_result);

               end if; --if major version >=9

             end if;

            -- if we need to generate either just the JRAD or everything
            IF (p_generate_mode IN ('ALL', 'JRAD')) THEN

                 PON_FORMS_JRAD_PVT.CREATE_JRAD(p_form_id ,
                        x_result,
                        x_error_code,
                        x_error_message
                      );

                 if(x_result = fnd_api.g_ret_sts_success) then
                   p_result := 0;
                 else
                   p_result := 1;
                   p_error  := x_error_message;
                   return;
                 end if;

                 -- update the JRAD region references
                 -- if the form/abstract/section is active
                 x_data_entry_region_name := PON_FORMS_UTIL_PVT.getDataEntryRegionName(p_form_id);
                 x_read_only_region_name_disp := PON_FORMS_UTIL_PVT.getReadOnlyRegionName(p_form_id);

                 UPDATE pon_forms_sections
                 SET
                   jrad_xml_region_name = x_data_entry_region_name,
                   jrad_xml_region_name_disp = x_read_only_region_name_disp
                 WHERE form_id = p_form_id
                   AND status = 'ACTIVE';

                 print_debug_log(l_api_name, 'PON_FORMS_JRAD_PVT.CREATE_JRAD  p_result = '||p_result);

                 print_debug_log(l_api_name, 'END '||l_api_name);

            END IF;

    EXCEPTION
       WHEN OTHERS THEN
     p_result := 1;
     l_err_num := SQLCODE;
     l_err_msg := SUBSTR(SQLERRM, 1, 200);
   	print_error_log(l_api_name, 'EXCEPTION l_err_num = '||l_err_num||' l_err_msg = '||l_err_msg);

  END GENERATE_FORM_DETAILS;



/*======================================================================
 PROCEDURE:  publishAbstract	PUBLIC
   PARAMETERS:
   COMMENT   : 	This procedure is used to update the abstract status
 		when it is published, i.e. this procedure should be
		invoked when the user presses either publish or un-publish
		abstract button. We also invoke this procedure when the
		apply button is pressed on the enter form-data page as
		we need to save the 'include pdf' checkbox value.
======================================================================*/

procedure publishAbstract(p_auction_header_id	IN	NUMBER,
			  p_include_pdf_flag 	IN	VARCHAR2,
			  p_publish_action	IN	VARCHAR2,
  			  x_result		OUT NOCOPY  VARCHAR2,
  			  x_error_code    	OUT NOCOPY  VARCHAR2,
  			  x_error_message 	OUT NOCOPY  VARCHAR2) IS

l_api_name	CONSTANT VARCHAR2(30) := 'PUBLISHABSTRACT';
l_form_id	NUMBER;

BEGIN

	print_debug_log(l_api_name, 'BEGIN- p_auction_header_id = '|| p_auction_header_id||'
                            p_include_pdf_flag = '||p_include_pdf_flag ||'
                            p_publish_action = '||p_publish_action);

	update 	pon_auction_headers_all
	set    	include_pdf_in_external_page = p_include_pdf_flag,
		last_update_date = sysdate
	where	auction_header_id = p_auction_header_id;

--	if(nvl(p_publish_action, 'A') <> 'A') then

	if((nvl(p_publish_action, '@') = 'Y' ) OR (nvl(p_publish_action, '@') = 'N') ) then

		-- if the user hasn't pressed the publish abstract button
		-- we dont need to update the status in either
		-- pon_auction_headers_all.abstract_status OR
		-- pon_forms_instances.status

		-- as we do invoke this method when the user presses the apply button as well

		update 	pon_auction_headers_all
		set    	abstract_status = decode(nvl(p_publish_action, 'X'), 'Y', 'PUBLISHED', 'NOT_PUBLISHED'),
			last_update_date = sysdate
		where	auction_header_id = p_auction_header_id;

		select 	form_id
		into	l_form_id
		from 	pon_forms_sections
		where 	form_code = 'ABSTRACT'
		and 	type      = 'ABSTRACT';

		update 	pon_forms_instances
		set	status = decode(nvl(p_publish_action, 'X'), 'Y', 'PUBLISHED', 'NOT_PUBLISHED'),
			last_update_date = sysdate
		where	entity_code = 'PON_AUCTION_HEADERS_ALL'
		and	entity_pk1  = to_char(p_auction_header_id)
		and	form_id     = l_form_id;

	end if;



	x_result := fnd_api.g_ret_sts_success;
	print_debug_log(l_api_name, 'END');

EXCEPTION
    WHEN OTHERS THEN
	x_error_code := SQLCODE;
	x_error_message := SUBSTR(SQLERRM, 1, 100);
	print_error_log(l_api_name, 'EXCEPTION x_error_code = '||x_error_code||' x_error_message = '||x_error_message);
	x_result := fnd_api.g_ret_sts_error;
END publishAbstract;

/*======================================================================
 PROCEDURE:  performPostSaveChanges	PUBLIC
   PARAMETERS:
   COMMENT   : 	This procedure is used to update the form instance status
 		for a form attached to an entity. This procedure will be
		invoked from the beforeCommit method of the
		FormFieldValuesEO entity
======================================================================*/

PROCEDURE performPostSaveChanges(p_form_id		IN 	    NUMBER,
			 	 p_entity_pk1		IN	    VARCHAR2,
				 p_entity_code		IN	    VARCHAR2,
				 p_include_pdf		IN	    VARCHAR2,
  				 x_result		OUT NOCOPY  VARCHAR2,
  				 x_error_code    	OUT NOCOPY  VARCHAR2,
  				 x_error_message 	OUT NOCOPY  VARCHAR2) IS

l_api_name	CONSTANT VARCHAR2(30) := 'PERFORMPOSTSAVECHANGES';
l_form_type	PON_FORMS_SECTIONS.FORM_CODE%TYPE;
l_old_status	PON_FORMS_INSTANCES.STATUS%TYPE;

BEGIN

	print_debug_log(l_api_name, 'BEGIN- p_form_id = '||p_form_id||'
                            p_entity_pk1 = '||p_entity_pk1||'
                            p_entity_code = '||p_entity_code);

	select 	type
	into	l_form_type
	from	pon_forms_sections
	where 	form_id = p_form_id;

	if(l_form_type = 'FORM') then

		update 	pon_forms_instances
		set	status = 'DATA_ENTERED',
			last_update_date = sysdate
		where	entity_code = p_entity_code
		and	entity_pk1  = p_entity_pk1
		and	form_id     = p_form_id;

	elsif(l_form_type = 'ABSTRACT') then

		select 	status
		into	l_old_status
		from	pon_forms_instances
		where 	entity_code = p_entity_code
		and	entity_pk1  = p_entity_pk1
		and	form_id     = p_form_id;

		-- if the apply button has been pressed while entering
		-- data for a form, we need to update the status if the
		-- status hasnt been set

		if(NVL(l_old_status , 'x@Y#z') = 'x@Y#z') then

			update 	pon_forms_instances
			set	status = 'NOT_PUBLISHED',
				last_update_date = sysdate
			where	entity_code = p_entity_code
			and	entity_pk1  = p_entity_pk1
			and	form_id     = p_form_id;

		end if;

	end if;


	if(NVL(p_include_pdf, 'x@Y#z') <> 'x@Y#z') then

		begin
			update 	pon_auction_headers_all
			set    	include_pdf_in_external_page = p_include_pdf,
				last_update_date = sysdate
			where	auction_header_id = to_number(p_entity_pk1);

		exception
			when others then
				null;
		end;
	end if;

	x_result := fnd_api.g_ret_sts_success;

	print_debug_log(l_api_name, 'END');

EXCEPTION
    WHEN OTHERS THEN
  x_result := fnd_api.g_ret_sts_error;
	x_error_code := SQLCODE;
	x_error_message := SUBSTR(SQLERRM, 1, 100);
  print_error_log(l_api_name, 'EXCEPTION x_error_code = '||x_error_code||' x_error_message = '||x_error_message);

END performPostSaveChanges;

/*======================================================================
 PROCEDURE:  deleteFormFieldValues	PUBLIC
   PARAMETERS:
   COMMENT   : 	This procedure is used to remove all the child rows from
		pon_form_field_values table for a given parent row.
		This procedure will be invoked from the remove method of the
		FormFieldValuesEO entity
======================================================================*/

PROCEDURE deleteFormFieldValues(p_form_id		IN 	    NUMBER,
			 	p_entity_pk1		IN	    VARCHAR2,
				p_entity_code		IN	    VARCHAR2,
				p_section_id		IN	    NUMBER,
				p_parent_fk		IN	    NUMBER,
  				x_result		OUT NOCOPY  VARCHAR2,
  				x_error_code    	OUT NOCOPY  VARCHAR2,
  				x_error_message 	OUT NOCOPY  VARCHAR2) IS

l_api_name	CONSTANT VARCHAR2(30) := 'DELETEFORMFIELDVALUES';

BEGIN
	print_debug_log(l_api_name, 'BEGIN- p_form_id = '||p_form_id||'
                            p_entity_pk1 = '||p_entity_pk1||'
                            p_entity_code = '||p_entity_code||'
                            p_section_id = '||p_section_id||'
                            p_parent_fk = '||p_parent_fk);

	delete 	from pon_form_field_values
	where	form_id			= p_form_id
	and	entity_pk1 		= p_entity_pk1
	and	owning_entity_code 	= p_entity_code
	and	parent_field_values_fk	= p_parent_fk
	and	nvl(section_id, -1)	<> -1;


	x_result := fnd_api.g_ret_sts_success;

	print_debug_log(l_api_name, 'END');

EXCEPTION
    WHEN OTHERS THEN
	x_error_code := SQLCODE;
	x_error_message := SUBSTR(SQLERRM, 1, 100);
	print_error_log(l_api_name, 'EXCEPTION x_error_code = '||x_error_code||' x_error_message = '||x_error_message);
	x_result := fnd_api.g_ret_sts_error;

END deleteFormFieldValues;

/*======================================================================
 PROCEDURE : GET_EXTERNAL_REGISTER_URL PUBLIC
 PARAMETERS:
 COMMENT   : This procedure will return the url to be used for
             supplier registration.
======================================================================*/

FUNCTION GET_EXTERNAL_REGISTER_URL (p_org_id IN NUMBER) RETURN VARCHAR2 IS

l_api_name	CONSTANT VARCHAR2(30) := 'GET_EXTERNAL_REGISTER_URL';
l_external_register_url VARCHAR2(600);
l_org_hash_key VARCHAR2(80);

BEGIN

	print_debug_log(l_api_name, 'BEGIN- p_org_id = '||p_org_id);

	print_debug_log(l_api_name, 'Calling POS_URL_PKG.get_External_url');

        l_external_register_url := POS_URL_PKG.get_external_url();

	print_debug_log(l_api_name, 'Return value from POS_URL_PKG.get_External_url:external url = ' || l_external_register_url);

        SELECT HASHKEY
        INTO l_org_hash_key
        FROM POS_ORG_HASH
        WHERE ORG_ID=p_org_id;

        l_external_register_url := l_external_register_url || 'OA_HTML/jsp/pos/suppreg/SupplierRegister.jsp?ouid=' || l_org_hash_key;

	print_debug_log(l_api_name, 'END- external url = ' || l_external_register_url);

        return l_external_register_url;

END;

/*======================================================================
 PROCEDURE:  deleteValues	PUBLIC
   PARAMETERS:
   COMMENT   : 	This procedure is used to remove all the rows from
		pon_form_field_values table for a given form.
		This procedure should be invoked from the remove method
		FormInstancesEO entity
======================================================================*/

PROCEDURE deleteValues( p_form_id		IN 	    NUMBER,
			p_entity_pk1		IN	    VARCHAR2,
			p_entity_code		IN	    VARCHAR2,
  			x_result		OUT NOCOPY  VARCHAR2,
  			x_error_code    	OUT NOCOPY  VARCHAR2,
  			x_error_message 	OUT NOCOPY  VARCHAR2) IS

l_api_name	CONSTANT VARCHAR2(30) := 'DELETEVALUES';


BEGIN

	print_debug_log(l_api_name, 'BEGIN- p_form_id = '||p_form_id||'
                            p_entity_pk1 = '||p_entity_pk1||'
                            p_entity_code = '||p_entity_code);

	x_result := fnd_api.g_ret_sts_error;

	delete 	from pon_form_field_values
	where	form_id			= p_form_id
	and	entity_pk1 		= p_entity_pk1
	and	owning_entity_code 	= p_entity_code;

	x_result := fnd_api.g_ret_sts_success;

	print_debug_log(l_api_name, 'END');

EXCEPTION
    WHEN OTHERS THEN
	x_error_code := SQLCODE;
	x_error_message := SUBSTR(SQLERRM, 1, 100);
	print_error_log(l_api_name, 'EXCEPTION x_error_code = '||x_error_code||' x_error_message = '||x_error_message);
	x_result := fnd_api.g_ret_sts_error;
END deleteValues;



/*======================================================================
 PROCEDURE:  PRINT_DEBUG_LOG	PRIVATE
   PARAMETERS:
   COMMENT   : 	This procedure is used to print debug messages into
		FND logs
======================================================================*/
PROCEDURE print_debug_log(p_module   IN    VARCHAR2,
                    	  p_message  IN    VARCHAR2)

IS

l_message_trun varchar2(800);

BEGIN
   IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string(log_level => FND_LOG.level_statement,
                        module  =>  g_module_prefix || p_module,
                        message  => p_message);
      END IF;
   END IF;
END;

/*======================================================================
 PROCEDURE:  PRINT_ERROR_LOG	PRIVATE
   PARAMETERS:
   COMMENT   : 	This procedure is used to print unexpected exceptions or
		error  messages into FND logs
======================================================================*/

PROCEDURE print_error_log(p_module   IN    VARCHAR2,
                    	  p_message  IN    VARCHAR2)
IS
BEGIN
   IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string(log_level => FND_LOG.level_procedure,
                        module    =>  g_module_prefix || p_module,
                        message   => p_message);
      END IF;
   END IF;
END;


END PON_FORMS_UTIL_PVT;

/
