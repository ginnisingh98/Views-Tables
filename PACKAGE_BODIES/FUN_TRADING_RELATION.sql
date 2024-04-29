--------------------------------------------------------
--  DDL for Package Body FUN_TRADING_RELATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_TRADING_RELATION" AS
/* $Header: funtraderelb.pls 120.12 2006/05/15 14:04:49 ashikuma noship $ */

  l_debug_level CONSTANT NUMBER  :=      FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level CONSTANT NUMBER  :=      FND_LOG.LEVEL_STATEMENT;
  l_proc_level  CONSTANT NUMBER  :=      FND_LOG.LEVEL_PROCEDURE;
  l_event_level CONSTANT NUMBER  :=      FND_LOG.LEVEL_EVENT;
  l_excep_level CONSTANT NUMBER  :=      FND_LOG.LEVEL_EXCEPTION;
  l_error_level CONSTANT NUMBER  :=      FND_LOG.LEVEL_ERROR;
  l_unexp_level CONSTANT NUMBER  :=      FND_LOG.LEVEL_UNEXPECTED;
  l_path        CONSTANT VARCHAR2(50)  :=  'FUN.PLSQL.funtraderelb.FUN_TRADING_RELATION_PKG.';


/* Internal routine.. Will be called only by get_customer and get_supplier, to validate the source*/
FUNCTION validate_source (p_source IN VARCHAR2)
RETURN boolean IS
l_RETURN NUMBER;
p_path CONSTANT VARCHAR2(50) :=  'VALIDATE_SOURCE';
CURSOR c_source (p_source VARCHAR2) IS
SELECT 1
        FROM FND_LOOKUP_VALUES
        WHERE lookup_type = 'FUN_TRADE_REL_SOURCE'
        AND   language    = USERENV('LANG')
        AND lookup_code = p_source;
BEGIN
        OPEN c_source (p_source);
        FETCH c_source INto l_RETURN;
        IF c_source%NOTFOUND THEN
            RETURN false ;
        else
            RETURN true ;
        END IF;
        CLOSE c_source;
EXCEPTION
WHEN others THEN
    IF (l_unexp_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_unexp_level , l_path || p_path , 'Unexpected Error4' );
    END IF;
    RETURN false;
    app_exception.raise_exception;
END validate_source; -- End of validate_source



/* Internal routine.. Will be called only by get_customer and get_supplier*/
PROCEDURE get_relation (
    p_source	 	     IN VARCHAR2,
    p_type                   IN VARCHAR2,
    p_trans_le_id            IN NUMBER ,
    p_tp_le_id		     IN NUMBER ,
    p_trans_org_id 	     IN NUMBER := NULL,
    p_tp_org_id 	     IN NUMBER := NULL,
    p_trans_organization_id IN NUMBER,
    p_tp_organization_id IN NUMBER,
    x_relation_id	     OUT NOCOPY	NUMBER,
    x_success		     OUT NOCOPY VARCHAR2,
    x_msg_data		     OUT NOCOPY VARCHAR2
    )
IS
      p_path CONSTANT VARCHAR2(50)  :=  'GET_RELATION';

      CURSOR c_cust_relation(p_source  VARCHAR2,
                        p_trans_le_id NUMBER,
                        p_tp_le_id NUMBER,
                        p_trans_org_id NUMBER,
                        p_tp_org_id NUMBER,
                        p_trans_organization_id NUMBER,
                        p_tp_organization_id NUMBER )  IS
      SELECT rel.relation_id
      FROM FUN_TRADE_RELATIONS rel,
           fun_customer_maps   cust
      WHERE Nvl(rel.source,'INTERCOMPANY') = p_source
      AND rel.transaction_le_id = p_trans_le_id
      AND rel.tp_le_id = p_tp_le_id
      AND nvl(rel.transaction_org_id , -1) = nvl(p_trans_org_id, -1)
      AND nvl(rel.tp_org_id,-1) = nvl(p_tp_org_id,-1)
      AND rel.transaction_organization_id=p_trans_organization_id
      AND rel.tp_organization_id=p_tp_organization_id
      AND rel.relation_id = cust.relation_id;

      CURSOR c_supp_relation(p_source  VARCHAR2,
                        p_trans_le_id NUMBER,
                        p_tp_le_id NUMBER,
                        p_trans_org_id NUMBER,
                        p_tp_org_id NUMBER,
                        p_trans_organization_id NUMBER,
                        p_tp_organization_id NUMBER )  IS
      SELECT rel.relation_id
      FROM FUN_TRADE_RELATIONS rel,
           fun_supplier_maps   supp
      WHERE Nvl(rel.source,'INTERCOMPANY') = p_source
      AND rel.transaction_le_id = p_trans_le_id
      AND rel.tp_le_id = p_tp_le_id
      AND nvl(rel.transaction_org_id , -1) = nvl(p_trans_org_id, -1)
      AND nvl(rel.tp_org_id,-1) = nvl(p_tp_org_id,-1)
      AND rel.transaction_organization_id=p_trans_organization_id
      AND rel.tp_organization_id=p_tp_organization_id
      AND rel.relation_id = supp.relation_id;
