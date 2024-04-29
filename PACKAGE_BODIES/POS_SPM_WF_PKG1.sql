--------------------------------------------------------
--  DDL for Package Body POS_SPM_WF_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SPM_WF_PKG1" AS
/* $Header: POSSPM1B.pls 120.30.12010000.38 2014/03/25 09:57:17 spapana ship $ */

TYPE g_refcur IS ref CURSOR;

g_package_name CONSTANT VARCHAR2(30) := 'POS_SPM_WF_PKG1';

g_log_module CONSTANT VARCHAR2(30) := 'POSSPM1B';

g_supplier_function_name CONSTANT fnd_form_functions.function_name%TYPE := 'POS_HT_SP_S_SUP_DET';

g_new_line CONSTANT VARCHAR2(1) := '
';
g_actn_send_supp_invite CONSTANT VARCHAR2(20) := 'SEND_INVITE';


    --
    -- Begin Supplier Hub: OSN Integration
    --
    FUNCTION get_osn_message RETURN VARCHAR2 IS
    --
    -- In this project, we have added a new token OSN_MESSAGE to the
    -- FND message text.  This needs to be substituted with a message
    -- that invites the supplier to sign up at Oracle Supplier Network.
    -- Look into profile POS_SM_OSN_REG_MESSAGE to find a FND message name.
    -- Then get the message text and put it into the OSN_MESSAGE token.
    -- This utility function returns the OSN message or '' if
    -- not found.
    -- Tue Sep  1 20:45:01 PDT 2009 bso R12.1.2
    --
        l_message_name VARCHAR2(240);
    BEGIN
        --
        -- First get profile value to find the FND message name.
        -- Then get and return the message text.
        --
        l_message_name := fnd_profile.value('POS_SM_OSN_REG_MESSAGE');

        --
        -- In PL/SQL NULL is equivalent to ''.  Special NULL checking
        -- logic is not required in this function.
        --
        RETURN fnd_message.get_string('POS', l_message_name);
    END get_osn_message;


    FUNCTION to_html(p_text VARCHAR2) RETURN VARCHAR2 IS
    --
    -- Private function to convert text to HTML by adding line break tags
    --
    BEGIN
             --
             -- Replace double newlines with <P> first and then
             -- single newline with <BR>
             -- Avoid using local variables to save space.
             --
             RETURN
                 REPLACE(
                     REPLACE(p_text, fnd_global.newline || fnd_global.newline, '<P>'),
                     fnd_global.newline,
                     '<BR>');
    END to_html;
    --
    -- End Supplier Hub: OSN Integration
    --


FUNCTION get_function_id (p_function_name IN VARCHAR2) RETURN NUMBER IS
   CURSOR l_cur IS
      SELECT function_id
        FROM fnd_form_functions
        WHERE function_name = p_function_name;
   l_function_id NUMBER;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_function_id;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;
   RETURN l_function_id;
END get_function_id;

-- utility to add user to a workflow adhoc role
-- using the new procedure wf_directory.addUserToAdHocRle2
PROCEDURE addusertoadhocrole
  (p_role_name IN VARCHAR2,
   p_user_name IN VARCHAR2)
  IS
     l_user_table wf_directory.usertable;
BEGIN
   l_user_table(1) := p_user_name;
   wf_directory.adduserstoadhocrole2(p_role_name, l_user_table);
END addusertoadhocrole;

PROCEDURE get_enterprise_name(x_name OUT nocopy VARCHAR2)
  IS
     l_status VARCHAR2(2);
     l_msg    VARCHAR2(1000);
BEGIN
   pos_enterprise_util_pkg.get_enterprise_party_name
     (x_party_name    => x_name,
      x_exception_msg => l_msg,
      x_status        => l_status);
   IF l_status IS NULL OR l_status <> 'S' THEN
      RAISE no_data_found;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001, 'error in get_enterprise_name', TRUE);
END get_enterprise_name;

PROCEDURE get_supplier_name
  (p_vendor_id    IN NUMBER,
   x_vendor_name  OUT nocopy VARCHAR2)
  IS
     CURSOR l_cur IS
        SELECT vendor_name
          FROM ap_suppliers
          WHERE vendor_id = p_vendor_id;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO x_vendor_name;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;
END get_supplier_name;

PROCEDURE get_wf_item_type
  (x_itemtype OUT NOCOPY VARCHAR2)
  IS
BEGIN
   x_itemtype := 'POSSPM1';
END get_wf_item_type;

-- generate a workflow item key
PROCEDURE get_wf_item_key
  (p_process IN  VARCHAR2,
   p_idstr   IN  VARCHAR2,
   x_itemkey OUT NOCOPY VARCHAR2)
  IS
BEGIN
   x_itemkey := 'POSSPM1_' || p_process || '_' || p_idstr || '_' || fnd_crypto.smallrandomnumber;
END get_wf_item_key;

PROCEDURE get_adhoc_role_name
  (p_process IN  VARCHAR2,
   x_name    OUT nocopy VARCHAR2) IS
--l_name wf_roles.name%TYPE;
--l_index NUMBER := 1;
BEGIN
   x_name := 'POSSPM1_' || p_process || '_' ||
     To_char(Sysdate, 'MMDDYYYY_HH24MISS') || '_' || fnd_crypto.smallrandomnumber;
   -- bug 3569374
   --l_name := x_name;
   --WHILE(wf_directory.getroledisplayname(l_name) IS NOT NULL) LOOP
   --   l_name := x_name || '_' || l_index;
   --   l_index := l_index + 1;
   --END LOOP;
   --x_name := l_name;
END get_adhoc_role_name;

PROCEDURE create_adhoc_role
  (p_process IN  VARCHAR2,
   x_name    OUT nocopy VARCHAR2) IS
BEGIN
   get_adhoc_role_name(p_process,x_name);
   wf_directory.CreateAdHocRole
     (role_name         => x_name,
      role_display_name => x_name);
END create_adhoc_role;

PROCEDURE add_user_to_role_from_cur
  (p_refcur IN  g_refcur,
   p_role   IN  VARCHAR2,
   x_count  OUT nocopy NUMBER
   ) IS
      l_count NUMBER;
      l_name wf_roles.name%TYPE;
BEGIN
   l_count := 0;
   WHILE TRUE LOOP
      FETCH p_refcur INTO l_name;
      IF p_refcur%notfound THEN
         EXIT;
      END IF;

      BEGIN
         -- It is possible for the next call to fail
         -- under some cases. For example, if you
         -- just create a new user and the system
         -- has not sync that to the workflow directory,
         -- you would get an exception for name not valid.
         --
         -- In such case, we do not want to stop sending
         -- notification. We would just log the error.
         --
         AddUserToAdHocRole(p_role, l_name);
         l_count := l_count + 1;
      EXCEPTION
         WHEN OTHERS THEN
	    IF ( fnd_log.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	       fnd_log.string(fnd_log.level_exception,
			      g_package_name || '.add_user_to_role_from_cur',
			      'AddUserToAdHocRole failed with error '
			      || sqlerrm);
	    END IF;
      END;
   END LOOP;
   CLOSE p_refcur;
   IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_statement,
                     g_log_module || '.add_user_to_role_from_cur',
                     'count is ' || l_count);
   END IF;
   x_count := l_count;
END add_user_to_role_from_cur;

PROCEDURE get_user_name
  (p_user_id    IN  NUMBER,
   x_first_name OUT nocopy VARCHAR2,
   x_last_name  OUT nocopy VARCHAR2)
  IS
     CURSOR l_per_cur IS
       SELECT ppf.first_name, ppf.last_name
       FROM per_people_f ppf, fnd_user fu
         WHERE fu.employee_id = ppf.person_id
         AND fu.user_id = p_user_id;
     CURSOR l_tca_cur IS
        SELECT hp.person_first_name, hp.person_last_name
          FROM hz_parties hp, fnd_user fu
          WHERE fu.person_party_id = hp.party_id
          AND fu.user_id = p_user_id;
     CURSOR l_fnd_cur IS
        SELECT user_name FROM fnd_user WHERE user_id = p_user_id;
     l_found BOOLEAN;
BEGIN
   l_found := FALSE;
   -- query the user's employee name.
   OPEN l_per_cur;
   FETCH l_per_cur INTO x_first_name, x_last_name;
   l_found := l_per_cur%found;
   CLOSE l_per_cur;
   IF l_found THEN
      RETURN;
   END IF;

   -- query the user's party name.
   OPEN l_tca_cur;
   FETCH l_tca_cur INTO x_first_name, x_last_name;
   l_found := l_tca_cur%found;
   CLOSE l_tca_cur;
   IF l_found THEN
      RETURN;
   END IF;

   -- query the user's username
   OPEN l_fnd_cur;
   FETCH l_fnd_cur INTO x_first_name;
   x_last_name := NULL;
   l_found := l_fnd_cur%found;
   CLOSE l_fnd_cur;

   IF l_found = FALSE THEN
      RAISE no_data_found;
   END IF;
END get_user_name;

PROCEDURE get_current_user_name
   (x_first_name OUT nocopy VARCHAR2,
    x_last_name  OUT nocopy VARCHAR2)
  IS
BEGIN
   get_user_name(fnd_global.user_id, x_first_name, x_last_name);
END get_current_user_name;

PROCEDURE get_user_company_name
  (p_username     IN  VARCHAR2,
   x_company_name OUT nocopy VARCHAR2)
  IS
     CURSOR l_per_cur IS
        SELECT employee_id
          FROM fnd_user
          WHERE user_name = p_username;
     l_employee_id NUMBER;
     l_vendor_id   NUMBER;
BEGIN
   OPEN l_per_cur;
   FETCH l_per_cur INTO l_employee_id;
   IF l_per_cur%notfound THEN
      l_employee_id := NULL;
   END IF;
   CLOSE l_per_cur;

   IF l_employee_id IS NOT NULL THEN
      get_enterprise_name (x_company_name);
    ELSE
      l_vendor_id := pos_vendor_util_pkg.get_po_vendor_id_for_user(p_username);
      IF l_vendor_id IS NOT NULL THEN
         get_supplier_name(l_vendor_id, x_company_name);
       ELSE
         x_company_name := NULL;
      END IF;
   END IF;
END get_user_company_name;

PROCEDURE get_current_user_company_name
  (x_company_name OUT nocopy VARCHAR2)
  IS
BEGIN
   get_user_company_name(fnd_global.user_name, x_company_name);
END get_current_user_company_name;

-- This is a private procedure for setting up the
-- value for the <first name>, <last name> of <company name>
-- item attributes for some of the notifications that have
-- that in the message body
--
-- Note: this is not a generic procedure, and should
-- not be included in the package spec.
PROCEDURE setup_actioner_private
  (itemtype IN VARCHAR2,
   itemkey  IN VARCHAR2
   )
  IS
     l_company_name    ap_suppliers.vendor_name%TYPE;
     l_first_name      hz_parties.person_first_name%TYPE;
     l_last_name       hz_parties.person_last_name%TYPE;
BEGIN
   get_current_user_name(l_first_name, l_last_name);
   get_current_user_company_name(l_company_name);

   wf_engine.SetItemAttrText (itemtype   => itemtype,
                              itemkey    => itemkey,
                              aname      => 'COMPANY_NAME',
                              avalue     => l_company_name);


   wf_engine.SetItemAttrText (itemtype   => itemtype,
                              itemkey    => itemkey,
                              aname      => 'FIRST_NAME',
                              avalue     => l_first_name);

   wf_engine.SetItemAttrText (itemtype   => itemtype,
                              itemkey    => itemkey,
                              aname      => 'LAST_NAME',
                              avalue     => l_last_name);

END setup_actioner_private;

PROCEDURE get_buyers
  (p_event_type IN  VARCHAR2,
   x_cur        OUT nocopy g_refcur
   )
  IS
     l_sql VARCHAR2(1000);
BEGIN
   OPEN x_cur FOR
     SELECT user_name
       FROM fnd_user fu, pos_spmntf_subscription sub
      WHERE fu.user_id = sub.user_id
        AND sub.event_type = p_event_type;
   RETURN;
END get_buyers;

FUNCTION get_address_name_in_req(p_address_request_id IN NUMBER) RETURN VARCHAR2
  IS
     CURSOR l_cur IS
	SELECT Decode(par.party_site_id, NULL, par.party_site_name,
		      (SELECT hps.party_site_name
		       FROM hz_party_sites hps
		       WHERE hps.party_site_id = par.party_site_id
		       )) address_name
	  FROM pos_address_requests par
	  WHERE par.address_request_id = p_address_request_id;

     l_rec l_cur%ROWTYPE;

BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;
   RETURN l_rec.address_name;

END get_address_name_in_req;

-- this is a private procedure. not intended to be public
PROCEDURE notify_addr_events
  (p_vendor_id           IN  NUMBER,
   p_address_request_id  IN  NUMBER,
   p_wf_process    	 IN  VARCHAR2,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2,
   x_receiver      	 OUT nocopy VARCHAR2
   )
  IS
     l_supplier_name   ap_suppliers.vendor_name%TYPE;
     l_address_name    hz_party_sites.party_site_name%TYPE;
     l_itemtype        wf_items.item_type%TYPE;
     l_itemkey         wf_items.item_key%TYPE;
     l_receiver        wf_roles.name%TYPE;
     l_cur             g_refcur;
     l_count           NUMBER;
     l_process         wf_process_activities.process_name%TYPE;
     l_step NUMBER;
BEGIN
   l_step := 0;
   get_supplier_name(p_vendor_id, l_supplier_name);

   l_step := 1;
   l_address_name := get_address_name_in_req(p_address_request_id);

   l_process := p_wf_process;

   -- setup receiver
   create_adhoc_role(l_process || '_' || p_address_request_id, l_receiver);

   l_step := 3;
   get_buyers('SUPP_ADDR_CHANGE_REQ',l_cur);

   l_step := 4;
   add_user_to_role_from_cur(l_cur, l_receiver, l_count);
   IF l_count < 1 THEN
      -- there is no one to notify, so we just return
      x_itemtype := NULL;
      x_itemkey := NULL;
      x_receiver := NULL;
      RETURN;
   END IF;

   l_step := 5;
   -- create workflow process
   get_wf_item_type (l_itemtype);
   get_wf_item_key (l_process,
                    To_char(p_vendor_id) || '_' || p_address_request_id,
                    l_itemkey);

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);
   l_step := 6;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPPLIER_NAME',
                              avalue     => l_supplier_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ADDRESS_NAME',
                              avalue     => l_address_name);
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'VENDOR_ID',
                              avalue     => p_vendor_id);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     => pos_url_pkg.get_dest_page_url('POS_HT_SP_B_ADDR_BK', 'BUYER'));
   l_step := 7;
   setup_actioner_private(l_itemtype, l_itemkey);

   l_step := 8;
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );
   l_step := 9;
   x_itemtype := l_itemtype;
   x_itemkey  := l_itemkey;
   x_receiver := l_receiver;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_ADDR_EVENTS',l_itemtype,l_itemkey);
      raise_application_error(-20041, 'Failure at step ' || l_step, true);
END notify_addr_events;

-- notify buyer admins that an address is created
-- in the supplier's address book
PROCEDURE notify_addr_created
  (p_vendor_id          IN  NUMBER,
   p_address_request_id IN NUMBER,
   x_itemtype      	OUT nocopy VARCHAR2,
   x_itemkey       	OUT nocopy VARCHAR2,
   x_receiver      	OUT nocopy VARCHAR2
   )
  IS
BEGIN
   notify_addr_events
     (p_vendor_id          => p_vendor_id,
      p_address_request_id => p_address_request_id,
      p_wf_process    	   => 'PADDR_CREATED',
      x_itemtype      	   => x_itemtype,
      x_itemkey       	   => x_itemkey,
      x_receiver      	   => x_receiver
      );
END notify_addr_created;

-- notify buyer admins that an address is removed
-- in the supplier's address book
PROCEDURE notify_addr_removed
(p_vendor_id          IN  NUMBER,
   p_address_request_id IN NUMBER,
   x_itemtype      	OUT nocopy VARCHAR2,
   x_itemkey       	OUT nocopy VARCHAR2,
   x_receiver      	OUT nocopy VARCHAR2
   )
  IS
BEGIN
   notify_addr_events
     (p_vendor_id          => p_vendor_id,
      p_address_request_id => p_address_request_id,
      p_wf_process    	   => 'PADDR_REMOVED',
      x_itemtype      	   => x_itemtype,
      x_itemkey       	   => x_itemkey,
      x_receiver      	   => x_receiver
      );
END notify_addr_removed;

-- notify buyer admins that an address is updated in
-- the supplier's address book
PROCEDURE notify_addr_updated
(p_vendor_id          IN  NUMBER,
   p_address_request_id IN NUMBER,
   x_itemtype      	OUT nocopy VARCHAR2,
   x_itemkey       	OUT nocopy VARCHAR2,
   x_receiver      	OUT nocopy VARCHAR2
   )
  IS
BEGIN
   notify_addr_events
     (p_vendor_id          => p_vendor_id,
      p_address_request_id => p_address_request_id,
      p_wf_process    	   => 'PADDR_UPDATED',
      x_itemtype      	   => x_itemtype,
      x_itemkey       	   => x_itemkey,
      x_receiver      	   => x_receiver
      );
END notify_addr_updated;

FUNCTION get_bus_class_name_in_req (p_bus_class_request_id IN NUMBER) RETURN VARCHAR2
  IS
     CURSOR l_cur IS
	SELECT flv.meaning
	  FROM fnd_lookup_values flv, pos_bus_class_reqs pbcr
         WHERE flv.lookup_type = pbcr.lookup_type
	   AND flv.lookup_code = pbcr.lookup_code
	   AND flv.language = userenv('LANG')
	   AND flv.lookup_type = 'POS_BUSINESS_CLASSIFICATIONS'
	   AND pbcr.bus_class_request_id = p_bus_class_request_id;

     l_rec l_cur%ROWTYPE;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;
   RETURN l_rec.meaning;

END get_bus_class_name_in_req;

-- this is a utility private procedure that deals with
-- supplier business classification related change notifications
PROCEDURE notify_bus_class_changed
  (p_process              IN  VARCHAR2,
   p_vendor_id            IN  NUMBER,
   p_bus_class_request_id IN  NUMBER,
   x_itemtype       	  OUT nocopy VARCHAR2,
   x_itemkey        	  OUT nocopy VARCHAR2,
   x_receiver       	  OUT nocopy VARCHAR2
   )
  IS
     l_supplier_name   ap_suppliers.vendor_name%TYPE;
     l_itemtype        wf_items.item_type%TYPE;
     l_itemkey         wf_items.item_key%TYPE;
     l_receiver        wf_roles.name%TYPE;
     l_cur             g_refcur;
     l_count           NUMBER;
     l_step            NUMBER;
     l_bus_class_name  fnd_lookup_values.meaning%TYPE;
