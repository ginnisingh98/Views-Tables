--------------------------------------------------------
--  DDL for Package Body PN_CC_SYNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_CC_SYNC_PKG" AS
  -- $Header: PNCCSYNB.pls 120.5 2007/08/10 05:49:06 hrodda ship $

/*===========================================================================+
 | PROCEDURE
 |    cc_sync_with_hr
 |
 | DESCRIPTION
 |     Main procedure for  concurrent program 'Cost Center Synchronization
 |     with HR'
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |                    pnp_util_func.get_segment_column_name
 |                    pnp_util_func.get_location_code
 |                    pn_space_assign_emp_pkg.update_row
 |
 | ARGUMENTS  : IN:
 |                    p_as_of_date
 |                    p_locn_type
 |                    p_locn_code_from
 |                    p_locn_code_to
 |                    p_emp_cost_center
 |              OUT:
 |                    Std. concurrent program out params (errbuf, retcode)
 |
 |
 | MODIFICATION HISTORY
 |
 |     13-NOV-03  Vikas Mehta  Created
 |     26-OCT-05  Hareesha     o ATG mandated changes for SQL literals using
 |                               dbms_sql.
 |     04-APR-06  Hareesha     o Bug 5119241 Modified call to
 |                               PN_SPACE_ASSIGN_EMP_PKG.Update_Row to pass
 |                               new CC.
 |     30-JUN-06  Hareesha     o Bug #5262982 Select org_id too in the query
 |                               along with all other columns.The new record
 |                               created was not being populated with org_id.
 |     10-AUG-07  Hareesha     o Bug 6168505 , this package invalid at macerich's instance,
 |                               because, asg_rec is referring to baseview rowtype,
 |                               instead of _all rowtype.
 +===========================================================================*/

  PROCEDURE cc_sync_with_hr (
            errbuf                  OUT NOCOPY VARCHAR2,
            retcode                 OUT NOCOPY VARCHAR2,
            p_as_of_date            IN VARCHAR2,
            p_locn_type             IN pn_locations.location_type_lookup_code%TYPE,
            p_locn_code_from        IN pn_locations.location_code%TYPE,
            p_locn_code_to          IN pn_locations.location_code%TYPE,
            p_emp_cost_center       IN pn_space_assign_emp.cost_center_code%TYPE
            ) IS


   asg_rec                      pn_space_assign_emp_ALL%ROWTYPE;
   l_query                      VARCHAR2(2000);
   l_where_clause               VARCHAR2(2000);
   l_where_clause_loc           VARCHAR2(2000) := NULL;
   l_count_total                NUMBER := 0;
   l_count_success              NUMBER := 0;
   l_count_failure              NUMBER := 0;
   l_commit_count               NUMBER := 0;
   l_log_context                VARCHAR2(2000);
   l_desc                       VARCHAR2(100) := 'pn_cc_sync_pkg.cc_sync_with_hr';
   l_as_of_date                 DATE;
   l_cost_center                VARCHAR2(30) := NULL;
   l_person_id                  pn_space_assign_emp.person_id%TYPE := 0 ;
   l_column_name                VARCHAR2(30) := NULL;
   l_last_person_processed      pn_space_assign_emp.person_id%TYPE := 0 ;
   l_last_updated_by            pn_space_assign_emp.last_updated_by%TYPE ;
   l_last_update_login          pn_space_assign_emp.last_update_login%TYPE ;
   l_err_msg1                   VARCHAR2(2000);
   l_source_id                  VARCHAR2(30) := 'PNCCSYNC';
   l_batch_size                 NUMBER := 5000 ;
   l_emp_name                   per_people_f.full_name%TYPE;
   l_location_code              pn_locations.location_code%TYPE;
   l_success_msg                VARCHAR2(1000) := NULL;
   l_failure_msg                VARCHAR2(1000) := NULL;
   i                            NUMBER := 0;
   l_errbuf                     VARCHAR2(200) := NULL ;
   l_message                    VARCHAR2(1000) := NULL ;
   l_out_date                   DATE ;
   l_cursor                     INTEGER;
   l_rows                       INTEGER;
   l_count                      INTEGER;
   x_as_of_date                 DATE;
   l_locn_code_from             VARCHAR2(90);
   l_locn_code_to               VARCHAR2(90);
   l_locn_type                  VARCHAR2(30);
   l_emp_cost_center            VARCHAR2(30);
   x_last_person_processed      pn_space_assign_emp.person_id%TYPE := 0 ;


   CURSOR get_emp_name (p_employee_id IN NUMBER, p_as_of_date DATE) IS
        SELECT
          FULL_NAME
        FROM
          PER_PEOPLE_F
        WHERE person_id = p_employee_id
          AND TRUNC(p_as_of_date) BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
          AND EMPLOYEE_NUMBER IS NOT NULL ;

   TYPE failed_tbl_type IS TABLE OF VARCHAR2(1000)
      INDEX BY BINARY_INTEGER;
   failure_table                failed_tbl_type;

   TYPE success_tbl_type IS TABLE OF VARCHAR2(1000)
      INDEX BY BINARY_INTEGER;
   success_table                success_tbl_type;