BEGIN
     x_success := 'Y';

     IF p_type = 'SUPPLIER'
     THEN
         OPEN c_supp_relation (p_source,
                             p_trans_le_id,
                             p_tp_le_id,
                             p_trans_org_id ,
                             p_tp_org_id,
                             p_trans_organization_id,
                             p_tp_organization_id );
         FETCH c_supp_relation INTO x_relation_id;
         CLOSE c_supp_relation;
     ELSIF p_type = 'CUSTOMER'
     THEN
         OPEN c_cust_relation (p_source,
                             p_trans_le_id,
                             p_tp_le_id,
                             p_trans_org_id ,
                             p_tp_org_id,
                             p_trans_organization_id,
                             p_tp_organization_id );
         FETCH c_cust_relation INTO x_relation_id;
         CLOSE c_cust_relation;

     END IF;
EXCEPTION
       WHEN others THEN
            x_success := 'N';
            x_msg_data := 'Unexpected error1' || SQLERRM;
            IF (l_excep_level >=  l_debug_level ) THEN
                    FND_LOG.STRING  (l_excep_level , l_path || p_path , x_msg_data );
            END IF;
            app_exception.raise_exception;
END get_relation;

/* GET_CUSTOMER RETURNs the customer information, relationship should be derived
on the hierarchial business logic using get_relation routine. */

FUNCTION get_customer (
    p_source	 	    IN VARCHAR2,
    p_trans_le_id 		IN NUMBER ,
    p_tp_le_id		    IN NUMBER ,
    p_trans_org_id 		IN NUMBER := NULL,
    p_tp_org_id 		IN NUMBER := NULL,
    p_trans_organization_id IN NUMBER,
    p_tp_organization_id IN NUMBER,
    x_msg_data		    OUT NOCOPY VARCHAR2,
    x_cust_acct_id		OUT NOCOPY NUMBER,
    x_cust_acct_site_id		OUT NOCOPY NUMBER,
    x_site_use_id 		OUT NOCOPY NUMBER
) RETURN boolean
IS
      p_path CONSTANT VARCHAR2(50) :=  'GET_CUSTOMER';
      l_success VARCHAR2(1);
      l_msg_data VARCHAR2(1000);
      x_relation_id number;
      x_customer_party_id number;

     CURSOR c_cust_acct(x_relation_id  NUMBER ) IS
     SELECT mp.cust_account_id ,
            mp.site_use_id,
            site.cust_acct_site_id
     FROM fun_customer_maps mp,
          hz_cust_acct_sites_all site,
          hz_cust_site_uses_all  use
     WHERE relation_id = x_relation_id
     AND   site.cust_account_id   = mp.cust_account_id
     AND   site.cust_acct_site_id = use.cust_acct_site_id
     AND   use.site_use_id        = mp.site_use_id
     AND   use.status = 'A'
     AND   site.status = 'A';

     CURSOR c_site_use (p_trans_org_id NUMBER, x_cust_acct_id NUMBER) IS
     SELECT site_use_id , cust_acct_site_id
     FROM hz_cust_site_uses_all
     WHERE cust_acct_site_id
     IN ( SELECT cust_acct_site_id FROM hz_cust_acct_sites_all WHERE cust_account_id = x_cust_acct_id AND org_id = p_trans_org_id)
     AND org_id = p_trans_org_id
     AND site_use_code = 'BILL_TO'
     AND status = 'A'
     AND primary_flag = 'Y';

     CURSOR c_cust_party (x_cust_acct_id NUMBER ) IS
     SELECT party_id
     FROM hz_cust_accounts_all
     WHERE cust_account_id = x_cust_acct_id
     AND   status = 'A';

