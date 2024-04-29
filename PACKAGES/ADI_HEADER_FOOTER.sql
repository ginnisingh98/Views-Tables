--------------------------------------------------------
--  DDL for Package ADI_HEADER_FOOTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ADI_HEADER_FOOTER" AUTHID CURRENT_USER AS
/* $Header: frmkhdrs.pls 120.0 2006/12/14 02:04:51 dvayro noship $ */
--------------------------------------------------------------------------------
--  PACKAGE:      ADI_Header_Footer                                           --
--                                                                            --
--  DESCRIPTION:  Creates a header and a footer which may be attached to any  --
--                web page.                                                   --
--                                                                            --
--  Modification History                                                      --
--  Date        Username   Description                                        --
--  22-JUN-99   CCLYDE     Initial Creation                                   --
--  16-FEB-00   CCLYDE     Added Package_Revision procedure to see if we can  --
--                         capture the revision number of the package during  --
--                         runtime.                                           --
--  16-MAY-00   GSANAP     Moved the $Header comment from the top and replaced--
--                         CREATE OR REPLACE PACKAGE IS TO AS                 --
--  14-NOV-02  GHOOKER    Stub out procedures not used by RM8                 --
--------------------------------------------------------------------------------
END ADI_Header_Footer;

 

/
