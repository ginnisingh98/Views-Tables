--------------------------------------------------------
--  DDL for Package PAY_STA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_STA_INS" AUTHID CURRENT_USER as
/* $Header: pystarhi.pkh 120.0.12000000.2 2007/05/01 22:41:10 ahanda noship $ */

--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
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
--   A Pl/Sql record structre.
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
-- ----------------------------------------------------------------------------
Procedure insert_dml
      (p_rec                   in out nocopy pay_sta_shd.g_rec_type,
       p_effective_date        in      	     date,
       p_datetrack_mode        in      	     varchar2,
       p_validation_start_date in      	     date,
       p_validation_end_date   in      	     date);
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
Procedure ins
  (
  p_rec               in out nocopy pay_sta_shd.g_rec_type,
  p_effective_date in     	    date
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
Procedure ins
  (
  p_emp_state_tax_rule_id        out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_assignment_id                in number,
  p_state_code                   in varchar2,
  p_jurisdiction_code            in varchar2,
  p_business_group_id            in number,
  p_additional_wa_amount         in number,
  p_filing_status_code           in varchar2,
  p_remainder_percent            in number,
  p_secondary_wa                 in number,
  p_sit_additional_tax           in number,
  p_sit_override_amount          in number,
  p_sit_override_rate            in number,
  p_withholding_allowances       in number,
  p_excessive_wa_reject_date     in date             default null,
  p_sdi_exempt                   in varchar2         default null,
  p_sit_exempt                   in varchar2         default null,
  p_sit_optional_calc_ind        in varchar2         default null,
  p_state_non_resident_cert      in varchar2         default null,
  p_sui_exempt                   in varchar2         default null,
  p_wc_exempt                    in varchar2         default null,
  p_wage_exempt                  in varchar2         default null,
  p_sui_wage_base_override_amoun in number           default null,
  p_supp_tax_override_rate       in number           default null,
  p_object_version_number        out nocopy number,
  p_effective_date             in date,
  p_attribute_category          in varchar2         default null,
  p_attribute1                  in varchar2         default null,
  p_attribute2                  in varchar2         default null,
  p_attribute3                  in varchar2         default null,
  p_attribute4                  in varchar2         default null,
  p_attribute5                  in varchar2         default null,
  p_attribute6                  in varchar2         default null,
  p_attribute7                  in varchar2         default null,
  p_attribute8                  in varchar2         default null,
  p_attribute9                  in varchar2         default null,
  p_attribute10                 in varchar2         default null,
  p_attribute11                 in varchar2         default null,
  p_attribute12                 in varchar2         default null,
  p_attribute13                 in varchar2         default null,
  p_attribute14                 in varchar2         default null,
  p_attribute15                 in varchar2         default null,
  p_attribute16                 in varchar2         default null,
  p_attribute17                 in varchar2         default null,
  p_attribute18                 in varchar2         default null,
  p_attribute19                 in varchar2         default null,
  p_attribute20                 in varchar2         default null,
  p_attribute21                 in varchar2         default null,
  p_attribute22                 in varchar2         default null,
  p_attribute23                 in varchar2         default null,
  p_attribute24                 in varchar2         default null,
  p_attribute25                 in varchar2         default null,
  p_attribute26                 in varchar2         default null,
  p_attribute27                 in varchar2         default null,
  p_attribute28                 in varchar2         default null,
  p_attribute29                 in varchar2         default null,
  p_attribute30                 in varchar2         default null,
  p_sta_information_category    in varchar2         default null,
  p_sta_information1            in varchar2         default null,
  p_sta_information2            in varchar2         default null,
  p_sta_information3            in varchar2         default null,
  p_sta_information4            in varchar2         default null,
  p_sta_information5            in varchar2         default null,
  p_sta_information6            in varchar2         default null,
  p_sta_information7            in varchar2         default null,
  p_sta_information8            in varchar2         default null,
  p_sta_information9            in varchar2         default null,
  p_sta_information10           in varchar2         default null,
  p_sta_information11           in varchar2         default null,
  p_sta_information12           in varchar2         default null,
  p_sta_information13           in varchar2         default null,
  p_sta_information14           in varchar2         default null,
  p_sta_information15           in varchar2         default null,
  p_sta_information16           in varchar2         default null,
  p_sta_information17           in varchar2         default null,
  p_sta_information18           in varchar2         default null,
  p_sta_information19           in varchar2         default null,
  p_sta_information20           in varchar2         default null,
  p_sta_information21           in varchar2         default null,
  p_sta_information22           in varchar2         default null,
  p_sta_information23           in varchar2         default null,
  p_sta_information24           in varchar2         default null,
  p_sta_information25           in varchar2         default null,
  p_sta_information26           in varchar2         default null,
  p_sta_information27           in varchar2         default null,
  p_sta_information28           in varchar2         default null,
  p_sta_information29           in varchar2         default null,
  p_sta_information30           in varchar2         default null
  );
--
end pay_sta_ins;

 

/
