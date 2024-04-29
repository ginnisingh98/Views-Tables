--------------------------------------------------------
--  DDL for Package Body XXAH_CONTRACT_CONV_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_CONTRACT_CONV_UPDATE_PKG" AS
 /* ************************************************************************
  * Copyright (c)  2010    Oracle Netherlands             De Meern
  * All rights reserved
  **************************************************************************
  *
  * FILENAME           : XXAH_CONTRACT_CONV_UPDATE_PKG.pkb
  * AITHOR             : Kevin Bouwmeester, Oracle NL Appstech
  * DESCRIPTION        : Package body with logic for the update of the
  *                      franchise contract conversion.
  * LAST UPDATE DATE   : 20-OCT-2010
  *
  * HISTORY
  * =======
  *
  * VER  DATE         AUTHOR(S)          DESCRIPTION
  * ---  -----------  -----------------  -----------------------------------
  * 1.0  20-OCT-2009  Kevin Bouwmeester  Genesis
  *************************************************************************/

  -- Global Constant Declaration
  gc_package_name              CONSTANT VARCHAR2(  32)                            := 'xxah_contract_conv_update_pkg';
  gc_log_prefix                CONSTANT VARCHAR2(  50)                            := 'apps.plsql.'|| gc_package_name || '.';
  gc_created_by_module         CONSTANT VARCHAR2( 150)                            := 'XXAH_CONTRACT_CONV_PKG';
  gc_status_active             CONSTANT VARCHAR2(   1)                            := 'A';
  gc_application_id            CONSTANT NUMBER                                    := fnd_global.prog_appl_id;
  gc_party_type_organization   CONSTANT hz_parties.party_type%TYPE                := 'ORGANIZATION';
  gc_party_type_person         CONSTANT hz_parties.party_type%TYPE                := 'PERSON';
  gc_person_category_code      CONSTANT hz_parties.category_code%TYPE             := 'CUSTOMER';
  gc_contact_point_type_phone  CONSTANT hz_contact_points.contact_point_type%TYPE := 'PHONE';
  gc_contact_point_type_email  CONSTANT hz_contact_points.contact_point_type%TYPE := 'EMAIL';
  gc_phone_line_type_general   CONSTANT hz_contact_points.phone_line_type%TYPE    := 'GEN';
  gc_phone_line_type_mobile    CONSTANT hz_contact_points.phone_line_type%TYPE    := 'MOBILE';
  gc_phone_line_type_fax       CONSTANT hz_contact_points.phone_line_type%TYPE    := 'FAX';
  gc_default_email_format      CONSTANT hz_contact_points.email_format%TYPE       := 'MAILTEXT';

  e_conv_exception EXCEPTION;


  -- -----------------------------------------------------------------
  -- Write output
  -- -----------------------------------------------------------------
  PROCEDURE out (p_message IN VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
    fnd_file.put
    ( fnd_file.OUTPUT
    , p_message);
  END out;

  PROCEDURE outline (p_message IN VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
    fnd_file.put_line
    ( fnd_file.OUTPUT
    , p_message);
  END outline;

  PROCEDURE log
  ( p_step IN VARCHAR2
  , p_message IN VARCHAR2 DEFAULT NULL
  )
  IS
  BEGIN
    fnd_file.put_line(fnd_file.log,to_char(systimestamp, 'HH24:MI:SS.FF2 ') || rpad(p_step, 14) || ' - ' || p_message);
  END log;

  -- --------------------------------------------------------------------
  -- PROCEDURE create_org_contact
  -- Create org_contact.
  -- --------------------------------------------------------------------
  PROCEDURE create_org_contact
  ( -- p_party_number            IN  VARCHAR2
    p_party_id                IN  hz_parties.party_id%TYPE -- Organization's party_id
  , p_cp_party_id             IN  hz_parties.party_id%TYPE -- Contact person's party_id
  , p_subject_type            IN  hz_parties.party_type%TYPE
  , p_oc_party_id             OUT hz_parties.party_id%TYPE -- Org contact's party_id
  ) IS
    -- Local constants
    lc_subprogram_name        CONSTANT VARCHAR2(30) := 'create_org_contact';
    -- Local variables
    l_org_contact_rec         hz_party_contact_v2pub.org_contact_rec_type;
    l_org_contact_id          NUMBER;
    l_party_rel_id            NUMBER;
    l_party_number            hz_parties.party_number%TYPE;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
  BEGIN
    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    l_org_contact_rec.created_by_module                             := gc_created_by_module;
    l_org_contact_rec.party_rel_rec.relationship_type               := 'CONTACT';
    l_org_contact_rec.party_rel_rec.relationship_code               := 'CONTACT_OF';
    l_org_contact_rec.party_rel_rec.subject_table_name              := 'HZ_PARTIES';
    l_org_contact_rec.party_rel_rec.subject_type                    := p_subject_type; -- gc_party_type_person;
    l_org_contact_rec.party_rel_rec.object_table_name               := 'HZ_PARTIES';
    l_org_contact_rec.party_rel_rec.object_type                     := gc_party_type_organization;
    -- l_org_contact_rec.party_rel_rec.party_rec.party_number          := p_party_number || gc_org_contact_suffix;
    --l_org_contact_rec.party_rel_rec.party_rec.orig_system           := gc_orig_system;
    --l_org_contact_rec.party_rel_rec.party_rec.orig_system_reference := p_party_number || gc_org_contact_suffix;
    l_org_contact_rec.party_rel_rec.party_rec.status                := gc_status_active;
    l_org_contact_rec.party_rel_rec.subject_id                      := p_cp_party_id;
    l_org_contact_rec.party_rel_rec.object_id                       := p_party_id;

    hz_party_contact_v2pub.create_org_contact
    ( p_org_contact_rec       => l_org_contact_rec
    , x_org_contact_id        => l_org_contact_id
    , x_party_rel_id          => l_party_rel_id
    , x_party_id              => p_oc_party_id
    , x_party_number          => l_party_number
    , x_return_status         => l_return_status
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    );

    IF l_return_status != 'S'
    OR l_msg_count > 0
    THEN
      fnd_msg_pub.Add_Exc_Msg
      ( p_pkg_name            => gc_package_name
      , p_procedure_name      => lc_subprogram_name
      , p_error_text          => 'API hz_party_contact_v2pub.create_org_contact '
                          || 'voltooid met status '''|| l_return_status || ''''
      );

      RAISE e_conv_exception;
    END IF;

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );
  END create_org_contact;

  -- --------------------------------------------------------------------
  -- PROCEDURE create_location
  -- Create location.
  -- --------------------------------------------------------------------
  PROCEDURE create_location
  ( p_address_street          IN hz_locations.address1%TYPE
  , p_address_house_num       IN hz_locations.street_number%TYPE
  , p_address_house_num_add   IN hz_locations.street_suffix%TYPE
  , p_address_city            IN hz_locations.city%TYPE
  , p_address_pc              IN hz_locations.postal_code%TYPE
  , p_location_id             OUT hz_locations.location_id%TYPE
  ) IS
    -- Local constants
    lc_subprogram_name        CONSTANT VARCHAR2(30) := 'create_location';
    -- Local variables
    l_location_rec            hz_location_v2pub.location_rec_type;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
  BEGIN
    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    l_location_rec.created_by_module     := gc_created_by_module;
    l_location_rec.application_id        := gc_application_id;
    --l_location_rec.orig_system           := gc_orig_system;
    --l_location_rec.orig_system_reference := p_party_number;
    l_location_rec.country               := 'NL';
    l_location_rec.address1              := trim(p_address_street  || ' ' || p_address_house_num || ' ' || p_address_house_num_add);
    l_location_rec.address2              := NULL;
    l_location_rec.address3              := NULL;
    l_location_rec.address4              := NULL;
    l_location_rec.city                  := p_address_city;
    l_location_rec.postal_code           := p_address_pc;
    l_location_rec.language              := userenv('LANG');
    --l_location_rec.street_suffix         := p_address_house_num_add;
    --l_location_rec.street                := p_address_street;
    --l_location_rec.street_number         := p_address_house_num;

    hz_location_v2pub.create_location
    ( p_location_rec          => l_location_rec
    , x_location_id           => p_location_id
    , x_return_status         => l_return_status
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    );

    IF l_return_status != 'S'
    OR l_msg_count > 0
    THEN
      fnd_msg_pub.Add_Exc_Msg
      ( p_pkg_name            => gc_package_name
      , p_procedure_name      => lc_subprogram_name
      , p_error_text          => 'API hz_location_v2pub.create_location '
                          || 'voltooid met status ''' || l_return_status || ''''
      );

      RAISE e_conv_exception;
    END IF;

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );
  END create_location;

  -- --------------------------------------------------------------------
  -- PROCEDURE create_party_site
  -- Create party_site.
  -- --------------------------------------------------------------------
  PROCEDURE create_party_site
  ( --p_party_number            IN  VARCHAR2
    p_party_id                IN  NUMBER
  , p_location_id             IN  NUMBER
  , p_party_site_id           OUT NUMBER
  ) IS
    -- Local constants
    lc_subprogram_name     CONSTANT VARCHAR2(30) := 'create_party_site';
    -- Local variables
    l_party_site_rec    hz_party_site_v2pub.party_site_rec_type;
    l_party_site_number hz_party_sites.party_site_number%TYPE;
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
  BEGIN
    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    l_party_site_rec.created_by_module     := gc_created_by_module;
    --l_party_site_rec.orig_system           := gc_orig_system;
    --l_party_site_rec.orig_system_reference := p_party_number;
    --    p_party_site_rec.party_site_number     := p_staging_customer_rec.customer_address_number;
    l_party_site_rec.application_id        := gc_application_id;
    l_party_site_rec.status                := gc_status_active;
    l_party_site_rec.party_id              := p_party_id;
    l_party_site_rec.location_id           := p_location_id;

    hz_party_site_v2pub.create_party_site
    ( p_party_site_rec        => l_party_site_rec
    , x_party_site_id         => p_party_site_id
    , x_party_site_number     => l_party_site_number
    , x_return_status         => l_return_status
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    );

    IF l_return_status != 'S'
    OR l_msg_count > 0
    THEN
      fnd_msg_pub.Add_Exc_Msg
      ( p_pkg_name           => gc_package_name
      , p_procedure_name     => lc_subprogram_name
      , p_error_text         => 'API hz_party_site_v2pub.create_party_site '
                          || 'voltooid met status '''|| l_return_status || ''''
      );

      RAISE e_conv_exception;
    END IF;

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    ,'End procedure.'
    );
  END create_party_site;

  PROCEDURE create_party_org
  ( p_org_name                IN  hz_parties.party_name%TYPE
  , p_party_number            OUT hz_parties.party_number%TYPE
  , p_party_id                OUT hz_parties.party_id%TYPE
  )
  IS
    -- Local constants
    lc_subprogram_name        CONSTANT VARCHAR2(30) := 'create_party';
    -- Local variables
    l_organization_rec        hz_party_v2pub.organization_rec_type;
--    l_party_number            hz_parties.party_number%TYPE;
    l_profile_id              NUMBER;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
  BEGIN
    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    l_organization_rec.organization_name               := p_org_name;
    l_organization_rec.organization_type               := gc_party_type_organization;
    l_organization_rec.internal_flag                   := 'N';
    l_organization_rec.created_by_module               := gc_created_by_module;
    -- l_organization_rec.party_rec.party_number          := p_org_number;
    l_organization_rec.party_rec.status                := gc_status_active;
    l_organization_rec.party_rec.validated_flag        := 'N';
    --l_organization_rec.party_rec.orig_system           := gc_orig_system;
    --l_organization_rec.party_rec.orig_system_reference := p_org_number;

    hz_party_v2pub.create_organization
    ( p_organization_rec     => l_organization_rec
    , x_party_id             => p_party_id
    , x_party_number         => p_party_number
    , x_profile_id           => l_profile_id
    , x_return_status        => l_return_status
    , x_msg_count            => l_msg_count
    , x_msg_data             => l_msg_data
    );

    IF l_return_status != 'S'
    OR l_msg_count > 0
    THEN
      fnd_msg_pub.Add_Exc_Msg
      ( p_pkg_name       => gc_package_name
      , p_procedure_name => lc_subprogram_name
      , p_error_text     => 'API hz_party_v2pub.create_organization '
                            || 'voltooid met status ''' || l_return_status || ''''
      );

      RAISE e_conv_exception;

    END IF;

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );

  END create_party_org;

  PROCEDURE create_party_person
  ( p_pers_firstname          IN  hz_parties.person_first_name%TYPE
  , p_pers_middlename         IN  hz_parties.person_middle_name%TYPE
  , p_pers_lastname           IN  hz_parties.person_last_name%TYPE
  , p_party_number            OUT hz_parties.party_number%TYPE
  , p_party_id                OUT hz_parties.party_id%TYPE
  )
  IS
    -- Local constants
    lc_subprogram_name        CONSTANT VARCHAR2(30) := 'create_party';
    -- Local variables
    l_person_rec              hz_party_v2pub.person_rec_type;
     --    l_party_number            hz_parties.party_number%TYPE;
    l_profile_id              NUMBER;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);

    l_full_name               hz_parties.party_name%TYPE;
  BEGIN
    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    -- combine the full_name
    IF p_pers_middlename IS NOT NULL
    THEN
        l_full_name := p_pers_firstname || ' ' || p_pers_middlename || ' ' || p_pers_lastname;
    ELSE
        l_full_name := p_pers_firstname || ' ' || p_pers_lastname;
    END IF;

    l_person_rec.created_by_module               := gc_created_by_module;
    l_person_rec.application_id                  := gc_application_id;
    l_person_rec.internal_flag                   := 'N';
    l_person_rec.content_source_type             := hz_party_v2pub.g_miss_content_source_type;
    -- l_person_rec.person_first_name               := p_pers_firstname;
    l_person_rec.person_initials                 := replace(p_pers_firstname,'.');
    l_person_rec.person_middle_name              := p_pers_middlename;
    l_person_rec.person_last_name                := p_pers_lastname;
    l_person_rec.person_name_phonetic            := l_full_name;
    l_person_rec.created_by_module               := gc_created_by_module;
    l_person_rec.party_rec.category_code         := gc_person_category_code;
    l_person_rec.party_rec.validated_flag        := 'N';
    l_person_rec.party_rec.status                := gc_status_active;

    hz_party_v2pub.create_person
    ( p_person_rec            => l_person_rec
    , x_party_id              => p_party_id
    , x_party_number          => p_party_number
    , x_profile_id            => l_profile_id
    , x_return_status         => l_return_status
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    );

    IF l_return_status != 'S'
    OR l_msg_count > 0
    THEN
      fnd_msg_pub.Add_Exc_Msg
      ( p_pkg_name            => gc_package_name
      , p_procedure_name      => lc_subprogram_name
      , p_error_text          => 'API hz_party_v2pub.create_person voltooid met status '''
                            || l_return_status || ''''
      );

      RAISE e_conv_exception;
    END IF;

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );

  END create_party_person;

  -- --------------------------------------------------------------------
  -- PROCEDURE create_phone_contact_point
  -- Create phone_contact_point.
  -- --------------------------------------------------------------------
  PROCEDURE create_phone_contact_point
  ( --p_party_number         IN hz_parties.party_number%TYPE
    p_party_id             IN hz_parties.party_id%TYPE
  , p_phone_line_type      IN hz_contact_points.phone_line_type%TYPE
  , p_phone_number         IN hz_contact_points.phone_number%TYPE
  ) IS
    -- Local constants
    lc_subprogram_name     CONSTANT VARCHAR2(30) := 'create_phone_contact_point';
    -- Local variables
    l_contact_point_rec    hz_contact_point_v2pub.contact_point_rec_type;
    l_phone_rec            hz_contact_point_v2pub.phone_rec_type := hz_contact_point_v2pub.g_miss_phone_rec;
    l_contact_point_id     NUMBER;
    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

    l_count_contact_point NUMBER := 0;

  BEGIN
    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    l_contact_point_rec.status                := gc_status_active;
    l_contact_point_rec.owner_table_name      := 'HZ_PARTIES';
    l_contact_point_rec.created_by_module     := gc_created_by_module;
    l_contact_point_rec.application_id        := gc_application_id;
    --l_contact_point_rec.orig_system           := gc_orig_system;

    l_contact_point_rec.owner_table_id        := p_party_id;
    l_contact_point_rec.contact_point_type    := gc_contact_point_type_phone;
    --l_contact_point_rec.orig_system_reference := p_party_number
    --                                          || gc_contact_point_type_phone
    --                                          || p_party_id
    --                                          || p_phone_line_type;
    l_phone_rec.phone_line_type               := p_phone_line_type;
    l_phone_rec.raw_phone_number              := p_phone_number;
    l_phone_rec.phone_number                  := NULL;
    l_phone_rec.phone_area_code               := NULL;

    hz_contact_point_v2pub.create_phone_contact_point
    ( p_contact_point_rec     => l_contact_point_rec
    , p_phone_rec             => l_phone_rec
    , x_contact_point_id      => l_contact_point_id
    , x_return_status         => l_return_status
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    );

    log('3.1.4.2','Contact point id created: ' || l_contact_point_id);

    log('3.1.4.2','Return status: ' || l_return_status);

    select count(*) into l_count_contact_point
    FROM   hz_contact_points where contact_point_id = l_contact_point_id;

    log('3.1.4.2','Found: ' || l_count_contact_point);

    IF l_return_status != 'S'
    OR l_msg_count > 0
    THEN
      fnd_msg_pub.Add_Exc_Msg
      ( p_pkg_name            => gc_package_name
      , p_procedure_name      => lc_subprogram_name
      , p_error_text          => 'API hz_contact_point_v2pub.create_phone_contact_point '
                          || 'voltooid met status ''' || l_return_status  || ''''
      );

      log('Exception',l_msg_count || ' ' || l_msg_data);

      FOR l_index IN 1 .. l_msg_count LOOP
        l_msg_data := fnd_msg_pub.get(l_index,'F');
        log('Exception', SUBSTR(l_msg_data,1,2000));
      END LOOP;

      RAISE e_conv_exception;
    END IF;

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );
  END create_phone_contact_point;

  -- --------------------------------------------------------------------
  -- PROCEDURE update_phone_contact_point
  -- Update phone_contact_point.
  -- --------------------------------------------------------------------
  PROCEDURE update_phone_contact_point
  ( p_party_id             IN hz_parties.party_id%TYPE
  , p_contact_point_id     IN hz_contact_points.contact_point_id%TYPE
  , p_phone_line_type      IN hz_contact_points.phone_line_type%TYPE
  , p_phone_number         IN hz_contact_points.phone_number%TYPE
  ) IS
    -- Local constants
    lc_subprogram_name     CONSTANT VARCHAR2(30) := 'update_phone_contact_point';
    -- Local variables
    l_contact_point_rec    hz_contact_point_v2pub.contact_point_rec_type;
    l_phone_rec            hz_contact_point_v2pub.phone_rec_type := hz_contact_point_v2pub.g_miss_phone_rec;
    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_object_version_num   NUMBER;
  BEGIN
    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    l_contact_point_rec.contact_point_id      := p_contact_point_id;
    l_contact_point_rec.status                := gc_status_active;
    l_contact_point_rec.owner_table_name      := 'HZ_PARTIES';
    l_contact_point_rec.created_by_module     := gc_created_by_module;
    l_contact_point_rec.application_id        := gc_application_id;
    l_contact_point_rec.owner_table_id        := p_party_id;
    l_contact_point_rec.contact_point_type    := gc_contact_point_type_phone;
    l_phone_rec.phone_line_type               := p_phone_line_type;
    l_phone_rec.raw_phone_number              := p_phone_number;
    l_phone_rec.phone_number                  := NULL;
    l_phone_rec.phone_area_code               := NULL;

    SELECT object_version_number
    INTO   l_object_version_num
    FROM   hz_contact_points
    WHERE  contact_point_id = p_contact_point_id;

    hz_contact_point_v2pub.update_phone_contact_point
    ( p_contact_point_rec     => l_contact_point_rec
    , p_phone_rec             => l_phone_rec
    , p_object_version_number => l_object_version_num
    , x_return_status         => l_return_status
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    );

    IF l_return_status != 'S'
    OR l_msg_count > 0
    THEN
      fnd_msg_pub.Add_Exc_Msg
      ( p_pkg_name            => gc_package_name
      , p_procedure_name      => lc_subprogram_name
      , p_error_text          => 'API hz_contact_point_v2pub.update_phone_contact_point '
                          || 'voltooid met status ''' || l_return_status  || ''''
      );

      log('Exception',l_msg_count || ' ' || l_msg_data);

      FOR l_index IN 1 .. l_msg_count LOOP
        l_msg_data := fnd_msg_pub.get(l_index,'F');
        log('Exception', SUBSTR(l_msg_data,1,2000));
      END LOOP;



      RAISE e_conv_exception;
    END IF;

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );
  END update_phone_contact_point;

  -- --------------------------------------------------------------------
  -- PROCEDURE create_email_contact_point
  -- Create email_contact_point.
  -- --------------------------------------------------------------------
  PROCEDURE create_email_contact_point
  ( --p_party_number         IN hz_parties.party_number%TYPE
    p_party_id             IN hz_parties.party_id%TYPE
  , p_email_address        IN hz_contact_points.email_address%TYPE
  ) IS
    -- Local constants
    lc_subprogram_name     CONSTANT VARCHAR2(30) := 'create_email_contact_point';
    -- Local variables
    l_contact_point_rec    hz_contact_point_v2pub.contact_point_rec_type;
    l_email_rec            hz_contact_point_v2pub.email_rec_type := hz_contact_point_v2pub.g_miss_email_rec;
    l_contact_point_id     NUMBER;
    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
  BEGIN
    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    l_contact_point_rec.status                := gc_status_active;
    l_contact_point_rec.owner_table_name      := 'HZ_PARTIES';
    l_contact_point_rec.created_by_module     := gc_created_by_module;
    l_contact_point_rec.application_id        := gc_application_id;
    --l_contact_point_rec.orig_system           := gc_orig_system;
    l_contact_point_rec.owner_table_id        := p_party_id;
    l_contact_point_rec.contact_point_type    := gc_contact_point_type_email;
    --l_contact_point_rec.orig_system_reference := p_party_number || gc_contact_point_type_email || p_party_id;
    l_email_rec.email_address                 := p_email_address;
    l_email_rec.email_format                  := gc_default_email_format;

    --write_log('EMAIL_FORMAT: ' || l_email_rec.email_format);

    hz_contact_point_v2pub.create_email_contact_point
    ( p_contact_point_rec     => l_contact_point_rec
    , p_email_rec             => l_email_rec
    , x_contact_point_id      => l_contact_point_id
    , x_return_status         => l_return_status
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    );

    IF l_return_status != 'S'
    OR l_msg_count > 0
    THEN
      fnd_msg_pub.Add_Exc_Msg
      ( p_pkg_name            => gc_package_name
      , p_procedure_name      => lc_subprogram_name
      , p_error_text          => 'API hz_contact_point_v2pub.create_email_contact_point '
                          || 'voltooid met status ''' || l_return_status || ''''
      );

      RAISE e_conv_exception;
    END IF;

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );
  END create_email_contact_point;

  -- --------------------------------------------------------------------
  -- PROCEDURE update_email_contact_point
  -- Update email_contact_point.
  -- --------------------------------------------------------------------
  PROCEDURE update_email_contact_point
  ( p_party_id             IN hz_parties.party_id%TYPE
  , p_contact_point_id     IN hz_contact_points.contact_point_id%TYPE
  , p_email_address        IN hz_contact_points.email_address%TYPE
  ) IS
    -- Local constants
    lc_subprogram_name     CONSTANT VARCHAR2(30) := 'update_email_contact_point';
    -- Local variables
    l_contact_point_rec    hz_contact_point_v2pub.contact_point_rec_type;
    l_email_rec            hz_contact_point_v2pub.email_rec_type := hz_contact_point_v2pub.g_miss_email_rec;
    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_object_version_number NUMBER;
  BEGIN
    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    l_contact_point_rec.contact_point_id      := p_contact_point_id;
    l_contact_point_rec.status                := gc_status_active;
    l_contact_point_rec.owner_table_name      := 'HZ_PARTIES';
    l_contact_point_rec.created_by_module     := gc_created_by_module;
    l_contact_point_rec.application_id        := gc_application_id;
    l_contact_point_rec.owner_table_id        := p_party_id;
    l_contact_point_rec.contact_point_type    := gc_contact_point_type_email;
    l_email_rec.email_address                 := p_email_address;
    l_email_rec.email_format                  := gc_default_email_format;

    SELECT object_version_number
    INTO   l_object_version_number
    FROM   hz_contact_points
    WHERE  contact_point_id = p_contact_point_id;

    hz_contact_point_v2pub.update_email_contact_point
    ( p_contact_point_rec     => l_contact_point_rec
    , p_email_rec             => l_email_rec
    , p_object_version_number => l_object_version_number
    , x_return_status         => l_return_status
    , x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    );

    IF l_return_status != 'S'
    OR l_msg_count > 0
    THEN
      fnd_msg_pub.Add_Exc_Msg
      ( p_pkg_name            => gc_package_name
      , p_procedure_name      => lc_subprogram_name
      , p_error_text          => 'API hz_contact_point_v2pub.update_email_contact_point '
                          || 'voltooid met status ''' || l_return_status || ''''
      );

      RAISE e_conv_exception;
    END IF;

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );
  END update_email_contact_point;

  -- --------------------------------------------------------------------
  -- PROCEDURE update_entrepeneur
  -- Update entrepeneur data. This can be done for three situation:
  -- STEP 1. Entrepeneur exists, and there is an update, so update it.
  --      1.1. Update Names
  --      1.2. Update Address
  --      1.3. Insert, update or delete phone number
  --      1.3.1 UPDATE
  --      1.3.2 INSERT
  --      1.3.3 DELETE
  --      1.4. Insert, update or delete mobile number
  --      1.4.1 UPDATE
  --      1.4.2 INSERT
  --      1.4.3 DELETE
  --      1.5. Insert, update or delete email address
  --      1.5.1 UPDATE
  --      1.5.2 INSERT
  --      1.5.3 DELETE
  -- STEP 2. Entrepeneur does not exists yet, and there is an update, so create it.
  --      2.1. Create Party
  --      2.2. Create party address
  --      2.3. Create phone number
  --      2.4. Create mobile number
  --      2.5. Create email address
  -- STEP 3. Entrepeneur exists, and there is no update, so delete existing.
  --      3.1. DELETE party record
  --      3.2. DELETE relationships
  --      3.3. DELETE address
  --      3.4. DELETE location
  --      3.5. DELETE contact points
  -- --------------------------------------------------------------------
  PROCEDURE update_entrepeneur
  ( p_entre_party_id            IN NUMBER
  , p_entrepeneur_initials      IN VARCHAR2
  , p_entrepeneur_middle_name   IN VARCHAR2
  , p_entrepeneur_last_name     IN VARCHAR2
  , p_entrepeneur_street        IN VARCHAR2
  , p_entrepeneur_house_num     IN VARCHAR2
  , p_entrepeneur_house_num_add IN VARCHAR2
  , p_entrepeneur_city          IN VARCHAR2
  , p_entrepeneur_pc            IN VARCHAR2
  , p_entrepeneur_phone         IN VARCHAR2
  , p_entrepeneur_mobile        IN VARCHAR2
  , p_entrepeneur_email         IN VARCHAR2
  , p_store_party_id            IN NUMBER
  , p_le_party_id               IN NUMBER
  )
  IS

    CURSOR c_phone(b_party_id hz_parties.party_id%TYPE)
    IS
    SELECT contact_point_id
    FROM   hz_contact_points
    WHERE  contact_point_type = 'PHONE'
    AND    phone_line_type = gc_phone_line_type_general
    AND    owner_table_name = 'HZ_PARTIES'
    AND    owner_table_id = b_party_id
    ;

    CURSOR c_mobile(b_party_id hz_parties.party_id%TYPE)
    IS
    SELECT contact_point_id
    FROM   hz_contact_points
    WHERE  contact_point_type = 'PHONE'
    AND    phone_line_type = gc_phone_line_type_mobile
    AND    owner_table_name = 'HZ_PARTIES'
    AND    owner_table_id = b_party_id
    ;

    CURSOR c_email(b_party_id hz_parties.party_id%TYPE)
    IS
    SELECT contact_point_id
    FROM   hz_contact_points
    WHERE  contact_point_type = 'EMAIL'
    AND    owner_table_name = 'HZ_PARTIES'
    AND    owner_table_id = b_party_id
    ;

    CURSOR c_locations(b_party_id hz_parties.party_id%TYPE)
    IS
    SELECT location_id
    FROM   hz_party_sites
    WHERE  party_id = p_entre_party_id
    ;

    l_new_entre_party_number  hz_parties.party_number%TYPE;
    l_new_entre_party_id      NUMBER;
    l_new_entre_party_site_id NUMBER;
    l_new_entre_location_id   NUMBER;
    l_del_entre_locations     c_locations%ROWTYPE;
    l_entre_contact_point_id  NUMBER;

    l_oc_store_party_id       NUMBER;
    l_oc_le_party_id          NUMBER;

    l_full_name               hz_parties.party_name%TYPE;

  BEGIN
    IF  p_entre_party_id IS NOT NULL
    AND p_entrepeneur_last_name IS NOT NULL
    THEN
       log('STEP 3.1','Party already exists, so update it Party Id: ' || p_entre_party_id);
       log('STEP 3.1.1','Update party names');

       -- combine the full_name
       IF p_entrepeneur_middle_name IS NOT NULL
       THEN
         l_full_name := p_entrepeneur_initials || ' ' || p_entrepeneur_middle_name || ' ' || p_entrepeneur_last_name;
       ELSE
         l_full_name := p_entrepeneur_initials || ' ' || p_entrepeneur_last_name;
       END IF;

       UPDATE hz_parties
       SET    party_name         = p_entrepeneur_last_name
       ,      person_first_name  = p_entrepeneur_initials
       ,      person_middle_name = p_entrepeneur_middle_name
       ,      person_last_name   = p_entrepeneur_last_name
       ,      last_update_date   = SYSDATE
       ,      last_updated_by    = fnd_global.USER_ID
       ,      last_update_login  = fnd_global.LOGIN_ID
       WHERE  party_id    = p_entre_party_id
       ;
       update hz_person_profiles
       set    person_name          = p_entrepeneur_last_name
       ,      person_last_name     = p_entrepeneur_last_name
       ,      person_initials      = p_entrepeneur_initials
       ,      person_name_phonetic = l_full_name
       where  party_id    = p_entre_party_id;

       IF SQL%ROWCOUNT > 0
       THEN
         out(rpad('U',6));
       ELSE
         out(rpad('-',6));
       END IF;

       IF  p_entrepeneur_street IS NOT NULL
       AND p_entrepeneur_house_num IS NOT NULL
       AND p_entrepeneur_pc IS NOT NULL
       AND p_entrepeneur_city IS NOT NULL
       THEN
         BEGIN
           SELECT s.location_id
           INTO   l_new_entre_location_id
           FROM   hz_party_sites s
           WHERE  s.party_id = p_entre_party_id
           ;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_new_entre_location_id := NULL;
         END;
         IF l_new_entre_location_id IS NOT NULL
         THEN
           log('STEP 3.1.2','Update address Location Id: ' || l_new_entre_location_id);
           UPDATE hz_locations
           SET    address1           = trim(p_entrepeneur_street  || ' ' || p_entrepeneur_house_num || ' ' || p_entrepeneur_house_num_add)
           ,      city               = p_entrepeneur_city
           ,      postal_code        = p_entrepeneur_pc
           ,      last_update_date   = SYSDATE
           ,      last_updated_by    = fnd_global.USER_ID
           ,      last_update_login  = fnd_global.LOGIN_ID
           WHERE  location_id        = l_new_entre_location_id
           ;
           UPDATE hz_parties
           SET    address1           = trim(p_entrepeneur_street || ' ' || p_entrepeneur_house_num || ' ' || p_entrepeneur_house_num_add)
           ,      city               = p_entrepeneur_city
           ,      postal_code        = p_entrepeneur_pc
           ,      last_update_date   = SYSDATE
           ,      last_updated_by    = fnd_global.USER_ID
           ,      last_update_login  = fnd_global.LOGIN_ID
           WHERE  party_id           = p_entre_party_id
           ;
           IF SQL%ROWCOUNT > 0
           THEN
             out(rpad('U',6));
           ELSE
             out(rpad('-',6));
           END IF;
         ELSE
           log('STEP 3.1.2.1','Create new address');
           create_location
           ( p_address_street         => p_entrepeneur_street
           , p_address_house_num      => p_entrepeneur_house_num
           , p_address_house_num_add  => p_entrepeneur_house_num_add
           , p_address_city           => p_entrepeneur_city
           , p_address_pc             => p_entrepeneur_pc
           , p_location_id            => l_new_entre_location_id
           );
           create_party_site
           ( p_party_id              => p_entre_party_id
           , p_location_id           => l_new_entre_location_id
           , p_party_site_id         => l_new_entre_party_site_id
           );
           out(rpad('I',6));
         END IF;
       ELSE
         out(rpad('-',6));
       END IF;

       l_entre_contact_point_id := NULL;

       OPEN c_phone(p_entre_party_id);
       FETCH c_phone INTO l_entre_contact_point_id;
       CLOSE c_phone;

       log('STEP 3.1.3','Insert, update or delete phone number');
       IF  p_entrepeneur_phone IS NOT NULL
       AND l_entre_contact_point_id IS NOT NULL
       THEN
         log('STEP 3.1.3.1','UPDATE Contact Point Id: ' || l_entre_contact_point_id);
         update_phone_contact_point
         ( p_party_id          => p_entre_party_id
         , p_contact_point_id  => l_entre_contact_point_id
         , p_phone_line_type   => gc_phone_line_type_general
         , p_phone_number      => p_entrepeneur_phone
         );
         out(rpad('U',6));
       ELSIF p_entrepeneur_phone IS NOT NULL
       AND l_entre_contact_point_id IS NULL
       THEN
         log('STEP 3.1.3.2','INSERT');
         create_phone_contact_point
         ( p_party_id         => p_entre_party_id
         , p_phone_line_type  => gc_phone_line_type_general
         , p_phone_number     => p_entrepeneur_phone
         );
         out(rpad('I',6));
       ELSIF p_entrepeneur_phone IS NULL
       AND l_entre_contact_point_id IS NOT NULL
       THEN
         log('STEP 3.1.3.3','DELETE Contact Point Id: ' || l_entre_contact_point_id);
         DELETE hz_contact_points
         WHERE contact_point_id  = l_entre_contact_point_id
         ;
         out(rpad('D',6));
       ELSE
         out(rpad('-',6));
       END IF;

       l_entre_contact_point_id := NULL;

       log('STEP 3.1.4','Insert, update or delete mobile number');
       OPEN  c_mobile(p_entre_party_id);
       FETCH c_mobile INTO l_entre_contact_point_id;
       CLOSE c_mobile;

       IF p_entrepeneur_mobile IS NOT NULL
       AND l_entre_contact_point_id IS NOT NULL
       THEN
         log('STEP 3.1.4.1','UPDATE Contact Point Id: ' || l_entre_contact_point_id);
         update_phone_contact_point
         ( p_party_id          => p_entre_party_id
         , p_contact_point_id  => l_entre_contact_point_id
         , p_phone_line_type   => 'MOBILE'
         , p_phone_number      => p_entrepeneur_mobile
         );
         out(rpad('U',6));
       ELSIF p_entrepeneur_mobile IS NOT NULL
       AND   l_entre_contact_point_id IS NULL
       THEN
         log('STEP 3.1.4.2','INSERT');
         create_phone_contact_point
         ( p_party_id         => p_entre_party_id
         , p_phone_line_type  => 'MOBILE'
         , p_phone_number     => p_entrepeneur_mobile
         );
         out(rpad('I',6));
       ELSIF p_entrepeneur_mobile IS NULL
       AND   l_entre_contact_point_id IS NOT NULL
       THEN
         log('STEP 3.1.4.3','DELETE Contact Point Id: ' || l_entre_contact_point_id);
         DELETE hz_contact_points
         WHERE contact_point_id  = l_entre_contact_point_id
         ;
         out(rpad('D',6));
       ELSE
         out(rpad('-',6));
       END IF;

       l_entre_contact_point_id := NULL;

       log('STEP 3.1.5','Insert, update or delete email address');
       OPEN  c_email(p_entre_party_id);
       FETCH c_email INTO l_entre_contact_point_id;
       CLOSE c_email;

       IF p_entrepeneur_email IS NOT NULL
       AND l_entre_contact_point_id IS NOT NULL
       THEN
         log('STEP 3.1.5.1','UPDATE Contact Point Id: ' || l_entre_contact_point_id);
         update_email_contact_point
         ( p_party_id          => p_entre_party_id
         , p_contact_point_id  => l_entre_contact_point_id
         , p_email_address     => p_entrepeneur_email
         );
         out(rpad('U',6));
       ELSIF p_entrepeneur_email IS NOT NULL
       AND l_entre_contact_point_id IS NULL
       THEN
         log('STEP 3.1.5.2','INSERT');
         create_email_contact_point
         ( p_party_id          => p_entre_party_id
         , p_email_address     => p_entrepeneur_email
         );
         out(rpad('I',6));
       ELSIF p_entrepeneur_email IS NULL
       AND l_entre_contact_point_id IS NOT NULL
       THEN
         log('STEP 3.1.5.3','DELETE Contact Point Id: ' || l_entre_contact_point_id);
         DELETE hz_contact_points
         WHERE contact_point_id  = l_entre_contact_point_id
         ;
         out(rpad('D',6));
       ELSE
         out(rpad('-',6));
       END IF;

    ELSIF p_entre_party_id IS NULL
    AND   p_entrepeneur_last_name IS NOT NULL
    THEN
      log('STEP 3.2','Party does not exists yet, so create it');
      log('STEP 3.2.1','Create party');
      create_party_person
      ( p_pers_firstname  => p_entrepeneur_initials
      , p_pers_middlename => p_entrepeneur_middle_name
      , p_pers_lastname   => p_entrepeneur_last_name
      , p_party_number    => l_new_entre_party_number
      , p_party_id        => l_new_entre_party_id
      );
      out(rpad('I',6));

      IF  p_entrepeneur_street IS NOT NULL
      AND p_entrepeneur_house_num IS NOT NULL
      AND p_entrepeneur_city IS NOT NULL
      AND p_entrepeneur_pc IS NOT NULL
      THEN
        log('STEP 3.2.2','Create address (location and party site)');
        create_location
        ( p_address_street         => p_entrepeneur_street
        , p_address_house_num      => p_entrepeneur_house_num
        , p_address_house_num_add  => p_entrepeneur_house_num_add
        , p_address_city           => p_entrepeneur_city
        , p_address_pc             => p_entrepeneur_pc
        , p_location_id            => l_new_entre_location_id
        );
        create_party_site
        ( p_party_id              => l_new_entre_party_id
        , p_location_id           => l_new_entre_location_id
        , p_party_site_id         => l_new_entre_party_site_id
        );
        out(rpad('I',6));
      ELSE
        out(rpad('-',6));
      END IF;


      log('STEP 3.2.3','Create link between entrepeneur and legal entity and store');

      IF p_store_party_id IS NOT NULL
      THEN
        log('STEP 3.2.3.1','Create link between entrepeneur and store party');
        create_org_contact
        ( p_party_id                => p_store_party_id
        , p_cp_party_id             => l_new_entre_party_id
        , p_subject_type            => gc_party_type_person
        , p_oc_party_id             => l_oc_store_party_id
        );
      END IF;

      IF p_le_party_id IS NOT NULL
      THEN
        log('STEP 3.2.3.2','Create link between entrepeneur and legal entity');
        create_org_contact
        ( p_party_id                => p_le_party_id
        , p_cp_party_id             => l_new_entre_party_id
        , p_subject_type            => gc_party_type_person
        , p_oc_party_id             => l_oc_le_party_id
        );
      END IF;

      IF p_entrepeneur_phone IS NOT NULL
      THEN
         log('STEP 3.2.4','Create phone number');
         create_phone_contact_point
         ( p_party_id          => l_new_entre_party_id
         , p_phone_line_type   => gc_phone_line_type_general
         , p_phone_number      => p_entrepeneur_phone
         );
         out(rpad('I',6));
      ELSE
        out(rpad('-',6));
      END IF;
      IF p_entrepeneur_mobile IS NOT NULL
      THEN
        log('STEP 3.2.5','Create mobile number');
        create_phone_contact_point
        ( p_party_id          => l_new_entre_party_id
        , p_phone_line_type   => 'MOBILE'
        , p_phone_number      => p_entrepeneur_mobile
        );
        out(rpad('I',6));
      ELSE
        out(rpad('-',6));
      END IF;
      IF p_entrepeneur_email IS NOT NULL
      THEN
        log('STEP 3.2.6','Create email address');
        create_email_contact_point
        ( p_party_id          => l_new_entre_party_id
        , p_email_address     => p_entrepeneur_email
        );
        out(rpad('I',6));
      ELSE
        out(rpad('-',6));
      END IF;
    ELSIF p_entre_party_id IS NOT NULL
    AND   p_entrepeneur_last_name IS NULL
    THEN
      log('STEP 3.3','Did find an existing entrepeneur, but no new one, so delete existing.');
      log('STEP 3.3.1','DELETE party record');
      DELETE hz_parties
      WHERE party_id = p_entre_party_id
      ;
      out(rpad('D',6));
      log('STEP 3.3.2','DELETE relationships');
      DELETE hz_relationships
      WHERE subject_id = p_entre_party_id
      ;
      FOR l_del_entre_locations IN c_locations(p_entre_party_id)
      LOOP
        log('STEP 3.3.3','DELETE location');
        DELETE hz_locations
        WHERE  location_id = l_del_entre_locations.location_id
        ;
      END LOOP;
      out(rpad('D',6));

      log('STEP 3.3.4','DELETE address');
      DELETE hz_party_sites
      WHERE  party_id = p_entre_party_id
      ;

      log('STEP 3.3.5','DELETE contact points');
      DELETE hz_contact_points
      WHERE  owner_table_id = p_entre_party_id
      ;
      out(rpad('D',6)); -- phone
      out(rpad('D',6)); -- mobile
      out(rpad('D',6)); -- fax
    ELSE
      out(rpad('-',6)); -- name
      out(rpad('-',6)); -- address
      out(rpad('-',6)); -- phone
      out(rpad('-',6)); -- mobile
      out(rpad('-',6)); -- fax
    END IF;

    -- do intermediate commit
    COMMIT;

  END update_entrepeneur;


 /* ************************************************************************
  * PROCEDURE   :  update
  * DESCRIPTION :  This script will update all contracts that are related to the
  *                stores that are mentioned in the XXAH_CONTRACT_CONV_DATA table.
  *                Requirements:
  *                - for an entrepeneur the last name is mandatory
  *                - for an entrepeneur's address the street, house number and
  *                  postal code and city are mandatory
  * PARAMETERS  :  -
  *************************************************************************/
  PROCEDURE update_conversion
  ( errbuf               OUT VARCHAR2
  , retcode              OUT NUMBER
  )
  IS
    CURSOR c_stores
    IS
    SELECT d.store_number
    ,      d.formule
    ,      d.g31
    ,      d.format
    ,      d.wvo
    ,      d.vvo
    ,      d.first_contract_date
    ,      d.last_renovation_date
    ,      d.last_renovation_type
    ,      d.store_status
    ,      d.signature_date
    ,      trim(d.real_estate_property_owner) real_estate_property_owner
    ,      trim(d.avg_main_lessee) avg_main_lessee
    ,      d.store_closing_date
    ,      d.region_number
    ,      d.store_street
    ,      d.store_house_num
    ,      d.store_house_num_add
    ,      d.store_city
    ,      d.store_pc
    ,      d.store_phone_num
    ,      d.store_mobile_num
    ,      d.store_fax_num
    ,      d.legal_entity_name
    ,      d.legal_entity_street
    ,      d.legal_entity_house_num
    ,      d.legal_entity_house_num_add
    ,      d.legal_entity_city
    ,      d.legal_entity_pc
    ,      d.coc_number
    ,      d.legal_entity_type
    ,      d.entrepeneur1_initials
    ,      d.entrepeneur1_middle_name
    ,      d.entrepeneur1_last_name
    ,      d.entrepeneur1_street
    ,      d.entrepeneur1_house_num
    ,      d.entrepeneur1_house_num_add
    ,      d.entrepeneur1_city
    ,      d.entrepeneur1_pc
    ,      replace(d.entrepeneur1_phone_num, ' ', '') entrepeneur1_phone_num
    ,      replace(d.entrepeneur1_mobile_num, ' ', '') entrepeneur1_mobile_num
    ,      replace(d.entrepeneur1_email, ' ', '') entrepeneur1_email
    ,      d.entrepeneur2_initials
    ,      d.entrepeneur2_middle_name
    ,      d.entrepeneur2_last_name
    ,      d.entrepeneur2_street
    ,      d.entrepeneur2_house_num
    ,      d.entrepeneur2_house_num_add
    ,      d.entrepeneur2_city
    ,      d.entrepeneur2_pc
    ,      replace(d.entrepeneur2_phone_num, ' ', '') entrepeneur2_phone_num
    ,      replace(d.entrepeneur2_mobile_num, ' ', '') entrepeneur2_mobile_num
    ,      replace(d.entrepeneur2_email, ' ', '') entrepeneur2_email
    ,      d.entrepeneur3_initials
    ,      d.entrepeneur3_middle_name
    ,      d.entrepeneur3_last_name
    ,      d.entrepeneur3_street
    ,      d.entrepeneur3_house_num
    ,      d.entrepeneur3_house_num_add
    ,      d.entrepeneur3_city
    ,      d.entrepeneur3_pc
    ,      replace(d.entrepeneur3_phone_num, ' ', '') entrepeneur3_phone_num
    ,      replace(d.entrepeneur3_mobile_num, ' ', '') entrepeneur3_mobile_num
    ,      replace(d.entrepeneur3_email, ' ', '') entrepeneur3_email
    ,      d.entrepeneur4_initials
    ,      d.entrepeneur4_middle_name
    ,      d.entrepeneur4_last_name
    ,      d.entrepeneur4_street
    ,      d.entrepeneur4_house_num
    ,      d.entrepeneur4_house_num_add
    ,      d.entrepeneur4_city
    ,      d.entrepeneur4_pc
    ,      replace(d.entrepeneur4_phone_num, ' ', '') entrepeneur4_phone_num
    ,      replace(d.entrepeneur4_mobile_num, ' ', '') entrepeneur4_mobile_num
    ,      replace(d.entrepeneur4_email, ' ', '') entrepeneur4_email
    ,      d.entrepeneur5_initials
    ,      d.entrepeneur5_middle_name
    ,      d.entrepeneur5_last_name
    ,      d.entrepeneur5_street
    ,      d.entrepeneur5_house_num
    ,      d.entrepeneur5_house_num_add
    ,      d.entrepeneur5_city
    ,      d.entrepeneur5_pc
    ,      replace(d.entrepeneur5_phone_num, ' ', '') entrepeneur5_phone_num
    ,      replace(d.entrepeneur5_mobile_num, ' ', '') entrepeneur5_mobile_num
    ,      replace(d.entrepeneur5_email, ' ', '') entrepeneur5_email
    ,      d.frov_filename_1
    ,      d.frov_contract_eff_date
    ,      d.frov_contract_exp_date
    ,      d.frov_term_of_notice
    ,      d.frov_ext_sign_date
    ,      d.leen_term_of_notice
    ,      d.terk_term_of_notice
    FROM   xxah_contract_conv_data d
    ;

    CURSOR c_current_entres
    ( b_store_party_id  IN NUMBER
    , b_store_number    IN VARCHAR2
    )
    IS
    SELECT a.subject_id  entrep_party_id
    ,      b.entrep_num
    ,      b.entrep_initials
    ,      b.entrep_middle_name
    ,      b.entrep_last_name
    ,      b.entrep_street
    ,      b.entrep_house_num
    ,      b.entrep_house_num_add
    ,      b.entrep_city
    ,      b.entrep_pc
    ,      b.entrep_phone_num
    ,      b.entrep_mobile_num
    ,      b.entrep_email
    FROM
    (SELECT rownum row_num
     ,      r.subject_id
     FROM   HZ_RELATIONSHIPS r
     WHERE  r.object_id = b_store_party_id
    ) a
    ,
    (SELECT   entreps.*
     FROM     (SELECT 1 entrep_num
               ,      d.store_number
               ,      d.entrepeneur1_initials       entrep_initials
               ,      d.entrepeneur1_middle_name    entrep_middle_name
               ,      d.entrepeneur1_last_name      entrep_last_name
               ,      d.entrepeneur1_street         entrep_street
               ,      d.entrepeneur1_house_num      entrep_house_num
               ,      d.entrepeneur1_house_num_add  entrep_house_num_add
               ,      d.entrepeneur1_city           entrep_city
               ,      d.entrepeneur1_pc             entrep_pc
               ,      d.entrepeneur1_phone_num      entrep_phone_num
               ,      d.entrepeneur1_mobile_num     entrep_mobile_num
               ,      d.entrepeneur1_email          entrep_email
               FROM   xxah_contract_conv_data d
               UNION ALL
               SELECT 2 entrep_num
               ,      d.store_number
               ,      d.entrepeneur2_initials       entrep_initials
               ,      d.entrepeneur2_middle_name    entrep_middle_name
               ,      d.entrepeneur2_last_name      entrep_last_name
               ,      d.entrepeneur2_street         entrep_street
               ,      d.entrepeneur2_house_num      entrep_house_num
               ,      d.entrepeneur2_house_num_add  entrep_house_num_add
               ,      d.entrepeneur2_city           entrep_city
               ,      d.entrepeneur2_pc             entrep_pc
               ,      d.entrepeneur2_phone_num      entrep_phone_num
               ,      d.entrepeneur2_mobile_num     entrep_mobile_num
               ,      d.entrepeneur2_email          entrep_email
               FROM   xxah_contract_conv_data d
               UNION ALL
               SELECT 3 entrep_num
               ,      d.store_number
               ,      d.entrepeneur3_initials       entrep_initials
               ,      d.entrepeneur3_middle_name    entrep_middle_name
               ,      d.entrepeneur3_last_name      entrep_last_name
               ,      d.entrepeneur3_street         entrep_street
               ,      d.entrepeneur3_house_num      entrep_house_num
               ,      d.entrepeneur3_house_num_add  entrep_house_num_add
               ,      d.entrepeneur3_city           entrep_city
               ,      d.entrepeneur3_pc             entrep_pc
               ,      d.entrepeneur3_phone_num      entrep_phone_num
               ,      d.entrepeneur3_mobile_num     entrep_mobile_num
               ,      d.entrepeneur3_email          entrep_email
               FROM   xxah_contract_conv_data d
               UNION ALL
               SELECT 4 entrep_num
               ,      d.store_number
               ,      d.entrepeneur4_initials       entrep_initials
               ,      d.entrepeneur4_middle_name    entrep_middle_name
               ,      d.entrepeneur4_last_name      entrep_last_name
               ,      d.entrepeneur4_street         entrep_street
               ,      d.entrepeneur4_house_num      entrep_house_num
               ,      d.entrepeneur4_house_num_add  entrep_house_num_add
               ,      d.entrepeneur4_city           entrep_city
               ,      d.entrepeneur4_pc             entrep_pc
               ,      d.entrepeneur4_phone_num      entrep_phone_num
               ,      d.entrepeneur4_mobile_num     entrep_mobile_num
               ,      d.entrepeneur4_email          entrep_email
               FROM   xxah_contract_conv_data d
               UNION ALL
               SELECT 5 entrep_num
               ,      d.store_number
               ,      d.entrepeneur5_initials       entrep_initials
               ,      d.entrepeneur5_middle_name    entrep_middle_name
               ,      d.entrepeneur5_last_name      entrep_last_name
               ,      d.entrepeneur5_street         entrep_street
               ,      d.entrepeneur5_house_num      entrep_house_num
               ,      d.entrepeneur5_house_num_add  entrep_house_num_add
               ,      d.entrepeneur5_city           entrep_city
               ,      d.entrepeneur5_pc             entrep_pc
               ,      d.entrepeneur5_phone_num      entrep_phone_num
               ,      d.entrepeneur5_mobile_num     entrep_mobile_num
               ,      d.entrepeneur5_email          entrep_email
               FROM   xxah_contract_conv_data d
              ) entreps
        WHERE  entreps.store_number = b_store_number
    ) b
    WHERE a.row_num (+) = b.entrep_num
    ORDER BY b.entrep_num ASC
    ;

    CURSOR c_phone(b_party_id hz_parties.party_id%TYPE)
    IS
    SELECT contact_point_id
    FROM   hz_contact_points
    WHERE  contact_point_type = 'PHONE'
    AND    phone_line_type = 'GEN'
    AND    owner_table_name = 'HZ_PARTIES'
    AND    owner_table_id = b_party_id
    ;

    CURSOR c_mobile(b_party_id hz_parties.party_id%TYPE)
    IS
    SELECT contact_point_id
    FROM   hz_contact_points
    WHERE  contact_point_type = 'PHONE'
    AND    phone_line_type = 'MOBILE'
    AND    owner_table_name = 'HZ_PARTIES'
    AND    owner_table_id = b_party_id
    ;

    CURSOR c_fax(b_party_id hz_parties.party_id%TYPE)
    IS
    SELECT contact_point_id
    FROM   hz_contact_points
    WHERE  contact_point_type = 'PHONE'
    AND    phone_line_type = 'FAX'
    AND    owner_table_name = 'HZ_PARTIES'
    AND    owner_table_id = b_party_id
    ;

    CURSOR c_deliverables(b_store_number VARCHAR2, b_formule VARCHAR2)
    IS
    SELECT del.deliverable_id
    FROM   okc_deliverables del
    ,      okc_rep_contracts_all con
    WHERE  con.contract_name LIKE b_store_number ||'%'|| b_formule || '%FROV'
    AND    con.contract_id = del.business_document_id
    ;

    CURSOR c_person(b_person_name per_all_people.full_name%TYPE)
    IS
    SELECT person_id
    FROM   per_all_people_f
    WHERE  last_name = b_person_name
    ;

    l_store_party_id         NUMBER;
    l_store_location_id      NUMBER;
    l_le_party_id            NUMBER;
    l_le_location_id         NUMBER;
    l_le_party_site_id       NUMBER;
    l_store_contact_point_id NUMBER;
    -- l_deliverable_id         NUMBER;
    l_new_le_location_id     NUMBER;
    l_new_le_party_site_id   NUMBER;
    l_le_party_number        VARCHAR2(50);

    l_counter                NUMBER := 0;
    l_del_counter            NUMBER := 0;
    l_person_id              NUMBER;
    l_frov_contract_id       okc_rep_contracts_all.contract_id%TYPE;
    l_frov_contract_number   okc_rep_contracts_all.contract_number%TYPE;
    l_frov_contract_type     okc_rep_contracts_all.contract_type%TYPE;

  BEGIN

    outline(to_char(SYSDATE, 'DD-MM-YYYY HH24:MI:SS'));
    outline('The following stores were updated.');
    outline('-----');
    outline(' ');
    out(rpad('STORE', 5)  || ' ' || rpad('STNAM', 5)  || ' ' || rpad('STADR', 5)  || ' ' || rpad('STPHO', 5)  || ' ' || rpad('STMOB', 5)  || ' ' || rpad('STFAX', 5)  || ' ');
    out(rpad('LENAM', 5)  || ' ' || rpad('LEADR', 5)  || ' ' || rpad('LEDFF', 5)  || ' ' );
    out(rpad('E1NAM', 5)  || ' ' || rpad('E1ADR', 5)  || ' ' || rpad('E1PHO', 5)  || ' ' || rpad('E1MOB', 5)  || ' ' || rpad('E1MAI', 5) || ' ' );
    out(rpad('E2NAM', 5)  || ' ' || rpad('E2ADR', 5)  || ' ' || rpad('E2PHO', 5)  || ' ' || rpad('E2MOB', 5)  || ' ' || rpad('E2MAI', 5) || ' ' );
    out(rpad('E3NAM', 5)  || ' ' || rpad('E3ADR', 5)  || ' ' || rpad('E3PHO', 5)  || ' ' || rpad('E3MOB', 5)  || ' ' || rpad('E3MAI', 5) || ' ' );
    out(rpad('E4NAM', 5)  || ' ' || rpad('E4ADR', 5)  || ' ' || rpad('E4PHO', 5)  || ' ' || rpad('E4MOB', 5)  || ' ' || rpad('E4MAI', 5) || ' ' );
    out(rpad('E5NAM', 5)  || ' ' || rpad('E5ADR', 5)  || ' ' || rpad('E5PHO', 5)  || ' ' || rpad('E5MOB', 5)  || ' ' || rpad('E5MAI', 5) || ' ' );
    outline(rpad('COEFF', 5) || ' ' || rpad('COEXP', 5) || ' ' || rpad('CODEL', 5) || ' ' || rpad('COSIG', 5));

    out(rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' );
    out(rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' );
    out(rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' );
    out(rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' );
    out(rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' );
    outline(rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ');

    FOR r_store IN c_stores LOOP
      -- init and reset
      l_counter  := l_counter + 1;
      l_store_party_id := NULL;
      l_store_location_id := NULL;
      l_store_contact_point_id := NULL;
      l_le_party_id := NULL;
      l_le_location_id := NULL;

     /* ************************************************
      * STEP 1 -   Update store data.
      * ************************************************ */
      out(rpad(r_store.store_number, 4)|| '| ');

      -- STEP 1.1 - Update store party
      BEGIN
        SELECT party_id
        INTO   l_store_party_id
        FROM   hz_parties
        WHERE  party_name = r_store.store_number || ' ' || r_store.formule
        ;
        log('STEP 1.1','Update store party id: ' || l_store_party_id);
        UPDATE hz_parties
        SET    ATTRIBUTE1         = DECODE(r_store.g31, 'Y', 'Yes', 'N', 'No')
        ,      ATTRIBUTE3         = r_store.format
        ,      ATTRIBUTE5         = r_store.wvo
        ,      ATTRIBUTE6         = r_store.vvo
        ,      ATTRIBUTE7         = to_char(r_store.first_contract_date, 'YYYY/MM/DD HH24:MI:SS')
        ,      ATTRIBUTE8         = to_char(r_store.last_renovation_date, 'YYYY/MM/DD HH24:MI:SS')
        ,      ATTRIBUTE9         = r_store.last_renovation_type
        ,      ATTRIBUTE10        = decode(r_store.store_status, 'O', 'Open', 'C', 'Closed')
        ,      ATTRIBUTE11        = to_char(r_store.signature_date, 'YYYY/MM/DD HH24:MI:SS')
        ,      ATTRIBUTE13        = r_store.real_estate_property_owner
        ,      ATTRIBUTE14        = decode(r_store.avg_main_lessee, 'Y', 'Yes', 'N', 'No')
        ,      ATTRIBUTE15        = to_char(r_store.store_closing_date, 'YYYY/MM/DD HH24:MI:SS')
        ,      ATTRIBUTE16        = r_store.region_number
        ,      last_update_date   = SYSDATE
        ,      last_updated_by    = fnd_global.USER_ID
        ,      last_update_login  = fnd_global.LOGIN_ID
        WHERE  party_id           = l_store_party_id
        ;
        IF SQL%ROWCOUNT > 0
        THEN
          out(rpad('U', 6));
        ELSE
          out(rpad('-', 6));
        END IF;

        -- STEP 1.2 - Update store party address
        BEGIN
          SELECT s.location_id
          INTO   l_store_location_id
          FROM   hz_party_sites s
          WHERE  s.party_id = l_store_party_id
          AND    s.identifying_address_flag = 'Y'
          ;
        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            l_store_location_id := NULL;
        END;

        log('STEP 1.2','Update store party address location_id: ' || l_store_location_id);
        UPDATE hz_locations
        SET    address1           = trim(r_store.store_street  || ' ' || r_store.store_house_num || ' ' || r_store.store_house_num_add)
        ,      city               = r_store.store_city
        ,      postal_code        = r_store.store_pc
        ,      last_update_date   = SYSDATE
        ,      last_updated_by    = fnd_global.USER_ID
        ,      last_update_login  = fnd_global.LOGIN_ID
        WHERE  location_id        = l_store_location_id
        ;
        UPDATE hz_parties
        SET    address1           = trim(r_store.store_street  || ' ' || r_store.store_house_num || ' ' || r_store.store_house_num_add)
        ,      city               = r_store.store_city
        ,      postal_code        = r_store.store_pc
        ,      last_update_date   = SYSDATE
        ,      last_updated_by    = fnd_global.USER_ID
        ,      last_update_login  = fnd_global.LOGIN_ID
        WHERE  party_id           = l_store_party_id
        ;
        IF SQL%ROWCOUNT > 0
        THEN
          out(rpad('U', 6));
        ELSE
          out(rpad('-', 6));
        END IF;

        -- STEP 1.3 - Update store phone
        log('STEP 1.3','Update store phone');
        OPEN  c_phone(l_store_party_id);
        FETCH c_phone INTO l_store_contact_point_id;
        CLOSE c_phone;

        IF l_store_contact_point_id IS NULL
        AND r_store.store_phone_num IS NOT NULL
        THEN
          log('STEP 1.3.1','Insert new contact point for this phone');
          create_phone_contact_point
          ( p_party_id        => l_store_party_id
          , p_phone_line_type => 'GEN'
          , p_phone_number    => r_store.store_phone_num
          );
          out(rpad('I', 6));
        ELSIF l_store_contact_point_id IS NOT NULL
        AND   r_store.store_phone_num IS NULL
        THEN
          log('STEP 1.3.2','Delete contact point for phone');
          DELETE hz_contact_points
          WHERE contact_point_id = l_store_contact_point_id
          ;
          out(rpad('D', 6));
        ELSIF l_store_contact_point_id IS NOT NULL
        AND   r_store.store_phone_num IS NOT NULL
        THEN
          log('STEP 1.3.3','Update contact point for phone');
          update_phone_contact_point
          ( p_party_id          => l_store_party_id
          , p_contact_point_id  => l_store_contact_point_id
          , p_phone_line_type   => 'GEN'
          , p_phone_number      => r_store.store_phone_num
          );
          out(rpad('U', 6));
        ELSE
          out(rpad('-',6));
        END IF;

        -- reset
        l_store_contact_point_id := NULL;

        log('STEP 1.4','Update store mobile');
        OPEN  c_mobile(l_store_party_id);
        FETCH c_mobile INTO l_store_contact_point_id;
        CLOSE c_mobile
        ;
        IF l_store_contact_point_id IS NULL
        AND r_store.store_mobile_num IS NOT NULL
        THEN
          log('STEP 1.4.1','Insert new contact point for this mobile');
          create_phone_contact_point
          ( p_party_id        => l_store_party_id
          , p_phone_line_type => 'MOBILE'
          , p_phone_number    => r_store.store_mobile_num
          );
          out(rpad('N', 6));
        ELSIF l_store_contact_point_id IS NOT NULL
        AND   r_store.store_mobile_num IS NULL
        THEN
          log('STEP 1.4.2','Delete contact point for phone');
          DELETE hz_contact_points
          WHERE contact_point_id = l_store_contact_point_id
          ;
          out(rpad('D', 6));
        ELSIF l_store_contact_point_id IS NOT NULL
        AND   r_store.store_mobile_num IS NOT NULL
        THEN
          log('STEP 1.4.3','Update contact point for pone');
          update_phone_contact_point
          ( p_party_id          => l_store_party_id
          , p_contact_point_id  => l_store_contact_point_id
          , p_phone_line_type   => 'MOBILE'
          , p_phone_number      => r_store.store_mobile_num
          );
          out(rpad('U', 6));
        ELSE
          out(rpad('-',6));
        END IF;

        -- reset
        l_store_contact_point_id := NULL;

        log('STEP 1.5','Update store fax');
        OPEN  c_fax(l_store_party_id);
        FETCH c_fax INTO l_store_contact_point_id;
        CLOSE c_fax;

        IF  l_store_contact_point_id IS NULL
        AND r_store.store_fax_num IS NOT NULL
        THEN
          log('STEP 1.5.1','Insert new contact point for this fax');
          create_phone_contact_point
          ( p_party_id        => l_store_party_id
          , p_phone_line_type => gc_phone_line_type_fax
          , p_phone_number    => r_store.store_fax_num
          );
          out(rpad('I', 6));
        ELSIF l_store_contact_point_id IS NOT NULL
        AND   r_store.store_fax_num IS NULL
        THEN
          log('STEP 1.5.2','Delete contact point for phone');
          DELETE hz_contact_points
          WHERE contact_point_id = l_store_contact_point_id
          ;
          out(rpad('D', 6));
        ELSIF l_store_contact_point_id IS NOT NULL
        AND   r_store.store_fax_num IS NOT NULL
        THEN
          log('STEP 1.5.3','Update contact point');
          update_phone_contact_point
          ( p_party_id          => l_store_party_id
          , p_contact_point_id  => l_store_contact_point_id
          , p_phone_line_type   => gc_phone_line_type_fax
          , p_phone_number      => r_store.store_fax_num
          );
          out(rpad('U', 6));
        ELSE
          out(rpad('-',6));
        END IF;

       /* ************************************************
        * STEP 2 - Update Legal Entity data.
        * *********************************************** */
        DECLARE
          CURSOR c_legal_entity(b_store_number VARCHAR2)
          IS
          SELECT DISTINCT hp.party_id
          INTO   l_le_party_id
          FROM   okc_rep_contracts_all c
          ,      Okc_Rep_Contract_Parties p
          ,      hz_parties hp
          WHERE  c.contract_name LIKE b_store_number || '%' || 'FROV'
          AND    p.contract_id = c.contract_id
          AND    p.party_role_code = 'PARTNER_ORG'
          AND    p.party_id = hp.party_id
          AND    hp.party_type = 'ORGANIZATION'
          AND    hp.attribute_category IS NULL
          AND    hp.party_name NOT IN ('Etos', 'Gall '||Chr(38)||' Gall', 'Albert Heijn')
          ;
        BEGIN

          OPEN c_legal_entity(r_store.store_number);
          FETCH c_legal_entity INTO l_le_party_id;
          CLOSE c_legal_entity;

        END;

        IF l_le_party_id IS NOT NULL
        THEN
          log('STEP 2.1','Legal Entity Party Id: ' || l_le_party_id);
          UPDATE hz_parties
          SET    party_name         = r_store.legal_entity_name
          ,      last_update_date   = SYSDATE
          ,      last_updated_by    = fnd_global.USER_ID
          ,      last_update_login  = fnd_global.LOGIN_ID
          WHERE  party_id           = l_le_party_id
          ;
          IF SQL%ROWCOUNT > 0
          THEN
            out(rpad('U', 6));
          ELSE
            out(rpad('-', 6));
          END IF;


          BEGIN
            SELECT s.location_id
            INTO   l_le_location_id
            FROM   hz_party_sites s
            WHERE  s.party_id = l_le_party_id
            AND    s.identifying_address_flag = 'Y'
            ;
          EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
              l_le_location_id := NULL;
          END;

          IF l_le_location_id IS NOT NULL
          AND r_store.legal_entity_street IS NOT NULL
          THEN
            log('STEP 2.2','Legal Entity Address Location Id: ' || l_le_location_id);
            UPDATE hz_locations
            SET    address1           = trim(r_store.legal_entity_street  || ' ' || r_store.legal_entity_house_num || ' ' || r_store.legal_entity_house_num_add)
            ,      city               = r_store.legal_entity_city
            ,      postal_code        = r_store.legal_entity_pc
            ,      last_update_date   = SYSDATE
            ,      last_updated_by    = fnd_global.USER_ID
            ,      last_update_login  = fnd_global.LOGIN_ID
            WHERE  location_id        = l_le_location_id
            ;
            IF SQL%ROWCOUNT > 0
            THEN
              out(rpad('U', 6));
            ELSE
              out(rpad('-', 6));
            END IF;

            BEGIN
              SELECT s.party_site_id
              INTO   l_le_party_site_id
              FROM   hz_party_sites s
              WHERE  s.party_id = l_le_party_id
              AND    s.identifying_address_flag = 'Y'
              ;
            EXCEPTION
              WHEN NO_DATA_FOUND
              THEN
                l_le_party_site_id := NULL;
            END;
            IF l_le_party_site_id IS NOT NULL
            THEN
              log('STEP 2.3','Legal Entity Address Flexfields Party Site Id: ' || l_le_party_site_id);
              UPDATE hz_party_sites
              SET    attribute1         = r_store.coc_number
              ,      attribute2         = r_store.legal_entity_type
              ,      last_update_date   = SYSDATE
              ,      last_updated_by    = fnd_global.USER_ID
              ,      last_update_login  = fnd_global.LOGIN_ID
              WHERE  party_site_id      = l_le_party_site_id
              ;
              IF SQL%ROWCOUNT > 0
              THEN
                out(rpad('U', 6));
              ELSE
                out(rpad('-', 6));
              END IF;
            ELSE
              out(rpad('-', 6));
            END IF;
          ELSIF l_le_location_id IS NULL
          AND   r_store.legal_entity_street IS NOT NULL THEN
            -- create legal entity address
            create_location
            ( p_address_street         => r_store.legal_entity_street
            , p_address_house_num      => r_store.legal_entity_house_num
            , p_address_house_num_add  => r_store.legal_entity_house_num_add
            , p_address_city           => r_store.legal_entity_city
            , p_address_pc             => r_store.legal_entity_pc
            , p_location_id            => l_new_le_location_id
            );
            create_party_site
            ( p_party_id              => l_le_party_id
            , p_location_id           => l_new_le_location_id
            , p_party_site_id         => l_new_le_party_site_id
            );
            out(rpad('I', 6));
            UPDATE hz_party_sites
            SET    attribute1         = r_store.coc_number
            ,      attribute2         = r_store.legal_entity_type
            ,      last_update_date   = SYSDATE
            ,      last_updated_by    = fnd_global.USER_ID
            ,      last_update_login  = fnd_global.LOGIN_ID
            WHERE  party_site_id      = l_new_le_party_site_id
            ;
            out(rpad('I', 6));
          ELSIF l_le_location_id IS NOT NULL
          AND   r_store.legal_entity_street IS NULL
          THEN
            -- delete address
            log('STEP 3.3.3','DELETE location');
            DELETE hz_locations
            WHERE  location_id = l_le_location_id
            ;
            out(rpad('D',6));

            log('STEP 3.3.4','DELETE address');
            DELETE hz_party_sites
            WHERE  party_id = l_le_party_id
            ;
            out(rpad('D', 6));
          ELSE

            out(rpad('-', 6));
            out(rpad('-', 6));
          END IF;
        ELSE
          log('STEP 2','No Legal Entity Found, so no update is possible!');
          log('Exception','Legal Entity ('||r_store.legal_entity_name||') should exist.');

          l_new_le_party_site_id := NULL;
          l_new_le_location_id := NULL;

          -- create legal entity party
          create_party_org
          ( p_org_name     => r_store.legal_entity_name
          , p_party_number => l_le_party_number
          , p_party_id     => l_le_party_id
          );
          out(rpad('I', 6));
          -- party site
          create_location
          ( p_address_street         => r_store.legal_entity_street
          , p_address_house_num      => r_store.legal_entity_house_num
          , p_address_house_num_add  => r_store.legal_entity_house_num_add
          , p_address_city           => r_store.legal_entity_city
          , p_address_pc             => r_store.legal_entity_pc
          , p_location_id            => l_new_le_location_id
          );
          create_party_site
          ( p_party_id              => l_le_party_id
          , p_location_id           => l_new_le_location_id
          , p_party_site_id         => l_new_le_party_site_id
          );
          out(rpad('I', 6));

          -- fill flexfields
          UPDATE hz_party_sites
          SET    attribute1         = r_store.coc_number
          ,      attribute2         = r_store.legal_entity_type
          ,      last_update_date   = SYSDATE
          ,      last_updated_by    = fnd_global.USER_ID
          ,      last_update_login  = fnd_global.LOGIN_ID
          WHERE  party_site_id      = l_new_le_party_site_id
          ;
          IF SQL%ROWCOUNT > 0
          THEN
            out(rpad('I', 6));
          ELSE
            out(rpad('-', 6));
          END IF;
          -- create contact

          -- out(rpad('-', 6) || rpad('-', 6) || rpad('-', 6));
        END IF;

       /* ************************************************
        * STEP 3 - Update entrepeneur data.
        * *********************************************** */
        log('STEP 3','Loop over entrepeneurs');
        FOR r_entre IN c_current_entres(l_store_party_id, r_store.store_number)
        LOOP
          update_entrepeneur
          ( r_entre.entrep_party_id
          , replace(r_entre.entrep_initials,'.')
          , r_entre.entrep_middle_name
          , r_entre.entrep_last_name
          , r_entre.entrep_street
          , r_entre.entrep_house_num
          , r_entre.entrep_house_num_add
          , r_entre.entrep_city
          , r_entre.entrep_pc
          , r_entre.entrep_phone_num
          , r_entre.entrep_mobile_num
          , r_entre.entrep_email
          , l_store_party_id
          , l_le_party_id
          );
        END LOOP;

       /* ************************************************
        * STEP 4 - Update Legal Entity data.
        * *********************************************** */

        -- check if contract exists
        DECLARE
          CURSOR c_contract_exists
          ( b_store_number  VARCHAR2
          , b_store_formule VARCHAR2
          )
          IS
          SELECT contract_id
          ,      contract_number
          ,      contract_type
          INTO   l_frov_contract_id
          ,      l_frov_contract_number
          ,      l_frov_contract_type
          FROM   okc_rep_contracts_all c
          WHERE  c.contract_name LIKE b_store_number ||'%'|| b_store_formule || '%FROV%'
          ;
        BEGIN
          l_frov_contract_id := NULL;

          OPEN c_contract_exists(r_store.store_number, r_store.formule);
          FETCH c_contract_exists INTO l_frov_contract_id, l_frov_contract_number, l_frov_contract_type;
          CLOSE c_contract_exists;
        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            IF r_store.frov_filename_1 IS NOT NULL
            THEN
               log('STEP 4', 'WARNING: Please first upload FROV file for ' || r_store.store_number);
            ELSE
               log('STEP 4', 'WARNING: No FROV contract definition found for ' || r_store.store_number);
            END IF;
        END;

        log('STEP 4.1','Contact effective date: ' || to_char(r_store.frov_contract_eff_date, 'DD-MM-YYYY'));
        UPDATE okc_rep_contracts_all c
        SET    c.contract_effective_date = r_store.frov_contract_eff_date
        ,      c.last_update_date        = SYSDATE
        ,      c.last_updated_by         = fnd_global.USER_ID
        ,      c.last_update_login       = fnd_global.LOGIN_ID
        WHERE  c.contract_name LIKE r_store.store_number ||'%'|| r_store.formule || '%'
        ;
        IF SQL%ROWCOUNT > 0
        THEN
          out(rpad('U',6));
        ELSE
          out(rpad('-',6));
        END IF
        ;
        log('STEP 4.2','Contact expiration date: ' || to_char(r_store.frov_contract_exp_date, 'DD-MM-YYYY'));
        UPDATE okc_rep_contracts_all c
        SET    c.contract_expiration_date = r_store.frov_contract_exp_date
        ,      c.last_update_date         = SYSDATE
        ,      c.last_updated_by          = fnd_global.USER_ID
        ,      c.last_update_login        = fnd_global.LOGIN_ID
        WHERE  c.contract_name LIKE r_store.store_number ||'%'|| r_store.formule || '%FROV'
        ;
        IF SQL%ROWCOUNT > 0
        THEN
          out(rpad('U',6));
        ELSE
          out(rpad('-',6));
        END IF
        ;

        IF  r_store.frov_term_of_notice IS NULL
        AND l_frov_contract_id IS NOT NULL
        THEN
          log('STEP 4.3','WARNING: no FROV term of notice found: ' || r_store.store_number);
          out(rpad('-',6));
        ELSIF l_frov_contract_id IS NOT NULL
        AND   r_store.frov_term_of_notice IS NOT NULL
        THEN
          -- so term of notice is filled, and there is a contract
          log('STEP 4.3','Deliverable date: ' || to_char(r_store.frov_term_of_notice, 'DD-MM-YYYY'))
          ;
          l_del_counter := 0;
          FOR r_del IN c_deliverables(r_store.store_number, r_store.formule)
          LOOP
            l_del_counter := l_del_counter + 1;
            IF r_del.deliverable_id IS NOT NULL
            THEN

              UPDATE okc_deliverables
              SET    actual_due_date    = r_store.frov_term_of_notice
              ,      fixed_start_date   = r_store.frov_term_of_notice
              ,      last_update_date   = SYSDATE
              ,      last_updated_by    = fnd_global.USER_ID
              ,      last_update_login  = fnd_global.LOGIN_ID
              WHERE  deliverable_id     = r_del.deliverable_id
              ;
              IF SQL%ROWCOUNT > 0
              THEN
                -- deliverable found, and updated it
                out(rpad('U',6));
              END IF;
            END IF;
          END LOOP;

          IF l_del_counter = 0
          THEN
            -- no deliverables found, but there is a FROV contract
            log('STEP 4.3','WARNING: no deliverables found for FROV of store: ' || r_store.store_number);

            OPEN c_person('Koevoets');
            FETCH c_person INTO l_person_id;
            CLOSE c_person;

            INSERT INTO okc_deliverables
             ( DELIVERABLE_ID
             , BUSINESS_DOCUMENT_TYPE
             , BUSINESS_DOCUMENT_ID
             , BUSINESS_DOCUMENT_NUMBER
             , DELIVERABLE_TYPE
             , RESPONSIBLE_PARTY
             , INTERNAL_PARTY_CONTACT_ID
             , EXTERNAL_PARTY_CONTACT_ID
             , DELIVERABLE_NAME
             , DESCRIPTION
             , COMMENTS
             , DISPLAY_SEQUENCE
             , FIXED_DUE_DATE_YN
             , ACTUAL_DUE_DATE
             , PRINT_DUE_DATE_MSG_NAME
             , RECURRING_YN
             , NOTIFY_PRIOR_DUE_DATE_VALUE
             , NOTIFY_PRIOR_DUE_DATE_UOM
             , NOTIFY_PRIOR_DUE_DATE_YN
             , NOTIFY_COMPLETED_YN
             , NOTIFY_OVERDUE_YN
             , NOTIFY_ESCALATION_YN
             , NOTIFY_ESCALATION_VALUE
             , NOTIFY_ESCALATION_UOM
             , ESCALATION_ASSIGNEE
             , AMENDMENT_OPERATION
             , PRIOR_NOTIFICATION_ID
             , AMENDMENT_NOTES
             , COMPLETED_NOTIFICATION_ID
             , OVERDUE_NOTIFICATION_ID
             , ESCALATION_NOTIFICATION_ID
             , LANGUAGE
             , ORIGINAL_DELIVERABLE_ID
             , REQUESTER_ID
             , EXTERNAL_PARTY_ID
             , EXTERNAL_PARTY_ROLE
             , BUSINESS_DOCUMENT_VERSION
             , FIXED_START_DATE
             , FIXED_END_DATE
             , MANAGE_YN
             , INTERNAL_PARTY_ID
             , DELIVERABLE_STATUS
             , STATUS_CHANGE_NOTES
             , CREATED_BY
             , CREATION_DATE
             , LAST_UPDATED_BY
             , LAST_UPDATE_DATE
             , LAST_UPDATE_LOGIN
             , OBJECT_VERSION_NUMBER
             , DISABLE_NOTIFICATIONS_YN
             , LAST_AMENDMENT_DATE
             , SUMMARY_AMEND_OPERATION_CODE)
             VALUES
             ( okc_deliverable_id_s.nextval -- DELIVERABLE_ID
             , l_frov_contract_type         -- BUSINESS_DOCUMENT_TYPE
             , l_frov_contract_id           -- BUSINESS_DOCUMENT_ID
             , l_frov_contract_number       -- BUSINESS_DOCUMENT_NUMBER
             , 'CONTRACTUAL'                -- DELIVERABLE_TYPE
             , 'INTERNAL_ORG'               -- RESPONSIBLE_PARTY
             , l_person_id                  -- INTERNAL_PARTY_CONTACT_ID
             , NULL                         -- EXTERNAL_PARTY_CONTACT_ID
             , 'Opzegtermijn'               -- DELIVERABLE_NAME
             , NULL                         -- DESCRIPTION
             , 'Created by FAM contracts conversion correction on ' || to_char(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') -- COMMENTS
             , 680                          -- DISPLAY_SEQUENCE
             , 'Y'                          -- FIXED_DUE_DATE_YN
             , NULL                         -- ACTUAL_DUE_DATE
             , NULL                         -- PRINT_DUE_DATE_MSG_NAME
             , 'N'                          -- RECURRING_YN
             , 180                          -- NOTIFY_PRIOR_DUE_DATE_VALUE
             , 'DAY'                        -- NOTIFY_PRIOR_DUE_DATE_UOM
             , 'Y'                          -- NOTIFY_PRIOR_DUE_DATE_YN
             , 'N'                          -- NOTIFY_COMPLETED_YN
             , 'N'                          -- NOTIFY_OVERDUE_YN
             , 'N'                          -- NOTIFY_ESCALATION_YN
             , NULL                         -- NOTIFY_ESCALATION_VALUE
             , NULL                         -- NOTIFY_ESCALATION_OUM
             , NULL                         -- ESCALATION_ASSIGNEE
             , NULL                         -- AMENDMENT_OPERATION
             , NULL                         -- PRIOR_NOTIFICATION_ID
             , NULL                         -- AMENDMENT_NOTES
             , NULL                         -- COMPLETED_NOTIFICATION_ID
             , NULL                         -- OVERDUE_NOTIFICATION_ID
             , NULL                         -- ESCALATION_NOTIFICATION_ID
             , 'US'                         -- LANGUAGE
             , okc_deliverable_id_s.currval -- ORIGINAL_DELIVERABLE_ID
             , NULL                         -- REQUESTOR_ID
             , NULL                         -- EXTERNAL_PARTY_ID
             , NULL                         -- EXTERNAL_PARTY_ROLE
             , -99                          -- BUSINESS_DOCUMENT_VERSION
             , r_store.frov_term_of_notice  -- FIXED_START_DATE
             , NULL                         -- FIXED_END_DATE
             , 'N'                          -- MANAGE_YN
             , 127                          -- INTERNAL_PARTY_ID
             , 'INACTIVE'                   -- DELIVERABLE_STATUS
             , NULL                         -- STATUS_CHANGE_NOTES
             , FND_GLOBAL.user_id           -- CREATED_BY
             , SYSDATE                      -- CREATION_DATE
             , FND_GLOBAL.user_id           -- LAST_UPDATED_BY
             , SYSDATE                      -- LAST_UPDATE_DATE
             , FND_GLOBAL.LOGIN_ID          -- LAST_UPDATE_LOGIN
             , 1                            -- OBJECT_VERSION_NUMBER
             , 'N'                          -- DISABLE_NOTIFICATIONS_YN
             , SYSDATE                      -- LAST_AMENDMENT_DATE
             , 'ADDED'                      -- SUMMARY_AMEND_OPERATION_CODE
             );

             IF SQL%ROWCOUNT > 0
             THEN
               out(rpad('I', 6));
             ELSE
               out(rpad('-', 6));
             END IF;
          END IF;
        ELSE
          -- else there is no FROV contract
          out(rpad('-', 6));

        END IF;

        log('STEP 4.4','Update sign dates: ' || to_char(r_store.frov_ext_sign_date, 'DD-MM-YYYY'));
        UPDATE okc_rep_signature_details
        SET    signed_date        = r_store.frov_ext_sign_date
        ,      last_update_date   = SYSDATE
        ,      last_updated_by    = fnd_global.USER_ID
        ,      last_update_login  = fnd_global.LOGIN_ID
        WHERE  contract_id IN (SELECT c.contract_id
                               FROM okc_rep_contracts_all c
                               WHERE  c.contract_name LIKE r_store.store_number || '%' || r_store.formule || '%')
        ;
        IF SQL%ROWCOUNT > 0
        THEN
          out(rpad('U',6));
        ELSE
          out(rpad('-',6));
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          log('Store '|| r_store.store_number || ' not found!');
      END;
      -- end output line
      outline('');
    END LOOP;

    COMMIT;

    out(rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' );
    out(rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' );
    out(rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' );
    out(rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' );
    out(rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' );
    outline(rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ' || rpad('-', 5, '-') || ' ');

    IF l_counter = 1
    THEN
      outline(l_counter || ' store updated.');
    ELSIF l_counter = 0
    THEN
      outline('No stores updated.');
    ELSE
     outline(l_counter || ' stores updated.');
    END IF;
  END update_conversion;

END XXAH_CONTRACT_CONV_UPDATE_PKG;

/
