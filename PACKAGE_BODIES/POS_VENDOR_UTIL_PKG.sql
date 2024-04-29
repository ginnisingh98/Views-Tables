--------------------------------------------------------
--  DDL for Package Body POS_VENDOR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_VENDOR_UTIL_PKG" as
-- $Header: POSVENDB.pls 120.7.12010000.2 2014/01/08 02:51:31 atjen ship $

-- This procedure will merge the related parties for
-- given vendor_id 's
-- On error typically exceptions is raised keeping the error
-- stack information.

-- In Release 12, POS is no longer maintaining the TCA links
-- so all we have to do is maintain the registration details

PROCEDURE merge_vendor_parties
  ( p_vendor_id     IN NUMBER,       -- new VENDOR_ID
    p_dup_vendor_id IN NUMBER        -- old / disabled VENDOR_ID
    --,p_vendor_site_id IN NUMBER,   -- new VENDOR_SITE_ID
    --p_dup_vendor_site_id IN NUMBER -- old / disabled VENDOR_SITE_ID
    )
IS
BEGIN
   -- merge the POS registration records
   merge_registration_details(p_vendor_id, p_dup_vendor_id);
END merge_vendor_parties;

-- This procedure will update the registration details tables when a
-- party merge occurs
-- This is called internally from merge_vendor_parties
PROCEDURE merge_registration_details
  (p_vendor_id     IN NUMBER,      -- new VENDOR_ID
   p_dup_vendor_id IN NUMBER       -- old / disabled VENDOR_ID
)
IS
   x_exception_msg varchar2(500);
   l_new_vendor_name varchar2(240);
BEGIN
   -- Correct the name first and then correct the ID
   select vendor_name
     into l_new_vendor_name
     from ap_suppliers
     where vendor_id = p_vendor_id;

   -- We are not comparing the supplier name as this information
   -- might not be reliable ( could have different spelling).
   -- But the supplier number must be
   -- reliable.
   update fnd_registration_details
      set field_value_string = l_new_vendor_name
        , last_updated_by = 1, last_update_date = sysdate
    where application_id = 177
      and field_name = 'Supplier Name'
      and registration_id in
          (select fr.registration_id from fnd_registrations fr,
           fnd_registration_details frd
           where registration_status IN ('INVITED', 'REGISTERED')
           and frd.registration_id = fr.registration_id
           and frd.field_name = 'Supplier Number'
           and frd.field_value_number = p_dup_vendor_id
           and frd.application_id = 177
          );

   update fnd_registration_details
      set field_value_number = p_vendor_id
        , last_update_date = sysdate, last_updated_by = 1
    where field_value_number = p_dup_vendor_id
      and application_id = 177
      and field_name = 'Supplier Number'
      and registration_id in
          (select registration_id from fnd_registrations
           where registration_status IN ('INVITED', 'REGISTERED')
           );
EXCEPTION
   WHEN OTHERS THEN
      x_exception_msg := 'POSVENDB.pls: Merging vendor data in Fnd_registration_details table:\n Error :'
        ||x_exception_msg;
      raise_application_error(-20001, x_exception_msg, true);
END merge_registration_details;

FUNCTION get_party_id_for_vendor(p_vendor_id IN NUMBER)
  RETURN NUMBER IS
     l_party_id NUMBER;
     CURSOR l_cur IS
        SELECT party_id
          FROM ap_suppliers
         WHERE vendor_id = p_vendor_id;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_party_id;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      raise_application_error
        (-20001
         , 'pos_vendor_util_pkg.get_party_id_for_vendor error: Invalid vendor_id '
         || p_vendor_id
         , true);
   END IF;

   CLOSE l_cur;
   RETURN l_party_id;
END get_party_id_for_vendor;

-- Get the vendor id (as in AP_SUPPLIERS table ) for a given
-- user name ( as in FND_USER table)
FUNCTION get_po_vendor_id_for_user(p_username IN VARCHAR2)
  RETURN NUMBER
  IS
     l_vendor_id NUMBER;
     CURSOR l_cur IS
        SELECT vendor_id
          FROM pos_supplier_users_v
         WHERE user_name = p_username;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_vendor_id;
   CLOSE l_cur;
   RETURN l_vendor_id;
END get_po_vendor_id_for_user;

FUNCTION get_vendor_party_id_for_user(p_username IN VARCHAR2)
  RETURN NUMBER
  IS
     l_party_id NUMBER;
     CURSOR l_cur IS
        SELECT vendor_party_id
          FROM pos_supplier_users_v
         WHERE user_name = p_username;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_party_id;
   CLOSE l_cur;
   RETURN l_party_id;
