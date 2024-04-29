--------------------------------------------------------
--  DDL for Package Body POS_PARTY_MANAGEMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_PARTY_MANAGEMENT_PKG" as
--$Header: POSPMNGB.pls 120.9.12010000.2 2008/09/11 19:12:21 jburugul ship $

PROCEDURE classify_party
  ( p_party_id           IN  NUMBER
  , p_category           IN  VARCHAR2
  , p_code               IN  VARCHAR2
  , p_primary_flag       IN  VARCHAR2
  , x_code_assignment_id OUT NOCOPY NUMBER
  , x_status             OUT NOCOPY VARCHAR2
  , x_exception_msg      OUT NOCOPY VARCHAR2
  )
IS
   l_return_status VARCHAR2(1);
   l_msg_count     NUMBER;
   l_msg_data      VARCHAR2(3000);
   l_number        NUMBER;

   l_code_assignment_rec hz_classification_v2pub.code_assignment_rec_type;

   CURSOR l_cur IS
      SELECT code_assignment_id
        FROM hz_code_assignments
       WHERE owner_table_name = 'HZ_PARTIES'
         AND owner_table_id = p_party_id
         AND class_category = p_category
         AND class_code     = p_code
         AND status = 'A'
         AND (end_date_active is null or end_date_active > sysdate);

BEGIN
    --fnd_client_info.set_org_context('-3113');
    OPEN l_cur;
    FETCH l_cur INTO x_code_assignment_id;
    IF l_cur%found THEN
       CLOSE l_cur;
       x_status := fnd_api.g_ret_sts_success;
       RETURN;
    END IF;
    CLOSE l_cur;

    l_code_assignment_rec.owner_table_name    := 'HZ_PARTIES';
    l_code_assignment_rec.owner_table_id      := p_party_id;
    l_code_assignment_rec.class_category      := p_category;
    l_code_assignment_rec.class_code          := p_code;
    l_code_assignment_rec.primary_flag        := p_primary_flag;
    l_code_assignment_rec.content_source_type := 'USER_ENTERED';
    l_code_assignment_rec.start_date_active   := Sysdate;
    l_code_assignment_rec.status              := 'A';
    l_code_assignment_rec.created_by_module   := 'POS_SUPPLIER_MGMT';
    l_code_assignment_rec.application_id      := 177;

    hz_classification_v2pub.create_code_assignment
      ( FND_API.G_FALSE,
        l_code_assignment_rec,
        l_return_status,
        l_msg_count,
        l_msg_data,
        x_code_assignment_id
    );

    pos_log.log_call_result
      ( p_module        => 'POSPMNGB',
        p_prefix        => 'in classify_party',
        p_return_status => l_return_status,
        p_msg_count     => l_msg_count,
        p_msg_data      => l_msg_data
        );

    x_status := l_return_status;
    IF l_msg_count = 1 THEN
       x_exception_msg := l_msg_data;
     ELSIF l_msg_count > 1 THEN
       pos_log.combine_fnd_msg(l_msg_count, x_exception_msg);
    END IF;
END classify_party;

PROCEDURE classify_party
  ( p_party_id      IN  NUMBER
  , p_category      IN  VARCHAR2
  , p_code          IN  VARCHAR2
  , x_status        OUT NOCOPY VARCHAR2
  , x_exception_msg OUT NOCOPY VARCHAR2
  )
  IS
     l_code_assignment_id number;
BEGIN

   classify_party
     (p_party_id,
      p_category,
      p_code,
      'Y',
      l_code_assignment_id ,
      x_status,
      x_exception_msg
      );

END classify_party;

