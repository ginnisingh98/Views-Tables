--------------------------------------------------------
--  DDL for Package Body JTF_TTY_EXCEL_NAORG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_EXCEL_NAORG_PVT" AS
/* $Header: jtfamifb.pls 120.14 2006/07/31 18:57:48 mhtran noship $ */
-- ===========================================================================+
-- |               Copyright (c) 2003 Oracle Corporation                       |
-- |                  Redwood Shores, California, USA                          |
-- |                       All rights reserved.                                |
-- +===========================================================================
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_EXCEL_NAORG_PVT
--    ---------------------------------------------------
--    PURPOSE
--
--      This package is used to populate the interface table jtf_tty_webadi_interface
--      for the admin export download
--
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      02/24/2004    ACHANDA        Created
--     04/14/2004    SGKUMAR        Bug 3570818 fixed. Performance fix for
--                                   Named Accounts Search by City, Role or
--                                   Salesperson and Group
--      10/07/2004    sgkumar        Bug 3907932 fixed. Performance fix
--                                   for na search by salesperson
--      10/14/2005   vbghosh        Modified to suport export button functionality.
--
--    End of Comments
--

  g_seq NUMBER;
--g_seq NUMBER := -9999;
  g_rows_limit CONSTANT NUMBER := 25000;
  g_no_lookup VARCHAR2(80);

  G_SEQUENCE_ERROR    EXCEPTION;
  G_DELETE_ERROR      EXCEPTION;
  G_TERRGRP_MISSING   EXCEPTION;
  G_NO_LOOKUP_MISSING EXCEPTION;

/* this function returns true is p_str contains any character othet than % or space */
FUNCTION CONTAINS_ONLY_PCTG(P_STR IN VARCHAR2) RETURN BOOLEAN
AS
  l_length NUMBER;
  l_found  BOOLEAN;
BEGIN
  l_found := FALSE;

  IF (TRIM(p_str) IS NOT NULL) THEN
    l_length := LENGTH(p_str);
    FOR i IN 1..l_length LOOP
      IF (SUBSTR(p_str, i, 1) <> '%') THEN
        l_found := TRUE;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  RETURN l_found;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;

PROCEDURE POPULATE_INTERFACE_FOR_ORG( P_USERID         IN  INTEGER
                                 ,P_SICCODE            IN  VARCHAR2
                                 ,P_SICCODE_TYPE       IN VARCHAR2
                                 ,P_SITE_DUNS          IN VARCHAR2
                                 ,P_PARTY_NAME         IN VARCHAR2
                                 ,P_WEB_SITE           IN VARCHAR2
                                 ,P_EMAIL_ADDR         IN VARCHAR2
                                 ,P_CITY               IN VARCHAR2
                                 ,P_STATE              IN VARCHAR2
                                 ,P_COUNTY             IN VARCHAR2
                                 ,P_PROVINCE           IN VARCHAR2
                                 ,P_POSTAL_CODE_FROM   IN VARCHAR2
                                 ,P_POSTAL_CODE_TO     IN VARCHAR2
                                 ,P_COUNTRY            IN VARCHAR2
                                 ,P_PARTY_NUMBER       IN VARCHAR2
                                 ,P_CERT_LEVEL         IN VARCHAR2
                                 ,P_PARTY_TYPE         IN VARCHAR2
                                 ,P_HIERARCHY_TYPE     IN VARCHAR2
                                 ,P_RELATIONSHIP_ROLE  IN VARCHAR2
                                 ,P_CLASS_TYPE         IN VARCHAR2
                                 ,P_CLASS_CODE         IN VARCHAR2
                                 ,P_ANNUAL_REV_FROM    IN NUMBER
                                 ,P_ANNUAL_REV_TO      IN NUMBER
                                 ,P_NUM_EMP_FROM       IN VARCHAR2
                                 ,P_NUM_EMP_TO         IN VARCHAR2
                                 ,P_CUST_CATEGORY      IN VARCHAR2
                                 ,P_IDADDR_FLAG        IN VARCHAR2
                                 ,X_ROWS_INSERTED      OUT NOCOPY NUMBER
                                 ,X_RETCODE            OUT NOCOPY VARCHAR2
                                 ,X_ERRBUF             OUT NOCOPY VARCHAR2) IS

  l_na_query              VARCHAR2(6000);
  l_curr_date             VARCHAR2(100);

  L_PARTY_NAME_STR       VARCHAR2(361);
  L_WEBSITE_STR          VARCHAR2(2001);
  L_EMAIL_STR            VARCHAR2(2001);
  l_useExistsClause      VARCHAR2(1);

