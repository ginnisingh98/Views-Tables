--------------------------------------------------------
--  DDL for Package PAY_BALANCE_TYPES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_TYPES_BK2" AUTHID CURRENT_USER as
/* $Header: pybltapi.pkh 120.1 2005/10/02 02:46:06 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_BAL_TYPE_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_bal_type_b
  (p_effective_date                in     date
  ,p_language_code                 in     varchar2
  ,p_balance_type_id               in     number
  ,p_object_version_number         in     number
  ,p_balance_name                  in     varchar2
  ,p_balance_uom                   in     varchar2
  ,p_currency_code                 in     varchar2
  ,p_assignment_remuneration_flag  in     varchar2
  ,p_comments                      in     varchar2
  ,p_reporting_name                in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in	  varchar2
  ,p_attribute2                    in	  varchar2
  ,p_attribute3                    in	  varchar2
  ,p_attribute4                    in	  varchar2
  ,p_attribute5                    in	  varchar2
  ,p_attribute6                    in	  varchar2
  ,p_attribute7                    in	  varchar2
  ,p_attribute8                    in	  varchar2
  ,p_attribute9                    in	  varchar2
  ,p_attribute10                   in	  varchar2
  ,p_attribute11                   in	  varchar2
  ,p_attribute12                   in	  varchar2
  ,p_attribute13                   in	  varchar2
  ,p_attribute14                   in	  varchar2
  ,p_attribute15                   in	  varchar2
  ,p_attribute16                   in	  varchar2
  ,p_attribute17                   in	  varchar2
  ,p_attribute18                   in	  varchar2
  ,p_attribute19                   in	  varchar2
  ,p_attribute20                   in	  varchar2
  ,p_balance_category_id           in     number
  ,p_base_balance_type_id          in     number
  ,p_input_value_id                in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_BAL_TYPE_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_bal_type_a
  (p_effective_date                in     date
  ,p_language_code                 in     varchar2
  ,p_balance_type_id               in     number
  ,p_object_version_number         in     number
  ,p_balance_name                  in     varchar2
  ,p_balance_uom                   in     varchar2
  ,p_currency_code                 in     varchar2
  ,p_assignment_remuneration_flag  in     varchar2
  ,p_comments                      in     varchar2
  ,p_reporting_name                in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in	  varchar2
  ,p_attribute2                    in	  varchar2
  ,p_attribute3                    in	  varchar2
  ,p_attribute4                    in	  varchar2
  ,p_attribute5                    in	  varchar2
  ,p_attribute6                    in	  varchar2
  ,p_attribute7                    in	  varchar2
  ,p_attribute8                    in	  varchar2
  ,p_attribute9                    in	  varchar2
  ,p_attribute10                   in	  varchar2
  ,p_attribute11                   in	  varchar2
  ,p_attribute12                   in	  varchar2
  ,p_attribute13                   in	  varchar2
  ,p_attribute14                   in	  varchar2
  ,p_attribute15                   in	  varchar2
  ,p_attribute16                   in	  varchar2
  ,p_attribute17                   in	  varchar2
  ,p_attribute18                   in	  varchar2
  ,p_attribute19                   in	  varchar2
  ,p_attribute20                   in	  varchar2
  ,p_balance_category_id           in     number
  ,p_base_balance_type_id          in     number
  ,p_input_value_id                in     number
  ,p_balance_name_warning          in     number
  );
--
end PAY_BALANCE_TYPES_BK2;

 

/
