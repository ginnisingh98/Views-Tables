--------------------------------------------------------
--  DDL for Package Body AP_SUPPLIER_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_SUPPLIER_INFO_PKG" AS
/* $Header: apsupinfb.pls 120.1.12010000.3 2008/11/18 10:49:48 anarun noship $ */
------------------------------------------------------------------------------
--                    Global Variables                                      --
------------------------------------------------------------------------------
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT       CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP_SUPPLIER_INFO_PKG';
G_LEVEL_PROCEDURE       CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;

-- Procedure Definitions

------------------------------------------------------------------------------
----------------------------- Supplier_Details -------------------------------
------------------------------------------------------------------------------
/* Fetches the details of Supplier, Site and Contact
 * This is an overloaded procedure
 * Parameters : i_vendor_id          - vendor_id of supplier
 *              i_vendor_site_id     - vendor_site_id of supplier site
 *              i_vendor_contact_id  - vendor_contact_id
 *              o_supplier_info      - Supplier details are populated into
 *                                     this parameter
 *              o_success            - If a valid combination of vendor_id,
 *                                     vendor_site_id and vendor_contact_id
 *                                     was not passed then o_success is set
 *                                     to FALSE
 *
 * Logic :
 * 1) Validation check and query string formulation
 *    First check if the vendor_id exists in ap_suppliers.
 *    If vendor_site_id is available then
 *       a) check if it is valid
 *       b) append it to site query string
 *       c) If vendor_contact_id is available then
 *           i) check if this contact is valid for this combination of
 *              ( vendor_id, vendor_site_id )
 *          ii) append it to contact query string. Here we do not need to
 *              consider it for site query string because while opening
 *              contact cursor, if vendor_site_id is available then we will
 *              use it as a condition
 *        End If
 *    Else
 *       a) If vendor_contact_id is available then
 *            i) check if this contact is valid for this combination of
 *               ( vendor_id, vendor_site_id )
 *           ii) Get the list of vendor_site_id for this contact and add
 *               this list as a IN condition of site query string
 *          End If
 *    End If
 * 2) Populate the suplier details
 * 3) Loop through sites and get site details
 * 4) Loop through contacts for each site to get contact details
 *
*/

PROCEDURE Supplier_Details(
                           i_vendor_id          IN    NUMBER ,
                           i_vendor_site_id     IN    NUMBER   DEFAULT NULL,
                           i_vendor_contact_id  IN    NUMBER   DEFAULT NULL,
                           o_supplier_info      OUT NOCOPY t_supplier_info_rec,
                           o_success            OUT NOCOPY BOOLEAN
                          )
IS
    TYPE t_site_refcur    IS REF CURSOR;
    TYPE t_contact_refcur IS REF CURSOR;
    TYPE t_site_tab       IS TABLE OF ap_supplier_sites_all%ROWTYPE
    INDEX BY BINARY_INTEGER;

    c_site          t_site_refcur;
    c_contact       t_contact_refcur;
    l_site_tab      t_site_tab;
    l_contact_tab   t_contacts_tab;
    l_site_sel      VARCHAR2(1000) := 'SELECT * FROM ap_supplier_sites_all ';
    l_site_where    VARCHAR2(1000) := ' WHERE vendor_id = '
                                      || to_char(i_vendor_id);
    l_contact_sel   VARCHAR2(1000) := 'SELECT * FROM po_vendor_contacts ';
    l_contact_where VARCHAR2(1000) := ' WHERE vendor_id = '
                                      || to_char(i_vendor_id);
    l_site_indx     NUMBER;
    l_contact_indx  NUMBER;
    l_check_vid     NUMBER;
    l_check_vsid    NUMBER;
    l_check_vcid    NUMBER;
    l_api_name      CONSTANT VARCHAR2(200) := 'Supplier_Details';
    l_debug_info    VARCHAR2(2000);