BEGIN


  pnp_debug_pkg.debug(l_desc||' (+)');


  --Print all input parameters

  fnd_message.set_name ('PN','PN_HRSYNC_INP_PARAMS');
  fnd_message.set_token ('DATE', to_char(fnd_date.canonical_to_date(p_as_of_date),'mm/dd/yyyy'));
  fnd_message.set_token ('LOC_TYPE', p_locn_type);
  fnd_message.set_token ('LOC_CODE_FROM', p_locn_code_from);
  fnd_message.set_token ('LOC_CODE_TO', p_locn_code_to);
  fnd_message.set_token ('COST_CENTER', p_emp_cost_center);
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  l_log_context        := ' Getting as of Date..';
  l_as_of_date         := trunc(fnd_date.canonical_to_date(p_as_of_date));

  l_log_context        := 'Initializing WHO variables..';
  l_last_updated_by    := nvl(fnd_profile.VALUE ('USER_ID'), 0);
  l_last_update_login  := nvl(fnd_profile.value('LOGIN_ID'),0);

  l_log_context        := ' Getting segment column ' ;
  l_column_name        := pnp_util_func.get_segment_column_name(pn_mo_cache_utils.get_current_org_id);

  l_log_context        := ' Defining sub-query for location ';

  l_cursor := dbms_sql.open_cursor;
  x_as_of_date := l_as_of_date;

  l_where_clause_loc   := ' WHERE :x_as_of_date between trunc(active_start_date) and trunc(active_end_date) ';

  /*  Construct sub-query for location based on input parameters */

  IF p_locn_type IS NULL THEN

   /* No need to traverse the hierarchy.
      Construct where clause based on location_code range */

     IF p_locn_code_from IS NOT NULL AND p_locn_code_to IS NOT NULL THEN
        l_locn_code_from := p_locn_code_from;
        l_locn_code_to := p_locn_code_to;
        l_where_clause_loc := l_where_clause_loc || ' AND location_code between :l_locn_code_from AND :l_locn_code_to ';

     ELSIF p_locn_code_from IS NOT NULL AND p_locn_code_to IS NULL THEN
        l_locn_code_from := p_locn_code_from;
        l_where_clause_loc := l_where_clause_loc || ' AND location_code >= :l_locn_code_from ';

     ELSIF p_locn_code_from IS NULL AND p_locn_code_to IS NOT NULL THEN
        l_locn_code_to := p_locn_code_to;
        l_where_clause_loc := l_where_clause_loc || ' AND location_code <=  :l_locn_code_to ';

     END IF;

  ELSE

  /* Need to traverse hierarchy to identify children.
     Apply location_code range for identifying top nodes only */

  l_locn_type := p_locn_type;
  l_where_clause_loc := l_where_clause_loc ||
                        ' START WITH location_type_lookup_code = :l_locn_type ';

   IF p_locn_code_from IS NOT NULL AND p_locn_code_to IS NOT NULL THEN
      l_locn_code_from := p_locn_code_from;
      l_locn_code_to := p_locn_code_to;
      l_where_clause_loc := l_where_clause_loc || ' AND location_code between :l_locn_code_from AND :l_locn_code_to ';

   ELSIF p_locn_code_from IS NOT NULL AND p_locn_code_to IS NULL THEN
      l_locn_code_from := p_locn_code_from;
      l_where_clause_loc := l_where_clause_loc || ' AND location_code >= :l_locn_code_from ';

   ELSIF p_locn_code_from IS NULL AND p_locn_code_to IS NOT NULL THEN
      l_locn_code_to := p_locn_code_to;
      l_where_clause_loc := l_where_clause_loc || ' AND location_code <=  :l_locn_code_to ';

   END IF;

  l_where_clause_loc := l_where_clause_loc ||
                        ' AND :x_as_of_date BETWEEN trunc(active_start_date) AND trunc(active_end_date)
                          CONNECT BY PRIOR location_id = parent_location_id ';

  END IF;

  /* Construct query for main cursor */

  l_log_context := ' Defining query for cursor ';

  l_query :=
  'SELECT
  EMP_SPACE_ASSIGN_ID
 ,LOCATION_ID
 ,PERSON_ID
 ,PROJECT_ID
 ,TASK_ID
 ,EMP_ASSIGN_START_DATE
 ,EMP_ASSIGN_END_DATE
 ,COST_CENTER_CODE
 ,ALLOCATED_AREA_PCT
 ,ALLOCATED_AREA
 ,UTILIZED_AREA
 ,EMP_SPACE_COMMENTS
 ,LAST_UPDATE_DATE
 ,LAST_UPDATED_BY
 ,CREATION_DATE
 ,CREATED_BY
 ,LAST_UPDATE_LOGIN
 ,ATTRIBUTE_CATEGORY
 ,ATTRIBUTE1
 ,ATTRIBUTE2
 ,ATTRIBUTE3
 ,ATTRIBUTE4
 ,ATTRIBUTE5
 ,ATTRIBUTE6
 ,ATTRIBUTE7
 ,ATTRIBUTE8
 ,ATTRIBUTE9
 ,ATTRIBUTE10
 ,ATTRIBUTE11
 ,ATTRIBUTE12
 ,ATTRIBUTE13
 ,ATTRIBUTE14
 ,ATTRIBUTE15
 ,ORG_ID
 FROM PN_SPACE_ASSIGN_EMP ';

  x_last_person_processed := l_last_person_processed ;
  l_where_clause := ' WHERE :x_as_of_date BETWEEN trunc(emp_assign_start_date) AND
                        trunc(NVL(emp_assign_end_date, TO_DATE(''12/31/4712'', ''MM/DD/YYYY'')))
                      AND person_id >= :x_last_person_processed' ;

  IF p_emp_cost_center IS NOT NULL THEN
     l_emp_cost_center := p_emp_cost_center;
     l_where_clause := l_where_clause ||
                        ' AND cost_center_code = :l_emp_cost_center ';

  END IF;

  l_where_clause := l_where_clause || ' AND location_id IN (SELECT location_id FROM pn_locations ' ;
  l_where_clause := l_where_clause || l_where_clause_loc;
  l_where_clause := l_where_clause|| ' )';
  l_where_clause := l_where_clause || ' ORDER BY person_id ';
  l_query := l_query || l_where_clause ;

  /* uncomment for debugging purposes */
  /*pnp_debug_pkg.log('l_query is : '|| l_query);*/

  dbms_sql.parse(l_cursor, l_query, dbms_sql.native);

  dbms_sql.bind_variable
            (l_cursor,'x_as_of_date',x_as_of_date );

  dbms_sql.bind_variable
            (l_cursor,'x_last_person_processed',x_last_person_processed );

  IF p_emp_cost_center IS NOT NULL THEN
     dbms_sql.bind_variable
            (l_cursor,'l_emp_cost_center',l_emp_cost_center );
  END IF;

  IF p_locn_type IS NULL THEN
     IF p_locn_code_from IS NOT NULL AND p_locn_code_to IS NOT NULL THEN
        dbms_sql.bind_variable
            (l_cursor,'l_locn_code_from',l_locn_code_from );
        dbms_sql.bind_variable
            (l_cursor,'l_locn_code_to',l_locn_code_to );
     ELSIF p_locn_code_from IS NOT NULL AND p_locn_code_to IS NULL THEN
        dbms_sql.bind_variable
            (l_cursor,'l_locn_code_from',l_locn_code_from );
     ELSIF p_locn_code_from IS NULL AND p_locn_code_to IS NOT NULL THEN
        dbms_sql.bind_variable
            (l_cursor,'l_locn_code_to',l_locn_code_to );
     END IF;
  ELSE
    dbms_sql.bind_variable
            (l_cursor,'l_locn_type',l_locn_type );
    dbms_sql.bind_variable
            (l_cursor,'x_as_of_date',x_as_of_date );

    IF p_locn_code_from IS NOT NULL AND p_locn_code_to IS NOT NULL THEN
        dbms_sql.bind_variable
            (l_cursor,'l_locn_code_from',l_locn_code_from );
        dbms_sql.bind_variable
            (l_cursor,'l_locn_code_to',l_locn_code_to );
    ELSIF p_locn_code_from IS NOT NULL AND p_locn_code_to IS NULL THEN
        dbms_sql.bind_variable
            (l_cursor,'l_locn_code_from',l_locn_code_from );
    ELSIF p_locn_code_from IS NULL AND p_locn_code_to IS NOT NULL THEN
        dbms_sql.bind_variable
            (l_cursor,'l_locn_code_to',l_locn_code_to );
    END IF;
  END IF;

  dbms_sql.define_column (l_cursor, 1,asg_rec.EMP_SPACE_ASSIGN_ID);
  dbms_sql.define_column (l_cursor, 2,asg_rec.LOCATION_ID);
  dbms_sql.define_column (l_cursor, 3,asg_rec.PERSON_ID);
  dbms_sql.define_column (l_cursor, 4,asg_rec.PROJECT_ID);
  dbms_sql.define_column (l_cursor, 5,asg_rec.TASK_ID);
  dbms_sql.define_column (l_cursor, 6,asg_rec.EMP_ASSIGN_START_DATE);
  dbms_sql.define_column (l_cursor, 7,asg_rec.EMP_ASSIGN_END_DATE);
  dbms_sql.define_column (l_cursor, 8,asg_rec.COST_CENTER_CODE,30);
  dbms_sql.define_column (l_cursor, 9,asg_rec.ALLOCATED_AREA_PCT);
  dbms_sql.define_column (l_cursor, 10,asg_rec.ALLOCATED_AREA);
  dbms_sql.define_column (l_cursor, 11,asg_rec.UTILIZED_AREA);
  dbms_sql.define_column (l_cursor, 12,asg_rec.EMP_SPACE_COMMENTS,2000);
  dbms_sql.define_column (l_cursor, 13,asg_rec.LAST_UPDATE_DATE);
  dbms_sql.define_column (l_cursor, 14,asg_rec.LAST_UPDATED_BY);
  dbms_sql.define_column (l_cursor, 15,asg_rec.CREATION_DATE);
  dbms_sql.define_column (l_cursor, 16,asg_rec.CREATED_BY);
  dbms_sql.define_column (l_cursor, 17,asg_rec.LAST_UPDATE_LOGIN);
  dbms_sql.define_column (l_cursor, 18,asg_rec.ATTRIBUTE_CATEGORY,30);
  dbms_sql.define_column (l_cursor, 19,asg_rec.ATTRIBUTE1,150);
  dbms_sql.define_column (l_cursor, 20,asg_rec.ATTRIBUTE2,150);
  dbms_sql.define_column (l_cursor, 21,asg_rec.ATTRIBUTE3,150);
  dbms_sql.define_column (l_cursor, 22,asg_rec.ATTRIBUTE4,150);
  dbms_sql.define_column (l_cursor, 23,asg_rec.ATTRIBUTE5,150);
  dbms_sql.define_column (l_cursor, 24,asg_rec.ATTRIBUTE6,150);
  dbms_sql.define_column (l_cursor, 25,asg_rec.ATTRIBUTE7,150);
  dbms_sql.define_column (l_cursor, 26,asg_rec.ATTRIBUTE8,150);
  dbms_sql.define_column (l_cursor, 27,asg_rec.ATTRIBUTE9,150);
  dbms_sql.define_column (l_cursor, 28,asg_rec.ATTRIBUTE10,150);
  dbms_sql.define_column (l_cursor, 29,asg_rec.ATTRIBUTE11,150);
  dbms_sql.define_column (l_cursor, 30,asg_rec.ATTRIBUTE12,150);
  dbms_sql.define_column (l_cursor, 31,asg_rec.ATTRIBUTE13,150);
  dbms_sql.define_column (l_cursor, 32,asg_rec.ATTRIBUTE14,150);
  dbms_sql.define_column (l_cursor, 33,asg_rec.ATTRIBUTE15,150);
  dbms_sql.define_column (l_cursor, 34,asg_rec.ORG_ID);

  l_rows   := dbms_sql.execute(l_cursor);

  LOOP

    l_count := dbms_sql.fetch_rows( l_cursor );

    EXIT WHEN l_count <> 1;

    dbms_sql.column_value (l_cursor, 1,asg_rec.EMP_SPACE_ASSIGN_ID);
    dbms_sql.column_value (l_cursor, 2,asg_rec.LOCATION_ID);
    dbms_sql.column_value (l_cursor, 3,asg_rec.PERSON_ID);
    dbms_sql.column_value (l_cursor, 4,asg_rec.PROJECT_ID);
    dbms_sql.column_value (l_cursor, 5,asg_rec.TASK_ID);
    dbms_sql.column_value (l_cursor, 6,asg_rec.EMP_ASSIGN_START_DATE);
    dbms_sql.column_value (l_cursor, 7,asg_rec.EMP_ASSIGN_END_DATE);
    dbms_sql.column_value (l_cursor, 8,asg_rec.COST_CENTER_CODE);
    dbms_sql.column_value (l_cursor, 9,asg_rec.ALLOCATED_AREA_PCT);
    dbms_sql.column_value (l_cursor, 10,asg_rec.ALLOCATED_AREA);
    dbms_sql.column_value (l_cursor, 11,asg_rec.UTILIZED_AREA);
    dbms_sql.column_value (l_cursor, 12,asg_rec.EMP_SPACE_COMMENTS);
    dbms_sql.column_value (l_cursor, 13,asg_rec.LAST_UPDATE_DATE);
    dbms_sql.column_value (l_cursor, 14,asg_rec.LAST_UPDATED_BY);
    dbms_sql.column_value (l_cursor, 15,asg_rec.CREATION_DATE);
    dbms_sql.column_value (l_cursor, 16,asg_rec.CREATED_BY);
    dbms_sql.column_value (l_cursor, 17,asg_rec.LAST_UPDATE_LOGIN);
    dbms_sql.column_value (l_cursor, 18,asg_rec.ATTRIBUTE_CATEGORY);
    dbms_sql.column_value (l_cursor, 19,asg_rec.ATTRIBUTE1);
    dbms_sql.column_value (l_cursor, 20,asg_rec.ATTRIBUTE2);
    dbms_sql.column_value (l_cursor, 21,asg_rec.ATTRIBUTE3);
    dbms_sql.column_value (l_cursor, 22,asg_rec.ATTRIBUTE4);
    dbms_sql.column_value (l_cursor, 23,asg_rec.ATTRIBUTE5);
    dbms_sql.column_value (l_cursor, 24,asg_rec.ATTRIBUTE6);
    dbms_sql.column_value (l_cursor, 25,asg_rec.ATTRIBUTE7);
    dbms_sql.column_value (l_cursor, 26,asg_rec.ATTRIBUTE8);
    dbms_sql.column_value (l_cursor, 27,asg_rec.ATTRIBUTE9);
    dbms_sql.column_value (l_cursor, 28,asg_rec.ATTRIBUTE10);
    dbms_sql.column_value (l_cursor, 29,asg_rec.ATTRIBUTE11);
    dbms_sql.column_value (l_cursor, 30,asg_rec.ATTRIBUTE12);
    dbms_sql.column_value (l_cursor, 31,asg_rec.ATTRIBUTE13);
    dbms_sql.column_value (l_cursor, 32,asg_rec.ATTRIBUTE14);
    dbms_sql.column_value (l_cursor, 33,asg_rec.ATTRIBUTE15);
    dbms_sql.column_value (l_cursor, 34,asg_rec.ORG_ID);
    l_log_context := 'opening cursor ';

    PN_SPACE_ASSIGN_EMP_PKG.tlempinfo := asg_rec;


     /* Get cost center from HR */
     IF l_person_id <> asg_rec.person_id THEN
         pn_cc_sync_pkg.get_cc_as_of_date(asg_rec.person_id, l_column_name, fnd_date.canonical_to_date(p_as_of_date), l_emp_name, l_cost_center);

        /* Get employee name if any issues with finding cost center */
        IF l_emp_name IS NULL THEN
          OPEN get_emp_name(asg_rec.person_id, l_as_of_date);
          FETCH get_emp_name INTO l_emp_name;
          CLOSE get_emp_name;
        END IF;

        l_person_id := asg_rec.person_id;
        pnp_debug_pkg.log('Processing data for person:  '|| l_person_id || ' HR Cost Center : ' || l_cost_center);

     END IF;

     /* Comapre cost centers and make changes if necessary */

     IF l_cost_center IS NULL THEN

       fnd_message.set_name ('PN', 'PN_CC_NOT_FOUND_MSG');
       l_err_msg1 := fnd_message.get;
       l_failure_msg :=  rpad(nvl(l_emp_name,' '), 50, ' ') ||
                         rpad(asg_rec.emp_assign_start_date, 15, ' ') ||
                         rpad(nvl(to_char(asg_rec.emp_assign_end_date),' '), 15, ' ') ||
                         rpad(pnp_util_func.get_location_code(asg_rec.location_id, l_as_of_date), 30, ' ') ||
                         rpad(asg_rec.cost_center_code, 30, ' ') ||
                         l_err_msg1 ;
        failure_table(failure_table.COUNT) := l_failure_msg;
        l_count_failure := l_count_failure + 1;
        l_count_total := l_count_total + 1;

     ELSIF asg_rec.cost_center_code <> l_cost_center THEN

       l_log_context := ' inserting/updating data for assignment_id : ' || asg_rec.emp_space_assign_id ;
       pnp_debug_pkg.log(l_log_context);


      BEGIN

       PN_SPACE_ASSIGN_EMP_PKG.tlempinfo := asg_rec;

       /*  Check if assignmnet start date is same as as_of_date.
           We do not need to insert new record but only need to update cost ceneter in this case.  */

       IF l_as_of_date = trunc(asg_rec.emp_assign_start_date) THEN

         /* Call Update_Row in CORRECT mode */

         PN_SPACE_ASSIGN_EMP_PKG.Update_Row(
               asg_rec.emp_space_assign_id,
               asg_rec.attribute1,
               asg_rec.attribute2,
               asg_rec.attribute3,
               asg_rec.attribute4,
               asg_rec.attribute5,
               asg_rec.attribute6,
               asg_rec.attribute7,
               asg_rec.attribute8,
               asg_rec.attribute9,
               asg_rec.attribute10,
               asg_rec.attribute11,
               asg_rec.attribute12,
               asg_rec.attribute13,
               asg_rec.attribute14,
               asg_rec.attribute15,
               asg_rec.location_id,
               asg_rec.person_id,
               asg_rec.project_id,
               asg_rec.task_id,
               asg_rec.emp_assign_start_date,
               asg_rec.emp_assign_end_date,
               l_cost_center,
               asg_rec.allocated_area_pct,
               asg_rec.allocated_area,
               asg_rec.utilized_area,
               asg_rec.emp_space_comments,
               asg_rec.attribute_category,
               sysdate,
               l_last_updated_by,
               l_last_update_login,
               'CORRECT',
               l_out_date,
               l_source_id   /*  Use process identifier for source column */
                 ) ;


       ELSE
       /* Need to update current record and insert new record
          Call Update_Row in UPDATE mode */

        PN_SPACE_ASSIGN_EMP_PKG.tlempinfo.source := l_source_id || '_' || asg_rec.emp_space_assign_id ;

         PN_SPACE_ASSIGN_EMP_PKG.Update_Row(
               asg_rec.emp_space_assign_id,
               asg_rec.attribute1,
               asg_rec.attribute2,
               asg_rec.attribute3,
               asg_rec.attribute4,
               asg_rec.attribute5,
               asg_rec.attribute6,
               asg_rec.attribute7,
               asg_rec.attribute8,
               asg_rec.attribute9,
               asg_rec.attribute10,
               asg_rec.attribute11,
               asg_rec.attribute12,
               asg_rec.attribute13,
               asg_rec.attribute14,
               asg_rec.attribute15,
               asg_rec.location_id,
               asg_rec.person_id,
               asg_rec.project_id,
               asg_rec.task_id,
               l_as_of_date,                    /* Use As of Date as start date */
               asg_rec.emp_assign_end_date,
               l_cost_center,                   /* Use HR cost center */
               asg_rec.allocated_area_pct,
               asg_rec.allocated_area,
               asg_rec.utilized_area,
               asg_rec.emp_space_comments,
               asg_rec.attribute_category,
               sysdate,
               l_last_updated_by,
               l_last_update_login,
               'UPDATE',
               l_out_date,
               l_source_id   /*  Use process identifier for source column */
                ) ;

       END IF;

        l_log_context := ' constructing l_success_msg ...';

        l_success_msg :=        rpad(nvl(l_emp_name, ' '), 50, ' ') ||
                                rpad(l_as_of_date, 15, ' ') ||
                                rpad(nvl(to_char(asg_rec.emp_assign_end_date),' '), 15, ' ') ||
                                rpad(pnp_util_func.get_location_code(asg_rec.location_id, l_as_of_date), 30, ' ') ||
                                rpad(asg_rec.cost_center_code, 30, ' ') ||
                                rpad(l_cost_center, 30, ' ') ;

        success_table(success_table.COUNT) := l_success_msg;
        l_count_success := l_count_success + 1;
        l_count_total := l_count_total + 1;
        l_commit_count := l_commit_count + 1;

        IF l_commit_count > l_batch_size then
          l_log_context := ' doing batch commit...';
          commit;
          l_log_context := ' done batch commit...current person_id : ' || asg_rec.person_id;
          pnp_debug_pkg.log(l_log_context);
          l_commit_count := 0;
          l_last_person_processed := asg_rec.person_id;
          l_log_context := ' Cursor closing and opening again...' ;
          pnp_debug_pkg.log(l_log_context);

       END IF;

       EXCEPTION
         WHEN OTHERS THEN

         l_log_context := ' constructing l_failure_msg ...';
         l_err_msg1 := SQLERRM || ' : ' || SQLCODE ;
         l_failure_msg :=  rpad(nvl(l_emp_name, ' '), 50, ' ') ||
                         rpad(asg_rec.emp_assign_start_date, 15, ' ') ||
                         rpad(nvl(to_char(asg_rec.emp_assign_end_date),' '), 15, ' ') ||
                         rpad(pnp_util_func.get_location_code(asg_rec.location_id, l_as_of_date), 30, ' ') ||
                         rpad(asg_rec.cost_center_code, 30, ' ')
                         || l_err_msg1 ;
         failure_table(failure_table.COUNT) := l_failure_msg;
         l_count_failure := l_count_failure + 1;
         l_count_total := l_count_total + 1;

      END;

    END IF;

   END LOOP;

