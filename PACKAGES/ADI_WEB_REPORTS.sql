--------------------------------------------------------
--  DDL for Package ADI_WEB_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ADI_WEB_REPORTS" AUTHID CURRENT_USER AS
/* $Header: frmkosks.pls 120.0 2006/12/14 02:05:13 dvayro noship $ */
----------------------------------------------------------------------------------------
--  PACKAGE:      ADI_Web_Reports                                                     --
--                                                                                    --
--  DESCRIPTION:  Creates the menu structure for the Web Reporting Kiosk.             --
--                                                                                    --
--  Modifications                                                                     --
--  Date       Username   Description                                                 --
--  26-JUN-99  cclyde     Initial creation                                            --
--  16-FEB-00  cclyde     Added Package_Revision procedure to see if we can capture   --
--                        the revision number of the package during runtime.          --
--                              (Task:  3858)                                         --
--  16-MAY-00  GSANAP     Moved the $Header comment from the top to under             --
--                        the CREATE OR REPLACE PACKAGE stmt.                         --
--  14-NOV-02  GHOOKER    Stub out procedures not used by RM8                         --
----------------------------------------------------------------------------------------
END ADI_Web_Reports;

 

/
