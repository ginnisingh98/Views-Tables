--------------------------------------------------------
--  DDL for Package Body POS_SUPPLIER_USER_REG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPPLIER_USER_REG_PKG" AS
/* $Header: POSUREGB.pls 120.12.12010000.5 2012/09/08 18:53:37 pneralla ship $ */

g_log_module_name CONSTANT VARCHAR2(30) := 'POS_SUPPLIER_USER_REG_PKG';

-- the invitation response page URL
POS_INV_REPLY_PAGE CONSTANT VARCHAR2(4000) := 'OA_HTML/jsp/pos/registration/RegistrationReply.jsp?registrationKey=';

-- the user approval page URL
POS_APPROVAL_PAGE CONSTANT VARCHAR2(4000) := 'OA_HTML/OA.jsp?akRegionCode=POS_APPROVE_MAIN_RGN&akRegionApplicationId=177&registrationKey=';

TYPE g_refcur IS REF CURSOR;

FUNCTION decrypt
  (key   IN VARCHAR2,
   value IN VARCHAR2
   )
  RETURN VARCHAR2 AS language java name 'oracle.apps.fnd.security.WebSessionManagerProc.decrypt(java.lang.String,java.lang.String) return java.lang.String';

/*----------------------------------------

  private PROCEDURE create_resp_sec_attr_ifneeded

    Create the responsibility security attributes if it is not yet created

  PARAM:
     p_resp_id          IN NUMBER    - responsibility id
     p_resp_appl_id     IN NUMBER    - responsibility application  id
     p_sec_attr_code    IN VARCHAR2  - security attribute code
     p_sec_attr_appl_id IN NUMBER    - security attribute application id

----------------------------------------*/

PROCEDURE create_resp_sec_attr_ifneeded
  (p_resp_id          IN NUMBER,
   p_resp_appl_id     IN NUMBER,
   p_sec_attr_code    IN VARCHAR2,
   p_sec_attr_appl_id IN NUMBER
   )
  IS
     CURSOR l_cur IS
        SELECT 1
          FROM ak_resp_security_attributes
          WHERE responsibility_id = p_resp_id AND
          resp_application_id = p_resp_appl_id AND
          attribute_code = p_sec_attr_code AND
          attribute_application_id = p_sec_attr_appl_id;
     l_num NUMBER;
     lv_proc_name VARCHAR2(30) := 'create_resp_sec_attr_ifneeded';

BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_num;
   IF l_cur%found THEN
      CLOSE l_cur;
      IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' ||
                        lv_proc_name, 'Responsibility Security Attribute for resp_id=' ||
                        p_resp_id || ' and attribute_code=' || p_sec_attr_code || ' exists.'
                        );
      END IF;
      RETURN;
   END IF;
   CLOSE l_cur;

   IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name,
                     'Creating Responsibility Security Attribute for resp_id=' || p_resp_id ||
                     ' and attribute_code=' || p_sec_attr_code
                     );
   END IF;

   INSERT INTO ak_resp_security_attributes
     (responsibility_id,
      resp_application_id,
      attribute_code,
      attribute_application_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
      )
     VALUES
     (p_resp_id,
      p_resp_appl_id,
      p_sec_attr_code,
      p_sec_attr_appl_id,
      fnd_global.user_id,
      Sysdate,
      fnd_global.user_id,
      Sysdate,
      fnd_global.login_id
      );


   IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name,
                     'Responsibility Security Attribute created');
   END IF;

END create_resp_sec_attr_ifneeded;

/*----------------------------------------

  private PROCEDURE set_resp_sec_attrval_ifneeded

    Set the responsibility security attributes value if it is not yet set

  PARAM:
     p_resp_id          IN NUMBER    - responsibility id
     p_resp_appl_id     IN NUMBER    - responsibility application  id
     p_sec_attr_code    IN VARCHAR2  - security attribute code
     p_sec_attr_appl_id IN NUMBER    - security attribute application id
     p_varchar2_value   IN VARCHAR2 DEFAULT NULL - the varchar2 value
     p_date_value       IN DATE DEFAULT NULL     - the data value
     p_number_value     IN NUMBER DEFAULT NULL   - the number value

----------------------------------------*/

PROCEDURE set_resp_sec_attrval_ifneeded
  (p_resp_id          IN NUMBER,
   p_resp_appl_id     IN NUMBER,
   p_sec_attr_code    IN VARCHAR2,
   p_sec_attr_appl_id IN NUMBER,
   p_varchar2_value   IN VARCHAR2 DEFAULT NULL,
   p_date_value       IN DATE DEFAULT NULL,
   p_number_value     IN NUMBER DEFAULT NULL
   )
  IS
     CURSOR l_cur IS
        SELECT 1
          FROM ak_resp_security_attr_values
          WHERE responsibility_id = p_resp_id AND
          resp_application_id = p_resp_appl_id AND
          attribute_code = p_sec_attr_code AND
          attribute_application_id = p_sec_attr_appl_id;
     l_num NUMBER;
     lv_proc_name VARCHAR2(30) := 'set_resp_sec_attrval_ifneeded';

BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_num;
   IF l_cur%found THEN
      CLOSE l_cur;

      IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name,
                        'No need to set Responsibility Security Attribute value for resp_id=' ||
                        p_resp_id || ' and attribute_code=' || p_sec_attr_code
                        );
      END IF;

      RETURN;
   END IF;
   CLOSE l_cur;

   IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name,
                     'Setting Responsibility Security Attribute value for resp_id=' ||
                     p_resp_id || ' and attribute_code=' || p_sec_attr_code);
   END IF;

   INSERT INTO ak_resp_security_attr_values
     (responsibility_id,
      resp_application_id,
      attribute_code,
      attribute_application_id,
      varchar2_value,
      date_value,
      number_value
      )
     VALUES
     (p_resp_id,
      p_resp_appl_id,
      p_sec_attr_code,
      p_sec_attr_appl_id,
      p_varchar2_value,
      p_date_value,
      p_number_value
      );


   IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_procedure,g_log_module_name || '.' || lv_proc_name,
                     'Responsibility Security Attribute value set'
                     );
   END IF;

END set_resp_sec_attrval_ifneeded;

/*----------------------------------------

   PROCEDURE check_isp_resp_sec_attr

    This procedure will create iSP securing attributes
    (ICX_SUPPLIER_ORG_ID, ICX_SUPPLIER_SITE_ID, ICX_SUPPLIER_CONTACT_ID)
    for the responsibility, if they are not defined. It will also
    set the default value (-9999) for the securing attributes
    ICX_SUPPLIER_SITE_ID and ICX_SUPPLIER_CONTACT_ID for the responsibility,
    if they are not defined.

  PARAM:
     p_resp_id          IN NUMBER    - responsibility id
     p_resp_appl_id     IN NUMBER    - responsibility application  id

----------------------------------------*/

PROCEDURE check_isp_resp_sec_attr
  (p_resp_id      IN NUMBER,
   p_resp_appl_id IN NUMBER)
  IS
     CURSOR l_app_id_cur IS
        SELECT application_id
          FROM   fnd_application
          WHERE  application_short_name = 'POS';
     l_isp_appl_id NUMBER;
     lv_proc_name VARCHAR2(30) := 'set_resp_sec_attrval_ifneeded';

