--------------------------------------------------------
--  DDL for Package Body IRC_IPD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IPD_UPD" as
/* $Header: iripdrhi.pkb 120.0 2005/07/26 15:09:42 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ipd_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec in out nocopy irc_ipd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  --
  -- Update the irc_pending_data Row
  --
  update irc_pending_data
    set
     pending_data_id                 = p_rec.pending_data_id
    ,email_address                   = p_rec.email_address
    ,last_name                       = p_rec.last_name
    ,first_name                      = p_rec.first_name
    ,user_password                   = p_rec.user_password
    ,resume_file_name                = p_rec.resume_file_name
    ,resume_description              = p_rec.resume_description
    ,resume_mime_type                = p_rec.resume_mime_type
    ,source_type                     = p_rec.source_type
    ,job_post_source_name            = p_rec.job_post_source_name
    ,posting_content_id              = p_rec.posting_content_id
    ,person_id                       = p_rec.person_id
    ,processed                       = p_rec.processed
    ,sex                             = p_rec.sex
    ,date_of_birth                   = p_rec.date_of_birth
    ,per_information_category        = p_rec.per_information_category
    ,per_information1                = p_rec.per_information1
    ,per_information2                = p_rec.per_information2
    ,per_information3                = p_rec.per_information3
    ,per_information4                = p_rec.per_information4
    ,per_information5                = p_rec.per_information5
    ,per_information6                = p_rec.per_information6
    ,per_information7                = p_rec.per_information7
    ,per_information8                = p_rec.per_information8
    ,per_information9                = p_rec.per_information9
    ,per_information10               = p_rec.per_information10
    ,per_information11               = p_rec.per_information11
    ,per_information12               = p_rec.per_information12
    ,per_information13               = p_rec.per_information13
    ,per_information14               = p_rec.per_information14
    ,per_information15               = p_rec.per_information15
    ,per_information16               = p_rec.per_information16
    ,per_information17               = p_rec.per_information17
    ,per_information18               = p_rec.per_information18
    ,per_information19               = p_rec.per_information19
    ,per_information20               = p_rec.per_information20
    ,per_information21               = p_rec.per_information21
    ,per_information22               = p_rec.per_information22
    ,per_information23               = p_rec.per_information23
    ,per_information24               = p_rec.per_information24
    ,per_information25               = p_rec.per_information25
    ,per_information26               = p_rec.per_information26
    ,per_information27               = p_rec.per_information27
    ,per_information28               = p_rec.per_information28
    ,per_information29               = p_rec.per_information29
    ,per_information30               = p_rec.per_information30
    ,error_message                   = p_rec.error_message
    ,last_update_date                = p_rec.last_update_date
    ,allow_access                    = p_rec.allow_access
    ,user_guid                       = p_rec.user_guid
    ,visitor_resp_key                = p_rec.visitor_resp_key
    ,visitor_resp_appl_id            = p_rec.visitor_resp_appl_id
    ,security_group_key              = p_rec.security_group_key
    where pending_data_id = p_rec.pending_data_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    irc_ipd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    irc_ipd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    irc_ipd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec in irc_ipd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_rec                          in irc_ipd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_ipd_rku.after_update
      (p_pending_data_id
      => p_rec.pending_data_id
      ,p_email_address
      => p_rec.email_address
      ,p_last_name
      => p_rec.last_name
      ,p_first_name
      => p_rec.first_name
      ,p_user_password
      => p_rec.user_password
      ,p_resume_file_name
      => p_rec.resume_file_name
      ,p_resume_description
      => p_rec.resume_description
      ,p_resume_mime_type
      => p_rec.resume_mime_type
      ,p_source_type
      => p_rec.source_type
      ,p_job_post_source_name
      => p_rec.job_post_source_name
      ,p_posting_content_id
      => p_rec.posting_content_id
      ,p_person_id
      => p_rec.person_id
      ,p_processed
      => p_rec.processed
      ,p_sex
      => p_rec.sex
      ,p_date_of_birth
      => p_rec.date_of_birth
      ,p_per_information_category
      => p_rec.per_information_category
      ,p_per_information1
      => p_rec.per_information1
      ,p_per_information2
      => p_rec.per_information2
      ,p_per_information3
      => p_rec.per_information3
      ,p_per_information4
      => p_rec.per_information4
      ,p_per_information5
      => p_rec.per_information5
      ,p_per_information6
      => p_rec.per_information6
      ,p_per_information7
      => p_rec.per_information7
      ,p_per_information8
      => p_rec.per_information8
      ,p_per_information9
      => p_rec.per_information9
      ,p_per_information10
      => p_rec.per_information10
      ,p_per_information11
      => p_rec.per_information11
      ,p_per_information12
      => p_rec.per_information12
      ,p_per_information13
      => p_rec.per_information13
      ,p_per_information14
      => p_rec.per_information14
      ,p_per_information15
      => p_rec.per_information15
      ,p_per_information16
      => p_rec.per_information16
      ,p_per_information17
      => p_rec.per_information17
      ,p_per_information18
      => p_rec.per_information18
      ,p_per_information19
      => p_rec.per_information19
      ,p_per_information20
      => p_rec.per_information20
      ,p_per_information21
      => p_rec.per_information21
      ,p_per_information22
      => p_rec.per_information22
      ,p_per_information23
      => p_rec.per_information23
      ,p_per_information24
      => p_rec.per_information24
      ,p_per_information25
      => p_rec.per_information25
      ,p_per_information26
      => p_rec.per_information26
      ,p_per_information27
      => p_rec.per_information27
      ,p_per_information28
      => p_rec.per_information28
      ,p_per_information29
      => p_rec.per_information29
      ,p_per_information30
      => p_rec.per_information30
      ,p_error_message
      => p_rec.error_message
      ,p_last_update_date
      => p_rec.last_update_date
      ,p_allow_access
      => p_rec.allow_access
      ,p_visitor_resp_key
      => p_rec.visitor_resp_key
      ,p_visitor_resp_appl_id
      => p_rec.visitor_resp_appl_id
      ,p_security_group_key
      => p_rec.security_group_key
      ,p_email_address_o
      => irc_ipd_shd.g_old_rec.email_address
      ,p_vacancy_id_o
      => irc_ipd_shd.g_old_rec.vacancy_id
      ,p_last_name_o
      => irc_ipd_shd.g_old_rec.last_name
      ,p_first_name_o
      => irc_ipd_shd.g_old_rec.first_name
      ,p_user_password_o
      => irc_ipd_shd.g_old_rec.user_password
      ,p_resume_file_name_o
      => irc_ipd_shd.g_old_rec.resume_file_name
      ,p_resume_description_o
      => irc_ipd_shd.g_old_rec.resume_description
      ,p_resume_mime_type_o
      => irc_ipd_shd.g_old_rec.resume_mime_type
      ,p_source_type_o
      => irc_ipd_shd.g_old_rec.source_type
      ,p_job_post_source_name_o
      => irc_ipd_shd.g_old_rec.job_post_source_name
      ,p_posting_content_id_o
      => irc_ipd_shd.g_old_rec.posting_content_id
      ,p_person_id_o
      => irc_ipd_shd.g_old_rec.person_id
      ,p_processed_o
      => irc_ipd_shd.g_old_rec.processed
      ,p_sex_o
      => irc_ipd_shd.g_old_rec.sex
      ,p_date_of_birth_o
      => irc_ipd_shd.g_old_rec.date_of_birth
      ,p_per_information_category_o
      => irc_ipd_shd.g_old_rec.per_information_category
      ,p_per_information1_o
      => irc_ipd_shd.g_old_rec.per_information1
      ,p_per_information2_o
      => irc_ipd_shd.g_old_rec.per_information2
      ,p_per_information3_o
      => irc_ipd_shd.g_old_rec.per_information3
      ,p_per_information4_o
      => irc_ipd_shd.g_old_rec.per_information4
      ,p_per_information5_o
      => irc_ipd_shd.g_old_rec.per_information5
      ,p_per_information6_o
      => irc_ipd_shd.g_old_rec.per_information6
      ,p_per_information7_o
      => irc_ipd_shd.g_old_rec.per_information7
      ,p_per_information8_o
      => irc_ipd_shd.g_old_rec.per_information8
      ,p_per_information9_o
      => irc_ipd_shd.g_old_rec.per_information9
      ,p_per_information10_o
      => irc_ipd_shd.g_old_rec.per_information10
      ,p_per_information11_o
      => irc_ipd_shd.g_old_rec.per_information11
      ,p_per_information12_o
      => irc_ipd_shd.g_old_rec.per_information12
      ,p_per_information13_o
      => irc_ipd_shd.g_old_rec.per_information13
      ,p_per_information14_o
      => irc_ipd_shd.g_old_rec.per_information14
      ,p_per_information15_o
      => irc_ipd_shd.g_old_rec.per_information15
      ,p_per_information16_o
      => irc_ipd_shd.g_old_rec.per_information16
      ,p_per_information17_o
      => irc_ipd_shd.g_old_rec.per_information17
      ,p_per_information18_o
      => irc_ipd_shd.g_old_rec.per_information18
      ,p_per_information19_o
      => irc_ipd_shd.g_old_rec.per_information19
      ,p_per_information20_o
      => irc_ipd_shd.g_old_rec.per_information20
      ,p_per_information21_o
      => irc_ipd_shd.g_old_rec.per_information21
      ,p_per_information22_o
      => irc_ipd_shd.g_old_rec.per_information22
      ,p_per_information23_o
      => irc_ipd_shd.g_old_rec.per_information23
      ,p_per_information24_o
      => irc_ipd_shd.g_old_rec.per_information24
      ,p_per_information25_o
      => irc_ipd_shd.g_old_rec.per_information25
      ,p_per_information26_o
      => irc_ipd_shd.g_old_rec.per_information26
      ,p_per_information27_o
      => irc_ipd_shd.g_old_rec.per_information27
      ,p_per_information28_o
      => irc_ipd_shd.g_old_rec.per_information28
      ,p_per_information29_o
      => irc_ipd_shd.g_old_rec.per_information29
      ,p_per_information30_o
      => irc_ipd_shd.g_old_rec.per_information30
      ,p_error_message_o
      => irc_ipd_shd.g_old_rec.error_message
      ,p_creation_date_o
      => irc_ipd_shd.g_old_rec.creation_date
      ,p_last_update_date_o
      => irc_ipd_shd.g_old_rec.last_update_date
      ,p_allow_access_o
      => irc_ipd_shd.g_old_rec.allow_access
	  ,p_visitor_resp_key_o
      => irc_ipd_shd.g_old_rec.visitor_resp_key
      ,p_visitor_resp_appl_id_o
      => irc_ipd_shd.g_old_rec.visitor_resp_appl_id
      ,p_security_group_key_o
      => irc_ipd_shd.g_old_rec.security_group_key
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_PENDING_DATA'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
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
Procedure convert_defs
  (p_rec in out nocopy irc_ipd_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.email_address = hr_api.g_varchar2) then
    p_rec.email_address :=
    irc_ipd_shd.g_old_rec.email_address;
  End If;
  If (p_rec.vacancy_id = hr_api.g_number) then
    p_rec.vacancy_id :=
    irc_ipd_shd.g_old_rec.vacancy_id;
  End If;
  If (p_rec.last_name = hr_api.g_varchar2) then
    p_rec.last_name :=
    irc_ipd_shd.g_old_rec.last_name;
  End If;
  If (p_rec.first_name = hr_api.g_varchar2) then
    p_rec.first_name :=
    irc_ipd_shd.g_old_rec.first_name;
  End If;
  If (p_rec.user_password = hr_api.g_varchar2) then
    p_rec.user_password :=
    irc_ipd_shd.g_old_rec.user_password;
  End If;
  If (p_rec.resume_file_name = hr_api.g_varchar2) then
    p_rec.resume_file_name :=
    irc_ipd_shd.g_old_rec.resume_file_name;
  End If;
  If (p_rec.resume_description = hr_api.g_varchar2) then
    p_rec.resume_description :=
    irc_ipd_shd.g_old_rec.resume_description;
  End If;
  If (p_rec.resume_mime_type = hr_api.g_varchar2) then
    p_rec.resume_mime_type :=
    irc_ipd_shd.g_old_rec.resume_mime_type;
  End If;
  If (p_rec.source_type = hr_api.g_varchar2) then
    p_rec.source_type :=
    irc_ipd_shd.g_old_rec.source_type;
  End If;
  If (p_rec.job_post_source_name = hr_api.g_varchar2) then
    p_rec.job_post_source_name :=
    irc_ipd_shd.g_old_rec.job_post_source_name;
  End If;
  If (p_rec.posting_content_id = hr_api.g_number) then
    p_rec.posting_content_id :=
    irc_ipd_shd.g_old_rec.posting_content_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    irc_ipd_shd.g_old_rec.person_id;
  End If;
  If (p_rec.processed = hr_api.g_varchar2) then
    p_rec.processed :=
    irc_ipd_shd.g_old_rec.processed;
  End If;
  If (p_rec.sex = hr_api.g_varchar2) then
    p_rec.sex :=
    irc_ipd_shd.g_old_rec.sex;
  End If;
  If (p_rec.date_of_birth = hr_api.g_date) then
    p_rec.date_of_birth :=
    irc_ipd_shd.g_old_rec.date_of_birth;
  End If;
  If (p_rec.per_information_category = hr_api.g_varchar2) then
    p_rec.per_information_category :=
    irc_ipd_shd.g_old_rec.per_information_category;
  End If;
  If (p_rec.per_information1 = hr_api.g_varchar2) then
    p_rec.per_information1 :=
    irc_ipd_shd.g_old_rec.per_information1;
  End If;
  If (p_rec.per_information2 = hr_api.g_varchar2) then
    p_rec.per_information2 :=
    irc_ipd_shd.g_old_rec.per_information2;
  End If;
  If (p_rec.per_information3 = hr_api.g_varchar2) then
    p_rec.per_information3 :=
    irc_ipd_shd.g_old_rec.per_information3;
  End If;
  If (p_rec.per_information4 = hr_api.g_varchar2) then
    p_rec.per_information4 :=
    irc_ipd_shd.g_old_rec.per_information4;
  End If;
  If (p_rec.per_information5 = hr_api.g_varchar2) then
    p_rec.per_information5 :=
    irc_ipd_shd.g_old_rec.per_information5;
  End If;
  If (p_rec.per_information6 = hr_api.g_varchar2) then
    p_rec.per_information6 :=
    irc_ipd_shd.g_old_rec.per_information6;
  End If;
  If (p_rec.per_information7 = hr_api.g_varchar2) then
    p_rec.per_information7 :=
    irc_ipd_shd.g_old_rec.per_information7;
  End If;
  If (p_rec.per_information8 = hr_api.g_varchar2) then
    p_rec.per_information8 :=
    irc_ipd_shd.g_old_rec.per_information8;
  End If;
  If (p_rec.per_information9 = hr_api.g_varchar2) then
    p_rec.per_information9 :=
    irc_ipd_shd.g_old_rec.per_information9;
  End If;
  If (p_rec.per_information10 = hr_api.g_varchar2) then
    p_rec.per_information10 :=
    irc_ipd_shd.g_old_rec.per_information10;
  End If;
  If (p_rec.per_information11 = hr_api.g_varchar2) then
    p_rec.per_information11 :=
    irc_ipd_shd.g_old_rec.per_information11;
  End If;
  If (p_rec.per_information12 = hr_api.g_varchar2) then
    p_rec.per_information12 :=
    irc_ipd_shd.g_old_rec.per_information12;
  End If;
  If (p_rec.per_information13 = hr_api.g_varchar2) then
    p_rec.per_information13 :=
    irc_ipd_shd.g_old_rec.per_information13;
  End If;
  If (p_rec.per_information14 = hr_api.g_varchar2) then
    p_rec.per_information14 :=
    irc_ipd_shd.g_old_rec.per_information14;
  End If;
  If (p_rec.per_information15 = hr_api.g_varchar2) then
    p_rec.per_information15 :=
    irc_ipd_shd.g_old_rec.per_information15;
  End If;
  If (p_rec.per_information16 = hr_api.g_varchar2) then
    p_rec.per_information16 :=
    irc_ipd_shd.g_old_rec.per_information16;
  End If;
  If (p_rec.per_information17 = hr_api.g_varchar2) then
    p_rec.per_information17 :=
    irc_ipd_shd.g_old_rec.per_information17;
  End If;
  If (p_rec.per_information18 = hr_api.g_varchar2) then
    p_rec.per_information18 :=
    irc_ipd_shd.g_old_rec.per_information18;
  End If;
  If (p_rec.per_information19 = hr_api.g_varchar2) then
    p_rec.per_information19 :=
    irc_ipd_shd.g_old_rec.per_information19;
  End If;
  If (p_rec.per_information20 = hr_api.g_varchar2) then
    p_rec.per_information20 :=
    irc_ipd_shd.g_old_rec.per_information20;
  End If;
  If (p_rec.per_information21 = hr_api.g_varchar2) then
    p_rec.per_information21 :=
    irc_ipd_shd.g_old_rec.per_information21;
  End If;
  If (p_rec.per_information22 = hr_api.g_varchar2) then
    p_rec.per_information22 :=
    irc_ipd_shd.g_old_rec.per_information22;
  End If;
  If (p_rec.per_information23 = hr_api.g_varchar2) then
    p_rec.per_information23 :=
    irc_ipd_shd.g_old_rec.per_information23;
  End If;
  If (p_rec.per_information24 = hr_api.g_varchar2) then
    p_rec.per_information24 :=
    irc_ipd_shd.g_old_rec.per_information24;
  End If;
  If (p_rec.per_information25 = hr_api.g_varchar2) then
    p_rec.per_information25 :=
    irc_ipd_shd.g_old_rec.per_information25;
  End If;
  If (p_rec.per_information26 = hr_api.g_varchar2) then
    p_rec.per_information26 :=
    irc_ipd_shd.g_old_rec.per_information26;
  End If;
  If (p_rec.per_information27 = hr_api.g_varchar2) then
    p_rec.per_information27 :=
    irc_ipd_shd.g_old_rec.per_information27;
  End If;
  If (p_rec.per_information28 = hr_api.g_varchar2) then
    p_rec.per_information28 :=
    irc_ipd_shd.g_old_rec.per_information28;
  End If;
  If (p_rec.per_information29 = hr_api.g_varchar2) then
    p_rec.per_information29 :=
    irc_ipd_shd.g_old_rec.per_information29;
  End If;
  If (p_rec.per_information30 = hr_api.g_varchar2) then
    p_rec.per_information30 :=
    irc_ipd_shd.g_old_rec.per_information30;
  End If;
  If (p_rec.error_message = hr_api.g_varchar2) then
    p_rec.error_message :=
    irc_ipd_shd.g_old_rec.error_message;
  End If;
  If (p_rec.creation_date= hr_api.g_date) then
    p_rec.creation_date :=
    irc_ipd_shd.g_old_rec.creation_date;
  End If;
  If (p_rec.last_update_date = hr_api.g_date) then
    p_rec.last_update_date :=
    irc_ipd_shd.g_old_rec.last_update_date;
  End If;
  If (p_rec.allow_access = hr_api.g_varchar2) then
    p_rec.allow_access :=
    irc_ipd_shd.g_old_rec.allow_access;
  End If;
  -- don't handle USER_GUID as we don't have a default value for RAW
  If (p_rec.visitor_resp_key = hr_api.g_varchar2) then
    p_rec.visitor_resp_key :=
    irc_ipd_shd.g_old_rec.visitor_resp_key;
  End If;
  If (p_rec.visitor_resp_appl_id = hr_api.g_number) then
    p_rec.visitor_resp_appl_id :=
    irc_ipd_shd.g_old_rec.visitor_resp_appl_id;
  End If;
  If (p_rec.security_group_key = hr_api.g_varchar2) then
    p_rec.security_group_key :=
    irc_ipd_shd.g_old_rec.security_group_key;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy irc_ipd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  irc_ipd_shd.lck
    (p_rec.pending_data_id
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  irc_ipd_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  irc_ipd_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  irc_ipd_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  irc_ipd_upd.post_update
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_pending_data_id              in     number
  ,p_email_address                in     varchar2  default hr_api.g_varchar2
  ,p_last_name                    in     varchar2  default hr_api.g_varchar2
  ,p_first_name                   in     varchar2  default hr_api.g_varchar2
  ,p_user_password                in     varchar2  default hr_api.g_varchar2
  ,p_resume_file_name             in     varchar2  default hr_api.g_varchar2
  ,p_resume_description           in     varchar2  default hr_api.g_varchar2
  ,p_resume_mime_type             in     varchar2  default hr_api.g_varchar2
  ,p_source_type                  in     varchar2  default hr_api.g_varchar2
  ,p_job_post_source_name         in     varchar2  default hr_api.g_varchar2
  ,p_posting_content_id           in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_processed                    in     varchar2  default hr_api.g_varchar2
  ,p_sex                          in     varchar2  default hr_api.g_varchar2
  ,p_date_of_birth                in     date      default hr_api.g_date
  ,p_per_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_per_information1             in     varchar2  default hr_api.g_varchar2
  ,p_per_information2             in     varchar2  default hr_api.g_varchar2
  ,p_per_information3             in     varchar2  default hr_api.g_varchar2
  ,p_per_information4             in     varchar2  default hr_api.g_varchar2
  ,p_per_information5             in     varchar2  default hr_api.g_varchar2
  ,p_per_information6             in     varchar2  default hr_api.g_varchar2
  ,p_per_information7             in     varchar2  default hr_api.g_varchar2
  ,p_per_information8             in     varchar2  default hr_api.g_varchar2
  ,p_per_information9             in     varchar2  default hr_api.g_varchar2
  ,p_per_information10            in     varchar2  default hr_api.g_varchar2
  ,p_per_information11            in     varchar2  default hr_api.g_varchar2
  ,p_per_information12            in     varchar2  default hr_api.g_varchar2
  ,p_per_information13            in     varchar2  default hr_api.g_varchar2
  ,p_per_information14            in     varchar2  default hr_api.g_varchar2
  ,p_per_information15            in     varchar2  default hr_api.g_varchar2
  ,p_per_information16            in     varchar2  default hr_api.g_varchar2
  ,p_per_information17            in     varchar2  default hr_api.g_varchar2
  ,p_per_information18            in     varchar2  default hr_api.g_varchar2
  ,p_per_information19            in     varchar2  default hr_api.g_varchar2
  ,p_per_information20            in     varchar2  default hr_api.g_varchar2
  ,p_per_information21            in     varchar2  default hr_api.g_varchar2
  ,p_per_information22            in     varchar2  default hr_api.g_varchar2
  ,p_per_information23            in     varchar2  default hr_api.g_varchar2
  ,p_per_information24            in     varchar2  default hr_api.g_varchar2
  ,p_per_information25            in     varchar2  default hr_api.g_varchar2
  ,p_per_information26            in     varchar2  default hr_api.g_varchar2
  ,p_per_information27            in     varchar2  default hr_api.g_varchar2
  ,p_per_information28            in     varchar2  default hr_api.g_varchar2
  ,p_per_information29            in     varchar2  default hr_api.g_varchar2
  ,p_per_information30            in     varchar2  default hr_api.g_varchar2
  ,p_error_message                in     varchar2  default hr_api.g_varchar2
  ,p_last_update_date             in     date      default hr_api.g_date
  ,p_allow_access                 in     varchar2  default hr_api.g_varchar2
  ,p_user_guid                    in     raw       default NULL
  ,p_visitor_resp_key             in     varchar2  default hr_api.g_varchar2
  ,p_visitor_resp_appl_id         in     number    default hr_api.g_number
  ,p_security_group_key           in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   irc_ipd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  irc_ipd_shd.convert_args
  (p_pending_data_id
  ,p_email_address
  ,hr_api.g_number
  ,p_last_name
  ,p_first_name
  ,p_user_password
  ,p_resume_file_name
  ,p_resume_description
  ,p_resume_mime_type
  ,p_source_type
  ,p_job_post_source_name
  ,p_posting_content_id
  ,p_person_id
  ,p_processed
  ,p_sex
  ,p_date_of_birth
  ,p_per_information_category
  ,p_per_information1
  ,p_per_information2
  ,p_per_information3
  ,p_per_information4
  ,p_per_information5
  ,p_per_information6
  ,p_per_information7
  ,p_per_information8
  ,p_per_information9
  ,p_per_information10
  ,p_per_information11
  ,p_per_information12
  ,p_per_information13
  ,p_per_information14
  ,p_per_information15
  ,p_per_information16
  ,p_per_information17
  ,p_per_information18
  ,p_per_information19
  ,p_per_information20
  ,p_per_information21
  ,p_per_information22
  ,p_per_information23
  ,p_per_information24
  ,p_per_information25
  ,p_per_information26
  ,p_per_information27
  ,p_per_information28
  ,p_per_information29
  ,p_per_information30
  ,p_error_message
  ,hr_api.g_date
  ,p_last_update_date
  ,p_allow_access
  ,p_user_guid
  ,p_visitor_resp_key
  ,p_visitor_resp_appl_id
  ,p_security_group_key
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  irc_ipd_upd.upd
     (l_rec
     );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end irc_ipd_upd;

/
