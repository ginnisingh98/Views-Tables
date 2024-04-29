--------------------------------------------------------
--  DDL for Package ADI_SECURITY_NOMINATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ADI_SECURITY_NOMINATE" AUTHID CURRENT_USER AS
/* $Header: frmsnoms.pls 120.0 2006/12/14 02:08:14 dvayro noship $ */
--------------------------------------------------------------------------------
--  PACKAGE:      ADI_Security_Nominate                                       --
--                                                                            --
--  DESCRIPTION:  Allows the user to select any number of flex values sets to --
--                participate within the User To Value Security model.        --
--                                                                            --
--  Modification History                                                      --
--  Date       Username    Description                                        --
--  18-JUN-99  CCLYDE      Initial creation                                   --
--  16-FEB-00  cclyde      Added Package_Revision procedure to see if we can  --
--                         capture the revision number of the package during  --
--                         runtime.     (Task: 3858)                          --
--  16-MAY-00 GSANAP       Moved the $Header comment from the top and replced --
--                         CREATE OR REPLACE PACKAGE IS TO AS                 --
--  02-JUN-00 GSANAP       Renamed AddValue to ValueSetDisplayFrame and       --
--                         added a parameter p_ValueSetSearch. Created new    --
--                         AddValue and ValueSetSearchFrame procedures.       --
--                         (Task : 4363)                                      --
--  15-NOV-02  GHOOKER    Stub out procedures not used by RM8                 --
--------------------------------------------------------------------------------
END ADI_Security_Nominate;

 

/
