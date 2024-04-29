--------------------------------------------------------
--  DDL for Package Body PNRX_SP_ASSIGN_BY_LEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNRX_SP_ASSIGN_BY_LEASE" AS
/* $Header: PNRXLESB.pls 120.2 2005/12/01 14:35:27 appldev ship $ */

   FUNCTION compare_assign_emplease(P_LOCATION_ID  IN NUMBER,
                                    P_PERSON_ID    IN NUMBER,
                                    P_COST_CENTER  IN VARCHAR2,
                                    P_REQUEST_ID   IN NUMBER)
   RETURN BOOLEAN IS
      v_var1              VARCHAR2(1);

   BEGIN

      SELECT 'X'
      INTO   v_var1
      FROM   pn_space_assign_lease_itf
      WHERE  location_id = P_LOCATION_ID
      AND    person_id(+)   = P_PERSON_ID
      AND    cost_center = P_COST_CENTER
      AND    request_id  = P_REQUEST_ID;

      RETURN TRUE;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN

      RETURN FALSE;

   END compare_assign_emplease;

   FUNCTION compare_assign_custlease(P_LOCATION_ID IN NUMBER,
                                     P_ACCOUNT_ID  IN VARCHAR2,
                                     P_REQUEST_ID  IN NUMBER)
   RETURN BOOLEAN IS
      v_var2              VARCHAR2(1);

   BEGIN

      SELECT 'Y'
      INTO   v_var2
      FROM   pn_space_assign_lease_itf
      WHERE  location_id = P_LOCATION_ID
      AND    customer_account = P_ACCOUNT_ID
      AND    request_id = P_REQUEST_ID;

      RETURN TRUE;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN

      RETURN FALSE;

   END compare_assign_custlease;

-------------------------------------------------------------------------------
-- PROCDURE     : PN_SPACE_ASSIGN_LEASE
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_distributions with _ALL table.
-- 27-OCT-05  sdmahesh o ATG Mandated changes for SQL literals
-------------------------------------------------------------------------------

PROCEDURE pn_space_assign_lease(
           lease_number_low            IN                    VARCHAR2,
           lease_number_high           IN                    VARCHAR2,
           as_of_date                  IN                    DATE,
           report_type                 IN                    VARCHAR2,
           l_request_id                IN                    NUMBER,
           l_user_id                   IN                    NUMBER,
           retcode                     OUT NOCOPY            VARCHAR2,
           errbuf                      OUT NOCOPY            VARCHAR2
                      )
 IS
   l_login_id                          NUMBER;
   type cur_typ is ref cursor;
   c_e_pn                              CUR_TYP;
   c_c_pn                              CUR_TYP;
   c_e_assign_pn                       CUR_TYP;
   c_c_assign_pn                       CUR_TYP;
   c_e_prop                            CUR_TYP;
   c_c_prop                            CUR_TYP;
   emp_pn                              CUR_TYP;
   cust_pn                             CUR_TYP;
   query_str                           VARCHAR2(20000);
 --declare the 'WHERE clauses here........'
   lease_number_WHERE_clause           VARCHAR2(4000);
   l_one                               NUMBER default 1;
   l_two                               NUMBER default 2;
   l_three                             NUMBER default 3;
 --declare all columns as variables here
   V_LEASE_ID                          pn_space_assign_lease_itf.LEASE_ID%TYPE;
   V_LEASE_NAME                        pn_space_assign_lease_itf.LEASE_NAME%TYPE;
   V_LEASE_NUMBER                      pn_space_assign_lease_itf.LEASE_NUMBER%TYPE;
   V_LEASE_COM_DATE                    pn_space_assign_lease_itf.LEASE_COMMENCEMENT_DATE%TYPE;
   V_LEASE_TERM_DATE                   pn_space_assign_lease_itf.LEASE_TERMINATION_DATE%TYPE;
   V_LOCATION_ID                       pn_space_assign_lease_itf.LOCATION_ID%TYPE;
   V_LOCATION_ID_1                     pn_space_assign_lease_itf.LOCATION_ID%TYPE;
   V_LOCATION_ID_2                     pn_space_assign_lease_itf.LOCATION_ID%TYPE;
   V_LOCATION_TYPE                     pn_space_assign_lease_itf.LOCATION_TYPE%TYPE;
   V_LOCATION_NAME                     pn_space_assign_lease_itf.LOCATION_NAME%TYPE;
   V_LOCATION_CODE                     pn_space_assign_lease_itf.LOCATION_CODE%TYPE;
   V_SPACE_TYPE                        pn_space_assign_lease_itf.SPACE_TYPE%TYPE;
   V_PROPERTY_CODE                     pn_space_assign_lease_itf.PROPERTY_CODE%TYPE;
   V_PERSON_ID                         pn_space_assign_lease_itf.PERSON_ID%TYPE;
   V_COST_CENTER                       pn_space_assign_lease_itf.COST_CENTER%TYPE;
   V_EMPLOYEE_PROJECT_NUMBER           pn_space_assign_lease_itf.EMPLOYEE_PROJECT_NUMBER%TYPE;
   V_EMPLOYEE_TASK_NUMBER              pn_space_assign_lease_itf.EMPLOYEE_TASK_NUMBER%TYPE;
   V_EMPLOYEE_ASSIGNED_FROM            pn_space_assign_lease_itf.EMPLOYEE_ASSIGNED_FROM%TYPE;
   V_EMPLOYEE_ASSIGNED_TO              pn_space_assign_lease_itf.EMPLOYEE_ASSIGNED_TO%TYPE;
   V_CUSTOMER_ACCOUNT                  pn_space_assign_lease_itf.CUSTOMER_ACCOUNT%TYPE;
   V_EXP_ACCOUNT                       NUMBER;
   V_CUSTOMER_ACCOUNT_ID               NUMBER;
   V_CUSTOMER_PROJECT_NUMBER           pn_space_assign_lease_itf.CUSTOMER_PROJECT_NUMBER%TYPE;
   V_CUSTOMER_TASK_NUMBER              pn_space_assign_lease_itf.CUSTOMER_TASK_NUMBER%TYPE;
   V_CUSTOMER_ASSIGNED_FROM            pn_space_assign_lease_itf.CUSTOMER_ASSIGNED_FROM%TYPE;
   V_CUSTOMER_ASSIGNED_TO              pn_space_assign_lease_itf.CUSTOMER_ASSIGNED_TO%TYPE;
   V_CUSTOMER_NAME                     pn_space_assign_lease_itf.CUSTOMER_NAME%TYPE;
   V_CUSTOMER_SITE                     pn_space_assign_lease_itf.CUSTOMER_SITE%TYPE;
   V_CUSTOMER_CATEGORY                 pn_space_assign_lease_itf.CUSTOMER_CATEGORY%TYPE;
   V_RENTABLE_AREA                     pn_space_assign_lease_itf.RENTABLE_AREA%TYPE;
   V_USABLE_AREA                       pn_space_assign_lease_itf.USABLE_AREA%TYPE;
   V_ASSIGNABLE_AREA                   pn_space_assign_lease_itf.ASSIGNABLE_AREA%TYPE;
   V_COMMON_AREA                       pn_space_assign_lease_itf.COMMON_AREA%TYPE;
   V_EMPLOYEE_ASSIGNED_AREA            pn_space_assign_lease_itf.EMPLOYEE_ASSIGNED_AREA%TYPE;
   V_CUSTOMER_ASSIGNED_AREA            pn_space_assign_lease_itf.CUSTOMER_ASSIGNED_AREA%TYPE;
   V_VACANT_AREA                       NUMBER;
   V_ATTRIBUTE_CATEGORY                pn_space_assign_lease_itf.TEN_ATTRIBUTE_CATEGORY%TYPE;
   V_ATTRIBUTE1                        pn_space_assign_lease_itf.TEN_ATTRIBUTE1%TYPE;
   V_ATTRIBUTE2                        pn_space_assign_lease_itf.TEN_ATTRIBUTE2%TYPE;
   V_ATTRIBUTE3                        pn_space_assign_lease_itf.TEN_ATTRIBUTE3%TYPE;
   V_ATTRIBUTE4                        pn_space_assign_lease_itf.TEN_ATTRIBUTE4%TYPE;
   V_ATTRIBUTE5                        pn_space_assign_lease_itf.TEN_ATTRIBUTE5%TYPE;
   V_ATTRIBUTE6                        pn_space_assign_lease_itf.TEN_ATTRIBUTE6%TYPE;
   V_ATTRIBUTE7                        pn_space_assign_lease_itf.TEN_ATTRIBUTE7%TYPE;
   V_ATTRIBUTE8                        pn_space_assign_lease_itf.TEN_ATTRIBUTE8%TYPE;
   V_ATTRIBUTE9                        pn_space_assign_lease_itf.TEN_ATTRIBUTE9%TYPE;
   V_ATTRIBUTE10                       pn_space_assign_lease_itf.TEN_ATTRIBUTE10%TYPE;
   V_ATTRIBUTE11                       pn_space_assign_lease_itf.TEN_ATTRIBUTE11%TYPE;
   V_ATTRIBUTE12                       pn_space_assign_lease_itf.TEN_ATTRIBUTE12%TYPE;
   V_ATTRIBUTE13                       pn_space_assign_lease_itf.TEN_ATTRIBUTE13%TYPE;
   V_ATTRIBUTE14                       pn_space_assign_lease_itf.TEN_ATTRIBUTE14%TYPE;
   V_ATTRIBUTE15                       pn_space_assign_lease_itf.TEN_ATTRIBUTE15%TYPE;
   V_LAST_UPDATE_DATE                  pn_space_assign_lease_itf.LAST_UPDATE_DATE%TYPE;
   V_LAST_UPDATED_BY                   pn_space_assign_lease_itf.LAST_UPDATED_BY%TYPE;
   V_LAST_UPDATE_LOGIN                 pn_space_assign_lease_itf.LAST_UPDATE_LOGIN%TYPE;
   V_CREATION_DATE                     pn_space_assign_lease_itf.CREATION_DATE%TYPE;
   V_CREATED_BY                        pn_space_assign_lease_itf.CREATED_BY%TYPE;
 --declare the record type for the function here.........
   v_emp_data                          PNP_UTIL_FUNC.emp_hr_data_rec := NULL;
   v_code_data                         PNP_UTIL_FUNC.location_name_rec := NULL;
   l_date                              DATE:=fnd_date.canonical_to_date(
                                          '4712/12/31 00:00:00' );
   v_compare_emp                       BOOLEAN;
   v_compare_cust                      BOOLEAN;
   v_coa_id                            NUMBER;
   v_loc_type                          VARCHAR2(100)  ;                     --BUG#2226865
   v_loc_area                          PNP_UTIL_FUNC.PN_LOCATION_AREA_REC;  --bug#2226865
   v_space_area                        PNP_UTIL_FUNC.PN_SPACE_AREA_REC;     --bug#2226865
   l_count_1                           NUMBER := 0;
   l_count_2                           NUMBER := 0;
   l_count_3                           NUMBER := 0;

   l_lease_number_low                  VARCHAR2(30);
   l_lease_number_high                 VARCHAR2(30);
   l_statement                         VARCHAR2(10000);
   l_cursor                            INTEGER;
   l_rows                              INTEGER;
   l_count                             INTEGER;

