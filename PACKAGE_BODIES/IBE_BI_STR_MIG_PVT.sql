--------------------------------------------------------
--  DDL for Package Body IBE_BI_STR_MIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_BI_STR_MIG_PVT" AS
/* $Header: IBEBISTRMIGB.pls 120.1 2005/09/14 03:33:29 appldev ship $ */


g_start_dt    DATE := SYSDATE;


type g_org_mapping is RECORD(
    minisite_id        aso_quote_headers_all.minisite_id%TYPE,
    org_id             aso_quote_headers_all.org_id%TYPE,
    minisite_name      ibe_msites_vl.msite_name%TYPE,
    org_name           hr_operating_units.name%TYPE ,
    is_valid_org       varchar2(1),
    is_valid_str       varchar2(1),
    is_duplicate_org   varchar2(1) );

type org_mapping_table is table of g_org_mapping
   index by binary_integer;



v_mapping_tab org_mapping_table;

g_return_code NUMBER := 0;


-- ===========================================================
--  Procedure printLog uses FND_FILE.PUT_LINE  to write in the
--  "log" file of a concurrent program
-- ===========================================================
PROCEDURE printLog(p_message IN VARCHAR2)
IS
BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG,p_message);
END printLog;

-- ===========================================================
--  Procedure printOutput uses FND_FILE.PUT_LINE  to write in the
--  "Output" file of a concurrent program
-- ===========================================================
PROCEDURE printOutput(p_message IN VARCHAR2)
IS
BEGIN
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_message);
   printLog(p_message);
END printOutput;



-- ====================================================
-- Procedure Clean_log_table Resets the rows in
-- temporary table to start execution of the program
-- ====================================================
 PROCEDURE Clean_log_table
 IS
 BEGIN
        printLog('Procedure Clean_log : Begin');

        DELETE  FROM  ibe_migration_log
        WHERE         Migration_code = 'IBE_MINISITE_MIGRATION'
                      AND  migration_mode = 'EVALUATE';

        printLog('Procedure Clean_log : End');

 EXCEPTION
 WHEN OTHERS THEN
        printLog('Procedure Clean_log : Exception '||sqlerrm);
        g_return_code := 2;
        RAISE;
 END Clean_log_table;



-- =========================================
--  Procedure Parse_org_minisite_mapping
--  The procedure
-- =========================================

PROCEDURE parse_org_minisite_mapping (
     p_string_in    IN   VARCHAR2,
     p_dlim_in      IN   VARCHAR2
     ) IS

l_length         NUMBER;
l_lim            NUMBER;
i                NUMBER;
j                NUMBER;
l_pos            NUMBER;
l_position       NUMBER;
l_start_pos      NUMBER;
l_start_position NUMBER;
l_string_out     VARCHAR2(255);
l_string_left    VARCHAR2(255);
l_string_in      VARCHAR2(255);
l_index          NUMBER;
x                NUMBER;
y                NUMBER ;
l_temp_msg       VARCHAR2(2000);
invalid_org_msite EXCEPTION;


BEGIN

   printLog('Procedure Parse_org_minisite_mapping : Begin');

     l_index := 1;

         l_string_in := replace(p_string_in, ' ' , '');

         FOR x in 1..3 LOOP
             l_string_in := replace(l_string_in, ',,', ',');
         END LOOP;
         FOR x in 1..3 LOOP
             l_string_in := replace(l_string_in, '::', ':');
         END LOOP;
         l_length := length(trim(l_string_in));

         l_lim := l_length;
         i := 1;
         j := 1;
         l_pos := 0;
         l_position :=0;
         l_start_pos := 1;
         l_start_position := 1;

          WHILE i <= l_lim LOOP
                j := instr(l_string_in,p_dlim_in,i);

                IF i = j THEN
                  RAISE invalid_org_msite;
                END IF;
                IF ( j <> 0 ) THEN
                    i := j+1;
                    l_pos := j-1;
                END IF;
                l_string_out := substr(l_string_in,l_start_pos,j-l_start_pos);
                IF (l_pos=0) THEN
                   l_string_left := substr(l_string_in,l_pos+1,length(l_string_in)-l_pos);
                ELSE
                  l_string_left := substr(l_string_in,l_pos+2,length(l_string_in)-l_pos);
                END IF;

                IF  l_string_out is null  THEN
                 l_string_out :=l_string_left ;
                END IF;

                 l_position:= instr(l_string_out,':');

               IF l_position = 0 THEN
                  l_string_out := l_string_out || ':';
                  l_position:= instr(l_string_out,':');
               END IF ;


               v_mapping_tab(l_index).org_id := substr(l_string_out, 1,l_position-1);

              IF l_position = length(l_string_out) THEN
                 v_mapping_tab(l_index).minisite_id := NULL;
                 v_mapping_tab(l_index).is_valid_str := 'N';
              ELSE
                 v_mapping_tab(l_index).minisite_id :=substr(l_string_out,l_position+1);
                  v_mapping_tab(l_index).is_valid_str := 'Y';
              END IF;

              v_mapping_tab(l_index).minisite_name  := 'NULL';
              v_mapping_tab(l_index).org_name  := 'NULL';
              v_mapping_tab(l_index).is_valid_org := 'Y';
              v_mapping_tab(l_index).is_duplicate_org := 'N';

              l_index := l_index+1;
              l_start_pos := j+1;
              EXIT WHEN j = 0;
          END LOOP;

               printLog('Procedure Parse_org_minisite_mapping  : End');

EXCEPTION
     WHEN   invalid_org_msite THEN
           printlog(' ');
           printlog(' ');
           printLog(rpad('*',80,'*'));
           printlog(' ');
           fnd_message.set_name('IBE','IBE_BI_INVALID_ORG_MSITE_ERR');
           l_temp_msg := fnd_message.get;

           printLog(l_temp_msg);
           printlog(' ');
           printLog(rpad('*',80,'*'));
           printlog(' ');
           printlog(' ');
           -- RAISE;
           NULL;
      WHEN OTHERS THEN
            printLog('Error in parse_org_minisite_mapping  , Exception Others' );
            NULL;
END parse_org_minisite_mapping;



--  =======================================================
--  Procedure Validate_params - used to validate user input
--  =======================================================


PROCEDURE Validate_params IS

