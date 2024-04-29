--------------------------------------------------------
--  DDL for Package Body POS_SUPPLIER_ADDRESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPPLIER_ADDRESS_PKG" AS
/* $Header: POSSAB.pls 120.17.12010000.6 2011/09/20 05:25:34 ramkandu ship $ */

g_module VARCHAR2(30) := 'POS_SUPPLIER_ADDRESS_PKG';

PROCEDURE assign_address_type
  ( p_party_site_id      IN  NUMBER,
    p_address_type       IN  VARCHAR2,
    x_party_site_use_id  OUT nocopy NUMBER,
    x_return_status      OUT nocopy VARCHAR2,
    x_msg_count          OUT nocopy NUMBER,
    x_msg_data           OUT nocopy VARCHAR2
    )
  IS
     CURSOR l_cur IS
        SELECT party_site_use_id
          FROM hz_party_site_uses
         WHERE party_site_id = p_party_site_id
           AND site_use_type = p_address_type
           AND status = 'A';

     l_rec    l_cur%ROWTYPE;
     l_found  BOOLEAN;

     l_party_site_use_rec hz_party_site_v2pub.party_site_use_rec_type;

     l_method VARCHAR(30);
     l_step   VARCHAR2(100);
BEGIN

   l_method := 'assign_address_type';
   -- log_values p_party_site_id p_address_type
   IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement
                      , g_module || '.' || l_method
                      , ' p_party_site_id = ' || p_party_site_id
                      || ' p_address_type = ' || p_address_type
                      );
   END IF;

   l_step := 'check existing address type';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step
         );
   END IF;

   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   l_found := l_cur%found;
   CLOSE l_cur;

   IF l_found THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
           (fnd_log.level_statement
            , g_module || '.' || l_method
            , l_step || ' found an existing record'
         );
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      RETURN;
   ELSE
      l_step := 'call hz_party_site_v2pub.create_party_site_use';

      l_party_site_use_rec.party_site_id     := p_party_site_id;
      l_party_site_use_rec.application_id    := 177;
      l_party_site_use_rec.created_by_module := 'POS_SUPPLIER_MGMT';
      l_party_site_use_rec.status            := 'A';
      l_party_site_use_rec.site_use_type     := p_address_type;

      hz_party_site_v2pub.create_party_site_use
        ( p_init_msg_list        => FND_API.G_FALSE,
          p_party_site_use_rec   => l_party_site_use_rec,
          x_party_site_use_id    => x_party_site_use_id,
          x_return_status        => x_return_status,
          x_msg_count            => x_msg_count,
          x_msg_data             => x_msg_data
          );

      -- log_callresult x_party_site_use_id
      IF x_return_status = FND_API.g_ret_sts_success THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement
                          , g_module || '.' || l_method
                          , l_step || ' x_party_site_use_id = ' || x_party_site_use_id
                          );
         END IF;
      ELSE
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_error
                          , g_module || '.' || l_method
                          , l_step || ': x_return_status = ' || x_return_status
                            || ' x_msg_count = ' || x_msg_count
                            || ', x_msg_data = ' || x_msg_data
                          );
         END IF;
      END IF;
   END IF;
END assign_address_type;

PROCEDURE remove_address_type
  ( p_party_site_id      IN  NUMBER,
    p_address_type       IN  VARCHAR2,
    x_return_status      OUT nocopy VARCHAR2,
    x_msg_count          OUT nocopy NUMBER,
    x_msg_data           OUT nocopy VARCHAR2
    )
  IS
     CURSOR l_cur IS
        SELECT party_site_use_id, object_version_number
          FROM hz_party_site_uses
         WHERE party_site_id = p_party_site_id
           AND site_use_type = p_address_type
           AND status = 'A';

     l_rec    l_cur%ROWTYPE;
     l_found  BOOLEAN;

     l_party_site_use_rec hz_party_site_v2pub.party_site_use_rec_type;

     l_method VARCHAR(30);
     l_step   VARCHAR2(100);
BEGIN

   l_method := 'remove_address_type';
   -- log_values p_party_site_id p_address_type
   IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement
                      , g_module || '.' || l_method
                      , ' p_party_site_id = ' || p_party_site_id
                      || ' p_address_type = ' || p_address_type
                      );
   END IF;

   l_step := 'check existing address type';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step
         );
   END IF;

   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   l_found := l_cur%found;
   CLOSE l_cur;

   IF NOT l_found THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
           (fnd_log.level_statement
            , g_module || '.' || l_method
            , l_step || ' existing record not found so no record to end-date.'
         );
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      RETURN;
   ELSE
      l_step := 'call hz_party_site_v2pub.update_party_site_use';
      l_party_site_use_rec.party_site_use_id := l_rec.party_site_use_id;
      l_party_site_use_rec.status            := 'I';

      hz_party_site_v2pub.update_party_site_use
        ( p_init_msg_list         => FND_API.G_FALSE,
          p_party_site_use_rec    => l_party_site_use_rec,
          p_object_version_number => l_rec.object_version_number,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data
          );

      IF x_return_status = FND_API.g_ret_sts_success THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement
                          , g_module || '.' || l_method
                          , l_step || ' succeeded'
                          );
         END IF;
      ELSE
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_error
                          , g_module || '.' || l_method
                          , l_step || ': x_return_status = ' || x_return_status
                            || ' x_msg_count = ' || x_msg_count
                            || ', x_msg_data = ' || x_msg_data
                          );
         END IF;
      END IF;
   END IF;
END remove_address_type;

