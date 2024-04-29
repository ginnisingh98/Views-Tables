--------------------------------------------------------
--  DDL for Package BEN_PLAN_DESIGN_TXNS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_DESIGN_TXNS_API" AUTHID CURRENT_USER as
/* $Header: becetapi.pkh 120.0 2005/05/28 01:01:17 appldev noship $ */
--
-- REUSE ENHANCEMENT
g_pgm_pl_prefix_suffix_text varchar2(300);
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PLAN_DESIGN_TXN >------------------------|
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
--   p_validate                     Yes  number   Commit or Rollback.
--   p_transaction_category_id      Yes  number
--   p_txn_category_attribute_id    Yes  number    Descriptive Flexfield
--   p_context_business_group_id    No   number
--   p_datetrack_mode               No   varchar2
--   p_proc_typ_cd                  No   varchar2
--   action_date                    No  date      default null
--   src_effective_date             No  date      default null
--   p_number_of_copies             No   number
--   p_process_name                 No   varchar2
--   p_replacement_type_cd          No   varchar2
--   p_sfl_step_name                No   varchar2
--   p_increment_by                 No   number
--   p_status                       No   varchar2
--   p_effective_date               Yes  date      Session Date.
--   p_copy_entity_txn_id           Yes  number
--   p_row_type_cd                  No   varchar2
--   p_information_category         No   varchar2
--   p_prefix_suffix_text           No   varchar2
--   p_export_file_name             No   varchar2
--   p_target_typ_cd                No   varchar2
--   p_reuse_object_flag            No   varchar2
--   p_target_business_group_id     No   varchar2
--   p_search_by_cd1                No   varchar2
--   p_search_value1                No   varchar2
--   p_search_by_cd2                No   varchar2
--   p_search_value2                No   varchar2
--   p_search_by_cd3                No   varchar2
--   p_search_value3                No   varchar2
--   p_prefix_suffix_cd             No   varchar2
--   p_information13                No   varchar2
--   p_information14                No   varchar2
--   p_information15                No   varchar2
--   p_information16                No   varchar2
--   p_information17                No   varchar2
--   p_information18                No   varchar2
--   p_information19                No   varchar2
--   p_information20                No   varchar2
--   p_information21                No   varchar2
--   p_information22                No   varchar2
--   p_information23                No   varchar2
--   p_information24                No   varchar2
--   p_information25                No   varchar2
--   p_information26                No   varchar2
--   p_information27                No   varchar2
--   p_information28                No   varchar2
--   p_information29                No   varchar2
--   p_information30                No   varchar2
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_copy_entity_txn_id           Yes  number    PK of record
--   p_cet_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_PLAN_DESIGN_TXN
(
   p_validate                       in number     default 0 -- false
  ,p_copy_entity_txn_id             out nocopy number
  ,p_transaction_category_id        in  number    default null
  ,p_txn_category_attribute_id      in  number    default null
  ,p_context_business_group_id      in  number    default null
  ,p_datetrack_mode                 in  varchar2    default null
  ,p_proc_typ_cd                    in  varchar2  default null
  ,p_action_date                    in  date      default null
  ,p_src_effective_date             in  date      default null
  ,p_number_of_copies               in  number    default null
  ,p_process_name                   in  varchar2  default null
  ,p_replacement_type_cd            in  varchar2  default null
  ,p_sfl_step_name                  in  varchar2    default null
  ,p_increment_by                   in  number    default null
  ,p_status                         in  varchar2  default null
  ,p_cet_object_version_number      out nocopy number
  ,p_effective_date                 in  date
  ,p_copy_entity_attrib_id          out nocopy number
  ,p_row_type_cd                    in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_prefix_suffix_text             in  varchar2  default null
  ,p_export_file_name               in  varchar2  default null
  ,p_target_typ_cd                  in  varchar2  default null
  ,p_reuse_object_flag              in  varchar2  default null
  ,p_target_business_group_id       in  varchar2  default null
  ,p_search_by_cd1                  in  varchar2  default null
  ,p_search_value1                  in  varchar2  default null
  ,p_search_by_cd2                  in  varchar2  default null
  ,p_search_value2                  in  varchar2  default null
  ,p_search_by_cd3                  in  varchar2  default null
  ,p_search_value3                  in  varchar2  default null
  ,p_prefix_suffix_cd               in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_cea_object_version_number      out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_PLAN_DESIGN_TXN >------------------------|
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
--   p_validate                     Yes  number  Commit or Rollback.
--   p_copy_entity_txn_id           Yes  number    PK of record
--   p_transaction_category_id      Yes  number
--   p_txn_category_attribute_id    Yes  number    Descriptive Flexfield
--   p_context_business_group_id    No   number
--   p_datetrack_mode               No   varchar2
--   p_proc_typ_cd                  Yes  varchar2
--   action_date                    in  date      default null
--   src_effective_date             in  date      default null
--   p_number_of_copies             No   number
--   p_process_name                 No   varchar2
--   p_replacement_type_cd          No   varchar2
--   p_sfl_step_name                No   varchar2
--   p_increment_by                 No   number
--   p_status                       No   varchar2
--   p_effective_date               Yes  date       Session Date.
--   p_copy_entity_attrib_id        Yes  number    PK of record
--   p_row_type_cd                  No   varchar2
--   p_information_category         No   varchar2
--   p_prefix_suffix_text           No   varchar2
--   p_export_file_name             No   varchar2
--   p_target_typ_cd                No   varchar2
--   p_reuse_object_flag            No   varchar2
--   p_target_business_group_id     No   varchar2
--   p_search_by_cd1                No   varchar2
--   p_search_value1                No   varchar2
--   p_search_by_cd2                No   varchar2
--   p_search_value2                No   varchar2
--   p_search_by_cd3                No   varchar2
--   p_search_value3                No   varchar2
--   p_prefix_suffix_cd             No   varchar2
--   p_information13                No   varchar2
--   p_information14                No   varchar2
--   p_information15                No   varchar2
--   p_information16                No   varchar2
--   p_information17                No   varchar2
--   p_information18                No   varchar2
--   p_information19                No   varchar2
--   p_information20                No   varchar2
--   p_information21                No   varchar2
--   p_information22                No   varchar2
--   p_information23                No   varchar2
--   p_information24                No   varchar2
--   p_information25                No   varchar2
--   p_information26                No   varchar2
--   p_information27                No   varchar2
--   p_information28                No   varchar2
--   p_information29                No   varchar2
--   p_information30                No   varchar2
--
-- Post Success:
--
--   Name                           Type     Description
--   p_cet_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_PLAN_DESIGN_TXN
  (
   p_validate                       in number    default 0 -- false
  ,p_copy_entity_txn_id             in  number
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_txn_category_attribute_id      in  number    default hr_api.g_number
  ,p_context_business_group_id      in  number    default hr_api.g_number
  ,p_datetrack_mode                 in  varchar2    default hr_api.g_varchar2
  ,p_proc_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_action_date                    in  date      default hr_api.g_date
  ,p_src_effective_date             in  date      default hr_api.g_date
  ,p_number_of_copies               in  number    default hr_api.g_number
  ,p_process_name                   in  varchar2  default hr_api.g_varchar2
  ,p_replacement_type_cd            in  varchar2  default hr_api.g_varchar2
  ,p_sfl_step_name                  in  varchar2    default hr_api.g_varchar2
  ,p_increment_by                   in  number    default hr_api.g_number
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_cet_object_version_number      in out nocopy number
  ,p_effective_date                 in  date
  ,p_copy_entity_attrib_id          in  number
  ,p_row_type_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_information_category           in  varchar2  default hr_api.g_varchar2
  ,p_prefix_suffix_text             in  varchar2  default hr_api.g_varchar2
  ,p_export_file_name               in  varchar2  default hr_api.g_varchar2
  ,p_target_typ_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_reuse_object_flag              in  varchar2  default hr_api.g_varchar2
  ,p_target_business_group_id       in  varchar2  default hr_api.g_varchar2
  ,p_search_by_cd1                  in  varchar2  default hr_api.g_varchar2
  ,p_search_value1                  in  varchar2  default hr_api.g_varchar2
  ,p_search_by_cd2                  in  varchar2  default hr_api.g_varchar2
  ,p_search_value2                  in  varchar2  default hr_api.g_varchar2
  ,p_search_by_cd3                  in  varchar2  default hr_api.g_varchar2
  ,p_search_value3                  in  varchar2  default hr_api.g_varchar2
  ,p_prefix_suffix_cd               in  varchar2  default hr_api.g_varchar2
  ,p_information13                  in  varchar2  default hr_api.g_varchar2
  ,p_information14                  in  varchar2  default hr_api.g_varchar2
  ,p_information15                  in  varchar2  default hr_api.g_varchar2
  ,p_information16                  in  varchar2  default hr_api.g_varchar2
  ,p_information17                  in  varchar2  default hr_api.g_varchar2
  ,p_information18                  in  varchar2  default hr_api.g_varchar2
  ,p_information19                  in  varchar2  default hr_api.g_varchar2
  ,p_information20                  in  varchar2  default hr_api.g_varchar2
  ,p_information21                  in  varchar2  default hr_api.g_varchar2
  ,p_information22                  in  varchar2  default hr_api.g_varchar2
  ,p_information23                  in  varchar2  default hr_api.g_varchar2
  ,p_information24                  in  varchar2  default hr_api.g_varchar2
  ,p_information25                  in  varchar2  default hr_api.g_varchar2
  ,p_information26                  in  varchar2  default hr_api.g_varchar2
  ,p_information27                  in  varchar2  default hr_api.g_varchar2
  ,p_information28                  in  varchar2  default hr_api.g_varchar2
  ,p_information29                  in  varchar2  default hr_api.g_varchar2
  ,p_information30                  in  varchar2  default hr_api.g_varchar2
  ,p_upd_record_type                in  varchar2  default null
  ,p_cea_object_version_number      in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PLAN_DESIGN_TXN >------------------------|
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
--   p_validate                     Yes  number  Commit or Rollback.
--   p_copy_entity_txn_id           Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_cet_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_PLAN_DESIGN_TXN
  (
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_txn_id             in  number
  ,p_cet_object_version_number          in  number
  ,p_effective_date            in date
  ,p_retain_log   in varchar2 default 'N'                    -- Bug No 4281567
  );
--
procedure create_plan_design_result
  (
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_result_id          out nocopy number
  ,p_copy_entity_txn_id             in  number
  ,p_pl_id                          in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in date
  ,p_no_dup_rslt                    in varchar2   default null
  ) ;
--
procedure update_plan_design_result
  (
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_result_id          in number
  ,p_copy_entity_txn_id             in number
  ,p_business_group_id              in number    default hr_api.g_number
  ,p_number_of_copies               in  number   default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_information1                   in varchar2  default hr_api.g_varchar2
  ,p_information8                   in varchar2  default hr_api.g_varchar2
  ,p_information175                 in varchar2  default hr_api.g_varchar2
  ,p_information176                 in varchar2  default hr_api.g_varchar2
  ,p_information177                 in varchar2  default hr_api.g_varchar2
  ,p_information178                 in varchar2  default hr_api.g_varchar2
  ,p_information179                 in varchar2  default hr_api.g_varchar2
  ,p_information180                 in varchar2  default hr_api.g_varchar2
  ,p_called_from                    in varchar2  default hr_api.g_varchar2
  ,p_mirror_entity_result_id        in number    default hr_api.g_number
  ) ;
--
procedure delete_plan_design_result
  (
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_txn_id             in  number
  ,p_effective_date                 in date
  );
--
procedure update_mapping_target_data(
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_txn_id             in number
  ,p_table_route_id                 in number
  ,p_source_id1                      in number
  ,p_target_value1                   in varchar2
  ,p_target_id1                      in number
  ,p_source_id2                      in number
  ,p_target_value2                   in varchar2
  ,p_target_id2                      in number
  ,p_business_group_id              in number        default hr_api.g_number
  ,p_effective_date                 in date          default null
);
--
procedure auto_mapping(
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_txn_id             in number
  ,p_table_route_id                 in number
  ,p_table_route_id2                 in number
  ,p_legislation_code               in varchar2
  ,p_target_business_group_id       in number       default hr_api.g_number
  ,p_effective_date                 in date          default null
  ,p_effective_date_to_copy         in date          default null
) ;
  --

function get_mapping_info(
  p_mapping_info varchar2,
  p_table_route_id number,
  p_entity_txn_id number) return varchar2 ;
--
procedure get_user_business_group_ids(
  p_user_id number,
  p_business_group_ids out nocopy varchar2
) ;
--

procedure submit_copy_request(
  p_validate                 in  number     default 0 -- false
 ,p_copy_entity_txn_id       in  number
 ,p_request_id               out nocopy number
);
--

procedure update_hgrid_child_selection(
   p_copy_entity_result_id    in number
  ,p_mirror_entity_result_id  in number
  ,p_copy_entity_txn_id       in number
  ,p_number_of_copies         in number
  ,p_table_route_id           in number
);
--
procedure get_required_mapping_completed(
   p_copy_entity_txn_id in number
  ,p_required_mapping out nocopy varchar2
);
--
procedure get_mapping_column_name(
   p_table_route_id in number
  ,p_mapping_colum_name1 out nocopy varchar2
  ,p_mapping_colum_name2 out nocopy varchar2
  ,p_copy_entity_txn_id in number
);
--
procedure update_download_status(
   errbuf                     out nocopy varchar2
  ,retcode                    out nocopy number
  ,p_request_id                in number
  ,p_copy_entity_txn_id        in number
);
--
function get_log_display(
  p_copy_entity_txn_id         in number
 ,p_status                     in varchar2
 ,p_target_typ_cd              in varchar2) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |------------------------< write_txn_table_route >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--  This procedure is used for writing the table_rout_id column for a process
--  since Plan Design wizard does not write the table_route_id but the submit
-- process uses it. The procedure runs as a autonomous transaction so that we do not
-- do the same processing again.

procedure write_txn_table_route(p_copy_entity_txn_id in number);

--  submit process wrapper for Plan Design Wizard

procedure pdw_submit_copy_request(
  p_validate                 in  number     default 0 -- false
 ,p_copy_entity_txn_id       in  number
 ,p_request_id               out nocopy number
);

-- create_plan_design_result overloaded for Plan Design Wizard
-- This has been overloaded to alllow copying Plans to staging area
-- without setting information8 to PLNIP

procedure create_plan_design_result
  (
   p_validate                       in number        default 0 -- false
  ,p_copy_entity_result_id          out nocopy number
  ,p_copy_entity_txn_id             in  number
  ,p_pl_id                          in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in date
  ,p_no_dup_rslt                    in varchar2   default null
  ,p_plan_in_program                in varchar2
  ) ;
--
-- Bug 4278495
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_log >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_log
 ( p_copy_entity_txn_id       in  number
 ) ;
--
--
--
-- Bug 4281567
-- ----------------------------------------------------------------------------
-- |------------------< purge_plan_design_process >--------------------|
-- ----------------------------------------------------------------------------
--
procedure purge_plan_design_process(
  errbuf                           out nocopy varchar2                   --needed by concurrent manager.
 ,retcode                          out nocopy number                     --needed by concurrent manager.
 ,p_process_id                 in  number default null
 ,p_validate                      in varchar2
 ,p_effective_date           in varchar2
 ,p_status                         in  varchar2  default null
 ,p_transaction_short_name  in  varchar2
 ,p_retain_log                       in varchar2
 ,p_business_group_id          in     number
);
--
--
end BEN_PLAN_DESIGN_TXNS_api;

 

/