BEGIN
   l_step := 0;
   get_supplier_name(p_vendor_id, l_supplier_name);

   l_step := 1;
   -- setup receiver
   create_adhoc_role(p_process||'_'||p_bus_class_request_id, l_receiver);

   l_step := 2;
   get_buyers('SUPP_BUS_CLASS_CHANGE_REQ',l_cur);

   l_step := 3;
   add_user_to_role_from_cur(l_cur, l_receiver, l_count);
   IF l_count < 1 THEN
      -- there is no one to notify, so we just return
      x_itemtype := NULL;
      x_itemkey := NULL;
      x_receiver := NULL;
      RETURN;
   END IF;

   l_step := 4;
   l_bus_class_name := get_bus_class_name_in_req(p_bus_class_request_id);

   l_step := 5;
   -- create workflow process
   get_wf_item_type (l_itemtype);

   l_step := 6;
   get_wf_item_key (p_process,
                    To_char(p_vendor_id) || '_' || p_bus_class_request_id,
                    l_itemkey);

   l_step := 7;
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => p_process);
   l_step := 8;

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPPLIER_NAME',
                              avalue     => l_supplier_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BUS_CLASS_NAME',
                              avalue     => l_bus_class_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'VENDOR_ID',
                              avalue     => p_vendor_id);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     => pos_url_pkg.get_dest_page_url ('POS_HT_SP_B_BUS_CLSS', 'BUYER'));
   l_step := 9;

   setup_actioner_private(l_itemtype, l_itemkey);

   l_step := 10;

   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   l_step := 11;
   x_itemtype := l_itemtype;
   x_itemkey  := l_itemkey;
   x_receiver := l_receiver;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_BUS_CLASS_CRT_REMOVED',l_itemtype,l_itemkey);
      raise_application_error(-20043,'Failure at step ' || l_step , true);
END notify_bus_class_changed;

-- notify buyer admins that a business classification is added to the
-- supplier's list
PROCEDURE notify_bus_class_created
  (p_vendor_id            IN  NUMBER,
   p_bus_class_request_id IN  NUMBER,
   x_itemtype       	  OUT nocopy VARCHAR2,
   x_itemkey        	  OUT nocopy VARCHAR2,
   x_receiver       	  OUT nocopy VARCHAR2
   )
  IS
  l_class_id number;
BEGIN
   select classification_id
   into l_class_id
   from pos_bus_class_reqs
   where bus_class_request_id = p_bus_class_request_id;

   -- The java API makes the call to this method even if the
   -- classification is changed. This is where we can catch
   -- this
   if ( l_class_id is not null and l_class_id > 0 ) then
    notify_bus_class_updated (p_vendor_id, p_bus_class_request_id,
        x_itemtype, x_itemkey, x_receiver);
    return;
   end if;

   notify_bus_class_changed
     ('PBUS_CLASS_CREATED', p_vendor_id, p_bus_class_request_id, x_itemtype, x_itemkey, x_receiver);
END notify_bus_class_created;

-- notify buyer admins that a business classification is removed from the
-- supplier's list
PROCEDURE notify_bus_class_removed
  (p_vendor_id            IN  NUMBER,
   p_bus_class_request_id IN  NUMBER,
   x_itemtype       	  OUT nocopy VARCHAR2,
   x_itemkey        	  OUT nocopy VARCHAR2,
   x_receiver       	  OUT nocopy VARCHAR2
  )
  IS
BEGIN

   notify_bus_class_changed
     ('PBUS_CLASS_REMOVED', p_vendor_id, p_bus_class_request_id, x_itemtype, x_itemkey, x_receiver);
END notify_bus_class_removed;

-- notify buyer admins that a business classification is removed from the
-- supplier's list
PROCEDURE notify_bus_class_updated
  (p_vendor_id            IN  NUMBER,
   p_bus_class_request_id IN  NUMBER,
   x_itemtype       	  OUT nocopy VARCHAR2,
   x_itemkey        	  OUT nocopy VARCHAR2,
   x_receiver       	  OUT nocopy VARCHAR2
  )
  IS
BEGIN
   notify_bus_class_changed
     ('PBUS_CLASS_UPDATED', p_vendor_id, p_bus_class_request_id, x_itemtype, x_itemkey, x_receiver);
END notify_bus_class_updated;

FUNCTION get_contact_name_in_req (p_contact_request_id IN NUMBER) RETURN VARCHAR2
  IS
     CURSOR l_cur IS
	SELECT Decode(pcr.contact_party_id, NULL, pcr.first_name || ' ' || pcr.last_name,
		      (SELECT hp.party_name
		       FROM hz_parties hp
		       WHERE hp.party_id = pcr.contact_party_id
		       )) contact_name
	  FROM pos_contact_requests pcr
	  WHERE pcr.contact_request_id = p_contact_request_id;

     l_rec l_cur%ROWTYPE;

BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;
   RETURN l_rec.contact_name;

END get_contact_name_in_req;


-- this is a private method used for sending notification for
-- contact creation, update, removal events
PROCEDURE notify_contact_events
  (p_wf_process         IN  VARCHAR2,
   p_vendor_id          IN  NUMBER,
   p_contact_request_id IN  NUMBER,
   x_itemtype           OUT nocopy VARCHAR2,
   x_itemkey            OUT nocopy VARCHAR2,
   x_receiver           OUT nocopy VARCHAR2
   )
  IS
     l_supplier_name   ap_suppliers.vendor_name%TYPE;
     l_contact_name    hz_parties.party_name%TYPE;
     l_itemtype        wf_items.item_type%TYPE;
     l_itemkey         wf_items.item_key%TYPE;
     l_receiver        wf_roles.name%TYPE;
     l_cur             g_refcur;
     l_count           NUMBER;
     l_process         wf_process_activities.process_name%TYPE;
     l_step            NUMBER;
BEGIN
   l_step := 0;
   get_supplier_name(p_vendor_id, l_supplier_name);
   l_step := 1;

   l_contact_name := get_contact_name_in_req(p_contact_request_id);
   l_step := 2;

   -- setup receiver
   l_process := p_wf_process;
   create_adhoc_role(l_process||'_'||p_contact_request_id, l_receiver);

   l_step := 3;
   get_buyers('SUPP_CONT_CHANGE_REQ', l_cur);

   l_step := 4;
   add_user_to_role_from_cur(l_cur, l_receiver, l_count);
   IF l_count < 1 THEN
      -- there is no one to notify, so we just return
      x_itemtype := NULL;
      x_itemkey := NULL;
      x_receiver := NULL;
      RETURN;
   END IF;

   l_step := 5;
   -- create workflow process
   get_wf_item_type (l_itemtype);

   l_step := 6;
   get_wf_item_key (l_process,
                    To_char(p_vendor_id) || '_' || p_contact_request_id,
                    l_itemkey);

   l_step := 7;
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 8;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPPLIER_NAME',
                              avalue     => l_supplier_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'CONTACT_NAME',
                              avalue     => l_contact_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'VENDOR_ID',
                              avalue     => p_vendor_id);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     =>  pos_url_pkg.get_dest_page_url ('POS_HT_SP_B_CONT_DIR', 'BUYER'));

   l_step := 9;
   setup_actioner_private(l_itemtype, l_itemkey);

   l_step := 10;
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   l_step := 11;
   x_itemtype := l_itemtype;
   x_itemkey  := l_itemkey;
   x_receiver := l_receiver;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_CONTACT_CREATED',l_itemtype,l_itemkey);
      raise_application_error(-20044,'Failure at step ' || l_step , true);
END notify_contact_events;

-- notify buyer admins that an contact is removed
-- in the supplier's contact directory
PROCEDURE notify_contact_created
  (p_vendor_id          IN  NUMBER,
   p_contact_request_id IN  NUMBER,
   x_itemtype           OUT nocopy VARCHAR2,
   x_itemkey            OUT nocopy VARCHAR2,
   x_receiver           OUT nocopy VARCHAR2
   )
  IS
BEGIN
   notify_contact_events
     ('PCONTACT_CREATED', p_vendor_id, p_contact_request_id, x_itemtype, x_itemkey, x_receiver);
END notify_contact_created;

-- notify buyer admins that an contact is removed
-- in the supplier's contact directory
PROCEDURE notify_contact_removed
  (p_vendor_id          IN  NUMBER,
   p_contact_request_id IN  NUMBER,
   x_itemtype           OUT nocopy VARCHAR2,
   x_itemkey            OUT nocopy VARCHAR2,
   x_receiver           OUT nocopy VARCHAR2
   )
  IS
BEGIN
   notify_contact_events
     ('PCONTACT_REMOVED', p_vendor_id, p_contact_request_id, x_itemtype, x_itemkey, x_receiver);
END notify_contact_removed;

-- notify buyer admins that an contact is updated in
-- the supplier's contact directory
PROCEDURE notify_contact_updated
  (p_vendor_id          IN  NUMBER,
   p_contact_request_id IN  NUMBER,
   x_itemtype           OUT nocopy VARCHAR2,
   x_itemkey            OUT nocopy VARCHAR2,
   x_receiver           OUT nocopy VARCHAR2
   )
  IS
BEGIN
   notify_contact_events
     ('PCONTACT_UPDATED', p_vendor_id, p_contact_request_id, x_itemtype, x_itemkey, x_receiver);
END notify_contact_updated;

-- in r12, the contact change request approval ui and the contact address change request approval ui
-- is the same. So for link events, the notification should be also the same (which means using the contact request).

/*PROCEDURE notify_contact_link_events
  (p_vendor_id          IN  NUMBER,
   p_contact_request_id IN  NUMBER,
   p_wf_process         IN  VARCHAR2,
   x_itemtype           OUT nocopy VARCHAR2,
   x_itemkey            OUT nocopy VARCHAR2,
   x_receiver           OUT nocopy VARCHAR2
   )
  IS
     l_supplier_name   ap_suppliers.vendor_name%TYPE;
     l_contact_name    hz_parties.party_name%TYPE;
     l_itemtype        wf_items.item_type%TYPE;
     l_itemkey         wf_items.item_key%TYPE;
     l_receiver        wf_roles.name%TYPE;
     l_cur             g_refcur;
     l_count           NUMBER;
     l_process         wf_process_activities.process_name%TYPE;
     l_step            NUMBER;
BEGIN
   l_step := 0;
   get_supplier_name(p_vendor_id, l_supplier_name);

   l_step := 1;
   get_contact_name(p_contact_party_id, l_contact_name);

   l_step := 2;
   -- setup receiver
   l_process := p_wf_process;
   create_adhoc_role(l_process||'_'||p_party_site_id||'_'||p_contact_party_id, l_receiver);
   get_buyers('SUPP_CONT_CHANGE_REQ', l_cur);
   add_user_to_role_from_cur(l_cur, l_receiver, l_count);
   IF l_count < 1 THEN
      -- there is no one to notify, so we just return
      x_itemtype := NULL;
      x_itemkey := NULL;
      RETURN;
   END IF;

   l_step := 3;
   get_wf_item_type (l_itemtype);

   l_step := 4;
   get_wf_item_key (l_process,
                    To_char(p_vendor_id) || '_' || p_contact_party_id,
                    l_itemkey);

   l_step := 5;
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 6;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPPLIER_NAME',
                              avalue     => l_supplier_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'CONTACT_NAME',
                              avalue     => l_contact_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'VENDOR_ID',
                              avalue     => p_vendor_id);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     =>  pos_url_pkg.get_dest_page_url ('POS_HT_SP_B_CONT_DIR', 'BUYER'));
   l_step := 7;
   setup_actioner_private(l_itemtype, l_itemkey);
   l_step := 8;

   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   l_step := 9;
   x_itemtype := l_itemtype;
   x_itemkey  := l_itemkey;
   x_receiver := l_receiver;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_CONTACT_LINK_CREATED',l_itemtype,l_itemkey);
      raise_application_error(-20046, 'Failure at step ' || l_step , true);
END notify_contact_link_events;

PROCEDURE notify_contact_link_created
  (p_vendor_id        IN  NUMBER,
   p_party_site_id    IN  NUMBER,
   p_contact_party_id IN  NUMBER,
   x_itemtype         OUT nocopy VARCHAR2,
   x_itemkey          OUT nocopy VARCHAR2,
   x_receiver         OUT nocopy VARCHAR2
   )
  IS
BEGIN
   notify_contact_link_events
     (p_vendor_id        => p_vendor_id,
      p_party_site_id    => p_party_site_id,
      p_contact_party_id => p_contact_party_id,
      p_wf_process       => 'PCONTACT_LINK_CREATED',
      x_itemtype         => x_itemtype,
      x_itemkey          => x_itemkey,
      x_receiver         => x_receiver
      );
END notify_contact_link_created;

PROCEDURE notify_contact_link_removed
  (p_vendor_id        IN  NUMBER,
   p_party_site_id    IN  NUMBER,
   p_contact_party_id IN  NUMBER,
   x_itemtype         OUT nocopy VARCHAR2,
   x_itemkey          OUT nocopy VARCHAR2,
   x_receiver         OUT nocopy VARCHAR2
   )
  IS
BEGIN
   notify_contact_link_events
     (p_vendor_id        => p_vendor_id,
      p_party_site_id    => p_party_site_id,
      p_contact_party_id => p_contact_party_id,
      p_wf_process       => 'PCONTACT_LINK_REMOVED',
      x_itemtype         => x_itemtype,
      x_itemkey          => x_itemkey,
      x_receiver         => x_receiver
      );
END notify_contact_link_removed;
    */

-- this is a utility private procedure that deals with
-- supplier product and service related change notifications
PROCEDURE notify_product_crt_removed
  (p_process        IN  VARCHAR2,
   p_vendor_id      IN  NUMBER,
   x_itemtype       OUT nocopy VARCHAR2,
   x_itemkey        OUT nocopy VARCHAR2,
   x_receiver       OUT nocopy VARCHAR2
   )
  IS
     l_supplier_name   ap_suppliers.vendor_name%TYPE;
     l_itemtype        wf_items.item_type%TYPE;
     l_itemkey         wf_items.item_key%TYPE;
     l_receiver        wf_roles.name%TYPE;
     l_cur             g_refcur;
     l_count           NUMBER;
     l_step            NUMBER;
BEGIN
   l_step := 0;
   get_supplier_name(p_vendor_id, l_supplier_name);

   l_step := 1;
   -- setup receiver
   create_adhoc_role(p_process||'_'||p_vendor_id, l_receiver);

   l_step := 2;
   get_buyers('SUPP_PS_CHANGE_REQ',l_cur);

   l_step := 3;
   add_user_to_role_from_cur(l_cur, l_receiver, l_count);

   l_step := 4;
   IF l_count < 1 THEN
      -- there is no one to notify, so we just return
      x_itemtype := NULL;
      x_itemkey := NULL;
      x_receiver := NULL;
      RETURN;
   END IF;

   l_step := 5;
   get_wf_item_type (l_itemtype);

   l_step := 6;
   get_wf_item_key (p_process,
                    To_char(p_vendor_id),
                    l_itemkey);

   l_step := 7;
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => p_process);

   l_step := 8;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPPLIER_NAME',
                              avalue     => l_supplier_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'VENDOR_ID',
                              avalue     => p_vendor_id);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     =>  pos_url_pkg.get_dest_page_url ('POS_HT_SP_B_PS', 'BUYER'));

   l_step := 9;
   setup_actioner_private(l_itemtype, l_itemkey);

   l_step := 10;
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   l_step := 11;
   x_itemtype := l_itemtype;
   x_itemkey  := l_itemkey;
   x_receiver := l_receiver;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_PRODUCT_CRT_REMOVED',l_itemtype,l_itemkey);
      raise_application_error(-20048, 'Failure at step ' || l_step, true);
END notify_product_crt_removed;

-- notify buyer admins that a business classification is added to the
-- supplier's list
PROCEDURE notify_product_created
  (p_vendor_id      IN  NUMBER,
   x_itemtype       OUT nocopy VARCHAR2,
   x_itemkey        OUT nocopy VARCHAR2,
   x_receiver       OUT nocopy VARCHAR2
   )
  IS
BEGIN
   notify_product_crt_removed
     ('PPRODUCT_CREATED', p_vendor_id, x_itemtype, x_itemkey, x_receiver);
END notify_product_created;

-- notify buyer admins that a product and service is removed from the
-- supplier's list
PROCEDURE notify_product_removed
  (p_vendor_id      IN  NUMBER,
   x_itemtype       OUT nocopy VARCHAR2,
   x_itemkey        OUT nocopy VARCHAR2,
   x_receiver       OUT nocopy VARCHAR2
   )
  IS
BEGIN
   notify_product_crt_removed
     ('PPRODUCT_REMOVED', p_vendor_id, x_itemtype, x_itemkey, x_receiver);
END notify_product_removed;

FUNCTION get_1st_supplier_user(p_vendor_id IN NUMBER) RETURN VARCHAR2
  IS
     l_supplier_party_id NUMBER;
     CURSOR l_user_name_cur (p_supplier_party_id IN NUMBER) IS
        SELECT fu.user_name
          FROM hz_relationships hzr, hz_parties hp, fnd_user fu
          WHERE
          fu.person_party_id = hp.party_id
          AND fu.email_address IS NOT NULL
          AND fu.end_date IS NULL
          AND hzr.object_id  = p_supplier_party_id
          AND hzr.subject_type = 'PERSON'
          AND hzr.object_type = 'ORGANIZATION'
          AND hzr.relationship_type = 'POS_EMPLOYMENT'
          AND hzr.relationship_code = 'EMPLOYEE_OF'
          AND hzr.status  = 'A'
          AND (hzr.start_date IS NULL OR
               hzr.start_date <= Sysdate)
          AND (hzr.end_date IS NULL OR
                 hzr.end_date >= Sysdate)
          AND hzr.subject_id = hp.party_id
          ORDER BY hp.creation_date asc;

BEGIN
   l_supplier_party_id := pos_vendor_util_pkg.get_party_id_for_vendor(p_vendor_id);
   IF l_supplier_party_id IS NULL THEN
      RETURN NULL;
   END IF;

   FOR l_rec IN l_user_name_cur(l_supplier_party_id) LOOP
      RETURN l_rec.user_name; -- only need the first one
   END LOOP;

   RETURN NULL;
END get_1st_supplier_user;

