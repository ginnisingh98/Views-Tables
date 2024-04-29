--------------------------------------------------------
--  DDL for Package Body PN_PROFILE_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_PROFILE_UPGRADE" AS
/* $Header: PNXPROFB.pls 120.4 2006/04/03 10:13:28 appldev noship $ */

   TYPE def_set_of_books_type IS TABLE OF hr_operating_units%ROWTYPE
      INDEX BY BINARY_INTEGER;

   TYPE profile_value_rec_type IS RECORD
      (profile_option_name  fnd_profile_options.profile_option_name%TYPE,
       profile_option_value fnd_profile_option_values.profile_option_value%TYPE,
       level_id             fnd_profile_option_values.level_id%TYPE,
       level_value          fnd_profile_option_values.level_value%TYPE);

   TYPE profile_value_type IS TABLE OF profile_value_rec_type
      INDEX BY BINARY_INTEGER;

   def_set_of_books_tbl   def_set_of_books_type;
   profile_value_tbl      profile_value_type;

   g_default_org_id pn_system_setup_options.org_id%TYPE;
   g_profileid4orgid fnd_profile_options.profile_option_id%TYPE;


/*-----------------------------------------------------------------------------
| FUNCTION : get_value
| PURPOSE  : gets profile value for a given parameter
| NOTE     : o assumes internal tables are populated through init_lookup_vars
|            o will return default value if no match found
|            o optimization note:
|              - the search algorithm assumes the tables are structured in
|                a specific order
| HISTORY  : 26-MAR-02  ftanudja  created
|            28-JAN-04  atuppad   Added code to handle 2 profile options:
|                                 GL_TRANSFER_MODE and SUBMIT_JOURNAL_IMPORT
\----------------------------------------------------------------------------*/

FUNCTION  get_value(p_resp_id NUMBER,
                    p_parameter   VARCHAR2)
   RETURN VARCHAR2
IS
   l_result VARCHAR2(30);
BEGIN

   FOR i IN 0 .. (profile_value_tbl.count - 1) LOOP
      IF ((profile_value_tbl(i).profile_option_name = p_parameter) AND
          (profile_value_tbl(i).level_value = p_resp_id)AND
          (profile_value_tbl(i).level_id = 10003))
         OR
         ((profile_value_tbl(i).level_id <> 10003) AND
          (profile_value_tbl(i).profile_option_name = p_parameter))
         THEN
            l_result := profile_value_tbl(i).profile_option_value;
            EXIT;
      END IF;
   END LOOP;

   -- take care of default value;

   IF l_result IS NOT NULL OR p_parameter IN ('PN_GL_TRANSFER_MODE','PN_SUBMIT_JOURNAL_IMPORT') THEN
      RETURN l_result;
   ELSIF p_parameter NOT IN ('PN_SET_OF_BOOKS_ID','PN_CURRENCY_CONV_RATE_TYPE',
                             'PN_ACCOUNTING_OPTION','PN_SPASGN_CHNGDT_OPTN') THEN
      RETURN 'N';
   ELSIF p_parameter IN ('PN_ACCOUNTING_OPTION','PN_SPASGN_CHNGDT_OPTN') THEN
      RETURN 'Y';
   ELSE
      RETURN '';
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      null;
END;


/*-----------------------------------------\
| FUNCTION : get_def_set_of_books_id
| PURPOSE  : gets default set of books id
| NOTE     : assumes internal tables are initialized through init_lookup_vars
| HISTORY  : 26-MAR-2002  ftanudja  created
\------------------------------------------*/

FUNCTION get_def_set_of_books_id(p_org_id NUMBER) RETURN NUMBER
IS
   l_result NUMBER;
BEGIN

   FOR i IN 0 .. (def_set_of_books_tbl.count - 1) LOOP
      IF (def_set_of_books_tbl(i).organization_id = p_org_id) THEN
         l_result := def_set_of_books_tbl(i).set_of_books_id;
         EXIT;
      END IF;
   END LOOP;

   RETURN l_result;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END;

