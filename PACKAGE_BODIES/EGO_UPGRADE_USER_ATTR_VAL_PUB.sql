--------------------------------------------------------
--  DDL for Package Body EGO_UPGRADE_USER_ATTR_VAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_UPGRADE_USER_ATTR_VAL_PUB" AS
/* $Header: EGOUPGAB.pls 120.0 2005/05/26 21:35:12 appldev noship $ */



                   ------------------------------
                   -- Private Global Variables --
                   ------------------------------

    G_PKG_NAME                               CONSTANT VARCHAR2(30) := 'EGO_UPGRADE_USER_ATTR_VAL_PUB';


                          ----------------
                          -- Procedures --
                          ----------------

----------------------------------------------------------------------

PROCEDURE Upgrade_Cat_User_Attrs_Data
(
        p_api_version                   IN  NUMBER DEFAULT 1.0
       ,p_functional_area_id 		IN  NUMBER
       ,p_attr_group_name          	IN  VARCHAR2 DEFAULT NULL
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_proc_name  CONSTANT    VARCHAR2(30)  :=  'Upgrade_Cat_User_Attrs_Data';
    l_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_data_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_attr_group_id NUMBER;
    l_category_set_id NUMBER;
    l_return_status VARCHAR2(1);

    ---------------------------------------------------
    -- For finding the default category set for the  --
    -- functional area				     --
    ---------------------------------------------------
    CURSOR category_set_cursor
    IS
    SELECT CATEGORY_SET_ID
      FROM MTL_DEFAULT_CATEGORY_SETS
     WHERE FUNCTIONAL_AREA_ID = p_functional_area_id;

    -----------------------------------------------------
    -- For finding all categories in the category set  --
    -- that don't already have attribute group entries --
    -----------------------------------------------------
    CURSOR category_cursor (p_cat_set_id IN NUMBER
			    ,p_attr_group_id IN NUMBER)
    IS
   SELECT CAT.CATEGORY_ID
      FROM MTL_CATEGORY_SET_VALID_CATS CAT, MTL_CATEGORY_SETS_B CATSET
     WHERE CAT.CATEGORY_SET_ID = CATSET.CATEGORY_SET_ID
       AND CATSET.CATEGORY_SET_ID = p_cat_set_id
       AND NOT EXISTS
                (SELECT CATEGORY_ID
                 FROM EGO_PRODUCT_CAT_SET_EXT
                 WHERE CATEGORY_SET_ID = CATSET.CATEGORY_SET_ID
				 AND CATEGORY_ID = CAT.CATEGORY_ID
                 AND ATTR_GROUP_ID = p_attr_group_id);

    -------------------------------------------------------
    -- For finding ids for all category-level attribute  --
    -- groups. This cursor contains hard-coded 		 --
    -- attribute group names as there is currently no	 --
    -- mechanism to determine whether a particular	 --
    -- attribute group is at the category level or	 --
    -- catalog level. In addition, there is currently no --
    -- means to determine functional area to attribute   --
    -- group type association                           --
    -------------------------------------------------------
    CURSOR cat_level_attr_gp_cursor
    IS
    SELECT ATTRS.ATTR_GROUP_ID, ATTRS.ATTR_GROUP_NAME
      FROM EGO_ATTR_GROUPS_V ATTRS
     WHERE ATTRS.ATTR_GROUP_NAME = 'SalesAndMarketing'
       AND p_functional_area_id = 11;

    ----------------------------------------------
    -- For finding the id of an attribute group --
    ----------------------------------------------
    CURSOR attr_gp_id_cursor (attribute_group_name IN VARCHAR2)
    IS
    SELECT ATTRS.ATTR_GROUP_ID
      FROM EGO_ATTR_GROUPS_V ATTRS
     WHERE ATTRS.ATTR_GROUP_NAME = attribute_group_name;

  BEGIN


    ---------------------------------------------------
    -- Get default category set for functional area  --
    ---------------------------------------------------
    OPEN category_set_cursor;
    FETCH category_set_cursor INTO l_category_set_id;
    CLOSE category_set_cursor;

    ------------------------------------------------------------------
    -- Initialize the PK column array and the attribute data array  --
    -- before we start iterating thru the categories in the category--
    -- set				                            --
    ------------------------------------------------------------------
    l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                          EGO_COL_NAME_VALUE_PAIR_OBJ('CATEGORY_SET_ID',
						      l_category_set_id));

    l_data_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                          EGO_COL_NAME_VALUE_PAIR_OBJ('CATEGORY_ID', null));

    ------------------------------------------------------------------
    -- If no specific attribute group has come in, then process all --
    -- attribute groups attached to the category set                --
    ------------------------------------------------------------------
    IF (p_attr_group_name IS NULL) THEN

        FOR attr_gp_rec IN cat_level_attr_gp_cursor
        LOOP
    	  ------------------------------------------------------------------
    	  -- We loop through the categories in the category set, and      --
    	  -- build appropriate objects to call                            --
    	  -- EGO_USER_ATTRS_DATA_PVT.Perform_DML_On_Row                   --
    	  ------------------------------------------------------------------
       	  FOR cat_rec IN category_cursor(l_category_set_id,
	  			  	 attr_gp_rec.attr_group_id)
          LOOP
          	------------------------------------------------------------------
          	-- Now we update the Primary Key value, and clear out the Attr  --
          	-- Data table                                                 --
          	------------------------------------------------------------------
          	l_data_column_name_value_pairs(1).VALUE := cat_rec.CATEGORY_ID;

        	EGO_USER_ATTRS_DATA_PVT.Perform_DML_On_Row(
                  p_api_version                  => 1.0
                  ,p_object_name                 => 'EGO_CATEGORY_SET'
                  ,p_application_id              => 431
                  ,p_attr_group_type             => 'EGO_PRODUCT_CATEGORY_SET'
                  ,p_attr_group_name             => attr_gp_rec.attr_group_name
                  ,p_pk_column_name_value_pairs  => l_pk_column_name_value_pairs
                  ,p_class_code_name_value_pairs => NULL
                  ,p_data_level_name_value_pairs => l_data_column_name_value_pairs
                  ,p_attr_name_value_pairs       => null
                  ,p_use_def_vals_on_insert      => FND_API.G_TRUE
		  ,x_return_status               => x_return_status
                  ,x_errorcode                   => x_errorcode
                  ,x_msg_count                   => x_msg_count
                  ,x_msg_data                    => x_msg_data
                  );

	  END LOOP; -- category loop
	END LOOP; -- attribute gp loop

    ELSE

        ------------------------------------------------------------------
        -- If a  specific attribute group has come in, then process     --
        -- only that attribute group                                    --
        ------------------------------------------------------------------

    	OPEN attr_gp_id_cursor(p_attr_group_name);
    	FETCH attr_gp_id_cursor INTO l_attr_group_id;
    	IF (attr_gp_id_cursor%FOUND) THEN

           ------------------------------------------------------------------
           -- We loop through the categories in the category set, and      --
           -- build appropriate objects to call                            --
           -- EGO_USER_ATTRS_DATA_PVT.Perform_DML_On_Row                   --
           ------------------------------------------------------------------

           FOR cat_rec IN category_cursor(l_category_set_id,
                                          l_attr_group_id)
           LOOP
           	------------------------------------------
	   	-- Now we update the Primary Key value  --
           	------------------------------------------
           	l_data_column_name_value_pairs(1).VALUE := cat_rec.CATEGORY_ID;

    	   	EGO_USER_ATTRS_DATA_PVT.Perform_DML_On_Row(
        	   p_api_version                  => 1.0
       		   ,p_object_name                 => 'EGO_CATEGORY_SET'
       		   ,p_application_id              => 431
       		   ,p_attr_group_type             => 'EGO_PRODUCT_CATEGORY_SET'
       		   ,p_attr_group_name             => p_attr_group_name
       		   ,p_pk_column_name_value_pairs  => l_pk_column_name_value_pairs
       		   ,p_class_code_name_value_pairs => NULL
       		   ,p_data_level_name_value_pairs => l_data_column_name_value_pairs
       		   ,p_attr_name_value_pairs       => null
       		   ,p_use_def_vals_on_insert      => FND_API.G_TRUE
		   ,x_return_status               => x_return_status
       		   ,x_errorcode                   => x_errorcode
       		   ,x_msg_count                   => x_msg_count
       		   ,x_msg_data                    => x_msg_data
    		   );

	    END LOOP; -- Loop thru all categories in the category set
	END IF; -- IF attribute group id was found
    END IF; -- If attribute_group_name is NULL


    COMMIT WORK;

  EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_proc_name||' '||SQLERRM;

END Upgrade_Cat_User_Attrs_Data;

----------------------------------------------------------------------

END EGO_UPGRADE_USER_ATTR_VAL_PUB;


/
