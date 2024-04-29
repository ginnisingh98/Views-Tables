--------------------------------------------------------
--  DDL for Package Body PON_FORMS_JRAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_FORMS_JRAD_PVT" AS
-- $Header: PONFMJRB.pls 120.5 2007/09/03 05:48:10 adsahay ship $

-- we will switch between 2 regions, created for LOVs
-- 1st region will be used for LOVs with value-set validation list type set to 'Independent' or
-- 'Translatable Independent'
-- the 2nd region will be used for LOVs with value-set validation list type set to 'table'

g_jrad_lov_path_sql	CONSTANT VARCHAR2(60) := '/oracle/apps/pon/forms/jrad/webui/ponFormsSqlBasedLovRN';
g_jrad_lov_path_tab	CONSTANT VARCHAR2(60) := '/oracle/apps/pon/forms/jrad/webui/ponFormsTableBasedLovRN';
g_jrad_rgn_pkg_name	CONSTANT VARCHAR2(50) := '/oracle/apps/pon/forms/jrad/webui/';
g_jrad_ext_poplist	CONSTANT VARCHAR2(60) := '/oracle/apps/pon/forms/jrad/webui/ponExtAbsPoplistRG';
g_jrad_ext_page_path	CONSTANT VARCHAR2(60) := '/oracle/apps/pon/forms/jrad/webui/ponExtAbstractTableRG';
g_jrad_long_tip_rgn	CONSTANT VARCHAR2(60) := '/oracle/apps/pon/forms/jrad/webui/ponFormsJradLongTipRN';

g_ext_abs_vo_name	CONSTANT VARCHAR2(50) := 'AbstractFieldsTableVO';

g_lov_code		CONSTANT VARCHAR2(20) := 'Code';
g_lov_description	CONSTANT VARCHAR2(20) := 'Description';
g_lov_meaning		CONSTANT VARCHAR2(20) := 'Meaning';
g_lov_vset_name		CONSTANT VARCHAR2(20) := 'ValueSetName';
g_values_viewName	CONSTANT VARCHAR2(20) := 'FormFieldValuesVO';
g_sql_poplist_view_name	CONSTANT VARCHAR2(20) := 'SqlBasedPoplistVO';
g_tab_poplist_view_name	CONSTANT VARCHAR2(20) := 'TableBasedPoplistVO';


g_fnd_debug 		CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name 		CONSTANT VARCHAR2(30) := 'PON_FORMS_JRAD_PVT';
g_module_prefix 	CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';

g_app_module		CONSTANT VARCHAR2(60) := 'oracle.apps.pon.forms.jrad.server.FormsDynamicJradAM';
g_controller		CONSTANT VARCHAR2(60) := 'oracle.apps.pon.forms.jrad.webui.FormsDynamicJradCO';
g_ext_app_module	CONSTANT VARCHAR2(60) := 'oracle.apps.pon.forms.jrad.server.FormsExtAbstractTableAM';
g_ext_controller	CONSTANT VARCHAR2(60) := 'oracle.apps.pon.forms.jrad.webui.FormsExtAbstractTableCO';

g_spacer		CONSTANT VARCHAR2(3)  := '---';
g_under_score		CONSTANT VARCHAR2(3)  := '_';

g_sql_pop_list_count 	INTEGER;
g_table_pop_list_count	INTEGER;
g_lov_map_count		INTEGER;
g_pop_list_count 	INTEGER;
g_total_image_count	INTEGER;
g_total_element_count	INTEGER;
g_base_language		VARCHAR2(4);
v_date_list_count 	INTEGER;
v_table_vo_count 	INTEGER;


/*======================================================================
 FUNCTION:  ISLOVVALUESET	PRIVATE
   PARAMETERS: NONE
   COMMENT   : 	This function is used to escape special characters in the
		the prompts for various fields/sections.
======================================================================*/

FUNCTION isLovValueSet(p_field_code IN VARCHAR2) RETURN VARCHAR2 IS

v_ret_value	VARCHAR2(1);
l_api_name	CONSTANT  VARCHAR2(30) := 'ISLOVVALUESET';

BEGIN
	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'BEGIN');

	v_ret_value := 'N';

	BEGIN
		select  decode(fnd_flex_value_sets.longlist_flag, 'X', 'N', 'Y') isLov
		into    v_ret_value
		from 	pon_fields,
			fnd_flex_value_sets
		where	pon_fields.value_set_name = fnd_flex_value_sets.flex_value_set_name
		and	pon_fields.value_set_name is not null
		and	pon_fields.field_code	  = p_field_code;

	EXCEPTION
		WHEN OTHERS THEN
			v_ret_value := 'N';
	END;


	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'RETURN VALUE=' || v_ret_value);

	RETURN v_ret_value;

END isLovValueSet;



/*======================================================================
 FUNCTION:  ESCAPESPECIALCHAR	PRIVATE
   PARAMETERS: NONE
   COMMENT   : 	This function is used to escape special characters in the
		the prompts for various fields/sections.
======================================================================*/

FUNCTION escapeSpecialChar(p_prompt IN VARCHAR2) RETURN VARCHAR2 IS

v_ret_value	VARCHAR2(120);
l_api_name	CONSTANT  VARCHAR2(30) := 'ESCAPESPECIALCHAR';

BEGIN
	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'BEGIN');

	v_ret_value := replace(p_prompt, '&', '&'||'amp;');

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'RETURN VALUE=' || v_ret_value);

	RETURN v_ret_value;

END escapeSpecialChar;


/*======================================================================
 FUNCTION:  GETPARENTELEMENTINDEX	PRIVATE
   PARAMETERS: NONE
   COMMENT   : 	This function is used to determine the index of the parent
		item in the tree of region items while creating the JRAD
		for a form.
======================================================================*/

FUNCTION getParentElementIndex (p_type 		IN VARCHAR2,
				p_form_id 	IN NUMBER,
				p_section_id	IN NUMBER,
				p_incl_sec_id	IN NUMBER,
				p_rept_sec_id	IN NUMBER,
				p_field_code	IN VARCHAR2) RETURN VARCHAR2 IS

v_ret_value	VARCHAR2(120);
l_api_name	CONSTANT  VARCHAR2(30) := 'GETPARENTELEMENTINDEX';

BEGIN
	IF	(p_type = 'FORM') THEN
		-- no parent
		null;
	ELSIF   (p_type = 'FORM_FIELD') THEN
		-- parent is form
		v_ret_value := 'FORM' 	|| g_spacer || p_form_id || g_spacer || 0
					|| g_spacer || 0 	 || g_spacer || 0
					|| g_spacer || to_char(null);

	ELSIF	(p_type = 'NORMAL_SECTION') THEN
		-- parent is form
		v_ret_value := 'FORM' 	|| g_spacer || p_form_id || g_spacer || 0
					|| g_spacer || 0 	 || g_spacer || 0
					|| g_spacer|| to_char(null);

	ELSIF	(p_type = 'SECTION_FIELD') THEN
		-- parent is normal_section
		v_ret_value := 'NORMAL_SECTION'
					|| g_spacer || p_form_id || g_spacer  || p_section_id
					|| g_spacer || 0 	 || g_spacer  || 0
					|| g_spacer|| to_char(null);

	ELSIF	(p_type = 'INNER_NORMAL_SECTION') THEN
		-- parent is normal_section
		v_ret_value := 'NORMAL_SECTION'
					|| g_spacer || p_form_id || g_spacer || p_section_id
					|| g_spacer || 0 	 || g_spacer || 0
					|| g_spacer || to_char(null);

	ELSIF	(p_type = 'INNER_SECTION_FIELD') THEN
		-- parent is inner_normal_section
		v_ret_value := 'INNER_NORMAL_SECTION'
					|| g_spacer || p_form_id     || g_spacer || p_section_id
					|| g_spacer || p_incl_sec_id || g_spacer || 0
					|| g_spacer || to_char(null);

	ELSIF	(p_type = 'REPEAT_SECTION') THEN
		-- parent is form
		v_ret_value := 'FORM' 	|| g_spacer || p_form_id || g_spacer || 0
					|| g_spacer || 0 	 || g_spacer || 0
					|| g_spacer || to_char(null);

	ELSIF	(p_type = 'INNER_REPEAT_SECTION') THEN
		-- parent is normal_section
		v_ret_value := 'NORMAL_SECTION'
					|| g_spacer || p_form_id || g_spacer || p_section_id
					|| g_spacer || 0 	 || g_spacer || 0
					|| g_spacer || to_char(null);

	ELSIF	(p_type = 'INNER_SECTION_REPEAT_SECTION') THEN
		-- parent is inner_normal_section
		v_ret_value := 'INNER_NORMAL_SECTION'
					|| g_spacer || p_form_id     || g_spacer || p_section_id
					|| g_spacer || p_incl_sec_id || g_spacer || 0
					|| g_spacer || to_char(null);
	END IF;

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'RETURN VALUE=' || v_ret_value);

	RETURN v_ret_value;

END getparentelementindex;



/*======================================================================
 FUNCTION:  GETCURRENTELEMENTINDEX	PRIVATE
   PARAMETERS: NONE
   COMMENT   : 	This function is used to return the index of the current
		region item or region in the entire tree of JRAD items
		while constructing the JRAD for a given form.
======================================================================*/

FUNCTION getCurrentElementIndex(p_type 		IN VARCHAR2,
				p_form_id 	IN NUMBER,
				p_section_id	IN NUMBER,
				p_incl_sec_id	IN NUMBER,
				p_rept_sec_id	IN NUMBER,
				p_field_code	IN VARCHAR2) RETURN VARCHAR2 IS

v_ret_value	VARCHAR2(120);
l_api_name	CONSTANT  VARCHAR2(30) := 'GETCURRENTELEMENTINDEX';

BEGIN
	v_ret_value := p_type || g_spacer || p_form_id 	   || g_spacer || p_section_id
			      || g_spacer || p_incl_sec_id || g_spacer || p_rept_sec_id
			      || g_spacer || to_char(null);

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'RETURN VALUE=' || v_ret_value);

	RETURN v_ret_value;

END getCurrentElementIndex;

/*======================================================================
 FUNCTION:  GETDISPLAYTYPE	PRIVATE
   PARAMETERS: NONE
   COMMENT   : 	Since we have restrictions on the number of characters
		that we can have in a JRAD id, we will follow a certain
		convention to construct each JRAD element

======================================================================*/

FUNCTION getDisplayType (p_type IN VARCHAR2) RETURN VARCHAR2 IS

v_ret_value	VARCHAR2(2);
l_api_name	CONSTANT  VARCHAR2(30) := 'GETDISPLAYTYPE';

BEGIN

-- we do have the following restrictions -
-- we cannot have variable names starting with a number
-- we cannot have variables names with dashes
-- i.e. only alpha-numeric characters and underscores
-- max length for a JRAD id in PL/SQL is 60 characters
-- i think there's no max length for a java variable name (or atleast < 60 characters)

	IF	(p_type = 'FORM') THEN
		v_ret_value := 't1';
	ELSIF   (p_type = 'FORM_FIELD') THEN
		v_ret_value := 't2';
	ELSIF	(p_type = 'NORMAL_SECTION') THEN
		v_ret_value := 't3';
	ELSIF	(p_type = 'SECTION_FIELD') THEN
		v_ret_value := 't4';
	ELSIF	(p_type = 'INNER_NORMAL_SECTION') THEN
		v_ret_value := 't5';
	ELSIF	(p_type = 'INNER_SECTION_FIELD') THEN
		v_ret_value := 't6';
	ELSIF	(p_type = 'REPEAT_SECTION') THEN
		v_ret_value := 't7';
	ELSIF	(p_type = 'INNER_REPEAT_SECTION') THEN
		v_ret_value := 't8';
	ELSIF	(p_type = 'INNER_SECTION_REPEAT_SECTION') THEN
		v_ret_value := 't9';
	ELSE
		v_ret_value := 't0';
	END IF;

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'RETURN VALUE=' || v_ret_value);

	RETURN v_ret_value;

END getdisplaytype;


/*======================================================================
 FUNCTION:  GETDISPLAYID	PRIVATE

   PARAMETERS: NONE
   COMMENT   : 	This function simply returns the passed value or a null
		value if the passed value is a -1

======================================================================*/

FUNCTION getDisplayId(p_id IN NUMBER ) RETURN VARCHAR2 IS

v_ret_value	VARCHAR2(10);
l_api_name	CONSTANT  VARCHAR2(30) := 'GETDISPLAYID';

BEGIN
	IF(p_id = -1) THEN
		v_ret_value := to_char(null);
	ELSE
		v_ret_value := to_char(p_id);
	END IF;

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'RETURN VALUE=' || v_ret_value);

	RETURN v_ret_value;

END getDisplayId;



/*======================================================================
 FUNCTION:  GETJRADID	PRIVATE
   PARAMETERS: NONE
   COMMENT   : 	This function returns the actual JRAD id to be used while
		creating the JRAD for a form in such a way that it will
		always be unique in the entire hierarchy

======================================================================*/

FUNCTION getJradId(p_type 		IN VARCHAR2,
		p_form_id 	IN NUMBER,
		p_section_id	IN NUMBER,
		p_incl_sec_id	IN NUMBER,
		p_rept_sec_id	IN NUMBER,
		p_field_code	IN VARCHAR2) RETURN VARCHAR2 IS

-- JDR_COMPONENTS.comp_id%TYPE;
-- max max 60 characters

v_ret_value	VARCHAR2(60);
l_api_name	CONSTANT  VARCHAR2(30) := 'GETJRADID';

BEGIN
	v_ret_value := getDisplayType(p_type)
			      || 'FM_'  || getDisplayId(p_form_id)
			      || 'TS_'  || getDisplayId(p_section_id)
			      || 'IS_'  || getDisplayId(p_incl_sec_id)
			      || 'RS_'  || getDisplayId(p_rept_sec_id)
                              || 'FD_'  || p_field_code;


	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'RETURN VALUE=' || v_ret_value);

	RETURN v_ret_value;

END getJradId;



/*======================================================================
 PROCEDURE:  CREATE_LOV	PRIVATE
   PARAMETERS:
   COMMENT   : This procedure will create an LOV map for a messageLovInput
	       field.
======================================================================*/

PROCEDURE CREATE_LOV(
    p_field_code          IN VARCHAR2,
    p_vset_name		  IN VARCHAR2,
    p_mapping_field	  IN VARCHAR2,
    p_validation_type	  IN VARCHAR2,
    p_jrad_field_id	  IN VARCHAR2,
    p_input_elem IN 	  jdr_docbuilder.Element) IS

    err_num               NUMBER;
    err_msg               VARCHAR2(100);
    l_api_name	CONSTANT  VARCHAR2(30) := 'CREATE_LOV';
    lovMap  		  jdr_docbuilder.ELEMENT;

BEGIN
	/*
	  we want the lookup_type to be transferred from the generated page to the lov region
	  we want the meaning to be transferred from the lov region to the generated page
	  here's how our lovMappings shud look like
	*/

	-- from Meaning resultTo _NAME

   	lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
   	jdr_docbuilder.setAttribute(lovMap, 'id', 'lovMap' || g_lov_map_count);
   	jdr_docbuilder.setAttribute(lovMap, 'lovItem', g_lov_meaning);
	jdr_docbuilder.setAttribute(lovMap, 'resultTo', p_jrad_field_id);
	jdr_docbuilder.setAttribute(lovMap, 'criteriaFrom', p_jrad_field_id);
   	jdr_docbuilder.addChild(p_input_elem, jdr_docbuilder.JRAD_NS, 'lovMappings',lovMap);
   	g_lov_map_count := g_lov_map_count  + 1;

   	lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
   	jdr_docbuilder.setAttribute(lovMap, 'id', 'lovMap' || g_lov_map_count);
   	jdr_docbuilder.setAttribute(lovMap, 'lovItem', g_lov_code);
   	jdr_docbuilder.setAttribute(lovMap, 'resultTo', p_jrad_field_id || '_FORM');
   	jdr_docbuilder.addChild(p_input_elem, jdr_docbuilder.JRAD_NS, 'lovMappings',lovMap);
   	g_lov_map_count := g_lov_map_count  + 1;


	-- from base-page EO-based VO attribute to lovItem Code
	/*
   	lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
   	jdr_docbuilder.setAttribute(lovMap, 'id', 'lovMap' || g_lov_map_count);
   	jdr_docbuilder.setAttribute(lovMap, 'lovItem', g_lov_code);
   	jdr_docbuilder.setAttribute(lovMap, 'resultTo', p_mapping_field);
   	jdr_docbuilder.addChild(p_input_elem, jdr_docbuilder.JRAD_NS, 'lovMappings',lovMap);
   	g_lov_map_count := g_lov_map_count  + 1;
	*/

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'END');