PROCEDURE handle_address_type
  (p_party_site_id  IN  NUMBER,
   p_address_type   IN  VARCHAR2,
   p_value          IN  VARCHAR2,
   x_return_status  OUT nocopy VARCHAR2,
   x_msg_count      OUT nocopy NUMBER,
   x_msg_data       OUT nocopy VARCHAR2
   )
  IS
     l_method            VARCHAR2(30);
     l_step              VARCHAR2(100);
     l_party_site_use_id NUMBER;
BEGIN

   IF p_value = 'Y' THEN
      l_step := 'call assign_address_type ';
    ELSE
      l_step := 'call remove_address_type ';
   END IF;

   IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step || ' p_address_type = ' || p_address_type
           || ' p_party_site_id = ' || p_party_site_id
         );
   END IF;

   IF p_value = 'Y' THEN
      assign_address_type
        (p_party_site_id           => p_party_site_id,
         p_address_type            => p_address_type,
         x_party_site_use_id       => l_party_site_use_id,
         x_return_status           => x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data
         );
    ELSE
      remove_address_type
        (p_party_site_id           => p_party_site_id,
         p_address_type            => p_address_type,
         x_return_status           => x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data
         );
   END IF;

END handle_address_type;

PROCEDURE check_payables_options
  (
   p_vendor_id        IN  NUMBER,
   x_return_status    OUT nocopy VARCHAR2,
   x_msg_count        OUT nocopy NUMBER,
   x_msg_data         OUT nocopy VARCHAR2
   )
  IS
     l_orgs  VARCHAR2(3000);
     l_found BOOLEAN;
     l_reg_ou_id  NUMBER := null;
BEGIN
   l_found := FALSE;
  /* bug9505563: Use OU ID from the Registration Request to create the sites */

     IF (FND_PROFILE.VALUE('POS_SM_SITE_ENABLE_OPTION') = 'REQOU') THEN

      begin

        SELECT ou_id
        INTO l_reg_ou_id
        FROM pos_supplier_registrations
        WHERE po_vendor_id = p_vendor_id;

      exception
        when others then
          l_reg_ou_id := null;
      end;
     END IF;

   FOR x IN (SELECT name
             FROM hr_operating_units o
             WHERE mo_global.check_access(organization_id) = 'Y'
             AND o.organization_id = nvl(l_reg_ou_id,o.organization_id)
             AND NOT exists
                 (SELECT 1
                  FROM ap_system_parameters_all
                  WHERE o.organization_id = org_id
                  )
             )
     LOOP
        l_found := TRUE;
        IF l_orgs IS NULL THEN
           l_orgs := x.name;
         ELSE
           l_orgs := l_orgs || ', ' || x.name;
        END IF;
   END LOOP;

   IF l_found THEN
      x_return_status := 'E';
      fnd_message.set_name('POS','POS_ORG_PAY_PARAM_MISS');
      fnd_message.set_token('OPERATING_UNITS', l_orgs);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get
        (p_count => x_msg_count,
         p_data  => x_msg_data
        );
    ELSE
      x_return_status := 'S';
   END IF;

END check_payables_options;

PROCEDURE create_supplier_address
  (p_vendor_id        IN  NUMBER,
   p_vendor_party_id  IN  NUMBER,
   p_party_site_name  IN  VARCHAR2,
   p_address_line1    IN  VARCHAR2,
   p_address_line2    IN  VARCHAR2,
   p_address_line3    IN  VARCHAR2,
   p_address_line4    IN  VARCHAR2,
   p_country          IN  VARCHAR2,
   p_city             IN  VARCHAR2,
   p_state            IN  VARCHAR2,
   p_province         IN  VARCHAR2,
   p_postal_code      IN  VARCHAR2,
   p_county           IN  VARCHAR2,
   p_rfq_flag         IN  VARCHAR2,
   p_pur_flag         IN  VARCHAR2,
   p_pay_flag         IN  VARCHAR2,
   p_primary_pay_flag IN  VARCHAR2,
   p_phone_area_code  IN  VARCHAR2,
   p_phone_number     IN  VARCHAR2,
   p_phone_extension  IN  VARCHAR2,
   p_fax_area_code    IN  VARCHAR2,
   p_fax_number       IN  VARCHAR2,
   p_email_address    IN  VARCHAR2,
   x_return_status    OUT nocopy VARCHAR2,
   x_msg_count        OUT nocopy NUMBER,
   x_msg_data         OUT nocopy VARCHAR2,
   x_party_site_id    OUT nocopy NUMBER
   )
  IS
     l_party_site_number hz_party_sites.party_site_number%TYPE;
     l_party_site_id     NUMBER;
     l_location_id       NUMBER;
     l_party_site_use_id NUMBER;
     l_ou_ids            pos_security_profile_utl_pkg.number_table;
     l_ou_count          NUMBER;
     l_vendor_site_rec   ap_vendor_pub_pkg.r_vendor_site_rec_type;
     l_vendor_site_id    NUMBER;
     l_dummy_location_id NUMBER;
     l_dummy_party_site_id NUMBER;

  /* bug9505563: Use OU ID from the Registration Request to create the sites */
     l_reg_ou_id  NUMBER;

