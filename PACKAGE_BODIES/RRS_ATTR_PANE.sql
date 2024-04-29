--------------------------------------------------------
--  DDL for Package Body RRS_ATTR_PANE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_ATTR_PANE" AS
/* $Header: RRSGATPB.pls 120.0.12010000.15 2010/03/13 00:00:34 jijiao noship $ */

/*Get Basic Information for the object*/
PROCEDURE Get_Primary_Attributes
(
	p_object_type		IN		VARCHAR2,
	p_object_id		IN		VARCHAR2,
	x_primary_attributes	OUT NOCOPY 	rrs_primary_attribute_rec,
	x_error_messages	OUT NOCOPY 	rrs_error_msg_tab
) IS

l_object_table_name	VARCHAR2(30);
l_pk_name		VARCHAR2(30);
l_classification_name	VARCHAR2(30);
l_date_format_mask	VARCHAR2(100);

BEGIN
	--Bug Fix for Bug 9027024, need display the start/end date in the format as set in user preference
	SELECT FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')
	  INTO l_date_format_mask
	  FROM DUAL;

	/* decide which object type we are processing*/
	IF UPPER(p_object_type) = 'SITE' THEN
		BEGIN
		SELECT RRS_PRIMARY_ATTRIBUTE_REC(
			SITE_ID,
			SITE_IDENTIFICATION_NUMBER,
			NAME,
			(SELECT MEANING
			   FROM RRS_SITE_USES RSU, AR_LOOKUPS LK
			  WHERE RSU.SITE_ID = p_object_id
			    AND RSU.IS_PRIMARY_FLAG = 'Y'
			    AND LK.LOOKUP_TYPE (+) = 'PARTY_SITE_USE_CODE'
			    AND RSU.SITE_USE_TYPE_CODE = LK.LOOKUP_CODE (+)
			),
			DESCRIPTION,
			(SELECT MEANING FROM RRS_LOOKUPS_V WHERE LOOKUP_TYPE = 'RRS_SITE_TYPE' AND LOOKUP_CODE = RSV.SITE_TYPE_CODE),
			(SELECT MEANING FROM RRS_LOOKUPS_V WHERE LOOKUP_TYPE = 'RRS_SITE_STATUS' AND LOOKUP_CODE = RSV.SITE_STATUS_CODE),
			TO_CHAR(START_DATE, l_date_format_mask), --Bug Fix for Bug 9027024, need display the start/end date in the format as set in user preference
			TO_CHAR(END_DATE, l_date_format_mask),   --Bug Fix for Bug 9027024, need display the start/end date in the format as set in user preference
			(HZ_FORMAT_PUB.format_address(RSV.location_id, null, null, ', ' , null) || ', ' || (SELECT COUNTRY FROM RRS_LOCATIONS_V WHERE LOCATION_ID = RSV.LOCATION_ID)
			),
			NULL,
			NULL,
			NULL)
		   INTO x_primary_attributes
		   FROM RRS_SITES_VL RSV
		  WHERE SITE_ID = p_object_id;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				Record_Error('No primary attributes were found for ' || p_object_type || ' ' || p_object_id || '.', x_error_messages);
			WHEN OTHERS THEN
				Record_Error('Get_Primary_Attributes: ' || dbms_utility.format_error_backtrace, x_error_messages);

		END;

	ELSIF UPPER(p_object_type) = 'LOCATION' THEN
		BEGIN
		SELECT RRS_PRIMARY_ATTRIBUTE_REC(
			LOCATION_ID,
			NULL,
			NULL,
			COUNTRY,
			DESCRIPTION,
			NULL,
			NULL,
			NULL,
			NULL,
			(HZ_FORMAT_PUB.format_address(RLV.location_id, null, null, ',' , null) || ', ' || COUNTRY
			),
			COUNTRY,
			NULL,
			NULL)
		   INTO x_primary_attributes
		   FROM RRS_LOCATIONS_V RLV
		  WHERE LOCATION_ID = p_object_id;
		  EXCEPTION
		  	WHEN NO_DATA_FOUND THEN
				Record_Error('No primary attributes were found for ' || p_object_type || ' ' || p_object_id || '.', x_error_messages);
			WHEN OTHERS THEN
				Record_Error('Get_Primary_Attributes: ' || dbms_utility.format_error_backtrace, x_error_messages);

		  END;

	ELSIF UPPER(p_object_type) = 'NODE' THEN
		 BEGIN
		 SELECT RRS_PRIMARY_ATTRIBUTE_REC(
			SITE_GROUP_NODE_ID,
			NODE_IDENTIFICATION_NUMBER,
			NAME,
			(SELECT MEANING
			   FROM RRS_LOOKUPS_V LK
			  WHERE LK.LOOKUP_TYPE (+) = 'RRS_NODE_PURPOSE'
			    AND RSGNV.NODE_PURPOSE_CODE = LK.LOOKUP_CODE (+)
			),
			DESCRIPTION,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL)
		   INTO x_primary_attributes
		   FROM RRS_SITE_GROUP_NODES_VL RSGNV
		  WHERE SITE_GROUP_NODE_ID = p_object_id;

		  EXCEPTION
		  	WHEN NO_DATA_FOUND THEN
				Record_Error('No primary attributes were found for ' || p_object_type || ' ' || p_object_id || '.', x_error_messages);
			WHEN OTHERS THEN
				Record_Error('Get_Primary_Attributes: ' || dbms_utility.format_error_backtrace, x_error_messages);
		  END;

	/*ELSIF UPPER(p_object_type) = 'TRADE AREA' THEN
		SELECT RRS_PRIMARY_ATTRIBUTE_REC(
			GROUP_ID,
			SITE_IDENTIFICATION_NUMBER,
			NAME,
			(SELECT MEANING
			   FROM RRS_SITE_USES RSU, AR_LOOKUPS LK
			  WHERE RSU.SITE_ID = p_object_id
			    AND RSU.IS_PRIMARY_FLAG = 'Y'
			    AND LK.LOOKUP_TYPE = 'PARTY_SITE_USE_CODE'
			    AND RSU.SITE_USE_TYPE_CODE = LK.LOOKUP_CODE
			),
			DESCRIPTION,
			(SELECT MEANING FROM RRS_LOOKUPS_V WHERE LOOKUP_TYPE = 'RRS_SITE_TYPE' AND LOOKUP_CODE = RSV.SITE_TYPE_CODE),
			(SELECT MEANING FROM RRS_LOOKUPS_V WHERE LOOKUP_TYPE = 'RRS_SITE_STATUS' AND LOOKUP_CODE = RSV.SITE_STATUS_CODE),
			START_DATE,
			END_DATE,
			(HZ_FORMAT_PUB.format_address(RSV.location_id, null, null, ',' , null) || ', ' || (SELECT COUNTRY FROM RRS_LOCATIONS_V WHERE LOCATION_ID = RSV.LOCATION_ID)
			),
			(SELECT MEANING FROM RRS_LOOKUPS_V WHERE LOOKUP_TYPE = 'RRS_TRADE_AREA_GROUP_TYPE' AND LOOKUP_CODE = RTAGV.GROUP_TYPE_CODE),
			NULL,
			NULL)
		   INTO x_primary_attributes
		   FROM RRS_TRADE_AREA_GROUPS_VL RTAGV
		  WHERE GROUP_ID = p_object_id;
	*/
	ELSIF UPPER(p_object_type) = 'HIERARCHY' THEN
		 BEGIN
		 SELECT RRS_PRIMARY_ATTRIBUTE_REC(
			SITE_GROUP_ID,
			NULL,
			NAME,
			(SELECT MEANING
			   FROM RRS_LOOKUPS_V LK
			  WHERE LK.LOOKUP_TYPE(+) = 'RRS_HIERARCHY_PURPOSE'
			    AND RSGV.GROUP_PURPOSE_CODE = LK.LOOKUP_CODE (+)
			),
			DESCRIPTION,
			NULL,
			NULL,
			TO_CHAR(START_DATE, l_date_format_mask),  --Bug Fix for Bug 9027024, need display the start/end date in the format as set in user preference
			TO_CHAR(END_DATE, l_date_format_mask),    --Bug Fix for Bug 9027024, need display the start/end date in the format as set in user preference
			NULL,
			NULL,
			SITE_GROUP_TYPE_CODE,
			NULL)
		   INTO x_primary_attributes
		   FROM RRS_SITE_GROUPS_VL RSGV
		  WHERE SITE_GROUP_ID = (SELECT SITE_GROUP_ID FROM RRS_SITE_GROUP_VERSIONS WHERE SITE_GROUP_VERSION_ID = p_object_id);

		 EXCEPTION
		  	WHEN NO_DATA_FOUND THEN
		  		Record_Error('No primary attributes were found for ' || p_object_type || ' ' || p_object_id || '.', x_error_messages);
		  	WHEN OTHERS THEN
		  		Record_Error('Get_Primary_Attributes: ' || dbms_utility.format_error_backtrace, x_error_messages);

		 END;
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		Record_Error('No primary attributes were found for ' || p_object_type || ' ' || p_object_id || '.', x_error_messages);
	WHEN OTHERS THEN
		Record_Error('Get_Primary_Attributes: ' || dbms_utility.format_error_backtrace, x_error_messages);
