--------------------------------------------------------
--  DDL for Package Body JTF_RS_IMP_RES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_IMP_RES_PVT" AS
  /* $Header: jtfrsvub.pls 120.6 2006/05/05 11:55:27 nsinghai ship $ */

  G_PKG_NAME         CONSTANT VARCHAR2(30) := 'JTF_RS_IMP_RES_PVT';

  PROCEDURE import_resources(
   P_API_VERSION     IN   NUMBER,
   P_INIT_MSG_LIST   IN   VARCHAR2,
   P_COMMIT          IN   VARCHAR2,
   P_IMP_RES_TBL     IN   imp_tbl_type,
   X_RES_ID_TBL      OUT NOCOPY  res_id_tbl_type,
   X_TRANSACTION_NUM OUT NOCOPY  NUMBER,
   X_RETURN_STATUS   OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT       OUT NOCOPY  NUMBER,
   X_MSG_DATA        OUT NOCOPY  VARCHAR2
  )
  IS

    l_api_version        CONSTANT NUMBER := 1.0;
    l_api_name           CONSTANT VARCHAR2(30) := 'IMPORT_RESOURCES';

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_transaction_number  jtf_rs_resource_extns.transaction_number%TYPE;
    l_salesrep_id         jtf_rs_salesreps.salesrep_id%TYPE;

    l_address1            jtf_rs_resource_extns.source_address1%TYPE;
    l_address2            jtf_rs_resource_extns.source_address2%TYPE;
    l_address3            jtf_rs_resource_extns.source_address3%TYPE;
    l_address4            jtf_rs_resource_extns.source_address4%TYPE;
    l_city                jtf_rs_resource_extns.source_city%TYPE;
    l_postal_code         jtf_rs_resource_extns.source_postal_code%TYPE;
    l_state               jtf_rs_resource_extns.source_state%TYPE;
    l_province            jtf_rs_resource_extns.source_province%TYPE;
    l_county              jtf_rs_resource_extns.source_county%TYPE;
    l_country             jtf_rs_resource_extns.source_country%TYPE;

    l_managing_emp_id     jtf_rs_resource_extns.managing_employee_id%TYPE ;
    l_resource_id         jtf_rs_resource_extns.resource_id%TYPE ;
    l_resource_number     jtf_rs_resource_extns.resource_number%TYPE ;
    l_role_relate_id      jtf_rs_role_relations.role_relate_id%TYPE;

    l_source_number       jtf_rs_resource_extns.source_number%TYPE;
    l_assignment_type     per_all_assignments_f.assignment_type%TYPE;

    -- fetching the role_type_code in this cursor also so that if salesrep is not created then
    -- do not create roles of type SALES_COMP -- bug 3579147
    -- new cursor added (repuri 04/07/03)
    CURSOR c_job_roles (l_job_id jtf_rs_job_roles.job_id%type) IS
      SELECT a.role_id, b.role_type_code
      FROM jtf_rs_job_roles a,
           jtf_rs_roles_b b
      WHERE a.job_id = l_job_id
        AND a.role_id = b.role_id ;

    CURSOR emp_cur(l_person_id NUMBER) IS
      SELECT
         ppl.employee_number       employee_num
        ,ppl.npw_number
        ,ppl.full_name
        ,ppl.first_name
        ,ppl.middle_names          middle_name
        ,ppl.last_name
        ,ppl.work_telephone
        ,ppl.email_address
        ,ppl.person_id
        ,job.job_id
        ,job.name                  job_title
        ,ppl.business_group_id     org_id
        ,org.name                  org_name
        ,loc.address_line_1        address1
        ,loc.address_line_2        address2
        ,loc.address_line_3        address3
        ,loc.town_or_city          city
        ,loc.country               country
        ,loc.postal_code           postal_code
        ,asg.location_id           address_id
        ,asg.supervisor_id         mgr_id
        ,emp.full_name             mgr_name
        ,asg.assignment_id         assignment_id
        ,asg.assignment_type
        ,ppl.office_number
        ,ppl.internal_location
        ,ppl.mailstop
      FROM
         per_all_people_f          ppl
        ,hr_all_organization_units org
        ,per_assignments_f         asg
        ,per_jobs                  job
        ,hr_locations_all          loc  -- Changed to hr_locations_all for performance fix bug # 4956645
--        ,per_all_people_f          pep removed the table since we can get the work_telephone from ppl
        ,per_all_people_f          emp
      WHERE  ppl.person_id = l_person_id
      AND  trunc(sysdate) between trunc(ppl.effective_start_date) and trunc(ppl.effective_end_date)
--        AND  ppl.employee_number is not null
        AND  (ppl.current_employee_flag = 'Y' OR ppl.current_npw_flag = 'Y')
        AND  ppl.business_group_id = org.organization_id
        AND  ppl.person_id      = asg.person_id
        AND  asg.primary_flag = 'Y'
