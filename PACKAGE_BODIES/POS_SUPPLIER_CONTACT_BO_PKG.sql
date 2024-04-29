--------------------------------------------------------
--  DDL for Package Body POS_SUPPLIER_CONTACT_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPPLIER_CONTACT_BO_PKG" AS
  /* $Header: POSSPCONB.pls 120.0.12010000.1 2010/02/02 06:55:46 ntungare noship $ */
  /*#
  * Use this routine to get supplier contact
  * @param p_api_version The version of API
  * @param p_init_msg_list The Initialization message list
  * @param p_party_id The party id
  * @param p_orig_system The Orig System
  * @param p_orig_system_reference The Orig System Reference
  * @param x_ap_supplier_contact_bo The supplier contact record
  * @param x_return_status The return status
  * @param x_msg_count The message count
  * @param x_msg_data The message data
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Supplier Contacts
  * @rep:catagory BUSSINESS_ENTITY POS_SUPPLIER
  */
  PROCEDURE get_pos_supp_contact_bo_tbl
  (
    p_api_version            IN NUMBER DEFAULT NULL,
    p_init_msg_list          IN VARCHAR2 DEFAULT NULL,
    p_party_id               IN NUMBER,
    p_orig_system            IN VARCHAR2,
    p_orig_system_reference  IN VARCHAR2,
    x_ap_supplier_contact_bo OUT NOCOPY pos_supplier_contact_bo_tbl,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
  ) IS

    -- l_ap_supplier_contact_typ_tbl pos_supplier_contact_bo_tbl := pos_supplier_contact_bo_tbl();
    --l_pos_supplier_uda_bo         pos_supplier_uda_bo;
    l_party_id NUMBER;

  BEGIN

    IF p_party_id IS NULL OR p_party_id = 0 THEN

      l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                         p_orig_system_reference);
    ELSE
      l_party_id := p_party_id;
    END IF;

    SELECT pos_supplier_contact_bo(apsc.vendor_contact_id,
                                   apsc.last_update_date,
                                   apsc.last_updated_by,
                                   apsc.vendor_site_id,
                                   apsc.last_update_login,
                                   apsc.creation_date,
                                   apsc.created_by,
                                   apsc.inactive_date,
                                   apsc.first_name,
                                   apsc.middle_name,
                                   apsc.last_name,
                                   apsc.prefix,
                                   apsc.title,
                                   apsc.mail_stop,
                                   apsc.area_code,
                                   apsc.phone,
                                   apsc.attribute_category,
                                   apsc.attribute1,
                                   apsc.attribute2,
                                   apsc.attribute3,
                                   apsc.attribute4,
                                   apsc.attribute5,
                                   apsc.attribute6,
                                   apsc.attribute7,
                                   apsc.attribute8,
                                   apsc.attribute9,
                                   apsc.attribute10,
                                   apsc.attribute11,
                                   apsc.attribute12,
                                   apsc.attribute13,
                                   apsc.attribute14,
                                   apsc.attribute15,
                                   apsc.request_id,
                                   apsc.program_application_id,
                                   apsc.program_id,
                                   apsc.program_update_date,
                                   apsc.contact_name_alt,
                                   apsc.first_name_alt,
                                   apsc.last_name_alt,
                                   apsc.department,
                                   apsc.email_address,
                                   apsc.url,
                                   apsc.alt_area_code,
                                   apsc.alt_phone,
                                   apsc.fax_area_code,
                                   apsc.fax,
                                   apsc.per_party_id,
                                   NULL,
                                   NULL,
                                   apsc.relationship_id,
                                   apsc.rel_party_id,
                                   apsc.party_site_id,
                                   apsc.org_contact_id,
                                   apsc.org_party_site_id,
                                   '',
                                   '',
                                   '',
                                   '',
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   '',
                                   '')

           BULK COLLECT
    INTO   x_ap_supplier_contact_bo
    FROM   ap_supplier_contacts  apsc,
           ap_suppliers          ap,
           ap_supplier_sites_all sa
    WHERE  ap.party_id = l_party_id
    AND    sa.vendor_id = ap.vendor_id