END;


PROCEDURE Get_Attribute_Page
(
	p_where_used		IN		VARCHAR2,
	p_object_type		IN		VARCHAR2,
	p_object_id		IN		NUMBER,
	p_object1		IN		VARCHAR2,
	p_classification_code1	IN		VARCHAR2,
	p_object2		IN		VARCHAR2,
	p_classification_code2	IN		VARCHAR2,
	x_primary_attributes	OUT NOCOPY	rrs_primary_attribute_rec,
	x_ag_page_tab		OUT NOCOPY	rrs_attr_group_page_tab,
	x_attr_group_tab	OUT NOCOPY	rrs_attribute_group_tab,
	x_attribute_tab		OUT NOCOPY	rrs_attribute_tab,
	x_error_messages	OUT NOCOPY	rrs_error_msg_tab
) IS

l_classification_code	VARCHAR2(30);
l_page_id_array		t_array_of_number;
l_attr_group_page_rec	rrs_attr_group_page_rec;
l_attr_group_page_tab	rrs_attr_group_page_tab;
l_attribute_group_rec	rrs_attribute_group_rec;
l_page_entries		t_page_entry_tab;
l_ext_id_array		t_array_of_number;

l_ext_table_name	VARCHAR2(30);
l_pk_name		VARCHAR2(30);
l_classification_name	VARCHAR2(30);
l_attribute_tab		t_attribute_tab;

l_x_display_value	VARCHAR2(1000);
l_x_display_type	VARCHAR2(200);
l_x_dynamic_url		VARCHAR2(1000);

l_query			VARCHAR2(1000);
l_display_type_code	VARCHAR2(10);