l_valid_org_id             HR_OPERATING_UNITS.ORGANIZATION_ID%TYPE ;
l_valid_minisite_id        IBE_MSITES_VL.MSITE_ID%TYPE ;
l_valid_minisite_name      ibe_msites_vl.msite_name%TYPE;
l_valid_org_name           hr_operating_units.name%TYPE ;
l_temp_msg                 VARCHAR2(2000);
invalid_str_org_input      EXCEPTION;


CURSOR c_valid_org_id(c_org_id NUMBER) IS
       SELECT organization_id,name
       FROM   hr_operating_units ou
       WHERE  ou.organization_id = c_org_id ;

CURSOR c_valid_msite_id(c_msite_id  NUMBER ) IS
       SELECT  msite_id,msite_name
       FROM   ibe_msites_vl str
       WHERE  str.msite_id = c_msite_id
         AND  str.site_type= 'I'; -- Changed as per the Bug # 4394901

m NUMBER;
n NUMBER;
o number;

BEGIN

   printLog('Procedure validate_params  : start');
   o := v_mapping_tab.FIRST;
   WHILE o IS NOT NULL LOOP
        IF v_mapping_tab(o).org_id IS NULL AND v_mapping_tab(o).minisite_id IS NULL THEN
           v_mapping_tab.DELETE(o);
        END IF;

        o := v_mapping_tab.NEXT(o);

   END LOOP;

  if v_mapping_tab.first is not null then
     FOR n in v_mapping_tab.first ..v_mapping_tab.last LOOP

            IF  v_mapping_tab.EXISTS(n) THEN
              FOR m in v_mapping_tab.first  .. v_mapping_tab.last LOOP
                IF  v_mapping_tab.EXISTS(m) THEN
                 IF ( (v_mapping_tab(n).org_id = v_mapping_tab(m).org_id) AND (n <>m) AND (n>m) ) THEN
                    v_mapping_tab(n).is_duplicate_org := 'Y';
                 END IF;
               END IF;
             END LOOP;

      OPEN c_valid_org_id(v_mapping_tab(n).org_id);
      FETCH c_valid_org_id into l_valid_org_id,l_valid_org_name;


      IF  (c_valid_org_id%NOTFOUND) THEN
           v_mapping_tab(n).is_valid_org :='N' ;
           v_mapping_tab(n).org_name  := 'NULL';
      ELSE
          v_mapping_tab(n).org_name  := l_valid_org_name;

      END IF ;

      CLOSE c_valid_org_id;


      OPEN  c_valid_msite_id(v_mapping_tab(n).minisite_id);
      FETCH c_valid_msite_id into l_valid_minisite_id,l_valid_minisite_name;



      IF    (c_valid_msite_id%NOTFOUND) then
            v_mapping_tab(n).is_valid_str :='N' ;
            v_mapping_tab(n).minisite_name := 'NULL';
      ELSE
            v_mapping_tab(n).minisite_name  := l_valid_minisite_name;

      END IF ;
      CLOSE c_valid_msite_id;


 END IF;

END LOOP;

        printlog(' ');
        printlog(' ');
        printLog(rpad('*',80,'*'));
        printlog(' ');
        fnd_message.set_name('IBE','IBE_BI_OPR_NOT_VALID');
        l_temp_msg := fnd_message.get;

       FOR q in v_mapping_tab.first ..v_mapping_tab.last LOOP

         IF  v_mapping_tab.EXISTS(q)  AND v_mapping_tab(q).is_valid_org = 'N' THEN
	     if l_temp_msg is not null then
	        printlog(l_temp_msg);
		l_temp_msg :=NULL;
	     end if;
            printlog(v_mapping_tab(q).org_id);

        END IF;
      END LOOP;


      fnd_message.set_name('IBE','IBE_BI_STR_NOT_VALID');
      l_temp_msg := fnd_message.get;

      FOR r in v_mapping_tab.first ..v_mapping_tab.last LOOP

       IF  v_mapping_tab.EXISTS(r)  AND v_mapping_tab(r).is_valid_str = 'N' THEN
           if l_temp_msg is not null then
	        printlog(l_temp_msg);
		l_temp_msg :=NULL;
	   end if;
           printlog(v_mapping_tab(r).minisite_id);

       END IF;
      END LOOP;

      fnd_message.set_name('IBE','IBE_BI_OPR_DUPLICATE');


      FOR s in v_mapping_tab.first ..v_mapping_tab.last LOOP

       IF  v_mapping_tab.EXISTS(s)  AND v_mapping_tab(s).is_duplicate_org = 'Y' THEN
	   fnd_message.set_token('1',v_mapping_tab(s).org_id);
           l_temp_msg := fnd_message.get;
	   printlog(l_temp_msg);
           printlog(v_mapping_tab(s).org_id || ':' ||v_mapping_tab(s).minisite_id);
       END IF;
      END LOOP;


      FOR r in v_mapping_tab.first ..v_mapping_tab.last LOOP
          IF  ( v_mapping_tab.EXISTS(r)  AND v_mapping_tab(r).is_valid_str = 'N') OR
              (v_mapping_tab.EXISTS(r)  AND v_mapping_tab(r).is_valid_org = 'N') THEN
               RAISE   invalid_str_org_input ;
          END IF;
      END LOOP;
   end if;
  printLog('Procedure validate_params  : End');


EXCEPTION

    WHEN   invalid_str_org_input  THEN
           fnd_message.set_name('IBE','IBE_BI_INVALID_ORG_MSITE_ERR');
           l_temp_msg := fnd_message.get;
           printLog(l_temp_msg);
           printlog(' ');
           printLog(rpad('*',80,'*'));
           printlog(' ');
           printlog(' ');
           g_return_code := 2;
           RAISE;
    WHEN   OTHERS THEN
           printLog('Procedure validate_params  :' || sqlerrm);
           g_return_code := 2;
           RAISE;
END validate_params;



--=========================================================================
-- Load_temp_table  api  to load temp table with the quotes to be migrated
--=========================================================================


PROCEDURE Load_temp_table(p_override_minisite_flag IN VARCHAR2,
                          p_auto_defaulting_flag   IN VARCHAR2) IS

  l_append_condition varchar2(50);


