--------------------------------------------------------
--  DDL for Package FII_MV_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_MV_REFRESH" AUTHID CURRENT_USER AS
/*$Header: FIIMVRSS.pls 120.4 2005/10/30 05:08:31 appldev ship $*/

   Procedure GL_REFRESH (Errbuf         IN OUT NOCOPY Varchar2,
                         Retcode        IN OUT NOCOPY Varchar2,
	                 p_program_type IN            VARCHAR2);

   Procedure AR_REFRESH (Errbuf         IN OUT NOCOPY Varchar2,
                         Retcode        IN OUT NOCOPY Varchar2);

   Procedure RSG_CALLOUT_API(p_param IN OUT NOCOPY BIS_BIA_RSG_PARAMETER_TBL);

End FII_MV_REFRESH;

 

/
