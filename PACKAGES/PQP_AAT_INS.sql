--------------------------------------------------------
--  DDL for Package PQP_AAT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_AAT_INS" AUTHID CURRENT_USER as
/* $Header: pqaatrhi.pkh 120.2.12010000.2 2009/07/01 10:54:32 dchindar ship $ */
--
-- ---------------------------------------------------------------------------+
-- |------------------------------< insert_dml >------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_insert_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within the dt_insert_dml
--   procedure).
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure insert_dml
  (p_rec                   in out nocopy pqp_aat_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );
--
-- ---------------------------------------------------------------------------+
-- |---------------------------------< ins >----------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) We must lock parent rows (if any exist).
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the process have to be in the record
--   format.
--
-- In Parameters:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
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
-- ---------------------------------------------------------------------------+
Procedure ins
  (p_effective_date in     date
  ,p_rec            in out nocopy pqp_aat_shd.g_rec_type
  );
--
-- ---------------------------------------------------------------------------+
-- |---------------------------------< ins >----------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
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
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
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
-- ---------------------------------------------------------------------------+
Procedure ins
  (p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_assignment_id                  in     number
  ,p_contract_type                  in     varchar2 default null
  ,p_work_pattern                   in     varchar2 default null
  ,p_start_day                      in     varchar2 default null
  ,p_primary_company_car            in     number   default null
  ,p_primary_car_fuel_benefit       in     varchar2 default null
  ,p_primary_class_1a               in     varchar2 default null
  ,p_primary_capital_contribution   in     number   default null
  ,p_primary_private_contribution   in     number   default null
  ,p_secondary_company_car          in     number   default null
  ,p_secondary_car_fuel_benefit     in     varchar2 default null
  ,p_secondary_class_1a             in     varchar2 default null
  ,p_secondary_capital_contributi   in     number   default null
  ,p_secondary_private_contributi   in     number   default null
  ,p_company_car_calc_method        in     varchar2 default null
  ,p_company_car_rates_table_id     in     number   default null
  ,p_company_car_secondary_table    in     number   default null
  ,p_private_car                    in     number   default null
  ,p_private_car_calc_method        in     varchar2 default null
  ,p_private_car_rates_table_id     in     number   default null
  ,p_private_car_essential_table    in     number   default null
  ,p_tp_is_teacher                  in     varchar2 default null
  ,p_tp_headteacher_grp_code        in     number   default null --added for head Teacher seconded location for salary scale calculation
  ,p_tp_safeguarded_grade           in     varchar2 default null
  ,p_tp_safeguarded_grade_id        in     number   default null
  ,p_tp_safeguarded_rate_type       in     varchar2 default null
  ,p_tp_safeguarded_rate_id         in     number   default null
  ,p_tp_spinal_point_id             in     number   default null
  ,p_tp_elected_pension             in     varchar2 default null
  ,p_tp_fast_track                  in     varchar2 default null
  ,p_aat_attribute_category         in     varchar2 default null
  ,p_aat_attribute1                 in     varchar2 default null
  ,p_aat_attribute2                 in     varchar2 default null
  ,p_aat_attribute3                 in     varchar2 default null
  ,p_aat_attribute4                 in     varchar2 default null
  ,p_aat_attribute5                 in     varchar2 default null
  ,p_aat_attribute6                 in     varchar2 default null
  ,p_aat_attribute7                 in     varchar2 default null
  ,p_aat_attribute8                 in     varchar2 default null
  ,p_aat_attribute9                 in     varchar2 default null
  ,p_aat_attribute10                in     varchar2 default null
  ,p_aat_attribute11                in     varchar2 default null
  ,p_aat_attribute12                in     varchar2 default null
  ,p_aat_attribute13                in     varchar2 default null
  ,p_aat_attribute14                in     varchar2 default null
  ,p_aat_attribute15                in     varchar2 default null
  ,p_aat_attribute16                in     varchar2 default null
  ,p_aat_attribute17                in     varchar2 default null
  ,p_aat_attribute18                in     varchar2 default null
  ,p_aat_attribute19                in     varchar2 default null
  ,p_aat_attribute20                in     varchar2 default null
  ,p_aat_information_category       in     varchar2 default null
  ,p_aat_information1               in     varchar2 default null
  ,p_aat_information2               in     varchar2 default null
  ,p_aat_information3               in     varchar2 default null
  ,p_aat_information4               in     varchar2 default null
  ,p_aat_information5               in     varchar2 default null
  ,p_aat_information6               in     varchar2 default null
  ,p_aat_information7               in     varchar2 default null
  ,p_aat_information8               in     varchar2 default null
  ,p_aat_information9               in     varchar2 default null
  ,p_aat_information10              in     varchar2 default null
  ,p_aat_information11              in     varchar2 default null
  ,p_aat_information12              in     varchar2 default null
  ,p_aat_information13              in     varchar2 default null
  ,p_aat_information14              in     varchar2 default null
  ,p_aat_information15              in     varchar2 default null
  ,p_aat_information16              in     varchar2 default null
  ,p_aat_information17              in     varchar2 default null
  ,p_aat_information18              in     varchar2 default null
  ,p_aat_information19              in     varchar2 default null
  ,p_aat_information20              in     varchar2 default null
  ,p_lgps_process_flag              in     varchar2 default null
  ,p_lgps_exclusion_type            in     varchar2 default null
  ,p_lgps_pensionable_pay           in     varchar2 default null
  ,p_lgps_trans_arrang_flag         in     varchar2 default null
  ,p_lgps_membership_number         in     varchar2 default null
  ,p_assignment_attribute_id           out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  );
--
end pqp_aat_ins;

/