EXCEPTION
    WHEN OTHERS THEN
	PON_FORMS_UTIL_PVT.print_error_log(l_api_name, 'EXCEPTION');
        err_num := SQLCODE;
        err_msg := SUBSTR(SQLERRM, 1, 100);

END CREATE_LOV;


/*======================================================================
 FUNCTION:  GETBASELANGUAGE	PRIVATE
   PARAMETERS: NONE
   COMMENT   : 	This function will get the base language of the instance,
	       	We will use this base language to create the default
		JRAD XML, although the prompts will be set dynamically
		at run time.
======================================================================*/

FUNCTION getBaseLanguage RETURN VARCHAR2 IS

v_base_language		  FND_LANGUAGES.LANGUAGE_CODE%TYPE;
l_api_name	CONSTANT  VARCHAR2(30) := 'GETBASELANGUAGE';

BEGIN
	-- just initialize this local variable to a default value

	V_BASE_LANGUAGE := g_base_language;

	SELECT 	LANGUAGE_CODE
	INTO 	V_BASE_LANGUAGE
	FROM	FND_LANGUAGES
	WHERE	NVL(INSTALLED_FLAG, 'X') = 'B';

	RETURN  V_BASE_LANGUAGE;

EXCEPTION
    WHEN OTHERS THEN
	PON_FORMS_UTIL_PVT.print_error_log(l_api_name, 'EXCEPTION');
	RETURN V_BASE_LANGUAGE;

END getBaseLanguage;


/*======================================================================
 FUNCTION:  CREATE_ELEMENT	PRIVATE
   PARAMETERS:
   COMMENT   : Generic function to create any type of element
======================================================================*/

FUNCTION CREATE_ELEMENT (
		  p_element_type 	IN VARCHAR2,
		  p_element_id 		IN VARCHAR2,
		  p_element_prompt 	IN VARCHAR2,
		  p_element_dataType 	IN VARCHAR2,
		  p_element_tipType 	IN VARCHAR2,
		  p_element_viewAttr 	IN VARCHAR2) RETURN JDR_DOCBUILDER.ELEMENT IS

v_return_jrad_element JDR_DOCBUILDER.ELEMENT;
l_api_name	CONSTANT  VARCHAR2(30) := 'CREATE_ELEMENT';

BEGIN

	 PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'BEGIN '
					|| p_element_type 	|| ' ' || p_element_id   || ' '
					|| p_element_dataType 	|| ' ' || p_element_viewAttr);

	 v_return_jrad_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, p_element_type);
	 JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'id', p_element_id);
	 JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'viewAttr', p_element_viewAttr);

	if(p_element_type <> 'formValue') then
	 	 JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'prompt', escapespecialchar(p_element_prompt));
		 JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'dataType', p_element_dataType);
		 JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'cellNoWrapFormat', 'true');
	end if;


	if(p_element_type = 'messageStyledText') then
		JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'styleClass', 'OraDataText');
	else
		if(p_element_tipType = 'dateFormat') then
			JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'tipType', p_element_tipType);
		elsif (p_element_tipType = 'longMessage') then
			JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'tipType', 'longMessage');
			JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'longTipRegion', g_jrad_long_tip_rgn);
		end if;
	end if;

	 PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'END');

	 return v_return_jrad_element;

END CREATE_ELEMENT;


/*======================================================================
 FUNCTION:  CREATE_TABLE_ELEMENT	PRIVATE
   PARAMETERS:
   COMMENT   : 	Generic function to create a display-only element in
		a table
======================================================================*/

FUNCTION CREATE_TABLE_ELEMENT (
		  p_element_type 	IN VARCHAR2,
		  p_element_id 		IN VARCHAR2,
		  p_element_prompt 	IN VARCHAR2,
		  p_element_dataType 	IN VARCHAR2,
		  p_element_tipType 	IN VARCHAR2,
		  p_element_viewAttr 	IN VARCHAR2) RETURN JDR_DOCBUILDER.ELEMENT IS

v_return_jrad_element JDR_DOCBUILDER.ELEMENT;
l_api_name	CONSTANT  VARCHAR2(30) := 'CREATE_TABLE_ELEMENT';

BEGIN

	 PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'BEGIN '
					|| p_element_type 	|| ' ' || p_element_id   || ' '
					|| p_element_dataType 	|| ' ' || p_element_viewAttr);

	v_return_jrad_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, p_element_type);
	JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'id', p_element_id);
	JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'viewAttr', p_element_viewAttr);

	JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'prompt', escapespecialchar(p_element_prompt));
	JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'dataType', p_element_dataType);
	JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'cellNoWrapFormat', 'true');

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'END');

	return v_return_jrad_element;

END CREATE_TABLE_ELEMENT;


/*======================================================================
 FUNCTION:  CREATE_VSET_ELEMENT		PRIVATE
   PARAMETERS:
   COMMENT   : 	Function to create any value-set based element in the
		JRAD. i.e. either a messageChoice or a messageLovInput
		Depending upon the vset definition, we will create the
		corresponding JRAD UI element.
======================================================================*/

FUNCTION create_vset_element (p_field_jrad_id 	IN VARCHAR2,
			      p_field_code	IN VARCHAR2,
			      p_field_name	IN VARCHAR2,
			      p_field_desc 	IN VARCHAR2,
			      p_mapping_field	IN VARCHAR2,
			      p_value_set_name	IN VARCHAR2,
			      p_in_table	IN VARCHAR2) RETURN JDR_DOCBUILDER.ELEMENT IS

v_return_jrad_element 	JDR_DOCBUILDER.ELEMENT;
v_display_type 		VARCHAR2(1);
v_validation_type	VARCHAR2(1);
l_api_name	CONSTANT  VARCHAR2(30) := 'CREATE_VSET_ELEMENT';
FND_FLEX_EXCEPTION  EXCEPTION;

BEGIN

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'BEGIN -'
					|| p_field_jrad_id || ' ' || p_field_code || ' '
					|| p_mapping_field || ' ' || p_value_set_name);

	BEGIN

		SELECT  fnd_flex_value_sets.LONGLIST_FLAG, fnd_flex_value_sets.VALIDATION_TYPE
		INTO 	v_display_type, v_validation_type
		FROM	fnd_flex_value_sets
		WHERE 	fnd_flex_value_sets.FLEX_VALUE_SET_NAME = p_value_set_name;

	EXCEPTION
		WHEN OTHERS THEN
			RAISE FND_FLEX_EXCEPTION;
	END;

	if(v_display_type = 'X') then --{

	-- create a poplist

		if(p_in_table = 'Y' OR nvl(p_field_desc, 'x@Y#z') = 'x@Y#z' ) then

			v_return_jrad_element := create_element ('messageChoice', p_field_jrad_id,
			                           	p_field_name, 'VARCHAR2','none',
						   	p_mapping_field);

		else
			v_return_jrad_element := create_element ('messageChoice', p_field_jrad_id,
			                           	p_field_name, 'VARCHAR2','longMessage',
						   	p_mapping_field);


		end if;

		if((v_validation_type = 'I') OR (v_validation_type = 'X')) then --{
			-- independent or translatable independent
			JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'pickListViewName',g_sql_poplist_view_name || g_sql_pop_list_count);
			JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'pickListDispAttr','Meaning');
			JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'pickListValAttr','Code');
			g_sql_pop_list_count := g_sql_pop_list_count + 1;

		--}

		elsif ((v_validation_type = 'F')) then --{

			-- poplist based on a table-based validation set
			-- need to create this VO in the middle tier, and associate that VOs attributes here
			-- 'Code' is VALUE_COLUMN, 'Meaning' is ID_COLUMN

			JDR_DOCBUILDER.setAttribute (v_return_jrad_element,'pickListViewName',g_tab_poplist_view_name||g_table_pop_list_count);

			JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'pickListDispAttr','ID_COLUMN');
			JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'pickListValAttr','VALUE_COLUMN');
			g_table_pop_list_count := g_table_pop_list_count + 1;

		end if; -- bad type done

		--} -- done creating a poplist

	elsif( (v_display_type = 'Y' ) OR (v_display_type = 'N')) then --{

		-- list of values OR long list of values

			if(p_in_table = 'Y' OR nvl(p_field_desc, 'x@Y#z') = 'x@Y#z') then

				-- here we should have the JRAD field Id as the VO attribute
				-- by default, the user will be able to search on the 'meaning' or
				-- user-displayed value
				-- the '_FORM' JRAD element will be based on p_mapping_field
				v_return_jrad_element := create_element ('messageLovInput', p_field_jrad_id,
			                                         p_field_name, 'VARCHAR2', 'none', p_field_jrad_id || '_NAME');
			else
				v_return_jrad_element := create_element ('messageLovInput', p_field_jrad_id,
			                                         p_field_name, 'VARCHAR2', 'longMessage', p_field_jrad_id || '_NAME');
			end if;

			-- depending upon the validation_type, we will associate this lov, with a different region

			if((v_validation_type = 'I') OR (v_validation_type = 'X')) then --{
				-- refer to direct sql query
				JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'externalListOfValues', g_jrad_lov_path_sql);
			--}
			elsif ((v_validation_type = 'F')) then --{
				-- create a sql query, and then create a vo
				JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'externalListOfValues', g_jrad_lov_path_tab);
			end if;
			--}

			-- JDR_DOCBUILDER.setAttribute (v_return_jrad_element, 'unvalidated', 'false');

			-- need to construct an LOV for v_form_fields_row.field_name
			create_lov(p_field_code, p_value_set_name, p_mapping_field,
				   v_validation_type, p_field_jrad_id, v_return_jrad_element);
			end if; --}

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'END');
	return v_return_jrad_element;

EXCEPTION
	WHEN FND_FLEX_EXCEPTION THEN
		RAISE_APPLICATION_ERROR(-20010, 'ERROR: FND FLEXFIELD VALIDATION SETS ERRROR FOR VALUE-SET ' || p_value_set_name);
END CREATE_VSET_ELEMENT;


/*======================================================================
 FUNCTION:  CREATE_TABLE	PRIVATE
   PARAMETERS:
   COMMENT   : 	This function is used to add all the columns to the table
 		of repeating section.
======================================================================*/

FUNCTION CREATE_TABLE(
	section_id 		 IN NUMBER,
	v_section_layout_element IN JDR_DOCBUILDER.ELEMENT,
	p_form_ID 		 IN NUMBER,
	p_vocount 		 IN INTEGER,
	p_readonly_flag		 IN VARCHAR2,
	p_row_seq_num		 IN NUMBER)
RETURN	JDR_DOCBUILDER.ELEMENT IS

l_api_name	CONSTANT  VARCHAR2(30) := 'CREATE_TABLE';

CURSOR V_FORM_FIELDS_CURSOR(p_form_id NUMBER) is

SELECT	pon_form_section_compiled.FORM_ID,
	pon_form_section_compiled.TYPE,
	pon_form_section_compiled.FIELD_CODE,
	pon_form_section_compiled.MAPPING_FIELD_VALUE_COLUMN,
	pon_form_section_compiled.REQUIRED,
	NVL (pon_form_section_compiled.LEVEL1_SECTION_ID, -1) LEVEL1_SECTION_ID,
	pon_forms_sections.FORM_CODE SECTION_CODE,
	pon_fields.DATATYPE ,
	pon_fields.VALUE_SET_NAME,
	pon_fields.SYSTEM_FLAG,
	pon_fields_tl.FIELD_NAME,
	pon_fields_tl.DESCRIPTION FIELD_DESCRIPTION,
	pon_form_section_compiled.INTERNAL_SEQUENCE_NUMBER,
	NVL(pon_form_section_compiled.LEVEL2_SECTION_ID, -1) LEVEL2_SECTION_ID,
	NVL(pon_form_section_compiled.REPEATING_SECTION_ID, -1) SECTION_ID
FROM	PON_FORM_SECTION_COMPILED,
	PON_FIELDS,
	PON_FIELDS_TL,
	PON_FORMS_SECTIONS
WHERE   pon_form_section_compiled.FIELD_CODE = pon_fields.FIELD_CODE(+)
AND     pon_form_section_compiled.FIELD_CODE = pon_fields_tl.FIELD_CODE(+)
AND	pon_forms_sections.FORM_ID	     = P_FORM_ID
AND     pon_form_section_compiled.FORM_ID    = P_FORM_ID
AND	pon_form_section_compiled.TYPE	     IN ('FORM_FIELD', 'REPEAT_SECTION')
AND	pon_fields_tl.LANGUAGE(+)	     = g_base_language
ORDER BY
	INTERNAL_SEQUENCE_NUMBER;

v_section_field_element 	JDR_DOCBUILDER.ELEMENT;
v_message_layout_element	JDR_DOCBUILDER.ELEMENT;
v_temp_element 			JDR_DOCBUILDER.ELEMENT;
v_column_header_element 	JDR_DOCBUILDER.ELEMENT;
v_form_fields_row 		V_FORM_FIELDS_CURSOR%ROWTYPE;
v_section_title 		PON_FORMS_SECTIONS_TL.FORM_NAME%TYPE;
v_section_code			PON_FORMS_SECTIONS.FORM_CODE%TYPE;
v_action_parameters 		JDR_DOCBUILDER.ELEMENT;
v_action_parameter 		JDR_DOCBUILDER.ELEMENT;
v_curr_formfieldvaluesvo_name 	VARCHAR2(20);
v_display_type 			VARCHAR2(1);
v_validation_type 		VARCHAR2(1);
v_jrad_field_id			VARCHAR2(200);
v_jrad_element_id		VARCHAR2(200);
v_LEVEL1_SECTION_ID		NUMBER;
v_incl_section_id		NUMBER;
v_parent_row_type		PON_FORM_SECTION_COMPILED.TYPE%TYPE;
v_vset_element_created		VARCHAR2(1);

