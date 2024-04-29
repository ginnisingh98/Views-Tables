--------------------------------------------------------
--  DDL for Package Body PER_EMPDIR_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EMPDIR_SS" AS
/* $Header: peredrcp.pkb 120.11.12010000.7 2013/07/26 08:48:57 sudedas ship $ */

-- Global Variables
TYPE cur_typ IS REF CURSOR;
g_hz_api_api_version CONSTANT Number:=1.0;
g_srcSystem          VARCHAR2(30);
g_oracle_db_version  CONSTANT NUMBER := hr_general2.get_oracle_db_version;
g_schema_owner       VARCHAR2(30);

CURSOR c_organizations IS
 SELECT o.organization_id, nvl(upper(replace(oi.org_information1,'|','||''.''||')),'j.name') slist
  FROM hr_all_organization_units o, hr_organization_information oi
 WHERE o.organization_id = o.business_group_id
 AND o.organization_id = oi.organization_id (+)
 AND oi.org_information_context(+) = 'SSHR Information';

-- Local Members

PROCEDURE write_log(
   p_fpt IN NUMBER
  ,p_msg IN VARCHAR2) IS

l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

BEGIN
    -- p_fpt (1,2)?(log : output)
    FND_FILE.put(p_fpt, p_msg);
    FND_FILE.NEW_LINE(p_fpt, 1);
    -- If p_fpt == 2 and debug flag then also write to log file
    IF p_fpt = 2 AND l_debug THEN
     FND_FILE.put(1, p_msg);
     FND_FILE.NEW_LINE(1, 1);
    END IF;
    --dbms_output.put_line(p_msg);
    EXCEPTION
        WHEN OTHERS THEN
         NULL;
END write_log;

FUNCTION getTblOwner RETURN VARCHAR2 IS
l_status    VARCHAR2(100) := '';
l_industry  VARCHAR2(100) := '';
l_result    BOOLEAN;
l_schema_owner VARCHAR2(10) := '';
BEGIN
    l_result := FND_INSTALLATION.GET_APP_INFO(
                'PER',
                 l_status,
                 l_industry,
                 l_schema_owner);

    IF l_result THEN
       RETURN l_schema_owner;
    ELSE
       write_log(1, 'Error in getTblOwner: '||SQLCODE);
       write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
       RETURN 'HR';
    END IF;
END getTblOwner;

PROCEDURE trace(
   p_enable BOOLEAN) IS

ddl_curs integer;
v_Dummy  integer;
BEGIN
  ddl_curs := dbms_sql.open_cursor;
  IF (p_enable) then
    dbms_sql.parse(ddl_curs,'ALTER SESSION SET sql_trace = TRUE',dbms_sql.native);
  ELSE
    dbms_sql.parse(ddl_curs,'ALTER SESSION SET sql_trace = FALSE',dbms_sql.native);
  END IF;
  v_Dummy := DBMS_SQL.EXECUTE(ddl_curs);
  dbms_sql.close_cursor(ddl_curs);
EXCEPTION WHEN OTHERS THEN
 NULL;
END trace;

