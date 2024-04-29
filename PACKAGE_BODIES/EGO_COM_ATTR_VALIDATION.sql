--------------------------------------------------------
--  DDL for Package Body EGO_COM_ATTR_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_COM_ATTR_VALIDATION" AS
/* $Header: EGOCOMVB.pls 120.0.12010000.7 2009/04/22 19:53:32 mshirkol noship $ */

-----------------------------------------------------------------------
-- This procedure validates PIM Telco item user defined attributes   --
-----------------------------------------------------------------------

PROCEDURE Validate_Attributes (
        p_attr_group_type             IN VARCHAR2
       ,p_attr_group_name             IN VARCHAR2
       ,p_attr_group_id               IN NUMBER
       ,p_attr_name_value_pairs       IN EGO_USER_ATTR_DATA_TABLE
       ,p_pk_column_name_value_pairs  IN EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,x_return_status               OUT NOCOPY VARCHAR2
       ,x_error_messages              OUT NOCOPY EGO_COL_NAME_VALUE_PAIR_ARRAY
       ) IS

  l_curr_data_element                 EGO_USER_ATTR_DATA_OBJ;
  l_curr_pk_col_name_val_element      EGO_COL_NAME_VALUE_PAIR_OBJ;
  l_curr_class_cd_val_element         EGO_COL_NAME_VALUE_PAIR_OBJ;
  l_error_messages                    EGO_COL_NAME_VALUE_PAIR_ARRAY;

  -- attribute group --
  l_attr_group_type                   VARCHAR2(40);
  l_attrgrp_name                      VARCHAR2(40);
  l_attr_group_id                     NUMBER;

  -- attributes --
  l_curr_data_id                      NUMBER;
  l_curr_data_attr_name               VARCHAR2(30);

  -- COM item user defined attributes --
  l_minimum_price                     NUMBER;
  l_maximum_price                     NUMBER;
  l_targeted_min_age                  NUMBER;
  l_targeted_max_age                  NUMBER;
  l_end_t                             NUMBER;
  l_start_t                           NUMBER;

  -- COM component user defined attributes --
  l_max_cardinality                   NUMBER;
  l_min_cardinality                   NUMBER;
  l_default_cardinality               NUMBER;
  l_min                               NUMBER;
  l_max                               NUMBER;
  l_default_value                     NUMBER;

  -- COM item user defined attributes --
  l_minimum_price_exists              BOOLEAN    := FALSE;
  l_maximum_price_exists              BOOLEAN    := FALSE;
  l_targeted_min_age_exists           BOOLEAN    := FALSE;
  l_targeted_max_age_exists           BOOLEAN    := FALSE;
  l_end_t_exists                      BOOLEAN    := FALSE;
  l_start_t_exists                    BOOLEAN    := FALSE;

  -- COM component user defined attributes --
  l_max_cardinality_exists            BOOLEAN    := FALSE;
  l_min_cardinality_exists            BOOLEAN    := FALSE;
  l_default_cardinality_exists        BOOLEAN    := FALSE;
  l_max_exists                        BOOLEAN    := FALSE;
  l_min_exists                        BOOLEAN    := FALSE;
  l_default_value_exists              BOOLEAN    := FALSE;

  -- error --
  l_error_name_value_pairs            EGO_COL_NAME_VALUE_PAIR_ARRAY := EGO_COL_NAME_VALUE_PAIR_ARRAY();
  l_error_obj                         EGO_COL_NAME_VALUE_PAIR_OBJ;

  l_appl_id                           NUMBER;
  l_attr_grp_display_name             VARCHAR2(60);

  -- Cursor to derive display name
  Cursor c_get_attr_grp_display_name(p_application_id in number
                                    ,p_descriptive_flexfield_name in varchar2
                                    ,p_attr_grp_name in varchar2) is
  Select descriptive_flex_context_name
  from fnd_descr_flex_contexts_vl
  where application_id = p_application_id
  and descriptive_flexfield_name = p_descriptive_flexfield_name
  and descriptive_flex_context_code = p_attr_grp_name;

