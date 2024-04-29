--------------------------------------------------------
--  DDL for Package ADI_KIOSK_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ADI_KIOSK_GLOBAL" AUTHID CURRENT_USER AS
/* $Header: frmglobs.pls 120.0 2006/12/14 02:04:30 dvayro noship $ */
----------------------------------------------------------------------------------------
--  PROCEDURE:    ADI_Kiosk_Global                                                    --
--                                                                                    --
--  DESCRIPTION:  Contains a selection of global procedures which are required by     --
--                multiple packages.                                                  --
--                                                                                    --
--  PARAMETERS:   None                                                                --
--                                                                                    --
--  Modifications                                                                     --
--  Date       Username   Description                                                 --
--             cclyde     Initial creation                                            --
--  24-NOV-99  cclyde     Added function SetOwnershipPrivilege.  This checks to see   --
--                        if the current user has System Administration responsibility--
--                        assigned to them.  Anyone with Sys Admin responsibility     --
--                        is allowed to grant ownership.                              --
--  16-FEB-00  cclyde     Added Package_Revision procedure to see if we can capture   --
--                        the revision number of the package during runtime.          --
--                              (Task:  3858)                                         --
--  16-MAY-00  GSANAP     Moved the $Header comment from the top and replaced   --
--                        CREATE OR REPLACE PACKAGE IS TO AS                    --
--  14-NOV-02  GHOOKER    Stub out procedures not used by RM8                         --
----------------------------------------------------------------------------------------
END ADI_Kiosk_Global;

 

/
