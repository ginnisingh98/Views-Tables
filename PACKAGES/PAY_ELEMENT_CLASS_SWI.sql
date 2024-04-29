--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_CLASS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_CLASS_SWI" AUTHID CURRENT_USER As
/* $Header: pypecswi.pkh 120.0 2006/01/25 16:09 ndorai noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_row >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_element_class_pkg.delete_row
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
PROCEDURE delete_row
  (x_classification_id            in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_row >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_element_class_pkg.insert_row
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
PROCEDURE insert_row
  (x_rowid                        in out nocopy varchar2
  ,x_classification_id            in     number
  ,x_business_group_id            in     number
  ,x_legislation_code             in     varchar2
  ,x_legislation_subgroup         in     varchar2
  ,x_costable_flag                in     varchar2
  ,x_default_high_priority        in     number
  ,x_default_low_priority         in     number
  ,x_default_priority             in     number
  ,x_distributable_over_flag      in     varchar2
  ,x_non_payments_flag            in     varchar2
  ,x_costing_debit_or_credit      in     varchar2
  ,x_parent_classification_id     in     number
  ,x_create_by_default_flag       in     varchar2
  ,x_balance_initialization_flag  in     varchar2
  ,x_object_version_number        in     number
  ,x_classification_name          in     varchar2
  ,x_description                  in     varchar2
  ,x_creation_date                in     date
  ,x_created_by                   in     number
  ,x_last_update_date             in     date
  ,x_last_updated_by              in     number
  ,x_last_update_login            in     number
  ,x_freq_rule_enabled            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------------< lock_row >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_element_class_pkg.lock_row
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
PROCEDURE lock_row
  (x_classification_id            in     number
  ,x_business_group_id            in     number
  ,x_legislation_code             in     varchar2
  ,x_legislation_subgroup         in     varchar2
  ,x_costable_flag                in     varchar2
  ,x_default_high_priority        in     number
  ,x_default_low_priority         in     number
  ,x_default_priority             in     number
  ,x_distributable_over_flag      in     varchar2
  ,x_non_payments_flag            in     varchar2
  ,x_costing_debit_or_credit      in     varchar2
  ,x_parent_classification_id     in     number
  ,x_create_by_default_flag       in     varchar2
  ,x_balance_initialization_flag  in     varchar2
  ,x_object_version_number        in     number
  ,x_classification_name          in     varchar2
  ,x_description                  in     varchar2
  ,x_freq_rule_enabled            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< set_translation_globals >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_element_class_pkg.set_translation_globals
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
PROCEDURE set_translation_globals
  (p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< translate_row >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_element_class_pkg.translate_row
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
PROCEDURE translate_row
  (x_e_classification_name        in     varchar2
  ,x_e_legislation_code           in     varchar2
  ,x_classification_name          in     varchar2
  ,x_description                  in     varchar2
  ,x_owner                        in     varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------------< update_row >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_element_class_pkg.update_row
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
PROCEDURE update_row
  (x_classification_id            in     number
  ,x_business_group_id            in     number
  ,x_legislation_code             in     varchar2
  ,x_legislation_subgroup         in     varchar2
  ,x_costable_flag                in     varchar2
  ,x_default_high_priority        in     number
  ,x_default_low_priority         in     number
  ,x_default_priority             in     number
  ,x_distributable_over_flag      in     varchar2
  ,x_non_payments_flag            in     varchar2
  ,x_costing_debit_or_credit      in     varchar2
  ,x_parent_classification_id     in     number
  ,x_create_by_default_flag       in     varchar2
  ,x_balance_initialization_flag  in     varchar2
  ,x_object_version_number        in     number
  ,x_classification_name          in     varchar2
  ,x_description                  in     varchar2
  ,x_last_update_date             in     date
  ,x_last_updated_by              in     number
  ,x_last_update_login            in     number
  ,x_mesg_flg                        out nocopy number
  ,x_freq_rule_enabled            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< validate_translation >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_element_class_pkg.validate_translation
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
PROCEDURE validate_translation
  (classification_id              in     number
  ,language                       in     varchar2
  ,classification_name            in     varchar2
  ,description                    in     varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
 end pay_element_class_swi;

 

/