BEGIN

  -- Initialize Return Status
  x_return_status   := 'S';
  x_error_messages  := EGO_COL_NAME_VALUE_PAIR_ARRAY();
  l_attrgrp_name    := p_attr_group_name;

  IF (Is_Attribute_Group_Telco(l_attrgrp_name,p_attr_group_type)) THEN

    IF ( p_attr_group_type = 'EGO_ITEMMGMT_GROUP') THEN

      l_appl_id     := 431;

      -- get attribute group information
      l_attr_group_type := p_attr_group_type;
      l_attr_group_id   := p_attr_group_id;

      -- get attribute display name
      OPEN c_get_attr_grp_display_name(l_appl_id,p_attr_group_type,l_attrgrp_name);
      FETCH c_get_attr_grp_display_name into l_attr_grp_display_name;
      CLOSE c_get_attr_grp_display_name;

      -- create an array list with Telco attribute groups
      -- check whether the attribute group exists in the array list or not
      -- if attribute group exists in the array list then only do validations

      IF (p_attr_name_value_pairs.count > 0) THEN
        FOR j IN p_attr_name_value_pairs.FIRST .. p_attr_name_value_pairs.LAST
        LOOP
          l_curr_data_element := p_attr_name_value_pairs(j);
          l_curr_data_id := l_curr_data_element.ROW_IDENTIFIER;
          l_curr_data_attr_name := l_curr_data_element.ATTR_NAME;

          -- not sure whether row_identifier should be same
          -- for ego_user_attr_row_table and ego_user_attr_data_table
          --IF(l_curr_row_id = l_curr_data_id) THEN
          IF(l_curr_data_attr_name = 'Minimum_Price') THEN
            l_minimum_price := l_curr_data_element.ATTR_VALUE_NUM;
       	    l_minimum_price_exists := TRUE;
          ELSIF (l_curr_data_attr_name = 'Maximum_Price') THEN
            l_maximum_price := l_curr_data_element.ATTR_VALUE_NUM;
	    l_maximum_price_exists := TRUE;
          ELSIF (l_curr_data_attr_name = 'Targeted_Min_Age') THEN
            l_targeted_min_age := l_curr_data_element.ATTR_VALUE_NUM;
	    l_targeted_min_age_exists := TRUE;
          ELSIF (l_curr_data_attr_name = 'Targeted_Max_Age') THEN
            l_targeted_max_age := l_curr_data_element.ATTR_VALUE_NUM;
	    l_targeted_max_age_exists := TRUE;
          ELSIF (l_curr_data_attr_name = 'End_T') THEN
            l_end_t := l_curr_data_element.ATTR_VALUE_NUM;
	    l_end_t_exists := TRUE;
          ELSIF (l_curr_data_attr_name = 'Start_T') THEN
            l_start_t := l_curr_data_element.ATTR_VALUE_NUM;
            l_start_t_exists := TRUE;
          END IF;
        END LOOP;
      END IF;

      -- validate the user defined attributes
      -- if one of the attributes value is NULL then get it from database
      IF ( l_attrgrp_name = 'COM_Pricing_Price_Lists' ) THEN

        IF (NOT l_minimum_price_exists) THEN
          l_minimum_price := Get_Attr_Value_From_db
                            (l_attr_group_id
                            ,l_attr_group_type
	                    ,l_attrgrp_name
                            ,'Minimum_Price'
                            ,p_attr_name_value_pairs
                            ,p_pk_column_name_value_pairs
                            );
          l_minimum_price := to_number(l_minimum_price);
        ELSIF (NOT l_maximum_price_exists) THEN
          l_maximum_price := Get_Attr_Value_From_db
                            (l_attr_group_id
                            ,l_attr_group_type
	                    ,l_attrgrp_name
                     	    ,'Maximum_Price'
                            ,p_attr_name_value_pairs
                            ,p_pk_column_name_value_pairs
                            );
          l_maximum_price := to_number(l_maximum_price);
        END IF;

        -- validate attributes
        IF ((l_minimum_price IS NOT NULL) AND (l_maximum_price IS NOT NULL)) THEN
           IF (l_minimum_price > l_maximum_price) THEN
             l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_GROUP_NAME', l_attr_grp_display_name);
             l_error_name_value_pairs.EXTEND();
             l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

             l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ERROR_MESSAGE_NAME', 'EGO_COM_INVLD_MIN_MAX_PRICE');
             l_error_name_value_pairs.EXTEND();
             l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

             l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_INT_NAME', 'Minimum_Price');
             l_error_name_value_pairs.EXTEND();
             l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

             l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_INT_NAME', 'Maximum_Price');
             l_error_name_value_pairs.EXTEND();
             l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

             x_return_status := 'E';
          END IF;
        END IF;

      ELSIF ( l_attrgrp_name = 'MDM_Product_Details_Marketing' ) THEN

        IF (NOT l_targeted_min_age_exists) THEN
          l_targeted_min_age := Get_Attr_Value_From_db
                               (l_attr_group_id
                               ,l_attr_group_type
	                       ,l_attrgrp_name
                               ,'Targeted_Min_Age'
                               ,p_attr_name_value_pairs
                               ,p_pk_column_name_value_pairs
                               );
          l_targeted_min_age := to_number(l_targeted_min_age);
        ELSIF (NOT l_targeted_max_age_exists) THEN
          l_targeted_max_age := Get_Attr_Value_From_db
                               (l_attr_group_id
                               ,l_attr_group_type
	                       ,l_attrgrp_name
                 	       ,'Targeted_Max_Age'
                               ,p_attr_name_value_pairs
                               ,p_pk_column_name_value_pairs
                               );
          l_targeted_max_age := to_number(l_targeted_max_age);
        END IF;

        -- validate attributes
        IF ((l_targeted_min_age IS NOT NULL) AND (l_targeted_max_age IS NOT NULL)) THEN
          IF ((l_targeted_min_age > l_targeted_max_age) OR (l_targeted_min_age = l_targeted_max_age)) THEN
            l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_GROUP_NAME', l_attr_grp_display_name);
            l_error_name_value_pairs.EXTEND();
            l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

            l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ERROR_MESSAGE_NAME', 'EGO_COM_INVLD_TRGET_MINMAX_AGE');
            l_error_name_value_pairs.EXTEND();
            l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

            l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_INT_NAME', 'Targeted_Min_Age');
            l_error_name_value_pairs.EXTEND();
            l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

            l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_INT_NAME', 'Targeted_Max_Age');
            l_error_name_value_pairs.EXTEND();
            l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

            x_return_status := 'E';
	  END IF;
        END IF;

      ELSIF ( l_attrgrp_name = 'COM_Billing_Attributes_General' ) THEN

        IF (NOT l_end_t_exists) THEN
          l_end_t := Get_Attr_Value_From_db
                    (l_attr_group_id
                    ,l_attr_group_type
	            ,l_attrgrp_name
                    ,'End_T'
                    ,p_attr_name_value_pairs
                    ,p_pk_column_name_value_pairs
                    );
          l_end_t := to_number(l_end_t);
        ELSIF (NOT l_start_t_exists) THEN
          l_start_t := Get_Attr_Value_From_db
                      (l_attr_group_id
                      ,l_attr_group_type
	              ,l_attrgrp_name
                      ,'Start_T'
                      ,p_attr_name_value_pairs
                      ,p_pk_column_name_value_pairs
                      );
          l_start_t := to_number(l_start_t);
        END IF;

        -- validate attributes
        IF ((l_start_t  IS NOT NULL) AND (l_end_t IS NOT NULL)) THEN
          IF ((l_start_t > l_end_t) OR (l_start_t = l_end_t)) THEN
            l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_GROUP_NAME', l_attr_grp_display_name);
            l_error_name_value_pairs.EXTEND();
            l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

            l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ERROR_MESSAGE_NAME', 'EGO_COM_INVLD_START_END_T');
            l_error_name_value_pairs.EXTEND();
            l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

            l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_INT_NAME', 'End_T');
            l_error_name_value_pairs.EXTEND();
            l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

            l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_INT_NAME', 'Start_T');
            l_error_name_value_pairs.EXTEND();
            l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

            x_return_status := 'E';
          END IF;
        END IF;

      END IF;

    ELSIF ( p_attr_group_type = 'BOM_COMPONENTMGMT_GROUP') THEN  -- Attribute Group Type

      -- get attribute group information
      l_attr_group_type := p_attr_group_type;
      l_attr_group_id   := p_attr_group_id;
      l_appl_id         := 702;

      -- get attribute display name
      OPEN c_get_attr_grp_display_name(l_appl_id,p_attr_group_type,l_attrgrp_name);
      FETCH c_get_attr_grp_display_name into l_attr_grp_display_name;
      CLOSE c_get_attr_grp_display_name;

      -- create an array list with Telco attribute groups
      -- check whether the attribute group exists in the array list or not
      -- if attribute group exists in the array list then only do validations

      IF (p_attr_name_value_pairs.count > 0) THEN
        FOR j IN p_attr_name_value_pairs.FIRST .. p_attr_name_value_pairs.LAST
        LOOP
          l_curr_data_element   := p_attr_name_value_pairs(j);
          l_curr_data_id        := l_curr_data_element.ROW_IDENTIFIER;
          l_curr_data_attr_name := l_curr_data_element.ATTR_NAME;


          IF(l_curr_data_attr_name = 'Max_Cardinality') THEN
            l_max_cardinality        := l_curr_data_element.ATTR_VALUE_NUM;
       	    l_max_cardinality_exists := TRUE;
          ELSIF (l_curr_data_attr_name = 'Min_Cardinality') THEN
            l_min_cardinality        := l_curr_data_element.ATTR_VALUE_NUM;
	    l_min_cardinality_exists := TRUE;
          ELSIF (l_curr_data_attr_name = 'Default_Cardinality') THEN
            l_default_cardinality        := l_curr_data_element.ATTR_VALUE_NUM;
	    l_default_cardinality_exists := TRUE;
          ELSIF (l_curr_data_attr_name = 'Min') THEN
            l_min        := l_curr_data_element.ATTR_VALUE_NUM;
	    l_min_exists := TRUE;
          ELSIF (l_curr_data_attr_name = 'Max') THEN
            l_max        := l_curr_data_element.ATTR_VALUE_NUM;
	    l_max_exists := TRUE;
          ELSIF (l_curr_data_attr_name = 'Default_Value') THEN
            l_default_value        := l_curr_data_element.ATTR_VALUE_NUM;
            l_default_value_exists := TRUE;
          END IF;
        END LOOP;
      END IF;

      -- validate the user defined attributes
      -- if one of the attributes value is NULL then get it from database
      IF ( l_attrgrp_name = 'COM_Version_Structure' ) THEN

        IF (NOT l_max_cardinality_exists) THEN
          l_max_cardinality := Get_Attr_Value_From_db
                            (l_attr_group_id
                            ,l_attr_group_type
	                    ,l_attrgrp_name
                            ,'Max_Cardinality'
                            ,p_attr_name_value_pairs
                            ,p_pk_column_name_value_pairs
                            );
          l_max_cardinality := to_number(l_max_cardinality);
        END IF;

        IF (NOT l_min_cardinality_exists) THEN
          l_min_cardinality := Get_Attr_Value_From_db
	                    (l_attr_group_id
	                    ,l_attr_group_type
	  	            ,l_attrgrp_name
	                    ,'Min_Cardinality'
                            ,p_attr_name_value_pairs
                            ,p_pk_column_name_value_pairs
                            );
          l_min_cardinality := to_number(l_min_cardinality);
        END IF;

        IF (NOT l_default_cardinality_exists) THEN
          l_default_cardinality := Get_Attr_Value_From_db
	                    (l_attr_group_id
	                    ,l_attr_group_type
	  	            ,l_attrgrp_name
	                    ,'Default_Cardinality'
                            ,p_attr_name_value_pairs
                            ,p_pk_column_name_value_pairs
	                    );
          l_default_cardinality := to_number(l_default_cardinality);
        END IF;

        -- validate attributes
        IF ((l_min_cardinality is not null AND l_default_cardinality is not null AND l_min_cardinality > l_default_cardinality)  OR
            (l_default_cardinality is not null AND l_max_cardinality is not null AND l_default_cardinality > l_max_cardinality ) OR
            (l_min_cardinality is not null AND l_max_cardinality is not null AND l_min_cardinality > l_max_cardinality )) THEN

             l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_GROUP_NAME', l_attr_grp_display_name);
             l_error_name_value_pairs.EXTEND();
             l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

             l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ERROR_MESSAGE_NAME', 'EGO_COM_VS_CARDINALITY_VALDN');
             l_error_name_value_pairs.EXTEND();
             l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

             l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_INT_NAME', 'Min_Cardinality');
             l_error_name_value_pairs.EXTEND();
             l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

             l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_INT_NAME', 'Max_Cardinality');
             l_error_name_value_pairs.EXTEND();
             l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

             l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_INT_NAME', 'Default_Cardinality');
	     l_error_name_value_pairs.EXTEND();
             l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

             x_return_status := 'E';
        END IF;

      ELSIF ( l_attrgrp_name = 'COM_Prod_Promotions_Components' ) THEN

        IF (NOT l_min_exists) THEN
          l_min   := Get_Attr_Value_From_db
	             (l_attr_group_id
	             ,l_attr_group_type
	  	     ,l_attrgrp_name
	             ,'Min'
                     ,p_attr_name_value_pairs
                     ,p_pk_column_name_value_pairs
                     );
          l_min := to_number(l_min);
        END IF;

        IF (NOT l_max_exists) THEN
          l_max := Get_Attr_Value_From_db
                    (l_attr_group_id
                    ,l_attr_group_type
	            ,l_attrgrp_name
                    ,'Max'
                    ,p_attr_name_value_pairs
                    ,p_pk_column_name_value_pairs
                     );
          l_max := to_number(l_max);
        END IF;

        IF (NOT l_default_value_exists) THEN
          l_default_value := Get_Attr_Value_From_db
                           (l_attr_group_id
                           ,l_attr_group_type
	                   ,l_attrgrp_name
                           ,'Default_Value'
                           ,p_attr_name_value_pairs
                           ,p_pk_column_name_value_pairs
                          );
          l_default_value := to_number(l_default_value);
        END IF;

        -- validate attributes
        IF ((l_min is not null AND l_default_value is not null AND l_min > l_default_value)  OR
            (l_default_value is not null AND l_max is not null AND l_default_value > l_max ) OR
            (l_min is not null AND l_max is not null AND l_min > l_max )) THEN

            l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_GROUP_NAME', l_attr_grp_display_name);
            l_error_name_value_pairs.EXTEND();
            l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

            l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ERROR_MESSAGE_NAME','EGO_COM_PROD_PROMO_VALDN');
            l_error_name_value_pairs.EXTEND();
            l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

            l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_INT_NAME', 'Min');
            l_error_name_value_pairs.EXTEND();
            l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

            l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_INT_NAME', 'Max');
            l_error_name_value_pairs.EXTEND();
            l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

            l_error_obj := EGO_COL_NAME_VALUE_PAIR_OBJ('ATTR_INT_NAME', 'Default_Value');
            l_error_name_value_pairs.EXTEND();
            l_error_name_value_pairs(l_error_name_value_pairs.LAST) := l_error_obj;

            x_return_status := 'E';
        END IF;

      END IF;

    END IF;

    IF ( x_return_status = 'E' ) THEN
      x_error_messages := l_error_name_value_pairs;
    ELSE
      x_error_messages := EGO_COL_NAME_VALUE_PAIR_ARRAY();
    END IF;

  END IF;