BEGIN

  PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_leaseConditions(+)');
--Initialise status parameters...
  retcode:=0;
  errbuf:='';
  fnd_profile.get('LOGIN_ID', l_login_id);
  SELECT  chart_of_accounts_id INTO v_coa_id
  FROM GL_SETS_OF_BOOKS
  WHERE set_of_books_id= TO_NUMBER(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                   pn_mo_cache_utils.get_current_org_id));
  l_lease_number_low := lease_number_low;
  l_lease_number_high := lease_number_high;
 --lease number conditions.....
 IF lease_number_low IS NOT NULL AND lease_number_high IS NOT NULL THEN
   lease_number_WHERE_clause := ' AND les.lease_num  BETWEEN :l_lease_number_low AND
                                  :l_lease_number_high';
  ELSIF lease_number_low IS NULL AND lease_number_high IS NOT NULL THEN
   lease_number_WHERE_clause := ' AND les.lease_num = :l_lease_number_high';
  ELSIF lease_number_low IS NOT NULL AND lease_number_high IS NULL THEN
   lease_number_WHERE_clause := ' AND les.lease_num = :l_lease_number_low';
  ELSE
   lease_number_WHERE_clause := ' AND 1 = 1 ';
 END IF;

--validate report type...
 PNP_DEBUG_PKG.put_log_msg('report_type:'||report_type);
 IF report_type IN ('EMPLOYEE','ALL') THEN
   pnp_debug_pkg.put_log_msg('pn_sp_assign_Emp(+)');
  l_statement :=
  'SELECT
   distinct
   ten.location_id                                  LOCATION_ID,
   les.lease_id                                     LEASE_ID,
   les.name                                         LEASE_NAME,
   les.lease_num                                    LEASE_NUMBER,
   lda.lease_commencement_date                      LEASE_COMMENCEMENT_DATE,
   lda.lease_termination_date                       LEASE_TERMINATION_DATE,
   ten.attribute_category                           ATTRIBUTE_CATEGORY,
   ten.attribute1                                   ATTRIBUTE1,
   ten.attribute2                                   ATTRIBUTE2,
   ten.attribute3                                   ATTRIBUTE3,
   ten.attribute4                                   ATTRIBUTE4,
   ten.attribute5                                   ATTRIBUTE5,
   ten.attribute6                                   ATTRIBUTE6,
   ten.attribute7                                   ATTRIBUTE7,
   ten.attribute8                                   ATTRIBUTE8,
   ten.attribute9                                   ATTRIBUTE9,
   ten.attribute10                                  ATTRIBUTE10,
   ten.attribute11                                  ATTRIBUTE11,
   ten.attribute12                                  ATTRIBUTE12,
   ten.attribute13                                  ATTRIBUTE13,
   ten.attribute14                                  ATTRIBUTE14,
   ten.attribute15                                  ATTRIBUTE15
   FROM    pn_leases          les,
           pn_lease_details_all    lda,
           pn_tenancies_all        ten
   WHERE   ten.lease_id = les.lease_id
   AND     ten.lease_id = lda.lease_id '
   ||lease_number_WHERE_clause;
  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor,l_statement,dbms_sql.native);


  IF lease_number_low IS NOT NULL AND lease_number_high IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_number_low',l_lease_number_low);
   dbms_sql.bind_variable(l_cursor,'l_lease_number_high',l_lease_number_high);
  ELSIF lease_number_low IS NULL AND lease_number_high IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_number_high',l_lease_number_high);
  ELSIF lease_number_low IS NOT NULL AND lease_number_high IS NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_number_low',l_lease_number_low);
  END IF;

  dbms_sql.define_column (l_cursor,1,V_LOCATION_ID_1);
  dbms_sql.define_column (l_cursor,2,V_LEASE_ID);
  dbms_sql.define_column (l_cursor,3,V_LEASE_NAME,50);
  dbms_sql.define_column (l_cursor,4,V_LEASE_NUMBER,30);
  dbms_sql.define_column (l_cursor,5,V_LEASE_COM_DATE);
  dbms_sql.define_column (l_cursor,6,V_LEASE_TERM_DATE);
  dbms_sql.define_column (l_cursor,7,V_ATTRIBUTE_CATEGORY,30);
  dbms_sql.define_column (l_cursor,8,V_ATTRIBUTE1,150);
  dbms_sql.define_column (l_cursor,9,V_ATTRIBUTE2,150);
  dbms_sql.define_column (l_cursor,10,V_ATTRIBUTE3,150);
  dbms_sql.define_column (l_cursor,11,V_ATTRIBUTE4,150);
  dbms_sql.define_column (l_cursor,12,V_ATTRIBUTE5,150);
  dbms_sql.define_column (l_cursor,13,V_ATTRIBUTE6,150);
  dbms_sql.define_column (l_cursor,14,V_ATTRIBUTE7,150);
  dbms_sql.define_column (l_cursor,15,V_ATTRIBUTE8,150);
  dbms_sql.define_column (l_cursor,16,V_ATTRIBUTE9,150);
  dbms_sql.define_column (l_cursor,17,V_ATTRIBUTE10,150);
  dbms_sql.define_column (l_cursor,18,V_ATTRIBUTE11,150);
  dbms_sql.define_column (l_cursor,19,V_ATTRIBUTE12,150);
  dbms_sql.define_column (l_cursor,20,V_ATTRIBUTE13,150);
  dbms_sql.define_column (l_cursor,21,V_ATTRIBUTE14,150);
  dbms_sql.define_column (l_cursor,22,V_ATTRIBUTE15,150);

  l_rows   := dbms_sql.execute(l_cursor);

   pnp_debug_pkg.put_log_msg('pn_sp_assign_Emp: c_e_pn Loop(+)');
   l_count_1 := 0;
 LOOP
     l_count_1 := l_count_1 + 1;
     l_count := dbms_sql.fetch_rows( l_cursor );
        EXIT WHEN l_count <> 1;

     dbms_sql.column_value(l_cursor,1,V_LOCATION_ID_1);
     dbms_sql.column_value(l_cursor,2,V_LEASE_ID);
     dbms_sql.column_value(l_cursor,3,V_LEASE_NAME);
     dbms_sql.column_value(l_cursor,4,V_LEASE_NUMBER);
     dbms_sql.column_value(l_cursor,5,V_LEASE_COM_DATE);
     dbms_sql.column_value(l_cursor,6,V_LEASE_TERM_DATE);
     dbms_sql.column_value(l_cursor,7,V_ATTRIBUTE_CATEGORY);
     dbms_sql.column_value(l_cursor,8,V_ATTRIBUTE1);
     dbms_sql.column_value(l_cursor,9,V_ATTRIBUTE2);
     dbms_sql.column_value(l_cursor,10,V_ATTRIBUTE3);
     dbms_sql.column_value(l_cursor,11,V_ATTRIBUTE4);
     dbms_sql.column_value(l_cursor,12,V_ATTRIBUTE5);
     dbms_sql.column_value(l_cursor,13,V_ATTRIBUTE6);
     dbms_sql.column_value(l_cursor,14,V_ATTRIBUTE7);
     dbms_sql.column_value(l_cursor,15,V_ATTRIBUTE8);
     dbms_sql.column_value(l_cursor,16,V_ATTRIBUTE9);
     dbms_sql.column_value(l_cursor,17,V_ATTRIBUTE10);
     dbms_sql.column_value(l_cursor,18,V_ATTRIBUTE11);
     dbms_sql.column_value(l_cursor,19,V_ATTRIBUTE12);
     dbms_sql.column_value(l_cursor,20,V_ATTRIBUTE13);
     dbms_sql.column_value(l_cursor,21,V_ATTRIBUTE14);
     dbms_sql.column_value(l_cursor,22,V_ATTRIBUTE15);

