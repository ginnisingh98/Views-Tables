--------------------------------------------------------
--  DDL for Package Body JTF_RS_CONC_RES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_CONC_RES_PUB" AS
/* $Header: jtfrsbrb.pls 120.6.12010000.4 2009/05/22 09:37:52 rgokavar ship $ */

  /*****************************************************************************************
   This is a concurrent program to fetch all employees from the employee database for creating
   resources in resource manager. All employees who are valid on sysdate and are not already
   existing in resource manager will be fetched

   This program also updates the party and partner information from TCA model

   ******************************************************************************************/

    /* Package variables. */

  G_PKG_NAME       CONSTANT VARCHAR2(30) := 'JTF_RS_CONC_RES_PUB';
  g_run_date       DATE;

  /* Function to get the start date of the primary job assignment */

  FUNCTION get_asg_start_date(p_job_id NUMBER, p_person_id NUMBER, p_assignment_id NUMBER, p_assignment_type VARCHAR2)
    RETURN DATE
  IS
    l_asg_start_date         DATE;
    l_asg_start_date_temp    DATE;
    l_job_id                 NUMBER;
    l_job_id_temp            NUMBER;

    CURSOR c_get_start_date(c_job_id IN NUMBER, c_person_id IN NUMBER, c_assignment_id NUMBER, c_assignment_type VARCHAR2) IS
    select job_id, effective_start_date
    from   per_all_assignments_f
    where  person_id = c_person_id
--    and    assignment_type = 'E'
    and    assignment_type = c_assignment_type
    and    primary_flag = 'Y'
--    and    job_id = c_job_id
    and    assignment_id = c_assignment_id
    and    trunc(effective_start_date) <= g_run_date
    order by effective_start_date desc;

  BEGIN

     l_job_id := p_job_id;
     l_job_id_temp := p_job_id;

     OPEN c_get_start_date(p_job_id,p_person_id,p_assignment_id,p_assignment_type);
     LOOP
        FETCH c_get_start_date INTO l_job_id_temp, l_asg_start_date_temp;
        if (l_job_id = l_job_id_temp) then
           l_asg_start_date := l_asg_start_date_temp;
        else
           EXIT;
        end if;
        EXIT WHEN c_get_start_date%NOTFOUND;
     END LOOP;
     CLOSE c_get_start_date;

    RETURN l_asg_start_date;

  END;

   /* Enh 3947611 2-dec-2004:Function to get the start date of the primary job assignment for future dated employees */

  FUNCTION get_ftr_asg_start_date(p_job_id NUMBER, p_person_id NUMBER, p_assignment_id NUMBER, p_assignment_type VARCHAR2)
    RETURN DATE
  IS
    l_asg_start_date         DATE;
    l_asg_start_date_temp    DATE;
    l_job_id                 NUMBER;
    l_job_id_temp            NUMBER;

    CURSOR c_get_start_date(c_job_id IN NUMBER, c_person_id IN NUMBER, c_assignment_id NUMBER, c_assignment_type VARCHAR2) IS
    select job_id, effective_start_date
    from   per_all_assignments_f
    where  person_id = c_person_id
--    and    assignment_type = 'E'
    and    assignment_type = c_assignment_type
    and    primary_flag = 'Y'
--    and    job_id = c_job_id
    and    assignment_id = c_assignment_id
    --and    trunc(effective_start_date) <= trunc(sysdate)
    order by effective_start_date desc;

  BEGIN

     l_job_id := p_job_id;
     l_job_id_temp := p_job_id;

     OPEN c_get_start_date(p_job_id,p_person_id,p_assignment_id,p_assignment_type);
     LOOP
        FETCH c_get_start_date INTO l_job_id_temp, l_asg_start_date_temp;
        if (l_job_id = l_job_id_temp) then
           l_asg_start_date := l_asg_start_date_temp;
        else
           EXIT;
        end if;
        EXIT WHEN c_get_start_date%NOTFOUND;
     END LOOP;
     CLOSE c_get_start_date;

    RETURN l_asg_start_date;

  END;


  /* Function to get the end date of the primary job assignment */

  FUNCTION get_asg_end_date(p_job_id NUMBER, p_person_id NUMBER, p_assignment_id NUMBER, p_assignment_type VARCHAR2)
    RETURN DATE
  IS
    l_asg_end_date    DATE;

    CURSOR c_get_end_date(c_job_id IN NUMBER, c_person_id IN NUMBER, c_assignment_id NUMBER, c_assignment_type VARCHAR2) IS
    select effective_end_date
    from   per_all_assignments_f
    where  person_id = c_person_id
--    and    assignment_type = 'E'
    and    assignment_type = c_assignment_type
    and    primary_flag = 'Y'
    and    job_id = c_job_id
    and    assignment_id = c_assignment_id
    and    trunc(effective_start_date) <= g_run_date
    order by effective_start_date desc;

  BEGIN

     OPEN c_get_end_date(p_job_id,p_person_id,p_assignment_id,p_assignment_type);
     FETCH c_get_end_date INTO l_asg_end_date;
     CLOSE c_get_end_date;

    RETURN l_asg_end_date;

  END;

  PROCEDURE UPDATE_EMP_PHONE;

  --procedure to group together all the synchronizing procedures
   PROCEDURE  synchronize_employee
   (ERRBUF                   OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2,
   P_OVERWRITE_NAME          IN  VARCHAR2,
   P_GET_NEW_EMP             IN  VARCHAR2,
   P_DUMMY_1                 IN  VARCHAR2,
   P_CREATE_SRP              IN  VARCHAR2,
   P_DUMMY_2                 IN  VARCHAR2,
   P_SALES_CREDIT_TYPE       IN  VARCHAR2,
   P_CHECK_JOB_ROLE_MAP      IN  VARCHAR2
   )

   IS

  /* Moved the initial assignment of below variables to inside begin */
   set_err_var VARCHAR2(1);
   l_prof_srp_num  fnd_profile_option_values.profile_option_value%TYPE;

   BEGIN

   set_err_var     := 'N';
   l_prof_srp_num  := FND_PROFILE.VALUE('JTF_RS_MODE_OF_SRP_NUM_CREATION');
   g_run_date      := nvl(to_date(FND_PROFILE.VALUE('JTF_RS_SYNC_RUN_DATE'),'MM/DD/YYYY'),trunc(sysdate));

     SAVEPOINT CONC_EMPLOYEE_SP;

     -- Adding Code for Enh to Create Salesperson and Roles (Job-Role Map) Automatically
     IF (p_get_new_emp ='Y') THEN
       IF (p_create_srp = 'Y') THEN
         IF (p_sales_credit_type IS NULL) THEN
           fnd_message.set_name ('JTF','JTF_RS_CP_PM_SLS_CRDT_TYP_NULL');
           fnd_file.put_line(fnd_file.log, fnd_message.get);
           fnd_file.new_line(fnd_file.log,1);
           set_err_var := 'Y';
         END IF;
         IF (l_prof_srp_num = 'MANUALLY_ENTERED' OR l_prof_srp_num IS NULL) THEN
           fnd_message.set_name('JTF', 'JTF_RS_PROF_SRP_NUM_CONC_ERR');
           fnd_message.set_token('P_PROFILE_VALUE', l_prof_srp_num);
           fnd_file.put_line(fnd_file.log, fnd_message.get);
           fnd_file.new_line(fnd_file.log,1);
           set_err_var := 'Y';
         END IF;
       END IF;
     END IF;

     IF (set_err_var='Y') THEN
       raise fnd_api.g_exc_error;
     END IF;

   -- End Code for Enh

     --call terminate api
        jtf_rs_conc_res_pub.terminate_employee;


     --call update api
       jtf_rs_conc_res_pub.update_employee
              (P_OVERWRITE_NAME => P_OVERWRITE_NAME);

     -- call update terminated api
     -- jtf_rs_conc_res_pub.update_terminated_employee;

     -- call update phones for employees
     -- update_emp_phone;

     --call create api
     IF(p_get_new_emp = 'Y')
     THEN
       jtf_rs_conc_res_pub.create_employee
         (P_CREATE_SRP          => P_CREATE_SRP,
          P_SALES_CREDIT_TYPE   => P_SALES_CREDIT_TYPE,
          P_CHECK_JOB_ROLE_MAP  => P_CHECK_JOB_ROLE_MAP);
     END IF;

    commit;

    EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO CONC_EMPLOYEE_SP;
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO CONC_EMPLOYEE_SP;
      --FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      --ROLLBACK TO CONC_EMPLOYEE_SP;
      --FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   END synchronize_employee;


    /* Procedure to create the resource  */

  PROCEDURE  create_employee
   (P_CREATE_SRP           IN  VARCHAR2,
    P_SALES_CREDIT_TYPE    IN  VARCHAR2,
    P_CHECK_JOB_ROLE_MAP   IN  VARCHAR2
   )

   IS

   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'CREATE_EMPLOYEE';
   l_return_status       VARCHAR2(2);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_resource_id         jtf_rs_resource_extns.resource_id%TYPE;
   l_resource_number     jtf_rs_resource_extns.resource_number%TYPE;
   l_source_number       jtf_rs_resource_extns.source_number%TYPE;
   l_assignment_type     per_all_assignments_f.assignment_type%TYPE;
-- l_msg_index_out       number;
-- l_msg_data1            varchar2(5000);

  -- Variables and Cursors added for Enh/Bug 2828368

   l_salesperson_number    jtf_rs_salesreps.salesrep_number%TYPE;
   l_role_id               jtf_rs_roles_vl.role_id%TYPE;
   l_role_name             jtf_rs_roles_vl.role_name%TYPE;
  /* Moved the initial assignment of below variable to inside begin */
   l_sales_credit_type     oe_sales_credit_types.name%TYPE;
   l_sales_credit_type_id  oe_sales_credit_types.sales_credit_type_id%TYPE;

  /* Moved the initial assignment of below variable to inside begin */
   l_prof_srp_num      fnd_profile_option_values.profile_option_value%TYPE;
   l_prof_get_emp_org  fnd_profile_option_values.profile_option_value%TYPE;
   l_prof_org          fnd_profile_option_values.profile_option_value%TYPE;

   r_return_status       VARCHAR2(2);
   r_msg_count           NUMBER;
   r_msg_data            VARCHAR2(2000);

   s_return_status       VARCHAR2(2);
   s_msg_count           NUMBER;
   s_msg_data            VARCHAR2(2000);

   l_salesrep_id         jtf_rs_salesreps.salesrep_id%TYPE;
   m_salesrep_id         jtf_rs_salesreps.salesrep_id%TYPE;
   l_role_relate_id      jtf_rs_role_relations.role_relate_id%TYPE;

   CURSOR c_salesrep_number (l_salesrep_number jtf_rs_salesreps.salesrep_number%TYPE) IS
     SELECT salesrep_id FROM jtf_rs_salesreps
     WHERE salesrep_number = l_salesrep_number;

   CURSOR c_job_roles (l_job_id jtf_rs_job_roles.job_id%TYPE) IS
     SELECT role_id
     FROM jtf_rs_job_roles
     WHERE job_id = l_job_id;

   CURSOR c_role_name (l_role_id jtf_rs_roles_vl.role_id%TYPE) IS
     SELECT role_name
     FROM jtf_rs_roles_vl
     WHERE role_id = l_role_id;

   -- Added the below cursor to get the role type for a role id.
   CURSOR c_get_role_type (l_role_id jtf_rs_roles_vl.role_id%TYPE) IS
     SELECT role_type_code
     FROM jtf_rs_roles_b
     WHERE role_id = l_role_id;

   l_role_type_code jtf_rs_roles_b.role_type_code%TYPE;

   CURSOR c_sales_credit_type_id (l_sales_credit_type oe_sales_credit_types.name%TYPE) IS
     SELECT sales_credit_type_id
     FROM oe_sales_credit_types
     WHERE name = l_sales_credit_type;

  -- End of Variables and Cursors Added


  CURSOR fetch_emp_cur
      IS
 SELECT ppl.person_id            person_id
       , ppl.employee_number     employee_number
       , ppl.npw_number          npw_number
       , ppl.known_as            known_as
       , ppl.full_name           full_name
       , ppl.first_name          first_name
       , ppl.last_name           last_name
       , ppl.middle_names        middle_name
       , ppl.work_telephone      phone
       , ppl.email_address       email
       , job.job_id              job_id
       , job.name                job_title
       , ppl.effective_start_date effective_start_date
       , ppl.effective_end_date  effective_end_date
       , ppl.business_group_id   org_id
       , org.name                org_name
       , loc.address_line_1      address1
       , loc.address_line_2      address2
       , loc.address_line_3      address3
       , null                    address4
       , loc.town_or_city        city
       , null                    county
       , loc.country             country
       , loc.postal_code         postal_code
       , null                    state
       , null                    province
       , asg.supervisor_id       mgr_id
       , emp.full_name           mgr_name
       , ppl.office_number       office
       , ppl.internal_location   location
       , ppl.mailstop            mailstop
       , asg.location_id         address_id
       , asg.assignment_id       assignment_id
       , asg.assignment_type     assignment_type
  FROM  per_all_people_f         ppl
      , hr_all_organization_units org
      , per_all_assignments_f         asg
      , per_jobs                  job
      --, hr_locations           loc (SQL rep perf bug 4956611 Nishant 28-Mar-2006)
      , hr_locations_all         loc
      --, per_employees_current_x   emp
      , per_all_people_f          emp