PROCEDURE setup_dup_reg_receiver
  (p_process   IN  VARCHAR2,
   p_vendor_id IN  NUMBER,
   x_receiver  OUT nocopy VARCHAR2
   )
  IS
     l_receiver   wf_roles.name%TYPE;
     l_adhoc_user wf_roles.name%TYPE;

     CURSOR l_user_name_cur IS
        SELECT fu.user_name
          FROM hz_relationships hzr, hz_parties hp, fnd_user fu, ap_suppliers ap, hz_party_usg_assignments hpua
          WHERE fu.person_party_id = hp.party_id
          AND fu.email_address IS NOT NULL
          AND fu.end_date IS NULL
          AND ap.vendor_id = p_vendor_id
          AND hzr.object_id  = ap.party_id
          AND hzr.subject_type = 'PERSON'
          AND hzr.object_type = 'ORGANIZATION'
          AND hzr.relationship_type = 'CONTACT'
          AND hzr.relationship_code = 'CONTACT_OF'
          AND hzr.status  = 'A'
          AND (hzr.start_date IS NULL OR
               hzr.start_date <= Sysdate)
          AND (hzr.end_date IS NULL OR
                 hzr.end_date >= Sysdate)
          AND hzr.subject_id = hp.party_id
          and hpua.party_id = hp.party_id
          and hpua.status_flag = 'A'
          and hpua.party_usage_code = 'SUPPLIER_CONTACT'
          and (hpua.effective_end_date is null OR hpua.effective_end_date > sysdate);

     l_user_name_rec l_user_name_cur%ROWTYPE;

     CURSOR l_cur IS
        SELECT pvsa.email_address, ft.nls_territory, pvsa.language
        FROM ap_supplier_sites_all pvsa, fnd_territories ft
        WHERE pvsa.email_address IS NOT NULL
        AND pvsa.vendor_id = p_vendor_id
        AND (pvsa.inactive_date IS NULL OR pvsa.inactive_date IS NOT NULL AND pvsa.inactive_date > Sysdate)
        AND pvsa.country = ft.territory_code (+);

     l_rec l_cur%ROWTYPE;
     l_count NUMBER;
     l_user_name fnd_user.user_name%TYPE;

     CURSOR l_contact_cur IS
        select hp.person_first_name, hp.person_last_name, hzr_hp.email_address
        from hz_parties hp, hz_relationships hzr, hz_parties hzr_hp, hz_party_usg_assignments hpua, ap_suppliers apsupp
        where hp.party_id = hzr.subject_id
        and hzr.object_id = apsupp.party_id
        and apsupp.vendor_id = p_vendor_id
        and hzr.relationship_type = 'CONTACT'
        and hzr.relationship_code = 'CONTACT_OF'
        and hzr.subject_type ='PERSON'
        and hzr.object_type = 'ORGANIZATION'
        and (hzr.end_date is null or hzr.end_date > sysdate)
        and hzr.status = 'A'
        and hzr_hp.party_id = hzr.party_id
        and hpua.party_id = hp.party_id
        and hpua.status_flag = 'A'
        and hpua.party_usage_code = 'SUPPLIER_CONTACT'
        and (hpua.effective_end_date is null OR hpua.effective_end_date > sysdate)
        and hp.party_id not in ( select pcr.contact_party_id
          from pos_contact_requests pcr, pos_supplier_mappings psm
          where pcr.request_status='PENDING'
          and psm.mapping_id = pcr.mapping_id
          and psm.PARTY_ID = apsupp.party_id
          and pcr.contact_party_id is not null )
        and hzr_hp.email_address is not null;

BEGIN
   create_adhoc_role(p_process||'_'||p_vendor_id, l_receiver);
   l_count := 0;

   FOR l_user_name_rec in l_user_name_cur loop
         l_count := l_count + 1;
         AddUserToAdHocRole
           (l_receiver, l_user_name_rec.user_name);
   END LOOP;

   IF l_count = 0 then
      FOR l_rec IN l_cur LOOP
      l_count := l_count + 1;
      l_adhoc_user := l_receiver || '_' || l_count;
      wf_directory.CreateAdHocUser
        (name            => l_adhoc_user,
         display_name    => l_rec.email_address,
         language        => l_rec.language,
         territory       => l_rec.nls_territory ,
         email_address   => l_rec.email_address
         );
      AddUserToAdHocRole
        (l_receiver, l_adhoc_user);
      END LOOP;
   END IF;

   IF l_count = 0 THEN
      FOR l_contact_rec IN l_contact_cur LOOP
         l_count := l_count + 1;
         l_adhoc_user := l_receiver || '_' || l_count;
         wf_directory.CreateAdHocUser
           (name            => l_adhoc_user,
            display_name    => l_contact_rec.email_address,
            email_address   => l_contact_rec.email_address
            );
         AddUserToAdHocRole
           (l_receiver, l_adhoc_user);
      END LOOP;
   END IF;
   x_receiver := l_receiver;
END setup_dup_reg_receiver;

-- return Y if the role has at least one active user; otherwise N
FUNCTION wfrole_has_active_user
  (p_role IN VARCHAR2) RETURN VARCHAR2 IS
     l_users wf_directory.usertable;
     l_username wf_users.name%TYPE;
BEGIN
   wf_directory.GetRoleUsers(p_role, l_users);
   FOR l_index IN 1..l_users.COUNT LOOP
      IF l_users(l_index) IS NOT NULL
        AND wf_directory.UserActive(l_users(l_index)) THEN
         RETURN 'Y';
      END IF;
   END LOOP;
   RETURN 'N';
END wfrole_has_active_user;

PROCEDURE notify_dup_supplier_reg
   (p_vendor_id     IN  NUMBER,
    p_first_name    IN  VARCHAR2,
    p_last_name     IN  VARCHAR2,
    p_sup_reg_email IN  VARCHAR2,
    x_itemtype      OUT nocopy VARCHAR2,
    x_itemkey       OUT nocopy VARCHAR2,
    x_receiver      OUT nocopy VARCHAR2
    )
  IS
     PRAGMA autonomous_transaction;
     l_supplier_name   ap_suppliers.vendor_name%TYPE;
     l_enterprise_name hz_parties.party_name%TYPE;
     l_itemtype        wf_items.item_type%TYPE;
     l_itemkey         wf_items.item_key%TYPE;
     l_receiver        wf_roles.name%TYPE;
     l_cur             g_refcur;
     l_count           NUMBER;
     l_process         wf_process_activities.process_name%TYPE;
     l_step            NUMBER;
BEGIN
   l_step := 0;
   get_supplier_name(p_vendor_id, l_supplier_name);

   l_step := 1;
   get_enterprise_name(l_enterprise_name);

   l_step := 2;
   -- setup receiver
   l_process := 'PDUP_SUPPLIER_REG';
   setup_dup_reg_receiver(l_process, p_vendor_id, l_receiver);

   IF wfrole_has_active_user(l_receiver) = 'N' THEN
      -- there is no one to notify, so we just return
      x_itemtype := NULL;
      x_itemkey := NULL;
      x_receiver := NULL;
      -- bug 2809368, need to rollback before return as this procedure uses
      -- autonomous_transaction
      ROLLBACK;
      RETURN;
   END IF;

   l_step := 3;
   get_wf_item_type (l_itemtype);

   l_step := 4;
   get_wf_item_key (l_process,
                    To_char(p_vendor_id) || '_' || p_sup_reg_email,
                    l_itemkey);

   l_step := 5;
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 6;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPPLIER_NAME',
                              avalue     => l_supplier_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => l_enterprise_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'FIRST_NAME',
                              avalue     => p_first_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'LAST_NAME',
                              avalue     => p_last_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUP_REG_EMAIL',
                              avalue     => p_sup_reg_email);

   l_step := 7;
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   l_step := 8;
   x_itemtype := l_itemtype;
   x_itemkey  := l_itemkey;
   x_receiver := l_receiver;

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      -- bug 2809368, need to rollback before return as this procedure uses
      -- autonomous_transaction
      ROLLBACK;
      wf_core.context(g_package_name,'NOTIFY_DUP_SUPPLIER_REG',l_itemtype,l_itemkey);
      raise_application_error(-20049, 'Failure at step ' || l_step, true);
END notify_dup_supplier_reg;

PROCEDURE get_reg_ou_id
  (p_supplier_reg_id IN NUMBER,
   x_ou_id           OUT nocopy NUMBER)
  IS
     CURSOR l_cur IS
        SELECT ou_id
          FROM pos_supplier_registrations
          WHERE supplier_reg_id = p_supplier_reg_id;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO x_ou_id;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;
END get_reg_ou_id;

PROCEDURE get_reg_supplier_name
  (p_supplier_reg_id IN NUMBER,
   x_name            OUT nocopy VARCHAR2)
  IS
     CURSOR l_cur IS
        SELECT supplier_name
          FROM pos_supplier_registrations
          WHERE supplier_reg_id = p_supplier_reg_id;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO x_name;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;
END get_reg_supplier_name;

-- notify buyer admins that a supplier has registered
PROCEDURE notify_supplier_registered
  (p_supplier_reg_id IN  NUMBER,
   x_itemtype        OUT nocopy VARCHAR2,
   x_itemkey         OUT nocopy VARCHAR2,
   x_receiver        OUT nocopy VARCHAR2
   )
  IS
     l_supplier_name   ap_suppliers.vendor_name%TYPE;
     l_itemtype        wf_items.item_type%TYPE;
     l_itemkey         wf_items.item_key%TYPE;
     l_receiver        wf_roles.name%TYPE;
     l_cur             g_refcur;
     l_count           NUMBER;
     l_process         wf_process_activities.process_name%TYPE;
     l_ou_id           NUMBER;
     l_step            NUMBER;
BEGIN

   l_step := 0;
   get_reg_supplier_name(p_supplier_reg_id, l_supplier_name);

   l_step := 1;
   get_reg_ou_id(p_supplier_reg_id, l_ou_id);

   l_step := 2;
   l_process := 'PSUPPLIER_REGISTERED';
   create_adhoc_role(l_process||'_'||p_supplier_reg_id, l_receiver);

   l_step := 3;
   get_buyers('SUPPLIER_REGISTERED',l_cur);

   l_step := 4;
   add_user_to_role_from_cur(l_cur, l_receiver, l_count);

   l_step := 5;
   IF l_count < 1 THEN
      -- there is no one to notify, so we just return
      x_itemtype := NULL;
      x_itemkey := NULL;
      x_receiver := NULL;
      RETURN;
   END IF;

   l_step := 6;
   get_wf_item_type (l_itemtype);

   l_step := 7;
   get_wf_item_key (l_process,
                    To_char(p_supplier_reg_id),
                    l_itemkey);

   l_step := 8;
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 9;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPPLIER_NAME',
                              avalue     => l_supplier_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     => pos_url_pkg.get_buyer_login_url);

   l_step := 10;
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   l_step := 11;
   x_itemtype := l_itemtype;
   x_itemkey  := l_itemkey;
   x_receiver := l_receiver;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_SUPPLIER_REGISTERED',l_itemtype,l_itemkey);
      raise_application_error(-20052, 'Failure at step ' || l_step, true);
END notify_supplier_registered;

FUNCTION get_admin_email RETURN VARCHAR2
  IS
     l_user_id NUMBER;

     CURSOR l_email_cur IS
        SELECT fu.email_address
          FROM fnd_user fu
          WHERE fu.user_id = l_user_id;

     CURSOR l_name_cur IS
        SELECT ppf.first_name, ppf.last_name
          FROM fnd_user fu, per_people_f ppf
          WHERE fu.user_id = l_user_id AND
          ppf.person_id = fu.employee_id;

     l_email_rec   l_email_cur%ROWTYPE;
     l_name_rec    l_name_cur%ROWTYPE;
     l_found_email BOOLEAN;
     l_found_name  BOOLEAN;
BEGIN
   l_user_id := fnd_global.user_id;
   l_found_email := FALSE;
   l_found_name  := FALSE;
   OPEN l_email_cur;
   FETCH l_email_cur INTO l_email_rec;
   IF l_email_cur%found THEN
      l_found_email := TRUE;
   END IF;
   CLOSE l_email_cur;
   OPEN l_name_cur;
   FETCH l_name_cur INTO l_name_rec;
   IF l_name_cur%found THEN
      l_found_name := TRUE;
   END IF;
   CLOSE l_name_cur;

   IF l_found_name AND l_found_email THEN
      RETURN l_name_rec.first_name || ' ' || l_name_rec.last_name || '(' ||
        l_email_rec.email_address || ')';
    ELSIF l_found_name THEN
      RETURN l_name_rec.first_name || ' ' || l_name_rec.last_name;
    ELSE
      RETURN l_email_rec.email_address;
   END IF;
END get_admin_email;

-- notify the supplier that his/her supplier registration is
-- approved
PROCEDURE notify_supplier_approved
  (p_supplier_reg_id IN  NUMBER,
   p_username        IN  VARCHAR2,
   p_password        IN  VARCHAR2,
   x_itemtype        OUT nocopy VARCHAR2,
   x_itemkey         OUT nocopy VARCHAR2
   )
  IS
     l_itemtype wf_items.item_type%TYPE;
     l_itemkey  wf_items.item_key%TYPE;
     l_process  wf_process_activities.process_name%TYPE;
     l_enterprise_name hz_parties.party_name%TYPE;
     l_step    NUMBER;
BEGIN
   l_step := 0;
   get_enterprise_name(l_enterprise_name);

   l_step := 1;
   l_process := 'PSUPPLIER_APPROVED';
   get_wf_item_type (l_itemtype);

   l_step := 2;
   get_wf_item_key (l_process,
                    To_char(p_supplier_reg_id),
                    l_itemkey);

   l_step := 3;
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 4;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => p_username);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => l_enterprise_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'USERNAME',
                              avalue     => p_username);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'PASSWORD',
                              avalue     => p_password);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     => pos_url_pkg.get_external_login_url);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ADMIN_EMAIL',
                              avalue     => get_admin_email);

   /*
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BUYER_NOTE',
                              avalue     => 'PLSQL:POS_SPM_WF_PKG1.BUYER_NOTE/'||To_char(p_supplier_reg_id));
   */

   -- Bug 8325979 - Following attributes have been replaced with FND Messages

   wf_engine.SetItemAttrText  (itemtype   => l_itemtype,
                             itemkey    => l_itemkey,
                             aname      => 'POS_APPROVE_SUPPLIER_SUBJECT',
                             avalue     => GET_APPRV_SUPPLIER_SUBJECT(l_enterprise_name));


   wf_engine.SetItemAttrText  (itemtype   => l_itemtype, itemkey    => l_itemkey,
                              aname      => 'POS_APPROVE_SUPPLIER_BODY',
                              avalue     => 'PLSQLCLOB:pos_spm_wf_pkg1.GET_APPRV_SUPPLIER_BODY/'||l_itemtype ||':' ||l_itemkey ||'#'||p_supplier_reg_id
                             );

   l_step := 5;
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );
   l_step := 6;
   x_itemtype := l_itemtype;
   x_itemkey  := l_itemkey;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_SUPPLIER_APPROVED',l_itemtype,l_itemkey);
      raise_application_error(-20053, 'Failure at step ' || l_step, true);
END notify_supplier_approved;

-- Notify supplie user of login info.
-- The supplier user here is not the primary contact who submitted the
-- registration. The notification for the primary contact should be
-- sent using notify_supplier_approved method above.
PROCEDURE notify_supplier_user_approved
  (p_supplier_reg_id IN  NUMBER,
   p_username        IN  VARCHAR2,
   p_password        IN  VARCHAR2,
   x_itemtype        OUT nocopy VARCHAR2,
   x_itemkey         OUT nocopy VARCHAR2
   )
  IS
     l_itemtype        wf_items.item_type%TYPE;
     l_itemkey         wf_items.item_key%TYPE;
     l_process         wf_process_activities.process_name%TYPE;
     l_enterprise_name hz_parties.party_name%TYPE;
     l_step            VARCHAR2(100);
BEGIN
   l_step := 1;

   get_enterprise_name(l_enterprise_name);

   l_process := 'SUPPLIER_REG_USER_CREATED';

   l_step := 2;
   get_wf_item_type (l_itemtype);

   l_step := 3;
   get_wf_item_key (l_process,
                    To_char(p_supplier_reg_id) || '_' || p_username,
                    l_itemkey);

   l_step := 4;
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 5;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => p_username);

   l_step := 6;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => l_enterprise_name);

   l_step := 7;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'USERNAME',
                              avalue     => p_username);

   l_step := 8;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'PASSWORD',
                              avalue     => p_password);

   l_step := 9;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     => pos_url_pkg.get_external_login_url);

   l_step := 10;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ADMIN_EMAIL',
                              avalue     => get_admin_email);

   l_step := 11;

   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );
   x_itemtype := l_itemtype;
   x_itemkey  := l_itemkey;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_SUPPLIER_USER_APPROVED',l_itemtype,l_itemkey);
      raise_application_error(-20053, 'Failure at step ' || l_step, true);
END notify_supplier_user_approved;

-- notify the supplier that his/her supplier registration is
-- rejected
PROCEDURE notify_supplier_rejected
  (p_supplier_reg_id IN  NUMBER,
   x_itemtype        OUT nocopy VARCHAR2,
   x_itemkey         OUT nocopy VARCHAR2,
   x_receiver        OUT nocopy VARCHAR2
   )
  IS
     l_itemtype wf_items.item_type%TYPE;
     l_itemkey  wf_items.item_key%TYPE;
     l_process  wf_process_activities.process_name%TYPE;

     CURSOR l_cur IS
	SELECT email_address, first_name, last_name
	  FROM pos_contact_requests
	 WHERE mapping_id IN (SELECT mapping_id FROM pos_supplier_mappings WHERE supplier_reg_id = p_supplier_reg_id)
           AND do_not_delete = 'Y';

     l_rec l_cur%ROWTYPE;
     l_receiver wf_roles.name%TYPE;
     l_enterprise_name hz_parties.party_name%TYPE;
     l_display_name wf_roles.display_name%TYPE;
     l_step  NUMBER;
BEGIN
   l_step := 0;
   get_enterprise_name(l_enterprise_name);

   l_step := 1;
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;

   l_step := 2;
   l_display_name := l_rec.first_name || ' ' || l_rec.last_name;
   l_process := 'PSUPPLIER_REJECTED';
   get_adhoc_role_name(l_process, l_receiver);

   l_step := 3;
   wf_directory.CreateAdHocUser
     (name            => l_receiver,
      display_name    => l_display_name,
      email_address   => l_rec.email_address
      );

   l_step := 4;
   get_wf_item_type (l_itemtype);

   l_step := 7;
   get_wf_item_key (l_process,
                    To_char(p_supplier_reg_id),
                    l_itemkey);

   l_step := 8;
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 9;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => l_enterprise_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BUYER_NOTE',
                              avalue     => 'PLSQL:POS_SPM_WF_PKG1.BUYER_NOTE/'||To_char(p_supplier_reg_id));

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'MESSAGE_SUBJECT',
                              avalue     => GET_SUPP_REJECT_NOTIF_SUBJECT(l_enterprise_name)
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'MESSAGE_BODY',
                              avalue     => 'PLSQLCLOB:POS_SPM_WF_PKG1.GET_SUPP_REJECT_NOTIF_BODY/'||l_itemtype ||':' ||l_itemkey ||'#'||p_supplier_reg_id
                              );

   l_step := 10;
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   l_step := 11;
   x_itemtype := l_itemtype;
   x_itemkey  := l_itemkey;
   x_receiver := l_receiver;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_SUPPLIER_REJECTED',l_itemtype,l_itemkey);
      raise_application_error(-20050, 'Failure at step ' || l_step, true);
END notify_supplier_rejected;

-- This procedure is used by workflow to generate the buyer note with proper heading
-- in the notification to supplier when the supplier registration is approved or rejected.
-- It should not be used for other purpose.
--
-- Logic of the procedure: if sm_notes_to_supplier is not null, returns a fnd message
-- POS_SUPPREG_BUYER_NOTE_HEADING for heading and the note; otherwise, null.
-- (bug 2725468).
--
PROCEDURE buyer_note
  (document_id   IN VARCHAR2,
   display_type  IN VARCHAR2,
   document      IN OUT nocopy VARCHAR2,
   document_type IN OUT nocopy VARCHAR2)
  IS
     l_supplier_reg_id NUMBER;

     CURSOR l_cur IS
        SELECT SM_NOTE_TO_SUPPLIER, NOTE_TO_SUPPLIER
          FROM pos_supplier_registrations
          WHERE supplier_reg_id = l_supplier_reg_id;

     l_rec l_cur%ROWTYPE;
     l_enterprise_name hz_parties.party_name%TYPE;
     l_step NUMBER;
     l_note_to_supplier pos_supplier_registrations.note_to_supplier%TYPE;
