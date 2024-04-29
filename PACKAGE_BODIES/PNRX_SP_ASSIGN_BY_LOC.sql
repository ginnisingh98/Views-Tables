--------------------------------------------------------
--  DDL for Package Body PNRX_SP_ASSIGN_BY_LOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNRX_SP_ASSIGN_BY_LOC" AS
/* $Header: PNRXSALB.pls 120.3 2005/12/29 22:49:31 appldev ship $ */

FUNCTION compare_assign_emploc(
                       p_location_id                   IN     NUMBER,
                       p_person_id                     IN     NUMBER,
                       p_cost_center                   IN     VARCHAR2,
                       p_request_id                    IN     NUMBER)
RETURN BOOLEAN IS
   v1_location_id      NUMBER;
   v1_person_id        NUMBER;
   v1_cost_center      VARCHAR2(30);
   v1_request_id       NUMBER;
   v_returnvalue       NUMBER;
   v_var1              VARCHAR2(1);
BEGIN
   SELECT 'X'
   INTO   v_var1
   FROM   pn_space_assign_loc_itf
   WHERE  location_id = p_location_id
   AND    person_id(+) = p_person_id
   AND    cost_center = p_cost_center
   AND    request_id = P_request_id;
   RETURN TRUE;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
END compare_assign_emploc;

-------------------------------------------------------------------------------
-- FUNCTION     : COMPARE_ASSIGN_CUSTLOC
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_locations with _ALL table.
-- 27-OCT-05  sdmahesh o ATG Mandated changes for SQL literals
-------------------------------------------------------------------------------

FUNCTION compare_assign_custloc(
                       p_location_id                   IN     NUMBER,
                       p_account_id                    IN     VARCHAR2,
                       p_request_id                    IN     NUMBER)
RETURN BOOLEAN IS
   v1_location_id      NUMBER;
   v1_account_id       NUMBER;
   v1_request_id       NUMBER;
   v_returnvalue       NUMBER;
   v_var2              VARCHAR2(1);
BEGIN
   SELECT 'Y'
   INTO   v_var2
   FROM   pn_space_assign_loc_itf
   WHERE  location_id = p_location_id
   AND    customer_account = p_account_id
   AND    request_id = p_request_id;
   RETURN TRUE;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
END compare_assign_custloc;

PROCEDURE pn_space_assign_loc(
                       property_code_low               IN     VARCHAR2,
                       property_code_high              IN     VARCHAR2,
                       location_code_low               IN     VARCHAR2,
                       location_code_high              IN     VARCHAR2,
                       location_type                   IN     VARCHAR2,
                       as_of_date                      IN     DATE,
                       report_type                     IN     VARCHAR2,
                       l_request_id                    IN     NUMBER,
                       l_user_id                       IN     NUMBER,
                       retcode                            OUT NOCOPY VARCHAR2,
                       errbuf                             OUT NOCOPY VARCHAR2
                      )