END Validate_Attributes;

-------------------------------------------------------------------------------------
--       This function gets data from database for the item and component uda      --
-------------------------------------------------------------------------------------

FUNCTION Get_Attr_Value_From_db(p_attr_grp_id  IN NUMBER
                               ,p_attr_grp_type IN VARCHAR2
                               ,p_attr_grp_name IN VARCHAR2
                               ,p_attr_name     IN VARCHAR2
			       ,p_attr_name_value_pairs       IN ego_user_attr_data_table
			       ,p_pk_column_name_value_pairs  IN ego_col_name_value_pair_array
			       ) RETURN VARCHAR2
IS
  l_appl_id       NUMBER;
  l_object_name   VARCHAR2(30);
  l_pk_col1       VARCHAR2(30);
  l_pk_col2       VARCHAR2(30);
  l_pk_col3       VARCHAR2(30);
  l_pk_col4       VARCHAR2(30);
  l_pk_value1     VARCHAR2(10);
  l_pk_value2     VARCHAR2(10);
  l_pk_value3     VARCHAR2(10);
  l_pk_value4     VARCHAR2(10);
  l_user_attr_val VARCHAR2(30);
  l_object_id     NUMBER;
  l_attr_group_metadata_obj      EGO_ATTR_GROUP_METADATA_OBJ;
  l_ext_table_metadata_obj       EGO_EXT_TABLE_METADATA_OBJ;
  l_data_level_name_value_pairs  EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_extension_id  NUMBER;
  l_index         NUMBER;
  l_attr_grp_id   NUMBER;

  Cursor c_get_attr_grp_id(p_application_id in number
                           ,p_descriptive_flexfield_name in varchar2
                           ,p_attr_grp_name in varchar2) is
  Select attr_group_id
  from ego_fnd_dsc_flx_ctx_ext
  where application_id = p_application_id
  and descriptive_flexfield_name = p_descriptive_flexfield_name
  and descriptive_flex_context_code = p_attr_grp_name;

