--------------------------------------------------------
--  DDL for Package Body IMC_REPORTS_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IMC_REPORTS_SUMMARY_PKG" AS
/* $Header: imcrsumb.pls 120.16.12010000.3 2010/03/02 07:17:19 rgokavar ship $ */
-- IMC reports summary extraction program

  --- declarations

  -- g_proc_name is set to the procedure name in a procedure
  g_proc_name    varchar2(50);

  g_party_exists number := 0;
  g_select_str   varchar2(3000);

  TYPE pregrowth_rec_type IS RECORD(
    month_name        VARCHAR2(80),
    exist_flag        VARCHAR2(1)
  );

  TYPE pregrowth_tbl_type IS TABLE OF pregrowth_rec_type INDEX BY BINARY_INTEGER;

  PROCEDURE get_counts;
  PROCEDURE write_log(p_msg varchar2);

  --------------- get_counts -----------------


 --  This PROCEDURE will count the total number of customers and
 --  number of customers FOR each party_type and assigns these values
 --  to the appropriate global variables

 PROCEDURE get_counts IS

      BEGIN

       g_proc_name := 'get_counts';

       -- Single SELECT for all counts, as suggested by Lester Gutierrez

       SELECT
           SUM(DECODE(party_type,'PERSON',
               DECODE(LEAST(creation_date,add_months(sysdate,-23)),
                      add_months(sysdate,-23),count(*),0),
               0)),
           SUM(DECODE(party_type,'ORGANIZATION',
               DECODE(LEAST(creation_date,add_months(sysdate,-23)),
                      add_months(sysdate,-23),count(*),0),
               0)),
           SUM(DECODE(party_type,'PARTY_RELATIONSHIP',
               DECODE(LEAST(creation_date,add_months(sysdate,-23)),
                      add_months(sysdate,-23),count(*),0),
               0)),
           SUM(DECODE(LEAST(creation_date,add_months(sysdate,-23)),
               add_months(sysdate,-23),count(*),0)),
           SUM(count(*))
       INTO   rp_grth_per_cnt, rp_grth_org_cnt, rp_grth_rel_cnt,
              rp_grth_total_cnt, rp_total_cnt
       FROM   hz_parties
       GROUP  BY party_type,creation_date;

       -- for total person, organization and relationship count
       -- the party must be active.  Don't include inactive,
       -- deleted or merged parties.
       SELECT
           SUM(DECODE(party_type,'PERSON',            count(*),0)),
           SUM(DECODE(party_type,'ORGANIZATION',      count(*),0)),
           SUM(DECODE(party_type,'PARTY_RELATIONSHIP',count(*),0))
       INTO   rp_per_cnt, rp_org_cnt, rp_rel_cnt
       FROM   hz_parties
       WHERE  status = 'A'
       GROUP  BY party_type;

       g_party_exists := 2;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
	 g_party_exists := 1;
         write_log('No data found in HZ_PARTIES:' || sqlerrm);

    WHEN OTHERS THEN
         write_log('Error:' || sqlerrm);

 END get_counts;

 PROCEDURE write_log (p_msg varchar2) IS

 -- This procedure logs errors and information messages
 -- The variable g_log_flag is used as a flag whether to use fnd_file.put_line
 -- or not.
 -- If it is set to null, error messages are logged to fnd_file.
 -- If it set to some value, the message can be printed using dbms_output
 -- instead of fnd_file.put_line.
 -- This is used only during developement and testing as fnd_file
 -- can not be used from the SQL prompt.

 BEGIN
   IF g_log_output IS NULL THEN
      fnd_file.put_line
	 (fnd_file.log,substr(p_msg || ': ' || g_proc_name,1,350) ||
	  to_char(sysdate,'dd-mon-yy hh24:mi:ss'));
   END IF;

 END write_log;


 -------- Loads data related to Industry chart and report --------
 --- Report Name : INDUSTRY     ---
 --- Party  Types: ORGANIZATION ---
 --- Report Types: R and G      ---

 PROCEDURE load_industry IS

   l_nd_ind     NUMBER;

 BEGIN

   g_proc_name := 'load_industry';

   -- INSERT all the categories for ORGANIZATION

   -- fix bug 3296096, get CUSTOMER_CATEGORY from
   -- HZ_CODE_ASSIGNMENTS table

   -- fix perf bug 3638775, here are the steps
   -- Run sql statement twice is much faster than having outer join to HZ_PARTIES
   -- 1) get all industry with customer_category
   -- 2) count the total number of parties with customer_category
   -- 3) deduct the total number of organization by total number calculated at step 2
   --    the result will be those undefined industry

   -- Step 1
   INSERT INTO imc_reports_tempinfo(report_name,
 			            report_type,
			            category,
				    parent_category,
				    org_cnt,
			            time_stamp)
   SELECT 'INDUSTRY','R',
          industry, 'YES' industry_code, sum(org_count), sysdate
   FROM   (SELECT  lkp.meaning industry,
                   decode(pty.party_type, 'ORGANIZATION', count(*), 0) org_count
           FROM    hz_parties pty, hz_code_assignments look, ar_lookups lkp
           WHERE   look.class_category = 'CUSTOMER_CATEGORY'
           AND     look.owner_table_name = 'HZ_PARTIES'
           AND     pty.party_id = look.owner_table_id
           AND     pty.party_type = 'ORGANIZATION'
           AND     pty.status = 'A'
           AND     look.class_code = lkp.lookup_code
           AND     sysdate between look.start_date_active and nvl(look.end_date_active,sysdate)
           AND     lkp.lookup_type = 'CUSTOMER_CATEGORY'
           GROUP   BY lkp.meaning, pty.party_type)
   GROUP   BY industry;

   -- Step 2
   SELECT count(1) INTO l_nd_ind
   FROM (SELECT  1
         FROM    hz_parties pty, hz_code_assignments look, ar_lookups lkp
         WHERE   look.class_category = 'CUSTOMER_CATEGORY'
         AND     look.owner_table_name = 'HZ_PARTIES'
         AND     pty.party_id = look.owner_table_id
         AND     pty.party_type = 'ORGANIZATION'
         AND     pty.status = 'A'
         AND     look.class_code = lkp.lookup_code
         AND     sysdate between look.start_date_active and nvl(look.end_date_active,sysdate)
         AND     lkp.lookup_type = 'CUSTOMER_CATEGORY'
         GROUP BY pty.party_id);

   -- Step 3
   INSERT INTO imc_reports_tempinfo(report_name,
                                    report_type,
                                    category,
                                    parent_category,
                                    org_cnt,
                                    time_stamp)
   VALUES
   ('INDUSTRY','R', rp_msg_undefined, 'YES', rp_org_cnt-l_nd_ind, sysdate);

   SELECT nvl(sum(org_cnt),0)
   INTO rp_ind_org_cnt
   FROM imc_reports_tempinfo
   WHERE report_name = 'INDUSTRY'
   AND report_type = 'R';

   -- UPDATE percentage for ORGANIZATION by industry

   IF rp_ind_org_cnt > 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     org_pct = round((org_cnt/rp_ind_org_cnt)*100,2)
      WHERE   report_name = 'INDUSTRY'
      AND     report_type = 'R';

   END IF;

