--------------------------------------------------------
--  DDL for Package HR_ITP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ITP_UPD" AUTHID CURRENT_USER as
/* $Header: hritprhi.pkh 120.0 2005/05/31 01:00:40 appldev noship $ */
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
  (p_effective_date               in date
  ,p_rec                          in out nocopy hr_itp_shd.g_rec_type
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
  (p_effective_date               in     date
  ,p_item_property_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_form_item_id                 in     number    default hr_api.g_number
  ,p_template_item_id             in     number    default hr_api.g_number
  ,p_template_item_context_id     in     number    default hr_api.g_number
  ,p_alignment                    in     number    default hr_api.g_number
  ,p_bevel                        in     number    default hr_api.g_number
  ,p_case_restriction             in     number    default hr_api.g_number
  ,p_enabled                      in     number    default hr_api.g_number
  ,p_format_mask                  in     varchar2  default hr_api.g_varchar2
  ,p_height                       in     number    default hr_api.g_number
  ,p_information_formula_id       in     number    default hr_api.g_number
  ,p_information_param_item_id1   in     number    default hr_api.g_number
  ,p_information_param_item_id2   in     number    default hr_api.g_number
  ,p_information_param_item_id3   in     number    default hr_api.g_number
  ,p_information_param_item_id4   in     number    default hr_api.g_number
  ,p_information_param_item_id5   in     number    default hr_api.g_number
  ,p_insert_allowed               in     number    default hr_api.g_number
  ,p_prompt_alignment_offset      in     number    default hr_api.g_number
  ,p_prompt_display_style         in     number    default hr_api.g_number
  ,p_prompt_edge                  in     number    default hr_api.g_number
  ,p_prompt_edge_alignment        in     number    default hr_api.g_number
  ,p_prompt_edge_offset           in     number    default hr_api.g_number
  ,p_prompt_text_alignment        in     number    default hr_api.g_number
  ,p_query_allowed                in     number    default hr_api.g_number
  ,p_required                     in     number    default hr_api.g_number
  ,p_update_allowed               in     number    default hr_api.g_number
  ,p_validation_formula_id        in     number    default hr_api.g_number
  ,p_validation_param_item_id1    in     number    default hr_api.g_number
  ,p_validation_param_item_id2    in     number    default hr_api.g_number
  ,p_validation_param_item_id3    in     number    default hr_api.g_number
  ,p_validation_param_item_id4    in     number    default hr_api.g_number
  ,p_validation_param_item_id5    in     number    default hr_api.g_number
  ,p_visible                      in     number    default hr_api.g_number
  ,p_width                        in     number    default hr_api.g_number
  ,p_x_position                   in     number    default hr_api.g_number
  ,p_y_position                   in     number    default hr_api.g_number
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
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
  ,p_next_navigation_item_id      in     number    default hr_api.g_number
  ,p_previous_navigation_item_id  in     number    default hr_api.g_number
  );
--
end hr_itp_upd;

 

/
