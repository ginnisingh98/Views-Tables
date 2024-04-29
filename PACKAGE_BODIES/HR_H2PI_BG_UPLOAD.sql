--------------------------------------------------------
--  DDL for Package Body HR_H2PI_BG_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_H2PI_BG_UPLOAD" AS
/* $Header: hrh2pibg.pkb 120.0 2005/05/31 00:38:20 appldev noship $ */

g_package  VARCHAR2(33) := '  hr_h2pi_bg_upload.';
MAPPING_ID_INVALID EXCEPTION;
MAPPING_ID_MISSING EXCEPTION;
PRAGMA EXCEPTION_INIT (MAPPING_ID_MISSING, -20010);


-- --------------------------------------------------------------------------------
-- Description: Local function to get the ids corresponding to values for the DFF
--
-- --------------------------------------------------------------------------------
--

    FUNCTION get_id_from_value (p_org_information_id in number,
                                 p_org_info_number    in number)  return varchar2 is

    CURSOR csr_org_info IS
      SELECT ogi.org_information_context context
             ,ogi.org_information1 ogi1
             ,ogi.org_information2 ogi2
             ,ogi.org_information3 ogi3
             ,ogi.org_information4 ogi4
             ,ogi.org_information5 ogi5
             ,ogi.org_information6 ogi6
             ,ogi.org_information7 ogi7
             ,ogi.org_information8 ogi8
             ,ogi.org_information9 ogi9
             ,ogi.org_information10 ogi10
             ,ogi.org_information11 ogi11
             ,ogi.org_information12 ogi12
             ,ogi.org_information13 ogi13
             ,ogi.org_information14 ogi14
             ,ogi.org_information15 ogi15
             ,ogi.org_information16 ogi16
             ,ogi.org_information17 ogi17
             ,ogi.org_information18 ogi18
             ,ogi.org_information19 ogi19
             ,ogi.org_information20 ogi20
      FROM    hr_h2pi_organization_info ogi
      WHERE   ogi.org_information_id = p_org_information_id;

    l_seg_id    	  VARCHAR2(100);
    l_seg_value 	  VARCHAR2(100);
    l_seg_desc  	  VARCHAR2(100);

    l_return_status BOOLEAN;

    TYPE t_org_info IS RECORD
         (column_seq_num  number
          ,column_name    varchar2(30)
         );

    TYPE tab_org_info IS TABLE OF t_org_info
       INDEX BY BINARY_INTEGER;

    CURSOR csr_flex_cols(p_context VARCHAR2) IS
      SELECT column_seq_num,
             application_column_name  col_name
      FROM   fnd_descr_flex_column_usages
      WHERE  application_id = 800
      AND    descriptive_flex_context_code = p_context
      ORDER BY column_seq_num;

     idx  NUMBER;
     i    NUMBER;
     l_proc           varchar2(72) := g_package || '.get_id_from_value' ;

  BEGIN
    hr_utility.set_location('Entering:'  || l_proc,10);
    FOR v_rec IN csr_org_info LOOP
      hr_utility.trace('Context : ' || v_rec.context);
      fnd_flex_descval.set_column_value('ORG_INFORMATION_CONTEXT', v_rec.context);
      fnd_flex_descval.set_column_value('ORG_INFORMATION1', v_rec.ogi1 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION2', v_rec.ogi2 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION3', v_rec.ogi3 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION4', v_rec.ogi4 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION5', v_rec.ogi5 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION6', v_rec.ogi6 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION7', v_rec.ogi7 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION8', v_rec.ogi8 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION9', v_rec.ogi9 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION10', v_rec.ogi10);
      fnd_flex_descval.set_column_value('ORG_INFORMATION11', v_rec.ogi11);
      fnd_flex_descval.set_column_value('ORG_INFORMATION12', v_rec.ogi12);
      fnd_flex_descval.set_column_value('ORG_INFORMATION13', v_rec.ogi13);
      fnd_flex_descval.set_column_value('ORG_INFORMATION14', v_rec.ogi14);
      fnd_flex_descval.set_column_value('ORG_INFORMATION15', v_rec.ogi15);
      fnd_flex_descval.set_column_value('ORG_INFORMATION16', v_rec.ogi16);
      fnd_flex_descval.set_column_value('ORG_INFORMATION17', v_rec.ogi17);
      fnd_flex_descval.set_column_value('ORG_INFORMATION18', v_rec.ogi18);
      fnd_flex_descval.set_column_value('ORG_INFORMATION19', v_rec.ogi19);
      fnd_flex_descval.set_column_value('ORG_INFORMATION20', v_rec.ogi20);

      hr_utility.set_location(l_proc,10);
      l_return_status := fnd_flex_descval.VALIDATE_DESCCOLS
            	  (
            	  appl_short_name         =>   'PER',
            	  desc_flex_name          =>   'Org Developer DF',
            	  values_or_ids           =>   'V'
            	  );
      hr_utility.set_location(l_proc,30);

      i:=1;

      FOR v_org_info IN csr_flex_cols(v_rec.context) LOOP
        IF v_org_info.col_name = 'ORG_INFORMATION'||TO_CHAR(p_org_info_number) THEN
          idx := i;
          hr_utility.trace('Column Name : ' || v_org_info.col_name);
        END IF;
        i:=i+1;
      END LOOP;

      select fnd_flex_descval.segment_id(idx+1),
             fnd_flex_descval.segment_value(idx+1),
             fnd_flex_descval.segment_description(idx+1)
      into   l_seg_id,
             l_seg_value,
             l_seg_desc
      from   dual;

      hr_utility.trace(l_seg_id || ':' || l_seg_value);
      hr_utility.trace(fnd_flex_descval.error_message());
      return(l_seg_id);
      END LOOP;
      hr_utility.set_location('Leaving:'  || l_proc,90);
    END;

PROCEDURE upload_location (p_from_client_id NUMBER) IS

CURSOR csr_locations (p_bg_id NUMBER) IS
  SELECT *
  FROM   hr_h2pi_locations
  WHERE  client_id = p_bg_id
  AND   (status IS NULL OR status <> 'C');

l_ud_loc       hr_h2pi_locations%ROWTYPE;
l_location_id  NUMBER(15);
l_ovn          NUMBER(9);
l_encoded_message VARCHAR2(200);

l_proc         VARCHAR2(72) := g_package||'upload_location';



BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  FOR v_ud_loc in csr_locations(p_from_client_id) LOOP

    SAVEPOINT location_start;

    BEGIN
      hr_utility.set_location(l_proc, 20);
      l_location_id := hr_h2pi_map.get_to_id
                        (p_table_name        => 'HR_LOCATIONS_ALL',
                         p_from_id           => v_ud_loc.location_id);

      IF l_location_id = -1 THEN
        hr_utility.set_location(l_proc, 30);
        hr_location_api.create_location
           (p_validate	           => FALSE
           ,p_effective_date       => SYSDATE
           ,p_location_code        => v_ud_loc.location_code
           ,p_description          => v_ud_loc.description
           ,p_address_line_1       => v_ud_loc.address_line_1
           ,p_address_line_2       => v_ud_loc.address_line_2
           ,p_address_line_3       => v_ud_loc.address_line_3
           ,p_town_or_city         => v_ud_loc.town_or_city
           ,p_country              => v_ud_loc.country
           ,p_inactive_date        => v_ud_loc.inactive_date
           ,p_postal_code          => v_ud_loc.postal_code
           ,p_region_1	           => v_ud_loc.region_1
           ,p_region_2	           => v_ud_loc.region_2
           ,p_region_3	           => v_ud_loc.region_3
           ,p_style	           => v_ud_loc.style
           ,p_telephone_number_1   => v_ud_loc.telephone_number_1
           ,p_telephone_number_2   => v_ud_loc.telephone_number_2
           ,p_telephone_number_3   => v_ud_loc.telephone_number_3
           ,p_loc_information13    => v_ud_loc.loc_information13
           ,p_loc_information14    => v_ud_loc.loc_information14
           ,p_loc_information15    => v_ud_loc.loc_information15
           ,p_loc_information16    => v_ud_loc.loc_information16
           ,p_loc_information17    => v_ud_loc.loc_information17
           ,p_loc_information18    => v_ud_loc.loc_information18
           ,p_loc_information19    => v_ud_loc.loc_information19
           ,p_loc_information20    => v_ud_loc.loc_information20
           ,p_attribute_category   => v_ud_loc.attribute_category
           ,p_attribute1           => v_ud_loc.attribute1
           ,p_attribute2           => v_ud_loc.attribute2
           ,p_attribute3           => v_ud_loc.attribute3
           ,p_attribute4           => v_ud_loc.attribute4
           ,p_attribute5           => v_ud_loc.attribute5
           ,p_attribute6           => v_ud_loc.attribute6
           ,p_attribute7           => v_ud_loc.attribute7
           ,p_attribute8           => v_ud_loc.attribute8
           ,p_attribute9           => v_ud_loc.attribute9
           ,p_attribute10          => v_ud_loc.attribute10
           ,p_attribute11          => v_ud_loc.attribute11
           ,p_attribute12          => v_ud_loc.attribute12
           ,p_attribute13          => v_ud_loc.attribute13
           ,p_attribute14          => v_ud_loc.attribute14
           ,p_attribute15          => v_ud_loc.attribute15
           ,p_attribute16          => v_ud_loc.attribute16
           ,p_attribute17          => v_ud_loc.attribute17
           ,p_attribute18          => v_ud_loc.attribute18
           ,p_attribute19          => v_ud_loc.attribute19
           ,p_attribute20          => v_ud_loc.attribute20
           ,p_business_group_id    => hr_h2pi_upload.g_to_business_group_id
           ,p_location_id	   => l_location_id
           ,p_object_version_number=> l_ovn);

        hr_h2pi_map.create_id_mapping
                          (p_table_name => 'HR_LOCATIONS_ALL',
                           p_from_id    => v_ud_loc.location_id,
                           p_to_id      => l_location_id);
      ELSE
        BEGIN
          hr_utility.set_location(l_proc, 40);
          SELECT loc.object_version_number
          INTO   l_ovn
          FROM   hr_locations_all loc
          WHERE  loc.location_id = l_location_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          hr_utility.set_location(l_proc, 50);
          RAISE MAPPING_ID_INVALID;
        END;

        hr_utility.set_location(l_proc, 60);
        hr_location_api.update_location
           (p_validate	           => FALSE
           ,p_effective_date       => SYSDATE
           ,p_location_id          => l_location_id
           ,p_object_version_number=> l_ovn
           ,p_location_code        => v_ud_loc.location_code
           ,p_description          => v_ud_loc.description
           ,p_address_line_1       => v_ud_loc.address_line_1
           ,p_address_line_2       => v_ud_loc.address_line_2
           ,p_address_line_3       => v_ud_loc.address_line_3
           ,p_town_or_city         => v_ud_loc.town_or_city
           ,p_country              => v_ud_loc.country
           ,p_inactive_date        => v_ud_loc.inactive_date
           ,p_postal_code	   => v_ud_loc.postal_code
           ,p_region_1	           => v_ud_loc.region_1
           ,p_region_2	           => v_ud_loc.region_2
           ,p_region_3	           => v_ud_loc.region_3
           ,p_style	           => v_ud_loc.style
           ,p_telephone_number_1   => v_ud_loc.telephone_number_1
           ,p_telephone_number_2   => v_ud_loc.telephone_number_2
           ,p_telephone_number_3   => v_ud_loc.telephone_number_3
           ,p_loc_information13    => v_ud_loc.loc_information13
           ,p_loc_information14    => v_ud_loc.loc_information14
           ,p_loc_information15    => v_ud_loc.loc_information15
           ,p_loc_information16    => v_ud_loc.loc_information16
           ,p_loc_information17    => v_ud_loc.loc_information17
           ,p_loc_information18    => v_ud_loc.loc_information18
           ,p_loc_information19    => v_ud_loc.loc_information19
           ,p_loc_information20    => v_ud_loc.loc_information20
           ,p_attribute_category   => v_ud_loc.attribute_category
  	   ,p_attribute1           => v_ud_loc.attribute1
  	   ,p_attribute2           => v_ud_loc.attribute2
  	   ,p_attribute3           => v_ud_loc.attribute3
  	   ,p_attribute4           => v_ud_loc.attribute4
  	   ,p_attribute5           => v_ud_loc.attribute5
  	   ,p_attribute6           => v_ud_loc.attribute6
  	   ,p_attribute7           => v_ud_loc.attribute7
  	   ,p_attribute8           => v_ud_loc.attribute8
  	   ,p_attribute9           => v_ud_loc.attribute9
  	   ,p_attribute10          => v_ud_loc.attribute10
  	   ,p_attribute11          => v_ud_loc.attribute11
  	   ,p_attribute12          => v_ud_loc.attribute12
  	   ,p_attribute13          => v_ud_loc.attribute13
  	   ,p_attribute14          => v_ud_loc.attribute14
  	   ,p_attribute15          => v_ud_loc.attribute15
  	   ,p_attribute16          => v_ud_loc.attribute16
  	   ,p_attribute17          => v_ud_loc.attribute17
  	   ,p_attribute18          => v_ud_loc.attribute18
  	   ,p_attribute19          => v_ud_loc.attribute19
           ,p_attribute20          => v_ud_loc.attribute20
           );

      END IF;

      hr_utility.set_location(l_proc, 70);
      UPDATE hr_h2pi_locations
      SET status = 'C'
      WHERE  location_id = v_ud_loc.location_id
      AND    client_id   = p_from_client_id;

      COMMIT;

    EXCEPTION
      WHEN MAPPING_ID_INVALID THEN
        ROLLBACK;
        hr_utility.set_location(l_proc, 80);
        hr_h2pi_error.data_error
                   (p_from_id       => l_location_id,
                    p_table_name    => 'HR_H2PI_LOCATIONS',
                    p_message_level => 'FATAL',
                    p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
      WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
        ROLLBACK;
        hr_utility.set_location(l_proc, 90);
        l_encoded_message := fnd_message.get_encoded;
        hr_h2pi_error.data_error
                   (p_from_id              => v_ud_loc.location_id,
                    p_table_name           => 'HR_H2PI_LOCATIONS',
                    p_message_level        => 'FATAL',
                    p_message_text         => l_encoded_message);
    END;

  END LOOP;

  hr_utility.set_location('Leaving:'|| l_proc, 100);
  COMMIT;

END;



PROCEDURE upload_hr_organization (p_from_client_id NUMBER) AS

CURSOR csr_orgs (p_bg_id NUMBER) IS
  SELECT DISTINCT organization_id,
         hr_h2pi_bg_upload.org_exists(p_from_client_id,organization_id, 1) hr_org,
         hr_h2pi_bg_upload.org_exists(p_from_client_id,organization_id, 2) class,
         hr_h2pi_bg_upload.org_exists(p_from_client_id,organization_id, 3) info
  FROM   hr_h2pi_hr_organizations
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
  UNION
  SELECT DISTINCT organization_id,
         hr_h2pi_bg_upload.org_exists(p_from_client_id,organization_id, 1) hr_org,
         hr_h2pi_bg_upload.org_exists(p_from_client_id,organization_id, 2) class,
         hr_h2pi_bg_upload.org_exists(p_from_client_id,organization_id, 3) info
  FROM   hr_h2pi_organization_class
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
  UNION
  SELECT DISTINCT organization_id,
         hr_h2pi_bg_upload.org_exists(p_from_client_id,organization_id, 1) hr_org,
         hr_h2pi_bg_upload.org_exists(p_from_client_id,organization_id, 2) class,
         hr_h2pi_bg_upload.org_exists(p_from_client_id,organization_id, 3) info
  FROM   hr_h2pi_organization_info
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
  ORDER BY organization_id;

CURSOR csr_hr_org(p_org_id NUMBER) IS
  SELECT DISTINCT *
  FROM   hr_h2pi_hr_organizations
  WHERE  organization_id = p_org_id
  AND   (status IS NULL OR status <> 'C')
  AND   client_id = p_from_client_id;

CURSOR csr_hr_org_class(p_org_id NUMBER) IS
  SELECT DISTINCT *
  FROM   hr_h2pi_organization_class
  WHERE  organization_id = p_org_id
  AND   (status IS NULL OR status <> 'C')
  AND   client_id = p_from_client_id;

CURSOR csr_hr_org_info(p_org_id NUMBER) IS
  SELECT DISTINCT *
  FROM   hr_h2pi_organization_info
  WHERE  organization_id = p_org_id
  AND    (status IS NULL OR status <> 'C')
  AND   client_id = p_from_client_id;

--
CURSOR csr_session_date is
  SELECT effective_date
  FROM   fnd_sessions
  WHERE  session_id = userenv('sessionid');
--
v_ud_hr_org       hr_h2pi_hr_organizations%ROWTYPE;
l_hr_org_id       hr_all_organization_units.organization_id%TYPE := NULL;
l_hr_org_class_id hr_organization_information.org_information_id%TYPE := NULL;
l_hr_org_info_id  hr_organization_information.org_information_id%TYPE := NULL;
l_location_id     hr_all_organization_units.location_id%TYPE;
l_encoded_message VARCHAR2(200);
l_org_info2       VARCHAR2(150);
l_ovn             NUMBER(9);
l_session_date    DATE;

l_org_info1       hr_h2pi_organization_info.org_information1%TYPE;
l_org_info8       hr_h2pi_organization_info.org_information8%TYPE;
l_org_info9       hr_h2pi_organization_info.org_information9%TYPE;
l_org_info10      hr_h2pi_organization_info.org_information10%TYPE;
l_org_info12      hr_h2pi_organization_info.org_information12%TYPE;
l_org_info13      hr_h2pi_organization_info.org_information13%TYPE;

l_proc            VARCHAR2(72) := g_package||'upload_hr_organization';

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

   -- Insert fnd_sessions row
  OPEN csr_session_date;
  hr_utility.set_location(l_proc, 11);
  FETCH csr_session_date into l_session_date;
  hr_utility.set_location(l_proc, 12);
  IF csr_session_date%notfound then
    hr_utility.set_location(l_proc, 13);
    insert into fnd_sessions (SESSION_ID, EFFECTIVE_DATE)
      values(userenv('sessionid'), trunc(SYSDATE));
    hr_utility.set_location(l_proc, 14);
    hr_utility.set_location(l_proc || ': ' || userenv('sessionid'), 15);
  END IF;
  CLOSE csr_session_date;
  --

  FOR v_ud_org IN csr_orgs(p_from_client_id) LOOP

    hr_utility.set_location(l_proc, 20);
    SAVEPOINT hr_org_start;

    BEGIN
      IF v_ud_org.hr_org = 1 THEN

        l_hr_org_id := NULL;
        hr_utility.set_location(l_proc, 30);
        OPEN   csr_hr_org(v_ud_org.organization_id);
        FETCH  csr_hr_org INTO  v_ud_hr_org;
        CLOSE  csr_hr_org;

        hr_utility.set_location(l_proc, 40);
        l_location_id := hr_h2pi_map.get_to_id
                        (p_table_name        => 'HR_LOCATIONS_ALL',
                         p_from_id           => v_ud_hr_org.location_id,
                         p_report_error      => TRUE);

        l_hr_org_id := hr_h2pi_map.get_to_id
                        (p_table_name        => 'HR_ALL_ORGANIZATION_UNITS',
                         p_from_id           => v_ud_hr_org.organization_id);

        hr_utility.set_location(l_proc, 50);
        IF l_hr_org_id = -1 THEN
          hr_utility.set_location(l_proc, 60);
          hr_organization_api.create_organization
           (p_effective_date         => SYSDATE
           ,p_business_group_id      => hr_h2pi_upload.g_to_business_group_id
           ,p_date_from              => v_ud_hr_org.date_from
           ,p_date_to                => v_ud_hr_org.date_to
           ,p_name                   => v_ud_hr_org.name
           ,p_location_id            => l_location_id
           ,p_internal_external_flag => v_ud_hr_org.internal_external_flag
           ,p_attribute_category     => v_ud_hr_org.attribute_category
           ,p_attribute1             => v_ud_hr_org.attribute1
           ,p_attribute2             => v_ud_hr_org.attribute2
           ,p_attribute3             => v_ud_hr_org.attribute3
           ,p_attribute4             => v_ud_hr_org.attribute4
           ,p_attribute5             => v_ud_hr_org.attribute5
           ,p_attribute6             => v_ud_hr_org.attribute6
           ,p_attribute7             => v_ud_hr_org.attribute7
           ,p_attribute8             => v_ud_hr_org.attribute8
           ,p_attribute9             => v_ud_hr_org.attribute9
           ,p_attribute10            => v_ud_hr_org.attribute10
           ,p_attribute11            => v_ud_hr_org.attribute11
           ,p_attribute12            => v_ud_hr_org.attribute12
           ,p_attribute13            => v_ud_hr_org.attribute13
           ,p_attribute14            => v_ud_hr_org.attribute14
           ,p_attribute15            => v_ud_hr_org.attribute15
           ,p_attribute16            => v_ud_hr_org.attribute16
           ,p_attribute17            => v_ud_hr_org.attribute17
           ,p_attribute18            => v_ud_hr_org.attribute18
           ,p_attribute19            => v_ud_hr_org.attribute19
           ,p_attribute20            => v_ud_hr_org.attribute20
           ,p_organization_id        => l_hr_org_id
           ,p_object_version_number  => l_ovn
           );

          hr_h2pi_map.create_id_mapping
                          (p_table_name => 'HR_ALL_ORGANIZATION_UNITS',
                           p_from_id    => v_ud_hr_org.organization_id,
                           p_to_id      => l_hr_org_id);
        ELSE
          hr_utility.set_location(l_proc, 70);
          BEGIN
            SELECT org.object_version_number
            INTO   l_ovn
            FROM   hr_all_organization_units org
            WHERE  org.organization_id = l_hr_org_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
            hr_utility.set_location(l_proc, 75);
            ROLLBACK;
            hr_h2pi_error.data_error
               (p_from_id       => l_hr_org_class_id,
                p_table_name    => 'HR_H2PI_ORGANIZATION_CLASS',
                p_message_level => 'FATAL',
                p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
            RAISE MAPPING_ID_INVALID;
          END;

          hr_utility.set_location(l_proc, 80);
          hr_organization_api.update_organization
           (p_effective_date       => SYSDATE
           ,p_organization_id      => l_hr_org_id
           ,p_date_from            => v_ud_hr_org.date_from
           ,p_date_to              => v_ud_hr_org.date_to
           ,p_location_id          => l_location_id
           ,p_attribute_category   => v_ud_hr_org.attribute_category
           ,p_attribute1           => v_ud_hr_org.attribute1
           ,p_attribute2           => v_ud_hr_org.attribute2
           ,p_attribute3           => v_ud_hr_org.attribute3
           ,p_attribute4           => v_ud_hr_org.attribute4
           ,p_attribute5           => v_ud_hr_org.attribute5
           ,p_attribute6           => v_ud_hr_org.attribute6
           ,p_attribute7           => v_ud_hr_org.attribute7
           ,p_attribute8           => v_ud_hr_org.attribute8
           ,p_attribute9           => v_ud_hr_org.attribute9
           ,p_attribute10          => v_ud_hr_org.attribute10
           ,p_attribute11          => v_ud_hr_org.attribute11
           ,p_attribute12          => v_ud_hr_org.attribute12
           ,p_attribute13          => v_ud_hr_org.attribute13
           ,p_attribute14          => v_ud_hr_org.attribute14
           ,p_attribute15          => v_ud_hr_org.attribute15
           ,p_attribute16          => v_ud_hr_org.attribute16
           ,p_attribute17          => v_ud_hr_org.attribute17
           ,p_attribute18          => v_ud_hr_org.attribute18
           ,p_attribute19          => v_ud_hr_org.attribute19
           ,p_attribute20          => v_ud_hr_org.attribute20
           ,p_object_version_number=> l_ovn
           );

        END IF;

        hr_utility.set_location(l_proc, 90);
        UPDATE hr_h2pi_hr_organizations
        SET status = 'C'
        WHERE  organization_id = v_ud_hr_org.organization_id
        AND    client_id   = p_from_client_id;

      ELSE

        hr_utility.set_location(l_proc, 94);
        l_hr_org_id := hr_h2pi_map.get_to_id
                        (p_table_name        => 'HR_ALL_ORGANIZATION_UNITS',
                         p_from_id           => v_ud_org.organization_id,
                         p_report_error      => TRUE);

      END IF;

      IF v_ud_org.class = 1 THEN
        FOR v_ud_hr_org_class IN csr_hr_org_class(v_ud_org.organization_id)
        LOOP

          BEGIN
            hr_utility.set_location(l_proc, 100);
            l_hr_org_class_id := hr_h2pi_map.get_to_id
                       (p_table_name => 'HR_ORGANIZATION_INFORMATION',
                        p_from_id   => v_ud_hr_org_class.org_information_id);

            hr_utility.set_location(l_proc, 110);
            IF l_hr_org_class_id = -1 THEN
              hr_utility.set_location(l_proc, 120);
              hr_organization_api.create_org_classification
               (p_effective_date       => SYSDATE
               ,p_organization_id      => l_hr_org_id
               ,p_org_classif_code     => v_ud_hr_org_class.org_information1
               ,p_org_information_id   => l_hr_org_class_id
               ,p_object_version_number=> l_ovn
               );

              hr_h2pi_map.create_id_mapping
                     (p_table_name => 'HR_ORGANIZATION_INFORMATION',
                      p_from_id    => v_ud_hr_org_class.org_information_id,
                      p_to_id      => l_hr_org_class_id);
            END IF;

            hr_utility.set_location(l_proc, 130);
            hr_utility.set_location(l_proc, l_hr_org_class_id);
            BEGIN
              SELECT org_information2,
                     object_version_number
              INTO   l_org_info2,
                     l_ovn
              FROM   hr_organization_information
            WHERE  org_information_id = l_hr_org_class_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              hr_utility.set_location(l_proc, 135);
              ROLLBACK;
              hr_h2pi_error.data_error
                 (p_from_id       => l_hr_org_class_id,
                  p_table_name    => 'HR_H2PI_ORGANIZATION_CLASS',
                  p_message_level => 'FATAL',
                  p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
              RAISE MAPPING_ID_INVALID;
            END;

            hr_utility.set_location(l_proc, 140);
            IF v_ud_hr_org_class.org_information2 = 'N' AND
               l_org_info2 = 'Y' THEN
              hr_utility.set_location(l_proc, 150);
              hr_organization_api.disable_org_classification
               (p_effective_date        => SYSDATE
               ,p_org_information_id    => l_hr_org_class_id
               ,p_org_info_type_code    => 'CLASS'
               ,p_object_version_number => l_ovn
               );
            ELSIF v_ud_hr_org_class.org_information2 = 'Y' AND
                l_org_info2 = 'N' THEN
              hr_utility.set_location(l_proc, 160);
              hr_organization_api.enable_org_classification
               (p_effective_date        => SYSDATE
               ,p_org_information_id    => l_hr_org_class_id
               ,p_org_info_type_code    => 'CLASS'
               ,p_object_version_number => l_ovn
               );
            END IF;

            UPDATE hr_h2pi_organization_class
            SET status = 'C'
            WHERE  org_information_id = v_ud_hr_org_class.org_information_id
            AND    client_id  = p_from_client_id;
            hr_utility.set_location(l_proc, 170);

          EXCEPTION
            WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
            hr_utility.set_location(l_proc, 180);
            l_encoded_message := fnd_message.get_encoded;
            hr_h2pi_error.data_error
                 (p_from_id        => v_ud_hr_org_class.org_information_id,
                  p_table_name     => 'HR_H2PI_ORGANIZATION_CLASS',
                  p_message_level  => 'FATAL',
                  p_message_text   => l_encoded_message);
          END;

        END LOOP;

      END IF;

      IF v_ud_org.info = 1 THEN

        FOR v_ud_hr_org_info in csr_hr_org_info(v_ud_org.organization_id)LOOP

          BEGIN
            hr_utility.set_location(l_proc, 190);
            l_hr_org_info_id := hr_h2pi_map.get_to_id
                       (p_table_name => 'HR_ORGANIZATION_INFORMATION',
                        p_from_id    => v_ud_hr_org_info.org_information_id);

            hr_utility.set_location(l_proc, 200);

            -- set values from uploaded org info table
            l_org_info1   := v_ud_hr_org_info.org_information1;
            l_org_info8   := v_ud_hr_org_info.org_information8;
            l_org_info9   := v_ud_hr_org_info.org_information9;
            l_org_info10  := v_ud_hr_org_info.org_information10;
            l_org_info12  := v_ud_hr_org_info.org_information12;
            l_org_info13  := v_ud_hr_org_info.org_information13;

            hr_utility.set_location(l_proc, 210);

            /* Added to take care for value set IDs in org additional info */
            IF v_ud_hr_org_info.org_information_context = 'SQWL GN Transmitter Rules' THEN
               -- for MMREF Contact Name
               hr_utility.trace('Found : ' || v_ud_hr_org_info.org_information_context);
               IF v_ud_hr_org_info.org_information12 IS NOT NULL THEN
                 hr_utility.set_location(l_proc, 220);
                 l_org_info12 := hr_h2pi_map.get_to_id
                      (p_table_name        => 'PER_ALL_PEOPLE_F',
                       p_from_id           => v_ud_hr_org_info.org_information12);
                 hr_utility.set_location(l_proc, 220);
                 IF l_org_info12 = -1 THEN
                   hr_utility.trace(v_ud_hr_org_info.org_information_context || ':' ||
                                    'ORG_INFORMATION12'|| ':' ||
                                    v_ud_hr_org_info.org_information12 || ':' ||
                                    'is unsupported');

                   l_org_info12 := NULL;
                 END IF;
               ELSE
                 l_org_info12 := v_ud_hr_org_info.org_information12;
               END IF;
               -- for Company Name
               IF v_ud_hr_org_info.org_information13 IS NOT NULL THEN
                 hr_utility.set_location(l_proc, 260);
                 l_org_info13 := hr_h2pi_map.get_to_id
                      (p_table_name        => 'HR_ALL_ORGANIZATION_UNITS',
                       p_from_id           =>v_ud_hr_org_info.org_information13);
               ELSE
                 l_org_info13 := v_ud_hr_org_info.org_information13;
               END IF;
            ElSIF v_ud_hr_org_info.org_information_context = 'State Tax Rules' THEN
               -- for WC Carrier Name
               hr_utility.trace('Found : ' || v_ud_hr_org_info.org_information_context);
               IF v_ud_hr_org_info.org_information8 IS NOT NULL THEN
                 l_org_info8 := hr_h2pi_map.get_to_id
                      (p_table_name        => 'HR_ALL_ORGANIZATION_UNITS',
                       p_from_id           => v_ud_hr_org_info.org_information8);
               ELSE
                 l_org_info8 := v_ud_hr_org_info.org_information8;
               END IF;
            ELSIF v_ud_hr_org_info.org_information_context = 'W2 Reporting Rules' THEN
               -- for Company Name
               hr_utility.trace('Found : ' || v_ud_hr_org_info.org_information_context);
               IF v_ud_hr_org_info.org_information9 IS NOT NULL THEN
                 hr_utility.set_location(l_proc, 270);
                 l_org_info9 := hr_h2pi_map.get_to_id
                      (p_table_name        => 'HR_ALL_ORGANIZATION_UNITS',
                       p_from_id           =>v_ud_hr_org_info.org_information9);
               ELSE
                 l_org_info9 := v_ud_hr_org_info.org_information9;
               END IF;
               -- for Contact Name
               IF v_ud_hr_org_info.org_information10 IS NOT NULL THEN
                 l_org_info10 := hr_h2pi_map.get_to_id
                      (p_table_name        => 'PER_ALL_PEOPLE_F',
                       p_from_id           => v_ud_hr_org_info.org_information10);
                 IF l_org_info10 = -1 THEN
                   hr_utility.trace(v_ud_hr_org_info.org_information_context || ':' ||
                                    'ORG_INFORMATION10' || ':' ||
                                    v_ud_hr_org_info.org_information10 || ':' ||
                                    'is unsupported');
                   l_org_info10 := NULL;
                 END IF;
                ELSE
                  l_org_info10 := v_ud_hr_org_info.org_information10;
                END IF;
              ELSIF v_ud_hr_org_info.org_information_context = 'Work Schedule' THEN
               -- for Schedule Table
               hr_utility.trace('Found : ' || v_ud_hr_org_info.org_information_context);
               IF v_ud_hr_org_info.org_information1 IS NOT NULL THEN
                 hr_utility.set_location(l_proc, 210);
                 l_org_info1 := hr_h2pi_map.get_to_id
                      (p_table_name        => 'COMPANY_WORK_SCHEDULE',
                       p_from_id           => v_ud_hr_org_info.org_information1);
                 IF l_org_info10 = -1 THEN
                   hr_utility.trace(v_ud_hr_org_info.org_information_context || ':' ||
                                    'ORG_INFORMATION1' || ':' ||
                                    v_ud_hr_org_info.org_information1 || ':' ||
                                    'is unsupported');
                   l_org_info1 := NULL;
                 END IF;
               ELSE
                 l_org_info1 := v_ud_hr_org_info.org_information1;
               END IF;
            ELSE
              Null;
            END IF;

            IF l_hr_org_info_id = -1 THEN
              hr_utility.set_location(l_proc, 210);

              hr_organization_api.create_org_information
               (p_effective_date      => SYSDATE
               ,p_organization_id     => l_hr_org_id
               ,p_org_info_type_code
                               => v_ud_hr_org_info.org_information_context
               ,p_org_information1    => l_org_info1
               ,p_org_information2    => v_ud_hr_org_info.org_information2
               ,p_org_information3    => v_ud_hr_org_info.org_information3
               ,p_org_information4    => v_ud_hr_org_info.org_information4
               ,p_org_information5    => v_ud_hr_org_info.org_information5
               ,p_org_information6    => v_ud_hr_org_info.org_information6
               ,p_org_information7    => v_ud_hr_org_info.org_information7
               ,p_org_information8    => l_org_info8
               ,p_org_information9    => l_org_info9
               ,p_org_information10   => l_org_info10
               ,p_org_information11   => v_ud_hr_org_info.org_information11
               ,p_org_information12   => l_org_info12
               ,p_org_information13   => l_org_info13
               ,p_org_information14   => v_ud_hr_org_info.org_information14
               ,p_org_information15   => v_ud_hr_org_info.org_information15
               ,p_org_information16   => v_ud_hr_org_info.org_information16
               ,p_org_information17   => v_ud_hr_org_info.org_information17
               ,p_org_information18   => v_ud_hr_org_info.org_information18
               ,p_org_information19   => v_ud_hr_org_info.org_information19
               ,p_org_information20   => v_ud_hr_org_info.org_information20
               ,p_org_information_id  => l_hr_org_info_id
               ,p_object_version_number=> l_ovn
               );

              hr_h2pi_map.create_id_mapping
                     (p_table_name => 'HR_ORGANIZATION_INFORMATION',
                      p_from_id    => v_ud_hr_org_info.org_information_id,
                      p_to_id      => l_hr_org_info_id);
            ELSE

              hr_utility.set_location(l_proc, 220);
              hr_utility.set_location(l_proc, l_hr_org_info_id);
              BEGIN
                SELECT org_information2,
                       object_version_number
                INTO   l_org_info2,
                       l_ovn
                FROM   hr_organization_information
                WHERE  org_information_id = l_hr_org_info_id;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                hr_utility.set_location(l_proc, 50);
                ROLLBACK;
                hr_h2pi_error.data_error
                   (p_from_id       => l_hr_org_info_id,
                    p_table_name    => 'HR_H2PI_ORGANIZATION_INFO',
                    p_message_level => 'FATAL',
                    p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
                RAISE MAPPING_ID_INVALID;
              END;

              hr_utility.set_location(l_proc, 230);
              hr_organization_api.update_org_information
               (p_effective_date      => SYSDATE
               ,p_org_info_type_code
                               => v_ud_hr_org_info.org_information_context
               ,p_org_information1    => l_org_info1
               ,p_org_information2    => v_ud_hr_org_info.org_information2
               ,p_org_information3    => v_ud_hr_org_info.org_information3
               ,p_org_information4    => v_ud_hr_org_info.org_information4
               ,p_org_information5    => v_ud_hr_org_info.org_information5
               ,p_org_information6    => v_ud_hr_org_info.org_information6
               ,p_org_information7    => v_ud_hr_org_info.org_information7
               ,p_org_information8    => l_org_info8
               ,p_org_information9    => l_org_info9
               ,p_org_information10   => l_org_info10
               ,p_org_information11   => v_ud_hr_org_info.org_information11
               ,p_org_information12   => l_org_info12
               ,p_org_information13   => l_org_info13
               ,p_org_information14   => v_ud_hr_org_info.org_information14
               ,p_org_information15   => v_ud_hr_org_info.org_information15
               ,p_org_information16   => v_ud_hr_org_info.org_information16
               ,p_org_information17   => v_ud_hr_org_info.org_information17
               ,p_org_information18   => v_ud_hr_org_info.org_information18
               ,p_org_information19   => v_ud_hr_org_info.org_information19
               ,p_org_information20   => v_ud_hr_org_info.org_information20
               ,p_org_information_id  => l_hr_org_info_id
               ,p_object_version_number=> l_ovn
               );
            END IF;


            UPDATE hr_h2pi_organization_info
            SET status = 'C'
            WHERE  org_information_id = v_ud_hr_org_info.org_information_id
            AND    client_id  = p_from_client_id;
            hr_utility.set_location(l_proc, 240);

          EXCEPTION
              WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
              hr_utility.set_location(l_proc, 250);
              l_encoded_message := fnd_message.get_encoded;
              hr_h2pi_error.data_error
                   (p_from_id       => v_ud_hr_org_info.org_information_id,
                    p_table_name    => 'HR_H2PI_ORGANIZATION_INFO',
                    p_message_level => 'FATAL',
                    p_message_text  => l_encoded_message);
          END;

        END LOOP;

      END IF;

      hr_utility.set_location(l_proc, 260);
      COMMIT;

    EXCEPTION
      WHEN MAPPING_ID_INVALID THEN
        hr_utility.set_location(l_proc, 270);
      WHEN MAPPING_ID_MISSING THEN
        hr_utility.set_location(l_proc, 280);
      WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
        ROLLBACK;
        hr_utility.set_location(l_proc, 290);
        l_encoded_message := fnd_message.get_encoded;
        hr_h2pi_error.data_error
                   (p_from_id              => v_ud_hr_org.organization_id,
                    p_table_name           => 'HR_H2PI_HR_ORGANIZATIONS',
                    p_message_level        => 'FATAL',
                    p_message_text         => l_encoded_message);
    END;

  END LOOP;

  hr_utility.set_location('Leaving:'|| l_proc, 10);
  COMMIT;


END;


PROCEDURE upload_element_type (p_from_client_id NUMBER) AS

CURSOR csr_ele_names (p_bg_id NUMBER) IS
  SELECT *
  FROM   hr_h2pi_element_names
  WHERE  client_id = p_bg_id
  AND   (status IS NULL OR status <> 'C');

l_ud_ele_name  hr_h2pi_element_names%ROWTYPE;
l_ele_type_id  pay_element_types_f.element_type_id%TYPE;
l_element_name pay_element_types_f.element_name%TYPE;
l_encoded_message VARCHAR2(200);
l_ovn          NUMBER(9);

l_proc         VARCHAR2(72) := g_package||'upload_element_name';

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  FOR v_ud_ele_name in csr_ele_names(p_from_client_id) LOOP

    hr_utility.set_location(l_proc, 20);
    SAVEPOINT hr_ele_name_start;

    BEGIN
      hr_utility.set_location(l_proc, 30);
      l_ele_type_id := hr_h2pi_map.get_to_id
                          (p_table_name    => 'PAY_ELEMENT_TYPES_F',
                           p_from_id       => v_ud_ele_name.element_type_id,
                           p_report_error  => TRUE);

      hr_utility.set_location(l_proc, 50);
      SELECT elt.element_name
      INTO   l_element_name
      FROM   pay_element_types_f elt
      WHERE  elt.element_type_id = l_ele_type_id
      AND    SYSDATE BETWEEN elt.effective_start_date
                         AND elt.effective_end_date;

      hr_utility.set_location(l_proc, 60);
/*
      pay_element_types_pkg.translate_row
            (x_e_element_name     => l_element_name
            ,x_e_legislation_code => 'US'--hr_h2pi_upload.g_legislation_code
            ,x_e_effective_start_date => SYSDATE
            ,x_e_effective_end_date   => SYSDATE
            ,x_element_name       => v_ud_ele_name.element_name
            ,x_reporting_name     => v_ud_ele_name.reporting_name
            ,x_description        => NULL
            ,x_owner              => 'OWNER'
            ,x_business_group_id  => hr_h2pi_upload.g_to_business_group_id);
*/

      UPDATE hr_h2pi_element_names
      SET status = 'C'
      WHERE  element_type_id = v_ud_ele_name.element_type_id
      AND    client_id  = p_from_client_id;

      hr_utility.set_location(l_proc, 70);
      COMMIT;

    EXCEPTION
      WHEN MAPPING_ID_MISSING THEN
      hr_utility.set_location(l_proc, 80);
      WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
      ROLLBACK;
      hr_utility.set_location(l_proc, 90);
      l_encoded_message := fnd_message.get_encoded;
      hr_h2pi_error.data_error
                   (p_from_id              => v_ud_ele_name.element_type_id,
                    p_table_name           => 'HR_H2PI_ELEMENT_NAME',
                    p_message_level        => 'FATAL',
                    p_message_text         => l_encoded_message);
    END;

  END LOOP;

  hr_utility.set_location('Leaving:'|| l_proc, 100);
  COMMIT;

END;

FUNCTION  org_exists (p_from_client_id NUMBER,
                      p_org_id NUMBER,
                      p_table  NUMBER) RETURN NUMBER IS

l_proc  VARCHAR2(72) := g_package||'org_exists';

CURSOR csr_hr_org (p_id NUMBER) IS
  SELECT 1
  FROM   hr_h2pi_hr_organizations
  WHERE  organization_id = p_id
  AND   (status IS NULL OR status <> 'C')
  AND   client_id = p_from_client_id;
CURSOR csr_class (p_id NUMBER) IS
  SELECT 1
  FROM   hr_h2pi_organization_class
  WHERE  organization_id = p_id
  AND   (status IS NULL OR status <> 'C')
  AND   client_id = p_from_client_id;
CURSOR csr_info (p_id NUMBER) IS
  SELECT 1
  FROM   hr_h2pi_organization_info
  WHERE  organization_id = p_id
  AND   (status IS NULL OR status <> 'C')
  AND   client_id = p_from_client_id;

l_dummy NUMBER;
l_retval NUMBER := 0;

BEGIN

  IF p_table = 1 THEN
    OPEN csr_hr_org(p_org_id);
    FETCH csr_hr_org INTO l_dummy;
    IF csr_hr_org%FOUND THEN
      l_retval := 1;
    END IF;
    CLOSE csr_hr_org;
  ELSIF p_table = 2 THEN
    OPEN csr_class(p_org_id);
    FETCH csr_class INTO l_dummy;
    IF csr_class%FOUND THEN
      l_retval := 1;
    END IF;
    CLOSE csr_class;
  ELSIF p_table = 3 THEN
    OPEN csr_info(p_org_id);
    FETCH csr_info INTO l_dummy;
    IF csr_info%FOUND THEN
      l_retval := 1;
    END IF;
    CLOSE csr_info;
  END IF;

  RETURN l_retval;

END;

END hr_h2pi_bg_upload;

/
