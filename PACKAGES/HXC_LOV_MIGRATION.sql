--------------------------------------------------------
--  DDL for Package HXC_LOV_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_LOV_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: hxclovmig.pkh 115.1 2003/07/09 19:07:35 mstewart noship $ */

  -- =================================================================
  -- == migrate_lov_region
  -- =================================================================
  PROCEDURE migrate_lov_region
    (p_region_code            IN AK_REGIONS_VL.REGION_CODE%TYPE DEFAULT NULL
    ,p_region_app_short_name  IN FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE DEFAULT NULL
    ,p_force                  IN VARCHAR2 DEFAULT NULL
    );
END hxc_lov_migration;

 

/
