--------------------------------------------------------
--  DDL for Package Body JTF_TTY_WEBADI_NADOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_WEBADI_NADOC_PKG" AS
/* $Header: jtfintfb.pls 120.6.12000000.2 2007/06/27 08:32:56 sseshaiy ship $ */
-- ===========================================================================+
-- |               Copyright (c) 2003 Oracle Corporation                       |
-- |                  Redwood Shores, California, USA                          |
-- |                       All rights reserved.                                |
-- +===========================================================================
--    Start of Comments
--    ---------------------------------------------------
--    PURPOSE
--
--      This package is used to return a list of column in order of selectivity.
--      And create indices on columns in order of  input
--
--
--      Procedures:
--         (see below for specification)
--
--      This package is publicly available for use
--
--    HISTORY
--      05/02/2002    SHLI        Created
--      14/03/2004    SP          Modified for bug 3334142.
--
--    End of Comments
--
-- *******************************************************
--    Start of Comments
-- *******************************************************

PROCEDURE POPULATE_INTERFACE(      P_CALLFROM         IN VARCHAR2,
                                   P_SEARCHTYPE       IN VARCHAR2,
                                   P_SEARCHVALUE      IN VARCHAR2,
                                   P_USERID           IN INTEGER,
                                   P_GRPID            IN NUMBER,
                                   P_GRPNAME          IN VARCHAR2,
                                   P_SITE_TYPE        IN VARCHAR2,
                                   P_SICCODE          IN VARCHAR2,
                                   P_SITE_DUNS        IN VARCHAR2,
                                   P_NAMED_ACCOUNT    IN VARCHAR2,
                                   P_CITY             IN VARCHAR2,
                                   P_STATE            IN VARCHAR2,
                                   P_PROVINCE         IN VARCHAR2,
                                   P_POSTAL_CODE_FROM IN VARCHAR2,
                                   P_POSTAL_CODE_TO   IN VARCHAR2,
                                   P_COUNTRY          IN VARCHAR2,
                                   P_DU_DUNS          IN VARCHAR2,
                                   P_DU_NAME          IN VARCHAR2,
                                   P_GU_DUNS          IN VARCHAR2,
                                   P_GU_NAME          IN VARCHAR2,
                                   P_SALESPERSON      IN NUMBER,
                                   P_SALES_GROUP      IN NUMBER,
                                   P_SALES_ROLE       IN VARCHAR2,
                                   P_ASSIGNED_STATUS  IN VARCHAR2,
									   P_IDENTADDRFLAG    IN VARCHAR2,
                                   P_ISADMINFLAG      IN VARCHAR2,
                                   X_SEQ            OUT NOCOPY VARCHAR2) IS

PARAM_ARRAY             VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,

NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

/*
RESOURCE_NAME           VARRAY_TYPE:=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,

null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
GROUP_NAME              VARRAY_TYPE:=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,

null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
ROLE_NAME               VARRAY_TYPE:=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,

null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
COL_ROLE                VARRAY_TYPE:=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,

null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
RESOURCE_ID             NARRAY_TYPE:=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
L_GROUP_ID              NARRAY_TYPE:=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
ROLE_CODE               VARRAY_TYPE:=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,

null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
COL_RSC                 NARRAY_TYPE:=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
COL_USED                NARRAY_TYPE:=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
*/

RESOURCE_NAME           VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                 NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
GROUP_NAME              VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                 NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
ROLE_NAME               VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                 NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
COL_ROLE                VARRAY_TYPE:=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                 NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
COL_USED                NARRAY_TYPE:=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

salesMgr                NUMBER;
SEQ     	            NUMBER;
ID	                    NUMBER;
NAMED_ACCOUNT	        VARCHAR2(360);
L_PARTY_ID              VARCHAR2(30);
SITE_TYPE	            VARCHAR2(80);
DUNS	            	VARCHAR2(30);
TRADE_NAME	        	VARCHAR2(240);
GU_DUNS		            VARCHAR2(360);
GU_NAME		            VARCHAR2(360);
--DOME_ULTIMATE_DUNS		VARCHAR2(360);
--DOME_ULTIMATE_NAME		VARCHAR2(360);
CITY	               	VARCHAR2(60);
STATE	              	VARCHAR2(60);
POSTAL_CODE	            VARCHAR2(60);
TERRITORY_GROUP	    	VARCHAR2(150);
NA_ID                   NUMBER;
TERR_GRP_ACCT_ID	   	NUMBER;
CREATED_BY	         	NUMBER(15);
CREATION_DATE	      	DATE;
LAST_UPDATED_BY	    	NUMBER(15);
LAST_UPDATE_DATE	   	DATE;
LAST_UPDATE_LOGIN	  	NUMBER(15);
l_na_rsc_stat           VARCHAR2(6000);
l_na_query              VARCHAR2(6000);
l_var1                  VARCHAR2(200);
l_var2                  VARCHAR2(200);
curr_date               VARCHAR2(100);
i                       NUMBER;
j                       NUMBER;
k                       NUMBER;
numParam                NUMBER;
m                       NUMBER;
num                     NUMBER;
nastat                  INTEGER;
na                      INTEGER;
ignore                  INTEGER;
namedacct               INTEGER;
useExistsClause         VARCHAR2(10);
l_identAddrFlag         VARCHAR2(5);

P_NAMED_ACCOUNT_STR    VARCHAR2(361);
P_CITY_STR             VARCHAR2(61);
P_POSTAL_CODE_FROM_STR VARCHAR2(61);
P_POSTAL_CODE_TO_STR   VARCHAR2(61);
P_DU_NAME_STR          VARCHAR2(361);
P_GU_NAME_STR          VARCHAR2(361);
l_sql 				   VARCHAR2(5000);

  TYPE csr_type IS REF CURSOR;
  l_get_statistic_csr csr_type;
  TYPE get_stat_rec_type IS RECORD
  (role_code		varchar(30),
   num				number);
  TYPE get_stat_tbl_type is table of get_stat_rec_type index by binary_integer;

  l_get_stat_tbl	get_stat_tbl_type;

   CURSOR getSalesperson( P_NAID   IN NUMBER ) IS
         SELECT  rsc.resource_name resource_name
	           , rol.role_name role_name
	           , grp.group_name group_name
	           , rsc.resource_id resource_id
               , grp.group_id group_id
	           , rol.role_code role_code
         FROM jtf_rs_resource_extns_vl rsc
            , jtf_rs_groups_vl grp
            , jtf_rs_roles_vl rol
            , jtf_tty_named_acct_rsc narsc
            , jtf_tty_terr_grp_accts ga
--            , jtf_tty_named_accts na
         WHERE rsc.resource_id = narsc.resource_id
           AND grp.group_id = narsc.rsc_group_id
           AND rol.role_code = narsc.rsc_role_code
           AND narsc.terr_group_account_id =  ga.terr_group_account_id
           AND narsc.rsc_resource_type = 'RS_EMPLOYEE'
--           AND ga.named_account_id = na.named_account_id
           AND ga.named_account_id = P_NAID;
--  ???        ORDER BY UPPER(rol.role_name), rsc.resource_name;


   CURSOR getNAFromInterface  IS
   SELECT jtf_tty_webadi_int_id, terr_grp_acct_id
   FROM jtf_tty_webadi_interface--JTF_TTY_WEBADI_INT_GT --
   WHERE user_id=p_userid;


