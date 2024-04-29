--------------------------------------------------------
--  DDL for Package BEN_LOS_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LOS_CACHE" AUTHID CURRENT_USER AS
/* $Header: benlosch.pkh 115.2 2003/02/12 10:38:05 rpgupta ship $ */
--
-- length of service factor
--
type g_cache_los_object_rec is record
(los_fctr_id ben_los_fctr.los_fctr_id%type
,mx_los_num ben_los_fctr.mx_los_num%type
,mn_los_num ben_los_fctr.mn_los_num%type
,no_mn_los_num_apls_flag ben_los_fctr.no_mn_los_num_apls_flag%type
,no_mx_los_num_apls_flag ben_los_fctr.no_mx_los_num_apls_flag%type
);
--
type g_cache_los_instor is table of g_cache_los_object_rec index by binary_integer;
--
-- length of service factor
--
procedure los_writecache
(p_effective_date in date
--
,p_refresh_cache in boolean default FALSE
);
--
procedure los_getcacdets
(p_effective_date in date
,p_business_group_id in number
,p_los_fctr_id in number
--
,p_refresh_cache in boolean default FALSE
--
,p_inst_set out nocopy ben_los_cache.g_cache_los_instor
,p_inst_count out nocopy number
);
--
END ben_los_cache;

 

/