--  WHERE NOT EXISTS (select source_id
  WHERE NOT EXISTS (select 1
                      from jtf_rs_resource_extns rsc
                     where category = 'EMPLOYEE'
                       and  ppl.person_id = rsc.source_id)
    and    ppl.business_group_id = org.organization_id
    and    ppl.person_id   = asg.person_id
    and    trunc(sysdate ) between ppl.effective_start_date and ppl.effective_end_date
--    and    ppl.employee_number is not null
    and    (ppl.current_employee_flag = 'Y' OR ppl.current_npw_flag = 'Y')
    and    asg.primary_flag = 'Y'
--    and    asg.assignment_type = 'E'
    and    (asg.assignment_type = 'E' OR asg.assignment_type = 'C')
    and    trunc(sysdate ) between asg.effective_start_date and asg.effective_end_date
    and    asg.job_id   = job.job_id(+)
    and    asg.location_id  = loc.location_id (+)
    --and    asg.supervisor_id   = emp.employee_id(+)
    and    asg.supervisor_id   = emp.person_id(+)
  and    trunc(sysdate ) between emp.effective_start_date(+) and emp.effective_end_date(+);

   -- Enh 3947611 2-dec-2004:future dated employee cursor
  CURSOR fetch_future_emp_cur
      IS
 SELECT ppl.person_id            person_id
       , ppl.employee_number     employee_number
       , ppl.npw_number          npw_number
       , ppl.known_as            known_as
       , ppl.full_name           full_name
       , ppl.first_name          first_name
       , ppl.last_name           last_name
       , ppl.middle_names        middle_name
       , ppl.work_telephone      phone
       , ppl.email_address       email
       , job.job_id              job_id
       , job.name                job_title
       , ppl.effective_start_date effective_start_date
       , ppl.effective_end_date  effective_end_date
       , ppl.business_group_id   org_id
       , org.name                org_name
       , loc.address_line_1      address1
       , loc.address_line_2      address2
       , loc.address_line_3      address3
       , null                    address4
       , loc.town_or_city        city
       , null                    county
       , loc.country             country
       , loc.postal_code         postal_code
       , null                    state
       , null                    province
       , asg.supervisor_id       mgr_id
       , emp.full_name           mgr_name
       , ppl.office_number       office
       , ppl.internal_location   location
       , ppl.mailstop            mailstop
       , asg.location_id         address_id
       , asg.assignment_id       assignment_id
       , asg.assignment_type     assignment_type
  FROM  per_all_people_f         ppl
      , hr_all_organization_units org
      , per_all_assignments_f         asg
      , per_jobs                  job
      --, hr_locations            loc (SQL rep perf bug 4956611 Nishant 28-Mar-2006)
      , hr_locations_all          loc
      --, per_employees_current_x   emp
      , per_all_people_f          emp
  -- WHERE NOT EXISTS (select source_id
  WHERE NOT EXISTS (select 1
                      from jtf_rs_resource_extns rsc
                     where category = 'EMPLOYEE'
                       and  ppl.person_id = rsc.source_id)
    and    ppl.business_group_id     = org.organization_id
    and    ppl.person_id             = asg.person_id
    and    trunc(sysdate)            <= ppl.effective_end_date
    and    ppl.effective_start_date   > trunc(sysdate )
    and    (ppl.current_employee_flag = 'Y' OR ppl.current_npw_flag = 'Y')
    and    asg.primary_flag           = 'Y'
    and    (asg.assignment_type       = 'E' OR asg.assignment_type = 'C')
   -- and    trunc(sysdate )           <= asg.effective_end_date -- (not required as start_date >= sysdate is already checked)
    and    asg.effective_start_date   = (select min(asg1.effective_start_date)
                                           from per_all_assignments_f asg1
                                          where ppl.person_id             = asg1.person_id
                                            and asg1.effective_start_date >= trunc(sysdate)
                                            and asg.primary_flag          = 'Y')
    and    asg.job_id                = job.job_id(+)
    and    asg.location_id           = loc.location_id (+)
    and    asg.supervisor_id         = emp.person_id(+);
   -- and    trunc(sysdate )          <= emp.effective_end_date(+);


  CURSOR fetch_user_cur(l_employee_id NUMBER)
      IS
  SELECT user_id,
         user_name
    FROM fnd_user
   WHERE employee_id = l_employee_id;

  cursor fetch_phone(l_person_id number)
      is
  select phone_number
   from  per_phones p1
  where  parent_table = 'PER_ALL_PEOPLE_F'
    and  parent_id    = l_person_id
    and  phone_type = 'W1'
    and  trunc(sysdate) between date_from and nvl(date_to, to_date('31/12/4712', 'DD/MM/YYYY'));

    -- Enh 3947611 2-dec-2004:for future dated emp phone
    cursor fetch_future_phone(l_person_id number)
      is
  select phone_number
   from  per_phones p1
  where  parent_table = 'PER_ALL_PEOPLE_F'
    and  parent_id    = l_person_id
    and  phone_type = 'W1'
    and  date_from  = (select max(date_from)
                        from  per_phones p2
                       where  parent_table = 'PER_ALL_PEOPLE_F'
                         and  parent_id    = l_person_id
                         and  phone_type = 'W1');


  -- to get the active start date and end_date of the employee
  -- changed the ORDER BY from desc to asc. Fix for bug # 3300436
  CURSOR c_active_emp_dates (l_person_id IN NUMBER) IS
    SELECT date_start, actual_termination_date
    FROM per_periods_of_service
    WHERE person_id = l_person_id
    ORDER BY date_start asc;

--  CURSOR c_active_npw_dates (l_person_id IN NUMBER) IS
--    SELECT date_start, actual_termination_date
--    FROM per_periods_of_placement
--    WHERE person_id = l_person_id
--    ORDER BY date_start asc;

   -- Added the below cursor to validate the operating unit belongs to the current business_group_id
   CURSOR op_units_cur(c_business_group_id number, c_org_id number) IS
   select organization_id
   from   hr_operating_units
   where  business_group_id = c_business_group_id
   and    organization_id = c_org_id;

   l_organization_id number;
   l_salesrep_extsts varchar2(2);
   l_create_salesrep varchar2(2);
   l_org_id          number;

   TYPE Getenddate IS REF CURSOR;
   get_enddate_date Getenddate;

   l_query          varchar2(300);

   l_table_not_found EXCEPTION;  --exception to handle table not found;
   PRAGMA EXCEPTION_INIT(l_table_not_found, -00942 );

  l_user_id    NUMBER;
  l_user_name  VARCHAR2(2000);
  i            NUMBER;
  l_value      varchar2(2000);
  l_count      number;
  l_phone      per_phones.phone_number%type;

  l_active_emp_start_date DATE;
  l_active_emp_end_date   DATE;
  l_asg_start_date        date;

  BEGIN

   l_sales_credit_type  := P_SALES_CREDIT_TYPE;
   l_prof_srp_num       := FND_PROFILE.VALUE('JTF_RS_MODE_OF_SRP_NUM_CREATION');
   l_prof_get_emp_org   := FND_PROFILE.VALUE('JTF_RS_SYNC_EMP_BUSINESS_GROUP');
   l_prof_org           := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');

   l_query        := 'SELECT date_start, actual_termination_date '||
    'FROM per_periods_of_placement ' ||
    'WHERE person_id = :b_person_id '||
    'ORDER BY date_start asc';


  --Standard Start of API SAVEPOINT
   SAVEPOINT CREATE_EMPLOYEE_SP;

   l_return_status := fnd_api.g_ret_sts_success;

   -- Fetch Sales Credit Type if you want to create Salesperson
   IF (p_create_srp='Y') THEN
     OPEN c_sales_credit_type_id (l_sales_credit_type);
     FETCH c_sales_credit_type_id INTO l_sales_credit_type_id;
     CLOSE c_sales_credit_type_id;

     MO_GLOBAL.init('JTF');
     l_org_id := MO_UTILS.get_default_org_id;
   END IF;

   -- start of import of employees
  l_count := 1;
  For fetch_emp_rec IN fetch_emp_cur
  loop

  -- Start of business profile validation
  if (l_prof_get_emp_org = 'ALL' or l_prof_org = fetch_emp_rec.org_id) then

    -- Adding Code for Enh

    BEGIN

      SAVEPOINT create_resource_sp;

      l_role_id := NULL;

      IF (fetch_emp_rec.job_id IS NOT NULL) THEN
        OPEN c_job_roles (fetch_emp_rec.job_id);
        FETCH c_job_roles into l_role_id;
        CLOSE c_job_roles;
      END IF;

      IF ((P_CHECK_JOB_ROLE_MAP = 'N') OR
          (P_CHECK_JOB_ROLE_MAP = 'Y' AND l_role_id IS NOT NULL)) THEN

      -- End Adding Code

        --fetch the user_id for the employee
        l_user_id := null;
        l_user_name := null;
        open fetch_user_cur(fetch_emp_rec.person_id);
        fetch fetch_user_cur into l_user_id, l_user_name;
        close fetch_user_cur;

        --fetch phone number
        l_phone := null;
        open fetch_phone(fetch_emp_rec.person_id);
        fetch fetch_phone into l_phone;
        close fetch_phone;

        l_return_status := fnd_api.g_ret_sts_success;
        r_return_status := fnd_api.g_ret_sts_success;
        s_return_status := fnd_api.g_ret_sts_success;

        --fetch active emp dates
        l_active_emp_start_date := NULL;
        l_active_emp_end_date   := NULL;

        if fetch_emp_rec.assignment_type = 'E' then
           l_source_number := fetch_emp_rec.employee_number;
           l_assignment_type := 'E';

           OPEN c_active_emp_dates (fetch_emp_rec.person_id);
           FETCH c_active_emp_dates INTO l_active_emp_start_date,l_active_emp_end_date;
           IF c_active_emp_dates%NOTFOUND THEN
              l_active_emp_start_date := fetch_emp_rec.effective_start_date;
              l_active_emp_end_date   := fetch_emp_rec.effective_end_date;
           END IF;
           CLOSE c_active_emp_dates;
        else
           l_source_number := fetch_emp_rec.npw_number;
           l_assignment_type := 'C';

--           OPEN c_active_npw_dates (fetch_emp_rec.person_id);
--           FETCH c_active_npw_dates INTO l_active_emp_start_date,l_active_emp_end_date;
--           IF c_active_npw_dates%NOTFOUND THEN
--              l_active_emp_start_date := fetch_emp_rec.effective_start_date;
--              l_active_emp_end_date   := fetch_emp_rec.effective_end_date;
--           END IF;
--           CLOSE c_active_npw_dates;

           begin
              OPEN get_enddate_date FOR l_query USING fetch_emp_rec.person_id;
              FETCH get_enddate_date into l_active_emp_start_date, l_active_emp_end_date;
              IF get_enddate_date%NOTFOUND THEN
                 l_active_emp_start_date := fetch_emp_rec.effective_start_date;
                 l_active_emp_end_date   := fetch_emp_rec.effective_end_date;
              END IF;
              CLOSE get_enddate_date;
           exception
           when l_table_not_found then
              l_active_emp_start_date := fetch_emp_rec.effective_start_date;
              l_active_emp_end_date   := fetch_emp_rec.effective_end_date;
           end;
        end if;

        -- call the public api for create resource
       /* Fix for bug # 3300436. commented P_END_DATE_ACTIVE */
        jtf_rs_resource_pub.create_resource
          ( P_API_VERSION 		=> 1,
            P_INIT_MSG_LIST 		=> fnd_api.g_true,
            P_COMMIT 			=> fnd_api.g_false,
            P_CATEGORY 			=> 'EMPLOYEE',
            P_SOURCE_ID 		=> fetch_emp_rec.person_id,
            P_ADDRESS_ID 		=> fetch_emp_rec.address_id,
            P_CONTACT_ID 		=> null,
            P_MANAGING_EMP_ID 		=> null,
            P_START_DATE_ACTIVE 	=> l_active_emp_start_date,
--            P_END_DATE_ACTIVE 		=> l_active_emp_end_date,
            P_TIME_ZONE 		=> null,
            P_COST_PER_HR 		=> null,
            P_PRIMARY_LANGUAGE 		=> null,
            P_SECONDARY_LANGUAGE 	=> null,
            P_SUPPORT_SITE_ID 		=> null,
            P_IES_AGENT_LOGIN 		=> null,
            P_SERVER_GROUP_ID 		=> null,
            P_ASSIGNED_TO_GROUP_ID 	=> null,
            P_COST_CENTER 		=> null,
            P_CHARGE_TO_COST_CENTER 	=> null,
            P_COMP_CURRENCY_CODE 	=> null,
            P_COMMISSIONABLE_FLAG 	=> null,
            P_HOLD_REASON_CODE 		=> null,
            P_HOLD_PAYMENT 		=> null,
            P_COMP_SERVICE_TEAM_ID 	=> null,
            P_USER_ID 			=> l_user_id,
            P_TRANSACTION_NUMBER 	=> null,
            X_RETURN_STATUS 		=> l_return_status,
            X_MSG_COUNT 		=> l_msg_count,
            X_MSG_DATA 			=> l_msg_data,
            X_RESOURCE_ID 		=> l_resource_id,
            X_RESOURCE_NUMBER 		=> l_resource_number,
          --P_RESOURCE_NAME             => fetch_emp_rec.full_name ,
            P_RESOURCE_NAME             => nvl(fetch_emp_rec.known_as,fetch_emp_rec.full_name) ,
            P_SOURCE_NAME               => fetch_emp_rec.full_name,
            P_SOURCE_NUMBER             => l_source_number,
            P_SOURCE_JOB_TITLE          => fetch_emp_rec.job_title,
            P_SOURCE_EMAIL              => fetch_emp_rec.email,
            P_SOURCE_PHONE              => l_phone,
            P_SOURCE_ORG_ID             => null,
            P_SOURCE_ORG_NAME           => null,
            P_SOURCE_ADDRESS1           => fetch_emp_rec.address1,
            P_SOURCE_ADDRESS2           => fetch_emp_rec.address2,
            P_SOURCE_ADDRESS3           => fetch_emp_rec.address3,
            P_SOURCE_ADDRESS4           => fetch_emp_rec.address4,
            P_SOURCE_CITY               => fetch_emp_rec.city,
            P_SOURCE_POSTAL_CODE        => fetch_emp_rec.postal_code,
            P_SOURCE_STATE              => fetch_emp_rec.state,
            P_SOURCE_PROVINCE           => fetch_emp_rec.province,
            P_SOURCE_COUNTY             => fetch_emp_rec.county,
            P_SOURCE_COUNTRY            => fetch_emp_rec.country,
            P_SOURCE_MGR_ID             => fetch_emp_rec.mgr_id,
            P_SOURCE_MGR_NAME           => fetch_emp_rec.mgr_name,
            P_SOURCE_BUSINESS_GRP_ID    => fetch_emp_rec.org_id,
            P_SOURCE_BUSINESS_GRP_NAME  => fetch_emp_rec.org_name,
            P_SOURCE_FIRST_NAME         => fetch_emp_rec.first_name,
            P_SOURCE_LAST_NAME          => fetch_emp_rec.last_name,
            P_SOURCE_MIDDLE_NAME        => fetch_emp_rec.middle_name,
            P_SOURCE_CATEGORY           => null,
            P_SOURCE_STATUS             => null,
            P_SOURCE_OFFICE             => fetch_emp_rec.office,
            P_SOURCE_LOCATION           => fetch_emp_rec.location,
            P_SOURCE_MAILSTOP           => fetch_emp_rec.mailstop,
            P_USER_NAME                 => l_user_name
        );

        -- dbms_output.put_line('name '||fetch_emp_rec.full_name);
        IF ( l_return_status <> fnd_api.g_ret_sts_success) THEN
          fnd_message.set_name('JTF', 'JTF_RS_CONC_CREATE_EMP_ERR');
          fnd_message.set_token('P_EMPLOYEE_NAME', fetch_emp_rec.full_name);
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          FOR i IN 1..l_msg_count
          LOOP
             fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                            p_encoded => fnd_api.g_false)));
          END LOOP;
          fnd_msg_pub.delete_msg;
          fnd_file.new_line(fnd_file.log,1);
          raise fnd_api.g_exc_error;
        END IF;

        -- Code added by repuri (04/09/03) for Enh/Bug # 2828368

        l_organization_id := NULL;
        l_salesrep_extsts := 'N';
        l_create_salesrep := 'N';

        IF (P_CREATE_SRP = 'Y') THEN

          -- To get the current operating unit. if l_org_id is NULL, then it is a single org
--          select to_number(decode(substrb(userenv('CLIENT_INFO'),1,1),' ',null,substrb(userenv('CLIENT_INFO'),1,10)))
--          into   l_org_id
--          from   dual;

          if l_org_id is NOT NULL then
             OPEN op_units_cur(fetch_emp_rec.org_id,l_org_id);
             FETCH op_units_cur INTO l_organization_id;
             IF op_units_cur%FOUND THEN
                l_create_salesrep := 'Y';
             END IF;
             CLOSE op_units_cur;