/*-----------------------------------------------------------------------------
| PROCEDURE : init_lookup_vars
| PURPOSE   : initializes data into plsql tables
| NOTES     : o assumes 10001 = level_id for site
|             o assumes 10002 = level_id for application
|             o cursor get_def_org_id is ordered by level_id
|             oo the fetch loop picks up lowest level => if find higher level_id, replace
|             o cursor profile_option_cur is ordered by profile_option_name then level_id
|             oo will go through the list starting from the highest level first (i.e resp level)
|             oo if not found, default at next level (app level then site level)
| HISTORY   : 26-MAR-2002  ftanudja  o created
|           : 11-SEP-2002  ftanudja  o added handle for PN_MULTIPLE_LEASE_FOR_LOCATION
|                                    o changed TO_NUMBER() to TRIM() and put TO_CHAR()
|                                      in get_def_set_of_books_cur
|           : 07-AUG-2003  ftanudja  o added constraint for application id. 3084731.
|           : 07-OCT-2003  ftanudja  o removed 'DISTINCT' and added alias ref to tbl.
|           : 03-FEB-2005  ftanudja  o add 'PN_MULT_TNC_FOR_SAME_LEASE'. 4150676
\----------------------------------------------------------------------------*/

PROCEDURE init_lookup_vars
IS

   CURSOR profile_option_cur IS
      SELECT o.profile_option_name,
             v.profile_option_value,
             v.level_id,
             v.level_value
      FROM   fnd_profile_options       o,
             fnd_profile_option_values v
      WHERE  o.profile_option_id       = v.profile_option_id
      AND    o.application_id          = v.application_id
      AND    v.level_id                <> 10004
      AND    o.profile_option_name IN ('PN_ACCOUNTING_OPTION',
                                'PN_SET_OF_BOOKS_ID',
                                'PN_AUTOMATIC_COMPANY_NUMBER',
                                'PN_AUTOMATIC_INDEX_RENT_NUMBERING',
                                'PN_AUTOMATIC_LEASE_NUMBER',
                                'PN_AUTOMATIC_SPACE_DISTRIBUTION',
                                'PN_AUTO_VAR_RENT_NUM',
                                'PN_CURRENCY_CONV_RATE_TYPE',
                                'PN_SPASGN_CHNGDT_OPTN',
                                'PN_MULTIPLE_LEASE_FOR_LOCATION',
                                'PN_MULT_TNC_FOR_SAME_LEASE')
      ORDER BY 1, 3 DESC;

   CURSOR def_set_of_books_cur IS
      SELECT   hr.organization_id                org_id,
               hr.set_of_books_id                set_of_books_id
      FROM     hr_operating_units                hr,
               fnd_profile_options               o,
               fnd_profile_option_values         v
      WHERE    v.profile_option_id               = o.profile_option_id
        AND    o.profile_option_name             = 'ORG_ID'
        AND    v.level_id                        <> 10004
        AND    TRIM(v.profile_option_value)      = TO_CHAR(hr.organization_id)
      GROUP BY hr.organization_id, hr.set_of_books_id
      ORDER BY 1;

   CURSOR get_def_org_id IS
      SELECT   TO_NUMBER(v.profile_option_value) org_id, v.level_id
      FROM     fnd_profile_option_values v, fnd_profile_options o
      WHERE    v.profile_option_id = o.profile_option_id
      AND      o.profile_option_name = 'ORG_ID'
      AND      v.level_id IN (10002,10001)
      ORDER BY 2;

   CURSOR get_profileid4orgid IS
      SELECT   profile_option_id
      FROM     fnd_profile_options
      WHERE    profile_option_name = 'ORG_ID';

   l_counter NUMBER := 0;
   l_info_text VARCHAR2(200);
