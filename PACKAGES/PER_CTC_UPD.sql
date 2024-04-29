--------------------------------------------------------
--  DDL for Package PER_CTC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CTC_UPD" AUTHID CURRENT_USER as
/* $Header: pectcrhi.pkh 120.0 2005/05/31 07:20:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to perform the datetrack update mode, fully validating the row
--   for the HR schema passing back to the calling process, any system
--   generated values (e.g. object version number attribute). This process
--   is the main backbone of the upd process. The processing of
--   this procedure is as follows:
--   1) Ensure that the datetrack update mode is valid.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   4) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   5) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   6) The update_dml process will physical perform the update dml into the
--      specified entity.
--   7) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the process have to be in the record
--   format.
--
-- In Parameters:
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
--
-- Post Success:
--   The specified row will be fully validated and datetracked updated for
--   the specified entity without being committed for the datetrack mode.
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
  p_rec			in out nocopy 	per_ctc_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the datetrack update
--   process for the specified entity and is the outermost layer.
--   The role of this process is to update a fully validated row into the
--   HR schema passing back to the calling process, any system generated
--   values (e.g. object version number attributes). The processing of this
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
--   p_effective_date
--     Specifies the date of the datetrack update operation.
--   p_datetrack_mode
--     Determines the datetrack update mode.
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
  p_contract_id                  in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_object_version_number        in out nocopy number,
  p_reference                    in varchar2         default hr_api.g_varchar2,
  p_type                         in varchar2         default hr_api.g_varchar2,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_status_reason                in varchar2         default hr_api.g_varchar2,
  p_doc_status                   in varchar2         default hr_api.g_varchar2,
  p_doc_status_change_date       in date             default hr_api.g_date,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_duration                     in number           default hr_api.g_number,
  p_duration_units               in varchar2         default hr_api.g_varchar2,
  p_contractual_job_title        in varchar2         default hr_api.g_varchar2,
  p_parties                      in varchar2         default hr_api.g_varchar2,
  p_start_reason                 in varchar2         default hr_api.g_varchar2,
  p_end_reason                   in varchar2         default hr_api.g_varchar2,
  p_number_of_extensions         in number           default hr_api.g_number,
  p_extension_reason             in varchar2         default hr_api.g_varchar2,
  p_extension_period             in number           default hr_api.g_number,
  p_extension_period_units       in varchar2         default hr_api.g_varchar2,
  p_ctr_information_category     in varchar2         default hr_api.g_varchar2,
  p_ctr_information1             in varchar2         default hr_api.g_varchar2,
  p_ctr_information2             in varchar2         default hr_api.g_varchar2,
  p_ctr_information3             in varchar2         default hr_api.g_varchar2,
  p_ctr_information4             in varchar2         default hr_api.g_varchar2,
  p_ctr_information5             in varchar2         default hr_api.g_varchar2,
  p_ctr_information6             in varchar2         default hr_api.g_varchar2,
  p_ctr_information7             in varchar2         default hr_api.g_varchar2,
  p_ctr_information8             in varchar2         default hr_api.g_varchar2,
  p_ctr_information9             in varchar2         default hr_api.g_varchar2,
  p_ctr_information10            in varchar2         default hr_api.g_varchar2,
  p_ctr_information11            in varchar2         default hr_api.g_varchar2,
  p_ctr_information12            in varchar2         default hr_api.g_varchar2,
  p_ctr_information13            in varchar2         default hr_api.g_varchar2,
  p_ctr_information14            in varchar2         default hr_api.g_varchar2,
  p_ctr_information15            in varchar2         default hr_api.g_varchar2,
  p_ctr_information16            in varchar2         default hr_api.g_varchar2,
  p_ctr_information17            in varchar2         default hr_api.g_varchar2,
  p_ctr_information18            in varchar2         default hr_api.g_varchar2,
  p_ctr_information19            in varchar2         default hr_api.g_varchar2,
  p_ctr_information20            in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  );
--
procedure update_effective_start_date
  (
  p_contract_id         in      per_contracts_f.contract_id%TYPE,
  p_effective_date      in      date,
  p_new_start_date      in      per_contracts_f.effective_start_date%TYPE,
  p_object_version_number in    per_contracts_f.object_version_number%TYPE
  );
--
end per_ctc_upd;

 

/