BEGIN
---delete from tmp;
---insert into tmp values ( to_char(sysdate,'HH,MI:SS'), '1. start'); commit;

    P_NAMED_ACCOUNT_STR := NULL;
    P_CITY_STR          := NULL;
    P_DU_NAME_STR       := NULL;
    P_GU_NAME_STR       := NULL;

     BEGIN




       --l_t1 := TO_CHAR(SYSDATE, 'mm/dd/yyyy hh24:mi:ss');
       --dbms_output.put_line('PREVIOUS DOWNLOAD CLEANUP = '|| l_t1 );

        SELECT jtf_tty_interface_s.NEXTVAL INTO SEQ
        FROM dual;

     --delete from JTF_TTY_WEBADI_INT_GT  ;
     -- remove existing old data for this userid
       DELETE /*+ INDEX(jtf_tty_webadi_intf_n1) */
       FROM JTF_TTY_WEBADI_INTERFACE tty
       WHERE tty.user_id = TO_NUMBER(p_userid);
    --    AND tty.user_sequence <> seq;

       --dbms_output.put_line('CLEANUP ROW COUNT = '|| TO_CHAR(SQL%ROWCOUNT) );

        -- JDOCHERT: 11/01/03
        -- Very important commit as it will
	-- prevent locking of JTF_TTY_WEBADI_INTERFACE
	-- table should the download fail
	--
     COMMIT;

     EXCEPTION
        WHEN OTHERS THEN
           NULL;

     END;

    -- and sysdate - creation_date >2;
    --select count(*) into id from JTF_TTY_WEBADI_INTERFACE;
    --if id=0 then id:=1;
    --else select max(id)+1 into id from JTF_TTY_WEBADI_INTERFACE;
    --end if;

   BEGIN

      SELECT resource_id INTO salesMgr FROM jtf_rs_resource_extns
      WHERE user_id = TO_NUMBER(p_userid);

     EXCEPTION
           WHEN NO_DATA_FOUND THEN
            x_seq := '-100';
            RETURN;
  END;