BEGIN

    l_debug_info := 'Called with parameters : i_vendor_id = '
                    || to_char(i_vendor_id) || ', i_vendor_site_id = '
                    || to_char(i_vendor_site_id) || ', i_vendor_contact_id = '
                    || to_char(i_vendor_contact_id);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_api_name,
                       l_debug_info);
    END IF;

    /* ========= Validation Check and query string begin ==========
     |  This section of code checks if the given combination of   |
     |  vendor_id, vendor_site_id and vendor_contact_id is valid  |
     |  or not and sets o_success to FALSE if it is invalid.      |
     |  Simultaneously, it forms the query string.                |
     ============================================================ */

    o_success := TRUE;

    SELECT  count(1)
    INTO    l_check_vid
    FROM    ap_suppliers
    WHERE   vendor_id = i_vendor_id;

    IF l_check_vid = 0 THEN
        o_success := FALSE;
        l_debug_info := 'Invalid vendor_id';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_api_name,
                           l_debug_info);
        END IF;
    ELSE
        IF i_vendor_site_id IS NOT NULL THEN
            SELECT  count(1)
            INTO    l_check_vsid
            FROM    ap_supplier_sites_all
            WHERE   vendor_id = i_vendor_id
            AND     vendor_site_id = i_vendor_site_id;

            IF l_check_vsid = 0 THEN
                o_success := FALSE;
                l_debug_info := 'Invalid combination of (vendor_id, '
                                || 'vendor_site_id)';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                                   l_api_name, l_debug_info);
                END IF;
            ELSE
                l_site_where := l_site_where
                                || ' AND vendor_site_id = '
                                || to_char(i_vendor_site_id);
            END IF;

            IF i_vendor_contact_id IS NOT NULL THEN
                SELECT  count(1)
                INTO    l_check_vcid
                FROM    po_vendor_contacts
                WHERE   vendor_id = i_vendor_id
                AND     vendor_site_id = i_vendor_site_id
                AND     vendor_contact_id = i_vendor_contact_id;

                IF l_check_vcid = 0 THEN
                    o_success := FALSE;
                    l_debug_info := 'Invalid combination of (vendor_id, '
                                    || 'vendor_site_id, vendor_contact_id)';
                    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME
                                       || l_api_name, l_debug_info);
                    END IF;
                ELSE
                    l_contact_where     := l_contact_where
                                        || ' AND vendor_contact_id = '
                                        || to_char(i_vendor_contact_id);
                END IF;
            END IF;
        ELSE
            IF i_vendor_contact_id IS NOT NULL THEN
                SELECT  count(1)
                INTO    l_check_vcid
                FROM    po_vendor_contacts
                WHERE   vendor_id = i_vendor_id
                AND     vendor_contact_id = i_vendor_contact_id;

                IF l_check_vcid = 0 THEN
                    o_success := FALSE;
                    l_debug_info := 'Invalid combination of (vendor_id, '
                                    || 'vendor_contact_id)';
                    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME
                                       || l_api_name, l_debug_info);
                    END IF;
                ELSE
                    l_site_where := l_site_where
                                    || ' AND vendor_site_id IN ( '
                                    || 'SELECT vendor_site_id '
                                    || 'FROM   PO_VENDOR_CONTACTS '
                                    || 'WHERE  vendor_contact_id = '
                                    || to_char( i_vendor_contact_id ) || ' )' ;

                    l_contact_where     := l_contact_where
                                        || ' AND vendor_contact_id = '
                                        || to_char(i_vendor_contact_id);
                END IF;
            END IF;
        END IF;
    END IF;

    IF o_success = FALSE THEN
        return;
    END IF;
    /* ============ Validation Check and query string end ============= */

    l_debug_info := 'l_site_where = ' || l_site_where ;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_api_name,
                       l_debug_info);
    END IF;

    l_debug_info := 'l_contact_where = ' || l_contact_where ;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_api_name,
                       l_debug_info);
    END IF;

    SELECT  *
    INTO    o_supplier_info.supp_rec
    FROM    ap_suppliers
    WHERE   vendor_id = i_vendor_id;

    OPEN c_site FOR l_site_sel || l_site_where ;
    LOOP
        FETCH c_site BULK COLLECT INTO l_site_tab LIMIT 100;
        EXIT WHEN l_site_tab.COUNT = 0;

        FOR l_site_loop_indx IN 1..l_site_tab.COUNT
        LOOP
            l_site_indx := NVL( o_supplier_info.site_con_tab.LAST, 0) + 1;
            o_supplier_info.site_con_tab(l_site_indx).site_rec
				            := l_site_tab(l_site_loop_indx);
            OPEN c_contact FOR l_contact_sel || l_contact_where
                       || ' AND vendor_site_id = '
                       || to_char(l_site_tab(l_site_loop_indx).vendor_site_id);
            LOOP
                FETCH c_contact BULK COLLECT INTO l_contact_tab LIMIT 100;
                EXIT WHEN l_contact_tab.COUNT = 0;

                FOR l_contact_loop_indx IN 1..l_contact_tab.COUNT
                LOOP
                    l_contact_indx := NVL(
  		    o_supplier_info.site_con_tab(l_site_indx).contact_tab.LAST,
					0) + 1;
                    o_supplier_info.site_con_tab(l_site_indx).
 		                  contact_tab(l_contact_indx) :=
                                           l_contact_tab(l_contact_loop_indx);
                END LOOP;
		l_contact_tab.DELETE;
            END LOOP;
            CLOSE c_contact;
        END LOOP;
	l_site_tab.DELETE;
    END LOOP;
    CLOSE c_site;

