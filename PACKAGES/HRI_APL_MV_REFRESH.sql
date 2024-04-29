--------------------------------------------------------
--  DDL for Package HRI_APL_MV_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_APL_MV_REFRESH" AUTHID CURRENT_USER AS
/* $Header: hrirsgapi.pkh 120.0 2006/02/07 03:09:03 jtitmas noship $ */

PROCEDURE custom_api(p_param IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL);

END hri_apl_mv_refresh;

 

/
