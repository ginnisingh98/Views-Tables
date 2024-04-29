--------------------------------------------------------
--  DDL for Package Body AR_CMGT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_UTIL" AS
/* $Header: ARCMUTLB.pls 120.28.12010000.4 2010/03/24 13:18:48 mraymond ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/
pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

pg_wf_debug VARCHAR2(1) := nvl(fnd_profile.value('AR_CMGT_WF_DEBUG'),'N');
pg_wf_debug_file VARCHAR2(50) := fnd_profile.value('AR_CMGT_WF_DEBUG_FILE');
pg_wf_debug_path VARCHAR2(255) := fnd_profile.value('AR_CMGT_WF_DEBUG_PATH');

g_master_debug VARCHAR2(1);

g_file_handle utl_file.file_type;
/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/* This function tests both flags and returns Y if either
   is turned on.  Internally, we will utilize wf_debug only
   if it is turned on and FND debug only if it is turned on.
   It is possible for both to be enabled at the same time
   and that would produce both debug logs */
FUNCTION get_wf_debug_flag
    RETURN VARCHAR2  IS
BEGIN
   IF g_master_debug = 'Y'
   THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;
END get_wf_debug_flag;

PROCEDURE debug (
  p_message     IN VARCHAR2,
  p_module_name IN VARCHAR2,
  p_log_level   IN NUMBER) IS

