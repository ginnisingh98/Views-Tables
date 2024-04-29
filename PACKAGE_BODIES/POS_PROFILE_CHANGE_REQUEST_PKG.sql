--------------------------------------------------------
--  DDL for Package Body POS_PROFILE_CHANGE_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_PROFILE_CHANGE_REQUEST_PKG" AS
/* $Header: POSPCRB.pls 120.56.12010000.11 2014/01/20 10:32:15 pneralla ship $ */

g_module VARCHAR2(30) := 'POS_PROFILE_CHANGE_REQUEST_PKG';

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

PROCEDURE raise_address_event
(    p_request_id    IN  NUMBER,
     p_request_type  IN  VARCHAR2,
     p_vendor_id     IN  NUMBER,
     p_party_id      IN  NUMBER,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_data      OUT NOCOPY VARCHAR2
)
IS
     CURSOR l_cur IS
       SELECT *
       FROM pos_address_requests
       WHERE address_request_id = p_request_id FOR UPDATE NOWAIT;

     l_approved_rec l_cur%ROWTYPE;
     l_event_status VARCHAR2(40);
     l_event_err_msg VARCHAR2(2000);
BEGIN
  OPEN l_cur;
  FETCH l_cur INTO l_approved_rec;
  IF l_cur%notfound THEN
    CLOSE l_cur;
    IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module || '.' || 'raise_address_event' , 'Request Id is not found when raising event');
    END IF;
  ELSE
    CLOSE l_cur;
    POS_VENDOR_UTIL_PKG.RAISE_SUPPLIER_EVENT(p_vendor_id => p_vendor_id,
                                            p_party_id  => p_party_id,
                                            p_transaction_type => p_request_type,
                                            p_entity_name => 'ADDRESS',
                                            p_entity_key => l_approved_rec.party_site_id,
                                            x_return_status => l_event_status,
                                            x_msg_data => l_event_err_msg);
  END IF;

  IF l_event_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module || '.' || 'raise_address_event' , l_event_err_msg);
    END IF;
  END IF;
 EXCEPTION
   WHEN OTHERS THEN
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_statement, g_module || '.' || 'raise_address_event' , l_event_err_msg);
   END IF;
END raise_address_event;

PROCEDURE raise_contact_event
(    p_request_id    IN  NUMBER,
     p_request_type  IN  VARCHAR2,
     p_vendor_id     IN  NUMBER,
     p_party_id      IN  NUMBER,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_data      OUT NOCOPY VARCHAR2
)
IS
     CURSOR l_cur IS
       SELECT *
       FROM pos_contact_requests
       WHERE contact_request_id = p_request_id FOR UPDATE NOWAIT;

     l_approved_rec l_cur%ROWTYPE;
     l_event_status VARCHAR2(40);
     l_event_err_msg VARCHAR2(2000);
BEGIN
  OPEN l_cur;
  FETCH l_cur INTO l_approved_rec;
  IF l_cur%notfound THEN
    CLOSE l_cur;
    IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module || '.' || 'raise_contact_event' , 'Request Id is not found when raising event');
    END IF;
  ELSE
    CLOSE l_cur;
    POS_VENDOR_UTIL_PKG.RAISE_SUPPLIER_EVENT(p_vendor_id => p_vendor_id,
                                            p_party_id  => p_party_id,
                                            p_transaction_type => p_request_type,
                                            p_entity_name => 'CONTACT',
                                            p_entity_key => l_approved_rec.contact_party_id,
                                            x_return_status => l_event_status,
                                            x_msg_data => l_event_err_msg);
  END IF;

  IF l_event_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module || '.' || 'raise_contact_event' , l_event_err_msg);
    END IF;
  END IF;
 EXCEPTION
   WHEN OTHERS THEN
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_statement, g_module || '.' || 'raise_contact_event' , l_event_err_msg);
   END IF;
END raise_contact_event;

