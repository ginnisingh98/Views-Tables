--------------------------------------------------------
--  DDL for Package Body HR_AE_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AE_PERSON_ADDRESS_API" as
/* $Header: peaddaei.pkb 120.0.12000000.1 2007/01/21 19:39:15 appldev ship $ */

g_package  varchar2(33) := 'hr_ae_person_address_api.';


--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ae_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE create_ae_person_address
  (
   p_validate                   in     boolean  default false
  ,p_effective_date             in     date
  ,p_person_id                  in     number
  ,p_primary_flag               in     varchar2
  ,p_date_from                  in     date
  ,p_date_to                    in     date     default null
  ,p_address_type               in     varchar2 default null
  ,p_comments                   in     long     default null
  ,p_address_line1              in     varchar2
  ,p_address_line2              in     varchar2 default null
  ,p_emirate                    in     varchar2
  ,p_city_village               in     varchar2 default null
  ,p_region_area                in     varchar2 default null
  ,p_street                     in     varchar2 default null
  ,p_building                   in     varchar2 default null
  ,p_flat_number                in     varchar2 default null
  ,p_po_box                     in     varchar2 default null
  ,p_country                    in     varchar2 default null
  ,p_addr_attribute_category    in     varchar2 default null
  ,p_addr_attribute1            in     varchar2 default null
  ,p_addr_attribute2            in     varchar2 default null
  ,p_addr_attribute3            in     varchar2 default null
  ,p_addr_attribute4            in     varchar2 default null
  ,p_addr_attribute5            in     varchar2 default null
  ,p_addr_attribute6            in     varchar2 default null
  ,p_addr_attribute7            in     varchar2 default null
  ,p_addr_attribute8            in     varchar2 default null
  ,p_addr_attribute9            in     varchar2 default null
  ,p_addr_attribute10           in     varchar2 default null
  ,p_addr_attribute11           in     varchar2 default null
  ,p_addr_attribute12           in     varchar2 default null
  ,p_addr_attribute13           in     varchar2 default null
  ,p_addr_attribute14           in     varchar2 default null
  ,p_addr_attribute15           in     varchar2 default null
  ,p_addr_attribute16           in     varchar2 default null
  ,p_addr_attribute17           in     varchar2 default null
  ,p_addr_attribute18           in     varchar2 default null
  ,p_addr_attribute19           in     varchar2 default null
  ,p_addr_attribute20           in     varchar2 default null
  ,p_party_id                   in     number   default null
  ,p_address_id                 out nocopy number
  ,p_object_version_number      out nocopy number
 ) AS
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) ;
  --
 BEGIN
     l_proc := g_package||'create_ae_person_address';

     hr_utility.set_location('Entering:'|| l_proc, 5);
     --
     -- Create Person Address details.
     --

     hr_person_address_api.create_person_address
              (p_validate                      	=>	  p_validate
              ,p_effective_date               	=>	  p_effective_date
              ,p_person_id                    	=>	  p_person_id
              ,p_primary_flag                  	=>	  p_primary_flag
              ,p_style	        		=>        'AE'
              ,p_date_from                     	=>	  p_date_from
              ,p_date_to                      	=>	  p_date_to
              ,p_address_type                  	=>	  p_address_type
              ,p_comments                      	=>	  p_comments
              ,p_address_line1                 	=>	  p_address_line1
              ,p_address_line2                 	=>	  p_address_line2
              ,p_address_line3                 	=>	  p_emirate
              ,p_town_or_city                   =>        p_city_village
              ,p_region_1                      	=>	  p_region_area
              ,p_region_2                      	=>	  p_street
              ,p_region_3                      	=>	  p_building
              ,p_add_information14            	=>	  p_flat_number
              ,p_add_information15            	=>	  p_po_box
              ,p_country                       	=>	  p_country
              ,p_addr_attribute_category       	=>	  p_addr_attribute_category
              ,p_addr_attribute1               	=>	  p_addr_attribute1
              ,p_addr_attribute2               	=>	  p_addr_attribute2
              ,p_addr_attribute3               	=>	  p_addr_attribute3
              ,p_addr_attribute4               	=>	  p_addr_attribute4
              ,p_addr_attribute5               	=>	  p_addr_attribute5
              ,p_addr_attribute6               	=>	  p_addr_attribute6
              ,p_addr_attribute7               	=>	  p_addr_attribute7
              ,p_addr_attribute8               	=>	  p_addr_attribute8
              ,p_addr_attribute9               	=>	  p_addr_attribute9
              ,p_addr_attribute10              	=>	  p_addr_attribute10
              ,p_addr_attribute11              	=>	  p_addr_attribute11
              ,p_addr_attribute12              	=>	  p_addr_attribute12
              ,p_addr_attribute13              	=>	  p_addr_attribute13
              ,p_addr_attribute14              	=>	  p_addr_attribute14
              ,p_addr_attribute15              	=>	  p_addr_attribute15
              ,p_addr_attribute16              	=>	  p_addr_attribute16
              ,p_addr_attribute17              	=>	  p_addr_attribute17
              ,p_addr_attribute18              	=>	  p_addr_attribute18
              ,p_addr_attribute19              	=>	  p_addr_attribute19
              ,p_addr_attribute20              	=>	  p_addr_attribute20
              ,p_party_id                      	=>	  p_party_id
              ,p_address_id                    	=>	  p_address_id
              ,p_object_version_number         	=>	  p_object_version_number
             );

     --
     hr_utility.set_location(' Leaving:'||l_proc, 10);
     --

END create_ae_person_address;


