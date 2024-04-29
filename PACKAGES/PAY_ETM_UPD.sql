--------------------------------------------------------
--  DDL for Package PAY_ETM_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ETM_UPD" AUTHID CURRENT_USER as
/* $Header: pyetmrhi.pkh 115.5 2003/11/05 01:47:04 sdhole ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
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
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
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
  (p_effective_date  in     date
  ,p_rec              in out nocopy pay_etm_shd.g_rec_type
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
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
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
  (
  p_template_id                  in number,
  p_effective_date               in date,
  p_base_processing_priority     in number           default hr_api.g_number,
  p_version_number               in number           default hr_api.g_number,
  p_max_base_name_length         in number           default hr_api.g_number,
  p_preference_info_category     in varchar2         default hr_api.g_varchar2,
  p_preference_information1      in varchar2         default hr_api.g_varchar2,
  p_preference_information2      in varchar2         default hr_api.g_varchar2,
  p_preference_information3      in varchar2         default hr_api.g_varchar2,
  p_preference_information4      in varchar2         default hr_api.g_varchar2,
  p_preference_information5      in varchar2         default hr_api.g_varchar2,
  p_preference_information6      in varchar2         default hr_api.g_varchar2,
  p_preference_information7      in varchar2         default hr_api.g_varchar2,
  p_preference_information8      in varchar2         default hr_api.g_varchar2,
  p_preference_information9      in varchar2         default hr_api.g_varchar2,
  p_preference_information10     in varchar2         default hr_api.g_varchar2,
  p_preference_information11     in varchar2         default hr_api.g_varchar2,
  p_preference_information12     in varchar2         default hr_api.g_varchar2,
  p_preference_information13     in varchar2         default hr_api.g_varchar2,
  p_preference_information14     in varchar2         default hr_api.g_varchar2,
  p_preference_information15     in varchar2         default hr_api.g_varchar2,
  p_preference_information16     in varchar2         default hr_api.g_varchar2,
  p_preference_information17     in varchar2         default hr_api.g_varchar2,
  p_preference_information18     in varchar2         default hr_api.g_varchar2,
  p_preference_information19     in varchar2         default hr_api.g_varchar2,
  p_preference_information20     in varchar2         default hr_api.g_varchar2,
  p_preference_information21     in varchar2         default hr_api.g_varchar2,
  p_preference_information22     in varchar2         default hr_api.g_varchar2,
  p_preference_information23     in varchar2         default hr_api.g_varchar2,
  p_preference_information24     in varchar2         default hr_api.g_varchar2,
  p_preference_information25     in varchar2         default hr_api.g_varchar2,
  p_preference_information26     in varchar2         default hr_api.g_varchar2,
  p_preference_information27     in varchar2         default hr_api.g_varchar2,
  p_preference_information28     in varchar2         default hr_api.g_varchar2,
  p_preference_information29     in varchar2         default hr_api.g_varchar2,
  p_preference_information30     in varchar2         default hr_api.g_varchar2,
  p_configuration_info_category  in varchar2         default hr_api.g_varchar2,
  p_configuration_information1   in varchar2         default hr_api.g_varchar2,
  p_configuration_information2   in varchar2         default hr_api.g_varchar2,
  p_configuration_information3   in varchar2         default hr_api.g_varchar2,
  p_configuration_information4   in varchar2         default hr_api.g_varchar2,
  p_configuration_information5   in varchar2         default hr_api.g_varchar2,
  p_configuration_information6   in varchar2         default hr_api.g_varchar2,
  p_configuration_information7   in varchar2         default hr_api.g_varchar2,
  p_configuration_information8   in varchar2         default hr_api.g_varchar2,
  p_configuration_information9   in varchar2         default hr_api.g_varchar2,
  p_configuration_information10  in varchar2         default hr_api.g_varchar2,
  p_configuration_information11  in varchar2         default hr_api.g_varchar2,
  p_configuration_information12  in varchar2         default hr_api.g_varchar2,
  p_configuration_information13  in varchar2         default hr_api.g_varchar2,
  p_configuration_information14  in varchar2         default hr_api.g_varchar2,
  p_configuration_information15  in varchar2         default hr_api.g_varchar2,
  p_configuration_information16  in varchar2         default hr_api.g_varchar2,
  p_configuration_information17  in varchar2         default hr_api.g_varchar2,
  p_configuration_information18  in varchar2         default hr_api.g_varchar2,
  p_configuration_information19  in varchar2         default hr_api.g_varchar2,
  p_configuration_information20  in varchar2         default hr_api.g_varchar2,
  p_configuration_information21  in varchar2         default hr_api.g_varchar2,
  p_configuration_information22  in varchar2         default hr_api.g_varchar2,
  p_configuration_information23  in varchar2         default hr_api.g_varchar2,
  p_configuration_information24  in varchar2         default hr_api.g_varchar2,
  p_configuration_information25  in varchar2         default hr_api.g_varchar2,
  p_configuration_information26  in varchar2         default hr_api.g_varchar2,
  p_configuration_information27  in varchar2         default hr_api.g_varchar2,
  p_configuration_information28  in varchar2         default hr_api.g_varchar2,
  p_configuration_information29  in varchar2         default hr_api.g_varchar2,
  p_configuration_information30  in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number
  );
--
end pay_etm_upd;

 

/