BEGIN

  IF (p_attr_grp_type = 'EGO_ITEMMGMT_GROUP') THEN

    l_appl_id     := 431;
    l_object_name := 'EGO_ITEM';
    l_pk_col1     := 'INVENTORY_ITEM_ID';
    l_pk_col2     := 'ORGANIZATION_ID';
    l_pk_col3     := 'REVISION_ID';

    -- Derive Attr Group Id
    IF (p_attr_grp_id is NULL) THEN
      -- Derive the Attribute Group Id
      OPEN c_get_attr_grp_id(l_appl_id,p_attr_grp_type,p_attr_grp_name);
      FETCH c_get_attr_grp_id into l_attr_grp_id;
      CLOSE c_get_attr_grp_id;
    ELSE
      l_attr_grp_id := p_attr_grp_id;
    END IF;

    -- get pk values - inventory_item_id, organization_id, revision_id
    l_index := p_pk_column_name_value_pairs.FIRST;
    While (l_index IS NOT NULL)
    LOOP
       IF ((p_pk_column_name_value_pairs(l_index).NAME IS NOT NULL) AND (p_pk_column_name_value_pairs(l_index).NAME = 'INVENTORY_ITEM_ID')) THEN
         l_pk_value1 := p_pk_column_name_value_pairs(l_index).VALUE;
       END IF;
       IF ((p_pk_column_name_value_pairs(l_index).NAME IS NOT NULL) AND (p_pk_column_name_value_pairs(l_index).NAME = 'ORGANIZATION_ID')) THEN
         l_pk_value2 := p_pk_column_name_value_pairs(l_index).VALUE;
       END IF;
       IF ((p_pk_column_name_value_pairs(l_index).NAME IS NOT NULL) AND (p_pk_column_name_value_pairs(l_index).NAME = 'REVISION_ID')) THEN
         l_pk_value3 := p_pk_column_name_value_pairs(l_index).VALUE;
       END IF;
       l_index := p_pk_column_name_value_pairs.NEXT(l_index);
    END LOOP;

  ELSIF (p_attr_grp_type = 'BOM_COMPONENTMGMT_GROUP') THEN

    l_appl_id     := 702;
    l_object_name := 'BOM_COMPONENTS';
    l_pk_col1     := 'BILL_SEQUENCE_ID';
    l_pk_col2     := 'STRUCTURE_TYPE_ID';
    l_pk_col3     := 'COMPONENT_SEQUENCE_ID';

    -- Derive Attr Group Id
    IF (p_attr_grp_id is NULL) THEN
      -- Derive the Attribute Group Id
      OPEN c_get_attr_grp_id(l_appl_id,p_attr_grp_type,p_attr_grp_name);
      FETCH c_get_attr_grp_id into l_attr_grp_id;
      CLOSE c_get_attr_grp_id;
    ELSE
      l_attr_grp_id := p_attr_grp_id;
    END IF;

    -- get pk values - bill_sequence_id, structure_type_id, component_sequence_id
    l_index := p_pk_column_name_value_pairs.FIRST;
    While (l_index IS NOT NULL)
    LOOP
       IF ((p_pk_column_name_value_pairs(l_index).NAME IS NOT NULL) AND (p_pk_column_name_value_pairs(l_index).NAME = 'BILL_SEQUENCE_ID')) THEN
         l_pk_value1 := p_pk_column_name_value_pairs(l_index).VALUE;
       END IF;
       IF ((p_pk_column_name_value_pairs(l_index).NAME IS NOT NULL) AND (p_pk_column_name_value_pairs(l_index).NAME = 'STRUCTURE_TYPE_ID')) THEN
         l_pk_value2 := p_pk_column_name_value_pairs(l_index).VALUE;
       END IF;
       IF ((p_pk_column_name_value_pairs(l_index).NAME IS NOT NULL) AND (p_pk_column_name_value_pairs(l_index).NAME = 'COMPONENT_SEQUENCE_ID')) THEN
         l_pk_value3 := p_pk_column_name_value_pairs(l_index).VALUE;
       END IF;
       IF ((p_pk_column_name_value_pairs(l_index).NAME IS NOT NULL) AND (p_pk_column_name_value_pairs(l_index).NAME = 'EXTENSION_ID')) THEN
         l_extension_id := p_pk_column_name_value_pairs(l_index).VALUE;
       END IF;
       l_index := p_pk_column_name_value_pairs.NEXT(l_index);
    END LOOP;

  END IF;

  -- Derive the Extension for MR AG only if it is null


  l_attr_group_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Attr_Group_Metadata
                                ( p_attr_group_id => l_attr_grp_id );


  IF (l_extension_id IS NULL) THEN

    IF (p_attr_grp_type = 'EGO_ITEMMGMT_GROUP') THEN

     l_object_id := EGO_USER_ATTRS_DATA_PVT.Get_Object_Id_From_Name('EGO_ITEM');
     l_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(p_object_id => l_object_id);

     l_data_level_name_value_pairs :=
              EGO_COL_NAME_VALUE_PAIR_ARRAY(
                EGO_COL_NAME_VALUE_PAIR_OBJ( 'REVISION_ID', l_pk_value3 )
                 );

    ELSIF (p_attr_grp_type = 'BOM_COMPONENTMGMT_GROUP') THEN

     l_object_id := EGO_USER_ATTRS_DATA_PVT.Get_Object_Id_From_Name('BOM_COMPONENTS');
     l_ext_table_metadata_obj := EGO_USER_ATTRS_COMMON_PVT.Get_Ext_Table_Metadata(p_object_id => l_object_id);

     l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY();

    END IF;


    l_extension_id := EGO_USER_ATTRS_DATA_PVT.Get_Extension_Id_For_Row
                            ( p_attr_group_metadata_obj     => l_attr_group_metadata_obj
                            , p_ext_table_metadata_obj      => l_ext_table_metadata_obj
                            , p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs
                            , p_data_level                  => NULL -- p_data_level
                            , p_data_level_name_value_pairs => l_data_level_name_value_pairs
                            , p_attr_name_value_pairs       => p_attr_name_value_pairs
                          );


    IF (l_extension_id is NOT NULL) THEN
      l_pk_col4    := 'EXTENSION_ID';
      l_pk_value4  := to_char(l_extension_id);
    END IF;

  ELSE

    l_pk_col4    := 'EXTENSION_ID';
    l_pk_value4  := to_char(l_extension_id);

  END IF;

  l_user_attr_val := EGO_USER_ATTRS_DATA_PVT.Get_User_Attr_Val (
                               p_appl_id                       => l_appl_id
                              ,p_attr_grp_type                 => p_attr_grp_type
                              ,p_attr_grp_name                 => p_attr_grp_name
                              ,p_attr_name                     => p_attr_name
                              ,p_object_name                   => l_object_name
                              ,p_pk_col1                       => l_pk_col1
                              ,p_pk_col2                       => l_pk_col2
			      ,p_pk_col3                       => l_pk_col3
			      ,p_pk_col4                       => l_pk_col4
                              ,p_pk_value1                     => l_pk_value1
                              ,p_pk_value2                     => l_pk_value2
			      ,p_pk_value3                     => l_pk_value3
			      ,p_pk_value4                     => l_pk_value4
                             );
  RETURN l_user_attr_val;

