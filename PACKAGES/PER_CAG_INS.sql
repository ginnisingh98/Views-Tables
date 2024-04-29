--------------------------------------------------------
--  DDL for Package PER_CAG_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CAG_INS" AUTHID CURRENT_USER as
/* $Header: pecagrhi.pkh 120.0 2005/05/31 06:22:21 appldev noship $ */

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
  p_rec        in out nocopy per_cag_shd.g_rec_type
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
  p_collective_agreement_id      out nocopy number,
  p_business_group_id            in number,
  p_object_version_number        out nocopy number,
  p_name                         in varchar2,
  p_pl_id                        in number,
  p_status                       in varchar2         default null,
  p_cag_number                   in number           default null,
  p_description                  in varchar2         default null,
  p_start_date                   in date             default null,
  p_end_date                     in date             default null,
  p_employer_organization_id     in number           default null,
  p_employer_signatory           in varchar2         default null,
  p_bargaining_organization_id   in number           default null,
  p_bargaining_unit_signatory    in varchar2         default null,
  p_jurisdiction                 in varchar2         default null,
  p_authorizing_body             in varchar2         default null,
  p_authorized_date              in date             default null,
  p_cag_information_category     in varchar2         default null,
  p_cag_information1             in varchar2         default null,
  p_cag_information2             in varchar2         default null,
  p_cag_information3             in varchar2         default null,
  p_cag_information4             in varchar2         default null,
  p_cag_information5             in varchar2         default null,
  p_cag_information6             in varchar2         default null,
  p_cag_information7             in varchar2         default null,
  p_cag_information8             in varchar2         default null,
  p_cag_information9             in varchar2         default null,
  p_cag_information10            in varchar2         default null,
  p_cag_information11            in varchar2         default null,
  p_cag_information12            in varchar2         default null,
  p_cag_information13            in varchar2         default null,
  p_cag_information14            in varchar2         default null,
  p_cag_information15            in varchar2         default null,
  p_cag_information16            in varchar2         default null,
  p_cag_information17            in varchar2         default null,
  p_cag_information18            in varchar2         default null,
  p_cag_information19            in varchar2         default null,
  p_cag_information20            in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null
  );
--
end per_cag_ins;

 

/