--          else
--             l_create_salesrep := 'Y';
          end if;

          if l_create_salesrep = 'Y' then

          l_salesperson_number := NULL;
          IF (l_prof_srp_num = 'EMPLOYEE_NUMBER') THEN
            l_salesperson_number := l_source_number;
          ELSIF (l_prof_srp_num = 'SEQUENCE_GENERATED') THEN
            LOOP
              SELECT jtf_rs_salesrep_number_s.nextval
              INTO l_salesperson_number
              FROM DUAL;

              OPEN c_salesrep_number(l_salesperson_number);
              FETCH c_salesrep_number INTO m_salesrep_id;
              EXIT WHEN c_salesrep_number%NOTFOUND;
              CLOSE c_salesrep_number;
            END LOOP;
            CLOSE c_salesrep_number;
          END IF;


          IF (l_salesperson_number IS NOT NULL AND l_sales_credit_type_id IS NOT NULL) THEN
            --Create a Salesperson for the Resource Created above
            JTF_RS_SALESREPS_PUB.CREATE_SALESREP (
              p_api_version                  => 1.0,
              p_init_msg_list                => fnd_api.g_true,
              p_commit                       => fnd_api.g_false,
              p_resource_id                  => l_resource_id,
              p_sales_credit_type_id         => l_sales_credit_type_id,
              p_salesrep_number              => l_salesperson_number,
              p_name                         => fetch_emp_rec.full_name,
              p_status                       => 'A',
              p_start_date_active            => l_active_emp_start_date,
              p_end_date_active              => null,
              p_org_id                       => l_org_id,
              p_gl_id_rev                    => null,
              p_gl_id_freight                => null,
              p_gl_id_rec                    => null,
              p_set_of_books_id              => null,
              p_email_address                => null,
              p_wh_update_date               => null,
              p_sales_tax_geocode            => null,
              p_sales_tax_inside_city_limits => null,
              x_return_status                => s_return_status,
              x_msg_count                    => s_msg_count,
              x_msg_data                     => s_msg_data,
              x_salesrep_id                  => l_salesrep_id
            );
            IF(s_return_status <> 'S') THEN
              fnd_message.set_name('JTF', 'JTF_RS_CP_SYN_EMP_CRT_SRP_ERR');
              fnd_message.set_token('P_EMPLOYEE_NAME', fetch_emp_rec.full_name);
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              FOR i IN 1..s_msg_count LOOP
                fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                                 p_encoded => fnd_api.g_false)));
              END LOOP;
              fnd_msg_pub.delete_msg;
              fnd_file.new_line(fnd_file.log,1);
              raise fnd_api.g_exc_error;
            END IF;
            l_salesrep_extsts := 'Y';
          END IF;
          END IF;

        END IF;

        /* added the below line to get the job assignment start date */
        /* also changed the value for p_start_date_active from sysdate to l_asg_start_date */
        l_asg_start_date := get_asg_start_date(fetch_emp_rec.job_id,fetch_emp_rec.person_id,fetch_emp_rec.assignment_id,l_assignment_type);

        FOR i IN c_job_roles(fetch_emp_rec.job_id) LOOP

          l_role_type_code := NULL;
          OPEN  c_get_role_type(i.role_id);
          FETCH c_get_role_type INTO l_role_type_code;
          CLOSE c_get_role_type;

          -- Check for Sales Comp Roles
          -- Will create the SALES_COMP roles only if the resource is a salesperson.
          if not (l_salesrep_extsts = 'N' and l_role_type_code = 'SALES_COMP') then

             JTF_RS_ROLE_RELATE_PVT.CREATE_RESOURCE_ROLE_RELATE(
               p_api_version         => 1.0,
               p_init_msg_list       => fnd_api.g_true,
               p_commit              => fnd_api.g_false,
               p_role_resource_type  => 'RS_INDIVIDUAL',
               p_role_resource_id    => l_resource_id,
               p_role_id             => i.role_id,
               p_start_date_active   => l_asg_start_date,
               x_return_status       => r_return_status,
               x_msg_count           => r_msg_count,
               x_msg_data            => r_msg_data,
               x_role_relate_id      => l_role_relate_id
             );
             IF ( r_return_status <> fnd_api.g_ret_sts_success) THEN
               l_role_name := NULL;
               OPEN c_role_name (i.role_id);
               FETCH c_role_name INTO l_role_name;
               CLOSE c_role_name;
               fnd_message.set_name('JTF', 'JTF_RS_CP_SYN_EMP_CRT_RES_ROLE');
               fnd_message.set_token('P_EMPLOYEE_NAME', fetch_emp_rec.full_name);
               fnd_message.set_token('P_ROLE_NAME',l_role_name);
               fnd_file.put_line(fnd_file.log, fnd_message.get);
               FOR i IN 1..r_msg_count LOOP
                 fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                                  p_encoded => fnd_api.g_false)));
               END LOOP;
               fnd_msg_pub.delete_msg;
               fnd_file.new_line(fnd_file.log,1);
               raise fnd_api.g_exc_error;
             END IF;
          end if; -- End of Check for Sales Comp Roles
        END LOOP;

        -- End Add Code for Enh

        l_count := l_count + 1;
        IF (l_count > 1000) THEN
          commit;
          l_count := 1;
        END IF;

      END IF;

    EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
        fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
        ROLLBACK TO create_resource_sp;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
        fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
        ROLLBACK TO create_resource_sp;
      WHEN OTHERS
      THEN
        fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
        ROLLBACK TO create_resource_sp;

    END;

   end if; -- End of business profile validation

   END LOOP; -- fetch employee cursor end

     --Enh 3947611 2-dec-2004: create resource for future dated emplooyees
   --
    -- start of import of employees
  l_count := 1;
  For fetch_emp_rec IN fetch_future_emp_cur
  loop
  -- Start of business profile validation
  if (l_prof_get_emp_org = 'ALL' or l_prof_org = fetch_emp_rec.org_id) then
    -- Adding Code for Enh

    BEGIN

      SAVEPOINT create_resource_sp;

      l_role_id := NULL;

      IF (fetch_emp_rec.job_id IS NOT NULL) THEN
        OPEN c_job_roles (fetch_emp_rec.job_id);
        FETCH c_job_roles into l_role_id;
        CLOSE c_job_roles;
      END IF;

      IF ((P_CHECK_JOB_ROLE_MAP = 'N') OR
          (P_CHECK_JOB_ROLE_MAP = 'Y' AND l_role_id IS NOT NULL)) THEN


      -- End Adding Code

        --fetch the user_id for the employee
        l_user_id := null;
        l_user_name := null;
        open fetch_user_cur(fetch_emp_rec.person_id);
        fetch fetch_user_cur into l_user_id, l_user_name;
        close fetch_user_cur;

        --fetch phone number
        l_phone := null;
        open fetch_future_phone(fetch_emp_rec.person_id);
        fetch fetch_future_phone into l_phone;
        close fetch_future_phone;



        l_return_status := fnd_api.g_ret_sts_success;
        r_return_status := fnd_api.g_ret_sts_success;
        s_return_status := fnd_api.g_ret_sts_success;

        --fetch active emp dates
        l_active_emp_start_date := NULL;
        l_active_emp_end_date   := NULL;

        if fetch_emp_rec.assignment_type = 'E' then
           l_source_number := fetch_emp_rec.employee_number;
           l_assignment_type := 'E';

           OPEN c_active_emp_dates (fetch_emp_rec.person_id);
           FETCH c_active_emp_dates INTO l_active_emp_start_date,l_active_emp_end_date;
           IF c_active_emp_dates%NOTFOUND THEN
              l_active_emp_start_date := fetch_emp_rec.effective_start_date;
              l_active_emp_end_date   := fetch_emp_rec.effective_end_date;
           END IF;
           CLOSE c_active_emp_dates;
        else
           l_source_number := fetch_emp_rec.npw_number;
           l_assignment_type := 'C';

           begin
              OPEN get_enddate_date FOR l_query USING fetch_emp_rec.person_id;
              FETCH get_enddate_date into l_active_emp_start_date, l_active_emp_end_date;
              IF get_enddate_date%NOTFOUND THEN
                 l_active_emp_start_date := fetch_emp_rec.effective_start_date;
                 l_active_emp_end_date   := fetch_emp_rec.effective_end_date;
              END IF;
              CLOSE get_enddate_date;
           exception
           when l_table_not_found then
              l_active_emp_start_date := fetch_emp_rec.effective_start_date;
              l_active_emp_end_date   := fetch_emp_rec.effective_end_date;
           end;
        end if;

        -- call the public api for create resource
       /* Fix for bug # 3300436. commented P_END_DATE_ACTIVE */
        jtf_rs_resource_pub.create_resource
          ( P_API_VERSION 		=> 1,
            P_INIT_MSG_LIST 		=> fnd_api.g_true,
            P_COMMIT 			=> fnd_api.g_false,
            P_CATEGORY 			=> 'EMPLOYEE',
            P_SOURCE_ID 		=> fetch_emp_rec.person_id,
            P_ADDRESS_ID 		=> fetch_emp_rec.address_id,
            P_CONTACT_ID 		=> null,
            P_MANAGING_EMP_ID 		=> null,
            P_START_DATE_ACTIVE 	=> l_active_emp_start_date,
--            P_END_DATE_ACTIVE 		=> l_active_emp_end_date,
            P_TIME_ZONE 		=> null,
            P_COST_PER_HR 		=> null,
            P_PRIMARY_LANGUAGE 		=> null,
            P_SECONDARY_LANGUAGE 	=> null,
            P_SUPPORT_SITE_ID 		=> null,
            P_IES_AGENT_LOGIN 		=> null,
            P_SERVER_GROUP_ID 		=> null,
            P_ASSIGNED_TO_GROUP_ID 	=> null,
            P_COST_CENTER 		=> null,
            P_CHARGE_TO_COST_CENTER 	=> null,
            P_COMP_CURRENCY_CODE 	=> null,
            P_COMMISSIONABLE_FLAG 	=> null,
            P_HOLD_REASON_CODE 		=> null,
            P_HOLD_PAYMENT 		=> null,
            P_COMP_SERVICE_TEAM_ID 	=> null,
            P_USER_ID 			=> l_user_id,
            P_TRANSACTION_NUMBER 	=> null,
            X_RETURN_STATUS 		=> l_return_status,
            X_MSG_COUNT 		=> l_msg_count,
            X_MSG_DATA 			=> l_msg_data,
            X_RESOURCE_ID 		=> l_resource_id,
            X_RESOURCE_NUMBER 		=> l_resource_number,
          --P_RESOURCE_NAME             => fetch_emp_rec.full_name ,
            P_RESOURCE_NAME             => nvl(fetch_emp_rec.known_as,fetch_emp_rec.full_name) ,
            P_SOURCE_NAME               => fetch_emp_rec.full_name,
            P_SOURCE_NUMBER             => l_source_number,
            P_SOURCE_JOB_TITLE          => fetch_emp_rec.job_title,
            P_SOURCE_EMAIL              => fetch_emp_rec.email,
            P_SOURCE_PHONE              => l_phone,
            P_SOURCE_ORG_ID             => null,
            P_SOURCE_ORG_NAME           => null,
            P_SOURCE_ADDRESS1           => fetch_emp_rec.address1,
            P_SOURCE_ADDRESS2           => fetch_emp_rec.address2,
            P_SOURCE_ADDRESS3           => fetch_emp_rec.address3,
            P_SOURCE_ADDRESS4           => fetch_emp_rec.address4,
            P_SOURCE_CITY               => fetch_emp_rec.city,
            P_SOURCE_POSTAL_CODE        => fetch_emp_rec.postal_code,
            P_SOURCE_STATE              => fetch_emp_rec.state,
            P_SOURCE_PROVINCE           => fetch_emp_rec.province,
            P_SOURCE_COUNTY             => fetch_emp_rec.county,
            P_SOURCE_COUNTRY            => fetch_emp_rec.country,
            P_SOURCE_MGR_ID             => fetch_emp_rec.mgr_id,
            P_SOURCE_MGR_NAME           => fetch_emp_rec.mgr_name,
            P_SOURCE_BUSINESS_GRP_ID    => fetch_emp_rec.org_id,
            P_SOURCE_BUSINESS_GRP_NAME  => fetch_emp_rec.org_name,
            P_SOURCE_FIRST_NAME         => fetch_emp_rec.first_name,
            P_SOURCE_LAST_NAME          => fetch_emp_rec.last_name,
            P_SOURCE_MIDDLE_NAME        => fetch_emp_rec.middle_name,
            P_SOURCE_CATEGORY           => null,
            P_SOURCE_STATUS             => null,
            P_SOURCE_OFFICE             => fetch_emp_rec.office,
            P_SOURCE_LOCATION           => fetch_emp_rec.location,
            P_SOURCE_MAILSTOP           => fetch_emp_rec.mailstop,
            P_USER_NAME                 => l_user_name
        );

        -- dbms_output.put_line('name '||fetch_emp_rec.full_name);
        IF ( l_return_status <> fnd_api.g_ret_sts_success) THEN

          fnd_message.set_name('JTF', 'JTF_RS_CONC_CREATE_EMP_ERR');
          fnd_message.set_token('P_EMPLOYEE_NAME', fetch_emp_rec.full_name);
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          FOR i IN 1..l_msg_count
          LOOP
             fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                            p_encoded => fnd_api.g_false)));
          END LOOP;
          fnd_msg_pub.delete_msg;
          fnd_file.new_line(fnd_file.log,1);
          raise fnd_api.g_exc_error;
        END IF;

        -- Code added by repuri (04/09/03) for Enh/Bug # 2828368

        l_organization_id := NULL;
        l_salesrep_extsts := 'N';

        IF (P_CREATE_SRP = 'Y') THEN
          OPEN op_units_cur(fetch_emp_rec.org_id,l_org_id);
          FETCH op_units_cur INTO l_organization_id;
          IF op_units_cur%FOUND THEN

          l_salesperson_number := NULL;
          IF (l_prof_srp_num = 'EMPLOYEE_NUMBER') THEN
            l_salesperson_number := l_source_number;
          ELSIF (l_prof_srp_num = 'SEQUENCE_GENERATED') THEN
            LOOP
              SELECT jtf_rs_salesrep_number_s.nextval
              INTO l_salesperson_number
              FROM DUAL;

              OPEN c_salesrep_number(l_salesperson_number);
              FETCH c_salesrep_number INTO m_salesrep_id;
              EXIT WHEN c_salesrep_number%NOTFOUND;
              CLOSE c_salesrep_number;
            END LOOP;
            CLOSE c_salesrep_number;
          END IF;


          IF (l_salesperson_number IS NOT NULL AND l_sales_credit_type_id IS NOT NULL) THEN
            --Create a Salesperson for the Resource Created above
            JTF_RS_SALESREPS_PUB.CREATE_SALESREP (
              p_api_version                  => 1.0,
              p_init_msg_list                => fnd_api.g_true,
              p_commit                       => fnd_api.g_false,
              p_resource_id                  => l_resource_id,
              p_sales_credit_type_id         => l_sales_credit_type_id,
              p_salesrep_number              => l_salesperson_number,
              p_name                         => fetch_emp_rec.full_name,
              p_status                       => 'A',
               -- Enh 3947611 2-dec-2004:changed this date for future dated employees
              p_start_date_active            => l_active_emp_start_date, --trunc(sysdate),
              p_end_date_active              => null,
              p_org_id                       => l_org_id,
              p_gl_id_rev                    => null,
              p_gl_id_freight                => null,
              p_gl_id_rec                    => null,
              p_set_of_books_id              => null,
              p_email_address                => null,
              p_wh_update_date               => null,
              p_sales_tax_geocode            => null,
              p_sales_tax_inside_city_limits => null,
              x_return_status                => s_return_status,
              x_msg_count                    => s_msg_count,
              x_msg_data                     => s_msg_data,
              x_salesrep_id                  => l_salesrep_id
            );
            IF(s_return_status <> 'S') THEN
              fnd_message.set_name('JTF', 'JTF_RS_CP_SYN_EMP_CRT_SRP_ERR');
              fnd_message.set_token('P_EMPLOYEE_NAME', fetch_emp_rec.full_name);
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              FOR i IN 1..s_msg_count LOOP
                fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                                 p_encoded => fnd_api.g_false)));
              END LOOP;
              fnd_msg_pub.delete_msg;
              fnd_file.new_line(fnd_file.log,1);
              raise fnd_api.g_exc_error;
            END IF;
            l_salesrep_extsts := 'Y';
          END IF;
          END IF;
          CLOSE op_units_cur;

        END IF;
         /*added the below line to get the job assignment start date */
        /* Enh 3947611 2-dec-2004: using  new function for future dated*/
        /* also changed the value for p_start_date_active from sysdate to l_asg_start_date */
        l_asg_start_date := get_ftr_asg_start_date(fetch_emp_rec.job_id,fetch_emp_rec.person_id,fetch_emp_rec.assignment_id,l_assignment_type);

        FOR i IN c_job_roles(fetch_emp_rec.job_id) LOOP
          l_role_type_code := NULL;
          OPEN  c_get_role_type(i.role_id);
          FETCH c_get_role_type INTO l_role_type_code;
          CLOSE c_get_role_type;

          -- Check for Sales Comp Roles
          -- Will create the SALES_COMP roles only if the resource is a salesperson.
          if not (l_salesrep_extsts = 'N' and l_role_type_code = 'SALES_COMP') then

          JTF_RS_ROLE_RELATE_PVT.CREATE_RESOURCE_ROLE_RELATE(
            p_api_version         => 1.0,
            p_init_msg_list       => fnd_api.g_true,
            p_commit              => fnd_api.g_false,
            p_role_resource_type  => 'RS_INDIVIDUAL',
            p_role_resource_id    => l_resource_id,
            p_role_id             => i.role_id,
            p_start_date_active   => l_asg_start_date,
            x_return_status       => r_return_status,
            x_msg_count           => r_msg_count,
            x_msg_data            => r_msg_data,
            x_role_relate_id      => l_role_relate_id
          );
          IF ( r_return_status <> fnd_api.g_ret_sts_success) THEN
            l_role_name := NULL;
            OPEN c_role_name (i.role_id);
            FETCH c_role_name INTO l_role_name;
            CLOSE c_role_name;

            fnd_message.set_name('JTF', 'JTF_RS_CP_SYN_EMP_CRT_RES_ROLE');
            fnd_message.set_token('P_EMPLOYEE_NAME', fetch_emp_rec.full_name);
            fnd_message.set_token('P_ROLE_NAME',l_role_name);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            FOR i IN 1..r_msg_count LOOP
              fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                               p_encoded => fnd_api.g_false)));
            END LOOP;

            fnd_msg_pub.delete_msg;
            fnd_file.new_line(fnd_file.log,1);
            raise fnd_api.g_exc_error;
          END IF;
          end if; -- End of Check for Sales Comp Roles
        END LOOP;

        -- End Add Code for Enh

        l_count := l_count + 1;
        IF (l_count > 1000) THEN
          commit;
          l_count := 1;
        END IF;

      END IF;

    EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
        fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
        ROLLBACK TO create_resource_sp;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
        fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
        ROLLBACK TO create_resource_sp;
      WHEN OTHERS
      THEN
        fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
        ROLLBACK TO create_resource_sp;

    END;

   end if; -- End of business profile validation


   END LOOP; -- fetch employee cursor end


   FND_MSG_PUB.count_and_get (p_count => l_msg_count, p_data => l_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO CREATE_EMPLOYEE_SP;
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO CREATE_EMPLOYEE_SP;
    WHEN OTHERS
    THEN
      fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO CREATE_EMPLOYEE_SP;
      fnd_file.put_line(fnd_file.log, sqlerrm);

    END  create_employee;


  PROCEDURE  terminate_employee
  IS
   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'TERMINATE_EMPLOYEE';
   L_RETURN_STATUS       VARCHAR2(2);
   L_MSG_COUNT           NUMBER;
   L_MSG_DATA            VARCHAR2(2000);
   l_resource_id         NUMBER;

  CURSOR term_emp_cur (l_active_days IN NUMBER)
      IS
  SELECT rsc.resource_id
--       , rsc.resource_number
         , rsc.resource_name
         , rsc.source_id
         , rsc.object_version_number
--       , rsc.start_date_active
--       , rsc.end_date_active
   FROM  jtf_rs_resource_extns_vl rsc
  WHERE  rsc.category = 'EMPLOYEE'
   /* AND  not exists (select employee_id
                      from  per_employees_current_x emp
                     where  emp.employee_id = rsc.source_id
                      and   rsc.category    = 'EMPLOYEE')*/
/*
    AND   not exists (select ppl.person_id
                      from   per_all_people_f ppl,
                             per_all_assignments_f asg,
                             per_periods_of_service ser
                      where  ppl.person_id = rsc.source_id
--                        and  rsc.category  = 'EMPLOYEE'
                        and  trunc(sysdate) between ppl.effective_start_date and ppl.effective_end_date
                        and  ppl.employee_number is not null
                        and  ppl.person_id = asg.person_id
                        and  trunc(sysdate) between asg.effective_start_date and asg.effective_end_date
                        and  asg.primary_flag = 'Y'
                        and  asg.assignment_type = 'E'
                        and  asg.period_of_service_id = ser.period_of_service_id
                        and  (ser.actual_termination_date >= trunc(sysdate) or ser.actual_termination_date is NULL))
*/
    AND   not exists (select ppl.person_id
                      from   per_all_people_f ppl
                      where  ppl.person_id = rsc.source_id
                      --Enh 3947611 2-dec-2004: changed the date check so that  future dated employees are not terminated
                      --and    ( trunc(sysdate) between trunc(ppl.effective_start_date) and trunc(ppl.effective_end_date)
                       and    trunc(sysdate) <= trunc(ppl.effective_end_date )
                      and    (ppl.current_employee_flag = 'Y' OR ppl.current_npw_flag = 'Y'))
    AND  trunc( nvl(end_date_active, sysdate+l_active_days)) >= trunc(sysdate+l_active_days);

  -- Added this cursor (and related code)  for the Enh #2660474
  -- to get the actual termination date of an employee
  /* Added the last 2 lines in the cursor to fix bug # 3300436
     The first record from this query will give the correct record from per_periods_of_service
     if there are more records in this table. */
  CURSOR c_term_emp_date (l_person_id IN NUMBER) IS
    SELECT actual_termination_date
    FROM per_periods_of_service
    WHERE person_id = l_person_id
    AND trunc(date_start) <= trunc(sysdate)
    ORDER BY period_of_service_id desc;

  /* To get the actual termination date of a worker
     The first record from this query will give the correct record from per_periods_of_placement
     if there are more records in this table. */
--  CURSOR c_term_cwk_date (l_person_id IN NUMBER) IS
--    SELECT actual_termination_date
--    FROM per_periods_of_placement
--    WHERE person_id = l_person_id
--    AND trunc(date_start) <= trunc(sysdate)
--    ORDER BY period_of_placement_id desc;

   TYPE Getenddate IS REF CURSOR;
   get_enddate_date Getenddate;

   l_query          varchar2(300);

   l_table_not_found EXCEPTION;  --exception to handle table not found;
   PRAGMA EXCEPTION_INIT(l_table_not_found, -00942 );

   i          NUMBER;
   l_count    NUMBER;

   l_emp_end_date  DATE;
   l_cwk_end_date  DATE;
   l_date          DATE;
   l_active_days   NUMBER;

  BEGIN

     l_query        := 'SELECT actual_termination_date '||
    'FROM per_periods_of_placement ' ||
    'WHERE person_id = :b_person_id '||
    'AND trunc(date_start) <= trunc(sysdate) '||
    'ORDER BY period_of_placement_id desc';

     --Standard Start of API SAVEPOINT
     SAVEPOINT TERMINATE_EMPLOYEE_SP;

     l_return_status := fnd_api.g_ret_sts_success;
     l_count := 0;

     FND_PROFILE.GET('JTF_RS_RESOURCE_ACTIVE_DAYS',l_active_days);

     IF l_active_days IS NULL THEN
       l_active_days := 0;
     END IF;

     For term_emp_rec IN term_emp_cur (l_active_days)
     loop

        BEGIN

           SAVEPOINT TERMINATE_EMPLOYEE_IN_SP;

           l_return_status := fnd_api.g_ret_sts_success;

        -- Additional Code for the Enh #2660474
           IF term_emp_rec.source_id IS NOT NULL THEN

        -- Changed the logic to derive the end date. Person can be a Employee or CWK.
        -- Fix for bug # 3455951, 3072464
              OPEN c_term_emp_date (term_emp_rec.source_id);
              FETCH c_term_emp_date into l_emp_end_date;
                IF c_term_emp_date%NOTFOUND THEN
                  l_emp_end_date := NULL;
                END IF;
              CLOSE c_term_emp_date;

--              OPEN c_term_cwk_date (term_emp_rec.source_id);
--              FETCH c_term_cwk_date into l_cwk_end_date;
--                IF c_term_cwk_date%FOUND THEN
              begin
                 OPEN get_enddate_date FOR l_query USING term_emp_rec.source_id;
                 FETCH get_enddate_date into l_cwk_end_date;
                 IF get_enddate_date%FOUND THEN
                   IF l_emp_end_date IS NULL THEN
                     l_date := l_cwk_end_date;
                   ELSE -- This person was an Employee as well as CWK
                     IF l_cwk_end_date IS NULL THEN -- this is just to address if there is any bad data.
                       l_date := l_emp_end_date;
                     ELSE
                       l_date := greatest(l_emp_end_date,l_cwk_end_date);
                     END IF;
                   END IF;
                ELSE -- this shows the person was never a CWK.
                   l_date := l_emp_end_date;
                END IF;
--              CLOSE c_term_cwk_date;
              CLOSE get_enddate_date;
           exception
           when l_table_not_found then
              l_date := l_emp_end_date;
           end;

           END IF;

------------------------------------------------------------------------------
        -- We assume that per_periods_of_service will always have a value
        -- for termination_date column, if an employee is terminated.
        -- But for any bad data (if there is no value), we initialize it to sysdate

           IF l_date IS NULL THEN
             l_date := trunc(sysdate-1);
           END IF;

           jtf_rs_resource_utl_pub.end_date_employee
             (p_api_version         => 1.0
              , p_resource_id       => term_emp_rec.resource_id
              , p_end_date_active   => (l_date+l_active_days)
              , x_object_ver_number => term_emp_rec.object_version_number
              , x_return_status     => l_return_status
              , x_msg_count         => l_msg_count
              , x_msg_data          => l_msg_data);

           IF ( l_return_status <> fnd_api.g_ret_sts_success) THEN
              fnd_message.set_name('JTF', 'JTF_RS_CP_SYN_EMP_TER_RES');
              fnd_message.set_token('P_RESOURCE_NAME', term_emp_rec.resource_name);
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              FOR i IN 1..l_msg_count LOOP
                 fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                              p_encoded => fnd_api.g_false)));
              END LOOP;
              fnd_msg_pub.delete_msg;
              fnd_file.new_line(fnd_file.log,1);
              raise fnd_api.g_exc_error;
           END IF;

-------------------------------------------------------------------------------

           l_count := l_count + 1;
           if (l_count > 1000) then
             commit;
             l_count := 1;
           end if;

        EXCEPTION
        WHEN fnd_api.g_exc_error THEN
           fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
           ROLLBACK TO TERMINATE_EMPLOYEE_IN_SP;
        WHEN fnd_api.g_exc_unexpected_error THEN
           fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
           ROLLBACK TO TERMINATE_EMPLOYEE_IN_SP;
        WHEN OTHERS THEN
           fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
           ROLLBACK TO TERMINATE_EMPLOYEE_IN_SP;
        END;

     end loop; -- end of term_emp_cur

  FND_MSG_PUB.count_and_get (p_count => l_msg_count, p_data => l_msg_data);

  EXCEPTION
     WHEN fnd_api.g_exc_error
     THEN
        fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
        ROLLBACK TO TERMINATE_EMPLOYEE_SP;
  WHEN OTHERS
     THEN
        fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
        ROLLBACK TO TERMINATE_EMPLOYEE_SP;
--        fnd_file.put_line(fnd_file.log, sqlerrm);

  END terminate_employee;


 PROCEDURE  update_employee
                 (P_OVERWRITE_NAME   IN  VARCHAR2 )
   IS
   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_EMPLOYEE';
   l_return_status       VARCHAR2(2);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
  /* Moved the initial assignment of below variable to inside begin */
   l_sysdate             date;

-------------------------------------------------------------

   CURSOR c_resource IS
   SELECT resource_id,
  	  source_id,
          source_number,
          source_job_id,
          start_date_active,
          end_date_active
   FROM   jtf_rs_resource_extns
   WHERE  category = 'EMPLOYEE';

   CURSOR c_check_rehire_rev_emp(p_person_id IN NUMBER) IS
   SELECT 'Y'
   FROM   jtf_rs_resource_extns rsc
   WHERE  rsc.category = 'EMPLOYEE'
   AND    rsc.source_id = p_person_id
   AND    l_sysdate not between trunc(rsc.start_date_active) and trunc(nvl(rsc.end_date_active,sysdate))
--   AND    exists ( select cur.employee_id from PER_EMPLOYEES_CURRENT_X cur where cur.employee_id = rsc.source_id);
   AND    exists ( select ppl.person_id
                   from   per_all_people_f ppl
                   where  ppl.person_id = p_person_id
                   and    trunc(sysdate) between ppl.effective_start_date and ppl.effective_end_date
                   and    (ppl.current_employee_flag = 'Y' OR ppl.current_npw_flag = 'Y'));

   CURSOR c_salesreps (c_resource_id jtf_rs_resource_extns.resource_id%TYPE) IS
   SELECT salesrep_id
   FROM   jtf_rs_salesreps
   WHERE  resource_id = c_resource_id;

   l_salesreps_rec c_salesreps%ROWTYPE;

   CURSOR c_ppf(p_person_id IN NUMBER) IS
   SELECT employee_number,
	  full_name,
          known_as,
 	  first_name,
	  middle_names,
	  last_name,
	  email_address,
	  business_group_id,
	  office_number,
	  internal_location,
	  mailstop,
          npw_number,
          party_id,
          current_employee_flag,
          current_npw_flag
   FROM   per_all_people_f
   WHERE  person_id = p_person_id
     and  g_run_date between effective_start_date and effective_end_date;

   l_ppf_rec c_ppf%ROWTYPE;
   l_source_number       jtf_rs_resource_extns.source_number%TYPE;
   l_assignment_type     per_all_assignments_f.assignment_type%TYPE;

   CURSOR c_org(p_org_id IN NUMBER) IS
   SELECT name
   FROM   hr_all_organization_units
   WHERE  organization_id = p_org_id;

   CURSOR c_asg(p_person_id IN NUMBER) IS
   SELECT supervisor_id,
          location_id,
          job_id,
          assignment_id
   FROM   per_all_assignments_f
   WHERE  person_id = p_person_id
   AND    primary_flag = 'Y'