BEGIN

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'BEGIN -' || section_id);

	v_curr_formfieldvaluesvo_name := g_values_viewName || p_vocount;

	--
	v_LEVEL1_SECTION_ID  := -1;
	v_incl_section_id := -1;
	v_vset_element_created := 'N';

	IF(section_id <> p_form_id) THEN

    	/*
      	  This means we are creating the MDS region for the table associated with
      	  the form
       */

		select  LEVEL1_SECTION_ID , LEVEL2_SECTION_ID, type
		into	v_LEVEL1_SECTION_ID, v_incl_section_id, v_parent_row_type
		from	pon_form_section_compiled
		where	form_id = p_form_id
		and	repeating_section_id = section_id
		and 	internal_sequence_number = p_row_seq_num;

	END IF;

	for v_form_fields_row in V_FORM_FIELDS_CURSOR(section_id) LOOP

		-- repeating section within repeating section

	    IF (v_form_fields_row.TYPE = 'REPEAT_SECTION') THEN

		/*CASE I : REPEATING SECTION WITHIN REPEATING SECTION*/

  		v_jrad_element_id := getJradId (v_form_fields_row.type,
                                      p_form_id,
                                      v_LEVEL1_SECTION_ID,
                                      v_incl_section_id,
                                      v_form_fields_row.section_id,  -- pass the inner repeating section id
                                      v_form_fields_row.field_code);

    	    ELSE

		IF(section_id <> p_form_id) THEN

		        /* CASE II : 	WE ARE GENERATING THE JRAD FOR A FORM, BUT NOW WE ARE IN THE
			             C	ONTEXT OF GENERATING THE TABLE FOR A REPEATING SECTION WHICH
					IS DIRECTLY ATTACHED TO A FORM - I.E. DISPLAYED ON THE MAIN
					PAGE OF THE FORM - WE PASS THE FORM-ID AS THE DRIVING KEY
			*/

  			v_jrad_element_id := getJradId (v_form_fields_row.type,
                                      p_form_id,
                                      v_LEVEL1_SECTION_ID,
                                      v_incl_section_id,
                                      section_id,
                                      v_form_fields_row.field_code);

      			v_jrad_field_id := v_jrad_element_id;

		ELSE

		        /* CASE III : 	WE ARE GENERATING THE JRAD FOR A REPEATING SECTION - A STAND ALONE
					JRAD: WE ARE IN THE CONTEXT OF GENERATING THE TABLE FOR A REPEATING SECTION WHICH
					IS INSIDE ANOTHER REPEATING SECTION ATTACHED TO A FORM -
					I.E. DISPLAYED ON A SEPARATE DRILL-DOWN PAGE OF THE FORM -
					WE PASS THE SECTION-ID AS THE DRIVING KEY
			*/

  			v_jrad_element_id := getJradId (v_form_fields_row.type,
                                      SECTION_ID,
                                      v_LEVEL1_SECTION_ID,
                                      v_incl_section_id,
                                      -1,
                                      v_form_fields_row.field_code);

      			v_jrad_field_id := v_jrad_element_id;


		END IF;
	END IF;

		IF (v_form_fields_row.type='REPEAT_SECTION') then --{

			  SELECT
			  	  forms_tl.form_name , forms.form_code
			  INTO
				  v_section_title, v_section_code
			  FROM
				  pon_forms_sections 	forms,
				  pon_forms_sections_tl forms_tl
			  WHERE
				  forms.form_id 	= forms_tl.form_id AND
				  forms.form_id		= v_form_fields_row.section_id AND
				  forms_tl.LANGUAGE	= g_base_language;

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'Creat image for inner repeating section '
							|| v_form_fields_row.section_id || ' ' || v_section_title);

		 	v_section_field_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'image');
			JDR_DOCBUILDER.setAttribute (v_section_field_element, 'id', v_jrad_element_id || 'IMG' || g_total_image_count);
			JDR_DOCBUILDER.setAttribute (v_section_field_element, 'serverUnvalidated', 'true');
			JDR_DOCBUILDER.setAttribute (v_section_field_element, 'warnAboutChanges', 'false');

			if(nvl(p_readonly_flag, 'N') = 'Y') then
				JDR_DOCBUILDER.setAttribute (v_section_field_element, 'source', 'eyeglasses_24x24_transparent.gif');
			else
				JDR_DOCBUILDER.setAttribute (v_section_field_element, 'source', 'rework_enabled.gif');
			end if;


			v_action_parameters := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'fireAction');
			JDR_DOCBUILDER.setAttribute (v_action_parameters, 'event', 'DetailsIconClicked');

			-- add all the parameters we want to pass to the details page

			v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'FORM_FIELD_VALUES_ID');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value',
						     '${oa.encrypt.' || v_curr_formfieldvaluesvo_name ||  '.FormFieldValueId}');
			JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);

			v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'FORM_ID');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value',
						     '${oa.encrypt.' || v_curr_formfieldvaluesvo_name ||  '.FormId}');
			JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);


			v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'OWNING_ENTITY_CODE');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value',
						     '${oa.encrypt.' || v_curr_formfieldvaluesvo_name ||  '.OwningEntityCode}');
			JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);


			v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'ENTITY_PK1');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value',
						     '${oa.encrypt.' || v_curr_formfieldvaluesvo_name ||  '.EntityPk1}');
			JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);

			v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'SECTION_ID');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value',
						     '${oa.encrypt.' || v_curr_formfieldvaluesvo_name ||  '.SectionId}');
			JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);

			v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'PARENT_FIELD_VALUES_FK');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value',
						     '${oa.encrypt.' || v_curr_formfieldvaluesvo_name ||  '.ParentFieldValuesFk}');
			JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);

			v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'DETAIL_SECTION_CODE');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value', v_section_code);
			JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);


			v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'DETAIL_SECTION_ID');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value', v_form_fields_row.section_id);
			JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);


			v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'DETAIL_JRAD_PAGE_MODE');

			if(nvl(p_readonly_flag, 'N') = 'Y') then
				JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value', 'SECTION_READ_ONLY');
			else
				JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value', 'SECTION_DATA_ENTRY');
			end if;

			JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);


			v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'FROM_PAGE');
			JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value', 'PON_FORMS_JRAD_GENX');
			JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);

			JDR_DOCBUILDER.addChild (v_section_field_element, JDR_DOCBUILDER.UI_NS,
						 'primaryClientAction', v_action_parameters);
		--}

		elsIF (v_form_fields_row.datatype='LONGTEXT') then --{

			IF(p_readonly_flag = 'N') THEN

				v_section_field_element := create_element ('messageTextInput', v_form_fields_row.field_code,
			                                            v_form_fields_row.field_name, 'VARCHAR2',
								   'none',v_form_fields_row.mapping_field_value_column);

				JDR_DOCBUILDER.setAttribute (v_section_field_element, 'maximumLength', 2000);
			ELSE
				v_section_field_element := create_table_element ('messageStyledText', v_form_fields_row.field_code,
			                                            v_form_fields_row.field_name, 'VARCHAR2',
								   'none',v_form_fields_row.mapping_field_value_column);


			END IF;
		 --}
	  	 ELSIF (v_form_fields_row.datatype='DATE') then --{

			IF(p_readonly_flag = 'N') THEN

				v_section_field_element := create_element ('messageTextInput', v_jrad_field_id,
			                                            v_form_fields_row.field_name, 'DATE', 'dateFormat',
								    v_form_fields_row.mapping_field_value_column);

				v_date_list_count := v_date_list_count + 1;

			ELSE
				v_section_field_element := create_table_element ('messageStyledText', v_jrad_field_id,
			                                            v_form_fields_row.field_name, 'DATE', 'dateFormat',
								    v_form_fields_row.mapping_field_value_column);

			END IF;
		--}
	  	 ELSIF (v_form_fields_row.datatype='DATETIME') then --{

			IF(p_readonly_flag = 'N') THEN

				v_section_field_element := create_element ('messageTextInput', v_jrad_field_id,
			                                            v_form_fields_row.field_name, 'DATETIME','dateFormat',
								    v_form_fields_row.mapping_field_value_column);

			ELSE

				v_section_field_element := create_table_element ('messageStyledText', v_jrad_field_id,
			                                            v_form_fields_row.field_name, 'DATETIME','dateFormat',
								    v_form_fields_row.mapping_field_value_column);


			END IF;
		--}
	  	 ELSIF (v_form_fields_row.datatype='AMOUNT') then --{

			IF(p_readonly_flag = 'N') THEN

				v_section_field_element := create_element ('messageTextInput', v_jrad_field_id,
			                                            v_form_fields_row.field_name, 'NUMBER', 'none',
								    v_form_fields_row.mapping_field_value_column);

			ELSE

				v_section_field_element := create_table_element ('messageStyledText', v_jrad_field_id,
			                                            v_form_fields_row.field_name, 'NUMBER', 'none',
								    v_form_fields_row.mapping_field_value_column);

			END IF;
		--}
	  	 ELSIF (v_form_fields_row.datatype='NUMBER') then --{

			IF(p_readonly_flag = 'N') THEN

				v_section_field_element := create_element ('messageTextInput', v_jrad_field_id,
			                                            v_form_fields_row.field_name, 'NUMBER', 'none',
								    v_form_fields_row.mapping_field_value_column);
			ELSE
				v_section_field_element := create_table_element ('messageStyledText', v_jrad_field_id,
			                                            v_form_fields_row.field_name, 'NUMBER', 'none',
								    v_form_fields_row.mapping_field_value_column);
			END IF;

		--}
		 ELSIF (v_form_fields_row.datatype='TEXT' AND v_form_fields_row.value_set_name is not null) then --{

			IF(p_readonly_flag = 'Y') THEN

				v_section_field_element := create_table_element ('messageStyledText', v_jrad_field_id,
			                                            	   v_form_fields_row.field_name, 'VARCHAR2','none',
									   v_jrad_field_id || '_NAME');
									   --v_form_fields_row.field_code || '_NAME');

			ELSE
				v_section_field_element := create_vset_element (v_jrad_field_id,
									v_form_fields_row.field_code,
									v_form_fields_row.field_name,
									v_form_fields_row.field_description,
									v_form_fields_row.mapping_field_value_column,
									v_form_fields_row.value_set_name,
									'Y');

				v_vset_element_created := 'Y';

			END IF;
		--}
	  	 ELSE -- TBD: Unrecognized field --{

			IF(p_readonly_flag = 'N') THEN

				v_section_field_element := create_element ('messageTextInput', v_jrad_field_id,
			                                           v_form_fields_row.field_name, 'VARCHAR2','none',
								   v_form_fields_row.mapping_field_value_column);
			ELSE

				v_section_field_element := create_table_element ('messageStyledText', v_jrad_field_id,
			                                           v_form_fields_row.field_name, 'VARCHAR2','none',
								   v_form_fields_row.mapping_field_value_column);

			END IF;

		--}
	  	 END IF;

		 IF (v_form_fields_row.required='Y') THEN
		 	JDR_DOCBUILDER.setAttribute (v_section_field_element, 'required', 'yes');
		 END IF;

		IF (v_form_fields_row.type='REPEAT_SECTION') then

			v_temp_element := JDR_DOCBUILDER.CREATEELEMENT (JDR_DOCBUILDER.OA_NS, 'column');
			JDR_DOCBUILDER.setAttribute (v_temp_element, 'id', v_jrad_element_id || '_COL');
			JDR_DOCBUILDER.setAttribute (v_temp_element, 'columnDataFormat', 'iconButtonFormat');

		   	JDR_DOCBUILDER.addChild (v_section_layout_element, JDR_DOCBUILDER.UI_NS, 'contents', v_temp_element);

			JDR_DOCBUILDER.addChild (v_temp_element, JDR_DOCBUILDER.UI_NS, 'contents', v_section_field_element);

		   	v_column_header_element := JDR_DOCBUILDER.CREATEELEMENT (JDR_DOCBUILDER.OA_NS, 'sortableHeader');
		   	JDR_DOCBUILDER.setAttribute (v_column_header_element, 'id', v_jrad_element_id ||  '_SCLHDR');
		   	JDR_DOCBUILDER.setAttribute (v_column_header_element, 'prompt', escapespecialchar(v_section_title));
		   	JDR_DOCBUILDER.addChild (v_temp_element, JDR_DOCBUILDER.UI_NS, 'columnHeader', v_column_header_element);
		ELSE
			v_temp_element := JDR_DOCBUILDER.CREATEELEMENT (JDR_DOCBUILDER.OA_NS, 'column');
			JDR_DOCBUILDER.setAttribute (v_temp_element, 'id', v_jrad_element_id || '_COL');

			-- need to set the column format for a 'NUMBER'

			if ((v_form_fields_row.datatype='NUMBER') OR (v_form_fields_row.datatype='AMOUNT') ) then
				JDR_DOCBUILDER.setAttribute (v_temp_element, 'columnDataFormat', 'numberFormat');
			end if;

		   	JDR_DOCBUILDER.addChild (v_section_layout_element, JDR_DOCBUILDER.UI_NS, 'contents', v_temp_element);

		   	JDR_DOCBUILDER.addChild (v_temp_element, JDR_DOCBUILDER.UI_NS, 'contents', v_section_field_element);

			---- need to create a formValue element for this LOV

			if(v_vset_element_created = 'Y' and isLovValueSet(v_form_fields_row.field_code) = 'Y') then

				v_vset_element_created := 'N';

				v_section_field_element := create_element ('formValue', v_jrad_element_id || '_FORM',
			                                           v_form_fields_row.field_name, 'VARCHAR2', 'none',
								   v_form_fields_row.mapping_field_value_column);

			       	JDR_DOCBUILDER.setAttribute (v_section_field_element, 'viewName', v_curr_formfieldvaluesvo_name);
			       	JDR_DOCBUILDER.addChild (v_temp_element,jdr_docbuilder.UI_NS,'contents',v_section_field_element);

			end if;
			--

		   	v_column_header_element := JDR_DOCBUILDER.CREATEELEMENT (JDR_DOCBUILDER.OA_NS, 'sortableHeader');
		   	JDR_DOCBUILDER.setAttribute (v_column_header_element, 'id', v_jrad_element_id || '_SCLHDR');
		   	JDR_DOCBUILDER.setAttribute (v_column_header_element, 'prompt', escapespecialchar(v_form_fields_row.field_name));

		    	IF (v_form_fields_row.required='Y') THEN
		       		JDR_DOCBUILDER.setAttribute (v_column_header_element, 'required', 'yes');
		    	END IF;
		   	JDR_DOCBUILDER.addChild (v_temp_element, JDR_DOCBUILDER.UI_NS, 'columnHeader', v_column_header_element);
		END IF;

	END LOOP;

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'END');

	return v_section_layout_element;

END CREATE_TABLE;

/*======================================================================
 PROCEDURE:  CREATE_REPEATING_SECTION	PRIVATE
   PARAMETERS:
   COMMENT   : 	This procedure is invoked when a repeating section is
		made active, in order to generate the JRAD regions for
		that section
======================================================================*/

PROCEDURE CREATE_REPEATING_SECTION(p_section_id 	IN NUMBER,
  				   x_result		OUT NOCOPY  VARCHAR2,
  				   x_error_code    	OUT NOCOPY  VARCHAR2,
  				   x_error_message 	OUT NOCOPY  VARCHAR2) IS
rval INTEGER;

v_section_title 	PON_FORMS_SECTIONS_TL.FORM_NAME%TYPE;

v_section_code		PON_FORMS_SECTIONS.FORM_CODE%TYPE;
v_section_entry_path	PON_FORMS_SECTIONS.JRAD_XML_REGION_NAME%TYPE;
v_section_read_path	PON_FORMS_SECTIONS.JRAD_XML_REGION_NAME_DISP%TYPE;


v_section_element 		JDR_DOCBUILDER.ELEMENT;
v_section_layout_element 	JDR_DOCBUILDER.ELEMENT;
v_delete_field_element 		JDR_DOCBUILDER.ELEMENT;
v_delete_parameter 		JDR_DOCBUILDER.ELEMENT;
v_delete_parameters 		JDR_DOCBUILDER.ELEMENT;
v_add_table_row_element 	JDR_DOCBUILDER.ELEMENT;
v_table_footer_element 		JDR_DOCBUILDER.ELEMENT;
v_section_element_rd 		JDR_DOCBUILDER.ELEMENT;
v_section_layout_element_rd 	JDR_DOCBUILDER.ELEMENT;
v_table_footer_element_rd 	JDR_DOCBUILDER.ELEMENT;
v_temp_element 			JDR_DOCBUILDER.ELEMENT;
v_column_header_element 	JDR_DOCBUILDER.ELEMENT;
v_section_tip_element		JDR_DOCBUILDER.ELEMENT;
v_section_desc			PON_FORMS_SECTIONS_TL.FORM_DESCRIPTION%TYPE;

v_view_name 			VARCHAR2(30);

mainDocBuyerEntry 		JDR_DOCBUILDER.DOCUMENT;
mainDocReadOnly			JDR_DOCBUILDER.DOCUMENT;

l_api_name	CONSTANT  VARCHAR2(30) := 'CREATE_REPEATING_SECTION';