/* Bug 3296096, total does not match with the sum of all category
   by count.  So, comment out this total count after talking to PM
   as this total # does not make a good meaning on the number
   the total # of organizations are shown on graph
   -- INSERT 'Total' row for ORGANIZATION by industry

   INSERT INTO imc_reports_tempinfo(report_name,
 			            report_type,
			            category,
			            org_cnt,
			            org_pct,
			            time_stamp)
   SELECT 'INDUSTRY','R',rp_msg_total, nvl(rp_org_cnt,0),'100.00',sysdate
   FROM    dual;
*/

   -- INSERT 'Top 5' counts for ORGANIZATION by industry

   INSERT INTO imc_reports_tempinfo(report_name,
  			            report_type,
			            category,
				    parent_category,
			            org_cnt,
			            org_pct,
			            time_stamp)
   SELECT 'INDUSTRY','G', category, parent_category,
           org_cnt, org_pct, sysdate
   FROM (SELECT category, parent_category, org_cnt, org_pct
         FROM   imc_reports_tempinfo
         WHERE  report_name = 'INDUSTRY'
         AND    report_type = 'R'
         AND    org_cnt IS NOT NULL
         AND    NOT (org_pct = 100 AND parent_category IS NULL)
         ORDER  BY org_cnt DESC)
   WHERE rownum < 6;


   -- INSERT 'All Others' row for ORGANIZATION by industry

   IF rp_org_cnt > 0 THEN

      INSERT INTO imc_reports_tempinfo(report_name,
			               report_type,
			               category,
				       org_cnt,
				       org_pct,
			               time_stamp)
      SELECT 'INDUSTRY','G',rp_msg_all_others,
             (rp_ind_org_cnt - sum(imc_tmp.org_cnt)),
             round(((rp_ind_org_cnt - sum(imc_tmp.org_cnt))/rp_ind_org_cnt) * 100,2),
             sysdate
      FROM   imc_reports_tempinfo imc_tmp
      WHERE  imc_tmp.report_name = 'INDUSTRY'
      AND    imc_tmp.report_type = 'G';

   END IF;

 COMMIT;

 END load_industry;


 -------- Loads data related to Country chart and report --------
 --- Report Name : COUNTRY                 ---
 --- Party  Types: ORGANIZATION and PERSON ---
 --- Report Types: R and G                 ---

 PROCEDURE load_country IS

   l_nd_org NUMBER;
   l_nd_per NUMBER;

 BEGIN

   g_proc_name := 'load_country';

   -- INSERT all the countries for ORGANIZATION and PERSON

   -- Fix perf bug 3659367.
   -- 1) Use FND_TERRITORIES_TL instead of VL
   -- 2) Count the number of parties which has country set
   -- 3) By deducting the total number of parties by the total number of parites
   --    having country information, we will get the number of parties which do
   --    not have country information

   -- Step 1
   -- Fix perf bug 4915034, use parallel hint on HZ_PARTIES table
   INSERT INTO imc_reports_tempinfo(report_name,
			            report_type,
			            category,
				    parent_category,
			            org_cnt,
				    per_cnt,
			            time_stamp)
   SELECT 'COUNTRY','R',
          terr.territory_short_name  country,
          terr.territory_code        country_code,
          pty.org_count, pty.per_count, sysdate
   FROM (SELECT country, sum(org_count) org_count, sum(per_count) per_count
         FROM (SELECT /*+ parallel(pty) */  pty.country,
                      DECODE(pty.party_type,'ORGANIZATION',count(*),0) org_count,
                      DECODE(pty.party_type,'PERSON',count(*),0) per_count
               FROM  hz_parties pty
               WHERE pty.party_type IN ('ORGANIZATION','PERSON')
               AND pty.status = 'A'
               GROUP BY pty.country, pty.party_type )
         GROUP BY country ) pty ,
         fnd_territories_tl terr
   WHERE pty.country = terr.territory_code
   AND terr.language = userenv('LANG')
   ORDER BY country, country_code;

   -- Step 2
   SELECT sum(org_cnt), sum(per_cnt) INTO l_nd_org, l_nd_per
   FROM IMC_REPORTS_TEMPINFO
   WHERE report_name = 'COUNTRY'
   AND report_type = 'R';

   -- Step 3
   INSERT INTO imc_reports_tempinfo(report_name,
                                    report_type,
                                    category,
                                    parent_category,
                                    org_cnt,
                                    per_cnt,
                                    time_stamp)
   VALUES
   ('COUNTRY','R', rp_msg_undefined, NULL,
    rp_org_cnt-l_nd_org, rp_per_cnt-l_nd_per, sysdate);

   -- UPDATE percentage for ORGANIZATION and PERSON by country

   IF rp_org_cnt > 0 AND rp_per_cnt > 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     org_pct = round((org_cnt/rp_org_cnt)*100,2),
   	      per_pct = round((per_cnt/rp_per_cnt)*100,2)
      WHERE   report_name = 'COUNTRY'
      AND     report_type = 'R';

   ELSIF rp_org_cnt > 0 AND rp_per_cnt = 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     org_pct = round((org_cnt/rp_org_cnt)*100,2)
      WHERE   report_name = 'COUNTRY'
      AND     report_type = 'R';

   ELSIF rp_org_cnt = 0 AND rp_per_cnt > 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     per_pct = round((per_cnt/rp_per_cnt)*100,2)
      WHERE   report_name = 'COUNTRY'
      AND     report_type = 'R';

   END IF;

   -- INSERT 'Total' row for ORGANIZATION and PERSON by country

   INSERT INTO imc_reports_tempinfo(report_name,
			            report_type,
			            category,
			            org_cnt,
			            org_pct,
				    per_cnt,
				    per_pct,
			            time_stamp)
   SELECT 'COUNTRY','R',rp_msg_total,
	   nvl(rp_org_cnt,0),'100.00',nvl(rp_per_cnt,0),'100.00',sysdate
   FROM    dual;


   -- INSERT 'Top 5' counts for ORGANIZATION and PERSON by country

   INSERT INTO imc_reports_tempinfo(report_name,
			            report_type,
			            category,
				    parent_category,
			            org_cnt,
			            org_pct,
			            time_stamp)
   SELECT 'COUNTRY','G', category, parent_category,
          org_cnt, org_pct, sysdate
   FROM (SELECT category, parent_category, org_cnt, org_pct
         FROM   imc_reports_tempinfo
         WHERE  report_name = 'COUNTRY'
         AND    report_type = 'R'
         AND    org_cnt IS NOT NULL
         AND    NOT (org_pct = 100 AND parent_category IS NULL)
         ORDER  BY org_cnt DESC)
   WHERE rownum < 6;


   INSERT INTO imc_reports_tempinfo(report_name,
			            report_type,
			            category,
				    parent_category,
				    per_cnt,
				    per_pct,
			            time_stamp)
   SELECT 'COUNTRY','G', category, parent_category,
          per_cnt, per_pct, sysdate
   FROM (SELECT category, parent_category, per_cnt, per_pct
         FROM   imc_reports_tempinfo
         WHERE  report_name = 'COUNTRY'
         AND    report_type = 'R'
         AND    per_cnt IS NOT NULL
         AND    NOT (per_pct = 100 AND parent_category IS NULL)
         ORDER  BY per_cnt DESC)
   WHERE rownum < 6;


   -- INSERT 'All Others' row for ORGANIZATION and PERSON by country

   IF rp_org_cnt > 0 AND rp_per_cnt > 0 THEN

      INSERT INTO imc_reports_tempinfo(report_name,
			               report_type,
			               category,
				       org_cnt,
				       org_pct,
				       per_cnt,
				       per_pct,
			               time_stamp)
      SELECT 'COUNTRY','G',rp_msg_all_others,
             (rp_org_cnt - sum(imc_tmp.org_cnt)),
             round(((rp_org_cnt - sum(imc_tmp.org_cnt))/rp_org_cnt) * 100,2),
             (rp_per_cnt - sum(imc_tmp.per_cnt)),
             round(((rp_per_cnt - sum(imc_tmp.per_cnt))/rp_per_cnt) * 100,2),
             sysdate
      FROM   imc_reports_tempinfo imc_tmp
      WHERE  imc_tmp.report_name = 'COUNTRY'
      AND    imc_tmp.report_type = 'G';

   ELSIF rp_org_cnt = 0 AND rp_per_cnt > 0 THEN

      INSERT INTO imc_reports_tempinfo(report_name,
			               report_type,
			               category,
				       org_cnt,
				       org_pct,
				       per_cnt,
				       per_pct,
			               time_stamp)
      SELECT 'COUNTRY','G',rp_msg_all_others,
             (rp_org_cnt - sum(imc_tmp.org_cnt)), 0,
             (rp_per_cnt - sum(imc_tmp.per_cnt)),
             round(((rp_per_cnt - sum(imc_tmp.per_cnt))/rp_per_cnt) * 100,2),
             sysdate
      FROM   imc_reports_tempinfo imc_tmp
      WHERE  imc_tmp.report_name = 'COUNTRY'
      AND    imc_tmp.report_type = 'G';

   ELSIF rp_org_cnt > 0 AND rp_per_cnt = 0 THEN

      INSERT INTO imc_reports_tempinfo(report_name,
			               report_type,
			               category,
				       org_cnt,
				       org_pct,
				       per_cnt,
				       per_pct,
			               time_stamp)
      SELECT 'COUNTRY','G',rp_msg_all_others,
             (rp_org_cnt - sum(imc_tmp.org_cnt)),
             round(((rp_org_cnt - sum(imc_tmp.org_cnt))/rp_org_cnt) * 100,2),
             (rp_per_cnt - sum(imc_tmp.per_cnt)), 0,
             sysdate
      FROM   imc_reports_tempinfo imc_tmp
      WHERE  imc_tmp.report_name = 'COUNTRY'
      AND    imc_tmp.report_type = 'G';

   END IF;

   COMMIT;

 END load_country;


 -------- Loads data related to State chart and report --------
 --- Report Name : STATE                   ---
 --- Party  Types: ORGANIZATION and PERSON ---
 --- Report Types: R and G                 ---

 PROCEDURE load_state IS

 CURSOR state_country IS
       SELECT parent_category,
              sum(org_cnt) org_total,
              sum(per_cnt) per_total
       FROM   imc_reports_tempinfo
       WHERE  report_name = 'STATE'
       AND    report_type = 'R'
       AND    parent_category <> rp_msg_total
       GROUP  BY parent_category;

 BEGIN

   g_proc_name := 'load_state';

   -- INSERT all the states for ORGANIZATION and PERSON

   INSERT INTO imc_reports_tempinfo(report_name,
			            report_type,
			            category,
				    parent_category,
			            org_cnt,
				    per_cnt,
			            time_stamp)
   SELECT 'STATE','R',
	   state,  country, sum(org_count), sum(per_count), sysdate
   FROM   (SELECT  nvl(pty.state,rp_msg_undefined) state,
		   pty.country,
        	   decode(pty.party_type,'ORGANIZATION',count(*),0) org_count,
        	   decode(pty.party_type,'PERSON',count(*),0) per_count
	   FROM    hz_parties pty
	   WHERE   pty.party_type IN ('ORGANIZATION','PERSON')
           AND     pty.status = 'A'
	   GROUP   BY pty.country, pty.state, pty.party_type)
   GROUP   BY country, state;


   FOR i in state_country LOOP

      -- UPDATE percentage for ORGANIZATION and PERSON by state

      IF i.org_total > 0 AND i.per_total > 0 THEN

         UPDATE  imc_reports_tempinfo
         SET     org_pct = round((org_cnt/i.org_total)*100,2),
                 per_pct = round((per_cnt/i.per_total)*100,2)
         WHERE   report_name = 'STATE'
         AND     report_type = 'R'
         AND     parent_category = i.parent_category;

      ELSIF i.org_total > 0 AND i.per_total = 0 THEN

         UPDATE  imc_reports_tempinfo
         SET     org_pct = round((org_cnt/i.org_total)*100,2)
         WHERE   report_name = 'STATE'
         AND     report_type = 'R'
         AND     parent_category = i.parent_category;

      ELSIF i.org_total = 0 AND i.per_total > 0 THEN

         UPDATE  imc_reports_tempinfo
         SET     per_pct = round((per_cnt/i.per_total)*100,2)
         WHERE   report_name = 'STATE'
         AND     report_type = 'R'
         AND     parent_category = i.parent_category;

      END IF;

      -- INSERT 'Top 5' counts for ORGANIZATION and PERSON by state

      INSERT INTO imc_reports_tempinfo(report_name,
			               report_type,
			               category,
				       parent_category,
			               org_cnt,
			               org_pct,
			               time_stamp)
      SELECT 'STATE','G', category, parent_category,
             org_cnt, org_pct, sysdate
      FROM (SELECT category, parent_category, org_cnt, org_pct
            FROM   imc_reports_tempinfo
            WHERE  report_name = 'STATE'
            AND    report_type = 'R'
            AND    org_cnt IS NOT NULL
            AND    NOT (org_pct = 100 AND parent_category IS NULL)
            AND    category <> rp_msg_total
            AND    parent_category = i.parent_category
            ORDER  BY org_cnt DESC)
      WHERE rownum < 6;


      INSERT INTO imc_reports_tempinfo(report_name,
			               report_type,
			               category,
				       parent_category,
				       per_cnt,
				       per_pct,
			               time_stamp)
      SELECT 'STATE','G', category, parent_category,
             per_cnt, per_pct, sysdate
      FROM (SELECT category, parent_category, per_cnt, per_pct
            FROM   imc_reports_tempinfo
            WHERE  report_name = 'STATE'
            AND    report_type = 'R'
            AND    category <> rp_msg_total
            AND    per_cnt IS NOT NULL
            AND    NOT (per_pct = 100 AND parent_category IS NULL)
            AND    parent_category = i.parent_category
            ORDER  BY per_cnt DESC)
      WHERE rownum < 6;


      -- INSERT 'Total' row for ORGANIZATION and PERSON by state

      INSERT INTO imc_reports_tempinfo(report_name,
			               report_type,
				       parent_category,
			               category,
			               org_cnt,
			               org_pct,
				       per_cnt,
				       per_pct,
			               time_stamp)
      SELECT 'STATE','R', i.parent_category, rp_msg_total,
   	      nvl(i.org_total,0),'100.00',nvl(i.per_total,0),'100.00',sysdate
      FROM    dual;


      -- INSERT 'All Others' row for ORGANIZATION and PERSON by state

      IF i.org_total > 0 AND i.per_total > 0 THEN

         INSERT INTO imc_reports_tempinfo(report_name,
			                  report_type,
			                  parent_category,
			                  category,
				          org_cnt,
				          org_pct,
				          per_cnt,
				          per_pct,
			                  time_stamp)
         SELECT 'STATE','G',i.parent_category,rp_msg_all_others,
                (i.org_total - sum(imc_tmp.org_cnt)),
                round(((i.org_total - sum(imc_tmp.org_cnt))/i.org_total) * 100,2),
                (i.per_total - sum(imc_tmp.per_cnt)),
                round(((i.per_total - sum(imc_tmp.per_cnt))/i.per_total) * 100,2),
                sysdate
         FROM   imc_reports_tempinfo imc_tmp
         WHERE  imc_tmp.report_name = 'STATE'
         AND    imc_tmp.report_type = 'G'
         AND    imc_tmp.parent_category = i.parent_category;

      ELSIF i.org_total = 0 AND i.per_total > 0 THEN

         INSERT INTO imc_reports_tempinfo(report_name,
			                  report_type,
			                  parent_category,
			                  category,
				          org_cnt,
				          org_pct,
				          per_cnt,
				          per_pct,
			                  time_stamp)
         SELECT 'STATE','G',i.parent_category,rp_msg_all_others, 0, 0,
                (i.per_total - sum(imc_tmp.per_cnt)),
                round(((i.per_total - sum(imc_tmp.per_cnt))/i.per_total) * 100,2),
                sysdate
         FROM   imc_reports_tempinfo imc_tmp
         WHERE  imc_tmp.report_name = 'STATE'
         AND    imc_tmp.report_type = 'G'
         AND    imc_tmp.parent_category = i.parent_category;

      ELSIF i.org_total > 0 AND i.per_total = 0 THEN

         INSERT INTO imc_reports_tempinfo(report_name,
			                  report_type,
			                  parent_category,
			                  category,
				          org_cnt,
				          org_pct,
				          per_cnt,
				          per_pct,
			                  time_stamp)
         SELECT 'STATE','G',i.parent_category,rp_msg_all_others,
                (i.org_total - sum(imc_tmp.org_cnt)),
                round(((i.org_total - sum(imc_tmp.org_cnt))/i.org_total) * 100,2),
		0, 0, sysdate
         FROM   imc_reports_tempinfo imc_tmp
         WHERE  imc_tmp.report_name = 'STATE'
         AND    imc_tmp.report_type = 'G'
         AND    imc_tmp.parent_category = i.parent_category;

      END IF;

   END LOOP;

   COMMIT;

 EXCEPTION
    WHEN OTHERS THEN
         write_log('Error:' || sqlerrm);

 END load_state;


 -------- Loads data related to Duplicates chart and report --------
 --- Report Name : DUPLICATE               ---
 --- Party  Types: ORGANIZATION and PERSON ---
 --- Report Types: R and G                 ---

 PROCEDURE load_duplicates IS

 BEGIN

   g_proc_name := 'load_duplicates';

   -- INSERT all records for ORGANIZATION and PERSON by duplicate
