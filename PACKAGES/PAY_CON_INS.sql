--------------------------------------------------------
--  DDL for Package PAY_CON_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CON_INS" AUTHID CURRENT_USER as
/* $Header: pyconrhi.pkh 115.1 99/09/30 13:47:46 porting ship  $ */

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
  p_rec        in out pay_con_shd.g_rec_type
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
  p_contr_history_id             out number,
  p_person_id                    in number,
  p_date_from                    in date,
  p_date_to                      in date,
  p_contr_type                   in varchar2,
  p_business_group_id            in number,
  p_legislation_code             in varchar2,
  p_amt_contr                    in number           default null,
  p_max_contr_allowed            in number           default null,
  p_includable_comp              in number           default null,
  p_tax_unit_id                  in number           default null,
  p_source_system                in varchar2         default null,
  p_contr_information_category   in varchar2         default null,
  p_contr_information1           in varchar2         default null,
  p_contr_information2           in varchar2         default null,
  p_contr_information3           in varchar2         default null,
  p_contr_information4           in varchar2         default null,
  p_contr_information5           in varchar2         default null,
  p_contr_information6           in varchar2         default null,
  p_contr_information7           in varchar2         default null,
  p_contr_information8           in varchar2         default null,
  p_contr_information9           in varchar2         default null,
  p_contr_information10          in varchar2         default null,
  p_contr_information11          in varchar2         default null,
  p_contr_information12          in varchar2         default null,
  p_contr_information13          in varchar2         default null,
  p_contr_information14          in varchar2         default null,
  p_contr_information15          in varchar2         default null,
  p_contr_information16          in varchar2         default null,
  p_contr_information17          in varchar2         default null,
  p_contr_information18          in varchar2         default null,
  p_contr_information19          in varchar2         default null,
  p_contr_information20          in varchar2         default null,
  p_contr_information21          in varchar2         default null,
  p_contr_information22          in varchar2         default null,
  p_contr_information23          in varchar2         default null,
  p_contr_information24          in varchar2         default null,
  p_contr_information25          in varchar2         default null,
  p_contr_information26          in varchar2         default null,
  p_contr_information27          in varchar2         default null,
  p_contr_information28          in varchar2         default null,
  p_contr_information29          in varchar2         default null,
  p_contr_information30          in varchar2         default null,
  p_object_version_number        out number
  );
--
end pay_con_ins;

 

/