OPEN c_e_assign_pn FOR
SELECT
  distinct
  loc.location_id                                                          LOCATION_ID,
  fl1.meaning                                                              LOCATION_TYPE,
  NVL(NVL(loc.building, loc.floor), loc.office)                            LOCATION_NAME,
  loc.location_code                                                        LOCATION_CODE,
  loc.location_type_lookup_code                                            Loc_type     , --BUG#2226865
  fl.meaning                                                               USAGE_TYPE,
  loc.rentable_area                                                        RENTABLE_AREA,
  loc.usable_area                                                          USABLE_AREA,
  loc.assignable_area                                                      ASSIGNABLE_AREA,
  loc.common_area                                                          COMMON_AREA,
  loc.last_update_date                                                     LAST_UPDATE_DATE,
  loc.last_updated_by                                                      LAST_UPDATED_BY,
  loc.last_update_login                                                    LAST_UPDATE_LOGIN,
  loc.creation_date                                                        CREATION_DATE,
  loc.created_by                                                           CREATED_BY
FROM pn_locations_all loc,
     fnd_lookups  fl,
     fnd_lookups  fl1
WHERE fl.lookup_code(+) = loc.space_type_lookup_code
AND   fl.lookup_type(+) = 'PN_SPACE_TYPE'
AND   fl1.lookup_code(+)= loc.location_type_lookup_code
AND   fl1.lookup_type(+)= 'PN_LOCATION_TYPE'
AND   loc.location_id IN (SELECT loc.location_id FROM pn_locations_all loc
                          WHERE  active_start_date <= as_of_date
                          AND  active_end_date   >= as_of_date
                          START WITH loc.location_id = V_LOCATION_ID_1
                          CONNECT BY PRIOR loc.location_id = loc.parent_location_id
                          AND as_of_date between prior active_start_date AND prior active_end_date);
   PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_Emp: c_e_pn# '||l_count_1||': c_e_assign_pn Loop(+)');
   l_count_2 := 0;