--        AND  asg.assignment_type = 'E'
        AND  asg.assignment_type in ('E','C')
        AND  trunc(sysdate) between asg.effective_start_date and asg.effective_end_date
        AND  asg.job_id  = job.job_id (+)
        AND  asg.location_id = loc.location_id(+)
--        AND  ppl.person_id = pep.person_id
--        AND  trunc(sysdate) between pep.effective_start_date and pep.effective_end_date
--        AND  pep.employee_number is not null
        AND  asg.supervisor_id = emp.person_id (+)
        AND  trunc(sysdate) between emp.effective_start_date(+) and emp.effective_end_date(+);


    emp_rec emp_cur%rowtype;


     CURSOR future_emp_cur(l_person_id NUMBER) IS
      SELECT
         ppl.employee_number       employee_num
        ,ppl.npw_number
        ,ppl.full_name
        ,ppl.first_name
        ,ppl.middle_names          middle_name
        ,ppl.last_name
        ,ppl.work_telephone
        ,ppl.email_address
        ,ppl.person_id
        ,job.job_id
        ,job.name                  job_title
        ,ppl.business_group_id     org_id
        ,org.name                  org_name
        ,loc.address_line_1        address1
        ,loc.address_line_2        address2
        ,loc.address_line_3        address3
        ,loc.town_or_city          city
        ,loc.country               country
        ,loc.postal_code           postal_code
        ,asg.location_id           address_id
        ,asg.supervisor_id         mgr_id
        ,emp.full_name             mgr_name
        ,asg.assignment_id         assignment_id
        ,asg.assignment_type
        ,ppl.office_number
        ,ppl.internal_location
        ,ppl.mailstop
      FROM
         per_all_people_f          ppl
        ,hr_all_organization_units org
        ,per_assignments_f         asg
        ,per_jobs                  job
        ,hr_locations_all          loc -- Changed to hr_locations_all for performance fix bug # 4956645
--        ,per_all_people_f          pep removed the table since we can get the work_telephone from ppl
        ,per_all_people_f          emp
      WHERE  ppl.person_id = l_person_id
--        AND  trunc(sysdate) between trunc(ppl.effective_start_date) and trunc(ppl.effective_end_date)
-- Enh 3947611 2-dec-2004:changed the date check for future dated employees.
        AND  trunc(sysdate)  <= trunc(ppl.effective_end_date)
--        AND  ppl.employee_number is not null
        AND  (ppl.current_employee_flag = 'Y' OR ppl.current_npw_flag = 'Y')
        AND  ppl.business_group_id = org.organization_id
        AND  ppl.person_id      = asg.person_id
        AND  asg.primary_flag = 'Y'
--        AND  asg.assignment_type = 'E'
        AND  asg.assignment_type in ('E','C')
--        AND  trunc(sysdate) between asg.effective_start_date and asg.effective_end_date
-- Enh 3947611 2-dec-2004: changed the date check for future dated employees.
        AND  trunc(sysdate) <=  asg.effective_end_date
        AND  asg.job_id  = job.job_id (+)
        AND  asg.location_id = loc.location_id(+)
--        AND  ppl.person_id = pep.person_id
--        AND  trunc(sysdate) between pep.effective_start_date and pep.effective_end_date
--        AND  pep.employee_number is not null
        AND  asg.supervisor_id = emp.person_id (+)
