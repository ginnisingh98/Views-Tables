--------------------------------------------------------
--  DDL for Package HR_SALARY_BASIS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SALARY_BASIS_SWI" AUTHID CURRENT_USER As
/* $Header: hrppbswi.pkh 115.1 2002/12/31 01:56:26 ndorai noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_salary_basis >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_salary_basis_api.create_salary_basis
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
PROCEDURE create_salary_basis
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number
  ,p_input_value_id               in     number
  ,p_rate_id                      in     number    default null
  ,p_name                         in     varchar2
  ,p_pay_basis                    in     varchar2
  ,p_rate_basis                   in     varchar2
  ,p_pay_annualization_factor     in     number    default null
  ,p_grade_annualization_factor   in     number    default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_last_update_date             in     date      default null
  ,p_last_updated_by              in     number    default null
  ,p_last_update_login            in     number    default null
  ,p_created_by                   in     number    default null
  ,p_creation_date                in     date      default null
  ,p_information_category         in     varchar2  default null
  ,p_information1                 in     varchar2  default null
  ,p_information2                 in     varchar2  default null
  ,p_information3                 in     varchar2  default null
  ,p_information4                 in     varchar2  default null
  ,p_information5                 in     varchar2  default null
  ,p_information6                 in     varchar2  default null
  ,p_information7                 in     varchar2  default null
  ,p_information8                 in     varchar2  default null
  ,p_information9                 in     varchar2  default null
  ,p_information10                in     varchar2  default null
  ,p_information11                in     varchar2  default null
  ,p_information12                in     varchar2  default null
  ,p_information13                in     varchar2  default null
  ,p_information14                in     varchar2  default null
  ,p_information15                in     varchar2  default null
  ,p_information16                in     varchar2  default null
  ,p_information17                in     varchar2  default null
  ,p_information18                in     varchar2  default null
  ,p_information19                in     varchar2  default null
  ,p_information20                in     varchar2  default null
  ,p_pay_basis_id                    out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_salary_basis >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_salary_basis_api.delete_salary_basis
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
PROCEDURE delete_salary_basis
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pay_basis_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_salary_basis >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_salary_basis_api.update_salary_basis
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
PROCEDURE update_salary_basis
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pay_basis_id                 in     number
  ,p_input_value_id               in     number    default hr_api.g_number
  ,p_rate_id                      in     number    default hr_api.g_number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_pay_basis                    in     varchar2  default hr_api.g_varchar2
  ,p_rate_basis                   in     varchar2  default hr_api.g_varchar2
  ,p_pay_annualization_factor     in     number    default hr_api.g_number
  ,p_grade_annualization_factor   in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_last_update_date             in     date      default hr_api.g_date
  ,p_last_updated_by              in     number    default hr_api.g_number
  ,p_last_update_login            in     number    default hr_api.g_number
  ,p_created_by                   in     number    default hr_api.g_number
  ,p_creation_date                in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end hr_salary_basis_swi;

 

/