PROCEDURE pos_create_organization
  (p_organization_name   IN  VARCHAR2,
   p_duns_number         IN  NUMBER   DEFAULT NULL,
   p_corp_hq_flag        IN  VARCHAR2 DEFAULT NULL,
   p_sic_code            IN  VARCHAR2 DEFAULT NULL,
   x_org_party_id        OUT NOCOPY NUMBER,
   x_org_party_number    OUT NOCOPY VARCHAR2,
   x_profile_id          OUT NOCOPY NUMBER,
   x_exception_msg       OUT NOCOPY VARCHAR2,
   x_status              OUT NOCOPY VARCHAR2
   )
  IS
     l_org_rec       hz_party_v2pub.organization_rec_type;
     l_return_status VARCHAR2(1);
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(3000);

/* Added for bug 7366321 */
   l_hzprofile_value   varchar2(20);
   l_hzprofile_changed varchar2(1) := 'N';
/* End */

BEGIN
/* Added for bug 7366321 */
    l_hzprofile_value := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');
    if nvl(l_hzprofile_value, 'Y') = 'N' then
      fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'Y');
      l_hzprofile_changed := 'Y';
    end if;
/* End */
 /*  commented for bug 7366321
   fnd_profile.put('HZ_GENERATE_PARTY_NUMBER','Y');
*/
   l_org_rec.organization_name := p_organization_name;
   l_org_rec.duns_number_c     := p_duns_number;
   l_org_rec.hq_branch_ind     := p_corp_hq_flag;
   l_org_rec.sic_code          := p_sic_code;
   l_org_rec.created_by_module := 'POS_SUPPLIER_MGMT';

   hz_party_v2pub.create_organization
     (p_init_msg_list    => fnd_api.g_false,
      p_organization_rec => l_org_rec,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      x_party_id         => x_org_party_id,
      x_party_number     => x_org_party_number,
      x_profile_id       => x_profile_id
      );
/* Added for bug 7366321 */
     if nvl(l_hzprofile_changed,'N') = 'Y' then
       fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', l_hzprofile_value);
       l_hzprofile_changed := 'N';
     end if;
/* End */
   pos_log.log_call_result
     (p_module        => 'POSENTRB',
      p_prefix        => 'call hz_party_v2pub.create_organization',
      p_return_status => l_return_status,
      p_msg_count     => l_msg_count,
      p_msg_data      => l_msg_data
      );

   IF l_return_status IS NULL OR l_return_status <> fnd_api.g_ret_sts_success THEN
     /* Added for bug 7366321 */
     if nvl(l_hzprofile_changed,'N') = 'Y' then
       fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', l_hzprofile_value);
       l_hzprofile_changed := 'N';
     end if;
    /* End */
      IF l_msg_count = 1 THEN
         x_exception_msg := l_msg_data;
       ELSIF l_msg_count > 1 THEN
         pos_log.combine_fnd_msg(l_msg_count, x_exception_msg);
       ELSE
         x_exception_msg := 'unknown error when calling hz_party_v2pub.create_organization';
      END IF;
      raise_application_error(-20001, x_exception_msg, true);
   END IF;

   classify_party (x_org_party_id,
                   'POS_CLASSIFICATION',
                   'PROCUREMENT_ORGANIZATION',
                   x_status,
                   x_exception_msg
                   );

   IF (x_status <> 'S') THEN
      raise_application_error(-20002, x_exception_msg, TRUE);
   END IF;

   x_status := 'S';
   x_exception_msg := NULL;
   RETURN;

END pos_create_organization;

PROCEDURE create_email_address
  ( p_partyid      IN NUMBER
  , p_emailaddress IN VARCHAR2
    )
IS
   l_contact_point_id    NUMBER;
   l_contact_points_rec  hz_contact_point_v2pub.contact_point_rec_type;
   l_email_rec           hz_contact_point_v2pub.email_rec_type;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(3000);

   CURSOR l_cur IS
      SELECT 1
        FROM hz_contact_points
       WHERE owner_table_id = p_partyid
         AND upper(email_address) = upper(p_emailaddress)
         AND owner_table_name = 'HZ_PARTIES'
         AND status = 'A'
        AND contact_point_type = 'EMAIL';

   l_number NUMBER;