BEGIN

   l_info_text := 'creating default set of books plsql table';

   def_set_of_books_tbl.delete;
   FOR def_rec IN def_set_of_books_cur LOOP
      def_set_of_books_tbl(l_counter).organization_id := def_rec.org_id;
      def_set_of_books_tbl(l_counter).set_of_books_id := def_rec.set_of_books_id;
      l_counter := l_counter + 1;
   END LOOP;

   l_counter := 0;
   l_info_text := 'creating list of profile options plsql table';

   profile_value_tbl.delete;
   FOR prof_rec IN profile_option_cur LOOP
      profile_value_tbl(l_counter).profile_option_name  := prof_rec.profile_option_name;
      profile_value_tbl(l_counter).profile_option_value := prof_rec.profile_option_value;
      profile_value_tbl(l_counter).level_id             := prof_rec.level_id;
      profile_value_tbl(l_counter).level_value          := prof_rec.level_value;
      l_counter := l_counter + 1;
   END LOOP;

   l_info_text := 'populating default_org_id variable';
   OPEN get_def_org_id;
   LOOP
      FETCH get_def_org_id INTO g_default_org_id, l_counter;
      EXIT WHEN get_def_org_id%NOTFOUND;
   END LOOP;
   CLOSE get_def_org_id;

   l_info_text := 'populating profile_id for org_id variable';
   OPEN get_profileid4orgid;
   LOOP
      FETCH get_profileid4orgid INTO g_profileid4orgid;
      EXIT WHEN get_profileid4orgid%NOTFOUND;
   END LOOP;
   CLOSE get_profileid4orgid;

EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001,'Error while ' || l_info_text || to_char(sqlcode));
      app_exception.raise_exception;
END;


/*-----------------------------------------------------------------------------
| PROCEDURE : populate_profile_tbl
| PURPOSE   : inserts data into the pn_system_setup_options table
| NOTE      : o assumes -1 is not a valid level_value
|             o optimization note:
|              oo the search algorithm assumes the tables are structured in a
|                 specific order
|              oo for entries with the same org_id, the one with the most user
|                 is placed on top of list
| HISTORY  :
| 26-MAR-02  ftanudja  created.
| 11-SEP-02  ftanudja  added handle for PN_MULTIPLE_LEASE_FOR_LOCATION.
| 30-JUN-03  ftanudja  during INSERT, added new required columns from recovery
|                      module. And populated them with default values
|                      (since these are new profiles)
| 22-JUL-04  atuppad  Optimized the main cursor for performance bug#3779117.
|                     Also, issued a mass insert on the table.
| 26-JUL-04  atuppad  Added the default value of default_user_view_code col.
| 30-AUG-04  ftanudja  add default value of 'extend_indexrent_term_flag'
|                      Reference bug #3756208.
| 28-OCT-04  atuppad  o Added code for 4 columns of Retro.
| 30-DEC-04  kkhegde  o Added calc_annualized_basis_code column.
| 15-DEC-05  kkhegde  o Added recalc_ir_on_acc_chg_flag column default 'Y'
| 23-MAR-06  Hareesha o Bug 5106419 Modified to handle case when
|                       mandatory columns of pn_system_setup_options are NULL.
| 24-MAR-06  Hareesha o Bug 5106419 Needed to update the default value of
|                       ACCOUNTING_OPTION
| 03-APR-06  Kiran    o Bug 5135571 changed OrgId, RespId, Count to tables
|                       INDEX BY BINARY_INTEGER
\----------------------------------------------------------------------------*/

PROCEDURE populate_profile_tbl
IS

   CURSOR active_pn_resp_cur IS
     SELECT   NVL(v.profile_option_value, g_default_org_id)
                                         org_id,
               r.responsibility_id       resp_id,
               COUNT(u.user_id)          num_users
      FROM     fnd_user u,
               wf_user_roles wur,
               fnd_responsibility        r,
               fnd_profile_option_values v
      WHERE    r.application_id          = 240
        AND    r.responsibility_id       = wur.role_orig_system_id (+)
        AND    wur.role_orig_system (+) = 'FND_RESP'
        AND    not wur.role_name (+) like 'FND_RESP|%|ANY'
        AND    u.user_name(+)            = wur.user_name
        AND    r.start_date              <= SYSDATE
        AND    NVL(r.end_date, SYSDATE)  >= SYSDATE
        AND    v.profile_option_id    = g_profileid4orgid
        AND    v.level_value          = r.responsibility_id
        AND    v.profile_option_value NOT IN (SELECT org_id
                                              FROM   pn_system_setup_options)
        AND    v.level_value_application_id = 240
        AND    v.level_id = 10003
      GROUP BY r.responsibility_id, v.profile_option_value
      UNION
      SELECT TO_CHAR(g_default_org_id) org_id,
             0                resp_id,
             0                num_users
      FROM   dual
      WHERE  NOT EXISTS (SELECT NULL
                         FROM   fnd_profile_option_values v
                         WHERE  v.profile_option_id   = g_profileid4orgid
                         AND    v.profile_option_value = g_default_org_id
                         AND    v.level_id = 10003
                         AND    v.level_value_application_id = 240
                         AND    EXISTS (SELECT null
                                        FROM pn_system_setup_options
                                        WHERE org_id = g_default_org_id))
      ORDER BY  1,3 DESC;

   -- Get multiorg flag
   CURSOR multi_org_cur IS
      SELECT nvl(multi_org_flag, 'N') multi_org
      FROM   fnd_product_groups;

   l_prev NUMBER := -1;
   l_multi_org VARCHAR2(1) := 'N';
   l_exists VARCHAR2(1);
   l_info_text VARCHAR2(200);

   TYPE OrgId  IS TABLE OF pn_system_setup_options.org_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE RespId IS TABLE OF fnd_responsibility.responsibility_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE Count  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   orgids    OrgId;
   respids   RespId;
   counts    Count;

   l_set_of_books_id NUMBER(15);