END get_vendor_party_id_for_user;

-- validate_user_setup
-- Purpose: to make sure the user has the correct vendor, site and contact setup
-- for a single supplier hierarchy
-- Return Value: returns value 'Y' or 'N' indicating respectively whether user
-- set-up is valid or not

FUNCTION validate_user_setup (p_user_id in number) RETURN VARCHAR2 IS

   l_root_vendor_id           NUMBER;
   l_number                   NUMBER;

   CURSOR l_vendor_cur IS
      SELECT akw.number_value
        FROM ak_web_user_sec_attr_values akw, ap_suppliers pv
       WHERE akw.web_user_id = p_user_id
         AND akw.attribute_code = 'ICX_SUPPLIER_ORG_ID'
         AND akw.attribute_application_id = 177
         AND akw.number_value = pv.vendor_id
         AND ((pv.parent_vendor_id is null) OR
              (pv.parent_vendor_id not in
               (SELECT number_value
                  FROM ak_web_user_sec_attr_values
                 WHERE web_user_id = p_user_id
                   AND attribute_code = 'ICX_SUPPLIER_ORG_ID'
                   AND attribute_application_id = 177
                )
               )
              )
	 AND ROWNUM < 3;

   CURSOR l_invalid_site_cur IS
      SELECT akw.number_value
        FROM ak_web_user_sec_attr_values akw, ap_supplier_sites_all pvs
       WHERE akw.web_user_id = p_user_id
         AND akw.attribute_code = 'ICX_SUPPLIER_SITE_ID'
         AND akw.attribute_application_id = 177
         AND akw.number_value = pvs.vendor_site_id
         AND pvs.vendor_id NOT IN
             (select vendor_id from ap_suppliers
              start with vendor_id = l_root_vendor_id
              connect by prior vendor_id = parent_vendor_id
              )
         AND ROWNUM < 2;

   CURSOR l_invalid_contact_cur IS
      SELECT akw.number_value
        FROM ak_web_user_sec_attr_values akw, po_vendor_contacts pvc
       WHERE akw.web_user_id = p_user_id
         AND akw.attribute_code = 'ICX_SUPPLIER_CONTACT_ID'
         AND akw.attribute_application_id = 177
         AND akw.number_value = pvc.vendor_contact_id
         AND pvc.vendor_site_id not in
             (SELECT vendor_site_id
                FROM ap_supplier_sites_all
               WHERE vendor_id in
                     (select vendor_id
                        from ap_suppliers
                        start with vendor_id = l_root_vendor_id
                      connect by prior vendor_id = parent_vendor_id
                      )
              )
         AND ROWNUM < 2;
BEGIN
   -- there should be exactly one vendor with no parent_vendor in the list
   OPEN l_vendor_cur;
   FETCH l_vendor_cur INTO l_root_vendor_id;
   IF l_vendor_cur%notfound THEN
      CLOSE l_vendor_cur;
      RETURN 'N';
   END IF;

   FETCH l_vendor_cur INTO l_number;
   IF l_vendor_cur%found THEN
      CLOSE l_vendor_cur;
      -- found two then it is wrong
      RETURN 'N';
   END IF;
   CLOSE l_vendor_cur;

   -- do the check for vendor_sites
   -- to make sure all sites listed for the user belong to the parent vendor hierarchy

   OPEN l_invalid_site_cur;
   FETCH l_invalid_site_cur INTO l_number;
   IF l_invalid_site_cur%found THEN
      CLOSE l_invalid_site_cur;
      RETURN 'N';
   END IF;
   CLOSE l_invalid_site_cur;

   -- do the check for vendor_contacts
   -- to make sure all contacts listed for the user belong to the parent vendor hierarchy

   OPEN l_invalid_contact_cur;
   FETCH l_invalid_contact_cur INTO l_number;
   IF l_invalid_contact_cur%found THEN
      CLOSE l_invalid_contact_cur;
      RETURN 'N';
   END IF;
   CLOSE l_invalid_contact_cur;

   RETURN 'Y';

END validate_user_setup;

-- Return Y if p_vendor_name already exists in ap_suppliers
-- Note: this api does case insensitive check
FUNCTION vendor_name_exist (p_vendor_name IN VARCHAR2) RETURN VARCHAR2
  IS
     CURSOR l_cur IS
	SELECT 1
	  FROM ap_suppliers
         WHERE Upper(vendor_name) = Upper(p_vendor_name);
     l_number NUMBER;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_number;
   IF l_cur%found THEN
      CLOSE l_cur;
      RETURN 'Y';
    ELSE
      CLOSE l_cur;
      RETURN 'N';
   END IF;
