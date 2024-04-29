--------------------------------------------------------
--  DDL for Package Body HZ_CUSTOMER_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUSTOMER_INT" AS
/*$Header: ARHCUSIB.pls 120.21.12010000.2 2008/10/17 13:02:45 idali ship $*/

-- The following varibles and types are added for bug 2460837.

g_created_by                       NUMBER;
g_last_update_login                NUMBER;
g_last_updated_by                  NUMBER;
g_request_id                       NUMBER;
g_program_application_id           NUMBER;
g_program_id                       NUMBER;

TYPE t_varchar500 IS TABLE OF VARCHAR2(400);
TYPE t_id IS TABLE OF NUMBER(15);
TYPE t_flag IS TABLE OF VARCHAR2(1);

  FUNCTION get_cust_account_id (p_orig_system_customer_ref IN VARCHAR2)
    RETURN NUMBER IS
    l_cust_account_id NUMBER;
    CURSOR c1 IS
      SELECT cust_account_id
      FROM   hz_cust_accounts
      WHERE  orig_system_reference = p_orig_system_customer_ref;
  BEGIN
    OPEN c1;
    FETCH c1 INTO l_cust_account_id;
    CLOSE c1;
    RETURN l_cust_account_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END get_cust_account_id;

  /* bug 4454799 - added argument for org_id below. */
  FUNCTION get_cust_acct_site_id (p_orig_system_address_ref IN VARCHAR2,p_org_id IN NUMBER)
    RETURN NUMBER IS
    l_cust_acct_site_id NUMBER;
    CURSOR c2 IS
      SELECT cust_acct_site_id
      FROM   hz_cust_acct_sites_all  -- bug 4454799
      WHERE  orig_system_reference = p_orig_system_address_ref
	AND  org_id = p_org_id; -- bug 4454799
  BEGIN
    OPEN c2;
    FETCH c2 into l_cust_acct_site_id;
    CLOSE c2;
    RETURN l_cust_acct_site_id;
  EXCEPTION
    WHEN NO_DATA_FOUND  THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END get_cust_acct_site_id;

  FUNCTION get_cust_account_role_id (p_orig_system_contact_ref IN VARCHAR2)
    RETURN NUMBER IS
    l_cust_account_role_id NUMBER;
    CURSOR c3 IS
      SELECT cust_account_role_id
      FROM   hz_cust_account_roles
      WHERE  orig_system_reference = p_orig_system_contact_ref;
  BEGIN
    OPEN c3;
    FETCH c3 INTO l_cust_account_role_id;
    CLOSE c3;
    RETURN l_cust_account_role_id;
  EXCEPTION
    WHEN NO_DATA_FOUND  THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END get_cust_account_role_id;

  FUNCTION get_prel_party_id (p_orig_system_contact_ref IN VARCHAR2)
    RETURN NUMBER IS
    l_prel_party_id NUMBER;
    CURSOR c4 IS
      SELECT party_id
      FROM   hz_cust_account_roles
      WHERE  orig_system_reference = p_orig_system_contact_ref;
  BEGIN
    OPEN c4;
    FETCH c4 INTO l_prel_party_id;
    CLOSE c4;
    RETURN l_prel_party_id;
  EXCEPTION
    WHEN no_data_found  THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END get_prel_party_id;

/*  Bug Fix 2596570  */
 FUNCTION get_contact_name(p_orig_system_contact_ref IN VARCHAR2,
                            p_orig_system_customer_ref IN VARCHAR2
                          )
  RETURN VARCHAR2 IS
         l_party_name VARCHAR2(360);
         l_cont_name  VARCHAR2(360);
         l_org_name   VARCHAR2(360);
         l_party_number VARCHAR2(30);

 CURSOR party_num IS
 SELECT party_number
 FROM hz_parties
 WHERE orig_system_reference = 'PREL-'||p_orig_system_contact_ref;

 CURSOR cont_name IS
 SELECT party_name
 FROM hz_parties
 WHERE orig_system_reference = p_orig_system_contact_ref;

 CURSOR org_name IS
 SELECT party_name
 FROM hz_parties
 WHERE party_id = (select party_id
                   from hz_cust_accounts
                   where orig_system_reference = p_orig_system_customer_ref);

 BEGIN
    OPEN cont_name;
    FETCH cont_name INTO l_cont_name;
    CLOSE cont_name;

    OPEN org_name;
    FETCH org_name INTO l_org_name;
    CLOSE org_name;

    OPEN party_num;
    FETCH party_num INTO l_party_number;
    CLOSE party_num;

    l_party_name := substrb(l_cont_name || '-'||l_org_name || '-' ||l_party_number,1,360 );

    RETURN l_party_name;

 EXCEPTION
    WHEN no_data_found  THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
 END get_contact_name;


/*  Bug Fix 2596570 */
 PROCEDURE update_party_prel_name(p_party_id IN NUMBER )
 IS

   l_party_name VARCHAR2(360);

 CURSOR c_party_rels IS
      SELECT r.party_id, r.object_id, o.party_name, r.subject_id, s.party_name,
             rel.party_number, rel.party_name
      FROM hz_relationships r, hz_parties s, hz_parties o, hz_parties rel
      WHERE (r.subject_id = p_party_id OR r.object_id = p_party_id)
      AND r.party_id IS NOT NULL
      AND r.subject_table_name = 'HZ_PARTIES'
      AND r.object_table_name = 'HZ_PARTIES'
      AND r.directional_flag = 'F'
      AND r.subject_id = s.party_id
      AND r.object_id = o.party_id
      AND r.party_id = rel.party_id;

    TYPE IDlist IS TABLE OF NUMBER(15);
    TYPE NAMElist IS TABLE OF HZ_PARTIES.PARTY_NAME%TYPE;
    TYPE NUMBERlist IS TABLE OF HZ_PARTIES.PARTY_NUMBER%TYPE;

    i_party_id                         IDlist;
    i_object_id                        IDlist;
    i_object_name                      NAMElist;
    i_subject_id                       IDlist;
    i_subject_name                     NAMElist;
    i_party_number                     NUMBERlist;
    i_party_name                       NAMElist;
    l_dummy                            VARCHAR2(1);

  BEGIN

  OPEN c_party_rels;
    FETCH c_party_rels BULK COLLECT INTO
      i_party_id,i_object_id,i_object_name,i_subject_id,i_subject_name,
      i_party_number, i_party_name;
    CLOSE c_party_rels;

    FOR i IN 1..i_party_id.COUNT LOOP
      l_party_name := SUBSTRB(i_subject_name(i) || '-' ||
                             i_object_name(i)  || '-' ||
                             i_party_number(i), 1, 360);

      IF l_party_name <> i_party_name(i) THEN

        UPDATE hz_parties
        SET party_name = l_party_name
        WHERE party_id = i_party_id(i);

      END IF;

      --recursively update those party relationships' name whose
      --subject or object party might also be a party relationship.

      update_party_prel_name(i_party_id(i));

    END LOOP;

  end update_party_prel_name;

  /* bug 4454799 - added argument for org_id below. */
FUNCTION get_party_site_id (p_orig_system_address_ref IN VARCHAR2,p_org_id IN NUMBER)
    RETURN NUMBER IS
    l_party_site_id NUMBER;
    CURSOR c5 IS
      SELECT party_site_id
      FROM hz_cust_acct_sites_all -- bug 4454799
      WHERE orig_system_reference = p_orig_system_address_ref
      AND org_id = p_org_id; -- bug 4454799
  BEGIN
    OPEN c5;
    FETCH c5 INTO l_party_site_id;
    CLOSE c5;
    RETURN l_party_site_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN null;
    WHEN OTHERS THEN
      RAISE;
  END get_party_site_id;

  FUNCTION get_party_id(p_orig_system_customer_ref IN VARCHAR2)
    RETURN NUMBER IS
    l_party_id NUMBER;
    CURSOR c6 IS
      SELECT party_id
      FROM   hz_cust_accounts
      WHERE  orig_system_reference = p_orig_system_customer_ref;
  BEGIN
    OPEN c6;
    FETCH c6 into l_party_id;
    CLOSE c6;
    RETURN l_party_id;
  EXCEPTION
    WHEN NO_DATA_FOUND  THEN
      RETURN null;
    WHEN OTHERS THEN
      RAISE;
  END get_party_id;

  FUNCTION validate_contact_ref (p_orig_system_contact_ref IN VARCHAR2)
    RETURN VARCHAR2 IS
    l_return_code VARCHAR2(5) := '';
    l_party_id NUMBER;
    p_customer_ref VARCHAR2(240);

    CURSOR c7 IS
      SELECT party_id
      FROM   hz_parties
      WHERE  orig_system_reference = p_orig_system_contact_ref;

    CURSOR c2 IS
      SELECT orig_system_customer_ref
      FROM   ra_customers_interface;
  BEGIN
    OPEN c7;
    FETCH c7 INTO l_party_id;
    CLOSE c7;

    IF l_party_id IS NOT NULL THEN
      l_return_code :='G4,';
    END IF;

    -- Bug 1487004
    OPEN c2;

    LOOP
      FETCH c2 into p_customer_ref;
      EXIT WHEN c2%NOTFOUND;
      IF p_customer_ref = p_orig_system_contact_ref THEN
        l_return_code := 'G4,';
        EXIT;
      END IF;
    END LOOP;
    CLOSE c2;

    RETURN l_return_code;
  EXCEPTION
    WHEN NO_DATA_FOUND  THEN
      RETURN null;
    WHEN OTHERS THEN
      RAISE;
  END validate_contact_ref;

  FUNCTION get_language_code (p_language IN VARCHAR2) RETURN VARCHAR2 IS
    l_language_code VARCHAR2(4);
    CURSOR language_code IS
      SELECT language_code
      FROM   fnd_languages
      WHERE  nls_language = p_language;
  BEGIN
    OPEN language_code;
    FETCH language_code INTO l_language_code;
    CLOSE language_code;
    RETURN l_language_code;
  EXCEPTION
    WHEN NO_DATA_FOUND  THEN
      RETURN null;
    WHEN OTHERS THEN
      RAISE;
  END get_language_code;

  PROCEDURE validate_ccid (p_request_id NUMBER) IS
    CURSOR auto_acc IS
      SELECT  site_use_code, i.gl_id_rec, i.gl_id_rev, i.gl_id_tax,
              i.gl_id_freight, i.gl_id_clearing, i.gl_id_unbilled,
              i.gl_id_unearned, i.interface_status
      FROM    ra_customers_interface i
      WHERE   i.request_id = p_request_id
              AND nvl(i.validated_flag,'N') <> 'Y'
              AND (gl_id_rec IS NOT NULL
                   OR gl_id_rev IS NOT NULL
                   OR gl_id_tax IS NOT NULL
                   OR gl_id_freight IS NOT NULL
                   OR gl_id_clearing IS NOT NULL
                   OR gl_id_unbilled IS NOT NULL
                   OR gl_id_unearned IS NOT NULL)
      FOR UPDATE;

    CURSOR boe IS
      SELECT  i.site_use_code, i.gl_id_unpaid_rec, i.gl_id_remittance,
              i.gl_id_factor, i.interface_status
      FROM    ra_customers_interface i
      WHERE   i.request_id = p_request_id
              AND nvl(i.validated_flag,'N') <> 'Y'
              AND (gl_id_unpaid_rec IS NOT NULL
                   OR gl_id_remittance IS NOT NULL
                   OR gl_id_factor IS NOT NULL)
      FOR UPDATE;

    p_site_use_code VARCHAR2(30);
    p_gl_id_rec NUMBER;
    p_gl_id_rev NUMBER;
    p_gl_id_tax NUMBER;
    p_gl_id_freight NUMBER;
    p_gl_id_clearing NUMBER;
    p_gl_id_unbilled NUMBER;
    p_gl_id_unearned NUMBER;
    p_gl_id_unpaid_rec NUMBER;
    p_gl_id_remittance NUMBER;
    p_gl_id_factor NUMBER;
    p_interface_status VARCHAR2(240);

  BEGIN
    OPEN auto_acc;
    LOOP
      FETCH auto_acc
      INTO  p_site_use_code, p_gl_id_rec, p_gl_id_rev, p_gl_id_tax,
            p_gl_id_freight, p_gl_id_clearing, p_gl_id_unbilled,
            p_gl_id_unearned, p_interface_status;

      EXIT WHEN auto_acc%NOTFOUND;

      IF p_site_use_code <> 'BILL_TO' THEN
        p_interface_status := p_interface_status || 'm1,';
      END IF;

      IF p_gl_id_rec IS NOT NULL THEN
        IF NOT fnd_flex_keyval.validate_ccid(
                 appl_short_name  => 'SQLGL',
                 key_flex_code    => 'GL#',
                 structure_number =>  arp_global.chart_of_accounts_id,
                 combination_id   =>  p_gl_id_rec) THEN

          p_interface_status := p_interface_status || 'm2,';

        END IF;
      END IF;

      IF p_gl_id_rev IS NOT NULL THEN
        IF NOT fnd_flex_keyval.validate_ccid(
                 appl_short_name  => 'SQLGL',
                 key_flex_code    => 'GL#',
                 structure_number =>  arp_global.chart_of_accounts_id,
                 combination_id   =>  p_gl_id_rev) THEN

          p_interface_status := p_interface_status || 'm3,';

        END IF;
      END IF;

      IF p_gl_id_tax IS NOT NULL THEN
        IF NOT fnd_flex_keyval.validate_ccid(
                 appl_short_name  => 'SQLGL',
                 key_flex_code    => 'GL#',
                 structure_number =>  arp_global.chart_of_accounts_id,
                 combination_id   =>  p_gl_id_tax) THEN

          p_interface_status := p_interface_status || 'm2,';

        END IF;
      END IF;

      IF p_gl_id_freight IS NOT NULL THEN
        IF NOT fnd_flex_keyval.validate_ccid(
                 appl_short_name  => 'SQLGL',
                 key_flex_code    => 'GL#',
                 structure_number =>  arp_global.chart_of_accounts_id,
                 combination_id   =>  p_gl_id_freight) THEN

          p_interface_status := p_interface_status || 'm2,';

        END IF;
      END IF;

      IF p_gl_id_clearing IS NOT NULL THEN
        IF NOT fnd_flex_keyval.validate_ccid(
                 appl_short_name  => 'SQLGL',
                 key_flex_code    => 'GL#',
                 structure_number =>  arp_global.chart_of_accounts_id,
                 combination_id   =>  p_gl_id_clearing) THEN

          p_interface_status := p_interface_status || 'm2,';

        END IF;
      END IF;

      IF p_gl_id_unbilled IS NOT NULL THEN
        IF NOT fnd_flex_keyval.validate_ccid(
                 appl_short_name  => 'SQLGL',
                 key_flex_code    => 'GL#',
                 structure_number =>  arp_global.chart_of_accounts_id,
                 combination_id   =>  p_gl_id_unbilled) THEN

          p_interface_status := p_interface_status || 'm2,';

        END IF;
      END IF;

      IF p_gl_id_unearned IS NOT NULL THEN
        IF NOT fnd_flex_keyval.validate_ccid(
                 appl_short_name  => 'SQLGL',
                 key_flex_code    => 'GL#',
                 structure_number =>  arp_global.chart_of_accounts_id,
                 combination_id   =>  p_gl_id_unearned) THEN

          p_interface_status := p_interface_status || 'm2,';

        END IF;
      END IF;

      UPDATE ra_customers_interface_all
      SET    interface_status = p_interface_status
      WHERE  CURRENT OF auto_acc;

    END LOOP;
    CLOSE auto_acc;

    OPEN boe;
    LOOP
      FETCH boe
      INTO  p_site_use_code,p_gl_id_unpaid_rec,p_gl_id_remittance,
            p_gl_id_factor,p_interface_status;

      EXIT WHEN boe%NOTFOUND;

      IF p_site_use_code <> 'DRAWEE' THEN
        p_interface_status := p_interface_status || 'u1,';
      END IF;

      IF p_gl_id_unpaid_rec IS NOT NULL THEN
        IF NOT fnd_flex_keyval.validate_ccid(
                 appl_short_name  => 'SQLGL',
                 key_flex_code    => 'GL#',
                 structure_number =>  arp_global.chart_of_accounts_id,
                 combination_id   =>  p_gl_id_unpaid_rec) THEN

          p_interface_status := p_interface_status || 'u2,';

        END IF;
      END IF;

      IF p_gl_id_remittance IS NOT NULL THEN
        IF NOT fnd_flex_keyval.validate_ccid(
                 appl_short_name  => 'SQLGL',
                 key_flex_code    => 'GL#',
                 structure_number =>  arp_global.chart_of_accounts_id,
                 combination_id   =>  p_gl_id_remittance) THEN

          p_interface_status := p_interface_status || 'u3,';

        END IF;
      END IF;

      IF p_gl_id_factor IS NOT NULL THEN
        IF NOT fnd_flex_keyval.validate_ccid(
                 appl_short_name  => 'SQLGL',
                 key_flex_code    => 'GL#',
                 structure_number =>  arp_global.chart_of_accounts_id,
                 combination_id   =>  p_gl_id_factor) THEN

          p_interface_status := p_interface_status || 'u4,';

        END IF;
      END IF;

      UPDATE ra_customers_interface_all
      SET    interface_status = p_interface_status
      WHERE  CURRENT OF boe;
    END LOOP;
    CLOSE boe;
  END validate_ccid;

  FUNCTION validate_ref_party (p_orig_system_customer_ref IN VARCHAR2,
                               p_insert_update_flag IN VARCHAR2)
    RETURN VARCHAR2 IS
    l_return_code VARCHAR2(5) := 'A3,';
    l_party_id NUMBER;
    CURSOR c7 IS
      SELECT party_id
      FROM   hz_parties
      WHERE  orig_system_reference = p_orig_system_customer_ref;
  BEGIN
    IF p_insert_update_flag = 'I' THEN
      OPEN c7;
      FETCH c7 INTO l_party_id;
      CLOSE c7;
      IF l_party_id IS NOT NULL THEN
        RETURN l_return_code;
      ELSE
        RETURN null;
      END IF;
    ELSE
      NULL;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND  THEN
      RETURN null;
    WHEN OTHERS THEN
      RAISE;
  END validate_ref_party;


  FUNCTION get_cust_party_id (p_orig_system_customer_ref IN VARCHAR2,
                              p_request_id IN NUMBER)
    RETURN NUMBER IS
    l_party_id NUMBER;

    CURSOR c8 IS
      SELECT party_id
      FROM   hz_parties
      WHERE  orig_system_reference = p_orig_system_customer_ref
      AND    party_id              = p_request_id /* Bug Fix : 5214454 */
         --  AND request_id        = p_request_id;  /* Bug Fix : 1891773 */
             AND rownum            = 1;
  BEGIN
    OPEN c8;
    FETCH c8 INTO l_party_id;
    CLOSE c8;
    RETURN l_party_id;

  EXCEPTION
    WHEN NO_DATA_FOUND  THEN
      RETURN null;
    WHEN OTHERS THEN
      RAISE;
  END get_cust_party_id;

  FUNCTION get_account_party_id (p_orig_system_customer_ref IN VARCHAR2,
				 p_person_flag  IN VARCHAR2 DEFAULT 'N',
				 p_ref_flag   IN VARCHAR2 DEFAULT 'C')
    RETURN NUMBER IS
    l_party_id NUMBER;
    l_party_type VARCHAR2(30) ;