-- Commit last batch

 l_log_context := ' commiting last batch...';
 commit;
 l_log_context := ' commited last batch...';
 pnp_debug_pkg.log(l_log_context);

 l_log_context := ' printing summary ...';

 pnp_debug_pkg.put_log_msg('===============================================================================');


 fnd_message.set_name ('PN','PN_CAFM_LOCATION_TOTAL');
 fnd_message.set_token ('TOTAL', TO_CHAR(l_count_total));
 pnp_debug_pkg.put_log_msg(fnd_message.get);

 fnd_message.set_name ('PN','PN_CAFM_LOCATION_SUCCESS');
 fnd_message.set_token ('SUCCESS', TO_CHAR(l_count_success));
 pnp_debug_pkg.put_log_msg(fnd_message.get);

 fnd_message.set_name ('PN','PN_CAFM_LOCATION_FAILURE');
 fnd_message.set_token ('FAILURE', TO_CHAR(l_count_failure));
 pnp_debug_pkg.put_log_msg(fnd_message.get);

 pnp_debug_pkg.put_log_msg('===============================================================================');


-- Print failed records

  IF failure_table.COUNT > 0 THEN
    l_log_context := ' printing failure table...';
    pnp_debug_pkg.put_log_msg(' ');
    pnp_debug_pkg.put_log_msg(' ');

    fnd_message.set_name ('PN','PN_HRSYNC_FAIL_DTLS');
    pnp_debug_pkg.put_log_msg(fnd_message.get);

    fnd_message.set_name ('PN','PN_HRSYNC_REC_DTLS_NAME');
    l_message := fnd_message.get;
    l_message := l_message||'                                              ';

    fnd_message.set_name ('PN','PN_HRSYNC_REC_DTLS_FROM');
    l_message := l_message||fnd_message.get||'           ';

    fnd_message.set_name ('PN','PN_HRSYNC_REC_DTLS_TO');
    l_message := l_message||fnd_message.get||'             ';

    fnd_message.set_name ('PN','PN_HRSYNC_REC_DTLS_LOC');
    l_message := l_message||fnd_message.get||'                     ';

    fnd_message.set_name ('PN','PN_HRSYNC_REC_DTLS_CC');
    l_message := l_message||fnd_message.get||'                    ';

    fnd_message.set_name ('PN','PN_ERR');
    l_message := l_message||fnd_message.get||'                        ';

    pnp_debug_pkg.put_log_msg(l_message);
    pnp_debug_pkg.put_log_msg(' ');


    pnp_debug_pkg.put_log_msg('==============================================================================================================================================================');

 i := 0;
 FOR i IN 0 .. (failure_table.COUNT - 1) LOOP
   pnp_debug_pkg.put_log_msg(failure_table(i));
 END LOOP;

 pnp_debug_pkg.put_log_msg('==============================================================================================================================================================');


  END IF;