END Get_Attr_Value_From_db;

-----------------------------------------------------------------------
--  This function checks whether the the attribute group is PIM      --
--  Telco attribute group or not                                     --
-----------------------------------------------------------------------

FUNCTION Is_Attribute_Group_Telco(p_attr_grp_name IN VARCHAR2,p_attr_grp_type IN VARCHAR2) RETURN BOOLEAN
IS

  TYPE com_itemattr_grps IS VARRAY(6) OF VARCHAR2(30);
  TYPE com_bomattr_grps  IS VARRAY(6) OF VARCHAR2(30);

  Com_ItemAttrGrps com_itemattr_grps;
  Com_BOMAttrGrps  com_bomattr_grps;

  l_attr_grp_found BOOLEAN := FALSE;

BEGIN

    Com_ItemAttrGrps := com_itemattr_grps('COM_Pricing_Price_Lists'
                                        , 'MDM_Product_Details_Marketing'
                                        , 'COM_Billing_Attributes_General');

    Com_BOMAttrGrps := com_bomattr_grps('COM_Version_Structure'
                                      , 'COM_Prod_Promotions_Components');

    FOR i IN Com_ItemAttrGrps.FIRST .. Com_ItemAttrGrps.LAST
    LOOP
      IF (Com_ItemAttrGrps(i) = p_attr_grp_name and p_attr_grp_type = 'EGO_ITEMMGMT_GROUP') THEN
        l_attr_grp_found := TRUE;
	EXIT;
      END IF;
    END LOOP;

    FOR i IN Com_BOMAttrGrps.FIRST .. Com_BOMAttrGrps.LAST
    LOOP
      IF (Com_BOMAttrGrps(i) = p_attr_grp_name and p_attr_grp_type = 'BOM_COMPONENTMGMT_GROUP') THEN
        l_attr_grp_found := TRUE;
	EXIT;
      END IF;
    END LOOP;

    RETURN l_attr_grp_found;

