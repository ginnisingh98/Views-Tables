--------------------------------------------------------
--  DDL for Package Body RA_CUSTOMER_TEXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RA_CUSTOMER_TEXT_PKG" as
/* $Header: ARXCUTXB.pls 120.21.12000000.5 2007/06/12 19:27:10 nsinghai ship $ */


/** Private Proc **/
PROCEDURE sync_index(
        p_index_name            IN     VARCHAR2,
        retcode                 OUT NOCOPY    VARCHAR2,
        err                     OUT NOCOPY    VARCHAR2) IS


BEGIN

  retcode := 0;
  err := null;

  --Call to sync index
  ad_ctx_Ddl.Sync_Index ( p_index_name );

 EXCEPTION
  WHEN OTHERS THEN
    retcode :=  1;
    err := SQLERRM;

END sync_index;



/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    update_text_addr                                                        |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure updates the address_text column of ra_addresses table    |
 |    with the concatenated customer,contacts,phones,address information      |
 |    so that interMedia index can be created on it to perform text searches. |
 |                                                                            |
 | PARAMETERS                                                                 |
 |   INPUT                                                                    |
 |                                                                            |
 |                                                                            |
 |   OUTPUT                                                                   |
 |      Errbuf                  VARCHAR2 -- Conc Pgm Error mesgs.             |
 |      RetCode                 VARCHAR2 -- Conc Pgm Error Code.              |
 |                                          0 - Success, 2 - Failure.         |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |    12-Apr-1999    Ujjal Singh   Created.                                   |
 *----------------------------------------------------------------------------*/

PROCEDURE update_text_addr (
                        Errbuf                  OUT NOCOPY  VARCHAR2,
                        Retcode                 OUT NOCOPY  VARCHAR2,
                        p_idx_cust_contacts     IN          VARCHAR2) IS

cursor cust_index (p_schema IN VARCHAR2)is
/* Bug Fix: 4095863 */
select STATUS , DOMIDX_OPSTATUS , PARAMETERS from all_indexes where index_name = 'HZ_CUST_ACCT_SITES_ALL_T1'
and owner = p_schema;

x_dummy              BOOLEAN;
x_status             varchar2(30);
x_ind                varchar2(30);
x_index_owner        varchar2(50);
l_idx_mem 	     varchar2(30);
x_index_exist        varchar2(30) := NULL;
x_dom_index_status   varchar2(30) := NULL;
l_count              NUMBER  := 0;
L_DATASTORE 	     varchar2(30);
/* Bug Fix: 4095863 */
l_param_str	     varchar2(255);
x_parameters	     all_indexes.parameters%TYPE;
l_pos                NUMBER  := 0;
X_DROP_INDEX 	     varchar2(255);
X_INDEX_STRING 	     varchar2(255);
v_return_value       BOOLEAN;
x_profile_date       varchar2(30);
idx_retcode VARCHAR2(1);
idx_err     VARCHAR2(2000);