/* search by

2                              Unmapped Named Account
3                              Named Account
4                              Site Type
5                              Salesperson
6                              City
7                              State
8                              Postal Code
9                              Country
91                             Territory Group
*/
  --l_t1 := TO_CHAR(SYSDATE, 'mm/dd/yyyy hh24:mi:ss');
    --dbms_output.put_line('QUERY BUILD = '|| l_t1 );
   curr_date := TO_CHAR(SYSDATE);

  IF p_callfrom = 'S' /* simple search */ THEN

	  --DBMS_OUTPUT.PUT_LINE ('p_userid: '||P_USERID ||', SEQ: ' ||SEQ||', CURR_DATE: '||CURR_DATE);
      l_na_query :=
       'INSERT into JTF_TTY_WEBADI_INTERFACE  ' || --JTF_TTY_WEBADI_INT_GT
       ' ( USER_SEQUENCE,USER_ID,TERR_GRP_ACCT_ID,JTF_TTY_WEBADI_INT_ID,NAMED_ACCOUNT,SITE_TYPE,TRADE_NAME,DUNS, '||
       '   GU_DUNS,GU_NAME,CITY,STATE,POSTAL_CODE,TERRITORY_GROUP, ' ||
       '   CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE ' ||
       '  ) ' ||
	   ' SELECT ' ||
       ' :SEQ USER_SEQUENCE,'||
       ' :P_USERID USER_ID,'|| ' GAID, NAID, NAMED_ACCOUNT,SITE_TYPE,TRADE_NAME, SITE_DUNS, '||
       '  GU_DUNS,GU_NAME,CITY,STATE,POSTAL_CODE, GRPNAME, ' ||
       ' :P_USERID CREATED_BY, :curr_date CREATION_DATE,' ||
       ' :P_USERID LAST_UPDATED_BY, :curr_date LAST_UPDATE_DATE '||
       ' FROM (';

     /* main select */
     IF  P_SEARCHTYPE = '91' --Territory Group
         AND P_SEARCHVALUE IS NOT NULL AND trim(P_SEARCHVALUE) IS NOT NULL AND SUBSTR(trim(P_SEARCHVALUE),1,1)<> '%' THEN

       l_var1 := UPPER(trim(P_SEARCHVALUE)) || '%';
       l_na_query :=l_na_query ||
       '   select /*+ ORDERED */ ' ||
       '          hzp.party_name    named_account, ' ||
       '          lkp.meaning       site_type,  ' ||
       '          hzp.known_as      trade_name, ' ||
       '          hzp.duns_number_c site_duns, ' ||
       '          GU.GU_NAME gu_name,  ' ||
       '          GU.GU_DUNS gu_duns,  ' ||
       '          hzl.city  city, ' ||
       '          hzl.state         state, ' ||
       '          hzl.postal_code   postal_code, ' ||
       '          ttygrp.terr_group_name grpname, ' ||
       '          ga.terr_group_account_id gaid,  '||
       '          ga.terr_group_id     tgid, ' ||
       '          na.named_account_id naid ' ||
       '     from jtf_tty_terr_grp_accts ga ' ||
       '          ,jtf_tty_terr_groups ttygrp ' ||
       '          ,jtf_tty_named_accts na ' ||
       '          ,fnd_lookups  lkp ' ||
       '          ,hz_parties hzp ' ||
       '          ,hz_party_sites hzps ' ||
       '          ,hz_locations hzl ' ||
       '          , ( /* Global Ultimate */ ' ||
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
       '              group by hzr.object_id ) GU	 ' ||
       '     where ' ||
       '           ga.terr_group_account_id IN ' ||
       '           (  ' ||
       '              select /*+ NO_MERGE */ narsc.terr_group_account_id ' ||
       '                from jtf_tty_named_acct_rsc narsc, ' ||
       '                     jtf_tty_srch_my_resources_v repdn ' ||
       '               where current_user_id = :P_USERID ' ||
       '                 and narsc.rsc_group_id = repdn.group_id ' ||
       '                 and narsc.resource_id  = repdn.resource_id ' ||
       '           ) ' ||
       '           and ttygrp.terr_group_id = ga.terr_group_id ' ||
       '           and ttygrp.active_from_date <= sysdate ' ||
       '           and ( ttygrp.active_to_date is null   or ' ||
       '                  ttygrp.active_to_date >= sysdate) ' ||
       '           and upper(ttygrp.terr_group_name) like :P_SEARCHSTR ' ||
       '           and na.named_account_id = ga.named_account_id ' ||
       '           AND na.site_type_code = lkp.lookup_code ' ||
       '           and lkp.lookup_type = ''JTF_TTY_SITE_TYPE_CODE'' ' ||
       '           and hzp.party_id = na.party_id ' ||
       '           and hzps.party_id = na.party_id ' ||
       '           and hzps.party_site_id = na.party_site_id ' ||
       '           and hzps.location_id = hzl.location_id ' ||
       '           AND GU.GU_OBJECT_ID (+) = hzp.party_id ' ||
       ' ) '; -- done

       m :=2; -- 2 bind variable

     ELSE /* search by null or search by other(than TG) */
          l_na_query := l_na_query ||
             ' select * from ( ' ||
             ' select hzp.party_name    named_account, ' ||
             '    lkp.meaning       site_type, ' ||
             '    hzp.known_as      trade_name, ' ||
             '    hzp.duns_number_c site_duns, ' ||
             '    GU.GU_NAME        gu_name, ' ||
	         '    GU.GU_DUNS        gu_duns, ' ||
             '    hzl.city          city, ' ||
             '    hzl.state         state, ' ||
             '    hzl.postal_code   postal_code, ' ||
             '    hzl.country       country, ' ||
             '    ttygrp.terr_group_name grpname, ' ||
             '    ga.terr_group_account_id gaid, ' ||
             '    ga.terr_group_id  tgid, ' ||
             '    lkp.lookup_code   sitetypecode, ' ||
             '    hzp.province, ' ||
             '    na.named_account_id naid ' ||
             ' from hz_parties hzp, ' ||
             '      hz_party_sites hzps, ' ||
             '      hz_locations hzl, ' ||
             '      jtf_tty_named_accts na, ' ||
             '      jtf_tty_terr_grp_accts ga, ' ||
             '      fnd_lookups  lkp, ' ||
             '      jtf_tty_terr_groups ttygrp ' ||
	         '      , ( /* Global Ultimate */ ' ||
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
             '            group by hzr.object_id ) GU	 ' ||
             ' where hzp.party_id = na.party_id ' ||
             '       and hzps.party_id = na.party_id ' ||
             '       and hzps.party_site_id = na.party_site_id ' ||
             '       and hzps.location_id = hzl.location_id ' ||
             '       and na.site_type_code = lkp.lookup_code ' ||
             '       and lkp.lookup_type = ''JTF_TTY_SITE_TYPE_CODE'' ' ||
             '       and na.named_account_id = ga.named_account_id ' ||
             '       and ttygrp.terr_group_id = ga.terr_group_id ' ||
             '       and ttygrp.active_from_date <= sysdate ' ||
             '       and ( ttygrp.active_to_date is null ' ||
             '            or ' ||
             '            ttygrp.active_to_date >= sysdate ' ||
             '           ) ' ||
             '       AND GU.GU_OBJECT_ID (+) = hzp.party_id ' ||
             ' ) ';  -- not done


        IF P_SEARCHVALUE IS NULL OR trim(P_SEARCHVALUE) IS NULL OR  SUBSTR(trim(P_SEARCHVALUE),1,1) = '%' THEN

          l_na_query := l_na_query ||
                      ' where gaid IN ( select /*+ NO_MERGE */ narsc.terr_group_account_id ' ||
                      '             from jtf_tty_named_acct_rsc narsc, '||
                      '                  jtf_tty_srch_my_resources_v repdn '||
                      '            where narsc.resource_id = repdn.resource_id '||
                      '              and narsc.rsc_group_id = repdn.group_id '||
                      '              and repdn.current_user_id = :P_USERID ) ' ||
                      ' )';
           m:=1;  -- one bind variable so far

        ELSE
             l_na_query := l_na_query ||
                      ' where EXISTS ( select narsc.terr_group_account_id '||
                      '            from jtf_tty_named_acct_rsc narsc, '||
                      '                 jtf_tty_srch_my_resources_v repdn '||
                      '           where narsc.resource_id = repdn.resource_id '||
                      '             and narsc.rsc_group_id = repdn.group_id '||
                      '             and narsc.terr_group_account_id = gaid '||
                      '             and repdn.current_user_id = :P_USERID ) ' ||
                      '             and ';

             IF P_SEARCHTYPE = '8' THEN l_var1 := trim(P_SEARCHVALUE) || '%'; -- no index
             ELSE l_var1 := UPPER(trim(P_SEARCHVALUE)) || '%';
             END IF;

             IF    P_SEARCHTYPE = '1' THEN NULL;
             ELSIF P_SEARCHTYPE = '3' --named account
                   THEN  l_na_query := l_na_query || ' upper(named_account) like :P_SEARCHSTR';
             ELSIF P_SEARCHTYPE = '4' --site type
                   THEN  l_na_query := l_na_query || ' upper(site_type)     like :P_SEARCHSTR';
             ELSIF P_SEARCHTYPE = '6' --city
                   THEN  l_na_query := l_na_query || ' upper(city)          like :P_SEARCHSTR';
             ELSIF P_SEARCHTYPE = '7' --state
                   THEN  l_na_query := l_na_query || ' upper(state)         like :P_SEARCHSTR';
             ELSIF P_SEARCHTYPE = '8' --postal_code
                   -- then  l_na_query := l_na_query || ' upper(postal_code)   like :P_SEARCHSTR';
                   -- no index
                   THEN  l_na_query := l_na_query || ' postal_code   like :P_SEARCHSTR';
             END IF;
             l_na_query := l_na_query || ')'; -- close
             m:=2;  -- 2 bind variable
       END IF; -- P_SEARCHVALUE is null or ...

    END IF;  -- for P_SEARCHTYPE = '91'


  ELSE /* advanced search */

  l_na_query:='DECLARE ' ||
  ' P_USERID           INTEGER       := :P_USERID; '||
  ' P_GRPID            NUMBER        := :P_GRPID ; '||
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
  ' P_GU_DUNS          VARCHAR2(100) := :P_GU_DUNS; '||
  ' P_GU_NAME          VARCHAR2(360) := :P_GU_NAME; '||
  ' P_SALESPERSON      NUMBER        := :P_SALESPERSON; '||
  ' P_SALES_GROUP      NUMBER        := :P_SALES_GROUP; '||
  ' P_SALES_ROLE       VARCHAR2(100) := :P_SALES_ROLE; '||
  ' P_ASSIGNED_STATUS  VARCHAR2(100) := :P_ASSIGNED_STATUS; ' ||
  ' L_SEQ 			   NUMBER		 := :SEQ; ' ||
  ' L_CURR_DATE		   DATE			 := :CURR_DATE; '||

  ' BEGIN '||

  ' INSERT into JTF_TTY_WEBADI_INTERFACE ' || --JTF_TTY_WEBADI_INTERFACE '||
       ' ( USER_SEQUENCE,USER_ID,TERR_GRP_ACCT_ID,JTF_TTY_WEBADI_INT_ID,NAMED_ACCOUNT,SITE_TYPE,TRADE_NAME,DUNS, '||
       '   GU_DUNS,GU_NAME,CITY,STATE,POSTAL_CODE,TERRITORY_GROUP, ' ||
       '   CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE ' ||
       '  ) ' ||
       ' SELECT ' ||
       ' L_SEQ USER_SEQUENCE,'||
       '  P_USERID USER_ID,'|| ' GAID, NAID, NAMED_ACCOUNT,SITE_TYPE,TRADE_NAME, SITE_DUNS, '||
       '  GU_DUNS,GU_NAME,CITY,STATE,POSTAL_CODE, GRPNAME, ' ||
       '  P_USERID CREATED_BY, L_CURR_DATE CREATION_DATE,' ||
       '  P_USERID LAST_UPDATED_BY, L_CURR_DATE LAST_UPDATE_DATE '||
       ' FROM ( ' ||
       '    select '||
       '         ga.terr_group_id         tgid, ' ||
       '         na.named_account_id      naid, ' ||
       '         hzp.party_name           named_account, ' ||
       '         hzp.party_id             party_id,'||
       '         lkp.meaning              site_type,  ' ||
       '         hzp.known_as             trade_name, ' ||
       '         hzp.duns_number_c        site_duns, ' ||
       '         GU.GU_DUNS               gu_duns,  ' ||
       '         GU.GU_NAME               gu_name,  ' ||
       '         hzl.city                 city, ' ||
       '         hzl.state                state, ' ||
       '         hzl.postal_code          postal_code, ' ||
       '         hzl.country              country, ' ||
       '         ttygrp.terr_group_name   grpname, ' ||
       '         ga.terr_group_account_id gaid,' ||
       '         lkp.lookup_code          sitetypecode, '||
       '         hzp.sic_code             siccode, ' ||
       '         hzp.province             privince, '||
		   '         decode(hzps.identifying_address_flag, ''Y'', ''Y'', ''N'' ) identifying_addr_flag ' ||
             ' from hz_parties hzp, ' ||
             '      hz_locations hzl, ' ||
             '      hz_party_sites hzps, ' ||
             '      jtf_tty_named_accts na, ' ||
             '      jtf_tty_terr_grp_accts ga, ' ||
             '      fnd_lookups  lkp, ' ||
             '      jtf_tty_terr_groups ttygrp ' ||
	            '      , ( /* Global Ultimate */ ' ||
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
             '             group by hzr.object_id ) GU	 ' ||
             ' where hzp.party_id = na.party_id ' ||
	     '       AND hzps.party_site_id = na.party_site_id ' ||
             '       AND hzp.party_id = hzps.party_id ' ||
             '       AND hzps.party_id = na.party_id ' ||
             '       AND hzps.location_id = hzl.location_id ' ||
             '       and na.site_type_code = lkp.lookup_code ' ||
             '       and lkp.lookup_type = ''JTF_TTY_SITE_TYPE_CODE'' ' ||
             '       and na.named_account_id = ga.named_account_id ' ||
             '       AND ttygrp.terr_group_id = ga.terr_group_id ' ||
             '       AND GU.GU_OBJECT_ID (+) = hzp.party_id ' ;
      /*******************************/


    useExistsClause := 'N' ;

    IF P_GRPID IS NOT NULL AND trim(P_GRPID) IS NOT NULL THEN
    -- if (terrGrpID!=null  !"".equals(terrGrpID.trim()))
          l_na_query :=  l_na_query || ' and ga.terr_group_id = :P_GRPID ';
    END IF;

    IF P_CITY IS NOT NULL AND trim(P_CITY) IS NOT NULL THEN
    -- if (city!=null  !"".equals(city.trim()))
      l_na_query :=  l_na_query || 'AND upper(hzl.city) like :P_CITY ';
      useExistsClause := 'Y';
      P_CITY_STR             := UPPER(P_CITY) || '%';
    END IF;

    IF P_STATE IS NOT NULL AND trim(P_STATE) IS NOT NULL THEN
    -- if (state!=null  !"".equals(state.trim()))
      l_na_query :=  l_na_query || 'AND hzl.state = :P_STATE ';
    END IF;

    IF P_COUNTRY IS NOT NULL AND trim(P_COUNTRY) IS NOT NULL THEN
    -- if (country!=null  !"".equals(country.trim()))
      l_na_query :=  l_na_query || 'AND hzl.country = :P_COUNTRY ';
    END IF;

    IF P_POSTAL_CODE_FROM IS NOT NULL AND trim(P_POSTAL_CODE_FROM) IS NOT NULL
       AND P_POSTAL_CODE_TO IS NOT NULL AND trim(P_POSTAL_CODE_TO) IS NOT NULL
       AND P_POSTAL_CODE_FROM = P_POSTAL_CODE_TO THEN
    --if (postCodeFrom!=null  !"".equals(postCodeFrom.trim())
    --     postCodeTo!=null  !"".equals(postCodeTo.trim())
    --     postCodeFrom.equals(postCodeTo) )
        l_na_query :=  l_na_query || 'AND hzl.postal_code = :P_POSTAL_CODE_FROM ';
        useExistsClause := 'Y' ;
     ELSIF P_POSTAL_CODE_FROM IS NOT NULL AND trim(P_POSTAL_CODE_FROM) IS NOT NULL
       AND P_POSTAL_CODE_TO   IS NOT NULL AND trim(P_POSTAL_CODE_TO) IS NOT NULL
       AND P_POSTAL_CODE_FROM <> P_POSTAL_CODE_TO  THEN
       -- (postCodeFrom!=null  !"".equals(postCodeFrom.trim())
       --  postCodeTo!=null  !"".equals(postCodeTo.trim())
       --  !postCodeFrom.equals(postCodeTo))
         l_na_query :=  l_na_query || 'AND hzl.postal_code between :P_POSTAL_CODE_FROM and :P_POSTAL_CODE_TO ';
         useExistsClause := 'N' ;
     END IF;

    IF P_POSTAL_CODE_FROM IS NOT NULL AND trim(P_POSTAL_CODE_FROM) IS NOT NULL
       AND (P_POSTAL_CODE_TO IS NULL OR trim(P_POSTAL_CODE_TO) IS NULL)  THEN
    --if (postCodeFrom!=null  !"".equals(postCodeFrom.trim())
    --     (postCodeTo==null || "".equals(postCodeTo.trim())) )
         l_na_query :=  l_na_query || 'AND hzl.postal_code = :P_POSTAL_CODE_FROM ';
         useExistsClause := 'Y';
    END IF;

    IF (P_POSTAL_CODE_FROM IS NULL OR trim(P_POSTAL_CODE_FROM) IS NULL)
       AND P_POSTAL_CODE_TO IS NOT NULL AND trim(P_POSTAL_CODE_TO) IS NOT NULL THEN
    --if ( (postCodeFrom==null || "".equals(postCodeFrom.trim()))
    --    postCodeTo!=null  !"".equals(postCodeTo.trim()) )
         l_na_query :=  l_na_query || 'AND hzl.postal_code = :P_POSTAL_CODE_TO ' ;
         useExistsClause := 'Y' ;
    END IF;

    IF P_SITE_TYPE IS NOT NULL AND trim(P_SITE_TYPE) IS NOT NULL AND P_SITE_TYPE <> 'ALL' THEN
    --if (siteType!=null  !"".equals(siteType.trim())  !"ALL".equals(siteType))
         l_na_query :=  l_na_query || 'AND lkp.lookup_code = :P_SITE_TYPE ';
    END IF;

    IF P_SICCODE IS NOT NULL AND trim(P_SICCODE) IS NOT NULL THEN
    -- if (SICCode!=null  !"".equals(SICCode.trim()) )
        l_na_query :=  l_na_query || 'AND hzp.sic_code = :P_SICCODE ' ;
        useExistsClause := 'Y' ;
    END IF;

    IF P_SITE_DUNS IS NOT NULL AND trim(P_SITE_DUNS) IS NOT NULL THEN
    -- if (siteDUNS!=null  !"".equals(siteDUNS.trim()) )
        l_na_query :=  l_na_query || 'AND hzp.duns_number_c = :P_SITE_DUNS ' ;
        useExistsClause := 'Y';
    END IF;

    IF P_NAMED_ACCOUNT IS NOT NULL AND trim(P_NAMED_ACCOUNT) IS NOT NULL THEN
    --if (siteBN!=null  !"".equals(siteBN.trim()) )
        l_na_query :=  l_na_query || 'AND upper(hzp.party_name) like :P_NAMED_ACCOUNT ' ;
        useExistsClause := 'Y';
        P_NAMED_ACCOUNT_STR    := UPPER(P_NAMED_ACCOUNT) || '%';
    END IF;

    IF P_PROVINCE IS NOT NULL AND trim(P_PROVINCE) IS NOT NULL THEN
    -- if (province!=null  !"".equals(province.trim()) )
        l_na_query :=  l_na_query || 'AND hzp.province = :P_PROVINCE ' ;
        useExistsClause := 'Y' ;
    END IF;

    IF (P_DU_DUNS IS NOT NULL AND trim(P_DU_DUNS) IS NOT NULL) OR
        (P_DU_NAME IS NOT NULL AND trim(P_DU_NAME) IS NOT NULL) THEN
    --  if (DUBN!=null  !"".equals(DUBN.trim()) )
    --  if (DUDUNS!=null  !"".equals(DUDUNS.trim()) )
        l_na_query :=  l_na_query ||
          ' AND hzp.PARTY_ID in ( select hzr.object_id '||
          ' from   hz_parties hzp1, ' ||
          '         hz_relationships hzr '||
          ' where hzp1.party_id = hzr.subject_id '||
          ' and hzr.subject_table_name = ''HZ_PARTIES'' '||
          ' and hzr.object_table_name  = ''HZ_PARTIES'' '||
          ' and hzr.relationship_type  = ''DOMESTIC_ULTIMATE'' '||
          ' and hzr.relationship_code  = ''DOMESTIC_ULTIMATE_OF'' '||
          ' and hzr.status = ''A'' ';
          IF P_DU_DUNS IS NOT NULL AND trim(P_DU_DUNS) IS NOT NULL THEN
            l_na_query :=  l_na_query || ' and hzp1.duns_number_c = :P_DU_DUNS ';
          END IF;
          IF P_DU_NAME IS NOT NULL AND trim(P_DU_NAME) IS NOT NULL THEN
            l_na_query :=  l_na_query || ' and upper(hzp1.party_name) like :P_DU_NAME ';
            P_DU_NAME_STR          := UPPER(P_DU_NAME)||'%';
          END IF;
          l_na_query :=  l_na_query || ')';
          useExistsClause := 'Y';
    END IF;

    IF P_GU_DUNS IS NOT NULL AND trim(P_GU_DUNS) IS NOT NULL THEN
    --if (GUDUNS!=null  !"".equals(GUDUNS.trim()) )
          l_na_query :=  l_na_query || ' and GU.gu_duns = :P_GU_DUNS ';
          useExistsClause := 'Y' ;
    END IF;

    IF P_GU_NAME IS NOT NULL AND trim(P_GU_NAME) IS NOT NULL THEN
    --if (GUBN!=null  !"".equals(GUBN.trim()) )
          l_na_query :=  l_na_query || ' and upper(GU.gu_name) like :P_GU_NAME ';
          useExistsClause := 'Y' ;
          P_GU_NAME_STR          := UPPER(P_GU_NAME)||'%';
    END IF;

    ----BBB
    IF (P_SALESPERSON IS NOT NULL AND trim(P_SALESPERSON) IS NOT NULL) OR
       (P_SALES_GROUP IS NOT NULL AND trim(P_SALES_GROUP) IS NOT NULL) OR
       (P_SALES_ROLE  IS NOT NULL AND trim(P_SALES_ROLE ) IS NOT NULL) THEN
     --if ( (salesperson!=null  !"".equals(salesperson.trim())) ||
     --     (salesGrp   !=null  !"".equals(salesGrp.trim())   ) ||
     --     (salesRole  !=null  !"".equals(salesRole.trim())  ) )

         l_na_query :=  l_na_query || ' and ';
         IF trim(P_ASSIGNED_STATUS)='2' THEN
           l_na_query :=  l_na_query || ' ga.terr_group_account_id = -9999555 ';  --???
         ELSE ---AAA
           l_na_query :=  l_na_query || ' ga.terr_group_account_id in ( ';

            IF P_SALESPERSON IS NOT NULL AND trim(P_SALESPERSON) IS NOT NULL AND
               P_SALES_GROUP IS     NULL AND trim(P_SALES_GROUP) IS NULL AND
               P_SALES_ROLE  IS     NULL AND trim(P_SALES_ROLE ) IS NULL THEN

                l_na_query :=  l_na_query ||
                  ' select /*+ NO_MERGE */ narsc1.terr_group_account_id '||
                   ' from jtf_tty_named_acct_rsc narsc1, '||
                        '( SELECT dir.resource_id, ' ||
                                 ' MY_GRPS.group_id , ' ||
                                 ' MY_GRPS.CURRENT_USER_ID ' ||
                           ' FROM jtf_rs_group_members grpmemo , ' ||
                               ' jtf_rs_resource_extns dir , ' ||
                              ' ( SELECT /*+ NO_MERGE */ dv.group_id , ' ||
                                    ' mrsc.user_id CURRENT_USER_ID  ' ||
                                  ' FROM jtf_rs_group_usages usg , ' ||
                                        'jtf_rs_groups_denorm dv , ' ||
                                        'jtf_rs_rep_managers sgh , '||
                                        'jtf_rs_resource_extns mrsc , ' ||
                                        'jtf_rs_roles_b rol , ' ||
                                        'jtf_rs_role_relations rlt ' ||
                                  ' WHERE usg.usage = ''SALES'' ' ||
                                    ' AND usg.group_id = dv.group_id ' ||
                                    ' AND rlt.role_id = rol.role_id ' ||
                                    ' AND rlt.role_relate_id = sgh.par_role_relate_id '||
                                    ' AND dv.parent_group_id = sgh.group_id ' ||
                                    ' AND sgh.resource_id = sgh.parent_resource_id ' ||
                                    ' AND (sgh.hierarchy_type IN (''MGR_TO_MGR'') ' ||
                                     ' OR rol.role_code = FND_PROFILE.VALUE(''JTF_TTY_NA_PROXY_USER_ROLE'')) ' ||
                                     ' AND mrsc.resource_id = sgh.resource_id ' ||
                              ' ) MY_GRPS ' ||
                        ' WHERE grpmemo.resource_id = dir.resource_id ' ||
                         '  AND grpmemo.group_id = MY_GRPS.group_id ' ||
                               ' UNION ALL  ' ||
                        ' SELECT dir.resource_id , '||
                              ' grpmemo.group_id , ' ||
                              ' dir.user_id CURRENT_USER_ID ' ||
                         ' FROM jtf_rs_group_members grpmemo , ' ||
                              ' jtf_rs_resource_extns dir , ' ||
                              ' jtf_rs_group_usages usg ' ||
                        ' WHERE usg.usage = ''SALES'' ' ||
                         ' AND grpmemo.resource_id = dir.resource_id ' ||
                         ' AND grpmemo.group_id = usg.group_id ' ||
                     ' ) repdn1 ' ||
                  '  where narsc1.resource_id = repdn1.resource_id '||
                  '   and narsc1.rsc_group_id = repdn1.group_id '||
                  '   and repdn1.current_user_id = :P_SALESPERSON ';
             END IF;

             IF P_SALES_GROUP  IS NOT NULL AND trim(P_SALES_GROUP) IS NOT NULL AND
                (P_SALESPERSON IS     NULL OR  trim(P_SALESPERSON) IS NULL) AND
                (P_SALES_ROLE  IS     NULL OR  trim(P_SALES_ROLE ) IS NULL) THEN

                l_na_query :=  l_na_query ||
                  ' select narsc1.terr_group_account_id '||
                  ' from jtf_tty_named_acct_rsc narsc1, '||
                  '      jtf_rs_group_members mem1, '||
                  '      jtf_rs_groups_denorm grpdn1 '||
                  ' where narsc1.resource_id = mem1.resource_id '||
                  '   and narsc1.rsc_group_id = mem1.group_id  '||
                  '   and mem1.delete_flag = ''N''  '||
                  '   and mem1.group_id = grpdn1.group_id  '||
                  '   and SYSDATE BETWEEN NVL(grpdn1.start_date_active, SYSDATE-1)  '||
                  '   AND NVL(grpdn1.end_date_active, SYSDATE+1) '||
                  '   and grpdn1.parent_group_id = :P_SALES_GROUP ';
             END IF;

             IF  P_SALES_ROLE IS NOT NULL AND trim(P_SALES_ROLE)  IS NOT NULL AND
                (P_SALESPERSON IS     NULL OR trim(P_SALESPERSON) IS     NULL) AND
                (P_SALES_GROUP IS     NULL OR trim(P_SALES_GROUP) IS     NULL) THEN
                l_na_query :=  l_na_query ||
                 ' select narsc1.terr_group_account_id'||
                 ' from jtf_tty_named_acct_rsc narsc1,'||
                 '      jtf_tty_my_resources_v repdn1,'||
                 '      jtf_rs_rep_managers repmgr1,'||
                 '      jtf_rs_groups_denorm grpdn1 '||
                 '  where narsc1.resource_id = repmgr1.resource_id'||
                 '   and narsc1.rsc_group_id = repmgr1.group_id'||
                 '   and repmgr1.group_id = grpdn1.group_id'||
                 '   and repdn1.resource_id = repmgr1.parent_resource_id'||
                 '   and repdn1.parent_group_id = grpdn1.parent_group_id'||
                 '   and repdn1.current_user_id = :P_USERID '||
                 '   and repdn1.role_code = :P_SALES_ROLE ';
            END IF;

            IF   (P_SALESPERSON IS NOT NULL AND trim(P_SALESPERSON) IS NOT NULL) AND
                 (P_SALES_GROUP IS NOT NULL AND trim(P_SALES_GROUP) IS NOT NULL) AND
                 (P_SALES_ROLE  IS     NULL OR  trim(P_SALES_ROLE)  IS     NULL) THEN
                 l_na_query :=  l_na_query ||
                 '  select narsc1.terr_group_account_id '||
                 '  from jtf_tty_named_acct_rsc narsc1, '||
                 '      jtf_tty_my_resources_v repdn1 '||
                 ' where narsc1.resource_id = repdn1.resource_id '||
                 '  and narsc1.rsc_group_id = repdn1.group_id '||
                 '  and repdn1.current_user_id = :P_SALESPERSON '||
                 '  and repdn1.parent_group_id = :P_SALES_GROUP ';
            END IF;

            IF   (P_SALESPERSON IS NOT NULL AND trim(P_SALESPERSON) IS NOT NULL) AND
                 (P_SALES_GROUP IS     NULL OR  trim(P_SALES_GROUP) IS     NULL) AND
                 (P_SALES_ROLE  IS NOT NULL AND trim(P_SALES_ROLE)  IS NOT NULL) THEN
                 l_na_query :=  l_na_query ||
                 ' select narsc1.terr_group_account_id '||
                 '  from jtf_tty_named_acct_rsc narsc1, '||
                 '        jtf_tty_my_resources_v repdn1 '||
                 ' where narsc1.resource_id = repdn1.resource_id '||
                 '    and narsc1.rsc_group_id = repdn1.group_id '||
                 '    and repdn1.current_user_id = :P_SALESPERSON '||
                 '    and repdn1.current_user_role_code = :P_SALES_ROLE ';
            END IF;

            IF   (P_SALESPERSON IS     NULL OR  trim(P_SALESPERSON) IS     NULL) AND
                 (P_SALES_GROUP IS NOT NULL AND trim(P_SALES_GROUP) IS NOT NULL) AND
                 (P_SALES_ROLE  IS NOT NULL AND trim(P_SALES_ROLE)  IS NOT NULL) THEN
                 l_na_query :=  l_na_query ||
                ' select narsc1.terr_group_account_id '||
                '  from jtf_tty_named_acct_rsc narsc1, '||
                '       jtf_tty_my_resources_v repdn1, '||
                '       jtf_rs_rep_managers repmgr1, '||
                '       jtf_rs_groups_denorm grpdn1 '||
                '   where narsc1.resource_id = repmgr1.resource_id '||
                '    and narsc1.rsc_group_id = repmgr1.group_id '||
                '    and repmgr1.group_id = grpdn1.group_id '||
                '    and repdn1.resource_id = repmgr1.parent_resource_id '||
                '    and repdn1.current_user_id = :P_USERID '||
                '    and repdn1.role_code = :P_SALES_ROLE '||
                '    and grpdn1.parent_group_id = :P_SALES_GROUP ';
           END IF;

           IF   (P_SALESPERSON IS NOT NULL AND trim(P_SALESPERSON) IS NOT NULL) AND
                (P_SALES_GROUP IS NOT NULL AND trim(P_SALES_GROUP) IS NOT NULL) AND
                (P_SALES_ROLE  IS NOT NULL AND trim(P_SALES_ROLE)  IS NOT NULL) THEN
               l_na_query :=  l_na_query ||
                ' select narsc1.terr_group_account_id '||
                '    from jtf_tty_named_acct_rsc narsc1, '||
                '         jtf_tty_my_resources_v repdn1 '||
                '    where narsc1.resource_id = repdn1.resource_id '||
                '     and narsc1.rsc_group_id = repdn1.group_id '||
                '     and repdn1.current_user_id = :P_SALESPERSON ' ||
                '     and repdn1.parent_group_id = :P_SALES_GROUP '||
                '     and repdn1.current_user_role_code = :P_SALES_ROLE ';
           END IF;
           l_na_query :=  l_na_query || ')';
        END IF; -- end of AAA : salesperson/grp/role and not unassigned
     ---- end if salesperson/grp/role
     -- elseif of BBB
     ELSIF P_ASSIGNED_STATUS IS NOT NULL AND trim(P_ASSIGNED_STATUS) IS NOT NULL
           AND P_ASSIGNED_STATUS<>'1' THEN

        l_na_query :=  l_na_query || ' AND ';

        IF useExistsClause = 'Y' THEN
           l_na_query :=  l_na_query || ' EXISTS ' ;
        ELSE
              l_na_query :=  l_na_query || ' ga.terr_group_account_id IN ' ;
        END IF;

        IF  P_ASSIGNED_STATUS='2' THEN
                 IF P_ISADMINFLAG = 'Y' THEN
                    l_na_query :=  l_na_query ||
                    ' ( select narsc1.terr_group_account_id '||
                    '   from jtf_tty_named_acct_rsc narsc1, '||
                    '        jtf_tty_my_directs_v dir '||
                    '   where narsc1.resource_id = dir.resource_id '||
                    '   and narsc1.rsc_group_id = dir.group_id '||
                    '   and dir.group_id = dir.parent_group_id '||
                    '   and narsc1.assigned_flag = ''N'' '||
                    '   and dir.current_user_id = :P_USERID ';
                 ELSE
                    l_na_query :=  l_na_query ||
                    '( select narsc1.terr_group_account_id '||
                    '  from jtf_tty_named_acct_rsc narsc1, '||
                    '       jtf_rs_resource_extns rsc1 '||
                    ' where narsc1.resource_id = rsc1.resource_id '||
                    ' and narsc1.assigned_flag = ''N'' '||
                    ' and rsc1.user_id = :P_USERID ';
                 END IF; -- end of isAdmin

                 IF useExistsClause = 'Y' THEN
                    l_na_query :=  l_na_query || ' and narsc1.terr_group_account_id = ga.terr_group_account_id ';
                 END IF;
        ---- end of AssignedStatus equals 2

        ELSE -- P_ASSIGNED_STATUS<>'2'
             l_na_query :=  l_na_query ||
                ' ( select narsc.terr_group_account_id '||
                '   from jtf_tty_named_acct_rsc narsc, '||
                '        jtf_tty_srch_my_resources_v repdn '||
                '   where narsc.resource_id = repdn.resource_id '||
                '     and narsc.rsc_group_id = repdn.group_id '||
                '     and repdn.current_user_id = :P_USERID ';

                IF useExistsClause='Y' THEN
                   l_na_query :=  l_na_query || ' and narsc.terr_group_account_id = ga.terr_group_account_id ';
                END IF;

                IF P_ISADMINFLAG = 'Y' THEN
                   l_na_query :=  l_na_query ||
                     ' and not exists ( select ''Y'' '||
                     ' from jtf_tty_named_acct_rsc narsc1, '||
                     '      jtf_tty_my_directs_v dir '||
                     ' where narsc1.resource_id = dir.resource_id '||
                     ' and narsc1.rsc_group_id = dir.group_id '||
                     ' and dir.group_id = dir.parent_group_id '||
                     ' and narsc1.terr_group_account_id = narsc.terr_group_account_id '||
                     ' and narsc1.assigned_flag = ''N'' '||
                     ' and dir.current_user_id = :P_USERID ';
                ELSE
                   l_na_query :=  l_na_query ||
                     ' and not exists ( select ''Y'' '||
                     ' from jtf_tty_named_acct_rsc narsc1, '||
                     '      jtf_rs_resource_extns rsc1 '||
                     ' where narsc1.resource_id = rsc1.resource_id '||
                     ' and narsc1.terr_group_account_id = narsc.terr_group_account_id '||
                     ' and narsc1.assigned_flag = ''N'' '||
                     ' and rsc1.user_id = :P_USERID ';
                END IF;

                l_na_query :=  l_na_query || ')';
        END IF; -- of P_ASSIGNED_STATUS<>'2'

        l_na_query :=  l_na_query || ')';

     --- end of assigned status
     ELSE -- of BBB: i.e no rep/group/role/assigned parameters
        l_na_query :=  l_na_query || ' AND ';

        IF useExistsClause='Y' THEN
               l_na_query :=  l_na_query || ' EXISTS (select narsc1.terr_group_account_id ';
        ELSE
               l_na_query :=  l_na_query ||
                   ' ga.terr_group_account_id IN (select /*+ NO_MERGE */ narsc1.terr_group_account_id  ';
        END IF;

        l_na_query :=  l_na_query ||
                   '   from jtf_tty_named_acct_rsc narsc1, '||
                   '        jtf_tty_srch_my_resources_v repdn  '||
                   '   where narsc1.resource_id = repdn.resource_id '||
                   '     and narsc1.rsc_group_id = repdn.group_id '||
                   '     and repdn.current_user_id = :P_USERID ';


        IF useExistsClause='Y' THEN
           l_na_query :=  l_na_query || ' and narsc1.terr_group_account_id = ga.terr_group_account_id ';
        END IF;

        l_na_query :=  l_na_query || ')';

    END IF; -- of BBB;

		/* identifying_addr **/

		IF P_IDENTADDRFLAG IS NOT NULL THEN
        l_na_query :=  l_na_query || ' and hzps.identifying_address_flag = ''Y''  ';
    END IF;

   l_na_query :=  l_na_query || ');';
   l_na_query :=  l_na_query || ' end; ';

 END IF; -- advance search

