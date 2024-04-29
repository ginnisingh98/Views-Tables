--------------------------------------------------------
--  DDL for Package WF_DIRECTORY_PART_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_DIRECTORY_PART_UTIL" AUTHID CURRENT_USER as
/* $Header: wfdpus.pls 115.0 2003/12/27 00:18:27 dlam noship $ */

-- Validate_Display_Name
-- Validates that a display name is both unique and valid.  If the display
-- name is passed in then it will set the internal user name.
procedure validate_display_name (
p_display_name in varchar2,
p_user_name    in out nocopy varchar2);

end WF_DIRECTORY_PART_UTIL;

 

/