END vendor_name_exist;

PROCEDURE get_le_by_liability_acct
  (p_accts_pay_ccid    IN  NUMBER,
   p_operating_unit_id IN  NUMBER,
   x_le_id             OUT nocopy NUMBER,
   x_le_name           OUT nocopy VARCHAR2
   )
  IS
   l_return_status VARCHAR2(1);
   l_msg_data      VARCHAR2(3000);
   l_ptop_le_info  xle_businessinfo_grp.ptop_le_rec;
BEGIN
   IF p_accts_pay_ccid IS NULL OR p_operating_unit_id IS NULL THEN
      x_le_id := NULL;
      x_le_name := NULL;
      RETURN;
   END IF;

   xle_businessinfo_grp.get_purchasetopay_info
     (
      x_return_status       => l_return_status,
      x_msg_data            => l_msg_data,
      P_registration_code   => NULL,
      P_registration_number => NULL,
      P_location_id         => NULL,
      p_code_combination_id => p_accts_pay_ccid,
      P_operating_unit_id   => p_operating_unit_id,
      x_ptop_Le_info        => l_ptop_le_info
      );
   IF l_return_status IS NULL OR
      l_return_status <> fnd_api.g_ret_sts_success THEN
      x_le_id := NULL;
      x_le_name := NULL;
      RETURN;
   END IF;

   x_le_id := l_ptop_le_info.legal_entity_id;
   x_le_name := l_ptop_le_info.name;

EXCEPTION
   WHEN OTHERS THEN
      x_le_id := NULL;
      x_le_name := NULL;

END get_le_by_liability_acct;

-- Return legal entity id based on the liability account
-- (accts_pay_ccid), and the operating unit id
-- of a vendor site; return null if error
FUNCTION get_le_id_by_liability_acct
  (p_accts_pay_ccid     IN NUMBER,
   p_operating_unit_id  IN NUMBER
   )
  RETURN NUMBER
  IS
     l_le_id NUMBER;
     l_le_name xle_entity_profiles.NAME%TYPE;
BEGIN
   get_le_by_liability_acct
     (p_accts_pay_ccid     => p_accts_pay_ccid,
      p_operating_unit_id  => p_operating_unit_id,
      x_le_id              => l_le_id,
      x_le_name            => l_le_name
      );
   RETURN l_le_id;
END get_le_id_by_liability_acct;

-- Return legal entity id based on the liability account
-- (accts_pay_ccid), and the operating unit id
-- of a vendor site; return null if error
FUNCTION get_le_name_by_liability_acct
  (p_accts_pay_ccid     IN NUMBER,
   p_operating_unit_id  IN NUMBER
   )
  RETURN VARCHAR2
  IS
     l_le_id NUMBER;
     l_le_name xle_entity_profiles.NAME%TYPE;
BEGIN
   get_le_by_liability_acct
     (p_accts_pay_ccid     => p_accts_pay_ccid,
      p_operating_unit_id  => p_operating_unit_id,
      x_le_id              => l_le_id,
      x_le_name            => l_le_name
      );
   RETURN l_le_name;
END get_le_name_by_liability_acct;

-- Bug 17068732
-- Supplier Profile Business Event
PROCEDURE Raise_Supplier_Event
(   p_vendor_id        IN         NUMBER,
    p_party_id         IN         NUMBER,
    p_transaction_type IN         VARCHAR2,
    p_entity_name      IN         VARCHAR2,
    p_entity_key       IN         VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2
)
IS

  l_event_name  VARCHAR(240) := 'oracle.apps.pos.supplier.profile';
  l_event_key   VARCHAR(240);
  l_param_list  wf_parameter_list_t;

BEGIN

  SAVEPOINT Raise_Supplier_Event_PUB;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT pos_supplier_event_s.NEXTVAL
  INTO l_event_key
  FROM dual;

  l_param_list := wf_parameter_list_t
                  (   wf_parameter_t('VENDOR_ID', p_vendor_id),
                      wf_parameter_t('PARTY_ID', p_party_id),
                      wf_parameter_t('TRANSACTION_TYPE', p_transaction_type),
                      wf_parameter_t('ENTITY_NAME', p_entity_name),
                      wf_parameter_t('ENTITY_KEY', p_entity_key)
                  );

  wf_event.raise(p_event_name => l_event_name,
                 p_event_key  => l_event_key,
                 p_parameters => l_param_list);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := SQLERRM;
    ROLLBACK TO Raise_Supplier_Event_PUB;

END Raise_Supplier_Event;

END POS_VENDOR_UTIL_PKG;

/