EXCEPTION
    WHEN OTHERS THEN
        IF (SQLCODE <> -20001 ) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
        END IF;

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_api_name,
                            SQLERRM);
        END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;

END Supplier_Details;

------------------------------------------------------------------------------
----------------------------- Supplier_Details -------------------------------
------------------------------------------------------------------------------
/* Fetches the details of Supplier, Site and Contact for a particular range
 * of vendor_id.
 * This is an overloaded procedure. The parameter o_supplier_info_tab can be
 * used to distinguish between the calls. Here, both i_from_vendor_id and
 * i_to_vendor_id are mandatory parameters.
 * This procedure should be called with a reasonable range of vendor_id based
 * on the resources available at customer's instance to avoid performance
 * issues. If there is some performance issue then the only way to fix it will
 * be to provide a lesser range of vendor_id.
 *
 * Parameters : i_from_vendor_id    - Start range of vendor_id
 *              i_to_vendor_id      - End range of vendor_id
 *              o_supplier_info_tab - Supplier details are populated into
 *                                    this parameter.
 *              o_success           - If no vendor exists in the range of
 *                                    vendor_id for which this procedure is
 *                                    called then o_success is set to FALSE
 *
*/

PROCEDURE Supplier_Details(
                           i_from_vendor_id     IN    NUMBER ,
                           i_to_vendor_id       IN    NUMBER ,
                           o_supplier_info_tab  OUT NOCOPY t_supplier_info_tab,
                           o_success            OUT NOCOPY BOOLEAN
                          )
IS
    TYPE t_site_refcur    IS REF CURSOR;
    TYPE t_contact_refcur IS REF CURSOR;
    TYPE t_supplier_tab   IS TABLE OF ap_suppliers%ROWTYPE
    INDEX BY BINARY_INTEGER;
    TYPE t_site_tab       IS TABLE OF ap_supplier_sites_all%ROWTYPE
    INDEX BY BINARY_INTEGER;

    CURSOR c_supplier
    IS
        SELECT  *
        FROM    ap_suppliers
        WHERE   vendor_id BETWEEN i_from_vendor_id AND i_to_vendor_id;

    c_site          t_site_refcur;
    c_contact       t_contact_refcur;
    l_supplier_tab  t_supplier_tab;
    l_site_tab      t_site_tab;
    l_contact_tab   t_contacts_tab;
    l_site_sel      VARCHAR2(1000) := 'SELECT * FROM ap_supplier_sites_all ';
    l_site_where    VARCHAR2(1000) := ' WHERE vendor_id = ' ;
    l_contact_sel   VARCHAR2(1000) := 'SELECT * FROM po_vendor_contacts ';
    l_contact_where VARCHAR2(1000) := ' WHERE vendor_id = ' ;
    l_supplier_indx NUMBER;
    l_site_indx     NUMBER;
    l_contact_indx  NUMBER;
    l_check_vid     NUMBER;
    l_api_name      CONSTANT VARCHAR2(200) := 'Supplier_Details';
    l_debug_info    VARCHAR2(2000);
