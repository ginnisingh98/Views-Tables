--------------------------------------------------------
--  DDL for Package Body PER_ADD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ADD_UPD" as
/* $Header: peaddrhi.pkb 120.1.12010000.6 2009/04/13 08:33:06 sgundoju ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_add_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Arguments:
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
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy per_add_shd.g_rec_type) is
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
hr_utility.set_location(l_proc, 6);
  per_add_shd.g_api_dml := true;  -- Set the api dml status
  --
hr_utility.set_location(l_proc, 7);
  -- Update the per_addresses Row
  --
  update per_addresses
  set
  address_id                        = p_rec.address_id,
  business_group_id                 = p_rec.business_group_id,
  person_id                         = p_rec.person_id,
-- 70.2 change a start.
  date_from                         = p_rec.date_from,
-- 70.2 change a end.
  derived_locale                    = p_rec.derived_locale,
  address_line1                     = p_rec.address_line1,
  address_line2                     = p_rec.address_line2,
  address_line3                     = p_rec.address_line3,
  address_type                      = p_rec.address_type,
  comments                          = p_rec.comments,
  country                           = p_rec.country,
  date_to                           = p_rec.date_to,
  postal_code                       = p_rec.postal_code,
  region_1                          = p_rec.region_1,
  region_2                          = p_rec.region_2,
  region_3                          = p_rec.region_3,
  telephone_number_1                = p_rec.telephone_number_1,
  telephone_number_2                = p_rec.telephone_number_2,
  telephone_number_3                = p_rec.telephone_number_3,
  town_or_city                      = p_rec.town_or_city,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  addr_attribute_category           = p_rec.addr_attribute_category,
  addr_attribute1                   = p_rec.addr_attribute1,
  addr_attribute2                   = p_rec.addr_attribute2,
  addr_attribute3                   = p_rec.addr_attribute3,
  addr_attribute4                   = p_rec.addr_attribute4,
  addr_attribute5                   = p_rec.addr_attribute5,
  addr_attribute6                   = p_rec.addr_attribute6,
  addr_attribute7                   = p_rec.addr_attribute7,
  addr_attribute8                   = p_rec.addr_attribute8,
  addr_attribute9                   = p_rec.addr_attribute9,
  addr_attribute10                  = p_rec.addr_attribute10,
  addr_attribute11                  = p_rec.addr_attribute11,
  addr_attribute12                  = p_rec.addr_attribute12,
  addr_attribute13                  = p_rec.addr_attribute13,
  addr_attribute14                  = p_rec.addr_attribute14,
  addr_attribute15                  = p_rec.addr_attribute15,
  addr_attribute16                  = p_rec.addr_attribute16,
  addr_attribute17                  = p_rec.addr_attribute17,
  addr_attribute18                  = p_rec.addr_attribute18,
  addr_attribute19                  = p_rec.addr_attribute19,
  addr_attribute20                  = p_rec.addr_attribute20,
  add_information13                 = p_rec.add_information13,
  add_information14                 = p_rec.add_information14,
  add_information15                 = p_rec.add_information15,
  add_information16                 = p_rec.add_information16,
  add_information17                 = p_rec.add_information17,
  add_information18                 = p_rec.add_information18,
  add_information19                 = p_rec.add_information19,
  add_information20                 = p_rec.add_information20,
  party_id                          = p_rec.party_id,
  object_version_number             = p_rec.object_version_number,
  geometry                          = p_rec.geometry,
-- Start of fix for Bug #2431588
  primary_flag			    = p_rec.primary_flag,
-- End of fix for Bug #2431588
  style                             = p_rec.style
  where address_id = p_rec.address_id;
  --
hr_utility.set_location(l_proc, 8);
  per_add_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_add_shd.g_api_dml := false;   -- Unset the api dml status
    per_add_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_add_shd.g_api_dml := false;   -- Unset the api dml status
    per_add_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_add_shd.g_api_dml := false;   -- Unset the api dml status
    per_add_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_add_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in out nocopy per_add_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- WWBUG 2203479.
  -- Removed for irecruitment
  -- Bug# 2747048. Uncommented the code as it is required now.
  per_add_shd.derive_locale(p_rec);
  --
  -- Enhancement added for Location Searching
  --
  if( (fnd_profile.value('IRC_INSTALLED_FLAG') in ('Y','D') )and
      (fnd_profile.value('IRC_GEOCODE_HOST')is not null)
    ) then
    p_rec.geometry := Irc_location_utility.address2geometry
      (address_line1       => p_rec.address_line1
      ,address_line2       => p_rec.address_line2
      ,address_line3       => p_rec.address_line3
      ,address_line4       => p_rec.town_or_city
      ,address_line5       => p_rec.region_1
      ,address_line6       => p_rec.region_2
      ,address_line7       => p_rec.region_3
      ,address_line8       => p_rec.postal_code
      ,country             => p_rec.country
      );
  end if;
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
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_rec                in per_add_shd.g_rec_type
  ,p_effective_date     in date
  ,p_prflagval_override in boolean
  ,p_validate_county  in boolean
  )
is

  --
  l_proc  varchar2(72) := g_package||'post_update';
  --
  --
  -- Fix for WWBUG 1408379
  --
  l_old               ben_add_ler.g_add_ler_rec;
  l_new               ben_add_ler.g_add_ler_rec;
  --
  -- End of Fix for WWBUG 1408379
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_update.
  begin
    per_add_rku.after_update
      (p_address_id                   => p_rec.address_id
      ,p_business_group_id            => p_rec.business_group_id
      ,p_person_id                    => p_rec.person_id
      ,p_date_from                    => p_rec.date_from
      ,p_address_line1                => p_rec.address_line1
      ,p_address_line2                => p_rec.address_line2
      ,p_address_line3                => p_rec.address_line3
      ,p_address_type                 => p_rec.address_type
      ,p_comments                     => p_rec.comments
      ,p_country                      => p_rec.country
      ,p_date_to                      => p_rec.date_to
      ,p_postal_code                  => p_rec.postal_code
      ,p_region_1                     => p_rec.region_1
      ,p_region_2                     => p_rec.region_2
      ,p_region_3                     => p_rec.region_3
      ,p_telephone_number_1           => p_rec.telephone_number_1
      ,p_telephone_number_2           => p_rec.telephone_number_2
      ,p_telephone_number_3           => p_rec.telephone_number_3
      ,p_town_or_city                 => p_rec.town_or_city
      ,p_request_id                   => p_rec.request_id
      ,p_program_application_id       => p_rec.program_application_id
      ,p_program_id                   => p_rec.program_id
      ,p_program_update_date          => p_rec.program_update_date
      ,p_addr_attribute_category      => p_rec.addr_attribute_category
      ,p_addr_attribute1              => p_rec.addr_attribute1
      ,p_addr_attribute2              => p_rec.addr_attribute2
      ,p_addr_attribute3              => p_rec.addr_attribute3
      ,p_addr_attribute4              => p_rec.addr_attribute4
      ,p_addr_attribute5              => p_rec.addr_attribute5
      ,p_addr_attribute6              => p_rec.addr_attribute6
      ,p_addr_attribute7              => p_rec.addr_attribute7
      ,p_addr_attribute8              => p_rec.addr_attribute8
      ,p_addr_attribute9              => p_rec.addr_attribute9
      ,p_addr_attribute10             => p_rec.addr_attribute10
      ,p_addr_attribute11             => p_rec.addr_attribute11
      ,p_addr_attribute12             => p_rec.addr_attribute12
      ,p_addr_attribute13             => p_rec.addr_attribute13
      ,p_addr_attribute14             => p_rec.addr_attribute14
      ,p_addr_attribute15             => p_rec.addr_attribute15
      ,p_addr_attribute16             => p_rec.addr_attribute16
      ,p_addr_attribute17             => p_rec.addr_attribute17
      ,p_addr_attribute18             => p_rec.addr_attribute18
      ,p_addr_attribute19             => p_rec.addr_attribute19
      ,p_addr_attribute20             => p_rec.addr_attribute20
      ,p_add_information13            => p_rec.add_information13
      ,p_add_information14            => p_rec.add_information14
      ,p_add_information15            => p_rec.add_information15
      ,p_add_information16            => p_rec.add_information16
      ,p_add_information17            => p_rec.add_information17
      ,p_add_information18            => p_rec.add_information18
      ,p_add_information19            => p_rec.add_information19
      ,p_add_information20            => p_rec.add_information20
      ,p_object_version_number        => p_rec.object_version_number
      ,p_effective_date               => p_effective_date
      ,p_prflagval_override           => p_prflagval_override
      ,p_validate_county              => p_validate_county
      ,p_business_group_id_o
          => per_add_shd.g_old_rec.business_group_id
      ,p_person_id_o
          => per_add_shd.g_old_rec.person_id
      ,p_date_from_o
          => per_add_shd.g_old_rec.date_from
      ,p_primary_flag_o
          => per_add_shd.g_old_rec.primary_flag
      ,p_style_o
          => per_add_shd.g_old_rec.style
      ,p_address_line1_o
          => per_add_shd.g_old_rec.address_line1
      ,p_address_line2_o
          => per_add_shd.g_old_rec.address_line2
      ,p_address_line3_o
          => per_add_shd.g_old_rec.address_line3
      ,p_address_type_o
          => per_add_shd.g_old_rec.address_type
      ,p_comments_o
          => per_add_shd.g_old_rec.comments
      ,p_country_o
          => per_add_shd.g_old_rec.country
      ,p_date_to_o
          => per_add_shd.g_old_rec.date_to
      ,p_postal_code_o
          => per_add_shd.g_old_rec.postal_code
      ,p_region_1_o
          => per_add_shd.g_old_rec.region_1
      ,p_region_2_o
          => per_add_shd.g_old_rec.region_2
      ,p_region_3_o
          => per_add_shd.g_old_rec.region_3
      ,p_telephone_number_1_o
          => per_add_shd.g_old_rec.telephone_number_1
      ,p_telephone_number_2_o
          => per_add_shd.g_old_rec.telephone_number_2
      ,p_telephone_number_3_o
          => per_add_shd.g_old_rec.telephone_number_3
      ,p_town_or_city_o
          => per_add_shd.g_old_rec.town_or_city
      ,p_request_id_o
          => per_add_shd.g_old_rec.request_id
      ,p_program_application_id_o
          => per_add_shd.g_old_rec.program_application_id
      ,p_program_id_o
          => per_add_shd.g_old_rec.program_id
      ,p_program_update_date_o
          => per_add_shd.g_old_rec.program_update_date
      ,p_addr_attribute_category_o
          => per_add_shd.g_old_rec.addr_attribute_category
      ,p_addr_attribute1_o
          => per_add_shd.g_old_rec.addr_attribute1
      ,p_addr_attribute2_o
          => per_add_shd.g_old_rec.addr_attribute2
      ,p_addr_attribute3_o
          => per_add_shd.g_old_rec.addr_attribute3
      ,p_addr_attribute4_o
          => per_add_shd.g_old_rec.addr_attribute4
      ,p_addr_attribute5_o
          => per_add_shd.g_old_rec.addr_attribute5
      ,p_addr_attribute6_o
          => per_add_shd.g_old_rec.addr_attribute6
      ,p_addr_attribute7_o
          => per_add_shd.g_old_rec.addr_attribute7
      ,p_addr_attribute8_o
          => per_add_shd.g_old_rec.addr_attribute8
      ,p_addr_attribute9_o
          => per_add_shd.g_old_rec.addr_attribute9
      ,p_addr_attribute10_o
          => per_add_shd.g_old_rec.addr_attribute10
      ,p_addr_attribute11_o
          => per_add_shd.g_old_rec.addr_attribute11
      ,p_addr_attribute12_o
          => per_add_shd.g_old_rec.addr_attribute12
      ,p_addr_attribute13_o
          => per_add_shd.g_old_rec.addr_attribute13
      ,p_addr_attribute14_o
          => per_add_shd.g_old_rec.addr_attribute14
      ,p_addr_attribute15_o
          => per_add_shd.g_old_rec.addr_attribute15
      ,p_addr_attribute16_o
          => per_add_shd.g_old_rec.addr_attribute16
      ,p_addr_attribute17_o
          => per_add_shd.g_old_rec.addr_attribute17
      ,p_addr_attribute18_o
          => per_add_shd.g_old_rec.addr_attribute18
      ,p_addr_attribute19_o
          => per_add_shd.g_old_rec.addr_attribute19
      ,p_addr_attribute20_o
          => per_add_shd.g_old_rec.addr_attribute20
      ,p_add_information13_o
          => per_add_shd.g_old_rec.add_information13
      ,p_add_information14_o
          => per_add_shd.g_old_rec.add_information14
      ,p_add_information15_o
          => per_add_shd.g_old_rec.add_information15
      ,p_add_information16_o
          => per_add_shd.g_old_rec.add_information16
      ,p_add_information17_o
          => per_add_shd.g_old_rec.add_information17
      ,p_add_information18_o
          => per_add_shd.g_old_rec.add_information18
      ,p_add_information19_o
          => per_add_shd.g_old_rec.add_information19
      ,p_add_information20_o
          => per_add_shd.g_old_rec.add_information20
      ,p_object_version_number_o
          => per_add_shd.g_old_rec.object_version_number
      ,p_party_id_o                             -- HR/TCA merge
          => per_add_shd.g_old_rec.party_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ADDRESSES'
        ,p_hook_type   => 'AU'
        );
  end;
  --
  -- Fix for WWBUG 1408379
  --
  l_old.person_id := per_add_shd.g_old_rec.person_id;
  l_old.business_group_id := per_add_shd.g_old_rec.business_group_id;
  l_old.date_from := per_add_shd.g_old_rec.date_from;
  l_old.date_to := per_add_shd.g_old_rec.date_to;
  l_old.primary_flag := per_add_shd.g_old_rec.primary_flag;
  l_old.postal_code := per_add_shd.g_old_rec.postal_code;
  l_old.region_2 := per_add_shd.g_old_rec.region_2;
  l_old.address_type := per_add_shd.g_old_rec.address_type;
  l_old.address_id := per_add_shd.g_old_rec.address_id;
  l_new.person_id := p_rec.person_id;
  l_new.business_group_id := p_rec.business_group_id;
  l_new.date_from := p_rec.date_from;
  l_new.date_to := p_rec.date_to;
  l_new.primary_flag := p_rec.primary_flag;
  l_new.postal_code := p_rec.postal_code;
  l_new.region_2 := p_rec.region_2;
  l_new.address_type := p_rec.address_type;
  l_new.address_id := p_rec.address_id;
  --
  ben_add_ler.ler_chk(p_old            => l_old,
                      p_new            => l_new,
                      p_effective_date => l_new.date_from);
  --
  -- End of Fix for WWBUG 1408379
  --
  --
  -- End of API User Hook for post_update.
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
--   The Convert_Defs function has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_defs(p_rec in out nocopy per_add_shd.g_rec_type)
         Return per_add_shd.g_rec_type is
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
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_add_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    per_add_shd.g_old_rec.person_id;
  End If;
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    per_add_shd.g_old_rec.date_from;
  End If;
  If (p_rec.primary_flag = hr_api.g_varchar2) then
    p_rec.primary_flag :=
    per_add_shd.g_old_rec.primary_flag;
  End If;
  If (p_rec.style = hr_api.g_varchar2) then
    p_rec.style :=
    per_add_shd.g_old_rec.style;
  End If;
  If (p_rec.address_line1 = hr_api.g_varchar2) then
    p_rec.address_line1 :=
    per_add_shd.g_old_rec.address_line1;
  End If;
  If (p_rec.address_line2 = hr_api.g_varchar2) then
    p_rec.address_line2 :=
    per_add_shd.g_old_rec.address_line2;
  End If;
  If (p_rec.address_line3 = hr_api.g_varchar2) then
    p_rec.address_line3 :=
    per_add_shd.g_old_rec.address_line3;
  End If;
  If (p_rec.address_type = hr_api.g_varchar2) then
    p_rec.address_type :=
    per_add_shd.g_old_rec.address_type;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_add_shd.g_old_rec.comments;
  End If;
  If (p_rec.country = hr_api.g_varchar2) then
    p_rec.country :=
    per_add_shd.g_old_rec.country;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    per_add_shd.g_old_rec.date_to;
  End If;
  If (p_rec.postal_code = hr_api.g_varchar2) then
    p_rec.postal_code :=
    per_add_shd.g_old_rec.postal_code;
  End If;
  If (p_rec.region_1 = hr_api.g_varchar2) then
    p_rec.region_1 :=
    per_add_shd.g_old_rec.region_1;
  End If;
  If (p_rec.region_2 = hr_api.g_varchar2) then
    p_rec.region_2 :=
    per_add_shd.g_old_rec.region_2;
  End If;
  If (p_rec.region_3 = hr_api.g_varchar2) then
    p_rec.region_3 :=
    per_add_shd.g_old_rec.region_3;
  End If;
  If (p_rec.telephone_number_1 = hr_api.g_varchar2) then
    p_rec.telephone_number_1 :=
    per_add_shd.g_old_rec.telephone_number_1;
  End If;
  If (p_rec.telephone_number_2 = hr_api.g_varchar2) then
    p_rec.telephone_number_2 :=
    per_add_shd.g_old_rec.telephone_number_2;
  End If;
  If (p_rec.telephone_number_3 = hr_api.g_varchar2) then
    p_rec.telephone_number_3 :=
    per_add_shd.g_old_rec.telephone_number_3;
  End If;
  If (p_rec.town_or_city = hr_api.g_varchar2) then
    p_rec.town_or_city :=
    per_add_shd.g_old_rec.town_or_city;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    per_add_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    per_add_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    per_add_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    per_add_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.addr_attribute_category = hr_api.g_varchar2) then
    p_rec.addr_attribute_category :=
    per_add_shd.g_old_rec.addr_attribute_category;
  End If;
  If (p_rec.addr_attribute1 = hr_api.g_varchar2) then
    p_rec.addr_attribute1 :=
    per_add_shd.g_old_rec.addr_attribute1;
  End If;
  If (p_rec.addr_attribute2 = hr_api.g_varchar2) then
    p_rec.addr_attribute2 :=
    per_add_shd.g_old_rec.addr_attribute2;
  End If;
  If (p_rec.addr_attribute3 = hr_api.g_varchar2) then
    p_rec.addr_attribute3 :=
    per_add_shd.g_old_rec.addr_attribute3;
  End If;
  If (p_rec.addr_attribute4 = hr_api.g_varchar2) then
    p_rec.addr_attribute4 :=
    per_add_shd.g_old_rec.addr_attribute4;
  End If;
  If (p_rec.addr_attribute5 = hr_api.g_varchar2) then
    p_rec.addr_attribute5 :=
    per_add_shd.g_old_rec.addr_attribute5;
  End If;
  If (p_rec.addr_attribute6 = hr_api.g_varchar2) then
    p_rec.addr_attribute6 :=
    per_add_shd.g_old_rec.addr_attribute6;
  End If;
  If (p_rec.addr_attribute7 = hr_api.g_varchar2) then
    p_rec.addr_attribute7 :=
    per_add_shd.g_old_rec.addr_attribute7;
  End If;
  If (p_rec.addr_attribute8 = hr_api.g_varchar2) then
    p_rec.addr_attribute8 :=
    per_add_shd.g_old_rec.addr_attribute8;
  End If;
  If (p_rec.addr_attribute9 = hr_api.g_varchar2) then
    p_rec.addr_attribute9 :=
    per_add_shd.g_old_rec.addr_attribute9;
  End If;
  If (p_rec.addr_attribute10 = hr_api.g_varchar2) then
    p_rec.addr_attribute10 :=
    per_add_shd.g_old_rec.addr_attribute10;
  End If;
  If (p_rec.addr_attribute11 = hr_api.g_varchar2) then
    p_rec.addr_attribute11 :=
    per_add_shd.g_old_rec.addr_attribute11;
  End If;
  If (p_rec.addr_attribute12 = hr_api.g_varchar2) then
    p_rec.addr_attribute12 :=
    per_add_shd.g_old_rec.addr_attribute12;
  End If;
  If (p_rec.addr_attribute13 = hr_api.g_varchar2) then
    p_rec.addr_attribute13 :=
    per_add_shd.g_old_rec.addr_attribute13;
  End If;
  If (p_rec.addr_attribute14 = hr_api.g_varchar2) then
    p_rec.addr_attribute14 :=
    per_add_shd.g_old_rec.addr_attribute14;
  End If;
  If (p_rec.addr_attribute15 = hr_api.g_varchar2) then
    p_rec.addr_attribute15 :=
    per_add_shd.g_old_rec.addr_attribute15;
  End If;
  If (p_rec.addr_attribute16 = hr_api.g_varchar2) then
    p_rec.addr_attribute16 :=
    per_add_shd.g_old_rec.addr_attribute16;
  End If;
  If (p_rec.addr_attribute17 = hr_api.g_varchar2) then
    p_rec.addr_attribute17 :=
    per_add_shd.g_old_rec.addr_attribute17;
  End If;
  If (p_rec.addr_attribute18 = hr_api.g_varchar2) then
    p_rec.addr_attribute18 :=
    per_add_shd.g_old_rec.addr_attribute18;
  End If;
  If (p_rec.addr_attribute19 = hr_api.g_varchar2) then
    p_rec.addr_attribute19 :=
    per_add_shd.g_old_rec.addr_attribute19;
  End If;
  If (p_rec.addr_attribute20 = hr_api.g_varchar2) then
    p_rec.addr_attribute20 :=
    per_add_shd.g_old_rec.addr_attribute20;
  End If;
  If (p_rec.add_information13 = hr_api.g_varchar2) then
    p_rec.add_information13 :=
    per_add_shd.g_old_rec.add_information13;
  End If;
  If (p_rec.add_information14 = hr_api.g_varchar2) then
    p_rec.add_information14 :=
    per_add_shd.g_old_rec.add_information14;
  End If;
  If (p_rec.add_information15 = hr_api.g_varchar2) then
    p_rec.add_information15 :=
    per_add_shd.g_old_rec.add_information15;
  End If;
  If (p_rec.add_information16 = hr_api.g_varchar2) then
    p_rec.add_information16 :=
    per_add_shd.g_old_rec.add_information16;
  End If;
  If (p_rec.add_information17 = hr_api.g_varchar2) then
    p_rec.add_information17 :=
    per_add_shd.g_old_rec.add_information17;
  End If;
  If (p_rec.add_information18 = hr_api.g_varchar2) then
    p_rec.add_information18 :=
    per_add_shd.g_old_rec.add_information18;
  End If;
  If (p_rec.add_information19 = hr_api.g_varchar2) then
    p_rec.add_information19 :=
    per_add_shd.g_old_rec.add_information19;
  End If;
  If (p_rec.add_information20 = hr_api.g_varchar2) then
    p_rec.add_information20 :=
    per_add_shd.g_old_rec.add_information20;
  End If;
  If (p_rec.party_id = hr_api.g_number) then   -- HR/TCA merge
    p_rec.party_id :=
    per_add_shd.g_old_rec.party_id;
  End If;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(p_rec);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                in out nocopy per_add_shd.g_rec_type
  ,p_validate           in     boolean default false
  ,p_effective_date     in     date
  ,p_prflagval_override in     boolean      default false
  ,p_validate_county    in     boolean      default true
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
  l_convert per_add_shd.g_rec_type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_per_add;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  per_add_shd.lck
	(
	p_rec.address_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  l_convert := convert_defs(p_rec);
  --
  per_add_bus.update_validate(l_convert
                             ,p_effective_date
                             ,p_prflagval_override
                             ,p_validate_county
                             );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
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
  post_update(p_rec
             ,p_effective_date
             ,p_prflagval_override
             ,p_validate_county
             );
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_per_add;
End upd;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< upd >-----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
   p_address_id               in     number
  ,p_business_group_id            in number           default hr_api.g_number
  ,p_person_id                    in number           default hr_api.g_number
-- 70.2 change a start.
  ,p_date_from                in     date             default hr_api.g_date
-- 70.2 change a end.
-- Start of fix for Bug #2431588
  ,p_primary_flag             in     varchar2         default hr_api.g_varchar2
-- End of fix for Bug #2431588
  ,p_address_line1            in     varchar2         default hr_api.g_varchar2
  ,p_address_line2            in     varchar2         default hr_api.g_varchar2
  ,p_address_line3            in     varchar2         default hr_api.g_varchar2
  ,p_address_type             in     varchar2         default hr_api.g_varchar2
  ,p_comments                 in     long             default hr_api.g_varchar2
  ,p_country                  in     varchar2         default hr_api.g_varchar2
  ,p_date_to                  in     date             default hr_api.g_date
  ,p_postal_code              in     varchar2         default hr_api.g_varchar2
  ,p_region_1                 in     varchar2         default hr_api.g_varchar2
  ,p_region_2                 in     varchar2         default hr_api.g_varchar2
  ,p_region_3                 in     varchar2         default hr_api.g_varchar2
  ,p_telephone_number_1       in     varchar2         default hr_api.g_varchar2
  ,p_telephone_number_2       in     varchar2         default hr_api.g_varchar2
  ,p_telephone_number_3       in     varchar2         default hr_api.g_varchar2
  ,p_town_or_city             in     varchar2         default hr_api.g_varchar2
  ,p_request_id               in     number           default hr_api.g_number
  ,p_program_application_id   in     number           default hr_api.g_number
  ,p_program_id               in     number           default hr_api.g_number
  ,p_program_update_date      in     date             default hr_api.g_date
  ,p_addr_attribute_category  in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute1          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute2          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute3          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute4          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute5          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute6          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute7          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute8          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute9          in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute10         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute11         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute12         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute13         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute14         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute15         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute16         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute17         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute18         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute19         in     varchar2         default hr_api.g_varchar2
  ,p_addr_attribute20         in     varchar2         default hr_api.g_varchar2
  ,p_add_information13        in     varchar2         default hr_api.g_varchar2
  ,p_add_information14        in     varchar2         default hr_api.g_varchar2
  ,p_add_information15        in     varchar2         default hr_api.g_varchar2
  ,p_add_information16        in     varchar2         default hr_api.g_varchar2
  ,p_add_information17        in     varchar2         default hr_api.g_varchar2
  ,p_add_information18        in     varchar2         default hr_api.g_varchar2
  ,p_add_information19        in     varchar2         default hr_api.g_varchar2
  ,p_add_information20        in     varchar2         default hr_api.g_varchar2
  ,p_object_version_number    in out nocopy number
  ,p_party_id                 in     number           default hr_api.g_number
  ,p_validate                 in     boolean      default false
  ,p_effective_date           in     date
  ,p_prflagval_override       in     boolean      default false
  ,p_validate_county          in     boolean      default true
  ,p_style                    in     varchar2         default hr_api.g_varchar2
  ) is
--
  l_rec	  per_add_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_add_shd.convert_args
  (
  p_address_id,
-- 70.2 change a start.
  p_business_group_id,
  p_person_id,
--  hr_api.g_number,
--  hr_api.g_number,
  p_date_from,
-- Start of fix for Bug #2431588
  p_primary_flag,
-- End of fix for Bug #2431588
  p_style,
-- 70.2 change a end.
  p_address_line1,
  p_address_line2,
  p_address_line3,
  p_address_type,
  p_comments,
  p_country,
  p_date_to,
  p_postal_code,
  p_region_1,
  p_region_2,
  p_region_3,
  p_telephone_number_1,
  p_telephone_number_2,
  p_telephone_number_3,
  p_town_or_city,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_addr_attribute_category,
  p_addr_attribute1,
  p_addr_attribute2,
  p_addr_attribute3,
  p_addr_attribute4,
  p_addr_attribute5,
  p_addr_attribute6,
  p_addr_attribute7,
  p_addr_attribute8,
  p_addr_attribute9,
  p_addr_attribute10,
  p_addr_attribute11,
  p_addr_attribute12,
  p_addr_attribute13,
  p_addr_attribute14,
  p_addr_attribute15,
  p_addr_attribute16,
  p_addr_attribute17,
  p_addr_attribute18,
  p_addr_attribute19,
  p_addr_attribute20,
  p_add_information13,
  p_add_information14,
  p_add_information15,
  p_add_information16,
  p_add_information17,
  p_add_information18,
  p_add_information19,
  p_add_information20,
  p_object_version_number,
  p_party_id  -- HR/TCA merge
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec
     ,p_validate
     ,p_effective_date
     ,p_prflagval_override
     ,p_validate_county
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_add_upd;

/
