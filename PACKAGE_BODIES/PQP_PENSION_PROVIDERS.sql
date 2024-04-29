--------------------------------------------------------
--  DDL for Package Body PQP_PENSION_PROVIDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PENSION_PROVIDERS" as
/* $Header: pqppenpr.pkb 120.3 2005/06/28 00:29:36 sashriva noship $ */

g_package   varchar(70) := ' PQP_Pension_Providers.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_pension_provider >---------------------------|
-- ----------------------------------------------------------------------------
-- Pension Provider in NL HRMS is defined as a External Organization.
-- This procedure uses the core APIS,Packages to replicate the
-- Work Structures > Organization and Location forms.
-- It will create the location if the user has choosen to do so.

procedure create_pension_provider
  (p_pension_provider_name         in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_security_profile_id           in     number
  ,p_effective_start_date          in     date
  ,p_internal_external_flag        in     varchar2
  ,p_type                          in     varchar2
  ,p_location_id                   in out nocopy number
  ,p_create_new_location_flag      in     varchar2
  ,p_org_information_context       in     varchar2
  ,p_org_classification            in     varchar2
  ,p_organization_id               out    nocopy number
  ,p_org_information_id            out    nocopy number
  ,p_location_code                 in     varchar2
  ,p_language_code                 in     varchar2
  ,p_country_code                  in     varchar2
  ,p_address_line_1                in     varchar2 default null
  ,p_address_line_2                in     varchar2 default null
  ,p_address_line_3                in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_region_1                      in     varchar2 default null
  ,p_region_2                      in     varchar2 default null
  ,p_region_3                      in     varchar2 default null
  ,p_style                         in     varchar2 default null
  ,p_tax_name                      in     varchar2 default null
  ,p_town_or_city                  in     varchar2 default null
  ,p_location_extra_info_id        out    nocopy number
  ,p_information_type              in     varchar2 default null
  ,p_lei_information_category      in     varchar2 default null
  ,p_lei_information1              in     varchar2 default null
  ,p_lei_information2              in     varchar2 default null
  ,p_lei_information3              in     varchar2 default null
  ,p_lei_information4              in     varchar2 default null
  ,p_lei_information5              in     varchar2 default null
  ,p_lei_information6              in     varchar2 default null
  ,p_lei_information7              in     varchar2 default null
  ,p_lei_information8              in     varchar2 default null
  ,p_lei_information9              in     varchar2 default null
  ,p_lei_information10             in     varchar2 default null
  ,p_lei_information11             in     varchar2 default null
  ,p_lei_information12             in     varchar2 default null
  ,p_lei_information13             in     varchar2 default null
  ,p_lei_information14             in     varchar2 default null
  ,p_lei_information15             in     varchar2 default null
  ,p_lei_information16             in     varchar2 default null
  ,p_lei_information17             in     varchar2 default null
  ,p_lei_information18             in     varchar2 default null
  ,p_lei_information19             in     varchar2 default null
  ,p_lei_information20             in     varchar2 default null
  ,p_lei_information21             in     varchar2 default null
  ,p_lei_information22             in     varchar2 default null
  ,p_lei_information23             in     varchar2 default null
  ,p_lei_information24             in     varchar2 default null
  ,p_lei_information25             in     varchar2 default null
  ,p_lei_information26             in     varchar2 default null
  ,p_lei_information27             in     varchar2 default null
  ,p_lei_information28             in     varchar2 default null
  ,p_lei_information29             in     varchar2 default null
  ,p_lei_information30             in     varchar2 default null

  ) IS

-- Declare local variables

l_location_id            number := NULL;
l_loc_ovn                number;
l_lei_ovn                number;
l_org_ovn                number;
l_location_extra_info_id number;
l_organization_id        number;
l_org_rowid              rowid;
l_org_info_rowid         rowid;
l_org_information_id     number;

BEGIN

 -- check to see if the organization name entered is unique

     hr_organization.unique_name(
      p_business_group_id       =>  p_business_group_id,
      p_organization_id         =>  null,
      p_organization_name       =>  p_pension_provider_name);

 -- Check if a new location is to be created.

   IF p_create_new_location_flag = 'Y' AND p_location_id = -1 THEN

   -- Create new Location with the information provided
     hr_location_api.create_location(
      p_validate                    => FALSE,
      p_effective_date              => p_effective_start_date,
      p_language_code               => p_language_code,
      p_location_id                 => l_location_id,
      p_object_version_number       => l_loc_ovn,
      p_tp_header_id                => NULL,
      p_ece_tp_location_code        => NULL,
      p_address_line_1              => p_address_line_1,
      p_address_line_2              => p_address_line_2,
      p_address_line_3              => p_address_line_3,
      p_bill_to_site_flag           => 'N',
      p_country                     => p_country_code,
      p_designated_receiver_id      => NULL,
      p_in_organization_flag        => 'Y',
      p_inactive_date               => NULL,
      p_operating_unit_id           => NULL,
      p_inventory_organization_id   => NULL,
      p_office_site_flag            => 'N',
      p_postal_code                 => p_postal_code,
      p_receiving_site_flag         => 'Y',
      p_region_1                    => p_region_1,
      p_region_2                    => p_region_2,
      p_region_3                    => p_region_3,
      p_ship_to_location_id         => NULL,
      p_ship_to_site_flag           => 'Y',
      p_style                       => p_style,
      p_tax_name                    => p_tax_name,
      p_telephone_number_1          => NULL,
      p_telephone_number_2          => NULL,
      p_telephone_number_3          => NULL,
      p_town_or_city                => p_town_or_city,
      p_loc_information13           => NULL,
      p_loc_information14           => NULL,
      p_loc_information15           => NULL,
      p_loc_information16           => NULL,
      p_loc_information17           => NULL,
      p_loc_information18           => NULL,
      p_loc_information19           => NULL,
      p_loc_information20           => NULL,
      p_attribute_category          => NULL,
      p_attribute1                  => NULL,
      p_attribute2                  => NULL,
      p_attribute3                  => NULL,
      p_attribute4                  => NULL,
      p_attribute5                  => NULL,
      p_attribute6                  => NULL,
      p_attribute7                  => NULL,
      p_attribute8                  => NULL,
      p_attribute9                  => NULL,
      p_attribute10                 => NULL,
      p_attribute11                 => NULL,
      p_attribute12                 => NULL,
      p_attribute13                 => NULL,
      p_attribute14                 => NULL,
      p_attribute15                 => NULL,
      p_attribute16                 => NULL,
      p_attribute17                 => NULL,
      p_attribute18                 => NULL,
      p_attribute19                 => NULL,
      p_attribute20                 => NULL,
      p_global_attribute_category   => NULL,
      p_global_attribute1           => NULL,
      p_global_attribute2           => NULL,
      p_global_attribute3           => NULL,
      p_global_attribute4           => NULL,
      p_global_attribute5           => NULL,
      p_global_attribute6           => NULL,
      p_global_attribute7           => NULL,
      p_global_attribute8           => NULL,
      p_global_attribute9           => NULL,
      p_global_attribute10          => NULL,
      p_global_attribute11          => NULL,
      p_global_attribute12          => NULL,
      p_global_attribute13          => NULL,
      p_global_attribute14          => NULL,
      p_global_attribute15          => NULL,
      p_global_attribute16          => NULL,
      p_global_attribute17          => NULL,
      p_global_attribute18          => NULL,
      p_global_attribute19          => NULL,
      p_global_attribute20          => NULL,
      p_business_group_id           => NULL,
      p_location_code               => p_location_code,
      p_description                 => p_location_code);

      -- Create record in Extra Location information .
      -- For NL the postal address is stored here .
      hr_location_extra_info_api.create_location_extra_info
      (p_validate                     => FALSE
      ,p_location_id                  => l_location_id
      ,p_information_type             => 'NL_POSTAL_ADDRESS'
      ,p_lei_attribute_category       => NULL
      ,p_lei_attribute1               => NULL
      ,p_lei_attribute2               => NULL
      ,p_lei_attribute3               => NULL
      ,p_lei_attribute4               => NULL
      ,p_lei_attribute5               => NULL
      ,p_lei_attribute6               => NULL
      ,p_lei_attribute7               => NULL
      ,p_lei_attribute8               => NULL
      ,p_lei_attribute9               => NULL
      ,p_lei_attribute10              => NULL
      ,p_lei_attribute11              => NULL
      ,p_lei_attribute12              => NULL
      ,p_lei_attribute13              => NULL
      ,p_lei_attribute14              => NULL
      ,p_lei_attribute15              => NULL
      ,p_lei_attribute16              => NULL
      ,p_lei_attribute17              => NULL
      ,p_lei_attribute18              => NULL
      ,p_lei_attribute19              => NULL
      ,p_lei_attribute20              => NULL
      ,p_lei_information_category     => 'NL_POSTAL_ADDRESS'
      ,p_lei_information1             => p_lei_information1
      ,p_lei_information2             => p_lei_information2
      ,p_lei_information3             => p_lei_information3
      ,p_lei_information4             => p_lei_information4
      ,p_lei_information5             => p_lei_information5
      ,p_lei_information6             => p_lei_information6
      ,p_lei_information7             => p_lei_information7
      ,p_lei_information8             => p_lei_information8
      ,p_lei_information9             => p_lei_information9
      ,p_lei_information10            => p_lei_information10
      ,p_lei_information11            => p_lei_information11
      ,p_lei_information12            => p_lei_information12
      ,p_lei_information13            => p_lei_information13
      ,p_lei_information14            => p_lei_information14
      ,p_lei_information15            => p_lei_information15
      ,p_lei_information16            => p_lei_information16
      ,p_lei_information17            => p_lei_information17
      ,p_lei_information18            => p_lei_information18
      ,p_lei_information19            => p_lei_information19
      ,p_lei_information20            => p_lei_information20
      ,p_lei_information21            => p_lei_information21
      ,p_lei_information22            => p_lei_information22
      ,p_lei_information23            => p_lei_information23
      ,p_lei_information24            => p_lei_information24
      ,p_lei_information25            => p_lei_information25
      ,p_lei_information26            => p_lei_information26
      ,p_lei_information27            => p_lei_information27
      ,p_lei_information28            => p_lei_information28
      ,p_lei_information29            => p_lei_information29
      ,p_lei_information30            => p_lei_information30
      ,p_location_extra_info_id       => l_location_extra_info_id
      ,p_object_version_number        => l_lei_ovn
      );

   -- If the location_id is passed, use that location to create the org.

   ELSIF p_create_new_location_flag = 'N' AND p_location_id <> -1 THEN

      l_location_id := p_location_id;

   END IF; -- Check to create a new location

   -- Create the Organization with the location from above.
     hr_organization_units_pkg.insert_row(
      x_rowid                       => l_org_rowid,
      x_organization_id             => l_organization_id,
      x_business_group_id           => p_business_group_id,
      x_cost_allocation_keyflex_id  => NULL,
      x_location_id                 => l_location_id,
      x_soft_coding_keyflex_id      => NULL,
      x_date_from                   => p_effective_start_date,
      x_name                        => p_pension_provider_name,
      x_comments                    => p_pension_provider_name,
      x_date_to                     => NULL,
      x_internal_external_flag      => p_internal_external_flag,
      x_internal_address_line       => NULL,
      x_type                        => p_type,
      x_security_profile_id         => p_Security_Profile_Id,
      x_view_all_orgs               => 'Y',
      x_attribute_category          => NULL,
      x_attribute1                  => NULL,
      x_attribute2                  => NULL,
      x_attribute3                  => NULL,
      x_attribute4                  => NULL,
      x_attribute5                  => NULL,
      x_attribute6                  => NULL,
      x_attribute7                  => NULL,
      x_attribute8                  => NULL,
      x_attribute9                  => NULL,
      x_attribute10                 => NULL,
      x_attribute11                 => NULL,
      x_attribute12                 => NULL,
      x_attribute13                 => NULL,
      x_attribute14                 => NULL,
      x_attribute15                 => NULL,
      x_attribute16                 => NULL,
      x_attribute17                 => NULL,
      x_attribute18                 => NULL,
      x_attribute19                 => NULL,
      x_attribute20                 => NULL );

   -- Add a Organization classification of Pension Provider to the Org
     hr_org_information_pkg.insert_row(
      x_rowid                => l_org_info_rowid,
      x_org_information_id   => l_org_information_id,
      x_org_information_context => p_org_information_context,
      x_organization_id      => l_organization_id,
      x_org_information1     => p_org_classification,
      x_org_information2     => 'Y',
      x_org_information3     => NULL,
      x_org_information4     => NULL,
      x_org_information5     => NULL,
      x_org_information6     => NULL,
      x_org_information7     => NULL,
      x_org_information8     => NULL,
      x_org_information9     => NULL,
      x_org_information10    => NULL,
      x_org_information11    => NULL,
      x_org_information12    => NULL,
      x_org_information13    => NULL,
      x_org_information14    => NULL,
      x_org_information15    => NULL,
      x_org_information16    => NULL,
      x_org_information17    => NULL,
      x_org_information18    => NULL,
      x_org_information19    => NULL,
      x_org_information20    => NULL,
      x_attribute_category   => NULL,
      x_attribute1           => NULL,
      x_attribute2           => NULL,
      x_attribute3           => NULL,
      x_attribute4           => NULL,
      x_attribute5           => NULL,
      x_attribute6           => NULL,
      x_attribute7           => NULL,
      x_attribute8           => NULL,
      x_attribute9           => NULL,
      x_attribute10          => NULL,
      x_attribute11          => NULL,
      x_attribute12          => NULL,
      x_attribute13          => NULL,
      x_attribute14          => NULL,
      x_attribute15          => NULL,
      x_attribute16          => NULL,
      x_attribute17          => NULL,
      x_attribute18          => NULL,
      x_attribute19          => NULL,
      x_attribute20          => NULL);

      p_organization_id         :=  l_organization_id;
      p_location_id             :=  l_location_id;
      p_org_information_id      :=  l_org_information_id;
      p_location_extra_info_id  :=  l_location_extra_info_id;

