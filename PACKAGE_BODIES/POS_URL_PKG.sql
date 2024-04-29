--------------------------------------------------------
--  DDL for Package Body POS_URL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_URL_PKG" AS
/* $Header: POSURLB.pls 120.4.12010000.2 2011/11/01 18:31:17 jatraman ship $ */

FUNCTION get_menu_function_context (p_notif_performer   IN VARCHAR2) RETURN menu_function_parameter_rec

   IS
        l_menu_function_parameter_rec       menu_function_parameter_rec;

   BEGIN
        IF p_notif_performer = 'BUYER' THEN
                    l_menu_function_parameter_rec.OAHP := 'POS_HT_SP_HP';
                    l_menu_function_parameter_rec.OASF := 'POS_HT_SP_B_SUPP';
        ELSE
                    l_menu_function_parameter_rec.OAHP := 'ISP_HOMEPAGE_MENU';
                    l_menu_function_parameter_rec.OASF := 'POS_HOME';
        END IF;
   RETURN l_menu_function_parameter_rec;

END get_menu_function_context;


FUNCTION get_base_buyer_url RETURN VARCHAR2
   IS
        l_base_url VARCHAR2(240);
   BEGIN

        l_base_url := get_internal_url;
        IF ( substr(l_base_url, -1, 1) = '/' ) THEN
              RETURN l_base_url ||  'OA_HTML/OA.jsp';
        ELSE
              RETURN l_base_url || '/' || 'OA_HTML/OA.jsp';
        END IF;

        RETURN l_base_url || 'OA_HTML/OA.jsp';

END get_base_buyer_url;

FUNCTION get_page_url (p_url_parameters_tab url_parameters_tab
                              ,p_notif_performer  VARCHAR2) RETURN VARCHAR2
   IS
           i PLS_INTEGER;
           l_page_url VARCHAR2(2000);

   BEGIN

       IF p_notif_performer = 'BUYER' THEN
                l_page_url := get_base_buyer_url;
       ELSE
                l_page_url := get_base_buyer_url;
       END IF;

       -- appending each parameter as passed in
           FOR i IN p_url_parameters_tab.FIRST..p_url_parameters_tab.LAST
           LOOP
               IF (i = 1) THEN
                 l_page_url := l_page_url || '?';
               ELSE
                 l_page_url := l_page_url || '&';
               END IF;

               l_page_url := l_page_url || p_url_parameters_tab(i).name || '=' || p_url_parameters_tab (i).value;
           END LOOP;

        RETURN l_page_url;

END get_page_url;

FUNCTION get_dest_page_url (    p_dest_func IN VARCHAR2,
                                p_notif_performer IN VARCHAR2)

RETURN VARCHAR2
   IS

     l_url_parameters_tab    url_parameters_tab;
     l_menu_function_parameter_rec   menu_function_parameter_rec;

   BEGIN

    l_menu_function_parameter_rec := get_menu_function_context(p_notif_performer => p_notif_performer);

    -- This is the redirect page which will get these parameters and redirect
    -- to the final page
    l_url_parameters_tab(1).name := 'OAFunc';
    l_url_parameters_tab(1).value := 'POS_NOTIF_LINK_REDIRECT';
    l_url_parameters_tab(2).name := 'OAHP';
    l_url_parameters_tab(2).value := l_menu_function_parameter_rec.OAHP;
    l_url_parameters_tab(3).name := 'OASF';
    l_url_parameters_tab(3).value := l_menu_function_parameter_rec.OASF;
    l_url_parameters_tab(4).name := 'destFunc';
    l_url_parameters_tab(4).value := p_dest_func;

    -- This will be replaced by the actual notification id during runtime
    l_url_parameters_tab(5).name := 'notificationId';
    l_url_parameters_tab(5).value := '&#NID';

    RETURN get_page_url(p_url_parameters_tab => l_url_parameters_tab
                           ,p_notif_performer => p_notif_performer);
END get_dest_page_url;

-- Get the vendor id for the
FUNCTION get_ntf_vendor_id (p_ntf_id IN NUMBER) RETURN NUMBER
  IS
  CURSOR wf_item_cur IS
  SELECT item_type,
         item_key
  FROM   wf_item_activity_statuses
  WHERE  notification_id  = p_ntf_id;

  CURSOR wf_notif_context_cur IS
  SELECT SUBSTR(context,1,INSTR(context,':',1)-1),
         SUBSTR(context,INSTR(context,':')+1,
                       (INSTR(context,':',1,2) - INSTR(context,':')-1))
  FROM   wf_notifications
  WHERE  notification_id   = p_ntf_id;

  l_itemtype WF_ITEM_ACTIVITY_STATUSES.item_type%TYPE;
  l_itemkey  WF_ITEM_ACTIVITY_STATUSES.item_key%TYPE;

