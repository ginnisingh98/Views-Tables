--------------------------------------------------------
--  DDL for Package BEN_SAZ_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SAZ_CACHE" AUTHID CURRENT_USER as
/* $Header: bensazch.pkh 120.0.12010000.1 2008/07/29 12:31:12 appldev ship $*/
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Who	   What?
  ---------  ---------	---------- --------------------------------------------
  115.0      17-Sep-00	mhoyes     Created.
  115.2    11-dec-2002  hmani      NoCopy changes
  -----------------------------------------------------------------------------
*/
--
-- Check if the zip code and service area combination exists in
-- ben_svc_area_pstl_zip_rng_f
--
procedure SAZRZR_Exists
  (p_svc_area_id in     number
  ,p_zip_code    in     varchar2
  ,p_eff_date    in     date
  --
  ,p_exists         out nocopy boolean
  );
--
------------------------------------------------------------------------
-- DELETE CACHED DATA
------------------------------------------------------------------------
procedure clear_down_cache;
--
END ben_saz_cache;

/