BEGIN

        printLog('Procedure Load_temp_table : Begin');

        -- p_override_minisite_flag indicates whether carts/published quotes with
        -- minisite_id need to be considered for update based on the applied rules.


        printLog('Procedure Load_temp_table : p_override_minisite_flag = '||p_override_minisite_flag );
        printLog('Procedure Load_tem_table: 1 or 3:' || l_append_condition);

        --Insert into ibe_migration_log
        IF p_auto_defaulting_flag = '1' OR p_auto_defaulting_flag ='3' THEN
            printLog('Procedure defaulting_flag : 1 or 3:');

          IF p_override_minisite_flag = 'Y' then
                   INSERT INTO IBE_MIGRATION_LOG (
                                        mglog_id,
                                        migration_code ,
                                        migration_mode ,
                                        run_sequence,
                                        attribute1,
                                        attribute_idx1,
                                        attribute_idx2,
                                        attribute2,
                                        attribute3,
                                        attribute4,
                                        attribute5,
                                        attribute6,
                                        attribute7,
                                        attribute8,
                                        created_by,
                                        creation_date,
                                        last_updated_by ,
                                        last_update_date,
                                        last_update_login,
                                        request_id ,
                                        program_application_id,
                                        program_id ,
                                        program_update_date )
                        SELECT         IBE_MIGRATION_LOG_S1.nextval,
                                        'IBE_MINISITE_MIGRATION',
                                        'EVALUATE',
                                        0,
                                        a.quote_header_id,
                                        a.org_id,
                                        a.price_list_id,
                                        a.party_type,
                                        a.RECORD_TYPE,
                                        a.msite1,
                                        a.msite2,
                                        a.qtype,
                                        a.currency_code,
                                        decode(p_override_minisite_flag, 'Y', 'Yes', 'No'),
                                        fnd_global.user_id,
                                        SYSDATE,
                                        fnd_global.user_id ,
                                        SYSDATE,
                                        fnd_global.Conc_Login_id,
                                        fnd_global.conc_request_id ,
                                        fnd_global.prog_appl_id,
                                        fnd_global.conc_program_id ,
                                        SYSDATE
                        FROM
                           (SELECT  qhdr.quote_header_id,
                             qhdr.org_id,
                             qhdr.price_list_id,
                             decode(qhdr.quote_source_code,'IStore Walkin','GUEST', hp.party_type) party_type,
                             decode(UPPER(SUBSTR(qhdr.quote_source_code,1,6)), 'ISTORE', 'cart', 'Quote')
                             RECORD_TYPE,
                             qhdr.minisite_id msite1,
                             qlin.minisite_id msite2,
                             decode(NVL(qlin.minisite_id,-999) , -999, NULL, 'LINE') qtype,
                             qhdr.currency_code,
                             RANK() OVER (PARTITION BY qhdr.quote_header_id ORDER BY qlin.quote_line_id ASC NULLS LAST) RANK
                           FROM  aso_quote_headers_all QHDR,
                              aso_quote_lines_all QLIN,
                              hz_parties hp
                           WHERE qhdr.quote_header_id = qlin.quote_header_id(+)
                             AND (qhdr.quote_source_code like 'IStore%' or qhdr.publish_flag = 'Y')
                             AND qhdr.party_id = hp.party_id)  a
                           where a.rank <= 1;
		ELSE

                      INSERT INTO IBE_MIGRATION_LOG (
                                        mglog_id,
                                        migration_code ,
                                        migration_mode ,
                                        run_sequence,
                                        attribute1,
                                        attribute_idx1,
                                        attribute_idx2,
                                        attribute2,
                                        attribute3,
                                        attribute4,
                                        attribute5,
                                        attribute6,
                                        attribute7,
                                        attribute8,
                                        created_by,
                                        creation_date,
                                        last_updated_by ,
                                        last_update_date,
                                        last_update_login,
                                        request_id ,
                                        program_application_id,
                                        program_id ,
                                        program_update_date )
                        SELECT          IBE_MIGRATION_LOG_S1.nextval,
                                        'IBE_MINISITE_MIGRATION',
                                        'EVALUATE',
                                        0,
                                        a.quote_header_id,
                                        a.org_id,
                                        a.price_list_id,
                                        a.party_type,
                                        a.RECORD_TYPE,
                                        a.msite1,
                                        a.msite2,
                                        a.qtype,
                                        a.currency_code,
                                        decode(p_override_minisite_flag, 'Y', 'Yes', 'No'),
                                        fnd_global.user_id,
                                        SYSDATE,
                                        fnd_global.user_id ,
                                        SYSDATE,
                                        fnd_global.Conc_Login_id,
                                        fnd_global.conc_request_id ,
                                        fnd_global.prog_appl_id,
                                        fnd_global.conc_program_id ,
                                        SYSDATE
                        FROM
                           (SELECT  qhdr.quote_header_id,
                             qhdr.org_id,
                             qhdr.price_list_id,
                             decode(qhdr.quote_source_code,'IStore Walkin','GUEST', hp.party_type) party_type,
                             decode(UPPER(SUBSTR(qhdr.quote_source_code,1,6)), 'ISTORE', 'cart', 'Quote')
                             RECORD_TYPE,
                             qhdr.minisite_id msite1,
                             qlin.minisite_id msite2,
                             decode(NVL(qlin.minisite_id,-999) , -999, NULL, 'LINE') qtype,
                             qhdr.currency_code,
                             RANK() OVER (PARTITION BY qhdr.quote_header_id ORDER BY qlin.quote_line_id ASC NULLS LAST) RANK
                           FROM  aso_quote_headers_all QHDR,
                              aso_quote_lines_all QLIN,
                              hz_parties hp
                           WHERE qhdr.quote_header_id = qlin.quote_header_id(+)
                             AND (qhdr.quote_source_code like 'IStore%' or qhdr.publish_flag = 'Y')
                             AND qhdr.party_id = hp.party_id)  a
                           where a.rank <= 1
			   AND a.msite1 IS NULL;

		END IF;



        ELSE
	   IF p_override_minisite_flag = 'Y' then

                         INSERT INTO IBE_MIGRATION_LOG
                                       (mglog_id,
                                        migration_code ,
                                        migration_mode ,
                                        run_sequence,
                                        attribute1,
                                        attribute_idx1,
                                        attribute_idx2,
                                        attribute2,
                                        attribute3,
                                        attribute4,
                                        attribute5,
                                        attribute7,
                                        attribute8,
                                        created_by,
                                        creation_date,
                                        last_updated_by ,
                                        last_update_date,
                                        last_update_login,
                                        request_id ,
                                        program_application_id,
                                        program_id ,
                                        program_update_date )
                        SELECT          IBE_MIGRATION_LOG_S1.nextval,
                                        'IBE_MINISITE_MIGRATION',
                                        'EVALUATE',
                                         0,
                                        qhdr.quote_header_id,
                                        qhdr.org_id,
                                        qhdr.price_list_id,
                                        decode(qhdr.quote_source_code, 'IStore Walkin', 'GUEST', hp.party_type) party_type,
                                        decode(UPPER(SUBSTR(qhdr.quote_source_code,1,6)), 'ISTORE', 'Cart', 'Quote'),
                                        null,
                                        null,
                                        qhdr.currency_code,
                                        decode(p_override_minisite_flag, 'Y', 'Yes', 'No'),
                                        fnd_global.user_id,
                                        SYSDATE,
                                        fnd_global.user_id ,
                                        SYSDATE,
                                        fnd_global.Conc_Login_id,
                                        fnd_global.conc_request_id ,
                                        fnd_global.prog_appl_id,
                                        fnd_global.conc_program_id ,
                                        SYSDATE
                          from          aso_quote_headers_all qhdr,
                                        hz_parties hp
                          where         (qhdr.quote_source_code like 'IStore%' OR qhdr.publish_flag = 'Y')
                                        AND qhdr.party_id = hp.party_id ;
	 ELSE

                    INSERT INTO IBE_MIGRATION_LOG
                                       (mglog_id,
                                        migration_code ,
                                        migration_mode ,
                                        run_sequence,
                                        attribute1,
                                        attribute_idx1,
                                        attribute_idx2,
                                        attribute2,
                                        attribute3,
                                        attribute4,
                                        attribute5,
                                        attribute7,
                                        attribute8,
                                        created_by,
                                        creation_date,
                                        last_updated_by ,
                                        last_update_date,
                                        last_update_login,
                                        request_id ,
                                        program_application_id,
                                        program_id ,
                                        program_update_date )
                        SELECT          IBE_MIGRATION_LOG_S1.nextval,
                                        'IBE_MINISITE_MIGRATION',
                                        'EVALUATE',
                                         0,
                                        qhdr.quote_header_id,
                                        qhdr.org_id,
                                        qhdr.price_list_id,
                                        decode(qhdr.quote_source_code, 'IStore Walkin', 'GUEST', hp.party_type) party_type,
                                        decode(UPPER(SUBSTR(qhdr.quote_source_code,1,6)), 'ISTORE', 'Cart', 'Quote'),
                                        null,
                                        null,
                                        qhdr.currency_code,
                                        decode(p_override_minisite_flag, 'Y', 'Yes', 'No'),
                                        fnd_global.user_id,
                                        SYSDATE,
                                        fnd_global.user_id ,
                                        SYSDATE,
                                        fnd_global.Conc_Login_id,
                                        fnd_global.conc_request_id ,
                                        fnd_global.prog_appl_id,
                                        fnd_global.conc_program_id ,
                                        SYSDATE
                          from          aso_quote_headers_all qhdr,
                                        hz_parties hp
                          where         (qhdr.quote_source_code like 'IStore%' OR qhdr.publish_flag = 'Y')
                                        AND qhdr.party_id = hp.party_id
					AND qhdr.minisite_id IS NULL;
	 END IF;

     END IF;

     -- Check the count of records need to be processed and exit if no records to migrate

     g_return_code := SQL%ROWCOUNT;
     IF g_return_code =0 THEN
       printLog(' No Records to migrate');
       g_return_code := 0;
     END IF;

     COMMIT;

     printLog('Procedure Load_temp_table : End');


 EXCEPTION
 WHEN OTHERS THEN
        printLog('Procedure Load_temp_table : Exception '||sqlerrm);
        g_return_code := 2;
        RAISE;
