--------------------------------------------------------
--  DDL for Package ADI_SECURITY_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ADI_SECURITY_USER" AUTHID CURRENT_USER AS
/* $Header: frmsusrs.pls 120.0 2006/03/19 14:03:46 dvayro noship $ */
----------------------------------------------------------------------------------------
--  PACKAGE:      ADI_Security_User_To_Value                                          --
--                                                                                    --
--  DESCRIPTION:  Select a value set and multiple flex values in order to             --
--                grant and revoke access privileges between flex values and          --
--                users.                                                              --
--                                                                                    --
--  Modification History                                                              --
--  Date       Username    Description                                                --
--  14-JUL-99  CCLYDE      Initial creation                                           --
--  16-FEB-00  cclyde      Added Package_Revision procedure to see if we can capture  --
--                         the revision number of the package during runtime.         --
--                              (Task:  3858)                                         --
--  16-MAY-00  GSANAP      Moved the $Header comment from the top to                  --
--                         under the CREATE OR REPLACE PACKAGE stmt.                  --
--  15-NOV-02  GHOOKER    Stub out procedures not used by RM8                         --
----------------------------------------------------------------------------------------
END ADI_Security_User;

 

/
