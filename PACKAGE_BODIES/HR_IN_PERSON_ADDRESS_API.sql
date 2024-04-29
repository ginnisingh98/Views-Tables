--------------------------------------------------------
--  DDL for Package Body HR_IN_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IN_PERSON_ADDRESS_API" AS
/* $Header: peaddini.pkb 115.0 2004/05/25 04:11 gaugupta noship $ */
g_package  VARCHAR2(33) := 'hr_in_person_address_api.';
g_trace BOOLEAN ;

-- ----------------------------------------------------------------------------
-- |-----------------------------< check_person >------------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE check_person (p_person_id         IN NUMBER
                       ,p_legislation_code  IN VARCHAR2
                       ,p_effective_date    IN DATE
                        )
IS
   l_legislation_code    per_business_groups.legislation_code%type;
   --
   CURSOR csr_emp_leg
      (c_person_id         per_people_f.person_id%TYPE,
       c_effective_date DATE
      )
   IS
      select bgp.legislation_code
      from per_people_f per,
           per_business_groups bgp
      where per.business_group_id = bgp.business_group_id
      and    per.person_id       = c_person_id
      and    c_effective_date  between per.effective_start_date and per.effective_END_date;

BEGIN

   OPEN csr_emp_leg(p_person_id, trunc(p_effective_date));
   FETCH csr_emp_leg into l_legislation_code;

   IF csr_emp_leg%notfound THEN
      CLOSE csr_emp_leg;
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
   END IF;

   CLOSE csr_emp_leg;

   --
   -- Check that the legislation of the specIFied business group is 'IN'.
   --
   IF l_legislation_code <> p_legislation_code THEN
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','IN');
      hr_utility.raise_error;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF csr_emp_leg%ISOPEN THEN
          CLOSE csr_emp_leg;
       END IF;
          RAISE;

END check_person;

-- ----------------------------------------------------------------------------
-- |------------------------< create_in_person_address >-------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE create_in_person_address
  (p_validate                      IN     BOOLEAN  default false
  ,p_effective_date                IN     DATE
  ,p_pradd_ovlapval_override       IN     BOOLEAN  default FALSE
  ,p_person_id                     IN     NUMBER   default null
  ,p_primary_flag                  IN     VARCHAR2
  ,p_date_from                     IN     DATE
  ,p_date_to                       IN     DATE     default null
  ,p_address_type                  IN     VARCHAR2 default null
  ,p_country                       IN     VARCHAR2 default null
  ,p_comments                      IN     LONG     default null
  ,p_flat_door_block               IN     VARCHAR2
  ,p_building_village              IN     VARCHAR2 default null
  ,p_road_street                   IN     VARCHAR2 default null
  ,p_area_locality                 IN     VARCHAR2 default null
  ,p_town_or_city                  IN     VARCHAR2
  ,p_state_ut                      IN     VARCHAR2 default null
  ,p_pin_code                      IN     VARCHAR2 default null
  ,p_addr_attribute_category       IN     VARCHAR2 default null
  ,p_addr_attribute1               IN     VARCHAR2 default null
  ,p_addr_attribute2               IN     VARCHAR2 default null
  ,p_addr_attribute3               IN     VARCHAR2 default null
  ,p_addr_attribute4               IN     VARCHAR2 default null
  ,p_addr_attribute5               IN     VARCHAR2 default null
  ,p_addr_attribute6               IN     VARCHAR2 default null
  ,p_addr_attribute7               IN     VARCHAR2 default null
  ,p_addr_attribute8               IN     VARCHAR2 default null
  ,p_addr_attribute9               IN     VARCHAR2 default null
  ,p_addr_attribute10              IN     VARCHAR2 default null
  ,p_addr_attribute11              IN     VARCHAR2 default null
  ,p_addr_attribute12              IN     VARCHAR2 default null
  ,p_addr_attribute13              IN     VARCHAR2 default null
  ,p_addr_attribute14              IN     VARCHAR2 default null
  ,p_addr_attribute15              IN     VARCHAR2 default null
  ,p_addr_attribute16              IN     VARCHAR2 default null
  ,p_addr_attribute17              IN     VARCHAR2 default null
  ,p_addr_attribute18              IN     VARCHAR2 default null
  ,p_addr_attribute19              IN     VARCHAR2 default null
  ,p_addr_attribute20              IN     VARCHAR2 default null
  ,p_address_id                    OUT NOCOPY    NUMBER
  ,p_object_version_number         OUT NOCOPY    NUMBER
  ) AS
  --
  -- Declare cursors and local variables
  --
  l_proc    varchar2(72) ;
  --
