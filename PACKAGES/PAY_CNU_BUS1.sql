--------------------------------------------------------
--  DDL for Package PAY_CNU_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CNU_BUS1" AUTHID CURRENT_USER as
/* $Header: pycnurhi.pkh 120.0 2005/05/29 04:05:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< is_numeric >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function validates that the caharacter passed to it is a numeric
--   ie 0 to 9.
--
-- Prerequisites:
--
-- In Parameter:
--   p_one_char
--
-- Post Success:
--   Processing continues. The function retruns 0.
--
-- Post Failure:
--   Processing continues. The function returns 1.
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function is_numeric (p_one_char in VARCHAR2) RETURN varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_element_name >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the element_name is not null.
--
-- Prerequisites:
--
-- In Parameter:
--   p_element_name
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--   Only needs to be called from insert validate.
--
-- Access Status:
--   Internal Development Use Only. Insert Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_element_name (
   p_element_name     in pay_fr_contribution_usages.element_name%TYPE
 );
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_contribution_usage_type >----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the contribution_usage_type
--   An error is raised if the contribution_usage_type is not validated by the call
--   to hr_api.not_exists_in_hrstand_lookups
--
-- Prerequisites:
--
-- In Parameter:
--   p_effective_date - date at which the lookups must exist
--   p_contribution_usage_type - the lookup code that must exist
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--   Only needs to be called from insert validate.
--
-- Access Status:
--   Internal Development Use Only. Insert Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_contribution_usage_type (
   p_effective_date                 in date
  ,p_contribution_usage_type        in pay_fr_contribution_usages.contribution_usage_type%TYPE
 );
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_rate_type >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the rate_type
--   An error is raised if the rate_type is not validated by the call
--   to hr_api.not_exists_in_hrstand_lookups
--
-- Prerequisites:
--
-- In Parameter:
--   p_effective_date - date at which the lookups must exist
--   p_rate_type - the lookup code that must exist
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--   Only needs to be called from insert validate.
--
-- Access Status:
--   Internal Development Use Only. Insert Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_rate_type (
   p_effective_date    in date
  ,p_rate_type         in pay_fr_contribution_usages.rate_type%TYPE
 );
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_process_type >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the process_type
--   An error is raised if the process type is not validated by the call
--   to hr_api.not_exists_in_hrstand_lookups
--
-- Prerequisites:
--
-- In Parameter:
--   p_effective_date - date at which the lookups must exist
--   p_process_type - the lookup code that must exist
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--   Only needs to be called from insert validate.
--
-- Access Status:
--   Internal Development Use Only. Insert Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_process_type (
   p_effective_date      in date
  ,p_process_type        in pay_fr_contribution_usages.process_type%TYPE
 );
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_lu_group_code >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the group code
--   An error is raised if the group code is not validated by the call
--   to hr_api.not_exists_in_hrstand_lookups
--
-- Prerequisites:
--
-- In Parameter:
--   p_effective_date - date at which the lookups must exist
--   p_group_code - the lookup code that must exist
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--   Only needs to be called from insert validate.
--
-- Access Status:
--   Internal Development Use Only. Insert Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_lu_group_code (
   p_effective_date    in date
  ,p_group_code        in pay_fr_contribution_usages.group_code%TYPE
 );
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_business_group_id >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks that the GB is in a French Legislation, if the
--   BG is not null.
--
-- Prerequisites:
--
-- In Parameter:
--   p_business_group_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only. Insert Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_business_group_id (
   p_business_group_id     in pay_fr_contribution_usages.business_group_id%TYPE
 );
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_rate_category_type >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks that the rate type and the rate category are consistent.
--
-- Prerequisites:
--
-- In Parameter:
--   p_rate_type
--   p_rate_category
--
-- Post Success:
--   processing continues.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only. Insert Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_rate_category_type (
   p_rate_category     in pay_fr_contribution_usages.rate_category%TYPE
  ,p_rate_type         in pay_fr_contribution_usages.rate_type%TYPE
 );
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_validate_code >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks that a contribution code and a code type are consistent.
--
-- Prerequisites:
--   The type has already been vaidated.
--
-- In Parameter:
--   p_code (either a retro or a normal code)
--   p_contribution_type (eg ARRCO, AGIRC..)
--   p_rate_category     ('S', 'D'...)
-- Post Success:
--   Processing Continues
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_validate_code (
   p_code              in pay_fr_contribution_usages.contribution_code%TYPE
  ,p_contribution_type in pay_fr_contribution_usages.contribution_type%TYPE
  ,p_rate_category     in pay_fr_contribution_usages.rate_category%TYPE
 );
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_contribution_type >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates tha the contribution_type is correct
--
-- Prerequisites:
--
-- In Parameter:
--   p_contribution_type
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only. Insert test only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_contribution_type (
   p_contribution_type in pay_fr_contribution_usages.contribution_type%TYPE
 );
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_contribution_codes >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks that a contribution code(either retro or normal)
--   conforms to the layout of the code type in p_contribution_type.
--
-- Prerequisites:
--
-- In Parameter:
--   p_contribution_usage_id
--   p_object_version_number
--   p_contribution_type in
--   p_contribution_code in
--   p_retro_contribution_code
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--   This procedure calls chk_validate_code to validate the codes (retro
--   or normal).
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_contribution_codes (
  p_contribution_usage_id   in pay_fr_contribution_usages.contribution_usage_id%TYPE
 ,p_object_version_number   in pay_fr_contribution_usages.object_version_number%TYPE
 ,p_contribution_type in pay_fr_contribution_usages.contribution_type%TYPE
 ,p_contribution_code in pay_fr_contribution_usages.contribution_code%TYPE
 ,p_retro_contribution_code in pay_fr_contribution_usages.retro_contribution_code%TYPE
 ,p_rate_category           in pay_fr_contribution_usages.rate_category%TYPE
 );
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_group_code >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the group code
--   There can only be one group_code for a combination of element_name, process_type
--   contribution_usage_type for :
--     if p_business_group_id  is null, where bg is null
--     if p_business_group_id  is not null, where bg = this bg, or bg is null
--
-- Prerequisites:
--
-- In Parameter:
--  p_group_code
--  p_process_type
--  p_element_name
--  p_contribution_usage_type
--  p_business_group_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only. Insert test only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_group_code (
  p_group_code              in pay_fr_contribution_usages.group_code%TYPE
 ,p_process_type            in pay_fr_contribution_usages.process_type%TYPE
 ,p_element_name            in pay_fr_contribution_usages.element_name%TYPE
 ,p_contribution_usage_type in pay_fr_contribution_usages.contribution_usage_type%TYPE
 ,p_business_group_id       in pay_fr_contribution_usages.business_group_id%TYPE
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_dates >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- There cannot be a duplicate of date_from, date_to, group_code, process_type
-- element_name, contribution_usage_type :
--  if p_business_group_id is null, where BG is null
--  if BG is not null, where BG = P_BG, and where BG is null
-- covering any period in the date_from -> date_to date range.
-- If p_date_to is null, use eot.
--
-- This can be called from insert (where ID and OVN are null)
-- or
-- from update, as date_to may have changed.
-- Only test if new insert, or date_to is changing.
--
-- Prerequisites:
--
-- In Parameter:
--  p_contribution_usage_id
--  p_object_version_number
--  p_date_from
--  p_date_to
--  p_group_code
--  p_process_type
--  p_element_name
--  p_contribution_usage_type
--  p_business_group_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_dates (
  p_contribution_usage_id   in pay_fr_contribution_usages.contribution_usage_id%TYPE
 ,p_object_version_number   in pay_fr_contribution_usages.object_version_number%TYPE
 ,p_date_from               in pay_fr_contribution_usages.date_from%TYPE
 ,p_date_to                 in pay_fr_contribution_usages.date_to%TYPE
 ,p_group_code              in pay_fr_contribution_usages.group_code%TYPE
 ,p_process_type            in pay_fr_contribution_usages.process_type%TYPE
 ,p_element_name            in pay_fr_contribution_usages.element_name%TYPE
 ,p_contribution_usage_type in pay_fr_contribution_usages.contribution_usage_type%TYPE
 ,p_business_group_id       in pay_fr_contribution_usages.business_group_id%TYPE
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< LOAD_ROW >-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called by the loader
--   It first tries to update the row, and if no data is found it tries to
--   insert the row.
--   If necessary the insert operation will adjust another row's end
--   date (for the same primary key) to put the existing row's date_to
--   to be the date before the new date_from.
--   This cannot call the row handlers, as they operate on the surrogate key
--   (ie contribution_usage_id)
--   and loaders operate on the primary key. This assumes the data was extracted from
--   a database, where the validation was performed.
--
-- Prerequisites:
--
-- In Parameter:
--  p_date_from
--  p_date_to
--  p_group_code
--  p_process_type
--  p_element_name
--  p_contribution_usage_type
--  p_rate_type
--  p_rate_category
--  p_contribution_code
--  p_contribution_type
--  p_retro_contribution_code
--
-- Post Success:
--   The row is udtated, or inserted.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--   Only to be used by the loader.
--
-- Access Status:
--   Only to be used by the loader.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure load_row (
  p_date_from               in varchar2
 ,p_date_to                 in varchar2
 ,p_group_code              in pay_fr_contribution_usages.group_code%TYPE
 ,p_process_type            in pay_fr_contribution_usages.process_type%TYPE
 ,p_element_name            in pay_fr_contribution_usages.element_name%TYPE
 ,p_contribution_usage_type in pay_fr_contribution_usages.contribution_usage_type%TYPE
 ,p_rate_type               in pay_fr_contribution_usages.rate_type%TYPE
 ,p_rate_category           in pay_fr_contribution_usages.rate_category%TYPE
 ,p_contribution_code       in pay_fr_contribution_usages.contribution_code%TYPE
 ,p_contribution_type       in pay_fr_contribution_usages.contribution_type%TYPE
 ,p_retro_contribution_code in pay_fr_contribution_usages.retro_contribution_code%TYPE
 ,p_code_rate_id            in pay_fr_contribution_usages.code_Rate_id%TYPE
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_code_rate_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- There cannot be more than 1 CODE_RATE_ID for a given contribution code /
-- rate type / business group combination
--
-- Rate_categories of 'W' and 'T' must not have code_rate_IDs.
--
-- code_rate_Ids must not be specified for Business_group rows, and must not
-- be specified for business_group rows.
--
-- Business group rows must have code_Rate_ids <=50 and >=30.
-- Non-Business group rows must have code_Rate_ids >= 0 and <30.
--
-- This can be called from insert only
--
-- Prerequisites:
--
-- In Parameter:
--  p_contribution_code
--  p_object_version_number
--  p_rate_type
--  p_rate_category
--  p_business_group_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An Error is raised and processing stops.
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_code_rate_id (
  p_code_rate_id            in out nocopy pay_fr_contribution_usages.code_rate_id%TYPE
 ,p_contribution_code       in pay_fr_contribution_usages.contribution_code%TYPE
 ,p_business_group_id       in pay_fr_contribution_usages.business_group_id%TYPE
 ,p_rate_type               in pay_fr_contribution_usages.rate_type%TYPE
 ,p_rate_category           in pay_fr_contribution_usages.rate_category%TYPE
 );
end pay_cnu_bus1;

 

/
