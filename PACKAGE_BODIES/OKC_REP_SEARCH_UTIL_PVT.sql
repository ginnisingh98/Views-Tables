--------------------------------------------------------
--  DDL for Package Body OKC_REP_SEARCH_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REP_SEARCH_UTIL_PVT" AS
/* $Header: OKCVREPSRCHUTILB.pls 120.0.12010000.5 2011/07/15 07:17:00 kkolukul noship $ */


  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------

    -- API name     : get_rep_doc_acl
    -- Type         : Private.
    -- Function     : Called in the BusDocSearchPlugIn class by the AppSearch
    --                Framework at crawl-time to get the ACL list for the given
    --                contract document (for repository contracts) or for the
    --                given contract document and version (for archived
    --                contracts). The list of ACLs is then indexed with the
    --                document to be used at query-time to determine whether
    --                a user has access to the document.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : p_bus_doc_id IN NUMBER
    --                   The document ID of the contract document currently
    --                   being crawled.
    --   IN         : p_bus_doc_version IN NUMBER
    --                   The version of the contract document currently being
    --                   crawled.
    --   IN           p_driving_table IN VARCHAR2
    --                   The table that drives the VO associated with the
    --                   contract document currently being crawled. There are
    --                   two possible values: 'okc_rep_contracts_all' (for
    --                   repository contracts) and 'okc_rep_contract_vers'
    --                   (for archived contracts).
    --   OUT        : x_acl OUT VARCHAR2
    --                   A space-delimited string of ACL keys that define
    --                   access to this document.
    --                   Example:  g32324 g4434 u88932 u72223 admin_acl o23452
    -- Note         :
   PROCEDURE get_rep_doc_acl
    ( p_bus_doc_id IN NUMBER,
      p_bus_doc_version IN NUMBER,
      p_driving_table IN VARCHAR2,
      x_acl OUT NOCOPY VARCHAR2)
    IS
        l_api_name VARCHAR2(30);
        l_use_acl_flag VARCHAR2(1);

        -- Get group IDs for a given contract
        CURSOR group_csr
         IS
            SELECT g.parameter2 group_id
            FROM
                fnd_grants g,
                fnd_objects o
            WHERE
                g.object_id = o.object_id
            AND  o.obj_name = 'OKC_REP_CONTRACT'
            AND  g.instance_pk1_value = p_bus_doc_id
            AND  g.parameter1 = 'GROUP';

        -- Get user IDs for a given contract
        CURSOR user_csr
         IS
            SELECT  g.parameter2 user_id
            FROM
                fnd_grants g,
                fnd_objects o
            WHERE
                g.object_id = o.object_id
            AND  o.obj_name = 'OKC_REP_CONTRACT'
            AND  g.instance_pk1_value = p_bus_doc_id
            AND  g.parameter1 <> 'GROUP';

        -- Get owner IDs for a given repository contract
        CURSOR owner_rep_csr
         IS
            SELECT owner_id
            FROM okc_rep_contracts_all
            WHERE contract_id = p_bus_doc_id;

        -- Get owner IDs for a given archive contract
        CURSOR owner_archive_csr
         IS
            SELECT owner_id
            FROM okc_rep_contract_vers
            WHERE
                contract_id = p_bus_doc_id
            AND contract_version_num = p_bus_doc_version;

        group_rec           group_csr%ROWTYPE;
        user_rec            user_csr%ROWTYPE;
        owner_rep_rec       owner_rep_csr%ROWTYPE;
        owner_archive_rec   owner_archive_csr%ROWTYPE;

   BEGIN

       l_api_name := 'get_rep_doc_acl';

       -- Do logging.
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,
            'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
            '200: Entered OKC_REP_SEARCH_UTIL_PVT.get_rep_doc_acl');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,
            'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
            '201: Contract Id is: ' || to_char(p_bus_doc_id));
       END IF;
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
            'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
            'Input parameters are: p_bus_doc_id = ' || p_bus_doc_id ||
            ', p_bus_doc_version = ' || p_bus_doc_version ||
            ', p_driving_table = ' || p_driving_table ||
            '.');
       END IF;

       -- 1. Get contract.use_acl_flag for the given p_bus_doc_id.
       --    nvl: if the value returned is null, set it to 'N'.
       SELECT nvl(use_acl_flag,'N')
       INTO l_use_acl_flag
       FROM okc_rep_contracts_all
       WHERE contract_id = p_bus_doc_id;

       -- 2. If (contract.use_acl_flag == false), then add the string
       --    'no_acl' to the ACL.
       IF (l_use_acl_flag = 'N')
       THEN
            x_acl := x_acl || 'no_acl' || ' ';

       -- 3. Else:
       ELSE
            --     a. Get all the groups having access to this contract. Add
            --        the concatenated string g<group_id> g<group_id>.. to the
            --        ACL.
            FOR group_rec IN group_csr
            LOOP
                x_acl := x_acl || 'g' || to_char(group_rec.group_id) || ' ';
  	        END LOOP;

            --     b. Get all the users having access to this contract. Add
            --        the concatenated string u<user_id> u<user_id> to the ACL.
            FOR user_rec IN user_csr
            LOOP
                x_acl := x_acl || 'u' || to_char(user_rec.user_id) || ' ';
            END LOOP;
       END IF;

       -- 4. Add the string 'admin_acl' to the ACL.
       x_acl := x_acl || 'admin_acl' || ' ';

       -- 5. Add the contract owner's user id o<user_id> to the ACL.
       -- If the driving table is 'okc_rep_contracts_all' (repository
       -- contracts), we need to match only the document ID and not the
       -- document version, so we use the owner_rep_csr cursor.
       IF (p_driving_table = 'okc_rep_contracts_all')
       THEN
            FOR owner_rep_rec IN owner_rep_csr
            LOOP
                x_acl := x_acl || 'o' || to_char(owner_rep_rec.owner_id) || ' ';
            END LOOP;
       -- Else, the driving table is 'okc_rep_contract_vers' (the archive of
       -- contracts) and we need to match the version as well as the ID. See
       -- the owner_archive_csr cursor.
       ELSE
            FOR owner_archive_rec IN owner_archive_csr
            LOOP
                x_acl := x_acl || 'o' || to_char(owner_archive_rec.owner_id)
                || ' ';
            END LOOP;
       END IF;

       -- Do logging.
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'OKC_REP_UTIL_PVT.get_rep_doc_acl
                returns x_acl as : '
                || x_acl);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'Leaving  get_rep_doc_acl');
       END IF;

       EXCEPTION
            WHEN OTHERS
            THEN
                IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                        'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'
                        ||l_api_name,
                        'Leaving PROCEDURE get_rep_doc_acl
                        because of EXCEPTION: '
                        ||sqlerrm);
                END IF;
            Okc_Api.Set_Message(p_app_name     => 'OKC',
                p_msg_name     => OKC_REP_UTIL_PVT.G_UNEXPECTED_ERROR,
                p_token1       => OKC_REP_UTIL_PVT.G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => OKC_REP_UTIL_PVT.G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm);

   END;


    -- API name     : get_current_user_acl_keys
    -- Type         : Private.
    -- Function     : Called in the BusDocSearchPlugIn class by the AppSearch
    --                Framework at query-time to get the ACL keys for the
    --                current user. This list of ACL keys is then used to
    --                check each search hit and verify that the user is
    --                permitted to view that specific hit. If a user is
    --                not permitted to view a given hit, then that hit is
    --                removed from the query result set.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : None.
    --   OUT        : x_keys  OUT VARCHAR2
    --                   A space-delimited string of ACL keys that define
    --                   the user's access rights.
    --                   Example:  no_acl o23452 u23452 g2241 g2308
    -- Note         :
   PROCEDURE get_current_user_acl_keys
    ( x_keys OUT NOCOPY VARCHAR2)
    IS
        l_api_name VARCHAR2(30);
        l_resource_id  NUMBER;
        l_user_id NUMBER;

    -- Get the resource ids of the current user.
    CURSOR user_csr IS
        SELECT resource_id
        FROM   jtf_rs_resource_extns
        WHERE  user_id = FND_GLOBAL.user_id();


    -- Get all the groups for a resource id.
    CURSOR group_csr(l_resource_id NUMBER) IS
        SELECT group_id
        FROM jtf_rs_group_members
        WHERE resource_id=l_resource_id;

    user_rec    user_csr%ROWTYPE;
    group_rec   group_csr%ROWTYPE;

    BEGIN
       l_api_name := 'get_current_user_acl_keys';

       -- Do logging.
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                '200: Entered OKC_REP_SEARCH_UTIL_PVT.get_current_user_acl_keys');
       END IF;

       -- 1. Add the string 'no_acl' to the ACL keys.
       x_keys := 'no_acl' || ' ';

       -- 2. Add the current user o<user_id> to the ACL keys.
       l_user_id := FND_GLOBAL.user_id();
       x_keys := x_keys || 'o' || to_char(l_user_id) || ' ';

       -- 3. If (the current user has admin responsibility), then add
       --    'admin_acl' and return the list of ACL keys.
       IF (FND_FUNCTION.TEST(OKC_REP_UTIL_PVT.G_FUNC_OKC_REP_ADMINISTRATOR,'Y'))
       THEN
            x_keys := x_keys || 'admin_acl';

       -- 4. Else:
       ELSE

            --     a. Add the current user u<user_id> to the ACL keys.
            x_keys := x_keys || 'u' || to_char(l_user_id) || ' ';

            --     b. Get all the groups of the current user. Add the
            --        concatenated string g<group_id> g<group_id>.. to the ACL keys.
            FOR user_rec IN user_csr
            LOOP
                l_resource_id := user_rec.resource_id;
		-- Bug 12660114
                -- get the current user resource Number from JTF objects and
                -- add the u<user_rec.resource_id> to the acl keys

                x_keys := x_keys || 'u' || to_char(l_resource_id) || ' ';

                FOR group_rec IN group_csr(l_resource_id)
                LOOP
    	           x_keys := x_keys || 'g' || to_char(group_rec.group_id) || ' ';
                END LOOP;
            END LOOP;

       END IF;

       -- Do logging.
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'OKC_REP_UTIL_PVT.get_current_user_acl_keys
                returns x_keys as : '
                || x_keys);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'Leaving  get_current_user_acl_keys');
       END IF;

       EXCEPTION
            WHEN OTHERS
            THEN
                IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                        'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'
                        ||l_api_name,
                        'Leaving PROCEDURE get_current_user_acl_keys
                        because of EXCEPTION: '
                        ||sqlerrm);
                END IF;
            Okc_Api.Set_Message(p_app_name     => 'OKC',
                p_msg_name     => OKC_REP_UTIL_PVT.G_UNEXPECTED_ERROR,
                p_token1       => OKC_REP_UTIL_PVT.G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => OKC_REP_UTIL_PVT.G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm);
    END;


    -- API name     : get_current_user_moac_keys
    -- Type         : Private.
    -- Function     : Called in the BusDocSearchPlugIn class by the AppSearch
    --                Framework at query-time to get the list of operating
    --                units that the current user may access. This list of
    --                operating unit IDs is then used to check each search hit
    --                and verify that the user is permitted to view that
    --                specific hit. If a user is not permitted to view a given
    --                hit, then that hit is removed from the query result set.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : None.
    --   OUT        : x_keys  OUT VARCHAR2
    --                   A space-delimited string of the IDs of the operating
    --                   units to which the current user has access.
    --                   Example:  134 325 4384
    -- Note         :
   PROCEDURE get_current_user_moac_keys
    ( x_keys OUT NOCOPY VARCHAR2)
    IS
        l_api_name VARCHAR2(30);
        l_ou_tab MO_GLOBAL.OrgIdTab;

        l_user_id      NUMBER;
        l_resp_id      NUMBER;
        l_resp_appl_id NUMBER;
        l_security_grp_id NUMBER;

    CURSOR get_moac_org_id IS
    SELECT ou.organization_id   org_id
    FROM hr_operating_units ou
    WHERE mo_global.check_access(ou.organization_id) = 'Y';


    BEGIN

       l_api_name := 'get_current_user_moac_keys';

       -- Do logging.
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,
            'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
            '200: Entered OKC_REP_SEARCH_UTIL_PVT.get_current_user_moac_keys');
       END IF;

        l_user_id := FND_GLOBAL.user_id;
        l_resp_id := FND_GLOBAL.RESP_ID;
        l_security_grp_id := FND_GLOBAL.SECURITY_GROUP_ID;
        l_resp_appl_id := 510;

        fnd_global.apps_initialize(l_user_id,l_resp_id, l_resp_appl_id);
        MO_GLOBAL.init('OKC');



       -- 1. Call MO_GLOBAL.get_ou_tab to get the current user's accessible
       --    operating units in a temporary table.
       --
       --    (Uncomment the following for testing purposes)
       --       MO_GLOBAL.init('OKC');
       --       MO_GLOBAL.set_policy_context('M',204);
       --l_ou_tab := MO_GLOBAL.get_ou_tab;//Commented this.Using the cursor instead

       OPEN get_moac_org_id;
       FETCH get_moac_org_id BULK COLLECT INTO l_ou_tab;
       CLOSE get_moac_org_id;


       -- 2. Create a space-separated string of operating unit IDs using the
       --    temp table from step 1.
      IF (l_ou_tab.COUNT > 0)
       THEN
            FOR i IN l_ou_tab.FIRST .. l_ou_tab.LAST
            LOOP
                x_keys := x_keys || ' ' || l_ou_tab(i);
            END LOOP;
        END IF;

        -- Do logging.
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'OKC_REP_UTIL_PVT.get_current_user_moac_keys
                returns x_keys as : '
                || x_keys);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'Leaving  get_current_user_moac_keys');
        END IF;

        EXCEPTION
            WHEN OTHERS
            THEN
                IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                    'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                    'Leaving PROCEDURE get_current_user_moac_keys because of
                    EXCEPTION: '||sqlerrm);
                END IF;
            Okc_Api.Set_Message(p_app_name     => 'OKC',
                p_msg_name     => OKC_REP_UTIL_PVT.G_UNEXPECTED_ERROR,
                p_token1       =>OKC_REP_UTIL_PVT. G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => OKC_REP_UTIL_PVT.G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm);
    END;


    -- API name     : get_intent_profile_keys
    -- Type         : Private.
    -- Function     : Called in the BusDocSearchPlugIn class by the AppSearch
    --                Framework at query-time to get the list of intent codes
    --                that represent the types of contracts (e.g. Buy, Sell)
    --                that the current user may access. This list of
    --                intent codes is then used to check each search hit
    --                and verify that the user is permitted to view that
    --                specific hit. If a user is not permitted to view a given
    --                hit, then that hit is removed from the query result set.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : None.
    --   OUT        : x_keys  OUT VARCHAR2
    --                   A string of single-character intent codes that
    --                   represent the types of contracts (e.g. Buy, Sell) to
    --                   which the current user has access. This string is
    --                   parse into another string containing the single
    --                   characters separated by spaces in the BusDocSearchPlugIn
    --                   class (e.g. "SA" -> "S A").
    --                   Example:  BA
    --                   Example:  BSOA
    -- Note         :
   PROCEDURE get_intent_profile_keys
    ( x_keys OUT NOCOPY VARCHAR2)
    IS
        l_api_name VARCHAR2(30);

   BEGIN

       l_api_name := 'get_intent_profile_keys';

       -- Do logging.
       IF ( FND_LOG.LEVEL_PROCEDURE>= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,
            'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
            '200: Entered OKC_REP_SEARCH_UTIL_PVT.get_intent_profile_keys');
       END IF;

       -- 1. Call FND_PROFILE.value('OKC_REP_INTENTS') to get the intent
       --    codes from the FND profile.
       x_keys := FND_PROFILE.value('OKC_REP_INTENTS');

       x_keys := x_keys;

       -- 2. Create a space-separated string of intent codes from step 1.
       --    Will do this in the Java level.

       -- Do logging.
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'OKC_REP_UTIL_PVT.get_intent_profile_keys
                returns x_keys as : '
                || x_keys);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'Leaving  get_intent_profile_keys');
       END IF;

       EXCEPTION
            WHEN OTHERS
            THEN
                IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION,
                    'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                    'Leaving PROCEDURE get_current_intent_profile_keys
                    because of EXCEPTION: '||sqlerrm);
                END IF;
            Okc_Api.Set_Message(p_app_name     => 'OKC',
                p_msg_name     => OKC_REP_UTIL_PVT.G_UNEXPECTED_ERROR,
                p_token1       => OKC_REP_UTIL_PVT.G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => OKC_REP_UTIL_PVT.G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm);

   END;

    -- API name     : get_current_user_quote_access
    -- Type         : Private.
    -- Function     : Called in the BusDocSearchPlugIn class in the
    --                queryPostProcess() method at query-time to discover the
    --                current user's level of access for a given Sales Quote
    --                document. The possible return values are UPDATE, READ,
    --                and NONE. If a user is not permitted to view a given
    --                quote (meaning that this procedure returns NONE), then
    --                that quote document is removed from the query result set.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : p_quote_number  IN NUMBER
    --                   The ID number of the sales quote document
    --                   currently being processed.
    --   OUT        : x_access  OUT VARCHAR2
    --                   A string that represents the current user's level of
    --                   access for the given Sales Quote document.
    -- Note         :
   PROCEDURE get_current_user_quote_access
     ( p_quote_number IN NUMBER,
       x_access OUT NOCOPY VARCHAR2)
    IS
        l_api_name VARCHAR2(30);
        l_resource_id VARCHAR2(30);

   BEGIN

       l_api_name := 'get_current_user_quote_access';

       -- Do logging.
       IF ( FND_LOG.LEVEL_PROCEDURE>= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,
            'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
            '200: Entered OKC_REP_SEARCH_UTIL_PVT.get_current_user_quote_access');
       END IF;
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
            'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
            'Input parameter is: p_quote_number = ' || p_quote_number||
            '.');
       END IF;

       -- 1. Get the resource_id associated with the current user.
       SELECT resource_id
       INTO l_resource_id
       FROM jtf_rs_resource_extns
       WHERE user_id = FND_GLOBAL.user_id;

       -- 2. If the resource_id is null, return 'NONE'.
       IF (l_resource_id = NULL)
       THEN
            x_access := 'NONE';
       ELSE
            -- Else, use the ASO_SECURITY_INT API get_quote_access to
            -- retrieve the access level. Possible values are
            -- UPDATE, READ, and NONE. If null is returned, then
            -- set x_access to NONE.
            x_access := aso_security_int.get_quote_access(
                l_resource_id, p_quote_number);
            IF (x_access = NULL)
            THEN
                x_access := 'NONE';
            END IF;
       END IF;

       -- Do logging.
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'OKC_REP_UTIL_PVT.get_current_user_quote_access
                returns x_access as : '
                || x_access);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'Leaving  get_current_user_quote_access');
       END IF;

       EXCEPTION
            WHEN OTHERS
            THEN
                IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                    'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                    'Leaving PROCEDURE get_current_user_quote_access
                    because of EXCEPTION: '||sqlerrm);
                END IF;
            Okc_Api.Set_Message(p_app_name     => 'OKC',
                p_msg_name     => OKC_REP_UTIL_PVT.G_UNEXPECTED_ERROR,
                p_token1       => OKC_REP_UTIL_PVT.G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => OKC_REP_UTIL_PVT.G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm);

   END;

    -- API name     : get_local_language_attributes
    -- Type         : Private.
    -- Function     : Called in the BusDocSearchPlugIn class in the
    --                queryPostProcess() method at query-time to fetch
    --                three language-dependent attributes: document type,
    --                intent, and status. The local language values of
    --                these three attributes are returned in a comma-
    --                delimited string in the order docType, intent, status.
    -- Parameters   :
    --   IN         : p_doc_type_code IN NUMBER
    --                   The document type code of the contract document
    --                   currently being processed by queryPostProcess().
    --   IN         : p_intent_code IN NUMBER
    --                   The intent code of the contract document currently
    --                   being processed by queryPostProcess().
    --   IN         : p_status_code IN NUMBER
    --                   The status code of the contract document currently
    --                   being processed by queryPostProcess().
    --   OUT        : x_attrs  OUT VARCHAR2
    --                   A string containing three sub-strings separated by
    --                   commas. These three sub-strings represent the
    --                   local-language value of document type, intent,
    --                   and status.
    -- Note         :
   PROCEDURE get_local_language_attributes
     ( p_doc_type_code IN VARCHAR,
       p_intent_code IN VARCHAR,
       p_status_code IN VARCHAR,
       x_attrs OUT NOCOPY VARCHAR2)
    IS
        l_api_name VARCHAR2(30);
        l_doc_type VARCHAR2(500);
        l_intent VARCHAR2(500);
        l_status VARCHAR2(500);
        l_lookup_type VARCHAR2(50);

   BEGIN

       l_api_name := 'get_local_language_attributes';

       -- Do logging.
       IF ( FND_LOG.LEVEL_PROCEDURE>= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,
            'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
            '200: Entered OKC_REP_SEARCH_UTIL_PVT.get_local_language_attributes');
       END IF;
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
            'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
            'Input parameters are: p_doc_type_code = ' || p_doc_type_code ||
            ', p_intent_code = ' || p_intent_code ||
            ', p_status_code = ' || p_status_code ||
            '.');
       END IF;

       -- 1. Get the document type. If the type is null (meaning that
       -- there is no entry in okc_bus_doc_types_vl for that doc type code),
       -- set the document type to be the document type code. We nest the
       -- query in its own block in order to catch No Data Found
       -- exceptions.
      SELECT name
      INTO l_doc_type
      FROM okc_bus_doc_types_vl
      WHERE document_type = p_doc_type_code;


       -- Append the document type to the attribute list.
       x_attrs := l_doc_type || ',';

       -- 2. Get the document intent. If the intent is null (meaning that
       -- there is no entry in fnd_lookups for that intent code and lookup
       -- type), set the intent to be the intent code. We nest the
       -- query in its own block in order to catch No Data Found
       -- exceptions.
       SELECT meaning
       INTO l_intent
       FROM fnd_lookups
       WHERE lookup_type = 'OKC_REP_CONTRACT_INTENTS'
           AND  lookup_code = p_intent_code;


       -- Append the intent to the attribute list.
       x_attrs := x_attrs || l_intent || ',';

       -- 3. Get the document status and append it to x_attrs.
       --
       -- If the document type code is QUOTE, the status needs to be fetched
       -- with this SQL statement.
       IF (p_doc_type_code = 'QUOTE')
       THEN
            SELECT aqsvl.meaning
            INTO l_status
            FROM aso_quote_statuses_b aqsb,
                 aso_quote_statuses_vl aqsvl
            WHERE aqsb.status_code = p_status_code
                AND  aqsb.quote_status_id = aqsvl.quote_status_id;

       -- If the document type code is RFQ or RFI or AUCTION,
       -- the status needs to be fetched with
       -- this SQL statement.
       ELSE
            IF ((p_doc_type_code = 'RFQ') OR
                (p_doc_type_code = 'RFI') OR
                (p_doc_type_code = 'AUCTION'))
            THEN

       -- AUCTION_CLOSED status is a derived status
       --  which is dependent on the user logged in. So
       -- displaying a message.

 		IF(  p_status_code = 'AUCTION_CLOSED')
             	 THEN
                	SELECT MESSAGE_TEXT
                	INTO l_status
                	FROM  FND_NEW_MESSAGES
               	 	WHERE language_code = USERENV('LANG')
                   	 AND application_id = 510
                   	 AND message_name = 'OKC_SES_AUC_STATUS_EXP';

	              ELSE

                	SELECT meaning
                	INTO l_status
                	FROM fnd_lookup_values
                	WHERE  language = USERENV('LANG')
                  	  AND    lookup_type = 'PON_AUCTION_STATUS'
                   	  AND    lookup_code = p_status_code;
		END IF;

            -- Else, we need to set the lookup type and fetch the status with
            -- this SQL statement.
            ELSE
                -- If the document type code is O or B, then the lookup type
                -- is FLOW_STATUS
                IF ((p_doc_type_code = 'B') OR
                    (p_doc_type_code = 'O'))
                THEN
                    l_lookup_type := 'FLOW_STATUS';

                    -- Get the status using the lookup type.
                    SELECT meaning
                    INTO l_status
                    FROM oe_lookups
                    WHERE lookup_type = l_lookup_type
                        AND lookup_code = p_status_code;
                ELSE
                    -- If the document type code is PA_BLANKET or PA_CONTRACT
                    -- or PO_STANDARD, then the lookup type is
                    -- AUTHORIZATION_STATUS
                    IF ((p_doc_type_code = 'PA_BLANKET') OR
                        (p_doc_type_code = 'PA_CONTRACT') OR
                        (p_doc_type_code = 'PO_STANDARD'))
                    THEN
                        l_lookup_type := 'AUTHORIZATION STATUS';
                    -- Else, the document type code is REP_% and the lookup
                    -- type is OKC_REP_CONTRACT_STATUSES.
                    ELSE
                        l_lookup_type := 'OKC_REP_CONTRACT_STATUSES';
                    END IF;

                    -- Get the status using the lookup type.
                    SELECT meaning
                    INTO l_status
                    FROM fnd_lookup_values
                    WHERE lookup_type = l_lookup_type
                        AND language = USERENV('LANG')
                        AND lookup_code = p_status_code;
                END IF;
            END IF;
       END IF;

       -- Append the status to the attribute list.
       x_attrs := x_attrs || l_status;

       -- Do logging.
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'OKC_REP_UTIL_PVT.get_local_language_attributes
                returns x_attrs as : '
                || x_attrs);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'Leaving  get_local_language_attributes');
       END IF;

       EXCEPTION
            WHEN OTHERS
            THEN
                IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED,
                    'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                    'Leaving PROCEDURE get_local_language_attributes
                    because of EXCEPTION: '||sqlerrm);
                END IF;
            Okc_Api.Set_Message(p_app_name     => 'OKC',
                p_msg_name     => OKC_REP_UTIL_PVT.G_UNEXPECTED_ERROR,
                p_token1       => OKC_REP_UTIL_PVT.G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => OKC_REP_UTIL_PVT.G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm);
   END;


    -- API name     : get_rep_parties
    -- Type         : Private.
    -- Function     : This function fetches the party names for a given
    --                repository contract. It is called in the SQL statements
    --                of RepHeaderSearchExpVO and RepArchiveSearchExpVO in the
    --                oracle.apps.okc.repository.search.server package.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : p_contract_id IN NUMBER
    --                   The contract ID of the contract document currently
    --                   being crawled.
    --   OUT        : x_parties OUT VARCHAR2
    --                   A string of party names that define
    --                   the parties of this repository contract. The party
    --                   names are separated by spaces.
    --                   Example:  Vision, Inc. AT&T Informologics
    -- Note         :
   FUNCTION get_rep_parties
     ( p_contract_id IN NUMBER)
       RETURN VARCHAR2
    IS
        l_api_name VARCHAR2(30);
        l_party_name VARCHAR2(500);
        l_parties VARCHAR2(2000);

         -- Get the party role code associated with the given contract.
        CURSOR party_csr IS
            SELECT party_id, party_role_code
            FROM   okc_rep_contract_parties
            WHERE  contract_id = p_contract_id;

        party_rec    party_csr%ROWTYPE;

    BEGIN

       l_api_name := 'get_rep_parties';

       -- Do logging.
       IF ( FND_LOG.LEVEL_PROCEDURE>= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,
            'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
            '200: Entered OKC_REP_SEARCH_UTIL_PVT.get_rep_parties');
       END IF;
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
            'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
            'Input parameter is: p_contract_id = ' || p_contract_id||
            '.');
       END IF;

       -- 1. Get party_role_code from okc_rep_contract_parties
       --    for the given contract_id.
       -- 2. For each record from step 1:
       FOR party_rec IN party_csr
       LOOP
            -- a. If the party_role_code==INTERNAL_ORG, get the party name
            --    from hr_all_organizational_units using
            --    party_id=organization_id join
            IF (party_rec.party_role_code = 'INTERNAL_ORG')
            THEN
                SELECT name
                INTO l_party_name
                FROM hr_all_organization_units
                WHERE organization_id = party_rec.party_id;

            -- b. Else If the party_role_code==SUPPLIER_ORG
            -- get the party name from  po_vendors using party_id join.
            ELSIF (party_rec.party_role_code = 'SUPPLIER_ORG')
            THEN
                SELECT vendor_name
                INTO l_party_name
                FROM po_vendors
                WHERE vendor_id = party_rec.party_id;
            -- c. Else get the party name from  hz_parties using party_id join.
            ELSE
                SELECT party_name
                INTO l_party_name
                FROM hz_parties
                WHERE party_id = party_rec.party_id;
            END IF;

            --c.	Append party name from step a or b to x_parties.
            l_parties := l_parties || l_party_name || ' ';

       END LOOP;

       -- Do logging.
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'OKC_REP_UTIL_PVT.get_rep_parties returns l_parties as : '
                || l_parties);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'Leaving  get_rep_parties');
       END IF;

       RETURN l_parties;

       EXCEPTION
            WHEN OTHERS
            THEN
                IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                    'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                    'Leaving PROCEDURE get_rep_parties
                    because of EXCEPTION: '||sqlerrm);
                END IF;
            Okc_Api.Set_Message(p_app_name     => 'OKC',
                p_msg_name     => OKC_REP_UTIL_PVT.G_UNEXPECTED_ERROR,
                p_token1       => OKC_REP_UTIL_PVT.G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => OKC_REP_UTIL_PVT.G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm);
   END;


    -- API name      : get_terms_last_update_date.
    -- Type          : Private.
    -- Function      : This function returns the last_update_date value of the the business
    --                document's contract terms.
    -- Pre-reqs      : None.
    -- Parameters    :
    -- IN            : p_document_type       IN VARCHAR2       Required
    --                   Type of the document that is being checked
    --               : p_document_id       IN VARCHAR2       Required
    --                   Id of the document that is being checked
    -- OUT           : Returns the last_update_date value of the the business
    --                 document's contract terms.
   FUNCTION get_terms_last_update_date(
      p_document_type IN  VARCHAR2,
      p_document_id   IN  NUMBER
    ) RETURN DATE
    IS
        l_api_name                     VARCHAR2(30);
        l_has_access                   VARCHAR2(1);
        l_return_status                VARCHAR2(1);
        l_msg_count                    NUMBER;
        l_msg_data                     VARCHAR2(2000);
        l_deliverable_changed_date     DATE;
        l_terms_changed_date           DATE;

      BEGIN

        l_api_name                     := 'get_terms_last_update_date';
        l_has_access                   := 'N';

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Entered Function OKC_REP_SEARCH_UTIL_PVT.get_terms_last_update_date');
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Document Id is: ' || p_document_id);
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Document Type is: ' || p_document_type);
        END IF;
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Calling OKC_TERMS_UTIL_GRP.Get_Last_Update_Date');
        END IF;
        --- Call OKC_TERMS_UTIL_GRP.Get_Last_Update_Date procedure.

        OKC_TERMS_UTIL_GRP.Get_Last_Update_Date(
            p_api_version              => 1.0,
            p_init_msg_list            => FND_API.G_FALSE,
            x_msg_data                 => l_msg_data,
            x_msg_count                => l_msg_count,
            x_return_status            => l_return_status,
            p_doc_type                 => p_document_type,
            p_doc_id                   => p_document_id,
            x_deliverable_changed_date => l_deliverable_changed_date,
            x_terms_changed_date       => l_terms_changed_date
        );
        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'OKC_TERMS_UTIL_GRP.Get_Last_Update_Date return status is: '
              || l_return_status);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'OKC_REP_UTIL_PVT.Get_Last_Update_Date returns x_terms_changed_date as : '
              || l_terms_changed_date);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Leaving Function get_terms_last_update_date');
        END IF;
        RETURN l_terms_changed_date ;

      EXCEPTION
        WHEN OTHERS THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                    'Leaving Function get_terms_last_update_date because of EXCEPTION: '||sqlerrm);
          END IF;
          Okc_Api.Set_Message(p_app_name     => 'OKC',
                p_msg_name     => OKC_REP_UTIL_PVT.G_UNEXPECTED_ERROR,
                p_token1       => OKC_REP_UTIL_PVT.G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => OKC_REP_UTIL_PVT.G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm);
          RETURN l_has_access ;
  END get_terms_last_update_date;









    -- API name      : draft_attachment_exists.
    -- Type          : Private.
    -- Function      : This function returns Y if the generated draft attachment exists for
    --                the business document passed as input. It will also check that
    --                attachment's last_update_date is later than the business document's
    --                Term's last_update_date.
    -- Pre-reqs      : None.
    -- Parameters    :
    -- IN            : p_document_type       IN VARCHAR2       Required
    --                   Type of the document that is being checked
    --               : p_document_id       IN VARCHAR2       Required
    --                   Id of the document that is being checked
    -- OUT           : Return Y if the latest generated draft attachment exists for the
    --                business document, else returns N
   FUNCTION draft_attachment_exists(
      p_document_type IN  VARCHAR2,
      p_document_id   IN  NUMBER
    ) RETURN VARCHAR2

       IS
           l_api_name                     VARCHAR2(30);
           l_has_access                   VARCHAR2(1);
           l_return_status                VARCHAR2(1);
           l_msg_count                    NUMBER;
           l_msg_data                     VARCHAR2(2000);
           l_terms_changed_date           DATE;
           l_attachment_last_update_date  DATE;
           l_attachment_exists            VARCHAR2(1);
           l_results                      VARCHAR2(1);

            CURSOR draft_attachment_csr IS
	        SELECT last_update_date
	        FROM   okc_contract_docs_details_vl
                WHERE  business_document_type = p_document_type
                AND  business_document_id = p_document_id
                AND  file_name like 'Text_Search_Gen_Attach%';

         BEGIN

           l_api_name                     := 'draft_attachment_exists';
           l_results                      := 'N';
           l_attachment_exists            := 'N';

           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                       'Entered Function OKC_REP_SEARCH_UTIL_PVT.draft_attachment_exists');
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                       'Document Id is: ' || p_document_id);
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                       'Document Type is: ' || p_document_type);
           END IF;
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                       'Calling OKC_REP_SEARCH_UTIL_PVT.get_terms_last_update_date');
           END IF;
           --- Call OKC_REP_SEARCH_UTIL_PVT.Get_Last_Update_Date procedure.

           l_terms_changed_date := OKC_REP_SEARCH_UTIL_PVT.get_terms_last_update_date(
               p_document_type          => p_document_type,
               p_document_id            => p_document_id
           );

           OPEN  draft_attachment_csr;
           FETCH draft_attachment_csr INTO l_attachment_last_update_date;

           IF (draft_attachment_csr%rowcount > 0) THEN
	          l_attachment_exists := 'Y';
	       END IF;

           CLOSE draft_attachment_csr;

           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
	                 'l_terms_changed_date: ' || l_terms_changed_date);
	           FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
	                 'l_attachment_last_update_date: ' || l_attachment_last_update_date);
	           FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
	                 'l_attachment_exists: ' || l_attachment_exists);
           END IF;

           IF ((l_attachment_exists = 'N') OR (l_attachment_last_update_date < l_terms_changed_date))THEN
              l_results := 'N';
           ELSE
              l_results := 'Y';
           END IF;

           RETURN l_results;

           EXCEPTION
             WHEN OTHERS THEN
               IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                       'Leaving Function draft_attachment_exists because of EXCEPTION: '||sqlerrm);
               END IF;
               IF (draft_attachment_csr%ISOPEN) THEN
	               CLOSE draft_attachment_csr ;
               END IF;
               Okc_Api.Set_Message(p_app_name     => 'OKC',
                p_msg_name     => OKC_REP_UTIL_PVT.G_UNEXPECTED_ERROR,
                p_token1       => OKC_REP_UTIL_PVT.G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => OKC_REP_UTIL_PVT.G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm);
               RETURN l_results ;
  END draft_attachment_exists;



   -- API name      : is_contract_status_draft.
   -- Type          : Private.
   -- Function      : This function returns Y if the business document status is
   --                 draft.
   -- Pre-reqs      : None.
   -- Parameters    :
   -- IN            : p_document_type       IN VARCHAR2       Required
   --                   Type of the document that is being checked
   --               : p_document_id       IN VARCHAR2       Required
   --                   Id of the document that is being checked
   -- OUT           : Returns Y if the business document status is
   --                draft, else returns N
   FUNCTION is_contract_status_draft(
          p_document_type IN  VARCHAR2,
          p_document_id   IN  NUMBER
   ) RETURN VARCHAR2

        IS
            l_api_name                     VARCHAR2(30);
            l_has_access                   VARCHAR2(1);
            l_return_status                VARCHAR2(1);
            l_msg_count                    NUMBER;
            l_msg_data                     VARCHAR2(2000);
            l_contract_status_code         VARCHAR2(30);
            l_results                      VARCHAR2(1);

            CURSOR rep_status_csr IS
 	        SELECT contract_status_code
 	        FROM   okc_rep_contracts_all
            WHERE  contract_id = p_document_id;

            CURSOR po_status_csr IS
 	        SELECT NVL(authorization_status, 'INCOMPLETE') AS contract_status_code
 	        FROM   po_headers_all
            WHERE po_header_id = p_document_id;

            CURSOR neg_status_csr IS
 	        SELECT auction_status AS contract_status_code
 	        FROM   pon_auction_headers_all
            WHERE  auction_header_id = p_document_id;

            CURSOR quote_status_csr IS
 	        SELECT sb.status_code AS contract_status_code
		    FROM
		           aso_quote_headers_all h
                   ,aso_quote_statuses_b sb
            WHERE  h.quote_header_id = p_document_id
                   AND   h.quote_status_id = sb.quote_status_id;

            CURSOR so_status_csr IS
 	        SELECT flow_status_code AS contract_status_code
 	        FROM   oe_order_headers_all
            WHERE  header_id = p_document_id;

            CURSOR bsa_status_csr IS
 	        SELECT flow_status_code AS contract_status_code
 	        FROM   oe_blanket_headers_all
            WHERE  header_id = p_document_id;

          BEGIN

            l_api_name                     := 'is_contract_status_draft';
            l_has_access                   := 'N';
            l_results                      := 'N';

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                        'Entered Function OKC_REP_SEARCH_UTIL_PVT.is_contract_status_draft');
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                        'Document Id is: ' || p_document_id);
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                        'Document Type is: ' || p_document_type);
          END IF;
          IF (SubStr(p_document_type,1,3) = 'REP') THEN
            OPEN  rep_status_csr;
            FETCH rep_status_csr INTO l_contract_status_code;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
	     	   'Repository doc type, l_contract_status_code: ' || l_contract_status_code);
            END IF;
            IF ( (l_contract_status_code = 'DRAFT') OR
                 (l_contract_status_code = 'REJECTED') OR
                 (l_contract_status_code = 'PENDING_APPROVAL')) THEN
               l_results := 'Y';
            ELSE
               l_results := 'N';
            END IF;
            CLOSE rep_status_csr;

          ELSIF ((p_document_type='PA_BLANKET') OR (p_document_type='PA_CONTRACT')
                    OR (p_document_type='PO_STANDARD')) THEN
            OPEN  po_status_csr;
            FETCH po_status_csr INTO l_contract_status_code;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
	     	   'PO doc type, l_contract_status_code: ' || l_contract_status_code);
            END IF;
            IF ( (l_contract_status_code = 'IN PROCESS') OR
                 (l_contract_status_code = 'INCOMPLETE') OR
                 (l_contract_status_code = 'PRE-APPROVED') OR
                 (l_contract_status_code = 'REJECTED') OR
                 (l_contract_status_code = 'REQUIRES REAPPROVAL')) THEN
               l_results := 'Y';
            ELSE
               l_results := 'N';
            END IF;
            CLOSE po_status_csr;

          ELSIF ((p_document_type='RFI') OR (p_document_type='RFQ')
                    OR (p_document_type='AUCTION')) THEN
            OPEN  neg_status_csr;
            FETCH neg_status_csr INTO l_contract_status_code;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
	     	   'Negotiation doc type, l_contract_status_code: ' || l_contract_status_code);
            END IF;
            IF ( (l_contract_status_code = 'ACTIVE') OR
                 (l_contract_status_code = 'AWARD_APPROVAL_INPROCESS') OR
                 (l_contract_status_code = 'AWARD_REJECTED') OR
                 (l_contract_status_code = 'AWARD_IN_PROG') OR
                 (l_contract_status_code = 'CLOSED') OR
		         (l_contract_status_code = 'DRAFT') OR
                 (l_contract_status_code = 'OPEN_FOR_BIDDING') OR
                 (l_contract_status_code = 'PAUSED') OR
		         (l_contract_status_code = 'PREVIEW') OR
                 (l_contract_status_code = 'SUBMITTED')) THEN
               l_results := 'Y';
            ELSE
               l_results := 'N';
            END IF;
            CLOSE neg_status_csr;
          ELSIF (p_document_type='QUOTE') THEN
            OPEN  quote_status_csr;
            FETCH quote_status_csr INTO l_contract_status_code;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
	     	   'Sales Quote doc type, l_contract_status_code: ' || l_contract_status_code);
            END IF;
            IF ( (l_contract_status_code = 'APPROVAL CANCELED') OR
                 (l_contract_status_code = 'APPROVAL PENDING') OR
                 (l_contract_status_code = 'APPROVAL REJECTED') OR
                 (l_contract_status_code = 'DRAFT') OR
                 (l_contract_status_code = 'ENTERED') OR
		         (l_contract_status_code = 'INACTIVE') OR
                 (l_contract_status_code = 'QUOTE GENERATED BY UW') OR
                 (l_contract_status_code = 'REVIEWED') OR
                 (l_contract_status_code = 'SUBMIT TO UNDERWRITING')) THEN
               l_results := 'Y';
            ELSE
               l_results := 'N';
            END IF;
            CLOSE quote_status_csr;
           ELSIF (p_document_type='B') THEN
             OPEN  bsa_status_csr;
             FETCH bsa_status_csr INTO l_contract_status_code;
             IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
	     	   'Sales Agreement doc type, l_contract_status_code: ' || l_contract_status_code);
             END IF;

             IF ( (l_contract_status_code= 'DRAFT') OR
                  (l_contract_status_code= 'DRAFT_CUSTOMER_REJECTED') OR
                  (l_contract_status_code= 'DRAFT_INTERNAL_REJECTED') OR
                  (l_contract_status_code= 'DRAFT_SUBMITTED') OR
                  (l_contract_status_code= 'ENTERED') OR
 		          (l_contract_status_code = 'INTERNAL_REJECTED') OR
                  (l_contract_status_code = 'PENDING_INTERNAL_APPROVAL')) THEN
                l_results := 'Y';
             ELSE
                l_results := 'N';
             END IF;
             CLOSE bsa_status_csr;
          ELSIF (p_document_type='O') THEN
            OPEN  so_status_csr;
            FETCH so_status_csr INTO l_contract_status_code;
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     	   FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
	     	   'Sale Order doc type, l_contract_status_code: ' || l_contract_status_code);
            END IF;
            IF ( (l_contract_status_code = 'DRAFT') OR
                  (l_contract_status_code = 'DRAFT_CUSTOMER_REJECTED') OR
                  (l_contract_status_code = 'DRAFT_INTERNAL_REJECTED') OR
                  (l_contract_status_code = 'DRAFT_SUBMITTED') OR
                  (l_contract_status_code = 'ENTERED') OR
                  (l_contract_status_code = 'PENDING_INTERNAL_APPROVAL')) THEN
               l_results := 'Y';
            ELSE
               l_results := 'N';
            END IF;
            CLOSE so_status_csr;
          END IF;   -- p_document_type like '%tmp_txt_search_draft'


          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	           FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
 	                 'l_results: ' || l_results);
 	           FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
 	                 'Exiting is_contract_status_draft');
          END IF;

          RETURN l_results;

          EXCEPTION
            WHEN OTHERS THEN
              IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,G_MODULE||l_api_name,
                        'Leaving Function is_contract_status_draft because of EXCEPTION: '||sqlerrm);
              END IF;
              IF (rep_status_csr%ISOPEN) THEN
 	               CLOSE rep_status_csr ;
              END IF;
              IF (po_status_csr%ISOPEN) THEN
	       	       CLOSE po_status_csr ;
              END IF;
              IF (neg_status_csr%ISOPEN) THEN
	       	       CLOSE neg_status_csr ;
              END IF;
              IF (quote_status_csr%ISOPEN) THEN
	       	       CLOSE quote_status_csr ;
              END IF;
              IF (so_status_csr%ISOPEN) THEN
	       	       CLOSE so_status_csr ;
              END IF;
              IF (bsa_status_csr%ISOPEN) THEN
	       	       CLOSE bsa_status_csr ;
              END IF;
              Okc_Api.Set_Message(p_app_name     => 'OKC',
                p_msg_name     => OKC_REP_UTIL_PVT.G_UNEXPECTED_ERROR,
                p_token1       => OKC_REP_UTIL_PVT.G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => OKC_REP_UTIL_PVT.G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm);
              RETURN l_results ;
  END is_contract_status_draft;

    -- API name     : get_neg_parties
    -- Type         : Private.
    -- Function     : This function fetches the party names for a given
    --                negotiation contract. It is called in the SQL statements
    --                of NegSearchExpVO.xml in the
    --                oracle.apps.okc.repository.search.server package.
    -- Pre-reqs     : None.
    -- Parameters   :
    --   IN         : p_auction_header_id IN NUMBER
    --                   The auction header ID of the contract document currently
    --                   being crawled.
    --   OUT        : x_parties OUT VARCHAR2
    --                   A string of party names that define
    --                   the parties of this negotiation contract. The party
    --                   names are separated by spaces.
    --                   Example:  Vision, Inc. AT&T Informologics
    -- Note         :
   FUNCTION get_neg_parties(
        p_auction_header_id IN NUMBER
     ) RETURN VARCHAR2
   IS
     l_api_name VARCHAR2(30);
     l_party_name VARCHAR2(500);
     l_parties VARCHAR2(2000);

   -- Get the parties associated with this contract
    CURSOR party_csr IS
    SELECT v.vendor_name
    FROM pon_bid_headers b
    ,po_vendors v
    WHERE b.auction_header_id = p_auction_header_id
    AND   b.bid_status IN ('ACTIVE','DISQUALIFIED')
    AND   b.vendor_id = v.vendor_id;

    party_rec    party_csr%ROWTYPE;

   BEGIN

     l_api_name := 'get_neg_parties';

          -- Do logging.
       IF ( FND_LOG.LEVEL_PROCEDURE>= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,
            'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
            '200: Entered OKC_REP_SEARCH_UTIL_PVT.get_neg_parties');
       END IF;
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
            'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
            'Input parameter is: p_auction_header_id = ' || p_auction_header_id||
            '.');
       END IF;
      FOR party_rec IN party_csr
      LOOP
      l_parties := l_parties || party_rec.vendor_name || ' ';
      END LOOP;

             -- Do logging.
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'OKC_REP_UTIL_PVT.get_neg_parties returns l_parties as : '
                || l_parties);
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,
                'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                'Leaving  get_neg_parties');
       END IF;

       RETURN l_parties;

       EXCEPTION
            WHEN OTHERS
            THEN
                IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION ,
                    'okc.plsql.OKC_REP_SEARCH_UTIL_PVT.'||l_api_name,
                    'Leaving PROCEDURE get_neg_parties
                    because of EXCEPTION: '||sqlerrm);
                END IF;
            Okc_Api.Set_Message(p_app_name     => 'OKC',
                p_msg_name     => OKC_REP_UTIL_PVT.G_UNEXPECTED_ERROR,
                p_token1       => OKC_REP_UTIL_PVT.G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => OKC_REP_UTIL_PVT.G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm);
   END get_neg_parties;


END OKC_REP_SEARCH_UTIL_PVT;

/
