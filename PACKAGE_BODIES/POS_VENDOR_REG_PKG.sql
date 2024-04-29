--------------------------------------------------------
--  DDL for Package Body POS_VENDOR_REG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_VENDOR_REG_PKG" AS
/* $Header: POSVREGB.pls 120.30.12010000.40 2013/12/21 11:15:11 spapana ship $ */

g_module VARCHAR2(30) := 'POS_VENDOR_REG_PKG';

TYPE username_pwd_rec IS RECORD
  (user_name fnd_user.user_name%TYPE,
   password VARCHAR2(200),
   exist_in_oid VARCHAR2(1)
   );

TYPE username_pwd_tbl IS TABLE OF username_pwd_rec INDEX BY BINARY_INTEGER;

-- Note: this procedure will lock the supplier reg row
--
PROCEDURE lock_supplier_reg_row
  (p_supplier_reg_id  IN NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   x_supplier_reg_rec OUT NOCOPY pos_supplier_registrations%ROWTYPE
   )
  IS
     CURSOR l_cur IS
        SELECT *
          FROM pos_supplier_registrations
          WHERE supplier_reg_id = p_supplier_reg_id FOR UPDATE;
BEGIN
   OPEN l_cur;
   FETCH l_cur INTO x_supplier_reg_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_SUPPLIER_REG_INVALID_ID');
      fnd_message.set_token('SUPPLIER_REG_ID', p_supplier_reg_id);
      fnd_msg_pub.ADD;

      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
           (fnd_log.level_error
            , g_module || '.lock_supplier_reg_row'
            , 'can not lock supplier reg row with id ' || p_supplier_reg_id);
      END IF;
    ELSE
      FETCH l_cur INTO x_supplier_reg_rec;
      CLOSE l_cur;
      x_return_status := fnd_api.g_ret_sts_success;
   END IF;

   fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);

END lock_supplier_reg_row;

PROCEDURE check_bus_class
  (p_supplier_reg_id IN  NUMBER,
   p_bus_class_code  IN  VARCHAR2,
   x_found           OUT nocopy VARCHAR2,
   x_ext_attr_1      OUT nocopy VARCHAR2
   )
  IS
     CURSOR l_cur IS
        SELECT ext_attr_1
          FROM pos_bus_class_reqs pbcr
          , pos_supplier_mappings psm
          , pos_supplier_registrations psr
          WHERE psm.supplier_reg_id = psr.supplier_reg_id
            AND psr.supplier_reg_id = p_supplier_reg_id
            AND pbcr.mapping_id = psm.mapping_id
            AND pbcr.request_type = 'ADD'
            AND pbcr.request_status = 'PENDING'
            AND pbcr.lookup_type = 'POS_BUSINESS_CLASSIFICATIONS'
            AND pbcr.lookup_code = p_bus_class_code;
BEGIN
   x_found := 'N';

   OPEN l_cur;
   FETCH l_cur INTO x_ext_attr_1;
   IF l_cur%found THEN
      x_found := 'Y';
    ELSE
      x_found := 'N';
   END IF;
   CLOSE l_cur;
END check_bus_class;

PROCEDURE save_duns_number
  (p_vendor_id     IN  NUMBER,
   p_duns_number   IN  VARCHAR2,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   )
  IS
     l_org_rec   hz_party_v2pub.organization_rec_type;
     l_party_rec hz_party_v2pub.party_rec_type;

     CURSOR l_cur IS
        SELECT party_id, object_version_number
          FROM hz_parties
         WHERE party_id =
               (SELECT party_id
                FROM ap_suppliers
               WHERE vendor_id = p_vendor_id);

     l_rec        l_cur%ROWTYPE;
     l_profile_id NUMBER;
BEGIN
   IF p_duns_number IS NULL THEN
      x_return_status := fnd_api.g_ret_sts_success;
      RETURN;
   END IF;

   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count := 1;
      x_msg_data := 'can not find party for vendor ' || p_vendor_id;
      RETURN;
   END IF;
   CLOSE l_cur;

   l_party_rec.party_id    := l_rec.party_id;
   l_org_rec.party_rec     := l_party_rec;
   l_org_rec.duns_number_c := p_duns_number;

   hz_party_v2pub.update_organization
     (p_init_msg_list               => fnd_api.g_false,
      p_organization_rec            => l_org_rec,
      p_party_object_version_number => l_rec.object_version_number,
      x_profile_id                  => l_profile_id,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data
      );
END save_duns_number;

PROCEDURE create_vendor_and_party
  (p_supplier_reg_rec  IN  pos_supplier_registrations%ROWTYPE,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   x_vendor_id         OUT NOCOPY NUMBER,
   x_party_id          OUT NOCOPY NUMBER
   )
  IS
     l_step         VARCHAR2(100);
     l_method       VARCHAR2(100);
     l_vendor_rec   ap_vendor_pub_pkg.r_vendor_rec_type;
     l_found        VARCHAR2(1);
     l_ext_attr_1   pos_bus_class_reqs.ext_attr_1%TYPE;
     CURSOR l_vendor_cur IS
        SELECT vendor_id
          FROM ap_suppliers
          WHERE vendor_id = x_vendor_id;
     l_number NUMBER;
/* Added for bug 7366321 */
   l_hzprofile_value   varchar2(20);
   l_hzprofile_changed varchar2(1) := 'N';
/* End */

BEGIN
   l_method := 'create_vendor_and_party';
   x_return_status := fnd_api.g_ret_sts_error;
   x_msg_count := 0;
   x_msg_data := NULL;

    FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data
        );

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_procedure
         , g_module || '.' || l_method
         , 'start');
   END IF;

   l_step := 'set HZ_GENERATE_PARTY_NUMBER profile to Y';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;
/* Added for bug 7366321 */
    l_hzprofile_value := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');
    if nvl(l_hzprofile_value, 'Y') = 'N' then
      fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'Y');
      l_hzprofile_changed := 'Y';
    end if;
/* End */

   -- not sure if the next line is still necessary
   -- generate party numbers from a sequence,
   -- rather than having to supply them.
/*  commented for bug 7366321
   fnd_profile.put('HZ_GENERATE_PARTY_NUMBER','Y');
*/

   l_step := 'fnd_msg_pub.initialize';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   l_step := 'prepare l_vendor_rec';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   l_vendor_rec.vendor_name       := p_supplier_reg_rec.supplier_name;
   l_vendor_rec.segment1          := p_supplier_reg_rec.supplier_number;
   l_vendor_rec.jgzz_fiscal_code  := p_supplier_reg_rec.taxpayer_id;
   l_vendor_rec.tax_reference     := p_supplier_reg_rec.tax_registration_number;
   l_vendor_rec.start_date_active := Sysdate;

   /* Begin Supplier Hub: Supplier Management
      Added code to pass the party id from Supplier reg table
      to Vendor Record. This is to avoid creation of party
      again during the Reg approval time.
      As per the Supplier hub changes, a party will be created by
      Buyer Admin during Registration review */

   l_vendor_rec.party_id     := p_supplier_reg_rec.vendor_party_id;

   /* End Supplier Hub: Supplier Management  */

   /* Begin Supplier Hub: Bug 11071248
    * The following 4 fields are introduced for supplier registration in
    * Supplier Hub, and need to be copied to suppliers table during approval.
    */

   l_vendor_rec.vendor_name_alt         := p_supplier_reg_rec.supplier_name_alt;
   l_vendor_rec.vendor_type_lookup_code := p_supplier_reg_rec.supplier_type;
   l_vendor_rec.sic_code                := p_supplier_reg_rec.standard_industry_class;
   l_vendor_rec.ni_number               := p_supplier_reg_rec.ni_number;

   /* End Supplier Hub: Bug 11071248 */

   -- The following is commented as we are not sure if this is correct
   -- IF p_supplier_reg_rec.taxpayer_id IS NOT NULL THEN
   --    l_vendor_rec.federal_reportable_flag := 'Y';
   -- END IF;

   l_step := 'check minority group lookup code';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   check_bus_class
     ( p_supplier_reg_id => p_supplier_reg_rec.supplier_reg_id,
       p_bus_class_code  => 'MINORITY_OWNED',
       x_found           => l_found,
       x_ext_attr_1      => l_ext_attr_1
       );

   IF l_found = 'Y' THEN
      l_vendor_rec.minority_group_lookup_code := l_ext_attr_1;
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step || ' l_found is ' || l_found);
   END IF;

   l_step := 'check women owned';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   check_bus_class
     ( p_supplier_reg_id => p_supplier_reg_rec.supplier_reg_id,
       p_bus_class_code  => 'WOMEN_OWNED',
       x_found           => l_found,
       x_ext_attr_1      => l_ext_attr_1
       );

   IF l_found = 'Y' THEN
      l_vendor_rec.women_owned_flag := 'Y';
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step || ' l_found is ' || l_found);
   END IF;

   l_step := 'check small business';

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step || ' l_found is ' || l_found);
   END IF;

   check_bus_class
     ( p_supplier_reg_id => p_supplier_reg_rec.supplier_reg_id,
       p_bus_class_code  => 'SMALL_BUSINESS',
       x_found           => l_found,
       x_ext_attr_1      => l_ext_attr_1
       );

   IF l_found = 'Y' THEN
      l_vendor_rec.small_business_flag := 'Y';
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step || ' l_found is ' || l_found);
   END IF;

   l_step := 'call pos_vendor_pub_pkg.create_vendor';

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   pos_vendor_pub_pkg.create_vendor
     ( p_vendor_rec     => l_vendor_rec,
       x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       x_vendor_id      => x_vendor_id,
       x_party_id       => x_party_id
       );
/* Added for bug 7366321 */
     if nvl(l_hzprofile_changed,'N') = 'Y' then
       fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', l_hzprofile_value);
       l_hzprofile_changed := 'N';
     end if;