PROCEDURE approve_new_address_req
  (p_request_rec     IN  pos_address_requests%ROWTYPE,
   p_vendor_id       IN  NUMBER,
   p_vendor_party_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS
     l_party_site_id     NUMBER;
     l_location_id       NUMBER;
     l_address_request_id NUMBER;
     l_lock_id NUMBER;
     cursor l_cont_addr_cur is
     select address_req_id from pos_cont_addr_requests
     WHERE address_req_id = p_request_rec.address_request_id for update nowait;
     l_cont_addr_rec l_cont_addr_cur%ROWTYPE;

     cursor l_address_note_cur is
     select address_req_id from pos_address_notes
     WHERE address_req_id = p_request_rec.address_request_id for update nowait;
     l_address_note_rec l_address_note_cur%ROWTYPE;

BEGIN
   savepoint approve_new_address_req;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   select address_request_id into l_lock_id from pos_address_requests
   WHERE address_request_id = p_request_rec.address_request_id for update nowait;

   open l_cont_addr_cur;
   fetch l_cont_addr_cur into l_cont_addr_rec;
   close l_cont_addr_cur;

   open l_address_note_cur;
   fetch l_address_note_cur into l_address_note_rec;
   close l_address_note_cur;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_new_address_req' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20049, x_msg_data, true);
   END;

   pos_supplier_address_pkg.create_supplier_address
     (p_vendor_id        => p_vendor_id,
      p_vendor_party_id  => p_vendor_party_id,
      p_party_site_name  => p_request_rec.party_site_name,
      p_address_line1    => p_request_rec.address_line1,
      p_address_line2    => p_request_rec.address_line2,
      p_address_line3    => p_request_rec.address_line3,
      p_address_line4    => p_request_rec.address_line4,
      p_country          => p_request_rec.country,
      p_city             => p_request_rec.city,
      p_state            => p_request_rec.state,
      p_province         => p_request_rec.province,
      p_postal_code      => p_request_rec.postal_code,
      p_county           => p_request_rec.county,
      p_rfq_flag         => p_request_rec.rfq_flag,
      p_pur_flag         => p_request_rec.pur_flag,
      p_pay_flag         => p_request_rec.pay_flag,
      p_primary_pay_flag => p_request_rec.primary_pay_flag,
      p_phone_area_code  => p_request_rec.phone_area_code,
      p_phone_number     => p_request_rec.phone_number,
      p_phone_extension  => p_request_rec.phone_extension,
      p_fax_area_code    => p_request_rec.fax_area_code,
      p_fax_number       => p_request_rec.fax_number,
      p_email_address    => p_request_rec.email_address,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      x_party_site_id    => l_party_site_id
     );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      rollback to approve_new_address_req;
      RETURN;
   END IF;

   UPDATE pos_address_notes
     SET party_site_id = l_party_site_id
     WHERE address_req_id = p_request_rec.address_request_id;

   UPDATE pos_address_requests
     SET party_site_id = l_party_site_id,
         request_status = 'APPROVED',
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
     WHERE address_request_id = p_request_rec.address_request_id;

   UPDATE pos_cont_addr_requests
      SET party_site_id = l_party_site_id,
          last_update_date = Sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
    WHERE address_req_id = p_request_rec.address_request_id
      AND request_status = 'PENDING'
      AND party_site_id IS NULL;

   -- Inform Banking about the address approval
   -- This call enables banking to update all the account assignment
   -- request associated with the address request to the new
   -- tca address. This call is required for banking functionality
   -- to work properly in R12 once an address has been approved.
   -- It will throw an exception if null values for address_request_id
   -- or newly created tca party_site_id are passed.
    l_address_request_id := p_request_rec.address_request_id;
    POS_SBD_PKG.sbd_handle_address_apv(
	  p_address_request_id => l_address_request_id
	, p_party_site_id      => l_party_site_id
	, x_status        => x_return_status
	, x_exception_msg => x_msg_data
	);

   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_new_address_req' , x_msg_data);
      END IF;
      rollback to approve_new_address_req;
      raise_application_error(-20050, x_msg_data, true);

END approve_new_address_req;

PROCEDURE approve_update_address_req
  (p_request_rec     IN  pos_address_requests%ROWTYPE,
   p_vendor_id       IN  NUMBER,
   p_vendor_party_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS
     l_obj_ver           hz_locations.object_version_number%TYPE;

     CURSOR l_cur IS
        SELECT object_version_number,location_id
          from hz_locations
          where location_id =
          (SELECT location_id
           FROM hz_party_sites
           WHERE party_site_id = p_request_rec.party_site_id
           ) FOR UPDATE;

     l_rec l_cur%ROWTYPE;

     CURSOR l_cur2 IS
        select object_version_number, party_site_name
          from hz_party_sites
          where party_site_id = p_request_rec.party_site_id FOR UPDATE;

     l_rec2 l_cur2%ROWTYPE;
     l_lock_id NUMBER;
BEGIN
   savepoint approve_update_address_req;

   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   select address_request_id into l_lock_id from pos_address_requests
   WHERE address_request_id = p_request_rec.address_request_id for update nowait;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_update_address_req' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20051, x_msg_data, true);
   END;


   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      -- prepare err msg
      x_return_status := fnd_api.g_ret_sts_error;
      rollback to approve_update_address_req;
      RETURN;
   END IF;
   CLOSE l_cur;

   OPEN l_cur2;
   FETCH l_cur2 INTO l_rec2;
   IF l_cur2%notfound THEN
      CLOSE l_cur2;
      -- prepare err msg
      x_return_status := fnd_api.g_ret_sts_error;
      rollback to approve_update_address_req;
      RETURN;
   END IF;
   CLOSE l_cur2;

   pos_supplier_address_pkg.update_supplier_address
     (p_vendor_id        => p_vendor_id,
      p_vendor_party_id  => p_vendor_party_id,
      p_party_site_id    => p_request_rec.party_site_id,
      p_party_site_name  => p_request_rec.party_site_name,
      p_address_line1    => p_request_rec.address_line1,
      p_address_line2    => p_request_rec.address_line2,
      p_address_line3    => p_request_rec.address_line3,
      p_address_line4    => p_request_rec.address_line4,
      p_country          => p_request_rec.country,
      p_city             => p_request_rec.city,
      p_state            => p_request_rec.state,
      p_province         => p_request_rec.province,
      p_postal_code      => p_request_rec.postal_code,
      p_county           => p_request_rec.county,
      p_rfq_flag         => p_request_rec.rfq_flag,
      p_pur_flag         => p_request_rec.pur_flag,
      p_pay_flag         => p_request_rec.pay_flag,
      p_primary_pay_flag => p_request_rec.primary_pay_flag,
      p_phone_area_code  => p_request_rec.phone_area_code,
      p_phone_number     => p_request_rec.phone_number,
      p_phone_extension  => p_request_rec.phone_extension,
      p_fax_area_code    => p_request_rec.fax_area_code,
      p_fax_number       => p_request_rec.fax_number,
      p_email_address    => p_request_rec.email_address,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data
     );

   UPDATE pos_address_requests
     SET request_status = 'APPROVED',
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
     WHERE address_request_id = p_request_rec.address_request_id;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_update_address_req' , x_msg_data);
      END IF;
      rollback to approve_update_address_req;
      raise_application_error(-20052, x_msg_data, true);
END approve_update_address_req;

PROCEDURE approve_cont_addr_requests
  (p_contact_request_id IN  NUMBER,
   x_return_status      OUT nocopy VARCHAR2,
   x_msg_count          OUT nocopy NUMBER,
   x_msg_data           OUT nocopy VARCHAR2
   ) IS
      CURSOR l_cur IS
         SELECT pcar.cont_addr_request_id,
                pcar.request_type,
                pv.party_id,
                pv.vendor_id,
                pcr.contact_party_id,
                pcar.party_site_id
           FROM pos_cont_addr_requests pcar,
                pos_contact_requests pcr,
                pos_supplier_mappings psm,
                po_vendors pv
          WHERE pcar.contact_req_id = p_contact_request_id
            AND pcar.request_status = 'PENDING'
            AND pcar.party_site_id IS NOT NULL
            AND pcar.mapping_id = psm.mapping_id
            AND psm.vendor_id = pv.vendor_id
            AND pcar.contact_req_id = pcr.contact_request_id;
BEGIN
   savepoint approve_cont_addr_requests;

   FOR l_rec IN l_cur LOOP
      IF l_rec.request_type = 'ADD' THEN

         pos_supplier_address_pkg.assign_address_to_contact
           (p_contact_party_id  => l_rec.contact_party_id,
            p_org_party_site_id => l_rec.party_site_id,
            p_vendor_id         => l_rec.vendor_id,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data
            );

         IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
	    rollback to approve_cont_addr_requests;
            RETURN;
         END IF;

       ELSIF l_rec.request_type = 'DELETE' THEN
          pos_supplier_address_pkg.unassign_address_to_contact
           (p_contact_party_id  => l_rec.contact_party_id,
            p_org_party_site_id => l_rec.party_site_id,
            p_vendor_id         => l_rec.vendor_id,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data
            );

            IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
	    rollback to approve_cont_addr_requests;
            RETURN;
         END IF;


       ELSE
         x_return_status := fnd_api.g_ret_sts_error;
         x_msg_count := 1;
         x_msg_data := 'invalid request type ' || l_rec.request_type
           || ' in pos_cont_addr_requests table with cont_addr_request_id = '
           || l_rec.cont_addr_request_id;
	 rollback to approve_cont_addr_requests;
         RETURN;
      END IF;
   END LOOP;

   UPDATE pos_cont_addr_requests
      SET request_status = 'APPROVED',
          last_update_date = Sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
    WHERE cont_addr_request_id IN
     (SELECT pcar.cont_addr_request_id
        FROM pos_cont_addr_requests pcar,
             pos_contact_requests pcr,
             pos_supplier_mappings psm,
             po_vendors pv
       WHERE pcar.contact_req_id = p_contact_request_id
         AND pcar.request_status = 'PENDING'
         AND pcar.mapping_id = psm.mapping_id
         AND psm.vendor_id = pv.vendor_id
         AND pcar.contact_req_id = pcr.contact_request_id
       );

   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_cont_addr_requests' , x_msg_data);
      END IF;
      rollback to approve_cont_addr_requests;
      raise_application_error(-20053, x_msg_data, true);

END approve_cont_addr_requests;

PROCEDURE approve_new_contact_req
  (p_request_rec     IN  pos_contact_requests%ROWTYPE,
   p_vendor_id       IN  NUMBER,
   p_vendor_party_id IN  NUMBER,
   p_user_name       IN  VARCHAR2,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2,
   x_password        OUT nocopy VARCHAR2,
   p_inactive_date   IN DATE DEFAULT NULL
   )
  IS
     l_person_party_id     NUMBER;
     l_fnd_user_id         NUMBER;
     l_step                VARCHAR2(100);
     l_method              VARCHAR2(30);
     l_lock_id             NUMBER;
     cursor l_cont_addr_cur is
     select contact_req_id from pos_cont_addr_requests
     WHERE contact_req_id = p_request_rec.contact_request_id for update nowait;
     l_cont_addr_rec l_cont_addr_cur%ROWTYPE;

BEGIN
   SAVEPOINT approve_new_contact_req_sp;

   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   select contact_request_id into l_lock_id from pos_contact_requests
   where contact_request_id = p_request_rec.contact_request_id for update nowait;

   open l_cont_addr_cur;
   fetch l_cont_addr_cur into l_cont_addr_rec;
   close l_cont_addr_cur;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_new_contact_req' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20049, x_msg_data, true);
   END;


   l_method := 'approve_new_contact_req';

   pos_supp_contact_pkg.create_supplier_contact
     (p_vendor_party_id => p_vendor_party_id,
      p_first_name      => p_request_rec.first_name,
      p_last_name       => p_request_rec.last_name,
      p_middle_name     => p_request_rec.middle_name,
      p_contact_title   => p_request_rec.contact_title,
      p_job_title       => p_request_rec.job_title,
      p_phone_area_code => p_request_rec.phone_area_code,
      p_phone_number    => p_request_rec.phone_number,
      p_phone_extension => p_request_rec.phone_extension,
      p_fax_area_code   => p_request_rec.fax_area_code,
      p_fax_number      => p_request_rec.fax_number,
      p_email_address   => p_request_rec.email_address,
      p_inactive_date   => p_inactive_date,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      x_person_party_id => l_person_party_id,
      p_department      => p_request_rec.department,
      p_alt_contact_name => p_request_rec.alt_contact_name,
      p_alt_area_code    => p_request_rec.alt_area_code,
      p_alt_phone_number => p_request_rec.alt_phone_number,
      p_url              => p_request_rec.url
      );

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO approve_new_contact_req_sp;
      RETURN;
   END IF;

   -- handling user account
   IF p_request_rec.create_user_account IS NOT NULL
     AND p_request_rec.create_user_account = 'Y' THEN
      -- create fnd user account
      l_step := 'call create_fnd_user';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
           ( fnd_log.level_statement
             , g_module || '.' || l_method
             , l_step
             || ' username ' || p_request_rec.email_address
             || ' user_email ' || p_request_rec.email_address
             || ' party_id ' || l_person_party_id
             );
      END IF;

      pos_user_admin_pkg.create_supplier_user_ntf
        (p_user_name        => p_user_name,
         p_user_email       => p_request_rec.email_address,
         p_person_party_id  => l_person_party_id,
         p_password         => null,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
         x_user_id          => l_fnd_user_id,
         x_password         => x_password
         );

      IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
         ROLLBACK TO approve_new_contact_req_sp;
         RETURN;
      END IF;

      pos_user_admin_pkg.createsecattr
	( p_user_id        => l_fnd_user_id,
	  p_attribute_code => 'ICX_SUPPLIER_ORG_ID',
	  p_app_id         => 177,
	  p_number_value   => p_vendor_id
	  );
   END IF;

   l_step := 'update pos_contact_request with ids';
   IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        ( fnd_log.level_statement
          , g_module || '.' || l_method
          , l_step
          );
   END IF;

   UPDATE pos_contact_requests
     SET contact_party_id = l_person_party_id,
     request_status = 'APPROVED',
     last_update_date = Sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
     WHERE contact_request_id = p_request_rec.contact_request_id;

   UPDATE pos_cont_addr_requests
     SET contact_party_id = l_person_party_id,
     last_update_date = Sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
     WHERE contact_req_id = p_request_rec.contact_request_id
       AND contact_party_id IS NULL
       AND request_status = 'PENDING';

   -- handle address contact association
   approve_cont_addr_requests
     (p_contact_request_id => p_request_rec.contact_request_id,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO approve_new_contact_req_sp;
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count := 1;
      x_msg_data := Sqlerrm;
      ROLLBACK TO approve_new_contact_req_sp;
      pos_log.log_sqlerrm('POSCONTB', 'in approve_new_contact_req');

END approve_new_contact_req;

PROCEDURE approve_update_contact_req
  (p_request_rec     IN  pos_contact_requests%ROWTYPE,
   p_vendor_party_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS
l_lock_id number;
p_request_inactive_date date;
BEGIN
   SAVEPOINT approve_update_contact_req_sp;

   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   select contact_request_id into l_lock_id from pos_contact_requests
   where contact_request_id = p_request_rec.contact_request_id for update nowait;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_update_contact_req' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20049, x_msg_data, true);
   END;

   IF p_request_rec.request_type <> 'UPDATE' AND
      p_request_rec.request_type <> 'DELETE'    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 1;
      x_msg_data := 'request_type not UPDATED for contact request id '
	            || p_request_rec.contact_request_id;
      ROLLBACK TO approve_update_contact_req_sp;
      RETURN;
   END IF;

   IF p_request_rec.request_status <> 'PENDING' THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 1;
      x_msg_data := 'request_status not PENDING for contact request id '
   	            || p_request_rec.contact_request_id;
      ROLLBACK TO approve_update_contact_req_sp;
      RETURN;
   END IF;

   IF p_request_rec.contact_party_id IS NULL THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 1;
      x_msg_data := 'contact_party_id is NULL for contact request id '
   	            || p_request_rec.contact_request_id;
      ROLLBACK TO approve_update_contact_req_sp;
      RETURN;
   END IF;

   IF p_request_rec.request_type = 'DELETE' THEN
    p_request_inactive_date := sysdate;
   ELSE
    p_request_inactive_date := null;
   END IF;

   pos_supp_contact_pkg.update_supplier_contact
     (p_contact_party_id => p_request_rec.contact_party_id,
      p_vendor_party_id  => p_vendor_party_id,
      p_first_name       => p_request_rec.first_name,
      p_last_name        => p_request_rec.last_name,
      p_middle_name      => p_request_rec.middle_name,
      p_contact_title    => p_request_rec.contact_title,
      p_job_title        => p_request_rec.job_title,
      p_phone_area_code  => p_request_rec.phone_area_code,
      p_phone_number     => p_request_rec.phone_number,
      p_phone_extension  => p_request_rec.phone_extension,
      p_fax_area_code    => p_request_rec.fax_area_code,
      p_fax_number       => p_request_rec.fax_number,
      p_email_address    => p_request_rec.email_address,
      p_inactive_date    => p_request_inactive_date,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data ,
      p_department       => p_request_rec.department,
      p_alt_contact_name => p_request_rec.alt_contact_name,
      p_alt_area_code    => p_request_rec.alt_area_code,
      p_alt_phone_number => p_request_rec.alt_phone_number,
      p_url              => p_request_rec.url
   );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO approve_update_contact_req_sp;
      RETURN;
   END IF;

   UPDATE pos_contact_requests
      SET request_status = 'APPROVED',
          last_update_date = Sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
    WHERE contact_request_id = p_request_rec.contact_request_id;

   -- handle address contact association
   approve_cont_addr_requests
     (p_contact_request_id => p_request_rec.contact_request_id,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO approve_update_contact_req_sp;
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO approve_update_contact_req_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count := 1;
      x_msg_data := Sqlerrm;
      pos_log.log_sqlerrm('POSCONTB', 'in approve_update_contact_req');

END approve_update_contact_req;

PROCEDURE approve_new_bus_class_req
  (p_request_rec     IN  pos_bus_class_reqs%ROWTYPE,
   p_vendor_id       IN  NUMBER,
   p_vendor_party_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
  )
  IS

  l_lock_id NUMBER;

BEGIN
   savepoint approve_new_bus_class_req;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   select bus_class_request_id into l_lock_id from pos_bus_class_reqs
   WHERE bus_class_request_id = p_request_rec.bus_class_request_id for update nowait;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_new_bus_class_req' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20049, x_msg_data, true);
   END;

   INSERT INTO pos_bus_class_attr
     (  classification_id
      , party_id
      , lookup_type
      , lookup_code
      , start_date_active
      , end_date_active
      , status
      , ext_attr_1
      , expiration_date
      , certificate_number
      , certifying_agency
      , class_status
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
      , last_update_login
      , vendor_id
        )
     VALUES
     (
        pos_bus_class_attr_s.NEXTVAL
      , p_vendor_party_id
      , p_request_rec.lookup_type
      , p_request_rec.lookup_code
      , Sysdate
      , NULL
      , 'A'
      , p_request_rec.ext_attr_1
      , p_request_rec.expiration_date
      , p_request_rec.certification_no
      , p_request_rec.certification_agency
      , 'APPROVED'
      , fnd_global.user_id
      , Sysdate
      , fnd_global.user_id
      , Sysdate
      , fnd_global.login_id
      , p_vendor_id
      );

   UPDATE pos_bus_class_reqs
      SET request_status = 'APPROVED',
      last_update_date = Sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id,
      classification_id = pos_bus_class_attr_s.CURRVAL
    WHERE bus_class_request_id = p_request_rec.bus_class_request_id;

   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_new_bus_class_req' , x_msg_data);
      END IF;
      rollback to approve_new_bus_class_req;
      raise_application_error(-20097, x_msg_data, true);

END approve_new_bus_class_req;

PROCEDURE approve_update_bus_class_req
  (p_request_rec     IN  pos_bus_class_reqs%ROWTYPE,
   p_vendor_id       IN  NUMBER,
   p_vendor_party_id IN  NUMBER,   x_return_status OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS

  l_lock_id NUMBER;

BEGIN
   savepoint approve_update_bus_class_req;

   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   select bus_class_request_id into l_lock_id from pos_bus_class_reqs
   WHERE bus_class_request_id = p_request_rec.bus_class_request_id for update nowait;

   select classification_id into l_lock_id from pos_bus_class_attr
   WHERE classification_id = p_request_rec.classification_id for update nowait;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_update_bus_class_req' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20049, x_msg_data, true);
   END;

   UPDATE pos_bus_class_attr
     SET ext_attr_1          = p_request_rec.ext_attr_1
       , expiration_date     = p_request_rec.expiration_date
       , certificate_number  = p_request_rec.certification_no
       , certifying_agency   = p_request_rec.certification_agency
       , last_updated_by     = fnd_global.user_id
       , last_update_date    = Sysdate
       , last_update_login   = fnd_global.login_id
     WHERE classification_id = p_request_rec.classification_id;

   UPDATE pos_bus_class_reqs
     SET request_status = 'APPROVED',
     last_update_date = Sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
     WHERE bus_class_request_id = p_request_rec.bus_class_request_id;

   x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_update_bus_class_req' , x_msg_data);
      END IF;
      rollback to approve_update_bus_class_req;
      raise_application_error(-20096, x_msg_data, true);

END approve_update_bus_class_req;

PROCEDURE approve_address_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   )
  IS
     CURSOR l_cur IS
        SELECT *
          FROM pos_address_requests
          WHERE address_request_id = p_request_id FOR UPDATE NOWAIT;
     	  -- ECO 5209555 Add the nowait clause

     l_rec l_cur%ROWTYPE;

     CURSOR l_cur2 IS
        SELECT vendor_id, party_id
          FROM pos_supplier_mappings psm
          WHERE mapping_id = l_rec.mapping_id;

     l_rec2 l_cur2%ROWTYPE;
     l_lock_id number;

     --Added for Bug 17068732: raise business event
     l_sdh_profile fnd_profile_option_values.profile_option_value%type;
     l_event_status VARCHAR2(40);
     l_event_err_msg VARCHAR2(2000);
BEGIN
   savepoint approve_address_req;
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_PRCR_BAD_ADDR_REQ_ID');
      fnd_message.set_token('ADDRRESS_REQUEST_ID', p_request_id);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
      rollback to approve_address_req;
      RETURN;
   END IF;
   CLOSE l_cur;

   IF l_rec.request_status IS NULL OR l_rec.request_status <> 'PENDING' THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_PRCR_ADDRREQ_NOT_PEND');
      fnd_message.set_token('ADDRRESS_REQUEST_ID', p_request_id);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
      rollback to approve_address_req;
      RETURN;
   END IF;

   OPEN l_cur2;
   FETCH l_cur2 INTO l_rec2;
   IF l_cur2%notfound THEN
      CLOSE l_cur2;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_PRCR_BAD_MAPPING_ID');
      fnd_message.set_token('MAPPING_ID', l_rec.mapping_id);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
      rollback to approve_address_req;
      RETURN;
   END IF;
   CLOSE l_cur2;

   IF l_rec.request_type = 'ADD' THEN
      approve_new_address_req
        (p_request_rec      => l_rec,
         p_vendor_id        => l_rec2.vendor_id,
         p_vendor_party_id  => l_rec2.party_id,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
         );
      -- Begin Supplier Hub: Bug 17068732: Raise Business Event for address creation
      l_sdh_profile := check_sdh_profile_option;
      IF l_sdh_profile IN ('INTGREBS', 'STANDALONE') THEN
        raise_address_event (p_request_id,
                             'CREATE',
                             l_rec2.vendor_id,
                             l_rec2.party_id,
                             l_event_status,
                             l_event_err_msg);
      END IF;
      -- End Bug 17068732: Address creation


    ELSIF l_rec.request_type = 'UPDATE' THEN
      approve_update_address_req
        (p_request_rec      => l_rec,
         p_vendor_id        => l_rec2.vendor_id,
         p_vendor_party_id  => l_rec2.party_id,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
         );
      -- Begin Supplier Hub: Bug 17068732: Raise Business Event for address update
      l_sdh_profile := check_sdh_profile_option;
      IF l_sdh_profile IN ('INTGREBS', 'STANDALONE') THEN
        raise_address_event (p_request_id,
                             'UPDATE',
                             l_rec2.vendor_id,
                             l_rec2.party_id,
                             l_event_status,
                             l_event_err_msg);
      END IF;
      -- End Bug 17068732: Address Update

    ELSIF l_rec.request_type = 'DELETE' then

     UPDATE pos_address_requests
     SET request_status = 'APPROVED',
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
     WHERE address_request_id = p_request_id;

     -- Begin Supplier Hub: Bug 17068732: Raise Business Event for address delete
     l_sdh_profile := check_sdh_profile_option;
     IF l_sdh_profile IN ('INTGREBS', 'STANDALONE') THEN
       raise_address_event (p_request_id,
                             'DELETE',
                             l_rec2.vendor_id,
                             l_rec2.party_id,
                             l_event_status,
                             l_event_err_msg);
     END IF;

     x_return_status := fnd_api.g_ret_sts_success;  -- This is to fix the existing NPE when approving a delete request.
     -- End Bug 17068732: Address Delete

    ELSE
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 1;
      x_msg_data := l_rec.request_type || ' is not yet supported';
   END IF;

 EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_address_req' , x_msg_data);
      END IF;
      rollback to approve_address_req;
      raise_application_error(-20092, x_msg_data, true);

END approve_address_req;

PROCEDURE approve_contact_req
  (p_request_id          IN  NUMBER,
   x_return_status 	 OUT nocopy VARCHAR2,
   x_msg_count     	 OUT nocopy NUMBER,
   x_msg_data      	 OUT nocopy VARCHAR2,
   x_password      	 OUT nocopy VARCHAR2
   )
  IS
BEGIN
   savepoint approve_contact_req;
   approve_contact_req
     (p_request_id          => p_request_id,
      p_user_name           => NULL, -- not passing user name to default to email address
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_password            => x_password
      );

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_contact_req' , x_msg_data);
      END IF;
      rollback to approve_contact_req;
      raise_application_error(-20093, x_msg_data, true);

END approve_contact_req;

-- If the request is a new contact request with user account,
-- x_password will have the generated password; otherwise it is null
--
PROCEDURE approve_contact_req
  (p_request_id          IN  NUMBER,
   p_user_name           IN  VARCHAR2,
   x_return_status 	 OUT nocopy VARCHAR2,
   x_msg_count     	 OUT nocopy NUMBER,
   x_msg_data      	 OUT nocopy VARCHAR2,
   x_password      	 OUT nocopy VARCHAR2,
   p_inactive_date       IN  DATE DEFAULT NULL
   )
  IS
     CURSOR l_cur IS
        SELECT *
          FROM pos_contact_requests
          WHERE contact_request_id = p_request_id FOR UPDATE NOWAIT;
     	  -- ECO 5209555 Add the nowait clause

     l_rec l_cur%ROWTYPE;

     CURSOR l_cur2 IS
        SELECT vendor_id, party_id
          FROM pos_supplier_mappings psm
          WHERE mapping_id = l_rec.mapping_id;

     l_rec2 l_cur2%ROWTYPE;

     l_method VARCHAR2(30);

     l_user_name fnd_user.user_name%TYPE;

   /*Begin Supplier Hub -- Supplier Management */

  /* Added to assign party usage as SUPPLIER_CONTACT for existing party
     contacts*/

    l_party_usg_rec   HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;
    l_party_usg_validation_level NUMBER;

  /*End Supplier Hub -- Supplier Management */

    -- Added for Bug 17068732: raise business event
    l_sdh_profile fnd_profile_option_values.profile_option_value%type;
    l_event_status VARCHAR2(40);
    l_event_err_msg VARCHAR2(2000);

BEGIN
   savepoint approve_contact_req;

   l_method := 'approve_contact_req';
   x_password := NULL;
   IF  (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        ( fnd_log.level_procedure
          , g_module || '.' || l_method
          , 'start with p_request_id ' || p_request_id
          );
   END IF;

   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_PRCR_BAD_CONT_REQ_ID');
      fnd_message.set_token('CONTACT_REQUEST_ID', p_request_id);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
      rollback to approve_contact_req;
      RETURN;
   END IF;
   CLOSE l_cur;

   IF l_rec.request_status IS NULL OR l_rec.request_status <> 'PENDING' THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_PRCR_CONTREQ_NOT_PEND');
      fnd_message.set_token('CONTACT_REQUEST_ID', p_request_id);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
      rollback to approve_contact_req;
      RETURN;
   END IF;

   OPEN l_cur2;
   FETCH l_cur2 INTO l_rec2;
   IF l_cur2%notfound THEN
      CLOSE l_cur2;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_PRCR_BAD_MAPPING_ID');
      fnd_message.set_token('MAPPING_ID', l_rec.mapping_id);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
      rollback to approve_contact_req;
      RETURN;
   END IF;
   CLOSE l_cur2;

   IF l_rec.request_type = 'ADD' THEN

      IF p_user_name IS NOT NULL THEN
	 l_user_name := p_user_name;
       ELSE
	 l_user_name := l_rec.email_address;
      END IF;

      approve_new_contact_req
	(p_request_rec         => l_rec,
	 p_vendor_id           => l_rec2.vendor_id,
	 p_vendor_party_id     => l_rec2.party_id,
	 p_user_name           => l_user_name,
	 x_return_status       => x_return_status,
	 x_msg_count           => x_msg_count,
	 x_msg_data            => x_msg_data,
	 x_password            => x_password,
	 p_inactive_date       => p_inactive_date
	 );

   -- Begin Supplier Hub: Bug 17068732: Raise Business Event for contact creation
   l_sdh_profile := check_sdh_profile_option;
   IF l_sdh_profile IN ('INTGREBS', 'STANDALONE') THEN
     raise_contact_event (p_request_id,
                          'CREATE',
                          l_rec2.vendor_id,
                          l_rec2.party_id,
                          l_event_status,
                          l_event_err_msg);
   END IF;
   -- End Bug 17068732: Contact creation

    ELSIF l_rec.request_type = 'UPDATE' OR
          l_rec.request_type = 'DELETE' THEN
      approve_update_contact_req
	(p_request_rec     => l_rec,
	 p_vendor_party_id => l_rec2.party_id,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data
	 );

   -- Begin Supplier Hub: Bug 17068732: Raise Business Event for contact update/delete
   l_sdh_profile := check_sdh_profile_option;
   IF l_sdh_profile IN ('INTGREBS', 'STANDALONE') THEN
     raise_contact_event (p_request_id,
                          'UPDATE',
                          l_rec2.vendor_id,
                          l_rec2.party_id,
                          l_event_status,
                          l_event_err_msg);
   END IF;
   -- End Bug 17068732: Contact creation

        /*Begin Supplier Hub -- Supplier Management */
        /* Added to assign partyusage as SUPPLIER_CONTACT for
           existing party contacts*/
    ELSIF l_rec.request_type = 'ADD_PARTY_CONTACT' THEN
        l_party_usg_validation_level :=
                         HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_NONE;
        l_party_usg_rec.party_id := l_rec.contact_party_id;
        l_party_usg_rec.party_usage_code := 'SUPPLIER_CONTACT';
        l_party_usg_rec.created_by_module := 'POS_SUPPLIER_MGMT';

        HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage (
        p_validation_level          => l_party_usg_validation_level,
        p_party_usg_assignment_rec  => l_party_usg_rec,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data);


        IF (x_return_status IS NULL OR
            x_return_status <> fnd_api.g_ret_sts_success) THEN
             ROLLBACK TO approve_new_contact_req_sp;
            RETURN;
        END IF;

        UPDATE pos_contact_requests
         SET request_status = 'APPROVED',
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
         WHERE contact_request_id = l_rec.contact_request_id;

        -- Begin Supplier Hub: Bug 17068732: Raise Business Event for enabling supplier contact
        l_sdh_profile := check_sdh_profile_option;
        IF l_sdh_profile IN ('INTGREBS', 'STANDALONE') THEN
          raise_contact_event (p_request_id,
                               'UPDATE',
                               l_rec2.vendor_id,
                               l_rec2.party_id,
                               l_event_status,
                               l_event_err_msg);
        END IF;
        -- End Bug 17068732: Contact creation

    /*End Supplier Hub -- Supplier Management */

    ELSE

      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 1;
      x_msg_data := l_rec.request_type || ' is not yet supported';
   END IF;

 EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_contact_req' , x_msg_data);
      END IF;
      rollback to approve_contact_req;
      raise_application_error(-20090, x_msg_data, true);

END approve_contact_req;

PROCEDURE approve_bus_class_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   )
  IS
     CURSOR l_cur IS
        SELECT *
          FROM pos_bus_class_reqs
          WHERE bus_class_request_id = p_request_id FOR UPDATE NOWAIT;
     	  -- ECO 5209555 Add the nowait clause

     l_rec l_cur%ROWTYPE;

     CURSOR l_cur2 IS
        SELECT vendor_id, party_id
          FROM pos_supplier_mappings psm
          WHERE mapping_id = l_rec.mapping_id;

     l_rec2 l_cur2%ROWTYPE;

BEGIN

savepoint approve_bus_class_req;

   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_PRCR_BAD_BC_REQ_ID');
      fnd_message.set_token('BUS_CLASS_REQUEST_ID', p_request_id);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
      rollback to approve_bus_class_req;
      RETURN;
   END IF;
   CLOSE l_cur;

   IF l_rec.request_status IS NULL OR l_rec.request_status <> 'PENDING' THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_PRCR_BCREQ_NOT_PEND');
      fnd_message.set_token('BUS_CLASS_REQUEST_ID', p_request_id);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
      rollback to approve_bus_class_req;
      RETURN;
   END IF;

   OPEN l_cur2;
   FETCH l_cur2 INTO l_rec2;
   IF l_cur2%notfound THEN
      CLOSE l_cur2;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_PRCR_BAD_MAPPING_ID');
      fnd_message.set_token('MAPPING_ID', l_rec.mapping_id);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
      rollback to approve_bus_class_req;
      RETURN;
   END IF;
   CLOSE l_cur2;

   IF l_rec.request_type = 'ADD' THEN
      approve_new_bus_class_req
        (p_request_rec      => l_rec,
         p_vendor_id        => l_rec2.vendor_id,
         p_vendor_party_id  => l_rec2.party_id,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
         );

      POS_SUPP_CLASSIFICATION_PKG.SYNCHRONIZE_CLASS_TCA_TO_PO(
                pPartyId => l_rec2.party_id,
                pVendorId => l_rec2.vendor_id);
    ELSIF l_rec.request_type = 'UPDATE' THEN
      approve_update_bus_class_req
        (p_request_rec      => l_rec,
         p_vendor_id        => l_rec2.vendor_id,
         p_vendor_party_id  => l_rec2.party_id,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
         );
      POS_SUPP_CLASSIFICATION_PKG.SYNCHRONIZE_CLASS_TCA_TO_PO(
                pPartyId => l_rec2.party_id,
                pVendorId => l_rec2.vendor_id);

    ELSE
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 1;
      x_msg_data := l_rec.request_type || ' is not yet supported';
   END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_bus_class_req' , x_msg_data);
      END IF;
      rollback to approve_bus_class_req;
      raise_application_error(-20090, x_msg_data, true);

END approve_bus_class_req;

PROCEDURE approve_ps_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   )
  IS
     CURSOR l_cur IS
        SELECT *
          FROM pos_product_service_requests
          WHERE ps_request_id = p_request_id FOR UPDATE NOWAIT;
	  -- ECO 5209555 Add the nowait clause

     l_rec l_cur%ROWTYPE;

     CURSOR l_cur2 IS
        SELECT vendor_id, party_id
          FROM pos_supplier_mappings psm
          WHERE mapping_id = l_rec.mapping_id;

     l_rec2 l_cur2%ROWTYPE;
     l_lock_id number;

     -- Added for Bug 17068732: raise business event
    l_sdh_profile fnd_profile_option_values.profile_option_value%type;
    l_event_status VARCHAR2(40);
    l_event_err_msg VARCHAR2(2000);

BEGIN

  savepoint approve_ps_req;

   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_PRCR_BAD_PS_REQ_ID');
      fnd_message.set_token('PS_REQUEST_ID', p_request_id);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
      rollback to approve_ps_req;
      RETURN;
   END IF;
   CLOSE l_cur;

   IF l_rec.request_status IS NULL OR l_rec.request_status <> 'PENDING' THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_PRCR_PSREQ_NOT_PEND');
      fnd_message.set_token('PS_REQUEST_ID', p_request_id);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
      rollback to approve_ps_req;
      RETURN;
   END IF;

   IF l_rec.request_type IS NULL OR l_rec.request_type <> 'ADD' THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_PRCR_PSREQ_TYPE_NOT_ADD');
      fnd_message.set_token('PS_REQUEST_ID', p_request_id);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
      rollback to approve_ps_req;
      RETURN;
   END IF;

   OPEN l_cur2;
   FETCH l_cur2 INTO l_rec2;
   IF l_cur2%notfound THEN
      CLOSE l_cur2;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_PRCR_BAD_MAPPING_ID');
      fnd_message.set_token('MAPPING_ID', l_rec.mapping_id);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);
      rollback to approve_ps_req;
      RETURN;
   END IF;
   CLOSE l_cur2;

   INSERT INTO pos_sup_products_services
     (
        classification_id
      , vendor_id
      , segment1
      , segment2
      , segment3
      , segment4
      , segment5
      , segment6
      , segment7
      , segment8
      , segment9
      , segment10
      , segment11
      , segment12
      , segment13
      , segment14
      , segment15
      , segment16
      , segment17
      , segment18
      , segment19
      , segment20
      , status
      , segment_definition
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
      , last_update_login
     )
     VALUES
     (
        pos_sup_products_services_s.NEXTVAL
      , l_rec2.vendor_id
      , l_rec.segment1
      , l_rec.segment2
      , l_rec.segment3
      , l_rec.segment4
      , l_rec.segment5
      , l_rec.segment6
      , l_rec.segment7
      , l_rec.segment8
      , l_rec.segment9
      , l_rec.segment10
      , l_rec.segment11
      , l_rec.segment12
      , l_rec.segment13
      , l_rec.segment14
      , l_rec.segment15
      , l_rec.segment16
      , l_rec.segment17
      , l_rec.segment18
      , l_rec.segment19
      , l_rec.segment20
      , 'A'
      , l_rec.segment_definition
      , fnd_global.user_id
      , Sysdate
      , fnd_global.user_id
      , Sysdate
      , fnd_global.login_id
     );

   UPDATE pos_product_service_requests
      SET request_status = 'APPROVED',
      last_update_date = Sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id
   WHERE ps_request_id = p_request_id;

   x_return_status := fnd_api.g_ret_sts_success;

      -- Begin Supplier Hub: Bug 17068732: Raise Business Event for Products and Services creation
      BEGIN
      l_sdh_profile := check_sdh_profile_option;
      IF l_sdh_profile IN ('INTGREBS', 'STANDALONE') THEN
         POS_VENDOR_UTIL_PKG.RAISE_SUPPLIER_EVENT(p_vendor_id => l_rec2.vendor_id,
                                            p_party_id  => l_rec2.party_id,
                                            p_transaction_type => 'CREATE',
                                            p_entity_name => 'PRODUCTS AND SERVICES',
                                            p_entity_key => pos_sup_products_services_s.CURRVAL,
                                            x_return_status => l_event_status,
                                            x_msg_data => l_event_err_msg);
        IF l_event_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string(fnd_log.level_statement, g_module || '.' || 'raise_supplier_event_for_PS' , l_event_err_msg);
           END IF;
        END IF;
      END IF;
      EXCEPTION
      WHEN OTHERS THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'raise_supplier_event_for_PS' , l_event_err_msg);
        END IF;
      END;
      -- End Bug 17068732: Products and Services creation


EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_ps_req' , x_msg_data);
      END IF;
      rollback to approve_ps_req;
      raise_application_error(-20088, x_msg_data, true);

END approve_ps_req;

PROCEDURE reject_address_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   )
  IS
 l_lock_id number;
     cursor l_cont_addr_cur is
     select address_req_id from pos_cont_addr_requests
     WHERE address_req_id = p_request_id for update nowait;
     l_cont_addr_rec l_cont_addr_cur%ROWTYPE;

BEGIN
   savepoint reject_address_req;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN
    select address_request_id into l_lock_id from pos_address_requests
    WHERE address_request_id = p_request_id for update nowait;

    open l_cont_addr_cur;
    fetch l_cont_addr_cur into l_cont_addr_rec;
    close l_cont_addr_cur;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_address_req' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20086, x_msg_data, true);
   END;

   UPDATE pos_address_requests
     SET request_status = 'REJECTED',
     last_update_date = Sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
     WHERE address_request_id = p_request_id;

   UPDATE pos_cont_addr_requests
     SET request_status = 'REJECTED',
     last_update_date = Sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
   WHERE address_req_id = p_request_id;

   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_address_req' , x_msg_data);
      END IF;
      rollback to reject_address_req;
      raise_application_error(-20085, x_msg_data, true);

END reject_address_req;

PROCEDURE reject_contact_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   )
  IS

 l_lock_id number;