BEGIN
 l_proc  := g_package||'create_IN_person_address';
 g_trace := hr_utility.debug_enabled ;

 IF g_trace THEN
    hr_utility.set_location('Leaving: '||l_proc, 10);
 END IF ;

 check_person (p_person_id, 'IN', trunc(p_effective_date));

 IF g_trace THEN
    hr_utility.set_location(l_proc, 20);
 END IF ;
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
  (p_validate                      => p_validate
  ,p_effective_date                => p_effective_date
  ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
  ,p_person_id                     => p_person_id
  ,p_primary_flag                  => p_primary_flag
  ,p_style                         => 'IN'
  ,p_date_from                     => p_date_from
  ,p_date_to                       => p_date_to
  ,p_address_type                  => p_address_type
  ,p_comments                      => p_comments
  ,p_address_line1                 => p_flat_door_block
  ,p_address_line2                 => p_building_village
  ,p_address_line3                 => p_road_street
  ,p_postal_code                   => p_pin_code
  ,p_country                       => 'IN'
  ,p_addr_attribute_category       => p_addr_attribute_category
  ,p_addr_attribute1               => p_addr_attribute1
  ,p_addr_attribute2               => p_addr_attribute2
  ,p_addr_attribute3               => p_addr_attribute3
  ,p_addr_attribute4               => p_addr_attribute4
  ,p_addr_attribute5               => p_addr_attribute5
  ,p_addr_attribute6               => p_addr_attribute6
  ,p_addr_attribute7               => p_addr_attribute7
  ,p_addr_attribute8               => p_addr_attribute8
  ,p_addr_attribute9               => p_addr_attribute9
  ,p_addr_attribute10              => p_addr_attribute10
  ,p_addr_attribute11              => p_addr_attribute11
  ,p_addr_attribute12              => p_addr_attribute12
  ,p_addr_attribute13              => p_addr_attribute13
  ,p_addr_attribute14              => p_addr_attribute14
  ,p_addr_attribute15              => p_addr_attribute15
  ,p_addr_attribute16              => p_addr_attribute16
  ,p_addr_attribute17              => p_addr_attribute17
  ,p_addr_attribute18              => p_addr_attribute18
  ,p_addr_attribute19              => p_addr_attribute19
  ,p_addr_attribute20              => p_addr_attribute20
  ,p_add_information13             => p_area_locality
  ,p_add_information14             => p_town_or_city
  ,p_add_information15             => p_state_ut
  ,p_address_id                    => p_address_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  IF g_trace THEN
    hr_utility.set_location('Leaving: '||l_proc, 30);
  END IF;

  END create_in_person_address;

-- ----------------------------------------------------------------------------
-- |------------------------< update_in_person_address >-------------------------|
-- ----------------------------------------------------------------------------
 PROCEDURE update_in_person_address
   (p_validate                      IN     BOOLEAN  DEFAULT FALSE
   ,p_effective_date                IN     DATE
   ,p_address_id                    IN     NUMBER
   ,p_object_version_number         IN OUT NOCOPY NUMBER
   ,p_date_from                     IN     DATE     DEFAULT hr_api.g_date
   ,p_date_to                       IN     DATE     DEFAULT hr_api.g_date
   ,p_address_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_comments                      IN     LONG     DEFAULT hr_api.g_varchar2
   ,p_flat_door_block               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_building_village              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_road_street                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_area_locality                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_town_or_city                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_state_ut                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_pin_code                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_country                       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute_category       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute1               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute2               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute3               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute4               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute5               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute6               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute7               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute8               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute9               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute10              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute11              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute12              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute13              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute14              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute15              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute16              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute17              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute18              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute19              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ,p_addr_attribute20              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
   ) AS
   --
   -- Declare cursors and local variables
   --
  g_package VARCHAR2(10);
   l_proc                VARCHAR2(72);
   l_style               per_addresses.style%TYPE;

   CURSOR c_add_style IS
   SELECT addr.style
     FROM per_addresses addr
    WHERE addr.address_id = p_address_id;

 BEGIN
  l_proc := g_package||'update_IN_person_address';

  IF g_trace THEN
    hr_utility.set_location('Entering:'|| l_proc, 5);
  END IF;
   --
   -- Check that the Address identified is of specified style.
   --
   OPEN  c_add_style;
   FETCH c_add_style
   INTO l_style;
     IF c_add_style%NOTFOUND THEN
       CLOSE c_add_style;

       IF g_trace THEN
         hr_utility.set_location(l_proc, 7);
       END IF;
       hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
       hr_utility.raise_error;
     ELSE
       CLOSE c_add_style;

       IF l_style NOT IN( 'IN','IN_GLB')
       THEN

         IF g_trace THEN
           hr_utility.set_location(l_proc, 8);
         END IF;

         hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
         hr_utility.raise_error;
        END IF;
     END IF;

   IF g_trace THEN
     hr_utility.set_location(l_proc, 9);
   END IF;
   --
   -- Update Person Address details.
   --
   hr_person_address_api.update_person_address
     (p_validate                     => p_validate
     ,p_effective_date               => p_effective_date
     ,p_address_id                   => p_address_id
     ,p_object_version_number        => p_object_version_number
     ,p_date_from                    => p_date_from
     ,p_date_to                      => p_date_to
     ,p_address_type                 => p_address_type
     ,p_comments                     => p_comments
     ,p_address_line1                => p_flat_door_block
     ,p_address_line2                => p_building_village
     ,p_address_line3                => p_road_street
     ,p_postal_code                  => p_pin_code
     ,p_country                      => 'IN'
     ,p_addr_attribute_category      => p_addr_attribute_category
     ,p_addr_attribute1              => p_addr_attribute1
     ,p_addr_attribute2              => p_addr_attribute2
     ,p_addr_attribute3              => p_addr_attribute3
     ,p_addr_attribute4              => p_addr_attribute4
     ,p_addr_attribute5              => p_addr_attribute5
     ,p_addr_attribute6              => p_addr_attribute6
     ,p_addr_attribute7              => p_addr_attribute7
     ,p_addr_attribute8              => p_addr_attribute8
     ,p_addr_attribute9              => p_addr_attribute9
     ,p_addr_attribute10             => p_addr_attribute10
     ,p_addr_attribute11             => p_addr_attribute11
     ,p_addr_attribute12             => p_addr_attribute12
     ,p_addr_attribute13             => p_addr_attribute13
     ,p_addr_attribute14             => p_addr_attribute14
     ,p_addr_attribute15             => p_addr_attribute15
     ,p_addr_attribute16             => p_addr_attribute16
     ,p_addr_attribute17             => p_addr_attribute17
     ,p_addr_attribute18             => p_addr_attribute18
     ,p_addr_attribute19             => p_addr_attribute19
     ,p_addr_attribute20             => p_addr_attribute20
     ,p_add_information13            => p_area_locality
     ,p_add_information14            => p_town_or_city
     ,p_add_information15            => p_state_ut
     );

   IF g_trace THEN
     hr_utility.set_location(' Leaving:'||l_proc, 11);
   END IF;

 END update_IN_person_address;
 END hr_in_person_address_api;


/
