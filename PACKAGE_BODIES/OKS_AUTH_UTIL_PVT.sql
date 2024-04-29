--------------------------------------------------------
--  DDL for Package Body OKS_AUTH_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_AUTH_UTIL_PVT" AS
    /* $Header: OKSRAUTB.pls 120.24.12010000.4 2009/08/06 17:39:29 cgopinee ship $ */

        ------------------------ Internal Type Declarations ---------------------------------
    TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE date_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
    TYPE chr_tbl_type IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;


    --GLOBAL VARIABLES
    g_clvl_filter_rec      clvl_filter_rec;
    g_clvl_selections_tbl  clvl_selections_tbl;
    g_chr_id               NUMBER;

    -- This procedure is to create a table of party ids based on Default criteria Customer/Related or Both

    FUNCTION Get_selling_price(p_order_line_id IN NUMBER)
    RETURN NUMBER
    IS
    CURSOR l_csr_get_selling_price(p_order_line_id IN NUMBER  )
        IS
        SELECT unit_selling_price
        FROM   oe_order_lines_all
        WHERE  line_id = p_order_line_id;

    l_selling_price NUMBER := 0;
    BEGIN
        OPEN l_csr_get_selling_price(p_order_line_id);
        FETCH l_csr_get_selling_price INTO l_selling_price;
        IF l_Csr_get_selling_price%NOTFOUND THEN
            l_selling_price := 0;
        END IF;
        CLOSE l_csr_get_selling_price;


        RETURN l_selling_price;

    END;

    PROCEDURE get_item_name_desc(p_inv_id IN NUMBER,
                                 x_name   OUT NOCOPY VARCHAR2,
                                 x_description OUT NOCOPY VARCHAR2   )
    IS
    CURSOR l_csr_get_name_desc(p_inv_id IN NUMBER) IS
        SELECT name, description
        FROM   OKX_SYSTEM_ITEMS_V
        WHERE  id1 = p_inv_id
        AND  TRUNC(SYSDATE) BETWEEN trunc(nvl(start_date_active, SYSDATE)) AND trunc(nvl(end_date_active, SYSDATE)) ;

    l_sp_flag VARCHAR2(1);
    l_name    OKX_SYSTEM_ITEMS_V.name%TYPE;
    l_description OKX_SYSTEM_ITEMS_V.name%TYPE;

    BEGIN
        OPEN  l_csr_get_name_desc(p_inv_id) ;
        FETCH l_csr_get_name_desc INTO l_name, l_description ;
        x_name := l_name;
        x_description := l_description;
        CLOSE l_csr_get_name_desc;

    END;

    PROCEDURE get_party_id(p_default       IN   VARCHAR2,
                           p_party_id      IN   NUMBER,
                           p_org_id        IN   NUMBER,
                           x_party_id_tbl  OUT  NOCOPY party_id_tbl )
    IS


    CURSOR l_csr_cust_party (p_party_id IN NUMBER)
        IS
        SELECT id1, name
        FROM okx_parties_v
        WHERE id1 = p_party_id;

    CURSOR l_csr_rel_party (p_party_id IN NUMBER,
                            p_org_id   IN NUMBER)  IS
        SELECT P.id1, P.name
        FROM   OKX_PARTIES_V P,
               OKX_CUSTOMER_ACCOUNTS_V CA1
        WHERE  P.id1 = CA1.party_id
        AND    CA1.id1  IN(SELECT  A.related_cust_account_id
                           FROM   OKX_CUST_ACCT_RELATE_ALL_V A,
                           OKX_CUSTOMER_ACCOUNTS_V  B
                           WHERE  B.ID1 = A.CUST_ACCOUNT_ID
                           AND    B.party_id = p_party_id
                           AND    B.status = 'A'
                           AND    A.status = 'A'
                           AND    A.org_id = p_org_id)
        AND CA1.status = 'A';

    CURSOR l_csr_both_party(p_party_id IN NUMBER,
                            p_org_id   IN NUMBER) IS
        SELECT id1, name
        FROM   okx_parties_v
        WHERE  id1 = p_party_id
        UNION
        SELECT P.id1, p.name
        FROM   OKX_PARTIES_V P,
               OKX_CUSTOMER_ACCOUNTS_V CA1
        WHERE  P.id1 = CA1.party_id
        AND    CA1.id1  IN(SELECT  A.related_cust_account_id
                           FROM   OKX_CUST_ACCT_RELATE_ALL_V A,
                           OKX_CUSTOMER_ACCOUNTS_V  B
                           WHERE  B.ID1 = A.CUST_ACCOUNT_ID
                           AND    B.party_id = p_party_id
                           AND    B.status = 'A'
                           AND    A.status = 'A'
                           AND    A.org_id = p_org_id)
        AND CA1.status = 'A';

    i                 NUMBER := 1;
    l_party_id        OKX_PARTIES_V.id1%TYPE;
    l_party_name      OKX_PARTIES_V.name%TYPE;
    BEGIN
        IF p_default = 'CUSTOMER' THEN

            OPEN l_csr_cust_party(p_party_id
                                  );
            FETCH l_csr_cust_party INTO l_party_id, l_party_name;
            IF l_csr_cust_party%FOUND THEN
                x_party_id_tbl(1).party_id := l_party_id;
                x_party_id_tbl(1).party_name := l_party_name;
            END IF;
            CLOSE l_csr_cust_party;

        ELSIF p_default = 'RELATED' THEN

            OPEN l_csr_rel_party(p_party_id,
                                 p_org_id   );
            LOOP

                FETCH l_csr_rel_party INTO l_party_id, l_party_name;
                EXIT WHEN l_csr_rel_party%NOTFOUND;
                x_party_id_tbl(i).party_id := l_party_id;
                x_party_id_tbl(i).party_name := l_party_name;
                i := i + 1;
            END LOOP ;
            CLOSE l_csr_rel_party;
        ELSIF p_default = 'BOTH' THEN
            OPEN l_csr_both_party(p_party_id,
                                  p_org_id   );
            LOOP

                FETCH l_csr_both_party INTO l_party_id, l_party_name;
                EXIT WHEN l_csr_both_party%NOTFOUND;
                x_party_id_tbl(i).party_id := l_party_id;
                x_party_id_tbl(i).party_name := l_party_name;
                i := i + 1;
            END LOOP ;
            CLOSE l_csr_both_party;
        -- Bug 5054171 --
	ELSIF p_default = 'ALL' THEN

            OPEN l_csr_cust_party(p_party_id
                                  );
            FETCH l_csr_cust_party INTO l_party_id, l_party_name;
            IF l_csr_cust_party%FOUND THEN
                x_party_id_tbl(1).party_id := l_party_id;
                x_party_id_tbl(1).party_name := l_party_name;
            END IF;
            CLOSE l_csr_cust_party;
        END IF;
	-- Bug 5054171 --

    END ;

    -- This procedure is to create a table of customer ids based on Default criteria Customer/Related or Both
    PROCEDURE get_customer_id(p_default IN  VARCHAR2,
                              p_party_id IN NUMBER,
                              p_org_id   IN NUMBER,
                              x_cust_id_tbl  OUT  NOCOPY cust_id_tbl )
    IS

    CURSOR l_csr_customer (p_party_id IN NUMBER,
                           p_org_id   IN NUMBER)
        IS
        SELECT CA1.Id1, CA1.name
        FROM   OKX_CUSTOMER_ACCOUNTS_V CA1
        WHERE  CA1.party_id = p_party_id
        AND    CA1.status = 'A'
        ORDER BY ca1.name ;


    CURSOR l_csr_rel_customer (p_party_id IN NUMBER,
                               p_org_id   IN NUMBER)  IS
        SELECT CA2.id1, CA2.name
        FROM   OKX_CUSTOMER_ACCOUNTS_V CA2
        WHERE  CA2.id1 IN(SELECT A.RELATED_CUST_ACCOUNT_ID
                          FROM   OKX_CUST_ACCT_RELATE_ALL_V A,
                          OKX_CUSTOMER_ACCOUNTS_V  B
                          WHERE  B.ID1 = A.CUST_ACCOUNT_ID
                          AND    B.party_id = p_party_id
                          AND    B.status = 'A'
                          AND    A.status = 'A'
                          AND    A.org_id = p_org_id)
        AND CA2.status = 'A'
        ORDER BY ca2.name ;

    CURSOR l_csr_both_customer(p_party_id IN NUMBER,
                               p_org_id   IN NUMBER) IS
        SELECT CA1.Id1, CA1.name
        FROM   OKX_CUSTOMER_ACCOUNTS_V CA1
        WHERE  CA1.party_id = p_party_id
        AND    CA1.status = 'A'
        UNION
        SELECT CA2.id1, CA2.name
        FROM   OKX_CUSTOMER_ACCOUNTS_V CA2
        WHERE  CA2.id1 IN(SELECT A.RELATED_CUST_ACCOUNT_ID
                          FROM   OKX_CUST_ACCT_RELATE_ALL_V A,
                          OKX_CUSTOMER_ACCOUNTS_V  B
                          WHERE  B.ID1 = A.CUST_ACCOUNT_ID
                          AND    B.party_id = p_party_id
                          AND    B.status = 'A'
                          AND    A.status = 'A'
                          AND    A.org_id = p_org_id)
       AND CA2.status = 'A'
       ORDER BY 2 ;

    i                 NUMBER := 1;
    l_customer_id     OKX_CUSTOMER_ACCOUNTS_V.id1%TYPE;
    l_customer_name   OKX_CUSTOMER_ACCOUNTS_V.name%TYPE;

    BEGIN
        --------------------------------errorout(' IN customer id func '||p_default||' '||p_party_id||' '||p_org_id);

        IF p_default = 'CUSTOMER' THEN

            OPEN l_csr_customer(p_party_id,
                                p_org_id   );
            LOOP

                FETCH l_csr_customer INTO l_customer_id, l_customer_name;
                EXIT WHEN l_csr_customer%NOTFOUND;

                x_cust_id_tbl(i).customer_id := l_customer_id;
                x_cust_id_tbl(i).customer_name := l_customer_name;
                i := i + 1;
            END LOOP ;
            CLOSE l_csr_customer;
        ELSIF p_default = 'RELATED' THEN
            OPEN l_csr_rel_customer(p_party_id,
                                    p_org_id   );
            LOOP

                FETCH l_csr_rel_customer INTO l_customer_id, l_customer_name;
                EXIT WHEN l_csr_rel_customer%NOTFOUND;
                x_cust_id_tbl(i).customer_id := l_customer_id;
                x_cust_id_tbl(i).customer_name := l_customer_name;
                i := i + 1;
            END LOOP ;
            CLOSE l_csr_rel_customer;
        ELSIF p_default = 'BOTH' THEN
            OPEN l_csr_both_customer(p_party_id,
                                     p_org_id   );
            LOOP
                ----------------------------------errorout(' In loop for both ');
                FETCH l_csr_both_customer INTO l_customer_id, l_customer_name;
                IF l_csr_both_customer%NOTFOUND THEN
                    EXIT;
                ELSE
                    ----------------------------------------errorout(' both customer_id '||l_customer_id);
                    x_cust_id_tbl(i).customer_id := l_customer_id;
                    x_cust_id_tbl(i).customer_name := l_customer_name;
                    i := i + 1;
                END IF;
            END LOOP ;
            CLOSE l_csr_both_customer;
        END IF;

    END ;


    /*****************************************************************/
    PROCEDURE get_products(p_filter          IN VARCHAR2,
                           p_id              IN NUMBER DEFAULT NULL,
                           p_default         IN VARCHAR2,
                           p_cust_id_list    IN VARCHAR2,
                           p_party_id        IN VARCHAR2,
                           p_org_id          IN NUMBER,
                           p_organization_id IN NUMBER,
                           x_prod_tbl OUT NOCOPY prod_tbl)
    IS


    /* Select Products for a single customer or for all  customers belonging to a Party */
    -- This cursor is not used --
    CURSOR l_csr_party_products(p_party_id IN NUMBER,
                                p_organization_id IN NUMBER)
        IS
        SELECT CII.instance_id id1,
               CII.install_location_id,
               CII.quantity,
               CII.instance_number,
               CII.unit_of_measure,
                    0,
               CII.inventory_item_id,
               CII.serial_number,
               '#' id2,
               CII.last_oe_order_line_id
            FROM   CSI_ITEM_INSTANCES CII,
               CSI_INSTANCE_STATUSES CIS
        WHERE  CII.owner_party_account_id IN
                             (SELECT id1 FROM okx_customer_accounts_v
                              WHERE  party_id = p_party_id)
        AND  CII.Instance_status_id = CIS.instance_status_id
        AND    CIS.service_order_allowed_flag = 'Y';


    l_get_prod_rec get_prod_rec;

    TYPE var_cur_type IS REF CURSOR ;

    csr_get_products    var_cur_type;
    get_prod_sql        VARCHAR2(5000);
    l_prod_rec          prod_rec;
    l_id                NUMBER;
    i                   NUMBER := 1;
    l_add_condition_sql VARCHAR2(500) := '';
    l_customer_id       OKX_CUSTOMER_ACCOUNTS_V.id1%TYPE ;
    l_org_id            NUMBER;get_prod_sql_all    VARCHAR2(5000);
    l_order_by         VARCHAR2(2000);
    get_prod_sql_cust  VARCHAR2(10000);
    get_prod_sql_rel  VARCHAR2(10000);
    get_prod_sql_both  VARCHAR2(10000);

    BEGIN


        ----------------------errorout_an(' in get product ');

        get_prod_sql := ' SELECT CII.instance_id id1    '
        ||', CII.install_location_id install_location_id '
        ||', CII.quantity quantity '
        ||', CII.instance_number instance_number '
        ||', CII.unit_of_measure unit_of_measure '
        ||', 0  '
        ||', CII.inventory_item_id   inventory_item_id'
        ||', CII.serial_number serial_number '
        ||', ''#'' id2 '
        ||', CII.last_oe_order_line_id '
        ||', CII.external_reference ' -- new bug 4372877
        ||'  FROM   CSI_ITEM_INSTANCES CII, CSI_INSTANCE_STATUSES  CIS '
        ||'  WHERE   '
        ||'  CIS.instance_status_id = CII.instance_status_id '
        ||'  AND    CIS.service_order_allowed_flag = ''Y''' ;


        /*** These queries will hold when filter = Item/Site/System/Party  ***/

        /**** Get products when default = customer ***/

        get_prod_sql_cust := ' SELECT CII.instance_id id1    '
        ||', CII.install_location_id install_location_id '
        ||', CII.quantity quantity '
        ||', CII.instance_number instance_number '
        ||', CII.unit_of_measure unit_of_measure '
        ||', 0  unit_selling_price '
        ||', CII.inventory_item_id   inventory_item_id'
        ||', CII.serial_number serial_number '
        ||', ''#'' id2 '
        ||', CII.last_oe_order_line_id '
        ||', CII.external_reference ' -- new bug 4372877
        ||'  FROM   CSI_ITEM_INSTANCES CII, CSI_INSTANCE_STATUSES  CIS , MTL_SYSTEM_ITEMS_KFV IT'
        ||'  WHERE IT.inventory_item_id = CII.inventory_item_id '
        ||'  AND  IT.serviceable_product_flag = ''Y'''
        ||'  AND  IT.organization_id = :p_organization_id '
        ||'  AND  CIS.instance_status_id = CII.instance_status_id '
        ||'  AND  CIS.service_order_allowed_flag = ''Y'''
        ||'  AND    CII.owner_party_account_id in (select id1 '
        ||' from okx_customer_accounts_v '
        ||' where party_id =  :l_party_id ) ';


        /**** Get products when default = related ***/

        get_prod_sql_rel := ' SELECT CII.instance_id id1    '
        ||', CII.install_location_id install_location_id '
        ||', CII.quantity quantity '
        ||', CII.instance_number instance_number '
        ||', CII.unit_of_measure unit_of_measure '
        ||', 0  unit_selling_price '
        ||', CII.inventory_item_id   inventory_item_id'
        ||', CII.serial_number serial_number '
        ||', ''#'' id2 '
        ||', last_oe_order_line_id '
        ||', CII.external_reference ' -- new bug 4372877
        ||'  FROM   CSI_ITEM_INSTANCES CII, CSI_INSTANCE_STATUSES  CIS , MTL_SYSTEM_ITEMS_KFV IT'
        ||'  WHERE IT.inventory_item_id = CII.inventory_item_id '
        ||'  AND  IT.serviceable_product_flag = ''Y'''
        ||'  AND  IT.organization_id = :p_organization_id '
        ||'  AND  '
        ||'     CIS.instance_status_id = CII.instance_status_id '
        ||'  AND  CIS.service_order_allowed_flag = ''Y'''
        ||'  AND    CII.owner_party_account_id in  '
        ||'  (select A.RELATED_CUST_ACCOUNT_ID '
        ||'   FROM   OKX_CUST_ACCT_RELATE_ALL_V A, '
        ||'          OKX_CUSTOMER_ACCOUNTS_V  B '
        ||'   WHERE  B.ID1 = A.CUST_ACCOUNT_ID '
        ||'   AND    B.party_id =   :l_party_id '
        ||'   AND    B.status = ''A'''
        ||'   AND    A.status = ''A'''
        ||'   AND    A.org_id =  :l_org_id '
        ||'  ) '                        ;

        /**** Get products when default = both ***/

        get_prod_sql_both := ' SELECT CII.instance_id id1    '
        ||', CII.install_location_id install_location_id '
        ||', CII.quantity quantity '
        ||', CII.instance_number instance_number '
        ||', CII.unit_of_measure unit_of_measure '
        ||',0  unit_selling_price '
        ||', CII.inventory_item_id   inventory_item_id'
        ||', CII.serial_number serial_number '
        ||', ''#'' id2 '
        ||', last_oe_order_line_id '
        ||', CII.external_reference ' -- new bug 4372877
        ||'  FROM   CSI_ITEM_INSTANCES CII, CSI_INSTANCE_STATUSES  CIS , MTL_SYSTEM_ITEMS_KFV IT'
        ||'  WHERE IT.inventory_item_id = CII.inventory_item_id '
        ||'  AND  IT.serviceable_product_flag = ''Y'''
        ||'  AND  IT.organization_id = :p_organization_id '
        ||'  AND   '
        ||'     CIS.instance_status_id = CII.instance_status_id '
        ||'  AND  CIS.service_order_allowed_flag = ''Y'''
        ||'  AND    CII.owner_party_account_id in (select id1 '
        ||' from okx_customer_accounts_v '
        ||' where party_id = to_char(:l_party_id) '
        ||' UNION '
        ||'  select A.RELATED_CUST_ACCOUNT_ID '
        ||'   FROM   OKX_CUST_ACCT_RELATE_ALL_V A, '
        ||'          OKX_CUSTOMER_ACCOUNTS_V  B '
        ||'   WHERE  B.ID1 = A.CUST_ACCOUNT_ID '

        ||'   AND    B.party_id = :l_party_id'
        ||'   AND    B.status = ''A'''
        ||'   AND    A.status = ''A'''
        ||'   AND    A.org_id =  :l_org_id '
        ||'  ) ';


        get_prod_sql_all := ' SELECT CII.instance_id id1    '
        ||', CII.install_location_id install_location_id '
        ||', CII.quantity quantity '
        ||', CII.instance_number instance_number '
        ||', CII.unit_of_measure unit_of_measure '
        ||', 0  unit_selling_price '
        ||', CII.inventory_item_id   inventory_item_id'
        ||', CII.serial_number serial_number '
        ||', ''#'' id2 '
        ||', CII.last_oe_order_line_id '
        ||', CII.external_reference ' -- new bug 4372877
        ||'  FROM   CSI_ITEM_INSTANCES CII, CSI_INSTANCE_STATUSES  CIS ,  MTL_SYSTEM_ITEMS_KFV IT'
        ||'  WHERE IT.inventory_item_id = CII.inventory_item_id '
        ||'  AND  IT.serviceable_product_flag = ''Y'''
        ||'  AND  IT.organization_id = :p_organization_id '
        ||'  AND   '
        ||'         CIS.instance_status_id = CII.instance_status_id '
        ||'  AND  CIS.service_order_allowed_flag = ''Y''';


        l_order_by := ' Order by CII.serial_number, CII.instance_number ';
        -- removed CII.instance_id for bug3944182

        l_id := p_id;
        l_org_id := p_org_id;

        -----------------------errorout('before condition '||get_prod_sql);
        -- errorout('before condition '||get_prod_sql);

        --------------errorout_ad('before condition '||get_prod_sql);

        IF  p_filter <> ('Model') THEN


            /* If filter = Customer, then the above additional criteria is not required */

            IF p_filter NOT IN ('Party', 'Customer') THEN   /** these two conditions are handled seperately **/
                -- errorout( 'P_filter ' || p_filter);
                IF p_default = 'CUSTOMER' THEN

                    IF p_filter = 'Item' THEN
                        IF l_id IS NOT   NULL THEN
                            get_prod_sql_cust := get_prod_sql_cust ||' '||' AND CII.inventory_item_id = :l_id'||' '|| l_order_by;
                            OPEN csr_get_products FOR get_prod_sql_cust USING p_organization_id, p_party_id, l_id ;
                        ELSE
                            get_prod_sql_cust := get_prod_sql_cust ||' '|| l_order_by;
                            OPEN csr_get_products FOR get_prod_sql_cust USING p_organization_id, p_party_id ;
                        END IF;
                    ELSE
                        IF p_filter = 'Site' THEN
                            l_add_condition_sql := ' AND CII.install_location_id = :l_id';
                        ELSIF p_filter = 'System' THEN
                            l_add_condition_sql := ' AND CII.system_id = :l_id';
                        END IF;
                        --                ------------------------errorout_an('after condition '||get_prod_sql_cust);
                        get_prod_sql_cust := get_prod_sql_cust ||' '|| l_add_condition_sql ||' '|| l_order_by;
                        OPEN csr_get_products FOR get_prod_sql_cust USING p_organization_id, p_party_id, l_id ;
                    END IF;

                ELSIF p_default = 'RELATED' THEN

                    IF p_filter = 'Item' THEN
                        IF l_id IS NOT   NULL THEN
                            get_prod_sql_rel := get_prod_sql_rel ||' '||' AND CII.inventory_item_id = :l_id'||' '|| l_order_by;
                            OPEN csr_get_products FOR get_prod_sql_rel USING p_organization_id, p_party_id, l_org_id, l_id ;
                        ELSE
                            get_prod_sql_rel := get_prod_sql_rel ||' '|| l_order_by;
                            OPEN csr_get_products FOR get_prod_sql_rel USING p_organization_id, p_party_id, l_org_id;
                        END IF;
                    ELSE
                        IF p_filter = 'Site' THEN
                            l_add_condition_sql := ' AND CII.install_location_id = :l_id';
                        ELSIF p_filter = 'System' THEN
                            l_add_condition_sql := ' AND CII.system_id = :l_id';
                        END IF;
                        get_prod_sql_rel := get_prod_sql_rel ||' '|| l_add_condition_sql ||' '|| l_order_by;
                        OPEN csr_get_products FOR get_prod_sql_rel USING p_organization_id, p_party_id, l_org_id, l_id ;
                    END IF;

                ELSIF p_default = 'BOTH' THEN
                    IF p_filter = 'Item' THEN
                        IF l_id IS NOT   NULL THEN
                            get_prod_sql_both := get_prod_sql_both ||' '||' AND CII.inventory_item_id = :l_id'||' '|| l_order_by;
                            OPEN csr_get_products FOR get_prod_sql_both USING p_organization_id, p_party_id, p_party_id, l_org_id, l_id ;
                        ELSE
                            get_prod_sql_both := get_prod_sql_both ||' '|| l_order_by;
                            OPEN csr_get_products FOR get_prod_sql_both USING p_organization_id, p_party_id, p_party_id, l_org_id ;
                        END IF;
                    ELSE
                        IF p_filter = 'Site' THEN
                            l_add_condition_sql := ' AND CII.install_location_id = :l_id';
                        ELSIF p_filter = 'System' THEN
                            l_add_condition_sql := ' AND CII.system_id = :l_id';
                        END IF;

                        get_prod_sql_both := get_prod_sql_both ||' '|| l_add_condition_sql ||' '|| l_order_by;
                        --                ------------------errorout_an('after condition both '||get_prod_sql_both);
                        OPEN csr_get_products FOR get_prod_sql_both USING p_organization_id, p_party_id, p_party_id, l_org_id, l_id ;
                    END IF;

                ELSIF p_default = 'ALL' THEN
                    IF p_filter = 'Item' THEN
                        IF l_id IS NOT   NULL THEN
                            get_prod_sql_all := get_prod_sql_all ||' '||' AND CII.inventory_item_id = :l_id'||' '|| l_order_by;
                            -- BUG 3643410  31-MAY-2004 --
                            -- GCHADHA --
                            -- OPEN csr_get_products FOR get_prod_sql_all USING l_id, p_organization_id;
                            OPEN csr_get_products FOR get_prod_sql_all USING p_organization_id, l_id;
                            -- GCHADHA --
                        ELSE
                            -- BUG 3643410  31-MAY-2004 --
                            -- GCHADHA --
                            --   get_prod_sql_all  := get_prod_sql_both||' '||' AND CII.inventory_item_id = :l_id'||l_order_by;
                            get_prod_sql_all := get_prod_sql_all ||' '|| l_order_by;
                            -- OPEN csr_get_products FOR get_prod_sql_all USING l_id, p_organization_id;
                            OPEN csr_get_products FOR get_prod_sql_all USING p_organization_id;
                            -- END GCHADHA --
                        END IF;
                    ELSE
                        IF l_id IS NOT NULL THEN
                            IF p_filter = 'Site' THEN
                                l_add_condition_sql := ' AND CII.install_location_id = :l_id';
                            ELSIF p_filter = 'System' THEN
                                l_add_condition_sql := ' AND CII.system_id = :l_id';
                            END IF;
                            get_prod_sql_all := get_prod_sql_all ||' '|| l_add_condition_sql ||' '|| l_order_by;
                            -- BUG 3643410  31-MAY-2004 --
                            -- GCHADHA --
                            --   OPEN csr_get_products FOR get_prod_sql_all USING l_id, p_organization_id ;
                            OPEN csr_get_products FOR get_prod_sql_all USING p_organization_id, l_id ;
                            -- GCHADHA --
                        ELSE
                            get_prod_sql_all := get_prod_sql_all ||' '|| l_order_by;
                            OPEN csr_get_products FOR get_prod_sql_all USING p_organization_id ;
                        END IF;

                    END IF;

                END IF;

            ELSIF p_filter = 'Party' THEN
                --           ----------------errorout_an(' party id  '||p_party_id);

                IF l_id IS NOT NULL THEN
                    OPEN csr_get_products FOR get_prod_sql_cust USING p_organization_id, l_id;
                ELSE

                    IF p_default = 'CUSTOMER'  THEN
                        get_prod_sql_cust := get_prod_sql_cust ||' '|| l_order_by;
                        OPEN csr_get_products FOR get_prod_sql_cust USING p_organization_id, p_party_id;
                    ELSIF p_default = 'RELATED' THEN
                        get_prod_sql_rel := get_prod_sql_rel ||' '|| l_order_by;
                        OPEN csr_get_products FOR get_prod_sql_rel USING p_organization_id, p_party_id, p_org_id;
                    ELSIF p_default = 'BOTH' THEN
                        get_prod_sql_both := get_prod_sql_both ||' '|| l_order_by;
                        OPEN csr_get_products FOR get_prod_sql_both USING p_organization_id, p_party_id, p_party_id, p_org_id ;
                    ELSIF p_default = 'ALL' THEN
                        -- Bug 5054171 --
			-- P_cust_id_list is not null when the
			-- name field is not Null
			If p_cust_id_list is not NULL
                        THEN
                             get_prod_sql_cust := get_prod_sql_cust ||' '|| l_order_by;
                        OPEN csr_get_products FOR get_prod_sql_cust USING p_organization_id, p_party_id;

                        ELSE
                            get_prod_sql_all := get_prod_sql_all ||' '|| l_order_by;
                            OPEN csr_get_products FOR get_prod_sql_all USING p_organization_id ; -- USING
                        END IF;
                        -- Bug 5054171 --
                    END IF;
                END IF;


            ELSIF p_filter = 'Customer' THEN
                l_add_condition_sql := ' AND CII.owner_party_account_id = :p_id';
                get_prod_sql := get_prod_sql ||' '|| l_add_condition_sql ||' '|| l_order_by;
                --         --------------errorout_an('after condition customer '||get_prod_sql||' l_id '||l_id ||' p_id '||p_id);
                OPEN csr_get_products FOR get_prod_sql USING p_id ;
            END IF;


            LOOP

                FETCH csr_get_products INTO l_get_prod_rec;
                IF csr_get_products%NOTFOUND THEN
                    EXIT;
                ELSE
                    x_prod_tbl(i).id1 := l_get_prod_rec.id1;
                    x_prod_tbl(i).install_location_Id := l_get_prod_rec.install_location_id ;
                    x_prod_tbl(i).quantity := l_get_prod_rec.quantity;
                    x_prod_tbl(i).instance_number := l_get_prod_rec.instance_number;
                    x_prod_tbl(i).unit_of_measure := l_get_prod_rec.unit_of_measure;
                    x_prod_tbl(i).unit_selling_price := get_selling_price(l_get_prod_rec.oe_line_id);
                    x_prod_tbl(i).inventory_item_id := l_get_prod_rec.inventory_item_id;
                    x_prod_tbl(i).serial_number := l_get_prod_rec.serial_number;
                    x_prod_tbl(i).id2 := l_get_prod_rec.id2;
                    -- GCHADHA --
                    -- 4372877 --
                    -- 5/25/2005 --
                    x_prod_tbl(i).external_reference := l_get_prod_rec.external_reference;
                    -- END GCHADHA --
                    i := i + 1 ;

                END IF;
            END LOOP;
            CLOSE csr_get_products;
            --------------------------errorout_an(' inv id '||l_id||' count '||x_prod_tbl.count);
        END IF;
    END ;



    /*****************************************************************/


    PROCEDURE populate_table(p_prod_tbl         IN    prod_tbl,
                             p_filter           IN    VARCHAR2,
                             px_rowcount        IN OUT NOCOPY NUMBER,
                             p_display_pref     IN    VARCHAR2,
                             x_prod_selections_tbl  IN OUT NOCOPY  prod_selections_tbl )
    IS
    l_price              NUMBER;
    l_name               VARCHAR2(1000);
    l_install_site_id    OKX_PARTY_SITES_V.id1%TYPE;
    -- Bug 4915711 --
    -- l_install_site_name  OKX_PARTY_SITES_V.DESCRIPTION%TYPE;
    l_install_site_name  VARCHAR2(2000);
    -- Bug 4915711 --

    rowcount             NUMBER ;
    l_display_name       VARCHAR2(2000); -- 4915711 --
    j                    NUMBER;
    l_uom_desc           OKx_UNITS_OF_MEASURE_v.unit_of_measure_tl%TYPE;

    CURSOR l_site_name_csr(l_install_site_id NUMBER) IS
        SELECT S.DESCRIPTION
        FROM   OKX_PARTY_SITES_V S
        WHERE  S.ID1 = l_install_site_id;

    CURSOR l_csr_uom_desc(p_uom_code IN VARCHAR2)
        IS
        SELECT unit_of_measure_tl
        FROM OKX_UNITS_OF_MEASURE_V
        WHERE uom_code = p_uom_code ;


    l_gen_name           OKX_SYSTEM_ITEMS_V.name%TYPE;
    l_gen_desc           OKX_SYSTEM_ITEMS_V.description%TYPE;
    BEGIN
        rowcount := px_rowcount;

        ----------------------errorout_an(' in populate table ');

        FOR j IN 1 .. p_prod_tbl.COUNT LOOP
            x_prod_selections_tbl(rowcount).rec_type := 'C';
            x_prod_selections_tbl(rowcount).rec_name := p_filter;
            x_prod_selections_tbl(rowcount).rec_no := rowcount;
            x_prod_selections_tbl(rowcount).cp_id := p_prod_tbl(j).id1;

            IF p_filter = 'Model' THEN
                x_prod_selections_tbl(rowcount).config_parent_id := p_prod_tbl(j).config_parent_id;
                x_prod_selections_tbl(rowcount).model_level := p_prod_tbl(j).model_level;

            END IF;

            x_prod_selections_tbl(rowcount).cp_id2 := p_prod_tbl(j).id2;
            x_prod_selections_tbl(rowcount).ser_number := p_prod_tbl(j).serial_number ;
            x_prod_selections_tbl(rowcount).ref_number := p_prod_tbl(j).instance_number ;
            x_prod_selections_tbl(rowcount).quantity := p_prod_tbl(j).quantity;
            x_prod_selections_tbl(rowcount).orig_net_amt := p_prod_tbl(j).unit_selling_price;
            -- GCHADHA --
            -- BUG 4372877 --
            -- 5/25/2005 --
            x_prod_selections_tbl(rowcount).ext_reference := p_prod_tbl(j).external_reference;

            -- END GCHADHA --




            IF NVL(p_prod_tbl(j).quantity, 1) = 0 THEN
                l_price := 0 ;
            ELSE
                l_price := p_prod_tbl(j).unit_selling_price / NVL(p_prod_tbl(j).quantity, 1);
            END IF;


            x_prod_selections_tbl(rowcount).price := l_price;
            x_prod_selections_tbl(rowcount).inventory_item_id := p_prod_tbl(j).inventory_item_id;
            x_prod_selections_tbl(rowcount).site_id := p_prod_tbl(j).install_location_id;
            x_prod_selections_tbl(rowcount).uom_code := p_prod_tbl(j).unit_of_measure;

            l_install_site_id := p_prod_tbl(j).install_location_id;
            l_install_site_name := '';

            IF l_install_site_id IS NOT NULL THEN
                OPEN  l_site_name_csr(l_install_site_id);
                FETCH l_site_name_csr INTO l_install_site_name;
                CLOSE l_site_name_csr;
            END IF;

            --               l_install_site_name := ' Install description ';
            x_prod_selections_tbl(rowcount).orig_net_amt := get_selling_price(p_prod_tbl(j).oe_line_id);



            OPEN l_csr_uom_desc(p_prod_tbl(j).unit_of_measure);
            FETCH l_csr_uom_desc INTO l_uom_desc;
            CLOSE l_csr_uom_desc;

            -- Get item name and description for the inventory item id

            get_item_name_desc(p_prod_tbl(j).inventory_item_id, l_gen_name, l_gen_desc) ;

            IF p_display_pref = 'DISPLAY_DESC' THEN
                x_prod_selections_tbl(rowcount).name := l_gen_name;
                x_prod_selections_tbl(rowcount).description := l_gen_desc;

            ELSIF p_display_pref = 'DISPLAY_NAME' THEN
                x_prod_selections_tbl(rowcount).name := l_gen_desc;
                x_prod_selections_tbl(rowcount).description := l_gen_name;
            END IF;

            x_prod_selections_tbl(rowcount).site_name := l_install_site_name;

            /*bugfix 5698684 - FP of 5675692 */
            IF p_filter = 'Item' THEN
                  l_display_name := g_serial_number || NVL(p_prod_tbl(j).serial_number, 'N/A') ||
                                    g_ref || NVL(p_prod_tbl(j).instance_number, 'N/A') ||
                                    g_quantity || to_char(p_prod_tbl(j).quantity) || '/' || l_uom_desc ||
                                    g_installed_at || NVL(l_install_site_name, 'N/A');
            ELSE
                  l_display_name := x_prod_selections_tbl(rowcount).name||'; '||g_serial_number ||
                                    NVL(p_prod_tbl(j).serial_number, 'N/A') ||
                                    g_ref || NVL(p_prod_tbl(j).instance_number, 'N/A') ||
                                    g_quantity || to_char(p_prod_tbl(j).quantity) || '/' || l_uom_desc ||
                                    g_installed_at || NVL(l_install_site_name, 'N/A');
            END IF;
            /*bugfix 5698684 - FP of 5675692 */

            x_prod_selections_tbl(rowcount).display_name := l_display_name;

            rowcount := rowcount + 1;

        END LOOP;
        px_rowcount := rowcount - 1;
        ----------------------errorout(' after populate table count '||rowcount);
    END populate_table;



    /************************** get model ***************************/

    PROCEDURE get_model(p_organization_id IN NUMBER,
                        p_clvl_id         IN NUMBER,
                        p_party_id     IN NUMBER,
                        p_display_pref IN VARCHAR2,
                        p_default      IN VARCHAR2,
                        p_org_id       IN VARCHAR2,
                        x_prod_selections_tbl IN OUT NOCOPY OKS_AUTH_UTIL_PVT.prod_selections_tbl)

    IS
    /* Cursor to select all Model  having Covered Products for a given Party ID */
    CURSOR l_csr_all_models(p_party_id IN NUMBER,
                            p_organization_id IN NUMBER)
        IS
        SELECT DISTINCT id1,
               name,
               description
        FROM okx_system_items_v it
        WHERE id1 IN
        (SELECT  inventory_item_id FROM
         csi_item_instances
         WHERE instance_id IN (SELECT PR.object_id
                               FROM csi_ii_relationships PR
                               WHERE relationship_type_code = 'COMPONENT-OF'
                               AND NOT EXISTS (SELECT cp.subject_id FROM csi_ii_relationships cp
                                               WHERE pr.object_id = cp.subject_id )))
        AND IT.serviceable_product_flag = 'Y'
        --And IT.organization_id = p_organization_id
        AND SYSDATE BETWEEN nvl(it.start_date_active, SYSDATE) AND nvl(it.end_date_active, SYSDATE)  ;



    /** get parent child hierarchy from csi_ii_realtionships **/
    CURSOR l_csr_configuration (p_inventory_id  IN NUMBER,
                                p_party_id   IN NUMBER)
        IS
        SELECT ciir.object_id  config_parent_id,
               ciir.subject_id cp_id,
               LEVEL
        FROM   csi_ii_relationships ciir
        WHERE active_end_date IS NULL
        START WITH subject_id
                      IN (SELECT ciir_pr.subject_id
                          FROM   csi_ii_relationships ciir_pr
                          WHERE  object_id  IN
                          (SELECT instance_id
                           FROM   csi_item_instances
                           WHERE  inventory_item_id = p_inventory_id
                           AND    owner_party_account_id IN (SELECT id1
                                                             FROM okx_customer_accounts_v
                                                             WHERE party_id = p_party_id)))
        CONNECT BY  ciir.object_id = PRIOR ciir.subject_id  ;

    /** Cursor to get product + system item details for select instance id ***/


    CURSOR l_csr_model_products(p_instance_id IN NUMBER,
                                p_organization_id       IN NUMBER
                                )
        IS
        SELECT CII.instance_id
              , IT.name
              , IT.description
              , CII.install_location_id
              , CII.quantity
              , CII.instance_number
              , CII.unit_of_measure
              , CII.inventory_item_id
              , CII.serial_number
              , OOL.unit_selling_price
              , '#' id2
              , CII.external_reference -- bug 4372877
        FROM  CSI_ITEM_INSTANCES CII
           , CSI_INSTANCE_STATUSES CIS
           , OE_ORDER_LINES_ALL OOL
           , OKX_SYSTEM_ITEMS_V IT
        WHERE CII.INSTANCE_ID = p_instance_id
        AND   CII.inventory_item_id = IT.id1
        AND   IT.serviceable_product_flag = 'Y'
        AND   IT.organization_id = p_organization_id
        AND   SYSDATE BETWEEN nvl(it.start_date_active, SYSDATE) AND nvl(it.end_date_active, SYSDATE)
        AND   CII.last_oe_order_line_id = OOL.line_id ( + )
        AND   CII.instance_status_id = CIS.instance_status_id
        AND   CIS.service_order_allowed_flag = 'Y'   ;

    l_config_parent_id    CSI_II_RELATIONSHIPS.object_id%TYPE :=  - 99;
    l_config_rec          l_csr_configuration%ROWTYPE;
    l_model_prod_rec      l_csr_model_products%ROWTYPE;
    l_id                  CSI_ITEM_INSTANCES.inventory_item_id%TYPE;
    l_inv_id          NUMBER :=  - 99;
    l_id_old             NUMBER :=  - 99;
    rowcount              NUMBER := 1;
    i                     NUMBER := 1;
    l_display_pref        VARCHAR2(20) := p_display_pref;
    l_name                VARCHAR2(500);

    l_prod_tbl  prod_tbl;

    TYPE var_cur_type5  IS REF CURSOR ;
    csr_model_config  var_cur_type5;

    l_config_cust         VARCHAR2(10000);
    l_config_rel        VARCHAR2(10000);
    l_config_both         VARCHAR2(10000);
    l_config_all         VARCHAR2(10000);

    BEGIN
        rowcount := 1;


        /** Set up dynamic queries to fetch config items **/

        l_config_cust := 'SELECT ciir.object_id  config_parent_id,'
        ||'ciir.subject_id cp_id,'
        ||'level '
        ||' FROM   csi_ii_relationships ciir '
        ||' WHERE active_end_date IS NULL '
        ||' START WITH subject_id '
        ||' IN (SELECT ciir_pr.subject_id '
        ||' FROM   csi_ii_relationships ciir_pr '
        ||' WHERE  object_id  IN '
        ||' ( SELECT instance_id '
        ||' FROM   csi_item_instances '
        ||' WHERE  inventory_item_id = to_char(:l_id)'
        ||' AND    owner_party_account_id in (select id1 '
        ||' from okx_customer_accounts_v '
        ||' where party_id =  to_char(:p_party_id) ))) '
        ||'CONNECT BY  ciir.object_id = PRIOR ciir.subject_id  ' ;


        l_config_rel := 'SELECT ciir.object_id  config_parent_id,'
        ||'ciir.subject_id cp_id,'
        ||'level '
        ||' FROM   csi_ii_relationships ciir '
        ||' WHERE active_end_date IS NULL '
        ||' START WITH subject_id '
        ||' IN (SELECT ciir_pr.subject_id '
        ||' FROM   csi_ii_relationships ciir_pr '
        ||' WHERE  object_id  IN '
        ||' ( SELECT instance_id '
        ||' FROM   csi_item_instances '
        ||' WHERE  inventory_item_id =  to_char(:l_id ) '
        ||' AND    owner_party_account_id in  '
        ||'  (select A.RELATED_CUST_ACCOUNT_ID '
        ||'   FROM   OKX_CUST_ACCT_RELATE_ALL_V A, '
        ||'          OKX_CUSTOMER_ACCOUNTS_V  B '
        ||'   WHERE  B.ID1 = A.CUST_ACCOUNT_ID '
        ||'   AND    B.party_id =   to_char(:p_party_id) '
        ||'   AND    B.status = ''A'''
        ||'   AND    A.status = ''A'''
        ||'   AND    A.org_id =  to_char(:p_org_id) '
        ||'  ))) '
        ||'CONNECT BY  ciir.object_id = PRIOR ciir.subject_id  ' ;

        l_config_both := 'SELECT ciir.object_id  config_parent_id,'
        ||'ciir.subject_id cp_id,'
        ||'level '
        ||' FROM   csi_ii_relationships ciir '
        ||' WHERE active_end_date IS NULL '
        ||' START WITH subject_id '
        ||' IN (SELECT ciir_pr.subject_id '
        ||' FROM   csi_ii_relationships ciir_pr '
        ||' WHERE  object_id  IN '
        ||' ( SELECT instance_id '
        ||' FROM   csi_item_instances '
        ||' WHERE  inventory_item_id =  to_char(:l_id)'
        ||' AND    owner_party_account_id in (select id1 '
        ||' from okx_customer_accounts_v '
        ||' where party_id = to_char(:p_party_id)) '
        ||' UNION '
        ||'  (select A.RELATED_CUST_ACCOUNT_ID '
        ||'   FROM   OKX_CUST_ACCT_RELATE_ALL_V A, '
        ||'          OKX_CUSTOMER_ACCOUNTS_V  B '
        ||'   WHERE  B.ID1 = A.CUST_ACCOUNT_ID '
        ||'   AND    B.party_id = to_char(:p_party_id)'
        ||'   AND    B.status = ''A'''
        ||'   AND    A.status = ''A'''
        ||'   AND    A.org_id =  to_Char(:p_org_id) '
        ||'  ))) '
        ||'CONNECT BY  ciir.object_id = PRIOR ciir.subject_id  ' ;

        l_config_all := 'SELECT ciir.object_id  config_parent_id,'
        ||'ciir.subject_id cp_id,'
        ||'level '
        ||' FROM   csi_ii_relationships ciir '
        ||' WHERE active_end_date IS NULL '
        ||' START WITH subject_id '
        ||' IN (SELECT ciir_pr.subject_id '
        ||' FROM   csi_ii_relationships ciir_pr '
        ||' WHERE  object_id  IN '
        ||' ( SELECT instance_id '
        ||' FROM   csi_item_instances '
        ||' WHERE  inventory_item_id = to_char(:l_id))) '
        ||'CONNECT BY  ciir.object_id = PRIOR ciir.subject_id  ' ;


        IF p_clvl_id IS NULL THEN /* 1st if */

            /* Select all Items for given party first */

            FOR l_get_all_models_rec IN l_csr_all_models(p_party_id, p_organization_id)
                LOOP /** 1st loop **/

                l_id := l_get_all_models_rec.id1;

                /** Get config items for an inventory_item_id **/

                IF  p_default = 'CUSTOMER' THEN
                    OPEN csr_model_config FOR l_config_cust USING l_id, p_party_id;
                ELSIF p_default = 'RELATED' THEN
                    OPEN csr_model_config FOR l_config_rel USING l_id, p_party_id, p_org_id;
                ELSIF p_default = 'BOTH' THEN
                    OPEN csr_model_config FOR l_config_both USING l_id, p_party_id, p_party_id, p_org_id ;
                ELSIF p_default = 'ALL' THEN
                    OPEN csr_model_config FOR l_config_all USING l_id, p_party_id, p_org_id;
                END IF;

                LOOP
                    FETCH csr_model_config INTO l_config_rec;
                    IF csr_model_config%NOTFOUND THEN /* 2nd if */
                        CLOSE csr_model_config;
                        EXIT;
                    ELSE

                        IF (l_prod_tbl.COUNT > 0) THEN

                            populate_table (l_prod_tbl,
                                            'Model',
                                            rowcount,
                                            l_display_pref,
                                            x_prod_selections_tbl);

                            l_prod_tbl.DELETE;
                            rowcount := rowcount + 1;
                            i := 1;
                        END IF;
                        IF l_config_parent_id <> l_config_rec.config_parent_id  AND l_config_rec.LEVEL = 1 THEN /* 3rd if */

                            /* select product details for config parent */
                            /** Build parent **/
                            OPEN l_csr_model_products(l_config_rec.config_parent_id,
                                                      p_organization_id);
                            FETCH l_csr_model_products INTO l_model_prod_rec;
                            IF l_csr_model_products%FOUND THEN

                                IF l_id <> l_id_old THEN
                                    /* Populate parent records */
                                    x_prod_selections_tbl(rowcount).cp_id := l_model_prod_rec.instance_id;
                                    x_prod_selections_tbl(rowcount).config_parent_id := '';
                                    x_prod_selections_tbl(rowcount).name := l_model_prod_rec.name;

                                    x_prod_selections_tbl(rowcount).description := l_model_prod_rec.description;

                                    IF l_display_pref = 'DISPLAY_DESC' THEN /* 5 if */
                                        l_name := rpad(l_model_prod_rec.name, 30, ' ') || rpad(l_model_prod_rec.description, 40,' ');
                                    ELSIF l_display_pref = 'DISPLAY_NAME' THEN
                                        x_prod_selections_tbl(rowcount).description := l_model_prod_rec.name;
                                        x_prod_selections_tbl(rowcount).name := l_model_prod_rec.description;
                                        l_name := rpad(l_model_prod_rec.description, 40,' ') || rpad(l_model_prod_rec.name, 30, ' ');
                                    END IF; /* end if 5 */

                                    x_prod_selections_tbl(rowcount).name := l_name;
                                    x_prod_selections_tbl(rowcount).rec_type := 'P';
                                    x_prod_selections_tbl(rowcount).rec_name := 'Model';
                                    x_prod_selections_tbl(rowcount).rec_no := rowcount;
                                    x_prod_selections_tbl(rowcount).model_level := l_config_rec.LEVEL;
                                    x_prod_selections_tbl(rowcount).cp_id2 := '';
                                    x_prod_selections_tbl(rowcount).ser_number := '';
                                    x_prod_selections_tbl(rowcount).ref_number := '' ;
                                    x_prod_selections_tbl(rowcount).quantity := '';
                                    x_prod_selections_tbl(rowcount).orig_net_amt := '';
                                    x_prod_selections_tbl(rowcount).price := '';
                                    x_prod_selections_tbl(rowcount).inventory_item_id := '';
                                    x_prod_selections_tbl(rowcount).site_id := '';
                                    x_prod_selections_tbl(rowcount).uom_code := '';
                                    x_prod_selections_tbl(rowcount).display_name := '';
                                    x_prod_selections_tbl(rowcount).site_name := '';
                                    x_prod_selections_tbl(rowcount).model_level :=  - 1;
                                    -- BUG 4372877 --
                                    -- GCHADHA --
                                    -- 5/25/2005 --
                                    x_prod_selections_tbl(rowcount).ext_reference := '';
                                    -- END GCHADHA --



                                    l_id_old := l_id;
                                    rowcount := rowcount + 1;
                                END IF;

                                l_config_parent_id := l_config_rec.config_parent_id;

                                /* populate product details of the model */
                                l_prod_tbl(i).id1 := l_config_rec.config_parent_id;
                                l_prod_tbl(i).config_parent_id := '';

                                l_prod_tbl(i).install_location_Id := l_model_prod_rec.install_location_id ;
                                l_prod_tbl(i).quantity := l_model_prod_rec.quantity;
                                l_prod_tbl(i).instance_number := l_model_prod_rec.instance_number;
                                l_prod_tbl(i).unit_of_measure := l_model_prod_rec.unit_of_measure;
                                l_prod_tbl(i).unit_selling_price := l_model_prod_rec.unit_selling_price;
                                l_prod_tbl(i).inventory_item_id := l_model_prod_rec.inventory_item_id;
                                l_prod_tbl(i).serial_number := l_model_prod_rec.serial_number;
                                l_prod_tbl(i).id2 := l_model_prod_rec.id2;
                                l_prod_tbl(i).model_level := 0;
                                -- BUG 4372877 --
                                -- GCHADHA --
                                -- 5/25/2005 --
                                l_prod_tbl(i).external_reference := l_model_prod_rec.external_reference;
                                -- END GCHADHA --

                                i := i + 1 ;
                            END IF; /* end if l_csr_model_products */

                            CLOSE l_csr_model_products;

                        END IF ; /* Populate parent records end if 3 */
                        --                END IF; /** items found csr_configuration cursor end if 2 **/

                        /* populate product details of the model */

                        OPEN l_csr_model_products(l_config_rec.cp_id,
                                                  p_organization_id);
                        FETCH l_csr_model_products INTO l_model_prod_rec;
                        IF l_csr_model_products%FOUND THEN /** if 3 */

                            l_prod_tbl(i).id1 := l_config_rec.cp_id;
                            l_prod_tbl(i).config_parent_id := l_config_rec.config_parent_id;

                            l_prod_tbl(i).install_location_Id := l_model_prod_rec.install_location_id ;
                            l_prod_tbl(i).quantity := l_model_prod_rec.quantity;
                            l_prod_tbl(i).instance_number := l_model_prod_rec.instance_number;
                            l_prod_tbl(i).unit_of_measure := l_model_prod_rec.unit_of_measure;
                            l_prod_tbl(i).unit_selling_price := l_model_prod_rec.unit_selling_price;
                            l_prod_tbl(i).inventory_item_id := l_model_prod_rec.inventory_item_id;
                            l_prod_tbl(i).serial_number := l_model_prod_rec.serial_number;
                            l_prod_tbl(i).id2 := l_model_prod_rec.id2;
                            l_prod_tbl(i).model_level := l_config_rec.LEVEL;
                            -- BUG 4372877 --
                            -- GCHADHA --
                            -- 5/25/2005 --
                            l_prod_tbl(i).external_reference := l_model_prod_rec.external_reference;
                            -- END GCHADHA --

                            i := i + 1 ;
                        END IF; /* end if 3 */
                        CLOSE l_csr_model_products;

                    END IF;
                END LOOP;   /* end loop of l_csr_configuration cursror end loop 2*/
                -- ----------------------errorout(' before populate table '||l_prod_tbl.count);

            END LOOP; /* end loop of inventory item id  end loop 1 */

        ELSIF p_clvl_id IS NOT NULL THEN
            l_id := p_clvl_id;
            /** Get config items for an inventory_item_id **/
            IF  p_default = 'CUSTOMER' THEN
                OPEN csr_model_config FOR l_config_cust USING l_id, p_party_id;
            ELSIF p_default = 'RELATED' THEN
                OPEN csr_model_config FOR l_config_rel USING l_id, p_party_id, p_org_id;
            ELSIF p_default = 'BOTH' THEN
                OPEN csr_model_config FOR l_config_both USING l_id, p_party_id, p_party_id, p_org_id ;
            ELSIF p_default = 'ALL' THEN
                OPEN csr_model_config FOR l_config_all USING l_id; --, p_party_id, p_org_id;
            END IF;

            LOOP
                FETCH csr_model_config INTO l_config_rec;
                IF csr_model_config%NOTFOUND THEN /* 2nd if */
                    CLOSE csr_model_config;
                    EXIT;
                ELSE

                    IF (l_prod_tbl.COUNT > 0) THEN

                        populate_table (l_prod_tbl,
                                        'Model',
                                        rowcount,
                                        l_display_pref,
                                        x_prod_selections_tbl);

                        l_prod_tbl.DELETE;
                        rowcount := rowcount + 1;
                        i := 1;
                    END IF;
                    IF l_config_parent_id <> l_config_rec.config_parent_id  AND l_config_rec.LEVEL = 1 THEN /* 3rd if */

                        /* select product details for config parent */
                        /** Build parent **/
                        OPEN l_csr_model_products(l_config_rec.config_parent_id,
                                                  p_organization_id);
                        FETCH l_csr_model_products INTO l_model_prod_rec;
                        IF l_csr_model_products%FOUND THEN

                            IF l_id <> l_id_old THEN
                                /* Populate parent records */
                                x_prod_selections_tbl(rowcount).cp_id := l_model_prod_rec.instance_id;
                                x_prod_selections_tbl(rowcount).config_parent_id := '';
                                x_prod_selections_tbl(rowcount).name := l_model_prod_rec.name;

                                x_prod_selections_tbl(rowcount).description := l_model_prod_rec.description;

                                IF l_display_pref = 'DISPLAY_DESC' THEN /* 5 if */
                                    l_name := rpad(l_model_prod_rec.name, 30, ' ') || rpad(l_model_prod_rec.description, 40,' ');
                                ELSIF l_display_pref = 'DISPLAY_NAME' THEN
                                    x_prod_selections_tbl(rowcount).description := l_model_prod_rec.name;
                                    x_prod_selections_tbl(rowcount).name := l_model_prod_rec.description;
                                    l_name := rpad(l_model_prod_rec.description, 40,' ') || rpad(l_model_prod_rec.name, 30, ' ');
                                END IF; /* end if 5 */

                                x_prod_selections_tbl(rowcount).name := l_name;
                                x_prod_selections_tbl(rowcount).rec_type := 'P';
                                x_prod_selections_tbl(rowcount).rec_name := 'Model';
                                x_prod_selections_tbl(rowcount).rec_no := rowcount;
                                x_prod_selections_tbl(rowcount).model_level := l_config_rec.LEVEL;
                                x_prod_selections_tbl(rowcount).cp_id2 := '';
                                x_prod_selections_tbl(rowcount).ser_number := '';
                                x_prod_selections_tbl(rowcount).ref_number := '' ;
                                x_prod_selections_tbl(rowcount).quantity := '';
                                x_prod_selections_tbl(rowcount).orig_net_amt := '';
                                x_prod_selections_tbl(rowcount).price := '';
                                x_prod_selections_tbl(rowcount).inventory_item_id := '';
                                x_prod_selections_tbl(rowcount).site_id := '';
                                x_prod_selections_tbl(rowcount).uom_code := '';
                                x_prod_selections_tbl(rowcount).display_name := '';
                                x_prod_selections_tbl(rowcount).site_name := '';
                                x_prod_selections_tbl(rowcount).model_level :=  - 1;
                                -- BUG 4372877 --
                                -- GCHADHA --
                                -- 5/25/2005 --
                                x_prod_selections_tbl(rowcount).ext_reference := '';
                                -- END GCHADHA --
                                l_id_old := l_id;
                                rowcount := rowcount + 1;
                            END IF;

                            l_config_parent_id := l_config_rec.config_parent_id;

                            /* populate product details of the model */
                            l_prod_tbl(i).id1 := l_config_rec.config_parent_id;
                            l_prod_tbl(i).config_parent_id := '';
                            l_prod_tbl(i).install_location_Id := l_model_prod_rec.install_location_id ;
                            l_prod_tbl(i).quantity := l_model_prod_rec.quantity;
                            l_prod_tbl(i).instance_number := l_model_prod_rec.instance_number;
                            l_prod_tbl(i).unit_of_measure := l_model_prod_rec.unit_of_measure;
                            l_prod_tbl(i).unit_selling_price := l_model_prod_rec.unit_selling_price;
                            l_prod_tbl(i).inventory_item_id := l_model_prod_rec.inventory_item_id;
                            l_prod_tbl(i).serial_number := l_model_prod_rec.serial_number;
                            l_prod_tbl(i).id2 := l_model_prod_rec.id2;
                            l_prod_tbl(i).model_level := 0;
                            -- BUG 4372877 --
                            -- GCHADHA --
                            -- 5/25/2005 --
                            l_prod_tbl(i).external_reference := l_model_prod_rec.external_reference;
                            -- END GCHADHA --


                            i := i + 1 ;
                        END IF; /* end if l_csr_model_products */

                        CLOSE l_csr_model_products;

                    END IF ; /* Populate parent records end if 3 */

                    /* populate product details of the model */

                    OPEN l_csr_model_products(l_config_rec.cp_id,
                                              p_organization_id);
                    FETCH l_csr_model_products INTO l_model_prod_rec;
                    IF l_csr_model_products%FOUND THEN /** if 3 */

                        l_prod_tbl(i).id1 := l_config_rec.cp_id;
                        l_prod_tbl(i).config_parent_id := l_config_rec.config_parent_id;

                        l_prod_tbl(i).install_location_Id := l_model_prod_rec.install_location_id ;
                        l_prod_tbl(i).quantity := l_model_prod_rec.quantity;
                        l_prod_tbl(i).instance_number := l_model_prod_rec.instance_number;
                        l_prod_tbl(i).unit_of_measure := l_model_prod_rec.unit_of_measure;
                        l_prod_tbl(i).unit_selling_price := l_model_prod_rec.unit_selling_price;
                        l_prod_tbl(i).inventory_item_id := l_model_prod_rec.inventory_item_id;
                        l_prod_tbl(i).serial_number := l_model_prod_rec.serial_number;
                        l_prod_tbl(i).id2 := l_model_prod_rec.id2;
                        l_prod_tbl(i).model_level := l_config_rec.LEVEL;
                        -- BUG 4372877 --
                        -- GCHADHA --
                        -- 5/25/2005 --
                        l_prod_tbl(i).external_reference := l_model_prod_rec.external_reference;
                        -- END GCHADHA --


                        i := i + 1 ;
                    END IF; /* end if 3 */
                    CLOSE l_csr_model_products;

                END IF;
            END LOOP;   /* end loop of l_csr_configuration cursror end loop 2*/

            /*******************/

        END IF;
    END ; /** end of procedure get_model **/

    /*********************************/


    PROCEDURE get_product_selection(p_clvl_filter_rec IN clvl_filter_rec,
                                    x_prod_selections_tbl OUT NOCOPY prod_selections_tbl)
    IS

    l_param_organization_id  NUMBER := okc_context.get_okc_organization_id;
    l_find                   NUMBER := p_clvl_filter_rec.clvl_find_id;

    TYPE items_rec IS RECORD (inventory_item_id MTL_SYSTEM_ITEMS_KFV.inventory_item_id%TYPE,
                              description       VARCHAR2(10000),
                              name              VARCHAR2(10000));


    l_items_rec items_rec;

    -- Setting up cursor types + record types to fetch Party Sites using Dynamic cursor
    l_get_all_sites_sql  VARCHAR2(2000);
    TYPE var_cur_type1  IS REF CURSOR ;
    l_csr_get_all_sites  var_cur_type1;
    TYPE get_all_sites_rec IS RECORD (id1   OKX_PARTY_SITES_V.id1%TYPE,
                                      name  OKX_PARTY_SITES_V.name%TYPE,
                                      party_site_number OKX_PARTY_SITES_V.party_site_number%TYPE,
                                      -- description       OKX_PARTY_SITES_V.description%TYPE -- Bug 4915711
                                      description       VARCHAR2(2000));

    l_get_all_sites_rec get_all_sites_rec;

    -- Setting up cursor types + record types to fetch Systems using Dynamic cursor
    l_get_all_systems_sql  VARCHAR2(2000);
    TYPE var_cur_type IS REF CURSOR;
    l_csr_get_all_systems  var_cur_type;

    TYPE get_all_systems_rec IS RECORD (id1  CSI_SYSTEMS_B.system_id%TYPE,
                                        NAME CSI_SYSTEMS_TL.name%TYPE,
                                        Description CSI_SYSTEMS_TL.description%TYPE);

    l_get_all_systems_rec get_all_systems_rec;

    l_item_cust VARCHAR2(2000);
    l_item_rel  VARCHAR2(2000);
    l_item_both VARCHAR2(2000);
    l_item_all  VARCHAR2(2000);
    l_select_for_name VARCHAR2(2000);
    l_select_for_desc VARCHAR2(2000);
    l_order_by_name VARCHAR2(2000);
    l_order_by_desc VARCHAR2(2000);

    TYPE var_cur_item IS REF CURSOR;
    l_get_items var_cur_item;

    l_party_id  NUMBER;
    l_org_id    NUMBER;
    l_clvl_id   NUMBER ;
    l_customer_id VARCHAR2(10);
    l_clvl_filter  VARCHAR2(15);
    l_id        NUMBER;
    l_prod_tbl  prod_tbl;
    l_price     NUMBER;
    l_default   VARCHAR2(15);
    rowcount    NUMBER := 1;
    l_prod_selections_tbl prod_selections_tbl;
    l_cust_id_tbl         cust_id_tbl;
    l_party_id_tbl        party_id_tbl;
    cust_count  NUMBER := 1;
    l_organization_id     NUMBER;
    l_display_pref        VARCHAR2(25);
    l_config_parent_id    NUMBER :=  - 99 ;
    l_name                VARCHAR2(500);

    l_get_all_systems_sql_c  VARCHAR2(2000);
    l_get_all_systems_sql_r  VARCHAR2(2000);
    l_get_all_systems_sql_b  VARCHAR2(2000);
    l_get_all_systems_sql_a  VARCHAR2(2000);

    l_get_all_sites_sql_c  VARCHAR2(2000);
    l_get_all_sites_sql_r  VARCHAR2(2000);
    l_get_all_sites_sql_b  VARCHAR2(2000);
    l_get_all_sites_sql_a  VARCHAR2(2000);

    l_chk_id_flag      VARCHAR2(1) := 'N' ;
    id_counter         NUMBER := 1;
    l_cust_id_list      VARCHAR2(500);

    k                     NUMBER := 1;
    j   NUMBER := 1;
    start_sort NUMBER := 1;
    l_prod_tbl_sort  prod_tbl  ;
    l_inv_id   NUMBER ;
    l_old_inv_id NUMBER :=  - 99;
    l_gen_name           VARCHAR2(2000);
    l_gen_desc           VARCHAR2(2000);
    l_tmp_prod_tbl      prod_tbl;


    BEGIN

        l_default := p_clvl_filter_rec.clvl_default;
        l_party_id := p_clvl_filter_rec.clvl_party_id;
        l_org_id := p_clvl_filter_rec.clvl_auth_org_id;
        l_clvl_id := p_clvl_filter_rec.clvl_find_id;
        l_clvl_filter := p_clvl_filter_rec.clvl_filter;
        l_organization_id := p_clvl_filter_rec.clvl_organization_id;
        l_display_pref := p_clvl_filter_rec.clvl_display_pref;


        g_serial_number := p_clvl_filter_rec.lbl_serial_number;
        g_quantity := p_clvl_filter_rec.lbl_quantity;
        g_price := p_clvl_filter_rec.lbl_price;
        g_installed_at := p_clvl_filter_rec.lbl_installed_at;
        g_ref := p_clvl_filter_rec.lbl_ref;

        --IF l_default IN ('CUSTOMER','RELATED','BOTH') THEN

        IF l_clvl_filter <> 'Party' THEN  /* if filter is Party then party id and name should be fetched */


            IF l_clvl_filter = 'Item' THEN

                /*CURSOR l_csr_item_name_cust(p_party_id IN NUMBER, l_organization_id IN NUMBER)
                IS
                select inventory_item_id, concatenated_segments name  ,  description description */

                l_select_for_name := 'select inventory_item_id, concatenated_segments name  ,  description description ';
                l_select_for_desc := 'select inventory_item_id,   description description , concatenated_segments name  ';



                l_order_by_name := ' order by name ' ;

                l_order_by_desc := ' order by description ';

                l_item_cust := ' from mtl_system_items_kfv  '
                ||' where inventory_item_id in ( select inventory_item_id from csi_item_instances  '
                ||' where owner_party_account_id in (select id1  '
                ||'  FROM okx_customer_accounts_v '
                ||'  WHERE party_id = :l_party_id)) '
                ||' and organization_id = :l_organization_id '
                ||' and serviceable_product_flag = ''Y''';

                l_item_rel := ' FROM  mtl_system_items_kfv  '
                ||' where inventory_item_id in ( select inventory_item_id from csi_item_instances  '
                ||' where owner_party_account_id in   (select A.RELATED_CUST_ACCOUNT_ID  '
                ||' FROM   OKX_CUST_ACCT_RELATE_ALL_V A,  '
                ||'        OKX_CUSTOMER_ACCOUNTS_V  B  '
                ||' WHERE  B.ID1 = A.CUST_ACCOUNT_ID  '
                ||' AND    B.party_id =  :l_party_id '
                ||' AND    B.status = ''A'''
                ||' AND    A.status = ''A'''
                ||' AND    A.org_id =  :l_org_id '
                ||' )) '
                ||' and organization_id = :l_organization_id '
                ||' and serviceable_product_flag = ''Y''';

                l_item_both := ' from mtl_system_items_kfv '
                ||' where inventory_item_id in ( select inventory_item_id from csi_item_instances  '
                ||' where owner_party_account_id in  (select id1  '
                ||' FROM okx_customer_accounts_v '
                ||' WHERE party_id = :p_party_id '
                ||' UNION '
                ||' select A.RELATED_CUST_ACCOUNT_ID  '
                ||' FROM   OKX_CUST_ACCT_RELATE_ALL_V A,  '
                ||' OKX_CUSTOMER_ACCOUNTS_V  B  '
                ||' WHERE  B.ID1 = A.CUST_ACCOUNT_ID '
                ||' AND    B.party_id =  :l_party_id '
                ||' AND    B.status = ''A'''
                ||' AND    A.status = ''A'''
                ||' AND    A.org_id =  :l_org_id '
                ||' )) '
                ||' and organizatioN_id = :l_organization_id '
                ||' and serviceable_product_flag = ''Y''';

                l_item_all := ' from mtl_system_items_kfv '
                ||' where organizatioN_id = :l_organization_id '
                ||' and serviceable_product_flag = ''Y''';

                IF l_clvl_id IS NULL THEN
                    /* Select all Items for given party first */
                    IF l_default = 'CUSTOMER' THEN
                        IF l_display_pref = 'NAME' THEN
                            l_item_cust := l_select_for_name ||' '|| l_item_cust ||' '|| l_order_by_name;
                        ELSE
                            l_item_cust := l_select_for_desc ||' '|| l_item_cust ||' '|| l_order_by_desc;
                        END IF;
                        --------------------------------------------------------errorout_an(' item customer '||l_item_cust);

                        OPEN l_get_items FOR l_item_cust USING l_party_id, l_organization_id;
                    ELSIF l_default = 'RELATED' THEN
                        IF l_display_pref = 'NAME' THEN
                            l_item_rel := l_select_for_name ||' '|| l_item_rel ||' '|| l_order_by_name;
                        ELSE
                            l_item_rel := l_select_for_desc ||' '|| l_item_rel ||' '|| l_order_by_desc;
                        END IF;
                        --             ----------------------errorout_an(' item rel '||l_item_rel);
                        --             ----------------------errorout_an(' party '||l_party_id||' org id '||l_org_id||' '||l_organization_id);
                        OPEN l_get_items FOR l_item_rel USING l_party_id, l_org_id, l_organization_id;
                    ELSIF l_default = 'BOTH' THEN
                        IF l_display_pref = 'NAME' THEN
                            l_item_both := l_select_for_name ||' '|| l_item_both ||' '|| l_order_by_name;
                        ELSE
                            l_item_both := l_select_for_desc ||' '|| l_item_both ||' '|| l_order_by_desc;
                        END IF;
                        OPEN l_get_items FOR l_item_both USING l_party_id, l_party_id, l_org_id, l_organization_id;
                        --------------------------------------------------------errorout_an(' item both '||l_item_both);
                    ELSIF l_default = 'ALL' THEN
                        IF l_display_pref = 'NAME' THEN
                            l_item_all := l_select_for_name ||' '|| l_item_all ||' '|| l_order_by_name;
                        ELSE
                            l_item_all := l_select_for_desc ||' '|| l_item_all ||' '|| l_order_by_desc;
                        END IF;
                        OPEN l_get_items FOR l_item_all USING l_organization_id;
                        --------------------------------------------------------errorout_an(' item all '||l_item_all);
                    END IF;


                    /* Find cp id in the record group */

                    LOOP
                        ------errorout_an(' in loop ');
                        FETCH l_get_items INTO l_items_rec ;
                        IF l_get_items%NOTFOUND THEN
                            EXIT;
                        ELSE
                            ------errorout_an(' before get prod ');

                            get_products(l_clvl_filter,
                                         l_items_rec.inventory_item_id,
                                         l_default,
                                         l_cust_id_list,
                                         l_party_id,
                                         l_org_id,
                                         l_organization_id,
                                         l_prod_tbl);

                            IF l_prod_tbl.COUNT > 0 THEN

                                x_prod_selections_tbl(rowcount).cp_id := l_items_rec.inventory_item_id;
                                x_prod_selections_tbl(rowcount).name := l_items_rec.name;
                                x_prod_selections_tbl(rowcount).description := l_items_rec.description;

                                IF l_display_pref = 'DISPLAY_NAME' THEN
                                    l_name := rpad(l_items_rec.name, 30, ' ') || rpad(l_items_rec.description, 40,' ');
                                ELSIF l_display_pref = 'DISPLAY_DESC' THEN
                                    l_name := rpad(l_items_rec.description, 30, ' ') || rpad(l_items_rec.name, 40,' ');
                                END IF;

                                x_prod_selections_tbl(rowcount).name := l_name;
                                x_prod_selections_tbl(rowcount).rec_type := 'P';
                                x_prod_selections_tbl(rowcount).rec_name := 'Item';
                                x_prod_selections_tbl(rowcount).rec_no := rowcount;
                                x_prod_selections_tbl(rowcount).cp_id2 := '';
                                x_prod_selections_tbl(rowcount).ser_number := '';
                                x_prod_selections_tbl(rowcount).ref_number := '' ;
                                x_prod_selections_tbl(rowcount).quantity := '';
                                x_prod_selections_tbl(rowcount).orig_net_amt := '';
                                x_prod_selections_tbl(rowcount).price := '';
                                x_prod_selections_tbl(rowcount).inventory_item_id := '';
                                x_prod_selections_tbl(rowcount).site_id := '';
                                x_prod_selections_tbl(rowcount).uom_code := '';
                                x_prod_selections_tbl(rowcount).display_name := '';
                                x_prod_selections_tbl(rowcount).site_name := '';
                                -- GCHADHA --
                                -- BUG 4372877 --
                                -- 5/25/2005 --
                                x_prod_selections_tbl(rowcount).ext_reference := '';
                                -- END GCHADHA --

                                rowcount := rowcount + 1;

                                /* Populate child records  */

                                populate_table (l_prod_tbl,
                                                l_clvl_filter,
                                                rowcount,
                                                l_display_pref,
                                                x_prod_selections_tbl);

                                rowcount := rowcount + 1;
                            END IF;

                        END IF ; /* End of ITems cursor */
                        --     ------------------------------------------errorout_an(' out of cursors ');
                    END LOOP; /* End of Cursor Loop */


                ELSIF l_clvl_id IS NOT NULL THEN

                    get_products(l_clvl_filter,
                                 l_clvl_id,
                                 l_default,
                                 l_cust_id_list,
                                 l_party_id,
                                 l_org_id,
                                 l_organization_id,
                                 l_prod_tbl);


                    IF l_prod_tbl.COUNT > 0 THEN
                        /* Populate parent records */
                        x_prod_selections_tbl(rowcount).cp_id := l_clvl_id;

                        l_name := rpad(p_clvl_filter_rec.clvl_name, 30,' ') || rpad(p_clvl_filter_rec.clvl_description, 40,' ');
                        x_prod_selections_tbl(rowcount).name := rpad(p_clvl_filter_rec.clvl_name, 30,' ') || rpad(p_clvl_filter_rec.clvl_description, 40,' ');
                        x_prod_selections_tbl(rowcount).description := p_clvl_filter_rec.clvl_description;
                        x_prod_selections_tbl(rowcount).rec_type := 'P';
                        x_prod_selections_tbl(rowcount).rec_name := 'Item';
                        x_prod_selections_tbl(rowcount).rec_no := rowcount;
                        x_prod_selections_tbl(rowcount).cp_id2 := '';
                        x_prod_selections_tbl(rowcount).ser_number := '';
                        x_prod_selections_tbl(rowcount).ref_number := '' ;
                        x_prod_selections_tbl(rowcount).quantity := '';
                        x_prod_selections_tbl(rowcount).orig_net_amt := '';
                        x_prod_selections_tbl(rowcount).price := '';
                        x_prod_selections_tbl(rowcount).inventory_item_id := '';
                        x_prod_selections_tbl(rowcount).site_id := '';
                        x_prod_selections_tbl(rowcount).uom_code := '';
                        x_prod_selections_tbl(rowcount).display_name := '';
                        x_prod_selections_tbl(rowcount).site_name := '';
                        -- BUG 4372877 --
                        -- GCHADHA --
                        -- 5/25/2005 --
                        x_prod_selections_tbl(rowcount).ext_reference := '';
                        -- END GCHADHA --


                        rowcount := rowcount + 1;

                        populate_table (l_prod_tbl,
                                        l_clvl_filter,
                                        rowcount,
                                        l_display_pref,
                                        x_prod_selections_tbl);


                    END IF;

                END IF;

            ELSIF  l_clvl_filter = 'System' THEN
                IF  l_clvl_id IS NULL THEN

                    /** Setting up dynamic cursor for Systems **/


                    -- Bug 5041892 --
                    l_get_all_systems_sql_c := ' SELECT CSB.system_Id Id1 , CST.name name , CST.description description '
                    || ' FROM   CSI_SYSTEMS_B   CSB, '
                    || '        CSI_SYSTEMS_TL  CST '
                    || ' WHERE  CSB.system_id = CST.system_id  '
                    || ' AND    CSB.system_id IN  (Select CII.system_id '
                    || ' From   CSI_ITEM_INSTANCES CII, '
                    || '        CSI_INSTANCE_STATUSES  CIS '
                    || '       , MTL_SYSTEM_ITEMS_B IT '
                    || ' WHERE IT.inventory_item_id = CII.inventory_item_id '
                    || ' AND   IT.serviceable_product_flag = ''Y'''
                    || ' AND   IT.organization_id = :l_organization_id '
                    || ' AND  CII.owner_party_account_id in (select cust_account_id '
                    ||' from hz_cust_accounts '
                    ||' where party_id =  :p_party_id ) '
                    || ' And    CIS.instance_status_id = CII.instance_status_id '
                    || ' And    CIS.service_order_allowed_flag = ''Y'''
                    || ' And    sysdate between Nvl(CIS.start_date_active, sysdate) and  Nvl(CIS.end_date_active, sysdate) '
                    || ' And    CII.system_id is not null ) '
                    || ' And    sysdate between Nvl(CSB.start_date_active, sysdate) and   Nvl(CSB.end_date_active, sysdate) '
                    || ' Order by CST.name ';


                    -- Bug 5041892 --
                    l_get_all_systems_sql_b := ' SELECT CSB.system_Id Id1 , CST.name name , CST.description description '
                    || ' FROM   CSI_SYSTEMS_B   CSB, '
                    || '        CSI_SYSTEMS_TL  CST '
                    || ' WHERE  CSB.system_id = CST.system_id  '
                    || ' AND    CSB.system_id IN  '
                    ||' (SELECT CII.system_id '
                    ||'  FROM   CSI_ITEM_INSTANCES CII, '
                    ||'         CSI_INSTANCE_STATUSES  CIS '
                    ||'       , MTL_SYSTEM_ITEMS_B IT '
                    || ' WHERE IT.inventory_item_id = CII.inventory_item_id '
                    || ' AND   IT.serviceable_product_flag = ''Y'''
                    || ' AND   IT.organization_id = :l_organization_id '
                    || ' AND   CII.owner_party_account_id in (select cust_account_id '
                    ||' from HZ_CUST_ACCOUNTS '
                    ||' where party_id =  :p_party_id  '
                    ||' UNION ALL'
                    ||'  select A.RELATED_CUST_ACCOUNT_ID '
                    ||'   FROM   HZ_CUST_ACCT_RELATE_ALL A, '
                    ||'          HZ_CUST_ACCOUNTS  B '
                    ||'   WHERE  B.cust_account_id = A.CUST_ACCOUNT_ID '
                    ||'   AND    B.party_id =   :p_party_id '
                    ||'   AND    B.status = ''A'''
                    ||'   AND    A.status = ''A'''
                    ||'   AND    A.org_id =  :p_org_id '
                    ||'  ) '
                    || ' And    CIS.instance_status_id = CII.instance_status_id '
                    || ' And    CIS.service_order_allowed_flag = ''Y'''
                    || ' And    sysdate between Nvl(CIS.start_date_active, sysdate) and  Nvl(CIS.end_date_active, sysdate) '
                    || ' And    CII.system_id is not null ) '
                    || ' And    sysdate between Nvl(CSB.start_date_active, sysdate) and   Nvl(CSB.end_date_active, sysdate) '
                    || ' Order by CST.name ';

                    -- Bug 5041892 --
                    l_get_all_systems_sql_r := ' SELECT CSB.system_Id Id1 , CST.name name , CST.description description '
                    || ' FROM   CSI_SYSTEMS_B   CSB, '
                    || '        CSI_SYSTEMS_TL  CST '
                    || ' WHERE  CSB.system_id = CST.system_id  '
                    || ' AND    CSB.system_id IN  (Select CII.system_id '
                    || ' From  CSI_ITEM_INSTANCES CII, '
                    || '       CSI_INSTANCE_STATUSES  CIS '
                    ||' ,       MTL_SYSTEM_ITEMS_B IT '
                    || ' WHERE IT.inventory_item_id = CII.inventory_item_id '
                    || ' AND   IT.serviceable_product_flag = ''Y'''
                    || ' AND   IT.organization_id = :l_organization_id '
                    || ' AND   CII.owner_party_account_id in  '
                    ||'  (select A.RELATED_CUST_ACCOUNT_ID '
                    ||'   FROM   HZ_CUST_ACCT_RELATE_ALL A, '
                    ||'          HZ_CUST_ACCOUNTS  B '
                    ||'   WHERE  B.cust_account_id = A.CUST_ACCOUNT_ID '
                    ||'   AND    B.party_id =   :p_party_id '
                    ||'   AND    B.status = ''A'''
                    ||'   AND    A.status = ''A'''
                    ||'   AND    A.org_id =  :p_org_id '
                    ||'  ) '
                    || ' And    CIS.instance_status_id = CII.instance_status_id '
                    || ' And    CIS.service_order_allowed_flag = ''Y'''
                    || ' And    sysdate between Nvl(CIS.start_date_active, sysdate) and  Nvl(CIS.end_date_active, sysdate) '
                    || ' And    system_id is not null ) '
                    || ' And    sysdate between Nvl(CSB.start_date_active, sysdate) and   Nvl(CSB.end_date_active, sysdate) '
                    || ' Order by CST.name ';


                    l_get_all_systems_sql_a := ' SELECT CSB.system_Id Id1 , CST.name name , CST.description description '
                    || ' FROM   CSI_SYSTEMS_B   CSB, '
                    || '        CSI_SYSTEMS_TL  CST '
                    || ' WHERE  CSB.system_id = CST.system_id  '
                    || ' AND    CSB.system_id IN  (Select CII.system_id '
                    || ' From   CSI_ITEM_INSTANCES CII, '
                    || '        CSI_INSTANCE_STATUSES  CIS '
                    ||' ,       MTL_SYSTEM_ITEMS_B IT '
                    || ' WHERE IT.inventory_item_id = CII.inventory_item_id '
                    || ' AND   IT.serviceable_product_flag = ''Y'''
                    || ' AND   IT.organization_id = :l_organization_id '
                    || ' AND   CIS.instance_status_id = CII.instance_status_id '
                    || ' And   CIS.service_order_allowed_flag = ''Y'''
                    || ' And   sysdate between Nvl(CIS.start_date_active, sysdate) and  Nvl(CIS.end_date_active, sysdate) '
                    || ' And   CII.system_id is not null ) '
                    || ' And    sysdate between Nvl(CSB.start_date_active, sysdate) and   Nvl(CSB.end_date_active, sysdate) '
                    || ' Order by CST.name ';

                    /* Select all Items for given party first */

                    IF l_default = 'CUSTOMER' THEN
                        ------------------------------errorout_an(l_get_all_systems_sql_c);
                        l_get_all_systems_sql := l_get_all_systems_sql_c;
                        OPEN l_csr_get_all_systems FOR l_get_all_systems_sql USING l_organization_id, l_party_id;
                    ELSIF l_default = 'RELATED' THEN
                        ------------------------------errorout_an(l_get_all_systems_sql_r);
                        l_get_all_systems_sql := l_get_all_systems_sql_r;
                        OPEN l_csr_get_all_systems FOR l_get_all_systems_sql USING l_organization_id, l_party_id, l_org_id;
                    ELSIF l_default = 'BOTH' THEN
                        ------------------------------errorout_an(l_get_all_systems_sql_b);
                        l_get_all_systems_sql := l_get_all_systems_sql_b;
                        OPEN l_csr_get_all_systems FOR l_get_all_systems_sql USING l_organization_id, l_party_id, l_party_id, l_org_id ;
                    ELSIF l_default = 'ALL' THEN
                        ------------------------------errorout_an(l_get_all_systems_sql_b);
                        l_get_all_systems_sql := l_get_all_systems_sql_a;
                        OPEN l_csr_get_all_systems FOR l_get_all_systems_sql USING l_organization_id ;
                    END IF;


                    LOOP
                        FETCH l_csr_get_all_systems INTO l_get_all_systems_rec;
                        IF l_csr_get_all_systems%NOTFOUND THEN
                            CLOSE l_csr_get_all_systems;
                            EXIT;
                        END IF;

                        l_id := l_get_all_systems_rec.id1;

                        FOR  id_counter IN 1 .. x_prod_selections_tbl.COUNT LOOP
                            IF x_prod_selections_tbl(id_counter).rec_type = 'P' THEN

                                IF x_prod_selections_tbl(id_counter).cp_id = l_id THEN
                                    l_chk_id_flag := 'Y';
                                    EXIT;
                                ELSE
                                    l_chk_id_flag := 'N';
                                END IF;
                            END IF;
                        END LOOP;

                        IF l_chk_id_flag = 'N' THEN

                            get_products(l_clvl_filter,
                                         l_id,
                                         l_default,
                                         l_cust_id_list,
                                         l_party_id,
                                         l_org_id,
                                         l_organization_id,
                                         l_prod_tbl);

                            IF l_prod_tbl.COUNT > 0 THEN

                                x_prod_selections_tbl(rowcount).cp_id := l_get_all_systems_rec.id1;
                                l_name := rpad(l_get_all_systems_rec.name, 30, ' ') || rpad(l_get_all_systems_rec.description, 40,' ');
                                x_prod_selections_tbl(rowcount).name := l_name;
                                x_prod_selections_tbl(rowcount).description := l_get_all_systems_rec.description;
                                x_prod_selections_tbl(rowcount).rec_type := 'P';
                                x_prod_selections_tbl(rowcount).rec_name := 'System';
                                x_prod_selections_tbl(rowcount).rec_no := rowcount;
                                x_prod_selections_tbl(rowcount).cp_id2 := '';
                                x_prod_selections_tbl(rowcount).ser_number := '';
                                x_prod_selections_tbl(rowcount).ref_number := '' ;
                                x_prod_selections_tbl(rowcount).quantity := '';
                                x_prod_selections_tbl(rowcount).orig_net_amt := '';
                                x_prod_selections_tbl(rowcount).price := '';
                                x_prod_selections_tbl(rowcount).inventory_item_id := '';
                                x_prod_selections_tbl(rowcount).site_id := '';
                                x_prod_selections_tbl(rowcount).uom_code := '';
                                x_prod_selections_tbl(rowcount).display_name := '';
                                x_prod_selections_tbl(rowcount).site_name := '';
                                -- BUG 4372877 --
                                -- GCHADHA --
                                -- 5/25/2005 --
                                x_prod_selections_tbl(rowcount).ext_reference := '';
                                -- END GCHADHA --


                                rowcount := rowcount + 1;

                                populate_table (l_prod_tbl,
                                                l_clvl_filter,
                                                rowcount,
                                                l_display_pref,
                                                x_prod_selections_tbl);

                                rowcount := rowcount + 1;
                            END IF;
                        END IF;
                    END LOOP;

                ELSIF l_clvl_id IS NOT NULL THEN


                    get_products(l_clvl_filter,
                                 l_clvl_id,
                                 l_default,
                                 l_cust_id_list,
                                 l_party_id,
                                 l_org_id,
                                 l_organization_id,
                                 l_prod_tbl);


                    IF l_prod_tbl.COUNT > 0 THEN
                        -- Populate parent record in table, only if products exist
                        x_prod_selections_tbl(rowcount).cp_id := l_clvl_id;
                        l_name := rpad(p_clvl_filter_rec.clvl_name, 30,' ') || rpad(p_clvl_filter_rec.clvl_description, 40,' ');

                        x_prod_selections_tbl(rowcount).name := l_name;
                        x_prod_selections_tbl(rowcount).description := p_clvl_filter_rec.clvl_description;
                        x_prod_selections_tbl(rowcount).rec_type := 'P';
                        x_prod_selections_tbl(rowcount).rec_name := 'System';
                        x_prod_selections_tbl(rowcount).rec_no := rowcount;
                        x_prod_selections_tbl(rowcount).cp_id2 := '';
                        x_prod_selections_tbl(rowcount).ser_number := '';
                        x_prod_selections_tbl(rowcount).ref_number := '' ;
                        x_prod_selections_tbl(rowcount).quantity := '';
                        x_prod_selections_tbl(rowcount).orig_net_amt := '';
                        x_prod_selections_tbl(rowcount).price := '';
                        x_prod_selections_tbl(rowcount).inventory_item_id := '';
                        x_prod_selections_tbl(rowcount).site_id := '';
                        x_prod_selections_tbl(rowcount).uom_code := '';
                        x_prod_selections_tbl(rowcount).display_name := '';
                        x_prod_selections_tbl(rowcount).site_name := '';
                        -- BUG 4372877 --
                        -- GCHADHA --
                        -- 5/25/2005 --
                        x_prod_selections_tbl(rowcount).ext_reference := '';
                        -- END GCHADHA --

                        rowcount := rowcount + 1;

                        populate_table (l_prod_tbl,
                                        l_clvl_filter,
                                        rowcount,
                                        l_display_pref,
                                        x_prod_selections_tbl);


                    END IF;
                END IF;

            ELSIF  l_clvl_filter = 'Site' THEN
                IF  l_clvl_id IS NULL THEN
                    /* Select all Items for given party first */
		    -- Bug 5004778 --
	            -- Modified Query to reduce shared memory Usage
		    -- Replaced views to base tables where ever possible
                    l_get_all_sites_sql_c := ' SELECT  SI.Id1 id1 , SI.name name , SI.Party_Site_Number party_site_number , SI.description description '
                    || ' FROM    OKX_PARTY_SITES_V   SI '
                    || ' WHERE  exists   (SELECT CII.install_location_Id '
                    ||'  FROM   CSI_ITEM_INSTANCES CII, '
                    ||'         CSI_INSTANCE_STATUSES   CIS, '
                    ||'         MTL_SYSTEM_ITEMS_B IT '
                    ||'  WHERE IT.inventory_item_id = CII.inventory_item_id '
                    ||'  AND   IT.serviceable_product_flag = ''Y'''
                    ||'  AND   IT.organization_id = :l_organization_id '
                    ||'  AND   CII.install_location_id = SI.id1 '
                    ||'  AND   CII.owner_party_account_id in '
                    ||'(select cust_account_id '
                    ||' from hz_cust_accounts '
                    ||' where party_id =  :p_party_id ) '
                    ||'        And    CIS.instance_Status_id = CII.instance_status_id '
                    ||'        And    CIS.service_order_allowed_flag = ''Y'''
                    ||'        And    sysdate between Nvl(CIS.start_date_active, sysdate) and '
                    ||'                               Nvl(CIS.end_date_active, sysdate)) '
                    -- TCA Changes --
                    /*  ||'        And    sysdate between Nvl(SI.start_date_active, sysdate) and '
                    ||'                               Nvl(SI.end_date_active, sysdate) '  */
                    || 'AND SI.STATUS = ''A'''
                    -- TCA Changes --
                    ||' ORDER BY si.party_site_number, si.name ';

		    -- Bug 5004778 --
		    -- Modified Query to reduce shared memory Usage
		    -- Replaced views to base tables where ever possible
                    l_get_all_sites_sql_r := ' SELECT  SI.Id1 id1 , SI.name name , SI.Party_Site_Number party_site_number , SI.description description '
                    || ' FROM    OKX_PARTY_SITES_V   SI '
                    || ' WHERE  exists  (SELECT CII.install_location_Id '
                    ||'   FROM   CSI_ITEM_INSTANCES CII, '
                    ||'          CSI_INSTANCE_STATUSES   CIS '
                    ||' ,        MTL_SYSTEM_ITEMS_B IT '
                    ||'   WHERE IT.inventory_item_id = CII.inventory_item_id '
                    ||'   AND   IT.serviceable_product_flag = ''Y'''
                    ||'   AND   IT.organization_id = :l_organization_id '
                    ||'   AND   CII.install_location_id = SI.id1 '
                    ||'   AND   CII.owner_party_account_id in '
                    ||'  (select A.RELATED_CUST_ACCOUNT_ID '
                    ||'   FROM   HZ_CUST_ACCT_RELATE_ALL A, '
                    ||'          HZ_CUST_ACCOUNTS  B '
                    ||'   WHERE  B.cust_account_id = A.CUST_ACCOUNT_ID '
                    ||'   AND    B.party_id =   :l_party_id '
                    ||'   AND    B.status = ''A'''
                    ||'   AND    A.status = ''A'''
                    ||'   AND    A.org_id =  :p_org_id '
                    ||'  ) '
                    ||'        And    CIS.instance_Status_id = CII.instance_status_id '
                    ||'        And    CIS.service_order_allowed_flag = ''Y'''
                    ||'        And    sysdate between Nvl(CIS.start_date_active, sysdate) and '
                    ||'                               Nvl(CIS.end_date_active, sysdate)) '
                    -- TCA Changes --
                    /* ||'        And    sysdate between Nvl(SI.start_date_active, sysdate) and '
                    ||'                               Nvl(SI.end_date_active, sysdate) '  */
                    || 'AND SI.STATUS = ''A'''
                    -- TCA Changes --
                    ||' ORDER BY si.party_site_number, si.name ';

		    -- Bug 5004778 --
		    -- Modified Query to reduce shared memory Usage
		    -- Replaced views to base tables where ever possible
                    l_get_all_sites_sql_b := ' SELECT  SI.Id1 id1 , SI.name name , SI.Party_Site_Number party_site_number , SI.description description '
                    || ' FROM    OKX_PARTY_SITES_V   SI '
                    || ' WHERE  exists   (SELECT CII.install_location_Id '
                    || '   FROM   CSI_ITEM_INSTANCES CII, '
                    ||'           CSI_INSTANCE_STATUSES   CIS '
                    ||'  ,        MTL_SYSTEM_ITEMS_B IT '
                    ||'   WHERE IT.inventory_item_id = CII.inventory_item_id '
                    ||'   AND   IT.serviceable_product_flag = ''Y'''
                    ||'   AND   IT.organization_id = :l_organization_id '
                    ||'   AND     CII.install_location_id = SI.id1 '
                    ||'  AND    CII.owner_party_account_id in '
                    ||' (select cust_account_id '
                    ||' from hz_cust_accounts '
                    ||' where party_id =  :p_party_id  '
                    ||' UNION '
                    ||'  select  A.RELATED_CUST_ACCOUNT_ID '
                    ||'   FROM   HZ_CUST_ACCT_RELATE_ALL A, '
                    ||'          HZ_CUST_ACCOUNTS  B '
                    ||'   WHERE  B.cust_account_id = A.CUST_ACCOUNT_ID '
                    ||'   AND    B.party_id =   :p_party_id '
                    ||'   AND    B.status = ''A'''
                    ||'   AND    A.status = ''A'''
                    ||'   AND    A.org_id =  :p_org_id '
                    ||'  ) '
                    ||'        And    CIS.instance_Status_id = CII.instance_status_id '
                    ||'        And    CIS.service_order_allowed_flag = ''Y'''
                    ||'        And    sysdate between Nvl(CIS.start_date_active, sysdate) and '
                    ||'                               Nvl(CIS.end_date_active, sysdate)) '
                    -- TCA Changes --
                    /* ||'        And    sysdate between Nvl(SI.start_date_active, sysdate) and '
                    ||'                               Nvl(SI.end_date_active, sysdate) '  */
                    || 'AND SI.STATUS = ''A'''
                    -- TCA Changes --
                    ||' ORDER BY si.party_site_number, si.name ';
		    -- Bug 5004778 --

                    l_get_all_sites_sql_a := ' SELECT  SI.Id1 id1 , SI.name name , SI.Party_Site_Number party_site_number , SI.description description '
                    || ' FROM    OKX_PARTY_SITES_V   SI '
                    || ' WHERE  exists   (SELECT CII.install_location_Id '
                    || '   FROM   CSI_ITEM_INSTANCES CII, '
                    ||'           CSI_INSTANCE_STATUSES   CIS '
                    ||'  ,        MTL_SYSTEM_ITEMS_KFV IT '
                    ||'   WHERE IT.inventory_item_id = CII.inventory_item_id '
                    ||'   AND   IT.serviceable_product_flag = ''Y'''
                    ||'   AND   IT.organization_id = :l_organization_id '
                    ||'   AND   CII.install_location_id = SI.id1 '
                    ||'   AND   CIS.instance_Status_id = CII.instance_status_id '
                    ||'        And    CIS.service_order_allowed_flag = ''Y'''
                    ||'        And    sysdate between Nvl(CIS.start_date_active, sysdate) and '
                    ||'                               Nvl(CIS.end_date_active, sysdate)) '
                    -- TCA Changes --
                    /* ||'        And    sysdate between Nvl(SI.start_date_active, sysdate) and '
                    ||'                               Nvl(SI.end_date_active, sysdate) '  */
                    || 'AND SI.STATUS = ''A''';
                    -- TCA Changes --


                    IF l_default = 'CUSTOMER' THEN
                        l_get_all_sites_sql := l_get_all_sites_sql_c;
                        --          ----------------------errorout_an(' get sites info cust '||l_get_all_sites_sql);
                        OPEN l_csr_get_all_sites  FOR l_get_all_sites_sql USING l_organization_id, l_party_id;
                    ELSIF l_default = 'RELATED' THEN
                        l_get_all_sites_sql := l_get_all_sites_sql_r;
                        --          ----------------------errorout_an(' get sites info rel '||l_get_all_sites_sql||' '||l_party_id||' '||l_org_id);
                        OPEN l_csr_get_all_sites  FOR l_get_all_sites_sql USING l_organization_id, l_party_id, l_org_id;
                    ELSIF l_default = 'BOTH' THEN
                        l_get_all_sites_sql := l_get_all_sites_sql_b;
                        --          ----------------------errorout_an(' get sites info both '||l_get_all_sites_sql);
                        OPEN l_csr_get_all_sites  FOR l_get_all_sites_sql USING l_organization_id, l_party_id, l_party_id, l_org_id;
                    ELSIF l_default = 'ALL' THEN
                        l_get_all_sites_sql := l_get_all_sites_sql_a;
                        --          ----------------------errorout_an(' get sites info both '||l_get_all_sites_sql);
                        OPEN l_csr_get_all_sites  FOR l_get_all_sites_sql USING l_organization_id;

                    END IF;


                    --         OPEN l_csr_get_all_sites  FOR l_get_all_sites_sql USING l_party_id;
                    LOOP         FETCH l_csr_get_all_sites INTO l_get_all_sites_rec;
                        IF l_csr_get_all_sites%NOTFOUND THEN
                            CLOSE l_csr_Get_all_sites;
                            EXIT;
                        END IF;

                        l_id := l_get_all_sites_rec.id1;

                        FOR  id_counter IN 1 .. x_prod_selections_tbl.COUNT LOOP
                            IF x_prod_selections_tbl(id_counter).rec_type = 'P' THEN

                                IF x_prod_selections_tbl(id_counter).cp_id = l_id THEN
                                    l_chk_id_flag := 'Y';
                                    EXIT;
                                ELSE
                                    l_chk_id_flag := 'N';
                                END IF;
                            END IF;
                        END LOOP;


                        IF l_chk_id_flag = 'N' THEN
                            get_products(l_clvl_filter,
                                         l_id,
                                         l_default,
                                         l_cust_id_list,
                                         l_party_id,
                                         l_org_id,
                                         l_organization_id,
                                         l_prod_tbl);

                            IF l_prod_tbl.COUNT > 0 THEN

                                x_prod_selections_tbl(rowcount).cp_id := l_get_all_sites_rec.id1;

                                --l_name := rpad(l_get_all_sites_rec.party_site_number || '-' || l_get_all_sites_rec.name, 30) || rpad(p_clvl_filter_rec.clvl_description, 40,' ');

                                --bug 5243637 (forward port for bug 5221204/2749830)
                                l_name := rpad(l_get_all_sites_rec.party_site_number||'-'||l_get_all_sites_rec.name,30)
                                ||' '||rpad(l_get_all_sites_rec.description,40,' ');

                                x_prod_selections_tbl(rowcount).name := l_name;
                                x_prod_selections_tbl(rowcount).description := l_get_all_sites_rec.description;
                                x_prod_selections_tbl(rowcount).rec_type := 'P';
                                x_prod_selections_tbl(rowcount).rec_name := 'Site';
                                x_prod_selections_tbl(rowcount).rec_no := rowcount;
                                x_prod_selections_tbl(rowcount).cp_id2 := '';
                                x_prod_selections_tbl(rowcount).ser_number := '';
                                x_prod_selections_tbl(rowcount).ref_number := '' ;
                                x_prod_selections_tbl(rowcount).quantity := '';
                                x_prod_selections_tbl(rowcount).orig_net_amt := '';
                                x_prod_selections_tbl(rowcount).price := '';
                                x_prod_selections_tbl(rowcount).inventory_item_id := '';
                                x_prod_selections_tbl(rowcount).site_id := '';
                                x_prod_selections_tbl(rowcount).uom_code := '';
                                x_prod_selections_tbl(rowcount).display_name := '';
                                x_prod_selections_tbl(rowcount).site_name := '';
                                -- BUG 4372877 --
                                -- GCHADHA --
                                -- 5/25/2005 --
                                x_prod_selections_tbl(rowcount).ext_reference := '';
                                -- END GCHADHA --


                                rowcount := rowcount + 1;

                                populate_table (l_prod_tbl,
                                                l_clvl_filter,
                                                rowcount,
                                                l_display_pref,
                                                x_prod_selections_tbl);

                                -- BUG 4113113 --
                                -- GCHADHA --
                                rowcount := rowcount + 1;
                                -- END GCHADHA --
                            END IF;
                        END IF;
                    END LOOP;
                ELSIF l_clvl_id IS NOT NULL THEN

                    get_products(l_clvl_filter,
                                 l_clvl_id,
                                 l_default,
                                 l_cust_id_list,
                                 l_party_id,
                                 l_org_id,
                                 l_organization_id,
                                 l_prod_tbl);

                    IF l_prod_tbl.COUNT > 0 THEN

                        x_prod_selections_tbl(rowcount).cp_id := l_clvl_id;
                        l_name := rpad(p_clvl_filter_rec.clvl_name, 30,' ') || rpad(p_clvl_filter_rec.clvl_description, 40,' ');
                        x_prod_selections_tbl(rowcount).name := l_name;
                        x_prod_selections_tbl(rowcount).description := p_clvl_filter_rec.clvl_description;
                        x_prod_selections_tbl(rowcount).rec_type := 'P';
                        x_prod_selections_tbl(rowcount).rec_name := 'Site';
                        x_prod_selections_tbl(rowcount).rec_no := rowcount;
                        x_prod_selections_tbl(rowcount).cp_id2 := '';
                        x_prod_selections_tbl(rowcount).ser_number := '';
                        x_prod_selections_tbl(rowcount).ref_number := '' ;
                        x_prod_selections_tbl(rowcount).quantity := '';
                        x_prod_selections_tbl(rowcount).orig_net_amt := '';
                        x_prod_selections_tbl(rowcount).price := '';
                        x_prod_selections_tbl(rowcount).inventory_item_id := '';
                        x_prod_selections_tbl(rowcount).site_id := '';
                        x_prod_selections_tbl(rowcount).uom_code := '';
                        x_prod_selections_tbl(rowcount).display_name := '';
                        x_prod_selections_tbl(rowcount).site_name := '';
                        -- BUG 4372877 --
                        -- GCHADHA --
                        -- 5/25/2005 --
                        x_prod_selections_tbl(rowcount).ext_reference := '';
                        -- END GCHADHA --


                        rowcount := rowcount + 1;

                        populate_table (l_prod_tbl,
                                        l_clvl_filter,
                                        rowcount,
                                        l_display_pref,
                                        x_prod_selections_tbl);



                    END IF;

                END IF;

            ELSIF  l_clvl_filter = 'Customer' THEN
                IF  l_clvl_id IS NULL THEN
                    /* Select all Items for given party first */
                    get_customer_id(p_default => l_default,
                                    p_party_id => l_party_id,
                                    p_org_id => l_org_id,
                                    x_cust_id_tbl => l_cust_id_tbl);

                    --           ----------------------errorout_an(' cust count   '||l_cust_id_tbl.count);

                    FOR cust_count IN 1..l_cust_id_tbl.COUNT LOOP

                        l_id := l_cust_id_tbl(cust_count).customer_id;
                        l_name := l_cust_id_tbl(cust_count).customer_name ;

                        --           ----------------------errorout_an(' before get products '||l_id);

                        get_products(l_clvl_filter,
                                     l_id,
                                     l_default,
                                     l_id,
                                     l_org_id,
                                     l_party_id,
                                     l_organization_id,
                                     l_prod_tbl);

                        --           ----------------------errorout_an(' after get products '||l_prod_tbl.count);
                        IF l_prod_tbl.COUNT > 0 THEN

                            x_prod_selections_tbl(rowcount).cp_id := l_id;
                            x_prod_selections_tbl(rowcount).name := l_name;
                            --              x_prod_selections_tbl(rowcount).description := l_get_all_customer_rec.description;
                            x_prod_selections_tbl(rowcount).rec_type := 'P';
                            x_prod_selections_tbl(rowcount).rec_name := 'Customer';
                            x_prod_selections_tbl(rowcount).rec_no := rowcount;
                            x_prod_selections_tbl(rowcount).cp_id2 := '';
                            x_prod_selections_tbl(rowcount).ser_number := '';
                            x_prod_selections_tbl(rowcount).ref_number := '' ;
                            x_prod_selections_tbl(rowcount).quantity := '';
                            x_prod_selections_tbl(rowcount).orig_net_amt := '';
                            x_prod_selections_tbl(rowcount).price := '';
                            x_prod_selections_tbl(rowcount).inventory_item_id := '';
                            x_prod_selections_tbl(rowcount).site_id := '';
                            x_prod_selections_tbl(rowcount).uom_code := '';
                            x_prod_selections_tbl(rowcount).display_name := '';
                            x_prod_selections_tbl(rowcount).site_name := '';
                            -- BUG 4372877 --
                            -- GCHADHA --
                            -- 5/25/2005 --
                            x_prod_selections_tbl(rowcount).ext_reference := '';
                            -- END GCHADHA --


                            rowcount := rowcount + 1;

                            populate_table (l_prod_tbl,
                                            l_clvl_filter,
                                            rowcount,
                                            l_display_pref,
                                            x_prod_selections_tbl);

                            -- BUG 4113113 --
                            -- GCHADHA --
                            rowcount := rowcount + 1;
                            -- END GCHADHA --
                        END IF;
                    END LOOP;
                ELSIF l_clvl_id IS NOT NULL THEN

                    get_products(l_clvl_filter,
                                 l_clvl_id,
                                 l_default,
                                 l_clvl_id,
                                 l_party_id,
                                 l_org_id,
                                 l_organization_id,
                                 l_prod_tbl);

                    IF l_prod_tbl.COUNT > 0 THEN

                        x_prod_selections_tbl(rowcount).cp_id := l_customer_id;
                        x_prod_selections_tbl(rowcount).name := p_clvl_filter_rec.clvl_name;
                        --              x_prod_selections_tbl(rowcount).description := p_clvl_filter_rec.clvl_description;
                        x_prod_selections_tbl(rowcount).rec_type := 'P';
                        x_prod_selections_tbl(rowcount).rec_name := 'Customer';
                        x_prod_selections_tbl(rowcount).rec_no := rowcount;
                        x_prod_selections_tbl(rowcount).cp_id2 := '';
                        x_prod_selections_tbl(rowcount).ser_number := '';
                        x_prod_selections_tbl(rowcount).ref_number := '' ;
                        x_prod_selections_tbl(rowcount).quantity := '';
                        x_prod_selections_tbl(rowcount).orig_net_amt := '';
                        x_prod_selections_tbl(rowcount).price := '';
                        x_prod_selections_tbl(rowcount).inventory_item_id := '';
                        x_prod_selections_tbl(rowcount).site_id := '';
                        x_prod_selections_tbl(rowcount).uom_code := '';
                        x_prod_selections_tbl(rowcount).display_name := '';
                        x_prod_selections_tbl(rowcount).site_name := '';
                        -- BUG 4372877 --
                        -- GCHADHA --
                        -- 5/25/2005 --
                        x_prod_selections_tbl(rowcount).ext_reference := '';
                        -- END GCHADHA --


                        rowcount := rowcount + 1;

                        populate_table (l_prod_tbl,
                                        l_clvl_filter,
                                        rowcount,
                                        l_display_pref,
                                        x_prod_selections_tbl);



                    END IF;
                END IF;

            ELSIF l_clvl_filter = 'Model' THEN

                get_model(l_organization_id,
                          l_clvl_id,
                          l_party_id,
                          l_display_pref,
                          l_default,
                          l_org_id,
                          x_prod_selections_tbl );


            END IF; /** l_clvl_filter  in  item/system/site/customer/model **/

        ELSIF   l_clvl_filter = 'Party' THEN

            IF  l_clvl_id IS NOT NULL OR l_default = 'CUSTOMER' THEN
                l_clvl_id := NVL(l_clvl_id, l_party_id);


                --       IF l_default = 'CUSTOMER' THEN
                get_party_id(p_default => l_default,
                             p_party_id => l_clvl_id,
                             p_org_id => l_org_id,
                             x_party_id_tbl => l_party_id_tbl );

                l_name := l_party_id_tbl(1).party_name;


                --      END IF;

                get_products(l_clvl_filter,
                             NULL,
                             l_default,
                             l_clvl_id,
                             l_clvl_id,
                             l_org_id,
                             l_organization_id,
                             l_prod_tbl);

                IF l_prod_tbl.COUNT > 0 THEN
                    x_prod_selections_tbl(rowcount).cp_id := l_party_id;
                    x_prod_selections_tbl(rowcount).name := l_name;
                    x_prod_selections_tbl(rowcount).description := l_name;
                    x_prod_selections_tbl(rowcount).rec_type := 'P';
                    x_prod_selections_tbl(rowcount).rec_name := 'Party';
                    x_prod_selections_tbl(rowcount).rec_no := rowcount;
                    x_prod_selections_tbl(rowcount).cp_id2 := '';
                    x_prod_selections_tbl(rowcount).ser_number := '';
                    x_prod_selections_tbl(rowcount).ref_number := '' ;
                    x_prod_selections_tbl(rowcount).quantity := '';
                    x_prod_selections_tbl(rowcount).price := '';
                    x_prod_selections_tbl(rowcount).inventory_item_id := '';
                    x_prod_selections_tbl(rowcount).site_id := '';
                    x_prod_selections_tbl(rowcount).uom_code := '';
                    x_prod_selections_tbl(rowcount).display_name := '';
                    x_prod_selections_tbl(rowcount).site_name := '';
                    -- BUG 4372877 --
                    -- GCHADHA --
                    -- 5/25/2005 --
                    x_prod_selections_tbl(rowcount).ext_reference := '';
                    -- END GCHADHA --


                    rowcount := rowcount + 1;

                    populate_table (l_prod_tbl,
                                    l_clvl_filter,
                                    rowcount,
                                    l_display_pref,
                                    x_prod_selections_tbl);

                END IF;

            ELSIF  l_clvl_id IS NULL THEN
                /* Select all Items for given party first */

                get_party_id(p_default => l_default,
                             p_party_id => l_party_id,
                             p_org_id => l_org_id,
                             x_party_id_tbl => l_party_id_tbl );

                FOR i IN 1..l_party_id_tbl.COUNT LOOP

                    l_party_id := l_party_id_tbl(i).party_id;


                    get_products(l_clvl_filter,
                                 NULL,
                                 l_default,
                                 l_clvl_id,
                                 l_party_id,
                                 l_org_id,
                                 l_organization_id,
                                 l_prod_tbl);


                    IF l_prod_tbl.COUNT > 0 THEN

                        x_prod_selections_tbl(rowcount).cp_id := l_party_id_tbl(i).party_id;
                        x_prod_selections_tbl(rowcount).name := l_party_id_tbl(i).party_name;
                        x_prod_selections_tbl(rowcount).description := l_party_id_tbl(i).party_name;
                        x_prod_selections_tbl(rowcount).rec_type := 'P';
                        x_prod_selections_tbl(rowcount).rec_name := 'Party';
                        x_prod_selections_tbl(rowcount).rec_no := rowcount;
                        x_prod_selections_tbl(rowcount).cp_id2 := '';
                        x_prod_selections_tbl(rowcount).ser_number := '';
                        x_prod_selections_tbl(rowcount).ref_number := '' ;
                        x_prod_selections_tbl(rowcount).quantity := '';
                        x_prod_selections_tbl(rowcount).orig_net_amt := '';
                        x_prod_selections_tbl(rowcount).price := '';
                        x_prod_selections_tbl(rowcount).inventory_item_id := '';
                        x_prod_selections_tbl(rowcount).site_id := '';
                        x_prod_selections_tbl(rowcount).uom_code := '';
                        x_prod_selections_tbl(rowcount).display_name := '';
                        x_prod_selections_tbl(rowcount).site_name := '';
                        -- BUG 4372877 --
                        -- GCHADHA --
                        -- 5/25/2005 --
                        x_prod_selections_tbl(rowcount).ext_reference := '';
                        -- END GCHADHA --


                        rowcount := rowcount + 1;

                        populate_table (l_prod_tbl,
                                        l_clvl_filter,
                                        rowcount,
                                        l_display_pref,
                                        x_prod_selections_tbl);
                        -- BUG 4113113 --
                        -- GCHADHA --
                        rowcount := rowcount + 1;
                        -- END GCHADHA --

                    END IF; /* end if or prod tbl count > 0 */
                END LOOP; /* End loop of prod tbl loop */

            END IF; /* Clvl Id is NULL */


        END IF; /** If l_clvl_filter <> 'Party' **/

    END;

    /******* PROC 2 ************/



    /*******************************************/

    PROCEDURE Get_customer_selections(p_clvl_filter_rec IN clvl_filter_rec,
                                      x_clvl_selections_tbl   OUT   NOCOPY   clvl_selections_tbl)
    IS

    CURSOR l_csr_get_customer(p_party_id IN NUMBER ) IS
        SELECT cust_acc.party_id party_id, parties.name party_name, parties.description description,
               cust_acc.id1 id1, cust_acc.name name, cust_acc.id2 id2, cust_acc.description account_number
        FROM   OKX_CUSTOMER_ACCOUNTS_V cust_acc,
               OKX_PARTIES_V parties
        WHERE  cust_acc.party_id = p_party_id
        AND    cust_acc.party_id = parties.id1
        AND    cust_acc.status = 'A';

    CURSOR l_csr_get_party_name(p_party_id IN NUMBER) IS
        SELECT parties.id1 party_id, parties.name party_name
        FROM OKX_PARTIES_V parties
        WHERE parties.id1 = p_party_id ;

    CURSOR l_csr_get_all_customers IS
        SELECT cust_acc.party_id party_id, parties.name party_name, parties.description description,
               cust_acc.id1 id1, cust_acc.name name, cust_acc.id2 id2, cust_acc.description account_number
        FROM   OKX_CUSTOMER_ACCOUNTS_V cust_acc,
               OKX_PARTIES_V parties
        WHERE  cust_acc.party_id = parties.id1
        AND    cust_acc.status = 'A';

    l_csr_cust_rec  l_csr_get_customer%ROWTYPE;
    l_csr_party_rec l_csr_get_party_name%ROWTYPE;

    l_default   VARCHAR2(15);
    l_party_id  OKX_PARTIES_V.id1%TYPE;
    i           NUMBER ;
    rowcount    NUMBER := 1;
    l_org_id    NUMBER ;
    l_customer_id   NUMBER ;
    l_cust_id_tbl cust_id_tbl;
    l_party_id_tbl party_id_tbl;

    l_old_party_Id NUMBER :=  - 99;
    l_party_selected OKX_PARTIES_V.ID1%TYPE;
    BEGIN
        l_default := p_clvl_filter_rec.clvl_default;
        l_party_id := p_clvl_filter_rec.clvl_party_id;
        l_org_id := p_clvl_filter_rec.clvl_auth_org_id;
        l_party_selected := p_clvl_filter_rec.clvl_find_id;

        l_party_id := NVL(l_party_selected, l_party_id);

        IF l_party_selected IS NOT NULL THEN
            OPEN l_csr_get_party_name(l_party_selected);
            FETCH l_csr_get_party_name INTO l_csr_party_rec;
            CLOSE l_csr_get_party_name;

            /*** Set parent records ***/

            x_clvl_selections_tbl(rowcount).rec_type := 'P';
            x_clvl_selections_tbl(rowcount).rec_name := 'Customer';
            x_clvl_selections_tbl(rowcount).rec_no := rowcount;
            x_clvl_selections_tbl(rowcount).id1 := l_csr_party_rec.party_id;
            x_clvl_selections_tbl(rowcount).name := l_csr_party_rec.party_name;
            x_clvl_selections_tbl(rowcount).lse_id := 35;
            x_clvl_selections_tbl(rowcount).lse_name := 'Customer';

            rowcount := rowcount + 1;

            FOR l_cust_csr_rec IN l_csr_get_customer(l_party_selected) LOOP

                x_clvl_selections_tbl(rowcount).rec_type := 'C';
                x_clvl_selections_tbl(rowcount).rec_name := 'Customer';
                x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                x_clvl_selections_tbl(rowcount).id1 := l_cust_csr_rec.id1;
                x_clvl_selections_tbl(rowcount).id2 := l_cust_csr_rec.id2;
                x_clvl_selections_tbl(rowcount).name := l_cust_csr_rec.name;
                x_clvl_selections_tbl(rowcount).clvl_id := l_cust_csr_rec.id1;
                x_clvl_selections_tbl(rowcount).clvl_name := l_cust_csr_rec.name;
                x_clvl_selections_tbl(rowcount).display_name := l_cust_csr_rec.name || ',' || l_cust_csr_rec.account_number;
                x_clvl_selections_tbl(rowcount).party_id := l_cust_csr_rec.party_id;
                x_clvl_selections_tbl(rowcount).party_name := l_cust_csr_rec.party_name;
                x_clvl_selections_tbl(rowcount).description := l_cust_csr_Rec.description;
                x_clvl_selections_tbl(rowcount).lse_id := 35;
                x_clvl_selections_tbl(rowcount).lse_name := 'Customer';
                rowcount := rowcount + 1;
            END LOOP;

        ELSE
            IF   l_default <> 'ALL' THEN

                get_party_id(p_default => l_default,
                             p_party_id => l_party_id,
                             p_org_id => l_org_id,
                             x_party_id_tbl => l_party_id_tbl);

                FOR i IN 1 .. l_party_id_tbl.COUNT LOOP
                    l_party_selected := l_party_id_tbl(i).party_id;

                    FOR l_cust_csr_rec IN l_csr_get_customer(l_party_selected) LOOP
                        l_party_id := l_cust_csr_rec.party_id;
                        IF l_old_party_id <> l_party_id THEN
                            x_clvl_selections_tbl(rowcount).rec_type := 'P';
                            x_clvl_selections_tbl(rowcount).rec_name := 'Customer';
                            x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                            x_clvl_selections_tbl(rowcount).id1 := l_cust_csr_rec.party_id;
                            x_clvl_selections_tbl(rowcount).name := l_cust_csr_rec.party_name;
                            x_clvl_selections_tbl(rowcount).lse_id := 35;
                            x_clvl_selections_tbl(rowcount).lse_name := 'Customer';

                            l_old_party_id := l_party_id;

                            rowcount := rowcount + 1;
                            /* Set parent record */
                        END IF;

                        x_clvl_selections_tbl(rowcount).rec_type := 'C';
                        x_clvl_selections_tbl(rowcount).rec_name := 'Customer';
                        x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                        x_clvl_selections_tbl(rowcount).id1 := l_cust_csr_rec.id1;
                        x_clvl_selections_tbl(rowcount).id2 := l_cust_csr_rec.id2;
                        x_clvl_selections_tbl(rowcount).name := l_cust_csr_rec.name;
                        x_clvl_selections_tbl(rowcount).clvl_id := l_cust_csr_rec.id1;
                        x_clvl_selections_tbl(rowcount).clvl_name := l_cust_csr_rec.name;
                        x_clvl_selections_tbl(rowcount).display_name := l_cust_csr_rec.name || ',' || l_cust_csr_rec.account_number;
                        x_clvl_selections_tbl(rowcount).party_id := l_cust_csr_rec.party_id;
                        x_clvl_selections_tbl(rowcount).party_name := l_cust_csr_rec.party_name;
                        x_clvl_selections_tbl(rowcount).description := l_cust_csr_Rec.description;
                        x_clvl_selections_tbl(rowcount).lse_id := 35;
                        x_clvl_selections_tbl(rowcount).lse_name := 'Customer';
                        rowcount := rowcount + 1;
                    END LOOP;

                END LOOP; /* end of customer id loop */

            ELSIF l_default = 'ALL' THEN
                FOR l_cust_csr_rec IN l_csr_get_all_customers LOOP

                    l_party_id := l_cust_csr_rec.party_id;

                    IF l_old_party_id <> l_party_id THEN

                        x_clvl_selections_tbl(rowcount).rec_type := 'P';
                        x_clvl_selections_tbl(rowcount).rec_name := 'Customer';
                        x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                        x_clvl_selections_tbl(rowcount).id1 := l_cust_csr_rec.party_id;
                        x_clvl_selections_tbl(rowcount).name := l_cust_csr_rec.party_name;
                        x_clvl_selections_tbl(rowcount).lse_id := 35;
                        x_clvl_selections_tbl(rowcount).lse_name := 'Customer';

                        l_old_party_id := l_party_id;
                        rowcount := rowcount + 1;
                        /* Set parent record */
                    END IF;

                    x_clvl_selections_tbl(rowcount).rec_type := 'C';
                    x_clvl_selections_tbl(rowcount).rec_name := 'Customer';
                    x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                    x_clvl_selections_tbl(rowcount).clvl_id := l_cust_csr_rec.id1;
                    x_clvl_selections_tbl(rowcount).id2 := l_cust_csr_rec.id2;
                    x_clvl_selections_tbl(rowcount).clvl_name := l_cust_csr_rec.name;
                    x_clvl_selections_tbl(rowcount).display_name := l_cust_csr_rec.name || ',' || l_cust_csr_rec.account_number;
                    x_clvl_selections_tbl(rowcount).party_id := l_cust_csr_rec.party_id;
                    x_clvl_selections_tbl(rowcount).party_name := l_cust_csr_rec.party_name;
                    x_clvl_selections_tbl(rowcount).description := l_cust_csr_Rec.account_number;
                    x_clvl_selections_tbl(rowcount).lse_id := 35;
                    x_clvl_selections_tbl(rowcount).lse_name := 'Customer';
                    rowcount := rowcount + 1;
                END LOOP;
            END IF; /* L_default id <> 'ALL' */
        END IF;

    END get_customer_selections;



    /*******************************************/


    PROCEDURE Get_party_selections(p_clvl_filter_rec IN clvl_filter_rec,
                                   x_clvl_selections_tbl   OUT   NOCOPY   clvl_selections_tbl)
    IS

    CURSOR l_csr_party_customer(p_party_id IN NUMBER ) IS
        SELECT id1, id2, Name, Description
        FROM   OKX_PARTIES_V
        WHERE  id1 = p_party_id
        AND    status = 'A';

    CURSOR l_csr_party_related(p_party_id IN NUMBER,
                               p_org_id   IN NUMBER) IS
        SELECT P1.id1, P1.id2, P1.name, P1.description
        FROM OKX_PARTIES_V P1, OKX_CUSTOMER_ACCOUNTS_V CA1
        WHERE P1.id1 = CA1.party_id
        AND CA1.id1 IN (SELECT rel_acc.cust_account_id
                        FROM  OKX_CUSTOMER_ACCOUNTS_V    cust_acc,
                        OKX_CUST_ACCT_RELATE_ALL_V rel_acc
                        WHERE rel_acc.related_cust_account_id = cust_acc.id1
                        AND   cust_acc.party_id = p_party_id
                        AND   cust_acc.status = 'A'
                        AND   rel_acc.org_id = p_org_id
                        AND   rel_acc.status = 'A')
        AND P1.status = 'A'
        AND CA1.status = 'A';

    CURSOR l_csr_party_both(p_party_id IN NUMBER,
                            p_org_id   IN NUMBER ) IS
        SELECT id1, id2, Name, Description
        FROM   OKX_PARTIES_V
        WHERE  id1 = p_party_id
        AND    status = 'A'
        UNION
        SELECT P1.id1, P1.id2, P1.name, P1.description
        FROM OKX_PARTIES_V P1, OKX_CUSTOMER_ACCOUNTS_V CA1
        WHERE P1.id1 = CA1.party_id
        AND CA1.id1 IN (SELECT rel_acc.cust_account_id
                        FROM  OKX_CUSTOMER_ACCOUNTS_V    cust_acc,
                        OKX_CUST_ACCT_RELATE_ALL_V rel_acc
                        WHERE rel_acc.related_cust_account_id = cust_acc.id1
                        AND   cust_acc.party_id = p_party_id
                        AND   cust_acc.status = 'A'
                        AND   rel_acc.org_id = p_org_id
                        AND   rel_acc.status = 'A')
        AND P1.status = 'A'
        AND CA1.status = 'A';

    CURSOR l_csr_party_all IS
        SELECT id1, id2, Name, Description
        FROM   OKX_PARTIES_V
        WHERE  status = 'A';

    l_csr_party_rec  l_csr_party_customer%ROWTYPE;

    l_default   VARCHAR2(15);
    l_party_id  OKX_PARTIES_V.id1%TYPE;
    i           NUMBER ;
    rowcount    NUMBER := 1;
    l_org_id    NUMBER ;
    l_party_selected NUMBER;

    BEGIN
        l_default := p_clvl_filter_rec.clvl_default;
        l_party_id := p_clvl_filter_rec.clvl_party_id;
        l_org_id := p_clvl_filter_rec.clvl_auth_org_id;
        l_party_selected := p_clvl_filter_rec.clvl_find_id;


        IF l_default = 'CUSTOMER' OR l_party_selected IS NOT NULL THEN
            IF l_party_selected IS NOT NULL THEN
                l_party_id := l_party_selected ;
            END IF;

            FOR l_csr_party_rec_c IN l_csr_party_customer(l_party_id) LOOP
                x_clvl_selections_tbl(rowcount).rec_type := 'C';
                x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                x_clvl_selections_tbl(rowcount).rec_name := 'Party';
                x_clvl_selections_tbl(rowcount).clvl_id := l_csr_party_rec_c.id1;
                x_clvl_selections_tbl(rowcount).clvl_name := l_csr_party_rec_c.name;
                x_clvl_selections_tbl(rowcount).id2 := l_csr_party_rec_c.id2;
                x_clvl_selections_tbl(rowcount).name := l_csr_party_rec_c.name;
                x_clvl_selections_tbl(rowcount).display_name := l_csr_party_rec_c.name || ',' || l_csr_party_Rec_c.description;
                x_clvl_selections_tbl(rowcount).party_id := l_csr_party_rec_c.id1;
                x_clvl_selections_tbl(rowcount).party_name := l_csr_party_rec_c.name;
                x_clvl_selections_tbl(rowcount).description := l_csr_party_Rec_c.description;
                x_clvl_selections_tbl(rowcount).lse_id := 8;
                x_clvl_selections_tbl(rowcount).lse_name := 'Party'  ;
                rowcount := rowcount + 1;
            END LOOP;
        ELSIF l_default = 'ALL' THEN
            FOR l_csr_party_rec_a IN l_csr_party_all LOOP
                l_party_id := l_csr_party_rec_a.id1 ;
                FOR l_csr_party_rec IN l_Csr_party_customer(l_party_id) LOOP
                    x_clvl_selections_tbl(rowcount).rec_type := 'C';
                    x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                    x_clvl_selections_tbl(rowcount).rec_name := 'Party';
                    x_clvl_selections_tbl(rowcount).id1 := l_csr_party_rec.id1;
                    x_clvl_selections_tbl(rowcount).id2 := l_csr_party_rec.id2;
                    x_clvl_selections_tbl(rowcount).name := l_csr_party_rec.name;
                    x_clvl_selections_tbl(rowcount).display_name := l_csr_party_rec.name || ',' || l_csr_party_Rec.description;
                    x_clvl_selections_tbl(rowcount).clvl_id := l_csr_party_rec.id1;
                    x_clvl_selections_tbl(rowcount).clvl_name := l_csr_party_rec.name;
                    x_clvl_selections_tbl(rowcount).party_id := l_csr_party_rec.id1;
                    x_clvl_selections_tbl(rowcount).party_name := l_csr_party_rec.name;
                    x_clvl_selections_tbl(rowcount).description := l_csr_party_Rec.description;
                    x_clvl_selections_tbl(rowcount).lse_id := 8;
                    x_clvl_selections_tbl(rowcount).lse_name := 'Party'  ;
                    rowcount := rowcount + 1;
                END LOOP;
            END LOOP;
        ELSIF l_default = 'RELATED' THEN
            FOR l_csr_party_rec_r IN l_Csr_party_related(l_party_id, l_org_id ) LOOP
                x_clvl_selections_tbl(rowcount).rec_type := 'C';
                x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                x_clvl_selections_tbl(rowcount).rec_name := 'Party';
                x_clvl_selections_tbl(rowcount).id1 := l_csr_party_rec_r.id1;
                x_clvl_selections_tbl(rowcount).id2 := l_csr_party_rec_r.id2;
                x_clvl_selections_tbl(rowcount).name := l_csr_party_rec_r.name;
                x_clvl_selections_tbl(rowcount).clvl_id := l_csr_party_rec_r.id1;
                x_clvl_selections_tbl(rowcount).clvl_name := l_csr_party_rec_r.name;
                x_clvl_selections_tbl(rowcount).display_name := l_csr_party_rec_r.name || ',' || l_csr_party_Rec.description;
                x_clvl_selections_tbl(rowcount).party_id := l_csr_party_rec_r.id1;
                x_clvl_selections_tbl(rowcount).party_name := l_csr_party_rec_r.name;
                x_clvl_selections_tbl(rowcount).description := l_csr_party_Rec_r.description;
                x_clvl_selections_tbl(rowcount).lse_id := 8;
                x_clvl_selections_tbl(rowcount).lse_name := 'Party'  ;
                rowcount := rowcount + 1;
            END LOOP;
        ELSIF l_default = 'BOTH' THEN
            FOR l_csr_party_rec_b IN l_Csr_party_both(l_party_id, l_org_id ) LOOP
                x_clvl_selections_tbl(rowcount).rec_type := 'C';
                x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                x_clvl_selections_tbl(rowcount).rec_name := 'Party';
                x_clvl_selections_tbl(rowcount).id1 := l_csr_party_rec_b.id1;
                x_clvl_selections_tbl(rowcount).id2 := l_csr_party_rec_b.id2;
                x_clvl_selections_tbl(rowcount).name := l_csr_party_rec_b.name;
                x_clvl_selections_tbl(rowcount).clvl_id := l_csr_party_rec_b.id1;
                x_clvl_selections_tbl(rowcount).id2 := l_csr_party_rec_b.id2;
                x_clvl_selections_tbl(rowcount).clvl_name := l_csr_party_rec_b.name;
                x_clvl_selections_tbl(rowcount).display_name := l_csr_party_rec_b.name || ',' || l_csr_party_Rec.description;
                x_clvl_selections_tbl(rowcount).party_id := l_csr_party_rec_b.id1;
                x_clvl_selections_tbl(rowcount).party_name := l_csr_party_rec_b.name;
                x_clvl_selections_tbl(rowcount).description := l_csr_party_Rec_b.description;
                x_clvl_selections_tbl(rowcount).lse_id := 8;
                x_clvl_selections_tbl(rowcount).lse_name := 'Party'  ;
                rowcount := rowcount + 1;
            END LOOP;
        END IF;

    END get_party_selections;

    PROCEDURE Get_site_selections(p_clvl_filter_rec IN clvl_filter_rec,
                                  x_clvl_selections_tbl   OUT   NOCOPY   clvl_selections_tbl)
    IS

    CURSOR l_csr_get_site(p_party_id IN NUMBER ) IS
        SELECT DISTINCT parties.name party_name, parties.id1 party_id,
               party_site.id1 id1, party_site.party_site_number, party_site.id2,
               party_site.name party_site_name, party_site.description
        FROM   OKX_PARTIES_V parties,
               OKX_PARTY_SITES_V party_site
        WHERE  parties.id1 = p_party_id
        AND    party_site.party_id = parties.id1
        AND    party_site.status = 'A'
        ORDER BY parties.name ;

    CURSOR l_csr_get_all_sites  IS
        SELECT DISTINCT parties.name party_name, parties.id1 party_id,
               party_site.id1 id1, party_site.party_site_number, party_site.id2,
               party_site.name  party_site_name, party_site.description
        FROM   OKX_PARTIES_V parties,
               OKX_PARTY_SITES_V party_site
        WHERE  party_site.party_id = parties.id1
        AND    party_site.status = 'A'
        ORDER BY parties.name ;

    -- Bug 4915711--
    -- l_csr_cust_rec  l_csr_get_site%ROWTYPE;
    -- Bug 4915711--

    l_default      VARCHAR2(15);
    l_party_id     OKX_PARTIES_V.id1%TYPE;
    l_old_party_id     NUMBER :=  - 99;
    i              NUMBER ;
    rowcount       NUMBER := 1;
    l_org_id       NUMBER ;
    l_cust_id_tbl cust_id_tbl;
    l_party_id_tbl party_id_tbl;
    l_party_selected VARCHAR2(15);

    l_old_customer_id NUMBER :=  - 99 ;
    l_customer_id NUMBER ;
    -- BUG 4915711 --
    TYPE get_all_sites_rec IS RECORD (
                                      party_name OKX_PARTIES_V.NAME%TYPE,
                                      party_Id1  OKX_PARTIES_V.ID1%TYPE,
                                      party_sites_Id1  OKX_PARTY_SITES_V.ID1%TYPE,
                                      Party_Sites_Number OKX_PARTY_SITES_V.party_site_number%TYPE,
                                      party_sites_Id2  OKX_PARTY_SITES_V.ID2%TYPE,
                                      party_sites_name OKX_PARTY_SITES_V.NAME%TYPE,
                                      party_desc VARCHAR2(2000)
                                      );

    l_get_all_sites_rec get_all_sites_rec;
    -- BUG 4915711 --

    BEGIN
        l_default := p_clvl_filter_rec.clvl_default;
        l_party_id := p_clvl_filter_rec.clvl_party_id;
        l_org_id := p_clvl_filter_rec.clvl_auth_org_id;

        IF p_clvl_filter_rec.clvl_find_id IS NOT NULL THEN
            l_party_id := p_clvl_filter_rec.clvl_find_id;
        ELSE
            IF l_default = 'CUSTOMER' THEN
                l_party_selected := l_party_Id;
            END IF ;
        END IF;


        IF p_clvl_filter_rec.clvl_find_id IS NOT NULL THEN /* If default = CUSTOMER, or find id has a value then select covered sites only for given party id */
            -- BUG 4915711 --
            --  FOR l_site_csr_rec IN l_csr_get_site(l_party_id) LOOP
            OPEN l_csr_get_site(l_party_id);
            LOOP
                FETCH l_csr_get_site INTO l_get_all_sites_rec;
                IF l_csr_get_site%NOTFOUND THEN
                    CLOSE l_csr_get_site;
                    EXIT;
                END IF;
                IF rowcount = 1 THEN
                    x_clvl_selections_tbl(rowcount).rec_type := 'P';
                    x_clvl_selections_tbl(rowcount).rec_name := 'Site';
                    x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                    --  x_clvl_selections_tbl(rowcount).id1    := l_site_csr_rec.party_id; -- Bug 4915711
                    --  x_clvl_selections_tbl(rowcount).name   := l_site_csr_rec.party_name; -- Bug 4915711
                    x_clvl_selections_tbl(rowcount).id1 := l_get_all_sites_rec.party_id1;
                    x_clvl_selections_tbl(rowcount).name := l_get_all_sites_rec.party_name;
                    x_clvl_selections_tbl(rowcount).lse_id := 10;
                    x_clvl_selections_tbl(rowcount).lse_name := 'Site';
                    rowcount := rowcount + 1;
                    /* Set parent record */
                END IF;

                x_clvl_selections_tbl(rowcount).rec_type := 'C';
                x_clvl_selections_tbl(rowcount).rec_name := 'Site';
                x_clvl_selections_tbl(rowcount).rec_no := rowcount;

                x_clvl_selections_tbl(rowcount).id1 := l_get_all_sites_rec.party_sites_id1;
                x_clvl_selections_tbl(rowcount).id2 := l_get_all_sites_rec.party_sites_id2;
                x_clvl_selections_tbl(rowcount).name := l_get_all_sites_rec.party_sites_number || '-' || l_get_all_sites_rec.party_sites_name;
                x_clvl_selections_tbl(rowcount).display_name := l_get_all_sites_rec.party_sites_number || '-' || l_get_all_sites_rec.party_sites_name ||' '|| l_get_all_sites_rec.party_desc;
                x_clvl_selections_tbl(rowcount).clvl_id := l_get_all_sites_rec.party_sites_id1;
                x_clvl_selections_tbl(rowcount).clvl_name := l_get_all_sites_rec.party_sites_number || '-' || l_get_all_sites_rec.party_sites_name;
                x_clvl_selections_tbl(rowcount).description := l_get_all_sites_rec.party_desc;

                x_clvl_selections_tbl(rowcount).lse_id := 10;

                x_clvl_selections_tbl(rowcount).lse_name := 'Site';

                rowcount := rowcount + 1;

            END LOOP;
            -- Bug 4915711--
        ELSE  /* if find id is NULL */

            IF l_default <> 'ALL' THEN /* if default is BOTH or RELATED */

                get_party_id(p_default => l_default,
                             p_party_id => l_party_id,
                             p_org_id => l_org_id,
                             x_party_id_tbl => l_party_id_tbl);

                FOR i IN 1 .. l_party_id_tbl.COUNT LOOP

                    l_party_id := l_party_id_tbl(i).party_id;
                    -- Bug 4915711--
                    -- FOR l_site_csr_rec IN l_csr_get_site(l_party_Id) LOOP
                    OPEN l_csr_get_site(l_party_id);
                    LOOP
                        FETCH l_csr_get_site INTO l_get_all_sites_rec;
                        IF l_csr_get_site%NOTFOUND THEN
                            CLOSE l_csr_get_site;
                            EXIT;
                        END IF;
                        -- l_party_id := l_site_csr_rec.party_id;
                        l_party_id := l_get_all_sites_rec.party_id1;
                        IF l_old_party_id <> l_party_id THEN
                            x_clvl_selections_tbl(rowcount).rec_type := 'P';
                            x_clvl_selections_tbl(rowcount).rec_name := 'Site';
                            x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                            --x_clvl_selections_tbl(rowcount).id1 := l_site_csr_rec.party_id;
                            -- x_clvl_selections_tbl(rowcount).name := l_site_csr_rec.party_name;
                            x_clvl_selections_tbl(rowcount).id1 := l_get_all_sites_rec.party_id1;
                            x_clvl_selections_tbl(rowcount).name := l_get_all_sites_rec.party_name;

                            x_clvl_selections_tbl(rowcount).lse_id := 10;
                            x_clvl_selections_tbl(rowcount).lse_name := 'Site';

                            l_old_party_id := l_party_id;
                            rowcount := rowcount + 1;
                            /* Set parent record */
                        END IF;

                        x_clvl_selections_tbl(rowcount).rec_type := 'C';
                        x_clvl_selections_tbl(rowcount).rec_name := 'Site';
                        x_clvl_selections_tbl(rowcount).rec_no := rowcount;

                        x_clvl_selections_tbl(rowcount).id1 := l_get_all_sites_rec.party_sites_id1;
                        x_clvl_selections_tbl(rowcount).id2 := l_get_all_sites_rec.party_sites_id2;
                        x_clvl_selections_tbl(rowcount).name := l_get_all_sites_rec.party_sites_number || '-' || l_get_all_sites_rec.party_sites_name;
                        x_clvl_selections_tbl(rowcount).display_name := l_get_all_sites_rec.party_sites_number || '-' || l_get_all_sites_rec.party_sites_name ||' '|| l_get_all_sites_rec.party_desc;
                        x_clvl_selections_tbl(rowcount).clvl_id := l_get_all_sites_rec.party_sites_id1;
                        x_clvl_selections_tbl(rowcount).clvl_name := l_get_all_sites_rec.party_sites_number || '-' || l_get_all_sites_rec.party_sites_name;
                        x_clvl_selections_tbl(rowcount).description := l_get_all_sites_rec.party_desc;

                        x_clvl_selections_tbl(rowcount).lse_id := 10;
                        x_clvl_selections_tbl(rowcount).lse_name := 'Site';

                        rowcount := rowcount + 1;

                    END LOOP;
                    -- Bug 4915711 --
                END LOOP;


            ELSIF l_default = 'ALL' THEN
                -- Bug 4915711 --
                -- FOR l_site_csr_rec IN l_csr_get_all_sites  LOOP
                OPEN l_csr_get_all_sites;
                LOOP
                    FETCH l_csr_get_all_sites INTO l_get_all_sites_rec;
                    IF l_csr_get_all_sites%NOTFOUND THEN
                        CLOSE l_csr_get_all_sites;
                        EXIT;
                    END IF;
                    -- l_party_id := l_site_csr_rec.party_id;
                    l_party_id := l_get_all_sites_rec.party_id1;

                    IF l_old_party_id <> l_party_id THEN

                        x_clvl_selections_tbl(rowcount).rec_type := 'P';
                        x_clvl_selections_tbl(rowcount).rec_name := 'Site';
                        x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                        /*
                        x_clvl_selections_tbl(rowcount).id1 := l_site_csr_rec.party_id;
                        x_clvl_selections_tbl(rowcount).name := l_site_csr_rec.party_name;
                        */
                        x_clvl_selections_tbl(rowcount).id1 := l_get_all_sites_rec.party_id1;
                        x_clvl_selections_tbl(rowcount).name := l_get_all_sites_rec.party_name;

                        x_clvl_selections_tbl(rowcount).lse_id := 10;
                        x_clvl_selections_tbl(rowcount).lse_name := 'Site';
                        --    l_old_site_id := l_site_id;
                        l_old_party_id := l_party_id;
                        rowcount := rowcount + 1;
                        /* Set parent record */
                    END IF;

                    x_clvl_selections_tbl(rowcount).rec_type := 'C';
                    x_clvl_selections_tbl(rowcount).rec_name := 'Site';
                    x_clvl_selections_tbl(rowcount).rec_no := rowcount;

                    x_clvl_selections_tbl(rowcount).clvl_id := l_get_all_sites_rec.party_sites_id1;
                    x_clvl_selections_tbl(rowcount).id2 := l_get_all_sites_rec.party_sites_id2;
                    x_clvl_selections_tbl(rowcount).clvl_name := l_get_all_sites_rec.party_sites_number || '-' || l_get_all_sites_rec.party_sites_name;
                    x_clvl_selections_tbl(rowcount).display_name := l_get_all_sites_rec.party_sites_number || '-' || l_get_all_sites_rec.party_sites_name ||' '|| l_get_all_sites_rec.party_desc;
                    x_clvl_selections_tbl(rowcount).id1 := l_get_all_sites_rec.party_sites_id1;
                    x_clvl_selections_tbl(rowcount).name := l_get_all_sites_rec.party_sites_number || '-' || l_get_all_sites_rec.party_sites_name;
                    x_clvl_selections_tbl(rowcount).description := l_get_all_sites_rec.party_desc;

                    x_clvl_selections_tbl(rowcount).lse_id := 10;
                    x_clvl_selections_tbl(rowcount).lse_name := 'Site';

                    rowcount := rowcount + 1;

                END LOOP;
                -- Bug 4915711--
            END IF;   /** end of default = ALL **/
        END IF;   /** Find id is not  null **/
    END get_site_selections;

    PROCEDURE Get_system_selections(p_clvl_filter_rec IN clvl_filter_rec,
                                    x_clvl_selections_tbl   OUT   NOCOPY   clvl_selections_tbl)
    IS

    -- BUG 4171350 --
    -- Added check for Language used for Session

    /** Covered Systems by customer */
    CURSOR l_csr_get_cust_system(p_customer_id IN NUMBER ) IS
        SELECT cust_acc.id1, cust_acc.name,
               CSB.system_id, '#' id2, CSB.system_number,
               CST.description, CST.name system_name
        FROM   CSI_SYSTEMS_B CSB, CSI_SYSTEMS_TL CST, OKX_CUSTOMER_ACCOUNTS_V cust_acc
        WHERE cust_acc.id1 = p_customer_id
        AND   CSB.system_id = CST.system_id
        AND   CSB.Customer_id = cust_acc.id1
        AND   CST.language = userenv('lang') -- new
        AND   SYSDATE BETWEEN NVL(CSB.start_date_active, SYSDATE) AND NVL(CSB.end_date_active, SYSDATE)

        ORDER BY cust_acc.id1, CSB.system_id;


    CURSOR l_csr_get_all_cust_system  IS
        SELECT cust_acc.id1, cust_acc.name,
               CSB.system_id, '#' id2, CSB.system_number,
               CST.description, CST.name system_name
        FROM   CSI_SYSTEMS_B CSB, CSI_SYSTEMS_TL CST, OKX_CUSTOMER_ACCOUNTS_V cust_acc
        WHERE  CSB.system_id = CST.system_id
        AND    CSB.Customer_id = cust_acc.id1
        AND    SYSDATE BETWEEN NVL(CSB.start_date_active, SYSDATE)  AND NVL(CSB.end_date_active, SYSDATE)
        AND    CST.language = userenv('lang') -- new
        ORDER  BY cust_acc.id1, CSB.system_id;


    /** Covered System by party */
    CURSOR l_csr_get_party_system(p_party_id IN VARCHAR2)  IS
        SELECT parties.id1, parties.name, CSB.system_id, parties.id2 id2,
               CST.name system_name, CST.description, CSB.system_number
        FROM   CSI_SYSTEMS_B CSB,
               CSI_SYSTEMS_TL CST,
               OKX_PARTIES_V parties,
               OKX_CUSTOMER_ACCOUNTS_V cust_acc
        WHERE parties.id1 = p_party_id
        AND   cust_acc.party_id = parties.id1
        AND   CSB.system_id = CST.system_id
        AND   CSB.customer_id = cust_acc.id1
        AND    CST.language = userenv('lang') -- new
        AND   SYSDATE BETWEEN NVL(CSB.start_date_active, SYSDATE) AND NVL(CSB.end_date_active, SYSDATE);


    CURSOR l_csr_get_all_party_systems  IS
        SELECT parties.id1, parties.name, CSB.system_id, parties.id2 id2,
               CST.name system_name, CST.description,
               CSB.system_number
        FROM CSI_SYSTEMS_B CSB,
             CSI_SYSTEMS_TL CST,
             OKX_PARTIES_V parties,
             OKX_CUSTOMER_ACCOUNTS_V cust_acc
        WHERE cust_acc.party_id = parties.id1
        AND   CSB.system_id = CST.system_id
        AND   CSB.customer_id = cust_acc.id1
        AND    CST.language = userenv('lang') -- new
        AND   SYSDATE BETWEEN NVL(CSB.start_date_active, SYSDATE)  AND NVL(CSB.end_date_active, SYSDATE);


    /** Covered System by Site **/
    CURSOR l_csr_get_site_system(p_party_site_id IN NUMBER)  IS
        SELECT party_site.id1, party_site.party_site_number || '-' || party_site.name party_site_name, CSB.system_id,
               '#', CST.name system_name, CST.description,
               CSB.system_number, party_site.id2 id2
        FROM   CSI_SYSTEMS_B CSB, CSI_SYSTEMS_TL CST, OKX_PARTY_SITES_V party_site
        WHERE  party_site.id1 = p_party_site_id
        AND    CSB.system_id = CST.system_id
        AND    SYSDATE BETWEEN  NVL(CSB.start_date_active, SYSDATE) AND NVL(CSB.end_date_active, SYSDATE)
        AND    CSB.install_site_use_id = party_site.id1
        AND    CST.language = userenv('lang') -- new
        ORDER BY  party_site.id1, CSB.system_id;

    CURSOR l_csr_site_system_by_party(p_party_id IN NUMBER)  IS
        SELECT party_site.id1, party_site.party_site_number || '-' || party_site.name party_site_name, CSB.system_id,
               '#', CST.name system_name, CST.description,
               CSB.system_number, party_site.id2 id2
        FROM   CSI_SYSTEMS_B CSB, CSI_SYSTEMS_TL CST, OKX_PARTY_SITES_V party_site
        WHERE  party_site.party_id = p_party_id
        AND    CSB.system_id = CST.system_id
        AND    SYSDATE BETWEEN  NVL(CSB.start_date_active, SYSDATE) AND NVL(CSB.end_date_active, SYSDATE)
        AND    CSB.install_site_use_id = party_site.id1
        AND    CST.language = userenv('lang') -- new
        ORDER BY  party_site.id1, CSB.system_id;

    CURSOR l_csr_get_all_site_systems  IS
        SELECT party_site.id1, party_site.party_site_number || '-' || party_site.name party_site_name,
               CSB.system_id, party_site.id2 id2, CST.name system_name, CST.description,
               CSB.system_number
        FROM   CSI_SYSTEMS_B CSB, CSI_SYSTEMS_TL CST, OKX_PARTY_SITES_V party_site
        WHERE  CSB.system_id = CST.system_id
        AND    SYSDATE BETWEEN NVL(CSB.start_date_active, SYSDATE) AND NVL(CSB.end_date_active, SYSDATE)
        AND    CSB.install_site_use_id = party_site.id1
        AND    CST.language = userenv('lang') -- new
        ORDER BY  party_site.id1, CSB.system_id;

    l_csr_system_rec  l_csr_get_cust_system%ROWTYPE;

    l_default      VARCHAR2(15);
    l_party_id     NUMBER(15);
    l_customer_id  OKX_CUSTOMER_ACCOUNTS_V.id1%TYPE;
    i              NUMBER ;
    rowcount       NUMBER := 1;
    l_org_id       NUMBER ;
    l_party_id_tbl party_id_tbl;
    l_filter       VARCHAR2(15);
    l_old_customer_id  NUMBER :=  - 99;
    l_old_party_id     NUMBER :=  - 99;
    l_party_site_id    NUMBER;
    l_cust_id_tbl      cust_id_tbl;
    l_party_selected NUMBER;
    l_old_party_site_id   NUMBER :=  - 99;


    BEGIN
        l_default := p_clvl_filter_rec.clvl_default;
        l_party_id := p_clvl_filter_rec.clvl_party_id;
        l_org_id := p_clvl_filter_rec.clvl_auth_org_id;
        l_filter := p_clvl_filter_rec.clvl_filter;

        IF l_filter = 'Customer' THEN
            IF p_clvl_filter_rec.clvl_find_id IS NOT NULL THEN
                l_customer_id := p_clvl_filter_rec.clvl_find_id;
            END IF;
            --    ----------------errorout(' l customer id '||l_customer_id);
            IF p_clvl_filter_rec.clvl_find_id  IS NOT NULL THEN

                --   ----------------errorout(' l customer id is NOT NULL ');
                FOR l_system_csr_rec IN l_csr_get_cust_system(l_customer_Id) LOOP
                    --                               ----------------errorout(' in loop customer id is '||l_customer_id);
                    IF rowcount = 1 THEN
                        ----------------errorout(' systems selected ');
                        x_clvl_selections_tbl(rowcount).rec_type := 'P';
                        x_clvl_selections_tbl(rowcount).rec_name := 'System';
                        x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                        x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1 /** Customer id */ ;
                        x_clvl_selections_tbl(rowcount).name := l_system_csr_rec.name /* customer name */ ;
                        x_clvl_selections_tbl(rowcount).lse_id := 11;
                        x_clvl_selections_tbl(rowcount).lse_name := 'System';

                        rowcount := rowcount + 1;

                        /* Set parent record */

                    END IF;

                    x_clvl_selections_tbl(rowcount).rec_type := 'C';
                    x_clvl_selections_tbl(rowcount).rec_name := 'System';
                    x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                    x_clvl_selections_tbl(rowcount).id2 := l_system_csr_rec.id2;
                    x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                    x_clvl_selections_tbl(rowcount).clvl_id := l_system_csr_rec.system_id;
                    x_clvl_selections_tbl(rowcount).clvl_name := l_system_csr_rec.system_name;
                    x_clvl_selections_tbl(rowcount).display_name := l_system_csr_rec.system_name ||' , '|| l_system_csr_rec.description ||' , '|| l_system_csr_rec.system_number;
                    x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1; /** customer id **/
                    x_clvl_selections_tbl(rowcount).name := l_system_csr_rec.name;  /** customer name **/
                    x_clvl_selections_tbl(rowcount).description := l_system_csr_Rec.description;
                    x_clvl_selections_tbl(rowcount).lse_id := 11;
                    x_clvl_selections_tbl(rowcount).lse_name := 'System';

                    rowcount := rowcount + 1;

                END LOOP;

            ELSE  /* Customer id is NULL */
                --     ----------------errorout(' l customer id IS NULL ');
                IF l_default <> 'ALL' THEN
                    --       ----------------errorout(' default is not ALL ');
                    get_customer_id(p_default => l_default,
                                    p_party_id => l_party_id,  /* clvl_rec.party_id */
                                    p_org_id => l_org_id,
                                    x_cust_id_tbl => l_cust_id_tbl);

                    FOR i IN 1 .. l_cust_id_tbl.COUNT LOOP

                        l_customer_id := l_cust_id_tbl(i).customer_id;
                        --                ----------------errorout(' in loop customer id is '||l_customer_id);
                        FOR l_system_csr_rec IN l_csr_get_cust_system(l_customer_Id) LOOP

                            --                  ----------------errorout(' systems selected ');
                            IF l_old_customer_id <> l_customer_id THEN
                                --                              ----------------errorout(' customer parent id is '||l_customer_id);
                                x_clvl_selections_tbl(rowcount).rec_type := 'P';
                                x_clvl_selections_tbl(rowcount).rec_name := 'System';
                                x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                                x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                                x_clvl_selections_tbl(rowcount).name := l_system_csr_rec.name;
                                x_clvl_selections_tbl(rowcount).lse_id := 11;
                                x_clvl_selections_tbl(rowcount).lse_name := 'System';

                                rowcount := rowcount + 1;
                                l_old_customer_id := l_customer_id;

                                /* Set parent record */

                            END IF;

                            x_clvl_selections_tbl(rowcount).rec_type := 'C';
                            x_clvl_selections_tbl(rowcount).rec_name := 'System';
                            x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                            x_clvl_selections_tbl(rowcount).id2 := l_system_csr_rec.id2;
                            x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                            x_clvl_selections_tbl(rowcount).clvl_id := l_system_csr_rec.system_id;
                            x_clvl_selections_tbl(rowcount).clvl_name := l_system_csr_rec.system_name;
                            x_clvl_selections_tbl(rowcount).display_name := l_system_csr_rec.system_name ||' , '|| l_system_csr_rec.description ||' , '|| l_system_csr_rec.system_number;
                            x_clvl_selections_tbl(rowcount).party_id := l_system_csr_rec.id1; /** customer id **/
                            x_clvl_selections_tbl(rowcount).party_name := l_system_csr_rec.name;  /** customer name **/
                            x_clvl_selections_tbl(rowcount).description := l_system_csr_Rec.description;
                            x_clvl_selections_tbl(rowcount).lse_id := 11;
                            x_clvl_selections_tbl(rowcount).lse_name := 'System';

                            rowcount := rowcount + 1;

                        END LOOP; /* Select systems for given customer id */
                    END LOOP; /* Select customer id */

                ELSE /** Default is ALL **/

                    FOR l_system_csr_rec IN l_csr_get_all_cust_system  LOOP

                        l_customer_id := l_system_csr_rec.id1;
                        IF l_old_customer_id <> l_customer_id THEN
                            x_clvl_selections_tbl(rowcount).rec_type := 'P';
                            x_clvl_selections_tbl(rowcount).rec_name := 'System';
                            x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                            x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                            x_clvl_selections_tbl(rowcount).name := l_system_csr_rec.name;
                            x_clvl_selections_tbl(rowcount).lse_id := 11;
                            x_clvl_selections_tbl(rowcount).lse_name := 'System';

                            l_old_customer_id := l_customer_id ;
                            rowcount := rowcount + 1;

                            /* Set parent record */

                        END IF;

                        x_clvl_selections_tbl(rowcount).rec_type := 'C';
                        x_clvl_selections_tbl(rowcount).rec_name := 'System';
                        x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                        x_clvl_selections_tbl(rowcount).id2 := l_system_csr_rec.id2;
                        x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                        x_clvl_selections_tbl(rowcount).clvl_id := l_system_csr_rec.system_id;
                        x_clvl_selections_tbl(rowcount).clvl_name := l_system_csr_rec.system_name;
                        x_clvl_selections_tbl(rowcount).display_name := l_system_csr_rec.system_name ||' , '|| l_system_csr_rec.description ||' , '|| l_system_csr_rec.system_number;
                        x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1; /** customer id **/
                        x_clvl_selections_tbl(rowcount).name := l_system_csr_rec.name;  /** customer name **/
                        x_clvl_selections_tbl(rowcount).description := l_system_csr_Rec.description;
                        x_clvl_selections_tbl(rowcount).lse_id := 11;
                        x_clvl_selections_tbl(rowcount).lse_name := 'System';

                        rowcount := rowcount + 1;

                    END LOOP;  /** Select systems for all customers **/
                END IF; /** Default <> 'ALL' **/

            END IF;  /** customer id is not null **/

        ELSIF l_filter = 'Site' THEN

            IF p_clvl_filter_rec.clvl_find_id IS NOT NULL THEN
                l_party_site_id := p_clvl_filter_rec.clvl_find_id;
            END IF;

            --    ----------------errorout(' party site id is '||l_party_site_id);
            IF l_party_site_id IS NOT NULL THEN
                FOR l_system_csr_rec IN l_csr_get_site_system(l_party_site_Id) LOOP
                    IF l_old_party_site_id <> l_system_csr_rec.id1 THEN
                        x_clvl_selections_tbl(rowcount).rec_type := 'P';
                        x_clvl_selections_tbl(rowcount).rec_name := 'System';
                        x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                        x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;

                        x_clvl_selections_tbl(rowcount).name := l_system_csr_rec.party_site_name;
                        x_clvl_selections_tbl(rowcount).party_id := l_system_csr_rec.id1;
                        x_clvl_selections_tbl(rowcount).party_name := l_system_csr_rec.party_site_name;
                        x_clvl_selections_tbl(rowcount).lse_id := 11;
                        x_clvl_selections_tbl(rowcount).lse_name := 'System';
                        rowcount := rowcount + 1;

                        l_old_party_site_id := l_system_csr_rec.id1;
                        /* Set parent record */

                    END IF;

                    x_clvl_selections_tbl(rowcount).rec_type := 'C';
                    x_clvl_selections_tbl(rowcount).rec_name := 'System';
                    x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                    x_clvl_selections_tbl(rowcount).id2 := l_system_csr_rec.id2;
                    x_clvl_selections_tbl(rowcount).clvl_id := l_system_csr_rec.system_id;
                    x_clvl_selections_tbl(rowcount).clvl_name := l_system_csr_rec.system_name;
                    x_clvl_selections_tbl(rowcount).display_name := l_system_csr_rec.system_name ||' , '|| l_system_csr_rec.description ||' , '|| l_system_csr_rec.system_number;
                    x_clvl_selections_tbl(rowcount).party_id := l_system_csr_rec.id1; /** party id **/
                    x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                    x_clvl_selections_tbl(rowcount).party_name := l_system_csr_rec.party_site_name;  /** party name **/
                    x_clvl_selections_tbl(rowcount).description := l_system_csr_Rec.description;
                    x_clvl_selections_tbl(rowcount).lse_id := 11;
                    x_clvl_selections_tbl(rowcount).lse_name := 'System';


                    rowcount := rowcount + 1;

                END LOOP;

            ELSE  /* party site id is NULL */
                IF l_default IN  ('CUSTOMER', 'RELATED', 'BOTH') THEN
                    get_party_id(p_default => l_default,
                                 p_party_id => l_party_id,
                                 p_org_id => l_org_id,
                                 x_party_id_tbl => l_party_id_tbl);

                    FOR i IN 1 .. l_party_id_tbl.COUNT LOOP
                        l_party_id := l_party_id_tbl(i).party_id;

                        FOR l_system_csr_rec IN l_csr_site_system_by_party(l_party_Id) LOOP

                            IF l_old_party_site_id <> l_system_csr_rec.id1 THEN
                                /* Build parent record */
                                x_clvl_selections_tbl(rowcount).rec_type := 'P';
                                x_clvl_selections_tbl(rowcount).rec_name := 'System';
                                x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                                x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                                x_clvl_selections_tbl(rowcount).name := l_system_csr_rec.party_site_name;
                                x_clvl_selections_tbl(rowcount).party_id := l_system_csr_rec.id1;

                                x_clvl_selections_tbl(rowcount).party_name := l_system_csr_rec.party_site_name;
                                x_clvl_selections_tbl(rowcount).lse_id := 11;
                                x_clvl_selections_tbl(rowcount).lse_name := 'System';

                                l_old_party_site_id := l_system_csr_rec.id1;

                                rowcount := rowcount + 1;

                                /* Set parent record */

                            END IF;

                            x_clvl_selections_tbl(rowcount).rec_type := 'C';
                            x_clvl_selections_tbl(rowcount).rec_name := 'System';
                            x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                            x_clvl_selections_tbl(rowcount).clvl_id := l_system_csr_rec.system_id;
                            x_clvl_selections_tbl(rowcount).clvl_name := l_system_csr_rec.system_name;
                            x_clvl_selections_tbl(rowcount).display_name := l_system_csr_rec.system_name ||' , '|| l_system_csr_rec.description ||' , '|| l_system_csr_rec.system_number;
                            x_clvl_selections_tbl(rowcount).party_id := l_system_csr_rec.id1; /** party id **/
                            x_clvl_selections_tbl(rowcount).id2 := l_system_csr_rec.id2;
                            x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                            x_clvl_selections_tbl(rowcount).party_name := l_system_csr_rec.party_site_name;  /** party name **/
                            x_clvl_selections_tbl(rowcount).description := l_system_csr_Rec.description;
                            x_clvl_selections_tbl(rowcount).lse_id := 11;
                            x_clvl_selections_tbl(rowcount).lse_name := 'System';

                            rowcount := rowcount + 1;

                        END LOOP; /* Select systems for given customer id */
                    END LOOP; /* Select customer id */

                ELSIF l_default = 'ALL' THEN

                    FOR l_system_csr_rec IN l_csr_get_all_site_systems  LOOP
                        l_party_id := l_system_csr_rec.id1;
                        IF l_old_party_id <> l_party_id THEN
                            x_clvl_selections_tbl(rowcount).rec_type := 'P';
                            x_clvl_selections_tbl(rowcount).rec_name := 'System';
                            x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                            x_clvl_selections_tbl(rowcount).party_id := l_system_csr_rec.id1;
                            x_clvl_selections_tbl(rowcount).party_name := l_system_csr_rec.party_site_name;
                            x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                            x_clvl_selections_tbl(rowcount).name := l_system_csr_rec.party_site_name;
                            x_clvl_selections_tbl(rowcount).lse_id := 11;
                            x_clvl_selections_tbl(rowcount).lse_name := 'System';

                            l_old_party_id := l_party_id ;
                            rowcount := rowcount + 1;

                            /* Set parent record */

                        END IF;

                        x_clvl_selections_tbl(rowcount).rec_type := 'C';
                        x_clvl_selections_tbl(rowcount).rec_name := 'System';
                        x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                        x_clvl_selections_tbl(rowcount).clvl_id := l_system_csr_rec.system_id;
                        x_clvl_selections_tbl(rowcount).clvl_name := l_system_csr_rec.system_name;
                        x_clvl_selections_tbl(rowcount).display_name := l_system_csr_rec.system_name ||' , '|| l_system_csr_rec.description ||' , '|| l_system_csr_rec.system_number;
                        x_clvl_selections_tbl(rowcount).party_id := l_system_csr_rec.id1; /** party id **/
                        x_clvl_selections_tbl(rowcount).id2 := l_system_csr_rec.id2;
                        x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                        x_clvl_selections_tbl(rowcount).party_name := l_system_csr_rec.party_site_name;  /** party name **/
                        x_clvl_selections_tbl(rowcount).description := l_system_csr_Rec.description;
                        x_clvl_selections_tbl(rowcount).lse_id := 11;
                        x_clvl_selections_tbl(rowcount).lse_name := 'System';

                        rowcount := rowcount + 1;

                    END LOOP;  /** Select systems for all customers **/
                END IF ; /** Default <> 'ALL' **/

            END IF;  /** customer id is not null **/

        ELSIF l_filter = 'Party' THEN

            IF l_default = 'CUSTOMER' THEN
                l_party_selected := l_party_id;
            ELSE
                l_party_selected := p_clvl_filter_rec.clvl_find_id;
            END IF;
            --   ----------------errorout(' party selected is '||l_party_selected);
            IF l_party_selected IS NOT NULL THEN

                FOR l_system_csr_rec IN l_csr_get_party_system(l_party_selected) LOOP
                    IF rowcount = 1 THEN
                        x_clvl_selections_tbl(rowcount).rec_type := 'P';
                        x_clvl_selections_tbl(rowcount).rec_name := 'System';
                        x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                        x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                        x_clvl_selections_tbl(rowcount).id2 := l_system_csr_rec.id2;
                        x_clvl_selections_tbl(rowcount).name := l_system_csr_rec.name;
                        x_clvl_selections_tbl(rowcount).party_id := l_system_csr_rec.id1;
                        x_clvl_selections_tbl(rowcount).party_name := l_system_csr_rec.name;
                        x_clvl_selections_tbl(rowcount).lse_id := 11;
                        x_clvl_selections_tbl(rowcount).lse_name := 'System';
                        rowcount := rowcount + 1;

                        /* Set parent record */

                    END IF;

                    x_clvl_selections_tbl(rowcount).rec_type := 'C';
                    x_clvl_selections_tbl(rowcount).rec_name := 'System';
                    x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                    x_clvl_selections_tbl(rowcount).id2 := l_system_csr_rec.id2;
                    x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                    x_clvl_selections_tbl(rowcount).clvl_id := l_system_csr_rec.system_id;
                    x_clvl_selections_tbl(rowcount).clvl_name := l_system_csr_rec.system_name;
                    x_clvl_selections_tbl(rowcount).display_name := l_system_csr_rec.system_name ||' , '|| l_system_csr_rec.description ||' , '|| l_system_csr_rec.system_number;
                    x_clvl_selections_tbl(rowcount).party_id := l_system_csr_rec.id1; /** party id **/
                    x_clvl_selections_tbl(rowcount).party_name := l_system_csr_rec.name;  /** party name **/
                    x_clvl_selections_tbl(rowcount).description := l_system_csr_Rec.description;
                    x_clvl_selections_tbl(rowcount).lse_id := 11;
                    x_clvl_selections_tbl(rowcount).lse_name := 'System';

                    --                    ----------------errorout(' child record is '||x_clvl_selections_tbl(rowcount).clvl_name);
                    rowcount := rowcount + 1;
                END LOOP;

            ELSE  /* party  id is NULL */
                IF l_default IN  ('RELATED', 'BOTH') THEN
                    get_party_id(p_default => l_default,
                                 p_party_id => l_party_id,
                                 p_org_id => l_org_id,
                                 x_party_id_tbl => l_party_id_tbl);


                    FOR i IN 1 .. l_party_id_tbl.COUNT LOOP
                        l_party_selected := l_party_id_tbl(i).party_id;
                        --                    ----------------errorout(' party selected is '||l_party_selected);
                        --                ----------------errorout(' party id is ' ||l_party_selected);
                        FOR l_system_csr_rec IN l_csr_get_party_system(l_party_selected) LOOP

                            IF rowcount = 1 THEN
                                x_clvl_selections_tbl(rowcount).rec_type := 'P';
                                x_clvl_selections_tbl(rowcount).rec_name := 'System';
                                x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                                x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                                x_clvl_selections_tbl(rowcount).name := l_system_csr_rec.name;
                                x_clvl_selections_tbl(rowcount).party_id := l_system_csr_rec.id1;
                                x_clvl_selections_tbl(rowcount).party_name := l_system_csr_rec.name;
                                x_clvl_selections_tbl(rowcount).lse_id := 11;
                                x_clvl_selections_tbl(rowcount).lse_name := 'System';
                                --                      ----------------errorout(' after setting parent record ');
                                --                      ----------------errorout(' parent record is '||x_clvl_selections_tbl(rowcount).party_name);
                                rowcount := rowcount + 1;

                                /* Set parent record */

                            END IF;

                            x_clvl_selections_tbl(rowcount).rec_type := 'C';
                            x_clvl_selections_tbl(rowcount).rec_name := 'System';
                            x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                            x_clvl_selections_tbl(rowcount).id2 := l_system_csr_rec.id2;
                            x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                            x_clvl_selections_tbl(rowcount).clvl_id := l_system_csr_rec.system_id;
                            x_clvl_selections_tbl(rowcount).clvl_name := l_system_csr_rec.system_name;
                            x_clvl_selections_tbl(rowcount).display_name := l_system_csr_rec.system_name ||' , '|| l_system_csr_rec.description ||' , '|| l_system_csr_rec.system_number;
                            x_clvl_selections_tbl(rowcount).party_id := l_system_csr_rec.id1;
                            x_clvl_selections_tbl(rowcount).party_name := l_system_csr_rec.name;  /** party name **/
                            x_clvl_selections_tbl(rowcount).description := l_system_csr_Rec.description;
                            x_clvl_selections_tbl(rowcount).lse_id := 11;
                            x_clvl_selections_tbl(rowcount).lse_name := 'System';
                            --                    ----------------errorout(' in child rec '||x_clvl_selections_tbl(rowcount).party_name);
                            rowcount := rowcount + 1;

                        END LOOP; /* Select systems for given customer id */
                    END LOOP; /* Select customer id */

                ELSIF l_default = 'ALL' THEN

                    FOR l_system_csr_rec IN l_csr_get_all_party_systems  LOOP
                        l_party_id := l_system_csr_rec.id1;
                        IF l_old_party_id <> l_party_id THEN
                            x_clvl_selections_tbl(rowcount).rec_type := 'P';
                            x_clvl_selections_tbl(rowcount).rec_name := 'System';
                            x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                            x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                            x_clvl_selections_tbl(rowcount).id2 := l_system_csr_rec.id2;
                            x_clvl_selections_tbl(rowcount).name := l_system_csr_rec.name;
                            x_clvl_selections_tbl(rowcount).party_id := l_system_csr_rec.id1;
                            x_clvl_selections_tbl(rowcount).party_name := l_system_csr_rec.name;
                            x_clvl_selections_tbl(rowcount).lse_id := 11;
                            x_clvl_selections_tbl(rowcount).lse_name := 'System';

                            l_old_party_id := l_party_id ;
                            --                    ----------------errorout(' parent record is '||x_clvl_selections_tbl(rowcount).id1);
                            rowcount := rowcount + 1;

                            /* Set parent record */

                        END IF;

                        x_clvl_selections_tbl(rowcount).rec_type := 'C';
                        x_clvl_selections_tbl(rowcount).rec_name := 'System';
                        x_clvl_selections_tbl(rowcount).rec_no := rowcount;
                        x_clvl_selections_tbl(rowcount).id2 := l_system_csr_rec.id2;
                        x_clvl_selections_tbl(rowcount).id1 := l_system_csr_rec.id1;
                        x_clvl_selections_tbl(rowcount).clvl_id := l_system_csr_rec.system_id;
                        x_clvl_selections_tbl(rowcount).clvl_name := l_system_csr_rec.system_name;
                        x_clvl_selections_tbl(rowcount).display_name := l_system_csr_rec.system_name ||' , '|| l_system_csr_rec.description ||' , '|| l_system_csr_rec.system_number;
                        x_clvl_selections_tbl(rowcount).party_id := l_system_csr_rec.id1; /** party id **/
                        x_clvl_selections_tbl(rowcount).party_name := l_system_csr_rec.name;  /** party name **/
                        x_clvl_selections_tbl(rowcount).description := l_system_csr_Rec.description;
                        x_clvl_selections_tbl(rowcount).lse_id := 11;
                        x_clvl_selections_tbl(rowcount).lse_name := 'System';

                        rowcount := rowcount + 1;

                    END LOOP;  /** Select systems for all customers **/
                END IF ; /** Default <> 'ALL' **/

            END IF;  /** customer id is not null **/

        END IF;
    END get_system_selections;

    PROCEDURE GetSelections_Prod(p_api_version         IN  NUMBER
                                 , p_init_msg_list       IN  VARCHAR2
                                 , p_clvl_filter_rec     IN  clvl_filter_rec
                                 , x_return_status       OUT NOCOPY VARCHAR2
                                 , x_msg_count           OUT NOCOPY NUMBER
                                 , x_msg_data            OUT NOCOPY VARCHAR2
                                 , x_prod_selections_tbl OUT NOCOPY prod_selections_tbl)
    IS
    lf_prod_selections_tbl prod_selections_tbl;
    rowcount NUMBER := 1;
    BEGIN

        ------errorout(' before get_product selections ');
        get_product_selection(p_clvl_filter_rec,
                              lf_prod_selections_tbl);

        FOR rowcount IN 1 .. lf_prod_selections_tbl.COUNT LOOP

            x_prod_selections_tbl(rowcount).rec_type := lf_prod_selections_tbl(rowcount).rec_type;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).rec_type);
            x_prod_selections_tbl(rowcount).rec_name := 'Item';
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).rec_name);
            x_prod_selections_tbl(rowcount).rec_no := rowcount;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).rec_no);
            x_prod_selections_tbl(rowcount).cp_id := lf_prod_selections_tbl(rowcount).cp_id;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).cp_id);
            x_prod_selections_tbl(rowcount).cp_id2 := lf_prod_selections_tbl(rowcount).cp_id2;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).cp_id2);
            x_prod_selections_tbl(rowcount).ser_number := lf_prod_selections_tbl(rowcount).ser_number;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).ser_number);
            x_prod_selections_tbl(rowcount).ref_number := lf_prod_selections_tbl(rowcount).ref_number ;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).ref_number);
            x_prod_selections_tbl(rowcount).quantity := lf_prod_selections_tbl(rowcount).quantity;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).quantity);
            x_prod_selections_tbl(rowcount).orig_net_amt := lf_prod_selections_tbl(rowcount).orig_net_amt;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).orig_net_amt);
            x_prod_selections_tbl(rowcount).price := lf_prod_selections_tbl(rowcount).price;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).price);
            x_prod_selections_tbl(rowcount).inventory_item_id := lf_prod_selections_tbl(rowcount).inventory_item_id;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).inventory_item_id);
            x_prod_selections_tbl(rowcount).site_id := lf_prod_selections_tbl(rowcount).site_id;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).site_id);
            x_prod_selections_tbl(rowcount).uom_code := lf_prod_selections_tbl(rowcount).uom_code;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).uom_code);
            x_prod_selections_tbl(rowcount).name := lf_prod_selections_tbl(rowcount).name;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).name);
            x_prod_selections_tbl(rowcount).display_name := lf_prod_selections_tbl(rowcount).display_name;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).display_name);
            x_prod_selections_tbl(rowcount).description := lf_prod_selections_tbl(rowcount).description;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).description);
            x_prod_selections_tbl(rowcount).model_level := lf_prod_selections_tbl(rowcount).model_level;
            x_prod_selections_tbl(rowcount).site_name := lf_prod_selections_tbl(rowcount).site_name;
            x_prod_selections_tbl(rowcount).model_level := lf_prod_selections_tbl(rowcount).model_level;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).site_name);
            -- GCHADHA --
            -- BUG 4372877 ---
            -- 5/25/2005 --
            x_prod_selections_tbl(rowcount).ext_reference := lf_prod_selections_tbl(rowcount).ext_reference;
            ------errorout(rowcount||' '||x_prod_selections_tbl(rowcount).ext_reference);
            -- END GCHADHA --



        END LOOP;

        x_return_status := 'S';
        ------errorout(' out of getselections Product PVT ');
    END GetSelections_Prod;


    PROCEDURE GetSelections_other(p_api_version         IN  NUMBER
                                  , p_init_msg_list       IN  VARCHAR2
                                  , p_clvl_filter_rec     IN  clvl_filter_rec
                                  , x_return_status       OUT NOCOPY VARCHAR2
                                  , x_msg_count           OUT NOCOPY NUMBER
                                  , x_msg_data            OUT NOCOPY VARCHAR2
                                  , x_clvl_selections_tbl OUT  NOCOPY clvl_selections_tbl)
    IS
    l_clvl_selections_tbl  clvl_selections_tbl ;
    rowcount NUMBER := 1;
    BEGIN

        IF p_clvl_filter_rec.clvl_lse_id = 8 THEN   /* Covered Party */
            ------------------errorout(' in party selections ');
            get_party_selections(p_clvl_filter_rec,
                                 l_clvl_selections_tbl);
            --                          ----------------errorout(' sys count is '||l_clvl_selections_tbl.count);
            FOR rowcount IN 1 .. l_clvl_selections_tbl.COUNT LOOP

                x_clvl_selections_tbl(rowcount).rec_no := l_clvl_selections_tbl(rowcount).rec_no;
                --           ----------------errorout(x_clvl_selections_tbl(rowcount).rec_type);
                x_clvl_selections_tbl(rowcount).rec_name := l_clvl_selections_tbl(rowcount).rec_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).rec_name );
                x_clvl_selections_tbl(rowcount).rec_type := l_clvl_selections_tbl(rowcount).rec_type;
                ----------------errorout(x_clvl_selections_tbl(rowcount).rec_no);
                x_clvl_selections_tbl(rowcount).id1 := l_clvl_selections_tbl(rowcount).id1;
                ----------------errorout(x_clvl_selections_tbl(rowcount).id1 );
                x_clvl_selections_tbl(rowcount).name := l_clvl_selections_tbl(rowcount).name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).id2 );
                x_clvl_selections_tbl(rowcount).id2 := l_clvl_selections_tbl(rowcount).id2;
                ----------------errorout(x_clvl_selections_tbl(rowcount).name );
                x_clvl_selections_tbl(rowcount).Party_id := l_clvl_selections_tbl(rowcount).party_id;
                ----------------errorout(x_clvl_selections_tbl(rowcount).party_id );
                x_clvl_selections_tbl(rowcount).party_name := l_clvl_selections_tbl(rowcount).party_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).party_name );
                x_clvl_selections_tbl(rowcount).description := l_clvl_selections_tbl(rowcount).description;
                ----------------errorout(x_clvl_selections_tbl(rowcount).description );
                x_clvl_selections_tbl(rowcount).display_name := l_clvl_selections_tbl(rowcount).display_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).display_name );
                x_clvl_selections_tbl(rowcount).clvl_id := l_clvl_selections_tbl(rowcount).clvl_id;
                ----------------errorout(x_clvl_selections_tbl(rowcount).display_name );
                x_clvl_selections_tbl(rowcount).clvl_name := l_clvl_selections_tbl(rowcount).clvl_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).clvl_name );
                x_clvl_selections_tbl(rowcount).lse_id := l_clvl_selections_tbl(rowcount).lse_id;
                -----------------errorout(x_clvl_selections_tbl(rowcount).lse_id );
                x_clvl_selections_tbl(rowcount).lse_name := l_clvl_selections_tbl(rowcount).lse_name;
                -----------------errorout(x_clvl_selections_tbl(rowcount).lse_name );

            END LOOP;
        ELSIF p_clvl_filter_rec.clvl_lse_id = 35 THEN   /* Covered Customer */
            ----------------errorout('in customer selections ');

            get_customer_selections(p_clvl_filter_rec,
                                    l_clvl_selections_tbl);
            --                            ----------------errorout(' sys count is '||l_clvl_selections_tbl.count);
            FOR rowcount IN 1 .. l_clvl_selections_tbl.COUNT LOOP

                x_clvl_selections_tbl(rowcount).rec_no := l_clvl_selections_tbl(rowcount).rec_no;
                --             ----------------errorout(x_clvl_selections_tbl(rowcount).rec_type);
                x_clvl_selections_tbl(rowcount).rec_name := l_clvl_selections_tbl(rowcount).rec_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).rec_name );
                x_clvl_selections_tbl(rowcount).rec_type := l_clvl_selections_tbl(rowcount).rec_type;
                ----------------errorout(x_clvl_selections_tbl(rowcount).rec_no);
                x_clvl_selections_tbl(rowcount).id1 := l_clvl_selections_tbl(rowcount).id1;

                x_clvl_selections_tbl(rowcount).name := l_clvl_selections_tbl(rowcount).name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).id2 );
                x_clvl_selections_tbl(rowcount).id2 := l_clvl_selections_tbl(rowcount).id2;
                ----------------errorout(x_clvl_selections_tbl(rowcount).name );
                x_clvl_selections_tbl(rowcount).Party_id := l_clvl_selections_tbl(rowcount).party_id;
                ----------------errorout(x_clvl_selections_tbl(rowcount).party_id );
                x_clvl_selections_tbl(rowcount).party_name := l_clvl_selections_tbl(rowcount).party_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).party_name );
                x_clvl_selections_tbl(rowcount).description := l_clvl_selections_tbl(rowcount).description;
                ----------------errorout(x_clvl_selections_tbl(rowcount).description );
                x_clvl_selections_tbl(rowcount).display_name := l_clvl_selections_tbl(rowcount).display_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).display_name );
                x_clvl_selections_tbl(rowcount).clvl_id := l_clvl_selections_tbl(rowcount).clvl_id;
                ----------------errorout(x_clvl_selections_tbl(rowcount).display_name );
                x_clvl_selections_tbl(rowcount).clvl_name := l_clvl_selections_tbl(rowcount).clvl_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).clvl_name );
                x_clvl_selections_tbl(rowcount).lse_id := l_clvl_selections_tbl(rowcount).lse_id;
                -----------------errorout(x_clvl_selections_tbl(rowcount).lse_id );
                x_clvl_selections_tbl(rowcount).lse_name := l_clvl_selections_tbl(rowcount).lse_name;
                -----------------errorout(x_clvl_selections_tbl(rowcount).lse_name );

            END LOOP;
        ELSIF p_clvl_filter_rec.clvl_lse_id = 10 THEN   /* Covered Site */
            --       ----------------errorout('in site selections ');
            get_site_selections(p_clvl_filter_rec,
                                l_clvl_selections_tbl);
            ----------------errorout(' sys count is '||l_clvl_selections_tbl.count);
            FOR rowcount IN 1 .. l_clvl_selections_tbl.COUNT LOOP

                x_clvl_selections_tbl(rowcount).rec_no := l_clvl_selections_tbl(rowcount).rec_no;
                --           ----------------errorout(x_clvl_selections_tbl(rowcount).rec_type);
                x_clvl_selections_tbl(rowcount).rec_name := l_clvl_selections_tbl(rowcount).rec_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).rec_name );
                x_clvl_selections_tbl(rowcount).rec_type := l_clvl_selections_tbl(rowcount).rec_type;
                ----------------errorout(x_clvl_selections_tbl(rowcount).rec_no);
                x_clvl_selections_tbl(rowcount).id1 := l_clvl_selections_tbl(rowcount).id1;
                ----------------errorout(x_clvl_selections_tbl(rowcount).id1 );
                x_clvl_selections_tbl(rowcount).name := l_clvl_selections_tbl(rowcount).name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).id2 );
                x_clvl_selections_tbl(rowcount).id2 := l_clvl_selections_tbl(rowcount).id2;
                ----------------errorout(x_clvl_selections_tbl(rowcount).name );
                x_clvl_selections_tbl(rowcount).Party_id := l_clvl_selections_tbl(rowcount).party_id;
                ----------------errorout(x_clvl_selections_tbl(rowcount).party_id );
                x_clvl_selections_tbl(rowcount).party_name := l_clvl_selections_tbl(rowcount).party_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).party_name );
                x_clvl_selections_tbl(rowcount).description := l_clvl_selections_tbl(rowcount).description;
                ----------------errorout(x_clvl_selections_tbl(rowcount).description );
                x_clvl_selections_tbl(rowcount).display_name := l_clvl_selections_tbl(rowcount).display_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).display_name );
                x_clvl_selections_tbl(rowcount).clvl_id := l_clvl_selections_tbl(rowcount).clvl_id;
                ----------------errorout(x_clvl_selections_tbl(rowcount).display_name );
                x_clvl_selections_tbl(rowcount).clvl_name := l_clvl_selections_tbl(rowcount).clvl_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).clvl_name );
                x_clvl_selections_tbl(rowcount).lse_id := l_clvl_selections_tbl(rowcount).lse_id;
                -----------------errorout(x_clvl_selections_tbl(rowcount).lse_id );
                x_clvl_selections_tbl(rowcount).lse_name := l_clvl_selections_tbl(rowcount).lse_name;
                -----------------errorout(x_clvl_selections_tbl(rowcount).lse_name );

            END LOOP;
        ELSIF p_clvl_filter_rec.clvl_lse_id = 11 THEN   /* Covered System */



            get_system_selections(p_clvl_filter_rec,
                                  l_clvl_selections_tbl);

            ----------------errorout(' sys count is '||l_clvl_selections_tbl.count);
            FOR rowcount IN 1 .. l_clvl_selections_tbl.COUNT LOOP

                x_clvl_selections_tbl(rowcount).rec_no := l_clvl_selections_tbl(rowcount).rec_no;
                ----------------errorout(x_clvl_selections_tbl(rowcount).rec_type);
                x_clvl_selections_tbl(rowcount).rec_name := l_clvl_selections_tbl(rowcount).rec_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).rec_name );
                x_clvl_selections_tbl(rowcount).rec_type := l_clvl_selections_tbl(rowcount).rec_type;
                ----------------errorout(x_clvl_selections_tbl(rowcount).rec_no);
                x_clvl_selections_tbl(rowcount).id1 := l_clvl_selections_tbl(rowcount).id1;
                ----------------errorout(x_clvl_selections_tbl(rowcount).id1 );
                x_clvl_selections_tbl(rowcount).name := l_clvl_selections_tbl(rowcount).name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).id2 );
                x_clvl_selections_tbl(rowcount).id2 := l_clvl_selections_tbl(rowcount).id2;
                ----------------errorout(x_clvl_selections_tbl(rowcount).name );
                x_clvl_selections_tbl(rowcount).Party_id := l_clvl_selections_tbl(rowcount).party_id;
                ----------------errorout(x_clvl_selections_tbl(rowcount).party_id );
                x_clvl_selections_tbl(rowcount).party_name := l_clvl_selections_tbl(rowcount).party_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).party_name );
                x_clvl_selections_tbl(rowcount).description := l_clvl_selections_tbl(rowcount).description;
                ----------------errorout(x_clvl_selections_tbl(rowcount).description );
                x_clvl_selections_tbl(rowcount).display_name := l_clvl_selections_tbl(rowcount).display_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).display_name );
                x_clvl_selections_tbl(rowcount).clvl_id := l_clvl_selections_tbl(rowcount).clvl_id;
                ----------------errorout(x_clvl_selections_tbl(rowcount).display_name );
                x_clvl_selections_tbl(rowcount).clvl_name := l_clvl_selections_tbl(rowcount).clvl_name;
                ----------------errorout(x_clvl_selections_tbl(rowcount).clvl_name );
                x_clvl_selections_tbl(rowcount).lse_id := l_clvl_selections_tbl(rowcount).lse_id;
                -----------------errorout(x_clvl_selections_tbl(rowcount).lse_id );
                x_clvl_selections_tbl(rowcount).lse_name := l_clvl_selections_tbl(rowcount).lse_name;
                -----------------errorout(x_clvl_selections_tbl(rowcount).lse_name );

            END LOOP;
        END IF;

    END GetSelections_other;



    FUNCTION get_item_name(p_inventory_item_id IN NUMBER)
    RETURN VARCHAR2
    IS

    CURSOR l_csr_get_item_name(p_inventory_item_Id IN NUMBER)
        IS
        SELECT name
        FROM OKX_SYSTEM_ITEMS_V
        WHERE id1 = p_inventory_item_id
        AND  TRUNC(SYSDATE) BETWEEN trunc(nvl(start_date_active, SYSDATE)) AND trunc(nvl(end_date_active, SYSDATE))
        AND ROWNUM < 2;

    l_item_name  OKX_SYSTEM_ITEMS_V.name%TYPE;

    BEGIN

        OPEN l_csr_Get_item_name(p_inventory_item_id);
        FETCH l_csr_get_item_name INTO l_item_name;
        CLOSE l_csr_Get_item_name;

        RETURN l_item_name;


    END;


    FUNCTION get_item_desc(p_inventory_item_id IN NUMBER)
    RETURN VARCHAR2
    IS

    CURSOR l_csr_get_item_desc(p_inventory_item_Id IN NUMBER)
        IS
        SELECT description
        FROM OKX_SYSTEM_ITEMS_V
        WHERE id1 = p_inventory_item_id
        AND  TRUNC(SYSDATE) BETWEEN trunc(nvl(start_date_active, SYSDATE)) AND trunc(nvl(end_date_active, SYSDATE))
        AND ROWNUM < 2;

    l_item_desc OKX_SYSTEM_ITEMS_V.description%TYPE;

    BEGIN

        OPEN l_csr_Get_item_desc(p_inventory_item_id);
        FETCH l_csr_get_item_desc INTO l_item_desc;
        CLOSE l_csr_Get_item_desc;

        RETURN l_item_desc;

    END;


    FUNCTION get_item_desc(p_inventory_item_id IN NUMBER,
                           p_organization_id   IN NUMBER)
    RETURN VARCHAR2
    IS

    CURSOR l_csr_get_item_desc(p_inventory_item_Id IN NUMBER,
                               p_organization_id IN NUMBER)
        IS
        SELECT description
        FROM OKX_SYSTEM_ITEMS_V
        WHERE inventory_item_id = p_inventory_item_id
        AND   organization_id = p_organization_id
        AND  TRUNC(SYSDATE) BETWEEN trunc(nvl(start_date_active, SYSDATE)) AND trunc(nvl(end_date_active, SYSDATE))
        AND ROWNUM < 2;

    l_item_desc MTL_SYSTEM_ITEMS_KFV.description%TYPE;

    BEGIN

        OPEN l_csr_Get_item_desc(p_inventory_item_id, p_organization_id);
        FETCH l_csr_get_item_desc INTO l_item_desc;
        CLOSE l_csr_Get_item_desc;

        RETURN l_item_desc;

    END;


    FUNCTION get_item_name(p_inventory_item_id IN NUMBER,
                           p_organization_id   IN NUMBER)
    RETURN VARCHAR2
    IS

    CURSOR l_csr_get_item_name(p_inventory_item_Id IN NUMBER,
                               p_organization_id IN  NUMBER)
        IS
        SELECT concatenated_segments name
        FROM MTL_SYSTEM_ITEMS_KFV
        WHERE inventory_item_id = p_inventory_item_id
        AND   organization_id = p_organization_id
        AND  TRUNC(SYSDATE) BETWEEN trunc(nvl(start_date_active, SYSDATE)) AND trunc(nvl(end_date_active, SYSDATE))
        AND ROWNUM < 2;

    l_item_name  MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE;

    BEGIN

        OPEN l_csr_Get_item_name(p_inventory_item_id, p_organization_id);
        FETCH l_csr_get_item_name INTO l_item_name;
        CLOSE l_csr_Get_item_name;

        RETURN l_item_name;

    END;

    /** Code for changing/splitting service lines **/

    PROCEDURE get_rev_distr(p_cle_id  IN NUMBER,
                            x_rev_tbl OUT NOCOPY OKS_REV_DISTR_PUB.rdsv_tbl_type)
    IS
    CURSOR rev_cur IS
        SELECT chr_id
              , cle_id
              , account_class
              , code_combination_id
              , PERCENT
        FROM  oks_rev_distributions
        WHERE cle_id = p_cle_id;
    i     NUMBER := 1;
    BEGIN
        FOR rev_rec IN rev_cur
            LOOP
            x_rev_tbl(i).id := OKC_API.G_MISS_NUM;
            x_rev_tbl(i).chr_id := rev_rec.chr_id;
            x_rev_tbl(i).account_class := rev_rec.account_class;
            x_rev_tbl(i).code_combination_id := rev_rec.code_combination_id;
            x_rev_tbl(i).PERCENT := rev_rec.PERCENT;
            x_rev_tbl(i).object_version_number := OKC_API.G_MISS_NUM;
            x_rev_tbl(i).created_by := OKC_API.G_MISS_NUM;
            x_rev_tbl(i).creation_date := OKC_API.G_MISS_DATE;
            x_rev_tbl(i).last_updated_by := OKC_API.G_MISS_NUM;
            x_rev_tbl(i).last_update_date := OKC_API.G_MISS_DATE;
            x_rev_tbl(i).last_update_login := OKC_API.G_MISS_NUM;
            i := i + 1;
        END LOOP;
    END get_rev_distr;

    PROCEDURE create_rev_distr(p_cle_id  IN NUMBER,
                               p_rev_tbl IN OUT NOCOPY OKS_REV_DISTR_PUB.rdsv_tbl_type,
                               x_status  OUT NOCOPY VARCHAR2)
    IS
    l_api_version  NUMBER := 1.0;
    l_msg_count    NUMBER;
    l_msg_data     VARCHAR2(2000);
    l_rev_tbl      OKS_REV_DISTR_PUB.rdsv_tbl_type;
    i              NUMBER;
    BEGIN
        i := p_rev_tbl.FIRST;
        LOOP
            p_rev_tbl(i).cle_id := p_cle_id;
            EXIT WHEN i = p_rev_tbl.LAST;
            i := p_rev_tbl.NEXT(i);
        END LOOP;
        OKS_REV_DISTR_PUB.insert_Revenue_Distr
        (p_api_version => l_api_version
         , x_return_status => x_status
         , x_msg_count => l_msg_count
         , x_msg_data => l_msg_data
         , p_rdsv_tbl => p_rev_tbl
         , x_rdsv_tbl => l_rev_tbl);
    END create_rev_distr;

    PROCEDURE get_sales_cred(p_cle_id  IN NUMBER,
                             x_scrv_tbl OUT NOCOPY OKS_SALES_CREDIT_PUB.scrv_tbl_type)
    IS
    CURSOR scrv_cur IS
        SELECT
          PERCENT,
          chr_id,
          ctc_id,
          sales_credit_type_id1,
          sales_credit_type_id2
        FROM OKS_K_SALES_CREDITS
        WHERE cle_id = p_cle_id;
    i     NUMBER := 1;
    BEGIN
        FOR scrv_rec IN scrv_cur
            LOOP
            x_scrv_tbl(i).id := OKC_API.G_MISS_NUM;
            x_scrv_tbl(i).PERCENT := scrv_rec.PERCENT;
            x_scrv_tbl(i).chr_id := scrv_rec.chr_id;
            x_scrv_tbl(i).ctc_id := scrv_rec.ctc_id;
            x_scrv_tbl(i).sales_credit_type_id1 := scrv_rec.sales_credit_type_id1;
            x_scrv_tbl(i).sales_credit_type_id2 := scrv_rec.sales_credit_type_id2;
            x_scrv_tbl(i).object_version_number := OKC_API.G_MISS_NUM;
            x_scrv_tbl(i).created_by := OKC_API.G_MISS_NUM;
            x_scrv_tbl(i).creation_date := OKC_API.G_MISS_DATE;
            x_scrv_tbl(i).last_updated_by := OKC_API.G_MISS_NUM;
            x_scrv_tbl(i).last_update_date := OKC_API.G_MISS_DATE;
            i := i + 1;
        END LOOP;
    END get_sales_cred;

    PROCEDURE create_sales_cred(p_cle_id   IN NUMBER,
                                p_scrv_tbl IN OUT NOCOPY OKS_SALES_CREDIT_PUB.scrv_tbl_type,
                                x_status   OUT NOCOPY VARCHAR2) IS
    l_api_version NUMBER := 1.0;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_scrv_tbl OKS_SALES_CREDIT_PUB.scrv_tbl_type;
    i NUMBER;
    BEGIN
        i := p_scrv_tbl.FIRST;
        LOOP
            p_scrv_tbl(i).cle_id := p_cle_id;
            EXIT WHEN i = p_scrv_tbl.LAST;
            i := p_scrv_tbl.NEXT(i);
        END LOOP;
        OKS_SALES_CREDIT_PUB.insert_Sales_credit(
                                                 p_api_version => l_api_version,
                                                 x_return_status => x_status,
                                                 x_msg_count => l_msg_count,
                                                 x_msg_data => l_msg_data,
                                                 p_scrv_tbl => p_scrv_tbl,
                                                 x_scrv_tbl => l_scrv_tbl);
    END create_sales_cred;

    PROCEDURE update_line_item(p_cle_id   IN NUMBER,
                               p_item_id  IN VARCHAR2,
                               x_status   OUT NOCOPY VARCHAR2) IS
    l_api_version   NUMBER := 1.0;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_cimv_rec_in   OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
    l_cimv_rec_out  OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
    CURSOR item_cur IS
        SELECT id
        FROM   okc_k_items_v
        WHERE  cle_id = p_cle_id;
    BEGIN
        OPEN  item_cur;
        FETCH item_cur INTO l_cimv_rec_in.id;
        CLOSE item_cur;
        l_cimv_rec_in.object1_id1 := p_item_id;
        OKC_CONTRACT_ITEM_PUB.update_contract_item(
                                                   p_api_version => l_api_version,
                                                   x_return_status => x_status,
                                                   x_msg_count => l_msg_count,
                                                   x_msg_data => l_msg_data,
                                                   p_cimv_rec => l_cimv_rec_in,
                                                   x_cimv_rec => l_cimv_rec_out);
    END update_line_item;

    PROCEDURE prorate_amount(p_cle_id     IN NUMBER,
                             p_percent    IN NUMBER,
                             p_amount     IN NUMBER,
                             x_status     OUT NOCOPY VARCHAR2) IS
    CURSOR subline_count IS
        SELECT COUNT( * )
        FROM  okc_k_lines_b
        WHERE cle_id = p_cle_id
        AND   lse_id IN (7, 8, 9, 10, 11, 35, 18, 25);

    CURSOR subline_cur IS
        SELECT id, price_negotiated
        FROM okc_k_lines_b
        WHERE cle_id = p_cle_id
        AND lse_id IN (7, 8, 9, 10, 11, 35, 18, 25);

    l_total_amt NUMBER := 0;
    l_count NUMBER;
    i NUMBER;
    l_api_version NUMBER := 1.0;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_clev_tbl_in  OKC_CONTRACT_PUB.clev_tbl_type;
    l_clev_tbl_out OKC_CONTRACT_PUB.clev_tbl_type;
    BEGIN
        OPEN subline_count;
        FETCH subline_count INTO l_count;
        CLOSE subline_count;
        IF l_count = 0 THEN
            x_status := OKC_API.G_RET_STS_SUCCESS;
            RETURN;
        END IF;
        i := 1;
        FOR subline IN subline_cur
            LOOP
            l_clev_tbl_in(i).id := subline.id;
            IF i <> l_count THEN
                l_clev_tbl_in(i).price_negotiated := subline.price_negotiated * p_percent / 100.0;
            ELSE
                l_clev_tbl_in(i).price_negotiated := p_amount - l_total_amt;
            END IF;
            l_total_amt := l_total_amt + NVL(l_clev_tbl_in(i).price_negotiated, 0);
            i := i + 1;
        END LOOP;
        OKC_CONTRACT_PUB.update_contract_line(
                                              p_api_version => l_api_version,
                                              x_return_status => x_status,
                                              x_msg_count => l_msg_count,
                                              x_msg_data => l_msg_data,
                                              p_clev_tbl => l_clev_tbl_in,
                                              x_clev_tbl => l_clev_tbl_out);
    END prorate_amount;

    PROCEDURE refresh_bill_sch(p_cle_id   IN NUMBER,
                               --x_rgp_id   OUT NOCOPY NUMBER,
                               x_status   OUT NOCOPY VARCHAR2) IS

    l_rgp_id NUMBER;

    l_inv_rule_id NUMBER;

    CURSOR inv_rule_cur(p_id IN NUMBER) IS
        SELECT inv_rule_id
        FROM okc_k_lines_b
        WHERE id = p_id;

    l_sll_tbl OKS_BILL_SCH.StreamLvl_tbl;
    l_bill_sch_out_tbl OKS_BILL_SCH.ItemBillSch_tbl;
    l_bill_type OKS_K_LINES_V.billing_schedule_type%TYPE;


    PROCEDURE Populate_Sll_Table(p_cle_id IN NUMBER, x_sll_tbl OUT NOCOPY OKS_BILL_SCH.StreamLvl_tbl, x_bill_type OUT NOCOPY OKS_K_LINES_V.billing_schedule_type%TYPE)
    IS
    tbl_index NUMBER := 1;
    CURSOR sll_cur(p_cle_id IN NUMBER) IS
        SELECT id
              , chr_id
              , cle_id
              , dnz_chr_id
              , sequence_no
              , uom_code
              , start_date
              , end_date
              , level_periods
              , uom_per_period
              , advance_periods
              , level_amount
              , invoice_offset_days
              , interface_offset_days
              , comments
              , due_arr_yn
              , amount
              , lines_detailed_yn
        FROM oks_stream_levels_b
        WHERE cle_id = p_cle_id;

    CURSOR get_bill_type_cur(p_cle_id IN  NUMBER) IS
        SELECT billing_schedule_type
        FROM OKS_K_LINES_V
        WHERE cle_id = p_cle_id;

    l_bill_type OKS_K_LINES_V.billing_schedule_type%TYPE;

    BEGIN

        OPEN get_bill_type_cur(p_cle_id);
        FETCH get_bill_type_cur INTO l_bill_type;
        CLOSE get_bill_type_cur;

        x_bill_type := l_bill_type;
        FOR sll_rec IN sll_cur(p_cle_id)
            LOOP
            x_sll_tbl(tbl_index).Id := sll_rec.id;
            x_sll_tbl(tbl_index).chr_Id := sll_rec.chr_id;
            x_sll_tbl(tbl_index).cle_id := sll_rec.cle_id;
            x_sll_tbl(tbl_index).dnz_chr_id := sll_rec.dnz_chr_id;
            x_sll_tbl(tbl_index).sequence_no := sll_rec.sequence_no;
            x_sll_tbl(tbl_index).uom_code := sll_rec.uom_code;
            x_sll_tbl(tbl_index).start_date := sll_rec.start_date;
            x_sll_tbl(tbl_index).end_date := sll_rec.end_date;
            x_sll_tbl(tbl_index).level_periods := sll_rec.level_periods;
            x_sll_tbl(tbl_index).uom_per_period := sll_rec.uom_per_period;
            x_sll_tbl(tbl_index).level_amount := sll_rec.level_amount;
            x_sll_tbl(tbl_index).invoice_offset_days := sll_rec.invoice_offset_days;
            x_sll_tbl(tbl_index).interface_offset_days := sll_rec.interface_offset_days;
            x_sll_tbl(tbl_index).comments := sll_rec.comments;
            x_sll_tbl(tbl_index).due_arr_yn := sll_rec.due_arr_yn;
            x_sll_tbl(tbl_index).amount := sll_rec.amount;
            x_sll_tbl(tbl_index).lines_detailed_yn := sll_rec.lines_detailed_yn;

            tbl_index := tbl_index + 1;
        END LOOP;

    END Populate_Sll_Table;

    BEGIN

        OPEN  inv_rule_cur(p_cle_id);
        FETCH inv_rule_cur INTO l_inv_rule_id;
        CLOSE inv_rule_cur;


        populate_sll_table (p_cle_id, l_sll_tbl, l_bill_type);

        OKS_BILL_SCH.Create_Bill_Sch_Rules
        (p_billing_type => l_bill_type,
         p_sll_tbl => l_sll_tbl,
         p_invoice_rule_id => l_inv_rule_id,
         x_bil_sch_out_tbl => l_bill_sch_out_tbl,
         x_return_status => x_status);
    END refresh_bill_sch;


    /************/

    --ADDED FOR Bug# 2364507
    FUNCTION GetCoveragetemplate(p_item_id IN NUMBER) RETURN NUMBER
    IS

    l_org_id    NUMBER := OKC_CONTEXT.GET_OKC_ORGANIZATION_ID;

    --Bug 5041682, modifed the cursor to have a lower parse time, current query takes 3 seconds
    CURSOR l_covtemp_csr IS
        --SELECT coverage_template_id
        --FROM   okx_system_items_v
        --WHERE  id1 = p_item_id
        --AND    id2 = OKC_CONTEXT.GET_OKC_ORGANIZATION_ID;
        SELECT COVERAGE_SCHEDULE_ID
        FROM   mtl_system_items_b
        WHERE  inventory_item_id = p_item_id
        AND    organization_id = nvl(l_org_id, -99) ;


    l_covtemp_id   NUMBER := NULL;
    BEGIN
        OPEN  l_covtemp_csr;
        FETCH l_covtemp_csr INTO l_covtemp_id;
        CLOSE l_covtemp_csr;
        RETURN(l_covtemp_id);
    END GetCoverageTemplate;

    FUNCTION GetCoverage(p_cle_id IN NUMBER) RETURN NUMBER
    IS
    CURSOR l_cov_csr IS
        SELECT id
        FROM   okc_k_lines_b
        WHERE  cle_id = p_cle_id
        AND    lse_id IN(2, 20);
    l_cov_id   NUMBER := NULL;
    BEGIN
        OPEN  l_cov_csr;
        FETCH l_cov_csr INTO l_cov_id;
        CLOSE l_cov_csr;
        RETURN(l_cov_id);
    END GetCoverage;

    PROCEDURE calculate_tax(p_chr_id                   NUMBER,
                            p_amt                      NUMBER,
                            p_cle_id                   NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_tax_value     OUT NOCOPY NUMBER,
                            x_AMOUNT_INCLUDES_TAX_FLAG OUT NOCOPY VARCHAR2,
                            x_total OUT NOCOPY NUMBER)
    IS
    l_calculate_tax            VARCHAR2(150);
    -- p_contract_line_rec        OKS_QP_INT_PVT.G_LINE_REC_TYPE;
    L_INDEX1                   BINARY_INTEGER;
    L_INDEX2                   BINARY_INTEGER;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_return_status            VARCHAR2(1) := 'S';
    G_RAIL_REC                 OKS_TAX_UTIL_PVT.ra_rec_type;
    l_UNIT_SELLING_PRICE       G_RAIL_REC.UNIT_SELLING_PRICE%TYPE;
    l_QUANTITY                 G_RAIL_REC.QUANTITY%TYPE;
    l_sub_total                G_RAIL_REC.AMOUNT%TYPE;
    l_total_amt                G_RAIL_REC.AMOUNT%TYPE;
    l_Tax_Code                 G_RAIL_REC.TAX_CODE%TYPE;
    l_TAX_RATE                 G_RAIL_REC.TAX_RATE%TYPE;
    l_total                    G_RAIL_REC.AMOUNT%TYPE;
    l_Tax_Value                G_RAIL_REC.TAX_VALUE%TYPE;
    l_AMOUNT_INCLUDES_TAX_FLAG G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG%TYPE;
    l_price_negotiated         G_RAIL_REC.AMOUNT%TYPE;
    l_lse_id                   NUMBER;
    BEGIN
        G_RAIL_REC.AMOUNT := p_amt;
        OKS_TAX_UTIL_PVT.Get_Tax
        (
         p_api_version => 1.0,
         p_init_msg_list => OKC_API.G_TRUE,
         p_chr_id => p_chr_id,
         p_cle_id => p_cle_id,
         px_rail_rec => G_RAIL_REC,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data,
         x_return_status => l_return_status
         );

        IF (l_return_status = 'S') THEN

            l_UNIT_SELLING_PRICE := G_RAIL_REC.UNIT_SELLING_PRICE;
            l_QUANTITY := G_RAIL_REC.QUANTITY;
            l_sub_total := G_RAIL_REC.AMOUNT;
            l_AMOUNT_INCLUDES_TAX_FLAG := G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG;
            l_Tax_Code := G_RAIL_REC.TAX_CODE;
            l_TAX_RATE := G_RAIL_REC.TAX_RATE ;
            l_Tax_Value := G_RAIL_REC.TAX_VALUE;

            IF NVL(l_AMOUNT_INCLUDES_TAX_FLAG, 'N') = 'Y' THEN
                l_tax_value := 0;

                l_total := l_sub_total + l_Tax_Value;
            ELSE
                l_total := l_sub_total + l_Tax_Value;
                l_AMOUNT_INCLUDES_TAX_FLAG := 'N';
            END IF;
            x_total := l_total;
            x_Tax_Value := l_Tax_Value;
            x_AMOUNT_INCLUDES_TAX_FLAG := l_AMOUNT_INCLUDES_TAX_FLAG;
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
        ELSE
            x_return_status := l_return_status;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
        END IF;

    END calculate_tax;


    FUNCTION GetFormattedInvoiceText(p_item_desc  IN VARCHAR2
                                     , p_start_date IN DATE
                                     , p_end_date   IN DATE) RETURN VARCHAR2
    IS
    BEGIN
        RETURN(SUBSTR(p_item_desc || ':' || p_start_date || ':' || p_end_date, 1, 450));
    END GetFormattedInvoiceText;

    PROCEDURE UpdateIRTRule(p_chr_id        IN  NUMBER
                            , p_cle_id        IN  NUMBER
                            , p_invoice_text  IN  VARCHAR2
                            , p_api_version   IN  NUMBER
                            , p_init_msg_list IN  VARCHAR2
                            , x_return_status OUT NOCOPY VARCHAR2
                            , x_tax_value     OUT NOCOPY NUMBER
                            , x_AMOUNT_INCLUDES_TAX_FLAG OUT NOCOPY VARCHAR2
                            , x_total         OUT NOCOPY NUMBER)

    IS

    l_khrv_tbl OKS_CONTRACT_HDR_PUB.khrv_tbl_type;
    lx_khrv_tbl OKS_CONTRACT_HDR_PUB.khrv_tbl_type;

    l_klnv_tbl OKS_CONTRACT_LINE_PUB.klnv_tbl_type;
    lx_klnv_tbl OKS_CONTRACT_LINE_PUB.klnv_tbl_type;

    CURSOR l_get_khr_id(p_chr_id IN NUMBER)
        IS
        SELECT id, object_version_number --BUG#4066428 hkamdar 01/21/05 added object_version_number
        FROM OKS_K_HEADERS_V
        WHERE chr_id = p_chr_id;

    CURSOR l_get_kln_id(p_dnz_chr_id IN NUMBER, p_cle_id IN NUMBER)
        IS
        SELECT id, object_version_number
        FROM OKS_K_LINES_V
        WHERE dnz_chr_id = p_dnz_chr_id
        AND cle_id = p_cle_id;

    /** Get tax values for each line for given contract id **/
    CURSOR l_get_tot_tax(p_dnz_chr_id IN NUMBER)
        IS
        SELECT cle.id, SUM(kln.tax_amount)
        FROM OKS_K_LINES_V kln, OKC_K_LINES_V cle
        WHERE cle.dnz_chr_id = p_dnz_chr_id
        AND cle.cle_id IS NULL
        AND kln.cle_id = cle.id;


    /*** Get sum of taxes at subline level **/
    CURSOR l_get_tot_tax_subline(p_dnz_chr_id IN NUMBER, p_cle_id IN NUMBER)
        IS
        SELECT MAX(kln.tax_amount)
        FROM OKS_K_LINES_V kln, OKC_K_LINES_V cle
        WHERE cle.dnz_chr_id = p_dnz_chr_id
        AND cle.cle_id = p_cle_id
        AND kln.cle_id = cle.id;


    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);

    l_object_version_number NUMBER;
    l_khr_id         OKS_K_HEADERS_V.id%TYPE;
    l_kln_id         OKS_K_LINES_V.id%TYPE;
    l_validate_yn    VARCHAR2(1);
    --BUG#4066428 hkamdar 01/21/05 added object_version_number
    l_hdr_object_ver_num    OKS_K_HEADERS_V.object_version_number%TYPE;

    --LLC

    CURSOR	get_topline_tax_amt_csr (p_cle_id IN NUMBER) IS
        SELECT	nvl(SUM(nvl(tax_amount, 0)), 0)
        FROM    okc_k_lines_b cle, oks_k_lines_b sle
        WHERE   cle.cle_id = p_cle_id
        AND     cle.lse_id IN (7, 8, 9, 10, 11, 18, 25, 35)
        AND     cle.id = sle.cle_id
        AND     cle.dnz_chr_id = sle.dnz_chr_id
        AND     cle.date_cancelled IS NULL;

    CURSOR get_hdr_tax_amt_csr (p_chr_id IN NUMBER) IS
        SELECT  nvl(SUM(nvl(tax_amount, 0)), 0)
        FROM    okc_k_lines_b cle, oks_k_lines_b sle
        WHERE   cle.dnz_chr_id = p_chr_id
        AND     cle.lse_id IN (1, 12, 14, 19, 46)
        AND     cle.cle_id IS NULL
        AND     cle.id = sle.cle_id
        AND     cle.dnz_chr_id = sle.dnz_chr_id;


    l_topline_tax_amt        NUMBER;
    l_hdr_tax_amt               NUMBER;

    --LLC

    BEGIN



        OPEN l_get_kln_id(p_chr_id, p_cle_id);
        FETCH l_get_kln_id INTO l_kln_id, l_object_version_number;
        CLOSE l_get_kln_id;

        --LLC

        OPEN get_topline_tax_amt_csr(p_cle_id);
        FETCH get_topline_tax_amt_csr INTO l_topline_tax_amt;
        CLOSE get_topline_tax_amt_csr;

        --LLC

        l_klnv_tbl(1).id := l_kln_id;
        l_klnv_tbl(1).cle_id := p_cle_id;
        l_klnv_tbl(1).tax_amount := l_topline_tax_amt; --LLC
        l_klnv_tbl(1).invoice_text := p_invoice_text;
        l_klnv_tbl(1).tax_inclusive_yn := x_amount_includes_tax_flag;
        l_klnv_tbl(1).object_Version_number := l_object_version_number ;


        OKS_CONTRACT_LINE_PUB.update_line(
                                          p_api_version => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => l_return_status,
                                          x_msg_count => l_msg_count,
                                          x_msg_data => l_msg_data,
                                          p_klnv_tbl => l_klnv_tbl,
                                          x_klnv_tbl => lx_klnv_tbl,
                                          p_validate_yn => l_validate_yn);



        x_return_status := l_return_status;



        OPEN l_get_khr_id(p_chr_id);
        FETCH l_get_khr_id INTO l_khr_id,
        l_hdr_object_ver_num; --BUG#4066428 hkamdar 01/21/05 added object_version_number
        CLOSE l_get_khr_id;

        --LLC

        OPEN get_hdr_tax_amt_csr(p_chr_id);
        FETCH get_hdr_tax_amt_csr INTO l_hdr_tax_amt;
        CLOSE get_hdr_tax_amt_csr;

        --LLC

        l_khrv_tbl(1).id := l_khr_id;
        l_khrv_tbl(1).chr_id := p_chr_id;
        l_khrv_tbl(1).tax_amount := l_hdr_tax_amt; --LLC
        --BUG#4066428 hkamdar 01/21/05 added object_version_number
        l_khrv_tbl(1).object_version_number := l_hdr_object_ver_num;


        OKS_CONTRACT_HDR_PUB.update_header(p_api_version => p_api_version,
                                           p_init_msg_list => p_init_msg_list,
                                           x_return_status => l_return_status,
                                           x_msg_count => l_msg_count,
                                           x_msg_data => l_msg_data,
                                           p_khrv_tbl => l_khrv_tbl,
                                           x_khrv_tbl => lx_khrv_tbl,
                                           p_validate_yn => l_validate_yn);

        --errorout('After Update header in UpdateIRTRule-'||l_return_status);
        --BUG#4066428 hkamdar 01/21/05
        x_return_status := l_return_status;
        --End BUG#4066428

        IF l_return_status <> 'S' THEN
            RETURN;
        END IF;


    END UpdateIRTRule;

    /****************/

    PROCEDURE UpdateIRTRule_Subline(p_cle_id        IN  NUMBER
                                    , p_item_desc     IN  VARCHAR2
                                    , p_start_date    IN  DATE
                                    , p_end_date      IN  DATE
                                    , x_return_status OUT NOCOPY VARCHAR2
                                    )
    IS

    l_klnv_tbl_in OKS_CONTRACT_LINE_PUB.klnv_tbl_type;
    lx_klnv_tbl OKS_CONTRACT_LINE_PUB.klnv_tbl_type;


    CURSOR l_cle_csr(p_cle_id IN NUMBER) IS
        SELECT cle.lse_id
             , cle.id line_id
             , cle.start_date
             , cle.end_date
             , cle.price_negotiated amt
             , cle.dnz_chr_id chr_id
             , kln.id kln_id
             , kln.object_version_number
        FROM okc_k_lines_b cle,
             oks_k_lines_b kln
        WHERE cle.cle_id = p_cle_id
        AND  kln.cle_id = cle.id
        AND  lse_id NOT IN (2, 15, 20, 46);


    l_cle_rec       l_cle_csr%ROWTYPE;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_init_msg_list  VARCHAR2(1000);
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_total                   NUMBER;
    l_Tax_Value                NUMBER;
    l_AMOUNT_INCLUDES_TAX_FLAG VARCHAR2(1);
    l_validate_yn   VARCHAR2(1);

    FUNCTION GetFormattedInvoiceText(p_cle_id      IN NUMBER
                                     , p_start_date  IN DATE
                                     , p_end_date    IN DATE
                                     , p_item_desc   IN VARCHAR2
                                     , p_lse_id      IN NUMBER) RETURN VARCHAR2
    IS
    CURSOR l_item_csr IS
        SELECT jtot_object1_code
              , object1_id1
              , object1_id2
              , number_of_items
        FROM  okc_k_items
        WHERE cle_id = p_cle_id;
    l_object_code             okc_k_items.jtot_object1_code%TYPE;
    l_object1_id1             okc_k_items.object1_id1%TYPE;
    l_object1_id2             okc_k_items.object1_id2%TYPE;
    l_no_of_items             okc_k_items.number_of_items%TYPE;
    l_name                    VARCHAR2(2000);
    l_desc                    VARCHAR2(2000);
    l_formatted_invoice_text  VARCHAR2(2000);
    BEGIN
        OPEN  l_item_csr;
        FETCH l_item_csr INTO l_object_code, l_object1_id1, l_object1_id2, l_no_of_items;
        CLOSE l_item_csr;

        IF l_object_code IS NULL THEN
            RETURN(NULL);
        END IF;

        OKC_UTIL.GET_NAME_DESC_FROM_JTFV
        (p_object_code => l_object_code
         , p_id1 => l_object1_id1
         , p_id2 => l_object1_id2
         , x_name => l_name
         , x_description => l_desc);
        IF p_lse_id IN(8, 10, 11, 35) THEN
            l_formatted_invoice_text := SUBSTR(p_item_desc || ':' || l_no_of_items || ':' || l_desc || ':' || p_start_date || ':' || p_end_date, 1, 450);
        ELSE
            IF fnd_profile.VALUE('OKS_ITEM_DISPLAY_PREFERENCE') = 'DISPLAY_DESC' THEN
                l_desc := l_desc;
            ELSE
                l_desc := l_name;
            END IF;
            l_formatted_invoice_text := SUBSTR(p_item_desc || ':' || l_no_of_items || ':' || l_desc || ':' || p_start_date || ':' || p_end_date, 1, 450);
        END IF;
        RETURN(l_formatted_invoice_text);
    END GetFormattedInvoiceText;



    BEGIN NULL;

        OPEN  l_cle_csr(p_cle_id);
        LOOP
            FETCH l_cle_csr INTO l_cle_rec;
            EXIT WHEN l_cle_csr%NOTFOUND;
            l_klnv_tbl_in(1).cle_id := l_cle_rec.line_id;
            l_klnv_tbl_in(1).id := l_cle_rec.kln_id;
            l_klnv_tbl_in(1).object_version_number := l_cle_rec.object_version_number;
            l_klnv_tbl_in(1).invoice_text := GetFormattedInvoiceText
            (l_cle_rec.line_id
             , l_cle_rec.start_date
             , l_cle_rec.end_date
             , p_item_desc
             , l_cle_rec.lse_id);

            --*
            calculate_tax(p_chr_id => l_cle_rec.chr_id,
                          p_amt => l_cle_rec.amt,
                          p_cle_id => l_cle_rec.line_id,
                          x_return_status => l_return_status,
                          x_msg_data => l_msg_data,
                          x_msg_count => l_msg_count,
                          x_tax_value => l_tax_value,
                          x_AMOUNT_INCLUDES_TAX_FLAG => l_AMOUNT_INCLUDES_TAX_FLAG,
                          x_total => l_total);
            --errorout('After Calculate Tax in UpdateIRTRule_Subline-'||l_return_status);
            --BUG#4066428 hkamdar 01/21/05
            x_return_status := l_return_status;
            --End BUG#4066428

            IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
                RAISE G_ERROR;
            END IF;
            l_klnv_tbl_in(1).tax_amount := l_tax_value;
            l_klnv_tbl_in(1).tax_inclusive_yn := l_AMOUNT_INCLUDES_TAX_FLAG;
            --      l_rulv_tbl_in(1).rule_information6 := l_total;



            oks_contract_line_pub.update_line (
                                               p_api_version => 1.0,
                                               p_init_msg_list => l_init_msg_list,
                                               x_return_status => l_return_status,
                                               x_msg_count => l_msg_count,
                                               x_msg_data => l_msg_data,
                                               p_klnv_tbl => l_klnv_tbl_in,
                                               x_klnv_tbl => lx_klnv_tbl,
                                               p_validate_yn => l_validate_yn) ;
            --errorout('After Update Line in UpdateIRTRule_Subline-'||l_return_status);
        END LOOP;
        CLOSE l_cle_csr;
        x_return_status := l_return_status;

    END UpdateIRTRule_Subline;


    --ADDED FOR Bug# 2364507

    PROCEDURE update_header_amount(p_cle_id IN NUMBER,
                                   x_status  OUT NOCOPY VARCHAR2) IS
    l_api_version  CONSTANT NUMBER := 1.0;
    l_init_msg_list VARCHAR2(2000) := OKC_API.G_FALSE;
    l_return_status VARCHAR2(1);
    l_msg_count  NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_msg_index_out NUMBER;
    l_chrv_tbl_in             okc_contract_pub.chrv_tbl_type;
    l_chrv_tbl_out            okc_contract_pub.chrv_tbl_type;

    CURSOR total_amount(p_chr_id IN NUMBER) IS
        SELECT nvl(SUM(price_negotiated), 0) SUM
        FROM okc_k_lines_b
        WHERE dnz_chr_id = p_chr_id
        AND lse_id IN (7, 8, 9, 10, 11, 35, 13, 18, 25)
        AND date_cancelled IS NULL; --ignore cancelled sublines

    BEGIN
        x_status := OKC_API.G_RET_STS_SUCCESS;
        IF p_cle_id IS NOT NULL THEN
            FOR cur_total_amount IN total_amount(g_chr_id)
                LOOP
                l_chrv_tbl_in(1).id := g_chr_id;
                l_chrv_tbl_in(1).estimated_amount := cur_total_amount.SUM;
                okc_contract_pub.update_contract_header (
                                                         p_api_version => l_api_version,
                                                         p_init_msg_list => l_init_msg_list,
                                                         x_return_status => l_return_status,
                                                         x_msg_count => l_msg_count,
                                                         x_msg_data => l_msg_data,
                                                         p_chrv_tbl => l_chrv_tbl_in,
                                                         x_chrv_tbl => l_chrv_tbl_out );
                x_status := l_return_status;
            END LOOP;
        END IF;
    END update_header_amount;

    PROCEDURE CopyService(p_api_version   IN  NUMBER
                          , p_init_msg_list IN  VARCHAR2
                          , p_source_rec    IN  copy_source_rec
                          , p_target_tbl    IN  copy_target_tbl
                          , x_return_status OUT NOCOPY VARCHAR2
                          , x_msg_count     OUT NOCOPY NUMBER
                          , x_msg_data      OUT NOCOPY VARCHAR2
                          , p_change_status IN VARCHAR2) -- Added an additional flag parameter, p_change_status,
    -- to decide whether to allow change of status of sublines
    -- of the topline during update service
    IS

    CURSOR header_cur IS
        SELECT dnz_chr_id, start_date, end_date, object_version_number, lse_id
        FROM   okc_k_lines_b
        WHERE  id = p_source_rec.cle_id;

    CURSOR get_contract_modifier_cur (p_chr_id NUMBER)
        IS
        SELECT contract_number_modifier
        FROM   okc_k_headers_b
        WHERE  id = p_chr_id;


    l_target_tbl        copy_target_tbl;
    idx                 NUMBER;
    l_rgp_id            NUMBER;
    l_return_status     VARCHAR2(20);
    l_rev_tbl           OKS_REV_DISTR_PUB.rdsv_tbl_type;
    l_salescr_tbl       OKS_SALES_CREDIT_PUB.scrv_tbl_type;
    l_msg_index         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_total_pct         NUMBER := 0;
    l_rev_found         BOOLEAN := FALSE;
    l_scr_found         BOOLEAN := FALSE;
    l_top_line_number   NUMBER := 0;
    G_ERROR             EXCEPTION;
    l_object_version_number  NUMBER;

    --ADDED FOR Bug# 2364507
    l_covtemp_id        NUMBER;
    l_cov_id            NUMBER;
    l_start_date        DATE;
    l_end_date          DATE;
    --l_ac_rec            OKS_COVERAGES_PUB.ac_rec_type;
    l_msg_count         NUMBER;
    l_oie_id            okc_operation_instances.id%TYPE;
    --ADDED FOR Bug# 2364507
    l_select_renewal_flag BOOLEAN;
    l_operation_lines_tbl opn_lines_tbl;
    l_contract_modifier okc_k_headers_b.contract_number_modifier%TYPE;
    l_init_msg_list             VARCHAR2(1000);
    l_curr_price_negotiated_amt NUMBER;
    l_curr_sum_negotiated_amt   NUMBER;


    --LLC

    l_curr_cancelled_amt	NUMBER;
    l_curr_sum_cancelled_amt	NUMBER;
    l_topline_cancelled_amt     NUMBER;
    l_prorated_cancelled_amt    NUMBER;
    l_adjusted_prorated_amt	NUMBER;
    l_cancelled_amt             NUMBER;
    l_sum_price_negotiated_lines    NUMBER;
    l_sum_cancelled_amt_lines   NUMBER;
    l_topline_tax_amount        NUMBER;
    l_curr_topline_tax_amt      NUMBER;
    l_hdr_tax_amt               NUMBER;
    l_curr_hdr_tax_amt          NUMBER;

    --LLC

    l_lse_id                    NUMBER;
    l_api_components_tbl        OKS_COPY_CONTRACT_PVT.api_components_tbl;
    l_lines_tbl                 OKS_COPY_CONTRACT_PVT.api_lines_tbl;
    l_published_line_ids_tbl_i  NUMBER;
    l_published_line_ids_tbl    OKS_COPY_CONTRACT_PVT.published_line_ids_tbl;
    lx_to_chr_id                NUMBER;


    /*   CURSOR rule_group_cur(p_cle_id IN NUMBER) IS
    SELECT id
    FROM  okc_rule_groups_b
    WHERE cle_id = p_cle_id; */

    CURSOR item_cur (p_cle_id IN NUMBER) IS
        SELECT object1_id1, object1_id2, jtot_object1_code
        FROM   okc_k_items
        WHERE cle_id = p_cle_id;

    item_rec    item_cur%ROWTYPE;

    --TAX

    CURSOR get_price_negotiated_amt_csr (p_cle_id IN NUMBER) IS
        SELECT nvl(SUM(price_negotiated), 0) amt
        FROM   okc_k_lines_b
        WHERE  cle_id = p_cle_id
        AND	   date_cancelled IS NULL; ---Added condition to exclude cancelled sublines

    get_price_negotiated_amt_rec		get_price_negotiated_amt_csr%ROWTYPE;

    CURSOR sum_price_negotiated_lines_csr (p_chr_id NUMBER) IS
        SELECT nvl(SUM(price_negotiated), 0) amt
        FROM   okc_k_lines_b
        WHERE  dnz_chr_id = p_chr_id
        AND cle_id IS NULL
        AND	 date_cancelled IS NULL; ---Added condition to exclude cancelled lines

    CURSOR l_hdr_curr(p_chr_id IN NUMBER)
        IS
        SELECT currency_code
        FROM   okc_k_headers_b
        WHERE  id = p_chr_id;

    l_curr_code  VARCHAR2(3);

    sum_price_negotiated_lines_rec	sum_price_negotiated_lines_csr%ROWTYPE;

    l_total                   NUMBER;
    l_Tax_Value                NUMBER;
    l_AMOUNT_INCLUDES_TAX_FLAG VARCHAR2(1);

    --LLC CANCELLED_AMOUNT

    CURSOR sum_cancelled_amt_lines_csr (p_chr_id NUMBER) IS
        SELECT SUM(nvl(cancelled_amount, 0))
        FROM   okc_k_lines_b
        WHERE  dnz_chr_id = p_chr_id
        AND cle_id IS NULL;


    CURSOR get_topline_cancelled_amt (p_cle_id IN NUMBER) IS
        SELECT nvl(SUM(nvl(price_negotiated, 0)), 0) --BUG FIX 4758886 --Forced to return this query 0 value
        FROM  okc_k_lines_b
        WHERE cle_id = p_cle_id
        AND   date_cancelled IS NOT NULL; --Condition to consider only the cancelled sublines




    BEGIN
        l_target_tbl := p_target_tbl;
        IF l_target_tbl.COUNT = 0 THEN
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
            RETURN;
        END IF;
        OPEN  header_cur;
        FETCH header_cur INTO g_chr_id, l_start_date, l_end_date, l_object_version_number, l_lse_id ;
        CLOSE header_cur;

        OPEN item_cur (p_source_rec.cle_id);
        FETCH item_cur INTO item_rec;
        CLOSE item_cur;

        OPEN l_hdr_curr(g_chr_id);
        FETCH l_hdr_curr INTO l_curr_code;
        CLOSE l_hdr_curr;


        CreateOperationInstance(p_chr_id => g_chr_id
                                , p_object1_id1 => item_rec.object1_id1
                                , p_object1_id2 => item_rec.object1_id2
                                , p_jtot_object1_code => item_rec.jtot_object1_code
                                , x_return_status => l_return_status
                                , x_oie_id => l_oie_id);
        --errorout('After CreateOperationInstance-'||l_return_status);
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            RAISE G_ERROR;
        END IF;

        --First copy the source line to create all target lines.
        idx := l_target_tbl.FIRST;
        -- The original source line will become the first target line.(so, don't copy)
        l_target_tbl(idx).cle_id := p_source_rec.cle_id;
        -- If there are more target lines then make copies of the source line for each
        -- and update the l_target_tbl with the new line id.

        IF idx <> l_target_tbl.LAST THEN
            idx := l_target_tbl.NEXT(idx);
            get_rev_distr(p_source_rec.cle_id, l_rev_tbl);
            IF l_rev_tbl.COUNT > 0 THEN
                l_rev_found := TRUE;
            END IF;
            get_sales_cred(p_source_rec.cle_id, l_salescr_tbl);
            IF l_salescr_tbl.COUNT > 0 THEN
                l_scr_found := TRUE;
            END IF;

            --Fix for bug#2221910 start.  Get Max Of Top Lines.

            SELECT nvl(MAX(to_number(line_number)), 0)
            INTO   l_top_line_number
            FROM   OKC_K_LINES_B
            WHERE  dnz_chr_id = g_chr_id
            AND    cle_id IS NULL;
            --Fix for bug#2221910 end.

            LOOP

                /***
                OKC_COPY_CONTRACT_PUB.copy_contract_lines(
                p_api_version    => p_api_version,
                p_init_msg_list  => p_init_msg_list,
                x_return_status  => l_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_from_cle_id    => p_source_rec.cle_id,
                p_to_chr_id      => g_chr_id,
                x_cle_id         => l_target_tbl(idx).cle_id,
                p_change_status  => p_change_status); -- Added an additional flag parameter, p_change_status,
                -- to decide whether to allow change of status of sublines
                -- of the topline during update service

                --errorout('After copy_contract_lines-'||l_return_status);
                IF l_return_status  <> OKC_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
                RAISE G_ERROR;
                ELSE
                OKS_SETUP_UTIL_PUB.Okscopy
                (p_chr_id => g_chr_id,
                p_cle_id => NULL,
                x_return_status => l_return_status,
                p_upd_line_flag => 'Y',
                p_bill_profile_flag => NULL
                );
                --errorout('After OKSCOPY-'||l_return_status);
                END IF;
                ***/

                --replaced above call with call to new copy API. This will ensure that all new R12 columns will be correctly copied.
                --Bug 4747648
                l_lines_tbl(1).id := p_source_rec.cle_id;
                l_lines_tbl(1).to_k := NULL;
                l_lines_tbl(1).to_line := NULL;
                l_lines_tbl(1).lse_id := l_lse_id;
                l_lines_tbl(1).line_exists_yn := NULL;
                l_lines_tbl(1).line_exp_yn := 'Y'; -- this will make sure all sublines are copied

                OKS_COPY_CONTRACT_PVT.copy_components (
                                                       p_api_version => p_api_version,
                                                       p_init_msg_list => p_init_msg_list,
                                                       x_return_status => l_return_status,
                                                       x_msg_count => x_msg_count,
                                                       x_msg_data => x_msg_data,
                                                       p_from_chr_id => g_chr_id,
                                                       p_to_chr_id => g_chr_id,
                                                       p_contract_number => NULL,
                                                       p_contract_number_modifier => NULL,
                                                       p_to_template_yn => 'N',
                                                       p_components_tbl => l_api_components_tbl,  --empty
                                                       p_lines_tbl => l_lines_tbl,
                                                       p_change_status_YN => p_change_status,  -- Added an additional flag parameter, p_change_status
                                                       -- to decide whether to allow change of status of sublines
                                                       -- of the topline during update service
                                                       p_return_new_top_line_ID_YN => 'Y',
                                                       x_to_chr_id => lx_to_chr_id,
                                                       p_published_line_ids_tbl => l_published_line_ids_tbl
                                                       );

                l_published_line_ids_tbl_i := l_published_line_ids_tbl.FIRST;
                l_target_tbl(idx).cle_id := l_published_line_ids_tbl(l_published_line_ids_tbl_i).new_line_id;
                --end Bug 4747648

                IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    x_return_status := l_return_status;
                    RAISE G_ERROR;
                END IF;

                --Fix for bug#2221910 start.  Update Top Line Sequence number.

                l_top_line_number := l_top_line_number + 1;
                UPDATE okc_k_lines_b SET line_number = l_top_line_number
                WHERE  id = l_target_tbl(idx).cle_id;
                --Fix for bug#2221910 end.

                IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    x_return_status := l_return_status;
                    RAISE G_ERROR;
                END IF;



                /************* Commented out because this is being taken care of by OKSCOPY

                IF l_rev_found THEN
                create_rev_distr(l_target_tbl(idx).cle_id, l_rev_tbl, l_return_status);
                IF l_return_status  <> OKC_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
                RAISE G_ERROR;
                END IF;
                END IF;
                IF l_scr_found THEN
                create_sales_cred(l_target_tbl(idx).cle_id, l_salescr_tbl, l_return_status);
                IF l_return_status  <> OKC_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
                RAISE G_ERROR;
                END IF;
                END IF;  **********/


                EXIT WHEN idx = l_target_tbl.LAST;
                idx := l_target_tbl.NEXT(idx);
            END LOOP;
        END IF;
        -- Now update each target line with the new item id, amount et cetera.
        idx := l_target_tbl.FIRST;
        LOOP
            update_line_item(l_target_tbl(idx).cle_id, l_target_tbl(idx).item_id, l_return_status);
            --errorout('After update_line_item-'||l_return_status);
            IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
                RAISE G_ERROR;
            END IF;

            IF l_target_tbl(idx).percentage <> 100 THEN

                --LLC

                --Changes to p_amount being passed when prorated_amount procedure is called, so that p_amount
                --also contains prorated cancelled_amount along with prorated price_negotiated of topline
                --the new adjdusted prorated amount is stored in l_adjusted_prorated_amt

                OPEN get_topline_cancelled_amt(l_target_tbl(idx).cle_id);
                FETCH get_topline_cancelled_amt INTO l_topline_cancelled_amt;
                CLOSE get_topline_cancelled_amt;

                l_prorated_cancelled_amt := l_topline_cancelled_amt * l_target_tbl(idx).percentage / 100.0;
                l_adjusted_prorated_amt := l_target_tbl(idx).amount + l_prorated_cancelled_amt;

                prorate_amount(l_target_tbl(idx).cle_id, l_target_tbl(idx).percentage, l_adjusted_prorated_amt, l_return_status);

                --LLC

                --errorout('After prorate_amount-'||l_return_status);
                IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    x_return_status := l_return_status;
                    RAISE G_ERROR;
                END IF;

                refresh_bill_sch(l_target_tbl(idx).cle_id, l_return_status);
                --errorout('After refresh_bill_sch-'||l_return_status);
                IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    x_return_status := l_return_status;
                    RAISE G_ERROR;
                END IF;
            END IF;

            -- Start Bug# 2701879
            l_contract_modifier := NULL;

            OPEN get_contract_modifier_cur (g_chr_id);
            FETCH get_contract_modifier_cur INTO l_contract_modifier;
            CLOSE get_contract_modifier_cur;
            --Call procedure to get date_renewed of header and lines
            --if modifier exists
            --
            IF l_contract_modifier IS NOT NULL
                THEN
                select_renewal_info
                (p_chr_id => g_chr_id,
                 x_operation_lines_tbl => l_operation_lines_tbl
                 );
                l_select_renewal_flag := TRUE;
            ELSE
                l_select_renewal_flag := FALSE;
            END IF;

            -- Start Bug# 2701879

            --ADDED FOR Bug# 2364507
            l_cov_id := GetCoverage(l_target_tbl(idx).cle_id);

            IF l_cov_id IS NOT NULL
                THEN
                OKS_COVERAGES_PUB.Undo_Line
                (p_api_version => 1.0
                 , p_init_msg_list => 'T'
                 , x_return_status => l_return_status
                 , x_msg_count => l_msg_count
                 , x_msg_data => l_msg_data
                 , p_line_id => l_cov_id);
                --errorout('After Undo_Line-'||l_return_status);
                IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    x_return_status := l_return_status;
                    RAISE G_ERROR;
                END IF;
            END IF;

            --start bug#2701879
            --Call procedure to update date_renewed of header and lines
            --if modifier exists
            --
            IF l_select_renewal_flag
                THEN
                IF l_operation_lines_tbl.COUNT > 0
                    THEN
                    update_renewal_info
                    (p_operation_lines_tbl => l_operation_lines_tbl,
                     x_return_status => l_return_status,
                     x_msg_count => l_msg_count,
                     x_msg_data => l_msg_data
                     );
                    --errorout('After update_renewal_info-'||l_return_status);
                END IF;
            END IF;
            --
            IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
                RAISE G_ERROR;
            END IF;

            --end bug#2701879

            l_covtemp_id := GetCoverageTemplate(l_target_tbl(idx).item_id);

            IF l_covtemp_id IS NOT NULL
                THEN
                /**
                l_ac_rec.svc_cle_id := l_target_tbl(idx).cle_id;
                l_ac_rec.tmp_cle_id := l_covtemp_id;
                l_ac_rec.start_date := l_start_date;
                l_ac_rec.end_date   := l_end_date;

                OKS_COVERAGES_PUB.create_actual_coverage
                (p_api_version        => 1.0
                ,p_init_msg_list      => 'T'
                ,p_ac_rec_in          => l_ac_rec
                ,x_return_status      => l_return_status
                ,x_msg_count          => l_msg_count
                ,x_msg_data           => l_msg_data
                ,x_actual_coverage_id => l_cov_id);
                --errorout('After create_actual_coverage-'||l_return_status);
                IF l_return_status  <> OKC_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
                RAISE G_ERROR;
                END IF;
                **/
                --Bug 4718226: need to create standard coverage to service line after split
                UPDATE oks_k_lines_b
                SET coverage_id = l_covtemp_id,
                    standard_cov_yn = 'Y'
                WHERE cle_id = l_target_tbl(idx).cle_id;


            END IF;
            l_covtemp_id := NULL;
            l_cov_id := NULL;

            --LLC Earlier: Call made to UpdateIRTRule and then UpdateIRTRule_Subline
            --LLC Now: Call made to UpdateIRTRule_Subline and then to UpdateIRTRule

            UpdateIRTRule_Subline(p_cle_id => l_target_tbl(idx).cle_id
                                  , p_item_desc => l_target_tbl(idx).item_desc
                                  , p_start_date => l_start_date
                                  , p_end_date => l_end_date
                                  , x_return_status => l_return_status);
            --errorout('After UpdateIRTRule_SubLine-'||l_return_status);
            IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
                RAISE G_ERROR;
            END IF;
            --ADDED FOR Bug# 2364507


            UpdateIRTRule(p_chr_id => g_chr_id
                          , p_cle_id => l_target_tbl(idx).cle_id --LLC ealier: p_source_rec.cle_id
                          , p_invoice_text => GetFormattedInvoiceText
                          (l_target_tbl(idx).item_desc, l_start_date, l_end_date)
                          , p_api_version => 1.0
                          , p_init_msg_list => l_init_msg_list
                          , x_return_status => l_return_status
                          , x_tax_value => l_tax_value
                          , x_AMOUNT_INCLUDES_TAX_FLAG => l_AMOUNT_INCLUDES_TAX_FLAG
                          , x_total => l_total);

            --errorout('After UpdateIRTRule-'||l_return_status);

            IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
                RAISE G_ERROR;
            END IF;



            --*

            --price_negotiated for the topline

            OPEN get_price_negotiated_amt_csr(l_target_tbl(idx).cle_id);
            FETCH get_price_negotiated_amt_csr INTO get_price_negotiated_amt_rec;
            CLOSE get_price_negotiated_amt_csr;

            l_curr_price_negotiated_amt := OKS_EXTWAR_UTIL_PVT.Round_Currency_amt
            (get_price_negotiated_amt_rec.amt,
             l_curr_code
             );

            --LLC

            --CANCELLED_AMOUNT for the topline

            OPEN get_topline_cancelled_amt(l_target_tbl(idx).cle_id);
            FETCH get_topline_cancelled_amt INTO l_cancelled_amt;
            CLOSE get_topline_cancelled_amt;


            l_curr_cancelled_amt := OKS_EXTWAR_UTIL_PVT.Round_Currency_amt
            (l_cancelled_amt,
             l_curr_code
             );
            --Updating topline with the price_negotiated and cancelled_amount

            UPDATE okc_k_lines_b
            SET	price_negotiated = l_curr_price_negotiated_amt,
             cancelled_amount = l_curr_cancelled_amt
            WHERE id = l_target_tbl(idx).cle_id;

            --Estimated_amount for the header

            OPEN sum_price_negotiated_lines_csr(g_chr_id);
            FETCH sum_price_negotiated_lines_csr INTO l_sum_price_negotiated_lines;
            CLOSE sum_price_negotiated_lines_csr;


            l_curr_sum_negotiated_amt := OKS_EXTWAR_UTIL_PVT.Round_Currency_amt
            (l_sum_price_negotiated_lines,
             l_curr_code

             );

            --CANCELLED_AMOUNT for contract

            OPEN sum_cancelled_amt_lines_csr(g_chr_id);
            FETCH sum_cancelled_amt_lines_csr INTO l_sum_cancelled_amt_lines;
            CLOSE sum_cancelled_amt_lines_csr;


            l_curr_sum_cancelled_amt := OKS_EXTWAR_UTIL_PVT.Round_Currency_amt
            (l_sum_cancelled_amt_lines,
             l_curr_code
             );

            --Updating Header with the estimated_amount and cancelled_amount

            UPDATE okc_k_headers_b
            SET estimated_amount = l_curr_sum_negotiated_amt,
             cancelled_amount = l_curr_sum_cancelled_amt
            WHERE id = g_chr_id;

            --LLC



            --*
            --errorout('Calling CreateOperationlines');
            CreateOperationLines(p_chr_id => g_chr_id
                                 , p_object_line_id => p_source_rec.cle_id
                                 , p_subject_line_id => l_target_tbl(idx).cle_id
                                 , p_oie_id => l_oie_id
                                 , x_return_status => l_return_status);

            --errorout('After CreateOperationlines-'||l_return_status);
            IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
                RAISE G_ERROR;
            END IF;
            l_total_pct := l_total_pct + l_target_tbl(idx).percentage;
            EXIT WHEN idx = l_target_tbl.LAST;
            idx := l_target_tbl.NEXT(idx);
        END LOOP;
        IF l_total_pct <> 100 THEN
            update_header_amount(p_source_rec.cle_id, l_return_status);
            --errorout('After update_header-'||l_return_status);
            IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
                RAISE G_ERROR;
            END IF;
        END IF;
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
    EXCEPTION
        WHEN G_ERROR THEN
            NULL;
        WHEN OTHERS THEN
            OKC_API.set_message(OKC_API.G_APP_NAME,
                                'OKS_UNEXP_ERROR',
                                'SQLcode',
                                SQLCODE,
                                'SQLerrm',
                                SQLERRM);
            -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END CopyService;


    -- Begin modifications for new HZ_CONTACT_POINTS_V2PUB for TCA uptake, aiyengar 11/20/02


    PROCEDURE Create_Contact_Points
    (
     p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2,
     p_commit              IN   VARCHAR2,
     P_contact_point_rec   IN   contact_point_rec,
     x_return_status       OUT NOCOPY  VARCHAR2,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2,
     x_contact_point_id    OUT NOCOPY  NUMBER)
    IS

    l_contact_point_rec      HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
    l_email_rec_type         HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
    l_phone_rec_type         HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
    l_web_rec_type           HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE ;
    l_telex_rec_type         HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
    l_edi_rec_type           HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;

    G_ERROR                  EXCEPTION;

    BEGIN

        --commented out intialization for bug#3392035
        --l_contact_point_rec.contact_point_id    := FND_API.G_MISS_NUM;

        l_contact_point_rec.contact_point_id := p_contact_point_rec.contact_point_id;
        l_contact_point_rec.contact_point_type := p_contact_point_rec.contact_point_type;
        l_contact_point_rec.status := p_contact_point_rec.status;
        l_contact_point_rec.owner_table_name := p_contact_point_rec.owner_table_name;
        l_contact_point_rec.owner_table_id := p_contact_point_rec.owner_table_id;
        l_contact_point_rec.primary_flag := p_contact_point_rec.primary_flag;

        l_contact_point_rec.created_by_module := 'OKS_AUTH';

        IF l_contact_point_rec.contact_point_type = 'EMAIL' THEN
            l_email_rec_type.email_address := p_contact_point_rec.email_address;
        ELSIF l_contact_point_rec.contact_point_type IN('PHONE', 'FAX', 'MOBILE') THEN
            IF l_contact_point_rec.contact_point_type = 'PHONE' THEN
                l_phone_rec_type.phone_line_type := 'GEN';
            ELSIF l_contact_point_rec.contact_point_type = 'FAX' THEN
                l_contact_point_rec.contact_point_type := 'PHONE';
                l_phone_rec_type.phone_line_type := 'FAX';
            ELSIF l_contact_point_rec.contact_point_type = 'MOBILE' THEN -- added for contact creation
                l_contact_point_rec.contact_point_type := 'PHONE'; -- added for contact creation
                l_phone_rec_type.phone_line_type := 'MOBILE'; -- added for contact creation
            END IF;
            l_phone_rec_type.phone_number := p_contact_point_rec.email_address;
            --Added following codition to make area code null if area code having no value 3392035
            IF  p_contact_point_rec.area_code IS NULL
                THEN
                l_phone_rec_type.phone_area_code := FND_API.G_MISS_CHAR;
            ELSE
                l_phone_rec_type.phone_area_code := p_contact_point_rec.area_code;
            END IF;
            -- added for contact creation
            IF p_contact_point_rec.phone_country_code IS NULL
                THEN
                l_phone_rec_type.phone_country_code := FND_API.G_MISS_CHAR; -- added for contact creation
            ELSE
                l_phone_rec_type.phone_country_code := p_contact_point_rec.phone_country_code; -- added for contact creation
            END IF;
            --contact creation end

        END IF;

        HZ_CONTACT_POINT_V2PUB.create_contact_point (
                                                     p_init_msg_list => p_init_msg_list,
                                                     p_contact_point_rec => l_contact_point_rec,
                                                     p_email_rec => l_email_rec_type,
                                                     p_phone_rec => l_phone_rec_type,
                                                     x_contact_point_id => x_contact_point_id,
                                                     x_return_status => x_return_status,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data => x_msg_data
                                                     );

        IF x_return_status <> 'S' THEN
            RAISE G_ERROR;
        END IF;

    EXCEPTION
        WHEN G_ERROR THEN
            NULL;
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END Create_Contact_Points;

    PROCEDURE Update_Contact_Points
    (
     p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2,
     P_commit              IN   VARCHAR2,
     P_contact_point_rec   IN   contact_point_rec,
     x_return_status       OUT NOCOPY  VARCHAR2,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2)
    IS
    l_object_Version_number  NUMBER := 1 ;
    l_contact_point_rec      HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
    l_email_rec_type         HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
    l_phone_rec_type         HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
    G_ERROR                  EXCEPTION;

    CURSOR l_cpoint_csr IS
        SELECT last_update_date, object_version_number, contact_point_type
        FROM   HZ_CONTACT_POINTS
        WHERE  contact_point_id = P_contact_point_rec.contact_point_id;

    l_cpoint_rec l_cpoint_csr%ROWTYPE;

    BEGIN

        l_contact_point_rec.contact_point_id := P_contact_point_rec.contact_point_id;

        OPEN  l_cpoint_csr;
        FETCH l_cpoint_csr INTO l_cpoint_rec;
        CLOSE l_cpoint_csr;

        IF l_cpoint_rec.contact_point_type = 'EMAIL' THEN
            l_email_rec_type.email_address := p_contact_point_rec.email_address;
        ELSIF l_cpoint_rec.contact_point_type IN ('PHONE', 'FAX') THEN
            l_phone_rec_type.phone_number := p_contact_point_rec.email_address;

            --ADDED following condition to make area code null 3392035
            IF p_contact_point_rec.area_code IS NULL
                THEN
                l_phone_rec_type.phone_area_code := FND_API.G_MISS_CHAR;
            ELSE
                l_phone_rec_type.phone_area_code := p_contact_point_rec.area_code;
            END IF;
            -- added for contact creation OCT 2004
            IF p_contact_point_rec.phone_country_code IS NULL
                THEN
                l_phone_rec_type.phone_country_code := FND_API.G_MISS_CHAR; -- added for contact creation
            ELSE
                l_phone_rec_type.phone_country_code := p_contact_point_rec.phone_country_code; -- added for contact creation
            END IF;
            --contact creation end OCT 2004

        END IF;
        l_object_version_number := l_cpoint_rec.object_Version_number;

        HZ_CONTACT_POINT_V2PUB.update_contact_point (
                                                     p_init_msg_list => p_init_msg_list,
                                                     p_contact_point_rec => l_contact_point_rec,
                                                     p_email_rec => l_email_rec_type,
                                                     p_phone_rec => l_phone_rec_type,
                                                     x_return_status => x_return_status,
                                                     x_msg_count => x_msg_count,
                                                     x_msg_data => x_msg_data,
                                                     p_object_version_number => l_object_version_number
                                                     );
        IF x_return_status <> 'S' THEN
            RAISE G_ERROR;
        END IF;

    EXCEPTION
        WHEN G_ERROR THEN
            NULL;
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);

    END Update_Contact_Points;

    -- End modifications for new HZ_CONTACT_POINTS_V2PUB for TCA uptake, aiyengar 11/20/02

    PROCEDURE CreateOperationInstance(p_chr_id IN NUMBER
                                      , p_object1_id1 IN VARCHAR2
                                      , p_object1_id2 IN VARCHAR2
                                      , p_jtot_object1_code IN VARCHAR2
                                      , x_return_status OUT NOCOPY VARCHAR2
                                      , x_oie_id OUT NOCOPY NUMBER)
    IS

    CURSOR c_clopn_split_csr IS
        SELECT id
        FROM   okc_class_operations
        WHERE  CLS_CODE = 'SERVICE'
        AND    OPN_CODE = 'SPLIT';

    l_split_Id    NUMBER := NULL;

    l_api_version      NUMBER := 1.0;
    l_init_msg_list    VARCHAR2(1) := G_TRUE;
    l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);

    l_oiev_tbl   OKC_OPER_INST_PVT.oiev_tbl_type;
    x_oiev_tbl   OKC_OPER_INST_PVT.oiev_tbl_type;

    BEGIN

        OPEN  c_clopn_split_csr;
        FETCH c_clopn_split_csr INTO l_split_id;
        CLOSE c_clopn_split_csr;
        IF l_split_id IS NULL THEN
            x_return_status := G_RET_STS_ERROR;
            OKC_API.set_message(G_APP_NAME_OKS, 'OKS_CLS_OPN_NOT_FOUND');
            RAISE G_ERROR;
        END IF;

        l_oiev_tbl(1).cop_id := l_split_id;
        l_oiev_tbl(1).status_code := 'PROCESSED';
        l_oiev_tbl(1).target_chr_id := p_chr_id;
        l_oiev_tbl(1).object1_id1 := p_object1_id1;
        l_oiev_tbl(1).object1_id2 := p_object1_id2;
        l_oiev_tbl(1).jtot_object1_code := p_jtot_object1_code;
        OKC_OPER_INST_PUB.Create_Operation_Instance
        (p_api_version => l_api_version
         , p_init_msg_list => l_init_msg_list
         , x_return_status => l_return_status
         , x_msg_count => l_msg_count
         , x_msg_data => l_msg_data
         , p_oiev_tbl => l_oiev_tbl
         , x_oiev_tbl => x_oiev_tbl);
        IF l_return_status <> G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            RAISE G_ERROR;
        END IF;

        --BUG#4066428 hkamdar 01/21/05
        x_return_status := l_return_status;
        --End BUG#4066428
        x_oie_id := x_oiev_tbl(1).id;
    EXCEPTION
        WHEN G_ERROR THEN
            NULL;
        WHEN OTHERS THEN
            OKC_API.set_message(G_APP_NAME_OKS,
                                'OKS_UNEXP_ERROR',
                                'SQLcode',
                                SQLCODE,
                                'SQLerrm',
                                SQLERRM);
            -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END CreateOperationInstance;

    PROCEDURE CreateOperationLines(p_chr_id IN NUMBER
                                   , p_object_line_id IN NUMBER
                                   , p_subject_line_id IN NUMBER
                                   , p_oie_id IN NUMBER
                                   --BUG#4066428 01/24/05 hkamdar
                                   --,x_return_status OUT NOCOPY NUMBER)
                                   , x_return_status OUT NOCOPY VARCHAR2)
    --End BUG#4066428 01/24/05 hkamdar
    IS
    l_api_version      NUMBER := 1.0;
    l_init_msg_list    VARCHAR2(1) := G_TRUE;
    l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_olev_tbl   OKC_OPER_INST_PVT.olev_tbl_type;
    x_olev_tbl   OKC_OPER_INST_PVT.olev_tbl_type;
    BEGIN
        --  errorout('In Operation Lines');
        l_olev_tbl(1).oie_id := p_oie_id;
        l_olev_tbl(1).subject_chr_id := p_chr_id;
        l_olev_tbl(1).object_chr_id := p_chr_id;
        l_olev_tbl(1).subject_cle_id := p_subject_line_id;
        l_olev_tbl(1).object_cle_id := p_object_line_id;
        OKC_OPER_INST_PUB.Create_Operation_Line
        (p_api_version => l_api_version
         , p_init_msg_list => l_init_msg_list
         , x_return_status => l_return_status
         , x_msg_count => l_msg_count
         , x_msg_data => l_msg_data
         , p_olev_tbl => l_olev_tbl
         , x_olev_tbl => x_olev_tbl);

        --	errorout('After calling Create_Operation_Line in OPLINES-'||l_return_status);
        IF l_return_status <> G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            RAISE G_ERROR;
        END IF;

        --BUG#4066428 hkamdar 01/21/05
        x_return_status := l_return_status;
        --End BUG#4066428
        --errorout('End CreateOperationlines');
    EXCEPTION
        WHEN G_ERROR THEN
            NULL;
        WHEN OTHERS THEN
            OKC_API.set_message(G_APP_NAME_OKS,
                                'OKS_UNEXP_ERROR',
                                'SQLcode',
                                SQLCODE,
                                'SQLerrm',
                                SQLERRM);
            -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END CreateOperationLines;


    PROCEDURE CREATE_CII_FOR_SUBSCRIPTION
    (
     p_api_version   IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY NUMBER,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_cle_id        IN NUMBER,
     p_quantity      IN NUMBER DEFAULT 1,
     x_instance_id   OUT NOCOPY NUMBER

     )

    IS

    p_instance_rec          CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
    p_ext_attrib_values_tbl CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
    p_party_tbl             CSI_DATASTRUCTURES_PUB.PARTY_TBL;
    p_account_tbl           CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
    p_pricing_attrib_tbl    CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
    p_org_assignments_tbl   CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
    p_asset_assignment_tbl  CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
    p_txn_rec               CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;

    t_output                VARCHAR2(2000);
    t_msg_dummy             NUMBER;

    CURSOR l_get_item_id(p_cle_id IN NUMBER)
        IS
        SELECT object1_id1, object1_id2, dnz_chr_id, uom_code
        FROM   okc_k_items
        WHERE  cle_id = p_cle_id;


    CURSOR l_csr_Get_party_sites(p_party_id IN NUMBER)
        IS
        SELECT party_site_id
        FROM   HZ_PARTY_SITES
        WHERE  party_id = p_party_id
        AND    identifying_address_flag = 'Y';

    -- Get customer account id
    CURSOR l_csr_get_cust_acct_id(p_cle_id IN NUMBER)
        IS
        SELECT cust_acct_id
        FROM okc_k_lines_b
        WHERE id = p_cle_id;


    CURSOR l_Get_party_id(p_cust_acct_id IN NUMBER)
        IS
        SELECT party_id
        FROM   HZ_CUST_ACCOUNTS
        WHERE  cust_account_id = p_cust_acct_id;


    /*** Fetch inventory revision code **/

    CURSOR l_csr_chk_revision_control(p_item_id IN NUMBER, p_organization_id IN NUMBER)
        IS
        SELECT revision_qty_control_code
        FROM mtl_system_items_kfv
        WHERE  inventory_item_id = p_item_id
        AND    organization_id = p_organization_id;


    CURSOR l_csr_get_item_revision(p_item_id IN NUMBER, p_organization_id IN NUMBER)
        IS
        SELECT revision
        FROM   MTL_ITEM_REVISIONS_VL
        WHERE  inventory_item_id = p_item_id
        AND    organization_id = p_organization_id;


    /* Cursors for traversing logic to get site id */
    /*  Fetch ship_to_site_use_id and bill_to_site_use_id */


    l_inv_item_id   OKX_system_items_v.id1%TYPE;
    l_inv_organization_id   NUMBER;
    l_dnz_chr_id     NUMBER;
    l_party_id       NUMBER;
    l_uom            OKC_K_ITEMS.uom_code%TYPE;
    l_party_site_id  HZ_PARTY_SITES.party_site_id%TYPE;
    l_rgp_id         OKC_RULE_GROUPS_B.id%TYPE;
    l_cust_acct_id   OKX_CUSTOMER_ACCOUNTS_V.id1%TYPE;


    l_revision_control_yn    MTL_SYSTEM_ITEMS_KFV.revision_qty_control_code%TYPE;
    l_revision       MTL_ITEM_REVISIONS_VL.revision%TYPE;
    l_ship_to_site_use_id   OKC_K_HEADERS_B.ship_to_site_use_id%TYPE;
    l_bill_to_site_use_id   OKC_K_HEADERS_B.bill_to_site_use_id%TYPE;

    FUNCTION ship_to(p_cle_id IN NUMBER)
    RETURN NUMBER
    IS
    CURSOR l_csr_get_shipto_billto(p_cle_id IN NUMBER)
        IS
        SELECT ship_to_site_use_id, bill_to_site_use_id
        FROM   okc_k_lines_b
        WHERE  id = p_cle_id;


    CURSOR l_csr_partysite_from_custsite(p_shipto_or_billto IN NUMBER)
        IS
        SELECT party_site_id
        FROM okx_cust_site_uses_v
        WHERE id1 = p_shipto_or_billto ;

    l_shipto             NUMBER;
    l_billto             NUMBER;
    l_shipto_or_billto   NUMBER;
    l_party_site         NUMBER;

    BEGIN

        OPEN l_csr_get_shipto_billto(p_cle_id);
        FETCH l_csr_get_shipto_billto INTO l_shipto, l_billto;
        CLOSE l_csr_get_shipto_billto;

        IF l_shipto IS NOT NULL THEN
            l_shipto_or_billto := l_shipto;
        ELSIF l_billto IS NOT NULL THEN
            l_shipto_or_billto := l_billto;
        END IF;

        OPEN l_csr_partysite_from_custsite(l_shipto_or_billto);
        FETCH l_csr_partysite_from_custsite INTO l_party_site;
        CLOSE l_csr_partysite_from_custsite;

        RETURN l_party_site;

    END;


    BEGIN

        OPEN  l_get_item_id(p_cle_id);
        FETCH l_get_item_id INTO  l_inv_item_id, l_inv_organization_id, l_dnz_chr_id, l_uom;
        CLOSE l_get_item_id;


        OPEN  l_csr_get_cust_acct_id(p_cle_id);
        FETCH l_csr_get_cust_acct_id INTO l_cust_acct_id;
        CLOSE l_csr_get_cust_acct_id;


        IF l_cust_acct_id IS NULL THEN

            RAISE G_ERROR;
        END IF;


        OPEN  l_get_party_id(l_cust_acct_id);
        FETCH l_get_party_id INTO l_party_id;
        CLOSE l_get_party_id;



        OPEN  l_csr_get_party_sites(l_party_id);
        FETCH l_csr_get_party_sites INTO l_party_site_id;
        CLOSE l_csr_get_party_sites;

        -- Code added to check whether item is revision controlled or not
        -- And pass revision to create_item_instance api accordingly
        -- aiyengar

        OPEN l_csr_chk_revision_control(l_inv_item_id, l_inv_organization_id);
        FETCH l_csr_chk_revision_control INTO l_revision_control_yn ;
        CLOSE l_csr_chk_revision_control;

        IF l_revision_control_yn = 2 THEN
            OPEN l_csr_get_item_revision(l_inv_item_id, l_inv_organization_id);
            FETCH l_csr_get_item_revision INTO l_revision;
            CLOSE l_csr_get_item_revision;

        ELSE
            l_revision := '';

        END IF;


        ----------errorout(' party id '||l_party_id);
        ----------errorout(' inv items id '||l_inv_item_id);
        ----------errorout(' organization id '||l_inv_organization_id);
        -- dnz chr id  '||l_dnz_chr_id);
        p_instance_rec.instance_id := NULL;

        p_instance_rec.instance_number := '';
        p_instance_rec.external_reference := '';
        p_instance_rec.inventory_item_id := l_inv_item_id;
        p_instance_rec.vld_organization_id := l_inv_organization_id;
        p_instance_rec.inventory_revision := l_revision;
        --  p_instance_rec.inv_master_organization_id := l_inv_organization_id; --NULL;
        p_instance_rec.serial_number := NULL;
        p_instance_rec.mfg_serial_number_flag := '';
        p_instance_rec.quantity := p_quantity;
        p_instance_rec.unit_of_measure := l_uom;
        p_instance_rec.accounting_class_code := '';
        p_instance_rec.instance_condition_id := 1;
        p_instance_rec.instance_status_id := NULL;
        p_instance_rec.customer_view_flag := '';
        p_instance_rec.merchant_view_flag := '';
        p_instance_rec.sellable_flag := '';
        p_instance_rec.system_id := NULL;
        p_instance_rec.instance_type_code := '';
        p_instance_rec.active_start_date := '';
        p_instance_rec.active_end_date := '';

        p_instance_rec.in_transit_order_line_id := NULL;
        p_instance_rec.location_type_code := 'HZ_PARTY_SITES';
        p_instance_rec.location_id := NVL(ship_to(p_cle_id), l_party_site_id ) ;



        --  p_instance_rec.location_type_code := 'INVENTORY';
        -- p_instance_rec.location_id :=207 ;

        --  p_instance_rec.inv_organization_id :=l_inv_organization_id;
        --  p_instance_rec.inv_subinventory_name := 'Stores'; --'FGI';


        p_instance_rec.last_oe_order_line_id := NULL;
        p_instance_rec.last_oe_rma_line_id := NULL;
        p_instance_rec.last_po_po_line_id := NULL;
        p_instance_rec.last_oe_po_number := '';
        p_instance_rec.last_wip_job_id := NULL;
        p_instance_rec.last_pa_project_id := NULL;
        p_instance_rec.last_pa_task_id := NULL;
        p_instance_rec.last_oe_agreement_id := NULL;
        p_instance_rec.install_date := SYSDATE;
        p_instance_rec.manually_created_flag := '';
        p_instance_rec.return_by_date := '';
        p_instance_rec.actual_return_date := '';
        p_instance_rec.creation_complete_flag := '';
        p_instance_rec.completeness_flag := '';
        p_instance_rec.version_label := '';
        p_instance_rec.version_label_description := '';
        p_instance_rec.context := '';
        p_instance_rec.attribute1 := '';
        p_instance_rec.attribute2 := '';
        p_instance_rec.attribute3 := '';
        p_instance_rec.attribute4 := '';
        p_instance_rec.attribute5 := '';
        p_instance_rec.attribute6 := '';
        p_instance_rec.attribute7 := '';
        p_instance_rec.attribute8 := '';
        p_instance_rec.attribute9 := '';
        p_instance_rec.attribute10 := '';
        p_instance_rec.attribute11 := '';
        p_instance_rec.attribute12 := '';
        p_instance_rec.attribute13 := '';
        p_instance_rec.attribute14 := '';
        p_instance_rec.attribute15 := '';
        p_instance_rec.object_version_number := NULL;
        p_instance_rec.last_txn_line_detail_id := NULL;
        p_instance_rec.install_location_type_code := '';
        p_instance_rec.install_location_id := NULL;
        --  p_instance_rec.instance_usage_code := 'IN_TRANSIT';--'INSTALLED';

        p_party_tbl(1).instance_party_id := NULL;
        p_party_tbl(1).instance_id := NULL;
        p_party_tbl(1).party_source_table := 'HZ_PARTIES';
        p_party_tbl(1).party_id := l_party_id ;
        p_party_tbl(1).relationship_type_code := 'OWNER';
        p_party_tbl(1).contact_flag := 'N';
        p_party_tbl(1).contact_ip_id := NULL;
        p_party_tbl(1).active_start_date := '';
        p_party_tbl(1).active_end_date := '';
        p_party_tbl(1).context := '';
        p_party_tbl(1).attribute1 := '';
        p_party_tbl(1).attribute2 := '';
        p_party_tbl(1).attribute3 := '';
        p_party_tbl(1).attribute4 := '';
        p_party_tbl(1).attribute5 := '';
        p_party_tbl(1).attribute6 := '';
        p_party_tbl(1).attribute7 := '';
        p_party_tbl(1).attribute8 := '';
        p_party_tbl(1).attribute9 := '';
        p_party_tbl(1).attribute10 := '';
        p_party_tbl(1).attribute11 := '';
        p_party_tbl(1).attribute12 := '';
        p_party_tbl(1).attribute13 := '';
        p_party_tbl(1).attribute14 := '';
        p_party_tbl(1).attribute15 := '';
        p_party_tbl(1).object_version_number := NULL;

        p_account_tbl(1).ip_account_id := NULL;
        p_account_tbl(1).parent_tbl_index := 1; --NULL;
        p_account_tbl(1).instance_party_id := NULL;
        p_account_tbl(1).party_account_id := l_cust_acct_id; --NULL;
        p_account_tbl(1).relationship_type_code := 'OWNER';
        -- p_account_tbl(1).bill_to_address := 1000;
        --  p_account_tbl(1).ship_to_address := 1001;
        p_account_tbl(1).active_start_date := '';
        p_account_tbl(1).active_end_date := '';
        p_account_tbl(1).context := '';
        p_account_tbl(1).attribute1 := '';
        p_account_tbl(1).attribute2 := '';
        p_account_tbl(1).attribute3 := '';
        p_account_tbl(1).attribute4 := '';
        p_account_tbl(1).attribute5 := '';
        p_account_tbl(1).attribute6 := '';
        p_account_tbl(1).attribute7 := '';
        p_account_tbl(1).attribute8 := '';
        p_account_tbl(1).attribute9 := '';
        p_account_tbl(1).attribute10 := '';
        p_account_tbl(1).attribute11 := '';
        p_account_tbl(1).attribute12 := '';
        p_account_tbl(1).attribute13 := '';
        p_account_tbl(1).attribute14 := '';
        p_account_tbl(1).attribute15 := '';
        p_account_tbl(1).object_version_number := NULL;


        p_org_assignments_tbl(1).instance_ou_id := NULL;
        p_org_assignments_tbl(1).instance_id := NULL;
        p_org_assignments_tbl(1).operating_unit_id := okc_context.get_okc_org_id;
        p_org_assignments_tbl(1).relationship_type_code := 'SOLD_FROM';
        p_org_assignments_tbl(1).active_start_date := '';
        p_org_assignments_tbl(1).active_end_date := '';
        p_org_assignments_tbl(1).context := '';
        p_org_assignments_tbl(1).attribute1 := '';
        p_org_assignments_tbl(1).attribute2 := '';
        p_org_assignments_tbl(1).attribute3 := '';
        p_org_assignments_tbl(1).attribute4 := '';
        p_org_assignments_tbl(1).attribute5 := '';
        p_org_assignments_tbl(1).attribute6 := '';
        p_org_assignments_tbl(1).attribute7 := '';
        p_org_assignments_tbl(1).attribute8 := '';
        p_org_assignments_tbl(1).attribute9 := '';
        p_org_assignments_tbl(1).attribute10 := '';
        p_org_assignments_tbl(1).attribute11 := '';
        p_org_assignments_tbl(1).attribute12 := '';
        p_org_assignments_tbl(1).attribute13 := '';
        p_org_assignments_tbl(1).attribute14 := '';
        p_org_assignments_tbl(1).attribute15 := '';
        p_org_assignments_tbl(1).object_version_number := NULL;

        p_txn_rec.transaction_id := NULL;
        p_txn_rec.transaction_date := SYSDATE; --TO_DATE('');
        p_txn_rec.source_transaction_date := SYSDATE; --TO_DATE('');
        p_txn_rec.transaction_type_id := 1; --NULL;
        p_txn_rec.txn_sub_type_id := NULL;
        p_txn_rec.source_group_ref_id := NULL;
        p_txn_rec.source_group_ref := '';
        p_txn_rec.source_header_ref_id := NULL;
        p_txn_rec.source_header_ref := '';
        p_txn_rec.source_line_ref_id := NULL;
        p_txn_rec.source_line_ref := '';
        p_txn_rec.source_dist_ref_id1 := NULL;
        p_txn_rec.source_dist_ref_id2 := NULL;
        p_txn_rec.inv_material_transaction_id := NULL;
        p_txn_rec.transaction_quantity := NULL;
        p_txn_rec.transaction_uom_code := 'EA';
        p_txn_rec.transacted_by := NULL;
        p_txn_rec.transaction_status_code := '';
        p_txn_rec.transaction_action_code := '';
        p_txn_rec.message_id := NULL;
        p_txn_rec.context := '';
        p_txn_rec.attribute1 := '';
        p_txn_rec.attribute2 := '';
        p_txn_rec.attribute3 := '';
        p_txn_rec.attribute4 := '';
        p_txn_rec.attribute5 := '';
        p_txn_rec.attribute6 := '';
        p_txn_rec.attribute7 := '';
        p_txn_rec.attribute8 := '';
        p_txn_rec.attribute9 := '';
        p_txn_rec.attribute10 := '';
        p_txn_rec.attribute11 := '';
        p_txn_rec.attribute12 := '';
        p_txn_rec.attribute13 := '';
        p_txn_rec.attribute14 := '';
        p_txn_rec.attribute15 := '';
        p_txn_rec.object_version_number := NULL;

        -- Now call the stored program
        csi_item_instance_pub.create_item_instance(
                                                   1.0,
                                                   'F',
                                                   'F',
                                                   1,
                                                   p_instance_rec,
                                                   p_ext_attrib_values_tbl,
                                                   p_party_tbl,
                                                   p_account_tbl,
                                                   p_pricing_attrib_tbl,
                                                   p_org_assignments_tbl,
                                                   p_asset_assignment_tbl,
                                                   p_txn_rec,
                                                   x_return_status,
                                                   x_msg_count,
                                                   x_msg_data);

        -- Output the results


        IF x_msg_count > 0
            THEN
            FOR j IN 1 .. x_msg_count LOOP
                fnd_msg_pub.get
                (j
                 , FND_API.G_FALSE
                 , x_msg_data
                 , t_msg_dummy
                 );
                t_output := ('Msg'
                             || To_Char
                             (j
                              )
                             || ': '
                             || x_msg_data
                             );
                --  dbms_output.put_line
                --  ( SubStr
                --    ( t_output
                --    , 1
                --    , 255
                --    )
                --   );
            END LOOP;
        END IF;

        --  dbms_output.put_line('x_return_status = '||x_return_status);
        -- dbms_output.put_line('x_msg_count = '||TO_CHAR(x_msg_count));
        -- dbms_output.put_line('x_msg_data = '||x_msg_data);
        --- dbms_output.put_line('instance_id = '||p_instance_rec.instance_id);

        /* UPDATE csi_item_instances
        SET owner_party_source_table = 'OKC_K_ITEMS_B',
        security_group_id = p_cle_id
        WHERE instance_id = p_instance_rec.instance_id;
        */

        x_instance_id := p_instance_rec.instance_id;

        --  --------errorout(' resultant instance id is '||px_instance_id);

    EXCEPTION
        WHEN G_ERROR THEN
            x_return_status := G_RET_STS_ERROR;
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME_OKS,
                                p_msg_name => 'OKS_NULL_CUSTACCT');
    END;


    PROCEDURE DELETE_CII_FOR_SUBSCRIPTION
    (p_api_version   IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count     OUT NOCOPY NUMBER,
     x_msg_data      OUT NOCOPY VARCHAR2,
     p_instance_id   IN NUMBER
     )
    IS
    BEGIN

        NULL;
    END;


    PROCEDURE line_contact_name_addr(
                                     p_object_code       IN  VARCHAR2,
                                     p_id1               IN  VARCHAR2,
                                     p_id2               IN  VARCHAR2,
                                     x_name              OUT NOCOPY VARCHAR2,
                                     x_addr              OUT NOCOPY okx_cust_sites_v.description%TYPE)
    IS
    --l_name              VARCHAR2(255);
    l_from_table        VARCHAR2(200);
    l_where_clause      VARCHAR2(2000);
    l_sql_stmt          VARCHAR2(1000);
    l_not_found         BOOLEAN;
    l_cust_acct_site_id NUMBER;
    -- l_addr              okx_cust_sites_v.description%type;

    CURSOR jtfv_csr IS
        SELECT FROM_TABLE, WHERE_CLAUSE
        FROM JTF_OBJECTS_B
        WHERE OBJECT_CODE = p_object_code;
    TYPE SOURCE_CSR IS REF CURSOR;
    sql_csr SOURCE_CSR;

    CURSOR get_address_csr (p_cust_acct_site_id IN NUMBER) IS
        SELECT description
        FROM   okx_cust_sites_v
        WHERE  id1 = p_cust_acct_site_id;
    BEGIN
        OPEN jtfv_csr;
        FETCH jtfv_csr INTO l_from_table, l_where_clause;
        l_not_found := jtfv_csr%NOTFOUND;
        CLOSE jtfv_csr;


        l_sql_stmt := 'SELECT name, cust_acct_site_id FROM ' || l_from_table ||
        ' WHERE ID1 = :id_1 AND ID2 = :id2';

        IF (l_where_clause IS NOT NULL) THEN
            l_sql_stmt := l_sql_stmt || ' AND ' || l_where_clause;
        END IF;


        OPEN sql_csr FOR l_sql_stmt USING p_id1, p_id2;
        FETCH sql_csr INTO x_name, l_cust_acct_site_id;
        l_not_found := sql_csr%NOTFOUND;
        CLOSE sql_csr;

        OPEN   get_address_csr(l_cust_acct_site_id);
        FETCH  get_address_csr INTO x_addr;
        CLOSE  get_address_csr;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF (jtfv_csr%ISOPEN) THEN
                CLOSE jtfv_csr;
            END IF;
            IF (sql_csr%ISOPEN) THEN
                CLOSE sql_csr;
            END IF;
    END line_contact_name_addr;


    PROCEDURE select_renewal_info
    (p_chr_id IN NUMBER,
     x_operation_lines_tbl OUT NOCOPY opn_lines_tbl
     )
    IS
    --select operation id for renewal of 'SERVICE'
    CURSOR class_operation_cur IS
        SELECT id
        FROM   okc_class_operations
        WHERE  opn_code = 'RENEWAL'
        AND    cls_code = 'SERVICE';

    --select operation instance id for renewal
    CURSOR operation_instance_cur (p_cop_id IN NUMBER)
        IS
        SELECT id
        FROM   okc_operation_instances
        WHERE  target_chr_id = p_chr_id
        AND    cop_id = p_cop_id;

    CURSOR operation_lines_cur (p_oie_id NUMBER) IS
        SELECT creation_date, subject_chr_id, object_chr_id,
               subject_cle_id, object_cle_id
        FROM okc_operation_lines
        WHERE  oie_id = p_oie_id;

    l_opn_id NUMBER;
    l_oie_id NUMBER;
    l_ctr NUMBER;
    BEGIN
        OPEN class_operation_cur;
        FETCH class_operation_cur INTO l_opn_id;
        CLOSE class_operation_cur;

        OPEN operation_instance_cur (l_opn_id);
        FETCH  operation_instance_cur INTO l_oie_id;
        CLOSE  operation_instance_cur;

        IF x_operation_lines_tbl.COUNT > 0
            THEN
            x_operation_lines_tbl.DELETE;
        END IF;

        --populating table
        l_ctr := 1;
        FOR operation_lines_rec IN operation_lines_cur (l_oie_id)
            LOOP
            x_operation_lines_tbl(l_ctr).creation_date := operation_lines_rec.creation_date;
            x_operation_lines_tbl(l_ctr).object_chr_id := operation_lines_rec.object_chr_id;
            x_operation_lines_tbl(l_ctr).object_cle_id := operation_lines_rec.object_cle_id;
            l_ctr := l_ctr + 1;
        END LOOP;

    END select_renewal_info;


    PROCEDURE update_renewal_info
    (p_operation_lines_tbl IN opn_lines_tbl,
     x_return_status       OUT NOCOPY  VARCHAR2,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2
     )
    IS
    BEGIN
        IF p_operation_lines_tbl.COUNT > 0
            THEN
            FOR i IN p_operation_lines_tbl.FIRST..p_operation_lines_tbl.LAST
                LOOP
                IF p_operation_lines_tbl(i).object_cle_id IS NULL
                    THEN
                    UPDATE okc_k_headers_b
                    SET    date_renewed = TRUNC(p_operation_lines_tbl(i).creation_date)
                    WHERE  id = p_operation_lines_tbl(i).object_chr_id;
                ELSE
                    UPDATE okc_k_lines_b
                    SET    date_renewed = TRUNC(p_operation_lines_tbl(i).creation_date)
                    WHERE  id = p_operation_lines_tbl(i).object_cle_id;
                END IF;
            END LOOP;
        END IF; -- IF p_operation_lines_tbl.COUNT > 0
        x_return_status := 'S';

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := G_UNEXPECTED_ERROR;
            OKC_API.set_message(G_APP_NAME_OKS,
                                'OKS_UNEXP_ERROR',
                                'SQLcode',
                                SQLCODE,
                                'SQLerrm',
                                SQLERRM);

    END update_renewal_info;

    PROCEDURE CheckDuplicatePriceAdj(p_api_version   IN  NUMBER
                                     , p_init_msg_list IN  VARCHAR2
                                     , p_pradj_rec     IN  price_adj_rec
                                     , x_return_status OUT NOCOPY VARCHAR2
                                     , x_msg_count     OUT NOCOPY NUMBER
                                     , x_msg_data      OUT NOCOPY VARCHAR2)
    IS

    CURSOR line_cur(c_cle_id NUMBER) IS
        SELECT cle_id, line_number
        FROM   okc_k_lines_b
        WHERE  id = c_cle_id;

    CURSOR price_adj_cur(c_list_line_id NUMBER, c_cle_id NUMBER) IS
        SELECT 'x'
        FROM   okc_price_adjustments
        WHERE  list_line_id = c_list_line_id
        AND    cle_id = c_cle_id;

    CURSOR price_adj_cur_hdr(c_list_line_id NUMBER, c_chr_id NUMBER) IS
        SELECT 'x'
        FROM   okc_price_adjustments
        WHERE  list_line_id = c_list_line_id
        AND    chr_id = c_chr_id;

    CURSOR sub_line_cur(c_cle_id NUMBER) IS
        SELECT id, line_number
        FROM   okc_k_lines_b
        WHERE  cle_id = c_cle_id
        AND    lse_id IN(9, 25);

    l_line_number      VARCHAR2(301) := NULL;
    l_cle_id           NUMBER := NULL;
    l_pradj_exists     VARCHAR2(1) := NULL;
    l_subline_id       NUMBER := NULL;

    BEGIN

        x_return_status := G_RET_STS_SUCCESS;
        fnd_msg_pub.initialize;

        IF p_pradj_rec.chr_id IS NOT NULL THEN
            OPEN  price_adj_cur_hdr(p_pradj_rec.list_line_id, p_pradj_rec.chr_id);
            FETCH price_adj_cur_hdr INTO l_pradj_exists;
            CLOSE price_adj_cur_hdr;
            IF l_pradj_exists IS NOT NULL THEN
                RAISE G_DUPLICATE_RECORD;
            ELSE
                RETURN;
            END IF;
        END IF;

        OPEN  price_adj_cur(p_pradj_rec.list_line_id, p_pradj_rec.cle_id);
        FETCH price_adj_cur INTO l_pradj_exists;
        CLOSE price_adj_cur;
        IF l_pradj_exists IS NOT NULL THEN
            RAISE G_DUPLICATE_RECORD;
        END IF;

        OPEN  line_cur(p_pradj_rec.cle_id);
        FETCH line_cur INTO l_cle_id, l_line_number;
        CLOSE line_cur;

        IF l_cle_id IS NULL THEN --TopLine/Subline
            --GET SUBLINES
            OPEN sub_line_cur(p_pradj_rec.cle_id);
            LOOP
                l_line_number := NULL;
                FETCH sub_line_cur INTO l_subline_id, l_line_number;
                EXIT WHEN sub_line_cur%NOTFOUND;

                OPEN  price_adj_cur(p_pradj_rec.list_line_id, l_subline_id);
                FETCH price_adj_cur INTO l_pradj_exists;
                CLOSE price_adj_cur;
                IF l_pradj_exists IS NOT NULL THEN
                    RAISE G_DUPLICATE_RECORD;
                END IF;
                l_subline_id := NULL;
            END LOOP; -- GET SUBLINES
        ELSE --TopLine/Subline
            OPEN  price_adj_cur(p_pradj_rec.list_line_id, l_cle_id);
            FETCH price_adj_cur INTO l_pradj_exists;
            CLOSE price_adj_cur;
            IF l_pradj_exists IS NOT NULL THEN
                RAISE G_DUPLICATE_RECORD;
            END IF;
        END IF; --TopLine/Subline
    EXCEPTION
        WHEN G_DUPLICATE_RECORD THEN
            x_return_status := G_RET_STS_ERROR;
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME_OKS,
                                p_msg_name => 'OKS_DUPLICATE_MODIFIER');
        WHEN OTHERS THEN
            x_return_status := G_UNEXPECTED_ERROR;
            OKC_API.set_message(G_APP_NAME_OKS,
                                'OKS_UNEXP_ERROR',
                                'SQLcode',
                                SQLCODE,
                                'SQLerrm',
                                SQLERRM);
    END CheckDuplicatePriceAdj;


    PROCEDURE Update_Line_Amount
    (p_line_id       IN   NUMBER,
     p_new_service_amount IN NUMBER,
     x_return_status OUT  NOCOPY VARCHAR2,
     x_msg_count     OUT  NOCOPY NUMBER,
     x_msg_data      OUT  NOCOPY VARCHAR2)
    IS
    l_clev_rec         OKC_CONTRACT_PUB.clev_rec_type;
    x_clev_rec         OKC_CONTRACT_PUB.clev_rec_type;
    l_api_version      NUMBER := 1.0;
    l_init_msg_list   VARCHAR2(2000) := OKC_API.G_FALSE;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_price_negotiated  NUMBER;
    l_klnv_tbl_in               oks_contract_line_pub.klnv_tbl_type;
    l_klnv_tbl_out              oks_contract_line_pub.klnv_tbl_type;


    CURSOR l_csr_total_line_amount(p_line_id IN NUMBER)
        IS
        SELECT nvl(SUM(nvl(price_negotiated, 0)), 0)
        FROM   okc_k_lines_b
        WHERE  cle_id = p_line_id
        AND    date_cancelled IS NULL; -- line Level Cancellation

    CURSOR toplinetax_cur(p_cle_id IN NUMBER) IS
        SELECT SUM(nvl(tax_amount, 0)) amount
        FROM okc_k_lines_b cle, oks_k_lines_b kln
        WHERE cle.cle_id = p_cle_id
        AND   cle.id = kln.cle_id
        AND   cle.lse_id IN (7, 8, 9, 10, 11, 13, 35, 25, 46)
        AND   cle.date_cancelled IS NULL;

    l_tax_amount       toplinetax_cur%ROWTYPE;

    CURSOR Get_oks_Lines_details(p_cle_id IN NUMBER) IS
        SELECT id, object_version_number, dnz_chr_id
        FROM oks_k_lines_b
        WHERE cle_id = p_cle_id ;

    l_get_oks_details  Get_oks_Lines_details%ROWTYPE;

    BEGIN

        l_clev_rec.id := p_Line_Id;
        OPEN l_csr_total_line_amount(p_line_id);
        FETCH l_csr_total_line_amount INTO l_price_negotiated;
        CLOSE l_csr_total_line_amount;



        l_clev_rec.price_negotiated := l_price_negotiated ;

        OKC_CONTRACT_PUB.Update_Contract_Line
        (
         p_api_version => l_api_version,
         p_init_msg_lISt => l_init_msg_lISt,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_restricted_update => 'F',
         p_clev_rec => l_clev_rec,
         x_clev_rec => x_clev_rec
         );

        IF NVL(x_return_status, '!') <> OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_ERROR;
        END IF;
        -- Update Lines Level Tax Amount --
        OPEN Get_oks_Lines_details(p_line_id);
        FETCH Get_oks_Lines_details INTO l_get_oks_details ;
        CLOSE Get_oks_Lines_details;

        OPEN toplinetax_cur(p_line_id);
        FETCH toplinetax_cur INTO l_tax_amount;
        CLOSE toplinetax_cur;

        l_klnv_tbl_in(1).id := l_get_oks_details.id ;
        l_klnv_tbl_in(1).object_version_number := l_get_oks_details.object_version_number;
        l_klnv_tbl_in(1).dnz_chr_id := l_get_oks_details.dnz_chr_id;
        l_klnv_tbl_in(1).cle_id := p_line_id;
        l_klnv_tbl_in(1).tax_amount := l_tax_amount.amount;


        oks_contract_line_pub.update_line
        (
         p_api_version => l_api_version,
         p_init_msg_list => l_init_msg_list,
         x_return_status => l_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data,
         p_klnv_tbl => l_klnv_tbl_in,
         x_klnv_tbl => l_klnv_tbl_out,
         p_validate_yn => 'N'
         );

        x_return_status := l_return_status;
        IF NVL(l_return_status, '!') <> OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_ERROR;
        END IF;

    EXCEPTION
        WHEN G_ERROR THEN
            NULL;
    END Update_Line_Amount;

    PROCEDURE Update_Coverage_Levels
    (p_clvl_rec      IN   Clvl_Rec_Type,
     x_return_status OUT  NOCOPY VARCHAR2,
     x_msg_count     OUT  NOCOPY NUMBER,
     x_msg_data      OUT  NOCOPY VARCHAR2)
    IS

    l_clev_rec         OKC_CONTRACT_PUB.clev_rec_type;
    x_clev_rec         OKC_CONTRACT_PUB.clev_rec_type;
    l_api_version      NUMBER := 1.0;
    l_init_msg_lISt    VARCHAR2(1) := 'T';

    BEGIN

        ----------errorout_ad('cp line id = ' || to_char(p_clvl_rec.Coverage_Level_Line_Id));
        ----------errorout_ad('cp amount = ' || to_char(p_clvl_rec.price_negotiated));
        l_clev_rec.id := p_clvl_rec.Coverage_Level_Line_Id;
        l_clev_rec.price_unit := p_clvl_rec.price_unit;
        l_clev_rec.price_unit_percent := p_clvl_rec.price_unit_percent;
        l_clev_rec.price_negotiated := p_clvl_rec.price_negotiated;

        OKC_CONTRACT_PUB.Update_Contract_Line
        (
         p_api_version => l_api_version,
         p_init_msg_lISt => l_init_msg_lISt,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_restricted_update => 'F',
         p_clev_rec => l_clev_rec,
         x_clev_rec => x_clev_rec
         );

        ----------errorout_ad('OKC_CONTRACT_PUB.Update_Contract_Line status = ' || x_return_status);

        IF NVL(x_return_status, '!') <> OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_ERROR;
        END IF;

    EXCEPTION
        WHEN G_ERROR THEN
            NULL;
    END Update_Coverage_Levels;

    PROCEDURE UPDATE_CONTRACT_AMOUNT(p_header_id IN NUMBER,
                                     x_return_status  OUT NOCOPY VARCHAR2) IS
    l_api_version     CONSTANT   NUMBER := 1.0;
    l_init_msg_list   VARCHAR2(2000) := OKC_API.G_FALSE;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_msg_index_out   NUMBER;
    l_chrv_tbl_in     okc_contract_pub.chrv_tbl_type;
    l_chrv_tbl_out    okc_contract_pub.chrv_tbl_type;
    -- Header Level Tax Amount --
    l_khrv_tbl_type_in   oks_contract_hdr_pub.khrv_tbl_type;
    l_khrv_tbl_type_out  oks_contract_hdr_pub.khrv_tbl_type;

    -- Header Level Tax Amount --
    CURSOR total_amount IS
        SELECT nvl(SUM(price_negotiated), 0) SUM
        FROM okc_k_lines_b
        WHERE dnz_chr_id = p_header_id
        AND   cle_id IS NULL
        AND   date_cancelled IS NULL; -- line Level Cancellation
    --Commented URP
    --WHERE dnz_chr_id = p_header_id;

    -- Header Tax Total
    CURSOR hdrtax_cur IS
        SELECT SUM(kln.tax_amount)  amount
        FROM okc_k_lines_b cle, oks_k_lines_b kln
        WHERE cle.dnz_chr_id = p_header_id
        AND   cle.id = kln.cle_id
        AND   cle.lse_id IN (7, 8, 9, 10, 11, 13, 35, 25, 46)
        AND   cle.date_cancelled IS NULL;

    l_total_tax hdrtax_cur%ROWTYPE;

    CURSOR Get_Header_details IS
        SELECT id, object_version_number
        FROM OKS_K_HEADERS_B
        WHERE chr_id = p_header_id ;

    l_get_hdr_details get_header_details%ROWTYPE;

    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        IF p_header_id IS NOT NULL THEN
            l_chrv_tbl_in.DELETE;
            FOR cur_total_amount IN total_amount
                LOOP
                l_chrv_tbl_in(1).id := p_header_id;
                l_chrv_tbl_in(1).estimated_amount := cur_total_amount.SUM;
                okc_contract_pub.update_contract_header (
                                                         p_api_version => l_api_version,
                                                         p_init_msg_list => l_init_msg_list,
                                                         x_return_status => l_return_status,
                                                         x_msg_count => l_msg_count,
                                                         x_msg_data => l_msg_data,
                                                         p_chrv_tbl => l_chrv_tbl_in,
                                                         x_chrv_tbl => l_chrv_tbl_out
                                                         );
                x_return_status := l_return_status;
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;
            END LOOP;

            -- Updating Header level tax Amount --
            OPEN get_header_details;
            FETCH get_header_details INTO l_get_hdr_details;
            CLOSE get_header_details;

            OPEN hdrtax_cur;
            FETCH hdrtax_cur INTO l_total_tax;
            CLOSE hdrtax_cur;

            l_khrv_tbl_type_in(1).id := l_get_hdr_details.id;
            l_khrv_tbl_type_in(1).chr_id := p_header_id;
            l_khrv_tbl_type_in(1).object_version_number := l_get_hdr_details.object_version_number;
            l_khrv_tbl_type_in(1).tax_amount := l_total_tax.amount;

            oks_contract_hdr_pub.update_header(
                                               p_api_version => l_api_version,
                                               p_init_msg_list => l_init_msg_list,
                                               x_return_status => l_return_status,
                                               x_msg_count => l_msg_count,
                                               x_msg_data => l_msg_data,
                                               p_khrv_tbl => l_khrv_tbl_type_in,
                                               x_khrv_tbl => l_khrv_tbl_type_out,
                                               p_validate_yn => 'N');

            x_return_status := l_return_status;
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
            -- Updating Header level tax Amount --

        END IF;
    END UPDATE_CONTRACT_AMOUNT;



    PROCEDURE GetIgnorableAmount(p_contract_line_id IN NUMBER,
                                 x_prorated_amount OUT NOCOPY NUMBER,
                                 x_rec_count OUT NOCOPY NUMBER)
    IS
    CURSOR l_subline_csr IS
        SELECT NVL(lines.price_negotiated, 0) price_negotiated,
               lines.start_date,
               lines.end_date,
               lines.date_terminated,
               lines.price_unit,
               lines.price_unit_percent,
               lines.id
        FROM   okc_k_lines_b lines
        WHERE  lines.cle_id = p_contract_line_id
        AND    lines.lse_id IN(7, 8, 9, 10, 11, 18, 25, 35);
    l_subline_rec          l_subline_csr%ROWTYPE;
    l_prorated_amount      NUMBER := 0;
    l_amount               NUMBER := 0;
    l_rec_count            NUMBER := 0;
    BEGIN
        OPEN  l_subline_csr;
        LOOP
            FETCH l_subline_csr INTO l_subline_rec;
            EXIT WHEN l_subline_csr%NOTFOUND;
            IF l_subline_rec.date_terminated IS NOT NULL THEN
                IF l_subline_rec.date_terminated <= trunc(SYSDATE) THEN
                    l_amount := l_subline_rec.price_negotiated;
                END IF;
                l_rec_count := l_rec_count + 1;
                --Commented to fix Bug#2450212 , 09, Aug 2002  , Sudam
                --ELSIF l_subline_rec.end_date < trunc(sysdate) THEN
                --l_amount := l_subline_rec.price_negotiated;
                --l_rec_count := l_rec_count + 1;
            END IF;
            l_prorated_amount := l_prorated_amount + l_amount;
            l_amount := 0;
        END LOOP;
        CLOSE l_subline_csr;
        x_prorated_amount := l_prorated_amount;
        x_rec_count := l_rec_count;
    END GetIgnorableAmount;

    /***************/

    PROCEDURE Cascade_Service_Price(
                                    p_api_version        IN  NUMBER,
                                    p_init_msg_lISt      IN  VARCHAR2,
                                    p_contract_line_id   IN  NUMBER,
                                    p_new_service_price  IN  NUMBER,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    x_msg_count          OUT NOCOPY NUMBER,
                                    x_msg_data           OUT NOCOPY VARCHAR2
                                    )
    IS

    lc_jtot_obj_code      VARCHAR2(30) := 'OKX_CUSTPROD';

    CURSOR  l_svc_csr IS
        SELECT  nvl(SUM(NVL(price_negotiated, 0)), 0) service_amount
             , COUNT(price_negotiated)
        FROM    okc_k_lines_b lines
        WHERE   lines.cle_id = p_contract_line_id
        AND     lines.lse_id IN(7, 8, 9, 10, 11, 18, 25, 35)
        AND     lines.date_cancelled IS NULL; -- line Level Cancellation



    --bug # 2215282 -- exclude terminated/expired/cancelled clvl lines from cascade service pricing
    --Removed Status Check but included Date_Terminated for termination
    --and end_date for the expiration. This is for same Bug 2215282.

    -- Bug 5228352 --
    CURSOR  l_clvl_csr IS
        SELECT  okc.id,
                price_negotiated,
                 price_unit,
                price_unit_percent,
                lse_id,
                okc.dnz_chr_id,
                currency_code,
                oks.id oks_id,
                oks.object_version_number
        FROM    okc_k_lines_b  okc, oks_k_lines_b oks
        WHERE   okc.Cle_id = p_contract_line_id
        AND     OKS.cle_id = okc.id
        AND     (okc.date_terminated IS NULL OR okc.date_terminated > TRUNC(SYSDATE))
        AND     lse_id NOT IN(2, 15, 20)
        AND     okc.date_cancelled IS NULL; -- line Level Cancellation

   CURSOR get_tax_details(p_cle_id IN NUMBER) IS
        SELECT id, object_version_number
        FROM   oks_k_lines_b
        WHERE  cle_id = p_cle_id;

   get_tax_rec		get_tax_details%rowtype;
   -- Bug 5228352 --

    CURSOR l_aggr_csr(p_chr_id IN NUMBER) IS
        SELECT Isa_Agreement_Id
        FROM   OKC_GOVERNANCES_V
        WHERE  dnz_chr_id = p_chr_id
        AND    cle_id IS NULL;


    l_service_amount      NUMBER;
    l_clvl_price          NUMBER;
    l_current_percent     NUMBER := 0;
    l_new_amount          NUMBER := 0;
    l_clvl_rec            Clvl_Rec_type;
    l_count               NUMBER := 1;
    l_curr_rec            NUMBER := 0;
    l_sum_amt             NUMBER := 0;
    l_diff_amt            NUMBER := 0;
    l_old_id              NUMBER;
    l_old_up              NUMBER;
    l_old_upp             NUMBER;
    --  l_contract_line_rec   OKS_QP_INT_PVT.G_LINE_REC_TYPE;
    -- lx_contract_cp_tbl     OKS_QP_INT_PVT.G_SLINE_TBL_TYPE;
    l_currency_code       VARCHAR2(15);
    i                     NUMBER := 1;
    l_pdl_adjusted_amount NUMBER;
    l_covlvl_qty   NUMBER;
    l_tlvl_priced_qty  NUMBER;
    l_aggr_id         NUMBER;
    cp_price  NUMBER ;
    l_index NUMBER ;

    l_terminated_service_amount NUMBER;
    l_terminated_count          NUMBER;
    l_percent_terminated        NUMBER;
    l_active_service_amount     NUMBER;
    l_active_line_count         NUMBER;
    l_new_cascade_service_price NUMBER;
    l_detail_rec    OKS_QP_PKG.input_details;
    l_api_Version     NUMBER := 1;
    l_init_msg_list   VARCHAR2(2000) := OKC_API.G_FALSE;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_price_details         OKS_QP_PKG.price_details;
    l_modifier_details      QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    l_price_break_details   OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE;
    l_old_lse_id     NUMBER;
    l_old_currency_code  VARCHAR2(4);
    lx_klnv_tbl OKS_CONTRACT_LINE_PUB.klnv_tbl_type;
    l_validate_yn VARCHAR2(1);
    l_curr_code    VARCHAR2(30);


    --    l_rule_rec               OKC_RUL_PVT.rulv_rec_type;
    --    l_rule_tbl               OKC_RULE_PUB.rulv_tbl_type;

    l_klnv_tbl   OKS_CONTRACT_LINE_PUB.klnv_tbl_type;
    /* for tax calculation */

    G_RAIL_REC             OKS_TAX_UTIL_PVT.ra_rec_type;

    PROCEDURE Get_Currency_Code(p_chr_id    IN  NUMBER
                                , x_curr_code OUT NOCOPY VARCHAR2) IS
    CURSOR l_hdr_csr IS
        SELECT currency_code
       FROM   okc_k_headers_b
        WHERE  id = p_chr_id;
    BEGIN
        x_curr_code := NULL;
        OPEN  l_hdr_csr;
        FETCH l_hdr_csr INTO x_curr_code;
        CLOSE l_hdr_csr;
    END Get_Currency_Code;

    FUNCTION Get_Header_Id RETURN NUMBER IS
    CURSOR l_hdr_csr IS
        SELECT dnz_chr_id
        FROM   okc_k_lines_b
        WHERE  id = p_contract_line_id;
    l_header_id     OKC_K_HEADERS_B.ID%TYPE;
    BEGIN
        OPEN  l_hdr_csr;
        FETCH l_hdr_csr INTO l_header_id;
        CLOSE l_hdr_csr;
        RETURN(l_header_id);
    END Get_Header_Id;

    BEGIN

        OPEN  l_svc_csr;
        FETCH l_svc_csr INTO l_service_amount, l_count;
        CLOSE l_svc_csr;

        ----------errorout_ad(' l_service_amount '||l_service_amount );
        ----------errorout_ad(' l_count '||l_count );

        --bug # 2215282 -- exclude terminated/expired/cancelled clvl lines from cascade service pricing

        GetIgnorableAmount(p_contract_line_id => p_contract_line_id,
                           x_prorated_amount => l_terminated_service_amount,
                           x_rec_count => l_terminated_count);

        IF l_count = l_terminated_count THEN
            RETURN;
        END IF;

        ----------errorout_ad(' l_terminated_service_amount '||l_terminated_service_amount );
        ----------errorout_ad(' l_terminated_count '||l_terminated_count );

        /** Find total reprice amount to be adjusted #2215282 **/
        IF NVL(l_service_amount, 0) <> 0 THEN
            IF NVL(l_terminated_service_amount, 0) <> 0 THEN
                l_active_service_amount := NVL(l_service_amount, 0) - NVL(l_terminated_service_amount, 0);
                l_active_line_count := NVL(l_count, 0) - NVL(l_terminated_count, 0);
                l_new_cascade_service_price := p_new_service_price - NVL(l_terminated_service_amount, 0);
            ELSE
                l_active_service_amount := l_service_amount;
                l_new_cascade_service_price := p_new_service_price;
                l_active_line_count := l_count;
            END IF;
        END IF;

        ----------errorout_ad(' l_new_cascade_service_price '||l_new_cascade_service_price );
        ----------errorout_ad(' l_active_line_count '||l_active_line_count );


        FOR  clvl_rec IN l_clvl_csr
            LOOP

            -- --------errorout_ad (' clvl '||clvl_rec.id);

            --    --------errorout_ad (' clvl  price negotiated '||clvl_rec.price_negotiated);
            /** Check for status of the covered level line **/
            l_curr_rec := l_curr_rec + 1;

            l_clvl_price := clvl_rec.Price_Negotiated;
            Get_Currency_Code(p_chr_id => Get_Header_Id, x_curr_code => l_curr_code);
            --bug # 2215282 -- exclude terminated/expired/cancelled clvl lines from cascade service pricing
            IF l_service_amount = 0 THEN
                IF NVL(l_active_line_count, 0) <> 0 THEN
                    --     l_new_amount := NVL(l_new_cascade_service_price,0) / NVL(l_active_line_count, 1);

                    l_new_amount := OKS_EXTWAR_UTIL_PVT.Round_Currency_amt
                    (
                     NVL(l_new_cascade_service_price, 0) / NVL(l_active_line_count, 1),
                     l_curr_code
                     );
                END IF;
            ELSE
                IF NVL(l_active_service_amount, 0) <> 0 THEN
                    l_current_percent := (NVL(l_clvl_price, 0) * 100) / NVL(l_active_service_amount, 1);
                    --      l_new_amount      := ROUND( ((NVL(l_new_cascade_service_price, 0) * l_current_percent)/100), 2);

                    l_new_amount := OKS_EXTWAR_UTIL_PVT.Round_Currency_amt(
                                                                           (NVL(l_new_cascade_service_price, 0) * l_current_percent) / 100,
                                                                           l_curr_code
                                                                           );

                END IF;

            END IF;
            ----------errorout_ad(' l_new_amount '||l_new_amount);
            IF l_curr_rec <= l_count THEN

                ----------errorout_ad(' before updating cov level ');
                l_clvl_rec.coverage_level_line_id := clvl_rec.id;
                l_clvl_rec.price_negotiated := l_new_amount;
                l_clvl_rec.price_unit := clvl_rec.price_unit;
                l_clvl_rec.price_unit_percent := clvl_rec.price_unit_percent;

                Update_Coverage_Levels
                (p_clvl_rec => l_clvl_rec,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data);

                ----------errorout_ad(' after updating coverag level ' ||clvl_rec.lse_id||' '||clvl_rec.id);

                /* select price_negotiated into cp_price
                from okc_k_lines_b
                where id = clvl_rec.id; */

                ----------errorout_ad(' price nego after update '||cp_price);

                IF Nvl(x_return_status, 'S') <> OKC_API.G_RET_STS_SUCCESS
                    THEN
                    --              --------errorout_ad (' error in updation of coverage level ');
                    RAISE G_ERROR;
                END IF;

                /** Recalculate Tax **/
                --       --------errorout(' before calculating tax '||clvl_rec.lse_id);
		-- Bug 5228352 --
                IF clvl_rec.lse_id  IN (8, 10, 11, 12, 35 )
		OR (
		    clvl_rec.lse_id IN (7, 9, 18, 25)
		    AND
		    NVL(fnd_profile.VALUE('OKS_USE_QP_FOR_MANUAL_ADJ'), 'NO') = 'NO')

		THEN
		-- Bug 5228352 --
                    --          --------errorout_ad(' before calculating tax ');
                    G_RAIL_REC.amount := l_new_amount ;

                    OKS_TAX_UTIL_PVT.Get_Tax (p_api_version => 1.0,
                                              p_init_msg_list => OKC_API.G_TRUE,
                                              p_chr_id => clvl_rec.dnz_chr_id,
                                              p_cle_id => p_contract_line_id,
                                              px_rail_rec => G_RAIL_REC,
                                              x_msg_count => x_msg_count,
                                              x_msg_data => x_msg_data,
                                              x_return_status => l_return_status );

		    -- Bug 5228352 --
		    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
			RAISE OKC_API.G_EXCEPTION_ERROR;
		    ELSIF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		    END IF;
		    -- Bug 5228352 --

                    --         --------errorout_ad(' error in calc tax '||l_return_status );
                    -- Create IRT Rule

		    -- Bug 5228352 --
                    l_klnv_tbl(1).id := clvl_rec.oks_id;
                    l_klnv_tbl(1).cle_id := clvl_rec.id;
		    l_klnv_tbl(1).object_version_number := clvl_rec.object_version_number;
                    l_klnv_tbl(1).dnz_chr_id := get_header_id;
                    l_klnv_tbl(1).tax_inclusive_yn := g_rail_rec.amount_includes_tax_flag;
		    -- Bug 5228352 --





                    IF  g_rail_rec.amount_includes_tax_flag = 'N' THEN
                        l_klnv_tbl(1).tax_amount := NVL(g_rail_rec.tax_value, 0);
                        --    l_klnv_tbl(1).rule_information6     := g_rail_rec.amount + NVL(g_rail_rec.tax_value,0);
                    ELSE
                        l_klnv_tbl(1).tax_amount := 0;
                        --    l_rule_rec.rule_information6     := g_rail_rec.amount;
                    END IF;

                    -- Update IRT rule
                    --           --------errorout_ad(' tax amount  ' || g_rail_rec.tax_value);
                    --          --------errorout_ad(' amount '||g_rail_rec.amount);



                    OKS_CONTRACT_LINE_PUB.update_line(
                                                      p_api_version => p_api_version,
                                                      p_init_msg_list => p_init_msg_list,
                                                      x_return_status => l_return_status,
                                                      x_msg_count => l_msg_count,
                                                      x_msg_data => l_msg_data,
                                                      p_klnv_tbl => l_klnv_tbl,
                                                      x_klnv_tbl => lx_klnv_tbl,
                                                      p_validate_yn => l_validate_yn);
		     -- Bug 5228352 --
	            IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
			 RAISE OKC_API.G_EXCEPTION_ERROR;
		    ELSIF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		    END IF;
	            -- Bug 5228352 --


                    --      --------errorout_ad(' after qp int pvt '||l_return_status );

                END IF; /* Calculate tax  - update IRT rule for non cov item , cov prod */

                IF NVL(fnd_profile.VALUE('OKS_USE_QP_FOR_MANUAL_ADJ'), 'NO') = 'YES' THEN

                    IF clvl_rec.lse_id IN (7, 9, 18, 25) THEN
                        --         l_detail_rec.chr_id         :=   l_service_rec.header_id; /** header id **/
                        --         l_detail_rec.line_id        :=   p_contract_line_id;   /** line id **/
                        l_detail_rec.subline_id := clvl_rec.id;             /** Subline id **/
                        l_detail_rec.intent := 'OA';
                        l_detail_rec.currency := clvl_rec.currency_code; /** Currency code **/
                        l_detail_Rec.usage_qty := NULL;
                        l_detail_rec.usage_uom_code := NULL;
                        l_detail_rec.asking_unit_price := l_new_amount; /* New subine amount after cascade service price */

                        ----------errorout_ad(' ******* cp level  updation ******** '||l_curr_rec);
                        ----------errorout_ad(' subline id '||l_detail_rec.subline_id);
                        ----------errorout_ad(' currency '||l_detail_rec.currency);
                        ----------errorout_ad(' price '||l_detail_rec.asking_unit_price);

                        --                --------errorout_ad(' call compute price for cp  ci ');

                        OKS_QP_INT_PVT.COMPUTE_PRICE
                        (
                         l_api_version,
                         l_init_msg_list,
                         l_detail_rec,
                         l_price_details,
                         l_modifier_details,
                         l_price_break_details,
                         l_return_status,
                         l_msg_count,
                         l_msg_data         );

                        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

                            RAISE G_ERROR;
                        END IF;

                    END IF;


                END IF; /* end of check QP profile option */

                l_sum_amt := l_sum_amt + l_new_amount;

                l_old_id := clvl_rec.id;
                l_old_up := clvl_rec.price_unit;
                l_old_upp := clvl_rec.price_unit_percent;
                l_old_lse_id := clvl_rec.lse_id ;
                l_old_currency_code := clvl_rec.currency_code;

            END IF;

        END LOOP;


        /*** Adjust difference amount arising because of decimals ***/

        l_diff_amt := l_new_cascade_service_price - l_sum_amt;
        --  --------errorout_ad(' l_diff_amt '||l_diff_amt);

        IF l_diff_amt IS NOT NULL AND l_diff_amt <> 0  THEN
            l_clvl_rec.coverage_level_line_id := l_old_id;
            l_clvl_rec.price_negotiated := l_clvl_rec.price_negotiated + NVL(l_diff_amt, 0);
            l_clvl_rec.price_unit := l_old_up;
            l_clvl_rec.price_unit_percent := l_old_upp;

            Update_Coverage_Levels(p_clvl_rec => l_clvl_rec,
                                   x_return_status => x_return_status,
                                   x_msg_count => x_msg_count,
                                   x_msg_data => x_msg_data);

            IF Nvl(x_return_status, 'S') <> OKC_API.G_RET_STS_SUCCESS THEN
                RAISE G_ERROR;
            END IF;



            /*** Calculate tax - update IRT rule for residual value **/
            -- Bug 5228352 --
            IF l_old_lse_id  IN (8, 10, 11, 12, 35 )
	    OR (   l_old_lse_id IN (7, 9, 18, 25)
		    AND
		    NVL(fnd_profile.VALUE('OKS_USE_QP_FOR_MANUAL_ADJ'), 'NO') = 'NO')
	    THEN
            -- Bug 5228352 --

                --       --------errorout_ad(' before calculating tax ');
                G_RAIL_REC.amount := l_clvl_rec.price_negotiated + NVL(l_diff_amt, 0) ;

                OKS_TAX_UTIL_PVT.Get_Tax (p_api_version => 1.0,
                                          p_init_msg_list => OKC_API.G_TRUE,
                                          p_chr_id => get_header_id,
                                          p_cle_id => l_old_id,
                                          px_rail_rec => G_RAIL_REC,
                                          x_msg_count => x_msg_count,
                                          x_msg_data => x_msg_data,
                                          x_return_status => l_return_status );

		-- Bug 5228352 --
	        IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
		ELSIF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                END IF;
	       -- Bug 5228352 --

                --        --------errorout_ad(' error in calc tax '||l_return_status );
                -- Create IRT Rule

                -- OKS_QP_INT_PVT.CLEAR_RULE_TABLE ( x_rulv_tbl   =>  l_rule_tbl);

                -- l_rule_rec             := l_rule_tbl(1);
		-- Bug 5228352 --
		open get_tax_details(l_old_id);
		fetch get_tax_details into get_tax_rec;
		close get_tax_details;

		l_klnv_tbl(1).id := get_tax_rec.id;
                l_klnv_tbl(1).cle_id := l_old_id;
		l_klnv_tbl(1).object_version_number := get_tax_rec.object_version_number;
		-- Bug 5228352 --

                l_klnv_tbl(1).dnz_chr_id := get_header_id;
                l_klnv_tbl(1).tax_inclusive_yn := g_rail_rec.amount_includes_tax_flag;


                IF  g_rail_rec.amount_includes_tax_flag = 'N' THEN
                    l_klnv_tbl(1).tax_amount := NVL(g_rail_rec.tax_value, 0);
                    --    l_klnv_tbl(1).rule_information6     := g_rail_rec.amount + NVL(g_rail_rec.tax_value,0);
                ELSE
                    l_klnv_tbl(1).tax_amount := 0;
                    --    l_rule_rec.rule_information6     := g_rail_rec.amount;
                END IF;

                ---        l_rule_rec.dnz_chr_id                := Get_header_id;
                --         l_rule_rec.rule_information_category := 'IRT';
                --         l_rule_rec.rule_information5         := g_rail_rec.amount_includes_tax_flag;

                IF  g_rail_rec.amount_includes_tax_flag = 'N' THEN
                    --      l_rule_rec.rule_information4     := NVL(g_rail_rec.tax_value,0);
                    l_klnv_tbl(1).tax_amount := g_rail_rec.amount + NVL(g_rail_rec.tax_value, 0)  ;
                ELSE
                    --    l_rule_rec.rule_information4     := 0;
                    l_klnv_tbl(1).tax_amount := g_rail_rec.amount;
                END IF;

                -- Update IRT rul

                OKS_CONTRACT_LINE_PUB.update_line(
                                                  p_api_version => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                                                  x_return_status => l_return_status,
                                                  x_msg_count => l_msg_count,
                                                  x_msg_data => l_msg_data,
                                                  p_klnv_tbl => l_klnv_tbl,
                                                  x_klnv_tbl => lx_klnv_tbl,
                                                  p_validate_yn => l_validate_yn);
       	       -- Bug 5228352 --
	        IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
		ELSIF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                END IF;
	       -- Bug 5228352 --


                /*             oks_qp_int_pvt.UPDATE_RULE ( p_rule_rec         => l_rule_rec,
                p_line_id          => l_old_id,
                x_return_status    => l_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data);
                */
                --       --------errorout_ad(' after qp int pvt '||l_return_status );

            END IF; /* Calculate tax  - update IRT rule for non cov item , cov prod */


            /*** Profile option to be checked. If 'Yes' then call pricing engine **/

            IF NVL(fnd_profile.VALUE('OKS_USE_QP_FOR_MANUAL_ADJ'), 'NO') = 'YES' THEN

                IF l_old_lse_id IN (7, 9, 18, 25) THEN
                    --   l_detail_rec.chr_id         :=   l_service_red.header_id; /** header id **/
                    --   l_detail_rec.line_id        :=   l_service_rec.line_id;   /** line id **/
                    l_detail_rec.subline_id := l_old_id;             /** Subline id **/
                    l_detail_rec.intent := 'OA';
                    l_detail_rec.currency := l_old_currency_code; /** Currency code **/
                    l_detail_Rec.usage_qty := NULL;
                    l_detail_rec.usage_uom_code := NULL;
                    l_detail_rec.asking_unit_price := l_clvl_rec.price_negotiated + NVL(l_diff_amt, 0) ; /* New subine amount after cascade service price */

                    ----------errorout_ad(' ******* diff amt updation ******** ');
                    ----------errorout_ad(' subline id '||l_detail_rec.subline_id);
                    ----------errorout_ad(' currency '||l_detail_rec.currency);
                    ----------errorout_ad(' price '||l_detail_rec.asking_unit_price);

                    OKS_QP_INT_PVT.COMPUTE_PRICE
                    (
                     l_api_version,
                     l_init_msg_list,
                     l_detail_rec,
                     l_price_details,
                     l_modifier_details,
                     l_price_break_details,
                     l_return_status,
                     l_msg_count,
                     l_msg_data         );

                    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                        RAISE G_ERROR;
                    END IF;
                END IF;
            END IF; /** ENDIF CALL TO QP INT */
        END IF; /** ENDIF DIFF AMT **/

        -- Need to update line amount also


        UPDATE_LINE_AMOUNT(p_contract_line_id,
                           p_new_service_price,
                           x_return_status,
                           x_msg_count,
                           x_msg_data  );


        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_ERROR;
        END IF;


        --Update Header Amount Added For Bug 2236444
        UPDATE_CONTRACT_AMOUNT(p_header_id => Get_Header_Id,
                               x_return_status => x_return_status);


        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_ERROR;
        END IF;



    EXCEPTION
        WHEN G_ERROR THEN

            NULL;
        WHEN OTHERS THEN

            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME_OKC,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);

            x_return_status := G_RET_STS_UNEXP_ERROR;

    END Cascade_Service_Price;



    PROCEDURE update_quantity(p_cle_id         IN NUMBER,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2
                              )
    IS
    CURSOR get_all_instances_csr IS
        SELECT id
        FROM okc_k_lines_b
        WHERE cle_id = p_cle_id
        AND  lse_id IN (9, 25);

    CURSOR get_okc_item_qty_csr (p_item_cle_id NUMBER) IS
        SELECT object1_id1, number_of_items
        FROM okc_k_items
        WHERE cle_id = p_item_cle_id;

    get_okc_item_qty_rec get_okc_item_qty_csr%ROWTYPE;

    CURSOR get_csi_item_qty_csr (p_object1_id1 VARCHAR2) IS
        SELECT cii.quantity
        FROM  CSI_ITEM_INSTANCES CII
        WHERE instance_id = TO_NUMBER(p_object1_id1);

    get_csi_item_qty_rec get_csi_item_qty_csr%ROWTYPE;

    l_input_details   OKS_QP_PKG.INPUT_DETAILS;
    l_output_details  OKS_QP_PKG.PRICE_DETAILS;
    l_modif_details   QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    l_pb_details      OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE;
    l_return_status   VARCHAR2(20) := 'S';
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    BEGIN

        FOR get_all_instances_rec IN get_all_instances_csr
            LOOP
            OPEN get_okc_item_qty_csr(get_all_instances_rec.id);
            FETCH get_okc_item_qty_csr INTO get_okc_item_qty_rec;
            CLOSE get_okc_item_qty_csr;

            OPEN get_csi_item_qty_csr (get_okc_item_qty_rec.object1_id1);
            FETCH get_csi_item_qty_csr INTO get_csi_item_qty_rec;
            CLOSE get_csi_item_qty_csr;

            IF NVL(get_csi_item_qty_rec.quantity, 0) > NVL(get_okc_item_qty_rec.number_of_items, 0)
                THEN
                UPDATE okc_k_items
                SET number_of_items = get_csi_item_qty_rec.quantity
                WHERE cle_id = get_all_instances_rec.id;

                --calling reprice
                l_input_details.line_id := p_cle_id;
                l_input_details.subline_id := get_all_instances_rec.id;
                l_input_details.intent := 'SP';
                OKS_QP_INT_PVT.Compute_Price
                (
                 p_api_version => 1.0,
                 p_init_msg_list => 'T',
                 p_detail_rec => l_input_details,
                 x_price_details => l_output_details,
                 x_modifier_details => l_modif_details,
                 x_price_break_details => l_pb_details,
                 x_return_status => l_return_status,
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data
                 );

                --refresh schedule
                IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    RAISE G_ERROR;
                END IF;
                oks_bill_sch.Create_Bill_Sch_CP
                (
                 p_top_line_id => p_cle_id,
                 p_cp_line_id => get_all_instances_rec.id,
                 p_cp_new => 'N',
                 x_return_status => l_return_status,
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data);

                IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    RAISE G_ERROR;
                END IF;
            END IF;
        END LOOP;
        x_return_status := l_return_status;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
    EXCEPTION
        WHEN G_ERROR THEN

            NULL;
        WHEN OTHERS THEN

            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME_OKC,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);

            x_return_status := G_RET_STS_UNEXP_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;

    END update_quantity;
    -- added for contact creation OCT2004
    PROCEDURE create_person (
                             p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
                             p_person_tbl                       IN      PERSON_TBL_TYPE,
                             x_party_id                         OUT NOCOPY     NUMBER,
                             x_party_number                     OUT NOCOPY     VARCHAR2,
                             x_profile_id                       OUT NOCOPY     NUMBER,
                             x_return_status                    OUT NOCOPY     VARCHAR2,
                             x_msg_count                        OUT NOCOPY     NUMBER,
                             x_msg_data                         OUT NOCOPY     VARCHAR2
                             )IS
    l_person_rec                     HZ_PARTY_V2PUB.person_rec_type ;
    l_init_msg_list        CONSTANT  VARCHAR2(1) := 'F';
    l_return_status                  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
        l_person_rec.person_pre_name_adjunct := p_person_tbl(1).person_pre_name_adjunct;
        l_person_rec.person_first_name := p_person_tbl(1).person_first_name;
        l_person_rec.person_last_name := p_person_tbl(1).person_last_name;
        l_person_rec.content_source_type := 'USER_ENTERED';
        l_person_rec.actual_content_source := 'SST';
        l_person_rec.created_by_module := 'OKS_AUTH';


        HZ_PARTY_V2PUB.create_person (
                                      p_init_msg_list => l_init_msg_list,
                                      p_person_rec => l_person_rec,
                                      x_party_id => x_party_id,
                                      x_party_number => x_party_number,
                                      x_profile_id => x_profile_id,
                                      x_return_status => x_return_status,
                                      x_msg_count => x_msg_count,
                                      x_msg_data => x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE update_person (
                             p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
                             p_person_tbl                       IN      PERSON_TBL_TYPE,
                             p_party_object_version_number      IN     NUMBER,
                             x_profile_id                       OUT NOCOPY     NUMBER,
                             x_return_status                    OUT NOCOPY     VARCHAR2,
                             x_msg_count                        OUT NOCOPY     NUMBER,
                             x_msg_data                         OUT NOCOPY     VARCHAR2
                             )IS
    l_person_rec                     HZ_PARTY_V2PUB.person_rec_type ;
    l_party_rec                      HZ_PARTY_V2PUB.party_rec_type;
    l_init_msg_list        CONSTANT  VARCHAR2(1) := 'F';
    l_party_object_version_number    NUMBER := p_party_object_version_number;
    BEGIN

        l_party_rec.party_id := p_person_tbl(1).party_id;
        l_person_rec.party_rec := l_party_rec;
        l_person_rec.person_pre_name_adjunct := p_person_tbl(1).person_pre_name_adjunct;
        l_person_rec.person_first_name := p_person_tbl(1).person_first_name;
        l_person_rec.person_last_name := p_person_tbl(1).person_last_name;
        l_person_rec.content_source_type := 'USER_ENTERED';
        l_person_rec.actual_content_source := 'SST';
        --l_person_rec.created_by_module       := 'OKS_AUTH';

        HZ_PARTY_V2PUB.update_person(
                                     p_init_msg_list => l_init_msg_list,
                                     p_person_rec => l_person_rec,
                                     p_party_object_version_number => l_party_object_version_number,
                                     x_profile_id => x_profile_id,
                                     x_return_status => x_return_status,
                                     x_msg_count => x_msg_count,
                                     x_msg_data => x_msg_data);
    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);

    END;

    PROCEDURE create_org_contact (
                                  p_init_msg_list                    IN       VARCHAR2 := FND_API.G_FALSE,
                                  p_org_contact_tbl                  IN       ORG_CONTACT_TBL_TYPE,
                                  p_relationship_tbl_type            IN       relationship_tbl_type,
                                  x_org_contact_id                   OUT NOCOPY      NUMBER,
                                  x_party_rel_id                     OUT NOCOPY      NUMBER,
                                  x_party_id                         OUT NOCOPY      NUMBER,
                                  x_party_number                     OUT NOCOPY      VARCHAR2,
                                  x_return_status                    OUT NOCOPY      VARCHAR2,
                                  x_msg_count                        OUT NOCOPY      NUMBER,
                                  x_msg_data                         OUT NOCOPY      VARCHAR2
                                  )IS
    l_init_msg_list         CONSTANT  VARCHAR2(1) := 'F';
    relationship_rel_rec    HZ_RELATIONSHIP_V2PUB.relationship_rec_type ;
    org_contact_rec         HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type ;
    BEGIN
        relationship_rel_rec.subject_id := p_relationship_tbl_type(1).subject_id;
        relationship_rel_rec.subject_type := p_relationship_tbl_type(1).subject_type ; --'PERSON';
        relationship_rel_rec.subject_table_name := p_relationship_tbl_type(1).subject_table_name; --'HZ_PARTIES';
        relationship_rel_rec.object_id := p_relationship_tbl_type(1).object_id;
        relationship_rel_rec.object_type := p_relationship_tbl_type(1).object_type;
        relationship_rel_rec.object_table_name := p_relationship_tbl_type(1).object_table_name; --'HZ_PARTIES';
        relationship_rel_rec.relationship_code := p_relationship_tbl_type(1).relationship_code ; --'CONTACT_OF';
        relationship_rel_rec.relationship_type := p_relationship_tbl_type(1).relationship_type ; --'CONTACT';
        relationship_rel_rec.created_by_module := 'OKS_AUTH';
        relationship_rel_rec.content_source_type := 'USER_ENTERED';
        --  relationship_rel_rec.actual_content_source := 'SST';
        org_contact_rec.job_title_code := p_org_contact_tbl(1).job_title_code;
        org_contact_rec.job_title := p_org_contact_tbl(1).job_title;
        org_contact_rec.party_site_id := p_org_contact_tbl(1).party_site_id;
        org_contact_rec.created_by_module := 'OKS_AUTH';
        org_contact_rec.party_rel_rec := relationship_rel_rec;
        HZ_PARTY_CONTACT_V2PUB.create_org_contact(
                                                  p_init_msg_list => l_init_msg_list,
                                                  p_org_contact_rec => org_contact_rec,
                                                  x_org_contact_id => x_org_contact_id,
                                                  x_party_rel_id => x_party_rel_id,
                                                  x_party_id => x_party_id,
                                                  x_party_number => x_party_number,
                                                  x_return_status => x_return_status,
                                                  x_msg_count => x_msg_count,
                                                  x_msg_data => x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE update_org_contact (
                                  p_init_msg_list                    IN       VARCHAR2 := FND_API.G_FALSE,
                                  p_org_contact_tbl                  IN       ORG_CONTACT_TBL_TYPE,
                                  p_relationship_tbl_type            IN       relationship_tbl_type,
                                  p_cont_object_version_number       IN OUT NOCOPY   NUMBER,
                                  p_rel_object_version_number        IN OUT NOCOPY   NUMBER,
                                  p_party_object_version_number      IN OUT NOCOPY   NUMBER,
                                  x_return_status                    OUT NOCOPY      VARCHAR2,
                                  x_msg_count                        OUT NOCOPY      NUMBER,
                                  x_msg_data                         OUT NOCOPY      VARCHAR2
                                  )IS
    l_init_msg_list        CONSTANT  VARCHAR2(1) := 'F';
    relationship_rel_rec             HZ_RELATIONSHIP_V2PUB.relationship_rec_type ;
    org_contact_rec                  HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type ;
    party_rec                        HZ_PARTY_V2PUB.PARTY_REC_TYPE ;
    l_cont_object_version_number     NUMBER := p_cont_object_version_number;
    l_rel_object_version_number      NUMBER := p_rel_object_version_number;
    l_party_object_version_number    NUMBER := p_party_object_version_number;

    BEGIN
        party_rec.party_id := p_relationship_tbl_type(1).relationship_id;
        relationship_rel_rec.party_rec := party_rec;
        relationship_rel_rec.subject_id := p_relationship_tbl_type(1).subject_id;
        relationship_rel_rec.subject_type := p_relationship_tbl_type(1).subject_type ; --'PERSON';
        relationship_rel_rec.subject_table_name := p_relationship_tbl_type(1).subject_table_name; --'HZ_PARTIES';
        relationship_rel_rec.object_id := p_relationship_tbl_type(1).object_id;
        relationship_rel_rec.object_type := p_relationship_tbl_type(1).object_type;
        relationship_rel_rec.object_table_name := p_relationship_tbl_type(1).object_table_name; --'HZ_PARTIES';
        relationship_rel_rec.relationship_code := p_relationship_tbl_type(1).relationship_code ; --'CONTACT_OF';
        relationship_rel_rec.relationship_type := p_relationship_tbl_type(1).relationship_type ; --'CONTACT';
        relationship_rel_rec.content_source_type := 'USER_ENTERED';
        relationship_rel_rec.actual_content_source := 'SST';
        org_contact_rec.job_title_code := p_org_contact_tbl(1).job_title_code;
        org_contact_rec.job_title := p_org_contact_tbl(1).job_title;
        org_contact_rec.org_contact_id := p_org_contact_tbl(1).org_contact_id;
        org_contact_rec.party_site_id := p_org_contact_tbl(1).party_site_id;
        org_contact_rec.party_rel_rec := relationship_rel_rec;

        HZ_PARTY_CONTACT_V2PUB.update_org_contact(
                                                  p_init_msg_list => l_init_msg_list,
                                                  p_org_contact_rec => org_contact_rec,
                                                  p_cont_object_version_number => l_cont_object_version_number,
                                                  p_rel_object_version_number => l_rel_object_version_number,
                                                  p_party_object_version_number => l_party_object_version_number,
                                                  x_return_status => x_return_status,
                                                  x_msg_count => x_msg_count,
                                                  x_msg_data => x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE create_party_site (
                                 p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
                                 p_party_site_tbl                IN          PARTY_SITE_TBL_TYPE,
                                 x_party_site_id                 OUT NOCOPY         NUMBER,
                                 x_party_site_number             OUT NOCOPY         VARCHAR2,
                                 x_return_status                 OUT NOCOPY         VARCHAR2,
                                 x_msg_count                     OUT NOCOPY         NUMBER,
                                 x_msg_data                      OUT NOCOPY         VARCHAR2
                                 )IS

    party_site_rec                   HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
    l_init_msg_list        CONSTANT  VARCHAR2(1) := 'F';
    --npalepu added on 4/26/2006 for bug # 5174716
    l_hz_prof_val VARCHAR2(1);
    l_change_prof VARCHAR2(1) := 'N';
    --end npalepu

    BEGIN

        party_site_rec.party_id := p_party_site_tbl(1).party_id ;
        party_site_rec.location_id := p_party_site_tbl(1).location_id;
        party_site_rec.mailstop := p_party_site_tbl(1).mailstop;
        party_site_rec.identifying_address_flag := 'Y';
        party_site_rec.created_by_module := 'OKS_AUTH';

        --npalepu added on 4/26/2006 for bug # 5174716
        --setting the profile value HZ_GENERATE_PARTY_SITE_NUMBER to Y if it is set to N
        --inorder to auto generate the party_site_number irrespective of the profile value
        l_hz_prof_val := fnd_profile.value('HZ_GENERATE_PARTY_SITE_NUMBER');
        IF l_hz_prof_val = 'N' THEN
                fnd_profile.put('HZ_GENERATE_PARTY_SITE_NUMBER','Y');
                l_change_prof := 'Y';
        END IF;
        --end npalepu

        HZ_PARTY_SITE_V2PUB.create_party_site(
                                              p_init_msg_list => l_init_msg_list,
                                              p_party_site_rec => party_site_rec,
                                              x_party_site_id => x_party_site_id,
                                              x_party_site_number => x_party_site_number,
                                              x_return_status => x_return_status,
                                              x_msg_count => x_msg_count,
                                              x_msg_data => x_msg_data);

        --npalepu added on 4/26/2006 for bug # 5174716
        IF l_change_prof = 'Y' THEN
                fnd_profile.put('HZ_GENERATE_PARTY_SITE_NUMBER',l_hz_prof_val);
        END IF;
        --end npalepu

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE update_party_site (
                                 p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
                                 p_party_site_tbl                IN          PARTY_SITE_TBL_TYPE,
                                 p_object_version_number         IN OUT NOCOPY      NUMBER,
                                 x_return_status                 OUT NOCOPY         VARCHAR2,
                                 x_msg_count                     OUT NOCOPY         NUMBER,
                                 x_msg_data                      OUT NOCOPY         VARCHAR2
                                 )IS
    party_site_rec                   hz_party_site_v2pub.PARTY_SITE_REC_TYPE;
    l_init_msg_list        CONSTANT  VARCHAR2(1) := 'F';
    l_object_version_number          NUMBER := p_object_version_number;
    BEGIN

        party_site_rec.party_id := p_party_site_tbl(1).party_id ;
        party_site_rec.location_id := p_party_site_tbl(1).location_id;
        party_site_rec.party_site_id := p_party_site_tbl(1).party_site_id;
        party_site_rec.mailstop := p_party_site_tbl(1).mailstop;
        HZ_PARTY_SITE_V2PUB.update_party_site(
                                              p_init_msg_list => l_init_msg_list,
                                              p_party_site_rec => party_site_rec,
                                              p_object_version_number => l_object_version_number,
                                              x_return_status => x_return_status,
                                              x_msg_count => x_msg_count,
                                              x_msg_data => x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE create_cust_account_role (
                                        p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
                                        p_cust_account_role_tbl                 IN     CUST_ACCOUNT_ROLE_tbl_TYPE,
                                        x_cust_account_role_id                  OUT NOCOPY    NUMBER,
                                        x_return_status                         OUT NOCOPY    VARCHAR2,
                                        x_msg_count                             OUT NOCOPY    NUMBER,
                                        x_msg_data                              OUT NOCOPY    VARCHAR2
                                        ) IS
    l_init_msg_list        CONSTANT  VARCHAR2(1) := 'F';
    cust_account_role_rec       Hz_cust_account_role_v2pub.cust_account_role_rec_type;
    BEGIN
        cust_account_role_rec.party_id := p_cust_account_role_tbl(1).party_id;
        cust_account_role_rec.role_type := p_cust_account_role_tbl(1).role_type;
        cust_account_role_rec.cust_account_id := p_cust_account_role_tbl(1).cust_account_id;
        cust_account_role_rec.cust_acct_site_id := p_cust_account_role_tbl(1).cust_acct_site_id;
        cust_account_role_rec.primary_flag := p_cust_account_role_tbl(1).primary_flag;
        cust_account_role_rec.status := p_cust_account_role_tbl(1).status;
        cust_account_role_rec.created_by_module := 'OKS_AUTH';

        Hz_cust_account_role_v2pub.create_cust_account_role(
                                                            p_init_msg_list => l_init_msg_list,
                                                            p_cust_account_role_rec => cust_account_role_rec,
                                                            x_cust_account_role_id => x_cust_account_role_id,
                                                            x_return_status => x_return_status,
                                                            x_msg_count => x_msg_count,
                                                            x_msg_data => x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE update_cust_account_role (
                                        p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
                                        p_cust_account_role_tbl                 IN     CUST_ACCOUNT_ROLE_tbl_TYPE,
                                        p_object_version_number                 IN OUT NOCOPY NUMBER,
                                        x_return_status                         OUT NOCOPY    VARCHAR2,
                                        x_msg_count                             OUT NOCOPY    NUMBER,
                                        x_msg_data                              OUT NOCOPY    VARCHAR2
                                        )IS
    l_init_msg_list        CONSTANT  VARCHAR2(1) := 'F';
    l_object_version_number          NUMBER := p_object_version_number;
    cust_account_role_rec       Hz_cust_account_role_v2pub.cust_account_role_rec_type;
    BEGIN
        cust_account_role_rec.cust_account_role_id := p_cust_account_role_tbl(1).cust_account_role_id;
        cust_account_role_rec.party_id := p_cust_account_role_tbl(1).party_id;
        cust_account_role_rec.role_type := p_cust_account_role_tbl(1).role_type;
        cust_account_role_rec.cust_account_id := p_cust_account_role_tbl(1).cust_account_id;
        cust_account_role_rec.cust_acct_site_id := p_cust_account_role_tbl(1).cust_acct_site_id;
        cust_account_role_rec.primary_flag := p_cust_account_role_tbl(1).primary_flag;
        cust_account_role_rec.status := p_cust_account_role_tbl(1).status;

        Hz_cust_account_role_v2pub.update_cust_account_role(
                                                            p_init_msg_list => l_init_msg_list,
                                                            p_cust_account_role_rec => cust_account_role_rec,
                                                            p_object_version_number => l_object_version_number,
                                                            x_return_status => x_return_status,
                                                            x_msg_count => x_msg_count,
                                                            x_msg_data => x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    PROCEDURE create_cust_acct_site (
                                     p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
                                     p_cust_acct_site_tbl                    IN     CUST_ACCT_SITE_TBL_TYPE,
                                     x_cust_acct_site_id                     OUT NOCOPY    NUMBER,
                                     x_return_status                         OUT NOCOPY    VARCHAR2,
                                     x_msg_count                             OUT NOCOPY    NUMBER,
                                     x_msg_data                              OUT NOCOPY    VARCHAR2
                                     )IS
    l_init_msg_list        CONSTANT  VARCHAR2(1) := 'F';
    cust_acct_site_rec               HZ_CUST_ACCOUNT_SITE_V2PUB.cust_acct_site_rec_type;
    BEGIN

        cust_acct_site_rec.cust_account_id := p_cust_acct_site_tbl(1).cust_account_id ;
        cust_acct_site_rec.party_site_id := p_cust_acct_site_tbl(1).party_site_id;
        cust_acct_site_rec.created_by_module := 'OKS_AUTH' ;

        Hz_cust_account_site_v2pub.create_cust_acct_site(
                                                         p_init_msg_list => l_init_msg_list,
                                                         p_cust_acct_site_rec => cust_acct_site_rec,
                                                         x_cust_acct_site_id => x_cust_acct_site_id,
                                                         x_return_status => x_return_status,
                                                         x_msg_count => x_msg_count,
                                                         x_msg_data => x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);

    END;

    PROCEDURE update_cust_acct_site (
                                     p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
                                     p_cust_acct_site_tbl                    IN     CUST_ACCT_SITE_TBL_TYPE,
                                     p_object_version_number                 IN OUT NOCOPY NUMBER,
                                     x_return_status                         OUT NOCOPY    VARCHAR2,
                                     x_msg_count                             OUT NOCOPY    NUMBER,
                                     x_msg_data                              OUT NOCOPY    VARCHAR2
                                     )IS
    l_init_msg_list        CONSTANT  VARCHAR2(1) := 'F';
    l_object_version_number          NUMBER := p_object_version_number;
    cust_acct_site_rec               HZ_CUST_ACCOUNT_SITE_V2PUB.cust_acct_site_rec_type;
    BEGIN

        cust_acct_site_rec.cust_account_id := p_cust_acct_site_tbl(1).cust_account_id ;
        cust_acct_site_rec.party_site_id := p_cust_acct_site_tbl(1).party_site_id;
        cust_acct_site_rec.cust_acct_site_id := p_cust_acct_site_tbl(1).cust_acct_site_id;
        --cust_acct_site_rec.created_by_module   := 'OKS_AUTH' ;
        Hz_cust_account_site_v2pub.update_cust_acct_site(
                                                         p_init_msg_list => l_init_msg_list,
                                                         p_cust_acct_site_rec => cust_acct_site_rec,
                                                         p_object_version_number => l_object_version_number,
                                                         x_return_status => x_return_status,
                                                         x_msg_count => x_msg_count,
                                                         x_msg_data => x_msg_data);

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);
    END;

    /**** Partial Period Computation Project  **/
    -- P_intent --> 'H' Header
    -- P_intent --> 'T' Topline
    -- P_intent --> 'S' Subline
    FUNCTION Is_Line_Eligible(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2,
                              p_contract_hdr_id    IN  NUMBER,  -- VARCHAR2
                              p_contract_line_id   IN  NUMBER,
                              p_price_list_id      IN  NUMBER,
                              p_intent	       IN  VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2
                              ) RETURN BOOLEAN IS

    CURSOR check_eligiblity_line IS
        SELECT 'Y' FROM OKC_K_LINES_B
        WHERE dnz_chr_id = p_contract_hdr_id
        AND   id = p_contract_line_id
        AND(date_terminated IS NULL OR date_terminated > TRUNC(SYSDATE))
        AND date_cancelled IS NULL
        AND end_date > NVL(oks_bill_util_pub.get_billed_upto(id, p_intent), end_date - 1);


    CURSOR get_lines_id IS
        SELECT ID, LSE_ID FROM OKC_K_LINES_B
        WHERE dnz_chr_id = p_contract_hdr_id
        AND cle_id IS NULL
        AND(date_terminated IS NULL OR date_terminated > TRUNC(SYSDATE))
        AND date_cancelled IS NULL
        AND end_date > NVL(oks_bill_util_pub.get_billed_upto(id, 'T'), end_date - 1);

    CURSOR get_lines_details (p_chr_id IN NUMBER, p_cle_id IN NUMBER) IS
        SELECT  locked_price_list_id,
            locked_price_list_line_id
        FROM    OKS_k_LINES_B
        WHERE   dnz_chr_id = p_chr_id
        AND     cle_id = p_cle_id ;

    l_return_status VARCHAR2(2);
    l_status        VARCHAR2(2);
    l_locked_price_list_line_id NUMBER;
    l_locked_price_list_id NUMBER;
    l_source_price_list_line_id NUMBER;
    l_api_version          NUMBER := 1.0;
    l_init_msg_list        VARCHAR2(1) := 'T';
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(1000);

    BEGIN
        -- If Intent is 'H' the call is made from
        -- Authoring and we would update the price list
        -- Else find the status whether the line is eligible
        -- for repricing or not.

        IF P_intent = 'H'
            THEN
            FOR cur_rec IN get_lines_id
                LOOP
                UPDATE okc_k_lines_b
                SET price_list_id = p_price_list_id
                WHERE dnz_chr_id = p_contract_hdr_id
                AND cle_id IS NULL
                AND ID = CUR_REC.id;

                IF CUR_REC.lse_id  IN (12, 13) THEN
                    -- delete the price break given for Usage line
                    -- CURSOR to fetch locked list details

                    OPEN get_lines_details (p_contract_hdr_id, cur_rec.id);
                    FETCH get_lines_details INTO l_locked_price_list_id, l_locked_price_list_line_id;
                    CLOSE get_lines_details;
                    l_source_price_list_line_id := l_locked_price_list_line_id;

                    IF  l_source_price_list_line_id IS NOT NULL THEN
                        oks_qp_pkg.delete_locked_pricebreaks(l_api_version,
                                                             l_source_price_list_line_id,
                                                             l_init_msg_list,
                                                             l_return_status,
                                                             l_msg_count,
                                                             l_msg_data);
                        IF l_return_status <> 'S' THEN
                            l_status := 'N';
                            EXIT;
                        END IF;
                    END IF;
                END IF;

                UPDATE OKS_K_LINES_B SET
                locked_price_list_id = NULL,
                locked_price_list_line_id = NULL
                WHERE dnz_chr_id = p_contract_hdr_id
                AND cle_id = cur_rec.id ;
            END LOOP;
            l_status := nvl(l_status, 'Y');
        ELSE
            OPEN check_eligiblity_line;
            FETCH check_eligiblity_line INTO l_status;
            CLOSE check_eligiblity_line;
        END IF;

        IF NVL(l_status, 'X') = 'Y'
            THEN
            RETURN(TRUE);
        ELSE
            RETURN(FALSE);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN(FALSE);
            OKC_API.set_message
            (OKC_API.G_APP_NAME,
             G_UNEXPECTED_ERROR,
             G_SQLCODE_TOKEN,
             SQLCODE,
             G_SQLERRM_TOKEN,
             SQLERRM);

    END Is_Line_Eligible;
    /**** Partial Period Computation Project  **/
    -- end contact creation OCT 2004

        /*
        This new procedure was added to resolve bug 5243626.
        It updates amount for a topline if and only if topline amount
        does not euqal to the sum of subline amounts. Similarly it
        updates the header amount if and only if, the header amount does
        not equal the sum of line amounts.

        This avoids unncessary updates to lines and prevents record locking
        when multiple users access the same contract. The example given below
        illustrates record locking in authoring and how it can be avoided in most cases

                    User 1 Action                       User 2 Action
        Time A      Open Contract K1                    Open same Contract K1

        Time B      Modify contract header              Modify topline 1
                    -Header record locked               -Top line record locked.
                    -No amount changes required.        -No amount changes required.

        Time C      Try to save contract K1             No action
                    -Application hangs as               -User 2 continues to hold lock
                    -unconditional update of topline    -on topline 1.
                    -amount waits for lock on topline
                    -1 to be released by User 2.
                    -Header and contract version number
                    -updated.

        Time D      No action                           Try to save contract K1
                                                        -Deadlock detected
                                                        -User 1 is waiting for lock on
                                                        -topline 1 held by user 2.
                                                        -User 2 is waiting for lock on
                                                        -version number held by user 1.

        To avoid, the above record locking and deadlock, we one needs to
            1. Conditionally update the topline amount and header amount. Do not
               update if amounts are in sync whith child entities.
            2. Do not update contract version as part of header/line or any other
               enitity update. Defer contract version update till all other updates
               are successful.

        Please note that if two users attempt to modify the same line or same entity
        in a contract, record locking cannot be and should not be prevented.

    */
       PROCEDURE CHECK_UPDATE_AMOUNTS
    (
     p_api_version                           IN NUMBER,
     p_init_msg_list                         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_commit                                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_chr_id                                IN NUMBER,
     x_msg_count                             OUT NOCOPY    NUMBER,
     x_msg_data                              OUT NOCOPY    VARCHAR2,
     x_return_status                         OUT NOCOPY    VARCHAR2
    )
    IS

      l_api_name CONSTANT VARCHAR2(30) := 'CHECK_UPDATE_AMOUNTS';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_APP_NAME_OKS) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    E_RESOURCE_BUSY  EXCEPTION;
    PRAGMA  EXCEPTION_INIT(E_Resource_Busy, -00054);

    l_tl_id_tbl         num_tbl_type;
    l_tl_amt_tbl        num_tbl_type;
    l_sl_amt_tbl        num_tbl_type;
    l_tl_amt_tax_tbl    num_tbl_type;
    l_sl_amt_tax_tbl    num_tbl_type;
    l_tl_amt            NUMBER;
    l_hdr_amt           NUMBER;
    l_hdr_amt_tax       NUMBER;
    l_tl_amt_tax        NUMBER;
    l_dummy             NUMBER;
    l_line_name         VARCHAR2(2000);
    l_k_num             VARCHAR2(450);
    l_header_cancelled  NUMBER;
    l_topline_cancelled NUMBER;

    --select all toplines where topline amount is not equal to sum of subline amounts
    CURSOR c_k_toplines (cp_chr_id IN NUMBER) IS
        SELECT a.id, nvl(a.price_negotiated, 0) topline_amt,
        SUM(nvl(b.price_negotiated,0)) sum_subline_amt,
        nvl(c.tax_amount,0) topline_tax_amt,
        SUM(nvl(d.tax_amount,0)) sum_subline_tax_amt
        FROM okc_k_lines_b a, okc_k_lines_b b,
             oks_k_lines_b c, oks_k_lines_b d
        WHERE a.dnz_chr_id = cp_chr_id AND a.lse_id IN (1,12,14,19)
        AND b.dnz_chr_id = a.dnz_chr_id AND b.cle_id = a.id
        AND a.id=c.cle_id AND b.id=d.cle_id
        AND b.lse_id IN (7,8,9,10,11,35,13,18,25)
        AND a.date_cancelled is null
        AND b.date_cancelled is null
        GROUP BY a.id, a.price_negotiated,c.tax_amount
        HAVING nvl(a.price_negotiated, 0) <> SUM(nvl(b.price_negotiated,0))
              OR nvl(c.tax_amount, 0) <> SUM(nvl(d.tax_amount,0));

--cgopinee bugfix for 7717417
     CURSOR c_k_tl_zero_sl (cp_chr_id IN NUMBER) IS
        SELECT a.id, nvl(a.price_negotiated, 0) topline_amt,
        0 sum_subline_amt,
        nvl(c.tax_amount,0) topline_tax_amt,
        0 sum_subline_tax_amt
        FROM okc_k_lines_b a,
             oks_k_lines_b c
        WHERE a.dnz_chr_id = cp_chr_id
        AND a.lse_id IN (1,12,14,19)
        AND a.id=c.cle_id
        AND a.date_cancelled is null
        and not exists( select 1 from okc_k_lines_b b
            WHERE b.lse_id IN (7,8,9,10,11,35,13,18,25)
                AND b.date_cancelled is null
                AND b.dnz_chr_id=a.dnz_chr_id
                AND b.cle_id=a.id);

    CURSOR c_lock_tl(cp_id IN NUMBER) IS
        SELECT price_negotiated
        FROM okc_k_lines_b WHERE id = cp_id
        FOR UPDATE OF price_negotiated NOWAIT;

    CURSOR c_line_name(cp_id IN NUMBER) IS
        SELECT substr(RTRIM(RTRIM(line_number) || ', ' || RTRIM(lsev.name) || ' ' || RTRIM(clev.name)), 1, 2000) line_name
        FROM   okc_line_styles_v lsev, okc_k_lines_v clev
        WHERE  lsev.id = clev.lse_id
        AND    clev.id =  cp_id;

    CURSOR c_k_hdr(cp_chr_id IN NUMBER) IS
        SELECT a.contract_number ||' '|| a.contract_number_modifier,
        nvl(a.estimated_amount, 0) hdr_amt,
        SUM(nvl(b.price_negotiated,0)) sum_tl_line_amt,
        nvl(c.tax_amount,0) hdr_tax_amt,
        SUM(nvl(d.tax_amount,0)) sum_tl_line_amt_tax
        FROM okc_k_headers_all_b a, okc_k_lines_b b,
             oks_k_headers_b c, oks_k_lines_b d
        WHERE a.id = cp_chr_id
        AND b.dnz_chr_id = a.id AND b.cle_id IS NULL
        AND d.dnz_chr_id = c.chr_id AND d.cle_id=b.id
        AND b.date_cancelled is null
        AND b.lse_id IN (1,12,14,19,46)
        GROUP BY a.contract_number, a.contract_number_modifier, a.estimated_amount,c.tax_amount;

  --cgopinee bugfix for 7717417
    CURSOR c_k_hdr_zero_tl(cp_chr_id IN NUMBER) IS
        SELECT a.contract_number ||' '|| a.contract_number_modifier,
        nvl(a.estimated_amount, 0) hdr_amt,
        0 sum_tl_line_amt,
        nvl(c.tax_amount,0) hdr_tax_amt,
        0 sum_tl_line_amt_tax
        FROM okc_k_headers_all_b a,
             oks_k_headers_b c
        WHERE a.id = cp_chr_id
        AND c.chr_id = a.id
        AND NOT EXISTS (SELECT 1 from okc_k_lines_b b
            WHERE  b.dnz_chr_id = a.id
            AND b.cle_id IS NULL
            AND b.date_cancelled is null
            AND b.lse_id IN (1,12,14,19,46));

        CURSOR c_lock_hdr(cp_chr_id IN NUMBER) IS
        SELECT estimated_amount
        FROM okc_k_headers_all_b WHERE id = cp_chr_id
        FOR UPDATE OF estimated_amount NOWAIT;

     -- select all the toplines which has cancelled amount not equal to those of sublines
    CURSOR c_k_toplines_cancelled (cp_chr_id IN NUMBER) IS
        SELECT a.id, nvl(a.cancelled_amount, 0) topline_canceled_amt,           /*modified for bug:6765336*/
            SUM(nvl(b.cancelled_amount,0)) sum_subline_cancelled_amt
        FROM okc_k_lines_b a, okc_k_lines_b b
        WHERE a.dnz_chr_id = cp_chr_id AND a.lse_id IN (1,12,14,19)
	        AND b.dnz_chr_id = a.dnz_chr_id AND b.cle_id = a.id
        AND a.date_cancelled is null
        AND b.date_cancelled is not null
        GROUP BY a.id, a.cancelled_amount
        HAVING nvl(a.cancelled_amount, 0) <> SUM(nvl(b.cancelled_amount,0));       /*modified for bug:6765336*/

     -- select header cancelled amount and sum of topline cancelled amounts
     CURSOR c_k_hdr_cancelled(cp_chr_id IN NUMBER) IS
        SELECT
            nvl(a.cancelled_amount, 0) hdr_cancelled_amt,
            SUM(nvl(b.cancelled_amount,0)) sum_tl_line_cancelled_amt
        FROM okc_k_headers_all_b a, okc_k_lines_b b
        WHERE a.id = cp_chr_id
        AND b.dnz_chr_id = a.id AND b.cle_id IS NULL
        AND b.lse_id IN (1,12,14,19,46)
        GROUP BY a.cancelled_amount;

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_api_version=' || p_api_version ||' ,p_commit='|| p_commit ||' ,p_chr_id='|| p_chr_id);
        END IF;

        --standard api initilization and checks
        SAVEPOINT check_update_amounts_PVT;
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --get all toplines that are out of sync with sublines
        OPEN c_k_toplines(p_chr_id);
        LOOP
             FETCH c_k_toplines BULK COLLECT INTO l_tl_id_tbl, l_tl_amt_tbl, l_sl_amt_tbl,l_tl_amt_tax_tbl,l_sl_amt_tax_tbl LIMIT G_BULK_FETCH_LIMIT;
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.c_k_toplines.bulk_fetch', 'l_tl_id_tbl.count='||l_tl_id_tbl.count);
            END IF;

            EXIT WHEN (l_tl_id_tbl.count = 0);

            FOR i IN l_tl_id_tbl.first..l_tl_id_tbl.last LOOP

                --before updating the topline amount, first try to obtain a lock on the topline
                --if the lock fails, another user is holding the lock, exit with appropriate
                --error message. If the lock succeeds, update the top line amount
                BEGIN

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.lock_line', 'checking lock for line id='||l_tl_id_tbl(i));
                    END IF;

                    IF (l_tl_amt_tbl(i) <> l_sl_amt_tbl(i))OR ( l_tl_amt_tax_tbl(i) <> l_sl_amt_tax_tbl(i)) THEN
                        OPEN c_lock_tl(l_tl_id_tbl(i));
                        FETCH c_lock_tl INTO l_dummy;
                        CLOSE c_lock_tl;
                    END IF;
                EXCEPTION
                    WHEN E_RESOURCE_BUSY THEN
                        IF c_lock_tl%isopen THEN
                            CLOSE c_lock_tl;
                        END IF;
                        OPEN c_line_name(l_tl_id_tbl(i));
                        FETCH c_line_name INTO l_line_name;
                        CLOSE c_line_name;

                        --set the error message on the error stack to inform the user
                        FND_MESSAGE.set_name(G_APP_NAME_OKS, 'OKS_LINE_LOCKED');
                        FND_MESSAGE.set_token('LINE_NAME', l_line_name);

                        IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                            FND_LOG.message(FND_LOG.level_error, l_mod_name || '.lock_line_fail', FALSE);
                        END IF;
                        FND_MSG_PUB.ADD;

                        l_tl_id_tbl.delete;
                        l_tl_amt_tbl.delete;
                        l_sl_amt_tbl.delete;
                        l_tl_amt_tax_tbl.delete;
                        l_sl_amt_tax_tbl.delete;

                        RAISE FND_API.g_exc_error;

                END; --of anonymous block checking topline locks

            END LOOP;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_line', 'able to lock all fetched toplines - updating amount');
            END IF;

            --if we come till here, we where able to obtain locks on all the toplines fectched previously
            FORALL j IN  l_tl_id_tbl.first..l_tl_id_tbl.last
                UPDATE okc_k_lines_b
                    SET price_negotiated = l_sl_amt_tbl(j)
                    WHERE id = l_tl_id_tbl(j);

            FORALL j IN  l_tl_id_tbl.first..l_tl_id_tbl.last
                UPDATE oks_k_lines_b
                    SET tax_amount = l_sl_amt_tax_tbl(j)
                    WHERE cle_id = l_tl_id_tbl(j);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_line', 'amounts updated');
            END IF;

        END LOOP; --of bulk fetch loop
        CLOSE c_k_toplines;
        l_tl_id_tbl.delete;
        l_tl_amt_tbl.delete;
        l_sl_amt_tbl.delete;
        l_tl_amt_tax_tbl.delete;
        l_sl_amt_tax_tbl.delete;

        --cgopinee bugfix for 7717417
        OPEN c_k_tl_zero_sl(p_chr_id);
        LOOP
             FETCH c_k_tl_zero_sl BULK COLLECT INTO l_tl_id_tbl, l_tl_amt_tbl, l_sl_amt_tbl,l_tl_amt_tax_tbl,l_sl_amt_tax_tbl LIMIT G_BULK_FETCH_LIMIT;
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.c_k_tl_zero_sl.bulk_fetch', 'l_tl_id_tbl.count='||l_tl_id_tbl.count);
            END IF;

            EXIT WHEN (l_tl_id_tbl.count = 0);

            FOR i IN l_tl_id_tbl.first..l_tl_id_tbl.last LOOP

                --before updating the topline amount, first try to obtain a lock on the topline
                --if the lock fails, another user is holding the lock, exit with appropriate
                --error message. If the lock succeeds, update the top line amount
                BEGIN

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.lock_line', 'checking lock for line id='||l_tl_id_tbl(i));
                    END IF;

                    IF (l_tl_amt_tbl(i) <> l_sl_amt_tbl(i))OR ( l_tl_amt_tax_tbl(i) <> l_sl_amt_tax_tbl(i)) THEN
                        OPEN c_lock_tl(l_tl_id_tbl(i));
                        FETCH c_lock_tl INTO l_dummy;
                        CLOSE c_lock_tl;
                    END IF;
                EXCEPTION
                    WHEN E_RESOURCE_BUSY THEN
                        IF c_lock_tl%isopen THEN
                            CLOSE c_lock_tl;
                        END IF;
                        OPEN c_line_name(l_tl_id_tbl(i));
                        FETCH c_line_name INTO l_line_name;
                        CLOSE c_line_name;

                        --set the error message on the error stack to inform the user
                        FND_MESSAGE.set_name(G_APP_NAME_OKS, 'OKS_LINE_LOCKED');
                        FND_MESSAGE.set_token('LINE_NAME', l_line_name);

                        IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                            FND_LOG.message(FND_LOG.level_error, l_mod_name || '.lock_line_fail', FALSE);
                        END IF;
                        FND_MSG_PUB.ADD;

                        l_tl_id_tbl.delete;
                        l_tl_amt_tbl.delete;
                        l_sl_amt_tbl.delete;
                        l_tl_amt_tax_tbl.delete;
                        l_sl_amt_tax_tbl.delete;

                        RAISE FND_API.g_exc_error;

                END; --of anonymous block checking topline locks
            END LOOP;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_line', 'able to lock all fetched toplines - updating amount');
            END IF;

            --if we come till here, we where able to obtain locks on all the toplines fectched previously
            FORALL j IN  l_tl_id_tbl.first..l_tl_id_tbl.last
                UPDATE okc_k_lines_b
                    SET price_negotiated = l_sl_amt_tbl(j)
                    WHERE id = l_tl_id_tbl(j);

            FORALL j IN  l_tl_id_tbl.first..l_tl_id_tbl.last
                UPDATE oks_k_lines_b
                    SET tax_amount = l_sl_amt_tax_tbl(j)
                    WHERE cle_id = l_tl_id_tbl(j);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_line', 'amounts updated');
            END IF;
        END LOOP; --of bulk fetch loop

        CLOSE c_k_tl_zero_sl;
        l_tl_id_tbl.delete;
        l_tl_amt_tbl.delete;
        l_sl_amt_tbl.delete;
        l_tl_amt_tax_tbl.delete;
        l_sl_amt_tax_tbl.delete;
        --end of bugfix for 7717417

        OPEN c_k_hdr(p_chr_id);
        FETCH c_k_hdr INTO l_k_num, l_hdr_amt, l_tl_amt,l_hdr_amt_tax,l_tl_amt_tax;
        CLOSE c_k_hdr;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_hdr', 'db hdr amt='||l_hdr_amt||' , sum of toplines='||l_tl_amt);
        END IF;

        --update the header only if required
         IF (l_hdr_amt <> l_tl_amt) OR(l_hdr_amt_tax <> l_tl_amt_tax) THEN

            --before updating the header amount, first try to obtain a lock on the header
            --if the lock fails, another user is holding the lock, exit with appropriate
            --error message. If the lock succeeds, update the header amount
            BEGIN

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.lock_hdr', 'checking lock for header id='||p_chr_id);
                END IF;

                OPEN c_lock_hdr(p_chr_id);
                FETCH c_lock_hdr INTO l_dummy;
                CLOSE c_lock_hdr;

                IF (l_hdr_amt <> l_tl_amt) THEN
                    UPDATE okc_k_headers_all_b
                    SET estimated_amount = l_tl_amt
                    WHERE id = p_chr_id;
                END IF;

                IF (l_hdr_amt_tax <> l_tl_amt_tax) THEN
                    UPDATE oks_k_headers_b
                    SET tax_amount = l_tl_amt_tax
                    where chr_id = p_chr_id;
                END IF;

            EXCEPTION
                WHEN E_RESOURCE_BUSY THEN
                    IF c_lock_hdr%isopen THEN
                        CLOSE c_lock_hdr;
                    END IF;
                    --set the error message on the error stack to inform the user
                    FND_MESSAGE.set_name(G_APP_NAME_OKS, 'OKS_HEADER_LOCKED');
                    FND_MESSAGE.set_token('CONTRACT_NUMBER', l_k_num);

                    IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.message(FND_LOG.level_error, l_mod_name || '.lock_header_fail', FALSE);
                    END IF;
                    FND_MSG_PUB.ADD;

                    RAISE FND_API.g_exc_error;

            END; --of anonymous block checking header lock

        END IF; --of (l_hdr_amt <> l_tl_amt) OR(l_hdr_amt_tax <> l_tl_amt_tax) THEN

        --cgopinee bugfix for 7717417
        OPEN c_k_hdr_zero_tl(p_chr_id);
	        FETCH c_k_hdr_zero_tl INTO l_k_num, l_hdr_amt, l_tl_amt,l_hdr_amt_tax,l_tl_amt_tax;
	        CLOSE c_k_hdr_zero_tl;

	        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
	            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_hdr', 'db hdr amt='||l_hdr_amt||' , sum of toplines='||l_tl_amt);
	        END IF;

	        --update the header only if required
	         IF (l_hdr_amt <> l_tl_amt) OR(l_hdr_amt_tax <> l_tl_amt_tax) THEN

	            --before updating the header amount, first try to obtain a lock on the header
	            --if the lock fails, another user is holding the lock, exit with appropriate
	            --error message. If the lock succeeds, update the header amount
	            BEGIN

	                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
	                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.lock_hdr', 'checking lock for header id='||p_chr_id);
	                END IF;

	                OPEN c_lock_hdr(p_chr_id);
	                FETCH c_lock_hdr INTO l_dummy;
	                CLOSE c_lock_hdr;

	                IF (l_hdr_amt <> l_tl_amt) THEN
	                    UPDATE okc_k_headers_all_b
	                    SET estimated_amount = l_tl_amt
	                    WHERE id = p_chr_id;
	                END IF;

	                IF (l_hdr_amt_tax <> l_tl_amt_tax) THEN
	                    UPDATE oks_k_headers_b
	                    SET tax_amount = l_tl_amt_tax
	                    where chr_id = p_chr_id;
	                END IF;

	            EXCEPTION
	                WHEN E_RESOURCE_BUSY THEN
	                    IF c_lock_hdr%isopen THEN
	                        CLOSE c_lock_hdr;
	                    END IF;
	                    --set the error message on the error stack to inform the user
	                    FND_MESSAGE.set_name(G_APP_NAME_OKS, 'OKS_HEADER_LOCKED');
	                    FND_MESSAGE.set_token('CONTRACT_NUMBER', l_k_num);

	                    IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
	                        FND_LOG.message(FND_LOG.level_error, l_mod_name || '.lock_header_fail', FALSE);
	                    END IF;
	                    FND_MSG_PUB.ADD;

	                    RAISE FND_API.g_exc_error;

	            END; --of anonymous block checking header lock

        END IF; --of (l_hdr_amt <> l_tl_amt) OR(l_hdr_amt_tax <> l_tl_amt_tax)
        --end of bugfix for 7717417

        -- to update cancelled amount of toplines.First get all toplines that are out of sync with sublines
        OPEN c_k_toplines_cancelled(p_chr_id);
        LOOP
             FETCH c_k_toplines_cancelled BULK COLLECT INTO l_tl_id_tbl, l_tl_amt_tbl, l_sl_amt_tbl LIMIT G_BULK_FETCH_LIMIT;
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.c_k_toplines_cancelled.bulk_fetch', 'l_tl_id_tbl.count='||l_tl_id_tbl.count);
            END IF;

            EXIT WHEN (l_tl_id_tbl.count = 0);

            FOR i IN l_tl_id_tbl.first..l_tl_id_tbl.last LOOP

                --before updating the topline cancelled amount, first try to obtain a lock on the topline
                --if the lock fails, another user is holding the lock, exit with appropriate
                --error message. If the lock succeeds, update the top line cancelled amount
                BEGIN

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.lock_line', 'checking lock for line id='||l_tl_id_tbl(i));
                    END IF;

                    OPEN c_lock_tl(l_tl_id_tbl(i));
                    FETCH c_lock_tl INTO l_dummy;
                    CLOSE c_lock_tl;

                EXCEPTION
                    WHEN E_RESOURCE_BUSY THEN
                        IF c_lock_tl%isopen THEN
                            CLOSE c_lock_tl;
                        END IF;
                        OPEN c_line_name(l_tl_id_tbl(i));
                        FETCH c_line_name INTO l_line_name;
                        CLOSE c_line_name;

                        --set the error message on the error stack to inform the user
                        FND_MESSAGE.set_name(G_APP_NAME_OKS, 'OKS_LINE_LOCKED');
                        FND_MESSAGE.set_token('LINE_NAME', l_line_name);

                        IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                            FND_LOG.message(FND_LOG.level_error, l_mod_name || '.lock_line_fail', FALSE);
                        END IF;
                        FND_MSG_PUB.ADD;

                        l_tl_id_tbl.delete;
                        l_tl_amt_tbl.delete;
                        l_sl_amt_tbl.delete;

                        RAISE FND_API.g_exc_error;

                END; --of anonymous block checking topline locks

            END LOOP;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_line', 'able to lock all fetched toplines - updating canceled amount');
            END IF;

            --if we come till here, we where able to obtain locks on all the toplines fectched previously
            FORALL j IN  l_tl_id_tbl.first..l_tl_id_tbl.last
                update okc_k_lines_b
                    set cancelled_amount =l_sl_amt_tbl(j)
                    where id=l_tl_id_tbl(j);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_line', 'cancelled amounts updated');
            END IF;

        END LOOP; --of bulk fetch loop
        CLOSE c_k_toplines_cancelled;
        l_tl_id_tbl.delete;
        l_tl_amt_tbl.delete;
        l_sl_amt_tbl.delete;

        -- update cancelled amount in header
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_header', 'to update header cancelled amount not equal to sum of toplines.');
        END IF;

        OPEN c_k_hdr_cancelled(p_chr_id);
        FETCH c_k_hdr_cancelled INTO l_header_cancelled,l_topline_cancelled;
        CLOSE c_k_hdr_cancelled;

        --update the header cancelled amount only if required
        IF l_header_cancelled <> l_topline_cancelled THEN

            --before updating the header amount, first try to obtain a lock on the header
            --if the lock fails, another user is holding the lock, exit with appropriate
            --error message. If the lock succeeds, update the header amount
            BEGIN

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.lock_hdr', 'checking lock for header id='||p_chr_id);
                END IF;

                OPEN c_lock_hdr(p_chr_id);
                FETCH c_lock_hdr INTO l_dummy;
                CLOSE c_lock_hdr;

                update okc_k_headers_all_b
                set cancelled_amount = l_topline_cancelled
                where id=p_chr_id;

            EXCEPTION
                WHEN E_RESOURCE_BUSY THEN
                    IF c_lock_hdr%isopen THEN
                        CLOSE c_lock_hdr;
                    END IF;
                    --set the error message on the error stack to inform the user
                    FND_MESSAGE.set_name(G_APP_NAME_OKS, 'OKS_HEADER_LOCKED');
                    FND_MESSAGE.set_token('CONTRACT_NUMBER', l_k_num);

                    IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.message(FND_LOG.level_error, l_mod_name || '.lock_header_fail', FALSE);
                    END IF;
                    FND_MSG_PUB.ADD;

                    RAISE FND_API.g_exc_error;

            END; --of anonymous block checking header lock

        END IF; --of (l_header_cancelled <> l_topline_cancelled) THEN

	    IF FND_API.to_boolean(p_commit) THEN
		    COMMIT;
	    END IF;

        --exit
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            ROLLBACK TO check_update_amounts_PVT;
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );
            IF (c_k_toplines%isopen) THEN
                CLOSE c_k_toplines;
            END IF;
            IF (c_lock_tl%isopen) THEN
                CLOSE c_lock_tl;
            END IF;
            IF (c_line_name%isopen) THEN
                CLOSE c_line_name;
            END IF;
            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            IF (c_lock_hdr%isopen) THEN
                CLOSE c_lock_hdr;
            END IF;


        WHEN FND_API.g_exc_unexpected_error THEN
            ROLLBACK TO check_update_amounts_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );
            IF (c_k_toplines%isopen) THEN
                CLOSE c_k_toplines;
            END IF;
            IF (c_lock_tl%isopen) THEN
                CLOSE c_lock_tl;
            END IF;
            IF (c_line_name%isopen) THEN
                CLOSE c_line_name;
            END IF;
            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            IF (c_lock_hdr%isopen) THEN
                CLOSE c_lock_hdr;
            END IF;

        WHEN OTHERS THEN
            ROLLBACK TO check_update_amounts_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );
            IF (c_k_toplines%isopen) THEN
                CLOSE c_k_toplines;
            END IF;
            IF (c_lock_tl%isopen) THEN
                CLOSE c_lock_tl;
            END IF;
            IF (c_line_name%isopen) THEN
                CLOSE c_line_name;
            END IF;
            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            IF (c_lock_hdr%isopen) THEN
                CLOSE c_lock_hdr;
            END IF;

    END CHECK_UPDATE_AMOUNTS;


    FUNCTION get_net_reading(p_counter_id NUMBER)
    RETURN  NUMBER IS

     CURSOR c1 IS
     SELECT counter_value_id
     FROM   CSI_COUNTER_READINGS
     WHERE  counter_id = p_counter_id
     AND    value_timestamp in
        (select max(value_timestamp) from CSI_COUNTER_READINGS
         where counter_id = p_counter_id
         and disabled_flag='N');

     l_counter_value_id NUMBER;

     BEGIN

      OPEN c1;
      FETCH c1 INTO l_counter_value_id;
      CLOSE c1;

      RETURN l_counter_value_id;

     END get_net_reading;


END OKS_AUTH_UTIL_PVT;

/