LOOP
     l_count_2 := l_count_2 + 1;
     FETCH c_e_assign_pn into V_LOCATION_ID_2                   ,
                     V_LOCATION_TYPE                            ,
                     V_LOCATION_NAME                            ,
                     V_LOCATION_CODE                            ,
                     v_loc_type                                 ,  --BUG#2226865
                     V_SPACE_TYPE                               ,
                     V_LOC_AREA.RENTABLE_AREA                   ,  --bug#2226865
                     V_LOC_AREA.USABLE_AREA                     ,  --bug#2226865
                     V_LOC_AREA.ASSIGNABLE_AREA                 ,  --bug#2226865
                     V_LOC_AREA.COMMON_AREA                     ,  --bug#2226865
                     V_LAST_UPDATE_DATE                         ,
                     V_LAST_UPDATED_BY                          ,
                     V_LAST_UPDATE_LOGIN                        ,
                     V_CREATION_DATE                            ,
                     V_CREATED_BY                               ;
EXIT WHEN c_e_assign_pn%NOTFOUND;
OPEN emp_pn FOR
SELECT
  distinct
  emp.location_id                                  LOCATION_ID,
  emp.person_id                                    PERSON_ID,
  emp.cost_center_code                             COST_CENTER,
  pa.segment1                                      EMPLOYEE_PROJECT_NUMBER,
  pat.task_name                                    EMPLOYEE_TASK_NUMBER,
  emp.allocated_area                               EMPLOYEE_ASSIGNED_AREA,
  emp.emp_assign_start_date                        EMPLOYEE_ASSIGNED_FROM,
  emp.emp_assign_end_date                          EMPLOYEE_ASSIGNED_TO,
  NULL                                             CUSTOMER_ACCOUNT,
  NULL                                             CUSTOMER_PROJECT_NUMBER,
  NULL                                             CUSTOMER_TASK_NUMBER,
  0                                                CUSTOMER_ASSIGNED_AREA,
  NULL                                             CUSTOMER_ASSIGNED_FROM,
  NULL                                             CUSTOMER_ASSIGNED_TO,
  NULL                                             CUSTOMER_NAME,
  NULL                                             CUSTOMER_SITE,
  NULL                                             CUSTOMER_CATEGORY
FROM     pa_projects_all pa,
         pa_tasks pat,
         pn_space_assign_emp_all emp
