--------------------------------------------------------
--  DDL for Package ADI_DISPLAY_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ADI_DISPLAY_REPORT" AUTHID CURRENT_USER AS
/* $Header: frmdisps.pls 120.0.12000000.3 2007/03/01 20:10:54 ghooker ship $ */
----------------------------------------------------------------------------------------
--  PROCEDURE:    ADI_Display_Report                                                  --
--                                                                                    --
--  DESCRIPTION:  Displays and HTML report/form to the screen.  The HTML output may   --
--                a report published from the Request Center, or a stand alone file   --
--                which was unloaded (also from the Request Center).                  --
--                                                                                    --
--  MODIFICATIONS                                                                     --
--  DATE       DEVELOPER  COMMENTS                                                    --
--             CCLYDE     Initial Creation                                            --
--  16-FEB-00  CCLYDE     Added Package_Revision procedure to see if we can capture   --
--                        the revision number of the package during runtime.          --
--                              (Task:  3858)                                         --
--  16-MAY-00  GSANAP     Moved the $Header comment from the top to under             --
--                        the CREATE OR REPLACE PACKAGE stmt.                         --
--  17-MAY-00  CCLYDE     Created new procedure DisplayBannerFrame, which displays    --
--                        the report Banner in a separate frame.  (Task: 4179)        --
--  17-MAY-00  CCLYDE     Made the following procedures public:  DisplayApprovalFrame --
--                        and DisplayFile, so that they can be called and displayed   --
--                        into two different frames.     (Task: 4192)                 --
--  13-NOV-02  GHOOKER    Bugs 2279439, 2618782 Images not displayed in RM8.          --
--  13-NOV-02  GHOOKER    Procedures not required for RM8 have been stubbed out       --
----------------------------------------------------------------------------------------
   TYPE g_timeArray IS TABLE OF VARCHAR2(2) INDEX BY BINARY_INTEGER;
   PROCEDURE DisplayFile (p_docId IN NUMBER);
   PROCEDURE DisplayHTMLFile (p_ReportTitle   IN VARCHAR2 default '',
                              p_TimeFrame     IN VARCHAR2 default '',
                              p_ExpandedValue IN VARCHAR2 default '',
                              p_StaticFile    IN VARCHAR2 default '',
                              p_PageType      IN VARCHAR2 default '',
                              p_displayBanner IN  VARCHAR2 default 'N');
   PROCEDURE Show (p_ReportTitle    IN  VARCHAR2,
           p_security       IN  VARCHAR2 default '',
                   p_displayBanner  IN  VARCHAR2 default 'N');
END ADI_display_report;

 

/