BEGIN
  IF ( p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
  	FND_LOG.string(p_log_level,p_module_name, p_message);
  END IF;

END debug;

/* This debug routine was constructed to bypass the fnd_debug
    because that one does not work easily or consistently
    through workflow.

   This debug routine is controlled by the AR_CMGT_WF_DEBUG profile
    and simply writes the messages to the file AR_CMGT_WF_DEBUG_FILE
    in AR_CMGT_WF_DEBUG_PATH.  To effectively use this, you need to
    set those profiles at the site level or for sysadmin user (where
    WF is run from) */

PROCEDURE wf_debug(   p_process_name IN VARCHAR2,
                      p_message      IN VARCHAR2) IS
   l_message VARCHAR2(512);
BEGIN
   IF pg_wf_debug = 'Y'
   THEN
      l_message := TO_CHAR(sysdate, 'RRRR-MM-DD HH:MI:SS ~ ') ||
               p_process_name || ' ~ ' || p_message;
      utl_file.put_line(g_file_handle, l_message );
   END IF;

   /* Also write to FND debug log if it is enabled */
   IF pg_debug in ('Y','C')
   THEN
      /* Calls internal debug routine which directly calls
      FND_LOG routine.  This avoids ARP_STANDARD and the
      odd 'AR_NO_ROW_SYSTEM_PARAMETERS' error. */
      debug(p_message, p_process_name, FND_LOG.G_CURRENT_RUNTIME_LEVEL);
   END IF;
END wf_debug;

/*========================================================================
 | PUBLIC FUNCTION
 |	check_user_resource()
 | DESCRIPTION
 |      This function checks whether resource id passed is for the user who
 |      is logged.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_credit_analyst_id    IN   Credit Analyst Id of the case folder
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 20-May-2002           S.Nambiar         Created
 |
 *=======================================================================*/
FUNCTION check_update_permissions(
                             p_credit_analyst_id IN  NUMBER,
                             p_requestor_id   IN NUMBER,
                             p_credit_request_status IN VARCHAR2 )
    RETURN VARCHAR2 IS

l_update_permissions 	VARCHAR2(1) :='N';
l_user_employee_id      NUMBER := fnd_global.employee_id;
l_resource_id           NUMBER;

 CURSOR get_resource_analyst IS
  SELECT c.resource_id
  FROM  jtf_rs_role_relations a,
        jtf_rs_roles_vl b,
        jtf_rs_resource_extns c
  WHERE a.role_resource_type = 'RS_INDIVIDUAL'
  AND   a.role_resource_id = c.resource_id
  AND   b.role_type_code  = 'CREDIT_MGMT'
  AND   a.role_id = b.role_id
  AND   b.role_code = 'CREDIT_ANALYST'
  AND   c.category = 'EMPLOYEE'
  AND   c.source_id = l_user_employee_id
  AND   NVL(a.delete_flag,'N') <> 'Y';

l_check_for_requestor BOOLEAN := FALSE;
BEGIN

 IF p_credit_request_status = 'SUBMIT'  THEN
  IF p_credit_analyst_id IS NOT NULL  THEN

    OPEN get_resource_analyst;

    FETCH get_resource_analyst INTO l_resource_id;


    IF p_credit_analyst_id = nvl(l_resource_id,-99) THEN
       l_update_permissions := 'Y';
    ELSE
       l_check_for_requestor := TRUE;
       l_update_permissions := 'N';
    END IF;

    CLOSE get_resource_analyst;

  END IF;

 ELSIF p_credit_request_status = 'SAVE'  THEN
 --Now check for the requestor .

  /* IF p_requestor_id IS NOT NULL  AND
     (p_credit_analyst_id IS NULL
      OR
      (l_check_for_requestor)) THEN
   IF  l_user_employee_id  = p_requestor_id THEN
      l_update_permissions := 'Y';
   ELSE
      l_update_permissions := 'N';
   END IF;

  END IF; */
  IF p_requestor_id IS NOT NULL
  THEN
	IF p_requestor_id = l_user_employee_id
	THEN
		l_update_permissions := 'Y';
	ELSE
		l_update_permissions := 'N';
	END IF;
  END IF;

 END IF;

        RETURN l_update_permissions;
EXCEPTION
  WHEN others THEN
     l_update_permissions := 'N';
     RETURN  l_update_permissions;
END;

/* Overloaded Function */
FUNCTION check_update_permissions(
                             p_credit_analyst_id IN  NUMBER,
                             p_requestor_id   IN NUMBER)
    RETURN VARCHAR2 IS

l_update_permissions 	VARCHAR2(1) :='N';
l_user_employee_id      NUMBER := fnd_global.employee_id;
l_resource_id           NUMBER;

 CURSOR get_resource_analyst IS
  SELECT c.resource_id
  FROM  jtf_rs_role_relations a,
        jtf_rs_roles_vl b,
        jtf_rs_resource_extns c
  WHERE a.role_resource_type = 'RS_INDIVIDUAL'
  AND   a.role_resource_id = c.resource_id
  AND   b.role_type_code  = 'CREDIT_MGMT'
  AND   a.role_id = b.role_id
  AND   b.role_code = 'CREDIT_ANALYST'
  AND   c.category = 'EMPLOYEE'
  AND   c.source_id = l_user_employee_id
  AND   NVL(a.delete_flag,'N') <> 'Y';

l_check_for_requestor BOOLEAN := FALSE;
BEGIN

  IF p_credit_analyst_id IS NOT NULL  THEN

    OPEN get_resource_analyst;

    FETCH get_resource_analyst INTO l_resource_id;


    IF p_credit_analyst_id = nvl(l_resource_id,-99) THEN
       l_update_permissions := 'Y';
    ELSE
       l_check_for_requestor := TRUE;
       l_update_permissions := 'N';
    END IF;

    CLOSE get_resource_analyst;

  END IF;

 --Now check for the requestor .

  IF p_requestor_id IS NOT NULL  AND
     (p_credit_analyst_id IS NULL
      OR
      (l_check_for_requestor)) THEN
   IF  l_user_employee_id  = p_requestor_id THEN
      l_update_permissions := 'Y';
   ELSE
      l_update_permissions := 'N';
   END IF;

  END IF;
        RETURN l_update_permissions;
EXCEPTION
  WHEN others THEN
     l_update_permissions := 'N';
     RETURN  l_update_permissions;
END;

/*========================================================================
 | PUBLIC FUNCTION
 |      check_emp_credit_analyst()
 | DESCRIPTION
 |      This function checks whether employee id passed is a credit analyst
 |      or not
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_employee_id    IN   Employee Id of the user logged in
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 20-May-2002           S.Nambiar         Created
 |
 *=======================================================================*/
FUNCTION check_emp_credit_analyst(p_employee_id IN  NUMBER )
    RETURN VARCHAR2 IS

l_credit_analyst 	VARCHAR2(1) :='N';

BEGIN
  SELECT 'Y'
  INTO   l_credit_analyst
  FROM  jtf_rs_role_relations a,
        jtf_rs_roles_vl b,
        jtf_rs_resource_extns c
  WHERE a.role_resource_type = 'RS_INDIVIDUAL'
  AND   a.role_resource_id = c.resource_id
  AND   a.role_id = b.role_id
  AND   b.role_type_code  = 'CREDIT_MGMT'
  AND   b.role_code = 'CREDIT_ANALYST'
  AND   c.category = 'EMPLOYEE'
  AND   c.source_id = p_employee_id
  AND   NVl(a.delete_flag,'N') <> 'Y';

  RETURN l_credit_analyst;

EXCEPTION
  WHEN others THEN
     RETURN l_credit_analyst;
END;

FUNCTION check_emp_credit_analyst
    RETURN VARCHAR2 IS

l_credit_analyst 	VARCHAR2(1) :='N';
l_employee_id           NUMBER := fnd_global.employee_id;

BEGIN
  SELECT 'Y'
  INTO   l_credit_analyst
  FROM  jtf_rs_role_relations a,
        jtf_rs_roles_vl b,
        jtf_rs_resource_extns c
  WHERE a.role_resource_type = 'RS_INDIVIDUAL'
  AND   a.role_resource_id = c.resource_id
  AND   a.role_id = b.role_id
  AND   b.role_type_code  = 'CREDIT_MGMT'
  AND   b.role_code = 'CREDIT_ANALYST'
  AND   c.category = 'EMPLOYEE'
  AND   c.source_id = l_employee_id
  AND   NVl(a.delete_flag,'N') <> 'Y';

  RETURN l_credit_analyst;

EXCEPTION
  WHEN others THEN
     RETURN l_credit_analyst;
END;

/*========================================================================
 | PUBLIC FUNCTION
 |      check_credit_analyst()
 | DESCRIPTION
 |      This function checks whether resource_id passed is a credit analyst.
 |      For a credit analysts there will be a credit analyst role assigned
 |      in resource manager.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_resource_id    IN      resource_id
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 20-May-2002           S.Nambiar         Created
 |
 *=======================================================================*/
FUNCTION check_credit_analyst(p_resource_id IN  NUMBER )
    RETURN VARCHAR2 IS

l_credit_analyst        VARCHAR2(1) :='N';

BEGIN
        SELECT 'Y'
        INTO  l_credit_analyst
        FROM  jtf_rs_role_relations a,
              jtf_rs_roles_vl b,
              jtf_rs_resource_extns c
        WHERE a.role_resource_type = 'RS_INDIVIDUAL'
        AND   a.role_resource_id = c.resource_id
        AND   a.role_id = b.role_id
        AND   b.role_type_code  = 'CREDIT_MGMT'
        AND   b.role_code = 'CREDIT_ANALYST'
        AND   c.category = 'EMPLOYEE'
        AND   c.resource_id = p_resource_id;

        RETURN l_credit_analyst;
EXCEPTION
 WHEN others THEN
        RETURN l_credit_analyst;
END;

FUNCTION get_credit_analyst_name(p_credit_analyst_id IN NUMBER)
RETURN VARCHAR2 IS
l_credit_analyst_name jtf_rs_resource_extns_vl.resource_name%TYPE;

CURSOR  credit_analyst_name(p_resource_id IN NUMBER) IS
  SELECT per.FULL_NAME
  FROM   JTF_RS_RESOURCE_EXTNS rextns,
         JTF_RS_ROLE_RELATIONS rel,
         JTF_RS_ROLES_VL role_vl,
         PER_ALL_PEOPLE_F per
  WHERE  role_vl.role_type_code  = 'CREDIT_MGMT'
    and  role_vl.role_code = 'CREDIT_ANALYST'
    and  role_vl.role_id = rel.role_id
    and  rel.role_resource_type = 'RS_INDIVIDUAL'
    and  rel.delete_flag <> 'Y'
    and  rel.role_resource_id = rextns.resource_id
    and  rextns.category = 'EMPLOYEE'
    and  rextns.source_id = per.person_id
    and  sysdate between per.effective_start_date and  per.effective_end_date
    and  per.current_employee_flag = 'Y'
    and  rextns.resource_id = p_resource_id;

BEGIN

 IF p_credit_analyst_id IS NOT NULL THEN

  OPEN credit_analyst_name(p_credit_analyst_id);

  FETCH credit_analyst_name INTO l_credit_analyst_name;

  CLOSE credit_analyst_name;
 END IF;

 RETURN l_credit_analyst_name;
END;

FUNCTION get_latest_cf_number(p_credit_request_id IN NUMBER)
 RETURN NUMBER IS

 CURSOR latest_cf_number(p_credit_request_id IN NUMBER ) IS
 SELECT case_folder_number
   FROM AR_CMGT_CASE_FOLDERS
  WHERE credit_request_id = p_credit_request_id;

 l_case_folder_number    NUMBER;

BEGIN
  OPEN latest_cf_number(p_credit_request_id);

  FETCH latest_cf_number INTO l_case_folder_number;

  IF latest_cf_number%NOTFOUND THEN
   l_case_folder_number := null;
  END IF;

  CLOSE latest_cf_number;

  RETURN l_case_folder_number;

END;


/*========================================================================
 | PUBLIC FUNCTION
 |      get_no_of_ref_data_points()
 | DESCRIPTION
 |      This procedure returns the value and no of references based on
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_credit_classification         IN      VARCHAR2,
 |      p_review_type                   IN      VARCHAR2,
 |      p_data_point_id                 IN      NUMBER,
 |      p_number_of_references          OUT NOCOPY     NUMBER,
 |      p_value                         OUT NOCOPY     VARCHAR2  (for future use)
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 20-May-2002           B.Sarkar          Created
 |
 *=======================================================================*/
PROCEDURE get_no_of_ref_data_points(
            p_credit_classification         IN      VARCHAR2,
            p_review_type                   IN      VARCHAR2,
            p_data_point_id                 IN      NUMBER,
            p_number_of_references          OUT NOCOPY     NUMBER,
            p_value                         OUT NOCOPY     VARCHAR2 ) IS

CURSOR c_number_of_reference IS
    SELECT  cld.number_of_references
    FROM    ar_cmgt_check_list_dtls cld,
            ar_cmgt_check_lists cl
    WHERE   cl.check_list_id = cld.check_list_id
    AND     cld.data_point_id  = p_data_point_id
    AND     cl.credit_classification = p_credit_classification
    AND     cl.review_type  = p_review_type
    AND     cl.submit_flag = 'Y'
    AND     sysdate between cl.start_date and nvl(cl.end_date,SYSDATE);


BEGIN
    OPEN c_number_of_reference;

    FETCH c_number_of_reference INTO p_number_of_references;

    IF c_number_of_reference%NOTFOUND THEN
        p_number_of_references := null;
    END IF;

  CLOSE c_number_of_reference;
END get_no_of_ref_data_points;


/*========================================================================
 | PUBLIC FUNCTION
 |      find_analysis_level()
 | DESCRIPTION
 |      This function checks tells you whether the analysis is at the
 |      party, customer account, or account site level.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_party_id    IN
 |      p_cust_account_id    IN
 |      p_cust_acct_site_id    IN
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Jun-2003           M.Senthil         Created
 |
 *=======================================================================*/
 FUNCTION find_analysis_level
        ( p_party_id            IN       NUMBER,
          p_cust_account_id     IN       NUMBER,
          p_cust_acct_site_id   IN       NUMBER)

          return VARCHAR2 IS
    l_analysis_level                VARCHAR2(1);
BEGIN
    IF p_cust_acct_site_id <> -99
    THEN
        l_analysis_level := 'S';
    ELSIF p_cust_account_id <> -99
    THEN
        l_analysis_level := 'A';
    ELSE
        l_analysis_level := 'P';
    END IF;
    return l_analysis_level;
END;


/*========================================================================
 | PUBLIC FUNCTION
 |      get_limit_currency()
 | DESCRIPTION
 |      This function takes in some parameters and fills in the appropriate
 |      values regarding which currency is returned.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_party_id             IN     Party Id
 |      p_cust_account_id      IN     Customer Account Id
 |      p_cust_acct_site_id    IN     Customer Account Site Id
 |      p_trx_currency_code    IN     Transaction Currency Code
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Jun-2003           M.Senthil         Created
 |
 *=======================================================================*/
PROCEDURE get_limit_currency(
            p_party_id                  IN          NUMBER,
            p_cust_account_id           IN          NUMBER,
            p_cust_acct_site_id         IN          NUMBER,
            p_trx_currency_code         IN          VARCHAR2,
            p_limit_curr_code           OUT nocopy         VARCHAR2,
            p_trx_limit                 OUT nocopy         NUMBER,
            p_overall_limit             OUT nocopy         NUMBER,
            p_cust_acct_profile_amt_id  OUT nocopy         NUMBER,
            p_global_exposure_flag      OUT nocopy         VARCHAR2,
            p_include_all_flag          OUT nocopy         VARCHAR2,
            p_usage_curr_tbl            OUT nocopy         HZ_CREDIT_USAGES_PKG.curr_tbl_type,
            p_excl_curr_list            OUT nocopy         VARCHAR2
            ) IS

l_entity_type               VARCHAR2(30);
l_entity_id                 NUMBER(15);
l_limit_currency_code       ar_cmgt_credit_requests.limit_currency%type;
l_analysis_level            VARCHAR2(1);

BEGIN
    l_analysis_level := AR_CMGT_UTIL.find_analysis_level(p_party_id,
                    p_cust_account_id, p_cust_acct_site_id);
    IF ( l_analysis_level = 'P')
    THEN
        l_entity_type := 'PARTY';
        l_entity_id := p_party_id;
    ELSIF ( l_analysis_level = 'A')
    THEN
        l_entity_type := 'CUSTOMER';
        l_entity_id   := p_cust_account_id;
    ELSIF ( l_analysis_level = 'S')
    THEN
        l_entity_type := 'SITE';
        l_entity_id   := p_cust_acct_site_id;
    END IF;

        hz_credit_usages_pkg.Get_Limit_Currency_usages (
                p_entity_type           => l_entity_type,
                p_entity_id             => l_entity_id,
                p_trx_curr_code         => p_trx_currency_code,
                x_limit_curr_code       => p_limit_curr_code,
                x_trx_limit             => p_trx_limit,
                x_overall_limit         => p_overall_limit,
                x_cust_acct_profile_amt_id => p_cust_acct_profile_amt_id,
                x_global_exposure_flag  => p_global_exposure_flag,
                x_include_all_flag      => p_include_all_flag,
                x_usage_curr_tbl        => p_usage_curr_tbl,
                x_excl_curr_list        => p_excl_curr_list);

END;


/*========================================================================
 | PUBLIC FUNCTION
 |      copy_checklist_datapoints()
 | DESCRIPTION
 |      This procedure copies datapoints for a checklist.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_old_check_list_id             IN      NUMBER,
 |      p_new_check_list_id             IN      NUMBER,
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 20-May-2002           B.Sarkar          Created
 |
 *=======================================================================*/
PROCEDURE copy_checklist_data_points(
            p_new_check_list_id                 IN      VARCHAR2,
            p_old_check_list_id                 IN      VARCHAR2) IS

CURSOR c_data_points IS
    SELECT  data_point_id,
            required_flag,
            number_of_references
    FROM    ar_cmgt_check_list_dtls
    WHERE   check_list_id = p_old_check_list_id;
BEGIN
     FOR c_data_points_rec IN c_data_points
     LOOP
            INSERT INTO ar_cmgt_check_list_dtls
                    (check_list_id,
                     data_point_id,
                     number_of_references,
                     required_flag,
                     last_updated_by,
                     created_by,
                     creation_date,
                     last_update_date,
                     last_update_login )
                     VALUES (
                     p_new_check_list_id,
                     c_data_points_rec.data_point_id,
                     c_data_points_rec.number_of_references,
                     c_data_points_rec.required_flag,
                     -1,
                     -1,
                     SYSDATE,
                     SYSDATE,
                     -1);


     END LOOP;
END copy_checklist_data_points;

FUNCTION IS_DUPLICATE_CHECKLIST (
        p_credit_classification         IN      VARCHAR2,
        p_review_type                   IN      VARCHAR2,
        p_start_date                    IN      DATE)
        return VARCHAR2 IS

CURSOR c_dup_checklist IS
    SELECT Check_list_name
    FROM ar_cmgt_check_lists
    WHERE submit_flag = 'Y'
    AND   credit_classification = p_credit_classification
    AND   review_type  = p_review_type
    AND   nvl(end_date,SYSDATE) >=  p_start_date;

    l_check_list_name                   ar_cmgt_check_lists.check_list_name%type;

BEGIN
     OPEN c_dup_checklist;

     FETCH c_dup_checklist INTO l_check_list_name;


     IF c_dup_checklist%NOTFOUND THEN
        l_check_list_name := null;
     END IF;

    CLOSE c_dup_checklist;

  RETURN l_check_list_name;
END;


FUNCTION is_valid_date (
        p_start_date                    IN      DATE,
        p_end_date                      IN      DATE)
        return NUMBER IS
l_result            NUMBER;
BEGIN
        IF p_start_date <= p_end_date
        THEN
	    IF ( p_start_date < trunc(sysdate) or
                 p_end_date < trunc(sysdate) )
	    THEN
		l_result := 2;
	    ELSE
            	l_result := 0;  -- succss
	    END IF;
        ELSE
            l_result := 1;  -- failure
        END IF;

        return l_result;
END;

FUNCTION get_fnd_user_name (
	p_user_id		IN	NUMBER )
	return VARCHAR2 IS

CURSOR c_user_name IS
	SELECT user_name
	FROM fnd_user
	WHERE user_id = p_user_id
	AND   sysdate between start_date and nvl(end_date,SYSDATE);

l_user_name			fnd_user.user_name%type;
BEGIN

     OPEN c_user_name;

     FETCH c_user_name INTO l_user_name;


     IF c_user_name%NOTFOUND THEN
        l_user_name := null;
     END IF;

    CLOSE c_user_name;

  RETURN l_user_name;
END;

FUNCTION check_delete_permissions(p_credit_analyst_id  IN  NUMBER,
                                  p_requestor_id       IN  NUMBER,
                                  p_credit_request_status IN VARCHAR2 )
RETURN VARCHAR2
IS
l_del_permission  varchar2(1) := 'N';
l_user_employee_id      NUMBER := fnd_global.employee_id;
BEGIN
 IF p_credit_request_status = 'SAVE'  THEN
  IF p_requestor_id IS NOT NULL THEN
   if l_user_employee_id = p_requestor_id then
    l_del_permission := 'Y';
   end if;
  END IF;
 END IF;

 return l_del_permission;

END check_delete_permissions;

FUNCTION get_person_based_on_resource ( l_resource_id   IN  NUMBER)
return NUMBER IS
    l_person_id             per_people_f.person_id%type;
    CURSOR c_person_id IS
        SELECT c.source_id
        FROM  jtf_rs_resource_extns c
        WHERE c.category = 'EMPLOYEE'
        AND   c.resource_id = l_resource_id;

BEGIN

     OPEN c_person_id;

     FETCH c_person_id INTO l_person_id;

     IF c_person_id%NOTFOUND THEN
        l_person_id := null;
     END IF;

    CLOSE c_person_id;

    return l_person_id;


END;

FUNCTION get_person_based_on_cf ( l_case_folder_id   IN  NUMBER)
return NUMBER IS
    l_resource_id                   ar_cmgt_case_folders.credit_analyst_id%type;
    l_person_id                     per_people_f.person_id%type;
    CURSOR c_res_id IS
        SELECT credit_analyst_id
        FROM  ar_cmgt_case_folders
        WHERE case_folder_id = l_case_folder_id;

BEGIN

     OPEN c_res_id;

     FETCH c_res_id INTO l_resource_id;

     IF c_res_id%NOTFOUND THEN
        l_resource_id := null;
     ELSE
        l_person_id := get_person_based_on_resource (l_resource_id);
     END IF;

    CLOSE c_res_id;

    return l_person_id;


END;

/* This function will check whether any case folders exist for the party */
FUNCTION check_casefolder_exists(p_party_id             IN NUMBER,
                                 p_cust_account_id      IN NUMBER,
                                 p_cust_account_site_id IN NUMBER)
RETURN VARCHAR2 IS
CURSOR case_folder_exists IS
select 'Y'
from dual
where exists (select case_folder_id
              from ar_cmgt_case_folders
              where party_id = p_party_id
              and   cust_account_id = nvl(p_cust_account_id,-99)
              and   site_use_id = nvl(p_cust_account_site_id,-99));

l_return_status   VARCHAR2(1):= 'N';
BEGIN

/* If there is a CF exist for account/site and there is no CF exist for
   party directly, are we supposed to display CF details for the party in
   credit summary by rolling over the child CFs ????
   we need to revisit this logic again, till that party search results view
   credit summary will be disabled if there is no CF for party
*/

   OPEN case_folder_exists;
   FETCH case_folder_exists INTO l_return_status;
   CLOSE case_folder_exists;

  RETURN l_return_status;

EXCEPTION
   WHEN others THEN
     l_return_status := 'N';
    RETURN l_return_status;
END;

FUNCTION IsApplicationExists(
	p_party_id	        IN 	    NUMBER,
    p_cust_account_id   IN      NUMBER,
    p_site_use_id       IN      NUMBER)
return VARCHAR2 IS
	l_credit_request_id			NUMBER;
	l_return_status		        VARCHAR2(1):= 'N';
BEGIN

    BEGIN
	   SELECT credit_request_id
	   INTO   l_credit_request_id
	   FROM   ar_cmgt_credit_requests
	   WHERE  party_id = p_party_id
       AND    cust_account_id = p_cust_account_id
       AND    site_use_id  = p_site_use_id
	   AND    status <> 'PROCESSED';

       l_return_status := 'Y';

      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            l_return_status := 'N';
        WHEN TOO_MANY_ROWS
        THEN
            l_return_status := 'Y';
        WHEN OTHERS -- any other error conditions
        THEN
            l_return_status := 'N';
    END;
    return l_return_status;
END;

FUNCTION get_score_summary(p_case_folder_id IN NUMBER)
RETURN NUMBER IS
l_score_total  NUMBER := 0;
BEGIN

  SELECT SUM(score)
  INTO l_score_total
  FROM ar_cmgt_cf_dtls
  WHERE case_folder_id=p_case_folder_id;

  RETURN l_score_total;
EXCEPTION
WHEN others THEN
 RETURN l_score_total;

END;


FUNCTION get_credit_classification(p_party_id           IN NUMBER,
                                   p_cust_account_id    IN NUMBER,
                                   p_site_use_id        IN NUMBER)
RETURN VARCHAR2 IS
    l_credit_classification   ar_cmgt_credit_requests.credit_classification%type;
    l_sql_statement           VARCHAR2(2000);

BEGIN

   -- check what level the request came
   IF p_site_use_id <> -99  -- means site level analysis
   THEN
      l_sql_statement :=
                 'SELECT credit_classification '    ||
                 'FROM   hz_customer_profiles '     ||
                 'WHERE  party_id = :1 '            ||
                 'AND    cust_account_id = :2 '     ||
                 'AND    site_use_id = :3 ';
      EXECUTE IMMEDIATE l_sql_statement INTO l_credit_classification
      USING p_party_id, p_cust_account_id, p_site_use_id;
   ELSIF p_cust_account_id <> -99 -- means account level analysis
   THEN
      l_sql_statement :=
                 'SELECT credit_classification '    ||
                 'FROM   hz_customer_profiles '     ||
                 'WHERE  party_id = :1 '            ||
                 'AND    cust_account_id = :2 '     ||
                 'AND    site_use_id IS NULL ';
      EXECUTE IMMEDIATE l_sql_statement INTO l_credit_classification
      USING p_party_id, p_cust_account_id;
   ELSE  -- means party level analysis
      l_sql_statement :=
                 'SELECT credit_classification '    ||
                 'FROM   hz_customer_profiles '     ||
                 'WHERE  party_id = :1 '            ||
                 'AND    cust_account_id = -1 '     ||
                 'AND    site_use_id IS NULL ';
      EXECUTE IMMEDIATE l_sql_statement INTO l_credit_classification
      USING p_party_id;
   END IF;
   IF l_credit_classification IS NULL -- means profile is not set
   THEN
      SELECT default_credit_classification
      INTO   l_credit_classification
      FROM ar_cmgt_setup_options;
   END IF;
   return l_credit_classification;

EXCEPTION
WHEN others THEN
 l_credit_classification := 'NULL';
 return l_credit_classification;

END;


PROCEDURE CLOSE_WF_NOTIFICATION  (
		p_credit_request_id		IN			NUMBER,
		p_message_name 			IN			VARCHAR2,
		p_recipient_role		IN			VARCHAR2,
		p_resultout				OUT NOCOPY 	VARCHAR2,
		p_error_msg				OUT NOCOPY	VARCHAR2) IS

	l_notification_id 		wf_notifications.notification_id%type;

BEGIN
	IF pg_debug = 'Y' THEN
     debug ('CLOSE_WF_NOTIFICATION(+)' );
     debug ('p_credit_request_id '||p_credit_request_id );
     debug ('Role  '||p_recipient_role );
     debug ('p_message_name  '||p_message_name);
    END IF;
	p_resultout	 := 0;
	p_error_msg := null;

	select notification_id
	INTO   l_notification_id
	from wf_notifications
	where message_name = p_message_name --'MSG_TO_CM_NO_CA'
	and Recipient_role = p_recipient_role --'FND_RESP222:23918'
	and status = 'OPEN'
	and context like 'ARCMGTAP:'||p_credit_request_id||'%';

	IF pg_debug = 'Y' THEN
       debug ('Notification Id  '||l_notification_id);
    END IF;
	-- Now call wf_notification api to close the notification
	WF_NOTIFICATION.close(
		nid 	=> l_notification_id );
	IF pg_debug = 'Y' THEN
     debug ('CLOSE_WF_NOTIFICATION(-)' );
    END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND
		THEN
			Null;
		WHEN OTHERS
		THEN
			p_resultout	:= 1;
			p_error_msg := sqlerrm;
END CLOSE_WF_NOTIFICATION;

FUNCTION convert_amount (
                	  p_from_currency         VARCHAR2,
                	  p_to_currency           VARCHAR2,
                	  p_conversion_date       DATE,
                	  p_conversion_type       VARCHAR2 DEFAULT NULL,
                	  p_amount                NUMBER )
RETURN NUMBER
IS
   converted_amount       NUMBER;
   l_type              	  VARCHAR2(8);
BEGIN
   FND_MSG_PUB.initialize;

   /* First verify if to currency is valid */
   SELECT decode( derive_type,
                  'EURO', 'EURO',
                  'EMU', decode( sign( trunc(sysdate) -
                                       trunc(derive_effective)),
                                 -1, 'OTHER',
                                 'EMU'),
                  'OTHER' )
   INTO   l_type
   FROM   FND_CURRENCIES
   WHERE  currency_code = p_to_currency;

   converted_amount := gl_currency_api.convert_amount(  p_from_currency,
							p_to_currency,
                                        		p_conversion_date,
							p_conversion_type,
                                        		p_amount );
   return( converted_amount );

EXCEPTION
   WHEN gl_currency_api.NO_RATE THEN
      FND_MESSAGE.SET_NAME('AR', 'OCM_NO_RATE');
      FND_MESSAGE.SET_TOKEN('CODE1', p_from_currency);
      FND_MESSAGE.SET_TOKEN('CODE2', p_to_currency);
      FND_MESSAGE.SET_TOKEN('DATE', p_conversion_date);
      FND_MESSAGE.SET_TOKEN('TYPE', p_conversion_type);
      fnd_msg_pub.add();
      raise;

   WHEN gl_currency_api.INVALID_CURRENCY THEN
      FND_MESSAGE.SET_NAME('AR', 'OCM_INVALID_CURRENCY');
      FND_MESSAGE.SET_TOKEN('CURRCODE', p_from_currency);
      fnd_msg_pub.add();
      raise;

   WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'OCM_INVALID_CURRENCY');
      FND_MESSAGE.SET_TOKEN('CURRCODE', p_to_currency);
      fnd_msg_pub.add();
      raise;