IS
   l_login_id                      NUMBER;
   type cur_typ is ref cursor;
   c_e_pn                          CUR_TYP;
   c_c_pn                          CUR_TYP;
   c_e_assign_pn                   CUR_TYP;
   c_c_assign_pn                   CUR_TYP;
   c_e_prop                        CUR_TYP;
   c_c_prop                        CUR_TYP;
   c_e_v_pn                        CUR_TYP;
   c_c_v_pn                        CUR_TYP;
   emp_pn                          CUR_TYP;
   cust_pn                         CUR_TYP;
   query_str                       VARCHAR2(20000);

   --declare the 'where clauses here........'
   property_code_where_clause      VARCHAR2(4000);
   location_code_where_clause      VARCHAR2(4000);
   location_type_where_clause      VARCHAR2(4000);
   l_one                           NUMBER := 1;
   l_two                           NUMBER := 2;
   l_three                         NUMBER := 3;

   --declare all columns as variables here
   v_location_id                   pn_space_assign_loc_itf.location_id%TYPE;
   v_location_id_1                 pn_space_assign_loc_itf.location_id%TYPE;
   v_location_id_2                 pn_space_assign_loc_itf.location_id%TYPE;
   v_location_id_3                 pn_space_assign_loc_itf.location_id%TYPE;
   v_location_type                 pn_space_assign_loc_itf.location_type%TYPE;
   v_location_name                 pn_space_assign_loc_itf.location_name%TYPE;
   v_location_code                 pn_space_assign_loc_itf.location_code%TYPE;
   v_space_type                    pn_space_assign_loc_itf.space_type%TYPE;
   v_property_code                 pn_space_assign_loc_itf.property_code%TYPE;
   v_person_id                     pn_space_assign_loc_itf.person_id%TYPE;
   v_person_id_3                   pn_space_assign_loc_itf.person_id%TYPE;
   v_cost_center                   pn_space_assign_loc_itf.cost_center%TYPE;
   v_employee_project_number       pn_space_assign_loc_itf.employee_project_number%TYPE;
   v_employee_task_number          pn_space_assign_loc_itf.employee_task_number%TYPE;
   v_employee_assigned_from        pn_space_assign_loc_itf.employee_assigned_from%TYPE;
   v_employee_assigned_to          pn_space_assign_loc_itf.employee_assigned_to%TYPE;
   v_customer_account              pn_space_assign_loc_itf.customer_account%TYPE;
   v_exp_account                   NUMBER;
   v_customer_account_id           NUMBER;
   v_customer_project_number       pn_space_assign_loc_itf.customer_project_number%TYPE;
   v_customer_task_number          pn_space_assign_loc_itf.customer_task_number%TYPE;
   v_customer_assigned_from        pn_space_assign_loc_itf.customer_assigned_from%TYPE;
   v_customer_assigned_to          pn_space_assign_loc_itf.customer_assigned_to%TYPE;
   v_customer_name                 pn_space_assign_loc_itf.customer_name%TYPE;
   v_customer_site                 pn_space_assign_loc_itf.customer_site%TYPE;
   v_customer_category             pn_space_assign_loc_itf.customer_category%TYPE;
   v_rentable_area                 pn_space_assign_loc_itf.rentable_area%TYPE;
   v_usable_area                   pn_space_assign_loc_itf.usable_area%TYPE;
   v_assignable_area               pn_space_assign_loc_itf.assignable_area%TYPE;
   v_common_area                   pn_space_assign_loc_itf.common_area%TYPE;
   v_employee_assigned_area        pn_space_assign_loc_itf.employee_assigned_area%TYPE;
   v_customer_assigned_area        pn_space_assign_loc_itf.customer_assigned_area%TYPE;
   v_vacant_area                   NUMBER;
   v_attribute_category            pn_space_assign_loc_itf.loc_attribute_category%TYPE;
   v_attribute1                    pn_space_assign_loc_itf.loc_attribute1%TYPE;
   v_attribute2                    pn_space_assign_loc_itf.loc_attribute2%TYPE;
   v_attribute3                    pn_space_assign_loc_itf.loc_attribute3%TYPE;
   v_attribute4                    pn_space_assign_loc_itf.loc_attribute4%TYPE;
   v_attribute5                    pn_space_assign_loc_itf.loc_attribute5%TYPE;
   v_attribute6                    pn_space_assign_loc_itf.loc_attribute6%TYPE;
   v_attribute7                    pn_space_assign_loc_itf.loc_attribute7%TYPE;
   v_attribute8                    pn_space_assign_loc_itf.loc_attribute8%TYPE;
   v_attribute9                    pn_space_assign_loc_itf.loc_attribute9%TYPE;
   v_attribute10                   pn_space_assign_loc_itf.loc_attribute10%TYPE;
   v_attribute11                   pn_space_assign_loc_itf.loc_attribute11%TYPE;
   v_attribute12                   pn_space_assign_loc_itf.loc_attribute12%TYPE;
   v_attribute13                   pn_space_assign_loc_itf.loc_attribute13%TYPE;
   v_attribute14                   pn_space_assign_loc_itf.loc_attribute14%TYPE;
   v_attribute15                   pn_space_assign_loc_itf.loc_attribute15%TYPE;
   v_last_update_date              pn_space_assign_loc_itf.last_update_date%TYPE;
   v_last_updated_by               pn_space_assign_loc_itf.last_updated_by%TYPE;
   v_last_update_login             pn_space_assign_loc_itf.last_update_login%TYPE;
   v_creation_date                 pn_space_assign_loc_itf.creation_date%TYPE;
   v_created_by                    pn_space_assign_loc_itf.created_by%TYPE;

   --declare the record type for the function here.........
   v_emp_data                      pnp_util_func.emp_hr_data_rec := NULL;
   v_code_data                     pnp_util_func.location_name_rec := NULL;
   v_compare_emp                   BOOLEAN;
   v_compare_cust                  BOOLEAN;
   l_date                          DATE := fnd_date.canonical_to_date('4712/12/31 00:00:00' );
   v_coa_id                        NUMBER; --VARCHAR2(30);
   v_loc_type                      VARCHAR2(100)  ;    --BUG#2226865
   v_loc_area                      pnp_util_func.pn_location_area_rec;  --bug#2226865
   v_space_area                    pnp_util_func.pn_space_area_rec;  --bug#2226865

   l_cursor                        INTEGER;
   l_rows                          INTEGER;
   l_count                         INTEGER;
   l_property_code_low             VARCHAR2(90);
   l_property_code_high            VARCHAR2(90);
   l_location_code_low             VARCHAR2(90);
   l_location_code_high            VARCHAR2(90);
   l_location_type                 VARCHAR2(30);
   l_statement                     VARCHAR2(10000);