BEGIN

  retcode := 0;

  IF nvl(p_idx_cust_contacts,'Y') = 'Y' THEN
    l_datastore := 'APPS.siteud'; -- Bug 3162951
  ELSE
    l_datastore := 'APPS.siteud1'; -- Bug 3162951
  END IF;
	/* Bug Fix: 4095863 */
 	l_param_str :=  'replace datastore ' || l_datastore ;

  x_dummy := fnd_installation.GET_APP_INFO('AR',x_status,x_ind,x_index_owner);

  open cust_index(x_index_owner);
	/* Bug Fix: 409586 */
  fetch cust_index into x_index_exist,x_dom_index_status,x_parameters;
  IF cust_index%FOUND THEN
    /* Index Exist */
    IF x_index_exist      IS NOT NULL AND x_index_exist      = 'VALID' AND
       x_dom_index_status IS NOT NULL AND x_dom_index_status = 'VALID'
    THEN
         select count(1) into l_count
         from   ctxsys.ctx_index_errors
         where  err_index_name = 'HZ_CUST_ACCT_SITES_ALL_T1'
           and  rownum =1;
         IF l_count <> 1 THEN
		/* Bug Fix: 4095863 */
		l_pos := instr(x_parameters,'siteud1');
		IF ((l_pos <> 0 AND l_datastore = 'APPS.siteud') OR
		   (l_pos = 0 AND l_datastore = 'APPS.siteud1'))
		THEN
			EXECUTE IMMEDIATE ' ALTER INDEX ' || x_index_owner || '.HZ_CUST_ACCT_SITES_ALL_T1 REBUILD
			online parameters (''' || l_param_str || ''') PARALLEL ' ;
		END IF;
            /* Index is valid */
            SYNC_INDEX(x_index_owner || '.HZ_CUST_ACCT_SITES_ALL_T1', idx_retcode , idx_err);
            IF idx_retcode = 1 THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
            --to populate the profile option
            x_profile_date := fnd_date.date_to_canonical(sysdate);
            v_return_value := fnd_profile.save('AR_CUSTOMER_TEXT_LAST_SUCCESSFUL_RUN',x_profile_date,'SITE');
           IF not(v_return_value) then
              arp_util.debug('Profile option AR_CUSTOMER_TEXT_LAST_SUCCESSFUL_RUN ');
           END IF;
           RETURN;
        END IF;
    END IF;
      /* Index is invalid */
      x_drop_index := 'drop index '||x_index_owner||'.'|| 'HZ_CUST_ACCT_SITES_ALL_T1 force';
      EXECUTE IMMEDIATE x_drop_index;
  END IF;
  close cust_index;

  BEGIN
    SELECT PAR_VALUE INTO l_idx_mem
    FROM CTX_PARAMETERS
    WHERE PAR_NAME = 'MAX_INDEX_MEMORY';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BEGIN
        SELECT PAR_VALUE INTO l_idx_mem
        FROM CTX_PARAMETERS
        WHERE PAR_NAME = 'DEFAULT_INDEX_MEMORY';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_idx_mem := '0';
      END;
  END;

  BEGIN
    /* Bug Fix : 2910426
    ctx_output.start_log('cust_index');
    */
    execute immediate 'begin ctx_output.start_log(''cust_index''); end;';
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  IF l_idx_mem <> '0' THEN
    x_index_string := 'create index '||x_index_owner||'.'||
                      'HZ_CUST_ACCT_SITES_ALL_T1 on HZ_CUST_ACCT_SITES_ALL '||
                      '(ADDRESS_TEXT) indextype is ctxsys.context ' ||
                      'parameters ('' datastore ' || l_datastore ||
                                      ' stoplist ctxsys.empty_stoplist lexer APPS.text_lexer ' ||
                                      ' memory ' || l_idx_mem || ' '') PARALLEL ONLINE';
  ELSE
    x_index_string := 'create index '||x_index_owner||'.'||
                      'HZ_CUST_ACCT_SITES_ALL_T1 on HZ_CUST_ACCT_SITES_ALL '||
                      '(ADDRESS_TEXT) indextype is ctxsys.context '||
                      'parameters ('' datastore ' || l_datastore ||
                                   ' stoplist ctxsys.empty_stoplist lexer APPS.text_lexer ' ||' '') PARALLEL ONLINE';
  END IF;

  hz_common_pub.disable_cont_source_security;
  EXECUTE IMMEDIATE x_index_string;

--to populate the profile option
  x_profile_date := fnd_date.date_to_canonical(sysdate);
  v_return_value := fnd_profile.save('AR_CUSTOMER_TEXT_LAST_SUCCESSFUL_RUN',x_profile_date,'SITE');
  IF not(v_return_value) then
     arp_util.debug('Profile option AR_CUSTOMER_TEXT_LAST_SUCCESSFUL_RUN ');
  END IF;

  BEGIN
    /* Bug Fix : 2910426
    ctx_output.end_log;
    */
    execute immediate 'begin ctx_output.end_log; end;';
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