BEGIN
   OPEN l_app_id_cur;
   FETCH l_app_id_cur INTO l_isp_appl_id;
   IF l_app_id_cur%notfound THEN
      CLOSE l_app_id_cur;

      IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name,
                        'Application ID for POS is not found');
      END IF;

      RAISE NO_DATA_FOUND;
   END IF;
   CLOSE l_app_id_cur;
   --
   -- only create the attribute, not set default value
   -- because we do want the value be set at the user level for ICX_SUPPLIER_ORG_ID
   create_resp_sec_attr_ifneeded(p_resp_id          => p_resp_id,
                                 p_resp_appl_id     => p_resp_appl_id,
                                 p_sec_attr_code    => 'ICX_SUPPLIER_ORG_ID',
                                 p_sec_attr_appl_id => l_isp_appl_id
                                 );
   --
   create_resp_sec_attr_ifneeded(p_resp_id          => p_resp_id,
                                 p_resp_appl_id     => p_resp_appl_id,
                                 p_sec_attr_code    => 'ICX_SUPPLIER_SITE_ID',
                                 p_sec_attr_appl_id => l_isp_appl_id
                                 );
   --
   set_resp_sec_attrval_ifneeded(p_resp_id          => p_resp_id,
                                 p_resp_appl_id     => p_resp_appl_id,
                                 p_sec_attr_code    => 'ICX_SUPPLIER_SITE_ID',
                                 p_sec_attr_appl_id => l_isp_appl_id,
                                 p_varchar2_value   => NULL,
                                 p_date_value       => NULL,
                                 p_number_value     => -9999
                                 );
   --
   create_resp_sec_attr_ifneeded(p_resp_id          => p_resp_id,
                                 p_resp_appl_id     => p_resp_appl_id,
                                 p_sec_attr_code    => 'ICX_SUPPLIER_CONTACT_ID',
                                 p_sec_attr_appl_id => l_isp_appl_id
                                 );
   --
   set_resp_sec_attrval_ifneeded(p_resp_id          => p_resp_id,
                                 p_resp_appl_id     => p_resp_appl_id,
                                 p_sec_attr_code    => 'ICX_SUPPLIER_CONTACT_ID',
                                 p_sec_attr_appl_id => l_isp_appl_id,
                                 p_varchar2_value   => NULL,
                                 p_date_value       => NULL,
                                 p_number_value     => -9999
                                 );
END check_isp_resp_sec_attr;

/*----------------------------------------

   PROCEDURE check_isp_resp_sec_attr

    Overload check_isp_resp_sec_attr(NUMBER, NUMBER) to take the responsibility
    key.

  PARAM:
     p_resp_key         IN VARCHAR2  - the responsibility key
     p_resp_appl_id     IN NUMBER    - responsibility application  id

----------------------------------------*/

PROCEDURE check_isp_resp_sec_attr
  (p_resp_key     IN VARCHAR2,
   p_resp_appl_id IN NUMBER)
  IS
     lv_proc_name VARCHAR2(30) := 'check_isp_resp_sec_attr';
     ln_resp_id NUMBER;
     --
     CURSOR l_resp_id_cur (p_appl_id NUMBER, p_resp_key VARCHAR2) IS
        SELECT responsibility_id
          FROM   fnd_responsibility
          WHERE  application_id = p_appl_id
          AND    responsibility_key = p_resp_key
          AND    (end_date IS NULL OR end_date > start_date);
BEGIN
   OPEN l_resp_id_cur(p_resp_appl_id, p_resp_key);
   FETCH l_resp_id_cur INTO ln_resp_id;
   CLOSE l_resp_id_cur;
   IF ln_resp_id IS NULL THEN

      IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' ||
                     lv_proc_name, 'Invalid responsibility key ' || p_resp_key);
      END IF;

      RETURN;
   END IF;

   check_isp_resp_sec_attr(ln_resp_id, p_resp_appl_id);
END check_isp_resp_sec_attr;

PROCEDURE create_local_user
  (p_local_user_name IN VARCHAR2,
   p_email           IN VARCHAR2,
   p_language_code   IN VARCHAR2
   )
  IS
     l_local_user_name wf_local_users.name%TYPE;
     l_display_name    wf_local_users.display_name%TYPE;
     l_nls_lang        fnd_languages.nls_language%TYPE;
BEGIN

  SELECT nls_language
  INTO   l_nls_lang
  FROM   fnd_languages
  WHERE  language_code = p_language_code;

  l_local_user_name := p_local_user_name;
  l_display_name := p_email;

  wf_directory.createadhocuser
    ( name          => l_local_user_name,
      display_name  => l_display_name,
      language      => l_nls_lang,
      email_address => p_email
      );

  pos_anon_pkg.confirm_has_resp('POS_SUPPLIER_GUEST_USER');

END create_local_user;

PROCEDURE lock_reg
  (p_registration_id IN NUMBER)
  IS
     l_registration_id NUMBER;
BEGIN
   SELECT registration_id INTO l_registration_id
     FROM fnd_registrations
     WHERE registration_id = p_registration_id FOR UPDATE;
END lock_reg;

FUNCTION get_note (p_registration_id IN NUMBER) RETURN VARCHAR2
  IS
     CURSOR l_cur IS
        SELECT field_value_string
          FROM fnd_registration_details
         WHERE field_name = 'Note'
           AND registration_id = p_registration_id;

     l_note fnd_registration_details.field_value_string%TYPE;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_note;
   CLOSE l_cur;
   RETURN l_note;
END get_note;

FUNCTION get_contact_email RETURN VARCHAR2
  IS
     CURSOR l_cur IS
        SELECT email_address
          FROM fnd_user
         WHERE user_id = fnd_global.user_id;

     l_email fnd_user.email_address%TYPE;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_email;
   CLOSE l_cur;
   RETURN l_email;
END get_contact_email;

FUNCTION get_enterprise_name RETURN VARCHAR2
  IS
     lv_party_name    hz_parties.party_name%TYPE;
     lv_exception_msg VARCHAR2(32000);
     lv_status        VARCHAR2(240);
BEGIN

   pos_enterprise_util_pkg.get_enterprise_party_name
     ( lv_party_name, lv_exception_msg, lv_status);

   IF ( lv_status <> 'S' ) THEN
      RETURN NULL;
    ELSE
      RETURN lv_party_name;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_enterprise_name;

FUNCTION get_password
  (p_registration_id IN NUMBER) RETURN VARCHAR2
  IS
     l_encrypted_initial_password fnd_registration_details.field_value_string%TYPE;
     lv_unencrypted_password      VARCHAR2(100);
     l_reg_key                    fnd_registrations.registration_key%TYPE;
     l_osn_req_id NUMBER;
     l_internal_id NUMBER;
     l_user_name FND_USER.USER_NAME%TYPE;
     l_testname NUMBER;

     CURSOR l_cur IS
       SELECT d1.field_value_number, d2.field_value_number
       FROM fnd_registrations r,
            fnd_registration_details d1, fnd_registration_details d2
       WHERE r.registration_id = p_registration_id
       AND   d1.registration_id = r.registration_id
       AND   d2.registration_id = r.registration_id
       AND   d1.field_name = 'OSN Request ID'
       AND   d2.field_name = 'OSN Request InternalID';