End Create_Pension_Provider;
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_pension_provider >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_pension_provider
  (p_organization_id   in number
  ,p_business_group_id in number
  ,p_provider_name     in varchar2
  ,p_location_id       in number
  ,p_date_from         in date
  ,p_date_to           in date ) Is

  Cursor csr_org Is
   Select *
     from hr_organization_units_v
    where organization_id = p_organization_id;

  l_proc     varchar2(150)  :=  g_package||'update_pension_provider';
  l_org_rec  csr_org%ROWTYPE;

Begin
   hr_utility.set_location('Entering:'|| l_proc, 10);
   Open csr_org;
   Fetch csr_org Into l_org_rec;
   If csr_org%NOTFOUND Then
      Close csr_org;
      fnd_message.set_name('PQP', 'PQP_230815_INVALID_ORG');
      fnd_message.raise_error;
   Else
      Close csr_org;
   End If;

 -- check to see if the organization name entered is unique

     hr_organization.unique_name(
      p_business_group_id       =>  p_business_group_id,
      p_organization_id         =>  p_organization_id,
      p_organization_name       =>  p_provider_name);

   hr_organization_units_pkg.Update_Row
     (x_Rowid                        => l_org_rec.row_id,
      x_Organization_Id              => l_org_rec.organization_id,
      x_Business_Group_Id            => l_org_rec.business_group_id,
      x_Cost_Allocation_Keyflex_Id   => l_org_rec.Cost_Allocation_Keyflex_Id,
      x_Location_Id                  => p_location_id,
      x_Soft_Coding_Keyflex_Id       => l_org_rec.Soft_Coding_Keyflex_Id,
      x_Date_From                    => p_date_from,
      x_Name                         => p_provider_name,
      x_Comments                     => l_org_rec.Comments,
      x_Date_To                      => p_date_to,
      x_Internal_External_Flag       => l_org_rec.Internal_External_Flag,
      x_Internal_Address_Line        => l_org_rec.Internal_Address_Line,
      x_Type                         => l_org_rec.Type,
      x_Attribute_Category           => l_org_rec.Attribute_Category,
      x_Attribute1                   => l_org_rec.Attribute1,
      x_Attribute2                   => l_org_rec.Attribute2,
      x_Attribute3                   => l_org_rec.Attribute3,
      x_Attribute4                   => l_org_rec.Attribute4,
      x_Attribute5                   => l_org_rec.Attribute5,
      x_Attribute6                   => l_org_rec.Attribute6,
      x_Attribute7                   => l_org_rec.Attribute7,
      x_Attribute8                   => l_org_rec.Attribute8,
      x_Attribute9                   => l_org_rec.Attribute9,
      x_Attribute10                  => l_org_rec.Attribute10,
      x_Attribute11                  => l_org_rec.Attribute11,
      x_Attribute12                  => l_org_rec.Attribute12,
      x_Attribute13                  => l_org_rec.Attribute13,
      x_Attribute14                  => l_org_rec.Attribute14,
      x_Attribute15                  => l_org_rec.Attribute15,
      x_Attribute16                  => l_org_rec.Attribute16,
      x_Attribute17                  => l_org_rec.Attribute17,
      x_Attribute18                  => l_org_rec.Attribute18,
      x_Attribute19                  => l_org_rec.Attribute19,
      x_Attribute20                  => l_org_rec.Attribute20
      );
   hr_utility.set_location('Leaving:'|| l_proc, 70);

End update_pension_provider;


-- ----------------------------------------------------------------------------
-- |-------------------< add_pension_types >----------------------------------|
-- ----------------------------------------------------------------------------

procedure add_pension_types
  (p_organization_id               in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_org_information_context       in     varchar2
  ,p_pension_type_id               in     number
  ,p_org_information_id            out nocopy number
  ) IS

l_hoi_rowid           rowid;
l_org_information_id  number;

  BEGIN

   hr_org_information_pkg.insert_row
    (x_rowid                      => l_hoi_rowid,
     x_org_information_id         => l_org_information_id,
     x_org_information_context    => p_org_information_context,
     x_organization_id            => p_organization_id,
     x_org_information1           => to_char(p_pension_type_id),
     x_org_information2           => NULL,
     x_org_information3           => NULL,
     x_org_information4           => NULL,
     x_org_information5           => NULL,
     x_org_information6           => NULL,
     x_org_information7           => NULL,
     x_org_information8           => NULL,
     x_org_information9           => NULL,
     x_org_information10          => NULL,
     x_org_information11          => NULL,
     x_org_information12          => NULL,
     x_org_information13          => NULL,
     x_org_information14          => NULL,
     x_org_information15          => NULL,
     x_org_information16          => NULL,
     x_org_information17          => NULL,
     x_org_information18          => NULL,
     x_org_information19          => NULL,
     x_org_information20          => NULL,
     x_attribute_category         => NULL,
     x_attribute1                 => NULL,
     x_attribute2                 => NULL,
     x_attribute3                 => NULL,
     x_attribute4                 => NULL,
     x_attribute5                 => NULL,
     x_attribute6                 => NULL,
     x_attribute7                 => NULL,
     x_attribute8                 => NULL,
     x_attribute9                 => NULL,
     x_attribute10                => NULL,
     x_attribute11                => NULL,
     x_attribute12                => NULL,
     x_attribute13                => NULL,
     x_attribute14                => NULL,
     x_attribute15                => NULL,
     x_attribute16                => NULL,
     x_attribute17                => NULL,
     x_attribute18                => NULL,
     x_attribute19                => NULL,
     x_attribute20                => NULL
     );

  END add_pension_types;


-- ----------------------------------------------------------------------------
--|-------------------< add_provider_ref_number >------------------------------|
-- ----------------------------------------------------------------------------

procedure add_provider_ref_number
  (p_organization_id               in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_org_information_context       in     varchar2
  ,p_provider_reference_number     in     varchar2
  ,p_org_information_id            out nocopy number
  ) IS

l_hoi_rowid           rowid;
l_org_information_id  number;

  BEGIN

   hr_org_information_pkg.insert_row
    (x_rowid                      => l_hoi_rowid,
     x_org_information_id         => l_org_information_id,
     x_org_information_context    => p_org_information_context,
     x_organization_id            => p_organization_id,
     x_org_information1           => p_provider_reference_number,
     x_org_information2           => NULL,
     x_org_information3           => NULL,
     x_org_information4           => NULL,
     x_org_information5           => NULL,
     x_org_information6           => NULL,
     x_org_information7           => NULL,
     x_org_information8           => NULL,
     x_org_information9           => NULL,
     x_org_information10          => NULL,
     x_org_information11          => NULL,
     x_org_information12          => NULL,
     x_org_information13          => NULL,
     x_org_information14          => NULL,
     x_org_information15          => NULL,
     x_org_information16          => NULL,
     x_org_information17          => NULL,
     x_org_information18          => NULL,
     x_org_information19          => NULL,
     x_org_information20          => NULL,
     x_attribute_category         => NULL,
     x_attribute1                 => NULL,
     x_attribute2                 => NULL,
     x_attribute3                 => NULL,
     x_attribute4                 => NULL,
     x_attribute5                 => NULL,
     x_attribute6                 => NULL,
     x_attribute7                 => NULL,
     x_attribute8                 => NULL,
     x_attribute9                 => NULL,
     x_attribute10                => NULL,
     x_attribute11                => NULL,
     x_attribute12                => NULL,
     x_attribute13                => NULL,
     x_attribute14                => NULL,
     x_attribute15                => NULL,
     x_attribute16                => NULL,
     x_attribute17                => NULL,
     x_attribute18                => NULL,
     x_attribute19                => NULL,
     x_attribute20                => NULL
     );

  END add_provider_ref_number;

-- ----------------------------------------------------------------------------
-- |-------------------< create_third_party_paymnt >--------------------------|
-- ----------------------------------------------------------------------------

