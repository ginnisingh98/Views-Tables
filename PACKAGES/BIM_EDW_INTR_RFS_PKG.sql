--------------------------------------------------------
--  DDL for Package BIM_EDW_INTR_RFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_EDW_INTR_RFS_PKG" AUTHID CURRENT_USER AS
/*$Header: bimdrdrs.pls 120.0 2005/06/01 13:05:47 appldev noship $*/

    	PROCEDURE POPULATE(
		  ERRBUF       OUT NOCOPY VARCHAR2
		, RETCODE      OUT NOCOPY VARCHAR2
	    );

        FUNCTION SETUP RETURN BOOLEAN;
        PROCEDURE WRAPUP (
                   P_SUCCESSFUL BOOLEAN
                 , P_ROWS_PROCESSED NUMBER := 0
                 , P_EXCEPTION_MSG  VARCHAR2 := NULL );
        PROCEDURE POPULATE_INTRCTNS;
        PROCEDURE UPDATE_TEMP_TABLE;
        PROCEDURE POPULATE_INSTEAD_OF_VIEW;

        G_ROW_PROCESSED NUMBER := 0;

END BIM_EDW_INTR_RFS_PKG;

 

/