BEGIN
   SAVEPOINT create_supplier_address_sp;

   check_payables_options(
                         p_vendor_id     => p_vendor_id,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data);

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_supplier_address_sp;
      RETURN;
   END IF;

   pos_security_profile_utl_pkg.get_current_ous (l_ou_ids, l_ou_count);

   pos_hz_util_pkg.pos_create_hz_location
     (p_country_code  => p_country,
      p_address1      => p_address_line1,
      p_address2      => p_address_line2,
      p_address3      => p_address_line3,
      p_address4      => p_address_line4,
      p_city          => p_city,
      p_postal_code   => p_postal_code,
      p_county        => p_county,
      p_state         => p_state ,
      p_province      => p_province,
      x_location_id   => l_location_id,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_supplier_address_sp;
      RETURN;
   END IF;

   pos_hz_util_pkg.pos_create_party_site
     (p_party_id          => p_vendor_party_id,
      p_location_id       => l_location_id,
      p_party_site_name   => p_party_site_name,
      x_party_site_id     => l_party_site_id,
      x_party_site_number => l_party_site_number,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_supplier_address_sp;
      RETURN;
   END IF;

   x_party_site_id := l_party_site_id;

   IF p_rfq_flag IS NOT NULL AND p_rfq_flag = 'Y' THEN
      assign_address_type
        (p_party_site_id           => l_party_site_id,
         p_address_type            => 'RFQ', -- 'RFQ',
         x_party_site_use_id       => l_party_site_use_id,
         x_return_status           => x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data
         );
      IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
         ROLLBACK TO create_supplier_address_sp;
         RETURN;
      END IF;
   END IF;

   IF p_pur_flag IS NOT NULL AND p_pur_flag = 'Y' THEN
      assign_address_type
        (p_party_site_id           => l_party_site_id,
         p_address_type            => 'PURCHASING', -- 'PURCHASING',
         x_party_site_use_id       => l_party_site_use_id,
         x_return_status           => x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data
         );
      IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
         ROLLBACK TO create_supplier_address_sp;
         RETURN;
      END IF;
   END IF;

   IF p_pay_flag IS NOT NULL AND p_pay_flag = 'Y' THEN
      assign_address_type
        (p_party_site_id           => l_party_site_id,
         p_address_type            => 'PAY', --'PAY',
         x_party_site_use_id       => l_party_site_use_id,
         x_return_status           => x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data
         );
      IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
         ROLLBACK TO create_supplier_address_sp;
         RETURN;
      END IF;
   END IF;

   IF p_primary_pay_flag IS NOT NULL AND p_primary_pay_flag = 'Y' THEN
      --       assign_address_type
      --         (p_party_site_id           => l_party_site_id,
      --          p_address_type            => 'PRIMARY_PAY', -- ap has not seeded this
      --          x_party_site_use_id       => l_party_site_use_id,
      --          x_return_status           => x_return_status,
      --          x_msg_count               => x_msg_count,
      --          x_msg_data                => x_msg_data
      --          );
      --       IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      --          RETURN;
      --       END IF;
      NULL;
   END IF;

   pos_hz_contact_point_pkg.update_party_site_phone
     (
      p_party_site_id     => l_party_site_id,
      p_country_code      =>  NULL,
      p_area_code         => p_phone_area_code ,
      p_number            => p_phone_number,
      p_extension         => NULL,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
    );

   IF x_return_status IS NULL OR
     x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_supplier_address_sp;
      RETURN;
   END IF;

   pos_hz_contact_point_pkg.update_party_site_fax
     (
      p_party_site_id     => l_party_site_id,
      p_country_code      =>  NULL,
      p_area_code         => p_fax_area_code ,
      p_number            => p_fax_number,
      p_extension         => NULL,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
    );

   IF x_return_status IS NULL OR
     x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_supplier_address_sp;
      RETURN;
   END IF;

   pos_hz_contact_point_pkg.update_party_site_email
     (
      p_party_site_id     => l_party_site_id,
      p_email             => p_email_address,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
    );

   IF x_return_status IS NULL OR
     x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_supplier_address_sp;
      RETURN;
   END IF;

   -- create vendor sites

 /* bug 9505563 -  Supplier Hub Changes
    create vendor site only in supplier registration OU.  */

  IF (FND_PROFILE.VALUE('POS_SM_SITE_ENABLE_OPTION') = 'REQOU') THEN

      begin

        SELECT ou_id
        INTO l_reg_ou_id
	FROM pos_supplier_registrations
	WHERE po_vendor_id = p_vendor_id;

      exception
        when others then
          l_reg_ou_id := null;
      end;


      IF l_reg_ou_id IS NOT NULL THEN

         l_vendor_site_rec := NULL;
         l_vendor_site_rec.org_id                := l_reg_ou_id;
         l_vendor_site_rec.vendor_id             := p_vendor_id;
         l_vendor_site_rec.location_id           := l_location_id;
         l_vendor_site_rec.party_site_id         := l_party_site_id;
         l_vendor_site_rec.vendor_site_code      := substrb(p_party_site_name,
                                                              1,15);
         l_vendor_site_rec.purchasing_site_flag  := p_pur_flag;
         l_vendor_site_rec.rfq_only_site_flag    := p_rfq_flag;
         l_vendor_site_rec.pay_site_flag         := p_pay_flag;
         l_vendor_site_rec.primary_pay_site_flag := p_primary_pay_flag;
         l_vendor_site_rec.email_address         := p_email_address;
         l_vendor_site_rec.area_code             := p_phone_area_code;
         l_vendor_site_rec.phone                 := p_phone_number;
         l_vendor_site_rec.fax_area_code         := p_fax_area_code;
         l_vendor_site_rec.fax                   := p_fax_number;

         pos_vendor_pub_pkg.create_vendor_site(
                         p_vendor_site_rec => l_vendor_site_rec,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         x_vendor_site_id  => l_vendor_site_id,
                         x_party_site_id   => l_dummy_party_site_id,
                         x_location_id     => l_dummy_location_id);

         IF (x_return_status IS NULL OR
             x_return_status <> fnd_api.g_ret_sts_success) THEN
             ROLLBACK TO create_supplier_address_sp;
             RETURN;
         END IF;
       END IF;
    ELSIF (FND_PROFILE.VALUE('POS_SM_SITE_ENABLE_OPTION') = 'MOACSP') THEN
	-- Create  Sites in all OUs as per MO:Security profile option

     FOR l_index IN 1..l_ou_count LOOP

      l_vendor_site_rec := NULL;

      l_vendor_site_rec.org_id                := l_ou_ids(l_index);
      l_vendor_site_rec.vendor_id             := p_vendor_id;
      l_vendor_site_rec.location_id           := l_location_id;
      l_vendor_site_rec.party_site_id         := l_party_site_id;
      l_vendor_site_rec.vendor_site_code      := substrb(p_party_site_name, 1, 15);
      l_vendor_site_rec.purchasing_site_flag  := p_pur_flag;
      l_vendor_site_rec.rfq_only_site_flag    := p_rfq_flag;
      l_vendor_site_rec.pay_site_flag         := p_pay_flag;
      l_vendor_site_rec.primary_pay_site_flag := p_primary_pay_flag;
      l_vendor_site_rec.email_address         := p_email_address;
      l_vendor_site_rec.area_code             := p_phone_area_code;
      l_vendor_site_rec.phone                 := p_phone_number;
      l_vendor_site_rec.fax_area_code         := p_fax_area_code;
      l_vendor_site_rec.fax                   := p_fax_number;

      pos_vendor_pub_pkg.create_vendor_site
        ( p_vendor_site_rec => l_vendor_site_rec,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          x_vendor_site_id  => l_vendor_site_id,
          x_party_site_id   => l_dummy_party_site_id,
          x_location_id     => l_dummy_location_id
          );

      IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
         ROLLBACK TO create_supplier_address_sp;
         RETURN;
      END IF;

   END LOOP;
 END IF;

 x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO create_supplier_address_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_data := Sqlerrm;
      x_msg_count := 1;
      pos_log.log_sqlerrm('POSSAB','create_supplier_address');
END create_supplier_address;

PROCEDURE update_supplier_address
  (p_vendor_id        IN  NUMBER,
   p_vendor_party_id  IN  NUMBER,
   p_party_site_id    IN  NUMBER,
   p_party_site_name  IN  VARCHAR2,
   p_address_line1    IN  VARCHAR2,
   p_address_line2    IN  VARCHAR2,
   p_address_line3    IN  VARCHAR2,
   p_address_line4    IN  VARCHAR2,
   p_country          IN  VARCHAR2,
   p_city             IN  VARCHAR2,
   p_state            IN  VARCHAR2,
   p_province         IN  VARCHAR2,
   p_postal_code      IN  VARCHAR2,
   p_county           IN  VARCHAR2,
   p_rfq_flag         IN  VARCHAR2,
   p_pur_flag         IN  VARCHAR2,
   p_pay_flag         IN  VARCHAR2,
   p_primary_pay_flag IN  VARCHAR2,
   p_phone_area_code  IN  VARCHAR2,
   p_phone_number     IN  VARCHAR2,
   p_phone_extension  IN  VARCHAR2,
   p_fax_area_code    IN  VARCHAR2,
   p_fax_number       IN  VARCHAR2,
   p_email_address    IN  VARCHAR2,
   x_return_status    OUT nocopy VARCHAR2,
   x_msg_count        OUT nocopy NUMBER,
   x_msg_data         OUT nocopy VARCHAR2
   )
   IS
     l_party_site_rec    hz_party_site_v2pub.party_site_rec_type;
     l_location_rec      hz_location_v2pub.location_rec_type;
     l_obj_ver           hz_locations.object_version_number%TYPE;

     CURSOR l_cur IS
        SELECT object_version_number,location_id
          from hz_locations
          where location_id =
          (SELECT location_id
           FROM hz_party_sites
           WHERE party_site_id = p_party_site_id
           ) FOR UPDATE;

     l_rec l_cur%ROWTYPE;

     CURSOR l_cur2 IS
        select object_version_number, party_site_name
          from hz_party_sites
          where party_site_id = p_party_site_id FOR UPDATE;

     l_rec2 l_cur2%ROWTYPE;

BEGIN
   SAVEPOINT update_supplier_address_sp;
   OPEN l_cur;
   FETCH l_cur INTO l_rec;
   IF l_cur%notfound THEN
      CLOSE l_cur;
      -- prepare err msg
      RETURN;
   END IF;
   CLOSE l_cur;

   OPEN l_cur2;
   FETCH l_cur2 INTO l_rec2;
   IF l_cur2%notfound THEN
      CLOSE l_cur2;
      -- prepare err msg
      RETURN;
   END IF;
   CLOSE l_cur2;

   l_location_rec.location_id  := l_rec.location_id;
   l_location_rec.address1     := Nvl(p_address_line1, fnd_api.g_miss_char);
   l_location_rec.address2     := Nvl(p_address_line2, fnd_api.g_miss_char);
   l_location_rec.address3     := Nvl(p_address_line3, fnd_api.g_miss_char);
   l_location_rec.address4     := Nvl(p_address_line4, fnd_api.g_miss_char);
   l_location_rec.city         := Nvl(p_city         , fnd_api.g_miss_char);
   l_location_rec.postal_code  := Nvl(p_postal_code  , fnd_api.g_miss_char);
   l_location_rec.state        := Nvl(p_state        , fnd_api.g_miss_char);
   l_location_rec.province     := Nvl(p_province     , fnd_api.g_miss_char);
   l_location_rec.county       := Nvl(p_county       , fnd_api.g_miss_char);
   l_location_rec.country      := Nvl(p_country      , fnd_api.g_miss_char);

   l_obj_ver := l_rec.object_version_number;

   hz_location_v2pub.update_location
     (  p_init_msg_list         => fnd_api.g_true,
        p_location_rec          => l_location_rec,
        p_object_version_number => l_obj_ver,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data
    );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_address_sp;
      RETURN;
   END IF;

   IF l_rec2.party_site_name IS NULL AND p_party_site_name IS NOT NULL OR
     l_rec2.party_site_name IS NOT NULL AND p_party_site_name IS NULL OR
       l_rec2.party_site_name <> p_party_site_name THEN

      l_party_site_rec.party_site_id := p_party_site_id;
      l_party_site_rec.party_site_name := p_party_site_name;

      hz_party_site_v2pub.update_party_site
        (p_init_msg_list         => fnd_api.g_false,
         p_party_site_rec        => l_party_site_rec,
         p_object_version_number => l_rec2.object_version_number,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data
         );

      IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
         ROLLBACK TO update_supplier_address_sp;
         RETURN;
      END IF;
   END IF;

   -- set phone for the address
   pos_hz_contact_point_pkg.update_party_site_phone
     (
      p_party_site_id     => p_party_site_id,
      p_country_code      =>  NULL,
      p_area_code         => p_phone_area_code ,
      p_number            => p_phone_number,
      p_extension         => NULL,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
    );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_address_sp;
      RETURN;
   END IF;

   -- set fax for the address
   pos_hz_contact_point_pkg.update_party_site_fax
     (
      p_party_site_id     => p_party_site_id,
      p_country_code      =>  NULL,
      p_area_code         => p_fax_area_code ,
      p_number            => p_fax_number,
      p_extension         => NULL,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
    );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_address_sp;
      RETURN;
   END IF;

   -- set email for the address
   pos_hz_contact_point_pkg.update_party_site_email
     (
      p_party_site_id     => p_party_site_id,
      p_email             => p_email_address,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_address_sp;
      RETURN;
   END IF;

   handle_address_type
     (p_party_site_id    => p_party_site_id,
      p_address_type     => 'PAY',
      p_value            => p_pay_flag,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_address_sp;
      RETURN;
   END IF;

   handle_address_type
     (p_party_site_id    => p_party_site_id,
      p_address_type     => 'PURCHASING',
      p_value            => p_pur_flag,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_address_sp;
      RETURN;
   END IF;

   handle_address_type
     (p_party_site_id    => p_party_site_id,
      p_address_type     => 'RFQ',
      p_value            => p_rfq_flag,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_address_sp;
      RETURN;
   END IF;

   -- logic for primary pay still need to be worked out
   x_return_status := fnd_api.g_ret_sts_success;

END update_supplier_address;

PROCEDURE unassign_address_to_contact
  (p_contact_party_id   IN  NUMBER,
   p_org_party_site_id  IN  NUMBER,
   p_vendor_id          IN  NUMBER,
   x_return_status      OUT nocopy VARCHAR2,
   x_msg_count          OUT nocopy NUMBER,
   x_msg_data           OUT nocopy VARCHAR2
   )
IS

CURSOR l_cur IS
        select ASCS.vendor_site_id, ASCS.relationship_id, ASCS.org_contact_id,
        ASCS.rel_party_id, ASCS.party_site_id, ASCS.vendor_contact_id
        from ap_supplier_contacts ASCS
        where (ASCS.inactive_date is null OR ASCS.inactive_date > sysdate)
        AND ASCS.org_party_site_id = p_org_party_site_id
        AND ASCS.per_party_id = p_contact_party_id;

l_rec l_cur%ROWTYPE;
l_vendor_contact_rec ap_vendor_pub_pkg.r_vendor_contact_rec_type;

BEGIN

    for l_rec in l_cur loop

      l_vendor_contact_rec.vendor_site_id    := l_rec.vendor_site_id;
      l_vendor_contact_rec.per_party_id      := p_contact_party_id;
      l_vendor_contact_rec.relationship_id   := l_rec.relationship_id;
      l_vendor_contact_rec.rel_party_id      := l_rec.rel_party_id;
      l_vendor_contact_rec.org_party_site_id := p_org_party_site_id;
      l_vendor_contact_rec.inactive_date     := sysdate;
      l_vendor_contact_rec.vendor_contact_id := l_rec.vendor_contact_id;
      l_vendor_contact_rec.org_contact_id    := l_rec.org_contact_id;
      l_vendor_contact_rec.party_site_id     := l_rec.party_site_id;

      IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' Before Calling pos_vendor_pub_pkg.update_vendor_contact');
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' per_party_id ' || p_contact_party_id);
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' org_party_site_id ' || p_org_party_site_id);
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' rel_party_id ' || l_rec.rel_party_id);
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' relationship_id ' || l_rec.relationship_id);
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' vendor_site_id ' || l_rec.vendor_site_id);
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' org_contact_id ' || l_rec.org_contact_id);

      END IF;

      AP_VENDOR_PUB_PKG.Update_Vendor_Contact
        (
          p_api_version           => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_FALSE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_vendor_contact_rec    => l_vendor_contact_rec,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data
        );

      IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' After Calling pos_vendor_pub_pkg.update_vendor_contact');
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' x_return_status ' || x_return_status);
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' x_msg_count ' || x_msg_count);
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' x_msg_data ' || x_msg_data);
      END IF;

    end loop;