procedure create_third_party_paymnt
  (p_organization_id               in     number
  ,p_org_information_id            out nocopy number
  ) IS

l_hoi_rowid           rowid;
l_org_information_id  number;

  BEGIN

   hr_org_information_pkg.insert_row
    (x_rowid                      => l_hoi_rowid,
     x_org_information_id         => l_org_information_id,
     x_org_information_context    => 'CLASS',
     x_organization_id            => p_organization_id,
     x_org_information1           => 'HR_PAYEE',
     x_org_information2           => 'Y',
     x_org_information3           => NULL,
     x_org_information4           => NULL,
     x_org_information5           => NULL,
     x_org_information6           => NULL,
     x_org_information7           => NULL,
     x_org_information8           => NULL,
     x_org_information9           => NULL,
     x_org_information10          => NULL,
     x_org_information11          => NULL,
     x_org_information12          => NULL,
     x_org_information13          => NULL,
     x_org_information14          => NULL,
     x_org_information15          => NULL,
     x_org_information16          => NULL,
     x_org_information17          => NULL,
     x_org_information18          => NULL,
     x_org_information19          => NULL,
     x_org_information20          => NULL,
     x_attribute_category         => NULL,
     x_attribute1                 => NULL,
     x_attribute2                 => NULL,
     x_attribute3                 => NULL,
     x_attribute4                 => NULL,
     x_attribute5                 => NULL,
     x_attribute6                 => NULL,
     x_attribute7                 => NULL,
     x_attribute8                 => NULL,
     x_attribute9                 => NULL,
     x_attribute10                => NULL,
     x_attribute11                => NULL,
     x_attribute12                => NULL,
     x_attribute13                => NULL,
     x_attribute14                => NULL,
     x_attribute15                => NULL,
     x_attribute16                => NULL,
     x_attribute17                => NULL,
     x_attribute18                => NULL,
     x_attribute19                => NULL,
     x_attribute20                => NULL
     );

  END create_third_party_paymnt;
--
-- ----------------------------------------------------------------------------
-- |-------------------< assign_pension_type_to_org >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure assign_pension_type_to_org
 ( p_transaction_mode      in     varchar2
  ,p_organization_id       in     number
  ,p_business_group_id     in     number
  ,p_legislation_code      in     varchar2
  ,p_pension_provider_id   in     number
  ,p_pension_type_id       in     number
  ,p_registration_number   in     varchar2
  ,p_start_date            date
  ,p_end_date              date
  ,p_org_information_id    in out nocopy number
 ) Is

  Cursor csr_pen_type Is
   Select min(effective_start_date), max(effective_end_date)
     from pqp_pension_types_f
    where pension_type_id = p_pension_type_id;

  Cursor csr_org_info Is
   Select rowid
     from hr_organization_information
    where org_information_context = 'PQP_NL_ER_PENSION_TYPES'
      and org_information_id      = p_org_information_id
      and organization_id         = p_organization_id;

  Cursor csr_assigned_pen_types Is
   Select pty.pension_type_name
     from hr_organization_information hoi,
     pqp_pension_types_f pty
    where hoi.org_information_context    = 'PQP_NL_ER_PENSION_TYPES'
      and hoi.org_information2           = to_char(p_pension_type_id)
      and hoi.organization_id            = p_organization_id
      and to_char(pty.pension_type_id)   = hoi.org_information2
      and to_char(p_pension_provider_id) = hoi.org_information1
      and rownum = 1;

  l_proc               varchar2(150)  :=  g_package||'assign_pension_type_to_org';
  l_min_start_date     date;
  l_max_end_date       date;
  l_org_information_id number;
  l_hoi_rowid          rowid;
  l_assigned_pen_type  varchar2(150);

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check the start date and end date of the information
  --
  savepoint assign_pension_type_to_org;
  Open csr_pen_type;
  Fetch csr_pen_type Into l_min_start_date, l_max_end_date;
  If csr_pen_type%Found Then
     If p_start_date < l_min_start_date Or
        p_end_date   > l_max_end_date Then
        -- Error : Start or End date can't be less than or greater
        -- than the pension types Start or End date.
        fnd_message.set_name('PQP', 'PQP_230816_INV_ST_ED_DATES');
        fnd_message.raise_error;
     End If;
     Close csr_pen_type;
  Else
    -- Error : Invalid pension type id passed
    fnd_message.set_name('PQP', 'PQP_230817_INVALID_PEN_TYPE');
    fnd_message.raise_error;
     Close csr_pen_type;
  End If;
  -- Insert the information into the hr_organization_information table
  If p_transaction_mode = 'INSERT' Then
   hr_utility.set_location('  INSERT Mode, Calling: hr_org_information_pkg.Insert_Row', 15);

   open csr_assigned_pen_types;
   Fetch csr_assigned_pen_types Into l_assigned_pen_type;
   If csr_assigned_pen_types%Found Then
    --Error : The pension type is already assigned to this org
    fnd_message.set_name('PQP','PQP_230870_PTYPE_ALREADY_ASSIG');
    fnd_message.set_token('PTYPE_NAME',l_assigned_pen_type);
    fnd_message.raise_error;
   Close csr_assigned_pen_types;
   End If;

   hr_org_information_pkg.insert_row
    (x_rowid                   => l_hoi_rowid,
     x_org_information_id      => l_org_information_id,
     x_org_information_context => 'PQP_NL_ER_PENSION_TYPES',
     x_organization_id         => p_organization_id,
     x_org_information1        => to_char(p_pension_provider_id), -- Pension Provider
     x_org_information2        => to_char(p_pension_type_id),     -- Pension Type
     x_org_information3        => p_registration_number,          -- Registration Number
     x_org_information4        => fnd_date.date_to_canonical(p_start_date),-- Start Date
     x_org_information5        => fnd_date.date_to_canonical(p_end_date),  -- End Date
     x_org_information6        => NULL,
     x_org_information7        => NULL,
     x_org_information8        => NULL,
     x_org_information9        => NULL,
     x_org_information10       => NULL,
     x_org_information11       => NULL,
     x_org_information12       => NULL,
     x_org_information13       => NULL,
     x_org_information14       => NULL,
     x_org_information15       => NULL,
     x_org_information16       => NULL,
     x_org_information17       => NULL,
     x_org_information18       => NULL,
     x_org_information19       => NULL,
     x_org_information20       => NULL,
     x_attribute_category      => NULL,
     x_attribute1              => NULL,
     x_attribute2              => NULL,
     x_attribute3              => NULL,
     x_attribute4              => NULL,
     x_attribute5              => NULL,
     x_attribute6              => NULL,
     x_attribute7              => NULL,
     x_attribute8              => NULL,
     x_attribute9              => NULL,
     x_attribute10             => NULL,
     x_attribute11             => NULL,
     x_attribute12             => NULL,
     x_attribute13             => NULL,
     x_attribute14             => NULL,
     x_attribute15             => NULL,
     x_attribute16             => NULL,
     x_attribute17             => NULL,
     x_attribute18             => NULL,
     x_attribute19             => NULL,
     x_attribute20             => NULL
     );
     p_org_information_id := l_org_information_id;
  ElsIf p_transaction_mode = 'UPDATE' Then

   hr_utility.set_location('  UPDATE Mode, Calling: hr_org_information_pkg.Update_Row', 25);
   --
   -- Get the rowid for the org_information_id passed
   --
   Open csr_org_info;
   Fetch csr_org_info Into l_hoi_rowid;
   If csr_org_info%NOTFOUND Then
      --
      -- Invalid org_information_id, organization_id or combination
      -- does not exists for PQP_NL_ER_PENSION_TYPES context
      --
      Close csr_org_info;
      fnd_message.set_name('PQP', 'PQP_230815_INVALID_ORG');
      fnd_message.raise_error;
   Else
      Close csr_org_info;
   End If;
   -- Update the information in the hr_organization_information table
   hr_org_information_pkg.Update_Row
    (X_Rowid                   => l_hoi_rowid,
     X_Org_Information_Id      => p_org_information_id,
     x_org_information_context => 'PQP_NL_ER_PENSION_TYPES',
     x_organization_id         => p_organization_id,
     x_org_information1        => to_char(p_pension_provider_id), -- Pension Provider
     x_org_information2        => to_char(p_pension_type_id),     -- Pension Type
     x_org_information3        => p_registration_number,          -- Registration Number
     x_org_information4        => fnd_date.date_to_canonical(p_start_date),-- Start Date
     x_org_information5        => fnd_date.date_to_canonical(p_end_date),  -- End Date
     x_org_information6        => NULL,
     x_org_information7        => NULL,
     x_org_information8        => NULL,
     x_org_information9        => NULL,
     x_org_information10       => NULL,
     x_org_information11       => NULL,
     x_org_information12       => NULL,
     x_org_information13       => NULL,
     x_org_information14       => NULL,
     x_org_information15       => NULL,
     x_org_information16       => NULL,
     x_org_information17       => NULL,
     x_org_information18       => NULL,
     x_org_information19       => NULL,
     x_org_information20       => NULL,
     x_attribute_category      => NULL,
     x_attribute1              => NULL,
     x_attribute2              => NULL,
     x_attribute3              => NULL,
     x_attribute4              => NULL,
     x_attribute5              => NULL,
     x_attribute6              => NULL,
     x_attribute7              => NULL,
     x_attribute8              => NULL,
     x_attribute9              => NULL,
     x_attribute10             => NULL,
     x_attribute11             => NULL,
     x_attribute12             => NULL,
     x_attribute13             => NULL,
     x_attribute14             => NULL,
     x_attribute15             => NULL,
     x_attribute16             => NULL,
     x_attribute17             => NULL,
     x_attribute18             => NULL,
     x_attribute19             => NULL,
     x_attribute20             => NULL
     );
  End If;
  hr_utility.set_location(' Leaving:'|| l_proc, 60);
Exception
  When Others Then
   Rollback to assign_pension_type_to_org;
   Raise;
   hr_utility.set_location(' Leaving:'|| l_proc, 80);