BEGIN
    IF (p_trans_le_id IS NULL or p_tp_le_id IS NULL or p_source IS NULL) THEN
           x_msg_data := 'Transacting Legal Entity,Trading Partner Legal Entity AND Source are mandatory parameters.' ;
           IF (l_error_level >=  l_debug_level ) THEN
                  FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
            END IF;
            RETURN false;
    END IF;

    IF NOT validate_source (p_source) THEN
            x_msg_data := 'Source is NOT a valid parameter' ;
           IF (l_error_level >=  l_debug_level ) THEN
                  FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
            END IF;
            RETURN false;
    END IF;

    IF ( p_trans_org_id IS NOT NULL ) THEN
        IF (p_tp_org_id IS NOT NULL ) THEN
            GET_RELATION (p_source, 'CUSTOMER', p_trans_le_id , p_tp_le_id, p_trans_org_id, p_tp_org_id, p_trans_organization_id, p_tp_organization_id, x_relation_id, l_success, l_msg_data	);
        END IF;
        IF (x_relation_id IS NULL ) THEN
             GET_RELATION (p_source, 'CUSTOMER', p_trans_le_id , p_tp_le_id, p_trans_org_id, NULL, p_trans_organization_id, p_tp_organization_id, x_relation_id, l_success,  l_msg_data	);
        END IF;
        IF (x_relation_id IS NULL ) THEN
            GET_RELATION (p_source, 'CUSTOMER', p_trans_le_id , p_tp_le_id, NULL, NULL, p_trans_organization_id, p_tp_organization_id, x_relation_id, l_success, l_msg_data	);
        END IF;
        IF (x_relation_id IS NULL ) THEN
            IF (p_tp_org_id IS NOT NULL ) THEN
                GET_RELATION ('ALL', 'CUSTOMER', p_trans_le_id , p_tp_le_id, p_trans_org_id, p_tp_org_id, p_trans_organization_id, p_tp_organization_id, x_relation_id, l_success, l_msg_data	);
            END IF;
            IF (x_relation_id IS NULL ) THEN
                GET_RELATION ('ALL', 'CUSTOMER', p_trans_le_id , p_tp_le_id, p_trans_org_id, NULL, p_trans_organization_id, p_tp_organization_id, x_relation_id, l_success,  l_msg_data	);
            END IF;
            IF (x_relation_id IS NULL ) THEN
                GET_RELATION ('ALL', 'CUSTOMER', p_trans_le_id , p_tp_le_id, NULL, NULL, p_trans_organization_id, p_tp_organization_id, x_relation_id, l_success, l_msg_data	);
            END IF;
        END IF;
        IF (x_relation_id IS NULL ) THEN
                  x_msg_data := 'Relation does not exist for the given pair of Transacting and Trading Partners';
                  IF (l_error_level >=  l_debug_level ) THEN
                        FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
                  END IF;
            RETURN false;
        else
            OPEN c_cust_acct (x_relation_id);
            FETCH c_cust_acct INto x_cust_acct_id,
                                   x_site_use_id,
                                   x_cust_acct_site_id;
            IF c_cust_acct%NOTFOUND THEN
                x_msg_data := 'Customer mapping is not present for the relation id ' || x_relation_id;
                IF (l_error_level >=  l_debug_level ) THEN
                        FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
                END IF;
                CLOSE c_cust_acct;
                RETURN FALSE;
            END IF;
            CLOSE c_cust_acct;

            IF (x_cust_acct_id IS NOT NULL) THEN
              OPEN c_cust_party (x_cust_acct_id );
              FETCH c_cust_party INTO x_customer_party_id ;
              CLOSE c_cust_party;
              IF x_customer_party_id IS  NULL THEN
                    x_msg_data := 'The Customer defined in the  relation ' || x_relation_id || ' is inactive or does not have a customer party id ';
                    IF (l_error_level >=  l_debug_level ) THEN
                       FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
                     END IF;
                     RETURN false;
             END IF;

             IF (x_site_use_id IS NULL) THEN
                OPEN c_site_use (p_trans_org_id , x_cust_acct_id);
                FETCH c_site_use INto x_site_use_id, x_cust_acct_site_id;
                CLOSE c_site_use;
              END IF;

              IF x_site_use_id IS NULL THEN
                    x_msg_data := 'Site is not defined for the customer mapping on the relation id '|| x_relation_id;
                    IF (l_error_level >=  l_debug_level ) THEN
                            FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
                    END IF;
                    RETURN false;
              END IF;
                RETURN true;
             else
                x_msg_data := 'The Customer defined in the  relation ' || x_relation_id || ' does not have a customer account' ;
                IF (l_error_level >=  l_debug_level ) THEN
                       FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
                 END IF;
                 RETURN false;
             END IF;
        END IF; /* Successfully got all data*/