END Load_temp_table;



-- ============================================================================
--  Procedure find_org_minisite_hits api to find hits of org to minisite mapping
--  ============================================================================
PROCEDURE find_org_minisite_hits
IS

 l_msite_from_org NUMBER;

 -- Get only ORG_IDs associated with a "SINGLE" minisite
 CURSOR c_unique_orgs is
         SELECT  org_id
         FROM
             (SELECT distinct  msite_id,
                     to_number(fnd_profile.value_specific('ORG_ID', -99999, responsibility_id, application_id)) org_id
              FROM   ibe_msite_resps_b)
       WHERE  org_id IS NOT NULL
       GROUP  BY org_id
       HAVING count(*) = 1;

  CURSOR c_msite_org(c_org_id  NUMBER) IS
      SELECT  i.msite_id FROM ibe_msite_resps_b i
      WHERE   to_number(fnd_profile.value_specific('ORG_ID', -99999, responsibility_id, application_id)) = c_org_id;

BEGIN

   printLog('Procedure find_org_minisite_hits : Start');

   FOR crec in c_unique_orgs loop

     OPEN c_msite_org(crec.org_id);
     FETCH c_msite_org into l_msite_from_org;
     CLOSE c_msite_org;

      UPDATE   ibe_migration_log
      SET      attribute6 = 'ORG',
               attribute5 = l_msite_from_org
      WHERE    attribute5 is null
      AND      attribute_idx1 = crec.org_id
      AND      migration_code = 'IBE_MINISITE_MIGRATION'
      AND      migration_mode = 'EVALUATE'
      AND      run_sequence = 0;

  END LOOP;

  printLog('Procedure find_org_minisite_hits : End');


EXCEPTION
 WHEN OTHERS THEN
        printLog('Procedure Load_temp_table : Exception '||sqlerrm);
        g_return_code := 2;
        RAISE;
END  Find_org_minisite_hits ;



--=====================================
--  Procedure find_unique_prclst_msites
--  ===================================




PROCEDURE find_unique_prclst_msites(p_party_type  IN varchar2)
IS

l_msite_prof_check varchar(1);

