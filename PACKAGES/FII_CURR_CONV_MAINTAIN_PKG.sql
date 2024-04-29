--------------------------------------------------------
--  DDL for Package FII_CURR_CONV_MAINTAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_CURR_CONV_MAINTAIN_PKG" AUTHID CURRENT_USER AS
/* $Header: FIICRCVS.pls 120.0.12000000.1 2007/04/13 05:50:32 arcdixit noship $  */

-- *******************************************************************
-- Package level variables
-- *******************************************************************

 FIIDIM_Debug           BOOLEAN         := FALSE;
 FII_User_Id            NUMBER          := NULL;
 FII_Login_Id           NUMBER          := NULL;
 EX_fatal_err           EXCEPTION;

-- *******************************************************************
-- Procedure
-- *******************************************************************

  PROCEDURE Init_Load( errbuf  OUT NOCOPY VARCHAR2,
                       retcode OUT NOCOPY VARCHAR2 );

END FII_CURR_CONV_MAINTAIN_PKG;

 

/
