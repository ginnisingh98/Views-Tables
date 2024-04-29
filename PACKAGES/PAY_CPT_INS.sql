--------------------------------------------------------
--  DDL for Package PAY_CPT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CPT_INS" AUTHID CURRENT_USER as
/* $Header: pycprrhi.pkh 120.1.12010000.1 2008/07/27 22:24:00 appldev ship $ */

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
	(p_rec 			 in out nocopy pay_cpt_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date);
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
  p_rec		   in out nocopy pay_cpt_shd.g_rec_type,
  p_effective_date in     date
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
  p_emp_province_tax_inf_id      out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_legislation_code             in varchar2,
  p_assignment_id                in number,
  p_business_group_id            in number,
  p_province_code                in varchar2,
  p_jurisdiction_code            in varchar2         default null,
  p_tax_credit_amount            in number           default null,
  p_basic_exemption_flag         in varchar2         default null,
  p_deduction_code               in varchar2         default null,
  p_extra_info_not_provided      in varchar2         default null,
  p_marriage_status              in varchar2         default null,
  p_no_of_infirm_dependants      in number           default null,
  p_non_resident_status          in varchar2         default null,
  p_disability_status            in varchar2         default null,
  p_no_of_dependants             in number           default null,
  p_annual_dedn                  in number           default null,
  p_total_expense_by_commission  in number           default null,
  p_total_remnrtn_by_commission  in number           default null,
  p_prescribed_zone_dedn_amt     in number           default null,
  p_additional_tax               in number           default null,
  p_prov_override_rate           in number           default null,
  p_prov_override_amount         in number           default null,
  p_prov_exempt_flag             in varchar2         default null,
  p_pmed_exempt_flag             in varchar2         default null,
  p_wc_exempt_flag               in varchar2         default null,
  p_qpp_exempt_flag              in varchar2         default null,
  p_tax_calc_method              in varchar2         default null,
  p_other_tax_credit             in number           default null,
  p_ca_tax_information_category  in varchar2         default null,
  p_ca_tax_information1          in varchar2         default null,
  p_ca_tax_information2          in varchar2         default null,
  p_ca_tax_information3          in varchar2         default null,
  p_ca_tax_information4          in varchar2         default null,
  p_ca_tax_information5          in varchar2         default null,
  p_ca_tax_information6          in varchar2         default null,
  p_ca_tax_information7          in varchar2         default null,
  p_ca_tax_information8          in varchar2         default null,
  p_ca_tax_information9          in varchar2         default null,
  p_ca_tax_information10         in varchar2         default null,
  p_ca_tax_information11         in varchar2         default null,
  p_ca_tax_information12         in varchar2         default null,
  p_ca_tax_information13         in varchar2         default null,
  p_ca_tax_information14         in varchar2         default null,
  p_ca_tax_information15         in varchar2         default null,
  p_ca_tax_information16         in varchar2         default null,
  p_ca_tax_information17         in varchar2         default null,
  p_ca_tax_information18         in varchar2         default null,
  p_ca_tax_information19         in varchar2         default null,
  p_ca_tax_information20         in varchar2         default null,
  p_ca_tax_information21         in varchar2         default null,
  p_ca_tax_information22         in varchar2         default null,
  p_ca_tax_information23         in varchar2         default null,
  p_ca_tax_information24         in varchar2         default null,
  p_ca_tax_information25         in varchar2         default null,
  p_ca_tax_information26         in varchar2         default null,
  p_ca_tax_information27         in varchar2         default null,
  p_ca_tax_information28         in varchar2         default null,
  p_ca_tax_information29         in varchar2         default null,
  p_ca_tax_information30         in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_prov_lsp_amount              in number           default null,
  p_effective_date		 in date,
  p_ppip_exempt_flag              in varchar2         default null
  );
--
end pay_cpt_ins;

/
