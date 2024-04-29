--------------------------------------------------------
--  DDL for Package Body HR_LOC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOC_UPD" AS
/* $Header: hrlocrhi.pkb 120.7.12010000.2 2008/12/30 10:18:50 ktithy ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  hr_loc_upd.';  -- Global package name
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
PROCEDURE update_dml(p_rec IN OUT NOCOPY hr_loc_shd.g_rec_type) IS
--
  l_proc  VARCHAR2(72) := g_package||'update_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  hr_loc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the hr_locations_all Row
  --
  UPDATE hr_locations_all
  SET
  location_id                       = p_rec.location_id,
  entered_by                        = p_rec.entered_by,
  location_code                     = p_rec.location_code,
  timezone_code                     = p_rec.timezone_code,
  address_line_1                    = p_rec.address_line_1,
  address_line_2                    = p_rec.address_line_2,
  address_line_3                    = p_rec.address_line_3,
  bill_to_site_flag                 = p_rec.bill_to_site_flag,
  country                           = p_rec.country,
  description                       = p_rec.description,
  designated_receiver_id            = p_rec.designated_receiver_id,
  in_organization_flag              = p_rec.in_organization_flag,
  inactive_date                     = p_rec.inactive_date,
  inventory_organization_id         = p_rec.inventory_organization_id,
  office_site_flag                  = p_rec.office_site_flag,
  postal_code                       = p_rec.postal_code,
  receiving_site_flag               = p_rec.receiving_site_flag,
  region_1                          = p_rec.region_1,
  region_2                          = p_rec.region_2,
  region_3                          = p_rec.region_3,
  ship_to_location_id               = p_rec.ship_to_location_id,
  ship_to_site_flag                 = p_rec.ship_to_site_flag,
  derived_locale                    = p_rec.derived_locale,
  style                             = p_rec.style,
--  tax_name                          = p_rec.tax_name,
  telephone_number_1                = p_rec.telephone_number_1,
  telephone_number_2                = p_rec.telephone_number_2,
  telephone_number_3                = p_rec.telephone_number_3,
  town_or_city                      = p_rec.town_or_city,
  loc_information13                 = p_rec.loc_information13,
  loc_information14                 = p_rec.loc_information14,
  loc_information15                 = p_rec.loc_information15,
  loc_information16                 = p_rec.loc_information16,
  loc_information17                 = p_rec.loc_information17,
  loc_information18                 = p_rec.loc_information18,
  loc_information19                 = p_rec.loc_information19,
  loc_information20                 = p_rec.loc_information20,
  attribute_category                = p_rec.attribute_category,
  attribute1                        = p_rec.attribute1,
  attribute2                        = p_rec.attribute2,
  attribute3                        = p_rec.attribute3,
  attribute4                        = p_rec.attribute4,
  attribute5                        = p_rec.attribute5,
  attribute6                        = p_rec.attribute6,
  attribute7                        = p_rec.attribute7,
  attribute8                        = p_rec.attribute8,
  attribute9                        = p_rec.attribute9,
  attribute10                       = p_rec.attribute10,
  attribute11                       = p_rec.attribute11,
  attribute12                       = p_rec.attribute12,
  attribute13                       = p_rec.attribute13,
  attribute14                       = p_rec.attribute14,
  attribute15                       = p_rec.attribute15,
  attribute16                       = p_rec.attribute16,
  attribute17                       = p_rec.attribute17,
  attribute18                       = p_rec.attribute18,
  attribute19                       = p_rec.attribute19,
  attribute20                       = p_rec.attribute20,
  object_version_number             = p_rec.object_version_number,
  global_attribute_category         = p_rec.global_attribute_category,
  global_attribute1                 = p_rec.global_attribute1,
  global_attribute2                 = p_rec.global_attribute2,
  global_attribute3                 = p_rec.global_attribute3,
  global_attribute4                 = p_rec.global_attribute4,
  global_attribute5                 = p_rec.global_attribute5,
  global_attribute6                 = p_rec.global_attribute6,
  global_attribute7                 = p_rec.global_attribute7,
  global_attribute8                 = p_rec.global_attribute8,
  global_attribute9                 = p_rec.global_attribute9,
  global_attribute10                = p_rec.global_attribute10,
  global_attribute11                = p_rec.global_attribute11,
  global_attribute12                = p_rec.global_attribute12,
  global_attribute13                = p_rec.global_attribute13,
  global_attribute14                = p_rec.global_attribute14,
  global_attribute15                = p_rec.global_attribute15,
  global_attribute16                = p_rec.global_attribute16,
  global_attribute17                = p_rec.global_attribute17,
  global_attribute18                = p_rec.global_attribute18,
  global_attribute19                = p_rec.global_attribute19,
  global_attribute20                = p_rec.global_attribute20,
  legal_address_flag                = p_rec.legal_address_flag,
  tp_header_id                      = p_rec.tp_header_id,
  ece_tp_location_code              = p_rec.ece_tp_location_code,
  geometry                          = p_rec.geometry
  WHERE location_id = p_rec.location_id;
  --
  hr_loc_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
EXCEPTION
  WHEN hr_api.check_integrity_violated THEN
    -- A check constraint has been violated
    hr_loc_shd.g_api_dml := false;   -- Unset the api dml status
    hr_loc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(sqlerrm));
  WHEN hr_api.parent_integrity_violated THEN
    -- Parent integrity has been violated
    hr_loc_shd.g_api_dml := false;   -- Unset the api dml status
    hr_loc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(sqlerrm));
  WHEN hr_api.unique_integrity_violated THEN
    -- Unique integrity has been violated
    hr_loc_shd.g_api_dml := false;   -- Unset the api dml status
    hr_loc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(sqlerrm));
  WHEN OTHERS THEN
    hr_loc_shd.g_api_dml := false;   -- Unset the api dml status
    RAISE;
END update_dml;
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
PROCEDURE pre_update(p_rec            IN OUT NOCOPY hr_loc_shd.g_rec_type
                    ) IS
--
  l_proc  VARCHAR2(72) := g_package||'pre_update';
--
  l_number_table dbms_describe.number_table;
  l_varchar_table dbms_describe.varchar2_table;
  l_package_exists boolean;
  l_package_name varchar2(30);
BEGIN

--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_loc_shd.derive_locale(p_rec);


  if((nvl(p_rec.address_line_1,' ') = nvl(hr_loc_shd.g_old_rec.address_line_1,' '))
  	 and (nvl(p_rec.address_line_2,' ') = nvl(hr_loc_shd.g_old_rec.address_line_2,' '))
	 and (nvl(p_rec.address_line_3,' ') = nvl(hr_loc_shd.g_old_rec.address_line_3,' '))
     and (nvl(p_rec.town_or_city,' ') = nvl(hr_loc_shd.g_old_rec.town_or_city,' '))
	 and (nvl(p_rec.region_1,' ') = nvl(hr_loc_shd.g_old_rec.region_1,' '))
	 and (nvl(p_rec.region_2,' ') = nvl(hr_loc_shd.g_old_rec.region_2,' '))
     and (nvl(p_rec.region_3,' ') = nvl(hr_loc_shd.g_old_rec.region_3,' '))
	 and (nvl(p_rec.postal_code,' ') = nvl(hr_loc_shd.g_old_rec.postal_code,' '))
	 and (nvl(p_rec.country,' ') = nvl(hr_loc_shd.g_old_rec.country,' ')) )	  then

     hr_utility.set_location('Not calling address2geometry:'||l_proc, 8);

  else
  --
  --
  -- Enhancement added for Location Searching
  --
  if((fnd_profile.value('IRC_INSTALLED_FLAG') in ('Y','D')) and
      (fnd_profile.value('IRC_GEOCODE_HOST')is not null)
     )then
  p_rec.geometry := Irc_location_utility.address2geometry
     (address_line1       => p_rec.address_line_1
     ,address_line2       => p_rec.address_line_2
     ,address_line3       => p_rec.address_line_3
     ,address_line4       => p_rec.town_or_city
     ,address_line5       => p_rec.region_1
     ,address_line6       => p_rec.region_2
     ,address_line7       => p_rec.region_3
     ,address_line8       => p_rec.postal_code
     ,country             => p_rec.country
     );
  end if;

  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
END pre_update;
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
PROCEDURE post_update(p_rec IN hr_loc_shd.g_rec_type,
            p_effective_date IN DATE) IS
--
  l_proc  VARCHAR2(72) := g_package||'post_update';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
    -- Start of API User Hook for the after update hook
    --
    hr_loc_rku.after_update
   (p_effective_date                => p_effective_date
        ,p_location_id                   => p_rec.location_id
   ,p_location_code                 => p_rec.location_code
        ,p_timezone_code                 => p_rec.timezone_code
   ,p_address_line_1                => p_rec.address_line_1
   ,p_address_line_2                => p_rec.address_line_2
   ,p_address_line_3                => p_rec.address_line_3
   ,p_bill_to_site_flag             => p_rec.bill_to_site_flag
   ,p_country                       => p_rec.country
   ,p_description                   => p_rec.description
        ,p_designated_receiver_id        => p_rec.designated_receiver_id
   ,p_in_organization_flag          => p_rec.in_organization_flag
   ,p_inactive_date                 => p_rec.inactive_date
   ,p_inventory_organization_id     => p_rec.inventory_organization_id
   ,p_office_site_flag              => p_rec.office_site_flag
   ,p_postal_code                   => p_rec.postal_code
   ,p_receiving_site_flag           => p_rec.receiving_site_flag
   ,p_region_1                      => p_rec.region_1
   ,p_region_2                      => p_rec.region_2
   ,p_region_3                      => p_rec.region_3
   ,p_ship_to_location_id           => p_rec.ship_to_location_id
   ,p_ship_to_site_flag             => p_rec.ship_to_site_flag
   ,p_tax_name                      => p_rec.tax_name
   ,p_telephone_number_1            => p_rec.telephone_number_1
   ,p_telephone_number_2            => p_rec.telephone_number_2
   ,p_telephone_number_3            => p_rec.telephone_number_3
   ,p_town_or_city                  => p_rec.town_or_city
        ,p_loc_information13             => p_rec.loc_information13
        ,p_loc_information14             => p_rec.loc_information14
        ,p_loc_information15             => p_rec.loc_information15
        ,p_loc_information16             => p_rec.loc_information16
   ,p_loc_information17             => p_rec.loc_information17
   ,p_loc_information18             => p_rec.loc_information18
   ,p_loc_information19             => p_rec.loc_information19
   ,p_loc_information20             => p_rec.loc_information20
   ,p_attribute_category            => p_rec.attribute_category
   ,p_attribute1                    => p_rec.attribute1
   ,p_attribute2                    => p_rec.attribute2
   ,p_attribute3                    => p_rec.attribute3
   ,p_attribute4                    => p_rec.attribute4
   ,p_attribute5                    => p_rec.attribute5
   ,p_attribute6                    => p_rec.attribute6
   ,p_attribute7                    => p_rec.attribute7
   ,p_attribute8                    => p_rec.attribute8
   ,p_attribute9                    => p_rec.attribute9
   ,p_attribute10                   => p_rec.attribute10
   ,p_attribute11                   => p_rec.attribute11
   ,p_attribute12                   => p_rec.attribute12
   ,p_attribute13                   => p_rec.attribute13
   ,p_attribute14                   => p_rec.attribute14
   ,p_attribute15                   => p_rec.attribute15
   ,p_attribute16                   => p_rec.attribute16
   ,p_attribute17                   => p_rec.attribute17
   ,p_attribute18                   => p_rec.attribute18
   ,p_attribute19                   => p_rec.attribute19
   ,p_attribute20                   => p_rec.attribute20
   ,p_global_attribute_category     => p_rec.global_attribute_category
   ,p_global_attribute1             => p_rec.global_attribute1
   ,p_global_attribute2             => p_rec.global_attribute2
   ,p_global_attribute3             => p_rec.global_attribute3
   ,p_global_attribute4             => p_rec.global_attribute4
   ,p_global_attribute5             => p_rec.global_attribute5
   ,p_global_attribute6             => p_rec.global_attribute6
   ,p_global_attribute7             => p_rec.global_attribute7
   ,p_global_attribute8             => p_rec.global_attribute8
   ,p_global_attribute9             => p_rec.global_attribute9
   ,p_global_attribute10            => p_rec.global_attribute10
   ,p_global_attribute11            => p_rec.global_attribute11
   ,p_global_attribute12            => p_rec.global_attribute12
   ,p_global_attribute13            => p_rec.global_attribute13
   ,p_global_attribute14            => p_rec.global_attribute14
   ,p_global_attribute15            => p_rec.global_attribute15
   ,p_global_attribute16            => p_rec.global_attribute16
   ,p_global_attribute17            => p_rec.global_attribute17
   ,p_global_attribute18            => p_rec.global_attribute18
   ,p_global_attribute19            => p_rec.global_attribute19
        ,p_global_attribute20            => p_rec.global_attribute20
        ,p_legal_address_flag            => p_rec.legal_address_flag
   ,p_tp_header_id                  => p_rec.tp_header_id
   ,p_ece_tp_location_code          => p_rec.ece_tp_location_code
   ,p_object_version_number         => p_rec.object_version_number
        ,p_business_group_id             => p_rec.business_group_id
--
   ,p_location_code_o                 => hr_loc_shd.g_old_rec.location_code
   ,p_address_line_1_o                => hr_loc_shd.g_old_rec.address_line_1
   ,p_address_line_2_o                => hr_loc_shd.g_old_rec.address_line_2
   ,p_address_line_3_o                => hr_loc_shd.g_old_rec.address_line_3
   ,p_bill_to_site_flag_o             => hr_loc_shd.g_old_rec.bill_to_site_flag
   ,p_country_o                       => hr_loc_shd.g_old_rec.country
   ,p_description_o                   => hr_loc_shd.g_old_rec.description
   ,p_designated_receiver_id_o        => hr_loc_shd.g_old_rec.designated_receiver_id
   ,p_in_organization_flag_o          => hr_loc_shd.g_old_rec.in_organization_flag
   ,p_inactive_date_o                 => hr_loc_shd.g_old_rec.inactive_date
   ,p_inventory_organization_id_o     => hr_loc_shd.g_old_rec.inventory_organization_id
   ,p_office_site_flag_o              => hr_loc_shd.g_old_rec.office_site_flag
   ,p_postal_code_o                   => hr_loc_shd.g_old_rec.postal_code
   ,p_receiving_site_flag_o           => hr_loc_shd.g_old_rec.receiving_site_flag
   ,p_region_1_o                      => hr_loc_shd.g_old_rec.region_1
   ,p_region_2_o                      => hr_loc_shd.g_old_rec.region_2
   ,p_region_3_o                      => hr_loc_shd.g_old_rec.region_3
   ,p_ship_to_location_id_o           => hr_loc_shd.g_old_rec.ship_to_location_id
   ,p_ship_to_site_flag_o             => hr_loc_shd.g_old_rec.ship_to_site_flag
   ,p_style_o                         => hr_loc_shd.g_old_rec.style
   ,p_tax_name_o                      => hr_loc_shd.g_old_rec.tax_name
   ,p_telephone_number_1_o            => hr_loc_shd.g_old_rec.telephone_number_1
   ,p_telephone_number_2_o            => hr_loc_shd.g_old_rec.telephone_number_2
   ,p_telephone_number_3_o            => hr_loc_shd.g_old_rec.telephone_number_3
   ,p_town_or_city_o                  => hr_loc_shd.g_old_rec.town_or_city
        ,p_loc_information13_o             => hr_loc_shd.g_old_rec.loc_information13
        ,p_loc_information14_o             => hr_loc_shd.g_old_rec.loc_information14
        ,p_loc_information15_o             => hr_loc_shd.g_old_rec.loc_information15
        ,p_loc_information16_o             => hr_loc_shd.g_old_rec.loc_information16
   ,p_loc_information17_o             => hr_loc_shd.g_old_rec.loc_information17
   ,p_loc_information18_o             => hr_loc_shd.g_old_rec.loc_information18
   ,p_loc_information19_o             => hr_loc_shd.g_old_rec.loc_information19
   ,p_loc_information20_o             => hr_loc_shd.g_old_rec.loc_information20
   ,p_attribute_category_o            => hr_loc_shd.g_old_rec.attribute_category
   ,p_attribute1_o                    => hr_loc_shd.g_old_rec.attribute1
   ,p_attribute2_o                    => hr_loc_shd.g_old_rec.attribute2
   ,p_attribute3_o                    => hr_loc_shd.g_old_rec.attribute3
   ,p_attribute4_o                    => hr_loc_shd.g_old_rec.attribute4
   ,p_attribute5_o                    => hr_loc_shd.g_old_rec.attribute5
   ,p_attribute6_o                    => hr_loc_shd.g_old_rec.attribute6
   ,p_attribute7_o                    => hr_loc_shd.g_old_rec.attribute7
   ,p_attribute8_o                    => hr_loc_shd.g_old_rec.attribute8
   ,p_attribute9_o                    => hr_loc_shd.g_old_rec.attribute9
   ,p_attribute10_o                   => hr_loc_shd.g_old_rec.attribute10
   ,p_attribute11_o                   => hr_loc_shd.g_old_rec.attribute11
   ,p_attribute12_o                   => hr_loc_shd.g_old_rec.attribute12
   ,p_attribute13_o                   => hr_loc_shd.g_old_rec.attribute13
   ,p_attribute14_o                   => hr_loc_shd.g_old_rec.attribute14
   ,p_attribute15_o                   => hr_loc_shd.g_old_rec.attribute15
   ,p_attribute16_o                   => hr_loc_shd.g_old_rec.attribute16
   ,p_attribute17_o                   => hr_loc_shd.g_old_rec.attribute17
   ,p_attribute18_o                   => hr_loc_shd.g_old_rec.attribute18
   ,p_attribute19_o                   => hr_loc_shd.g_old_rec.attribute19
   ,p_attribute20_o                   => hr_loc_shd.g_old_rec.attribute20
   ,p_global_attribute_category_o     => hr_loc_shd.g_old_rec.global_attribute_category
   ,p_global_attribute1_o             => hr_loc_shd.g_old_rec.global_attribute1
   ,p_global_attribute2_o             => hr_loc_shd.g_old_rec.global_attribute2
   ,p_global_attribute3_o             => hr_loc_shd.g_old_rec.global_attribute3
   ,p_global_attribute4_o             => hr_loc_shd.g_old_rec.global_attribute4
   ,p_global_attribute5_o             => hr_loc_shd.g_old_rec.global_attribute5
   ,p_global_attribute6_o             => hr_loc_shd.g_old_rec.global_attribute6
   ,p_global_attribute7_o             => hr_loc_shd.g_old_rec.global_attribute7
   ,p_global_attribute8_o             => hr_loc_shd.g_old_rec.global_attribute8
   ,p_global_attribute9_o             => hr_loc_shd.g_old_rec.global_attribute9
   ,p_global_attribute10_o            => hr_loc_shd.g_old_rec.global_attribute10
   ,p_global_attribute11_o            => hr_loc_shd.g_old_rec.global_attribute11
   ,p_global_attribute12_o            => hr_loc_shd.g_old_rec.global_attribute12
   ,p_global_attribute13_o            => hr_loc_shd.g_old_rec.global_attribute13
   ,p_global_attribute14_o            => hr_loc_shd.g_old_rec.global_attribute14
   ,p_global_attribute15_o            => hr_loc_shd.g_old_rec.global_attribute15
   ,p_global_attribute16_o            => hr_loc_shd.g_old_rec.global_attribute16
   ,p_global_attribute17_o            => hr_loc_shd.g_old_rec.global_attribute17
   ,p_global_attribute18_o            => hr_loc_shd.g_old_rec.global_attribute18
   ,p_global_attribute19_o            => hr_loc_shd.g_old_rec.global_attribute19
        ,p_global_attribute20_o            => hr_loc_shd.g_old_rec.global_attribute20
        ,p_legal_address_flag_o            => hr_loc_shd.g_old_rec.legal_address_flag
   ,p_tp_header_id_o                  => hr_loc_shd.g_old_rec.tp_header_id
        ,p_ece_tp_location_code_o          => hr_loc_shd.g_old_rec.ece_tp_location_code
   ,p_object_version_number_o         => hr_loc_shd.g_old_rec.object_version_number
        ,p_business_group_id_o             => hr_loc_shd.g_old_rec.business_group_id
     );
   EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_LOCATIONS_ALL'
        ,p_hook_type   => 'AU'
        );
    --
    -- End of API User Hook for the after_update hook
    --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END post_update;
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
PROCEDURE convert_defs(p_rec IN OUT NOCOPY hr_loc_shd.g_rec_type) IS
--
  l_proc  VARCHAR2(72) := g_package||'convert_defs';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  IF (p_rec.entered_by = hr_api.g_number) THEN
    p_rec.entered_by :=
    hr_loc_shd.g_old_rec.entered_by;
  END IF;
  IF (p_rec.location_code = hr_api.g_varchar2) THEN
    p_rec.location_code :=
    hr_loc_shd.g_old_rec.location_code;
  END IF;
  IF (p_rec.address_line_1 = hr_api.g_varchar2) THEN
    p_rec.address_line_1 :=
    hr_loc_shd.g_old_rec.address_line_1;
  END IF;
  IF (p_rec.address_line_2 = hr_api.g_varchar2) THEN
    p_rec.address_line_2 :=
    hr_loc_shd.g_old_rec.address_line_2;
  END IF;
  IF (p_rec.address_line_3 = hr_api.g_varchar2) THEN
    p_rec.address_line_3 :=
    hr_loc_shd.g_old_rec.address_line_3;
  END IF;
  IF (p_rec.bill_to_site_flag = hr_api.g_varchar2) THEN
    p_rec.bill_to_site_flag :=
    hr_loc_shd.g_old_rec.bill_to_site_flag;
  END IF;
  IF (p_rec.country = hr_api.g_varchar2) THEN
    p_rec.country :=
    hr_loc_shd.g_old_rec.country;
  END IF;
  IF (p_rec.description = hr_api.g_varchar2) THEN
    p_rec.description :=
    hr_loc_shd.g_old_rec.description;
  END IF;
  IF (p_rec.designated_receiver_id = hr_api.g_number) THEN
    p_rec.designated_receiver_id :=
    hr_loc_shd.g_old_rec.designated_receiver_id;
  END IF;
  IF (p_rec.in_organization_flag = hr_api.g_varchar2) THEN
    p_rec.in_organization_flag :=
    hr_loc_shd.g_old_rec.in_organization_flag;
  END IF;
  IF (p_rec.inactive_date = hr_api.g_date) THEN
    p_rec.inactive_date :=
    hr_loc_shd.g_old_rec.inactive_date;
  END IF;
  IF (p_rec.inventory_organization_id = hr_api.g_number) THEN
    p_rec.inventory_organization_id :=
    hr_loc_shd.g_old_rec.inventory_organization_id;
  END IF;
  IF (p_rec.office_site_flag = hr_api.g_varchar2) THEN
    p_rec.office_site_flag :=
    hr_loc_shd.g_old_rec.office_site_flag;
  END IF;
  IF (p_rec.postal_code = hr_api.g_varchar2) THEN
    p_rec.postal_code :=
    hr_loc_shd.g_old_rec.postal_code;
  END IF;
  IF (p_rec.receiving_site_flag = hr_api.g_varchar2) THEN
    p_rec.receiving_site_flag :=
    hr_loc_shd.g_old_rec.receiving_site_flag;
  END IF;
  IF (p_rec.region_1 = hr_api.g_varchar2) THEN
    p_rec.region_1 :=
    hr_loc_shd.g_old_rec.region_1;
  END IF;
  IF (p_rec.region_2 = hr_api.g_varchar2) THEN
    p_rec.region_2 :=
    hr_loc_shd.g_old_rec.region_2;
  END IF;
  IF (p_rec.region_3 = hr_api.g_varchar2) THEN
    p_rec.region_3 :=
    hr_loc_shd.g_old_rec.region_3;
  END IF;
  IF (p_rec.ship_to_location_id = hr_api.g_number) THEN
    p_rec.ship_to_location_id :=
    hr_loc_shd.g_old_rec.ship_to_location_id;
  END IF;
  IF (p_rec.ship_to_site_flag = hr_api.g_varchar2) THEN
    p_rec.ship_to_site_flag :=
    hr_loc_shd.g_old_rec.ship_to_site_flag;
  END IF;
  IF (p_rec.style = hr_api.g_varchar2) THEN
    p_rec.style :=
    hr_loc_shd.g_old_rec.style;
  END IF;
  IF (p_rec.tax_name = hr_api.g_varchar2) THEN
    p_rec.tax_name :=
    hr_loc_shd.g_old_rec.tax_name;
  END IF;
  IF (p_rec.telephone_number_1 = hr_api.g_varchar2) THEN
    p_rec.telephone_number_1 :=
    hr_loc_shd.g_old_rec.telephone_number_1;
  END IF;
  IF (p_rec.telephone_number_2 = hr_api.g_varchar2) THEN
    p_rec.telephone_number_2 :=
    hr_loc_shd.g_old_rec.telephone_number_2;
  END IF;
  IF (p_rec.telephone_number_3 = hr_api.g_varchar2) THEN
    p_rec.telephone_number_3 :=
    hr_loc_shd.g_old_rec.telephone_number_3;
  END IF;
  IF (p_rec.town_or_city = hr_api.g_varchar2) THEN
    p_rec.town_or_city :=
    hr_loc_shd.g_old_rec.town_or_city;
  END IF;
  IF (p_rec.loc_information13 = hr_api.g_varchar2) THEN
    p_rec.loc_information13 :=
    hr_loc_shd.g_old_rec.loc_information13;
  END IF;
  IF (p_rec.loc_information14 = hr_api.g_varchar2) THEN
    p_rec.loc_information14 :=
    hr_loc_shd.g_old_rec.loc_information14;
  END IF;
  IF (p_rec.loc_information15 = hr_api.g_varchar2) THEN
    p_rec.loc_information15 :=
    hr_loc_shd.g_old_rec.loc_information15;
  END IF;
  IF (p_rec.loc_information16 = hr_api.g_varchar2) THEN
    p_rec.loc_information16 :=
    hr_loc_shd.g_old_rec.loc_information16;
  END IF;
  IF (p_rec.loc_information17 = hr_api.g_varchar2) THEN
    p_rec.loc_information17 :=
    hr_loc_shd.g_old_rec.loc_information17;
  END IF;
  IF (p_rec.loc_information18 = hr_api.g_varchar2) THEN
    p_rec.loc_information18 :=
    hr_loc_shd.g_old_rec.loc_information18;
  END IF;
  IF (p_rec.loc_information19 = hr_api.g_varchar2) THEN
    p_rec.loc_information19 :=
    hr_loc_shd.g_old_rec.loc_information19;
  END IF;
  IF (p_rec.loc_information20 = hr_api.g_varchar2) THEN
    p_rec.loc_information20 :=
    hr_loc_shd.g_old_rec.loc_information20;
  END IF;
  IF (p_rec.attribute_category = hr_api.g_varchar2) THEN
    p_rec.attribute_category :=
    hr_loc_shd.g_old_rec.attribute_category;
  END IF;
  IF (p_rec.attribute1 = hr_api.g_varchar2) THEN
    p_rec.attribute1 :=
    hr_loc_shd.g_old_rec.attribute1;
  END IF;
  IF (p_rec.attribute2 = hr_api.g_varchar2) THEN
    p_rec.attribute2 :=
    hr_loc_shd.g_old_rec.attribute2;
  END IF;
  IF (p_rec.attribute3 = hr_api.g_varchar2) THEN
    p_rec.attribute3 :=
    hr_loc_shd.g_old_rec.attribute3;
  END IF;
  IF (p_rec.attribute4 = hr_api.g_varchar2) THEN
    p_rec.attribute4 :=
    hr_loc_shd.g_old_rec.attribute4;
  END IF;
  IF (p_rec.attribute5 = hr_api.g_varchar2) THEN
    p_rec.attribute5 :=
    hr_loc_shd.g_old_rec.attribute5;
  END IF;
  IF (p_rec.attribute6 = hr_api.g_varchar2) THEN
    p_rec.attribute6 :=
    hr_loc_shd.g_old_rec.attribute6;
  END IF;
  IF (p_rec.attribute7 = hr_api.g_varchar2) THEN
    p_rec.attribute7 :=
    hr_loc_shd.g_old_rec.attribute7;
  END IF;
  IF (p_rec.attribute8 = hr_api.g_varchar2) THEN
    p_rec.attribute8 :=
    hr_loc_shd.g_old_rec.attribute8;
  END IF;
  IF (p_rec.attribute9 = hr_api.g_varchar2) THEN
    p_rec.attribute9 :=
    hr_loc_shd.g_old_rec.attribute9;
  END IF;
  IF (p_rec.attribute10 = hr_api.g_varchar2) THEN
    p_rec.attribute10 :=
    hr_loc_shd.g_old_rec.attribute10;
  END IF;
  IF (p_rec.attribute11 = hr_api.g_varchar2) THEN
    p_rec.attribute11 :=
    hr_loc_shd.g_old_rec.attribute11;
  END IF;
  IF (p_rec.attribute12 = hr_api.g_varchar2) THEN
    p_rec.attribute12 :=
    hr_loc_shd.g_old_rec.attribute12;
  END IF;
  IF (p_rec.attribute13 = hr_api.g_varchar2) THEN
    p_rec.attribute13 :=
    hr_loc_shd.g_old_rec.attribute13;
  END IF;
  IF (p_rec.attribute14 = hr_api.g_varchar2) THEN
    p_rec.attribute14 :=
    hr_loc_shd.g_old_rec.attribute14;
  END IF;
  IF (p_rec.attribute15 = hr_api.g_varchar2) THEN
    p_rec.attribute15 :=
    hr_loc_shd.g_old_rec.attribute15;
  END IF;
  IF (p_rec.attribute16 = hr_api.g_varchar2) THEN
    p_rec.attribute16 :=
    hr_loc_shd.g_old_rec.attribute16;
  END IF;
  IF (p_rec.attribute17 = hr_api.g_varchar2) THEN
    p_rec.attribute17 :=
    hr_loc_shd.g_old_rec.attribute17;
  END IF;
  IF (p_rec.attribute18 = hr_api.g_varchar2) THEN
    p_rec.attribute18 :=
    hr_loc_shd.g_old_rec.attribute18;
  END IF;
  IF (p_rec.attribute19 = hr_api.g_varchar2) THEN
    p_rec.attribute19 :=
    hr_loc_shd.g_old_rec.attribute19;
  END IF;
  IF (p_rec.attribute20 = hr_api.g_varchar2) THEN
    p_rec.attribute20 :=
    hr_loc_shd.g_old_rec.attribute20;
  END IF;
  IF (p_rec.global_attribute_category = hr_api.g_varchar2) THEN
    p_rec.global_attribute_category :=
    hr_loc_shd.g_old_rec.global_attribute_category;
  END IF;
  IF (p_rec.global_attribute1 = hr_api.g_varchar2) THEN
    p_rec.global_attribute1 :=
    hr_loc_shd.g_old_rec.global_attribute1;
  END IF;
  IF (p_rec.global_attribute2 = hr_api.g_varchar2) THEN
    p_rec.global_attribute2 :=
    hr_loc_shd.g_old_rec.global_attribute2;
  END IF;
  IF (p_rec.global_attribute3 = hr_api.g_varchar2) THEN
    p_rec.global_attribute3 :=
    hr_loc_shd.g_old_rec.global_attribute3;
  END IF;
  IF (p_rec.global_attribute4 = hr_api.g_varchar2) THEN
    p_rec.global_attribute4 :=
    hr_loc_shd.g_old_rec.global_attribute4;
  END IF;
  IF (p_rec.global_attribute5 = hr_api.g_varchar2) THEN
    p_rec.global_attribute5 :=
    hr_loc_shd.g_old_rec.global_attribute5;
  END IF;
  IF (p_rec.global_attribute6 = hr_api.g_varchar2) THEN
    p_rec.global_attribute6 :=
    hr_loc_shd.g_old_rec.global_attribute6;
  END IF;
  IF (p_rec.global_attribute7 = hr_api.g_varchar2) THEN
    p_rec.global_attribute7 :=
    hr_loc_shd.g_old_rec.global_attribute7;
  END IF;
  IF (p_rec.global_attribute8 = hr_api.g_varchar2) THEN
    p_rec.global_attribute8 :=
    hr_loc_shd.g_old_rec.global_attribute8;
  END IF;
  IF (p_rec.global_attribute9 = hr_api.g_varchar2) THEN
    p_rec.global_attribute9 :=
    hr_loc_shd.g_old_rec.global_attribute9;
  END IF;
  IF (p_rec.global_attribute10 = hr_api.g_varchar2) THEN
    p_rec.global_attribute10 :=
    hr_loc_shd.g_old_rec.global_attribute10;
  END IF;
  IF (p_rec.global_attribute11 = hr_api.g_varchar2) THEN
    p_rec.global_attribute11 :=
    hr_loc_shd.g_old_rec.global_attribute11;
  END IF;
  IF (p_rec.global_attribute12 = hr_api.g_varchar2) THEN
    p_rec.global_attribute12 :=
    hr_loc_shd.g_old_rec.global_attribute12;
  END IF;
  IF (p_rec.global_attribute13 = hr_api.g_varchar2) THEN
    p_rec.global_attribute13 :=
    hr_loc_shd.g_old_rec.global_attribute13;
  END IF;
  IF (p_rec.global_attribute14 = hr_api.g_varchar2) THEN
    p_rec.global_attribute14 :=
    hr_loc_shd.g_old_rec.global_attribute14;
  END IF;
  IF (p_rec.global_attribute15 = hr_api.g_varchar2) THEN
    p_rec.global_attribute15 :=
    hr_loc_shd.g_old_rec.global_attribute15;
  END IF;
  IF (p_rec.global_attribute16 = hr_api.g_varchar2) THEN
    p_rec.global_attribute16 :=
    hr_loc_shd.g_old_rec.global_attribute16;
  END IF;
  IF (p_rec.global_attribute17 = hr_api.g_varchar2) THEN
    p_rec.global_attribute17 :=
    hr_loc_shd.g_old_rec.global_attribute17;
  END IF;
  IF (p_rec.global_attribute18 = hr_api.g_varchar2) THEN
    p_rec.global_attribute18 :=
    hr_loc_shd.g_old_rec.global_attribute18;
  END IF;
  IF (p_rec.global_attribute19 = hr_api.g_varchar2) THEN
    p_rec.global_attribute19 :=
    hr_loc_shd.g_old_rec.global_attribute19;
  END IF;
  IF (p_rec.global_attribute20 = hr_api.g_varchar2) THEN
    p_rec.global_attribute20 :=
    hr_loc_shd.g_old_rec.global_attribute20;
  END IF;
  IF (p_rec.legal_address_flag = hr_api.g_varchar2) THEN
    p_rec.legal_address_flag :=
    hr_loc_shd.g_old_rec.legal_address_flag;
  END IF;
  IF (p_rec.tp_header_id = hr_api.g_number) THEN
    p_rec.tp_header_id :=
    hr_loc_shd.g_old_rec.tp_header_id;
  END IF;
  IF (p_rec.ece_tp_location_code = hr_api.g_varchar2) THEN
    p_rec.ece_tp_location_code :=
    hr_loc_shd.g_old_rec.ece_tp_location_code;
  END IF;
  IF (p_rec.business_group_id = hr_api.g_number) THEN
    p_rec.business_group_id :=
    hr_loc_shd.g_old_rec.business_group_id;
  END IF;
  -- Fix 3286235
  IF (p_rec.timezone_code = hr_api.g_varchar2) THEN
    p_rec.timezone_code :=
    hr_loc_shd.g_old_rec.timezone_code;
  END IF;
  -- End Fix 3286235
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
END convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upd
  (
   p_rec               IN OUT NOCOPY hr_loc_shd.g_rec_type
  ,p_effective_date    IN DATE
  ,p_operating_unit_id IN NUMBER
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'upd';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  hr_loc_shd.lck
   (
   p_rec.location_id,
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
  --
  hr_loc_bus.update_validate(p_rec
                            ,p_effective_date
             ,p_operating_unit_id);
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
  post_update(p_rec,
              p_effective_date);
  --
END upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upd
  (
  p_effective_date               IN DATE,
  p_location_id                  IN NUMBER,
  p_object_version_number        IN OUT NOCOPY NUMBER,
  p_location_code                IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_timezone_code                IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_address_line_1               IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_address_line_2               IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_address_line_3               IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_bill_to_site_flag            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_country                      IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_description                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_designated_receiver_id       IN NUMBER           DEFAULT hr_api.g_number,
  p_in_organization_flag         IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_inactive_date                IN DATE             DEFAULT hr_api.g_date,
  p_operating_unit_id            IN NUMBER           DEFAULT NULL,
  p_inventory_organization_id    IN NUMBER           DEFAULT hr_api.g_number,
  p_office_site_flag             IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_postal_code                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_receiving_site_flag          IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_region_1                     IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_region_2                     IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_region_3                     IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_ship_to_location_id          IN NUMBER           DEFAULT hr_api.g_number,
  p_ship_to_site_flag            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_style                        IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_tax_name                     IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_telephone_number_1           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_telephone_number_2           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_telephone_number_3           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_town_or_city                 IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information13            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information14            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information15            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information16            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information17            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information18            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information19            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_loc_information20            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute_category           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute1                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute2                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute3                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute4                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute5                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute6                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute7                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute8                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute9                   IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute10                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute11                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute12                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute13                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute14                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute15                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute16                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute17                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute18                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute19                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_attribute20                  IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute_category    IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute1            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute2            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute3            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute4            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute5            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute6            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute7            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute8            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute9            IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute10           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute11           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute12           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute13           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute14           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute15           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute16           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute17           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute18           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute19           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_global_attribute20           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_legal_address_flag           IN VARCHAR2         DEFAULT hr_api.g_varchar2,
  p_tp_header_id                 IN NUMBER           DEFAULT hr_api.g_number,
  p_ece_tp_location_code         IN VARCHAR2         DEFAULT hr_api.g_varchar2
  ) IS
--
  l_rec    hr_loc_shd.g_rec_type;
  l_proc  VARCHAR2(72) := g_package||'upd';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_loc_shd.convert_args
  (
  p_location_id,
  p_location_code,
  p_timezone_code,
  p_address_line_1,
  p_address_line_2,
  p_address_line_3,
  p_bill_to_site_flag,
  p_country,
  p_description,
  p_designated_receiver_id,
  p_in_organization_flag,
  p_inactive_date,
  p_inventory_organization_id,
  p_office_site_flag,
  p_postal_code,
  p_receiving_site_flag,
  p_region_1,
  p_region_2,
  p_region_3,
  p_ship_to_location_id,
  p_ship_to_site_flag,
  p_style,
  p_tax_name,
  p_telephone_number_1,
  p_telephone_number_2,
  p_telephone_number_3,
  p_town_or_city,
  p_loc_information13,
  p_loc_information14,
  p_loc_information15,
  p_loc_information16,
  p_loc_information17,
  p_loc_information18,
  p_loc_information19,
  p_loc_information20,
  p_attribute_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20,
  p_global_attribute_category,
  p_global_attribute1,
  p_global_attribute2,
  p_global_attribute3,
  p_global_attribute4,
  p_global_attribute5,
  p_global_attribute6,
  p_global_attribute7,
  p_global_attribute8,
  p_global_attribute9,
  p_global_attribute10,
  p_global_attribute11,
  p_global_attribute12,
  p_global_attribute13,
  p_global_attribute14,
  p_global_attribute15,
  p_global_attribute16,
  p_global_attribute17,
  p_global_attribute18,
  p_global_attribute19,
  p_global_attribute20,
  p_legal_address_flag,
  p_tp_header_id,
  p_ece_tp_location_code,
  p_object_version_number,
  hr_api.g_number                -- business_group_id is not updateable
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  upd(l_rec
    ,p_effective_date
    ,p_operating_unit_id);

  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
END upd;
--
END hr_loc_upd;

/