CURSOR   c_get_priclist(p_party_type varchar2) IS
SELECT   decode (p_party_type, 'PERSON',             registered_prc_listid,
                               'PARTY_RELATIONSHIP', bizpartner_prc_listid,
                               'GUEST',              walkin_prc_listid)    price_list_id,
         msite_id,
         currency_code
  FROM   ibe_msite_currencies
  WHERE  decode (p_party_type, 'PERSON',registered_prc_listid,
                               'PARTY_RELATIONSHIP', bizpartner_prc_listid,
                               'GUEST', walkin_prc_listid)
                          IN
                          (SELECT    decode (p_party_type, 'PERSON',registered_prc_listid,
                                                           'PARTY_RELATIONSHIP', bizpartner_prc_listid,
                                                           'GUEST', walkin_prc_listid) price_list_id
                           FROM      ibe_msite_currencies
                           GROUP BY  decode (p_party_type, 'PERSON',registered_prc_listid,
                                                           'PARTY_RELATIONSHIP', bizpartner_prc_listid,
                                                           'GUEST', walkin_prc_listid)
                           HAVING        count(*) = 1 );
 BEGIN

  printLog('Procedure Find_unique_prclst_msites: Start');

  printLog('Procedure Find_unique_prclst_msites: p_party_type'||p_party_type);

   -- Need to be updating based on PRICE_LIST_ID mapping in iStore New Merchant UI,
   -- ONLY if the profile "IBE: Use Price list associated with Specialty Store" is
   -- enabled at the "iStore" application level.

   l_msite_prof_check := FND_PROFILE.VALUE_SPECIFIC('IBE_USE_MINISITE_PRICELIST',null,null,671);

   IF     l_msite_prof_check = 'Y' THEN

      FOR crec in c_get_priclist(p_party_type) LOOP
          UPDATE ibe_migration_log
          SET    attribute6 = 'PRICE',
                 attribute5 = crec.msite_id
          WHERE  attribute5   IS NULL
          AND    attribute_idx2 = crec.price_list_id
          AND    attribute2     = p_party_type
          AND    attribute7     =  crec.currency_code
          AND    migration_code = 'IBE_MINISITE_MIGRATION'
          AND    migration_mode = 'EVALUATE'
          AND    run_sequence = 0;
      END LOOP;
   END IF;

  printLog('Procedure Find_unique_prclst_msites: End');

EXCEPTION
 WHEN OTHERS THEN
        printLog('Procedure Find_unique_prclst_msites : Exception '||sqlerrm);
        g_return_code := 2;
        RAISE;
END Find_unique_prclst_msites;


--==================================
--Procedure find_price_list_hits
--==================================
PROCEDURE  find_price_list_hits IS
BEGIN

  printLog('Procedure find_price_list_hits : Start');

  Find_unique_prclst_msites('GUEST');
  Find_unique_prclst_msites('PERSON');
  Find_unique_prclst_msites('PARTY_RELATIONSHIP');

  printLog('Procedure find_price_list_hits : End');

EXCEPTION
 WHEN OTHERS THEN
        printLog('Procedure find_price_list_hits : Exception '||sqlerrm);
        g_return_code := 2;
        RAISE;
END Find_price_list_hits  ;


--=========================================================
-- Procedure find_ue_org_hits - used to validate user input
--  =======================================================

--PROCEDURE find_ue_org_hits (p_mapping_tab  IN org_mapping_table) IS
PROCEDURE find_ue_org_hits  IS
BEGIN

  printLog('Procedure find_ue_org_hits : Start');


   FOR i in v_mapping_tab.FIRST .. v_mapping_tab.LAST LOOP
      IF  v_mapping_tab.EXISTS(i) THEN

	UPDATE    ibe_migration_log
	SET       attribute6 = 'MANUAL',
                attribute5 = v_mapping_tab(i).minisite_id
	WHERE     attribute5 IS NULL
        AND     attribute_idx1 = v_mapping_tab(i).org_id
        AND     migration_code = 'IBE_MINISITE_MIGRATION'
        AND     migration_mode = 'EVALUATE'
        AND     run_sequence = 0;
       END IF;

   END LOOP;

  printLog('Procedure find_ue_org_hits : End');

EXCEPTION
 WHEN OTHERS THEN
        printLog('Procedure find_ue_org_hits : Exception '||sqlerrm);
        g_return_code := 2;
        RAISE;
END find_ue_org_hits ;







--====================================================================
--     Procedure update_quote api to update aso_quote_headers_all
--====================================================================

PROCEDURE update_quote (p_batch_size IN NUMBER) IS
CURSOR LogCursor IS
SELECT  to_number(attribute1) header_id,
to_number(attribute5) minisite
FROM    ibe_migration_log
WHERE   migration_code = 'IBE_MINISITE_MIGRATION'
AND     migration_mode = 'EVALUATE'
AND     run_sequence = 0;

TYPE MsiteTab IS TABLE OF ASO_QUOTE_HEADERS_ALL.MINISITE_ID%TYPE;
TYPE QuoteHeaderTab IS TABLE OF ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID%TYPE;

MsiteTable MsiteTab;
QuoteHeaderTable QuoteHeaderTab;
k Number :=0;

BEGIN

  printLog('Procedure update_quote : Start');

     OPEN LogCursor;
     LOOP
     FETCH LogCursor BULK COLLECT INTO QuoteHeaderTable,MsiteTable
     LIMIT p_batch_size;

	/** check if above cursor fetches no rows and then exit out of loop **/
	IF QuoteHeaderTable.COUNT = 0 THEN
		EXIT;
	END IF;

     FORALL i in QuoteHeaderTable.First..QuoteHeaderTable.Last
        UPDATE   aso_quote_headers_all
        SET      minisite_id = MsiteTable(i)
        WHERE    quote_header_id = QuoteHeaderTable(i);

     EXIT WHEN LogCursor%NOTFOUND;
     END LOOP;
     CLOSE LogCursor;

  printLog('Procedure update_quote : End');

EXCEPTION
 WHEN OTHERS THEN
        printLog('Procedure update_quote : Exception '||sqlerrm);
        g_return_code := 2;
        RAISE;
END update_quote;


--=====================================================================
--Procedure migration_status api to update ibe_migration_history
--====================================================================
  PROCEDURE migration_status(p_status IN VARCHAR2) IS


  BEGIN

          printLog('Procedure Migration_status : Start');


           UPDATE  IBE_MIGRATION_HISTORY
           SET     STATUS = p_status,
   	           LAST_UPDATE_DATE = SYSDATE
           WHERE   MIGRATION_CODE = 'IBE_MINISITE_MIGRATION';

           IF (SQL%NOTFOUND) THEN
               printLog('Procedure Migration_status :sqlnotfound');


          INSERT INTO IBE_MIGRATION_HISTORY(MIGRATION_CODE,
                                             OBJECT_VERSION_NUMBER,
                                             CREATED_BY,
                                             CREATION_DATE,
                                             LAST_UPDATED_BY,
                                             LAST_UPDATE_DATE,
                                             STATUS)
                                      VALUES('IBE_MINISITE_MIGRATION',
                                             0,
                                             FND_GLOBAL.user_id,
                                             g_start_dt,
                                             FND_GLOBAL.user_id,
                                             SYSDATE,
                                             p_status);



           END IF;


         printLog('Procedure Migration_status : End');

 EXCEPTION
 WHEN OTHERS THEN
        printLog('Procedure Migration_status : Exception '||sqlerrm);
        g_return_code := 2;
        RAISE;
 END migration_status;



