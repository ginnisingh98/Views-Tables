--------------------------------------------------------
--  DDL for Package BEN_BATCH_DT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_DT_API" AUTHID CURRENT_USER as
/* $Header: bendtapi.pkh 115.5 2003/09/18 16:00:18 mhoyes noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Comp Object Caching Routine
Purpose
	This package is used to return comp object information.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        15 May 99        mhoyes     115.0      Created
        29 Dec 00        Tmathers   115.1      fixed check_sql errors.
        22 May 01        mhoyes     115.2      Added batch_validate_bgp_id.
        18 Sep 03        mhoyes     115.4      3150329 - Update eligibility
                                               APIs.
*/
--------------------------------------------------------------------------------
--
-- Cache all comp object stuff
--
type gtyp_dtsum_row is record
  (id        number
  ,min_esd   date
  ,max_eed   date
  );
--
type gtyp_dtsum_tab is table of gtyp_dtsum_row index by binary_integer;
--
-- On demand caches
--
g_person_dtsum_odcache   gtyp_dtsum_tab;
g_ler_dtsum_odcache      gtyp_dtsum_tab;
g_pgm_dtsum_odcache      gtyp_dtsum_tab;
g_ptip_dtsum_odcache     gtyp_dtsum_tab;
g_plip_dtsum_odcache     gtyp_dtsum_tab;
g_pl_dtsum_odcache       gtyp_dtsum_tab;
g_elig_per_dtsum_odcache gtyp_dtsum_tab;
--
-- Caches current rows
--
g_lastperson_dtsum_row   gtyp_dtsum_row;
g_lastler_dtsum_row      gtyp_dtsum_row;
g_lastpgm_dtsum_row      gtyp_dtsum_row;
g_lastptip_dtsum_row     gtyp_dtsum_row;
g_lastplip_dtsum_row     gtyp_dtsum_row;
g_lastpl_dtsum_row       gtyp_dtsum_row;
g_lastelig_per_dtsum_row gtyp_dtsum_row;
--
-- Get start and end dates
--
procedure Get_DtIns_Start_and_End_Dates
  (p_effective_date in            date
  ,p_parcolumn_name in            varchar2
  ,p_min_esd        in            date
  ,p_max_eed        in            date
  --
  ,p_esd            in out nocopy date
  ,p_eed            in out nocopy date
  );
--
-- Get object routines
--
procedure get_personobject
  (p_person_id in     number
  ,p_rec       in out NOCOPY gtyp_dtsum_row
  );
--
procedure get_lerobject
  (p_ler_id in     number
  ,p_rec    in out NOCOPY gtyp_dtsum_row
  );
--
procedure get_pgmobject
  (p_pgm_id in     number
  ,p_rec    in out NOCOPY gtyp_dtsum_row
  );
--
procedure get_ptipobject
  (p_ptip_id in     number
  ,p_rec     in out NOCOPY gtyp_dtsum_row
  );
--
procedure get_plipobject
  (p_plip_id in     number
  ,p_rec     in out NOCOPY gtyp_dtsum_row
  );
--
procedure get_plobject
  (p_pl_id in     number
  ,p_rec   in out NOCOPY gtyp_dtsum_row
  );
--
procedure get_elig_perobject
  (p_elig_per_id in     number
  ,p_rec   in out NOCOPY gtyp_dtsum_row
  );
--
procedure clear_down_cache;
--
procedure batch_validate_bgp_id
  (p_business_group_id in number
  );
--
procedure validate_dt_mode_insert
  (p_effective_date       in     date
  ,p_person_id            in     number default null
  ,p_ler_id               in     number default null
  ,p_pgm_id               in     number default null
  ,p_ptip_id              in     number default null
  ,p_plip_id              in     number default null
  ,p_pl_id                in     number default null
  --
  ,p_effective_start_date in out nocopy date
  ,p_effective_end_date   in out nocopy date
  );
--
PROCEDURE return_effective_dates
  (p_base_table_name      IN      varchar2
  ,p_effective_date       IN      DATE
  ,p_base_key_value       IN      NUMBER
  --
  ,p_effective_start_date in out nocopy date
  ,p_effective_end_date   in out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< Return_Max_End_Date >---------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION return_max_end_date
  (p_base_table_name IN  varchar2
  ,p_base_key_value  IN  NUMBER
  )
RETURN DATE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Future_Rows_Exists >---------------------------|
-- ----------------------------------------------------------------------------
--
Function Future_Rows_Exist
  (p_base_table_name IN     varchar2
  ,p_effective_date  in     date
  ,p_base_key_value  in     number
  )
return Boolean;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< validate_dt_mode_pep >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure validate_dt_mode_pep
  (p_effective_date        in     date
  ,p_datetrack_mode        in     varchar2
  ,p_elig_per_id           in     number
  --
  ,p_validation_start_date in out nocopy date
  ,p_validation_end_date   in out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< validate_dt_mode_epo >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure validate_dt_mode_epo
  (p_effective_date        in     date
  ,p_datetrack_mode        in     varchar2
  ,p_elig_per_opt_id       in     number
  --
  ,p_validation_start_date in out nocopy date
  ,p_validation_end_date   in out nocopy date
  );
--
end ben_batch_dt_api;

 

/
