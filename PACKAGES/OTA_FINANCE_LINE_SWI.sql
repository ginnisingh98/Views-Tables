--------------------------------------------------------
--  DDL for Package OTA_FINANCE_LINE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FINANCE_LINE_SWI" AUTHID CURRENT_USER As
/* $Header: ottflswi.pkh 120.0 2005/05/29 07:43 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_finance_line >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_finance_line_api.create_finance_line
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
PROCEDURE create_finance_line
  (p_finance_line_id              in     number
  ,p_finance_header_id            in     number
  ,p_cancelled_flag               in     varchar2
  ,p_date_raised                  in out nocopy date
  ,p_line_type                    in     varchar2
  ,p_object_version_number           out nocopy number
  ,p_sequence_number              in out nocopy number
  ,p_transfer_status              in     varchar2
  ,p_comments                     in     varchar2
  ,p_currency_code                in     varchar2
  ,p_money_amount                 in     number
  ,p_standard_amount              in     number
  ,p_trans_information_category   in     varchar2
  ,p_trans_information1           in     varchar2
  ,p_trans_information10          in     varchar2
  ,p_trans_information11          in     varchar2
  ,p_trans_information12          in     varchar2
  ,p_trans_information13          in     varchar2
  ,p_trans_information14          in     varchar2
  ,p_trans_information15          in     varchar2
  ,p_trans_information16          in     varchar2
  ,p_trans_information17          in     varchar2
  ,p_trans_information18          in     varchar2
  ,p_trans_information19          in     varchar2
  ,p_trans_information2           in     varchar2
  ,p_trans_information20          in     varchar2
  ,p_trans_information3           in     varchar2
  ,p_trans_information4           in     varchar2
  ,p_trans_information5           in     varchar2
  ,p_trans_information6           in     varchar2
  ,p_trans_information7           in     varchar2
  ,p_trans_information8           in     varchar2
  ,p_trans_information9           in     varchar2
  ,p_transfer_date                in     date
  ,p_transfer_message             in     varchar2
  ,p_unitary_amount               in     number
  ,p_booking_deal_id              in     number
  ,p_booking_id                   in     number
  ,p_resource_allocation_id       in     number
  ,p_resource_booking_id          in     number
  ,p_last_update_date             in     date
  ,p_last_updated_by              in     number
  ,p_last_update_login            in     number
  ,p_created_by                   in     number
  ,p_creation_date                in     date
  ,p_tfl_information_category     in     varchar2
  ,p_tfl_information1             in     varchar2
  ,p_tfl_information2             in     varchar2
  ,p_tfl_information3             in     varchar2
  ,p_tfl_information4             in     varchar2
  ,p_tfl_information5             in     varchar2
  ,p_tfl_information6             in     varchar2
  ,p_tfl_information7             in     varchar2
  ,p_tfl_information8             in     varchar2
  ,p_tfl_information9             in     varchar2
  ,p_tfl_information10            in     varchar2
  ,p_tfl_information11            in     varchar2
  ,p_tfl_information12            in     varchar2
  ,p_tfl_information13            in     varchar2
  ,p_tfl_information14            in     varchar2
  ,p_tfl_information15            in     varchar2
  ,p_tfl_information16            in     varchar2
  ,p_tfl_information17            in     varchar2
  ,p_tfl_information18            in     varchar2
  ,p_tfl_information19            in     varchar2
  ,p_tfl_information20            in     varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_return_status                out    nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_finance_line >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_finance_line_api.update_finance_line
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
PROCEDURE update_finance_line
  (p_finance_line_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_new_object_version_number       out nocopy number
  ,p_finance_header_id            in     number
  ,p_cancelled_flag               in     varchar2
  ,p_date_raised                  in out nocopy date
  ,p_line_type                    in     varchar2
  ,p_sequence_number              in out nocopy number
  ,p_transfer_status              in     varchar2
  ,p_comments                     in     varchar2
  ,p_currency_code                in     varchar2
  ,p_money_amount                 in     number
  ,p_standard_amount              in     number
  ,p_trans_information_category   in     varchar2
  ,p_trans_information1           in     varchar2
  ,p_trans_information10          in     varchar2
  ,p_trans_information11          in     varchar2
  ,p_trans_information12          in     varchar2
  ,p_trans_information13          in     varchar2
  ,p_trans_information14          in     varchar2
  ,p_trans_information15          in     varchar2
  ,p_trans_information16          in     varchar2
  ,p_trans_information17          in     varchar2
  ,p_trans_information18          in     varchar2
  ,p_trans_information19          in     varchar2
  ,p_trans_information2           in     varchar2
  ,p_trans_information20          in     varchar2
  ,p_trans_information3           in     varchar2
  ,p_trans_information4           in     varchar2
  ,p_trans_information5           in     varchar2
  ,p_trans_information6           in     varchar2
  ,p_trans_information7           in     varchar2
  ,p_trans_information8           in     varchar2
  ,p_trans_information9           in     varchar2
  ,p_transfer_date                in     date
  ,p_transfer_message             in     varchar2
  ,p_unitary_amount               in     number
  ,p_booking_deal_id              in     number
  ,p_booking_id                   in     number
  ,p_resource_allocation_id       in     number
  ,p_resource_booking_id          in     number
  ,p_last_update_date             in     date
  ,p_last_updated_by              in     number
  ,p_last_update_login            in     number
  ,p_created_by                   in     number
  ,p_creation_date                in     date
  ,p_tfl_information_category     in     varchar2
  ,p_tfl_information1             in     varchar2
  ,p_tfl_information2             in     varchar2
  ,p_tfl_information3             in     varchar2
  ,p_tfl_information4             in     varchar2
  ,p_tfl_information5             in     varchar2
  ,p_tfl_information6             in     varchar2
  ,p_tfl_information7             in     varchar2
  ,p_tfl_information8             in     varchar2
  ,p_tfl_information9             in     varchar2
  ,p_tfl_information10            in     varchar2
  ,p_tfl_information11            in     varchar2
  ,p_tfl_information12            in     varchar2
  ,p_tfl_information13            in     varchar2
  ,p_tfl_information14            in     varchar2
  ,p_tfl_information15            in     varchar2
  ,p_tfl_information16            in     varchar2
  ,p_tfl_information17            in     varchar2
  ,p_tfl_information18            in     varchar2
  ,p_tfl_information19            in     varchar2
  ,p_tfl_information20            in     varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_transaction_type             in     varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_finance_line >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_finance_line_api.delete_finance_line
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
PROCEDURE delete_finance_line
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_finance_line_id              in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end ota_finance_line_swi;

 

/