BEGIN
   PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_locCondotions(+)');

   --Initialise status parameters...
   retcode:=0;
   errbuf:='';
   fnd_profile.get('LOGIN_ID', l_login_id);
   SELECT  chart_of_accounts_id into v_coa_id
   FROM gl_sets_of_books
   WHERE set_of_books_id= TO_NUMBER(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                    pn_mo_cache_utils.get_current_org_id));

   l_cursor := dbms_sql.open_cursor;

   --property code conditions

   l_property_code_low  := property_code_low;
   l_property_code_high := property_code_high;

   IF property_code_low IS NOT NULL AND property_code_high IS NOT NULL THEN
   property_code_where_clause := ' AND p.property_code  BETWEEN
   :l_property_code_low AND :l_property_code_high';
   ELSIF property_code_low IS NULL AND property_code_high IS NOT NULL THEN
       property_code_where_clause := ' AND p.property_code =
       :l_property_code_high';
   ELSIF property_code_low IS NOT NULL AND property_code_high IS NULL THEN
        property_code_where_clause := ' AND p.property_code =
        :l_property_code_low';
   ELSE  property_code_where_clause := ' AND 1 = 1 ';
   END IF;


   /*IF property_code_low IS NOT NULL AND property_code_high IS NOT NULL THEN
      property_code_where_clause := ' AND p.property_code  BETWEEN '||''''||property_code_low||''''||
                                                          ' AND '||''''||property_code_high||'''';
   ELSIF property_code_low IS NULL AND property_code_high IS NOT NULL THEN
      property_code_where_clause := ' AND p.property_code = '||''''||property_code_high||'''';
   ELSIF property_code_low IS NOT NULL AND property_code_high IS NULL THEN
      property_code_where_clause := ' AND p.property_code = '||''''||property_code_low||'''';
   ELSE
      property_code_where_clause := ' AND 1 = 1 ';
   END IF;*/

  --location code conditions.....
  l_location_code_low  := location_code_low;
  l_location_code_high := location_code_high;
   IF location_code_low IS NOT NULL AND location_code_high IS NOT NULL THEN
     location_code_where_clause := ' AND loc.location_code  BETWEEN
     :l_location_code_low AND :l_location_code_high';
   ELSIF location_code_low IS NULL AND location_code_high IS NOT NULL THEN
       location_code_where_clause := ' AND loc.location_code =
       :l_location_code_high';
   ELSIF location_code_low IS NOT NULL AND location_code_high IS NULL THEN
       location_code_where_clause := ' AND loc.location_code =
       :l_location_code_low';
   ELSE  location_code_where_clause := ' AND 2=2 ';
   END IF;


--location type conditions....
   l_location_type := location_type;
   IF location_type IS NOT NULL THEN
      location_type_where_clause := ' AND loc.location_type_lookup_code = :l_location_type';
      /*location_type_where_clause := ' AND loc.location_type_lookup_code = '||''''||location_type||'''';*/
   ELSE
      location_type_where_clause := ' AND 3 = 3 ';
   END IF;

   --validate report type...
   IF report_type IN ('EMPLOYEE','ALL') THEN

      l_statement :=
         'SELECT DISTINCT
                 loc.location_id location_i
          FROM   pn_locations        loc,
                 pn_properties       p
          WHERE  p.property_id(+) = loc.property_id '
         ||property_code_where_clause||location_code_where_clause||location_type_where_clause;



         dbms_sql.parse(l_cursor,l_statement,dbms_sql.native);

         --------------------------------------
   --property code conditions
   IF property_code_low IS NOT NULL AND property_code_high IS NOT NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_property_code_low',l_property_code_low);
     dbms_sql.bind_variable(l_cursor,'l_property_code_high',l_property_code_high);
   ELSIF property_code_low IS NULL AND property_code_high IS NOT NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_property_code_high',l_property_code_high);
   ELSIF property_code_low IS NOT NULL AND property_code_high IS NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_property_code_low',l_property_code_low);
   END IF;


  --location code conditions.....
   IF location_code_low IS NOT NULL AND location_code_high IS NOT NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_location_code_low',l_location_code_low);
     dbms_sql.bind_variable(l_cursor,'l_location_code_high',l_location_code_high);
   ELSIF location_code_low IS NULL AND location_code_high IS NOT NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_location_code_high',l_location_code_high);
   ELSIF location_code_low IS NOT NULL AND location_code_high IS NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_location_code_low',l_location_code_low);
   END IF;