BEGIN

    l_debug_info := 'Called with parameters : i_from_vendor_id = '
                    || to_char(i_from_vendor_id) || ', i_to_vendor_id = '
                    || to_char(i_to_vendor_id) ;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_api_name,
                       l_debug_info);
    END IF;

    SELECT  count(1)
    INTO    l_check_vid
    FROM    ap_suppliers
    WHERE   vendor_id BETWEEN i_from_vendor_id AND i_to_vendor_id;

    IF l_check_vid = 0 THEN
        o_success := FALSE;
        l_debug_info := 'No vendor exists within this range of vendor_id';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                           l_api_name, l_debug_info);
        END IF;
    ELSE
        OPEN c_supplier;
        LOOP
            FETCH c_supplier BULK COLLECT INTO l_supplier_tab LIMIT 100;
            EXIT WHEN l_supplier_tab.COUNT = 0;

            FOR l_supp_loop_indx IN 1..l_supplier_tab.COUNT
            LOOP
                l_supplier_indx := NVL( o_supplier_info_tab.LAST, 0) + 1;
                o_supplier_info_tab(l_supplier_indx).supp_rec :=
                                        l_supplier_tab(l_supp_loop_indx);

                OPEN c_site FOR l_site_sel || l_site_where
                          ||to_char(l_supplier_tab(l_supp_loop_indx).vendor_id);
                LOOP
                    FETCH c_site BULK COLLECT INTO l_site_tab LIMIT 100;
                    EXIT WHEN l_site_tab.COUNT = 0;

                    FOR l_site_loop_indx IN 1..l_site_tab.COUNT
                    LOOP
                        l_site_indx :=
                          NVL( o_supplier_info_tab(l_supplier_indx).
                               site_con_tab.LAST,  0) + 1;
                        o_supplier_info_tab(l_supplier_indx).
                        site_con_tab(l_site_indx).site_rec
                            := l_site_tab(l_site_loop_indx);
                        OPEN c_contact FOR l_contact_sel || l_contact_where
                        || to_char( l_supplier_tab(l_supp_loop_indx).vendor_id )
                        || ' AND vendor_site_id = '
                        ||to_char(l_site_tab(l_site_loop_indx).vendor_site_id);
                        LOOP
                            FETCH c_contact
                            BULK COLLECT INTO l_contact_tab LIMIT 100;
                            EXIT WHEN l_contact_tab.COUNT = 0;

                            FOR l_contact_loop_indx IN 1..l_contact_tab.COUNT
                            LOOP
                                l_contact_indx := NVL(
                         	        o_supplier_info_tab(l_supplier_indx).
                                    site_con_tab(l_site_indx).contact_tab.LAST,
                					0) + 1;
                                o_supplier_info_tab(l_supplier_indx).
                                   site_con_tab(l_site_indx).
                                       contact_tab(l_contact_indx) :=
                                           l_contact_tab(l_contact_loop_indx);
                            END LOOP;
                            l_contact_tab.DELETE;
                        END LOOP;
                        CLOSE c_contact;
                    END LOOP;
                	l_site_tab.DELETE;
                END LOOP;
                CLOSE c_site;
           END LOOP;
           l_supplier_tab.DELETE;
        END LOOP;
        CLOSE c_supplier;
        o_success := TRUE;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF (SQLCODE <> -20001 ) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info );
        END IF;

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_api_name,
                            SQLERRM);
        END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;

END Supplier_Details;

END AP_SUPPLIER_INFO_PKG;

/
