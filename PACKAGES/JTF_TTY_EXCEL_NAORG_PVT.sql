--------------------------------------------------------
--  DDL for Package JTF_TTY_EXCEL_NAORG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_EXCEL_NAORG_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfamifs.pls 120.6 2006/07/28 22:56:17 mhtran noship $ */
-- ===========================================================================+
-- |               Copyright (c) 1999 Oracle Corporation                       |
-- |                  Redwood Shores, California, USA                          |
-- |                       All rights reserved.                                |
-- +===========================================================================
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_EXCEL_NAORG_PVT
--    ---------------------------------------------------
--    PURPOSE
--
--      This package is used to populate the interface table jtf_tty_webadi_interface
--      for the admin export download
--
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      02/24/2004    ACHANDA        Created
--      10/14/2005    VBGHOSH        Added mapped status to support for Export button
--
--    End of Comments
--

TYPE VARRAY_TYPE IS VARRAY(30) OF VARCHAR2(360);
TYPE NARRAY_TYPE IS VARRAY(30) OF NUMBER;
TYPE DARRAY_TYPE IS VARRAY(30) OF DATE;

procedure POPULATE_WEBADI_INTERFACE( P_CALLFROM         IN VARCHAR2
                                    ,P_SEARCHTYPE       IN VARCHAR2
                                    ,P_SEARCHVALUE      IN VARCHAR2
                                    ,P_USERID           IN INTEGER
                                    ,P_GRPNAME          IN VARCHAR2
                                    ,P_GRPID            IN NUMBER
                                    ,P_SITE_TYPE        IN VARCHAR2
                                    ,P_SICCODE          IN VARCHAR2
                                    ,P_SICCODE_TYPE     IN VARCHAR2 DEFAULT NULL
                                    ,P_SITE_DUNS        IN VARCHAR2
                                    ,P_NAMED_ACCOUNT    IN VARCHAR2
                                    ,P_WEB_SITE         IN VARCHAR2 DEFAULT NULL
                                    ,P_EMAIL_ADDR       IN VARCHAR2 DEFAULT NULL
                                    ,P_CITY             IN VARCHAR2
                                    ,P_STATE            IN VARCHAR2
                                    ,P_COUNTY           IN VARCHAR2 DEFAULT NULL
                                    ,P_PROVINCE         IN VARCHAR2
                                    ,P_POSTAL_CODE_FROM IN VARCHAR2
                                    ,P_POSTAL_CODE_TO   IN VARCHAR2
                                    ,P_COUNTRY          IN VARCHAR2
                                    ,P_DU_DUNS          IN VARCHAR2
                                    ,P_DU_NAME          IN VARCHAR2
                                    ,P_PARTY_NUMBER     IN VARCHAR2
                                    ,P_GU_DUNS          IN VARCHAR2
                                    ,P_GU_NAME          IN VARCHAR2
                                    ,P_CERT_LEVEL       IN VARCHAR2
                                    ,P_SALESPERSON      IN NUMBER
                                    ,P_SALES_GROUP      IN NUMBER
                                    ,P_SALES_ROLE       IN VARCHAR2
                                    ,P_ASSIGNED_STATUS  IN VARCHAR2
                                    ,P_ISADMINFLAG      IN VARCHAR2
                                    ,P_PARTY_TYPE       IN VARCHAR2 DEFAULT NULL
                                    ,P_HIERARCHY_TYPE   IN VARCHAR2 DEFAULT NULL
                                    ,P_RELATIONSHIP_ROLE IN VARCHAR2 DEFAULT NULL
                                    ,P_CLASS_TYPE       IN VARCHAR2 DEFAULT NULL
                                    ,P_CLASS_CODE       IN VARCHAR2 DEFAULT NULL
                                    ,P_ANN_REV_FROM     IN NUMBER DEFAULT NULL
                                    ,P_ANN_REV_TO       IN NUMBER DEFAULT NULL
                                    ,P_NUM_EMP_FROM     IN VARCHAR2 DEFAULT NULL
                                    ,P_NUM_EMP_TO       IN VARCHAR2 DEFAULT NULL
                                    ,P_CUST_CATEGORY    IN VARCHAR2 DEFAULT NULL
                                    ,P_IDENT_ADDR_FLAG  IN VARCHAR2 DEFAULT NULL
  			            			,P_MAPPED_STATUS   IN VARCHAR2 DEFAULT NULL
									,P_VIEW_DATE		IN DATE		DEFAULT NULL
									,P_ORG_ID			IN NUMBER		DEFAULT NULL
				    				,X_SEQ              OUT NOCOPY VARCHAR2
                                    ,X_RETCODE          OUT NOCOPY VARCHAR2
                                    ,X_ERRBUF           OUT NOCOPY VARCHAR2);


END JTF_TTY_EXCEL_NAORG_PVT;

 

/
