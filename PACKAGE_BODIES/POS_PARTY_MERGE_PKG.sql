--------------------------------------------------------
--  DDL for Package Body POS_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_PARTY_MERGE_PKG" AS
/*$Header: POSPTYMB.pls 120.7.12010000.2 2014/01/21 21:42:38 dalu ship $ */

g_log_module CONSTANT VARCHAR2(30) := 'POS.PLS.POS_PARTY_MERGE_PKG.';

-- Function check_sdh_profile_option
-- Added for Bug 17068732
FUNCTION check_sdh_profile_option RETURN VARCHAR2
 IS
 l_sdh_profile_option	fnd_profile_option_values.profile_option_value%type;
 BEGIN
   select opv.profile_option_value
   into   l_sdh_profile_option
   from fnd_profile_option_values opv, fnd_profile_options op
   where op.profile_option_id = opv.profile_option_id
   and op.profile_option_name = 'POS_SM_SDH_CONFIG';

 return l_sdh_profile_option;
 EXCEPTION
    WHEN OTHERS THEN
    	RETURN 'ERROR';
END;

FUNCTION is_enterprise_party (p_party_id IN NUMBER) RETURN BOOLEAN
  IS PRAGMA AUTONOMOUS_TRANSACTION;
     CURSOR l_cur IS
        SELECT 1
          FROM hz_code_assignments
          WHERE owner_table_name = 'HZ_PARTIES'
          AND owner_table_id = p_party_id
          AND class_category = 'POS_PARTICIPANT_TYPE'
          AND class_code     = 'ENTERPRISE'
          AND status = 'A'
          AND ROWNUM < 2;

     l_number NUMBER;
     l_found BOOLEAN;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO l_number;
   l_found := l_cur%found;
   CLOSE l_cur;
   RETURN l_found;

END is_enterprise_party;

FUNCTION has_pending_change (p_party_id IN NUMBER) RETURN BOOLEAN
  IS PRAGMA AUTONOMOUS_TRANSACTION;

    l_change        BOOLEAN;

    CURSOR l_address IS
        SELECT 1
        FROM pos_address_requests par, pos_supplier_mappings psm
        WHERE psm.party_id = p_party_id
        AND psm.mapping_id = par.mapping_id
        AND par.request_status = 'PENDING';

    CURSOR l_bus_class IS
        SELECT 1
        FROM pos_bus_class_reqs pbcr, pos_supplier_mappings psm
        WHERE psm.party_id = p_party_id
        AND psm.mapping_id = pbcr.mapping_id
        AND pbcr.request_status = 'PENDING';

    CURSOR l_contacts IS
        SELECT 1
        FROM pos_contact_requests pcr, pos_supplier_mappings psm
        WHERE psm.party_id = p_party_id
        AND psm.mapping_id = pcr.mapping_id
        AND pcr.request_status = 'PENDING';

    CURSOR l_cont_addr IS
        SELECT 1
        FROM pos_cont_addr_requests pcar, pos_supplier_mappings psm
        WHERE psm.party_id = p_party_id
        AND psm.mapping_id = pcar.mapping_id
        AND pcar.request_status = 'PENDING';

    CURSOR l_product_service IS
        SELECT 1
        FROM pos_product_service_requests ppsr, pos_supplier_mappings psm
        WHERE psm.party_id = p_party_id
        AND psm.mapping_id = ppsr.mapping_id
        AND ppsr.request_status = 'PENDING';

    CURSOR l_acnt_cur IS

        SELECT 1
        from POS_ACNT_GEN_REQ req, IBY_TEMP_EXT_BANK_ACCTS temp, POS_SUPPLIER_MAPPINGS pmap
        where req.mapping_id = pmap.mapping_id
        and pmap.party_id = p_party_id
        and temp.status in ('CORRECTED', 'NEW', 'IN_VERIFICATION', 'CHANGE_PENDING')
        and req.temp_ext_bank_acct_id = temp.temp_ext_bank_acct_id
        and rownum = 1

        UNION

        select 1
        from pos_acnt_addr_req req, pos_supplier_mappings pmap, hz_party_sites hps
        where req.request_status = 'PENDING'
        and req.request_type = 'ADDRESS'
        and req.mapping_id = pmap.mapping_id
        and hps.party_site_id = req.party_site_id
        and hps.status = 'A'
        and pmap.party_id = p_party_id
        and rownum = 1

        UNION

        select 1
        from pos_acnt_addr_req req, pos_supplier_mappings pmap
        where req.request_status = 'PENDING'
        and req.request_type = 'SUPPLIER'
        and req.mapping_id = pmap.mapping_id
        and req.party_site_id is null
        and pmap.party_id = p_party_id
        and rownum = 1;

    l_number NUMBER;  -- dummy variable for cursors
    l_found BOOLEAN;

