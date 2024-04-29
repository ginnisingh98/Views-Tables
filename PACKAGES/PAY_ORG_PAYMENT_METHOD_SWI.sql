--------------------------------------------------------
--  DDL for Package PAY_ORG_PAYMENT_METHOD_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ORG_PAYMENT_METHOD_SWI" AUTHID CURRENT_USER As
/* $Header: pyopmswi.pkh 115.0 2003/09/26 08:28 sdhole noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_org_payment_method >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_org_payment_method_api.create_org_payment_method
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
PROCEDURE create_org_payment_method
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_language_code                in     varchar2  default null
  ,p_business_group_id            in     number
  ,p_org_payment_method_name      in     varchar2
  ,p_payment_type_id              in     number
  ,p_currency_code                in     varchar2  default null
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
  ,p_pmeth_information1           in     varchar2  default null
  ,p_pmeth_information2           in     varchar2  default null
  ,p_pmeth_information3           in     varchar2  default null
  ,p_pmeth_information4           in     varchar2  default null
  ,p_pmeth_information5           in     varchar2  default null
  ,p_pmeth_information6           in     varchar2  default null
  ,p_pmeth_information7           in     varchar2  default null
  ,p_pmeth_information8           in     varchar2  default null
  ,p_pmeth_information9           in     varchar2  default null
  ,p_pmeth_information10          in     varchar2  default null
  ,p_pmeth_information11          in     varchar2  default null
  ,p_pmeth_information12          in     varchar2  default null
  ,p_pmeth_information13          in     varchar2  default null
  ,p_pmeth_information14          in     varchar2  default null
  ,p_pmeth_information15          in     varchar2  default null
  ,p_pmeth_information16          in     varchar2  default null
  ,p_pmeth_information17          in     varchar2  default null
  ,p_pmeth_information18          in     varchar2  default null
  ,p_pmeth_information19          in     varchar2  default null
  ,p_pmeth_information20          in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_segment1                     in     varchar2  default null
  ,p_segment2                     in     varchar2  default null
  ,p_segment3                     in     varchar2  default null
  ,p_segment4                     in     varchar2  default null
  ,p_segment5                     in     varchar2  default null
  ,p_segment6                     in     varchar2  default null
  ,p_segment7                     in     varchar2  default null
  ,p_segment8                     in     varchar2  default null
  ,p_segment9                     in     varchar2  default null
  ,p_segment10                    in     varchar2  default null
  ,p_segment11                    in     varchar2  default null
  ,p_segment12                    in     varchar2  default null
  ,p_segment13                    in     varchar2  default null
  ,p_segment14                    in     varchar2  default null
  ,p_segment15                    in     varchar2  default null
  ,p_segment16                    in     varchar2  default null
  ,p_segment17                    in     varchar2  default null
  ,p_segment18                    in     varchar2  default null
  ,p_segment19                    in     varchar2  default null
  ,p_segment20                    in     varchar2  default null
  ,p_segment21                    in     varchar2  default null
  ,p_segment22                    in     varchar2  default null
  ,p_segment23                    in     varchar2  default null
  ,p_segment24                    in     varchar2  default null
  ,p_segment25                    in     varchar2  default null
  ,p_segment26                    in     varchar2  default null
  ,p_segment27                    in     varchar2  default null
  ,p_segment28                    in     varchar2  default null
  ,p_segment29                    in     varchar2  default null
  ,p_segment30                    in     varchar2  default null
  ,p_concat_segments              in     varchar2  default null
  ,p_gl_segment1                  in     varchar2  default null
  ,p_gl_segment2                  in     varchar2  default null
  ,p_gl_segment3                  in     varchar2  default null
  ,p_gl_segment4                  in     varchar2  default null
  ,p_gl_segment5                  in     varchar2  default null
  ,p_gl_segment6                  in     varchar2  default null
  ,p_gl_segment7                  in     varchar2  default null
  ,p_gl_segment8                  in     varchar2  default null
  ,p_gl_segment9                  in     varchar2  default null
  ,p_gl_segment10                 in     varchar2  default null
  ,p_gl_segment11                 in     varchar2  default null
  ,p_gl_segment12                 in     varchar2  default null
  ,p_gl_segment13                 in     varchar2  default null
  ,p_gl_segment14                 in     varchar2  default null
  ,p_gl_segment15                 in     varchar2  default null
  ,p_gl_segment16                 in     varchar2  default null
  ,p_gl_segment17                 in     varchar2  default null
  ,p_gl_segment18                 in     varchar2  default null
  ,p_gl_segment19                 in     varchar2  default null
  ,p_gl_segment20                 in     varchar2  default null
  ,p_gl_segment21                 in     varchar2  default null
  ,p_gl_segment22                 in     varchar2  default null
  ,p_gl_segment23                 in     varchar2  default null
  ,p_gl_segment24                 in     varchar2  default null
  ,p_gl_segment25                 in     varchar2  default null
  ,p_gl_segment26                 in     varchar2  default null
  ,p_gl_segment27                 in     varchar2  default null
  ,p_gl_segment28                 in     varchar2  default null
  ,p_gl_segment29                 in     varchar2  default null
  ,p_gl_segment30                 in     varchar2  default null
  ,p_gl_concat_segments           in     varchar2  default null
  ,p_sets_of_book_id              in     number    default null
  ,p_third_party_payment          in     varchar2  default null
  ,p_org_payment_method_id        in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_object_version_number           out nocopy number
  ,p_asset_code_combination_id       out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_external_account_id             out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_org_payment_method >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_org_payment_method_api.delete_org_payment_method
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
PROCEDURE delete_org_payment_method
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_delete_mode        in     varchar2
  ,p_org_payment_method_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_org_payment_method >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_org_payment_method_api.update_org_payment_method
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
PROCEDURE update_org_payment_method
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_org_payment_method_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_org_payment_method_name      in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
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
  ,p_pmeth_information1           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information2           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information3           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information4           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information5           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information6           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information7           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information8           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information9           in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information10          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information11          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information12          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information13          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information14          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information15          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information16          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information17          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information18          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information19          in     varchar2  default hr_api.g_varchar2
  ,p_pmeth_information20          in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_segment1                     in     varchar2  default hr_api.g_varchar2
  ,p_segment2                     in     varchar2  default hr_api.g_varchar2
  ,p_segment3                     in     varchar2  default hr_api.g_varchar2
  ,p_segment4                     in     varchar2  default hr_api.g_varchar2
  ,p_segment5                     in     varchar2  default hr_api.g_varchar2
  ,p_segment6                     in     varchar2  default hr_api.g_varchar2
  ,p_segment7                     in     varchar2  default hr_api.g_varchar2
  ,p_segment8                     in     varchar2  default hr_api.g_varchar2
  ,p_segment9                     in     varchar2  default hr_api.g_varchar2
  ,p_segment10                    in     varchar2  default hr_api.g_varchar2
  ,p_segment11                    in     varchar2  default hr_api.g_varchar2
  ,p_segment12                    in     varchar2  default hr_api.g_varchar2
  ,p_segment13                    in     varchar2  default hr_api.g_varchar2
  ,p_segment14                    in     varchar2  default hr_api.g_varchar2
  ,p_segment15                    in     varchar2  default hr_api.g_varchar2
  ,p_segment16                    in     varchar2  default hr_api.g_varchar2
  ,p_segment17                    in     varchar2  default hr_api.g_varchar2
  ,p_segment18                    in     varchar2  default hr_api.g_varchar2
  ,p_segment19                    in     varchar2  default hr_api.g_varchar2
  ,p_segment20                    in     varchar2  default hr_api.g_varchar2
  ,p_segment21                    in     varchar2  default hr_api.g_varchar2
  ,p_segment22                    in     varchar2  default hr_api.g_varchar2
  ,p_segment23                    in     varchar2  default hr_api.g_varchar2
  ,p_segment24                    in     varchar2  default hr_api.g_varchar2
  ,p_segment25                    in     varchar2  default hr_api.g_varchar2
  ,p_segment26                    in     varchar2  default hr_api.g_varchar2
  ,p_segment27                    in     varchar2  default hr_api.g_varchar2
  ,p_segment28                    in     varchar2  default hr_api.g_varchar2
  ,p_segment29                    in     varchar2  default hr_api.g_varchar2
  ,p_segment30                    in     varchar2  default hr_api.g_varchar2
  ,p_concat_segments              in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment1                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment2                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment3                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment4                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment5                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment6                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment7                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment8                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment9                  in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment10                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment11                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment12                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment13                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment14                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment15                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment16                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment17                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment18                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment19                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment20                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment21                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment22                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment23                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment24                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment25                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment26                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment27                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment28                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment29                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_segment30                 in     varchar2  default hr_api.g_varchar2
  ,p_gl_concat_segments           in     varchar2  default hr_api.g_varchar2
  ,p_sets_of_book_id              in     number    default hr_api.g_number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_asset_code_combination_id       out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_external_account_id             out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end pay_org_payment_method_swi;

 

/