x_return_status := 'S';
x_msg_data := null;

EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20020, 'Failure error status ' || x_return_status || x_msg_data || Sqlerrm, true);

END unassign_address_to_contact;

-- code added for bug 8237063
/* updating address details to ap_supplier_contacts
when only the contact related data is changed and the
address assignments are not added or deleted */
PROCEDURE update_address_to_contact
  (p_contact_party_id   IN  NUMBER,
   p_org_party_site_id  IN  NUMBER,
   p_vendor_id          IN  NUMBER,
   x_return_status      OUT nocopy VARCHAR2,
   x_msg_count          OUT nocopy NUMBER,
   x_msg_data           OUT nocopy VARCHAR2
   )
IS

CURSOR l_cur IS
        select ASCS.vendor_site_id, ASCS.relationship_id, ASCS.org_contact_id,
        ASCS.rel_party_id, ASCS.party_site_id, ASCS.vendor_contact_id, ASCS.inactive_date
        from ap_supplier_contacts ASCS
        where (ASCS.inactive_date is null OR ASCS.inactive_date > sysdate)
        AND ASCS.org_party_site_id = p_org_party_site_id
        AND ASCS.per_party_id = p_contact_party_id;

l_rec l_cur%ROWTYPE;
l_vendor_contact_rec ap_vendor_pub_pkg.r_vendor_contact_rec_type;

