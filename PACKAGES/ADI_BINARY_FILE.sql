--------------------------------------------------------
--  DDL for Package ADI_BINARY_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ADI_BINARY_FILE" AUTHID CURRENT_USER AS
/* $Header: frmdimgs.pls 120.0.12000000.3 2007/03/01 20:12:42 ghooker ship $ */
--------------------------------------------------------------------------------
--  PACKAGE:      ADI_Image                                                   --
--                                                                            --
--  DESCRIPTION:  Displays an image embedded within an HTML file.  Images     --
--                will be displayed as part of the HTML file, whilst Xcel     --
--                files, word documents, etc will be downloaded onto the      --
--                file system (if the link is clicked on).                    --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  23-JUN-99  CCLYDE    Initial Creation                                     --
--  16-FEB-00  CCLYDE    Added Package_Revision procedure to see if we can    --
--                       capture the revision number of the package during    --
--                       runtime.          (Task:  3858)                      --
--  16-MAY-00  GSANAP    Moved the $Header comment from the top to under the  --
--                       CREATE OR REPLACE PACKAGE stmt.                      --
--  13-NOV-02  GHOOKER   Bugs 2279439, 2618782 Images not displayed in RM8.   --
--  28-JUN-06  GHOOKER   Stubbed out GetFileListenerAddress                   --
--------------------------------------------------------------------------------
   PROCEDURE Show (p_documentId IN  NUMBER DEFAULT 0,
                   p_file  IN  VARCHAR2 DEFAULT '');
   PROCEDURE PackageRevision (p_showOwner IN VARCHAR2 DEFAULT '');
END ADI_Binary_File;

 

/