--location type conditions....
   IF location_type IS NOT NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_location_type',l_location_type);
   END IF;

   dbms_sql.define_column (l_cursor,1,v_location_id_1);
   l_rows   := dbms_sql.execute(l_cursor);

         PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_locQuery(-)');
         PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_locLoop(+)');
      LOOP
       l_count := dbms_sql.fetch_rows( l_cursor );
       EXIT WHEN l_count <> 1;

       dbms_sql.column_value(l_cursor,1,v_location_id_1);

         OPEN c_e_assign_pn FOR
            SELECT DISTINCT
                   loc.location_id                     location_id,
                   fl1.meaning                         location_type,
                   NVL(NVL(loc.building, loc.FLOOR), loc.office) location_name,
                   loc.location_code                   location_code,
                   loc.location_type_lookup_code       lOC_TYPE, --BUG#2226865
                   fl.meaning                          usage_type,
                   loc.rentable_area                   rentable_area,
                   loc.usable_area                     usable_area,
                   loc.assignable_area                 assignable_area,
                   loc.common_area                     common_area,
                   loc.attribute_category              attribute_category,
                   loc.attribute1                      attribute1,
                   loc.attribute2                      attribute2,
                   loc.attribute3                      attribute3,
                   loc.attribute4                      attribute4,
                   loc.attribute5                      attribute5,
                   loc.attribute6                      attribute6,
                   loc.attribute7                      attribute7,
                   loc.attribute8                      attribute8,
                   loc.attribute9                      attribute9,
                   loc.attribute10                     attribute10,
                   loc.attribute11                     attribute11,
                   loc.attribute12                     attribute12,
                   loc.attribute13                     attribute13,
                   loc.attribute14                     attribute14,
                   loc.attribute15                     attribute15,
                   loc.last_update_date                last_update_date,
                   loc.last_updated_by                 last_updated_by,
                   loc.last_update_login               last_update_login,
                   loc.creation_date                   creation_date,
                   loc.created_by                      created_by
            FROM   pn_locations_all loc,
                   fnd_lookups  fl,
                   fnd_lookups  fl1
            WHERE  fl.lookup_code(+) = loc.space_type_lookup_code
            AND    fl.lookup_type(+) = 'PN_SPACE_TYPE'
            AND    fl1.lookup_code(+)= loc.location_type_lookup_code
            AND    fl1.lookup_type(+)= 'PN_LOCATION_TYPE'
            and    nvl(trunc(as_of_date),trunc(loc.active_start_date)) between
                   trunc(loc.active_start_date) and trunc(loc.active_end_date);