END convert_amount;


/* Bug 2855292 */
FUNCTION get_setup_option(p_detail_type IN VARCHAR2)
RETURN VARCHAR2 IS
   l_return_val VARCHAR2(30);
   l_default_credit_classif VARCHAR2(30);
   l_default_exchange_type VARCHAR2(30);
   l_aging_bucket_id NUMBER(15);
   l_match_rule_id NUMBER(15);
   l_cer_dso_days NUMBER(15);
   l_period NUMBER(15);
   l_auto_application_num_flag varchar2(1);
BEGIN
   IF p_detail_type IS NOT NULL THEN
      IF NOT pg_ocm_global_setup_options.EXISTS(1) THEN

         SELECT default_credit_classification ,
                default_exchange_rate_type,
                aging_bucket_id,
                match_rule_id,
                cer_dso_days,
                period,
                auto_application_num_flag
         INTO   l_default_credit_classif ,
                l_default_exchange_type,
                l_aging_bucket_id,
                l_match_rule_id,
                l_cer_dso_days,
                l_period,
                l_auto_application_num_flag
         FROM ar_cmgt_setup_options;

	 pg_ocm_global_setup_options(1).default_credit_classification :=
						l_default_credit_classif;
      	 pg_ocm_global_setup_options(1).default_exchange_rate_type:=
						l_default_exchange_type;
      	 pg_ocm_global_setup_options(1).aging_bucket_id:=l_aging_bucket_id;
      	 pg_ocm_global_setup_options(1).match_rule_id:=l_match_rule_id;
      	 pg_ocm_global_setup_options(1).cer_dso_days:=l_cer_dso_days;
      	 pg_ocm_global_setup_options(1).period := l_period;
      	 pg_ocm_global_setup_options(1).auto_application_num_flag :=
						l_auto_application_num_flag;

      END IF;

      IF p_detail_type = 'DEFAULT_CREDIT_CLASSIFICATION' THEN
         l_return_val :=
                pg_ocm_global_setup_options(1).default_credit_classification;

      ELSIF p_detail_type = 'DEFAULT_EXCHANGE_RATE_TYPE' THEN
         l_return_val :=
                pg_ocm_global_setup_options(1).default_exchange_rate_type;

      ELSIF p_detail_type = 'AGING_BUCKET_ID' THEN
         l_return_val :=  pg_ocm_global_setup_options(1).aging_bucket_id;

      ELSIF p_detail_type = 'MATCH_RULE_ID' THEN
         l_return_val :=  pg_ocm_global_setup_options(1).match_rule_id;

      ELSIF p_detail_type = 'CER_DSO_DAYS' THEN
         l_return_val :=  pg_ocm_global_setup_options(1).cer_dso_days;

      ELSIF p_detail_type = 'PERIOD' THEN
         l_return_val :=  pg_ocm_global_setup_options(1).period;

      ELSIF p_detail_type = 'AUTO_APPLICATION_NUM_FLAG' THEN
         l_return_val :=
                pg_ocm_global_setup_options(1).auto_application_num_flag;
      END IF;

      RETURN l_return_val;
   END IF;