BEGIN

   -- OSN: retrieve initial pwd set from OSN request, only when
   -- the initial password is not set do we generate user pwd.
   lv_unencrypted_password := NULL;

   --r12 requirement to use centralized password management
   OPEN l_cur;
   FETCH l_cur INTO l_osn_req_id, l_internal_id;
   IF l_cur%notfound THEN
     lv_unencrypted_password := NULL;
   ELSE
     lv_unencrypted_password := fnd_vault.get('POS_OSN',
            to_char(l_osn_req_id) || '_' || to_char(l_internal_id) );
   END IF;
   CLOSE l_cur;

   IF lv_unencrypted_password IS NULL THEN

   BEGIN
      l_encrypted_initial_password := NULL;

      SELECT registration_key
        INTO l_reg_key
        FROM fnd_registrations
       WHERE registration_id = p_registration_id;

      SELECT field_value_string
        INTO l_encrypted_initial_password
        FROM fnd_registration_details
       WHERE registration_id = p_registration_id
         AND field_name  = 'Initial Pass';

      lv_unencrypted_password := decrypt (l_reg_key,
                                          l_encrypted_initial_password
                                          );

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --if Initial Pass not found, then it's not an OSN request
         lv_unencrypted_password := NULL;
   END;

   END IF;

   IF lv_unencrypted_password IS NULL THEN
      lv_unencrypted_password := pos_password_util_pkg.generate_user_pwd();
   END IF;

   -- sso check: for users that already have an account in oid, add synch is allowed
   -- we should pass null as the password when creating the user account in fnd
   select r.requested_user_name
   into   l_user_name
   from fnd_registrations r
   where r.registration_id = p_registration_id;

   l_testname := FND_USER_PKG.TestUserName(l_user_name);
   IF (l_testname = FND_USER_PKG.USER_SYNCHED) THEN
     lv_unencrypted_password := NULL;
   END IF;

   RETURN lv_unencrypted_password;

END get_password;

FUNCTION get_tp_name
  (p_registration_id IN NUMBER) RETURN VARCHAR2
  IS
     CURSOR l_cur IS
        SELECT frd1.field_value_string tp_name
          FROM fnd_registration_details frd1,
               fnd_registrations fr
         WHERE frd1.registration_id = fr.registration_id
           AND frd1.field_name = 'OSN TP Name'
           AND fr.registration_id = p_registration_id;

     l_tpname fnd_registration_details.field_value_string%TYPE;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_tpname;
   CLOSE l_cur;
   RETURN l_tpname;
END get_tp_name;

/*----------------------------------------
set_initial_password
  set the initial password for osn registration request, so the user
  doesn't need to change password at first logon
  set_initial_password needs to be called after the user is created
  and should only be called for osn requests
----------------------------------------*/
FUNCTION set_initial_password(l_reg_id NUMBER)
  RETURN VARCHAR2

IS
    l_user_name FND_USER.USER_NAME%TYPE;
    l_osn_req_id NUMBER;
    l_internal_id NUMBER;
    l_reg_key FND_REGISTRATIONS.REGISTRATION_KEY%TYPE;
    l_encrypted_initial_password VARCHAR2(240);
    l_initial_password VARCHAR2(30);
    l_retcode VARCHAR2(1);
BEGIN
    l_initial_password := NULL;
    l_initial_password := get_password(l_reg_id);
    --for osn requests, the initial password could be
    --1. stored in fnd_vault (r12)
    --2. stored in Initial Pass (before r12)
    --3. null (if the user exists in oid, but not fnd, and user synch is allowed)

    IF (l_initial_password IS NULL) THEN
        RETURN 'N';
    END IF;

    SELECT r.requested_user_name, d1.field_value_number, d2.field_value_number
    INTO   l_user_name, l_osn_req_id, l_internal_id
    FROM fnd_registrations r,
         fnd_registration_details d1, fnd_registration_details d2
    WHERE r.registration_id = l_reg_id
    AND   d1.registration_id = l_reg_id
    AND   d2.registration_id = l_reg_id
    AND   d1.field_name = 'OSN Request ID'
    AND   d2.field_name = 'OSN Request InternalID';

    --call fnd_web_sec.change_password: the same routine
    --when user first time logon and change his/her password
    l_retcode := fnd_web_sec.change_password (
                              l_user_name,
                              l_initial_password
                              );

    fnd_vault.del('POS_OSN',
                  to_char(l_osn_req_id) || '_' || to_char(l_internal_id) );

    RETURN l_retcode;
EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
END set_initial_password;

FUNCTION is_osnrequest(p_registration_id IN NUMBER) RETURN VARCHAR2
  IS
     CURSOR l_cur IS
        SELECT field_value_number
          FROM fnd_registration_details
         WHERE field_name = 'OSN Request ID'
           AND registration_id = p_registration_id;

     l_osnreqid fnd_registration_details.field_value_number%TYPE;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_osnreqid;
   IF l_cur%notfound THEN
     l_osnreqid := NULL;
   END IF;
   CLOSE l_cur;

   IF (l_osnreqid IS NULL) THEN
     RETURN 'N';
   END IF;

   RETURN 'Y';
END is_osnrequest;

/*******************************************************************
     PROCEDURE NAME: get_wf_role_for_users
     this is the same function as that in PO_REQAPPROVAL_INIT1 (private func)

     DESCRIPTION   :
     Given a list of users, the procedure looks through the wf_user_roles
     to get a role that has exactly same set of input list of users.

     parameters    :
       Input:
           p_list_of_users - String containing the list of users
               Example string: 'GE1', 'GE2', 'GE22'
           p_num_users - number of users in the above list
       Output:
           A string containg the role name ( or null , if such role
           does not exist ).
*******************************************************************/

FUNCTION get_wf_role_for_users(p_list_of_users IN VARCHAR2, p_num_users IN NUMBER) RETURN VARCHAR2 IS
   l_refcur g_refcur;
   l_role_name WF_USER_ROLES.ROLE_NAME%TYPE;
   l_progress VARCHAR2(255);

   cursor l_role_cur is
   SELECT final.role_name
           FROM fnd_user fu,
           fnd_responsibility fr,
           wf_user_roles wur, wf_user_roles final
           WHERE fr.menu_id in
            (SELECT     fme.menu_id
             FROM       fnd_menu_entries fme, (SELECT function_id FROM fnd_form_functions WHERE function_name = 'POS_REG_APPROVE_EXT_USERS') func
             START WITH fme.function_id = func.function_id
             CONNECT BY PRIOR menu_id = sub_menu_id
             )
           AND fr.application_id = 177
           AND wur.role_name like 'FND_RESP|%|%|STANDARD'
           AND WUR.ROLE_ORIG_SYSTEM = 'FND_RESP'
           AND WUR.ROLE_ORIG_SYSTEM_ID = FR.RESPONSIBILITY_ID
           AND WUR.ASSIGNMENT_TYPE IN ('D', 'B')
           AND wur.user_name = fu.user_name
           AND final.user_name = fu.user_name
           GROUP BY final.role_name
           having count(final.role_name) = p_num_users;

   l_role_rec l_role_cur%ROWTYPE;