BEGIN

   -- Fetch the item_type and item_key values from
   -- wf_item_activity_statuses for a given notification_id.
   OPEN wf_item_cur;
   FETCH wf_item_cur INTO l_itemtype, l_itemkey;
   CLOSE wf_item_cur;

   -- If the wf_item_activity_statuses does not contain an entry,
   -- then parse the wf_notifications.context field to
   -- get the item_type and item_key values for a given notification_id.
   IF ((l_itemtype IS NULL) AND (l_itemkey IS NULL))
   THEN
        OPEN  wf_notif_context_cur;
        FETCH wf_notif_context_cur INTO l_itemtype, l_itemkey;
        CLOSE wf_notif_context_cur;
   END IF;

   if( l_itemkey is not null) then

           return wf_engine.GetItemAttrNumber (itemtype => l_itemtype,
                                       itemkey  => l_itemkey,
                                       aname    => 'VENDOR_ID');
   end if;

   -- No Valid value found.
   return -1;

END get_ntf_vendor_id;

-- this is a private package function
FUNCTION get_protocol_host_port (p_url IN VARCHAR2)
  RETURN VARCHAR2
  IS
     l_position NUMBER;
     l_value VARCHAR2(500);
BEGIN
   l_value := p_url;

   IF l_value IS NULL THEN
      RETURN NULL;
   END IF;

   IF NOT owa_pattern.match(l_value, '^https?://.*', '') THEN
      -- The url in the value of the profile option
      -- is not a valid url. l_value is returned without further processing.
      RETURN l_value;
   END IF;

   l_position:= Instr(l_value, '/', 1, 3);
   IF l_position = 0 THEN
      -- missing the last /
      l_value := l_value || '/';
    ELSE
      l_value := Substr(l_value, 1, l_position);
   END IF;

   RETURN l_value;

END get_protocol_host_port;

-- Return the url for the external web server for suppliers.
-- Example: http://host.example.com:8888/
FUNCTION get_external_url RETURN VARCHAR2
  IS
     -- the size of l_value is larger than the size 240 of
     -- the profile_option_value column in
     -- fnd_profile_option_values table
     l_value VARCHAR2(500);
     l_position NUMBER;
BEGIN
   l_value := fnd_profile.value('POS_EXTERNAL_URL');
   RETURN get_protocol_host_port(l_value);
END get_external_url;

FUNCTION get_site_apps_servlet_agent
  RETURN VARCHAR2
  IS
     CURSOR l_cur IS
	SELECT fpov.profile_option_value
	  FROM fnd_profile_options fpo,
	  fnd_profile_option_values fpov
	  WHERE fpo.application_id = 0
	  AND fpo.profile_option_name = 'APPS_SERVLET_AGENT'
	  AND fpo.profile_option_id = fpov.profile_option_id
	  AND fpov.level_id = 10001
	  AND fpov.application_id = 0;

     l_value fnd_profile_option_values.profile_option_value%TYPE;

BEGIN
   OPEN l_cur;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RETURN NULL;
   END IF;

   FETCH l_cur INTO l_value;
   CLOSE l_cur;
   RETURN l_value;

END get_site_apps_servlet_agent;

-- Return the url for an internal web server.
-- Example value, http://host.example.com:8888/
FUNCTION get_internal_url RETURN VARCHAR2
  IS
     -- the size of l_value is larger than the size 240 of
     -- the profile_option_value column in
     -- fnd_profile_option_values table
     l_value VARCHAR2(500);
     l_position NUMBER;

BEGIN
   l_value := fnd_profile.value('POS_INTERNAL_URL');
   IF l_value IS NULL THEN
      l_value := get_site_apps_servlet_agent;
   END IF;

   l_value := get_protocol_host_port(l_value);
   RETURN l_value;

END get_internal_url;

-- Return the login url at the external web server for suppliers.
FUNCTION get_external_login_url RETURN VARCHAR2
  IS
     l_url VARCHAR2(3000);
     l_path VARCHAR2(500);
BEGIN
   l_path := fnd_profile.value('POS_EXTERNAL_LOGON_PATH');
   IF l_path IS NULL THEN
     l_url := fnd_sso_manager.getloginurl;
     l_url := regexp_replace(l_url,'https?://[^/]+/',get_external_url);
   ELSE
     l_url := get_external_url || l_path;
   END IF;
   RETURN l_url;
END get_external_login_url;

-- Return the login url at an internal web server
FUNCTION get_internal_login_url RETURN VARCHAR2
  IS
BEGIN
   RETURN fnd_sso_manager.getloginurl;
END get_internal_login_url;

FUNCTION get_buyer_login_url RETURN VARCHAR2
   IS
        l_base_url VARCHAR2(240);
   BEGIN

        l_base_url := get_internal_url;
        IF ( substr(l_base_url, -1, 1) = '/' ) THEN
              RETURN l_base_url ||  'OA_HTML/AppsLogin';
        ELSE
              RETURN l_base_url || '/' || 'OA_HTML/AppsLogin';
        END IF;

        RETURN l_base_url || 'OA_HTML/AppsLogin';

END get_buyer_login_url;

END pos_url_pkg;

/
