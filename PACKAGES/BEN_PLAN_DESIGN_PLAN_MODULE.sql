--------------------------------------------------------
--  DDL for Package BEN_PLAN_DESIGN_PLAN_MODULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_DESIGN_PLAN_MODULE" AUTHID CURRENT_USER as
/* $Header: bepdcpln.pkh 115.8 2004/01/13 11:44:24 rpillay noship $ */
--
procedure create_plan_result
  (
   p_validate                       in number     default 0 -- false
  ,p_copy_entity_result_id          out nocopy number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_plip_id                         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_no_dup_rslt                    in  varchar2  default null
  ) ;
--
-- Overloaded create_plan_result for Plan Design Wizard
-- This has been overloaded to allow copying Plans to staging area
-- without setting information8 to PLNIP
--
procedure create_plan_result
  (
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_result_id          out nocopy number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in date
  ,p_no_dup_rslt                    in varchar2   default null
  ,p_plan_in_program                in varchar2
  );
--
procedure create_popl_result
  (
   p_validate                       in number     default 0 -- false
  ,p_copy_entity_result_id          in number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in  number
  ) ;
--
procedure create_ler_result
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_no_dup_rslt                    in  varchar2  default null
  ) ;
  --
 procedure create_oipl_result
  (  p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number
    ,p_copy_entity_txn_id             in  number
    ,p_oipl_id                        in  number
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_parent_entity_result_id        in  number
    ,p_no_dup_rslt                    in  varchar2  default null
  );
  --
  procedure create_opt_result
  (  p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number
    ,p_copy_entity_txn_id             in  number
    ,p_opt_id                         in  number
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_parent_entity_result_id        in  number
    ,p_no_dup_rslt                    in  varchar2  default null
  );
  --
  procedure create_pl_typ_result
  (  p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number
    ,p_copy_entity_txn_id             in  number
    ,p_pl_typ_id                      in  number
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_parent_entity_result_id        in  number
    ,p_no_dup_rslt                    in  varchar2  default null
    );
  --
  procedure create_yr_perd_result
  (  p_validate                       in  number     default 0 -- false
    ,p_copy_entity_result_id          in  number
    ,p_copy_entity_txn_id             in  number
    ,p_yr_perd_id                     in  number
    ,p_business_group_id              in  number    default null
    ,p_number_of_copies               in  number    default 0
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_parent_entity_result_id        in  number
    ,p_no_dup_rslt                    in  varchar2  default null
    );
  --
end ben_plan_design_plan_module;

 

/