EXCEPTION
   WHEN others THEN
      RETURN NULL;
END get_setup_option;

PROCEDURE OM_CUST_APPLY_HOLD (
    p_party_id            			IN          NUMBER,
    p_cust_account_id            	IN          NUMBER,
    p_site_use_id					IN			NUMBER,
    p_error_msg         			OUT NOCOPY  VARCHAR2,
	p_return_status					OUT NOCOPY	VARCHAR2 ) IS

    l_return_value      NUMBER := 0;
    l_hold_source_rec  OE_HOLDS_PVT.Hold_Source_Rec_Type :=
                      		OE_HOLDS_PVT.G_MISS_Hold_Source_REC;
    l_msg_count			NUMBER;
    l_entity_code 		VARCHAR2(1);
    CURSOR cAccounts IS
            SELECT CUST_ACCOUNT_ID
            FROM   HZ_CUST_ACCOUNTS
            WHERE  PARTY_ID = p_party_id
            AND    STATUS = 'A';

BEGIN

 	l_hold_source_rec.hold_id          := 1;           -- credit hold
 	   -- For Ct based holds.
 	-- first check the level of analysis
 	IF p_cust_account_id = -1 -- party level
 	THEN
 		l_hold_source_rec.hold_entity_code := 'C';
 		-- get all the acconts for the parties
 		FOR cAccountsRec IN cAccounts
 		LOOP
 			l_hold_source_rec.hold_entity_id   := cAccountsRec.cust_account_id;
 			OE_Holds_PUB.Apply_Holds
         		( p_api_version       => 1.0
         		, p_validation_level  => FND_API.G_VALID_LEVEL_NONE
         		, p_hold_source_rec   => l_hold_source_rec
         		, x_msg_count         => l_msg_count
         		, x_msg_data          => p_error_msg
         		, x_return_status     => p_return_status
         		);
         	IF 	p_return_status <> FND_API.G_RET_STS_SUCCESS
         	THEN
         			exit;
         	END IF;
 		END LOOP;
 	ELSIF p_cust_account_id <> -1 and p_site_use_id IS NULL
 	THEN
			l_hold_source_rec.hold_entity_code := 'C';
			l_hold_source_rec.hold_entity_id   := p_cust_account_id;
			OE_Holds_PUB.Apply_Holds
         		( p_api_version       => 1.0
         		, p_validation_level  => FND_API.G_VALID_LEVEL_NONE
         		, p_hold_source_rec   => l_hold_source_rec
         		, x_msg_count         => l_msg_count
         		, x_msg_data          => p_error_msg
         		, x_return_status     => p_return_status
         		);
         	IF 	p_return_status <> FND_API.G_RET_STS_SUCCESS
         	THEN
         			return;
         	END IF;
	ELSIF p_cust_account_id <> -1 and p_site_use_id IS NOT NULL
 	THEN
			l_hold_source_rec.hold_entity_code := 'S';
			l_hold_source_rec.hold_entity_id   := p_site_use_id;
			OE_Holds_PUB.Apply_Holds
         		( p_api_version       => 1.0
         		, p_validation_level  => FND_API.G_VALID_LEVEL_NONE
         		, p_hold_source_rec   => l_hold_source_rec
         		, x_msg_count         => l_msg_count
         		, x_msg_data          => p_error_msg
         		, x_return_status     => p_return_status
         		);
         	IF 	p_return_status <> FND_API.G_RET_STS_SUCCESS
         	THEN
         			return;
         	END IF;
 	END IF;
