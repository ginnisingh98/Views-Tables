--------------------------------------------------------
--  DDL for Package Body FFHUTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FFHUTL" as
/* $Header: ffhutl.pkb 115.0 99/07/16 02:03:06 porting ship $ */
/*
  Copyright (c) Oracle Corporation (UK) Ltd 1993.
  All rights reserved

  Name:   ffhutl

  Description:

  Change List
  -----------
  D Saxby        18-JUL-1995     Moved the arcs header line.
  P Gowers       10-MAR-1993     Rename package to ffhutl
*/
-------------------------------- load_harness --------------------------------
-- NAME
--   load_harness
-- DESCRIPTION
--   Copies the FDIU contents for a given formula into a harness table
--   which links each item with a value. The whole set of harness items
--   are referenced by formula_id and a test_id which is like a session
--   id for the current test formula form
--
procedure load_harness (p_formula_id in number) is
begin
  -- get rid of any old rows first (there shouldn't be any)
  hr_utility.set_location ('ffhutl.load_harness', 1);
  delete from ff_harness
  where test_id = userenv('SESSIONID') and formula_id = p_formula_id;
--
  -- create new rows based on the formula_id and test_id passed containing
  -- all input variables for the formula
  -- NOTE all 'B' usages are indicated as 'I' because at the harness level
  -- outputs are completely separate and unrelated to inputs
  hr_utility.set_location ('ffhutl.load_harness', 2);
  insert into ff_harness (test_id, formula_id, item_name, data_type, usage)
  select userenv('SESSIONID'), p_formula_id, item_name, data_type,
         decode (usage, 'B', 'I', usage)
  from ff_fdi_usages
  where formula_id = p_formula_id
  and (usage = 'I' or usage = 'B' or usage = 'U');
end load_harness;
------------------------------- delete_harness -------------------------------
-- NAME
--   delete_harness
-- DESCRIPTION
--   Deletes all entries in the harness for the current user determined by
--   the test id passed as a parameter
--
procedure delete_harness is
begin
  hr_utility.set_location ('ffhutl.delete_harness', 1);
  delete from ff_harness where test_id = userenv('SESSIONID');
end delete_harness;
--
end ffhutl;

/