BEGIN
   l_step := 0;
   -- the document id should be the supplier_reg_id for the registration in pos_supplier_registrations
   l_supplier_reg_id := To_number(document_id);

   l_step := 1;
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   CLOSE l_cur;
   IF (FND_PROFILE.VALUE('POS_SM_ENABLE_SPM_EXTENSION') = 'Y') THEN
      l_note_to_supplier := l_rec.SM_NOTE_TO_SUPPLIER;
   ELSE
      l_note_to_supplier := l_rec.NOTE_TO_SUPPLIER;
   END IF;
   IF l_note_to_supplier IS NULL THEN
      document := NULL;
    ELSE
      get_enterprise_name(l_enterprise_name);
      fnd_message.set_name('POS','POS_SUPPREG_BUYER_NOTE_HEADING');
      fnd_message.set_token('ENTERPRISE_NAME', l_enterprise_name);
      IF display_type = 'text/html' THEN
         document_type := 'text/html';
         document := '<b>' || fnd_message.get || '</b>' || '<br>' || l_note_to_supplier || '<p>';
       ELSE
         document := g_new_line || fnd_message.get || g_new_line || l_note_to_supplier || g_new_line;
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'BUYER_NOTE',Sqlerrm);
      raise_application_error(-20051, 'Failure at step ' || l_step, true);
END buyer_note;

-- generates the buyer's note document for notifications to suppliers on
-- bank account approvals
PROCEDURE bank_acct_buyer_note
  (document_id   IN VARCHAR2,
   display_type  IN VARCHAR2,
   document      IN OUT nocopy VARCHAR2,
   document_type IN OUT nocopy VARCHAR2)
  IS
     l_step NUMBER;
BEGIN
   l_step := 0;

   IF document_id IS NULL THEN
      document := NULL;
    ELSE
      fnd_message.set_name('POS','POS_SBD_BUYER_NOTE_HEADER');
      IF display_type = 'text/html' THEN
         document_type := 'text/html';
         document := fnd_message.get || '<br>' || document_id;
       ELSE
         document := fnd_message.get || g_new_line || document_id || g_new_line;
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'BANK_ACCT_BUYER_NOTE',Sqlerrm);
      raise_application_error(-20051, 'Failure at step ' || l_step, true);
END bank_acct_buyer_note;

--
--
--
-- The following section are related to supplier bank account project
--
--
-- wf function activity to setup receiver (suppliers) for account actions
PROCEDURE setup_acct_action_receiver
  (itemtype  IN VARCHAR2,
   itemkey   IN VARCHAR2,
   actid     IN NUMBER,
   funcmode  IN VARCHAR2,
   resultout OUT nocopy VARCHAR2)
IS
	l_receiver  wf_roles.name%TYPE;
     	l_vendor_id NUMBER;
     	l_function_id NUMBER;

    	CURSOR l_receiver_cur IS
           select DISTINCT fu.user_name
           from fnd_user fu,
                fnd_responsibility fr,
                fnd_user_resp_groups_direct furg,
                hz_relationships hr1, ap_suppliers ap_sup, hz_party_usg_assignments hpua
           where fr.menu_id IN
                 (SELECT fme.menu_id
                  FROM fnd_menu_entries fme
                  START WITH fme.function_id = l_function_id
                  CONNECT BY PRIOR menu_id = sub_menu_id
                 )
           AND   ( furg.end_date is null or furg.end_date > sysdate )
           AND   furg.security_group_id = 0
           AND   fr.responsibility_id = furg.responsibility_id
           AND   fr.application_id = furg.responsibility_application_id
           AND   fu.user_id = furg.user_id
           and   fu.person_party_id = hr1.subject_id
           and   hr1.subject_type = 'PERSON'
           and   hr1.relationship_type = 'CONTACT'
           and   hr1.relationship_code = 'CONTACT_OF'
           and   hr1.object_type = 'ORGANIZATION'
           and   hr1.status = 'A'
           and   hr1.start_date <= sysdate
           and   ( hr1.end_date IS NULL OR hr1.end_date > sysdate)
           and   hr1.object_id = ap_sup.party_id
           and   ap_sup.vendor_id = l_vendor_id
           and   hpua.party_id = hr1.subject_id
           and   hpua.status_flag = 'A'
           and   hpua.party_usage_code = 'SUPPLIER_CONTACT'
           and   (hpua.effective_end_date is null OR hpua.effective_end_date > sysdate);

BEGIN

   IF ( funcmode = 'RUN' ) THEN
      l_vendor_id :=
        wf_engine.GetItemAttrNumber(itemtype, itemkey, 'VENDOR_ID');
      create_adhoc_role('PACCOUNT_ACTION_' || l_vendor_id, l_receiver);

      wf_engine.SetItemAttrText (itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      => 'RECEIVER',
                                 avalue     => l_receiver);

      l_function_id := get_function_id(g_supplier_function_name);

      FOR l_user_rec IN l_receiver_cur LOOP
        AddUserToAdHocRole(l_receiver, l_user_rec.user_name);

      END LOOP;
   END IF;
   resultout := 'COMPLETE';

EXCEPTION
   WHEN OTHERS THEN
     WF_CORE.CONTEXT ('POS_SPM_WF_PKG1', 'setup_acct_action_receiver', itemtype, itemkey, to_char(actid), funcmode);
END setup_acct_action_receiver;

-- wf function activity to setup buyer receivers for supplier account update
PROCEDURE setup_acct_upd_buyer_rcvr
  (itemtype  IN VARCHAR2,
   itemkey   IN VARCHAR2,
   actid     IN NUMBER,
   funcmode  IN VARCHAR2,
   resultout OUT nocopy VARCHAR2)
  IS
     l_receiver  wf_roles.name%TYPE;
     l_cur g_refcur;
     l_count NUMBER;
     l_vendor_id NUMBER;
     l_bank_account_name   iby_ext_bank_accounts_v.bank_account_name%TYPE;
     l_bank_account_number iby_ext_bank_accounts_v.bank_account_number%TYPE;
     l_currency_code       iby_ext_bank_accounts_v.currency_code%TYPE;
BEGIN
   IF ( funcmode = 'RUN' ) THEN

      l_vendor_id :=
	wf_engine.GetItemAttrNumber(itemtype, itemkey, 'VENDOR_ID');

      l_bank_account_number :=
	wf_engine.GetItemAttrText(itemtype, itemkey, 'BANK_ACCOUNT_NUMBER');

      l_currency_code :=
	wf_engine.GetItemAttrText(itemtype, itemkey, 'CURRENCY_CODE');

      l_bank_account_name :=
	wf_engine.GetItemAttrText(itemtype, itemkey, 'BANK_ACCOUNT_NAME');

      create_adhoc_role('PACCOUNT_UPDATED_'||l_bank_account_number, l_receiver);

      wf_engine.SetItemAttrText (itemtype   => itemtype,
				 itemkey    => itemkey,
				 aname      => 'RECEIVER',
				 avalue     => l_receiver);

      get_buyers('SUPP_BANK_ACCT_CHANGE_REQ',l_cur);
      add_user_to_role_from_cur(l_cur, l_receiver, l_count);

      IF l_count > 0 THEN
	 resultout := 'COMPLETE:Y';
       ELSE
	 resultout := 'COMPLETE:N';
      END IF;
      RETURN;
   END IF;

   resultout := ' ';
   RETURN;

EXCEPTION
   WHEN OTHERS THEN
      WF_CORE.CONTEXT ('POS_SPM_WF_PKG1', 'setup_acct_upd_buyer_rcvr', itemtype,
		       itemkey, to_char(actid), funcmode);
      RAISE;
END setup_acct_upd_buyer_rcvr;

-- return a cursor of usernames of suppliers
-- whose have profile management function
PROCEDURE get_spm_supplier_for_vendor
  (p_vendor_id IN  NUMBER,
   x_refcur    OUT nocopy g_refcur)
  IS
     l_function_id NUMBER;
BEGIN
   l_function_id := get_function_id (g_supplier_function_name);

   -- Specifically, this query returns
   -- supplier admins who have a responsibility that has a menu that includes
   -- the specific supplier function;
   --
   OPEN x_refcur FOR
     select DISTINCT psuv.user_name
     from fnd_responsibility fr,
     fnd_user_resp_groups_direct furg,
     pos_supplier_users_v psuv
     where fr.menu_id IN
     (SELECT fme.menu_id
      FROM fnd_menu_entries fme
      START WITH fme.function_id = l_function_id
      CONNECT BY PRIOR menu_id = sub_menu_id
      )
     AND ( furg.end_date is null or furg.end_date > sysdate )
       AND furg.security_group_id = 0
       AND fr.responsibility_id = furg.responsibility_id
       AND fr.application_id = furg.responsibility_application_id
       AND psuv.user_id = furg.user_id
       AND psuv.vendor_id = p_vendor_id;
END get_spm_supplier_for_vendor;

-- wf function activity to setup supplier receivers for buyer account update
PROCEDURE setup_acct_upd_supp_rcvr
  (itemtype  IN VARCHAR2,
   itemkey   IN VARCHAR2,
   actid     IN NUMBER,
   funcmode  IN VARCHAR2,
   resultout OUT nocopy VARCHAR2)
IS
BEGIN
 -- This method is no longer required since IBY now controls the bank account creation
 -- and update flows.
 null;

END setup_acct_upd_supp_rcvr;

-- wf function activity to setup buyer receiver for account creation
PROCEDURE setup_acct_crt_buyer_rcvr
  (itemtype  IN VARCHAR2,
   itemkey   IN VARCHAR2,
   actid     IN NUMBER,
   funcmode  IN VARCHAR2,
   resultout OUT nocopy VARCHAR2)
IS
     l_receiver  wf_roles.name%TYPE;
     l_cur g_refcur;
     l_count NUMBER;
     l_vendor_id NUMBER;
     l_bank_account_name   iby_ext_bank_accounts_v.bank_account_name%TYPE;
     l_bank_account_number iby_ext_bank_accounts_v.bank_account_number%TYPE;
     l_currency_code       iby_ext_bank_accounts_v.currency_code%TYPE;

BEGIN
   IF ( funcmode = 'RUN' ) THEN

      l_vendor_id :=
	wf_engine.GetItemAttrNumber(itemtype, itemkey, 'VENDOR_ID');

      l_bank_account_number :=
	wf_engine.GetItemAttrText(itemtype, itemkey, 'BANK_ACCOUNT_NUMBER');

      l_currency_code :=
	wf_engine.GetItemAttrText(itemtype, itemkey, 'CURRENCY_CODE');

      l_bank_account_name :=
	wf_engine.GetItemAttrText(itemtype, itemkey, 'BANK_ACCOUNT_NAME');

      create_adhoc_role('PACCOUNT_CREATED_'|| l_vendor_id, l_receiver);

      wf_engine.SetItemAttrText (itemtype   => itemtype,
				 itemkey    => itemkey,
				 aname      => 'RECEIVER',
				 avalue     => l_receiver);

      get_buyers('SUPP_BANK_ACCT_CHANGE_REQ',l_cur);
      add_user_to_role_from_cur(l_cur, l_receiver, l_count);

      IF l_count > 0 THEN
	 resultout := 'COMPLETE:Y';
       ELSE
	 resultout := 'COMPLETE:N';
      END IF;
      RETURN;
   END IF;

   resultout := ' ';
   RETURN;

EXCEPTION
   WHEN OTHERS THEN
      WF_CORE.CONTEXT ('POS_SPM_WF_PKG1', 'setup_acct_crt_buyer_rcvr', itemtype,itemkey, to_char(actid), funcmode);
END setup_acct_crt_buyer_rcvr;

-- wf function activity to setup supplier receiver for account creation
PROCEDURE setup_acct_crt_supp_rcvr
  (itemtype  IN VARCHAR2,
   itemkey   IN VARCHAR2,
   actid     IN NUMBER,
   funcmode  IN VARCHAR2,
   resultout OUT nocopy VARCHAR2)
IS
BEGIN
 -- This method is no longer required since IBY now controls the bank account creation
 -- and update flows.
 null;
END setup_acct_crt_supp_rcvr;

PROCEDURE notify_account_create
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2)
  IS
     l_itemtype wf_items.item_type%TYPE;
     l_itemkey  wf_items.item_key%TYPE;
     l_process   wf_process_activities.process_name%TYPE;
     l_step      NUMBER;
     l_supplier_name  ap_suppliers.vendor_name%TYPE;
     l_first_name      hz_parties.person_first_name%TYPE;
     l_last_name       hz_parties.person_last_name%TYPE;

BEGIN
   l_step := 0;
   get_supplier_name(p_vendor_id, l_supplier_name);
   get_current_user_name(l_first_name, l_last_name);

   l_step := 1;
   get_wf_item_type (l_itemtype);

   l_step := 2;
   l_process := 'PACCOUNT_CREATED';

   get_wf_item_key (l_process,
                    To_char(p_vendor_id),
                    l_itemkey);

   l_step := 3;
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 4;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     => pos_url_pkg.get_dest_page_url ('POS_SBD_BUYER_MAIN', 'BUYER'));

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPPLIER_NAME',
                              avalue     => l_supplier_name);

   wf_engine.SetItemAttrNumber (itemtype   => l_itemtype,
				itemkey    => l_itemkey,
				aname      => 'VENDOR_ID',
				avalue     => p_vendor_id);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_NAME',
                              avalue     => p_bank_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_ACCOUNT_NUMBER',
                              avalue     => IBY_EXT_BANKACCT_PUB.Mask_Bank_Number(p_bank_account_number));

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'FIRST_NAME',
                              avalue     => l_first_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'LAST_NAME',
                              avalue     => l_last_name);

   l_step := 5;
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   x_itemtype := l_itemtype;
   x_itemkey := l_itemkey;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_ACCOUNT_CREATE',l_itemtype,l_itemkey);
      raise_application_error(-20050, 'Failure at step ' || l_step, true);

END notify_account_create;

PROCEDURE notify_buyer_create_account
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2)
  IS
     l_itemtype wf_items.item_type%TYPE;
     l_itemkey  wf_items.item_key%TYPE;
     l_process   wf_process_activities.process_name%TYPE;
     l_step      NUMBER;
     l_supplier_name  ap_suppliers.vendor_name%TYPE;
     l_enterprise_name hz_parties.party_name%TYPE;
     l_first_name      hz_parties.person_first_name%TYPE;
     l_last_name       hz_parties.person_last_name%TYPE;

BEGIN
   l_step := 0;

   get_supplier_name(p_vendor_id, l_supplier_name);
   get_enterprise_name(l_enterprise_name);
   get_current_user_name(l_first_name, l_last_name);

   l_step := 1;

   get_wf_item_type (l_itemtype);

   l_step := 2;

   l_process := 'PACCT_BUYER_CREATE';

   get_wf_item_key (l_process,
                    To_char(p_vendor_id),
                    l_itemkey);

   l_step := 3;

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 4;

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     => pos_url_pkg.get_external_login_url);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPPLIER_NAME',
                              avalue     => l_supplier_name);

   wf_engine.SetItemAttrNumber (itemtype   => l_itemtype,
				itemkey    => l_itemkey,
				aname      => 'VENDOR_ID',
				avalue     => p_vendor_id);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_NAME',
                              avalue     => p_bank_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_ACCOUNT_NUMBER',
                              avalue     => IBY_EXT_BANKACCT_PUB.Mask_Bank_Number(p_bank_account_number));

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => l_enterprise_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'FIRST_NAME',
                              avalue     => l_first_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'LAST_NAME',
                              avalue     => l_last_name);
   l_step := 5;

   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   x_itemtype := l_itemtype;
   x_itemkey := l_itemkey;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_BUYER_CREATE_ACCOUNT',l_itemtype,l_itemkey);
      raise_application_error(-20050, 'Failure at step ' || l_step, true);
end notify_buyer_create_account;

PROCEDURE notify_account_update
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   p_currency_code       IN VARCHAR2,
   p_bank_account_name   IN VARCHAR2,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2)
  IS
     l_itemtype wf_items.item_type%TYPE;
     l_itemkey  wf_items.item_key%TYPE;
     l_process   wf_process_activities.process_name%TYPE;
     l_step      NUMBER;
     l_supplier_name  ap_suppliers.vendor_name%TYPE;
     l_first_name      hz_parties.person_first_name%TYPE;
     l_last_name       hz_parties.person_last_name%TYPE;

BEGIN
   l_step := 0;

   get_supplier_name(p_vendor_id, l_supplier_name);
   get_current_user_name(l_first_name, l_last_name);

   l_step := 1;

   get_wf_item_type (l_itemtype);

   l_step := 2;

   l_process := 'PACCOUNT_UPDATED';

   get_wf_item_key (l_process,
                    To_char(p_vendor_id),
                    l_itemkey);

   l_step := 3;

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 4;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     => pos_url_pkg.get_dest_page_url ('POS_SBD_BUYER_MAIN', 'BUYER'));

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPPLIER_NAME',
                              avalue     => l_supplier_name);

   wf_engine.SetItemAttrNumber (itemtype   => l_itemtype,
				itemkey    => l_itemkey,
				aname      => 'VENDOR_ID',
				avalue     => p_vendor_id);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_NAME',
                              avalue     => p_bank_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_ACCOUNT_NUMBER',
                              avalue     => IBY_EXT_BANKACCT_PUB.Mask_Bank_Number(p_bank_account_number));

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'CURRENCY_CODE',
                              avalue     => p_currency_code);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_ACCOUNT_NAME',
                              avalue     => p_bank_account_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'FIRST_NAME',
                              avalue     => l_first_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'LAST_NAME',
                              avalue     => l_last_name);

   l_step := 5;

   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   x_itemtype := l_itemtype;
   x_itemkey := l_itemkey;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_ACCOUNT_UPDATE',l_itemtype,l_itemkey);
      raise_application_error(-20050, 'Failure at step ' || l_step, true);

END notify_account_update;

PROCEDURE notify_buyer_update_account
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   p_currency_code       IN VARCHAR2,
   p_bank_account_name   IN VARCHAR2,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2)
  IS
     l_itemtype wf_items.item_type%TYPE;
     l_itemkey  wf_items.item_key%TYPE;
     l_process   wf_process_activities.process_name%TYPE;
     l_step      NUMBER;
     l_supplier_name  ap_suppliers.vendor_name%TYPE;
     l_first_name      hz_parties.person_first_name%TYPE;
     l_last_name       hz_parties.person_last_name%TYPE;

BEGIN
   l_step := 0;

   get_supplier_name(p_vendor_id, l_supplier_name);
   get_current_user_name(l_first_name, l_last_name);

   l_step := 1;

   get_wf_item_type (l_itemtype);

   l_step := 2;

   l_process := 'PACCT_BUYER_UPDATE';

   get_wf_item_key (l_process,
                    To_char(p_vendor_id),
                    l_itemkey);

   l_step := 3;

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 4;

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     => pos_url_pkg.get_external_login_url);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPPLIER_NAME',
                              avalue     => l_supplier_name);

   wf_engine.SetItemAttrNumber (itemtype   => l_itemtype,
				itemkey    => l_itemkey,
				aname      => 'VENDOR_ID',
				avalue     => p_vendor_id);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_NAME',
                              avalue     => p_bank_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_ACCOUNT_NUMBER',
                              avalue     => IBY_EXT_BANKACCT_PUB.Mask_Bank_Number(p_bank_account_number));

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'CURRENCY_CODE',
                              avalue     => p_currency_code);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_ACCOUNT_NAME',
                              avalue     => p_bank_account_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'FIRST_NAME',
                              avalue     => l_first_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'LAST_NAME',
                              avalue     => l_last_name);

   l_step := 5;

   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   x_itemtype := l_itemtype;
   x_itemkey := l_itemkey;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_BUYER_UPDATE_ACCOUNT',l_itemtype,l_itemkey);
      raise_application_error(-20050, 'Failure at step ' || l_step, true);