/* Bug 4748773

            AND    loc.location_id IN (SELECT loc.location_id from pn_locations_all loc
                                       WHERE loc.active_start_date <= as_of_date
                                       AND   loc.active_end_date >= as_of_date
                                       AND   loc.location_id = v_location_id_1);
*/

         LOOP
            FETCH c_e_assign_pn
            INTO  v_location_id_2                            ,
                  v_location_type                            ,
                  v_location_name                            ,
                  v_location_code                            ,
                  v_loc_type                                 ,  --BUG#2226865
                  v_space_type                               ,
                  v_loc_area.rentable_area                   ,  --BUG#2226865
                  v_loc_area.usable_area                     ,  --BUG#2226865
                  v_loc_area.assignable_area                 ,  --BUG#2226865
                  v_loc_area.common_area                     ,  --BUG#2226865
                  v_attribute_category                       ,
                  v_attribute1                               ,
                  v_attribute2                               ,
                  v_attribute3                               ,
                  v_attribute4                               ,
                  v_attribute5                               ,
                  v_attribute6                               ,
                  v_attribute7                               ,
                  v_attribute8                               ,
                  v_attribute9                               ,
                  v_attribute10                              ,
                  v_attribute11                              ,
                  v_attribute12                              ,
                  v_attribute13                              ,
                  v_attribute14                              ,
                  v_attribute15                              ,
                  v_last_update_date                         ,
                  v_last_updated_by                          ,
                  v_last_update_login                        ,
                  v_creation_date                            ,
                  v_created_by                               ;
            EXIT WHEN c_e_assign_pn%NOTFOUND;

            OPEN emp_pn FOR
               SELECT DISTINCT
                      emp.location_id                     location_id,
                      emp.person_id                       person_id,
                      emp.cost_center_code                cost_center,
                      pa.segment1                         employee_project_number,
                      pat.task_name                       employee_task_number,
                      emp.allocated_area                  employee_assigned_area,
                      emp.emp_assign_start_date           employee_assigned_from,
                      emp.emp_assign_end_date             employee_assigned_to,
                      NULL                                customer_account,
                      NULL                                customer_project_number,
                      NULL                                customer_task_number,
                      0                                   customer_assigned_area,
                      NULL                                customer_assigned_from,
                      NULL                                customer_assigned_to,
                      NULL                                customer_name,
                      NULL                                customer_site,
                      NULL                                customer_category
               FROM   pa_projects_all pa,
                      pa_tasks pat,
                      pn_space_assign_emp_all emp
               WHERE  emp.location_id = V_LOCATION_ID_2
               AND    pa.project_id(+)= emp.project_id
               AND    pat.task_id(+)  = emp.task_id
               AND    as_of_date BETWEEN emp.emp_assign_start_date AND NVL(emp.emp_assign_end_date, l_date);
               PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_locQuery(-)');
               PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_locLoop(+)');
            LOOP
               FETCH emp_pn
               INTO  v_location_id,
                     v_person_id,
                     v_cost_center,
                     v_employee_project_number,
                     v_employee_task_number,
                     v_space_area.allocated_area_emp,  --BUG#2226865
                     v_employee_assigned_from,
                     v_employee_assigned_to,
                     v_customer_account,
                     v_customer_project_number,
                     v_customer_task_number,
                     v_space_area.allocated_area_cust,  --BUG#2226865
                     v_customer_assigned_from,
                     v_customer_assigned_to,
                     v_customer_name,
                     v_customer_site,
                     v_customer_category;
               EXIT WHEN emp_pn%NOTFOUND;
               v_compare_emp:=compare_assign_emploc(v_location_id, v_person_id, v_cost_center, l_request_id);
               IF NOT(v_compare_emp) THEN

                  v_code_data:=pnp_util_func.get_location_name(v_location_id, as_of_date);
                  v_emp_data:= pnp_util_func.get_emp_hr_data(v_person_id);
                  --dbms_output.put_line('fet'||sqlerrm);
                  --------------bug#2226865-----------------
                  IF V_LOC_TYPE in ('BUILDING' ,'LAND','FLOOR','PARCEL') THEN
                     PNP_UTIL_FUNC.get_area(v_location_id , v_loc_type ,NULL,as_of_date,v_loc_area,v_space_area);
                  END IF;
                  -----------bug#2226865--------


                  INSERT INTO pn_space_assign_loc_itf
                  (location_id                     ,
                   location_type                   ,
                   location_name                   ,
                   location_code                   ,
                   space_type                      ,
                   property_code                   ,
                   property_name                   ,
                   building_location_code          ,
                   building_or_land_name           ,
                   floor_location_code             ,
                   floor_or_parcel_name            ,
                   office_location_code            ,
                   office_or_section_name          ,
                   rentable_area                   ,
                   usable_area                     ,
                   assignable_area                 ,
                   common_area                     ,
                   person_id                       ,
                   employee_name                   ,
                   cost_center                     ,
                   employee_number                 ,
                   employee_type                   ,
                   employee_category               ,
                   employee_position               ,
                   employee_project_number         ,
                   employee_task_number            ,
                   employee_assigned_area          ,
                   employee_vacant_area            ,
                   employee_assigned_from          ,
                   employee_assigned_to            ,
                   customer_name                   ,
                   customer_site                   ,
                   customer_category               ,
                   customer_account                ,
                   customer_project_number         ,
                   customer_task_number            ,
                   customer_assigned_area          ,
                   customer_assigned_from          ,
                   customer_assigned_to            ,
                   loc_attribute_category          ,
                   loc_attribute1                  ,
                   loc_attribute2                  ,
                   loc_attribute3                  ,
                   loc_attribute4                  ,
                   loc_attribute5                  ,
                   loc_attribute6                  ,
                   loc_attribute7                  ,
                   loc_attribute8                  ,
                   loc_attribute9                  ,
                   loc_attribute10                 ,
                   loc_attribute11                 ,
                   loc_attribute12                 ,
                   loc_attribute13                 ,
                   loc_attribute14                 ,
                   loc_attribute15                 ,
                   last_update_date                ,
                   last_updated_by                 ,
                   last_update_login               ,
                   creation_date                   ,
                   created_by,
                   request_id           )
                  VALUES
                  (v_location_id                              ,
                   v_location_type                            ,
                   v_location_name                            ,
                   v_location_code                            ,
                   v_space_type                               ,
                   v_code_data.property_code                  ,
                   v_code_data.property_name                  ,
                   v_code_data.building_location_code         ,
                   v_code_data.building                       ,
                   v_code_data.floor_location_code            ,
                   v_code_data.FLOOR                          ,
                   v_code_data.office_location_code           ,
                   v_code_data.office                         ,
                   v_loc_area.rentable_area                   ,--BUG#2226865
                   v_loc_area.usable_area                     ,--BUG#2226865
                   v_loc_area.assignable_area                 ,--BUG#2226865
                   v_loc_area.common_area                     ,--BUG#2226865
                   v_person_id                                ,
                   v_emp_data.full_name                       ,
                   v_cost_center                              ,
                   v_emp_data.employee_number                 ,
                   v_emp_data.employee_type                   ,
                   v_emp_data.employment_category_meaning     ,
                   v_emp_data.position                        ,
                   v_employee_project_number                  ,
                   v_employee_task_number                     ,
                   v_space_area.allocated_area_emp            ,  --BUG#2226865
                   v_space_area.vacant_area                   ,   --BUG#2226865
                   v_employee_assigned_from                   ,
                   v_employee_assigned_to                     ,
                   v_customer_name                            ,
                   v_customer_site                            ,
                   v_customer_category                        ,
                   v_customer_account                         ,
                   v_customer_project_number                  ,
                   v_customer_task_number                     ,
                   v_space_area.allocated_area_cust           ,  --BUG#2226865
                   v_customer_assigned_from                   ,
                   v_customer_assigned_to                     ,
                   v_attribute_category                       ,
                   v_attribute1                               ,
                   v_attribute2                               ,
                   v_attribute3                               ,
                   v_attribute4                               ,
                   v_attribute5                               ,
                   v_attribute6                               ,
                   v_attribute7                               ,
                   v_attribute8                               ,
                   v_attribute9                               ,
                   v_attribute10                              ,
                   v_attribute11                              ,
                   v_attribute12                              ,
                   v_attribute13                              ,
                   v_attribute14                              ,
                   v_attribute15                              ,
                   v_last_update_date                         ,
                   v_last_updated_by                          ,
                   v_last_update_login                        ,
                   v_creation_date                            ,
                   v_created_by                               ,
                   l_request_id
                  );
               END IF;
            END LOOP;
         END LOOP;
      END LOOP;
      IF dbms_sql.is_open (l_cursor) THEN
        dbms_sql.close_cursor (l_cursor);
      END IF;
      COMMIT;
   END IF;

   V_LOC_TYPE := NULL;  --Bug#2226865
   IF report_type IN ('CUSTOMER','ALL') THEN
      l_statement :=
         'SELECT DISTINCT
                 loc.location_id location_id
          FROM   pn_locations        loc,
                 pn_properties       p
          WHERE  p.property_id(+) = loc.property_id '
         ||property_code_where_clause||location_code_where_clause||location_type_where_clause;
      IF NOT dbms_sql.is_open (l_cursor) THEN
         l_cursor := dbms_sql.open_cursor;
      END IF;
      dbms_sql.parse(l_cursor,l_statement,dbms_sql.native);

         --------------------------------------
   --property code conditions
   IF property_code_low IS NOT NULL AND property_code_high IS NOT NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_property_code_low',l_property_code_low);
     dbms_sql.bind_variable(l_cursor,'l_property_code_high',l_property_code_high);
   ELSIF property_code_low IS NULL AND property_code_high IS NOT NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_property_code_high',l_property_code_high);
   ELSIF property_code_low IS NOT NULL AND property_code_high IS NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_property_code_low',l_property_code_low);
   END IF;


  --location code conditions.....
   IF location_code_low IS NOT NULL AND location_code_high IS NOT NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_location_code_low',l_location_code_low);
     dbms_sql.bind_variable(l_cursor,'l_location_code_high',l_location_code_high);
   ELSIF location_code_low IS NULL AND location_code_high IS NOT NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_location_code_high',l_location_code_high);
   ELSIF location_code_low IS NOT NULL AND location_code_high IS NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_location_code_low',l_location_code_low);
   END IF;


