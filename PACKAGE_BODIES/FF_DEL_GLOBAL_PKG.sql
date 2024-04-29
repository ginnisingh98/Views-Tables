--------------------------------------------------------
--  DDL for Package Body FF_DEL_GLOBAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_DEL_GLOBAL_PKG" as
/* $Header: ffglb02t.pkb 120.0 2005/05/27 23:25:30 appldev noship $ */
--
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    FF_DEL_GLOBAL_PKG
  Purpose
    Package used to support delete operations on ff_globals_f.
  Notes

  History
    04-04-2001 K.Kawol     115.0        Date created.

 ============================================================================*/
 TYPE tab_globalid_type IS TABLE OF ff_globals_f.global_id%TYPE
      INDEX BY BINARY_INTEGER;
 --
 g_global_id  tab_globalid_type;
 g_global_ind BINARY_INTEGER;
 --
 -----------------------------------------------------------------------------
 -- Name
 --   Clear_Count
 -- Purpose
 --   Will be used in the Before Delete trigger on table ff_globals_f
 --   to empty the plsql table.
 -- Arguments
 --
 -- Notes
 --   None.
 -----------------------------------------------------------------------------
 PROCEDURE Clear_Count IS
 BEGIN
  g_global_ind := 0;
 END CLear_count;
 --
 -----------------------------------------------------------------------------
 -- Name
 --   Add_Global
 -- Purpose
 --   Used in the Before Delete row level trigger to add the primary key
 --   global_id of the record being deleted to the plsql table.
 -- Arguments
 --   See below.
 -- Notes
 --   None.
 -----------------------------------------------------------------------------
--
 PROCEDURE Add_Global (p_global_id in ff_globals_f.global_id%TYPE) IS
 BEGIN
  g_global_ind := g_global_ind + 1;
  g_global_id(g_global_ind) := p_global_id;
 END Add_Global;
 --
 -----------------------------------------------------------------------------
 -- Name
 --   Delete_User_Entity
 -- Purpose
 --   Used in the After Delete statement level trigger on ff_globals_f
 --   and checks that no rows with the same global id exists before going
 --   on to delete user_entities and database items.
 -- Arguments
 --   See below.
 -- Notes
 --   None.
 -----------------------------------------------------------------------------
 PROCEDURE Delete_User_Entity IS
  l_globalid ff_globals_f.global_id%TYPE;
  no_of_global number;
 --
 BEGIN
  FOR i in 1..g_global_ind LOOP
    l_globalid := g_global_id(i);

    select count(*)
      into no_of_global
      from ff_globals_f
     where global_id = l_globalid;

    if (no_of_global = 0) then
      delete from ff_user_entities
      where creator_id = l_globalid
      and creator_type = 'S';
    end if;

  END LOOP;
  --
 END Delete_User_Entity;
 --
END FF_DEL_GLOBAL_PKG;

/