END;

PROCEDURE OM_CUST_RELEASE_HOLD (
    p_party_id            			IN          NUMBER,
    p_cust_account_id            	IN          NUMBER,
    p_site_use_id					IN			NUMBER,
    p_error_msg         			OUT NOCOPY  VARCHAR2,
	p_return_status					OUT NOCOPY	VARCHAR2 ) IS

    l_return_value      NUMBER := 0;
    l_hold_source_rec  OE_HOLDS_PVT.Hold_Source_Rec_Type :=
                      		OE_HOLDS_PVT.G_MISS_Hold_Source_REC;
    l_hold_release_rec   OE_HOLDS_PVT.Hold_Release_Rec_Type :=
                      OE_HOLDS_PVT.G_MISS_Hold_Release_REC;

    l_msg_count			NUMBER;
    l_entity_code 		VARCHAR2(1);

    CURSOR cAccounts IS
            SELECT CUST_ACCOUNT_ID
            FROM   HZ_CUST_ACCOUNTS
            WHERE  PARTY_ID = p_party_id
            AND    STATUS = 'A';

BEGIN

 	l_hold_source_rec.hold_id          := 1;           -- credit hold
        l_hold_release_rec.release_reason_code := 'OCM_AUTOMATIC';
   	l_hold_release_rec.release_comment := 'Credit Management Hold Release' ;
 	   -- For Ct based holds.
 	-- first check the level of analysis
 	IF p_cust_account_id = -1 -- party level
 	THEN
 		l_hold_source_rec.hold_entity_code := 'C';
 		-- get all the acconts for the parties
 		FOR cAccountsRec IN cAccounts
 		LOOP
 			l_hold_source_rec.hold_entity_id   := cAccountsRec.cust_account_id;
 			OE_Holds_PUB.Release_Holds
         		( p_api_version       => 1.0
         		, p_validation_level  => FND_API.G_VALID_LEVEL_NONE
         		, p_hold_source_rec   => l_hold_source_rec
         		, p_hold_release_rec  => l_hold_release_rec
         		, x_msg_count         => l_msg_count
         		, x_msg_data          => p_error_msg
         		, x_return_status     => p_return_status
         		);
         	IF 	p_return_status <> FND_API.G_RET_STS_SUCCESS
         	THEN
         			exit;
         	END IF;
 		END LOOP;
 	ELSIF p_cust_account_id <> -1 and p_site_use_id IS NULL
 	THEN
			l_hold_source_rec.hold_entity_code := 'C';
			l_hold_source_rec.hold_entity_id   := p_cust_account_id;
			OE_Holds_PUB.Release_Holds
         		( p_api_version       => 1.0
         		, p_validation_level  => FND_API.G_VALID_LEVEL_NONE
         		, p_hold_source_rec   => l_hold_source_rec
         		, p_hold_release_rec  => l_hold_release_rec
         		, x_msg_count         => l_msg_count
         		, x_msg_data          => p_error_msg
         		, x_return_status     => p_return_status
         		);
         	IF 	p_return_status <> FND_API.G_RET_STS_SUCCESS
         	THEN
         			return;
         	END IF;
	ELSIF p_cust_account_id <> -1 and p_site_use_id IS NOT NULL
 	THEN
			l_hold_source_rec.hold_entity_code := 'S';
			l_hold_source_rec.hold_entity_id   := p_site_use_id;
			OE_Holds_PUB.Release_Holds
         		( p_api_version       => 1.0
         		, p_validation_level  => FND_API.G_VALID_LEVEL_NONE
         		, p_hold_source_rec   => l_hold_source_rec
         		, p_hold_release_rec  => l_hold_release_rec
         		, x_msg_count         => l_msg_count
         		, x_msg_data          => p_error_msg
         		, x_return_status     => p_return_status
         		);
         	IF 	p_return_status <> FND_API.G_RET_STS_SUCCESS
         	THEN
         			return;
         	END IF;
 	END IF;
END;

FUNCTION get_requestor_name(p_requestor_id IN NUMBER)
RETURN VARCHAR2 IS

l_requestor_name per_all_people_f.full_name%TYPE;

CURSOR  crequestorName IS
  SELECT FULL_NAME
  FROM   PER_ALL_PEOPLE_F
  WHERE  sysdate between effective_start_date and  effective_end_date
    and  person_id  = p_requestor_id;

BEGIN

 IF p_requestor_id IS NOT NULL THEN

  OPEN cRequestorName;

  FETCH cRequestorName INTO l_requestor_name;

  CLOSE cRequestorName;

 END IF;

 RETURN l_requestor_name;

END;

BEGIN
   IF pg_wf_debug = 'Y'
   THEN
     /* make sure file handle is set */
     g_file_handle := utl_file.fopen(pg_wf_debug_path, pg_wf_debug_file, 'A');
     g_master_debug := 'Y';
   ELSE
      IF pg_debug in ('Y','C')
      THEN
        g_master_debug := 'Y';
      END IF;
   END IF;

END AR_CMGT_UTIL;

/
