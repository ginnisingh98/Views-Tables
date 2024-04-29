--------------------------------------------------------
--  DDL for Package Body BIS_BIA_REFRESH_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BIA_REFRESH_REPORT" AS
/* $Header: BISRPTSB.pls 120.0 2005/06/01 14:24:02 appldev noship $  */
   version          CONSTANT CHAR (80)
            := '$Header: BISRPTSB.pls 120.0 2005/06/01 14:24:02 appldev noship $
';

   FUNCTION get_request_set_time_qry (
      p_page_parameter_tbl   IN   bis_pmv_page_parameter_tbl
   )
      RETURN VARCHAR2
   IS
      sql_str    VARCHAR2 (6000);
      vorderby   VARCHAR2 (200);
      vset       VARCHAR2 (2000);
   BEGIN
      FOR i IN 1 .. p_page_parameter_tbl.COUNT
      LOOP
         IF p_page_parameter_tbl (i).parameter_name =
                                            'DBI_REQUEST_SET+DBI_REQUEST_SET'
         THEN
            vset := p_page_parameter_tbl (i).parameter_id;
         END IF;

         IF    p_page_parameter_tbl (i).parameter_name = 'ORDER BY'
            OR p_page_parameter_tbl (i).parameter_name = 'ORDERBY'
         THEN
            vorderby := p_page_parameter_tbl (i).parameter_value;
         END IF;
      END LOOP;

      IF vset IS NULL OR vset IN ('',' ')
      THEN
         vset := 'All';
      END IF;

      IF NVL (vorderby, 'ORDERBY') = 'ORDERBY'
      THEN
         vorderby := ' UPPER(BIS_REQUEST_SET_DISPLAY_NAME) ASC';
      END IF;

      vorderby := REPLACE (vorderby, 'BIS_REQUEST_LAST_DATE', 'actual_completion_date');
      vorderby := REPLACE (vorderby, 'BIS_REQUEST_SET_DISPLAY_NAME','UPPER(user_request_set_name)');

      sql_str :=
            'SELECT request_set_name bis_request_set_short_name,
       user_request_set_name bis_request_set_display_name,
       meaning bis_request_refresh_type,
       request_set_id bis_request_set_id, request_id bis_request_id,
       user_name bis_requestor, bis_request_refresh_time,
       TO_CHAR (actual_completion_date,
                ''DD-MON-YYYY HH24:MI:SS''
               ) bis_request_last_date
  FROM (SELECT DISTINCT s.user_request_set_name, s.request_set_name, s.request_set_id,
               c.actual_completion_date
               ,c.request_id,
               u.user_name,
               bis_bia_refresh_report.time_interval(c.actual_completion_date
                                 - c.requested_start_date
                                ) bis_request_refresh_time,
               RANK () OVER (PARTITION BY s.request_set_id ORDER BY c.actual_completion_date DESC)
                                                                          pos,
               v.meaning
          FROM bis_request_set_objects_v o,
               fnd_request_sets_vl s,
               fnd_concurrent_requests c,
               fnd_concurrent_programs p,
               fnd_user u,
               bis_request_set_options r,
               fnd_common_lookups v
         WHERE o.object_type = ''PAGE''
           AND bis_impl_dev_pkg.get_function_by_page (o.object_name) IS NOT NULL
           AND s.application_id = 191
           AND s.request_set_name = o.request_set_name
           AND p.concurrent_program_id = c.concurrent_program_id
           AND p.application_id = 0
           AND p.concurrent_program_name = ''FNDRSSUB''
           AND c.argument1 = s.application_id
           AND c.argument2 = s.request_set_id
           AND c.status_code IN (''C'', ''G'', ''R'', ''I'')
           AND u.user_id = c.requested_by
           AND s.request_set_name = r.request_set_name
           AND r.option_name = ''REFRESH_MODE''
           AND r.option_value = v.lookup_code
           AND v.lookup_type = ''BIS_REFRESH_MODE''
           AND s.request_set_name =
                               DECODE (NVL (&DBI_REQUEST_SET+DBI_REQUEST_SET, ''All''),
                                       ''All'', s.request_set_name,
                                       NVL (&DBI_REQUEST_SET+DBI_REQUEST_SET, ''All'')
                                      )
            )
 WHERE pos = 1
      ORDER BY '
         || vorderby;
      RETURN sql_str;
   END get_request_set_time_qry;

   FUNCTION get_request_stage_time_qry (
      p_page_parameter_tbl   IN   bis_pmv_page_parameter_tbl
   )
      RETURN VARCHAR2
   IS
      sql_str                   VARCHAR2 (2000);
      vorderby                  VARCHAR2 (200);
      l_request_id              fnd_concurrent_requests.request_id%TYPE;
      l_request_set_id          fnd_request_sets_vl.request_set_id%TYPE;
      l_request_set_name        fnd_request_sets_vl.request_set_name%TYPE;
      l_user_request_set_name   fnd_request_sets_vl.user_request_set_name%TYPE;
   BEGIN
      FOR i IN 1 .. p_page_parameter_tbl.COUNT
      LOOP
         IF p_page_parameter_tbl (i).parameter_name = 'REQUEST_SET_ID'
         THEN
            l_request_set_id := p_page_parameter_tbl (i).parameter_value;
         ELSIF p_page_parameter_tbl (i).parameter_name = 'REQUEST_SET_NAME'
         THEN
            l_request_set_name := p_page_parameter_tbl (i).parameter_value;
         ELSIF p_page_parameter_tbl (i).parameter_name =
                                                       'USER_REQUEST_SET_NAME'
         THEN
            l_user_request_set_name :=
                                     p_page_parameter_tbl (i).parameter_value;
         ELSIF p_page_parameter_tbl (i).parameter_name = 'REQUEST_ID'
         THEN
            l_request_id := p_page_parameter_tbl (i).parameter_value;
         END IF;

         IF    p_page_parameter_tbl (i).parameter_name = 'ORDER BY'
            OR p_page_parameter_tbl (i).parameter_name = 'ORDERBY'
         THEN
            vorderby := p_page_parameter_tbl (i).parameter_value;
         END IF;
      END LOOP;

      -- if nvl(vOrderBy,'ORDERBY') = 'ORDERBY'  then vOrderBy := 'ELAPSED_TIME' ; end if;
      IF NVL (vorderby, 'ORDERBY') = 'ORDERBY'
      THEN
         vorderby := ' display_sequence ASC';
      END IF;

      IF INSTR (vorderby, 'BIS_REQUEST_SET_STAGE') >= 1
      THEN
         IF INSTR (vorderby, 'ASC') >= 1
         THEN
            vorderby := ' display_sequence ASC';
         ELSE
            vorderby := ' display_sequence DESC';
         END IF;
      END IF;

      sql_str :=
            'SELECT stg.request_set_id BIS_REQUEST_SET_ID,'
         || ''''
         || l_request_set_name
         || ''''
         || 'BIS_REQUEST_SET_NAME,'
         || ''''
         || l_request_id
         || ''''
         || 'BIS_PRIORITY_REQUEST_ID,
         stg.request_set_stage_id BIS_REQUEST_SET_STAGE_ID,
         stg.user_stage_name BIS_REQUEST_SET_STAGE_NAME,
         con.request_id BIS_REQUEST_ID,
         bis_bia_refresh_report.time_interval(con.actual_completion_date
                                 - con.requested_start_date
                                ) BIS_REQUEST_REFRESH_TIME

  FROM fnd_concurrent_requests con, fnd_request_set_stages_vl stg
 WHERE con.priority_request_id = '
         || l_request_id
         || ' AND con.priority_request_id = con.parent_request_id
   AND stg.request_set_id = '
         || l_request_set_id
         || 'AND con.argument2 = TO_CHAR (stg.request_set_id)
   AND con.argument3 = TO_CHAR (stg.request_set_stage_id) ORDER BY'
         || vorderby;
      RETURN sql_str;
   END get_request_stage_time_qry;

   FUNCTION get_request_object_time_qry (
      p_page_parameter_tbl   IN   bis_pmv_page_parameter_tbl
   )
      RETURN VARCHAR2
   IS
      sql_str                 VARCHAR2 (6000);
      vorderby                VARCHAR2 (200);
      l_priority_request_id   NUMBER (30);
      l_parent_request_id     NUMBER (30);
   BEGIN
      IF p_page_parameter_tbl.COUNT > 0
      THEN
         FOR i IN 1 .. p_page_parameter_tbl.COUNT
         LOOP
            IF p_page_parameter_tbl (i).parameter_name = 'PARENT_REQUEST_ID'
            THEN
               l_parent_request_id :=
                                     p_page_parameter_tbl (i).parameter_value;
            END IF;

            IF    p_page_parameter_tbl (i).parameter_name = 'ORDER BY'
               OR p_page_parameter_tbl (i).parameter_name = 'ORDERBY'
            THEN
               vorderby := p_page_parameter_tbl (i).parameter_value;
            END IF;
         END LOOP;
      END IF;

      IF NVL (vorderby, 'ORDERBY') = 'ORDERBY'
      THEN
         vorderby := 'display_sequence ASC, request_id ASC';
      END IF;

      IF INSTR (vorderby, 'BIS_REQUEST_SET_STAGE') >= 1
      THEN
         IF INSTR (vorderby, 'ASC') >= 1
         THEN
            vorderby := ' display_sequence ASC, request_id ASC';
         ELSE
            vorderby := ' display_sequence DESC, request_id DESC';
         END IF;
      END IF;

      IF l_parent_request_id IS NOT NULL
      THEN
         sql_str :=
               'SELECT
      request_set_stage_id BIS_REQUEST_SET_STAGE_ID
     , user_stage_name BIS_REQUEST_SET_STAGE_NAME
     , NVL(
         (
         SELECT fnd_lv.meaning
           FROM bis_obj_properties bobjp
              , fnd_common_lookups fnd_lv
          WHERE bobjp.object_name = m.object_name
            AND fnd_lv.lookup_type = ''BIS_OBJECT_TYPE''
            AND fnd_lv.lookup_code = bobjp.object_type
         )
       , (
         SELECT meaning
           FROM fnd_common_lookups
          WHERE lookup_type = ''BIS_OBJECT_TYPE''
            AND lookup_code = ''TABLE''
            AND m.object_name LIKE ''MLOG$_%''
         )
       ) BIS_REQUEST_OBJECT_TYPE
     , object_name BIS_REQUEST_OBJECT_NAME
     , request_id BIS_REQUEST_ID
     , user_concurrent_program_name BIS_CONCURRENT_DISPLAY_NAME
     , BIS_REQUEST_REFRESH_TIME
     , display_sequence BIS_REQUEST_STAGE_DISPLAY_SEQ
  FROM (
       SELECT rset.request_id
            , DECODE(cprog.concurrent_program_name, ''FNDGTST'', rset.argument2, brlog.object_name) object_name
            , stage.user_stage_name
            , stage.request_set_stage_id
            , stage.display_sequence
            , rset.actual_start_date
            , rset.actual_completion_date
            , bis_bia_refresh_report.time_interval(rset.actual_completion_date
                                 - rset.actual_start_date
                                ) BIS_REQUEST_REFRESH_TIME
            , cprog.user_concurrent_program_name
         FROM fnd_concurrent_requests rset
            , fnd_concurrent_requests rset_stg
            , fnd_concurrent_programs_vl cprog
            , fnd_request_set_stages_vl stage
            , bis_refresh_log brlog
        WHERE rset.priority_request_id = &REQUEST_ID+REQUEST_ID
          AND rset.parent_request_id NOT IN (-1, &REQUEST_ID+REQUEST_ID)
          AND rset.concurrent_program_id = cprog.concurrent_program_id
          AND rset.request_id = brlog.request_id(+)
          AND rset.parent_request_id = rset_stg.request_id
          AND rset_stg.argument3 = TO_CHAR(stage.request_set_stage_id)
          AND rset_stg.priority_request_id = &REQUEST_ID+REQUEST_ID
          AND rset.parent_request_id ='
            || l_parent_request_id
            || ') m  order by '
            || vorderby;
      ELSE
         sql_str :=
               'SELECT
      request_set_stage_id BIS_REQUEST_SET_STAGE_ID
     , user_stage_name BIS_REQUEST_SET_STAGE_NAME
     , NVL(
         (
         SELECT fnd_lv.meaning
           FROM bis_obj_properties bobjp
              , fnd_common_lookups fnd_lv
          WHERE bobjp.object_name = m.object_name
            AND fnd_lv.lookup_type = ''BIS_OBJECT_TYPE''
            AND fnd_lv.lookup_code = bobjp.object_type
         )
       , (
         SELECT meaning
           FROM fnd_common_lookups
          WHERE lookup_type = ''BIS_OBJECT_TYPE''
            AND lookup_code = ''TABLE''
            AND m.object_name LIKE ''MLOG$_%''
         )
       ) BIS_REQUEST_OBJECT_TYPE
     , object_name BIS_REQUEST_OBJECT_NAME
     , request_id BIS_REQUEST_ID
     , user_concurrent_program_name BIS_CONCURRENT_DISPLAY_NAME
     , BIS_REQUEST_REFRESH_TIME
     , display_sequence BIS_REQUEST_STAGE_DISPLAY_SEQ
  FROM (
       SELECT rset.request_id
            , DECODE(cprog.concurrent_program_name, ''FNDGTST'', rset.argument2, brlog.object_name) object_name
            , stage.user_stage_name
            , stage.request_set_stage_id
            , stage.display_sequence
            , rset.actual_start_date
            , rset.actual_completion_date
            , bis_bia_refresh_report.time_interval(rset.actual_completion_date
                                 - rset.actual_start_date
                                ) BIS_REQUEST_REFRESH_TIME
            , cprog.user_concurrent_program_name
         FROM fnd_concurrent_requests rset
            , fnd_concurrent_requests rset_stg
            , fnd_concurrent_programs_vl cprog
            , fnd_request_set_stages_vl stage
            , bis_refresh_log brlog
        WHERE rset.priority_request_id = &REQUEST_ID+REQUEST_ID
          AND rset.parent_request_id NOT IN (-1, &REQUEST_ID+REQUEST_ID)
          AND rset.concurrent_program_id = cprog.concurrent_program_id
          AND rset.request_id = brlog.request_id(+)
          AND rset.parent_request_id = rset_stg.request_id
          AND rset_stg.argument3 = TO_CHAR(stage.request_set_stage_id)
          AND rset_stg.priority_request_id = &REQUEST_ID+REQUEST_ID
          AND stage.request_set_stage_id in (
                  DECODE (NVL (&DBI_REQUEST_SET+DBI_REQUEST_STAGE, ''ALL''),
                                       ''ALL'', stage.request_set_stage_id,
                                       NVL (&DBI_REQUEST_SET+DBI_REQUEST_STAGE, ''ALL''))
                                      )
       ) m  order by '
            || vorderby;
      END IF;

      RETURN sql_str;
   END get_request_object_time_qry;

   FUNCTION time_interval (p_interval IN NUMBER)
      RETURN VARCHAR2
   IS
      l_result   VARCHAR2 (30) := '';
      l_dummy    PLS_INTEGER   := 0;

      FUNCTION format (p_value IN NUMBER)
         RETURN VARCHAR2
      IS
         l_str   VARCHAR2 (30) := '';
      BEGIN
         IF p_value < 10
         THEN
            l_str := '0' || TO_CHAR (p_value);
         ELSE
            l_str := p_value;
         END IF;

         RETURN l_str;
      END format;
   BEGIN
      l_dummy := FLOOR (p_interval) * 24 + MOD (FLOOR (p_interval * 24), 24);
      l_result := format (l_dummy) || ':';
      l_dummy := MOD (FLOOR (p_interval * 24 * 60), 60);
      l_result := l_result || format (l_dummy) || ':';
      l_dummy := MOD (FLOOR (p_interval * 24 * 60 * 60), 60);
      l_result := l_result || format (l_dummy);
      RETURN l_result;
   END time_interval;
END BIS_BIA_REFRESH_REPORT;


/
