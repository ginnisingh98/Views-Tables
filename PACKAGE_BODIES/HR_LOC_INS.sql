--------------------------------------------------------
--  DDL for Package Body HR_LOC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOC_INS" AS
/* $Header: hrlocrhi.pkb 120.7.12010000.2 2008/12/30 10:18:50 ktithy ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  hr_loc_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_location_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_location_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_loc_ins.g_location_id_i := p_location_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE insert_dml(p_rec IN OUT NOCOPY hr_loc_shd.g_rec_type) IS
--
  l_proc  VARCHAR2(72) := g_package||'insert_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  hr_loc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: hr_locations_all
  --
  INSERT INTO hr_locations_all
  (   location_id,
   entered_by,
   location_code,
        timezone_code,
   address_line_1,
   address_line_2,
   address_line_3,
   bill_to_site_flag,
   country,
   description,
   designated_receiver_id,
   in_organization_flag,
   inactive_date,
   inventory_organization_id,
   office_site_flag,
   postal_code,
   receiving_site_flag,
   region_1,
   region_2,
   region_3,
   ship_to_location_id,
   ship_to_site_flag,
        derived_locale,
   style,
 --  tax_name,
   telephone_number_1,
   telephone_number_2,
   telephone_number_3,
        town_or_city,
        loc_information13,
        loc_information14,
        loc_information15,
        loc_information16,
        loc_information17,
        loc_information18,
        loc_information19,
        loc_information20,
   attribute_category,
   attribute1,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15,
   attribute16,
   attribute17,
   attribute18,
   attribute19,
   attribute20,
   object_version_number,
   global_attribute_category,
   global_attribute1,
   global_attribute2,
   global_attribute3,
   global_attribute4,
   global_attribute5,
   global_attribute6,
   global_attribute7,
        global_attribute8,
   global_attribute9,
   global_attribute10,
   global_attribute11,
   global_attribute12,
   global_attribute13,
   global_attribute14,
   global_attribute15,
   global_attribute16,
   global_attribute17,
   global_attribute18,
   global_attribute19,
        global_attribute20,
        legal_address_flag,
   tp_header_id,
   ece_tp_location_code,
        business_group_id,
   geometry
  )
  VALUES
  (   p_rec.location_id,
   p_rec.entered_by,
   p_rec.location_code,
        p_rec.timezone_code,
   p_rec.address_line_1,
   p_rec.address_line_2,
   p_rec.address_line_3,
   p_rec.bill_to_site_flag,
   p_rec.country,
   p_rec.description,
   p_rec.designated_receiver_id,
   p_rec.in_organization_flag,
   p_rec.inactive_date,
   p_rec.inventory_organization_id,
   p_rec.office_site_flag,
   p_rec.postal_code,
   p_rec.receiving_site_flag,
   p_rec.region_1,
   p_rec.region_2,
   p_rec.region_3,
   p_rec.ship_to_location_id,
   p_rec.ship_to_site_flag,
        p_rec.derived_locale,
   p_rec.style,
--   p_rec.tax_name,
   p_rec.telephone_number_1,
   p_rec.telephone_number_2,
   p_rec.telephone_number_3,
   p_rec.town_or_city,
        p_rec.loc_information13,
        p_rec.loc_information14,
        p_rec.loc_information15,
        p_rec.loc_information16,
        p_rec.loc_information17,
        p_rec.loc_information18,
        p_rec.loc_information19,
        p_rec.loc_information20,
        p_rec.attribute_category,
   p_rec.attribute1,
   p_rec.attribute2,
   p_rec.attribute3,
   p_rec.attribute4,
   p_rec.attribute5,
   p_rec.attribute6,
   p_rec.attribute7,
   p_rec.attribute8,
   p_rec.attribute9,
   p_rec.attribute10,
   p_rec.attribute11,
   p_rec.attribute12,
   p_rec.attribute13,
   p_rec.attribute14,
   p_rec.attribute15,
   p_rec.attribute16,
   p_rec.attribute17,
   p_rec.attribute18,
   p_rec.attribute19,
   p_rec.attribute20,
   p_rec.object_version_number,
   p_rec.global_attribute_category,
   p_rec.global_attribute1,
   p_rec.global_attribute2,
   p_rec.global_attribute3,
   p_rec.global_attribute4,
   p_rec.global_attribute5,
   p_rec.global_attribute6,
   p_rec.global_attribute7,
   p_rec.global_attribute8,
   p_rec.global_attribute9,
   p_rec.global_attribute10,
   p_rec.global_attribute11,
   p_rec.global_attribute12,
   p_rec.global_attribute13,
   p_rec.global_attribute14,
   p_rec.global_attribute15,
   p_rec.global_attribute16,
   p_rec.global_attribute17,
   p_rec.global_attribute18,
   p_rec.global_attribute19,
        p_rec.global_attribute20,
        p_rec.legal_address_flag,
   p_rec.tp_header_id,
   p_rec.ece_tp_location_code,
        p_rec.business_group_id,
   p_rec.geometry
  );
  --
  hr_loc_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
END insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre and effective date.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE pre_insert(p_rec            IN OUT NOCOPY hr_loc_shd.g_rec_type) IS
--
  l_proc  VARCHAR2(72) := g_package||'pre_insert';
--
  cursor csr_next_location_id IS
    SELECT hr_locations_s.nextval
      FROM sys.dual;
--
  l_number_table dbms_describe.number_table;
  l_varchar_table dbms_describe.varchar2_table;
  l_package_exists boolean;
  l_package_name varchar2(2000);
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number for hr_locations_all.location_id:
  --
  OPEN csr_next_location_id;
  FETCH csr_next_location_id INTO p_rec.location_id;
  CLOSE csr_next_location_id;

  IF p_rec.ship_to_location_id IS NULL THEN
     p_rec.ship_to_location_id := p_rec.location_id;
  END IF;


 --
  -- do not call Irc_location_utility.address2geometry function if all parameters passed are null
  --
  if((p_rec.address_line_1 is null)
      and (p_rec.address_line_2 is null)
	  and (p_rec.address_line_3 is null)
      and (p_rec.town_or_city is null)
	  and (p_rec.region_1 is null)
	  and (p_rec.region_2 is null)
      and ( p_rec.region_3 is null)
	  and (p_rec.postal_code is null)
	  and (p_rec.country is null)) then

  	hr_utility.set_location('Not calling address2geometry:'||l_proc, 8);

  else
  --
  --
  --
  -- Enhancement added for Location Searching
  --
  if ((fnd_profile.value('IRC_INSTALLED_FLAG') in ('Y','D')) and
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
  --
  end if;

  hr_loc_shd.derive_locale(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE post_insert(p_rec IN hr_loc_shd.g_rec_type,
                      p_effective_date IN DATE) IS
--
  l_proc  VARCHAR2(72) := g_package||'post_insert';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for the before hook of create_location
  --
  hr_loc_rki.after_insert
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
   ,p_style                         => p_rec.style
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
     );
   EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_LOCATIONS_ALL'
        ,p_hook_type   => 'AI'
        );
    --
    -- End of API User Hook for the before hook of create_location
    --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE ins
  (
   p_rec               IN OUT NOCOPY hr_loc_shd.g_rec_type
  ,p_effective_date    IN DATE
  ,p_operating_unit_id IN NUMBER
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'ins';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  hr_loc_bus.insert_validate(p_rec
                            ,p_effective_date
             ,p_operating_unit_id);
  --
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec,
              p_effective_date);
  --
END ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE ins
(
   p_effective_date               IN DATE,
   p_location_id                  OUT NOCOPY NUMBER,
   p_object_version_number        OUT NOCOPY NUMBER,
   p_location_code                IN VARCHAR2,
   p_timezone_code                IN VARCHAR2         DEFAULT NULL,
   p_address_line_1               IN VARCHAR2         DEFAULT NULL,
   p_address_line_2               IN VARCHAR2         DEFAULT NULL,
   p_address_line_3               IN VARCHAR2         DEFAULT NULL,
   p_bill_to_site_flag            IN VARCHAR2         DEFAULT 'Y',
   p_country                      IN VARCHAR2         DEFAULT NULL,
   p_description                  IN VARCHAR2         DEFAULT NULL,
   p_designated_receiver_id       IN NUMBER           DEFAULT NULL,
   p_in_organization_flag         IN VARCHAR2         DEFAULT 'Y',
   p_inactive_date                IN DATE             DEFAULT NULL,
   p_operating_unit_id            IN NUMBER           DEFAULT NULL,
   p_inventory_organization_id    IN NUMBER           DEFAULT NULL,
   p_office_site_flag             IN VARCHAR2         DEFAULT 'Y',
   p_postal_code                  IN VARCHAR2         DEFAULT NULL,
   p_receiving_site_flag          IN VARCHAR2         DEFAULT 'Y',
   p_region_1                     IN VARCHAR2         DEFAULT NULL,
   p_region_2                     IN VARCHAR2         DEFAULT NULL,
   p_region_3                     IN VARCHAR2         DEFAULT NULL,
   p_ship_to_location_id          IN NUMBER           DEFAULT NULL,
   p_ship_to_site_flag            IN VARCHAR2         DEFAULT 'Y',
   p_style                        IN VARCHAR2         DEFAULT NULL,
   p_tax_name                     IN VARCHAR2         DEFAULT NULL,
   p_telephone_number_1           IN VARCHAR2         DEFAULT NULL,
   p_telephone_number_2           IN VARCHAR2         DEFAULT NULL,
   p_telephone_number_3           IN VARCHAR2         DEFAULT NULL,
   p_town_or_city                 IN VARCHAR2         DEFAULT NULL,
   p_loc_information13            IN VARCHAR2         DEFAULT NULL,
   p_loc_information14            IN VARCHAR2         DEFAULT NULL,
   p_loc_information15            IN VARCHAR2         DEFAULT NULL,
   p_loc_information16            IN VARCHAR2         DEFAULT NULL,
   p_loc_information17            IN VARCHAR2         DEFAULT NULL,
   p_loc_information18            IN VARCHAR2         DEFAULT NULL,
   p_loc_information19            IN VARCHAR2         DEFAULT NULL,
   p_loc_information20            IN VARCHAR2         DEFAULT NULL,
   p_attribute_category           IN VARCHAR2         DEFAULT NULL,
   p_attribute1                   IN VARCHAR2         DEFAULT NULL,
   p_attribute2                   IN VARCHAR2         DEFAULT NULL,
   p_attribute3                   IN VARCHAR2         DEFAULT NULL,
   p_attribute4                   IN VARCHAR2         DEFAULT NULL,
   p_attribute5                   IN VARCHAR2         DEFAULT NULL,
   p_attribute6                   IN VARCHAR2         DEFAULT NULL,
   p_attribute7                   IN VARCHAR2         DEFAULT NULL,
   p_attribute8                   IN VARCHAR2         DEFAULT NULL,
   p_attribute9                   IN VARCHAR2         DEFAULT NULL,
   p_attribute10                  IN VARCHAR2         DEFAULT NULL,
   p_attribute11                  IN VARCHAR2         DEFAULT NULL,
   p_attribute12                  IN VARCHAR2         DEFAULT NULL,
   p_attribute13                  IN VARCHAR2         DEFAULT NULL,
   p_attribute14                  IN VARCHAR2         DEFAULT NULL,
   p_attribute15                  IN VARCHAR2         DEFAULT NULL,
   p_attribute16                  IN VARCHAR2         DEFAULT NULL,
   p_attribute17                  IN VARCHAR2         DEFAULT NULL,
   p_attribute18                  IN VARCHAR2         DEFAULT NULL,
   p_attribute19                  IN VARCHAR2         DEFAULT NULL,
   p_attribute20                  IN VARCHAR2         DEFAULT NULL,
   p_global_attribute_category    IN VARCHAR2         DEFAULT NULL,
   p_global_attribute1            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute2            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute3            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute4            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute5            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute6            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute7            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute8            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute9            IN VARCHAR2         DEFAULT NULL,
   p_global_attribute10           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute11           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute12           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute13           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute14           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute15           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute16           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute17           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute18           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute19           IN VARCHAR2         DEFAULT NULL,
   p_global_attribute20           IN VARCHAR2         DEFAULT NULL,
   p_legal_address_flag           IN VARCHAR2         DEFAULT 'N',
   p_tp_header_id                 IN NUMBER           DEFAULT NULL,
   p_ece_tp_location_code         IN VARCHAR2         DEFAULT NULL,
   p_business_group_id            IN NUMBER           DEFAULT NULL
) IS
--
  l_rec    hr_loc_shd.g_rec_type;
  l_proc  VARCHAR2(72) := g_package||'ins';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hr_loc_shd.convert_args
  (
  NULL,
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
  NULL,
  p_business_group_id
  );
  --
  -- Having converted the arguments into the hr_loc_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec
    ,p_effective_date
    ,p_operating_unit_id);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_location_id := l_rec.location_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END ins;
--
END hr_loc_ins;

/