--  AND    apsc.vendor_site_id = sa.vendor_site_id;
    AND    apsc.org_party_site_id = sa.party_site_id;
    /*
    pos_supplier_uda_bo_pkg.get_uda_data(p_api_version,
                                         p_init_msg_list,
                                         NULL,
                                         NULL,
                                         p_party_id,
                                         'SUPP_ADDR_LEVEL',
                                         l_pos_supplier_uda_bo,
                                         x_return_status,
                                         x_msg_count,
                                         x_msg_data);*/

    /* x_ap_supplier_contact_bo := pos_supplier_contact_bo(l_ap_supplier_contact_typ_tbl,
    l_pos_supplier_uda_bo);*/
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
    WHEN fnd_api.g_exc_unexpected_error THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
    WHEN OTHERS THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      x_msg_count := 1;
      x_msg_data  := SQLCODE || SQLERRM;

  END get_pos_supp_contact_bo_tbl;
  /*#
  * Use this routine to create supplier contact
  * @param p_api_version The version of API
  * @param p_init_msg_list The Initialization message list
  * @param p_pos_supplier_contact_bo_tbl The Supplier Contact BO table
  * @param p_party_id The Party Id
  * @param p_orig_system The Orig System
  * @param p_orig_system_reference The Orig System Reference
  * @param p_create_update_flag The Create Update Flag
  * @param x_vendor_contact_id The Vendor Contact Id
  * @param x_per_party_id  The Person Party ID
  * @param x_rel_party_id  The Rel Party Id
  * @param x_org_contact_id  The Organization contact id
  * @param x_party_site_id The Party Site Id
  * @param x_return_status The return status
  * @param x_msg_count The message count
  * @param x_msg_data The message data
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Create Supplier Contacts
  * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
  */
  PROCEDURE create_pos_supp_contact_bo
  (
    p_api_version                 IN NUMBER DEFAULT NULL,
    p_init_msg_list               IN VARCHAR2 DEFAULT NULL,
    p_pos_supplier_contact_bo_tbl IN pos_supplier_contact_bo_tbl,
    p_party_id                    IN NUMBER,
    p_orig_system                 IN VARCHAR2,
    p_orig_system_reference       IN VARCHAR2,
    p_create_update_flag          IN VARCHAR2,
    x_vendor_contact_id           OUT NOCOPY NUMBER,
    x_per_party_id                OUT NOCOPY NUMBER,
    x_rel_party_id                OUT NOCOPY NUMBER,
    x_rel_id                      OUT NOCOPY NUMBER,
    x_org_contact_id              OUT NOCOPY NUMBER,
    x_party_site_id               OUT NOCOPY NUMBER,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2
  ) IS

    l_step               VARCHAR2(100);
    p_vendor_contact_rec ap_vendor_pub_pkg.r_vendor_contact_rec_type;
    l_party_id           NUMBER;
    l_per_party_id       NUMBER;
  BEGIN

    IF p_party_id IS NULL THEN
      l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                         p_orig_system_reference);
    ELSE
      l_party_id := p_party_id;
    END IF;

    IF (l_party_id = 0) THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count     := 1;
      x_msg_data      := 'Party ID Invalid';
      RETURN;
    END IF;

    l_step := 'call ap_vendor_pub_pkg.create_vendor_contact';

    FOR i IN p_pos_supplier_contact_bo_tbl.first .. p_pos_supplier_contact_bo_tbl.last LOOP

      p_vendor_contact_rec.alt_area_code         := p_pos_supplier_contact_bo_tbl(i)
                                                    .alt_area_code;
      p_vendor_contact_rec.alt_phone             := p_pos_supplier_contact_bo_tbl(i)
                                                    .alt_phone;
      p_vendor_contact_rec.area_code             := p_pos_supplier_contact_bo_tbl(i)
                                                    .area_code;
      p_vendor_contact_rec.attribute_category    := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute_category;
      p_vendor_contact_rec.attribute1            := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute1;
      p_vendor_contact_rec.attribute10           := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute10;
      p_vendor_contact_rec.attribute11           := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute11;
      p_vendor_contact_rec.attribute12           := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute12;
      p_vendor_contact_rec.attribute13           := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute13;
      p_vendor_contact_rec.attribute14           := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute14;
      p_vendor_contact_rec.attribute15           := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute15;
      p_vendor_contact_rec.attribute2            := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute2;
      p_vendor_contact_rec.attribute3            := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute3;
      p_vendor_contact_rec.attribute4            := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute4;
      p_vendor_contact_rec.attribute5            := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute5;
      p_vendor_contact_rec.attribute6            := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute6;
      p_vendor_contact_rec.attribute7            := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute7;
      p_vendor_contact_rec.attribute8            := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute8;
      p_vendor_contact_rec.attribute9            := p_pos_supplier_contact_bo_tbl(i)
                                                    .attribute9;
      p_vendor_contact_rec.contact_name_phonetic := p_pos_supplier_contact_bo_tbl(i)
                                                    .contact_name_phonetic;
      p_vendor_contact_rec.department            := p_pos_supplier_contact_bo_tbl(i)
                                                    .department;
      p_vendor_contact_rec.email_address         := p_pos_supplier_contact_bo_tbl(i)
                                                    .email_address;

      p_vendor_contact_rec.fax_area_code       := p_pos_supplier_contact_bo_tbl(i)
                                                  .fax_area_code;
      p_vendor_contact_rec.fax_phone           := p_pos_supplier_contact_bo_tbl(i).fax;
      p_vendor_contact_rec.inactive_date       := p_pos_supplier_contact_bo_tbl(i)
                                                  .inactive_date;
      p_vendor_contact_rec.mail_stop           := p_pos_supplier_contact_bo_tbl(i)
                                                  .mail_stop;
      p_vendor_contact_rec.operating_unit_name := p_pos_supplier_contact_bo_tbl(i)
                                                  .operating_unit_name;
      p_vendor_contact_rec.org_contact_id      := p_pos_supplier_contact_bo_tbl(i)
                                                  .org_contact_id;
      p_vendor_contact_rec.org_id              := p_pos_supplier_contact_bo_tbl(i)
                                                  .org_id;

      p_vendor_contact_rec.org_party_site_id          := p_pos_supplier_contact_bo_tbl(i)
                                                         .org_party_site_id;
      p_vendor_contact_rec.organization_name_phonetic := p_pos_supplier_contact_bo_tbl(i)
                                                         .organization_name_phonetic;
      p_vendor_contact_rec.party_number               := p_pos_supplier_contact_bo_tbl(i)
                                                         .party_number;
      p_vendor_contact_rec.party_site_id              := p_pos_supplier_contact_bo_tbl(i)
                                                         .party_site_id;
      p_vendor_contact_rec.party_site_name            := p_pos_supplier_contact_bo_tbl(i)
                                                         .party_site_name;
      /* Suchita Change */
      IF (p_pos_supplier_contact_bo_tbl(i).per_party_id IS NULL) THEN
        l_per_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_pos_supplier_contact_bo_tbl(i)
                                                               .per_orig_system,
                                                               p_pos_supplier_contact_bo_tbl(i)
                                                               .per_orig_system_ref);
      ELSE
        l_per_party_id := p_pos_supplier_contact_bo_tbl(i).per_party_id;
      END IF;

      IF (l_per_party_id = 0) THEN
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_count     := 1;
        x_msg_data      := 'Person Party ID Invalid';
        RETURN;
      END IF;

      p_vendor_contact_rec.per_party_id := l_per_party_id;

      p_vendor_contact_rec.person_first_name          := p_pos_supplier_contact_bo_tbl(i)
                                                         .first_name;
      p_vendor_contact_rec.person_first_name_phonetic := p_pos_supplier_contact_bo_tbl(i)
                                                         .first_name_alt;
      p_vendor_contact_rec.person_last_name           := p_pos_supplier_contact_bo_tbl(i)
                                                         .last_name;
      p_vendor_contact_rec.person_last_name_phonetic  := p_pos_supplier_contact_bo_tbl(i)
                                                         .last_name_alt;
      p_vendor_contact_rec.person_middle_name         := p_pos_supplier_contact_bo_tbl(i)
                                                         .middle_name;
      p_vendor_contact_rec.person_title               := p_pos_supplier_contact_bo_tbl(i)
                                                         .title;
      p_vendor_contact_rec.phone                      := p_pos_supplier_contact_bo_tbl(i)
                                                         .phone;

      p_vendor_contact_rec.prefix                      := p_pos_supplier_contact_bo_tbl(i)
                                                          .prefix;
      p_vendor_contact_rec.rel_party_id                := p_pos_supplier_contact_bo_tbl(i)
                                                          .rel_party_id;
      p_vendor_contact_rec.relationship_id             := p_pos_supplier_contact_bo_tbl(i)
                                                          .relationship_id;
      p_vendor_contact_rec.url                         := p_pos_supplier_contact_bo_tbl(i).url;
      p_vendor_contact_rec.vendor_contact_id           := p_pos_supplier_contact_bo_tbl(i)
                                                          .vendor_contact_id;
      p_vendor_contact_rec.vendor_contact_interface_id := p_pos_supplier_contact_bo_tbl(i)
                                                          .vendor_contact_interface_id;
      p_vendor_contact_rec.vendor_id                   := p_pos_supplier_contact_bo_tbl(i)
                                                          .vendor_id;

      p_vendor_contact_rec.vendor_interface_id := p_pos_supplier_contact_bo_tbl(i)
                                                  .vendor_interface_id;
      p_vendor_contact_rec.vendor_site_code    := p_pos_supplier_contact_bo_tbl(i)
                                                  .vendor_site_code;
      p_vendor_contact_rec.vendor_site_id      := p_pos_supplier_contact_bo_tbl(i)
                                                  .vendor_site_id;

      IF (p_vendor_contact_rec.vendor_id IS NULL) THEN
        BEGIN
          SELECT vendor_id
          INTO   p_vendor_contact_rec.vendor_id
          FROM   ap_suppliers supp
          WHERE  supp.party_id = l_party_id;

        EXCEPTION
          WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
            RETURN;
        END;

      END IF;

      IF p_create_update_flag = 'U' THEN

        pos_supp_contact_pkg.update_supplier_contact(p_contact_party_id => p_vendor_contact_rec.per_party_id,
                                                     p_vendor_party_id  => l_party_id,
                                                     p_first_name       => p_vendor_contact_rec.person_first_name,
                                                     p_last_name        => p_vendor_contact_rec.person_last_name,
                                                     p_middle_name      => p_vendor_contact_rec.person_middle_name,
                                                     p_contact_title    => p_vendor_contact_rec.person_title,
                                                     p_job_title        => NULL,
                                                     p_phone_area_code  => p_vendor_contact_rec.area_code,
                                                     p_phone_number     => p_vendor_contact_rec.phone,
                                                     p_phone_extension  => NULL,
                                                     p_fax_area_code    => p_vendor_contact_rec.fax_area_code,
                                                     p_fax_number       => p_vendor_contact_rec.fax_phone,
                                                     p_email_address    => p_vendor_contact_rec.email_address,
                                                     p_inactive_date    => p_vendor_contact_rec.inactive_date,
                                                     x_return_status    => x_return_status,
                                                     x_msg_count        => x_msg_count,
                                                     x_msg_data         => x_msg_data,
                                                     p_department       => p_vendor_contact_rec.department);

        IF (p_vendor_contact_rec.org_party_site_id IS NOT NULL) THEN
          pos_supplier_address_pkg.assign_address_to_contact(p_contact_party_id  => p_vendor_contact_rec.per_party_id,
                                                             p_org_party_site_id => p_vendor_contact_rec.org_party_site_id,
                                                             p_vendor_id         => p_vendor_contact_rec.vendor_id,
                                                             x_return_status     => x_return_status,
                                                             x_msg_count         => x_msg_count,
                                                             x_msg_data          => x_msg_data);
        ELSE
          IF (p_vendor_contact_rec.party_site_name IS NOT NULL) THEN
            SELECT party_site_id
            INTO   p_vendor_contact_rec.org_party_site_id
            FROM   hz_party_sites
            WHERE  party_id = l_party_id
            AND    party_site_name = p_vendor_contact_rec.party_site_name;

            pos_supplier_address_pkg.assign_address_to_contact(p_contact_party_id  => p_vendor_contact_rec.per_party_id,
                                                               p_org_party_site_id => p_vendor_contact_rec.org_party_site_id,
                                                               p_vendor_id         => p_vendor_contact_rec.vendor_id,
                                                               x_return_status     => x_return_status,
                                                               x_msg_count         => x_msg_count,
                                                               x_msg_data          => x_msg_data);
          END IF;
        END IF;

      ELSIF p_create_update_flag = 'C' THEN

        ap_vendor_pub_pkg.create_vendor_contact(p_api_version,
                                                p_init_msg_list,
                                                fnd_api.g_false,
                                                fnd_api.g_valid_level_full,
                                                x_return_status,
                                                x_msg_count,
                                                x_msg_data,
                                                p_vendor_contact_rec,
                                                x_vendor_contact_id,
                                                x_per_party_id,
                                                x_rel_party_id,
                                                x_rel_id,
                                                x_org_contact_id,
                                                x_party_site_id);

      END IF;
      IF x_return_status IS NOT NULL AND
         x_return_status = fnd_api.g_ret_sts_success THEN
        -- succeed

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_procedure,
                         'pos_supplier_contact_bo_pkg.create_pos_supp_contact_bo',
                         l_step || ' x_return_status = ' || x_return_status ||
                         ' x_vendor_contact_id = ' || x_vendor_contact_id ||
                         ' x_per_party_id = ' || x_per_party_id ||
                         ' x_rel_party_id = ' || x_rel_party_id ||
                         ' x_rel_id = ' || x_rel_id ||
                         ' x_org_contact_id = ' || x_org_contact_id ||
                         ' x_party_site_id = ' || x_party_site_id);
        END IF;
      ELSE
        -- failed

        --ROLLBACK TO upd_vndr_contact;
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_error,
                         'pos_supplier_contact_bo_pkg.create_pos_supp_contact_bo',
                         l_step || ' x_return_status = ' || x_return_status ||
                         ', x_msg_count = ' || x_msg_count ||
                         ', x_msg_data = ' || x_msg_data);
        END IF;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
    WHEN fnd_api.g_exc_unexpected_error THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count     := 1;
      x_msg_data      := SQLCODE || SQLERRM;
    WHEN OTHERS THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      x_msg_count := 1;
      x_msg_data  := SQLCODE || SQLERRM;
  END;
