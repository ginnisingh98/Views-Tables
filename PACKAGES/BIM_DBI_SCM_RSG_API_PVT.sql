--------------------------------------------------------
--  DDL for Package BIM_DBI_SCM_RSG_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_DBI_SCM_RSG_API_PVT" AUTHID CURRENT_USER AS
/*$Header: bimmvims.pls 115.0 2004/06/02 08:36:58 kpadiyar noship $*/

  PROCEDURE bim_Custom_Api (p_param		IN OUT	NOCOPY	BIS_BIA_RSG_PARAMETER_TBL);

END;

 

/
