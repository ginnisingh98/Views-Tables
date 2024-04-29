--------------------------------------------------------
--  DDL for Package Body POS_ANON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ANON_PKG" AS
/* $Header: POSANONB.pls 120.0 2005/06/01 17:34:16 appldev noship $ */

g_log_module_name VARCHAR2(30) := 'pos.plsql.POSANONB';

FUNCTION make_anonymous_login(p_registration_key IN VARCHAR2,
                              x_session_id       OUT NOCOPY NUMBER,
                              x_transaction_id   OUT NOCOPY NUMBER)
RETURN VARCHAR2
IS
    l_validate          BOOLEAN;
    l_url               VARCHAR2(4000);
    l_dbc               VARCHAR2(240);
    l_language_code     VARCHAR2(30);
    l_region            VARCHAR2(30);
    l_access_key        VARCHAR2(2000);
    l_admin_mode        VARCHAR2(2000);
BEGIN
    l_region := 'My Region';
    IF NOT icx_sec.validateSession(c_validate_only => 'Y')
    THEN
        x_session_id := icx_sec.createSession(
                            p_user_id       => 6,
                            c_mode_code     => '115X');
        l_validate := icx_sec.validateSessionPrivate(
                            c_session_id    => x_session_id,
                            c_validate_only => 'Y');
--        owa_util.mime_header('text/html',FALSE);
--        icx_sec.sendsessioncookie(l_session_id);

        x_transaction_id := icx_sec.createTransaction(
                            p_session_id        => x_session_id,
                            p_resp_appl_id      => 178,
                            p_responsibility_id => 20873,
                            p_security_group_id => 0);

        icx_sec.updateSessionContext(
                            p_application_id    =>178,
                            p_responsibility_id =>20873,
                            p_security_group_id => 0,
                            p_session_id        => x_session_id,
                            p_transaction_id    => x_transaction_id);
    ELSE

      BEGIN

        SELECT  max(transaction_id)
        INTO    x_transaction_id
        FROM    icx_transactions
        WHERE   session_id = icx_sec.g_session_id
        AND     responsibility_id = icx_sec.g_responsibility_id
        AND     security_group_id = icx_sec.g_security_group_id
        AND     function_id = icx_sec.g_function_id
        GROUP BY transaction_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN

            SELECT  icx_transactions_s.nextval
            INTO    x_transaction_id
            FROM    dual;

        END;
    END IF;

    l_url := fnd_web_config.trail_slash(fnd_profile.value('APPS_FRAMEWORK_AGENT'));
    fnd_profile.get(
                    name => 'APPS_DATABASE_ID',
                    val  => l_dbc);

    IF l_dbc IS null
    THEN
       l_dbc := FND_WEB_CONFIG.DATABASE_ID;
    END IF;

    l_url := l_url || 'OA_HTML/OA.jsp?page=/oracle/apps/pos/registration/webui/UsrRegMainPG' ||
             '&'||'akRegionApplicationId=177'||'&'||'dbc=' || l_dbc ||
             '&'||'transaction_id=' || x_transaction_id ||
             '&'||'registrationKey=' || p_registration_key;

    return l_url;
END make_anonymous_login;

-- Check to see if the POS_SUPPLIER_GUEST_USER responsibility has the right value
-- of APPS_FRAMEWORK_AGENT profile_option. If not, set it based on external url.
PROCEDURE check_guest_resp_fwk_agent IS
   CURSOR l_hier_cur IS
      SELECT resp_enabled_flag,
	hierarchy_type
        FROM fnd_profile_options
        WHERE profile_option_name = 'APPS_FRAMEWORK_AGENT'
        AND Nvl(start_date_active, Sysdate) <= Sysdate
        AND Nvl(end_date_active, sysdate) >= sysdate;

   l_hier_rec l_hier_cur%ROWTYPE;

   CURSOR l_resp_cur IS
      SELECT responsibility_id, application_id
	FROM fnd_responsibility
	WHERE responsibility_key = 'POS_SUPPLIER_GUEST_USER'
	AND application_id =
	(SELECT application_id FROM fnd_application WHERE application_short_name = 'POS');

   l_resp_rec l_resp_cur%ROWTYPE;

   l_value fnd_profile_option_values.profile_option_value%TYPE;

   l_result BOOLEAN;

