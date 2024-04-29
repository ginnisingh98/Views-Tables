--------------------------------------------------------
--  DDL for Package Body IRC_IOF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IOF_UPD" as
/* $Header: iriofrhi.pkb 120.13.12010000.2 2009/03/06 06:12:46 kvenukop ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     private global definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_iof_upd.';  -- global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {start of comments}
--
-- description:
--   this procedure controls the actual dml update logic. the processing of
--   this procedure is:
--   1) increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) to set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) to update the specified row in the schema using the primary key in
--      the predicates.
--   4) to trap any constraint violations that may have occurred.
--   5) to raise any other errors.
--
-- prerequisites:
--   this is an internal private procedure which must be called from the upd
--   procedure.
--
-- in parameters:
--   a pl/sql record structre.
--
-- post success:
--   the specified row will be updated in the schema.
--
-- post failure:
--   on the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   if a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   if any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- developer implementation notes:
--   the update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- access status:
--   internal row handler use only.
--
-- {end of comments}
-- ----------------------------------------------------------------------------
procedure update_dml
  (p_rec in out nocopy irc_iof_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  --
  -- increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- update the irc_offers row
  --
  update irc_offers
    set
     offer_id                        = p_rec.offer_id
    ,offer_version                   = p_rec.offer_version
    ,latest_offer                    = p_rec.latest_offer
    ,offer_status                    = p_rec.offer_status
    ,discretionary_job_title         = p_rec.discretionary_job_title
    ,offer_extended_method           = p_rec.offer_extended_method
    ,respondent_id                   = p_rec.respondent_id
    ,expiry_date                     = p_rec.expiry_date
    ,proposed_start_date             = p_rec.proposed_start_date
    ,offer_letter_tracking_code      = p_rec.offer_letter_tracking_code
    ,offer_postal_service            = p_rec.offer_postal_service
    ,offer_shipping_date             = p_rec.offer_shipping_date
    ,vacancy_id                      = p_rec.vacancy_id
    ,applicant_assignment_id         = p_rec.applicant_assignment_id
    ,offer_assignment_id             = p_rec.offer_assignment_id
    ,address_id                      = p_rec.address_id
    ,template_id                     = p_rec.template_id
    ,offer_letter_file_type          = p_rec.offer_letter_file_type
    ,offer_letter_file_name          = p_rec.offer_letter_file_name
    ,attribute_category              = p_rec.attribute_category
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
    ,attribute6                      = p_rec.attribute6
    ,attribute7                      = p_rec.attribute7
    ,attribute8                      = p_rec.attribute8
    ,attribute9                      = p_rec.attribute9
    ,attribute10                     = p_rec.attribute10
    ,attribute11                     = p_rec.attribute11
    ,attribute12                     = p_rec.attribute12
    ,attribute13                     = p_rec.attribute13
    ,attribute14                     = p_rec.attribute14
    ,attribute15                     = p_rec.attribute15
    ,attribute16                     = p_rec.attribute16
    ,attribute17                     = p_rec.attribute17
    ,attribute18                     = p_rec.attribute18
    ,attribute19                     = p_rec.attribute19
    ,attribute20                     = p_rec.attribute20
    ,attribute21                     = p_rec.attribute21
    ,attribute22                     = p_rec.attribute22
    ,attribute23                     = p_rec.attribute23
    ,attribute24                     = p_rec.attribute24
    ,attribute25                     = p_rec.attribute25
    ,attribute26                     = p_rec.attribute26
    ,attribute27                     = p_rec.attribute27
    ,attribute28                     = p_rec.attribute28
    ,attribute29                     = p_rec.attribute29
    ,attribute30                     = p_rec.attribute30
    ,object_version_number           = p_rec.object_version_number
    where offer_id = p_rec.offer_id;
  --
  --
  --
  hr_utility.set_location(' leaving:'||l_proc, 10);
--
exception
  when hr_api.check_integrity_violated then
    -- a check constraint has been violated
    --
    irc_iof_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(sqlerrm));
  when hr_api.parent_integrity_violated then
    -- parent integrity has been violated
    --
    irc_iof_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(sqlerrm));
  when hr_api.unique_integrity_violated then
    -- unique integrity has been violated
    --
    irc_iof_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(sqlerrm));
  when others then
    --
    raise;
end update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {start of comments}
--
-- description:
--   this private procedure contains any processing which is required before
--   the update dml.
--
-- prerequisites:
--   this is an internal procedure which is called from the upd procedure.
--
-- in parameters:
--   a pl/sql record structure.
--
-- post success:
--   processing continues.
--
-- post failure:
--   if an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- developer implementation notes:
--   any pre-processing required before the update dml is issued should be
--   coded within this procedure. it is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- access status:
--   internal row handler use only.
--
-- {end of comments}
-- ----------------------------------------------------------------------------
procedure pre_update
  (p_rec in irc_iof_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  --
  hr_utility.set_location(' leaving:'||l_proc, 10);
end pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {start of comments}
--
-- description:
--   this private procedure contains any processing which is required after
--   the update dml.
--
-- prerequisites:
--   this is an internal procedure which is called from the upd procedure.
--
-- in parameters:
--   a pl/sql record structure.
--
-- post success:
--   processing continues.
--
-- post failure:
--   if an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- developer implementation notes:
--   any post-processing required after the update dml is issued should be
--   coded within this procedure. it is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- access status:
--   internal row handler use only.
--
-- {end of comments}
-- ----------------------------------------------------------------------------
procedure post_update
  (p_effective_date               in date
  ,p_rec                          in irc_iof_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  begin
    --
    irc_iof_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_offer_id
      => p_rec.offer_id
      ,p_offer_version
      => p_rec.offer_version
      ,p_latest_offer
      => p_rec.latest_offer
      ,p_offer_status
      => p_rec.offer_status
      ,p_discretionary_job_title
      => p_rec.discretionary_job_title
      ,p_offer_extended_method
      => p_rec.offer_extended_method
      ,p_respondent_id
      => p_rec.respondent_id
      ,p_expiry_date
      => p_rec.expiry_date
      ,p_proposed_start_date
      => p_rec.proposed_start_date
      ,p_offer_letter_tracking_code
      => p_rec.offer_letter_tracking_code
      ,p_offer_postal_service
      => p_rec.offer_postal_service
      ,p_offer_shipping_date
      => p_rec.offer_shipping_date
      ,p_vacancy_id
      => p_rec.vacancy_id
      ,p_applicant_assignment_id
      => p_rec.applicant_assignment_id
      ,p_offer_assignment_id
      => p_rec.offer_assignment_id
      ,p_address_id
      => p_rec.address_id
      ,p_template_id
      => p_rec.template_id
      ,p_offer_letter_file_type
      => p_rec.offer_letter_file_type
      ,p_offer_letter_file_name
      => p_rec.offer_letter_file_name
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_attribute21
      => p_rec.attribute21
      ,p_attribute22
      => p_rec.attribute22
      ,p_attribute23
      => p_rec.attribute23
      ,p_attribute24
      => p_rec.attribute24
      ,p_attribute25
      => p_rec.attribute25
      ,p_attribute26
      => p_rec.attribute26
      ,p_attribute27
      => p_rec.attribute27
      ,p_attribute28
      => p_rec.attribute28
      ,p_attribute29
      => p_rec.attribute29
      ,p_attribute30
      => p_rec.attribute30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_offer_version_o
      => irc_iof_shd.g_old_rec.offer_version
      ,p_latest_offer_o
      => irc_iof_shd.g_old_rec.latest_offer
      ,p_offer_status_o
      => irc_iof_shd.g_old_rec.offer_status
      ,p_discretionary_job_title_o
      => irc_iof_shd.g_old_rec.discretionary_job_title
      ,p_offer_extended_method_o
      => irc_iof_shd.g_old_rec.offer_extended_method
      ,p_respondent_id_o
      => irc_iof_shd.g_old_rec.respondent_id
      ,p_expiry_date_o
      => irc_iof_shd.g_old_rec.expiry_date
      ,p_proposed_start_date_o
      => irc_iof_shd.g_old_rec.proposed_start_date
      ,p_offer_letter_tracking_code_o
      => irc_iof_shd.g_old_rec.offer_letter_tracking_code
      ,p_offer_postal_service_o
      => irc_iof_shd.g_old_rec.offer_postal_service
      ,p_offer_shipping_date_o
      => irc_iof_shd.g_old_rec.offer_shipping_date
      ,p_vacancy_id_o
      => irc_iof_shd.g_old_rec.vacancy_id
      ,p_applicant_assignment_id_o
      => irc_iof_shd.g_old_rec.applicant_assignment_id
      ,p_offer_assignment_id_o
      => irc_iof_shd.g_old_rec.offer_assignment_id
      ,p_address_id_o
      => irc_iof_shd.g_old_rec.address_id
      ,p_template_id_o
      => irc_iof_shd.g_old_rec.template_id
      ,p_offer_letter_file_type_o
      => irc_iof_shd.g_old_rec.offer_letter_file_type
      ,p_offer_letter_file_name_o
      => irc_iof_shd.g_old_rec.offer_letter_file_name
      ,p_attribute_category_o
      => irc_iof_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => irc_iof_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => irc_iof_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => irc_iof_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => irc_iof_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => irc_iof_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => irc_iof_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => irc_iof_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => irc_iof_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => irc_iof_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => irc_iof_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => irc_iof_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => irc_iof_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => irc_iof_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => irc_iof_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => irc_iof_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => irc_iof_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => irc_iof_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => irc_iof_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => irc_iof_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => irc_iof_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => irc_iof_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => irc_iof_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => irc_iof_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => irc_iof_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => irc_iof_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => irc_iof_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => irc_iof_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => irc_iof_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => irc_iof_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => irc_iof_shd.g_old_rec.attribute30
      ,p_object_version_number_o
      => irc_iof_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'irc_offers'
        ,p_hook_type   => 'au');
      --
  end;
  --
  hr_utility.set_location(' leaving:'||l_proc, 10);
end post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {start of comments}
--
-- description:
--   the convert_defs procedure has one very important function:
--   it must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. when
--   we attempt to update a row through the upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). for the upd process to determine which attributes
--   have not been specified we need to check if the parameter has a reserved
--   system default value. therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. if a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- prerequisites:
--   this private function can only be called from the upd process.
--
-- in parameters:
--   a pl/sql record structure.
--
-- post success:
--   the record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- post failure:
--   no direct error handling is required within this function. any possible
--   errors within this procedure will be a pl/sql value error due to
--   conversion of datatypes or data lengths.
--
-- developer implementation notes:
--   none.
--
-- access status:
--   internal row handler use only.
--
-- {end of comments}
-- ----------------------------------------------------------------------------
procedure convert_defs
  (p_rec in out nocopy irc_iof_shd.g_rec_type
  ) is
--
begin
  --
  -- we must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. if a system default
  -- is being used then we must set to the 'current' argument value.
  --
  if (p_rec.offer_version = hr_api.g_number) then
    p_rec.offer_version :=
    irc_iof_shd.g_old_rec.offer_version;
  end if;
  if (p_rec.latest_offer = hr_api.g_varchar2) then
    p_rec.latest_offer :=
    irc_iof_shd.g_old_rec.latest_offer;
  end if;
  if (p_rec.offer_status = hr_api.g_varchar2) then
    p_rec.offer_status :=
    irc_iof_shd.g_old_rec.offer_status;
  end if;
  if (p_rec.discretionary_job_title = hr_api.g_varchar2) then
    p_rec.discretionary_job_title :=
    irc_iof_shd.g_old_rec.discretionary_job_title;
  end if;
  if (p_rec.offer_extended_method = hr_api.g_varchar2) then
    p_rec.offer_extended_method :=
    irc_iof_shd.g_old_rec.offer_extended_method;
  end if;
  if (p_rec.respondent_id = hr_api.g_number) then
    p_rec.respondent_id :=
    irc_iof_shd.g_old_rec.respondent_id;
  end if;
  if (p_rec.expiry_date = hr_api.g_date) then
    p_rec.expiry_date :=
    irc_iof_shd.g_old_rec.expiry_date;
  end if;
  if (p_rec.proposed_start_date = hr_api.g_date) then
    p_rec.proposed_start_date :=
    irc_iof_shd.g_old_rec.proposed_start_date;
  end if;
  if (p_rec.offer_letter_tracking_code = hr_api.g_varchar2) then
    p_rec.offer_letter_tracking_code :=
    irc_iof_shd.g_old_rec.offer_letter_tracking_code;
  end if;
  if (p_rec.offer_postal_service = hr_api.g_varchar2) then
    p_rec.offer_postal_service :=
    irc_iof_shd.g_old_rec.offer_postal_service;
  end if;
  if (p_rec.offer_shipping_date = hr_api.g_date) then
    p_rec.offer_shipping_date :=
    irc_iof_shd.g_old_rec.offer_shipping_date;
  end if;
  if (p_rec.vacancy_id = hr_api.g_number) then
    p_rec.vacancy_id :=
    irc_iof_shd.g_old_rec.vacancy_id;
  end if;
  if (p_rec.applicant_assignment_id = hr_api.g_number) then
    p_rec.applicant_assignment_id :=
    irc_iof_shd.g_old_rec.applicant_assignment_id;
  end if;
  if (p_rec.offer_assignment_id = hr_api.g_number) then
    p_rec.offer_assignment_id :=
    irc_iof_shd.g_old_rec.offer_assignment_id;
  end if;
  if (p_rec.address_id = hr_api.g_number) then
    p_rec.address_id :=
    irc_iof_shd.g_old_rec.address_id;
  end if;
  if (p_rec.template_id = hr_api.g_number) then
    p_rec.template_id :=
    irc_iof_shd.g_old_rec.template_id;
  end if;
  if (p_rec.offer_letter_file_type = hr_api.g_varchar2) then
    p_rec.offer_letter_file_type :=
    irc_iof_shd.g_old_rec.offer_letter_file_type;
  end if;
  if (p_rec.offer_letter_file_name = hr_api.g_varchar2) then
    p_rec.offer_letter_file_name :=
    irc_iof_shd.g_old_rec.offer_letter_file_name;
  end if;
  if (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    irc_iof_shd.g_old_rec.attribute_category;
  end if;
  if (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    irc_iof_shd.g_old_rec.attribute1;
  end if;
  if (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    irc_iof_shd.g_old_rec.attribute2;
  end if;
  if (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    irc_iof_shd.g_old_rec.attribute3;
  end if;
  if (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    irc_iof_shd.g_old_rec.attribute4;
  end if;
  if (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    irc_iof_shd.g_old_rec.attribute5;
  end if;
  if (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    irc_iof_shd.g_old_rec.attribute6;
  end if;
  if (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    irc_iof_shd.g_old_rec.attribute7;
  end if;
  if (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    irc_iof_shd.g_old_rec.attribute8;
  end if;
  if (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    irc_iof_shd.g_old_rec.attribute9;
  end if;
  if (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    irc_iof_shd.g_old_rec.attribute10;
  end if;
  if (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    irc_iof_shd.g_old_rec.attribute11;
  end if;
  if (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    irc_iof_shd.g_old_rec.attribute12;
  end if;
  if (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    irc_iof_shd.g_old_rec.attribute13;
  end if;
  if (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    irc_iof_shd.g_old_rec.attribute14;
  end if;
  if (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    irc_iof_shd.g_old_rec.attribute15;
  end if;
  if (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    irc_iof_shd.g_old_rec.attribute16;
  end if;
  if (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    irc_iof_shd.g_old_rec.attribute17;
  end if;
  if (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    irc_iof_shd.g_old_rec.attribute18;
  end if;
  if (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    irc_iof_shd.g_old_rec.attribute19;
  end if;
  if (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    irc_iof_shd.g_old_rec.attribute20;
  end if;
  if (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    irc_iof_shd.g_old_rec.attribute21;
  end if;
  if (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    irc_iof_shd.g_old_rec.attribute22;
  end if;
  if (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    irc_iof_shd.g_old_rec.attribute23;
  end if;
  if (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    irc_iof_shd.g_old_rec.attribute24;
  end if;
  if (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    irc_iof_shd.g_old_rec.attribute25;
  end if;
  if (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    irc_iof_shd.g_old_rec.attribute26;
  end if;
  if (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    irc_iof_shd.g_old_rec.attribute27;
  end if;
  if (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    irc_iof_shd.g_old_rec.attribute28;
  end if;
  if (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    irc_iof_shd.g_old_rec.attribute29;
  end if;
  if (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    irc_iof_shd.g_old_rec.attribute30;
  end if;
  --
end convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_iof_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  --
  -- we must lock the row which we need to update.
  --
  irc_iof_shd.lck
    (p_rec.offer_id
    ,p_rec.object_version_number
    );
  --
  -- 1. during an update system defaults are used to determine if
  --    arguments have been defaulted or not. we must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. call the supporting update validate operations.
  --
  convert_defs(p_rec);
  irc_iof_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- call the supporting pre-update operation
  --
  irc_iof_upd.pre_update(p_rec);
  --
  -- update the row.
  --
  irc_iof_upd.update_dml(p_rec);
  --
  -- call the supporting post-update operation
  --
  irc_iof_upd.post_update
     (p_effective_date
     ,p_rec
     );
  --
  -- call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
end upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
procedure upd
  (p_effective_date               in     date
  ,p_offer_id                     in     number
  ,p_object_version_number        in out nocopy number
  ,p_offer_version                out nocopy number
  ,p_latest_offer                 in     varchar2  default hr_api.g_varchar2
  ,p_applicant_assignment_id      in     number    default hr_api.g_number
  ,p_offer_assignment_id          in     number    default hr_api.g_number
  ,p_offer_status                 in     varchar2  default hr_api.g_varchar2
  ,p_discretionary_job_title      in     varchar2  default hr_api.g_varchar2
  ,p_offer_extended_method        in     varchar2  default hr_api.g_varchar2
  ,p_respondent_id                in     number    default hr_api.g_number
  ,p_expiry_date                  in     date      default hr_api.g_date
  ,p_proposed_start_date          in     date      default hr_api.g_date
  ,p_offer_letter_tracking_code   in     varchar2  default hr_api.g_varchar2
  ,p_offer_postal_service         in     varchar2  default hr_api.g_varchar2
  ,p_offer_shipping_date          in     date      default hr_api.g_date
  ,p_address_id                   in     number    default hr_api.g_number
  ,p_template_id                  in     number    default hr_api.g_number
  ,p_offer_letter_file_type       in     varchar2  default hr_api.g_varchar2
  ,p_offer_letter_file_name       in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   irc_iof_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  --
  -- call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  irc_iof_shd.convert_args
  (p_offer_id
  ,hr_api.g_number -- offer_version
  ,p_latest_offer
  ,p_offer_status
  ,p_discretionary_job_title
  ,p_offer_extended_method
  ,p_respondent_id
  ,p_expiry_date
  ,p_proposed_start_date
  ,p_offer_letter_tracking_code
  ,p_offer_postal_service
  ,p_offer_shipping_date
  ,hr_api.g_number -- vacancy_id
  ,p_applicant_assignment_id
  ,p_offer_assignment_id
  ,p_address_id
  ,p_template_id
  ,p_offer_letter_file_type
  ,p_offer_letter_file_name
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_attribute21
  ,p_attribute22
  ,p_attribute23
  ,p_attribute24
  ,p_attribute25
  ,p_attribute26
  ,p_attribute27
  ,p_attribute28
  ,p_attribute29
  ,p_attribute30
  ,p_object_version_number
  );
  --
  -- having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  irc_iof_upd.upd
     (p_effective_date
     ,l_rec
     );
  --
  p_object_version_number := l_rec.object_version_number;
  p_offer_version  := l_rec.offer_version;
  --
  hr_utility.set_location(' leaving:'||l_proc, 10);
end upd;
--
end irc_iof_upd;

/