BEGIN

   l_info_text := 'Selecting multi org flag';
   FOR multi_org_rec IN multi_org_cur LOOP
     l_multi_org := multi_org_rec.multi_org;
   END LOOP;


   IF (UPPER(l_multi_org) = 'Y') THEN

     OPEN active_pn_resp_cur;
     LOOP
       orgids.DELETE;
       respids.DELETE;
       counts.DELETE;

       FETCH active_pn_resp_cur BULK COLLECT INTO orgids, respids, counts LIMIT 1000;
       EXIT WHEN active_pn_resp_cur%NOTFOUND;
       FOR i IN 1..orgids.COUNT LOOP

         l_set_of_books_id := nvl(TO_NUMBER(get_value(respids(i), 'PN_SET_OF_BOOKS_ID')),
                                 get_def_set_of_books_id(orgids(i)));

         IF l_set_of_books_id IS NOT NULL THEN

           INSERT INTO pn_system_setup_options
                 (profile_id,
                  org_id,
                  accounting_option,
                  set_of_books_id,
                  default_currency_conv_type,
                  space_assign_sysdate_optn,
                  multiple_tenancy_lease,
                  auto_comp_num_gen,
                  auto_lease_num_gen,
                  auto_index_num_gen,
                  auto_space_distribution,
                  auto_var_rent_num_gen,
                  auto_rec_agr_num_flag,
                  auto_rec_exp_num_flag,
                  auto_rec_arcl_num_flag,
                  auto_rec_expcl_num_flag,
                  cons_rec_agrterms_flag,
                  default_locn_area_flag,
                  default_user_view_code,
                  extend_indexrent_term_flag,
                  sysdate_for_adj_flag,
                  sysdate_as_trx_date_flag,
                  renorm_adj_acc_all_draft_flag,
                  consolidate_adj_items_flag,
                  calc_annualized_basis_code,
                  allow_tenancy_overlap_flag,
                  recalc_ir_on_acc_chg_flag,
                  created_by,
                  last_update_login,
                  last_updated_by,
                  creation_date,
                  last_update_date)
           VALUES(pn_system_setup_options_s.nextval,
                  orgids(i),
                  NVL(get_value(respids(i), 'PN_ACCOUNTING_OPTION'),'Y'),
                  l_set_of_books_id,
                  get_value(respids(i), 'PN_CURRENCY_CONV_RATE_TYPE'),
                  NVL(get_value(respids(i), 'PN_SPASGN_CHNGDT_OPTN'),'Y'),
                  NVL(get_value(respids(i), 'PN_MULTIPLE_LEASE_FOR_LOCATION'),'N'),
                  NVL(get_value(respids(i), 'PN_AUTOMATIC_COMPANY_NUMBER'),'Y'),
                  NVL(get_value(respids(i), 'PN_AUTOMATIC_LEASE_NUMBER'),'Y'),
                  NVL(get_value(respids(i), 'PN_AUTOMATIC_INDEX_RENT_NUMBERING'),'N'),
                  NVL(get_value(respids(i), 'PN_SPACE_DISTRIBUTION'),'N'),
                  NVL(get_value(respids(i), 'PN_AUTO_VAR_RENT_NUMBER'),'N'),
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'TENANT',
                  'Y',
                  'Y',
                  'N',
                  'Y',
                  'N',
                  'PERIOD',
                  NVL(get_value(respids(i), 'PN_MULT_TNC_FOR_SAME_LEASE'),'N'),
                  'Y',
                  NVL(fnd_global.user_id, -1),
                  NVL(fnd_global.user_id, -1),
                  NVL(fnd_global.user_id, -1),
                  SYSDATE,
                  SYSDATE);

         END IF;

       END LOOP;

     END LOOP;

     CLOSE active_pn_resp_cur;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      l_info_text := SQLERRM;
      raise_application_error(-20001,'Error while ' || l_info_text || to_char(sqlcode));
      app_exception.raise_exception;