END Is_Attribute_Group_Telco;


-----------------------------------------------------------------------
--  Procedure to validate Component Attribute Default Values         --
--  Validation is done for only Single Row AG's since                --
--  defaulting is not done for MR AG's as per current functionality  --
-----------------------------------------------------------------------
PROCEDURE Validate_Default_CompAttr(
              p_pk_column_name_value_pairs  IN ego_col_name_value_pair_array DEFAULT NULL
             ,x_return_status               OUT NOCOPY VARCHAR2
             ,x_error_messages              OUT NOCOPY ego_col_name_value_pair_array
              )IS


  l_object_id                  NUMBER;
  l_attr_name_value_pairs      EGO_USER_ATTR_DATA_TABLE;
  l_bill_sequence_id           NUMBER;
  l_structure_type_id          NUMBER;
  l_component_sequence_id      NUMBER;
  l_index                      NUMBER;
  --
  -- Cursor to derive attribute groups
  --
  Cursor c_get_attr_grp(p_structure_type_id in number,
                        p_object_id  in number) is
  Select a.attr_group_id
         ,a.attr_group_name
         ,a.attr_group_type
         ,b.multi_row
  from ego_obj_attr_grp_assocs_v a,
       ego_fnd_dsc_flx_ctx_ext b
  where a.object_id = p_object_id
  and a.classification_code = to_char(p_structure_type_id)
  and a.data_level_int_name = 'COMPONENTS_LEVEL'
  and a.attr_group_id = b.attr_group_id;