--   AND  trunc(sysdate) between emp.effective_start_date(+) and emp.effective_end_date(+)
-- Enh 3947611 2-dec-2004:changed the date check for future dated employees who may have future dated employees
-- as manager.
        AND  trunc(sysdate) <=  emp.effective_end_date (+);

    future_emp_rec emp_cur%rowtype;

    -- Cursor to get the Effective Start Date, for a given Job Assignment of an Employee.

    CURSOR c_get_asg_start_date (l_job_id IN NUMBER, l_person_id IN NUMBER, l_assignment_id NUMBER, l_assignment_type IN VARCHAR2) IS
      SELECT EFFECTIVE_START_DATE
      FROM   PER_all_assignments_f
      WHERE  person_id = l_person_id
      AND    ASSIGNMENT_TYPE = l_assignment_type
      AND    PRIMARY_FLAG = 'Y'
      AND    job_id = l_job_id
      AND    assignment_id = l_assignment_id
      ORDER BY EFFECTIVE_START_DATE asc;

    l_asg_start_date    DATE;

    CURSOR phone_cur(l_person_id NUMBER) IS
      SELECT phone_number
        FROM per_phones per
       WHERE parent_table = 'PER_ALL_PEOPLE_F'
         AND parent_id = l_person_id
         AND phone_type = 'W1'
         AND  date_from  = (SELECT MAX(date_from)
                              FROM per_phones p2
                            WHERE  parent_table = 'PER_ALL_PEOPLE_F'
                              AND  parent_id    = l_person_id
                              AND  phone_type   = 'W1' );

    phone_rec phone_cur%rowtype;

    -- Adding the cursors for mobile and pager (repuri 10/16/01)

    CURSOR mobile_cur(l_person_id NUMBER) IS
      SELECT phone_number
        FROM per_phones per
       WHERE parent_table = 'PER_ALL_PEOPLE_F'
         and parent_id = l_person_id
         and phone_type = 'M'
         and  date_from  = (SELECT MAX(date_from)
                              FROM per_phones p2
                             WHERE parent_table = 'PER_ALL_PEOPLE_F'
                               AND parent_id    = l_person_id
                               AND phone_type   = 'M' );

    mobile_rec mobile_cur%rowtype;

    CURSOR pager_cur(l_person_id NUMBER) IS
      SELECT phone_number
        FROM per_phones per
       WHERE parent_table = 'PER_ALL_PEOPLE_F'
         and parent_id = l_person_id
         and phone_type = 'P'
         and  date_from  = (SELECT MAX(date_from)
                              FROM per_phones p2
                             WHERE parent_table = 'PER_ALL_PEOPLE_F'
                               AND parent_id    = l_person_id
                               AND phone_type   = 'P' );

    pager_rec pager_cur%rowtype;

    CURSOR par_cur(l_person_id NUMBER) IS
    SELECT PARTY.PARTY_NUMBER,
           PARTY.PARTY_NAME,
           PARTY.EMAIL_ADDRESS,
           PARTY.ADDRESS1,
           PARTY.ADDRESS2,
           PARTY.ADDRESS3,
           PARTY.ADDRESS4,
           PARTY.CITY,
           PARTY.POSTAL_CODE,
           PARTY.STATE,
           PARTY.PROVINCE,
           PARTY.COUNTY,
           PARTY.COUNTRY,
           CT_POINT1.PHONE_AREA_CODE||CT_POINT1.PHONE_NUMBER PHONE,
           TO_NUMBER(NULL) ORG_ID,
           NULL             ORG_NAME,
           PARTY.PERSON_FIRST_NAME,
           PARTY.PERSON_MIDDLE_NAME,
           PARTY.PERSON_LAST_NAME
    FROM   HZ_PARTIES PARTY,
           HZ_CONTACT_POINTS CT_POINT1
    WHERE  PARTY.PARTY_ID = l_person_id
      AND  PARTY.PARTY_TYPE NOT IN ('ORGANIZATION', 'GROUP')
      AND  CT_POINT1.OWNER_TABLE_NAME   (+) = 'HZ_PARTIES'
      AND  CT_POINT1.OWNER_TABLE_ID     (+) = PARTY.PARTY_ID
      AND  CT_POINT1.PRIMARY_FLAG       (+) = 'Y'
      AND  CT_POINT1.STATUS             (+) = 'A'
      AND  CT_POINT1.CONTACT_POINT_TYPE (+) = 'PHONE';

    party_rec par_cur%rowtype;

   -- cursor for party contact
     CURSOR party_contact_cur(l_party_id IN NUMBER)
         IS
     SELECT hzoc.org_contact_id CONTACT_ID
       FROM hz_relationships hzr,
            hz_org_contacts hzoc
      WHERE hzr.party_id =  l_party_id
        AND hzr.directional_flag = 'F'
        AND hzr.relationship_code = 'EMPLOYEE_OF'
        AND hzr.subject_table_name ='HZ_PARTIES'
        AND hzr.object_table_name ='HZ_PARTIES'
        AND hzr.start_date <= SYSDATE
        AND (hzr.end_date is null or hzr.end_date > SYSDATE)
        AND hzr.status = 'A'
        AND hzoc.PARTY_RELATIONSHIP_ID = hzr.relationship_id;

   party_contact_rec party_contact_cur%rowtype;

    CURSOR partner_cur(l_person_id NUMBER) IS
    SELECT PARTY.PARTY_NUMBER,
           PARTY.PARTY_NAME,
           PARTY.EMAIL_ADDRESS,
           PARTY.ADDRESS1,
           PARTY.ADDRESS2,
           PARTY.ADDRESS3,
           PARTY.ADDRESS4,
           PARTY.CITY,
           PARTY.POSTAL_CODE,
           PARTY.STATE,
           PARTY.PROVINCE,
           PARTY.COUNTY,
           PARTY.COUNTRY,
           CT_POINT1.PHONE_AREA_CODE||CT_POINT1.PHONE_NUMBER PHONE,
           REL.OBJECT_ID ORG_ID,
           PARTY.PARTY_NAME             ORG_NAME,
           PARTY.PERSON_FIRST_NAME,
           PARTY.PERSON_MIDDLE_NAME,
           PARTY.PERSON_LAST_NAME
    FROM   HZ_PARTIES PARTY,
           HZ_CONTACT_POINTS CT_POINT1,
--         HZ_PARTY_RELATIONSHIPS REL
           HZ_RELATIONSHIPS REL
    WHERE  PARTY.PARTY_ID = l_person_id
      AND  (
            ( PARTY.PARTY_TYPE = 'ORGANIZATION'
              AND
              PARTY.PARTY_ID = REL.SUBJECT_ID
            )
            OR
           ( PARTY.PARTY_TYPE = 'PARTY_REALTIONSHIP'
             AND
             PARTY.PARTY_ID = REL.PARTY_ID
            )
           )