BEGIN

    OPEN l_address;
    FETCH l_address INTO l_number;
    l_found:= l_address%found;
    CLOSE l_address;

    IF (l_found) THEN
      RETURN l_found;
    END IF;

    OPEN l_bus_class;
    FETCH l_bus_class INTO l_number;
    l_found:= l_bus_class%found;
    CLOSE l_bus_class;

    IF (l_found) THEN
        RETURN l_found;
    END IF;

    OPEN l_contacts;
    FETCH l_contacts INTO l_number;
    l_found := l_contacts%found;
    CLOSE l_contacts;

    IF (l_found) THEN
        RETURN l_found;
    END IF;

    OPEN l_cont_addr;
    FETCH l_cont_addr INTO l_number;
    l_found := l_cont_addr%found;
    CLOSE l_cont_addr;

    IF (l_found) THEN
        RETURN l_found;
    END IF;

    OPEN l_acnt_cur;
    FETCH l_acnt_cur INTO l_number;
    l_found := l_acnt_cur%found;
    CLOSE l_acnt_cur;

    IF (l_found) THEN
        RETURN l_found;
    END IF;

    OPEN l_product_service;
    FETCH l_product_service INTO l_number;
    l_found := l_product_service%found;
    CLOSE l_product_service;

    RETURN l_found;

END has_pending_change;

PROCEDURE get_party_info
  (p_party_id   IN  NUMBER,
   x_found      OUT nocopy BOOLEAN,
   x_party_type OUT nocopy VARCHAR2,
   x_party_name OUT nocopy VARCHAR2)
  IS
     CURSOR l_cur IS
        SELECT party_type, party_name
          FROM hz_parties
          WHERE party_id = p_party_id;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO x_party_type, x_party_name;
   IF l_cur%found THEN
        CLOSE l_cur;
        x_found := TRUE;
        RETURN;
    ELSE
      CLOSE l_cur;
      x_found := FALSE;
      x_party_type := NULL;
      x_party_name := NULL;
      RETURN;
   END IF;
END get_party_info;

PROCEDURE check_party_for_veto
  (p_party_id      IN  NUMBER,
   p_is_from_party IN  VARCHAR2,
   x_return_status OUT nocopy VARCHAR2)
  IS
     l_party_type hz_parties.party_type%TYPE;
     l_party_name hz_parties.party_name%TYPE;
     l_found      BOOLEAN;
BEGIN
   get_party_info(p_party_id, l_found, l_party_type, l_party_name);

   IF l_found = FALSE THEN
      fnd_message.set_name('POS','POS_PTYM_INVALID_PARTY_ID');
      fnd_message.set_token('PARTY_ID', p_party_id);
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;
   END IF;

   -- check parties for pending changes; if pending, fail merge
   IF (p_is_from_party = 'Y' AND has_pending_change(p_party_id)) THEN
        fnd_message.set_name('POS', 'POS_PENDING_CHANGE');
        fnd_message.set_token('PARTY_NAME', l_party_name);
        fnd_msg_pub.ADD;
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
   END IF;

   IF l_party_type = 'ORGANIZATION' THEN

       IF is_enterprise_party(p_party_id) THEN

         fnd_message.set_name('POS','POS_PTYM_IS_ENTERPRISE');
         fnd_message.set_token('PARTY_NAME', l_party_name);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;

       ELSE

         x_return_status := fnd_api.g_ret_sts_success;
       RETURN;

      END IF;

    ELSE
      -- party type is not ORGANIZATION
      x_return_status := fnd_api.g_ret_sts_success;
      RETURN;

   END IF;

END check_party_for_veto;

PROCEDURE update_supplier_mapping(
    p_old_party_id     IN NUMBER,
    p_new_party_id     IN NUMBER,
    x_return_status    IN OUT nocopy VARCHAR2
    )
IS

BEGIN

   UPDATE pos_supplier_mappings
      SET party_id = p_new_party_id,
          last_updated_by = FND_GLOBAL.user_id,
          last_update_date = SYSDATE,
          last_update_login = FND_GLOBAL.login_id
    WHERE mapping_id IN
          (SELECT mapping_id
	     FROM pos_supplier_mappings
            WHERE party_id = p_old_party_id
	   );

   x_return_status := fnd_api.g_ret_sts_success;

END update_supplier_mapping;

-- Procedure raise business event
-- Added for Bug 17068732
PROCEDURE raise_business_event(
    p_from_party_id     IN NUMBER,
    p_to_party_id       IN NUMBER,
    p_batch_id          IN VARCHAR2,
    x_return_status     IN OUT nocopy VARCHAR2
    )
