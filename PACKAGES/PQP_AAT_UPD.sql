--------------------------------------------------------
--  DDL for Package PQP_AAT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_AAT_UPD" AUTHID CURRENT_USER as
/* $Header: pqaatrhi.pkh 120.2.12010000.2 2009/07/01 10:54:32 dchindar ship $ */
--
-- ---------------------------------------------------------------------------+
-- |---------------------------------< upd >----------------------------------|
-- ---------------------------------------------------------------------------+
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
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- ---------------------------------------------------------------------------+
Procedure upd
  (p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  ,p_rec            in out nocopy pqp_aat_shd.g_rec_type
  );
--
-- ---------------------------------------------------------------------------+
-- |-------------------------------< upd >------------------------------------|
-- ---------------------------------------------------------------------------+
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
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure upd
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_assignment_attribute_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_contract_type                in     varchar2  default hr_api.g_varchar2
  ,p_work_pattern                 in     varchar2  default hr_api.g_varchar2
  ,p_start_day                    in     varchar2  default hr_api.g_varchar2
  ,p_primary_company_car          in     number    default hr_api.g_number
  ,p_primary_car_fuel_benefit     in     varchar2  default hr_api.g_varchar2
  ,p_primary_class_1a             in     varchar2  default hr_api.g_varchar2
  ,p_primary_capital_contribution in     number    default hr_api.g_number
  ,p_primary_private_contribution in     number    default hr_api.g_number
  ,p_secondary_company_car        in     number    default hr_api.g_number
  ,p_secondary_car_fuel_benefit   in     varchar2  default hr_api.g_varchar2
  ,p_secondary_class_1a           in     varchar2  default hr_api.g_varchar2
  ,p_secondary_capital_contributi in     number    default hr_api.g_number
  ,p_secondary_private_contributi in     number    default hr_api.g_number
  ,p_company_car_calc_method      in     varchar2  default hr_api.g_varchar2
  ,p_company_car_rates_table_id   in     number    default hr_api.g_number
  ,p_company_car_secondary_table  in     number    default hr_api.g_number
  ,p_private_car                  in     number    default hr_api.g_number
  ,p_private_car_calc_method      in     varchar2  default hr_api.g_varchar2
  ,p_private_car_rates_table_id   in     number    default hr_api.g_number
  ,p_private_car_essential_table  in     number    default hr_api.g_number
  ,p_tp_is_teacher                in     varchar2  default hr_api.g_varchar2
  ,p_tp_headteacher_grp_code      in     number    default hr_api.g_number --added for head Teacher seconded location for salary scale calculation
  ,p_tp_safeguarded_grade         in     varchar2  default hr_api.g_varchar2
  ,p_tp_safeguarded_grade_id      in     number    default hr_api.g_number
  ,p_tp_safeguarded_rate_type     in     varchar2  default hr_api.g_varchar2
  ,p_tp_safeguarded_rate_id       in     number    default hr_api.g_number
  ,p_tp_spinal_point_id           in     number    default hr_api.g_number
  ,p_tp_elected_pension           in     varchar2  default hr_api.g_varchar2
  ,p_tp_fast_track                in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_aat_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_aat_information1             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information2             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information3             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information4             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information5             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information6             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information7             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information8             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information9             in     varchar2  default hr_api.g_varchar2
  ,p_aat_information10            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information11            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information12            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information13            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information14            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information15            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information16            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information17            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information18            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information19            in     varchar2  default hr_api.g_varchar2
  ,p_aat_information20            in     varchar2  default hr_api.g_varchar2
  ,p_lgps_process_flag            in     varchar2  default hr_api.g_varchar2
  ,p_lgps_exclusion_type          in     varchar2  default hr_api.g_varchar2
  ,p_lgps_pensionable_pay         in     varchar2  default hr_api.g_varchar2
  ,p_lgps_trans_arrang_flag       in     varchar2  default hr_api.g_varchar2
  ,p_lgps_membership_number       in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
end pqp_aat_upd;

/