BEGIN
	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'BEGIN-');

	-- initialize to error
	x_result := fnd_api.g_ret_sts_error;

	-- always use VO1 for independent repeating section
	v_view_name := g_values_viewName || '1';

	v_section_entry_path := PON_FORMS_UTIL_PVT.getDataEntryRegionName(p_section_id);
	v_section_read_path  := PON_FORMS_UTIL_PVT.getReadOnlyRegionName(p_section_id);


	IF (JDR_DOCBUILDER.DOCUMENTEXISTS(v_section_entry_path)=TRUE) THEN
		  JDR_DOCBUILDER.DELETEDOCUMENT (v_section_entry_path);
    	END IF;


	IF (JDR_DOCBUILDER.DOCUMENTEXISTS(v_section_read_path)=TRUE) THEN
		  JDR_DOCBUILDER.DELETEDOCUMENT (v_section_read_path);
    	END IF;

	-- reset the top level documents
	mainDocBuyerEntry := NULL;
	mainDocReadOnly   := NULL;


	-- initialize the mainDoc
	mainDocBuyerEntry := JDR_DOCBUILDER.createDocument (v_section_entry_path,'en-US');

	mainDocReadOnly	  := JDR_DOCBUILDER.createDocument (v_section_read_path,'en-US');

	-- initialize a few global variables
	g_sql_pop_list_count 	:= 1; -- display a poplist, vo-based on direct sql query (eg. SqlPopListVO1)
	g_table_pop_list_count	:= 1; -- display a poplist, vo based on a generated sql query (eg. TablePopListVO1)
	g_lov_map_count		:= 1; -- display a lov, total number of LOVs displayed on page
	g_pop_list_count 	:= 1;

	SELECT
		forms_tl.form_name, forms.form_code, forms_tl.tip_text
	INTO 	v_section_title, v_section_code, v_section_desc
	FROM
		pon_forms_sections forms,
		pon_forms_sections_tl forms_tl
	WHERE
		forms.form_id		= forms_tl.form_id AND
		forms.form_id		= p_section_id AND
		forms_tl.LANGUAGE	= g_base_language;

	v_section_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');
	JDR_DOCBUILDER.setAttribute (v_section_element, 'id', v_section_code);
	JDR_DOCBUILDER.setAttribute (v_section_element, 'text', escapespecialchar(v_section_title));

	-- add a small tip element if description has been entered
	if(nvl(v_section_desc, 'E') <> 'E') then
		v_section_tip_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'tip');
		JDR_DOCBUILDER.setAttribute (v_section_tip_element, 'id',  v_section_code || '_TIP');
		JDR_DOCBUILDER.setAttribute (v_section_tip_element, 'text', escapespecialchar(v_section_desc));
		JDR_DOCBUILDER.addChild(v_section_element, jdr_docbuilder.UI_NS,'contents',v_section_tip_element);
	end if;

	v_section_layout_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'advancedTable');
	JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'id', v_section_code||'_table');
	JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'viewName', v_view_name);
	JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'width', '100%');

	v_table_footer_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'tableFooter');
	JDR_DOCBUILDER.setAttribute (v_table_footer_element, 'id', v_section_code|| '_TABFTR');
	JDR_DOCBUILDER.addChild (v_section_layout_element, JDR_DOCBUILDER.UI_NS, 'footer', v_table_footer_element);

	v_add_table_row_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'addTableRow');
	JDR_DOCBUILDER.setAttribute (v_add_table_row_element, 'id', v_section_code||'_ADDBTN');
	JDR_DOCBUILDER.setAttribute (v_add_table_row_element, 'autoInsertion', 'false');
	JDR_DOCBUILDER.addChild (v_table_footer_element, JDR_DOCBUILDER.UI_NS, 'contents', v_add_table_row_element);

	-- add all the remaining columns to this table
	v_section_layout_element := CREATE_TABLE(p_section_id, v_section_layout_element,p_section_id, 1, 'N', -1);

	v_temp_element := JDR_DOCBUILDER.CREATEELEMENT (JDR_DOCBUILDER.OA_NS, 'column');
	JDR_DOCBUILDER.setAttribute (v_temp_element, 'id', 'columnDelete' || v_section_code);
	JDR_DOCBUILDER.setAttribute (v_temp_element, 'columnDataFormat', 'iconButtonFormat');
	JDR_DOCBUILDER.addChild (v_section_layout_element, JDR_DOCBUILDER.UI_NS, 'contents', v_temp_element);

	v_column_header_element := JDR_DOCBUILDER.CREATEELEMENT (JDR_DOCBUILDER.OA_NS, 'sortableHeader');
	JDR_DOCBUILDER.setAttribute (v_column_header_element, 'id', 'columnHeader' || v_section_code);
	JDR_DOCBUILDER.setAttribute (v_column_header_element, 'prompt', 'Delete');
	JDR_DOCBUILDER.addChild (v_temp_element, JDR_DOCBUILDER.UI_NS, 'columnHeader', v_column_header_element);

	-- add a delete image
	v_delete_field_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS,'image');
	JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'id', 'deleteImage' || v_section_code);
	JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'source', 'deleteicon_enabled.gif');
	JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'warnAboutChanges', 'false');
	JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'serverUnvalidated', 'true');
	JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'unvalidated', 'true');

	JDR_DOCBUILDER.addChild (v_temp_element, JDR_DOCBUILDER.UI_NS, 'contents', v_delete_field_element);

	v_delete_parameters := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'fireAction');
	JDR_DOCBUILDER.setAttribute (v_delete_parameters, 'event', 'Delete');
	JDR_DOCBUILDER.setAttribute (v_delete_parameters, 'unvalidated', 'true');
	v_delete_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
	JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'key', 'Id');
	JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'value', '${oa.encrypt.' || v_view_name ||'.FormFieldValueId}');
	JDR_DOCBUILDER.addChild (v_delete_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_delete_parameter);
	v_delete_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
	JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'key', 'ViewName');
	JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'value', v_view_name);
	JDR_DOCBUILDER.addChild (v_delete_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_delete_parameter);
	JDR_DOCBUILDER.addChild (v_delete_field_element, JDR_DOCBUILDER.UI_NS, 'primaryClientAction', v_delete_parameters);


	JDR_DOCBUILDER.addChild (v_section_element, jdr_docbuilder.UI_NS,'contents',v_section_layout_element);

	JDR_DOCBUILDER.setTopLevelElement(mainDocBuyerEntry, v_section_element);

	--------------------------------------
	-----READ--ONLY--REGION---START-------
	--------------------------------------

	v_section_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');
	JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'id', v_section_code);
	JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'text', escapespecialchar(v_section_title));

	v_section_layout_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'advancedTable');
	JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'id', v_section_code||'table1');
	JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'viewName', v_view_name);
	JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'width', '100%');

	v_table_footer_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'tableFooter');
	JDR_DOCBUILDER.setAttribute (v_table_footer_element_rd, 'id', v_section_code|| '_TABFTR');
	JDR_DOCBUILDER.addChild (v_section_layout_element_rd, JDR_DOCBUILDER.UI_NS, 'footer', v_table_footer_element_rd);

	-- add all the remaining columns to this table
	v_section_layout_element_rd := CREATE_TABLE(p_section_id, v_section_layout_element_rd,p_section_id, 1, 'Y', -1);
	-- add the table as a child of the header section
	JDR_DOCBUILDER.addChild (v_section_element_rd, jdr_docbuilder.UI_NS,'contents',v_section_layout_element_rd);

	JDR_DOCBUILDER.setTopLevelElement(mainDocReadOnly, v_section_element_rd);

	--------------------------------------
	-----READ--ONLY--REGION---END---------
	--------------------------------------

	rval := JDR_DOCBUILDER.save;

	x_result := fnd_api.g_ret_sts_success;

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'END');

EXCEPTION
    WHEN OTHERS THEN
	x_result := fnd_api.g_ret_sts_error;
	x_error_code := SQLCODE;
	x_error_message := SUBSTR(SQLERRM, 1, 100);
	PON_FORMS_UTIL_PVT.print_error_log(l_api_name, 'EXCEPTION - x_result=' || x_result || ' x_error_code=' || x_error_code || ' x_error_message=' || x_error_message || ' SQLERRM=' || SQLERRM);

end CREATE_REPEATING_SECTION;



/*=======================================================
 PROCEDURE:  CREATE_ABSTRACT_TABLE	PRIVATE
   PARAMETERS:
   COMMENT   : 	This procedure is invoked when a abstract
		is made active. Using this procedure, we will
		generate the table to be displayed on the external
		supplier page containing all the negotiations with
		abstracts.
========================================================*/
PROCEDURE CREATE_ABSTRACT_TABLE(p_form_id 	IN 	NUMBER,
  				x_result	OUT NOCOPY  VARCHAR2,
  				x_error_code    OUT NOCOPY  VARCHAR2,
  				x_error_message OUT NOCOPY  VARCHAR2
 ) IS

l_api_name	CONSTANT  VARCHAR2(30) := 'CREATE_ABSTRACT_TABLE';

CURSOR V_ABSTRACT_FIELDS_CURSOR IS

select 	pon_fields.field_code,
	pon_form_section_compiled.mapping_field_value_column,
	pon_fields.datatype,
	pon_fields.value_set_name,
	pon_fields.system_flag,
	pon_fields.system_field_lov_flag,
	pon_fields_tl.field_name,
	pon_fields_tl.description field_description,
	pon_forms_sections.form_id,
	pon_forms_sections.form_code,
	pon_forms_sections_tl.form_name,
	pon_forms_sections_tl.form_description,
	pon_form_section_compiled.display_on_main_page,
	pon_form_section_compiled.internal_sequence_number
from 	pon_fields,
	pon_fields_tl,
	pon_forms_sections,
	pon_forms_sections_tl,
	pon_form_section_compiled
where
	pon_forms_sections.FORM_CODE = 'ABSTRACT'
and	pon_forms_sections.STATUS   = 'ACTIVE'
and	pon_forms_sections.FORM_ID  = pon_form_section_compiled.FORM_ID
and	pon_forms_sections.FORM_ID  = pon_forms_sections_tl.FORM_ID
and	pon_form_section_compiled.TYPE 	= 'FORM_FIELD'
and	pon_form_section_compiled.FIELD_CODE is not null
and	pon_form_section_compiled.FIELD_CODE = pon_fields.FIELD_CODE
and	pon_fields.FIELD_CODE 		= pon_fields_tl.FIELD_CODE
and 	pon_fields_tl.LANGUAGE 		= g_base_language
and	pon_forms_sections_tl.LANGUAGE	= g_base_language
and	nvl(pon_form_section_compiled.display_on_main_page, 'N') = 'Y'
order by
	internal_sequence_number;

mainDoc				JDR_DOCBUILDER.DOCUMENT;
v_section_element 		JDR_DOCBUILDER.ELEMENT;
v_section_layout_element 	JDR_DOCBUILDER.ELEMENT;
v_section_field_element  	JDR_DOCBUILDER.ELEMENT;
v_table_footer_element		JDR_DOCBUILDER.ELEMENT;
v_action_parameters		JDR_DOCBUILDER.ELEMENT;
v_action_parameter		JDR_DOCBUILDER.ELEMENT;
v_section_case_element		JDR_DOCBUILDER.ELEMENT;
v_section_link_element		JDR_DOCBUILDER.ELEMENT;
v_section_img_element		JDR_DOCBUILDER.ELEMENT;

v_abstract_fields_row           V_ABSTRACT_FIELDS_CURSOR%ROWTYPE;
v_section_code			PON_FORMS_SECTIONS.FORM_CODE%TYPE;
v_curr_vo_name   		VARCHAR2(100);
rval 				INTEGER;

BEGIN

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'BEGIN-');

	IF (JDR_DOCBUILDER.DOCUMENTEXISTS(g_jrad_ext_page_path)=TRUE) THEN
		  JDR_DOCBUILDER.DELETEDOCUMENT (g_jrad_ext_page_path);
    	END IF;

	v_section_code 			:= 'ABSTRACT';
	v_curr_vo_name 			:= g_ext_abs_vo_name;

	mainDoc	  := NULL;

	mainDoc	  := JDR_DOCBUILDER.createDocument(g_jrad_ext_page_path,'en-US');

	v_section_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'flowLayout');
	JDR_DOCBUILDER.setAttribute (v_section_element, 'id', v_section_code);
	JDR_DOCBUILDER.setAttribute (v_section_element, 'amDefName', g_ext_app_module);
	JDR_DOCBUILDER.setAttribute (v_section_element, 'controllerClass', g_ext_controller);
	JDR_DOCBUILDER.setAttribute (v_section_element, 'headerDisabled', 'true');

	JDR_DOCBUILDER.setTopLevelElement(mainDoc, v_section_element);

	/*v_section_layout_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'tableLayout');
	JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'id', v_section_code || '_TAB_LAYOUT');
	JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'extends', g_jrad_ext_poplist);
	JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'headerDisabled', 'true');

	JDR_DOCBUILDER.addChild (v_section_element, jdr_docbuilder.UI_NS,'contents',v_section_layout_element);*/

	v_section_layout_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'table');
	JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'id', v_section_code||'_table');
	JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'width', '100%');
        JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'shortDesc', fnd_message.get_string ('PON', 'PON_EXT_ABSTRACT_TBL_SHORTDESC'));

	FOR v_abstract_fields_row in V_ABSTRACT_FIELDS_CURSOR LOOP --{

                v_section_field_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'messageStyledText');
	 	JDR_DOCBUILDER.setAttribute (v_section_field_element, 'id', v_abstract_fields_row.field_code);
 	 	JDR_DOCBUILDER.setAttribute (v_section_field_element, 'prompt', escapespecialchar(v_abstract_fields_row.field_name));
	 	JDR_DOCBUILDER.setAttribute (v_section_field_element, 'dataType', 'VARCHAR2');
	 	JDR_DOCBUILDER.setAttribute (v_section_field_element, 'viewAttr', v_abstract_fields_row.field_code || '_NAME');
               	JDR_DOCBUILDER.setAttribute (v_section_field_element, 'viewName', v_curr_vo_name);
               	JDR_DOCBUILDER.addChild (v_section_layout_element, jdr_docbuilder.UI_NS,
					'contents',v_section_field_element);

	END LOOP; --}


	-- after adding all the columns in the table, we need to add the following columns as well
	-- 'details' icon
	v_section_field_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'image');

	JDR_DOCBUILDER.setAttribute (v_section_field_element, 'id', 'detailImage');

	JDR_DOCBUILDER.setAttribute (v_section_field_element, 'source', 'eyeglasses_24x24_transparent.gif');
	JDR_DOCBUILDER.setAttribute (v_section_field_element, 'warnAboutChanges', 'false');
	JDR_DOCBUILDER.setAttribute (v_section_field_element, 'prompt', 'Details');

	v_action_parameters := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'fireAction');
	JDR_DOCBUILDER.setAttribute (v_action_parameters, 'event', 'DetailsIconClicked');

	-- add all the parameters we want to pass to the details page

	v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'FORM_ID');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value', p_form_id);
	JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);


	v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'OWNING_ENTITY_CODE');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value', 'PON_AUCTION_HEADERS_ALL');
	JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);


	v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'ENTITY_PK1');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value',
					'${oa.encrypt.' || v_curr_vo_name ||  '.AUCTION_HEADER_ID}');
	JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);

	v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'ABSTRACT_AUCTION_STATUS');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value',
					'${oa.encrypt.' || v_curr_vo_name ||  '.NEGOTIATION_STATUS}');
	JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);


	v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'JRAD_PAGE_MODE');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value', 'FORM_READ_ONLY');
	JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);

	v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'ABSTRACT_PDF_FLAG');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value',
						'${oa.encrypt.' || v_curr_vo_name ||  '.ABSTRACT_PDF_FLAG}');
	JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);

	v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'ORG_ID');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value',
						'${oa.encrypt.' || v_curr_vo_name ||  '.ORG_ID}');
	JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);

	v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'DOCTYPE_ID');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value',
						'${oa.encrypt.' || v_curr_vo_name ||  '.DOCTYPE_ID}');
	JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);

	v_action_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'key', 'FROM_PAGE');
	JDR_DOCBUILDER.setAttribute (v_action_parameter, 'value', 'PON_FORMS_JRAD_GENX');

	JDR_DOCBUILDER.addChild (v_action_parameters, JDR_DOCBUILDER.UI_NS, 'parameters', v_action_parameter);

	JDR_DOCBUILDER.addChild (v_section_field_element, JDR_DOCBUILDER.UI_NS, 'primaryClientAction', v_action_parameters);

        JDR_DOCBUILDER.addChild (v_section_layout_element, jdr_docbuilder.UI_NS, 'contents',v_section_field_element);

	JDR_DOCBUILDER.addChild (v_section_element, jdr_docbuilder.UI_NS, 'contents',v_section_layout_element);

	JDR_DOCBUILDER.setTopLevelElement(mainDoc, v_section_element);

	rval := JDR_DOCBUILDER.save;

	x_result := fnd_api.g_ret_sts_success;

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'END');

EXCEPTION
    WHEN OTHERS THEN
	x_result := fnd_api.g_ret_sts_error;
	x_error_code := SQLCODE;
	x_error_message := SUBSTR(SQLERRM, 1, 100);
	PON_FORMS_UTIL_PVT.print_error_log(l_api_name, 'EXCEPTION - x_result=' || x_result || ' x_error_code=' || x_error_code || ' x_error_message=' || x_error_message || ' SQLERRM=' || SQLERRM);

END CREATE_ABSTRACT_TABLE;

/*======================================================================
 PROCEDURE :  CREATE_FORM	PRIVATE
   PARAMETERS:
   COMMENT   :  This is the mother of all procedures to actually generate
		the JRAD for the corresponding form_id.
======================================================================*/

PROCEDURE CREATE_FORM(p_form_id 	IN NUMBER,
  		      x_result		OUT NOCOPY  VARCHAR2,
  		      x_error_code    	OUT NOCOPY  VARCHAR2,
  		      x_error_message 	OUT NOCOPY  VARCHAR2) IS

