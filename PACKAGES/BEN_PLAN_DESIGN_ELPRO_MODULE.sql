--------------------------------------------------------
--  DDL for Package BEN_PLAN_DESIGN_ELPRO_MODULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_DESIGN_ELPRO_MODULE" AUTHID CURRENT_USER as
/* $Header: bepdcprf.pkh 120.1 2006/02/28 03:28:34 rgajula noship $ */
--

  --Bug 5059695 Cursor to retreive the transaction category
     cursor g_trasaction_categories(c_copy_entity_txn_id number) is
	select ptc.short_name
	from PQH_COPY_ENTITY_TXNS pcet,
	     PQH_TRANSACTION_CATEGORIES ptc
	where pcet.COPY_ENTITY_TXN_ID= c_copy_entity_txn_id
	and ptc.TRANSACTION_CATEGORY_ID = pcet.TRANSACTION_CATEGORY_ID;

g_copy_entity_txn_id PQH_COPY_ENTITY_TXNS.COPY_ENTITY_TXN_ID%type := -999999;
g_trasaction_category     PQH_TRANSACTION_CATEGORIES.SHORT_NAME%type := null;

-- End Bug 5059695

procedure create_elpro_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number    -- Source Elpro
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in number
  ) ;
--
procedure create_dep_elpro_result
  (
   p_validate                       in number     default 0 -- false
  ,p_copy_entity_result_id          in number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in number
  ) ;
--
procedure create_elig_prfl_results
  (
   p_validate                       in  number    default 0 -- false
  ,p_mirror_src_entity_result_id    in  number
  ,p_parent_entity_result_id        in  number
  ,p_copy_entity_txn_id             in  number
  ,p_eligy_prfl_id                  in  number
  ,p_mndtry_flag                    in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_no_dup_rslt                    in varchar2 default null
  );
--
procedure create_dep_elig_prfl_results
  (
   p_validate                       in  number    default 0 -- false
  ,p_mirror_src_entity_result_id    in  number
  ,p_parent_entity_result_id        in  number
  ,p_copy_entity_txn_id             in  number
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_no_dup_rslt                    in varchar2 default null
  );
--
procedure create_eligy_criteria_result
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number
  ,p_copy_entity_txn_id             in  number
  ,p_eligy_criteria_id              in  number
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in  number
  ,p_no_dup_rslt                    in varchar2   default null
  );
--
end ben_plan_design_elpro_module;

 

/