End assign_pension_type_to_org;
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_pension_types >--------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_pension_types
  (p_organization_id               in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_pension_type_id               in     number
  ,p_org_information_id            in     number
  ) IS

  Cursor csr_org_info(c_org_info_context in varchar2)  Is
   Select rowid
     from hr_organization_information
    where org_information_context = c_org_info_context
      and org_information_id      = p_org_information_id
      and organization_id         = p_organization_id;

  Cursor c_chk_asg_employer IS
    select 'x'
      from hr_organization_information
     where org_information_context  = 'PQP_NL_ER_PENSION_TYPES'
           -- ORG_INFORMATION2 is the pension_type_id from NL
       and ORG_INFORMATION2      = to_char(p_pension_type_id)
       and ORG_INFORMATION1      = to_char(p_organization_id);

  Cursor c_is_pentype_attached_nl Is
   Select 1
     from pay_element_type_extra_info eei
    where ((eei.information_type = 'PQP_NL_PRE_TAX_DEDUCTIONS'
      and eei.eei_information_category = 'PQP_NL_PRE_TAX_DEDUCTIONS')
      or (eei.information_type = 'PQP_NL_SAVINGS_DEDUCTIONS'
      and eei.eei_information_category = 'PQP_NL_SAVINGS_DEDUCTIONS')
      or (eei.information_type = 'PQP_NL_ABP_DEDUCTION'
      and eei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'))
      and eei.eei_information2  = p_pension_type_id
      and eei.eei_information3  = p_organization_id;

  Cursor c_is_pentype_attached_gb Is
   Select 1
     from pay_element_type_extra_info eei
    where eei.information_type = 'PQP_GB_PENSION_SCHEME_INFO'
      and eei.eei_information_category = 'PQP_GB_PENSION_SCHEME_INFO'
      and eei.eei_information3  = p_pension_type_id
      and eei.eei_information2  = p_organization_id;

  Cursor c_is_pentype_attached_hu Is
   Select 1
     from pay_element_type_extra_info eei
    where eei.information_type = 'HU_PENSION_SCHEME_INFO'
      and eei.eei_information_category = 'HU_PENSION_SCHEME_INFO'
      and eei.eei_information3  = p_pension_type_id
      and eei.eei_information2  = p_organization_id;

  Cursor c_is_pentype_attached_ie Is
   Select 1
     from pay_element_type_extra_info eei
    where eei.information_type = 'IE_PENSION_SCHEME_INFO'
      and eei.eei_information_category = 'IE_PENSION_SCHEME_INFO'
      and eei.eei_information1  = p_pension_type_id
      and eei.eei_information2  = p_organization_id;

 l_org_info_rowid rowid;
 l_dummy          varchar2(1);
 l_org_info_context varchar2(30) default null;

Begin
  if p_legislation_code = 'GB' THEN
    l_org_info_context := 'PQP_GB_PENSION_TYPES_INFO';
  elsif p_legislation_code = 'NL' THEN
    l_org_info_context := 'PQP_NL_PENSION_TYPES';
  elsif p_legislation_code = 'HU' THEN
    l_org_info_context := 'HU_PENSION_TYPES_INFO';
  elsif p_legislation_code = 'IE' THEN
    l_org_info_context := 'IE_PENSION_TYPES_INFO';
  end if;
  OPEN  csr_org_info(l_org_info_context);
  FETCH csr_org_info INTO l_org_info_rowid;
  IF  csr_org_info%FOUND THEN
    -- Before deleting the pension type or removing
    -- it from the pension provider, check that the pension
    -- type is not assigned to any employer or a scheme. If it is then
    -- do not let the user delete the pension type from the
    -- provider.
    close csr_org_info;
    -- chk if the pension type is attached for NL schemes
    IF p_legislation_code = 'NL' THEN

      OPEN c_chk_asg_employer;
      FETCH c_chk_asg_employer INTO l_dummy;
         IF c_chk_asg_employer%FOUND THEN
           -- Error Pension type is assigned to an employer.
          close c_chk_asg_employer;
          fnd_message.set_name('PQP', 'PQP_230867_PTYPE_ASSIGN_TO_EMP');
          fnd_message.raise_error;
         ELSE
           -- It is not assigned so it can be deleted.
          close c_chk_asg_employer;
          OPEN c_is_pentype_attached_nl;
          FETCH c_is_pentype_attached_nl into l_dummy;
           IF c_is_pentype_attached_nl%FOUND THEN
            -- error the pension type cannot be removed since its used in a scheme
            close c_is_pentype_attached_nl;
            fnd_message.set_name('PQP', 'PQP_230960_PTYPE_ATTACH_SCHM');
            fnd_message.raise_error;
           ELSE
            close c_is_pentype_attached_nl;
            hr_org_information_pkg.delete_row(l_org_info_rowid);
           END IF; -- if c_is_pentype_attached_nl
         END IF; -- if c_chk_asg_employer
    ELSIF p_legislation_code = 'GB' THEN
     -- if the legislation code is GB
       OPEN c_is_pentype_attached_gb;
       FETCH c_is_pentype_attached_gb INTO l_dummy;
         IF c_is_pentype_attached_gb%FOUND THEN
           -- Error Pension type is attached to a scheme.
          close c_is_pentype_attached_gb;
          fnd_message.set_name('PQP', 'PQP_230960_PTYPE_ATTACH_SCHM');
          fnd_message.raise_error;
         ELSE
           -- It is not assigned so it can be deleted.
          close c_is_pentype_attached_gb;
           hr_org_information_pkg.delete_row(l_org_info_rowid);
         END IF;
    ELSIF p_legislation_code = 'HU' THEN
     -- if the legislation code is HU
       OPEN c_is_pentype_attached_hu;
       FETCH c_is_pentype_attached_hu INTO l_dummy;
         IF c_is_pentype_attached_hu%FOUND THEN
           -- Error Pension type is attached to a scheme.
          close c_is_pentype_attached_hu;
          fnd_message.set_name('PQP', 'PQP_230960_PTYPE_ATTACH_SCHM');
          fnd_message.raise_error;
         ELSE
           -- It is not assigned so it can be deleted.
          close c_is_pentype_attached_hu;
           hr_org_information_pkg.delete_row(l_org_info_rowid);
         END IF;
    ELSIF p_legislation_code = 'IE' THEN
     -- if the legislation code is IE
       OPEN c_is_pentype_attached_ie;
       FETCH c_is_pentype_attached_ie INTO l_dummy;
         IF c_is_pentype_attached_ie%FOUND THEN
           -- Error Pension type is attached to a scheme.
          close c_is_pentype_attached_ie;
          fnd_message.set_name('PQP', 'PQP_230960_PTYPE_ATTACH_SCHM');
          fnd_message.raise_error;
         ELSE
           -- It is not assigned so it can be deleted.
          close c_is_pentype_attached_ie;
           hr_org_information_pkg.delete_row(l_org_info_rowid);
         END IF;
     END IF;
  ELSE
    close csr_org_info;
  END IF;

End Delete_Pension_Types;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_third_party_paymnt >---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_third_party_paymnt
  (p_organization_id               in     number
  ) IS
  -- cursor to select the rowid for the org information row
  Cursor csr_org_info Is
   Select rowid
     from hr_organization_information
    where org_information_context = 'CLASS'
      and org_information1      = 'HR_PAYEE'
      and org_information2      = 'Y'
      and organization_id       = p_organization_id;

 l_org_info_rowid rowid;

Begin

  OPEN  csr_org_info;
  FETCH csr_org_info INTO l_org_info_rowid;
  -- if a row has been found specifying third party payment
  -- then delete it from hr_org_information table
  IF csr_org_info%FOUND THEN
    close csr_org_info;
    hr_org_information_pkg.delete_row(l_org_info_rowid);
  ELSE
    close csr_org_info;
  END IF;

End Delete_third_party_paymnt;

--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_pension_provider_nl>-------------------------|
-- ----------------------------------------------------------------------------
--


Procedure delete_pension_provider_nl
  (p_organization_id   in number)
  Is

  Cursor csr_org_info Is
   Select rowid,org_information_id,org_information_context,org_information1
     from hr_organization_information
   where org_information_context = 'CLASS'
     and org_information1      = 'FR_PENSION'
     and organization_id         = p_organization_id;


  Cursor csr_is_provider_assigned Is
   Select rowid
     from hr_organization_information
    where org_information_context = 'PQP_NL_ER_PENSION_TYPES'
      and org_information1      = p_organization_id;

  Cursor csr_pen_types_org_info Is
   Select rowid
     from hr_organization_information
   where org_information_context = 'PQP_NL_PENSION_TYPES'
     and organization_id = p_organization_id;

  Cursor csr_is_provider_attached Is
   Select 1
     from pay_element_type_extra_info eei
    where ((eei.information_type = 'PQP_NL_PRE_TAX_DEDUCTIONS'
      and eei.eei_information_category = 'PQP_NL_PRE_TAX_DEDUCTIONS')
      or (eei.information_type = 'PQP_NL_SAVINGS_DEDUCTIONS'
      and eei.eei_information_category = 'PQP_NL_SAVINGS_DEDUCTIONS')
      or (eei.information_type = 'PQP_NL_ABP_DEDUCTION'
      and eei.eei_information_category = 'PQP_NL_ABP_DEDUCTION'))
      and eei.eei_information3  = p_organization_id;


  l_org_info_rowid           rowid;
  l_org_information_id       number;
  l_org_information_context  varchar2(40);
  l_org_classification       varchar2(150);
  l_assigned_provider        varchar2(150);


  BEGIN

  hr_utility.set_location(' Leaving:' ,20);
    open csr_is_provider_assigned;
    Fetch csr_is_provider_assigned Into l_assigned_provider;
    If csr_is_provider_assigned%Found Then
      Close csr_is_provider_assigned;
       --Error : The provider is assigned to an employer
      fnd_message.set_name('PQP','PQP_230868_PRVDR_ASSIGN_TO_EMP');
      fnd_message.raise_error;

    Else
     Close csr_is_provider_assigned;

    End If;

    open csr_is_provider_attached;
    Fetch csr_is_provider_attached Into l_assigned_provider;
    If csr_is_provider_attached%Found Then
      Close csr_is_provider_attached;
       --Error : The provider is attached to a scheme
      fnd_message.set_name('PQP','PQP_230959_PRVDR_ATTACH_SCHM');
      fnd_message.raise_error;

    Else
     Close csr_is_provider_attached;

    End If;

    -- remove all the org_information rows containing the pension types
    --attached to this provider
     Open csr_pen_types_org_info;

     loop
       fetch csr_pen_types_org_info into l_org_info_rowid;
       exit when csr_pen_types_org_info%NOTFOUND;
       -- delete the org info row containing this pension type
       hr_org_information_pkg.delete_row(l_org_info_rowid);
     end loop;

     close csr_pen_types_org_info;

    open csr_org_info;
    fetch csr_org_info into l_org_info_rowid,l_org_information_id,
                            l_org_information_context,l_org_classification;
    close csr_org_info;

 hr_utility.set_location(' Leaving:' ,40);
    -- Disable the Organization classification of Pension Provider of the Org
     hr_org_information_pkg.update_row(
      x_rowid                => l_org_info_rowid,
      x_org_information_id   => l_org_information_id,
      x_org_information_context => l_org_information_context,
      x_organization_id      => p_organization_id,
      x_org_information1     => l_org_classification,
      x_org_information2     => 'N',
      x_org_information3     => NULL,
      x_org_information4     => NULL,
      x_org_information5     => NULL,
      x_org_information6     => NULL,
      x_org_information7     => NULL,
      x_org_information8     => NULL,
      x_org_information9     => NULL,
      x_org_information10    => NULL,
      x_org_information11    => NULL,
      x_org_information12    => NULL,
      x_org_information13    => NULL,
      x_org_information14    => NULL,
      x_org_information15    => NULL,
      x_org_information16    => NULL,
      x_org_information17    => NULL,
      x_org_information18    => NULL,
      x_org_information19    => NULL,
      x_org_information20    => NULL,
      x_attribute_category   => NULL,
      x_attribute1           => NULL,
      x_attribute2           => NULL,
      x_attribute3           => NULL,
      x_attribute4           => NULL,
      x_attribute5           => NULL,
      x_attribute6           => NULL,
      x_attribute7           => NULL,
      x_attribute8           => NULL,
      x_attribute9           => NULL,
      x_attribute10          => NULL,
      x_attribute11          => NULL,
      x_attribute12          => NULL,
      x_attribute13          => NULL,
      x_attribute14          => NULL,
      x_attribute15          => NULL,
      x_attribute16          => NULL,
      x_attribute17          => NULL,
      x_attribute18          => NULL,
      x_attribute19          => NULL,
      x_attribute20          => NULL);
hr_utility.set_location(' Leaving:' ,50);

End delete_pension_provider_nl;

--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_pension_provider_gb>-------------------------|
-- ----------------------------------------------------------------------------
--


Procedure delete_pension_provider_gb
  (p_organization_id   in number
  ,p_effective_date    in date)
  Is


 Cursor csr_org Is
  Select *
    from hr_organization_units_v
  where organization_id = p_organization_id;

  Cursor csr_org_info Is
   Select rowid,org_information_id,org_information_context,org_information1
     from hr_organization_information
   where org_information_context = 'CLASS'
     and org_information1      = 'FR_PENSION'
     and organization_id         = p_organization_id;

  Cursor csr_third_party_org_info Is
   Select rowid,org_information_id,org_information_context,org_information1
     from hr_organization_information
   where org_information_context = 'CLASS'
     and org_information1      = 'HR_PAYEE'
     and organization_id         = p_organization_id;

  Cursor csr_pen_types_org_info Is
   Select rowid
     from hr_organization_information
   where org_information_context = 'PQP_GB_PENSION_TYPES_INFO'
     and organization_id = p_organization_id;

  Cursor csr_is_provider_assigned Is
   Select 1
     from pay_element_type_extra_info eei
    where eei.information_type = 'PQP_GB_PENSION_SCHEME_INFO'
      and eei.eei_information_category = 'PQP_GB_PENSION_SCHEME_INFO'
      and eei.eei_information2 = p_organization_id;

  l_org_info_rowid              rowid;
  l_org_information_id          number;
  l_org_information_context     varchar2(40);
  l_org_classification          varchar2(150);
  l_assigned_provider           number;
  l_org_rec                     csr_org%ROWTYPE;


  BEGIN
   hr_utility.set_location(' Leaving:' ,20);
    open csr_is_provider_assigned;
    Fetch csr_is_provider_assigned Into l_assigned_provider;
    If csr_is_provider_assigned%Found Then
      Close csr_is_provider_assigned;
       --Error : The provider is assigned to an employer
      fnd_message.set_name('PQP','PQP_230959_PRVDR_ATTACH_SCHM');
      fnd_message.raise_error;

    Else
     Close csr_is_provider_assigned;

    End If;

    open csr_org_info;
    fetch csr_org_info into l_org_info_rowid,l_org_information_id,
                            l_org_information_context,l_org_classification;
    close csr_org_info;
 hr_utility.set_location(' Leaving:' ,40);
    -- Disable the Organization classification of Pension Provider of the Org
     hr_org_information_pkg.update_row(
      x_rowid                => l_org_info_rowid,
      x_org_information_id   => l_org_information_id,
      x_org_information_context => l_org_information_context,
      x_organization_id      => p_organization_id,
      x_org_information1     => l_org_classification,
      x_org_information2     => 'N',
      x_org_information3     => NULL,
      x_org_information4     => NULL,
      x_org_information5     => NULL,
      x_org_information6     => NULL,
      x_org_information7     => NULL,
      x_org_information8     => NULL,
      x_org_information9     => NULL,
      x_org_information10    => NULL,
      x_org_information11    => NULL,
      x_org_information12    => NULL,
      x_org_information13    => NULL,
      x_org_information14    => NULL,
      x_org_information15    => NULL,
      x_org_information16    => NULL,
      x_org_information17    => NULL,
      x_org_information18    => NULL,
      x_org_information19    => NULL,
      x_org_information20    => NULL,
      x_attribute_category   => NULL,
      x_attribute1           => NULL,
      x_attribute2           => NULL,
      x_attribute3           => NULL,
      x_attribute4           => NULL,
      x_attribute5           => NULL,
      x_attribute6           => NULL,
      x_attribute7           => NULL,
      x_attribute8           => NULL,
      x_attribute9           => NULL,
      x_attribute10          => NULL,
      x_attribute11          => NULL,
      x_attribute12          => NULL,
      x_attribute13          => NULL,
      x_attribute14          => NULL,
      x_attribute15          => NULL,
      x_attribute16          => NULL,
      x_attribute17          => NULL,
      x_attribute18          => NULL,
      x_attribute19          => NULL,
      x_attribute20          => NULL);
hr_utility.set_location(' Leaving:' ,50);
    -- remove all the org_information rows containing the pension types
    --attached to this provider
     Open csr_pen_types_org_info;

     loop
       fetch csr_pen_types_org_info into l_org_info_rowid;
       exit when csr_pen_types_org_info%NOTFOUND;
       -- delete the org info row containing this pension type
       hr_org_information_pkg.delete_row(l_org_info_rowid);
     end loop;

     close csr_pen_types_org_info;


    -- if a third party payment classification exists, disable that too
    open csr_third_party_org_info;
    fetch csr_third_party_org_info into l_org_info_rowid,l_org_information_id,
                            l_org_information_context,l_org_classification;
 hr_utility.set_location(' Leaving:' ,60);
    if csr_third_party_org_info%Found Then
    -- Disable the Third Party Payment Organization classification
    -- of Pension Provider
    close csr_third_party_org_info;
     hr_org_information_pkg.update_row(
      x_rowid                => l_org_info_rowid,
      x_org_information_id   => l_org_information_id,
      x_org_information_context => l_org_information_context,
      x_organization_id      => p_organization_id,
      x_org_information1     => l_org_classification,
      x_org_information2     => 'N',
      x_org_information3     => NULL,
      x_org_information4     => NULL,
      x_org_information5     => NULL,
      x_org_information6     => NULL,
      x_org_information7     => NULL,
      x_org_information8     => NULL,
      x_org_information9     => NULL,
      x_org_information10    => NULL,
      x_org_information11    => NULL,
      x_org_information12    => NULL,
      x_org_information13    => NULL,
      x_org_information14    => NULL,
      x_org_information15    => NULL,
      x_org_information16    => NULL,
      x_org_information17    => NULL,
      x_org_information18    => NULL,
      x_org_information19    => NULL,
      x_org_information20    => NULL,
      x_attribute_category   => NULL,
      x_attribute1           => NULL,
      x_attribute2           => NULL,
      x_attribute3           => NULL,
      x_attribute4           => NULL,
      x_attribute5           => NULL,
      x_attribute6           => NULL,
      x_attribute7           => NULL,
      x_attribute8           => NULL,
      x_attribute9           => NULL,
      x_attribute10          => NULL,
      x_attribute11          => NULL,
      x_attribute12          => NULL,
      x_attribute13          => NULL,
      x_attribute14          => NULL,
      x_attribute15          => NULL,
      x_attribute16          => NULL,
      x_attribute17          => NULL,
      x_attribute18          => NULL,
      x_attribute19          => NULL,
      x_attribute20          => NULL);

   else
        close csr_third_party_org_info;
    End If;
hr_utility.set_location(' Leaving:' ,70);

  -- end-date the pension provider organization with the current effective date
  Open csr_org;
  Fetch csr_org into l_org_rec;
  If csr_org%NOTFOUND Then
    Close csr_org;
    fnd_message.set_name('PQP', 'PQP_230815_INVALID_ORG');
    fnd_message.raise_error;
  Else
    Close csr_org;
  End If;
  hr_organization_units_pkg.Update_Row
     (x_Rowid                        => l_org_rec.row_id,
      x_Organization_Id              => l_org_rec.organization_id,
      x_Business_Group_Id            => l_org_rec.business_group_id,
      x_Cost_Allocation_Keyflex_Id   => l_org_rec.Cost_Allocation_Keyflex_Id,
      x_Location_Id                  => l_org_rec.Location_Id,
      x_Soft_Coding_Keyflex_Id       => l_org_rec.Soft_Coding_Keyflex_Id,
      x_Date_From                    => l_org_rec.Date_From,
      x_Name                         => l_org_rec.Name,
      x_Comments                     => l_org_rec.Comments,
      x_Date_To                      => p_effective_date,
      x_Internal_External_Flag       => l_org_rec.Internal_External_Flag,
      x_Internal_Address_Line        => l_org_rec.Internal_Address_Line,
      x_Type                         => l_org_rec.Type,
      x_Attribute_Category           => l_org_rec.Attribute_Category,
      x_Attribute1                   => l_org_rec.Attribute1,
      x_Attribute2                   => l_org_rec.Attribute2,
      x_Attribute3                   => l_org_rec.Attribute3,
      x_Attribute4                   => l_org_rec.Attribute4,
      x_Attribute5                   => l_org_rec.Attribute5,
      x_Attribute6                   => l_org_rec.Attribute6,
      x_Attribute7                   => l_org_rec.Attribute7,
      x_Attribute8                   => l_org_rec.Attribute8,
      x_Attribute9                   => l_org_rec.Attribute9,
      x_Attribute10                  => l_org_rec.Attribute10,
      x_Attribute11                  => l_org_rec.Attribute11,
      x_Attribute12                  => l_org_rec.Attribute12,
      x_Attribute13                  => l_org_rec.Attribute13,
      x_Attribute14                  => l_org_rec.Attribute14,
      x_Attribute15                  => l_org_rec.Attribute15,
      x_Attribute16                  => l_org_rec.Attribute16,
      x_Attribute17                  => l_org_rec.Attribute17,
      x_Attribute18                  => l_org_rec.Attribute18,
      x_Attribute19                  => l_org_rec.Attribute19,
      x_Attribute20                  => l_org_rec.Attribute20
      );
hr_utility.set_location(' Leaving:' ,80);

End delete_pension_provider_gb;

--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_pension_provider_hu>-------------------------|
-- ----------------------------------------------------------------------------
--


Procedure delete_pension_provider_hu
  (p_organization_id   in number
  ,p_effective_date    in date)
  Is


 Cursor csr_org Is
  Select *
    from hr_organization_units_v
  where organization_id = p_organization_id;

  Cursor csr_org_info Is
   Select rowid,org_information_id,org_information_context,org_information1
     from hr_organization_information
   where org_information_context = 'CLASS'
     and org_information1      = 'FR_PENSION'
     and organization_id         = p_organization_id;

  Cursor csr_third_party_org_info Is
   Select rowid,org_information_id,org_information_context,org_information1
     from hr_organization_information
   where org_information_context = 'CLASS'
     and org_information1      = 'HR_PAYEE'
     and organization_id         = p_organization_id;

  Cursor csr_pen_types_org_info Is
   Select rowid
     from hr_organization_information
   where org_information_context = 'HU_PENSION_TYPES_INFO'
     and organization_id = p_organization_id;

  Cursor csr_is_provider_assigned Is
   Select 1
     from pay_element_type_extra_info eei
    where eei.information_type = 'HU_PENSION_SCHEME_INFO'
      and eei.eei_information_category = 'HU_PENSION_SCHEME_INFO'
      and eei.eei_information2 = p_organization_id;

  l_org_info_rowid              rowid;
  l_org_information_id          number;
  l_org_information_context     varchar2(40);
  l_org_classification          varchar2(150);
  l_assigned_provider           number;
  l_org_rec                     csr_org%ROWTYPE;


  BEGIN
   hr_utility.set_location(' Leaving:' ,20);
    open csr_is_provider_assigned;
    Fetch csr_is_provider_assigned Into l_assigned_provider;
    If csr_is_provider_assigned%Found Then
      Close csr_is_provider_assigned;
       --Error : The provider is attached to a scheme
      fnd_message.set_name('PQP','PQP_230959_PRVDR_ATTACH_SCHM');
      fnd_message.raise_error;

    Else
     Close csr_is_provider_assigned;

    End If;

    open csr_org_info;
    fetch csr_org_info into l_org_info_rowid,l_org_information_id,
                            l_org_information_context,l_org_classification;
    close csr_org_info;
 hr_utility.set_location(' Leaving:' ,40);
    -- Disable the Organization classification of Pension Provider of the Org
     hr_org_information_pkg.update_row(
      x_rowid                => l_org_info_rowid,
      x_org_information_id   => l_org_information_id,
      x_org_information_context => l_org_information_context,
      x_organization_id      => p_organization_id,
      x_org_information1     => l_org_classification,
      x_org_information2     => 'N',
      x_org_information3     => NULL,
      x_org_information4     => NULL,
      x_org_information5     => NULL,
      x_org_information6     => NULL,
      x_org_information7     => NULL,
      x_org_information8     => NULL,
      x_org_information9     => NULL,
      x_org_information10    => NULL,
      x_org_information11    => NULL,
      x_org_information12    => NULL,
      x_org_information13    => NULL,
      x_org_information14    => NULL,
      x_org_information15    => NULL,
      x_org_information16    => NULL,
      x_org_information17    => NULL,
      x_org_information18    => NULL,
      x_org_information19    => NULL,
      x_org_information20    => NULL,
      x_attribute_category   => NULL,
      x_attribute1           => NULL,
      x_attribute2           => NULL,
      x_attribute3           => NULL,
      x_attribute4           => NULL,
      x_attribute5           => NULL,
      x_attribute6           => NULL,
      x_attribute7           => NULL,
      x_attribute8           => NULL,
      x_attribute9           => NULL,
      x_attribute10          => NULL,
      x_attribute11          => NULL,
      x_attribute12          => NULL,
      x_attribute13          => NULL,
      x_attribute14          => NULL,
      x_attribute15          => NULL,
      x_attribute16          => NULL,
      x_attribute17          => NULL,
      x_attribute18          => NULL,
      x_attribute19          => NULL,
      x_attribute20          => NULL);
hr_utility.set_location(' Leaving:' ,50);
    -- remove all the org_information rows containing the pension types
    --attached to this provider
     Open csr_pen_types_org_info;

     loop
       fetch csr_pen_types_org_info into l_org_info_rowid;
       exit when csr_pen_types_org_info%NOTFOUND;
       -- delete the org info row containing this pension type
       hr_org_information_pkg.delete_row(l_org_info_rowid);
     end loop;

     close csr_pen_types_org_info;


    -- if a third party payment classification exists, disable that too
    open csr_third_party_org_info;
    fetch csr_third_party_org_info into l_org_info_rowid,l_org_information_id,
                            l_org_information_context,l_org_classification;
 hr_utility.set_location(' Leaving:' ,60);
    if csr_third_party_org_info%Found Then
    -- Disable the Third Party Payment Organization classification
    -- of Pension Provider
    close csr_third_party_org_info;
     hr_org_information_pkg.update_row(
      x_rowid                => l_org_info_rowid,
      x_org_information_id   => l_org_information_id,
      x_org_information_context => l_org_information_context,
      x_organization_id      => p_organization_id,
      x_org_information1     => l_org_classification,
      x_org_information2     => 'N',
      x_org_information3     => NULL,
      x_org_information4     => NULL,
      x_org_information5     => NULL,
      x_org_information6     => NULL,
      x_org_information7     => NULL,
      x_org_information8     => NULL,
      x_org_information9     => NULL,
      x_org_information10    => NULL,
      x_org_information11    => NULL,
      x_org_information12    => NULL,
      x_org_information13    => NULL,
      x_org_information14    => NULL,
      x_org_information15    => NULL,
      x_org_information16    => NULL,
      x_org_information17    => NULL,
      x_org_information18    => NULL,
      x_org_information19    => NULL,
      x_org_information20    => NULL,
      x_attribute_category   => NULL,
      x_attribute1           => NULL,
      x_attribute2           => NULL,
      x_attribute3           => NULL,
      x_attribute4           => NULL,
      x_attribute5           => NULL,
      x_attribute6           => NULL,
      x_attribute7           => NULL,
      x_attribute8           => NULL,
      x_attribute9           => NULL,
      x_attribute10          => NULL,
      x_attribute11          => NULL,
      x_attribute12          => NULL,
      x_attribute13          => NULL,
      x_attribute14          => NULL,
      x_attribute15          => NULL,
      x_attribute16          => NULL,
      x_attribute17          => NULL,
      x_attribute18          => NULL,
      x_attribute19          => NULL,
      x_attribute20          => NULL);

   else
        close csr_third_party_org_info;
    End If;
hr_utility.set_location(' Leaving:' ,70);

  -- end-date the pension provider organization with the current effective date
  Open csr_org;
  Fetch csr_org into l_org_rec;
  If csr_org%NOTFOUND Then
    Close csr_org;
    fnd_message.set_name('PQP', 'PQP_230815_INVALID_ORG');
    fnd_message.raise_error;
  Else
    Close csr_org;
  End If;
  hr_organization_units_pkg.Update_Row
     (x_Rowid                        => l_org_rec.row_id,
      x_Organization_Id              => l_org_rec.organization_id,
      x_Business_Group_Id            => l_org_rec.business_group_id,
      x_Cost_Allocation_Keyflex_Id   => l_org_rec.Cost_Allocation_Keyflex_Id,
      x_Location_Id                  => l_org_rec.Location_Id,
      x_Soft_Coding_Keyflex_Id       => l_org_rec.Soft_Coding_Keyflex_Id,
      x_Date_From                    => l_org_rec.Date_From,
      x_Name                         => l_org_rec.Name,
      x_Comments                     => l_org_rec.Comments,
      x_Date_To                      => p_effective_date,
      x_Internal_External_Flag       => l_org_rec.Internal_External_Flag,
      x_Internal_Address_Line        => l_org_rec.Internal_Address_Line,
      x_Type                         => l_org_rec.Type,
      x_Attribute_Category           => l_org_rec.Attribute_Category,
      x_Attribute1                   => l_org_rec.Attribute1,
      x_Attribute2                   => l_org_rec.Attribute2,
      x_Attribute3                   => l_org_rec.Attribute3,
      x_Attribute4                   => l_org_rec.Attribute4,
      x_Attribute5                   => l_org_rec.Attribute5,
      x_Attribute6                   => l_org_rec.Attribute6,
      x_Attribute7                   => l_org_rec.Attribute7,
      x_Attribute8                   => l_org_rec.Attribute8,
      x_Attribute9                   => l_org_rec.Attribute9,
      x_Attribute10                  => l_org_rec.Attribute10,
      x_Attribute11                  => l_org_rec.Attribute11,
      x_Attribute12                  => l_org_rec.Attribute12,
      x_Attribute13                  => l_org_rec.Attribute13,
      x_Attribute14                  => l_org_rec.Attribute14,
      x_Attribute15                  => l_org_rec.Attribute15,
      x_Attribute16                  => l_org_rec.Attribute16,
      x_Attribute17                  => l_org_rec.Attribute17,
      x_Attribute18                  => l_org_rec.Attribute18,
      x_Attribute19                  => l_org_rec.Attribute19,
      x_Attribute20                  => l_org_rec.Attribute20
      );
hr_utility.set_location(' Leaving:' ,80);

End delete_pension_provider_hu;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_pension_provider_ie>-------------------------|
-- ----------------------------------------------------------------------------
--


Procedure delete_pension_provider_ie
  (p_organization_id   in number
  ,p_effective_date    in date)
  Is


 Cursor csr_org Is
  Select *
    from hr_organization_units_v
  where organization_id = p_organization_id;

  Cursor csr_org_info Is
   Select rowid,org_information_id,org_information_context,org_information1
     from hr_organization_information
   where org_information_context = 'CLASS'
     and org_information1      = 'IE_PENSION'
     and organization_id         = p_organization_id;

  Cursor csr_third_party_org_info Is
   Select rowid,org_information_id,org_information_context,org_information1
     from hr_organization_information
   where org_information_context = 'CLASS'
     and org_information1      = 'HR_PAYEE'
     and organization_id         = p_organization_id;

  Cursor csr_pen_types_org_info Is
   Select rowid
     from hr_organization_information
   where org_information_context = 'IE_PENSION_TYPES_INFO'
     and organization_id = p_organization_id;

  Cursor csr_is_provider_assigned Is
   Select 1
     from pay_element_type_extra_info eei
    where eei.information_type = 'IE_PENSION_SCHEME_INFO'
      and eei.eei_information_category = 'IE_PENSION_SCHEME_INFO'
      and eei.eei_information2 = p_organization_id;

  l_org_info_rowid              rowid;
  l_org_information_id          number;
  l_org_information_context     varchar2(40);
  l_org_classification          varchar2(150);
  l_assigned_provider           number;
  l_org_rec                     csr_org%ROWTYPE;


  BEGIN
   hr_utility.set_location(' Leaving:' ,20);
    open csr_is_provider_assigned;
    Fetch csr_is_provider_assigned Into l_assigned_provider;
    If csr_is_provider_assigned%Found Then
      Close csr_is_provider_assigned;
       --Error : The provider is attached to a scheme
      fnd_message.set_name('PQP','PQP_230959_PRVDR_ATTACH_SCHM');
      fnd_message.raise_error;

    Else
     Close csr_is_provider_assigned;

    End If;

    open csr_org_info;
    fetch csr_org_info into l_org_info_rowid,l_org_information_id,
                            l_org_information_context,l_org_classification;
    close csr_org_info;
 hr_utility.set_location(' Leaving:' ,40);
    -- Disable the Organization classification of Pension Provider of the Org
     hr_org_information_pkg.update_row(
      x_rowid                => l_org_info_rowid,
      x_org_information_id   => l_org_information_id,
      x_org_information_context => l_org_information_context,
      x_organization_id      => p_organization_id,
      x_org_information1     => l_org_classification,
      x_org_information2     => 'N',
      x_org_information3     => NULL,
      x_org_information4     => NULL,
      x_org_information5     => NULL,
      x_org_information6     => NULL,
      x_org_information7     => NULL,
      x_org_information8     => NULL,
      x_org_information9     => NULL,
      x_org_information10    => NULL,
      x_org_information11    => NULL,
      x_org_information12    => NULL,
      x_org_information13    => NULL,
      x_org_information14    => NULL,
      x_org_information15    => NULL,
      x_org_information16    => NULL,
      x_org_information17    => NULL,
      x_org_information18    => NULL,
      x_org_information19    => NULL,
      x_org_information20    => NULL,
      x_attribute_category   => NULL,
      x_attribute1           => NULL,
      x_attribute2           => NULL,
      x_attribute3           => NULL,
      x_attribute4           => NULL,
      x_attribute5           => NULL,
      x_attribute6           => NULL,
      x_attribute7           => NULL,
      x_attribute8           => NULL,
      x_attribute9           => NULL,
      x_attribute10          => NULL,
      x_attribute11          => NULL,
      x_attribute12          => NULL,
      x_attribute13          => NULL,
      x_attribute14          => NULL,
      x_attribute15          => NULL,
      x_attribute16          => NULL,
      x_attribute17          => NULL,
      x_attribute18          => NULL,
      x_attribute19          => NULL,
      x_attribute20          => NULL);
hr_utility.set_location(' Leaving:' ,50);
    -- remove all the org_information rows containing the pension types
    --attached to this provider
     Open csr_pen_types_org_info;

     loop
       fetch csr_pen_types_org_info into l_org_info_rowid;
       exit when csr_pen_types_org_info%NOTFOUND;
       -- delete the org info row containing this pension type
       hr_org_information_pkg.delete_row(l_org_info_rowid);
     end loop;

     close csr_pen_types_org_info;


    -- if a third party payment classification exists, disable that too
    open csr_third_party_org_info;
    fetch csr_third_party_org_info into l_org_info_rowid,l_org_information_id,
                            l_org_information_context,l_org_classification;
 hr_utility.set_location(' Leaving:' ,60);
    if csr_third_party_org_info%Found Then
    -- Disable the Third Party Payment Organization classification
    -- of Pension Provider
    close csr_third_party_org_info;
     hr_org_information_pkg.update_row(
      x_rowid                => l_org_info_rowid,
      x_org_information_id   => l_org_information_id,
      x_org_information_context => l_org_information_context,
      x_organization_id      => p_organization_id,
      x_org_information1     => l_org_classification,
      x_org_information2     => 'N',
      x_org_information3     => NULL,
      x_org_information4     => NULL,
      x_org_information5     => NULL,
      x_org_information6     => NULL,
      x_org_information7     => NULL,
      x_org_information8     => NULL,
      x_org_information9     => NULL,
      x_org_information10    => NULL,
      x_org_information11    => NULL,
      x_org_information12    => NULL,
      x_org_information13    => NULL,
      x_org_information14    => NULL,
      x_org_information15    => NULL,
      x_org_information16    => NULL,
      x_org_information17    => NULL,
      x_org_information18    => NULL,
      x_org_information19    => NULL,
      x_org_information20    => NULL,
      x_attribute_category   => NULL,
      x_attribute1           => NULL,
      x_attribute2           => NULL,
      x_attribute3           => NULL,
      x_attribute4           => NULL,
      x_attribute5           => NULL,
      x_attribute6           => NULL,
      x_attribute7           => NULL,
      x_attribute8           => NULL,
      x_attribute9           => NULL,
      x_attribute10          => NULL,
      x_attribute11          => NULL,
      x_attribute12          => NULL,
      x_attribute13          => NULL,
      x_attribute14          => NULL,
      x_attribute15          => NULL,
      x_attribute16          => NULL,
      x_attribute17          => NULL,
      x_attribute18          => NULL,
      x_attribute19          => NULL,
      x_attribute20          => NULL);

   else
        close csr_third_party_org_info;
    End If;
hr_utility.set_location(' Leaving:' ,70);

  -- end-date the pension provider organization with the current effective date
  Open csr_org;
  Fetch csr_org into l_org_rec;
  If csr_org%NOTFOUND Then
    Close csr_org;
    fnd_message.set_name('PQP', 'PQP_230815_INVALID_ORG');
    fnd_message.raise_error;
  Else
    Close csr_org;
  End If;
  hr_organization_units_pkg.Update_Row
     (x_Rowid                        => l_org_rec.row_id,
      x_Organization_Id              => l_org_rec.organization_id,
      x_Business_Group_Id            => l_org_rec.business_group_id,
      x_Cost_Allocation_Keyflex_Id   => l_org_rec.Cost_Allocation_Keyflex_Id,
      x_Location_Id                  => l_org_rec.Location_Id,
      x_Soft_Coding_Keyflex_Id       => l_org_rec.Soft_Coding_Keyflex_Id,
      x_Date_From                    => l_org_rec.Date_From,
      x_Name                         => l_org_rec.Name,
      x_Comments                     => l_org_rec.Comments,
      x_Date_To                      => p_effective_date,
      x_Internal_External_Flag       => l_org_rec.Internal_External_Flag,
      x_Internal_Address_Line        => l_org_rec.Internal_Address_Line,
      x_Type                         => l_org_rec.Type,
      x_Attribute_Category           => l_org_rec.Attribute_Category,
      x_Attribute1                   => l_org_rec.Attribute1,
      x_Attribute2                   => l_org_rec.Attribute2,
      x_Attribute3                   => l_org_rec.Attribute3,
      x_Attribute4                   => l_org_rec.Attribute4,
      x_Attribute5                   => l_org_rec.Attribute5,
      x_Attribute6                   => l_org_rec.Attribute6,
      x_Attribute7                   => l_org_rec.Attribute7,
      x_Attribute8                   => l_org_rec.Attribute8,
      x_Attribute9                   => l_org_rec.Attribute9,
      x_Attribute10                  => l_org_rec.Attribute10,
      x_Attribute11                  => l_org_rec.Attribute11,
      x_Attribute12                  => l_org_rec.Attribute12,
      x_Attribute13                  => l_org_rec.Attribute13,
      x_Attribute14                  => l_org_rec.Attribute14,
      x_Attribute15                  => l_org_rec.Attribute15,
      x_Attribute16                  => l_org_rec.Attribute16,
      x_Attribute17                  => l_org_rec.Attribute17,
      x_Attribute18                  => l_org_rec.Attribute18,
      x_Attribute19                  => l_org_rec.Attribute19,
      x_Attribute20                  => l_org_rec.Attribute20
      );
hr_utility.set_location(' Leaving:' ,80);

End delete_pension_provider_ie;


--
-- ----------------------------------------------------------------------------
-- |---------------------< create_pension_provider_swi >-----------------------|
-- ----------------------------------------------------------------------------

procedure create_pension_provider_swi
  (p_pension_provider_name         in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_security_profile_id           in     number
  ,p_effective_start_date          in     date
  ,p_internal_external_flag        in     varchar2
  ,p_type                          in     varchar2
  ,p_location_id                   in out nocopy number
  ,p_create_new_location_flag      in     varchar2
  ,p_org_information_context       in     varchar2
  ,p_org_classification            in     varchar2
  ,p_organization_id               out    nocopy number
  ,p_org_information_id            out    nocopy number
  ,p_location_code                 in     varchar2
  ,p_language_code                 in     varchar2
  ,p_country_code                  in     varchar2
  ,p_address_line_1                in     varchar2 default null
  ,p_address_line_2                in     varchar2 default null
  ,p_address_line_3                in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_region_1                      in     varchar2 default null
  ,p_region_2                      in     varchar2 default null
  ,p_region_3                      in     varchar2 default null
  ,p_style                         in     varchar2 default null
  ,p_tax_name                      in     varchar2 default null
  ,p_town_or_city                  in     varchar2 default null
  ,p_location_extra_info_id        out    nocopy number
  ,p_information_type              in     varchar2 default null
  ,p_lei_information_category      in     varchar2 default null
  ,p_lei_information1              in     varchar2 default null
  ,p_lei_information2              in     varchar2 default null
  ,p_lei_information3              in     varchar2 default null
  ,p_lei_information4              in     varchar2 default null
  ,p_lei_information5              in     varchar2 default null
  ,p_lei_information6              in     varchar2 default null
  ,p_lei_information7              in     varchar2 default null
  ,p_lei_information8              in     varchar2 default null
  ,p_lei_information9              in     varchar2 default null
  ,p_lei_information10             in     varchar2 default null
  ,p_lei_information11             in     varchar2 default null
  ,p_lei_information12             in     varchar2 default null
  ,p_lei_information13             in     varchar2 default null
  ,p_lei_information14             in     varchar2 default null
  ,p_lei_information15             in     varchar2 default null
  ,p_lei_information16             in     varchar2 default null
  ,p_lei_information17             in     varchar2 default null
  ,p_lei_information18             in     varchar2 default null
  ,p_lei_information19             in     varchar2 default null
  ,p_lei_information20             in     varchar2 default null
  ,p_lei_information21             in     varchar2 default null
  ,p_lei_information22             in     varchar2 default null
  ,p_lei_information23             in     varchar2 default null
  ,p_lei_information24             in     varchar2 default null
  ,p_lei_information25             in     varchar2 default null
  ,p_lei_information26             in     varchar2 default null
  ,p_lei_information27             in     varchar2 default null
  ,p_lei_information28             in     varchar2 default null
  ,p_lei_information29             in     varchar2 default null
  ,p_lei_information30             in     varchar2 default null

  ) IS

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'create_pension_provider';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_pension_provider;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
   pqp_pension_providers.create_pension_provider
  (p_pension_provider_name     =>    p_pension_provider_name
  ,p_business_group_id         =>    p_business_group_id
  ,p_legislation_code          =>    p_legislation_code
  ,p_security_profile_id       =>    p_security_profile_id
  ,p_effective_start_date      =>    p_effective_start_date
  ,p_internal_external_flag    =>    p_internal_external_flag
  ,p_type                      =>    p_type
  ,p_location_id               =>    p_location_id
  ,p_create_new_location_flag  =>    p_create_new_location_flag
  ,p_org_information_context   =>    p_org_information_context
  ,p_org_classification        =>    p_org_classification
  ,p_organization_id           =>    p_organization_id
  ,p_org_information_id        =>    p_org_information_id
  ,p_location_code             =>    p_location_code
  ,p_language_code             =>    p_language_code
  ,p_country_code              =>    p_country_code
  ,p_address_line_1            =>    p_address_line_1
  ,p_address_line_2            =>    p_address_line_2
  ,p_address_line_3            =>    p_address_line_3
  ,p_postal_code               =>    p_postal_code
  ,p_region_1                  =>    p_region_1
  ,p_region_2                  =>    p_region_2
  ,p_region_3                  =>    p_region_3
  ,p_style                     =>    p_style
  ,p_tax_name                  =>    p_tax_name
  ,p_town_or_city              =>    p_town_or_city
  ,p_location_extra_info_id    =>    p_location_extra_info_id
  ,p_information_type          =>    p_information_type
  ,p_lei_information_category  =>    p_lei_information_category
  ,p_lei_information1          =>    p_lei_information1
  ,p_lei_information2          =>    p_lei_information2
  ,p_lei_information3          =>    p_lei_information3
  ,p_lei_information4          =>    p_lei_information4
  ,p_lei_information5          =>    p_lei_information5
  ,p_lei_information6          =>    p_lei_information6
  ,p_lei_information7          =>    p_lei_information7
  ,p_lei_information8          =>    p_lei_information8
  ,p_lei_information9          =>    p_lei_information9
  ,p_lei_information10         =>    p_lei_information10
  ,p_lei_information11         =>    p_lei_information11
  ,p_lei_information12         =>    p_lei_information12
  ,p_lei_information13         =>    p_lei_information13
  ,p_lei_information14         =>    p_lei_information14
  ,p_lei_information15         =>    p_lei_information15
  ,p_lei_information16         =>    p_lei_information16
  ,p_lei_information17         =>    p_lei_information17
  ,p_lei_information18         =>    p_lei_information18
  ,p_lei_information19         =>    p_lei_information19
  ,p_lei_information20         =>    p_lei_information20
  ,p_lei_information21         =>    p_lei_information21
  ,p_lei_information22         =>    p_lei_information22
  ,p_lei_information23         =>    p_lei_information23
  ,p_lei_information24         =>    p_lei_information24
  ,p_lei_information25         =>    p_lei_information25
  ,p_lei_information26         =>    p_lei_information26
  ,p_lei_information27         =>    p_lei_information27
  ,p_lei_information28         =>    p_lei_information28
  ,p_lei_information29         =>    p_lei_information29
  ,p_lei_information30         =>    p_lei_information30
  );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_pension_provider;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --

    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_pension_provider;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

END create_pension_provider_swi;

--
-- ----------------------------------------------------------------------------
-- |---------------------< update_pension_provider_swi >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_pension_provider_swi
  (p_organization_id   in number
  ,p_business_group_id in number
  ,p_provider_name     in varchar2
  ,p_location_id       in number
  ,p_date_from         in date
  ,p_date_to           in date ) Is

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'update_pension_provider';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_pension_provider;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
 pqp_pension_providers.update_pension_provider
  (p_organization_id      =>  p_organization_id
  ,p_business_group_id    =>  p_business_group_id
  ,p_provider_name        =>  p_provider_name
  ,p_location_id          =>  p_location_id
  ,p_date_from            =>  p_date_from
  ,p_date_to              =>  p_date_to
  );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_pension_provider;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --

    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_pension_provider;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

End update_pension_provider_swi;

--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_pension_provider_swi >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_pension_provider_swi
  (p_organization_id   in number
  ,p_effective_date    in date
  ,p_business_group_id in number)
  Is

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'delete_pension_provider';
  l_leg_code varchar2(5);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_pension_provider;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --

  --
  -- Get the legislation code for the business group
  --
  l_leg_code := pqp_utilities.pqp_get_legislation_code(p_business_group_id);

  --
  -- Call API according to the appropriate legislation
  --
   IF l_leg_code = 'NL' THEN

      pqp_pension_providers.delete_pension_provider_nl
      (p_organization_id  => p_organization_id);

   ELSIF l_leg_code = 'GB' THEN

      pqp_pension_providers.delete_pension_provider_gb
      (p_organization_id  => p_organization_id
      ,p_effective_date   => p_effective_date);

   ELSIF l_leg_code = 'HU' THEN

      pqp_pension_providers.delete_pension_provider_hu
      (p_organization_id  => p_organization_id
      ,p_effective_date   => p_effective_date);
   ELSIF l_leg_code = 'IE' THEN

      pqp_pension_providers.delete_pension_provider_ie
      (p_organization_id  => p_organization_id
      ,p_effective_date   => p_effective_date);


   END IF;

   hr_utility.set_location(' Called:' || l_proc,15);
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_pension_provider;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --

    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_pension_provider;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_return_status,45);
    hr_utility.set_location(' Leaving:' || l_proc,50);
End delete_pension_provider_swi;

-- ----------------------------------------------------------------------------
-- |-------------------< add_pension_types_swi >-------------------------------|
-- ----------------------------------------------------------------------------

procedure add_pension_types_swi
  (p_organization_id               in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_org_information_context       in     varchar2
  ,p_pension_type_id               in     number
  ,p_org_information_id            out nocopy number
  ) IS

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'add_pension_types';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint add_pension_types;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqp_pension_providers.add_pension_types
  (p_organization_id         =>    p_organization_id
  ,p_business_group_id       =>    p_business_group_id
  ,p_legislation_code        =>    p_legislation_code
  ,p_org_information_context =>    p_org_information_context
  ,p_pension_type_id         =>    p_pension_type_id
  ,p_org_information_id      =>    p_org_information_id
  );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to add_pension_types;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --

    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to add_pension_types;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);


  END add_pension_types_swi;
  -- ----------------------------------------------------------------------------