EXCEPTION
      WHEN OTHERS THEN
        arp_util.debug('OTHERS : ra_customer_text_pkg.update_text_addr');
        Errbuf := fnd_message.get||'     '||SQLERRM;
        Retcode := 2;

END update_text_addr;

PROCEDURE write_to_char (
    vl IN            VARCHAR2,
    sv IN OUT NOCOPY VARCHAR2 ) IS

BEGIN
  IF (nvl(lengthb(sv),0) + nvl(lengthb(vl),0)) < 32000 THEN
    sv := sv || vl;
  END IF;
END;

PROCEDURE write_to_lob(
    cl IN OUT NOCOPY CLOB,
    vl IN            VARCHAR2,
    sv IN OUT NOCOPY VARCHAR2 ) IS

len NUMBER;

BEGIN
  IF (nvl(lengthb(sv),0) + nvl(lengthb(vl),0)) >= 32000 THEN
    len := nvl(lengthb(sv),0);
    dbms_lob.writeappend(cl,len,sv);
    sv := vl;
  ELSE
    sv := sv || vl;
  END IF;
END;

Procedure site_info2 (
   rid          IN              ROWID,
   site_lob     IN OUT NOCOPY   CLOB) IS

stvar VARCHAR2(32000);
l_party_id NUMBER;
BEGIN

  /* Bug Fix: 4006266 */
  FOR sites in (
    SELECT cust_account_id, ac.cust_acct_site_id, ps.party_site_id, loc.address1||' '||loc.address2||' '||loc.address3||' '||loc.address4||' '|| loc.city||' '||loc.state||' '||
           loc.province||' '||loc.postal_code || ' ' cust_address
    FROM APPS.HZ_LOCATIONS loc, APPS.HZ_PARTY_SITES ps,
         APPS.HZ_CUST_ACCT_SITES_ALL ac
    WHERE ac.PARTY_SITE_ID=ps.PARTY_SITE_ID
    AND loc.LOCATION_ID = ps.LOCATION_ID
    AND ac.ROWID = rid)
  LOOP
    write_to_lob(site_lob,sites.cust_address,stvar);

    FOR cust in (
      SELECT cust_account_id, p.party_id,
        party_name||' '||ACCOUNT_NUMBER||' '||tax_reference || ' ' data
      FROM APPS.HZ_PARTIES p, APPS.HZ_CUST_ACCOUNTS c
      WHERE p.party_id = c.party_id
      AND c.cust_account_id = sites.cust_account_id)
    LOOP
      l_party_id := cust.party_id;
      write_to_lob(site_lob,cust.data,stvar);
      FOR tax IN (
         SELECT distinct customer_exemption_number || ' ' taxinfo
         FROM APPS.ra_tax_exemptions_all
         WHERE customer_id = cust.cust_account_id)
      LOOP
        write_to_lob(site_lob,tax.taxinfo,stvar);
      END LOOP;
    END LOOP;

    FOR cont in (
       SELECT rel.PARTY_ID rel_party_id,
           p.PERSON_FIRST_NAME || ' ' || p.PERSON_LAST_NAME|| ' ' name
       FROM APPS.HZ_PARTIES p, APPS.HZ_CUST_ACCOUNT_ROLES ar,
            APPS.HZ_RELATIONSHIPS rel
       WHERE ar.cust_account_id = sites.cust_account_id
       AND (ar.cust_acct_site_id is null)
       AND ar.ROLE_TYPE = 'CONTACT'
       AND ar.party_id = rel.party_id
       AND p.party_id = rel.subject_id
       AND rel.subject_table_name = 'HZ_PARTIES'
       AND rel.object_table_name  = 'HZ_PARTIES'
       AND rel.DIRECTIONAL_FLAG   = 'F')
    LOOP
      write_to_lob(site_lob,cont.name,stvar);

      FOR cp1 IN (
        SELECT PHONE_NUMBER||phone_area_code||phone_country_code||
               ' ' || EMAIL_ADDRESS || ' ' phone
        FROM APPS.hz_contact_points
        WHERE OWNER_TABLE_NAME = 'HZ_PARTIES'
        AND CONTACT_POINT_TYPE NOT IN ( 'EDI', 'WEB')
        AND OWNER_TABLE_ID = cont.rel_party_id)
      LOOP
        write_to_lob(site_lob,cp1.phone,stvar);
      END LOOP;
    END LOOP;

    FOR cp1 IN (
      SELECT PHONE_NUMBER||phone_area_code||phone_country_code||
                ' ' || EMAIL_ADDRESS || ' ' phone
      FROM APPS.hz_contact_points
      WHERE OWNER_TABLE_NAME = 'HZ_PARTIES'
      AND CONTACT_POINT_TYPE NOT IN ( 'EDI', 'WEB')
      AND OWNER_TABLE_ID = l_party_id)
    LOOP
      write_to_lob(site_lob,cp1.phone,stvar);
    END LOOP;

    FOR cont in (
     SELECT rel.PARTY_ID rel_party_id,
         p.PERSON_FIRST_NAME || ' ' || p.PERSON_LAST_NAME|| ' ' name
     FROM APPS.HZ_PARTIES p, APPS.HZ_CUST_ACCOUNT_ROLES ar,
          APPS.HZ_RELATIONSHIPS rel
     WHERE ar.cust_account_id = sites.cust_account_id
     AND (ar.cust_acct_site_id = sites.cust_acct_site_id)
     AND ar.ROLE_TYPE = 'CONTACT'
     AND ar.party_id = rel.party_id
     AND p.party_id = rel.subject_id
     AND rel.subject_table_name = 'HZ_PARTIES'
     AND rel.object_table_name  = 'HZ_PARTIES'
     AND rel.DIRECTIONAL_FLAG   = 'F')
    LOOP
      write_to_lob(site_lob,cont.name,stvar);

      FOR cp1 IN (
        SELECT PHONE_NUMBER||phone_area_code||phone_country_code||
               ' ' || EMAIL_ADDRESS || ' ' phone
        FROM APPS.hz_contact_points
        WHERE OWNER_TABLE_NAME = 'HZ_PARTIES'
        AND CONTACT_POINT_TYPE NOT IN ( 'EDI', 'WEB')
        AND OWNER_TABLE_ID = cont.rel_party_id)
      LOOP
        write_to_lob(site_lob,cp1.phone,stvar);
      END LOOP;
    END LOOP;

    FOR cp1 IN (
      SELECT PHONE_NUMBER||phone_area_code||phone_country_code|| ' ' phone
      FROM APPS.hz_contact_points
      WHERE OWNER_TABLE_NAME = 'HZ_PARTY_SITES'
      AND CONTACT_POINT_TYPE NOT IN ( 'EDI', 'EMAIL', 'WEB')
      AND OWNER_TABLE_ID = sites.party_site_id)
    LOOP
      write_to_lob(site_lob,cp1.phone,stvar);
    END LOOP;
  END LOOP;
  dbms_lob.writeappend(site_lob,lengthb(stvar),stvar);
