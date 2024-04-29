--------------------------------------------------------
--  DDL for Package HR_ITP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ITP_INS" AUTHID CURRENT_USER as
/* $Header: hritprhi.pkh 120.0 2005/05/31 01:00:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins
--   process. The processing of this procedure is as follows:
--   1) The controlling validation process insert_validate is executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   3) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   4) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
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
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy hr_itp_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
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
Procedure ins
  (p_effective_date               in     date
  ,p_form_item_id                   in     number   default null
  ,p_template_item_id               in     number   default null
  ,p_template_item_context_id       in     number   default null
  ,p_alignment                      in     number   default null
  ,p_bevel                          in     number   default null
  ,p_case_restriction               in     number   default null
  ,p_enabled                        in     number   default null
  ,p_format_mask                    in     varchar2 default null
  ,p_height                         in     number   default null
  ,p_information_formula_id         in     number   default null
  ,p_information_param_item_id1     in     number   default null
  ,p_information_param_item_id2     in     number   default null
  ,p_information_param_item_id3     in     number   default null
  ,p_information_param_item_id4     in     number   default null
  ,p_information_param_item_id5     in     number   default null
  ,p_insert_allowed                 in     number   default null
  ,p_prompt_alignment_offset        in     number   default null
  ,p_prompt_display_style           in     number   default null
  ,p_prompt_edge                    in     number   default null
  ,p_prompt_edge_alignment          in     number   default null
  ,p_prompt_edge_offset             in     number   default null
  ,p_prompt_text_alignment          in     number   default null
  ,p_query_allowed                  in     number   default null
  ,p_required                       in     number   default null
  ,p_update_allowed                 in     number   default null
  ,p_validation_formula_id          in     number   default null
  ,p_validation_param_item_id1      in     number   default null
  ,p_validation_param_item_id2      in     number   default null
  ,p_validation_param_item_id3      in     number   default null
  ,p_validation_param_item_id4      in     number   default null
  ,p_validation_param_item_id5      in     number   default null
  ,p_visible                        in     number   default null
  ,p_width                          in     number   default null
  ,p_x_position                     in     number   default null
  ,p_y_position                     in     number   default null
  ,p_information_category           in     varchar2 default null
  ,p_information1                   in     varchar2 default null
  ,p_information2                   in     varchar2 default null
  ,p_information3                   in     varchar2 default null
  ,p_information4                   in     varchar2 default null
  ,p_information5                   in     varchar2 default null
  ,p_information6                   in     varchar2 default null
  ,p_information7                   in     varchar2 default null
  ,p_information8                   in     varchar2 default null
  ,p_information9                   in     varchar2 default null
  ,p_information10                  in     varchar2 default null
  ,p_information11                  in     varchar2 default null
  ,p_information12                  in     varchar2 default null
  ,p_information13                  in     varchar2 default null
  ,p_information14                  in     varchar2 default null
  ,p_information15                  in     varchar2 default null
  ,p_information16                  in     varchar2 default null
  ,p_information17                  in     varchar2 default null
  ,p_information18                  in     varchar2 default null
  ,p_information19                  in     varchar2 default null
  ,p_information20                  in     varchar2 default null
  ,p_information21                  in     varchar2 default null
  ,p_information22                  in     varchar2 default null
  ,p_information23                  in     varchar2 default null
  ,p_information24                  in     varchar2 default null
  ,p_information25                  in     varchar2 default null
  ,p_information26                  in     varchar2 default null
  ,p_information27                  in     varchar2 default null
  ,p_information28                  in     varchar2 default null
  ,p_information29                  in     varchar2 default null
  ,p_information30                  in     varchar2 default null
  ,p_next_navigation_item_id        in     number   default null
  ,p_previous_navigation_item_id    in     number   default null
  ,p_item_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end hr_itp_ins;

 

/