--location type conditions....
   IF location_type IS NOT NULL THEN
     dbms_sql.bind_variable(l_cursor,'l_location_type',l_location_type);
   END IF;

   dbms_sql.define_column (l_cursor,1,v_location_id_1);
   l_rows   := dbms_sql.execute(l_cursor);
   PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_locQuery(-)');
   PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_locLoop(+)');
     LOOP
         l_count := dbms_sql.fetch_rows( l_cursor );
         EXIT WHEN l_count <> 1;


        dbms_sql.column_value(l_cursor,1,v_location_id_1);
         OPEN c_c_assign_pn FOR
            SELECT DISTINCT
                   loc.location_id                     location_id,
                   fl1.meaning                         location_type,
                   NVL(NVL(loc.building, loc.floor), loc.office) location_name,
                   loc.location_code                   location_code,
                   loc.location_type_lookup_code       Loc_type, --BUG#2226865
                   fl.meaning                          usage_type,
                   loc.rentable_area                   rentable_area,
                   loc.usable_area                     usable_area,
                   loc.assignable_area                 assignable_area,
                   loc.common_area                     common_area,
                   loc.attribute_category              attribute_category,
                   loc.attribute1                      attribute1,
                   loc.attribute2                      attribute2,
                   loc.attribute3                      attribute3,
                   loc.attribute4                      attribute4,
                   loc.attribute5                      attribute5,
                   loc.attribute6                      attribute6,
                   loc.attribute7                      attribute7,
                   loc.attribute8                      attribute8,
                   loc.attribute9                      attribute9,
                   loc.attribute10                     attribute10,
                   loc.attribute11                     attribute11,
                   loc.attribute12                     attribute12,
                   loc.attribute13                     attribute13,
                   loc.attribute14                     attribute14,
                   loc.attribute15                     attribute15,
                   loc.last_update_date                last_update_date,
                   loc.last_updated_by                 last_updated_by,
                   loc.last_update_login               last_update_login,
                   loc.creation_date                   creation_date,
                   loc.created_by                      created_by
            FROM   pn_locations_all loc,
                   fnd_lookups  fl,
                   fnd_lookups  fl1
            WHERE  fl.lookup_code(+) = loc.space_type_lookup_code
            AND    fl.lookup_type(+) = 'PN_SPACE_TYPE'
            AND    fl1.lookup_code(+)= loc.location_type_lookup_code
            AND    fl1.lookup_type(+)= 'PN_LOCATION_TYPE'
            and    nvl(trunc(as_of_date),trunc(loc.active_start_date)) between
                   trunc(loc.active_start_date) and trunc(loc.active_end_date);