/*
insert into tmp values(p_ExtraWhereClause, 'p_ExtraWhereClause'); commit;
insert into tmp values(p_paranum,'p_paranum');
insert into tmp values(p_1, 'p_1');
insert into tmp values(p_2, 'p_2');
insert into tmp values(p_3, 'p_3');
insert into tmp values(p_4, 'p_4');
insert into tmp values(p_5, 'p_5'); commit;
*/

    IF p_callfrom = 'S' /* simple search */ THEN
    /* simple search param = 1 or 2, first one is user_id */

      IF m=1 THEN

        EXECUTE IMMEDIATE l_na_query USING SEQ,P_USERID,P_USERID,CURR_DATE,P_USERID,CURR_DATE,P_USERID;
      ELSE
        EXECUTE IMMEDIATE l_na_query USING SEQ,P_USERID,P_USERID,CURR_DATE,P_USERID,CURR_DATE,P_USERID,l_var1;
      END IF;

    ELSE /* adv search */
        EXECUTE IMMEDIATE l_na_query USING P_USERID,P_GRPID,P_SITE_TYPE,P_SICCODE,P_SITE_DUNS,
                                           P_NAMED_ACCOUNT_STR,P_CITY_STR,P_STATE,P_PROVINCE,P_POSTAL_CODE_FROM,
                                           P_POSTAL_CODE_TO,P_COUNTRY,P_DU_DUNS,P_DU_NAME_STR,P_GU_DUNS,
                                           P_GU_NAME_STR,P_SALESPERSON,P_SALES_GROUP,P_SALES_ROLE,P_ASSIGNED_STATUS,
										   SEQ, CURR_DATE;
    END IF;
    COMMIT;


    ---insert into tmp values ( to_char(sysdate,'HH,MI:SS'), '3. finish na, before stat, userid='||p_userid);commit;


         /* Nas are populated, now start collect sales*/

         /* populate slots */
        i:=1;
		l_sql := 'SELECT role_code, MAX(num) num '
              || 'FROM ( '
              || 'SELECT rol.role_code role_code, COUNT(rol.role_code) num '
              || 'FROM '
        	  || '	      ( SELECT /*+ DYNAMIC_SAMPLING(jtw,5) */ '
        	  || '		  	jtw.jtf_tty_webadi_int_id '
              || '            FROM  jtf_tty_webadi_interface jtw ' --JTF_TTY_WEBADI_INT_GT
              || '            WHERE jtw.user_id = ' ||p_userid
              || '          ) sub, '
              || '          jtf_rs_roles_vl rol, '
              || '          jtf_tty_named_acct_rsc narsc, '
              || '          jtf_tty_terr_grp_accts ga '
              || '    WHERE rol.role_code = narsc.rsc_role_code '
              || '      AND narsc.terr_group_account_id =  ga.terr_group_account_id '
              || '      AND ga.named_account_id = sub.jtf_tty_webadi_int_id  '
              || '    GROUP BY ga.named_account_id, rol.role_code '
              || '    ORDER BY MAX(rol.role_name) '
              || '   ) '
              || ' GROUP BY role_code ';

 		open l_get_statistic_csr for l_sql;
		fetch l_get_statistic_csr bulk collect into l_get_stat_tbl;
		close l_get_statistic_csr;

		if l_get_stat_tbl.count > 0 then
        FOR stat IN l_get_stat_tbl.first..l_get_stat_tbl.last
         LOOP
            IF i+l_get_stat_tbl(stat).num-1 <=30 THEN
              FOR k IN i..i+l_get_stat_tbl(stat).num-1
                LOOP
                  COL_ROLE(k) := l_get_stat_tbl(stat).role_code;
                END LOOP;
            ELSE  x_seq := '-1';
                  RETURN;
            END IF;

            i:=i+l_get_stat_tbl(stat).num;
        END LOOP;
		end if;

         /* for each NA_ID */
        --- insert into tmp values ( to_char(sysdate,'HH,MI:SS'), '4. finish analysis '); commit;

        FOR m IN getNAFromInterface
        -- FOR m IN 1 .. NAST_tbl.TERR_GRP_ACCT_ID.count
        LOOP


          /* clear col_used flags */
          COL_USED        :=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
          RESOURCE_NAME   :=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
          GROUP_NAME      :=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
          ROLE_NAME       :=VARRAY_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

          /*FOR k in 1..30 loop  COL_USED(k):=0;
                               RESOURCE_NAME(k):=null;
                               GROUP_NAME(k):=null;
                               ROLE_NAME(k):=null;
                         end loop;
          */
          /* get all sales for this NA */
          --FOR SALES IN getSalesperson(NAST_tbl.JTF_TTY_WEBADI_INT_ID(m)/*NA_ID*/, NAST_tbl.TERR_GRP_ACCT_ID(m) )
          FOR SALES IN getSalesperson(m.JTF_TTY_WEBADI_INT_ID )
          LOOP

            --k:=0; -- not yet sloted
            FOR j IN 1..30
            LOOP -- look into 30 slots
              IF /*k=0 and*/ SALES.role_code = COL_ROLE(j) AND COL_USED(j)=0 THEN
                      COL_USED(j)     :=1;
                      --k:=1;
                      -- write into pl/sql table row
                      RESOURCE_NAME(j):=SALES.resource_name;
                      GROUP_NAME(j)   :=SALES.group_name;
                      ROLE_NAME(j)    :=SALES.role_name;
                      EXIT;
              END IF;
             END LOOP; -- of slotting
          END LOOP; -- of SALES


        UPDATE JTF_TTY_WEBADI_INTERFACE -- /*+ INDEX JTF_TTY_WEBADI_INTF_N2 */
        SET RESOURCE1_NAME=RESOURCE_NAME(1),GROUP1_NAME=GROUP_NAME(1),ROLE1_NAME=ROLE_NAME(1),
            RESOURCE2_NAME=RESOURCE_NAME(2),GROUP2_NAME=GROUP_NAME(2),ROLE2_NAME=ROLE_NAME(2),
            RESOURCE3_NAME=RESOURCE_NAME(3),GROUP3_NAME=GROUP_NAME(3),ROLE3_NAME=ROLE_NAME(3),
            RESOURCE4_NAME=RESOURCE_NAME(4),GROUP4_NAME=GROUP_NAME(4),ROLE4_NAME=ROLE_NAME(4),
            RESOURCE5_NAME=RESOURCE_NAME(5),GROUP5_NAME=GROUP_NAME(5),ROLE5_NAME=ROLE_NAME(5),
            RESOURCE6_NAME=RESOURCE_NAME(6),GROUP6_NAME=GROUP_NAME(6),ROLE6_NAME=ROLE_NAME(6),
            RESOURCE7_NAME=RESOURCE_NAME(7),GROUP7_NAME=GROUP_NAME(7),ROLE7_NAME=ROLE_NAME(7),
            RESOURCE8_NAME=RESOURCE_NAME(8),GROUP8_NAME=GROUP_NAME(8),ROLE8_NAME=ROLE_NAME(8),
            RESOURCE9_NAME=RESOURCE_NAME(9),GROUP9_NAME=GROUP_NAME(9),ROLE9_NAME=ROLE_NAME(9),
            RESOURCE10_NAME=RESOURCE_NAME(10),GROUP10_NAME=GROUP_NAME(10),ROLE10_NAME=ROLE_NAME(10),
            RESOURCE11_NAME=RESOURCE_NAME(11),GROUP11_NAME=GROUP_NAME(11),ROLE11_NAME=ROLE_NAME(11),
            RESOURCE12_NAME=RESOURCE_NAME(12),GROUP12_NAME=GROUP_NAME(12),ROLE12_NAME=ROLE_NAME(12),
            RESOURCE13_NAME=RESOURCE_NAME(13),GROUP13_NAME=GROUP_NAME(13),ROLE13_NAME=ROLE_NAME(13),
            RESOURCE14_NAME=RESOURCE_NAME(14),GROUP14_NAME=GROUP_NAME(14),ROLE14_NAME=ROLE_NAME(14),
            RESOURCE15_NAME=RESOURCE_NAME(15),GROUP15_NAME=GROUP_NAME(15),ROLE15_NAME=ROLE_NAME(15),
            RESOURCE16_NAME=RESOURCE_NAME(16),GROUP16_NAME=GROUP_NAME(16),ROLE16_NAME=ROLE_NAME(16),
            RESOURCE17_NAME=RESOURCE_NAME(17),GROUP17_NAME=GROUP_NAME(17),ROLE17_NAME=ROLE_NAME(17),
            RESOURCE18_NAME=RESOURCE_NAME(18),GROUP18_NAME=GROUP_NAME(18),ROLE18_NAME=ROLE_NAME(18),
            RESOURCE19_NAME=RESOURCE_NAME(19),GROUP19_NAME=GROUP_NAME(19),ROLE19_NAME=ROLE_NAME(19),
            RESOURCE20_NAME=RESOURCE_NAME(20),GROUP20_NAME=GROUP_NAME(20),ROLE20_NAME=ROLE_NAME(20),
            RESOURCE21_NAME=RESOURCE_NAME(21),GROUP21_NAME=GROUP_NAME(21),ROLE21_NAME=ROLE_NAME(21),
            RESOURCE22_NAME=RESOURCE_NAME(22),GROUP22_NAME=GROUP_NAME(22),ROLE22_NAME=ROLE_NAME(22),
            RESOURCE23_NAME=RESOURCE_NAME(23),GROUP23_NAME=GROUP_NAME(23),ROLE23_NAME=ROLE_NAME(23),
            RESOURCE24_NAME=RESOURCE_NAME(24),GROUP24_NAME=GROUP_NAME(24),ROLE24_NAME=ROLE_NAME(24),
            RESOURCE25_NAME=RESOURCE_NAME(25),GROUP25_NAME=GROUP_NAME(25),ROLE25_NAME=ROLE_NAME(25),
            RESOURCE26_NAME=RESOURCE_NAME(26),GROUP26_NAME=GROUP_NAME(26),ROLE26_NAME=ROLE_NAME(26),
            RESOURCE27_NAME=RESOURCE_NAME(27),GROUP27_NAME=GROUP_NAME(27),ROLE27_NAME=ROLE_NAME(27),
            RESOURCE28_NAME=RESOURCE_NAME(28),GROUP28_NAME=GROUP_NAME(28),ROLE28_NAME=ROLE_NAME(28),
            RESOURCE29_NAME=RESOURCE_NAME(29),GROUP29_NAME=GROUP_NAME(29),ROLE29_NAME=ROLE_NAME(29),
            RESOURCE30_NAME=RESOURCE_NAME(30),GROUP30_NAME=GROUP_NAME(30),ROLE30_NAME=ROLE_NAME(30)
          WHERE user_id = p_userid
                --and TERR_GRP_ACCT_ID = NAST_tbl.TERR_GRP_ACCT_ID(m);
                AND TERR_GRP_ACCT_ID =m.TERR_GRP_ACCT_ID;


        --   if mod(i, 300)=0 then insert into tmp values ( to_char(sysdate,'HH,MI:SS'), 'finish update with ' || i); commit; end if;

                END LOOP; -- of NA
    x_seq := TO_CHAR(seq);
    ---insert into tmp values ( to_char(sysdate,'HH,MI:SS'), '5. done with update, seq=' || x_seq); commit;
    COMMIT;
    -- clear all fields

 END;


END Jtf_Tty_Webadi_Nadoc_Pkg;

/