BEGIN
    IF ( p_emailaddress IS NULL ) THEN
       RETURN;
    END IF;

    OPEN l_cur;
    FETCH l_cur INTO l_number;
    IF l_cur%found THEN
       CLOSE l_cur;
       RETURN;     -- kind of strange to return here but this is 11.5.10 logic
    END IF;
    CLOSE l_cur;

    l_email_rec.email_format                := 'MAILTEXT';
    l_email_rec.email_address               := p_emailaddress;
    l_contact_points_rec.contact_point_type := 'EMAIL';
    l_contact_points_rec.status             := 'A';
    l_contact_points_rec.owner_table_name   := 'HZ_PARTIES';
    l_contact_points_rec.owner_table_id     := p_partyId;
    l_contact_points_rec.created_by_module  := 'POS_SUPPLIER_MGMT';

    hz_contact_point_v2pub.create_contact_point
    ( p_init_msg_list     => FND_API.G_FALSE,
      p_contact_point_rec => l_contact_points_rec,
      p_email_rec         => l_email_rec,
      x_contact_point_id  => l_contact_point_id,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
      );

    pos_log.log_call_result
      ( p_module        => 'POSPMNGB',
        p_prefix        => 'in create_email_address',
        p_return_status => l_return_status,
        p_msg_count     => l_msg_count,
        p_msg_data      => l_msg_data
        );

   IF l_return_status IS NULL OR l_return_status <> fnd_api.g_ret_sts_success THEN
      IF l_msg_count > 1 THEN
         pos_log.combine_fnd_msg(l_msg_count, l_msg_data);
       ELSE
         l_msg_data := 'unknown error when calling hz_party_v2pub.create_organization';
      END IF;
      raise_application_error(-20001, l_msg_data, true);
   END IF;
END create_email_address;

-- in release 12, this procedure should not be used to create supplier user
-- it should be used for boot strap enterprise user for Sourcing
PROCEDURE pos_create_user
  (p_username      IN  VARCHAR2,
   p_firstname     IN  VARCHAR2,
   p_lastname      IN  VARCHAR2,
   p_emailaddress  IN  VARCHAR2,
   x_party_id      OUT NOCOPY NUMBER, -- party id of the user
   x_exception_msg OUT NOCOPY VARCHAR2,
   x_status        OUT NOCOPY VARCHAR2
   )
  IS
     l_lastname varchar2(240);
     l_return_status VARCHAR2(1);
     l_msg_count     NUMBER;
     l_msg_data      VARCHAR2(3000);
BEGIN

   IF( (p_firstname IS null) AND (p_lastname IS null) ) THEN
      l_lastname := '__SUPPLIER__';
    ELSE
      l_lastname := p_lastname;
   END IF;

   -- Create the user without mail and then we set the e-mail.
   -- The reason is because the TCA tries to find the user with
   -- same e-mail address, and will reuse the party.
   -- This will cause problem in our case as the vendor users typically
   -- could share e-mail addresses ( as the e-mail is stored in site
   -- tables but not in po_contact tables).
   hz_user_party_utils.get_user_party_id
     (p_username,
      p_firstname,
      l_lastname,
      NULL,
      x_party_id,
      x_status
      );

    IF x_status IS NULL OR x_status <> 'S' THEN
       l_msg_count := fnd_msg_pub.count_msg;
       pos_log.combine_fnd_msg(l_msg_count, x_exception_msg);
       raise_application_error(-20001, x_exception_msg, true);
    END IF;

    fnd_user_pkg.updateuser
      ( x_user_name   => p_username,
        x_owner       => NULL,
        x_customer_id => x_party_id
        );

    classify_party
      (x_party_id,
       'POS_CLASSIFICATION',
       'PROCUREMENT_USER',
       x_status,
       x_exception_msg
       );

    IF x_status IS NULL OR x_status <> 'S' THEN
       x_exception_msg := 'Setting the party as PROCUREMENT_USER for party_id= '
         || x_party_id || ' ' || x_exception_msg;
       raise_application_error(-20001, x_exception_msg, true);
    END IF;

    create_email_address(x_party_id, p_emailaddress);
    x_status := 'S';
    x_exception_msg := NULL;

