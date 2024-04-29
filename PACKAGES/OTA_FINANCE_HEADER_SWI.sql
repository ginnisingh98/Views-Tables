--------------------------------------------------------
--  DDL for Package OTA_FINANCE_HEADER_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FINANCE_HEADER_SWI" AUTHID CURRENT_USER As
/* $Header: ottfhswi.pkh 120.0 2005/05/29 07:41 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_finance_header >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_finance_header_api.create_finance_header
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
PROCEDURE create_finance_header
  (p_finance_header_id             in  out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_superceding_header_id        in     number
  ,p_authorizer_person_id         in     number
  ,p_organization_id              in     number
  ,p_administrator                in     number
  ,p_cancelled_flag               in     varchar2
  ,p_currency_code                in     varchar2
  ,p_date_raised                  in     date
  ,p_payment_status_flag          in     varchar2
  ,p_transfer_status              in     varchar2
  ,p_type                         in     varchar2
  ,p_receivable_type              in     varchar2
  ,p_comments                     in     varchar2
  ,p_external_reference           in     varchar2
  ,p_invoice_address              in     varchar2
  ,p_invoice_contact              in     varchar2
  ,p_payment_method               in     varchar2
  ,p_pym_information_category     in     varchar2
  ,p_pym_attribute1               in     varchar2
  ,p_pym_attribute2               in     varchar2
  ,p_pym_attribute3               in     varchar2
  ,p_pym_attribute4               in     varchar2
  ,p_pym_attribute5               in     varchar2
  ,p_pym_attribute6               in     varchar2
  ,p_pym_attribute7               in     varchar2
  ,p_pym_attribute8               in     varchar2
  ,p_pym_attribute9               in     varchar2
  ,p_pym_attribute10              in     varchar2
  ,p_pym_attribute11              in     varchar2
  ,p_pym_attribute12              in     varchar2
  ,p_pym_attribute13              in     varchar2
  ,p_pym_attribute14              in     varchar2
  ,p_pym_attribute15              in     varchar2
  ,p_pym_attribute16              in     varchar2
  ,p_pym_attribute17              in     varchar2
  ,p_pym_attribute18              in     varchar2
  ,p_pym_attribute19              in     varchar2
  ,p_pym_attribute20              in     varchar2
  ,p_transfer_date                in     date
  ,p_transfer_message             in     varchar2
  ,p_vendor_id                    in     number
  ,p_contact_id                   in     number
  ,p_address_id                   in     number
  ,p_customer_id                  in     number
  ,p_tfh_information_category     in     varchar2
  ,p_tfh_information1             in     varchar2
  ,p_tfh_information2             in     varchar2
  ,p_tfh_information3             in     varchar2
  ,p_tfh_information4             in     varchar2
  ,p_tfh_information5             in     varchar2
  ,p_tfh_information6             in     varchar2
  ,p_tfh_information7             in     varchar2
  ,p_tfh_information8             in     varchar2
  ,p_tfh_information9             in     varchar2
  ,p_tfh_information10            in     varchar2
  ,p_tfh_information11            in     varchar2
  ,p_tfh_information12            in     varchar2
  ,p_tfh_information13            in     varchar2
  ,p_tfh_information14            in     varchar2
  ,p_tfh_information15            in     varchar2
  ,p_tfh_information16            in     varchar2
  ,p_tfh_information17            in     varchar2
  ,p_tfh_information18            in     varchar2
  ,p_tfh_information19            in     varchar2
  ,p_tfh_information20            in     varchar2
  ,p_paying_cost_center           in     varchar2
  ,p_receiving_cost_center        in     varchar2
  ,p_transfer_from_set_of_book_id in     number
  ,p_transfer_to_set_of_book_id   in     number
  ,p_from_segment1                in     varchar2
  ,p_from_segment2                in     varchar2
  ,p_from_segment3                in     varchar2
  ,p_from_segment4                in     varchar2
  ,p_from_segment5                in     varchar2
  ,p_from_segment6                in     varchar2
  ,p_from_segment7                in     varchar2
  ,p_from_segment8                in     varchar2
  ,p_from_segment9                in     varchar2
  ,p_from_segment10               in     varchar2
  ,p_from_segment11               in     varchar2
  ,p_from_segment12               in     varchar2
  ,p_from_segment13               in     varchar2
  ,p_from_segment14               in     varchar2
  ,p_from_segment15               in     varchar2
  ,p_from_segment16               in     varchar2
  ,p_from_segment17               in     varchar2
  ,p_from_segment18               in     varchar2
  ,p_from_segment19               in     varchar2
  ,p_from_segment20               in     varchar2
  ,p_from_segment21               in     varchar2
  ,p_from_segment22               in     varchar2
  ,p_from_segment23               in     varchar2
  ,p_from_segment24               in     varchar2
  ,p_from_segment25               in     varchar2
  ,p_from_segment26               in     varchar2
  ,p_from_segment27               in     varchar2
  ,p_from_segment28               in     varchar2
  ,p_from_segment29               in     varchar2
  ,p_from_segment30               in     varchar2
  ,p_to_segment1                  in     varchar2
  ,p_to_segment2                  in     varchar2
  ,p_to_segment3                  in     varchar2
  ,p_to_segment4                  in     varchar2
  ,p_to_segment5                  in     varchar2
  ,p_to_segment6                  in     varchar2
  ,p_to_segment7                  in     varchar2
  ,p_to_segment8                  in     varchar2
  ,p_to_segment9                  in     varchar2
  ,p_to_segment10                 in     varchar2
  ,p_to_segment11                 in     varchar2
  ,p_to_segment12                 in     varchar2
  ,p_to_segment13                 in     varchar2
  ,p_to_segment14                 in     varchar2
  ,p_to_segment15                 in     varchar2
  ,p_to_segment16                 in     varchar2
  ,p_to_segment17                 in     varchar2
  ,p_to_segment18                 in     varchar2
  ,p_to_segment19                 in     varchar2
  ,p_to_segment20                 in     varchar2
  ,p_to_segment21                 in     varchar2
  ,p_to_segment22                 in     varchar2
  ,p_to_segment23                 in     varchar2
  ,p_to_segment24                 in     varchar2
  ,p_to_segment25                 in     varchar2
  ,p_to_segment26                 in     varchar2
  ,p_to_segment27                 in     varchar2
  ,p_to_segment28                 in     varchar2
  ,p_to_segment29                 in     varchar2
  ,p_to_segment30                 in     varchar2
  ,p_transfer_from_cc_id          in     number
  ,p_transfer_to_cc_id            in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_finance_header >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_finance_header_api.update_finance_header
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
PROCEDURE update_finance_header
  (p_finance_header_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_new_object_version_number       out nocopy number
  ,p_superceding_header_id        in     number
  ,p_authorizer_person_id         in     number
  ,p_organization_id              in     number
  ,p_administrator                in     number
  ,p_cancelled_flag               in     varchar2
  ,p_currency_code                in     varchar2
  ,p_date_raised                  in     date
  ,p_payment_status_flag          in     varchar2
  ,p_transfer_status              in     varchar2
  ,p_type                         in     varchar2
  ,p_receivable_type              in     varchar2
  ,p_comments                     in     varchar2
  ,p_external_reference           in     varchar2
  ,p_invoice_address              in     varchar2
  ,p_invoice_contact              in     varchar2
  ,p_payment_method               in     varchar2
  ,p_pym_information_category     in     varchar2
  ,p_pym_attribute1               in     varchar2
  ,p_pym_attribute2               in     varchar2
  ,p_pym_attribute3               in     varchar2
  ,p_pym_attribute4               in     varchar2
  ,p_pym_attribute5               in     varchar2
  ,p_pym_attribute6               in     varchar2
  ,p_pym_attribute7               in     varchar2
  ,p_pym_attribute8               in     varchar2
  ,p_pym_attribute9               in     varchar2
  ,p_pym_attribute10              in     varchar2
  ,p_pym_attribute11              in     varchar2
  ,p_pym_attribute12              in     varchar2
  ,p_pym_attribute13              in     varchar2
  ,p_pym_attribute14              in     varchar2
  ,p_pym_attribute15              in     varchar2
  ,p_pym_attribute16              in     varchar2
  ,p_pym_attribute17              in     varchar2
  ,p_pym_attribute18              in     varchar2
  ,p_pym_attribute19              in     varchar2
  ,p_pym_attribute20              in     varchar2
  ,p_transfer_date                in     date
  ,p_transfer_message             in     varchar2
  ,p_vendor_id                    in     number
  ,p_contact_id                   in     number
  ,p_address_id                   in     number
  ,p_customer_id                  in     number
  ,p_tfh_information_category     in     varchar2
  ,p_tfh_information1             in     varchar2
  ,p_tfh_information2             in     varchar2
  ,p_tfh_information3             in     varchar2
  ,p_tfh_information4             in     varchar2
  ,p_tfh_information5             in     varchar2
  ,p_tfh_information6             in     varchar2
  ,p_tfh_information7             in     varchar2
  ,p_tfh_information8             in     varchar2
  ,p_tfh_information9             in     varchar2
  ,p_tfh_information10            in     varchar2
  ,p_tfh_information11            in     varchar2
  ,p_tfh_information12            in     varchar2
  ,p_tfh_information13            in     varchar2
  ,p_tfh_information14            in     varchar2
  ,p_tfh_information15            in     varchar2
  ,p_tfh_information16            in     varchar2
  ,p_tfh_information17            in     varchar2
  ,p_tfh_information18            in     varchar2
  ,p_tfh_information19            in     varchar2
  ,p_tfh_information20            in     varchar2
  ,p_paying_cost_center           in     varchar2
  ,p_receiving_cost_center        in     varchar2
  ,p_transfer_from_set_of_book_id in     number
  ,p_transfer_to_set_of_book_id   in     number
  ,p_from_segment1                in     varchar2
  ,p_from_segment2                in     varchar2
  ,p_from_segment3                in     varchar2
  ,p_from_segment4                in     varchar2
  ,p_from_segment5                in     varchar2
  ,p_from_segment6                in     varchar2
  ,p_from_segment7                in     varchar2
  ,p_from_segment8                in     varchar2
  ,p_from_segment9                in     varchar2
  ,p_from_segment10               in     varchar2
  ,p_from_segment11               in     varchar2
  ,p_from_segment12               in     varchar2
  ,p_from_segment13               in     varchar2
  ,p_from_segment14               in     varchar2
  ,p_from_segment15               in     varchar2
  ,p_from_segment16               in     varchar2
  ,p_from_segment17               in     varchar2
  ,p_from_segment18               in     varchar2
  ,p_from_segment19               in     varchar2
  ,p_from_segment20               in     varchar2
  ,p_from_segment21               in     varchar2
  ,p_from_segment22               in     varchar2
  ,p_from_segment23               in     varchar2
  ,p_from_segment24               in     varchar2
  ,p_from_segment25               in     varchar2
  ,p_from_segment26               in     varchar2
  ,p_from_segment27               in     varchar2
  ,p_from_segment28               in     varchar2
  ,p_from_segment29               in     varchar2
  ,p_from_segment30               in     varchar2
  ,p_to_segment1                  in     varchar2
  ,p_to_segment2                  in     varchar2
  ,p_to_segment3                  in     varchar2
  ,p_to_segment4                  in     varchar2
  ,p_to_segment5                  in     varchar2
  ,p_to_segment6                  in     varchar2
  ,p_to_segment7                  in     varchar2
  ,p_to_segment8                  in     varchar2
  ,p_to_segment9                  in     varchar2
  ,p_to_segment10                 in     varchar2
  ,p_to_segment11                 in     varchar2
  ,p_to_segment12                 in     varchar2
  ,p_to_segment13                 in     varchar2
  ,p_to_segment14                 in     varchar2
  ,p_to_segment15                 in     varchar2
  ,p_to_segment16                 in     varchar2
  ,p_to_segment17                 in     varchar2
  ,p_to_segment18                 in     varchar2
  ,p_to_segment19                 in     varchar2
  ,p_to_segment20                 in     varchar2
  ,p_to_segment21                 in     varchar2
  ,p_to_segment22                 in     varchar2
  ,p_to_segment23                 in     varchar2
  ,p_to_segment24                 in     varchar2
  ,p_to_segment25                 in     varchar2
  ,p_to_segment26                 in     varchar2
  ,p_to_segment27                 in     varchar2
  ,p_to_segment28                 in     varchar2
  ,p_to_segment29                 in     varchar2
  ,p_to_segment30                 in     varchar2
  ,p_transfer_from_cc_id          in     number
  ,p_transfer_to_cc_id            in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_finance_header >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_finance_header_api.delete_finance_header
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
PROCEDURE delete_finance_header
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_finance_header_id            in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );


Procedure cancel_header
  (
   p_finance_header_id     in   number
  ,p_cancel_header_id      out  nocopy number
  ,p_date_raised           in   date
  ,p_validate              in   number    default hr_api.g_false_num
  ,p_commit                in   number    default hr_api.g_false_num
  ,p_return_status  out nocopy VARCHAR2
  );

Procedure recancel_header
  (
   p_finance_header_id     in   number
  ,p_validate              in     number    default hr_api.g_false_num
  ,p_commit                in     number    default hr_api.g_false_num
  ,p_return_status  out nocopy VARCHAR2
  );

Procedure cancel_and_recreate
  (
   p_finance_header_id     in   number
  ,p_recreation_header_id  out  nocopy number
  ,p_cancel_header_id      out  nocopy number
  ,p_date_raised           in   date
  ,p_validate              in     number    default hr_api.g_false_num
  ,p_commit                in     number    default hr_api.g_false_num
  ,p_return_status  out nocopy VARCHAR2
);

end ota_finance_header_swi;

 

/
