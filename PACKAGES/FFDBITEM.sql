--------------------------------------------------------
--  DDL for Package FFDBITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FFDBITEM" AUTHID CURRENT_USER as
/* $Header: ffdbitem.pkh 115.0 99/07/16 02:02:20 porting ship $ */
--
--
--   Copyright (c) Oracle Corporation (UK) Ltd 1994.
--   All Rights Reserved.
--
--   PRODUCT
--     Oracle*FastFormula
--
--   NAME
--     ffdbitem
--
--   NOTES
--     Contains utility functions and procedures for accessing database
--     item SQL and values
--
--   MODIFIED
--   pgowers         09-FEB-94    Created
--   rneale	     19-MAY-94	  Added exit.
--   jthuring        11-OCT-95    Removed spurious start of comment marker
--   mfender         11-JUN-97	  Create package statement to standard for
--                                release 11.
--
-- PUBLIC TYPES
--
type NAMES is table of ff_contexts.context_name%TYPE
  index by binary_integer;
type TYPES is table of ff_contexts.data_type%TYPE
  index by binary_integer;
type VALS is table of varchar2(255)
  index by binary_integer;

type FFCONTEXTS_T is record (
  context_count number,
  context_names NAMES,
  context_types TYPES,
  bind_names NAMES,
  bind_values VALS);

type FFITEM_INFO_T is record (
  item_name FF_DATABASE_ITEMS.USER_NAME%TYPE,
  item_sql  varchar2(8000),
  data_type varchar2(1), -- T=Text, N=Number, D=Date
  notfound_ok boolean,   -- TRUE means notfound is legal
  null_ok boolean,        -- TRUE means null is legal
  contexts FFCONTEXTS_T);

--
-- PUBLIC PROTOTYPES

------------------------------- get_dbitem_sql -------------------------------
--
-- NAME
--  get_dbitem_sql
--
-- DESCRIPTION
--   Returns all information for a database item required to fetch it's value
--   including SQL, context requirements, data type in FFITEM_INFO_T
--   given the database item name, formula type id, business group id
--   and legislation code
--
procedure get_dbitem_info (p_item_name in varchar2,
                           p_formula_type_id in number,
                           p_bg_id in number,
                           p_leg_code in varchar2,
                           p_item_info out FFITEM_INFO_T);
--
------------------------------ get_dbitem_value ------------------------------
--
-- NAME
--  get_dbitem_value
--
-- DESCRIPTION
--   Returns the value of a database item given the item details
--
function get_dbitem_value (p_item_info in FFITEM_INFO_T) return varchar2;
--
end ffdbitem;

 

/
