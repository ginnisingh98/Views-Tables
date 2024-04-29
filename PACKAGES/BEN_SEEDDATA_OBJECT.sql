--------------------------------------------------------
--  DDL for Package BEN_SEEDDATA_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SEEDDATA_OBJECT" AUTHID CURRENT_USER as
/* $Header: benseedc.pkh 115.3 2002/12/19 09:52:02 hmani ship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Lookup Object Caching Routine
Purpose
	This package is used to return lookup object information.
History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      18-JUN-99  gperry     Created
  115.1      04-OCT-99  stee       Added drvdlselg, drvdnlp,
                                   drvdpoeelg, drvdpoert and drvdvec.
  115.2      11-NOV-99  stee       Added drvdvec.
  115.3      19-dec-2002  hmani    NoCopy changes
  -----------------------------------------------------------------------------
*/
--
type g_derived_factor_info_rec is record
  (drvdage_id                   number,
   drvdlos_id                   number,
   drvdcmp_id                   number,
   drvdcal_id                   number,
   drvdtpf_id                   number,
   drvdhrw_id                   number,
   drvdlselg_id                 number,
   drvdnlp_id                   number,
   drvdpoeelg_id                number,
   drvdpoert_id                 number,
   drvdvec_id                   number
);
--
-- Global type declarations.
--
g_cache_derived_factor_rec  g_derived_factor_info_rec;
--
-- Set object routines
--
procedure set_object
  (p_rec in g_derived_factor_info_rec);
--
procedure set_object
  (p_effective_date    in date,
   p_business_group_id in number,
   p_rec               out nocopy g_derived_factor_info_rec);
--
-- Get object routines
--
procedure get_object
  (p_rec       out nocopy g_derived_factor_info_rec);
--
procedure clear_down_cache;
--
end ben_seeddata_object;

 

/