l_api_name	CONSTANT VARCHAR2(30) := 'CREATE_FORM';

CURSOR V_FORM_FIELDS_CURSOR(p_form_id NUMBER) is

SELECT	pon_form_section_compiled.FORM_ID,
	pon_form_section_compiled.TYPE,
	pon_form_section_compiled.FIELD_CODE,
	pon_form_section_compiled.MAPPING_FIELD_VALUE_COLUMN,
	pon_form_section_compiled.REQUIRED,
	NVL (pon_form_section_compiled.LEVEL1_SECTION_ID, -1) SECTION_ID,
	pon_forms_sections.FORM_CODE SECTION_CODE,
	pon_fields.DATATYPE,
	pon_fields.SYSTEM_FLAG,
	pon_fields.VALUE_SET_NAME,
	pon_fields_tl.FIELD_NAME,
	pon_fields_tl.DESCRIPTION FIELD_DESCRIPTION,
	pon_form_section_compiled.INTERNAL_SEQUENCE_NUMBER,
	NVL(pon_form_section_compiled.LEVEL2_SECTION_ID, -1) LEVEL2_SECTION_ID,
	NVL(pon_form_section_compiled.REPEATING_SECTION_ID, -1) REPEATING_SECTION_ID
FROM	PON_FORM_SECTION_COMPILED,
	PON_FIELDS,
	PON_FIELDS_TL,
	PON_FORMS_SECTIONS
WHERE   pon_form_section_compiled.FIELD_CODE 		= pon_fields.FIELD_CODE(+)
AND     pon_form_section_compiled.FIELD_CODE 		= pon_fields_tl.FIELD_CODE(+)
AND	pon_forms_sections.FORM_ID	     		= pon_form_section_compiled.FORM_ID
AND     pon_form_section_compiled.FORM_ID    		= P_FORM_ID
AND	NVL(pon_form_section_compiled.ENABLED, 'Y') 	= 'Y'
AND	pon_fields_tl.LANGUAGE(+)	     		= g_base_language
ORDER BY
	INTERNAL_SEQUENCE_NUMBER;


TYPE SECTION_LAYOUT_ELEMENTS_TABLE IS TABLE OF JDR_DOCBUILDER.ELEMENT INDEX BY BINARY_INTEGER;

TYPE SECTION_LAYOUT_TABLE IS TABLE OF JDR_DOCBUILDER.ELEMENT INDEX BY VARCHAR2(120);

v_section_layout_array 		SECTION_LAYOUT_TABLE;
v_section_layout_array_rd 	SECTION_LAYOUT_TABLE;
v_parent_layout_array_index	VARCHAR2(120);
v_current_layout_array_index	VARCHAR2(120);

v_form_fields_row 		V_FORM_FIELDS_CURSOR%ROWTYPE;

v_section_layout_element_array 	SECTION_LAYOUT_ELEMENTS_TABLE;

v_current_layout_element_index 	BINARY_INTEGER;

v_section_element_array_rd 	SECTION_LAYOUT_ELEMENTS_TABLE;

v_current_element_index_rd 	BINARY_INTEGER;


v_section_element 		JDR_DOCBUILDER.ELEMENT;
v_section_layout_element 	JDR_DOCBUILDER.ELEMENT;
v_message_layout_element	JDR_DOCBUILDER.ELEMENT;
v_section_field_element  	JDR_DOCBUILDER.ELEMENT;
v_section_tip_element		JDR_DOCBUILDER.ELEMENT;
v_section_tip_element_rd	JDR_DOCBUILDER.ELEMENT;
v_delete_field_element 		JDR_DOCBUILDER.ELEMENT;
v_delete_parameter 		JDR_DOCBUILDER.ELEMENT;
v_delete_parameters 		JDR_DOCBUILDER.ELEMENT;
v_temp_element 			JDR_DOCBUILDER.ELEMENT;
v_column_header_element 	JDR_DOCBUILDER.ELEMENT;
v_add_table_row_element 	JDR_DOCBUILDER.ELEMENT;
v_table_footer_element 		JDR_DOCBUILDER.ELEMENT;


v_section_element_rd		JDR_DOCBUILDER.ELEMENT;
v_section_layout_element_rd 	JDR_DOCBUILDER.ELEMENT;
v_section_field_element_rd  	JDR_DOCBUILDER.ELEMENT;


v_section_title 		PON_FORMS_SECTIONS_TL.FORM_NAME%TYPE;
v_parent_section_code 		PON_FORMS_SECTIONS.FORM_CODE%TYPE;
v_section_code 			PON_FORMS_SECTIONS.FORM_CODE%TYPE;
v_section_desc			PON_FORMS_SECTIONS_TL.FORM_DESCRIPTION%TYPE;
v_field_jrad_id			VARCHAR2(200);
v_jrad_element_id		VARCHAR2(200);
v_section_id			PON_FORMS_SECTIONS.FORM_ID%TYPE;

v_LEVEL1_SECTION_ID		PON_FORMS_SECTIONS.FORM_ID%TYPE;
v_parent_section_id		PON_FORMS_SECTIONS.FORM_ID%TYPE;
v_current_section_id		PON_FORMS_SECTIONS.FORM_ID%TYPE;

v_formfieldvaluesvo_list_count 	INTEGER;
v_form_mcl_count		INTEGER;
v_section_mcl_count		INTEGER;

v_formfieldvaluesvo_name 	VARCHAR2(100);
v_curr_formfieldvaluesvo_name 	VARCHAR2(100);
v_top_formfieldvaluesvo_name	VARCHAR2(100);
v_display_type 			VARCHAR2(1);
v_validation_type 		VARCHAR2(1);
v_prev_record_type 		PON_FORM_SECTION_COMPILED.TYPE%TYPE;

rval 				INTEGER;
dataEntryRegion 		JDR_DOCBUILDER.DOCUMENT := NULL;
readOnlyRegion			JDR_DOCBUILDER.DOCUMENT := NULL;

v_data_entry_rgn_name		VARCHAR2(250);
v_read_only_rgn_name		VARCHAR2(250);
v_vset_element_created		VARCHAR2(1);