/* End */

   IF x_return_status IS NULL OR
      x_return_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF x_vendor_id IS NULL THEN
      raise_application_error(-20001, 'create_vendor returns NULL vendor_id, error msg: ' || x_msg_data, true);
   END IF;

   IF x_party_id IS NULL THEN
      raise_application_error(-20001, 'create_vendor returns NULL party_id, error msg: ' || x_msg_data, true);
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , 'create_vendor call result: x_return_status ' || x_return_status
         || ' x_msg_count ' || x_msg_count
         || ' x_msg_data ' || x_msg_data
         );
   END IF;

   IF x_return_status = fnd_api.g_ret_sts_success THEN

      OPEN l_vendor_cur;
      FETCH l_vendor_cur INTO l_number;
      IF l_vendor_cur%notfound THEN
         CLOSE l_vendor_cur;
         RAISE no_data_found;
      END IF;
      CLOSE l_vendor_cur;

      -- save duns number collected during registration
      -- since right now the vendor creation api does not take
      -- duns number for vendor as input parameter
      save_duns_number
        (p_vendor_id     => l_number,
         p_duns_number   => p_supplier_reg_rec.duns_number,
         x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data
         );

      IF x_return_status IS NULL OR
         x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;

      l_step := 'update pos_supplier_mappings with ids';
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
           (fnd_log.level_statement
            , g_module || '.' || l_method
            , l_step || ' x_return_status ' || x_return_status
            || ' x_msg_count ' || x_msg_count
            || ' x_msg_data ' || x_msg_data
            );
      END IF;

      UPDATE pos_supplier_mappings
        SET vendor_id = x_vendor_id,
            party_id  = x_party_id,
            last_updated_by = fnd_global.user_id,
            last_update_date = Sysdate,
            last_update_login = fnd_global.login_id
       WHERE supplier_reg_id = p_supplier_reg_rec.supplier_reg_id;


    /* Begin Supplier Hub: Supplier Management
       Following update will transfer the attachments
       entered by supplier during registration time
       to supplier entity upon approval
     */
      l_step := 'assign registered supplier attachments to approved supplier';

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string
             (fnd_log.level_statement
              , g_module || '.' || l_method
              , l_step);
      END IF;

      UPDATE fnd_attached_documents
      SET entity_name = 'PO_VENDORS',
          pk1_value = x_vendor_id,
          last_updated_by = fnd_global.user_id,
          last_update_date = Sysdate,
          last_update_login = fnd_global.login_id
      WHERE entity_name = 'POS_SUPP_REG' and
            pk1_value = p_supplier_reg_rec.supplier_reg_id;


 l_step := 'set party_usage_code SUPPLIER_PROSPECT as inactive';

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string
             (fnd_log.level_statement
              , g_module || '.' || l_method
              , l_step);
      END IF;

      UPDATE hz_party_usg_assignments
         SET effective_end_date=sysdate,
             status_flag = 'I',
             last_updated_by = fnd_global.user_id,
             last_update_date = Sysdate,
             last_update_login = fnd_global.login_id
       WHERE party_id= x_party_id
             and party_usage_code='SUPPLIER_PROSPECT';


     /* End Supplier Hub: Supplier Management */

      l_step := 'update pos_supplier_registrations with ids';

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
           (fnd_log.level_statement
            , g_module || '.' || l_method
            , l_step);
      END IF;

      UPDATE pos_supplier_registrations
        SET registration_status = 'APPROVED',
            po_vendor_id = x_vendor_id,
            vendor_party_id = x_party_id,
            last_updated_by = fnd_global.user_id,
            last_update_date = Sysdate,
            last_update_login = fnd_global.login_id
       WHERE supplier_reg_id = p_supplier_reg_rec.supplier_reg_id;

      x_return_status := fnd_api.g_ret_sts_success;

   END IF;

EXCEPTION
   WHEN OTHERS THEN

/* Added for bug 7366321 */
      if nvl(l_hzprofile_changed,'N') = 'Y' then
       fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', l_hzprofile_value);
       l_hzprofile_changed := 'N';
      end if;
  /* End */

      x_return_status := fnd_api.g_ret_sts_error;
      raise_application_error (-20003, sqlerrm, true);

END create_vendor_and_party;

PROCEDURE create_supplier_addrs_sites
  (p_supplier_reg_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   ) IS
      CURSOR l_cur IS
         SELECT par.address_request_id
           FROM pos_address_requests par
              , pos_supplier_mappings psm
          WHERE par.request_type = 'ADD'
            AND par.request_status = 'PENDING'
            AND par.mapping_id = psm.mapping_id
            AND psm.supplier_reg_id = p_supplier_reg_id;

BEGIN
   FOR l_rec IN l_cur LOOP
      pos_profile_change_request_pkg.approve_address_req
        (p_request_id     => l_rec.address_request_id,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data
         );
      IF x_return_status IS NULL OR
         x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;
   END LOOP;

   x_return_status := fnd_api.g_ret_sts_success;

END create_supplier_addrs_sites;

PROCEDURE create_supplier_contacts
  (p_supplier_reg_id  IN  NUMBER,
   x_return_status    OUT nocopy VARCHAR2,
   x_msg_count        OUT nocopy NUMBER,
   x_msg_data         OUT nocopy VARCHAR2,
   x_username_pwds    OUT nocopy username_pwd_tbl
   )
  IS


/*
   Supplier Hub : Supplier Managment Changes :
   Modified where clause to pick up  request_type 'ADD_PARTY_CONTACT also
*/
     CURSOR l_cur IS
        SELECT pcr.contact_request_id, pcr.email_address,
               psm.vendor_id, create_user_account
        FROM pos_contact_requests pcr
            , pos_supplier_mappings psm
        WHERE (pcr.request_type = 'ADD'
            OR pcr.request_type = 'ADD_PARTY_CONTACT')
         AND pcr.request_status = 'PENDING'
          AND pcr.mapping_id = psm.mapping_id
          AND psm.supplier_reg_id = p_supplier_reg_id;

     l_counter NUMBER;

     CURSOR l_user_cur (p_user_name IN VARCHAR2) IS
        SELECT user_id
          FROM fnd_user
          WHERE user_name = Upper(p_user_name);

     l_user_id NUMBER;

     CURSOR l_reg_type_cur IS
	SELECT registration_type
	  FROM pos_supplier_registrations
	 WHERE supplier_reg_id = p_supplier_reg_id;

     l_reg_type_rec l_reg_type_cur%ROWTYPE;

     l_pon_def_also VARCHAR2(1);

     l_temp_password VARCHAR2(200);

     l_user_in_oid        VARCHAR2(1);

BEGIN
   l_counter := 0;

   FOR l_rec IN l_cur LOOP

      if (l_rec.create_user_account = 'Y' and
      FND_USER_PKG.TestUserName(Upper(l_rec.email_address)) = FND_USER_PKG.USER_SYNCHED) then
        l_user_in_oid := 'Y';
      else
        l_user_in_oid := 'N';
      end if;

      l_temp_password := NULL;

      pos_profile_change_request_pkg.approve_contact_req
        (p_request_id          => l_rec.contact_request_id,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data,
         x_password            => l_temp_password
         );

      IF x_return_status IS NULL OR
         x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;

      IF l_rec.create_user_account = 'Y' THEN
	 -- save the username and password to the return table
	 l_counter := l_counter + 1;
	 x_username_pwds(l_counter).user_name := Upper(l_rec.email_address);
	 x_username_pwds(l_counter).password := l_temp_password;
         x_username_pwds(l_counter).exist_in_oid := l_user_in_oid;

	 -- assign default responsibilities for the new user account
	 OPEN l_user_cur (l_rec.email_address);
	 FETCH l_user_cur INTO l_user_id;

	 IF l_user_cur%notfound THEN
	    CLOSE l_user_cur;
	  ELSE
	    CLOSE l_user_cur;

	    l_pon_def_also := 'N';

	    OPEN l_reg_type_cur;
	    FETCH l_reg_type_cur INTO l_reg_type_rec;
	    IF l_reg_type_cur%found AND
	      l_reg_type_rec.registration_type = 'ONBOARD_SRC' THEN
	       l_pon_def_also := 'Y';
	    END IF;
	    CLOSE l_reg_type_cur;

	    pos_user_admin_pkg.assign_vendor_reg_def_resp
	      (p_user_id         => l_user_id,
	       p_vendor_id       => l_rec.vendor_id,
	       p_pon_def_also    => l_pon_def_also,
	       x_return_status   => x_return_status,
	       x_msg_count       => x_msg_count,
	       x_msg_data        => x_msg_data
	       );

	    IF x_return_status IS NULL OR
	      x_return_status <> fnd_api.g_ret_sts_success THEN
	       RETURN;
	    END IF;
	 END IF;
      END IF;
   END LOOP;

   x_return_status := fnd_api.g_ret_sts_success;

END create_supplier_contacts;