-- For orig_system_party_ref which is having an account
    CURSOR party_ref_cur IS
      SELECT party_id
      FROM   hz_parties party
      WHERE  party.orig_system_reference = p_orig_system_customer_ref
      AND    party.PARTY_TYPE = decode(p_person_flag, 'Y', 'PERSON','ORGANIZATION')
      AND	 exists (select 'X' from hz_cust_accounts where  party_id = party.party_id)
      AND    rownum  = 1;
--For orig_system_customer_ref
    CURSOR cust_ref_cur IS
      SELECT party_id
      FROM   hz_cust_accounts
      WHERE  orig_system_reference = p_orig_system_customer_ref;
--For any orig_system_party_ref
    CURSOR any_party_ref_cur IS
      SELECT party_id
      FROM   hz_parties
      WHERE  orig_system_reference = p_orig_system_customer_ref
      AND    PARTY_TYPE = decode(p_person_flag, 'Y', 'PERSON','ORGANIZATION')
      AND    status  in ('A','I')
      AND    rownum  = 1;

  BEGIN
  IF p_ref_flag ='P' THEN    -- For orig_system_party_ref having an account
    OPEN party_ref_cur;
    FETCH party_ref_cur INTO l_party_id;
    CLOSE party_ref_cur;
    RETURN l_party_id;
  ELSIF p_ref_flag ='A' THEN --For any orig_system_party_ref
    OPEN any_party_ref_cur;
    FETCH any_party_ref_cur INTO l_party_id;
    CLOSE any_party_ref_cur;
    RETURN l_party_id;
  ELSE   -- For orig_system_customer_ref
    OPEN cust_ref_cur;
    FETCH cust_ref_cur INTO l_party_id;
    CLOSE cust_ref_cur;
    RETURN l_party_id;
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND  THEN
      RETURN null;
    WHEN OTHERS THEN
      RAISE;
  END get_account_party_id;

  FUNCTION get_subject_id (p_orig_system_contact_ref IN VARCHAR2,
                           p_request_id IN NUMBER)
    RETURN NUMBER IS
    l_party_id      NUMBER;

    -- bug 2098243 - fixed to use a cursor instead of a direct select.
    CURSOR c9 IS
      SELECT c.party_id
      FROM   hz_parties c
      WHERE  c.orig_system_reference = p_orig_system_contact_ref
             AND c.request_id        = p_request_id
             AND NOT EXISTS
               (SELECT 'X'
                FROM   hz_cust_accounts y
                WHERE  y.orig_system_reference = p_orig_system_contact_ref
                       AND y.party_id = c.party_id);
  BEGIN
    OPEN c9;
    FETCH c9 INTO l_party_id;
    CLOSE c9;
    RETURN l_party_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END get_subject_id;


  FUNCTION get_prel_party_id (p_orig_system_contact_ref IN VARCHAR2,
                              p_request_id IN NUMBER)
    RETURN NUMBER IS
    l_party_id NUMBER;
    CURSOR c IS
      SELECT rel.party_id
      FROM   hz_relationships rel,
             hz_org_contacts  cont
      WHERE  cont.request_id    = p_request_id
             AND cont.orig_system_reference = p_orig_system_contact_ref
             AND cont.party_relationship_id = rel.relationship_id
             AND rel.subject_table_name = 'HZ_PARTIES'
             AND rel.object_table_name = 'HZ_PARTIES';
      /*     AND rel.directional_flag = 'F';    */   /* Bug No : 2359461 */
  BEGIN
    OPEN c;
    FETCH c INTO l_party_id;
    CLOSE c;

    RETURN l_party_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END get_prel_party_id;

  FUNCTION get_prel_id (p_orig_system_contact_ref IN VARCHAR2,
                        p_request_id IN NUMBER)
    RETURN NUMBER IS
    l_prel_id NUMBER;
    CURSOR c is
      SELECT rel.relationship_id
      FROM   hz_relationships  rel,
             hz_org_contacts         cont
      WHERE  cont.request_id = p_request_id
             AND cont.orig_system_reference = p_orig_system_contact_ref
             AND cont.party_relationship_id = rel.relationship_id
             AND rel.subject_table_name = 'HZ_PARTIES'
             AND rel.object_table_name = 'HZ_PARTIES';
/*           AND rel.directional_flag = 'F';  */  /* Bug No : 2359461 */
  BEGIN
    OPEN c;
    FETCH c INTO l_prel_id;
    CLOSE c;

    RETURN  l_prel_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END get_prel_id;

 /* bug 4454799 - added argument for org_id below. */
  FUNCTION val_bill_to_orig_address_ref(p_orig_system_customer_ref IN VARCHAR2,
                                        p_orig_system_address_ref IN VARCHAR2,
                                        p_bill_to_orig_address_ref IN VARCHAR2,
                                        p_orig_system_parent_ref IN VARCHAR2,
	                                p_org_id IN NUMBER,
                                        req_id IN NUMBER) RETURN VARCHAR2 is
    err_msg   VARCHAR2(3) := 'e3,';
    l_dummy   VARCHAR2(3);

    --Bug 1829164
    --Rewrote the code using CURSORS to take care of the following conditions also
    --1> relationship already exists and referencing the
    --   Bill_to_orig_address_ref of the related customer.
    --2> relationship is created now, with the SHIP_TO referencing the
    --   Bill_to_orig_address_ref of the customer who will be related to this
    --   customer.
/*
  BEGIN

        BEGIN
                select  'X'
                into    l_count
                from    hz_cust_accounts cust
                        ,hz_cust_acct_sites site
                        ,hz_cust_site_uses su
                where   site.orig_system_reference = p_bill_to_orig_address_ref
                and     site.cust_acct_site_id = su.cust_acct_site_id
                and     site.cust_account_id = cust.cust_account_id
                and     cust.orig_system_reference = p_orig_system_customer_ref
                and     su.site_use_code = 'BILL_TO'
                and     su.status = 'A'
                and     site.status = 'A';

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                BEGIN
                  select  'X'
                  into l_count
                  from ra_customers_interface i,
                        ra_customers_interface i1
                  where
                        i.request_id                = req_id
                  and   i.bill_to_orig_address_ref is not  NULL
                  and   i1.site_use_code = 'BILL_TO'
                  and   i.bill_to_orig_address_ref = i1.orig_system_address_ref
                  and   i.orig_system_address_ref = p_orig_system_address_ref
                  and   i.orig_system_customer_ref = p_orig_system_customer_ref
                  and   i.rowid                    <> i1.rowid
                  and   i.interface_status is null
                  and   rownum = 1;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                 return err_msg;
                END;
        END;

     return null;
*/

    CURSOR c IS -- Checkif the customer or the related customer already exists
      SELECT 'x'
      FROM   hz_cust_accounts cust,
             hz_cust_acct_sites_all site, -- bug 4454799
             hz_cust_site_uses_all su  -- bug 4454799
      WHERE  cust.orig_system_reference = p_orig_system_customer_ref
             AND site.orig_system_reference = p_bill_to_orig_address_ref
             AND site.org_id = p_org_id  -- bug 4454799
             AND site.cust_account_id = cust.cust_account_id
             AND site.cust_acct_site_id = su.cust_acct_site_id
             AND site.org_id = su.org_id -- bug 4454799
             AND su.site_use_code = 'BILL_TO'
             AND su.status = 'A'
             AND site.status = 'A'
      UNION ALL
      SELECT 'x'
      FROM   hz_cust_accounts cust,
             hz_cust_acct_sites_all site, -- bug 4454799
             hz_cust_site_uses_all su  -- bug 4454799
      WHERE  cust.orig_system_reference = p_orig_system_parent_ref
             AND site.orig_system_reference = p_bill_to_orig_address_ref
             AND site.org_id = p_org_id  -- bug 4454799
             AND site.cust_account_id = cust.cust_account_id
             AND site.cust_acct_site_id = su.cust_acct_site_id
             AND site.org_id = su.org_id  -- bug 4454799
             AND su.site_use_code = 'BILL_TO'
             AND su.status = 'A'
             AND site.status = 'A';

    CURSOR c2 IS -- Checking if the relationship already exists
      SELECT 'x'
      FROM   hz_cust_accounts cust,
             hz_cust_acct_relate_all rel, -- bug 4454799
             hz_cust_acct_sites_all site, -- bug 4454799
             hz_cust_site_uses_all su  -- bug 4454799
      WHERE  cust.orig_system_reference = p_orig_system_customer_ref
             AND  rel.related_cust_account_id = cust.cust_account_id
             AND  rel.bill_to_flag   = 'Y'
             AND  site.cust_account_id = rel.cust_account_id
             AND  site.orig_system_reference = p_bill_to_orig_address_ref
             AND  site.org_id = p_org_id -- bug 4454799
	     AND  site.org_id = su.org_id -- bug 4454799
	     AND  site.org_id = rel.org_id -- bug 4454799
             AND site.cust_acct_site_id = su.cust_acct_site_id
             AND su.site_use_code = 'BILL_TO'
             AND su.status = 'A'
             AND site.status = 'A';

    CURSOR c1 IS  -- If the customer or related customer do not exist THEN Check for their existence in the interface table
      SELECT 'x'
      FROM   ra_customers_interface      i,
             ra_customers_interface_all i1 -- bug 4454799
      WHERE  i.request_id = req_id
             AND   i.bill_to_orig_address_ref is not NULL
             AND   i.orig_system_customer_ref = p_orig_system_customer_ref
             AND   i.orig_system_address_ref = p_orig_system_address_ref
             AND   i.bill_to_orig_address_ref = i1.orig_system_address_ref
             AND   i.org_id = p_org_id  -- bug 4454799
             AND   i.org_id = i1.org_id -- bug 4454799
             AND   i1.site_use_code = 'BILL_TO'
             AND   i.rowid  <> i1.rowid
             AND   i1.interface_status is null
             AND   rownum = 1
      UNION ALL
      SELECT 'x'
      FROM   ra_customers_interface i,
             ra_customers_interface_all i1 -- bug 4454799
      WHERE  i.request_id = req_id
             AND   i.bill_to_orig_address_ref is not NULL
             AND   i.orig_system_customer_ref = p_orig_system_customer_ref
             AND   i1.orig_system_customer_ref = i.orig_system_parent_ref
             AND   i.orig_system_address_ref = p_orig_system_address_ref
             AND   i.org_id = p_org_id  -- bug 4454799
	     AND   i.org_id = i1.org_id -- bug 4454799
             AND   i.bill_to_orig_address_ref = i1.orig_system_address_ref
             AND   i1.site_use_code = 'BILL_TO'
             AND   i.rowid  <> i1.rowid
             AND   i1.interface_status is null
             AND   rownum = 1;

  BEGIN

    OPEN c;
    FETCH c INTO l_dummy;
    IF c%NOTFOUND THEN
      OPEN c1;
      FETCH c1 INTO l_dummy;
      IF c1%NOTFOUND THEN
        OPEN c2;
        FETCH c2 INTO l_dummy;
        IF c2%NOTFOUND THEN
          CLOSE c;
          CLOSE c1;
          CLOSE c2;
          RETURN err_msg;
        END IF;
      END IF;
    END IF;

    IF c%ISOPEN THEN
      CLOSE c;
    END IF;

    IF c1%ISOPEN THEN
      CLOSE c1;
    END IF;

    IF c2%ISOPEN THEN
      CLOSE c2;
    END IF;
    RETURN NULL;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN err_msg;
  END val_bill_to_orig_address_ref;