BEGIN
	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'BEGIN-');

	-- we dont need to pass the fullPathName to this procedure
	-- we can generate the region name here

	v_data_entry_rgn_name := PON_FORMS_UTIL_PVT.getDataEntryRegionName(p_form_id);
	v_read_only_rgn_name  := PON_FORMS_UTIL_PVT.getReadOnlyRegionName(p_form_id);

	IF (JDR_DOCBUILDER.DOCUMENTEXISTS(v_data_entry_rgn_name)=TRUE) THEN --{
		JDR_DOCBUILDER.DELETEDOCUMENT(v_data_entry_rgn_name);
	END IF; --}

	IF (JDR_DOCBUILDER.DOCUMENTEXISTS(v_read_only_rgn_name)=TRUE) THEN --{
		JDR_DOCBUILDER.DELETEDOCUMENT(v_read_only_rgn_name);
	END IF; --}

	-- initialize the dataEntryRegion
	dataEntryRegion := JDR_DOCBUILDER.createDocument(v_data_entry_rgn_name,'en-US');
	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'Step 1 - create data-entry region' || v_data_entry_rgn_name);

	readOnlyRegion  := JDR_DOCBUILDER.createDocument(v_read_only_rgn_name,'en-US');

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'Step 2 - create read-entry region' || v_read_only_rgn_name);

	v_current_layout_element_index := 0;
	v_parent_section_code 	:= NULL;
	v_section_code 		:= NULL;

	-- initialize a few local variables
	v_date_list_count := 1;
	v_table_vo_count := 1;
   	v_formfieldvaluesvo_list_count 	:= 1;
	v_form_mcl_count := 0;
	v_section_mcl_count := 0;
	v_parent_section_id  := -9999;
	v_LEVEL1_SECTION_ID     := -9999;
	v_current_section_id := -9999;
	v_prev_record_type   := 'DUMMY';
	v_vset_element_created := 'N';

    	v_formfieldvaluesvo_name 	:= 'FormFieldValuesVO';
	v_top_formfieldvaluesvo_name	:= 'FormFieldValuesVO1';
    	v_curr_formfieldvaluesvo_name 	:= 'FormFieldValuesVO1';

	FOR v_form_fields_row in V_FORM_FIELDS_CURSOR (p_form_id) LOOP --{

		v_jrad_element_id := getJradId (v_form_fields_row.type,
						v_form_fields_row.form_id,
						v_form_fields_row.section_id,
						v_form_fields_row.LEVEL2_SECTION_ID,
						v_form_fields_row.repeating_section_id,
						v_form_fields_row.field_code);

		IF(v_form_fields_row.type='FORM') THEN --{

			v_parent_section_id  := -1;
			v_current_section_id := v_form_fields_row.form_id;
			v_LEVEL1_SECTION_ID     := -1;

			--Create a new header section
			v_section_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');
			--Create a new header section for read only region
			v_section_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');

			--get the section title

			SELECT
				forms_tl.form_name, forms.form_code
			INTO
				v_section_title, v_section_code
			FROM
				pon_forms_sections forms,
				pon_forms_sections_tl forms_tl
			WHERE
				forms.form_id		= forms_tl.form_id AND
				forms.form_id		= v_current_section_id AND
				forms_tl.LANGUAGE	= g_base_language;

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 1+ : create header region for section ' || v_section_code);

			JDR_DOCBUILDER.setAttribute (v_section_element, 'id', v_jrad_element_id);

			JDR_DOCBUILDER.setAttribute (v_section_element, 'text', escapespecialchar(v_section_title));

			JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'id', v_jrad_element_id);

			JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'text', escapespecialchar(v_section_title));

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 1+ - top level element is ' || v_current_section_id);

			JDR_DOCBUILDER.setTopLevelElement(dataEntryRegion, v_section_element);

			JDR_DOCBUILDER.setTopLevelElement(readOnlyRegion, v_section_element_rd);

			--add the layout to the array
			---
			v_current_layout_array_index := getCurrentElementIndex(v_form_fields_row.type, p_form_id, 0, 0, 0, null);
			v_section_layout_array(v_current_layout_array_index) := v_section_element;

			----------------------------------------------------------------------------------------
			-----READ-ONLY-REGION-START-------------------------------------------------------------
			----------------------------------------------------------------------------------------
			v_section_layout_array_rd(v_current_layout_array_index) := v_section_element_rd;
			----------------------------------------------------------------------------------------
			-----READ-ONLY-REGION-END---------------------------------------------------------------
			----------------------------------------------------------------------------------------


		--}

		ELSIF (v_form_fields_row.type='FORM_FIELD') THEN
		--{

			IF(v_prev_record_type <> 'FORM_FIELD') THEN --{

				v_parent_section_id  := v_form_fields_row.form_id;
				v_current_section_id := v_form_fields_row.form_id;
				v_LEVEL1_SECTION_ID     := -1;

				--create a section layout(MCL) and add it to the new section
				-- create a MCL
				v_form_mcl_count := v_form_mcl_count + 1;
				v_section_layout_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS,
											  'messageComponentLayout');

				v_section_layout_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS,
											  'messageComponentLayout');

				v_section_mcl_count := v_section_mcl_count + 1;

				v_curr_formfieldvaluesvo_name := v_top_formfieldvaluesvo_name;

				JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'id',
							     v_section_code||'_MCL'|| v_section_mcl_count);

				JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'columns', '2');
				JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'rows', '1');

				v_parent_layout_array_index := getParentElementIndex(v_form_fields_row.type, p_form_id, 0, 0, 0, null);

				JDR_DOCBUILDER.addChild (v_section_layout_array(v_parent_layout_array_index),jdr_docbuilder.UI_NS,
							'contents',v_section_layout_element);

				--------------------------------------------
				-----READ-ONLY-REGION-START-----------------
				--------------------------------------------

				JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'id',
							     v_section_code||'_MCL'|| v_section_mcl_count);

				JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'columns', '2');
				JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'rows', '1');

			  	-- add the MCL region as a child of the top-level header region

				JDR_DOCBUILDER.addChild (v_section_layout_array_rd(v_parent_layout_array_index),jdr_docbuilder.UI_NS,
 							'contents', v_section_layout_element_rd);

				--------------------------------------------
				-----READ-ONLY-REGION-END-------------------
				--------------------------------------------


			END IF; --}

		--}

		ELSIF (v_form_fields_row.type='NORMAL_SECTION') THEN
		--{

			-- this is the 1st occurence of the section_field

			v_parent_section_id  := v_form_fields_row.form_id;
			v_current_section_id := v_form_fields_row.section_id;
			v_LEVEL1_SECTION_ID     := v_current_section_id;

			-- add the mcl as a child of the header region

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 2+ : v_parent_section_id = '
							|| v_parent_section_id  || ' v_current_section_id = '
							|| v_current_section_id || ' v_LEVEL1_SECTION_ID = ' || v_LEVEL1_SECTION_ID);

			--Create a new header section
			v_section_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');
			--Create a new header section for the readonly region as well
			v_section_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');

			--get the section title

			SELECT
				forms_tl.form_name, forms.form_code, forms_tl.tip_text
			INTO
				v_section_title, v_section_code, v_section_desc
			FROM
				pon_forms_sections forms,
				pon_forms_sections_tl forms_tl
			WHERE
				forms.form_id		= forms_tl.form_id AND
				forms.form_id		= v_current_section_id AND
				forms_tl.LANGUAGE	= g_base_language;

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 2+ - create header region for section ' || v_section_code);

			JDR_DOCBUILDER.setAttribute (v_section_element, 'id', v_jrad_element_id);
			JDR_DOCBUILDER.setAttribute (v_section_element, 'text', escapespecialchar(v_section_title));
			g_total_element_count := g_total_element_count + 1;

			JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'id', v_jrad_element_id);
			JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'text', escapespecialchar(v_section_title));

			-- add the header region of the section as a child of the toplevel header region of the form
			v_current_layout_array_index := getCurrentElementIndex (v_form_fields_row.type,p_form_id,v_current_section_id,
										0,0,null);

			v_parent_layout_array_index  := getParentElementIndex  (v_form_fields_row.type,p_form_id,v_current_section_id,
										0,0,null);
			--add the layout to the array
			JDR_DOCBUILDER.addChild(v_section_layout_array(v_parent_layout_array_index),
						jdr_docbuilder.UI_NS,'contents',v_section_element);

			v_section_layout_array(v_current_layout_array_index) := v_section_element;

			-- add a small tip element if description has been entered
			if(nvl(v_section_desc, 'E') <> 'E') then
				v_section_tip_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS,
										       'tip');

				JDR_DOCBUILDER.setAttribute (v_section_tip_element, 'id', v_jrad_element_id || '_TIP');
				JDR_DOCBUILDER.setAttribute (v_section_tip_element, 'text', escapespecialchar(v_section_desc));
				JDR_DOCBUILDER.addChild(v_section_element,
							jdr_docbuilder.UI_NS,'contents',v_section_tip_element);

			else
				v_section_desc := to_char(null);
			end if;

			------------------------------------------
			---READONLY--REGION--START----------------
			------------------------------------------

			JDR_DOCBUILDER.addChild(v_section_layout_array_rd(v_parent_layout_array_index),
						jdr_docbuilder.UI_NS,'contents',v_section_element_rd);

			v_section_layout_array_rd(v_current_layout_array_index) := v_section_element_rd;

			if(nvl(v_section_desc, 'E') <> 'E') then
				v_section_tip_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'tip');
				JDR_DOCBUILDER.setAttribute (v_section_tip_element_rd, 'id', v_jrad_element_id || '_TIP');
				JDR_DOCBUILDER.setAttribute (v_section_tip_element_rd, 'text', escapespecialchar(v_section_desc));
				JDR_DOCBUILDER.addChild(v_section_element_rd,
							jdr_docbuilder.UI_NS,'contents',v_section_tip_element_rd);
			else
				v_section_desc := to_char(null);
			end if;

			--------------------------------------------
			-----READ-ONLY-REGION-END-------------------
			--------------------------------------------
		--}

		ELSIF (v_form_fields_row.type='SECTION_FIELD') THEN
		--{
			-- if this is the 1st occurence of a section field, then we will need
			-- to create a MCL OR
			-- if we haven't previously created an MCL for this section
			-- normal adding of fields to an MCL for a section will be handled below,
			-- here, we will determine whether or not this field appears in a section
			-- apart from the remaining group of fields in the section

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case ' || v_form_fields_row.type || ' :-: ' || v_prev_record_type);

			IF(v_prev_record_type <> 'SECTION_FIELD') THEN
			--{
				v_parent_section_id := v_form_fields_row.form_id;
				v_current_section_id := v_form_fields_row.section_id;
				v_LEVEL1_SECTION_ID := v_current_section_id;

				PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case '|| v_form_fields_row.type ||':+:'
										      || v_current_section_id);

				-- we have already created a oa:header region for this section
				-- but just that this field has been added to this section out-of-order
				-- so create a MCL
				v_section_layout_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS,
											  'messageComponentLayout');


				v_section_layout_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS,
											  'messageComponentLayout');


				v_section_mcl_count := v_section_mcl_count + 1;

				v_curr_formfieldvaluesvo_name := v_top_formfieldvaluesvo_name;


                                SELECT
                                        forms_tl.form_name, forms.form_code, forms_tl.tip_text
                                INTO
                                        v_section_title, v_section_code, v_section_desc
                                FROM
                                        pon_forms_sections forms,
                                        pon_forms_sections_tl forms_tl
                                WHERE
                                        forms.form_id           = forms_tl.form_id AND
                                        forms.form_id           = v_current_section_id AND
                                        forms_tl.LANGUAGE       = g_base_language;


				JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'id',
							     v_section_code||'_MCL'|| v_section_mcl_count);

				JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'columns', '2');
				JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'rows', '1');

				-- add the MCL as a child of the header region of the section
				-- we have already created that oa:header region before in type='normal-section'
				------------------------------------------------------------------------------------
				v_parent_layout_array_index :=getParentElementIndex(v_form_fields_row.type,p_form_id,v_current_section_id,
										    0,0,null);

				JDR_DOCBUILDER.addChild(v_section_layout_array(v_parent_layout_array_index),
							jdr_docbuilder.UI_NS,'contents',v_section_layout_element);
				------------------------------------------------------------------------------------

				-------------------------------------------
				-- READONLY--REGION--START-----------------
				-------------------------------------------
				JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'id',
							     v_section_code||'_MCL'|| v_section_mcl_count);

				JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'columns', '2');
				JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'rows', '1');

				JDR_DOCBUILDER.addChild(v_section_layout_array_rd(v_parent_layout_array_index),
							jdr_docbuilder.UI_NS,'contents',v_section_layout_element_rd);

				--------------------------------------------
				-- READONLY--REGION--END--------------------
				--------------------------------------------

			END IF;
			--}
		--}

		ELSIF (v_form_fields_row.type='INNER_NORMAL_SECTION') THEN
		--{

			v_parent_section_id  := v_form_fields_row.section_id;
			v_current_section_id := v_form_fields_row.LEVEL2_SECTION_ID;
			v_LEVEL1_SECTION_ID     := v_parent_section_id;

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 3+ : v_parent_section_id = '
							|| v_parent_section_id  || ' v_current_section_id = '
							|| v_current_section_id || ' v_LEVEL1_SECTION_ID = ' || v_LEVEL1_SECTION_ID);

			--Create a new header section
			v_section_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');


			--Create a new header section
			v_section_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');

			--get the section title

			SELECT
				forms_tl.form_name, forms.form_code, forms_tl.tip_text
			INTO
				v_section_title, v_section_code, v_section_desc
			FROM
				pon_forms_sections forms,
				pon_forms_sections_tl forms_tl
			WHERE
					forms.form_id		= forms_tl.form_id AND
					forms.form_id		= v_current_section_id AND
					forms_tl.LANGUAGE	= g_base_language;

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 3+ : create header region for section ' || v_section_code);

			JDR_DOCBUILDER.setAttribute (v_section_element, 'id', v_jrad_element_id);
			JDR_DOCBUILDER.setAttribute (v_section_element, 'text', escapespecialchar(v_section_title));

			JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'id', v_jrad_element_id);
			JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'text', escapespecialchar(v_section_title));

			------------------------------------------------------------------------------------
			v_current_layout_array_index := getCurrentElementIndex(v_form_fields_row.type,p_form_id,v_parent_section_id,
									       v_current_section_id,0,null);

			v_parent_layout_array_index  := getParentElementIndex(v_form_fields_row.type,p_form_id,v_parent_section_id,
									      v_current_section_id,0,null);

			JDR_DOCBUILDER.addChild(v_section_layout_array(v_parent_layout_array_index),
						jdr_docbuilder.UI_NS,'contents',v_section_element);

			v_section_layout_array(v_current_layout_array_index) := v_section_element;

			------------------------------------------------------------------------------------

			-- add a small tip element if description has been entered
			if(nvl(v_section_desc, 'E') <> 'E') then
				v_section_tip_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'tip');
				JDR_DOCBUILDER.setAttribute (v_section_tip_element, 'id', v_jrad_element_id || '_TIP');
				JDR_DOCBUILDER.setAttribute (v_section_tip_element, 'text', escapespecialchar(v_section_desc));
				JDR_DOCBUILDER.addChild(v_section_element,
							jdr_docbuilder.UI_NS,'contents',v_section_tip_element);

			else
				v_section_desc := to_char(null);
			end if;
			---------------------------------------
			--- READ-ONLY-REGION-START-------------
			---------------------------------------

			JDR_DOCBUILDER.addChild(v_section_layout_array_rd(v_parent_layout_array_index),
						jdr_docbuilder.UI_NS,'contents',v_section_element_rd);

			v_section_layout_array_rd(v_current_layout_array_index) := v_section_element_rd;

			if(nvl(v_section_desc, 'E') <> 'E') then
				v_section_tip_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS,'tip');
				JDR_DOCBUILDER.setAttribute (v_section_tip_element_rd, 'id', v_jrad_element_id || '_TIP');
				JDR_DOCBUILDER.setAttribute (v_section_tip_element_rd, 'text', escapespecialchar(v_section_desc));
				JDR_DOCBUILDER.addChild(v_section_element_rd,
							jdr_docbuilder.UI_NS,'contents',v_section_tip_element_rd);
			else
				v_section_desc := to_char(null);
			end if;
			---------------------------------------
			--- READ-ONLY-REGION-END-------------
			---------------------------------------
		--}

		ELSIF (v_form_fields_row.type='INNER_SECTION_FIELD') THEN
		--{
			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case ' || v_form_fields_row.type || ' :-: ' || v_prev_record_type);

			IF(v_prev_record_type <> 'INNER_SECTION_FIELD') THEN
			--{

				v_parent_section_id  := v_form_fields_row.section_id;
				v_current_section_id := v_form_fields_row.LEVEL2_SECTION_ID;
				v_LEVEL1_SECTION_ID     := v_parent_section_id;

				-- we have encountered a field inside a inner section, which was
				-- added out-of-order from the original set of fields directly
				-- inside the

				PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case'||v_form_fields_row.type||':+:'||v_current_section_id);

				--create a section layout(MCL) and add it to the new section
				v_section_layout_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS,
											  'messageComponentLayout');

				--create a section layout(MCL) and add it to the new section
				v_section_layout_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS,
											  'messageComponentLayout');
				-- increment the total number of MCLs we have created so far
				v_section_mcl_count := v_section_mcl_count + 1;

				-- since we are creating a MCL for the main page normal section, the top-level
				-- view object should be used
				v_curr_formfieldvaluesvo_name := v_top_formfieldvaluesvo_name;

                                SELECT
                                        forms_tl.form_name, forms.form_code, forms_tl.tip_text
                                INTO
                                        v_section_title, v_section_code, v_section_desc
                                FROM
                                        pon_forms_sections forms,
                                        pon_forms_sections_tl forms_tl
                                WHERE
                                        forms.form_id           = forms_tl.form_id AND
                                        forms.form_id           = v_current_section_id AND
                                        forms_tl.LANGUAGE       = g_base_language;

				JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'id',
							     v_section_code||'_MCL' || v_section_mcl_count);

				JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'columns', '2');
				JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'rows', '1');

				------------------------------------------------------------------------------------
				v_parent_layout_array_index :=getParentElementIndex(v_form_fields_row.type,p_form_id,v_parent_section_id,
										    v_current_section_id,0,null);

				JDR_DOCBUILDER.addChild(v_section_layout_array(v_parent_layout_array_index),
							jdr_docbuilder.UI_NS,'contents',v_section_layout_element);
				------------------------------------------------------------------------------------

				-----------------------------------
				-----READ-ONLY-REGION-START--------
				-----------------------------------

				JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'id',
							     v_section_code||'_MCL' || v_section_mcl_count);

				JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'columns', '2');
				JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'rows', '1');
				JDR_DOCBUILDER.addChild(v_section_layout_array_rd(v_parent_layout_array_index),
							jdr_docbuilder.UI_NS,'contents',v_section_layout_element_rd);

				-----------------------------------
				-----READ-ONLY-REGION-END----------
				-----------------------------------

			END IF;
			--}

		--}

		ELSIF (v_form_fields_row.type='REPEAT_SECTION') THEN
		--{

			-- this is a repeating section inside the form

			v_parent_section_id  := v_form_fields_row.form_id;
			v_current_section_id := v_form_fields_row.repeating_section_id;
			v_LEVEL1_SECTION_ID     := v_current_section_id;

			-- create a header section

			v_section_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');

			v_section_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 4+ : v_parent_section_id = '
							|| v_parent_section_id  || ' v_current_section_id = '
							|| v_current_section_id || ' v_LEVEL1_SECTION_ID = '
							|| v_LEVEL1_SECTION_ID);

			-- get the section title
			SELECT
				forms_tl.form_name, forms.form_code
			INTO
				v_section_title, v_section_code
			FROM
				pon_forms_sections forms,
				pon_forms_sections_tl forms_tl
			WHERE
				forms.form_id		= forms_tl.form_id AND
				forms.form_id		= v_current_section_id AND
				forms_tl.LANGUAGE	= g_base_language;

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 4+ : create header region for section - '
								|| v_section_code );

			JDR_DOCBUILDER.setAttribute (v_section_element, 'id', v_jrad_element_id);
			JDR_DOCBUILDER.setAttribute (v_section_element, 'text', escapespecialchar(v_section_title));

			JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'id', v_jrad_element_id);
			JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'text', escapespecialchar(v_section_title));

			-- set all table-level JRAD attributes
			v_section_layout_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'advancedTable');
			v_section_layout_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'advancedTable');
			-- increment the VO count by one
			v_formfieldvaluesvo_list_count := v_formfieldvaluesvo_list_count + 1;
			v_curr_formfieldvaluesvo_name := v_formfieldvaluesvo_name || v_formfieldvaluesvo_list_count;

			JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'id', v_jrad_element_id ||'_table');
			JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'viewName', v_curr_formfieldvaluesvo_name);
			JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'width', '100%');

			JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'id', v_jrad_element_id ||'_table');
			JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'viewName',
						     v_curr_formfieldvaluesvo_name);

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'Setting viewName for ' || v_section_code
							||'_table' || ' ' || v_curr_formfieldvaluesvo_name);

			JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'width', '100%');

			-- create a table footer, and this footer as a child of the table region
			v_table_footer_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'tableFooter');
			JDR_DOCBUILDER.setAttribute (v_table_footer_element, 'id', v_jrad_element_id ||'_TABFTR');
			JDR_DOCBUILDER.addChild (v_section_layout_element, JDR_DOCBUILDER.UI_NS, 'footer',
						 v_table_footer_element);

			v_add_table_row_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'addTableRow');
			JDR_DOCBUILDER.setAttribute (v_add_table_row_element, 'id', v_jrad_element_id ||'_ADDBTN');
			JDR_DOCBUILDER.setAttribute (v_add_table_row_element, 'autoInsertion', 'false');
			JDR_DOCBUILDER.addChild (v_table_footer_element, JDR_DOCBUILDER.UI_NS, 'contents',
						 v_add_table_row_element);

			-- add all the rows in the table
			-- create a repeating section directly inside a form

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'Invoke CREATE_TABLE with '
							|| v_current_section_id || ' ' || p_form_id || ' '
							|| v_formfieldvaluesvo_list_count);

			v_section_layout_element := CREATE_TABLE(v_current_section_id, v_section_layout_element,
								 p_form_id, v_formfieldvaluesvo_list_count, 'N',
								 v_form_fields_row.internal_sequence_number);

			v_section_layout_element_rd := CREATE_TABLE(v_current_section_id,
								    v_section_layout_element_rd,
								    p_form_id,
								    v_formfieldvaluesvo_list_count,
							            'Y', v_form_fields_row.internal_sequence_number);


			/** Adding the delete column **/
			v_temp_element := JDR_DOCBUILDER.CREATEELEMENT (JDR_DOCBUILDER.OA_NS, 'column');
			JDR_DOCBUILDER.setAttribute (v_temp_element, 'id', v_jrad_element_id || '_COLDEL');
			JDR_DOCBUILDER.setAttribute (v_temp_element, 'columnDataFormat', 'iconButtonFormat');
			JDR_DOCBUILDER.addChild (v_section_layout_element, JDR_DOCBUILDER.UI_NS,
					 	 'contents', v_temp_element);

			v_column_header_element := JDR_DOCBUILDER.CREATEELEMENT (JDR_DOCBUILDER.OA_NS, 'sortableHeader');

			JDR_DOCBUILDER.setAttribute (v_column_header_element, 'id', v_jrad_element_id || '_SCLHDR');
			JDR_DOCBUILDER.setAttribute (v_column_header_element, 'prompt', 'Delete');
			JDR_DOCBUILDER.addChild (v_temp_element, JDR_DOCBUILDER.UI_NS, 'columnHeader',
						 v_column_header_element);

			v_delete_field_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS,'image');
			JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'id', v_jrad_element_id ||   '_DELIMG');
			JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'source', 'deleteicon_enabled.gif');
			JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'warnAboutChanges', 'false');
			JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'serverUnvalidated', 'true');
			JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'unvalidated', 'true');
			JDR_DOCBUILDER.addChild (v_temp_element, JDR_DOCBUILDER.UI_NS, 'contents',
						 v_delete_field_element);

			v_delete_parameters := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'fireAction');
			JDR_DOCBUILDER.setAttribute (v_delete_parameters, 'event', 'Delete');
			JDR_DOCBUILDER.setAttribute (v_delete_parameters, 'unvalidated', 'true');
			v_delete_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
			JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'key', 'Id');

			JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'value',
					'${oa.encrypt.' || v_curr_formfieldvaluesvo_name ||  '.FormFieldValueId}');

			JDR_DOCBUILDER.addChild (v_delete_parameters, JDR_DOCBUILDER.UI_NS,
							'parameters', v_delete_parameter);

			v_delete_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');

			JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'key', 'ViewName');

			JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'value', v_curr_formfieldvaluesvo_name);
			JDR_DOCBUILDER.addChild (v_delete_parameters, JDR_DOCBUILDER.UI_NS,
							'parameters', v_delete_parameter);

			JDR_DOCBUILDER.addChild (v_delete_field_element, JDR_DOCBUILDER.UI_NS,
							'primaryClientAction', v_delete_parameters);

				/** Done: Adding delete colmn */

			-- add the table into the header region
			JDR_DOCBUILDER.addChild (v_section_element, jdr_docbuilder.UI_NS,'contents',
						v_section_layout_element);

			-- add the header region to its parent, since this is type='repeating_section'
			-- we can rest assured that the parent of this section is the top-level form

			---------------------------------------------------------------------------------------------------------------
			v_current_layout_array_index := getCurrentElementIndex(v_form_fields_row.type,p_form_id,0,0,
									       v_current_section_id,null);

			v_parent_layout_array_index  := getParentElementIndex(v_form_fields_row.type,p_form_id,0,0,
									      v_current_section_id,null);

			JDR_DOCBUILDER.addChild(v_section_layout_array(v_parent_layout_array_index),
						jdr_docbuilder.UI_NS,'contents',v_section_element);

			v_section_layout_array(v_current_layout_array_index) := v_section_element;
			---------------------------------------------------------------------------------------------------------------

			-------------------------------------
			-----READ-ONLY-REGION-START----------
			-------------------------------------
			JDR_DOCBUILDER.addChild (v_section_element_rd, jdr_docbuilder.UI_NS,'contents',
						v_section_layout_element_rd);


			JDR_DOCBUILDER.addChild(v_section_layout_array_rd(v_parent_layout_array_index),
						jdr_docbuilder.UI_NS,'contents',v_section_element_rd);

			v_section_layout_array_rd(v_current_layout_array_index) := v_section_element_rd;

			-------------------------------------
			-----READ-ONLY-REGION-END------------
			-------------------------------------
		--}

		ELSIF (v_form_fields_row.type='INNER_REPEAT_SECTION') THEN
		--{


			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 5- : v_parent_section_id = '
							|| v_parent_section_id  || ' v_current_section_id = '
							|| v_current_section_id || ' v_LEVEL1_SECTION_ID = '
							|| v_LEVEL1_SECTION_ID);

				-- this is a repeating section inside a normal section

				v_parent_section_id  := v_form_fields_row.section_id;
				v_current_section_id := v_form_fields_row.repeating_section_id;
				v_LEVEL1_SECTION_ID  := v_parent_section_id;

				-- create a header region
				PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 5+ : v_parent_section_id = '
								|| v_parent_section_id || ' v_current_section_id = '
								|| v_current_section_id || ' v_LEVEL1_SECTION_ID = '
								|| v_LEVEL1_SECTION_ID);

				-- create a table region

				-- create a header section
				v_section_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');

				-- create a header section
				v_section_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');

				-- get the section title

				SELECT
					forms_tl.form_name, forms.form_code
				INTO
					v_section_title, v_section_code
				FROM
					pon_forms_sections forms,
					pon_forms_sections_tl forms_tl
				WHERE
					forms.form_id		= forms_tl.form_id AND
					forms.form_id		= v_current_section_id AND
					forms_tl.LANGUAGE	= g_base_language;

				PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 5+ : create header region for section - '
								|| v_section_code );

				JDR_DOCBUILDER.setAttribute (v_section_element, 'id', v_jrad_element_id);
				JDR_DOCBUILDER.setAttribute (v_section_element, 'text', escapespecialchar(v_section_title));

				JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'id', v_jrad_element_id);
				JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'text', escapespecialchar(v_section_title));

				-- set all table-level JRAD attributes
				v_section_layout_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'advancedTable');

				-- set all table-level JRAD attributes
				v_section_layout_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'advancedTable');

				-- increment the VO count by one
				v_formfieldvaluesvo_list_count := v_formfieldvaluesvo_list_count + 1;
				v_curr_formfieldvaluesvo_name := v_formfieldvaluesvo_name || v_formfieldvaluesvo_list_count;

				JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'id', v_jrad_element_id ||'_table');
				JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'viewName', v_curr_formfieldvaluesvo_name);
				JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'width', '100%');

				JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'id', v_jrad_element_id ||'_table');
				JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'viewName',
						             v_curr_formfieldvaluesvo_name);

				PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'Setting viewName for ' || v_section_code
								   ||'_table' || ' as ' ||  v_curr_formfieldvaluesvo_name);


				JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'width', '100%');


				-- create a table footer, and this footer as a child of the table region
				v_table_footer_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'tableFooter');
				JDR_DOCBUILDER.setAttribute (v_table_footer_element, 'id', v_jrad_element_id ||'_TABFTR');

				JDR_DOCBUILDER.addChild (v_section_layout_element, JDR_DOCBUILDER.UI_NS, 'footer',
							 v_table_footer_element);

				v_add_table_row_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'addTableRow');
				JDR_DOCBUILDER.setAttribute (v_add_table_row_element, 'id', v_jrad_element_id || '_ADDBTN');
				JDR_DOCBUILDER.setAttribute (v_add_table_row_element, 'autoInsertion', 'false');
				JDR_DOCBUILDER.addChild (v_table_footer_element, JDR_DOCBUILDER.UI_NS, 'contents',
							 v_add_table_row_element);

				-- add all the rows in the table
				-- create a repeating section directly inside a form
				-- originally passed 'v_section_code' as the 1st param
				v_section_layout_element := CREATE_TABLE(v_current_section_id,
									 v_section_layout_element,
									 p_form_id,
									 v_formfieldvaluesvo_list_count,
									 'N', v_form_fields_row.internal_sequence_number);


				v_section_layout_element_rd := CREATE_TABLE(v_current_section_id,
									    v_section_layout_element_rd,
									    p_form_id,
								       	    v_formfieldvaluesvo_list_count,
									    'Y', v_form_fields_row.internal_sequence_number);


				/** Adding the delete column **/
				v_temp_element := JDR_DOCBUILDER.CREATEELEMENT (JDR_DOCBUILDER.OA_NS, 'column');
				JDR_DOCBUILDER.setAttribute (v_temp_element, 'id', v_jrad_element_id || '_COLDEL');
				JDR_DOCBUILDER.setAttribute (v_temp_element, 'columnDataFormat', 'iconButtonFormat');
				JDR_DOCBUILDER.addChild (v_section_layout_element, JDR_DOCBUILDER.UI_NS, 'contents', v_temp_element);

				v_column_header_element := JDR_DOCBUILDER.CREATEELEMENT (JDR_DOCBUILDER.OA_NS, 'sortableHeader');

				JDR_DOCBUILDER.setAttribute (v_column_header_element, 'id', v_jrad_element_id || '_SCLHDR');
				JDR_DOCBUILDER.setAttribute (v_column_header_element, 'prompt', 'Delete');
				JDR_DOCBUILDER.addChild (v_temp_element, JDR_DOCBUILDER.UI_NS, 'columnHeader',
							 v_column_header_element);

				v_delete_field_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS,'image');
				JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'id', v_jrad_element_id || '_DELIMG');
				JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'source', 'deleteicon_enabled.gif');
				JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'warnAboutChanges', 'false');
				JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'serverUnvalidated', 'true');
				JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'unvalidated', 'true');



				JDR_DOCBUILDER.addChild (v_temp_element, JDR_DOCBUILDER.UI_NS, 'contents',
						   	 v_delete_field_element);

				v_delete_parameters := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'fireAction');
				JDR_DOCBUILDER.setAttribute (v_delete_parameters, 'event', 'Delete');
				JDR_DOCBUILDER.setAttribute (v_delete_parameters, 'unvalidated', 'true');
				v_delete_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
				JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'key', 'Id');

				JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'value',
					'${oa.encrypt.' || v_curr_formfieldvaluesvo_name ||  '.FormFieldValueId}');

				JDR_DOCBUILDER.addChild (v_delete_parameters, JDR_DOCBUILDER.UI_NS,
							'parameters', v_delete_parameter);

				v_delete_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');

				JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'key', 'ViewName');

				JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'value', v_curr_formfieldvaluesvo_name);
				JDR_DOCBUILDER.addChild (v_delete_parameters, JDR_DOCBUILDER.UI_NS,
							'parameters', v_delete_parameter);

				JDR_DOCBUILDER.addChild (v_delete_field_element, JDR_DOCBUILDER.UI_NS,
							'primaryClientAction', v_delete_parameters);

				/** Done: Adding delete colmn */

				-- add the table into the header region
				JDR_DOCBUILDER.addChild (v_section_element, jdr_docbuilder.UI_NS,'contents',
							v_section_layout_element);

				-- add the header region to its parent, since this is type='repeating_section'
				-- we can rest assured that the parent of this section is the top-level form

			---------------------------------------------------------------------------------------------------------------
			v_current_layout_array_index := getCurrentElementIndex(v_form_fields_row.type,p_form_id,v_parent_section_id,0,
									       v_current_section_id,null);
			v_parent_layout_array_index  := getParentElementIndex (v_form_fields_row.type,p_form_id,v_parent_section_id,0,
									       v_current_section_id,null);

			JDR_DOCBUILDER.addChild(v_section_layout_array(v_parent_layout_array_index),
						jdr_docbuilder.UI_NS,'contents',v_section_element);

			v_section_layout_array(v_current_layout_array_index) := v_section_element;
			---------------------------------------------------------------------------------------------------------------

			-------------------------------------
			-----READ-ONLY-REGION-START----------
			-------------------------------------

			JDR_DOCBUILDER.addChild (v_section_element_rd, jdr_docbuilder.UI_NS,'contents',
						 v_section_layout_element_rd);

			JDR_DOCBUILDER.addChild(v_section_layout_array_rd(v_parent_layout_array_index),
						jdr_docbuilder.UI_NS,'contents',v_section_element_rd);

			v_section_layout_array_rd(v_current_layout_array_index) := v_section_element_rd;

			-------------------------------------
			-----READ-ONLY-REGION-END------------
			-------------------------------------


		--}
		ELSIF (v_form_fields_row.type='INNER_SECTION_REPEAT_SECTION') THEN
		--{

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 6- : v_parent_section_id = '
							|| v_parent_section_id  || ' v_current_section_id = '
							|| v_current_section_id || ' v_LEVEL1_SECTION_ID = '
							|| v_LEVEL1_SECTION_ID);

			-- this is a repeating section inside a normal section which itself
			-- is inside another normal section

			v_parent_section_id  := v_form_fields_row.LEVEL2_SECTION_ID;
			v_current_section_id := v_form_fields_row.repeating_section_id;
			v_LEVEL1_SECTION_ID     := v_form_fields_row.section_id;
			-- create a header region

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 6+ : v_parent_section_id = '
							|| v_parent_section_id  || ' v_current_section_id = '
							|| v_current_section_id || ' v_LEVEL1_SECTION_ID = '
							|| v_LEVEL1_SECTION_ID);

			v_section_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');

			v_section_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'header');

			-- get the section title

			SELECT
				forms_tl.form_name, forms.form_code
			INTO
				v_section_title, v_section_code
			FROM
				pon_forms_sections forms,
				pon_forms_sections_tl forms_tl
			WHERE
				forms.form_id		= forms_tl.form_id AND
				forms.form_id		= v_current_section_id AND
				forms_tl.LANGUAGE	= g_base_language;

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'case 4+ : create header region for section - ' || v_section_code );

			JDR_DOCBUILDER.setAttribute (v_section_element, 'id', v_jrad_element_id);
			JDR_DOCBUILDER.setAttribute (v_section_element, 'text', escapespecialchar(v_section_title));

			JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'id', v_jrad_element_id);
			JDR_DOCBUILDER.setAttribute (v_section_element_rd, 'text', escapespecialchar(v_section_title));

			-- set all table-level JRAD attributes
			v_section_layout_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'advancedTable');

			v_section_layout_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'advancedTable');



			-- increment the VO count by one
			v_formfieldvaluesvo_list_count := v_formfieldvaluesvo_list_count + 1;
			v_curr_formfieldvaluesvo_name := v_formfieldvaluesvo_name || v_formfieldvaluesvo_list_count;

			JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'id', v_jrad_element_id ||'_table' );
			JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'viewName', v_curr_formfieldvaluesvo_name);
			JDR_DOCBUILDER.setAttribute (v_section_layout_element, 'width', '100%');


			JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'id', v_jrad_element_id ||'_table');
			JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'viewName', v_curr_formfieldvaluesvo_name);

			PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'Setting viewName for ' || v_section_code||'_table' || ' as ' || v_curr_formfieldvaluesvo_name);
			JDR_DOCBUILDER.setAttribute (v_section_layout_element_rd, 'width', '100%');

			-- create a table footer, and this footer as a child of the table region
			v_table_footer_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'tableFooter');
			JDR_DOCBUILDER.setAttribute (v_table_footer_element, 'id', v_jrad_element_id || '_TABFTR');

			JDR_DOCBUILDER.addChild (v_section_layout_element, JDR_DOCBUILDER.UI_NS, 'footer',
						 v_table_footer_element);

			v_add_table_row_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'addTableRow');
			JDR_DOCBUILDER.setAttribute (v_add_table_row_element, 'id', v_jrad_element_id ||'_ADDBTN');
			JDR_DOCBUILDER.setAttribute (v_add_table_row_element, 'autoInsertion', 'false');
			JDR_DOCBUILDER.addChild (v_table_footer_element, JDR_DOCBUILDER.UI_NS, 'contents',
						 v_add_table_row_element);

			-- add all the 'columns' in the table
			-- create a repeating section directly inside a form
			-- originally passed 'v_section_code' as the 1st param
			v_section_layout_element := CREATE_TABLE(v_current_section_id,
									           v_section_layout_element,
								                   p_form_id,
		 							           v_formfieldvaluesvo_list_count,
										   'N', v_form_fields_row.internal_sequence_number);

			v_section_layout_element_rd := CREATE_TABLE(v_current_section_id,
									           v_section_layout_element_rd,
								                   p_form_id,
		 							           v_formfieldvaluesvo_list_count,
										   'Y', v_form_fields_row.internal_sequence_number);

			/** Adding the delete column **/
			v_temp_element := JDR_DOCBUILDER.CREATEELEMENT (JDR_DOCBUILDER.OA_NS, 'column');
			JDR_DOCBUILDER.setAttribute (v_temp_element, 'id', v_jrad_element_id || '_COLDEL');
			JDR_DOCBUILDER.setAttribute (v_temp_element, 'columnDataFormat', 'iconButtonFormat');
			JDR_DOCBUILDER.addChild (v_section_layout_element, JDR_DOCBUILDER.UI_NS,
						 'contents', v_temp_element);

			v_column_header_element := JDR_DOCBUILDER.CREATEELEMENT (JDR_DOCBUILDER.OA_NS, 'sortableHeader');

			JDR_DOCBUILDER.setAttribute (v_column_header_element, 'id', v_jrad_element_id || '_SCLHDR');
			JDR_DOCBUILDER.setAttribute (v_column_header_element, 'prompt', 'Delete');
			JDR_DOCBUILDER.addChild (v_temp_element, JDR_DOCBUILDER.UI_NS, 'columnHeader',
							 v_column_header_element);

			v_delete_field_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS,'image');
			JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'id', v_jrad_element_id ||  '_DELIMG');
			JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'source', 'deleteicon_enabled.gif');
			JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'warnAboutChanges', 'false');
			JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'serverUnvalidated', 'true');
			JDR_DOCBUILDER.setAttribute (v_delete_field_element, 'unvalidated', 'true');
			JDR_DOCBUILDER.addChild (v_temp_element, JDR_DOCBUILDER.UI_NS, 'contents', v_delete_field_element);

			v_delete_parameters := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'fireAction');
			JDR_DOCBUILDER.setAttribute (v_delete_parameters, 'event', 'Delete');
			JDR_DOCBUILDER.setAttribute (v_delete_parameters, 'unvalidated', 'true');
			v_delete_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');
			JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'key', 'Id');

			JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'value',
					'${oa.encrypt.' || v_curr_formfieldvaluesvo_name ||  '.FormFieldValueId}');

			JDR_DOCBUILDER.addChild (v_delete_parameters, JDR_DOCBUILDER.UI_NS,
							'parameters', v_delete_parameter);

			v_delete_parameter := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.UI_NS, 'parameter');

			JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'key', 'ViewName');

			JDR_DOCBUILDER.setAttribute (v_delete_parameter, 'value', v_curr_formfieldvaluesvo_name);
			JDR_DOCBUILDER.addChild (v_delete_parameters, JDR_DOCBUILDER.UI_NS,
						'parameters', v_delete_parameter);

			JDR_DOCBUILDER.addChild (v_delete_field_element, JDR_DOCBUILDER.UI_NS,
						'primaryClientAction', v_delete_parameters);

			/** Done: Adding delete colmn */

			-- add the table into the header region
			JDR_DOCBUILDER.addChild (v_section_element, jdr_docbuilder.UI_NS,'contents',
						v_section_layout_element);

			-- add the header region to its parent, since this is type='repeating_section'
			-- we can rest assured that the parent of this section is the top-level form

			---------------------------------------------------------------------------------------------------------------
			v_current_layout_array_index := getCurrentElementIndex(v_form_fields_row.type,p_form_id,v_LEVEL1_SECTION_ID,
									       v_parent_section_id,v_current_section_id,null);

			v_parent_layout_array_index  := getParentElementIndex(v_form_fields_row.type,p_form_id,v_LEVEL1_SECTION_ID,
									      v_parent_section_id,v_current_section_id,null);

			JDR_DOCBUILDER.addChild(v_section_layout_array(v_parent_layout_array_index),
						jdr_docbuilder.UI_NS,'contents',v_section_element);

			v_section_layout_array(v_current_layout_array_index) := v_section_element;
			---------------------------------------------------------------------------------------------------------------

			-------------------------------------
			-----READ-ONLY-REGION-START----------
			-------------------------------------

			JDR_DOCBUILDER.addChild (v_section_element_rd, jdr_docbuilder.UI_NS,'contents',
						v_section_layout_element_rd);

			JDR_DOCBUILDER.addChild(v_section_layout_array_rd(v_parent_layout_array_index),
						jdr_docbuilder.UI_NS,'contents',v_section_element_rd);

			v_section_layout_array_rd(v_current_layout_array_index) := v_section_element_rd;

			-------------------------------------
			-----READ-ONLY-REGION-END------------
			-------------------------------------


		--}

		ELSE
		--{
			-- something really bad has happened
			-- do we need to take some drastic action or simply ignore this error silently
			null;
		END IF;
		--}


		IF (v_form_fields_row.type <>'FORM' AND
		    v_form_fields_row.type <>'REPEAT_SECTION' AND
		    v_form_fields_row.type <>'INNER_REPEAT_SECTION' AND
		    v_form_fields_row.type <>'INNER_SECTION_REPEAT_SECTION' AND
		    v_form_fields_row.type <>'NORMAL_SECTION' AND
		    v_form_fields_row.type <>'INNER_NORMAL_SECTION' AND
		    nvl(v_form_fields_row.field_code, 'x$#$y') <> 'x$#$y' ) THEN
		--{

--		  v_field_jrad_id := v_section_code || '_' || v_form_fields_row.field_code;
		  v_field_jrad_id := v_jrad_element_id;

		  PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'Creating field ' || v_field_jrad_id);

		  IF(NVL( v_form_fields_row.SYSTEM_FLAG, 'N') = 'Y' ) THEN
		  --{
                      /* Bug 6050403: For the TWO_PART_FLAG system field there is need to
                       * have a checkbox instead of a text field. So we handle it separately
		       */
                      IF (v_form_fields_row.FIELD_CODE <> 'TWO_PART_FLAG') THEN -- {
			v_section_field_element := create_element ('messageStyledText', v_field_jrad_id,
			                                           v_form_fields_row.field_name, 'VARCHAR2', 'none',
								   v_form_fields_row.field_code || '_NAME');

			v_section_field_element_rd := create_element ('messageStyledText', v_field_jrad_id,
			                                           v_form_fields_row.field_name, 'VARCHAR2', 'none',
								   v_form_fields_row.field_code || '_NAME');
                      ELSE  -- } {
	                v_section_field_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'messageCheckBox');
	                JDR_DOCBUILDER.setAttribute (v_section_field_element, 'id', v_field_jrad_id);
	                JDR_DOCBUILDER.setAttribute (v_section_field_element, 'defaultValue', 'Y');
	                JDR_DOCBUILDER.setAttribute (v_section_field_element, 'readOnly', 'true');
	                JDR_DOCBUILDER.setAttribute (v_section_field_element, 'prompt', v_form_fields_row.field_name);
                        JDR_DOCBUILDER.setAttribute (v_section_field_element, 'rendered', 'true');

	                v_section_field_element_rd := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'messageCheckBox');
	                JDR_DOCBUILDER.setAttribute (v_section_field_element_rd, 'id', v_field_jrad_id);
	                JDR_DOCBUILDER.setAttribute (v_section_field_element_rd, 'defaultValue', 'Y');
	                JDR_DOCBUILDER.setAttribute (v_section_field_element_rd, 'readOnly', 'true');
	                JDR_DOCBUILDER.setAttribute (v_section_field_element_rd, 'prompt', v_form_fields_row.field_name);
                        JDR_DOCBUILDER.setAttribute (v_section_field_element_rd, 'rendered', 'true');
                      END IF; --}
		  --}

		  ELSE
		  --{

		  IF (v_form_fields_row.datatype='LONGTEXT') then
			v_section_field_element := create_element ('messageTextInput', v_field_jrad_id,
			                                           v_form_fields_row.field_name, 'VARCHAR2', 'none',
								   v_form_fields_row.mapping_field_value_column);


			JDR_DOCBUILDER.setAttribute (v_section_field_element, 'maximumLength', 2000);

			v_section_field_element_rd := create_element ('messageStyledText', v_field_jrad_id,
			                                           v_form_fields_row.field_name, 'VARCHAR2', 'none',
								   v_form_fields_row.mapping_field_value_column);



	  	 ELSIF (v_form_fields_row.datatype='DATE') then
			v_section_field_element := create_element ('messageTextInput', v_field_jrad_id,
			                                            v_form_fields_row.field_name, 'DATE', 'dateFormat',
								    v_form_fields_row.mapping_field_value_column);

			v_section_field_element_rd := create_element ('messageStyledText', v_field_jrad_id,
			                                            v_form_fields_row.field_name, 'DATE', 'none',
								    v_form_fields_row.mapping_field_value_column);

	  	 ELSIF (v_form_fields_row.datatype='DATETIME') then

			v_section_field_element := create_element ('messageTextInput', v_field_jrad_id,
			                                           v_form_fields_row.field_name, 'DATETIME','dateFormat',
								   v_form_fields_row.mapping_field_value_column);

			v_section_field_element_rd := create_element ('messageStyledText', v_field_jrad_id,
			                                            v_form_fields_row.field_name, 'DATETIME', 'dateFormat',
								    v_form_fields_row.mapping_field_value_column);

	  	 ELSIF (v_form_fields_row.datatype='AMOUNT') then
			v_section_field_element := create_element ('messageTextInput', v_field_jrad_id,
			                                           v_form_fields_row.field_name, 'NUMBER', 'none',
								   v_form_fields_row.mapping_field_value_column);

			v_section_field_element_rd := create_element ('messageStyledText', v_field_jrad_id,
			                                           v_form_fields_row.field_name, 'NUMBER', 'none',
								   v_form_fields_row.mapping_field_value_column);
	  	 ELSIF (v_form_fields_row.datatype='NUMBER') then

			IF(nvl(v_form_fields_row.field_description, 'x@Y#z') = 'x@Y#z' ) THEN

				v_section_field_element := create_element ('messageTextInput', v_field_jrad_id,
			                                           v_form_fields_row.field_name, 'NUMBER', 'none',
								   v_form_fields_row.mapping_field_value_column);

				v_section_field_element_rd := create_element ('messageStyledText', v_field_jrad_id,
			                                           v_form_fields_row.field_name, 'NUMBER', 'none',
								   v_form_fields_row.mapping_field_value_column);

			ELSE
				v_section_field_element := create_element ('messageTextInput', v_field_jrad_id,
			                                           v_form_fields_row.field_name, 'NUMBER', 'longMessage',
								   v_form_fields_row.mapping_field_value_column);

				v_section_field_element_rd := create_element ('messageStyledText', v_field_jrad_id,
			                                           v_form_fields_row.field_name, 'NUMBER', 'longMessage',
								   v_form_fields_row.mapping_field_value_column);


			END IF;

	  	 ELSIF ( (v_form_fields_row.datatype='TEXT') AND (v_form_fields_row.value_set_name is not null)) then

			v_section_field_element_rd := create_element ('messageStyledText', v_field_jrad_id,
			                                           v_form_fields_row.field_name, 'VARCHAR2', 'none',
								   v_field_jrad_id || '_NAME');

			v_section_field_element   := create_vset_element (v_field_jrad_id, v_form_fields_row.field_code,
									  v_form_fields_row.field_name,
									  v_form_fields_row.field_description,
									  v_form_fields_row.mapping_field_value_column,
									  v_form_fields_row.value_set_name, 'N');
			v_vset_element_created    := 'Y';


	  	   ELSE -- TBD: Unrecognized field

			IF(nvl(v_form_fields_row.field_description, 'x@Y#z') = 'x@Y#z' ) THEN

				v_section_field_element := create_element ('messageTextInput', v_field_jrad_id,
			                                            v_form_fields_row.field_name, 'VARCHAR2','none',
								    v_form_fields_row.mapping_field_value_column);
				JDR_DOCBUILDER.setAttribute (v_section_field_element, 'maximumLength', 2000);

				v_section_field_element_rd := create_element ('messageStyledText', v_field_jrad_id,
			                                            v_form_fields_row.field_name, 'VARCHAR2','none',
								    v_form_fields_row.mapping_field_value_column);
			ELSE
				v_section_field_element := create_element ('messageTextInput', v_field_jrad_id,
			                                            v_form_fields_row.field_name, 'VARCHAR2','longMessage',
								    v_form_fields_row.mapping_field_value_column);
				JDR_DOCBUILDER.setAttribute (v_section_field_element, 'maximumLength', 2000);

				v_section_field_element_rd := create_element ('messageStyledText', v_field_jrad_id,
			                                            v_form_fields_row.field_name, 'VARCHAR2','longMessage',
								    v_form_fields_row.mapping_field_value_column);


			END IF;

	  	 END IF;

		 --If the field is a required field then set it accordingly.
   		 IF (v_form_fields_row.required='Y') THEN
			JDR_DOCBUILDER.setAttribute (v_section_field_element, 'required','yes');
		 END IF;

	       END IF;
	       --}  -- end if this field is not a system field

                /*
                 * Bug 6050403: We do not need a viewname for the two_part_flag field as the
		 * checkbox will always remain checked. The rendered attribute will ensure that
		 * the checkbox does not appear for non-two part rfqs
		 */
                IF (v_form_fields_row.FIELD_CODE <> 'TWO_PART_FLAG') THEN -- {
	       	  JDR_DOCBUILDER.setAttribute (v_section_field_element, 'viewName', v_curr_formfieldvaluesvo_name);
                END IF;
	       	JDR_DOCBUILDER.addChild (v_section_layout_element,jdr_docbuilder.UI_NS,'contents',v_section_field_element);
		---- need to create a formValue element for this LOV

		if(v_vset_element_created = 'Y' and isLovValueSet(v_form_fields_row.field_code) = 'Y') then

			v_vset_element_created := 'N';

			-- encapsulate the formValue bean inside a messageLayout bean as
			-- we cannot have a formValue directly inside a messageComponentLayout

			v_message_layout_element := JDR_DOCBUILDER.createElement (JDR_DOCBUILDER.OA_NS, 'messageLayout');
			JDR_DOCBUILDER.setAttribute (v_message_layout_element, 'id', v_field_jrad_id || '_MSL');
			JDR_DOCBUILDER.addChild (v_section_layout_element,jdr_docbuilder.UI_NS,'contents',v_message_layout_element);

			v_section_field_element := create_element ('formValue', v_field_jrad_id || '_FORM',
			                                           v_form_fields_row.field_name, 'VARCHAR2', 'none',
								   v_form_fields_row.mapping_field_value_column);

		       	JDR_DOCBUILDER.setAttribute (v_section_field_element, 'viewName', v_curr_formfieldvaluesvo_name);
		       	JDR_DOCBUILDER.addChild (v_message_layout_element,jdr_docbuilder.UI_NS,'contents',v_section_field_element);

		end if;


                /*
                 * Bug 6050403: We do not need a viewname for the two_part_flag field as the
		 * checkbox will always remain checked. The rendered attribute will ensure that
		 * the checkbox does not appear for non-two part rfqs
		 */
               IF (v_form_fields_row.FIELD_CODE <> 'TWO_PART_FLAG') THEN -- {
	         JDR_DOCBUILDER.setAttribute (v_section_field_element_rd, 'viewName', v_curr_formfieldvaluesvo_name);
               END IF;
	       JDR_DOCBUILDER.addChild (v_section_layout_element_rd,jdr_docbuilder.UI_NS,'contents',v_section_field_element_rd);

	       PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'Setting viewname for ' || v_form_fields_row.field_code || ' as ' || v_curr_formfieldvaluesvo_name);

	   END IF; --}

	   v_prev_record_type := v_form_fields_row.type;

	END LOOP; --}

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'JRAD created, now saving to JDR repository');

	rval := JDR_DOCBUILDER.save;

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'Finished saving to JDR repository');

	x_result :=fnd_api.g_ret_sts_success;

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'END');