BEGIN

   savepoint reject_contact_req;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN
    select contact_request_id into l_lock_id from pos_contact_requests
    WHERE contact_request_id = p_request_id for update nowait;
   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_contact_req' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20084, x_msg_data, true);
   END;

   -- Bug # 5192274, the address requests should also be rejected
   update pos_cont_addr_requests
     set request_status = 'REJECTED',
     last_update_date = sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
   where contact_req_id = p_request_id;

   UPDATE pos_contact_requests
     SET request_status = 'REJECTED',
     last_update_date = Sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
   WHERE contact_request_id = p_request_id;

   x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_contact_req' , x_msg_data);
      END IF;
      rollback to reject_contact_req;
      raise_application_error(-20083, x_msg_data, true);

END reject_contact_req;

PROCEDURE reject_bus_class_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   )
  IS
  l_lock_id number;

BEGIN

   savepoint reject_bus_class_req;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   select bus_class_request_id into l_lock_id from pos_bus_class_reqs
   WHERE bus_class_request_id = p_request_id for update nowait;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_bus_class_req' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20082, x_msg_data, true);
   END;

   UPDATE pos_bus_class_reqs
     SET request_status = 'REJECTED',
     last_update_date = Sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
   WHERE bus_class_request_id = p_request_id;

   x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_bus_class_req' , x_msg_data);
      END IF;
      rollback to reject_bus_class_req;
      raise_application_error(-20081, x_msg_data, true);