END;


/*-----------------------------------------------------------------------------
| PROCEDURE     : init_lookup_vars_migr
| PURPOSE       : initializes data into plsql tables
| DESCRIPTION   : Initializes the table with the profile values for the 2 new
|                 profiles that need to be migrated. The 2 profiles are:
|                 1. GL_TRANSFER_MODE  2. SUBMIT_JOURNAL_IMPORT
|                 This proc is similar to init_lookup_vars procedure.
| NOTES         : Please refer to notes in procedure init_lookup_vars.
| HISTORY   : 28-JAN-2004  atuppad   o created
-----------------------------------------------------------------------------*/

PROCEDURE init_lookup_vars_migr
IS

   CURSOR profile_option_cur IS
      SELECT o.profile_option_name,
             v.profile_option_value,
             v.level_id,
             v.level_value
      FROM   fnd_profile_options       o,
             fnd_profile_option_values v
      WHERE  o.profile_option_id       = v.profile_option_id
      AND    o.application_id          = v.application_id
      AND    v.level_id                <> 10004
      AND    o.profile_option_name IN ('PN_GL_TRANSFER_MODE','PN_SUBMIT_JOURNAL_IMPORT')
      ORDER BY 1, 3 DESC;

   CURSOR get_profileid4orgid IS
      SELECT   profile_option_id
      FROM     fnd_profile_options
      WHERE    profile_option_name = 'ORG_ID';

   CURSOR get_def_org_id IS
      SELECT   TO_NUMBER(v.profile_option_value) org_id, v.level_id
      FROM     fnd_profile_option_values v, fnd_profile_options o
      WHERE    v.profile_option_id = o.profile_option_id
      AND      o.profile_option_name = 'ORG_ID'
      AND      v.level_id IN (10002,10001)
      ORDER BY 2;

   l_counter NUMBER := 0;
   l_info_text VARCHAR2(200);
BEGIN

   l_counter := 0;
   l_info_text := 'creating list of profile options plsql table';

   profile_value_tbl.delete;
   FOR prof_rec IN profile_option_cur LOOP
      profile_value_tbl(l_counter).profile_option_name  := prof_rec.profile_option_name;
      profile_value_tbl(l_counter).profile_option_value := prof_rec.profile_option_value;
      profile_value_tbl(l_counter).level_id             := prof_rec.level_id;
      profile_value_tbl(l_counter).level_value          := prof_rec.level_value;
      l_counter := l_counter + 1;
   END LOOP;

   l_info_text := 'populating default_org_id variable';
   OPEN get_def_org_id;
   LOOP
      FETCH get_def_org_id INTO g_default_org_id, l_counter;
      EXIT WHEN get_def_org_id%NOTFOUND;
   END LOOP;
   CLOSE get_def_org_id;

   l_info_text := 'populating profile_id for org_id variable';
   OPEN get_profileid4orgid;
   LOOP
      FETCH get_profileid4orgid INTO g_profileid4orgid;
      EXIT WHEN get_profileid4orgid%NOTFOUND;
   END LOOP;
   CLOSE get_profileid4orgid;

EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001,'Error while ' || l_info_text || to_char(sqlcode));
      app_exception.raise_exception;

END init_lookup_vars_migr;