/*
/*#
    * Use this routine to Update supplier contact
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_vendor_contact_rec The supplier contact record
    * @param x_vendor_contact_id The Vendor Contact Id
    * @param x_per_party_id  The Person Party ID
    * @param x_rel_party_id  The Rel Party Id
    * @param x_org_contact_id  The Organization contact id
    * @param x_party_site_id The Party Site Id
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Supplier Contact
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
/* PROCEDURE update_pos_supp_contact_bo(p_api_version        IN NUMBER DEFAULT NULL,
                                         p_init_msg_list      IN VARCHAR2 DEFAULT NULL,
                                         p_vendor_contact_rec IN ap_vendor_pub_pkg.r_vendor_contact_rec_type,
                                         x_vendor_contact_id  OUT NOCOPY NUMBER,
                                         x_per_party_id       OUT NOCOPY NUMBER,
                                         x_rel_party_id       OUT NOCOPY NUMBER,
                                         x_rel_id             OUT NOCOPY NUMBER,
                                         x_org_contact_id     OUT NOCOPY NUMBER,
                                         x_party_site_id      OUT NOCOPY NUMBER,
                                         x_return_status      OUT NOCOPY VARCHAR2,
                                         x_msg_count          OUT NOCOPY NUMBER,
                                         x_msg_data           OUT NOCOPY VARCHAR2) IS

        l_step VARCHAR2(100);
    BEGIN
        l_step := 'call ap_vendor_pub_pkg.update_vendor_contactt';
        SAVEPOINT upd_vndr_contact;
        ap_vendor_pub_pkg.update_vendor_contact(p_api_version        => 1.0,
                                                p_init_msg_list      => fnd_api.g_true,
                                                p_commit             => fnd_api.g_false,
                                                p_validation_level   => fnd_api.g_valid_level_full,
                                                p_vendor_contact_rec => p_vendor_contact_rec,
                                                x_return_status      => x_return_status,
                                                x_msg_count          => x_msg_count,
                                                x_msg_data           => x_msg_data);

        IF x_return_status IS NOT NULL AND
           x_return_status = fnd_api.g_ret_sts_success THEN
            -- succeed
            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_procedure,
                               'pos_supplier_contact_bo_pkg.create_pos_supp_contact_bo',
                               l_step || ' x_return_status = ' ||
                               x_return_status || ' x_vendor_contact_id = ' ||
                               x_vendor_contact_id || ' x_per_party_id = ' ||
                               x_per_party_id || ' x_rel_party_id = ' ||
                               x_rel_party_id || ' x_rel_id = ' || x_rel_id ||
                               ' x_org_contact_id = ' || x_org_contact_id ||
                               ' x_party_site_id = ' || x_party_site_id);
            END IF;
        ELSE
            -- failed
            ROLLBACK TO upd_vndr_contact;
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_error,
                               'pos_supplier_contact_bo_pkg.create_pos_supp_contact_bo',
                               l_step || ' x_return_status = ' ||
                               x_return_status || ', x_msg_count = ' ||
                               x_msg_count || ', x_msg_data = ' ||
                               x_msg_data);
            END IF;
        END IF;
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN

            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN fnd_api.g_exc_unexpected_error THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN OTHERS THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;

            x_msg_count := 1;
            x_msg_data  := SQLCODE || SQLERRM;
    END update_pos_supp_contact_bo;
*/
END pos_supplier_contact_bo_pkg;

/