BEGIN

    for l_rec in l_cur loop

      l_vendor_contact_rec.vendor_site_id    := l_rec.vendor_site_id;
      l_vendor_contact_rec.per_party_id      := p_contact_party_id;
      l_vendor_contact_rec.relationship_id   := l_rec.relationship_id;
      l_vendor_contact_rec.rel_party_id      := l_rec.rel_party_id;
      l_vendor_contact_rec.org_party_site_id := p_org_party_site_id;
      l_vendor_contact_rec.inactive_date     := l_rec.inactive_date;
      l_vendor_contact_rec.vendor_contact_id := l_rec.vendor_contact_id;
      l_vendor_contact_rec.org_contact_id    := l_rec.org_contact_id;
      l_vendor_contact_rec.party_site_id     := l_rec.party_site_id;

      IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' Before Calling pos_vendor_pub_pkg.update_vendor_contact from update_address_to_contact');
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' per_party_id ' || p_contact_party_id);
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' org_party_site_id ' || p_org_party_site_id);
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' rel_party_id ' || l_rec.rel_party_id);
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' relationship_id ' || l_rec.relationship_id);
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' vendor_site_id ' || l_rec.vendor_site_id);
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' org_contact_id ' || l_rec.org_contact_id);

      END IF;

      AP_VENDOR_PUB_PKG.Update_Vendor_Contact
        (
          p_api_version           => 1.0,
          p_init_msg_list         => FND_API.G_TRUE,
          p_commit                => FND_API.G_FALSE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_vendor_contact_rec    => l_vendor_contact_rec,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data
        );

      IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' After Calling pos_vendor_pub_pkg.update_vendor_contact from update_address_to_contact');
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' x_return_status ' || x_return_status);
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' x_msg_count ' || x_msg_count);
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' x_msg_data ' || x_msg_data);
      END IF;

    end loop;

