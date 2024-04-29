--------------------------------------------------------
--  DDL for Package JTY_WEBADI_OTH_TERR_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_WEBADI_OTH_TERR_UPDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfowups.pls 120.7.12000000.1 2007/01/18 16:31:41 appldev ship $ */

--    Start of Comments

--    ---------------------------------------------------

--  PURPOSE

--      upload territory definition, resource information into excel

--		package name: JTY_WEBADI_OTH_TERR_UPDATE_PKG

--

--  PROCEDURES:

--       (see below for specification)

--

--  NOTES

--    This package is for PRIVATE USE ONLY use

--

--  HISTORY

--    09/01/2005    mhtran          Package Created

--    End of Comments

--


PROCEDURE UPDATE_TERR_DEF(
    x_errbuf            	  OUT NOCOPY VARCHAR2,
    x_retcode           	  OUT NOCOPY VARCHAR2,
    P_USER_SEQUENCE	  	  IN  NUMBER,
	--p_org_id			  IN  NUMBER,
	p_usage_id			  IN  NUMBER,
    p_user_id			  in  number
);

END JTY_WEBADI_OTH_TERR_UPDATE_PKG;

 

/
