--------------------------------------------------------
--  DDL for Package Body HR_LOC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOC_SHD" AS
/* $Header: hrlocrhi.pkb 120.7.12010000.2 2008/12/30 10:18:50 ktithy ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package       VARCHAR2(33)  := '  hr_loc_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION return_api_dml_status RETURN BOOLEAN IS
   --
   l_proc   VARCHAR2(72) := g_package||'return_api_dml_status';
   --
BEGIN
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   RETURN (nvl(g_api_dml, false));
   --
   hr_utility.set_location(' Leaving:'||l_proc, 10);
END return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE constraint_error
  (p_constraint_name IN all_constraints.constraint_name%type) IS
   --
   l_proc   VARCHAR2(72) := g_package||'constraint_error';
   --
BEGIN
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   IF    (p_constraint_name = 'HR_HRLOC_BILL_TO_SITE_FLAG_CHK') THEN
      hr_utility.set_message(800, 'PER_52500_INV_YES_NO_FLAG');
      hr_utility.set_message_token('YES_NO_FLAG', 'Bill-to Site Flag');
      hr_utility.raise_error;
   ELSIF (p_constraint_name = 'HR_HRLOC_IN_ORGANIZATION_F_CHK') THEN
      hr_utility.set_message(800, 'PER_52500_INV_YES_NO_FLAG');
      hr_utility.set_message_token('YES_NO_FLAG', 'In-Organization Flag');
      hr_utility.raise_error;
   ELSIF (p_constraint_name = 'HR_HRLOC_OFFICE_SITE_FLAG_CHK') THEN
      hr_utility.set_message(800, 'PER_52500_INV_YES_NO_FLAG');
      hr_utility.set_message_token('YES_NO_FLAG', 'Office Site Flag');
      hr_utility.raise_error;
   ELSIF (p_constraint_name = 'HR_HRLOC_RECEIVING_SITE_FL_CHK') THEN
      hr_utility.set_message(800, 'PER_52500_INV_YES_NO_FLAG');
      hr_utility.set_message_token('YES_NO_FLAG', 'Receiving Site Flag');
      hr_utility.raise_error;
   ELSIF (p_constraint_name = 'HR_HRLOC_SHIP_TO_SITE_FLAG_CHK') THEN
      hr_utility.set_message(800, 'PER_52500_INV_YES_NO_FLAG');
      hr_utility.set_message_token('YES_NO_FLAG', 'Ship-to Site Flag');
      hr_utility.raise_error;
   ELSIF (p_constraint_name = 'HR_LOCATIONS_PK') THEN
      hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','30');
      hr_utility.raise_error;
   ELSIF (p_constraint_name = 'HR_LOCATIONS_UK2') THEN
      hr_utility.set_message(800, 'PER_52507_INV_LOCATION_CODE');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','35');
      hr_utility.raise_error;
   ELSE
      hr_utility.set_message(800, 'HR_7877_API_INVALID_CONSTRAINT');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
      hr_utility.raise_error;
   END IF;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 10);
END constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION api_updating
  (
   p_location_id                        IN NUMBER,
   p_object_version_number              IN NUMBER
  )      RETURN BOOLEAN IS
   --
   --
   -- Cursor selects the 'current' row from the HR Schema
   --
   cursor csr_select_row IS
     SELECT
       location_id,
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
       tax_name,
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
       object_version_number,
       business_group_id,
       geometry
       FROM hr_locations_all
       WHERE   location_id = p_location_id;
     --
     l_proc VARCHAR2(72)   := g_package||'api_updating';
     l_fct_ret BOOLEAN;
     --
BEGIN
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   IF (
     p_location_id IS NULL AND
     p_object_version_number IS NULL
      ) THEN
      --
      -- One of the primary key arguments is null therefore we must
      -- set the returning function value to false
      --
      l_fct_ret := false;
   ELSE
      IF (
   p_location_id = g_old_rec.location_id AND
   p_object_version_number = g_old_rec.object_version_number
    ) THEN
    hr_utility.set_location(l_proc, 10);
    --
    -- The g_old_rec is current therefore we must
    -- set the returning function to true
    --
    l_fct_ret := true;
      ELSE
    --
    -- Select the current row into g_old_rec
    --
    OPEN csr_select_row;
    FETCH csr_select_row INTO g_old_rec;
    IF csr_select_row%notfound THEN
       CLOSE csr_select_row;
       --
       -- The primary key is invalid therefore we must error
       --
       hr_utility.set_message(800, 'HR_7220_INVALID_PRIMARY_KEY');
       hr_utility.raise_error;
    END IF;
    CLOSE csr_select_row;
    IF (p_object_version_number <> g_old_rec.object_version_number) THEN
       hr_utility.set_message(800, 'HR_7155_OBJECT_INVALID');
       hr_utility.set_message_token('TABLE_NAME', 'HR_LOCATIONS_ALL');
       hr_utility.raise_error;
    END IF;
    hr_utility.set_location(l_proc, 15);
    l_fct_ret := true;
      END IF;
   END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 20);
   RETURN (l_fct_ret);
   --
END api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (
   p_location_id                        IN NUMBER,
   p_object_version_number              IN NUMBER
  ) IS
   --
   -- Cursor selects the 'current' row from the HR Schema
   --
   cursor csr_lock_row IS
     SELECT
       location_id,
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
       tax_name,
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
       object_version_number,
       business_group_id,
       geometry
       FROM hr_locations_all
       WHERE   location_id = p_location_id
       FOR  UPDATE nowait;
     --
     l_proc VARCHAR2(72) := g_package||'lck';
     --
BEGIN
   hr_utility.set_location('Entering:'|| l_proc || '. OVN :' || to_char (p_object_version_number)
                            || ',  ID :' || to_char (p_location_id), 5);
   --
   -- Add any mandatory argument checking here:
   -- Example:
   -- hr_api.mandatory_arg_error
   --   (p_api_name       => l_proc,
   --    p_argument       => 'object_version_number',
   --    p_argument_value => p_object_version_number);
   --
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'location_id',
     p_argument_value => p_location_id);
   --
   hr_utility.set_location(l_proc, 6);
   --
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'object_version_number',
     p_argument_value => p_object_version_number);
   --
   hr_utility.set_location(l_proc, 10);
   --
   --
   OPEN csr_lock_row;
   FETCH csr_lock_row INTO g_old_rec;
   IF csr_lock_row%notfound THEN
      CLOSE csr_lock_row;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(800, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
   END IF;
   CLOSE csr_lock_row;
   --
   hr_utility.set_location(l_proc, 15);
   --
   IF (p_object_version_number <> nvl (g_old_rec.object_version_number, hr_api.g_number) )
   THEN
      hr_utility.set_message(800, 'HR_7155_OBJECT_INVALID');
      hr_utility.raise_error;
   END IF;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 20);
   --
   -- We need to trap the ORA LOCK exception
   --
EXCEPTION
   WHEN hr_api.object_locked THEN
     --
     -- The object is locked therefore we need to supply a meaningful
     -- error message.
     --
     hr_utility.set_message(800, 'HR_7165_OBJECT_LOCKED');
     hr_utility.set_message_token('TABLE_NAME', 'hr_locations_all');
     hr_utility.raise_error;
END lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION convert_args
  (
   p_location_id                   IN NUMBER,
   p_location_code                 IN VARCHAR2,
   p_timezone_code                 IN VARCHAR2,
   p_address_line_1                IN VARCHAR2,
   p_address_line_2                IN VARCHAR2,
   p_address_line_3                IN VARCHAR2,
   p_bill_to_site_flag             IN VARCHAR2,
   p_country                       IN VARCHAR2,
   p_description                   IN VARCHAR2,
   p_designated_receiver_id        IN NUMBER,
   p_in_organization_flag          IN VARCHAR2,
   p_inactive_date                 IN DATE,
   p_inventory_organization_id     IN NUMBER,
   p_office_site_flag              IN VARCHAR2,
   p_postal_code                   IN VARCHAR2,
   p_receiving_site_flag           IN VARCHAR2,
   p_region_1                      IN VARCHAR2,
   p_region_2                      IN VARCHAR2,
   p_region_3                      IN VARCHAR2,
   p_ship_to_location_id           IN NUMBER,
   p_ship_to_site_flag             IN VARCHAR2,
   p_style                         IN VARCHAR2,
   p_tax_name                      IN VARCHAR2,
   p_telephone_number_1            IN VARCHAR2,
   p_telephone_number_2            IN VARCHAR2,
   p_telephone_number_3            IN VARCHAR2,
   p_town_or_city                  IN VARCHAR2,
   p_loc_information13             IN VARCHAR2,
   p_loc_information14             IN VARCHAR2,
   p_loc_information15             IN VARCHAR2,
   p_loc_information16             IN VARCHAR2,
   p_loc_information17             IN VARCHAR2,
   p_loc_information18             IN VARCHAR2,
   p_loc_information19             IN VARCHAR2,
   p_loc_information20             IN VARCHAR2,
   p_attribute_category            IN VARCHAR2,
   p_attribute1                    IN VARCHAR2,
   p_attribute2                    IN VARCHAR2,
   p_attribute3                    IN VARCHAR2,
   p_attribute4                    IN VARCHAR2,
   p_attribute5                    IN VARCHAR2,
   p_attribute6                    IN VARCHAR2,
   p_attribute7                    IN VARCHAR2,
   p_attribute8                    IN VARCHAR2,
   p_attribute9                    IN VARCHAR2,
   p_attribute10                   IN VARCHAR2,
   p_attribute11                   IN VARCHAR2,
   p_attribute12                   IN VARCHAR2,
   p_attribute13                   IN VARCHAR2,
   p_attribute14                   IN VARCHAR2,
   p_attribute15                   IN VARCHAR2,
   p_attribute16                   IN VARCHAR2,
   p_attribute17                   IN VARCHAR2,
   p_attribute18                   IN VARCHAR2,
   p_attribute19                   IN VARCHAR2,
   p_attribute20                   IN VARCHAR2,
   p_global_attribute_category     IN VARCHAR2,
   p_global_attribute1             IN VARCHAR2,
   p_global_attribute2             IN VARCHAR2,
   p_global_attribute3             IN VARCHAR2,
   p_global_attribute4             IN VARCHAR2,
   p_global_attribute5             IN VARCHAR2,
   p_global_attribute6             IN VARCHAR2,
   p_global_attribute7             IN VARCHAR2,
   p_global_attribute8             IN VARCHAR2,
   p_global_attribute9             IN VARCHAR2,
   p_global_attribute10            IN VARCHAR2,
   p_global_attribute11            IN VARCHAR2,
   p_global_attribute12            IN VARCHAR2,
   p_global_attribute13            IN VARCHAR2,
   p_global_attribute14            IN VARCHAR2,
   p_global_attribute15            IN VARCHAR2,
   p_global_attribute16            IN VARCHAR2,
   p_global_attribute17            IN VARCHAR2,
   p_global_attribute18            IN VARCHAR2,
   p_global_attribute19            IN VARCHAR2,
   p_global_attribute20            IN VARCHAR2,
   p_legal_address_flag            IN VARCHAR2,
   p_tp_header_id                  IN NUMBER,
   p_ece_tp_location_code          IN VARCHAR2,
   p_object_version_number         IN NUMBER,
   p_business_group_id             IN NUMBER
  )
   RETURN g_rec_type IS
   --
   l_rec   g_rec_type;
   l_proc  VARCHAR2(72) := g_package||'convert_args';
   --
BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   -- Convert arguments into local l_rec structure.
   --
   l_rec.location_id                      := p_location_id;
   l_rec.entered_by                       := 1;
   l_rec.location_code                    := p_location_code;
   l_rec.timezone_code                    := p_timezone_code;
   l_rec.address_line_1                   := p_address_line_1;
   l_rec.address_line_2                   := p_address_line_2;
   l_rec.address_line_3                   := p_address_line_3;
   l_rec.bill_to_site_flag                := p_bill_to_site_flag;
   l_rec.country                          := p_country;
   l_rec.description                      := p_description;
   l_rec.designated_receiver_id           := p_designated_receiver_id;
   l_rec.in_organization_flag             := p_in_organization_flag;
   l_rec.inactive_date                    := p_inactive_date;
   l_rec.inventory_organization_id        := p_inventory_organization_id;
   l_rec.office_site_flag                 := p_office_site_flag;
   l_rec.postal_code                      := p_postal_code;
   l_rec.receiving_site_flag              := p_receiving_site_flag;
   l_rec.region_1                         := p_region_1;
   l_rec.region_2                         := p_region_2;
   l_rec.region_3                         := p_region_3;
   l_rec.ship_to_location_id              := p_ship_to_location_id;
   l_rec.ship_to_site_flag                := p_ship_to_site_flag;
   l_rec.style                            := p_style;
   l_rec.tax_name                         := p_tax_name;
   l_rec.telephone_number_1               := p_telephone_number_1;
   l_rec.telephone_number_2               := p_telephone_number_2;
   l_rec.telephone_number_3               := p_telephone_number_3;
   l_rec.town_or_city                     := p_town_or_city;
   l_rec.loc_information13                := p_loc_information13;
   l_rec.loc_information14                := p_loc_information14;
   l_rec.loc_information15                := p_loc_information15;
   l_rec.loc_information16                := p_loc_information16;
   l_rec.loc_information17                := p_loc_information17;
   l_rec.loc_information18                := p_loc_information18;
   l_rec.loc_information19                := p_loc_information19;
   l_rec.loc_information20                := p_loc_information20;
   l_rec.attribute_category               := p_attribute_category;
   l_rec.attribute1                       := p_attribute1;
   l_rec.attribute2                       := p_attribute2;
   l_rec.attribute3                       := p_attribute3;
   l_rec.attribute4                       := p_attribute4;
   l_rec.attribute5                       := p_attribute5;
   l_rec.attribute6                       := p_attribute6;
   l_rec.attribute7                       := p_attribute7;
   l_rec.attribute8                       := p_attribute8;
   l_rec.attribute9                       := p_attribute9;
   l_rec.attribute10                      := p_attribute10;
   l_rec.attribute11                      := p_attribute11;
   l_rec.attribute12                      := p_attribute12;
   l_rec.attribute13                      := p_attribute13;
   l_rec.attribute14                      := p_attribute14;
   l_rec.attribute15                      := p_attribute15;
   l_rec.attribute16                      := p_attribute16;
   l_rec.attribute17                      := p_attribute17;
   l_rec.attribute18                      := p_attribute18;
   l_rec.attribute19                      := p_attribute19;
   l_rec.attribute20                      := p_attribute20;
   l_rec.object_version_number            := p_object_version_number;
   l_rec.global_attribute_category        := p_global_attribute_category;
   l_rec.global_attribute1                := p_global_attribute1;
   l_rec.global_attribute2                := p_global_attribute2;
   l_rec.global_attribute3                := p_global_attribute3;
   l_rec.global_attribute4                := p_global_attribute4;
   l_rec.global_attribute5                := p_global_attribute5;
   l_rec.global_attribute6                := p_global_attribute6;
   l_rec.global_attribute7                := p_global_attribute7;
   l_rec.global_attribute8                := p_global_attribute8;
   l_rec.global_attribute9                := p_global_attribute9;
   l_rec.global_attribute10               := p_global_attribute10;
   l_rec.global_attribute11               := p_global_attribute11;
   l_rec.global_attribute12               := p_global_attribute12;
   l_rec.global_attribute13               := p_global_attribute13;
   l_rec.global_attribute14               := p_global_attribute14;
   l_rec.global_attribute15               := p_global_attribute15;
   l_rec.global_attribute16               := p_global_attribute16;
   l_rec.global_attribute17               := p_global_attribute17;
   l_rec.global_attribute18               := p_global_attribute18;
   l_rec.global_attribute19               := p_global_attribute19;
   l_rec.global_attribute20               := p_global_attribute20;
      hr_utility.set_location(' Leaving:'||l_proc, 101);
   l_rec.legal_address_flag               := p_legal_address_flag;
      hr_utility.set_location(' Leaving:'||l_proc, 102);
   l_rec.tp_header_id                     := p_tp_header_id;
   l_rec.ece_tp_location_code             := p_ece_tp_location_code;
   l_rec.business_group_id                := p_business_group_id;
   --
   -- Return the plsql record structure.
   --
   hr_utility.set_location(' Leaving:'||l_proc, 10);
   RETURN(l_rec);
   --
END convert_args;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< derive_locale >-----------------------------|
-- ----------------------------------------------------------------------------
procedure derive_locale(p_rec in out nocopy hr_loc_shd.g_rec_type)
is
--
  l_number_table dbms_describe.number_table;
  l_varchar_table dbms_describe.varchar2_table;
  l_package_exists boolean;
  l_package_name varchar2(2000);
  l_seperator varchar2(1);
--
begin
  BEGIN
    l_package_name := 'HR_'||substr(p_rec.style,1,2)||'_UTILITY.DERIVE_HR_LOC_ADDRESS';-- fix for bug 4518559.
    hr_general.describe_procedure(
                 object_name   => l_package_name,
                 reserved1     => null,
                 reserved2     => null,
                 overload      => l_number_table,
                 position      => l_number_table,
                 level         => l_number_table,
                 argument_name => l_varchar_table,
                 datatype      => l_number_table,
                 default_value => l_number_table,
                 in_out        => l_number_table,
                 length        => l_number_table,
                 precision     => l_number_table,
                 scale         => l_number_table,
                 radix         => l_number_table,
                 spare         => l_number_table
                );
    -- If no exception raised at this point, then ready to concatenate address
    -- fields using legislative package.
    l_package_exists := true;
    EXCEPTION
      when others then
      -- Package doesn't exist.
      l_package_exists := false;
  END;

  IF l_package_exists THEN
    l_package_name := 'begin ' ||l_package_name ||
                                      '(:tax_name,' ||
                                       ':style,' ||
                                       ':address_line_1,' ||
                                       ':address_line_2,' ||
                                       ':address_line_3,' ||
                                       ':town_or_city,' ||
                                       ':country,' ||
                                       ':postal_code,' ||
                                       ':region_1,' ||
                                       ':region_2,' ||
                                       ':region_3,' ||
                                       ':telephone_number_1,' ||
                                       ':telephone_number_2,' ||
                                       ':telephone_number_3,' ||
                                       ':loc_information13,' ||
                                       ':loc_information14,' ||
                                       ':loc_information15,' ||
                                       ':loc_information16,' ||
                                       ':loc_information17,' ||
                                       ':attribute_category,' ||
                                       ':attribute1,' ||
                                       ':attribute2,' ||
                                       ':attribute3,' ||
                                       ':attribute4,' ||
                                       ':attribute5,' ||
                                       ':attribute6,' ||
                                       ':attribute7,' ||
                                       ':attribute8,' ||
                                       ':attribute9,' ||
                                       ':attribute10,' ||
                                       ':attribute11,' ||
                                       ':attribute12,' ||
                                       ':attribute13,' ||
                                       ':attribute14,' ||
                                       ':attribute15,' ||
                                       ':attribute16,' ||
                                       ':attribute17,' ||
                                       ':attribute18,' ||
                                       ':attribute19,' ||
                                       ':attribute20,' ||
                                       ':global_attribute_category,' ||
                                       ':global_attribute1,' ||
                                       ':global_attribute2,' ||
                                       ':global_attribute3,' ||
                                       ':global_attribute4,' ||
                                       ':global_attribute5,' ||
                                       ':global_attribute6,' ||
                                       ':global_attribute7,' ||
                                       ':global_attribute8,' ||
                                       ':global_attribute9,' ||
                                       ':global_attribute10,' ||
                                       ':global_attribute11,' ||
                                       ':global_attribute12,' ||
                                       ':global_attribute13,' ||
                                       ':global_attribute14,' ||
                                       ':global_attribute15,' ||
                                       ':global_attribute16,' ||
                                       ':global_attribute17,' ||
                                       ':global_attribute18,' ||
                                       ':global_attribute19,' ||
                                       ':global_attribute20,' ||
                                       ':loc_information18,' ||
                                       ':loc_information19,' ||
                                       ':loc_information20,' ||
                                       ':derived_locale); ' ||
                                       'end; ';
     execute immediate l_package_name
                                   using in p_rec.tax_name,
                                         in p_rec.style,
                                         in p_rec.address_line_1,
                                         in p_rec.address_line_2,
                                         in p_rec.address_line_3,
                                         in p_rec.town_or_city,
                                         in p_rec.country,
                                         in p_rec.postal_code,
                                         in p_rec.region_1,
                                         in p_rec.region_2,
                                         in p_rec.region_3,
                                         in p_rec.telephone_number_1,
                                         in p_rec.telephone_number_2,
                                         in p_rec.telephone_number_3,
                                         in p_rec.loc_information13,
                                         in p_rec.loc_information14,
                                         in p_rec.loc_information15,
                                         in p_rec.loc_information16,
                                         in p_rec.loc_information17,
                                         in p_rec.attribute_category,
                                         in p_rec.attribute1,
                                         in p_rec.attribute2,
                                         in p_rec.attribute3,
                                         in p_rec.attribute4,
                                         in p_rec.attribute5,
                                         in p_rec.attribute6,
                                         in p_rec.attribute7,
                                         in p_rec.attribute8,
                                         in p_rec.attribute9,
                                         in p_rec.attribute10,
                                         in p_rec.attribute11,
                                         in p_rec.attribute12,
                                         in p_rec.attribute13,
                                         in p_rec.attribute14,
                                         in p_rec.attribute15,
                                         in p_rec.attribute16,
                                         in p_rec.attribute17,
                                         in p_rec.attribute18,
                                         in p_rec.attribute19,
                                         in p_rec.attribute20,
                                         in p_rec.global_attribute_category,
                                         in p_rec.global_attribute1,
                                         in p_rec.global_attribute2,
                                         in p_rec.global_attribute3,
                                         in p_rec.global_attribute4,
                                         in p_rec.global_attribute5,
                                         in p_rec.global_attribute6,
                                         in p_rec.global_attribute7,
                                         in p_rec.global_attribute8,
                                         in p_rec.global_attribute9,
                                         in p_rec.global_attribute10,
                                         in p_rec.global_attribute11,
                                         in p_rec.global_attribute12,
                                         in p_rec.global_attribute13,
                                         in p_rec.global_attribute14,
                                         in p_rec.global_attribute15,
                                         in p_rec.global_attribute16,
                                         in p_rec.global_attribute17,
                                         in p_rec.global_attribute18,
                                         in p_rec.global_attribute19,
                                         in p_rec.global_attribute20,
                                         in p_rec.loc_information18,
                                         in p_rec.loc_information19,
                                         in p_rec.loc_information20,
                                        out p_rec.derived_locale;
  ELSE
    if (ltrim(p_rec.town_or_city) is null) OR
       (ltrim(p_rec.country) is null) then
      l_seperator := '';
    else
      l_seperator := ',';
    end if;
    p_rec.derived_locale := ltrim(p_rec.town_or_city) || l_seperator || ltrim(p_rec.country);
  END IF;
end;

END hr_loc_shd;

/
