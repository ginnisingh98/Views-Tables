--------------------------------------------------------
--  DDL for Package JTFB_DCF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTFB_DCF" AUTHID CURRENT_USER AS
/* $Header: jtfbdcfs.pls 115.6 2002/02/27 14:00:45 pkm ship       $ */


  ------------------------------------------------------------------------
  --Created by  : Varun Puri
  --Date created: 03-OCT-2001
  --
  --Purpose:
  --  Creates the missing FND_MENU_ENTRIES for SECURITY data
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History: (who, when, what: NO CREATION RECORDS HERE!)
  --Who    When    What
  ------------------------------------------------------------------------
  PROCEDURE security_update;

procedure copy(
     source_region_code  in  varchar2
   , target_region_code  in  varchar2
);

---------------------------------------------------------------------------------
-- History:
-- 15-AUG-2001   Varun Puri   CREATED
--
-- This function returns the ICX Session ID
--
-- Returns: ICX Session ID
---------------------------------------------------------------------------------
FUNCTION get_icx_session_id RETURN NUMBER;

---------------------------------------------------------------------------------
-- History:
-- 28-JUN-2001   Varun Puri   CREATED
--
-- This function returns the parameter value of a parameter from parameter string.
-- It takes parameter string and parameter name as input. Parameter separator and
-- value separator too could be passed to this function. Default values are '&'
-- and '='.
--
-- Sample Usage:
--  SELECT jtfb_util.get_parameter_value('p1=v1',p1) from dual
-- Returns: v1
---------------------------------------------------------------------------------
FUNCTION  get_parameter_value(p_param_str  varchar2,
                              p_param_name varchar2,
                              p_param_sep  varchar2 default '&',
                              p_value_sep  varchar2 default '=') RETURN VARCHAR2;



-------------------------------------------------------------------------
-- History:
-- 28-JUN-2001    Varun Puri   CREATED
--
-- Returns the count of tokens, given the delimiter string
-- This function is used by get_multiselect_value
--
-- Sample Usage:
--  SELECT jtfb_util.get_multiselect_count('AB~~CD~~EF~~GH','~~') from dual
-- Returns: 4
--------------------------------------------------------------------------
FUNCTION get_multiselect_count(p_param_str VARCHAR2,
                               p_multi_sep VARCHAR2 default '~~') RETURN NUMBER;

-------------------------------------------------------------------------
-- History:
-- 28-JUN-2001    Varun Puri   CREATED
--
-- Returns the nth value of a delimiter seperated string
--
-- Sample Usage:
--  SELECT jtfb_util.get_multiselect_value('AB~~CD~~EF~~GH',2,'~~') from dual
-- Returns: CD
--------------------------------------------------------------------------
FUNCTION get_multiselect_value(p_param_str VARCHAR2,
                               pos         NUMBER,
                               p_multi_sep VARCHAR2 default '~~') RETURN VARCHAR2;

--
--
-------------------------------------------------------------------------------
-- Name
--    Lov_Upgrade
--
-- Purpose:
--    Updates Consumer Components LOV Parameter's Metadata. Changes include
--    updates to the value of flex_segment_list and the following attribute
--    substitutions.
--    Old                     New
--    --------------------    ----------
--    lov_region_code         attribute7
--    lov_foreign_key_name    attribute8
--    lov_attribute_code      attribute9
--    flex_segment_list       attribute10
--
-- Note:
--    The changes are committed if successful and rolled back if not.
--    Unexpected_Error Exception is raised in case of any Errors.

--
-- History:
--    28-SEP-2001, Elanchelvan Elango, Created
--
-- Sample Usage:
--    Login as APPS user.
--    SQL> set serveroutput on
--    SQL> exec jtfb_dcf.Lov_Upgrade;
--
-------------------------------------------------------------------------------
procedure Lov_Upgrade;
--
--
-------------------------------------------------------------------------------
-- Name
--    Graph_Upgrade
--
-- Purpose:
--    Updates display_sequence of DCF Component's Graph Metadata if they are
--    between 1 and 4, to the highest sequence between 601 and 699.
--
-- Note:
--    The changes are committed if successful and rolled back if not.
--    Unexpected_Error Exception is raised in case of any Errors.

--
-- History:
--    08-OCT-2001, Elanchelvan Elango, Created
--
-- Sample Usage:
--    Login as APPS user.
--    SQL> set serveroutput on
--    SQL> exec jtfb_dcf.Graph_Upgrade;
--
-------------------------------------------------------------------------------
procedure Graph_Upgrade;
--
--
-------------------------------------------------------------------------------
-- Name
--    Multiselect_Upgrade
--
-- Purpose:
--    Updates DCF Parameters of item_style 'MULTI_SELECT' to 'DATA'. Changes
--    are made to respective Ak_Attributes too.
--
-- Note:
--    The changes are committed if successful and rolled back if not.
--    Unexpected_Error Exception is raised in case of any Errors.

--
-- History:
--    08-OCT-2001, Elanchelvan Elango, Created
--
-- Sample Usage:
--    Login as APPS user.
--    SQL> set serveroutput on
--    SQL> exec jtfb_dcf.Multiselect_Upgrade;
--
-------------------------------------------------------------------------------
procedure Multiselect_Upgrade;
--
--
-------------------------------------------------------------------------------
-- Name
--    Audit_Columns_Patch
--
-- Purpose:
--    Updates the created_by and last_update_by columns of all DCF components
--    with the value from fnd_global.user_id. The updated tables include:
--    ak_regions, ak_regions_tl, ak_region_items, ak_region_items_tl. All the
--    language rows are updated in the translated tables. Once the patch is
--    applied the actions are irreversible.
--
-- Note:
--    1) Locking of rows before update has been given more priority over size
--       of cursor. So no intermediate Commits are done withing a cursor. Since
--       the update may involve a large number of rows, you must have a large
--       rollback segment available.
--    2) Unexpected_Error Exception is raised in case of any Errors.
--    3) If the Application Context is not set then fnd_global may have
--       invalid values. See Oracle Applications Developer's Guide, Release 11i
--
-- History:
-- 25-FEB-2002  eelango    Created.
--
-- Sample Usage:
--    Login as APPS user.
--    SQL> set serveroutput on
--    SQL> exec jtfb_dcf.Audit_Columns_Patch;
--
-------------------------------------------------------------------------------
procedure Audit_Columns_Patch(p_param_str  varchar2);
--
--
end jtfb_dcf;

 

/