IS
    l_module fnd_log_messages.module%TYPE;

    l_from_vendor_id NUMBER;
    l_to_vendor_id   NUMBER;
    l_event_status VARCHAR2(40);
    l_event_err_msg VARCHAR2(2000);

    CURSOR l_vendor_cur(p_party_id NUMBER) IS
        SELECT vendor_id
        FROM ap_suppliers
        WHERE party_id = p_party_id;
BEGIN
    l_module := g_log_module || 'RAISE_BUSINESS_EVENT';

    OPEN l_vendor_cur(p_from_party_id);
      FETCH l_vendor_cur INTO l_from_vendor_id;
      IF l_vendor_cur%notfound THEN
         l_from_vendor_id := -1;
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string(fnd_log.level_procedure, l_module, 'Supplier not found; use -1');
         END IF;
      END IF;
    CLOSE l_vendor_cur;

    OPEN l_vendor_cur(p_to_party_id);
      FETCH l_vendor_cur INTO l_to_vendor_id;
      IF l_vendor_cur%notfound THEN
         l_to_vendor_id := -1;
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string(fnd_log.level_procedure, l_module, 'Supplier for master record not found; use -1');
         END IF;
      END IF;
    CLOSE l_vendor_cur;

   POS_VENDOR_UTIL_PKG.RAISE_SUPPLIER_EVENT(p_vendor_id => l_from_vendor_id,
                                            p_party_id  => p_from_party_id,
                                            p_transaction_type => 'UPDATE',
                                            p_entity_name => 'MERGE_SUPPLIER',
                                            p_entity_key => p_batch_id,
                                            x_return_status => l_event_status,
                                            x_msg_data => l_event_err_msg);
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string(fnd_log.level_procedure, l_module, 'Event Raised for Supplier, party_id = ' || p_from_party_id ||
                                       ' Batch id = ' || p_batch_id ||
                                       ' Status: ' || l_event_status ||
                                       ' Message: ' || l_event_err_msg);
   END IF;
   x_return_status := l_event_status;

   POS_VENDOR_UTIL_PKG.RAISE_SUPPLIER_EVENT(p_vendor_id => l_to_vendor_id,
                                            p_party_id  => p_to_party_id,
                                            p_transaction_type => 'UPDATE',
                                            p_entity_name => 'MERGE_SUPPLIER',
                                            p_entity_key => p_batch_id,
                                            x_return_status => l_event_status,
                                            x_msg_data => l_event_err_msg);
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string(fnd_log.level_procedure, l_module, 'Event Raised for Master Supplier, party_id = ' || p_to_party_id ||
                                       ' Batch id = ' || p_batch_id ||
                                       ' Status: ' || l_event_status ||
                                       ' Message: ' || l_event_err_msg);
   END IF;

   IF x_return_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
       x_return_status := l_event_status;
   END IF;
 EXCEPTION
   WHEN OTHERS THEN
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_procedure, g_log_module || '.' || 'raise_business_event' , 'Unexpected error when raising business event');
   END IF;

END raise_business_event;

-- public method called by party merge program
PROCEDURE party_merge_routine
  (p_entity_name        IN     VARCHAR2,
   p_from_id            IN     NUMBER,
   p_to_id              IN OUT nocopy NUMBER,
   p_from_fk_id         IN     NUMBER,
   p_to_fk_id           IN     NUMBER,
   p_parent_entity_name IN     VARCHAR2,
   p_batch_id           IN     VARCHAR2,
   p_batch_party_id     IN     VARCHAR2,
   x_return_status      IN OUT nocopy VARCHAR2
   )
  IS
     l_sdh_profile fnd_profile_option_values.profile_option_value%type;  -- Bug 17068732

     l_from_party_id NUMBER;
     l_to_party_id   NUMBER;

     CURSOR l_party_id_cur(p_party_site_id NUMBER) IS
        SELECT party_id
          FROM hz_party_sites
          WHERE party_site_id = p_party_site_id;

     l_return_status VARCHAR2(2);
     l_module fnd_log_messages.module%TYPE;
     l_invalid_param VARCHAR2(30);

     CURSOR l_party_site_cur(p_party_site_id NUMBER) IS
        SELECT party_id
          FROM hz_party_sites
          WHERE party_site_id = p_party_site_id;

     CURSOR l_party_cur(p_party_id NUMBER) IS
        SELECT party_id
          FROM hz_parties
          WHERE party_id = p_party_id;