/* Bug 4748773
            AND    loc.location_id IN (SELECT loc.location_id from pn_locations_all loc
                                       WHERE loc.active_start_date <= as_of_date
                                       AND   loc.active_end_date   >= as_of_date
                                       AND   loc.location_id = v_location_id_1 );
*/
         LOOP
            FETCH c_c_assign_pn
            INTO  v_location_id_2                            ,
                  v_location_type                            ,
                  v_location_name                            ,
                  v_location_code                            ,
                  v_loc_type                                 ,   --BUG#2226865
                  v_space_type                               ,
                  v_loc_area.rentable_area                   ,--BUG#2226865
                  v_loc_area.usable_area                     ,--BUG#2226865
                  v_loc_area.assignable_area                 ,--BUG#2226865
                  v_loc_area.common_area                     ,--BUG#2226865
                  v_attribute_category                       ,
                  v_attribute1                               ,
                  v_attribute2                               ,
                  v_attribute3                               ,
                  v_attribute4                               ,
                  v_attribute5                               ,
                  v_attribute6                               ,
                  v_attribute7                               ,
                  v_attribute8                               ,
                  v_attribute9                               ,
                  v_attribute10                              ,
                  v_attribute11                              ,
                  v_attribute12                              ,
                  v_attribute13                              ,
                  v_attribute14                              ,
                  v_attribute15                              ,
                  v_last_update_date                         ,
                  v_last_updated_by                          ,
                  v_last_update_login                        ,
                  v_creation_date                            ,
                  v_created_by                               ;
            EXIT WHEN c_c_assign_pn%NOTFOUND;

            OPEN cust_pn FOR
               SELECT DISTINCT
                      cust.location_id                     location_id,
                      0                                    person_id,
                      NULL                                 cost_center,
                      NULL                                 employee_project_number,
                      NULL                                 employee_task_number,
                      0                                    employee_assigned_area,
                      NULL                                 employee_assigned_FROM,
                      NULL                                 employee_assigned_to,
                      cust.expense_account_id              exp_account,
                      cust.cust_account_id                 customer_account_id,
                      pa.segment1                          customer_project_number,
                      pat.task_name                        customer_task_number,
                      cust.allocated_area                  customer_assigned_area,
                      cust.cust_assign_start_date          customer_assigned_from,
                      cust.cust_assign_end_date            customer_assigned_to,
                      hp.party_name                        customer_name,
                      hcsu.location                        customer_site,
                      arl.meaning                          customer_category
               FROM   hz_parties                      hp,
                      hz_cust_site_uses_all           hcsu,
                      ar_lookups                      arl,
                      hz_cust_accounts                hca,
                      pa_projects_all                 pa,
                      pa_tasks                        pat,
                      pn_space_assign_cust_all        cust
               WHERE  cust.location_id = v_location_id_2
               AND    hca.cust_account_id = cust.cust_account_id
               AND    hca.party_id = hp.party_id
               AND    arl.lookup_code(+) = hp.category_code
               AND    arl.lookup_type(+) = 'CUSTOMER_CATEGORY'
               AND    hcsu.site_use_id(+) = cust.site_use_id
               AND    pa.project_id(+) = cust.project_id
               AND    pat.task_id(+) = cust.task_id
               AND    as_of_date BETWEEN cust.cust_assign_start_date AND NVL(cust.cust_assign_end_date, l_date);
            LOOP
               FETCH cust_pn
               INTO  v_location_id,
                     v_person_id,
                     v_cost_center,
                     v_employee_project_number,
                     v_employee_task_number,
                     v_space_area.allocated_area_emp,  --BUG#2226865
                     v_employee_assigned_from,
                     v_employee_assigned_to,
                     v_exp_account,
                     v_customer_account_id,
                     v_customer_project_number,
                     v_customer_task_number,
                     v_space_area.allocated_area_cust,  --BUG#2226865
                     v_customer_assigned_from,
                     v_customer_assigned_to,
                     v_customer_name,
                     v_customer_site,
                     v_customer_category;

               v_customer_account :=  fnd_flex_ext.get_segs('SQLGL','GL#',v_coa_id,v_exp_account);
               EXIT WHEN cust_pn%NOTFOUND;
               v_compare_cust:= compare_assign_custloc(v_location_id, v_customer_account, l_request_id);
               IF NOT (v_compare_cust) THEN

                  v_code_data:=pnp_util_func.get_location_name(v_location_id, as_of_date);
                  v_emp_data:= pnp_util_func.get_emp_hr_data(v_person_id);
                  --dbms_output.put_line('fet'||sqlerrm);
                  --------------bug#2226865-----------------
                  IF V_LOC_TYPE in ('BUILDING' ,'LAND','FLOOR','PARCEL') THEN
                     PNP_UTIL_FUNC.get_area(v_location_id , v_loc_type ,NULL,as_of_date,v_loc_area,v_space_area);
                  END IF;
                  -----------bug#2226865--------


                  INSERT INTO pn_space_assign_loc_itf
                  (
                   location_id                     ,
                   location_type                   ,
                   location_name                   ,
                   location_code                   ,
                   space_type                      ,
                   property_code                   ,
                   property_name                   ,
                   building_location_code          ,
                   building_or_land_name           ,
                   floor_location_code             ,
                   floor_or_parcel_name            ,
                   office_location_code            ,
                   office_or_section_name          ,
                   rentable_area                   ,
                   usable_area                     ,
                   assignable_area                 ,
                   common_area                     ,
                   person_id                       ,
                   employee_name                   ,
                   cost_center                     ,
                   employee_number                 ,
                   employee_type                   ,
                   employee_category               ,
                   employee_position               ,
                   employee_project_number         ,
                   employee_task_number            ,
                   employee_assigned_area          ,
                   employee_assigned_from          ,
                   employee_assigned_to            ,
                   customer_name                   ,
                   customer_site                   ,
                   customer_category               ,
                   customer_account                ,
                   customer_project_number         ,
                   customer_task_number            ,
                   customer_assigned_area          ,
                   customer_vacant_area            ,
                   customer_assigned_from          ,
                   customer_assigned_to            ,
                   loc_attribute_category          ,
                   loc_attribute1                  ,
                   loc_attribute2                  ,
                   loc_attribute3                  ,
                   loc_attribute4                  ,
                   loc_attribute5                  ,
                   loc_attribute6                  ,
                   loc_attribute7                  ,
                   loc_attribute8                  ,
                   loc_attribute9                  ,
                   loc_attribute10                 ,
                   loc_attribute11                 ,
                   loc_attribute12                 ,
                   loc_attribute13                 ,
                   loc_attribute14                 ,
                   loc_attribute15                 ,
                   last_update_date                ,
                   last_updated_by                 ,
                   last_update_login               ,
                   creation_date                   ,
                   created_by                      ,
                   request_id
                  )
                  VALUES
                  (
                   v_location_id                                ,
                   v_location_type                              ,
                   v_location_name                              ,
                   v_location_code                              ,
                   v_space_type                                 ,
                   v_code_data.property_code                    ,
                   v_code_data.property_name                    ,
                   v_code_data.building_location_code           ,
                   v_code_data.building                         ,
                   v_code_data.floor_location_code              ,
                   v_code_data.floor                            ,
                   v_code_data.office_location_code             ,
                   v_code_data.office                           ,
                   v_loc_area.rentable_area                     , --BUG#2226865
                   v_loc_area.usable_area                       ,--BUG#2226865
                   v_loc_area.assignable_area                   ,--BUG#2226865
                   v_loc_area.common_area                       ,--BUG#2226865
                   v_person_id                                  ,
                   v_emp_data.full_name                         ,
                   v_cost_center                                ,
                   v_emp_data.employee_number                   ,
                   v_emp_data.employee_type                     ,
                   v_emp_data.employment_category_meaning       ,
                   v_emp_data.position                          ,
                   v_employee_project_number                    ,
                   v_employee_task_number                       ,
                   v_space_area.allocated_area_emp              ,  --BUG#2226865
                   v_employee_assigned_from                     ,
                   v_employee_assigned_to                       ,
                   v_customer_name                              ,
                   v_customer_site                              ,
                   v_customer_category                          ,
                   v_customer_account                           ,
                   v_customer_project_number                    ,
                   v_customer_task_number                       ,
                   v_space_area.allocated_area_cust             ,  --BUG#2226865
                   v_space_area.vacant_area                     ,  --Bug#2226865
                   v_customer_assigned_from                     ,
                   v_customer_assigned_to                       ,
                   v_attribute_category                         ,
                   v_attribute1                                 ,
                   v_attribute2                                 ,
                   v_attribute3                                 ,
                   v_attribute4                                 ,
                   v_attribute5                                 ,
                   v_attribute6                                 ,
                   v_attribute7                                 ,
                   v_attribute8                                 ,
                   v_attribute9                                 ,
                   v_attribute10                                ,
                   v_attribute11                                ,
                   v_attribute12                                ,
                   v_attribute13                                ,
                   v_attribute14                                ,
                   v_attribute15                                ,
                   v_last_update_date                           ,
                   v_last_updated_by                            ,
                   v_last_update_login                          ,
                   v_creation_date                              ,
                   v_created_by                                 ,
                   l_request_id
                  );
               END IF;
            END LOOP;
         END LOOP;
      END LOOP;
      COMMIT;
      IF dbms_sql.is_open (l_cursor) THEN
        dbms_sql.close_cursor (l_cursor);
      END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
       retcode:=2;
       errbuf:=SUBSTR(SQLERRM,1,235);
       RAISE;
END pn_space_assign_loc;

END pnrx_sp_assign_by_loc;

/
