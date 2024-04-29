--------------------------------------------------------
--  DDL for Package OTA_TAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TAD_API" AUTHID CURRENT_USER as
/* $Header: ottad01t.pkh 120.1 2005/07/11 07:31:29 pgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  activity_id                       number(9),
  business_group_id                 number(9),
  name                              varchar2(240),
  comments                          varchar2(2000),
  description                       varchar2(4000),
  multiple_con_versions_flag        varchar2(30),
  object_version_number             number(9),        -- Increased length
  tad_information_category          varchar2(30),
  tad_information1                  varchar2(150),
  tad_information2                  varchar2(150),
  tad_information3                  varchar2(150),
  tad_information4                  varchar2(150),
  tad_information5                  varchar2(150),
  tad_information6                  varchar2(150),
  tad_information7                  varchar2(150),
  tad_information8                  varchar2(150),
  tad_information9                  varchar2(150),
  tad_information10                 varchar2(150),
  tad_information11                 varchar2(150),
  tad_information12                 varchar2(150),
  tad_information13                 varchar2(150),
  tad_information14                 varchar2(150),
  tad_information15                 varchar2(150),
  tad_information16                 varchar2(150),
  tad_information17                 varchar2(150),
  tad_information18                 varchar2(150),
  tad_information19                 varchar2(150),
  tad_information20                 varchar2(150),
  category_usage_id                 number(9)
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_unique_name >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The activity name is mandantory and must be unique within business group.
--
Procedure check_unique_name
  (
   p_name               in  varchar2
  ,p_business_group_id  in  number
  ,p_activity_id        in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_activity_id >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Return the surrogate key from a passed parameter of name or code.
--
Function get_activity_id
  (
   p_name               in     varchar2
  ,p_business_group_id  in  number
  )
   Return number;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_tav_exist >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete validation
--   Check whether any child rows in ota_activity_versions exist for
--   this activity. If they do exist then this activity may not be deleted.
--
Procedure check_tav_exist
  (
   p_activity_id      in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_tpm_exist >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete validation
--   Check whether any child rows in ota_training_paln_members exist for
--   this activity. If they do exist then this activity may not be deleted.
--
Procedure check_if_tpm_exist
  (
   p_activity_id      in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_mult_vers_flag >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The attribute multiple_con_versions_flag must be in the domain 'Yes No'.
--
-- Procedure check_mult_vers_flag
--    (
--     p_flag   in    varchar2
--    );
--
-- Look at constraint OTA_TAD_MULTIPLE_CON_VERSI_CHK
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_concurrent_versions >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The MULTIPLE_CON_VERSIONS_FLAG must be set to 'Y' if any concurrent
--   activity Versions exist.
--
Procedure check_concurrent_versions
  (
   p_activity_id  in  number
  ,p_flag         in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the current g_api_dml private global
--   boolean status.
--   The g_api_dml status determines if at the time of the function
--   being executed if a dml statement (i.e. INSERT, UPDATE or DELETE)
--   is being issued from within an api.
--   If the status is TRUE then a dml statement is being issued from
--   within this entity api.
--   This function is primarily to support database triggers which
--   need to maintain the object_version_number for non-supported
--   dml statements (i.e. dml statement issued outside of the api layer).
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   None.
--
-- Post Success:
--   Processing continues.
--   If the function returns a TRUE value then, dml is being executed from
--   within this api.
--
-- Post Failure:
--   None.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user and the
--   specified object version number match. Secondly, during the locking of
--   the row, the row is selected into the g_old_rec data structure which
--   enables the current row values from the server to be available to the api.
--
-- Pre Conditions:
--   When attempting to call the lock the object version number (if defined)
--   is mandatory.
--
-- In Arguments:
--   The arguments to the Lck process are the primary key(s) which uniquely
--   identify the row and the object version number of row.
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for three reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Developer Implementation Notes:
--   For each primary key and the object version number arguments add a
--   call to hr_api.mandatory_arg_error procedure to ensure that these
--   argument values are not null.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_activity_id                        in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert business process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--   6) If the p_validate argument has been set to true an exception is raised
--      which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the Ins process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     business process and is rollbacked at the end of the business process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     arguments being set.
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed. If the p_validate argument has been set to true
--   then all the work will be rolled back.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy g_rec_type,
  p_validate   in boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_activity_id                  out nocopy number,
  p_business_group_id            in number,
  p_name                         in varchar2,
  p_comments                     in varchar2         default null,
  p_description                  in varchar2         default null,
  p_multiple_con_versions_flag   in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_tad_information_category     in varchar2         default null,
  p_tad_information1             in varchar2         default null,
  p_tad_information2             in varchar2         default null,
  p_tad_information3             in varchar2         default null,
  p_tad_information4             in varchar2         default null,
  p_tad_information5             in varchar2         default null,
  p_tad_information6             in varchar2         default null,
  p_tad_information7             in varchar2         default null,
  p_tad_information8             in varchar2         default null,
  p_tad_information9             in varchar2         default null,
  p_tad_information10            in varchar2         default null,
  p_tad_information11            in varchar2         default null,
  p_tad_information12            in varchar2         default null,
  p_tad_information13            in varchar2         default null,
  p_tad_information14            in varchar2         default null,
  p_tad_information15            in varchar2         default null,
  p_tad_information16            in varchar2         default null,
  p_tad_information17            in varchar2         default null,
  p_tad_information18            in varchar2         default null,
  p_tad_information19            in varchar2         default null,
  p_tad_information20            in varchar2         default null,
  p_category_usage_id            in number           default null,
  p_validate                     in boolean          default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update business
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint
--      is issued.
--   2) The row to be updated is then locked and selected into the record
--      structure g_old_rec.
--   3) Because on update arguments which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted arguments to their corresponding
--      value.
--   4) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   5) The pre_update business process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   6) The update_dml process will physical perform the update dml into the
--      specified entity.
--   7) The post_update business process is then executed which enables any
--      logic to be processed after the update dml process.
--   8) If the p_validate argument has been set to true an exception is
--      raised which is handled and processed by performing a rollback to
--      the savepoint which was issued at the beginning of the upd process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     business process and is rollbacked at the end of the business process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     arguments being set.
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed. If the p_validate argument has been set
--   to true then all the work will be rolled back.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy g_rec_type,
  p_validate   in boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_defs function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface business process is executed.
--   3) OUT arguments are then set to their corresponding record arguments.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed (or rollbacked depending on the p_validate
--   status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_activity_id                  in number,
  p_business_group_id            in number           default hr_api.g_number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_multiple_con_versions_flag   in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out  nocopy number,
  p_tad_information_category     in varchar2         default hr_api.g_varchar2,
  p_tad_information1             in varchar2         default hr_api.g_varchar2,
  p_tad_information2             in varchar2         default hr_api.g_varchar2,
  p_tad_information3             in varchar2         default hr_api.g_varchar2,
  p_tad_information4             in varchar2         default hr_api.g_varchar2,
  p_tad_information5             in varchar2         default hr_api.g_varchar2,
  p_tad_information6             in varchar2         default hr_api.g_varchar2,
  p_tad_information7             in varchar2         default hr_api.g_varchar2,
  p_tad_information8             in varchar2         default hr_api.g_varchar2,
  p_tad_information9             in varchar2         default hr_api.g_varchar2,
  p_tad_information10            in varchar2         default hr_api.g_varchar2,
  p_tad_information11            in varchar2         default hr_api.g_varchar2,
  p_tad_information12            in varchar2         default hr_api.g_varchar2,
  p_tad_information13            in varchar2         default hr_api.g_varchar2,
  p_tad_information14            in varchar2         default hr_api.g_varchar2,
  p_tad_information15            in varchar2         default hr_api.g_varchar2,
  p_tad_information16            in varchar2         default hr_api.g_varchar2,
  p_tad_information17            in varchar2         default hr_api.g_varchar2,
  p_tad_information18            in varchar2         default hr_api.g_varchar2,
  p_tad_information19            in varchar2         default hr_api.g_varchar2,
  p_tad_information20            in varchar2         default hr_api.g_varchar2,
  p_category_usage_id            in number           default hr_api.g_number,
  p_validate                     in boolean          default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the delete business process
--   for the specified entity. The role of this process is to delete the
--   row from the HR schema. This process is the main backbone of the del
--   business process. The processing of this procedure is as follows:
--   1) If the p_validate argument has been set to true then a savepoint is
--      issued.
--   2) The controlling validation process delete_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_delete business process is then executed which enables any
--      logic to be processed before the delete dml process is executed.
--   4) The delete_dml process will physical perform the delete dml for the
--      specified row.
--   5) The post_delete business process is then executed which enables any
--      logic to be processed after the delete dml process.
--   6) If the p_validate argument has been set to true an exception is raised
--      which is handled and processed by performing a rollback to the
--      savepoint which was issued at the beginning of the del process.
--
-- Pre Conditions:
--   The main arguments to the business process have to be in the record
--   format.
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     boolean value to true will invoke the process to be validated. The
--     default is false. The validation is controlled by a savepoint and
--     rollback mechanism. The savepoint is issued at the beginning of the
--     business process and is rollbacked at the end of the business process
--     when all the processing has been completed. The rollback is controlled
--     by raising and handling the exception hr_api.validate_enabled. We use
--     the exception because, by raising the exception with the business
--     process, we can exit successfully without having any of the 'OUT'
--     arguments being set.
--
-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed. If the p_validate argument has been set
--   to true then all the work will be rolled back.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	in g_rec_type,
  p_validate   in boolean default false
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the delete business
--   process for the specified entity and is the outermost layer. The role
--   of this process is to validate and delete the specified row from the
--   HR schema. The processing of this procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      explicitly coding the attribute arguments into the g_rec_type
--      datatype.
--   2) After the conversion has taken place, the corresponding record del
--      interface business process is executed.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_validate
--     Determines if the business process is to be validated. Setting this
--     Boolean value to true will invoke the process to be validated.
--     The default is false.
--
-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed (or rollbacked depending on the
--   p_validate status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   The attrbute in arguments should be modified as to the business process
--   requirements.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_activity_id                        in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  );
--
end ota_tad_api;

 

/