EXCEPTION
    WHEN OTHERS THEN
	x_result := fnd_api.g_ret_sts_error;
	x_error_code := SQLCODE;
	x_error_message := SUBSTR(SQLERRM, 1, 100);
	PON_FORMS_UTIL_PVT.print_error_log(l_api_name, 'EXCEPTION - x_result=' || x_result || ' x_error_code=' || x_error_code || ' x_error_message=' || x_error_message || ' SQLERRM=' || SQLERRM);

END CREATE_FORM;

/*======================================================================
 PROCEDURE:  CREATE_ABSTRACT	PRIVATE
   PARAMETERS:
   COMMENT   :  This procedure generates the following 3 JRAD regions for
		a abstract -
		** Buyer entry abstract region
		** Read-only abstract region
		** External supplier table region
		This procedure is invoked when the abstract is made active
======================================================================*/

PROCEDURE CREATE_ABSTRACT(p_form_id 		IN 	 	NUMBER,
  		      	  x_result		OUT NOCOPY  	VARCHAR2,
  		      	  x_error_code    	OUT NOCOPY  	VARCHAR2,
  		      	  x_error_message 	OUT NOCOPY  	VARCHAR2) IS

l_api_name	CONSTANT VARCHAR2(30) := 'CREATE_ABSTRACT';