BEGIN
         l_role_name := null;

         for l_role_rec in l_role_cur loop
		l_role_name := l_role_rec.role_name;
         end loop;

         RETURN l_role_name;

EXCEPTION
    WHEN OTHERS THEN
       RETURN null;
END;

/*----------------------------------------
function get_approver_role_for_osn_request
  for user registration coming from Oracle
  Supplier Network.  We want the notification
  be sent to all users that can approve
  external user registrations.

  this function will create a role for this
  user list, so that notification REG_ADMIN_NTF
  will be sent to this role.
----------------------------------------*/
FUNCTION get_approver_role_for_osn
  RETURN VARCHAR2

IS
   x_refcur             g_refcur;
   l_approver_func_id   NUMBER := NULL;
   l_user_name          FND_USER.USER_NAME%TYPE := NULL;
   l_num_users          NUMBER := 0;
   l_approverlist       VARCHAR2(2000):=NULL;
   l_approverlist_sql   VARCHAR2(2000):=NULL;
   l_role_name          WF_USER_ROLES.ROLE_NAME%TYPE := NULL;
   l_role_display_name  VARCHAR2(100):=NULL;
   l_expiration_date    DATE;

BEGIN

   --step 1: find the users that can approve external user registrations

   SELECT function_id
   INTO l_approver_func_id
   FROM fnd_form_functions
   WHERE function_name = 'POS_REG_APPROVE_EXT_USERS';

   OPEN x_refcur FOR
      'SELECT DISTINCT fu.user_name
      FROM fnd_user fu,
           fnd_responsibility fr,
           wf_user_roles wur
      WHERE fr.menu_id in
            (SELECT     fme.menu_id
             FROM       fnd_menu_entries fme
             START WITH fme.function_id = :1
             CONNECT BY PRIOR menu_id = sub_menu_id
             )
      AND fr.application_id = 177
      AND wur.role_name like ''FND_RESP|%|%|STANDARD''
      AND WUR.ROLE_ORIG_SYSTEM = ''FND_RESP''
      AND WUR.ROLE_ORIG_SYSTEM_ID = FR.RESPONSIBILITY_ID
      AND WUR.ASSIGNMENT_TYPE IN (''D'', ''B'')
      AND wur.user_name = fu.user_name'
   using l_approver_func_id;


   --step 2: build the approver list

   LOOP
     FETCH x_refcur INTO l_user_name;
     EXIT WHEN x_refcur%NOTFOUND;
     l_num_users := l_num_users + 1;
     IF(l_approverlist is null) THEN
       l_approverlist:=l_user_name;
       l_approverlist_sql := ''''||l_user_name||'''';
     ELSE
       l_approverlist:=l_approverlist || ' ' || l_user_name;
       l_approverlist_sql:=l_approverlist_sql||','||''''||l_user_name||'''';
     END IF;
   END LOOP;
   CLOSE x_refcur;

   --step 3: given the approver list, find an existing matching role
   --        or create a new role

   IF(l_approverlist is not null) THEN
     l_role_name:= get_wf_role_for_users(l_approverlist_sql, l_num_users);

     IF(l_role_name is null ) THEN

           l_expiration_date := sysdate + 30; -- this role expires in 30 days

           WF_DIRECTORY.CreateAdHocRole(l_role_name, l_role_display_name,
             null,
             null,
             null,
             'MAILHTML',
             l_approverlist,
             null,
             null,
             'ACTIVE',
             l_expiration_date);
     END IF;

     RETURN l_role_name;

   END IF;

   --the approver list is null
   RETURN null;

EXCEPTION
   WHEN OTHERS THEN
     RETURN null;
END get_approver_role_for_osn;