BEGIN

  X_RETCODE       := 0;
  X_ERRBUF        := NULL;
  X_ROWS_INSERTED := 0;
  l_curr_date     := TO_CHAR(SYSDATE);
  l_useExistsClause := 'N';

  L_PARTY_NAME_STR := NULL;
  L_WEBSITE_STR       := NULL;
  L_EMAIL_STR         := NULL;


  /* form the pl/sql block to insert all the ORGs in the interface table jtf_tty_webadi_interface */
  l_na_query :=
    'DECLARE ' ||
      ' P_USERID           INTEGER       := :P_USERID; '||
      ' P_SICCODE          VARCHAR2(100) := :P_SICCODE; '||
      ' P_SICCODE_TYPE     VARCHAR2(100) := :P_SICCODE_TYPE; '||
      ' P_SITE_DUNS        VARCHAR2(100) := :P_SITE_DUNS; '||
      ' P_PARTY_NAME       VARCHAR2(360) := :P_PARTY_NAME; '||
      ' P_WEB_SITE         VARCHAR2(2000) := :P_WEB_SITE; '||
      ' P_EMAIL_ADDR       VARCHAR2(2000) := :P_EMAIL_ADDR; '||
      ' P_CITY             VARCHAR2(100) := :P_CITY; '||
      ' P_STATE            VARCHAR2(100) := :P_STATE; '||
      ' P_COUNTY           VARCHAR2(100) := :P_COUNTY; '||
      ' P_PROVINCE         VARCHAR2(100) := :P_PROVINCE; '||
      ' P_POSTAL_CODE_FROM VARCHAR2(100) := :P_POSTAL_CODE_FROM; '||
      ' P_POSTAL_CODE_TO   VARCHAR2(100) := :P_POSTAL_CODE_TO; '||
      ' P_COUNTRY          VARCHAR2(100) := :P_COUNTRY; '||
      ' P_PARTY_NUMBER     VARCHAR2(30)  := :P_PARTY_NUMBER; '||
      ' P_CERT_LEVEL       VARCHAR2(60)  := :P_CERT_LEVEL; ' ||
      ' P_PARTY_TYPE       VARCHAR2(60)  := :P_PARTY_TYPE; ' ||
      ' P_HIERARCHY_TYPE   VARCHAR2(60)  := :P_HIERARCHY_TYPE; ' ||
      ' P_RELATIONSHIP_ROLE VARCHAR2(60) := :P_RELATIONSHIP_ROLE; ' ||
      ' P_CLASS_TYPE       VARCHAR2(60)  := :P_CLASS_TYPE; ' ||
      ' P_CLASS_CODE       VARCHAR2(60)  := :P_CLASS_CODE; ' ||
      ' P_ANNUAL_REV_FROM  NUMBER        := :P_ANNUAL_REV_FROM; ' ||
      ' P_ANNUAL_REV_TO    NUMBER        := :P_ANNUAL_REV_TO; ' ||
      ' P_NUM_EMP_FROM     VARCHAR2(10)  := :P_NUM_EMP_FROM; ' ||
      ' P_NUM_EMP_TO       VARCHAR2(10)  := :P_NUM_EMP_TO; ' ||
      ' P_CUST_CATEGORY    VARCHAR2(60)  := :P_CUST_CATEGORY; ' ||
      ' P_IDENT_ADDR_FLAG  VARCHAR2(1)   := :P_IDADDR_FLAG; ' ||
    ' BEGIN '||
      ' INSERT into JTF_TTY_WEBADI_INTERFACE ( ' ||
          ' USER_SEQUENCE' ||
          ' ,USER_ID' ||
          ' ,TERR_GRP_ACCT_ID' ||
          ' ,JTF_TTY_WEBADI_INT_ID' ||
          ' ,NAMED_ACCOUNT' ||
          ' ,SITE_TYPE' ||
          ' ,DUNS'||
          ' ,TRADE_NAME' ||
          ' ,GU_DUNS' ||
          ' ,GU_NAME' ||
          ' ,DU_DUNS' ||
          ' ,DU_NAME' ||
          ' ,CITY' ||
          ' ,STATE' ||
          ' ,POSTAL_CODE' ||
          ' ,TERRITORY_GROUP' ||
     	   ' ,PARTY_NUMBER' ||
          ' ,TO_TERRITORY_GROUP' ||
          ' ,DELETE_FLAG' ||
          ' ,CREATED_BY' ||
          ' ,CREATION_DATE' ||
          ' ,LAST_UPDATED_BY' ||
          ' ,LAST_UPDATE_DATE' ||
	   	  ' ,PARTY_SITE_NUMBER'||
	   	  ' ,SALES_MANAGER' ||
          ' ,PHONETIC_NAME' ||
          ' ,IDENTIFYING_ADDRESS ) '||
      ' SELECT ' || g_seq || ' USER_SEQUENCE '||
         ' ,' ||  P_USERID || ' USER_ID '||
         ' ,TO_NUMBER(null) TERR_GRP_ACCT_ID '||
         ' ,TO_NUMBER(null) JTF_TTY_WEBADI_INT_ID '||
         ' ,NAMED_ACCOUNT NAMED_ACCOUNT '||
         ' ,null SITE_TYPE '||
         ' ,SITE_DUNS DUNS '||
         ' ,TRADE_NAME TRADE_NAME '||
         ' ,GU_DUNS GU_DUNS '||
         ' ,GU_NAME GU_NAME '||
         ' ,DU_DUNS DU_DUNS '||
         ' ,DU_NAME DU_NAME '||
         ' ,CITY CITY '||
         ' ,STATE STATE '||
         ' ,POSTAL_CODE POSTAL_CODE ' ||
         ' ,null TERRITORY_GROUP ' ||
         ' ,PARTY_NUMBER PARTY_NUMBER ' ||
         ' ,NULL TO_TERRITORY_GROUP ' ||
         ' ,''' || g_no_lookup || ''' DELETE_FLAG ' ||
         ' ,' ||  P_USERID || ' CREATED_BY '||
         ' ,''' || l_curr_date|| '''' || ' CREATION_DATE ' ||
         ' ,' ||  P_USERID || ' LAST_UPDATED_BY '||
         ' ,''' || l_curr_date|| '''' || ' LAST_UPDATE_DATE ' ||
		 ' ,PARTY_SITE_NUMBER PARTY_SITE_NUMBER'||
		 ' ,null SALES_MANAGER '||
         ' ,PHONETIC_NAME PHONETIC_NAME' ||
         ' ,IDENTIFYING_ADDRESS_FLAG IDENTIFYING_ADDRESS' ||
         ' FROM ( ' ||
         ' SELECT '||
          ' hzp.party_name  named_account ' ||
          ' ,hzp.duns_number_c site_duns ' ||
          ' ,hzp.known_as trade_name ' ||
          ' ,GU.GU_DUNS gu_duns ' ||
          ' ,GU.GU_NAME gu_name  ' ||
          ' ,null du_duns  ' ||
          ' ,null du_name  ' ||
          ' ,hzp.party_number party_number ' ||
          ' ,hzl.city  city ' ||
          ' ,hzl.state state ' ||
          ' ,hzl.postal_code  postal_code ' ||
          ' ,hzps.party_site_number   party_site_number '||
          ' ,identifying_address_flag identifying_address_flag ' ||
          ' ,decode(hzp.party_type, ''ORGANIZATION'',hzp.ORGANIZATION_NAME_PHONETIC, ' ||
          '        ''PERSON'',hzp.PERSON_LAST_NAME_PHONETIC || '', '' || hzp.PERSON_FIRST_NAME_PHONETIC,null) PHONETIC_NAME' ||
          ' FROM hz_parties hzp, hz_party_sites hzps, hz_locations hzl';

  IF ( (P_ANNUAL_REV_FROM IS NOT NULL) OR
       (P_ANNUAL_REV_TO IS NOT NULL) OR
       (trim(P_NUM_EMP_FROM) IS NOT NULL) OR
       (trim(P_NUM_EMP_TO) IS NOT NULL) ) THEN
    l_na_query := l_na_query || ' ,hz_organization_profiles hzop ';
  END IF;

  l_na_query := l_na_query ||
      ' ,( /* Global Ultimate : min is used to make sre that there is 1 GU for each party */ ' ||
      ' SELECT min(gup.party_name) GU_NAME ' ||
         ' , min(gup.duns_number_c) GU_DUNS ' ||
         ' , hzr.object_id GU_OBJECT_ID ' ||
         ' FROM hz_parties  gup ' ||
         '  , hz_relationships hzr ' ||
         ' WHERE hzr.subject_table_name = ''HZ_PARTIES'' ' ||
           ' AND hzr.object_table_name  = ''HZ_PARTIES'' ' ||
           ' AND hzr.relationship_type  = ''GLOBAL_ULTIMATE'' ' ||
           ' AND hzr.relationship_code  = ''GLOBAL_ULTIMATE_OF'' ' ||
           ' AND hzr.status = ''A'' ' ||
           ' AND hzr.subject_id = gup.party_id ' ||
           ' AND gup.status = ''A'' ' ||
           ' GROUP BY hzr.object_id ) GU ' ||
    ' WHERE hzp.status = ''A'' ' ||
      ' AND GU.GU_OBJECT_ID (+)  = hzp.party_id ' ||
      ' AND hzp.party_id = hzps.party_id ' ||
      ' AND hzps.status = ''A'' ' ||
      ' AND hzps.location_id = hzl.location_id  ' ;

  IF ( (P_ANNUAL_REV_FROM IS NOT NULL) OR
       (P_ANNUAL_REV_TO IS NOT NULL) OR
       (trim(P_NUM_EMP_FROM) IS NOT NULL) OR
       (trim(P_NUM_EMP_TO) IS NOT NULL) ) THEN
    l_na_query := l_na_query || ' AND hzp.party_id = hzop.party_id ' ||
                                ' AND hzop.status = ''A'' ' ||
                                ' AND ( (sysdate >= hzop.effective_start_date) AND ' ||
                                    ' ( ( hzop.effective_end_date IS NULL ) OR ' ||
                                      ' ( sysdate <= hzop.effective_end_date) ) ' ||
                                     ' ) ';

  END IF;

  IF (trim(P_IDADDR_FLAG) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzps.identifying_address_flag = :P_IDADDR_FLAG ' ;
    l_useExistsClause := 'Y';
  END IF;

  IF (trim(P_SICCODE) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzp.sic_code = :P_SICCODE ' ;
    l_useExistsClause := 'Y';
  END IF;

  IF (trim(P_SICCODE_TYPE) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzp.sic_code_type = :P_SICCODE_TYPE ' ;
  END IF;

  IF ((trim(P_SITE_DUNS) IS NOT NULL) AND
     (trim(P_RELATIONSHIP_ROLE) IS NULL) ) THEN
    l_na_query :=  l_na_query || 'AND hzp.duns_number_c = :P_SITE_DUNS ' ;
    l_useExistsClause := 'Y';
  END IF;

  IF ( (CONTAINS_ONLY_PCTG(P_PARTY_NAME)) AND
      (trim(P_RELATIONSHIP_ROLE) IS NULL) ) THEN
    l_na_query :=  l_na_query || 'AND upper(hzp.party_name) like :P_PARTY_NAME ' ;
    l_useExistsClause := 'Y';
  END IF;

  IF (CONTAINS_ONLY_PCTG(P_WEB_SITE)) THEN
    l_na_query :=  l_na_query || 'AND upper(hzp.url) like :P_WEB_SITE ' ;
  END IF;

  IF (CONTAINS_ONLY_PCTG(P_EMAIL_ADDR)) THEN
    l_na_query :=  l_na_query || 'AND upper(hzp.email_address) like :P_EMAIL_ADDR ' ;
  END IF;

   IF (trim(P_PARTY_TYPE) IS NOT NULL) THEN
     l_na_query :=  l_na_query || 'AND hzp.party_type = :P_PARTY_TYPE ' ;
   END IF;


  IF (trim(P_CITY) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzl.city = :P_CITY ';
  END IF;

  IF (trim(P_STATE) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzl.state = :P_STATE ';
  END IF;

  IF (trim(P_PROVINCE) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzl.province = :P_PROVINCE ' ;
  END IF;

  IF (trim(P_COUNTY) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzl.COUNTY = :P_COUNTY ' ;
  END IF;

  IF ((trim(P_POSTAL_CODE_FROM) IS NOT NULL) AND (trim(P_POSTAL_CODE_TO) IS NOT NULL)
      AND (P_POSTAL_CODE_FROM = P_POSTAL_CODE_TO)) THEN
    l_na_query :=  l_na_query || 'AND hzl.postal_code = :P_POSTAL_CODE_FROM ';

  ELSIF ((trim(P_POSTAL_CODE_FROM) IS NOT NULL) AND (trim(P_POSTAL_CODE_TO) IS NOT NULL)
         AND (P_POSTAL_CODE_FROM <> P_POSTAL_CODE_TO))  THEN
    l_na_query :=  l_na_query || 'AND hzl.postal_code between :P_POSTAL_CODE_FROM and :P_POSTAL_CODE_TO ';

  ELSIF ((trim(P_POSTAL_CODE_FROM) IS NOT NULL) AND (trim(P_POSTAL_CODE_TO) IS NULL))  THEN
    l_na_query :=  l_na_query || 'AND hzl.postal_code = :P_POSTAL_CODE_FROM ';

  ELSIF ((trim(P_POSTAL_CODE_FROM) IS NULL) AND (trim(P_POSTAL_CODE_TO) IS NOT NULL)) THEN
    l_na_query :=  l_na_query || 'AND hzl.postal_code = :P_POSTAL_CODE_TO ' ;
  END IF;

  IF (trim(P_COUNTRY) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzl.country = :P_COUNTRY ';
  END IF;

  IF ((trim(P_PARTY_NUMBER) IS NOT NULL) AND
       (trim(P_RELATIONSHIP_ROLE) IS NULL) )  THEN
    l_na_query :=  l_na_query || 'AND hzp.party_number = :P_PARTY_NUMBER ';
    l_useExistsClause := 'Y';
  END IF;


  IF ((trim(P_CERT_LEVEL) IS NOT NULL) AND (P_CERT_LEVEL <> 'ALL')) THEN
    l_na_query :=  l_na_query || ' and hzp.certification_level = :P_CERT_LEVEL ';
  END IF;

  -- Annual Revenue
  IF ((P_ANNUAL_REV_FROM IS NOT NULL) AND (P_ANNUAL_REV_TO IS NOT NULL)
      AND (P_ANNUAL_REV_FROM = P_ANNUAL_REV_TO)) THEN
    l_na_query :=  l_na_query || 'AND hzop.curr_fy_potential_revenue = :P_ANNUAL_REV_FROM ';

  ELSIF ((P_ANNUAL_REV_FROM IS NOT NULL) AND (P_ANNUAL_REV_TO IS NOT NULL)
         AND (P_ANNUAL_REV_FROM <> P_ANNUAL_REV_TO))  THEN
    l_na_query :=  l_na_query || 'AND hzop.curr_fy_potential_revenue between :P_ANNUAL_REV_FROM and :P_ANNUAL_REV_TO ';

  ELSIF ((P_ANNUAL_REV_FROM IS NOT NULL) AND (P_ANNUAL_REV_TO IS NULL))  THEN
    l_na_query :=  l_na_query || 'AND hzop.curr_fy_potential_revenue >= :P_ANNUAL_REV_FROM ';

  ELSIF ((P_ANNUAL_REV_FROM IS NULL) AND (P_ANNUAL_REV_TO IS NOT NULL)) THEN
    l_na_query :=  l_na_query || 'AND hzop.curr_fy_potential_revenue <= :P_ANNUAL_REV_TO ' ;
  END IF;

  -- Number of Employees

  IF ((trim(P_NUM_EMP_FROM) IS NOT NULL) AND (trim(P_NUM_EMP_TO) IS NOT NULL)
      AND (P_NUM_EMP_FROM = P_NUM_EMP_TO)) THEN
    l_na_query :=  l_na_query || 'AND hzop.emp_at_primary_adr = :P_NUM_EMP_FROM ';

  ELSIF ((trim(P_NUM_EMP_FROM) IS NOT NULL) AND (trim(P_NUM_EMP_TO) IS NOT NULL)
         AND (P_NUM_EMP_FROM <> P_NUM_EMP_TO))  THEN
    l_na_query :=  l_na_query || 'AND hzop.emp_at_primary_adr between :P_NUM_EMP_FROM and :P_NUM_EMP_TO ';

  ELSIF ((trim(P_NUM_EMP_FROM) IS NOT NULL) AND (trim(P_NUM_EMP_TO) IS NULL))  THEN
    l_na_query :=  l_na_query || 'AND hzop.emp_at_primary_adr = :P_NUM_EMP_FROM ';

  ELSIF ((trim(P_NUM_EMP_FROM) IS NULL) AND (trim(P_NUM_EMP_TO) IS NOT NULL)) THEN
    l_na_query :=  l_na_query || 'hzop.emp_at_primary_adr = :P_NUM_EMP_TO ' ;
  END IF;


   IF (trim(P_CUST_CATEGORY) IS NOT NULL) THEN
     l_na_query :=  l_na_query || 'AND hzp.category_code = :P_CUST_CATEGORY' ;
   END IF;


   IF (trim(P_HIERARCHY_TYPE) IS NOT NULL) AND
     (trim(P_RELATIONSHIP_ROLE) IS NOT NULL) THEN

      IF l_useExistsClause = 'Y' THEN
        l_na_query :=  l_na_query || ' AND EXISTS ( SELECT null ';
      ELSE
        l_na_query :=  l_na_query || ' AND hzp.party_id IN ( SELECT b.subject_id ';
      END IF;

      l_na_query :=  l_na_query || 'FROM hz_relationships b, hz_parties c ';
      l_na_query :=  l_na_query || 'WHERE b.object_id = c.party_id ';

      IF l_useExistsClause = 'Y' THEN
            l_na_query :=  l_na_query || 'AND b.subject_id = hzp.party_id ' ;
      END IF;

      l_na_query :=  l_na_query || 'AND b.subject_table_name = ''HZ_PARTIES'' ';
      l_na_query :=  l_na_query || 'AND b.object_table_name = ''HZ_PARTIES'' ';
      l_na_query :=  l_na_query || 'AND b.status = ''A'' ';
      l_na_query :=  l_na_query || 'AND b.relationship_type = :P_HIERARCHY_TYPE ';
      l_na_query :=  l_na_query || 'AND b.relationship_code = :P_RELATIONSHIP_ROLE ';

      IF (CONTAINS_ONLY_PCTG(P_PARTY_NAME)) THEN
           l_na_query :=  l_na_query || 'AND upper(c.party_name) like :P_PARTY_NAME ' ;
      END IF;


      IF (trim(P_SITE_DUNS) IS NOT NULL) THEN
          l_na_query :=  l_na_query || 'AND c.duns_number_c = :P_SITE_DUNS ' ;
      END IF;

      IF (trim(P_PARTY_NUMBER) IS NOT NULL) THEN
         l_na_query :=  l_na_query || 'AND c.party_number = :P_PARTY_NUMBER ';
      END IF;

      l_na_query :=  l_na_query || ')';
  END IF;

   IF (trim(P_CLASS_TYPE) IS NOT NULL) THEN

      IF l_useExistsClause = 'Y' THEN
         l_na_query :=  l_na_query || ' AND EXISTS ( SELECT null ';
      ELSE
       l_na_query :=  l_na_query || ' AND hzp.party_id IN ( SELECT hca.owner_table_id ' ;
      END IF;

       l_na_query :=  l_na_query || 'FROM hz_code_assignments hca ' ;
       l_na_query :=  l_na_query || 'WHERE hca.status = ''A'' ';
       l_na_query :=  l_na_query || 'AND sysdate >= hca.start_date_active ';
       l_na_query :=  l_na_query || 'AND ( hca.end_date_active IS NULL OR ';
       l_na_query :=  l_na_query || ' sysdate <= hca.end_date_active ) ';
       l_na_query :=  l_na_query || 'AND hca.class_category = :P_CLASS_TYPE ';


       IF (trim(P_CLASS_CODE) IS NOT NULL) THEN
          l_na_query :=  l_na_query || ' AND hca.class_code = :P_CLASS_CODE ';
       END IF;

       IF l_useExistsClause = 'Y' THEN
               l_na_query :=  l_na_query || ' AND hca.owner_table_id = hzp.party_id ';
       END IF;

      l_na_query :=  l_na_query || ')';
   END IF;

  l_na_query := l_na_query || ' AND ROWNUM <= ' || TO_CHAR(g_rows_limit + 1);
  l_na_query :=  l_na_query || ' ); ';
  l_na_query := l_na_query || ':X_ROWS_INSERTED := SQL%ROWCOUNT; ';
  l_na_query :=  l_na_query || ' end; ';
  /* end of the pl/sql block */

  IF (CONTAINS_ONLY_PCTG(P_PARTY_NAME)) THEN
    L_PARTY_NAME_STR    := UPPER(P_PARTY_NAME) || '%';
  END IF;
  IF (CONTAINS_ONLY_PCTG(P_WEB_SITE)) THEN
    L_WEBSITE_STR             := UPPER(P_WEB_SITE) || '%';
  END IF;
  IF (CONTAINS_ONLY_PCTG(P_EMAIL_ADDR)) THEN
    L_EMAIL_STR             := UPPER(P_EMAIL_ADDR) || '%';
  END IF;

  /* execute the pl/sql block and commit */
  EXECUTE IMMEDIATE l_na_query USING
          P_USERID,P_SICCODE,P_SICCODE_TYPE, P_SITE_DUNS, L_PARTY_NAME_STR, L_WEBSITE_STR, L_EMAIL_STR,
          P_CITY, P_STATE, P_COUNTY, P_PROVINCE, P_POSTAL_CODE_FROM, P_POSTAL_CODE_TO,P_COUNTRY, P_PARTY_NUMBER,
          P_CERT_LEVEL, P_PARTY_TYPE, P_HIERARCHY_TYPE, P_RELATIONSHIP_ROLE, P_CLASS_TYPE, P_CLASS_CODE,
          P_ANNUAL_REV_FROM, P_ANNUAL_REV_TO, P_NUM_EMP_FROM, P_NUM_EMP_TO, P_CUST_CATEGORY,
          P_IDADDR_FLAG, OUT X_ROWS_INSERTED;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END POPULATE_INTERFACE_FOR_ORG;

PROCEDURE POPULATE_INTERFACE_FOR_NA( P_USERID           IN  INTEGER
                                    ,P_GRPID            IN  NUMBER
                                    ,P_SITE_TYPE        IN  VARCHAR2
                                    ,P_SICCODE          IN  VARCHAR2
                                    ,P_SITE_DUNS        IN  VARCHAR2
                                    ,P_NAMED_ACCOUNT    IN  VARCHAR2
                                    ,P_CITY             IN  VARCHAR2
                                    ,P_STATE            IN  VARCHAR2
                                    ,P_PROVINCE         IN  VARCHAR2
                                    ,P_POSTAL_CODE_FROM IN  VARCHAR2
                                    ,P_POSTAL_CODE_TO   IN  VARCHAR2
                                    ,P_COUNTRY          IN  VARCHAR2
                                    ,P_DU_DUNS          IN  VARCHAR2
                                    ,P_DU_NAME          IN  VARCHAR2
                                    ,P_PARTY_NUMBER     IN  VARCHAR2
                                    ,P_GU_DUNS          IN  VARCHAR2
                                    ,P_GU_NAME          IN  VARCHAR2
                                    ,P_CERT_LEVEL       IN  VARCHAR2
                                    ,P_SALESPERSON      IN  NUMBER
                                    ,P_SALES_GROUP      IN  NUMBER
                                    ,P_SALES_ROLE       IN  VARCHAR2
								    ,P_PARTY_TYPE         IN VARCHAR2
					 				,P_HIERARCHY_TYPE     IN VARCHAR2 --added
					 				,P_RELATIONSHIP_ROLE  IN VARCHAR2
					 				,P_CLASS_TYPE         IN VARCHAR2
					 				,P_CLASS_CODE         IN VARCHAR2
					 				,P_ANNUAL_REV_FROM    IN NUMBER
					 				,P_ANNUAL_REV_TO      IN NUMBER
					 				,P_NUM_EMP_FROM       IN VARCHAR2
					 				,P_NUM_EMP_TO         IN VARCHAR2
					 				,P_CUST_CATEGORY      IN VARCHAR2
					 				,P_IDADDR_FLAG        IN VARCHAR2
					 				,P_SICCODE_TYPE       IN VARCHAR2
                                    ,P_GRPNAME            IN VARCHAR2  -- added 06/15/2006
									,P_VIEW_DATE		  IN DATE		-- added 07/20/2006
									,P_ORG_ID			  IN NUMBER		-- added 07/20/2006
                                    ,X_ROWS_INSERTED    OUT NOCOPY NUMBER
                                    ,X_RETCODE          OUT NOCOPY VARCHAR2
                                    ,X_ERRBUF           OUT NOCOPY VARCHAR2) IS


  RESOURCE_NAME           VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  GROUP_NAME              VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  ROLE_NAME               VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  COL_ROLE                VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  RESOURCE_ATTRIBUTE1     VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  RESOURCE_ATTRIBUTE2     VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  RESOURCE_ATTRIBUTE3     VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  RESOURCE_ATTRIBUTE4     VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  RESOURCE_ATTRIBUTE5     VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  RESOURCE_START_DATE     DARRAY_TYPE:=DARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  RESOURCE_END_DATE     DARRAY_TYPE:=DARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


  COL_USED                NARRAY_TYPE:=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

  l_na_query              VARCHAR2(31000);
  l_curr_date             VARCHAR2(100);

  P_NAMED_ACCOUNT_STR    VARCHAR2(361);
  P_CITY_STR             VARCHAR2(61);
  P_DU_NAME_STR          VARCHAR2(361);
  P_GU_NAME_STR          VARCHAR2(361);

  i                       NUMBER;
  j                       NUMBER;
  k                       NUMBER;

   /*vbghosh added */
  l_useExistsClause      VARCHAR2(1);
  l_terr_group_id        NUMBER;

/* JRADHAKR fixed the following cursor to consider the
   roles only for a specific TG bug 3576571 */

  CURSOR getStatistic (userid IN NUMBER) IS
  SELECT role_code, MAX(num) num
  FROM (
       SELECT rol.role_code role_code, COUNT(rol.role_code) num
       FROM
         jtf_rs_roles_vl rol,
         jtf_tty_named_acct_rsc narsc,
         jtf_tty_terr_grp_accts ga
       WHERE rol.role_code = narsc.rsc_role_code
       AND narsc.terr_group_account_id =  ga.terr_group_account_id
       AND ga.terr_group_account_id IN
                ( SELECT terr_grp_acct_id
                  FROM  jtf_tty_webadi_interface
                  WHERE user_id = userid
                )
       GROUP BY ga.terr_group_account_id, rol.role_code
       ORDER BY MAX(rol.role_name)
       )
  GROUP BY role_code;


  CURSOR getNAFromInterface(userid IN NUMBER)  IS
  SELECT jtf_tty_webadi_int_id, terr_grp_acct_id
  FROM   jtf_tty_webadi_interface
  WHERE  user_id = userid;

  CURSOR getSalesperson( P_TG_ACCT_ID IN NUMBER) IS
  SELECT   rsc.resource_name resource_name
         , rol.role_name role_name
         , grp.group_name group_name
         , rsc.resource_id resource_id
         , grp.group_id group_id
         , rol.role_code role_code
		 , narsc.ATTRIBUTE1
		 , narsc.ATTRIBUTE2
		 , narsc.ATTRIBUTE3
		 , narsc.ATTRIBUTE4
		 , narsc.ATTRIBUTE5
		 , narsc.START_DATE
		 , narsc.END_DATE
  FROM   jtf_rs_resource_extns_vl rsc
       , jtf_rs_groups_vl grp
       , jtf_rs_roles_vl rol
       , jtf_tty_named_acct_rsc narsc
       , jtf_tty_terr_grp_accts ga
      -- , jtf_tty_terr_groups    tga
  WHERE rsc.resource_id = narsc.resource_id
  AND grp.group_id = narsc.rsc_group_id
  AND rol.role_code = narsc.rsc_role_code
  AND narsc.terr_group_account_id =  ga.terr_group_account_id
 -- AND tga.terr_group_id = ga.terr_group_id
 -- AND sysdate >= tga.active_from_date
  --AND (tga.active_to_date is null OR
   -- sysdate <= tga.active_to_date)
  AND narsc.rsc_resource_type = 'RS_EMPLOYEE'
  AND ga.terr_group_account_id = P_TG_ACCT_ID;

BEGIN

  X_RETCODE       := 0;
  X_ERRBUF        := NULL;
  X_ROWS_INSERTED := 0;
  l_curr_date     := TO_CHAR(SYSDATE);

  P_NAMED_ACCOUNT_STR := NULL;
  P_CITY_STR          := NULL;
  P_DU_NAME_STR       := NULL;
  P_GU_NAME_STR       := NULL;

--  dbms_output.put_line('Start POPULATE_INTERFACE_FOR_NA');

  /* form the pl/sql block to insert all the NAs in the interface table jtf_tty_webadi_interface */
  l_na_query :=
    'DECLARE ' ||
      ' P_USERID           INTEGER       := :P_USERID; '||
      ' P_GRPID            NUMBER        := :P_GRPID ; '|| --vbghosh Added
      ' P_VIEW_DATE  	   DATE   		 := :P_VIEW_DATE; ' ||  -- added 07/20/2006
      ' P_ORG_ID  	 	   NUMBER   	 := :P_ORG_ID; ' ||  -- added 07/20/2006
	  ' P_GRPNAME		   VARCHAR2(360) := TRIM(UPPER(:P_GRPNAME)); ' || -- added 06/15/2006
      ' P_SITE_TYPE        VARCHAR2(100) := :P_SITE_TYPE; '||
      ' P_SICCODE          VARCHAR2(100) := :P_SICCODE; '||
      ' P_SITE_DUNS        VARCHAR2(100) := :P_SITE_DUNS; '||
      ' P_NAMED_ACCOUNT    VARCHAR2(360) := :P_NAMED_ACCOUNT; '||
      ' P_CITY             VARCHAR2(100) := :P_CITY; '||
      ' P_STATE            VARCHAR2(100) := :P_STATE; '||
      ' P_PROVINCE         VARCHAR2(100) := :P_PROVINCE; '||
      ' P_POSTAL_CODE_FROM VARCHAR2(100) := :P_POSTAL_CODE_FROM; '||
      ' P_POSTAL_CODE_TO   VARCHAR2(100) := :P_POSTAL_CODE_TO; '||
      ' P_COUNTRY          VARCHAR2(100) := :P_COUNTRY; '||
      ' P_DU_DUNS          VARCHAR2(100) := :P_DU_DUNS; '||
      ' P_DU_NAME          VARCHAR2(360) := :P_DU_NAME; '||
      ' P_PARTY_NUMBER     VARCHAR2(30)  := :P_PARTY_NUMBER; '||
      ' P_GU_DUNS          VARCHAR2(100) := :P_GU_DUNS; '||
      ' P_GU_NAME          VARCHAR2(360) := :P_GU_NAME; '||
      ' P_CERT_LEVEL       VARCHAR2(30)  := :P_CERT_LEVEL; ' ||
      ' P_SALESPERSON      NUMBER        := :P_SALESPERSON; '||
      ' P_SALES_GROUP      NUMBER        := :P_SALES_GROUP; '||
      ' P_SALES_ROLE       VARCHAR2(100) := :P_SALES_ROLE; '||
      ' P_PARTY_TYPE       VARCHAR2(60)  := :P_PARTY_TYPE; ' || --vbghosh Added
      ' P_HIERARCHY_TYPE   VARCHAR2(60)  := :P_HIERARCHY_TYPE; ' ||
      ' P_RELATIONSHIP_ROLE VARCHAR2(60) := :P_RELATIONSHIP_ROLE; ' ||
      ' P_CLASS_TYPE       VARCHAR2(60)  := :P_CLASS_TYPE; ' ||
      ' P_CLASS_CODE       VARCHAR2(60)  := :P_CLASS_CODE; ' ||
      ' P_ANNUAL_REV_FROM  NUMBER        := :P_ANNUAL_REV_FROM; ' ||
      ' P_ANNUAL_REV_TO    NUMBER        := :P_ANNUAL_REV_TO; ' ||
      ' P_NUM_EMP_FROM     VARCHAR2(10)  := :P_NUM_EMP_FROM; ' ||
      ' P_NUM_EMP_TO       VARCHAR2(10)  := :P_NUM_EMP_TO; ' ||
      ' P_CUST_CATEGORY    VARCHAR2(60)  := :P_CUST_CATEGORY; ' ||
      ' P_IDENT_ADDR_FLAG  VARCHAR2(1)   := :P_IDADDR_FLAG; ' ||  -- end added
    ' BEGIN '||

      ' INSERT into JTF_TTY_WEBADI_INTERFACE ( ' ||
      '     USER_SEQUENCE ' ||
      ' ,USER_ID ' ||
      ' ,TERR_GRP_ACCT_ID ' ||
      ' ,JTF_TTY_WEBADI_INT_ID ' ||
      ' ,NAMED_ACCOUNT ' ||
      ' ,SITE_TYPE ' ||
      ' ,DUNS '||
      ' ,TRADE_NAME ' ||
      ' ,GU_DUNS ' ||
      ' ,GU_NAME ' ||
      ' ,DU_DUNS ' ||
      ' ,DU_NAME ' ||
      ' ,CITY ' ||
      ' ,STATE ' ||
      ' ,POSTAL_CODE ' ||
      ' ,TERRITORY_GROUP ' ||
      ' ,PARTY_NUMBER ' ||
      ' ,TO_TERRITORY_GROUP ' ||
      ' ,DELETE_FLAG ' ||
      ' ,CREATED_BY ' ||
      ' ,CREATION_DATE ' ||
      ' ,LAST_UPDATED_BY ' ||
      ' ,LAST_UPDATE_DATE ' ||
      ' ,PARTY_SITE_NUMBER ' ||
      ' ,SALES_MANAGER '||
      ' ,PHONETIC_NAME' ||
      ' ,IDENTIFYING_ADDRESS '||
	  '	, start_date '||
	  '	, end_date '||
	  '	, attribute1 '||
	  '	, attribute2 '||
	  '	, attribute3 '||
	  '	, attribute4 '||
	  '	, attribute5 '||
	  '	, attribute6 '||
	  '	, attribute7 '||
	  '	, attribute8 '||
	  '	, attribute9 '||
	  '	, attribute10 '||
	  '	, attribute11 '||
	  '	, attribute12 '||
	  '	, attribute13 '||
	  '	, attribute14 '||
	  '	, attribute15 ) '||
      ' SELECT ' ||
            g_seq || ' USER_SEQUENCE '||
      ' ,' ||  P_USERID || ' USER_ID '||
      ' ,TGAID TERR_GRP_ACCT_ID '||
      ' ,NAID JTF_TTY_WEBADI_INT_ID '||
      ' ,NAMED_ACCOUNT NAMED_ACCOUNT '||
      ' ,SITE_TYPE SITE_TYPE '||
      ' ,SITE_DUNS DUNS '||
      ' ,TRADE_NAME TRADE_NAME '||
      ' ,GU_DUNS GU_DUNS '||
      ' ,GU_NAME GU_NAME '||
      ' ,DU_DUNS DU_DUNS '||
      ' ,DU_NAME DU_NAME '||
      ' ,CITY CITY '||
      ' ,STATE STATE '||
      ' ,POSTAL_CODE POSTAL_CODE ' ||
      ' ,TERRGRPNAME TERRITORY_GROUP ' ||
      ' ,PARTY_NUMBER PARTY_NUMBER ' ||
      ' ,NULL TO_TERRITORY_GROUP ' ||
      ' ,''' || g_no_lookup || ''' DELETE_FLAG ' ||
      ' ,' ||  P_USERID || ' CREATED_BY '||
      ' ,''' || l_curr_date|| '''' || ' CREATION_DATE ' ||
      ' ,' ||  P_USERID || ' LAST_UPDATED_BY '||
      ' ,''' || l_curr_date|| '''' || ' LAST_UPDATE_DATE ' ||
      ' ,PARTY_SITE_NUMBER PARTY_SITE_NUMBER' ||
      ' ,null SALES_MANAGER ' ||
      ' ,PHONETIC_NAME PHONETIC_NAME' ||
      ' ,IDENTIFYING_ADDRESS_FLAG IDENTIFYING_ADDRESS' ||
	  '	, start_date '||
	  '	, end_date '||
	  '	, attribute1 '||
	  '	, attribute2 '||
	  '	, attribute3 '||
	  '	, attribute4 '||
	  '	, attribute5 '||
	  '	, attribute6 '||
	  '	, attribute7 '||
	  '	, attribute8 '||
	  '	, attribute9 '||
	  '	, attribute10 '||
	  '	, attribute11 '||
	  '	, attribute12 '||
	  '	, attribute13 '||
	  '	, attribute14 '||
	  '	, attribute15 '||
      ' FROM ( ' ||
      '    SELECT '||
      '         ga.terr_group_account_id tgaid ' ||
      '        ,na.named_account_id      naid ' ||
      '        ,hzp.party_name           named_account ' ||
      '        ,lkp.meaning              site_type  ' ||
      '        ,hzp.duns_number_c        site_duns ' ||
      '        ,hzp.known_as             trade_name ' ||
      '        ,GU.GU_DUNS               gu_duns  ' ||
      '        ,GU.GU_NAME               gu_name  ' ||
      '        ,null                     du_duns  ' ||
      '        ,null                     du_name  ' ||
      '        ,hzl.city                 city ' ||
      '        ,hzl.state                state ' ||
      '        ,hzl.postal_code          postal_code ' ||
      '        ,ttygrp.terr_group_name   terrgrpname ' ||
      '        ,hzp.party_number         party_number '||
      '        ,hzps.party_site_number   party_site_number '||
      '        ,identifying_address_flag identifying_address_flag ' ||
      '        ,decode(hzp.party_type, ''ORGANIZATION'',hzp.ORGANIZATION_NAME_PHONETIC, ' ||
      '                ''PERSON'',hzp.PERSON_LAST_NAME_PHONETIC || '', '' || hzp.PERSON_FIRST_NAME_PHONETIC,null) PHONETIC_NAME' ||
	  '	, ga.start_date '||
	  '	, ga.end_date '||
	  '		   ,ga.attribute1 '||
	  '		   ,ga.attribute2 '||
	  '		   ,ga.attribute3 '||
	  '		   ,ga.attribute4 '||
	  '		   ,ga.attribute5 '||
	  '		   ,ga.attribute6 '||
	  '		   ,ga.attribute7 '||
	  '		   ,ga.attribute8 '||
	  '		   ,ga.attribute9 '||
	  '		   ,ga.attribute10 '||
	  '		   ,ga.attribute11 '||
	  '		   ,ga.attribute12 '||
	  '		   ,ga.attribute13 '||
	  '		   ,ga.attribute14 '||
	  '		   ,ga.attribute15 '||
      '    FROM ' ||
      '         hz_parties hzp ' ||
      '        ,hz_locations hzl '||
      '        ,hz_party_sites hzps '||
      '        ,jtf_tty_named_accts na ' ||
      '        ,jtf_tty_terr_grp_accts ga ' ||
      '        ,fnd_lookups  lkp ' ||
      '        ,jtf_tty_terr_groups ttygrp ' ;

      /*vbghosh  Added start  */
      IF ( (P_ANNUAL_REV_FROM IS NOT NULL) OR
       (P_ANNUAL_REV_TO IS NOT NULL) OR
       (trim(P_NUM_EMP_FROM) IS NOT NULL) OR
       (trim(P_NUM_EMP_TO) IS NOT NULL) ) THEN
		l_na_query := l_na_query || ' ,hz_organization_profiles hzop ';
     END IF;

     l_na_query := l_na_query ||
      '        ,( /* Global Ultimate : min is used to make sre that there is 1 GU for each party */ ' ||
      '            SELECT min(gup.party_name) GU_NAME ' ||
      '                 , min(gup.duns_number_c) GU_DUNS ' ||
      '                 , hzr.object_id GU_OBJECT_ID ' ||
      '            FROM hz_parties  gup ' ||
      '               , hz_relationships hzr ' ||
      '            WHERE hzr.subject_table_name = ''HZ_PARTIES'' ' ||
      '              AND hzr.object_table_name  = ''HZ_PARTIES'' ' ||
      '              AND hzr.relationship_type  = ''GLOBAL_ULTIMATE'' ' ||
      '              AND hzr.relationship_code  = ''GLOBAL_ULTIMATE_OF'' ' ||
      '              AND hzr.status = ''A'' ' ||
      '              AND hzr.subject_id = gup.party_id ' ||
      '              AND gup.status = ''A'' ' ||
      '              GROUP BY hzr.object_id ) GU ' ||
      '    WHERE hzp.party_id       = na.party_id ' ||
      '    AND hzps.party_site_id   = na.party_site_id ' ||
      '    AND hzps.location_id     = hzl.location_id  ' ||
      '    AND hzp.party_id         = hzps.party_id ' ||
      '    AND na.site_type_code    = lkp.lookup_code ' ||
      '    AND lkp.lookup_type      = ''JTF_TTY_SITE_TYPE_CODE'' ' ||
      '    AND na.named_account_id  = ga.named_account_id ' ||
      '    AND ttygrp.terr_group_id = ga.terr_group_id ' ||
--      '    AND ttygrp.terr_group_id = :P_GRPID ' ||
      '    AND GU.GU_OBJECT_ID (+)  = hzp.party_id ';


     if ( P_GRPID is not null ) then
       l_na_query :=  l_na_query || ' AND ttygrp.terr_group_id = :P_GRPID ' ;
     end if;


	 IF ( p_org_id is not null OR P_ORG_ID <> -999 OR
	 	  P_GRPNAME is not null	OR P_VIEW_DATE is not null) THEN

  	   l_na_query := l_na_query || ' AND EXISTS ( SELECT 1 ' ||
        '  FROM jtf_terr_all jt ' ||
        '  WHERE jt.territory_type_id = -1 ';

       if ( P_ORG_ID is not null AND P_ORG_ID <> -999 ) THEN
         l_na_query := l_na_query || ' AND jt.org_id = :P_ORG_ID ';
  	   end if;

  	   if ( P_GRPNAME is not null ) then
         l_na_query :=  l_na_query || ' AND UPPER (jt.NAME) LIKE :P_GRPNAME ';
  	   end if;

       if ( P_VIEW_DATE is not null ) then
  	     l_na_query :=  l_na_query || ' AND :P_VIEW_DATE BETWEEN jt.start_date_active AND jt.end_date_active ' ;
  	   end if;

  	   l_na_query :=  l_na_query || ' AND jt.terr_group_account_id = ga.TERR_GROUP_ACCOUNT_ID ) ' ;
	 END IF; -- add exist query for jtf_terr_all table


  IF ( (P_ANNUAL_REV_FROM IS NOT NULL) OR
       (P_ANNUAL_REV_TO IS NOT NULL) OR
       (trim(P_NUM_EMP_FROM) IS NOT NULL) OR
       (trim(P_NUM_EMP_TO) IS NOT NULL) ) THEN
    l_na_query := l_na_query || ' AND hzp.party_id = hzop.party_id ' ||
                                ' AND hzop.status = ''A'' ' ||
                                ' AND ( (sysdate >= hzop.effective_start_date) AND ' ||
                                    ' ( ( hzop.effective_end_date IS NULL ) OR ' ||
                                      ' ( sysdate <= hzop.effective_end_date) ) ' ||
                                     ' ) ';

  END IF;


  IF (trim(P_IDADDR_FLAG) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzps.identifying_address_flag = :P_IDADDR_FLAG ' ;
    l_useExistsClause := 'Y';
  END IF;


/* vbghosh Added end */

  IF ((trim(P_SITE_TYPE) IS NOT NULL) AND (P_SITE_TYPE <> 'ALL')) THEN
    l_na_query :=  l_na_query || 'AND lkp.lookup_code = :P_SITE_TYPE ';
  END IF;

  IF (trim(P_SICCODE) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzp.sic_code = :P_SICCODE ' ;
    l_useExistsClause := 'Y';
  END IF;

  --vbghosh added
  IF (trim(P_SICCODE_TYPE) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzp.sic_code_type = :P_SICCODE_TYPE ' ;
  END IF;

 --vbghosh Added
 IF ( (CONTAINS_ONLY_PCTG(P_NAMED_ACCOUNT)) AND
      (trim(P_RELATIONSHIP_ROLE) IS NULL) ) THEN
    l_na_query :=  l_na_query || 'AND upper(hzp.party_name) like :P_NAMED_ACCOUNT ' ;
    l_useExistsClause := 'Y';
  END IF;


   IF ((trim(P_SITE_DUNS) IS NOT NULL) AND
     (trim(P_RELATIONSHIP_ROLE) IS NULL) ) THEN
    l_na_query :=  l_na_query || 'AND hzp.duns_number_c = :P_SITE_DUNS ' ;
    l_useExistsClause := 'Y';
  END IF;



  IF (trim(P_CITY) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND upper(hzl.city) like :P_CITY ';
  END IF;

  IF (trim(P_STATE) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzl.state = :P_STATE ';
  END IF;

  IF (trim(P_PROVINCE) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzl.province = :P_PROVINCE ' ;
  END IF;

  IF ((trim(P_POSTAL_CODE_FROM) IS NOT NULL) AND (trim(P_POSTAL_CODE_TO) IS NOT NULL)
      AND (P_POSTAL_CODE_FROM = P_POSTAL_CODE_TO)) THEN
    l_na_query :=  l_na_query || 'AND hzl.postal_code = :P_POSTAL_CODE_FROM ';

  ELSIF ((trim(P_POSTAL_CODE_FROM) IS NOT NULL) AND (trim(P_POSTAL_CODE_TO) IS NOT NULL)
         AND (P_POSTAL_CODE_FROM <> P_POSTAL_CODE_TO))  THEN
    l_na_query :=  l_na_query || 'AND hzl.postal_code between :P_POSTAL_CODE_FROM and :P_POSTAL_CODE_TO ';

  ELSIF ((trim(P_POSTAL_CODE_FROM) IS NOT NULL) AND (trim(P_POSTAL_CODE_TO) IS NULL))  THEN
    l_na_query :=  l_na_query || 'AND hzl.postal_code = :P_POSTAL_CODE_FROM ';

  ELSIF ((trim(P_POSTAL_CODE_FROM) IS NULL) AND (trim(P_POSTAL_CODE_TO) IS NOT NULL)) THEN
    l_na_query :=  l_na_query || 'AND hzl.postal_code = :P_POSTAL_CODE_TO ' ;
  END IF;

  IF (trim(P_COUNTRY) IS NOT NULL) THEN
    l_na_query :=  l_na_query || 'AND hzl.country = :P_COUNTRY ';
  END IF;


  IF ((trim(P_DU_DUNS) IS NOT NULL) OR (trim(P_DU_NAME) IS NOT NULL)) THEN
    l_na_query :=  l_na_query ||
          ' and hzp.party_id in ' ||
          '       ( select hzr.object_id '||
          '         from   hz_parties hzp1, ' ||
          '                hz_relationships hzr '||
          '         where hzp1.party_id = hzr.subject_id '||
          '         and hzr.subject_table_name = ''HZ_PARTIES'' '||
          '         and hzr.object_table_name  = ''HZ_PARTIES'' '||
          '         and hzr.relationship_type  = ''DOMESTIC_ULTIMATE'' '||
          '         and hzr.relationship_code  = ''DOMESTIC_ULTIMATE_OF'' '||
          '         and hzr.status = ''A'' ';

    IF (trim(P_DU_DUNS) IS NOT NULL) THEN
            l_na_query :=  l_na_query || ' and hzp1.duns_number_c = :P_DU_DUNS ';
    END IF;
    IF (CONTAINS_ONLY_PCTG(P_DU_NAME)) THEN
            l_na_query :=  l_na_query || ' and upper(hzp1.party_name) like :P_DU_NAME ';
    END IF;
    l_na_query :=  l_na_query || ')';
  END IF;

 --vbghosh added
  IF ((trim(P_PARTY_NUMBER) IS NOT NULL) AND
       (trim(P_RELATIONSHIP_ROLE) IS NULL) )  THEN
    l_na_query :=  l_na_query || 'AND hzp.party_number = :P_PARTY_NUMBER ';
    l_useExistsClause := 'Y';
  END IF;


  --vbghosh added
  -- Annual Revenue
  IF ((P_ANNUAL_REV_FROM IS NOT NULL) AND (P_ANNUAL_REV_TO IS NOT NULL)
      AND (P_ANNUAL_REV_FROM = P_ANNUAL_REV_TO)) THEN
    l_na_query :=  l_na_query || 'AND hzop.curr_fy_potential_revenue = :P_ANNUAL_REV_FROM ';

  ELSIF ((P_ANNUAL_REV_FROM IS NOT NULL) AND (P_ANNUAL_REV_TO IS NOT NULL)
         AND (P_ANNUAL_REV_FROM <> P_ANNUAL_REV_TO))  THEN
    l_na_query :=  l_na_query || 'AND hzop.curr_fy_potential_revenue between :P_ANNUAL_REV_FROM and :P_ANNUAL_REV_TO ';

  ELSIF ((P_ANNUAL_REV_FROM IS NOT NULL) AND (P_ANNUAL_REV_TO IS NULL))  THEN
    l_na_query :=  l_na_query || 'AND hzop.curr_fy_potential_revenue >= :P_ANNUAL_REV_FROM ';

  ELSIF ((P_ANNUAL_REV_FROM IS NULL) AND (P_ANNUAL_REV_TO IS NOT NULL)) THEN
    l_na_query :=  l_na_query || 'AND hzop.curr_fy_potential_revenue <= :P_ANNUAL_REV_TO ' ;
  END IF;

  --vbghosh added
   -- Number of Employees

  IF ((trim(P_NUM_EMP_FROM) IS NOT NULL) AND (trim(P_NUM_EMP_TO) IS NOT NULL)
      AND (P_NUM_EMP_FROM = P_NUM_EMP_TO)) THEN
    l_na_query :=  l_na_query || 'AND hzop.emp_at_primary_adr = :P_NUM_EMP_FROM ';

  ELSIF ((trim(P_NUM_EMP_FROM) IS NOT NULL) AND (trim(P_NUM_EMP_TO) IS NOT NULL)
         AND (P_NUM_EMP_FROM <> P_NUM_EMP_TO))  THEN
    l_na_query :=  l_na_query || 'AND hzop.emp_at_primary_adr between :P_NUM_EMP_FROM and :P_NUM_EMP_TO ';

  ELSIF ((trim(P_NUM_EMP_FROM) IS NOT NULL) AND (trim(P_NUM_EMP_TO) IS NULL))  THEN
    l_na_query :=  l_na_query || 'AND hzop.emp_at_primary_adr = :P_NUM_EMP_FROM ';

  ELSIF ((trim(P_NUM_EMP_FROM) IS NULL) AND (trim(P_NUM_EMP_TO) IS NOT NULL)) THEN
    l_na_query :=  l_na_query || 'hzop.emp_at_primary_adr = :P_NUM_EMP_TO ' ;
  END IF;

  --vbghosh added
 IF (trim(P_HIERARCHY_TYPE) IS NOT NULL) AND
     (trim(P_RELATIONSHIP_ROLE) IS NOT NULL) THEN

      IF l_useExistsClause = 'Y' THEN
        l_na_query :=  l_na_query || ' AND EXISTS ( SELECT null ';
      ELSE
        l_na_query :=  l_na_query || ' AND hzp.party_id IN ( SELECT b.subject_id ';
      END IF;

      l_na_query :=  l_na_query || 'FROM hz_relationships b, hz_parties c ';
      l_na_query :=  l_na_query || 'WHERE b.object_id = c.party_id ';

      IF l_useExistsClause = 'Y' THEN
            l_na_query :=  l_na_query || 'AND b.subject_id = hzp.party_id ' ;
      END IF;

      l_na_query :=  l_na_query || 'AND b.subject_table_name = ''HZ_PARTIES'' ';
      l_na_query :=  l_na_query || 'AND b.object_table_name = ''HZ_PARTIES'' ';
      l_na_query :=  l_na_query || 'AND b.status = ''A'' ';
      l_na_query :=  l_na_query || 'AND b.relationship_type = :P_HIERARCHY_TYPE ';
      l_na_query :=  l_na_query || 'AND b.relationship_code = :P_RELATIONSHIP_ROLE ';

      IF (CONTAINS_ONLY_PCTG(P_NAMED_ACCOUNT)) THEN
           l_na_query :=  l_na_query || 'AND upper(c.party_name) like :P_NAMED_ACCOUNT ' ;
      END IF;


      IF (trim(P_SITE_DUNS) IS NOT NULL) THEN
          l_na_query :=  l_na_query || 'AND c.duns_number_c = :P_SITE_DUNS ' ;
      END IF;

      IF (trim(P_PARTY_NUMBER) IS NOT NULL) THEN
         l_na_query :=  l_na_query || 'AND c.party_number = :P_PARTY_NUMBER ';
      END IF;

      l_na_query :=  l_na_query || ')';
  END IF;

  --vbghosh added
  IF (trim(P_CLASS_TYPE) IS NOT NULL) THEN

      IF l_useExistsClause = 'Y' THEN
         l_na_query :=  l_na_query || ' AND EXISTS ( SELECT null ';
      ELSE
       l_na_query :=  l_na_query || ' AND hzp.party_id IN ( SELECT hca.owner_table_id ' ;
      END IF;

       l_na_query :=  l_na_query || 'FROM hz_code_assignments hca ' ;
       l_na_query :=  l_na_query || 'WHERE hca.status = ''A'' ';
       l_na_query :=  l_na_query || 'AND sysdate >= hca.start_date_active ';
       l_na_query :=  l_na_query || 'AND ( hca.end_date_active IS NULL OR ';
       l_na_query :=  l_na_query || ' sysdate <= hca.end_date_active ) ';
       l_na_query :=  l_na_query || 'AND hca.class_category = :P_CLASS_TYPE ';


       IF (trim(P_CLASS_CODE) IS NOT NULL) THEN
          l_na_query :=  l_na_query || ' AND hca.class_code = :P_CLASS_CODE ';
       END IF;

       IF l_useExistsClause = 'Y' THEN
               l_na_query :=  l_na_query || ' AND hca.owner_table_id = hzp.party_id ';
       END IF;

      l_na_query :=  l_na_query || ')';
   END IF;




  IF (trim(P_GU_DUNS) IS NOT NULL) THEN
    l_na_query :=  l_na_query || ' and gu.gu_duns = :P_GU_DUNS ';
  END IF;

  IF (CONTAINS_ONLY_PCTG(P_GU_NAME)) THEN
    l_na_query :=  l_na_query || ' and upper(gu.gu_name) LIKE :P_GU_NAME ';
  END IF;

  IF ((trim(P_CERT_LEVEL) IS NOT NULL) AND (P_CERT_LEVEL <> 'ALL')) THEN
    l_na_query :=  l_na_query || ' and hzp.certification_level = :P_CERT_LEVEL ';
  END IF;

  IF ((trim(P_SALESPERSON) IS NOT NULL) OR
       (trim(P_SALES_GROUP) IS NOT NULL) OR
       (trim(P_SALES_ROLE) IS NOT NULL)) THEN



    IF ((trim(P_SALESPERSON) IS NOT NULL) AND
         (trim(P_SALES_GROUP) IS NULL) AND
         (trim(P_SALES_ROLE) IS NULL)) THEN
      l_na_query :=  l_na_query || ' and ga.terr_group_account_id in ( ';
      l_na_query :=  l_na_query ||
                  ' select /*+ NO_MERGE */ narsc1.terr_group_account_id ' ||
                  ' from jtf_tty_named_acct_rsc narsc1, ' ||
                  '      ( SELECT dir.resource_id, ' ||
                  '               MY_GRPS.group_id , ' ||
                  '               MY_GRPS.CURRENT_USER_ID ' ||
                  '        FROM jtf_rs_group_members grpmemo , ' ||
                  '             jtf_rs_resource_extns dir , ' ||
                  '             ( SELECT /*+ NO_MERGE */ dv.group_id , ' ||
                  '                      mrsc.user_id CURRENT_USER_ID  ' ||
                  '               FROM jtf_rs_group_usages usg , ' ||
                  '                    jtf_rs_groups_denorm dv , ' ||
                  '                    jtf_rs_rep_managers sgh , ' ||
                  '                    jtf_rs_resource_extns mrsc , ' ||
                  '                    jtf_rs_roles_b rol , ' ||
                  '                    jtf_rs_role_relations rlt ' ||
                  '               WHERE usg.usage = ''SALES'' ' ||
                  '               AND usg.group_id = dv.group_id ' ||
                  '               AND rlt.role_id = rol.role_id ' ||
                  '               AND rlt.role_relate_id = sgh.par_role_relate_id ' ||
                  '               AND dv.parent_group_id = sgh.group_id ' ||
                  '               AND sgh.resource_id = sgh.parent_resource_id ' ||
                  '               AND (sgh.hierarchy_type IN (''MGR_TO_MGR'') ' ||
                  '                        OR rol.role_code = FND_PROFILE.VALUE(''JTF_TTY_NA_PROXY_USER_ROLE'')) ' ||
                  '               AND mrsc.resource_id = sgh.resource_id ' ||
                  '             ) MY_GRPS ' ||
                  '        WHERE grpmemo.resource_id = dir.resource_id ' ||
                  '        AND grpmemo.group_id = MY_GRPS.group_id ' ||
                  '        UNION ALL  ' ||
                  '        SELECT dir.resource_id , ' ||
                  '               grpmemo.group_id , ' ||
                  '               dir.user_id CURRENT_USER_ID ' ||
                  '        FROM jtf_rs_group_members grpmemo , ' ||
                  '             jtf_rs_resource_extns dir , ' ||
                  '             jtf_rs_group_usages usg ' ||
                  '        WHERE usg.usage = ''SALES'' ' ||
                  '        AND grpmemo.resource_id = dir.resource_id ' ||
                  '        AND grpmemo.group_id = usg.group_id ' ||
                  '      ) repdn1 ' ||
                  ' where narsc1.resource_id = repdn1.resource_id ' ||
                  ' and narsc1.rsc_group_id = repdn1.group_id ' ||
                  ' and repdn1.current_user_id = :P_SALESPERSON ';

    END IF;

    IF ((trim(P_SALES_GROUP) IS NOT NULL) AND
         (trim(P_SALESPERSON) IS NULL) AND
         (trim(P_SALES_ROLE) IS NULL)) THEN
      l_na_query :=  l_na_query || ' and ga.terr_group_account_id in ( ';
      l_na_query :=  l_na_query ||
                  ' select narsc1.terr_group_account_id '||
                  ' from jtf_tty_named_acct_rsc narsc1, '||
                  '      jtf_rs_group_members mem1, '||
                  '      jtf_rs_groups_denorm grpdn1 '||
                  ' where narsc1.resource_id = mem1.resource_id '||
                  ' and narsc1.rsc_group_id = mem1.group_id  '||
                  ' and mem1.delete_flag = ''N''  '||
                  ' and mem1.group_id = grpdn1.group_id  '||
                  ' and SYSDATE BETWEEN NVL(grpdn1.start_date_active, SYSDATE-1)  '||
                  ' AND NVL(grpdn1.end_date_active, SYSDATE+1) '||
                  ' and grpdn1.parent_group_id = :P_SALES_GROUP ';
    END IF;

    IF ((trim(P_SALES_ROLE) IS NOT NULL) AND
          (trim(P_SALESPERSON) IS NULL) AND
          (trim(P_SALES_GROUP) IS NULL)) THEN
      l_na_query :=  l_na_query || ' and EXISTS ( ';
      l_na_query :=  l_na_query ||
                 ' select narsc1.terr_group_account_id '||
                 ' from jtf_tty_named_acct_rsc narsc1, '||
                 --'      jtf_rs_rep_managers mgr, '||
                 '      jtf_rs_rep_managers mgr1, '||
                 '      jtf_rs_role_relations rlt, '||
                 '      jtf_rs_roles_b rol '||
                 ' where mgr1.resource_id = narsc1.resource_id '||
                 ' and mgr1.group_id = narsc1.rsc_group_id '||
                 ' and ga.terr_group_account_id = narsc1.terr_group_account_id ' ||
                -- ' and mgr1.parent_resource_id = mgr.resource_id '||
                 ' and mgr1.par_role_relate_id = rlt.role_relate_id '||
                 ' and rlt.role_id = rol.role_id '||
                 ' and rlt.role_resource_type = ''RS_GROUP_MEMBER'' '||
                 ' and rlt.delete_flag = ''N'' '||
                 ' and SYSDATE BETWEEN rlt.start_date_active AND NVL(rlt.end_date_active, SYSDATE+1) '||
                 ' and rol.role_code = :P_SALES_ROLE ';
    END IF;

    IF ((trim(P_SALESPERSON) IS NOT NULL) AND
            (trim(P_SALES_GROUP) IS NOT NULL) AND
            (trim(P_SALES_ROLE)  IS NULL)) THEN
      l_na_query :=  l_na_query || ' and ga.terr_group_account_id in ( ';
      l_na_query :=  l_na_query ||
                 ' select narsc1.terr_group_account_id '||
                 ' from jtf_tty_named_acct_rsc narsc1, '||
                 '      jtf_tty_my_resources_v repdn1 '||
                 ' where narsc1.resource_id = repdn1.resource_id '||
                 ' and narsc1.rsc_group_id = repdn1.group_id '||
                 ' and repdn1.current_user_id = :P_SALESPERSON '||
                 ' and repdn1.parent_group_id = :P_SALES_GROUP ';
    END IF;

    IF ((trim(P_SALESPERSON) IS NOT NULL) AND
          (trim(P_SALES_GROUP) IS NULL) AND
          (trim(P_SALES_ROLE)  IS NOT NULL)) THEN
      l_na_query :=  l_na_query || ' and ga.terr_group_account_id in ( ';
      l_na_query :=  l_na_query ||
                 ' select narsc1.terr_group_account_id '||
                 '  from jtf_tty_named_acct_rsc narsc1, '||
                 '        jtf_tty_my_resources_v repdn1 '||
                 ' where narsc1.resource_id = repdn1.resource_id '||
                 ' and narsc1.rsc_group_id = repdn1.group_id '||
                 ' and repdn1.current_user_id = :P_SALESPERSON '||
                 ' and repdn1.current_user_role_code = :P_SALES_ROLE ';
    END IF;

    IF ((trim(P_SALESPERSON) IS NULL) AND
          (trim(P_SALES_GROUP) IS NOT NULL) AND
          (trim(P_SALES_ROLE)  IS NOT NULL)) THEN
      l_na_query :=  l_na_query || ' and EXISTS ( ';
      l_na_query :=  l_na_query ||
                 ' select narsc1.terr_group_account_id '||
                 ' from jtf_tty_named_acct_rsc narsc1, '||
              --   '      jtf_rs_rep_managers mgr, '||
                 '      jtf_rs_rep_managers mgr1, '||
                 '      jtf_rs_role_relations rlt, '||
                 '      jtf_rs_roles_b rol, '||
                 '      jtf_rs_groups_denorm grpdn '||
                 ' where mgr1.resource_id = narsc1.resource_id '||
                 ' and mgr1.group_id = narsc1.rsc_group_id '||
                 --' and mgr1.parent_resource_id = mgr.resource_id '||
                 ' and ga.terr_group_account_id = narsc1.terr_group_account_id ' ||
                 ' and mgr1.par_role_relate_id = rlt.role_relate_id '||
                 ' and rlt.role_id = rol.role_id '||
                 ' and rlt.role_resource_type = ''RS_GROUP_MEMBER'' '||
                 ' and rlt.delete_flag = ''N'' '||
                 ' and SYSDATE BETWEEN rlt.start_date_active AND NVL(rlt.end_date_active, SYSDATE+1) '||
                 ' and rol.role_code = :P_SALES_ROLE '||
                 ' and mgr.group_id = grpdn.group_id  '||
                 ' and grpdn.parent_group_id = :P_SALES_GROUP ';
    END IF;

    IF ((trim(P_SALESPERSON) IS NOT NULL) AND
         (trim(P_SALES_GROUP) IS NOT NULL) AND
         (trim(P_SALES_ROLE)  IS NOT NULL)) THEN
      l_na_query :=  l_na_query || ' and ga.terr_group_account_id in ( ';
      l_na_query :=  l_na_query ||
                ' select narsc1.terr_group_account_id '||
                ' from jtf_tty_named_acct_rsc narsc1, '||
                '      jtf_tty_my_resources_v repdn1 '||
                ' where narsc1.resource_id = repdn1.resource_id '||
                ' and narsc1.rsc_group_id = repdn1.group_id '||
                ' and repdn1.current_user_id = :P_SALESPERSON ' ||
                ' and repdn1.parent_group_id = :P_SALES_GROUP '||
                ' and repdn1.current_user_role_code = :P_SALES_ROLE ';
    END IF;

    l_na_query :=  l_na_query || ') ';
  END IF; -- end of p_salessperson or p_selasgrp or p_selaesrole is not null

   IF ((trim(P_SALESPERSON) IS NOT NULL) OR
            (trim(P_SALES_GROUP) IS NOT NULL) OR
            (trim(P_SALES_ROLE)  IS NOT NULL)) THEN

    l_na_query :=  l_na_query || ' ) ';
    l_na_query := l_na_query || ' WHERE ROWNUM <= ' || TO_CHAR(g_rows_limit + 1) || ';';
    l_na_query := l_na_query || ':X_ROWS_INSERTED := SQL%ROWCOUNT; ';
    l_na_query :=  l_na_query || ' end; ';
   ELSE
    l_na_query := l_na_query || ' AND ROWNUM <= ' || TO_CHAR(g_rows_limit + 1);
    l_na_query :=  l_na_query || ' ); ';
    l_na_query := l_na_query || ':X_ROWS_INSERTED := SQL%ROWCOUNT; ';
    l_na_query :=  l_na_query || ' end; ';
   END IF;
  /* end of the pl/sql block */

  IF (CONTAINS_ONLY_PCTG(P_NAMED_ACCOUNT)) THEN
    P_NAMED_ACCOUNT_STR    := UPPER(P_NAMED_ACCOUNT) || '%';
  END IF;

  IF (CONTAINS_ONLY_PCTG(P_DU_NAME)) THEN
    P_DU_NAME_STR          := UPPER(P_DU_NAME)||'%';
  END IF;
  IF (CONTAINS_ONLY_PCTG(P_GU_NAME)) THEN
    P_GU_NAME_STR          := UPPER(P_GU_NAME)||'%';
  END IF;

  commit;

  --P(l_na_query);

  /* execute the pl/sql block and commit */
  /* add all the param in order of declare */
  EXECUTE IMMEDIATE l_na_query USING P_USERID,P_GRPID,P_VIEW_DATE,P_ORG_ID,
  		  					   		 P_GRPNAME,P_SITE_TYPE,P_SICCODE,P_SITE_DUNS,
                                     P_NAMED_ACCOUNT_STR,P_CITY,P_STATE,P_PROVINCE,P_POSTAL_CODE_FROM,
                                     P_POSTAL_CODE_TO,P_COUNTRY,P_DU_DUNS,P_DU_NAME_STR,P_PARTY_NUMBER,P_GU_DUNS,
                                     P_GU_NAME_STR,P_CERT_LEVEL,P_SALESPERSON,P_SALES_GROUP,P_SALES_ROLE, P_PARTY_TYPE,
				     				 P_HIERARCHY_TYPE, P_RELATIONSHIP_ROLE,P_CLASS_TYPE, P_CLASS_CODE,
                                     P_ANNUAL_REV_FROM, P_ANNUAL_REV_TO, P_NUM_EMP_FROM,P_NUM_EMP_TO,
				     				 P_CUST_CATEGORY, P_IDADDR_FLAG , OUT X_ROWS_INSERTED;

  COMMIT;


  --dbms_output.put_line('Rows inserted: '|| X_ROWS_INSERTED);
  /* NAs are populated, now start collect sales persons */

  /* populate slots */
  i:=1;

  FOR stat IN getStatistic(p_userid) LOOP
    IF i+stat.num-1 <=30 THEN
      FOR k IN i..i+stat.num-1 LOOP
        COL_ROLE(k) := stat.role_code;
      END LOOP;
    ELSE
      g_seq := 0;
      x_retcode := '-1';
      x_errbuf := 'More than 30 sales persons.';
      RETURN;
    END IF;

    i:=i+stat.num;
  END LOOP;


  /* for each NA_ID */
  FOR m IN getNAFromInterface(p_userid) LOOP

    /* clear col_used flags */
    COL_USED        :=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    RESOURCE_NAME   :=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
    GROUP_NAME      :=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
    ROLE_NAME       :=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
    RESOURCE_ATTRIBUTE1       :=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
    RESOURCE_ATTRIBUTE2       :=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  RESOURCE_ATTRIBUTE3     :=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  RESOURCE_ATTRIBUTE4     :=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  RESOURCE_ATTRIBUTE5     :=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  RESOURCE_START_DATE     :=DARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
  RESOURCE_END_DATE     :=DARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

    /* get all sales for this NA */
    FOR SALES IN getSalesperson(m.terr_grp_acct_id ) LOOP

      FOR j IN 1..30 LOOP -- look into 30 slots
        IF SALES.role_code = COL_ROLE(j) AND COL_USED(j)=0 THEN
          COL_USED(j)     :=1;
          RESOURCE_NAME(j):=SALES.resource_name;
          GROUP_NAME(j)   :=SALES.group_name;
          ROLE_NAME(j)    :=SALES.role_name;
		  RESOURCE_ATTRIBUTE1(j) := SALES.ATTRIBUTE1;
		  RESOURCE_ATTRIBUTE2(j) := SALES.ATTRIBUTE2;
  		  RESOURCE_ATTRIBUTE3(j) := SALES.ATTRIBUTE3;
		  RESOURCE_ATTRIBUTE4(j) := SALES.ATTRIBUTE4;
		  RESOURCE_ATTRIBUTE5(j) := SALES.ATTRIBUTE5;
		  RESOURCE_START_DATE(j) := SALES.START_DATE;
		  RESOURCE_END_DATE(j) := SALES.END_DATE;

          EXIT;
        END IF;
      END LOOP; -- of slotting
    END LOOP; -- of SALES


    UPDATE JTF_TTY_WEBADI_INTERFACE -- /*+ INDEX JTF_TTY_WEBADI_INTF_N2 */
    SET    RESOURCE1_NAME=RESOURCE_NAME(1),GROUP1_NAME=GROUP_NAME(1),ROLE1_NAME=ROLE_NAME(1),
		   RESOURCE1_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(1), RESOURCE1_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(1),
		   RESOURCE1_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(1), RESOURCE1_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(1),
		   RESOURCE1_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(1),RESOURCE1_START_DATE=RESOURCE_START_DATE(1),RESOURCE1_END_DATE=RESOURCE_END_DATE(1),
           RESOURCE2_NAME=RESOURCE_NAME(2),GROUP2_NAME=GROUP_NAME(2),ROLE2_NAME=ROLE_NAME(2),
		   RESOURCE2_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(2), RESOURCE2_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(2),
		   RESOURCE2_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(2), RESOURCE2_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(2),
		   RESOURCE2_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(2),RESOURCE2_START_DATE=RESOURCE_START_DATE(2),RESOURCE2_END_DATE=RESOURCE_END_DATE(2),
           RESOURCE3_NAME=RESOURCE_NAME(3),GROUP3_NAME=GROUP_NAME(3),ROLE3_NAME=ROLE_NAME(3),
		   RESOURCE3_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(3), RESOURCE3_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(3),
		   RESOURCE3_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(3), RESOURCE3_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(3),
		   RESOURCE3_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(3),RESOURCE3_START_DATE=RESOURCE_START_DATE(3),RESOURCE3_END_DATE=RESOURCE_END_DATE(3),
           RESOURCE4_NAME=RESOURCE_NAME(4),GROUP4_NAME=GROUP_NAME(4),ROLE4_NAME=ROLE_NAME(4),
		   RESOURCE4_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(4), RESOURCE4_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(4),
		   RESOURCE4_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(4), RESOURCE4_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(4),
		   RESOURCE4_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(4),RESOURCE4_START_DATE=RESOURCE_START_DATE(4),RESOURCE4_END_DATE=RESOURCE_END_DATE(4),
           RESOURCE5_NAME=RESOURCE_NAME(5),GROUP5_NAME=GROUP_NAME(5),ROLE5_NAME=ROLE_NAME(5),
		   RESOURCE5_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(5), RESOURCE5_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(5),
		   RESOURCE5_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(5), RESOURCE5_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(5),
		   RESOURCE5_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(5),RESOURCE5_START_DATE=RESOURCE_START_DATE(5),RESOURCE5_END_DATE=RESOURCE_END_DATE(5),
           RESOURCE6_NAME=RESOURCE_NAME(6),GROUP6_NAME=GROUP_NAME(6),ROLE6_NAME=ROLE_NAME(6),
		   RESOURCE6_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(6), RESOURCE6_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(6),
		   RESOURCE6_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(6), RESOURCE6_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(6),
		   RESOURCE6_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(6),RESOURCE6_START_DATE=RESOURCE_START_DATE(6),RESOURCE6_END_DATE=RESOURCE_END_DATE(6),
           RESOURCE7_NAME=RESOURCE_NAME(7),GROUP7_NAME=GROUP_NAME(7),ROLE7_NAME=ROLE_NAME(7),
		   RESOURCE7_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(7), RESOURCE7_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(7),
		   RESOURCE7_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(7), RESOURCE7_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(7),
		   RESOURCE7_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(7),RESOURCE7_START_DATE=RESOURCE_START_DATE(7),RESOURCE7_END_DATE=RESOURCE_END_DATE(7),
           RESOURCE8_NAME=RESOURCE_NAME(8),GROUP8_NAME=GROUP_NAME(8),ROLE8_NAME=ROLE_NAME(8),
		   RESOURCE8_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(8), RESOURCE8_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(8),
		   RESOURCE8_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(8), RESOURCE8_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(8),
		   RESOURCE8_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(8),RESOURCE8_START_DATE=RESOURCE_START_DATE(8),RESOURCE8_END_DATE=RESOURCE_END_DATE(8),
           RESOURCE9_NAME=RESOURCE_NAME(9),GROUP9_NAME=GROUP_NAME(9),ROLE9_NAME=ROLE_NAME(9),
		   RESOURCE9_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(9), RESOURCE9_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(9),
		   RESOURCE9_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(9), RESOURCE9_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(9),
		   RESOURCE9_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(9),RESOURCE9_START_DATE=RESOURCE_START_DATE(9),RESOURCE9_END_DATE=RESOURCE_END_DATE(9),
           RESOURCE10_NAME=RESOURCE_NAME(10),GROUP10_NAME=GROUP_NAME(10),ROLE10_NAME=ROLE_NAME(10),
		   RESOURCE10_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(10), RESOURCE10_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(10),
		   RESOURCE10_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(10), RESOURCE10_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(10),
		   RESOURCE10_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(10),RESOURCE10_START_DATE=RESOURCE_START_DATE(10),
		   RESOURCE10_END_DATE=RESOURCE_END_DATE(10),
           RESOURCE11_NAME=RESOURCE_NAME(11),GROUP11_NAME=GROUP_NAME(11),ROLE11_NAME=ROLE_NAME(11),
		   RESOURCE11_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(11), RESOURCE11_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(11),
		   RESOURCE11_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(11), RESOURCE11_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(11),
		   RESOURCE11_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(11),RESOURCE11_START_DATE=RESOURCE_START_DATE(11),
		   RESOURCE11_END_DATE=RESOURCE_END_DATE(11),
           RESOURCE12_NAME=RESOURCE_NAME(12),GROUP12_NAME=GROUP_NAME(12),ROLE12_NAME=ROLE_NAME(12),
		   RESOURCE12_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(12), RESOURCE12_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(12),
		   RESOURCE12_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(12), RESOURCE12_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(12),
		   RESOURCE12_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(12),RESOURCE12_START_DATE=RESOURCE_START_DATE(12),
		   RESOURCE12_END_DATE=RESOURCE_END_DATE(12),
           RESOURCE13_NAME=RESOURCE_NAME(13),GROUP13_NAME=GROUP_NAME(13),ROLE13_NAME=ROLE_NAME(13),
		   RESOURCE13_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(13), RESOURCE13_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(13),
		   RESOURCE13_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(13), RESOURCE13_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(13),
		   RESOURCE13_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(13),RESOURCE13_START_DATE=RESOURCE_START_DATE(13),
		   RESOURCE13_END_DATE=RESOURCE_END_DATE(13),
           RESOURCE14_NAME=RESOURCE_NAME(14),GROUP14_NAME=GROUP_NAME(14),ROLE14_NAME=ROLE_NAME(14),
		   RESOURCE14_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(14), RESOURCE14_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(14),
		   RESOURCE14_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(14), RESOURCE14_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(14),
		   RESOURCE14_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(14),RESOURCE14_START_DATE=RESOURCE_START_DATE(14),
		   RESOURCE14_END_DATE=RESOURCE_END_DATE(14),
           RESOURCE15_NAME=RESOURCE_NAME(15),GROUP15_NAME=GROUP_NAME(15),ROLE15_NAME=ROLE_NAME(15),
		   RESOURCE15_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(15), RESOURCE15_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(15),
		   RESOURCE15_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(15), RESOURCE15_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(15),
		   RESOURCE15_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(15),RESOURCE15_START_DATE=RESOURCE_START_DATE(15),
		   RESOURCE15_END_DATE=RESOURCE_END_DATE(15),
           RESOURCE16_NAME=RESOURCE_NAME(16),GROUP16_NAME=GROUP_NAME(16),ROLE16_NAME=ROLE_NAME(16),
		   RESOURCE16_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(16), RESOURCE16_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(16),
		   RESOURCE16_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(16), RESOURCE16_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(16),
		   RESOURCE16_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(16),RESOURCE16_START_DATE=RESOURCE_START_DATE(16),
		   RESOURCE16_END_DATE=RESOURCE_END_DATE(16),
           RESOURCE17_NAME=RESOURCE_NAME(17),GROUP17_NAME=GROUP_NAME(17),ROLE17_NAME=ROLE_NAME(17),
		   RESOURCE17_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(17), RESOURCE17_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(17),
		   RESOURCE17_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(17), RESOURCE17_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(17),
		   RESOURCE17_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(17),RESOURCE17_START_DATE=RESOURCE_START_DATE(17),
		   RESOURCE17_END_DATE=RESOURCE_END_DATE(17),
           RESOURCE18_NAME=RESOURCE_NAME(18),GROUP18_NAME=GROUP_NAME(18),ROLE18_NAME=ROLE_NAME(18),
		   RESOURCE18_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(18), RESOURCE18_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(18),
		   RESOURCE18_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(18), RESOURCE18_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(18),
		   RESOURCE18_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(18),RESOURCE18_START_DATE=RESOURCE_START_DATE(18),
		   RESOURCE18_END_DATE=RESOURCE_END_DATE(18),
           RESOURCE19_NAME=RESOURCE_NAME(19),GROUP19_NAME=GROUP_NAME(19),ROLE19_NAME=ROLE_NAME(19),
		   RESOURCE19_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(19), RESOURCE19_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(19),
		   RESOURCE19_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(19), RESOURCE19_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(19),
		   RESOURCE19_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(19),RESOURCE19_START_DATE=RESOURCE_START_DATE(19),
		   RESOURCE19_END_DATE=RESOURCE_END_DATE(19),
           RESOURCE20_NAME=RESOURCE_NAME(20),GROUP20_NAME=GROUP_NAME(20),ROLE20_NAME=ROLE_NAME(20),
		   RESOURCE20_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(20), RESOURCE20_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(20),
		   RESOURCE20_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(20), RESOURCE20_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(20),
		   RESOURCE20_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(20),RESOURCE20_START_DATE=RESOURCE_START_DATE(20),
		   RESOURCE20_END_DATE=RESOURCE_END_DATE(20),
           RESOURCE21_NAME=RESOURCE_NAME(21),GROUP21_NAME=GROUP_NAME(21),ROLE21_NAME=ROLE_NAME(21),
		   RESOURCE21_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(21), RESOURCE21_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(21),
		   RESOURCE21_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(21), RESOURCE21_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(21),
		   RESOURCE21_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(21),RESOURCE21_START_DATE=RESOURCE_START_DATE(21),
		   RESOURCE21_END_DATE=RESOURCE_END_DATE(21),
           RESOURCE22_NAME=RESOURCE_NAME(22),GROUP22_NAME=GROUP_NAME(22),ROLE22_NAME=ROLE_NAME(22),
		   RESOURCE22_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(22), RESOURCE22_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(22),
		   RESOURCE22_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(22), RESOURCE22_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(22),
		   RESOURCE22_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(22),RESOURCE22_START_DATE=RESOURCE_START_DATE(22),
		   RESOURCE22_END_DATE=RESOURCE_END_DATE(22),
           RESOURCE23_NAME=RESOURCE_NAME(23),GROUP23_NAME=GROUP_NAME(23),ROLE23_NAME=ROLE_NAME(23),
		   RESOURCE23_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(23), RESOURCE23_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(23),
		   RESOURCE23_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(23), RESOURCE23_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(23),
		   RESOURCE23_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(23),RESOURCE23_START_DATE=RESOURCE_START_DATE(23),
		   RESOURCE23_END_DATE=RESOURCE_END_DATE(23),
           RESOURCE24_NAME=RESOURCE_NAME(24),GROUP24_NAME=GROUP_NAME(24),ROLE24_NAME=ROLE_NAME(24),
		   RESOURCE24_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(24), RESOURCE24_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(24),
		   RESOURCE24_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(24), RESOURCE24_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(24),
		   RESOURCE24_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(24),RESOURCE24_START_DATE=RESOURCE_START_DATE(24),
		   RESOURCE24_END_DATE=RESOURCE_END_DATE(24),
           RESOURCE25_NAME=RESOURCE_NAME(25),GROUP25_NAME=GROUP_NAME(25),ROLE25_NAME=ROLE_NAME(25),
		   RESOURCE25_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(25), RESOURCE25_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(25),
		   RESOURCE25_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(25), RESOURCE25_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(25),
		   RESOURCE25_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(25),RESOURCE25_START_DATE=RESOURCE_START_DATE(25),
		   RESOURCE25_END_DATE=RESOURCE_END_DATE(25),
           RESOURCE26_NAME=RESOURCE_NAME(26),GROUP26_NAME=GROUP_NAME(26),ROLE26_NAME=ROLE_NAME(26),
		   RESOURCE26_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(26), RESOURCE26_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(26),
		   RESOURCE26_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(26), RESOURCE26_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(26),
		   RESOURCE26_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(26),RESOURCE26_START_DATE=RESOURCE_START_DATE(26),
		   RESOURCE26_END_DATE=RESOURCE_END_DATE(26),
           RESOURCE27_NAME=RESOURCE_NAME(27),GROUP27_NAME=GROUP_NAME(27),ROLE27_NAME=ROLE_NAME(27),
		   RESOURCE27_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(27), RESOURCE27_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(27),
		   RESOURCE27_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(27), RESOURCE27_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(27),
		   RESOURCE27_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(27),RESOURCE27_START_DATE=RESOURCE_START_DATE(27),
		   RESOURCE27_END_DATE=RESOURCE_END_DATE(27),
           RESOURCE28_NAME=RESOURCE_NAME(28),GROUP28_NAME=GROUP_NAME(28),ROLE28_NAME=ROLE_NAME(28),
		   RESOURCE28_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(28), RESOURCE28_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(28),
		   RESOURCE28_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(28), RESOURCE28_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(28),
		   RESOURCE28_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(28),RESOURCE28_START_DATE=RESOURCE_START_DATE(28),
		   RESOURCE28_END_DATE=RESOURCE_END_DATE(28),
           RESOURCE29_NAME=RESOURCE_NAME(29),GROUP29_NAME=GROUP_NAME(29),ROLE29_NAME=ROLE_NAME(29),
		   RESOURCE29_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(29), RESOURCE29_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(29),
		   RESOURCE29_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(29), RESOURCE29_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(29),
		   RESOURCE29_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(29),RESOURCE29_START_DATE=RESOURCE_START_DATE(29),
		   RESOURCE29_END_DATE=RESOURCE_END_DATE(29),
           RESOURCE30_NAME=RESOURCE_NAME(30),GROUP30_NAME=GROUP_NAME(30),ROLE30_NAME=ROLE_NAME(30),
		   RESOURCE30_ATTRIBUTE1=RESOURCE_ATTRIBUTE1(30), RESOURCE30_ATTRIBUTE2=RESOURCE_ATTRIBUTE2(30),
		   RESOURCE30_ATTRIBUTE3=RESOURCE_ATTRIBUTE3(30), RESOURCE30_ATTRIBUTE4=RESOURCE_ATTRIBUTE4(30),
		   RESOURCE30_ATTRIBUTE5=RESOURCE_ATTRIBUTE5(30),RESOURCE30_START_DATE=RESOURCE_START_DATE(30),
		   RESOURCE30_END_DATE=RESOURCE_END_DATE(30)
    WHERE user_id = p_userid
    AND TERR_GRP_ACCT_ID =m.TERR_GRP_ACCT_ID;

  END LOOP; -- of NA

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END POPULATE_INTERFACE_FOR_NA;


PROCEDURE POPULATE_WEBADI_INTERFACE( P_CALLFROM         IN VARCHAR2
                                    ,P_SEARCHTYPE       IN VARCHAR2
                                    ,P_SEARCHVALUE      IN VARCHAR2
                                    ,P_USERID           IN INTEGER
                                    ,P_GRPNAME          IN VARCHAR2
                                    ,P_GRPID            IN NUMBER
                                    ,P_SITE_TYPE        IN VARCHAR2
                                    ,P_SICCODE          IN VARCHAR2
                                    ,P_SICCODE_TYPE     IN VARCHAR2 DEFAULT NULL
                                    ,P_SITE_DUNS        IN VARCHAR2
                                    ,P_NAMED_ACCOUNT    IN VARCHAR2
                                    ,P_WEB_SITE         IN VARCHAR2 DEFAULT NULL
                                    ,P_EMAIL_ADDR       IN VARCHAR2 DEFAULT NULL
                                    ,P_CITY             IN VARCHAR2
                                    ,P_STATE            IN VARCHAR2
                                    ,P_COUNTY           IN VARCHAR2 DEFAULT NULL
                                    ,P_PROVINCE         IN VARCHAR2
                                    ,P_POSTAL_CODE_FROM IN VARCHAR2
                                    ,P_POSTAL_CODE_TO   IN VARCHAR2
                                    ,P_COUNTRY          IN VARCHAR2
                                    ,P_DU_DUNS          IN VARCHAR2
                                    ,P_DU_NAME          IN VARCHAR2
                                    ,P_PARTY_NUMBER     IN VARCHAR2
                                    ,P_GU_DUNS          IN VARCHAR2
                                    ,P_GU_NAME          IN VARCHAR2
                                    ,P_CERT_LEVEL       IN VARCHAR2
                                    ,P_SALESPERSON      IN NUMBER
                                    ,P_SALES_GROUP      IN NUMBER
                                    ,P_SALES_ROLE       IN VARCHAR2
                                    ,P_ASSIGNED_STATUS  IN VARCHAR2
                                    ,P_ISADMINFLAG      IN VARCHAR2
                                    ,P_PARTY_TYPE       IN VARCHAR2 DEFAULT NULL
                                    ,P_HIERARCHY_TYPE   IN VARCHAR2 DEFAULT NULL
                                    ,P_RELATIONSHIP_ROLE IN VARCHAR2 DEFAULT NULL
                                    ,P_CLASS_TYPE       IN VARCHAR2 DEFAULT NULL
                                    ,P_CLASS_CODE       IN VARCHAR2 DEFAULT NULL
                                    ,P_ANN_REV_FROM     IN NUMBER DEFAULT NULL
                                    ,P_ANN_REV_TO       IN NUMBER DEFAULT NULL
                                    ,P_NUM_EMP_FROM     IN VARCHAR2 DEFAULT NULL
                                    ,P_NUM_EMP_TO       IN VARCHAR2 DEFAULT NULL
                                    ,P_CUST_CATEGORY    IN VARCHAR2 DEFAULT NULL
                                    ,P_IDENT_ADDR_FLAG  IN VARCHAR2 DEFAULT NULL
				    				,P_MAPPED_STATUS    IN VARCHAR2 DEFAULT NULL
									,P_VIEW_DATE		IN DATE		DEFAULT NULL -- added 07/20/2006
									,P_ORG_ID			IN NUMBER	DEFAULT NULL -- added 07/20/2006
				    				,X_SEQ              OUT NOCOPY VARCHAR2
                                    ,X_RETCODE          OUT NOCOPY VARCHAR2
                                    ,X_ERRBUF           OUT NOCOPY VARCHAR2) IS

  l_rows_inserted  NUMBER;

BEGIN

  /* Initialize the out and loclal variables */
  X_SEQ           := 0;
  X_RETCODE       := 0;
  X_ERRBUF        := NULL;
  l_rows_inserted := 0;

  /* Get the next sequence number of the table jtf_tty_webadi_interface */
  BEGIN
    SELECT jtf_tty_interface_s.NEXTVAL
    INTO   g_seq
    FROM   DUAL;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE G_SEQUENCE_ERROR;
  END;

  /* Get the meaning for no lookup code */
  BEGIN
    SELECT MEANING
    INTO   g_no_lookup
    FROM   FND_LOOKUPS
    WHERE  lookup_type = 'JTF_TERR_FLAGS'
    AND    lookup_code = 'N';

  EXCEPTION
    WHEN OTHERS THEN
      RAISE G_NO_LOOKUP_MISSING;
  END;

  /* Delete the existing data for the user from the interface table */
  BEGIN
    DELETE /*+ index(tty jtf_tty_webadi_intf_n1) */
    FROM JTF_TTY_WEBADI_INTERFACE tty
    WHERE tty.user_id = TO_NUMBER(p_userid);

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE G_DELETE_ERROR;
  END;

  /* check to see if admin is initiating the download */
  IF (p_callfrom = 'ADMIN') THEN
    /* check to see if the export object type is named account (NA) or organization (ORG) */
    IF (p_searchtype = 'NA') THEN

--      IF (trim(P_GRPID) IS NOT NULL) THEN
        POPULATE_INTERFACE_FOR_NA( P_USERID
                                  ,P_GRPID
                                  ,P_SITE_TYPE
                                  ,P_SICCODE
                                  ,P_SITE_DUNS
                                  ,P_NAMED_ACCOUNT
                                  ,P_CITY
                                  ,P_STATE
                                  ,P_PROVINCE
                                  ,P_POSTAL_CODE_FROM
                                  ,P_POSTAL_CODE_TO
                                  ,P_COUNTRY
                                  ,P_DU_DUNS
                                  ,P_DU_NAME
                                  ,P_PARTY_NUMBER
                                  ,P_GU_DUNS
                                  ,P_GU_NAME
                                  ,P_CERT_LEVEL
                                  ,P_SALESPERSON
                                  ,P_SALES_GROUP
                                  ,P_SALES_ROLE
				  				  ,P_PARTY_TYPE
                                 ,P_HIERARCHY_TYPE
                                 ,P_RELATIONSHIP_ROLE
                                 ,P_CLASS_TYPE
                                 ,P_CLASS_CODE
                                 ,P_ANN_REV_FROM
                                 ,P_ANN_REV_TO
                                 ,P_NUM_EMP_FROM
                                 ,P_NUM_EMP_TO
                                 ,P_CUST_CATEGORY
                                 ,P_IDENT_ADDR_FLAG
				 				 ,P_SICCODE_TYPE
								 ,P_GRPNAME
								 ,P_VIEW_DATE
								 ,P_ORG_ID
				 				 ,L_ROWS_INSERTED
                                  ,X_RETCODE
                                  ,X_ERRBUF);
--      ELSE
--        RAISE G_TERRGRP_MISSING;
--      END IF;
    ELSIF (p_searchtype = 'ORG') THEN
      POPULATE_INTERFACE_FOR_ORG( P_USERID
                                 ,P_SICCODE
                                 ,P_SICCODE_TYPE
                                 ,P_SITE_DUNS
                                 ,P_NAMED_ACCOUNT
                                 ,P_WEB_SITE
                                 ,P_EMAIL_ADDR
                                 ,P_CITY
                                 ,P_STATE
                                 ,P_COUNTY
                                 ,P_PROVINCE
                                 ,P_POSTAL_CODE_FROM
                                 ,P_POSTAL_CODE_TO
                                 ,P_COUNTRY
                                 ,P_PARTY_NUMBER
                                 ,P_CERT_LEVEL
                                 ,P_PARTY_TYPE
                                 ,P_HIERARCHY_TYPE
                                 ,P_RELATIONSHIP_ROLE
                                 ,P_CLASS_TYPE
                                 ,P_CLASS_CODE
                                 ,P_ANN_REV_FROM
                                 ,P_ANN_REV_TO
                                 ,P_NUM_EMP_FROM
                                 ,P_NUM_EMP_TO
                                 ,P_CUST_CATEGORY
                                 ,P_IDENT_ADDR_FLAG
                                 ,L_ROWS_INSERTED
                                 ,X_RETCODE
                                 ,X_ERRBUF);
    END IF;
  END IF;

  COMMIT;

  /* check to see if more than 25000 records have been inserted in the interface table */
  /* if yes , set retcode to 2 (warning) and errbuf to appropiate error message        */
  IF (l_rows_inserted > g_rows_limit) THEN
    x_retcode := -2;
    x_errbuf  := 'More than ' || g_rows_limit || ' records have been retrieved';
  END IF;

  x_seq := TO_CHAR(g_seq);

EXCEPTION
  WHEN G_SEQUENCE_ERROR THEN
    x_retcode := -1;
    x_errbuf  := 'Error in  generating the sequence number jtf_tty_interface_s. SQLCODE : ' || SQLCODE ||
                 ' SQLERRM : ' || SQLERRM;
    x_seq     := 0;
    RETURN;

  WHEN G_NO_LOOKUP_MISSING THEN
    x_retcode := -1;
    x_errbuf  := 'Error in getting the meaning for the lookup code = N and lookup type = JTF_TERR_FLAGS  : ' || SQLCODE ||
                 ' SQLERRM : ' || SQLERRM;
    x_seq     := 0;
    RETURN;

  WHEN G_DELETE_ERROR THEN
    x_retcode := -1;
    x_errbuf  := 'Error in deleting the existing data for the user from the interface table. SQLCODE : ' || SQLCODE ||
                 ' SQLERRM : ' || SQLERRM;
    x_seq     := 0;
    RETURN;
/*
  WHEN G_TERRGRP_MISSING THEN
    x_retcode := -1;
    x_errbuf  := 'Territory Group must be specified while downloading named accounts.';
    x_seq     := 0;
    RETURN;
*/
  WHEN OTHERS THEN
    x_retcode := -1;
    x_errbuf  := 'SQLCODE : ' || SQLCODE || ' SQLERRM : ' || SQLERRM;
    x_seq     := 0;
    RETURN;
END POPULATE_WEBADI_INTERFACE;

END JTF_TTY_EXCEL_NAORG_PVT;

/