/*
   -- fix bug 3296241 and 3296206
   INSERT INTO imc_reports_tempinfo(report_name,
				    report_type,
				    category,
				    parent_category,
				    org_cnt,
				    per_cnt,
				    time_stamp)
   SELECT 'DUPLICATE', 'R',
          decode(allcount.dn, 0, rp_msg_no_dupl,
	       1, allcount.dr || ' ' || rp_msg_dupl,
               allcount.dr || ' ' || rp_msg_dupls) category, allcount.dn,
         sum(decode(allcount.ptype,'ORGANIZATION',allcount.dc,0)) ocount
       , sum(decode(allcount.ptype,'PERSON',allcount.dc,0)) pcount
       , sysdate
   FROM
       (SELECT x.ptype, rng.rng_no dn, rng.dupl_rng dr, count(1) dc
        FROM (SELECT hp.customer_key || hl.address_key key_comb,
                     decode(hp.party_type,'ORGANIZATION',count(*),0) org_count,
                     decode(hp.party_type,'PERSON',count(*),0) per_count,
                     hp.party_type ptype
              FROM   hz_parties hp, hz_locations hl, hz_party_sites hs
              WHERE  hp.party_id = hs.party_id (+)
              AND    hp.party_type in ('ORGANIZATION','PERSON')
              AND    hp.status = 'A'
              AND    hs.identifying_address_flag (+) = 'Y'
              AND    hs.location_id = hl.location_id (+)
              GROUP  BY hp.customer_key || hl.address_key, hp.party_type) x,
              imc_dupl_range_v rng
        WHERE   ((x.org_count between rng.min and rng.max)
        OR      (x.per_count between rng.min and rng.max))
        GROUP   BY rng.dupl_rng, rng.rng_no, ptype
       ) allcount
   GROUP BY allcount.dn, allcount.dr;
*/
   -- perf bug fix 3638757
   INSERT INTO imc_reports_tempinfo(report_name,
                                    report_type,
                                    category,
                                    parent_category,
                                    org_cnt,
                                    per_cnt,
                                    time_stamp)
   SELECT /*+ parallel(v3) */ 'DUPLICATE', 'R'
          , decode(val,'0',rp_msg_no_dupl,'1',val||' '||rp_msg_dupl, val||' '||rp_msg_dupls) category
          , decode(val,'0','0','1','1','2','2','3','3','4-10','4','11-100','5','101-10000','6','10001-9999999999','7') dn
          , sum(decode(pt, 'ORGANIZATION', tpc, 0)) otpc
          , sum(decode(pt, 'PERSON', tpc, 0)) ptpc
          , sysdate
   FROM
   ( select /*+ parallel(v2) */
       val, pt, sum(occurence) occur, sum(totalptycount) tpc
     from
     ( select /*+ parallel(v1) */
            decode(least(col1,4),col1,to_char(col1-1)
          , decode(least(col1,11),col1 ,'4-10'
          , decode(least(col1,101),col1 ,'11-100'
          , decode(least(col1,10001),col1 ,'101-10000'
          , '10001-9999999999')))) val
          , pt, count(*) occurence, col1*count(*) totalptycount
       from
       ( select /*+ parallel(hp) parallel(hs) parallel(hl) use_hash(hs,hl) */
            count(*) col1, hp.party_type pt
         from hz_parties hp, hz_party_sites hs, hz_locations hl
         where hp.party_type in ('ORGANIZATION','PERSON')
         and hp.status = 'A'
         and hp.party_id = hs.party_id(+)
         and hs.identifying_address_flag(+) = 'Y'
         and hs.location_id = hl.location_id(+)
         group by hp.customer_key || hl.address_key, hp.party_type ) v1
       group by decode(least(col1,4),col1,to_char(col1-1),
                decode(least(col1,11),col1 ,'4-10',
                decode(least(col1,101),col1 ,'11-100',
                decode(least(col1,10001),col1 ,'101-10000',
                '10001-9999999999')))), pt, col1 ) v2
     group by val, pt
   ) v3
   GROUP BY val;

   SELECT nvl(sum(org_cnt),0), nvl(sum(per_cnt),0)
   INTO rp_dupl_org_cnt, rp_dupl_per_cnt
   FROM imc_reports_tempinfo
   WHERE report_name = 'DUPLICATE'
   AND report_type = 'R';

   -- INSERT the rest of the ranges from imc_dupl_rang_v that do not
   -- have any duplicate entries for either ORGANIZATION or PERSON party types

   INSERT INTO imc_reports_tempinfo(report_name,
				    report_type,
				    category,
				    parent_category,
				    org_cnt,
				    per_cnt,
				    time_stamp)
   SELECT 'DUPLICATE', 'R',
          decode(rng.rng_no, 0, rp_msg_no_dupl,
		             1, rng.dupl_rng || ' ' || rp_msg_dupl,
                                rng.dupl_rng || ' ' || rp_msg_dupls),
	  rng.rng_no, 0, 0, sysdate
   FROM   imc_dupl_range_v rng
   WHERE  NOT EXISTS (SELECT '1' FROM imc_reports_tempinfo tmp
		      WHERE  tmp.report_name = 'DUPLICATE'
		      AND    tmp.report_type = 'R'
		      AND    tmp.parent_category = rng.rng_no);


   -- UPDATE percentage for ORGANIZATION and PERSON by duplicate

   IF rp_dupl_org_cnt > 0 AND rp_dupl_per_cnt > 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     org_pct = round((org_cnt/rp_dupl_org_cnt)*100,2),
	      per_pct = round((per_cnt/rp_dupl_per_cnt)*100,2)
      WHERE   report_name = 'DUPLICATE'
      AND     report_type = 'R';

   ELSIF rp_dupl_org_cnt > 0 AND rp_dupl_per_cnt = 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     org_pct = round((org_cnt/rp_dupl_org_cnt)*100,2),
	      per_pct = 0
      WHERE   report_name = 'DUPLICATE'
      AND     report_type = 'R';

   ELSIF rp_dupl_org_cnt = 0 AND rp_dupl_per_cnt > 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     org_pct = 0,
	      per_pct = round((per_cnt/rp_dupl_per_cnt)*100,2)
      WHERE   report_name = 'DUPLICATE'
      AND     report_type = 'R';

   END IF;

   -- INSERT 'Total' row for ORGANIZATION and PERSON by duplicate

   INSERT INTO imc_reports_tempinfo(report_name,
			            report_type,
			            category,
			            org_cnt,
			            org_pct,
				    per_cnt,
				    per_pct,
			            time_stamp)
   SELECT 'DUPLICATE','R',rp_msg_total, nvl(rp_dupl_org_cnt,0),'100.00',
	   nvl(rp_dupl_per_cnt,0),'100.00',  sysdate
   FROM    dual;

   COMMIT;

 EXCEPTION
      WHEN OTHERS THEN
	   write_log('Error:' || sqlerrm);

 END load_duplicates;


 -------- Loads data related to Country chart and report --------
 --- Report Name : COUNTRY                 ---
 --- Party  Types: ORGANIZATION and PERSON ---
 --- Report Types: R and G                 ---

 PROCEDURE load_growth IS

   CURSOR get_pregrowth_months IS
   SELECT category, to_number(parent_category)
   FROM IMC_REPORTS_TEMPINFO
   WHERE report_name = 'PRE-GROWTH'
   AND report_type = 'R'
   ORDER BY parent_category;

   l_month_name         VARCHAR2(80);
   l_month_no           NUMBER;
   l_pregrowth_tbl      pregrowth_tbl_type;

 BEGIN

   g_proc_name := 'load_growth';

   -- INSERT all records ORGANIZATION,PERSON,PARTY_RELATIONSHIP,Total by growth

/* Fix perf bug 4915034 - don't join with imc_growth_time_v
   Query IMC_REPORTS_TEMPINFO to find out which month did not write into
   TEMPINFO table.

   INSERT INTO imc_reports_tempinfo(report_name,
			            report_type,
			            category,
				    parent_category,
			            org_cnt,
				    per_cnt,
				    rel_cnt,
				    total_cnt,
			            time_stamp)
   SELECT 'PRE-GROWTH', 'R', month, month_no,
           sum(org_count), sum(per_count),
           sum(rel_count), sum(tot_count), sysdate
   FROM   (SELECT decode(party_type,'ORGANIZATION',count(*),0) org_count,
                  decode(party_type,'PERSON',count(*),0) per_count,
                  decode(party_type,'PARTY_RELATIONSHIP',count(*),0) rel_count,
                  count(*) tot_count,
                  to_char(creation_date,'Mon-YY') month_name,
                  to_number (to_char(creation_date,'MM')) month_num
           FROM   hz_parties
           WHERE  creation_date >= add_months(sysdate,-23)
           GROUP  BY to_char(creation_date,'Mon-YY'),
                     to_number(to_char(creation_date,'MM')), party_type),
           imc_growth_time_v gro
   WHERE   gro.month = month_name (+)
   GROUP   BY month_no, month;
*/
   INSERT INTO imc_reports_tempinfo(report_name,
			            report_type,
			            category,
				    parent_category,
			            org_cnt,
				    per_cnt,
				    rel_cnt,
				    total_cnt,
			            time_stamp)
   SELECT 'PRE-GROWTH', 'R', month_name,
            decode(month_name,
            to_char(add_months(sysdate, -23), 'Mon-YY'), 1,
            to_char(add_months(sysdate, -22), 'Mon-YY'), 2,
            to_char(add_months(sysdate, -21), 'Mon-YY'), 3,
            to_char(add_months(sysdate, -20), 'Mon-YY'), 4,
            to_char(add_months(sysdate, -19), 'Mon-YY'), 5,
            to_char(add_months(sysdate, -18), 'Mon-YY'), 6,
            to_char(add_months(sysdate, -17), 'Mon-YY'), 7,
            to_char(add_months(sysdate, -16), 'Mon-YY'), 8,
            to_char(add_months(sysdate, -15), 'Mon-YY'), 9,
            to_char(add_months(sysdate, -14), 'Mon-YY'), 10,
            to_char(add_months(sysdate, -13), 'Mon-YY'), 11,
            to_char(add_months(sysdate, -12), 'Mon-YY'), 12,
            to_char(add_months(sysdate, -11), 'Mon-YY'), 13,
            to_char(add_months(sysdate, -10), 'Mon-YY'), 14,
            to_char(add_months(sysdate, -9), 'Mon-YY'), 15,
            to_char(add_months(sysdate, -8), 'Mon-YY'), 16,
            to_char(add_months(sysdate, -7), 'Mon-YY'), 17,
            to_char(add_months(sysdate, -6), 'Mon-YY'), 18,
            to_char(add_months(sysdate, -5), 'Mon-YY'), 19,
            to_char(add_months(sysdate, -4), 'Mon-YY'), 20,
            to_char(add_months(sysdate, -3), 'Mon-YY'), 21,
            to_char(add_months(sysdate, -2), 'Mon-YY'), 22,
            to_char(add_months(sysdate, -1), 'Mon-YY'), 23,
            to_char(sysdate, 'Mon-YY'), 24
           ) month_no,
           sum(org_count), sum(per_count),
           sum(rel_count), sum(tot_count), sysdate
   FROM   (SELECT decode(party_type,'ORGANIZATION',count(*),0) org_count,
                  decode(party_type,'PERSON',count(*),0) per_count,
                  decode(party_type,'PARTY_RELATIONSHIP',count(*),0) rel_count,
                  count(*) tot_count,
                  to_char(creation_date,'Mon-YY') month_name,
                  to_number (to_char(creation_date,'MM')) month_num
           FROM   hz_parties
           WHERE  creation_date >= add_months(sysdate,-23)
           GROUP  BY to_char(creation_date,'Mon-YY'),
                     to_number(to_char(creation_date,'MM')), party_type)
   GROUP BY month_name;

   -- create a table of month_name and month_nos
   FOR i IN 1..24 LOOP
     l_pregrowth_tbl(i).month_name := to_char(add_months(sysdate, i-24), 'Mon-YY');
     l_pregrowth_tbl(i).exist_flag := 'N';
   END LOOP;

   -- fetch all months and month_nos which have been created into IMC_REPORTS_TEMPINFO
   OPEN get_pregrowth_months;
   LOOP
     FETCH get_pregrowth_months INTO l_month_name, l_month_no;
     EXIT WHEN get_pregrowth_months%NOTFOUND;
     IF(l_pregrowth_tbl(l_month_no).month_name = l_month_name) THEN
       l_pregrowth_tbl(l_month_no).exist_flag := 'Y';
     END IF;
   END LOOP;
   CLOSE get_pregrowth_months;

   -- insert missing months
   FOR i IN 1..24 LOOP
     IF(l_pregrowth_tbl(i).exist_flag = 'N') THEN
       INSERT INTO imc_reports_tempinfo(report_name, report_type, category, parent_category,
                                        org_cnt, per_cnt, rel_cnt, total_cnt, time_stamp)
       VALUES ('PRE-GROWTH', 'R', l_pregrowth_tbl(i).month_name, i, null, null, null, null, sysdate);
     END IF;
   END LOOP;

   -- To get a cumulative count, doing a self join and inserting rows
   -- for GROWTH now, using the PRE-GROWTH rows

   INSERT INTO imc_reports_tempinfo(report_name,
			            report_type,
			            category,
				    parent_category,
			            org_cnt,
				    per_cnt,
				    rel_cnt,
				    total_cnt,
			            time_stamp)
    SELECT 'GROWTH', 'R', category, parent_category,
	    org_cnt, per_cnt, rel_cnt, total_cnt, sysdate
    FROM   (SELECT a.category,
                   to_number(a.parent_category) parent_category,
                   nvl(sum(d.org_cnt),0) org_cnt,
                   nvl(sum(d.per_cnt),0) per_cnt,
                   nvl(sum(d.rel_cnt),0) rel_cnt,
                   nvl(sum(d.total_cnt),0) total_cnt
            FROM   imc_reports_tempinfo a, imc_reports_tempinfo d
            WHERE  a.report_name = 'PRE-GROWTH'
            AND    d.report_name = 'PRE-GROWTH'
	    AND    to_number(d.parent_category) <=  to_number(a.parent_category)
	    AND    UPPER(d.parent_category) = LOWER(d.parent_category)
	    AND    UPPER(a.parent_category) = LOWER(a.parent_category)
            GROUP  BY a.parent_category,a.category
	    ORDER  BY to_number(a.parent_category)) ;

   -- Cumulative rows for Growth report loaded. We can knock off
   -- PRE-GROWTH records

   DELETE imc_reports_tempinfo
   WHERE  report_name = 'PRE-GROWTH';

   -- UPDATE percentage ORGANIZATION,PERSON,PARTY_RELATIONSHIP,Total by growth

   IF rp_grth_org_cnt > 0 AND rp_grth_per_cnt > 0 AND rp_grth_rel_cnt > 0 AND
      rp_grth_total_cnt > 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     org_pct     = round((org_cnt/rp_grth_org_cnt)*100,2),
              per_pct     = round((per_cnt/rp_grth_per_cnt)*100,2),
	      rel_pct     = round((rel_cnt/rp_grth_rel_cnt)*100,2),
	      total_pct   = round((total_cnt/rp_grth_total_cnt)*100,2)
      WHERE   report_name = 'GROWTH'
      AND     report_type = 'R';

   ELSIF rp_grth_org_cnt = 0 AND rp_grth_per_cnt > 0 AND rp_grth_rel_cnt > 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     org_pct     = 0,
              per_pct     = round((per_cnt/rp_grth_per_cnt)*100,2),
	      rel_pct     = round((rel_cnt/rp_grth_rel_cnt)*100,2),
	      total_pct   = round((total_cnt/rp_grth_total_cnt)*100,2)
      WHERE   report_name = 'GROWTH'
      AND     report_type = 'R';

   ELSIF rp_grth_org_cnt > 0 AND rp_grth_per_cnt = 0 AND rp_grth_rel_cnt > 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     org_pct     = round((org_cnt/rp_grth_org_cnt)*100,2),
	      per_pct     = 0,
	      rel_pct     = round((rel_cnt/rp_grth_rel_cnt)*100,2),
	      total_pct   = round((total_cnt/rp_grth_total_cnt)*100,2)
      WHERE   report_name = 'GROWTH'
      AND     report_type = 'R';

   ELSIF rp_grth_org_cnt > 0 AND rp_grth_per_cnt > 0 AND rp_grth_rel_cnt = 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     org_pct     = round((org_cnt/rp_grth_org_cnt)*100,2),
              per_pct     = round((per_cnt/rp_grth_per_cnt)*100,2),
	      rel_pct     = 0,
	      total_pct   = round((total_cnt/rp_grth_total_cnt)*100,2)
      WHERE   report_name = 'GROWTH'
      AND     report_type = 'R';

   ELSIF rp_grth_org_cnt = 0 AND rp_grth_per_cnt = 0 AND rp_grth_rel_cnt > 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     org_pct     = 0,
              per_pct     = 0,
	      rel_pct     = round((rel_cnt/rp_grth_rel_cnt)*100,2),
	      total_pct   = round((total_cnt/rp_grth_total_cnt)*100,2)
      WHERE   report_name = 'GROWTH'
      AND     report_type = 'R';

   ELSIF rp_grth_org_cnt > 0 AND rp_grth_per_cnt = 0 AND rp_grth_rel_cnt = 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     org_pct     = round((org_cnt/rp_grth_org_cnt)*100,2),
              per_pct     = 0,
	      rel_pct     = 0,
	      total_pct   = round((total_cnt/rp_grth_total_cnt)*100,2)
      WHERE   report_name = 'GROWTH'
      AND     report_type = 'R';

   ELSIF rp_grth_org_cnt = 0 AND rp_grth_per_cnt > 0 AND rp_grth_rel_cnt = 0 THEN

      UPDATE  imc_reports_tempinfo
      SET     org_pct     = 0,
              per_pct     = round((per_cnt/rp_grth_per_cnt)*100,2),
	      rel_pct     = 0,
	      total_pct   = round((total_cnt/rp_grth_total_cnt)*100,2)
      WHERE   report_name = 'GROWTH'
      AND     report_type = 'R';

   END IF;

   -- INSERT 'Total' row ORGANIZATION,PERSON,PARTY_RELATIONSHIP,Total by growth

   INSERT INTO imc_reports_tempinfo(report_name,
			             report_type,
			             category,
			             org_cnt,
			             org_pct,
				     per_cnt,
				     per_pct,
				     rel_cnt,
				     rel_pct,
				     total_cnt,
				     total_pct,
			             time_stamp)
   SELECT 'GROWTH','R',rp_msg_total,
	   nvl(rp_grth_org_cnt,0),'100.00',
	   nvl(rp_grth_per_cnt,0),'100.00',
	   nvl(rp_grth_rel_cnt,0),'100.00',
	   nvl(rp_grth_total_cnt,0),'100.00',
	   sysdate
   FROM    dual;

   COMMIT;

 EXCEPTION
    WHEN OTHERS THEN
         write_log('Error:' || sqlerrm);

 END load_growth;

 -- main PROCEDURE that calls the PROCEDUREs FOR each type of report/chart

 PROCEDURE extract_main IS

 BEGIN

  g_proc_name    := 'extract_main';

  get_counts;

  IF g_party_exists = 2 THEN

     load_country;
     load_growth;
     load_duplicates;
     load_state;
     load_industry;

  END IF;

  EXCEPTION
      WHEN OTHERS THEN
	   write_log('Error:' || sqlerrm);

  END extract_main;