END reject_bus_class_req;

PROCEDURE reject_ps_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   )
  IS
 l_lock_id number;
BEGIN
   savepoint reject_ps_req;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   select ps_request_id into l_lock_id from pos_product_service_requests
   WHERE ps_request_id = p_request_id for update nowait;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_ps_req' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20080, x_msg_data, true);
   END;

   UPDATE pos_product_service_requests
     SET request_status = 'REJECTED',
     last_update_date = Sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
   WHERE ps_request_id = p_request_id;

   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_ps_req' , x_msg_data);
      END IF;
      rollback to reject_ps_req;
      raise_application_error(-20079, x_msg_data, true);

END reject_ps_req;

PROCEDURE reject_mult_address_reqs
  (  p_req_id_tbl        IN  po_tbl_number,
     x_return_status     OUT nocopy VARCHAR2,
     x_msg_count         OUT nocopy NUMBER,
     x_msg_data          OUT nocopy VARCHAR2
     )
  IS

 l_lock_id number;

BEGIN
   savepoint reject_mult_address_reqs;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN
   for i in 1..p_req_id_tbl.COUNT LOOP

    select address_request_id into l_lock_id from pos_address_requests
    WHERE address_request_id = p_req_id_tbl(i) for update nowait;

   END LOOP;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_mult_address_reqs' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20078, x_msg_data, true);
   END;

   for i in 1..p_req_id_tbl.COUNT LOOP
      reject_address_req
        (p_request_id       => p_req_id_tbl(i),
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
         );
      IF x_return_status IS NULL
        OR x_return_status <> fnd_api.g_ret_sts_success THEN
	 rollback to reject_mult_address_reqs;
         RETURN;
      END IF;
   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_mult_address_reqs' , x_msg_data);
      END IF;
      rollback to reject_mult_address_reqs;
      raise_application_error(-20077, x_msg_data, true);

