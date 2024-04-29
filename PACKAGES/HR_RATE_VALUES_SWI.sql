--------------------------------------------------------
--  DDL for Package HR_RATE_VALUES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATE_VALUES_SWI" AUTHID CURRENT_USER AS
/* $Header: hrpgrswi.pkh 115.3 2004/02/29 02:37:25 svittal noship $ */
g_asg_rate_table HR_ASG_RATE_TABLE;

g_update_only VARCHAR2(15) := 'UPDATE_ONLY';
g_update_delete VARCHAR2(15) := 'UPDATE_DELETE';
g_insert_only VARCHAR2(15) := 'INSERT_ONLY';
g_insert_delete VARCHAR2(15) := 'INSERT_DELETE';
g_delete_only VARCHAR2(15) := 'DELETE_ONLY';
g_no_change   VARCHAR2(15) := 'NO_CHANGE';


-- ----------------------------------------------------------------------------
-- |---------------------< create_assignment_rate_value >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_rate_values_api.create_assignment_rate_value
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_assignment_rate_value
  (p_validate                     in     boolean    default false
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_rate_id                      in     number
  ,p_assignment_id                in     number
  ,p_rate_type                    in     varchar2
  ,p_currency_code                in     varchar2
  ,p_value                        in     varchar2
  ,p_grade_rule_id                in out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< create_rate_value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_rate_values_api.create_rate_value
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_rate_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_rate_id                      in     number
  ,p_grade_or_spinal_point_id     in     number
  ,p_rate_type                    in     varchar2
  ,p_currency_code                in     varchar2  default null
  ,p_maximum                      in     varchar2  default null
  ,p_mid_value                    in     varchar2  default null
  ,p_minimum                      in     varchar2  default null
  ,p_sequence                     in     number    default null
  ,p_value                        in     varchar2  default null
  ,p_grade_rule_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_assignment_rate_value >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_rate_values_api.update_assignment_rate_value
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_assignment_rate_value
  (p_validate                     in     boolean    default false
  ,p_grade_rule_id                in     number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_value                        in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< update_rate_value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_rate_values_api.update_rate_value
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_rate_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_grade_rule_id                in     number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_maximum                      in     varchar2  default hr_api.g_varchar2
  ,p_mid_value                    in     varchar2  default hr_api.g_varchar2
  ,p_minimum                      in     varchar2  default hr_api.g_varchar2
  ,p_sequence                     in     number    default hr_api.g_number
  ,p_value                        in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_rate_value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_rate_values_api.delete_rate_value
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_rate_value
  (p_validate                     in     boolean    default false
  ,p_grade_rule_id                in     number
  ,p_datetrack_mode               in     varchar2
  ,p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_rate_value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_rate_values_api.delete_rate_value
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_rate_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_grade_rule_id                in     number
  ,p_datetrack_mode               in     varchar2
  ,p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_rate_values_api.lck
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_grade_rule_id                in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_validation_start_date           out nocopy date
  ,p_validation_end_date             out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ---------------------------------------------------------------------------
-- ---------------------------- < process_api > ------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure is used by the WF procedures to commit or validate
--          the transaction step with HRMS system
-- ---------------------------------------------------------------------------
PROCEDURE process_api
  (p_validate             in  boolean  default false
  ,p_transaction_step_id  in  number   default null
  ,p_effective_date       in  varchar2 default null
  );

PROCEDURE process_save
  (p_mode                  in     VARCHAR2 default '#'
  ,p_flow_mode             in     VARCHAR2 default NULL
  ,p_item_type             in     VARCHAR2 default hr_api.g_varchar2
  ,p_item_key              in     VARCHAR2 default hr_api.g_varchar2
  ,p_activity_id           in     VARCHAR2 default hr_api.g_varchar2
  ,p_effective_date_option in     VARCHAR2 default hr_api.g_varchar2
  ,p_asg_rate_tab          in     HR_ASG_RATE_TABLE
  ,p_return_status            out nocopy VARCHAR2
  ,p_transaction_step_id      out nocopy NUMBER
  );

PROCEDURE get_transaction_rownum
  (p_item_type      in     VARCHAR2
  ,p_item_key       in     VARCHAR2
  ,p_assignment_id  in     VARCHAR2
  ,p_business_gp_id in     VARCHAR2
  ,p_row_num           out nocopy VARCHAR2
  );

PROCEDURE get_transaction_details
  (p_asg_rate_table in out nocopy HR_ASG_RATE_TABLE
  );

PROCEDURE populate_transaction_details
  (p_item_type      in     VARCHAR2
  ,p_item_key       in     VARCHAR2
  ,p_assignment_id  in     VARCHAR2
  ,p_business_gp_id in     VARCHAR2
  );

PROCEDURE validate_record
  (p_validate       in     boolean Default true
  ,p_asg_rate_rec   in     HR_ASG_RATE_TYPE
  ,p_record_status  in     VARCHAR2
  ,p_effective_date in     date
  ,p_return_status     out nocopy VARCHAR2
  );

PROCEDURE delete_transaction_step
  (p_transaction_step_id in VARCHAR2
  );

FUNCTION is_date_change_required
  (p_new_date    in DATE
  ,p_old_date    in DATE
  ) return boolean;

PROCEDURE po_process_save
  (p_mode                  in     VARCHAR2 default '#'
  ,p_flow_mode             in     VARCHAR2 default NULL
  ,p_item_type             in     VARCHAR2 default hr_api.g_varchar2
  ,p_item_key              in     VARCHAR2 default hr_api.g_varchar2
  ,p_activity_id           in     VARCHAR2 default hr_api.g_varchar2
  ,p_effective_date_option in     VARCHAR2 default hr_api.g_varchar2
  ,p_po_line_id            in     NUMBER
  ,p_return_status            out nocopy VARCHAR2
  ,p_transaction_step_id      out nocopy NUMBER
);

end hr_rate_values_swi;

 

/