END pos_create_user;

-- return party_id of the supplier party of a supplier user;
-- if the user has more than one supplier parties, return -2
-- if the user has no supplier party, return -1
FUNCTION check_for_vendor_user(p_username IN VARCHAR2)
  RETURN NUMBER IS
     l_count    NUMBER;
     l_party_id NUMBER;
BEGIN
   l_count := 0;
   FOR x IN (SELECT DISTINCT vendor_party_id
	       FROM pos_supplier_users_v
	      WHERE user_name = p_username
	      ORDER BY 1
	     ) LOOP

       l_count := l_count + 1;
       l_party_id := x.vendor_party_id;
       IF l_count > 1 THEN
	  EXIT;
       END IF;
   END LOOP;

   IF l_count = 1 THEN
      RETURN l_party_id;
   END IF;

   IF l_count = 0 THEN
      RETURN -1;
   END IF;

   IF l_count > 1 THEN
      RETURN -2;
   END IF;
END check_for_vendor_user;

FUNCTION check_for_enterprise_user(p_username IN VARCHAR2)
  RETURN NUMBER IS
     l_party_id number;
BEGIN
    select distinct hz2.party_id
      into l_party_id
      from fnd_user f, hz_parties hz1, hz_parties hz2,
           hz_relationships hzr1, hz_code_assignments hca
     where f.person_party_id = hz1.party_id
       and f.user_name = p_username
       and hzr1.object_id = hz2.party_id
       and hzr1.subject_id = hz1.party_id
       and hzr1.relationship_type = 'POS_EMPLOYMENT'
       and hzr1.relationship_code = 'EMPLOYEE_OF'
       and hzr1.start_date <= sysdate
       and hzr1.end_date >= sysdate
       and hca.owner_table_id = hz2.party_id
       and hca.owner_table_name = 'HZ_PARTIES'
       and hca.class_category = 'POS_PARTICIPANT_TYPE'
       and hca.class_code = 'ENTERPRISE';

    return l_party_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      return -1;
END check_for_enterprise_user;

-- return Y if the person_id is a current employee or contingent worker;
-- N otherwise
FUNCTION is_person_employee_cont_worker(p_person_id IN NUMBER)
  RETURN VARCHAR2 IS

     l_hr_agent    fnd_profile_option_values.profile_option_value%TYPE;
     l_number      NUMBER;

     -- the following query is based on view per_employees_current_x
     -- we can not use the view based the view is a secured view
     -- (by HR: Security Profile profile option)
     CURSOR l_current_employee_cur (p_person_id IN NUMBER) IS
	SELECT 1
	  FROM per_people_f p,
	       per_all_assignments_f a,
               per_periods_of_service b
	 WHERE a.person_id = p.person_id
	   AND a.primary_flag = 'Y'
	   AND a.assignment_type = 'E'
	   AND a.period_of_service_id = b.period_of_service_id
	   AND trunc(sysdate) BETWEEN p.effective_start_date AND p.effective_end_date
	   AND trunc(sysdate) BETWEEN a.effective_start_date AND a.effective_end_date
	   AND (b.actual_termination_date>= trunc(sysdate) OR b.actual_termination_date IS NULL)
	   AND p.employee_number IS NOT NULL
           AND p.person_id = p_person_id;

     -- the following query is based on view per_cont_workers_current_x
     -- we can not use the view based the view is a secured view
     -- (by HR: Security Profile profile option)
     CURSOR l_contingent_worker_cur (p_person_id IN NUMBER) IS
	SELECT 1
	  FROM per_people_f p,
               per_all_assignments_f a,
               per_periods_of_placement pp
	 WHERE a.person_id = p.person_id
	   AND a.person_id = pp.person_id
	   AND a.primary_flag = 'Y'
	   AND a.assignment_type = 'C'
	   AND a.period_of_placement_date_start = pp.date_start
	   AND trunc(sysdate) between p.effective_start_date AND p.effective_end_date
	   AND trunc(sysdate) between a.effective_start_date AND a.effective_end_date
	   AND (pp.actual_termination_date>= trunc(sysdate) OR pp.actual_termination_date IS NULL)
	   AND p.npw_number IS NOT NULL
	   AND p.person_id = p_person_id;

