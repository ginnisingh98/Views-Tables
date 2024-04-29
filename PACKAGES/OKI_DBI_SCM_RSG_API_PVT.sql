--------------------------------------------------------
--  DDL for Package OKI_DBI_SCM_RSG_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_SCM_RSG_API_PVT" AUTHID CURRENT_USER AS
/*$Header: OKIMVIMS.pls 120.1 2005/06/14 16:56:09 appldev  $*/

  PROCEDURE Oki_Custom_Api(	p_param		IN OUT NOCOPY	BIS_BIA_RSG_PARAMETER_TBL);

  PROCEDURE Manage_Oki_Index(	p_mode				VARCHAR2,
				p_obj_name			VARCHAR2,
				p_retcode	IN OUT NOCOPY	NUMBER);

  PROCEDURE Drop_Index (	p_table_name			VARCHAR2,
                                p_owner                        VARCHAR2,
			        p_retcode	IN OUT NOCOPY	NUMBER);

  PROCEDURE Create_index(	p_table_name			VARCHAR2,
                                p_owner                        VARCHAR2,
			        p_retcode	IN OUT NOCOPY	NUMBER);

  PROCEDURE sleep(	p_param		IN OUT NOCOPY	BIS_BIA_RSG_PARAMETER_TBL);

END;

 

/
