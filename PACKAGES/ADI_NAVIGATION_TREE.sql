--------------------------------------------------------
--  DDL for Package ADI_NAVIGATION_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ADI_NAVIGATION_TREE" AUTHID CURRENT_USER as
/* $Header: frmnavgs.pls 120.0 2006/12/14 02:06:19 dvayro noship $ */
-----------------------------------------------------------------------------------------
--   PROCEDURE     ADI_Navigation_Tree                                                 --
--                                                                                     --
--   DESCRIPTION:  Displays/creates the navigation structure for the kiosk portal.     --
--                                                                                     --
--   PARAMETERS:   None                                                                --
--                                                                                     --
--   Modifications                                                                     --
--   Date       Username   Description                                                 --
--   16-FEB-00  cclyde     Added Package_Revision procedure to see if we can capture   --
--                         the revision number of the package during runtime.          --
--                               (Task:  3858)                                         --
--   16-MAY-00  GSANAP     Moved the $Header comment from the top to under             --
--                         the CREATE OR REPLACE PACKAGE stmt.                         --
--   15-NOV-02  GHOOKER    Stub out procedures not used by RM8                         --
-----------------------------------------------------------------------------------------
END ADI_Navigation_Tree;

 

/