BEGIN
   -- Initialize Return Status
  x_return_status   := 'S';
  x_error_messages  := EGO_COL_NAME_VALUE_PAIR_ARRAY();
  l_attr_name_value_pairs := EGO_USER_ATTR_DATA_TABLE();

  -- get pk values - bill_sequence_id, structure_type_id, component_sequence_id
  l_index := p_pk_column_name_value_pairs.FIRST;
  While (l_index IS NOT NULL)
  LOOP
    IF ((p_pk_column_name_value_pairs(l_index).NAME IS NOT NULL) AND (p_pk_column_name_value_pairs(l_index).NAME = 'STRUCTURE_TYPE_ID')) THEN
      l_structure_type_id := p_pk_column_name_value_pairs(l_index).VALUE;
      exit;
    END IF;
    l_index := p_pk_column_name_value_pairs.NEXT(l_index);
  END LOOP;

  -- Derive the object id
  l_object_id := EGO_USER_ATTRS_DATA_PVT.Get_Object_Id_From_Name('BOM_COMPONENTS');

  -- Attribute Groups associated with the Structure
  FOR c_attr_grp IN c_get_attr_grp(l_structure_type_id,l_object_id)
  LOOP

    IF (Is_Attribute_Group_Telco(c_attr_grp.attr_group_name,c_attr_grp.attr_group_type) and
        c_attr_grp.multi_row = 'N') THEN

      -- Since Attribute Values are derived in Validate_Attribute procedure
      -- passing null values in  l_attr_name_value_pairs parameter

      Validate_Attributes (
        p_attr_group_type             => 'BOM_COMPONENTMGMT_GROUP'
       ,p_attr_group_name             => c_attr_grp.attr_group_name
       ,p_attr_group_id               => c_attr_grp.attr_group_id
       ,p_attr_name_value_pairs       => l_attr_name_value_pairs
       ,p_pk_column_name_value_pairs  => p_pk_column_name_value_pairs
       ,x_return_status               => x_return_status
       ,x_error_messages              => x_error_messages);

      IF ( x_return_status = 'E' ) THEN
        return;
      ELSE
        x_error_messages := EGO_COL_NAME_VALUE_PAIR_ARRAY();
      END IF;

    END IF;

  END LOOP;

END;

END EGO_COM_ATTR_VALIDATION;

/
