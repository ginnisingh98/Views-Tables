--------------------------------------------------------
--  DDL for Package BEN_LIFE_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LIFE_OBJECT" AUTHID CURRENT_USER as
/* $Header: benlerde.pkh 120.0 2005/05/28 09:06:00 appldev noship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Life Event Object Caching Routine
Purpose
	This package is used to return life event object information.
History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      25-Jun-99  gperry     Created
  115.1      13-Dec-02  kmahendr   Nocopy changes
  -----------------------------------------------------------------------------
*/
--
-- Global type declarations.
--
type g_cache_ler_table is table of ben_ler_f%rowtype index
  by binary_integer;
--
type g_cache_css_table is table of ben_css_rltd_per_per_in_ler_f%rowtype index
  by binary_integer;
--
type g_cache_css_ler_table is table of ben_cache.g_cache_lookup index
  by binary_integer;
--
type g_cache_ler_ler_table is table of ben_cache.g_cache_lookup index
  by binary_integer;
--
g_cache_ler_rec         g_cache_ler_table;
g_cache_ler_ler_rec     g_cache_ler_ler_table;
g_cache_css_rec         g_cache_css_table;
g_cache_css_ler_rec     g_cache_css_ler_table;
--
-- Set object routines
--
procedure set_object
  (p_rec in ben_ler_f%rowtype);
procedure set_object
  (p_rec in ben_css_rltd_per_per_in_ler_f%rowtype);
procedure set_css_ler_object
  (p_rec in ben_cache.g_cache_lookup);
procedure set_ler_ler_object
  (p_rec in ben_cache.g_cache_lookup);
--
procedure set_ler_object
  (p_ler_id            in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               out nocopy ben_ler_f%rowtype);
--
procedure set_css_object
  (p_ler_id            in  number,
   p_business_group_id in  number,
   p_effective_date    in  date,
   p_rec               out nocopy g_cache_css_table);
--
-- Get object routines
--
procedure get_object
  (p_ler_id    in  number,
   p_rec       out nocopy ben_ler_f%rowtype);
procedure get_object
  (p_ler_id    in  number,
   p_rec       out nocopy g_cache_css_table);
--
procedure clear_down_cache;
--
end ben_life_object;

 

/