BEGIN
	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'BEGIN-');

	create_form(p_form_id, x_result, x_error_code, x_error_message);

	create_abstract_table(p_form_id, x_result, x_error_code, x_error_message);

	x_result :=fnd_api.g_ret_sts_success;

EXCEPTION
    WHEN OTHERS THEN
	x_result := fnd_api.g_ret_sts_error;
	x_error_code := SQLCODE;
	x_error_message := SUBSTR(SQLERRM, 1, 100);
	PON_FORMS_UTIL_PVT.print_error_log(l_api_name, 'EXCEPTION - x_result=' || x_result || ' x_error_code=' || x_error_code || ' x_error_message=' || x_error_message || ' SQLERRM=' || SQLERRM);

END;

/*======================================================================
 PROCEDURE:  CREATE_JRAD	PUBLIC
   PARAMETERS:
   COMMENT   : 	Wrapper public procedure to all internal procedures. This
		procedure is called from the middle-tier when a form or
		a section or abstract is made active.
======================================================================*/
PROCEDURE CREATE_JRAD(	p_form_id 	IN 	NUMBER,
  			x_result	OUT NOCOPY  VARCHAR2,
  			x_error_code    OUT NOCOPY  VARCHAR2,
  			x_error_message OUT NOCOPY  VARCHAR2
 ) IS

v_form_type PON_FORMS_SECTIONS.TYPE%TYPE;
v_is_repeating_section_flag PON_FORMS_SECTIONS.IS_REPEATING_SECTION_FLAG%TYPE;
l_api_name	CONSTANT VARCHAR2(30) := 'CREATE_JRAD';

BEGIN
	-- initialize to error
	x_result := fnd_api.g_ret_sts_error;

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'BEGIN-');

	-- the overall logic to generate jrad is as follows -
	-- determine whether the type is 'SECTION' or 'ABSTRACT' or 'FORM'

	select
    type,
    nvl(is_repeating_section_flag,'N')
  into
    v_form_type,
    v_is_repeating_section_flag
  from pon_forms_sections where form_id = p_form_id;

	-- generate the buyer data-entry page
	-- generate the buyer view-only page

	-- if this is an abstract, generate the supplier external table
	-- initialize a few global variables
	g_sql_pop_list_count 	:= 1;
	g_table_pop_list_count	:= 1;
	g_lov_map_count		:= 1;
	g_pop_list_count 	:= 1;
	g_total_image_count	:= 1;
	g_base_language		:= getBaseLanguage();

	if(v_form_type = 'FORM') then
	  create_form(p_form_id, x_result, x_error_code, x_error_message);
	elsif(v_form_type = 'SECTION') then
    if (v_is_repeating_section_flag = 'Y') then
      create_repeating_section(p_form_id , x_result, x_error_code, x_error_message);
    else
      create_form(p_form_id, x_result, x_error_code, x_error_message);
    end if;
	elsif (v_form_type = 'ABSTRACT') then
	  create_abstract(p_form_id, x_result, x_error_code, x_error_message);
	end if;

	x_result := fnd_api.g_ret_sts_success;

	PON_FORMS_UTIL_PVT.print_debug_log(l_api_name, 'END');

EXCEPTION
    WHEN OTHERS THEN
	x_result := fnd_api.g_ret_sts_error;
	x_error_code := SQLCODE;
	x_error_message := SUBSTR(SQLERRM, 1, 100);
	PON_FORMS_UTIL_PVT.print_error_log(l_api_name, 'EXCEPTION - x_result=' || x_result || ' x_error_code=' || x_error_code || ' x_error_message=' || x_error_message || ' SQLERRM=' || SQLERRM);

END CREATE_JRAD;


END PON_FORMS_JRAD_PVT;

/