END notify_buyer_update_account;

PROCEDURE notify_sup_on_acct_action
  (p_bank_account_number IN VARCHAR2,
   p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_request_status      IN VARCHAR2,
   p_note                IN VARCHAR2,
   x_itemtype            OUT nocopy VARCHAR2,
   x_itemkey             OUT nocopy VARCHAR2
   ) IS

      l_itemtype wf_items.item_type%TYPE;
      l_itemkey  wf_items.item_key%TYPE;
      l_process   wf_process_activities.process_name%TYPE;
      l_enterprise_name hz_parties.party_name%TYPE;
      l_step NUMBER;

BEGIN
   l_step := 0;

   IF p_request_status = 'APPROVED' THEN
      l_process := 'PACCOUNT_APPROVED';
    ELSIF p_request_status = 'REJECTED' THEN
      l_process := 'PACCOUNT_REJECTED';
    ELSIF p_request_status = 'IN_VERIFICATION' THEN
      l_process := 'PACCOUNT_VERIFY';
    ELSIF p_request_status = 'VERIFICATION_FAILED' THEN
      l_process := 'PACCOUNT_VERIFY_FAILED';
   END IF;

   get_wf_item_type (l_itemtype);
   get_wf_item_key (l_process,To_char(p_vendor_id),l_itemkey);

   l_step := 3;

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 4;
   wf_engine.SetItemAttrNumber (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'VENDOR_ID',
                              avalue     => p_vendor_id);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_NAME',
                              avalue     => p_bank_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_ACCOUNT_NUMBER',
                              avalue     => IBY_EXT_BANKACCT_PUB.Mask_Bank_Number(p_bank_account_number));

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BUYER_NOTE',
                              avalue     => 'PLSQL:POS_SPM_WF_PKG1.BANK_ACCT_BUYER_NOTE/'||p_note);

   IF l_process = 'PACCOUNT_VERIFY' OR l_process = 'PACCOUNT_VERIFY_FAILED'
   THEN
      get_enterprise_name(l_enterprise_name);
      wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                                 itemkey    => l_itemkey,
                                 aname      => 'ENTERPRISE_NAME',
                                 avalue     => l_enterprise_name);
   END IF;

   l_step := 5;

   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   x_itemtype := l_itemtype;
   x_itemkey := l_itemkey;

END notify_sup_on_acct_action;

-- wf function activity to setup receiver for account address change or remove
PROCEDURE setup_acct_addr_receiver
  (itemtype  IN VARCHAR2,
   itemkey   IN VARCHAR2,
   actid     IN NUMBER,
   funcmode  IN VARCHAR2,
   resultout OUT nocopy VARCHAR2)
  IS
     l_receiver  wf_roles.name%TYPE;
     l_cur g_refcur;
     l_count NUMBER;
     l_vendor_id NUMBER;
     l_bank_branch_id NUMBER;
     l_currency_code       iby_ext_bank_accounts_v.currency_code%TYPE;
     l_bank_account_number iby_ext_bank_accounts_v.bank_account_number%TYPE;
     l_bank_account_name   iby_ext_bank_accounts_v.bank_account_name%TYPE;
     l_party_site_id NUMBER;
BEGIN
   IF ( funcmode = 'RUN' ) THEN

      l_vendor_id :=
	wf_engine.GetItemAttrNumber(itemtype, itemkey, 'VENDOR_ID');

      l_bank_account_number :=
	wf_engine.GetItemAttrText(itemtype, itemkey, 'BANK_ACCOUNT_NUMBER');

      l_currency_code :=
	wf_engine.GetItemAttrText(itemtype, itemkey, 'CURRENCY_CODE');

      l_bank_branch_id :=
	wf_engine.GetItemAttrNumber(itemtype, itemkey, 'BANK_BRANCH_ID');

      l_bank_account_name :=
	wf_engine.GetItemAttrText(itemtype, itemkey, 'BANK_ACCOUNT_NAME');

      create_adhoc_role('PACCT_ADDR_'|| l_vendor_id, l_receiver);

      wf_engine.SetItemAttrText (itemtype   => itemtype,
				 itemkey    => itemkey,
				 aname      => 'RECEIVER',
				 avalue     => l_receiver);

      get_buyers('SUPP_BANK_ACCT_CHANGE_REQ',l_cur);
      add_user_to_role_from_cur(l_cur, l_receiver, l_count);

      IF l_count > 0 THEN
	 resultout := 'COMPLETE:Y';
       ELSE
	 resultout := 'COMPLETE:N';
      END IF;
      RETURN;
   END IF;

   resultout := ' ';
   RETURN;

EXCEPTION
   WHEN OTHERS THEN
      WF_CORE.CONTEXT ('POS_SPM_WF_PKG1', 'setup_acct_addr_receiver', itemtype,
		       itemkey, to_char(actid), funcmode);
      RAISE;
END setup_acct_addr_receiver;

PROCEDURE notify_acct_addr_crtchgrmv
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   p_currency_code       IN VARCHAR2,
   p_bank_account_name   IN VARCHAR2,
   p_party_site_name  	 IN VARCHAR2,
   p_action              IN VARCHAR2,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2
  ) IS
     l_itemtype  wf_items.item_type%TYPE;
     l_itemkey   wf_items.item_key%TYPE;
     l_process   wf_process_activities.process_name%TYPE;
     l_step      NUMBER;
     l_count     NUMBER;

     l_supplier_name  ap_suppliers.vendor_name%TYPE;
     l_first_name      hz_parties.person_first_name%TYPE;
     l_last_name       hz_parties.person_last_name%TYPE;

BEGIN
   l_step := 0;

   get_supplier_name(p_vendor_id, l_supplier_name);
   get_current_user_name(l_first_name, l_last_name);

   l_step := 1;

   get_wf_item_type (l_itemtype);

   l_step := 2;

   l_process := p_action;

   get_wf_item_key (l_process,
                    To_char(p_vendor_id),
                    l_itemkey);

   l_step := 3;

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 4;

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     => pos_url_pkg.get_dest_page_url ('POS_SBD_BUYER_MAIN', 'BUYER'));

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPPLIER_NAME',
                              avalue     => l_supplier_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ADDRESS_NAME',
                              avalue     => p_party_site_name);

   wf_engine.SetItemAttrNumber (itemtype   => l_itemtype,
				itemkey    => l_itemkey,
				aname      => 'VENDOR_ID',
				avalue     => p_vendor_id);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_NAME',
                              avalue     => p_bank_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_ACCOUNT_NUMBER',
                              avalue     => IBY_EXT_BANKACCT_PUB.Mask_Bank_Number(p_bank_account_number));

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'CURRENCY_CODE',
                              avalue     => p_currency_code);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'BANK_ACCOUNT_NAME',
                              avalue     => p_bank_account_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'FIRST_NAME',
                              avalue     => l_first_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'LAST_NAME',
                              avalue     => l_last_name);

   l_step := 5;

   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   x_itemtype := l_itemtype;
   x_itemkey := l_itemkey;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'NOTIFY_ACCT_ADDR_CRTCHGRMV',l_itemtype,l_itemkey);
      raise_application_error(-20050, 'Failure at step ' || l_step, true);
END notify_acct_addr_crtchgrmv;

PROCEDURE notify_acct_addr_created
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   p_currency_code       IN VARCHAR2,
   p_bank_account_name   IN VARCHAR2,
   p_party_site_name  	 IN VARCHAR2,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2)
  IS
BEGIN
   notify_acct_addr_crtchgrmv(p_vendor_id,
                           p_bank_name,
			   p_bank_account_number,
			   p_currency_code,
			   p_bank_account_name,
			   p_party_site_name,
			   'PACCT_ADDR_CREATED',
			   x_itemtype,
			   x_itemkey);

END notify_acct_addr_created;

PROCEDURE notify_acct_addr_changed
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   p_currency_code       IN VARCHAR2,
   p_bank_account_name   IN VARCHAR2,
   p_party_site_name  	 IN VARCHAR2,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2)
  IS
BEGIN
   notify_acct_addr_crtchgrmv(p_vendor_id,
                           p_bank_name,
			   p_bank_account_number,
			   p_currency_code,
			   p_bank_account_name,
			   p_party_site_name,
			   'PACCT_ADDR_CHANGED',
			   x_itemtype,
			   x_itemkey);

END notify_acct_addr_changed;

PROCEDURE notify_acct_addr_removed
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   p_currency_code       IN VARCHAR2,
   p_bank_account_name   IN VARCHAR2,
   p_party_site_name  	 IN VARCHAR2,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2)
  IS
BEGIN
   notify_acct_addr_crtchgrmv(p_vendor_id,
                           p_bank_name,
			   p_bank_account_number,
			   p_currency_code,
			   p_bank_account_name,
			   p_party_site_name,
			   'PACCT_ADDR_REMOVED',
			   x_itemtype,
			   x_itemkey);

END notify_acct_addr_removed;

FUNCTION get_supplier_reg_url
  (p_reg_key       IN VARCHAR2
   )
  RETURN VARCHAR2 IS
BEGIN
   RETURN pos_url_pkg.get_external_url ||
     'OA_HTML/jsp/pos/suppreg/SupplierRegister.jsp?regkey=' ||
     p_reg_key;
END get_supplier_reg_url;

PROCEDURE send_supplier_invite_reg_ntf
  (p_supplier_reg_id IN NUMBER
   )
  IS
     l_itemtype    wf_items.item_type%TYPE;
     l_itemkey     wf_items.item_key%TYPE;
     l_receiver    wf_roles.name%TYPE;
     l_process     wf_process_activities.process_name%TYPE;

     CURSOR l_cur IS
	SELECT psr.reg_key, pcr.first_name, pcr.last_name, pcr.email_address, psr.supplier_name
	  FROM pos_supplier_registrations psr,
	       pos_contact_requests pcr,
	       pos_supplier_mappings psm
	 WHERE psr.supplier_reg_id = psm.supplier_reg_id
	   AND psr.supplier_reg_id = p_supplier_reg_id
  	   AND pcr.mapping_id = psm.mapping_id
	   AND pcr.do_not_delete = 'Y';

     l_rec l_cur%ROWTYPE;

     l_enterprise_name hz_parties.party_name%TYPE;
     l_employeeId NUMBER;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;

   get_wf_item_type(l_itemtype);
   l_process := 'SEND_SUPPLIER_INVITE_REG_NTF';
   get_wf_item_key(l_process, p_supplier_reg_id, l_itemkey);
   -- l_receiver := l_process || '_' || p_supplier_reg_id;
   -- for the bug 17276337
   l_receiver := l_rec.supplier_name;

   wf_directory.createadhocuser
     ( name          => l_receiver,
       -- display_name  => l_receiver,
       -- for the bug 17276337
       display_name  => l_rec.email_address,
       email_address => l_rec.email_address
       );

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process
                           );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver
                              );

   get_enterprise_name(l_enterprise_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => l_enterprise_name
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     => get_supplier_reg_url(l_rec.reg_key)
                              );

   wf_engine.StartProcess (itemtype => l_itemtype,
                           itemkey  => l_itemkey
                           );
   POS_VENDOR_REG_PKG.get_employeeId(fnd_global.user_id, l_employeeId);
   pos_vendor_reg_pkg.update_reg_action_hist( p_supp_reg_id 	=>  p_supplier_reg_id,
                                              p_action      	=> g_actn_send_supp_invite,
											                        p_note     		=>  null,
                                              p_from_user_id 	=> l_employeeId,
											                        p_to_user_id 	=> NULL
                           );

END send_supplier_invite_reg_ntf;

PROCEDURE send_supplier_reg_reopen_ntf
  (p_supplier_reg_id IN NUMBER
   )
  IS
     l_itemtype    wf_items.item_type%TYPE;
     l_itemkey     wf_items.item_key%TYPE;
     l_receiver    wf_roles.name%TYPE;
     l_process     wf_process_activities.process_name%TYPE;

     CURSOR l_cur IS
	SELECT psr.reg_key, pcr.first_name, pcr.last_name, pcr.email_address, psr.supplier_name
	  FROM pos_supplier_registrations psr,
	       pos_contact_requests pcr,
	       pos_supplier_mappings psm
	 WHERE psr.supplier_reg_id = psm.supplier_reg_id
	   AND psr.supplier_reg_id = p_supplier_reg_id
  	   AND pcr.mapping_id = psm.mapping_id
	   AND pcr.do_not_delete = 'Y';

     l_rec l_cur%ROWTYPE;

     l_enterprise_name hz_parties.party_name%TYPE;

     l_wf_role_rec wf_directory.wf_local_roles_rec_type;

BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;

   get_wf_item_type(l_itemtype);
   l_process := 'SEND_SUPPLIER_REG_REOPEN_NTF';
   get_wf_item_key(l_process, p_supplier_reg_id, l_itemkey);

   l_receiver := l_rec.supplier_name;

   wf_directory.GetRoleInfo
     ( role          => l_receiver,
       display_name  => l_wf_role_rec.display_name,
       email_address => l_wf_role_rec.email_address,
       notification_preference => l_wf_role_rec.notification_preference,
       language      => l_wf_role_rec.language,
       territory     => l_wf_role_rec.territory
     );

   if (l_wf_role_rec.email_address is null) then
     --ad hoc role doesn't exist, create a new one
     wf_directory.CreateAdHocRole
       ( role_name          => l_receiver,
         role_display_name  => l_receiver,
         email_address      => l_rec.email_address
       );
   else
     --ad hoc role already exist, check for email address
     if (l_wf_role_rec.email_address <> l_rec.email_address) then
       --if the contact email address has been changed, modify the role email
       wf_directory.SetAdHocRoleAttr
       ( role_name          => l_receiver,
         email_address      => l_rec.email_address
       );
     end if;
   end if;

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process
                           );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver
                              );

   get_enterprise_name(l_enterprise_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => l_enterprise_name
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPP_REG_STATUS_URL',
                              avalue     => get_supplier_reg_url(l_rec.reg_key)
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'MESSAGE_SUBJECT',
                              avalue     => GET_SUPP_REOPEN_NOTIF_SUBJECT(l_enterprise_name)
                              );

  wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'MESSAGE_BODY',
                              avalue     => 'PLSQLCLOB:POS_SPM_WF_PKG1.GET_SUPP_REOPEN_NOTIF_BODY/'||l_itemtype ||':' ||l_itemkey ||'#'||p_supplier_reg_id
                              );

   wf_engine.StartProcess (itemtype => l_itemtype,
                           itemkey  => l_itemkey
                           );



END send_supplier_reg_reopen_ntf;

PROCEDURE send_supplier_reg_link_ntf
  (p_supplier_reg_id IN NUMBER
   )
  IS
     l_itemtype    wf_items.item_type%TYPE;
     l_itemkey     wf_items.item_key%TYPE;
     l_receiver    wf_roles.name%TYPE;
     l_process     wf_process_activities.process_name%TYPE;

     CURSOR l_cur IS
	SELECT psr.reg_key, pcr.first_name, pcr.last_name, pcr.email_address, psr.supplier_name
	  FROM pos_supplier_registrations psr,
	       pos_contact_requests pcr,
	       pos_supplier_mappings psm
	 WHERE psr.supplier_reg_id = psm.supplier_reg_id
	   AND psr.supplier_reg_id = p_supplier_reg_id
  	   AND pcr.mapping_id = psm.mapping_id
	   AND pcr.do_not_delete = 'Y';

     l_rec l_cur%ROWTYPE;

     l_enterprise_name hz_parties.party_name%TYPE;

     l_wf_role_rec wf_directory.wf_local_roles_rec_type;

BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;

   get_wf_item_type(l_itemtype);
   l_process := 'SEND_SUPPLIER_REG_LINK_NTF';
   get_wf_item_key(l_process, p_supplier_reg_id, l_itemkey);


   --l_receiver := l_rec.supplier_name;
   l_receiver := l_rec.first_name || ' ' || l_rec.last_name;

   wf_directory.GetRoleInfo
     ( role          => l_receiver,
       display_name  => l_wf_role_rec.display_name,
       email_address => l_wf_role_rec.email_address,
       notification_preference => l_wf_role_rec.notification_preference,
       language      => l_wf_role_rec.language,
       territory     => l_wf_role_rec.territory
     );

   if (l_wf_role_rec.email_address is null) then
     --ad hoc role doesn't exist, create a new one
     wf_directory.CreateAdHocRole
       ( role_name          => l_receiver,
         role_display_name  => l_receiver,
         email_address      => l_rec.email_address
       );
   else
     --ad hoc role already exist, check for email address
     if (l_wf_role_rec.email_address <> l_rec.email_address) then
       --if the contact email address has been changed, modify the role email
       wf_directory.SetAdHocRoleAttr
       ( role_name          => l_receiver,
         email_address      => l_rec.email_address
       );
     end if;
   end if;

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process
                           );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver
                              );

   get_enterprise_name(l_enterprise_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => l_enterprise_name
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPP_REG_STATUS_URL',
                              avalue     => get_supplier_reg_url(l_rec.reg_key)
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'MESSAGE_SUBJECT',
                              avalue     => GET_SUPP_LINK_NOTIF_SUBJECT(l_enterprise_name)
                              );

  wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'MESSAGE_BODY',
                              avalue     => 'PLSQLCLOB:POS_SPM_WF_PKG1.GET_SUPP_LINK_NOTIF_BODY/'||l_itemtype ||':' ||l_itemkey ||'#'||p_supplier_reg_id
                              );

   wf_engine.StartProcess (itemtype => l_itemtype,
                           itemkey  => l_itemkey
                           );


END send_supplier_reg_link_ntf;
PROCEDURE send_supplier_reg_saved_ntf
  (p_supplier_reg_id IN NUMBER
   )
  IS
     l_itemtype    wf_items.item_type%TYPE;
     l_itemkey     wf_items.item_key%TYPE;
     l_receiver    wf_roles.name%TYPE;
     l_process     wf_process_activities.process_name%TYPE;

     CURSOR l_cur IS
	SELECT psr.reg_key, pcr.first_name, pcr.last_name, pcr.email_address, psr.supplier_name
	  FROM pos_supplier_registrations psr,
	       pos_contact_requests pcr,
	       pos_supplier_mappings psm
	 WHERE psr.supplier_reg_id = psm.supplier_reg_id
	   AND psr.supplier_reg_id = p_supplier_reg_id
  	   AND pcr.mapping_id = psm.mapping_id
	   AND pcr.do_not_delete = 'Y';

     l_rec l_cur%ROWTYPE;

     l_enterprise_name hz_parties.party_name%TYPE;

     l_wf_role_rec wf_directory.wf_local_roles_rec_type;

BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;

   get_wf_item_type(l_itemtype);
   l_process := 'SEND_SUPPLIER_REG_SAVED_NTF';
   get_wf_item_key(l_process, p_supplier_reg_id, l_itemkey);

   -- bug 10112371 - changing the value of l_receiver so that it reflects supplier_name in the notification
   -- l_receiver := l_process || '_' || p_supplier_reg_id;
   l_receiver := l_rec.supplier_name;

   wf_directory.GetRoleInfo
     ( role          => l_receiver,
       display_name  => l_wf_role_rec.display_name,
       email_address => l_wf_role_rec.email_address,
       notification_preference => l_wf_role_rec.notification_preference,
       language      => l_wf_role_rec.language,
       territory     => l_wf_role_rec.territory
     );

   if (l_wf_role_rec.email_address is null) then
     --ad hoc role doesn't exist, create a new one
     wf_directory.CreateAdHocRole
       ( role_name          => l_receiver,
         role_display_name  => l_receiver,
         email_address      => l_rec.email_address
       );
   else
     --ad hoc role already exist, check for email address
     if (l_wf_role_rec.email_address <> l_rec.email_address) then
       --if the contact email address has been changed, modify the role email
       wf_directory.SetAdHocRoleAttr
       ( role_name          => l_receiver,
         email_address      => l_rec.email_address
       );
     end if;
   end if;

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process
                           );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver
                              );

   get_enterprise_name(l_enterprise_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => l_enterprise_name
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPP_REG_STATUS_URL',
                              avalue     => get_supplier_reg_url(l_rec.reg_key)
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'MESSAGE_SUBJECT',
                              avalue     => GET_SUPP_SAVE_NOTIF_SUBJECT(l_enterprise_name)
                              );

  wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'MESSAGE_BODY',
                              avalue     => 'PLSQLCLOB:POS_SPM_WF_PKG1.GET_SUPP_SAVE_NOTIF_BODY/'||l_itemtype ||':' ||l_itemkey ||'#'||p_supplier_reg_id
                              );

   wf_engine.StartProcess (itemtype => l_itemtype,
                           itemkey  => l_itemkey
                           );

END send_supplier_reg_saved_ntf;


PROCEDURE send_supplier_reg_submit_ntf
  (p_supplier_reg_id IN NUMBER
   )
  IS
     l_itemtype    wf_items.item_type%TYPE;
     l_itemkey     wf_items.item_key%TYPE;
     l_receiver    wf_roles.name%TYPE;
     l_process     wf_process_activities.process_name%TYPE;

     CURSOR l_cur IS
	SELECT psr.reg_key, pcr.first_name, pcr.last_name, pcr.email_address, psr.supplier_name
	  FROM pos_supplier_registrations psr,
	       pos_contact_requests pcr,
	       pos_supplier_mappings psm
	 WHERE psr.supplier_reg_id = psm.supplier_reg_id
	   AND psr.supplier_reg_id = p_supplier_reg_id
  	   AND pcr.mapping_id = psm.mapping_id
	   AND pcr.do_not_delete = 'Y';

     l_rec l_cur%ROWTYPE;

     l_enterprise_name hz_parties.party_name%TYPE;

     l_wf_role_rec wf_directory.wf_local_roles_rec_type;

BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;

   get_wf_item_type(l_itemtype);
   l_process := 'SEND_SUPPLIER_REG_SUBMIT_NTF';
   get_wf_item_key(l_process, p_supplier_reg_id, l_itemkey);


   --l_receiver := l_rec.supplier_name;
   l_receiver := l_rec.first_name || ' ' || l_rec.last_name;

   wf_directory.GetRoleInfo
     ( role          => l_receiver,
       display_name  => l_wf_role_rec.display_name,
       email_address => l_wf_role_rec.email_address,
       notification_preference => l_wf_role_rec.notification_preference,
       language      => l_wf_role_rec.language,
       territory     => l_wf_role_rec.territory
     );

   if (l_wf_role_rec.email_address is null) then
     --ad hoc role doesn't exist, create a new one
     wf_directory.CreateAdHocRole
       ( role_name          => l_receiver,
         role_display_name  => l_receiver,
         email_address      => l_rec.email_address
       );
   else
     --ad hoc role already exist, check for email address
     if (l_wf_role_rec.email_address <> l_rec.email_address) then
       --if the contact email address has been changed, modify the role email
       wf_directory.SetAdHocRoleAttr
       ( role_name          => l_receiver,
         email_address      => l_rec.email_address
       );
     end if;
   end if;

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process
                           );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver
                              );

   get_enterprise_name(l_enterprise_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => l_enterprise_name
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPP_REG_STATUS_URL',
                              avalue     => get_supplier_reg_url(l_rec.reg_key)
                              );

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'MESSAGE_SUBJECT',
                              avalue     => GET_SUPP_SUBMIT_NOTIF_SUBJECT(l_enterprise_name)
                              );

  wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'MESSAGE_BODY',
                              avalue     => 'PLSQLCLOB:pos_spm_wf_pkg1.GET_SUPP_SUBMIT_NOTIF_BODY/'||l_itemtype ||':' ||l_itemkey ||'#'||p_supplier_reg_id
                              );

   wf_engine.StartProcess (itemtype => l_itemtype,
                           itemkey  => l_itemkey
                           );

END send_supplier_reg_submit_ntf;

-- Sending Notification to Suppliers from Prospective Supplier Page
PROCEDURE PROS_SUPP_NOTIFICATION
  (p_supplier_reg_id IN varchar2,
   p_msg_subject in varchar2,
   p_msg_body in varchar2
   )
  IS
     l_itemtype    wf_items.item_type%TYPE:='POSNOTIF';
     l_itemkey     wf_items.item_key%TYPE;
     l_receiver    wf_roles.name%TYPE;
     --Bug 10113987 unable to configure the notification messages in the oracle slm in html format
     --Use the new process SUPP_REG_NOTIFY
     l_process     wf_process_activities.process_name%TYPE:='SUPP_REG_NOTIFY';
     C_EMAIL_USER_LIST varchar2(30000);
     L_EMAIL_USER_COUNT number;
     L_ADHOC_USER VARCHAR2(400);
     L_DISPLAY_NAME VARCHAR2(200);
     L_FROM_NAME  VARCHAR2(100);
     l_employeeId NUMBER;

   CURSOR l_cur IS
  	SELECT psr.reg_key, pcr.first_name, pcr.last_name, pcr.email_address
	    FROM pos_supplier_registrations psr,
	       pos_contact_requests pcr,
	       pos_supplier_mappings psm
  	WHERE psr.supplier_reg_id = psm.supplier_reg_id
	  AND psr.supplier_reg_id = p_supplier_reg_id
  	AND pcr.mapping_id = psm.mapping_id
	  AND pcr.do_not_delete = 'Y';

     l_rec l_cur%ROWTYPE;
     l_wf_role_rec wf_directory.wf_local_roles_rec_type;

BEGIN

  L_EMAIL_USER_COUNT:=0;

   OPEN l_cur;
    FETCH l_cur INTO l_rec;
     IF l_cur%notfound THEN
       CLOSE l_cur;
       RAISE no_data_found;
     END IF;
   CLOSE l_cur;

   IF (l_rec.email_address IS NOT NULL) THEN
      L_ADHOC_USER:='ADHOC_USER_'||l_rec.first_name||'_'||TO_CHAR(SYSDATE, 'MMDDYYYY_HH24MISS')||FND_CRYPTO.SMALLRANDOMNUMBER;
      L_DISPLAY_NAME:=l_rec.last_name||','||l_rec.first_name;
      -- CREATING ADHOC USER
	  --Bug 10113987 Don't need to set the NOTIFICATION_PREFERENCE here
      WF_DIRECTORY.CREATEADHOCUSER(
                    NAME => L_ADHOC_USER,
                    DISPLAY_NAME => L_DISPLAY_NAME,
                    EMAIL_ADDRESS => l_rec.email_address
                         );
       L_EMAIL_USER_COUNT := L_EMAIL_USER_COUNT + 1;
    END IF;

   -- Creating ADHOC ROLE
   CREATE_ADHOC_ROLE(L_PROCESS,l_receiver);

   -- Assigning ADHOC User to ADHOC Role
   ADDUSERTOADHOCROLE(l_receiver,L_ADHOC_USER);

   -- GET THE CURRENT USER NAME
   SELECT USER_NAME INTO L_FROM_NAME FROM FND_USER WHERE USER_ID=FND_GLOBAL.USER_ID;

   -- GENERATING THE PROCESS KEY
   GET_WF_ITEM_KEY (l_process,To_char(p_supplier_reg_id),L_ITEMKEY);

   -- CREATE WORKFLOW PROCESS
   WF_ENGINE.CREATEPROCESS(ITEMTYPE => L_ITEMTYPE,
                           ITEMKEY  => L_ITEMKEY,
                           PROCESS  => L_PROCESS);

   WF_ENGINE.SETITEMATTRTEXT(ITEMTYPE => L_ITEMTYPE,
                             ITEMKEY  => L_ITEMKEY,
                             ANAME    => '#FROM_ROLE',
                             AVALUE   => L_FROM_NAME);

   WF_ENGINE.SETITEMATTRTEXT (ITEMTYPE   => L_ITEMTYPE,
                              ITEMKEY    => L_ITEMKEY,
                              ANAME      => 'NOTIF_RECEIVER_ROLE',
                              AVALUE     => l_receiver);

   WF_ENGINE.SETITEMATTRTEXT (ITEMTYPE   => L_ITEMTYPE,
                              ITEMKEY    => L_ITEMKEY,
                              ANAME      => 'SUPPMSGSUB',
                              AVALUE     => GET_SUPP_RETURN_NOTIF_SUBJECT());

   WF_ENGINE.SETITEMATTRTEXT (ITEMTYPE   => L_ITEMTYPE,
                              ITEMKEY    => L_ITEMKEY,
                              ANAME      => 'SUPPMSGBD',
                              AVALUE     => p_msg_body);
--Bug 10113987 unable to configure the notification messages in the oracle slm in html format
--Use the new attribute URL
   WF_ENGINE.SETITEMATTRTEXT (ITEMTYPE   => L_ITEMTYPE,
                              ITEMKEY    => L_ITEMKEY,
                              --ANAME      => 'SUPPADTMSG',
			                        ANAME      => 'URL',
                              AVALUE     => get_supplier_reg_url(l_rec.reg_key));

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'NOTIFY_SUPP_BODY_TEXT',
                              avalue     => 'PLSQLCLOB:POS_SPM_WF_PKG1.GET_SUPP_RETURN_NOTIF_BODY/'||l_itemtype ||':' ||l_itemkey ||'#'||p_supplier_reg_id
                              );

  WF_ENGINE.STARTPROCESS(ITEMTYPE => L_ITEMTYPE,
                          ITEMKEY  => L_ITEMKEY );

  POS_VENDOR_REG_PKG.get_employeeId(fnd_global.user_id, l_employeeId);

  pos_vendor_reg_pkg.update_reg_action_hist( p_supp_reg_id 	=>  p_supplier_reg_id,
                                            p_action      	=> pos_vendor_reg_pkg.ACTN_RETURN_TO_SUPP,
											p_note     		=>  p_msg_body,
                                            p_from_user_id 	=> l_employeeId,
											p_to_user_id 	=> NULL
                                            );

  -- Reject Reason ER : Nullify sm_note_to_buyer/ note_from_buyer when request is rejected
  IF (FND_PROFILE.VALUE('POS_SM_ENABLE_SPM_EXTENSION') = 'Y') THEN
    UPDATE pos_supplier_registrations
    SET sm_note_to_buyer = NULL
    WHERE supplier_reg_id = p_supplier_reg_id;
  ELSE
    UPDATE pos_supplier_registrations
    SET note_from_supplier = NULL
    WHERE supplier_reg_id = p_supplier_reg_id;
  END IF;

Exception
WHEN OTHERS THEN
      WF_CORE.CONTEXT('POSNOTIFY','POSNOTIFY',L_ITEMTYPE,L_ITEMKEY);
      WF_CORE.RAISE('ERROR_NAME');
      RAISE_APPLICATION_ERROR(-20041, 'FAILURE AT STEP ' , TRUE);

END PROS_SUPP_NOTIFICATION;

-- this is a private procedure. not intended to be public
PROCEDURE notify_bank_aprv_supp_aprv
  (p_vendor_id           IN  NUMBER,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2,
   x_receiver      	 OUT nocopy VARCHAR2
   )
  IS
     l_supplier_name   ap_suppliers.vendor_name%TYPE;
     l_itemtype        wf_items.item_type%TYPE;
     l_itemkey         wf_items.item_key%TYPE;
     l_receiver        wf_roles.name%TYPE;
     l_cur             g_refcur;
     l_count           NUMBER;
     l_process         wf_process_activities.process_name%TYPE;
     l_step NUMBER;
BEGIN
   l_step := 0;
   get_supplier_name(p_vendor_id, l_supplier_name);

   l_process := 'PSUPPLIER_ACCOUNT_APRV';

   l_step := 1;
   -- setup receiver
   create_adhoc_role(l_process || '_' || p_vendor_id, l_receiver);

   l_step := 3;
   get_buyers('SUPP_BANK_ACCT_CHANGE_REQ',l_cur);

   l_step := 4;
   add_user_to_role_from_cur(l_cur, l_receiver, l_count);
   IF l_count < 1 THEN
      -- there is no one to notify, so we just return
      x_itemtype := NULL;
      x_itemkey := NULL;
      x_receiver := NULL;
      RETURN;
   END IF;

   l_step := 5;

   -- create workflow process
   get_wf_item_type (l_itemtype);
   get_wf_item_key (l_process, p_vendor_id, l_itemkey);

   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);
   l_step := 6;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'SUPPLIER_NAME',
                              avalue     => l_supplier_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'VENDOR_ID',
                              avalue     => p_vendor_id);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL',
                              avalue     => pos_url_pkg.get_dest_page_url('POS_SBD_BUYER_MAIN', 'BUYER'));
   l_step := 7;
   setup_actioner_private(l_itemtype, l_itemkey);

   l_step := 8;
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );
   l_step := 9;
   x_itemtype := l_itemtype;
   x_itemkey  := l_itemkey;
   x_receiver := l_receiver;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'notify_bank_aprv_supp_aprv',l_itemtype,l_itemkey);
      IF ( fnd_log.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.string(fnd_log.level_error, 'pos_spm_wf_pkg1' , 'Call to notify_bank_aprv_supp_aprv failed');
      END IF;
END notify_bank_aprv_supp_aprv;
 -- notify the supplier that his/her supplier registration is approved
 -- when the user (primary contact) already exists in OID and auto-link of username is enabled
PROCEDURE notify_supplier_apprv_ssosync
 	   (p_supplier_reg_id IN  NUMBER,
 	    p_username        IN  VARCHAR2,
 	    x_itemtype        OUT nocopy VARCHAR2,
 	    x_itemkey         OUT nocopy VARCHAR2
 	    )
 	   IS
 	      l_itemtype wf_items.item_type%TYPE;
 	      l_itemkey  wf_items.item_key%TYPE;
 	      l_process  wf_process_activities.process_name%TYPE;
 	      l_enterprise_name hz_parties.party_name%TYPE;
 	      l_step    NUMBER;
 	 BEGIN
 	    l_step := 0;
 	    get_enterprise_name(l_enterprise_name);

 	    l_step := 1;
 	    l_process := 'PSUPPLIER_APPROVED_SSOSYNC';
 	    get_wf_item_type (l_itemtype);

 	    l_step := 2;
 	    get_wf_item_key (l_process,
 	                     To_char(p_supplier_reg_id),
 	                     l_itemkey);

 	    l_step := 3;
 	    wf_engine.CreateProcess(itemtype => l_itemtype,
 	                            itemkey  => l_itemkey,
 	                            process  => l_process);

 	    l_step := 4;
 	    wf_engine.SetItemAttrText (itemtype   => l_itemtype,
 	                               itemkey    => l_itemkey,
 	                               aname      => 'RECEIVER',
 	                               avalue     => p_username);

 	    wf_engine.SetItemAttrText (itemtype   => l_itemtype,
 	                               itemkey    => l_itemkey,
 	                               aname      => 'ENTERPRISE_NAME',
 	                               avalue     => l_enterprise_name);

 	    wf_engine.SetItemAttrText (itemtype   => l_itemtype,
 	                               itemkey    => l_itemkey,
 	                               aname      => 'USERNAME',
 	                               avalue     => p_username);

 	    wf_engine.SetItemAttrText (itemtype   => l_itemtype,
 	                               itemkey    => l_itemkey,
 	                               aname      => 'URL',
 	                               avalue     => pos_url_pkg.get_external_login_url);

 	    wf_engine.SetItemAttrText (itemtype   => l_itemtype,
 	                               itemkey    => l_itemkey,
 	                               aname      => 'ADMIN_EMAIL',
 	                               avalue     => get_admin_email);

 	    wf_engine.SetItemAttrText (itemtype   => l_itemtype,
 	                               itemkey    => l_itemkey,
 	                               aname      => 'BUYER_NOTE',
 	                               avalue     => 'PLSQL:POS_SPM_WF_PKG1.BUYER_NOTE/'||To_char(p_supplier_reg_id));

        --
        -- Begin Supplier Hub: OSN Integration
        -- See FUNCTION get_osn_message for more info.
        --
 	    wf_engine.SetItemAttrText (itemtype   => l_itemtype,
 	                               itemkey    => l_itemkey,
 	                               aname      => 'OSN_MESSAGE',
 	                               avalue     => get_osn_message);
        --
        -- End Supplier Hub: OSN Integration
        --

 	    l_step := 5;
 	    wf_engine.StartProcess(itemtype => l_itemtype,
 	                           itemkey  => l_itemkey );
 	    l_step := 6;
 	    x_itemtype := l_itemtype;
 	    x_itemkey  := l_itemkey;

 	 EXCEPTION
 	    WHEN OTHERS THEN
 	       wf_core.context(g_package_name,'NOTIFY_SUPPLIER_APPROVED_SSO_SYNC',l_itemtype,l_itemkey);
 	       raise_application_error(-20053, 'Failure at step ' || l_step, true);
 	 END notify_supplier_apprv_ssosync;

-- send email to non-primary contact of user registration
-- when the user already exists in OID and auto-link of username is enabled
PROCEDURE notify_user_approved_sso_sync
 	   (p_supplier_reg_id IN  NUMBER,
 	    p_username        IN  VARCHAR2,
 	    x_itemtype        OUT nocopy VARCHAR2,
 	    x_itemkey         OUT nocopy VARCHAR2
 	    )
 	   IS
 	      l_itemtype        wf_items.item_type%TYPE;
 	      l_itemkey         wf_items.item_key%TYPE;
 	      l_process         wf_process_activities.process_name%TYPE;
 	      l_enterprise_name hz_parties.party_name%TYPE;
 	      l_step            VARCHAR2(100);
 	 BEGIN
 	    l_step := 1;

 	    get_enterprise_name(l_enterprise_name);

 	    l_process := 'SUPPLIER_USER_CREATED_SSOSYNC';

 	    l_step := 2;
 	    get_wf_item_type (l_itemtype);

 	    l_step := 3;
 	    get_wf_item_key (l_process,
 	                     To_char(p_supplier_reg_id) || '_' || p_username,
 	                     l_itemkey);

 	    l_step := 4;
 	    wf_engine.CreateProcess(itemtype => l_itemtype,
 	                            itemkey  => l_itemkey,
 	                            process  => l_process);

 	    l_step := 5;
 	    wf_engine.SetItemAttrText (itemtype   => l_itemtype,
 	                               itemkey    => l_itemkey,
 	                               aname      => 'RECEIVER',
 	                               avalue     => p_username);

 	    l_step := 6;
 	    wf_engine.SetItemAttrText (itemtype   => l_itemtype,
 	                               itemkey    => l_itemkey,
 	                               aname      => 'ENTERPRISE_NAME',
 	                               avalue     => l_enterprise_name);

 	    l_step := 7;
 	    wf_engine.SetItemAttrText (itemtype   => l_itemtype,
 	                               itemkey    => l_itemkey,
 	                               aname      => 'USERNAME',
 	                               avalue     => p_username);

 	    l_step := 8;

 	    l_step := 9;
 	    wf_engine.SetItemAttrText (itemtype   => l_itemtype,
 	                               itemkey    => l_itemkey,
 	                               aname      => 'URL',
 	                               avalue     => pos_url_pkg.get_external_login_url);

 	    l_step := 10;
 	    wf_engine.SetItemAttrText (itemtype   => l_itemtype,
 	                               itemkey    => l_itemkey,
 	                               aname      => 'ADMIN_EMAIL',
 	                               avalue     => get_admin_email);

 	    l_step := 11;

 	    wf_engine.StartProcess(itemtype => l_itemtype,
 	                           itemkey  => l_itemkey );
 	    x_itemtype := l_itemtype;
 	    x_itemkey  := l_itemkey;

 	 EXCEPTION
 	    WHEN OTHERS THEN
 	       wf_core.context(g_package_name,'NOTIFY_USER_APPROVED_SSO_SYNC',l_itemtype,l_itemkey);
 	       raise_application_error(-20053, 'Failure at step ' || l_step, true);
 	 END notify_user_approved_sso_sync;

-- CODE ADDED FOR BUSINESS CLASSIFICATION RE-CERTIFICATION ER

PROCEDURE bc_recert_workflow
(
  ERRBUF      OUT nocopy VARCHAR2,
  RETCODE     OUT nocopy VARCHAR2
)
IS

  --l_supplier_count   NUMBER;
  l_vendor_id        NUMBER;
  ul                 NUMBER;

  l_user_name         VARCHAR2(100);
  l_email_address     VARCHAR2(100);
  l_enterprise_name   VARCHAR2(100);
  l_role_name         VARCHAR2(200);
  l_role_display_name VARCHAR2(100);
  l_vendor_id_char    VARCHAR2(20);

  l_last_certification_date DATE;
  l_due_date                DATE;
  l_expiration_date         DATE;

  l_itemtype            wf_items.item_type%TYPE;
  l_purge_itemkey       wf_items.item_key%TYPE;
  l_itemkey             wf_items.item_key%TYPE;
  l_purge_item_key_type wf_items.item_key%TYPE;
  l_process             wf_process_activities.process_name%TYPE;
  l_users               WF_DIRECTORY.UserTable;

  /* bug 8647019 */
  CURSOR l_vendor_id_cur IS
    SELECT APS.VENDOR_ID
    FROM AP_SUPPLIERS APS
    WHERE
      (
        Trunc(APS.BUS_CLASS_LAST_CERTIFIED_DATE) + To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_PERIOD')) = Trunc(SYSDATE) + To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_REMIND_DAYS'))
        OR
        (
                Trunc(SYSDATE) >= Trunc(APS.BUS_CLASS_LAST_CERTIFIED_DATE + To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_PERIOD')))
                AND
                Mod ( To_Number(Trunc(SYSDATE) - Trunc(APS.BUS_CLASS_LAST_CERTIFIED_DATE)) - To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_PERIOD'))
                ,To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_REMIND_DAYS'))
                ) = 0
        )
        OR APS.BUS_CLASS_LAST_CERTIFIED_DATE IS NULL
      )
      and
      (
        (aps.start_date_active IS NULL OR aps.start_date_active <= SYSDATE) and
        (aps.end_date_active IS NULL OR aps.end_date_active >= SYSDATE) AND
        (aps.vendor_type_lookup_code IS NULL OR aps.vendor_type_lookup_code <> 'EMPLOYEE')
      );

  CURSOR l_supplier_users_cur IS
    SELECT fu.user_name, fu.email_address
    FROM hz_relationships hzr, hz_parties hp, fnd_user fu, ap_suppliers ap, hz_party_usg_assignments hpua
    WHERE
      fu.user_id in (select spm.user_id from pos_spmntf_subscription spm
                     where spm.event_type = 'SUPP_BUS_CLASS_RECERT_NTF')
      AND fu.person_party_id = hp.party_id
      AND fu.email_address IS NOT NULL
      --AND (fu.end_date IS NULL OR fu.end_date >= SYSDATE)                     /* bug 8647019 */
      AND Nvl(fu.end_date, SYSDATE) >= sysdate
      AND ap.vendor_id = l_vendor_id
      AND hzr.object_id  = ap.party_id
      AND hzr.subject_type = 'PERSON'
      AND hzr.object_type = 'ORGANIZATION'
      AND hzr.relationship_type = 'CONTACT'
      AND hzr.relationship_code = 'CONTACT_OF'
      AND hzr.status  = 'A'
      --AND (hzr.start_date IS NULL OR hzr.start_date <= Sysdate)               /* bug 8647019 */
      --AND (hzr.end_date IS NULL OR hzr.end_date >= Sysdate)
      AND Nvl(hzr.end_date, SYSDATE) >= sysdate
      AND hzr.subject_id = hp.party_id
      AND hpua.party_id = hp.party_id
      AND hpua.status_flag = 'A'
      AND hpua.party_usage_code = 'SUPPLIER_CONTACT'
      --AND (hpua.effective_end_date IS NULL OR hpua.effective_end_date > Sysdate);     /* bug 8647019 */
      AND Nvl(hpua.effective_end_date, SYSDATE) >= SYSDATE;

  /* bug 8647019 */
  CURSOR l_purge_wf_items_cur(l_purge_item_key_type VARCHAR2) IS
    SELECT item_key
    FROM wf_items
    WHERE item_key LIKE l_purge_item_key_type
    and item_type like l_itemtype;

