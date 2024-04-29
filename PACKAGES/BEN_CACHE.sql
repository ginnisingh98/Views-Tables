--------------------------------------------------------
--  DDL for Package BEN_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CACHE" AUTHID CURRENT_USER AS
/* $Header: bencache.pkh 115.12 2002/12/24 15:44:02 bmanyam ship $ */
--
type g_cache_lookup is record
  (id              number
  ,fk_id           number
  ,fk1_id          number
  ,fk2_id          number
  ,fk3_id          number
  ,fk4_id          number
  ,fk5_id          number
  ,v2value_1       varchar2(100)
  ,datevalue_1     date
  ,starttorele_num binary_integer
  ,endtorele_num   binary_integer
  );
--
type g_cache_lookup_table is table of g_cache_lookup index by binary_integer;
--
type IdRecType is record
  (id number
  );
--
type IdType is table of IdRecType index by binary_integer;
--
--   Table details record type
--
Type TabDetRecType      is record
  (tab_name     varchar2(100)
  ,tab_jncolnm  varchar2(100)
  ,tab_datetype varchar2(100)
  );
--
Type TabDetType is table of TabDetRecType index by binary_integer;
--
--   Column/cache details record type
--
Type InstColNmRecType      is record
  (col_name    varchar2(100)
  ,caccol_name varchar2(100)
  ,asscol_name varchar2(100)
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
g_tabdet_set                ben_cache.TabDetType;
g_instcolnm_set             ben_cache.InstColNmType;
g_curparm_set               ben_cache.CurParmType;
g_id_set                    ben_cache.IdType;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< Write_MastDet_Cache >------------------------|
--  ---------------------------------------------------------------------------
--
--  Write a master detail cache
--
procedure Write_MastDet_Cache
  (p_mastercol_name    in     varchar2
  ,p_detailcol_name    in     varchar2
  ,p_masterfkcol_name  in     varchar2 default null
  ,p_masterfk1col_name in     varchar2 default null
  ,p_masterfk2col_name in     varchar2 default null
  ,p_masterfk3col_name in     varchar2 default null
  ,p_masterfk4col_name in     varchar2 default null
  ,p_masterfk5col_name in     varchar2 default null
  ,p_lkup_name         in     varchar2
  ,p_inst_name         in     varchar2
  ,p_lkup_query        in     varchar2
  ,p_inst_query        in     varchar2
  ,p_nonmand_hv        in     boolean  default false
  ,p_coninst_query     in     varchar2 default null
  ,p_conlkup_name      in     varchar2 default null
  ,p_dtconlkup_ccolnm  in     varchar2 default null
  ,p_dtconlkup_value   in     date     default null
  ,p_instcolnm_set     in     ben_cache.InstColNmType
                             default ben_cache.g_instcolnm_set
  ,p_curparm_set       in     ben_cache.CurParmType
                             default ben_cache.g_curparm_set
  );
--
--  ---------------------------------------------------------------------------
--  |----------------------------< Write_BGP_Cache >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Write a cache below a business group
--
procedure Write_BGP_Cache
  (p_mastertab_name    in     varchar2
  ,p_masterpkcol_name  in     varchar2
  ,p_masterfkcol_name  in     varchar2 default null
  ,p_masterfk1col_name in     varchar2 default null
  ,p_masterfk2col_name in     varchar2 default null
  ,p_masterfk3col_name in     varchar2 default null
  ,p_masterfk4col_name in     varchar2 default null
  ,p_masterfk5col_name in     varchar2 default null
  ,p_masid_set         in     ben_cache.IdType default ben_cache.g_id_set
  ,p_tabdet_set        in     ben_cache.TabDetType default ben_cache.g_tabdet_set
  ,p_table1_name       in     varchar2
  ,p_tab1jncol_name    in     varchar2 default null
  ,p_table2_name       in     varchar2 default null
  ,p_tab2jncol_name    in     varchar2 default null
  ,p_table3_name       in     varchar2 default null
  ,p_business_group_id in     number
  ,p_effective_date    in     date     default null
  ,p_context1_colname  in     varchar2 default null
  ,p_context1_id       in     number   default null
  ,p_nonmand_hv        in     boolean  default false
  ,p_lkup_name         in     varchar2
  ,p_inst_name         in     varchar2
  ,p_inst_frclause     in     varchar2 default null
  ,p_lkup_whclause     in     varchar2 default null
  ,p_inst_whclause     in     varchar2 default null
  ,p_inst_queryorby    in     varchar2 default null
  ,p_lkup_subqyhint    in     varchar2 default null
  ,p_lkup_query        in     varchar2 default null
  ,p_instcolnm_set     in     ben_cache.InstColNmType
                              default ben_cache.g_instcolnm_set
  ,p_curparm_set       in     ben_cache.CurParmType
                              default ben_cache.g_curparm_set
  );
--
function check_list_duplicate
  (p_list in out nocopy ben_cache.IdType
  ,p_id   in     number
  )
return boolean;
--
END ben_cache;

 

/
