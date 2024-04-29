--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_ASSOCIATIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_ASSOCIATIONS_UTIL" AS
/* $Header: EGOVIAUB.pls 120.3.12010000.3 2011/01/21 13:26:27 maychen ship $ */

  G_SEARCH_CURSOR  NUMBER := dbms_sql.open_cursor;
  G_SEARCH_STMT    LONG;
  G_PKG_NAME       VARCHAR2(30);
  G_FILE_NAME      VARCHAR2(12);
  G_USER_ID        fnd_user.user_id%TYPE;
  G_PARTY_ID       hz_parties.party_id%TYPE;
  G_LOGIN_ID       fnd_user.last_update_login%TYPE;
  G_SESSION_LANG   VARCHAR2(99);


  /*
  -- Start of comments
  --  API name    : set_globals
  --  Type        : Private.
  --  Function    : Sets the global constant values used in this package.
  --  Pre-reqs    : None.
  --  Version     : Initial version     1.0
  --  Notes       : Sets the global constant values used in this package.
  --                1. G_USER_ID - user id
  --                2. G_SYSDATE - Creation Date and Update Date
  --                3. G_LOGIN_ID - Login which is used to create/update.
  -- End of comments
  */
  PROCEDURE set_globals
  IS
  BEGIN
    -- fnd_global.apps_initialize(1068, 431, 24089);
    --
    -- file names
    --
    G_FILE_NAME    := NVL(G_FILE_NAME,'EGOVIAUB.pls');
    G_PKG_NAME     := NVL(G_PKG_NAME,'EGO_ITEM_ASSOCIATONS_UTIL');
    --
    -- user values
    --
    G_USER_ID      := FND_GLOBAL.user_id;
    G_LOGIN_ID     := FND_GLOBAL.login_id;
    G_SESSION_LANG := USERENV('LANG');
    BEGIN
      SELECT party_id
        INTO G_PARTY_ID
        FROM ego_user_v
       WHERE USER_ID = G_USER_ID;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT party_id, user_id
          INTO G_PARTY_ID, G_USER_ID
          FROM ego_user_v
         WHERE USER_NAME = FND_GLOBAL.USER_NAME;
    END;
  END set_globals;


  /*
  -- Start of comments
  --  API name    : is_supplier_contact
  --  Type        : Private.
  --  Function    : Checks whether the party is a supplier contatc or not.
  --  Pre-reqs    : None.
  --  Version     : Initial version     1.0
  --  Notes       : None.
  -- End of comments
  */
  FUNCTION is_supplier_contact(p_party_id IN NUMBER) RETURN VARCHAR2
  IS
    l_vendor_contact VARCHAR2(1) := 'F';
  BEGIN
    SELECT 'T'
      INTO l_vendor_contact
      FROM dual
     WHERE EXISTS
           (
          SELECT 1
            FROM ap_supplier_contacts ascs
         WHERE ascs.per_party_id = G_PARTY_ID
         );
    RETURN l_vendor_contact;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_vendor_contact := 'F';
    RETURN l_vendor_contact;
  END is_supplier_contact;

  /*
  -- Start of comments
  --  API name    : a_debug
  --  Type        : Private.
  --  Function    : Writes the debug message into debug table.
  --  Pre-reqs    : None.
  --  Version     : Initial version     1.0
  --  Notes       : None.
  -- End of comments
  PROCEDURE a_debug(p_msg VARCHAR2)
  IS PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO ARASAN_TEMP
         VALUES (p_msg);
    COMMIT;
  END A_DEBUG;
  */



  -- Start of comments
  --  API name    : search_supplier_and_site
  --  Type        : Private.
  --  Function    : Searches the supplier and site for the given criteria
  --  Pre-reqs    :
  --                i) Search criteria is built using the constants specified in ego_item_associations_util or EgoSearchAssociationAM.
  --                ii) Search Columns and Criteria has same number of values
  --                iii) If p_search_sites is fnd_api.G_FALSE, then the criteria
  --                   for those columns should not be passed.
  --                   Will result in SQL exception if passed.
  --                iv) Atleast one criteria has been specified to search.
  --                v) Passed organization id should be master organization id.  No validation will be done from search.  Wrong value
  --                    will result in no rows.
  --  Parameters  :
  --  IN          : p_api_version       IN NUMBER Required
  --                p_batch_id    IN OUT NOCOPY NUMBER Required
  --                p_search_cols IN EGO_VARCHAR_TBL_TYPE Required
  --                p_search_criteria IN EGO_VARCHAR_TBL_TYPE Required
  --                p_search_sites IN VARCHAR2 Optional Default fnd_api.G_FALSE
  --                p_filter_rows IN VARCHAR2 Optional Default fnd_api.G_FALSE
  --                p_inventory_item_id IN NUMBER Optional Default NULL
  --                p_master_org_id  IN NUMBER Required
  --                p_search_existing_site_only IN VARCHAR2 Optional Default fnd_api.G_FALSE
  --  Version     : Current version 1.0
  --                Initial version   1.0
  --  Notes       : p_search_cols contains the search criteria columns.  The list of columns are
  --                defined as constants in ego_item_associations_util.
  --                p_search_criteria will be corresponding search criteria for the columns.
  --                Criteria and column names mapped based on index of the tables.
  --                p_search_sites allows to search/return site results.
  --                p_filter_rows specifies whether already associated needs to be filtered or not
  --                p_inventory_item_id is the item id for which the check needs to be done.
  --                Used only in single item flow.  In mass flow, the intersections are cartersians.
  --                p_master_org_id  Master Organization Id in context of which the search needs to be performed
  --                p_search_existing_site_only Searches only existing sites.  Used in item-site-org flow
  --
  -- End of comments
  PROCEDURE search_supplier_and_site
  (
    p_api_version                IN NUMBER
    ,p_batch_id                  IN OUT NOCOPY NUMBER
    ,p_search_cols               IN EGO_VARCHAR_TBL_TYPE
    ,p_search_criteria           IN EGO_VARCHAR_TBL_TYPE
    ,p_search_sites              IN VARCHAR2 := fnd_api.G_FALSE
    ,p_filter_rows               IN VARCHAR2 := fnd_api.G_FALSE
    ,p_inventory_item_id         IN NUMBER := NULL
    ,p_master_org_id             IN NUMBER
    ,p_search_existing_site_only IN VARCHAR2 := fnd_api.G_FALSE
    ,p_filter_suppliers          IN VARCHAR2 := fnd_api.G_FALSE
  )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION; /*Added for bug 8240551*/
    l_insert_clause VARCHAR2(2000);
    l_select_clause VARCHAR2(2000);
    l_from_clause VARCHAR2(500);
    l_where_clause VARCHAR2(2000);
    l_filter_clause VARCHAR2(2000);
    l_suppl_insert_clause VARCHAR2(2000);
    l_suppl_select_clause VARCHAR2(2000);
    l_suppl_from_clause VARCHAR2(2000);
    l_suppl_where_clause VARCHAR2(2000);
    l_rc NUMBER;
    l_existing_suppliers_only VARCHAR2(1) := fnd_api.G_TRUE;
    l_search_col_index NUMBER;
    l_err_msg VARCHAR2 (2000);
    l_api_name  CONSTANT VARCHAR2(30) := 'search_supplier_and_site';
    l_api_version  CONSTANT NUMBER    := 1.0;
    l_dynamic_sql VARCHAR2(32767);
    l_sec_predicate VARCHAR2(32767);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT search_supplier_and_site_pvt;
    set_globals();
    -- Standard call to check for call compatibility.
    IF NOT fnd_api.Compatible_API_Call ( l_api_version
                                         ,p_api_version
                                         ,l_api_name
                                         ,G_PKG_NAME )
     THEN
      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- if batch is not null then delete the existing rows in ego_suppliersite_tmp
    IF p_batch_id IS NULL THEN
      -- dbms_output.put_line(' Deleting rows');