-- Print succeeded records
  l_message := NULL;

  IF success_table.COUNT > 0 THEN
        l_log_context := ' printing success table...';
        pnp_debug_pkg.put_log_msg(' ');
        pnp_debug_pkg.put_log_msg(' ');
        fnd_message.set_name ('PN','PN_HRSYNC_SUC_DTLS');
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        fnd_message.set_name ('PN','PN_HRSYNC_REC_DTLS_NAME');
        l_message := fnd_message.get;
        l_message := l_message||'                                              ';

        fnd_message.set_name ('PN','PN_HRSYNC_REC_DTLS_FROM');
        l_message := l_message||fnd_message.get||'           ';

        fnd_message.set_name ('PN','PN_HRSYNC_REC_DTLS_TO');
        l_message := l_message||fnd_message.get||'             ';

        fnd_message.set_name ('PN','PN_HRSYNC_REC_DTLS_LOC');
        l_message := l_message||fnd_message.get||'                     ';

        fnd_message.set_name ('PN','PN_HRSYNC_REC_DTLS_OLD_CC');
        l_message := l_message||fnd_message.get||'                    ';

        fnd_message.set_name ('PN','PN_HRSYNC_REC_DTLS_NEW_CC');
        l_message := l_message||fnd_message.get||'                    ';

        pnp_debug_pkg.put_log_msg(l_message);
 pnp_debug_pkg.put_log_msg(' ');


 pnp_debug_pkg.put_log_msg('==============================================================================================================================================================');



 i := 0;
 FOR i IN 0 .. (success_table.COUNT - 1) LOOP
    pnp_debug_pkg.put_log_msg(success_table(i));
 END LOOP;

  pnp_debug_pkg.put_log_msg('==============================================================================================================================================================');


  END IF;

  pnp_debug_pkg.debug(l_desc||' (-)');

