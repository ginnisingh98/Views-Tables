--------------------------------------------------------
--  DDL for Package BEN_HASH_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_HASH_UTILITY" AUTHID CURRENT_USER as
/* $Header: benhashu.pkh 120.1 2005/06/12 21:04:33 mhoyes noship $ */
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
	This package is used to aid in the hashing of ids within benefits
        tables. This is used as a support for caching data during batch
        processes.
History
        Date             Who        Version  What?
        ----             ---        -------  -----
        01-MAY-99        GPERRY     115.0    Created.
        15-JUN-99        mhoyes     115.1    Added generic cache write
                                             routines. Write_MastDet_Cache
                                             and Write_BGP_Cache.
        12-JUN-05        mhoyes     115.4    Removed Write_MastDet_Cache
                                             and Write_BGP_Cache. Defined
                                             package locals as globals.
*/

-----------------------------------------------------------------------
--
-- PLSQL record types
--
--   Column/cache details record type
--
Type InstColNmRecType      is record
  (col_name    varchar2(100)
  ,caccol_name varchar2(100)
  ,col_alias   varchar2(100)
  ,col_type    varchar2(100)
  );
--
Type InstColNmType      is table of InstColNmRecType index by binary_integer;
--
--   Cursor details record type
--
Type CurParmRecType      is record
  (cur_type  varchar2(100)
  ,parm_type varchar2(100)
  ,name      varchar2(100)
  ,datatype  varchar2(100)
  ,v2val     varchar2(2000)
  ,dateval   date
  ,numval    number
  );
--
Type CurParmType      is table of CurParmRecType     index by binary_integer;
--
-- Globals
--
g_instcolnm_set             ben_hash_utility.InstColNmType;
g_curparm_set               ben_hash_utility.CurParmType;
-----------------------------------------------------------------------
-- Hash Variables
-----------------------------------------------------------------------
g_hash_key      binary_integer := 1299827; -- 100008th Prime number
g_hash_jump     binary_integer := 100;
-----------------------------------------------------------------------
function get_hashed_index(p_id in number) return number;
-----------------------------------------------------------------------
function get_next_hash_index(p_hash_index in number) return number;
-----------------------------------------------------------------------
function get_hash_jump return number;
-----------------------------------------------------------------------
function get_hash_key return number;
-----------------------------------------------------------------------
procedure set_hash_jump(p_hash_jump in number);
-----------------------------------------------------------------------
procedure set_hash_key(p_hash_key in number);
-----------------------------------------------------------------------
end ben_hash_utility;

 

/
