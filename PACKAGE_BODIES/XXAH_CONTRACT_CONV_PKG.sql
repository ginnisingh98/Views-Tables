--------------------------------------------------------
--  DDL for Package Body XXAH_CONTRACT_CONV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_CONTRACT_CONV_PKG" AS
 /* ************************************************************************
  * Copyright (c)  2010    Oracle Netherlands             De Meern
  * All rights reserved
  **************************************************************************
  *
  * FILENAME           : XXAH_CONTRACT_CONV_PKG.pkb
  * AITHOR             : Kevin Bouwmeester, Oracle NL Appstech
  * DESCRIPTION        : Package specification with logic for the franchise
  *                      contract conversion.
  *
  * HISTORY
  * =======
  *
  * VER  DATE         AUTHOR(S)          DESCRIPTION
  * ---  -----------  -----------------  -----------------------------------
  * 1.0  16-DEC-2009  Kevin Bouwmeester  Genesis
  * 2.0  01-MAR-2011  Joost Voordouw      CRD Update
  *************************************************************************/

  -- ----------------------------------------------------------------------
  -- Private constants
  -- ----------------------------------------------------------------------
  gc_package_name             CONSTANT VARCHAR2(  32)                            := 'xxah_contract_conv_pkg';
  gc_log_prefix               CONSTANT VARCHAR2(  50)                            := 'apps.plsql.'
                                                                                 || gc_package_name
                                                                                 || '.';
  gc_party_type_organization   CONSTANT hz_parties.party_type%TYPE                := 'ORGANIZATION';
  gc_party_type_person         CONSTANT hz_parties.party_type%TYPE                := 'PERSON';
  gc_created_by_module         CONSTANT VARCHAR2( 150)                            := 'XXAH_CONTRACT_CONV_PKG';
  gc_status_active             CONSTANT VARCHAR2(   1)                            := 'A';
  gc_application_id            CONSTANT NUMBER                                    := fnd_global.prog_appl_id;
  gc_contact_point_type_phone  CONSTANT hz_contact_points.contact_point_type%TYPE := 'PHONE';
  gc_contact_point_type_email  CONSTANT hz_contact_points.contact_point_type%TYPE := 'EMAIL';
  gc_phone_line_type_general   CONSTANT hz_contact_points.phone_line_type%TYPE    := 'GEN';
  gc_phone_line_type_mobile    CONSTANT hz_contact_points.phone_line_type%TYPE    := 'MOBILE';
  gc_phone_line_type_fax       CONSTANT hz_contact_points.phone_line_type%TYPE    := 'FAX';
  gc_site_use_type_bill_to     CONSTANT hz_party_site_uses.site_use_type%TYPE     := 'BILL_TO';
--  gc_contact_person_suffix     CONSTANT VARCHAR2(   2)                            := 'cp';

--  gc_org_contact_suffix        CONSTANT VARCHAR2(   2)                            := 'oc';
  gc_default_email_format      CONSTANT hz_contact_points.email_format%TYPE       := 'MAILTEXT';
