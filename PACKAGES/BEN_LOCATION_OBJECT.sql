--------------------------------------------------------
--  DDL for Package BEN_LOCATION_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LOCATION_OBJECT" AUTHID CURRENT_USER as
/* $Header: benlocch.pkh 120.0 2005/05/28 09:06:56 appldev noship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      08-Jun-99  bbulusu    Created.
  115.1      05-Aug-99  gperry     Added last record cached logic.
  115.2      16-Aug-99  GPERRY     Added nocopy compiler directive.
  115.3      06 May 00  RChase     Added addtional NOCOPY compiler directives.
  115.4      12 Dec 01  Tmathers   dos2unix for 2128462.
  -----------------------------------------------------------------------------
*/
--
type g_cache_loc_table is table of hr_locations_all%rowtype index
  by binary_integer;
--
g_cache_loc_rec         g_cache_loc_table;
g_cache_last_loc_rec    hr_locations_all%rowtype;
--
-- Set object routines
--
procedure set_object
  (p_rec in out nocopy hr_locations_all%rowtype);
--
procedure set_loc_object
  (p_location_id       in number,
   p_rec               in out nocopy hr_locations_all%rowtype);
--
-- Get object routines
--
procedure get_object
  (p_location_id in  number,
   p_rec         in out nocopy hr_locations_all%rowtype);
--
procedure clear_down_cache;
--
end ben_location_object;

 

/
