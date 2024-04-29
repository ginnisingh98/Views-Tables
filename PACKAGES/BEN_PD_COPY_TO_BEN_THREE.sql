--------------------------------------------------------
--  DDL for Package BEN_PD_COPY_TO_BEN_THREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PD_COPY_TO_BEN_THREE" AUTHID CURRENT_USER as
/* $Header: bepdccp3.pkh 120.0 2005/05/28 10:22:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_all_rt_prf_ben_rows >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
--
-- Start Log additions
--
TYPE g_not_mapped_log_rec_type Is RECORD(
    pk_id     number(15)
   ,text  varchar2(2000)
   );
--
TYPE not_mapped_log_table is table of g_not_mapped_log_rec_type index by binary_integer ;
--
g_not_copied_tbl            not_mapped_log_table ;
g_not_copied_tbl_count      number := 0 ;
g_parent_display_name        varchar2(80);
g_child_display_name         varchar2(80);
g_child_table_route_id      number :=null;
g_parent_table_route_id     number :=null;
--
procedure create_all_rt_prf_ben_rows(
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_txn_id             in  number
  ,p_effective_date                 in  date
  ,p_prefix_suffix_text             in  varchar2  default null
  ,p_reuse_object_flag              in  varchar2  default null
  ,p_target_business_group_id       in  varchar2  default null
  ,p_prefix_suffix_cd               in  varchar2  default null
 );
   procedure log_nomapping_data(p_parent_table_alias       in varchar2
                     ,p_parent_pk_id                       in number
                     ,p_copy_entity_txn_id                 in number
                     ,p_child_table_alias                  in varchar2
                     ,p_child_data                         in varchar2);

-- ----------------------------------------------------------------------------
end BEN_PD_COPY_TO_BEN_three;

 

/
