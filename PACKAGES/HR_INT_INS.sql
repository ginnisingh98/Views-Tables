--------------------------------------------------------
--  DDL for Package HR_INT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_INT_INS" AUTHID CURRENT_USER as
/* $Header: hrintrhi.pkh 120.0 2005/05/31 00:52 appldev noship $ */
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
  (p_integration_id  in  number);
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
  (p_rec                      in out nocopy hr_int_shd.g_rec_type
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
  (p_integration_key                in     varchar2
  ,p_party_type                     in     varchar2 default null
  ,p_party_name                     in     varchar2 default null
  ,p_party_site_name                in     varchar2 default null
  ,p_transaction_type               in     varchar2 default null
  ,p_transaction_subtype            in     varchar2 default null
  ,p_standard_code                  in     varchar2 default null
  ,p_ext_trans_type                 in     varchar2 default null
  ,p_ext_trans_subtype              in     varchar2 default null
  ,p_trans_direction                in     varchar2 default null
  ,p_url                            in     varchar2 default null
  ,p_ext_application_id             in     number   default null
  ,p_application_name               in     varchar2 default null
  ,p_application_type               in     varchar2 default null
  ,p_application_url                in     varchar2 default null
  ,p_logout_url                     in     varchar2 default null
  ,p_user_field                     in     varchar2 default null
  ,p_password_field                 in     varchar2 default null
  ,p_authentication_needed          in     varchar2 default null
  ,p_field_name1                    in     varchar2 default null
  ,p_field_value1                   in     varchar2 default null
  ,p_field_name2                    in     varchar2 default null
  ,p_field_value2                   in     varchar2 default null
  ,p_field_name3                    in     varchar2 default null
  ,p_field_value3                   in     varchar2 default null
  ,p_field_name4                    in     varchar2 default null
  ,p_field_value4                   in     varchar2 default null
  ,p_field_name5                    in     varchar2 default null
  ,p_field_value5                   in     varchar2 default null
  ,p_field_name6                    in     varchar2 default null
  ,p_field_value6                   in     varchar2 default null
  ,p_field_name7                    in     varchar2 default null
  ,p_field_value7                   in     varchar2 default null
  ,p_field_name8                    in     varchar2 default null
  ,p_field_value8                   in     varchar2 default null
  ,p_field_name9                    in     varchar2 default null
  ,p_field_value9                   in     varchar2 default null
  ,p_integration_id                    out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end hr_int_ins;

 

/