/*===========================================================================+
 | FUNCTION
 |         get_ultimate_parent_party_ref
 |
 | DESCRIPTION
 |         get ultimate parent party system reference
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_orig_system_customer_ref
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : Y/N
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    Jianying Huang 30-APR-01  Created.
 |    Jianying Huang 19-SEP-01  Renamed procedure and returned ultimate parent
 |                              party reference.
 |
 +===========================================================================*/

  FUNCTION get_ultimate_parent_party_ref (p_orig_system_customer_ref VARCHAR2)
    RETURN VARCHAR2 IS

    l_orig_system_party_ref    ra_customers_interface.orig_system_party_ref%TYPE;
    l_orig_system_parent_ref   ra_customers_interface.orig_system_parent_ref%TYPE;

    -- bug 2098243 - fixed to use a cursor instead of a direct select.
    CURSOR c10 IS
      SELECT orig_system_parent_ref, orig_system_party_ref
      FROM   ra_customers_interface
      WHERE  orig_system_customer_ref = p_orig_system_customer_ref
             AND ROWNUM = 1;
  BEGIN
    OPEN c10;
    FETCH c10 INTO l_orig_system_parent_ref, l_orig_system_party_ref;
    CLOSE c10;

    IF l_orig_system_parent_ref IS NULL THEN
      RETURN NVL(l_orig_system_party_ref, p_orig_system_customer_ref);
    ELSE
      RETURN get_ultimate_parent_party_ref( l_orig_system_parent_ref );
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN p_orig_system_customer_ref;
  END get_ultimate_parent_party_ref;

/*===========================================================================+
 | FUNCTION
 |         check_assigned_worker
 |
 | DESCRIPTION
 |         Computer worker number based on passed-in string and
 |         compare the computed worker number with passed-in worker
 |         number.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_string
 |                    p_total_workers
 |                    p_worker
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : Y/N
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    Jianying Huang 30-APR-01  Created.
 |
 +===========================================================================*/

  FUNCTION check_assigned_worker (p_string                VARCHAR2,
                                  p_total_workers         NUMBER,
                                  p_worker                NUMBER)
    RETURN VARCHAR2 IS

    len                     NUMBER;
    val                     NUMBER := 0;
    ret                     VARCHAR2(1);
    i                       NUMBER := 1;

  BEGIN
    IF p_total_workers = 1 THEN
      IF p_worker = 1 THEN
        RETURN ('Y');
      ELSE
        RETURN ('N');
      END IF;
    END IF;

    len := LENGTHB(p_string);
    IF (len = 0) THEN
      RETURN ('N');
    END IF;

    WHILE (i <= len)
    LOOP
      val := val + ASCII(SUBSTRB(p_string, i, 1));
      i := i + 1;
    END LOOP;

    IF ((MOD( val, p_total_workers ) + 1) = p_worker) THEN
      ret := 'Y';
    ELSE
      ret := 'N';
    END IF;

    RETURN (ret);

  END check_assigned_worker;

/*===========================================================================+
 | PROCEDURE
 |         conc_main
 |
 | DESCRIPTION
 |         Procedure called by concurrent executable - minus create_reciprocal
 |         _flag
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                   errbuf
 |                   retcode
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    J. del Callar  06-NOV-01  Created for backward compatibility, refer to
 |                              Bug 2092530.
 |
 +===========================================================================*/

  PROCEDURE conc_main (errbuf                  OUT NOCOPY VARCHAR2,
                       retcode                 OUT NOCOPY VARCHAR2) IS
  BEGIN
    conc_main(errbuf, retcode, 'No' , 0);
  END conc_main;

/*===========================================================================+
 | PROCEDURE
 |         conc_main
 |
 | DESCRIPTION
 |         Procedure called by concurrent executable.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                   create_reciprocal_flag - create reciprocal customer flag
 |              OUT:
 |                   errbuf
 |                   retcode
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    Jianying Huang 30-APR-00  Created.
 |    J. del Callar  06-NOV-01  Bug 2092530: added create_reciprocal_flag arg
 |
 +===========================================================================*/

  PROCEDURE conc_main (errbuf                  OUT NOCOPY VARCHAR2,
                       retcode                 OUT NOCOPY VARCHAR2,
                       p_create_reciprocal_flag IN VARCHAR2,
                       p_org_id                 IN NUMBER := 0 ) IS

    m_request_id            NUMBER;

    l_profile               VARCHAR2(30);
    l_num_of_workers        NUMBER;
    l_sub_request_id        NUMBER;

    l_conc_phase            VARCHAR2(80);
    l_conc_status           VARCHAR2(80);
    l_conc_dev_phase        VARCHAR2(30);
    l_conc_dev_status       VARCHAR2(30);
    l_message               VARCHAR2(240);

    l_posi1                 NUMBER;
    l_posi2                 NUMBER;
    l_times                 NUMBER;
    l_request_data          VARCHAR2(240);
    l_sub_request_ids       VARCHAR2(200);

    i                       NUMBER;

  BEGIN

    -- Read the value from REQUEST_DATA. If this is the
    -- first run of the program, the return value will
    -- be null. Otherwise, the return value will be what
    -- we passed to SET_REG_GLOBALS on the previous run.

    -- First run: Do global validation
    -- Second run: Do parallel validation
    -- Third run: Do global insert/update
    -- Fourth run: Do parallel insert/update

    l_request_data := FND_CONC_GLOBAL.REQUEST_DATA;

    -- this is not the first run
    IF l_request_data IS NOT NULL THEN

      l_posi1 := INSTRB(l_request_data, ' ', 1, 1);
      l_posi2 := INSTRB(l_request_data, ' ', 1, 2);
      l_times := TO_NUMBER(SUBSTRB(l_request_data, 1, l_posi1 - 1));
      m_request_id := TO_NUMBER(SUBSTRB(l_request_data, l_posi1 + 1,
                                       l_posi2 - l_posi1 ) );
      l_sub_request_ids := SUBSTRB(l_request_data, l_posi2 + 1);

      WHILE l_sub_request_ids IS NOT NULL LOOP
        l_posi1 := INSTRB(l_sub_request_ids, ' ', 1, 1);
        l_sub_request_id := TO_NUMBER(SUBSTRB(l_sub_request_ids, 1, l_posi1-1));

        -- Check return status of validation request.
        IF (FND_CONCURRENT.GET_REQUEST_STATUS(
              request_id  => l_sub_request_id,
              phase       => l_conc_phase,
              status      => l_conc_status,
              dev_phase   => l_conc_dev_phase,
              dev_status  => l_conc_dev_status,
              message     => l_message)) THEN
          IF l_conc_dev_phase <> 'COMPLETE'
             OR l_conc_dev_status <> 'NORMAL' THEN
            retcode := 2;

            FND_FILE.PUT_LINE(FND_FILE.LOG,
                              TO_CHAR( l_sub_request_id ) ||
                              ' : ' || l_conc_phase || ':' || l_conc_status ||
                              ' (' || l_message || ').' );
            RETURN;

          END IF;
        ELSE
          retcode := 2;

          RETURN;
        END IF;

        l_sub_request_ids := SUBSTRB( l_sub_request_ids, l_posi1 + 1 );
      END LOOP;
    ELSE
      m_request_id := FND_GLOBAL.CONC_REQUEST_ID;
      l_times := 0;
    END IF;

    l_times := l_times + 1;

    -- if this is the first run, we need to do global validation
    -- if this is the third run, we need to do global insert/update
    IF l_times IN ( 1, 3 ) THEN
      IF p_org_id <> 0    THEN
           FND_REQUEST.SET_ORG_ID(p_org_id);
      END IF;
      -- Bug 2092530: added create_reciprocal_flag arg
      l_sub_request_id := FND_REQUEST.SUBMIT_REQUEST(
                            'AR', 'RACUSTSB', '',
                            TO_CHAR( SYSDATE, 'DD-MON-YY HH24:MI:SS' ),  --Bug 3175928
                            TRUE,
                            1, 1, TO_CHAR(l_times), p_create_reciprocal_flag, p_org_id);

      IF l_sub_request_id = 0 THEN

        FND_MESSAGE.SET_NAME('AR', 'AR_CUST_CONC_ERROR');
        FND_MESSAGE.RETRIEVE(l_message);

        FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);
        retcode := 2;
        RETURN;

      ELSE

        FND_MESSAGE.SET_NAME('AR', 'AR_CUST_SHOW_UPD_REQID');
        FND_MESSAGE.RETRIEVE(l_message);

        FND_FILE.PUT_LINE(FND_FILE.LOG, l_message);
        retcode := 0;

      END IF;

      l_request_data := TO_CHAR( l_times ) || ' ' ||
                        TO_CHAR( m_request_id ) || ' ' ||
                        TO_CHAR( l_sub_request_id ) || ' ';

    -- if this is third run, do parallel validation
    -- if this is fouth run, do parallel insert/update
    ELSIF l_times IN ( 2, 4 ) THEN
      -- read profile option.
      l_profile := 'HZ_CINTERFACE_NUM_OF_WORKERS';

      l_num_of_workers := NVL(FND_PROFILE.VALUE(l_profile), 1);

      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        l_profile || ' = ' || TO_CHAR(l_num_of_workers));

      l_request_data := '';

      -- submit sub-requests to insert/update customers.
      -- do NOT do validation.
      FOR i IN 1..l_num_of_workers LOOP
      IF p_org_id <> 0    THEN
           FND_REQUEST.SET_ORG_ID(p_org_id);
      END IF;
        -- Bug 2092530: added create_reciprocal_flag arg
        l_sub_request_id := FND_REQUEST.SUBMIT_REQUEST(
                              'AR', 'RACUSTSB', '',
                              TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI:SS'),  --Bug 3175928
                              TRUE,
                              TO_CHAR(l_num_of_workers),
                              TO_CHAR(i), TO_CHAR(l_times),
                              p_create_reciprocal_flag, p_org_id);

        IF l_sub_request_id = 0 THEN

          FND_MESSAGE.SET_NAME('AR', 'AR_CUST_CONC_ERROR');
          FND_MESSAGE.RETRIEVE(l_message );

          FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(i) || ' : ' || l_message);
          retcode := 2;

        ELSE

          FND_MESSAGE.SET_NAME('AR', 'AR_CUST_SHOW_UPD_REQID');
          FND_MESSAGE.RETRIEVE(l_message);

          FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(i) || ' : ' || l_message);
          retcode := 0;

          l_request_data := l_request_data || TO_CHAR(l_sub_request_id) || ' ';
        END IF;

      END LOOP;

      IF l_times = 4 THEN
        retcode := 0;
        RETURN;
      END IF;

      l_request_data := TO_CHAR(l_times) || ' ' ||
                        TO_CHAR(m_request_id) || ' ' ||
                        l_request_data;
    END IF;

    FND_CONC_GLOBAL.SET_REQ_GLOBALS(
      conc_status  => 'PAUSED',
      request_data => l_request_data);

  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'Oracle Error : ' || SQLERRM );
      retcode := 2;
      RETURN;
  END conc_main;

/*===========================================================================+
 | FUNCTION
 |         validate_profile
 |
 | DESCRIPTION
 |         Function called by concurrent executable.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                   errbuf
 |                   retcode
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : Error Code/NULL
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    Gautam/Chelvi      26-May-01  Created for Bug# 1791059.
 |
 +===========================================================================*/

 /* bug 4454799 - added argument for org_id below. */
  FUNCTION validate_profile(v_insert_update_flag IN VARCHAR,
                            v_orig_system_customer_ref IN VARCHAR,
                            v_orig_system_address_ref IN VARCHAR,
                            v_org_id IN NUMBER,
                            v_request_id IN NUMBER)
    RETURN VARCHAR2 AS

    l_dummy VARCHAR(1);

    CURSOR c1 IS -- Check if Cust record exists for ninsertion
      SELECT 'x'
      FROM   ra_customers_interface
      WHERE  orig_system_customer_ref = v_orig_system_customer_ref
             AND interface_status is null
             AND request_id = v_request_id;

    CURSOR c2 IS -- Checking if Profile exists at Cust Level , thats why site_use_id is null
      SELECT 'x'
      FROM   hz_customer_profiles p ,hz_cust_accounts c
      WHERE  c.orig_system_reference = v_orig_system_customer_ref
             AND p.cust_account_id = c.cust_account_id
             AND p.site_use_id is null;

    CURSOR c3 IS
      SELECT 'x' -- The address ref should exist as Bill To and defined for the customer
      FROM   hz_cust_acct_sites_all ra, hz_cust_site_uses_all rsu, hz_cust_accounts rc -- bug 4454799
      WHERE  ra.orig_system_reference = v_orig_system_address_ref
             AND ra.org_id = v_org_id  -- bug 4454799
             AND rc.orig_system_reference = v_orig_system_customer_ref
             AND rc.cust_account_id = ra.cust_account_id
             AND ra.cust_acct_site_id = rsu.cust_acct_site_id
             AND ra.org_id = rsu.org_id  -- bug 4454799
             AND rsu.status = 'A'
             AND rsu.site_use_code in ('BILL_TO','DUN','STMTS')
      UNION ALL
      SELECT 'x' -- If not already defined, THEN address rec should
                 -- exist in  interface table with Bill To
      FROM   ra_customers_interface
      WHERE  orig_system_customer_ref = v_orig_system_customer_ref
             AND interface_status is null
             AND orig_system_address_ref = v_orig_system_address_ref
             AND org_id = v_org_id  -- bug 4454799
             AND request_id = v_request_id
--Bug fix 2473275
             AND site_use_code in ('BILL_TO','DUN','STMTS');

    CURSOR c4 IS -- Checking if Profile exists at Site Use Level
      SELECT 'x'
      FROM   hz_customer_profiles p,
             hz_cust_acct_sites_all ra, -- bug 4454799
             hz_cust_site_uses_all rsu  -- but 4454799
      WHERE  ra.orig_system_reference = v_orig_system_address_ref
             AND ra.org_id = v_org_id  -- bug 4454799
	     AND ra.org_id = rsu.org_id -- bug 4454799
             AND ra.cust_acct_site_id = rsu.cust_acct_site_id
             AND rsu.status = 'A'