PROCEDURE grant_resps
  (p_registration_id IN  NUMBER,
   p_user_id         IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS
     CURSOR l_cur IS
        SELECT field_value_string
          FROM fnd_registration_details
         WHERE registration_id = p_registration_id
           AND field_name LIKE 'POS_SUPPLIER_RESP_ID%';

     l_resp_id     NUMBER;
     l_resp_app_id NUMBER;
     l_index       NUMBER;
BEGIN

   FOR l_rec IN l_cur LOOP
      l_index := Instr(l_rec.field_value_string,':');
      l_resp_id := TO_NUMBER(SUBSTR(l_rec.field_value_string, 0, l_index - 1));
      l_resp_app_id := TO_NUMBER(SUBSTR(l_rec.field_value_string,  l_index + 1));

      pos_user_admin_pkg.grant_user_resp
        ( p_user_id       => p_user_id,
          p_resp_id       => l_resp_id,
          p_resp_app_id   => l_resp_app_id,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data
          );

      IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;

      IF l_resp_app_id = 177 THEN  -- pos application id is 177
         check_isp_resp_sec_attr(l_resp_id,l_resp_app_id);
      END IF;
   END LOOP;
END grant_resps;

PROCEDURE set_sec_attrs
  (p_registration_id IN  NUMBER,
   p_user_id         IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS
     CURSOR l_cur IS
         SELECT DISTINCT field_value_number, field_name
           FROM fnd_registration_details
          WHERE registration_id = p_registration_id
            AND (field_name like 'POS_SUPPLIER_ID%'
                 OR field_name like 'POS_SUPPLIER_SITE_ID%'
                 OR field_name like 'POS_SUPPLIER_CONTACT_ID%'
                 );
     l_attr_code VARCHAR2(30);
BEGIN
   FOR l_rec IN l_cur LOOP
      IF l_rec.field_name LIKE 'POS_SUPPLIER_ID%' THEN
         l_attr_code := 'ICX_SUPPLIER_ORG_ID';
       ELSIF l_rec.field_name LIKE 'POS_SUPPLIER_SITE_ID%' THEN
         l_attr_code := 'ICX_SUPPLIER_SITE_ID';
       ELSIF l_rec.field_name LIKE 'POS_SUPPLIER_CONTACT_ID%' THEN
         l_attr_code := 'ICX_SUPPLIER_CONTACT_ID';
      END IF;

      pos_user_admin_pkg.createsecattr
        ( p_user_id        => p_user_id,
          p_attribute_code => l_attr_code,
          p_app_id         => 177,
          p_number_value   => l_rec.field_value_number
          );
   END LOOP;
   x_return_status := fnd_api.g_ret_sts_success;
END set_sec_attrs;

PROCEDURE set_user_profile
  (p_user_id         IN  NUMBER,
   p_registration_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS
     l_value         fnd_profile_option_values.profile_option_value%TYPE;
     l_web_agent     fnd_profile_option_values.profile_option_value%TYPE;
     l_fwk_agent     fnd_profile_option_values.profile_option_value%TYPE;
     l_servlet_agent fnd_profile_option_values.profile_option_value%TYPE;
     l_saved         BOOLEAN;
     l_flag          VARCHAR2(1);
     is_osn          VARCHAR2(1);
BEGIN
   fnd_profile.get('POS_EXTERNAL_URL', l_value);
   l_web_agent := l_value;
   l_fwk_agent := l_value;
   owa_pattern.change(l_fwk_agent, '/pls.*', NULL);
   l_servlet_agent := l_fwk_agent || '/OA_HTML/';

   l_flag := NULL;
   IF l_web_agent IS NOT NULL AND owa_pattern.match(l_web_agent,'/pls/', l_flag) THEN
     -- The value of POS_EXTERNAL_URL still points to icx web site.
     l_saved := fnd_profile.save( x_name        => 'APPS_WEB_AGENT',
                                  x_value       => l_web_agent,
                                  x_level_name  => 'USER',
                                  x_level_value => p_user_id
                                  );
   END IF;

   IF l_fwk_agent IS NOT NULL THEN
      l_saved := fnd_profile.save( x_name        => 'APPS_FRAMEWORK_AGENT',
                                   x_value       => l_fwk_agent,
                                   x_level_name  => 'USER',
                                   x_level_value => p_user_id
                                   );
   END IF;

   IF l_servlet_agent IS NOT NULL THEN
      l_saved := fnd_profile.save( x_name        => 'APPS_SERVLET_AGENT',
                                   x_value       => l_servlet_agent,
                                   x_level_name  => 'USER',
                                   x_level_value => p_user_id
                                   );

   END IF;

  --OSN: need to set the profile to identify this user as a local user
  is_osn := is_osnrequest(p_registration_id);
  IF (is_osn = 'Y') THEN
      l_saved := fnd_profile.save( x_name               => 'APPS_SSO_LOCAL_LOGIN',
		                   -- 'Applications SSO Login Types' (Both/Local/SSO)
		                   x_value              => 'Local',
		                   x_level_name         => 'USER',
		                   x_level_value        => to_char(p_user_id),
		                   x_level_value_app_id => NULL
				   );
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;

END set_user_profile;

FUNCTION gen_local_user_name
  (p_registration_id IN NUMBER,
   p_flow            IN VARCHAR2
   ) RETURN VARCHAR2
  IS
BEGIN

   RETURN Substr('POSREGV2_' || p_registration_id || '_' || p_flow || '_' ||
     fnd_crypto.smallrandomnumber(), 0, 320);

END gen_local_user_name;

FUNCTION gen_wf_item_key
  (p_registration_id IN NUMBER,
   p_flow            IN VARCHAR2
   ) RETURN VARCHAR2
  IS
BEGIN
   RETURN Substr('POSREGV2_' || p_registration_id || '_' || p_flow || '_' ||
     fnd_crypto.smallrandomnumber(), 0, 240);
END gen_wf_item_key;

FUNCTION get_reg_page_url
  (p_inv_key       IN VARCHAR2,
   p_reg_lang_code IN VARCHAR2
   )
  RETURN VARCHAR2 IS
BEGIN
   RETURN pos_url_pkg.get_external_url || POS_INV_REPLY_PAGE || p_inv_key ||
     '&regLang=' || p_reg_lang_code;
END get_reg_page_url;

PROCEDURE send_approval_ntf
  (p_registration_id IN NUMBER,
   p_is_invited      IN VARCHAR2,
   p_is_user_in_oid  IN VARCHAR2,
   p_user_name       IN VARCHAR2,
   p_password        IN VARCHAR2
   )
  IS
     l_itemtype wf_items.item_type%TYPE;
     l_itemkey  wf_items.item_key%TYPE;
     l_process  wf_process_activities.process_name%TYPE;
     is_osn            VARCHAR2(1);
     l_enterprise_name VARCHAR2(10000);
BEGIN
   IF p_is_invited = 'Y' THEN
      l_process := 'SEND_APPRV_INV_USER_NTF';
    ELSE
      is_osn := is_osnrequest(p_registration_id);
      IF (is_osn = 'Y') THEN
        l_process := 'SEND_OSN_REG_USER_NTF';
      ELSIF (p_is_user_in_oid = 'Y') THEN
        l_process := 'SEND_APPRV_USER_SSOSYNC_NTF';
      ELSE
        l_process := 'SEND_APPRV_REG_USER_NTF';
      END IF;
   END IF;

   l_itemtype := 'POSREGV2';
   l_itemkey := gen_wf_item_key(p_registration_id,'approve');

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process
                           );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'LOGON_PAGE_URL',
                              avalue     => pos_url_pkg.get_external_login_url
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ASSIGNED_USER_NAME',
                              avalue     => p_user_name
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'FIRST_LOGON_KEY',
                              avalue     => p_password
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'CONTACT_EMAIL',
                              avalue     => get_contact_email
                              );

   IF p_is_invited <> 'Y' THEN
      wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                 itemkey    => l_itemkey,
                                 aname      => 'NOTE',
                                 avalue     => get_note(p_registration_id)
                                 );
   END IF;

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => get_enterprise_name
                              );

   -- Bug 8325979 - Following code added to replace the message body with FND
   -- Message tokens

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'POS_APPRV_REG_USER_SUBJECT',
                              avalue     => GET_APPRV_REG_USR_SUBJECT(l_enterprise_name)
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'POS_APPRV_REG_USER_BODY',
                              avalue     => 'PLSQLCLOB:pos_supplier_user_reg_pkg.GENERATE_APPRV_REG_USR_BODY/'||l_itemtype ||':' ||l_itemkey
                              );



   wf_engine.StartProcess (itemtype => l_itemtype,
                           itemkey  => l_itemkey
                           );

END send_approval_ntf;

PROCEDURE send_respond_ntf
  (p_registration_id IN NUMBER,
   p_first_name      IN VARCHAR2,
   p_last_name       IN VARCHAR2,
   p_vendor_name     IN VARCHAR2,
   p_approver_role   IN VARCHAR2
   )
  IS
     l_itemtype        wf_items.item_type%TYPE;
     l_itemkey         wf_items.item_key%TYPE;
     l_local_user_name wf_local_users.name%TYPE;
     l_process         wf_process_activities.process_name%TYPE;
     is_osn            VARCHAR2(1);
     lv_approver_role  WF_USER_ROLES.ROLE_NAME%TYPE;
BEGIN

   l_itemtype := 'POSREGV2';
   is_osn := is_osnrequest(p_registration_id);
   l_itemkey := gen_wf_item_key(p_registration_id,'respond');
   IF (is_osn = 'Y') THEN
     l_process := 'SEND_OSN_ADMIN_NTF';
   ELSE
     l_process := 'SEND_REG_ADMIN_NTF';
   END IF;

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process
                           );

   IF (is_osn = 'Y') THEN
     lv_approver_role := get_approver_role_for_osn();
     wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'APPROVER_ROLE',
                              avalue     => lv_approver_role
                              );
   ELSE
     wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'APPROVER_ROLE',
                              avalue     => p_approver_role
                              );
   END IF;

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'FIRST_NAME',
                              avalue     => p_first_name
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'LAST_NAME',
                              avalue     => p_last_name
                              );

   IF (is_osn = 'Y' AND p_vendor_name IS NULL) THEN
     wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'VENDOR_NAME',
                              avalue     => get_tp_name(p_registration_id)
                              );
   ELSE
     wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'VENDOR_NAME',
                              avalue     => p_vendor_name
                              );
   END IF;

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'LOGON_PAGE_URL',
                              avalue     => pos_url_pkg.get_buyer_login_url
                              );

   wf_engine.StartProcess (itemtype => l_itemtype,
                           itemkey  => l_itemkey
                           );

