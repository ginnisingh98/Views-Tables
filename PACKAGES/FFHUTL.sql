--------------------------------------------------------
--  DDL for Package FFHUTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FFHUTL" AUTHID CURRENT_USER as
/* $Header: ffhutl.pkh 115.0 99/07/16 02:03:09 porting ship $ */
/*
  Copyright (c) Oracle Corporation (UK) Ltd 1993.
  All rights reserved

  Name:   ffhutl

  Description:

  Change List
  -----------
  P Gowers       10-MAR-1993     Rename package to ffhutl
*/
--
-------------------------------- load_harness --------------------------------
-- NAME
--   load_harness
-- DESCRIPTION
--   Copies the FDIU contents for a given formula into a harness table
--   which links each item with a value. The whole set of harness items
--   are referenced by formula_id and the value of userenv('SESSIONID')
--
procedure load_harness (p_formula_id in number);
--
------------------------------- delete_harness -------------------------------
-- NAME
--   delete_harness
-- DESCRIPTION
--   Deletes all entries in the harness for the current user determined by
--   userenv('SESSIONID')
--
procedure delete_harness;
--
end ffhutl;

 

/
