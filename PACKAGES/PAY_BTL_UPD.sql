--------------------------------------------------------
--  DDL for Package PAY_BTL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BTL_UPD" AUTHID CURRENT_USER as
/* $Header: pybtlrhi.pkh 120.2 2005/10/17 00:50:22 mkataria noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< upd >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) The row to be updated is locked and selected into the record
--      structure g_old_rec.
--   2) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   3) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   4) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   5) The update_dml process will physical perform the update dml into the
--      specified entity.
--   6) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (p_session_date                 in     date
  ,p_rec                          in out nocopy pay_btl_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (p_session_date                 in     date
  ,p_batch_line_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_batch_line_status            in     varchar2  default hr_api.g_varchar2
  ,p_cost_allocation_keyflex_id   in     number    default hr_api.g_number
  ,p_element_type_id              in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_assignment_number            in     varchar2  default hr_api.g_varchar2
  ,p_batch_sequence               in     number    default hr_api.g_number
  ,p_concatenated_segments        in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_element_name                 in     varchar2  default hr_api.g_varchar2
  ,p_entry_type                   in     varchar2  default hr_api.g_varchar2
  ,p_reason                       in     varchar2  default hr_api.g_varchar2
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
  ,p_value_1                      in     varchar2  default hr_api.g_varchar2
  ,p_value_2                      in     varchar2  default hr_api.g_varchar2
  ,p_value_3                      in     varchar2  default hr_api.g_varchar2
  ,p_value_4                      in     varchar2  default hr_api.g_varchar2
  ,p_value_5                      in     varchar2  default hr_api.g_varchar2
  ,p_value_6                      in     varchar2  default hr_api.g_varchar2
  ,p_value_7                      in     varchar2  default hr_api.g_varchar2
  ,p_value_8                      in     varchar2  default hr_api.g_varchar2
  ,p_value_9                      in     varchar2  default hr_api.g_varchar2
  ,p_value_10                     in     varchar2  default hr_api.g_varchar2
  ,p_value_11                     in     varchar2  default hr_api.g_varchar2
  ,p_value_12                     in     varchar2  default hr_api.g_varchar2
  ,p_value_13                     in     varchar2  default hr_api.g_varchar2
  ,p_value_14                     in     varchar2  default hr_api.g_varchar2
  ,p_value_15                     in     varchar2  default hr_api.g_varchar2
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
  ,p_entry_information_category   in     varchar2  default hr_api.g_varchar2
  ,p_entry_information1           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information2           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information3           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information4           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information5           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information6           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information7           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information8           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information9           in     varchar2  default hr_api.g_varchar2
  ,p_entry_information10          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information11          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information12          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information13          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information14          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information15          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information16          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information17          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information18          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information19          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information20          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information21          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information22          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information23          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information24          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information25          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information26          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information27          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information28          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information29          in     varchar2  default hr_api.g_varchar2
  ,p_entry_information30          in     varchar2  default hr_api.g_varchar2
  ,p_date_earned                  in     date      default hr_api.g_date
  ,p_personal_payment_method_id   in     number    default hr_api.g_number
  ,p_subpriority                  in     number    default hr_api.g_number
  ,p_effective_start_date         in     date      default hr_api.g_date
  ,p_effective_end_date           in     date      default hr_api.g_date
  );
--
end pay_btl_upd;

 

/