--  =====================================================================
--  Procedure log_updated_rows
--  =====================================================================

PROCEDURE log_updated_rows
IS
  l_next_sequence NUMBER ;
BEGIN

  printLog('Procedure log_updated_rows : Start');

  -- Delete all records which do not have the "NEW" minisite_id after applying the rules.

   DELETE FROM  ibe_migration_log
   WHERE        attribute5 IS NULL
   AND          migration_code = 'IBE_MINISITE_MIGRATION'
   AND          migration_mode = 'EVALUATE';

   select ibe_migration_log_s2.nextval into l_next_sequence from dual ;

   UPDATE  ibe_migration_log
   SET     migration_mode = 'EXECUTE',
           run_sequence = l_next_sequence
   WHERE   Migration_code = 'IBE_MINISITE_MIGRATION'
   AND     migration_mode = 'EVALUATE'
   AND     run_sequence = 0;

   printLog('Procedure log_updated_rows : End');

 EXCEPTION
 WHEN OTHERS THEN
        printLog('Procedure log_updated_rows : Exception '||sqlerrm);
        g_return_code := 2;
        RAISE;
END log_updated_rows;




--  ===========================================================
--  Procedure printReport
--  ===========================================================
  PROCEDURE printReport(p_auto_defaulting_flag IN VARCHAR2,
                        p_override_minisite_flag IN VARCHAR2,
                        p_running_mode IN VARCHAR2,
                        p_string_in IN VARCHAR2
                        )   IS
  l_cnt_line number;
  l_cnt_price number;
  l_cnt_org number;
  l_cnt_manual number;
  l_tot_found number;
  l_tot_left number;
  l_temp_msg VARCHAR2(2000);
  l_temp_msg1 VARCHAR2(2000);
  l_temp_msg2 VARCHAR2(2000);
  l_temp_msg3 VARCHAR2(2000);
  l_temp_rule VARCHAR2(2000);
  l_temp_mode VARCHAR2(2000);
  l_temp_yesno VARCHAR2(200);

   CURSOR   c_get_carts_count IS
   SELECT   count(mlog.attribute1) cnt_cart,ou.organization_id,ou.name
   FROM     ibe_migration_log mlog, hr_operating_units ou
   WHERE    attribute5 is  null
   AND      mlog.attribute_idx1= ou.organization_id
   GROUP BY mlog.attribute_idx1, ou.organization_id,ou.name;

   CURSOR c_lookup(ptype IN VARCHAR2,pcode IN VARCHAR2) IS
   SELECT LookUp_Code,Meaning
   FROM   Fnd_Lookups
   WHERE  Lookup_Type  = pType
   AND lookup_code = pcode;


  BEGIN
    SELECT  sum(decode(attribute6,'LINE',1,0)) line,
            sum(decode(attribute6,'PRICE',1,0)) price,
            sum(decode(attribute6,'ORG',1,0)) org,
            sum(decode(attribute6,'MANUAL',1,0)) manual ,
            SUM(decode(attribute5,null,0,1)) ,
	    sum(decode(attribute5,null,1,0))
    INTO    l_cnt_line,
            l_cnt_price ,
            l_cnt_org,
            l_cnt_manual,
            l_tot_found,
            l_tot_left
   FROM     ibe_migration_log
   WHERE   Migration_code = 'IBE_MINISITE_MIGRATION'
   AND     migration_mode = 'EVALUATE'
   AND     run_sequence = 0;



    fnd_message.set_name('IBE','IBE_BI_MIGRATION_REPORT');
    l_temp_msg := fnd_message.get;
    printOutput(l_temp_msg);
    printOutput(rpad('=',80,'='));
    printOutput(' ');
    fnd_message.set_name('IBE','IBE_BI_CONC_PROG_PARAMETERS');
    l_temp_msg := fnd_message.get;
    printOutput(l_temp_msg);
    printOutput(rpad('-',60,'-'));
    printOutput('  ');

    fnd_message.set_name('IBE','IBE_BI_REPORT_PARAMETERS');
    l_temp_msg := fnd_message.get;
    fnd_message.set_name('IBE','IBE_BI_REPORT_PARAMETER_VALS');
    l_temp_msg1 := fnd_message.get;
    printOutput(RPAD(l_temp_msg ,45)|| ' ' || l_temp_msg1);
    printOutput(RPAD('-',45,'-')|| ' ' || lPAD('-',14,'-'));

    fnd_message.set_name('IBE','IBE_BI_RUNNING_MODE');
    l_temp_msg := fnd_message.get;
    for rec_mode_lookup in c_lookup('IBE_BI_MIG_MODE',p_running_mode) loop
      l_temp_mode := rec_mode_lookup.meaning;
    end loop;
    printOutput( RPAD(l_temp_msg,45,' ')  || ' ' || l_temp_mode);

    fnd_message.set_name('IBE','IBE_BI_USE_MIG_RULES');
    l_temp_msg := fnd_message.get;
    for rec_rule_lookup in c_lookup('IBE_BI_MIG_RULE',p_auto_defaulting_flag) loop
      l_temp_rule := rec_rule_lookup.meaning;
    end loop;
    printOutput( RPAD(l_temp_msg,45,' ')  || ' ' || l_temp_rule);

    if p_override_minisite_flag = 'Y' then
      fnd_message.set_name('IBE','IBE_BI_UPD_CARTS_WITH_STORE_ID');
      l_temp_msg := fnd_message.get;
      for rec_yesno_lookup in c_lookup('YES_NO',p_override_minisite_flag) loop
        l_temp_yesno := rec_yesno_lookup.meaning;
      end loop;
      printOutput( RPAD(l_temp_msg,45,' ')  || ' ' || l_temp_yesno);
    end if;

    fnd_message.set_name('IBE','IBE_BI_ORG_STR_INPUT');
    l_temp_msg := fnd_message.get;
    printOutput( RPAD(l_temp_msg,45)  || ' ' || nvl(p_string_in,'<  >'));
    printOutput(' ');

    fnd_message.set_name('IBE','IBE_BI_USER_ORG_STR_MAP');
    l_temp_msg := fnd_message.get;
    printOutput(l_temp_msg );
    printOutput(rpad('-',60,'-'));
    fnd_message.set_name('IBE','IBE_BI_ORGANIZATION_IDENTIFIER');
    l_temp_msg := fnd_message.get;

    fnd_message.set_name('IBE','IBE_BI_ORGANIZATION_NAME');
    l_temp_msg1 := fnd_message.get;

    fnd_message.set_name('IBE','IBE_BI_STORE_IDENTIFIER');
    l_temp_msg2 := fnd_message.get;

    fnd_message.set_name('IBE','IBE_BI_STORE_NAME');
    l_temp_msg3 := fnd_message.get;

   if v_mapping_tab.first is not null then

    printOutput(RPAD(l_temp_msg ,20)   || ' '  || RPAD(l_temp_msg1 ,20)  || ' ' ||                        RPAD(l_temp_msg2 ,20)    || l_temp_msg3);
    printOutput(RPAD('-',20,'-')||' '||RPAD('-',20,'-')||' '                                   ||RPAD('-',20,'-') || ' ' || lPAD('-',20,'-'));

    FOR t in v_mapping_tab.first ..v_mapping_tab.last LOOP
      IF  v_mapping_tab.EXISTS(t) THEN

      printOutput( rpad(TO_CHAR(v_mapping_tab(t).org_id), 20,' ') || ' ' ||                                    rpad(v_mapping_tab(t).org_name,20,' ') || ' ' ||
      rpad(TO_CHAR(v_mapping_tab(t).minisite_id), 20,' ')
      || ' ' ||          v_mapping_tab(t).minisite_name);


     END IF;

   END LOOP;
  end if;
    printOutput(' ');
    printOutput(' ');
    fnd_message.set_name('IBE','IBE_BI_MIGRATION_SUMMARY');
    l_temp_msg := fnd_message.get;
    printOutput(l_temp_msg);
    printOutput(rpad('=',80,'='));
    printOutput(' ');

    fnd_message.set_name('IBE','IBE_BI_NO_OF_CARTS_FOUND');
    l_temp_msg := fnd_message.get;
    printOutput(l_temp_msg ||' '|| nvl(l_tot_found,0));
    fnd_message.set_name('IBE','IBE_BI_NO_OF_CARTS_LEFT');
    l_temp_msg := fnd_message.get;
    printOutput(l_temp_msg || ' ' ||nvl(l_tot_left,0));
    printOutput(' ');


    fnd_message.set_name('IBE','IBE_BI_METHOD_TO_FIND_STR');
    l_temp_msg := fnd_message.get;
    fnd_message.set_name('IBE','IBE_BI_NO_OF_CARTS');
    l_temp_msg1 := fnd_message.get;


    printOutput(RPAD(l_temp_msg,45,' ')  || ' ' || l_temp_msg1);
    printOutput(RPAD('-',45,'-')       || ' ' || LPAD('-',14,'-'));
    fnd_message.set_name('IBE','IBE_BI_MIGRATION_LINE');
    l_temp_msg1 := fnd_message.get;
    printOutput(RPAD(l_temp_msg1,45,' ')  || ' ' || nvl(l_cnt_line,0));
    fnd_message.set_name('IBE','IBE_BI_MIGRATION_ORG');
    l_temp_msg1 := fnd_message.get;
    printOutput(RPAD(l_temp_msg1,45,' ')    || ' ' || nvl(l_cnt_org,0));
    fnd_message.set_name('IBE','IBE_BI_MIGRATION_PRICE');
    l_temp_msg1 := fnd_message.get;
    printOutput(RPAD(l_temp_msg1,45,' ')  || ' ' || nvl(l_cnt_price,0));
    fnd_message.set_name('IBE','IBE_BI_MIGRATION_MANUAL');
    l_temp_msg1 := fnd_message.get;
    printOutput(RPAD(l_temp_msg1,45,' ')    || ' ' || nvl(l_cnt_manual,0));
    printOutput(' ');
    printOutput(' ');

    fnd_message.set_name('IBE','IBE_BI_EXCEPTION_REPORT');
    l_temp_msg := fnd_message.get;
    printOutput(l_temp_msg );
    printOutput(rpad('=',80,'='));
    printOutput(' ');
    fnd_message.set_name('IBE','IBE_BI_EXCEPTION_REPORT_DETAIL');
    l_temp_msg := fnd_message.get;
    printOutput(l_temp_msg );
    printOutput(rpad('-',60,'-'));
    printOutput(' ');


    fnd_message.set_name('IBE','IBE_BI_NO_OF_CARTS');
    l_temp_msg := fnd_message.get;
    fnd_message.set_name('IBE','IBE_BI_ORGANIZATION_IDENTIFIER');
    l_temp_msg1 := fnd_message.get;
    fnd_message.set_name('IBE','IBE_BI_ORGANIZATION_NAME');
    l_temp_msg2 := fnd_message.get;

    printOutput(RPAD(l_temp_msg ,20,' ')  || ' ' || RPAD(l_temp_msg1,25,' ')||' '||l_temp_msg2);
    printOutput(RPAD('-',20,'-')       || ' '||RPAD('-',25,'-')       || ' ' || lPAD('-',33,'-'));

    FOR crec IN c_get_carts_count LOOP
    printOutput( RPAD(crec.cnt_cart,20,' ')  || ' '|| RPAD(crec.organization_id,25,' ')  || ' ' || crec.name);
    END LOOP;

   printOutput(' ');
   printOutput(' ');

  EXCEPTION

   WHEN OTHERS THEN
            printLog('Procedure printreport : Exception '||sqlerrm);
            g_return_code := 2;
            RAISE;
  END printReport;