BEGIN

/* bug 8647019 */
 --l_supplier_count := 0;

    /* bug 8647019 */
/*    SELECT count(APS.VENDOR_ID)
    into l_supplier_count
    FROM AP_SUPPLIERS APS
    WHERE
      (
        Trunc(APS.BUS_CLASS_LAST_CERTIFIED_DATE) + To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_PERIOD')) = Trunc(SYSDATE) + To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_REMIND_DAYS'))
        OR
        (
                Trunc(SYSDATE) >= Trunc(APS.BUS_CLASS_LAST_CERTIFIED_DATE + To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_PERIOD')))
                AND
                Mod ( To_Number(Trunc(SYSDATE) - Trunc(APS.BUS_CLASS_LAST_CERTIFIED_DATE)) - To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_PERIOD'))
                ,To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_REMIND_DAYS'))
                ) = 0
        )
        OR APS.BUS_CLASS_LAST_CERTIFIED_DATE IS NULL
      )
      and
      (
        (aps.start_date_active IS NULL OR aps.start_date_active <= SYSDATE) and
        (aps.end_date_active IS NULL OR aps.end_date_active >= SYSDATE) AND
        (aps.vendor_type_lookup_code IS NULL OR aps.vendor_type_lookup_code <> 'EMPLOYEE')
      );
*/
  --IF l_supplier_count > 0 THEN

    OPEN l_vendor_id_cur;

      LOOP

        FETCH l_vendor_id_cur INTO l_vendor_id;
        EXIT WHEN l_vendor_id_cur%NOTFOUND;

        l_process := 'POS_BC_RECERT_REMIND_NOTIFY';

        get_wf_item_type (l_itemtype);

        l_purge_item_key_type := l_itemtype||'_'||l_process||'_%_VENDOR_ID_'||to_char(l_vendor_id);

        OPEN l_purge_wf_items_cur(l_purge_item_key_type);
          LOOP

            FETCH l_purge_wf_items_cur INTO l_purge_itemkey;
            EXIT WHEN l_purge_wf_items_cur%NOTFOUND;

            WF_PURGE.ITEMS (itemtype => l_itemtype,
                            itemkey  => l_purge_itemkey,
                            enddate  => SYSDATE,
                            docommit => true,
                            force    => TRUE
                           );
          END LOOP;
        CLOSE l_purge_wf_items_cur;

        ul := 0;

        OPEN l_supplier_users_cur;

          LOOP

            FETCH l_supplier_users_cur INTO l_user_name, l_email_address;
            EXIT WHEN l_supplier_users_cur%NOTFOUND;

            l_users(ul) := l_user_name;

            ul := ul + 1;

          END LOOP;

        CLOSE l_supplier_users_cur;

        IF ul > 0 THEN

          l_itemkey := l_itemtype||'_'||l_process||'_'||to_char(sysdate, 'JSSSSS')||'_'||'VENDOR_ID'||'_'||to_char(l_vendor_id);

          wf_engine.CreateProcess(itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  process  => l_process
                                 );

          get_enterprise_name(l_enterprise_name);

          wf_engine.SetItemAttrText(itemtype   => l_itemtype,
                                    itemkey    => l_itemkey,
                                    aname      => 'ENTERPRISE_NAME',
                                    avalue     => l_enterprise_name
                                   );

          wf_engine.SetItemAttrNumber (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'VENDOR_ID',
                                       avalue     => l_vendor_id
                                      );

          SELECT bus_class_last_certified_date, vendor_name, SYSDATE + To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_REMIND_DAYS'))
          INTO l_last_certification_date, l_role_display_name, l_expiration_date
          FROM ap_suppliers
          WHERE vendor_id = l_vendor_id;

          IF l_last_certification_date IS NOT NULL then
            l_due_date := l_last_certification_date + To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_PERIOD'));
          ELSE
            l_due_date := SYSDATE + To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_REMIND_DAYS'));
          END IF;

          wf_engine.SetItemAttrText(itemtype   => l_itemtype,
                                    itemkey    => l_itemkey,
                                    aname      => 'BC_RECERT_DUE_DATE',
                                    avalue     => l_due_date
                                   );

          l_role_name := l_process||' '||To_Char(l_vendor_id)||' '||to_char(sysdate, 'JSSSSS')||To_Char(fnd_crypto.smallrandomnumber);
/*
          select vendor_name
          into l_role_display_name
          from ap_suppliers
          where vendor_id = l_vendor_id;

          select SYSDATE + To_Number(FND_PROFILE.Value('POS_BUS_CLASS_RECERT_REMIND_DAYS'))
          into l_expiration_date
          from ap_suppliers
          where vendor_id = l_vendor_id;
*/

          WF_DIRECTORY.CreateAdHocRole2(role_name          => l_role_name,
                                      role_display_name  => l_role_display_name,
                                      notification_preference => 'MAILHTML',
                                      role_users              => l_users,
                                  expiration_date         => l_expiration_date
                                   );

          wf_engine.SetItemAttrText( itemtype   => l_itemtype,
                                    itemkey    => l_itemkey,
                                    aname      => 'BUS_CLASS_RECERT_RECEIVERS',
                                     avalue     => l_role_name
                                   );

          wf_engine.StartProcess(itemtype => l_itemtype,
                                 itemkey  => l_itemkey
                                 );

        END IF;

	-- bug 11870821 - refreshing the l_users array for each new supplier
	l_users.delete;

      END LOOP;

    CLOSE l_vendor_id_cur;

  --END IF;
EXCEPTION

  WHEN OTHERS THEN

     wf_core.context(g_package_name,'bc_recert_workflow',l_itemtype,l_itemkey);

     IF ( fnd_log.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.string(fnd_log.level_error, 'pos_spm_wf_pkg1' , 'Call to the workflow process for sending reminder notifications for Business Classification Re-Certification failed.');
     END IF;

END bc_recert_workflow;

-- END OF CODE ADDED FOR BUSINESS CLASSIFICATION RE-CERTIFICATION ER


-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_APPRV_SUPPLIER_SUBJECT
--Type:
--  Function
--Function:
--  It returns the tokens replaced FND message to Notification Message Subject
--Function Usage:
--  This function is used to replace the workflow message subject by FND Message & its tokens
--Logic Implemented:
-- The FND Message Name 'POS_APPROVE_SUPPLIER_SUBJECT' will be replaced with
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

FUNCTION GET_APPRV_SUPPLIER_SUBJECT(p_enterprise_name IN VARCHAR2)
RETURN VARCHAR2  IS
l_document VARCHAR2(32000);

BEGIN

        fnd_message.set_name('POS','POS_APPROVE_SUPPLIER_SUBJECT');
        fnd_message.set_token('ENTERPRISE_NAME', p_enterprise_name);
        l_document :=  fnd_message.get;
  RETURN l_document;
END GET_APPRV_SUPPLIER_SUBJECT;

-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_APPRV_SUPPLIER_BODY
--Type:
--  Procedure
--Procedure:
--  It returns the tokens replaced FND message to Notification Message Body
--Procedure Usage:
--  It is being used to replace the workflow message Body by FND Message & its tokens
--Logic Implemented:
-- For HTML Body:
-- The FND Message Name 'POS_APPROVE_SUPPLIER_HTML_BODY' will be replaced with
-- corresponding Message Text and tokens inside the Message Text also be replaced.
-- Then, replaced FND message will be return to the corresponding attribute
-- For TEXT Body:
-- The FND Message Name 'POS_APPROVE_SUPPLIER_TEXT_BODY' will be replaced with
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


PROCEDURE GET_APPRV_SUPPLIER_BODY(p_document_id    IN VARCHAR2,
			               display_type  IN VARCHAR2,
			               document      IN OUT NOCOPY CLOB,
			               document_type IN OUT NOCOPY VARCHAR2)
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_note          VARCHAR2(32000) := '';
l_enterprisename VARCHAR2(1000) := '';
l_url           VARCHAR2(3000) := '';
l_adminemail    VARCHAR2(1000) := '';
l_username      VARCHAR2(500) := '';
l_password      VARCHAR2(100) := '';
l_supplier_reg_id NUMBER;
l_disp_type          VARCHAR2(20) := 'text/plain';
l_itemtype wf_items.item_type%TYPE;
l_itemkey  wf_items.item_key%TYPE;

BEGIN

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_APPRV_SUPPLIER_BODY', 'p_document_id ' || p_document_id);
  END IF;

  l_itemtype := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_itemkey := substr(p_document_id, instr(p_document_id, ':') + 1, (instr(p_document_id, '#') - instr(p_document_id, ':'))-1 );
  l_supplier_reg_id := substr(p_document_id, instr(p_document_id, '#') + 1, length(p_document_id));

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_APPRV_SUPPLIER_BODY', 'l_item_type ' || l_itemtype);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_APPRV_SUPPLIER_BODY', 'l_item_key ' || l_itemkey);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_APPRV_SUPPLIER_BODY', 'l_supplier_reg_id ' || l_supplier_reg_id);
  END IF;

   l_enterprisename := wf_engine.GetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME');

   l_username := wf_engine.GetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'USERNAME');

   l_password := wf_engine.GetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'PASSWORD');

   l_url := wf_engine.GetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'URL');

   l_adminemail := wf_engine.GetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ADMIN_EMAIL');



  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_APPRV_SUPPLIER_BODY', 'l_enterprisename ' || l_enterprisename);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_APPRV_SUPPLIER_BODY', 'l_url ' || l_url);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_APPRV_SUPPLIER_BODY', 'l_username ' || l_username);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_APPRV_SUPPLIER_BODY', 'l_password ' || l_password);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_APPRV_SUPPLIER_BODY', 'l_adminemail ' || l_adminemail);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_APPRV_SUPPLIER_BODY', 'display_type ' || display_type);
  END IF;

  IF display_type = 'text/html' THEN
      l_disp_type:= display_type;
        POS_SPM_WF_PKG1.BUYER_NOTE(To_char(l_supplier_reg_id),l_disp_type,l_note,l_disp_type);
        fnd_message.set_name('POS','POS_APPROVE_SUPPLIER_HTML_BODY');
        fnd_message.set_token('ENTERPRISE_NAME',l_enterprisename);
        fnd_message.set_token('URL',l_url);
        fnd_message.set_token('USERNAME',l_username);
        fnd_message.set_token('PASSWORD',l_password);
        fnd_message.set_token('ADMIN_EMAIL',l_adminemail);
        fnd_message.set_token('BUYER_NOTE',l_note);

        --
        -- Begin Supplier Hub: OSN Integration
        -- See comments in FUNCTION get_osn_message
        --
        fnd_message.set_token('OSN_MESSAGE', to_html(get_osn_message));
        --
        -- End Supplier Hub: OSN Integration
        --

        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
        l_disp_type:= display_type;
        POS_SPM_WF_PKG1.BUYER_NOTE(To_char(l_supplier_reg_id),l_disp_type,l_note,l_disp_type);
        fnd_message.set_name('POS','POS_APPROVE_SUPPLIER_TEXT_BODY');
        fnd_message.set_token('ENTERPRISE_NAME',l_enterprisename);
        fnd_message.set_token('URL',l_url);
        fnd_message.set_token('USERNAME',l_username);
        fnd_message.set_token('PASSWORD',l_password);
        fnd_message.set_token('ADMIN_EMAIL',l_adminemail);
        fnd_message.set_token('BUYER_NOTE',l_note);

        --
        -- Begin Supplier Hub: OSN Integration
        -- See comments in FUNCTION get_osn_message
        --
        fnd_message.set_token('OSN_MESSAGE', get_osn_message);
        --
        -- End Supplier Hub: OSN Integration
        --

        l_document :=   l_document || NL || NL || fnd_message.get;
   	    WF_NOTIFICATION.WriteToClob(document, l_document);

  END IF;

EXCEPTION
WHEN OTHERS THEN
    RAISE;
END GET_APPRV_SUPPLIER_BODY;

FUNCTION GET_SUPP_REOPEN_NOTIF_SUBJECT(p_enterprise_name IN VARCHAR2)
RETURN VARCHAR2  IS
l_document VARCHAR2(32000);

BEGIN

    fnd_message.set_name('POS','POS_SUPPLIER_REOPEN_SUBJECT');
    fnd_message.set_token('ENTERPRISE_NAME', p_enterprise_name);
    l_document :=  fnd_message.get;
    RETURN l_document;
END GET_SUPP_REOPEN_NOTIF_SUBJECT;


PROCEDURE GET_SUPP_REOPEN_NOTIF_BODY
  (
    document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  )
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_url           VARCHAR2(3000) := '';
l_supplier_reg_id NUMBER;
l_disp_type          VARCHAR2(20) := 'text/plain';
l_itemtype wf_items.item_type%TYPE;
l_itemkey  wf_items.item_key%TYPE;


BEGIN

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_REOPEN_NOTIF_BODY', 'document_id ' || document_id);
  END IF;

  l_itemtype := substr(document_id, 1, instr(document_id, ':') - 1);
  l_itemkey := substr(document_id, instr(document_id, ':') + 1, (instr(document_id, '#') - instr(document_id, ':'))-1 );
  l_supplier_reg_id := substr(document_id, instr(document_id, '#') + 1, length(document_id));

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_REOPEN_NOTIF_BODY', 'l_item_type ' || l_itemtype);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_REOPEN_NOTIF_BODY', 'l_item_key ' || l_itemkey);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_REOPEN_NOTIF_BODY', 'l_supplier_reg_id ' || l_supplier_reg_id);
  END IF;

   l_url := wf_engine.GetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'SUPP_REG_STATUS_URL');

  IF display_type = 'text/html' THEN
    l_disp_type:= display_type;
    fnd_message.set_name('POS','POS_SUPPLIER_REOPEN_HTML_BODY');
    fnd_message.set_token('URL',l_url);
    l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
    l_disp_type:= display_type;
    fnd_message.set_name('POS','POS_SUPPLIER_REOPEN_TEXT_BODY');
	  fnd_message.set_token('URL',l_url);
    l_document :=   l_document || NL || NL || fnd_message.get;
 	  WF_NOTIFICATION.WriteToClob(document, l_document);

  END IF;