END;

Procedure site_info (
   rid          IN              ROWID,
   site_char    IN OUT NOCOPY   VARCHAR2) IS

stvar VARCHAR2(32000);
l_party_id NUMBER;
BEGIN
  site_char := ' ';
  /* Bug Fix: 4006266 */
  FOR sites in (
    SELECT ac.status, cust_account_id, ac.cust_acct_site_id, ps.party_site_id, loc.address1||' '||loc.address2||' '||loc.address3 ||' '||loc.address4||' '|| loc.city||' '||loc.state||' '||
           loc.province||' '||loc.postal_code || ' ' cust_address
    FROM APPS.HZ_LOCATIONS loc, APPS.HZ_PARTY_SITES ps,
         APPS.HZ_CUST_ACCT_SITES_ALL ac
    WHERE ac.PARTY_SITE_ID=ps.PARTY_SITE_ID
    AND loc.LOCATION_ID = ps.LOCATION_ID
    AND ac.ROWID = rid)
  LOOP
    IF sites.status is null or sites.status = 'A' THEN
      write_to_char(sites.cust_address,site_char);

      FOR cust in (
        SELECT cust_account_id, p.party_id,
        party_name||' '||ACCOUNT_NUMBER||' '||tax_reference || ' ' data
        FROM APPS.HZ_PARTIES p, APPS.HZ_CUST_ACCOUNTS c
        WHERE p.party_id = c.party_id
        AND c.cust_account_id = sites.cust_account_id)
      LOOP
        l_party_id := cust.party_id;

        write_to_char(cust.data,site_char);
        FOR tax IN (
          SELECT distinct customer_exemption_number || ' ' taxinfo
          FROM APPS.ra_tax_exemptions_all
          WHERE customer_id = cust.cust_account_id)
        LOOP
          write_to_char(tax.taxinfo,site_char);
        END LOOP;
      END LOOP;

      FOR cp1 IN (
        SELECT PHONE_NUMBER||phone_area_code||phone_country_code||
                  ' ' || EMAIL_ADDRESS || ' ' phone
        FROM APPS.hz_contact_points
        WHERE OWNER_TABLE_NAME = 'HZ_PARTIES'
        AND CONTACT_POINT_TYPE NOT IN ( 'EDI', 'WEB')
        AND OWNER_TABLE_ID = l_party_id)
      LOOP
        write_to_char(cp1.phone,site_char);
      END LOOP;