--      EXECUTE IMMEDIATE 'DELETE FROM ego_suppliersite_tmp WHERE batch_id = :b_batch_id' USING p_batch_id;
      -- else create one batch_id here.  This is only for temp tables..so get it from massupdate seq.
--    ELSE
      SELECT ego_massupdate_s.NEXTVAL
        INTO p_batch_id
        FROM dual;
    END IF;
    -- construct the search result query dynamically
    -- dbms_output.put_line(' Called search_supplier_and_sites' );
    l_insert_clause := ' INSERT INTO ego_suppliersite_tmp ( created_by, creation_date, last_updated_by, last_update_date, select_flag, batch_id, supplier_id, supplier_number, supplier_name, duns_number, tax_payer_id, tax_registration_num ';
    l_suppl_insert_clause := ' INSERT INTO ego_suppliersite_tmp ( created_by, creation_date, last_updated_by, last_update_date, select_flag, batch_id, supplier_id, supplier_number, supplier_name, duns_number, tax_payer_id, tax_registration_num ) ';
    l_select_clause := ' SELECT fnd_global.USER_ID, sysdate, fnd_global.USER_ID, sysdate, ''Y'', :batch_id, aas.vendor_id, aas.segment1, aas.vendor_name, hp.duns_number_c, aas.num_1099, aas.vat_registration_num ';
    l_suppl_select_clause := ' SELECT fnd_global.USER_ID, sysdate, fnd_global.USER_ID, sysdate, ''Y'', :batch_id, aas.vendor_id, aas.segment1, aas.vendor_name, hp.duns_number_c, aas.num_1099, aas.vat_registration_num ';
    l_from_clause := ' FROM ap_suppliers aas, hz_parties hp ';
    l_suppl_from_clause := ' FROM ap_suppliers aas, hz_parties hp ';
    l_where_clause := ' WHERE aas.party_id = hp.party_id AND NVL(aas.end_date_active,SYSDATE+1) > SYSDATE ';
    l_suppl_where_clause := ' WHERE aas.party_id = hp.party_id AND NVL(aas.end_date_active,SYSDATE+1) > SYSDATE ';
    -- Add site related query if the search site flag is set
    IF p_search_sites = fnd_api.G_TRUE THEN
      -- dbms_output.put_line(' search sites is TRUE' );
      l_insert_clause := l_insert_clause || ', supplier_site_id, supplier_site_name, city, state, country ';
      l_select_clause := l_select_clause || ', asa.vendor_site_id, asa.vendor_site_code, asa.city, asa.state, asa.country ';
      l_from_clause := l_from_clause || ', ap_supplier_sites_all asa';
    END IF;
    -- Columns needs to be inserted are added.  So close the paranthesis
    l_insert_clause := l_insert_clause || ' ) ';
    -- Add the search criteria blindly.  Since search column values are passed using constants,
    -- which holds the exact column name with alias just add them to query and add bind values for the
    -- criteria.
    IF p_search_cols.FIRST IS NOT NULL THEN
      l_search_col_index := 1;
      -- Add criteria with AND condition.
      WHILE l_search_col_index IS NOT NULL
      LOOP
        IF p_search_criteria(l_search_col_index) IS NOT NULL THEN
          -- If there is supplier search criteria then search the sites for existing suppliers.
          IF ( p_search_cols(l_search_col_index) = G_SUPPLIER_NAME
           OR p_search_cols(l_search_col_index) = G_SUPPLIER_NUMBER
           OR p_search_cols(l_search_col_index) = G_DUNS_NUMBER
           OR p_search_cols(l_search_col_index) = G_TAX_PAYER_ID
           OR p_search_cols(l_search_col_index) = G_TAX_REGISTRATION_NUMBER )
           THEN
            IF p_search_sites = fnd_api.G_TRUE AND l_existing_suppliers_only = fnd_api.G_TRUE
             THEN
              l_existing_suppliers_only := fnd_api.G_FALSE;
            END IF;
            l_suppl_where_clause := l_suppl_where_clause || ' AND ' || p_search_cols(l_search_col_index) || ' LIKE ' || ' :bv'||l_search_col_index;
          END IF;
          l_where_clause := l_where_clause || ' AND ' || p_search_cols(l_search_col_index) || ' LIKE ' || ' :bv'||l_search_col_index;
        END IF;
      l_search_col_index := p_search_cols.NEXT(l_search_col_index);
      END LOOP;
    END IF;
    IF l_existing_suppliers_only = fnd_api.G_TRUE AND p_search_sites = fnd_api.G_TRUE AND p_inventory_item_id IS NOT NULL THEN
      l_where_clause := l_where_clause ||
                   ' AND EXISTS ( SELECT 1 FROM ego_item_associations eia1 ' ||
                   ' WHERE eia1.inventory_item_id = :b_item_id AND eia1.data_level_id = 43103 ' ||
                   ' AND eia1.pk1_value = aas.vendor_id AND eia1.organization_id = :b_master_org_id ) ';
    END IF;
    IF p_search_existing_site_only = fnd_api.G_TRUE AND p_inventory_item_id IS NOT NULL THEN
      l_where_clause := l_where_clause ||
                        ' AND EXISTS ( SELECT 1 FROM ego_item_associations eia2 ' ||
                        ' WHERE eia2.data_level_id = 43104  AND eia2.pk2_value = asa.vendor_site_id ' ||
                        ' AND eia2.inventory_item_id = :b_item_id AND eia2.organization_id = :b_master_org_id )';
    END IF;
    -- If we are searching for supplier sites then add the join condition to where clause
    IF p_search_sites = fnd_api.G_TRUE THEN
      l_where_clause := l_where_clause || ' AND asa.vendor_id = aas.vendor_id AND asa.org_id = fnd_profile.value(''ORG_ID'') and nvl(asa.inactive_date,SYSDATE + 1)>SYSDATE ';   --bug 11072046 NVL(aas.end_date_active,SYSDATE+1) > SYSDATE
    END IF;
    -- If filter rows is set to yes, then check whether any intersections already exists for this supplier site
    IF p_search_sites = fnd_api.G_TRUE AND p_filter_rows = fnd_api.G_TRUE AND p_inventory_item_id IS NOT NULL THEN
      l_where_clause := l_where_clause ||
                  ' AND NOT EXISTS ( SELECT 1 FROM ego_item_associations eia4 ' ||
                  ' WHERE eia4.inventory_item_id = :b_item_id AND eia4.data_level_id = 43104 ' ||
                  ' AND eia4.pk2_value = asa.vendor_site_id AND eia4.organization_id = :b_master_org_id )';
    END IF;
    -- l_where_clause := l_where_clause || ' AND EXISTS ( SELECT 1 FROM ap_supplier_sites_all assa WHERE assa.vendor_id = aas.vendor_id ) ';
    -- Filter for item-site-org intersection
    -- This cannot be done, because the mass update org table is not populated.
    -- IF p_search_existing_site_only = fnd_api.G_TRUE AND p_inventory_item_id IS NOT NULL THEN
    --   l_where_clause := l_where_clause || ' AND NOT EXISTS ( SELECT 1 FROM ego_item_associations eia5, ' ||
    --      ' ego_massupdate_org_tmp emot WHERE eia5.inventory_item_id = :b_item_id AND eia5.data_level_id = 43105  AND eia5.pk2_value = asa.vendor_site_id ' ||
    --      'AND eia5.organization_id = emot.organization_id_child AND emot.batch_id = :b_batch_id )';
    -- END IF;
    -- a_debug(' l_insert_clause ' || l_insert_clause );
    -- a_debug(' l_select_clause ' || l_select_clause );
    -- a_debug(' l_from_clause ' || l_from_clause );
    -- a_debug(' l_where_clause ' || l_where_clause );
    -- a_debug(' l_filter_clause ' || l_filter_clause );

    -- Construct the stmt by concatenating insert..select..from..where
    g_search_stmt := l_insert_clause || l_select_clause || l_from_clause || l_where_clause;
    IF is_supplier_contact(G_PARTY_ID) = FND_API.G_TRUE THEN
      g_search_stmt := g_search_stmt || ' AND EXISTS ' ||
                                  ' ( ' ||
                                '    SELECT 1 ' ||
                                '      FROM ego_vendor_v evv ' ||
                                '     WHERE evv.vendor_id = aas.vendor_id ' ||
                              '       AND evv.user_id = :b_user_id '||
                                  ' )';

    END IF;
    dbms_sql.parse( g_search_cursor, g_search_stmt, dbms_sql.native );
    -- Bind the batch id which is the first parameter
    dbms_sql.bind_variable( g_search_cursor, ':batch_id' , p_batch_id );
    -- Bind the search criteria values
    IF p_search_criteria.FIRST IS NOT NULL THEN
      l_search_col_index := p_search_criteria.FIRST;
      WHILE l_search_col_index IS NOT NULL
      LOOP
        IF p_search_criteria(l_search_col_index) IS NOT NULL THEN
          --dbms_output.put_line(' Binding ' || ':bv' || l_search_col_index || ' value ' || p_search_criteria(l_search_col_index));
          dbms_sql.bind_variable( g_search_cursor, ':bv' || l_search_col_index, p_search_criteria(l_search_col_index) );
        l_search_col_index := p_search_criteria.NEXT(l_search_col_index);
      END IF;
      END LOOP;
    END IF;
    -- If there is no supplier search criteria then bind item id for the criteria
    IF l_existing_suppliers_only = fnd_api.G_TRUE AND p_search_sites = fnd_api.G_TRUE AND p_inventory_item_id IS NOT NULL THEN
      dbms_sql.bind_variable( g_search_cursor, ':b_item_id', p_inventory_item_id);
      dbms_sql.bind_variable( g_search_cursor, ':b_master_org_id', p_master_org_id);
    END IF;
    IF p_search_existing_site_only = fnd_api.G_TRUE AND p_inventory_item_id IS NOT NULL THEN
      dbms_sql.bind_variable( g_search_cursor, ':b_item_id', p_inventory_item_id);
      dbms_sql.bind_variable( g_search_cursor, ':b_master_org_id', p_master_org_id);
    END IF;
    -- Bind the value for filter criteria of supplier site
    IF p_search_sites = fnd_api.G_TRUE AND p_filter_rows = fnd_api.G_TRUE AND p_inventory_item_id IS NOT NULL THEN
      dbms_sql.bind_variable( g_search_cursor, ':b_item_id', p_inventory_item_id);
      dbms_sql.bind_variable( g_search_cursor, ':b_master_org_id', p_master_org_id);
    END IF;
    IF is_supplier_contact(G_PARTY_ID) = FND_API.G_TRUE THEN
      dbms_sql.bind_variable( g_search_cursor, ':b_user_id' , G_USER_ID );
    END IF;


    -- Bind the value for filter condition of item-site-org intersection
    -- This cannot be done, because the mass update org table is not populated.
    --IF p_search_existing_site_only = fnd_api.G_TRUE AND p_inventory_item_id IS NOT NULL THEN
    --  dbms_sql.bind_variable( g_search_cursor, ':b_item_id' , p_inventory_item_id );
    --  dbms_sql.bind_variable( g_search_cursor, ':batch_id' , p_batch_id );
        --END IF;

    -- Execute the query which will insert the rows in ego_suppliersite_tmp
    -- Execute only when search sites is TRUE
    IF p_search_sites = fnd_api.G_TRUE THEN
        l_rc := dbms_sql.execute( g_search_cursor );
    END IF;

    IF p_filter_suppliers = fnd_api.G_FALSE THEN
      l_suppl_where_clause := l_suppl_where_clause || ' AND EXISTS ( SELECT 1 FROM ap_supplier_sites_all assa WHERE assa.vendor_id = aas.vendor_id AND assa.org_id = fnd_profile.value(''ORG_ID'') and nvl(assa.inactive_date,SYSDATE + 1)>SYSDATE ) ';
      IF p_filter_rows = fnd_api.G_TRUE AND p_inventory_item_id IS NOT NULL THEN
        l_suppl_where_clause := l_suppl_where_clause ||
                   ' AND NOT EXISTS ( SELECT 1 FROM ego_item_associations eia3 ' ||
                   ' WHERE eia3.inventory_item_id = :b_item_id AND eia3.data_level_id = 43103 ' ||
                   ' AND eia3.pk1_value = aas.vendor_id AND eia3.organization_id = :b_master_org_id )';
      END IF;
      g_search_stmt := l_suppl_insert_clause || l_suppl_select_clause || l_suppl_from_clause || l_suppl_where_clause;
      -- If filter rows is set to yes, then check whether any intersections already exists for this supplier
      IF is_supplier_contact(G_PARTY_ID) = FND_API.G_TRUE
      THEN
        g_search_stmt := g_search_stmt || ' AND EXISTS ' ||
                                  ' ( ' ||
                                '    SELECT 1 ' ||
                                '      FROM ego_vendor_v evv ' ||
                                '     WHERE evv.vendor_id = aas.vendor_id ' ||
                              '       AND evv.user_id = :b_user_id '||
                                  ' )';

      END IF;
      dbms_sql.parse( g_search_cursor, g_search_stmt, dbms_sql.native );
      -- Bind the value for filter criteria of supplier
      IF p_filter_rows = fnd_api.G_TRUE AND p_inventory_item_id IS NOT NULL THEN
        dbms_sql.bind_variable( g_search_cursor, ':b_item_id', p_inventory_item_id);
        dbms_sql.bind_variable( g_search_cursor, ':b_master_org_id', p_master_org_id);
      END IF;
      -- Bind the batch id which is the first parameter
      dbms_sql.bind_variable( g_search_cursor, ':batch_id' , p_batch_id );
      IF p_search_cols.FIRST IS NOT NULL THEN
        l_search_col_index := 1;
        -- Add criteria with AND condition.
        WHILE l_search_col_index IS NOT NULL
        LOOP
        IF p_search_criteria(l_search_col_index) IS NOT NULL THEN
          -- If there is supplier search criteria then search the sites for existing suppliers.
          IF ( p_search_cols(l_search_col_index) = G_SUPPLIER_NAME
          OR p_search_cols(l_search_col_index) = G_SUPPLIER_NUMBER
          OR p_search_cols(l_search_col_index) = G_DUNS_NUMBER
          OR p_search_cols(l_search_col_index) = G_TAX_PAYER_ID
          OR p_search_cols(l_search_col_index) = G_TAX_REGISTRATION_NUMBER )
           THEN
                dbms_sql.bind_variable( g_search_cursor, ':bv' || l_search_col_index, p_search_criteria(l_search_col_index) );
          END IF;
        END IF;
        l_search_col_index := p_search_cols.NEXT(l_search_col_index);
        END LOOP;
      END IF;
      IF is_supplier_contact(G_PARTY_ID) = FND_API.G_TRUE THEN
        dbms_sql.bind_variable( g_search_cursor, ':b_user_id' , G_USER_ID );
      END IF;
      l_rc := dbms_sql.execute( g_search_cursor );
    END IF;
    COMMIT;  /*Added for bug 8240551*/
    EXCEPTION
     WHEN OTHERS THEN
       -- Sometimes the exception trace might be larger then 2000 characters.
       -- But the complete error message should be less than 2000 characters.
       -- Since the SQLERRM is a token with in the message, add only 1900
       --  characters, which should be enough to identify the root cause
       l_err_msg := 'Unexpected Error Occured: ' || SUBSTR(SQLERRM,1,1900);
       fnd_message.set_name ('EGO', 'EGO_PLSQL_ERROR');
       fnd_message.set_token ('PKG_NAME', G_PKG_NAME);
       fnd_message.set_token ('API_NAME', l_api_name);
       fnd_message.set_token ('SQL_ERR_MSG', l_err_msg);
       --ROLLBACK TO search_supplier_and_site_pvt;
       app_exception.raise_exception;
  END search_supplier_and_site;

END ego_item_associations_util;

/