PROCEDURE gather_stats IS
BEGIN

    write_log(1, 'Begin gathering stats: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    fnd_stats.gather_table_stats(g_schema_owner,'PER_EMPDIR_PEOPLE');
    fnd_stats.gather_table_stats(g_schema_owner,'PER_EMPDIR_ASSIGNMENTS');
    fnd_stats.gather_table_stats(g_schema_owner,'PER_EMPDIR_ORGANIZATIONS');
    fnd_stats.gather_table_stats(g_schema_owner,'PER_EMPDIR_JOBS');
    fnd_stats.gather_table_stats(g_schema_owner,'PER_EMPDIR_POSITIONS');
    fnd_stats.gather_table_stats(g_schema_owner,'PER_EMPDIR_PHONES');
    fnd_stats.gather_table_stats(g_schema_owner,'PER_EMPDIR_LOCATIONS');
    fnd_stats.gather_table_stats(g_schema_owner,'PER_EMPDIR_LOCATIONS_TL');
    fnd_stats.gather_table_stats(g_schema_owner,'PER_EMPDIR_IMAGES');

    write_log(1, 'End gathering stats: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        NULL;
END gather_stats;


PROCEDURE dump_totals(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_cnt IN NUMBER
) IS
BEGIN

    FOR I IN 1 .. p_cnt LOOP
    BEGIN
        SELECT count(unique a.person_id)-1 INTO cntTbl.cnt(I)
        FROM per_empdir_assignments a,
        per_empdir_people p
        WHERE a.orig_system = cntTbl.orig_system(I)
        AND a.active = 'Y'
        and a.PERSON_ID = p.orig_system_ID
        and p.active = 'Y'
        CONNECT BY PRIOR a.person_id = a.supervisor_id
                     AND a.orig_system = cntTbl.orig_system(I)
        START WITH a.person_id = cntTbl.orig_system_id(I)
        AND a.active = 'Y'
        AND a.primary_flag = 'Y'
        AND a.orig_system = cntTbl.orig_system(I);

        EXCEPTION WHEN OTHERS THEN
            NULL;
    END;
    END LOOP;

    FORALL I IN 1 .. p_cnt
      UPDATE per_empdir_people
        SET total_reports = cntTbl.cnt(I)
      WHERE rowid = cntTbl.row_id(I);

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in dump_totals: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END dump_totals;

PROCEDURE compute_reports(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_source_system IN VARCHAR2
) IS

CURSOR people IS
 SELECT rowid
       ,orig_system
       ,orig_system_id
       ,null cnt
  FROM per_empdir_people p
  WHERE active = 'Y'
  AND p.orig_system = p_source_system;

BEGIN


    write_log(1, 'Begin Compute Directs: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    UPDATE per_empdir_people p
    SET direct_reports = (SELECT count(*)
                     FROM per_empdir_assignments a, per_empdir_people rp
                     WHERE supervisor_id = p.orig_system_id
                     AND a.orig_system = p.orig_system
                     AND a.active = 'Y'
                     -- AND a.primary_flag = 'Y'
                     AND a.person_id = rp.orig_system_id
                     AND a.orig_system =  rp.orig_system
                     AND rp.active = 'Y')
    WHERE p.orig_system = p_source_system;

    COMMIT;

    write_log(1, 'End Compute Directs: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));
    write_log(1, 'Begin Compute Totals: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    OPEN people; LOOP
     BEGIN
      FETCH people BULK COLLECT
       INTO cntTbl.row_id
           ,cntTbl.orig_system
           ,cntTbl.orig_system_id
           ,cntTbl.cnt LIMIT g_commit_size;

       IF cntTbl.row_id.count <= 0 THEN
         CLOSE people;
         EXIT;
       END IF;

       dump_totals(
         errbuf
        ,retcode
        ,cntTbl.row_id.count
       );

       COMMIT;

       IF people%NOTFOUND THEN
          CLOSE people;
          EXIT;
       END IF;
     END;
    END LOOP;
    COMMIT;

    write_log(1, 'End Compute Totals: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in compute_reports: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END compute_reports;

PROCEDURE dump_per_jobs(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_cnt IN NUMBER
) IS
BEGIN
     g_date := trunc(SYSDATE);

     FORALL I IN 1 .. p_cnt

	insert INTO per_empdir_jobs (ORIG_SYSTEM,
	ORIG_SYSTEM_ID,
	BUSINESS_GROUP_ID,
	JOB_DEFINITION_ID,
	NAME ,
	LANGUAGE,
	SOURCE_LANG ,
	OBJECT_VERSION_NUMBER,
	PARTITION_ID,
	LAST_UPDATE_DATE,
	LAST_UPDATE_BY,
	CREATED_BY,
	CREATION_DATE,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	ATTRIBUTE16,
	ATTRIBUTE17,
	ATTRIBUTE18,
	ATTRIBUTE19,
	ATTRIBUTE20) values(
             jobTbl.orig_system(I)
            ,jobTbl.orig_system_id(I)
            ,jobTbl.business_group_id(I)
            ,jobTbl.job_definition_id(I)
            ,jobTbl.name(I)
            ,jobTbl.language(I)
            ,jobTbl.source_language(I)
            ,jobTbl.object_version_number(I)
            ,jobTbl.partition_id(I)
            ,g_date
            ,g_user_id
            ,g_user_id
            ,g_date
            ,g_request_id
            ,g_prog_appl_id
            ,g_prog_id
            ,g_date
            ,jobTbl.attribute_category(I)
            ,jobTbl.attribute1(I)
            ,jobTbl.attribute2(I)
            ,jobTbl.attribute3(I)
            ,jobTbl.attribute4(I)
            ,jobTbl.attribute5(I)
            ,jobTbl.attribute6(I)
            ,jobTbl.attribute7(I)
            ,jobTbl.attribute8(I)
            ,jobTbl.attribute9(I)
            ,jobTbl.attribute10(I)
            ,jobTbl.attribute11(I)
            ,jobTbl.attribute12(I)
            ,jobTbl.attribute13(I)
            ,jobTbl.attribute14(I)
            ,jobTbl.attribute15(I)
            ,jobTbl.attribute16(I)
            ,jobTbl.attribute17(I)
            ,jobTbl.attribute18(I)
            ,jobTbl.attribute19(I)
            ,jobTbl.attribute20(I)
            );

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in dump_per_jobs: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END dump_per_jobs;

PROCEDURE update_hr_pos(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE
  ,p_cnt IN NUMBER
) IS
BEGIN

     g_date := trunc(SYSDATE);

     FORALL I IN 1 .. p_cnt
      UPDATE per_empdir_positions
      SET orig_system = posTbl.orig_system(I)
         ,orig_system_id = posTbl.orig_system_id(I)
    	 ,business_group_id = posTbl.business_group_id(I)
    	 ,job_id = posTbl.job_id(I)
    	 ,location_id = posTbl.location_id(I)
    	 ,organization_id = posTbl.organization_id(I)
    	 ,position_definition_id = posTbl.position_definition_id(I)
    	 ,name = posTbl.name(I)
    	 ,language = posTbl.language(I)
    	 ,source_lang = posTbl.source_language(I)
    	 ,object_version_number = posTbl.object_version_number(I)
    	 ,partition_id = posTbl.partition_id(I)
    	 ,last_update_date = g_date
    	 ,last_update_by = g_user_id
    	 ,created_by = g_user_id
    	 ,creation_date = g_date
    	 ,request_id = g_request_id
    	 ,program_application_id = g_prog_appl_id
    	 ,program_id = g_prog_id
    	 ,program_update_date = g_date
    	 ,attribute_category = posTbl.attribute_category(I)
    	 ,attribute1 = posTbl.attribute1(I)
    	 ,attribute2 = posTbl.attribute2(I)
    	 ,attribute3 = posTbl.attribute3(I)
    	 ,attribute4 = posTbl.attribute4(I)
    	 ,attribute5 = posTbl.attribute5(I)
    	 ,attribute6 = posTbl.attribute6(I)
    	 ,attribute7 = posTbl.attribute7(I)
    	 ,attribute8 = posTbl.attribute8(I)
    	 ,attribute9 = posTbl.attribute9(I)
    	 ,attribute10 = posTbl.attribute10(I)
    	 ,attribute11 = posTbl.attribute11(I)
    	 ,attribute12 = posTbl.attribute12(I)
    	 ,attribute13 = posTbl.attribute13(I)
    	 ,attribute14 = posTbl.attribute14(I)
    	 ,attribute15 = posTbl.attribute15(I)
    	 ,attribute16 = posTbl.attribute16(I)
    	 ,attribute17 = posTbl.attribute17(I)
    	 ,attribute18 = posTbl.attribute18(I)
    	 ,attribute19 = posTbl.attribute19(I)
    	 ,attribute20 = posTbl.attribute20(I)
       WHERE orig_system = posTbl.orig_system(I)
       AND orig_system_id = posTbl.orig_system_id(I)
       AND language = posTbl.language(I);

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in update_hr_pos: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END update_hr_pos;

PROCEDURE dump_hr_pos(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE
  ,p_cnt IN NUMBER
) IS
BEGIN
     g_date := trunc(SYSDATE);

     FORALL I IN 1 .. p_cnt
     INSERT INTO per_empdir_positions values (
       	 posTbl.orig_system(I)
    	,posTbl.orig_system_id(I)
    	,posTbl.business_group_id(I)
    	,posTbl.job_id(I)
    	,posTbl.location_id(I)
    	,posTbl.organization_id(I)
    	,posTbl.position_definition_id(I)
    	,posTbl.name(I)
    	,posTbl.language(I)
    	,posTbl.source_language(I)
    	,posTbl.object_version_number(I)
    	,posTbl.partition_id(I)
        ,g_date
        ,g_user_id
        ,g_user_id
        ,g_date
    	,g_request_id
    	,g_prog_appl_id
    	,g_prog_id
    	,g_date
        ,posTbl.attribute_category(I)
        ,posTbl.attribute1(I)
        ,posTbl.attribute2(I)
        ,posTbl.attribute3(I)
        ,posTbl.attribute4(I)
        ,posTbl.attribute5(I)
        ,posTbl.attribute6(I)
        ,posTbl.attribute7(I)
        ,posTbl.attribute8(I)
        ,posTbl.attribute9(I)
        ,posTbl.attribute10(I)
        ,posTbl.attribute11(I)
        ,posTbl.attribute12(I)
        ,posTbl.attribute13(I)
        ,posTbl.attribute14(I)
        ,posTbl.attribute15(I)
        ,posTbl.attribute16(I)
        ,posTbl.attribute17(I)
        ,posTbl.attribute18(I)
        ,posTbl.attribute19(I)
        ,posTbl.attribute20(I)
      );

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in dump_hr_pos: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END dump_hr_pos;

PROCEDURE open_hr_pos(
   p_cursor IN OUT NOCOPY cur_typ
  ,p_mode IN NUMBER
  ,p_eff_date IN DATE
) IS

query_str VARCHAR2(4000);

BEGIN
query_str := 'SELECT '''||g_srcSystem||''', p.position_id, p.business_group_id, oi.org_information9,' ||
                'p.job_id, p.location_id,p.organization_id, p.position_definition_id, ptl.name,'||
                'ptl.language, ptl.source_lang, p.object_version_number,1, p.attribute_category,'||
                'p.attribute1, p.attribute2, p.attribute3, p.attribute4, p.attribute5,p.attribute6,'||
                'p.attribute7, p.attribute8, p.attribute9, p.attribute10, p.attribute11, p.attribute12,'||
                'p.attribute13, p.attribute14, p.attribute15, p.attribute16, p.attribute17, p.attribute18,'||
                'p.attribute19,p.attribute20, p.attribute21, p.attribute22, p.attribute23, p.attribute24,'||
                'p.attribute25, p.attribute26,p.attribute27, p.attribute28, p.attribute29, p.attribute30,'||
                'information_category, information1, information2, information3, information4, information5,'||
                'information6, information7, information8, information9, information10, information11,'||
                'information12, information13, information14, information15, information16, information17,'||
                'information18, information19, information20, information21, information22, information23,'||
                'information24, information25, information26, information27, information28, information29,'||
                'information30 '||
              'FROM hr_all_positions_f p, hr_all_positions_f_tl ptl, hr_organization_information oi '||
              'WHERE p.position_id = ptl.position_id'||
              '  AND :1 between p.effective_start_date AND p.effective_end_date'||
              '  AND p.business_group_id = oi.organization_id'||
              '  AND oi.org_information_context = ''Business Group Information''';
     IF hr_multi_tenancy_pkg.get_system_model = 'B' THEN
       query_str := query_str || '  AND p.position_id NOT IN '||
                             '	(SELECT lp.position_id FROM hr_all_positions_f lp'||
                             '    WHERE label_to_char(lp.HR_ENTERPRISE) = ''C::ENT'' OR label_to_char(lp.HR_ENTERPRISE) is null)';
     END IF;
     IF (p_mode = 0) THEN
      OPEN p_cursor FOR query_str using p_eff_date;
     ELSIF (p_mode = 1) THEN
      query_str := query_str || '  AND EXISTS (SELECT ''e'' FROM per_empdir_positions ip'||
                       ' WHERE ip.orig_system_id = p.position_id'||
                       '   AND ip.orig_system = ''' || g_srcSystem || '''' ||
                       '   AND ip.object_version_number <> p.object_version_number)';
      OPEN p_cursor FOR query_str using p_eff_date;
     ELSIF (p_mode = 2) THEN
      query_str := query_str || '  AND NOT EXISTS (SELECT ''e'' FROM per_empdir_positions ip'||
                       ' WHERE ip.orig_system_id = p.position_id'||
                       '   AND ip.orig_system = ''' || g_srcSystem || ''')';

      OPEN p_cursor FOR query_str using p_eff_date;
     END IF;
END open_hr_pos;

PROCEDURE bulk_process_hr_pos(
   p_mode IN NUMBER
   ,p_cnt OUT NOCOPY NUMBER
   ,errbuf OUT NOCOPY VARCHAR2
   ,retcode OUT NOCOPY VARCHAR2
   ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cursor cur_typ;
l_flg BOOLEAN:= FALSE;

BEGIN

    p_cnt := 0;
    l_flg := per_empdir_LEG_OVERRIDE.isOverrideEnabled('POSITIONS');

    open_hr_pos(
        l_cursor
       ,p_mode
       ,p_eff_date
    );

    LOOP
    BEGIN
      FETCH l_cursor BULK COLLECT INTO
       	 posTbl.orig_system
    	,posTbl.orig_system_id
    	,posTbl.business_group_id
        ,posTbl.legislation_code
    	,posTbl.job_id
    	,posTbl.location_id
    	,posTbl.organization_id
    	,posTbl.position_definition_id
    	,posTbl.name
    	,posTbl.language
    	,posTbl.source_language
    	,posTbl.object_version_number
    	,posTbl.partition_id
        ,posTbl.attribute_category
        ,posTbl.attribute1
        ,posTbl.attribute2
        ,posTbl.attribute3
        ,posTbl.attribute4
        ,posTbl.attribute5
        ,posTbl.attribute6
        ,posTbl.attribute7
        ,posTbl.attribute8
        ,posTbl.attribute9
        ,posTbl.attribute10
        ,posTbl.attribute11
        ,posTbl.attribute12
        ,posTbl.attribute13
        ,posTbl.attribute14
        ,posTbl.attribute15
        ,posTbl.attribute16
        ,posTbl.attribute17
        ,posTbl.attribute18
        ,posTbl.attribute19
        ,posTbl.attribute20
        ,posTbl.attribute21
        ,posTbl.attribute22
        ,posTbl.attribute23
        ,posTbl.attribute24
        ,posTbl.attribute25
        ,posTbl.attribute26
        ,posTbl.attribute27
        ,posTbl.attribute28
        ,posTbl.attribute29
        ,posTbl.attribute30
        ,posTbl.information_category
        ,posTbl.information1
        ,posTbl.information2
        ,posTbl.information3
        ,posTbl.information4
        ,posTbl.information5
        ,posTbl.information6
        ,posTbl.information7
        ,posTbl.information8
        ,posTbl.information9
        ,posTbl.information10
        ,posTbl.information11
        ,posTbl.information12
        ,posTbl.information13
        ,posTbl.information14
        ,posTbl.information15
        ,posTbl.information16
        ,posTbl.information17
        ,posTbl.information18
        ,posTbl.information19
        ,posTbl.information20
        ,posTbl.information21
        ,posTbl.information22
        ,posTbl.information23
        ,posTbl.information24
        ,posTbl.information25
        ,posTbl.information26
        ,posTbl.information27
        ,posTbl.information28
        ,posTbl.information29
        ,posTbl.information30 LIMIT g_commit_size;

        IF posTbl.orig_system.count <= 0 THEN
            CLOSE l_cursor;
            EXIT;
        END IF;

      p_cnt := p_cnt + posTbl.orig_system.count;

      IF l_flg THEN
        per_empdir_leg_override.positions(
                    errbuf => errbuf
                   ,retcode => retcode
                   ,p_eff_date => p_eff_date
                   ,p_cnt => posTbl.orig_system.count
                   ,p_srcsystem => g_srcSystem);
      END IF;

      IF (p_mode = '0' OR p_mode = '2') THEN
               dump_hr_pos(
                 errbuf
                ,retcode
                ,p_eff_date
                ,posTbl.orig_system.count
               );
      ElSIF (p_mode = '1') THEN
               update_hr_pos(
                  errbuf
                 ,retcode
                 ,p_eff_date
                 ,posTbl.orig_system.count
               );
      END IF;

      COMMIT;

      IF l_cursor%NOTFOUND THEN
        CLOSE l_cursor;
        EXIT;
      END IF;

   EXCEPTION
        WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in pos bulk collect: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
   END;
   END LOOP;

   COMMIT;

   EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in bulk_process_per_pos: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END bulk_process_hr_pos;

PROCEDURE dump_per_locations(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE
  ,p_cnt IN NUMBER
) IS
BEGIN
     g_date := trunc(SYSDATE);

     FORALL I IN 1 .. p_cnt
      INSERT INTO per_empdir_locations values (
        locationTbl.orig_system(I)
        ,locationTbl.orig_system_id(I)
        ,locationTbl.business_group_id(I)
        ,locationTbl.derived_locale(I)
        ,locationTbl.tax_name(I)
        ,locationTbl.country(I)
        ,locationTbl.style(I)
        ,locationTbl.address(I)
        ,locationTbl.address_line_1(I)
        ,locationTbl.address_line_2(I)
        ,locationTbl.address_line_3(I)
        ,locationTbl.town_or_city(I)
        ,locationTbl.region_1(I)
        ,locationTbl.region_2(I)
        ,locationTbl.region_3(I)
        ,locationTbl.postal_code(I)
        ,locationTbl.inactive_date(I)
        ,locationTbl.office_site_flag(I)
        ,locationTbl.receiving_site_flag(I)
        ,locationTbl.telephone_number_1(I)
        ,locationTbl.telephone_number_2(I)
        ,locationTbl.telephone_number_3(I)
        ,locationTbl.timezone_id(I)
        ,locationTbl.object_version_number(I)
        ,locationTbl.partition_id(I)
        ,g_date
        ,g_user_id
        ,g_login_id
        ,g_user_id
        ,g_date
        ,g_request_id
        ,g_prog_appl_id
        ,g_prog_id
        ,g_date
        ,locationTbl.timezone_code(I)
      );

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in dump_per_locations: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END dump_per_locations;

PROCEDURE open_per_locations(
   p_cursor IN OUT NOCOPY cur_typ
  ,p_mode IN NUMBER
  ,p_eff_date IN DATE
) IS

query_str VARCHAR2(4000);

BEGIN
query_str := 'SELECT  ''' || g_srcSystem || '''' ||
             '     ,location_id, business_group_id, derived_locale,tax_name' ||
             '     ,country, style, null address, address_line_1, address_line_2' ||
             '     ,address_line_3, town_or_city, region_1, region_2, region_3' ||
             '     ,postal_code, inactive_date, office_site_flag, receiving_site_flag' ||
             '     ,telephone_number_1, telephone_number_2, telephone_number_3' ||
             '     ,null' ||
             '     ,nvl(TIMEZONE_CODE,' ||
             '             per_empdir_SS.get_timezone_code(postal_code,  town_or_city,' ||
             '                       decode(country,''US'',region_2,region_1), country))' ||
             '     ,object_version_number' ||
             '     ,1 ' ||
             ' FROM hr_locations_all l';
     IF (p_mode = 0) THEN
     IF hr_multi_tenancy_pkg.get_system_model = 'B' THEN
       query_str := query_str || '  WHERE label_to_char(HR_ENTERPRISE) <> ''C::ENT''';
     END IF;

      OPEN p_cursor FOR query_str;
     ELSIF (p_mode = 1) THEN
       query_str := query_str || '  WHERE EXISTS (SELECT ''e'' FROM per_empdir_locations il' ||
                      '                 WHERE il.orig_system_id = l.location_id'||
                      '                   AND il.orig_system = ''' || g_srcSystem || '''' ||
                      '                   AND il.object_version_number <> l.object_version_number)';
     IF hr_multi_tenancy_pkg.get_system_model = 'B' THEN
       query_str := query_str || '  AND label_to_char(HR_ENTERPRISE) <> ''C::ENT''';
     END IF;
      OPEN p_cursor FOR query_str;
     ELSIF (p_mode = 2) THEN
       query_str := query_str || '  WHERE NOT EXISTS (SELECT ''e'' FROM per_empdir_locations il' ||
                                 '       WHERE il.orig_system_id = l.location_id' ||
                                 '         AND il.orig_system = ''' || g_srcSystem || ''')';
     IF hr_multi_tenancy_pkg.get_system_model = 'B' THEN
       query_str := query_str || '  AND label_to_char(HR_ENTERPRISE) <> ''C::ENT''';
     END IF;
      OPEN p_cursor FOR query_str;
     END IF;
END open_per_locations;

PROCEDURE update_per_locations(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE
  ,p_cnt IN NUMBER
) IS
BEGIN

     g_date := trunc(SYSDATE);

     FORALL I IN 1 .. p_cnt
       UPDATE per_empdir_locations
       SET orig_system = locationTbl.orig_system(I)
           ,orig_system_id = locationTbl.orig_system_id(I)
           ,business_group_id = locationTbl.business_group_id(I)
           ,derived_locale = locationTbl.derived_locale(I)
           ,tax_name = locationTbl.tax_name(I)
           ,country = locationTbl.country(I)
           ,style = locationTbl.style(I)
           ,address = locationTbl.address(I)
           ,address_line_1 = locationTbl.address_line_1(I)
           ,address_line_2 = locationTbl.address_line_2(I)
           ,address_line_3 = locationTbl.address_line_3(I)
           ,town_or_city = locationTbl.town_or_city(I)
           ,region_1 = locationTbl.region_1(I)
           ,region_2 = locationTbl.region_2(I)
           ,region_3 = locationTbl.region_3(I)
           ,postal_code = locationTbl.postal_code(I)
           ,inactive_date = locationTbl.inactive_date(I)
           ,office_site_flag = locationTbl.office_site_flag(I)
           ,receiving_site_flag = locationTbl.receiving_site_flag(I)
           ,telephone_number_1 = locationTbl.telephone_number_1(I)
           ,telephone_number_2 = locationTbl.telephone_number_2(I)
           ,telephone_number_3 = locationTbl.telephone_number_3(I)
           ,timezone_id = locationTbl.timezone_id(I)
           ,timezone_code = locationTbl.timezone_code(I)
           ,object_version_number = locationTbl.object_version_number(I)
           ,partition_id = locationTbl.partition_id(I)
           ,last_update_date = g_date
           ,last_updated_by = g_user_id
           ,last_update_login = g_login_id
           ,created_by = g_user_id
           ,creation_date = g_date
           ,request_id = g_request_id
           ,program_application_id = g_prog_appl_id
           ,program_id = g_prog_id
           ,program_update_date = g_date
       WHERE orig_system = locationTbl.orig_system(I)
       AND orig_system_id = locationTbl.orig_system_id(I);

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in update_per_locations: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END update_per_locations;

PROCEDURE bulk_process_per_locations(
   p_mode IN NUMBER
   ,p_cnt OUT NOCOPY NUMBER
   ,errbuf OUT NOCOPY VARCHAR2
   ,retcode OUT NOCOPY VARCHAR2
   ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cursor cur_typ;
l_flg BOOLEAN:= FALSE;

BEGIN

    p_cnt := 0;
    l_flg := per_empdir_LEG_OVERRIDE.isOverrideEnabled('LOCATIONS');

    open_per_locations(
        l_cursor
       ,p_mode
       ,p_eff_date
    );

    LOOP
    BEGIN
      FETCH l_cursor BULK COLLECT
       INTO locationTbl.orig_system
           ,locationTbl.orig_system_id
           ,locationTbl.business_group_id
           ,locationTbl.derived_locale
           ,locationTbl.tax_name
           ,locationTbl.country
           ,locationTbl.style
           ,locationTbl.address
           ,locationTbl.address_line_1
           ,locationTbl.address_line_2
           ,locationTbl.address_line_3
           ,locationTbl.town_or_city
           ,locationTbl.region_1
           ,locationTbl.region_2
           ,locationTbl.region_3
           ,locationTbl.postal_code
           ,locationTbl.inactive_date
           ,locationTbl.office_site_flag
           ,locationTbl.receiving_site_flag
           ,locationTbl.telephone_number_1
           ,locationTbl.telephone_number_2
           ,locationTbl.telephone_number_3
           ,locationTbl.timezone_id
           ,locationTbl.timezone_code
           ,locationTbl.object_version_number
           ,locationTbl.partition_id LIMIT g_commit_size;

           IF locationTbl.orig_system.count <= 0 THEN
                CLOSE l_cursor;
                EXIT;
           END IF;

           p_cnt := p_cnt + locationTbl.orig_system.count;

           IF l_flg THEN
            per_empdir_leg_override.locations(
                    errbuf => errbuf
                   ,retcode => retcode
                   ,p_eff_date => p_eff_date
                   ,p_cnt => locationTbl.orig_system.count
                   ,p_srcsystem => g_srcSystem);
           END IF;


           IF (p_mode = '0' OR p_mode = '2') THEN
               dump_per_locations(
                 errbuf
                ,retcode
                ,p_eff_date
                ,locationTbl.orig_system.count
               );
           ElSIF (p_mode = '1') THEN
               update_per_locations(
                  errbuf
                 ,retcode
                 ,p_eff_date
                 ,locationTbl.orig_system.count
               );
           END IF;

           COMMIT;

           IF l_cursor%NOTFOUND THEN
            CLOSE l_cursor;
            EXIT;
           END IF;
     END;
    END LOOP;
    COMMIT;

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in bulk_process_per_locations: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END bulk_process_per_locations;

PROCEDURE update_per_asg(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE
  ,p_cnt IN NUMBER
) IS
BEGIN

     g_date := trunc(SYSDATE);

     FORALL I IN 1 .. p_cnt
      UPDATE per_empdir_assignments
         SET orig_system = asgTbl.orig_system(I)
             ,orig_system_id = asgTbl.orig_system_id(I)
             ,business_group_id  = asgTbl.business_group_id(I)
        	 ,position_id  = asgTbl.position_id(I)
             ,job_id  = asgTbl.job_id(I)
             ,location_id  = asgTbl.location_id(I)
             ,supervisor_id  = asgTbl.supervisor_id(I)
             ,supervisor_assignment_id  = asgTbl.supervisor_assignment_id(I)
             ,person_id  = asgTbl.person_id(I)
        	 ,organization_id  = asgTbl.organization_id(I)
        	 ,primary_flag  = asgTbl.primary_flag(I)
        	 ,active  = asgTbl.active(I)
        	 ,assignment_number  = asgTbl.assignment_number(I)
        	 ,discretionary_title  = asgTbl.discretionary_title(I)
        	 ,employee_category  = asgTbl.employee_category(I)
        	 ,employment_category  = asgTbl.employment_category(I)
        	 ,assignment_category  = asgTbl.assignment_category(I)
        	 ,work_at_home  = asgTbl.work_at_home(I)
        	 ,object_version_number  = asgTbl.object_version_number(I)
        	 ,partition_id  = asgTbl.partition_id(I)
        	 ,request_id  = g_request_id
        	 ,program_application_id  = g_prog_appl_id
        	 ,program_id  = g_prog_id
        	 ,program_update_date  = g_date
        	 ,last_update_date  = g_date
        	 ,last_updated_by  = g_user_id
        	 ,last_update_login  = g_login_id
        	 ,created_by  = g_user_id
        	 ,creation_date  = g_date
        	 ,ass_attribute_category  = asgTbl.ass_attribute_category(I)
        	 ,ass_attribute1  = asgTbl.ass_attribute1(I)
        	 ,ass_attribute2  = asgTbl.ass_attribute2(I)
        	 ,ass_attribute3  = asgTbl.ass_attribute3(I)
        	 ,ass_attribute4  = asgTbl.ass_attribute4(I)
        	 ,ass_attribute5  = asgTbl.ass_attribute5(I)
        	 ,ass_attribute6  = asgTbl.ass_attribute6(I)
        	 ,ass_attribute7  = asgTbl.ass_attribute7(I)
        	 ,ass_attribute8  = asgTbl.ass_attribute8(I)
        	 ,ass_attribute9  = asgTbl.ass_attribute9(I)
        	 ,ass_attribute10  = asgTbl.ass_attribute10(I)
        	 ,ass_attribute11  = asgTbl.ass_attribute11(I)
        	 ,ass_attribute12  = asgTbl.ass_attribute12(I)
        	 ,ass_attribute13  = asgTbl.ass_attribute13(I)
        	 ,ass_attribute14  = asgTbl.ass_attribute14(I)
        	 ,ass_attribute15  = asgTbl.ass_attribute15(I)
        	 ,ass_attribute16  = asgTbl.ass_attribute16(I)
        	 ,ass_attribute17  = asgTbl.ass_attribute17(I)
        	 ,ass_attribute18  = asgTbl.ass_attribute18(I)
        	 ,ass_attribute19  = asgTbl.ass_attribute19(I)
        	 ,ass_attribute20  = asgTbl.ass_attribute20(I)
        	 ,ass_attribute21  = asgTbl.ass_attribute21(I)
        	 ,ass_attribute22  = asgTbl.ass_attribute22(I)
        	 ,ass_attribute23  = asgTbl.ass_attribute23(I)
        	 ,ass_attribute24  = asgTbl.ass_attribute24(I)
        	 ,ass_attribute25  = asgTbl.ass_attribute25(I)
        	 ,ass_attribute26  = asgTbl.ass_attribute26(I)
        	 ,ass_attribute27  = asgTbl.ass_attribute27(I)
        	 ,ass_attribute28  = asgTbl.ass_attribute28(I)
        	 ,ass_attribute29  = asgTbl.ass_attribute29(I)
        	 ,ass_attribute30  = asgTbl.ass_attribute30(I)
       WHERE orig_system = asgTbl.orig_system(I)
       AND orig_system_id = asgTbl.orig_system_id(I);

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in update_per_asg: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END update_per_asg;

PROCEDURE dump_per_asg(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE
  ,p_cnt IN NUMBER
) IS
BEGIN
     g_date := trunc(SYSDATE);

     FORALL I IN 1 .. p_cnt
      INSERT INTO per_empdir_assignments values (
    	    	asgTbl.orig_system(I)
               ,asgTbl.orig_system_id(I)
	       ,asgTbl.business_group_id(I)
	       ,asgTbl.position_id(I)
	       ,asgTbl.job_id(I)
	       ,asgTbl.location_id(I)
	       ,asgTbl.supervisor_id(I)
	       ,asgTbl.supervisor_assignment_id(I)
	       ,asgTbl.person_id(I)
	       ,asgTbl.organization_id(I)
	       ,asgTbl.primary_flag(I)
	       ,asgTbl.active(I)
	       ,asgTbl.assignment_number(I)
	       ,asgTbl.discretionary_title(I)
	       ,asgTbl.employee_category(I)
	       ,asgTbl.employment_category(I)
	       ,asgTbl.assignment_category(I)
	       ,asgTbl.work_at_home(I)
	       ,asgTbl.object_version_number(I)
	       ,asgTbl.partition_id(I)
	       ,g_request_id
	       ,g_prog_appl_id
	       ,g_prog_id
	       ,g_date
	       ,g_date
	       ,g_user_id
	       ,g_login_id
	       ,g_user_id
	       ,g_date
	       ,asgTbl.ass_attribute_category(I)
	       ,asgTbl.ass_attribute1(I)
	       ,asgTbl.ass_attribute2(I)
	       ,asgTbl.ass_attribute3(I)
	       ,asgTbl.ass_attribute4(I)
	       ,asgTbl.ass_attribute5(I)
	       ,asgTbl.ass_attribute6(I)
	       ,asgTbl.ass_attribute7(I)
	       ,asgTbl.ass_attribute8(I)
	       ,asgTbl.ass_attribute9(I)
	       ,asgTbl.ass_attribute10(I)
	       ,asgTbl.ass_attribute11(I)
	       ,asgTbl.ass_attribute12(I)
	       ,asgTbl.ass_attribute13(I)
	       ,asgTbl.ass_attribute14(I)
	       ,asgTbl.ass_attribute15(I)
	       ,asgTbl.ass_attribute16(I)
	       ,asgTbl.ass_attribute17(I)
	       ,asgTbl.ass_attribute18(I)
	       ,asgTbl.ass_attribute19(I)
	       ,asgTbl.ass_attribute20(I)
	       ,asgTbl.ass_attribute21(I)
	       ,asgTbl.ass_attribute22(I)
	       ,asgTbl.ass_attribute23(I)
	       ,asgTbl.ass_attribute24(I)
	       ,asgTbl.ass_attribute25(I)
	       ,asgTbl.ass_attribute26(I)
	       ,asgTbl.ass_attribute27(I)
	       ,asgTbl.ass_attribute28(I)
	       ,asgTbl.ass_attribute29(I)
	       ,asgTbl.ass_attribute30(I)
      );

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in dump_per_asg: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END dump_per_asg;

PROCEDURE open_per_asg(
   p_cursor IN OUT NOCOPY cur_typ
  ,p_mode IN NUMBER
  ,p_eff_date IN DATE
  ,p_multi_asg IN VARCHAR2
) IS

query_str VARCHAR2(4000);
l_multi_asg CHAR(1):=NULL;

BEGIN

     IF (p_multi_asg = 'N') THEN
         l_multi_asg := 'Y';
     END IF;
query_str := 'SELECT ''' || g_srcSystem || ''', paf.assignment_id, paf.business_group_id, oi.org_information9,'||
        'paf.position_id, paf.job_id, paf.location_id, paf.supervisor_id, null,' ||
        'paf.person_id, paf.organization_id, paf.primary_flag,' ||
        'decode (astatus.per_system_status, ''TERM_ASSIGN'', ''N'',' ||
        '        decode(paf.assignment_type, ''E'', ''Y'', ''C'', ''Y'', ''N'')), paf.assignment_number,'||
        'null, paf.employee_category, paf.employment_category, paf.assignment_category,' ||
        'paf.work_at_home, paf.object_version_number, 1,' ||
        'ass_attribute_category, ass_attribute1, ass_attribute2, ass_attribute3,' ||
        'ass_attribute4, ass_attribute5, ass_attribute6, ass_attribute7, ass_attribute8,' ||
        'ass_attribute9, ass_attribute10, ass_attribute11, ass_attribute12, ass_attribute13,'||
        'ass_attribute14, ass_attribute15, ass_attribute16, ass_attribute17, ass_attribute18,'||
        'ass_attribute19, ass_attribute20, ass_attribute21, ass_attribute22, ass_attribute23,'||
        'ass_attribute24, ass_attribute25, ass_attribute26, ass_attribute27, ass_attribute28,'||
        'ass_attribute29, ass_attribute30 '||
      ' FROM per_assignments_f paf, per_assignment_status_types astatus' ||
      '    ,hr_organization_information oi '||
      ' WHERE :1 BETWEEN effective_start_date AND effective_end_date'||
      '   AND paf.assignment_status_type_id = astatus.assignment_status_type_id'||
      '   AND paf.business_group_id = oi.organization_id'||
      '   AND oi.org_information_context = ''Business Group Information'''||
      '   AND paf.primary_flag = nvl(:2,paf.primary_flag)'||
      ' /* Avoiding PK Violation */ '||
      '   AND paf.assignment_id NOT IN '||
      '         (SELECT assignment_id FROM per_all_assignments_f ipaf' ||
      '         WHERE :3 BETWEEN effective_start_date AND effective_end_date'||
      '         GROUP BY assignment_id HAVING count(*) > 1)'||
      ' AND paf.assignment_type in (''E'',''C'')';

    IF hr_multi_tenancy_pkg.get_system_model = 'B' THEN
       query_str := query_str || '  AND paf.assignment_id NOT IN '||
                             '	(SELECT assignment_id FROM per_all_assignments_f lpaf'||
                             '    WHERE label_to_char(lpaf.HR_ENTERPRISE) = ''C::ENT'' OR label_to_char(lpaf.HR_ENTERPRISE) is null)';
     END IF;

     IF (p_mode = 0) THEN
      query_str := query_str || '  AND astatus.per_system_status <> ''TERM_ASSIGN''';
      OPEN p_cursor FOR query_str using p_eff_date,l_multi_asg,p_eff_date;
     ELSIF (p_mode = 1) THEN
      query_str := query_str || '  AND EXISTS (SELECT ''e'' from per_empdir_assignments ia '||
                             ' WHERE ia.orig_system_id = paf.assignment_id'||
                             '   AND ia.orig_system = ''' || g_srcSystem || ''''||
                             '   AND (ia.object_version_number <> paf.object_version_number '||
                             '   OR paf.effective_start_date >= ia.last_update_date ))';
      OPEN p_cursor FOR query_str using p_eff_date,l_multi_asg,p_eff_date;
     ELSIF (p_mode = 2) THEN
      query_str := query_str || '  AND astatus.per_system_status <> ''TERM_ASSIGN'''||
                                '  AND NOT EXISTS (SELECT ''e'' from per_empdir_assignments ia'||
                                '        WHERE ia.orig_system_id = paf.assignment_id'||
                                '          AND ia.orig_system = ''' || g_srcSystem|| ''')';
      OPEN p_cursor FOR query_str using p_eff_date,l_multi_asg,p_eff_date;
     END IF;
END open_per_asg;

PROCEDURE bulk_process_per_asg(
   p_mode IN NUMBER
   ,p_cnt OUT NOCOPY NUMBER
   ,errbuf OUT NOCOPY VARCHAR2
   ,retcode OUT NOCOPY VARCHAR2
   ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
   ,p_multi_asg IN VARCHAR2
) IS

l_cursor cur_typ;
l_flg BOOLEAN:= FALSE;

BEGIN

    p_cnt := 0;
    l_flg := per_empdir_LEG_OVERRIDE.isOverrideEnabled('ASSIGNMENTS');

    open_per_asg(
        l_cursor
       ,p_mode
       ,p_eff_date
       ,p_multi_asg
    );

    LOOP
    BEGIN
      FETCH l_cursor BULK COLLECT
       INTO asgTbl.orig_system
           ,asgTbl.orig_system_id
	       ,asgTbl.business_group_id
	       ,asgTbl.legislation_code
	       ,asgTbl.position_id
	       ,asgTbl.job_id
	       ,asgTbl.location_id
	       ,asgTbl.supervisor_id
	       ,asgTbl.supervisor_assignment_id
	       ,asgTbl.person_id
	       ,asgTbl.organization_id
	       ,asgTbl.primary_flag
	       ,asgTbl.active
	       ,asgTbl.assignment_number
	       ,asgTbl.discretionary_title
	       ,asgTbl.employee_category
	       ,asgTbl.employment_category
	       ,asgTbl.assignment_category
	       ,asgTbl.work_at_home
	       ,asgTbl.object_version_number
	       ,asgTbl.partition_id
	       ,asgTbl.ass_attribute_category
	       ,asgTbl.ass_attribute1
	       ,asgTbl.ass_attribute2
	       ,asgTbl.ass_attribute3
	       ,asgTbl.ass_attribute4
	       ,asgTbl.ass_attribute5
	       ,asgTbl.ass_attribute6
	       ,asgTbl.ass_attribute7
	       ,asgTbl.ass_attribute8
	       ,asgTbl.ass_attribute9
	       ,asgTbl.ass_attribute10
	       ,asgTbl.ass_attribute11
	       ,asgTbl.ass_attribute12
	       ,asgTbl.ass_attribute13
	       ,asgTbl.ass_attribute14
	       ,asgTbl.ass_attribute15
	       ,asgTbl.ass_attribute16
	       ,asgTbl.ass_attribute17
	       ,asgTbl.ass_attribute18
	       ,asgTbl.ass_attribute19
	       ,asgTbl.ass_attribute20
	       ,asgTbl.ass_attribute21
	       ,asgTbl.ass_attribute22
	       ,asgTbl.ass_attribute23
	       ,asgTbl.ass_attribute24
	       ,asgTbl.ass_attribute25
	       ,asgTbl.ass_attribute26
	       ,asgTbl.ass_attribute27
	       ,asgTbl.ass_attribute28
	       ,asgTbl.ass_attribute29
	       ,asgTbl.ass_attribute30 LIMIT g_commit_size;

           IF asgTbl.orig_system.count <= 0 THEN
                CLOSE l_cursor;
                EXIT;
           END IF;

           p_cnt := p_cnt + asgTbl.orig_system.count;

           IF l_flg THEN
            per_empdir_leg_override.asg(
                    errbuf => errbuf
                   ,retcode => retcode
                   ,p_eff_date => p_eff_date
                   ,p_cnt => asgTbl.orig_system.count
                   ,p_srcsystem => g_srcSystem);
           END IF;

           IF (p_mode = '0' OR p_mode = '2') THEN
               dump_per_asg(
                 errbuf
                ,retcode
                ,p_eff_date
                ,asgTbl.orig_system.count
               );
           ElSIF (p_mode = '1') THEN
               update_per_asg(
                  errbuf
                 ,retcode
                 ,p_eff_date
                 ,asgTbl.orig_system.count
               );
           END IF;

           COMMIT;

           IF l_cursor%NOTFOUND THEN
            CLOSE l_cursor;
            EXIT;
           END IF;
     END;
    END LOOP;
    COMMIT;

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in bulk_process_per_asg: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END bulk_process_per_asg;



PROCEDURE update_hr_orgs(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE
  ,p_cnt IN NUMBER
) IS
BEGIN

     g_date := trunc(SYSDATE);

     FORALL I IN 1 .. p_cnt
      UPDATE per_empdir_organizations
      SET orig_system = orgTbl.orig_system(I)
         ,orig_system_id = orgTbl.orig_system_id(I)
    	 ,business_group_id = orgTbl.business_group_id(I)
    	 ,location_id	= orgTbl.location_id(I)
         ,representative1_id = orgTbl.representative1_id(I)
         ,representative2_id = orgTbl.representative1_id(I)
         ,representative3_id = orgTbl.representative1_id(I)
         ,representative4_id = orgTbl.representative1_id(I)
    	 ,name = orgTbl.name(I)
    	 ,language = orgTbl.language(I)
    	 ,source_lang = orgTbl.source_lang(I)
    	 ,object_version_number = orgTbl.object_version_number(I)
    	 ,partition_id = orgTbl.partition_id(I)
    	 ,last_update_date = g_date
    	 ,last_update_by = g_user_id
    	 ,created_by = g_user_id
    	 ,creation_date = g_date
    	 ,request_id  = g_request_id
    	 ,program_application_id = g_prog_appl_id
    	 ,program_id = g_prog_id
    	 ,program_update_date = g_date
    	 ,attribute_category  = orgTbl.attribute_category(I)
    	 ,attribute1  = orgTbl.attribute1(I)
    	 ,attribute2  = orgTbl.attribute2(I)
    	 ,attribute3  = orgTbl.attribute3(I)
    	 ,attribute4  = orgTbl.attribute4(I)
    	 ,attribute5  = orgTbl.attribute5(I)
    	 ,attribute6  = orgTbl.attribute6(I)
    	 ,attribute7  = orgTbl.attribute7(I)
    	 ,attribute8  = orgTbl.attribute8(I)
    	 ,attribute9  = orgTbl.attribute9(I)
    	 ,attribute10  = orgTbl.attribute10(I)
    	 ,attribute11  = orgTbl.attribute11(I)
    	 ,attribute12  = orgTbl.attribute12(I)
    	 ,attribute13  = orgTbl.attribute13(I)
    	 ,attribute14  = orgTbl.attribute14(I)
    	 ,attribute15  = orgTbl.attribute15(I)
    	 ,attribute16  = orgTbl.attribute16(I)
    	 ,attribute17  = orgTbl.attribute17(I)
    	 ,attribute18  = orgTbl.attribute18(I)
    	 ,attribute19  = orgTbl.attribute19(I)
    	 ,attribute20  = orgTbl.attribute20(I)
       WHERE orig_system = orgTbl.orig_system(I)
       AND orig_system_id = orgTbl.orig_system_id(I)
       AND language = orgTbl.language(I);

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in update_hr_orgs: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END update_hr_orgs;

PROCEDURE dump_hr_orgs(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE
  ,p_cnt IN NUMBER
) IS
BEGIN
     g_date := trunc(SYSDATE);

     FORALL I IN 1 .. p_cnt
      INSERT INTO per_empdir_organizations values (
    	    orgTbl.orig_system(I)
           ,orgTbl.orig_system_id(I)
           ,orgTbl.business_group_id(I)
           ,orgTbl.location_id(I)
           ,orgTbl.representative1_id(I)
           ,orgTbl.representative2_id(I)
           ,orgTbl.representative3_id(I)
           ,orgTbl.representative4_id(I)
           ,orgTbl.name(I)
           ,orgTbl.language(I)
           ,orgTbl.source_lang(I)
           ,orgTbl.object_version_number(I)
           ,orgTbl.partition_id(I)
           ,g_date
           ,g_user_id
           ,g_user_id
           ,g_date
           ,g_request_id
           ,g_prog_appl_id
           ,g_prog_id
           ,g_date
           ,orgTbl.attribute_category(I)
           ,orgTbl.attribute1(I)
           ,orgTbl.attribute2(I)
           ,orgTbl.attribute3(I)
           ,orgTbl.attribute4(I)
           ,orgTbl.attribute5(I)
           ,orgTbl.attribute6(I)
           ,orgTbl.attribute7(I)
           ,orgTbl.attribute8(I)
           ,orgTbl.attribute9(I)
           ,orgTbl.attribute10(I)
           ,orgTbl.attribute11(I)
           ,orgTbl.attribute12(I)
           ,orgTbl.attribute13(I)
           ,orgTbl.attribute14(I)
           ,orgTbl.attribute15(I)
           ,orgTbl.attribute16(I)
           ,orgTbl.attribute17(I)
           ,orgTbl.attribute18(I)
           ,orgTbl.attribute19(I)
           ,orgTbl.attribute20(I)
      );

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in dump_hr_orgs: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END dump_hr_orgs;

PROCEDURE open_hr_orgs(
   p_cursor IN OUT NOCOPY cur_typ
  ,p_mode IN NUMBER
  ,p_eff_date IN DATE
) IS

query_str VARCHAR2(4000);

BEGIN
query_str := 'SELECT '''||g_srcSystem||''', hou.organization_id,hou.business_group_id,oi.org_information9,'||
                'hou.location_id,null rep1,null rep2,null rep3,null rep4,houtl.name,houtl.language,'||
                'houtl.source_lang,hou.object_version_number,1,hou.attribute_category, hou.attribute1,'||
                'hou.attribute2, hou.attribute3, hou.attribute4, hou.attribute5, hou.attribute6,'||
                'hou.attribute7, hou.attribute8, hou.attribute9, hou.attribute10, hou.attribute11,'||
                'hou.attribute12, hou.attribute13,hou.attribute14, hou.attribute15, hou.attribute16,'||
                'hou.attribute17, hou.attribute18, hou.attribute19, hou.attribute20 '||
              'FROM hr_all_organization_units hou, hr_all_organization_units_tl houtl ,'||
                    'hr_organization_information oi '||
              'WHERE hou.organization_id = houtl.organization_id'||
              '  AND hou.business_group_id = oi.organization_id'||
              '  AND oi.org_information_context = ''Business Group Information'''||
              ' /* Avoiding PK Violation */'||
              '  AND houtl.organization_id NOT IN '||
              '	(SELECT organization_id FROM hr_all_organization_units ihou'||
              '    GROUP BY organization_id HAVING count(*) > 1)';
     IF hr_multi_tenancy_pkg.get_system_model = 'B' THEN
       query_str := query_str || '  AND houtl.organization_id NOT IN '||
                             '	(SELECT organization_id FROM hr_all_organization_units lhou'||
                             '    WHERE label_to_char(lhou.HR_ENTERPRISE) = ''C::ENT'' OR label_to_char(lhou.HR_ENTERPRISE) is null)';
     END IF;
     IF (p_mode = 0) THEN
      OPEN p_cursor FOR query_str;
     ELSIF (p_mode = 1) THEN
      query_str := query_str || ' AND EXISTS (SELECT ''e'' FROM per_empdir_organizations io '||
                      ' WHERE io.orig_system_id = hou.organization_id' ||
                      '   AND io.orig_system = ''' || g_srcSystem || '''' ||
                      '   AND io.object_version_number <> hou.object_version_number)';
      OPEN p_cursor FOR query_str;
     ELSIF (p_mode = 2) THEN
      query_str := query_str || ' AND NOT EXISTS (SELECT ''e'' FROM per_empdir_organizations io '||
                      ' WHERE io.orig_system_id = houtl.organization_id'||
                      '   AND io.orig_system = ''' || g_srcSystem || ''')';

       OPEN p_cursor FOR query_str;
     END IF;
END open_hr_orgs;

PROCEDURE bulk_process_hr_orgs(
   p_mode IN NUMBER
   ,p_cnt OUT NOCOPY NUMBER
   ,errbuf OUT NOCOPY VARCHAR2
   ,retcode OUT NOCOPY VARCHAR2
   ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cursor cur_typ;
l_flg BOOLEAN:= FALSE;

BEGIN

    p_cnt := 0;
    l_flg := per_empdir_LEG_OVERRIDE.isOverrideEnabled('ORGANIZATIONS');

    open_hr_orgs(
        l_cursor
       ,p_mode
       ,p_eff_date
    );

    LOOP
    BEGIN
      FETCH l_cursor BULK COLLECT
       INTO orgTbl.orig_system
           ,orgTbl.orig_system_id
           ,orgTbl.business_group_id
           ,orgTbl.legislation_code
           ,orgTbl.location_id
           ,orgTbl.representative1_id
           ,orgTbl.representative2_id
           ,orgTbl.representative3_id
           ,orgTbl.representative4_id
           ,orgTbl.name
           ,orgTbl.language
           ,orgTbl.source_lang
           ,orgTbl.object_version_number
           ,orgTbl.partition_id
           ,orgTbl.attribute_category
           ,orgTbl.attribute1
           ,orgTbl.attribute2
           ,orgTbl.attribute3
           ,orgTbl.attribute4
           ,orgTbl.attribute5
           ,orgTbl.attribute6
           ,orgTbl.attribute7
           ,orgTbl.attribute8
           ,orgTbl.attribute9
           ,orgTbl.attribute10
           ,orgTbl.attribute11
           ,orgTbl.attribute12
           ,orgTbl.attribute13
           ,orgTbl.attribute14
           ,orgTbl.attribute15
           ,orgTbl.attribute16
           ,orgTbl.attribute17
           ,orgTbl.attribute18
           ,orgTbl.attribute19
           ,orgTbl.attribute20 LIMIT g_commit_size;

           IF orgTbl.orig_system.count <= 0 THEN
                CLOSE l_cursor;
                EXIT;
           END IF;

           p_cnt := p_cnt + orgTbl.orig_system.count;

           IF l_flg THEN
            per_empdir_leg_override.orgs(
                    errbuf => errbuf
                   ,retcode => retcode
                   ,p_eff_date => p_eff_date
                   ,p_cnt => orgTbl.orig_system.count
                   ,p_srcsystem => g_srcSystem);
           END IF;


           IF (p_mode = '0' OR p_mode = '2') THEN
               dump_hr_orgs(
                 errbuf
                ,retcode
                ,p_eff_date
                ,orgTbl.orig_system.count
               );
           ElSIF (p_mode = '1') THEN
               update_hr_orgs(
                  errbuf
                 ,retcode
                 ,p_eff_date
                 ,orgTbl.orig_system.count
               );
           END IF;

           COMMIT;

           IF l_cursor%NOTFOUND THEN
            CLOSE l_cursor;
            EXIT;
           END IF;
     END;
    END LOOP;
    COMMIT;

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in bulk_process_hr_orgs: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END bulk_process_hr_orgs;

PROCEDURE update_per_jobs(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE
  ,p_cnt IN NUMBER
) IS
BEGIN

     g_date := trunc(SYSDATE);

     FORALL I IN 1 .. p_cnt
      UPDATE per_empdir_jobs
      SET orig_system = jobTbl.orig_system(I)
         ,orig_system_id = jobTbl.orig_system_id(I)
         ,business_group_id = jobTbl.business_group_id(I)
         ,name = jobTbl.name(I)
         ,language = jobTbl.language(I)
         ,source_lang = jobTbl.source_language(I)
         ,object_version_number = jobTbl.object_version_number(I)
         ,partition_id = jobTbl.partition_id(I)
         ,last_update_date = g_date
         ,last_update_by = g_user_id
         ,created_by = g_user_id
         ,creation_date = g_date
         ,request_id = g_request_id
         ,program_application_id = g_prog_appl_id
         ,program_id = g_prog_id
         ,program_update_date = g_date
       WHERE orig_system = jobTbl.orig_system(I)
       AND orig_system_id = jobTbl.orig_system_id(I)
       AND language = jobTbl.language(I);

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in update_per_jobs: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END update_per_jobs;

PROCEDURE open_per_jobs(
   p_cursor IN OUT NOCOPY cur_typ
  ,p_mode IN NUMBER
  ,p_eff_date IN DATE
  ,p_slist IN VARCHAR2
  ,p_busGrpId IN NUMBER
) IS

query_str VARCHAR2(4000);

BEGIN
    query_str := 'SELECT '''||g_srcSystem||''', j.job_id, j.business_group_id, oi.org_information9, j.job_definition_id, '||
                 'jtl.name, '||p_slist||' title, jtl.language, jtl.source_lang, j.object_version_number, 1, '||
                 'j.attribute_category, j.attribute1, j.attribute2, j.attribute3, j.attribute4, j.attribute5, '||
                 'j.attribute6, j.attribute7, j.attribute8, j.attribute9, j.attribute10,j.attribute11, '||
                 'j.attribute12, j.attribute13, j.attribute14, j.attribute15, j.attribute16, j.attribute17, '||
                 'j.attribute18, j.attribute19, j.attribute20, job_information_category, job_information1, '||
                 'job_information2, job_information3, job_information4, job_information5, '||
                 'job_information6, job_information7, job_information8, job_information9, '||
                 'job_information10, job_information11, job_information12, job_information13, '||
                 'job_information14, job_information15, job_information16, job_information17, '||
                 'job_information18, job_information19, job_information20 '||
                 'FROM per_jobs j, per_jobs_tl jtl, per_job_definitions jd '||
                      ',hr_organization_information oi '||
                 'WHERE j.job_id = jtl.job_id '||
                 'AND j.job_definition_id = jd.job_definition_id '||
                 'AND jtl.name is not null '||
                 'AND j.business_group_id = :1 '||
                 'AND j.business_group_id = oi.organization_id '||
                 'AND oi.org_information_context = ''Business Group Information''';
    IF hr_multi_tenancy_pkg.get_system_model = 'B' THEN
       query_str := query_str || '  AND j.job_id NOT IN '||
                             '	(SELECT job_id FROM per_jobs lj'||
                             '    WHERE label_to_char(lj.HR_ENTERPRISE) = ''C::ENT'' OR label_to_char(lj.HR_ENTERPRISE) is null)';
     END IF;
     IF (p_mode = 0) THEN
      OPEN p_cursor FOR query_str USING p_busGrpId;
     ELSIF (p_mode = 1) THEN
      query_str := query_str ||
        'AND EXISTS (SELECT ''e'' from per_empdir_jobs ij '||
        'WHERE ij.orig_system_id = j.job_id '||
        'AND ij.orig_system = '''||g_srcSystem||''' '||
        'AND ij.object_version_number <> j.object_version_number) ';
      OPEN p_cursor FOR query_str USING p_busGrpId;
     ELSIF (p_mode = 2) THEN
      query_str := query_str ||
        'AND NOT EXISTS (SELECT ''e'' from per_empdir_jobs ij '||
        'WHERE ij.orig_system_id = j.job_id '||
        'AND ij.orig_system = '''||g_srcSystem||''') ';
      OPEN p_cursor FOR query_str USING p_busGrpId;
     END IF;
END open_per_jobs;

PROCEDURE bulk_process_per_jobs(
   p_mode IN NUMBER
   ,p_cnt OUT NOCOPY NUMBER
   ,errbuf OUT NOCOPY VARCHAR2
   ,retcode OUT NOCOPY VARCHAR2
   ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
   ,p_slist IN VARCHAR2
   ,p_busGrpId IN NUMBER
) IS

l_cursor cur_typ;
l_flg BOOLEAN:= FALSE;
l_index NUMBER:= 1;
BEGIN

    p_cnt := 0;
    l_flg := per_empdir_LEG_OVERRIDE.isOverrideEnabled('JOBS');

    open_per_jobs(
        l_cursor
       ,p_mode
       ,p_eff_date
       ,p_slist
       ,p_busGrpId
    );

    LOOP
    BEGIN
        IF g_oracle_db_version >= 9 THEN
          FETCH l_cursor BULK COLLECT INTO
             jobTbl.orig_system
            ,jobTbl.orig_system_id
            ,jobTbl.business_group_id
            ,jobTbl.legislation_code
            ,jobTbl.job_definition_id
            ,jobTbl.name
            ,jobTbl.display_name
            ,jobTbl.language
            ,jobTbl.source_language
            ,jobTbl.object_version_number
            ,jobTbl.partition_id
            ,jobTbl.attribute_category
            ,jobTbl.attribute1
            ,jobTbl.attribute2
            ,jobTbl.attribute3
            ,jobTbl.attribute4
            ,jobTbl.attribute5
            ,jobTbl.attribute6
            ,jobTbl.attribute7
            ,jobTbl.attribute8
            ,jobTbl.attribute9
            ,jobTbl.attribute10
            ,jobTbl.attribute11
            ,jobTbl.attribute12
            ,jobTbl.attribute13
            ,jobTbl.attribute14
            ,jobTbl.attribute15
            ,jobTbl.attribute16
            ,jobTbl.attribute17
            ,jobTbl.attribute18
            ,jobTbl.attribute19
            ,jobTbl.attribute20
            ,jobTbl.job_information_category
            ,jobTbl.job_information1
            ,jobTbl.job_information2
            ,jobTbl.job_information
            ,jobTbl.job_information4
            ,jobTbl.job_information5
            ,jobTbl.job_information6
            ,jobTbl.job_information7
            ,jobTbl.job_information8
            ,jobTbl.job_information9
            ,jobTbl.job_information10
            ,jobTbl.job_information11
            ,jobTbl.job_information12
            ,jobTbl.job_information13
            ,jobTbl.job_information14
            ,jobTbl.job_information15
            ,jobTbl.job_information16
            ,jobTbl.job_information17
            ,jobTbl.job_information18
            ,jobTbl.job_information19
            ,jobTbl.job_information20 LIMIT g_commit_size;
          ELSE
            l_index := 1;
            jobTbl := null;
            LOOP FETCH l_cursor INTO
                     jobTbl.orig_system(l_index)
                    ,jobTbl.orig_system_id(l_index)
                    ,jobTbl.business_group_id(l_index)
                    ,jobTbl.legislation_code(l_index)
                    ,jobTbl.job_definition_id(l_index)
                    ,jobTbl.name(l_index)
                    ,jobTbl.display_name(l_index)
                    ,jobTbl.language(l_index)
                    ,jobTbl.source_language(l_index)
                    ,jobTbl.object_version_number(l_index)
                    ,jobTbl.partition_id(l_index)
                    ,jobTbl.attribute_category(l_index)
                    ,jobTbl.attribute1(l_index)
                    ,jobTbl.attribute2(l_index)
                    ,jobTbl.attribute3(l_index)
                    ,jobTbl.attribute4(l_index)
                    ,jobTbl.attribute5(l_index)
                    ,jobTbl.attribute6(l_index)
                    ,jobTbl.attribute7(l_index)
                    ,jobTbl.attribute8(l_index)
                    ,jobTbl.attribute9(l_index)
                    ,jobTbl.attribute10(l_index)
                    ,jobTbl.attribute11(l_index)
                    ,jobTbl.attribute12(l_index)
                    ,jobTbl.attribute13(l_index)
                    ,jobTbl.attribute14(l_index)
                    ,jobTbl.attribute15(l_index)
                    ,jobTbl.attribute16(l_index)
                    ,jobTbl.attribute17(l_index)
                    ,jobTbl.attribute18(l_index)
                    ,jobTbl.attribute19(l_index)
                    ,jobTbl.attribute20(l_index)
                    ,jobTbl.job_information_category(l_index)
                    ,jobTbl.job_information1(l_index)
                    ,jobTbl.job_information2(l_index)
                    ,jobTbl.job_information(l_index)
                    ,jobTbl.job_information4(l_index)
                    ,jobTbl.job_information5(l_index)
                    ,jobTbl.job_information6(l_index)
                    ,jobTbl.job_information7(l_index)
                    ,jobTbl.job_information8(l_index)
                    ,jobTbl.job_information9(l_index)
                    ,jobTbl.job_information10(l_index)
                    ,jobTbl.job_information11(l_index)
                    ,jobTbl.job_information12(l_index)
                    ,jobTbl.job_information13(l_index)
                    ,jobTbl.job_information14(l_index)
                    ,jobTbl.job_information15(l_index)
                    ,jobTbl.job_information16(l_index)
                    ,jobTbl.job_information17(l_index)
                    ,jobTbl.job_information18(l_index)
                    ,jobTbl.job_information19(l_index)
                    ,jobTbl.job_information20(l_index);

                    EXIT WHEN l_cursor%NOTFOUND;
                    l_index := l_index + 1;
            END LOOP;
        END IF;

        IF jobTbl.orig_system.count <= 0 THEN
            CLOSE l_cursor;
            EXIT;
        END IF;

      p_cnt := p_cnt + jobTbl.orig_system.count;

      IF l_flg THEN
        per_empdir_leg_override.jobs(
                    errbuf => errbuf
                   ,retcode => retcode
                   ,p_eff_date => p_eff_date
                   ,p_cnt => jobTbl.orig_system.count
                   ,p_srcsystem => g_srcSystem);
      END IF;


      IF (p_mode = '0' OR p_mode = '2') THEN
               dump_per_jobs(
                 errbuf
                ,retcode
                ,jobTbl.orig_system.count
               );
      ElSIF (p_mode = '1') THEN
               update_per_jobs(
                  errbuf
                 ,retcode
                 ,p_eff_date
                 ,jobTbl.orig_system.count
               );
      END IF;

      COMMIT;

      IF l_cursor%NOTFOUND THEN
        CLOSE l_cursor;
        EXIT;
      END IF;

   EXCEPTION
        WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in jobs bulk collect: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
   END;
   END LOOP;

   COMMIT;

   EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in bulk_process_per_jobs: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END bulk_process_per_jobs;

PROCEDURE dump_per_people(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE
  ,p_cnt IN NUMBER
) IS
BEGIN

     g_date := trunc(SYSDATE);

     FORALL I IN 1 .. p_cnt
      INSERT INTO per_empdir_people values (
             personTbl.person_key(I)
            ,personTbl.orig_system(I)
            ,personTbl.orig_sytem_id(I)
            ,personTbl.business_group_id(I)
            ,personTbl.legislation_code(I)
            ,personTbl.display_name(I)
            ,personTbl.full_name(I)
            ,personTbl.full_name_alternate(I)
            ,personTbl.last_name(I)
            ,personTbl.first_name(I)
            ,personTbl.last_name_alternate(I)
            ,personTbl.first_name_alternate(I)
            ,personTbl.pre_name_adjunct(I)
            ,personTbl.person_type(I)
            ,personTbl.user_name(I)
            ,personTbl.active(I)
            ,personTbl.employee_number(I)
            ,personTbl.known_as(I)
            ,personTbl.middle_names(I)
            ,personTbl.previous_last_name(I)
            ,personTbl.start_date(I)
            ,personTbl.original_DOH(I)
            ,personTbl.email_address(I)
            ,personTbl.work_telephone(I)
            ,personTbl.mailstop(I)
            ,personTbl.office_number(I)
            ,personTbl.order_name(I)
            ,personTbl.partition_id(I)
            ,personTbl.object_version_number(I)
            ,personTbl.global_person_id(I)
            ,personTbl.party_id(I)
            ,g_request_id
            ,g_prog_appl_id
            ,g_prog_id
            ,g_date
            ,g_date
            ,g_user_id
            ,g_login_id
            ,g_user_id
            ,g_date
            ,personTbl.attribute_category(I)
            ,personTbl.attribute1(I)
            ,personTbl.attribute2(I)
            ,personTbl.attribute3(I)
            ,personTbl.attribute4(I)
            ,personTbl.attribute5(I)
            ,personTbl.attribute6(I)
            ,personTbl.attribute7(I)
            ,personTbl.attribute8(I)
            ,personTbl.attribute9(I)
            ,personTbl.attribute10(I)
            ,personTbl.attribute11(I)
            ,personTbl.attribute12(I)
            ,personTbl.attribute13(I)
            ,personTbl.attribute14(I)
            ,personTbl.attribute15(I)
            ,personTbl.attribute16(I)
            ,personTbl.attribute17(I)
            ,personTbl.attribute18(I)
            ,personTbl.attribute19(I)
            ,personTbl.attribute20(I)
            ,personTbl.attribute21(I)
            ,personTbl.attribute22(I)
            ,personTbl.attribute23(I)
            ,personTbl.attribute24(I)
            ,personTbl.attribute25(I)
            ,personTbl.attribute26(I)
            ,personTbl.attribute27(I)
            ,personTbl.attribute28(I)
            ,personTbl.attribute29(I)
            ,personTbl.attribute30(I)
            ,personTbl.per_information_category(I)
            ,personTbl.per_information1(I)
            ,personTbl.per_information2(I)
            ,personTbl.per_information3(I)
            ,personTbl.per_information4(I)
            ,personTbl.per_information5(I)
            ,personTbl.per_information6(I)
            ,personTbl.per_information7(I)
            ,personTbl.per_information8(I)
            ,personTbl.per_information9(I)
            ,personTbl.per_information10(I)
            ,personTbl.per_information11(I)
            ,personTbl.per_information12(I)
            ,personTbl.per_information13(I)
            ,personTbl.per_information14(I)
            ,personTbl.per_information15(I)
            ,personTbl.per_information16(I)
            ,personTbl.per_information17(I)
            ,personTbl.per_information18(I)
            ,personTbl.per_information19(I)
            ,personTbl.per_information20(I)
            ,personTbl.per_information21(I)
            ,personTbl.per_information22(I)
            ,personTbl.per_information23(I)
            ,personTbl.per_information24(I)
            ,personTbl.per_information25(I)
            ,personTbl.per_information26(I)
            ,personTbl.per_information27(I)
            ,personTbl.per_information28(I)
            ,personTbl.per_information29(I)
            ,personTbl.per_information30(I)
            ,personTbl.direct_reports(I)
            ,personTbl.total_reports(I)
            );

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in dump_per_people: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END dump_per_people;

PROCEDURE update_per_people(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE
  ,p_cnt IN NUMBER
) IS
BEGIN

     g_date := trunc(SYSDATE);

     FORALL I IN 1 .. p_cnt
      UPDATE per_empdir_people
      SET person_key =  personTbl.person_key(I)
          ,orig_system = personTbl.orig_system(I)
          ,orig_system_id = personTbl.orig_sytem_id(I)
          ,business_group_id = personTbl.business_group_id(I)
          ,legislation_code = personTbl.legislation_code(I)
          ,display_name = personTbl.display_name(I)
          ,full_name = personTbl.full_name(I)
          ,full_name_alternate = personTbl.full_name_alternate(I)
          ,last_name = personTbl.last_name(I)
          ,first_name = personTbl.first_name(I)
          ,last_name_alternate = personTbl.last_name_alternate(I)
          ,first_name_alternate = personTbl.first_name_alternate(I)
          ,pre_name_adjunct = personTbl.pre_name_adjunct(I)
          ,person_type = personTbl.person_type(I)
          ,user_name = personTbl.user_name(I)
          ,active = personTbl.active(I)
          ,employee_number = personTbl.employee_number(I)
          ,known_as = personTbl.known_as(I)
          ,middle_names = personTbl.middle_names(I)
          ,previous_last_name = personTbl.previous_last_name(I)
          ,start_date = personTbl.start_date(I)
          ,original_date_of_hire = persontbl.original_doh(i)
          ,email_address = personTbl.email_address(I)
          ,work_telephone = personTbl.work_telephone(I)
          ,mailstop = personTbl.mailstop(I)
          ,office_number = personTbl.office_number(I)
          ,order_name = personTbl.order_name(I)
          ,partition_id = personTbl.partition_id(I)
          ,object_version_number = personTbl.object_version_number(I)
          ,global_person_id = personTbl.global_person_id(I)
          ,party_id = personTbl.party_id(I)
          ,request_id = g_request_id
          ,program_application_id = g_prog_appl_id
          ,program_id = g_prog_id
          ,program_update_date = g_date
          ,last_update_date = g_date
          ,last_updated_by = g_user_id
          ,last_update_login = g_login_id
          ,created_by = g_user_id
          ,creation_date = g_date
          ,attribute_category = personTbl.attribute_category(I)
          ,attribute1 = personTbl.attribute1(I)
          ,attribute2 = personTbl.attribute2(I)
          ,attribute3 = personTbl.attribute3(I)
          ,attribute4 = personTbl.attribute4(I)
          ,attribute5 = personTbl.attribute5(I)
          ,attribute6 = personTbl.attribute6(I)
          ,attribute7 = personTbl.attribute7(I)
          ,attribute8 = personTbl.attribute8(I)
          ,attribute9 = personTbl.attribute9(I)
          ,attribute10 = personTbl.attribute10(I)
          ,attribute11 = personTbl.attribute11(I)
          ,attribute12 = personTbl.attribute12(I)
          ,attribute13 = personTbl.attribute13(I)
          ,attribute14 = personTbl.attribute14(I)
          ,attribute15 = personTbl.attribute15(I)
          ,attribute16 = personTbl.attribute16(I)
          ,attribute17 = personTbl.attribute17(I)
          ,attribute18 = personTbl.attribute18(I)
          ,attribute19 = personTbl.attribute19(I)
          ,attribute20 = personTbl.attribute20(I)
          ,attribute21 = personTbl.attribute21(I)
          ,attribute22 = personTbl.attribute22(I)
          ,attribute23 = personTbl.attribute23(I)
          ,attribute24 = personTbl.attribute24(I)
          ,attribute25 = personTbl.attribute25(I)
          ,attribute26 = personTbl.attribute26(I)
          ,attribute27 = personTbl.attribute27(I)
          ,attribute28 = personTbl.attribute28(I)
          ,attribute29 = personTbl.attribute29(I)
          ,attribute30 = personTbl.attribute30(I)
          ,per_information_category = personTbl.per_information_category(I)
          ,per_information1 = personTbl.per_information1(I)
          ,per_information2 = personTbl.per_information2(I)
          ,per_information3 = personTbl.per_information3(I)
          ,per_information4 = personTbl.per_information4(I)
          ,per_information5 = personTbl.per_information5(I)
          ,per_information6 = personTbl.per_information6(I)
          ,per_information7 = personTbl.per_information7(I)
          ,per_information8 = personTbl.per_information8(I)
          ,per_information9 = personTbl.per_information9(I)
          ,per_information10 = personTbl.per_information10(I)
          ,per_information11 = personTbl.per_information11(I)
          ,per_information12 = personTbl.per_information12(I)
          ,per_information13 = personTbl.per_information13(I)
          ,per_information14 = personTbl.per_information14(I)
          ,per_information15 = personTbl.per_information15(I)
          ,per_information16 = personTbl.per_information16(I)
          ,per_information17 = personTbl.per_information17(I)
          ,per_information18 = personTbl.per_information18(I)
          ,per_information19 = personTbl.per_information19(I)
          ,per_information20 = personTbl.per_information20(I)
          ,per_information21 = personTbl.per_information21(I)
          ,per_information22 = personTbl.per_information22(I)
          ,per_information23 = personTbl.per_information23(I)
          ,per_information24 = personTbl.per_information24(I)
          ,per_information25 = personTbl.per_information25(I)
          ,per_information26 = personTbl.per_information26(I)
          ,per_information27 = personTbl.per_information27(I)
          ,per_information28 = personTbl.per_information28(I)
          ,per_information29 = personTbl.per_information29(I)
          ,per_information30 = personTbl.per_information30(I)
          ,direct_reports = personTbl.direct_reports(I)
          ,total_reports = personTbl.total_reports(I)
       WHERE rowid = personTbl.row_id(I);

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in update_per_people: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END update_per_people;

PROCEDURE open_per_people(
   p_cursor IN OUT NOCOPY cur_typ
  ,p_mode IN NUMBER
  ,p_eff_date IN DATE
) IS

query_str VARCHAR2(4000);
BEGIN

 IF (p_mode = 0) THEN
query_str :=
   'SELECT  /*+ parallel(ppf) */' ||
    'null,' ||
    'substr(upper(last_name)||'' ''||upper(first_name)||'' ''||upper(last_name)||'' ''||' ||
    'upper(list_name)||'' ''||' ||
    'decode(oi.org_information9' ||
    ' ,''KR'',per_information1||'' ''||per_information2||'' ''||per_information1||'' ''' ||
    ' ,''CN'',per_information14||'' ''||per_information15||'' ''||per_information14||'' ''' ||
    ' ,''JP'',per_information18||'' ''||per_information19||'' ''||per_information18||'' ''' ||
    ' ,'''')||' ||
    'upper(known_as)||'' ''||upper(ppf.email_address)||'' ''||' ||
    'translate(upper(ph.phone_number),''ABCDEFGHIJKLMNOPQRSTUVWXYZ ,.-()x/\'','' ''),1,2000),' ||
    ''''|| g_srcSystem ||''',' ||
    'ppf.person_id,' ||
    'ppf.business_group_id,' ||
    'oi.org_information9,' ||
    'ppf.list_name display_name,' ||
    'ppf.global_name full_name,' ||
    'ppf.local_name full_name_alternate,' ||
    'nvl(decode(oi.org_information9' ||
    '         ,''KR'', per_information1' ||
    '         ,''CN'', per_information14' ||
    '         ,ppf.last_name),ppf.last_name) last_name,' ||
    'decode(oi.org_information9' ||
    '         ,''KR'', per_information2' ||
    '         ,''CN'', per_information15' ||
    '         ,ppf.first_name) first_name,' ||
    'decode(oi.org_information9' ||
    '         ,''KR'', last_name' ||
    '         ,''CN'', last_name' ||
    '         ,''JP'', per_information18' ||
    '         ,NULL) last_name_alternate,' ||
    'decode(oi.org_information9' ||
    '         ,''KR'', first_name' ||
    '         ,''CN'', first_name' ||
    '         ,''JP'', per_information19' ||
    '         ,NULL) first_name_alternate,' ||
    'ppf.pre_name_adjunct,' ||
    'decode(ppf.current_npw_flag, ''Y'', ''C'', ''E'') person_type,' ||
    'NULL user_name,' ||
    '''Y'',' ||
    'ppf.employee_number,' ||
    'ppf.known_as,' ||
    'ppf.middle_names,' ||
    'ppf.previous_last_name,' ||
    'ppf.start_date,' ||
    'ppf.original_date_of_hire,' ||
    'ppf.email_address,' ||
    'ph.phone_number work_telephone,' ||
    'ppf.mailstop,' ||
    'ppf.office_number,' ||
    'ppf.order_name,' ||
    '1,' ||
    'ppf.object_version_number,' ||
    'ppf.global_person_id,' ||
    'ppf.party_id,' ||
    'ppf.attribute_category, ppf.attribute1, ppf.attribute2, ppf.attribute3, ppf.attribute4, ppf.attribute5,' ||
    'ppf.attribute6, ppf.attribute7, ppf.attribute8, ppf.attribute9, ppf.attribute10, ppf.attribute11,' ||
    'ppf.attribute12, ppf.attribute13, ppf.attribute14, ppf.attribute15, ppf.attribute16, ppf.attribute17,' ||
    'ppf.attribute18, ppf.attribute19, ppf.attribute20, ppf.attribute21, ppf.attribute22, ppf.attribute23,' ||
    'ppf.attribute24, ppf.attribute25, ppf.attribute26, ppf.attribute27, ppf.attribute28, ppf.attribute29,' ||
    'ppf.attribute30, ppf.per_information_category, ppf.per_information1, ppf.per_information2,' ||
    'ppf.per_information3, ppf.per_information4, ppf.per_information5, ppf.per_information6,' ||
    'ppf.per_information7, ppf.per_information8, ppf.per_information9, ppf.per_information10,' ||
    'ppf.per_information11, ppf.per_information12, per_information13, per_information14, per_information15,' ||
    'per_information16, per_information17, per_information18, per_information19, per_information20,' ||
    'per_information21, per_information22, per_information23, per_information24, per_information25,' ||
    'per_information26, per_information27, per_information28, per_information29, per_information30' ||
    ',NULL directs' ||
    ',NULL total' ||
   ' FROM per_people_f ppf, per_phones ph, hr_organization_information oi' ||
   ' WHERE :1 BETWEEN effective_start_date AND effective_end_date' ||
   '   AND (current_employee_flag = ''Y'' OR current_npw_flag = ''Y'')' ||
   '   AND ppf.business_group_id = oi.organization_id' ||
   '   AND oi.org_information_context = ''Business Group Information''' ||
   '   AND parent_table(+) = ''PER_ALL_PEOPLE_F''' ||
   '   AND parent_id(+) = ppf.person_id' ||
   '   AND phone_type(+) = ''W1''' ||
   '   AND :2 BETWEEN date_from(+) AND nvl(date_to(+),:3 + 1)' ||
   '/* Avoiding PK Violation */' ||
   '   AND ppf.person_id NOT IN' ||
   '             (SELECT person_id FROM per_all_people_f ippf' ||
   '              WHERE :4 BETWEEN effective_start_date AND effective_end_date' ||
   '              GROUP BY person_id HAVING count(*) > 1)';
     IF hr_multi_tenancy_pkg.get_system_model = 'B' THEN
       query_str := query_str || '  AND ppf.person_id NOT IN '||
                             '	(SELECT person_id FROM per_all_people_f lppf'||
                             '    WHERE label_to_char(lppf.HR_ENTERPRISE) = ''C::ENT'' OR label_to_char(lppf.HR_ENTERPRISE) is null)';
     END IF;

  OPEN p_cursor FOR query_str using p_eff_date,p_eff_date,p_eff_date,p_eff_date;
 ELSIF (p_mode = 1) THEN
  query_str :=
   'SELECT  /*+ parallel(ppf) */' ||
    'hrdp.rowid,' ||
    'substr(upper(ppf.last_name)||'' ''||upper(ppf.first_name)||'' ''||upper(ppf.last_name)||'' ''||' ||
    'upper(ppf.list_name)||'' ''||' ||
    'decode(oi.org_information9' ||
    ',''KR'',ppf.per_information1||'' ''||ppf.per_information2||'' ''||ppf.per_information1||'' ''' ||
    ' ,''CN'',ppf.per_information14||'' ''||ppf.per_information15||'' ''||ppf.per_information14||'' ''' ||
    ' ,''JP'',ppf.per_information18||'' ''||ppf.per_information19||'' ''||ppf.per_information18||'' ''' ||
    ' ,'''')||' ||
    'upper(ppf.known_as)||'' ''||upper(ppf.email_address)||'' ''||' ||
    'translate(upper(ph.phone_number),''ABCDEFGHIJKLMNOPQRSTUVWXYZ ,.-()x/\'','' ''),1,2000),' ||
    '''' || g_srcSystem || ''',' ||
    'ppf.person_id,' ||
    'ppf.business_group_id,' ||
    'oi.org_information9,' ||
    'ppf.list_name display_name,' ||
    'ppf.global_name full_name,' ||
    'ppf.local_name full_name_alternate,' ||
    'nvl(decode(oi.org_information9' ||
    '         ,''KR'', ppf.per_information1' ||
    '         ,''CN'', ppf.per_information14' ||
    '         ,ppf.last_name),ppf.last_name) last_name,' ||
    'decode(oi.org_information9' ||
    '         ,''KR'', ppf.per_information2' ||
    '         ,''CN'', ppf.per_information15' ||
    '         ,ppf.first_name) first_name,' ||
    'decode(oi.org_information9' ||
    '         ,''KR'', ppf.last_name' ||
    '         ,''CN'', ppf.last_name' ||
    '         ,''JP'', ppf.per_information18' ||
    '         ,NULL) last_name_alternate,' ||
    'decode(oi.org_information9' ||
    '         ,''KR'', ppf.first_name' ||
    '         ,''CN'', ppf.first_name' ||
    '         ,''JP'', ppf.per_information19' ||
    '         ,NULL) first_name_alternate,' ||
    'ppf.pre_name_adjunct,' ||
    'decode(ppf.current_npw_flag, ''Y'', ''C'', ''E'') person_type,' ||
    'NULL user_name,' ||
    'decode (nvl(ppf.current_employee_flag,''N''), ''Y'', ''Y'',' ||
    '   decode(ppf.current_npw_flag,''Y'',''Y'',''N'')) active,' ||
    'ppf.employee_number,' ||
    'ppf.known_as,' ||
    'ppf.middle_names,' ||
    'ppf.previous_last_name,' ||
    'ppf.start_date,' ||
    'ppf.original_date_of_hire,' ||
    'ppf.email_address,' ||
    'ph.phone_number work_telephone,' ||
    'ppf.mailstop,' ||
    'ppf.office_number,' ||
    'ppf.order_name,' ||
    '1,' ||
    'ppf.object_version_number,' ||
    'ppf.global_person_id,' ||
    'ppf.party_id,' ||
    'ppf.attribute_category, ppf.attribute1, ppf.attribute2, ppf.attribute3, ppf.attribute4, ppf.attribute5,' ||
    'ppf.attribute6, ppf.attribute7, ppf.attribute8, ppf.attribute9, ppf.attribute10, ppf.attribute11,' ||
    'ppf.attribute12, ppf.attribute13, ppf.attribute14, ppf.attribute15, ppf.attribute16, ppf.attribute17,' ||
    'ppf.attribute18, ppf.attribute19, ppf.attribute20, ppf.attribute21, ppf.attribute22, ppf.attribute23,' ||
    'ppf.attribute24, ppf.attribute25, ppf.attribute26, ppf.attribute27, ppf.attribute28, ppf.attribute29,' ||
    'ppf.attribute30, ppf.per_information_category, ppf.per_information1, ppf.per_information2,' ||
    'ppf.per_information3, ppf.per_information4, ppf.per_information5, ppf.per_information6,' ||
    'ppf.per_information7, ppf.per_information8, ppf.per_information9, ppf.per_information10,' ||
    'ppf.per_information11, ppf.per_information12, ppf.per_information13, ppf.per_information14,' ||
    'ppf.per_information15, ppf.per_information16, ppf.per_information17, ppf.per_information18,' ||
    'ppf.per_information19, ppf.per_information20, ppf.per_information21, ppf.per_information22,' ||
    'ppf.per_information23, ppf.per_information24, ppf.per_information25, ppf.per_information26,' ||
    'ppf.per_information27, ppf.per_information28, ppf.per_information29, ppf.per_information30' ||
    ',hrdp.direct_reports' ||
    ',hrdp.total_reports ' ||
   ' FROM per_people_f ppf, per_phones ph' ||
   '     ,hr_organization_information oi, per_empdir_people hrdp' ||
   ' WHERE :1 BETWEEN effective_start_date AND effective_end_date' ||
   '   AND hrdp.orig_system = ''' || g_srcSystem || '''' ||
   '   AND ppf.person_id = hrdp.orig_system_id' ||
   '   AND (ppf.object_version_number <> hrdp.object_version_number OR' ||
   '     nvl(hrdp.work_telephone,''#'') <> nvl(ph.phone_number,''#'')  OR' ||
   '     ppf.effective_start_date >=  hrdp.last_update_date) ' ||
   '   AND ppf.business_group_id = oi.organization_id' ||
   '   AND oi.org_information_context =''Business Group Information''' ||
   '   AND ph.parent_table(+) = ''PER_ALL_PEOPLE_F''' ||
   '   AND ph.parent_id(+) = ppf.person_id' ||
   '   AND ph.phone_type(+) = ''W1''' ||
   '   AND :2 BETWEEN date_from(+) AND nvl(date_to(+),:3 +1)';
     IF hr_multi_tenancy_pkg.get_system_model = 'B' THEN
       query_str := query_str || '  AND ppf.person_id NOT IN '||
                             '	(SELECT person_id FROM per_all_people_f lppf'||
                             '    WHERE label_to_char(lppf.HR_ENTERPRISE) = ''C::ENT'' OR label_to_char(lppf.HR_ENTERPRISE) is null)';
     END IF;
  OPEN p_cursor FOR query_str using p_eff_date,p_eff_date,p_eff_date;
 ELSIF (p_mode = 2) THEN
query_str :=
   'SELECT  /*+ parallel(ppf) */' ||
    'null,' ||
    'substr(upper(last_name)||'' ''||upper(first_name)||'' ''||upper(last_name)||'' ''||' ||
    'upper(list_name)||'' ''||' ||
    'decode(oi.org_information9' ||
    ' ,''KR'',per_information1||'' ''||per_information2||'' ''||per_information1||'' ''' ||
    ' ,''CN'',per_information14||'' ''||per_information15||'' ''||per_information14||'' ''' ||
    ' ,''JP'',per_information18||'' ''||per_information19||'' ''||per_information18||'' ''' ||
    ' ,'''')||' ||
    'upper(known_as)||'' ''||upper(ppf.email_address)||'' ''||' ||
    'translate(upper(ph.phone_number),''ABCDEFGHIJKLMNOPQRSTUVWXYZ ,.-()x/\'','' ''),1,2000),' ||
    ''''|| g_srcSystem ||''',' ||
    'ppf.person_id,' ||
    'ppf.business_group_id,' ||
    'oi.org_information9,' ||
    'ppf.list_name display_name,' ||
    'ppf.global_name full_name,' ||
    'ppf.local_name full_name_alternate,' ||
    'nvl(decode(oi.org_information9' ||
    '         ,''KR'', per_information1' ||
    '         ,''CN'', per_information14' ||
    '         ,ppf.last_name),ppf.last_name) last_name,' ||
    'decode(oi.org_information9' ||
    '         ,''KR'', per_information2' ||
    '         ,''CN'', per_information15' ||
    '         ,ppf.first_name) first_name,' ||
    'decode(oi.org_information9' ||
    '         ,''KR'', last_name' ||
    '         ,''CN'', last_name' ||
    '         ,''JP'', per_information18' ||
    '         ,NULL) last_name_alternate,' ||
    'decode(oi.org_information9' ||
    '         ,''KR'', first_name' ||
    '         ,''CN'', first_name' ||
    '         ,''JP'', per_information19' ||
    '         ,NULL) first_name_alternate,' ||
    'ppf.pre_name_adjunct,' ||
    'decode(ppf.current_npw_flag, ''Y'', ''C'', ''E'') person_type,' ||
    'NULL user_name,' ||
    '''Y'',' ||
    'ppf.employee_number,' ||
    'ppf.known_as,' ||
    'ppf.middle_names,' ||
    'ppf.previous_last_name,' ||
    'ppf.start_date,' ||
    'ppf.original_date_of_hire,' ||
    'ppf.email_address,' ||
    'ph.phone_number work_telephone,' ||
    'ppf.mailstop,' ||
    'ppf.office_number,' ||
    'ppf.order_name,' ||
    '1,' ||
    'ppf.object_version_number,' ||
    'ppf.global_person_id,' ||
    'ppf.party_id,' ||
    'ppf.attribute_category, ppf.attribute1, ppf.attribute2, ppf.attribute3, ppf.attribute4, ppf.attribute5,' ||
    'ppf.attribute6, ppf.attribute7, ppf.attribute8, ppf.attribute9, ppf.attribute10, ppf.attribute11,' ||
    'ppf.attribute12, ppf.attribute13, ppf.attribute14, ppf.attribute15, ppf.attribute16, ppf.attribute17,' ||
    'ppf.attribute18, ppf.attribute19, ppf.attribute20, ppf.attribute21, ppf.attribute22, ppf.attribute23,' ||
    'ppf.attribute24, ppf.attribute25, ppf.attribute26, ppf.attribute27, ppf.attribute28, ppf.attribute29,' ||
    'ppf.attribute30, ppf.per_information_category, ppf.per_information1, ppf.per_information2,' ||
    'ppf.per_information3, ppf.per_information4, ppf.per_information5, ppf.per_information6,' ||
    'ppf.per_information7, ppf.per_information8, ppf.per_information9, ppf.per_information10,' ||
    'ppf.per_information11, ppf.per_information12, per_information13, per_information14, per_information15,' ||
    'per_information16, per_information17, per_information18, per_information19, per_information20,' ||
    'per_information21, per_information22, per_information23, per_information24, per_information25,' ||
    'per_information26, per_information27, per_information28, per_information29, per_information30' ||
    ',NULL directs' ||
    ',NULL total' ||
   ' FROM per_people_f ppf, per_phones ph, hr_organization_information oi' ||
   ' WHERE :1 BETWEEN effective_start_date AND effective_end_date' ||
   '   AND (current_employee_flag = ''Y'' OR current_npw_flag = ''Y'')' ||
   '   AND ppf.business_group_id = oi.organization_id' ||
   '   AND oi.org_information_context = ''Business Group Information''' ||
   '   AND parent_table(+) = ''PER_ALL_PEOPLE_F''' ||
   '   AND parent_id(+) = ppf.person_id' ||
   '   AND phone_type(+) = ''W1''' ||
   '   AND :2 BETWEEN date_from(+) AND nvl(date_to(+),:3 + 1)' ||
   '/* Avoiding PK Violation */' ||
   '   AND ppf.person_id NOT IN' ||
   '             (SELECT person_id FROM per_all_people_f ippf' ||
   '              WHERE :4 BETWEEN effective_start_date AND effective_end_date' ||
   '              GROUP BY person_id HAVING count(*) > 1)' ||
   '/* Picking up not exists from per_empdir_people */' ||
   '   AND NOT EXISTS (SELECT ''e'' from per_empdir_people ip' ||
   '              WHERE ip.orig_system_id = ppf.person_id' ||
   '                AND ip.orig_system = ''' || g_srcSystem || ''')';
     IF hr_multi_tenancy_pkg.get_system_model = 'B' THEN
       query_str := query_str || '  AND ppf.person_id NOT IN '||
                             '	(SELECT person_id FROM per_all_people_f lppf'||
                             '    WHERE label_to_char(lppf.HR_ENTERPRISE) = ''C::ENT'' OR label_to_char(lppf.HR_ENTERPRISE) is null)';
     END IF;
OPEN p_cursor FOR query_str using p_eff_date,p_eff_date,p_eff_date,p_eff_date;

 END IF;
END open_per_people;

PROCEDURE bulk_process_per_people(
   p_mode IN NUMBER
   ,p_cnt OUT NOCOPY NUMBER
   ,errbuf OUT NOCOPY VARCHAR2
   ,retcode OUT NOCOPY VARCHAR2
   ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cursor cur_typ;
l_flg BOOLEAN:= FALSE;

BEGIN

    p_cnt := 0;
    l_flg := per_empdir_LEG_OVERRIDE.isOverrideEnabled('PEOPLE');

    open_per_people(
        l_cursor
       ,p_mode
       ,p_eff_date
    );

    LOOP
    BEGIN
      FETCH l_cursor BULK COLLECT
       INTO personTbl.row_id
           ,personTbl.person_key
           ,personTbl.orig_system
           ,personTbl.orig_sytem_id
           ,personTbl.business_group_id
           ,personTbl.legislation_code
           ,personTbl.display_name
           ,personTbl.full_name
           ,personTbl.full_name_alternate
           ,personTbl.last_name
           ,personTbl.first_name
           ,personTbl.last_name_alternate
           ,personTbl.first_name_alternate
           ,personTbl.pre_name_adjunct
           ,personTbl.person_type
           ,personTbl.user_name
           ,personTbl.active
           ,personTbl.employee_number
           ,personTbl.known_as
           ,personTbl.middle_names
           ,personTbl.previous_last_name
           ,personTbl.start_date
           ,personTbl.original_DOH
           ,personTbl.email_address
           ,personTbl.work_telephone
           ,personTbl.mailstop
           ,personTbl.office_number
           ,personTbl.order_name
           ,personTbl.partition_id
           ,personTbl.object_version_number
           ,personTbl.global_person_id
           ,personTbl.party_id
           ,personTbl.attribute_category
           ,personTbl.attribute1
           ,personTbl.attribute2
           ,personTbl.attribute3
           ,personTbl.attribute4
           ,personTbl.attribute5
           ,personTbl.attribute6
           ,personTbl.attribute7
           ,personTbl.attribute8
           ,personTbl.attribute9
           ,personTbl.attribute10
           ,personTbl.attribute11
           ,personTbl.attribute12
           ,personTbl.attribute13
           ,personTbl.attribute14
           ,personTbl.attribute15
           ,personTbl.attribute16
           ,personTbl.attribute17
           ,personTbl.attribute18
           ,personTbl.attribute19
           ,personTbl.attribute20
           ,personTbl.attribute21
           ,personTbl.attribute22
           ,personTbl.attribute23
           ,personTbl.attribute24
           ,personTbl.attribute25
           ,personTbl.attribute26
           ,personTbl.attribute27
           ,personTbl.attribute28
           ,personTbl.attribute29
           ,personTbl.attribute30
           ,personTbl.per_information_category
           ,personTbl.per_information1
           ,personTbl.per_information2
           ,personTbl.per_information3
    	   ,personTbl.per_information4
    	   ,personTbl.per_information5
    	   ,personTbl.per_information6
    	   ,personTbl.per_information7
    	   ,personTbl.per_information8
    	   ,personTbl.per_information9
    	   ,personTbl.per_information10
    	   ,personTbl.per_information11
    	   ,personTbl.per_information12
    	   ,personTbl.per_information13
    	   ,personTbl.per_information14
    	   ,personTbl.per_information15
    	   ,personTbl.per_information16
    	   ,personTbl.per_information17
    	   ,personTbl.per_information18
    	   ,personTbl.per_information19
    	   ,personTbl.per_information20
    	   ,personTbl.per_information21
    	   ,personTbl.per_information22
    	   ,personTbl.per_information23
    	   ,personTbl.per_information24
    	   ,personTbl.per_information25
    	   ,personTbl.per_information26
    	   ,personTbl.per_information27
    	   ,personTbl.per_information28
    	   ,personTbl.per_information29
    	   ,personTbl.per_information30
           ,personTbl.direct_reports
           ,personTbl.total_reports LIMIT g_commit_size;

           IF personTbl.person_key.count <= 0 THEN
                CLOSE l_cursor;
                EXIT;
           END IF;

           p_cnt := p_cnt + personTbl.person_key.count;

           IF l_flg THEN
            per_empdir_leg_override.people(
                    errbuf => errbuf
                   ,retcode => retcode
                   ,p_eff_date => p_eff_date
                   ,p_cnt => personTbl.person_key.count
                   ,p_srcsystem => g_srcSystem);
           END IF;

           IF (p_mode = '0' OR p_mode = '2') THEN
               dump_per_people(
                 errbuf
                ,retcode
                ,p_eff_date
                ,personTbl.person_key.count
               );
           ElSIF (p_mode = '1') THEN
               update_per_people(
                  errbuf
                 ,retcode
                 ,p_eff_date
                 ,personTbl.person_key.count
               );
           END IF;

           COMMIT;

           IF l_cursor%NOTFOUND THEN
            CLOSE l_cursor;
            EXIT;
           END IF;
     END;
    END LOOP;
    COMMIT;

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in bulk_process_per_people: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END bulk_process_per_people;

PROCEDURE merge_per_people(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cnt   NUMBER :=0;

BEGIN


    write_log(1, 'Begin merge per people: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    g_date := trunc(SYSDATE);

    bulk_process_per_people(
       1
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
    );

    write_log(1, 'Total # of records updated for per_empdir_people: '||l_cnt);
    write_log(2, 'Total # of records updated for per_empdir_people: '||l_cnt);

    bulk_process_per_people(
       2
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
    );

    write_log(1, 'Total # of new records processed for per_empdir_people: '||l_cnt);
    write_log(2, 'Total # of new records processed for per_empdir_people: '||l_cnt);
    write_log(1, 'End merge per people: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));


    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in merge_per_people: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END merge_per_people;

PROCEDURE populate_per_people(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cnt NUMBER:= 0;

BEGIN


    write_log(1, 'Begin populating per people: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXECUTE IMMEDIATE 'ALTER TABLE '||g_schema_owner||'.PER_EMPDIR_PEOPLE TRUNCATE PARTITION internal REUSE STORAGE';
    EXECUTE IMMEDIATE 'ALTER INDEX '||g_schema_owner||'.PER_EMPDIR_PEOPLE_PK REBUILD';
    EXECUTE IMMEDIATE 'ALTER INDEX '||g_schema_owner||'.PER_EMPDIR_PEOPLE_N1 REBUILD';

    bulk_process_per_people(
       0
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
    );

    write_log(1, 'Total # of records processed for per_empdir_people: '||l_cnt);
    write_log(2, 'Total # of records processed for per_empdir_people: '||l_cnt);
    write_log(1, 'End populating per people: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in populate_per_people: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END populate_per_people;

PROCEDURE merge_per_loctl(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cnt NUMBER:= 0;

BEGIN


    write_log(1, 'Begin merge per loctl: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    g_date := trunc(SYSDATE);

    UPDATE per_empdir_locations_tl loc
      SET (orig_system, orig_system_id, location_code, description,
         language, source_lang, object_version_number, partition_id,
         last_update_date, last_update_by, created_by, creation_date,
         request_id, program_application_id, program_id, program_update_date)
        = (SELECT
         g_srcSystem, ltl.location_id, ltl.location_code, ltl.description,
         ltl.language, ltl.source_lang, l.object_version_number, 1,
         g_date, g_user_id, g_user_id, g_date, g_request_id,
         g_prog_appl_id, g_prog_id, g_date
         FROM hr_locations_all_tl ltl, hr_locations_all l
         WHERE ltl.location_id = l.location_id
         AND ltl.language = loc.language
         AND ltl.location_id = loc.orig_system_id
         AND loc.orig_system = g_srcSystem)
    WHERE EXISTS (SELECT 'e' FROM hr_locations_all ol
                  WHERE loc.object_version_number <> ol.object_version_number
                  AND loc.orig_system_id = ol.location_id
                  AND loc.orig_system = g_srcSystem)
    AND loc.orig_system = g_srcSystem;

   l_cnt := sql%rowcount;
   COMMIT;

   write_log(1, 'Total # of records updated for per_empdir_locations_tl: '||l_cnt);
   write_log(2, 'Total # of records updated for per_empdir_locations_tl: '||l_cnt);

   INSERT  /*+ parallel(loc) append */ INTO per_empdir_locations_tl loc(
	ORIG_SYSTEM,
	ORIG_SYSTEM_ID,
 	LOCATION_CODE,
	DESCRIPTION,
	LANGUAGE,
	SOURCE_LANG,
	OBJECT_VERSION_NUMBER,
        PARTITION_ID ,
	LAST_UPDATE_DATE,
	LAST_UPDATE_BY,
	CREATED_BY ,
	CREATION_DATE,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE)
   SELECT  /*+ parallel(ltl) */
         g_srcSystem,
         ltl.location_id,
         ltl.location_code,
         ltl.description,
         ltl.language,
         ltl.source_lang,
         l.object_version_number,
         1,
         g_date,
         g_user_id,
         g_user_id,
         g_date,
         g_request_id,
         g_prog_appl_id,
         g_prog_id,
         g_date
   FROM  hr_locations_all_tl ltl, hr_locations_all l, per_empdir_locations pel
   WHERE ltl.location_id = l.location_id
   AND   pel.orig_system_id = l.location_id
   AND   pel.orig_system = g_srcSystem
   AND NOT EXISTS (SELECT 'e' from per_empdir_locations_tl il
                   WHERE il.orig_system_id = ltl.location_id
                   AND il.orig_system = g_srcSystem);

   l_cnt := sql%rowcount;
   COMMIT;

   write_log(1, 'Total # of new records processed for per_empdir_locations_tl: '||l_cnt);
   write_log(2, 'Total # of new records processed for per_empdir_locations_tl: '||l_cnt);
   write_log(1, 'End merge per loctl: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in merge_per_loctl: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END merge_per_loctl;

PROCEDURE merge_per_phones(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cnt NUMBER:= 0;

BEGIN

    write_log(1, 'Begin merge per phones: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    g_date := trunc(SYSDATE);

    UPDATE per_empdir_phones p
      SET (orig_system, orig_system_id, date_from, date_to, phone_type, phone_number,
         phone_key, parent_id, parent_table, object_version_number,
         partition_id, request_id, program_application_id, program_id,
         program_update_date, last_update_date, last_updated_by,
         last_update_login, created_by, creation_date)
            = (SELECT
         g_srcSystem, phone_id, date_from, date_to, phone_type, phone_number,
         nvl(translate(upper(phone_number),'ABCDEFGHIJKLMNOPQRSTUVWXYZ ,.-()x/\',' '),'##'),
         parent_id, parent_table, object_version_number, 1,
         g_request_id, g_prog_appl_id, g_prog_id, g_date,
         g_date, g_user_id, g_login_id, g_user_id, g_date
         FROM per_phones ph
         WHERE p_eff_date BETWEEN DATE_FROM AND nvl(DATE_TO, p_eff_date+1)
         AND ph.phone_id = p.orig_system_id
         AND p.orig_system = g_srcSystem)
    WHERE EXISTS (SELECT 'e' FROM per_phones oph
               WHERE p.object_version_number <> oph.object_version_number
			   AND p_eff_date BETWEEN DATE_FROM AND nvl(DATE_TO, p_eff_date+1)-- Added for bug#13862147
               AND p.orig_system_id = oph.phone_id
               AND p.orig_system = g_srcSystem)
    AND p.orig_system = g_srcSystem;

   l_cnt := sql%rowcount;
   COMMIT;

   write_log(1, 'Total # of records updated for per_empdir_phones: '||l_cnt);
   write_log(2, 'Total # of records updated for per_empdir_phones: '||l_cnt);

   INSERT  /*+ parallel(hrd) append */ INTO per_empdir_phones hrd(
	ORIG_SYSTEM ,
	ORIG_SYSTEM_ID ,
	DATE_FROM,
	DATE_TO ,
	PHONE_TYPE ,
	PHONE_NUMBER,
	PHONE_KEY ,
	PARENT_ID,
	PARENT_TABLE,
	OBJECT_VERSION_NUMBER,
	PARTITION_ID,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY ,
	CREATION_DATE)
  select  /*+ parallel(ph) */
         g_srcSystem,
         phone_id,
         date_from,
         date_to,
         phone_type,
         phone_number,
         nvl(translate(upper(phone_number),'ABCDEFGHIJKLMNOPQRSTUVWXYZ ,.-()x/\',' '),'##'),
         parent_id,
         parent_table,
         object_version_number,
         1,
         g_request_id,
         g_prog_appl_id,
         g_prog_id,
         g_date,
         g_date,
         g_user_id,
         g_login_id,
         g_user_id,
         g_date
   FROM per_phones ph
   WHERE p_eff_date BETWEEN DATE_FROM AND nvl(DATE_TO, p_eff_date+1)
   /* Picking up not exists from per_empdir_phones */
   AND NOT EXISTS (SELECT 'e' from per_empdir_phones iph
        WHERE iph.orig_system_id = ph.phone_id
        AND iph.orig_system = g_srcSystem);

   l_cnt := sql%rowcount;
   COMMIT;

   write_log(1, 'Total # of new records processed for per_empdir_phones: '||l_cnt);
   write_log(2, 'Total # of new records processed for per_empdir_phones: '||l_cnt);
   write_log(1, 'End merge per phones: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in merge_per_phones: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END merge_per_phones;

PROCEDURE merge_per_locations(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cnt NUMBER:= 0;

BEGIN


    write_log(1, 'Begin merge per locations: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    g_date := trunc(SYSDATE);

    bulk_process_per_locations(
       1
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
    );

    write_log(1, 'Total # of records updated for per_empdir_locations: '||l_cnt);
    write_log(2, 'Total # of records updated for per_empdir_locations: '||l_cnt);

    bulk_process_per_locations(
       2
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
    );

    write_log(1, 'Total # of new records processed for per_empdir_locations: '||l_cnt);
    write_log(2, 'Total # of new records processed for per_empdir_locations: '||l_cnt);
    write_log(1, 'End merge per locations: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in merge_per_locations: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END merge_per_locations;

PROCEDURE merge_per_jobs(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cnt  NUMBER:= 0;
l_ucnt NUMBER:= 0;
l_icnt NUMBER:= 0;

BEGIN


    write_log(1, 'Begin merge per jobs: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    g_date := trunc(SYSDATE);

   FOR I in c_organizations LOOP

    write_log(1,'Processing jobs for BusGrpId: '||I.organization_id||
                ' using SegList: '||I.slist);

    bulk_process_per_jobs(
       1
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
       ,I.slist
       ,I.organization_id
    );

    l_ucnt := l_ucnt + l_cnt;

    bulk_process_per_jobs(
       2
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
       ,I.slist
       ,I.organization_id
    );

    l_icnt := l_icnt + l_cnt;

   END LOOP;

    write_log(1, 'Total # of records updated for per_empdir_jobs: '||l_ucnt);
    write_log(2, 'Total # of records updated for per_empdir_jobs: '||l_ucnt);
    write_log(1, 'Total # of new records processed for per_empdir_jobs: '||l_icnt);
    write_log(2, 'Total # of new records processed for per_empdir_jobs: '||l_icnt);
    write_log(1, 'End merge per jobs: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in merge_per_jobs: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END merge_per_jobs;


PROCEDURE merge_per_pos(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cnt NUMBER:= 0;

BEGIN


    write_log(1, 'Begin merge per pos: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    g_date := trunc(SYSDATE);

    bulk_process_hr_pos(
       1
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
    );

    write_log(1, 'Total # of records updated for per_empdir_positions: '||l_cnt);
    write_log(2, 'Total # of records updated for per_empdir_positions: '||l_cnt);

    bulk_process_hr_pos(
       2
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
    );

    write_log(1, 'Total # of new records processed for per_empdir_positions: '||l_cnt);
    write_log(2, 'Total # of new records processed for per_empdir_positions: '||l_cnt);
    write_log(1, 'End merge per pos: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in merge_per_pos: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END merge_per_pos;

PROCEDURE merge_hr_orgs(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cnt NUMBER:= 0;

BEGIN

    write_log(1, 'Begin merge hr organizations: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    g_date := trunc(SYSDATE);

    bulk_process_hr_orgs(
       1
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
    );

    write_log(1, 'Total # of records updated for per_empdir_organizations: '||l_cnt);
    write_log(2, 'Total # of records updated for per_empdir_organizations: '||l_cnt);

    bulk_process_hr_orgs(
       2
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
    );

    write_log(1, 'Total # of new records processed for per_empdir_organizations: '||l_cnt);
    write_log(2, 'Total # of new records processed for per_empdir_organizations: '||l_cnt);
    write_log(1, 'End merge hr organizations: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in merge_hr_orgs: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END merge_hr_orgs;

PROCEDURE merge_per_asg(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
  ,p_multi_asg IN VARCHAR2
) IS

l_cnt NUMBER:= 0;

BEGIN


    write_log(1, 'Begin merge per assginments: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    g_date := trunc(SYSDATE);

    bulk_process_per_asg(
       1
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
       ,p_multi_asg
    );

    write_log(1, 'Total # of records updated for per_empdir_assignments: '||l_cnt);
    write_log(2, 'Total # of records updated for per_empdir_assignments: '||l_cnt);

    bulk_process_per_asg(
       2
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
       ,p_multi_asg
    );

    write_log(1, 'Total # of new records processed for per_empdir_assignments: '||l_cnt);
    write_log(2, 'Total # of new records processed for per_empdir_assignments: '||l_cnt);
    write_log(1, 'End merge per assignments: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));


    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in merge_per_asg: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END merge_per_asg;

PROCEDURE populate_per_asg(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
  ,p_multi_asg IN VARCHAR2
) IS

l_cnt NUMBER:= 0;

BEGIN

    write_log(1, 'Begin populating per assginments: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));
    EXECUTE IMMEDIATE 'ALTER TABLE '||g_schema_owner||'.PER_EMPDIR_ASSIGNMENTS TRUNCATE PARTITION internal REUSE STORAGE';
    EXECUTE IMMEDIATE 'ALTER INDEX '||g_schema_owner||'.PER_EMPDIR_ASSIGNMENTS_PK REBUILD';

    g_date := trunc(SYSDATE);

    bulk_process_per_asg(
       0
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
       ,p_multi_asg
    );

    write_log(1, 'Total # of records processed for per_empdir_assignments: '||l_cnt);
    write_log(2, 'Total # of records processed for per_empdir_assignments: '||l_cnt);
    write_log(1, 'End populating per asg: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in populate_per_asg: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));
END populate_per_asg;

PROCEDURE populate_hr_orgs(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cnt NUMBER:= 0;

BEGIN

   write_log(1, 'Begin populating hr orgs: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));
   EXECUTE IMMEDIATE 'ALTER TABLE '||g_schema_owner||'.PER_EMPDIR_ORGANIZATIONS TRUNCATE PARTITION internal REUSE STORAGE';
   EXECUTE IMMEDIATE 'ALTER INDEX '||g_schema_owner||'.PER_EMPDIR_ORGANIZATIONS_PK REBUILD';

   g_date := trunc(SYSDATE);

   bulk_process_hr_orgs(
       0
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
    );

   write_log(1, 'Total # of records processed for per_empdir_organizations: '||l_cnt);
   write_log(2, 'Total # of records processed for per_empdir_organizations: '||l_cnt);
   write_log(1, 'End populating hr orgs: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in populate_hr_orgs: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END populate_hr_orgs;

PROCEDURE populate_per_phones(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cnt NUMBER:= 0;

BEGIN


   write_log(1, 'Begin populating per phones: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

   EXECUTE IMMEDIATE 'ALTER TABLE '||g_schema_owner||'.PER_EMPDIR_PHONES TRUNCATE PARTITION internal REUSE STORAGE';
   EXECUTE IMMEDIATE 'ALTER INDEX '||g_schema_owner||'.PER_EMPDIR_PHONES_PK REBUILD';

   g_date := trunc(SYSDATE);

   INSERT  /*+ parallel(hrd) append */ INTO per_empdir_phones hrd(
	ORIG_SYSTEM ,
	ORIG_SYSTEM_ID ,
	DATE_FROM,
	DATE_TO ,
	PHONE_TYPE ,
	PHONE_NUMBER,
	PHONE_KEY ,
	PARENT_ID,
	PARENT_TABLE,
	OBJECT_VERSION_NUMBER,
	PARTITION_ID,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY ,
	CREATION_DATE)
   SELECT  /*+ parallel(ph) */
         g_srcSystem,
         phone_id,
         date_from,
         date_to,
         phone_type,
         phone_number,
         nvl(translate(upper(phone_number),'ABCDEFGHIJKLMNOPQRSTUVWXYZ ,.-()x/\',' '),'##'),
         parent_id,
         parent_table,
         object_version_number,
         1,
         g_request_id,
         g_prog_appl_id,
         g_prog_id,
         g_date,
         g_date,
         g_user_id,
         g_login_id,
         g_user_id,
         g_date
   FROM per_phones
   WHERE p_eff_date BETWEEN DATE_FROM AND nvl(DATE_TO, p_eff_date+1);


   l_cnt := sql%rowcount;
   COMMIT;

   write_log(1, 'Total # of records processed for per_empdir_phones: '||l_cnt);
   write_log(2, 'Total # of records processed for per_empdir_phones: '||l_cnt);
   write_log(1, 'End populating per phones: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in populate_per_phones: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END populate_per_phones;

PROCEDURE populate_per_loctl(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
) IS

l_cnt NUMBER:= 0;

BEGIN


   write_log(1, 'Begin populating per location tl: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));
   EXECUTE IMMEDIATE 'ALTER TABLE '||g_schema_owner||'.PER_EMPDIR_LOCATIONS_TL TRUNCATE PARTITION internal REUSE STORAGE';
   EXECUTE IMMEDIATE 'ALTER INDEX '||g_schema_owner||'.PER_EMPDIR_LOCATIONS_TL_PK REBUILD';

   g_date := trunc(SYSDATE);

   INSERT  /*+ parallel(loc) append */ INTO per_empdir_locations_tl loc(
	ORIG_SYSTEM,
	ORIG_SYSTEM_ID,
 	LOCATION_CODE,
	DESCRIPTION,
	LANGUAGE,
	SOURCE_LANG,
	OBJECT_VERSION_NUMBER,
	PARTITION_ID ,
	LAST_UPDATE_DATE,
	LAST_UPDATE_BY,
	CREATED_BY ,
	CREATION_DATE,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE)
   SELECT  /*+ parallel(ltl) */
         g_srcSystem,
         ltl.location_id,
         ltl.location_code,
         ltl.description,
         ltl.language,
         ltl.source_lang,
         l.object_version_number,
         1,
         g_date,
         g_user_id,
         g_user_id,
         g_date,
         g_request_id,
         g_prog_appl_id,
         g_prog_id,
         g_date
   from  hr_locations_all_tl ltl, hr_locations_all l
   where ltl.location_id = l.location_id;

   l_cnt := sql%rowcount;
   COMMIT;

   write_log(1, 'Total # of records processed for per_empdir_locations_tl: '||l_cnt);
   write_log(2, 'Total # of records processed for per_empdir_locations_tl: '||l_cnt);
   write_log(1, 'End populating per locations tl: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in populate_per_locations tl: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END populate_per_loctl;

PROCEDURE populate_per_locations(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cnt NUMBER:= 0;

BEGIN

   write_log(1, 'Begin populating per locations: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));
   EXECUTE IMMEDIATE 'ALTER TABLE '||g_schema_owner||'.PER_EMPDIR_LOCATIONS TRUNCATE PARTITION internal REUSE STORAGE';
   EXECUTE IMMEDIATE 'ALTER INDEX '||g_schema_owner||'.PER_EMPDIR_LOCATIONS_PK REBUILD';

   bulk_process_per_locations(
       0
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
    );

   write_log(1, 'Total # of records processed for per_empdir_locations: '||l_cnt);
   write_log(2, 'Total # of records processed for per_empdir_locations: '||l_cnt);
   write_log(1, 'End populating per locations: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in populate_per_locations: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END populate_per_locations;

PROCEDURE populate_per_pos(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cnt NUMBER:= 0;

BEGIN

   write_log(1, 'Begin populating per pos: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

   EXECUTE IMMEDIATE 'ALTER TABLE '||g_schema_owner||'.PER_EMPDIR_POSITIONS TRUNCATE PARTITION internal REUSE STORAGE';
   EXECUTE IMMEDIATE 'ALTER INDEX '||g_schema_owner||'.PER_EMPDIR_POSITIONS_PK REBUILD';

   g_date := trunc(SYSDATE);

   bulk_process_hr_pos(
       0
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
    );

   write_log(1, 'Total # of records processed for per_empdir_positions: '||l_cnt);
   write_log(2, 'Total # of records processed for per_empdir_positions: '||l_cnt);
   write_log(1, 'End populating per pos: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in populate_per_pos: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END populate_per_pos;

PROCEDURE populate_per_jobs(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_eff_date IN DATE DEFAULT trunc(SYSDATE)
) IS

l_cnt NUMBER:= 0;
l_tcnt NUMBER:= 0;

BEGIN


   write_log(1, 'Begin populating per jobs: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));
   EXECUTE IMMEDIATE 'ALTER TABLE '||g_schema_owner||'.PER_EMPDIR_JOBS TRUNCATE PARTITION internal REUSE STORAGE';
   EXECUTE IMMEDIATE 'ALTER INDEX '||g_schema_owner||'.PER_EMPDIR_JOBS_PK REBUILD';

   FOR I in c_organizations LOOP

    write_log(1,'Processing jobs for BusGrpId: '||I.organization_id||
                ' using SegList: '||I.slist);

     bulk_process_per_jobs(
       0
       ,l_cnt
       ,errbuf
       ,retcode
       ,p_eff_date
       ,I.slist
       ,I.organization_id
     );
     l_tcnt := l_tcnt + l_cnt;

   END LOOP;

   write_log(1, 'Total # of records processed for per_empdir_jobs: '||l_tcnt);
   write_log(2, 'Total # of records processed for per_empdir_jobs: '||l_tcnt);
   write_log(1, 'End populating per jobs: '||to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in populate_per_jobs: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END populate_per_jobs;

--Fix for Bug#4380794
PROCEDURE populate_per_images(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ) IS
 l_cnt NUMBER:= 0;
BEGIN

   write_log(1, 'Begin populating per images: '||to_char(SYSDATE, 'DD/MM/RRRR
HH:MI:SS'));

--fix for bug 6066127
 EXECUTE IMMEDIATE 'TRUNCATE TABLE '||g_schema_owner||'.PER_EMPDIR_IMAGES';
 EXECUTE IMMEDIATE 'ALTER INDEX '||g_schema_owner||'.PER_EMPDIR_IMAGES_PK REBUILD';
 EXECUTE IMMEDIATE 'ALTER INDEX '||g_schema_owner||'.PER_EMPDIR_IMAGES_U1 REBUILD';

/* inserting the blob columns from per_images to per_empdir_images if not exist
 *  * already*/

     INSERT INTO per_empdir_images
       (image_id,
        orig_system,
        orig_system_id,
        image_name,
        content_type,
        image,
        object_version_number)
    SELECT per_empdir_images_s.nextval
          ,'PER'
          ,pi.parent_id
          ,pi.parent_id
          ,null
          ,pi.image
          ,1
      FROM per_images pi
     WHERE pi.table_name='PER_PEOPLE_F'
       AND NOT EXISTS ( SELECT 'X'FROM per_empdir_images pei
                        WHERE pei.orig_system='PER'
                          AND pei.orig_system_id=pi.parent_id);



   l_cnt := sql%rowcount;
   COMMIT;

   write_log(1, 'Total # of new records processed for per_empdir_images:
'||l_cnt);
   write_log(2, 'Total # of new records processed for per_empdir_images:
'||l_cnt);
   write_log(1, 'End populating per images: '||to_char(SYSDATE, 'DD/MM/RRRR
HH:MI:SS'));

 delete from per_empdir_images
   where orig_system_id not in(
   select parent_id from per_images
   where table_name='PER_PEOPLE_F')
   and orig_system = 'PER' ;
   commit;


    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in populate_per_images: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END populate_per_images;

PROCEDURE merge_per_images(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ) IS

   l_cnt NUMBER:= 0;
 L_IMAGE_ID NUMBER(15,0) :=0;
  L_ORIG_SYSTEM VARCHAR2(30);
  L_ORIG_SYSTEM_ID NUMBER(15,0):=0;
  L_IMAGE_NAME VARCHAR2(60);
  L_CONTENT_TYPE VARCHAR2(30);
  L_OBJECT_VERSION_NUMBER NUMBER(9,0):= 0;
  L_LAST_UPDATE_DATE DATE;
  L_LAST_UPDATED_BY NUMBER(15,0):=0;
  L_LAST_UPDATE_LOGIN NUMBER(15,0):=0;
  L_CREATED_BY NUMBER(15,0):=0;
  L_CREATION_DATE DATE;

   Cursor update_emp_dirimages_cur is
      Select pi.parent_id parent_id
         From per_images pi,per_empdir_images pei
        Where pi.table_name='PER_PEOPLE_F'
          And pi.parent_id =pei.orig_system_id
          And pei.orig_system='PER'
          And trunc(pei.last_update_date) <= trunc(sysdate);


BEGIN

   write_log(1, 'Begin merging per images: '||to_char(SYSDATE, 'DD/MM/RRRR
HH:MI:SS'));
/* updating the blob columns from per_images to per_empdir_images if exist */


    FOR update_emp_dirimages_rec IN update_emp_dirimages_cur
    LOOP

    SELECT IMAGE_ID,ORIG_SYSTEM,ORIG_SYSTEM_ID,NVL(IMAGE_NAME,' '),NVL(CONTENT_TYPE,' '),
    NVL(OBJECT_VERSION_NUMBER,0),NVL(LAST_UPDATE_DATE,SYSDATE),
    NVL(LAST_UPDATED_BY,0),NVL(LAST_UPDATE_LOGIN,0),NVL(CREATED_BY,0),NVL(CREATION_DATE,SYSDATE) INTO
    L_IMAGE_ID,L_ORIG_SYSTEM,L_ORIG_SYSTEM_ID,L_IMAGE_NAME,L_CONTENT_TYPE,L_OBJECT_VERSION_NUMBER,L_LAST_UPDATE_DATE,
    L_LAST_UPDATED_BY,L_LAST_UPDATE_LOGIN,L_CREATED_BY,L_CREATION_DATE
    FROM PER_EMPDIR_IMAGES
    WHERE ORIG_SYSTEM_ID = update_emp_dirimages_rec.parent_id
    AND orig_system='PER';

    DELETE FROM PER_EMPDIR_IMAGES
    WHERE ORIG_SYSTEM_ID = update_emp_dirimages_rec.parent_id
    AND orig_system='PER';

    INSERT INTO PER_EMPDIR_IMAGES
    (IMAGE_ID,ORIG_SYSTEM,ORIG_SYSTEM_ID,IMAGE_NAME,CONTENT_TYPE,IMAGE,OBJECT_VERSION_NUMBER,LAST_UPDATE_DATE,
     LAST_UPDATED_BY,LAST_UPDATE_LOGIN,CREATED_BY,CREATION_DATE)
    SELECT L_IMAGE_ID,L_ORIG_SYSTEM,L_ORIG_SYSTEM_ID,L_IMAGE_NAME,L_CONTENT_TYPE,
    image,
    L_OBJECT_VERSION_NUMBER,L_LAST_UPDATE_DATE,
    L_LAST_UPDATED_BY,L_LAST_UPDATE_LOGIN,L_CREATED_BY,L_CREATION_DATE
    FROM per_images
    WHERE table_name='PER_PEOPLE_F'
	AND PARENT_ID = update_emp_dirimages_rec.parent_id;

    l_cnt := l_cnt + 1;
    END LOOP;




   l_cnt := sql%rowcount;

   COMMIT;


   write_log(1, 'Total # of records updated for per_empdir_images: '||l_cnt);
   write_log(2, 'Total # of records updated for per_empdir_images: '||l_cnt);
/* inserting the blob columns from per_images to per_empdir_images if not exist
 *  * already*/
    l_cnt :=0;
    INSERT INTO per_empdir_images
       (image_id,
        orig_system,
        orig_system_id,
        image_name,
        content_type,
        image,
        object_version_number)
    SELECT per_empdir_images_s.nextval
          ,'PER'
          ,pi.parent_id
          ,pi.parent_id
          ,null
          ,pi.image
          ,1
      FROM per_images pi
     WHERE pi.table_name='PER_PEOPLE_F'
       AND NOT EXISTS ( SELECT 'X'FROM per_empdir_images pei
                        WHERE pei.orig_system='PER'
                          AND pei.orig_system_id=pi.parent_id);

   l_cnt := sql%rowcount;
   COMMIT;

   write_log(1, 'Total # of new records processed for per_empdir_images:
'||l_cnt);
   write_log(2, 'Total # of new records processed for per_empdir_images:
'||l_cnt);
   write_log(1, 'End merge per images: '||to_char(SYSDATE, 'DD/MM/RRRR
HH:MI:SS'));

     delete from per_empdir_images
   where orig_system_id not in(
   select parent_id from per_images
   where table_name='PER_PEOPLE_F')
   and orig_system = 'PER' ;
   commit;


    EXCEPTION WHEN OTHERS THEN
        errbuf := errbuf||SQLERRM;
        retcode := '1';
        write_log(1, 'Error in merge_per_images: '||SQLCODE);
        write_log(1, 'Error Msg: '||substr(SQLERRM,1,700));

END merge_per_images;

--End of fix for bug#4380794

 -- Global Members

PROCEDURE swap(
        value1 IN OUT NOCOPY VARCHAR2
       ,value2 IN OUT NOCOPY VARCHAR2) IS

l_tmp VARCHAR2(240);
BEGIN

    l_tmp  := value1;
    value1 := value2;
    value2 := l_tmp;

    EXCEPTION WHEN OTHERS THEN
        per_empdir_ss.write_log(1,
                        'Error in swap: '||SQLCODE);
        per_empdir_ss.write_log(1,
                        'Error Msg: '||substr(SQLERRM,1,700));
END swap;

PROCEDURE main(
   errbuf  OUT NOCOPY VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,p_mode  IN  VARCHAR2
  ,p_eff_date IN VARCHAR2
  ,p_source_system IN  VARCHAR2
  ,p_multi_asg IN VARCHAR2 DEFAULT 'N'
  ,p_image_refresh IN VARCHAR2 DEFAULT 'N'
) IS

 l_eff_date DATE;
 l_index    varchar2(200);
 l_db_version varchar2(100);

BEGIN

    g_srcSystem := p_source_system;
    g_schema_owner := getTblOwner;
    l_eff_date := nvl(fnd_date.canonical_to_date(p_eff_date), trunc(sysdate));

    write_log(1, 'Process began @: '|| to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

    BEGIN
	    EXECUTE IMMEDIATE 'ALTER TRIGGER PER_EMPDIR_ASSIGNMENTS_WHO DISABLE';
	    EXECUTE IMMEDIATE 'ALTER TRIGGER PER_EMPDIR_LOCATIONS_WHO DISABLE';
	    EXECUTE IMMEDIATE 'ALTER TRIGGER PER_EMPDIR_PEOPLE_WHO DISABLE';
	    EXECUTE IMMEDIATE 'ALTER TRIGGER PER_EMPDIR_PHONES_WHO DISABLE';

    EXCEPTION WHEN OTHERS THEN
	NULL;
    END;

    EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

    IF (p_mode = 'COMPLETE') THEN
        write_log(2, 'Running Complete Build');

            populate_per_people(
                errbuf
               ,retcode
               ,l_eff_date
            );

 	        /*EXECUTE IMMEDIATE 'ALTER INDEX '||g_schema_owner||'.PER_EMPDIR_PEOPLE_N1 REBUILD PARAMETERS(''sync'')';*/

            l_index := g_schema_owner||'.PER_EMPDIR_PEOPLE_N1';
            ad_ctx_ddl.sync_index(l_index);

            populate_per_asg(
                errbuf
               ,retcode
               ,l_eff_date
               ,p_multi_asg
            );

            populate_hr_orgs(
                errbuf
               ,retcode
               ,l_eff_date
            );

            populate_per_phones(
                errbuf
               ,retcode
               ,l_eff_date
            );

            populate_per_pos(
                errbuf
               ,retcode
               ,l_eff_date
            );

            populate_per_jobs(
                errbuf
               ,retcode
               ,l_eff_date
            );

           populate_per_locations(
                errbuf
               ,retcode
               ,l_eff_date
            );

            populate_per_loctl(
                errbuf
               ,retcode
            );

           --Fix for bug#4380794
           IF p_image_refresh = 'Y' THEN
               populate_per_images(
                     errbuf
                    ,retcode
                  );
           END IF;
           --end ofFix for bug#4380794

           IF (nvl(retcode,'0') <> '1') THEN
                gather_stats;
            END IF;

            compute_reports(
                errbuf
               ,retcode
               ,g_srcSystem
            );

    ELSIF (p_mode = 'INCREMENTAL') THEN

        write_log(2, 'Incremental Refresh Build');

           merge_per_people(
                errbuf
               ,retcode
               ,l_eff_date
           );

           /*EXECUTE IMMEDIATE 'ALTER INDEX '||g_schema_owner||'.PER_EMPDIR_PEOPLE_N1 REBUILD PARAMETERS(''sync'') ONLINE';*/

            l_index := g_schema_owner||'.PER_EMPDIR_PEOPLE_N1';
            ad_ctx_ddl.sync_index(l_index);

           merge_per_asg(
                errbuf
               ,retcode
               ,l_eff_date
               ,p_multi_asg
           );

           merge_hr_orgs(
                errbuf
               ,retcode
               ,l_eff_date
           );

           merge_per_phones(
                errbuf
               ,retcode
               ,l_eff_date
           );

           merge_per_pos(
                errbuf
               ,retcode
               ,l_eff_date
           );

           merge_per_jobs(
                errbuf
               ,retcode
               ,l_eff_date
           );

           merge_per_locations(
                errbuf
               ,retcode
               ,l_eff_date
           );

           merge_per_loctl(
                errbuf
               ,retcode
               ,l_eff_date
           );

           --FIX FOR BUG#4380794
           IF p_image_refresh = 'Y' THEN
               merge_per_images(
                     errbuf
                    ,retcode
                  );
           END IF;
           --End of FIX FOR BUG#4380794

           compute_reports(
                errbuf
               ,retcode
               ,g_srcSystem
            );

    END IF;

    write_log(1, 'Process completed @: '|| to_char(SYSDATE, 'DD/MM/RRRR HH:MI:SS'));

END main;

function get_time (p_to_tz in varchar2) return varchar2 is
l_date date;
begin
fnd_date_tz.init_timezones_for_fnd_date;
l_date := FND_DATE.adjust_datetime(sysdate
                          ,FND_TIMEZONES.get_server_timezone_code
                          ,p_to_tz);

RETURN to_char(l_date, fnd_profile.value('ICX_DATE_FORMAT_MASK')||' HH24:MI');

EXCEPTION WHEN OTHERS THEN
        RETURN NULL;
end;

FUNCTION get_time (
   p_source_tz_id     IN NUMBER,
   p_dest_tz_id       IN NUMBER,
   p_source_day_time  IN DATE
) RETURN VARCHAR2 IS
-- local variables
x_dest_day_time     DATE;
x_return_status     VARCHAR2(10);
x_msg_count         NUMBER;
x_msg_data          VARCHAR2(300);
BEGIN
    hz_timezone_pub.get_time(
        p_api_version   => g_hz_api_api_version,
        p_init_msg_list => '',
        p_source_tz_id  => p_source_tz_id,
        p_dest_tz_id    => p_dest_tz_id,
        p_source_day_time => p_source_day_time,
        x_dest_day_time => x_dest_day_time,
        x_return_status => x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data
    );

    RETURN to_char(x_dest_day_time
                  ,fnd_profile.value('ICX_DATE_FORMAT_MASK')||' HH24:MI');

    EXCEPTION WHEN OTHERS THEN
        RETURN NULL;
END;


FUNCTION get_timezone_code(
  p_postal_code    IN   VARCHAR2,
  p_city           IN   VARCHAR2,
  p_state		   IN   VARCHAR2,
  p_country        IN   VARCHAR2
) RETURN VARCHAR2 IS
 l_timezone_id number;
begin
  l_timezone_id := get_timezone_id(p_postal_code, p_city, p_state, p_country);
  return fnd_timezones.get_code(l_timezone_id);
end;

FUNCTION get_timezone_id(
  p_postal_code    IN   VARCHAR2,
  p_city           IN   VARCHAR2,
  p_state		   IN   VARCHAR2,
  p_country        IN   VARCHAR2
) RETURN NUMBER IS
-- local variables
l_timezone_id       NUMBER(15);
x_return_status     VARCHAR2(10);
x_msg_count         NUMBER;
x_msg_data          VARCHAR2(300);

BEGIN
    hz_timezone_pub.get_timezone_id (
        p_api_version  => g_hz_api_api_version,
        p_init_msg_list => '',
        p_postal_code   => p_postal_code,
        p_city          => p_city,
        p_state		    => p_state,
        p_country       => p_country,
        x_timezone_id   => l_timezone_id,
        x_return_status => x_return_status,
        x_msg_count		=> x_msg_count,
        x_msg_data		=> x_msg_data
     );

    RETURN l_timezone_id;

    EXCEPTION WHEN OTHERS THEN
        RETURN NULL;
END get_timezone_id;

END PER_EMPDIR_SS;

/