--Bug fix 2473275
             AND rsu.site_use_code in ('BILL_TO','DUN','STMTS')
             AND rsu.site_use_id = p.site_use_id;

  BEGIN

    IF v_insert_update_flag NOT IN ('I','U') THEN
      RETURN 'J8,';
    END IF;

    -- Profile at the Cust Level validations

    IF v_orig_system_address_ref IS NULL THEN

      IF v_insert_update_flag = 'I' THEN  -- Insert New Profile
        -- check if the customer ref is valid.  if not, reject with status = S1
        OPEN c1;
        FETCH c1 INTO l_dummy;
        IF c1%NOTFOUND THEN
          RETURN 'S1,';
        END IF;
        CLOSE c1;

        -- This customer should not have a profile defined already.
        -- if defined  reject with status = 'a3'
        OPEN c2;
        FETCH c2 INTO l_dummy;
        IF c2%FOUND THEN
          RETURN 'a3,';
        END IF;
        CLOSE c2;
      END IF;

      IF v_insert_update_flag = 'U' THEN -- Updating existing profile
        -- This customer should have a profile defined already.
        -- if not defined  reject with status = 'a4'
        OPEN c2;
        FETCH c2 INTO l_dummy;
        IF c2%NOTFOUND THEN
          RETURN 'a4,';
        END IF;
        CLOSE c2;
      END IF;
    END IF;

    -- Profile at the Address Level Validations

    IF v_orig_system_address_ref IS NOT NULL THEN
      IF v_insert_update_flag = 'I' THEN -- Insert New Profile

        -- First check if the address  has been already created
        -- as a Bill_TO,DUNNING or STATEMENTS or if not created THEN should be in the
        -- interface table with no error AND should be BILL_TO,DUNNING or STATEMENTS.
        OPEN c3;
        FETCH c3 INTO l_dummy;
        IF c3%NOTFOUND THEN
          RETURN 'S7,';
        END IF;
        CLOSE c3;

        -- This Site should not have a profile defined already.
        -- if defined  reject with status = 'a3'
        OPEN c4;
        FETCH c4 INTO l_dummy;
        IF c4%FOUND THEN
          RETURN 'a3,';
        END IF;
        CLOSE c4;
      END IF;

      IF v_insert_update_flag = 'U' THEN -- Updating Existing Profile
        -- This Site should have a profile defined already.
        -- if not defined  reject with status = 'a4'
        OPEN c4;
        FETCH c4 INTO l_dummy;
        IF c4%NOTFOUND THEN
          RETURN 'a4,';
        END if;
        CLOSE c4;
      END IF;
    END IF;

    -- If all validations pass THEN return null
    RETURN NULL;

  END validate_profile;

  FUNCTION validate_address(p_location_structure_id IN NUMBER,
                            p_creation_date IN DATE,
                            p_state IN VARCHAR2,
                            p_city IN VARCHAR2,
                            p_county IN VARCHAR2,
                            p_postal_code IN VARCHAR2,
                            p_province IN VARCHAR2 default null) RETURN VARCHAR2 IS
    l_dummy   VARCHAR2(1);
--Bug Fix 2684136
    l_struct  VARCHAR2(200);
    l_no_segments NUMBER;
    l_child VARCHAR2(20);
    l_parent VARCHAR2(20);
    l_child_value  VARCHAR2(100);
   l_parent_value VARCHAR2(100);

--FOR postal_code.city.county.state

    CURSOR C IS
      SELECT 'X'
      FROM   ar_location_values v,
             ar_location_values pv,
             ar_location_values gv,
             ar_location_values ggv,
             ar_location_rates  r
      WHERE  v.location_structure_id      = p_location_structure_id
             AND v.location_segment_id    = r.location_segment_id
             AND v.location_segment_value = UPPER(p_postal_code)
             AND v.location_segment_qualifier = 'POSTAL_CODE'
             AND TRUNC(p_creation_date)
               BETWEEN TRUNC(r.start_date)
                       AND NVL(TRUNC(r.end_date), TRUNC(p_creation_date))
             AND p_postal_code BETWEEN r.from_postal_code AND r.to_postal_code
             AND v.parent_segment_id  = pv.location_segment_id(+)
             AND pv.parent_segment_id = gv.location_segment_id(+)
             AND gv.parent_segment_id = ggv.location_segment_id(+)
             AND (pv.location_segment_value = UPPER(p_city)
                  OR p_city IS NULL)
             AND (gv.location_segment_value = UPPER(p_county)
                  OR p_county IS NULL)
             AND (ggv.location_segment_value = UPPER(p_state)
                  OR p_state IS NULL );
--For city.county.state structure

    CURSOR C1 IS
      SELECT 'X'
      FROM   ar_location_values v,
             ar_location_values pv,
             ar_location_values gv,
             ar_location_rates  r
      WHERE  v.location_structure_id      = p_location_structure_id
             AND v.location_segment_id    = r.location_segment_id
             AND v.location_segment_value = UPPER(p_city)
             AND v.location_segment_qualifier = 'CITY'
             AND TRUNC(p_creation_date)
               BETWEEN TRUNC(r.start_date)
                       AND NVL(TRUNC(r.end_date), TRUNC(p_creation_date))
             AND p_postal_code BETWEEN r.from_postal_code AND r.to_postal_code
             AND v.parent_segment_id  = pv.location_segment_id(+)
             AND pv.parent_segment_id = gv.location_segment_id(+)
             AND (pv.location_segment_value = UPPER(p_county)
                  OR p_county IS NULL)
             AND (gv.location_segment_value = UPPER(p_state)
                  OR p_state IS NULL);

--For city.province and city.state structure

    CURSOR C2(p_child VARCHAR2,p_parent_value VARCHAR2,p_child_value VARCHAR2) IS
      SELECT 'X'
      FROM   ar_location_values v,
             ar_location_values gv,
             ar_location_rates  r
      WHERE  v.location_structure_id      = p_location_structure_id
             AND v.location_segment_id    = r.location_segment_id
             AND v.location_segment_value = UPPER(p_child_value)
             AND v.location_segment_qualifier = p_child
             AND TRUNC(p_creation_date)
               BETWEEN TRUNC(r.start_date)
                       AND nvl(TRUNC(r.end_date), TRUNC(p_creation_date))
             AND p_postal_code BETWEEN r.from_postal_code AND r.to_postal_code
             AND v.parent_segment_id  = gv.location_segment_id(+)
             AND (gv.location_segment_value = UPPER(p_parent_value)
                  OR p_state IS NULL);

--For city and province Structure

    CURSOR C3(p_segment VARCHAR2,p_value VARCHAR2) IS
      SELECT 'X'
      FROM   ar_location_values v, ar_location_rates  r
      WHERE  v.location_structure_id      = p_location_structure_id
             AND v.location_segment_id    = r.location_segment_id
             AND v.location_segment_value = UPPER(p_value)
             AND v.location_segment_qualifier = p_segment
             AND TRUNC(p_creation_date)
               BETWEEN TRUNC(r.start_date)
                       AND nvl(TRUNC(r.end_date), TRUNC(p_creation_date))
             AND p_postal_code BETWEEN r.from_postal_code AND r.to_postal_code
             ;
  BEGIN

    l_struct := (replace (replace (replace (arp_flex.expand(arp_flex.location,'ALLREV','.','%QUALIFIER%'),'EXEMPT_LEVEL',null),'TAX_ACCOUNT',null),' ',null));

 l_no_segments := arp_flex.active_segments(arp_flex.location);

 IF l_no_segments = 1 THEN
      IF l_struct = 'CITY' THEN
         l_child_value := p_city;
      ELSIF l_struct = 'PROVINCE' THEN
        l_child_value := p_province;
      ELSIF l_struct = 'COUNTRY' THEN
        RETURN (null);
      ELSE
       RETURN('Y');
      END IF;

      OPEN C3( l_struct, l_child_value );

      FETCH C3 INTO l_dummy;
       IF C3%NOTFOUND THEN
          CLOSE C3;
          RETURN('Y');
       END IF;

 ELSIF l_no_segments = 2 THEN

        select
        rtrim(substr(l_struct,1,instr(l_struct,'.')),'.'),ltrim(substr(l_struct,instr(l_struct,'.')),'.') into l_child,l_parent
        from dual;

       IF (l_struct = 'CITY.STATE') then
           l_child_value := p_city;
           l_parent_value := p_state;
        elsif ( l_struct = 'CITY.PROVINCE') THEN
           l_child_value := p_city;
           l_parent_value := p_province;
        END IF;


       OPEN C2( l_child,l_parent_value,l_child_value);
       FETCH C2 INTO l_dummy;
       IF C2%NOTFOUND THEN
          CLOSE C2;
          RETURN('Y');
       END IF;

 ELSIF l_no_segments = 3 THEN
       OPEN C1 ;
       FETCH C1 INTO l_dummy;
       IF C1%NOTFOUND THEN
          CLOSE C1;
          RETURN('Y');
       END IF;

 ELSE
       OPEN C;
       FETCH C INTO l_dummy;
       IF C%NOTFOUND THEN
          CLOSE C;
          RETURN('Y');
       END IF;
    END IF;

    IF C%ISOPEN THEN
       CLOSE C;
    END IF;
    IF C1%ISOPEN THEN
      CLOSE C1;
    END IF;
    IF C2%ISOPEN THEN
      CLOSE C2;
    END IF;
    IF C3%ISOPEN THEN
      CLOSE C3;
    END IF;

    RETURN(null);

  EXCEPTION
    WHEN OTHERS THEN
    RETURN('E');
  END validate_address;
/*===========================================================================+
 | FUNCTION
 |         validate_party_number
 |
 | DESCRIPTION
 |         Function called by concurrent executable.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                   orig_system_customer_ref
 |                   orig_system_party_ref
 |                   party_number
 |                   rowid
 |                   request_id
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : Error Code/NULL
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    V.Srinivasan      04-MAR-01  Created for Bug# 2222791.
 |
 +===========================================================================*/
  FUNCTION val_party_number( p_orig_system_customer_ref IN VARCHAR2,
                           p_orig_system_party_ref IN VARCHAR2,
                           p_party_number IN VARCHAR2,
                           p_rowid IN ROWID,
                           req_id IN NUMBER) RETURN VARCHAR2 is
    err_msg   VARCHAR2(3) := 'Y3,';
    l_dummy   VARCHAR2(3);


    CURSOR c IS -- Check if the party_number already exists
      SELECT decode(party.orig_system_reference,p_orig_system_party_ref,'','Y3,')
      FROM   hz_parties party
      WHERE  party.party_number = p_party_number;

    CURSOR c1 IS -- Check if the party_number already exists
      SELECT decode(party.orig_system_reference,p_orig_system_customer_ref,'','Y3,')
      FROM   hz_parties party
      WHERE  party.party_number = p_party_number;

    CURSOR c2 IS -- Check if the party_number already exists in interface table
      SELECT decode(NVL(i.orig_system_party_ref,i.orig_system_customer_ref),p_orig_system_party_ref,'','Y3,')
      FROM   ra_customers_interface_all i
      WHERE  i.party_number = p_party_number
      AND    i.request_id = req_id
      AND    i.rowid <> p_rowid ;

    CURSOR c3 IS -- Check if the party_number already exists in interface table
      SELECT decode(NVL(i.orig_system_party_ref,i.orig_system_customer_ref),p_orig_system_customer_ref,'','Y3,')
      FROM   ra_customers_interface_all i
      WHERE  i.party_number = p_party_number
      AND    i.request_id = req_id
      AND    i.rowid <> p_rowid ;


  BEGIN

  if p_orig_system_party_ref is NOT NULL then
    OPEN c;
    FETCH c INTO l_dummy;
    IF c%NOTFOUND THEN
      OPEN c2;
      FETCH c2 INTO l_dummy;

      IF c2%NOTFOUND THEN
          CLOSE c;
          CLOSE c2;
      ELSE RETURN l_dummy;
      END IF;

    ELSE RETURN l_dummy;
    END IF;

    IF c%ISOPEN THEN
      CLOSE c;
    END IF;

    IF c2%ISOPEN THEN
      CLOSE c2;
    END IF;

    RETURN NULL;

  else

    OPEN c1;
    FETCH c1 INTO l_dummy;
    IF c1%NOTFOUND THEN
      OPEN c3;
      FETCH c3 INTO l_dummy;

      IF c3%NOTFOUND THEN
          CLOSE c1;
          CLOSE c3;
      ELSE RETURN l_dummy;
      END IF;

    ELSE RETURN l_dummy;
    END IF;

    IF c1%ISOPEN THEN
      CLOSE c1;
    END IF;

    IF c3%ISOPEN THEN
      CLOSE c3;
    END IF;

    RETURN NULL;

  end if;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_dummy;
  END val_party_number;
/*===========================================================================+
 | FUNCTION
 |         validate_party_numb_ref
 |
 | DESCRIPTION
 |         Function called by concurrent executable.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                   orig_system_customer_ref
 |                   orig_system_party_ref
 |                   party_number
 |                   rowid
 |                   request_id
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : Error Code/NULL
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    V.Srinivasan      04-MAR-01  Created for Bug# 2222791.
 +===========================================================================*/
  FUNCTION val_party_numb_ref(p_orig_system_customer_ref IN VARCHAR2,
                           p_orig_system_party_ref IN VARCHAR2,
                           p_party_number IN VARCHAR2,
                           p_rowid IN ROWID,
                           req_id IN NUMBER) RETURN VARCHAR2 is
    err_msg   VARCHAR2(3) := 'Y4,';
    l_dummy   VARCHAR2(3);


    CURSOR c IS -- Check if the same party has a diff party_number
      SELECT decode(i.party_number,p_party_number,'','Y4,')
      FROM   ra_customers_interface_all i
      WHERE  i.orig_system_party_ref = p_orig_system_party_ref
      AND    i.request_id = req_id
      AND    i.rowid <> p_rowid ;

    CURSOR c1 IS -- Check if the same party has a diff party_number and the orig_system_party_ref is null
      SELECT decode(i.party_number,p_party_number,'','Y4,')
      FROM   ra_customers_interface_all i
      WHERE  i.orig_system_customer_ref = p_orig_system_party_ref
      AND    i.orig_system_party_ref is null
      AND    i.request_id = req_id
      AND    i.rowid <> p_rowid ;

    CURSOR c2 IS -- Check if the same party has a diff party_number and the orig_system_party_ref passed is null
      SELECT decode(i.party_number,p_party_number,'','Y4,')
      FROM   ra_customers_interface_all i
      WHERE  i.orig_system_party_ref = p_orig_system_customer_ref
      AND    i.request_id = req_id
      AND    i.rowid <> p_rowid ;

    CURSOR c3 IS -- Check if the same party has a diff party_number and the orig_system_party_ref passed is null and the record in the interface table also has orig_system_party_ref as null
      SELECT decode(i.party_number,p_party_number,'','Y4,')
      FROM   ra_customers_interface_all i
      WHERE  i.orig_system_customer_ref = p_orig_system_customer_ref
      AND    i.orig_system_party_ref is null
      AND    i.request_id = req_id
      AND    i.rowid <> p_rowid ;

  BEGIN

  if p_orig_system_party_ref is NOT NULL then
    OPEN c;
    FETCH c INTO l_dummy;
    IF c%NOTFOUND THEN
      OPEN c1;
      FETCH c1 INTO l_dummy;

      IF c1%NOTFOUND THEN
          CLOSE c;
          CLOSE c1;
      ELSE RETURN l_dummy;
      END IF;

    ELSE RETURN l_dummy;
    END IF;

    IF c%ISOPEN THEN
      CLOSE c;
    END IF;

    IF c1%ISOPEN THEN
      CLOSE c1;
    END IF;

    RETURN NULL;

  else

    OPEN c2;
    FETCH c2 INTO l_dummy;
    IF c2%NOTFOUND THEN
      OPEN c3;
      FETCH c3 INTO l_dummy;

      IF c3%NOTFOUND THEN
          CLOSE c2;
          CLOSE c3;
      ELSE RETURN l_dummy;
      END IF;

    ELSE RETURN l_dummy;
    END IF;

    IF c2%ISOPEN THEN
      CLOSE c2;
    END IF;

    IF c3%ISOPEN THEN
      CLOSE c3;
    END IF;

    RETURN NULL;

  end if;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_dummy;
  END val_party_numb_ref;