else
        /* only LE info*/
        x_msg_data := 'Transacting Operating Unit is not passed, so unable to get Customer details ';
        IF (l_error_level >=  l_debug_level ) THEN
                FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
        END IF;
        RETURN false;
END IF;
EXCEPTION
WHEN others THEN
    x_msg_data := 'Unexpected Error2';
    IF (l_unexp_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_unexp_level , l_path || p_path , x_msg_data );
    END IF;
    RETURN false;
    app_exception.raise_exception;
END get_customer;

/* GET SUPPLIER RETURNs the supplier information, relationship should be derived
on the hierarchial business logic using get_relation routine. */
-- Added p_trx_date to check if supplier is active - Bug 5176225
FUNCTION get_supplier (
    p_source	 	    IN VARCHAR2,
    p_trans_le_id       IN NUMBER ,
    p_tp_le_id		    IN NUMBER ,
    p_trans_org_id      IN NUMBER := NULL,
    p_tp_org_id 		IN NUMBER := NULL,
    p_trans_organization_id IN NUMBER,
    p_tp_organization_id IN NUMBER,
    p_trx_date              IN  DATE,
    x_msg_data		    OUT NOCOPY VARCHAR2,
    x_vendor_id		    OUT NOCOPY NUMBER,
    x_pay_site_id 		OUT NOCOPY NUMBER
    ) RETURN boolean
IS
    p_path CONSTANT VARCHAR2(50)  :=  'GET_SUPPLIER';
    l_success VARCHAR2(1);
    l_msg_data VARCHAR2(1000);
    x_relation_id number;

    CURSOR c_vendor_info (x_relation_id NUMBER,
                          p_trx_date DATE)  IS
    SELECT rel.vendor_id,  rel.vendor_site_id
    FROM fun_supplier_maps rel,
         ap_suppliers supp,
          ap_supplier_sites_all site
    WHERE relation_id = x_relation_id
    AND   supp.vendor_id = rel.vendor_id
    AND   site.vendor_site_id = rel.vendor_site_id
    AND   supp.vendor_id = site.vendor_id
    AND   p_trx_date BETWEEN Nvl(TRUNC(supp.start_date_active), p_trx_date) AND Nvl(TRUNC(supp.end_date_active), p_trx_date)
    AND   Nvl(TRUNC(site.inactive_date), p_trx_date) >= p_trx_date;


    CURSOR c_vendor_site_info (x_vendor_id NUMBER, p_trans_org_id NUMBER )  IS
    SELECT vendor_site_id
    FROM po_vendor_sites_all
    WHERE vendor_id = x_vendor_id AND (pay_site_flag = 'Y'  or  primary_pay_site_flag = 'Y' )
    AND org_id = p_trans_org_id ;