WHERE    emp.location_id  = V_LOCATION_ID_2
AND      pa.project_id(+) = emp.project_id
AND      pat.task_id(+)   = emp.task_id
    AND as_of_date  between emp.emp_assign_start_date AND NVL(emp.emp_assign_end_date, l_date);
   PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_Emp: c_e_pn# '||l_count_1||': c_e_assign_pn# '
                             ||l_count_2||': emp_pn Loop(+)');
   l_count_3 := 0;
 LOOP
     l_count_3 := l_count_3 + 1;
     FETCH emp_pn into V_LOCATION_ID,
                     V_PERSON_ID,
                     V_COST_CENTER,
                     V_EMPLOYEE_PROJECT_NUMBER,
                     V_EMPLOYEE_TASK_NUMBER,
                     V_SPACE_AREA.ALLOCATED_AREA_EMP,  --bug#2226865
                     V_EMPLOYEE_ASSIGNED_FROM,
                     V_EMPLOYEE_ASSIGNED_TO,
                     V_CUSTOMER_ACCOUNT,
                     V_CUSTOMER_PROJECT_NUMBER,
                     V_CUSTOMER_TASK_NUMBER,
                     V_SPACE_AREA.ALLOCATED_AREA_CUST,  --bug#2226865
                     V_CUSTOMER_ASSIGNED_FROM,
                     V_CUSTOMER_ASSIGNED_TO,
                     V_CUSTOMER_NAME,
                     V_CUSTOMER_SITE,
                     V_CUSTOMER_CATEGORY;
    EXIT WHEN emp_pn%notfound;
    v_compare_emp:=compare_assign_emplease(V_LOCATION_ID, V_PERSON_ID, V_COST_CENTER, l_request_id);
    IF NOT(v_compare_emp) THEN

    v_code_data:=pnp_util_func.get_location_name(V_LOCATION_ID, AS_OF_DATE);
    v_emp_data:= pnp_util_func.get_emp_hr_data(V_PERSON_ID);
      --------------bug#2226865-----------------
   IF V_LOC_TYPE in ('BUILDING' ,'LAND','FLOOR','PARCEL') THEN
      PNP_UTIL_FUNC.get_area(v_location_id , v_loc_type ,NULL,AS_OF_DATE,V_LOC_AREA,V_SPACE_AREA);
   END IF;
   -----------bug#2226865--------
    INSERT INTO pn_space_assign_lease_itf
    (LEASE_ID                        ,
     LEASE_NAME                      ,
     LEASE_NUMBER                    ,
     LEASE_COMMENCEMENT_DATE         ,
     LEASE_TERMINATION_DATE          ,
     LOCATION_ID                     ,
     LOCATION_TYPE                   ,
     LOCATION_NAME                   ,
     LOCATION_CODE                   ,
     SPACE_TYPE                      ,
     PROPERTY_CODE                   ,
     PROPERTY_NAME                   ,
     BUILDING_LOCATION_CODE          ,
     BUILDING_OR_LAND_NAME           ,
     FLOOR_LOCATION_CODE             ,
     FLOOR_OR_PARCEL_NAME            ,
     OFFICE_LOCATION_CODE            ,
     OFFICE_OR_SECTION_NAME          ,
     RENTABLE_AREA                   ,
     USABLE_AREA                     ,
     ASSIGNABLE_AREA                 ,
     COMMON_AREA                     ,
     PERSON_ID                       ,
     EMPLOYEE_NAME                   ,
     COST_CENTER                     ,
     EMPLOYEE_NUMBER                 ,
     EMPLOYEE_TYPE                   ,
     EMPLOYEE_CATEGORY               ,
     EMPLOYEE_POSITION               ,
     EMPLOYEE_PROJECT_NUMBER         ,
     EMPLOYEE_TASK_NUMBER            ,
     EMPLOYEE_ASSIGNED_AREA          ,
     EMPLOYEE_VACANT_AREA            ,
     EMPLOYEE_ASSIGNED_FROM          ,
     EMPLOYEE_ASSIGNED_TO            ,
     CUSTOMER_NAME                   ,
     CUSTOMER_SITE                   ,
     CUSTOMER_CATEGORY               ,
     CUSTOMER_ACCOUNT                ,
     CUSTOMER_PROJECT_NUMBER         ,
     CUSTOMER_TASK_NUMBER            ,
     CUSTOMER_ASSIGNED_AREA          ,
     CUSTOMER_ASSIGNED_FROM          ,
     CUSTOMER_ASSIGNED_TO            ,
     TEN_ATTRIBUTE_CATEGORY          ,
     TEN_ATTRIBUTE1                  ,
     TEN_ATTRIBUTE2                  ,
     TEN_ATTRIBUTE3                  ,
     TEN_ATTRIBUTE4                  ,
     TEN_ATTRIBUTE5                  ,
     TEN_ATTRIBUTE6                  ,
     TEN_ATTRIBUTE7                  ,
     TEN_ATTRIBUTE8                  ,
     TEN_ATTRIBUTE9                  ,
     TEN_ATTRIBUTE10                 ,
     TEN_ATTRIBUTE11                 ,
     TEN_ATTRIBUTE12                 ,
     TEN_ATTRIBUTE13                 ,
     TEN_ATTRIBUTE14                 ,
     TEN_ATTRIBUTE15                 ,
     LAST_UPDATE_DATE                ,
     LAST_UPDATED_BY                 ,
     LAST_UPDATE_LOGIN               ,
     CREATION_DATE                   ,
     CREATED_BY,
     REQUEST_ID           )
    VALUES
    ( V_LEASE_ID                                                  ,
      V_LEASE_NAME                                                ,
      V_LEASE_NUMBER                                              ,
      V_LEASE_COM_DATE                                            ,
      V_LEASE_TERM_DATE                                           ,
      V_LOCATION_ID                                               ,
      V_LOCATION_TYPE                                             ,
      V_LOCATION_NAME                                             ,
      V_LOCATION_CODE                                             ,
      V_SPACE_TYPE                                                ,
      v_code_data.PROPERTY_CODE                                   ,
      v_code_data.PROPERTY_NAME                                   ,
      v_code_data.BUILDING_LOCATION_CODE                          ,
      v_code_data.BUILDING                                        ,
      v_code_data.FLOOR_LOCATION_CODE                             ,
      v_code_data.FLOOR                                           ,
      v_code_data.OFFICE_LOCATION_CODE                            ,
      v_code_data.OFFICE                                          ,
      V_LOC_AREA.RENTABLE_AREA                                    ,--bug#2226865
      V_LOC_AREA.USABLE_AREA                                      ,--bug#2226865
      V_LOC_AREA.ASSIGNABLE_AREA                                  ,--bug#2226865
      V_LOC_AREA.COMMON_AREA                                      ,--bug#2226865
      V_PERSON_ID                                                 ,
      v_emp_data.FULL_NAME                                        ,
      V_COST_CENTER                                               ,
      v_emp_data.EMPLOYEE_NUMBER                                  ,
      v_emp_data.EMPLOYEE_TYPE                                    ,
      v_emp_data.EMPLOYMENT_CATEGORY_MEANING                      ,
      v_emp_data.POSITION                                         ,
      V_EMPLOYEE_PROJECT_NUMBER                                   ,
      V_EMPLOYEE_TASK_NUMBER                                      ,
      V_SPACE_AREA.ALLOCATED_AREA_EMP                             ,   --bug#2226865
      V_SPACE_AREA.Vacant_area                                    ,   --bug#2226865
      V_EMPLOYEE_ASSIGNED_FROM                                    ,
      V_EMPLOYEE_ASSIGNED_TO                                      ,
      V_CUSTOMER_NAME                                             ,
      V_CUSTOMER_SITE                                             ,
      V_CUSTOMER_CATEGORY                                         ,
      V_CUSTOMER_ACCOUNT                                          ,
      V_CUSTOMER_PROJECT_NUMBER                                   ,
      V_CUSTOMER_TASK_NUMBER                                      ,
      V_SPACE_AREA.ALLOCATED_AREA_CUST                            ,   --bug#2226865
      V_CUSTOMER_ASSIGNED_FROM                                    ,
      V_CUSTOMER_ASSIGNED_TO                                      ,
      V_ATTRIBUTE_CATEGORY                                        ,
      V_ATTRIBUTE1                                                ,
      V_ATTRIBUTE2                                                ,
      V_ATTRIBUTE3                                                ,
      V_ATTRIBUTE4                                                ,
      V_ATTRIBUTE5                                                ,
      V_ATTRIBUTE6                                                ,
      V_ATTRIBUTE7                                                ,
      V_ATTRIBUTE8                                                ,
      V_ATTRIBUTE9                                                ,
      V_ATTRIBUTE10                                               ,
      V_ATTRIBUTE11                                               ,
      V_ATTRIBUTE12                                               ,
      V_ATTRIBUTE13                                               ,
      V_ATTRIBUTE14                                               ,
      V_ATTRIBUTE15                                               ,
      V_LAST_UPDATE_DATE                                          ,
      V_LAST_UPDATED_BY                                           ,
      V_LAST_UPDATE_LOGIN                                         ,
      V_CREATION_DATE                                             ,
      V_CREATED_BY                                                ,
      l_request_id                                );
     END IF;
    END LOOP;
    PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_Emp: c_e_pn# '||l_count_1||': c_e_assign_pn# '
                              ||l_count_2||': emp_pn Loop(-)');
   END LOOP;
   PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_Emp: c_e_pn# '||l_count_1||': c_e_assign_pn Loop(-)');
 END LOOP;
 PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_Emp: c_e_pn Loop(-)');
 IF dbms_sql.is_open (l_cursor) THEN
  dbms_sql.close_cursor (l_cursor);
 END IF;

COMMIT;
   pnp_debug_pkg.put_log_msg('pn_sp_assign_Emp(-)');
END IF;


V_LOC_TYPE := null ;   ----Added BUG#2226865
   l_count_1 := 0;
   l_count_2 := 0;
   l_count_3 := 0;