BEGIN

   OPEN l_current_employee_cur(p_person_id);
   FETCH l_current_employee_cur INTO l_number;
   IF l_current_employee_cur%found THEN
      CLOSE l_current_employee_cur;
      RETURN 'Y';
   END IF;
   CLOSE l_current_employee_cur;

   fnd_profile.get('HR_TREAT_CWK_AS_EMP', l_hr_agent);

   IF l_hr_agent IS NULL OR l_hr_agent <> 'Y' THEN
      RETURN 'N';
   END IF;

   OPEN l_contingent_worker_cur(p_person_id);
   FETCH l_contingent_worker_cur INTO l_number;
   IF l_contingent_worker_cur%found THEN
      CLOSE l_contingent_worker_cur;
      RETURN 'Y';
   END IF;
   CLOSE l_contingent_worker_cur;
   RETURN 'N';

END is_person_employee_cont_worker;

-- return person_party_id of the fnd user if the user
-- is a current employee or contingent worker; otherwise return null
FUNCTION get_emp_or_ctgt_wrkr_pty_id (p_userid IN NUMBER)
  RETURN NUMBER IS

     l_party_id    NUMBER;
     l_employee_id NUMBER;

     CURSOR l_fnd_user_cur IS
	SELECT employee_id, person_party_id
	  FROM fnd_user WHERE user_id = p_userid;

BEGIN

   OPEN l_fnd_user_cur;
   FETCH l_fnd_user_cur INTO l_employee_id, l_party_id;
   IF l_fnd_user_cur%notfound OR l_employee_id IS NULL THEN
      CLOSE l_fnd_user_cur;
      RETURN NULL;
   END IF;
   CLOSE l_fnd_user_cur;

   IF is_person_employee_cont_worker(l_employee_id) = 'Y' THEN
      RETURN l_party_id;
    ELSE
      RETURN NULL;
   END IF;

END get_emp_or_ctgt_wrkr_pty_id;

FUNCTION is_user_employee_cont_worker(p_userid IN NUMBER)
  RETURN VARCHAR2 IS
     l_employee_id NUMBER;

     CURSOR l_fnd_user_cur IS
	SELECT employee_id
	  FROM fnd_user
	 WHERE user_id = p_userid;
BEGIN
   OPEN l_fnd_user_cur;
   FETCH l_fnd_user_cur INTO l_employee_id;
   IF l_fnd_user_cur%notfound OR l_employee_id IS NULL THEN
      CLOSE l_fnd_user_cur;
      RETURN 'N';
   END IF;
   CLOSE l_fnd_user_cur;

   IF is_person_employee_cont_worker(l_employee_id) = 'Y' THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
   END IF;
END is_user_employee_cont_worker;

-- bitang: the implementation here works for release 11.5.10 but might be changed for r12
-- due to TCA Supplier project.
-- this procedure is used in POSISPAB.pls. need to find out whether the
-- caller passes in a supplier username or internal user name
FUNCTION get_job_title_for_user (p_user_id IN NUMBER )
  RETURN VARCHAR2
  IS
     l_job_title HZ_PARTIES.PERSON_TITLE%TYPE;
BEGIN
   SELECT hp.person_title
     INTO l_job_title
     FROM hz_parties hp, fnd_user fu
    WHERE hp.party_id = fu.person_party_id
      AND fu.user_id = p_user_id;

    return l_job_title;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_job_title_for_user;

END POS_PARTY_MANAGEMENT_PKG;

/