END reject_mult_address_reqs;

PROCEDURE reject_mult_contact_reqs
  ( p_req_id_tbl        IN  po_tbl_number,
    x_return_status     OUT nocopy VARCHAR2,
    x_msg_count         OUT nocopy NUMBER,
    x_msg_data          OUT nocopy VARCHAR2
    )
  IS

 l_lock_id number;

BEGIN
   savepoint reject_mult_contact_reqs;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   for i in 1..p_req_id_tbl.COUNT LOOP
      select contact_request_id into l_lock_id from pos_contact_requests
      where contact_request_id = p_req_id_tbl(i) for update nowait;

   END LOOP;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_mult_contact_reqs' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20076, x_msg_data, true);
   END;

   for i in 1..p_req_id_tbl.COUNT LOOP
      reject_contact_req
        (p_request_id       => p_req_id_tbl(i),
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
         );
      IF x_return_status IS NULL
        OR x_return_status <> fnd_api.g_ret_sts_success THEN
	 rollback to reject_mult_contact_reqs;
         RETURN;
      END IF;
   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_mult_contact_reqs' , x_msg_data);
      END IF;
      rollback to reject_mult_contact_reqs;
      raise_application_error(-20075, x_msg_data, true);

END reject_mult_contact_reqs;

PROCEDURE reject_mult_bus_class_reqs
  ( p_req_id_tbl        IN  po_tbl_number,
    x_return_status     OUT nocopy VARCHAR2,
    x_msg_count         OUT nocopy NUMBER,
    x_msg_data          OUT nocopy VARCHAR2
    )
  IS

  l_lock_id number;

BEGIN
   savepoint reject_mult_bus_class_reqs;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   for i in 1..p_req_id_tbl.COUNT LOOP

   select bus_class_request_id into l_lock_id from pos_bus_class_reqs
   where bus_class_request_id =  p_req_id_tbl(i) for update nowait;

   END LOOP;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_mult_bus_class_reqs' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20074, x_msg_data, true);
   END;


   for i in 1..p_req_id_tbl.COUNT LOOP
      reject_bus_class_req
        (p_request_id       => p_req_id_tbl(i),
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
         );
      IF x_return_status IS NULL
        OR x_return_status <> fnd_api.g_ret_sts_success THEN
	 rollback to reject_mult_bus_class_reqs;
         RETURN;
      END IF;
   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_mult_bus_class_reqs' , x_msg_data);
      END IF;
      rollback to reject_mult_bus_class_reqs;
      raise_application_error(-20073, x_msg_data, true);

END reject_mult_bus_class_reqs;

PROCEDURE reject_mult_ps_reqs
  ( p_req_id_tbl        IN  po_tbl_number,
    x_return_status     OUT nocopy VARCHAR2,
    x_msg_count       OUT nocopy NUMBER,
    x_msg_data          OUT nocopy VARCHAR2
    )
  IS
l_lock_id number;

BEGIN

   savepoint reject_mult_ps_reqs;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   for i in 1..p_req_id_tbl.COUNT LOOP

   select ps_request_id into l_lock_id from pos_product_service_requests
   WHERE ps_request_id = p_req_id_tbl(i) for update nowait;

   END LOOP;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_mult_ps_reqs' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20071, x_msg_data, true);
   END;

   for i in 1..p_req_id_tbl.COUNT LOOP
      reject_ps_req
        (p_request_id       => p_req_id_tbl(i),
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
         );
      IF x_return_status IS NULL
        OR x_return_status <> fnd_api.g_ret_sts_success THEN
	 rollback to reject_mult_ps_reqs;
         RETURN;
      END IF;
   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_mult_ps_reqs' , x_msg_data);
      END IF;
      rollback to reject_mult_ps_reqs;
      raise_application_error(-20072, x_msg_data, true);

END reject_mult_ps_reqs;

PROCEDURE approve_mult_address_reqs
  ( p_req_id_tbl        IN  po_tbl_number,
    x_return_status     OUT nocopy VARCHAR2,
    x_msg_count         OUT nocopy NUMBER,
    x_msg_data          OUT nocopy VARCHAR2
    )
  IS

 l_lock_id number;

