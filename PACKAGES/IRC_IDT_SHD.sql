--------------------------------------------------------
--  DDL for Package IRC_IDT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IDT_SHD" AUTHID CURRENT_USER as
/* $Header: iridtrhi.pkh 120.0 2005/07/26 15:07:32 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (default_posting_id              number(15)
  ,language                        varchar2(9)       -- Increased length
  ,source_language                 varchar2(9)       -- Increased length
  ,org_name                        varchar2(240)
  ,org_description_c               clob
  ,org_description                 varchar2(32767)
  ,job_title                       varchar2(240)
  ,brief_description_c             clob
  ,brief_description               varchar2(32767)
  ,detailed_description_c          clob
  ,detailed_description            varchar2(32767)
  ,job_requirements_c              clob
  ,job_requirements                varchar2(32767)
  ,additional_details_c            clob
  ,additional_details              varchar2(32767)
  ,how_to_apply_c                  clob
  ,how_to_apply                    varchar2(32767)
  ,image_url_c                     clob
  ,image_url                       varchar2(32767)
  ,image_url_alt_c                 clob
  ,image_url_alt                   varchar2(32767)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
--
g_org_description_upd boolean default false;
g_brief_description_upd boolean default false;
g_detailed_description_upd boolean default false;
g_job_requirements_upd boolean default false;
g_additional_details_upd boolean default false;
g_how_to_apply_upd boolean default false;
g_image_url_upd boolean default false;
g_image_url_alt_upd boolean default false;
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
  (p_default_posting_id                   in     number
  ,p_language                             in     varchar2
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
  (p_default_posting_id                   in     number
  ,p_language                             in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< add_language >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Maintains the _TL table.  Ensures there is a translation for every
--   installed language, removes any orphaned translation rows and
--   corrects and translations which have got out of synchronisation.
--
-- Pre-requisites:
--
-- In Parameters:
--
-- Post Success:
--  A translation row exists for every installed language.
--
-- Post Failure:
--  Maintenance is aborted.
--
-- Developer Implementation Notes:
--  None.
--
-- Access Status:
--  Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure add_language;
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
  (p_default_posting_id             in number
  ,p_language                       in varchar2
  ,p_source_language                in varchar2
  ,p_org_name                       in varchar2
  ,p_org_description                in varchar2
  ,p_job_title                      in varchar2
  ,p_brief_description              in varchar2
  ,p_detailed_description           in varchar2
  ,p_job_requirements               in varchar2
  ,p_additional_details             in varchar2
  ,p_how_to_apply                   in varchar2
  ,p_image_url                      in varchar2
  ,p_image_url_alt                  in varchar2
  )
  Return g_rec_type;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< clob_dml >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to set CLOB values on the table that are passed
--   in as VARCHAR2.
--
-- Prerequisites:
--   This is a private function and can only be called from the insert_dml
--   or upddate_dml processes.
--
-- In Parameters:
--    p_rec contains the record of the data
--    p_api_updating indicates if the procedure is being called at insert
--    or at update.
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure clob_dml
  (p_rec in out nocopy irc_idt_shd.g_rec_type
  ,p_api_updating boolean
  );
--
 end irc_idt_shd;

 

/