-- |-------------------< add_provider_ref_number_swi >-------------------------------|
-- ----------------------------------------------------------------------------

procedure add_provider_ref_number_swi
  (p_organization_id               in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_org_information_context       in     varchar2
  ,p_provider_reference_number     in     varchar2
  ,p_org_information_id            out nocopy number
  ) IS

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'add_provider_ref_number_swi';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint add_provider_ref_number;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqp_pension_providers.add_provider_ref_number
  (p_organization_id
  ,p_business_group_id
  ,p_legislation_code
  ,p_org_information_context
  ,p_provider_reference_number
  ,p_org_information_id
  );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to add_provider_ref_number;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --

    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to add_provider_ref_number;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);


  END add_provider_ref_number_swi;




-- ----------------------------------------------------------------------------
-- |-------------------< create_third_party_paymnt_swi >-----------------------|
-- ----------------------------------------------------------------------------

procedure create_third_party_paymnt_swi
  (p_organization_id               in     number
  ,p_org_information_id            out nocopy number
  ) IS

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'create_third_party_paymnt_swi';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_third_party_paymnt_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqp_pension_providers.create_third_party_paymnt
  (p_organization_id         =>    p_organization_id
  ,p_org_information_id      =>    p_org_information_id
  );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_third_party_paymnt_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --

    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_third_party_paymnt_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);


  END create_third_party_paymnt_swi;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_pension_types_swi >----------------------------|