x_return_status := 'S';
x_msg_data := null;

EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20020, 'Failure error status ' || x_return_status || x_msg_data || Sqlerrm, true);

END update_address_to_contact;
-- code added for bug 8237063

PROCEDURE assign_address_to_contact
  (p_contact_party_id   IN  NUMBER,
   p_org_party_site_id  IN  NUMBER,
   p_vendor_id          IN  NUMBER,
   x_attribute_category   IN VARCHAR2 default null,
   x_attribute1 IN VARCHAR2 default null,
   x_attribute2 IN VARCHAR2 default null,
   x_attribute3 IN VARCHAR2 default null,
   x_attribute4 IN VARCHAR2 default null,
   x_attribute5 IN VARCHAR2 default null,
   x_attribute6 IN VARCHAR2 default null,
   x_attribute7 IN VARCHAR2 default null,
   x_attribute8 IN VARCHAR2 default null,
   x_attribute9 IN VARCHAR2 default null,
   x_attribute10 IN VARCHAR2 default null,
   x_attribute11 IN VARCHAR2 default null,
   x_attribute12 IN VARCHAR2 default null,
   x_attribute13 IN VARCHAR2 default null,
   x_attribute14 IN VARCHAR2 default null,
   x_attribute15 IN VARCHAR2 default null,
   x_return_status      OUT nocopy VARCHAR2,
   x_msg_count          OUT nocopy NUMBER,
   x_msg_data           OUT nocopy VARCHAR2
   )
  IS

    CURSOR l_cur IS
        SELECT 1
          FROM ap_supplier_contacts
         WHERE org_party_site_id = p_org_party_site_id
           AND per_party_id = p_contact_party_id
           AND (inactive_date is null OR inactive_date >= sysdate)
           AND rownum = 1;

     l_number NUMBER;

     l_vendor_contact_rec ap_vendor_pub_pkg.r_vendor_contact_rec_type;

     /* Bug 6610366 , Checking the Status from hz_relationships as status column
        in hz_org_contacts is obsoleted in R12 ,Also checking for */

     CURSOR l_cur3 IS
        SELECT hzr.relationship_id, hzr.party_id rel_party_id, hoc.org_contact_id
          FROM ap_suppliers pv, hz_relationships hzr, hz_org_contacts hoc
         WHERE pv.vendor_id = p_vendor_id
            AND hzr.relationship_type = 'CONTACT'
            AND hzr.relationship_code = 'CONTACT_OF'
            AND hzr.subject_id = p_contact_party_id
            AND hzr.subject_type = 'PERSON'
            AND hzr.subject_table_name = 'HZ_PARTIES'
            AND hzr.object_type = 'ORGANIZATION'
            AND hzr.object_table_name = 'HZ_PARTIES'
            AND hzr.object_id = pv.party_id
            AND hzr.status = 'A'
	    AND trunc(SYSDATE) between Trunc(hzr.START_DATE) AND
	        NVL(Trunc(hzr.END_DATE),trunc(SYSDATE + 1))
            AND hzr.relationship_id = hoc.party_relationship_id;

     l_rec3 l_cur3%ROWTYPE;
     l_step                 NUMBER;
     l_vendor_contact_id    NUMBER;
     l_per_party_id         NUMBER;
     l_rel_party_id         NUMBER;
     l_rel_id               NUMBER;
     l_org_contact_id       NUMBER;
     l_person_party_site_id NUMBER;