/*===========================================================================+
 | FUNCTION
 |         val_cust_number
 |
 | DESCRIPTION
 |         Function called by concurrent executable.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                   orig_system_customer_ref
 |                   customer_number
 |                   rowid
 |                   request_id
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : Error Code/NULL
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    V.Srinivasan      04-MAR-01  Created for Bug# 2222791.
 |
 +===========================================================================*/
  FUNCTION val_cust_number(p_orig_system_customer_ref IN VARCHAR2,
                           p_customer_number IN VARCHAR2,
                           p_rowid IN ROWID,
                           req_id IN NUMBER) RETURN VARCHAR2 is
    err_msg   VARCHAR2(3) := 'A5,';
    l_dummy   VARCHAR2(3);


    CURSOR c IS -- Check if the customer_number already exists
      SELECT decode(cust.orig_system_reference,p_orig_system_customer_ref,'','A5,')
      FROM   hz_cust_accounts cust
      WHERE  cust.account_number = p_customer_number;

    CURSOR c1 IS -- Check if the customer_number already exists in the interface table
      SELECT decode(i.orig_system_customer_ref,p_orig_system_customer_ref,'','A5,')
      FROM   ra_customers_interface_all i
      WHERE  i.customer_number = p_customer_number
      AND    i.request_id = req_id
      AND    i.rowid <> p_rowid ;

  BEGIN

    OPEN c;
    FETCH c INTO l_dummy;
    IF c%NOTFOUND THEN
      OPEN c1;
      FETCH c1 INTO l_dummy;

      IF c1%NOTFOUND THEN
          CLOSE c;
          CLOSE c1;
      ELSE RETURN l_dummy;
      END IF;

    ELSE RETURN l_dummy;
    END IF;

    IF c%ISOPEN THEN
      CLOSE c;
    END IF;

    IF c1%ISOPEN THEN
      CLOSE c1;
    END IF;

    RETURN NULL;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_dummy;
  END val_cust_number;
/*===========================================================================+
 | FUNCTION
 |         validate_party_site_number
 |
 | DESCRIPTION
 |         Function called by concurrent executable.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                   orig_system_address_ref
 |                   party_site_number
 |                   rowid
 |                   request_id
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : Error Code/NULL
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    V.Srinivasan      04-MAR-01  Created for Bug# 2222791.
 |
 +===========================================================================*/
  -- bug 4454799
  FUNCTION val_party_site_number( p_orig_system_address_ref IN VARCHAR2,
                           p_party_site_number IN VARCHAR2,
                           p_rowid IN ROWID,
                           p_org_id IN NUMBER,
                           req_id IN NUMBER) RETURN VARCHAR2 is
    err_msg   VARCHAR2(3) := 'Y6,';
    l_dummy   VARCHAR2(3);


    CURSOR c IS -- Check if the party_site_number already exists
      SELECT decode(cust_site.orig_system_reference,p_orig_system_address_ref,'','Y6,')
      FROM   hz_party_sites site, hz_cust_acct_sites_all cust_site -- bug 4454799
      WHERE  site.party_site_number = p_party_site_number
      AND    cust_site.org_id = p_org_id  -- bug 4454799
      AND    site.party_site_id = cust_site.party_site_id;

    CURSOR c1 IS -- Check if the party_site_number exists in the interface table
      SELECT decode(i.orig_system_address_ref,p_orig_system_address_ref,'','Y6,')
      FROM   ra_customers_interface_all i
      WHERE  i.party_site_number = p_party_site_number
      AND    i.org_id = p_org_id  -- bug 4454799
      AND    i.request_id = req_id
      AND    i.rowid <> p_rowid ;

  BEGIN

    OPEN c;
    FETCH c INTO l_dummy;
    IF c%NOTFOUND THEN
      OPEN c1;
      FETCH c1 INTO l_dummy;

      IF c1%NOTFOUND THEN
          CLOSE c;
          CLOSE c1;
      ELSE RETURN l_dummy;
      END IF;

    ELSE RETURN l_dummy;
    END IF;

    IF c%ISOPEN THEN
      CLOSE c;
    END IF;

    IF c1%ISOPEN THEN
      CLOSE c1;
    END IF;

    RETURN NULL;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_dummy;
  END val_party_site_number;

/*===========================================================================+
 | FUNCTION
 |         validate_tax_location
 |
 | DESCRIPTION
 |         Function called by concurrent executable.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                   orig_system_address_ref
 |                   country
 |                   city
 |                   state
 |                   county
 |                   province
 |                   postal_code
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : Error Code/NULL
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    P.Suresh        05/14/2002        Bug No : 2347408. Created.
 |
 +===========================================================================*/
  /* bug 4454799 - added argument for org_id below. */
  FUNCTION validate_tax_location( p_orig_system_address_ref IN VARCHAR2,
                                  p_country IN VARCHAR2,
                                  p_city IN VARCHAR2,
                                  p_state IN VARCHAR2,
                                  p_county IN VARCHAR2,
                                  p_province IN VARCHAR2,
                                  p_postal_code IN VARCHAR2,
                                  p_org_id IN NUMBER
                                   ) RETURN VARCHAR2 is

  err_msg   VARCHAR2(3) := 'y7,';
  l_dummy   VARCHAR2(3);

      l_location_id                NUMBER;
      l_city                       VARCHAR2(60);
      l_state                      VARCHAR2(60);
      l_country                    VARCHAR2(60);
      l_county                     VARCHAR2(60);
      l_province                   VARCHAR2(60);
      l_postal_code                VARCHAR2(60);


      l_loc_assignment_exist       VARCHAR2(1) := 'N';
      l_is_remit_to_location       VARCHAR2(1) := 'N';
      CURSOR C1 IS
      SELECT  loc.location_id,loc.country,loc.city, loc.state,
              loc.county, loc.province, loc.postal_code
      FROM    hz_cust_acct_sites_all cs, -- bug 4454799
              hz_party_sites         ps,
              hz_locations           loc
      WHERE   cs.orig_system_reference   =  p_orig_system_address_ref
      AND     cs.org_id			 =  p_org_id  -- bug 4454799
      AND     ps.party_site_id           =  cs.party_site_id
      AND     ps.location_id             =  loc.location_id;

  BEGIN
      -- tax location validation:
       OPEN C1;
       FETCH C1 INTO l_location_id,l_country, l_city, l_state,
                     l_county, l_province, l_postal_code;
       IF c1%NOTFOUND THEN
          CLOSE c1;
       END IF;
          -- check if the location is only used by prospect customers

          BEGIN
              SELECT  'Y'
              INTO    l_loc_assignment_exist
              FROM    DUAL
              WHERE   EXISTS (SELECT  1
                               FROM    hz_loc_assignments la
                               WHERE   la.location_id = l_location_id
                            );
              SELECT  'Y'
              INTO    l_is_remit_to_location
              FROM    DUAL
              WHERE   EXISTS (SELECT  1
                               FROM    hz_party_sites ps
                               WHERE   ps.location_id = l_location_id
                               AND     ps.party_id = -1
                            );
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
              NULL;
          END;

          IF l_is_remit_to_location = 'N' and l_loc_assignment_exist = 'Y' THEN
              -- check if the taxable components are changed
                      IF (     p_country        <>   l_country
                            OR  p_city           <>   l_city
                            OR  p_state          <>   l_state
                            OR  p_county         <>   l_county
                            OR  p_province       <>   l_province
                            OR  p_postal_code    <>   l_postal_code
                            )
                      THEN
                          IF ARH_ADDR_PKG.check_tran_for_all_accts(l_location_id)
                          THEN
                              return err_msg;
                          ELSE
                             return NULL;

                          END IF;
                      END IF;
           END IF; -- remit and loc
RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN err_msg;
END validate_tax_location;

/*===========================================================================+
 | PROCEDURE
 |    reset_who
 |
 | DESCRIPTION
 |    Cache who columns.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    Jianying Huang     07/12/2002        Bug No : 2460837. Created.
 |
 +===========================================================================*/

PROCEDURE reset_who IS
BEGIN
  g_created_by := hz_utility_v2pub.created_by;
  g_last_update_login := hz_utility_v2pub.last_update_login;
  g_last_updated_by := hz_utility_v2pub.last_updated_by;
  g_request_id := hz_utility_v2pub.request_id;
  g_program_application_id := hz_utility_v2pub.program_application_id;
  g_program_id := hz_utility_v2pub.program_id;
END reset_who;

/*===========================================================================+
 | PROCEDURE
 |    update_exception_table
 |
 | DESCRIPTION
 |    Update win source exception table when mix-n-match is seted up.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                   p_i_party_id
 |                   p_entity_attr_id
 |                   p_value
 |                   p_ue_ranking
 |                   p_sst_is_null
 |              OUT:
 |          IN/ OUT:
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    Jianying Huang     07/12/2002        Bug No : 2460837. Created.
 |
 +===========================================================================*/

PROCEDURE update_exception_table (
  p_i_party_id                       IN     t_id,
  p_entity_attr_id                   IN     NUMBER,
  p_value                            IN     t_varchar500,
  p_ue_ranking                       IN     NUMBER,
  p_sst_is_null                      IN     t_flag
) IS
  i_party_id                         t_id := t_id();
  i_flag                             t_flag := t_flag();
  total                              NUMBER := 0;
BEGIN
    i_party_id.extend(p_i_party_id.COUNT);
    i_flag.extend(p_i_party_id.COUNT);

    FOR i IN 1..p_i_party_id.COUNT LOOP
      IF p_value(i) IS NOT NULL
      THEN
        total := total + 1;
        i_party_id(total) := p_i_party_id(i);
        i_flag(total) := p_sst_is_null(i);
      END IF;
    END LOOP;

    IF p_ue_ranking = 1 THEN
      FORALL i IN 1..total
        DELETE hz_win_source_exceps
        WHERE party_id = i_party_id(i)
        AND entity_attr_id = p_entity_attr_id;
    ELSE
      FORALL i IN 1..total
        UPDATE hz_win_source_exceps exp
        SET content_source_type = 'USER_ENTERED',
            exception_type = (
              SELECT DECODE(sign(s.ranking-p_ue_ranking), 0, exp.exception_type,
                            1, 'Migration', -1, 'Exception')
              FROM hz_select_data_sources s
              WHERE entity_attr_id = p_entity_attr_id
              AND content_source_type = exp.content_source_type),
            last_updated_by = g_last_updated_by,
            last_update_login = g_last_update_login,
            last_update_date = SYSDATE,
            request_id = g_request_id,
            program_application_id = g_program_application_id,
            program_id = g_program_id,
            program_update_date = SYSDATE
        WHERE party_id = i_party_id(i)
        AND entity_attr_id = p_entity_attr_id;

      FORALL i IN 1..total
        INSERT INTO hz_win_source_exceps (
            party_id,
            entity_attr_id,
            content_source_type,
            exception_type,
            created_by,
            creation_date,
            last_update_login,
            last_update_date,
            last_updated_by,
            request_id,
            program_application_id,
            program_id,
            program_update_date
        ) SELECT
            i_party_id(i),
            p_entity_attr_id,
            'USER_ENTERED',
            decode(i_flag(i), '', 'Migration', 'Exception'),
            g_created_by,
            SYSDATE,
            g_last_update_login,
            SYSDATE,
            g_last_updated_by,
            g_request_id,
            g_program_application_id,
            g_program_id,
            SYSDATE
          FROM dual
          WHERE NOT EXISTS (
            SELECT 'Y'
            FROM hz_win_source_exceps
            WHERE party_id = i_party_id(i)
            AND entity_attr_id = p_entity_attr_id );
    END IF;
END update_exception_table;

/*===========================================================================+
 | PROCEDURE
 |    update_org_ue_profile
 |
 | DESCRIPTION
 |    The procedure will be called in racudc.lpc to sync. user-entered profile
 |    and sst profile when mix-n-match is seted up.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                   p_request_id
 |              OUT:
 |          IN/ OUT:
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    Jianying Huang     07/12/2002        Bug No : 2460837. Created.
 |    Sisir		 05/07/2003	   Bug No : 2970763;Before create/update
 |					   the profile hz_profile_versioning is
 |					   checked and added version_number in
 |					   insert/update clause.
 +===========================================================================*/

PROCEDURE update_org_ue_profile (
    p_request_id                    IN     NUMBER
) IS

    -- The cursor is used to select interface related value for user-entered
    -- profile.
    CURSOR c_entity IS
      SELECT /* decode(trunc(org.effective_start_date),trunc(sysdate),'U','C') create_update_flag,*/
      	     decode(fnd_profile.value ('HZ_PROFILE_VERSION'),'NEW_VERSION','C','NO_VERSION','U',
	     	decode(trunc(org.effective_start_date),trunc(sysdate),'U','C')) create_update_flag,
             org.organization_profile_id,
             org.party_id,
             -- User NVL for bug 1404725. We do not need NVL on
             -- customer name because it is a not-null column.
             -- However, for some reason we did not do NVL on
             -- customer name phonetic. Please see racudc.lpc.
             -- If we decide to do NVL on phoneic also, we need
             -- to modify both racudc.lpc and this procedure.
             -- By selecting non-NVL value here is to differentiate
             -- when customer is updating the column by passing
             -- value and when he/she does not want to update the
             -- column by setting the column to null. This information
             -- will be used when update data source exception table.
             nvl(i.jgzz_fiscal_code, org.jgzz_fiscal_code),
             i.jgzz_fiscal_code,
             decode(sst.jgzz_fiscal_code, '', 'Y', 'N'),
             i.customer_name,
             decode(sst.organization_name, '', 'Y', 'N'),
             i.customer_name_phonetic,
             decode(sst.organization_name_phonetic, '', 'Y', 'N'),
             nvl(i.cust_tax_reference, org.tax_reference),
             i.cust_tax_reference,
             decode(sst.tax_reference, '', 'Y', 'N'),nvl(org.version_number,1)+1
      FROM hz_organization_profiles org,
           hz_organization_profiles sst,
           ra_customers_interface_all i, -- Bug 4956131
           hz_cust_accounts cust,
           (SELECT min(i1.rowid) myrowid
            FROM ra_customers_interface_all i1 -- Bug 4956131
            WHERE i1.request_id = p_request_id
            AND i1.interface_status IS NULL
            AND i1.insert_update_flag='U'
            AND NVL(i1.person_flag,'N') = 'N'
            GROUP BY i1.orig_system_customer_ref) temp
      WHERE i.rowid = temp.myrowid
      AND i.request_id = p_request_id
      AND i.orig_system_customer_ref = cust.orig_system_reference
      AND cust.party_id = org.party_id
      AND org.effective_end_date is null
      AND org.actual_content_source = 'USER_ENTERED'
      AND sst.party_id = org.party_id
      AND sst.effective_end_date is null
      AND sst.actual_content_source = 'SST'
      ORDER BY create_update_flag;

    i_create_update_flag               t_flag;
    i_ue_profile_id                    t_id;
    i_party_id                         t_id;
    i_jgzz_fiscal_code                 t_varchar500;
    i1_jgzz_fiscal_code                t_varchar500;
    ss_jgzz_fiscal_code                t_flag;
    id_jgzz_fiscal_code                NUMBER;
    rk_jgzz_fiscal_code                NUMBER;
    i_organization_name                t_varchar500;
    ss_organization_name               t_flag;
    id_organization_name               NUMBER;
    rk_organization_name               NUMBER;
    i_organization_name_phonetic       t_varchar500;
    ss_organization_name_phonetic      t_flag;
    id_organization_name_phonetic      NUMBER;
    rk_organization_name_phonetic      NUMBER;
    i_tax_reference                    t_varchar500;
    i1_tax_reference                   t_varchar500;
    ss_tax_reference                   t_flag;
    id_tax_reference                   NUMBER;
    rk_tax_reference                   NUMBER;
    i_version_number                   t_id;

    -- The cursor is used to return entity_attr_id for
    -- an attribute and the ranking of user-entered data
    -- source.
    CURSOR c_attributes (
      p_attribute_name                 VARCHAR2
    ) IS
      SELECT s.entity_attr_id, s.ranking
      FROM hz_entity_attributes e,
           hz_select_data_sources s
      WHERE e.attribute_name = UPPER(p_attribute_name)
      AND e.entity_attr_id = s.entity_attr_id
      AND s.content_source_type = 'USER_ENTERED';

    l_entity_attr_id                   NUMBER;
    l_enabled                          VARCHAR2(1);
    subtotal                           NUMBER := 0;
    create_start                       NUMBER := 0;
    create_end                         NUMBER := 0;
    update_start                       NUMBER := 0;
    update_end                         NUMBER := 0;
    rows                               NUMBER := 500;
    l_last_fetch                       BOOLEAN := FALSE;