IF report_type IN ('CUSTOMER','ALL') THEN
   pnp_debug_pkg.put_log_msg('pn_sp_assign_Cust(+)');

  l_statement :=
  'SELECT
  distinct
  ten.location_id                                  LOCATION_ID,
  les.lease_id                                     LEASE_ID,
  les.name                                         LEASE_NAME,
  les.lease_num                                    LEASE_NUMBER,
  lda.lease_commencement_date                      LEASE_COMMENCEMENT_DATE,
  lda.lease_termination_date                       LEASE_TERMINATION_DATE,
  ten.attribute_category                           ATTRIBUTE_CATEGORY,
  ten.attribute1                                   ATTRIBUTE1,
  ten.attribute2                                   ATTRIBUTE2,
  ten.attribute3                                   ATTRIBUTE3,
  ten.attribute4                                   ATTRIBUTE4,
  ten.attribute5                                   ATTRIBUTE5,
  ten.attribute6                                   ATTRIBUTE6,
  ten.attribute7                                   ATTRIBUTE7,
  ten.attribute8                                   ATTRIBUTE8,
  ten.attribute9                                   ATTRIBUTE9,
  ten.attribute10                                  ATTRIBUTE10,
  ten.attribute11                                  ATTRIBUTE11,
  ten.attribute12                                  ATTRIBUTE12,
  ten.attribute13                                  ATTRIBUTE13,
  ten.attribute14                                  ATTRIBUTE14,
  ten.attribute15                                  ATTRIBUTE15
 FROM    pn_leases               les,
         pn_lease_details_all    lda,
         pn_tenancies_all        ten
  WHERE ten.lease_id = les.lease_id
    AND ten.lease_id = lda.lease_id '
   ||lease_number_WHERE_clause;

 IF NOT dbms_sql.is_open (l_cursor) THEN
  l_cursor := dbms_sql.open_cursor;
 END IF;


 dbms_sql.parse(l_cursor,l_statement,dbms_sql.native);
 IF lease_number_low IS NOT NULL AND lease_number_high IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_number_low',l_lease_number_low);
   dbms_sql.bind_variable(l_cursor,'l_lease_number_high',l_lease_number_high);
 ELSIF lease_number_low IS NULL AND lease_number_high IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_number_high',l_lease_number_high);
 ELSIF lease_number_low IS NOT NULL AND lease_number_high IS NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_number_low',l_lease_number_low);
 END IF;

 dbms_sql.define_column (l_cursor,1,V_LOCATION_ID_1);
 dbms_sql.define_column (l_cursor,2,V_LEASE_ID);
 dbms_sql.define_column (l_cursor,3,V_LEASE_NAME,50);
 dbms_sql.define_column (l_cursor,4,V_LEASE_NUMBER,30);
 dbms_sql.define_column (l_cursor,5,V_LEASE_COM_DATE);
 dbms_sql.define_column (l_cursor,6,V_LEASE_TERM_DATE);
 dbms_sql.define_column (l_cursor,7,V_ATTRIBUTE_CATEGORY,30);
 dbms_sql.define_column (l_cursor,8,V_ATTRIBUTE1,150);
 dbms_sql.define_column (l_cursor,9,V_ATTRIBUTE2,150);
 dbms_sql.define_column (l_cursor,10,V_ATTRIBUTE3,150);
 dbms_sql.define_column (l_cursor,11,V_ATTRIBUTE4,150);
 dbms_sql.define_column (l_cursor,12,V_ATTRIBUTE5,150);
 dbms_sql.define_column (l_cursor,13,V_ATTRIBUTE6,150);
 dbms_sql.define_column (l_cursor,14,V_ATTRIBUTE7,150);
 dbms_sql.define_column (l_cursor,15,V_ATTRIBUTE8,150);
 dbms_sql.define_column (l_cursor,16,V_ATTRIBUTE9,150);
 dbms_sql.define_column (l_cursor,17,V_ATTRIBUTE10,150);
 dbms_sql.define_column (l_cursor,18,V_ATTRIBUTE11,150);
 dbms_sql.define_column (l_cursor,19,V_ATTRIBUTE12,150);
 dbms_sql.define_column (l_cursor,20,V_ATTRIBUTE13,150);
 dbms_sql.define_column (l_cursor,21,V_ATTRIBUTE14,150);
 dbms_sql.define_column (l_cursor,22,V_ATTRIBUTE15,150);



  l_rows   := dbms_sql.execute(l_cursor);

 pnp_debug_pkg.put_log_msg('pn_sp_assign_Cust: c_c_pn Loop(+)');
 l_count_1 := 0;
 LOOP
     l_count_1 := l_count_1 + 1;
          l_count := dbms_sql.fetch_rows( l_cursor );
        EXIT WHEN l_count <> 1;

     dbms_sql.column_value(l_cursor,1,V_LOCATION_ID_1);
     dbms_sql.column_value(l_cursor,2,V_LEASE_ID);
     dbms_sql.column_value(l_cursor,3,V_LEASE_NAME);
     dbms_sql.column_value(l_cursor,4,V_LEASE_NUMBER);
     dbms_sql.column_value(l_cursor,5,V_LEASE_COM_DATE);
     dbms_sql.column_value(l_cursor,6,V_LEASE_TERM_DATE);
     dbms_sql.column_value(l_cursor,7,V_ATTRIBUTE_CATEGORY);
     dbms_sql.column_value(l_cursor,8,V_ATTRIBUTE1);
     dbms_sql.column_value(l_cursor,9,V_ATTRIBUTE2);
     dbms_sql.column_value(l_cursor,10,V_ATTRIBUTE3);
     dbms_sql.column_value(l_cursor,11,V_ATTRIBUTE4);
     dbms_sql.column_value(l_cursor,12,V_ATTRIBUTE5);
     dbms_sql.column_value(l_cursor,13,V_ATTRIBUTE6);
     dbms_sql.column_value(l_cursor,14,V_ATTRIBUTE7);
     dbms_sql.column_value(l_cursor,15,V_ATTRIBUTE8);
     dbms_sql.column_value(l_cursor,16,V_ATTRIBUTE9);
     dbms_sql.column_value(l_cursor,17,V_ATTRIBUTE10);
     dbms_sql.column_value(l_cursor,18,V_ATTRIBUTE11);
     dbms_sql.column_value(l_cursor,19,V_ATTRIBUTE12);
     dbms_sql.column_value(l_cursor,20,V_ATTRIBUTE13);
     dbms_sql.column_value(l_cursor,21,V_ATTRIBUTE14);
     dbms_sql.column_value(l_cursor,22,V_ATTRIBUTE15);

OPEN c_c_assign_pn FOR
SELECT
  distinct
  loc.location_id                                                               LOCATION_ID,
  fl1.meaning                                                                   LOCATION_TYPE,
  NVL(NVL(loc.building, loc.floor), loc.office)                                 LOCATION_NAME,
  loc.location_code                                                             LOCATION_CODE,
  loc.location_type_lookup_code                                                 Loc_type     , --BUG#2226865
  fl.meaning                                                                    USAGE_TYPE,
  loc.rentable_area                                                             RENTABLE_AREA,
  loc.usable_area                                                               USABLE_AREA,
  loc.assignable_area                                                           ASSIGNABLE_AREA,
  loc.common_area                                                               COMMON_AREA,
  loc.last_update_date                                                          LAST_UPDATE_DATE,
  loc.last_updated_by                                                           LAST_UPDATED_BY,
  loc.last_update_login                                                         LAST_UPDATE_LOGIN,
  loc.creation_date                                                             CREATION_DATE,
  loc.created_by                                                                CREATED_BY
FROM pn_locations_all loc,
     fnd_lookups  fl,
     fnd_lookups  fl1
WHERE fl.lookup_code(+) = loc.space_type_lookup_code
AND   fl.lookup_type(+) = 'PN_SPACE_TYPE'
AND   fl1.lookup_code(+)= loc.location_type_lookup_code
AND   fl1.lookup_type(+)= 'PN_LOCATION_TYPE'
AND   loc.location_id in (select loc.location_id FROM pn_locations_all loc
                          WHERE active_start_date <= as_of_date
                          AND active_end_date   >= as_of_date
                          START WITH loc.location_id = V_LOCATION_ID_1
                          CONNECT BY PRIOR loc.location_id = loc.parent_location_id
                          AND as_of_date between prior active_start_date AND prior active_end_date);

   pnp_debug_pkg.put_log_msg('pn_sp_assign_Cust: c_c_pn# '||l_count_1||': c_c_assign_pn Loop(+)');
   l_count_2 := 0;
