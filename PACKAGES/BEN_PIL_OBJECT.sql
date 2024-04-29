--------------------------------------------------------
--  DDL for Package BEN_PIL_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PIL_OBJECT" AUTHID CURRENT_USER as
/* $Header: bepilobj.pkh 120.0 2005/05/28 10:50:20 appldev noship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Person Object Caching Routine
Purpose
	This package is used to return person object information.
History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      11-Jun-99  gperry     Created.
  115.1      20-Mar-02  vsethi     added dbdrv lines
  -----------------------------------------------------------------------------
*/
--
-- Global type declarations.
--
type g_cache_pil_table is table of ben_per_in_ler%rowtype index
  by binary_integer;
--
g_cache_pil_rec         g_cache_pil_table;
--
-- Latest record caches
--
g_cache_last_pil_rec    ben_per_in_ler%rowtype;
--
-- Set object routines
--
procedure set_object
  (p_rec in out nocopy ben_per_in_ler%rowtype
  );
--
-- Get object routines
--
procedure get_object
  (p_per_in_ler_id in  number
  ,p_rec           in out nocopy ben_per_in_ler%rowtype
  );
--
procedure clear_down_cache;
--
end ben_pil_object;

 

/