--   AND    assignment_type = 'E'
   AND    assignment_type in ('E','C')
   AND    g_run_date between effective_start_date and effective_end_date;

   l_asg_rec c_asg%ROWTYPE;

   CURSOR c_job(p_job_id IN NUMBER) IS
   SELECT name
   FROM   per_jobs
   WHERE  job_id = p_job_id;

   CURSOR c_loc(p_loc_id IN NUMBER) IS
   SELECT address_line_1,
          address_line_2,
          address_line_3,
          town_or_city,
          country,
          postal_code
   FROM   hr_locations
   WHERE  location_id = p_loc_id;

   l_loc_rec c_loc%ROWTYPE;

   CURSOR c_mgr(p_person_id IN NUMBER) IS
   SELECT full_name
   FROM   per_all_people_f
   WHERE  person_id = p_person_id
     and  g_run_date between effective_start_date and effective_end_date;

   CURSOR c_phone(p_person_id IN NUMBER) IS
   SELECT phone_number
   FROM   per_phones
   WHERE  parent_table = 'PER_ALL_PEOPLE_F'
   AND    parent_id    = p_person_id
   AND    phone_type = 'W1'
   AND    g_run_date between date_from and nvl(date_to, to_date('31/12/4712', 'DD/MM/YYYY'));


   CURSOR c_mobile_phone(p_person_id IN NUMBER) IS
   SELECT phone_number
   FROM   per_phones
   WHERE  parent_table = 'PER_ALL_PEOPLE_F'
   AND    parent_id    = p_person_id
   AND    phone_type = 'M'
   AND    g_run_date between date_from and nvl(date_to, to_date('31/12/4712', 'DD/MM/YYYY'));

   CURSOR c_pager(p_person_id IN NUMBER) IS
   SELECT phone_number
   FROM   per_phones
   WHERE  parent_table = 'PER_ALL_PEOPLE_F'
   AND    parent_id    = p_person_id
   AND    phone_type = 'P'
   AND    g_run_date between date_from and nvl(date_to, to_date('31/12/4712', 'DD/MM/YYYY'));

    --Mugsrin
    --ER # 2669284.  This cursor selects old values from jtf_rs_resource_extns table.
    --Then old values are compared with new values to find out
    --whether a row has to be updated and also to insert null for unmodified columns.
    CURSOR rr_old_cur(l_resource_id JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE)
        IS
    SELECT
            source_number,
            source_name,
            source_first_name,
            source_middle_name,
            source_last_name,
            source_phone,
            source_email,
            source_job_id,
            source_job_title,
            address_id,
            source_address1,
            source_address2,
            source_address3,
            source_city,
            source_country,
            source_postal_code,
            source_mgr_id,
            source_mgr_name,
            source_business_grp_id,
            source_business_grp_name,
            source_office,
            source_location,
            source_mailstop,
            source_mobile_phone,
            source_pager,
            resource_name,
            end_date_active,
            person_party_id
     FROM  jtf_rs_resource_extns_vl
     WHERE  resource_id = l_resource_id;

    rr_old_rec    rr_old_cur%rowtype;

    --ER # 2669284. Resource old values
    l_source_number_o           jtf_rs_resource_extns.source_number%type;
    l_source_name_o             jtf_rs_resource_extns.source_name%type;
    l_source_first_name_o       jtf_rs_resource_extns.source_first_name%type;
    l_source_middle_name_o      jtf_rs_resource_extns.source_middle_name%type;
    l_source_last_name_o        jtf_rs_resource_extns.source_last_name%type;
    l_source_phone_o            jtf_rs_resource_extns.source_phone%type;
    l_source_email_o            jtf_rs_resource_extns.source_email%type;
    l_source_job_id_o           jtf_rs_resource_extns.source_job_id%type;
    l_source_job_title_o        jtf_rs_resource_extns.source_job_title%type;
    l_address_id_o              jtf_rs_resource_extns.address_id%type  ;
    l_source_address1_o         jtf_rs_resource_extns.source_address1%type;
    l_source_address2_o         jtf_rs_resource_extns.source_address2%type;
    l_source_address3_o         jtf_rs_resource_extns.source_address3%type;
    l_source_city_o             jtf_rs_resource_extns.source_city%type;
    l_source_country_o          jtf_rs_resource_extns.source_country%type;
    l_source_postal_code_o      jtf_rs_resource_extns.source_postal_code%type;
    l_source_mgr_id_o           jtf_rs_resource_extns.source_mgr_id%type;
    l_source_mgr_name_o         jtf_rs_resource_extns.source_mgr_name%type;
    l_source_business_grp_id_o  jtf_rs_resource_extns.source_business_grp_id%type;
    l_source_business_grp_name_o jtf_rs_resource_extns.source_business_grp_name%type;
    l_source_office_o            jtf_rs_resource_extns.source_office%type;
    l_source_location_o          jtf_rs_resource_extns.source_location%type;
    l_source_mailstop_o          jtf_rs_resource_extns.source_mailstop%type;
    l_source_mobile_phone_o      jtf_rs_resource_extns.source_mobile_phone%type;
    l_source_pager_o             jtf_rs_resource_extns.source_pager%type;
    l_resource_name_o            jtf_rs_resource_extns_vl.resource_name%type;
    l_end_date_active_o          jtf_rs_resource_extns_vl.end_date_active%type;
    l_party_id_o                 jtf_rs_resource_extns_vl.person_party_id%type;

    --ER # 2669284. Resource new values
    l_source_number_n               jtf_rs_resource_extns.source_number%type;
    l_source_name_n                 jtf_rs_resource_extns.source_name%type;
    l_source_first_name_n           jtf_rs_resource_extns.source_first_name%type;
    l_source_middle_name_n          jtf_rs_resource_extns.source_middle_name%type;
    l_source_last_name_n            jtf_rs_resource_extns.source_last_name%type;
    l_source_phone_n                jtf_rs_resource_extns.source_phone%type;
    l_source_email_n                jtf_rs_resource_extns.source_email%type;
    l_source_job_id_n               jtf_rs_resource_extns.source_job_id%type;
    l_source_job_title_n            jtf_rs_resource_extns.source_job_title%type;
    l_address_id_n                  jtf_rs_resource_extns.address_id%type  ;
    l_source_address1_n             jtf_rs_resource_extns.source_address1%type;
    l_source_address2_n             jtf_rs_resource_extns.source_address2%type;
    l_source_address3_n             jtf_rs_resource_extns.source_address3%type;
    l_source_city_n                 jtf_rs_resource_extns.source_city%type;
    l_source_country_n              jtf_rs_resource_extns.source_country%type;
    l_source_postal_code_n          jtf_rs_resource_extns.source_postal_code%type;
    l_source_mgr_id_n               jtf_rs_resource_extns.source_mgr_id%type;
    l_source_mgr_name_n             jtf_rs_resource_extns.source_mgr_name%type;
    l_source_business_grp_id_n      jtf_rs_resource_extns.source_business_grp_id%type;
    l_source_business_grp_name_n    jtf_rs_resource_extns.source_business_grp_name%type;
    l_source_office_n               jtf_rs_resource_extns.source_office%type;
    l_source_location_n             jtf_rs_resource_extns.source_location%type;
    l_source_mailstop_n             jtf_rs_resource_extns.source_mailstop%type;
    l_source_mobile_phone_n         jtf_rs_resource_extns.source_mobile_phone%type;
    l_source_pager_n                jtf_rs_resource_extns.source_pager%type;
    l_resource_name_n               jtf_rs_resource_extns_vl.resource_name%type;
    l_end_date_active_n             jtf_rs_resource_extns_vl.end_date_active%type;
    l_party_id_n                    jtf_rs_resource_extns_vl.person_party_id%type;

    l_resource_extn_aud_id jtf_rs_resource_extn_aud.resource_audit_id%type;
    l_row_id        varchar2(24) := null;
  /* Moved the initial assignment of below variables to inside begin */
    l_is_to_be_updated varchar2(1);
    l_update_extn varchar2(1);
    l_rehire_rev_emp_flag varchar2(1);
    l_activate_salesreps varchar2(1);

   l_phone          VARCHAR2(240);
   l_mobile_phone   VARCHAR2(240);
   l_pager          VARCHAR2(240);
   l_mgr_name       VARCHAR2(240);
   l_job_name       VARCHAR2(240);
   l_org_name       VARCHAR2(240);
   l_end_date_active jtf_rs_resource_extns_vl.end_date_active%type;
--   l_sysdate        DATE   := SYSDATE;
  /* Moved the initial assignment of below variables to inside begin */
   l_user_id        NUMBER;
   l_login          NUMBER;

   l_job_id         NUMBER;
   l_party_id       NUMBER;
--   l_role_relate_id NUMBER;
   l_role_name      jtf_rs_roles_vl.role_name%TYPE;
   l_role_id        NUMBER;

   l_new_job_title         VARCHAR2(240);
   l_new_job_id            NUMBER;
   l_new_job_assignment_id NUMBER;
   l_active_days   NUMBER;

   r_return_status  VARCHAR2(2);
   r_msg_count      NUMBER;
   r_msg_data       VARCHAR2(2000);

   l_derived_job_id NUMBER;

   CURSOR c_derive_job_id (l_job_name VARCHAR2, l_business_group_id NUMBER) IS
     SELECT job_id
     FROM   per_jobs
     WHERE  NAME = l_job_name
     AND    business_group_id = l_business_group_id;

   PROCEDURE  update_job_roles
   (p_old_job_id              IN  NUMBER,
    p_new_job_title           IN  VARCHAR2,
    p_new_job_id              IN  NUMBER,
    p_new_job_assignment_id   IN  NUMBER,
    p_person_id               IN  NUMBER,
    p_resource_id             IN  NUMBER,
    p_assignment_type         IN  VARCHAR2
   )
   IS

   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_JOB_ROLES';
   l_return_status       VARCHAR2(2);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
--   l_old_job_id          NUMBER;
   l_role_relate_id      NUMBER;
--   l_sysdate             date  := trunc(sysdate);

   l_g_miss_date         date;

   CURSOR c_job_roles (l_job_id IN NUMBER) IS
   SELECT role_id
   FROM   jtf_rs_job_roles
   WHERE  job_id = l_job_id;

   l_job_roles_rec c_job_roles%ROWTYPE;

   -- Added the below cursor to get the role type for a role id.
   CURSOR c_get_role_type (l_role_id jtf_rs_roles_vl.role_id%TYPE) IS
     SELECT role_type_code
     FROM jtf_rs_roles_b
     WHERE role_id = l_role_id;

   l_role_type_code jtf_rs_roles_b.role_type_code%TYPE;

   -- Added the below cursor to check the salesrep exists for the resource_id. If the salesrep does not esists
   -- we will not create the sales compensation roles.

   -- removed the code to check the org_id condition.
   -- As per bug # 4391220, JTF_RS_ROLE_RELATE_VUHK has been changed to be MOAC compliant
   -- The new validation check that a Resource it associated with at least one
   -- Salesrep record in JTF_RS_SALESREPS.
   CURSOR c_salesrep_check(c_resource_id number) IS
   select 'Y'
   from   jtf_rs_salesreps
   where  resource_id  = c_resource_id;
--   and    nvl(org_id,-99) = nvl(c_org_id,-99);

   l_salesrep_extsts varchar2(2);
--   l_org_id          number;

--  CURSOR c_job_id (l_job_name IN per_jobs.name%TYPE) IS
--   SELECT job_id
--   FROM   per_jobs
--   WHERE  name = l_job_name;

   CURSOR c_job_role_relations (l_role_id IN NUMBER, l_resource_id IN NUMBER) IS
   SELECT rr.role_relate_id, rr.object_version_number
   FROM   jtf_rs_role_relations rr
   WHERE  rr.role_resource_type = 'RS_INDIVIDUAL'
   AND    rr.role_resource_id   = l_resource_id
   AND    rr.role_id            = l_role_id
   AND    nvl(rr.delete_flag,'N') <> 'Y'
   AND    g_run_date between trunc(start_date_active) and trunc(nvl(end_date_active,g_run_date));

   l_job_role_relations_rec c_job_role_relations%ROWTYPE;

   /* The below cursor will get all the roles that has an end_date greater than or equal to the start date passed
      and also the role exists in job roles table. Bug # 3300409 */

   CURSOR c_res_roles_enddate (l_resource_id IN NUMBER, l_new_role_st_dt DATE) IS
   SELECT rr.role_relate_id, rr.object_version_number, rr.role_id
   FROM   jtf_rs_role_relations rr
   WHERE  exists (select null
                  from jtf_rs_job_roles jr
                  where jr.role_id = rr.role_id
                  and    jr.job_id not in (nvl(p_old_job_id,-99)))
   AND    rr.role_resource_type = 'RS_INDIVIDUAL'
   AND    rr.role_resource_id   = l_resource_id
   AND    nvl(rr.delete_flag,'N') <> 'Y'
   AND    trunc(nvl(end_date_active,g_run_date)) >= trunc(l_new_role_st_dt);

   CURSOR c_role_name (l_role_id IN jtf_rs_roles_vl.role_id%TYPE) IS
   SELECT role_name
   FROM   jtf_rs_roles_vl
   WHERE  role_id = l_role_id;

   CURSOR c_get_assignment_id(p_job_id IN NUMBER, p_person_id IN NUMBER) IS
   SELECT  assignment_id
   FROM   PER_ALL_ASSIGNMENTS_F
   WHERE  job_id = p_job_id
   AND    primary_flag = 'Y'
--   AND    assignment_type = 'E'
   AND    assignment_type = p_assignment_type
   AND    person_id = p_person_id
   ORDER BY assignment_id desc;

   l_asg_start_date date;
   l_asg_end_date   date;
   l_asg_new_end_date date;
   l_assignment_id  number;
  /* Moved the initial assignment of below variable to inside begin */
   l_res_roles_enddated varchar2(1);

   BEGIN

     l_g_miss_date        := trunc(to_date('31-12-4712','DD-MM-YYYY'));
     l_res_roles_enddated := 'N';
--      l_old_job_id := NULL;

      -- To get the current operating unit. if l_org_id is NULL, then it is a single org
--      select to_number(decode(substrb(userenv('CLIENT_INFO'),1,1),' ',null,substrb(userenv('CLIENT_INFO'),1,10)))
--      into   l_org_id
--      from   dual;

      l_salesrep_extsts := 'N';
--      if l_org_id is NOT NULL then
         OPEN  c_salesrep_check(p_resource_id);
         FETCH c_salesrep_check INTO l_salesrep_extsts;
         CLOSE c_salesrep_check;
--      end if;

      IF (NVL (p_new_job_id, -99) <> NVL (p_old_job_id, -99)) THEN /*Job changed*/
--      IF (NVL (p_new_job_title, 'jobnamenullerror') <> NVL (p_old_job_title, 'jobnamenullerror')) THEN /*Job changed*/
     --         IF l_job_name is NULL then /* Value to null */

         OPEN c_job_roles(p_new_job_id);
         FETCH c_job_roles INTO l_job_roles_rec;
         IF c_job_roles%FOUND THEN
            l_asg_start_date := get_asg_start_date(p_new_job_id,p_person_id,p_new_job_assignment_id,p_assignment_type);
         ELSE
            l_asg_start_date := NULL;
         END IF;
         CLOSE c_job_roles;

--         OPEN c_job_id(p_old_job_title);
--         FETCH c_job_id INTO l_old_job_id;
--         IF c_job_id%FOUND THEN

            OPEN c_job_roles(p_old_job_id);
            FETCH c_job_roles INTO l_job_roles_rec;
            IF c_job_roles%FOUND THEN

               OPEN c_get_assignment_id(p_old_job_id,p_person_id);
               FETCH c_get_assignment_id INTO l_assignment_id;
               CLOSE c_get_assignment_id;


               l_asg_end_date := get_asg_end_date(p_old_job_id,p_person_id,l_assignment_id,p_assignment_type) + l_active_days;

               IF (l_asg_start_date is NOT NULL AND l_asg_start_date <= l_asg_end_date) then
                  -- l_asg_start_date is not null implies there is a new job that has a job role mapping.
                  --  So This code will get executed only if the old job end date + profile overlaps with new job's start date
                  l_asg_end_date := l_asg_start_date - 1;
               END IF;

               LOOP
                  OPEN c_job_role_relations(l_job_roles_rec.role_id, p_resource_id);
                  FETCH c_job_role_relations INTO l_job_role_relations_rec;
                  IF c_job_role_relations%FOUND THEN
                     JTF_RS_ROLE_RELATE_PVT.UPDATE_RESOURCE_ROLE_RELATE(
                                            p_api_version         => 1.0,
                                            p_init_msg_list       => fnd_api.g_true,
                                            p_commit              => fnd_api.g_false,
                                            p_role_relate_id      => l_job_role_relations_rec.role_relate_id,
                                            p_end_date_active     => l_asg_end_date,
                                            p_object_version_num  => l_job_role_relations_rec.object_version_number,
                                            x_return_status       => r_return_status,
                                            x_msg_count           => r_msg_count,
                                            x_msg_data            => r_msg_data
                                            );
                     IF ( r_return_status <> fnd_api.g_ret_sts_success) THEN
                        l_role_name := NULL;
                        OPEN c_role_name (l_job_roles_rec.role_id);
                        FETCH c_role_name INTO l_role_name;
                        CLOSE c_role_name;
                        fnd_message.set_name('JTF', 'JTF_RS_CP_SYN_EMP_UPD_ROL_ERR');
                        fnd_message.set_token('P_EMPLOYEE_NAME', l_ppf_rec.full_name);
                        fnd_message.set_token('P_JOB_TITLE', p_new_job_title);
                        fnd_message.set_token('P_ROLE_NAME', l_role_name);
                        fnd_file.put_line(fnd_file.log, fnd_message.get);
                        for i in 1..r_msg_count loop
                           fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,p_encoded => fnd_api.g_false)));
                        end loop;
                        CLOSE c_job_roles;
--                        CLOSE c_job_id;
                        fnd_msg_pub.delete_msg;
                        fnd_file.new_line(fnd_file.log,1);
                        raise fnd_api.g_exc_error;
                     END IF;
                  END IF;
                  CLOSE c_job_role_relations;
                  FETCH c_job_roles INTO l_job_roles_rec;
                  EXIT WHEN c_job_roles%NOTFOUND;
               END LOOP;
            END IF;
            CLOSE c_job_roles;
--         END IF;
--         CLOSE c_job_id;
      --           ELSIF p_old_job_title is NULL then /* null to value */

         OPEN c_job_roles(p_new_job_id);
         FETCH c_job_roles INTO l_job_roles_rec;
         IF c_job_roles%FOUND THEN

            /* l_asg_start_date is already derived above */