-- ----------------------------------------------------------------------------

 procedure delete_pension_types_swi
  (p_organization_id               in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_pension_type_id               in     number
  ,p_org_information_id            in     number
  ) IS

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'delete_pension_types';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_pension_types;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqp_pension_providers.delete_pension_types
  (p_organization_id     =>    p_organization_id
  ,p_business_group_id   =>    p_business_group_id
  ,p_legislation_code    =>    p_legislation_code
  ,p_pension_type_id     =>    p_pension_type_id
  ,p_org_information_id  =>    p_org_information_id
  );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_pension_types;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --

    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_pension_types;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

END delete_pension_types_swi;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_third_party_paymnt_swi >-----------------------|
-- ----------------------------------------------------------------------------

 procedure delete_third_party_paymnt_swi
  (p_organization_id               in     number
  ) IS

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'delete_third_party_paymnt_swi';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_third_party_paymnt;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqp_pension_providers.delete_third_party_paymnt
  (p_organization_id     =>    p_organization_id
  );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_third_party_paymnt;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --

    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_third_party_paymnt;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

END delete_third_party_paymnt_swi;

--
-- ----------------------------------------------------------------------------
-- |-------------------< assign_pension_type_to_org_swi >----------------------|
-- ----------------------------------------------------------------------------
--
procedure assign_pension_type_to_org_swi
 ( p_transaction_mode      in     varchar2
  ,p_organization_id       in     number
  ,p_business_group_id     in     number
  ,p_legislation_code      in     varchar2
  ,p_pension_provider_id   in     number
  ,p_pension_type_id       in     number
  ,p_registration_number   in     varchar2
  ,p_start_date            date
  ,p_end_date              date
  ,p_org_information_id    in out nocopy number
 ) Is

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'assign_pension_type_to_org';
Begin

  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint assign_pension_type_to_org;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqp_pension_providers.assign_pension_type_to_org
 ( p_transaction_mode    =>  p_transaction_mode
  ,p_organization_id     =>  p_organization_id
  ,p_business_group_id   =>  p_business_group_id
  ,p_legislation_code    =>  p_legislation_code
  ,p_pension_provider_id =>  p_pension_provider_id
  ,p_pension_type_id     =>  p_pension_type_id
  ,p_registration_number =>  p_registration_number
  ,p_start_date          =>  p_start_date
  ,p_end_date            =>  p_end_date
  ,p_org_information_id  =>  p_org_information_id
 );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to assign_pension_type_to_org;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --

    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to assign_pension_type_to_org;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

