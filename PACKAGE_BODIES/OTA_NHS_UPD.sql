--------------------------------------------------------
--  DDL for Package Body OTA_NHS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_NHS_UPD" as
/* $Header: otnhsrhi.pkb 120.1 2005/09/30 05:00:04 ssur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_nhs_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ota_nhs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ota_nhs_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_notrng_histories Row
  --
  update ota_notrng_histories
  set
  nota_history_id                   = p_rec.nota_history_id,
  person_id                         = p_rec.person_id,
  contact_id                        = p_rec.contact_id,
  trng_title                        = p_rec.trng_title,
  provider                          = p_rec.provider,
  type                              = p_rec.type,
  centre                            = p_rec.centre,
  completion_date                   = p_rec.completion_date,
  award                             = p_rec.award,
  rating                            = p_rec.rating,
  duration                          = p_rec.duration,
  duration_units                    = p_rec.duration_units,
  activity_version_id               = p_rec.activity_version_id,
  status                            = p_rec.status,
  verified_by_id                    = p_rec.verified_by_id,
  nth_information_category          = p_rec.nth_information_category,
  nth_information1                  = p_rec.nth_information1,
  nth_information2                  = p_rec.nth_information2,
  nth_information3                  = p_rec.nth_information3,
  nth_information4                  = p_rec.nth_information4,
  nth_information5                  = p_rec.nth_information5,
  nth_information6                  = p_rec.nth_information6,
  nth_information7                  = p_rec.nth_information7,
  nth_information8                  = p_rec.nth_information8,
  nth_information9                  = p_rec.nth_information9,
  nth_information10                 = p_rec.nth_information10,
  nth_information11                 = p_rec.nth_information11,
  nth_information12                 = p_rec.nth_information12,
  nth_information13                 = p_rec.nth_information13,
  nth_information15                 = p_rec.nth_information15,
  nth_information16                 = p_rec.nth_information16,
  nth_information17                 = p_rec.nth_information17,
  nth_information18                 = p_rec.nth_information18,
  nth_information19                 = p_rec.nth_information19,
  nth_information20                 = p_rec.nth_information20,
  org_id                            = p_rec.org_id,
  object_version_number             = p_rec.object_version_number,
  business_group_id                 = p_rec.business_group_id,
  nth_information14                 = p_rec.nth_information14,
  customer_id            = p_rec.customer_id,
  organization_id             = p_rec.organization_id
  where nota_history_id = p_rec.nota_history_id;
  --
  ota_nhs_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_nhs_shd.g_api_dml := false;   -- Unset the api dml status
    ota_nhs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_nhs_shd.g_api_dml := false;   -- Unset the api dml status
    ota_nhs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_nhs_shd.g_api_dml := false;   -- Unset the api dml status
    ota_nhs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_nhs_shd.g_api_dml := false;   -- Unset the api dml status
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
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
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
Procedure pre_update(p_rec in ota_nhs_shd.g_rec_type) is
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
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
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
Procedure post_update(p_effective_date in date,
            p_rec in ota_nhs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  begin
    --
    ota_nhs_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_nota_history_id
      => p_rec.nota_history_id
      ,p_person_id
      => p_rec.person_id
      ,p_contact_id
      => p_rec.contact_id
      ,p_trng_title
      => p_rec.trng_title
      ,p_provider
      => p_rec.provider
      ,p_type
      => p_rec.type
      ,p_centre
      => p_rec.centre
      ,p_completion_date
      => p_rec.completion_date
      ,p_award
      => p_rec.award
      ,p_rating
      => p_rec.rating
      ,p_duration
      => p_rec.duration
      ,p_duration_units
      => p_rec.duration_units
      ,p_activity_version_id
      => p_rec.activity_version_id
      ,p_status
      => p_rec.status
      ,p_verified_by_id
      => p_rec.verified_by_id
      ,p_nth_information_category
      => p_rec.nth_information_category
      ,p_nth_information1
      => p_rec.nth_information1
      ,p_nth_information2
      => p_rec.nth_information2
      ,p_nth_information3
      => p_rec.nth_information3
      ,p_nth_information4
      => p_rec.nth_information4
      ,p_nth_information5
      => p_rec.nth_information5
      ,p_nth_information6
      => p_rec.nth_information6
      ,p_nth_information7
      => p_rec.nth_information7
      ,p_nth_information8
      => p_rec.nth_information8
      ,p_nth_information9
      => p_rec.nth_information9
      ,p_nth_information10
      => p_rec.nth_information10
      ,p_nth_information11
      => p_rec.nth_information11
      ,p_nth_information12
      => p_rec.nth_information12
      ,p_nth_information13
      => p_rec.nth_information13
      ,p_nth_information15
      => p_rec.nth_information15
      ,p_nth_information16
      => p_rec.nth_information16
      ,p_nth_information17
      => p_rec.nth_information17
      ,p_nth_information18
      => p_rec.nth_information18
      ,p_nth_information19
      => p_rec.nth_information19
      ,p_nth_information20
      => p_rec.nth_information20
   ,p_org_id
      => p_rec.org_id
      ,p_object_version_number
      => p_rec.object_version_number
   ,p_business_group_id
      => p_rec.business_group_id
      ,p_nth_information14
      => p_rec.nth_information14
   ,p_customer_id
      => p_rec.customer_id
      ,p_organization_id
      => p_rec.organization_id
      ,p_person_id_o
      => ota_nhs_shd.g_old_rec.person_id
      ,p_contact_id_o
      => ota_nhs_shd.g_old_rec.contact_id
      ,p_trng_title_o
      => ota_nhs_shd.g_old_rec.trng_title
      ,p_provider_o
      => ota_nhs_shd.g_old_rec.provider
      ,p_type_o
      => ota_nhs_shd.g_old_rec.type
      ,p_centre_o
      => ota_nhs_shd.g_old_rec.centre
      ,p_completion_date_o
      => ota_nhs_shd.g_old_rec.completion_date
      ,p_award_o
      => ota_nhs_shd.g_old_rec.award
      ,p_rating_o
      => ota_nhs_shd.g_old_rec.rating
      ,p_duration_o
      => ota_nhs_shd.g_old_rec.duration
      ,p_duration_units_o
      => ota_nhs_shd.g_old_rec.duration_units
      ,p_activity_version_id_o
      => ota_nhs_shd.g_old_rec.activity_version_id
      ,p_status_o
      => ota_nhs_shd.g_old_rec.status
      ,p_verified_by_id_o
      => ota_nhs_shd.g_old_rec.verified_by_id
      ,p_nth_information_category_o
      => ota_nhs_shd.g_old_rec.nth_information_category
      ,p_nth_information1_o
      => ota_nhs_shd.g_old_rec.nth_information1
      ,p_nth_information2_o
      => ota_nhs_shd.g_old_rec.nth_information2
      ,p_nth_information3_o
      => ota_nhs_shd.g_old_rec.nth_information3
      ,p_nth_information4_o
      => ota_nhs_shd.g_old_rec.nth_information4
      ,p_nth_information5_o
      => ota_nhs_shd.g_old_rec.nth_information5
      ,p_nth_information6_o
      => ota_nhs_shd.g_old_rec.nth_information6
      ,p_nth_information7_o
      => ota_nhs_shd.g_old_rec.nth_information7
      ,p_nth_information8_o
      => ota_nhs_shd.g_old_rec.nth_information8
      ,p_nth_information9_o
      => ota_nhs_shd.g_old_rec.nth_information9
      ,p_nth_information10_o
      => ota_nhs_shd.g_old_rec.nth_information10
      ,p_nth_information11_o
      => ota_nhs_shd.g_old_rec.nth_information11
      ,p_nth_information12_o
      => ota_nhs_shd.g_old_rec.nth_information12
      ,p_nth_information13_o
      => ota_nhs_shd.g_old_rec.nth_information13
      ,p_nth_information15_o
      => ota_nhs_shd.g_old_rec.nth_information15
      ,p_nth_information16_o
      => ota_nhs_shd.g_old_rec.nth_information16
      ,p_nth_information17_o
      => ota_nhs_shd.g_old_rec.nth_information17
      ,p_nth_information18_o
      => ota_nhs_shd.g_old_rec.nth_information18
      ,p_nth_information19_o
      => ota_nhs_shd.g_old_rec.nth_information19
      ,p_nth_information20_o
      => ota_nhs_shd.g_old_rec.nth_information20
   ,p_org_id_o
      => ota_nhs_shd.g_old_rec.org_id
      ,p_object_version_number_o
      => ota_nhs_shd.g_old_rec.object_version_number
   ,p_business_group_id_o
      => ota_nhs_shd.g_old_rec.business_group_id
      ,p_nth_information14_o
      => ota_nhs_shd.g_old_rec.nth_information14
   ,p_customer_id_o
      => ota_nhs_shd.g_old_rec.customer_id
      ,p_organization_id_o
      => ota_nhs_shd.g_old_rec.organization_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_NOTRNG_HISTORIES'
        ,p_hook_type   => 'AU');
      --
  end;



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
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion



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
Procedure convert_defs(p_rec in out nocopy ota_nhs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ota_nhs_shd.g_old_rec.person_id;
  End If;
  If (p_rec.contact_id = hr_api.g_number) then
    p_rec.contact_id :=
    ota_nhs_shd.g_old_rec.contact_id;
  End If;
  If (p_rec.trng_title = hr_api.g_varchar2) then
    p_rec.trng_title :=
    ota_nhs_shd.g_old_rec.trng_title;
  End If;
  If (p_rec.provider = hr_api.g_varchar2) then
    p_rec.provider :=
    ota_nhs_shd.g_old_rec.provider;
  End If;
  If (p_rec.type = hr_api.g_varchar2) then
    p_rec.type :=
    ota_nhs_shd.g_old_rec.type;
  End If;
  If (p_rec.centre = hr_api.g_varchar2) then
    p_rec.centre :=
    ota_nhs_shd.g_old_rec.centre;
  End If;
  If (p_rec.completion_date = hr_api.g_date) then
    p_rec.completion_date :=
    ota_nhs_shd.g_old_rec.completion_date;
  End If;
  If (p_rec.award = hr_api.g_varchar2) then
    p_rec.award :=
    ota_nhs_shd.g_old_rec.award;
  End If;
  If (p_rec.rating = hr_api.g_varchar2) then
    p_rec.rating :=
    ota_nhs_shd.g_old_rec.rating;
  End If;
  If (p_rec.duration = hr_api.g_number) then
    p_rec.duration :=
    ota_nhs_shd.g_old_rec.duration;
  End If;
  If (p_rec.duration_units = hr_api.g_varchar2) then
    p_rec.duration_units :=
    ota_nhs_shd.g_old_rec.duration_units;
  End If;
  If (p_rec.activity_version_id = hr_api.g_number) then
    p_rec.activity_version_id :=
    ota_nhs_shd.g_old_rec.activity_version_id;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    ota_nhs_shd.g_old_rec.status;
  End If;
  If (p_rec.verified_by_id = hr_api.g_number) then
    p_rec.verified_by_id :=
    ota_nhs_shd.g_old_rec.verified_by_id;
  End If;
  If (p_rec.nth_information_category = hr_api.g_varchar2) then
    p_rec.nth_information_category :=
    ota_nhs_shd.g_old_rec.nth_information_category;
  End If;
  If (p_rec.nth_information1 = hr_api.g_varchar2) then
    p_rec.nth_information1 :=
    ota_nhs_shd.g_old_rec.nth_information1;
  End If;
  If (p_rec.nth_information2 = hr_api.g_varchar2) then
    p_rec.nth_information2 :=
    ota_nhs_shd.g_old_rec.nth_information2;
  End If;
  If (p_rec.nth_information3 = hr_api.g_varchar2) then
    p_rec.nth_information3 :=
    ota_nhs_shd.g_old_rec.nth_information3;
  End If;
  If (p_rec.nth_information4 = hr_api.g_varchar2) then
    p_rec.nth_information4 :=
    ota_nhs_shd.g_old_rec.nth_information4;
  End If;
  If (p_rec.nth_information5 = hr_api.g_varchar2) then
    p_rec.nth_information5 :=
    ota_nhs_shd.g_old_rec.nth_information5;
  End If;
  If (p_rec.nth_information6 = hr_api.g_varchar2) then
    p_rec.nth_information6 :=
    ota_nhs_shd.g_old_rec.nth_information6;
  End If;
  If (p_rec.nth_information7 = hr_api.g_varchar2) then
    p_rec.nth_information7 :=
    ota_nhs_shd.g_old_rec.nth_information7;
  End If;
  If (p_rec.nth_information8 = hr_api.g_varchar2) then
    p_rec.nth_information8 :=
    ota_nhs_shd.g_old_rec.nth_information8;
  End If;
  If (p_rec.nth_information9 = hr_api.g_varchar2) then
    p_rec.nth_information9 :=
    ota_nhs_shd.g_old_rec.nth_information9;
  End If;
  If (p_rec.nth_information10 = hr_api.g_varchar2) then
    p_rec.nth_information10 :=
    ota_nhs_shd.g_old_rec.nth_information10;
  End If;
  If (p_rec.nth_information11 = hr_api.g_varchar2) then
    p_rec.nth_information11 :=
    ota_nhs_shd.g_old_rec.nth_information11;
  End If;
  If (p_rec.nth_information12 = hr_api.g_varchar2) then
    p_rec.nth_information12 :=
    ota_nhs_shd.g_old_rec.nth_information12;
  End If;
  If (p_rec.nth_information13 = hr_api.g_varchar2) then
    p_rec.nth_information13 :=
    ota_nhs_shd.g_old_rec.nth_information13;
  End If;
  If (p_rec.nth_information15 = hr_api.g_varchar2) then
    p_rec.nth_information15 :=
    ota_nhs_shd.g_old_rec.nth_information15;
  End If;
  If (p_rec.nth_information16 = hr_api.g_varchar2) then
    p_rec.nth_information16 :=
    ota_nhs_shd.g_old_rec.nth_information16;
  End If;
  If (p_rec.nth_information17 = hr_api.g_varchar2) then
    p_rec.nth_information17 :=
    ota_nhs_shd.g_old_rec.nth_information17;
  End If;
  If (p_rec.nth_information18 = hr_api.g_varchar2) then
    p_rec.nth_information18 :=
    ota_nhs_shd.g_old_rec.nth_information18;
  End If;
  If (p_rec.nth_information19 = hr_api.g_varchar2) then
    p_rec.nth_information19 :=
    ota_nhs_shd.g_old_rec.nth_information19;
  End If;
  If (p_rec.nth_information20 = hr_api.g_varchar2) then
    p_rec.nth_information20 :=
    ota_nhs_shd.g_old_rec.nth_information20;
  End If;
  If (p_rec.org_id = hr_api.g_number) then
    p_rec.org_id :=
    ota_nhs_shd.g_old_rec.org_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ota_nhs_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.nth_information14 = hr_api.g_varchar2) then
    p_rec.nth_information14 :=
    ota_nhs_shd.g_old_rec.nth_information14;
  End If;
  If (p_rec.customer_id = hr_api.g_number) then
    p_rec.customer_id :=
    ota_nhs_shd.g_old_rec.customer_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    ota_nhs_shd.g_old_rec.organization_id;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in  date ,
  p_rec        in out nocopy ota_nhs_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ota_nhs_shd.lck
   (
   p_rec.nota_history_id,
   p_rec.object_version_number
   );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);

ota_nhs_bus.update_validate(p_effective_date ,
                              p_rec);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --

  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --

  post_update(p_effective_date ,
              p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date ,
  p_nota_history_id              in number,
  p_person_id                    in number           default hr_api.g_number,
  p_contact_id                   in number           default hr_api.g_number,
  p_trng_title                   in varchar2         default hr_api.g_varchar2,
  p_provider                     in varchar2         default hr_api.g_varchar2,
  p_type                         in varchar2         default hr_api.g_varchar2,
  p_centre                       in varchar2         default hr_api.g_varchar2,
  p_completion_date              in date             default hr_api.g_date,
  p_award                        in varchar2         default hr_api.g_varchar2,
  p_rating                       in varchar2         default hr_api.g_varchar2,
  p_duration                     in number           default hr_api.g_number,
  p_duration_units               in varchar2         default hr_api.g_varchar2,
  p_activity_version_id          in number           default hr_api.g_number,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_verified_by_id               in number           default hr_api.g_number,
  p_nth_information_category     in varchar2         default hr_api.g_varchar2,
  p_nth_information1             in varchar2         default hr_api.g_varchar2,
  p_nth_information2             in varchar2         default hr_api.g_varchar2,
  p_nth_information3             in varchar2         default hr_api.g_varchar2,
  p_nth_information4             in varchar2         default hr_api.g_varchar2,
  p_nth_information5             in varchar2         default hr_api.g_varchar2,
  p_nth_information6             in varchar2         default hr_api.g_varchar2,
  p_nth_information7             in varchar2         default hr_api.g_varchar2,
  p_nth_information8             in varchar2         default hr_api.g_varchar2,
  p_nth_information9             in varchar2         default hr_api.g_varchar2,
  p_nth_information10            in varchar2         default hr_api.g_varchar2,
  p_nth_information11            in varchar2         default hr_api.g_varchar2,
  p_nth_information12            in varchar2         default hr_api.g_varchar2,
  p_nth_information13            in varchar2         default hr_api.g_varchar2,
  p_nth_information15            in varchar2         default hr_api.g_varchar2,
  p_nth_information16            in varchar2         default hr_api.g_varchar2,
  p_nth_information17            in varchar2         default hr_api.g_varchar2,
  p_nth_information18            in varchar2         default hr_api.g_varchar2,
  p_nth_information19            in varchar2         default hr_api.g_varchar2,
  p_nth_information20            in varchar2         default hr_api.g_varchar2,
  p_org_id                       in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_business_group_id            in number           default hr_api.g_number,
  p_nth_information14            in varchar2         default hr_api.g_varchar2,
  p_customer_id          in number       default hr_api.g_number,
  p_organization_id           in number        default hr_api.g_number
  ) is
--
  l_rec    ota_nhs_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_nhs_shd.convert_args
  (
  p_nota_history_id,
  p_person_id,
  p_contact_id,
  p_trng_title,
  p_provider,
  p_type,
  p_centre,
  p_completion_date,
  p_award,
  p_rating,
  p_duration,
  p_duration_units,
  p_activity_version_id,
  p_status,
  p_verified_by_id,
  p_nth_information_category,
  p_nth_information1,
  p_nth_information2,
  p_nth_information3,
  p_nth_information4,
  p_nth_information5,
  p_nth_information6,
  p_nth_information7,
  p_nth_information8,
  p_nth_information9,
  p_nth_information10,
  p_nth_information11,
  p_nth_information12,
  p_nth_information13,
  p_nth_information15,
  p_nth_information16,
  p_nth_information17,
  p_nth_information18,
  p_nth_information19,
  p_nth_information20,
  p_org_id,
  p_object_version_number,
  p_business_group_id,
  p_nth_information14,
  p_customer_id,
  p_organization_id
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(p_effective_date               ,
      l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ota_nhs_upd;

/