/*
      FOR cont in (
       SELECT rel.PARTY_ID rel_party_id,
           p.PERSON_FIRST_NAME || ' ' || p.PERSON_LAST_NAME|| ' ' name
       FROM APPS.HZ_PARTIES p, APPS.HZ_CUST_ACCOUNT_ROLES ar,
            APPS.HZ_PARTY_RELATIONSHIPS rel
       WHERE ar.cust_account_id = sites.cust_account_id
       AND (ar.cust_acct_site_id = sites.cust_acct_site_id)
       AND ar.ROLE_TYPE = 'CONTACT'
       AND ar.party_id = rel.party_id
       AND p.party_id = rel.subject_id )
      LOOP
        write_to_char(cont.name,site_char);

        FOR cp1 IN (
          SELECT PHONE_NUMBER||phone_area_code||phone_country_code||
                 ' ' || EMAIL_ADDRESS || ' ' phone
          FROM APPS.hz_contact_points
          WHERE OWNER_TABLE_NAME = 'HZ_PARTIES'
          AND CONTACT_POINT_TYPE NOT IN ( 'EDI', 'WEB')
          AND OWNER_TABLE_ID = cont.rel_party_id)
        LOOP
          write_to_char(cp1.phone,site_char);
        END LOOP;
      END LOOP;
*/

      FOR cp1 IN (
        SELECT PHONE_NUMBER||phone_area_code||phone_country_code|| ' ' phone
        FROM APPS.hz_contact_points
        WHERE OWNER_TABLE_NAME = 'HZ_PARTY_SITES'
        AND CONTACT_POINT_TYPE NOT IN ( 'EDI', 'EMAIL', 'WEB')
        AND OWNER_TABLE_ID = sites.party_site_id)
      LOOP
        write_to_char(cp1.phone,site_char);
      END LOOP;
    END IF;
  END LOOP;
END;

END RA_CUSTOMER_TEXT_PKG;

/

  GRANT EXECUTE ON "APPS"."RA_CUSTOMER_TEXT_PKG" TO "CTXSYS";