LOOP
     l_count_2 := l_count_2 + 1;
     FETCH c_c_assign_pn into V_LOCATION_ID_2                   ,
                     V_LOCATION_TYPE                            ,
                     V_LOCATION_NAME                            ,
                     V_LOCATION_CODE                            ,
                     v_loc_type                                 ,  --BUG#2226865
                     V_SPACE_TYPE                               ,
                     V_LOC_AREA.RENTABLE_AREA                   ,  --bug#2226865
                     V_LOC_AREA.USABLE_AREA                     ,  --bug#2226865
                     V_LOC_AREA.ASSIGNABLE_AREA                 ,  --bug#2226865
                     V_LOC_AREA.COMMON_AREA                     ,  --bug#2226865
                     V_LAST_UPDATE_DATE                         ,
                     V_LAST_UPDATED_BY                          ,
                     V_LAST_UPDATE_LOGIN                        ,
                     V_CREATION_DATE                            ,
                     V_CREATED_BY                               ;
EXIT WHEN c_c_assign_pn%notfound;
OPEN cust_pn FOR
SELECT
  distinct
  cust.location_id                                 LOCATION_ID,
  0                                                PERSON_ID,
  NULL                                             COST_CENTER,
  NULL                                             EMPLOYEE_PROJECT_NUMBER,
  NULL                                             EMPLOYEE_TASK_NUMBER,
  0                                                EMPLOYEE_ASSIGNED_AREA,
  NULL                                             EMPLOYEE_ASSIGNED_FROM,
  NULL                                             EMPLOYEE_ASSIGNED_TO,
  cust.expense_account_id                          EXP_ACCOUNT,
  cust.cust_account_id                             CUSTOMER_ACCOUNT_ID,
  pa.segment1                                      CUSTOMER_PROJECT_NUMBER,
  pat.task_name                                    CUSTOMER_TASK_NUMBER,
  cust.allocated_area                              CUSTOMER_ASSIGNED_AREA,
  cust.cust_assign_start_date                      CUSTOMER_ASSIGNED_FROM,
  cust.cust_assign_end_date                        CUSTOMER_ASSIGNED_TO,
  hp.party_name                                    CUSTOMER_NAME,
  hcsu.location                                    CUSTOMER_SITE,
  arl.meaning                                      CUSTOMER_CATEGORY
FROM
  pa_projects_all pa,
  pa_tasks pat,
  hz_parties hp,
  hz_cust_site_uses_all hcsu,
  ar_lookups arl,
  hz_cust_accounts hca,
  pn_space_assign_cust_all cust