--    AND REL.PARTY_RELATIONSHIP_TYPE IN ('PARTNER_OF', 'VAD_OF', 'THIRD_PARTY_OF')
--
      AND REL.RELATIONSHIP_CODE IN
           ('PARTNER_OF', 'VAD_OF', 'VAD_VENDOR_OF',
            'THIRD_PARTY_FOR', 'INDIRECTLY_MANAGES_CUSTOMER', 'CUSTOMER_INDIRECTLY_MANAGED_BY')
      AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
      AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
      AND REL.DIRECTIONAL_FLAG = 'F'
      AND REL.STATUS = 'A'
      AND PARTY.STATUS = 'A'
--
      AND  CT_POINT1.OWNER_TABLE_NAME (+) = 'HZ_PARTIES'
      AND  CT_POINT1.OWNER_TABLE_ID   (+) = PARTY.PARTY_ID
      AND  CT_POINT1.PRIMARY_FLAG      (+) = 'Y'
      AND  CT_POINT1.STATUS            (+) = 'A'
      AND  CT_POINT1.CONTACT_POINT_TYPE (+) = 'PHONE';

    partner_rec partner_cur%rowtype;

    CURSOR partner_add_cur(l_address_id NUMBER) IS
    SELECT LOC.ADDRESS1,
           LOC.ADDRESS2,
           LOC.ADDRESS3,
           LOC.ADDRESS4,
           LOC.CITY,
           LOC.POSTAL_CODE,
           LOC.STATE,
           LOC.PROVINCE,
           LOC.COUNTY,
           LOC.COUNTRY
     FROM  HZ_PARTY_SITES SITE,
           HZ_LOCATIONS LOC
    WHERE  SITE.PARTY_SITE_ID = l_address_id
      AND  SITE.LOCATION_ID   = LOC.LOCATION_ID;

    partner_add_rec partner_add_cur%rowtype;

   /* -- Modified cursor to go against AP tables below (as per AP teams reccomendation)
      -- Fix for SQL rep perf bug 5025410 on 05-May-2006
    CURSOR supp_cont_cur(l_person_id NUMBER) IS
    SELECT p.segment1 ,
           s.address_line1 ,
           s.address_line2 ,
           s.address_line3  ,
           s.CITY,
           s.STATE,
           s.PROVINCE,
           s.COUNTY,
           s.COUNTRY,
           c.area_code ||' '|| c.phone  phone,
           s.zip,
           s.org_id ,
           o.name  ,
           c.FIRST_NAME,
           c.MIDDLE_NAME,
           c.last_name
    FROM   PO_VENDORS   P,
           po_vendor_contacts c,
           po_vendor_sites_all s,
           hr_operating_units o
    WHERE  c.vendor_contact_id  = l_person_id
      and  c.vendor_site_id     = s.vendor_site_id
      and  s.vendor_id          = p.vendor_id
      and  s.org_id             = o.organization_id;
    */

    CURSOR supp_cont_cur(l_person_id NUMBER) IS
     SELECT p.segment1 ,
            s.address_line1 ,
            s.address_line2 ,
            s.address_line3  ,
            s.CITY,
            s.STATE,
            s.PROVINCE,
            s.COUNTY,
            s.COUNTRY,
            rel.primary_phone_area_code ||' '|| rel.primary_phone_number  phone,
            s.zip,
            s.org_id ,
            o.name  ,
            per.person_FIRST_NAME first_name,
            per.person_MIDDLE_NAME middle_name,
            per.person_last_name last_name
     FROM   ap_suppliers   P,
            ap_supplier_contacts c,
            ap_supplier_sites_all s,
            hr_all_organization_units o,
            hz_parties per,
            hz_parties rel
     WHERE  c.vendor_contact_id  = l_person_id
       and  c.vendor_site_id     = s.vendor_site_id
       and  c.org_party_site_id  = s.party_site_id
       and  per.party_id         = c.per_party_id
       and  rel.party_id         = c.rel_party_id
       and  s.vendor_id          = p.vendor_id
       and  s.org_id             = o.organization_id;

    supp_cont_rec     supp_cont_cur%rowtype;

    i      NUMBER;

  BEGIN

    SAVEPOINT import_resources;
    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initializing the transaction number
    l_transaction_number := null;

    IF p_imp_res_tbl.COUNT > 0 THEN
      i := p_imp_res_tbl.FIRST;
      LOOP

      x_res_id_tbl(i).res_id := p_imp_res_tbl(i).resource_id;

        IF (p_imp_res_tbl(i).selected = 'Y') THEN
          IF (p_imp_res_tbl(i).comment_code = 'ROLE') THEN
            --if resource with same role does not exist
            IF(p_imp_res_tbl(i).role_id IS NOT NULL) THEN
              JTF_RS_ROLE_RELATE_PVT.CREATE_RESOURCE_ROLE_RELATE(
                p_api_version         => 1.0,
                p_init_msg_list       => null,
                p_commit              => null,
                p_role_resource_type  => 'RS_INDIVIDUAL',
                p_role_resource_id    => p_imp_res_tbl(i).resource_id,
                p_role_id             => p_imp_res_tbl(i).role_id,
                p_start_date_active   => p_imp_res_tbl(i).role_start_date_active,
                p_end_date_active     => p_imp_res_tbl(i).role_end_date_active,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data,
                x_role_relate_id      => l_role_relate_id
              );

              IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;
          ELSIF (p_imp_res_tbl(i).comment_code = 'NEW') THEN
            --if resource does not exist for the person then insert both resource
            -- Bug 	3086823 : Transaction number should be created once for the entire set of records
            IF l_transaction_number is null
            THEN
               SELECT jtf_rs_transaction_num_s.nextval
               INTO l_transaction_number
               FROM  dual;
            END IF;

            x_transaction_num := l_transaction_number;

             --if category is employee then fetch all the denormalized columns
            IF (p_imp_res_tbl(i).category = 'EMPLOYEE') THEN
              open emp_cur(p_imp_res_tbl(i).person_id);
              fetch emp_cur INTO emp_rec;
              IF emp_cur%NOTFOUND THEN
                open future_emp_cur(p_imp_res_tbl(i).person_id);
                fetch future_emp_cur INTO emp_rec;
                close future_emp_cur;
              END IF;
              close emp_cur;


              if emp_rec.assignment_type = 'E' then
                 l_source_number := emp_rec.employee_num;
                 l_assignment_type := 'E';
              else
                 l_source_number := emp_rec.npw_number;
                 l_assignment_type := 'C';
              end if;

              open phone_cur(p_imp_res_tbl(i).person_id);
              fetch phone_cur INTO phone_rec;
              close phone_cur;

              -- Adding the parts for mobile and pager (repuri 10/16/01)

              open mobile_cur(p_imp_res_tbl(i).person_id);
              fetch mobile_cur INTO mobile_rec;
              close mobile_cur;

              open pager_cur(p_imp_res_tbl(i).person_id);
              fetch pager_cur INTO pager_rec;
              close pager_cur;

              --insert into jtf resource extn by calling the public api
              JTF_RS_RESOURCE_PUB.CREATE_RESOURCE(
                p_api_version              => 1.0,
                p_init_msg_list            => null,
                p_commit                   => null,
                p_category                 => p_imp_res_tbl(i).category,
                p_source_id                => p_imp_res_tbl(i).person_id,
                p_address_id               => emp_rec.address_id,
                p_contact_id               => p_imp_res_tbl(i).contact_id,
                p_managing_emp_id          => l_managing_emp_id,
                p_start_date_active        => p_imp_res_tbl(i).rs_start_date_active,
                p_end_date_active          => p_imp_res_tbl(i).rs_end_date_active,
                p_transaction_number       => l_transaction_number,
                p_user_id                  => p_imp_res_tbl(i).user_id,
                x_return_status            => l_return_status,
                x_msg_count                => l_msg_count,
                x_msg_data                 => l_msg_data,
                x_resource_id              => l_resource_id,
                x_resource_number          => l_resource_number,
                p_source_name              => p_imp_res_tbl(i).name,
                p_resource_name            => p_imp_res_tbl(i).name,
                p_source_number            => l_source_number,
                p_source_phone             => phone_rec.phone_number,
                p_source_mobile_phone      => mobile_rec.phone_number,
                p_source_pager             => pager_rec.phone_number,
                p_source_email             => emp_rec.email_address,
                p_source_job_title         => emp_rec.job_title,
                p_source_business_grp_id   => emp_rec.org_id,
                p_source_business_grp_name => emp_rec.org_name,
                p_source_address1          => emp_rec.address1,
                p_source_address2          => emp_rec.address2,
                p_source_address3          => emp_rec.address3,
                p_source_city              => emp_rec.city,
                p_source_country           => emp_rec.country,
                p_source_postal_code       => emp_rec.postal_code,
                p_source_mgr_id            => emp_rec.mgr_id,
                p_source_mgr_name          => emp_rec.mgr_name,
                p_source_first_name        => emp_rec.first_name,
                p_source_middle_name       => emp_rec.middle_name,
                p_source_last_name         => emp_rec.last_name,
                p_source_category          => null,
                p_source_status            => null,
                p_user_name                => p_imp_res_tbl(i).user_name,
                p_source_mailstop          => emp_rec.mailstop,
                p_source_office            => emp_rec.office_number,
                p_source_location          => emp_rec.internal_location
              );
              IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              x_res_id_tbl(i).res_id := l_resource_id;

              IF (p_imp_res_tbl(i).create_salesperson = 'Y') THEN
                IF p_imp_res_tbl(i).salesperson_number IS NULL THEN
                  fnd_message.set_name('JTF','JTF_RS_NO_SRP_NUM_ENT_FOR_EMP');
                  fnd_message.set_token('P_EMP_NAME',p_imp_res_tbl(i).name);
                  fnd_msg_pub.add;
                  RAISE fnd_api.g_exc_error;
                ELSE
                  --Create a Salesperson for the Resource Created above
                  JTF_RS_SALESREPS_PUB.CREATE_SALESREP (
                    p_api_version                  => 1.0,
                    p_init_msg_list                => null,
                    p_commit                       => null,
                    p_resource_id                  => l_resource_id,
                    p_sales_credit_type_id         => p_imp_res_tbl(i).sales_credit_type_id,
                    p_salesrep_number              => p_imp_res_tbl(i).salesperson_number,
                    p_name                         => p_imp_res_tbl(i).name,
                    p_status                       => 'A',
                    p_start_date_active            => p_imp_res_tbl(i).rs_start_date_active,
                    p_end_date_active              => p_imp_res_tbl(i).rs_end_date_active,
                    p_org_id                       => p_imp_res_tbl(i).org_id,
                    p_gl_id_rev                    => null,
                    p_gl_id_freight                => null,
                    p_gl_id_rec                    => null,
                    p_set_of_books_id              => null,
                    p_email_address                => null,
                    p_wh_update_date               => null,
                    p_sales_tax_geocode            => null,
                    p_sales_tax_inside_city_limits => null,
                    x_return_status                => l_return_status,
                    x_msg_count                    => l_msg_count,
                    x_msg_data                     => l_msg_data,
                    x_salesrep_id                  => l_salesrep_id
                  );
                  IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                    RAISE fnd_api.g_exc_error;
                  END IF;
                END IF;
              END IF;

              IF (emp_rec.job_id IS NOT NULL) THEN
                -- Get the Effective Start Date for the Current Job Assignment of this Employee.
                OPEN c_get_asg_start_date (emp_rec.job_id, emp_rec.person_id, emp_rec.assignment_id, l_assignment_type);
                FETCH c_get_asg_start_date INTO l_asg_start_date;
                CLOSE c_get_asg_start_date;

                FOR j in c_job_roles(emp_rec.job_id) LOOP
                  IF(j.role_id is not null) THEN
                     -- do not create roles of type SALES_COMP if Sales Rep has not been created -- bug 3579147
                     -- to avoid Vert User Hook error , sudarsana 8th July 2004
                     IF(j.role_type_code = 'SALES_COMP' AND
                        p_imp_res_tbl(i).create_salesperson <> 'Y')
                     THEN
                         null;
                     ELSE
                        JTF_RS_ROLE_RELATE_PVT.CREATE_RESOURCE_ROLE_RELATE(
                          p_api_version         => 1.0,
                          p_init_msg_list       => null,
                          p_commit              => null,
                          p_role_resource_type  => 'RS_INDIVIDUAL',
                          p_role_resource_id    => l_resource_id,
                          p_role_id             => j.role_id,
                          p_start_date_active   => l_asg_start_date,
                          p_end_date_active     => null,
                          x_return_status       => l_return_status,
                          x_msg_count           => l_msg_count,
                          x_msg_data            => l_msg_data,
                          x_role_relate_id      => l_role_relate_id
                        );
                        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                            RAISE fnd_api.g_exc_error;
                        END IF; -- end of check for l_return_status
                      END IF; -- end of check for SALES_COMP
                    END IF; -- end of check for j.role_id
                END LOOP;
              END IF;

            ELSIF (p_imp_res_tbl(i).category = 'PARTY') THEN
              open par_cur(p_imp_res_tbl(i).person_id);
              fetch par_cur INTO party_rec;
              close par_cur;

              -- added the party_contact cursor for bug 2954064, sudarsana 2nd July 04
              open party_contact_cur(p_imp_res_tbl(i).person_id);
              fetch party_contact_cur INTO party_contact_rec;
              close party_contact_cur;

              --insert into jtf resource extn by calling the public api
              JTF_RS_RESOURCE_PUB.CREATE_RESOURCE(
                p_api_version         => 1.0,
                p_init_msg_list       => null,
                p_commit              => null,
                p_category            => p_imp_res_tbl(i).category,
                p_source_id           => p_imp_res_tbl(i).person_id,
                p_address_id          => p_imp_res_tbl(i).address_id,
               -- assigning party contact id for PARTY resource for bug 2954064 sudarsana 2nd July 04
                p_contact_id          => party_contact_rec.contact_id,   --p_imp_res_tbl(i).contact_id,
                p_managing_emp_id     => l_managing_emp_id,
                p_start_date_active   => p_imp_res_tbl(i).rs_start_date_active,
                p_end_date_active     => p_imp_res_tbl(i).rs_end_date_active,
                p_transaction_number  => l_transaction_number,
                p_user_id             => p_imp_res_tbl(i).user_id,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data,
                x_resource_id         => l_resource_id,
                x_resource_number     => l_resource_number,
                p_source_name         => p_imp_res_tbl(i).name,
                p_resource_name       => p_imp_res_tbl(i).name,
                p_source_number       => party_rec.party_number,
                p_source_phone        => party_rec.phone,
                p_source_email        => party_rec.email_address,
                p_source_job_title    => null,
                p_source_org_id       => party_rec.org_id,
                p_source_org_name     => party_rec.org_name,
                p_source_address1     => party_rec.address1,
                p_source_address2     => party_rec.address2,
                p_source_address3     => party_rec.address3,
                p_source_address4     => party_rec.address4,
                p_source_city         => party_rec.city,
                p_source_state        => party_rec.state,
                p_source_province     => party_rec.province,
                p_source_county       => party_rec.county,
                p_source_country      => party_rec.country,
                p_source_postal_code  => party_rec.postal_code,
                p_source_mgr_id       => null,
                p_source_mgr_name     => null,
                p_source_first_name   => party_rec.person_first_name,
                p_source_middle_name  => party_rec.person_middle_name,
                p_source_last_name    => party_rec.person_last_name,
                p_source_category     => null,
                p_source_status       => null,
                p_user_name           => p_imp_res_tbl(i).user_name
              );
              IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              x_res_id_tbl(i).res_id := l_resource_id;

            ELSIF (p_imp_res_tbl(i).category = 'PARTNER') THEN
              open partner_cur(p_imp_res_tbl(i).person_id);
              fetch partner_cur INTO partner_rec;
              close partner_cur;

              IF (p_imp_res_tbl(i).address_id IS NOT NULL) THEN
                open partner_add_cur(p_imp_res_tbl(i).address_id);
                fetch partner_add_cur INTO partner_add_rec;
                close partner_add_cur;
                l_address1    := partner_add_rec.address1;
                l_address2    := partner_add_rec.address2;
                l_address3    := partner_add_rec.address3;
                l_address4    := partner_add_rec.address4;
                l_city        := partner_add_rec.city;
                l_postal_code := partner_add_rec.postal_code;
                l_state       := partner_add_rec.state;
                l_province    := partner_add_rec.province;
                l_county      := partner_add_rec.county;
                l_country     := partner_add_rec.country;
              ELSE
                l_address1    := partner_rec.address1;
                l_address2    := partner_rec.address2;
                l_address3    := partner_rec.address3;
                l_address4    := partner_rec.address4;
                l_city        := partner_rec.city;
                l_postal_code := partner_rec.postal_code;
                l_state       := partner_rec.state;
                l_province    := partner_rec.province;
                l_county      := partner_rec.county;
                l_country     := partner_rec.country;
              END IF;

              --insert into jtf resource extn by calling the public api
              JTF_RS_RESOURCE_PUB.CREATE_RESOURCE(
                p_api_version         => 1.0,
                p_init_msg_list       => null,
                p_commit              => null,
                p_category            => p_imp_res_tbl(i).category,
                p_source_id           => p_imp_res_tbl(i).person_id,
                p_address_id          => p_imp_res_tbl(i).address_id,
                p_contact_id          => p_imp_res_tbl(i).contact_id,
                p_managing_emp_id     => l_managing_emp_id,
                p_start_date_active   => p_imp_res_tbl(i).rs_start_date_active,
                p_end_date_active     => p_imp_res_tbl(i).rs_end_date_active,
                p_transaction_number  => l_transaction_number,
                p_user_id             => p_imp_res_tbl(i).user_id,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data,
                x_resource_id         => l_resource_id,
                x_resource_number     => l_resource_number,
                p_source_name         => p_imp_res_tbl(i).name,
                p_resource_name       => p_imp_res_tbl(i).name,
                p_source_number       => partner_rec.party_number,
                p_source_phone        => partner_rec.phone,
                p_source_email        => partner_rec.email_address,
                p_source_job_title    => null,
                p_source_org_id       => partner_rec.org_id,
                p_source_org_name     => partner_rec.org_name,
                p_source_address1     => l_address1,
                p_source_address2     => l_address2,
                p_source_address3     => l_address3,
                p_source_address4     => l_address4,
                p_source_city         => l_city,
                p_source_state        => l_state,
                p_source_province     => l_province,
                p_source_county       => l_county,
                p_source_country      => l_country,
                p_source_postal_code  => l_postal_code,
                p_source_mgr_id       => null,
                p_source_mgr_name     => null,
                p_source_first_name   => partner_rec.person_first_name,
                p_source_middle_name  => partner_rec.person_middle_name,
                p_source_last_name    => partner_rec.person_last_name,
                p_source_category     => null,
                p_source_status       => null,
                p_user_name           => p_imp_res_tbl(i).user_name
              );
              IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              x_res_id_tbl(i).res_id := l_resource_id;

            ELSIF (p_imp_res_tbl(i).category = 'SUPPLIER_CONTACT') THEN
              open supp_cont_cur(p_imp_res_tbl(i).person_id);
              fetch supp_cont_cur into supp_cont_rec;
              close supp_cont_cur;

              --insert into jtf resource extn by calling the public api
              JTF_RS_RESOURCE_PUB.CREATE_RESOURCE(
                p_api_version         => 1.0,
                p_init_msg_list       => null,
                p_commit              => null,
                p_category            => p_imp_res_tbl(i).category,
                p_source_id           => p_imp_res_tbl(i).person_id,
                p_address_id          => p_imp_res_tbl(i).address_id,
                p_contact_id          => p_imp_res_tbl(i).contact_id,
                p_managing_emp_id     => l_managing_emp_id,
                p_start_date_active   => p_imp_res_tbl(i).rs_start_date_active,
                p_end_date_active     => p_imp_res_tbl(i).rs_end_date_active,
                p_transaction_number  => l_transaction_number,
                p_user_id             => p_imp_res_tbl(i).user_id,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data,
                x_resource_id         => l_resource_id,
                x_resource_number     => l_resource_number,
                p_source_name         => p_imp_res_tbl(i).name,
                p_resource_name       => p_imp_res_tbl(i).name,
                p_source_number       => supp_cont_rec.segment1,
                p_source_phone        => supp_cont_rec.phone,
                p_source_email        => null,
                p_source_job_title    => null,
                p_source_org_id       => supp_cont_rec.org_id,
                p_source_org_name     => supp_cont_rec.name,
                p_source_address1     => supp_cont_rec.address_line1,
                p_source_address2     => supp_cont_rec.address_line2,
                p_source_address3     => supp_cont_rec.address_line3,
                p_source_address4     => null,
                p_source_city         => supp_cont_rec.city,
                p_source_state        => supp_cont_rec.state,
                p_source_province     => supp_cont_rec.province,
                p_source_county       => supp_cont_rec.county,
                p_source_country      => supp_cont_rec.country,
                p_source_postal_code  => supp_cont_rec.zip,
                p_source_mgr_id       => null,
                p_source_mgr_name     => null,
                p_source_first_name   => supp_cont_rec.first_name,
                p_source_middle_name  => supp_cont_rec.middle_name,
                p_source_last_name    => supp_cont_rec.last_name,
                p_source_category     => null,
                p_source_status       => null,
                p_user_name           => p_imp_res_tbl(i).user_name
              );
              IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              x_res_id_tbl(i).res_id := l_resource_id;

            ELSE
              --insert into jtf resource extn by calling the public api
              JTF_RS_RESOURCE_PUB.CREATE_RESOURCE(
                p_api_version         => 1.0,
                p_init_msg_list       => null,
                p_commit              => null,
                p_category            => p_imp_res_tbl(i).category,
                p_source_id           => p_imp_res_tbl(i).person_id,
                p_address_id          => p_imp_res_tbl(i).address_id,
                p_contact_id          => p_imp_res_tbl(i).contact_id,
                p_managing_emp_id     => l_managing_emp_id,
                p_start_date_active   => p_imp_res_tbl(i).rs_start_date_active,
                p_end_date_active     => p_imp_res_tbl(i).rs_end_date_active,
                p_transaction_number  => l_transaction_number,
                p_user_id             => p_imp_res_tbl(i).user_id,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data,
                x_resource_id         => l_resource_id,
                x_resource_number     => l_resource_number,
                p_source_name         => p_imp_res_tbl(i).name,
                p_resource_name       => p_imp_res_tbl(i).name,
                p_user_name           => p_imp_res_tbl(i).user_name
              );
              IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                RAISE fnd_api.g_exc_error;
              END IF;

              x_res_id_tbl(i).res_id := l_resource_id;

            END IF;

            IF(p_imp_res_tbl(i).role_id is not null) THEN
            --insert into role relate table
              JTF_RS_ROLE_RELATE_PVT.CREATE_RESOURCE_ROLE_RELATE(
                p_api_version         => 1.0,
                p_init_msg_list       => null,
                p_commit              => null,
                p_role_resource_type  => 'RS_INDIVIDUAL',
                p_role_resource_id    => l_resource_id,
                p_role_id             => p_imp_res_tbl(i).role_id,
                p_start_date_active   => p_imp_res_tbl(i).rs_start_date_active,
                p_end_date_active     => p_imp_res_tbl(i).rs_end_date_active,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data,
                x_role_relate_id      => l_role_relate_id
              );
              IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;
          END IF;
        END IF;

        EXIT WHEN (i = p_imp_res_tbl.LAST);
        i := p_imp_res_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO import_resources;
      x_return_status := fnd_api.g_ret_sts_error;
      x_transaction_num := NULL;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO import_resources;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_transaction_num := NULL;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO import_resources;
      fnd_message.set_name ('JTF','JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_transaction_num := NULL;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);

  END import_resources;

END jtf_rs_imp_res_pvt;

/
