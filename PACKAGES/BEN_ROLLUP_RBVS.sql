--------------------------------------------------------
--  DDL for Package BEN_ROLLUP_RBVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ROLLUP_RBVS" AUTHID CURRENT_USER AS
/* $Header: benrbvru.pkh 120.0 2005/05/28 09:25:35 appldev noship $ */
--
PROCEDURE build_rollup_sql_str
  (p_rt_cd_va       in out nocopy benutils.g_v2_150_table
  ,p_rt_fromstr_va  in out nocopy benutils.g_varchar2_table
  ,p_rt_wherestr_va in out nocopy benutils.g_varchar2_table
  ,p_rt_sqlstr_va   in out nocopy benutils.g_varchar2_table
  ,p_rt_typcd_va    in out nocopy benutils.g_v2_150_table
  );
--
PROCEDURE get_rollup_code_sql_dets
  (p_rollup_code in            varchar2
  --
  ,p_from_str    in out nocopy varchar2
  ,p_where_str   in out nocopy varchar2
  ,p_sql_str     in out nocopy varchar2
  );
--
PROCEDURE get_rollup_code_perid_va
  (p_rollup_code           in            varchar2
  ,p_old_benefit_action_id in            number
  ,p_new_benefit_action_id in            number
  --
  ,p_perid_va              in out nocopy benutils.g_number_table
  );
--
PROCEDURE get_rollup_code_combkey_va
  (p_rollup_code           in            varchar2
  ,p_old_benefit_action_id in            number
  ,p_new_benefit_action_id in            number
  --
  ,p_perid_va              in out nocopy benutils.g_number_table
  ,p_perlud_va             in out nocopy benutils.g_date_table
  ,p_combnm_va             in out nocopy benutils.g_varchar2_table
  ,p_combnm2_va            in out nocopy benutils.g_varchar2_table
  ,p_combnm3_va            in out nocopy benutils.g_varchar2_table
  ,p_combnm4_va            in out nocopy benutils.g_varchar2_table
  ,p_combid_va             in out nocopy benutils.g_number_table
  ,p_combid2_va            in out nocopy benutils.g_number_table
  ,p_combid3_va            in out nocopy benutils.g_number_table
  ,p_combid4_va            in out nocopy benutils.g_number_table
  ,p_cnt_va                in out nocopy benutils.g_number_table
  );
--
PROCEDURE rollup_benmngle_rbvs
  (p_benefit_action_id in     number
  ,p_refresh_rollups   in     varchar2 default 'N'
  );
--
END ben_rollup_rbvs;

 

/