--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ae_person_address >-----------------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE update_ae_person_address
  (
   p_validate                   in     boolean  default false
  ,p_effective_date             in     date
  ,p_address_id                 in     number
  ,p_object_version_number      in out nocopy number
  ,p_primary_flag               in     varchar2
  ,p_date_from                  in     date
  ,p_date_to                    in     date     default null
  ,p_address_type               in     varchar2 default null
  ,p_comments                   in     long     default null
  ,p_address_line1              in     varchar2
  ,p_address_line2              in     varchar2 default null
  ,p_emirate                    in     varchar2
  ,p_city_village               in     varchar2 default null
  ,p_region_area                in     varchar2 default null
  ,p_street                     in     varchar2 default null
  ,p_building                   in     varchar2 default null
  ,p_flat_number                in     varchar2 default null
  ,p_po_box                     in     varchar2 default null
  ,p_country                    in     varchar2 default null
  ,p_addr_attribute_category    in     varchar2 default null
  ,p_addr_attribute1            in     varchar2 default null
  ,p_addr_attribute2            in     varchar2 default null
  ,p_addr_attribute3            in     varchar2 default null
  ,p_addr_attribute4            in     varchar2 default null
  ,p_addr_attribute5            in     varchar2 default null
  ,p_addr_attribute6            in     varchar2 default null
  ,p_addr_attribute7            in     varchar2 default null
  ,p_addr_attribute8            in     varchar2 default null
  ,p_addr_attribute9            in     varchar2 default null
  ,p_addr_attribute10           in     varchar2 default null
  ,p_addr_attribute11           in     varchar2 default null
  ,p_addr_attribute12           in     varchar2 default null
  ,p_addr_attribute13           in     varchar2 default null
  ,p_addr_attribute14           in     varchar2 default null
  ,p_addr_attribute15           in     varchar2 default null
  ,p_addr_attribute16           in     varchar2 default null
  ,p_addr_attribute17           in     varchar2 default null
  ,p_addr_attribute18           in     varchar2 default null
  ,p_addr_attribute19           in     varchar2 default null
  ,p_addr_attribute20           in     varchar2 default null
  ,p_party_id                   in     number   default null
 ) AS
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) ;
  l_style               per_addresses.style%TYPE;
  --
  cursor csr_add_style is
  select addr.style
    from per_addresses addr
   where addr.address_id = p_address_id;
  --
BEGIN
    l_proc  := g_package||'update_ae_person_address';

    hr_utility.set_location('Entering:'|| l_proc, 5);
    --
    -- Check that the Address identified is of specified style.
    --
    open  csr_add_style;
    fetch csr_add_style
    into l_style;

    if csr_add_style%notfound then
        --
        close csr_add_style;
        --
        hr_utility.set_location(l_proc, 7);
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
        --
    else
        --
        close csr_add_style;
        --
        if l_style <> 'AE' then
          --
          hr_utility.set_location(l_proc, 8);
          --
          hr_utility.set_message(801, 'HR_52368_ADD_INV_NOT_CORR_STYLE');
          hr_utility.raise_error;
          --
        end if;
    end if;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
              (p_validate                      	=>	  p_validate
              ,p_effective_date               	=>	  p_effective_date
              ,p_address_id                     =>        p_address_id
              ,p_object_version_number          =>        p_object_version_number
              ,p_primary_flag                  	=>	  p_primary_flag
              ,p_date_from                     	=>	  p_date_from
              ,p_date_to                      	=>	  p_date_to
              ,p_address_type                  	=>	  p_address_type
              ,p_comments                      	=>	  p_comments
              ,p_address_line1                 	=>	  p_address_line1
              ,p_address_line2                 	=>	  p_address_line2
              ,p_address_line3                 	=>	  p_emirate
              ,p_town_or_city                   =>        p_city_village
              ,p_region_1                      	=>	  p_region_area
              ,p_region_2                      	=>	  p_street
              ,p_region_3                      	=>	  p_building
              ,p_add_information14            	=>	  p_flat_number
              ,p_add_information15            	=>	  p_po_box
              ,p_country                       	=>	  p_country
              ,p_addr_attribute_category       	=>	  p_addr_attribute_category
              ,p_addr_attribute1               	=>	  p_addr_attribute1
              ,p_addr_attribute2               	=>	  p_addr_attribute2
              ,p_addr_attribute3               	=>	  p_addr_attribute3
              ,p_addr_attribute4               	=>	  p_addr_attribute4
              ,p_addr_attribute5               	=>	  p_addr_attribute5
              ,p_addr_attribute6               	=>	  p_addr_attribute6
              ,p_addr_attribute7               	=>	  p_addr_attribute7
              ,p_addr_attribute8               	=>	  p_addr_attribute8
              ,p_addr_attribute9               	=>	  p_addr_attribute9
              ,p_addr_attribute10              	=>	  p_addr_attribute10
              ,p_addr_attribute11              	=>	  p_addr_attribute11
              ,p_addr_attribute12              	=>	  p_addr_attribute12
              ,p_addr_attribute13              	=>	  p_addr_attribute13
              ,p_addr_attribute14              	=>	  p_addr_attribute14
              ,p_addr_attribute15              	=>	  p_addr_attribute15
              ,p_addr_attribute16              	=>	  p_addr_attribute16
              ,p_addr_attribute17              	=>	  p_addr_attribute17
              ,p_addr_attribute18              	=>	  p_addr_attribute18
              ,p_addr_attribute19              	=>	  p_addr_attribute19
              ,p_addr_attribute20              	=>	  p_addr_attribute20
              ,p_party_id                      	=>	  p_party_id
             );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
  --
END update_ae_person_address;


END;

/
