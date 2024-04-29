--------------------------------------------------------
--  DDL for Package OTA_NHS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_NHS_INS" AUTHID CURRENT_USER as
/* $Header: otnhsrhi.pkh 120.0 2005/05/29 07:26:54 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--   This procedure is called to register the next ID value from the database
--   sequence.
--
-- Prerequisites:
--
-- In Parameters:
--   Primary Key
--
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_nota_history_id  in  number);
--

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
  (p_effective_date               in date,
  p_rec        in out nocopy ota_nhs_shd.g_rec_type
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
  (p_effective_date               in date,
  p_nota_history_id              out nocopy number,
  p_person_id                    in number,
  p_contact_id                   in number           default null,
  p_trng_title                   in varchar2,
  p_provider                     in varchar2         default null,
  p_type                         in varchar2         default null,
  p_centre                       in varchar2         default null,
  p_completion_date              in date,
  p_award                        in varchar2         default null,
  p_rating                       in varchar2         default null,
  p_duration                     in number           default null,
  p_duration_units               in varchar2         default null,
  p_activity_version_id          in number           default null,
  p_status                       in varchar2,
  p_verified_by_id               in number           default null,
  p_nth_information_category     in varchar2         default null,
  p_nth_information1             in varchar2         default null,
  p_nth_information2             in varchar2         default null,
  p_nth_information3             in varchar2         default null,
  p_nth_information4             in varchar2         default null,
  p_nth_information5             in varchar2         default null,
  p_nth_information6             in varchar2         default null,
  p_nth_information7             in varchar2         default null,
  p_nth_information8             in varchar2         default null,
  p_nth_information9             in varchar2         default null,
  p_nth_information10            in varchar2         default null,
  p_nth_information11            in varchar2         default null,
  p_nth_information12            in varchar2         default null,
  p_nth_information13            in varchar2         default null,
  p_nth_information15            in varchar2         default null,
  p_nth_information16            in varchar2         default null,
  p_nth_information17            in varchar2         default null,
  p_nth_information18            in varchar2         default null,
  p_nth_information19            in varchar2         default null,
  p_nth_information20            in varchar2         default null,
  p_org_id                       in number           default null,
  p_object_version_number        out nocopy number,
  p_business_group_id            in number,
  p_nth_information14            in varchar2         default null,
  p_customer_id          in number       default null,
  p_organization_id      in number       default null
  );
--
end ota_nhs_ins;

 

/