BEGIN

    -- check if mix-n-match is set up on hz_organization_profiles.
    l_enabled :=
      HZ_MIXNM_UTILITY.isMixNMatchEnabled(
        'HZ_ORGANIZATION_PROFILES', l_entity_attr_id);
    IF l_enabled = 'N' THEN
      RETURN;
    END IF;

    -- disable policy function.
    hz_common_pub.disable_cont_source_security;

    -- reset who-column.
    reset_who;

    l_last_fetch := FALSE;

    OPEN c_entity;
    LOOP
      <<myfetch>>
      FETCH c_entity BULK COLLECT INTO
        i_create_update_flag,
        i_ue_profile_id,
        i_party_id,
        i_jgzz_fiscal_code,
        i1_jgzz_fiscal_code,
        ss_jgzz_fiscal_code,
        i_organization_name,
        ss_organization_name,
        i_organization_name_phonetic,
        ss_organization_name_phonetic,
        i_tax_reference,
        i1_tax_reference,
        ss_tax_reference,
	i_version_number LIMIT rows;

      subtotal := i_party_id.COUNT;
      IF c_entity%NOTFOUND THEN
        l_last_fetch := TRUE;
      END IF;
      IF subtotal = 0 AND l_last_fetch THEN
        EXIT;
      END IF;
      IF subtotal = 0 THEN
        GOTO myfetch;
      END IF;

      -- split parties for which we need to create new user-entered
      -- profiles for date tracking purpose and for which we need to
      -- update existing user-entered profiles.

      create_start := 0;  create_end := -1;
      update_start := 0;  update_end := -1;

      FOR i IN 1..subtotal LOOP
        IF i_create_update_flag(i) = 'C' THEN
          IF create_start = 0 THEN create_start := i; END IF;
        ELSE
          IF update_start = 0 THEN
            update_start := i;
            IF create_start > 0 THEN create_end := i-1; END IF;
          END IF;
          EXIT;
        END IF;
      END LOOP;
      IF create_start > 0 AND create_end = -1 THEN create_end := subtotal; END IF;
      IF update_start > 0 AND update_end = -1 THEN update_end := subtotal; END IF;

      -- end-dated user-entered profiles for which we need to create new.

      FORALL i IN create_start..create_end
        UPDATE hz_organization_profiles
        SET effective_end_date = decode(trunc(effective_start_date),trunc(sysdate),trunc(sysdate),TRUNC(SYSDATE-1))
        WHERE organization_profile_id = i_ue_profile_id(i);

      -- create new user entered profiles

      FORALL i IN create_start..create_end
        INSERT INTO hz_organization_profiles (
          created_by,
          creation_date,
          last_update_login,
          last_update_date,
          last_updated_by,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          content_source_type,
          actual_content_source,
          created_by_module,
          application_id,
          organization_profile_id,
          party_id,
          effective_start_date,
          object_version_number,
          jgzz_fiscal_code,
          organization_name,
          organization_name_phonetic,
          tax_reference,
	  version_number
        ) VALUES (
          g_created_by,
          SYSDATE,
          g_last_update_login,
          SYSDATE,
          g_last_updated_by,
          g_request_id,
          g_program_application_id,
          g_program_id,
          SYSDATE,
          'USER_ENTERED',
          'USER_ENTERED',
          'TCA-CUSTOMER-INTERFACE',
          222,
          hz_organization_profiles_s.nextval,
          i_party_id(i),
          SYSDATE,
          1,
          i_jgzz_fiscal_code(i),
          i_organization_name(i),
          i_organization_name_phonetic(i),
          i_tax_reference(i),
	  i_version_number(i)
      );

      -- update user entered profiles

      FORALL i IN update_start..update_end
        UPDATE hz_organization_profiles
        SET
          last_updated_by = g_last_updated_by,
          last_update_login = g_last_update_login,
          last_update_date = SYSDATE,
          request_id = g_request_id,
          program_application_id = g_program_application_id,
          program_id = g_program_id,
          program_update_date = SYSDATE,
          jgzz_fiscal_code = i_jgzz_fiscal_code(i),
          organization_name = i_organization_name(i),
          organization_name_phonetic = i_organization_name_phonetic(i),
          tax_reference = i_tax_reference(i),
	  version_number = nvl(version_number,1)+1
      WHERE organization_profile_id = i_ue_profile_id(i);

      -- update exception for jgzz_fiscal_code
      OPEN c_attributes('JGZZ_FISCAL_CODE');
      FETCH c_attributes INTO id_jgzz_fiscal_code, rk_jgzz_fiscal_code;
      IF c_attributes%FOUND THEN
        update_exception_table(i_party_id,id_jgzz_fiscal_code,i1_jgzz_fiscal_code,rk_jgzz_fiscal_code,ss_jgzz_fiscal_code);
      END IF;
      CLOSE c_attributes;

      -- update exception for organization_name
      OPEN c_attributes('ORGANIZATION_NAME');
      FETCH c_attributes INTO id_organization_name, rk_organization_name;
      IF c_attributes%FOUND THEN
        update_exception_table(i_party_id,id_organization_name,i_organization_name,rk_organization_name,ss_organization_name);
      END IF;
      CLOSE c_attributes;

      -- update exception for organization_name_phonetic
      OPEN c_attributes('ORGANIZATION_NAME_PHONETIC');
      FETCH c_attributes INTO id_organization_name_phonetic, rk_organization_name_phonetic;
      IF c_attributes%FOUND THEN
        update_exception_table(i_party_id,id_organization_name_phonetic,i_organization_name_phonetic,rk_organization_name_phonetic,ss_organization_name_phonetic);
      END IF;
      CLOSE c_attributes;

      -- update exception for tax_reference
      OPEN c_attributes('TAX_REFERENCE');
      FETCH c_attributes INTO id_tax_reference, rk_tax_reference;
      IF c_attributes%FOUND THEN
        update_exception_table(i_party_id,id_tax_reference,i1_tax_reference,rk_tax_reference,ss_tax_reference);
      END IF;
      CLOSE c_attributes;

      IF l_last_fetch = TRUE THEN
        EXIT;
      END IF;
    END LOOP;
    CLOSE c_entity;

    -- enable policy function.
    hz_common_pub.enable_cont_source_security;

END update_org_ue_profile;

/*===========================================================================+
 | PROCEDURE
 |    update_per_ue_profile
 |
 | DESCRIPTION
 |    The procedure will be called in racudc.lpc to sync. user-entered profile
 |    and sst profile when mix-n-match is seted up.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                   p_request_id
 |              OUT:
 |          IN/ OUT:
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    Jianying Huang     07/12/2002        Bug No : 2460837. Created.
 |    Sisir		 06/09/2003	   Bug No : 2970763 Added additional
 |					   clause of hz_profile_version in decode
 |					   stmt and also added version_number
 |					   column in the select clause.
 +===========================================================================*/

PROCEDURE update_per_ue_profile (
    p_request_id                    IN     NUMBER
) IS

    -- The cursor is used to select interface related value for user-entered
    -- profile.
    CURSOR c_entity IS
      SELECT /* decode(trunc(per.effective_start_date),trunc(sysdate),'U','C') create_update_flag, */
      	     decode(fnd_profile.value ('HZ_PROFILE_VERSION'),'NEW_VERSION','C','NO_VERSION','U',
	     	decode(trunc(per.effective_start_date),trunc(sysdate),'U','C')) create_update_flag,
             per.person_profile_id,
             per.party_id,
             -- User NVL for bug 1404725 when we have to take
             -- value from hz_person_profiles. By selecting
             -- non-NVL value here is to differentiate when
             -- customer is updating the column by passing value
             -- and when he/she does not want to update the column
             -- by setting the column to null. This information
             -- will be used when update data source exception table.
             nvl(i.jgzz_fiscal_code, per.jgzz_fiscal_code),
             i.jgzz_fiscal_code,
             decode(sst.jgzz_fiscal_code, '', 'Y', 'N'),
             i.customer_name,
             decode(sst.person_name, '', 'Y', 'N'),
             decode(i.person_first_name,'',decode(i.person_last_name,'',substrb(i.customer_name,1,150),''),i.person_first_name),
             decode(sst.person_first_name, '', 'Y', 'N'),
             nvl(i.person_last_name, per.person_last_name),
             i.person_last_name,
             decode(sst.person_last_name, '', 'Y', 'N'),
             nvl(i.customer_name_phonetic, per.person_name_phonetic),
             i.customer_name_phonetic,
             decode(sst.person_name_phonetic, '', 'Y', 'N'),
             decode(nvl(i.person_flag,'N'),'Y',i.customer_name_phonetic,''),
             decode(sst.person_first_name_phonetic, '', 'Y', 'N'),
             decode(nvl(i.person_flag,'N'),'Y',i.customer_name_phonetic,''),
             decode(sst.person_last_name_phonetic, '', 'Y', 'N'),
             nvl(i.cust_tax_reference, per.tax_reference),
             i.cust_tax_reference,
             decode(sst.tax_reference, '', 'Y', 'N'),nvl(per.version_number,1)+1
      FROM hz_person_profiles per,
           hz_person_profiles sst,
           ra_customers_interface_all i, -- Bug 4956131
           hz_cust_accounts cust,
           (SELECT min(i1.rowid) myrowid
            FROM ra_customers_interface_all i1 -- Bug 4956131
            WHERE i1.request_id = p_request_id
            AND i1.interface_status IS NULL
            AND i1.insert_update_flag='U'
            AND i1.person_flag = 'Y'
            GROUP BY i1.orig_system_customer_ref) temp
      WHERE i.rowid = temp.myrowid
      AND i.request_id = p_request_id
      AND i.orig_system_customer_ref = cust.orig_system_reference
      AND cust.party_id = per.party_id
      AND per.effective_end_date is null
      AND per.actual_content_source = 'USER_ENTERED'
      AND sst.party_id = per.party_id
      AND sst.effective_end_date is null
      AND sst.actual_content_source = 'SST'
      ORDER BY create_update_flag;

    i_create_update_flag               t_flag;
    i_ue_profile_id                    t_id;
    i_party_id                         t_id;
    i_jgzz_fiscal_code                 t_varchar500;
    i1_jgzz_fiscal_code                t_varchar500;
    ss_jgzz_fiscal_code                t_flag;
    id_jgzz_fiscal_code                NUMBER;
    rk_jgzz_fiscal_code                NUMBER;
    i_person_name                      t_varchar500;
    ss_person_name                     t_flag;
    id_person_name                     NUMBER;
    rk_person_name                     NUMBER;
    i_person_first_name                t_varchar500;
    ss_person_first_name               t_flag;
    id_person_first_name               NUMBER;
    rk_person_first_name               NUMBER;
    i_person_last_name                 t_varchar500;
    i1_person_last_name                t_varchar500;
    ss_person_last_name                t_flag;
    id_person_last_name                NUMBER;
    rk_person_last_name                NUMBER;
    i_person_name_phonetic             t_varchar500;
    i1_person_name_phonetic            t_varchar500;
    ss_person_name_phonetic            t_flag;
    id_person_name_phonetic            NUMBER;
    rk_person_name_phonetic            NUMBER;
    i_person_first_name_phonetic       t_varchar500;
    ss_person_first_name_phonetic      t_flag;
    id_person_first_name_phonetic      NUMBER;
    rk_person_first_name_phonetic      NUMBER;
    i_person_last_name_phonetic        t_varchar500;
    ss_person_last_name_phonetic       t_flag;
    id_person_last_name_phonetic       NUMBER;
    rk_person_last_name_phonetic       NUMBER;
    i_tax_reference                    t_varchar500;
    i1_tax_reference                   t_varchar500;
    ss_tax_reference                   t_flag;
    id_tax_reference                   NUMBER;
    rk_tax_reference                   NUMBER;
    i_version_number		       t_id;

    -- The cursor is used to return entity_attr_id for
    -- an attribute and the ranking of user-entered data
    -- source.
    CURSOR c_attributes (
      p_attribute_name                 VARCHAR2
    ) IS
      SELECT s.entity_attr_id, s.ranking
      FROM hz_entity_attributes e,
           hz_select_data_sources s
      WHERE e.attribute_name = UPPER(p_attribute_name)
      AND e.entity_attr_id = s.entity_attr_id
      AND s.content_source_type = 'USER_ENTERED';

    l_entity_attr_id                   NUMBER;
    l_enabled                          VARCHAR2(1);
    subtotal                           NUMBER := 0;
    create_start                       NUMBER := 0;
    create_end                         NUMBER := 0;
    update_start                       NUMBER := 0;
    update_end                         NUMBER := 0;
    rows                               NUMBER := 500;
    l_last_fetch                       BOOLEAN := FALSE;

