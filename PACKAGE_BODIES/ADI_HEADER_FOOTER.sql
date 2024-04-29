--------------------------------------------------------
--  DDL for Package Body ADI_HEADER_FOOTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ADI_HEADER_FOOTER" AS
/* $Header: frmkhdrb.pls 120.0 2006/12/14 02:04:41 dvayro noship $ */
--------------------------------------------------------------------------------
--  PACKAGE:      ADI_Header_Footer                                           --
--                                                                            --
--  DESCRIPTION:  Creates a header and a footer which may be attached to any  --
--                web page.                                                   --
--                                                                            --
--  Modification History                                                      --
--  Date        Username   Description                                        --
--  22-JUN-99   CCLYDE     Initial Creation                                   --
--  05-AUG-99   BHOOKER    Added function select_checkbox(required_field)     --
--  08-AUG-99   CCLYDE     pagehead - Removed the icon labels (redundancy) and--
--                         added a colour banner to the title to give the same--
--                         look and feel as the BIS reports.                  --
--  09-AUG-99   CCLYDE     Moved icons to constant values.                    --
--                         Added the Apps Logo to the end of the banner.      --
--                         Changed ALT tab from Exit to Logout.               --
--  20-AUG-99   CCLYDE     Split the pageHead procedure into two new procs so --
--                         that the html header and banner could be called    --
--                         seperately.  This was necessary because some       --
--                         procedures need to pass attributes to the body tag --
--                         whereas other procedures do not.                   --
--  08-SEP-99   CCLYDE     Added p_AccessCode so that the correct Login/Logout--
--                         icon can be displayed within the banner.           --
--                         Retrieving UserId - If returns null, the user is   --
--                         not logged in and the login icon needs to be shown,--
--                         otherwise, the logout icon is displayed.           --
--                         (Task: 3381)  (pageBanner)                         --
--  14-SEP-99   BHOOKER    Adjusted banner to correctly space text and icons  --
--                         when displayed full screen (sans navigator) in a   --
--                         browser. (pageBanner & pageHead)                   --
--  28-OCT-99   CCLYDE     Added extra code to default the Home Page URL to   --
--                         the Self Service Home Page. Need to expand this    --
--                         further so that the Home Page defaults to either   --
--                         Self Service or Report Manager Navigator (which    --
--                         ever product call the report.  New parameter       --
--                         defined.                                           --
--  02-NOV-99   CCLYDE     Removed the new parameter p_calledFrom as this     --
--                         logic would not be feasible to implement.  Toggle  --
--                         logic is now based on a new Profile Option:        --
--                         FRM_KIOSK_HOME_PAGE.     (Task: 3598)              --
--  04-NOV-99   CCLYDE     Changed the Home Page Menu for 10.7 Self Service to--
--                         OracleApps.DMM (was .VL).   (Task: 3598)           --
--  23-DEC-99   CCLYDE     Restructured the default for the home page so that --
--                         the Menu and Exit icons navigate to the correct    --
--                         self service portal.  Profile Option now contains  --
--                         three values: KIOSK, PERSONAL and UNIVERSAL.       --
--                              Task:  3788                                   --
--  10-FEB-00   CCLYDE     Changed the name of the profile to:                --
--                            ADI_ICON_NAVIGATION.                            --
--                         This avoids having to write upgrade scripts, if    --
--                         the user has already created the previous profile. --
--                         Embedded the SELECT FROM V$INSTANCE as these       --
--                         fields do not exist within a 7.x version of the    --
--                         database.  This is relevant for 10.7 only because  --
--                         Release 11.0 onwards is only compatible with an    --
--                         Oracle 8.0 database.                               --
--  16-FEB-00   CCLYDE     Added Package_Revision procedure to see if we can  --
--                         capture the revision number of the package during  --
--                         runtime.                                           --
--  02-MAR-00   GSANAP     Added IF statements to include conditions for 11.51--
--                         Task 3925.                                         --
--  16-MAY-00   GSANAP     Moved the $Header comment from the top and         --
--                         replaced CREATE OR REPLACE PACKAGE IS TO AS        --
--  14-AUG-00   CCLYDE     Created new global .gif file, c_slright and        --
--                         created the new footer as per the Apps division's  --
--                         new requirements.                                  --
--  07-DEC-00   CCLYDE     Modified the anchor for Help.  Changed from anchor --
--                         anchor2 so that Help can be displayed within a new --
--                         window.                                            --
--                            (PageBanner, PageHead)                          --
--  14-NOV-02  GHOOKER    Stub out procedures not used by RM8                 --
--------------------------------------------------------------------------------
END ADI_Header_Footer;

/