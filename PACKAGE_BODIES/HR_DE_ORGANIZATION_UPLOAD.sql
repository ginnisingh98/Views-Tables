--------------------------------------------------------
--  DDL for Package Body HR_DE_ORGANIZATION_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_ORGANIZATION_UPLOAD" AS
 /* $Header: pedeoupl.pkb 115.3 2003/05/21 16:56:26 pkakar noship $ */
 --
 --
 -- Cursor to return tax office definitions.
 --
 CURSOR c_tax_office_defs
 (p_bundesland VARCHAR2) IS
   SELECT hr_general.decode_lookup('DE_FED_STATE', bundesland) bundesland_description
         ,bundesland
         ,tax_office_no
         ,tax_office_name
   FROM   hr_de_tax_office_definition_v
   WHERE  bundesland = NVL(p_bundesland, bundesland)
   ORDER BY hr_general.decode_lookup('DE_FED_STATE', bundesland) ASC;
 --
 --
 -- Cursor to return social insurance provider definitions.
 --
 CURSOR c_soc_ins_prov_defs
 (p_provider_type VARCHAR2) IS
   SELECT provider_name
         ,hr_general.decode_lookup('DE_ORG_UPLOAD_PROV_TYPES', provider_type) provider_type_description
         ,provider_type
         ,health_insurance_type
         ,LPAD(east_betriebesnumber, 8, '0') east_betriebesnumber
         ,LPAD(west_betriebesnumber, 8, '0') west_betriebesnumber
         ,pension_insurance_type
   FROM   hr_de_socins_prov_definition_v
   WHERE  provider_type = NVL(p_provider_type, provider_type)
   ORDER BY hr_general.decode_lookup('DE_ORG_UPLOAD_PROV_TYPES', provider_type);
 --
 --
 -- Cursor to return organization information.
 --
 CURSOR c_org_info
 (p_business_group_id NUMBER
 ,p_organization_name VARCHAR2) IS
   SELECT organization_id
         ,object_version_number
   FROM   hr_all_organization_units
   WHERE  business_group_id = p_business_group_id
     AND  name              = p_organization_name;
 --
 --
 -- Cursor to return organization classifications.
 --
 CURSOR c_org_class
 (p_organization_id NUMBER) IS
   SELECT org_information2 || ':' || org_information1 value
   FROM   hr_organization_information
   WHERE  organization_id = p_organization_id;
 --
 --
 -- Cursor to return tax office information.
 --
 CURSOR c_tax_office_info
 (p_business_group_id NUMBER
 ,p_tax_office_no     VARCHAR2) IS
   SELECT o.organization_id
         ,o.name
   FROM   hr_all_organization_units   o
         ,hr_organization_information i
   WHERE  o.business_group_id       = p_business_group_id
     AND  i.organization_id         = o.organization_id
     AND  i.org_information_context = 'DE_TAX_OFFICE_INFO'
     AND  i.org_information1        = p_tax_office_no;
 --
 --
 -- Cursor to return mandatory health provider information.
 --
 CURSOR c_mand_health_prov_info
 (p_business_group_id   NUMBER
 ,p_east_betriebsnummer VARCHAR2
 ,p_west_betriebsnummer VARCHAR2) IS
   SELECT o.organization_id
         ,o.name
   FROM   hr_all_organization_units   o
         ,hr_organization_information i
   WHERE  o.business_group_id       = p_business_group_id
     AND  i.organization_id         = o.organization_id
     AND  i.org_information_context = 'DE_SOCIAL_INSURANCE_INFO'
     AND  (i.org_information1 = p_west_betriebsnummer OR i.org_information2 = p_east_betriebsnummer);
 --
 --
 -- Cursor to return business group information.
 --
 CURSOR c_bg_info
 (p_business_group_id NUMBER) IS
   SELECT *
   FROM   per_business_groups
   WHERE  business_group_id = p_business_group_id;
 --
 --
 -- Table Definitions.
 --
 TYPE t_tax_office_list       IS TABLE OF c_tax_office_info%ROWTYPE       INDEX BY BINARY_INTEGER;
 TYPE t_mand_health_prov_list IS TABLE OF c_mand_health_prov_info%ROWTYPE INDEX BY BINARY_INTEGER;
 --
 --
 -- --------------------------------------------------------------------------
 -- Service function to decode avalue i.e. based on the expression return one
 -- of two possible values.
 -- --------------------------------------------------------------------------
 --
 FUNCTION local_decode
 (p_expr        BOOLEAN
 ,p_true_value  VARCHAR2
 ,p_false_value VARCHAR2) RETURN VARCHAR2 IS
 BEGIN
   IF p_expr THEN
     RETURN p_true_value;
   ELSE
     RETURN p_false_value;
   END IF;
 END local_decode;
 --
 --
 -- --------------------------------------------------------------------------
 -- Service function to return information for an organization.
 --
 -- This returns the following ...
 --
 -- 1. organization_id
 -- 2. list of organization classifications for the organization
 -- --------------------------------------------------------------------------
 --
 PROCEDURE org_info
 (p_business_group_id         NUMBER
 ,p_organization_name         VARCHAR2
 ,o_organization_id       OUT NOCOPY NUMBER
 ,o_classification_list   OUT NOCOPY VARCHAR2) IS
   --
   --
   -- Local variables.
   --
   l_classification_list VARCHAR2(2000) := '';
   l_org_rec             c_org_info%ROWTYPE;
 BEGIN
   --
   --
   -- See if the organization exists.
   --
   OPEN  c_org_info(p_business_group_id => p_business_group_id, p_organization_name => p_organization_name);
   FETCH c_org_info INTO l_org_rec;
   CLOSE c_org_info;
   --
   --
   -- Organization exsists so build up a list of its classifications.
   --
   IF l_org_rec.organization_id IS NOT NULL THEN
     FOR l_class_rec IN c_org_class(p_organization_id => l_org_rec.organization_id) LOOP
       l_classification_list := l_classification_list || l_class_rec.value || ':';
     END LOOP;
   END IF;
   --
   --
   -- Pass back the information.
   --
   o_organization_id     := l_org_rec.organization_id;
   o_classification_list := l_classification_list;
 END org_info;
 --
 --
 -- --------------------------------------------------------------------------
 -- Service function to return information for a tax office.
 --
 -- This returns a list of organization_id / organization name pairs in a table.
 -- --------------------------------------------------------------------------
 --
 PROCEDURE tax_office_info
 (p_business_group_id     NUMBER
 ,p_tax_office_no         VARCHAR2
 ,o_tax_office_list   OUT NOCOPY t_tax_office_list) IS
   --
   --
   -- Local variables.
   --
   l_tax_office_list t_tax_office_list;
   l_index           NUMBER := 1;
   l_tax_office_rec  c_tax_office_info%ROWTYPE;
 BEGIN
   --
   --
   -- Find first matching tax office.
   --
   OPEN c_tax_office_info
     (p_business_group_id => p_business_group_id
     ,p_tax_office_no     => p_tax_office_no);
   FETCH c_tax_office_info INTO l_tax_office_rec;
   --
   --
   -- Loop for all matching tax offices.
   --
   WHILE c_tax_office_info%FOUND LOOP
     l_tax_office_list(l_index) := l_tax_office_rec;
     FETCH c_tax_office_info INTO l_tax_office_rec;
     l_index  := l_index + 1;
   END LOOP;
   --
   --
   -- All matching tax offices have been found so close the cursor.
   --
   CLOSE c_tax_office_info;
   --
   --
   -- Return matching list of tax offices.
   --
   o_tax_office_list := l_tax_office_list;
 END tax_office_info;
 --
 --
 -- --------------------------------------------------------------------------
 -- Service function to return information for a mandatory health provider.
 --
 -- This returns a list of organization_id / organization name pairs in a table.
 -- --------------------------------------------------------------------------
 --
 PROCEDURE mand_health_info
 (p_business_group_id         NUMBER
 ,p_east_betriebsnummer       VARCHAR2
 ,p_west_betriebsnummer       VARCHAR2
 ,o_mand_health_prov_list OUT NOCOPY t_mand_health_prov_list) IS
   --
   --
   -- Local variables.
   --
   l_mand_health_prov_list t_mand_health_prov_list;
   l_index                 NUMBER := 1;
   l_mand_health_prov_rec  c_mand_health_prov_info%ROWTYPE;
 BEGIN
   --
   --
   -- Find first matching mandatory health provider.
   --
   OPEN c_mand_health_prov_info
     (p_business_group_id   => p_business_group_id
     ,p_east_betriebsnummer => p_east_betriebsnummer
     ,p_west_betriebsnummer => p_west_betriebsnummer);
   FETCH c_mand_health_prov_info INTO l_mand_health_prov_rec;
   --
   --
   -- Loop for all matching mandatory health providers.
   --
   WHILE c_mand_health_prov_info%FOUND LOOP
     l_mand_health_prov_list(l_index) := l_mand_health_prov_rec;
     FETCH c_mand_health_prov_info INTO l_mand_health_prov_rec;
     l_index  := l_index + 1;
   END LOOP;
   --
   --
   -- All matching mandatory health providers have been found so close the cursor.
   --
   CLOSE c_mand_health_prov_info;
   --
   --
   -- Return matching list of mandatory health providers.
   --
   o_mand_health_prov_list := l_mand_health_prov_list;
 END mand_health_info;
 --
 --
 --
 -- --------------------------------------------------------------------------
 -- Service function to create a new tax office.
 --
 -- This involves the following sequence ...
 --
 -- 1. Create an organization.
 -- 2. Classify it as a tax office.
 -- 3. Add tax office specifc information e.g. tax office number.
 -- --------------------------------------------------------------------------
 --
 PROCEDURE create_tax_office
 (p_effective_date    DATE
 ,p_business_group_id NUMBER
 ,p_date_from         DATE
 ,p_bundesland        VARCHAR2
 ,p_tax_office_no     VARCHAR2
 ,p_tax_office_name   VARCHAR2) IS
   --
   --
   -- Local Variables.
   --
   l_organization_id       NUMBER;
   l_org_information_id    NUMBER;
   l_object_version_number NUMBER;
 BEGIN
   --
   --
   -- Create basic organization definition.
   --
   hr_organization_api.create_organization
     (p_validate              => false
     ,p_effective_date        => p_effective_date
     ,p_language_code         => 'US'
     ,p_date_from             => p_date_from
     ,p_business_group_id     => p_business_group_id
     ,p_name                  => p_tax_office_name
     ,p_organization_id       => l_organization_id
     ,p_object_version_number => l_object_version_number);
   --
   --
   -- Classify the organization as a tax office.
   --
   hr_organization_api.create_org_class_internal
     (p_validate         => false
     ,p_effective_date   => p_effective_date
     ,p_organization_id  => l_organization_id
     ,p_org_classif_code => 'DE_TAX_OFFICE'
     ,p_org_information_id => l_org_information_id
     ,p_object_version_number => l_object_version_number
    );
   --
   --
   -- Add extra organization information.
   --
   hr_organization_api.create_org_information
     (p_validate              => false
     ,p_effective_date        => p_effective_date
     ,p_organization_id       => l_organization_id
     ,p_org_info_type_code    => 'DE_TAX_OFFICE_INFO'
     ,p_org_information1      => p_tax_office_no
     ,p_org_information2      => p_bundesland
     ,p_org_information_id    => l_org_information_id
     ,p_object_version_number => l_object_version_number);
 END create_tax_office;
 --
 --
 -- --------------------------------------------------------------------------
 -- Service function to create a new social insurance provider.
 --
 -- This involves the following sequence ...
 --
 -- 1. Create an organization.
 -- 2. Classify it as tthe correct social insurance provider type.
 -- 3. Add social insurance provider specifc information e.g. east
 --    betriebesnumber.
 -- --------------------------------------------------------------------------
 --
 PROCEDURE create_soc_ins_provider
 (p_effective_date         DATE
 ,p_business_group_id      NUMBER
 ,p_date_from              DATE
 ,p_provider_name          VARCHAR2
 ,p_provider_type          VARCHAR2
 ,p_health_insurance_type  VARCHAR2
 ,p_east_betriebesnumber   VARCHAR2
 ,p_west_betriebesnumber   VARCHAR2
 ,p_pension_insurance_type VARCHAR2) IS
   --
   --
   -- Local Variables.
   --
   l_organization_id       NUMBER;
   l_org_information_id    NUMBER;
   l_object_version_number NUMBER;
 BEGIN
   --
   --
   -- Create basic organization definition.
   --
   hr_organization_api.create_organization
     (p_validate              => false
     ,p_effective_date        => p_effective_date
     ,p_language_code         => 'US'
     ,p_business_group_id     => p_business_group_id
     ,p_date_from             => p_date_from
     ,p_name                  => p_provider_name
     ,p_organization_id       => l_organization_id
     ,p_object_version_number => l_object_version_number);
   --
   --
   -- Classify the organization as a social insurance
   -- provider of type p_provider_type.
   --
   hr_organization_api.create_org_classification
     (p_validate              => false
     ,p_effective_date        => p_effective_date
     ,p_organization_id       => l_organization_id
     ,p_org_classif_code      => p_provider_type
     ,p_org_information_id    => l_org_information_id
     ,p_object_version_number => l_object_version_number);
   --
   --
   -- Add extra organization information.
   --
   hr_organization_api.create_org_information
     (p_validate              => false
     ,p_effective_date        => p_effective_date
     ,p_organization_id       => l_organization_id
     ,p_org_info_type_code    => 'DE_SOCIAL_INSURANCE_INFO'
     ,p_org_information1      => LOCAL_DECODE(p_provider_type = 'DE_MAN_HEALTH_PROV'
                                             ,p_west_betriebesnumber, NULL)
     ,p_org_information2      => LOCAL_DECODE(p_provider_type = 'DE_MAN_HEALTH_PROV'
                                             ,p_east_betriebesnumber, NULL)
     ,p_org_information3      => LOCAL_DECODE(p_provider_type = 'DE_MAN_HEALTH_PROV'
                                             ,p_health_insurance_type, NULL)
     ,p_org_information4      => LOCAL_DECODE(p_provider_type = 'DE_MAN_PENSION_PROV'
                                             ,p_pension_insurance_type, NULL)
     ,p_org_information_id    => l_org_information_id
     ,p_object_version_number => l_object_version_number);
 END create_soc_ins_provider;
 --
 --
 -- --------------------------------------------------------------------------
 -- Service function to process a tax office.
 -- --------------------------------------------------------------------------
 --
 PROCEDURE process_tax_office
 (p_upload_mode    VARCHAR2
 ,p_effective_date DATE
 ,p_bg_rec         c_bg_info%ROWTYPE
 ,p_tax_office_rec c_tax_office_defs%ROWTYPE) IS
   --
   --
   -- Local Variables.
   --
   l_org_id          NUMBER;
   l_org_name        VARCHAR2(60);
   l_org_class_list  VARCHAR2(2000);
   l_tax_office_list t_tax_office_list;
 BEGIN
   --
   --
   -- Write out header line for the tax office e.g.
   --
   -- Bundesland              : <>
   -- Tax Office Name         : <>
   -- Tax Office Code         : <>
   --
   fnd_file.put_line(fnd_file.output, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'BUNDESLAND'), 30, ' ')
                                      || ': ' || p_tax_office_rec.bundesland_description);
   fnd_file.put_line(fnd_file.output, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'TAX_OFFICE_NAME'), 30, ' ')
                                      || ': ' || p_tax_office_rec.tax_office_name);
   fnd_file.put_line(fnd_file.output, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'TAX_OFFICE_CODE'), 30, ' ')
                                      || ': ' || NVL(p_tax_office_rec.tax_office_no, ' '));
   fnd_file.put_line(fnd_file.output, ' ');
   --
   --
   -- See if the tax office already exists (by searching by tax office no).
   --
   tax_office_info
     (p_business_group_id => p_bg_rec.business_group_id
     ,p_tax_office_no     => p_tax_office_rec.tax_office_no
     ,o_tax_office_list   => l_tax_office_list);
   --
   --
   -- At least one tax office exists based on tax office code.
   --
   IF l_tax_office_list.COUNT > 0 THEN
     --
     --
     -- Loop for all matching tax offices.
     --
     FOR l_loop_index IN l_tax_office_list.FIRST..l_tax_office_list.LAST LOOP
       --
       --
       -- Names matches.
       --
       IF l_tax_office_list(l_loop_index).name = p_tax_office_rec.tax_office_name THEN
         --
         --
         -- Write out status line e.g. Tax office already exists.
         --
         fnd_message.set_name('PER', 'HR_DE_TAX_OFFICE_EXISTS');
         fnd_file.put_line(fnd_file.output, fnd_message.get);
         fnd_file.put_line(fnd_file.output, '');
       --
       --
       -- Name does not match.
       --
       ELSE
         --
         --
         -- Write out status line e.g.
         --
         -- The tax office <> already exists with this tax office code.
         --
         fnd_message.set_name('PER', 'HR_DE_TAX_OFFICE_CODE_MATCHES');
         fnd_message.set_token('NAME', l_tax_office_list(l_loop_index).name);
         fnd_file.put_line(fnd_file.output, fnd_message.get);
         fnd_file.put_line(fnd_file.output, '');
       END IF;
     END LOOP;
   END IF;
   --
   --
   -- No matching organization has been found yet.
   --
   IF l_tax_office_list.COUNT = 0 THEN
     --
     --
     -- See if an organization with the same name already exists.
     --
     org_info
       (p_business_group_id   => p_bg_rec.business_group_id
       ,p_organization_name   => p_tax_office_rec.tax_office_name
       ,o_organization_id     => l_org_id
       ,o_classification_list => l_org_class_list);
     --
     --
     -- Organization exists based on the tax office name.
     --
     IF l_org_id IS NOT NULL THEN
       --
       --
       -- Organization is a tax office.
       --
       IF INSTR(l_org_class_list, 'DE_TAX_OFFICE') > 0 THEN
         --
         --
         -- Write out status line e.g.
         --
         -- A tax office with this name already exists but the tax office
         -- code does not match.
         --
         fnd_message.set_name('PER', 'HR_DE_TAX_OFFICE_NAME_MATCHES');
         fnd_file.put_line(fnd_file.output, fnd_message.get);
         fnd_file.put_line(fnd_file.output, '');
       --
       --
       -- Organization is not a tax office.
       --
       ELSE
         --
         --
         -- Write out status line e.g.
         --
         -- An organization with this name already exists but it is not a tax office
         --
         fnd_message.set_name('PER', 'HR_DE_NOT_A_TAX_OFFICE');
         fnd_file.put_line(fnd_file.output, fnd_message.get);
         fnd_file.put_line(fnd_file.output, '');
       END IF;
     END IF;
   END IF;
   --
   --
   -- No matching organization has been found yet.
   --
   IF l_tax_office_list.COUNT = 0 AND l_org_id IS NULL THEN
     --
     --
     -- Running in merge mode so create new tax office.
     --
     IF p_upload_mode = 'MERGE' THEN
       --
       --
       -- Tax office does not exist so create it.
       --
       create_tax_office
         (p_effective_date    => p_effective_date
         ,p_business_group_id => p_bg_rec.business_group_id
         ,p_date_from         => p_bg_rec.date_from
         ,p_bundesland        => p_tax_office_rec.bundesland
         ,p_tax_office_no     => p_tax_office_rec.tax_office_no
         ,p_tax_office_name   => p_tax_office_rec.tax_office_name);
       --
       --
       -- Write out status line e.g. Tax office has been created.
       --
       fnd_message.set_name('PER', 'HR_DE_TAX_OFFICE_CREATED');
       fnd_file.put_line(fnd_file.output, fnd_message.get);
       fnd_file.put_line(fnd_file.output, '');
     --
     --
     -- Running in analyse mode so only report the fact that the
     -- tax office will be created.
     --
     ELSE
       --
       --
       -- Write out status line e.g. Tax office can been created.
       --
       fnd_message.set_name('PER', 'HR_DE_TAX_OFFICE_POSSIBLE');
       fnd_file.put_line(fnd_file.output, fnd_message.get);
       fnd_file.put_line(fnd_file.output, '');
     END IF;
   END IF;
 END process_tax_office;
 --
 --
 -- --------------------------------------------------------------------------
 -- Service function to process a social insurance provider.
 -- --------------------------------------------------------------------------
 --
 PROCEDURE process_soc_ins_provider
 (p_upload_mode      VARCHAR2
 ,p_effective_date   DATE
 ,p_bg_rec           c_bg_info%ROWTYPE
 ,p_soc_ins_prov_rec c_soc_ins_prov_defs%ROWTYPE) IS
   --
   --
   -- Local Variables.
   --
   l_org_id         NUMBER;
   l_org_name       VARCHAR2(60);
   l_org_class_list VARCHAR2(2000);
 BEGIN
   --
   --
   -- Write out header line for the social insurance provider e.g.
   --
   -- Provider Type           : <>
   -- Provider Name           : <>
   --
   fnd_file.put_line(fnd_file.output, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'PROV_TYPE'), 30, ' ')
                                      || ': ' || p_soc_ins_prov_rec.provider_type_description);
   fnd_file.put_line(fnd_file.output, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'PROV_NAME'), 30, ' ')
                                      || ': ' || p_soc_ins_prov_rec.provider_name);
   fnd_file.put_line(fnd_file.output, ' ');
   --
   --
   -- See if an organization with the same name already exists.
   --
   org_info
     (p_business_group_id   => p_bg_rec.business_group_id
     ,p_organization_name   => p_soc_ins_prov_rec.provider_name
     ,o_organization_id     => l_org_id
     ,o_classification_list => l_org_class_list);
   --
   --
   -- Organization exists based on the social insurance provider name.
   --
   IF l_org_id IS NOT NULL THEN
     --
     --
     -- Organization is a social insurance provider of the correct type.
     --
     IF INSTR(l_org_class_list, p_soc_ins_prov_rec.provider_type) > 0 THEN
       --
       --
       -- Write out status line e.g. The social insurance provider already exists.
       --
       fnd_message.set_name('PER', 'HR_DE_SOCINS_PROV_EXISTS');
       fnd_file.put_line(fnd_file.output, fnd_message.get);
       fnd_file.put_line(fnd_file.output, '');
     --
     --
     -- Organization is not a social insurance provider of this type.
     --
     ELSE
       --
       --
       -- Write out status line e.g. An organization with this name already exists but it is not a <>.
       --
       fnd_message.set_name('PER', 'HR_DE_NOT_A_SOCINS_PROV');
       fnd_message.set_token('TYPE', p_soc_ins_prov_rec.provider_type_description);
       fnd_file.put_line(fnd_file.output, fnd_message.get);
       fnd_file.put_line(fnd_file.output, '');
     END IF;
   END IF;
   --
   --
   -- No matching organization has been found yet.
   --
   IF l_org_id IS NULL THEN
     --
     --
     -- Running in merge mode so create new social insurance provider.
     --
     IF p_upload_mode = 'MERGE' THEN
       --
       --
       -- Social insurance provider does not exist so create it.
       --
       create_soc_ins_provider
         (p_effective_date         => p_effective_date
         ,p_business_group_id      => p_bg_rec.business_group_id
         ,p_date_from              => p_bg_rec.date_from
         ,p_provider_name          => p_soc_ins_prov_rec.provider_name
         ,p_provider_type          => p_soc_ins_prov_rec.provider_type
         ,p_health_insurance_type  => p_soc_ins_prov_rec.health_insurance_type
         ,p_east_betriebesnumber   => p_soc_ins_prov_rec.east_betriebesnumber
         ,p_west_betriebesnumber   => p_soc_ins_prov_rec.west_betriebesnumber
         ,p_pension_insurance_type => p_soc_ins_prov_rec.pension_insurance_type);
       --
       --
       -- Write out status line e.g. Social insurance provider has been created.
       --
       fnd_message.set_name('PER', 'HR_DE_SOCINS_PROV_CREATED');
       fnd_file.put_line(fnd_file.output, fnd_message.get);
       fnd_file.put_line(fnd_file.output, '');
     --
     --
     -- Running in analyse mode so only report the fact that the
     -- social insurance provider will be created.
     --
     ELSE
       --
       --
       -- Write out status line e.g. Social insurance provider can been created.
       --
       fnd_message.set_name('PER', 'HR_DE_SOCINS_PROV_POSSIBLE');
       fnd_file.put_line(fnd_file.output, fnd_message.get);
       fnd_file.put_line(fnd_file.output, '');
     END IF;
   END IF;
 END process_soc_ins_provider;
 --
 --
 -- --------------------------------------------------------------------------
 -- Service function to process a mandatoru health provider.
 -- --------------------------------------------------------------------------
 --
 PROCEDURE process_mand_health_provider
 (p_upload_mode      VARCHAR2
 ,p_effective_date   DATE
 ,p_bg_rec           c_bg_info%ROWTYPE
 ,p_soc_ins_prov_rec c_soc_ins_prov_defs%ROWTYPE) IS
   --
   --
   -- Local Variables.
   --
   l_org_id                NUMBER;
   l_org_name              VARCHAR2(60);
   l_org_class_list        VARCHAR2(2000);
   l_mand_health_prov_list t_mand_health_prov_list;
 BEGIN
   --
   --
   -- Write out header line for the mandatory health provider e.g.
   --
   -- Provider Type           : <>
   -- Provider Name           : <>
   -- East Betriebsnummer     : <>
   -- West Betriebsnummer     : <>
   --
   fnd_file.put_line(fnd_file.output, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'PROV_TYPE'), 30, ' ')
                                      || ': ' || p_soc_ins_prov_rec.provider_type_description);
   fnd_file.put_line(fnd_file.output, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'PROV_NAME'), 30, ' ')
                                      || ': ' || p_soc_ins_prov_rec.provider_name);
   fnd_file.put_line(fnd_file.output, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'EAST_BETRIEBS'), 30, ' ')
                                      || ': ' || NVL(p_soc_ins_prov_rec.east_betriebesnumber, ' '));
   fnd_file.put_line(fnd_file.output, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'WEST_BETRIEBS'), 30, ' ')
                                      || ': ' || NVL(p_soc_ins_prov_rec.west_betriebesnumber, ' '));
   fnd_file.put_line(fnd_file.output, ' ');
   --
   --
   -- See if the mandatory health provider already exists (by searching by east
   -- and west betriebsnummer).
   --
   mand_health_info
     (p_business_group_id     => p_bg_rec.business_group_id
     ,p_east_betriebsnummer   => p_soc_ins_prov_rec.east_betriebesnumber
     ,p_west_betriebsnummer   => p_soc_ins_prov_rec.west_betriebesnumber
     ,o_mand_health_prov_list => l_mand_health_prov_list);
   --
   --
   -- At least one manadatory health provider exists (searching by betriebsnummers).
   --
   IF l_mand_health_prov_list.COUNT > 0 THEN
     --
     --
     -- Loop for all mandatory health providers.
     --
     FOR l_loop_index IN l_mand_health_prov_list.FIRST..l_mand_health_prov_list.LAST LOOP
       --
       --
       -- Names matches.
       --
       IF l_mand_health_prov_list(l_loop_index).name = p_soc_ins_prov_rec.provider_name THEN
         --
         --
         -- Write out status line e.g. Social insurance provider already exists.
         --
         fnd_message.set_name('PER', 'HR_DE_SOCINS_PROV_EXISTS');
         fnd_file.put_line(fnd_file.output, fnd_message.get);
         fnd_file.put_line(fnd_file.output, '');
       --
       --
       -- Name does not match.
       --
       ELSE
         --
         --
         -- Write out status line e.g.
         --
         -- The social insurance provider <> already exists with these betriebsnummers.
         --
         fnd_message.set_name('PER', 'HR_DE_SOCINS_BETRIEBS_MATCHES');
         fnd_message.set_token('NAME', l_mand_health_prov_list(l_loop_index).name);
         fnd_file.put_line(fnd_file.output, fnd_message.get);
         fnd_file.put_line(fnd_file.output, '');
       END IF;
     END LOOP;
   END IF;
   --
   --
   -- No matching organization has been found yet.
   --
   IF l_mand_health_prov_list.COUNT = 0 THEN
     --
     --
     -- See if an organization with the same name already exists.
     --
     org_info
       (p_business_group_id   => p_bg_rec.business_group_id
       ,p_organization_name   => p_soc_ins_prov_rec.provider_name
       ,o_organization_id     => l_org_id
       ,o_classification_list => l_org_class_list);
     --
     --
     -- Organization exists based on the mandatory health provider name.
     --
     IF l_org_id IS NOT NULL THEN
       --
       --
       -- Organization is a mandatory health provider.
       --
       IF INSTR(l_org_class_list, 'DE_MAN_HEALTH_PROV') > 0 THEN
         --
         --
         -- Write out status line e.g.
         --
         -- A social insurance provider with this name already exists but the east
         -- and west betriebsnummers do not match.
         --
         fnd_message.set_name('PER', 'HR_DE_SOCINS_NAME_MATCHES');
         fnd_file.put_line(fnd_file.output, fnd_message.get);
         fnd_file.put_line(fnd_file.output, '');
       --
       --
       -- Organization is not a mandatory health provider.
       --
       ELSE
         --
         --
         -- Write out status line e.g. An organization with this name already exists but it is not a <>.
         --
         fnd_message.set_name('PER', 'HR_DE_NOT_A_SOCINS_PROV');
         fnd_message.set_token('TYPE', p_soc_ins_prov_rec.provider_type_description);
         fnd_file.put_line(fnd_file.output, fnd_message.get);
         fnd_file.put_line(fnd_file.output, '');
       END IF;
     END IF;
   END IF;
   --
   --
   -- No matching organization has been found yet.
   --
   IF l_mand_health_prov_list.COUNT = 0 AND l_org_id IS NULL THEN
     --
     --
     -- Running in merge mode so create new mandatory health provider.
     --
     IF p_upload_mode = 'MERGE' THEN
       --
       --
       -- Mandatory health provider does not exist so create it.
       --
       create_soc_ins_provider
         (p_effective_date         => p_effective_date
         ,p_business_group_id      => p_bg_rec.business_group_id
         ,p_date_from              => p_bg_rec.date_from
         ,p_provider_name          => p_soc_ins_prov_rec.provider_name
         ,p_provider_type          => p_soc_ins_prov_rec.provider_type
         ,p_health_insurance_type  => p_soc_ins_prov_rec.health_insurance_type
         ,p_east_betriebesnumber   => p_soc_ins_prov_rec.east_betriebesnumber
         ,p_west_betriebesnumber   => p_soc_ins_prov_rec.west_betriebesnumber
         ,p_pension_insurance_type => p_soc_ins_prov_rec.pension_insurance_type);
       --
       --
       -- Write out status line e.g. Social insurance provider has been created.
       --
       fnd_message.set_name('PER', 'HR_DE_SOCINS_PROV_CREATED');
       fnd_file.put_line(fnd_file.output, fnd_message.get);
       fnd_file.put_line(fnd_file.output, '');
     --
     --
     -- Running in analyse mode so only report the fact that the
     -- social insurance provider will be created.
     --
     ELSE
       --
       --
       -- Write out status line e.g. Social insurance provider can been created.
       --
       fnd_message.set_name('PER', 'HR_DE_SOCINS_PROV_POSSIBLE');
       fnd_file.put_line(fnd_file.output, fnd_message.get);
       fnd_file.put_line(fnd_file.output, '');
     END IF;
   END IF;
 END process_mand_health_provider;
 --
 --
 -- --------------------------------------------------------------------------
 -- This uploads the definitions for tax offices as organizations in the HRMS
 -- system.
 --
 -- The definitions for the tax offices are held in a user table named
 -- HR_DE_TAX_OFFICE_DEFINITION which can be seen by using a view named
 -- HR_DE_TAX_DEFINITION_V.
 --
 -- The parameters are defined as follows...
 --
 -- p_business_group_id: the business group for which this upload is being run.
 -- p_effective_date   : the date on which the changes are made.
 -- p_upload_mode      : the mode is either 'Merge' or 'Analyse' (see below for
 --                      details).
 -- p_bundesland       : can be used to identify a subset of the tax offices
 --                      NB. leaving this blank means load all tax offices.
 --
 -- The mode of 'Merge' only adds tax offices that do not already exist, while
 -- 'Analyse' produces a summary of what would happen if 'Merge' was used.
 -- --------------------------------------------------------------------------
 --
 PROCEDURE upload_tax_offices
 (errbuf              OUT NOCOPY VARCHAR2
 ,retcode             OUT NOCOPY NUMBER
 ,p_business_group_id     NUMBER
 ,p_effective_date        VARCHAR2
 ,p_upload_mode           VARCHAR2
 ,p_bundesland            VARCHAR2) IS
   --
   --
   -- Local variables.
   --
   l_bg_rec         c_bg_info%ROWTYPE;
   l_tax_office_rec c_tax_office_defs%ROWTYPE;
   l_effective_date DATE := fnd_date.canonical_to_date(p_effective_date);
 BEGIN
   --
   --
   -- Setup up session date.
   --
   INSERT INTO fnd_sessions
   (session_id
   ,effective_date)
   VALUES
   (userenv('sessionid')
   ,l_effective_date);
   --
   --
   -- Get information for the business group.
   --
   OPEN  c_bg_info(p_business_group_id => p_business_group_id);
   FETCH c_bg_info INTO l_bg_rec;
   CLOSE c_bg_info;
   --
   --
   -- Write heading for output file.
   --
   fnd_file.put_line(fnd_file.output, ' ');
   fnd_file.put_line(fnd_file.output, LPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'TAX_OFFICE_UPLOAD'), 41, ' '));
   fnd_file.put_line(fnd_file.output, ' ');
   fnd_file.put_line(fnd_file.output, LPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'UPLOAD_MODE'), 29, ' ') || ' : '
                                      || hr_general.decode_lookup('DE_ORG_UPLOAD_MODE', p_upload_mode));
   fnd_file.put_line(fnd_file.output, LPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'BUNDESLAND'), 29, ' ') || ' : '
                                      || LOCAL_DECODE(p_bundesland IS NOT NULL
                                                     ,hr_general.decode_lookup('DE_FED_STATE', p_bundesland)
                                                     ,hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'ALL')));
   fnd_file.put_line(fnd_file.output, ' ');
   fnd_file.put_line(fnd_file.output, ' ');
   --
   --
   -- Fetch the first tax office definition.
   --
   OPEN  c_tax_office_defs(p_bundesland => p_bundesland);
   FETCH c_tax_office_defs INTO l_tax_office_rec;
   --
   --
   -- Loop for all tax office definitions.
   --
   WHILE c_tax_office_defs%FOUND LOOP
     --
     --
     -- Process the tax office.
     --
     process_tax_office
       (p_upload_mode    => p_upload_mode
       ,p_effective_date => l_effective_date
       ,p_bg_rec         => l_bg_rec
       ,p_tax_office_rec => l_tax_office_rec);
     --
     --
     -- Fetch the next tax office definition.
     --
     FETCH c_tax_office_defs INTO l_tax_office_rec;
   END LOOP;
   --
   --
   -- All tax office definitions have been found.
   --
   CLOSE c_tax_office_defs;
   --
   --
   -- Make the changes permanent.
   --
   COMMIT;
   --
   --
   -- Return success.
   --
   errbuf  := NULL;
   retcode := 0;
 EXCEPTION
   WHEN OTHERS THEN
     --
     --
     -- Write out header line for the tax office e.g.
     --
     -- Bundesland              : <>
     -- Tax Office Name         : <>
     -- Tax Office Code         : <>
     --
     fnd_file.put_line(fnd_file.output, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'BUNDESLAND'), 30, ' ')
                                        || ': ' || l_tax_office_rec.bundesland_description);
     fnd_file.put_line(fnd_file.output, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'TAX_OFFICE_NAME'), 30, ' ')
                                        || ': ' || l_tax_office_rec.tax_office_name);
     fnd_file.put_line(fnd_file.output, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'TAX_OFFICE_CODE'), 30, ' ')
                                        || ': ' || NVL(l_tax_office_rec.tax_office_no, ' '));
     fnd_file.put_line(fnd_file.output, ' ');
     --
     --
     -- Output the error that was raised.
     --
     fnd_file.put_line(fnd_file.log, SQLERRM);
     fnd_file.put_line(fnd_file.log, '');
     --
     --
     -- Close the cursor.
     --
     CLOSE c_tax_office_defs;
     --
     --
     -- Undo the changes.
     --
     ROLLBACK;
     --
     --
     -- Return the unexpected error.
     --
     errbuf  := NULL;
     retcode := 2;
 END upload_tax_offices;
 --
 --
 -- --------------------------------------------------------------------------
 -- This uploads the definitions for social insurance providers as organizations
 -- in the HRMS system.
 --
 -- The definitions for the social insurance providers are held in a user table
 -- named HR_DE_SOC_INS_PROV_DEFINITION which can be seen by using a view named
 -- HR_DE_SOCINS_PROV_DEFINITION_V.
 --
 -- The parameters are defined as follows...
 --
 -- p_business_group_id: the business group for which this upload is being run.
 -- p_effective_date   : the date on which the changes are made.
 -- p_upload_mode      : the mode is either 'Merge' or 'Analyse' (see below for
 --                      details).
 -- p_provider_type    : can be used to identify a subset of the social insurance
 --                      providers e.g. mandatory health providers, mandatory
 --                      pension providers, etc.
 --
 -- The mode of 'Merge' only adds social insurance providers that do not already
 -- exist, while 'Analyse' produces a summary of what would happen if 'Merge'
 -- was used.
 -- --------------------------------------------------------------------------
 --
 PROCEDURE upload_soc_ins_providers
 (errbuf              OUT NOCOPY VARCHAR2
 ,retcode             OUT NOCOPY NUMBER
 ,p_business_group_id     NUMBER
 ,p_effective_date        VARCHAR2
 ,p_upload_mode           VARCHAR2
 ,p_provider_type         VARCHAR2) IS
   --
   --
   -- Local variables.
   --
   l_bg_rec           c_bg_info%ROWTYPE;
   l_soc_ins_prov_rec c_soc_ins_prov_defs%ROWTYPE;
   l_effective_date   DATE := fnd_date.canonical_to_date(p_effective_date);
 BEGIN
   --
   --
   -- Setup up session date.
   --
   INSERT INTO fnd_sessions
   (session_id
   ,effective_date)
   VALUES
   (userenv('sessionid')
   ,l_effective_date);
   --
   --
   -- Get information for the business group.
   --
   OPEN  c_bg_info(p_business_group_id => p_business_group_id);
   FETCH c_bg_info INTO l_bg_rec;
   CLOSE c_bg_info;
   --
   --
   -- Write heading for output file.
   --
   fnd_file.put_line(fnd_file.output, ' ');
   fnd_file.put_line(fnd_file.output, LPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'SOCINS_PROV_UPLOAD'), 47, ' '));
   fnd_file.put_line(fnd_file.output, ' ');
   fnd_file.put_line(fnd_file.output, LPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'UPLOAD_MODE'), 29, ' ') || ' : '
                                      || hr_general.decode_lookup('DE_ORG_UPLOAD_MODE', p_upload_mode));
   fnd_file.put_line(fnd_file.output, LPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'PROV_TYPE'), 29, ' ') || ' : '
                                      || LOCAL_DECODE(p_provider_type IS NOT NULL
                                                     ,hr_general.decode_lookup('DE_ORG_UPLOAD_PROV_TYPES', p_provider_type)
                                                     ,hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'ALL')));
   fnd_file.put_line(fnd_file.output, ' ');
   fnd_file.put_line(fnd_file.output, ' ');
   --
   --
   -- Fetch the first social insurance provider definition.
   --
   OPEN  c_soc_ins_prov_defs(p_provider_type => p_provider_type);
   FETCH c_soc_ins_prov_defs INTO l_soc_ins_prov_rec;
   --
   --
   -- Loop for all social insrance provider definitions.
   --
   WHILE c_soc_ins_prov_defs%FOUND LOOP
     --
     --
     -- Process the social insurance provider NB. the processing is split
     -- into two with one focussed on mandatory health providers as their
     -- processing is more complex while all others can be processed in
     -- the same way.
     --
     IF l_soc_ins_prov_rec.provider_type = 'DE_MAN_HEALTH_PROV' THEN
       process_mand_health_provider
         (p_upload_mode      => p_upload_mode
         ,p_effective_date   => l_effective_date
         ,p_bg_rec           => l_bg_rec
         ,p_soc_ins_prov_rec => l_soc_ins_prov_rec);
     ELSE
       process_soc_ins_provider
         (p_upload_mode      => p_upload_mode
         ,p_effective_date   => l_effective_date
         ,p_bg_rec           => l_bg_rec
         ,p_soc_ins_prov_rec => l_soc_ins_prov_rec);
     END IF;
     --
     --
     -- Fetch the next social insurance provider definition.
     --
     FETCH c_soc_ins_prov_defs INTO l_soc_ins_prov_rec;
   END LOOP;
   --
   --
   -- All social insrance provider definitions have been found.
   --
   CLOSE c_soc_ins_prov_defs;
   --
   --
   -- Make the changes permanent.
   --
   COMMIT;
   --
   --
   -- Return success.
   --
   errbuf  := NULL;
   retcode := 0;
 EXCEPTION
   WHEN OTHERS THEN
     --
     --
     -- Output details of the current record that is being processed to aid debugging.
     --
     IF l_soc_ins_prov_rec.provider_type = 'DE_MAN_HEALTH_PROV' THEN
       --
       --
       -- Write out header line for the mandatory health provider e.g.
       --
       -- Provider Type           : <>
       -- Provider Name           : <>
       -- East Betriebsnummer     : <>
       -- West Betriebsnummer     : <>
       --
       fnd_file.put_line(fnd_file.log, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'PROV_TYPE'), 30, ' ')
                                       || ': ' || l_soc_ins_prov_rec.provider_type_description);
       fnd_file.put_line(fnd_file.log, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'PROV_NAME'), 30, ' ')
                                       || ': ' || l_soc_ins_prov_rec.provider_name);
       fnd_file.put_line(fnd_file.log, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'EAST_BETRIEBS'), 30, ' ')
                                       || ': ' || NVL(l_soc_ins_prov_rec.east_betriebesnumber, ' '));
       fnd_file.put_line(fnd_file.log, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'WEST_BETRIEBS'), 30, ' ')
                                       || ': ' || NVL(l_soc_ins_prov_rec.west_betriebesnumber, ' '));
       fnd_file.put_line(fnd_file.log, ' ');
     ELSE
       --
       --
       -- Write out header line for the social insurance provider e.g.
       --
       -- Provider Type           : <>
       -- Provider Name           : <>
       --
       fnd_file.put_line(fnd_file.log, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'PROV_TYPE'), 30, ' ')
                                       || ': ' || l_soc_ins_prov_rec.provider_type_description);
       fnd_file.put_line(fnd_file.log, RPAD(hr_general.decode_lookup('DE_ORG_UPLOAD_LABELS', 'PROV_NAME'), 30, ' ')
                                       || ': ' || l_soc_ins_prov_rec.provider_name);
       fnd_file.put_line(fnd_file.output, ' ');
     END IF;
     --
     --
     -- Output the error that was raised.
     --
     fnd_file.put_line(fnd_file.log, SQLERRM);
     fnd_file.put_line(fnd_file.log, '');
     --
     --
     -- Close the cursor.
     --
     CLOSE c_soc_ins_prov_defs;
     --
     --
     -- Undo the changes.
     --
     ROLLBACK;
     --
     --
     -- Return the unexpected error.
     --
     errbuf  := NULL;
     retcode := 2;
 END upload_soc_ins_providers;
END hr_de_organization_upload;

/