EXCEPTION
   WHEN OTHERS THEN

      pnp_debug_pkg.log(l_desc || ': Error while ' || l_log_context);
      Errbuf  := SQLERRM || ' : ' || SQLCODE ;
      raise;
END cc_sync_with_hr;


/*============================================================================+
 | PROCEDURE
 |    get_cc_as_of_date
 |
 | DESCRIPTION
 |    RETURN the cost center of an employee at HR assignment level on
 |    'As of Date' alongwith full name of an employee
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |      pnp_util_func.get_segment_column_name
 |
 | ARGUMENTS  : IN:
 |                    p_employee_id
 |                    p_column_name
 |                    p_as_of_date
 |              OUT:
 |                    p_cost_center
 |                    p_emp_name
 |
 |
 | NOTES      : Currently being used in concurrent program
 |              'Cost Center Synchronization with HR'
 |              (called by pn_cc_sync_pkg.cc_sync_with_hr)
 |
 | MODIFICATION HISTORY
 |
 |     13-NOV-03  Vikas Mehta     Created
 |     26-OCT-05  Hareesha        o ATG mandated changes for SQL literals
 |                                  using dbms_sql.
 |     22-NOV-05  Hareesha        o Replaced _all with secured synonyms/
 |                                  base views.
 |     04-APR-06  Hareesha        o Bug 5119241 Use SQL literal for l_column_name
 |                                  instead of bind variable since usage of
 |                                  bind varaible selscts
 |                                  the column name,not the column value
 +=============================================================================*/