--===========================================================
-- Procedure print_org_store_identifiers
--===========================================================

  PROCEDURE print_org_store_identifiers   IS

  l_temp_msg VARCHAR2(2000);
  l_temp_msg1 VARCHAR2(2000);



    CURSOR c_valid_orgs is
    SELECT organization_id, name  FROM hr_operating_units OU
    WHERE exists (SELECT  qhdr.org_id FROM  aso_quote_headers_all qhdr
                  WHERE   ou.organization_id = qhdr.org_id);

    CURSOR c_valid_str is
    SELECT  distinct MSITE_ID,
            msite_name
    FROM  ibe_msites_vl
    WHERE msite_id <> 1
      AND site_type= 'I'; -- Changed as per the Bug # 4394901

  BEGIN


     fnd_message.set_name('IBE','IBE_BI_ORG_STR_IDENTIFIER');
     l_temp_msg := fnd_message.get;
     printOutput(l_temp_msg);
     printOutput(RPAD('=' ,80 , '='));
     printOutput(' ');
     fnd_message.set_name('IBE','IBE_BI_ORGANIZATION_IDENTIFIER');
     l_temp_msg := fnd_message.get;
     fnd_message.set_name('IBE','IBE_BI_ORGANIZATION_NAME');
     l_temp_msg1 := fnd_message.get;




     printOutput(RPAD(l_temp_msg1,45,' ')   || ' '         || l_temp_msg);
     printOutput(RPAD('-',45,'-') || ' ' ||lPAD('-',24,'-') );

    FOR r_valid_orgs in c_valid_orgs LOOP
     printOutput(rpad(r_valid_orgs.name,45)|| ' ' ||  r_valid_orgs.organization_id);
    END LOOP;


     printOutput(' ');
     fnd_message.set_name('IBE','IBE_BI_STORE_IDENTIFIER');
     l_temp_msg := fnd_message.get;
     fnd_message.set_name('IBE','IBE_BI_STORE_NAME');
     l_temp_msg1 := fnd_message.get;

     printOutput(RPAD(l_temp_msg1,45,' ')   || ' '   || l_temp_msg);
     printOutput(RPAD('-',45,'-') || ' ' ||lPAD('-',24,'-') );

     FOR r_valid_str in c_valid_str LOOP
     printOutput(rpad(r_valid_str.msite_name,45)|| ' '||  r_valid_str.msite_id);
     END LOOP;

  EXCEPTION

   WHEN OTHERS THEN
            printLog('Error in print_org_store_identifiers  '||sqlerrm );
            g_return_code := 2;
            RAISE;

  END print_org_store_identifiers;