BEGIN

   OPEN l_hier_cur;
   FETCH l_hier_cur INTO l_hier_rec;
   IF l_hier_cur%notfound THEN
      CLOSE l_hier_cur;
      RETURN; -- something is wrong, but we do nothing
   END IF;
   CLOSE l_hier_cur;

   --    dbms_output.put_line('resp enable ' || l_hier_rec.resp_enabled_flag );
   --    dbms_output.put_line('hier type ' || l_hier_rec.hierarchy_type );

   IF l_hier_rec.resp_enabled_flag = 'Y' AND
     l_hier_rec.hierarchy_type = 'SECURITY' THEN

      OPEN l_resp_cur;
      FETCH l_resp_cur INTO l_resp_rec;
      IF l_resp_cur%notfound THEN
	 CLOSE l_resp_cur;
	 RETURN; -- unlikely to happen
      END IF;
      CLOSE l_resp_cur;

      l_value := pos_url_pkg.get_external_url;

      --dbms_output.put_line('value ' || l_value);

      IF l_value IS NULL OR
	l_value = fnd_profile.value_specific
	(name              => 'APPS_FRAMEWORK_AGENT',
	 user_id           => NULL,
	 responsibility_id => l_resp_rec.responsibility_id,
	 application_id    => l_resp_rec.application_id,
	 org_id            => NULL,
	 server_id         => NULL
	 ) THEN
	 NULL;
       ELSE
	 -- dbms_output.put_line('setting');
	 l_result := fnd_profile.save
	   (x_name               => 'APPS_FRAMEWORK_AGENT',
	    x_value              => l_value,
	    x_level_name         => 'RESP',
	    x_level_value        => l_resp_rec.responsibility_id,
	    x_level_value_app_id => l_resp_rec.application_id
	    );
      END IF;

   END IF;
END check_guest_resp_fwk_agent;

PROCEDURE confirm_has_resp(
              p_responsibility_key      IN  VARCHAR2)
  IS
     l_assignment_exists BOOLEAN;
     l_app_id        NUMBER;
     l_resp_id       NUMBER;
     l_start_date    DATE;
     l_end_date      DATE;
     l_found_in_view BOOLEAN;
     l_user_name     FND_USER.USER_NAME%TYPE;
     lv_proc_name VARCHAR2(30) := 'confirm_has_resp';

     CURSOR l_user_cur
       IS
	 SELECT user_name
	   FROM   FND_USER
	   WHERE  user_id = 6
	   AND    start_date < sysdate
	   AND    (end_date IS NULL OR end_date > sysdate);

     CURSOR l_resp_cur
       IS
	 SELECT application_id, responsibility_id
	   FROM   FND_RESPONSIBILITY
	   WHERE  responsibility_key = p_responsibility_key
	   AND    start_date < sysdate
	   AND    (end_date IS NULL OR end_date > sysdate);

    CURSOR l_assignment_cur
      IS
	 SELECT end_date, start_date
	   FROM   FND_USER_RESP_GROUPS_DIRECT
	   WHERE  user_id = 6
	   AND    responsibility_id = l_resp_id;