BEGIN
   savepoint approve_mult_address_reqs;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN
   for i in 1..p_req_id_tbl.COUNT LOOP

    select address_request_id into l_lock_id from pos_address_requests
    WHERE address_request_id = p_req_id_tbl(i) for update nowait;

   END LOOP;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_mult_address_reqs' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20070, x_msg_data, true);
   END;

   for i in 1..p_req_id_tbl.COUNT LOOP
      approve_address_req
        (p_request_id       => p_req_id_tbl(i),
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
         );
      IF x_return_status IS NULL
        OR x_return_status <> fnd_api.g_ret_sts_success THEN
	 rollback to approve_mult_address_reqs;
         RETURN;
      END IF;
   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_mult_address_reqs' , x_msg_data);
      END IF;
      rollback to approve_mult_address_reqs;
      raise_application_error(-20069, x_msg_data, true);

END approve_mult_address_reqs;

PROCEDURE approve_mult_contact_reqs
  ( p_req_id_tbl        IN  po_tbl_number,
    x_return_status     OUT nocopy VARCHAR2,
    x_msg_count         OUT nocopy NUMBER,
    x_msg_data          OUT nocopy VARCHAR2
    )
  IS
     l_password VARCHAR2(200);
     l_lock_id number;

     /* Bug 6607254 Start */

     l_fName VARCHAR2(150);
     l_lName VARCHAR2(150);
     l_eMail VARCHAR2(2000);
     l_phoneAreaCode VARCHAR2(10);
     l_phone VARCHAR2(40);
     l_phoneExtn VARCHAR2(20);
     l_suppPartyId NUMBER;
     l_contactPartyId NUMBER;
     l_duplicateRow NUMBER ;

     /* Bug 6607254 End  */

BEGIN
   savepoint approve_mult_contact_reqs;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   for i in 1..p_req_id_tbl.COUNT LOOP
      select contact_request_id into l_lock_id from pos_contact_requests
      where contact_request_id = p_req_id_tbl(i) for update nowait;

   END LOOP;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_mult_contact_reqs' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20068, x_msg_data, true);
   END;

   for i in 1..p_req_id_tbl.COUNT LOOP

     /* Bug 6607254 Start */
     /* The Below query selects the details of the contact request like first name,last name,email,phone number */

     SELECT
     PCR.FIRST_NAME,
     PCR.LAST_NAME,
     PCR.EMAIL_ADDRESS,
     PCR.PHONE_AREA_CODE,
     PCR.PHONE_NUMBER,
     PCR.PHONE_EXTENSION,
     PCR.CONTACT_PARTY_ID,
     PSM.PARTY_ID
     INTO
     l_fName,
     l_lName,
     l_eMail,
     l_phoneAreaCode,
     l_phone,
     l_phoneExtn,
     l_contactPartyId,
     l_suppPartyId
     FROM
     POS_CONTACT_REQUESTS PCR,
     POS_SUPPLIER_MAPPINGS PSM
     WHERE CONTACT_REQUEST_ID=p_req_id_tbl(i)
     AND PCR.MAPPING_ID=PSM.MAPPING_ID;

     /* Below query checks for the duplicate contacts */

     SELECT Count(*) INTO l_duplicateRow
     FROM   HZ_PARTIES HPC,
       HZ_CONTACT_POINTS HCPP,
       HZ_CONTACT_POINTS HCPE,
       HZ_RELATIONSHIPS HR
       WHERE  HR.SUBJECT_ID = l_suppPartyId
       AND HCPP.OWNER_TABLE_NAME (+)  = 'HZ_PARTIES'
       AND HCPP.OWNER_TABLE_ID (+)  = HR.PARTY_ID
       AND HCPP.PHONE_LINE_TYPE (+)  = 'GEN'
       AND HCPP.CONTACT_POINT_TYPE (+)  = 'PHONE'
       AND HCPE.OWNER_TABLE_NAME (+)  = 'HZ_PARTIES'
       AND HCPE.OWNER_TABLE_ID (+)  = HR.PARTY_ID
       AND HCPE.CONTACT_POINT_TYPE (+)  = 'EMAIL'
       AND HR.OBJECT_ID = HPC.PARTY_ID
       AND HR.SUBJECT_TYPE = 'ORGANIZATION'
       AND HR.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
       AND HR.OBJECT_TABLE_NAME = 'HZ_PARTIES'
       AND HR.OBJECT_TYPE = 'PERSON'
       AND HR.RELATIONSHIP_CODE = 'CONTACT'
       AND HR.DIRECTIONAL_FLAG = 'B'
       AND HR.RELATIONSHIP_TYPE = 'CONTACT'
       AND ((HPC.PERSON_FIRST_NAME IS NULL
             AND l_fName IS NULL )
             OR UPPER(HPC.PERSON_FIRST_NAME) = Upper(l_fName))
       AND ((HPC.PERSON_LAST_NAME IS NULL
             AND l_lName IS NULL )
             OR UPPER(HPC.PERSON_LAST_NAME) = Upper(l_lName))
       AND ((HCPP.PHONE_AREA_CODE IS NULL
             AND l_phoneAreacODE IS NULL )
             OR UPPER(HCPP.PHONE_AREA_CODE) = Upper(l_phoneAreacODE))
       AND ((HCPP.PHONE_NUMBER IS NULL
             AND l_phone IS NULL )
             OR UPPER(HCPP.PHONE_NUMBER) = Upper(l_phone))
       AND ((HCPP.PHONE_EXTENSION IS NULL
             AND l_phoneExtn IS NULL )
             OR UPPER(HCPP.PHONE_EXTENSION) = Upper(l_phoneExtn))
       AND ((HCPE.EMAIL_ADDRESS IS NULL
             AND l_eMail IS NULL )
             OR UPPER(HCPE.EMAIL_ADDRESS) = Upper(l_eMail))
       AND (l_contactPartyId IS NULL
             OR l_contactPartyId <> HPC.PARTY_ID)
       AND ROWNUM < 2;

       IF l_duplicateRow=1 THEN
          x_return_status := 'D';
          x_msg_data:=p_req_id_tbl(i);
          rollback to approve_mult_contact_reqs;
          RETURN;
       END IF ;

      /*
         In the above if condition we are checking for duplicate contact
	 entries.If we find any duplicate contact entries then rollback
	 the changes and return from the pl/sql procedure .We put
	 ContactRequestID into x_msg_data put parameter.This we want to
	 get the First Name,Last Name of the contact .The return status
	 is 'D' .
      */

      /* Bug 6607254 End */

      approve_contact_req
        (p_request_id       => p_req_id_tbl(i),
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
	 x_password         => l_password
         );
      IF x_return_status IS NULL
        OR x_return_status <> fnd_api.g_ret_sts_success THEN
	 rollback to approve_mult_contact_reqs;
         RETURN;
      END IF;
   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_mult_contact_reqs' , x_msg_data);
      END IF;
      rollback to approve_mult_contact_reqs;
      raise_application_error(-20067, x_msg_data, true);

END approve_mult_contact_reqs;

PROCEDURE approve_mult_bus_class_reqs
  ( p_req_id_tbl        IN  po_tbl_number,
    x_return_status     OUT nocopy VARCHAR2,
    x_msg_count         OUT nocopy NUMBER,
    x_msg_data          OUT nocopy VARCHAR2
    )
  IS
 l_lock_id number;
BEGIN
   savepoint approve_mult_bus_class_reqs;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   for i in 1..p_req_id_tbl.COUNT LOOP

   select bus_class_request_id into l_lock_id from pos_bus_class_reqs
   where bus_class_request_id =  p_req_id_tbl(i) for update nowait;

   END LOOP;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_mult_bus_class_reqs' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20049, x_msg_data, true);
   END;

   for i in 1..p_req_id_tbl.COUNT LOOP
      approve_bus_class_req
        (p_request_id       => p_req_id_tbl(i),
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
         );
      IF x_return_status IS NULL
        OR x_return_status <> fnd_api.g_ret_sts_success THEN
	 rollback to approve_mult_bus_class_reqs;
         RETURN;
      END IF;
   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_mult_bus_class_reqs' , x_msg_data);
      END IF;
      rollback to approve_mult_bus_class_reqs;
      raise_application_error(-20065, x_msg_data, true);

END approve_mult_bus_class_reqs;

PROCEDURE approve_mult_ps_reqs
  ( p_req_id_tbl        IN  po_tbl_number,
    x_return_status     OUT nocopy VARCHAR2,
    x_msg_count         OUT nocopy NUMBER,
    x_msg_data          OUT nocopy VARCHAR2
    )
  IS

 l_lock_id number;

BEGIN
   savepoint approve_mult_ps_reqs;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   for i in 1..p_req_id_tbl.COUNT LOOP

   select ps_request_id into l_lock_id from pos_product_service_requests
   WHERE ps_request_id = p_req_id_tbl(i) for update nowait;

   END LOOP;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_mult_ps_reqs' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20066, x_msg_data, true);
   END;

   for i in 1..p_req_id_tbl.COUNT LOOP
      approve_ps_req
        (p_request_id       => p_req_id_tbl(i),
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
         );
      IF x_return_status IS NULL
        OR x_return_status <> fnd_api.g_ret_sts_success THEN
	 rollback to approve_mult_ps_reqs;
         RETURN;
      END IF;
   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_mult_ps_reqs' , x_msg_data);
      END IF;
      rollback to approve_mult_ps_reqs;
      raise_application_error(-20065, x_msg_data, true);

END approve_mult_ps_reqs;


PROCEDURE approve_update_mult_bc_reqs
  (
    p_pos_bus_rec_tbl   IN  pos_bus_rec_tbl,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
  )
IS
	l_req_id_tbl           po_tbl_number;
        l_lock_id NUMBER;
BEGIN
   savepoint approve_update_mult_bc_reqs;

   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

      for i in 1..p_pos_bus_rec_tbl.COUNT LOOP

	select BUS_CLASS_REQUEST_ID into l_lock_id from pos_bus_class_reqs
	WHERE BUS_CLASS_REQUEST_ID = p_pos_bus_rec_tbl(i).BUS_CLASS_REQUEST_ID for update nowait;

      END LOOP;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_update_mult_bc_reqs' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20064, x_msg_data, true);
   END;

l_req_id_tbl := PO_TBL_NUMBER();

for i in 1..p_pos_bus_rec_tbl.COUNT LOOP

	UPDATE pos_bus_class_reqs
        SET CERTIFICATION_NO = p_pos_bus_rec_tbl(i).CERTIFICATION_NO,
            CERTIFICATION_AGENCY = p_pos_bus_rec_tbl(i).CERTIFICATION_AGENCY,
            EXPIRATION_DATE = p_pos_bus_rec_tbl(i).EXPIRATION_DATE
	WHERE BUS_CLASS_REQUEST_ID = p_pos_bus_rec_tbl(i).BUS_CLASS_REQUEST_ID;

	l_req_id_tbl.extend;
	l_req_id_tbl(i) := p_pos_bus_rec_tbl(i).BUS_CLASS_REQUEST_ID;

