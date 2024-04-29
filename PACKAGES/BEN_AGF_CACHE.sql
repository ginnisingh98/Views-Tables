--------------------------------------------------------
--  DDL for Package BEN_AGF_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_AGF_CACHE" AUTHID CURRENT_USER AS
/* $Header: benagfch.pkh 115.2 2002/12/23 12:35:51 nhunur ship $ */
--
-- age factor
--
type g_cache_agf_object_rec is record
(age_fctr_id ben_age_fctr.age_fctr_id%type
,mx_age_num ben_age_fctr.mx_age_num%type
,mn_age_num ben_age_fctr.mn_age_num%type
,no_mn_age_flag ben_age_fctr.no_mn_age_flag%type
,no_mx_age_flag ben_age_fctr.no_mx_age_flag%type
);
--
type g_cache_agf_instor is table of g_cache_agf_object_rec index by binary_integer;


--
-- age factor
--
procedure agf_writecache
(p_effective_date in date
--
,p_refresh_cache in boolean default FALSE
);
--
procedure agf_getcacdets
(p_effective_date in date
,p_business_group_id in number
,p_age_fctr_id in number
--
,p_refresh_cache in boolean default FALSE
--
,p_inst_set out nocopy ben_agf_cache.g_cache_agf_instor
,p_inst_count out nocopy number
);
--
END ben_agf_cache;

 

/
