--------------------------------------------------------
--  DDL for Package Body HR_BPL_ALERT_ADDRESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BPL_ALERT_ADDRESS" AS
/* $Header: perbaadr.pkb 120.1 2006/01/06 08:06:15 adhunter noship $ */
--
-- -----------------------------------------------------------------------------
-- Format the output address
-- -----------------------------------------------------------------------------
--
PROCEDURE format_address(p_component_string IN VARCHAR2)
   IS
BEGIN
  --
  IF p_component_string IS NOT NULL AND g_addr_address IS NOT NULL THEN
    --
    g_addr_address := g_addr_address || ', ' || p_component_string;
    --
  ELSIF p_component_string IS NOT NULL AND g_addr_address IS NULL THEN
    --
    g_addr_address := p_component_string;
    --
  END IF;
  --
END format_address;
--
-- -----------------------------------------------------------------------------
-- Format the output contact for a new contact
-- -----------------------------------------------------------------------------
--
PROCEDURE format_emrg_contacts(p_emrg_full_name    IN VARCHAR2
                              ,p_emrg_phone_number IN VARCHAR2
                              ,p_emrg_phone_type   IN VARCHAR2)
   IS
BEGIN
  --
  g_emrg_contacts := g_emrg_contacts
                  || hr_view_alert_messages.get_message_lng_psn
                     ('HR_AO_CONTACT_NAME'
                     ,p_emrg_full_name
                     ,g_emrg_person_id);
  --
  -- prints the tel numbers if there are tel numbers present
  --
  IF p_emrg_phone_number IS NOT NULL THEN
  g_emrg_contacts := g_emrg_contacts
                  || hr_view_alert_messages.get_message_lng_psn
                     ('HR_AO_DYNAMIC_TITLE'
                     ,p_emrg_phone_type
                     ,p_emrg_phone_number
                     ,g_emrg_person_id);
  --
  END IF;
  --
END format_emrg_contacts;
--
-- -----------------------------------------------------------------------------
-- Format the output contact for additional contact numbers
-- -----------------------------------------------------------------------------
--
PROCEDURE format_emrg_contacts(p_emrg_phone_number IN VARCHAR2
                              ,p_emrg_phone_type   IN VARCHAR2)
   IS
BEGIN
  --
  g_emrg_contacts := g_emrg_contacts
                  || hr_view_alert_messages.get_message_lng_psn
                     ('HR_AO_DYNAMIC_TITLE'
                     ,p_emrg_phone_type
                     ,p_emrg_phone_number
                     ,g_emrg_person_id);
  --
END format_emrg_contacts;
--
-- -----------------------------------------------------------------------------
-- Gets the details of a persons primary address
-- -----------------------------------------------------------------------------
--
PROCEDURE cache_psn_addrss_details(p_person_id IN NUMBER)
  IS
  --
  -- The following cursor gets all the required address fields for
  -- a given person id, in order to later construct an address.
  --
  CURSOR c_psn_addrss_details(cp_person_id NUMBER)
  IS
    SELECT addr.style
         , addr.address_line1
         , addr.address_line2
         , addr.address_line3
         , addr.address_type
         , addr.country
         , addr.postal_code
         , addr.region_1
         , addr.region_2
         , addr.region_3
         , addr.town_or_city
         , addr.add_information13
         , addr.add_information14
         , addr.add_information15
         , addr.add_information16
         , addr.add_information17
         , addr.add_information18
         , addr.add_information19
         , addr.add_information20
         , NULL
      FROM per_addresses addr
     WHERE addr.person_id = cp_person_id
       AND TRUNC(sysdate)
           BETWEEN date_from
               AND NVL(addr.date_to
                      ,TRUNC(SYSDATE))
       AND addr.primary_flag = 'Y'
       AND addr.address_type = 'H';
  --
  -- This cursor identifies the correct order of address components
  -- for a given address style.
  --
  CURSOR c_psn_addrss_struct(cp_addr_style VARCHAR2)
  IS
    SELECT fdc.application_column_name
      FROM fnd_descr_flex_column_usages fdc
     WHERE fdc.descriptive_flexfield_name = 'Address Structure'
       AND fdc.enabled_flag = 'Y'
       AND fdc.display_flag = 'Y'
       AND fdc.application_column_name NOT LIKE 'TELEPHONE_NUMBER%'
       AND fdc.descriptive_flex_context_code = cp_addr_style
     ORDER BY fdc.column_seq_num;
  --
  l_count NUMBER(7);
  --