BEGIN

    -- check if mix-n-match is set up on hz_person_profiles.
    l_enabled :=
      HZ_MIXNM_UTILITY.isMixNMatchEnabled(
        'HZ_PERSON_PROFILES', l_entity_attr_id);
    IF l_enabled = 'N' THEN
      RETURN;
    END IF;

    -- disable policy function.
    hz_common_pub.disable_cont_source_security;

    -- reset who-column.
    reset_who;

    l_last_fetch := FALSE;

    OPEN c_entity;
    LOOP
      <<myfetch>>
      FETCH c_entity BULK COLLECT INTO
        i_create_update_flag,
        i_ue_profile_id,
        i_party_id,
        i_jgzz_fiscal_code,
        i1_jgzz_fiscal_code,
        ss_jgzz_fiscal_code,
        i_person_name,
        ss_person_name,
        i_person_first_name,
        ss_person_first_name,
        i_person_last_name,
        i1_person_last_name,
        ss_person_last_name,
        i_person_name_phonetic,
        i1_person_name_phonetic,
        ss_person_name_phonetic,
        i_person_first_name_phonetic,
        ss_person_first_name_phonetic,
        i_person_last_name_phonetic,
        ss_person_last_name_phonetic,
        i_tax_reference,
        i1_tax_reference,
        ss_tax_reference,
	i_version_number LIMIT rows;

      subtotal := i_party_id.COUNT;
      IF c_entity%NOTFOUND THEN
        l_last_fetch := TRUE;
      END IF;
      IF subtotal = 0 AND l_last_fetch THEN
        EXIT;
      END IF;
      IF subtotal = 0 THEN
        GOTO myfetch;
      END IF;

      -- split parties for which we need to create new user-entered
      -- profiles for date tracking purpose and for which we need to
      -- update existing user-entered profiles.

      create_start := 0;  create_end := -1;
      update_start := 0;  update_end := -1;

      FOR i IN 1..subtotal LOOP
        IF i_create_update_flag(i) = 'C' THEN
          IF create_start = 0 THEN create_start := i; END IF;
        ELSE
          IF update_start = 0 THEN
            update_start := i;
            IF create_start > 0 THEN create_end := i-1; END IF;
          END IF;
          EXIT;
        END IF;
      END LOOP;
      IF create_start > 0 AND create_end = -1 THEN create_end := subtotal; END IF;
      IF update_start > 0 AND update_end = -1 THEN update_end := subtotal; END IF;

      -- end-dated user-entered profiles for which we need to create new.

      FORALL i IN create_start..create_end
        UPDATE hz_person_profiles
        SET effective_end_date = decode(trunc(effective_start_date),trunc(sysdate),trunc(sysdate),TRUNC(SYSDATE-1))
        WHERE person_profile_id = i_ue_profile_id(i);

      -- create new user entered profiles

      FORALL i IN create_start..create_end
        INSERT INTO hz_person_profiles (
          created_by,
          creation_date,
          last_update_login,
          last_update_date,
          last_updated_by,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          content_source_type,
          actual_content_source,
          created_by_module,
          application_id,
          person_profile_id,
          party_id,
          effective_start_date,
          object_version_number,
          jgzz_fiscal_code,
          person_name,
          person_first_name,
          person_last_name,
          person_name_phonetic,
          person_first_name_phonetic,
          person_last_name_phonetic,
          tax_reference,
	  version_number
        ) VALUES (
          g_created_by,
          SYSDATE,
          g_last_update_login,
          SYSDATE,
          g_last_updated_by,
          g_request_id,
          g_program_application_id,
          g_program_id,
          SYSDATE,
          'USER_ENTERED',
          'USER_ENTERED',
          'TCA-CUSTOMER-INTERFACE',
          222,
          hz_person_profiles_s.nextval,
          i_party_id(i),
          SYSDATE,
          1,
          i_jgzz_fiscal_code(i),
          i_person_name(i),
          i_person_first_name(i),
          i_person_last_name(i),
          i_person_name_phonetic(i),
          i_person_first_name_phonetic(i),
          i_person_last_name_phonetic(i),
          i_tax_reference(i),
	  i_version_number(i)
      );

      -- update user entered profiles

      FORALL i IN update_start..update_end
        UPDATE hz_person_profiles
        SET
          last_updated_by = g_last_updated_by,
          last_update_login = g_last_update_login,
          last_update_date = SYSDATE,
          request_id = g_request_id,
          program_application_id = g_program_application_id,
          program_id = g_program_id,
          program_update_date = SYSDATE,
          jgzz_fiscal_code = i_jgzz_fiscal_code(i),
          person_name = i_person_name(i),
          person_first_name = i_person_first_name(i),
          person_last_name = i_person_last_name(i),
          person_name_phonetic = i_person_name_phonetic(i),
          person_first_name_phonetic = i_person_first_name_phonetic(i),
          person_last_name_phonetic = i_person_last_name_phonetic(i),
          tax_reference = i_tax_reference(i),
	  version_number = nvl(version_number,1)+1
      WHERE person_profile_id = i_ue_profile_id(i);

      -- update exception for jgzz_fiscal_code
      OPEN c_attributes('JGZZ_FISCAL_CODE');
      FETCH c_attributes INTO id_jgzz_fiscal_code, rk_jgzz_fiscal_code;
      IF c_attributes%FOUND THEN
        update_exception_table(i_party_id,id_jgzz_fiscal_code,i1_jgzz_fiscal_code,rk_jgzz_fiscal_code,ss_jgzz_fiscal_code);
      END IF;
      CLOSE c_attributes;

      -- update exception for person_name
      OPEN c_attributes('PERSON_NAME');
      FETCH c_attributes INTO id_person_name, rk_person_name;
      IF c_attributes%FOUND THEN
        update_exception_table(i_party_id,id_person_name,i_person_name,rk_person_name,ss_person_name);
      END IF;
      CLOSE c_attributes;

      -- update exception for person_first_name
      OPEN c_attributes('PERSON_FIRST_NAME');
      FETCH c_attributes INTO id_person_first_name, rk_person_first_name;
      IF c_attributes%FOUND THEN
        update_exception_table(i_party_id,id_person_first_name,i_person_first_name,rk_person_first_name,ss_person_first_name);
      END IF;
      CLOSE c_attributes;

      -- update exception for person_last_name
      OPEN c_attributes('PERSON_LAST_NAME');
      FETCH c_attributes INTO id_person_last_name, rk_person_last_name;
      IF c_attributes%FOUND THEN
        update_exception_table(i_party_id,id_person_last_name,i1_person_last_name,rk_person_last_name,ss_person_last_name);
      END IF;
      CLOSE c_attributes;

      -- update exception for person_name_phonetic
      OPEN c_attributes('PERSON_NAME_PHONETIC');
      FETCH c_attributes INTO id_person_name_phonetic, rk_person_name_phonetic;
      IF c_attributes%FOUND THEN
        update_exception_table(i_party_id,id_person_name_phonetic,i1_person_name_phonetic,rk_person_name_phonetic,ss_person_name_phonetic);
      END IF;
      CLOSE c_attributes;

      -- update exception for person_first_name_phonetic
      OPEN c_attributes('PERSON_FIRST_NAME_PHONETIC');
      FETCH c_attributes INTO id_person_first_name_phonetic, rk_person_first_name_phonetic;
      IF c_attributes%FOUND THEN
        update_exception_table(i_party_id,id_person_first_name_phonetic,i_person_first_name_phonetic,rk_person_first_name_phonetic,ss_person_first_name_phonetic);
      END IF;
      CLOSE c_attributes;

      -- update exception for person_last_name_phonetic
      OPEN c_attributes('PERSON_LAST_NAME_PHONETIC');
      FETCH c_attributes INTO id_person_last_name_phonetic, rk_person_last_name_phonetic;
      IF c_attributes%FOUND THEN
        update_exception_table(i_party_id,id_person_last_name_phonetic,i_person_last_name_phonetic,rk_person_last_name_phonetic,ss_person_last_name_phonetic);
      END IF;
      CLOSE c_attributes;

      -- update exception for tax_reference
      OPEN c_attributes('TAX_REFERENCE');
      FETCH c_attributes INTO id_tax_reference, rk_tax_reference;
      IF c_attributes%FOUND THEN
        update_exception_table(i_party_id,id_tax_reference,i1_tax_reference,rk_tax_reference,ss_tax_reference);
      END IF;
      CLOSE c_attributes;

      IF l_last_fetch = TRUE THEN
        EXIT;
      END IF;
    END LOOP;
    CLOSE c_entity;

    -- enable policy function.
    hz_common_pub.enable_cont_source_security;

END update_per_ue_profile;

/*===========================================================================+
 | FUNCTION
 |    validate_primary_flag
 |
 | DESCRIPTION
 |    Validating Primary site use flag.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN: p_orig_system_customer_ref
                    p_site_use_code
 |              OUT:
 |          IN/ OUT:
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    Rajeshwari P      03/21/2003      Bug No : 2802126. Created.
 |    Rajesh Jose	04/06/2004	Bug 3535808. The cursor returns
 |					incorrect data when a 'DUN', 'LEGAL' or
 |					'STMTS' site has been inactivated.
 |
 +===========================================================================*/
/* bug 4454799 - added argument for org_id below. */
FUNCTION validate_primary_flag( p_orig_system_customer_ref IN VARCHAR2,
                                p_site_use_code IN VARCHAR2,
	                        p_org_id IN NUMBER )
  RETURN VARCHAR2 IS

  primaryflag VARCHAR2(100);

/* 3535808. Modified cursor. */
/* 4588090. Modified site use condition in the cursor. */
CURSOR pflag is
SELECT su.primary_flag
FROM hz_cust_accounts cust,
     hz_cust_acct_sites_all site, -- bug 4454799
     hz_cust_site_uses_all su  -- bug 4454799
WHERE cust.orig_system_reference = p_orig_system_customer_ref
and  cust.cust_account_id = site.cust_account_id
and  site.cust_acct_site_id = su.cust_acct_site_id
and  site.org_id = p_org_id  -- bug 4454799
and  site.org_id = su.org_id -- bug 4454799
and  su.site_use_code in ('STMTS','DUN','LEGAL')
and  su.site_use_code = p_site_use_code
and  su.status = 'A'
and  rownum = 1;


BEGIN
open pflag;
   fetch pflag into primaryflag;
   close pflag;
 RETURN primaryflag;
EXCEPTION
    WHEN NO_DATA_FOUND  THEN
      RETURN null;
    WHEN OTHERS THEN
      RAISE;

END validate_primary_flag;
/*===========================================================================+
 | FUNCTION
 |    set_primary_flag
 |
 | DESCRIPTION
 |    Updating Primary site use flag appropriately.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN: p_orig_system_customer_ref
                    p_site_use_code
 |              OUT:
 |          IN/ OUT:
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    Kalyan      10/30/2005      Bug No : 4588090. Created.
 |
 +===========================================================================*/
PROCEDURE set_primary_flag( p_orig_system_customer_ref IN VARCHAR2,
                            p_site_use_code IN VARCHAR2,
                            p_org_id        IN NUMBER)
IS
  l_acct_site_id hz_cust_acct_sites_all.cust_acct_site_id%TYPE;
  l_site_use_id  hz_cust_site_uses_all.site_use_id%TYPE;

CURSOR pflag is
SELECT site.cust_acct_site_id,suse.site_use_id
FROM   hz_cust_accounts       cust,
       hz_cust_acct_sites_all site,
       hz_cust_site_uses_all  suse
WHERE  cust.orig_system_reference = p_orig_system_customer_ref
and    cust.cust_account_id   = site.cust_account_id
and    site.cust_acct_site_id = suse.cust_acct_site_id
and    site.org_id = p_org_id  -- bug 4454799
and    site.org_id = suse.org_id -- bug 4454799
and    suse.site_use_code = p_site_use_code
and    suse.status = 'A'
and    suse.primary_flag = 'Y'
and    rownum = 1;

BEGIN
   open pflag;
   fetch pflag into l_acct_site_id,l_site_use_id;
   IF pflag%FOUND THEN
      update hz_cust_site_uses_all
      set    primary_flag           = 'N',
             last_update_login      = hz_utility_v2pub.last_update_login,
             last_update_date       = SYSDATE,
             last_updated_by        = hz_utility_v2pub.last_updated_by,
             request_id             = hz_utility_v2pub.request_id,
             program_application_id = hz_utility_v2pub.program_application_id,
             program_id             = hz_utility_v2pub.program_id
      where  site_use_id = l_site_use_id;

      update hz_cust_acct_sites_all
      set    BILL_TO_FLAG = decode(p_site_use_code,'BILL_TO','Y',BILL_TO_FLAG),
             SHIP_TO_FLAG = decode(p_site_use_code,'SHIP_TO','Y',SHIP_TO_FLAG),
             MARKET_FLAG  = decode(p_site_use_code,'MARKET','Y',MARKET_FLAG),
             last_update_login      = hz_utility_v2pub.last_update_login,
             last_update_date       = SYSDATE,
             last_updated_by        = hz_utility_v2pub.last_updated_by,
             request_id             = hz_utility_v2pub.request_id,
             program_application_id = hz_utility_v2pub.program_application_id,
             program_id             = hz_utility_v2pub.program_id
      where  cust_acct_site_id = l_acct_site_id;

   END IF;
   close pflag;

EXCEPTION
    WHEN OTHERS THEN
      RAISE;
END set_primary_flag;

PROCEDURE sync_tax_profile
(
  p_request_id                    IN NUMBER
)
IS

BEGIN

-- Import Party
  MERGE INTO ZX_PARTY_TAX_PROFILE PTP
  USING
       (SELECT  'THIRD_PARTY' PARTY_TYPE_CODE,
                party.party_id PARTY_ID,
                party.country COUNTRY_CODE, --4742586
                FND_GLOBAL.Login_ID PROGRAM_LOGIN_ID ,
                party.tax_reference TAX_REFERENCE,
                SYSDATE CREATION_DATE,
                FND_GLOBAL.User_ID CREATED_BY,
                SYSDATE LAST_UPDATE_DATE,
                FND_GLOBAL.User_ID LAST_UPDATED_BY,
                FND_GLOBAL.Login_ID LAST_UPDATE_LOGIN
        FROM	HZ_PARTIES party, ra_customers_interface_all rci -- Bug 4956131
        WHERE   party.orig_system_reference = nvl(rci.orig_system_party_ref, rci.orig_system_customer_ref)
      	AND     party.request_id =  p_request_id
      	AND     rci.interface_status is null
        AND     rci.request_id = p_request_id
        AND     rci.insert_update_flag  = 'I'
	AND 	(rci.rowid = (  SELECT min(i2.rowid)
                                FROM   ra_customers_interface_all i2 -- Bug 4956131
                                WHERE  i2.orig_system_customer_ref = rci.orig_system_customer_ref
	                        AND    rci.orig_system_party_ref is null
                                AND    i2.interface_status is null
                                AND    i2.request_id = p_request_id
                                AND    i2.insert_update_flag = 'I') OR
                 rci.rowid = (  SELECT min(i2.rowid)
                                FROM   ra_customers_interface_all i2 -- Bug 4956131
                                WHERE  i2.orig_system_party_ref = rci.orig_system_party_ref
                                AND    i2.interface_status is null
                                AND    i2.request_id = p_request_id
                                AND    i2.insert_update_flag = 'I'))
        AND      (party.party_type ='ORGANIZATION' OR party.party_type ='PERSON')) PTY
   ON  (PTY.PARTY_ID = PTP.PARTY_ID AND PTP.PARTY_TYPE_CODE = 'THIRD_PARTY')
   WHEN MATCHED THEN
        UPDATE SET
        PTP.REP_REGISTRATION_NUMBER = PTY.TAX_REFERENCE,
        PTP.LAST_UPDATE_DATE=PTY.LAST_UPDATE_DATE,
        PTP.LAST_UPDATED_BY=PTY.LAST_UPDATED_BY,
        PTP.LAST_UPDATE_LOGIN=PTY.LAST_UPDATE_LOGIN,
        PTP.PROGRAM_ID = hz_utility_v2pub.program_id,
        PTP.PROGRAM_APPLICATION_ID = hz_utility_v2pub.program_application_id,
        PTP.REQUEST_ID = p_request_id,
        PTP.OBJECT_VERSION_NUMBER = PTP.OBJECT_VERSION_NUMBER +1
   WHEN NOT MATCHED THEN
        INSERT (PARTY_TYPE_CODE,
                PARTY_TAX_PROFILE_ID,
                PARTY_ID,
                PROGRAM_LOGIN_ID,
                REP_REGISTRATION_NUMBER,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                PROGRAM_ID,
                PROGRAM_APPLICATION_ID,
                REQUEST_ID,
                OBJECT_VERSION_NUMBER,
                COUNTRY_CODE)--4742586
        VALUES (PTY.PARTY_TYPE_CODE,
                ZX_PARTY_TAX_PROFILE_S.NEXTVAL,
                PTY.PARTY_ID,
                PTY.PROGRAM_LOGIN_ID,
                PTY.TAX_REFERENCE,
                PTY.CREATION_DATE,
                PTY.CREATED_BY,
                PTY.LAST_UPDATE_DATE,
                PTY.LAST_UPDATED_BY,
                PTY.LAST_UPDATE_LOGIN,
                hz_utility_v2pub.program_id,
                hz_utility_v2pub.program_application_id,
                p_request_id,
                1,
                PTY.COUNTRY_CODE );--4742586