--=====================================================================
--Procedure "Run_migration" : Main api called from concurrent executable
--=====================================================================
PROCEDURE run_migration(errbuf   OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY VARCHAR2,
                        p_auto_defaulting_flag IN  VARCHAR2 ,
                        p_override_minisite_flag IN VARCHAR2,
                        p_running_mode IN VARCHAR2,
                        p_string_in IN VARCHAR2,
			p_batch_size  IN NUMBER)
IS
  l_status VARCHAR2(1);
  l_exit_flag VARCHAR2(1);
  user_input_null EXCEPTION;


BEGIN

     printLog('Proc Run_migration : Begin');
     printLog('Logging In Values... start');
     printLog ('Defaulting Flag :'|| p_auto_defaulting_flag);
     printLog ('Over Ride Minisite Flag :'|| p_override_minisite_flag);
     printLog ('Running Mode :'|| p_running_mode);
     printLog ('In String :'|| p_string_in);
     printLog('Logging In Values... end ');

    l_exit_flag  := 'N';

    IF    p_running_mode = 'GET_ORG_STR_MAP' THEN
          print_org_store_identifiers;
          retcode := 0;
          l_exit_flag := 'Y';
    END IF;

    --Parse the entered org to minisite mapping
     IF l_exit_flag = 'N' THEN   -- continue with the procerssing only if the running mode is not "GET_ORG_STR_MAP"

     IF    p_auto_defaulting_flag = '2' or p_auto_defaulting_flag = '3' THEN
          IF p_string_in is NULL THEN
           --  retcode := 1;
           --   l_exit_flag := 'Y';
              RAISE user_input_null;
          --EXIT;
         END IF;
    END IF;

     parse_org_minisite_mapping (p_string_in, ',' );
     Validate_params;


    --clean the temporary log table before starting this run - just to make sure we start fresh


     Clean_log_table;


     --To load temporary table containg all the quote that needs to updated,
     --it will be used during the session of current run, to track any changes.


     Load_temp_table(p_override_minisite_flag ,p_auto_defaulting_flag);

    IF  g_return_code >  0 then

       -- find hits using automatic defaulting logic

      IF  p_auto_defaulting_flag = '1' OR p_auto_defaulting_flag = '3' THEN
          find_org_minisite_hits;
          find_price_list_hits;
      END IF ;


      -- find hits using the manual org to minisite mapping

       IF  p_auto_defaulting_flag = '2' OR p_auto_defaulting_flag = '3' THEN

           find_ue_org_hits;
       END IF;

      --if user has selected only report only (evaluation) mode then do not call update_quote
      printLog('running mode is ....'||p_running_mode);
      IF   p_running_mode = 'EXECUTE'  THEN
        printLog('Calling update quote');
	     Update_quote(p_batch_size);
	     --log_updated_rows;
 	     migration_status('SUCCESS');

      ENd IF ;

      -- print report of hit ratio for all the carts
    END IF;
       printReport(p_auto_defaulting_flag,
                   p_override_minisite_flag,
                   p_running_mode,
                   p_string_in);

      print_org_store_identifiers();

     IF   p_running_mode = 'EXECUTE'  THEN
	  log_updated_rows;
     END IF;

     IF   p_running_mode = 'EVALUATE'  THEN
     -- clean the temporary log table after reporting
	DELETE FROM  ibe_migration_log
	WHERE  Migration_code = 'IBE_MINISITE_MIGRATION'
	       AND  migration_mode = 'EVALUATE'
	       AND  run_sequence  = 0
	       AND  attribute5 IS null;

    END IF ;
END IF ;

  COMMIT;
  retcode := 0;
  errbuf := 'SUCCESS';
  printLog('retcode  is :'||retcode);
  printLog('errbuf is :'|| errbuf);

  printLog('Proc Run Migration  : End');

EXCEPTION
  WHEN   user_input_null THEN
   ROLLBACK;
         printLog('Proc Run Migration :'||'User Org:Store Input Can Not Be  Null In EVALUATE MODE');
	 printLog('SQL ERROR :'||SQLCODE||'-'||SQLERRM);
         retcode := -1;

        --  RAISE;
  WHEN OTHERS THEN
       IF g_return_code = 0 THEN
          retcode := 0;
       ELSE
	   ROLLBACK;
	   retcode := -1;
       END IF;

      printLog('Proc Run Migration'||' '||SQLCODE||'-'||SQLERRM);
      errbuf := ' errbuf' || ' '||SQLCODE||'-'||SQLERRM;
      printLog('retcode  is :'||retcode || 'errbuf is :'|| errbuf);

END run_migration;

END  IBE_BI_STR_MIG_PVT;

/