--  gc_orig_system               CONSTANT VARCHAR2(  10)                            := 'AH_CM_CONV';
  gc_person_category_code      CONSTANT hz_parties.category_code%TYPE             := 'CUSTOMER';
  -- statusses
  gc_staging_new               CONSTANT xxah_contract_conv_data.store_process_status%TYPE := '0';
  gc_staging_process           CONSTANT xxah_contract_conv_data.store_process_status%TYPE := '1';
  gc_staging_error             CONSTANT xxah_contract_conv_data.store_process_status%TYPE := '2';
  gc_staging_done              CONSTANT xxah_contract_conv_data.store_process_status%TYPE := '400';

  gc_separator                 CONSTANT VARCHAR2(1)                               := ',';
  -- ----------------------------------------------------------------------
  -- Private exceptions
  -- ----------------------------------------------------------------------
  e_conv_exception EXCEPTION;

  -- ----------------------------------------------------------------------
  -- Public cursors
  -- ----------------------------------------------------------------------
  CURSOR c_party_exists
  ( b_party_name IN hz_parties.party_name%TYPE
  , b_party_type IN hz_parties.party_type%TYPE
  )
  IS
  SELECT party_id, party_number
  FROM   hz_parties
  WHERE  party_name = b_party_name
  AND    party_type = b_party_type
  ;

  CURSOR c_party_address_exists
  ( b_party_id    hz_parties.party_id%TYPE
  , b_postal_code hz_locations.postal_code%TYPE)
  IS
  SELECT l.location_id
  FROM   hz_locations l
  ,      hz_party_sites s
  WHERE  s.party_id = b_party_id
  AND    s.location_id = l.location_id
  AND    l.postal_code = b_postal_code
  ;

  CURSOR c_party_phone_exists
  ( b_party_id      hz_parties.party_id%TYPE
  , b_phone_number  hz_contact_points.raw_phone_number%TYPE)
  IS
  SELECT c.contact_point_id
  FROM   hz_contact_points c
  WHERE  c.owner_table_name = 'HZ_PARTIES'
  AND    c.owner_table_id = b_party_id
  AND    c.raw_phone_number = b_phone_number
  ;

  CURSOR c_party_email_exists
  ( b_party_id      hz_parties.party_id%TYPE
  , b_email_address hz_contact_points.email_address%TYPE)
  IS
  SELECT c.contact_point_id
  FROM   hz_contact_points c
  WHERE  c.owner_table_name = 'HZ_PARTIES'
  AND    c.owner_table_id = b_party_id
  AND    c.email_address = b_email_address
  ;

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

  PROCEDURE write_log
    (p_message IN VARCHAR2 DEFAULT NULL
    ) IS
  BEGIN
    fnd_file.put_line
      (fnd_file.log
      ,to_char(systimestamp, 'HH24:MI:SS.FF2 ') || p_message
      );
  END write_log;

  -- --------------------------------------------------------------------
  -- PROCEDURE create_party_org
  -- Create party organization (store, legal entity)
  -- --------------------------------------------------------------------
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

  -- --------------------------------------------------------------------
  -- PROCEDURE create_party_person
  -- Create party person (entrepeneur)
  -- --------------------------------------------------------------------
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

    IF l_return_status != 'S'
    OR l_msg_count > 0
    THEN
      fnd_msg_pub.Add_Exc_Msg
      ( p_pkg_name            => gc_package_name
      , p_procedure_name      => lc_subprogram_name
      , p_error_text          => 'API hz_contact_point_v2pub.create_phone_contact_point '
                          || 'voltooid met status ''' || l_return_status  || ''''
      );

      RAISE e_conv_exception;
    END IF;

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );
  END create_phone_contact_point;

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
  -- PROCEDURE create_location
  -- Create location.
  -- --------------------------------------------------------------------
  PROCEDURE create_location
  ( -- p_party_number            IN hz_parties.party_number%TYPE
    p_address_street          IN hz_locations.address1%TYPE
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

  -- --------------------------------------------------------------------
  -- PROCEDURE create_party_site_use
  -- Create party_site_use.
  -- --------------------------------------------------------------------
  PROCEDURE create_party_site_use
  ( p_party_site_id           IN  NUMBER
  , p_party_site_use_id       OUT NUMBER
  ) IS
    -- Local constants
    lc_subprogram_name        CONSTANT VARCHAR2(30) := 'create_party_site_use';
    -- Local variables
    l_party_site_use_rec      hz_party_site_v2pub.party_site_use_rec_type;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
  BEGIN
    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    l_party_site_use_rec.created_by_module     := gc_created_by_module;
    l_party_site_use_rec.application_id        := gc_application_id;
    l_party_site_use_rec.status                := gc_status_active;
    l_party_site_use_rec.site_use_type         := gc_site_use_type_bill_to;
    l_party_site_use_rec.party_site_id         := p_party_site_id;

    hz_party_site_v2pub.create_party_site_use
    ( p_party_site_use_rec    => l_party_site_use_rec
    , x_party_site_use_id     => p_party_site_use_id
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
      , p_error_text          => 'API hz_party_site_v2pub.create_party_site_use '
                          || 'voltooid met status '''|| l_return_status|| ''''
      );

      RAISE e_conv_exception;
    END IF;

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    ,'End procedure.'
    );
  END create_party_site_use;

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
  -- PROCEDURE process_entre_rec
  -- Create all entities belonging to an entrepeneur record.
  -- --------------------------------------------------------------------
  PROCEDURE process_entre_rec
  ( p_staging_entre_rec       IN t_staging_entre_rec
  , p_entre_party_number      OUT hz_parties.party_number%TYPE
  , p_entre_party_id          OUT hz_parties.party_id%TYPE
  )
  IS

    -- Local constants
    lc_subprogram_name        CONSTANT VARCHAR2(30) := 'process_entre_rec';
    -- Local variables
    l_entre_party_id          hz_parties.party_id%TYPE;
    l_location_id             hz_locations.location_id%TYPE;
    l_party_site_id           hz_party_sites.party_site_id%TYPE;
    l_party_site_use_id       hz_party_site_uses.party_site_use_id%TYPE;
    l_entre_party_number      hz_parties.party_number%TYPE;

    -- check exists variables
    l_phone_contact_point_id  hz_contact_points.contact_point_id%TYPE;
    l_mobile_contact_point_id hz_contact_points.contact_point_id%TYPE;
    l_email_contact_point_id  hz_contact_points.contact_point_id%TYPE;

    l_full_name               hz_parties.party_name%TYPE;

    l_oc_party_id     hz_parties.party_id%TYPE;
  BEGIN

    -- combine the full_name
    IF p_staging_entre_rec.entrep_middle IS NOT NULL
    THEN
        l_full_name := p_staging_entre_rec.entrep_initials || ' ' || p_staging_entre_rec.entrep_middle || ' ' || p_staging_entre_rec.entrep_last;
    ELSE
        l_full_name := p_staging_entre_rec.entrep_initials || ' ' || p_staging_entre_rec.entrep_last;
    END IF;

    -- check if party already exists

    OPEN  c_party_exists
    ( b_party_name => l_full_name
    , b_party_type => gc_person_category_code);
    FETCH c_party_exists INTO l_entre_party_id, l_entre_party_number;
    CLOSE c_party_exists;

    IF l_entre_party_id IS NULL
    THEN

      SELECT hz_party_number_s.nextval
      INTO   l_entre_party_number
      FROM   dual;

      create_party_person
      ( p_pers_firstname        => p_staging_entre_rec.entrep_initials
      , p_pers_middlename       => p_staging_entre_rec.entrep_middle
      , p_pers_lastname         => p_staging_entre_rec.entrep_last
      , p_party_number          => l_entre_party_number
      , p_party_id              => l_entre_party_id
      );

    END IF;

    /*
    IF l_entre_party_id IS NOT NULL
    THEN
      -- fetch all legal entities for this entrepeneur
      FOR r_legal IN c_legal
      ( p_staging_entre_rec.entrep_initials
      , p_staging_entre_rec.entrep_middle
      , p_staging_entre_rec.entrep_last
      )
      LOOP
        IF r_legal.legal_party_id IS NOT NULL
        THEN
          create_org_contact
          ( p_party_id              => r_legal.legal_party_id
          , p_cp_party_id           => l_entre_party_id
          , p_subject_type          => gc_party_type_person
          , p_oc_party_id           => l_oc_party_id
          );
        END IF;
      END LOOP;
    END IF;
    */

    p_entre_party_id          := l_entre_party_id;
    p_entre_party_number      := l_entre_party_number;

    IF p_staging_entre_rec.entrep_street IS NOT NULL
    THEN
      -- check if address with this party already exists, postal code is the key for this
      OPEN c_party_address_exists(l_entre_party_id, p_staging_entre_rec.entrep_pc);
      FETCH c_party_address_exists INTO l_location_id;
      CLOSE c_party_address_exists;

      IF l_location_id IS NULL
      THEN

        create_location
        ( p_address_street        => p_staging_entre_rec.entrep_street
        , p_address_house_num     => p_staging_entre_rec.entrep_house_num
        , p_address_house_num_add => p_staging_entre_rec.entrep_house_add
        , p_address_city          => p_staging_entre_rec.entrep_city
        , p_address_pc            => p_staging_entre_rec.entrep_pc
        , p_location_id           => l_location_id
        );

        create_party_site
        ( p_party_id              => l_entre_party_id
        , p_location_id           => l_location_id
        , p_party_site_id         => l_party_site_id
        );

        create_party_site_use
        ( p_party_site_id         => l_party_site_id
        , p_party_site_use_id     => l_party_site_use_id
        );
      END IF;
    END IF;

    IF p_staging_entre_rec.entrep_phone IS NOT NULL
    THEN
      -- check if phone already exists
      OPEN  c_party_phone_exists(l_entre_party_id, p_staging_entre_rec.entrep_phone);
      FETCH c_party_phone_exists INTO l_phone_contact_point_id;
      CLOSE c_party_phone_exists;

      IF l_phone_contact_point_id IS NULL
      THEN
        create_phone_contact_point
        ( p_party_id              => l_entre_party_id
        , p_phone_line_type       => gc_phone_line_type_general
        , p_phone_number          => p_staging_entre_rec.entrep_phone
        );
      END IF;
    END IF;

    IF p_staging_entre_rec.entrep_mobile IS NOT NULL
    THEN
      -- check if phone already exists
      OPEN  c_party_phone_exists(l_entre_party_id, p_staging_entre_rec.entrep_mobile);
      FETCH c_party_phone_exists INTO l_mobile_contact_point_id;
      CLOSE c_party_phone_exists;

      IF l_mobile_contact_point_id IS NULL
      THEN
        create_phone_contact_point
        ( p_party_id              => l_entre_party_id
        , p_phone_line_type       => gc_phone_line_type_mobile
        , p_phone_number          => p_staging_entre_rec.entrep_mobile
        );
      END IF;
    END IF;

    IF p_staging_entre_rec.entrep_email IS NOT NULL
    THEN
      -- check if email already exists
      OPEN  c_party_email_exists(l_entre_party_id, p_staging_entre_rec.entrep_email);
      FETCH c_party_email_exists INTO l_email_contact_point_id;
      CLOSE c_party_email_exists;

      IF l_email_contact_point_id IS NULL
      THEN
        create_email_contact_point
        ( p_party_id              => l_entre_party_id
        , p_email_address         => p_staging_entre_rec.entrep_email
        );
      END IF;
    END IF;

  END process_entre_rec;

  -- --------------------------------------------------------------------
  -- PROCEDURE process_legal_rec
  -- Create all entities belonging to a store record.
  -- --------------------------------------------------------------------
  PROCEDURE process_legal_rec
  ( p_staging_legal_rec       IN  t_staging_legal_rec
  , p_legal_party_number      OUT hz_parties.party_number%TYPE
  , p_legal_party_id          OUT hz_parties.party_id%TYPE
  )
  IS
    -- Local constants
    lc_subprogram_name        CONSTANT VARCHAR2(30) := 'process_legal_rec';
    -- Local variables
    l_legal_party_id          hz_parties.party_id%TYPE;
    l_legal_party_number      hz_parties.party_number%TYPE;
    l_oc_party_id             hz_parties.party_id%TYPE;
    l_location_id             hz_locations.location_id%TYPE;
    l_party_site_id           hz_party_sites.party_site_id%TYPE;
    l_party_site_use_id       hz_party_site_uses.party_site_use_id%TYPE;

    CURSOR c_entres(b_legal_entity_name IN XXAH_CONTRACT_CONV_DATA.legal_entity_name%TYPE)
    IS
    SELECT entre1_party_id entre_party_id
    FROM   XXAH_CONTRACT_CONV_DATA xcd
    WHERE  xcd.legal_entity_name = b_legal_entity_name
    AND    entre1_party_id IS NOT NULL
    UNION
    SELECT entre2_party_id entre_party_id
    FROM   XXAH_CONTRACT_CONV_DATA xcd
    WHERE  xcd.legal_entity_name = b_legal_entity_name
    AND    entre2_party_id IS NOT NULL
    UNION
    SELECT entre3_party_id entre_party_id
    FROM   XXAH_CONTRACT_CONV_DATA xcd
    WHERE  xcd.legal_entity_name = b_legal_entity_name
    AND    entre3_party_id IS NOT NULL
    UNION
    SELECT entre4_party_id entre_party_id
    FROM   XXAH_CONTRACT_CONV_DATA xcd
    WHERE  xcd.legal_entity_name = b_legal_entity_name
    AND    entre4_party_id IS NOT NULL
    UNION
    SELECT entre5_party_id entre_party_id
    FROM   XXAH_CONTRACT_CONV_DATA xcd
    WHERE  xcd.legal_entity_name = b_legal_entity_name
    AND    entre5_party_id IS NOT NULL
    ;

  BEGIN

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    IF p_staging_legal_rec.legal_entity_name IS NOT NULL
    THEN
      -- check if party already exists
      OPEN  c_party_exists
      ( b_party_name => p_staging_legal_rec.legal_entity_name
      , b_party_type => gc_party_type_organization);
      FETCH c_party_exists INTO l_legal_party_id, l_legal_party_number;
      CLOSE c_party_exists;

      IF l_legal_party_id IS NOT NULL THEN
         outline('<party already exists>');
      END IF;

      IF l_legal_party_id IS NULL
      THEN

        create_party_org
        ( p_org_name              => p_staging_legal_rec.legal_entity_name
        , p_party_number          => l_legal_party_number
        , p_party_id              => l_legal_party_id
        );

        -- process all related entrepeneurs for this legal entity
        FOR r_entres IN c_entres(p_staging_legal_rec.legal_entity_name)
        LOOP
          IF r_entres.entre_party_id IS NOT NULL
          THEN
            create_org_contact
            ( p_party_id             => l_legal_party_id
            , p_cp_party_id          => r_entres.entre_party_id
            , p_subject_type         => gc_party_type_person
            , p_oc_party_id          => l_oc_party_id
            );
          END IF;
        END LOOP;

      END IF;

      p_legal_party_id          := l_legal_party_id;
      p_legal_party_number      := l_legal_party_number;

      IF p_staging_legal_rec.legal_entity_street IS NOT NULL
      THEN
         -- check if address with this party already exists, postal code is the key for this
        OPEN  c_party_address_exists(l_legal_party_id, p_staging_legal_rec.legal_entity_pc);
        FETCH c_party_address_exists INTO l_location_id;
        CLOSE c_party_address_exists;

        IF l_location_id IS NULL
        THEN
          create_location
          ( p_address_street         => p_staging_legal_rec.legal_entity_street
          , p_address_house_num      => p_staging_legal_rec.legal_entity_house_num
          , p_address_house_num_add  => p_staging_legal_rec.legal_entity_house_num_add
          , p_address_city           => p_staging_legal_rec.legal_entity_city
          , p_address_pc             => p_staging_legal_rec.legal_entity_pc
          , p_location_id            => l_location_id
          );

          create_party_site
          ( p_party_id              => l_legal_party_id
          , p_location_id           => l_location_id
          , p_party_site_id         => l_party_site_id
          );

          UPDATE hz_party_sites
          SET    attribute1         = p_staging_legal_rec.coc_number -- kvk
          ,      attribute2         = p_staging_legal_rec.legal_entity_type
          WHERE  party_site_id      = l_party_site_id
          ;

          create_party_site_use
          ( p_party_site_id         => l_party_site_id
          , p_party_site_use_id     => l_party_site_use_id
          );
        END IF;
      END IF;
    END IF;

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );

 END process_legal_rec;

  -- --------------------------------------------------------------------
  -- PROCEDURE process_store_rec
  -- Create all entities belonging to a store record.
  -- --------------------------------------------------------------------
  PROCEDURE process_store_rec
  ( p_staging_store_rec       IN  t_staging_store_rec
  , p_store_party_number      OUT hz_parties.party_number%TYPE
  , p_store_party_id          OUT hz_parties.party_id%TYPE
  )
  IS

    CURSOR c_entres(b_store_number IN XXAH_CONTRACT_CONV_DATA.Store_Number%TYPE)
    IS
    SELECT DISTINCT entre_party_id
    FROM (
    SELECT entre1_party_id entre_party_id
    FROM   XXAH_CONTRACT_CONV_DATA xcd
    WHERE  xcd.store_number = b_store_number
    AND    entre1_party_id IS NOT NULL
    UNION
    SELECT entre2_party_id entre_party_id
    FROM   XXAH_CONTRACT_CONV_DATA xcd
    WHERE  xcd.store_number = b_store_number
    AND    entre2_party_id IS NOT NULL
    UNION
    SELECT entre3_party_id entre_party_id
    FROM   XXAH_CONTRACT_CONV_DATA xcd
    WHERE  xcd.store_number = b_store_number
    AND    entre3_party_id IS NOT NULL
    UNION
    SELECT entre4_party_id entre_party_id
    FROM   XXAH_CONTRACT_CONV_DATA xcd
    WHERE  xcd.store_number = b_store_number
    AND    entre4_party_id IS NOT NULL
    UNION
    SELECT entre5_party_id entre_party_id
    FROM   XXAH_CONTRACT_CONV_DATA xcd
    WHERE  xcd.store_number = b_store_number
    AND    entre5_party_id IS NOT NULL)
    ;

    -- Local constants
    lc_subprogram_name        CONSTANT VARCHAR2(30) := 'process_store_rec';
    -- Local variables
    l_store_party_id          hz_parties.party_id%TYPE;
    l_store_party_number      hz_parties.party_number%TYPE;
    l_oc_party_id             hz_parties.party_id%TYPE; --Org contact party_id
    l_location_id             hz_locations.location_id%TYPE;
    l_party_site_id           hz_party_sites.party_site_id%TYPE;
    l_party_site_use_id       hz_party_site_uses.party_site_use_id%TYPE;

    -- check exists variables
    l_phone_contact_point_id  hz_contact_points.contact_point_id%TYPE;
    l_mobile_contact_point_id hz_contact_points.contact_point_id%TYPE;
    l_fax_contact_point_id    hz_contact_points.contact_point_id%TYPE;
  BEGIN

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    -- check if party already exists
    OPEN  c_party_exists
    ( b_party_name => p_staging_store_rec.store_number || ' ' || p_staging_store_rec.formule
    , b_party_type => gc_party_type_organization);
    FETCH c_party_exists INTO l_store_party_id, l_store_party_number;
    CLOSE c_party_exists;

    IF l_store_party_id IS NULL
    THEN
      create_party_org
      ( p_org_name              => p_staging_store_rec.store_number || ' ' || p_staging_store_rec.formule
      , p_party_number          => l_store_party_number
      , p_party_id              => l_store_party_id
      );

      -- ADD flexfields
      UPDATE hz_parties
      SET    attribute_category = 'Store'
      ,      attribute1         = DECODE(p_staging_store_rec.g31,'Y','Yes','N','No')
      ,      attribute2         = p_staging_store_rec.formule
      ,      attribute3         = p_staging_store_rec.format
      ,      attribute5         = p_staging_store_rec.wvo
      ,      attribute6         = p_staging_store_rec.vvo
      ,      attribute7         = to_char(p_staging_store_rec.first_contract_date, 'YYYY/MM/DD HH24:MI:SS')
      ,      attribute8         = to_char(p_staging_store_rec.last_renovation_date, 'YYYY/MM/DD HH24:MI:SS')
      ,      attribute9         = p_staging_store_rec.last_renovation_type
      ,      attribute10        = DECODE(p_staging_store_rec.store_status,'O','Open','D','Closed')
      ,      attribute11        = to_char(p_staging_store_rec.signature_date, 'YYYY/MM/DD HH24:MI:SS')
      ,      attribute13        = p_staging_store_rec.real_estate_property_owner
      ,      attribute14        = DECODE(p_staging_store_rec.avg_main_lessee,'Y','Yes','N','No')
      ,      attribute15        = to_char(p_staging_store_rec.store_closing_date, 'YYYY/MM/DD HH24:MI:SS')
      ,      attribute16        = p_staging_store_rec.region_number
      WHERE  party_id           = l_store_party_id
      ;

      -- process all related entrepeneurs for this legal entity
      FOR r_entres IN c_entres(p_staging_store_rec.store_number)
      LOOP
        IF r_entres.entre_party_id IS NOT NULL
        THEN
          create_org_contact
          ( p_party_id             => l_store_party_id
          , p_cp_party_id          => r_entres.entre_party_id
          , p_subject_type         => gc_party_type_person
          , p_oc_party_id          => l_oc_party_id
          );
        END IF;
      END LOOP;

      /*
      -- fetch all entrepeneurs belonging to this store
      IF p_staging_store_rec.legal_party_id IS NOT NULL
      THEN
        create_org_contact
        ( p_party_id             => l_store_party_id
        , p_cp_party_id          => p_staging_store_rec.legal_party_id
        , p_subject_type         => gc_party_type_organization
        , p_oc_party_id          => l_oc_party_id
        );
      END IF;
      */
    END IF;

    p_store_party_id     := l_store_party_id;
    p_store_party_number := l_store_party_number;


    IF p_staging_store_rec.store_phone_num IS NOT NULL
    THEN
      -- check if phone already exists
      OPEN  c_party_phone_exists(l_store_party_id, p_staging_store_rec.store_phone_num);
      FETCH c_party_phone_exists INTO l_phone_contact_point_id;
      CLOSE c_party_phone_exists;

      IF l_phone_contact_point_id IS NULL
      THEN
        create_phone_contact_point
        ( p_party_id              => l_store_party_id
        , p_phone_line_type       => gc_phone_line_type_general
        , p_phone_number          => p_staging_store_rec.store_phone_num
        );
      END IF;
    END IF;

    IF p_staging_store_rec.store_mobile_num IS NOT NULL
    THEN
      -- check if phone already exists
      OPEN  c_party_phone_exists(l_store_party_id, p_staging_store_rec.store_mobile_num);
      FETCH c_party_phone_exists INTO l_mobile_contact_point_id;
      CLOSE c_party_phone_exists;

      IF l_mobile_contact_point_id IS NULL
      THEN
        create_phone_contact_point
        ( p_party_id              => l_store_party_id
        , p_phone_line_type       => gc_phone_line_type_mobile
        , p_phone_number          => p_staging_store_rec.store_mobile_num
        );
      END IF;
    END IF;

    IF p_staging_store_rec.store_fax_num IS NOT NULL
    THEN
      -- check if phone already exists
      OPEN  c_party_phone_exists(l_store_party_id, p_staging_store_rec.store_fax_num);
      FETCH c_party_phone_exists INTO l_fax_contact_point_id;
      CLOSE c_party_phone_exists;

      IF l_fax_contact_point_id IS NULL
      THEN
        create_phone_contact_point
        ( p_party_id              => l_store_party_id
        , p_phone_line_type       => gc_phone_line_type_fax
        , p_phone_number          => p_staging_store_rec.store_fax_num
        );
      END IF;
    END IF;

    IF p_staging_store_rec.store_street IS NOT NULL
    THEN
      -- check if address with this party already exists, postal code is the key for this
      OPEN  c_party_address_exists(l_store_party_id, p_staging_store_rec.store_pc);
      FETCH c_party_address_exists INTO l_location_id;
      CLOSE c_party_address_exists;

      IF l_location_id IS NULL
      THEN

        create_location
        ( p_address_street        => p_staging_store_rec.store_street
        , p_address_house_num     => p_staging_store_rec.store_house_num
        , p_address_house_num_add => p_staging_store_rec.store_house_num_add
        , p_address_city          => p_staging_store_rec.store_city
        , p_address_pc            => p_staging_store_rec.store_pc
        , p_location_id           => l_location_id
        );

        create_party_site
        ( p_party_id              => l_store_party_id
        , p_location_id           => l_location_id
        , p_party_site_id         => l_party_site_id
        );

        create_party_site_use
        ( p_party_site_id         => l_party_site_id
        , p_party_site_use_id     => l_party_site_use_id
        );
      END IF;
    END IF;

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );

 END process_store_rec;

  -- --------------------------------------------------------------------
  -- PROCEDURE create_legal_entities
  -- Loop through all legal entitties and process it.
  -- --------------------------------------------------------------------
  PROCEDURE create_legal_entities
  ( p_retcode IN OUT NUMBER
  , p_formule IN xxah_contract_conv_data.formule%TYPE)
  IS
    -- Local constants
    lc_subprogram_name         CONSTANT VARCHAR2(30) := 'create_legal_entities';
    -- Local types
    TYPE t_staging_legals_tbl IS TABLE OF t_staging_legal_rec;
    -- Local variables
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_msg_index_out            NUMBER;
    l_formatted_msg            VARCHAR2(2000);
    l_error_message            VARCHAR2(2000);
    l_staging_legals_tbl       t_staging_legals_tbl;
    l_staging_legal_idx        NUMBER;
    l_staging_legal_rec        t_staging_legal_rec;
    l_legal_party_id           hz_parties.party_id%TYPE;
    l_legal_party_number       hz_parties.party_number%TYPE;
    l_legal_creation_counter   NUMBER;
  BEGIN
    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    UPDATE xxah_contract_conv_data xcd
    SET    xcd.legal_process_status = gc_staging_process
    ,      last_update_date     = SYSDATE
    ,      last_updated_by      = FND_GLOBAL.user_id
    WHERE  xcd.legal_process_status = gc_staging_new
    AND    trim(xcd.legal_entity_name) IS NOT NULL;

    UPDATE xxah_contract_conv_data xcd
    SET    xcd.legal_process_status = gc_staging_done
    ,      last_update_date     = SYSDATE
    ,      last_updated_by      = FND_GLOBAL.user_id
    WHERE  xcd.legal_process_status = gc_staging_new
    AND    trim(xcd.legal_entity_name) IS NULL;

    fnd_log.string
    ( fnd_log.level_event
    , gc_log_prefix || lc_subprogram_name
    , SQL%rowcount  || ' stores marked for processing.'
    );

    OPEN  c_staging_legals
    ( b_process_status => '1'
    , b_formule => p_formule);
    FETCH c_staging_legals BULK COLLECT INTO l_staging_legals_tbl;
    CLOSE c_staging_legals;

    l_staging_legal_idx := l_staging_legals_tbl.FIRST;

    l_legal_creation_counter := 0;

    <<staging_legals>>
    WHILE l_staging_legals_tbl.EXISTS(l_staging_legal_idx)
    LOOP
      l_staging_legal_rec := l_staging_legals_tbl(l_staging_legal_idx);

      fnd_msg_pub.initialize;

      SAVEPOINT start_processing_legal;

      BEGIN
        process_legal_rec
        ( p_staging_legal_rec  => l_staging_legal_rec
        , p_legal_party_number => l_legal_party_number
        , p_legal_party_id     => l_legal_party_id
        );

        l_legal_creation_counter := l_legal_creation_counter + 1;

        out(rpad('Legal Entity', 15) || ' ');
        out(rpad(l_staging_legal_rec.legal_entity_name, 50) || ' ');
        out(rpad(l_legal_party_number, 10) || ' ');
        outline(rpad(l_legal_party_id, 10) || ' ');

        UPDATE xxah_contract_conv_data xcd
        SET    xcd.legal_process_status = gc_staging_done
        ,      xcd.legal_party_id       = l_legal_party_id
        ,      last_update_date         = SYSDATE
        ,      last_updated_by          = FND_GLOBAL.user_id
        WHERE  trim(xcd.legal_entity_name) = l_staging_legal_rec.legal_entity_name
        ;
        -- rowid = l_staging_store_rec.row_id;

      EXCEPTION
        WHEN e_conv_exception
        THEN
          p_retcode := 1; -- Warning
          l_error_message := '';
          l_msg_count := fnd_msg_pub.Count_Msg;

          IF l_msg_count > 0
          THEN
            FOR l_msg_index IN 1 .. l_msg_count
            LOOP
              fnd_msg_pub.Get
              ( p_msg_index     => l_msg_index
              , p_encoded       => 'F'
              , p_data          => l_msg_data
              , p_msg_index_out => l_msg_index_out
              );

              fnd_log.string
              ( fnd_log.level_exception
              , gc_log_prefix || lc_subprogram_name
              , l_msg_data
              );

              l_formatted_msg := '[' || l_msg_index || '] ' || l_msg_data || ' ';

              write_log(l_formatted_msg);

              l_error_message := substr(l_error_message || l_formatted_msg || ' ', 0, 2000);

            END LOOP;
          ELSE
            NULL;
          END IF;

        ROLLBACK TO start_processing_legal;

        UPDATE xxah_contract_conv_data
        SET    legal_process_status = gc_staging_error
        ,      error_message        = TRIM(l_error_message)
        ,      last_update_date     = SYSDATE
        ,      last_updated_by      = FND_GLOBAL.user_id
        WHERE  legal_entity_name = l_staging_legal_rec.legal_entity_name;
      END;

      l_staging_legal_idx := l_staging_legals_tbl.NEXT(l_staging_legal_idx);
    END LOOP staging_legals;

    outline('');
    outline(l_legal_creation_counter || ' legal entities created.');
    outline('');

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );
  END create_legal_entities;


  -- --------------------------------------------------------------------
  -- PROCEDURE create_entrepeneurs
  -- Loop through all entrepeneurs and process them.
  -- --------------------------------------------------------------------
  PROCEDURE create_entrepeneurs
  ( p_retcode IN OUT NUMBER
  , p_formule IN xxah_contract_conv_data.formule%TYPE)
  IS
    -- Local constants
    lc_subprogram_name CONSTANT VARCHAR2(30) := 'create_entrepeneurs';
    -- Local types
    TYPE t_staging_entres_tbl IS TABLE OF t_staging_entre_rec;
    -- Local variables
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_msg_index_out         NUMBER;
    l_formatted_msg         VARCHAR2(2000);
    l_error_message         VARCHAR2(2000);
    l_staging_entres_tbl     t_staging_entres_tbl;
    l_staging_entre_idx     NUMBER;
    l_staging_entre_rec     t_staging_entre_rec;
    l_entre_party_id        hz_parties.party_id%TYPE;
    l_entre_party_number    hz_parties.party_number%TYPE;
    l_full_name             hz_parties.party_name%TYPE;
    l_entrep_creation_counter NUMBER;
  BEGIN

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    UPDATE xxah_contract_conv_data xcd
    SET    xcd.entre1_process_status = gc_staging_process
    ,      xcd.last_update_date      = SYSDATE
    ,      xcd.last_updated_by       = FND_GLOBAL.user_id
    WHERE  xcd.entre1_process_status = gc_staging_new
    AND    xcd.entrepeneur1_last_name IS NOT NULL;

    UPDATE xxah_contract_conv_data xcd
    SET    xcd.entre1_process_status = gc_staging_done
    ,      xcd.last_update_date      = SYSDATE
    ,      xcd.last_updated_by       = FND_GLOBAL.user_id
    WHERE  xcd.entre1_process_status = gc_staging_new
    AND    xcd.entrepeneur1_last_name IS NULL;

    UPDATE xxah_contract_conv_data xcd
    SET    xcd.entre2_process_status = gc_staging_process
    ,      xcd.last_update_date     = SYSDATE
    ,      xcd.last_updated_by      = FND_GLOBAL.user_id
    WHERE  xcd.entre2_process_status = gc_staging_new
    AND    xcd.entrepeneur2_last_name IS NOT NULL;

    UPDATE xxah_contract_conv_data xcd
    SET    xcd.entre2_process_status = gc_staging_done
    ,      xcd.last_update_date      = SYSDATE
    ,      xcd.last_updated_by       = FND_GLOBAL.user_id
    WHERE  xcd.entre2_process_status = gc_staging_new
    AND    xcd.entrepeneur2_last_name IS NULL;

    UPDATE xxah_contract_conv_data xcd
    SET    xcd.entre3_process_status = gc_staging_process
    ,      xcd.last_update_date     = SYSDATE
    ,      xcd.last_updated_by      = FND_GLOBAL.user_id
    WHERE  xcd.entre3_process_status = gc_staging_new
    AND    xcd.entrepeneur3_last_name IS NOT NULL;

    UPDATE xxah_contract_conv_data xcd
    SET    xcd.entre3_process_status = gc_staging_done
    ,      xcd.last_update_date      = SYSDATE
    ,      xcd.last_updated_by       = FND_GLOBAL.user_id
    WHERE  xcd.entre3_process_status = gc_staging_new
    AND    xcd.entrepeneur3_last_name IS NULL;

    UPDATE xxah_contract_conv_data xcd
    SET    xcd.entre4_process_status = gc_staging_process
    ,      xcd.last_update_date     = SYSDATE
    ,      xcd.last_updated_by      = FND_GLOBAL.user_id
    WHERE  xcd.entre4_process_status = gc_staging_new
    AND    xcd.entrepeneur4_last_name IS NOT NULL;

    UPDATE xxah_contract_conv_data xcd
    SET    xcd.entre4_process_status = gc_staging_done
    ,      xcd.last_update_date      = SYSDATE
    ,      xcd.last_updated_by       = FND_GLOBAL.user_id
    WHERE  xcd.entre4_process_status = gc_staging_new
    AND    xcd.entrepeneur4_last_name IS NULL;

    UPDATE xxah_contract_conv_data xcd
    SET    xcd.entre5_process_status = gc_staging_process
    ,      xcd.last_update_date     = SYSDATE
    ,      xcd.last_updated_by      = FND_GLOBAL.user_id
    WHERE  xcd.entre5_process_status = gc_staging_new
    AND    xcd.entrepeneur5_last_name IS NOT NULL;

    UPDATE xxah_contract_conv_data xcd
    SET    xcd.entre5_process_status = gc_staging_done
    ,      xcd.last_update_date      = SYSDATE
    ,      xcd.last_updated_by       = FND_GLOBAL.user_id
    WHERE  xcd.entre5_process_status = gc_staging_new
    AND    xcd.entrepeneur5_last_name IS NULL;

    fnd_log.string
    ( fnd_log.level_event
    , gc_log_prefix || lc_subprogram_name
    , SQL%rowcount  || ' stores marked for processing.'
    );

    OPEN  c_staging_entres
    ( b_process_status => '1'
    , b_formule => p_formule);
    FETCH c_staging_entres BULK COLLECT INTO l_staging_entres_tbl;
    CLOSE c_staging_entres;

    l_staging_entre_idx := l_staging_entres_tbl.FIRST;

    l_entrep_creation_counter := 0;

    <<staging_entres>>
    WHILE l_staging_entres_tbl.EXISTS(l_staging_entre_idx)
    LOOP
      l_staging_entre_rec := l_staging_entres_tbl(l_staging_entre_idx);

      fnd_msg_pub.initialize;

      SAVEPOINT start_processing_entre;

      BEGIN

        process_entre_rec
        ( p_staging_entre_rec  => l_staging_entre_rec
        , p_entre_party_number => l_entre_party_number
        , p_entre_party_id     => l_entre_party_id
        );

        l_entrep_creation_counter := l_entrep_creation_counter + 1;

        -- combine the full_name
        IF l_staging_entre_rec.entrep_middle IS NOT NULL
        THEN
            l_full_name := l_staging_entre_rec.entrep_initials || ' ' || l_staging_entre_rec.entrep_middle || ' ' || l_staging_entre_rec.entrep_last;
        ELSE
            l_full_name := l_staging_entre_rec.entrep_initials || ' ' || l_staging_entre_rec.entrep_last;
        END IF;

        out(rpad('Entrepeneur', 15) || ' ');
        out(rpad(l_full_name, 50) || ' ');
        out(rpad(l_entre_party_number, 10) || ' ');
        outline(rpad(l_entre_party_id, 10) || ' ');

        UPDATE xxah_contract_conv_data xcd
        SET    xcd.entre1_process_status          = gc_staging_done
        ,      xcd.entre1_party_id                = l_entre_party_id
        ,      xcd.last_update_date               = SYSDATE
        ,      xcd.last_updated_by                = FND_GLOBAL.user_id
        WHERE (NVL(trim(xcd.entrepeneur1_initials),'NULL')    = NVL(l_staging_entre_rec.entrep_initials,'NULL')
        AND    NVL(trim(xcd.entrepeneur1_middle_name),'NULL') = NVL(l_staging_entre_rec.entrep_middle,'NULL')
        AND    trim(xcd.entrepeneur1_last_name)   = l_staging_entre_rec.entrep_last)
        ;

        UPDATE xxah_contract_conv_data xcd
        SET    xcd.entre2_process_status           = gc_staging_done
        ,      xcd.entre2_party_id                = l_entre_party_id
        ,      xcd.last_update_date               = SYSDATE
        ,      xcd.last_updated_by                = FND_GLOBAL.user_id
        WHERE (NVL(trim(xcd.entrepeneur2_initials),'NULL')    = NVL(l_staging_entre_rec.entrep_initials,'NULL')
        AND    NVL(trim(xcd.entrepeneur2_middle_name),'NULL') = NVL(l_staging_entre_rec.entrep_middle,'NULL')
        AND    trim(xcd.entrepeneur2_last_name)   = l_staging_entre_rec.entrep_last)
        ;

        UPDATE xxah_contract_conv_data xcd
        SET    xcd.entre3_process_status           = gc_staging_done
        ,      xcd.entre3_party_id                = l_entre_party_id
        ,      xcd.last_update_date               = SYSDATE
        ,      xcd.last_updated_by                = FND_GLOBAL.user_id
        WHERE (NVL(trim(xcd.entrepeneur3_initials),'NULL')    = NVL(l_staging_entre_rec.entrep_initials,'NULL')
        AND    NVL(trim(xcd.entrepeneur3_middle_name),'NULL') = NVL(l_staging_entre_rec.entrep_middle,'NULL')
        AND    trim(xcd.entrepeneur3_last_name)   = l_staging_entre_rec.entrep_last)
        ;

        UPDATE xxah_contract_conv_data xcd
        SET    xcd.entre4_process_status           = gc_staging_done
        ,      xcd.entre4_party_id                = l_entre_party_id
        ,      xcd.last_update_date               = SYSDATE
        ,      xcd.last_updated_by                = FND_GLOBAL.user_id
        WHERE (NVL(trim(xcd.entrepeneur4_initials),'NULL')    = NVL(l_staging_entre_rec.entrep_initials,'NULL')
        AND    NVL(trim(xcd.entrepeneur4_middle_name),'NULL') = NVL(l_staging_entre_rec.entrep_middle,'NULL')
        AND    trim(xcd.entrepeneur4_last_name)   = l_staging_entre_rec.entrep_last)
        ;

        UPDATE xxah_contract_conv_data xcd
        SET    xcd.entre5_process_status           = gc_staging_done
        ,      xcd.entre5_party_id                = l_entre_party_id
        ,      xcd.last_update_date               = SYSDATE
        ,      xcd.last_updated_by                = FND_GLOBAL.user_id
        WHERE (NVL(trim(xcd.entrepeneur5_initials),'NULL')    = NVL(l_staging_entre_rec.entrep_initials,'NULL')
        AND    NVL(trim(xcd.entrepeneur5_middle_name),'NULL') = NVL(l_staging_entre_rec.entrep_middle,'NULL')
        AND    trim(xcd.entrepeneur5_last_name)   = l_staging_entre_rec.entrep_last)
        ;

      EXCEPTION
        WHEN e_conv_exception
        THEN
          p_retcode := 1; -- Warning
          l_error_message := '';
          l_msg_count := fnd_msg_pub.Count_Msg;

          IF l_msg_count > 0
          THEN
            FOR l_msg_index IN 1 .. l_msg_count
            LOOP
              fnd_msg_pub.Get
              ( p_msg_index     => l_msg_index
              , p_encoded       => 'F'
              , p_data          => l_msg_data
              , p_msg_index_out => l_msg_index_out
              );

              fnd_log.string
              ( fnd_log.level_exception
              , gc_log_prefix || lc_subprogram_name
              , l_msg_data
              );

              l_formatted_msg := '[' || l_msg_index || '] ' || l_msg_data || ' ';

              write_log(l_formatted_msg);

              l_error_message := substr(l_error_message || l_formatted_msg || ' ', 0, 2000);

            END LOOP;
          ELSE
            NULL;
          END IF;

        ROLLBACK TO start_processing_entre;

        UPDATE xxah_contract_conv_data xcd
        SET    entre1_process_status       = gc_staging_error
        ,      error_message              = TRIM(l_error_message)
        ,      last_update_date           = SYSDATE
        ,      last_updated_by            = FND_GLOBAL.user_id
        WHERE (NVL(xcd.entrepeneur1_initials,'NULL')  = NVL(l_staging_entre_rec.entrep_initials,'NULL')
        AND    NVL(xcd.entrepeneur1_middle_name,'NULL') = NVL(l_staging_entre_rec.entrep_middle,'NULL')
        AND    NVL(xcd.entrepeneur1_last_name,'NULL') = NVL(l_staging_entre_rec.entrep_last,'NULL'))
        ;
        UPDATE xxah_contract_conv_data xcd
        SET    entre2_process_status       = gc_staging_error
        ,      error_message              = TRIM(l_error_message)
        ,      last_update_date           = SYSDATE
        ,      last_updated_by            = FND_GLOBAL.user_id
        WHERE (NVL(xcd.entrepeneur2_initials,'NULL')  = NVL(l_staging_entre_rec.entrep_initials,'NULL')
        AND    NVL(xcd.entrepeneur2_middle_name,'NULL') = NVL(l_staging_entre_rec.entrep_middle,'NULL')
        AND    NVL(xcd.entrepeneur2_last_name,'NULL') = NVL(l_staging_entre_rec.entrep_last,'NULL'))
        ;
        UPDATE xxah_contract_conv_data xcd
        SET    entre3_process_status       = gc_staging_error
        ,      error_message              = TRIM(l_error_message)
        ,      last_update_date           = SYSDATE
        ,      last_updated_by            = FND_GLOBAL.user_id
        WHERE (NVL(xcd.entrepeneur3_initials,'NULL')  = NVL(l_staging_entre_rec.entrep_initials,'NULL')
        AND    NVL(xcd.entrepeneur3_middle_name,'NULL') = NVL(l_staging_entre_rec.entrep_middle,'NULL')
        AND    NVL(xcd.entrepeneur3_last_name,'NULL') = NVL(l_staging_entre_rec.entrep_last,'NULL'))
        ;
        UPDATE xxah_contract_conv_data xcd
        SET    entre4_process_status       = gc_staging_error
        ,      error_message              = TRIM(l_error_message)
        ,      last_update_date           = SYSDATE
        ,      last_updated_by            = FND_GLOBAL.user_id
        WHERE (NVL(xcd.entrepeneur4_initials,'NULL')  = NVL(l_staging_entre_rec.entrep_initials,'NULL')
        AND    NVL(xcd.entrepeneur4_middle_name,'NULL') = NVL(l_staging_entre_rec.entrep_middle,'NULL')
        AND    NVL(xcd.entrepeneur4_last_name,'NULL') = NVL(l_staging_entre_rec.entrep_last,'NULL'))
        ;
        UPDATE xxah_contract_conv_data xcd
        SET    entre5_process_status       = gc_staging_error
        ,      error_message              = TRIM(l_error_message)
        ,      last_update_date           = SYSDATE
        ,      last_updated_by            = FND_GLOBAL.user_id
        WHERE (NVL(xcd.entrepeneur5_initials,'NULL')  = NVL(l_staging_entre_rec.entrep_initials,'NULL')
        AND    NVL(xcd.entrepeneur5_middle_name,'NULL') = NVL(l_staging_entre_rec.entrep_middle,'NULL')
        AND    NVL(xcd.entrepeneur5_last_name,'NULL') = NVL(l_staging_entre_rec.entrep_last,'NULL'))
        ;
      END;

      l_staging_entre_idx := l_staging_entres_tbl.NEXT(l_staging_entre_idx);
    END LOOP staging_entres;

    outline('');
    outline(l_entrep_creation_counter || ' entrepeneurs created.');
    outline('');

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );
  END create_entrepeneurs;

   -- --------------------------------------------------------------------
  -- PROCEDURE create_entrepeneurs
  -- Loop through all stores and process them.
  -- --------------------------------------------------------------------
  PROCEDURE create_stores
  ( p_retcode IN OUT NUMBER
  , p_formule IN xxah_contract_conv_data.formule%TYPE
  )
  IS
    -- Local constants
    lc_subprogram_name CONSTANT VARCHAR2(30) := 'create_stores';
    -- Local types
    TYPE t_staging_stores_tbl IS TABLE OF t_staging_store_rec;
    -- Local variables
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_msg_index_out         NUMBER;
    l_formatted_msg         VARCHAR2(2000);
    l_error_message         VARCHAR2(2000);
    l_store_party_id        hz_parties.party_id%TYPE;
    l_store_party_number    hz_parties.party_number%TYPE;
    l_staging_stores_tbl    t_staging_stores_tbl;
    l_staging_store_idx     NUMBER;
    l_staging_store_rec     t_staging_store_rec;

    l_store_creation_counter NUMBER;

  BEGIN
    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'Start procedure.'
    );

    UPDATE xxah_contract_conv_data xcd
    SET    xcd.store_process_status = gc_staging_process
    ,      last_update_date     = SYSDATE
    ,      last_updated_by      = FND_GLOBAL.user_id
    WHERE  xcd.store_process_status = gc_staging_new;

    fnd_log.string
    ( fnd_log.level_event
    , gc_log_prefix || lc_subprogram_name
    , SQL%rowcount  || ' buying department marked for processing.'
    );

    OPEN  c_staging_stores
    ( b_process_status => '1'
    , b_formule => p_formule);
    FETCH c_staging_stores BULK COLLECT INTO l_staging_stores_tbl;
    CLOSE c_staging_stores;

    l_staging_store_idx := l_staging_stores_tbl.FIRST;

    l_store_creation_counter := 0;

    <<staging_stores>>
    WHILE l_staging_stores_tbl.EXISTS(l_staging_store_idx)
    LOOP
      l_staging_store_rec := l_staging_stores_tbl(l_staging_store_idx);

      fnd_msg_pub.initialize;

      SAVEPOINT start_processing_store;

      BEGIN
        process_store_rec
        ( p_staging_store_rec  => l_staging_store_rec
        , p_store_party_number => l_store_party_number
        , p_store_party_id     => l_store_party_id
        );

        l_store_creation_counter := l_store_creation_counter + 1;

        out(rpad('Store', 15) || ' ');
        out(rpad(l_staging_store_rec.store_number || ' ' || l_staging_store_rec.formule, 50) || ' ');
        out(rpad(l_store_party_number, 10) || ' ');
        outline(rpad(l_store_party_id, 10) || ' ');

        UPDATE xxah_contract_conv_data xcd
        SET    xcd.store_process_status = gc_staging_done
        ,      xcd.store_party_id       = l_store_party_id
        ,      last_update_date         = SYSDATE
        ,      last_updated_by          = FND_GLOBAL.user_id
        WHERE  rowid                    = l_staging_store_rec.row_id;

      EXCEPTION
        WHEN e_conv_exception
        THEN
          p_retcode := 1; -- Warning
          l_error_message := '';
          l_msg_count := fnd_msg_pub.Count_Msg;

          IF l_msg_count > 0
          THEN
            FOR l_msg_index IN 1 .. l_msg_count
            LOOP
              fnd_msg_pub.Get
              ( p_msg_index     => l_msg_index
              , p_encoded       => 'F'
              , p_data          => l_msg_data
              , p_msg_index_out => l_msg_index_out
              );

              fnd_log.string
              ( fnd_log.level_exception
              , gc_log_prefix || lc_subprogram_name
              , l_msg_data
              );

              l_formatted_msg := '[' || l_msg_index || '] ' || l_msg_data || ' ';

              write_log(l_formatted_msg);

              l_error_message := substr(l_error_message || l_formatted_msg || ' ', 0, 2000);

            END LOOP;
          ELSE
            NULL;
          END IF;

        ROLLBACK TO start_processing_store;

        UPDATE xxah_contract_conv_data
        SET    store_process_status = gc_staging_error
        ,      error_message        = TRIM(l_error_message)
        ,      last_update_date     = SYSDATE
        ,      last_updated_by      = FND_GLOBAL.user_id
        WHERE  rowid                = l_staging_store_rec.row_id;

      END;

      l_staging_store_idx := l_staging_stores_tbl.NEXT(l_staging_store_idx);
    END LOOP staging_stores;

    outline('');
    outline(l_store_creation_counter || ' stores created.');
    outline('');

    fnd_log.string
    ( fnd_log.level_procedure
    , gc_log_prefix || lc_subprogram_name
    , 'End procedure.'
    );
  END create_stores;

 /*************************************************************************
  * PROCEDURE   :  create_crm
  * DESCRIPTION :  create CRM related entities
  * PARAMETERS   :  -
  *************************************************************************/
  PROCEDURE create_crm
  ( errbuf  OUT VARCHAR2
  , retcode OUT NUMBER
  , p_formule IN VARCHAR2
  )
  IS
  BEGIN
    UPDATE xxah_contract_conv_data
    SET    store_process_status = 0
    ,      error_message = ''
    WHERE  formule = p_formule
    AND    store_process_status != 400
    ;

    UPDATE xxah_contract_conv_data
    SET    legal_process_status = 0
    ,      error_message = ''
    WHERE  formule = p_formule
    AND    legal_process_status != 400
    ;

    UPDATE xxah_contract_conv_data
    SET    entre1_process_status = 0
    ,      error_message = ''
    WHERE  formule = p_formule
    AND    entre1_process_status != 400
    ;

    UPDATE xxah_contract_conv_data
    SET    entre2_process_status = 0
    ,      error_message = ''
    WHERE  formule = p_formule
    AND    entre2_process_status != 400
    ;

    UPDATE xxah_contract_conv_data
    SET    entre3_process_status = 0
    ,      error_message = ''
    WHERE  formule = p_formule
    AND    entre3_process_status != 400
    ;

    UPDATE xxah_contract_conv_data
    SET    entre4_process_status = 0
    ,      error_message = ''
    WHERE  formule = p_formule
    AND    entre4_process_status != 400
    ;

    UPDATE xxah_contract_conv_data
    SET    entre5_process_status = 0
    ,      error_message = ''
    WHERE  formule = p_formule
    AND    entre5_process_status != 400
    ;

    outline('The following parties were created');
    outline('');

    out(rpad('Party Type', 15) || ' ');
    out(rpad('Party Naam', 50) || ' ');
    out(rpad('Party No.', 10) || ' ');
    outline(rpad('Party Id', 10) || ' ');

    out(rpad('-', 15, '-') || ' ');
    out(rpad('-', 50, '-') || ' ');
    out(rpad('-', 10, '-') || ' ');
    outline(rpad('-', 10, '-') || ' ');

    -- JV 31/1/2011: do not create entrepeneurs
    --write_log('[*] Create Entrepeneurs');
    --create_entrepeneurs(p_retcode => retcode, p_formule => p_formule);

    write_log('[*] Create Legal Entities');
    create_legal_entities(p_retcode => retcode, p_formule => p_formule);

    --ROLLBACK;

  END create_crm;

 PROCEDURE print_csv_data
 ( p_contract_name     VARCHAR2
 , p_contract_admin    VARCHAR2 DEFAULT NULL
 , p_contract_type     VARCHAR2
 , p_eff_date          VARCHAR2
 , p_exp_date          VARCHAR2
 , p_keywords          VARCHAR2
 , p_legal_entity_name VARCHAR2
 , p_signature_date    VARCHAR2
 , p_store_name        VARCHAR2
 , p_filename_1        VARCHAR2
 , p_filename_2        VARCHAR2
 , p_filename_3        VARCHAR2
 , p_amount            VARCHAR2 DEFAULT NULL
 ) IS
 BEGIN
   out( ''                                     || gc_separator); -- contract number
   out( '"' || p_contract_name || '"'          || gc_separator); -- contract name
   out( 'Signed'                               || gc_separator); -- status
   out( p_contract_type                        || gc_separator); -- contract type
   out( p_eff_date                             || gc_separator); -- effective date
   out( p_exp_date                             || gc_separator); -- expiration date
   out( 'Ahold European Sourcing BV'           || gc_separator); -- operating unit

   out( replace(REGEXP_SUBSTR(p_contract_admin,'.*\|\|\|'),'|||', '')                      || gc_separator); -- contract admin
   out( 'EUR'                                  || gc_separator); -- currency
   out( p_amount                               || gc_separator); -- amount
   out( ''                                     || gc_separator); -- AuthoringParty
   out( ''                                     || gc_separator); -- PhysicalLocation
   out( p_keywords                             || gc_separator); -- Keywords
   out( ''                                     || gc_separator); -- Description
   out( 'CRD conversion on ' || to_char(SYSDATE, 'DD-MM-YYYY HH24:MI:SS')  || gc_separator); -- version comments
   out( 'Ahold European Sourcing BV'           || gc_separator); -- party 1 name
   out( 'Internal'                             || gc_separator); -- party 1 role
   out( 'Ahold European Sourcing BV'           || gc_separator); -- party 1 signed by
   out( p_signature_date                       || gc_separator); -- party 1 signed date
   out( 'Ahold European Sourcing'              || gc_separator); -- party 2 name    -- rvelden: Ahold European Sourcing is party name for external. Overleg met Edwin
   out( 'Partner'                              || gc_separator); -- party 2 role
   out( 'Ahold European Sourcing'           || gc_separator); -- party 2 signed by
   out( p_signature_date                       || gc_separator); -- party 2 signed date
   out( p_legal_entity_name                    || gc_separator); -- party 3 name
   out( 'Partner'                              || gc_separator); -- party 3 role
   out( p_legal_entity_name                    || gc_separator); -- party 3 signed by
   out( p_signature_date                       || gc_separator); -- party 3 signed date
   out( 'File'                                 || gc_separator); -- ContractDoc1Type
   out( p_filename_1                           || gc_separator); -- ContractDoc1Name
   out('Contract'                              || gc_separator); -- ContractDoc1Category
   out(''                                      || gc_separator); -- ContractDoc1Description
   IF (p_filename_2 IS NOT NULL ) AND (p_filename_2 <> '0' )
   THEN
     out( 'File'                                 || gc_separator); -- ContractDoc2Type
     out( p_filename_2                           || gc_separator); -- ContractDoc2Name
     out('Contract'                              || gc_separator); -- ContractDoc2Category
     out(''                                      || gc_separator); -- ContractDoc2Description
   ELSE
     out( ''                                     || gc_separator); -- ContractDoc2Type
     out( ''                                     || gc_separator); -- ContractDoc2Name
     out( ''                                     || gc_separator); -- ContractDoc2Category
     out( ''                                     || gc_separator); -- ContractDoc2Description
   END IF;
   IF (p_filename_3 IS NOT NULL ) AND (p_filename_3 <> '0' )
   THEN
     out( 'File'                                 || gc_separator); -- ContractDoc3Type
     out( p_filename_3                           || gc_separator); -- ContractDoc3Name
     out('Contract'                              || gc_separator); -- ContractDoc3Category
     out(''                                      || gc_separator); -- ContractDoc3Description
   ELSE
     out( ''                                     || gc_separator); -- ContractDoc3Type
     out( ''                                     || gc_separator); -- ContractDoc3Name
     out( ''                                     || gc_separator); -- ContractDoc3Category
     out( ''                                     || gc_separator); -- ContractDoc3Description
   END IF;
   out( ''                                     || gc_separator); -- ContractDoc4Type
   out( ''                                     || gc_separator); -- ContractDoc4Name
   out( ''                                     || gc_separator); -- ContractDoc4Category
   out( ''                                     || gc_separator); -- ContractDoc4Description
   out( ''                                     || gc_separator); -- ContractDoc5Type
   out( ''                                     || gc_separator); -- ContractDoc5Name
   out( ''                                     || gc_separator); -- ContractDoc5Category
   out( ''                                     || gc_separator); -- ContractDoc5Description
   out( ''                                     || gc_separator); -- OrigSystemRefCode
   out( ''                                     || gc_separator); -- OrigSystemRefId1
   outline( ''                                 ); -- OrigSystemRefId2
 END print_csv_data;

 /* ************************************************************************
  * PROCEDURE   :  export_csv
  * DESCRIPTION :  export csv file for contract import
  * PARAMETERS   :  -
  *************************************************************************/
  PROCEDURE export_csv
  ( errbuf               OUT VARCHAR2
  , retcode              OUT NUMBER
  , p_formule            IN VARCHAR2
  --, p_store_number_start IN NUMBER
  , p_store_number_start IN VARCHAR2
  --, p_store_number_end   IN NUMBER
  , p_store_number_end   IN VARCHAR2
  ) IS

    CURSOR c_export_csv
    IS
    SELECT * FROM (
    SELECT --xcd.store_number || '_' || xcd.formule              contract_name
           sum(purchase_value) over (partition by xcd.project_number) cum_purchase_value
    ,      xcd.project_number || ' - ' || xcd.project_name     contract_name
    ,      xcd.contract_admin                                  contract_admin
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   frov_eff_date
    ,      to_char(xcd.frov_contract_exp_date, 'MM/DD/YYYY')   frov_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   kvk_eff_date
    ,      to_char(xcd.kvk_contract_exp_date, 'MM/DD/YYYY')    kvk_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   excl_eff_date
    ,      to_char(xcd.excl_contract_exp_date, 'MM/DD/YYYY')   excl_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   geld_eff_date
    ,      to_char(xcd.geld_contract_exp_date, 'MM/DD/YYYY')   geld_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   pand_eff_date
    ,      to_char(xcd.pand_contract_exp_date, 'MM/DD/YYYY')   pand_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   terk_eff_date
    ,      to_char(xcd.terk_contract_exp_date, 'MM/DD/YYYY')   terk_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   verk_eff_date
    ,      to_char(xcd.verk_contract_exp_date, 'MM/DD/YYYY')   verk_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   spaar_eff_date
    ,      to_char(xcd.spaar_contract_exp_date, 'MM/DD/YYYY')  spaar_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   zama_eff_date
    ,      to_char(xcd.zama_contract_exp_date, 'MM/DD/YYYY')   zama_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   onder_eff_date
    ,      to_char(xcd.onder_contract_exp_date, 'MM/DD/YYYY')  onder_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   ovc_eff_date
    ,      to_char(xcd.ovc_contract_exp_date, 'MM/DD/YYYY')    ovc_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   tnt_eff_date
    ,      to_char(xcd.tnt_contract_exp_date, 'MM/DD/YYYY')    tnt_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   add_eff_date
    ,      to_char(xcd.add_contract_exp_date, 'MM/DD/YYYY')    add_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   bank_eff_date
    ,      to_char(xcd.bank_contract_exp_date, 'MM/DD/YYYY')   bank_exp_date
    ,      to_char(xcd.frov_contract_eff_date, 'MM/DD/YYYY')   leen_eff_date
    ,      to_char(xcd.leen_contract_exp_date, 'MM/DD/YYYY')   leen_exp_date
    -- JV 31/1/2011
    ,      '"' || keywords || '"'                              keywords
    ,      'CRD conversion on '
           || to_char(SYSDATE, 'DD-MM-YYYY HH24:MI:SS')        version_comments
    ,      xcd.legal_entity_name                               legal_entity_name
    ,      to_char(xcd.signature_date, 'MM/DD/YYYY')           signature_date
    ,      xcd.entrepeneur1_initials || ' '
           || xcd.entrepeneur1_last_name                       entrep_name
    ,      xcd.store_number || ' ' || xcd.formule              store_name
    ,      xcd.frov_filename_1
    ,      xcd.frov_filename_2
    ,      xcd.frov_filename_3
    ,      xcd.kvk_filename_1
    ,      xcd.kvk_filename_2
    ,      xcd.kvk_filename_3
    ,      xcd.excl_filename_1
    ,      xcd.excl_filename_2
    ,      xcd.excl_filename_3
    ,      xcd.geld_filename_1
    ,      xcd.geld_filename_2
    ,      xcd.geld_filename_3
    ,      xcd.pand_filename_1
    ,      xcd.pand_filename_2
    ,      xcd.pand_filename_3
    ,      xcd.terk_filename_1
    ,      xcd.terk_filename_2
    ,      xcd.terk_filename_3
    ,      xcd.verk_filename_1
    ,      xcd.verk_filename_2
    ,      xcd.verk_filename_3
    ,      xcd.spaar_filename_1
    ,      xcd.spaar_filename_2
    ,      xcd.spaar_filename_3
    ,      xcd.zama_filename_1
    ,      xcd.zama_filename_2
    ,      xcd.zama_filename_3
    ,      xcd.onder_filename_1
    ,      xcd.onder_filename_2
    ,      xcd.onder_filename_3
    ,      xcd.ovc_filename_1
    ,      xcd.ovc_filename_2
    ,      xcd.ovc_filename_3
    ,      xcd.tnt_filename_1
    ,      xcd.tnt_filename_2
    ,      xcd.tnt_filename_3
    ,      xcd.add_filename_1
    ,      xcd.add_filename_2
    ,      xcd.add_filename_3
    ,      xcd.bank_filename_1
    ,      xcd.bank_filename_2
    ,      xcd.bank_filename_3
    ,      xcd.leen_filename_1
    ,      xcd.leen_filename_2
    ,      xcd.leen_filename_3
    FROM   xxah_contract_conv_data    xcd
    WHERE  -- xcd.store_process_status = gc_staging_done --JV
    --xcd.entre1_process_status = gc_staging_done
    --AND    xcd.entre2_process_status = gc_staging_done
    --AND    xcd.entre3_process_status = gc_staging_done
    --AND    xcd.entre4_process_status = gc_staging_done
    --AND    xcd.entre5_process_status = gc_staging_done
    xcd.legal_process_status = gc_staging_done
    AND    xcd.formule = p_formule
    AND    COCON  = 'Y'
    AND    xcd.store_number BETWEEN p_store_number_start AND p_store_number_end
    ) xcd
    -- make sure each project is only listed once
    WHERE ROWID IN
      (SELECT MIN(ROWID)
       FROM xxah_contract_conv_data
	     GROUP BY project_number
      );

  BEGIN

    -- print header for CSV
    out('Contract Number'          || gc_separator);
    out('Contract Name'            || gc_separator);
    out('Status'                   || gc_separator);
    out('Contract Type'            || gc_separator);
    out('Effective Date'           || gc_separator);
    out('Expiration Date'          || gc_separator);
    out('Operating Unit'           || gc_separator);
    out('Contract Administrator'   || gc_separator);
    out('Currency'                 || gc_separator);
    out('Amount'                   || gc_separator);
    out('Authoring Party'          || gc_separator);
    out('Physical Location'        || gc_separator);
    out('Keywords'                 || gc_separator);
    out('Description'              || gc_separator);
    out('Version Comments'         || gc_separator);
    out('Party 1 Name'             || gc_separator);
    out('Party 1 Role'             || gc_separator);
    out('Party 1 Signed By'        || gc_separator);
    out('Party 1 Signed Date'      || gc_separator);
    out('Party 2 Name'             || gc_separator);
    out('Party 2 Role'             || gc_separator);
    out('Party 2 Signed By'        || gc_separator);
    out('Party 2 Signed Date'      || gc_separator);
    out('Party 3 Name'             || gc_separator);
    out('Party 3 Role'             || gc_separator);
    out('Party 3 Signed By'        || gc_separator);
    out('Party 3 Signed Date'      || gc_separator);
    out('Contract Document 1 Type'        || gc_separator);
    out('Contract Document 1 Name'        || gc_separator);
    out('Contract Document 1 Category'    || gc_separator);
    out('Contract Document 1 Description' || gc_separator);
    out('Contract Document 2 Type'        || gc_separator);
    out('Contract Document 2 Name'        || gc_separator);
    out('Contract Document 2 Category'    || gc_separator);
    out('Contract Document 2 Description' || gc_separator);
    out('Contract Document 3 Type'        || gc_separator);
    out('Contract Document 3 Name'        || gc_separator);
    out('Contract Document 3 Category'    || gc_separator);
    out('Contract Document 3 Description' || gc_separator);
    out('Contract Document 4 Type'        || gc_separator);
    out('Contract Document 4 Name'        || gc_separator);
    out('Contract Document 4 Category'    || gc_separator);
    out('Contract Document 4 Description' || gc_separator);
    out('Contract Document 5 Type'        || gc_separator);
    out('Contract Document 5 Name'        || gc_separator);
    out('Contract Document 5 Category'    || gc_separator);
    out('Contract Document 5 Description' || gc_separator);
    out('Original System Reference Code'       || gc_separator);
    out('Original System Reference ID1'        || gc_separator);
    outline('Original System Reference ID2'    );

    -- print data
    FOR r_store_data IN c_export_csv
    LOOP

      IF r_store_data.frov_filename_1 IS NOT NULL
      THEN
        -- FROV
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name
        , p_contract_admin    => r_store_data.contract_admin
        , p_contract_type     => 'CRD Conversion'
        , p_eff_date          => r_store_data.frov_eff_date
        , p_exp_date          => r_store_data.frov_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.frov_filename_1
        , p_filename_2        => r_store_data.frov_filename_2
        , p_filename_3        => r_store_data.frov_filename_3
        , p_amount            => r_store_data.cum_purchase_value
        );
      END IF;

      /*IF r_store_data.frov_filename_1 IS NOT NULL
      THEN
        -- FROV
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_FROV'
        , p_contract_type     => 'Franchise Agreement'
        , p_eff_date          => r_store_data.frov_eff_date
        , p_exp_date          => r_store_data.frov_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.frov_filename_1
        , p_filename_2        => r_store_data.frov_filename_2
        , p_filename_3        => r_store_data.frov_filename_3
        );
      END IF;*/
      IF r_store_data.kvk_filename_1 IS NOT NULL
      THEN
        -- KVK
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_KVK'
        , p_contract_type     => 'Other'
        , p_eff_date          => r_store_data.kvk_eff_date
        , p_exp_date          => r_store_data.kvk_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.kvk_filename_1
        , p_filename_2        => r_store_data.kvk_filename_2
        , p_filename_3        => r_store_data.kvk_filename_3
        );
      END IF;
      IF r_store_data.excl_filename_1 IS NOT NULL
      THEN
        -- EXCL
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_EXCL'
        , p_contract_type     => 'Other'
        , p_eff_date          => r_store_data.excl_eff_date
        , p_exp_date          => r_store_data.excl_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.excl_filename_1
        , p_filename_2        => r_store_data.excl_filename_2
        , p_filename_3        => r_store_data.excl_filename_3
        );
      END IF;
      IF r_store_data.geld_filename_1 IS NOT NULL
      THEN
        -- GELD
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_GELD'
        , p_contract_type     => 'Service Agreement'
        , p_eff_date          => r_store_data.geld_eff_date
        , p_exp_date          => r_store_data.geld_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.geld_filename_1
        , p_filename_2        => r_store_data.geld_filename_2
        , p_filename_3        => r_store_data.geld_filename_3
        );
      END IF;
      IF r_store_data.pand_filename_1 IS NOT NULL
      THEN
        -- PAND
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_PAND'
        , p_contract_type     => 'Option to Buy'
        , p_eff_date          => r_store_data.pand_eff_date
        , p_exp_date          => r_store_data.pand_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.pand_filename_1
        , p_filename_2        => r_store_data.pand_filename_2
        , p_filename_3        => r_store_data.pand_filename_3
        );
      END IF;
      IF r_store_data.terk_filename_1 IS NOT NULL
      THEN
        -- TERK
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_TERK'
        , p_contract_type     => 'Option to Buy'
        , p_eff_date          => r_store_data.terk_eff_date
        , p_exp_date          => r_store_data.terk_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.terk_filename_1
        , p_filename_2        => r_store_data.terk_filename_2
        , p_filename_3        => r_store_data.terk_filename_3
        );
      END IF;
      IF r_store_data.verk_filename_1 IS NOT NULL
      THEN
        -- VERK
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_VERK'
        , p_contract_type     => 'Option to Buy'
        , p_eff_date          => r_store_data.verk_eff_date
        , p_exp_date          => r_store_data.verk_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.verk_filename_1
        , p_filename_2        => r_store_data.verk_filename_2
        , p_filename_3        => r_store_data.verk_filename_3
        );
      END IF;
      IF r_store_data.spaar_filename_1 IS NOT NULL
      THEN
        -- SPAAR
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_SPAAR'
        , p_contract_type     => 'Service Agreement'
        , p_eff_date          => r_store_data.spaar_eff_date
        , p_exp_date          => r_store_data.spaar_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.spaar_filename_1
        , p_filename_2        => r_store_data.spaar_filename_2
        , p_filename_3        => r_store_data.spaar_filename_3
        );
      END IF;
      IF r_store_data.zama_filename_1 IS NOT NULL
      THEN
        -- ZAMA
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_ZAMA'
        , p_contract_type     => 'Other'
        , p_eff_date          => r_store_data.zama_eff_date
        , p_exp_date          => r_store_data.zama_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.zama_filename_1
        , p_filename_2        => r_store_data.zama_filename_2
        , p_filename_3        => r_store_data.zama_filename_3
        );
      END IF;
      IF r_store_data.onder_filename_1 IS NOT NULL
      THEN
        -- ONDER
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_ONDR'
        , p_contract_type     => 'Maintenance / Support Agreement'
        , p_eff_date          => r_store_data.onder_eff_date
        , p_exp_date          => r_store_data.onder_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.onder_filename_1
        , p_filename_2        => r_store_data.onder_filename_2
        , p_filename_3        => r_store_data.onder_filename_3
        );
      END IF;
      IF r_store_data.ovc_filename_1 IS NOT NULL
      THEN
        -- OVC
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_OVC'
        , p_contract_type     => 'Service Agreement'
        , p_eff_date          => r_store_data.ovc_eff_date
        , p_exp_date          => r_store_data.ovc_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.ovc_filename_1
        , p_filename_2        => r_store_data.ovc_filename_2
        , p_filename_3        => r_store_data.ovc_filename_3
        );
      END IF;
      IF r_store_data.tnt_filename_1 IS NOT NULL
      THEN
        -- TNT
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_TNT'
        , p_contract_type     => 'Service Agreement'
        , p_eff_date          => r_store_data.tnt_eff_date
        , p_exp_date          => r_store_data.tnt_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.tnt_filename_1
        , p_filename_2        => r_store_data.tnt_filename_2
        , p_filename_3        => r_store_data.tnt_filename_3
        );
      END IF;
      IF r_store_data.add_filename_1 IS NOT NULL
      THEN
        -- ADD
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_ADD'
        , p_contract_type     => 'Amendment'
        , p_eff_date          => r_store_data.add_eff_date
        , p_exp_date          => r_store_data.add_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.add_filename_1
        , p_filename_2        => r_store_data.add_filename_2
        , p_filename_3        => r_store_data.add_filename_3
        );
      END IF;
      IF r_store_data.bank_filename_1 IS NOT NULL
      THEN
        -- BANK
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_BANK'
        , p_contract_type     => 'Bank Guarantee/ Letter of Credit'
        , p_eff_date          => r_store_data.bank_eff_date
        , p_exp_date          => r_store_data.bank_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.bank_filename_1
        , p_filename_2        => r_store_data.bank_filename_2
        , p_filename_3        => r_store_data.bank_filename_3
        );
      END IF;
      IF r_store_data.leen_filename_1 IS NOT NULL
      THEN
        -- LEEN
        print_csv_data
        ( p_contract_name     => r_store_data.contract_name || '_LEEN'
        , p_contract_type     => 'Loan Agreement'
        , p_eff_date          => r_store_data.leen_eff_date
        , p_exp_date          => r_store_data.leen_exp_date
        , p_keywords          => r_store_data.keywords
        , p_legal_entity_name => r_store_data.legal_entity_name
        , p_signature_date    => r_store_data.signature_date
        , p_store_name        => r_store_data.store_name
        , p_filename_1        => r_store_data.leen_filename_1
        , p_filename_2        => r_store_data.leen_filename_2
        , p_filename_3        => r_store_data.leen_filename_3
        );
      END IF;
    END LOOP;
  END export_csv;

 /* ************************************************************************
  * PROCEDURE   :  port_import
  * DESCRIPTION :  perform the after-import conversion steps
  * PARAMETERS   :  -
  *************************************************************************/
  PROCEDURE post_import
  ( errbuf       OUT VARCHAR2
  , retcode      OUT NUMBER
  , p_request_id IN  OKC_REP_CONTRACTS_ALL.request_id%TYPE
  ) IS

    CURSOR c_contracts(b_request_id OKC_REP_CONTRACTS_ALL.request_id%TYPE)
    IS
    SELECT c.contract_id
    ,      c.contract_number
    ,      c.contract_type    contract_type
    FROM   okc_rep_contracts_all c
    WHERE  c.request_id = b_request_id;


    l_no_risk_event_id    NUMBER;

  BEGIN

    FOR r_contract IN c_contracts(p_request_id)
    LOOP

      SELECT risk_event_id
      INTO   l_no_risk_event_id
      FROM   okc_risk_events_tl
      WHERE  name = 'No Risk'
      AND    language = 'US'
      ;

      -- insert no-risk
      INSERT INTO okc_contract_risks
      ( business_document_type
      , business_document_id
      , business_document_version
      , risk_event_id
      , risk_occurred_flag
      , object_version_number
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
      , last_update_login
      )
      VALUES
      ( r_contract.contract_type   -- business_document_type
      , r_contract.contract_id     -- business_document_id
      , -99                        -- business_document_version
      , l_no_risk_event_id         -- risk_event_id
      , 'N'                        -- risk_occurred_flag
      , 1                          -- object_version_number
      , fnd_global.user_id         -- created_by
      , SYSDATE                    -- creation_date
      , fnd_global.user_id         -- last_updated_by
      , SYSDATE                    -- last_update_date
      , fnd_global.login_id        -- last_update_login
      );

      outline('Inserted risk for contract '|| r_contract.contract_number ||': ' || SQL%ROWCOUNT);

    END LOOP;

  END post_import;

END XXAH_CONTRACT_CONV_PKG;

/