/*-----------------------------------------------------------------------------
| PROCEDURE : update_profile_tbl
| PURPOSE   : updates data into the pn_system_setup_options table for migration
| DESCRIPTION: This procedure will update the pn_system_setup_option table for
|              migration of GL_TRANSFER_MODE and SUBMIT_JOURNAL_IMPORT
| NOTE      : Please refer to populate_profile_tbl procedure.
| HISTORY   :
| 28-JAN-04  atuppad  o created.
| 22-JUL-04  atuppad  o Optimized the main cursor for performance bug#3779117.
|                       Also, issued a mass update on the table.
\----------------------------------------------------------------------------*/

PROCEDURE update_profile_tbl
IS

   CURSOR active_pn_resp_cur IS
     SELECT   NVL(v.profile_option_value, g_default_org_id)
                                         org_id,
               r.responsibility_id       resp_id,
               COUNT(u.user_id)          num_users
      FROM     fnd_user u,
               wf_user_roles wur,
               fnd_responsibility        r,
               fnd_profile_option_values v
      WHERE    r.application_id          = 240
        AND    r.responsibility_id       = wur.role_orig_system_id (+)
        AND    wur.role_orig_system (+) = 'FND_RESP'
        AND    not wur.role_name (+) like 'FND_RESP|%|ANY'
        AND    u.user_name(+)            = wur.user_name
        AND    r.start_date              <= SYSDATE
        AND    NVL(r.end_date, SYSDATE)  >= SYSDATE
        AND    v.profile_option_id    = g_profileid4orgid
        AND    v.level_value          = r.responsibility_id
        AND    v.profile_option_value IN (SELECT org_id
                                          FROM   pn_system_setup_options)
        AND    v.level_value_application_id = 240
        AND    v.level_id = 10003
      GROUP BY r.responsibility_id, v.profile_option_value
      UNION
      SELECT TO_CHAR(g_default_org_id) org_id,
             0                resp_id,
             0                num_users
      FROM   dual
      WHERE  NOT EXISTS (SELECT NULL
                         FROM   fnd_profile_option_values v
                         WHERE  v.profile_option_id   = g_profileid4orgid
                         AND    v.profile_option_value = g_default_org_id
                         AND    v.level_id = 10003
                         AND    v.level_value_application_id = 240
                         AND    EXISTS (SELECT null
                                        FROM pn_system_setup_options
                                        WHERE org_id = g_default_org_id))
      ORDER BY  1,3 DESC;

   -- Get multiorg flag
   CURSOR multi_org_cur IS
      SELECT nvl(multi_org_flag, 'N') multi_org
      FROM   fnd_product_groups;

   l_prev         NUMBER := -1;
   l_multi_org    VARCHAR2(1) := 'N';
   l_exists       VARCHAR2(1);
   l_info_text    VARCHAR2(200);
   TYPE OrgId  IS TABLE OF pn_system_setup_options.org_id%TYPE;
   TYPE RespId IS TABLE OF fnd_responsibility.responsibility_id%TYPE;
   TYPE Count  IS TABLE OF NUMBER;

   orgids    OrgId;
   respids   RespId;
   counts    Count;

BEGIN

   l_info_text := 'Selecting multi org flag';
   FOR multi_org_rec IN multi_org_cur LOOP
     l_multi_org := multi_org_rec.multi_org;
   END LOOP;

   IF (UPPER(l_multi_org) = 'Y') THEN
     OPEN active_pn_resp_cur;
     LOOP
       FETCH active_pn_resp_cur BULK COLLECT INTO orgids, respids, counts LIMIT 1000;

       FORALL i IN 1..orgids.COUNT
         UPDATE PN_SYSTEM_SETUP_OPTIONS
         SET    gl_transfer_mode           = get_value(respids(i),'PN_GL_TRANSFER_MODE'),
                submit_journal_import_flag = get_value(respids(i),'PN_SUBMIT_JOURNAL_IMPORT'),
                last_update_login          = NVL(fnd_global.user_id, -1),
                last_updated_by            = NVL(fnd_global.user_id, -1),
                last_update_date           = SYSDATE
         WHERE  org_id = orgids(i);
       EXIT WHEN active_pn_resp_cur%NOTFOUND;

     END LOOP;
     CLOSE active_pn_resp_cur;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001,'Error while ' || l_info_text || to_char(sqlcode));
      app_exception.raise_exception;

END update_profile_tbl;

END pn_profile_upgrade;

/