FUNCTION get_party_count(
        p_party_type    IN VARCHAR2,
        p_date          IN DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN NUMBER;

FUNCTION get_enrich_party_count (
        p_party_type    IN VARCHAR2,
        p_date          IN DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN NUMBER;

FUNCTION get_party_clause(
        p_table_name    IN  VARCHAR2,
        p_party_type    IN  VARCHAR2,
        p_system_date   IN  DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_profile_clause(
        p_table_name    IN  VARCHAR2,
        p_party_type    IN  VARCHAR2,
        p_system_date   IN  DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_contactpoint_clause(
        p_table_name    IN  VARCHAR2,
        p_party_type    IN  VARCHAR2,
        p_attribute     IN  VARCHAR2,
        p_system_date   IN  DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_org_contact_clause(
        p_table_name    IN  VARCHAR2,
        p_party_type    IN  VARCHAR2,
        p_system_date   IN  DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_org_contact_role_clause(
        p_table_name    IN  VARCHAR2,
        p_party_type    IN  VARCHAR2,
        p_attribute     IN  VARCHAR2,
        p_system_date   IN  DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_code_assign_clause(
        p_table_name    IN  VARCHAR2,
        p_party_type    IN  VARCHAR2,
        p_attribute     IN  VARCHAR2,
        p_system_date   IN  DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2;

PROCEDURE get_compl_count(
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
) IS

  l_report_name       VARCHAR2(30);
  l_party_type        VARCHAR2(240);
  l_attribute         VARCHAR2(80);
  l_select_stmt       VARCHAR2(2000);
  l_attribute_count   NUMBER;
  l_attr_code         VARCHAR2(30);
  l_score             NUMBER;
  l_total_party       NUMBER;
  l_table_name        VARCHAR2(30);
  l_system_date       DATE;
  l_quarter_start     NUMBER;
  l_month_start       NUMBER;
  l_parent_cat        VARCHAR2(30);
  l_return_status     VARCHAR2(30);
  l_msg_data          VARCHAR2(2000);
  l_msg_count         NUMBER;
  l_dummy             VARCHAR2(1);
  l_month_exist       VARCHAR2(1);
  l_quarter_exist     VARCHAR2(1);
  l_daily_exist       VARCHAR2(1);
  l_attr_type         VARCHAR2(30);

  l_org_count         NUMBER;
  l_per_count         NUMBER;
  l_cnt_count         NUMBER;
  l_temp_type         VARCHAR2(30);
  l_temp_count        NUMBER;

  -- get all reports and type of reports (i.e. ORGNAIZATION, PERSON or CONTACT)
  cursor get_all_reports(l_system_date DATE) is
  SELECT rpt.lookup_code, substrb(rs.category,1,30)
  FROM imc_lookups rpt, imc_reports_summary rs
  WHERE rpt.lookup_type = 'COMPLETENESS_REPORTS'
  AND rpt.enabled_flag = 'Y'
  AND rpt.lookup_code = rs.parent_category
  AND rs.report_name = 'COMPLRPT_STATUS'
  AND rs.report_type = 'A';

  -- get all attributes and decode the description to table name and column name
  -- description like HZ_PARTIES.DUNS_NUMBER
  cursor get_all_attributes(l_report_name VARCHAR2, l_system_date DATE, l_type VARCHAR2) is
  SELECT substrb(t.description,instr(t.description,'.')+1), substrb(t.description,1,instr(t.description,'.')-1)
       , t.lookup_code
  FROM imc_lookups r, imc_lookups t, imc_lookups a
  WHERE r.lookup_type = l_report_name
  AND r.enabled_flag = 'Y'
  AND r.lookup_code = t.lookup_code
  and t.lookup_type = a.lookup_code
  and a.lookup_type = l_type
  AND l_system_date BETWEEN r.start_date_active AND nvl(r.end_date_active, l_system_date);

  -- get date and check if the date is start of month and quarter
  cursor get_system_month_day(l_system_date DATE) is
  SELECT decode(to_char(l_system_date,'DD'),'01',1,0),
         decode(to_char(l_system_date,'MM'),'01',1,'04',1,'07',1,'10',1,0),
         to_char(l_system_date, 'YYYY-MM')
  FROM dual;

  -- check if there is any completeness reports in IMC reports summary table
  cursor is_compl_record_exist is
  SELECT 'X'
  FROM IMC_REPORTS_SUMMARY a, IMC_LOOKUPS b
  WHERE a.report_name = b.lookup_code
  AND b.lookup_type = 'COMPLETENESS_REPORTS'
  AND a.report_type = 'M'
  AND rownum = 1;

  -- check if there exist any month record
  cursor is_month_record_exist(l_report_name VARCHAR2, l_date DATE) is
  SELECT 'X'
  FROM IMC_REPORTS_SUMMARY
  WHERE report_name = l_report_name
  AND report_type = 'M'
  AND parent_category = to_char(l_date,'YYYY-MM')
  AND rownum = 1;

  -- check if there exist any quarter record
  cursor is_quarter_record_exist(l_report_name VARCHAR2, l_date DATE) is
  SELECT 'X'
  FROM IMC_REPORTS_SUMMARY
  WHERE report_name = l_report_name
  AND report_type = 'Q'
  AND parent_category = to_char(l_date,'YYYY-')||'Q'||to_char(l_date,'Q')
  AND rownum = 1;

  -- check if there exist any daily record
  cursor is_daily_record_exist(l_report_name VARCHAR2, l_date DATE) is
  SELECT 'X'
  FROM IMC_REPORTS_SUMMARY
  WHERE report_name = l_report_name
  AND report_type = 'D'
  AND parent_category = to_char(l_date,'YYYY-MM')
  AND rownum = 1;

  -- get party count of organization
  cursor get_org_count is
  SELECT count(1)
  FROM HZ_PARTIES p, HZ_ORGANIZATION_PROFILES op
  WHERE p.status in ('A','I')
  AND p.party_type = 'ORGANIZATION'
  AND p.party_id = op.party_id
  AND sysdate between op.effective_start_date and nvl(op.effective_end_date, sysdate);

  -- get party count of person
  cursor get_per_count is
  SELECT count(1)
  FROM HZ_PARTIES p, HZ_PERSON_PROFILES pp
  WHERE p.status in ('A','I')
  AND p.party_type = 'PERSON'
  AND p.party_id = pp.party_id
  AND sysdate between pp.effective_start_date and nvl(pp.effective_end_date, sysdate);

  -- get contact count
  cursor get_cnt_count is
  SELECT count(1)
  FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r, HZ_PARTIES p
     , HZ_CODE_ASSIGNMENTS ca, HZ_RELATIONSHIP_TYPES rt
  WHERE oc.party_relationship_id = r.relationship_id
  AND r.subject_type = 'PERSON'
  AND r.subject_id = p.party_id
  AND ca.class_category = 'RELATIONSHIP_TYPE_GROUP'
  AND ca.owner_table_name = 'HZ_RELATIONSHIP_TYPES'
  AND ca.class_code = 'PARTY_REL_GRP_CONTACTS'
  AND rt.relationship_type_id = ca.owner_table_id
  AND rt.subject_type = 'PERSON'
  AND rt.forward_rel_code = r.relationship_code
  AND rt.relationship_type = r.relationship_type
  AND p.status in ('A','I');

BEGIN

  savepoint get_compl_count_pvt;
  FND_MSG_PUB.initialize;

  l_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_system_date := sysdate;

  write_log('Start collecting data for completeness report at: '||l_system_date);

  -- check if sysdate is first day of month and calendar quarter
  OPEN get_system_month_day(l_system_date);
  FETCH get_system_month_day INTO l_month_start, l_quarter_start, l_parent_cat;
  CLOSE get_system_month_day;

  -- check if this is the first run of completeness report
  OPEN is_compl_record_exist;
  FETCH is_compl_record_exist INTO l_dummy;
  CLOSE is_compl_record_exist;

  -- get count of organization
  OPEN get_org_count;
  FETCH get_org_count INTO l_org_count;
  CLOSE get_org_count;

  -- get count of person
  OPEN get_per_count;
  FETCH get_per_count INTO l_per_count;
  CLOSE get_per_count;

  -- get count of contact
  OPEN get_cnt_count;
  FETCH get_cnt_count INTO l_cnt_count;
  CLOSE get_cnt_count;

  -- getting all reports that is active
  OPEN get_all_reports(l_system_date);
  LOOP
    FETCH get_all_reports INTO l_report_name, l_party_type;
    EXIT WHEN get_all_reports%NOTFOUND;

    IF(l_party_type = 'ORGANIZATION') THEN
      l_attr_type := 'COMPL_ORG_ATTRIBUTES';
    ELSIF(l_party_type = 'PERSON') THEN
      l_attr_type := 'COMPL_PER_ATTRIBUTES';
    ELSIF(l_party_type = 'CONTACT') THEN
      l_attr_type := 'COMPL_CNT_ATTRIBUTES';
    END IF;

    -- check if current month data exist
    OPEN is_month_record_exist(l_report_name, l_system_date);
    FETCH is_month_record_exist INTO l_month_exist;
    CLOSE is_month_record_exist;

    -- check if current quarter data exist
    OPEN is_quarter_record_exist(l_report_name, l_system_date);
    FETCH is_quarter_record_exist INTO l_quarter_exist;
    CLOSE is_quarter_record_exist;

    -- get total number of active and inactive parties
    /* Fix bug 3638782
       count the number of party out of the loop */
    --l_total_party := get_party_count(l_party_type, l_system_date, l_return_status);
    IF(l_party_type = 'ORGANIZATION') THEN
      l_total_party := l_org_count;
    ELSIF(l_party_type = 'PERSON') THEN
      l_total_party := l_per_count;
    ELSIF(l_party_type = 'CONTACT') THEN
      l_total_party := l_cnt_count;
    END IF;
    l_attribute := NULL;
    l_attribute_count := 0;

    delete_daily_score(l_report_name, l_system_date, l_return_status, l_msg_count, l_msg_data);

    -- get all attributes of a report which are used to calculate completeness
    OPEN get_all_attributes(l_report_name, l_system_date, l_attr_type);
    LOOP
      FETCH get_all_attributes INTO l_attribute, l_table_name, l_attr_code;
      EXIT WHEN get_all_attributes%NOTFOUND;
      -- get completeness score for each attribute of sysdate
        insert_daily_score(l_report_name, l_total_party, l_party_type
                         , l_attribute, l_attr_code, l_table_name
                         , l_system_date, l_parent_cat
                         , l_return_status, l_msg_count, l_msg_data);
        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          l_attribute_count := l_attribute_count + 1;
        END IF;
    END LOOP;
    CLOSE get_all_attributes;

    -- check if at least one daily record successfully created for a report
    OPEN is_daily_record_exist(l_report_name, l_system_date);
    FETCH is_daily_record_exist INTO l_daily_exist;
    CLOSE is_daily_record_exist;
    IF(l_daily_exist IS NOT NULL) THEN

      -- for first day of a month or no "Month" record
      IF (l_dummy IS NULL) THEN
        insert_monthly_score(l_report_name, l_total_party, l_attribute_count, l_system_date
                           , l_return_status, l_msg_count, l_msg_data);
        insert_quarterly_score(l_report_name, l_total_party, l_attribute_count, l_system_date
                            , l_return_status, l_msg_count, l_msg_data);
      ELSE
        IF (l_month_exist IS NULL) THEN
          -- if current month data not exist
          insert_monthly_score(l_report_name, l_total_party, l_attribute_count, l_system_date
                             , l_return_status, l_msg_count, l_msg_data);
          IF (l_quarter_exist IS NULL) THEN
            insert_quarterly_score(l_report_name, l_total_party, l_attribute_count, l_system_date
                                 , l_return_status, l_msg_count, l_msg_data);
          ELSE
            update_quarterly_score(l_report_name, l_total_party, l_attribute_count, l_system_date
                                 , l_return_status, l_msg_count, l_msg_data);
          END IF;
        ELSE
          -- if current month and quarter data exist
          update_monthly_score(l_report_name, l_total_party, l_attribute_count, l_system_date
                             , l_return_status, l_msg_count, l_msg_data);
          update_quarterly_score(l_report_name, l_total_party, l_attribute_count, l_system_date
                               , l_return_status, l_msg_count, l_msg_data);
        END IF;
      END IF;

    ELSE
      write_log('No daily record exist for completeness report: '||l_report_name);
    END IF;
    l_month_exist := null;
    l_quarter_exist := null;
  END LOOP;
  CLOSE get_all_reports;

  write_log('Finish collecting data for completeness report');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_compl_count_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_compl_count_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO get_compl_count_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END get_compl_count;

PROCEDURE delete_daily_score (
  p_report_name      IN  VARCHAR2,
  p_system_date      IN  DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
) IS
  str             VARCHAR2(2000);
  l_return_status VARCHAR2(30);
BEGIN

  savepoint delete_daily_score_pvt;
  l_return_status :=  FND_API.G_RET_STS_SUCCESS;

  write_log('Start removing daily record for completeness report: '||p_report_name);

  -- remove day record
  str := 'delete from imc_reports_summary '||
         ' where report_name = '''||p_report_name||''''||
         ' and parent_category = to_char(:p_date,''YYYY-MM'')'||
         ' and report_type = ''D''';

  execute immediate str using p_system_date;

  x_return_status := l_return_status;

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK TO delete_daily_score_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END delete_daily_score;

PROCEDURE insert_daily_score (
  p_report_name      IN  VARCHAR2,
  p_total_party      IN  NUMBER,
  p_party_type       IN  VARCHAR2,
  p_attribute        IN  VARCHAR2,
  p_attr_code        IN  VARCHAR2,
  p_table_name       IN  VARCHAR2,
  p_system_date      IN  DATE,
  p_parent_cat       IN  VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
) IS
  table_prefix       VARCHAR2(10);
  str                VARCHAR2(2000);
  fromandwhere_str   VARCHAR2(4000);
  l_return_status    VARCHAR2(30);
  l_perf_hint        VARCHAR2(60); -- Perf Bug 6322629
BEGIN

  savepoint insert_daily_score_pvt;
  l_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_perf_hint := '';

  write_log('Start inserting daily score for completeness report: '||p_report_name);
  write_log('>> p_total_party:'||p_total_party||' p_party_type:'||p_party_type||' p_attribute: '||p_attribute);
  write_log('>> p_attr_code: '||p_attr_code||' p_table_name: '||p_table_name||' p_parent_cat: '||p_parent_cat);

  IF(p_table_name = 'HZ_PARTIES') THEN
      table_prefix := 'pty.';
      fromandwhere_str := get_party_clause(p_table_name, p_party_type, p_system_date, x_return_status);
      -- Perf Bug 6322629 (Add parallel hint for contact tables as volume of data is too high)
      IF (p_party_type = 'CONTACT') THEN
          l_perf_hint := ' /*+ PARALLEL(rt) PARALLEL(ca) PARALLEL(pty) PARALLEL(r) PARALLEL(oc) */ ';
      ELSE
          l_perf_hint := ' /*+ PARALLEL(pty) */ ';
      END IF;
    ELSIF((p_table_name = 'HZ_ORGANIZATION_PROFILES') OR (p_table_name = 'HZ_PERSON_PROFILES')) THEN
      table_prefix := 'prof.';
      fromandwhere_str := get_profile_clause(p_table_name, p_party_type, p_system_date, x_return_status);
      -- Perf Bug 6322629 (Add parallel hint for profile tables as volume of data is too high)
      l_perf_hint := ' /*+ PARALLEL(prof) PARALLEL(pty) */ ';
    ELSIF(p_table_name = 'HZ_CONTACT_POINTS') THEN
      table_prefix := 'contpt.';
      fromandwhere_str := get_contactpoint_clause(p_table_name, p_party_type, p_attribute, p_system_date, x_return_status);
      -- Perf Bug 6322629 (Add parallel hint for contact tables as volume of data is too high)
      IF (p_party_type = 'CONTACT') THEN
         l_perf_hint := ' /*+ PARALLEL(rt) PARALLEL(ca) PARALLEL(r) PARALLEL(oc) PARALLEL(contpt) PARALLEL(pty) */ ';
      ELSE
         l_perf_hint := ' /*+ PARALLEL(contpt) PARALLEL(pty) */ ';
      END IF;
    ELSIF(p_table_name = 'HZ_ORG_CONTACTS') THEN
      table_prefix := 'orgcnt.';
      fromandwhere_str := get_org_contact_clause(p_table_name, p_party_type, p_system_date, x_return_status);
      -- Perf Bug 6322629 (Add parallel hint for contact tables as volume of data is too high)
      l_perf_hint := ' /*+ PARALLEL(rt) PARALLEL(ca) PARALLEL(pty) PARALLEL(r) PARALLEL(orgcnt) */ ';
    ELSIF(p_table_name = 'HZ_ORG_CONTACT_ROLES') THEN
      table_prefix := 'ocrole.';
      fromandwhere_str := get_org_contact_role_clause(p_table_name, p_party_type, p_attribute, p_system_date, x_return_status);
    ELSIF(p_table_name = 'HZ_CODE_ASSIGNMENTS') THEN
      table_prefix := 'ca.';
      fromandwhere_str := get_code_assign_clause(p_table_name, p_party_type, p_attribute, p_system_date, x_return_status);
    END IF;

    -- add today record
    str := 'insert into imc_reports_summary('||
           ' report_name, report_type,'||
           ' category, parent_category,'||
           ' total_cnt, total_pct,'||
           ' time_stamp )'||
           ' select '||l_perf_hint||
           ''''||p_report_name||''''||','||
           '''D'''||','||
           ''''||p_attr_code||''''||','||
           ''''||p_parent_cat||''''||','||
           'nvl(sum(decode('||table_prefix||p_attribute||', NULL, 0, 1)),0),'||
           p_total_party ||','||
         ':p_date '||fromandwhere_str;

  write_log('>> sql string: '||str);

  IF((p_table_name = 'HZ_ORGANIZATION_PROFILES') OR (p_table_name = 'HZ_PERSON_PROFILES') OR (p_table_name = 'HZ_CODE_ASSIGNMENTS')) THEN
    execute immediate str using p_system_date, p_system_date, p_system_date;
  ELSE
    execute immediate str using p_system_date;
  END IF;

  x_return_status := l_return_status;

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK TO insert_daily_score_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     write_log('Error: '||sqlerrm);

END insert_daily_score;

PROCEDURE insert_monthly_score (
  p_report_name      IN VARCHAR2,
  p_total_party      IN NUMBER,
  p_total_attribute  IN NUMBER,
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
) IS

  l_return_status  VARCHAR2(30);

BEGIN

  savepoint insert_monthly_score_pvt;
  l_return_status :=  FND_API.G_RET_STS_SUCCESS;

  write_log('Start inserting monthly score for completeness report: '||p_report_name);
  write_log('>> p_total_party:'||p_total_party||' p_total_attribute: '||p_total_attribute);

  insert into IMC_REPORTS_SUMMARY (
      report_name,
      report_type,
      category,
      parent_category,
      org_cnt,
      total_cnt,
      total_pct,
      time_stamp
  ) select
      p_report_name,
      'M',
      NULL,
      to_char(p_system_date, 'YYYY-MM'),
      p_total_attribute,
      (sum(total_cnt)),
      (p_total_party*p_total_attribute),
--      (sum(total_cnt)/(p_total_attribute*p_total_party))*100,
--      p_total_party,
      p_system_date
      from IMC_REPORTS_SUMMARY
      where report_name = p_report_name
      and report_type = 'D'
      and parent_category = to_char(p_system_date,'YYYY-MM');

   x_return_status := l_return_status;

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK TO insert_monthly_score_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     write_log('Error: '||sqlerrm);

END insert_monthly_score;

PROCEDURE update_monthly_score (
  p_report_name      IN VARCHAR2,
  p_total_party      IN NUMBER,
  p_total_attribute  IN NUMBER,
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
) IS

  l_return_status  VARCHAR2(30);

BEGIN

  savepoint update_monthly_score_pvt;
  l_return_status :=  FND_API.G_RET_STS_SUCCESS;

  write_log('Start updating monthly score for completeness report: '||p_report_name);
  write_log('>> p_total_party:'||p_total_party||' p_total_attribute: '||p_total_attribute);

  update IMC_REPORTS_SUMMARY
  set total_cnt =
    (select (sum(total_cnt))
     from IMC_REPORTS_SUMMARY
     where report_name = p_report_name
     and parent_category = to_char(p_system_date,'YYYY-MM')
     and report_type = 'D'),
      total_pct = (p_total_party*p_total_attribute),
      org_cnt = p_total_attribute,
      time_stamp = p_system_date
  where report_name = p_report_name
  and report_type = 'M'
  and parent_category = to_char(p_system_date,'YYYY-MM');

  x_return_status := l_return_status;

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK TO update_monthly_score_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     write_log('Error: '||sqlerrm);

END update_monthly_score;

PROCEDURE insert_quarterly_score (
  p_report_name      IN VARCHAR2,
  p_total_party      IN NUMBER,
  p_total_attribute  IN NUMBER,
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
) IS

  l_return_status  VARCHAR2(30);

BEGIN

  savepoint insert_quarterly_score_pvt;
  l_return_status :=  FND_API.G_RET_STS_SUCCESS;

  write_log('Start inserting quarterly score for completeness report: '||p_report_name);
  write_log('>> p_total_party:'||p_total_party||' p_total_attribute: '||p_total_attribute);

  insert into IMC_REPORTS_SUMMARY (
      report_name,
      report_type,
      category,
      parent_category,
      org_cnt,
      total_cnt,
      total_pct,
      time_stamp
  ) select
      p_report_name,
      'Q',
      NULL,
      to_char(p_system_date, 'YYYY-')||'Q'||to_char(p_system_date,'Q'),
      org_cnt,
      total_cnt,
      total_pct,
      time_stamp
      from IMC_REPORTS_SUMMARY
      where report_name = p_report_name
      and report_type = 'M'
      and parent_category = to_char(p_system_date, 'YYYY-MM');

  x_return_status := l_return_status;

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK TO insert_quarterly_score_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     write_log('Error: '||sqlerrm);

END insert_quarterly_score;

PROCEDURE update_quarterly_score (
  p_report_name      IN VARCHAR2,
  p_total_party      IN NUMBER,
  p_total_attribute  IN NUMBER,
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
) IS

  l_return_status  VARCHAR2(30);

BEGIN

  savepoint update_quarterly_score_pvt;
  l_return_status :=  FND_API.G_RET_STS_SUCCESS;

  write_log('Start updating quarterly score for completeness report: '||p_report_name);
  write_log('>> p_total_party:'||p_total_party||' p_total_attribute: '||p_total_attribute);

  update IMC_REPORTS_SUMMARY
  set (total_cnt, total_pct, org_cnt, time_stamp) =
      (select total_cnt, total_pct, org_cnt, time_stamp
       from IMC_REPORTS_SUMMARY
       where report_name = p_report_name
       and report_type = 'M'
       and parent_category = to_char(p_system_date,'YYYY-MM'))
  where report_name = p_report_name
  and report_type = 'Q'
  and parent_category = to_char(p_system_date,'YYYY-')||'Q'||to_char(p_system_date,'Q');

  x_return_status := l_return_status;

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK TO update_quarterly_score_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     write_log('Error: '||sqlerrm);

END update_quarterly_score;

PROCEDURE get_enrich_count(
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
) IS

  CURSOR is_party_enrich_exist IS
  SELECT 'X'
  FROM IMC_REPORTS_SUMMARY
  WHERE report_name = 'PARTY_ENRICH'
  AND rownum = 1;

-- change here (Nishant)
/*
   Bug 5593223 : Added DNB Bulk Import statistics to
   DNB Online Purchase statistics for Enrichment Report
   26-Dec-2006 (Nishant Singhai)
*/
/*
  CURSOR min_max_year_month(l_system_date DATE) IS
  SELECT nvl(to_number(to_char(min(last_update_date), 'YYYY')),0) iy
       , nvl(to_number(to_char(min(last_update_date), 'MM')),0) im
       , to_number(to_char(l_system_date, 'YYYY')) xy
       , to_number(to_char(l_system_date, 'MM')) xm
  FROM HZ_PARTY_INTERFACE
  WHERE content_source_type = 'DNB'
  AND status = 'P2';
*/
--Bug9281743
--there are 2 rows fetched by internal query (2 table union) and if any of them is > 0,
--then regular insert code needs to be executed
--To implement this, Max of the min_year is fethed and if both MIN and MAX are = 0 then terminating the process.
  CURSOR min_max_year_month(l_system_date DATE) IS
	SELECT MIN(iy), MIN(im),
	       TO_NUMBER(to_char(l_system_date, 'YYYY')) xy,
	       TO_NUMBER(to_char(l_system_date, 'MM')) xm,
           MAX(iy)
	FROM (
	  SELECT nvl(to_number(to_char(min(last_update_date), 'YYYY')),0) iy
	       , nvl(to_number(to_char(min(last_update_date), 'MM')),0) im
	  FROM HZ_PARTY_INTERFACE
	  WHERE content_source_type = 'DNB'
	  AND status = 'P2'
	  UNION
	  SELECT nvl(to_number(to_char(min(last_update_date), 'YYYY')),0) iy
	       , nvl(to_number(to_char(min(last_update_date), 'MM')),0) im
	  FROM hz_imp_batch_summary
	  WHERE ORIGINAL_SYSTEM = 'DNB'
	  AND   IMPORT_STATUS <> 'PENDING'
	);

  CURSOR get_system_month_day(l_system_date DATE) IS
  SELECT decode(to_char(l_system_date,'DD'),'01',1,0),
         decode(to_char(l_system_date,'MM'),'01',1,'04',1,'07',1,'10',1,0)
  FROM dual;

  CURSOR get_all_period IS
  SELECT add_months(to_date(parent_category,'YYYY-MM'),1)-1
       , decode(substrb(parent_category,6,2),'03',1,'06',1,'09',1,'12',1,0)
       , decode(parent_category, to_char(sysdate,'YYYY-MM'), 1, 0)
  FROM IMC_REPORTS_SUMMARY
  WHERE report_name = 'PARTY_ENRICH'
  AND report_type = 'M';

  CURSOR is_month_record_exist(l_date DATE) IS
  SELECT 'X'
  FROM IMC_REPORTS_SUMMARY
  WHERE report_name = 'PARTY_ENRICH'
  AND report_type = 'M'
  AND parent_category = to_char(l_date,'YYYY-MM')
  AND rownum = 1;

  CURSOR is_quarter_record_exist(l_date DATE) IS
  SELECT 'X'
  FROM IMC_REPORTS_SUMMARY
  WHERE report_name = 'PARTY_ENRICH'
  AND report_type = 'Q'
  AND parent_category = to_char(l_date,'YYYY-')||'Q'||to_char(l_date,'Q')
  AND rownum = 1;

  l_dummy             VARCHAR2(1);
  l_min_year          NUMBER := 0;
  l_min_month         NUMBER := 0;
  l_max_year          NUMBER := 0;
  l_max_month         NUMBER := 0;
  l_system_date       DATE;
  l_quarter_start     NUMBER;
  l_month_start       NUMBER;
  l_parent_cat        VARCHAR2(30);
  l_return_status     VARCHAR2(30);
  l_msg_data          VARCHAR2(2000);
  l_msg_count         NUMBER;
  l_period_end        DATE;
  l_last_date         NUMBER;
  l_month_exist       VARCHAR2(1);
  l_quarter_exist     VARCHAR2(1);
  l_max_of_min_year   NUMBER := 0;
BEGIN

  savepoint get_enrich_count_pvt;

  l_system_date := sysdate;

  write_log('Start collecting data for enrichment report at: '||l_system_date);

  -- check if first time to run this program
  OPEN is_party_enrich_exist;
  FETCH is_party_enrich_exist INTO l_dummy;
  CLOSE is_party_enrich_exist;

  IF (l_dummy IS NULL) THEN
    -- first time running enrichment report

    write_log('Removing data for enrichment report');

    DELETE FROM IMC_REPORTS_SUMMARY
    WHERE REPORT_NAME = 'PARTY_ENRICH';

--Bug9281743
--Max of the min_year is fetched and if is also zero then only process will be terminated.
    OPEN min_max_year_month(l_system_date);
    FETCH min_max_year_month INTO l_min_year, l_min_month, l_max_year, l_max_month,l_max_of_min_year;
    CLOSE min_max_year_month;

--  Assigning Max of Min Year value to Min Year when Min Year is zero and Max of Min year is not zero.
    IF l_min_year = 0 AND l_max_of_min_year <> 0 THEN
         l_min_year := l_max_of_min_year;
    End if;

    IF (l_min_year = 0) AND (l_max_of_min_year = 0) THEN
      write_log('No enrichment data exist in party interface table');
    ELSE
      write_log('Adding month/year combination for enrichment report');

      FOR I IN l_min_year..l_max_year LOOP
        INSERT INTO IMC_REPORTS_SUMMARY (
          REPORT_NAME
         ,REPORT_TYPE
         ,CATEGORY
         ,PARENT_CATEGORY
         ,TIME_STAMP )
        SELECT
          'PARTY_ENRICH'
         ,'M'
         ,NULL
         ,to_char(I)||'-'||lookup_code
         ,sysdate
        FROM FND_LOOKUP_VALUES
        WHERE LOOKUP_TYPE = 'MONTH'
        AND ENABLED_FLAG = 'Y'
        GROUP BY lookup_code;
      END LOOP;

      write_log('Removing out of range month/year combination for enrichment report');

      -- remove rows that are out of min year-month and max year-month range
      DELETE IMC_REPORTS_SUMMARY
      WHERE report_name = 'PARTY_ENRICH'
      AND (parent_category < to_char(l_min_year)||'-'||lpad(to_char(l_min_month),2,'0')
      OR parent_category > to_char(l_max_year)||'-'||lpad(to_char(l_max_month),2,'0'));

      -- count the score of number of enriched data
      OPEN get_all_period;
      LOOP
        FETCH get_all_period INTO l_period_end, l_quarter_start, l_last_date;
        EXIT WHEN get_all_period%NOTFOUND;
        -- if l_period_end is same as l_system_date, then put l_system_date as l_period_end
        IF(l_last_date = 1) THEN
          update_menrich_score(l_system_date, l_return_status, l_msg_count, l_msg_data);
        ELSE
          update_menrich_score(l_period_end, l_return_status, l_msg_count, l_msg_data);
        END IF;
        IF(l_quarter_start = 1) THEN
          IF(l_last_date = 1) THEN
            insert_qenrich_score(l_system_date, l_return_status, l_msg_count, l_msg_data);
          ELSE
            insert_qenrich_score(l_period_end, l_return_status, l_msg_count, l_msg_data);
          END IF;
        ELSE
          IF((to_number(to_char(l_period_end,'YYYY')) = l_max_year) AND
             (to_number(to_char(l_period_end,'MM')) = l_max_month))  THEN
            IF(l_last_date = 1) THEN
              insert_qenrich_score(l_system_date, l_return_status, l_msg_count, l_msg_data);
            ELSE
              insert_qenrich_score(l_period_end, l_return_status, l_msg_count, l_msg_data);
            END IF;
          END IF;
        END IF;
      END LOOP;
      CLOSE get_all_period;
    END IF;

  ELSE
/*
    OPEN get_system_month_day(l_system_date);
    FETCH get_system_month_day INTO l_month_start, l_quarter_start;
    CLOSE get_system_month_day;
*/
    -- check if current month data exist
    OPEN is_month_record_exist(l_system_date);
    FETCH is_month_record_exist INTO l_month_exist;
    CLOSE is_month_record_exist;

    -- check if current quarter data exist
    OPEN is_quarter_record_exist(l_system_date);
    FETCH is_quarter_record_exist INTO l_quarter_exist;
    CLOSE is_quarter_record_exist;

    -- IF(l_month_start = 1) THEN
    IF (l_month_exist IS NULL) THEN
      insert_menrich_score(l_system_date, l_return_status, l_msg_count, l_msg_data);
      -- IF(l_quarter_start = 1) THEN
      IF (l_quarter_exist IS NULL) THEN
        insert_qenrich_score(l_system_date, l_return_status, l_msg_count, l_msg_data);
      ELSE
        update_qenrich_score(l_system_date, l_return_status, l_msg_count, l_msg_data);
      END IF;
    ELSE
      update_menrich_score(l_system_date, l_return_status, l_msg_count, l_msg_data);
      update_qenrich_score(l_system_date, l_return_status, l_msg_count, l_msg_data);
    END IF;

  END IF;

  write_log('Finish collecting data for enrichment report at: '||l_system_date);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_enrich_count_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_enrich_count_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO get_enrich_count_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     write_log('Error: '||sqlerrm);

END get_enrich_count;

PROCEDURE insert_menrich_score (
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
) IS

  l_return_status  VARCHAR2(30);
  l_party_count    NUMBER;
  l_enpty_count    NUMBER;

BEGIN

  savepoint insert_menrich_score_pvt;
  l_return_status :=  FND_API.G_RET_STS_SUCCESS;

  write_log('Start inserting monthly data for enrichment report: '||p_system_date);

  l_party_count := get_party_count('ORGANIZATION', p_system_date, l_return_status);
  l_enpty_count := get_enrich_party_count('ORGANIZATION', p_system_date, l_return_status);

  write_log('>> l_party_count: '||l_party_count);
  write_log('>> l_enpty_count: '||l_enpty_count);

-- change here (Nishant)
/*
   Bug 5593223 : Added DNB Bulk Import statistics to
   DNB Online Purchase statistics for Enrichment Report
   26-Dec-2006 (Nishant Singhai)
*/
/*
  INSERT INTO IMC_REPORTS_SUMMARY (
    report_name
   ,report_type
   ,category
   ,parent_category
   ,org_cnt
   ,total_cnt
   ,total_pct
   ,time_stamp
  ) SELECT
    'PARTY_ENRICH'
   ,'M'
   ,NULL
   ,to_char(p_system_date,'YYYY-MM')
   ,nvl(sum(decode(count(1),0,0,1)),0)
   ,l_enpty_count
   ,l_party_count
   ,p_system_date
  FROM HZ_PARTY_INTERFACE
  WHERE status = 'P2'
  AND to_char(last_update_date,'YYYY-MM') = to_char(p_system_date,'YYYY-MM')
  GROUP BY party_id;
*/
  INSERT INTO IMC_REPORTS_SUMMARY (
    report_name
   ,report_type
   ,category
   ,parent_category
   ,org_cnt
   ,total_cnt
   ,total_pct
   ,time_stamp
  ) SELECT
      'PARTY_ENRICH'
     ,'M'
     ,NULL
     ,to_char(p_system_date,'YYYY-MM')
     ,SUM(org_enriched_for_period)
     ,l_enpty_count
     ,l_party_count
     ,p_system_date
   FROM (
     SELECT nvl(sum(decode(count(1),0,0,1)),0) org_enriched_for_period
     FROM   HZ_PARTY_INTERFACE
     WHERE  status = 'P2'
     AND   content_source_type = 'DNB'
     AND   TO_CHAR(last_update_date,'YYYY-MM')= TO_CHAR(p_system_date,'YYYY-MM')
     GROUP BY party_id
     UNION ALL
	 SELECT nvl(SUM(parties_imported),0) org_enriched_for_period
     FROM   hz_imp_batch_summary
     WHERE  ORIGINAL_SYSTEM = 'DNB'
     AND    IMPORT_STATUS <> 'PENDING'
     AND   TO_CHAR(last_update_date,'YYYY-MM')= TO_CHAR(p_system_date,'YYYY-MM')
     ) ;

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK TO insert_menrich_score_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     write_log('Error: '||sqlerrm);

END insert_menrich_score;

PROCEDURE update_menrich_score (
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
) IS

  l_return_status  VARCHAR2(30);
  l_party_count    NUMBER;
  l_enpty_count    NUMBER;

BEGIN

  savepoint update_menrich_score_pvt;
  l_return_status :=  FND_API.G_RET_STS_SUCCESS;

  write_log('Start updating monthly data for enrichment report: '||p_system_date);

  l_party_count := get_party_count('ORGANIZATION', p_system_date, l_return_status);
  l_enpty_count := get_enrich_party_count('ORGANIZATION', p_system_date, l_return_status);

  write_log('>> l_party_count: '||l_party_count);
  write_log('>> l_enpty_count: '||l_enpty_count);

-- change here (Nishant)
/*
   Bug 5593223 : Added DNB Bulk Import statistics to
   DNB Online Purchase statistics for Enrichment Report
   26-Dec-2006 (Nishant Singhai)
*/
 /*
  UPDATE IMC_REPORTS_SUMMARY
  SET (org_cnt, total_cnt,total_pct, time_stamp) =
      (SELECT nvl(sum(decode(count(1),0,0,1)),0), l_enpty_count, l_party_count, p_system_date
       FROM HZ_PARTY_INTERFACE
       WHERE status = 'P2'
       AND to_char(last_update_date,'YYYY-MM') = to_char(p_system_date,'YYYY-MM')
       GROUP BY party_id)
  WHERE report_name = 'PARTY_ENRICH'
  AND report_type = 'M'
  AND parent_category = to_char(p_system_date,'YYYY-MM');
 */

  UPDATE IMC_REPORTS_SUMMARY
  SET (org_cnt, total_cnt,total_pct, time_stamp) =
      (SELECT SUM(org_enriched_for_period), l_enpty_count, l_party_count, p_system_date
       FROM (
             SELECT nvl(sum(decode(count(1),0,0,1)),0) org_enriched_for_period
             FROM   HZ_PARTY_INTERFACE
             WHERE  status = 'P2'
             AND    content_source_type = 'DNB'
             AND    TO_CHAR(last_update_date,'YYYY-MM')= TO_CHAR(p_system_date,'YYYY-MM')
             GROUP BY party_id
             UNION ALL
        	 SELECT nvl(SUM(parties_imported),0) org_enriched_for_period
             FROM   hz_imp_batch_summary
             WHERE  ORIGINAL_SYSTEM = 'DNB'
             AND    IMPORT_STATUS <> 'PENDING'
             AND   TO_CHAR(last_update_date,'YYYY-MM')= TO_CHAR(p_system_date,'YYYY-MM')
            )
        )
  WHERE report_name = 'PARTY_ENRICH'
  AND report_type = 'M'
  AND parent_category = to_char(p_system_date,'YYYY-MM');

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK TO update_menrich_score_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     write_log('Error: '||sqlerrm);

END update_menrich_score;

PROCEDURE insert_qenrich_score (
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
) IS

  l_return_status  VARCHAR2(30);
  l_party_count    NUMBER;
  l_enpty_count    NUMBER;

BEGIN

  savepoint insert_qenrich_score_pvt;
  l_return_status :=  FND_API.G_RET_STS_SUCCESS;

  write_log('Start inserting quarterly data for enrichment report: '||p_system_date);

  l_party_count := get_party_count('ORGANIZATION', p_system_date, l_return_status);
  l_enpty_count := get_enrich_party_count('ORGANIZATION', p_system_date, l_return_status);

  write_log('>> l_party_count: '||l_party_count);
  write_log('>> l_enpty_count: '||l_enpty_count);

-- change here (Nishant)
/*
   Bug 5593223 : Added DNB Bulk Import statistics to
   DNB Online Purchase statistics for Enrichment Report
   26-Dec-2006 (Nishant Singhai)
*/
/*
  INSERT INTO IMC_REPORTS_SUMMARY (
    report_name
   ,report_type
   ,category
   ,parent_category
   ,org_cnt
   ,total_cnt
   ,total_pct
   ,time_stamp
  ) SELECT
    'PARTY_ENRICH'
   ,'Q'
   ,NULL
   ,to_char(p_system_date,'YYYY-')||'Q'||to_char(p_system_date,'Q')
   ,nvl(sum(decode(count(1),0,0,1)),0)
   ,l_enpty_count
   ,l_party_count
   ,p_system_date
  FROM HZ_PARTY_INTERFACE
  WHERE status = 'P2'
  AND to_char(last_update_date,'YYYY-Q') = to_char(p_system_date,'YYYY-Q')
  GROUP BY party_id;
*/
  INSERT INTO IMC_REPORTS_SUMMARY (
    report_name
   ,report_type
   ,category
   ,parent_category
   ,org_cnt
   ,total_cnt
   ,total_pct
   ,time_stamp
  ) SELECT
      'PARTY_ENRICH'
     ,'Q'
     ,NULL
     ,to_char(p_system_date,'YYYY-')||'Q'||to_char(p_system_date,'Q')
     ,SUM(org_enriched_for_period)
     ,l_enpty_count
     ,l_party_count
     ,p_system_date
    FROM (
     SELECT nvl(SUM(decode(count(1),0,0,1)),0) org_enriched_for_period
     FROM HZ_PARTY_INTERFACE
     WHERE status = 'P2'
     AND  content_source_type = 'DNB'
     AND to_char(last_update_date,'YYYY-Q') = to_char(p_system_date,'YYYY-Q')
     GROUP BY party_id
     UNION ALL
     SELECT nvl(SUM(parties_imported),0) org_enriched_for_period
     FROM   hz_imp_batch_summary
     WHERE  ORIGINAL_SYSTEM = 'DNB'
     AND    IMPORT_STATUS <> 'PENDING'
     AND   TO_CHAR(last_update_date,'YYYY-Q')= TO_CHAR(p_system_date,'YYYY-Q')
    );

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK TO insert_qenrich_score_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     write_log('Error: '||sqlerrm);

END insert_qenrich_score;

PROCEDURE update_qenrich_score (
  p_system_date      IN DATE,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
) IS

  l_return_status  VARCHAR2(30);
  l_party_count    NUMBER;
  l_enpty_count    NUMBER;

BEGIN

  savepoint update_qenrich_score_pvt;
  l_return_status :=  FND_API.G_RET_STS_SUCCESS;

  write_log('Start updating quarterly data for enrichment report: '||p_system_date);

  l_party_count := get_party_count('ORGANIZATION', p_system_date, l_return_status);
  l_enpty_count := get_enrich_party_count('ORGANIZATION', p_system_date, l_return_status);

  write_log('>> l_party_count: '||l_party_count);
  write_log('>> l_enpty_count: '||l_enpty_count);

-- change here (Nishant)
/*
   Bug 5593223 : Added DNB Bulk Import statistics to
   DNB Online Purchase statistics for Enrichment Report
   26-Dec-2006 (Nishant Singhai)
*/
/*
  UPDATE IMC_REPORTS_SUMMARY
  SET (org_cnt, total_cnt,total_pct, time_stamp) =
      (SELECT nvl(sum(decode(count(1),0,0,1)),0), l_enpty_count, l_party_count, p_system_date
       FROM HZ_PARTY_INTERFACE
       WHERE status = 'P2'
       AND to_char(last_update_date,'YYYY-Q') = to_char(p_system_date,'YYYY-Q')
       GROUP BY party_id)
  WHERE report_name = 'PARTY_ENRICH'
  AND report_type = 'Q'
  AND parent_category = to_char(p_system_date,'YYYY-')||'Q'||to_char(p_system_date,'Q');
*/
  UPDATE IMC_REPORTS_SUMMARY
  SET (org_cnt, total_cnt,total_pct, time_stamp) =
      (SELECT SUM(org_enriched_for_period), l_enpty_count, l_party_count, p_system_date
       FROM (
             SELECT nvl(sum(decode(count(1),0,0,1)),0) org_enriched_for_period
             FROM   HZ_PARTY_INTERFACE
             WHERE  status = 'P2'
             AND    content_source_type = 'DNB'
             AND    TO_CHAR(last_update_date,'YYYY-Q')= TO_CHAR(p_system_date,'YYYY-Q')
             GROUP BY party_id
             UNION ALL
        	 SELECT nvl(SUM(parties_imported),0) org_enriched_for_period
             FROM   hz_imp_batch_summary
             WHERE  ORIGINAL_SYSTEM = 'DNB'
             AND    IMPORT_STATUS <> 'PENDING'
             AND   TO_CHAR(last_update_date,'YYYY-Q')= TO_CHAR(p_system_date,'YYYY-Q')
            )
        )
  WHERE report_name = 'PARTY_ENRICH'
  AND report_type = 'Q'
  AND parent_category = to_char(p_system_date,'YYYY-')||'Q'||to_char(p_system_date,'Q');

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK TO update_qenrich_score_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
     write_log('Error: '||sqlerrm);

END update_qenrich_score;

-- get total number of parties
FUNCTION get_party_count(
  p_party_type    IN VARCHAR2,
  p_date          IN DATE,
  x_return_status IN OUT NOCOPY  VARCHAR2
) RETURN NUMBER IS

  -- count ORGANIZATION or PERSON parties
  cursor get_pty_count(l_party_type VARCHAR2, l_date DATE) is
  SELECT count(1)
  FROM HZ_PARTIES
  WHERE status in ('A','I')
  AND party_type = l_party_type
  AND trunc(creation_date) <= trunc(l_date);

  -- count CONTACT
  cursor get_contact_count(l_date DATE) is
  SELECT count(1)
  FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r, HZ_PARTIES p
     , HZ_CODE_ASSIGNMENTS ca, HZ_RELATIONSHIP_TYPES rt
  WHERE oc.party_relationship_id = r.relationship_id
  AND r.subject_type = 'PERSON'
  AND r.subject_id = p.party_id
  AND ca.class_category = 'RELATIONSHIP_TYPE_GROUP'
  AND ca.owner_table_name = 'HZ_RELATIONSHIP_TYPES'
  AND ca.class_code = 'PARTY_REL_GRP_CONTACTS'
  AND rt.relationship_type_id = ca.owner_table_id
  AND rt.subject_type = 'PERSON'
  AND rt.forward_rel_code = r.relationship_code
  AND rt.relationship_type = r.relationship_type
  AND p.status in ('A','I')
  AND trunc(p.creation_date) <= trunc(l_date);

  l_party_count NUMBER;

BEGIN

  IF(p_party_type = 'CONTACT') THEN
    OPEN get_contact_count(p_date);
    FETCH get_contact_count INTO l_party_count;
    CLOSE get_contact_count;
  ELSE
    OPEN get_pty_count(p_party_type, p_date);
    FETCH get_pty_count INTO l_party_count;
    CLOSE get_pty_count;
  END IF;

  RETURN l_party_count;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN NULL;
END get_party_count;

FUNCTION get_enrich_party_count (
  p_party_type    IN VARCHAR2,
  p_date          IN DATE,
  x_return_status IN OUT NOCOPY  VARCHAR2
) RETURN NUMBER IS

-- change here (Nishant)
/*
   Bug 5593223 : Added DNB Bulk Import statistics to
   DNB Online Purchase statistics for Enrichment Report
   26-Dec-2006 (Nishant Singhai)
*/
/*
  cursor get_enpty_count(l_party_type VARCHAR2, l_date DATE) is
  SELECT nvl(sum(decode(count(1),0,0,1)),0)
  FROM HZ_PARTY_INTERFACE
  WHERE status = 'P2'
  AND content_source_type = 'DNB'
  AND trunc(last_update_date) <= trunc(l_date)
  GROUP BY party_id;
*/

  cursor get_enpty_count(l_party_type VARCHAR2, l_date DATE) is
  SELECT SUM(total_org_enriched) FROM (
      SELECT  nvl(sum(decode(count(1),0,0,1)),0) total_org_enriched
      FROM HZ_PARTY_INTERFACE
      WHERE status = 'P2'
      AND content_source_type = 'DNB'
      AND TRUNC(last_update_date) <= TRUNC(l_date)
      GROUP BY party_id
      UNION ALL
      SELECT nvl(SUM(parties_imported),0) total_org_enriched
      FROM   hz_imp_batch_summary
      WHERE  ORIGINAL_SYSTEM = 'DNB'
      AND    IMPORT_STATUS <> 'PENDING'
      AND   TRUNC(last_update_date) <= TRUNC(l_date)
      );

  l_enpty_count NUMBER;

BEGIN

  OPEN get_enpty_count(p_party_type, p_date);
  FETCH get_enpty_count INTO l_enpty_count;
  CLOSE get_enpty_count;

  RETURN l_enpty_count;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN NULL;
END get_enrich_party_count;

FUNCTION get_party_clause(
        p_table_name    IN  VARCHAR2,
        p_party_type    IN  VARCHAR2,
        p_system_date   IN  DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

  str VARCHAR2(4000);

BEGIN

  IF(p_party_type = 'CONTACT') THEN
    str := ' from HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r, HZ_PARTIES pty'||
           '    , HZ_CODE_ASSIGNMENTS ca, HZ_RELATIONSHIP_TYPES rt'||
           ' where pty.status in (''A'',''I'')'||
           ' and oc.party_relationship_id = r.relationship_id' ||
           ' and r.subject_type = ''PERSON'''||
           ' and r.party_id = pty.party_id'||
           ' and ca.class_category = ''RELATIONSHIP_TYPE_GROUP'''||
           ' and ca.owner_table_name = ''HZ_RELATIONSHIP_TYPES'''||
           ' and ca.class_code = ''PARTY_REL_GRP_CONTACTS'''||
           ' and rt.relationship_type_id = ca.owner_table_id'||
           ' and rt.subject_type = ''PERSON'''||
           ' and rt.forward_rel_code = r.relationship_code'||
           ' and rt.relationship_type = r.relationship_type';
  ELSE
    str := ' from HZ_PARTIES pty'||
           ' where pty.status in (''A'',''I'')'||
           ' and pty.party_type = '''||p_party_type||'''';
  END IF;

  RETURN str;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN NULL;
END get_party_clause;

FUNCTION get_code_assign_clause(
        p_table_name    IN VARCHAR2,
        p_party_type    IN VARCHAR2,
        p_attribute     IN VARCHAR2,
        p_system_date   IN DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

  str VARCHAR2(4000);

BEGIN

  -- code assignment is only for organization report
  str := ' from (select owner_table_id '||p_attribute||
         ' from HZ_CODE_ASSIGNMENTS c'||
         ' where owner_table_name = ''HZ_PARTIES'''||
         ' and status = ''A'''||
         ' and :p_date between c.start_date_active and nvl(c.end_date_active,:p_date)'||
         ' group by owner_table_id) ca';

  RETURN str;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN NULL;
END get_code_assign_clause;

FUNCTION get_profile_clause(
        p_table_name    IN  VARCHAR2,
        p_party_type    IN  VARCHAR2,
        p_system_date   IN  DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

  str VARCHAR2(4000);

BEGIN

  -- contact reports should NOT have profile checking
  -- the following if may not be valid now
  IF(p_party_type = 'CONTACT') THEN
    NULL;
  ELSE
    str := ' from HZ_PARTIES pty, '||p_table_name||' prof'||
           ' where pty.status in (''A'',''I'')'||
           ' and pty.party_type = '''||p_party_type||''''||
           ' and pty.party_id = prof.party_id'||
           ' and :p_date between prof.effective_start_date and nvl(prof.effective_end_date,:p_date)';
  END IF;

  RETURN str;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN NULL;
END get_profile_clause;

FUNCTION get_contactpoint_clause(
        p_table_name    IN  VARCHAR2,
        p_party_type    IN  VARCHAR2,
        p_attribute     IN  VARCHAR2,
        p_system_date   IN  DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

  str VARCHAR2(4000);
  l_contact_point_type VARCHAR2(30);

BEGIN

  IF(p_attribute = 'URL') THEN
    l_contact_point_type := 'WEB';
  ELSIF(p_attribute = 'EMAIL_ADDRESS') THEN
    l_contact_point_type := 'EMAIL';
  ELSE
    l_contact_point_type := 'PHONE';
  END IF;

  -- if the reports is used for contact, then we need to use HZ_RELATIONSHIPS
  -- and HZ_ORG_CONTACTS table to find out that person

  IF(p_party_type = 'CONTACT') THEN
    str := ' from HZ_PARTIES pty, HZ_CONTACT_POINTS contpt,'||
           ' HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r,'||
           ' HZ_CODE_ASSIGNMENTS ca, HZ_RELATIONSHIP_TYPES rt'||
           ' where pty.status in (''A'',''I'')'||
           ' and oc.party_relationship_id = r.relationship_id' ||
           ' and r.subject_type = ''PERSON'''||
           ' and r.party_id = pty.party_id'||
           ' and ca.class_category = ''RELATIONSHIP_TYPE_GROUP'''||
           ' and ca.owner_table_name = ''HZ_RELATIONSHIP_TYPES'''||
           ' and ca.class_code = ''PARTY_REL_GRP_CONTACTS'''||
           ' and rt.relationship_type_id = ca.owner_table_id'||
           ' and rt.subject_type = ''PERSON'''||
           ' and rt.forward_rel_code = r.relationship_code'||
           ' and rt.relationship_type = r.relationship_type'||
           ' and pty.party_id = contpt.owner_table_id'||
           ' and contpt.owner_table_name = ''HZ_PARTIES'''||
           ' and contpt.status in (''A'',''I'')'||
           ' and contpt.contact_point_type = '''||l_contact_point_type||''''||
           ' and contpt.primary_flag = ''Y''';
  ELSE
    str := ' from HZ_PARTIES pty, HZ_CONTACT_POINTS contpt'||
           ' where pty.status in (''A'',''I'')'||
           ' and pty.party_type = '''||p_party_type||''''||
           ' and pty.party_id = contpt.owner_table_id'||
           ' and contpt.owner_table_name = ''HZ_PARTIES'''||
           ' and contpt.status in (''A'',''I'')'||
           ' and contpt.contact_point_type = '''||l_contact_point_type||''''||
           ' and contpt.primary_flag = ''Y''';
  END IF;

  RETURN str;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN NULL;
END get_contactpoint_clause;

FUNCTION get_org_contact_clause(
        p_table_name    IN  VARCHAR2,
        p_party_type    IN  VARCHAR2,
        p_system_date   IN  DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

  str VARCHAR2(4000);

BEGIN

  -- org_contact is only used for contact report
  str := ' from HZ_ORG_CONTACTS orgcnt, HZ_RELATIONSHIPS r, HZ_PARTIES pty'||
         '    , HZ_CODE_ASSIGNMENTS ca, HZ_RELATIONSHIP_TYPES rt'||
         ' where pty.status in (''A'',''I'')'||
         ' and orgcnt.party_relationship_id = r.relationship_id' ||
         ' and r.subject_type = ''PERSON'''||
         ' and r.party_id = pty.party_id'||
         ' and ca.class_category = ''RELATIONSHIP_TYPE_GROUP'''||
         ' and ca.owner_table_name = ''HZ_RELATIONSHIP_TYPES'''||
         ' and ca.class_code = ''PARTY_REL_GRP_CONTACTS'''||
         ' and rt.relationship_type_id = ca.owner_table_id'||
         ' and rt.subject_type = ''PERSON'''||
         ' and rt.forward_rel_code = r.relationship_code'||
         ' and rt.relationship_type = r.relationship_type';

  RETURN str;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN NULL;
END get_org_contact_clause;

FUNCTION get_org_contact_role_clause(
        p_table_name    IN  VARCHAR2,
        p_party_type    IN  VARCHAR2,
        p_attribute     IN  VARCHAR2,
        p_system_date   IN  DATE,
        x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

  str VARCHAR2(4000);

BEGIN

  str := ' from (select r.party_id '||p_attribute||
         ' from HZ_ORG_CONTACTS orgcnt, HZ_RELATIONSHIPS r, HZ_PARTIES pty'||
         '    , HZ_CODE_ASSIGNMENTS ca, HZ_RELATIONSHIP_TYPES rt'||
         ' where pty.status in (''A'',''I'')'||
         ' and orgcnt.party_relationship_id = r.relationship_id' ||
         ' and r.subject_type = ''PERSON'''||
         ' and r.party_id = pty.party_id'||
         ' and ca.class_category = ''RELATIONSHIP_TYPE_GROUP'''||
         ' and ca.owner_table_name = ''HZ_RELATIONSHIP_TYPES'''||
         ' and ca.class_code = ''PARTY_REL_GRP_CONTACTS'''||
         ' and rt.relationship_type_id = ca.owner_table_id'||
         ' and rt.subject_type = ''PERSON'''||
         ' and rt.forward_rel_code = r.relationship_code'||
         ' and rt.relationship_type = r.relationship_type'||
         ' and exists (select 1 from HZ_ORG_CONTACT_ROLES ocr'||
         ' where ocr.status = ''A'''||
         ' and ocr.org_contact_id = orgcnt.org_contact_id)) ocrole';

  RETURN str;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN NULL;
END get_org_contact_role_clause;

 -- main PROCEDURE that collect data for quality reports

PROCEDURE extract_quality IS

  l_return_status VARCHAR2(30);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);

BEGIN

  g_proc_name    := 'extract_quality';

  get_compl_count(l_return_status, l_msg_count, l_msg_data);
  get_enrich_count(l_return_status, l_msg_count, l_msg_data);

EXCEPTION
  WHEN OTHERS THEN
    write_log('Error:' || sqlerrm);

END extract_quality;

PROCEDURE archive_compl_report (
  p_report_code        IN         VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2
) IS

  CURSOR get_meaning IS
  SELECT meaning, description, start_date_active
  FROM IMC_LOOKUPS
  WHERE lookup_type = 'COMPLETENESS_REPORTS'
  AND lookup_code = p_report_code;

  l_mean          VARCHAR2(80);
  l_desc          VARCHAR2(240);
  l_start_date    DATE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN get_meaning;
  FETCh get_meaning INTO l_mean, l_desc, l_start_date;
  CLOSE get_meaning;

  FND_LOOKUP_VALUES_PKG.update_row(
    x_lookup_type => 'COMPLETENESS_REPORTS',
    x_security_group_id => NULL,
    x_view_application_id => 879,
    x_lookup_code => p_report_code,
    x_tag => NULL,
    x_attribute_category => NULL,
    x_attribute1 => NULL,
    x_attribute2 => NULL,
    x_attribute3 => NULL,
    x_attribute4 => NULL,
    x_enabled_flag => 'Y',
    x_start_date_active => l_start_date,
    x_end_date_active => sysdate,
    x_territory_code => NULL,
    x_attribute5 => NULL,
    x_attribute6 => NULL,
    x_attribute7 => NULL,
    x_attribute8 => NULL,
    x_attribute9 => NULL,
    x_attribute10 => NULL,
    x_attribute11 => NULL,
    x_attribute12 => NULL,
    x_attribute13 => NULL,
    x_attribute14 => NULL,
    x_attribute15 => NULL,
    x_meaning => l_mean,
    x_description => l_desc,
    x_last_update_date => sysdate,
    x_last_updated_by => fnd_global.user_id,
    x_last_update_login => fnd_global.login_id);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE;
END archive_compl_report;

END imc_reports_summary_pkg;

/
