--------------------------------------------------------
--  DDL for Package Body HRI_APL_MV_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_APL_MV_REFRESH" AS
/* $Header: hrirsgapi.pkb 120.0 2006/02/07 03:09:28 jtitmas noship $ */

-- -----------------------------------------------------------------------------
-- The procedure in this package drop and recreate the indexes depending
-- upon the mode in which it is called
-------------------------------------------------------------------------------
PROCEDURE custom_api(p_param IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL) IS

 l_api_type             VARCHAR2(300);
 l_object_name          VARCHAR2(300);
 l_mode                 VARCHAR2(300);
 l_schema_name          VARCHAR2(300);

BEGIN

  -- Retrieve parameters
  l_api_type := BIS_BIA_RSG_CUSTOM_API_MGMNT.GET_PARAM
                 (p_parameter_tbl => p_param,
                  p_param_name    => BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_API_TYPE);
  l_object_name := BIS_BIA_RSG_CUSTOM_API_MGMNT.GET_PARAM
                    (p_parameter_tbl => p_param,
                     p_param_name    => BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_OBJECT_NAME);
  l_mode := BIS_BIA_RSG_CUSTOM_API_MGMNT.GET_PARAM
             (p_parameter_tbl => p_param,
              p_param_name    => BIS_BIA_RSG_CUSTOM_API_MGMNT.PARA_MODE);

  -- Select the user to find out the schema where the  materialized view exists, since
  -- the materialized views are placed in the same schema as this package
  SELECT user
  INTO l_schema_name
  FROM sys.dual;

  -- Call APIs based on context
  IF l_api_type = 'MV_INDEX_MGT' THEN

    -- Check call mode before/after MV refresh
    IF l_mode = 'BEFORE' THEN

      -- Log and drop indexes before MV refresh
      bis_bia_rsg_custom_api_mgmnt.log('Before dropping indexes');
      hri_utl_ddl.log_and_drop_indexes
       (p_application_short_name => l_schema_name,
        p_table_name             => l_object_name,
        p_table_owner            => l_schema_name,
        p_index_excptn_lst       => null);
      bis_bia_rsg_custom_api_mgmnt.log('Dropped indexes');

    ELSIF (l_mode = 'AFTER') THEN

      -- Recreate indexes after MV refresh
      bis_bia_rsg_custom_api_mgmnt.log('Before recreating indexes');
      hri_utl_ddl.recreate_indexes
       (p_application_short_name => l_schema_name,
        p_table_name             => l_object_name,
        p_table_owner            => l_schema_name);
      bis_bia_rsg_custom_api_mgmnt.log('Recreated indexes');

    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN

  -- Write error message to log
  IF l_mode = 'BEFORE' THEN
    bis_bia_rsg_custom_api_mgmnt.log('Error in dropping indexes');
    bis_bia_rsg_custom_api_mgmnt.log(SQLERRM);
  ELSIF l_mode = 'AFTER' THEN
    bis_bia_rsg_custom_api_mgmnt.log('Error in recreating indexes');
    bis_bia_rsg_custom_api_mgmnt.log(SQLERRM);
  END IF;

  -- Pass on exception
  RAISE;

END custom_api;

END hri_apl_mv_refresh;

/
