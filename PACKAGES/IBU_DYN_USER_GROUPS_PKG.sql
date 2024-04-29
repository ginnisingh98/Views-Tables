--------------------------------------------------------
--  DDL for Package IBU_DYN_USER_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_DYN_USER_GROUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: ibudyugs.pls 120.0 2006/01/11 11:17:41 ktma noship $ */

    PROCEDURE    IBU_USER_GROUP_UPD;

    PROCEDURE    IBU_USER_GROUP_CRE;

    PROCEDURE    IBU_USER_GROUP_DEL;

    PROCEDURE run_conc_prog
    (
          ERRBUF OUT NOCOPY VARCHAR2,
    	  RETCODE OUT NOCOPY NUMBER
    );
END; -- Package Specification IBU_DYN_USER_GROUPS_PKG

 

/