END send_respond_ntf;

PROCEDURE send_invitation_ntf
  (p_registration_id IN NUMBER,
   p_email           IN VARCHAR2,
   p_language_code   IN VARCHAR2,
   p_note            IN VARCHAR2,
   p_invitation_key  IN VARCHAR2
   )
  IS
     l_itemtype        wf_items.item_type%TYPE;
     l_itemkey         wf_items.item_key%TYPE;
     l_local_user_name wf_local_users.name%TYPE;
     l_process         wf_process_activities.process_name%TYPE;
BEGIN

   l_itemtype := 'POSREGV2';
   l_itemkey := gen_wf_item_key(p_registration_id,'invite');
   l_process := 'SEND_INV_USER_NTF';
   l_local_user_name := gen_local_user_name(p_registration_id, 'invite');

   create_local_user
     (p_local_user_name => l_local_user_name,
      p_email           => p_email,
      p_language_code   => p_language_code
      );

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process
                           );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ADHOC_USER_NAME',
                              avalue     => l_local_user_name
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => get_enterprise_name
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'REG_PAGE_URL',
                              avalue     => get_reg_page_url(p_invitation_key,
                                                             p_language_code)
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'NOTE',
                              avalue     => p_note
                              );

   wf_engine.StartProcess (itemtype => l_itemtype,
                           itemkey  => l_itemkey
                           );

END send_invitation_ntf;

PROCEDURE send_rejection_ntf
  (p_registration_id IN NUMBER,
   p_email           IN VARCHAR2,
   p_language_code   IN VARCHAR2
   )
  IS
     l_itemtype        wf_items.item_type%TYPE;
     l_itemkey         wf_items.item_key%TYPE;
     l_local_user_name wf_local_users.name%TYPE;
     l_process         wf_process_activities.process_name%TYPE;
BEGIN

   l_itemtype := 'POSREGV2';
   l_itemkey := gen_wf_item_key(p_registration_id,'reject');
   l_process := 'SEND_RJCT_USER_NTF';
   l_local_user_name := gen_local_user_name(p_registration_id, 'reject');

   create_local_user
     (p_local_user_name => l_local_user_name,
      p_email           => p_email,
      p_language_code   => p_language_code
      );

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process
                           );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ADHOC_USER_NAME',
                              avalue     => l_local_user_name
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'CONTACT_EMAIL',
                              avalue     => get_contact_email
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => get_enterprise_name
                              );
   wf_engine.StartProcess (itemtype => l_itemtype,
                           itemkey  => l_itemkey
                           );

END send_rejection_ntf;

FUNCTION is_invited
  (p_registration_id IN NUMBER) RETURN VARCHAR2
  IS
     CURSOR l_cur IS
        SELECT field_value_string
          FROM fnd_registration_details
         WHERE field_name = 'Invited Flag'
           AND registration_id = p_registration_id;

     l_value fnd_registration_details.field_value_string%TYPE;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_value;
   CLOSE l_cur;

   IF l_value IS NULL THEN
      RETURN NULL;
   END IF;

   IF l_value = 'Y' OR l_value = 'y' THEN
      RETURN 'Y';
   END IF;

   RETURN 'N';

END is_invited;