--            l_asg_start_date := get_asg_start_date(p_new_job_id,p_person_id,p_new_job_assignment_id,p_assignment_type);
            l_res_roles_enddated := 'N'; /* Initializing the flag to N for every resource. */

            LOOP
               OPEN c_job_role_relations(l_job_roles_rec.role_id,p_resource_id);
               FETCH c_job_role_relations INTO l_job_role_relations_rec;
               IF c_job_role_relations%NOTFOUND THEN /* no active resource role */

                  /* Below IF loop is added to Fix bug # 3300409 */
                  /* This loop will execute only once for a particular resource */
                  IF l_res_roles_enddated = 'N' THEN
                     /* This cursor will get all the roles that has an end_date greater than or equal to the start date
                        of the new role needs to be created */
                     FOR i in c_res_roles_enddate(p_resource_id,l_asg_start_date) LOOP
                        JTF_RS_ROLE_RELATE_PVT.UPDATE_RESOURCE_ROLE_RELATE(
                                            p_api_version         => 1.0,
                                            p_init_msg_list       => fnd_api.g_true,
                                            p_commit              => fnd_api.g_false,
                                            p_role_relate_id      => i.role_relate_id,
                                            p_end_date_active     => l_asg_start_date-1,
                                            p_object_version_num  => i.object_version_number,
                                            x_return_status       => r_return_status,
                                            x_msg_count           => r_msg_count,
                                            x_msg_data            => r_msg_data
                                            );
                        IF ( r_return_status <> fnd_api.g_ret_sts_success) THEN
                           l_role_name := NULL;
                           OPEN c_role_name (i.role_id);
                           FETCH c_role_name INTO l_role_name;
                           CLOSE c_role_name;
                           fnd_message.set_name('JTF', 'JTF_RS_CP_SYN_EMP_UPD_ROL_ERR');
                           fnd_message.set_token('P_EMPLOYEE_NAME', l_ppf_rec.full_name);
                           fnd_message.set_token('P_JOB_TITLE', p_new_job_title);
                           fnd_message.set_token('P_ROLE_NAME', l_role_name);
                           fnd_file.put_line(fnd_file.log, fnd_message.get);
                           for j in 1..r_msg_count loop
                              fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(j,p_encoded => fnd_api.g_false)));
                           end loop;
                           fnd_msg_pub.delete_msg;
                           fnd_file.new_line(fnd_file.log,1);
                           raise fnd_api.g_exc_error;
                        END IF;
                     END LOOP;
                     l_res_roles_enddated := 'Y';
                  END IF;
                  /* End of fix for bug # 3300409 */

                  -- Below cursor will retrive the role_type_code for a role id
                  l_role_type_code := NULL;
                  OPEN  c_get_role_type(l_job_roles_rec.role_id);
                  FETCH c_get_role_type INTO l_role_type_code;
                  CLOSE c_get_role_type;

                  -- Check for Sales Comp Roles and salesrep exists
                  -- Will create the SALES_COMP roles only if the resource is a salesperson.
                  if not (l_salesrep_extsts = 'N' and l_role_type_code = 'SALES_COMP') then

                  -- To get the end date of the new job
                  l_asg_new_end_date := get_asg_end_date(p_new_job_id,p_person_id,p_new_job_assignment_id,p_assignment_type);

                  -- If the end date of the new job is g_miss_date, replace the date with NULL.
                  -- Else add profile dayes to the end date
                  if (l_asg_new_end_date = l_g_miss_date) then
                     l_asg_new_end_date := NULL;
                  else
                     l_asg_new_end_date := l_asg_new_end_date + l_active_days;
                  end if;

                  JTF_RS_ROLE_RELATE_PVT.CREATE_RESOURCE_ROLE_RELATE(
                                  p_api_version         => 1.0,
                                  p_init_msg_list       => fnd_api.g_true,
                                  p_commit              => fnd_api.g_false,
                                  p_role_resource_type  => 'RS_INDIVIDUAL',
                                  p_role_resource_id    => p_resource_id,
                                  p_role_id             => l_job_roles_rec.role_id,
                                  p_start_date_active   => l_asg_start_date,
                                  p_end_date_active     => l_asg_new_end_date,
                                  x_return_status       => r_return_status,
                                  x_msg_count           => r_msg_count,
                                  x_msg_data            => r_msg_data,
                                  x_role_relate_id      => l_role_relate_id
                                  );
                  IF ( r_return_status <> fnd_api.g_ret_sts_success) THEN
                     l_role_name := NULL;
                     OPEN c_role_name (l_job_roles_rec.role_id);
                     FETCH c_role_name INTO l_role_name;
                     CLOSE c_role_name;
                     fnd_message.set_name('JTF', 'JTF_RS_CP_SYN_EMP_CRT_ROL_ERR');
                     fnd_message.set_token('P_EMPLOYEE_NAME', l_ppf_rec.full_name);
                     fnd_message.set_token('P_JOB_TITLE', p_new_job_title);
                     fnd_message.set_token('P_ROLE_NAME', l_role_name);
                     fnd_file.put_line(fnd_file.log, fnd_message.get);
                     for i in 1..r_msg_count loop
                        fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,p_encoded => fnd_api.g_false)));
                     end loop;
                     fnd_msg_pub.delete_msg;
                     fnd_file.new_line(fnd_file.log,1);
                     raise fnd_api.g_exc_error;
                  END IF;
                  end if; -- Check for Sales Comp Roles and salesrep exists
               END IF;
               CLOSE c_job_role_relations;
               FETCH c_job_roles INTO l_job_roles_rec;
               EXIT WHEN c_job_roles%NOTFOUND;
            END LOOP;
         END IF;
         CLOSE c_job_roles;
      ELSE  /*Job not changed*/

         OPEN c_job_roles(p_new_job_id);
         FETCH c_job_roles INTO l_job_roles_rec;
         IF c_job_roles%FOUND THEN /* all the roles from job roles */

            l_asg_start_date := get_asg_start_date(p_new_job_id,p_person_id,p_new_job_assignment_id,p_assignment_type);
            l_res_roles_enddated := 'N'; /* Initializing the flag to N for every resource. */

            LOOP
               OPEN c_job_role_relations(l_job_roles_rec.role_id,p_resource_id);
               FETCH c_job_role_relations INTO l_job_role_relations_rec;
               IF c_job_role_relations%NOTFOUND THEN /* no active resource role */

                  /* Below IF loop is added to Fix bug # 3300409 */
                  /* This loop will execute only once for a particular resource */
                  IF l_res_roles_enddated = 'N' THEN
                     /* This cursor will get all the roles that has an end_date greater than or equal to the start date
                        of the new role needs to be created */
                     FOR i in c_res_roles_enddate(p_resource_id,l_asg_start_date) LOOP
                        JTF_RS_ROLE_RELATE_PVT.UPDATE_RESOURCE_ROLE_RELATE(
                                            p_api_version         => 1.0,
                                            p_init_msg_list       => fnd_api.g_true,
                                            p_commit              => fnd_api.g_false,
                                            p_role_relate_id      => i.role_relate_id,
                                            p_end_date_active     => l_asg_start_date-1,
                                            p_object_version_num  => i.object_version_number,
                                            x_return_status       => r_return_status,
                                            x_msg_count           => r_msg_count,
                                            x_msg_data            => r_msg_data
                                            );
                        IF ( r_return_status <> fnd_api.g_ret_sts_success) THEN
                           l_role_name := NULL;
                           OPEN c_role_name (i.role_id);
                           FETCH c_role_name INTO l_role_name;
                           CLOSE c_role_name;
                           fnd_message.set_name('JTF', 'JTF_RS_CP_SYN_EMP_UPD_ROL_ERR');
                           fnd_message.set_token('P_EMPLOYEE_NAME', l_ppf_rec.full_name);
                           fnd_message.set_token('P_JOB_TITLE', p_new_job_title);
                           fnd_message.set_token('P_ROLE_NAME', l_role_name);
                           fnd_file.put_line(fnd_file.log, fnd_message.get);
                           for j in 1..r_msg_count loop
                              fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(j,p_encoded => fnd_api.g_false)));
                           end loop;
                           fnd_msg_pub.delete_msg;
                           fnd_file.new_line(fnd_file.log,1);
                           raise fnd_api.g_exc_error;
                        END IF;
                     END LOOP;
                     l_res_roles_enddated := 'Y';
                  END IF;
                  /* End of fix for bug # 3300409*/

                  -- Below cursor will retrive the role_type_code for a role id
                  l_role_type_code := NULL;
                  OPEN  c_get_role_type(l_job_roles_rec.role_id);
                  FETCH c_get_role_type INTO l_role_type_code;
                  CLOSE c_get_role_type;

                  -- Check for Sales Comp Roles and salesrep exists
                  -- Will create the SALES_COMP roles only if the resource is a salesperson.
                  if not (l_salesrep_extsts = 'N' and l_role_type_code = 'SALES_COMP') then

                  -- To get the end date of the new job
                  l_asg_new_end_date := get_asg_end_date(p_new_job_id,p_person_id,p_new_job_assignment_id,p_assignment_type);

                  -- If the end date of the new job is g_miss_date, replace the date with NULL.
                  -- Else add profile dayes to the end date
                  if (l_asg_new_end_date = l_g_miss_date) then
                     l_asg_new_end_date := NULL;
                  else
                     l_asg_new_end_date := l_asg_new_end_date + l_active_days;
                  end if;

                  JTF_RS_ROLE_RELATE_PVT.CREATE_RESOURCE_ROLE_RELATE(
                                  p_api_version         => 1.0,
                                  p_init_msg_list       => fnd_api.g_true,
                                  p_commit              => fnd_api.g_false,
                                  p_role_resource_type  => 'RS_INDIVIDUAL',
                                  p_role_resource_id    => p_resource_id,
                                  p_role_id             => l_job_roles_rec.role_id,
                                  p_start_date_active   => l_asg_start_date,
                                  p_end_date_active     => l_asg_new_end_date,
                                  x_return_status       => r_return_status,
                                  x_msg_count           => r_msg_count,
                                  x_msg_data            => r_msg_data,
                                  x_role_relate_id      => l_role_relate_id
                                  );
                  IF ( r_return_status <> fnd_api.g_ret_sts_success) THEN
                     l_role_name := NULL;
                     OPEN c_role_name (l_job_roles_rec.role_id);
                     FETCH c_role_name INTO l_role_name;
                     CLOSE c_role_name;
                     fnd_message.set_name('JTF', 'JTF_RS_CP_SYN_EMP_CRT_ROL_ERR');
                     fnd_message.set_token('P_EMPLOYEE_NAME', l_ppf_rec.full_name);
                     fnd_message.set_token('P_JOB_TITLE', p_new_job_title);
                     fnd_message.set_token('P_ROLE_NAME', l_role_name);
                     fnd_file.put_line(fnd_file.log, fnd_message.get);
                     for i in 1..r_msg_count loop
                        fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,p_encoded => fnd_api.g_false)));
                     end loop;
                     fnd_msg_pub.delete_msg;
                     fnd_file.new_line(fnd_file.log,1);
                     raise fnd_api.g_exc_error;
                  END IF;
                  end if;  -- Check for Sales Comp Roles and salesrep exists
               END IF; /* no active resource role */
               CLOSE c_job_role_relations;
               FETCH c_job_roles INTO l_job_roles_rec;
               EXIT WHEN c_job_roles%NOTFOUND;
            END LOOP; /* all the roles from job roles */
         END IF;
         CLOSE c_job_roles;
      END IF;  /*Job changed*/

      IF c_job_roles%ISOPEN THEN
         CLOSE c_job_roles;
      END IF;

--      IF c_job_id%ISOPEN THEN
--        CLOSE c_job_id;
--      END IF;

      IF c_job_role_relations%ISOPEN THEN
        CLOSE c_job_role_relations;
      END IF;

      IF c_role_name%ISOPEN THEN
        CLOSE c_role_name;
      END IF;

      IF c_get_assignment_id%ISOPEN THEN
        CLOSE c_get_assignment_id;
      END IF;

  END  update_job_roles;

 BEGIN

   l_sysdate             := trunc(sysdate);
   l_is_to_be_updated    := 'N';
   l_update_extn         := 'N';
   l_rehire_rev_emp_flag := 'N';
   l_activate_salesreps  := 'N';
   l_user_id             := nvl(FND_GLOBAL.USER_ID,-1);
   l_login               := nvl(FND_GLOBAL.LOGIN_ID,-1);

   --Standard Start of API SAVEPOINT

   SAVEPOINT UPDATE_EMPLOYEE_SP;

   l_return_status := fnd_api.g_ret_sts_success;

   FND_PROFILE.GET('JTF_RS_RESOURCE_ACTIVE_DAYS',l_active_days);

   FOR l_c_resource IN c_resource LOOP
     BEGIN
       SAVEPOINT update_resource_sp;

       l_rehire_rev_emp_flag := 'N';
       l_activate_salesreps := 'N';

       OPEN  c_ppf(l_c_resource.source_id);
       FETCH c_ppf INTO l_ppf_rec;
       IF c_ppf%FOUND THEN