PROCEDURE create_bus_class
  (p_supplier_reg_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS
     CURSOR l_cur IS
        SELECT pbcr.bus_class_request_id
          FROM pos_bus_class_reqs pbcr
             , pos_supplier_mappings psm
         WHERE pbcr.request_type = 'ADD'
           AND pbcr.request_status = 'PENDING'
           AND pbcr.mapping_id = psm.mapping_id
           AND psm.supplier_reg_id = p_supplier_reg_id;

BEGIN

   FOR l_rec IN l_cur LOOP
      pos_profile_change_request_pkg.approve_bus_class_req
        (p_request_id     => l_rec.bus_class_request_id,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data
         );
      IF x_return_status IS NULL OR
         x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;
   END LOOP;

   x_return_status := fnd_api.g_ret_sts_success;

END create_bus_class;

PROCEDURE create_product_service
  (p_supplier_reg_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS
     CURSOR l_cur IS
        SELECT ppsr.ps_request_id
          FROM pos_product_service_requests ppsr
             , pos_supplier_mappings psm
         WHERE ppsr.request_type = 'ADD'
           AND ppsr.request_status = 'PENDING'
           AND ppsr.mapping_id = psm.mapping_id
           AND psm.supplier_reg_id = p_supplier_reg_id;

BEGIN

   FOR l_rec IN l_cur LOOP
      pos_profile_change_request_pkg.approve_ps_req
        (p_request_id     => l_rec.ps_request_id,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data
         );
      IF x_return_status IS NULL OR
         x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;
   END LOOP;

   x_return_status := fnd_api.g_ret_sts_success;

END create_product_service;

PROCEDURE get_reg_primary_user
  (p_supplier_reg_id IN  NUMBER,
   x_user_name       OUT nocopy VARCHAR2,
   x_user_id         OUT nocopy NUMBER
   )
  IS
     CURSOR l_cur IS
        SELECT fu.user_name, fu.user_id
          FROM pos_contact_requests pcr, fnd_user fu
          WHERE pcr.mapping_id =
                (SELECT mapping_id
                   FROM pos_supplier_mappings
                   WHERE supplier_reg_id = p_supplier_reg_id
                 )
            AND pcr.request_status = 'APPROVED'
            AND pcr.do_not_delete = 'Y'
            AND fu.user_name = Upper(pcr.email_address);

BEGIN
   OPEN l_cur;
   FETCH l_cur INTO x_user_name, x_user_id;
   CLOSE l_cur;
END get_reg_primary_user;


PROCEDURE notify_banking_approver
  (p_vendor_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2)
  IS
     l_itemtype  wf_items.item_type%TYPE;
     l_itemkey   wf_items.item_key%TYPE;
     l_receiver  wf_roles.name%TYPE;
     l_count NUMBER;

BEGIN
      SELECT Count(pagr.ACCOUNT_REQUEST_ID)
         INTO l_count
          FROM POS_ACNT_GEN_REQ pagr,pos_supplier_mappings psm
         WHERE pagr.mapping_id = psm.mapping_id
           AND psm.vendor_id = p_vendor_id;


     IF l_count>0 THEN
     pos_spm_wf_pkg1.notify_bank_aprv_supp_aprv
           (p_vendor_id => p_vendor_id,
            x_itemtype        => l_itemtype,
            x_itemkey         => l_itemkey,
	        x_receiver        => l_receiver
            ) ;
      IF x_return_status IS NULL OR
         x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;
   END IF;
   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count := 1;
      x_msg_data := Sqlerrm;

END notify_banking_approver;

PROCEDURE notify_supplier_approved
  (p_supplier_reg_id IN  NUMBER,
   p_username_pwds   IN  username_pwd_tbl,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS
     l_itemtype  wf_items.item_type%TYPE;
     l_itemkey   wf_items.item_key%TYPE;
     l_count     NUMBER;
     l_user_name fnd_user.user_name%TYPE;
     l_user_id   NUMBER;
     L_EMAIL_ADDRESS pos_contact_requests.email_address%type;
     l_process  wf_process_activities.process_name%TYPE;
     l_receiver wf_roles.name%TYPE;
     l_enterprise_name hz_parties.party_name%TYPE;
     l_display_name wf_roles.display_name%TYPE;
     l_status VARCHAR2(2);
     l_msg    VARCHAR2(1000);

BEGIN

   get_reg_primary_user
     (p_supplier_reg_id => p_supplier_reg_id,
      x_user_name       => l_user_name,
      x_user_id         => l_user_id
      );

   /* Primary Contact ER Start */
   /*
   IF l_user_name IS NULL THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 1;
      x_msg_data := 'can not find the primary supplier user';
      RETURN;
   END IF;
   */
   /* Primary Contact ER End   */

   l_count := p_username_pwds.COUNT;
   FOR l_index IN 1..l_count LOOP
      IF p_username_pwds(l_index).user_name <> l_user_name THEN
        if (p_username_pwds(l_index).exist_in_oid = 'Y') then
         pos_spm_wf_pkg1.notify_user_approved_sso_sync
           (p_supplier_reg_id => p_supplier_reg_id,
            p_username => p_username_pwds(l_index).user_name,
            x_itemtype => l_itemtype,
            x_itemkey  => l_itemkey
            ) ;
	else
         pos_spm_wf_pkg1.notify_supplier_user_approved
           (p_supplier_reg_id => p_supplier_reg_id,
            p_username => p_username_pwds(l_index).user_name,
            p_password => p_username_pwds(l_index).password,
            x_itemtype => l_itemtype,
            x_itemkey  => l_itemkey
            ) ;
        end if;
       ELSE
        if (p_username_pwds(l_index).exist_in_oid = 'Y') then
         pos_spm_wf_pkg1.notify_supplier_apprv_ssosync
           (p_supplier_reg_id => p_supplier_reg_id,
            p_username        => p_username_pwds(l_index).user_name,
            x_itemtype        => l_itemtype,
            x_itemkey         => l_itemkey
            ) ;
	else
         pos_spm_wf_pkg1.notify_supplier_approved
           (p_supplier_reg_id => p_supplier_reg_id,
            p_username        => p_username_pwds(l_index).user_name,
            p_password        => p_username_pwds(l_index).password,
            x_itemtype        => l_itemtype,
            x_itemkey         => l_itemkey
            ) ;
        end if;
      END IF;
   END LOOP;

   IF l_user_name IS NULL THEN
   pos_spm_wf_pkg1.notify_supp_appr_no_user_acc
     (p_supplier_reg_id => p_supplier_reg_id,
      x_itemtype        => l_itemtype,
      x_itemkey         => l_itemkey,
      x_receiver        => l_receiver
      );
   END IF;

   x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count := 1;
      x_msg_data := Sqlerrm;

END notify_supplier_approved;

-- Begin Supplier Hub: Supplier Management
-- Procedure to update from prospective supplier UDAs to registered supplier UDAs
PROCEDURE update_supplier_reg_uda
  (p_supplier_reg_id IN NUMBER,
   p_party_id        IN NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   )
  IS

  CURSOR l_cur IS
    SELECT par.address_request_id, par.party_site_id
    FROM pos_address_requests par,
         pos_supplier_mappings psm
    WHERE par.request_type = 'ADD'
      AND par.mapping_id = psm.mapping_id
      AND par.party_site_id IS NOT NULL
      AND psm.supplier_reg_id = p_supplier_reg_id;

  l_supp_level_id         NUMBER;
  l_supp_addr_level_id    NUMBER;

BEGIN

  -- get the data level id's

  SELECT data_level_id
    INTO l_supp_level_id
    FROM ego_data_level_b
   WHERE application_id = 177
     AND attr_group_type = 'POS_SUPP_PROFMGMT_GROUP'
     AND data_level_name = 'SUPP_LEVEL';

  SELECT data_level_id
    INTO l_supp_addr_level_id
    FROM ego_data_level_b
   WHERE application_id = 177
     AND attr_group_type = 'POS_SUPP_PROFMGMT_GROUP'
     AND data_level_name = 'SUPP_ADDR_LEVEL';

  -- update party level UDAs

  UPDATE pos_supp_prof_ext_b
     SET is_prospect = 'N',
         party_id = p_party_id
  WHERE is_prospect = 'Y'
    AND party_id = p_supplier_reg_id
    AND data_level_id = l_supp_level_id;

  UPDATE pos_supp_prof_ext_tl
     SET is_prospect = 'N',
         party_id = p_party_id
  WHERE is_prospect = 'Y'
    AND party_id = p_supplier_reg_id
    AND data_level_id = l_supp_level_id;

  -- update party site UDAs

  FOR l_rec IN l_cur LOOP

    UPDATE pos_supp_prof_ext_b
       SET is_prospect = 'N',
           party_id = p_party_id,
           pk1_value = l_rec.party_site_id
    WHERE is_prospect = 'Y'
      AND party_id = p_supplier_reg_id
      AND pk1_value = l_rec.address_request_id
      AND data_level_id = l_supp_addr_level_id;

    UPDATE pos_supp_prof_ext_tl
       SET is_prospect = 'N',
           party_id = p_party_id,
           pk1_value = l_rec.party_site_id
    WHERE is_prospect = 'Y'
      AND party_id = p_supplier_reg_id
      AND pk1_value = l_rec.address_request_id
      AND data_level_id = l_supp_addr_level_id;

  END LOOP;

  x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    x_msg_count := 1;
    x_msg_data := SQLERRM;

END update_supplier_reg_uda;
-- End Supplier Hub: Supplier Management

PROCEDURE approve_supplier_reg
  (p_supplier_reg_id IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
   )
  IS
     l_supplier_reg_rec pos_supplier_registrations%ROWTYPE;
     l_step             VARCHAR2(100);
     l_method           VARCHAR2(30);
     l_vendor_id        NUMBER;
     l_vendor_party_id  NUMBER;
     l_username_pwds    username_pwd_tbl;
     l_user_name        fnd_user.user_name%TYPE;
     l_user_id          NUMBER;
     l_count            NUMBER;

     CURSOR l_ptp_cur(p_party_id IN NUMBER) IS
      SELECT party_tax_profile_id
        FROM zx_party_tax_profile
       WHERE party_id = p_party_id
         AND party_type_code = 'THIRD_PARTY'
         AND ROWNUM = 1;

     l_party_tax_profile_id NUMBER;
BEGIN

   SAVEPOINT approve_supplier_reg;

   l_method := 'approve_supplier';

   x_return_status := fnd_api.g_ret_sts_error;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_procedure
         , g_module || '.' || l_method
         , 'start');
   END IF;

   l_step := 'lock supplier reg row';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   lock_supplier_reg_row
     (p_supplier_reg_id  => p_supplier_reg_id,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      x_supplier_reg_rec => l_supplier_reg_rec
      );

   IF NOT (x_return_status IS NOT NULL
           AND x_return_status = fnd_api.g_ret_sts_success) THEN
      ROLLBACK TO approve_supplier_reg;
      RETURN;
   END IF;

   l_step := 'check reg status';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   IF l_supplier_reg_rec.registration_status IS NULL OR
      l_supplier_reg_rec.registration_status NOT IN ('PENDING_APPROVAL','RIF_SUPPLIER')
     THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_SUPPLIER_REG_NOT_PENDING');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);

      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
           (fnd_log.level_error
            , g_module || '.' || l_method
            , 'status is not PENDING_APPROVAL for reg id ' || p_supplier_reg_id);
      END IF;

      ROLLBACK TO approve_supplier_reg;
      RETURN;
   END IF;

  l_step := 'create vendor and party';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   create_vendor_and_party
     (p_supplier_reg_rec => l_supplier_reg_rec,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      x_vendor_id        => l_vendor_id,
      x_party_id         => l_vendor_party_id
      );

   IF NOT (x_return_status IS NOT NULL
           AND x_return_status = fnd_api.g_ret_sts_success) THEN
      ROLLBACK TO approve_supplier_reg;
      RETURN;
   END IF;

   l_supplier_reg_rec.po_vendor_id := l_vendor_id;
   l_supplier_reg_rec.vendor_party_id := l_vendor_party_id;

   l_step := 'create supplier addresses and vendor sites';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   -- Call eTax API to save tax reg type and tax reg country to party tax profile
   -- if they are collected during registration.
   -- We are doing this because even though TCA party creation API
   -- does create an party tax profile record for a new party,
   -- it does not store tax reg country code and tax reg type
   -- in the record as of 11/29/05 in r12 code line.

   IF l_supplier_reg_rec.tax_reg_country_code IS NOT NULL OR
      l_supplier_reg_rec.tax_reg_type IS NOT NULL OR
      l_supplier_reg_rec.tax_registration_number IS NOT NULL THEN

      OPEN l_ptp_cur(l_vendor_party_id);
      FETCH l_ptp_cur INTO l_party_tax_profile_id;
      IF l_ptp_cur%found THEN
         CLOSE l_ptp_cur;

         zx_party_tax_profile_pkg.update_row
           (p_party_tax_profile_id         => l_party_tax_profile_id,
            p_collecting_authority_flag    => NULL,
            p_provider_type_code           => NULL,
            p_create_awt_dists_type_code   => NULL,
            p_create_awt_invoices_type_cod => NULL,
            p_tax_classification_code      => NULL,
            p_self_assess_flag             => NULL,
            p_allow_offset_tax_flag        => NULL,
            p_rep_registration_number      => l_supplier_reg_rec.tax_registration_number,
            p_effective_from_use_le        => NULL,
            p_record_type_code             => NULL,
            p_request_id                   => NULL,
            p_attribute1                   => NULL,
            p_attribute2                   => NULL,
            p_attribute3                   => NULL,
            p_attribute4                   => NULL,
            p_attribute5                   => NULL,
            p_attribute6                   => NULL,
            p_attribute7                   => NULL,
            p_attribute8                   => NULL,
            p_attribute9                   => NULL,
            p_attribute10                  => NULL,
            p_attribute11                  => NULL,
            p_attribute12                  => NULL,
            p_attribute13                  => NULL,
            p_attribute14                  => NULL,
            p_attribute15                  => NULL,
            p_attribute_category           => NULL,
            p_party_id                     => NULL,
            p_program_login_id             => NULL,
            p_party_type_code              => NULL,
            p_supplier_flag                => NULL,
            p_customer_flag                => NULL,
            p_site_flag                    => NULL,
            p_process_for_applicability_fl => NULL,
            p_rounding_level_code          => NULL,
            p_rounding_rule_code           => NULL,
            p_withholding_start_date       => NULL,
            p_inclusive_tax_flag           => NULL,
            p_allow_awt_flag               => NULL,
            p_use_le_as_subscriber_flag    => NULL,
            p_legal_establishment_flag     => NULL,
            p_first_party_le_flag          => NULL,
            p_reporting_authority_flag     => NULL,
            x_return_status                => x_return_status,
            p_registration_type_code       => l_supplier_reg_rec.tax_reg_type,
            p_country_code                 => l_supplier_reg_rec.tax_reg_country_code
           );
         IF x_return_status IS NULL
           OR x_return_status <> fnd_api.g_ret_sts_success THEN
            ROLLBACK TO approve_supplier_reg;
            x_msg_count := 1;
            x_msg_data := 'call to zx_party_tax_profile_pkg.update_row failed';
            RETURN;
         END IF;
       ELSE
         CLOSE l_ptp_cur;
      END IF;
   END IF;

   create_supplier_addrs_sites
     (p_supplier_reg_id    => l_supplier_reg_rec.supplier_reg_id,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
      );

   IF x_return_status IS NULL
           OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO approve_supplier_reg;
      RETURN;
   END IF;

   l_step := 'create supplier contacts';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   create_supplier_contacts
     (p_supplier_reg_id => l_supplier_reg_rec.supplier_reg_id,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      x_username_pwds   => l_username_pwds
      );

   IF NOT (x_return_status IS NOT NULL
           AND x_return_status = fnd_api.g_ret_sts_success) THEN
      ROLLBACK TO approve_supplier_reg;
      RETURN;
   END IF;

   l_step := 'create supplier business classification';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   create_bus_class
     (p_supplier_reg_id => l_supplier_reg_rec.supplier_reg_id,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data
      );

   IF NOT (x_return_status IS NOT NULL
           AND x_return_status = fnd_api.g_ret_sts_success) THEN
      ROLLBACK TO approve_supplier_reg;
      RETURN;
   END IF;

   l_step := 'create product and services';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   create_product_service
     (p_supplier_reg_id => l_supplier_reg_rec.supplier_reg_id,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data
      );

   IF NOT (x_return_status IS NOT NULL
           AND x_return_status = fnd_api.g_ret_sts_success) THEN
      ROLLBACK TO approve_supplier_reg;
      RETURN;
   END IF;

   l_step := 'handle supplier survey';
   -- to be coded as part of supplier profile survey project
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   l_step := 'notify supplier';

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   notify_supplier_approved
     (p_supplier_reg_id => p_supplier_reg_id,
      p_username_pwds   => l_username_pwds,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data
   );

   IF NOT (x_return_status IS NOT NULL
           AND x_return_status = fnd_api.g_ret_sts_success) THEN
      ROLLBACK TO approve_supplier_reg;
      RETURN;
   END IF;

   -- Notify the banking approvers about the supplier approval
   -- so that they can review the supplier bank accounts. Bug 5299682
   notify_banking_approver
     (p_vendor_id => l_vendor_id,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data
   );

   get_reg_primary_user
     (p_supplier_reg_id => p_supplier_reg_id,
      x_user_name       => l_user_name,
      x_user_id         => l_user_id
      );

   -- Code Added for Business Classification Re-Certification ER to update ap_suppliers table
   -- with the last certification date and last certified by values at the time of supplier approval.

   /* Primary Contact ER Start */

    if l_user_name is not null
   then
   SELECT Count(pbcr.bus_class_request_id)
         INTO l_count
          FROM pos_bus_class_reqs pbcr
             , pos_supplier_mappings psm
         WHERE pbcr.request_type = 'ADD'
           AND pbcr.request_status = 'APPROVED'
           AND pbcr.mapping_id = psm.mapping_id
           AND psm.supplier_reg_id = p_supplier_reg_id;

  IF(l_count>0) THEN
   update ap_suppliers
      set bus_class_last_certified_by = l_user_id,
      bus_class_last_certified_date = (select creation_date
                                      from pos_supplier_registrations
                                      where supplier_reg_id = p_supplier_reg_id ),
      last_updated_by = l_user_id,
      last_update_date = sysdate
      where vendor_id=l_vendor_id;
  END IF;

   -- End of Code added for Business Classification Re-Certification ER


       end if;

   /* Primary Contact ER End   */

   /* Bug 17422416 */

   pon_new_supplier_reg_pkg.src_pos_reg_supplier_callback
     ( x_return_status            => x_return_status,
       x_msg_count                => x_msg_count,
       x_msg_data                 => x_msg_data,
       p_requested_supplier_id    => p_supplier_reg_id,
       p_po_vendor_id             => l_vendor_id,
       p_supplier_hz_party_id     => l_vendor_party_id,
       p_user_id                  => l_user_id
       );


   IF NOT (x_return_status IS NOT NULL
           AND x_return_status = fnd_api.g_ret_sts_success) THEN
      ROLLBACK TO approve_supplier_reg;
      RETURN;
   END IF;

   -- Begin Supplier Hub: Supplier Management
   update_supplier_reg_uda
     (p_supplier_reg_id => p_supplier_reg_id,
      p_party_id        => l_vendor_party_id,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data
      );

   IF NOT (x_return_status IS NOT NULL
           AND x_return_status = fnd_api.g_ret_sts_success) THEN
      ROLLBACK TO approve_supplier_reg;
      RETURN;
   END IF;

   IF (FND_PROFILE.VALUE('POS_SM_ENABLE_SPM_EXTENSION') = 'Y') THEN
      PON_ATTR_MAPPING.Sync_User_Attrs_Data(NULL, l_vendor_id, x_return_status, x_msg_data);
   END IF;

   IF NOT (x_return_status IS NOT NULL
           AND x_return_status = fnd_api.g_ret_sts_success) THEN
      ROLLBACK TO approve_supplier_reg;
      RETURN;
   END IF;
   -- End Supplier Hub: Supplier Management

   x_return_status := fnd_api.g_ret_sts_success;
   x_msg_count := 0;
   x_msg_data := NULL;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO approve_supplier_reg;
      raise_application_error (-20004, 'error in step ' || l_step ||
			       ': ' || Sqlerrm, true);

END approve_supplier_reg;

--- note: when creating rfq only supplier, we will skip business
--- classification and product and service

PROCEDURE reject_supplier_reg
  (p_supplier_reg_id IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
   ) IS
      l_step     VARCHAR2(100);
      l_method   VARCHAR2(30);
      l_itemtype wf_items.item_type%TYPE;
      l_itemkey  wf_items.item_key%TYPE;
      l_receiver fnd_user.user_name%TYPE;

      l_party_usages   number := 0 ;

      l_supplier_reg_rec pos_supplier_registrations%ROWTYPE;
      event_id Number;
      l_notes VARCHAR2(4000);
      l_employeeId NUMBER;
BEGIN
   l_method := 'reject_supplier_reg';

   l_step := 'lock supplier reg row';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   lock_supplier_reg_row
     (p_supplier_reg_id  => p_supplier_reg_id,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      x_supplier_reg_rec => l_supplier_reg_rec
      );

   IF NOT (x_return_status IS NOT NULL
           AND x_return_status = fnd_api.g_ret_sts_success) THEN
      RETURN;
   END IF;

   l_step := 'check reg status';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   IF l_supplier_reg_rec.registration_status IS NULL OR
      l_supplier_reg_rec.registration_status <> 'PENDING_APPROVAL' THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_SUPPLIER_REG_NOT_PENDING');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);

      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
           (fnd_log.level_error
            , g_module || '.' || l_method
            , 'status is not PENDING_APPROVAL for reg id ' || p_supplier_reg_id);
      END IF;

      RETURN;
   END IF;

   UPDATE pos_supplier_registrations
     SET registration_status = 'REJECTED',
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
     WHERE supplier_reg_id = p_supplier_reg_id;

   UPDATE pos_address_requests
     SET request_status = 'REJECTED',
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
     WHERE mapping_id =
          (SELECT mapping_id FROM pos_supplier_mappings
            WHERE supplier_reg_id = p_supplier_reg_id)
       AND request_status = 'PENDING';

   UPDATE pos_contact_requests
     SET request_status = 'REJECTED',
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
     WHERE mapping_id =
          (SELECT mapping_id FROM pos_supplier_mappings
            WHERE supplier_reg_id = p_supplier_reg_id)
       AND request_status = 'PENDING';

   UPDATE pos_cont_addr_requests
     SET request_status = 'REJECTED',
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
     WHERE mapping_id =
          (SELECT mapping_id FROM pos_supplier_mappings
            WHERE supplier_reg_id = p_supplier_reg_id)
       AND request_status = 'PENDING';


   /* Begin Supplier Hub: Supplier Management   */
   /* set the status of the party created to 'I' */

      select count(*)
      into l_party_usages
      from hz_party_usg_assignments
      where party_id = (select vendor_party_id
               from pos_supplier_registrations
               where supplier_reg_id = p_supplier_reg_id);

     if (l_party_usages = 0 ) then

     update hz_parties
     set status = 'I',
     last_update_date = Sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
     where status = 'A' and
           created_by_module = 'POS_SUPPLIER_MGMT' and
     party_id = (select vendor_party_id
               from pos_supplier_registrations
               where supplier_reg_id = p_supplier_reg_id);
     end if;

 /* set party_usage_code SUPPLIER_PROSPECT as inactive */

      UPDATE hz_party_usg_assignments
         SET effective_end_date=sysdate,
             status_flag = 'I',
             last_update_date = Sysdate,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id
       WHERE party_id= (select vendor_party_id
               from pos_supplier_registrations
               where supplier_reg_id = p_supplier_reg_id)
             and party_usage_code='SUPPLIER_PROSPECT';

   /* End Supplier Hub: Supplier Management   */

   pos_spm_wf_pkg1.notify_supplier_rejected
     (p_supplier_reg_id => p_supplier_reg_id,
      x_itemtype        => l_itemtype,
      x_itemkey         => l_itemkey,
      x_receiver        => l_receiver
      );
   /* Bug 17331252*/
   -- Update action history
   SELECT NVL(SM_NOTE_TO_SUPPLIER, NOTE_TO_SUPPLIER) INTO l_notes
   FROM POS_SUPPLIER_REGISTRATIONS
   WHERE SUPPLIER_REG_ID = p_supplier_reg_id;
   POS_VENDOR_REG_PKG.get_employeeId(fnd_global.user_id, l_employeeId);
   pos_vendor_reg_pkg.update_reg_action_hist( p_supp_reg_id 	=>  p_supplier_reg_id,
                                            p_action      	=> pos_vendor_reg_pkg.ACTN_REJECT,
											p_note     		=>  l_notes,
                                            p_from_user_id 	=> l_employeeId,
											p_to_user_id 	=> NULL
                                            );
   /* Bug 17331252*/
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
   x_return_status := fnd_api.g_ret_sts_success;
   x_msg_count := 0;
   x_msg_data := NULL;
/* Begin Supplier Hub - Supplier Data Publication */
/* Raise Supplier User Creation event */
    event_id:= pos_appr_rej_supp_event_raise.raise_appr_rej_supp_event('oracle.apps.pos.supplier.rejectsupplier', p_supplier_reg_id, '');

/* End Supplier Hub - Supplier Data Publication */
END reject_supplier_reg;

PROCEDURE submit_supplier_reg
  (p_supplier_reg_id IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
   ) IS

      l_step   VARCHAR2(100);
      l_method VARCHAR2(30);
      l_supplier_reg_rec pos_supplier_registrations%ROWTYPE;
      l_notes VARCHAR2(4000);
      l_employeeId NUMBER;
BEGIN
   l_method := 'submit_supplier_reg';

   l_step := 'lock supplier reg row';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   lock_supplier_reg_row
     (p_supplier_reg_id  => p_supplier_reg_id,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      x_supplier_reg_rec => l_supplier_reg_rec
      );

   IF x_return_status IS NULL
      OR x_return_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
   END IF;

   l_step := 'check reg status';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   IF l_supplier_reg_rec.registration_status IS NULL OR
      (l_supplier_reg_rec.registration_status <> 'DRAFT' AND
       l_supplier_reg_rec.registration_status <> 'RIF_SUPPLIER')
   THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('POS','POS_SUPPLIER_REG_NOT_DRAFT');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(fnd_api.g_false, x_msg_count, x_msg_data);

      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
           (fnd_log.level_error
            , g_module || '.' || l_method
            , 'status is not DRAFT for reg id ' || p_supplier_reg_id);
      END IF;

      RETURN;
   END IF;

   IF (FND_PROFILE.VALUE('POS_SM_ENABLE_SPM_EXTENSION') = 'Y') THEN
   UPDATE pos_supplier_registrations
     SET registration_status = 'PENDING_APPROVAL',
         SM_NOTE_TO_SUPPLIER = NULL, -- -- Reject Reason ER : when request is submitted, nullify SM_NOTE_TO_SUPPLIER/NOTE_TO_SUPPLIER
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
     WHERE supplier_reg_id = p_supplier_reg_id;

   SELECT SM_NOTE_TO_BUYER
    INTO l_notes
   FROM pos_supplier_registrations
   WHERE supplier_reg_id = p_supplier_reg_id;
   ELSE
    UPDATE pos_supplier_registrations
     SET registration_status = 'PENDING_APPROVAL',
         NOTE_TO_SUPPLIER = NULL,
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
    WHERE supplier_reg_id = p_supplier_reg_id;
    SELECT NOTE_FROM_SUPPLIER
      INTO l_notes
    FROM pos_supplier_registrations
    WHERE supplier_reg_id = p_supplier_reg_id;
   END IF;

   pos_spm_wf_pkg1.send_supplier_reg_submit_ntf
     (p_supplier_reg_id => p_supplier_reg_id);

   get_employeeId(fnd_global.user_id, l_employeeId);
   insert_reg_action_hist( p_supp_reg_id => p_supplier_reg_id,
                          p_action      => ACTN_SUBMIT,
                          p_from_user_id => l_employeeId,
                          p_to_user_id => NULL,
                          p_note        => l_notes,
                          p_approval_group_id => NULL
                        );

   x_return_status := fnd_api.g_ret_sts_success;
   x_msg_count := 0;
   x_msg_data := NULL;

END submit_supplier_reg;

PROCEDURE reopen_supplier_reg
  (p_supplier_reg_id IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
   )
IS

l_step     VARCHAR2(100);
l_method   VARCHAR2(30);
l_party_usages   number := 0 ;
l_supplier_reg_rec pos_supplier_registrations%ROWTYPE;
l_employeeId NUMBER;
isAmeEnabled          VARCHAR2(1);

BEGIN

   --pos_spm_wf_pkg1.send_supplier_reg_reopen_ntf (p_supplier_reg_id => p_supplier_reg_id);

   l_method := 'reopen_supplier_reg';

   l_step := 'lock supplier reg row';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   lock_supplier_reg_row
     (p_supplier_reg_id  => p_supplier_reg_id,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      x_supplier_reg_rec => l_supplier_reg_rec
      );

   IF NOT (x_return_status IS NOT NULL
           AND x_return_status = fnd_api.g_ret_sts_success) THEN
      RETURN;
   END IF;

   l_step := 'updating request tables';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
   END IF;

   UPDATE pos_supplier_registrations
     SET registration_status = 'DRAFT',
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
     WHERE supplier_reg_id = p_supplier_reg_id
     AND registration_status = 'REJECTED';

   UPDATE pos_address_requests
     SET request_status = 'PENDING',
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
     WHERE mapping_id =
          (SELECT mapping_id FROM pos_supplier_mappings
            WHERE supplier_reg_id = p_supplier_reg_id)
       AND request_status = 'REJECTED';

   UPDATE pos_contact_requests
     SET request_status = 'PENDING',
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
     WHERE mapping_id =
          (SELECT mapping_id FROM pos_supplier_mappings
            WHERE supplier_reg_id = p_supplier_reg_id)
       AND request_status = 'REJECTED';

   UPDATE pos_cont_addr_requests
     SET request_status = 'PENDING',
         last_update_date = Sysdate,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.login_id
     WHERE mapping_id =
          (SELECT mapping_id FROM pos_supplier_mappings
            WHERE supplier_reg_id = p_supplier_reg_id)
       AND request_status = 'REJECTED';


    l_step := 'updating hz_party_usg_assignments, hz_parties';
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string
          (fnd_log.level_statement
          , g_module || '.' || l_method
          , l_step);
    END IF;

   /* Begin Supplier Hub: Supplier Management   */
   /* set the status of the party created to 'A' */

      select count(*)
      into l_party_usages
      from hz_party_usg_assignments
      where party_id = (select vendor_party_id
               from pos_supplier_registrations
               where supplier_reg_id = p_supplier_reg_id);

     if (l_party_usages <> 0 ) then

     update hz_parties
     set status = 'A',
     last_update_date = Sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
     where status = 'I' and
           created_by_module = 'POS_SUPPLIER_MGMT' and
     party_id = (select vendor_party_id
               from pos_supplier_registrations
               where supplier_reg_id = p_supplier_reg_id);
     end if;

 /* set party_usage_code SUPPLIER_PROSPECT as active */

      UPDATE hz_party_usg_assignments
         SET effective_end_date=sysdate,
             status_flag = 'A',
             last_update_date = Sysdate,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id
       WHERE party_id= (select vendor_party_id
               from pos_supplier_registrations
               where supplier_reg_id = p_supplier_reg_id)
             and party_usage_code='SUPPLIER_PROSPECT';

   /* End Supplier Hub: Supplier Management   */

   -- Make all approver status to null so that when we call getnextapprover during register action, it gives all approver once again.
   POS_SUPP_APPR.CHECK_IF_AME_ENABLED  ( result => isAmeEnabled  );
   IF(isAmeEnabled = 'Y') THEN
      ame_api2.clearAllApprovals( applicationIdIn=>177, transactionTypeIn=>'POS_SUPP_APPR', transactionIdIn=>p_supplier_reg_id);
   END IF;
   -- Insert record to action history with action DRAFT
   get_employeeId(fnd_global.user_id, l_employeeId);
   insert_reg_action_hist( p_supp_reg_id => p_supplier_reg_id,
                          p_action      => ACTN_SAVE,
                          p_from_user_id => l_employeeId,
                          p_to_user_id => NULL,
                          p_note        => NULL,
                          p_approval_group_id => NULL
                        );

   x_return_status := fnd_api.g_ret_sts_success;
   x_msg_count := 0;
   x_msg_data := NULL;

END reopen_supplier_reg;

PROCEDURE send_supplier_reg_link
  (p_supplier_reg_id IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
   )
IS

BEGIN

   pos_spm_wf_pkg1.send_supplier_reg_link_ntf (p_supplier_reg_id => p_supplier_reg_id);

   x_return_status := fnd_api.g_ret_sts_success;
   x_msg_count := 0;
   x_msg_data := NULL;

END send_supplier_reg_link;
PROCEDURE send_save_for_later_ntf
  (p_supplier_reg_id IN  NUMBER,
   p_email_address   IN  VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
   )
IS

  l_employeeId NUMBER;
  l_submitCnt NUMBER;

BEGIN

   pos_spm_wf_pkg1.send_supplier_reg_saved_ntf (p_supplier_reg_id => p_supplier_reg_id);

   -- Update draft action date till it is submitted..

   SELECT Count(1) INTO l_submitCnt
   FROM pos_action_history
   WHERE object_id = p_supplier_reg_id
   AND ACTION_CODE = ACTN_SUBMIT;

   BEGIN
    IF ( l_submitCnt = 0 ) THEN

      get_employeeId(fnd_global.user_id, l_employeeId);
      update_reg_action_hist( p_supp_reg_id =>  p_supplier_reg_id,
                              p_action   =>  ACTN_SAVE,
                              p_note     =>  NULL,
                              p_from_user_id => l_employeeId,
                              p_to_user_id => NULL
                            );

      /*IF sql%rowcount = 0 THEN
        -- no rows were updated, so the record does not exist
        insert_reg_action_hist( p_supp_reg_id => p_supplier_reg_id,
                            p_action      => ACTN_SAVE,
                            p_from_user_id => fnd_global.user_id,
                            p_to_user_id => NULL,
                            p_note        => NULL,
                            p_approval_group_id => NULL
                          );
      END IF; */
    END IF;
   END;

   x_return_status := fnd_api.g_ret_sts_success;
   x_msg_count := 0;
   x_msg_data := NULL;

END send_save_for_later_ntf;

FUNCTION is_ou_id_valid
  (p_ou_id IN NUMBER
   ) RETURN VARCHAR2
  IS

     ln_dup hr_operating_units.organization_id%TYPE;

     CURSOR hou_cur IS
        SELECT organization_id
          FROM   hr_operating_units
          WHERE  organization_id = p_ou_id
          AND    ( date_to IS NULL OR
                   ( date_to > sysdate AND date_to > date_from ) );

BEGIN

   OPEN hou_cur;
   FETCH hou_cur INTO ln_dup;
   IF hou_cur%FOUND THEN
      CLOSE hou_cur;
      RETURN 'Y';
   END IF;
   CLOSE hou_cur;

   RETURN 'N';

END;

FUNCTION is_supplier_number_unique
  (p_supp_regid IN NUMBER,
   p_supp_number IN VARCHAR2
   ) RETURN VARCHAR2
  IS
BEGIN

   IF p_supp_number IS NULL THEN
      RETURN 'N';
   END IF;

   FOR x IN (SELECT supplier_number
      FROM   pos_supplier_registrations
      WHERE  supplier_reg_id <> p_supp_regid
      --AND    registration_status <> 'REJECTED'
      -- the unique key POS_SUPPLIER_REG_U2 is on supplier_number only
      -- without considering the registration_status
      AND    p_supp_number = supplier_number
      AND    ROWNUM < 2
      )
   LOOP
      RETURN 'N';
   END LOOP;

   FOR x IN (SELECT segment1
      FROM   ap_suppliers
      WHERE  segment1 = p_supp_number
      AND ROWNUM < 2
      )
   LOOP
      RETURN 'N';
   END LOOP;

   RETURN 'Y';

END is_supplier_number_unique;

/*Bug 8819829
Modified cursors to check duplicates only based on tax payer id.
Country shoud not be considered for checking duplicates. */

PROCEDURE is_taxpayer_id_unique(
  p_supp_regid IN NUMBER
, p_taxpayer_id IN VARCHAR2
, p_country IN VARCHAR2
, x_is_unique OUT NOCOPY VARCHAR2
, x_vendor_id OUT NOCOPY NUMBER
)
  IS

     CURSOR supp_reg_cur IS
	SELECT   -1
	  FROM   pos_supplier_registrations psr
	  WHERE  psr.supplier_reg_id <> p_supp_regid
	  AND    psr.taxpayer_id = p_taxpayer_id
	  AND    psr.registration_status = 'PENDING_APPROVAL';

     CURSOR po_vendors_cur IS
	SELECT pv.vendor_id
	  FROM   ap_suppliers pv
	  WHERE  pv.num_1099 = p_taxpayer_id;

BEGIN

   IF p_taxpayer_id IS NULL THEN
      x_is_unique := 'Y';
      x_vendor_id := -1;
      RETURN;
   END IF;

/* Code Change For Bug 9569389 - Start
   Swapping the position of the below cursors inorder to check the po_vendors first */

   OPEN po_vendors_cur;
   FETCH po_vendors_cur INTO x_vendor_id;
   IF po_vendors_cur%FOUND THEN
      CLOSE po_vendors_cur;
      x_is_unique := 'N';
      RETURN;
   END IF;
   CLOSE po_vendors_cur;

   OPEN supp_reg_cur;
   FETCH supp_reg_cur INTO x_vendor_id;
   IF supp_reg_cur%FOUND THEN
      CLOSE supp_reg_cur;
      x_is_unique := 'N';
      RETURN;
   END IF;
   CLOSE supp_reg_cur;

/* Code Change For Bug 9569389 - End */

   x_is_unique := 'Y';
   x_vendor_id := -1;
END is_taxpayer_id_unique;

PROCEDURE is_duns_num_unique(
  p_supp_regid IN NUMBER
, p_duns_num IN VARCHAR2
, x_is_unique OUT NOCOPY VARCHAR2
, x_vendor_id OUT NOCOPY NUMBER
)
IS

     l_party_id hz_parties.party_id%TYPE := -1;

     CURSOR supp_reg_cur IS
        SELECT -1
          FROM   pos_supplier_registrations psr
          WHERE  psr.supplier_reg_id <> p_supp_regid
          AND    psr.duns_number = p_duns_num
	  AND    psr.registration_status = 'PENDING_APPROVAL';

     CURSOR hz_cur IS
        SELECT party_id
	FROM   hz_parties
	WHERE  duns_number_c = p_duns_num
	AND    party_type = 'ORGANIZATION';

     CURSOR po_vendors_cur ( p_party_id hz_parties.party_id%TYPE ) IS
	SELECT vendor_id
	  FROM ap_suppliers
         WHERE party_id = p_party_id;

/*Begin Supplier Data Hub - Supplier Management*/

    CURSOR supp_reg_org_cur ( p_party_id hz_parties.party_id%TYPE ) IS
        SELECT -1
        FROM   pos_supplier_registrations psr
        WHERE  psr.supplier_reg_id = p_supp_regid
        AND    psr.vendor_party_id = p_party_id
        AND    psr.registration_status = 'PENDING_APPROVAL';

  /*End Supplier Data Hub - Supplier Management*/

BEGIN

   IF p_duns_num IS NULL THEN
      x_is_unique := 'Y';
      x_vendor_id := -1;
      RETURN;
   END IF;

   OPEN supp_reg_cur;
   FETCH supp_reg_cur INTO x_vendor_id;
   IF supp_reg_cur%FOUND THEN
      CLOSE supp_reg_cur;
      x_is_unique := 'N';
      RETURN;
   END IF;
   CLOSE supp_reg_cur;

   OPEN hz_cur;
   FETCH hz_cur INTO l_party_id;
   IF hz_cur%NOTFOUND THEN
      CLOSE hz_cur;
      x_is_unique := 'Y';
      x_vendor_id := -1;
      RETURN;
   END IF;
   CLOSE hz_cur;

/*Begin Supplier Data Hub - Supplier Management*/

    OPEN supp_reg_org_cur(l_party_id);
    FETCH supp_reg_org_cur INTO x_vendor_id;
    IF supp_reg_org_cur%FOUND THEN
      CLOSE supp_reg_org_cur;
        x_is_unique := 'Y';
        x_vendor_id := -1;
      RETURN;
    END IF;
    CLOSE supp_reg_org_cur;

    /*End Supplier Data Hub - Supplier Management*/

   OPEN po_vendors_cur(l_party_id);
   FETCH po_vendors_cur INTO x_vendor_id;
   IF po_vendors_cur%NOTFOUND THEN
      CLOSE po_vendors_cur;
      x_is_unique := 'Y';
      x_vendor_id := -1;
      RETURN;
   END IF;
   CLOSE po_vendors_cur;
   x_is_unique := 'N';
   RETURN;

END is_duns_num_unique;

PROCEDURE is_taxregnum_unique(
  p_supp_regid IN NUMBER
, p_taxreg_num IN VARCHAR2
, p_country IN VARCHAR2
, x_is_unique OUT NOCOPY VARCHAR2
, x_vendor_id OUT NOCOPY NUMBER
)
  IS

     CURSOR supp_reg_cur IS
	SELECT -1
	  FROM   pos_supplier_registrations psr
	  WHERE  psr.supplier_reg_id <> p_supp_regid
	  AND    psr.tax_registration_number = p_taxreg_num
	  AND    ((psr.tax_reg_country_code is not null and p_country is not null and psr.tax_reg_country_code = p_country) OR
		    (p_country is null))
	  AND    psr.registration_status = 'PENDING_APPROVAL';

     CURSOR po_vendors_cur IS
	SELECT pv.vendor_id
	  FROM   ap_suppliers pv, zx_party_tax_profile zxpr
	  WHERE  zxpr.party_id = pv.party_id
          AND    zxpr.rep_registration_number = p_taxreg_num
	  AND    ((zxpr.country_code is not null and p_country is not null and zxpr.country_code = p_country) OR
		    (p_country is null));

	  CURSOR po_vendor_sites_cur IS
	     SELECT pvsa.vendor_id
	       FROM   ap_supplier_sites_all pvsa,  zx_party_tax_profile zxpr
	       WHERE  zxpr.rep_registration_number = p_taxreg_num
               AND zxpr.site_flag = 'Y'
	       AND zxpr.party_id = pvsa.party_site_id
	       AND ((zxpr.country_code is not null and p_country is not null and zxpr.country_code = p_country) OR
		    (p_country is null));
BEGIN

   IF p_taxreg_num IS NULL THEN
      x_is_unique := 'Y';
      x_vendor_id := -1;
      RETURN;
   END IF;

   OPEN supp_reg_cur;
   FETCH supp_reg_cur INTO x_vendor_id;
   IF supp_reg_cur%FOUND THEN
      CLOSE supp_reg_cur;
      x_is_unique := 'N';
      RETURN;
   END IF;
   CLOSE supp_reg_cur;

   OPEN po_vendors_cur;
   FETCH po_vendors_cur INTO x_vendor_id;
   IF po_vendors_cur%FOUND THEN
      CLOSE po_vendors_cur;
      x_is_unique := 'N';
      RETURN;
   END IF;
   CLOSE po_vendors_cur;

   OPEN po_vendor_sites_cur;
   FETCH po_vendor_sites_cur INTO x_vendor_id;
   IF po_vendor_sites_cur%FOUND THEN
      CLOSE po_vendor_sites_cur;
      x_is_unique := 'N';
      RETURN;
   END IF;
   CLOSE po_vendor_sites_cur;

   x_is_unique := 'Y';
   x_vendor_id := -1;
END is_taxregnum_unique;

-- Begin Supplier Management: Bug 12849540
/*
 * Return a list of classification codes for a prospective supplier
 */
PROCEDURE get_prospect_class_codes
(   p_supp_reg_id     IN NUMBER,
    x_class_codes_tbl OUT NOCOPY EGO_VARCHAR_TBL_TYPE
)
IS

  l_mapping_id     pos_supplier_mappings.mapping_id%TYPE;
  l_party_id       pos_supplier_registrations.vendor_party_id%TYPE;
  l_supplier_type  pos_supplier_registrations.supplier_type%TYPE;
  l_ps_rec         pos_product_service_requests%ROWTYPE;
  l_segment        pos_product_service_requests.segment1%TYPE;

  l_ps_segment_def    fnd_profile_option_values.profile_option_value%TYPE;
  l_ps_segment_count  NUMBER;
  l_category_set_id   NUMBER;
  l_ps_delimiter      VARCHAR2(1);
  l_ps_code           VARCHAR2(1000);
  l_start             NUMBER;
  l_end               NUMBER;

  TYPE ps_segments_tbl_type IS TABLE OF NUMBER;
  l_ps_segments_tbl ps_segments_tbl_type;

  TYPE ps_code_tbl_type IS TABLE OF NUMBER INDEX BY VARCHAR2(1000);
  l_ps_code_tbl ps_code_tbl_type;


  CURSOR c_mapping_id(p_supp_reg_id IN NUMBER) IS
    SELECT mapping_id
    FROM pos_supplier_mappings
    WHERE supplier_reg_id = p_supp_reg_id;

  CURSOR c_party_id(p_supp_reg_id IN NUMBER) IS
    SELECT vendor_party_id
    FROM pos_supplier_registrations
    WHERE supplier_reg_id = p_supp_reg_id;

  CURSOR c_supplier_type(p_supp_reg_id IN NUMBER) IS
    SELECT supplier_type
    FROM pos_supplier_registrations
    WHERE supplier_reg_id = p_supp_reg_id;

  CURSOR c_bus_class(p_mapping_id IN NUMBER) IS
    SELECT 'BC:' || lookup_code AS code
    FROM pos_bus_class_reqs
    WHERE mapping_id = p_mapping_id;

  CURSOR c_product_service(p_mapping_id IN NUMBER) IS
    SELECT *
    FROM pos_product_service_requests
    WHERE mapping_id = p_mapping_id;

  CURSOR c_tca_class(p_party_id IN NUMBER) IS
    SELECT 'HZ:' || REPLACE(hccr.class_category, ' ', '$')
                 || ':'
                 || hccr.class_code AS code
    FROM hz_class_code_relations hccr,
         (SELECT class_category, class_code, owner_table_id
          FROM hz_code_assignments
          WHERE owner_table_name = 'HZ_PARTIES'
            AND owner_table_id = p_party_id
            AND start_date_active <= SYSDATE
            AND NVL(end_date_active, SYSDATE) >= SYSDATE
            AND status = 'A'
         ) v
    WHERE hccr.class_category = v.class_category
      START WITH hccr.class_code = v.class_code
      CONNECT BY PRIOR hccr.class_code = hccr.sub_class_code
    UNION
    SELECT 'HZ:' || REPLACE(fnd.lookup_type, ' ', '$')
                 || ':'
                 || fnd.lookup_code AS code
    FROM fnd_lookup_values_vl fnd,
         (SELECT class_category, class_code, owner_table_id
          FROM hz_code_assignments
          WHERE owner_table_name = 'HZ_PARTIES'
            AND owner_table_id = p_party_id
            AND start_date_active <= SYSDATE
            AND NVL(end_date_active, SYSDATE) >= SYSDATE
            AND status = 'A'
         ) v
    WHERE fnd.lookup_type = v.class_category
      AND fnd.lookup_code = v.class_code;


BEGIN

  x_class_codes_tbl := EGO_VARCHAR_TBL_TYPE();

  -- Mapping Id
  OPEN c_mapping_id(p_supp_reg_id);
  FETCH c_mapping_id INTO l_mapping_id;
  CLOSE c_mapping_id;

  IF (l_mapping_id IS NULL) THEN
    RETURN;
  END IF;


  -- Common
  x_class_codes_tbl.EXTEND();
  x_class_codes_tbl(x_class_codes_tbl.LAST) := 'BS:BASE';


  -- Supplier Type
  OPEN c_supplier_type(p_supp_reg_id);
  FETCH c_supplier_type INTO l_supplier_type;
  CLOSE c_supplier_type;

  IF (l_supplier_type IS NOT NULL) THEN
    x_class_codes_tbl.EXTEND();
    x_class_codes_tbl(x_class_codes_tbl.LAST) := 'ST:' || l_supplier_type;
  END IF;


  -- Business Classifications
  FOR l_bus_class_rec IN c_bus_class(l_mapping_id) LOOP
    x_class_codes_tbl.EXTEND();
    x_class_codes_tbl(x_class_codes_tbl.LAST) := l_bus_class_rec.code;
  END LOOP;


  -- Products and Services
  pos_product_service_utl_pkg.get_product_meta_data(l_ps_segment_def,
                                                    l_ps_segment_count,
                                                    l_category_set_id,
                                                    l_ps_delimiter);

  -- split l_ps_segment_def to l_ps_segments_tbl
  -- e.g., from 1.2.3.4 to (1, 2, 3, 4)
  l_ps_segments_tbl := ps_segments_tbl_type();
  l_start := 1;
  FOR i IN 1..l_ps_segment_count LOOP
    l_end := INSTR(l_ps_segment_def, '.', 1, i);
    IF (l_end = 0) THEN
      l_end := LENGTH(l_ps_segment_def) + 1;
    END IF;

    l_ps_segments_tbl.EXTEND();
    l_ps_segments_tbl(l_ps_segments_tbl.LAST) :=
      SUBSTR(l_ps_segment_def, l_start, l_end - l_start);

    l_start := l_end + 1;
  END LOOP;

  OPEN c_product_service(l_mapping_id);
  LOOP
    FETCH c_product_service INTO l_ps_rec;
    EXIT WHEN c_product_service%NOTFOUND;

    -- Construct the Products and Services codes, with parent codes
    -- Using the associative array l_ps_code_tbl as a hashset, so no
    -- duplicate is added

    l_ps_code := 'PS:';
    FOR i IN 1..l_ps_segments_tbl.COUNT LOOP

      l_segment := NULL;
      CASE l_ps_segments_tbl(i)
        WHEN  1 THEN l_segment := l_ps_rec.segment1;
        WHEN  2 THEN l_segment := l_ps_rec.segment2;
        WHEN  3 THEN l_segment := l_ps_rec.segment3;
        WHEN  4 THEN l_segment := l_ps_rec.segment4;
        WHEN  5 THEN l_segment := l_ps_rec.segment5;
        WHEN  6 THEN l_segment := l_ps_rec.segment6;
        WHEN  7 THEN l_segment := l_ps_rec.segment7;
        WHEN  8 THEN l_segment := l_ps_rec.segment8;
        WHEN  9 THEN l_segment := l_ps_rec.segment9;
        WHEN 10 THEN l_segment := l_ps_rec.segment10;
        WHEN 11 THEN l_segment := l_ps_rec.segment11;
        WHEN 12 THEN l_segment := l_ps_rec.segment12;
        WHEN 13 THEN l_segment := l_ps_rec.segment13;
        WHEN 14 THEN l_segment := l_ps_rec.segment14;
        WHEN 15 THEN l_segment := l_ps_rec.segment15;
        WHEN 16 THEN l_segment := l_ps_rec.segment16;
        WHEN 17 THEN l_segment := l_ps_rec.segment17;
        WHEN 18 THEN l_segment := l_ps_rec.segment18;
        WHEN 19 THEN l_segment := l_ps_rec.segment19;
        WHEN 20 THEN l_segment := l_ps_rec.segment20;
      END CASE;

      IF (l_segment IS NOT NULL) THEN
        IF (i > 1) THEN
          l_ps_code := l_ps_code || l_ps_delimiter;
        END IF;
        l_ps_code := l_ps_code || l_segment;
        l_ps_code_tbl(l_ps_code) := 1;
      END IF;

    END LOOP; -- l_ps_segments_tbl

  END LOOP;
  CLOSE c_product_service;

  l_ps_code := l_ps_code_tbl.FIRST;
  WHILE l_ps_code IS NOT NULL LOOP
    x_class_codes_tbl.EXTEND();
    x_class_codes_tbl(x_class_codes_tbl.LAST) := l_ps_code;
    l_ps_code := l_ps_code_tbl.NEXT(l_ps_code);
  END LOOP;


  -- General and Industrial Classifications
  OPEN c_party_id(p_supp_reg_id);
  FETCH c_party_id INTO l_party_id;
  CLOSE c_party_id;

  IF (l_party_id IS NOT NULL) THEN
    FOR l_tca_class_rec IN c_tca_class(l_party_id) LOOP
      x_class_codes_tbl.EXTEND();
      x_class_codes_tbl(x_class_codes_tbl.LAST) := l_tca_class_rec.code;
    END LOOP;
  END IF;

END get_prospect_class_codes;

/*
 * Return a list of prospective supplier's required UDA that does not have
 * value, in the following format:
 *
 *   x_attr_req_tbl := EGO_VARCHAR_TBL_TYPE(<page_display_name 1>,
 *                                          <attribute_group_display_name 1>,
 *                                          <attribute_display_name 1>,
 *                                          <page_display_name 2>,
 *                                          <attribute_group_display_name 2>,
 *                                          <attribute_display_name 2>,
 *                                          ...etc...
 *                                          <page_display_name n>,
 *                                          <attribute_group_display_name n>,
 *                                          <attribute_display_name n>);
 */
PROCEDURE validate_required_user_attrs
(   p_supp_reg_id   IN NUMBER,
    p_buyer_user    IN VARCHAR2,
    x_attr_req_tbl  OUT NOCOPY EGO_VARCHAR_TBL_TYPE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
)
IS

  TYPE ext_attr_csr_type IS REF CURSOR;
  TYPE ext_attr_rec_type IS RECORD
  (   page_disp_name        ego_pages_tl.display_name%TYPE,
      attr_group_id         ego_attr_groups_v.attr_group_id%TYPE,
      attr_group_disp_name  ego_attr_groups_v.attr_group_disp_name%TYPE,
      attr_name             ego_attrs_v.attr_name%TYPE,
      attr_disp_name        ego_attrs_v.attr_display_name%TYPE
  );
  TYPE ext_attr_tbl_type IS TABLE OF ext_attr_rec_type;

  TYPE attr_name_list_tbl_type IS TABLE OF VARCHAR2(3000)
    INDEX BY BINARY_INTEGER;

  TYPE has_value_tbl_type IS TABLE OF NUMBER INDEX BY VARCHAR2(100);

  l_object_id               NUMBER;
  l_pages_list              VARCHAR2(4000);
  l_class_codes_tbl         EGO_VARCHAR_TBL_TYPE;
  l_class_codes_list        VARCHAR2(4000);

  l_return_status           VARCHAR2(1);
  l_privileges              VARCHAR2(32767);

  l_ext_attr_query          VARCHAR2(32767);
  l_ext_attr_csr            ext_attr_csr_type;
  l_ext_attr_tbl            ext_attr_tbl_type;
  l_attr_group_id           ego_attr_groups_v.attr_group_id%TYPE;
  l_attr_name               ego_attrs_v.attr_name%TYPE;

  l_attr_name_list_tbl      attr_name_list_tbl_type;
  l_attr_name_list          VARCHAR2(3000);
  l_attr_group_request_tbl  EGO_ATTR_GROUP_REQUEST_TABLE;
  l_attr_group_request_obj  EGO_ATTR_GROUP_REQUEST_OBJ;
  l_pk_column_values        EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_attributes_row_tbl      EGO_USER_ATTR_ROW_TABLE;
  l_attributes_row_obj      EGO_USER_ATTR_ROW_OBJ;
  l_attributes_data_tbl     EGO_USER_ATTR_DATA_TABLE;
  l_errorcode               NUMBER;

  l_has_value_tbl           has_value_tbl_type;


  CURSOR c_pages_list(p_supp_reg_id IN NUMBER, p_buyer_user IN VARCHAR2) IS
    /* Bug 17252777:
     * Possible values for input parameter p_buyer_user are:
     *  Y : Buyer user who has to check all UDA(supplier UDA + Buyer UDA) to be filled in while submitting/registering or approving the request
     *  N : Prospective Supplier who has to check only supplier UDA to be filled in while submitting request
     *  I : Internal Buyer who has to check only buyer UDA(All Buyer UDA minus Supplier UDA) to be filled in.
     *      Noramlly we will have this value when internal buyer transfering the request to supplier via send invitation or RFI publish actions
     */
    SELECT pac.page_id
    FROM pos_attrpg_config pac,
         pos_supplier_registrations psr
    WHERE psr.supplier_reg_id = p_supp_reg_id
      AND pac.org_id IN (-999, psr.ou_id)
      AND DECODE(p_buyer_user, 'Y', pac.internal_update_flag,
                               'N', pac.supplier_update_flag,
                               'I', pac.internal_update_flag) = 'Y'
      AND pac.page_id NOT IN
          (SELECT pac2.page_id
           FROM pos_attrpg_config pac2
           WHERE pac2.org_id = psr.ou_id
             AND DECODE(p_buyer_user, 'Y', pac2.internal_update_flag,
                                      'N', pac2.supplier_update_flag,
                                      'I', pac2.supplier_update_flag) = Decode (p_buyer_user, 'I', 'Y', 'N')
          );

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  l_object_id := EGO_EXT_FWK_PUB.Get_Object_Id_From_Name('HZ_PARTIES');


  -- Pages List
  FOR l_page_rec IN c_pages_list(p_supp_reg_id, p_buyer_user) LOOP
    l_pages_list := l_pages_list || l_page_rec.page_id || ',';
  END LOOP;

  l_pages_list := SUBSTR(l_pages_list, 1, LENGTH(l_pages_list) - 1);

  -- Bug 13956982
  -- If there are no pages, then there is no required UDA to validate.
  IF (l_pages_list IS NULL) THEN
    RETURN;
  END IF;


  -- Classification Codes
  get_prospect_class_codes(p_supp_reg_id, l_class_codes_tbl);

  FOR i IN 1..l_class_codes_tbl.COUNT LOOP
    l_class_codes_list := l_class_codes_list || '''' ||
                          l_class_codes_tbl(i) || ''',';
  END LOOP;

  l_class_codes_list := SUBSTR(l_class_codes_list, 1,
                               LENGTH(l_class_codes_list) - 1);

  -- Bug 15982192
  -- Added support for UDA security
  pos_data_security.get_privileges_prosp(p_supp_reg_id,
                                         fnd_global.user_id,
                                         l_return_status,
                                         l_privileges);
  l_privileges := '''' || REPLACE(l_privileges, ',', ''',''') || '''';

  -- Bug 13953145
  -- Removed the following condition from the below query:
  -- '  AND ag.multi_row_code = ''N'' ' ||

  -- Required Attributes List
  l_ext_attr_query :=
    'SELECT ptl.display_name, ' ||
    '       ag.attr_group_id, ' ||
    '       ag.attr_group_disp_name, ' ||
    '       attr.attr_name, ' ||
    '       attr.attr_display_name ' ||
    'FROM ego_pages_b pb, ' ||
    '     ego_pages_tl ptl, ' ||
    '     ego_page_entries_b pe, ' ||
    '     ego_obj_ag_assocs_b a, ' ||
    '     ego_attr_groups_v ag, ' ||
    '     ego_attrs_v attr, ' ||
    '     ego_attr_group_dl agdl ' ||
    'WHERE ptl.page_id = pb.page_id ' ||
    '  AND ptl.language = USERENV(''LANG'') ' ||
    '  AND pe.page_id = pb.page_id ' ||
    '  AND a.association_id = pe.association_id ' ||
    '  AND a.enabled_flag = ''Y'' ' ||
    '  AND ag.attr_group_id = a.attr_group_id ' ||
    '  AND attr.application_id = ag.application_id ' ||
    '  AND attr.attr_group_type = ag.attr_group_type ' ||
    '  AND attr.attr_group_name = ag.attr_group_name ' ||
    '  AND attr.enabled_flag = ''Y'' ' ||
    '  AND attr.required_flag = ''Y'' ' ||
    '  AND agdl.attr_group_id = ag.attr_group_id ' ||
    '  AND (agdl.edit_privilege_id IS NULL OR ' ||
    '       agdl.edit_privilege_id IN ( ' ||
    '         SELECT function_id ' ||
    '         FROM fnd_form_functions ' ||
    '         WHERE function_name IN (' || l_privileges || ')) ' ||
    '      ) ' ||
    '  AND pb.object_id = ' || l_object_id ||
    '  AND pb.data_level = ''SUPP_LEVEL'' ' ||
    '  AND pb.page_id IN (' || l_pages_list || ') ' ||
    '  AND pb.classification_code IN (' || l_class_codes_list || ') ' ||
    'ORDER BY pb.sequence, pe.sequence, attr.sequence';

  OPEN l_ext_attr_csr FOR l_ext_attr_query;
  FETCH l_ext_attr_csr BULK COLLECT INTO l_ext_attr_tbl;
  CLOSE l_ext_attr_csr;


  -- Build Request Table
  FOR i IN 1..l_ext_attr_tbl.COUNT LOOP
    l_attr_group_id := l_ext_attr_tbl(i).attr_group_id;
    l_attr_name := l_ext_attr_tbl(i).attr_name;

    -- Bug 15982192
    -- Removed the ELSIF condition
    IF (NOT l_attr_name_list_tbl.EXISTS(l_attr_group_id)) THEN
      l_attr_name_list_tbl(l_attr_group_id) := l_attr_name;
    ELSE
      l_attr_name_list_tbl(l_attr_group_id) :=
        l_attr_name_list_tbl(l_attr_group_id) || ',' || l_attr_name;
    END IF;
  END LOOP;

  l_attr_group_request_tbl := EGO_ATTR_GROUP_REQUEST_TABLE();

  l_attr_group_id := l_attr_name_list_tbl.FIRST;
  WHILE l_attr_group_id IS NOT NULL LOOP
    l_attr_name_list := l_attr_name_list_tbl(l_attr_group_id);

    -- Bug 13956982
    -- Due to changes from EGOPEFDB.pls version 120.65.12010000.44 onwards,
    -- need to pass 'Y' instead of '''Y''' for DATA_LEVEL_1 field.
    l_attr_group_request_tbl.EXTEND();
    l_attr_group_request_tbl(l_attr_group_request_tbl.LAST) :=
      EGO_ATTR_GROUP_REQUEST_OBJ(
        l_attr_group_id,  -- ATTR_GROUP_ID
        NULL,             -- APPLICATION_ID
        NULL,             -- ATTR_GROUP_TYPE
        NULL,             -- ATTR_GROUP_NAME
        'SUPP_LEVEL',     -- DATA_LEVEL
        'Y',              -- DATA_LEVEL_1
        NULL,             -- DATA_LEVEL_2
        NULL,             -- DATA_LEVEL_3
        NULL,             -- DATA_LEVEL_4
        NULL,             -- DATA_LEVEL_5
        l_attr_name_list  -- ATTR_NAME_LIST
      );

    l_attr_group_id := l_attr_name_list_tbl.NEXT(l_attr_group_id);
  END LOOP;


  -- Get Attribute Values
  l_pk_column_values :=
    EGO_COL_NAME_VALUE_PAIR_ARRAY(
      EGO_COL_NAME_VALUE_PAIR_OBJ('PARTY_ID', TO_CHAR(p_supp_reg_id))
    );

  EGO_USER_ATTRS_DATA_PVT.Get_User_Attrs_Data
  (   p_api_version                => 1.0,
      p_object_name                => 'HZ_PARTIES',
      p_pk_column_name_value_pairs => l_pk_column_values,
      p_attr_group_request_table   => l_attr_group_request_tbl,
      x_attributes_row_table       => l_attributes_row_tbl,
      x_attributes_data_table      => l_attributes_data_tbl,
      x_return_status              => x_return_status,
      x_errorcode                  => l_errorcode,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RETURN;
  END IF;

  -- If attribute has value, add an entry in l_has_value_tbl
  IF (l_attributes_row_tbl IS NOT NULL AND l_attributes_data_tbl IS NOT NULL)
  THEN
    FOR i IN 1..l_attributes_data_tbl.COUNT LOOP

      IF (l_attributes_data_tbl(i).attr_value_str IS NOT NULL OR
          l_attributes_data_tbl(i).attr_value_num IS NOT NULL OR
          l_attributes_data_tbl(i).attr_value_date IS NOT NULL OR
          l_attributes_data_tbl(i).attr_disp_value IS NOT NULL)
      THEN

        FOR j IN 1..l_attributes_row_tbl.COUNT LOOP

          IF (l_attributes_row_tbl(j).row_identifier =
              l_attributes_data_tbl(i).row_identifier)
          THEN
            l_attr_group_id := l_attributes_row_tbl(j).attr_group_id;
            l_attr_name := l_attributes_data_tbl(i).attr_name;
            l_has_value_tbl(l_attr_group_id || '|' || l_attr_name) := 1;
            EXIT;
          END IF;

        END LOOP; -- l_attributes_row_tbl

      END IF;

    END LOOP; -- l_attributes_data_tbl
  END IF;


  -- Validate Required Attributes
  x_attr_req_tbl := EGO_VARCHAR_TBL_TYPE();

  FOR i IN 1..l_ext_attr_tbl.COUNT LOOP
    l_attr_group_id := l_ext_attr_tbl(i).attr_group_id;
    l_attr_name := l_ext_attr_tbl(i).attr_name;

    IF (NOT l_has_value_tbl.EXISTS(l_attr_group_id || '|' || l_attr_name))
    THEN
      x_attr_req_tbl.EXTEND(3);

      x_attr_req_tbl(x_attr_req_tbl.LAST - 2) :=
        l_ext_attr_tbl(i).page_disp_name;

      x_attr_req_tbl(x_attr_req_tbl.LAST - 1) :=
        l_ext_attr_tbl(i).attr_group_disp_name;

      x_attr_req_tbl(x_attr_req_tbl.LAST) :=
        l_ext_attr_tbl(i).attr_disp_name;
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := SQLERRM;

END validate_required_user_attrs;
-- End Supplier Management: Bug 12849540

PROCEDURE insert_reg_action_hist
(   p_supp_reg_id     IN NUMBER,
    p_action          IN VARCHAR2,
    p_from_user_id     IN VARCHAR2,
    p_to_user_id     IN VARCHAR2,
    p_note            IN VARCHAR2,
    p_approval_group_id IN VARCHAR2
)

IS

l_sequence_num   number := NULL;
l_object_type VARCHAR2(50) := 'PROSPECTIVE';

CURSOR action_hist_cursor(objectId number , objectType varchar2) is
   select max(sequence_num)
   from pos_action_history
   where object_id= objectId and
   object_type = objectType;

BEGIN

   OPEN action_hist_cursor(p_supp_reg_id , l_object_type );
   FETCH action_hist_cursor into l_sequence_num;
   CLOSE action_hist_cursor;

   IF l_sequence_num is NULL THEN
      l_sequence_num := 1;
   ELSE
      l_sequence_num := l_sequence_num +1;
   END IF;

   INSERT into pos_action_history
             (object_id,
              object_type,
              sequence_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              action_code,
              action_date,
              from_user,
              to_user,
              note,
              --object_revision_num,
              last_update_login,
              approval_group_id
              )
             VALUES
             (p_supp_reg_id,
              l_object_type,
              l_sequence_num,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              p_action,
              decode(p_action, '',to_date(null), sysdate),
              p_from_user_id,
              p_to_user_id,
              p_note,
              --l_revision_num,
              fnd_global.login_id,
              p_approval_group_id
              );


END insert_reg_action_hist;


PROCEDURE update_reg_action_hist
(   p_supp_reg_id     IN NUMBER,
    p_action          IN VARCHAR2,
    p_note            IN VARCHAR2,
    p_from_user_id IN VARCHAR2,
    p_to_user_id IN VARCHAR2
)

IS

l_object_type VARCHAR2(50) := 'PROSPECTIVE';

BEGIN


  -----------------------------------------------------------------------
   -- Update the action history record with ACTN_PENDING action code with the
   -- appropriate action code.
   -- Compare the approver id if it is passed in.
   -----------------------------------------------------------------------
  IF (p_from_user_id IS NOT NULL) THEN
    IF p_action = ACTN_SAVE THEN -- Always UPDATE save record with latest timestamp

    UPDATE pos_action_history
       SET action_code = p_action,
           note = p_note,
           action_date = SYSDATE,
           to_user = p_to_user_id
     WHERE object_id = p_supp_reg_id
       AND from_user = p_from_user_id
       AND object_type = l_object_type
       AND action_code IN ( ACTN_SAVE )
       AND rownum =1;
    ELSE
      UPDATE pos_action_history
        SET action_code = p_action,
            note = p_note,
            action_date = SYSDATE,
            to_user = p_to_user_id
      WHERE object_id = p_supp_reg_id
        AND from_user = p_from_user_id
        AND object_type = l_object_type
        AND action_code IN ( ACTN_PENDING )
       AND rownum =1;

    END IF;
    IF sql%rowcount = 0 AND p_action <> ACTN_NO_ACTION THEN
      -- get_employeeId(fnd_global.user_id, l_employeeId);
        -- no rows were updated, so the record does not exist
        insert_reg_action_hist( p_supp_reg_id => p_supp_reg_id,
                                p_action      => p_action,
                                p_from_user_id => p_from_user_id,
                                p_to_user_id => NULL,
                                p_note        => p_note,
                                p_approval_group_id => NULL
                              );
    END IF;

  END IF;

END update_reg_action_hist;

PROCEDURE get_employeeId(p_userId IN NUMBER, p_employeeId IN OUT NOCOPY NUMBER)
IS
BEGIN
  BEGIN
    SELECT employee_id
      INTO p_employeeId
    FROM fnd_user
    WHERE user_id = p_userId
    AND TRUNC(sysdate) BETWEEN start_date AND NVL(end_date, sysdate+1);
  EXCEPTION
  WHEN OTHERS THEN
    p_employeeId := NULL;
  END;
  IF ( p_employeeId IS NULL ) THEN
    p_employeeId := p_userId;
  END IF;
END get_employeeId;
END POS_VENDOR_REG_PKG;

/