BEGIN

   OPEN l_user_cur;
   FETCH l_user_cur INTO l_user_name;
   IF l_user_cur%NOTFOUND THEN
     -- the user has been end-dated
     CLOSE l_user_cur;
     IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'GUEST user has been end-dated');
     END IF;
     RETURN;
   END IF;
   CLOSE l_user_cur;

   OPEN l_resp_cur;
   FETCH l_resp_cur INTO   l_app_id, l_resp_id;
   IF l_resp_cur%NOTFOUND THEN
     -- there is no such responsibility or the responsibility has been
     -- end-dated. do not assign the responsibility in this case
     -- should have end-dated the assignment too. but presumably, there is
     -- no such assignment (because Form prevents the assignment...)
     CLOSE l_resp_cur;
     IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       fnd_log.string(fnd_log.level_exception, g_log_module_name || '.' || lv_proc_name, 'guest responsibility has been end-dated');
     END IF;
     RETURN;
   END IF;
   CLOSE l_resp_cur;

   l_assignment_exists :=
     fnd_user_resp_groups_api.assignment_exists
     (user_id => 6,
      responsibility_id => l_resp_id,
      responsibility_application_id => l_app_id,
      security_group_id => 0
      );

   IF l_assignment_exists = FALSE THEN
      FND_USER_RESP_GROUPS_API.insert_assignment
	( user_id => 6,
	  responsibility_id => l_resp_id,
	  responsibility_application_id => l_app_id,
	  security_group_id => 0,
	  start_date => sysdate,
	  end_date => NULL,
	  description => p_responsibility_key);
      --RETURN;
   ELSE
     -- assignment already exists here
     OPEN l_assignment_cur;
     FETCH l_assignment_cur INTO l_end_date, l_start_date;
     l_found_in_view := l_assignment_cur%found;
     CLOSE l_assignment_cur;

     IF NOT (l_found_in_view AND
              (l_end_date IS NULL OR l_end_date > Sysdate) AND
              (l_start_date IS NULL OR l_start_date <= Sysdate)) THEN

       IF l_start_date IS NULL OR l_start_date > Sysdate THEN
          l_start_date := Sysdate;
       END IF;

       -- assignment exists here but it is not active now
       -- due to start date or end_date
       fnd_user_resp_groups_api.update_assignment
         ( user_id            	     => 6,
           responsibility_id  	     => l_resp_id,
           responsibility_application_id => l_app_id,
           security_group_id             => 0,
           start_date                    => l_start_date,
           end_date                      => NULL,
           description                   => p_responsibility_key);
     END IF;
   END IF;

   -- make sure that the guest resp has the right fwk agent
   -- when not using server profile option
   check_guest_resp_fwk_agent;

END confirm_has_resp;

PROCEDURE get_various_login_info(
              p_raw_session_id          IN  VARCHAR2,
              p_raw_transaction_id      IN  VARCHAR2,
              p_responsibility_key      IN  VARCHAR2,
              x_dbc_name                OUT NOCOPY VARCHAR2,
              x_enc_session_id          OUT NOCOPY VARCHAR2,
              x_enc_transaction_id      OUT NOCOPY VARCHAR2,
              x_application_id          OUT NOCOPY VARCHAR2,
              x_responsibility_id       OUT NOCOPY VARCHAR2)
IS
    l_has_resp      NUMBER;
BEGIN
    x_enc_session_id     := icx_call.encrypt3(p_raw_session_id);
    x_enc_transaction_id := icx_call.encrypt3(p_raw_transaction_id);
    fnd_profile.get(
                    name => 'APPS_DATABASE_ID',
                    val  => x_dbc_name);
    IF x_dbc_name IS NULL
    THEN
        x_dbc_name := FND_WEB_CONFIG.DATABASE_ID;
    END IF;

    SELECT application_id, responsibility_id
    INTO   x_application_id, x_responsibility_id
    FROM   FND_RESPONSIBILITY
    WHERE  responsibility_key = p_responsibility_key;

END get_various_login_info;

PROCEDURE get_various_session_info(
    x_session_cookie_name     OUT NOCOPY VARCHAR2,
    x_session_cookie_domain   OUT NOCOPY VARCHAR2)
IS
    l_cookie_name   icx_parameters.session_cookie_name%TYPE;
    l_cookie_domain icx_parameters.session_cookie_domain%TYPE;
BEGIN

  SELECT session_cookie_name, session_cookie_domain
  INTO   l_cookie_name, l_cookie_domain
  FROM   icx_parameters;

    x_session_cookie_name   := l_cookie_name;
    x_session_cookie_domain := l_cookie_domain;

END get_various_session_info;

END pos_anon_pkg;

/