--Bug7426800
--Added one extra condition to avoid update NULL in
--Source Number of Terminated Employee's
          if l_ppf_rec.current_employee_flag = 'Y' then
             l_source_number := l_ppf_rec.employee_number;
             l_assignment_type := 'E';
          elsif (l_ppf_rec.current_npw_flag = 'Y') then
             l_source_number := l_ppf_rec.npw_number;
             l_assignment_type := 'C';
          end if;

          OPEN  c_org(l_ppf_rec.business_group_id);
          FETCH c_org INTO l_org_name;
          IF c_org%NOTFOUND THEN
            l_org_name := NULL;
          END IF;
          CLOSE c_org;

          OPEN  c_phone(l_c_resource.source_id);
          FETCH c_phone INTO l_phone;
          IF c_phone%NOTFOUND THEN
            l_phone := NULL;
          END IF;
          CLOSE c_phone;

          OPEN  c_mobile_phone(l_c_resource.source_id);
          FETCH c_mobile_phone INTO l_mobile_phone;
          IF c_mobile_phone%NOTFOUND THEN
            l_mobile_phone := NULL;
          END IF;
          CLOSE c_mobile_phone;

          OPEN  c_pager(l_c_resource.source_id);
          FETCH c_pager INTO l_pager;
          IF c_pager%NOTFOUND THEN
            l_pager := NULL;
          END IF;
          CLOSE c_pager;

          l_new_job_title := NULL;
          l_new_job_id    := NULL;
          l_new_job_assignment_id := NULL;

          OPEN  c_asg(l_c_resource.source_id);
          FETCH c_asg INTO l_asg_rec;
          IF c_asg%FOUND THEN

            IF l_asg_rec.job_id is NOT NULL then
              OPEN  c_job(l_asg_rec.job_id);
              FETCH c_job INTO l_job_name;
              IF c_job%NOTFOUND THEN
                l_job_name := NULL;

              END IF;
              CLOSE c_job;
            ELSE
              l_job_name := NULL;
            END IF;

            l_new_job_title := l_job_name;
            l_new_job_id    := l_asg_rec.job_id;
            l_new_job_assignment_id := l_asg_rec.assignment_id;

            IF l_asg_rec.location_id is NOT NULL then
               OPEN  c_loc(l_asg_rec.location_id);
               FETCH c_loc INTO l_loc_rec;
               IF c_loc%NOTFOUND THEN
                 l_loc_rec := NULL;
               END IF;
               CLOSE c_loc;
            ELSE
               l_loc_rec := NULL;
            END IF;

            IF l_asg_rec.supervisor_id is NOT NULL then
               OPEN  c_mgr(l_asg_rec.supervisor_id);
               FETCH c_mgr INTO l_mgr_name;
               IF c_mgr%NOTFOUND THEN
                 l_mgr_name := NULL;
               END IF;
               CLOSE c_mgr;
            ELSE
               l_mgr_name := NULL;
            END IF;

          ELSE
            l_asg_rec := NULL;
            l_job_name := NULL;
            l_loc_rec := NULL;
            l_mgr_name := NULL;
          END IF;
          CLOSE c_asg;

          OPEN  c_check_rehire_rev_emp(l_c_resource.source_id);
          FETCH c_check_rehire_rev_emp INTO l_rehire_rev_emp_flag;
          IF l_rehire_rev_emp_flag = 'Y' THEN
             l_end_date_active := NULL;
          ELSE
             l_end_date_active := l_c_resource.end_date_active;
          END IF;
          CLOSE c_check_rehire_rev_emp;

          OPEN  c_salesreps(l_c_resource.resource_id);
          FETCH c_salesreps INTO l_salesreps_rec;
          IF c_salesreps%FOUND THEN
             l_activate_salesreps := 'Y';
          ELSE
             l_activate_salesreps := 'N';
          END IF;
          CLOSE c_salesreps;

       ELSE
          l_ppf_rec := NULL;
          l_org_name:= NULL;
          l_phone := NULL;
          l_mobile_phone := NULL;
          l_pager := NULL;
          l_asg_rec := NULL;
          l_job_name := NULL;
          l_new_job_id    := NULL;
          l_loc_rec := NULL;
          l_mgr_name := NULL;
          l_end_date_active := l_c_resource.end_date_active;
          l_source_number := l_c_resource.source_number;
       END IF;
       CLOSE c_ppf;

    l_is_to_be_updated := 'N';
    l_update_extn      := 'N';

    --ER # 2669284. Compare old and new values and update l_is_to_be_updated variable to 'Y'
    --if any change has occured.
    open rr_old_cur(l_c_resource.resource_id);
    FETCH rr_old_cur into rr_old_rec;
    close rr_old_cur;

    --ER # 2669284. Resource old values
    l_source_number_o           := null;
    l_source_name_o             := null;
    l_source_first_name_o       := null;
    l_source_middle_name_o      := null;
    l_source_last_name_o        := null;
    l_source_phone_o            := null;
    l_source_email_o            := null;
    l_source_job_id_o           := null;
    l_source_job_title_o        := null;
    l_address_id_o              := null;
    l_source_address1_o         := null;
    l_source_address2_o         := null;
    l_source_address3_o         := null;
    l_source_city_o             := null;
    l_source_country_o          := null;
    l_source_postal_code_o      := null;
    l_source_mgr_id_o           := null;
    l_source_mgr_name_o         := null;
    l_source_business_grp_id_o  := null;
    l_source_business_grp_name_o := null;
    l_source_office_o            := null;
    l_source_location_o          := null;
    l_source_mailstop_o          := null;
    l_source_mobile_phone_o      := null;
    l_source_pager_o             := null;
    l_resource_name_o            := null;
    l_end_date_active_o          := null;

    --ER # 2669284. Resource new values
    l_source_number_n               := null;
    l_source_name_n                 := null;
    l_source_first_name_n           := null;
    l_source_middle_name_n          := null;
    l_source_last_name_n            := null;
    l_source_phone_n                := null;
    l_source_email_n                := null;
    l_source_job_id_n               := null;
    l_source_job_title_n            := null;
    l_address_id_n                  := null;
    l_source_address1_n             := null;
    l_source_address2_n             := null;
    l_source_address3_n             := null;
    l_source_city_n                 := null;
    l_source_country_n             := null;
    l_source_postal_code_n          := null;
    l_source_mgr_id_n               := null;
    l_source_mgr_name_n             := null;
    l_source_business_grp_id_n      := null;
    l_source_business_grp_name_n    := null;
    l_source_office_n               := null;
    l_source_location_n             := null;
    l_source_mailstop_n             := null;
    l_source_mobile_phone_n         := null;
    l_source_pager_n                := null;
    l_resource_name_n               := null;
    l_end_date_active_n             := null;

    if nvl(l_source_number, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_number, fnd_api.g_miss_char)
    then
       l_source_number_o  :=  rr_old_rec.source_number;
       l_source_number_n  :=  l_source_number;
       l_is_to_be_updated := 'Y';

    end if;

    if nvl(l_ppf_rec.full_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_name, fnd_api.g_miss_char)
    then
       l_source_name_o  :=  rr_old_rec.source_name;
       l_source_name_n  :=  l_ppf_rec.full_name;
       l_is_to_be_updated := 'Y';
    end if;

   if nvl(l_ppf_rec.first_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_first_name, fnd_api.g_miss_char)
    then
       l_source_first_name_o  :=  rr_old_rec.source_first_name;
       l_source_first_name_n  :=  l_ppf_rec.first_name;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_ppf_rec.middle_names, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_middle_name, fnd_api.g_miss_char)
    then
       l_source_middle_name_o  :=  rr_old_rec.source_middle_name;
       l_source_middle_name_n  :=  l_ppf_rec.middle_names;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_ppf_rec.last_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_last_name, fnd_api.g_miss_char)
    then
       l_source_last_name_o  :=  rr_old_rec.source_last_name;
       l_source_last_name_n  :=  l_ppf_rec.last_name;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_phone, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_phone, fnd_api.g_miss_char)
    then
       l_source_phone_o  :=  rr_old_rec.source_phone;
       l_source_phone_n  :=  l_phone;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_ppf_rec.email_address, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_email, fnd_api.g_miss_char)
    then
       l_source_email_o  :=  rr_old_rec.source_email;
       l_source_email_n  :=  l_ppf_rec.email_address;
       l_is_to_be_updated := 'Y';
    end if;


    if nvl(l_asg_rec.location_id, -1)  <> nvl(rr_old_rec.address_id, -1)
    then
       l_address_id_o  :=  rr_old_rec.address_id;
       l_address_id_n  :=  l_asg_rec.location_id ;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_ppf_rec.party_id, fnd_api.g_miss_num)  <> nvl(rr_old_rec.person_party_id, fnd_api.g_miss_num)
    then
       l_party_id_o  :=  rr_old_rec.person_party_id;
       l_party_id_n  :=  l_ppf_rec.party_id;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_new_job_id, fnd_api.g_miss_num)  <> nvl(rr_old_rec.source_job_id, fnd_api.g_miss_num)
    then
       l_source_job_id_o  :=  rr_old_rec.source_job_id;
       l_source_job_id_n  :=  l_new_job_id;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_job_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_job_title, fnd_api.g_miss_char)
    then
       l_source_job_title_o  :=  rr_old_rec.source_job_title;
       l_source_job_title_n  :=  l_job_name;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_loc_rec.address_line_1, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_address1, fnd_api.g_miss_char)
    then
       l_source_address1_o  :=  rr_old_rec.source_address1;
       l_source_address1_n  :=  l_loc_rec.address_line_1;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_loc_rec.address_line_2, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_address2, fnd_api.g_miss_char)
    then
       l_source_address2_o  :=  rr_old_rec.source_address2;
       l_source_address2_n  :=  l_loc_rec.address_line_1;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_loc_rec.address_line_3, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_address3, fnd_api.g_miss_char)
    then
       l_source_address3_o  :=  rr_old_rec.source_address3;
       l_source_address3_n  :=  l_loc_rec.address_line_3;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_loc_rec.town_or_city, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_city, fnd_api.g_miss_char)
    then
       l_source_city_o  :=  rr_old_rec.source_city;
       l_source_city_n  :=  l_loc_rec.town_or_city;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_loc_rec.postal_code, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_postal_code, fnd_api.g_miss_char)
    then
       l_source_postal_code_o  :=  rr_old_rec.source_postal_code;
       l_source_postal_code_n  :=  l_loc_rec.postal_code;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_loc_rec.country, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_country, fnd_api.g_miss_char)
    then
       l_source_country_o  :=  rr_old_rec.source_country;
       l_source_country_n  :=  l_loc_rec.country;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_asg_rec.supervisor_id, fnd_api.g_miss_num)  <> nvl(rr_old_rec.source_mgr_id, fnd_api.g_miss_num)
    then
       l_source_mgr_id_o  :=  rr_old_rec.source_mgr_id;
       l_source_mgr_id_n  :=  l_asg_rec.supervisor_id;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_mgr_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_mgr_name, fnd_api.g_miss_char)
    then
       l_source_mgr_name_o  :=  rr_old_rec.source_mgr_name;
       l_source_mgr_name_n  :=  l_mgr_name;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_ppf_rec.business_group_id, fnd_api.g_miss_num)  <> nvl(rr_old_rec.source_business_grp_id, fnd_api.g_miss_num)
    then
       l_source_business_grp_id_o  :=  rr_old_rec.source_business_grp_id;
       l_source_business_grp_id_n  :=  l_ppf_rec.business_group_id;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_org_name, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_business_grp_name, fnd_api.g_miss_char)
    then
       l_source_business_grp_name_o  :=  rr_old_rec.source_business_grp_name;
       l_source_business_grp_name_n  :=  l_org_name;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_ppf_rec.office_number, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_office, fnd_api.g_miss_char)
    then
       l_source_office_o  :=  rr_old_rec.source_office;
       l_source_office_n  :=  l_ppf_rec.office_number;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_ppf_rec.internal_location, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_location, fnd_api.g_miss_char)
    then
       l_source_location_o  :=  rr_old_rec.source_location;
       l_source_location_n  :=  l_ppf_rec.internal_location;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_ppf_rec.mailstop, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_mailstop, fnd_api.g_miss_char)
    then
       l_source_mailstop_o  :=  rr_old_rec.source_mailstop;
       l_source_mailstop_n  :=  l_ppf_rec.mailstop;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_mobile_phone, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_mobile_phone, fnd_api.g_miss_char)
    then
       l_source_mobile_phone_o  :=  rr_old_rec.source_mobile_phone;
       l_source_mobile_phone_n  :=  l_mobile_phone;
       l_is_to_be_updated := 'Y';
    end if;

    if nvl(l_pager, fnd_api.g_miss_char)  <> nvl(rr_old_rec.source_pager, fnd_api.g_miss_char)
    then
       l_source_pager_o  :=  rr_old_rec.source_pager;
       l_source_pager_n  :=  l_pager;
       l_is_to_be_updated := 'Y';
    end if;

   if (p_overwrite_name = 'ALIAS' AND  l_ppf_rec.known_as IS NOT NULL) THEN
        l_resource_name_n  :=  l_ppf_rec.known_as;
   elsif (p_overwrite_name = 'FULL_NAME' AND l_ppf_rec.full_name IS NOT NULL) THEN
        l_resource_name_n  :=  l_ppf_rec.full_name;
   end if;

    if nvl(l_end_date_active, fnd_api.g_miss_date) <> nvl(rr_old_rec.end_date_active, fnd_api.g_miss_date)
    then
       l_end_date_active_o  :=  rr_old_rec.end_date_active;
       l_end_date_active_n  :=  l_end_date_active;
       l_is_to_be_updated := 'Y';
    end if;

    if (l_is_to_be_updated = 'Y') then
        l_update_extn     := 'Y';
    end if;

    if (l_resource_name_n is not null) then
        l_resource_name_o := rr_old_rec.resource_name;
		if ( nvl(l_resource_name_o, fnd_api.g_miss_char)  <> l_resource_name_n) then
           if (l_update_extn = 'N') then
                l_is_to_be_updated := 'Y';
           end if;
        else
            l_resource_name_n :=  null;
            l_resource_name_o :=  null;
		end if;
    end if;

    --ER # 2669284 . If any change has ben encountered, then audit that resource record and also
    --update the jtf_rs_resource_extns.
    if (l_is_to_be_updated = 'Y') then

	    ---fnd_file.put_line(fnd_file.log,'resource id:' || l_c_resource.resource_id);
        select jtf_rs_resource_extn_aud_s.nextval
        into l_resource_extn_aud_id
        from dual;

        JTF_RS_RESOURCE_EXTN_AUD_PKG.INSERT_ROW
        (
            X_ROWID                        => l_row_id ,
            x_resource_audit_id            => l_resource_extn_aud_id ,
            x_resource_id                  => l_c_resource.resource_id ,
            x_new_category                 => null ,
            x_old_category                 => null ,
            x_new_resource_number          => null ,
            x_old_resource_number          => null ,
            x_new_source_id                => null ,
            x_old_source_id                => null ,
            x_new_address_id               => l_address_id_n ,
            x_old_address_id               => l_address_id_o ,
            x_new_contact_id               => null ,
            x_old_contact_id               => null ,
            x_new_managing_employee_id     => null ,
            x_old_managing_employee_id     => null ,
            x_new_start_date_active        => null ,
            x_old_start_date_active        => null ,
            x_new_end_date_active          => l_end_date_active_n ,
            x_old_end_date_active          => l_end_date_active_o ,
            x_new_time_zone                => null ,
            x_old_time_zone                => null ,
            x_new_cost_per_hr              => null ,
            x_old_cost_per_hr              => null ,
            x_new_primary_language         => null ,
            x_old_primary_language         => null ,
            x_new_secondary_language       => null ,
            x_old_secondary_language       => null ,
            x_new_support_site_id          => null ,
            x_old_support_site_id          => null ,
            x_new_ies_agent_login          => null ,
            x_old_ies_agent_login          => null ,
            x_new_server_group_id          => null ,
            x_old_server_group_id          => null ,
            x_new_assigned_to_group_id     => null ,
            x_old_assigned_to_group_id     => null ,
            x_new_cost_center              => null ,
            x_old_cost_center              => null ,
            x_new_charge_to_cost_center    => null ,
            x_old_charge_to_cost_center    => null ,
            x_new_compensation_currency_co => null ,
            x_old_compensation_currency_co => null ,
            x_new_commissionable_flag      => null ,
            x_old_commissionable_flag      => null ,
            x_new_hold_reason_code         => null ,
            x_old_hold_reason_code         => null ,
            x_new_hold_payment             => null ,
            x_old_hold_payment             => null ,
            x_new_comp_service_team_id     => null ,
            x_old_comp_service_team_id     => null ,
            x_new_transaction_number       => null ,
            x_old_transaction_number       => null ,
            x_new_object_version_number    => null ,
            x_old_object_version_number    => null ,
            x_new_user_id                  => null ,
            x_old_user_id                  => null ,
            x_new_resource_name            => l_resource_name_n ,
            x_old_resource_name            => l_resource_name_o ,
            x_new_source_name              => l_source_name_n,
            x_old_source_name              => l_source_name_o,
            x_new_source_number            => l_source_number_n,
            x_old_source_number            => l_source_number_o,
            x_new_source_job_id            => l_source_job_id_n,
            x_old_source_job_id            => l_source_job_id_o,
            x_new_source_job_title         => l_source_job_title_n,
            x_old_source_job_title         => l_source_job_title_o,
            x_new_source_email             => l_source_email_n,
            x_old_source_email             => l_source_email_o,
            x_new_source_phone             => l_source_phone_n,
            x_old_source_phone             => l_source_phone_o,
            x_new_source_org_id            => null,
            x_old_source_org_id            => null,
            x_new_source_org_name          => null,
            x_old_source_org_name          => null,
            x_new_source_address1          => l_source_address1_n,
            x_old_source_address1          => l_source_address1_o,
            x_new_source_address2          => l_source_address2_n,
            x_old_source_address2          => l_source_address2_o,
            x_new_source_address3          => l_source_address3_n,
            x_old_source_address3          => l_source_address3_o,
            x_new_source_address4          => null,
            x_old_source_address4          => null,
            x_new_source_city              => l_source_city_n,
            x_old_source_city              => l_source_city_o,
            x_new_source_postal_code       => l_source_postal_code_n,
            x_old_source_postal_code       => l_source_postal_code_o,
            x_new_source_state             => null,
            x_old_source_state             => null,
            x_new_source_province          => null,
            x_old_source_province          => null,
            x_new_source_county            => null,
            x_old_source_county            => null,
            x_new_source_country           => l_source_country_n,
            x_old_source_country           => l_source_country_o,
            x_new_source_mgr_id            => l_source_mgr_id_n,
            x_old_source_mgr_id            => l_source_mgr_id_o,
            x_new_source_mgr_name          => l_source_mgr_name_n,
            x_old_source_mgr_name          => l_source_mgr_name_o,
            x_new_source_business_grp_id   => l_source_business_grp_id_n,
            x_old_source_business_grp_id   => l_source_business_grp_id_o,
            x_new_source_business_grp_name => l_source_business_grp_name_n,
            x_old_source_business_grp_name => l_source_business_grp_name_o,
            x_new_source_first_name        => l_source_first_name_n,
            x_old_source_first_name        => l_source_first_name_o,
            x_new_source_middle_name       => l_source_middle_name_n,
            x_old_source_middle_name       => l_source_middle_name_o,
            x_new_source_last_name         => l_source_last_name_n,
            x_old_source_last_name         => l_source_last_name_o,
            x_new_source_category          => null,
            x_old_source_category          => null,
            x_new_source_status            => null,
            x_old_source_status            => null,
            x_new_source_office            => l_source_office_n,
            x_old_source_office            => l_source_office_o,
            x_new_source_location          => l_source_location_n,
            x_old_source_location          => l_source_location_o,
            x_new_source_mailstop          => l_source_mailstop_n,
            x_old_source_mailstop          => l_source_mailstop_o,
            x_new_user_name                => null,
            x_old_user_name                => null,
            x_new_party_id                 => l_party_id_n,
            x_old_party_id                 => l_party_id_o,
            x_new_source_mobile_phone      => l_source_mobile_phone_n,
            x_old_source_mobile_phone      => l_source_mobile_phone_o,
            x_new_source_pager             => l_source_pager_n,
            x_old_source_pager             => l_source_pager_o,
            x_creation_date                => l_sysdate,
            x_created_by                   => l_user_id,
            x_last_update_date             => l_sysdate,
            x_last_updated_by              => l_user_id,
            x_last_update_login            => l_login );

       if (l_update_extn = 'Y')  then

           UPDATE jtf_rs_resource_extns
           SET last_update_date = l_sysdate,
                last_update_login = l_login,
                last_updated_by = l_user_id,
                source_number = l_source_number,
                source_name = l_ppf_rec.full_name,
                source_first_name = l_ppf_rec.first_name,
                source_last_name = l_ppf_rec.last_name,
                source_middle_name = l_ppf_rec.middle_names,
                source_phone = l_phone,
                source_email = l_ppf_rec.email_address,
                source_job_id = l_new_job_id,
                source_job_title = l_job_name,
                address_id = l_asg_rec.location_id,
                source_address1 = l_loc_rec.address_line_1,
                source_address2 = l_loc_rec.address_line_2,
                source_address3 = l_loc_rec.address_line_3,
                source_city = l_loc_rec.town_or_city,
                source_country = l_loc_rec.country,
                source_postal_code = l_loc_rec.postal_code,
                source_mgr_id = l_asg_rec.supervisor_id,
                source_mgr_name = l_mgr_name,
                source_business_grp_id = l_ppf_rec.business_group_id,
                source_business_grp_name = l_org_name,
                source_office = l_ppf_rec.office_number,
                source_location = l_ppf_rec.internal_location,
                source_mailstop = l_ppf_rec.mailstop,
                source_mobile_phone = l_mobile_phone,
                source_pager = l_pager,
                person_party_id  = l_ppf_rec.party_id,
                end_date_active = l_end_date_active
           WHERE RESOURCE_ID = l_c_resource.resource_id;
        end if;

       IF (p_overwrite_name = 'ALIAS') THEN
         IF l_resource_name_n IS NOT NULL THEN
           update jtf_rs_resource_extns_tl
              SET last_update_date  = l_sysdate,
            	last_update_login = l_login,
    	        last_updated_by   = l_user_id,
                resource_name     = l_resource_name_n,
                source_lang       = userenv('LANG')
            where resource_id       = l_c_resource.resource_id
            and userenv('LANG') in  (LANGUAGE, SOURCE_LANG);

         END IF;
       ELSIF (p_overwrite_name = 'FULL_NAME') THEN
         IF (l_resource_name_n IS NOT NULL) THEN
           update jtf_rs_resource_extns_tl
              SET last_update_date  = l_sysdate,
        	last_update_login = l_login,
    	        last_updated_by   = l_user_id,
                resource_name     = l_resource_name_n,
                source_lang       = userenv('LANG')
            where resource_id       = l_c_resource.resource_id
            and userenv('LANG') in  (LANGUAGE, SOURCE_LANG);
         END IF;
       END IF;

       IF ((l_rehire_rev_emp_flag = 'Y') and (l_activate_salesreps = 'Y')) then
          UPDATE jtf_rs_salesreps
          SET    end_date_active = NULL,
                 last_update_date = l_sysdate,
                 last_update_login = l_login,
                 last_updated_by = l_user_id
          WHERE  resource_id = l_c_resource.resource_id;
       END IF;

   END IF;

   --- In the end update job roles for that resource
   IF g_run_date between trunc(l_c_resource.start_date_active) and trunc(nvl(l_end_date_active-l_active_days,g_run_date)) then /*active resource*/

     -- Bug 5590723 (Handle NULL values in source_job_id column when source_job_title is populated)
     -- otherwise NULL value gets passed to update_job_roles procedure.
      l_derived_job_id := rr_old_rec.source_job_id;

      IF (rr_old_rec.source_job_id IS NULL) THEN
        IF (rr_old_rec.source_job_title IS NOT NULL AND
            rr_old_rec.source_business_grp_id IS NOT NULL
           )
		THEN
           OPEN c_derive_job_id (rr_old_rec.source_job_title, rr_old_rec.source_business_grp_id);
           FETCH c_derive_job_id INTO l_derived_job_id;
           CLOSE c_derive_job_id;
        END IF;
      END IF;

           update_job_roles(
                          p_old_job_id              => l_derived_job_id, --l_c_resource.source_job_id,
                          p_new_job_title           => l_new_job_title,
                          p_new_job_id              => l_new_job_id,
                          p_new_job_assignment_id   => l_new_job_assignment_id,
                          p_person_id               => l_c_resource.source_id,
                          p_resource_id             => l_c_resource.resource_id,
                          p_assignment_type         => l_assignment_type
                          );

   END IF;

   EXCEPTION
     WHEN fnd_api.g_exc_error
     THEN
    --   fnd_file.put_line(fnd_file.log, sqlerrm);
       ROLLBACK TO update_resource_sp;
     WHEN fnd_api.g_exc_unexpected_error
     THEN
    --   fnd_file.put_line(fnd_file.log, sqlerrm);
       ROLLBACK TO update_resource_sp;
     WHEN OTHERS
     THEN
       fnd_file.put_line(fnd_file.log, sqlerrm);
       ROLLBACK TO update_resource_sp;
   END;

  END LOOP;

 EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error
   THEN

     IF c_resource%ISOPEN THEN
       CLOSE c_resource;
     END IF;

     IF c_check_rehire_rev_emp%ISOPEN THEN
       CLOSE c_check_rehire_rev_emp;
     END IF;

     IF c_salesreps%ISOPEN THEN
       CLOSE c_salesreps;
     END IF;

     IF c_ppf%ISOPEN THEN
       CLOSE c_ppf;
     END IF;

     fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
     ROLLBACK TO UPDATE_EMPLOYEE_SP;
   WHEN OTHERS
   THEN

     IF c_resource%ISOPEN THEN
       CLOSE c_resource;
     END IF;

     IF c_check_rehire_rev_emp%ISOPEN THEN
       CLOSE c_check_rehire_rev_emp;
     END IF;

     IF c_salesreps%ISOPEN THEN
       CLOSE c_salesreps;
     END IF;

     IF c_ppf%ISOPEN THEN
       CLOSE c_ppf;
     END IF;

     fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
     ROLLBACK TO UPDATE_EMPLOYEE_SP;

 END  update_employee;

----------------------------------------------------------------------

   PROCEDURE  update_terminated_employee
   IS
   cursor term_res_cur
      is
  SELECT RESOURCE_ID, SOURCE_ID
   FROM JTF_RS_RESOURCE_EXTNS RES
  WHERE res.category    = 'EMPLOYEE'
  AND   not exists (select ppl.person_id
                      from   per_all_people_f ppl,
                             per_all_assignments_f asg
                      where  ppl.person_id = res.source_id
                        and  res.category  = 'EMPLOYEE'
                        and  trunc(sysdate) between ppl.effective_start_date and ppl.effective_end_date
                        and  ppl.employee_number is not null
                        and  ppl.person_id = asg.person_id
                        and  trunc(sysdate) between asg.effective_start_date and asg.effective_end_date
                        and  asg.primary_flag = 'Y')
 /*AND NOT EXISTS (SELECT EMPLOYEE_ID
                      FROM PER_EMPLOYEES_CURRENT_X
                      WHERE EMPLOYEE_ID = RES.SOURCE_ID)*/
   union
  SELECT RESOURCE_ID, SOURCE_ID
   FROM JTF_RS_RESOURCE_EXTNS RES
  WHERE res.category    = 'EMPLOYEE'
    AND  (res.end_date_active  IS NOT NULL AND res.end_date_active < sysdate);

   term_res_rec  term_res_cur%rowtype;


   l_too_many_rows_query EXCEPTION;  --exception to handle too many rows returned by inner query;
   PRAGMA EXCEPTION_INIT(l_too_many_rows_query, -1427 );


    CURSOR fetch_emp_cur(l_resource_id NUMBER)
      IS
    SELECT res.resource_id              resource_id
       , res.resource_number          resource_number
       , res.object_version_number   object_version_num
       , ppl.person_id              person_id
       , ppl.employee_number             employee_number
       , ppl.full_name                full_name
       , ppl.first_name               first_name
       , ppl.middle_names              middle_name
       , ppl.last_name                last_name
       , ppl.work_telephone           phone
       , ppl.email_address            email
       , ppl.business_group_id        org_id
       , org.name                     org_name
       , ppl.office_number           office
       , ppl.internal_location       location
       , ppl.mailstop                mailstop
       , ppl.party_id                party_id
  FROM  jtf_rs_resource_extns         res
      , per_all_people_f             ppl
      , hr_all_organization_units     org
  WHERE res.resource_id  = l_resource_id
   AND  res.source_id   = ppl.person_id
   and    ppl.effective_start_date = (select max(effective_start_date)
                            from per_all_people_f where person_id = ppl.person_id)
   and    ppl.effective_end_date = (select max(effective_end_date)
                            from per_all_people_f where person_id = ppl.person_id)
   and    ppl.business_group_id = org.organization_id;

   emp_rec fetch_emp_cur%rowtype;

   BEGIN

     open term_res_cur;
     fetch term_res_cur into term_res_rec;
     while(term_res_cur%found)
     loop

     begin
        UPDATE jtf_rs_resource_extns RES
        SET RES.LAST_UPDATE_DATE  = sysdate,
            RES.LAST_UPDATED_BY  = fnd_global.user_id,
           (RES.SOURCE_NUMBER  ,
            RES.SOURCE_NAME ,
            RES.SOURCE_PHONE   ,
            RES.SOURCE_EMAIL  ,
            --RES.SOURCE_JOB_TITLE  ,
            --RES.SOURCE_ORG_ID  ,
            --RES.SOURCE_ORG_NAME ,
            --RES.SOURCE_ADDRESS1,
            --RES.SOURCE_ADDRESS2 ,
            --RES.SOURCE_ADDRESS3 ,
            --RES.SOURCE_ADDRESS4  ,
            --RES.SOURCE_CITY      ,
            --RES.SOURCE_POSTAL_CODE ,
            --RES.SOURCE_STATE    ,
            --RES.SOURCE_PROVINCE ,
            --RES.SOURCE_COUNTY   ,
            --RES.SOURCE_COUNTRY  ,
            --RES.SOURCE_MGR_ID  ,
            --RES.SOURCE_MGR_NAME   ,
            RES.SOURCE_BUSINESS_GRP_ID    ,
            RES.SOURCE_BUSINESS_GRP_NAME,
            RES.SOURCE_FIRST_NAME,
            RES.SOURCE_MIDDLE_NAME,
            RES.SOURCE_LAST_NAME,
            RES.SOURCE_OFFICE,
            RES.SOURCE_LOCATION,
            RES.PERSON_PARTY_ID,
            RES.SOURCE_MAILSTOP)
     =    ( SELECT
              ppl.employee_number             employee_number
              , ppl.full_name                full_name
              , ppl.work_telephone           phone
              , ppl.email_address            email
              --, job.name                     job_title
              --, NULL
              --, NULL
              --, loc.address_line_1           address1
              --, loc.address_line_2           address2
              --, loc.address_line_3           address3
              --, null                         address4
              --, loc.town_or_city             city
              --, loc.postal_code              postal_code
              --, null                         state
              --, null                         province
              --, null                         county
              --, loc.country                  country
              --, asg.supervisor_id            mgr_id
              --, emp.full_name                mgr_name
              , ppl.business_group_id        org_id
              , org.name                     org_name
              , ppl.first_name
              , ppl.middle_names
              , ppl.last_name
              , ppl.office_number
              , ppl.internal_location
              , ppl.party_id
              , ppl.mailstop
           FROM  per_all_people_f              ppl
                , hr_all_organization_units     org
                --, per_all_assignments_f             asg
                --, per_jobs                      job
                --, hr_locations                  loc
                --, per_employees_current_x       emp
             WHERE  res.source_id   = ppl.person_id
          /* AND NOT EXISTS (SELECT EMPLOYEE_ID
                      FROM PER_EMPLOYEES_CURRENT_X
                      WHERE EMPLOYEE_ID = RES.SOURCE_ID) */
            AND ppl.effective_start_date = (select max(effective_start_date)
                                    from   per_all_people_f
                                    where  person_id = ppl.person_id)
            and ppl.business_group_id = org.organization_id
            --and ppl.person_id   = asg.person_id
            --and asg.primary_flag = 'Y'
            --and asg.assignment_type = 'E'
            /*and asg.effective_start_date =  (select max(effective_start_date)
                                    from   per_all_assignments_f
                                    where  person_id = ppl.person_id
                                     and primary_flag = 'Y'
                                     and assignment_type = 'E'
                                    ) */
             --and asg.job_id   = job.job_id(+)
             --and asg.location_id  = loc.location_id (+)
             --and asg.supervisor_id   = emp.employee_id(+)
             )
             WHERE res.resource_id    =  term_res_rec.resource_id ;

       EXCEPTION
       when l_too_many_rows_query then
          open fetch_emp_cur(term_res_rec.resource_id);
          fetch fetch_emp_cur into emp_rec;
          close fetch_emp_cur;
          UPDATE jtf_rs_resource_extns RES
          SET     RES.LAST_UPDATE_DATE  = sysdate,
                  RES.LAST_UPDATED_BY  = fnd_global.user_id,
                  RES.SOURCE_NUMBER    = emp_rec.employee_number ,
                  RES.SOURCE_NAME      = emp_rec.full_name,
                  RES.SOURCE_PHONE     = emp_rec.phone,
                  RES.SOURCE_EMAIL     = emp_rec.email,
                  --RES.SOURCE_JOB_TITLE = emp_rec.job_title ,
                  RES.SOURCE_BUSINESS_GRP_ID = emp_rec.org_id   ,
                  RES.SOURCE_BUSINESS_GRP_NAME = emp_rec.org_name,
                  RES.SOURCE_FIRST_NAME = emp_rec.first_name,
                  RES.SOURCE_LAST_NAME = emp_rec.last_name,
                  RES.SOURCE_MIDDLE_NAME = emp_rec.middle_name,
                  RES.SOURCE_OFFICE = emp_rec.office,
                  RES.SOURCE_LOCATION = emp_rec.location,
                  RES.person_party_id = emp_rec.party_id,
                  RES.SOURCE_MAILSTOP = emp_rec.mailstop
          WHERE RES.resource_id = emp_rec.resource_id;
        WHEN OTHERS
         THEN
              fnd_message.set_name('JTF', 'JTF_RS_UPD_TERM_RES_ERR');
              fnd_message.set_token('P_PERSON_ID',term_res_rec.source_id );
              fnd_file.put_line(fnd_file.log, fnd_message.get);

       end;
       fetch term_res_cur into term_res_rec;
     end loop;
     close term_res_cur;
     commit;

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
       fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
    WHEN OTHERS
    THEN
       fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
       fnd_file.put_line(fnd_file.log, sqlerrm);
    END  update_terminated_employee;



  PROCEDURE update_emp_phone
  IS
  BEGIN

      update jtf_rs_resource_extns res
        SET   RES.LAST_UPDATE_DATE  = sysdate,
              RES.LAST_UPDATED_BY  = fnd_global.user_id,
              RES.SOURCE_PHONE
         =    (select per.phone_number
                 from per_phones per
                where  parent_table = 'PER_ALL_PEOPLE_F'
                  and  parent_id    = res.source_id
                  and  phone_type = 'W1'
                  AND  trunc(sysdate) between date_from and nvl(date_to, to_date('31/12/4712', 'DD/MM/YYYY')))
          WHERE RES.CATEGORY = 'EMPLOYEE';


      commit;
   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
       fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
    WHEN OTHERS
    THEN
       fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
       fnd_file.put_line(fnd_file.log, sqlerrm);

  END update_emp_phone;

  PROCEDURE synchronize_party
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2,
   P_OVERWRITE_NAME          IN  VARCHAR2
   )

   IS


   BEGIN
      --Terminate all partner resource, whose relationship is terminated in hz_relationships
        jtf_rs_conc_res_pub.terminate_partner_rel;

        jtf_rs_conc_res_pub.update_party
              (p_overwrite_name => P_OVERWRITE_NAME);
        COMMIT;

    EXCEPTION
       WHEN fnd_api.g_exc_unexpected_error
       THEN
           fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
       WHEN OTHERS
       THEN
          fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);

   END  synchronize_party;

  PROCEDURE  terminate_partner_rel IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'TERMINATE_PARTNER_REL';
    L_RETURN_STATUS       VARCHAR2(2);
    L_MSG_COUNT           NUMBER;
    L_MSG_DATA            VARCHAR2(2000);

    CURSOR term_part_rel_cur (l_active_days IN NUMBER) IS
      SELECT rsc.resource_id
           , rsc.object_version_number
           , hpr.end_date
           , hpr.status
    FROM   jtf_rs_resource_extns rsc
           ,hz_relationships hpr
    WHERE  rsc.category  = 'PARTNER'
    AND    rsc.source_id = hpr.party_id
    AND    hpr.directional_flag = 'F'