End assign_pension_type_to_org_swi;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_assigned_providers_swi >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_assigned_providers_swi
 ( p_organization_id       in     number
  ,p_org_information_id  in     number
 ) Is

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_return_status varchar2(1);
  l_proc    varchar2(72) := 'del_assigned_providers_swi';
Begin

  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint del_assigned_provider_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => hr_api.g_false_num);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqp_pension_providers.delete_assigned_providers
 (p_organization_id     =>  p_organization_id
 ,p_org_information_id  =>  p_org_information_id
 );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  l_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to del_assigned_provider_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --

    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to del_assigned_provider_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

End delete_assigned_providers_swi;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_assigned_providers >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_assigned_providers
 ( p_organization_id       in     number
  ,p_org_information_id  in     number
 ) Is

CURSOR csr_org_info IS
Select rowid
  From hr_organization_information
Where  org_information_context = 'PQP_NL_ER_PENSION_TYPES'
   AND organization_id = p_organization_id
   AND org_information_id = p_org_information_id;

l_hoi_rowid rowid;

Begin

--first query up the rowid of the org information row
Open csr_org_info;
Fetch csr_org_info INTO l_hoi_rowid;
If csr_org_info%NOTFOUND Then
     --
      -- Invalid org_information_id, organization_id or combination
      -- does not exists for PQP_NL_ER_PENSION_TYPES context
      --
      Close csr_org_info;
      fnd_message.set_name('PQP', 'PQP_230815_INVALID_ORG');
      fnd_message.raise_error;
Else
      -- found the rowid,now call the delete procedure
      Close csr_org_info;
      hr_org_information_pkg.delete_row(l_hoi_rowid);
End If;

End delete_assigned_providers;

End PQP_Pension_Providers;


/