BEGIN

   l_step := 0;

   OPEN l_cur;
   FETCH l_cur INTO l_number;
   IF l_cur%found THEN
      -- already has such assignment
      CLOSE l_cur;
      x_return_status := fnd_api.g_ret_sts_success;
      x_msg_count := 1;
      x_msg_data := NULL;
      RETURN;
   END IF;

   l_step := 1;

   OPEN l_cur3;
   FETCH l_cur3 INTO l_rec3;
   IF l_cur3%notfound THEN
      CLOSE l_cur3;
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count := 1;
      x_msg_data := 'invalid supplier contact info';
      RETURN;
   END IF;
   CLOSE l_cur3;

   l_step := 2;

   l_vendor_contact_rec.vendor_site_id    := null;
   l_vendor_contact_rec.per_party_id      := p_contact_party_id;
   l_vendor_contact_rec.relationship_id   := l_rec3.relationship_id;
   l_vendor_contact_rec.rel_party_id      := l_rec3.rel_party_id;
   l_vendor_contact_rec.org_party_site_id := p_org_party_site_id;
   l_vendor_contact_rec.org_contact_id    := l_rec3.org_contact_id;

   /* Bug 12983048 - Start */
   l_vendor_contact_rec.vendor_id         := p_vendor_id;

   IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.string(fnd_log.level_statement, g_module,
         'Before Call to pos_vendor_pub_pkg.create_vendor_contact, vendor_id is  : ' || l_vendor_contact_rec.vendor_id);
   END IF;
   /* Bug 12983048 - End */


   /* Bug 6599374 Start */

   l_vendor_contact_rec.attribute_category:=x_attribute_category;
   l_vendor_contact_rec.attribute1:=x_attribute1;
   l_vendor_contact_rec.attribute2:=x_attribute2;
   l_vendor_contact_rec.attribute3:=x_attribute3;
   l_vendor_contact_rec.attribute4:=x_attribute4;
   l_vendor_contact_rec.attribute5:=x_attribute5;
   l_vendor_contact_rec.attribute6:=x_attribute6;
   l_vendor_contact_rec.attribute7:=x_attribute7;
   l_vendor_contact_rec.attribute8:=x_attribute8;
   l_vendor_contact_rec.attribute9:=x_attribute9;
   l_vendor_contact_rec.attribute10:=x_attribute10;
   l_vendor_contact_rec.attribute11:=x_attribute11;
   l_vendor_contact_rec.attribute12:=x_attribute12;
   l_vendor_contact_rec.attribute13:=x_attribute13;
   l_vendor_contact_rec.attribute14:=x_attribute14;
   l_vendor_contact_rec.attribute15:=x_attribute15;

   /* Bug 6599374 End   */

   l_step := 3;

   IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' Before Calling pos_vendor_pub_pkg.create_vendor_contact');
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' per_party_id ' || p_contact_party_id);
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' org_party_site_id ' || p_org_party_site_id);
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' rel_party_id ' || l_rec3.rel_party_id);
            FND_LOG.string(fnd_log.level_statement, g_module,
            ' relationship_id ' || l_rec3.relationship_id);
   END IF;

   pos_vendor_pub_pkg.create_vendor_contact
     ( p_vendor_contact_rec  => l_vendor_contact_rec,
       x_return_status       => x_return_status,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data,
       x_vendor_contact_id   => l_vendor_contact_id,
       x_per_party_id        => l_per_party_id,
       x_rel_party_id        => l_rel_party_id,
       x_rel_id              => l_rel_id,
       x_org_contact_id      => l_org_contact_id,
       x_party_site_id       => l_person_party_site_id
       );

   l_step := 4;

   IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' After Calling pos_vendor_pub_pkg.create_vendor_contact');
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' x_return_status ' || x_return_status);
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' x_msg_count ' || x_msg_count);
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' x_msg_data ' || x_msg_data);
   END IF;

EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20020, 'Failure at step ' || l_step || Sqlerrm, true);
END assign_address_to_contact;

/* Bug 6599374 Start */