BEGIN

	Get_Primary_Attributes(p_object_type,
			       p_object_id,
			       x_primary_attributes,
			       x_error_messages);

	/* decide which object type we are processing*/
	IF UPPER(p_object_type) = 'NODE' THEN
		RAISE e_no_uda;
	ELSIF UPPER(p_object_type) = 'SITE' THEN
		l_ext_table_name := 'RRS_SITES_EXT_VL';
		l_pk_name := 'SITE_ID';
		l_classification_name := 'SITE_USE_TYPE_CODE';
	ELSIF UPPER(p_object_type) = 'LOCATION' THEN
		l_ext_table_name := 'RRS_LOCATIONS_EXT_VL';
		l_pk_name := 'LOCATION_ID';
		l_classification_name := 'COUNTRY';
	ELSIF UPPER(p_object_type) = 'TRADE AREA' THEN
		l_ext_table_name := 'RRS_TRADE_AREAS_EXT_VL';
		l_pk_name := 'TRADE_AREA_ID';
		l_classification_name := 'GROUP_ID';
	ELSIF UPPER(p_object_type) = 'HIERARCHY' THEN
		l_ext_table_name := 'RRS_HIERARCHIES_EXT_VL';
		l_pk_name := 'SITE_GROUP_VERSION_ID';
		l_classification_name := 'HIERARCHY_PURPOSE_CODE';
	END IF;

	/*Get Page IDs*/
	BEGIN
	IF p_object2 IS NOT NULL AND p_classification_code2 IS NOT NULL THEN
		SELECT ATTRIBUTE_PAGE_ID
		  BULK COLLECT
		  INTO l_page_id_array
		  FROM RRS_ATTR_PAGE_SETTINGS
		 WHERE WHERE_USED = p_where_used
		   AND OBJECT_TYPE = p_object_type
		   AND CATEGORIZATION_OBJECT1 = p_object1
		   AND CLASSIFICATION_CODE1 = p_classification_code1
		   AND CATEGORIZATION_OBJECT2 = p_object2
	   	   AND CLASSIFICATION_CODE2 = p_classification_code2;

	ELSIF p_object2 IS NULL AND p_classification_code2 IS NULL THEN
		SELECT ATTRIBUTE_PAGE_ID
		  BULK COLLECT
		  INTO l_page_id_array
		  FROM RRS_ATTR_PAGE_SETTINGS
		 WHERE WHERE_USED = p_where_used
		   AND OBJECT_TYPE = p_object_type
		   AND CATEGORIZATION_OBJECT1 = p_object1
		   AND CLASSIFICATION_CODE1 = p_classification_code1
		   AND CATEGORIZATION_OBJECT2 IS NULL
	   	   AND CLASSIFICATION_CODE2 IS NULL;

	ELSIF p_classification_code2 IS NULL THEN
		SELECT ATTRIBUTE_PAGE_ID
		  BULK COLLECT
		  INTO l_page_id_array
		  FROM RRS_ATTR_PAGE_SETTINGS
		 WHERE WHERE_USED = p_where_used
		   AND OBJECT_TYPE = p_object_type
		   AND CATEGORIZATION_OBJECT1 = p_object1
		   AND CLASSIFICATION_CODE1 = p_classification_code1
		   AND CATEGORIZATION_OBJECT2 = p_object2
	   	   AND CLASSIFICATION_CODE2 IS NULL;
	END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN

			IF x_error_messages IS NULL THEN
				x_error_messages := new rrs_error_msg_tab();
			END IF;
			x_error_messages.EXTEND();
			x_error_messages(x_error_messages.LAST) := 'Get_Attribute_Group_Page: No attribute page was found for ' || p_object_type || ' ' || p_object_id || '.';
			--Record_Error('Get_Attribute_Group_Page: No attribute page was found for ' || p_object_type || ' ' || p_object_id || '.', x_error_messages);
			RAISE e_no_page_found;
	END;

	IF l_page_id_array IS NULL OR l_page_id_array.COUNT = 0 THEN

			IF x_error_messages IS NULL THEN
				x_error_messages := new rrs_error_msg_tab();
			END IF;
			x_error_messages.EXTEND();
			x_error_messages(x_error_messages.LAST) := 'Get_Attribute_Group_Page: No attribute page was found for ' || p_object_type || ' ' || p_object_id || '.';
			--Record_Error('Get_Attribute_Group_Page: No attribute page was found for ' || p_object_type || ' ' || p_object_id || '.', x_error_messages);
			RAISE e_no_page_found;
	END IF;

	/*Decide the classification for the page*/
	IF p_classification_code2 IS NULL THEN
		l_classification_code := p_classification_code1;
	ELSE
		l_classification_code := p_classification_code2;
	END IF;

	/*For each page, get page information*/
        FOR i in 1 .. l_page_id_array.COUNT
        LOOP
        	/*Get Page Information*/
		BEGIN
		SELECT RRS_ATTR_GROUP_PAGE_REC(
		       PAGE_ID,
		       OBJECT_NAME,
		       CLASSIFICATION_CODE,
		       DATA_LEVEL_INT_NAME, INTERNAL_NAME, DISPLAY_NAME,
		       DESCRIPTION, SEQUENCE)
		  INTO l_attr_group_page_rec
		  FROM EGO_PAGES_V
		 WHERE PAGE_ID = l_page_id_array(i);

		 IF l_attr_group_page_tab IS NULL THEN
		 	l_attr_group_page_tab := new rrs_attr_group_page_tab();
		 END IF;

		 l_attr_group_page_tab.EXTEND();
		 l_attr_group_page_tab(l_attr_group_page_tab.LAST) := new rrs_attr_group_page_rec(
									l_attr_group_page_rec.PAGE_ID,
									l_attr_group_page_rec.OBJECT_NAME,
									l_attr_group_page_rec.CLASSIFICATION_CODE,
									l_attr_group_page_rec.DATA_LEVEL_INT_NAME,
									l_attr_group_page_rec.INTERNAL_NAME,
									l_attr_group_page_rec.DISPLAY_NAME,
									l_attr_group_page_rec.DESCRIPTION,
									l_attr_group_page_rec.SEQUENCE
								      );

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				Record_Error('Get_Attribute_Group_Page: No attribute page was found for Page Id ' || l_page_id_array(i) || '.', x_error_messages);
				RAISE e_no_page_found;
		END;
        END LOOP;

        SELECT RRS_ATTR_GROUP_PAGE_REC(
		PAGE_ID, OBJECT_NAME, CLASSIFICATION_CODE,
		DATA_LEVEL_INT_NAME, INTERNAL_NAME, DISPLAY_NAME,
		DESCRIPTION, SEQUENCE)
          BULK COLLECT
          INTO x_ag_page_tab
          FROM TABLE(l_attr_group_page_tab)
          ORDER BY SEQUENCE;



        /*For each page, get the Page Entries Information*/
        FOR i in 1 .. x_ag_page_tab.COUNT
        LOOP
		/*Get Page Entries In the Order of SEQUENCE*/
		BEGIN
		SELECT ATTR_GROUP_TYPE, ATTR_GROUP_NAME, SEQUENCE
		  BULK COLLECT
		  INTO l_page_entries
		  FROM EGO_PAGE_ENTRIES_V
		 WHERE PAGE_ID = l_page_id_array(i)
		   AND CLASSIFICATION_CODE = l_classification_code
	      ORDER BY SEQUENCE;

	      	EXCEPTION
	      		WHEN NO_DATA_FOUND THEN
				Record_Error('Get_Attribute_Group_Page: No attribute page entry was found for page ' || l_page_id_array(i) || '.', x_error_messages);
	      			RAISE e_no_page_entry_found;
	      	END;

	      	IF l_page_entries IS NULL OR l_page_entries.COUNT = 0 THEN
				Record_Error('Get_Attribute_Group_Page: No attribute page entry was found for page ' || l_page_id_array(i) || '.', x_error_messages);
	      			RAISE e_no_page_entry_found;
	      	END IF;

		/*Get Attribute Group Information*/
		FOR j in 1 .. l_page_entries.COUNT
		LOOP
			BEGIN
			SELECT RRS_ATTRIBUTE_GROUP_REC(
			       l_page_id_array(i),
			       ATTR_GROUP_ID,
			       ATTR_GROUP_TYPE,
			       ATTR_GROUP_NAME,
			       ATTR_GROUP_DISP_NAME,
			       DESCRIPTION,
			       MULTI_ROW_CODE,
			       SECURITY_CODE,
			       NUM_OF_COLS,
			       NUM_OF_ROWS,
			       l_page_entries(j).sequence)
			  INTO l_attribute_group_rec
			  FROM EGO_ATTR_GROUPS_V
			 WHERE APPLICATION_ID = 718
			   AND ATTR_GROUP_TYPE = l_page_entries(j).attr_group_type
			   AND ATTR_GROUP_NAME = l_page_entries(j).attr_group_name;

			IF x_attr_group_tab IS NULL THEN
				x_attr_group_tab := new rrs_attribute_group_tab();
			END IF;

			x_attr_group_tab.EXTEND();
			x_attr_group_tab(x_attr_group_tab.LAST) := new rrs_attribute_group_rec(
									l_attribute_group_rec.PAGE_ID,
									l_attribute_group_rec.ATTR_GROUP_ID,
									l_attribute_group_rec.ATTR_GROUP_TYPE,
									l_attribute_group_rec.ATTR_GROUP_NAME,
									l_attribute_group_rec.ATTR_GROUP_DISP_NAME,
									l_attribute_group_rec.DESCRIPTION,
									l_attribute_group_rec.MULTI_ROW_CODE,
									l_attribute_group_rec.SECURITY_CODE,
									l_attribute_group_rec.NUM_OF_COLS,
									l_attribute_group_rec.NUM_OF_ROWS,
									l_attribute_group_rec.SEQUENCE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					Record_Error('Get_Attribute_Group_Page: No attribute group was found for page entry ' || l_page_entries(j).attr_group_type || ' ' || l_page_entries(j).attr_group_name || '.', x_error_messages);
					RAISE e_no_attr_group_found;
			END;
		END LOOP;


		/*For each attribute group, get attributes*/
		FOR j in 1 .. x_attr_group_tab.COUNT
		LOOP
			/*For each attribute group, get Extension IDs*/
			l_query := 'SELECT EXTENSION_ID' ||
			           '  FROM ' || l_ext_table_name ||
			 	   ' WHERE ' || l_pk_name || ' = :1'||
			 	   '   AND ' || l_classification_name || ' = :2'||
			 	   '   AND ATTR_GROUP_ID = :3';
			EXECUTE IMMEDIATE l_query
			BULK COLLECT INTO l_ext_id_array
			            USING p_object_id, l_classification_code, x_attr_group_tab(j).ATTR_GROUP_ID;

			/*Get Attribute Names for the attribute group*/
			BEGIN
			SELECT ATTR_NAME, ATTR_DISPLAY_NAME, DISPLAY_CODE, DESCRIPTION, SEQUENCE
			  BULK COLLECT
			  INTO l_attribute_tab
			  FROM EGO_ATTRS_V
			 WHERE APPLICATION_ID = 718
			   AND ATTR_GROUP_TYPE = x_attr_group_tab(j).ATTR_GROUP_TYPE
			   AND ATTR_GROUP_NAME = x_attr_group_tab(j).ATTR_GROUP_NAME
			 ORDER BY SEQUENCE;

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					Record_Error('Get_Attribute_Group_Page: No attribute was found for ' || x_attr_group_tab(j).ATTR_GROUP_TYPE || ' ' || x_attr_group_tab(j).ATTR_GROUP_NAME || '.', x_error_messages);
					RAISE e_no_attribute_found;
			END;

			IF l_attribute_tab IS NULL OR l_attribute_tab.COUNT = 0 THEN
				Record_Error('Get_Attribute_Group_Page: No attribute was found for ' || x_attr_group_tab(j).ATTR_GROUP_TYPE || ' ' || x_attr_group_tab(j).ATTR_GROUP_NAME || '.', x_error_messages);
				RAISE e_no_attribute_found;
			END IF;

			/*For each EXT Row, we get the display value for each attribute*/
			FOR k in 1 .. l_ext_id_array.COUNT
			LOOP
				FOR p in 1 .. l_attribute_tab.COUNT
				LOOP
					--DBMS_OUTPUT.PUT_LINE('p_attr_group_type: ' || x_attr_group_tab(j).ATTR_GROUP_TYPE);
					Get_Display_Value(p_object_type,
					                  p_object_id,
					                  x_attr_group_tab(j).ATTR_GROUP_TYPE,
					                  x_attr_group_tab(j).ATTR_GROUP_NAME,
					                  l_attribute_tab(p).ATTR_NAME,
					                  l_ext_id_array(k),
					                  l_x_display_value,
					                  l_x_display_type,
					                  l_x_dynamic_url,
					                  x_error_messages);

					IF x_attribute_tab IS NULL THEN
						x_attribute_tab := new rrs_attribute_tab();
					END IF;

					x_attribute_tab.EXTEND();
					x_attribute_tab(x_attribute_tab.LAST) := new rrs_attribute_rec(
											x_attr_group_tab(j).ATTR_GROUP_TYPE,
											x_attr_group_tab(j).ATTR_GROUP_NAME,
											l_ext_id_array(k),
											l_attribute_tab(p).ATTR_NAME,
											l_attribute_tab(p).ATTR_DISPLAY_NAME,
											l_attribute_tab(p).DESCRIPTION,
											l_x_display_value,
											l_x_display_type,
											l_x_dynamic_url,
											l_attribute_tab(p).SEQUENCE);
				END LOOP;
			END LOOP;

			/*if there is no ext row for this attribute group, we still return the attribute names without any value*/
			IF l_ext_id_array IS NULL OR l_ext_id_array.COUNT = 0 THEN
				FOR p in 1 .. l_attribute_tab.COUNT
				LOOP
					IF x_attribute_tab IS NULL THEN
						x_attribute_tab := new rrs_attribute_tab();
					END IF;
					x_attribute_tab.EXTEND();
					l_display_type_code := 'T of C'; -- dummy display type
					--Bug Fix 9453429: Need consider the Hidden Data Type even for the empty attribute group
					IF l_attribute_tab(p).DISPLAY_CODE = 'H' THEN
						l_display_type_code := 'H of C';
					END IF;
					x_attribute_tab(x_attribute_tab.LAST) := new rrs_attribute_rec(
												x_attr_group_tab(j).ATTR_GROUP_TYPE,
												x_attr_group_tab(j).ATTR_GROUP_NAME,
												NULL, 					-- ext_id
												l_attribute_tab(p).ATTR_NAME,
												l_attribute_tab(p).ATTR_DISPLAY_NAME,
												l_attribute_tab(p).DESCRIPTION,
												NULL,					-- display value
												l_display_type_code,
												NULL,
												l_attribute_tab(p).SEQUENCE);
				END LOOP;
			END IF;
		END LOOP;
        END LOOP;


EXCEPTION
	WHEN e_no_uda THEN
		Record_Error('e_no_uda: ' || p_object_type || ' does not have UDA.', x_error_messages);
	WHEN e_no_page_found THEN
		Record_Error('e_no_page_found', x_error_messages);
	WHEN e_no_page_entry_found THEN
		Record_Error('e_no_page_entry_found', x_error_messages);
	WHEN e_no_attr_group_found THEN
		Record_Error('e_no_attr_group_found', x_error_messages);
	WHEN e_no_ext_row_found THEN
		Record_Error('e_no_ext_row_found', x_error_messages);
	WHEN e_no_attribute_found THEN
		Record_Error('e_no_attribute_found', x_error_messages);
	WHEN OTHERS THEN
		Record_Error('Get_Attribute_Group_Page: ' || dbms_utility.format_error_backtrace, x_error_messages);
		--DBMS_OUTPUT.PUT_LINE('Other exceptions in Get_Attribute_Page');
		--dbms_output.put_line(dbms_utility.format_error_backtrace);
END;


PROCEDURE Get_Display_Value
(
	p_object_type		IN		VARCHAR2,
	p_object_id		IN		NUMBER,
	p_attr_group_type	IN		VARCHAR2,
	p_attr_group_name	IN		VARCHAR2,
	p_attr_name 		IN		VARCHAR2,
	p_ext_id		IN		NUMBER,
	x_display_value		OUT NOCOPY	VARCHAR2,
	x_display_type		OUT NOCOPY	VARCHAR2,
	x_dynamic_url		OUT NOCOPY	VARCHAR2,
	x_error_messages	OUT NOCOPY 	rrs_error_msg_tab
) IS


l_query			VARCHAR2(2000);

l_ext_table_name	VARCHAR2(200);
l_pk_name		VARCHAR2(30);
l_attr_group_id		EGO_ATTR_GROUPS_V.ATTR_GROUP_ID%TYPE;

l_attr_info		attr_info_rec;
l_code_value		VARCHAR2(1000);
l_date_value		DATE;

l_uom_code		RRS_SITES_EXT_VL.UOM_EXT_ATTR1%TYPE;
l_uom			MTL_UNITS_OF_MEASURE_VL.UNIT_OF_MEASURE_TL%TYPE;
l_uom_conversion_rate	MTL_UOM_CONVERSIONS.CONVERSION_RATE%TYPE;

l_index			NUMBER := 1;
l_dynamic_url		EGO_ATTRS_V.INFO_1%TYPE;
l_url_value		EGO_ATTRS_V.INFO_1%TYPE;
l_url_tokens		array_of_string := new array_of_string();

l_x_display_value	VARCHAR2(1000);
l_x_display_type	VARCHAR2(200);
l_x_dynamic_url		VARCHAR2(1000);

/*For Table Value Set query*/
l_app_table_name	FND_FLEX_VALIDATION_TABLES.APPLICATION_TABLE_NAME%TYPE;
l_value_column_name	FND_FLEX_VALIDATION_TABLES.VALUE_COLUMN_NAME%TYPE;
l_value_column_type	FND_FLEX_VALIDATION_TABLES.VALUE_COLUMN_TYPE%TYPE;
l_id_column_name	FND_FLEX_VALIDATION_TABLES.ID_COLUMN_NAME%TYPE;
l_add_where_clause	FND_FLEX_VALIDATION_TABLES.ADDITIONAL_WHERE_CLAUSE%TYPE;
l_add_where_clause_holder	l_add_where_clause%TYPE;

l_date_format_mask	VARCHAR2(100);

--Bug Fix for Bug 9012596 - jijiao 10/15/2009
l_dep_attr_name		EGO_ATTRS_V.ATTR_NAME%TYPE;
l_start_index		NUMBER;
l_next_space_index      NUMBER;
l_dep_column		EGO_ATTRS_V.DATABASE_COLUMN%TYPE;
l_dep_data_type		EGO_ATTRS_V.DATA_TYPE_CODE%TYPE;
l_dep_code_value	VARCHAR2(1000);
l_dep_date_value	DATE;

BEGIN

--DBMS_OUTPUT.PUT_LINE('p_object_type: ' || p_object_type);
/* decide which object type we are processing*/
IF UPPER(p_object_type) = 'SITE' THEN
	l_ext_table_name := 'RRS_SITES_EXT_VL';
	l_pk_name := 'SITE_ID';
ELSIF UPPER(p_object_type) = 'LOCATION' THEN
	l_ext_table_name := 'RRS_LOCATIONS_EXT_VL';
	l_pk_name := 'LOCATION_ID';
ELSIF UPPER(p_object_type) = 'TRADE AREA' THEN
	l_ext_table_name := 'RRS_TRADE_AREAS_EXT_VL';
	l_pk_name := 'TRADE_AREA_ID';
ELSIF UPPER(p_object_type) = 'HIERARCHY' THEN
	l_ext_table_name := 'RRS_HIERARCHIES_EXT_VL';
	l_pk_name := 'SITE_GROUP_VERSION_ID';
END IF;

--DBMS_OUTPUT.PUT_LINE('l_ext_table_name: ' || l_ext_table_name);
--DBMS_OUTPUT.PUT_LINE('l_attr_group_name: ' || p_attr_group_type);

/* query for database column set up for the attribute*/
BEGIN
--DBMS_OUTPUT.PUT_LINE('p_attr_group_type: ' || p_attr_group_type);
--DBMS_OUTPUT.PUT_LINE('p_attr_group_name: ' || p_attr_group_name);
--DBMS_OUTPUT.PUT_LINE('p_attr_name: ' || p_attr_name);

	--Bug Fix 8989777 - jijiao 10/12/2009
	--Need add Attribute Group Type to the where clause to handle the Same Attribute Group Names for the different Attribute Group Types
	BEGIN
		SELECT DATABASE_COLUMN, DATA_TYPE_CODE, INFO_1, UOM_CLASS, VALUE_SET_ID, VALIDATION_CODE, DISPLAY_CODE, DISPLAY_MEANING
		  INTO l_attr_info
		  FROM EGO_ATTRS_V
		 WHERE APPLICATION_ID = 718
		   AND ATTR_GROUP_TYPE = p_attr_group_type
		   AND ATTR_GROUP_NAME = p_attr_group_name
		   AND ATTR_NAME = p_attr_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			Record_Error('Get_Display_Value: No Display Value is found.', x_error_messages);
		WHEN OTHERS THEN
			Record_Error('Get_Display_Value: When getting display value, get '|| sqlcode ||': '||sqlerrm, x_error_messages);
	END;
--DBMS_OUTPUT.PUT_LINE('l_database_column: ' || l_attr_info.value_set_id);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		Record_Error('Get_Display_Value: No attribute was found for ' || p_attr_group_type || ' ' || p_attr_group_name || '.', x_error_messages);
		RAISE e_no_attribute_found;
END;


/* query attribute group id */
BEGIN
	SELECT ATTR_GROUP_ID
	  INTO l_attr_group_id
	  FROM EGO_ATTR_GROUPS_V
	 WHERE APPLICATION_ID = 718
	   AND ATTR_GROUP_TYPE = p_attr_group_type
	   AND ATTR_GROUP_NAME = p_attr_group_name;
--DBMS_OUTPUT.PUT_LINE('l_attr_group_id: ' || l_attr_group_id);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		Record_Error('Get_Display_Value: No attribute group was found for attribute group name ' || p_attr_group_name || '.', x_error_messages);
		RAISE e_no_attr_group_found;
END;


/* query the code value*/
BEGIN
	/*For Date or DateTime Attributes, we need maintain the DATE data type to keep the full date/time infomation*/
	IF l_attr_info.data_type_code = 'X' OR l_attr_info.data_type_code = 'Y' THEN
		l_query := 'SELECT ' || l_attr_info.database_column ||
		    	    ' FROM ' || l_ext_table_name ||
		   	   ' WHERE ' || l_pk_name || ' = :1' ||
		   	     ' AND ATTR_GROUP_ID = :2' ||
		   	     ' AND EXTENSION_ID = :3';
		EXECUTE IMMEDIATE l_query INTO l_date_value USING p_object_id, l_attr_group_id, p_ext_id;
	/* for Numeric Attribute, we need consider UOM*/
	ElSIF l_attr_info.uom_class IS NOT NULL THEN
		l_query := 'SELECT ' || l_attr_info.database_column || ', ' || REPLACE(l_attr_info.database_column, 'N', 'UOM') ||
		    	    ' FROM ' || l_ext_table_name ||
		   	   ' WHERE ' || l_pk_name || ' = :1' ||
		   	     ' AND ATTR_GROUP_ID = :2' ||
		   	     ' AND EXTENSION_ID = :3';
		EXECUTE IMMEDIATE l_query INTO l_code_value, l_uom_code USING p_object_id, l_attr_group_id, p_ext_id;
		--DBMS_OUTPUT.PUT_LINE(l_attr_info.database_column);
		--DBMS_OUTPUT.PUT_LINE(l_code_value || ' ' || l_uom_code);

	ELSE
		l_query := 'SELECT ' || l_attr_info.database_column ||
		    	    ' FROM ' || l_ext_table_name ||
		   	   ' WHERE ' || l_pk_name || ' = :1' ||
		   	     ' AND ATTR_GROUP_ID = :2' ||
		   	     ' AND EXTENSION_ID = :3';
		--DBMS_OUTPUT.PUT_LINE(l_query);
		EXECUTE IMMEDIATE l_query INTO l_code_value USING p_object_id, l_attr_group_id, p_ext_id;
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		Record_Error('Get_Display_Value: No extension row was found for Extension Id ' || p_ext_id || '.', x_error_messages);
		RAISE e_no_ext_row_found;
END;

/* Can I say: Because only Numeric Attribute can have UOM, so the attribute has UOM is Numeric.
	      And because the Numeric Value Set's value code will be identifcal with the value meaning,
	      so for the attribute with UOM I do not need consider Value Set issue, but just directly display the value stored in N_EXT_ATTR column of the EXT table?*/
IF l_attr_info.data_type_code = 'N' AND l_uom_code IS NOT NULL THEN
	/* NEED CONVERT The Numberic Value stored in N_EXT_ATTR column from the BASE UOM to the UOM user input*/
	BEGIN
		/* query for the translated uom meaning*/
		SELECT UNIT_OF_MEASURE_TL
		  INTO l_uom
		  FROM MTL_UNITS_OF_MEASURE_VL
		 WHERE UOM_CODE = l_uom_code;

		/* query for the uom conversion rate*/
		SELECT CONVERSION_RATE
		  INTO l_uom_conversion_rate
		  FROM MTL_UOM_CONVERSIONS
		  WHERE UOM_CODE = l_uom_code;

		--DBMS_OUTPUT.PUT_LINE(l_uom_conversion_rate);

		/* construct the display value at the proper uom*/
		SELECT ((l_code_value / l_uom_conversion_rate) || ' ' || l_uom)
		  INTO x_display_value
		  FROM DUAL;
		--Bug 9247705: Use display_code rather than display_meaning.
		x_display_type := l_attr_info.display_code || ' of ' || l_attr_info.data_type_code || ' with UOM';

		--DBMS_OUTPUT.PUT_LINE(x_display_value || ' is displayed as ' || x_display_type);
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			Record_Error('Get_Display_Value: No Unit Of Measure was found for the UOM Code ' || l_uom_code || '.', x_error_messages);
			RAISE e_no_uom_found;
	END;
-- Bug 9247705: Use display_code rather than display_meaning.
-- T	Text Field
-- A	Attachment
-- D	Dynamic URL
-- L	Text Area
-- S	Static URL
-- C	Checkbox
-- H	Hidden
-- R	Radio Group
ELSIF l_attr_info.display_code = 'D' THEN
	/* NEED QUERY The Display Value for the TOKEN. For the Numeric Value with UOM, we only need the Numeric Value, but need conert the value from BASE UOM to the UOM user input*/
	BEGIN
		l_dynamic_url := l_attr_info.info_1;
		LOOP
			-- NO dollar sign found - no token in the url
			EXIT WHEN (INSTR(l_dynamic_url, '$', 1, l_index) = 0);
			l_index := l_index + 1;
			l_url_tokens.EXTEND;
			l_url_tokens(l_url_tokens.LAST) := SUBSTR(l_dynamic_url, INSTR(l_dynamic_url, '$', 1, l_index-1) + 1,
					     			  INSTR(l_dynamic_url, '$', 1, l_index) - INSTR(l_dynamic_url, '$', 1, l_index-1) -1
					    				       );
			--DBMS_OUTPUT.PUT_LINE(l_url_tokens(l_url_tokens.LAST));

			Get_Display_Value(p_object_type,
					  p_object_id,
					  p_attr_group_type,
					  p_attr_group_name,
					  l_url_tokens(l_url_tokens.LAST),
					  p_ext_id,
					  l_x_display_value,
					  l_x_display_type,
					  l_x_dynamic_url,
					  x_error_messages);

			--DBMS_OUTPUT.PUT_LINE(l_x_display_value);
			/*if there is UOM with the Numeric value, then we need get rid of the UOM, because in the Dynamic URL, we only use the EXT_ATTR value to take place of the token*/
			IF INSTR(l_x_display_type, 'N with UOM') > 0 THEN
				l_dynamic_url := REPLACE(l_dynamic_url, '$'||(l_url_tokens(l_url_tokens.LAST))||'$', SUBSTR(l_x_display_value, 1, INSTR(l_x_display_value, ' ')-1));
			ELSE
				l_dynamic_url := REPLACE(l_dynamic_url, '$'||(l_url_tokens(l_url_tokens.LAST))||'$', l_x_display_value);
			END IF;

			l_index := 1;
		END LOOP;

		x_display_value := l_code_value;
		--Bug 9247705: Use display_code rather than display_meaning.
		x_display_type := l_attr_info.display_code || ' of ' || l_attr_info.data_type_code;
		x_dynamic_url := l_dynamic_url;

		--DBMS_OUTPUT.PUT_LINE('x_display_value: ' || x_display_value);
		--DBMS_OUTPUT.PUT_LINE('x_display_type: ' || x_display_type);
		--DBMS_OUTPUT.PUT_LINE('x_dynamic_url: ' || x_dynamic_url);
	END;

/*The attribute with value set*/
ELSIF l_attr_info.value_set_id IS NOT NULL THEN
	BEGIN
	/*For the regular independent value set, we direclty reutrn FLEX_VALUE stored in EXT_ATTR column*/
	IF l_attr_info.validation_code = 'I' THEN
		 /*If the attribute is DATE type, we need convert the format*/
		IF l_attr_info.data_type_code = 'X' OR l_attr_info.data_type_code = 'Y' THEN

			SELECT FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')
			INTO l_date_format_mask
			FROM DUAL;

			IF l_attr_info.data_type_code = 'Y' THEN
				l_date_format_mask := l_date_format_mask || ' HH24:MI:SS';
			END IF;

			x_display_value := TO_CHAR(l_date_value, l_date_format_mask);
		ELSE
			x_display_value := l_code_value;
		END IF;

	/*For the translatable value set, we return FLEX_VALUE_MEANING*/
	ELSIF l_attr_info.validation_code = 'X' THEN
		BEGIN
		 	/*If the attribute is DATE type, we need convert the format*/
			IF (l_attr_info.data_type_code = 'X' OR l_attr_info.data_type_code = 'Y') AND l_date_value IS NOT NULL THEN
				SELECT FLEX_VALUE_MEANING
				  INTO x_display_value
				  FROM FND_FLEX_VALUES_VL
				 WHERE FLEX_VALUE_SET_ID = l_attr_info.value_set_id
				   AND FLEX_VALUE = l_date_value;

				SELECT FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')
				INTO l_date_format_mask
				FROM DUAL;

				IF l_attr_info.data_type_code = 'Y' THEN
					l_date_format_mask := l_date_format_mask || ' HH24:MI:SS';
				END IF;

				x_display_value := TO_CHAR(x_display_value, l_date_format_mask);
				--Bug 9247705: Use display_code rather than display_meaning.
				x_display_type := l_attr_info.display_code || ' of ' || l_attr_info.data_type_code;
			ELSIF l_code_value IS NOT NULL THEN
				SELECT FLEX_VALUE_MEANING
				  INTO x_display_value
				  FROM FND_FLEX_VALUES_VL
				 WHERE FLEX_VALUE_SET_ID = l_attr_info.value_set_id
				   AND FLEX_VALUE = l_code_value;
			END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RAISE e_no_value_set_value_found;
			WHEN OTHERS THEN
				Record_Error('Get_Display_Value: ' || dbms_utility.format_error_backtrace, x_error_messages);
		END;
	/*For the table value set, we assemble the query to get the value from the target table*/
	ELSIF l_attr_info.validation_code = 'F' THEN
		SELECT APPLICATION_TABLE_NAME, VALUE_COLUMN_NAME,
		       VALUE_COLUMN_TYPE, ID_COLUMN_NAME, ADDITIONAL_WHERE_CLAUSE
		  INTO l_app_table_name, l_value_column_name,
		       l_value_column_type, l_id_column_name, l_add_where_clause
		  FROM FND_FLEX_VALIDATION_TABLES
		 WHERE FLEX_VALUE_SET_ID = l_attr_info.value_set_id;

		 IF l_add_where_clause IS NOT NULL THEN
		 	-- use l_add_where_clause_holder as an index ruler for the l_add_where_clause
		 	-- because we cannot predict what user will enter. There could be no WHERE in Where Clause or different combination of capitalization
		 	-- We cannot simply UPPER the original l_add_where_clause, because that will modify the original dependent attribute name, which is CASE SENSITIVE.
		 	-- But the $ATTRIBUTEGROUP$ has to be all UPPER case, otherwise OA page will also error out.
		 	l_add_where_clause_holder := UPPER(l_add_where_clause);
		 	IF INSTR(l_add_where_clause_holder, 'WHERE') > 0 THEN
		 		l_add_where_clause := SUBSTR(l_add_where_clause, INSTR(l_add_where_clause_holder, 'WHERE') + 6);
		 		-- keep consistency between original l_add_where_clause and index ruler l_add_where_clause_holder
		 		l_add_where_clause_holder := SUBSTR(l_add_where_clause_holder, INSTR(l_add_where_clause_holder, 'WHERE') + 6);
		 	END IF;
                        --DBMS_OUTPUT.PUT_LINE(l_add_where_clause);
                        --DBMS_OUTPUT.PUT_LINE(l_add_where_clause_holder);
		 	--Bug Fix for Bug 9029322 - jijiao 10/15/2009
		 	--Need handle the DEPENDENT value set, which is depends on another attributes in the same attribute group
		 	IF INSTR(l_add_where_clause, ':$ATTRIBUTEGROUP$') > 0 THEN
		 		l_start_index := INSTR(l_add_where_clause, ':$ATTRIBUTEGROUP$.') + 18;
		 		l_next_space_index := INSTR(l_add_where_clause, ' ', INSTR(l_add_where_clause, ':$ATTRIBUTEGROUP$'), 1);

		 		IF l_next_space_index > 0 THEN
		 			l_dep_attr_name := SUBSTR(l_add_where_clause, l_start_index, (l_next_space_index - l_start_index));
		 		ELSE
					--if the dependent value is written at the end of the Where Clause
		 			l_dep_attr_name := SUBSTR(l_add_where_clause, l_start_index, LENGTH(l_add_where_clause) - l_start_index + 1);
		 		END IF;
		 		--DBMS_OUTPUT.PUT_LINE('l_next_space_index: ' || l_next_space_index);
		 		--DBMS_OUTPUT.PUT_LINE('l_dep_attr_name: ' || l_dep_attr_name);

				BEGIN
                               		SELECT DATABASE_COLUMN, DATA_TYPE_CODE
                                	  INTO l_dep_column, l_dep_data_type
                                  	  FROM EGO_ATTRS_V
                                 	 WHERE APPLICATION_ID = 718
                                   	   AND ATTR_GROUP_TYPE = p_attr_group_type
                                   	   AND ATTR_GROUP_NAME = p_attr_group_name
                                   	   AND ATTR_NAME = l_dep_attr_name;
	   			EXCEPTION
	   			   	WHEN NO_DATA_FOUND THEN
	   			   		Record_Error('Get_Display_Value: Dependent Attribute is not found', x_error_messages);
	   			   	WHEN OTHERS THEN
	   			   		Record_Error('Other exception'||sqlerrm||' and code '||sqlcode, x_error_messages);
	   		        END;

	   			l_query := 'SELECT ' || l_dep_column ||
	   				   '  FROM ' || l_ext_table_name ||
					   ' WHERE ' || l_pk_name || ' = :1' ||
					     ' AND ATTR_GROUP_ID = :2' ||
					     ' AND EXTENSION_ID = :3';
                                --DBMS_OUTPUT.PUT_LINE(l_query);
				IF l_dep_data_type = 'X' OR l_dep_data_type = 'Y' THEN
					EXECUTE IMMEDIATE l_query INTO l_dep_date_value USING p_object_id, l_attr_group_id, p_ext_id;
					IF l_dep_date_value IS NOT NULL THEN
						-- For the dependent value set that depends on a Date type value set, in the query, we need explictly convert the CHAR type of date value TO DATE.
						l_add_where_clause := REPLACE(l_add_where_clause, ':$ATTRIBUTEGROUP$.' || l_dep_attr_name, 'TO_DATE(''' || l_dep_date_value || ''')');
					ELSE
						IF INSTR(l_add_where_clause, '= :$ATTRIBUTEGROUP$.') > 0 THEN
							l_add_where_clause := REPLACE(l_add_where_clause, '= :$ATTRIBUTEGROUP$.' || l_dep_attr_name, ' IS NULL');
						ELSIF INSTR(l_add_where_clause, '=:$ATTRIBUTEGROUP$.') > 0 THEN
							l_add_where_clause := REPLACE(l_add_where_clause, '=:$ATTRIBUTEGROUP$.' || l_dep_attr_name, ' IS NULL');
						END IF;
					END IF;

				ELSE
					EXECUTE IMMEDIATE l_query INTO l_dep_code_value USING p_object_id, l_attr_group_id, p_ext_id;
					IF l_dep_code_value IS NOT NULL THEN
                                                -- Bug Fix 9029322 - If the dependent value is CHAR, we have to put single quotes around the value in the query condition.
                                                -- Actually here we also embrace Number by the single quotes, but SQL compiler will do the convertion for us. - jijiao 12/5/2009
						l_add_where_clause := REPLACE(l_add_where_clause, ':$ATTRIBUTEGROUP$.' || l_dep_attr_name, '''' || l_dep_code_value || '''');
					ELSE
						IF INSTR(l_add_where_clause, '= :$ATTRIBUTEGROUP$.') > 0 THEN
							l_add_where_clause := REPLACE(l_add_where_clause, '= :$ATTRIBUTEGROUP$.' || l_dep_attr_name, ' IS NULL');
						ELSIF INSTR(l_add_where_clause, '=:$ATTRIBUTEGROUP$.') > 0 THEN
							l_add_where_clause := REPLACE(l_add_where_clause, '=:$ATTRIBUTEGROUP$.' || l_dep_attr_name, ' IS NULL');
						END IF;
					END IF;

				END IF;
		 		--DBMS_OUTPUT.PUT_LINE('l_add_where_clause: ' || l_add_where_clause);

		 	END IF;

		 	-- Bug Fix 9029322, Need handle the case where user does not define ID COLUMN for the value set.
			IF l_id_column_name IS NOT NULL THEN
				l_query := 'SELECT ' || l_value_column_name ||
				    '  FROM ' || l_app_table_name ||
				    ' WHERE ' || l_id_column_name || ' = :1' ||
				    '   AND ' || l_add_where_clause;
			ELSE
				l_query := 'SELECT ' || l_value_column_name ||
				    '  FROM ' || l_app_table_name ||
				    ' WHERE ' || l_add_where_clause;
			END IF;
			--DBMS_OUTPUT.PUT_LINE(l_add_where_clause);
			--DBMS_OUTPUT.PUT_LINE(l_query);
		 -- Bug Fix for Bug 9012596 - jijiao 10/12/2009
		 -- Need handle the case there is no Additional Where Clause
		 -- ALSO NEED HANDLE NO ID COLUMN - THE POPLIST VALUE SET CASE! - jijiao 10/16/2009
		 ELSIF l_id_column_name IS NOT NULL THEN
			 l_query := 'SELECT ' || l_value_column_name ||
				    '  FROM ' || l_app_table_name ||
				    ' WHERE ' || l_id_column_name || ' = :1';
		 -- End of Bug Fix
		 END IF;
		 /*If the attribute is DATE type, we need convert the format*/
		 -- Bug Fix for Bug 9012630 - jijiao 10/12/2009
		 -- Need handle the  l_date_value is NULL case, which means there is no value for this  Value Set attribute
		 IF (l_attr_info.data_type_code = 'X' OR l_attr_info.data_type_code = 'Y') AND l_date_value IS NOT NULL THEN
			 -- Bug Fix for Bug 9012596
			 -- ALSO NEED HANDLE NO ID COLUMN - THE POPLIST VALUE SET CASE! - jijiao 10/16/2009
		 	IF l_id_column_name IS NOT NULL THEN
		 		EXECUTE IMMEDIATE l_query INTO x_display_value USING l_date_value;
		 	ELSE
		 		-- for the POPLIST value set, the display value is stored directly in the EXT TABLE
		 		x_display_value := l_date_value;
		 	END IF;
		 	SELECT FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')
				INTO l_date_format_mask
				FROM DUAL;

				IF l_attr_info.data_type_code = 'Y' THEN
					l_date_format_mask := l_date_format_mask || ' HH24:MI:SS';
				END IF;
			x_display_value := TO_CHAR(x_display_value, l_date_format_mask);
		 -- Bug Fix for Bug 9012630 - jijiao 10/12/2009
		 -- Need handle the  l_code_value is NULL case, which means there is no value for this  Value Set attribute
		 ELSIF l_code_value IS NOT NULL THEN
		 	BEGIN
                                 --DBMS_OUTPUT.PUT_LINE(l_query);

				 -- Bug Fix for Bug 9012596
				 -- ALSO NEED HANDLE NO ID COLUMN - THE POPLIST VALUE SET CASE! - jijiao 10/16/2009
		 		IF l_id_column_name IS NOT NULL THEN
		 			EXECUTE IMMEDIATE l_query INTO x_display_value USING l_code_value;
		 		ELSE
		 			-- for the POPLIST value set, the display value is stored directly in the EXT TABLE
		 			x_display_value := l_code_value;
		 		END IF;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					Record_Error('Get_Display_Value: No Display Value is found.', x_error_messages);
				WHEN OTHERS THEN
					Record_Error('Get_Display_Value: When getting display value, get '|| sqlcode ||': '||sqlerrm, x_error_messages);
			END;

		END IF;
	-- Bug Fix for 9098853 - jijiao 11/11/2009
	-- Need deal with None Validation explicitly.  For the None Vadilation Type, because here we only retrieve and display the UDA data
	-- we can assume the data has been passed the None Vadlidation, such as the Maximum/minimum length.
	-- And once the attribute is associated with None Validation Type value set, it can only be the simple type, which no need to lookup any Independent/Table value set anymore
	-- For the only special case which is Number with UOM, it has been handled at the beginning of this procedure, Number with UOM case.
	/*Do nothing for the None Validation Type*/
	ELSIF l_attr_info.validation_code = 'N' THEN
		--DATE OR DATETIME data type
		IF (l_attr_info.data_type_code = 'X' OR l_attr_info.data_type_code = 'Y') AND l_date_value IS NOT NULL THEN
		      SELECT FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')
			INTO l_date_format_mask
			FROM DUAL;

			IF l_attr_info.data_type_code = 'Y' THEN
				l_date_format_mask := l_date_format_mask || ' HH24:MI:SS';
			END IF;
			x_display_value := TO_CHAR(l_date_value, l_date_format_mask);
		-- CHAR data type
		ELSIF l_code_value IS NOT NULL THEN
			x_display_value := l_code_value;
		END IF;

	END IF;
	--Bug 9247705: Use display_code rather than display_meaning.
	x_display_type := l_attr_info.display_code || ' of ' || l_attr_info.data_type_code;

	EXCEPTION
		WHEN e_invalid_where_clause THEN
			Record_Error('Invalid WHERE Clause defined in Dependent Value Set.', x_error_messages);
		WHEN OTHERS THEN
			Record_Error('Get_Display_Value: ' || dbms_utility.format_error_backtrace, x_error_messages);
	END;

/*For the DATE or DATETIME data types, the value stored in EXT table is the same as the value in value set meaning column*/
/*What we need to do is to format the date value into the right format for the environment the user is in*/
ELSIF l_attr_info.data_type_code = 'X' OR l_attr_info.data_type_code = 'Y' THEN

	SELECT FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')
	INTO l_date_format_mask
	FROM DUAL;

	IF l_attr_info.data_type_code = 'Y' THEN
		l_date_format_mask := l_date_format_mask || ' HH24:MI:SS';
	END IF;
	--DBMS_OUTPUT.PUT_LINE(l_date_format_mask);
	--DBMS_OUTPUT.PUT_LINE(l_code_value);
	x_display_value := TO_CHAR(l_date_value, l_date_format_mask);
	--DBMS_OUTPUT.PUT_LINE(x_display_value);
	--Bug 9247705: Use display_code rather than display_meaning.
	x_display_type := l_attr_info.display_code || ' of ' || l_attr_info.data_type_code;

/*For the rest cases, we just display as the value is in EXT table*/
ELSE
	x_display_value := l_code_value;
	--Bug 9247705: Use display_code rather than display_meaning.
	x_display_type := l_attr_info.display_code || ' of ' || l_attr_info.data_type_code;

END IF;

		--DBMS_OUTPUT.PUT_LINE('x_display_value: ' || x_display_value);
		--DBMS_OUTPUT.PUT_LINE('x_display_type: ' || x_display_type);
		--DBMS_OUTPUT.PUT_LINE('x_dynamic_url: ' || x_dynamic_url);



EXCEPTION
	WHEN e_no_attribute_found THEN
		Record_Error('e_no_attribute_found', x_error_messages);
	WHEN e_no_attr_group_found THEN
		Record_Error('e_no_attr_group_found', x_error_messages);
	WHEN e_no_ext_row_found THEN
		Record_Error('e_no_ext_row_found', x_error_messages);
	WHEN e_no_uom_found THEN
		Record_Error('e_no_uom_found', x_error_messages);
	WHEN e_no_value_set_value_found THEN
		Record_Error('e_no_value_set_value_found', x_error_messages);
	WHEN OTHERS THEN
		Record_Error('Get_Display_Value: ' || dbms_utility.format_error_backtrace, x_error_messages);
END;


--Added for Bug Fix 6969229
Procedure Get_Display_Value
(
	p_object_type		IN		VARCHAR2,
	p_object_id		IN		NUMBER,
	p_attr_group_id		IN		NUMBER,
	p_ext_id		IN		NUMBER,
	p_column_name 		IN		VARCHAR2,
	x_display_value		OUT NOCOPY	VARCHAR2,
	x_msg_data		OUT NOCOPY 	VARCHAR2
) IS

l_object_type_val	VARCHAR2(30);	-- convert to the object type value that consumed by RRS_ATTR_PANE.Get_Display_Value
l_attr_group_type	VARCHAR2(30);
l_attr_group_name	VARCHAR2(30);
l_attr_name		VARCHAR2(30);
l_x_display_value	VARCHAR2(1000);
l_x_display_type	VARCHAR2(200);
l_x_dynamic_url		VARCHAR2(1000);
l_x_error_messages	rrs_error_msg_tab;

BEGIN
	-- convert to the object type value that consumed by RRS_ATTR_PANE.Get_Display_Value
	IF p_object_type = 'RRS_SITE' THEN
		l_object_type_val := 'SITE';
	ELSIF p_object_type = 'RRS_LOCATION' THEN
		l_object_type_val := 'LOCATION';
	ELSIF p_object_type = 'RRS_TRADE_AREA' THEN
		l_object_type_val := 'TRADE AREA';
	ELSIF p_object_type = 'RRS_HIERARCHY' THEN
		l_object_type_val := 'HIERARCHY';
	END IF;

	-- convert attribute group id to attribute group name
	SELECT ATTR_GROUP_TYPE, ATTR_GROUP_NAME
	  INTO l_attr_group_type, l_attr_group_name
	  FROM EGO_ATTR_GROUPS_V
	 WHERE ATTR_GROUP_ID = p_attr_group_id;

	-- query the corresponding attribute name of the data column name
	SELECT ATTR_NAME
	  INTO l_attr_name
	  FROM EGO_ATTRS_V
	 WHERE APPLICATION_ID = 718
	   AND ATTR_GROUP_TYPE = l_attr_group_type
	   AND ATTR_GROUP_NAME = l_attr_group_name
	   AND DATABASE_COLUMN = p_column_name;

	-- invoke the RRS_ATTR_PANE.Get_Display_Value
	Get_Display_Value(l_object_type_val,
			  p_object_id,
			  l_attr_group_type,
			  l_attr_group_name,
			  l_attr_name,
			  p_ext_id,
			  l_x_display_value,
			  l_x_display_type,
			  l_x_dynamic_url,
		  	  l_x_error_messages);

	-- strip the UOM from the display value for the Number type
	IF INSTR(p_column_name, 'N') = 1 AND INSTR(l_x_display_value, ' ') <> 0 THEN
		x_display_value := SUBSTR(l_x_display_value, 1, INSTR(l_x_display_value, ' ') - 1);
	ELSE
		x_display_value := l_x_display_value;
	END IF;

	IF l_x_error_messages IS NOT NULL AND l_x_error_messages.COUNT > 0 THEN
		x_msg_data := l_x_error_messages(0);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_msg_data := 'Get_Display_Value: No data found with ' ||
				p_object_type || ', ' || p_object_id || ', ' || p_attr_group_id || ', ' ||
				p_ext_id || ', ' || p_column_name || '.';
	WHEN OTHERS THEN
		x_msg_data := 'Get_Display_Value: Unexcepted Error - ' || dbms_utility.format_error_backtrace;
END Get_Display_Value;


/*Record the Errors*/
PROCEDURE Record_Error
(
	p_error_message		IN		VARCHAR2,
	x_error_messages	OUT NOCOPY	rrs_error_msg_tab
) IS

BEGIN
	IF x_error_messages IS NULL THEN
		x_error_messages := new rrs_error_msg_tab();
	END IF;
	x_error_messages.EXTEND();
	x_error_messages(x_error_messages.LAST) := p_error_message;
END;


/*TEST METHODS*/
/*
PROCEDURE TEST IS
x_display_value VARCHAR2(1000);
x_display_type VARCHAR2(200);
x_dynamic_url VARCHAR2(1000);

x_ag_page_tab		rrs_attr_group_page_tab;
x_attr_group_tab	rrs_attribute_group_tab;
x_attribute_tab		rrs_attribute_tab;

x_primary_attributes	rrs_primary_attribute_rec;
x_error_data		VARCHAR2(1000);
x_error_messages	rrs_error_msg_tab;

BEGIN

	Get_Display_Value('RRS_SITE',
			  12860,
			  1529,
			  83153,
			  'C_EXT_ATTR9',
			  x_display_value,
			  x_error_data);
	DBMS_OUTPUT.PUT_LINE('x_display_value: ' || x_display_value);
	DBMS_OUTPUT.PUT_LINE('x_error_data: ' || x_error_data);


	Get_Display_Value('SITE',
			  12860,
			  'RRS_SITEMGMT_GROUP',
			  'MBOX_ATTRIBUTES',
			  'SITE_CREATED_BY_DATE',
			  83153,
			  x_display_value,
			  x_display_type,
			  x_dynamic_url,
			  x_error_messages);


	DBMS_OUTPUT.PUT_LINE('x_display_value: ' || x_display_value);
	DBMS_OUTPUT.PUT_LINE('x_display_type: ' || x_display_type);
	IF x_error_messages IS NOT NULL AND x_error_messages.COUNT > 0 THEN
		DBMS_OUTPUT.PUT_LINE(x_error_messages.COUNT);
		FOR i in 1 .. x_error_messages.COUNT
		LOOP
			DBMS_OUTPUT.PUT_LINE(x_error_messages(i));
		END LOOP;
        END IF;

	Get_Attribute_Page('HIERARCHY',
	                         'SITE',
	                         10317,
	                         'HIERARCHY',
	                          'ROOT',
	                          'SITE',
	                          'MAIL',
	                         x_primary_attributes,
	                         x_ag_page_tab,
	                         x_attr_group_tab,
	                         x_attribute_tab,
	                         x_error_messages);


	DBMS_OUTPUT.PUT_LINE('Primary Attributes');
	DBMS_OUTPUT.PUT_LINE('============================');
	DBMS_OUTPUT.PUT_LINE(x_primary_attributes.OBJECT_ID);
	DBMS_OUTPUT.PUT_LINE(x_primary_attributes.OBJECT_IDENTIFICATION_NUMBER);
	DBMS_OUTPUT.PUT_LINE(x_primary_attributes.OBJECT_NAME);
	DBMS_OUTPUT.PUT_LINE(x_primary_attributes.CLASSIFICATION);
	DBMS_OUTPUT.PUT_LINE(x_primary_attributes.DESCRIPTION);
	DBMS_OUTPUT.PUT_LINE(x_primary_attributes.SITE_TYPE);
	DBMS_OUTPUT.PUT_LINE(x_primary_attributes.STATUS);
	DBMS_OUTPUT.PUT_LINE(x_primary_attributes.START_DATE);
	DBMS_OUTPUT.PUT_LINE(x_primary_attributes.END_DATE);
	DBMS_OUTPUT.PUT_LINE(x_primary_attributes.ADDRESS);
	DBMS_OUTPUT.PUT_LINE(x_primary_attributes.COUNTRY);
	DBMS_OUTPUT.PUT_LINE(x_primary_attributes.GROUP_TYPE);
	DBMS_OUTPUT.PUT_LINE(x_primary_attributes.UNIT_OF_MEASURE);
	DBMS_OUTPUT.PUT_LINE('----------------------------');

	DBMS_OUTPUT.PUT_LINE('Page Information');
	DBMS_OUTPUT.PUT_LINE('====================================');

	IF x_ag_page_tab IS NOT NULL AND x_ag_page_tab.COUNT > 0 THEN
	FOR i in 1 .. x_ag_page_tab.COUNT
	LOOP
		DBMS_OUTPUT.PUT_LINE(x_ag_page_tab(i).PAGE_ID);
		DBMS_OUTPUT.PUT_LINE(x_ag_page_tab(i).OBJECT_NAME);
		DBMS_OUTPUT.PUT_LINE(x_ag_page_tab(i).CLASSIFICATION_CODE);
		DBMS_OUTPUT.PUT_LINE(x_ag_page_tab(i).DATA_LEVEL_INT_NAME);
		DBMS_OUTPUT.PUT_LINE(x_ag_page_tab(i).INTERNAL_NAME);
		DBMS_OUTPUT.PUT_LINE(x_ag_page_tab(i).DISPLAY_NAME);
		DBMS_OUTPUT.PUT_LINE(x_ag_page_tab(i).DESCRIPTION);
		DBMS_OUTPUT.PUT_LINE(x_ag_page_tab(i).SEQUENCE);
		DBMS_OUTPUT.PUT_LINE('--------------------------------');
	END LOOP;
	END IF;

	DBMS_OUTPUT.PUT_LINE('Attribute Group Information');
	DBMS_OUTPUT.PUT_LINE('====================================');

	IF x_attr_group_tab IS NOT NULL AND x_attr_group_tab.COUNT > 0 THEN
	FOR j in 1 .. x_attr_group_tab.COUNT
	LOOP
		DBMS_OUTPUT.PUT_LINE(x_attR_group_tab(j).PAGE_ID);
		DBMS_OUTPUT.PUT_LINE(x_attR_group_tab(j).ATTR_GROUP_ID);
		DBMS_OUTPUT.PUT_LINE(x_attR_group_tab(j).ATTR_GROUP_TYPE);
		DBMS_OUTPUT.PUT_LINE(x_attR_group_tab(j).ATTR_GROUP_NAME);
		DBMS_OUTPUT.PUT_LINE(x_attR_group_tab(j).ATTR_GROUP_DISP_NAME);
		DBMS_OUTPUT.PUT_LINE(x_attR_group_tab(j).DESCRIPTION);
		DBMS_OUTPUT.PUT_LINE(x_attR_group_tab(j).MULTI_ROW_CODE);
		DBMS_OUTPUT.PUT_LINE(x_attR_group_tab(j).SECURITY_CODE);
		DBMS_OUTPUT.PUT_LINE(x_attR_group_tab(j).NUM_OF_COLS);
		DBMS_OUTPUT.PUT_LINE(x_attR_group_tab(j).NUM_OF_ROWS);
		DBMS_OUTPUT.PUT_LINE(x_attR_group_tab(j).SEQUENCE);
		DBMS_OUTPUT.PUT_LINE('--------------------------------');
	END LOOP;
	END IF;

	IF x_attribute_tab IS NOT NULL AND x_attribute_tab.COUNT > 0 THEN
	DBMS_OUTPUT.PUT_LINE('Attribute Information');
	DBMS_OUTPUT.PUT_LINE('====================================');
	FOR i in 1 .. x_attribute_tab.COUNT
	LOOP
		DBMS_OUTPUT.PUT_LINE(x_attribute_tab(i).ATTR_GROUP_TYPE);
		DBMS_OUTPUT.PUT_LINE(x_attribute_tab(i).ATTR_GROUP_NAME);
		DBMS_OUTPUT.PUT_LINE(x_attribute_tab(i).EXTENSION_ID);
		DBMS_OUTPUT.PUT_LINE(x_attribute_tab(i).ATTR_NAME);
		DBMS_OUTPUT.PUT_LINE(x_attribute_tab(i).ATTR_DISPLAY_NAME);
		DBMS_OUTPUT.PUT_LINE(x_attribute_tab(i).DESCRIPTION);
		DBMS_OUTPUT.PUT_LINE(x_attribute_tab(i).DISPLAY_VALUE);
		DBMS_OUTPUT.PUT_LINE(x_attribute_tab(i).DISPLAY_TYPE);
		DBMS_OUTPUT.PUT_LINE(x_attribute_tab(i).DYNAMIC_URL);
		DBMS_OUTPUT.PUT_LINE(x_attribute_tab(i).SEQUENCE);
		DBMS_OUTPUT.PUT_LINE('--------------------------------');
	END LOOP;
	END IF;

	IF x_error_messages IS NOT NULL AND x_error_messages.COUNT > 0 THEN
		DBMS_OUTPUT.PUT_LINE(x_error_messages.COUNT);
		FOR i in 1 .. x_error_messages.COUNT
		LOOP
			DBMS_OUTPUT.PUT_LINE(x_error_messages(i));
		END LOOP;
        END IF;

	Get_Primary_Attributes('HIERARCHY',
			        10000,
			        x_primary_attributes,
	                        x_error_messages);

END TEST;
*/

END RRS_ATTR_PANE;

/
