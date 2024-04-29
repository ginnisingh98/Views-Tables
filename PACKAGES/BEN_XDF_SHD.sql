--------------------------------------------------------
--  DDL for Package BEN_XDF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XDF_SHD" AUTHID CURRENT_USER as
/* $Header: bexdfrhi.pkh 120.1 2005/12/05 15:53:53 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--

Type g_rec_type Is Record
  (
  ext_dfn_id                        number(15),
  name                              varchar2(600),
  xml_tag_name                      varchar2(80),
  xdo_template_id                    number(15),
  data_typ_cd                       varchar2(30),
  ext_typ_cd                        varchar2(30),
  output_name                       varchar2(90),
  output_type                       varchar2(90),
  apnd_rqst_id_flag                 varchar2(90),
  prmy_sort_cd                      varchar2(90),
  scnd_sort_cd                      varchar2(90),
  strt_dt                           varchar2(90),
  end_dt                            varchar2(90),
  ext_crit_prfl_id                  number(15),
  ext_file_id                       number(15),
  business_group_id                 number(15),
  legislation_code                  varchar2(30),
  xdf_attribute_category            varchar2(30),
  xdf_attribute1                    varchar2(150),
  xdf_attribute2                    varchar2(150),
  xdf_attribute3                    varchar2(150),
  xdf_attribute4                    varchar2(150),
  xdf_attribute5                    varchar2(150),
  xdf_attribute6                    varchar2(150),
  xdf_attribute7                    varchar2(150),
  xdf_attribute8                    varchar2(150),
  xdf_attribute9                    varchar2(150),
  xdf_attribute10                   varchar2(150),
  xdf_attribute11                   varchar2(150),
  xdf_attribute12                   varchar2(150),
  xdf_attribute13                   varchar2(150),
  xdf_attribute14                   varchar2(150),
  xdf_attribute15                   varchar2(150),
  xdf_attribute16                   varchar2(150),
  xdf_attribute17                   varchar2(150),
  xdf_attribute18                   varchar2(150),
  xdf_attribute19                   varchar2(150),
  xdf_attribute20                   varchar2(150),
  xdf_attribute21                   varchar2(150),
  xdf_attribute22                   varchar2(150),
  xdf_attribute23                   varchar2(150),
  xdf_attribute24                   varchar2(150),
  xdf_attribute25                   varchar2(150),
  xdf_attribute26                   varchar2(150),
  xdf_attribute27                   varchar2(150),
  xdf_attribute28                   varchar2(150),
  xdf_attribute29                   varchar2(150),
  xdf_attribute30                   varchar2(150),
  last_update_date                  date,
  creation_date                     date,
  last_updated_by                   number(15),
  last_update_login                 number(15),
  created_by                        number(15),
  object_version_number             number(9),
  drctry_name                       varchar2(150),
  kickoff_wrt_prc_flag              varchar2(30),
  upd_cm_sent_dt_flag               varchar2(30),
  spcl_hndl_flag                    varchar2(30),
  ext_global_flag                   varchar2(30),
  cm_display_flag                   varchar2(30),
  use_eff_dt_for_chgs_flag          varchar2(30),
  ext_post_prcs_rl                  number(15)
  );


--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
g_api_dml  boolean;                               -- Global api dml status
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
-- Prerequisites:
--   None.
--
-- In Parameters:
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
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean;
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
-- {Start Of Comments}
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
  (
  p_ext_dfn_id                         in number,
  p_object_version_number              in number
  )      Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user.
--   Secondly, during the locking of the row, the row is selected into
--   the g_old_rec data structure which enables the current row values from the
--   server to be available to the api.
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_ext_dfn_id                         in number,
  p_object_version_number              in number
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
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
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
	(
	p_ext_dfn_id                    in number,
	p_name                          in varchar2,
	p_xml_tag_name                  in varchar2,
	p_xdo_template_id               in number,
	p_data_typ_cd                   in varchar2,
	p_ext_typ_cd                    in varchar2,
	p_output_name                   in varchar2,
	p_output_type                   in varchar2,
	p_apnd_rqst_id_flag             in varchar2,
	p_prmy_sort_cd                  in varchar2,
	p_scnd_sort_cd                  in varchar2,
	p_strt_dt                       in varchar2,
	p_end_dt                        in varchar2,
	p_ext_crit_prfl_id              in number,
	p_ext_file_id                   in number,
	p_business_group_id             in number,
        p_legislation_code              in varchar2,
	p_xdf_attribute_category        in varchar2,
	p_xdf_attribute1                in varchar2,
	p_xdf_attribute2                in varchar2,
	p_xdf_attribute3                in varchar2,
	p_xdf_attribute4                in varchar2,
	p_xdf_attribute5                in varchar2,
	p_xdf_attribute6                in varchar2,
	p_xdf_attribute7                in varchar2,
	p_xdf_attribute8                in varchar2,
	p_xdf_attribute9                in varchar2,
	p_xdf_attribute10               in varchar2,
	p_xdf_attribute11               in varchar2,
	p_xdf_attribute12               in varchar2,
	p_xdf_attribute13               in varchar2,
	p_xdf_attribute14               in varchar2,
	p_xdf_attribute15               in varchar2,
	p_xdf_attribute16               in varchar2,
	p_xdf_attribute17               in varchar2,
	p_xdf_attribute18               in varchar2,
	p_xdf_attribute19               in varchar2,
	p_xdf_attribute20               in varchar2,
	p_xdf_attribute21               in varchar2,
	p_xdf_attribute22               in varchar2,
	p_xdf_attribute23               in varchar2,
	p_xdf_attribute24               in varchar2,
	p_xdf_attribute25               in varchar2,
	p_xdf_attribute26               in varchar2,
	p_xdf_attribute27               in varchar2,
	p_xdf_attribute28               in varchar2,
	p_xdf_attribute29               in varchar2,
	p_xdf_attribute30               in varchar2,
        p_last_update_date              in date,
        p_creation_date                 in date,
        p_last_updated_by               in number,
        p_last_update_login             in number,
        p_created_by                    in number,
	p_object_version_number         in number,
	p_drctry_name                   in varchar2,
	p_kickoff_wrt_prc_flag          in varchar2,
	p_upd_cm_sent_dt_flag           in varchar2,
	p_spcl_hndl_flag                in varchar2,
	p_ext_global_flag                in varchar2,
	p_cm_display_flag                in varchar2,
	p_use_eff_dt_for_chgs_flag      in varchar2,
      p_ext_post_prcs_rl                in number
	)
	Return g_rec_type;
--
end ben_xdf_shd;

 

/