PROCEDURE update_address_assignment_dff
  (x_contact_party_id   IN  NUMBER,
   x_org_party_site_id  IN  NUMBER,
   x_vendor_id          IN  NUMBER,
   x_attribute_category   IN VARCHAR2 default null,
   x_attribute1 IN VARCHAR2 default null,
   x_attribute2 IN VARCHAR2 default null,
   x_attribute3 IN VARCHAR2 default null,
   x_attribute4 IN VARCHAR2 default null,
   x_attribute5 IN VARCHAR2 default null,
   x_attribute6 IN VARCHAR2 default null,
   x_attribute7 IN VARCHAR2 default null,
   x_attribute8 IN VARCHAR2 default null,
   x_attribute9 IN VARCHAR2 default null,
   x_attribute10 IN VARCHAR2 default null,
   x_attribute11 IN VARCHAR2 default null,
   x_attribute12 IN VARCHAR2 default null,
   x_attribute13 IN VARCHAR2 default null,
   x_attribute14 IN VARCHAR2 default null,
   x_attribute15 IN VARCHAR2 default null,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count OUT nocopy NUMBER,
   x_msg_data  OUT nocopy VARCHAR2
   ) IS
   BEGIN

   /* Here We Need To Call AP Package For Updating The Address Assignments */

   AP_VENDOR_PUB_PKG.Update_Address_Assignments_DFF
    (
    p_api_version       => 1,
    p_init_msg_list     => FND_API.G_FALSE,
    p_commit            => FND_API.G_FALSE,
    p_contact_party_id  => x_contact_party_id,
    p_org_party_site_id => x_org_party_site_id,
    p_attribute_category=> x_attribute_category,
    p_attribute1        => x_attribute1,
    p_attribute2        => x_attribute2,
    p_attribute3        => x_attribute3,
    p_attribute4        => x_attribute4,
    p_attribute5        => x_attribute5,
    p_attribute6        => x_attribute6,
    p_attribute7        => x_attribute7,
    p_attribute8        => x_attribute8,
    p_attribute9        => x_attribute9,
    p_attribute10       => x_attribute10,
    p_attribute11       => x_attribute11,
    p_attribute12       => x_attribute12,
    p_attribute13       => x_attribute13,
    p_attribute14       => x_attribute14,
    p_attribute15       => x_attribute15,
    x_return_status     => x_return_status,
    x_msg_count         => x_msg_count,
    x_msg_data          => x_msg_data
    );

    IF ( fnd_log.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' After Calling AP_VENDOR_PUB_PKG.Update_Address_Assignments_DFF ');
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' x_return_status ' || x_return_status);
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' x_msg_count ' || x_msg_count);
                FND_LOG.string(fnd_log.level_statement, g_module,
            ' x_msg_data ' || x_msg_data);
    END IF;

   EXCEPTION
   WHEN OTHERS
   THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   END update_address_assignment_dff;

/* Bug 6599374 End   */

-- This procedure is used by the new supplier UI in r12
-- to update details such as site use flags, phone,
-- fax, email, notes for a supplier address
PROCEDURE buyer_update_address_details
(p_party_site_id     IN  NUMBER,
 p_rfqFlag           IN  VARCHAR2,
 p_purFlag           IN  VARCHAR2,
 p_payFlag           IN  VARCHAR2,
 p_primaryPayFlag    IN  VARCHAR2,
 p_note              IN  VARCHAR2,
 p_phone_area_code   IN  VARCHAR2 DEFAULT NULL,
 p_phone             IN  VARCHAR2 DEFAULT NULL,
 p_phone_contact_id  IN  NUMBER DEFAULT NULL,
 p_phone_obj_ver_num IN  NUMBER DEFAULT NULL,
 p_fax_area_code     IN  VARCHAR2 DEFAULT NULL,
 p_fax               IN  VARCHAR2 DEFAULT NULL,
 p_fax_contact_id    IN  NUMBER DEFAULT NULL,
 p_fax_obj_ver_num   IN  NUMBER DEFAULT NULL,
 p_email             IN  VARCHAR2 DEFAULT NULL,
 p_email_contact_id  IN  NUMBER DEFAULT NULL,
 p_email_obj_ver_num IN  NUMBER DEFAULT NULL,
 x_return_status     OUT NOCOPY VARCHAR2,
 x_msg_count         OUT NOCOPY NUMBER,
 x_msg_data          OUT NOCOPY VARCHAR2
 )
  IS
     l_status VARCHAR2(1);
     l_msg    VARCHAR2(2000);
BEGIN
   SAVEPOINT update_supplier_address_sp;

   -- set phone for the address
   pos_hz_contact_point_pkg.update_party_site_phone
     (
      p_party_site_id     => p_party_site_id,
      p_country_code      =>  NULL,
      p_area_code         => p_phone_area_code ,
      p_number            => p_phone,
      p_extension         => NULL,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
    );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_address_sp;
      RETURN;
   END IF;

   -- set fax for the address
   pos_hz_contact_point_pkg.update_party_site_fax
     (
      p_party_site_id     => p_party_site_id,
      p_country_code      =>  NULL,
      p_area_code         => p_fax_area_code ,
      p_number            => p_fax,
      p_extension         => NULL,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
    );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_address_sp;
      RETURN;
   END IF;

   -- set email for the address
   pos_hz_contact_point_pkg.update_party_site_email
     (
      p_party_site_id     => p_party_site_id,
      p_email             => p_email,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_address_sp;
      RETURN;
   END IF;

   handle_address_type
     (p_party_site_id    => p_party_site_id,
      p_address_type     => 'PAY',
      p_value            => p_payflag,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_address_sp;
      RETURN;
   END IF;

   handle_address_type
     (p_party_site_id    => p_party_site_id,
      p_address_type     => 'PURCHASING',
      p_value            => p_purflag,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_address_sp;
      RETURN;
   END IF;

   handle_address_type
     (p_party_site_id    => p_party_site_id,
      p_address_type     => 'RFQ',
      p_value            => p_rfqflag,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_address_sp;
      RETURN;
   END IF;

   -- logic for primary pay still need to be worked out
   pos_address_notes_pkg.update_note
     ( p_party_site_id => p_party_site_id,
       p_note          => p_note,
       x_status        => l_status,
       x_exception_msg => l_msg
       );

   IF l_status IS NULL OR l_status <> 'S' THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := l_msg;
      IF l_msg IS NOT NULL THEN
         x_msg_count := 1;
       ELSE
         x_msg_count := 0;
      END IF;
    ELSE
      x_return_status := fnd_api.g_ret_sts_success;
   END IF;

END buyer_update_address_details;



END pos_supplier_address_pkg;

/