PROCEDURE get_cc_as_of_date (
  p_employee_id  IN  NUMBER,
  p_column_name  IN  VARCHAR2,
  p_as_of_date   IN  DATE,
  p_emp_name     OUT NOCOPY VARCHAR2,
  p_cost_center  OUT NOCOPY VARCHAR2
  ) IS

   l_column_name      VARCHAR2 (25) := NULL;
   sql_statement      VARCHAR2(2000);
   l_code_comb_id     PER_ALL_ASSIGNMENTS_F.default_code_comb_id%TYPE;
   l_cursor           INTEGER;
   l_statement        VARCHAR2(10000);
   l_rows             INTEGER;
   l_count            INTEGER;
   x_code_comb_id     PER_ALL_ASSIGNMENTS_F.default_code_comb_id%TYPE;


   CURSOR get_default_code_comb_id (p_employee_id IN NUMBER, p_as_of_date IN DATE) IS
        SELECT
          A.DEFAULT_CODE_COMB_ID,
          P.FULL_NAME
        FROM
          PER_PEOPLE_F P,
          PER_ALL_ASSIGNMENTS_F A,
          PER_PERIODS_OF_SERVICE B
        WHERE
          A.PERSON_ID = P.PERSON_ID
          AND A.person_id = p_employee_id
          AND A.PRIMARY_FLAG = 'Y'
          AND A.ASSIGNMENT_TYPE = 'E'
          AND A.PERIOD_OF_SERVICE_ID = B.PERIOD_OF_SERVICE_ID
          AND TRUNC(p_as_of_date) BETWEEN P.EFFECTIVE_START_DATE AND P.EFFECTIVE_END_DATE
          AND TRUNC(p_as_of_date) BETWEEN A.EFFECTIVE_START_DATE AND A.EFFECTIVE_END_DATE
          AND (trunc(B.ACTUAL_TERMINATION_DATE)>= trunc(p_as_of_date) or B.ACTUAL_TERMINATION_DATE is null)
          AND P.EMPLOYEE_NUMBER IS NOT NULL
          AND A.DEFAULT_CODE_COMB_ID IS NOT NULL ;