EXCEPTION
WHEN OTHERS THEN
    RAISE;

END GET_SUPP_REOPEN_NOTIF_BODY;

FUNCTION GET_SUPP_LINK_NOTIF_SUBJECT(p_enterprise_name IN VARCHAR2)
RETURN VARCHAR2  IS
l_document VARCHAR2(32000);

BEGIN

    fnd_message.set_name('POS','POS_SUPPLIER_LINK_SUBJECT');
    fnd_message.set_token('ENTERPRISE_NAME', p_enterprise_name);
    l_document :=  fnd_message.get;
    RETURN l_document;
END GET_SUPP_LINK_NOTIF_SUBJECT;


PROCEDURE GET_SUPP_LINK_NOTIF_BODY
  (
    document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  )
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_url           VARCHAR2(3000) := '';
l_supplier_reg_id NUMBER;
l_disp_type          VARCHAR2(20) := 'text/plain';
l_itemtype wf_items.item_type%TYPE;
l_itemkey  wf_items.item_key%TYPE;


BEGIN

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_LINK_NOTIF_BODY', 'document_id ' || document_id);
  END IF;

  l_itemtype := substr(document_id, 1, instr(document_id, ':') - 1);
  l_itemkey := substr(document_id, instr(document_id, ':') + 1, (instr(document_id, '#') - instr(document_id, ':'))-1 );
  l_supplier_reg_id := substr(document_id, instr(document_id, '#') + 1, length(document_id));

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_LINK_NOTIF_BODY', 'l_item_type ' || l_itemtype);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_LINK_NOTIF_BODY', 'l_item_key ' || l_itemkey);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_LINK_NOTIF_BODY', 'l_supplier_reg_id ' || l_supplier_reg_id);
  END IF;

   l_url := wf_engine.GetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'SUPP_REG_STATUS_URL');

  IF display_type = 'text/html' THEN
    l_disp_type:= display_type;
    fnd_message.set_name('POS','POS_SUPPLIER_LINK_HTML_BODY');
    fnd_message.set_token('URL',l_url);
    l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
    l_disp_type:= display_type;
    fnd_message.set_name('POS','POS_SUPPLIER_LINK_TEXT_BODY');
	  fnd_message.set_token('URL',l_url);
    l_document :=   l_document || NL || NL || fnd_message.get;
 	  WF_NOTIFICATION.WriteToClob(document, l_document);

  END IF;

EXCEPTION
WHEN OTHERS THEN
    RAISE;

END GET_SUPP_LINK_NOTIF_BODY;


FUNCTION GET_SUPP_SAVE_NOTIF_SUBJECT(p_enterprise_name IN VARCHAR2)
RETURN VARCHAR2  IS
l_document VARCHAR2(32000);

BEGIN

    fnd_message.set_name('POS','POS_SUPPLIER_SAVE_SUBJECT');
    fnd_message.set_token('ENTERPRISE_NAME', p_enterprise_name);
    l_document :=  fnd_message.get;
    RETURN l_document;
END GET_SUPP_SAVE_NOTIF_SUBJECT;



PROCEDURE GET_SUPP_SAVE_NOTIF_BODY
  (
    document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  )
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_url           VARCHAR2(3000) := '';
l_supplier_reg_id NUMBER;
l_disp_type          VARCHAR2(20) := 'text/plain';
l_itemtype wf_items.item_type%TYPE;
l_itemkey  wf_items.item_key%TYPE;


BEGIN

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SAVE_NOTIF_BODY', 'document_id ' || document_id);
  END IF;

  l_itemtype := substr(document_id, 1, instr(document_id, ':') - 1);
  l_itemkey := substr(document_id, instr(document_id, ':') + 1, (instr(document_id, '#') - instr(document_id, ':'))-1 );
  l_supplier_reg_id := substr(document_id, instr(document_id, '#') + 1, length(document_id));

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SAVE_NOTIF_BODY', 'l_item_type ' || l_itemtype);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SAVE_NOTIF_BODY', 'l_item_key ' || l_itemkey);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SAVE_NOTIF_BODY', 'l_supplier_reg_id ' || l_supplier_reg_id);
  END IF;

   l_url := wf_engine.GetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'SUPP_REG_STATUS_URL');

  IF display_type = 'text/html' THEN
    l_disp_type:= display_type;
    fnd_message.set_name('POS','POS_SUPPLIER_SAVE_HTML_BODY');
    fnd_message.set_token('URL',l_url);
    l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
    l_disp_type:= display_type;
    fnd_message.set_name('POS','POS_SUPPLIER_SAVE_TEXT_BODY');
	  fnd_message.set_token('URL',l_url);
    l_document :=   l_document || NL || NL || fnd_message.get;
 	  WF_NOTIFICATION.WriteToClob(document, l_document);

  END IF;

EXCEPTION
WHEN OTHERS THEN
    RAISE;

END GET_SUPP_SAVE_NOTIF_BODY;



FUNCTION GET_SUPP_SUBMIT_NOTIF_SUBJECT(p_enterprise_name IN VARCHAR2)
RETURN VARCHAR2  IS
l_document VARCHAR2(32000);

BEGIN
    fnd_message.set_name('POS','POS_SUPPLIER_SUBMIT_SUBJECT');
    fnd_message.set_token('ENTERPRISE_NAME', p_enterprise_name);
    l_document :=  fnd_message.get;
    RETURN l_document;
END GET_SUPP_SUBMIT_NOTIF_SUBJECT;



PROCEDURE GET_SUPP_SUBMIT_NOTIF_BODY
  (
    p_document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  )
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_url           VARCHAR2(3000) := '';
l_supplier_reg_id NUMBER;
l_disp_type          VARCHAR2(20) := 'text/plain';
l_itemtype wf_items.item_type%TYPE;
l_itemkey  wf_items.item_key%TYPE;


BEGIN

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUBMIT_NOTIF_BODY', 'p_document_id ' || p_document_id);
  END IF;

  l_itemtype := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_itemkey := substr(p_document_id, instr(p_document_id, ':') + 1, (instr(p_document_id, '#') - instr(p_document_id, ':'))-1 );
  l_supplier_reg_id := substr(p_document_id, instr(p_document_id, '#') + 1, length(p_document_id));

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUBMIT_NOTIF_BODY', 'l_item_type ' || l_itemtype);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUBMIT_NOTIF_BODY', 'l_item_key ' || l_itemkey);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUBMIT_NOTIF_BODY', 'l_supplier_reg_id ' || l_supplier_reg_id);
  END IF;

  l_url := wf_engine.GetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'SUPP_REG_STATUS_URL');

  IF display_type = 'text/html' THEN
    l_disp_type:= display_type;
    fnd_message.set_name('POS','POS_SUPPLIER_SUBMIT_HTML_BODY');
    fnd_message.set_token('URL',l_url);
    l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
    l_disp_type:= display_type;
    fnd_message.set_name('POS','POS_SUPPLIER_SUBMIT_TEXT_BODY');
	  fnd_message.set_token('URL',l_url);
    l_document :=   l_document || NL || NL || fnd_message.get;
 	  WF_NOTIFICATION.WriteToClob(document, l_document);

  END IF;

EXCEPTION
WHEN OTHERS THEN
    RAISE;

END GET_SUPP_SUBMIT_NOTIF_BODY;


FUNCTION GET_SUPP_REJECT_NOTIF_SUBJECT(p_enterprise_name IN VARCHAR2)
RETURN VARCHAR2  IS
l_document VARCHAR2(32000);

BEGIN
    fnd_message.set_name('POS','POS_SUPPLIER_REJECT_SUBJECT');
    fnd_message.set_token('ENTERPRISE_NAME', p_enterprise_name);
    l_document :=  fnd_message.get;
    RETURN l_document;
END GET_SUPP_REJECT_NOTIF_SUBJECT;



PROCEDURE GET_SUPP_REJECT_NOTIF_BODY
  (
    p_document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  )
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_enterprisename VARCHAR2(1000) := '';
l_supplier_reg_id NUMBER;
l_disp_type          VARCHAR2(20) := 'text/plain';
l_itemtype wf_items.item_type%TYPE;
l_itemkey  wf_items.item_key%TYPE;
l_note          VARCHAR2(32000) := '';


BEGIN

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_REJECT_NOTIF_BODY', 'p_document_id ' || p_document_id);
  END IF;

  l_itemtype := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_itemkey := substr(p_document_id, instr(p_document_id, ':') + 1, (instr(p_document_id, '#') - instr(p_document_id, ':'))-1 );
  l_supplier_reg_id := substr(p_document_id, instr(p_document_id, '#') + 1, length(p_document_id));

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_REJECT_NOTIF_BODY', 'l_item_type ' || l_itemtype);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_REJECT_NOTIF_BODY', 'l_item_key ' || l_itemkey);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_REJECT_NOTIF_BODY', 'l_supplier_reg_id ' || l_supplier_reg_id);
  END IF;

  l_enterprisename := wf_engine.GetItemAttrText (itemtype   => l_itemtype,
                                                 itemkey    => l_itemkey,
                                                 aname      => 'ENTERPRISE_NAME');

  IF display_type = 'text/html' THEN
    l_disp_type:= display_type;
    POS_SPM_WF_PKG1.BUYER_NOTE(To_char(l_supplier_reg_id),l_disp_type,l_note,l_disp_type);
    fnd_message.set_name('POS','POS_SUPPLIER_REJECT_HTML_BODY');
    fnd_message.set_token('ENTERPRISE_NAME',l_enterprisename);
    fnd_message.set_token('BUYER_NOTE',l_note);
    l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
    l_disp_type:= display_type;
    POS_SPM_WF_PKG1.BUYER_NOTE(To_char(l_supplier_reg_id),l_disp_type,l_note,l_disp_type);
    fnd_message.set_name('POS','POS_SUPPLIER_REJECT_TEXT_BODY');
	  fnd_message.set_token('ENTERPRISE_NAME',l_enterprisename);
    fnd_message.set_token('BUYER_NOTE',l_note);
    l_document :=   l_document || NL || NL || fnd_message.get;
 	  WF_NOTIFICATION.WriteToClob(document, l_document);

  END IF;

EXCEPTION
WHEN OTHERS THEN
    RAISE;

END GET_SUPP_REJECT_NOTIF_BODY;


FUNCTION GET_SUPP_RETURN_NOTIF_SUBJECT
RETURN VARCHAR2  IS
l_document VARCHAR2(32000);

BEGIN
    fnd_message.set_name('POS','POS_SUPPLIER_RETURN_SUBJECT');
    l_document :=  fnd_message.get;
    RETURN l_document;
END GET_SUPP_RETURN_NOTIF_SUBJECT;



PROCEDURE GET_SUPP_RETURN_NOTIF_BODY
  (
    p_document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  )
IS

NL              VARCHAR2(1) := fnd_global.newline;
l_document      VARCHAR2(32000) := '';
l_url           VARCHAR2(3000) := '';
l_supplier_reg_id NUMBER;
l_disp_type          VARCHAR2(20) := 'text/plain';
l_itemtype wf_items.item_type%TYPE;
l_itemkey  wf_items.item_key%TYPE;
l_mesg_body          VARCHAR2(32000) := '';
l_adt_mesg_body      VARCHAR2(32000) := '';
l_is_req_reopened    VARCHAR2(1);
l_reopen_mesg        VARCHAR2(4000);

BEGIN

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_RETURN_NOTIF_BODY', 'p_document_id ' || p_document_id);
  END IF;

  l_itemtype := substr(p_document_id, 1, instr(p_document_id, ':') - 1);
  l_itemkey := substr(p_document_id, instr(p_document_id, ':') + 1, (instr(p_document_id, '#') - instr(p_document_id, ':'))-1 );
  l_supplier_reg_id := substr(p_document_id, instr(p_document_id, '#') + 1, length(p_document_id));
  l_disp_type := display_type;

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_RETURN_NOTIF_BODY', 'l_item_type ' || l_itemtype);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_RETURN_NOTIF_BODY', 'l_item_key ' || l_itemkey);
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_RETURN_NOTIF_BODY', 'l_supplier_reg_id ' || l_supplier_reg_id);
  END IF;

  l_url := wf_engine.GetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'URL');
  l_mesg_body := wf_engine.GetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'SUPPMSGBD');

  l_adt_mesg_body := wf_engine.GetItemAttrText (itemtype   => l_itemtype,
                                       itemkey    => l_itemkey,
                                       aname      => 'SUPPADTMSG');

  POS_SUPP_APPR.IS_REOPENED_REQUEST(l_supplier_reg_id, l_is_req_reopened);
  IF(l_is_req_reopened = 'Y') THEN
    l_reopen_mesg := GET_SUPP_REOPEN_MSG(display_type);
    IF display_type = 'text/html' THEN
      POS_SPM_WF_PKG1.BUYER_NOTE(To_char(l_supplier_reg_id),l_disp_type,l_mesg_body,l_disp_type);
      fnd_message.set_name('POS','POS_SUPP_RJ_RETURN_HTML_BODY');
      fnd_message.set_token('URL',l_url);
      fnd_message.set_token('SUPPMSGBD',l_mesg_body);
      fnd_message.set_token('SUPPADTMSG',l_adt_mesg_body);
      fnd_message.set_token('REOPEN_MESG',l_reopen_mesg);
      l_document :=   l_document || NL || NL || fnd_message.get;
   	  WF_NOTIFICATION.WriteToClob(document, l_document);
    ELSE
      POS_SPM_WF_PKG1.BUYER_NOTE(To_char(l_supplier_reg_id),l_disp_type,l_mesg_body,l_disp_type);
      fnd_message.set_name('POS','POS_SUPP_RJ_RETURN_TEXT_BODY');
	    fnd_message.set_token('URL',l_url);
      fnd_message.set_token('SUPPMSGBD',l_mesg_body);
      fnd_message.set_token('SUPPADTMSG',l_adt_mesg_body);
      fnd_message.set_token('REOPEN_MESG',l_reopen_mesg);
      l_document :=   l_document || NL || NL || fnd_message.get;
 	    WF_NOTIFICATION.WriteToClob(document, l_document);
    END IF;
  ELSE
    IF display_type = 'text/html' THEN
      POS_SPM_WF_PKG1.BUYER_NOTE(To_char(l_supplier_reg_id),l_disp_type,l_mesg_body,l_disp_type);
      fnd_message.set_name('POS','POS_SUPPLIER_RETURN_HTML_BODY');
      fnd_message.set_token('URL',l_url);
      fnd_message.set_token('SUPPMSGBD',l_mesg_body);
      fnd_message.set_token('SUPPADTMSG',l_adt_mesg_body);
      l_document :=   l_document || NL || NL || fnd_message.get;
   	WF_NOTIFICATION.WriteToClob(document, l_document);

  ELSE
    POS_SPM_WF_PKG1.BUYER_NOTE(To_char(l_supplier_reg_id),l_disp_type,l_mesg_body,l_disp_type);
    fnd_message.set_name('POS','POS_SUPPLIER_RETURN_TEXT_BODY');
	  fnd_message.set_token('URL',l_url);
    fnd_message.set_token('SUPPMSGBD',l_mesg_body);
    fnd_message.set_token('SUPPADTMSG',l_adt_mesg_body);
    l_document :=   l_document || NL || NL || fnd_message.get;
 	  WF_NOTIFICATION.WriteToClob(document, l_document);

    END IF;
  END IF;

EXCEPTION
WHEN OTHERS THEN
    RAISE;

END GET_SUPP_RETURN_NOTIF_BODY;

FUNCTION GET_SUPP_REOPEN_MSG
(
  display_type IN VARCHAR2
)
RETURN VARCHAR2

IS

l_document VARCHAR2(4000);
NL VARCHAR2(1) := fnd_global.newline;
l_enterprise_name hz_parties.party_name%TYPE;

BEGIN

  IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    fnd_log.string(fnd_log.level_statement, g_log_module || '.GET_SUPP_REOPEN_MSG', 'display_type ' || display_type);
  END IF;

  get_enterprise_name(l_enterprise_name);

  IF display_type = 'text/html' THEN
    fnd_message.set_name('POS','POS_SUPP_REOPEN_HTML_BODY');
    fnd_message.set_token('ENTERPRISE_NAME', l_enterprise_name);
    l_document :=   l_document || NL || NL || fnd_message.get;

  ELSE
    fnd_message.set_name('POS','POS_SUPPLIER_REOPEN_TEXT_BODY');
    fnd_message.set_token('ENTERPRISE_NAME', l_enterprise_name);
    l_document :=   l_document || NL || NL || fnd_message.get;

  END IF;

  RETURN l_document;

EXCEPTION
WHEN OTHERS THEN
    RAISE;

END GET_SUPP_REOPEN_MSG;

PROCEDURE notify_supp_appr_no_user_acc
  (p_supplier_reg_id IN  NUMBER,
   x_itemtype        OUT nocopy VARCHAR2,
   x_itemkey         OUT nocopy VARCHAR2,
   x_receiver        OUT nocopy VARCHAR2
   )
  IS
     l_itemtype wf_items.item_type%TYPE;
     l_itemkey  wf_items.item_key%TYPE;
     l_process  wf_process_activities.process_name%TYPE;

     CURSOR l_cur IS
	SELECT email_address, first_name, last_name
	  FROM pos_contact_requests
	 WHERE mapping_id IN (SELECT mapping_id FROM pos_supplier_mappings WHERE supplier_reg_id = p_supplier_reg_id)
           AND do_not_delete = 'Y';

     l_rec l_cur%ROWTYPE;
     l_receiver wf_roles.name%TYPE;
     l_enterprise_name hz_parties.party_name%TYPE;
     l_display_name wf_roles.display_name%TYPE;
     l_step  NUMBER;

BEGIN
   l_step := 0;
   get_enterprise_name(l_enterprise_name);

   l_step := 1;
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      RAISE no_data_found;
   END IF;
   CLOSE l_cur;

   l_step := 2;
   l_display_name := l_rec.first_name || ' ' || l_rec.last_name;
   l_process := 'PSUPPLIER_APPROVED_NO_USER_ACC';
   get_adhoc_role_name(l_process, l_receiver);

   l_step := 3;
   wf_directory.CreateAdHocUser
     (name            => l_receiver,
      display_name    => l_display_name,
      email_address   => l_rec.email_address
      );

   l_step := 4;
   get_wf_item_type (l_itemtype);

   l_step := 7;
   get_wf_item_key (l_process,
                    To_char(p_supplier_reg_id),
                    l_itemkey);

   l_step := 8;
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   l_step := 9;
   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'RECEIVER',
                              avalue     => l_receiver);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ENTERPRISE_NAME',
                              avalue     => l_enterprise_name);

   wf_engine.SetItemAttrText (itemtype   => l_itemtype,
                              itemkey    => l_itemkey,
                              aname      => 'ADMIN_EMAIL',
                              avalue     => get_admin_email);

   l_step := 10;
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );

   l_step := 11;
   x_itemtype := l_itemtype;
   x_itemkey  := l_itemkey;
   x_receiver := l_receiver;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(g_package_name,'notify_supp_appr_no_user_acc',l_itemtype,l_itemkey);
      raise_application_error(-20050, 'Failure at step ' || l_step, true);
END notify_supp_appr_no_user_acc;

END pos_spm_wf_pkg1;

/