BEGIN
     IF (p_trans_le_id IS NULL or p_tp_le_id IS NULL or p_source IS NULL) THEN
           x_msg_data := 'Transacting Legal Entity,Trading Partner Legal Entity and Source are mandatory parameters.' ;
           IF (l_error_level >=  l_debug_level ) THEN
                  FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
            END IF;
            RETURN false;
    END IF;

    IF NOT validate_source (p_source) THEN
            x_msg_data := 'Source is NOT a valid parameter' ;
           IF (l_error_level >=  l_debug_level ) THEN
                  FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
            END IF;
            RETURN false;
    END IF;



    IF (p_trans_org_id IS NOT NULL) THEN
        IF (p_tp_org_id IS NOT NULL) THEN
            GET_RELATION (p_source, 'SUPPLIER', p_trans_le_id , p_tp_le_id, p_trans_org_id, p_tp_org_id, p_trans_organization_id, p_tp_organization_id, x_relation_id, l_success,  l_msg_data	);
        END IF;
        IF (x_relation_id IS NULL) THEN
            GET_RELATION (p_source, 'SUPPLIER', p_trans_le_id , p_tp_le_id, p_trans_org_id, NULL, p_trans_organization_id, p_tp_organization_id, x_relation_id, l_success,  l_msg_data	);
        END IF;
        IF (x_relation_id IS NULL)  THEN
            GET_RELATION (p_source, 'SUPPLIER', p_trans_le_id , p_tp_le_id, NULL, NULL, p_trans_organization_id, p_tp_organization_id, x_relation_id, l_success, l_msg_data	);
        END IF;
        IF (x_relation_id IS NULL)  THEN
            IF (p_tp_org_id IS NOT NULL) THEN
                GET_RELATION ('ALL', 'SUPPLIER', p_trans_le_id , p_tp_le_id, p_trans_org_id, p_tp_org_id, p_trans_organization_id, p_tp_organization_id, x_relation_id, l_success,  l_msg_data	);
            END IF;
            IF (x_relation_id IS NULL)  THEN
                GET_RELATION ('ALL', 'SUPPLIER', p_trans_le_id , p_tp_le_id, p_trans_org_id, NULL, p_trans_organization_id, p_tp_organization_id, x_relation_id, l_success, l_msg_data	);
            END IF;
            IF (x_relation_id IS NULL)  THEN
                GET_RELATION ('ALL', 'SUPPLIER', p_trans_le_id , p_tp_le_id, NULL, NULL, p_trans_organization_id, p_tp_organization_id, x_relation_id, l_success, l_msg_data	);
            END IF;
        END IF;
        IF (x_relation_id IS NULL)  THEN
                  x_msg_data := 'Relation does not exist for the given pair of Transacting AND Trading Partners';
                  IF (l_error_level >=  l_debug_level ) THEN
                       FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
                  END IF;
            RETURN false;
        else
            OPEN c_vendor_info ( x_relation_id, p_trx_date);
            FETCH c_vendor_info INto x_vendor_id, x_pay_site_id;
            IF c_vendor_info%NOTFOUND THEN
                x_msg_data := 'Valid Supplier Mapping is not present for the relation id ' || x_relation_id;
                IF (l_error_level >=  l_debug_level ) THEN
                       FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
                END IF;
                CLOSE c_vendor_info;
                RETURN FALSE;
            END IF;
            CLOSE c_vendor_info;
            IF x_vendor_id IS NOT NULL THEN

                IF ( x_pay_site_id IS NULL) THEN
                     OPEN c_vendor_site_info (x_vendor_id , p_trans_org_id);
                     FETCH c_vendor_site_info INto x_pay_site_id;
                     CLOSE c_vendor_site_info;
                     IF x_pay_site_id IS NULL THEN
                        x_msg_data := 'A valid Pay Site is not available for the Supplier';
                        IF (l_error_level >=  l_debug_level ) THEN
                           FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
                        END IF;
                        RETURN false;
                    END IF;
                END IF;
            else
                x_msg_data := 'Supplier info is not available';
                IF (l_error_level >=  l_debug_level ) THEN
                       FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
                END IF;
                RETURN false;
            END IF;
        END IF;
        RETURN true;
    else /*Only LE info available*/
         x_msg_data := 'Transacting Operating Unit is not passed, so unable to get Supplier details ';
         IF (l_error_level >=  l_debug_level ) THEN
              FND_LOG.STRING  (l_error_level , l_path || p_path , x_msg_data );
         END IF;
         RETURN false;
    END IF;
EXCEPTION
WHEN others THEN
    x_msg_data := 'Unexpected Error3';
     IF (l_unexp_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (l_unexp_level , l_path || p_path , x_msg_data );
    END IF;
    RETURN false;
    app_exception.raise_exception;
END get_supplier;


END FUN_TRADING_RELATION;


/
