--------------------------------------------------------
--  DDL for Package GHR_CCA_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CCA_SHD" AUTHID CURRENT_USER as
/* $Header: ghccarhi.pkh 120.0 2005/05/29 02:50:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (compl_appeal_id                 number(15)
  ,complaint_id                    number(15)
  ,appeal_date                     date
  ,appealed_to                     varchar2(30)       -- Increased length
  ,reason_for_appeal               varchar2(30)       -- Increased length
  ,source_decision_date            date
  ,docket_num                      varchar2(50)
  ,org_notified_of_appeal          date
  ,agency_recvd_req_for_files      date
  ,files_due                       date
  ,files_forwd                     date
  ,agcy_recvd_appellant_brief      date
  ,agency_brief_due                date
  ,appellant_brief_forwd_org       date
  ,org_forwd_brief_to_agency       date
  ,agency_brief_forwd              date
  ,decision_date                   date
  ,dec_recvd_by_agency             date
  ,decision                        varchar2(30)       -- Increased length
  ,dec_forwd_to_org                date
  ,agency_rfr_suspense             date
  ,request_for_rfr                 date
  ,rfr_docket_num                  varchar2(50)
  ,rfr_requested_by                varchar2(30)       -- Increased length
  ,agency_rfr_due                  date
  ,rfr_forwd_to_org                date
  ,org_forwd_rfr_to_agency         date
  ,agency_forwd_rfr_ofo            date
  ,rfr_decision                    varchar2(30)       -- Increased length
  ,rfr_decision_date               date
  ,agency_recvd_rfr_dec            date
  ,rfr_decision_forwd_to_org       date
  ,object_version_number           number(15)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--   hr_api.unique_integrity_violated has been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--   4) A unique integrity constraint can only be violated during INSERT or
--      UPDATE dml operation.
--
-- Prerequisites:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which corresponds with a constraint error.
--
-- In Parameter:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
--  {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the
--   current row from the database for the specified primary key
--   provided that the primary key exists and is valid and does not
--   already match the current g_old_rec. The function will always return
--   a TRUE value if the g_old_rec is populated with the current row.
--   A FALSE value will be returned if all of the primary key arguments
--   are null.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec
--   is current.
--   A value of FALSE will be returned if all of the primary key arguments
--   have a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (p_compl_appeal_id                      in     number
  ,p_object_version_number                in     number
  )      Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user.
--   Secondly, during the locking of the row, the row is selected into
--   the g_old_rec data structure which enables the current row values from
--   the server to be available to the api.
--
-- Prerequisites:
--   When attempting to call the lock the object version number (if defined)
--   is mandatory.
--
-- In Parameters:
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
--      'HR_7220_INVALID_PRIMARY_KEY'.
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
-- Access Status:
--   Internal Development Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (p_compl_appeal_id                      in     number
  ,p_object_version_number                in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute parameters into the record
--   structure parameter g_rec_type.
--
-- Prerequisites:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Parameters:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function.  Any possible
--   errors within this function will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
  (p_compl_appeal_id                in number
  ,p_complaint_id                   in number
  ,p_appeal_date                    in date
  ,p_appealed_to                    in varchar2
  ,p_reason_for_appeal              in varchar2
  ,p_source_decision_date           in date
  ,p_docket_num                     in varchar2
  ,p_org_notified_of_appeal         in date
  ,p_agency_recvd_req_for_files     in date
  ,p_files_due                      in date
  ,p_files_forwd                    in date
  ,p_agcy_recvd_appellant_brief     in date
  ,p_agency_brief_due               in date
  ,p_appellant_brief_forwd_org      in date
  ,p_org_forwd_brief_to_agency      in date
  ,p_agency_brief_forwd             in date
  ,p_decision_date                  in date
  ,p_dec_recvd_by_agency            in date
  ,p_decision                       in varchar2
  ,p_dec_forwd_to_org               in date
  ,p_agency_rfr_suspense            in date
  ,p_request_for_rfr                in date
  ,p_rfr_docket_num                 in varchar2
  ,p_rfr_requested_by               in varchar2
  ,p_agency_rfr_due                 in date
  ,p_rfr_forwd_to_org               in date
  ,p_org_forwd_rfr_to_agency        in date
  ,p_agency_forwd_rfr_ofo           in date
  ,p_rfr_decision                   in varchar2
  ,p_rfr_decision_date              in date
  ,p_agency_recvd_rfr_dec           in date
  ,p_rfr_decision_forwd_to_org      in date
  ,p_object_version_number          in number
  )
  Return g_rec_type;
--
end ghr_cca_shd;

 

/