BEGIN
  --
  -- Address components
  --
  -- If a person is not provided then set the components to NULL
  --
  IF p_person_id IS NULL
  THEN
    --
    g_addr_address_style      := NULL;
    g_addr_address_line1      := NULL;
    g_addr_address_line2      := NULL;
    g_addr_address_line3      := NULL;
    g_addr_address_type       := NULL;
    g_addr_country            := NULL;
    g_addr_postal_code        := NULL;
    g_addr_region_1           := NULL;
    g_addr_region_2           := NULL;
    g_addr_region_3           := NULL;
    g_addr_town_or_city       := NULL;
    g_addr_add_information13  := NULL;
    g_addr_add_information14  := NULL;
    g_addr_add_information15  := NULL;
    g_addr_add_information16  := NULL;
    g_addr_add_information17  := NULL;
    g_addr_add_information18  := NULL;
    g_addr_add_information19  := NULL;
    g_addr_add_information20  := NULL;
    g_addr_address            := NULL;
    --
    -- If not already cached then retrieve address components
    --
  ELSIF p_person_id <> NVL(g_person_id,-1)
  THEN
    --
    g_person_id := p_person_id;
    --
    OPEN c_psn_addrss_details(p_person_id);
    --
    FETCH c_psn_addrss_details
    INTO g_addr_address_style
       , g_addr_address_line1
       , g_addr_address_line2
       , g_addr_address_line3
       , g_addr_address_type
       , g_addr_country
       , g_addr_postal_code
       , g_addr_region_1
       , g_addr_region_2
       , g_addr_region_3
       , g_addr_town_or_city
       , g_addr_add_information13
       , g_addr_add_information14
       , g_addr_add_information15
       , g_addr_add_information16
       , g_addr_add_information17
       , g_addr_add_information18
       , g_addr_add_information19
       , g_addr_add_information20
       , g_addr_address;
    --
    l_count := c_psn_addrss_details%rowcount;
    --
    CLOSE c_psn_addrss_details;
    --
    IF l_count = 0 THEN
      g_addr_address_style      := NULL;
      g_addr_address_line1      := NULL;
      g_addr_address_line2      := NULL;
      g_addr_address_line3      := NULL;
      g_addr_address_type       := NULL;
      g_addr_country            := NULL;
      g_addr_postal_code        := NULL;
      g_addr_region_1           := NULL;
      g_addr_region_2           := NULL;
      g_addr_region_3           := NULL;
      g_addr_town_or_city       := NULL;
      g_addr_add_information13  := NULL;
      g_addr_add_information14  := NULL;
      g_addr_add_information15  := NULL;
      g_addr_add_information16  := NULL;
      g_addr_add_information17  := NULL;
      g_addr_add_information18  := NULL;
      g_addr_add_information19  := NULL;
      g_addr_add_information20  := NULL;
      g_addr_address            := NULL;
      --
      -- No point in proceding if there are no address components
      --
      RETURN;
      --
    END IF;
    --
  END IF;
  --
  -- Address structure
  --
  -- If necessary default the style to US address
  --
  IF g_addr_address_style IS NULL
  THEN
    --
    g_addr_address_style := 'US';
    --
  END IF;
  --
  OPEN c_psn_addrss_struct(g_addr_address_style);
  --
  LOOP
    --
    FETCH c_psn_addrss_struct INTO g_addr_col_name;
    --
    EXIT WHEN c_psn_addrss_struct%notfound ;
    --
    IF    NVL(g_addr_col_name,'X') = 'ADDRESS_LINE1'
    THEN
      --
      format_address(g_addr_address_line1);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'ADDRESS_LINE2'
    THEN
      --
      format_address(g_addr_address_line2);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'ADDRESS_LINE3'
    THEN
      --
      format_address(g_addr_address_line3);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'TOWN_OR_CITY'
    THEN
      --
      format_address(g_addr_town_or_city);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'REGION_1'
    THEN
      --
      format_address(g_addr_region_1);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'REGION_2'
    THEN
      --
      format_address(g_addr_region_2);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'REGION_3'
    THEN
      --
      format_address(g_addr_region_3);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'COUNTRY'
    THEN
      --
      format_address(g_addr_country);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'POSTAL_CODE'
    THEN
      --
      format_address(g_addr_country);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'ADD_INFORMATION13'
    THEN
      --
      format_address(g_addr_add_information13);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'ADD_INFORMATION14'
    THEN
      --
      format_address(g_addr_add_information14);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'ADD_INFORMATION15'
    THEN
      --
      format_address(g_addr_add_information15);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'ADD_INFORMATION16'
    THEN
      --
      format_address(g_addr_add_information16);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'ADD_INFORMATION17'
    THEN
      --
      format_address(g_addr_add_information17);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'ADD_INFORMATION18'
    THEN
      --
      format_address(g_addr_add_information18);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'ADD_INFORMATION19'
    THEN
      --
      format_address(g_addr_add_information19);
      --
    ELSIF NVL(g_addr_col_name,'X') = 'ADD_INFORMATION20'
    THEN
      --
      format_address(g_addr_add_information20);
      --
    END IF;
    --
  END LOOP;
  --
  CLOSE c_psn_addrss_struct;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
  --
    CLOSE c_psn_addrss_details;
    --
    g_addr_address_style      := NULL;
    g_addr_address_line1      := NULL;
    g_addr_address_line2      := NULL;
    g_addr_address_line3      := NULL;
    g_addr_address_type       := NULL;
    g_addr_country            := NULL;
    g_addr_postal_code        := NULL;
    g_addr_region_1           := NULL;
    g_addr_region_2           := NULL;
    g_addr_region_3           := NULL;
    g_addr_town_or_city       := NULL;
    g_addr_add_information13  := NULL;
    g_addr_add_information14  := NULL;
    g_addr_add_information15  := NULL;
    g_addr_add_information16  := NULL;
    g_addr_add_information17  := NULL;
    g_addr_add_information18  := NULL;
    g_addr_add_information19  := NULL;
    g_addr_add_information20  := NULL;
    g_addr_address            := NULL;
    g_addr_col_name           := NULL;
    g_person_id               := NULL;
    --
  --