-- Bug 6682585
-- Insert Contact Person Parties
 MERGE INTO ZX_PARTY_TAX_PROFILE PTP
  USING
       (SELECT  'THIRD_PARTY' PARTY_TYPE_CODE,
                party.party_id PARTY_ID,
                party.country COUNTRY_CODE,
                FND_GLOBAL.Login_ID PROGRAM_LOGIN_ID ,
                party.tax_reference TAX_REFERENCE,
                SYSDATE CREATION_DATE,
                FND_GLOBAL.User_ID CREATED_BY,
                SYSDATE LAST_UPDATE_DATE,
                FND_GLOBAL.User_ID LAST_UPDATED_BY,
                FND_GLOBAL.Login_ID LAST_UPDATE_LOGIN
        FROM    HZ_PARTIES party, RA_CONTACT_PHONES_INT_ALL rcpi
        WHERE   party.orig_system_reference =  rcpi.orig_system_contact_ref
        AND     party.request_id =  p_request_id
        AND     rcpi.interface_status is null
        AND     rcpi.request_id = p_request_id
        AND     rcpi.insert_update_flag  = 'I'
        AND     rcpi.rowid = (  SELECT min(i2.rowid)
                                FROM   RA_CONTACT_PHONES_INT_ALL i2
                                WHERE  i2.orig_system_contact_ref = rcpi.orig_system_contact_ref
                                AND    i2.interface_status is null
                                AND    i2.request_id = p_request_id
                                AND    i2.insert_update_flag = 'I')
        AND      party.party_type ='PERSON') PTY
   ON  (PTY.PARTY_ID = PTP.PARTY_ID AND PTP.PARTY_TYPE_CODE = 'THIRD_PARTY')
   WHEN MATCHED THEN
        UPDATE SET
        PTP.REP_REGISTRATION_NUMBER = PTY.TAX_REFERENCE,
        PTP.LAST_UPDATE_DATE=PTY.LAST_UPDATE_DATE,
        PTP.LAST_UPDATED_BY=PTY.LAST_UPDATED_BY,
        PTP.LAST_UPDATE_LOGIN=PTY.LAST_UPDATE_LOGIN,
        PTP.PROGRAM_ID = hz_utility_v2pub.program_id,
        PTP.PROGRAM_APPLICATION_ID = hz_utility_v2pub.program_application_id,
        PTP.REQUEST_ID = p_request_id,
        PTP.OBJECT_VERSION_NUMBER = PTP.OBJECT_VERSION_NUMBER +1
   WHEN NOT MATCHED THEN
        INSERT (PARTY_TYPE_CODE,
                PARTY_TAX_PROFILE_ID,
                PARTY_ID,
                PROGRAM_LOGIN_ID,
                REP_REGISTRATION_NUMBER,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                PROGRAM_ID,
          	PROGRAM_APPLICATION_ID,
                REQUEST_ID,
                OBJECT_VERSION_NUMBER,
                COUNTRY_CODE)
        VALUES (PTY.PARTY_TYPE_CODE,
                ZX_PARTY_TAX_PROFILE_S.NEXTVAL,
                PTY.PARTY_ID,
                PTY.PROGRAM_LOGIN_ID,
                PTY.TAX_REFERENCE,
                PTY.CREATION_DATE,
                PTY.CREATED_BY,
                PTY.LAST_UPDATE_DATE,
                PTY.LAST_UPDATED_BY,
                PTY.LAST_UPDATE_LOGIN,
                hz_utility_v2pub.program_id,
         	hz_utility_v2pub.program_application_id,
                p_request_id,
                1,
                PTY.COUNTRY_CODE );



-- Import Party Sites
  MERGE INTO ZX_PARTY_TAX_PROFILE PTP
  USING
       (SELECT  'THIRD_PARTY_SITE' PARTY_TYPE_CODE,
                ps.party_site_id PARTY_ID,
                loc.country COUNTRY_CODE,--4742586
                FND_GLOBAL.Login_ID PROGRAM_LOGIN_ID ,
                NULL TAX_REFERENCE,
                SYSDATE CREATION_DATE,
                FND_GLOBAL.User_ID CREATED_BY,
                SYSDATE LAST_UPDATE_DATE,
                FND_GLOBAL.User_ID LAST_UPDATED_BY,
                FND_GLOBAL.Login_ID LAST_UPDATE_LOGIN
        FROM    HZ_PARTY_SITES ps, ra_customers_interface_all rci, -- Bug 4956131
                HZ_LOCATIONS loc --4742586
        WHERE   ps.orig_system_reference = rci.orig_system_address_ref
        AND     loc.location_id = ps.location_id --4742586
      	AND     ps.request_id =  p_request_id
      	AND     rci.interface_status is null
        AND     rci.request_id = p_request_id
        AND     rci.insert_update_flag  = 'I'
	AND 	(rci.rowid = (  SELECT min(i2.rowid)
                                FROM   ra_customers_interface_all i2 -- Bug 4956131
                                WHERE  i2.orig_system_address_ref = rci.orig_system_address_ref
                                AND    i2.interface_status is null
                                AND    i2.request_id = p_request_id
                                AND    i2.insert_update_flag = 'I'))) PTY
  ON  (PTY.PARTY_ID = PTP.PARTY_ID AND PTP.PARTY_TYPE_CODE = 'THIRD_PARTY_SITE')
  WHEN MATCHED THEN
       UPDATE SET
        PTP.LAST_UPDATE_DATE=PTY.LAST_UPDATE_DATE,
        PTP.LAST_UPDATED_BY=PTY.LAST_UPDATED_BY,
        PTP.LAST_UPDATE_LOGIN=PTY.LAST_UPDATE_LOGIN,
        PTP.PROGRAM_ID = hz_utility_v2pub.program_id,
        PTP.PROGRAM_APPLICATION_ID = hz_utility_v2pub.program_application_id,
        PTP.REQUEST_ID = p_request_id,
        PTP.OBJECT_VERSION_NUMBER = PTP.OBJECT_VERSION_NUMBER +1
  WHEN NOT MATCHED THEN
       INSERT (
        PARTY_TYPE_CODE,
        PARTY_TAX_PROFILE_ID,
        PARTY_ID,
        PROGRAM_LOGIN_ID,
        REP_REGISTRATION_NUMBER,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        PROGRAM_ID,
      	PROGRAM_APPLICATION_ID,
        REQUEST_ID,
        OBJECT_VERSION_NUMBER,
        COUNTRY_CODE)--4742586
       VALUES (
        PTY.PARTY_TYPE_CODE,
        ZX_PARTY_TAX_PROFILE_S.NEXTVAL,
        PTY.PARTY_ID,
        PTY.PROGRAM_LOGIN_ID,
        PTY.TAX_REFERENCE,
        PTY.CREATION_DATE,
        PTY.CREATED_BY,
        PTY.LAST_UPDATE_DATE,
        PTY.LAST_UPDATED_BY,
        PTY.LAST_UPDATE_LOGIN,
	hz_utility_v2pub.program_id,
	hz_utility_v2pub.program_application_id,
	p_request_id,
        1,
        PTY.COUNTRY_CODE);--4742586
--COMMIT;

END sync_tax_profile;

PROCEDURE insert_ci_party_usages
(
  p_request_id                    IN NUMBER
)
IS

BEGIN
INSERT INTO hz_party_usg_assignments(
              PARTY_USG_ASSIGNMENT_ID
             ,PARTY_ID
             ,PARTY_USAGE_CODE
             ,EFFECTIVE_START_DATE
             ,EFFECTIVE_END_DATE
             ,STATUS_FLAG
             ,COMMENTS
             ,OWNER_TABLE_NAME
             ,OWNER_TABLE_ID
             ,OBJECT_VERSION_NUMBER
             ,CREATED_BY_MODULE
             ,APPLICATION_ID
             ,CREATED_BY
             ,CREATION_DATE
             ,LAST_UPDATE_LOGIN
             ,LAST_UPDATE_DATE
             ,LAST_UPDATED_BY
             ,REQUEST_ID
             ,PROGRAM_APPLICATION_ID
             ,PROGRAM_ID )
    SELECT    hz_party_usg_assignments_s.nextval      -- PARTY_USG_ASSIGNMENT_ID
             ,hzp.party_id                            -- PARTY_ID
             ,'CUSTOMER'                              -- PARTY_USAGE_CODE
             ,trunc(SYSDATE)                          -- EFFECTIVE_START_DATE
             ,decode((select min(status)
                      from   hz_cust_accounts
                      where  party_id = hzp.party_id),
                      'A',to_date('31-12-4712','DD-MM-YYYY')
                          ,trunc(SYSDATE))            -- EFFECTIVE_END_DATE
             ,(select min(status)
                      from   hz_cust_accounts
                      where  party_id = hzp.party_id) -- STATUS_FLAG
             ,''                                      -- COMMENTS
             ,''                                      -- OWNER_TABLE_NAME
             ,''                                      -- OWNER_TABLE_ID
             ,1                                       -- OBJECT_VERSION_NUMBER
             ,'CUST_INTERFACE'                        -- CREATED_BY_MODULE
             ,''                                      -- APPLICATION_ID
             ,hz_utility_v2pub.created_by             -- CREATED_BY
             , SYSDATE                                -- CREATION_DATE
             ,hz_utility_v2pub.last_update_login      -- LAST_UPDATE_LOGIN
             , SYSDATE                                -- LAST_UPDATE_DATE
             ,hz_utility_v2pub.last_updated_by        -- LAST_UPDATED_BY
             ,p_request_id                            -- REQUEST_ID
             ,hz_utility_v2pub.program_application_id -- PROGRAM_APPLICATION_ID
             ,hz_utility_v2pub.program_id             -- PROGRAM_ID
    from     ra_customers_interface  rci,
             hz_parties              hzp
    WHERE    hzp.orig_system_reference    = nvl(rci.orig_system_party_ref, rci.orig_system_customer_ref)
    and      hzp.request_id               = p_request_id
    AND      rci.interface_status        is null
    AND      rci.insert_update_flag       = 'I'
    AND      ( rci.rowid = (SELECT   min(i2.rowid)
                              FROM   ra_customers_interface i2
                              WHERE  i2.orig_system_customer_ref =
                                     rci.orig_system_customer_ref
                              and    rci.orig_system_party_ref is null
                              AND    i2.interface_status is null
                              AND    i2.insert_update_flag = 'I') OR
               rci.rowid = (SELECT   min(i2.rowid)
                             FROM    ra_customers_interface i2
                             WHERE   i2.orig_system_party_ref = rci.orig_system_party_ref
                             AND     i2.interface_status is null
                             AND     i2.insert_update_flag = 'I')
             );

END insert_ci_party_usages;

PROCEDURE insert_nci_party_usages
(
  p_request_id                    IN NUMBER
)
IS

BEGIN
INSERT INTO hz_party_usg_assignments(
              PARTY_USG_ASSIGNMENT_ID
             ,PARTY_ID
             ,PARTY_USAGE_CODE
             ,EFFECTIVE_START_DATE
             ,EFFECTIVE_END_DATE
             ,STATUS_FLAG
             ,COMMENTS
             ,OWNER_TABLE_NAME
             ,OWNER_TABLE_ID
             ,OBJECT_VERSION_NUMBER
             ,CREATED_BY_MODULE
             ,APPLICATION_ID
             ,CREATED_BY
             ,CREATION_DATE
             ,LAST_UPDATE_LOGIN
             ,LAST_UPDATE_DATE
             ,LAST_UPDATED_BY
             ,REQUEST_ID
             ,PROGRAM_APPLICATION_ID
             ,PROGRAM_ID )
    SELECT    hz_party_usg_assignments_s.nextval     -- PARTY_USG_ASSIGNMENT_ID
             ,hzp.party_id                           -- PARTY_ID
             ,'CUSTOMER'                             -- PARTY_USAGE_CODE
             ,trunc(SYSDATE)                         -- EFFECTIVE_START_DATE
             ,decode((select min(status)
                      from   hz_cust_accounts
                      where  party_id = hzp.party_id),
                      'A',to_date('31-12-4712','DD-MM-YYYY')
                          ,trunc(SYSDATE))           -- EFFECTIVE_END_DATE
             ,(select min(status)
                      from   hz_cust_accounts
                      where  party_id = hzp.party_id)-- STATUS_FLAG
             ,''                                     -- COMMENTS
             ,''                                     -- OWNER_TABLE_NAME
             ,''                                     -- OWNER_TABLE_ID
             ,1                                      -- OBJECT_VERSION_NUMBER
             ,'CUST_INTERFACE'                       -- CREATED_BY_MODULE
             ,''                                     -- APPLICATION_ID
             ,hz_utility_v2pub.created_by            -- CREATED_BY
             , SYSDATE                               -- CREATION_DATE
             ,hz_utility_v2pub.last_update_login     -- LAST_UPDATE_LOGIN
             , SYSDATE                               -- LAST_UPDATE_DATE
             ,hz_utility_v2pub.last_updated_by       -- LAST_UPDATED_BY
             ,p_request_id                           -- REQUEST_ID
             ,hz_utility_v2pub.program_application_id-- PROGRAM_APPLICATION_ID
             ,hz_utility_v2pub.program_id            -- PROGRAM_ID
    from     ra_customers_interface_all  rci, -- Bug 4956131
             hz_parties              hzp
    WHERE    hzp.party_id            = HZ_CUSTOMER_INT.get_account_party_id(rci.orig_system_party_ref,rci.person_flag,'P')
    AND      rci.request_id          = p_request_id
    AND      rci.interface_status    is null
    AND      rci.insert_update_flag  = 'I'
    AND      ( rci.rowid = (SELECT  min(i2.rowid)
                              FROM  ra_customers_interface_all i2 -- Bug 4956131
                              WHERE i2.orig_system_customer_ref =
                                    rci.orig_system_customer_ref
                              and   rci.orig_system_party_ref is null
                              AND   i2.interface_status is null
                              AND    i2.request_id = p_request_id
                              AND   i2.insert_update_flag = 'I') OR
               rci.rowid = (SELECT  min(i2.rowid)
                             FROM   ra_customers_interface_all i2 -- Bug 4956131
                             WHERE  i2.orig_system_party_ref = rci.orig_system_party_ref
                             AND    i2.request_id = p_request_id
                             AND    i2.interface_status is null
                             AND    i2.insert_update_flag = 'I')
             )
    and     not exists(     SELECT  '1'
                            FROM    hz_parties
                            WHERE   party_id = hzp.party_id
                            AND     request_id = p_request_id )
    and     not exists(
            select '1'
            from    hz_party_usg_assignments pua
            where   pua.party_id = hzp.party_id
            and     party_usage_code = 'CUSTOMER'
            and     pua.status_flag = ( select min(status)
                                        from   hz_cust_accounts
                                        where  party_id = hzp.party_id)
            and     pua.effective_start_date <= decode((select min(status)
                                                        from   hz_cust_accounts
                                                        where  party_id = hzp.party_id),
                                                               'A',trunc(SYSDATE)
                                                               ,pua.effective_start_date)
            and     nvl(pua.effective_end_date,to_date('31-12-4712','DD-MM-YYYY')) >= decode((select min(status)
                                                        from   hz_cust_accounts
                                                        where  party_id = hzp.party_id),
                                                               'A',trunc(SYSDATE)
                                                               ,nvl(pua.effective_start_date,
                                                               to_date('31-12-4712','DD-MM-YYYY')
                                                                    )));
END insert_nci_party_usages;

END hz_customer_int;

/