--
      AND hpr.RELATIONSHIP_CODE IN
           ('PARTNER_OF', 'VAD_OF', 'VAD_VENDOR_OF',
            'THIRD_PARTY_FOR', 'INDIRECTLY_MANAGES_CUSTOMER', 'CUSTOMER_INDIRECTLY_MANAGED_BY','POM_THIRDPARTY_AUTHOR_FOR')
      AND hpr.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
      AND hpr.OBJECT_TABLE_NAME = 'HZ_PARTIES'
--
--    AND    hpr.relationship_code in ('PARTNER_OF','VAD_OF','CUSTOMER_INDIRECTLY_MANAGED_BY','POM_THIRDPARTY_AUTHOR_FOR')
    AND    ((hpr.status  = 'I')
            OR
            (nvl(trunc(hpr.end_date),trunc(sysdate)) < trunc(sysdate)))
    AND   nvl(trunc(end_date_active),trunc(sysdate+1+l_active_days)) > trunc(sysdate+l_active_days);

    l_count          NUMBER;
    l_active_days    NUMBER;

    BEGIN

    --Standard Start of API SAVEPOINT
     SAVEPOINT TERMINATE_PARTNER_REL_SP;

    l_return_status := fnd_api.g_ret_sts_success;
    l_count := 0;

    FND_PROFILE.GET('JTF_RS_RESOURCE_ACTIVE_DAYS',l_active_days);

    IF l_active_days IS NULL THEN
      l_active_days := 0;
    END IF;

    FOR term_part_rel_rec IN term_part_rel_cur (l_active_days) LOOP

      l_return_status := fnd_api.g_ret_sts_success;

      IF (trunc(nvl(term_part_rel_rec.end_date,sysdate)) < trunc(sysdate)) THEN
        jtf_rs_resource_utl_pub.end_date_employee
          (p_api_version         => 1.0
           , p_resource_id       => term_part_rel_rec.resource_id
           , p_end_date_active   => trunc(term_part_rel_rec.end_date)+l_active_days
           , x_object_ver_number => term_part_rel_rec.object_version_number
           , x_return_status     => l_return_status
           , x_msg_count         => l_msg_count
           , x_msg_data          => l_msg_data);
      ELSIF (term_part_rel_rec.status = 'I') THEN
        jtf_rs_resource_utl_pub.end_date_employee
          (p_api_version         => 1.0
           , p_resource_id       => term_part_rel_rec.resource_id
           , p_end_date_active   => trunc(sysdate-1)+l_active_days
           , x_object_ver_number => term_part_rel_rec.object_version_number
           , x_return_status     => l_return_status
           , x_msg_count         => l_msg_count
           , x_msg_data          => l_msg_data);
      END IF;

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      l_count := l_count + 1;
      IF (l_count > 1000) THEN
        COMMIT;
        l_count := 1;
      END IF;

    END LOOP; -- end of term_part_cur

    FND_MSG_PUB.count_and_get (p_count => l_msg_count, p_data => l_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO TERMINATE_PARTNER_REL_SP;

    WHEN OTHERS
    THEN
      fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO TERMINATE_PARTNER_REL_SP;
      fnd_file.put_line(fnd_file.log, sqlerrm);

  END terminate_partner_rel;


  PROCEDURE update_party
            (P_OVERWRITE_NAME          IN  VARCHAR2 )
  IS
   l_too_many_rows_query EXCEPTION;  --exception to handle too many rows returned by inner query;
   PRAGMA EXCEPTION_INIT(l_too_many_rows_query, -1427 );


   CURSOR c_res
       IS
    SELECT resource_id
           , source_id
           , address_id
           , category
      FROM jtf_rs_resource_extns
     WHERE category in ('PARTY', 'PARTNER');


   CURSOR c_party(l_party_id in number)
       IS
     SELECT PARTY.PARTY_NUMBER,
            PARTY.PARTY_NAME,
            PARTY.EMAIL_ADDRESS,
            CT_POINT1.PHONE_AREA_CODE||CT_POINT1.PHONE_NUMBER    PHONE,
            TO_NUMBER(NULL)                                      ORG_ID,
            NULL                                                 ORG_NAME,
            PARTY.PERSON_FIRST_NAME    FIRST_NAME,
            PARTY.PERSON_MIDDLE_NAME   MIDDLE_NAME,
            PARTY.PERSON_LAST_NAME     LAST_NAME
       FROM
             HZ_PARTIES         PARTY,
             HZ_CONTACT_POINTS  CT_POINT1
      WHERE  PARTY.PARTY_ID          = l_party_id
        AND CT_POINT1.OWNER_TABLE_NAME   (+)= 'HZ_PARTIES'
        AND CT_POINT1.OWNER_TABLE_ID     (+)= PARTY.PARTY_ID
        AND CT_POINT1.PRIMARY_FLAG       (+)= 'Y'
        AND CT_POINT1.STATUS             (+)= 'A'
        AND CT_POINT1.CONTACT_POINT_TYPE (+)= 'PHONE';



   CURSOR c_partner(l_party_id in number)
       IS
   SELECT PARTY.PARTY_NUMBER,
          PARTY.PARTY_NAME,
          PARTY.EMAIL_ADDRESS,
          CT_POINT1.PHONE_AREA_CODE||CT_POINT1.PHONE_NUMBER    PHONE,
          REL.OBJECT_ID             ORG_ID,
          PARTY.PARTY_NAME          ORG_NAME,
          PARTY.PERSON_FIRST_NAME   FIRST_NAME,
          PARTY.PERSON_MIDDLE_NAME  MIDDLE_NAME,
          PARTY.PERSON_LAST_NAME    LAST_NAME
    FROM
          HZ_PARTIES         PARTY,
          HZ_PARTIES         PARTY2,
          HZ_PARTIES         PARTY3,
          HZ_CONTACT_POINTS  CT_POINT1,
          HZ_RELATIONSHIPS  REL
    WHERE PARTY.PARTY_ID  = l_party_id
      AND  (
                (
                 PARTY.PARTY_TYPE = 'ORGANIZATION'
                 AND
                 PARTY.PARTY_ID = REL.SUBJECT_ID
                 )
           OR
                (
                 PARTY.PARTY_TYPE             = 'PARTY_RELATIONSHIP'
                 AND
                  PARTY.PARTY_ID               =  REL.PARTY_ID
                 )
           )
--
--
      AND REL.RELATIONSHIP_CODE IN
           ('PARTNER_OF', 'VAD_OF', 'VAD_VENDOR_OF',
            'THIRD_PARTY_FOR', 'INDIRECTLY_MANAGES_CUSTOMER', 'CUSTOMER_INDIRECTLY_MANAGED_BY','POM_THIRDPARTY_AUTHOR_FOR')
      AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
      AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
      AND REL.DIRECTIONAL_FLAG = 'F'
      AND REL.STATUS = 'A'
--
      AND REL.SUBJECT_ID               = PARTY2.PARTY_ID
      AND (PARTY2.PARTY_TYPE           = 'PERSON'
              OR PARTY2.PARTY_TYPE         = 'ORGANIZATION')
      AND REL.OBJECT_ID                = PARTY3.PARTY_ID
      AND PARTY3.PARTY_TYPE            = 'ORGANIZATION'
      AND CT_POINT1.OWNER_TABLE_NAME   (+)= 'HZ_PARTIES'
      AND CT_POINT1.OWNER_TABLE_ID     (+)= PARTY.PARTY_ID
      AND CT_POINT1.PRIMARY_FLAG       (+)= 'Y'
      AND CT_POINT1.STATUS             (+)= 'A'
      AND CT_POINT1.CONTACT_POINT_TYPE (+)= 'PHONE'
      ORDER BY PARTY.LAST_UPDATE_DATE DESC ;  -- so that we can pick up latest record.

   r_party  c_partner%rowtype;

   CURSOR  c_address(l_address_id in number)
       IS
   SELECT  LOC.ADDRESS1
          ,LOC.ADDRESS2
          ,LOC.ADDRESS3
          ,LOC.ADDRESS4
          ,LOC.CITY
          ,LOC.POSTAL_CODE
          ,LOC.STATE
          ,LOC.PROVINCE
          ,LOC.COUNTY
          ,LOC.COUNTRY
    FROM  HZ_PARTY_SITES   PARTY_SITE
          , HZ_LOCATIONS   LOC
   WHERE PARTY_SITE.PARTY_SITE_ID    =  l_address_id
     AND PARTY_SITE.LOCATION_ID       =  LOC.LOCATION_ID;

  r_address c_address%rowtype;

  /* Moved the initial assignment of below variables to inside begin */
  l_sysdate DATE;
  l_user_id NUMBER;
  l_login   NUMBER;

  BEGIN

  l_sysdate := sysdate;
  l_user_id := nvl(FND_GLOBAL.USER_ID,-1);
  l_login   := nvl(FND_GLOBAL.LOGIN_ID,-1);

   -- first  populate the address id where address id is null
      BEGIN
       UPDATE JTF_RS_RESOURCE_EXTNS RES
          SET RES.LAST_UPDATE_DATE  = l_sysdate,
              RES.LAST_UPDATED_BY  = l_user_id,
              RES.LAST_UPDATE_LOGIN = l_login,
             (RES.ADDRESS_ID)
            = ( SELECT  prt.party_site_id
                  FROM   hz_party_sites prt
                 WHERE  prt.party_id = RES.source_id
                   AND  prt.identifying_address_flag = 'Y'
                   -- added status flag check 20 nov 2001
                   AND  prt.status = 'A')
       WHERE RES.CATEGORY = 'PARTY'
        AND  RES.ADDRESS_ID IS NULL;


       EXCEPTION
        WHEN L_TOO_MANY_ROWS_QUERY
        THEN
             null;
        WHEN OTHERS
        THEN
          fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
          fnd_file.put_line(fnd_file.log, sqlerrm);
       END;



        -- first populate the address id with primary address id for PARTNER
      BEGIN
        UPDATE JTF_RS_RESOURCE_EXTNS RES
          SET RES.LAST_UPDATE_DATE  = l_sysdate,
              RES.LAST_UPDATED_BY  = l_user_id,
              RES.LAST_UPDATE_LOGIN = l_login,
              (RES.ADDRESS_ID)
               = ( SELECT  prt.party_site_id
                  FROM   hz_party_sites prt
                 WHERE  prt.party_id = RES.source_id
                   AND  prt.identifying_address_flag = 'Y'
                   -- added status flag check 20 nov 2001
                   AND  prt.status = 'A')
          WHERE RES.CATEGORY = 'PARTNER'
            AND exists (select 'A'
                          from hz_parties par
                         where par.party_id = res.source_id
                           and par.party_type = 'PARTY_RELATIONSHIP');

       EXCEPTION
        WHEN L_TOO_MANY_ROWS_QUERY
        THEN
             null;
        WHEN OTHERS
        THEN
          fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
          fnd_file.put_line(fnd_file.log, sqlerrm);

       END;

   for r_res in c_res
   loop
     IF(r_res.category = 'PARTY')
     THEN
        open c_party(r_res.source_id);
        fetch c_party into r_party;
        close c_party;
     ELSIF(r_res.category = 'PARTNER')
     THEN
        open c_partner(r_res.source_id);
        fetch c_partner into r_party;
        close c_partner;
     END IF;
     IF(r_party.party_number is not null)
     THEN
       open c_address(r_res.address_id);
       fetch c_address into r_address;
       close c_address;

       UPDATE  JTF_RS_RESOURCE_EXTNS RES
          SET  RES.LAST_UPDATE_DATE    = l_sysdate,
               RES.LAST_UPDATED_BY     = l_user_id,
               RES.LAST_UPDATE_LOGIN   = l_login,
               RES.SOURCE_NUMBER       = r_party.party_number,
               RES.SOURCE_NAME         = r_party.party_name,
               RES.SOURCE_EMAIL        = r_party.email_address ,
               RES.SOURCE_ADDRESS1     = r_address.address1,
               RES.SOURCE_ADDRESS2     = r_address.address2,
               RES.SOURCE_ADDRESS3     = r_address.address3,
               RES.SOURCE_ADDRESS4     = r_address.address4,
               RES.SOURCE_CITY         = r_address.city,
               RES.SOURCE_POSTAL_CODE  = r_address.postal_code ,
               RES.SOURCE_STATE        = r_address.state,
               RES.SOURCE_PROVINCE     = r_address.province,
               RES.SOURCE_COUNTY       = r_address.county,
               RES.SOURCE_COUNTRY      = r_address.country,
               RES.SOURCE_PHONE        = r_party.phone,
               RES.SOURCE_ORG_ID       = r_party.org_id,
               RES.SOURCE_ORG_NAME     = r_party.org_name,
               RES.SOURCE_FIRST_NAME   = r_party.first_name,
               RES.SOURCE_MIDDLE_NAME  = r_party.middle_name,
               RES.SOURCE_LAST_NAME    = r_party.last_name
       WHERE   RES.RESOURCE_ID         = r_res.resource_id;


       IF(p_overwrite_name = 'Y')
       THEN
           update jtf_rs_resource_extns_tl res
              SET RES.LAST_UPDATE_DATE    = l_sysdate,
                  RES.LAST_UPDATED_BY     = l_user_id,
                  RES.LAST_UPDATE_LOGIN   = l_login,
                  resource_name           = r_party.party_name,
                  SOURCE_LANG             = userenv('LANG')
            where resource_id             = r_res.resource_id
              and userenv('LANG') in  (LANGUAGE, SOURCE_LANG);
       END IF;
     END IF;

   end loop;

   COMMIT;


   EXCEPTION
       WHEN OTHERS
       THEN
          fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
          fnd_file.put_line(fnd_file.log, sqlerrm);

   END update_party;



  PROCEDURE  synchronize_supp_contact
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2,
   P_OVERWRITE_NAME          IN  VARCHAR2
   )IS

   BEGIN

     -- Call Terminate Supplier Contact Procedure
        jtf_rs_conc_res_pub.terminate_supplier_contact;

     -- Call Update Supplier Contact Procedure
        jtf_rs_conc_res_pub.update_supp_contact
           (p_overwrite_name => P_OVERWRITE_NAME);
        COMMIT;

    EXCEPTION
       WHEN fnd_api.g_exc_unexpected_error
       THEN
           fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
       WHEN OTHERS
       THEN
          fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
    END  synchronize_supp_contact;


  PROCEDURE update_supp_contact
            (P_OVERWRITE_NAME          IN  VARCHAR2 )
  is

  CURSOR c_res
      IS
  SELECT resource_id,
         source_id
    FROM jtf_rs_resource_extns res
   WHERE res.category = 'SUPPLIER_CONTACT';



  CURSOR c_supp(l_supplier_contact_id in NUMBER)
      IS
   SELECT POV.SEGMENT1                      SOURCE_NUMBER,
          POC.LAST_NAME || ' , ' || POC.MIDDLE_NAME ||' '|| POC.FIRST_NAME|| ' - '|| POV.VENDOR_NAME  SOURCE_NAME ,
          NULL                              EMAIL,
          POS.ADDRESS_LINE1                 ADDRESS1 ,
          POS.ADDRESS_LINE2                 ADDRESS2 ,
          POS.ADDRESS_LINE3                 ADDRESS3  ,
          NULL                              ADDRESS4  ,
          POS.CITY                          CITY    ,
          POS.ZIP                           POSTAL_CODE ,
          POS.STATE                         STATE  ,
          POS.PROVINCE                      PROVINCE,
          POS.COUNTY                        COUNTY  ,
          POS.COUNTRY                       COUNTRY ,
          POC.AREA_CODE || ' ' ||POC.PHONE  PHONE,
          POS.ORG_ID                        ORG_ID,
--        ORG.NAME                          ORG_NAME,
          POC.FIRST_NAME                    FIRST_NAME,
          POC.MIDDLE_NAME                   MIDDLE_NAME,
          POC.LAST_NAME                     LAST_NAME
   FROM   PO_VENDOR_CONTACTS    POC,
          PO_VENDOR_SITES_ALL   POS,
          PO_VENDORS            POV
