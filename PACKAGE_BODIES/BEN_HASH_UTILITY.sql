--------------------------------------------------------
--  DDL for Package Body BEN_HASH_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_HASH_UTILITY" as
/* $Header: benhashu.pkb 120.1 2005/06/12 21:04:48 mhoyes noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Benefit Hash Utility.
Purpose
	This package is used to provide consistent hashing algorhythms for
        caching of data strucutures within benefits.
History
        Date             Who        Version What?
        ----             ---        ------- -----
        01-MAY-99        GPERRY     115.0   Created.
        06-MAY-99        mhoyes     115.1   Commented out hr_utility
                                            statements.
        09-MAY-99        mhoyes     115.2   Removed hr_utility
                                            statements from all
                                            procedures.
        15-JUN-99        mhoyes     115.3   Added generic cache write
                                            routines. Write_MastDet_Cache
                                            and Write_BGP_Cache.
        19-Oct-2003      nhunur     115.4   Made changes in write_mastdet_cache. Bug - 3125540.
        12-JUN-05        mhoyes     115.7    Removed Write_MastDet_Cache
                                             and Write_BGP_Cache. Defined
                                             package locals as globals.
*/
function get_hashed_index(p_id in number) return number is
  --
begin
  --
  return mod(p_id,g_hash_key);
  --
end get_hashed_index;
--
function get_next_hash_index(p_hash_index in number) return number is
  --
begin
  --
  return p_hash_index+g_hash_jump;
  --
end get_next_hash_index;
--
function get_hash_jump return number is
  --
begin
  --
  return g_hash_jump;
  --
end get_hash_jump;
--
function get_hash_key return number is
  --
begin
  --
  return g_hash_key;
  --
end get_hash_key;
--
-- Hopefully noone will ever use this routine as the clashing could be
-- increased but include it in cases where we know all data is under the limits
-- of 2**32
--
procedure set_hash_key(p_hash_key in number) is
  --
begin
  --
  g_hash_key := p_hash_key;
  --
end set_hash_key;
--
-- If the data is very random then it could be worth increasing the jump
-- value so I included the routine to do this.
--
procedure set_hash_jump(p_hash_jump in number) is
  --
begin
  --
  g_hash_jump := p_hash_jump;
  --
end set_hash_jump;
-----------------------------------------------------------------------
end ben_hash_utility;

/