WHERE cust.location_id =V_LOCATION_ID_2 AND
  hca.cust_account_id = cust.cust_account_id AND
  hca.party_id = hp.party_id AND
  arl.lookup_code(+) = hp.category_code AND
  arl.lookup_type(+) = 'CUSTOMER_CATEGORY' AND
  hcsu.site_use_id(+)= cust.site_use_id AND
  pa.project_id(+)   = cust.project_id AND
  pat.task_id(+)     = cust.task_id
  AND as_of_date between cust.cust_assign_start_date AND NVL(cust.cust_assign_end_date, l_date);
   pnp_debug_pkg.put_log_msg('pn_sp_assign_Cust: c_c_pn# '||l_count_1||': c_c_assign_pn# '
                             ||l_count_2||': cust_pn Loop(+)');
   l_count_3 := 0;
 LOOP
     l_count_3 := l_count_3 + 1;
     FETCH cust_pn into V_LOCATION_ID,
                     V_PERSON_ID,
                     V_COST_CENTER,
                     V_EMPLOYEE_PROJECT_NUMBER,
                     V_EMPLOYEE_TASK_NUMBER,
                     V_SPACE_AREA.ALLOCATED_AREA_EMP,  --bug#2226865
                     V_EMPLOYEE_ASSIGNED_FROM,
                     V_EMPLOYEE_ASSIGNED_TO,
                     V_EXP_ACCOUNT,
                     V_CUSTOMER_ACCOUNT_ID,
                     V_CUSTOMER_PROJECT_NUMBER,
                     V_CUSTOMER_TASK_NUMBER,
                     V_SPACE_AREA.ALLOCATED_AREA_CUST,  --bug#2226865
                     V_CUSTOMER_ASSIGNED_FROM,
                     V_CUSTOMER_ASSIGNED_TO,
                     V_CUSTOMER_NAME,
                     V_CUSTOMER_SITE,
                     V_CUSTOMER_CATEGORY;
     V_CUSTOMER_ACCOUNT := fnd_flex_ext.get_segs('SQLGL','GL#',v_coa_id,V_EXP_ACCOUNT);
    EXIT WHEN cust_pn%notfound;
    v_compare_cust:=compare_assign_custlease(V_LOCATION_ID, V_CUSTOMER_ACCOUNT, l_request_id);
    IF NOT(v_compare_cust) THEN

    v_code_data:=pnp_util_func.get_location_name(V_LOCATION_ID, AS_OF_DATE);
    v_emp_data:= pnp_util_func.get_emp_hr_data(V_PERSON_ID);
          --------------bug#2226865-----------------
   IF V_LOC_TYPE in ('BUILDING' ,'LAND','FLOOR','PARCEL') THEN
      PNP_UTIL_FUNC.get_area(v_location_id , v_loc_type ,NULL,AS_OF_DATE,V_LOC_AREA,V_SPACE_AREA);
   END IF;
   -----------bug#2226865--------
    INSERT INTO pn_space_assign_lease_itf
    (LEASE_ID                        ,
     LEASE_NAME                      ,
     LEASE_NUMBER                    ,
     LEASE_COMMENCEMENT_DATE         ,
     LEASE_TERMINATION_DATE          ,
     LOCATION_ID                     ,
     LOCATION_TYPE                   ,
     LOCATION_NAME                   ,
     LOCATION_CODE                   ,
     SPACE_TYPE                      ,
     PROPERTY_CODE                   ,
     PROPERTY_NAME                   ,
     BUILDING_LOCATION_CODE          ,
     BUILDING_OR_LAND_NAME           ,
     FLOOR_LOCATION_CODE             ,
     FLOOR_OR_PARCEL_NAME            ,
     OFFICE_LOCATION_CODE            ,
     OFFICE_OR_SECTION_NAME          ,
     RENTABLE_AREA                   ,
     USABLE_AREA                     ,
     ASSIGNABLE_AREA                 ,
     COMMON_AREA                     ,
     PERSON_ID                       ,
     EMPLOYEE_NAME                   ,
     COST_CENTER                     ,
     EMPLOYEE_NUMBER                 ,
     EMPLOYEE_TYPE                   ,
     EMPLOYEE_CATEGORY               ,
     EMPLOYEE_POSITION               ,
     EMPLOYEE_PROJECT_NUMBER         ,
     EMPLOYEE_TASK_NUMBER            ,
     EMPLOYEE_ASSIGNED_AREA          ,
     EMPLOYEE_ASSIGNED_FROM          ,
     EMPLOYEE_ASSIGNED_TO            ,
     CUSTOMER_NAME                   ,
     CUSTOMER_SITE                   ,
     CUSTOMER_CATEGORY               ,
     CUSTOMER_ACCOUNT                ,
     CUSTOMER_PROJECT_NUMBER         ,
     CUSTOMER_TASK_NUMBER            ,
     CUSTOMER_ASSIGNED_AREA          ,
     CUSTOMER_VACANT_AREA            ,
     CUSTOMER_ASSIGNED_FROM          ,
     CUSTOMER_ASSIGNED_TO            ,
     TEN_ATTRIBUTE_CATEGORY          ,
     TEN_ATTRIBUTE1                  ,
     TEN_ATTRIBUTE2                  ,
     TEN_ATTRIBUTE3                  ,
     TEN_ATTRIBUTE4                  ,
     TEN_ATTRIBUTE5                  ,
     TEN_ATTRIBUTE6                  ,
     TEN_ATTRIBUTE7                  ,
     TEN_ATTRIBUTE8                  ,
     TEN_ATTRIBUTE9                  ,
     TEN_ATTRIBUTE10                 ,
     TEN_ATTRIBUTE11                 ,
     TEN_ATTRIBUTE12                 ,
     TEN_ATTRIBUTE13                 ,
     TEN_ATTRIBUTE14                 ,
     TEN_ATTRIBUTE15                 ,
     LAST_UPDATE_DATE                ,
     LAST_UPDATED_BY                 ,
     LAST_UPDATE_LOGIN               ,
     CREATION_DATE                   ,
     CREATED_BY,
     REQUEST_ID           )
    VALUES
    ( V_LEASE_ID                                                  ,
      V_LEASE_NAME                                                ,
      V_LEASE_NUMBER                                              ,
      V_LEASE_COM_DATE                                            ,
      V_LEASE_TERM_DATE                                           ,
      V_LOCATION_ID                                               ,
      V_LOCATION_TYPE                                             ,
      V_LOCATION_NAME                                             ,
      V_LOCATION_CODE                                             ,
      V_SPACE_TYPE                                                ,
      v_code_data.PROPERTY_CODE                                   ,
      v_code_data.PROPERTY_NAME                                   ,
      v_code_data.BUILDING_LOCATION_CODE                          ,
      v_code_data.BUILDING                                        ,
      v_code_data.FLOOR_LOCATION_CODE                             ,
      v_code_data.FLOOR                                           ,
      v_code_data.OFFICE_LOCATION_CODE                            ,
      v_code_data.OFFICE                                          ,
      V_LOC_AREA.RENTABLE_AREA                                    ,--bug#2226865
      V_LOC_AREA.USABLE_AREA                                      ,--bug#2226865
      V_LOC_AREA.ASSIGNABLE_AREA                                  ,--bug#2226865
      V_LOC_AREA.COMMON_AREA                                      ,--bug#2226865
      V_PERSON_ID                                                 ,
      v_emp_data.FULL_NAME                                        ,
      V_COST_CENTER                                               ,
      v_emp_data.EMPLOYEE_NUMBER                                  ,
      v_emp_data.EMPLOYEE_TYPE                                    ,
      v_emp_data.EMPLOYMENT_CATEGORY_MEANING                      ,
      v_emp_data.POSITION                                         ,
      V_EMPLOYEE_PROJECT_NUMBER                                   ,
      V_EMPLOYEE_TASK_NUMBER                                      ,
      V_SPACE_AREA.ALLOCATED_AREA_EMP                             ,   --bug#2226865
      V_EMPLOYEE_ASSIGNED_FROM                                    ,
      V_EMPLOYEE_ASSIGNED_TO                                      ,
      V_CUSTOMER_NAME                                             ,
      V_CUSTOMER_SITE                                             ,
      V_CUSTOMER_CATEGORY                                         ,
      V_CUSTOMER_ACCOUNT                                          ,
      V_CUSTOMER_PROJECT_NUMBER                                   ,
      V_CUSTOMER_TASK_NUMBER                                      ,
      V_SPACE_AREA.ALLOCATED_AREA_CUST                            ,   --bug#2226865
      V_SPACE_AREA.Vacant_area                                    ,   --bug#2226865
      V_CUSTOMER_ASSIGNED_FROM                                    ,
      V_CUSTOMER_ASSIGNED_TO                                      ,
      V_ATTRIBUTE_CATEGORY                                        ,
      V_ATTRIBUTE1                                                ,
      V_ATTRIBUTE2                                                ,
      V_ATTRIBUTE3                                                ,
      V_ATTRIBUTE4                                                ,
      V_ATTRIBUTE5                                                ,
      V_ATTRIBUTE6                                                ,
      V_ATTRIBUTE7                                                ,
      V_ATTRIBUTE8                                                ,
      V_ATTRIBUTE9                                                ,
      V_ATTRIBUTE10                                               ,
      V_ATTRIBUTE11                                               ,
      V_ATTRIBUTE12                                               ,
      V_ATTRIBUTE13                                               ,
      V_ATTRIBUTE14                                               ,
      V_ATTRIBUTE15                                               ,
      V_LAST_UPDATE_DATE                                          ,
      V_LAST_UPDATED_BY                                           ,
      V_LAST_UPDATE_LOGIN                                         ,
      V_CREATION_DATE                                             ,
      V_CREATED_BY                                                ,
      l_request_id                                  );
     END IF;
    END LOOP;
   pnp_debug_pkg.put_log_msg('pn_sp_assign_Cust: c_c_pn# '||l_count_1||': c_c_assign_pn# '
                             ||l_count_2||': cust_pn Loop(-)');
   END LOOP;
   pnp_debug_pkg.put_log_msg('pn_sp_assign_Cust: c_c_pn# '||l_count_1||': c_c_assign_pn Loop(-)');
 END LOOP;

  IF dbms_sql.is_open (l_cursor) THEN
  dbms_sql.close_cursor (l_cursor);
  END IF;

   pnp_debug_pkg.put_log_msg('pn_sp_assign_Cust: c_c_pn Loop(-)');
COMMIT;
   pnp_debug_pkg.put_log_msg('pn_sp_assign_Cust(-)');
END IF;

  PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_leaseConditions(-)');

--If there is something amiss...
EXCEPTION
WHEN OTHERS THEN
  retcode:=2;
  errbuf:=SUBSTR(SQLERRM,1,235);
  RAISE;
END pn_space_assign_lease;

END pnrx_sp_assign_by_lease;

/