--        HR_OPERATING_UNITS    ORG
   WHERE  POC.VENDOR_CONTACT_ID = l_supplier_contact_id
     AND  POC.VENDOR_SITE_ID    =  POS.VENDOR_SITE_ID
     AND  POS.VENDOR_ID         =  POV.VENDOR_ID;
--   AND  POS.ORG_ID            =  ORG.ORGANIZATION_ID;

  r_supp c_supp%rowtype;

  --Added this Cursor (and some related code changes) as a fix for bug #2586720, single org sync issue
  CURSOR c_org_name (l_org_id IN NUMBER) IS
    SELECT name
    FROM  hr_operating_units
    WHERE organization_id = l_org_id;

  /* Moved the initial assignment of below variables to inside begin */
  l_sysdate DATE;
  l_user_id NUMBER;
  l_login   NUMBER;

  l_org_name         HR_OPERATING_UNITS.NAME%TYPE := NULL;

  begin

  l_sysdate  := sysdate;
  l_user_id  := nvl(FND_GLOBAL.USER_ID,-1);
  l_login    := nvl(FND_GLOBAL.LOGIN_ID,-1);

     -- synchronize supp cont

   FOR r_res in c_res LOOP

     OPEN c_supp(r_res.source_id);
     FETCH c_supp into r_supp;
     IF(c_supp%found)
     THEN

       l_org_name := NULL;

       IF r_supp.org_id IS NOT NULL THEN
         OPEN c_org_name (r_supp.org_id);
         FETCH c_org_name into l_org_name;
         CLOSE c_org_name;
       END IF;

         UPDATE JTF_RS_RESOURCE_EXTNS RES
           SET RES.LAST_UPDATE_DATE    = l_sysdate,
               RES.LAST_UPDATED_BY     = l_user_id,
               RES.LAST_UPDATE_LOGIN   = l_login,
               RES.SOURCE_NUMBER       = r_supp.source_number,
               RES.SOURCE_NAME         = r_supp.source_name,
               RES.SOURCE_EMAIL        = r_supp.email ,
               RES.SOURCE_ADDRESS1     = r_supp.address1,
               RES.SOURCE_ADDRESS2     = r_supp.address2,
               RES.SOURCE_ADDRESS3     = r_supp.address3,
               RES.SOURCE_ADDRESS4     = r_supp.address4,
               RES.SOURCE_CITY         = r_supp.city,
               RES.SOURCE_POSTAL_CODE  = r_supp.postal_code ,
               RES.SOURCE_STATE        = r_supp.state,
               RES.SOURCE_PROVINCE     = r_supp.province,
               RES.SOURCE_COUNTY       = r_supp.county,
               RES.SOURCE_COUNTRY      = r_supp.country,
               RES.SOURCE_PHONE        = r_supp.phone,
               RES.SOURCE_ORG_ID        = r_supp.org_id,
               RES.SOURCE_ORG_NAME      = l_org_name,
               RES.SOURCE_FIRST_NAME    = r_supp.first_name,
               RES.SOURCE_MIDDLE_NAME   = r_supp.middle_name,
               RES.SOURCE_LAST_NAME     = r_supp.last_name
         WHERE RES.RESOURCE_ID  = r_res.resource_id;


         IF(p_overwrite_name = 'Y')
         THEN
             update jtf_rs_resource_extns_tl res
                SET RES.LAST_UPDATE_DATE    = l_sysdate,
                    RES.LAST_UPDATED_BY     = l_user_id,
                    RES.LAST_UPDATE_LOGIN   = l_login,
                    SOURCE_LANG             = userenv('LANG'),
                    resource_name   =   r_supp.source_name
              where resource_id     =   r_res.resource_id
                and userenv('LANG') in  (LANGUAGE, SOURCE_LANG);
         END IF;
     END IF;
     CLOSE c_supp;

   END LOOP;
   COMMIT;

   EXCEPTION
       WHEN fnd_api.g_exc_unexpected_error
       THEN
           fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
       WHEN OTHERS
       THEN
          fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
  end update_supp_contact;


  PROCEDURE terminate_supplier_contact IS

    l_api_version         CONSTANT NUMBER := 1.0;
    l_api_name            CONSTANT VARCHAR2(30) := 'TERMINATE_SUPPLIER_CONTACT';
    L_RETURN_STATUS       VARCHAR2(2);
    L_MSG_COUNT           NUMBER;
    L_MSG_DATA            VARCHAR2(2000);

    CURSOR term_supp_cont_cur (l_active_days IN NUMBER) IS
      SELECT rsc.resource_id
           , rsc.object_version_number
           , pvc.inactive_date
    FROM   jtf_rs_resource_extns rsc
           ,po_vendor_contacts pvc
    WHERE  rsc.category  = 'SUPPLIER_CONTACT'
    AND    rsc.source_id = pvc.vendor_contact_id
    AND    trunc(nvl(inactive_date, sysdate)) < trunc(sysdate)
    AND    trunc(nvl(end_date_active,inactive_date+1+l_active_days)) > trunc(inactive_date+l_active_days);

    l_active_days       NUMBER;
    l_count             NUMBER;

  BEGIN

    --Standard Start of API SAVEPOINT
     SAVEPOINT TERMINATE_SUPPLIER_CONTACT_SP;

    l_return_status := fnd_api.g_ret_sts_success;
    l_count := 0;

    FND_PROFILE.GET('JTF_RS_RESOURCE_ACTIVE_DAYS',l_active_days);

    IF l_active_days IS NULL THEN
      l_active_days := 0;
    END IF;

    FOR term_supp_cont_rec IN term_supp_cont_cur (l_active_days) LOOP

      l_return_status := fnd_api.g_ret_sts_success;

      jtf_rs_resource_utl_pub.end_date_employee
        (p_api_version         => 1.0
         , p_resource_id       => term_supp_cont_rec.resource_id
         , p_end_date_active   => trunc(term_supp_cont_rec.inactive_date)+l_active_days
         , x_object_ver_number => term_supp_cont_rec.object_version_number
         , x_return_status     => l_return_status
         , x_msg_count         => l_msg_count
         , x_msg_data          => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      l_count := l_count + 1;
      IF (l_count > 1000) THEN
        COMMIT;
        l_count := 1;
      END IF;

    END LOOP; -- end of term_part_cur

   FND_MSG_PUB.count_and_get (p_count => l_msg_count, p_data => l_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO TERMINATE_SUPPLIER_CONTACT_SP;

    WHEN OTHERS
    THEN
      fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO TERMINATE_SUPPLIER_CONTACT_SP;
      fnd_file.put_line(fnd_file.log, sqlerrm);

  END terminate_supplier_contact;


  PROCEDURE update_username
  IS
  BEGIN
     UPDATE jtf_rs_resource_extns res
        SET user_name = (SELECT user_name
  	  		   FROM fnd_user fu
			  WHERE res.user_id = fu.user_id)
      WHERE user_id IS NOT NULL;
      COMMIT;
  EXCEPTION
     WHEN fnd_api.g_exc_unexpected_error
     THEN
       fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
     WHEN OTHERS
     THEN
       fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
       fnd_file.put_line(fnd_file.log, sqlerrm);
  END  update_username;


  PROCEDURE update_userid
  IS

  l_RETURN_STATUS   VARCHAR2(2);
  l_MSG_COUNT       NUMBER;
  l_MSG_DATA        VARCHAR2(2000);


  CURSOR c_invalid_userid IS
	SELECT
              RESOURCE_ID,
              CATEGORY,
              RESOURCE_NUMBER,
	      SOURCE_ID,
	      OBJECT_VERSION_NUMBER,
              USER_ID,
	      SOURCE_NAME,
              USER_NAME
    	 FROM JTF_RS_RESOURCE_EXTNS_VL jres
         WHERE CATEGORY in ('EMPLOYEE','PARTY','PARTNER','SUPPLIER_CONTACT')
           AND  jres.USER_ID is not null
           AND  NOT EXISTS
                ( SELECT 'x'
                    FROM fnd_user f
	           WHERE f.user_id  = jres.user_id
                     AND decode(category,'EMPLOYEE', employee_id,'SUPPLIER_CONTACT',supplier_id,customer_id) = jres.source_id
                );

  --to update effective FND_USER user_id during the period for the resource
  CURSOR c_invalid_active_userid IS
	SELECT
              RESOURCE_ID,
              CATEGORY,
              RESOURCE_NUMBER,
	      SOURCE_ID,
	      OBJECT_VERSION_NUMBER,
              USER_ID,
	      SOURCE_NAME,
              USER_NAME
    	 FROM JTF_RS_RESOURCE_EXTNS_VL jres
         WHERE CATEGORY in ('EMPLOYEE','PARTY','PARTNER','SUPPLIER_CONTACT')
           AND USER_ID is not null
           AND trunc(nvl(END_DATE_ACTIVE,SYSDATE))  >= trunc(SYSDATE)
           AND  NOT EXISTS
                ( SELECT 'x'
                    FROM fnd_user f
	           WHERE f.user_id  = jres.user_id
                     AND decode(category,'EMPLOYEE', employee_id,'SUPPLIER_CONTACT',supplier_id,customer_id) = jres.source_id
                     AND trunc(sysdate) between trunc(start_date) and trunc(nvl(end_date,sysdate))
                );

/* Modified the below cursor due to performance resons.  Bug # 3121399
   After this change, the cost is reduced from 114,186 to 3713 in CRMAPDEV */
/*  CURSOR c_null_userid IS
   	SELECT
        	RESOURCE_ID,
                CATEGORY,
         	RESOURCE_NUMBER,
		SOURCE_ID,
        	OBJECT_VERSION_NUMBER,
	        USER_ID,
        	SOURCE_NAME,
	        USER_NAME
	 FROM   JTF_RS_RESOURCE_EXTNS_VL jres
	WHERE   CATEGORY in ('EMPLOYEE','PARTY','PARTNER','SUPPLIER_CONTACT')
	  AND   trunc(nvl(END_DATE_ACTIVE,SYSDATE))  >= trunc(SYSDATE)
	  AND   jres.USER_ID is  null
	  AND   exists (select 'x'
          	          from fnd_user f
	                 where  jres.source_id = decode(jres.category,'EMPLOYEE',
                                                     employee_id,'SUPPLIER_CONTACT',supplier_id,customer_id)
                        );
*/
  CURSOR c_null_userid IS
  SELECT
      RESOURCE_ID,
      CATEGORY,
      RESOURCE_NUMBER,
      SOURCE_ID,
      OBJECT_VERSION_NUMBER,
      USER_ID,
      SOURCE_NAME,
      USER_NAME
  FROM  JTF_RS_RESOURCE_EXTNS_VL jres
  WHERE CATEGORY = 'EMPLOYEE'
  AND   trunc(nvl(END_DATE_ACTIVE,SYSDATE))  >= trunc(SYSDATE)
  AND   jres.USER_ID is  null
  AND   exists (select 'x'
              from fnd_user f
              where  jres.source_id = employee_id)
  union all
  SELECT
      RESOURCE_ID,
      CATEGORY,
      RESOURCE_NUMBER,
      SOURCE_ID,
      OBJECT_VERSION_NUMBER,
      USER_ID,
      SOURCE_NAME,
      USER_NAME
  FROM  JTF_RS_RESOURCE_EXTNS_VL jres
  WHERE CATEGORY = 'SUPPLIER_CONTACT'
  AND   trunc(nvl(END_DATE_ACTIVE,SYSDATE))  >= trunc(SYSDATE)
  AND   jres.USER_ID is  null
  AND   exists (select 'x'
              from fnd_user f
              where  jres.source_id = supplier_id)
  union all
  SELECT
      RESOURCE_ID,
      CATEGORY,
      RESOURCE_NUMBER,
      SOURCE_ID,
      OBJECT_VERSION_NUMBER,
      USER_ID,
      SOURCE_NAME,
      USER_NAME
  FROM  JTF_RS_RESOURCE_EXTNS_VL jres
  WHERE CATEGORY in ('PARTY','PARTNER')
  AND   trunc(nvl(END_DATE_ACTIVE,SYSDATE))  >= trunc(SYSDATE)
  AND   jres.USER_ID is  null
  AND   exists (select 'x'
              from fnd_user f
              where  jres.source_id = customer_id);

  CURSOR c_party_partner(p_source_id IN jtf_rs_resource_extns.source_id%TYPE) IS
  	SELECT user_id,
               user_name
	  FROM fnd_user
	 WHERE customer_id = p_source_id
           AND trunc(sysdate) BETWEEN trunc(start_date) AND trunc(nvl(end_date,sysdate));

  CURSOR c_supp_contact(p_source_id IN jtf_rs_resource_extns.source_id%TYPE) is
         SELECT user_id,
                user_name
	   FROM fnd_user
          WHERE supplier_id = p_source_id
            AND trunc(sysdate) BETWEEN trunc(start_date) AND trunc(nvl(end_date,sysdate));

  CURSOR c_emp(p_source_id IN jtf_rs_resource_extns.source_id%TYPE) is
         SELECT user_id,
                user_name
	   FROM fnd_user
          WHERE employee_id = p_source_id
            AND trunc(sysdate) BETWEEN trunc(start_date) AND trunc(nvl(end_date,sysdate));

  l_user_id         fnd_user.user_id%type   := NULL;
  l_user_name       fnd_user.user_name%type := NULL;
  l_count           number;
  i                 number;

  BEGIN
     SAVEPOINT UPDATE_USERID_SP;
     l_return_status := fnd_api.g_ret_sts_success;
     l_count := 1;

     FOR  l_c_invalid_userid  IN  c_invalid_userid
     LOOP
           l_user_id   := NULL;
           l_user_name := NULL;

           IF l_c_invalid_userid.category ='EMPLOYEE' then
              OPEN c_emp(l_c_invalid_userid.source_id);
              FETCH c_emp INTO l_user_id, l_user_name;
              CLOSE c_emp;
           ELSIF l_c_invalid_userid.category ='SUPPLIER_CONTACT' then
              OPEN  c_supp_contact(l_c_invalid_userid.source_id);
              FETCH c_supp_contact INTO l_user_id, l_user_name;
              CLOSE c_supp_contact;
           ELSE
              OPEN  c_party_partner(l_c_invalid_userid.source_id);
              FETCH c_party_partner INTO l_user_id, l_user_name;
              CLOSE c_party_partner;
           END IF;

           l_return_status := fnd_api.g_ret_sts_success;

           jtf_rs_resource_pub.update_resource
                   (p_api_version => 1.0,
                    p_init_msg_list => FND_API.G_TRUE,
                    p_resource_id => l_c_invalid_userid.resource_id,
                    p_resource_number => l_c_invalid_userid.resource_number,
                    p_user_id => l_user_id,
                    p_source_name => l_c_invalid_userid.source_name,
                    p_object_version_num => l_c_invalid_userid.object_version_number,
                    p_user_name => l_user_name,
                    x_return_status => l_return_status,
                    x_msg_count => l_msg_count,
                    x_msg_data => l_msg_data
                    ) ;

          IF ( l_return_status <> fnd_api.g_ret_sts_success)
          THEN
            fnd_message.set_name('JTF', 'JTF_RS_CONC_UPDATE_USERID_ERR');
            fnd_message.set_token('P_SOURCE_ID',  l_c_invalid_userid.source_id);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            FOR i IN 1..l_msg_count
              LOOP
                 fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                         p_encoded => fnd_api.g_false)));
              END LOOP;
          END IF;

          l_count := l_count + 1;
          IF (l_count > 1000)
          THEN
            COMMIT;
            l_count := 1;
          END IF;
     END LOOP;

     FOR  l_c_invalid_active_userid  IN  c_invalid_active_userid
     LOOP
           l_user_id   := NULL;
           l_user_name := NULL;

           IF l_c_invalid_active_userid.category ='EMPLOYEE' then
              OPEN c_emp(l_c_invalid_active_userid.source_id);
              FETCH c_emp INTO l_user_id, l_user_name;
              CLOSE c_emp;
           ELSIF l_c_invalid_active_userid.category ='SUPPLIER_CONTACT' then
              OPEN  c_supp_contact(l_c_invalid_active_userid.source_id);
              FETCH c_supp_contact INTO l_user_id, l_user_name;
              CLOSE c_supp_contact;
           ELSE
              OPEN  c_party_partner(l_c_invalid_active_userid.source_id);
              FETCH c_party_partner INTO l_user_id, l_user_name;
              CLOSE c_party_partner;
           END IF;

           l_return_status := fnd_api.g_ret_sts_success;

           jtf_rs_resource_pub.update_resource
                   (p_api_version => 1.0,
                    p_init_msg_list => FND_API.G_TRUE,
                    p_resource_id => l_c_invalid_active_userid.resource_id,
                    p_resource_number => l_c_invalid_active_userid.resource_number,
                    p_user_id => l_user_id,
                    p_source_name => l_c_invalid_active_userid.source_name,
                    p_object_version_num => l_c_invalid_active_userid.object_version_number,
                    p_user_name => l_user_name,
                    x_return_status => l_return_status,
                    x_msg_count => l_msg_count,
                    x_msg_data => l_msg_data
                    ) ;

          IF ( l_return_status <> fnd_api.g_ret_sts_success)
          THEN
            fnd_message.set_name('JTF', 'JTF_RS_CONC_UPDATE_USERID_ERR');
            fnd_message.set_token('P_SOURCE_ID',  l_c_invalid_active_userid.source_id);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            FOR i IN 1..l_msg_count
              LOOP
                 fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                         p_encoded => fnd_api.g_false)));
              END LOOP;
          END IF;

          l_count := l_count + 1;
          IF (l_count > 1000)
          THEN
            COMMIT;
            l_count := 1;
          END IF;
     END LOOP;

     FOR  l_c_null_userid  IN  c_null_userid
       LOOP
          l_user_id   := NULL;
          l_user_name := NULL;

          IF l_c_null_userid.category ='EMPLOYEE' then
             OPEN c_emp(l_c_null_userid.source_id);
             FETCH c_emp INTO l_user_id, l_user_name;
             CLOSE c_emp;
          ELSIF l_c_null_userid.category ='SUPPLIER_CONTACT' then
             OPEN  c_supp_contact(l_c_null_userid.source_id);
             FETCH c_supp_contact INTO l_user_id, l_user_name;
             CLOSE c_supp_contact;
          ELSE
             OPEN  c_party_partner(l_c_null_userid.source_id);
             FETCH c_party_partner INTO l_user_id, l_user_name;
             CLOSE c_party_partner;
          END IF;

          l_return_status := fnd_api.g_ret_sts_success;

          jtf_rs_resource_pub.update_resource
                  (p_api_version => 1.0,
                   p_init_msg_list => FND_API.G_TRUE,
                   p_resource_id => l_c_null_userid.resource_id,
                   p_resource_number => l_c_null_userid.resource_number,
                   p_user_id => l_user_id,
                   p_source_name => l_c_null_userid.source_name,
                   p_object_version_num => l_c_null_userid.object_version_number,
                   p_user_name => l_user_name,
                   x_return_status => l_return_status,
                   x_msg_count => l_msg_count,
                   x_msg_data => l_msg_data
                    ) ;
          IF ( l_return_status <> fnd_api.g_ret_sts_success)
          THEN
            fnd_message.set_name('JTF', 'JTF_RS_CONC_UPDATE_USERID_ERR');
            fnd_message.set_token('P_SOURCE_ID',  l_c_null_userid.source_id);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            FOR i IN 1..l_msg_count
              LOOP
                 fnd_file.put_line(fnd_file.log, (fnd_msg_pub.get(i,
                                         p_encoded => fnd_api.g_false)));
              END LOOP;
          END IF;

          l_count := l_count + 1;
          IF (l_count > 1000)
          THEN
            COMMIT;
            l_count := 1;
          END IF;
    END LOOP;

  FND_MSG_PUB.count_and_get (p_count => l_msg_count, p_data => l_msg_data);
  COMMIT;

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO UPDATE_USERID_SP;
    WHEN OTHERS
    THEN
      fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      ROLLBACK TO UPDATE_USERID_SP;
      fnd_file.put_line(fnd_file.log, sqlerrm);
  END  update_userid;


  PROCEDURE  synchronize_user_name
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2,
   P_SYNCHRONIZE             IN  VARCHAR2 DEFAULT 'Both'
   )
  IS
  BEGIN

    IF (P_SYNCHRONIZE = 'User Name' OR P_SYNCHRONIZE = 'Both')
    THEN
        jtf_rs_conc_res_pub.update_username;
    END IF;

    IF (P_SYNCHRONIZE = 'User Identifier' OR P_SYNCHRONIZE = 'Both')
    THEN
      jtf_rs_conc_res_pub.update_userid;
    END IF;

    COMMIT;
  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
        fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
    WHEN OTHERS
    THEN
        fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
  END synchronize_user_name;

END jtf_rs_conc_res_pub;

/