BEGIN

   l_module := g_log_module || 'PARTY_MERGE_ROUTINE';

   IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_procedure, l_module, 'p_parent_entity_name ' || p_parent_entity_name);

      IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_procedure, l_module, 'p_entity_name ' || p_entity_name);
      END IF;


      IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_procedure, l_module, 'p_from_fk_id ' || p_from_fk_id);
      END IF;


      IF ( fnd_log.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_procedure, l_module, 'p_to_fk_id ' || p_to_fk_id);
      END IF;

   END IF;

   -- make sure critical input parameters are not null
   IF p_parent_entity_name IS NULL OR p_from_fk_id IS NULL OR p_to_fk_id IS NULL THEN

      IF p_parent_entity_name IS NULL THEN
         l_invalid_param := 'p_parent_entity_name';
       ELSIF p_from_fk_id IS NULL THEN
         l_invalid_param := 'p_from_fk_id';
       ELSE
         l_invalid_param := 'p_to_fk_id';
      END IF;

      fnd_message.set_name('POS','POS_PTYM_NULL_PARAM');
      fnd_message.set_token('INPUT_PARAMETER',l_invalid_param);
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;

   END IF;

   IF p_parent_entity_name NOT IN ('HZ_PARTIES', 'HZ_PARTY_SITES') THEN
      fnd_message.set_name('POS','POS_PTYM_BAD_PARENT_ENTITY');
      fnd_message.set_token('PARENT_ENTITY_NAME', p_parent_entity_name);
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      RETURN;
   END IF;

   -- validate p_from_fk_id and p_to_fk_id
   IF p_parent_entity_name = 'HZ_PARTIES' THEN

      IF p_from_fk_id IS NULL THEN
         fnd_message.set_name('POS','POS_PTYM_BAD_PARTY_ID');
         fnd_message.set_token('PARTY_ID', p_from_fk_id);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

      OPEN l_party_cur(p_from_fk_id);
      FETCH l_party_cur INTO l_from_party_id;
      IF l_party_cur%notfound THEN
         CLOSE l_party_cur;
         fnd_message.set_name('POS','POS_PTYM_BAD_PARTY_ID');
         fnd_message.set_token('PARTY_SITE_ID', p_to_fk_id);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
      CLOSE l_party_cur;

      IF p_to_fk_id IS NULL THEN
         fnd_message.set_name('POS','POS_PTYM_BAD_PARTY_ID');
         fnd_message.set_token('PARTY_ID', p_to_fk_id);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

      OPEN l_party_cur(p_to_fk_id);
      FETCH l_party_cur INTO l_to_party_id;
      IF l_party_cur%notfound THEN
         CLOSE l_party_cur;
         fnd_message.set_name('POS','POS_PTYM_BAD_PARTY_ID');
         fnd_message.set_token('PARTY_ID', p_to_fk_id);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
      CLOSE l_party_cur;

    ELSIF p_parent_entity_name = 'HZ_PARTY_SITES' THEN

      OPEN l_party_site_cur(p_from_fk_id);
      FETCH l_party_site_cur INTO l_from_party_id;
      IF l_party_site_cur%notfound THEN
         CLOSE l_party_site_cur;
         fnd_message.set_name('POS','POS_PTYM_BAD_PARTY_SITE_ID');
         fnd_message.set_token('PARTY_SITE_ID', p_from_fk_id);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
      CLOSE l_party_site_cur;

      OPEN l_party_site_cur(p_to_fk_id);
      FETCH l_party_site_cur INTO l_to_party_id;
      IF l_party_site_cur%notfound THEN
         CLOSE l_party_site_cur;
         fnd_message.set_name('POS','POS_PTYM_BAD_PARTY_SITE_ID');
         fnd_message.set_token('PARTY_SITE_ID', p_to_fk_id);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
      CLOSE l_party_site_cur;

   END IF;

   IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_statement, l_module, 'l_from_party_id ' || l_from_party_id);

      IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(fnd_log.level_statement, l_module, 'l_to_party_id ' || l_to_party_id);
      END IF;

   END IF;

   check_party_for_veto(l_from_party_id, 'Y', l_return_status);

   -- If the check fails then veto the merge.
   if (l_return_status = fnd_api.g_ret_sts_error) then
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
   END IF;

   update_supplier_mapping(p_from_fk_id, p_to_fk_id, l_return_status);

   IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(fnd_log.level_statement, l_module, 'return_status for from party ' || l_return_status);
   END IF;

   IF l_return_status = fnd_api.g_ret_sts_success THEN
      check_party_for_veto(l_to_party_id, 'N', l_return_status);
      IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(fnd_log.level_statement, l_module, 'return_status for from party ' || l_return_status);
      END IF;
   END IF;

   x_return_status := l_return_status;

   -- Bug 17068732: raise business event for each merged supplier. use batch_id as entity_id.
   l_sdh_profile := check_sdh_profile_option;
   IF l_sdh_profile IN ('INTGREBS', 'STANDALONE') THEN
     raise_business_event(p_from_fk_id, p_to_fk_id, p_batch_id, l_return_status);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name('POS','POS_PTYM_UNEXP_ERR');
      fnd_message.set_token('ERROR',Sqlerrm);
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

END party_merge_routine;

END pos_party_merge_pkg;

/