END cache_psn_addrss_details;
--
-- -----------------------------------------------------------------------------
-- Gets the details of a persons emergency contacts
-- -----------------------------------------------------------------------------
--
PROCEDURE cache_psn_emrg_contacts(p_person_id IN NUMBER)
  IS
  --
  -- The cursor gets all the emergency contacts for a given person_id.
  --
  CURSOR c_psn_emrg_contacts_details(cp_person_id NUMBER)
  IS
    SELECT psn.full_name            contact_person_name
         , pho.phone_number         contact_phone_number
         , pho.phone_type           phone_type
      FROM per_contact_relationships con
         , per_all_people_f          psn
         , per_phones                pho
     WHERE psn.person_id = con.contact_person_id
       AND psn.person_id = pho.parent_id (+)
       AND pho.parent_table= 'PER_ALL_PEOPLE_F'
       AND con.person_id = cp_person_id
       AND con.contact_type = 'EMRG'
       AND TRUNC(sysdate)
             BETWEEN psn.effective_start_date
                 AND psn.effective_end_date
       AND TRUNC(SYSDATE)
             BETWEEN con.date_start
                 AND NVL(con.date_end
                        ,hr_general.end_of_time)
       AND TRUNC(SYSDATE)
             BETWEEN NVL(pho.date_from
                        ,hr_general.start_of_time)
                 AND NVL(pho.date_to
                        ,hr_general.end_of_time);
  --
  v_full_name VARCHAR2(2000) := NULL;
  --
BEGIN
  --
  IF p_person_id IS NULL THEN
    --
    g_emrg_contacts           := NULL;
    g_emrg_full_name          := NULL;
    g_emrg_phone_number       := NULL;
    g_emrg_phone_type         := NULL;
  --
  -- If not already cached then retrieve contact
  --
  ELSIF p_person_id <> NVL(g_emrg_person_id,-1)
  THEN
    --
    g_emrg_contacts           := NULL;
    g_emrg_full_name          := NULL;
    g_emrg_phone_number       := NULL;
    g_emrg_phone_type         := NULL;
    --
    g_emrg_person_id := p_person_id;
    --
    OPEN c_psn_emrg_contacts_details(p_person_id);
    --
    LOOP
      --
      FETCH c_psn_emrg_contacts_details
      INTO g_emrg_full_name
         , g_emrg_phone_number
         , g_emrg_phone_type;
      --
      If c_psn_emrg_contacts_details%notfound THEN
        --
        EXIT;
        --
      END IF;
      --
      -- format the contact depending if this is an additional contact no.
      --
      IF v_full_name = g_emrg_full_name THEN
        --
        format_emrg_contacts(g_emrg_phone_number
                            ,hr_view_alert_trnslt.psn_lng_decode_lookup
                             ('PHONE_TYPE'
                             ,g_emrg_phone_type
                             ,g_emrg_person_id));
        --
      ELSE
        --
        format_emrg_contacts(g_emrg_full_name
                            ,g_emrg_phone_number
                            ,hr_view_alert_trnslt.psn_lng_decode_lookup
                             ('PHONE_TYPE'
                             ,g_emrg_phone_type
                             ,g_emrg_person_id));
        --
        v_full_name := g_emrg_full_name;
        --
      END IF;
      --
    END LOOP;
    --
    CLOSE c_psn_emrg_contacts_details;
    --
    RETURN;
  --
  END IF;
  --
  EXCEPTION
    --
    WHEN OTHERS THEN
    --
    CLOSE c_psn_emrg_contacts_details;
    --
    g_emrg_contacts           := NULL;
    g_emrg_full_name          := NULL;
    g_emrg_phone_number       := NULL;
    g_emrg_phone_type         := NULL;
    --
  --
END cache_psn_emrg_contacts;
--
-- -----------------------------------------------------------------------------
-- Gets a single string containing the address
-- -----------------------------------------------------------------------------
--
FUNCTION get_psn_addrss(p_person_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  --
  cache_psn_addrss_details(p_person_id);
  --
  RETURN g_addr_address;
  --
END get_psn_addrss;
--
-- -----------------------------------------------------------------------------
-- Gets a single string containing the emergency contact details
-- -----------------------------------------------------------------------------
--
FUNCTION get_psn_emrg_contacts(p_person_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  --
  cache_psn_emrg_contacts(p_person_id);
  --
  RETURN g_emrg_contacts;
  --
END get_psn_emrg_contacts;
--
-- -----------------------------------------------------------------------------
--
END HR_BPL_ALERT_ADDRESS;

/
