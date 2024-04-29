--------------------------------------------------------
--  DDL for Package Body CAC_SYNC_CONTACT_DQM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SYNC_CONTACT_DQM_PVT" as
/* $Header: cacvscqb.pls 120.3 2006/01/13 17:09:16 twan noship $ */

    /* -- Private methods -- */

    -- This is used to get the translated user profile option name
    FUNCTION GET_USER_PROFILE_NAME(p_profile_option_name IN VARCHAR2)
    RETURN VARCHAR2
    IS
        CURSOR c_profile IS
        SELECT user_profile_option_name
          FROM fnd_profile_options_vl
         WHERE profile_option_name = p_profile_option_name;

        l_user_profile_option_name fnd_profile_options_tl.user_profile_option_name%TYPE;
    BEGIN
        OPEN c_profile;
        FETCH c_profile INTO l_user_profile_option_name;
        CLOSE c_profile;

        RETURN l_user_profile_option_name;
    END GET_USER_PROFILE_NAME;

    -- This is used to get an organization party id after DQM search
    FUNCTION GET_ORGANIZATION_PARTY_ID(p_search_ctx_id IN NUMBER)
    RETURN NUMBER
    IS
        CURSOR c_party IS
        SELECT party_id
          FROM hz_matched_parties_gt
         WHERE search_context_id = p_search_ctx_id;

        l_org_party_id NUMBER;
    BEGIN
        OPEN c_party;
        FETCH c_party INTO l_org_party_id;
        CLOSE c_party;

        RETURN l_org_party_id;
    END GET_ORGANIZATION_PARTY_ID;

    FUNCTION filter_ph_num(p_inval   IN  VARCHAR2)
    RETURN VARCHAR2 IS
    BEGIN
      IF p_inval IS NULL THEN
        RETURN NULL;
      END IF;
      RETURN translate(
        p_inval,
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!"#$%&()''*+,-./:;<=>?@[\]^_`{|}~ ',
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ');
    END;

    -- This is used to get a record for contact_search_rec_type
    FUNCTION GET_CONTACT_SEARCH_REC
    ( p_contact_name       IN VARCHAR2
    , p_person_name        IN VARCHAR2
    , p_person_first_name  IN VARCHAR2
    , p_person_last_name   IN VARCHAR2
    , p_person_middle_name IN VARCHAR2
    , p_person_name_suffix IN VARCHAR2
    , p_person_title       IN VARCHAR2
    , p_job_title          IN VARCHAR2
    )
    RETURN hz_party_search.contact_search_rec_type
    IS
        l_contact_search_rec hz_party_search.contact_search_rec_type;
    BEGIN
        l_contact_search_rec.contact_name       := p_contact_name;
        l_contact_search_rec.person_name        := p_person_name;
        l_contact_search_rec.person_first_name  := p_person_first_name;
        l_contact_search_rec.person_last_name   := p_person_last_name;
        l_contact_search_rec.person_middle_name := p_person_middle_name;
        l_contact_search_rec.person_name_suffix := p_person_name_suffix;
        l_contact_search_rec.person_title       := p_person_title;
        l_contact_search_rec.job_title          := p_job_title;

        RETURN l_contact_search_rec;
    END GET_CONTACT_SEARCH_REC;

    -- This is used to get a record for contact_point_search_rec_type for PHONE
    PROCEDURE GET_CONTACT_POINT_SEARCH_REC
    ( p_contact_point_type     IN VARCHAR2
    , p_phone_line_type        IN VARCHAR2
    , p_phone_country_code     IN VARCHAR2
    , p_phone_area_code        IN VARCHAR2
    , p_phone_number           IN VARCHAR2
    , p_contact_point_purpose  IN VARCHAR2
    , p_status                 IN VARCHAR2
    , x_contact_point_list     IN OUT NOCOPY hz_party_search.contact_point_list
    )
    IS
        l_index NUMBER;
    BEGIN
        IF p_phone_number IS NOT NULL THEN
            l_index := NVL(x_contact_point_list.LAST,0) + 1;
            x_contact_point_list(l_index).contact_point_type    := p_contact_point_type;
            x_contact_point_list(l_index).phone_line_type       := p_phone_line_type;
            x_contact_point_list(l_index).phone_country_code    := p_phone_country_code;
            x_contact_point_list(l_index).phone_area_code       := p_phone_area_code;
            x_contact_point_list(l_index).phone_number          := p_phone_number;
            x_contact_point_list(l_index).contact_point_purpose := p_contact_point_purpose;
            x_contact_point_list(l_index).status                := p_status;
            x_contact_point_list(l_index).flex_format_phone_number := filter_ph_num(p_phone_country_code || p_phone_area_code || p_phone_number);
            x_contact_point_list(l_index).raw_phone_number := filter_ph_num(p_phone_country_code || p_phone_area_code || p_phone_number);
        END IF;
    END GET_CONTACT_POINT_SEARCH_REC;

    -- This is used to get a record for contact_point_search_rec_type for EMAIL
    PROCEDURE GET_CONTACT_POINT_SEARCH_REC(
         p_contact_point_type IN VARCHAR2
        ,p_email_format       IN VARCHAR2
        ,p_email_address      IN VARCHAR2
        ,p_status             IN VARCHAR2
        ,x_contact_point_list IN OUT NOCOPY hz_party_search.contact_point_list
    )
    IS
        l_index NUMBER;
    BEGIN
        IF p_email_address IS NOT NULL THEN
            l_index := NVL(x_contact_point_list.LAST,0) + 1;
            x_contact_point_list(l_index).contact_point_type := p_contact_point_type;
            x_contact_point_list(l_index).email_format       := p_email_format;
            x_contact_point_list(l_index).email_address      := p_email_address;
            x_contact_point_list(l_index).status             := p_status;
        END IF;
    END GET_CONTACT_POINT_SEARCH_REC;

    PROCEDURE GET_CONTACT_POINT_LIST
    ( p_work_phone_country_code  IN   VARCHAR2
    , p_work_phone_area_code     IN   VARCHAR2
    , p_work_phone_number        IN   VARCHAR2
    , p_home_phone_country_code  IN   VARCHAR2
    , p_home_phone_area_code     IN   VARCHAR2
    , p_home_phone_number        IN   VARCHAR2
    , p_fax_phone_country_code   IN   VARCHAR2
    , p_fax_phone_area_code      IN   VARCHAR2
    , p_fax_phone_number         IN   VARCHAR2
    , p_pager_phone_country_code IN   VARCHAR2
    , p_pager_phone_area_code    IN   VARCHAR2
    , p_pager_phone_number       IN   VARCHAR2
    , p_cell_phone_country_code  IN   VARCHAR2
    , p_cell_phone_area_code     IN   VARCHAR2
    , p_cell_phone_number        IN   VARCHAR2
    , p_text_email_address       IN   VARCHAR2
    , p_html_email_address       IN   VARCHAR2
    , x_contact_point_list       IN OUT NOCOPY hz_party_search.contact_point_list
    )
    IS
    BEGIN
        get_contact_point_search_rec
        (p_contact_point_type     => 'PHONE'
        ,p_phone_line_type        => 'GEN'
        ,p_phone_country_code     => p_work_phone_country_code
        ,p_phone_area_code        => p_work_phone_area_code
        ,p_phone_number           => p_work_phone_number
        ,p_contact_point_purpose  => 'BUSINESS'
        ,p_status                 => 'A'
        ,x_contact_point_list     => x_contact_point_list
        );

        get_contact_point_search_rec
        (p_contact_point_type     => 'PHONE'
        ,p_phone_line_type        => 'GEN'
        ,p_phone_country_code     => p_home_phone_country_code
        ,p_phone_area_code        => p_home_phone_area_code
        ,p_phone_number           => p_home_phone_number
        ,p_contact_point_purpose  => 'PERSONAL'
        ,p_status                 => 'A'
        ,x_contact_point_list     => x_contact_point_list
        );

        get_contact_point_search_rec
        (p_contact_point_type     => 'PHONE'
        ,p_phone_line_type        => 'FAX'
        ,p_phone_country_code     => p_fax_phone_country_code
        ,p_phone_area_code        => p_fax_phone_area_code
        ,p_phone_number           => p_fax_phone_number
        ,p_contact_point_purpose  => NULL
        ,p_status                 => 'A'
        ,x_contact_point_list     => x_contact_point_list
        );

        get_contact_point_search_rec
        (p_contact_point_type     => 'PHONE'
        ,p_phone_line_type        => 'MOBILE'
        ,p_phone_country_code     => p_cell_phone_country_code
        ,p_phone_area_code        => p_cell_phone_area_code
        ,p_phone_number           => p_cell_phone_number
        ,p_contact_point_purpose  => NULL
        ,p_status                 => 'A'
        ,x_contact_point_list     => x_contact_point_list
        );

        get_contact_point_search_rec
        (p_contact_point_type     => 'PHONE'
        ,p_phone_line_type        => 'PAGER'
        ,p_phone_country_code     => p_pager_phone_country_code
        ,p_phone_area_code        => p_pager_phone_area_code
        ,p_phone_number           => p_pager_phone_number
        ,p_contact_point_purpose  => NULL
        ,p_status                 => 'A'
        ,x_contact_point_list     => x_contact_point_list
        );

        get_contact_point_search_rec
        (p_contact_point_type => 'EMAIL'
        ,p_email_format       => 'MAILTEXT'
        ,p_email_address      => p_text_email_address
        ,p_status             => 'A'
        ,x_contact_point_list => x_contact_point_list
        );

        get_contact_point_search_rec
        (p_contact_point_type => 'EMAIL'
        ,p_email_format       => 'MAILHTML'
        ,p_email_address      => p_html_email_address
        ,p_status             => 'A'
        ,x_contact_point_list => x_contact_point_list
        );

    END GET_CONTACT_POINT_LIST;

    FUNCTION GET_PARTY_ID (p_search_context_id IN NUMBER)
    RETURN NUMBER
    IS
        CURSOR c_ctx (b_search_context_id NUMBER) IS
		SELECT REL.PARTY_ID
		  FROM HZ_RELATIONSHIPS REL
		     , HZ_ORG_CONTACTS ORCT
		     , HZ_MATCHED_CONTACTS_GT GT
		 WHERE REL.RELATIONSHIP_ID = ORCT.PARTY_RELATIONSHIP_ID
		   AND REL.DIRECTIONAL_FLAG = 'F'
		   AND ORCT.ORG_CONTACT_ID = GT.ORG_CONTACT_ID
		   AND GT.SEARCH_CONTEXT_ID = b_search_context_id;

        l_party_id NUMBER;
    BEGIN
        OPEN c_ctx(p_search_context_id);
        FETCH c_ctx INTO l_party_id;
        CLOSE c_ctx;

        RETURN l_party_id;
    END GET_PARTY_ID;

    /* -- Public methods -- */

    PROCEDURE FIND_ORGANIZATION
    ( p_init_msg_list      IN   VARCHAR2
    , p_organization_name  IN   VARCHAR2
    , p_contact_name       IN   VARCHAR2
    , x_organization_id    OUT NOCOPY NUMBER
    , x_return_status      OUT NOCOPY VARCHAR2
    , x_msg_count          OUT NOCOPY NUMBER
    , x_msg_data           OUT NOCOPY VARCHAR2
    )
    IS
        l_party_search_rec   hz_party_search.party_search_rec_type;
        l_party_site_list    hz_party_search.party_site_list;
        l_contact_list       hz_party_search.contact_list;
        l_contact_point_list hz_party_search.contact_point_list;
        l_search_ctx_id      NUMBER;
        l_num_matches        NUMBER;
        l_rule_id NUMBER;
    BEGIN
        IF p_init_msg_list IS NULL OR
           fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        l_rule_id := fnd_profile.value('HZ_ORG_DUP_PREV_MATCHRULE');

        IF l_rule_id IS NULL THEN
            fnd_message.set_name ('JTF', 'CAC_SYNC_CONTACT_MATCH_RULE_NF');
            fnd_message.set_token ('P_PROFILE', get_user_profile_name('HZ_ORG_DUP_PREV_MATCHRULE'));
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        l_party_search_rec.organization_name := p_organization_name;
        l_party_search_rec.party_all_names := p_organization_name;
        l_party_search_rec.party_name := p_organization_name;
        l_party_search_rec.party_type := 'ORGANIZATION';
        l_party_search_rec.status     := 'A';

        hz_party_search.find_parties(
            p_init_msg_list      => fnd_api.g_false,
            x_rule_id            => l_rule_id,
            p_party_search_rec   => l_party_search_rec,
            p_party_site_list    => l_party_site_list,
            p_contact_list       => l_contact_list,
            p_contact_point_list => l_contact_point_list,
            p_restrict_sql       => NULL,
            p_search_merged      => 'N',
            x_search_ctx_id      => l_search_ctx_id,
            x_num_matches        => l_num_matches,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        ELSE
            IF l_num_matches = 1 THEN
                x_organization_id := get_organization_party_id(l_search_ctx_id);
            ELSE
                IF l_num_matches = 0 THEN
                    -- Error message:  <Contact Name>: Organization does not exist, contact not synchronized.
                    fnd_message.set_name ('JTF', 'CAC_SYNC_DQM_ORG_NOTFOUND');
                    fnd_message.set_token ('P_CONTACT_NAME', p_contact_name);
                ELSE
                    -- Error message: <Contact Name>: Multiple matches for the organization were found, contact not synchronized.
                    fnd_message.set_name ('JTF', 'CAC_SYNC_DQM_ORG_TOOMANY');
                    fnd_message.set_token ('P_CONTACT_NAME', p_contact_name);
                END IF;
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error THEN
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
            fnd_message.set_name ('JTF', 'CAC_SYNC_CONTACT_UNEXPECTED_ER');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END FIND_ORGANIZATION;

    PROCEDURE CHECK_CONTACT
    ( p_init_msg_list            IN   VARCHAR2
    , p_org_party_id             IN   NUMBER
    , p_organization_name        IN   VARCHAR2
    , p_person_full_name         IN   VARCHAR2
    , p_person_first_name        IN   VARCHAR2
    , p_person_last_name         IN   VARCHAR2
    , p_person_middle_name       IN   VARCHAR2
    , p_person_name_suffix       IN   VARCHAR2
    , p_person_title             IN   VARCHAR2
    , p_job_title                IN   VARCHAR2
    , p_work_phone_country_code  IN   VARCHAR2
    , p_work_phone_area_code     IN   VARCHAR2
    , p_work_phone_number        IN   VARCHAR2
    , p_home_phone_country_code  IN   VARCHAR2
    , p_home_phone_area_code     IN   VARCHAR2
    , p_home_phone_number        IN   VARCHAR2
    , p_fax_phone_country_code   IN   VARCHAR2
    , p_fax_phone_area_code      IN   VARCHAR2
    , p_fax_phone_number         IN   VARCHAR2
    , p_pager_phone_country_code IN   VARCHAR2
    , p_pager_phone_area_code    IN   VARCHAR2
    , p_pager_phone_number       IN   VARCHAR2
    , p_cell_phone_country_code  IN   VARCHAR2
    , p_cell_phone_area_code     IN   VARCHAR2
    , p_cell_phone_number        IN   VARCHAR2
    , p_text_email_address       IN   VARCHAR2
    , p_html_email_address       IN   VARCHAR2
    , p_match_type               IN   VARCHAR2
    , x_return_status            OUT NOCOPY VARCHAR2
    , x_msg_count                OUT NOCOPY NUMBER
    , x_msg_data                 OUT NOCOPY VARCHAR2
    , x_num_of_matches           OUT NOCOPY NUMBER
    , x_party_id                 OUT NOCOPY NUMBER
    )
    IS
        l_contact_list       hz_party_search.contact_list;
        l_contact_point_list hz_party_search.contact_point_list;
        l_search_ctx_id      NUMBER;
        l_rule_id NUMBER;
        l_num_matches NUMBER;
        l_index NUMBER;
    BEGIN
        IF p_init_msg_list IS NULL OR
           fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        x_return_status := fnd_api.g_ret_sts_success;

        l_rule_id := fnd_profile.value('HZ_CON_DUP_PREV_MATCHRULE');
        IF l_rule_id IS NULL THEN
            fnd_message.set_name ('JTF', 'CAC_SYNC_CONTACT_MATCH_RULE_NF');
            fnd_message.set_token ('P_PROFILE', get_user_profile_name('HZ_CON_DUP_PREV_MATCHRULE'));
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Prepare contact list
        l_contact_list(1) := get_contact_search_rec
                             (p_contact_name       => p_person_full_name
                             ,p_person_name        => p_person_full_name
                             ,p_person_first_name  => p_person_first_name
                             ,p_person_last_name   => p_person_last_name
                             ,p_person_middle_name => p_person_middle_name
                             ,p_person_name_suffix => p_person_name_suffix
                             ,p_person_title       => p_person_title
                             ,p_job_title          => p_job_title
                             );

        -- Prepare contact point list
        get_contact_point_list
        ( p_work_phone_country_code  => p_work_phone_country_code
        , p_work_phone_area_code     => p_work_phone_area_code
        , p_work_phone_number        => p_work_phone_number
        , p_home_phone_country_code  => p_home_phone_country_code
        , p_home_phone_area_code     => p_home_phone_area_code
        , p_home_phone_number        => p_home_phone_number
        , p_fax_phone_country_code   => p_fax_phone_country_code
        , p_fax_phone_area_code      => p_fax_phone_area_code
        , p_fax_phone_number         => p_fax_phone_number
        , p_pager_phone_country_code => p_pager_phone_country_code
        , p_pager_phone_area_code    => p_pager_phone_area_code
        , p_pager_phone_number       => p_pager_phone_number
        , p_cell_phone_country_code  => p_cell_phone_country_code
        , p_cell_phone_area_code     => p_cell_phone_area_code
        , p_cell_phone_number        => p_cell_phone_number
        , p_text_email_address       => p_text_email_address
        , p_html_email_address       => p_html_email_address
        , x_contact_point_list       => l_contact_point_list
        );

        -- Perform DQM check for contacts
        hz_party_search.get_matching_contacts(
            p_init_msg_list      => fnd_api.g_false,
            p_rule_id            => l_rule_id,
            p_party_id           => p_org_party_id,
            p_contact_list       => l_contact_list,
            p_contact_point_list => l_contact_point_list,
            p_restrict_sql       => null,
            p_match_type         => p_match_type,
            x_search_ctx_id      => l_search_ctx_id,
            x_num_matches        => l_num_matches,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        ELSE
            IF l_num_matches > 1 THEN
                -- Error message: <Contact Name>: Multiple matches for the contact were found, contact not synchronized.
                fnd_message.set_name ('JTF', 'CAC_SYNC_DQM_CONTACT_EXISTS');
                fnd_message.set_token ('P_CONTACT_NAME', p_person_full_name);
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            ELSE
                x_num_of_matches := l_num_matches;
                x_party_id := get_party_id(l_search_ctx_id);
            END IF;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error THEN
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
            fnd_message.set_name ('JTF', 'CAC_SYNC_CONTACT_UNEXPECTED_ER');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END CHECK_CONTACT;

END CAC_SYNC_CONTACT_DQM_PVT;

/
