--------------------------------------------------------
--  DDL for Package PAY_PAYROLL_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYROLL_SWI" AUTHID CURRENT_USER As
/* $Header: pyprlswi.pkh 115.1 2003/12/24 06:19 sdhole noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_payroll >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_payroll_api.create_payroll
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
PROCEDURE create_payroll
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_payroll_name                 in     varchar2
  ,p_payroll_type                 in     varchar2  default null
  ,p_period_type                  in     varchar2
  ,p_first_period_end_date        in     date
  ,p_number_of_years              in     number
  ,p_pay_date_offset              in     number    default 0
  ,p_direct_deposit_date_offset   in     number    default 0
  ,p_pay_advice_date_offset       in     number    default 0
  ,p_cut_off_date_offset          in     number    default 0
  ,p_midpoint_offset              in     number    default null
  ,p_default_payment_method_id    in     number    default null
  ,p_consolidation_set_id         in     number
  ,p_cost_allocation_keyflex_id   in     number    default null
  ,p_suspense_account_keyflex_id  in     number    default null
  ,p_negative_pay_allowed_flag    in     varchar2  default 'N'
  ,p_gl_set_of_books_id           in     number    default null
  ,p_soft_coding_keyflex_id       in     number    default null
  ,p_comments                     in     varchar2  default null
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
  ,p_arrears_flag                 in     varchar2  default 'N'
  ,p_period_reset_years           in     number    default null
  ,p_multi_assignments_flag       in     varchar2  default null
  ,p_organization_id              in     number    default null
  ,p_prl_information_category     in     varchar2  default null
  ,p_prl_information1             in     varchar2  default null
  ,p_prl_information2             in     varchar2  default null
  ,p_prl_information3             in     varchar2  default null
  ,p_prl_information4             in     varchar2  default null
  ,p_prl_information5             in     varchar2  default null
  ,p_prl_information6             in     varchar2  default null
  ,p_prl_information7             in     varchar2  default null
  ,p_prl_information8             in     varchar2  default null
  ,p_prl_information9             in     varchar2  default null
  ,p_prl_information10            in     varchar2  default null
  ,p_prl_information11            in     varchar2  default null
  ,p_prl_information12            in     varchar2  default null
  ,p_prl_information13            in     varchar2  default null
  ,p_prl_information14            in     varchar2  default null
  ,p_prl_information15            in     varchar2  default null
  ,p_prl_information16            in     varchar2  default null
  ,p_prl_information17            in     varchar2  default null
  ,p_prl_information18            in     varchar2  default null
  ,p_prl_information19            in     varchar2  default null
  ,p_prl_information20            in     varchar2  default null
  ,p_prl_information21            in     varchar2  default null
  ,p_prl_information22            in     varchar2  default null
  ,p_prl_information23            in     varchar2  default null
  ,p_prl_information24            in     varchar2  default null
  ,p_prl_information25            in     varchar2  default null
  ,p_prl_information26            in     varchar2  default null
  ,p_prl_information27            in     varchar2  default null
  ,p_prl_information28            in     varchar2  default null
  ,p_prl_information29            in     varchar2  default null
  ,p_prl_information30            in     varchar2  default null
  ,p_payroll_id                   in     number -- made IN
  ,p_org_pay_method_usage_id         out nocopy number
  ,p_prl_object_version_number       out nocopy number
  ,p_opm_object_version_number       out nocopy number
  ,p_prl_effective_start_date        out nocopy date
  ,p_prl_effective_end_date          out nocopy date
  ,p_opm_effective_start_date        out nocopy date
  ,p_opm_effective_end_date          out nocopy date
  ,p_comment_id                      out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_payroll >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_payroll_api.delete_payroll
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
PROCEDURE delete_payroll
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_payroll_id                   in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_payroll >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_payroll_api.update_payroll
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
PROCEDURE update_payroll
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_payroll_id                   in out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_payroll_name                 in     varchar2  default hr_api.g_varchar2
  ,p_number_of_years              in     number    default hr_api.g_number
  ,p_default_payment_method_id    in     number    default hr_api.g_number
  ,p_consolidation_set_id         in     number    default hr_api.g_number
  ,p_cost_allocation_keyflex_id   in     number    default hr_api.g_number
  ,p_suspense_account_keyflex_id  in     number    default hr_api.g_number
  ,p_negative_pay_allowed_flag    in     varchar2  default hr_api.g_varchar2
  ,p_soft_coding_keyflex_id       in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
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
  ,p_arrears_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_multi_assignments_flag       in     varchar2  default hr_api.g_varchar2
  ,p_prl_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_prl_information1             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information2             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information3             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information4             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information5             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information6             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information7             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information8             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information9             in     varchar2  default hr_api.g_varchar2
  ,p_prl_information10            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information11            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information12            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information13            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information14            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information15            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information16            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information17            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information18            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information19            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information20            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information21            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information22            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information23            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information24            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information25            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information26            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information27            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information28            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information29            in     varchar2  default hr_api.g_varchar2
  ,p_prl_information30            in     varchar2  default hr_api.g_varchar2
  ,p_prl_effective_start_date        out nocopy date
  ,p_prl_effective_end_date          out nocopy date
  ,p_comment_id                      out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end pay_payroll_swi;

 

/