END LOOP;

approve_mult_bus_class_reqs
        (p_req_id_tbl       => l_req_id_tbl,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
         );

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'approve_update_mult_bc_reqs' , x_msg_data);
      END IF;
      rollback to approve_update_mult_bc_reqs;
      raise_application_error(-20063, x_msg_data, true);

END approve_update_mult_bc_reqs;


PROCEDURE chg_address_req_approval
  (p_request_id    	IN NUMBER,
   p_party_site_name 	IN VARCHAR2,
   p_country 		IN VARCHAR2,
   p_address_line1	IN VARCHAR2,
   p_address_line2	IN VARCHAR2,
   p_address_line3	IN VARCHAR2,
   p_address_line4	IN VARCHAR2,
   p_city		IN VARCHAR2,
   p_county		IN VARCHAR2,
   p_state		IN VARCHAR2,
   p_province		IN VARCHAR2,
   p_postal_code	IN VARCHAR2,
   p_phone_area_code 	IN VARCHAR2,
   p_phone_number 	IN VARCHAR2,
   p_fax_area_code 	IN VARCHAR2,
   p_fax_number 	IN VARCHAR2,
   p_email_address	IN VARCHAR2,
   p_rfq_flag  		IN VARCHAR2,
   p_pay_flag  		IN VARCHAR2,
   p_pur_flag  		IN VARCHAR2,
   p_status             IN VARCHAR2,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   )
IS

l_step              NUMBER;
l_party_site_id     HZ_PARTY_SITES.party_site_id%TYPE;
l_lock_id           NUMBER;

BEGIN

   savepoint chg_address_req_approval;
   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN
    select ADDRESS_REQUEST_ID into l_lock_id from POS_ADDRESS_REQUESTS
    WHERE ADDRESS_REQUEST_ID = p_request_id for update nowait;
   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'chg_address_req_approval' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20061, x_msg_data, true);
   END;

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_step := 1;

UPDATE POS_ADDRESS_REQUESTS
SET PARTY_SITE_NAME = p_party_site_name,
COUNTRY = p_country,
ADDRESS_LINE1 = p_address_line1,
ADDRESS_LINE2 = p_address_line2,
ADDRESS_LINE3 = p_address_line3,
ADDRESS_LINE4 = p_address_line4,
CITY = p_city,
COUNTY = p_county,
STATE = p_state,
PROVINCE = p_province,
POSTAL_CODE = p_postal_code,
PHONE_AREA_CODE = p_phone_area_code,
PHONE_NUMBER = p_phone_number,
FAX_AREA_CODE = p_fax_area_code,
FAX_NUMBER = p_fax_number,
EMAIL_ADDRESS = p_email_address,
RFQ_FLAG = p_rfq_flag,
PAY_FLAG = p_pay_flag,
PUR_FLAG = p_pur_flag,
last_update_date = Sysdate,
last_updated_by = fnd_global.user_id,
last_update_login = fnd_global.login_id
WHERE ADDRESS_REQUEST_ID = p_request_id;

l_step := 2;

approve_address_req
        (p_request_id       => p_request_id,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data
        );

l_step := 3;

-- The following code below supports address removal and
-- incase during the change request itself the user
-- decides to inactivate the address.

if p_status = 'I' then

  select party_site_id
  into l_party_site_id
  from pos_address_requests
  where address_request_id = p_request_id;

  l_step := 4;

  POS_PROFILE_PKG.remove_address (
    p_party_site_id  => l_party_site_id
   , x_status        => x_return_status
   , x_exception_msg => x_msg_data
  );

end if;

l_step := 5;

EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_STATUS  :='E';
      x_msg_data := x_msg_data || ' Failure at step ' || l_step;
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'chg_address_req_approval' , x_msg_data);
      END IF;
      rollback to chg_address_req_approval;
      raise_application_error(-20015, x_msg_data, true);

END chg_address_req_approval;

FUNCTION format_address(
 p_address_line1		IN VARCHAR2 DEFAULT NULL,
 p_address_line2		IN VARCHAR2 DEFAULT NULL,
 p_address_line3		IN VARCHAR2 DEFAULT NULL,
 p_address_line4		IN VARCHAR2 DEFAULT NULL,
 p_addr_city			IN VARCHAR2 DEFAULT NULL,
 p_addr_postal_code		IN VARCHAR2 DEFAULT NULL,
 p_addr_state			IN VARCHAR2 DEFAULT NULL,
 p_addr_province		IN VARCHAR2 DEFAULT NULL,
 p_addr_county			IN VARCHAR2 DEFAULT NULL,
 p_addr_country			IN VARCHAR2 DEFAULT NULL
 )RETURN VARCHAR2
 IS
     l_return_status		VARCHAR2(1);
     l_msg_count		NUMBER;
     l_msg_data			NUMBER;
     l_formatted_address	VARCHAR2(360);

     l_tbl_cnt			NUMBER;
     l_tbl			HZ_FORMAT_PUB.string_tbl_type;

BEGIN

 HZ_FORMAT_PUB.format_address (
        p_line_break            => ' ',
	p_address_line_1	=> p_address_line1,
	p_address_line_2	=> p_address_line2,
	p_address_line_3	=> p_address_line3,
	p_address_line_4	=> p_address_line4,
	p_city			=> p_addr_city,
	p_postal_code		=> p_addr_postal_code,
	p_state			=> p_addr_state,
	p_province		=> p_addr_province,
	p_county		=> p_addr_county,
	p_country		=> p_addr_country,
   	-- output parameters
   	x_return_status		=> l_return_status,
   	x_msg_count		=> l_msg_count,
   	x_msg_data		=> l_msg_data,
   	x_formatted_address	=> l_formatted_address,
   	x_formatted_lines_cnt	=> l_tbl_cnt,
   	x_formatted_address_tbl	=> l_tbl
 );

 RETURN l_formatted_address;

 EXCEPTION
     WHEN OTHERS THEN
       RETURN l_formatted_address;
END format_address;


PROCEDURE chg_contact_req_approval
(  p_request_id    	IN NUMBER,
   p_contact_title  	IN VARCHAR2,
   p_first_name		IN VARCHAR2,
   p_middle_name 	IN VARCHAR2,
   p_last_name		IN VARCHAR2,
   p_alt_contact_name   IN VARCHAR2,
   p_job_title		IN VARCHAR2,
   p_department         IN VARCHAR2,
   p_email_address	IN VARCHAR2,
   p_url                IN VARCHAR2,
   p_phone_area_code 	IN VARCHAR2,
   p_phone_number 	IN VARCHAR2,
   p_phone_extension  	IN VARCHAR2,
   p_alt_area_code      IN VARCHAR2,
   p_alt_phone_number   IN VARCHAR2,
   p_fax_area_code 	IN VARCHAR2,
   p_fax_number 	IN VARCHAR2,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
)
IS
	l_password VARCHAR2(200);
        l_lock_id number;
BEGIN
   savepoint chg_contact_req_approval;

   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN
    select CONTACT_REQUEST_ID into l_lock_id from POS_CONTACT_REQUESTS
    WHERE CONTACT_REQUEST_ID = p_request_id for update nowait;
   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'chg_contact_req_approval' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20061, x_msg_data, true);
   END;

x_return_status := FND_API.G_RET_STS_SUCCESS;


UPDATE POS_CONTACT_REQUESTS
SET CONTACT_TITLE = p_contact_title,
FIRST_NAME = p_first_name,
MIDDLE_NAME = p_middle_name,
LAST_NAME = p_last_name,
JOB_TITLE = p_job_title,
DEPARTMENT=p_department,
EMAIL_ADDRESS = p_email_address,
PHONE_AREA_CODE = p_phone_area_code,
PHONE_NUMBER = p_phone_number,
PHONE_EXTENSION = p_phone_extension,
FAX_AREA_CODE = p_fax_area_code,
FAX_NUMBER = p_fax_number,
ALT_CONTACT_NAME = p_alt_contact_name,
ALT_AREA_CODE    = p_alt_area_code,
ALT_PHONE_NUMBER = p_alt_phone_number,
URL              = p_url,
last_update_date = Sysdate,
last_updated_by = fnd_global.user_id,
last_update_login = fnd_global.login_id
WHERE CONTACT_REQUEST_ID = p_request_id;

approve_contact_req
        (p_request_id       => p_request_id,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
	 x_password         => l_password
         );

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'chg_contact_req_approval' , x_msg_data);
      END IF;
      rollback to chg_contact_req_approval;
      raise_application_error(-20060, x_msg_data, true);

END chg_contact_req_approval;

PROCEDURE reject_mult_cont_addr_reqs
(     p_cont_req_id       IN  NUMBER,
      p_req_id_tbl        IN  po_tbl_number,
      x_return_status     OUT nocopy VARCHAR2,
      x_msg_count         OUT nocopy NUMBER,
      x_msg_data          OUT nocopy VARCHAR2
)
IS

l_lock_id number;

BEGIN

   savepoint reject_mult_cont_addr_reqs;

   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   for i in 1..p_req_id_tbl.COUNT LOOP

    select CONT_ADDR_REQUEST_ID into l_lock_id from pos_cont_addr_requests
    WHERE PARTY_SITE_ID = p_req_id_tbl(i)
    and REQUEST_STATUS = 'PENDING'
    and CONTACT_REQ_ID = p_cont_req_id for update nowait;

   END LOOP;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_mult_cont_addr_reqs' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20059, x_msg_data, true);
   END;

   for i in 1..p_req_id_tbl.COUNT LOOP

   UPDATE pos_cont_addr_requests
      SET request_status = 'REJECTED'
   WHERE PARTY_SITE_ID = p_req_id_tbl(i)
   and REQUEST_STATUS = 'PENDING'
   and CONTACT_REQ_ID = p_cont_req_id;

   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'reject_mult_cont_addr_reqs' , x_msg_data);
      END IF;
      rollback to reject_mult_cont_addr_reqs;
      raise_application_error(-20058, x_msg_data, true);

END reject_mult_cont_addr_reqs;

