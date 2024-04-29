--------------------------------------------------------
--  DDL for Package PQP_PENSION_PROVIDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PENSION_PROVIDERS" AUTHID CURRENT_USER as
/* $Header: pqppenpr.pkh 120.2 2005/06/08 09:28:28 sashriva noship $ */

--
-- ----------------------------------------------------------------------------
-- |---------------------< create_pension_provider_swi >-----------------------|
-- ----------------------------------------------------------------------------
--

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
  ,p_organization_id               out nocopy number
  ,p_org_information_id            out nocopy number
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
  ,p_location_extra_info_id        out nocopy number
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

  );

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
  ,p_date_to           in date );


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
  );

-- ----------------------------------------------------------------------------
-- |-------------------< create_third_party_paymnt_swi >----------------------|
-- ----------------------------------------------------------------------------

procedure create_third_party_paymnt_swi
  (p_organization_id               in     number
  ,p_org_information_id            out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------< assign_pension_type_to_org_swi >----------------------|
-- ----------------------------------------------------------------------------
--
Procedure assign_pension_type_to_org_swi
 ( p_transaction_mode              in     varchar2
  ,p_organization_id               in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_pension_provider_id           in     number
  ,p_pension_type_id               in     number
  ,p_registration_number           in     varchar2
  ,p_start_date                    date
  ,p_end_date                      date
  ,p_org_information_id            in out nocopy number
 );

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_pension_types_swi >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_pension_types_swi
  (p_organization_id               in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_pension_type_id               in     number
  ,p_org_information_id            in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_third_party_paymnt_swi >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_third_party_paymnt_swi
  (p_organization_id               in     number
  );

--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_pension_provider_swi>------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pension_provider_swi
   (p_organization_id in number
   ,p_effective_date  in date
   ,p_business_group_id in number);

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_assigned_providers_swi>------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_assigned_providers_swi
   (p_organization_id in number
   ,p_org_information_id in number);

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_assigned_providers>---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_assigned_providers
   (p_organization_id in number
   ,p_org_information_id in number);


-- ----------------------------------------------------------------------------
-- |-------------------< add_provider_ref_number_swi >------------------------|
-- ----------------------------------------------------------------------------

procedure add_provider_ref_number_swi
  (p_organization_id               in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_org_information_context       in     varchar2
  ,p_provider_reference_number     in     varchar2
  ,p_org_information_id            out nocopy number);

end pqp_pension_providers;


 

/