PROCEDURE approve
  (p_registration_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS
     CURSOR l_cur IS
        SELECT pv.party_id vendor_party_id,
               fr.*, jobt.field_value_string
          FROM po_vendors pv,
               fnd_registration_details frd,
               fnd_registrations fr, fnd_registration_details jobt
         WHERE frd.registration_id = fr.registration_id
           AND pv.vendor_id = frd.field_value_number
           AND frd.field_name = 'Supplier Number'
           AND jobt.field_name = 'Job Title'
           AND fr.registration_id = jobt.registration_id
           AND fr.application_id = jobt.application_id
           AND fr.registration_type = jobt.registration_type
           AND fr.registration_id = p_registration_id;

     l_rec  l_cur%ROWTYPE;

     l_person_party_id    NUMBER;
     l_password           VARCHAR2(100);
     l_password_returned  VARCHAR2(100);
     l_user_id            NUMBER;
     l_user_in_oid        VARCHAR2(1);

BEGIN
   SAVEPOINT supplier_user_reg_approve_sp;

   lock_reg (p_registration_id);

   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 1;
      x_msg_data := 'Can not find registration data for registration ' || p_registration_id;
      RETURN;
   END IF;
   CLOSE l_cur;

   l_password := get_password (p_registration_id);

   -- create supplier contact
   pos_supp_contact_pkg.create_supplier_contact
    (p_vendor_party_id => l_rec.vendor_party_id,
     p_first_name      => l_rec.first_name,
     p_last_name       => l_rec.last_name,
     p_middle_name     => l_rec.middle_name,
     p_contact_title   => l_rec.user_title,
     p_job_title       => l_rec.field_value_string,
     p_phone_area_code => l_rec.phone_area_code,
     p_phone_number    => l_rec.phone,
     p_phone_extension => l_rec.phone_extension,
     p_fax_area_code   => l_rec.fax_area_code,
     p_fax_number      => l_rec.fax,
     p_email_address   => l_rec.email,
     x_return_status   => x_return_status,
     x_msg_count       => x_msg_count,
     x_msg_data        => x_msg_data,
     x_person_party_id => l_person_party_id
     );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO supplier_user_reg_approve_sp;
      RETURN;
   END IF;

   l_user_in_oid := 'N';
   if (FND_USER_PKG.TestUserName(l_rec.requested_user_name) = FND_USER_PKG.USER_SYNCHED) then
     l_user_in_oid := 'Y';
   end if;

   -- create supplier user account
   pos_user_admin_pkg.create_supplier_user_account
     (p_user_name         => l_rec.requested_user_name,
      p_user_email        => l_rec.email,
      p_person_party_id   => l_person_party_id,
      p_password          => l_password,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      x_user_id           => l_user_id,
      x_password          => l_password_returned
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO supplier_user_reg_approve_sp;
      RETURN;
   END IF;

   -- grant responsibilities
   grant_resps(p_registration_id => p_registration_id,
               p_user_id         => l_user_id,
               x_return_status   => x_return_status,
               x_msg_count       => x_msg_count,
               x_msg_data        => x_msg_data
               );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO supplier_user_reg_approve_sp;
      RETURN;
   END IF;

   -- set sec attrs
   set_sec_attrs(p_registration_id => p_registration_id,
                 p_user_id         => l_user_id,
                 x_return_status   => x_return_status,
                 x_msg_count       => x_msg_count,
                 x_msg_data        => x_msg_data
               );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO supplier_user_reg_approve_sp;
      RETURN;
   END IF;

   set_user_profile ( p_user_id         => l_user_id,
                      p_registration_id => p_registration_id,
                      x_return_status   => x_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data
                      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO supplier_user_reg_approve_sp;
      RETURN;
   END IF;

   UPDATE fnd_registrations
     SET registration_status = 'APPROVED',
         last_update_date = Sysdate,
         last_update_login = fnd_global.login_id,
         last_updated_by = fnd_global.user_id
     WHERE registration_id = p_registration_id;

   send_approval_ntf
     (p_registration_id => p_registration_id,
      p_is_invited      => is_invited(p_registration_id),
      p_is_user_in_oid  => l_user_in_oid,
      p_user_name       => Upper(l_rec.requested_user_name),
      p_password        => l_password
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO supplier_user_reg_approve_sp;
      RETURN;
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO supplier_user_reg_approve_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_data := Sqlerrm;
      x_msg_count := 1;
      RETURN;
END approve;

PROCEDURE reject
  (p_registration_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS
     l_email         fnd_registrations.email%TYPE;
     l_language_code fnd_registrations.language_code%TYPE;
     event_id Number;
BEGIN
   SAVEPOINT supplier_user_reject_sp;
   UPDATE fnd_registrations
     SET registration_status = 'REJECTED',
         last_update_date = Sysdate,
         last_update_login = fnd_global.login_id,
         last_updated_by = fnd_global.user_id
     WHERE registration_id = p_registration_id;

   SELECT email, language_code
     INTO l_email, l_language_code
     FROM fnd_registrations
    WHERE registration_id = p_registration_id;

   send_rejection_ntf
     (p_registration_id => p_registration_id,
      p_email           => l_email,
      p_language_code   => l_language_code
      );

   x_return_status := fnd_api.g_ret_sts_success;

/* Begin Supplier Hub - Supplier Data Publication */
      /* Raise Supplier User Creation event*/
     event_id:= pos_appr_rej_supp_event_raise.raise_appr_rej_supp_event('oracle.apps.pos.supplier.rejectsupplieruser', p_registration_id, '');

/* End Supplier Hub - Supplier Data Publication */

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO supplier_user_reg_reject_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_data := Sqlerrm;
      x_msg_count := 1;
      RETURN;
END reject;

PROCEDURE invite
  (p_registration_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS
     l_email         fnd_registrations.email%TYPE;
     l_language_code fnd_registrations.language_code%TYPE;
     l_reg_key       fnd_registrations.registration_key%TYPE;
BEGIN
   SAVEPOINT supplier_user_invite_sp;
   UPDATE fnd_registrations
     SET registration_status = 'INVITED',
         last_update_date = Sysdate,
         last_update_login = fnd_global.login_id,
         last_updated_by = fnd_global.user_id
     WHERE registration_id = p_registration_id;

   SELECT email, language_code, registration_key
     INTO l_email, l_language_code, l_reg_key
     FROM fnd_registrations
    WHERE registration_id = p_registration_id;

   send_invitation_ntf
     (p_registration_id => p_registration_id,
      p_email           => l_email,
      p_language_code   => l_language_code,
      p_note            => get_note(p_registration_id),
      p_invitation_key  => l_reg_key
      );
   x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count := 1;
      x_msg_data := Sqlerrm;
      ROLLBACK TO supplier_user_invite_sp;
END invite;

PROCEDURE respond
  (p_registration_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS
     CURSOR l_cur IS
        SELECT fr.first_name, fr.last_name,
               fr.email, fr.language_code, fr.registration_key,
               frd1.field_value_string vendor_name,
               frd2.field_value_number approver_id,
               fu.user_name
          FROM fnd_registration_details frd1,
               fnd_registration_details frd2,
               fnd_registrations fr,
               fnd_user fu
         WHERE frd1.registration_id = fr.registration_id
           AND frd1.field_name = 'Supplier Name'
           AND frd2.registration_id = fr.registration_id
           AND frd2.field_name = 'Approver ID'
           AND fr.registration_id = p_registration_id
           AND fu.user_id = frd2.field_value_number;

     l_rec l_cur%ROWTYPE;
BEGIN
   SAVEPOINT supplier_user_respond_sp;
   UPDATE fnd_registrations
     SET registration_status = 'REGISTERED',
         last_update_date = Sysdate,
         last_update_login = fnd_global.login_id,
         last_updated_by = fnd_global.user_id
     WHERE registration_id = p_registration_id;

   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;

   send_respond_ntf
     (p_registration_id => p_registration_id,
      p_first_name      => l_rec.first_name,
      p_last_name       => l_rec.last_name,
      p_vendor_name     => l_rec.vendor_name,
      p_approver_role   => l_rec.user_name
      );

   x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count := 1;
      x_msg_data := Sqlerrm;
      ROLLBACK TO supplier_user_respond_sp;
END respond;

/*---------------------------------------

public
Procedure to set profile options for external user.
This procedure set the APPS_FRAMEWORK_AGENT and
APPS_WEB_AGENT for external user

*/

PROCEDURE set_profile_opt_ext_user
(p_userid in number)
is
lv_external_web_agent fnd_profile_option_values.profile_option_value%TYPE := NULL;
lv_ext_servlet_agent fnd_profile_option_values.profile_option_value%TYPE := NULL;
lv_pattern   VARCHAR2(40);
lv_flag      VARCHAR2(40);
lv_proc_name VARCHAR2(30) := 'set_profile_opt_ext_user';
begin

  fnd_profile.get('POS_EXTERNAL_URL', lv_external_web_agent);
  fnd_profile.get('POS_EXTERNAL_URL', lv_ext_servlet_agent);

  IF ( lv_external_web_agent IS NOT NULL ) THEN

     lv_pattern := '/pls';
     lv_flag    := ''; -- we want it to be case sensitive for now.
     If (owa_pattern.match(lv_external_web_agent,lv_pattern, lv_flag)) then
        -- The external profile still points to icx web site.

        IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'Setting user level APPS_WEB_AGENT profile option value');
        END IF;

        IF ( fnd_profile.save( x_name => 'APPS_WEB_AGENT',
                            x_value => lv_external_web_agent,
                            x_level_name => 'USER',
                            x_level_value => p_userid ) ) THEN

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_WEB_AGENT profile option value set');
            END IF;

        ELSE

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_WEB_AGENT profile option value fail');
            END IF;

        END IF;

        owa_pattern.change(lv_ext_servlet_agent, '/pls.*', '/OA_HTML');
        IF ( fnd_profile.save( x_name => 'APPS_SERVLET_AGENT',
                            x_value => lv_ext_servlet_agent,
                            x_level_name => 'USER',
                            x_level_value => p_userid ) ) THEN

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_SERVLET_AGENT profile option value set');
            END IF;

        ELSE

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_SERVLET_AGENT profile option value fail');
            END IF;

        END IF;

        owa_pattern.change(lv_ext_servlet_agent, '/OA_HTML.*', '');
        IF ( fnd_profile.save( x_name => 'APPS_FRAMEWORK_AGENT',
                            x_value => lv_ext_servlet_agent,
                            x_level_name => 'USER',
                            x_level_value => p_userid ) ) THEN

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_FRAMEWORK_AGENT profile option value set');
            END IF;

        ELSE

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_FRAMEWORK_AGENT profile option value fail');
            END IF;

        END IF;
     ELSE
        IF ( fnd_profile.save( x_name => 'APPS_FRAMEWORK_AGENT',
                            x_value => lv_ext_servlet_agent,
                            x_level_name => 'USER',
                            x_level_value => p_userid ) ) THEN

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_FRAMEWORK_AGENT profile option value set');
            END IF;

        ELSE

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_FRAMEWORK_AGENT profile option value fail');
            END IF;

        END IF;
        -- set only the framework agent. there is no way to set web agent
        -- as we dont know the external dbc name.
        lv_ext_servlet_agent := lv_ext_servlet_agent || '/OA_HTML';
        IF ( fnd_profile.save( x_name => 'APPS_SERVLET_AGENT',
                            x_value => lv_ext_servlet_agent,
                            x_level_name => 'USER',
                            x_level_value => p_userid ) ) THEN

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_servlet_AGENT profile option value set');
            END IF;

        ELSE

            IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'User level APPS_servlet_AGENT profile option value fail');
            END IF;

        END IF;
     End if;

  ELSE

     IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.' || lv_proc_name, 'POS_EXTERNAL_URL is not set');
     END IF;

  END IF;


end set_profile_opt_ext_user;


-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_APPRV_REG_USR_SUBJECT
--Type:
--  Function
--Function:
--  It returns the tokens replaced FND message to Notification Message Subject
--Function Usage:
--  This function is used to replace the workflow message subject by FND Message & its tokens
--Logic Implemented:
-- The FND Message Name 'POS_APPRV_REG_USER_SUBJECT' will be replaced with
-- corresponding Message Text and tokens inside the Message Text also be replaced.
-- Then, replaced FND message will be return to the corresponding attribute
--Parameters:
--  Enterprise Name
--IN:
--  Enterprise Name
--OUT:
--  l_document
--Bug Number for reference:
--  8325979
--End of Comments
------------------------------------------------------------------------------

FUNCTION GET_APPRV_REG_USR_SUBJECT(p_enterprise_name IN VARCHAR2)
RETURN VARCHAR2  IS
l_document VARCHAR2(32000);

BEGIN

        fnd_message.set_name('POS','POS_APPRV_REG_USER_SUBJECT');
        fnd_message.set_token('ENTERPRISE_NAME', p_enterprise_name);
        l_document :=  fnd_message.get;
  RETURN l_document;
END GET_APPRV_REG_USR_SUBJECT;

-------------------------------------------------------------------------------
--Start of Comments
--Name: GENERATE_APPRV_REG_USR_BODY
--Type:
--  Procedure
--Procedure:
--  It returns the tokens replaced FND message to Notification Message Body
--Procedure Usage:
--  It is being used to replace the workflow message Body by FND Message & its tokens
--Logic Implemented:
-- For HTML Body:
-- The FND Message Name 'POS_APPRV_REG_USER_HTML_BODY' will be replaced with
-- corresponding Message Text and tokens inside the Message Text also be replaced.
-- Then, replaced FND message will be return to the corresponding attribute
-- For TEXT Body:
-- The FND Message Name 'POS_APPRV_REG_USER_TEXT_BODY' will be replaced with
-- corresponding Message Text and tokens inside the Message Text also be replaced.
-- Then, replaced FND message will be return to the corresponding attribute
--Parameters:
--  document_id
--IN:
--  document_id
--OUT:
--  document
--Bug Number for reference:
--  8325979
--End of Comments
------------------------------------------------------------------------------

PROCEDURE GENERATE_APPRV_REG_USR_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_note          VARCHAR2(32000) := '';
l_enterprisename VARCHAR2(1000) := '';
l_url           VARCHAR2(3000) := '';
l_email    VARCHAR2(1000) := '';
l_username      VARCHAR2(500) := '';
l_password      VARCHAR2(100) := '';
l_disp_type     VARCHAR2(20) := 'text/plain';
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
BEGIN

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.GENERATE_APPRV_REG_USR_BODY', 'p_document_id ' || p_document_id);
  END IF;

  l_item_type := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_item_key := substr(p_document_id, instr(p_document_id, ':') + 1, length(p_document_id));

  IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.GENERATE_APPRV_REG_USR_BODY', 'l_item_type ' || l_item_type);
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.GENERATE_APPRV_REG_USR_BODY', 'l_item_key ' || l_item_key);
  END IF;

  l_enterprisename := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                         	itemkey    => l_item_key,
                                         	aname      => 'ENTERPRISE_NAME');
  l_url :=  wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                         	itemkey    => l_item_key,
                                         	aname      => 'LOGON_PAGE_URL');
  l_username := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                         	itemkey    => l_item_key,
                                         	aname      => 'ASSIGNED_USER_NAME');
  l_password := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                         	itemkey    => l_item_key,
                                         	aname      => 'FIRST_LOGON_KEY');
  l_email := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                         	itemkey    => l_item_key,
                                         	aname      => 'CONTACT_EMAIL');

  l_note := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                         	itemkey    => l_item_key,
                                         	aname      => 'NOTE');

 IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.GENERATE_APPRV_REG_USR_BODY', 'l_enterprisename ' || l_enterprisename);
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.GENERATE_APPRV_REG_USR_BODY', 'l_url ' || l_url);
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.GENERATE_APPRV_REG_USR_BODY', 'l_username ' || l_username);
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.GENERATE_APPRV_REG_USR_BODY', 'l_password ' || l_password);
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.GENERATE_APPRV_REG_USR_BODY', 'l_adminemail ' || l_email);
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.GENERATE_APPRV_REG_USR_BODY', 'l_note ' || l_note);
    fnd_log.string(fnd_log.level_procedure, g_log_module_name || '.GENERATE_APPRV_REG_USR_BODY', 'display_type ' || display_type);
  END IF;

  IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
        fnd_message.set_name('POS','POS_APPRV_REG_USER_HTML_BODY');
        fnd_message.set_token('ENTERPRISE_NAME',l_enterprisename);
        fnd_message.set_token('LOGON_PAGE_URL',l_url);
        fnd_message.set_token('ASSIGNED_USER_NAME',l_username);
        fnd_message.set_token('FIRST_LOGON_KEY',l_password);
        fnd_message.set_token('CONTACT_EMAIL',l_email);
        fnd_message.set_token('NOTE',l_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
        l_disp_type:= display_type;
        fnd_message.set_name('POS','POS_APPRV_REG_USER_TEXT_BODY');
        fnd_message.set_token('ENTERPRISE_NAME',l_enterprisename);
        fnd_message.set_token('LOGON_PAGE_URL',l_url);
        fnd_message.set_token('ASSIGNED_USER_NAME',l_username);
        fnd_message.set_token('FIRST_LOGON_KEY',l_password);
        fnd_message.set_token('CONTACT_EMAIL',l_email);
        fnd_message.set_token('NOTE',l_note);
        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);

  END IF;

EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GENERATE_APPRV_REG_USR_BODY;

END pos_supplier_user_reg_pkg;

/