PROCEDURE new_contact_req_approval
(  p_request_id    	IN NUMBER,
   p_contact_title  	IN VARCHAR2,
   p_first_name		IN VARCHAR2,
   p_middle_name 	IN VARCHAR2,
   p_last_name		IN VARCHAR2,
   p_job_title		IN VARCHAR2,
   p_email_address	IN VARCHAR2,
   p_phone_area_code 	IN VARCHAR2,
   p_phone_number 	IN VARCHAR2,
   p_phone_extension  	IN VARCHAR2,
   p_fax_area_code 	IN VARCHAR2,
   p_fax_number 	IN VARCHAR2,
   p_create_user_acc 	IN VARCHAR2,
   p_user_name 		IN VARCHAR2,
   x_user_id 	   OUT nocopy NUMBER,
   x_cont_party_id OUT nocopy NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2,
   p_inactive_date IN DATE DEFAULT NULL,
   p_department    IN VARCHAR2 DEFAULT NULL,
   p_alt_contact_name IN VARCHAR2 DEFAULT NULL,
   p_alt_area_code IN VARCHAR2 DEFAULT NULL,
   p_alt_phone_number IN VARCHAR2 DEFAULT NULL,
   p_url IN VARCHAR2 DEFAULT NULL
)
IS
	l_password VARCHAR2(200);
        l_lock_id number;
BEGIN

   savepoint new_contact_req_approval;

   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN
    select CONTACT_REQUEST_ID into l_lock_id from POS_CONTACT_REQUESTS
    WHERE CONTACT_REQUEST_ID = p_request_id for update nowait;
   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'new_contact_req_approval' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20058, x_msg_data, true);
   END;

x_return_status := FND_API.G_RET_STS_SUCCESS;
x_user_id := -1 ;
x_cont_party_id := -1 ;
UPDATE POS_CONTACT_REQUESTS
SET CONTACT_TITLE = p_contact_title,
FIRST_NAME = p_first_name,
MIDDLE_NAME = p_middle_name,
LAST_NAME = p_last_name,
JOB_TITLE = p_job_title,
DEPARTMENT = p_department,
EMAIL_ADDRESS = p_email_address,
PHONE_AREA_CODE = p_phone_area_code,
PHONE_NUMBER = p_phone_number,
PHONE_EXTENSION = p_phone_extension,
FAX_AREA_CODE = p_fax_area_code,
FAX_NUMBER = p_fax_number,
ALT_CONTACT_NAME = p_alt_contact_name,
ALT_AREA_CODE    = p_alt_area_code,
ALT_PHONE_NUMBER = p_alt_phone_number,
URL              = p_url,
CREATE_USER_ACCOUNT = p_create_user_acc
WHERE CONTACT_REQUEST_ID = p_request_id;

approve_contact_req
        (p_request_id       => p_request_id,
         p_user_name 	    => p_user_name,
         x_return_status    => x_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
	 x_password         => l_password,
	 p_inactive_date    => p_inactive_date
         );

IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
   rollback to new_contact_req_approval;
   RETURN;
END IF;

if p_create_user_acc = 'Y' then

SELECT fu.user_id,fu.PERSON_PARTY_ID
into x_user_id, x_cont_party_id
FROM fnd_user fu, pos_contact_requests pcr
WHERE pcr.CONTACT_PARTY_ID = fu.PERSON_PARTY_ID
and pcr.contact_request_id = p_request_id;

ELSE
select pcr.CONTACT_PARTY_ID
into x_cont_party_id
from pos_contact_requests pcr
where pcr.contact_request_id = p_request_id;

end if;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'new_contact_req_approval' , x_msg_data);
      END IF;
      rollback to new_contact_req_approval;
      raise_application_error(-20057, x_msg_data, true);

END new_contact_req_approval;


PROCEDURE assign_mult_address_to_contact
  (  p_site_id_tbl        IN  po_tbl_number,
     p_cont_party_id 	 IN  NUMBER,
     p_vendor_id	 IN  NUMBER,
     x_return_status     OUT nocopy VARCHAR2,
     x_msg_count         OUT nocopy NUMBER,
     x_msg_data          OUT nocopy VARCHAR2
     )
  IS
BEGIN
   for i in 1..p_site_id_tbl.COUNT LOOP
      pos_supplier_address_pkg.assign_address_to_contact
                 (p_contact_party_id  => p_cont_party_id,
                  p_org_party_site_id => p_site_id_tbl(i),
                  p_vendor_id         => p_vendor_id,
                  x_return_status     => x_return_status,
                  x_msg_count         => x_msg_count,
                  x_msg_data          => x_msg_data
            );
      IF x_return_status IS NULL
        OR x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;
   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
END assign_mult_address_to_contact;

PROCEDURE assign_user_sec_attr
  (  p_req_id_tbl        IN  po_tbl_number,
     p_usr_id 		 IN  NUMBER,
     p_code_name	 IN  VARCHAR2,
     x_return_status     OUT nocopy VARCHAR2,
     x_msg_count         OUT nocopy NUMBER,
     x_msg_data          OUT nocopy VARCHAR2
     )
  IS
BEGIN
   for i in 1..p_req_id_tbl.COUNT LOOP
POS_USER_ADMIN_PKG.CreateSecAttr
        (p_user_id       	=> p_usr_id,
         p_attribute_code	=> p_code_name,
         p_app_id	 	=> 177,
         p_number_value  	=> p_req_id_tbl(i)
         );
END LOOP;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
END assign_user_sec_attr;

PROCEDURE update_addr_req_status
  (p_request_id    IN  NUMBER,
   p_party_site_id IN  NUMBER,
   p_req_status	 IN  VARCHAR2,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   )
  IS

  l_lock_id number;
  cursor l_cont_addr_cur is
  select address_req_id from pos_cont_addr_requests
  where address_req_id = p_request_id for update nowait;
  l_cont_addr_rec l_cont_addr_cur%ROWTYPE;

BEGIN
   savepoint update_addr_req_status;

   -- Lock the rows: This is done as part of ECO 5209555
   BEGIN

   select address_request_id into l_lock_id from pos_address_requests
   WHERE address_request_id = p_request_id for update nowait;

   open l_cont_addr_cur;
   fetch l_cont_addr_cur into l_cont_addr_rec;
   close l_cont_addr_cur;

   EXCEPTION

    WHEN OTHERS THEN
      x_return_status :='E';
      x_msg_data := 'Cannot lock the rows';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'update_addr_req_status' , ' Cannot lock the rows ');
      END IF;
      raise_application_error(-20056, x_msg_data, true);
   END;

   UPDATE pos_address_requests
     SET request_status = p_req_status,
     PARTY_SITE_ID = p_party_site_id,
     last_update_date = Sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
   WHERE address_request_id = p_request_id;

   UPDATE pos_cont_addr_requests
     SET party_site_id = p_party_site_id,
     last_update_date = Sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
   WHERE address_req_id = p_request_id
     AND request_status = 'PENDING'
     AND party_site_id IS NULL;

    -- Inform banking that the address request now has a party site.
    if p_request_id is not null and p_party_site_id is not null then
        POS_SBD_PKG.sbd_handle_address_apv(
          p_address_request_id => p_request_id
        , p_party_site_id      => p_party_site_id
        , x_status        => x_return_status
        , x_exception_msg => x_msg_data
        );
    end if;

   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status :='E';
      IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement, g_module || '.' || 'update_addr_req_status' , x_msg_data);
      END IF;
      rollback to update_addr_req_status;
      raise_application_error(-20055, x_msg_data, true);

END update_addr_req_status;

PROCEDURE get_ou_count
(
	x_ou_count      OUT nocopy NUMBER,
	x_return_status OUT nocopy VARCHAR2,
	x_msg_count     OUT nocopy NUMBER,
	x_msg_data      OUT nocopy VARCHAR2
)
IS
     l_ou_ids            pos_security_profile_utl_pkg.number_table;
BEGIN
     pos_security_profile_utl_pkg.get_current_ous (l_ou_ids, x_ou_count);
     x_return_status := fnd_api.g_ret_sts_success;
END get_ou_count ;

PROCEDURE upd_address_to_contact_rel
(    p_mapping_id        IN  NUMBER,
     p_cont_party_id     IN  NUMBER,
     p_cont_req_id       IN  NUMBER,
     p_addr_req_id       IN  NUMBER,
     p_party_site_id     IN  NUMBER,
     p_request_type      IN  VARCHAR2,
     x_return_status     OUT nocopy VARCHAR2,
     x_msg_data     	 OUT nocopy VARCHAR2
)
is
   l_count     NUMBER;
   l_rec_req_type	VARCHAR2(10);
   cursor req_rec_exists(p_mapping_id IN NUMBER,p_cont_party_id IN NUMBER, p_cont_req_id IN NUMBER,p_addr_req_id IN NUMBER,p_party_site_id IN NUMBER, p_req_type IN VARCHAR2)
   is
   select cont_addr_request_id
   from pos_cont_addr_requests
   where mapping_id = p_mapping_id
   and nvl(contact_party_id, -1) = nvl(p_cont_party_id, -1)
   and nvl(contact_req_id, -1) = nvl(p_cont_req_id, -1)
   and nvl(ADDRESS_REQ_ID, -1) = nvl(p_addr_req_id, -1)
   and request_type = p_req_type
   and request_status = 'PENDING'
   and nvl(party_site_id, -1) in
        (
                select party_site_id
                from hz_party_sites
                where location_id in
                        (
                                select location_id
                                from hz_party_sites
                                where party_site_id = nvl(p_party_site_id, -1)
                        )
        ) FOR UPDATE NOWAIT;
   l_req_rec_exists_rec req_rec_exists%ROWTYPE;
begin

x_return_status := 'N';
if(p_request_type = 'DELETE') then
	l_rec_req_type := 'ADD';
elsif(p_request_type = 'ADD') then
	l_rec_req_type := 'DELETE';
end if;

  open req_rec_exists(p_mapping_id, p_cont_party_id, p_cont_req_id, p_addr_req_id, p_party_site_id, l_rec_req_type);
  LOOP
  fetch req_rec_exists into l_req_rec_exists_rec;
  EXIT WHEN req_rec_exists%NOTFOUND;
  x_return_status := 'Y';
  update pos_cont_addr_requests
        set request_status = 'DELETED'
        where cont_addr_request_id = l_req_rec_exists_rec.cont_addr_request_id;
  END LOOP;
  close req_rec_exists;

  EXCEPTION

        WHEN OTHERS THEN
          x_return_status :='E';
          x_msg_data := 'Cannot lock the rows';
          IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string(fnd_log.level_statement, g_module || '.' || 'Manage Address' , ' Cannot lock the rows ');
          END IF;
          raise_application_error(-20086, x_msg_data, true);

END upd_address_to_contact_rel;

FUNCTION get_cont_req_id(
    p_contact_party_id                    IN NUMBER
 ) RETURN NUMBER
 IS
 l_cont_req_id	NUMBER;
 BEGIN
 select contact_request_id
 into l_cont_req_id
 from pos_contact_requests
 where contact_party_id = p_contact_party_id
 and request_status = 'PENDING';

 return l_cont_req_id ;
 EXCEPTION
    WHEN OTHERS THEN
    	RETURN -1 ;
 END;

END pos_profile_change_request_pkg;

/