BEGIN

  IF p_column_name IS NULL THEN
        l_column_name := pnp_util_func.get_segment_column_name(pn_mo_cache_utils.get_current_org_id);
  ELSE
        l_column_name := p_column_name;
  END IF;

  FOR rec IN get_default_code_comb_id(p_employee_id, p_as_of_date) LOOP
     l_code_comb_id := rec.DEFAULT_CODE_COMB_ID;
     p_emp_name := rec.FULL_NAME;
  END LOOP;

  IF l_column_name IS NOT NULL THEN

      l_cursor := dbms_sql.open_cursor;

      l_statement :=
      ' SELECT '|| l_column_name ||
      ' FROM gl_code_combinations
        WHERE  code_combination_id = :x_code_comb_id ';

      dbms_sql.parse(l_cursor, l_statement, dbms_sql.native);

       /* uncomment for debugging purposes */
      /*pnp_debug_pkg.log(' l_statement_4:'||l_statement);
      pnp_debug_pkg.log(' l_code_comb_id:'||l_code_comb_id);
      pnp_debug_pkg.log(' l_column_name:'||l_column_name);*/

      dbms_sql.bind_variable
            (l_cursor,'x_code_comb_id',l_code_comb_id );

      dbms_sql.define_column (l_cursor, 1,p_cost_center,30);

      l_rows   := dbms_sql.execute(l_cursor);

      LOOP

        l_count := dbms_sql.fetch_rows( l_cursor );
        EXIT WHEN l_count <> 1;
        dbms_sql.column_value (l_cursor, 1,p_cost_center);

      END LOOP;

      IF dbms_sql.is_open (l_cursor) THEN
        dbms_sql.close_cursor (l_cursor);
      END IF;
  END IF;



EXCEPTION
  WHEN OTHERS THEN
      p_cost_center := NULL;
END get_cc_as_of_date;

------------------------------
-- End of Package
------------------------------
END PN_CC_SYNC_PKG;

/
