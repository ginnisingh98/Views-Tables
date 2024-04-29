--------------------------------------------------------
--  DDL for Package Body POS_BATCH_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_BATCH_IMPORT_PKG" AS
/* $Header: POSSUPIMPB.pls 120.0.12010000.49 2014/08/05 22:32:14 dalu noship $ */

  g_current_runtime_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
  g_level_procedure       CONSTANT NUMBER := fnd_log.level_procedure;
  g_module_name           CONSTANT VARCHAR2(100) := 'AP.PLSQL.POS_BATCH_IMPORT_PKG';

  g_source   VARCHAR2(30) := 'IMPORT';
  g_user_id  NUMBER(15) := fnd_global.user_id;
  g_login_id NUMBER(15) := fnd_global.login_id;

  l_error_msg_tbl error_handler.error_tbl_type;

  --Function: Insert_Rejections
  --This function is called whenever the process needs to insert a
  --rejection into new supplier interface rejection table.

  FUNCTION insert_rejections
  (
    p_batch_id          IN NUMBER,
    p_import_request_id IN NUMBER,
    p_parent_table      IN VARCHAR2,
    p_parent_id         IN NUMBER,
    p_reject_code       IN VARCHAR2,
    p_last_updated_by   IN NUMBER,
    p_last_update_login IN NUMBER,
    p_calling_sequence  IN VARCHAR2
  ) RETURN BOOLEAN IS

    l_current_calling_sequence VARCHAR2(2000);
    l_debug_info               VARCHAR2(500);
    l_api_name CONSTANT VARCHAR2(100) := 'INSERT_REJECTIONS';

  BEGIN
    -- Update the calling sequence
    l_current_calling_sequence := 'POS_BATCH_IMPORT_PKG.Insert_rejections<-' ||
                                  p_calling_sequence;

    IF (g_level_procedure >= g_current_runtime_level) THEN
      fnd_log.string(g_level_procedure,
                     g_module_name || l_api_name,
                     'Parameters: ' || ' p_parent_table: ' ||
                     p_parent_table || ', p_parent_id: ' ||
                     to_char(p_parent_id) || ', p_reject_code: ' ||
                     p_reject_code);
    END IF;

    INSERT INTO pos_supplier_int_rejections
      (batch_id,
       import_request_id,
       parent_table,
       parent_id,
       reject_lookup_code,
       last_updated_by,
       last_update_date,
       last_update_login,
       created_by,
       creation_date)
    VALUES
      (p_batch_id,
       p_import_request_id,
       p_parent_table,
       p_parent_id,
       p_reject_code,
       p_last_updated_by,
       SYSDATE,
       p_last_update_login,
       p_last_updated_by,
       SYSDATE);

    RETURN(TRUE);

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        fnd_message.set_name('SQLAP', 'AP_DEBUG');
        fnd_message.set_token('ERROR', SQLERRM);
        fnd_message.set_token('CALLING_SEQUENCE',
                              l_current_calling_sequence);
        fnd_message.set_token('DEBUG_INFO', l_debug_info);
      END IF;

      IF (g_level_procedure >= g_current_runtime_level) THEN
        fnd_log.string(g_level_procedure,
                       g_module_name || l_api_name,
                       SQLERRM);
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' Inside INSERT_REJECTIONS EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);

      RETURN(FALSE);

  END insert_rejections;

  -- Function to get the Party Id based on
  -- the Source System information passed to it
  --
  FUNCTION get_party_id
  (
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2
  ) RETURN NUMBER AS
    l_party_id NUMBER;
  BEGIN
    SELECT owner_table_id
    INTO   l_party_id
    FROM   hz_orig_sys_references hr
    WHERE  hr.owner_table_name = 'HZ_PARTIES'
    AND    hr.orig_system = p_orig_system
    AND    hr.orig_system_reference = p_orig_system_reference
    AND    hr.status = 'A'
    AND    nvl(hr.end_date_active, SYSDATE) >= SYSDATE;

    RETURN l_party_id;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,
                        ' Inside get_party_id EXCEPTION ' || ' Message: ' ||
                        SQLCODE || ' ' || SQLERRM);
      RETURN 0;
  END get_party_id;

  PROCEDURE check_party_exist
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_insert_count NUMBER(10);

  BEGIN
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Check if party is present for the perticular batch id,
    -- source id, source reference in cross reference table and update the ap_suppliers_int table
    UPDATE ap_suppliers_int supp
    SET    party_id =
           (SELECT party_id
            FROM   hz_orig_sys_references hr
            WHERE  hr.owner_table_name = 'HZ_PARTIES'
            AND    hr.orig_system = supp.party_orig_system
            AND    hr.orig_system_reference =
                   supp.party_orig_system_reference
            AND    hr.status = 'A'
            AND    nvl(hr.end_date_active, SYSDATE) >= SYSDATE)
    WHERE  party_id IS NULL
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED';

    -- If the party record is not present insert data into
    -- HZ_IMP_PARTIES_INT table using AP_SUPPLIERS_INT.
    INSERT INTO hz_imp_parties_int
      (batch_id,
       party_orig_system,
       party_orig_system_reference,
       created_by_module,
       --application_id,
       party_type,
       organization_name,
       organization_name_phonetic,
       jgzz_fiscal_code,
       tax_reference,
       ceo_name,
       ceo_title,
       party_id)  -- Bug 18447589: Copy party_id to HZ so that user-entered records can be updated/enriched by third-party data.
      SELECT sdh_batch_id,
             party_orig_system,
             party_orig_system_reference,
             'AP_SUPPLIERS_API',
             --200,
             'ORGANIZATION',
             vendor_name,
             vendor_name_alt,
             num_1099,
             vat_registration_num,
             ceo_name,
             ceo_title,
             party_id
      FROM   ap_suppliers_int supp
      WHERE  /* party_id IS NULL AND */
       sdh_batch_id = p_batch_id
       AND    nvl(status, 'ACTIVE') <> 'PROCESSED'
       AND    NOT EXISTS (SELECT *
        FROM   hz_imp_parties_int hp
        WHERE  hp.batch_id = supp.sdh_batch_id
        AND    hp.party_orig_system = supp.party_orig_system
        AND    hp.party_orig_system_reference =
               supp.party_orig_system_reference);

    l_insert_count := SQL%ROWCOUNT;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE check_party_exist' ||
                      ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                      ' Rows inserted in hz_imp_parties_int: ' ||
                      l_insert_count);

    IF (l_insert_count > 0) THEN
      -- Update hz_imp_batch_summary with the count of the records inserted into interface table.
      UPDATE hz_imp_batch_summary
      SET    total_batch_records      = total_batch_records + l_insert_count,
             total_records_for_import = total_records_for_import +
                                        l_insert_count,
             parties_in_batch         = parties_in_batch + l_insert_count
      WHERE  batch_id = p_batch_id;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('SQLAP', 'AP_INVALID_PARTY');
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside check_party_exist EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END check_party_exist;

  PROCEDURE check_party_site_exist
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_insert_count NUMBER(10);

  BEGIN
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Check for the existence of the site and location from the hz cross ref table
    -- and update the ap_supplier_sites_in table using below query

    UPDATE ap_supplier_sites_int supp
    SET    party_site_id =
           (SELECT owner_table_id
            FROM   hz_orig_sys_references hr
            WHERE  hr.owner_table_name = 'HZ_PARTY_SITES'
            AND    hr.party_id = supp.party_id   -- Bug 14772702: Same site orig reference can exist under different suppliers
            AND    hr.orig_system = supp.party_site_orig_system
            AND    hr.orig_system_reference =
                   supp.party_site_orig_sys_reference
            AND    hr.status = 'A'
            AND    nvl(hr.end_date_active, SYSDATE) >= SYSDATE)
    WHERE  party_site_id IS NULL
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED';

 --Bug 13086851 language code issue: The input language that we get from ap_supplier_sites_int will be NLS_LANGUAGE(varchar 30)
 --and will not be language code((varchar 4). So it needs to be converted to language_code before inserting to hz_imp_addresses_int .

 --bug 12689121 missing address_line4, county, language during insert to interface

 --Bug 14772702: party_id should be populated into hz_imp_address_int as it is part of unique index
 --Same site orig reference can exist under different suppliers
    INSERT INTO hz_imp_addresses_int
      (batch_id,
       party_orig_system,
       party_orig_system_reference,
       site_orig_system,
       site_orig_system_reference,
       party_site_name,
       address1,
       address_lines_phonetic,
       address2,
       address3,
       address4,
       city,
       state,
       country,
       province,
       county,
       postal_code,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       language,
       party_id,
       correct_move_indicator)   --BUG 16200981 Specify correct mode when doing update
      SELECT sdh_batch_id,
             party_orig_system,
             party_orig_system_reference,
             party_site_orig_system,
             party_site_orig_sys_reference,
             NVL(party_site_name, vendor_site_code), -- Bug 14088081: should populate party_site_name to TCA table as we already have such column.
             address_line1,
             address_lines_alt,
             address_line2,
             address_line3,
             address_line4,
             city,
             state,
             country,
             province,
             county,
             zip,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login,
             language_code,
             party_id,
             'C'    --BUG 16200981 Specify correct mode when doing update
      FROM   (SELECT sdh_batch_id,
                      party_orig_system,
                      party_orig_system_reference,
                      party_site_orig_system,
                      party_site_orig_sys_reference,
                      /*nvl(party_site_orig_system, supplier_site_orig_system) party_site_orig_system,
                      nvl(party_site_orig_sys_reference,
                          sup_site_orig_system_reference) party_site_orig_sys_reference,*/
                      vendor_site_code,
                      party_site_name,
                      address_line1,
                      address_lines_alt,
                      address_line2,
                      address_line3,
                      address_line4,
                      city,
                      state,
                      country,
                      province,
                      county,
                      zip,
                      hz_utility_v2pub.created_by,
                      hz_utility_v2pub.creation_date,
                      hz_utility_v2pub.last_updated_by,
                      hz_utility_v2pub.last_update_date,
                      hz_utility_v2pub.last_update_login,
                      LANG.LANGUAGE_CODE,
                      party_id,
                      dense_rank() over(PARTITION BY sdh_batch_id, party_site_orig_system, party_site_orig_sys_reference, party_id ORDER BY SUPP.ROWID) rnk
               FROM   ap_supplier_sites_int supp, FND_LANGUAGES LANG
               WHERE  /* party_site_id IS NULL AND */
                sdh_batch_id = p_batch_id  AND supp.language = lang.nls_language(+)
             AND    nvl(status, 'ACTIVE') <> 'PROCESSED'
             AND    NOT EXISTS
                (SELECT *
                 FROM   hz_imp_addresses_int hp
                 WHERE  hp.batch_id = supp.sdh_batch_id
                 AND    hp.party_orig_system = supp.party_orig_system
                 AND    hp.party_orig_system_reference =
                        supp.party_orig_system_reference
                 AND    hp.site_orig_system = supp.party_site_orig_system
                 AND    hp.site_orig_system_reference =
                        supp.party_site_orig_sys_reference))
      WHERE  rnk = 1;

    l_insert_count := SQL%ROWCOUNT;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE check_party_site_exist' ||
                      ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                      ' Rows inserted in hz_imp_addresses_int: ' ||
                      l_insert_count);

    IF (l_insert_count > 0) THEN
      -- Update hz_imp_batch_summary with the count of the records inserted into interface table.
      UPDATE hz_imp_batch_summary
      SET    total_batch_records      = total_batch_records + l_insert_count,
             total_records_for_import = total_records_for_import +
                                        l_insert_count,
             addresses_in_batch       = addresses_in_batch + l_insert_count
      WHERE  batch_id = p_batch_id;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('SQLAP', 'AP_INVALID_PARTY_SITE');
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside check_party_site_exist EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END check_party_site_exist;

  PROCEDURE check_party_contact_exist
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    -- l_party_id     NUMBER;
    l_insert_count NUMBER;
  BEGIN

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    UPDATE ap_sup_site_contact_int supp
    SET    per_party_id =
           (SELECT party_id
            FROM   hz_orig_sys_references hr
            WHERE  hr.owner_table_name = 'HZ_PARTIES'
            AND    hr.orig_system = supp.contact_orig_system
            AND    hr.orig_system_reference =
                   supp.contact_orig_system_reference
            AND    hr.status = 'A'
            AND    nvl(hr.end_date_active, SYSDATE) >= SYSDATE)
    WHERE  per_party_id IS NULL
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED';

    -- If the party record is not present insert data into
    -- HZ_IMP_PARTIES_INT table using AP_SUPPLIERS_INT.
    INSERT INTO hz_imp_parties_int
      (batch_id,
       party_orig_system,
       party_orig_system_reference,
       created_by_module,
       --application_id,
       party_type,
       organization_name,
       organization_name_phonetic,
       person_first_name,
       person_last_name,
       --Bug 13392627
       person_middle_name,
       person_pre_name_adjunct
       --person_title
       --jgzz_fiscal_code,
       --tax_reference
       )
      SELECT sdh_batch_id,
             contact_orig_system,
             contact_orig_system_reference,
             'AP_SUPPLIERS_API',
             'PERSON',
             org_name,
             org_name_alt,
             first_name,
             last_name,
	     middle_name,
	     prefix
      FROM   (SELECT sdh_batch_id,
                      contact_orig_system,
                      contact_orig_system_reference,
                      'AP_SUPPLIERS_API',
                      --200,
                      'PERSON',
                      supp.first_name || ' ' || supp.last_name org_name,
                      supp.first_name_alt || ' ' || supp.last_name_alt org_name_alt,
                      supp.first_name,
                      supp.last_name,
		      supp.middle_name,
		      supp.prefix,
                      dense_rank() over(PARTITION BY sdh_batch_id, contact_orig_system, contact_orig_system_reference, party_id ORDER BY ROWID) rnk
               --num_1099,
               --vat_registration_num
               FROM   ap_sup_site_contact_int supp
               WHERE  /* per_party_id IS NULL AND */
                sdh_batch_id = p_batch_id
             AND    nvl(status, 'ACTIVE') <> 'PROCESSED'
             AND    NOT EXISTS
                (SELECT *
                 FROM   hz_imp_parties_int hp
                 WHERE  hp.batch_id = supp.sdh_batch_id
                 AND    hp.party_orig_system = supp.contact_orig_system
                 AND    hp.party_orig_system_reference =
                        supp.contact_orig_system_reference))
      WHERE  rnk = 1;

    l_insert_count := SQL%ROWCOUNT;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE check_party_contact_exist' ||
                      ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                      ' Rows inserted in hz_imp_parties_int: ' ||
                      l_insert_count);

    IF (l_insert_count > 0) THEN
      -- Update hz_imp_batch_summary with the count of the records inserted into interface table.
      UPDATE hz_imp_batch_summary
      SET    total_batch_records      = total_batch_records + l_insert_count,
             total_records_for_import = total_records_for_import +
                                        l_insert_count,
             parties_in_batch         = parties_in_batch + l_insert_count
      WHERE  batch_id = p_batch_id;
    END IF;

    l_insert_count := 0;

    INSERT INTO hz_imp_contacts_int
      (batch_id,
       contact_orig_system,
       contact_orig_system_reference,
       sub_orig_system,
       sub_orig_system_reference,
       obj_orig_system,
       obj_orig_system_reference,
       start_date,
       created_by_module,
       contact_number,
       relationship_type,
       relationship_code,
       creation_date,
       insert_update_flag,
       department,  --Bug 13392627
       JOB_TITLE
       )

      SELECT sdh_batch_id,
             contact_orig_system,
             contact_orig_system_reference,
             contact_orig_system,
             contact_orig_system_reference,
             party_orig_system,
             party_orig_system_reference,
             SYSDATE,
             'AP_SUPPLIERS_API',
             supp.first_name || ' ' || supp.last_name,
             'CONTACT',
             'CONTACT_OF',
             SYSDATE,
             'I',
	     department,
             title
      FROM   ap_sup_site_contact_int supp
      WHERE  per_party_id IS NULL
      AND    sdh_batch_id = p_batch_id
      AND    nvl(status, 'ACTIVE') <> 'PROCESSED'
      AND    NOT EXISTS
       (SELECT *
              FROM   hz_imp_contacts_int hp
              WHERE  hp.batch_id = supp.sdh_batch_id
              AND    hp.contact_orig_system = supp.contact_orig_system
              AND    hp.contact_orig_system_reference =
                     supp.contact_orig_system_reference)
      UNION
      SELECT sdh_batch_id,
             contact_orig_system,
             contact_orig_system_reference,
             contact_orig_system,
             contact_orig_system_reference,
             party_orig_system,
             party_orig_system_reference,
             SYSDATE,
             'AP_SUPPLIERS_API',
             supp.first_name || ' ' || supp.last_name,
             'CONTACT',
             'CONTACT_OF',
             SYSDATE,
             'U',
	     department,
             title
      FROM   ap_sup_site_contact_int supp
      WHERE  per_party_id IS NOT NULL
      AND    sdh_batch_id = p_batch_id
      AND    nvl(status, 'ACTIVE') <> 'PROCESSED'
      AND    NOT EXISTS
       (SELECT *
              FROM   hz_imp_contacts_int hp
              WHERE  hp.batch_id = supp.sdh_batch_id
              AND    hp.contact_orig_system = supp.contact_orig_system
              AND    hp.contact_orig_system_reference =
                     supp.contact_orig_system_reference);

    l_insert_count := SQL%ROWCOUNT;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE check_party_contact_exist' ||
                      ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                      ' Rows inserted in hz_imp_contacts_int: ' ||
                      l_insert_count);

    IF (l_insert_count > 0) THEN
      -- Update hz_imp_batch_summary with the count of the records inserted into interface table.
      UPDATE hz_imp_batch_summary
      SET    total_batch_records      = total_batch_records + l_insert_count,
             total_records_for_import = total_records_for_import +
                                        l_insert_count,
             contacts_in_batch        = contacts_in_batch + l_insert_count
      WHERE  batch_id = p_batch_id;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      fnd_file.put_line(fnd_file.log,
                        ' Inside check_party_contact_exist EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END check_party_contact_exist;

  PROCEDURE validate_vendor
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'VALIDATE_VENDOR';
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_return_status VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_vendor_id     NUMBER;
    l_party_id      NUMBER;
    l_error_id      NUMBER;

    l_party_valid VARCHAR2(1);
    l_payee_valid VARCHAR2(1);

    vendor_rec ap_vendor_pub_pkg.r_vendor_rec_type;

    CURSOR party_int_cur IS
      SELECT ROWID,
             organization_name,
             organization_name_phonetic,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             party_id,
             party_orig_system,
             party_orig_system_reference,
             insert_update_flag
      FROM   hz_imp_parties_int hp
      WHERE  batch_id = p_batch_id
            /* Status for the data should not be E or C
            i.e. Errored out or Completed */
      AND    interface_status IS NULL
      AND    party_type = 'ORGANIZATION'
      AND    NOT EXISTS
       (SELECT *
              FROM   ap_suppliers_int supp
              WHERE  hp.batch_id = supp.sdh_batch_id
              AND    hp.party_orig_system = supp.party_orig_system
              AND    hp.party_orig_system_reference =
                     supp.party_orig_system_reference);

    party_int_rec party_int_cur%ROWTYPE;

    l_vendor_num_code financials_system_parameters.user_defined_vendor_num_code%TYPE;

    CURSOR check_vendor_exists(cp_party_id IN NUMBER) IS
      SELECT 1,
             vendor_id
      FROM   ap_suppliers
      WHERE  party_id = cp_party_id;

    l_vendor_exists NUMBER := 0;
  BEGIN
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    DELETE ap_supplier_int_rejections
    WHERE  parent_table = 'AP_SUPPLIERS_INT';

    fnd_file.put_line(fnd_file.log,
                      ' Validating vendor record before the party is created. ');
    OPEN party_int_cur;

    LOOP
      FETCH party_int_cur
        INTO party_int_rec;

      EXIT WHEN party_int_cur%NOTFOUND;

      vendor_rec.vendor_name        := party_int_rec.organization_name;
      vendor_rec.vendor_name_alt    := party_int_rec.organization_name_phonetic;
      vendor_rec.attribute_category := party_int_rec.attribute_category;
      vendor_rec.attribute1         := party_int_rec.attribute1;
      vendor_rec.attribute2         := party_int_rec.attribute2;
      vendor_rec.attribute3         := party_int_rec.attribute3;
      vendor_rec.attribute4         := party_int_rec.attribute4;
      vendor_rec.attribute5         := party_int_rec.attribute5;
      vendor_rec.attribute6         := party_int_rec.attribute6;
      vendor_rec.attribute7         := party_int_rec.attribute7;
      vendor_rec.attribute8         := party_int_rec.attribute8;
      vendor_rec.attribute9         := party_int_rec.attribute9;
      vendor_rec.attribute10        := party_int_rec.attribute10;
      vendor_rec.attribute11        := party_int_rec.attribute11;
      vendor_rec.attribute12        := party_int_rec.attribute12;
      vendor_rec.attribute13        := party_int_rec.attribute13;
      vendor_rec.attribute14        := party_int_rec.attribute14;
      vendor_rec.attribute15        := party_int_rec.attribute15;

      vendor_rec.ext_payee_rec.payment_function := 'PAYABLES_DISB';
      vendor_rec.ext_payee_rec.payer_org_type   := 'OPERATING_UNIT';

      /* Get the party id for orig system and orig system reference combination */

      vendor_rec.party_id := get_party_id(party_int_rec.party_orig_system,
                                          party_int_rec.party_orig_system_reference);

      IF (vendor_rec.party_id = 0) THEN
        vendor_rec.party_id := NULL;
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE validate_vendor' ||
                        ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                        ' Party id : ' || vendor_rec.party_id ||
                        ' from get_party_id');

      -- Check if the Vendor number is AutoNumbered.
      -- If the method is set to Manual then the vendor
      -- number would be mapped to the Orig System reference.
      --
      l_vendor_num_code := chk_vendor_num_nmbering_method();

      IF (l_vendor_num_code = 'MANUAL') THEN
        vendor_rec.segment1 := party_int_rec.party_orig_system_reference;
      END IF;

      -- Setting the vendor source as IMPORT so that the
      -- errors are logged in the rejections table
      --
      ap_vendor_pub_pkg.g_source := 'IMPORT';

      -- Check if the vendor already exists
      OPEN check_vendor_exists(vendor_rec.party_id);
      FETCH check_vendor_exists
        INTO l_vendor_exists,
             l_vendor_id;
      CLOSE check_vendor_exists;

      -- If the vendor exists then Sync it with the party information
      IF l_vendor_exists <> 0 THEN
        l_vendor_exists := 0;

        /* Call validate vendor in update mode */
        ap_vendor_pub_pkg.validate_vendor(p_api_version   => 1.0,
                                          p_init_msg_list => fnd_api.g_false,
                                          p_commit        => fnd_api.g_false,
                                          x_return_status => l_return_status,
                                          x_msg_count     => l_msg_count,
                                          x_msg_data      => l_msg_data,
                                          p_vendor_rec    => vendor_rec,
                                          p_mode          => 'U',
                                          p_calling_prog  => 'NOT ISETUP',
                                          x_party_valid   => l_party_valid,
                                          x_payee_valid   => l_payee_valid,
                                          p_vendor_id     => l_vendor_id);
      ELSE
        /* Call validate vendor in insert mode */
        ap_vendor_pub_pkg.validate_vendor(p_api_version   => 1.0,
                                          p_init_msg_list => fnd_api.g_false,
                                          p_commit        => fnd_api.g_false,
                                          x_return_status => l_return_status,
                                          x_msg_count     => l_msg_count,
                                          x_msg_data      => l_msg_data,
                                          p_vendor_rec    => vendor_rec,
                                          p_mode          => 'I',
                                          p_calling_prog  => 'NOT ISETUP',
                                          x_party_valid   => l_party_valid,
                                          x_payee_valid   => l_payee_valid,
                                          p_vendor_id     => l_vendor_id);
      END IF;

      IF (l_return_status <> fnd_api.g_ret_sts_success /*OR l_party_valid <> 'Y'*/
         ) THEN
        INSERT INTO pos_supplier_int_rejections
          (batch_id,
           import_request_id,
           parent_table,
           parent_id,
           reject_lookup_code,
           last_updated_by,
           last_update_date,
           last_update_login,
           created_by,
           creation_date)
          SELECT p_batch_id,
                 l_request_id,
                 parent_table,
                 parent_id,
                 reject_lookup_code,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 created_by,
                 creation_date
          FROM   ap_supplier_int_rejections
          WHERE  parent_table = 'AP_SUPPLIERS_INT';

        IF (g_level_procedure >= g_current_runtime_level) THEN
          fnd_log.string(g_level_procedure,
                         g_module_name || l_api_name,
                         ' No. of Messages from validate_vendor API: ' ||
                         l_msg_count ||
                         ', Message From validate_vendor API: ' ||
                         l_msg_data);
        END IF;

        INSERT INTO hz_imp_errors
          (creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           program_application_id,
           program_id,
           program_update_date,
           error_id,
           batch_id,
           request_id,
           interface_table_name,
           message_name,
           token1_name,
           token1_value)
        VALUES
          (SYSDATE,
           g_user_id,
           SYSDATE,
           g_user_id,
           g_user_id,
           NULL,
           NULL,
           SYSDATE,
           hz_imp_errors_s.nextval,
           p_batch_id,
           NULL,
           'HZ_IMP_PARTIES_INT',
           'AR_ALL_DUP_NAME',
           'ORGANIZATION_NAME',
           party_int_rec.organization_name)
        RETURNING error_id INTO l_error_id;

        UPDATE hz_imp_parties_int
        SET    interface_status = 'E',
               error_id         = l_error_id
        WHERE  ROWID = party_int_rec.rowid;

        fnd_file.put_line(fnd_file.log,
                          'Error Message Count: ' || x_msg_count ||
                          ' Error Message Data: ' || x_msg_data ||
                          ' From ap_vendor_pub_pkg.validate_vendor API for party id: ' ||
                          vendor_rec.party_id ||
                          ' or for party_orig_system_reference: ' ||
                          party_int_rec.party_orig_system_reference);

        x_return_status := l_return_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
      END IF;

    END LOOP;

    CLOSE party_int_cur;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('SQLAP', 'AP_INVALID_PARTY');
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      fnd_file.put_line(fnd_file.log,
                        ' Inside validate_vendor EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END validate_vendor;

  PROCEDURE update_contact_dtls
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS

    l_per_party_id    NUMBER(15);
    l_org_party_id    NUMBER(15);
    l_relationship_id NUMBER(15);
    l_rel_party_id    NUMBER(15);
    l_org_contact_id  NUMBER(15);

    CURSOR supp_contact_int_cur IS
      SELECT *
      FROM   ap_sup_site_contact_int supp
      WHERE  sdh_batch_id = p_batch_id
      AND    nvl(status, 'ACTIVE') NOT IN ('PROCESSED', 'REMOVED')
      AND    NOT EXISTS
       (SELECT 1
              FROM   hz_imp_contacts_int party
              WHERE  batch_id = p_batch_id
              AND    supp.sdh_batch_id = party.batch_id
              AND    supp.party_orig_system = party.obj_orig_system
              AND    supp.party_orig_system_reference =
                     party.obj_orig_system_reference
              AND    supp.contact_orig_system = party.contact_orig_system
              AND    supp.contact_orig_system_reference =
                     party.contact_orig_system_reference
              AND    party.interface_status = 'R');

    supp_contact_int_rec supp_contact_int_cur%ROWTYPE;

  BEGIN

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN supp_contact_int_cur;
    LOOP
      FETCH supp_contact_int_cur
        INTO supp_contact_int_rec;

      EXIT WHEN supp_contact_int_cur%NOTFOUND;

      IF (supp_contact_int_rec.party_id IS NULL) THEN
        l_org_party_id := get_party_id(supp_contact_int_rec.party_orig_system,
                                       supp_contact_int_rec.party_orig_system_reference);

        UPDATE ap_sup_site_contact_int
        SET    party_id = l_org_party_id
        WHERE  vendor_contact_interface_id =
               supp_contact_int_rec.vendor_contact_interface_id
        AND    sdh_batch_id = p_batch_id;
      ELSE
        l_org_party_id := supp_contact_int_rec.party_id;
      END IF;

      -- Using the Contact first name and last name execute the
      -- following SQL to yield the per_party_id
      IF (supp_contact_int_rec.per_party_id IS NULL) THEN
        l_per_party_id := get_party_id(supp_contact_int_rec.contact_orig_system,
                                       supp_contact_int_rec.contact_orig_system_reference);
        IF (l_per_party_id = 0) THEN
          SELECT party_id
          INTO   l_per_party_id
          FROM   hz_parties
          WHERE  party_name = supp_contact_int_rec.first_name || ' ' ||
                 supp_contact_int_rec.last_name
          AND    party_type = 'PERSON';
          /*AND    orig_system_reference =
          supp_contact_int_rec.party_orig_system_reference*/

        END IF;

        UPDATE ap_sup_site_contact_int
        SET    per_party_id = l_per_party_id
        WHERE  vendor_contact_interface_id =
               supp_contact_int_rec.vendor_contact_interface_id
        AND    sdh_batch_id = p_batch_id;
      ELSE
        l_per_party_id := supp_contact_int_rec.per_party_id;
      END IF;

      IF (supp_contact_int_rec.relationship_id IS NULL OR
         supp_contact_int_rec.rel_party_id IS NULL) THEN

        SELECT relationship_id,
               party_id
        INTO   l_relationship_id,
               l_rel_party_id
        FROM   hz_relationships
        WHERE  subject_id = l_org_party_id
        AND    subject_type = 'ORGANIZATION'
        AND    object_id = l_per_party_id
        AND    object_type = 'PERSON';

        UPDATE ap_sup_site_contact_int
        SET    relationship_id = l_relationship_id,
               rel_party_id    = l_rel_party_id
        WHERE  vendor_contact_interface_id =
               supp_contact_int_rec.vendor_contact_interface_id
        AND    sdh_batch_id = p_batch_id;
      ELSE
        l_relationship_id := supp_contact_int_rec.relationship_id;
        l_rel_party_id    := supp_contact_int_rec.rel_party_id;
      END IF;

      IF (supp_contact_int_rec.org_contact_id IS NULL) THEN

        SELECT org_contact_id
        INTO   l_org_contact_id
        FROM   hz_org_contacts
        WHERE  party_relationship_id = l_relationship_id;

        UPDATE ap_sup_site_contact_int
        SET    org_contact_id = l_org_contact_id
        WHERE  vendor_contact_interface_id =
               supp_contact_int_rec.vendor_contact_interface_id
        AND    sdh_batch_id = p_batch_id;
      END IF;
    END LOOP;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE update_contact_dtls' ||
                      ' Updated details for vendor_contact_interface_id: ' ||
                      supp_contact_int_rec.vendor_contact_interface_id ||
                      ' party_id: ' || l_org_party_id || ' per_party_id: ' ||
                      l_per_party_id || ' relationship_id: ' ||
                      l_relationship_id || ' rel_party_id: ' ||
                      l_rel_party_id || ' org_contact_id: ' ||
                      l_org_contact_id);

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('SQLAP', 'AP_INVALID_PARTY');
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      fnd_file.put_line(fnd_file.log,
                        ' Inside update_contact_dtls EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END update_contact_dtls;

  PROCEDURE update_party_id
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    UPDATE ap_suppliers_int supp
    SET    supp.party_id =
           (SELECT party_id
            FROM   hz_orig_sys_references hr
            WHERE  hr.owner_table_name = 'HZ_PARTIES'
            AND    hr.orig_system = supp.party_orig_system
            AND    hr.orig_system_reference =
                   supp.party_orig_system_reference
            AND    hr.status = 'A'
            AND    nvl(hr.end_date_active, SYSDATE) >= SYSDATE)
    WHERE  supp.party_id IS NULL
    AND    supp.sdh_batch_id = p_batch_id;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('SQLAP', 'AP_INVALID_PARTY');
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      fnd_file.put_line(fnd_file.log,
                        ' Inside update_party_id EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END update_party_id;

  PROCEDURE update_party_site_id
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    UPDATE ap_supplier_sites_int supp
    SET    supp.party_id =
           (SELECT party_id
            FROM   hz_orig_sys_references hr
            WHERE  hr.owner_table_name = 'HZ_PARTIES'
            AND    hr.orig_system = supp.party_orig_system
            AND    hr.orig_system_reference =
                   supp.party_orig_system_reference
            AND    hr.status = 'A'
            AND    nvl(hr.end_date_active, SYSDATE) >= SYSDATE)
    WHERE  supp.party_id IS NULL
    AND    supp.sdh_batch_id = p_batch_id;

    UPDATE ap_supplier_sites_int supp
    SET    party_site_id =
           (SELECT owner_table_id
            FROM   hz_orig_sys_references hr
            WHERE  hr.owner_table_name = 'HZ_PARTY_SITES'
            AND    hr.orig_system = supp.party_site_orig_system
            AND    hr.orig_system_reference =
                   supp.party_site_orig_sys_reference
            AND    hr.status = 'A'
            AND    nvl(hr.end_date_active, SYSDATE) >= SYSDATE)
    WHERE  supp.party_site_id IS NULL
    AND    supp.sdh_batch_id = p_batch_id;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('SQLAP', 'AP_INVALID_PARTY');
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      fnd_file.put_line(fnd_file.log,
                        ' Inside update_party_site_id EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END update_party_site_id;

  --
  -- Function to get the Vendor Number
  -- NUmbering technique
  --
  FUNCTION chk_vendor_num_nmbering_method RETURN VARCHAR2 IS

    l_ven_num_code financials_system_parameters.user_defined_vendor_num_code%TYPE;

  BEGIN
    SELECT supplier_numbering_method
    INTO   l_ven_num_code
    FROM   ap_product_setup;

    RETURN l_ven_num_code;

  END chk_vendor_num_nmbering_method;

  PROCEDURE pre_processing
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'PRE_PROCESSING';
    l_msg_count NUMBER;

  BEGIN
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Check if the party exist for the supplier to be imported by
    -- using cross reference table
    /* AP to HZ started */
    check_party_exist(p_batch_id      => p_batch_id,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_file.put_line(fnd_file.log,
                        'Error Message Count: ' || x_msg_count ||
                        ' Error Message Data: ' || x_msg_data ||
                        ' From check_party_exist API.');
      RETURN;
    END IF;

    check_party_site_exist(p_batch_id      => p_batch_id,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_file.put_line(fnd_file.log,
                        'Error Message Count: ' || x_msg_count ||
                        ' Error Message Data: ' || x_msg_data ||
                        ' From check_party_site_exist API.');
      RETURN;
    END IF;

    check_party_contact_exist(p_batch_id      => p_batch_id,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_file.put_line(fnd_file.log,
                        'Error Message Count: ' || x_msg_count ||
                        ' Error Message Data: ' || x_msg_data ||
                        ' From check_party_contact_exist API.');
      RETURN;
    END IF;

    /* AP to HZ ended */

    -- If party or sites or contacts are not present then above APIs will
    -- Bulk insert data in party interface tables from supplier interface tables

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('SQLAP', 'AP_INVALID_PARTY');
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      fnd_file.put_line(fnd_file.log,
                        ' Inside pre_processing EXCEPTION ' || ' Message: ' ||
                        SQLCODE || ' ' || SQLERRM);
  END pre_processing;

  -- This procedure would enable the successfully
  -- imported parties in a batch as Suppliers
  --
  PROCEDURE enable_party_as_supplier
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'ENABLE_PARTY_AS_SUPPLIER';
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_return_status VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_vendor_id     NUMBER;
    l_party_id      NUMBER;

    vendor_rec ap_vendor_pub_pkg.r_vendor_rec_type;

    CURSOR party_int_cur IS
      SELECT organization_name,
             organization_name_phonetic,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             party_id,
             party_orig_system,
             party_orig_system_reference,
             insert_update_flag
      FROM   hz_imp_parties_int hp
      WHERE  batch_id = p_batch_id
            /* Status for the data should not be E or C
            i.e. Errored out or Completed */
      AND    interface_status IS NULL
      AND    party_type = 'ORGANIZATION'
      AND    NOT EXISTS
       (SELECT *
              FROM   ap_suppliers_int supp
              WHERE  hp.batch_id = supp.sdh_batch_id
              AND    hp.party_orig_system = supp.party_orig_system
              AND    hp.party_orig_system_reference =
                     supp.party_orig_system_reference);

    party_int_rec party_int_cur%ROWTYPE;

    l_vendor_num_code financials_system_parameters.user_defined_vendor_num_code%TYPE;

    -- Added Sync Party Related return variables
    --
    l_sync_return_status VARCHAR2(50);
    l_sync_msg_count     NUMBER;
    l_sync_msg_data      VARCHAR2(1000);

    --
    -- bug 9049391
    -- Check if the supplier exists for the party
    --
    CURSOR check_vendor_exists(cp_party_id IN NUMBER) IS
      SELECT 1 FROM ap_suppliers WHERE party_id = cp_party_id;

    l_vendor_exists NUMBER := 0;
  BEGIN
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    DELETE ap_supplier_int_rejections
    WHERE  parent_table = 'AP_SUPPLIERS_INT';

    OPEN party_int_cur;

    LOOP
      FETCH party_int_cur
        INTO party_int_rec;

      EXIT WHEN party_int_cur%NOTFOUND;

      vendor_rec.vendor_name        := party_int_rec.organization_name;
      vendor_rec.vendor_name_alt    := party_int_rec.organization_name_phonetic;
      vendor_rec.attribute_category := party_int_rec.attribute_category;
      vendor_rec.attribute1         := party_int_rec.attribute1;
      vendor_rec.attribute2         := party_int_rec.attribute2;
      vendor_rec.attribute3         := party_int_rec.attribute3;
      vendor_rec.attribute4         := party_int_rec.attribute4;
      vendor_rec.attribute5         := party_int_rec.attribute5;
      vendor_rec.attribute6         := party_int_rec.attribute6;
      vendor_rec.attribute7         := party_int_rec.attribute7;
      vendor_rec.attribute8         := party_int_rec.attribute8;
      vendor_rec.attribute9         := party_int_rec.attribute9;
      vendor_rec.attribute10        := party_int_rec.attribute10;
      vendor_rec.attribute11        := party_int_rec.attribute11;
      vendor_rec.attribute12        := party_int_rec.attribute12;
      vendor_rec.attribute13        := party_int_rec.attribute13;
      vendor_rec.attribute14        := party_int_rec.attribute14;
      vendor_rec.attribute15        := party_int_rec.attribute15;

      /*vendor_rec.ext_payee_rec.payment_function := 'PAYABLES_DISB';
      vendor_rec.ext_payee_rec.payer_org_type   := 'OPERATING_UNIT';*/

      /* Get the party id for orig system and orig system reference combination */

      vendor_rec.party_id := get_party_id(party_int_rec.party_orig_system,
                                          party_int_rec.party_orig_system_reference);

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE enable_party_as_supplier' ||
                        ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                        ' Party id : ' || vendor_rec.party_id ||
                        ' from get_party_id');

      -- Check if the Vendor number is AutoNumbered.
      -- If the method is set to Manual then the vendor
      -- number would be mapped to the Orig System reference.
      --
      l_vendor_num_code := chk_vendor_num_nmbering_method();

      IF (l_vendor_num_code = 'MANUAL') THEN
        vendor_rec.segment1 := party_int_rec.party_orig_system_reference;
      END IF;

      -- Setting the vendor source as IMPORT so that the
      -- errors are logged in the rejections table
      --
      ap_vendor_pub_pkg.g_source := 'IMPORT';

      -- bug 9049391
      -- If the record is being updated in that case the AP suppliers data
      -- has to be synchronized with the TCA repository. This is done by making
      -- a call to the TCA Sync API
      --
      /*IF (nvl(party_int_rec.insert_update_flag, 'I') = 'U') THEN*/
      IF party_int_rec.insert_update_flag IS NULL THEN
        -- Check if the vendor already exists
        OPEN check_vendor_exists(vendor_rec.party_id);
        FETCH check_vendor_exists
          INTO l_vendor_exists;
        CLOSE check_vendor_exists;

        -- If the vendor exists then Sync it with the party information
        IF l_vendor_exists <> 0 THEN
          l_vendor_exists := 0;
          ap_tca_supplier_sync_pkg.sync_supplier(l_sync_return_status,
                                                 l_sync_msg_count,
                                                 l_sync_msg_data,
                                                 vendor_rec.party_id);
          IF l_sync_return_status = fnd_api.g_ret_sts_success THEN
            ap_vendor_pub_pkg.raise_supplier_event(i_vendor_id => l_vendor_id);
            x_return_status := fnd_api.g_ret_sts_success;
          ELSE
            x_return_status := l_sync_return_status;
            x_msg_count     := l_sync_msg_count;
            x_msg_data      := l_sync_msg_data;
          END IF;
        ELSE
          /* Call create vendor API to create a supplier */
          ap_vendor_pub_pkg.create_vendor(p_api_version      => 1.0,
                                          p_init_msg_list    => fnd_api.g_true,
                                          p_commit           => fnd_api.g_false,
                                          p_validation_level => fnd_api.g_valid_level_full,
                                          x_return_status    => l_return_status,
                                          x_msg_count        => l_msg_count,
                                          x_msg_data         => l_msg_data,
                                          p_vendor_rec       => vendor_rec,
                                          x_vendor_id        => l_vendor_id,
                                          x_party_id         => l_party_id);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            INSERT INTO pos_supplier_int_rejections
              (batch_id,
               import_request_id,
               parent_table,
               parent_id,
               reject_lookup_code,
               last_updated_by,
               last_update_date,
               last_update_login,
               created_by,
               creation_date)
              SELECT p_batch_id,
                     l_request_id,
                     parent_table,
                     parent_id,
                     reject_lookup_code,
                     last_updated_by,
                     last_update_date,
                     last_update_login,
                     created_by,
                     creation_date
              FROM   ap_supplier_int_rejections
              WHERE  parent_table = 'AP_SUPPLIERS_INT';

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             ' No. of Messages from Create_Vendor API: ' ||
                             l_msg_count ||
                             ', Message From Create_Vendor API: ' ||
                             l_msg_data);
            END IF;

            fnd_file.put_line(fnd_file.log, 'Failed in validating vendor.');

            fnd_file.put_line(fnd_file.log,
                              'Error Message Count: ' || x_msg_count ||
                              ' Error Message Data: ' || x_msg_data ||
                              ' From ap_vendor_pub_pkg.create_vendor API for party id: ' ||
                              vendor_rec.party_id);

            x_return_status := l_return_status;
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;
          END IF;

        END IF;
      ELSIF party_int_rec.insert_update_flag = 'I' THEN
        /* Call create vendor API to create a supplier */
        ap_vendor_pub_pkg.create_vendor(p_api_version      => 1.0,
                                        p_init_msg_list    => fnd_api.g_true,
                                        p_commit           => fnd_api.g_false,
                                        p_validation_level => fnd_api.g_valid_level_full,
                                        x_return_status    => l_return_status,
                                        x_msg_count        => l_msg_count,
                                        x_msg_data         => l_msg_data,
                                        p_vendor_rec       => vendor_rec,
                                        x_vendor_id        => l_vendor_id,
                                        x_party_id         => l_party_id);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          INSERT INTO pos_supplier_int_rejections
            (batch_id,
             import_request_id,
             parent_table,
             parent_id,
             reject_lookup_code,
             last_updated_by,
             last_update_date,
             last_update_login,
             created_by,
             creation_date)
            SELECT p_batch_id,
                   l_request_id,
                   parent_table,
                   parent_id,
                   reject_lookup_code,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   created_by,
                   creation_date
            FROM   ap_supplier_int_rejections
            WHERE  parent_table = 'AP_SUPPLIERS_INT';

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           ' No. of Messages from Create_Vendor API: ' ||
                           l_msg_count ||
                           ', Message From Create_Vendor API: ' ||
                           l_msg_data);
          END IF;

          fnd_file.put_line(fnd_file.log,
                            'Error Message Count: ' || x_msg_count ||
                            ' Error Message Data: ' || x_msg_data ||
                            ' From ap_vendor_pub_pkg.create_vendor API for party id: ' ||
                            vendor_rec.party_id);
          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
        END IF;
      ELSIF party_int_rec.insert_update_flag = 'U' THEN
        ap_tca_supplier_sync_pkg.sync_supplier(l_sync_return_status,
                                               l_sync_msg_count,
                                               l_sync_msg_data,
                                               vendor_rec.party_id);
        IF l_sync_return_status = fnd_api.g_ret_sts_success THEN
          ap_vendor_pub_pkg.raise_supplier_event(i_vendor_id => l_vendor_id);
          x_return_status := fnd_api.g_ret_sts_success;
        ELSE
          x_return_status := l_sync_return_status;
          x_msg_count     := l_sync_msg_count;
          x_msg_data      := l_sync_msg_data;
        END IF;
      END IF;
    END LOOP;

    CLOSE party_int_cur;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('SQLAP', 'AP_INVALID_PARTY');
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      fnd_file.put_line(fnd_file.log,
                        ' Inside enable_party_as_supplier EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END enable_party_as_supplier;

  -- This procedure would enable the successfully imported
  -- Party contacts in an import batch as supplier contacts
  --
  PROCEDURE enable_partycont_as_suppcont
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS

    l_return_status VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_party_id      NUMBER;

    CURSOR contact_int_cur IS
      SELECT contact_orig_system,
             contact_orig_system_reference
      FROM   hz_imp_contacts_int hz
      WHERE  batch_id = p_batch_id
            /* Status for the data should not be E or C
            i.e. Errored out or Completed */
      AND    interface_status IS NULL
      AND    relationship_type = 'CONTACT'
      AND    relationship_code = 'CONTACT_OF';

    contact_int_rec contact_int_cur%ROWTYPE;

    l_party_usg_rec              hz_party_usg_assignment_pvt.party_usg_assignment_rec_type;
    l_party_usg_validation_level NUMBER;
  BEGIN

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN contact_int_cur;

    LOOP
      FETCH contact_int_cur
        INTO contact_int_rec;

      EXIT WHEN contact_int_cur%NOTFOUND;

      /* Get the party id for orig system and
      orig system reference combination */
      l_party_id := get_party_id(contact_int_rec.contact_orig_system,
                                 contact_int_rec.contact_orig_system_reference);

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE enable_partycont_as_suppcont' ||
                        ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                        ' Party id : ' || l_party_id ||
                        ' from get_party_id');

      l_party_usg_validation_level      := hz_party_usg_assignment_pvt.g_valid_level_none;
      l_party_usg_rec.party_id          := l_party_id;
      l_party_usg_rec.party_usage_code  := 'SUPPLIER_CONTACT';
      l_party_usg_rec.created_by_module := 'AP_SUPPLIERS_API';

      /* Enable party contact as supplier contact by
      setting usage code as SUPPLIER_CONTACT */
      hz_party_usg_assignment_pvt.assign_party_usage(p_validation_level         => l_party_usg_validation_level,
                                                     p_party_usg_assignment_rec => l_party_usg_rec,
                                                     x_return_status            => l_return_status,
                                                     x_msg_count                => l_msg_count,
                                                     x_msg_data                 => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        error_handler.get_message_list(l_error_msg_tbl);
        IF l_error_msg_tbl.first IS NOT NULL THEN
          l_msg_count := l_error_msg_tbl.first;
          WHILE l_msg_count IS NOT NULL LOOP
            fnd_file.put_line(fnd_file.log,
                              'Error Message: ' || l_error_msg_tbl(l_msg_count)
                              .message_text ||
                               ' From hz_party_usg_assignment_pvt.assign_party_usage API for party id ' ||
                               l_party_id);
            l_msg_count := l_error_msg_tbl.next(l_msg_count);
          END LOOP;
        END IF;
        fnd_file.put_line(fnd_file.log,
                          'Error in hz_party_usg_assignment_pvt.assign_party_usage API for party id ' ||
                          l_party_id);
        x_return_status := l_return_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
      END IF;

    END LOOP;

    CLOSE contact_int_cur;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('SQLAP', 'AP_INVALID_PARTY_CONTACT');
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      fnd_file.put_line(fnd_file.log,
                        ' Inside enable_partycont_as_suppcont EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END enable_partycont_as_suppcont;

  PROCEDURE create_vendor
  (
    p_batch_id      IN NUMBER,
    p_vendor_rec    IN ap_vendor_pub_pkg.r_vendor_rec_type,
    ext_payee_rec   IN OUT NOCOPY iby_disbursement_setup_pub.external_payee_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'CREATE_VENDOR';
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_return_status VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_vendor_id     NUMBER;
    l_party_id      NUMBER;

    CURSOR iby_ext_accts_cur(p_unique_ref IN NUMBER) IS
      SELECT temp_ext_bank_acct_id
      FROM   iby_temp_ext_bank_accts
      WHERE  calling_app_unique_ref1 = p_unique_ref
      AND    status <> 'PROCESSED';

    ext_payee_tab        iby_disbursement_setup_pub.external_payee_tab_type;
    ext_payee_id_tab     iby_disbursement_setup_pub.ext_payee_id_tab_type;
    ext_payee_create_tab iby_disbursement_setup_pub.ext_payee_create_tab_type;

    l_temp_ext_acct_id NUMBER;
    ext_response_rec   iby_fndcpt_common_pub.result_rec_type;

    l_ext_payee_id NUMBER;
    l_bank_acct_id NUMBER;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE CREATE_VENDOR' ||
                      ' Parameters  party_id: ' || p_vendor_rec.party_id ||
                      ' vendor_id: ' || p_vendor_rec.vendor_id ||
                      ' vendor_interface_id: ' ||
                      p_vendor_rec.vendor_interface_id);

    ap_vendor_pub_pkg.create_vendor(p_api_version      => 1.0,
                                    p_init_msg_list    => fnd_api.g_true,
                                    p_commit           => fnd_api.g_false,
                                    p_validation_level => fnd_api.g_valid_level_full,
                                    x_return_status    => l_return_status,
                                    x_msg_count        => l_msg_count,
                                    x_msg_data         => l_msg_data,
                                    p_vendor_rec       => p_vendor_rec,
                                    x_vendor_id        => l_vendor_id,
                                    x_party_id         => l_party_id);

    IF l_return_status = fnd_api.g_ret_sts_success THEN

      UPDATE ap_suppliers_int
      SET    status = 'PROCESSED'
      WHERE  vendor_interface_id = p_vendor_rec.vendor_interface_id
      AND    sdh_batch_id = p_batch_id;

      UPDATE pos_imp_batch_summary
      SET    total_records_imported = total_records_imported + 1,
             total_inserts          = total_inserts + 1,
             suppliers_inserted     = suppliers_inserted + 1,
             suppliers_imported     = suppliers_imported + 1
      WHERE  batch_id = p_batch_id;

      UPDATE ap_supplier_sites_int
      SET    vendor_id = l_vendor_id
      WHERE  vendor_interface_id = p_vendor_rec.vendor_interface_id
      AND    sdh_batch_id = p_batch_id;

      UPDATE ap_sup_site_contact_int
      SET    vendor_id = l_vendor_id
      WHERE  vendor_interface_id = p_vendor_rec.vendor_interface_id
      AND    sdh_batch_id = p_batch_id;

      UPDATE pos_business_class_int
      SET    vendor_id = l_vendor_id
      WHERE  vendor_interface_id = p_vendor_rec.vendor_interface_id
      AND    sdh_batch_id = p_batch_id;

      UPDATE pos_product_service_int
      SET    vendor_id = l_vendor_id
      WHERE  vendor_interface_id = p_vendor_rec.vendor_interface_id
      AND    sdh_batch_id = p_batch_id;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE CREATE_VENDOR' ||
                        ' party_id: ' || p_vendor_rec.party_id ||
                        ' l_party_id: ' || l_party_id);

      ext_payee_rec.payee_party_id := nvl(l_party_id, p_vendor_rec.party_id);

      /* Calling IBY Payee Validation API */
      iby_disbursement_setup_pub.validate_external_payee(p_api_version   => 1.0,
                                                         p_init_msg_list => fnd_api.g_true,
                                                         p_ext_payee_rec => ext_payee_rec,
                                                         x_return_status => l_return_status,
                                                         x_msg_count     => l_msg_count,
                                                         x_msg_data      => l_msg_data);

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE CREATE_VENDOR' ||
                        ' from iby_disbursement_setup_pub.validate_external_payee' ||
                        ' l_return_status: ' || l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_success THEN

        ext_payee_tab(1) := ext_payee_rec;

        /*Calling IBY Payee Creation API */
        iby_disbursement_setup_pub.create_external_payee(p_api_version          => 1.0,
                                                         p_init_msg_list        => fnd_api.g_true,
                                                         p_ext_payee_tab        => ext_payee_tab,
                                                         x_return_status        => l_return_status,
                                                         x_msg_count            => l_msg_count,
                                                         x_msg_data             => l_msg_data,
                                                         x_ext_payee_id_tab     => ext_payee_id_tab,
                                                         x_ext_payee_status_tab => ext_payee_create_tab);

        fnd_file.put_line(fnd_file.log,
                          'Payee_Creation_Msg: ' || ext_payee_create_tab(1)
                          .payee_creation_msg);

        IF l_return_status = fnd_api.g_ret_sts_success THEN
          l_ext_payee_id := ext_payee_id_tab(1).ext_payee_id;

          UPDATE iby_temp_ext_bank_accts
          SET    ext_payee_id           = l_ext_payee_id,
                 account_owner_party_id = l_party_id
          WHERE  calling_app_unique_ref1 = p_vendor_rec.vendor_interface_id;

          -- Cursor processing for iby temp bank account record
          OPEN iby_ext_accts_cur(p_vendor_rec.vendor_interface_id);
          LOOP

            FETCH iby_ext_accts_cur
              INTO l_temp_ext_acct_id;
            EXIT WHEN iby_ext_accts_cur%NOTFOUND;

            /* Calling IBY Bank Account Validation API */
            iby_disbursement_setup_pub.validate_temp_ext_bank_acct(p_api_version      => 1.0,
                                                                   p_init_msg_list    => fnd_api.g_true,
                                                                   x_return_status    => l_return_status,
                                                                   x_msg_count        => l_msg_count,
                                                                   x_msg_data         => l_msg_data,
                                                                   p_temp_ext_acct_id => l_temp_ext_acct_id);

            IF l_return_status = fnd_api.g_ret_sts_success THEN
              /* Calling IBY Bank Account Creation API */
              iby_disbursement_setup_pub.create_temp_ext_bank_acct(p_api_version       => 1.0,
                                                                   p_init_msg_list     => fnd_api.g_true,
                                                                   x_return_status     => l_return_status,
                                                                   x_msg_count         => l_msg_count,
                                                                   x_msg_data          => l_msg_data,
                                                                   p_temp_ext_acct_id  => l_temp_ext_acct_id,
                                                                   p_association_level => 'S',
                                                                   p_supplier_site_id  => NULL,
                                                                   p_party_site_id     => NULL,
                                                                   p_org_id            => NULL,
                                                                   p_org_type          => NULL,
                                                                   x_bank_acc_id       => l_bank_acct_id,
                                                                   x_response          => ext_response_rec);

              IF l_return_status = fnd_api.g_ret_sts_success THEN
                UPDATE iby_temp_ext_bank_accts
                SET    status = 'PROCESSED'
                WHERE  temp_ext_bank_acct_id = l_temp_ext_acct_id;

              ELSE
                UPDATE iby_temp_ext_bank_accts
                SET    status = 'REJECTED'
                WHERE  temp_ext_bank_acct_id = l_temp_ext_acct_id;

                IF (insert_rejections(p_batch_id,
                                      l_request_id,
                                      'IBY_TEMP_EXT_BANK_ACCTS',
                                      p_vendor_rec.vendor_interface_id,
                                      'AP_BANK_ACCT_CREATION',
                                      g_user_id,
                                      g_login_id,
                                      'Import_Vendor') <> TRUE) THEN

                  IF (g_level_procedure >= g_current_runtime_level) THEN
                    fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                              p_data  => l_msg_data);
                    fnd_log.string(g_level_procedure,
                                   g_module_name || l_api_name,
                                   'Parameters: ' ||
                                   ' Vendor_Interface_Id: ' ||
                                   p_vendor_rec.vendor_interface_id ||
                                   ' Acct Validation Msg: ' || l_msg_data);
                  END IF;
                END IF;

                fnd_message.set_name('SQLAP', 'AP_BANK_ACCT_CREATION');
                fnd_msg_pub.add;

                fnd_file.put_line(fnd_file.log,
                                  ' Message: Inside PROCEDURE CREATE_VENDOR' ||
                                  ' failed in iby_disbursement_setup_pub.create_temp_ext_bank_acct ' ||
                                  ' vendor_interface_id: ' ||
                                  p_vendor_rec.vendor_interface_id ||
                                  ' temp_ext_bank_acct_id: ' ||
                                  l_temp_ext_acct_id);

              END IF; -- Bank Account Creation API

            ELSE
              UPDATE iby_temp_ext_bank_accts
              SET    status = 'REJECTED'
              WHERE  temp_ext_bank_acct_id = l_temp_ext_acct_id;

              IF (insert_rejections(p_batch_id,
                                    l_request_id,
                                    'IBY_TEMP_EXT_BANK_ACCTS',
                                    p_vendor_rec.vendor_interface_id,
                                    'AP_INVALID_BANK_ACCT_INFO',
                                    g_user_id,
                                    g_login_id,
                                    'Import_Vendor') <> TRUE) THEN

                IF (g_level_procedure >= g_current_runtime_level) THEN
                  fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                            p_data  => l_msg_data);
                  fnd_log.string(g_level_procedure,
                                 g_module_name || l_api_name,
                                 'Parameters: ' || ' Vendor_Interface_Id: ' ||
                                 p_vendor_rec.vendor_interface_id ||
                                 ' Acct Validation Msg: ' || l_msg_data);
                END IF;
              END IF;

              fnd_message.set_name('SQLAP', 'AP_INVALID_BANK_ACCT_INFO');
              fnd_msg_pub.add;

              fnd_file.put_line(fnd_file.log,
                                ' Message: Inside PROCEDURE CREATE_VENDOR' ||
                                ' failed in iby_disbursement_setup_pub.validate_temp_ext_bank_acct ' ||
                                ' vendor_interface_id: ' ||
                                p_vendor_rec.vendor_interface_id ||
                                ' temp_ext_bank_acct_id: ' ||
                                l_temp_ext_acct_id);

            END IF; -- Bank Account Validation API

          END LOOP;
          CLOSE iby_ext_accts_cur;

        ELSE
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'AP_SUPPLIERS_INT',
                                p_vendor_rec.vendor_interface_id,
                                'AP_PAYEE_CREATION',
                                g_user_id,
                                g_login_id,
                                'Import_Vendor') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Parameters: ' || ' Vendor_Interface_Id: ' ||
                             p_vendor_rec.vendor_interface_id ||
                             ' Payee Validation Msg: ' || l_msg_data);
            END IF;
          END IF;

          fnd_message.set_name('SQLAP', 'AP_PAYEE_CREATION');
          fnd_msg_pub.add;

          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE CREATE_VENDOR' ||
                            ' failed in iby_disbursement_setup_pub.create_external_payee ' ||
                            ' vendor_interface_id: ' ||
                            p_vendor_rec.vendor_interface_id ||
                            ' temp_ext_bank_acct_id: ' ||
                            l_temp_ext_acct_id);

        END IF; -- Payee Creation API

      ELSE
        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'AP_SUPPLIERS_INT',
                              p_vendor_rec.vendor_interface_id,
                              'AP_INVALID_PAYEE',
                              g_user_id,
                              g_login_id,
                              'Import_Vendor') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Vendor_Interface_Id: ' ||
                           p_vendor_rec.vendor_interface_id ||
                           ' Payee Validation Msg: ' || l_msg_data);
          END IF;
        END IF;

        fnd_message.set_name('SQLAP', 'AP_INVALID_PAYEE');
        fnd_msg_pub.add;

        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE CREATE_VENDOR' ||
                          ' failed in iby_disbursement_setup_pub.validate_external_payee ' ||
                          ' vendor_interface_id: ' ||
                          p_vendor_rec.vendor_interface_id ||
                          ' temp_ext_bank_acct_id: ' || l_temp_ext_acct_id);

      END IF; -- Payee Validation API

    ELSE

      UPDATE ap_suppliers_int
      SET    status = 'REJECTED'
      WHERE  vendor_interface_id = p_vendor_rec.vendor_interface_id
      AND    sdh_batch_id = p_batch_id;

      INSERT INTO pos_supplier_int_rejections
        (batch_id,
         import_request_id,
         parent_table,
         parent_id,
         reject_lookup_code,
         last_updated_by,
         last_update_date,
         last_update_login,
         created_by,
         creation_date)
        SELECT p_batch_id,
               l_request_id,
               parent_table,
               parent_id,
               reject_lookup_code,
               last_updated_by,
               last_update_date,
               last_update_login,
               created_by,
               creation_date
        FROM   ap_supplier_int_rejections
        WHERE  parent_table = 'AP_SUPPLIERS_INT'
        AND    parent_id = p_vendor_rec.vendor_interface_id;

      IF (g_level_procedure >= g_current_runtime_level) THEN
        fnd_log.string(g_level_procedure,
                       g_module_name || l_api_name,
                       ' Rejected Vendor_Interface_Id: ' ||
                       p_vendor_rec.vendor_interface_id ||
                       ', No. of Messages from Create_Vendor API: ' ||
                       l_msg_count || ', Message From Create_Vendor API: ' ||
                       l_msg_data);
      END IF;

      error_handler.get_message_list(l_error_msg_tbl);
      IF l_error_msg_tbl.first IS NOT NULL THEN
        l_msg_count := l_error_msg_tbl.first;
        WHILE l_msg_count IS NOT NULL LOOP
          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE CREATE_VENDOR' ||
                             ' failed in ap_vendor_pub_pkg.create_vendor ' ||
                             ' vendor_interface_id: ' ||
                             p_vendor_rec.vendor_interface_id ||
                             ', No. of Messages: ' || l_msg_count ||
                             ', Message: ' || l_error_msg_tbl(l_msg_count)
                            .message_text);
          l_msg_count := l_error_msg_tbl.next(l_msg_count);
        END LOOP;
      ELSE
        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE CREATE_VENDOR' ||
                          ' failed in ap_vendor_pub_pkg.create_vendor ' ||
                          ' vendor_interface_id: ' ||
                          p_vendor_rec.vendor_interface_id);
      END IF;
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;

    END IF; -- Supplier Creation API
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      fnd_file.put_line(fnd_file.log,
                        ' Inside create_vendor EXCEPTION ' || ' Message: ' ||
                        SQLCODE || ' ' || SQLERRM);
  END create_vendor;

    --bug 16210521 write a separate procedure to process vendor update
  PROCEDURE update_vendor
  (
    p_batch_id      IN NUMBER,
    p_vendor_rec      IN ap_vendor_pub_pkg.r_vendor_rec_type,
    ext_payee_rec   IN OUT NOCOPY iby_disbursement_setup_pub.external_payee_rec_type,
    p_vendor_id IN NUMBER,
    p_party_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_VENDOR_SITE';
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_return_status  VARCHAR2(2000);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_location_id    NUMBER;

    /* Variable Declaration for IBY */

    ext_payee_tab iby_disbursement_setup_pub.external_payee_tab_type;

    ext_payee_id_tab iby_disbursement_setup_pub.ext_payee_id_tab_type;

    ext_payee_update_tab iby_disbursement_setup_pub.ext_payee_update_tab_type;

    l_temp_ext_acct_id   NUMBER;
    ext_response_rec     iby_fndcpt_common_pub.result_rec_type;

    l_ext_payee_id NUMBER;
    l_ext_payee_cnt NUMBER;
    l_bank_acct_id NUMBER;

    l_ext_payee_id_rec iby_disbursement_setup_pub.Ext_Payee_ID_Rec_Type;

    CURSOR iby_ext_accts_cur(p_unique_ref IN NUMBER) IS
    SELECT temp_ext_bank_acct_id
    FROM   iby_temp_ext_bank_accts
    WHERE  calling_app_unique_ref2 = p_unique_ref
    AND    nvl(status, 'NEW') <> 'PROCESSED';

    CURSOR iby_ext_payee_cur(p_payee_party_id NUMBER,
                              p_party_site_id  NUMBER,
                              p_supplier_site_id NUMBER,
                              p_payer_org_id NUMBER,
                              p_payer_org_type VARCHAR2,
                              p_payment_function VARCHAR2) IS
    SELECT count(payee.EXT_PAYEE_ID), max(payee.EXT_PAYEE_ID)s
      FROM iby_external_payees_all payee
      WHERE payee.PAYEE_PARTY_ID = p_payee_party_id
    AND payee.PAYMENT_FUNCTION = p_payment_function
    AND ((p_party_site_id is NULL and payee.PARTY_SITE_ID is NULL) OR
        (payee.PARTY_SITE_ID = p_party_site_id))
    AND ((p_supplier_site_id is NULL and payee.SUPPLIER_SITE_ID is NULL) OR
        (payee.SUPPLIER_SITE_ID = p_supplier_site_id))
    AND ((p_payer_org_id is NULL and payee.ORG_ID is NULL) OR
                (payee.ORG_ID = p_payer_org_id AND payee.ORG_TYPE = p_payer_org_type));

    l_debug_info           VARCHAR2(500);
    l_rollback_vendor_site VARCHAR2(1) := 'N';
    l_payee_msg_count      NUMBER;
    l_payee_msg_data       VARCHAR2(4000);
    l_error_code           VARCHAR2(4000);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE UPDATE_VENDOR' ||
                      ' Parameters  party_id: ' || p_vendor_rec.party_id ||
                      ' vendor_id: ' || p_vendor_rec.vendor_id ||
                      ' vendor_interface_id: ' ||
                      p_vendor_rec.vendor_interface_id);


    ap_vendor_pub_pkg.update_vendor(1.0,
                                    fnd_api.g_false,
                                    fnd_api.g_false,
                                    fnd_api.g_valid_level_full,
                                    l_return_status,
                                    l_msg_count,
                                    l_msg_data,
                                    p_vendor_rec,
                                    p_vendor_id);

    IF l_return_status = fnd_api.g_ret_sts_success THEN

      UPDATE ap_suppliers_int
      SET    status = 'PROCESSED'
      WHERE  vendor_interface_id = p_vendor_rec.vendor_interface_id
      AND    sdh_batch_id = p_batch_id;

      UPDATE pos_imp_batch_summary
      SET    total_records_imported = total_records_imported + 1,
             total_updates          = total_updates + 1,
             suppliers_updated      = suppliers_updated + 1,
             suppliers_imported     = suppliers_imported + 1
      WHERE  batch_id = p_batch_id;

      ext_payee_rec.payee_party_id := p_party_id;

      iby_disbursement_setup_pub.validate_external_payee(p_api_version   => 1.0,
                                                         p_init_msg_list => fnd_api.g_true,
                                                         p_ext_payee_rec => ext_payee_rec,
                                                         x_return_status => l_return_status,
                                                         x_msg_count     => l_msg_count,
                                                         x_msg_data      => l_msg_data);

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE UPDATE_VENDOR' ||
                        ' from iby_disbursement_setup_pub.validate_external_payee' ||
                        ' l_return_status: ' || l_return_status);

      IF l_return_status = fnd_api.g_ret_sts_success THEN
      	OPEN iby_ext_payee_cur(ext_payee_rec.Payee_Party_Id,
                                ext_payee_rec.Payee_Party_Site_Id,
                                ext_payee_rec.Supplier_Site_Id,
                                ext_payee_rec.Payer_Org_Id,
                                ext_payee_rec.Payer_Org_Type,
                                ext_payee_rec.Payment_Function);
        FETCH iby_ext_payee_cur INTO l_ext_payee_cnt, l_ext_payee_id;
        CLOSE iby_ext_payee_cur;

        ext_payee_tab(1) := ext_payee_rec;
        l_ext_payee_id_rec.ext_payee_id := l_ext_payee_id;
        ext_payee_id_tab(1) := l_ext_payee_id_rec;

        iby_disbursement_setup_pub.update_external_payee(p_api_version          => 1.0,
                                                         p_init_msg_list        => fnd_api.g_true,
                                                         p_ext_payee_tab        => ext_payee_tab,
                                                         p_ext_payee_id_tab		=> ext_payee_id_tab,
                                                         x_return_status        => l_return_status,
                                                         x_msg_count            => l_msg_count,
                                                         x_msg_data             => l_msg_data,
                                                         x_ext_payee_status_tab => ext_payee_update_tab);

        IF l_return_status = fnd_api.g_ret_sts_success THEN
          ext_payee_tab(1) := ext_payee_rec;
        ELSE
          -- Payee Update API
          IF (insert_rejections(p_batch_id,
                    l_request_id,
                    'AP_SUPPLIERS_INT',
                    p_vendor_rec.vendor_interface_id,
                    'AP_PAYEE_CREATION',
                    g_user_id,
                    g_login_id,
                    'Update_Vendor') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                          p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                     g_module_name || l_api_name,
                     'Parameters: ' ||
                     ' Vendor_Interface_Id: ' ||
                     p_vendor_rec.vendor_interface_id ||
                     ' Payee Validation Msg: ' || l_msg_data);
            END IF;
          END IF;

          fnd_message.set_name('SQLAP', 'AP_PAYEE_CREATION');
          fnd_msg_pub.add;

				  fnd_file.put_line(fnd_file.log,
									' Message: Inside PROCEDURE UPDATE_VENDOR' ||
									' failed in payee update ' ||
									' vendor_interface_id: ' ||
									p_vendor_rec.vendor_interface_id);

        END IF; -- Payee Update API
      ELSE
        -- Payee Validation API
        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'AP_SUPPLIERS_INT',
                              p_vendor_rec.vendor_interface_id,
                              'AP_INVALID_PAYEE_INFO',
                              g_user_id,
                              g_login_id,
                              'Update_Vendor') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Vendor_Interface_Id: ' ||
                           p_vendor_rec.vendor_interface_id ||
                           ' Payee Validation Msg: ' || l_msg_data);
          END IF;
        END IF;

        l_debug_info := 'Calling IBY Payee Validation API in update vendor';

        IF (l_msg_data IS NOT NULL) THEN
          -- Print the error returned from the IBY service even if the debug
          -- mode is off
          ap_import_utilities_pkg.print('Y',
                                        '4)Error in ' || l_debug_info ||
                                        '---------------------->' ||
                                        l_msg_data);

        ELSE
          -- If the l_msg_data is null then the IBY service returned
          -- more than one error.  The calling module will need to get
          -- them from the message stack
          FOR i IN l_payee_msg_count .. l_msg_count LOOP
            l_error_code := fnd_msg_pub.get(p_msg_index => i,
                                            p_encoded   => 'F');

            IF i = l_payee_msg_count THEN
              l_error_code := '4)Error in ' || l_debug_info ||
                              '---------------------->' || l_error_code;
            END IF;

            ap_import_utilities_pkg.print('Y', l_error_code);

          END LOOP;
        END IF;
      END IF;
    ELSE
      UPDATE ap_suppliers_int
      SET    status = 'REJECTED'
      WHERE  vendor_interface_id = p_vendor_rec.vendor_interface_id
      AND    sdh_batch_id = p_batch_id;

      INSERT INTO pos_supplier_int_rejections
        (batch_id,
         import_request_id,
         parent_table,
         parent_id,
         reject_lookup_code,
         last_updated_by,
         last_update_date,
         last_update_login,
         created_by,
         creation_date)
        SELECT p_batch_id,
               l_request_id,
               parent_table,
               parent_id,
               reject_lookup_code,
               last_updated_by,
               last_update_date,
               last_update_login,
               created_by,
               creation_date
        FROM   ap_supplier_int_rejections
        WHERE  parent_table = 'AP_SUPPLIERS_INT'
        AND    parent_id = p_vendor_rec.vendor_interface_id;

      IF (g_level_procedure >= g_current_runtime_level) THEN
        fnd_log.string(g_level_procedure,
                       g_module_name || l_api_name,
                       ' Rejected Vendor_Interface_Id: ' ||
                       p_vendor_rec.vendor_interface_id ||
                       ', No. of Messages from update_vendor API: ' ||
                       l_msg_count ||
                       ', Message From update_vendor API: ' ||
                       l_msg_data);
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE IMPORT_VENDORS' ||
                        ' failed in ap_vendor_pub_pkg.update_vendor ' ||
                        ' vendor_interface_id: ' ||
                        p_vendor_rec.vendor_interface_id ||
                        ', No. of Messages: ' || l_msg_count ||
                        ', Message: ' || l_msg_data ||
                        ', return status: ' || l_return_status);

      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      fnd_file.put_line(fnd_file.log,
                        ' Inside update_vendor EXCEPTION ' || ' Message: ' ||
                        SQLCODE || ' ' || SQLERRM);
  END update_vendor;

  PROCEDURE import_vendors
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS

    l_api_name CONSTANT VARCHAR2(30) := 'IMPORT_VENDORS';
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_return_status VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_vendor_id     NUMBER;

    CURSOR vendor_int_cur IS
      SELECT *
      FROM   ap_suppliers_int supp
      WHERE  import_request_id = l_request_id
      AND    vendor_interface_id IS NOT NULL
      AND    sdh_batch_id = p_batch_id
      AND    nvl(status, 'ACTIVE') NOT IN ('PROCESSED', 'REMOVED')
      AND    NOT EXISTS
       (SELECT 1
              FROM   hz_imp_parties_int party
              WHERE  batch_id = p_batch_id
              AND    supp.sdh_batch_id = party.batch_id
              AND    supp.party_orig_system = party.party_orig_system
              AND    supp.party_orig_system_reference =
                     party.party_orig_system_reference
              AND    party.interface_status = 'R')
      ORDER  BY segment1;

    vendor_int_rec vendor_int_cur%ROWTYPE;
    vendor_rec     ap_vendor_pub_pkg.r_vendor_rec_type;

    l_vendor_num_code    financials_system_parameters.user_defined_vendor_num_code%TYPE;
    l_insert_update_flag VARCHAR2(1);

    /* Variable Declaration for IBY */
    ext_payee_rec iby_disbursement_setup_pub.external_payee_rec_type;

    CURSOR check_vendor_exists(cp_party_id IN NUMBER) IS
      SELECT 1,
             vendor_id
      FROM   ap_suppliers
      WHERE  party_id = cp_party_id;

    l_vendor_exists NUMBER := 0;

  BEGIN
    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Standard Start of API savepoint
    SAVEPOINT import_vendor_pub;

    DELETE ap_supplier_int_rejections
    WHERE  parent_table = 'AP_SUPPLIERS_INT';

    -- API body

    -- This update statement resets the unprocessed rows so
    -- that they get picked in the current run.
    UPDATE ap_suppliers_int api
    SET    import_request_id = NULL
    WHERE  import_request_id IS NOT NULL
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') IN ('ACTIVE', 'REJECTED')
    AND    EXISTS (SELECT 'Request Completed'
            FROM   fnd_concurrent_requests fcr
            WHERE  fcr.request_id = api.import_request_id
            AND    fcr.phase_code = 'C');

    -- Updating Interface Record with request id
    UPDATE ap_suppliers_int
    SET    import_request_id = l_request_id
    WHERE  import_request_id IS NULL
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') NOT IN ('PROCESSED', 'REMOVED');

    UPDATE ap_suppliers_int supp
    SET    status            = 'REMOVED',
           import_request_id = l_request_id
    WHERE  sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED'
    AND    EXISTS
     (SELECT 1
            FROM   hz_imp_parties_int party
            WHERE  batch_id = p_batch_id
            AND    supp.sdh_batch_id = party.batch_id
            AND    supp.party_orig_system = party.party_orig_system
            AND    supp.party_orig_system_reference =
                   party.party_orig_system_reference
            AND    party.interface_status = 'R');

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDORS' ||
                      ' Not imported(marked REMOVED) : ' || SQL%ROWCOUNT ||
                      ' records. Reason interface_status in hz_imp_parties_int = R');

    INSERT INTO pos_supplier_int_rejections
      (SELECT p_batch_id,
              l_request_id,
              'AP_SUPPLIERS_INT',
              vendor_interface_id,
              'POS_INVALID_PARTY_ORIG_SYSTEM',
              g_user_id,
              SYSDATE,
              g_login_id,
              g_user_id,
              SYSDATE
       FROM   ap_suppliers_int
       WHERE  status = 'REMOVED'
       AND    import_request_id = l_request_id
       AND    sdh_batch_id = p_batch_id);

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDORS' ||
                      ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                      ' request_id: ' || l_request_id);

    COMMIT;

    SAVEPOINT import_vendor_pub;
    ap_vendor_pub_pkg.g_source := 'IMPORT';

    -- Cursor processing for vendor interface record
    OPEN vendor_int_cur;
    LOOP

      FETCH vendor_int_cur
        INTO vendor_int_rec;
      EXIT WHEN vendor_int_cur%NOTFOUND;

      vendor_rec.vendor_interface_id        := vendor_int_rec.vendor_interface_id;
      vendor_rec.vendor_name                := vendor_int_rec.vendor_name;
      vendor_rec.segment1                   := vendor_int_rec.segment1;
      vendor_rec.vendor_name_alt            := vendor_int_rec.vendor_name_alt;
      vendor_rec.summary_flag               := vendor_int_rec.summary_flag;
      vendor_rec.enabled_flag               := vendor_int_rec.enabled_flag;
      vendor_rec.employee_id                := vendor_int_rec.employee_id;
      vendor_rec.vendor_type_lookup_code    := vendor_int_rec.vendor_type_lookup_code;
      vendor_rec.customer_num               := vendor_int_rec.customer_num;
      vendor_rec.one_time_flag              := vendor_int_rec.one_time_flag;
      vendor_rec.min_order_amount           := vendor_int_rec.min_order_amount;
      vendor_rec.terms_id                   := vendor_int_rec.terms_id;
      vendor_rec.terms_name                 := vendor_int_rec.terms_name;
      vendor_rec.set_of_books_id            := vendor_int_rec.set_of_books_id;
      vendor_rec.always_take_disc_flag      := vendor_int_rec.always_take_disc_flag;
      vendor_rec.pay_date_basis_lookup_code := vendor_int_rec.pay_date_basis_lookup_code;
      vendor_rec.pay_group_lookup_code      := vendor_int_rec.pay_group_lookup_code;
      vendor_rec.payment_priority           := vendor_int_rec.payment_priority;
      vendor_rec.invoice_currency_code      := vendor_int_rec.invoice_currency_code;
      vendor_rec.payment_currency_code      := vendor_int_rec.payment_currency_code;
      vendor_rec.invoice_amount_limit       := vendor_int_rec.invoice_amount_limit;
      vendor_rec.hold_all_payments_flag     := vendor_int_rec.hold_all_payments_flag;
      vendor_rec.hold_future_payments_flag  := vendor_int_rec.hold_future_payments_flag;
      vendor_rec.hold_reason                := vendor_int_rec.hold_reason;

      IF length(vendor_int_rec.num_1099) > 20 THEN

        UPDATE ap_suppliers_int
        SET    status = 'REJECTED'
        WHERE  vendor_interface_id = vendor_int_rec.vendor_interface_id
        AND    sdh_batch_id = p_batch_id;

        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'AP_SUPPLIERS_INT',
                              vendor_rec.vendor_interface_id,
                              'AP_INVALID_NUM_1099',
                              g_user_id,
                              g_login_id,
                              'IMPORT_VENDORS') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           ' Rejected Vendor_Interface_Id: ' ||
                           vendor_int_rec.vendor_interface_id ||
                           'as length of num_1099 > 20 ');
          END IF;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE IMPORT_VENDORS' ||
                          ' failed for vendor_interface_id: ' ||
                          vendor_int_rec.vendor_interface_id ||
                          'as length of num_1099 > 20 ');

        GOTO continue_next_record;
      END IF; /* length > 20 check */

      vendor_rec.jgzz_fiscal_code               := vendor_int_rec.num_1099;
      vendor_rec.type_1099                      := vendor_int_rec.type_1099;
      vendor_rec.organization_type_lookup_code  := vendor_int_rec.organization_type_lookup_code;
      vendor_rec.start_date_active              := vendor_int_rec.start_date_active;
      vendor_rec.end_date_active                := vendor_int_rec.end_date_active;
      vendor_rec.minority_group_lookup_code     := vendor_int_rec.minority_group_lookup_code;
      vendor_rec.women_owned_flag               := vendor_int_rec.women_owned_flag;
      vendor_rec.small_business_flag            := vendor_int_rec.small_business_flag;
      vendor_rec.sic_code                       := vendor_int_rec.standard_industry_class;
      vendor_rec.hold_flag                      := vendor_int_rec.hold_flag;
      vendor_rec.purchasing_hold_reason         := vendor_int_rec.purchasing_hold_reason;
      vendor_rec.hold_by                        := vendor_int_rec.hold_by;
      vendor_rec.hold_date                      := vendor_int_rec.hold_date;
      vendor_rec.terms_date_basis               := vendor_int_rec.terms_date_basis;
      vendor_rec.inspection_required_flag       := vendor_int_rec.inspection_required_flag;
      vendor_rec.receipt_required_flag          := vendor_int_rec.receipt_required_flag;
      vendor_rec.qty_rcv_tolerance              := vendor_int_rec.qty_rcv_tolerance;
      vendor_rec.qty_rcv_exception_code         := vendor_int_rec.qty_rcv_exception_code;
      vendor_rec.enforce_ship_to_location_code  := vendor_int_rec.enforce_ship_to_location_code;
      vendor_rec.days_early_receipt_allowed     := vendor_int_rec.days_early_receipt_allowed;
      vendor_rec.days_late_receipt_allowed      := vendor_int_rec.days_late_receipt_allowed;
      vendor_rec.receipt_days_exception_code    := vendor_int_rec.receipt_days_exception_code;
      vendor_rec.receiving_routing_id           := vendor_int_rec.receiving_routing_id;
      vendor_rec.allow_substitute_receipts_flag := vendor_int_rec.allow_substitute_receipts_flag;
      vendor_rec.allow_unordered_receipts_flag  := vendor_int_rec.allow_unordered_receipts_flag;
      vendor_rec.hold_unmatched_invoices_flag   := vendor_int_rec.hold_unmatched_invoices_flag;
      vendor_rec.tax_verification_date          := vendor_int_rec.tax_verification_date;
      vendor_rec.name_control                   := vendor_int_rec.name_control;
      vendor_rec.state_reportable_flag          := vendor_int_rec.state_reportable_flag;
      vendor_rec.federal_reportable_flag        := vendor_int_rec.federal_reportable_flag;
      vendor_rec.attribute_category             := vendor_int_rec.attribute_category;
      vendor_rec.attribute1                     := vendor_int_rec.attribute1;
      vendor_rec.attribute2                     := vendor_int_rec.attribute2;
      vendor_rec.attribute3                     := vendor_int_rec.attribute3;
      vendor_rec.attribute4                     := vendor_int_rec.attribute4;
      vendor_rec.attribute5                     := vendor_int_rec.attribute5;
      vendor_rec.attribute6                     := vendor_int_rec.attribute6;
      vendor_rec.attribute7                     := vendor_int_rec.attribute7;
      vendor_rec.attribute8                     := vendor_int_rec.attribute8;
      vendor_rec.attribute9                     := vendor_int_rec.attribute9;
      vendor_rec.attribute10                    := vendor_int_rec.attribute10;
      vendor_rec.attribute11                    := vendor_int_rec.attribute11;
      vendor_rec.attribute12                    := vendor_int_rec.attribute12;
      vendor_rec.attribute13                    := vendor_int_rec.attribute13;
      vendor_rec.attribute14                    := vendor_int_rec.attribute14;
      vendor_rec.attribute15                    := vendor_int_rec.attribute15;
      vendor_rec.auto_calculate_interest_flag   := vendor_int_rec.auto_calculate_interest_flag;
      vendor_rec.exclude_freight_from_discount  := vendor_int_rec.exclude_freight_from_discount;
      vendor_rec.tax_reporting_name             := vendor_int_rec.tax_reporting_name;
      vendor_rec.allow_awt_flag                 := vendor_int_rec.allow_awt_flag;
      vendor_rec.awt_group_id                   := vendor_int_rec.awt_group_id;
      vendor_rec.awt_group_name                 := vendor_int_rec.awt_group_name;
      vendor_rec.pay_awt_group_id               := vendor_int_rec.pay_awt_group_id;
      vendor_rec.pay_awt_group_name             := vendor_int_rec.pay_awt_group_name;
      vendor_rec.global_attribute1              := vendor_int_rec.global_attribute1;
      vendor_rec.global_attribute2              := vendor_int_rec.global_attribute2;
      vendor_rec.global_attribute3              := vendor_int_rec.global_attribute3;
      vendor_rec.global_attribute4              := vendor_int_rec.global_attribute4;
      vendor_rec.global_attribute5              := vendor_int_rec.global_attribute5;
      vendor_rec.global_attribute6              := vendor_int_rec.global_attribute6;
      vendor_rec.global_attribute7              := vendor_int_rec.global_attribute7;
      vendor_rec.global_attribute8              := vendor_int_rec.global_attribute8;
      vendor_rec.global_attribute9              := vendor_int_rec.global_attribute9;
      vendor_rec.global_attribute10             := vendor_int_rec.global_attribute10;
      vendor_rec.global_attribute11             := vendor_int_rec.global_attribute11;
      vendor_rec.global_attribute12             := vendor_int_rec.global_attribute12;
      vendor_rec.global_attribute13             := vendor_int_rec.global_attribute13;
      vendor_rec.global_attribute14             := vendor_int_rec.global_attribute14;
      vendor_rec.global_attribute15             := vendor_int_rec.global_attribute15;
      vendor_rec.global_attribute16             := vendor_int_rec.global_attribute16;
      vendor_rec.global_attribute17             := vendor_int_rec.global_attribute17;
      vendor_rec.global_attribute18             := vendor_int_rec.global_attribute18;
      vendor_rec.global_attribute19             := vendor_int_rec.global_attribute19;
      vendor_rec.global_attribute20             := vendor_int_rec.global_attribute20;
      vendor_rec.global_attribute_category      := vendor_int_rec.global_attribute_category;
      vendor_rec.bank_charge_bearer             := vendor_int_rec.bank_charge_bearer;
      vendor_rec.match_option                   := vendor_int_rec.match_option;
      vendor_rec.create_debit_memo_flag         := vendor_int_rec.create_debit_memo_flag;
      vendor_rec.tax_reference                  := vendor_int_rec.vat_registration_num;


      /* Populating IBY Records and Table */

      ext_payee_rec.payment_function := 'PAYABLES_DISB';
      /* Commented by Suchita for the bug7583123
      ext_payee_rec.payer_org_type     := 'OPERATING_UNIT'; */
      ext_payee_rec.exclusive_pay_flag := nvl(vendor_int_rec.exclusive_payment_flag,
                                              'N');

      ext_payee_rec.default_pmt_method  := vendor_int_rec.payment_method_lookup_code;
      ext_payee_rec.ece_tp_loc_code     := vendor_int_rec.ece_tp_location_code;
      ext_payee_rec.bank_charge_bearer  := vendor_int_rec.iby_bank_charge_bearer;
      ext_payee_rec.bank_instr1_code    := vendor_int_rec.bank_instruction1_code;
      ext_payee_rec.bank_instr2_code    := vendor_int_rec.bank_instruction2_code;
      ext_payee_rec.bank_instr_detail   := vendor_int_rec.bank_instruction_details;
      ext_payee_rec.pay_reason_code     := vendor_int_rec.payment_reason_code;
      ext_payee_rec.pay_reason_com      := vendor_int_rec.payment_reason_comments;
      ext_payee_rec.pay_message1        := vendor_int_rec.payment_text_message1;
      ext_payee_rec.pay_message2        := vendor_int_rec.payment_text_message2;
      ext_payee_rec.pay_message3        := vendor_int_rec.payment_text_message3;
      ext_payee_rec.delivery_channel    := vendor_int_rec.delivery_channel_code;
      ext_payee_rec.pmt_format          := vendor_int_rec.payment_format_code;
      ext_payee_rec.settlement_priority := vendor_int_rec.settlement_priority;

      -- Populating the ext_payee_rec of Vendor_rec
      ext_payee_rec.edi_payment_format         := vendor_int_rec.edi_payment_format;
      ext_payee_rec.edi_transaction_handling   := vendor_int_rec.edi_transaction_handling;
      ext_payee_rec.edi_payment_method         := vendor_int_rec.edi_payment_method;
      ext_payee_rec.edi_remittance_method      := vendor_int_rec.edi_remittance_method;
      ext_payee_rec.edi_remittance_instruction := vendor_int_rec.edi_remittance_instruction;

	  --bug 16210521 add missing fields
	  ext_payee_rec.remit_advice_email  := vendor_int_rec.remittance_email;

      vendor_rec.ext_payee_rec.default_pmt_method  := vendor_int_rec.payment_method_lookup_code;
      vendor_rec.ext_payee_rec.payment_function    := 'PAYABLES_DISB';
      vendor_rec.ext_payee_rec.payer_org_type      := 'OPERATING_UNIT';
      vendor_rec.ext_payee_rec.exclusive_pay_flag  := nvl(vendor_int_rec.exclusive_payment_flag,
                                                          'N');
      vendor_rec.ext_payee_rec.default_pmt_method  := vendor_int_rec.payment_method_lookup_code;
      vendor_rec.ext_payee_rec.ece_tp_loc_code     := vendor_int_rec.ece_tp_location_code;
      vendor_rec.ext_payee_rec.bank_charge_bearer  := vendor_int_rec.iby_bank_charge_bearer;
      vendor_rec.ext_payee_rec.bank_instr1_code    := vendor_int_rec.bank_instruction1_code;
      vendor_rec.ext_payee_rec.bank_instr2_code    := vendor_int_rec.bank_instruction2_code;
      vendor_rec.ext_payee_rec.bank_instr_detail   := vendor_int_rec.bank_instruction_details;
      vendor_rec.ext_payee_rec.pay_reason_code     := vendor_int_rec.payment_reason_code;
      vendor_rec.ext_payee_rec.pay_reason_com      := vendor_int_rec.payment_reason_comments;
      vendor_rec.ext_payee_rec.pay_message1        := vendor_int_rec.payment_text_message1;
      vendor_rec.ext_payee_rec.pay_message2        := vendor_int_rec.payment_text_message2;
      vendor_rec.ext_payee_rec.pay_message3        := vendor_int_rec.payment_text_message3;
      vendor_rec.ext_payee_rec.delivery_channel    := vendor_int_rec.delivery_channel_code;
      vendor_rec.ext_payee_rec.pmt_format          := vendor_int_rec.payment_format_code;
      vendor_rec.ext_payee_rec.settlement_priority := vendor_int_rec.settlement_priority;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE IMPORT_VENDORS' ||
                        ' vendor_interface_id: ' ||
                        vendor_rec.vendor_interface_id || ' party_id: ' ||
                        vendor_int_rec.party_id);

      IF (vendor_int_rec.party_id IS NULL) THEN
        vendor_rec.party_id := get_party_id(vendor_int_rec.party_orig_system,
                                            vendor_int_rec.party_orig_system_reference);
      ELSE
        vendor_rec.party_id := vendor_int_rec.party_id;
      END IF;

      IF (vendor_rec.party_id IS NULL OR vendor_rec.party_id = 0) THEN
        UPDATE ap_suppliers_int
        SET    status = 'REJECTED'
        WHERE  vendor_interface_id = vendor_rec.vendor_interface_id
        AND    sdh_batch_id = p_batch_id;

        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'AP_SUPPLIERS_INT',
                              vendor_rec.vendor_interface_id,
                              'POS_INVALID_PARTY_ORIG_SYSTEM',
                              g_user_id,
                              g_login_id,
                              'IMPORT_VENDORS') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           ' Rejected vendor_interface_id: ' ||
                           vendor_rec.vendor_interface_id ||
                           ', No. of Messages: ' || l_msg_count ||
                           ', Message: ' || l_msg_data);
          END IF;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_file.put_line(fnd_file.log,
                          ' Invalid Orig System Combination for: ' ||
                          ' vendor_interface_id: ' ||
                          vendor_rec.vendor_interface_id);
        GOTO continue_next_record;
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE IMPORT_VENDORS' ||
                        ' vendor_interface_id: ' ||
                        vendor_rec.vendor_interface_id || ' party_id: ' ||
                        vendor_rec.party_id);

      l_vendor_num_code := chk_vendor_num_nmbering_method();

      IF (l_vendor_num_code = 'MANUAL') THEN
        vendor_rec.segment1 := nvl(vendor_int_rec.segment1,
                                   vendor_int_rec.party_orig_system_reference);
      END IF;

      BEGIN
        SELECT insert_update_flag
        INTO   l_insert_update_flag
        FROM   hz_imp_parties_int
        WHERE  batch_id = p_batch_id
        AND    party_orig_system = vendor_int_rec.party_orig_system
        AND    party_orig_system_reference =
               vendor_int_rec.party_orig_system_reference;

      EXCEPTION
        WHEN OTHERS THEN
          l_insert_update_flag := 'O';
      END;

      IF (l_insert_update_flag = 'I') THEN
        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE IMPORT_VENDORS' ||
                          ' Calling create_vendor insert_update_flag = I');

        create_vendor(p_batch_id      => p_batch_id,
                      p_vendor_rec    => vendor_rec,
                      ext_payee_rec   => ext_payee_rec,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data);

      ELSE
        -- Check if the vendor already exists
        OPEN check_vendor_exists(vendor_rec.party_id);
        FETCH check_vendor_exists
          INTO l_vendor_exists,
               l_vendor_id;
        CLOSE check_vendor_exists;

        -- If the vendor exists then upodate it
        IF l_vendor_exists <> 0 THEN
          l_vendor_exists := 0;

          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE IMPORT_VENDORS' ||
                            ' As vendor exists calling ap_vendor_pub_pkg.update_vendor for vendor id : ' ||
                            l_vendor_id);

          -- Bug 19182150: Move the following fix here as it only applies to update case
          -- bug 16667819: set type_1099 to null if federal_reportable_flag = 'N'
          IF vendor_int_rec.federal_reportable_flag = 'N' THEN
            vendor_rec.type_1099 := FND_API.G_NULL_CHAR;
          END IF;

          -- bug 16210521 call a separate procedure to update vendor
          update_vendor(p_batch_id      => p_batch_id,
                        p_vendor_rec    => vendor_rec,
                        ext_payee_rec   => ext_payee_rec,
                        p_vendor_id     => l_vendor_id,
                        p_party_id      => vendor_rec.party_id,
                        x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
        /* bug 16210521
          ap_vendor_pub_pkg.update_vendor(1.0,
                                          fnd_api.g_false,
                                          fnd_api.g_false,
                                          fnd_api.g_valid_level_full,
                                          l_return_status,
                                          l_msg_count,
                                          l_msg_data,
                                          vendor_rec,
                                          l_vendor_id);

          IF l_return_status = fnd_api.g_ret_sts_success THEN

            UPDATE ap_suppliers_int
            SET    status = 'PROCESSED'
            WHERE  vendor_interface_id = vendor_rec.vendor_interface_id
            AND    sdh_batch_id = p_batch_id;

            UPDATE pos_imp_batch_summary
            SET    total_records_imported = total_records_imported + 1,
                   total_updates          = total_updates + 1,
                   suppliers_updated      = suppliers_updated + 1,
                   suppliers_imported     = suppliers_imported + 1
            WHERE  batch_id = p_batch_id;
          ELSE
            UPDATE ap_suppliers_int
            SET    status = 'REJECTED'
            WHERE  vendor_interface_id = vendor_rec.vendor_interface_id
            AND    sdh_batch_id = p_batch_id;

            INSERT INTO pos_supplier_int_rejections
              (batch_id,
               import_request_id,
               parent_table,
               parent_id,
               reject_lookup_code,
               last_updated_by,
               last_update_date,
               last_update_login,
               created_by,
               creation_date)
              SELECT p_batch_id,
                     l_request_id,
                     parent_table,
                     parent_id,
                     reject_lookup_code,
                     last_updated_by,
                     last_update_date,
                     last_update_login,
                     created_by,
                     creation_date
              FROM   ap_supplier_int_rejections
              WHERE  parent_table = 'AP_SUPPLIERS_INT'
              AND    parent_id = vendor_rec.vendor_interface_id;

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             ' Rejected Vendor_Interface_Id: ' ||
                             vendor_rec.vendor_interface_id ||
                             ', No. of Messages from update_vendor API: ' ||
                             l_msg_count ||
                             ', Message From update_vendor API: ' ||
                             l_msg_data);
            END IF;

            fnd_file.put_line(fnd_file.log,
                              ' Message: Inside PROCEDURE IMPORT_VENDORS' ||
                              ' failed in ap_vendor_pub_pkg.update_vendor ' ||
                              ' vendor_interface_id: ' ||
                              vendor_rec.vendor_interface_id ||
                              ', No. of Messages: ' || l_msg_count ||
                              ', Message: ' || l_msg_data ||
                              ', return status: ' || l_return_status);

            x_return_status := l_return_status;
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;
          END IF;*/
        ELSE
          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE IMPORT_VENDORS' ||
                            ' Calling create_vendor insert_update_flag = U');

          create_vendor(p_batch_id      => p_batch_id,
                        p_vendor_rec    => vendor_rec,
                        ext_payee_rec   => ext_payee_rec,
                        x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
        END IF;

      END IF;
      <<continue_next_record>>
      NULL;
    END LOOP;

    CLOSE vendor_int_cur;

    COMMIT WORK;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO import_vendor_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendors EXCEPTION ' || ' Message: ' ||
                        SQLCODE || ' ' || SQLERRM);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO import_vendor_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendors unexcepted EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
    WHEN OTHERS THEN
      ROLLBACK TO import_vendor_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendors others EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END import_vendors;

  PROCEDURE create_vendor_site
  (
    p_batch_id      IN NUMBER,
    p_site_rec      IN ap_vendor_pub_pkg.r_vendor_site_rec_type,
    ext_payee_rec   IN OUT NOCOPY iby_disbursement_setup_pub.external_payee_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'CREATE_VENDOR_SITE';
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_return_status  VARCHAR2(2000);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_vendor_site_id NUMBER;
    l_party_site_id  NUMBER;
    l_location_id    NUMBER;

    /* Variable Declaration for IBY */

    ext_payee_tab iby_disbursement_setup_pub.external_payee_tab_type;

    ext_payee_id_tab iby_disbursement_setup_pub.ext_payee_id_tab_type;

    ext_payee_create_tab iby_disbursement_setup_pub.ext_payee_create_tab_type;
    l_temp_ext_acct_id   NUMBER;
    ext_response_rec     iby_fndcpt_common_pub.result_rec_type;

    l_ext_payee_id NUMBER;
    l_bank_acct_id NUMBER;

    CURSOR iby_ext_accts_cur(p_unique_ref IN NUMBER) IS
      SELECT temp_ext_bank_acct_id
      FROM   iby_temp_ext_bank_accts
      WHERE  calling_app_unique_ref2 = p_unique_ref
      AND    nvl(status, 'NEW') <> 'PROCESSED';

    l_debug_info           VARCHAR2(500);
    l_rollback_vendor_site VARCHAR2(1) := 'N';
    l_payee_msg_count      NUMBER;
    l_payee_msg_data       VARCHAR2(4000);
    l_error_code           VARCHAR2(4000);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE CREATE_VENDOR_SITE' ||
                      ' Parameters  vendor_id: ' || p_site_rec.vendor_id ||
                      ' vendor_site_interface_id: ' ||
                      p_site_rec.vendor_site_interface_id);

    SAVEPOINT import_vendor_sites_pub2;

    ap_vendor_pub_pkg.create_vendor_site(p_api_version      => 1.0,
                                         p_init_msg_list    => fnd_api.g_true,
                                         p_commit           => fnd_api.g_false,
                                         p_validation_level => fnd_api.g_valid_level_full,
                                         x_return_status    => l_return_status,
                                         x_msg_count        => l_msg_count,
                                         x_msg_data         => l_msg_data,
                                         p_vendor_site_rec  => p_site_rec,
                                         x_vendor_site_id   => l_vendor_site_id,
                                         x_party_site_id    => l_party_site_id,
                                         x_location_id      => l_location_id);

    IF l_return_status = fnd_api.g_ret_sts_success THEN

      UPDATE ap_supplier_sites_int
      SET    status = 'PROCESSED'
      WHERE  vendor_site_interface_id = p_site_rec.vendor_site_interface_id
      AND    sdh_batch_id = p_batch_id;

      UPDATE pos_imp_batch_summary
      SET    total_records_imported = total_records_imported + 1,
             total_inserts          = total_inserts + 1,
             sites_inserted         = sites_inserted + 1,
             sites_imported         = sites_imported + 1
      WHERE  batch_id = p_batch_id;

      UPDATE ap_sup_site_contact_int
      SET    vendor_site_id = l_vendor_site_id
      WHERE  vendor_id = p_site_rec.vendor_id
      AND    vendor_site_code = p_site_rec.vendor_site_code
      AND    (org_id = p_site_rec.org_id OR
            operating_unit_name = p_site_rec.org_name)
      AND    sdh_batch_id = p_batch_id;

      ext_payee_rec.supplier_site_id    := l_vendor_site_id;
      ext_payee_rec.payee_party_site_id := l_party_site_id;

      SELECT org_id
      INTO   ext_payee_rec.payer_org_id
      FROM   po_vendor_sites_all
      WHERE  vendor_site_id = l_vendor_site_id;

      SELECT party_id,
             'PAYABLES_DISB'
      INTO   ext_payee_rec.payee_party_id,
             ext_payee_rec.payment_function
      FROM   po_vendors
      WHERE  vendor_id = p_site_rec.vendor_id;

      fnd_msg_pub.count_and_get(p_count => l_payee_msg_count,
                                p_data  => l_payee_msg_data);

      /* Calling IBY Payee Validation API */
      iby_disbursement_setup_pub.validate_external_payee(p_api_version   => 1.0,
                                                         p_init_msg_list => fnd_api.g_true,
                                                         p_ext_payee_rec => ext_payee_rec,
                                                         x_return_status => l_return_status,
                                                         x_msg_count     => l_msg_count,
                                                         x_msg_data      => l_msg_data);

      IF l_return_status = fnd_api.g_ret_sts_success THEN
        ext_payee_tab(1) := ext_payee_rec;

        /* Calling IBY Payee Creation API */
        iby_disbursement_setup_pub.create_external_payee(p_api_version          => 1.0,
                                                         p_init_msg_list        => fnd_api.g_true,
                                                         p_ext_payee_tab        => ext_payee_tab,
                                                         x_return_status        => l_return_status,
                                                         x_msg_count            => l_msg_count,
                                                         x_msg_data             => l_msg_data,
                                                         x_ext_payee_id_tab     => ext_payee_id_tab,
                                                         x_ext_payee_status_tab => ext_payee_create_tab);

        IF l_return_status = fnd_api.g_ret_sts_success THEN
          l_ext_payee_id := ext_payee_id_tab(1).ext_payee_id;

          UPDATE iby_temp_ext_bank_accts
          SET    ext_payee_id           = l_ext_payee_id,
                 account_owner_party_id = ext_payee_rec.payee_party_id --bug 6753331
          WHERE  calling_app_unique_ref2 =
                 p_site_rec.vendor_site_interface_id;

          -- Cursor processing for iby temp bank account record
          OPEN iby_ext_accts_cur(p_site_rec.vendor_site_interface_id);
          LOOP

            FETCH iby_ext_accts_cur
              INTO l_temp_ext_acct_id;
            EXIT WHEN iby_ext_accts_cur%NOTFOUND;

            /* Calling IBY Bank Account Validation API */
            iby_disbursement_setup_pub.validate_temp_ext_bank_acct(p_api_version      => 1.0,
                                                                   p_init_msg_list    => fnd_api.g_true,
                                                                   x_return_status    => l_return_status,
                                                                   x_msg_count        => l_msg_count,
                                                                   x_msg_data         => l_msg_data,
                                                                   p_temp_ext_acct_id => l_temp_ext_acct_id);

            IF l_return_status = fnd_api.g_ret_sts_success THEN
              /* Calling IBY Bank Account Creation API */

              iby_disbursement_setup_pub.create_temp_ext_bank_acct(p_api_version       => 1.0,
                                                                   p_init_msg_list     => fnd_api.g_true,
                                                                   x_return_status     => l_return_status,
                                                                   x_msg_count         => l_msg_count,
                                                                   x_msg_data          => l_msg_data,
                                                                   p_temp_ext_acct_id  => l_temp_ext_acct_id,
                                                                   p_association_level => 'SS',
                                                                   p_supplier_site_id  => l_vendor_site_id,
                                                                   p_party_site_id     => ext_payee_rec.payee_party_site_id,
                                                                   p_org_id            => ext_payee_rec.payer_org_id,
                                                                   p_org_type          => 'OPERATING_UNIT',
                                                                   x_bank_acc_id       => l_bank_acct_id,
                                                                   x_response          => ext_response_rec);

              IF l_return_status = fnd_api.g_ret_sts_success THEN
                UPDATE iby_temp_ext_bank_accts
                SET    status = 'PROCESSED'
                WHERE  temp_ext_bank_acct_id = l_temp_ext_acct_id;

              ELSE
                l_rollback_vendor_site := 'Y';

                fnd_message.set_name('SQLAP', 'AP_BANK_ACCT_CREATION');
                fnd_msg_pub.add;

              END IF; -- Bank Account Creation API

            ELSE
              l_rollback_vendor_site := 'Y';

              fnd_message.set_name('SQLAP', 'AP_INVALID_BANK_ACCT_INFO');
              fnd_msg_pub.add;

            END IF; -- Bank Account Validation API

          END LOOP;
          CLOSE iby_ext_accts_cur;

          /*Rollback if bank account creation fails*/
          IF l_rollback_vendor_site = 'Y' THEN

            ROLLBACK TO import_vendor_sites_pub2;

            UPDATE ap_supplier_sites_int
            SET    status = 'REJECTED'
            WHERE  vendor_site_interface_id =
                   p_site_rec.vendor_site_interface_id
            AND    sdh_batch_id = p_batch_id;

            UPDATE iby_temp_ext_bank_accts
            SET    status = 'REJECTED'
            WHERE  temp_ext_bank_acct_id = l_temp_ext_acct_id;

            IF (insert_rejections(p_batch_id,
                                  l_request_id,
                                  'AP_SUPPLIER_SITES_INT',
                                  p_site_rec.vendor_site_interface_id,
                                  'AP_INVALID_BANK_ACCT_INFO',
                                  g_user_id,
                                  g_login_id,
                                  'Create_Vendor_Site') <> TRUE) THEN

              IF (g_level_procedure >= g_current_runtime_level) THEN
                fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                          p_data  => l_msg_data);
                fnd_log.string(g_level_procedure,
                               g_module_name || l_api_name,
                               'Parameters: ' ||
                               ' Vendor_Site_Interface_Id: ' ||
                               p_site_rec.vendor_site_interface_id ||
                               ' Acct Validation Msg: ' || l_msg_data);
              END IF;
            END IF;

            fnd_file.put_line(fnd_file.log,
                              ' Message: Inside PROCEDURE CREATE_VENDOR_SITE' ||
                              ' failed in bank account creation ' ||
                              ' vendor_site_interface_id: ' ||
                              p_site_rec.vendor_site_interface_id ||
                              ' temp_ext_bank_acct_id: ' ||
                              l_temp_ext_acct_id);

            l_rollback_vendor_site := 'N'; --resetting the value to initial
          END IF;

        ELSE
          -- Payee Creation API
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'AP_SUPPLIER_SITES_INT',
                                p_site_rec.vendor_site_interface_id,
                                'AP_PAYEE_CREATION',
                                g_user_id,
                                g_login_id,
                                'Create_Vendor_Site') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Parameters: ' ||
                             ' Vendor_Site_Interface_Id: ' ||
                             p_site_rec.vendor_site_interface_id ||
                             ' Payee Validation Msg: ' || l_msg_data);
            END IF;
          END IF;

          fnd_message.set_name('SQLAP', 'AP_PAYEE_CREATION');
          fnd_msg_pub.add;

          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE CREATE_VENDOR_SITE' ||
                            ' failed in payee creation ' ||
                            ' vendor_site_interface_id: ' ||
                            p_site_rec.vendor_site_interface_id);

        END IF; -- Payee Creation API

      ELSE
        -- Payee Validation API
        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'AP_SUPPLIER_SITES_INT',
                              p_site_rec.vendor_site_interface_id,
                              'AP_INVALID_PAYEE_INFO',
                              g_user_id,
                              g_login_id,
                              'Create_Vendor_Site') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Vendor_Site_Interface_Id: ' ||
                           p_site_rec.vendor_site_interface_id ||
                           ' Payee Validation Msg: ' || l_msg_data);
          END IF;
        END IF;

        l_debug_info := 'Calling IBY Payee Validation API in import site';
        IF (l_msg_data IS NOT NULL) THEN
          -- Print the error returned from the IBY service even if the debug
          -- mode is off
          ap_import_utilities_pkg.print('Y',
                                        '4)Error in ' || l_debug_info ||
                                        '---------------------->' ||
                                        l_msg_data);

        ELSE
          -- If the l_msg_data is null then the IBY service returned
          -- more than one error.  The calling module will need to get
          -- them from the message stack
          FOR i IN l_payee_msg_count .. l_msg_count LOOP
            l_error_code := fnd_msg_pub.get(p_msg_index => i,
                                            p_encoded   => 'F');

            IF i = l_payee_msg_count THEN
              l_error_code := '4)Error in ' || l_debug_info ||
                              '---------------------->' || l_error_code;
            END IF;

            ap_import_utilities_pkg.print('Y', l_error_code);

          END LOOP;

        END IF;

        fnd_message.set_name('SQLAP', 'AP_INVALID_PAYEE_INFO');
        fnd_msg_pub.add;

        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE CREATE_VENDOR_SITE' ||
                          ' failed in payee validation ' ||
                          ' vendor_site_interface_id: ' ||
                          p_site_rec.vendor_site_interface_id);

      END IF; -- Payee Validation API

    ELSE
      -- Supplier Site Creation API
      UPDATE ap_supplier_sites_int
      SET    status = 'REJECTED'
      WHERE  vendor_site_interface_id = p_site_rec.vendor_site_interface_id
      AND    sdh_batch_id = p_batch_id;

      INSERT INTO pos_supplier_int_rejections
        (batch_id,
         import_request_id,
         parent_table,
         parent_id,
         reject_lookup_code,
         last_updated_by,
         last_update_date,
         last_update_login,
         created_by,
         creation_date)
        SELECT p_batch_id,
               l_request_id,
               parent_table,
               parent_id,
               decode(reject_lookup_code,
                      'AP_INCONSISTENT_ADDRESS',
                      'POS_INCONSISTENT_ADDRESS',
                      reject_lookup_code),
               last_updated_by,
               last_update_date,
               last_update_login,
               created_by,
               creation_date
        FROM   ap_supplier_int_rejections
        WHERE  parent_table = 'AP_SUPPLIER_SITES_INT'
        AND    parent_id = p_site_rec.vendor_site_interface_id;

      IF (g_level_procedure >= g_current_runtime_level) THEN
        fnd_log.string(g_level_procedure,
                       g_module_name || l_api_name,
                       ' Rejected Vendor_Site_Interface_Id: ' ||
                       p_site_rec.vendor_site_interface_id ||
                       ', No. of Messages from Create_Vendor_Site API: ' ||
                       l_msg_count ||
                       ', Message From Create_Vendor_Site API: ' ||
                       l_msg_data);
      END IF;

      error_handler.get_message_list(l_error_msg_tbl);
      IF l_error_msg_tbl.first IS NOT NULL THEN
        l_msg_count := l_error_msg_tbl.first;
        WHILE l_msg_count IS NOT NULL LOOP
          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE CREATE_VENDOR_SITE' ||
                             ' failed in ap_vendor_pub_pkg.create_vendor_site ' ||
                             ' vendor_site_interface_id: ' ||
                             p_site_rec.vendor_site_interface_id ||
                             ', No. of Messages: ' || l_msg_count ||
                             ', Message: ' || l_error_msg_tbl(l_msg_count)
                            .message_text);
          l_msg_count := l_error_msg_tbl.next(l_msg_count);
        END LOOP;
      ELSE
        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE CREATE_VENDOR_SITE' ||
                          ' failed in ap_vendor_pub_pkg.create_vendor_site ' ||
                          ' vendor_site_interface_id: ' ||
                          p_site_rec.vendor_site_interface_id);
      END IF;
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;

    END IF; -- Supplier Site Creation API
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside create_vendor_site EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END create_vendor_site;


  --bug 16210521 write a separate procedure to update vendor site
    PROCEDURE update_vendor_site
  (
    p_batch_id      IN NUMBER,
    p_site_rec      IN ap_vendor_pub_pkg.r_vendor_site_rec_type,
    ext_payee_rec   IN OUT NOCOPY iby_disbursement_setup_pub.external_payee_rec_type,
    p_vendor_site_id IN NUMBER,
    p_party_site_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_VENDOR_SITE';
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_return_status  VARCHAR2(2000);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_location_id    NUMBER;

    /* Variable Declaration for IBY */

    ext_payee_tab iby_disbursement_setup_pub.external_payee_tab_type;

    ext_payee_id_tab iby_disbursement_setup_pub.ext_payee_id_tab_type;

    ext_payee_update_tab iby_disbursement_setup_pub.ext_payee_update_tab_type;

    l_temp_ext_acct_id   NUMBER;
    ext_response_rec     iby_fndcpt_common_pub.result_rec_type;

    l_ext_payee_id NUMBER;
	l_ext_payee_cnt NUMBER;
    l_bank_acct_id NUMBER;

	l_ext_payee_id_rec iby_disbursement_setup_pub.Ext_Payee_ID_Rec_Type;

    CURSOR iby_ext_accts_cur(p_unique_ref IN NUMBER) IS
      SELECT temp_ext_bank_acct_id
      FROM   iby_temp_ext_bank_accts
      WHERE  calling_app_unique_ref2 = p_unique_ref
      AND    nvl(status, 'NEW') <> 'PROCESSED';

	CURSOR iby_ext_payee_cur(p_payee_party_id NUMBER,
                            p_party_site_id  NUMBER,
                            p_supplier_site_id NUMBER,
                            p_payer_org_id NUMBER,
                            p_payer_org_type VARCHAR2,
                            p_payment_function VARCHAR2) IS
	SELECT count(payee.EXT_PAYEE_ID), max(payee.EXT_PAYEE_ID)s
    FROM iby_external_payees_all payee
    WHERE payee.PAYEE_PARTY_ID = p_payee_party_id
	AND payee.PAYMENT_FUNCTION = p_payment_function
	AND ((p_party_site_id is NULL and payee.PARTY_SITE_ID is NULL) OR
		  (payee.PARTY_SITE_ID = p_party_site_id))
	AND ((p_supplier_site_id is NULL and payee.SUPPLIER_SITE_ID is NULL) OR
		  (payee.SUPPLIER_SITE_ID = p_supplier_site_id))
	AND ((p_payer_org_id is NULL and payee.ORG_ID is NULL) OR
              (payee.ORG_ID = p_payer_org_id AND payee.ORG_TYPE = p_payer_org_type));

    l_debug_info           VARCHAR2(500);
    l_rollback_vendor_site VARCHAR2(1) := 'N';
    l_payee_msg_count      NUMBER;
    l_payee_msg_data       VARCHAR2(4000);
    l_error_code           VARCHAR2(4000);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE UPDATE_VENDOR_SITE' ||
                      ' Parameters  vendor_id: ' || p_site_rec.vendor_id ||
                      ' vendor_site_interface_id: ' ||
                      p_site_rec.vendor_site_interface_id);

    SAVEPOINT import_vendor_sites_pub3;

    ap_vendor_pub_pkg.update_vendor_site(p_api_version      => 1.0,
                                         p_init_msg_list    => fnd_api.g_false,
                                         p_commit           => fnd_api.g_false,
                                         p_validation_level => fnd_api.g_valid_level_full,
                                         x_return_status    => l_return_status,
                                         x_msg_count        => l_msg_count,
                                         x_msg_data         => l_msg_data,
                                         p_vendor_site_rec  => p_site_rec,
                                         p_vendor_site_id   => p_vendor_site_id);

    IF l_return_status = fnd_api.g_ret_sts_success THEN

      UPDATE ap_supplier_sites_int
      SET    status = 'PROCESSED'
      WHERE  vendor_site_interface_id = p_site_rec.vendor_site_interface_id
      AND    sdh_batch_id = p_batch_id;

      UPDATE pos_imp_batch_summary
      SET    total_records_imported = total_records_imported + 1,
             total_inserts          = total_inserts + 1,
             sites_inserted         = sites_inserted + 1,
             sites_imported         = sites_imported + 1
      WHERE  batch_id = p_batch_id;

      UPDATE ap_sup_site_contact_int
      SET    vendor_site_id = p_vendor_site_id
      WHERE  vendor_id = p_site_rec.vendor_id
      AND    vendor_site_code = p_site_rec.vendor_site_code
      AND    (org_id = p_site_rec.org_id OR
            operating_unit_name = p_site_rec.org_name)
      AND    sdh_batch_id = p_batch_id;

      ext_payee_rec.supplier_site_id    := p_vendor_site_id;
      ext_payee_rec.payee_party_site_id := p_party_site_id;

      SELECT org_id
      INTO   ext_payee_rec.payer_org_id
      FROM   po_vendor_sites_all
      WHERE  vendor_site_id = p_vendor_site_id;

      SELECT party_id,
             'PAYABLES_DISB'
      INTO   ext_payee_rec.payee_party_id,
             ext_payee_rec.payment_function
      FROM   po_vendors
      WHERE  vendor_id = p_site_rec.vendor_id;

      fnd_msg_pub.count_and_get(p_count => l_payee_msg_count,
                                p_data  => l_payee_msg_data);

      /* Calling IBY Payee Validation API */
      iby_disbursement_setup_pub.validate_external_payee(p_api_version   => 1.0,
                                                         p_init_msg_list => fnd_api.g_true,
                                                         p_ext_payee_rec => ext_payee_rec,
                                                         x_return_status => l_return_status,
                                                         x_msg_count     => l_msg_count,
                                                         x_msg_data      => l_msg_data);

      IF l_return_status = fnd_api.g_ret_sts_success THEN

		OPEN iby_ext_payee_cur(ext_payee_rec.Payee_Party_Id,
                                ext_payee_rec.Payee_Party_Site_Id,
                                ext_payee_rec.Supplier_Site_Id,
                                ext_payee_rec.Payer_Org_Id,
                                ext_payee_rec.Payer_Org_Type,
                                ext_payee_rec.Payment_Function);
        FETCH iby_ext_payee_cur INTO l_ext_payee_cnt, l_ext_payee_id;
        CLOSE iby_ext_payee_cur;

			ext_payee_tab(1) := ext_payee_rec;
			l_ext_payee_id_rec.ext_payee_id := l_ext_payee_id;
			ext_payee_id_tab(1) := l_ext_payee_id_rec;

			/* Calling IBY Payee Update API */
			iby_disbursement_setup_pub.update_external_payee(p_api_version          => 1.0,
															 p_init_msg_list        => fnd_api.g_true,
															 p_ext_payee_tab        => ext_payee_tab,
															 p_ext_payee_id_tab		=> ext_payee_id_tab,
															 x_return_status        => l_return_status,
															 x_msg_count            => l_msg_count,
															 x_msg_data             => l_msg_data,
															 x_ext_payee_status_tab => ext_payee_update_tab);

			IF l_return_status = fnd_api.g_ret_sts_success THEN
        ext_payee_tab(1) := ext_payee_rec;
			ELSE
			-- Payee Update API
			  IF (insert_rejections(p_batch_id,
									l_request_id,
									'AP_SUPPLIER_SITES_INT',
									p_site_rec.vendor_site_interface_id,
									'AP_PAYEE_CREATION',
									g_user_id,
									g_login_id,
									'Create_Vendor_Site') <> TRUE) THEN

				IF (g_level_procedure >= g_current_runtime_level) THEN
				  fnd_msg_pub.count_and_get(p_count => l_msg_count,
											p_data  => l_msg_data);
				  fnd_log.string(g_level_procedure,
								 g_module_name || l_api_name,
								 'Parameters: ' ||
								 ' Vendor_Site_Interface_Id: ' ||
								 p_site_rec.vendor_site_interface_id ||
								 ' Payee Validation Msg: ' || l_msg_data);
				END IF;
			  END IF;

				fnd_message.set_name('SQLAP', 'AP_PAYEE_CREATION');
				fnd_msg_pub.add;

				  fnd_file.put_line(fnd_file.log,
									' Message: Inside PROCEDURE CREATE_VENDOR_SITE' ||
									' failed in payee creation ' ||
									' vendor_site_interface_id: ' ||
									p_site_rec.vendor_site_interface_id);

        END IF; -- Payee Update API
      ELSE
        -- Payee Validation API
        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'AP_SUPPLIER_SITES_INT',
                              p_site_rec.vendor_site_interface_id,
                              'AP_INVALID_PAYEE_INFO',
                              g_user_id,
                              g_login_id,
                              'Create_Vendor_Site') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Vendor_Site_Interface_Id: ' ||
                           p_site_rec.vendor_site_interface_id ||
                           ' Payee Validation Msg: ' || l_msg_data);
          END IF;
        END IF;

        l_debug_info := 'Calling IBY Payee Validation API in import site';
        IF (l_msg_data IS NOT NULL) THEN
          -- Print the error returned from the IBY service even if the debug
          -- mode is off
          ap_import_utilities_pkg.print('Y',
                                        '4)Error in ' || l_debug_info ||
                                        '---------------------->' ||
                                        l_msg_data);

        ELSE
          -- If the l_msg_data is null then the IBY service returned
          -- more than one error.  The calling module will need to get
          -- them from the message stack
          FOR i IN l_payee_msg_count .. l_msg_count LOOP
            l_error_code := fnd_msg_pub.get(p_msg_index => i,
                                            p_encoded   => 'F');

            IF i = l_payee_msg_count THEN
              l_error_code := '4)Error in ' || l_debug_info ||
                              '---------------------->' || l_error_code;
            END IF;

            ap_import_utilities_pkg.print('Y', l_error_code);

          END LOOP;

        END IF;

        fnd_message.set_name('SQLAP', 'AP_INVALID_PAYEE_INFO');
        fnd_msg_pub.add;

        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE CREATE_VENDOR_SITE' ||
                          ' failed in payee validation ' ||
                          ' vendor_site_interface_id: ' ||
                          p_site_rec.vendor_site_interface_id);

      END IF; -- Payee Validation API

    ELSE
      -- Supplier Site Creation API
      UPDATE ap_supplier_sites_int
      SET    status = 'REJECTED'
      WHERE  vendor_site_interface_id = p_site_rec.vendor_site_interface_id
      AND    sdh_batch_id = p_batch_id;

      INSERT INTO pos_supplier_int_rejections
        (batch_id,
         import_request_id,
         parent_table,
         parent_id,
         reject_lookup_code,
         last_updated_by,
         last_update_date,
         last_update_login,
         created_by,
         creation_date)
        SELECT p_batch_id,
               l_request_id,
               parent_table,
               parent_id,
               decode(reject_lookup_code,
                      'AP_INCONSISTENT_ADDRESS',
                      'POS_INCONSISTENT_ADDRESS',
                      reject_lookup_code),
               last_updated_by,
               last_update_date,
               last_update_login,
               created_by,
               creation_date
        FROM   ap_supplier_int_rejections
        WHERE  parent_table = 'AP_SUPPLIER_SITES_INT'
        AND    parent_id = p_site_rec.vendor_site_interface_id;

      IF (g_level_procedure >= g_current_runtime_level) THEN
        fnd_log.string(g_level_procedure,
                       g_module_name || l_api_name,
                       ' Rejected Vendor_Site_Interface_Id: ' ||
                       p_site_rec.vendor_site_interface_id ||
                       ', No. of Messages from Update_Vendor_Site API: ' ||
                       l_msg_count ||
                       ', Message From Update_Vendor_Site API: ' ||
                       l_msg_data);
      END IF;

      error_handler.get_message_list(l_error_msg_tbl);
      IF l_error_msg_tbl.first IS NOT NULL THEN
        l_msg_count := l_error_msg_tbl.first;
        WHILE l_msg_count IS NOT NULL LOOP
          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE update_VENDOR_SITE' ||
                             ' failed in ap_vendor_pub_pkg.update_vendor_site ' ||
                             ' vendor_site_interface_id: ' ||
                             p_site_rec.vendor_site_interface_id ||
                             ', No. of Messages: ' || l_msg_count ||
                             ', Message: ' || l_error_msg_tbl(l_msg_count)
                            .message_text);
          l_msg_count := l_error_msg_tbl.next(l_msg_count);
        END LOOP;
      ELSE
        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE UPDATE_VENDOR_SITE' ||
                          ' failed in ap_vendor_pub_pkg.update_vendor_site ' ||
                          ' vendor_site_interface_id: ' ||
                          p_site_rec.vendor_site_interface_id);
      END IF;
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;

    END IF; -- Supplier Site Update API
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(fnd_file.log,
                    ' Message: Inside PROCEDURE UPDATE_VENDOR_SITE' ||
                    ' no external payee found ' ||
                    ' vendor_site_interface_id: ' ||
                    p_site_rec.vendor_site_interface_id);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside update_vendor_site EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END update_vendor_site;

 PROCEDURE import_vendor_sites
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'IMPORT_VENDOR_SITES';
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_return_status      VARCHAR2(2000);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_insert_update_flag VARCHAR2(1);
    l_vendor_site_id     NUMBER;
    l_party_id           NUMBER;
    l_party_site_id      NUMBER; -- bug 16210521

    CURSOR site_int_cur IS
      SELECT *
      FROM   ap_supplier_sites_int supp
      WHERE  import_request_id = l_request_id
      AND    (org_id IS NOT NULL OR operating_unit_name IS NOT NULL)
      AND    sdh_batch_id = p_batch_id
      AND    nvl(status, 'ACTIVE') NOT IN ('PROCESSED', 'REMOVED')
      AND    NOT EXISTS
       (SELECT 1
              FROM   hz_imp_addresses_int party
              WHERE  batch_id = p_batch_id
              AND    supp.sdh_batch_id = party.batch_id
              AND    supp.party_orig_system = party.party_orig_system
              AND    supp.party_orig_system_reference =
                     party.party_orig_system_reference
              AND    supp.party_site_orig_system = party.site_orig_system
              AND    supp.party_site_orig_sys_reference =
                     party.site_orig_system_reference
              AND    party.interface_status = 'R');

    site_int_rec site_int_cur%ROWTYPE;
    site_rec     ap_vendor_pub_pkg.r_vendor_site_rec_type;

    /* Variable Declaration for IBY */
    ext_payee_rec iby_disbursement_setup_pub.external_payee_rec_type;

    CURSOR check_vendor_site_exists
    (
      cp_vendor_id        IN NUMBER,
      cp_vendor_site_code IN VARCHAR2,
      cp_operating_unit   IN VARCHAR2,
      cp_org_id           IN NUMBER
    ) IS
      SELECT 1,
             vendor_site_id,
             party_site_id
      FROM   ap_supplier_sites_all site
      WHERE  vendor_id = cp_vendor_id
      AND    VENDOR_SITE_CODE = CP_VENDOR_SITE_CODE
      AND    ORG_ID = cp_org_id;             --bug 17311920 adding org_id to identify vendor site record
      --Bug 14400745 Remove below condition since it will not allow user update any inactive sites
      --AND    (site.inactive_date > SYSDATE OR site.inactive_date IS NULL);

    l_vendor_site_exists NUMBER := 0;
  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT import_vendor_sites_pub;

    -- fnd_msg_pub.initialize;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    DELETE ap_supplier_int_rejections
    WHERE  parent_table = 'AP_SUPPLIER_SITES_INT';

    -- API body

    -- This update statement resets the unprocessed rows so
    -- that they get picked in the current run.
    UPDATE ap_supplier_sites_int api
    SET    import_request_id = NULL
    WHERE  import_request_id IS NOT NULL
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') IN ('ACTIVE', 'REJECTED')
    AND    EXISTS (SELECT 'Request Completed'
            FROM   fnd_concurrent_requests fcr
            WHERE  fcr.request_id = api.import_request_id
            AND    fcr.phase_code = 'C');

    -- Updating Interface Record with request id

    UPDATE ap_supplier_sites_int
    SET    import_request_id = l_request_id
    WHERE  import_request_id IS NULL
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED';

    UPDATE ap_supplier_sites_int
    SET    status            = 'REJECTED',
           import_request_id = l_request_id
    WHERE  (operating_unit_name IS NULL AND org_id IS NULL)
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED';

    INSERT INTO pos_supplier_int_rejections
      (SELECT p_batch_id,
              l_request_id,
              'AP_SUPPLIER_SITES_INT',
              vendor_site_interface_id,
              'AP_ORG_INFO_NULL',
              g_user_id,
              SYSDATE,
              g_login_id,
              g_user_id,
              SYSDATE
       FROM   ap_supplier_sites_int
       WHERE  status = 'REJECTED'
       AND    import_request_id = l_request_id
       AND    (operating_unit_name IS NULL AND org_id IS NULL)
       AND    sdh_batch_id = p_batch_id);

    UPDATE ap_supplier_sites_int supp
    SET    status            = 'REMOVED',
           import_request_id = l_request_id
    WHERE  sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED'
    AND    EXISTS
     (SELECT 1
            FROM   hz_imp_addresses_int party
            WHERE  batch_id = p_batch_id
            AND    supp.sdh_batch_id = party.batch_id
            AND    supp.party_orig_system = party.party_orig_system
            AND    supp.party_orig_system_reference =
                   party.party_orig_system_reference
            AND    supp.party_site_orig_system = party.site_orig_system
            AND    supp.party_site_orig_sys_reference =
                   party.site_orig_system_reference
            AND    party.interface_status = 'R');

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_SITES' ||
                      ' Not imported(marked REMOVED) : ' || SQL%ROWCOUNT ||
                      ' records. Reason interface_status in hz_imp_addresses_int = R');

    INSERT INTO pos_supplier_int_rejections
      (SELECT p_batch_id,
              l_request_id,
              'AP_SUPPLIER_SITES_INT',
              vendor_site_interface_id,
              'POS_INVALID_PARTY_ORIG_SYSTEM',
              g_user_id,
              SYSDATE,
              g_login_id,
              g_user_id,
              SYSDATE
       FROM   ap_supplier_sites_int
       WHERE  status = 'REMOVED'
       AND    import_request_id = l_request_id
       AND    sdh_batch_id = p_batch_id);

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_SITES' ||
                      ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                      ' request_id: ' || l_request_id);
    COMMIT;

    SAVEPOINT import_vendor_sites_pub; --Incase there is an unexpected error in loop below,
    --the rollback in exception can happen to this savepoint, since
    --after commit the savepoint set at the begining would be lost.

    ap_vendor_pub_pkg.g_source := 'IMPORT';

    -- Cursor processing for vendor site interface record
    OPEN site_int_cur;
    LOOP

      FETCH site_int_cur
        INTO site_int_rec;
      EXIT WHEN site_int_cur%NOTFOUND;

      site_rec.vendor_site_interface_id := site_int_rec.vendor_site_interface_id;
      site_rec.vendor_interface_id      := site_int_rec.vendor_interface_id;

      IF (site_int_rec.vendor_id IS NULL) THEN
        IF (site_int_rec.party_id IS NULL) THEN
          l_party_id := get_party_id(site_int_rec.party_orig_system,
                                     site_int_rec.party_orig_system_reference);
        ELSE
          l_party_id := site_int_rec.party_id;
        END IF;

        BEGIN
          SELECT vendor_id
          INTO   site_rec.vendor_id
          FROM   ap_suppliers supp
          WHERE  supp.party_id = l_party_id;

        EXCEPTION
          WHEN OTHERS THEN
            UPDATE ap_supplier_sites_int
            SET    status = 'REJECTED'
            WHERE  vendor_site_interface_id =
                   site_int_rec.vendor_site_interface_id
            AND    sdh_batch_id = p_batch_id;

            IF (insert_rejections(p_batch_id,
                                  l_request_id,
                                  'AP_SUPPLIER_SITES_INT',
                                  site_int_rec.vendor_site_interface_id,
                                  'AP_VENDOR_ID_NULL',
                                  g_user_id,
                                  g_login_id,
                                  'IMPORT_VENDOR_SITES') <> TRUE) THEN

              IF (g_level_procedure >= g_current_runtime_level) THEN
                fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                          p_data  => l_msg_data);
                fnd_log.string(g_level_procedure,
                               g_module_name || l_api_name,
                               ' Rejected vendor_site_interface_id: ' ||
                               site_int_rec.vendor_site_interface_id ||
                               ', No. of Messages: ' || l_msg_count ||
                               ', Message: ' || l_msg_data);
              END IF;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_file.put_line(fnd_file.log,
                              ' Vendor ID is null for: ' ||
                              ' vendor_site_interface_id: ' ||
                              site_int_rec.vendor_site_interface_id ||
                              ' party_id: ' || l_party_id);
            GOTO continue_next_record;
        END;

        --bug 16846475 --
        --update vendor_id for Integrated Supplier Import Rejections Report use --
        update ap_supplier_sites_int
        set vendor_id = site_rec.vendor_id
        where sdh_batch_id = p_batch_id
        and vendor_site_interface_id = site_int_rec.vendor_site_interface_id;
        --end 16846475 --

      ELSE
        site_rec.vendor_id := site_int_rec.vendor_id;
      END IF;

      --Bug 17311920 check org info
      IF (SITE_INT_REC.ORG_ID IS NOT NULL AND SITE_INT_REC.OPERATING_UNIT_NAME IS NOT NULL) THEN
        BEGIN
         SELECT ORGANIZATION_ID
         INTO   SITE_REC.ORG_ID
         FROM   HR_OPERATING_UNITS
         WHERE  ORGANIZATION_ID = SITE_INT_REC.ORG_ID
         AND    name = site_int_rec.operating_unit_name
         AND    sysdate < nvl(date_to, sysdate + 1);

       EXCEPTION
     -- Trap validation error
       WHEN NO_DATA_FOUND THEN
       UPDATE ap_supplier_sites_int
            SET    status = 'REJECTED'
            WHERE  vendor_site_interface_id =
                   site_int_rec.vendor_site_interface_id
            AND    sdh_batch_id = p_batch_id;

            IF (insert_rejections(p_batch_id,
                                  l_request_id,
                                  'AP_SUPPLIER_SITES_INT',
                                  site_int_rec.vendor_site_interface_id,
                                  'AP_INCONSISTENT_ORG_INFO',
                                  g_user_id,
                                  g_login_id,
                                  'IMPORT_VENDOR_SITES') <> TRUE) THEN

              IF (g_level_procedure >= g_current_runtime_level) THEN
                fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                          p_data  => l_msg_data);
                fnd_log.string(g_level_procedure,
                               g_module_name || l_api_name,
                               ' Rejected vendor_site_interface_id: ' ||
                               site_int_rec.vendor_site_interface_id ||
                               ', No. of Messages: ' || l_msg_count ||
                               ', Message: ' || l_msg_data);
              END IF;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            FND_FILE.PUT_LINE(FND_FILE.LOG,
                              ' Org ID and Operating Unit Name are inconsistent for: ' ||
                              ' vendor_site_interface_id: ' ||
                              site_int_rec.vendor_site_interface_id ||
                              ' party_id: ' || l_party_id);
            GOTO continue_next_record;
        END;
      ELSIF (SITE_INT_REC.ORG_ID IS NULL AND SITE_INT_REC.OPERATING_UNIT_NAME IS NOT NULL) THEN
       BEGIN
         SELECT ORGANIZATION_ID
         INTO   SITE_INT_REC.ORG_ID
         FROM   HR_OPERATING_UNITS
         WHERE  NAME = SITE_INT_REC.OPERATING_UNIT_NAME
         AND    sysdate < nvl(date_to, sysdate + 1);

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            UPDATE ap_supplier_sites_int
            SET    status = 'REJECTED'
            WHERE  vendor_site_interface_id =
                   site_int_rec.vendor_site_interface_id
            AND    sdh_batch_id = p_batch_id;

            IF (insert_rejections(p_batch_id,
                                  l_request_id,
                                  'AP_SUPPLIER_SITES_INT',
                                  site_int_rec.vendor_site_interface_id,
                                  'AP_INVALID_ORG_INFO',
                                  g_user_id,
                                  g_login_id,
                                  'IMPORT_VENDOR_SITES') <> TRUE) THEN

              IF (g_level_procedure >= g_current_runtime_level) THEN
                fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                          p_data  => l_msg_data);
                fnd_log.string(g_level_procedure,
                               g_module_name || l_api_name,
                               ' Rejected vendor_site_interface_id: ' ||
                               site_int_rec.vendor_site_interface_id ||
                               ', No. of Messages: ' || l_msg_count ||
                               ', Message: ' || l_msg_data);
              END IF;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            FND_FILE.PUT_LINE(FND_FILE.LOG,
                              ' Invalid Operating Unit Name for: ' ||
                              ' vendor_site_interface_id: ' ||
                              site_int_rec.vendor_site_interface_id ||
                              ' party_id: ' || L_PARTY_ID);
            GOTO CONTINUE_NEXT_RECORD;
      WHEN OTHERS THEN
          UPDATE ap_supplier_sites_int
            SET    status = 'REJECTED'
            WHERE  vendor_site_interface_id =
                   site_int_rec.vendor_site_interface_id
            AND    sdh_batch_id = p_batch_id;

            IF (insert_rejections(p_batch_id,
                                  l_request_id,
                                  'AP_SUPPLIER_SITES_INT',
                                  site_int_rec.vendor_site_interface_id,
                                  'AP_INVALID_ORG_INFO',
                                  g_user_id,
                                  g_login_id,
                                  'IMPORT_VENDOR_SITES') <> TRUE) THEN

              IF (g_level_procedure >= g_current_runtime_level) THEN
                fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                          p_data  => l_msg_data);
                fnd_log.string(g_level_procedure,
                               g_module_name || l_api_name,
                               ' Rejected vendor_site_interface_id: ' ||
                               site_int_rec.vendor_site_interface_id ||
                               ', No. of Messages: ' || l_msg_count ||
                               ', Message: ' || l_msg_data);
              END IF;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            FND_FILE.PUT_LINE(FND_FILE.LOG,
                              ' Invalid Operating Unit Name for: ' ||
                              ' vendor_site_interface_id: ' ||
                              site_int_rec.vendor_site_interface_id ||
                              ' party_id: ' || L_PARTY_ID);
            GOTO CONTINUE_NEXT_RECORD;
        END;
      END IF;
      --End Bug 17311920

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE IMPORT_VENDOR_SITES' ||
                        ' vendor_site_interface_id: ' ||
                        site_rec.vendor_site_interface_id || ' party_id: ' ||
                        l_party_id || ' vendor_id: ' || site_rec.vendor_id);

      site_rec.vendor_site_code     := site_int_rec.vendor_site_code;
      site_rec.vendor_site_code_alt := site_int_rec.vendor_site_code_alt;
      site_rec.purchasing_site_flag := site_int_rec.purchasing_site_flag;
      site_rec.rfq_only_site_flag   := site_int_rec.rfq_only_site_flag;
      site_rec.pay_site_flag        := site_int_rec.pay_site_flag;
      site_rec.attention_ar_flag    := site_int_rec.attention_ar_flag;

      site_rec.address_line1                 := rtrim(site_int_rec.address_line1);
      site_rec.address_lines_alt             := rtrim(site_int_rec.address_lines_alt);
      site_rec.address_line2                 := rtrim(site_int_rec.address_line2);
      site_rec.address_line3                 := rtrim(site_int_rec.address_line3);
      site_rec.city                          := rtrim(site_int_rec.city);
      site_rec.state                         := rtrim(site_int_rec.state);
      site_rec.zip                           := site_int_rec.zip;
      site_rec.province                      := site_int_rec.province;
      site_rec.country                       := site_int_rec.country;
      site_rec.phone                         := site_int_rec.phone;
      site_rec.area_code                     := site_int_rec.area_code;
      site_rec.customer_num                  := site_int_rec.customer_num;
      site_rec.ship_to_location_id           := site_int_rec.ship_to_location_id;
      site_rec.ship_to_location_code         := site_int_rec.ship_to_location_code;
      site_rec.bill_to_location_id           := site_int_rec.bill_to_location_id;
      site_rec.bill_to_location_code         := site_int_rec.bill_to_location_code;
      site_rec.ship_via_lookup_code          := site_int_rec.ship_via_lookup_code;
      site_rec.freight_terms_lookup_code     := site_int_rec.freight_terms_lookup_code;
      site_rec.fob_lookup_code               := site_int_rec.fob_lookup_code;
      site_rec.inactive_date                 := site_int_rec.inactive_date;
      site_rec.fax                           := site_int_rec.fax;
      site_rec.fax_area_code                 := site_int_rec.fax_area_code;
      site_rec.telex                         := site_int_rec.telex;
      site_rec.terms_date_basis              := site_int_rec.terms_date_basis;
      site_rec.distribution_set_id           := site_int_rec.distribution_set_id;
      site_rec.distribution_set_name         := site_int_rec.distribution_set_name;
      site_rec.accts_pay_code_combination_id := site_int_rec.accts_pay_code_combination_id;
      site_rec.prepay_code_combination_id    := site_int_rec.prepay_code_combination_id;
      site_rec.pay_group_lookup_code         := site_int_rec.pay_group_lookup_code;
      site_rec.payment_priority              := site_int_rec.payment_priority;
      site_rec.terms_id                      := site_int_rec.terms_id;
      site_rec.terms_name                    := site_int_rec.terms_name;

      site_rec.tolerance_id   := site_int_rec.tolerance_id;
      site_rec.tolerance_name := site_int_rec.tolerance_name;

      site_rec.invoice_amount_limit          := site_int_rec.invoice_amount_limit;
      site_rec.pay_date_basis_lookup_code    := site_int_rec.pay_date_basis_lookup_code;
      site_rec.always_take_disc_flag         := site_int_rec.always_take_disc_flag;
      site_rec.invoice_currency_code         := site_int_rec.invoice_currency_code;
      site_rec.payment_currency_code         := site_int_rec.payment_currency_code;
      site_rec.hold_all_payments_flag        := site_int_rec.hold_all_payments_flag;
      site_rec.hold_future_payments_flag     := site_int_rec.hold_future_payments_flag;
      site_rec.hold_reason                   := site_int_rec.hold_reason;
      site_rec.hold_unmatched_invoices_flag  := site_int_rec.hold_unmatched_invoices_flag;
      site_rec.tax_reporting_site_flag       := site_int_rec.tax_reporting_site_flag;
      site_rec.attribute_category            := site_int_rec.attribute_category;
      site_rec.attribute1                    := site_int_rec.attribute1;
      site_rec.attribute2                    := site_int_rec.attribute2;
      site_rec.attribute3                    := site_int_rec.attribute3;
      site_rec.attribute4                    := site_int_rec.attribute4;
      site_rec.attribute5                    := site_int_rec.attribute5;
      site_rec.attribute6                    := site_int_rec.attribute6;
      site_rec.attribute7                    := site_int_rec.attribute7;
      site_rec.attribute8                    := site_int_rec.attribute8;
      site_rec.attribute9                    := site_int_rec.attribute9;
      site_rec.attribute10                   := site_int_rec.attribute10;
      site_rec.attribute11                   := site_int_rec.attribute11;
      site_rec.attribute12                   := site_int_rec.attribute12;
      site_rec.attribute13                   := site_int_rec.attribute13;
      site_rec.attribute14                   := site_int_rec.attribute14;
      site_rec.attribute15                   := site_int_rec.attribute15;
      site_rec.exclude_freight_from_discount := site_int_rec.exclude_freight_from_discount;
      site_rec.org_id                        := site_int_rec.org_id;
      site_rec.org_name                      := site_int_rec.operating_unit_name;
      site_rec.address_line4                 := rtrim(site_int_rec.address_line4);
      site_rec.county                        := site_int_rec.county;
      site_rec.address_style                 := site_int_rec.address_style;
      site_rec.language                      := site_int_rec.language;
      site_rec.allow_awt_flag                := site_int_rec.allow_awt_flag;
      site_rec.awt_group_id                  := site_int_rec.awt_group_id;
      site_rec.awt_group_name                := site_int_rec.awt_group_name;
      site_rec.global_attribute1             := site_int_rec.global_attribute1;
      site_rec.global_attribute2             := site_int_rec.global_attribute2;
      site_rec.global_attribute3             := site_int_rec.global_attribute3;
      site_rec.global_attribute4             := site_int_rec.global_attribute4;
      site_rec.global_attribute5             := site_int_rec.global_attribute5;
      site_rec.global_attribute6             := site_int_rec.global_attribute6;
      site_rec.global_attribute7             := site_int_rec.global_attribute7;
      site_rec.global_attribute8             := site_int_rec.global_attribute8;
      site_rec.global_attribute9             := site_int_rec.global_attribute9;
      site_rec.global_attribute10            := site_int_rec.global_attribute10;
      site_rec.global_attribute11            := site_int_rec.global_attribute11;
      site_rec.global_attribute12            := site_int_rec.global_attribute12;
      site_rec.global_attribute13            := site_int_rec.global_attribute13;
      site_rec.global_attribute14            := site_int_rec.global_attribute14;
      site_rec.global_attribute15            := site_int_rec.global_attribute15;
      site_rec.global_attribute16            := site_int_rec.global_attribute16;
      site_rec.global_attribute17            := site_int_rec.global_attribute17;
      site_rec.global_attribute18            := site_int_rec.global_attribute18;
      site_rec.global_attribute19            := site_int_rec.global_attribute19;
      site_rec.global_attribute20            := site_int_rec.global_attribute20;
      site_rec.global_attribute_category     := site_int_rec.global_attribute_category;
      site_rec.bank_charge_bearer            := site_int_rec.bank_charge_bearer;
      site_rec.pay_on_code                   := site_int_rec.pay_on_code;
      site_rec.pay_on_receipt_summary_code   := site_int_rec.pay_on_receipt_summary_code;
      site_rec.default_pay_site_id           := site_int_rec.default_pay_site_id;
      site_rec.tp_header_id                  := site_int_rec.tp_header_id;
      site_rec.ece_tp_location_code          := site_int_rec.ece_tp_location_code;
      site_rec.pcard_site_flag               := site_int_rec.pcard_site_flag;
      site_rec.match_option                  := site_int_rec.match_option;
      site_rec.country_of_origin_code        := site_int_rec.country_of_origin_code;
      site_rec.future_dated_payment_ccid     := site_int_rec.future_dated_payment_ccid;
      site_rec.create_debit_memo_flag        := site_int_rec.create_debit_memo_flag;
      site_rec.supplier_notif_method         := site_int_rec.supplier_notif_method;
      site_rec.email_address                 := site_int_rec.email_address;
      site_rec.primary_pay_site_flag         := site_int_rec.primary_pay_site_flag;
      site_rec.shipping_control              := site_int_rec.shipping_control;
      site_rec.duns_number                   := site_int_rec.duns_number;
      site_rec.retainage_rate                := site_int_rec.retainage_rate;
      site_rec.vat_code                      := site_int_rec.vat_code;

      site_rec.vat_registration_num := site_int_rec.vat_registration_num;
      site_rec.edi_id_number        := site_int_rec.edi_id_number;
      /* Commented Suchita */
      -- site_rec.remit_advice_delivery_method := site_int_rec.remit_advice_delivery_method;

      ext_payee_rec.payer_org_type     := 'OPERATING_UNIT';
      ext_payee_rec.exclusive_pay_flag := nvl(site_int_rec.exclusive_payment_flag,
                                              'N');

      ext_payee_rec.default_pmt_method := site_int_rec.payment_method_lookup_code;
      ext_payee_rec.ece_tp_loc_code    := site_int_rec.ece_tp_location_code;

      ext_payee_rec.bank_charge_bearer  := site_int_rec.iby_bank_charge_bearer;
      ext_payee_rec.bank_instr1_code    := site_int_rec.bank_instruction1_code;
      ext_payee_rec.bank_instr2_code    := site_int_rec.bank_instruction2_code;
      ext_payee_rec.bank_instr_detail   := site_int_rec.bank_instruction_details;
      ext_payee_rec.pay_reason_code     := site_int_rec.payment_reason_code;
      ext_payee_rec.pay_reason_com      := site_int_rec.payment_reason_comments;
      ext_payee_rec.pay_message1        := site_int_rec.payment_text_message1;
      ext_payee_rec.pay_message2        := site_int_rec.payment_text_message2;
      ext_payee_rec.pay_message3        := site_int_rec.payment_text_message3;
      ext_payee_rec.delivery_channel    := site_int_rec.delivery_channel_code;
      ext_payee_rec.pmt_format          := site_int_rec.payment_format_code;
      ext_payee_rec.settlement_priority := site_int_rec.settlement_priority;


      -- Note that we must populate these EDI related fields only to ext_payee_rec
      -- Because only this record is passed for call to IBY in case of import.
      -- There is no need to populate site_rec.ext_payee_rec.
      -- Even if we pass it wont be used.
      ext_payee_rec.edi_payment_format         := site_int_rec.edi_payment_format;
      ext_payee_rec.edi_transaction_handling   := site_int_rec.edi_transaction_handling;
      ext_payee_rec.edi_payment_method         := site_int_rec.edi_payment_method;
      ext_payee_rec.edi_remittance_method      := site_int_rec.edi_remittance_method;
      ext_payee_rec.edi_remittance_instruction := site_int_rec.edi_remittance_instruction;

	  --bug 16210521 add missing fields
	  ext_payee_rec.remit_advice_email  := site_int_rec.remittance_email;


      site_rec.ext_payee_rec.payer_org_type      := 'OPERATING_UNIT';
      site_rec.ext_payee_rec.payment_function    := 'PAYABLES_DISB';
      site_rec.ext_payee_rec.exclusive_pay_flag  := nvl(site_int_rec.exclusive_payment_flag,
                                                        'N');
      site_rec.ext_payee_rec.default_pmt_method  := site_int_rec.payment_method_lookup_code;
      site_rec.ext_payee_rec.ece_tp_loc_code     := site_int_rec.ece_tp_location_code;
      site_rec.ext_payee_rec.bank_charge_bearer  := site_int_rec.iby_bank_charge_bearer;
      site_rec.ext_payee_rec.bank_instr1_code    := site_int_rec.bank_instruction1_code;
      site_rec.ext_payee_rec.bank_instr2_code    := site_int_rec.bank_instruction2_code;
      site_rec.ext_payee_rec.bank_instr_detail   := site_int_rec.bank_instruction_details;
      site_rec.ext_payee_rec.pay_reason_code     := site_int_rec.payment_reason_code;
      site_rec.ext_payee_rec.pay_reason_com      := site_int_rec.payment_reason_comments;
      site_rec.ext_payee_rec.pay_message1        := site_int_rec.payment_text_message1;
      site_rec.ext_payee_rec.pay_message2        := site_int_rec.payment_text_message2;
      site_rec.ext_payee_rec.pay_message3        := site_int_rec.payment_text_message3;
      site_rec.ext_payee_rec.delivery_channel    := site_int_rec.delivery_channel_code;
      site_rec.ext_payee_rec.pmt_format          := site_int_rec.payment_format_code;
      site_rec.ext_payee_rec.settlement_priority := site_int_rec.settlement_priority;

      site_rec.supplier_notif_method := site_int_rec.supplier_notif_method;
      site_rec.email_address         := site_int_rec.email_address;
      /* Commented Suchita */
      /*site_rec.remittance_email      := site_int_rec.remittance_email;
      site_rec.ext_payee_rec.remit_advice_delivery_method := site_int_rec.remit_advice_delivery_method;*/
      site_rec.ext_payee_rec.remit_advice_email := site_int_rec.remittance_email;

      site_rec.party_site_id   := site_int_rec.party_site_id;
      site_rec.party_site_name := site_int_rec.party_site_name;

      site_rec.auto_tax_calc_flag := site_int_rec.auto_tax_calc_flag;
      site_rec.offset_tax_flag    := site_int_rec.offset_tax_flag;
	  --bug 17051802: added the missing fields ap_tax_rounding_rule and amount_includes_tax_flag
      site_rec.ap_tax_rounding_rule := site_int_rec.ap_tax_rounding_rule;
      site_rec.amount_includes_tax_flag := site_int_rec.amount_includes_tax_flag;

      BEGIN
        SELECT insert_update_flag
        INTO   l_insert_update_flag
        FROM   hz_imp_addresses_int
        WHERE  batch_id = p_batch_id
        AND    party_orig_system = site_int_rec.party_orig_system
        AND    party_orig_system_reference =
               site_int_rec.party_orig_system_reference
        AND    site_orig_system = site_int_rec.party_site_orig_system
        AND    site_orig_system_reference =
               site_int_rec.party_site_orig_sys_reference;

      EXCEPTION
        WHEN OTHERS THEN
          l_insert_update_flag := 'O';
      END;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE IMPORT_VENDOR_SITES' ||
                        ' Parameters  insert_update_flag: ' ||
                        l_insert_update_flag ||
                        ' for vendor_site_interface_id: ' ||
                        site_rec.vendor_site_interface_id);

      IF (l_insert_update_flag = 'I') THEN
        create_vendor_site(p_batch_id      => p_batch_id,
                           p_site_rec      => site_rec,
                           ext_payee_rec   => ext_payee_rec,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data);
      ELSE
        /* Check whether supplier site exist */
        OPEN check_vendor_site_exists(site_rec.vendor_id,
                                       site_rec.vendor_site_code,
                                       site_rec.org_name,
                                       site_rec.org_id);
        FETCH check_vendor_site_exists
          INTO l_vendor_site_exists,
               l_vendor_site_id,
               l_party_site_id;
        CLOSE check_vendor_site_exists;

        -- If the vendor exists then update it
        IF l_vendor_site_exists <> 0
        AND l_party_site_id = site_rec.party_site_id THEN    --bug 16846475 different party_site_id indicates different sites
          l_vendor_site_exists := 0;

          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE IMPORT_VENDOR_SITES' ||
                            ' As vendor site exists calling' ||
                            ' ap_vendor_pub_pkg.update_vendor_site for vendor_site_id: ' ||
                            l_vendor_site_id);

          site_rec.vendor_site_code := null;    --Bug 16441477 avoid duplicate supplier site checking


          -- bug 16210521 call a separate procedure to update vendor site
          update_vendor_site(p_batch_id      => p_batch_id,
                             p_site_rec      => site_rec,
                             ext_payee_rec   => ext_payee_rec,
                             p_vendor_site_id => l_vendor_site_id,
                             p_party_site_id => l_party_site_id,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);
         /*         ap_vendor_pub_pkg.update_vendor_site(1.0,
                                               fnd_api.g_false,
                                               fnd_api.g_false,
                                               fnd_api.g_valid_level_full,
                                               l_return_status,
                                               l_msg_count,
                                               l_msg_data,
                                               site_rec,
                                               l_vendor_site_id);

          IF l_return_status = fnd_api.g_ret_sts_success THEN

            UPDATE ap_supplier_sites_int
            SET    status = 'PROCESSED'
            WHERE  vendor_site_interface_id =
                   site_rec.vendor_site_interface_id
            AND    sdh_batch_id = p_batch_id;

            UPDATE pos_imp_batch_summary
            SET    total_records_imported = total_records_imported + 1,
                   total_updates          = total_updates + 1,
                   sites_updated          = sites_updated + 1,
                   sites_imported         = sites_imported + 1
            WHERE  batch_id = p_batch_id;
          ELSE
            UPDATE ap_supplier_sites_int
            SET    status = 'REJECTED'
            WHERE  vendor_site_interface_id =
                   site_rec.vendor_site_interface_id
            AND    sdh_batch_id = p_batch_id;

            INSERT INTO pos_supplier_int_rejections
              (batch_id,
               import_request_id,
               parent_table,
               parent_id,
               reject_lookup_code,
               last_updated_by,
               last_update_date,
               last_update_login,
               created_by,
               creation_date)
              SELECT p_batch_id,
                     l_request_id,
                     parent_table,
                     parent_id,
                     reject_lookup_code,
                     last_updated_by,
                     last_update_date,
                     last_update_login,
                     created_by,
                     creation_date
              FROM   ap_supplier_int_rejections
              WHERE  parent_table = 'AP_SUPPLIER_SITES_INT'
              AND    parent_id = site_rec.vendor_site_interface_id;

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             ' Rejected vendor_site_interface_id: ' ||
                             site_rec.vendor_site_interface_id ||
                             ', No. of Messages from update_vendor_site API: ' ||
                             l_msg_count ||
                             ', Message From update_vendor_site API: ' ||
                             l_msg_data);
            END IF;

            fnd_file.put_line(fnd_file.log,
                              ' Message: Inside PROCEDURE IMPORT_VENDOR_SITES' ||
                              ' failed in ap_vendor_pub_pkg.update_vendor_site ' ||
                              ' vendor_site_interface_id: ' ||
                              site_rec.vendor_site_interface_id ||
                              ', No. of Messages: ' || l_msg_count ||
                              ', Message: ' || l_msg_data ||
                              ', Return Status: ' || l_return_status);

            x_return_status := l_return_status;
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;

          END IF;*/

        ELSE
          create_vendor_site(p_batch_id      => p_batch_id,
                             p_site_rec      => site_rec,
                             ext_payee_rec   => ext_payee_rec,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data);
        END IF;
      END IF;
      <<continue_next_record>>
      NULL;
    END LOOP;

    CLOSE site_int_cur;

    -- End of API body.

    -- Standard check of p_commit.
    COMMIT WORK;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO import_vendor_sites_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_sites EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO import_vendor_sites_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_sites unexcepted EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
    WHEN OTHERS THEN
      ROLLBACK TO import_vendor_sites_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_sites others EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END import_vendor_sites;

  PROCEDURE create_vendor_contact
  (
    p_batch_id           IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    p_vendor_contact_rec IN ap_vendor_pub_pkg.r_vendor_contact_rec_type
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'CREATE_VENDOR_CONTACT';
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_return_status     VARCHAR2(2000);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_vendor_contact_id NUMBER;
    l_per_party_id      NUMBER;
    l_rel_party_id      NUMBER;
    l_rel_id            NUMBER;
    l_org_contact_id    NUMBER;
    l_party_site_id     NUMBER;

    CURSOR l_cur IS
      SELECT 1
      FROM   ap_supplier_contacts
      WHERE  org_party_site_id = p_vendor_contact_rec.org_party_site_id
      AND    per_party_id = p_vendor_contact_rec.per_party_id
      AND    (inactive_date IS NULL OR inactive_date >= SYSDATE)
      AND    rownum = 1;

    l_number NUMBER;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE CREATE_VENDOR_CONTACT' ||
                      ' Parameters  vendor_id: ' ||
                      p_vendor_contact_rec.vendor_id ||
                      ' vendor_contact_interface_id: ' ||
                      p_vendor_contact_rec.vendor_contact_interface_id);

    OPEN l_cur;
    FETCH l_cur
      INTO l_number;
    IF l_cur%FOUND THEN
      -- already has such assignment
      CLOSE l_cur;
      l_return_status := fnd_api.g_ret_sts_success;
    ELSE
      ap_vendor_pub_pkg.create_vendor_contact(p_api_version        => 1.0,
                                              p_init_msg_list      => fnd_api.g_true,
                                              p_commit             => fnd_api.g_false,
                                              p_validation_level   => fnd_api.g_valid_level_full,
                                              x_return_status      => l_return_status,
                                              x_msg_count          => l_msg_count,
                                              x_msg_data           => l_msg_data,
                                              p_vendor_contact_rec => p_vendor_contact_rec,
                                              x_vendor_contact_id  => l_vendor_contact_id,
                                              x_per_party_id       => l_per_party_id,
                                              x_rel_party_id       => l_rel_party_id,
                                              x_rel_id             => l_rel_id,
                                              x_org_contact_id     => l_org_contact_id,
                                              x_party_site_id      => l_party_site_id);

    END IF;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN

      IF (g_level_procedure >= g_current_runtime_level) THEN
        fnd_log.string(g_level_procedure,
                       g_module_name || l_api_name,
                       ' Rejected Vendor_Contact_Interface_Id: ' ||
                       p_vendor_contact_rec.vendor_contact_interface_id ||
                       ', No. of Messages from Create_Vendor_Contact API: ' ||
                       l_msg_count ||
                       ', Message From Create_Vendor_Contact API: ' ||
                       l_msg_data);
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' Rejected Vendor_Contact_Interface_Id: ' ||
                        p_vendor_contact_rec.vendor_contact_interface_id ||
                        ', No. of Messages from Create_Vendor_Contact API: ' ||
                        l_msg_count ||
                        ', Message From Create_Vendor_Contact API: ' ||
                        l_msg_data);
    END IF;
    x_return_status := l_return_status;
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside create_vendor_contact EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END create_vendor_contact;

  PROCEDURE import_vendor_contacts
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'IMPORT_VENDOR_CONTACTS';

    l_request_id         NUMBER := fnd_global.conc_request_id;
    l_insert_update_flag VARCHAR2(1);
    l_return_status      VARCHAR2(2000);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_per_party_id       NUMBER;
    l_count              NUMBER;

    CURSOR contact_int_cur IS
      SELECT *
      FROM   ap_sup_site_contact_int supp
      WHERE  import_request_id = l_request_id
      AND    (org_id IS NOT NULL OR operating_unit_name IS NOT NULL)
      AND    last_name IS NOT NULL
      AND    sdh_batch_id = p_batch_id
      AND    nvl(status, 'ACTIVE') NOT IN ('PROCESSED', 'REMOVED')
      AND    NOT EXISTS
       (SELECT 1
              FROM   hz_imp_contacts_int party
              WHERE  batch_id = p_batch_id
              AND    supp.sdh_batch_id = party.batch_id
              AND    supp.party_orig_system = party.obj_orig_system
              AND    supp.party_orig_system_reference =
                     party.obj_orig_system_reference
              AND    supp.contact_orig_system = party.contact_orig_system
              AND    supp.contact_orig_system_reference =
                     party.contact_orig_system_reference
              AND    party.interface_status = 'R');

    contact_int_rec    contact_int_cur%ROWTYPE;
    vendor_contact_rec ap_vendor_pub_pkg.r_vendor_contact_rec_type;

  BEGIN
    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    DELETE ap_supplier_int_rejections
    WHERE  parent_table = 'AP_SUP_SITE_CONTACT_INT';

    -- API body

    -- This update statement resets the unprocessed rows so
    -- that they get picked in the current run.
    UPDATE ap_sup_site_contact_int api
    SET    import_request_id = NULL
    WHERE  import_request_id IS NOT NULL
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') IN ('ACTIVE', 'REJECTED')
    AND    EXISTS (SELECT 'Request Completed'
            FROM   fnd_concurrent_requests fcr
            WHERE  fcr.request_id = api.import_request_id
            AND    fcr.phase_code = 'C');

    -- Updating Interface Record with request id

    UPDATE ap_sup_site_contact_int
    SET    import_request_id = l_request_id
    WHERE  import_request_id IS NULL
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED';

    UPDATE ap_sup_site_contact_int
    SET    status            = 'REJECTED',
           import_request_id = l_request_id
    WHERE  ((operating_unit_name IS NULL AND org_id IS NULL) OR
           (last_name IS NULL))
    AND    sdh_batch_id = p_batch_id;

    INSERT INTO pos_supplier_int_rejections
      (SELECT p_batch_id,
              l_request_id,
              'AP_SUP_SITE_CONTACT_INT',
              vendor_contact_interface_id,
              'AP_ORG_INFO_NULL',
              g_user_id,
              SYSDATE,
              g_login_id,
              g_user_id,
              SYSDATE
       FROM   ap_sup_site_contact_int
       WHERE  status = 'REJECTED'
       AND    import_request_id = l_request_id
       AND    sdh_batch_id = p_batch_id
       AND    (operating_unit_name IS NULL AND org_id IS NULL)) UNION
      (SELECT p_batch_id,
              l_request_id,
              'AP_SUP_SITE_CONTACT_INT',
              vendor_contact_interface_id,
              'AP_LAST_NAME_NULL',
              g_user_id,
              SYSDATE,
              g_login_id,
              g_user_id,
              SYSDATE
       FROM   ap_sup_site_contact_int
       WHERE  status = 'REJECTED'
       AND    import_request_id = l_request_id
       AND    sdh_batch_id = p_batch_id
       AND    last_name IS NULL);

    UPDATE ap_sup_site_contact_int supp
    SET    status            = 'REMOVED',
           import_request_id = l_request_id
    WHERE  sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') NOT IN ('PROCESSED', 'REMOVED')
    AND    EXISTS
     (SELECT 1
            FROM   hz_imp_contacts_int party
            WHERE  batch_id = p_batch_id
            AND    supp.sdh_batch_id = party.batch_id
            AND    supp.party_orig_system = party.obj_orig_system
            AND    supp.party_orig_system_reference =
                   party.obj_orig_system_reference
            AND    supp.contact_orig_system = party.contact_orig_system
            AND    supp.contact_orig_system_reference =
                   party.contact_orig_system_reference
            AND    party.interface_status = 'R');

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_CONTACTS' ||
                      ' Not imported(marked REMOVED) : ' || SQL%ROWCOUNT ||
                      ' records. Reason interface_status in hz_imp_contacts_int = R');

    INSERT INTO pos_supplier_int_rejections
      (SELECT p_batch_id,
              l_request_id,
              'AP_SUP_SITE_CONTACT_INT',
              vendor_contact_interface_id,
              'POS_INVALID_PARTY_ORIG_SYSTEM',
              g_user_id,
              SYSDATE,
              g_login_id,
              g_user_id,
              SYSDATE
       FROM   ap_sup_site_contact_int
       WHERE  status = 'REMOVED'
       AND    import_request_id = l_request_id
       AND    sdh_batch_id = p_batch_id);

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_CONTACTS' ||
                      ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                      ' request_id: ' || l_request_id);
    COMMIT;

    SAVEPOINT import_vendor_contact_pub;

    ap_vendor_pub_pkg.g_source := 'IMPORT';

    -- Cursor processing for vendor contact interface record
    OPEN contact_int_cur;
    LOOP

      FETCH contact_int_cur
        INTO contact_int_rec;
      EXIT WHEN contact_int_cur%NOTFOUND;

      vendor_contact_rec.vendor_contact_interface_id := contact_int_rec.vendor_contact_interface_id;
      vendor_contact_rec.vendor_site_id              := contact_int_rec.vendor_site_id;
      vendor_contact_rec.person_first_name           := contact_int_rec.first_name;
      vendor_contact_rec.person_middle_name          := contact_int_rec.middle_name;
      vendor_contact_rec.person_last_name            := contact_int_rec.last_name;
      vendor_contact_rec.person_title                := contact_int_rec.title;
      vendor_contact_rec.person_first_name_phonetic  := contact_int_rec.first_name_alt;
      vendor_contact_rec.person_last_name_phonetic   := contact_int_rec.last_name_alt;
      vendor_contact_rec.contact_name_phonetic       := contact_int_rec.contact_name_alt;
      vendor_contact_rec.prefix                      := contact_int_rec.prefix;
      vendor_contact_rec.inactive_date               := contact_int_rec.inactive_date;
      vendor_contact_rec.department                  := contact_int_rec.department;
      vendor_contact_rec.mail_stop                   := contact_int_rec.mail_stop;
      vendor_contact_rec.area_code                   := contact_int_rec.area_code;
      vendor_contact_rec.phone                       := contact_int_rec.phone;
      vendor_contact_rec.alt_area_code               := contact_int_rec.alt_area_code;
      vendor_contact_rec.alt_phone                   := contact_int_rec.alt_phone;
      vendor_contact_rec.fax_area_code               := contact_int_rec.fax_area_code;
      vendor_contact_rec.fax_phone                   := contact_int_rec.fax;
      vendor_contact_rec.email_address               := contact_int_rec.email_address;
      vendor_contact_rec.url                         := contact_int_rec.url;
      vendor_contact_rec.vendor_site_code            := contact_int_rec.vendor_site_code;
      vendor_contact_rec.org_id                      := contact_int_rec.org_id;
      vendor_contact_rec.operating_unit_name         := contact_int_rec.operating_unit_name;
      vendor_contact_rec.vendor_interface_id         := contact_int_rec.vendor_interface_id;

      IF (contact_int_rec.vendor_id IS NULL) THEN
        BEGIN
          SELECT vendor_id
          INTO   vendor_contact_rec.vendor_id
          FROM   ap_suppliers supp
          WHERE  supp.party_id = contact_int_rec.party_id;

        EXCEPTION
          WHEN OTHERS THEN
            UPDATE ap_sup_site_contact_int
            SET    status = 'REJECTED'
            WHERE  vendor_contact_interface_id =
                   contact_int_rec.vendor_contact_interface_id
            AND    sdh_batch_id = p_batch_id;

            IF (insert_rejections(p_batch_id,
                                  l_request_id,
                                  'AP_SUP_SITE_CONTACT_INT',
                                  vendor_contact_rec.vendor_contact_interface_id,
                                  'AP_VENDOR_ID_NULL',
                                  g_user_id,
                                  g_login_id,
                                  'IMPORT_VENDOR_CONTACTS') <> TRUE) THEN

              IF (g_level_procedure >= g_current_runtime_level) THEN
                fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                          p_data  => l_msg_data);
                fnd_log.string(g_level_procedure,
                               g_module_name || l_api_name,
                               ' Rejected vendor_contact_interface_id: ' ||
                               vendor_contact_rec.vendor_contact_interface_id ||
                               ', No. of Messages: ' || l_msg_count ||
                               ', Message : ' || l_msg_data);
              END IF;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_file.put_line(fnd_file.log,
                              ' Vendor ID is null for: ' ||
                              ' vendor_contact_interface_id: ' ||
                              vendor_contact_rec.vendor_contact_interface_id ||
                              ' party_id: ' || contact_int_rec.party_id);
            GOTO continue_next_record;
        END;
      ELSE
        vendor_contact_rec.vendor_id := contact_int_rec.vendor_id;
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE IMPORT_VENDOR_CONTACTS' ||
                        ' vendor_contact_interface_id: ' ||
                        vendor_contact_rec.vendor_contact_interface_id ||
                        ' party_id: ' || contact_int_rec.party_id ||
                        ' vendor_id: ' || vendor_contact_rec.vendor_id);

      IF (contact_int_rec.party_site_id IS NOT NULL) THEN
        vendor_contact_rec.org_party_site_id := contact_int_rec.party_site_id;
      ELSE
        IF (contact_int_rec.party_site_orig_system IS NOT NULL AND
           contact_int_rec.party_site_orig_sys_reference IS NOT NULL) THEN

          BEGIN
            SELECT owner_table_id
            INTO   vendor_contact_rec.org_party_site_id
            FROM   hz_orig_sys_references hr
            WHERE  hr.owner_table_name = 'HZ_PARTY_SITES'
            AND    hr.orig_system = contact_int_rec.party_site_orig_system
            AND    hr.orig_system_reference =
                   contact_int_rec.party_site_orig_sys_reference
            AND    hr.status = 'A'
            AND    nvl(hr.end_date_active, SYSDATE) >= SYSDATE;

          EXCEPTION
            WHEN OTHERS THEN
              UPDATE ap_sup_site_contact_int
              SET    status = 'REJECTED'
              WHERE  vendor_contact_interface_id =
                     contact_int_rec.vendor_contact_interface_id
              AND    sdh_batch_id = p_batch_id;

              IF (insert_rejections(p_batch_id,
                                    l_request_id,
                                    'AP_SUP_SITE_CONTACT_INT',
                                    vendor_contact_rec.vendor_contact_interface_id,
                                    'POS_INV_PARTY_SITE_ORIG_SYS',
                                    g_user_id,
                                    g_login_id,
                                    'IMPORT_VENDOR_CONTACTS') <> TRUE) THEN

                IF (g_level_procedure >= g_current_runtime_level) THEN
                  fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                            p_data  => l_msg_data);
                  fnd_log.string(g_level_procedure,
                                 g_module_name || l_api_name,
                                 ' Rejected vendor_contact_interface_id: ' ||
                                 vendor_contact_rec.vendor_contact_interface_id ||
                                 ', No. of Messages: ' || l_msg_count ||
                                 ', Message : ' || l_msg_data);
                END IF;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              fnd_file.put_line(fnd_file.log,
                                ' Invalide party site orig sys and ref for: ' ||
                                ' vendor_contact_interface_id: ' ||
                                vendor_contact_rec.vendor_contact_interface_id);
              GOTO continue_next_record;
          END;
        END IF;
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' vendor_contact_rec.org_party_site_id: ' ||
                        vendor_contact_rec.org_party_site_id ||
                        ' for vendor_contact_interface_id: ' ||
                        vendor_contact_rec.vendor_contact_interface_id);

      vendor_contact_rec.party_site_name := contact_int_rec.party_site_name;

      vendor_contact_rec.per_party_id    := contact_int_rec.per_party_id;
      vendor_contact_rec.relationship_id := contact_int_rec.relationship_id;
      vendor_contact_rec.rel_party_id    := contact_int_rec.rel_party_id;
      vendor_contact_rec.org_contact_id  := contact_int_rec.org_contact_id;

      vendor_contact_rec.vendor_site_id := NULL;

      pos_supp_contact_pkg.update_supplier_contact(p_contact_party_id => vendor_contact_rec.per_party_id,
                                                   p_vendor_party_id  => contact_int_rec.party_id,
                                                   p_first_name       => vendor_contact_rec.person_first_name,
                                                   p_last_name        => vendor_contact_rec.person_last_name,
                                                   p_middle_name      => vendor_contact_rec.person_middle_name,
                                                   p_contact_title    => vendor_contact_rec.person_title,
                                                   p_job_title        => NULL,
                                                   p_phone_area_code  => vendor_contact_rec.area_code,
                                                   p_phone_number     => vendor_contact_rec.phone,
                                                   p_phone_extension  => NULL,
                                                   p_fax_area_code    => vendor_contact_rec.fax_area_code,
                                                   p_fax_number       => vendor_contact_rec.fax_phone,
                                                   p_email_address    => vendor_contact_rec.email_address,
                                                   p_inactive_date    => vendor_contact_rec.inactive_date,
                                                   x_return_status    => l_return_status,
                                                   x_msg_count        => l_msg_count,
                                                   x_msg_data         => l_msg_data,
                                                   p_department       => vendor_contact_rec.department);

      fnd_file.put_line(fnd_file.log,
                        'Before calling pos_supplier_address_pkg.assign_address_to_contact' ||
                        ' vendor_contact_rec.per_party_id: ' ||
                        vendor_contact_rec.per_party_id ||
                        ' vendor_contact_rec.org_party_site_id: ' ||
                        vendor_contact_rec.org_party_site_id ||
                        ' vendor_contact_rec.vendor_id: ' ||
                        vendor_contact_rec.vendor_id ||
                        ' for vendor_contact_interface_id: ' ||
                        vendor_contact_rec.vendor_contact_interface_id);

      BEGIN
        SELECT 1
        INTO   l_count
        FROM   ap_suppliers     pv,
               hz_relationships hzr,
               hz_org_contacts  hoc
        WHERE  pv.vendor_id = vendor_contact_rec.vendor_id
        AND    hzr.relationship_type = 'CONTACT'
        AND    hzr.relationship_code = 'CONTACT_OF'
        AND    hzr.subject_id = vendor_contact_rec.per_party_id
        AND    hzr.subject_type = 'PERSON'
        AND    hzr.subject_table_name = 'HZ_PARTIES'
        AND    hzr.object_type = 'ORGANIZATION'
        AND    hzr.object_table_name = 'HZ_PARTIES'
        AND    hzr.object_id = pv.party_id
        AND    hzr.status = 'A'
        AND    trunc(SYSDATE) BETWEEN trunc(hzr.start_date) AND
               nvl(trunc(hzr.end_date), trunc(SYSDATE + 1))
        AND    hzr.relationship_id = hoc.party_relationship_id;

      EXCEPTION
        WHEN OTHERS THEN
          UPDATE ap_sup_site_contact_int
          SET    status = 'REJECTED'
          WHERE  vendor_contact_interface_id =
                 contact_int_rec.vendor_contact_interface_id
          AND    sdh_batch_id = p_batch_id;

          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'AP_SUP_SITE_CONTACT_INT',
                                vendor_contact_rec.vendor_contact_interface_id,
                                'POS_INVALID_PERSON_PARTY_REL',
                                g_user_id,
                                g_login_id,
                                'IMPORT_VENDOR_CONTACTS') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             ' Rejected vendor_contact_interface_id: ' ||
                             vendor_contact_rec.vendor_contact_interface_id ||
                             ', No. of Messages: ' || l_msg_count ||
                             ', Message : ' || l_msg_data);
            END IF;
          END IF;
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_file.put_line(fnd_file.log,
                            ' Invalide person party id for: ' ||
                            ' vendor_contact_interface_id: ' ||
                            vendor_contact_rec.vendor_contact_interface_id);
          GOTO continue_next_record;
      END;

      IF (vendor_contact_rec.org_party_site_id IS NOT NULL) THEN
        create_vendor_contact(p_batch_id           => p_batch_id,
                              x_return_status      => l_return_status,
                              x_msg_count          => l_msg_count,
                              x_msg_data           => l_msg_data,
                              p_vendor_contact_rec => vendor_contact_rec);
        /* pos_supplier_address_pkg.assign_address_to_contact(p_contact_party_id  => vendor_contact_rec.per_party_id,
        p_org_party_site_id => vendor_contact_rec.org_party_site_id,
        p_vendor_id         => vendor_contact_rec.vendor_id,
        x_return_status     => l_return_status,
        x_msg_count         => l_msg_count,
        x_msg_data          => l_msg_data);*/
      ELSIF (vendor_contact_rec.party_site_name IS NOT NULL) THEN
        BEGIN
          SELECT party_site_id
          INTO   vendor_contact_rec.org_party_site_id
          FROM   hz_party_sites
          WHERE  party_id = contact_int_rec.party_id
          AND    party_site_name = vendor_contact_rec.party_site_name;

        EXCEPTION
          WHEN OTHERS THEN
            UPDATE ap_sup_site_contact_int
            SET    status = 'REJECTED'
            WHERE  vendor_contact_interface_id =
                   contact_int_rec.vendor_contact_interface_id
            AND    sdh_batch_id = p_batch_id;

            IF (insert_rejections(p_batch_id,
                                  l_request_id,
                                  'AP_SUP_SITE_CONTACT_INT',
                                  vendor_contact_rec.vendor_contact_interface_id,
                                  'POS_INVALID_PARTY_SITE_NAME',
                                  g_user_id,
                                  g_login_id,
                                  'IMPORT_VENDOR_CONTACTS') <> TRUE) THEN

              IF (g_level_procedure >= g_current_runtime_level) THEN
                fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                          p_data  => l_msg_data);
                fnd_log.string(g_level_procedure,
                               g_module_name || l_api_name,
                               ' Rejected vendor_contact_interface_id: ' ||
                               vendor_contact_rec.vendor_contact_interface_id ||
                               ', No. of Messages: ' || l_msg_count ||
                               ', Message : ' || l_msg_data);
              END IF;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_file.put_line(fnd_file.log,
                              ' Invalide party site name for: ' ||
                              ' vendor_contact_interface_id: ' ||
                              vendor_contact_rec.vendor_contact_interface_id);
            GOTO continue_next_record;
        END;

        create_vendor_contact(p_batch_id           => p_batch_id,
                              x_return_status      => l_return_status,
                              x_msg_count          => l_msg_count,
                              x_msg_data           => l_msg_data,
                              p_vendor_contact_rec => vendor_contact_rec);
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_success THEN
        UPDATE ap_sup_site_contact_int
        SET    status = 'PROCESSED'
        WHERE  vendor_contact_interface_id =
               vendor_contact_rec.vendor_contact_interface_id
        AND    sdh_batch_id = p_batch_id;

        BEGIN
          SELECT nvl(insert_update_flag, 'U')
          INTO   l_insert_update_flag
          FROM   hz_imp_contacts_int
          WHERE  batch_id = p_batch_id
          AND    obj_orig_system = contact_int_rec.party_orig_system
          AND    obj_orig_system_reference =
                 contact_int_rec.party_orig_system_reference
          AND    contact_orig_system = contact_int_rec.contact_orig_system
          AND    contact_orig_system_reference =
                 contact_int_rec.contact_orig_system_reference;

        EXCEPTION
          WHEN OTHERS THEN
            l_insert_update_flag := 'U';
        END;

        IF (l_insert_update_flag = 'I') THEN
          UPDATE pos_imp_batch_summary
          SET    total_records_imported = total_records_imported + 1,
                 total_inserts          = total_inserts + 1,
                 contacts_inserted      = contacts_inserted + 1,
                 contacts_imported      = contacts_imported + 1
          WHERE  batch_id = p_batch_id;
        ELSE
          UPDATE pos_imp_batch_summary
          SET    total_records_imported = total_records_imported + 1,
                 total_updates          = total_updates + 1,
                 contacts_updated       = contacts_updated + 1,
                 contacts_imported      = contacts_imported + 1
          WHERE  batch_id = p_batch_id;
        END IF;
      ELSE
        fnd_file.put_line(fnd_file.log,
                          'Record Rejected :' ||
                          vendor_contact_rec.vendor_contact_interface_id);
        UPDATE ap_sup_site_contact_int
        SET    status = 'REJECTED'
        WHERE  vendor_contact_interface_id =
               vendor_contact_rec.vendor_contact_interface_id
        AND    sdh_batch_id = p_batch_id;

        INSERT INTO pos_supplier_int_rejections
          (batch_id,
           import_request_id,
           parent_table,
           parent_id,
           reject_lookup_code,
           last_updated_by,
           last_update_date,
           last_update_login,
           created_by,
           creation_date)
          SELECT p_batch_id,
                 l_request_id,
                 parent_table,
                 parent_id,
                 reject_lookup_code,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 created_by,
                 creation_date
          FROM   ap_supplier_int_rejections
          WHERE  parent_table = 'AP_SUP_SITE_CONTACT_INT'
          AND    parent_id = vendor_contact_rec.vendor_contact_interface_id;
      END IF;
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      <<continue_next_record>>
      NULL;
    END LOOP;

    CLOSE contact_int_cur;

    -- End of API body.

    COMMIT WORK;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO import_vendor_contact_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_contacts EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO import_vendor_contact_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_contacts unexpected EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
    WHEN OTHERS THEN
      ROLLBACK TO import_vendor_contact_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_contacts others EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END import_vendor_contacts;

PROCEDURE validate_vendor_prods_services
  (
    p_batch_id           IN NUMBER,
    p_vendor_prodsrv_rec IN pos_product_service_int%ROWTYPE,
    p_party_id           IN hz_parties.party_id%TYPE,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_prod_valid         OUT NOCOPY VARCHAR2,
    x_segment_code       OUT NOCOPY VARCHAR2
  ) IS
    TYPE cursor_ref_type IS REF CURSOR;
    l_product_segment_definition VARCHAR2(2000);
    l_product_segment_count      NUMBER;
    l_default_po_category_set_id NUMBER;
    l_delimiter                  VARCHAR2(10);
    l_status                     VARCHAR(2000);
    l_error_message              VARCHAR(4000);

    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_api_name CONSTANT VARCHAR2(50) := 'VALIDATE_VENDOR_PRODS_SERVICES';
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_pscur   cursor_ref_type;
    l_sql     VARCHAR2(4000) := NULL;
    l_seg_def fnd_profile_option_values.profile_option_value%TYPE;
    --BUG 18328966
    L_SEGMENT_INDEX         VARCHAR2(10) := NULL;
    l_cat_cursor            cursor_ref_type;
    L_CAT_QUERY             VARCHAR2(4000) := NULL;
    L_CAT_SELECT_CLAUSE     VARCHAR2(4000) := 'SELECT NVL(MIN(CAT.CATEGORY_ID), 0)';
    L_CAT_FROM_CLAUSE       VARCHAR2(4000) := 'FROM POS_PRODUCT_SERVICE_INT INT,' ||
                                              'mtl_categories_kfv CAT';
    L_CAT_WHERE_CLAUSE      VARCHAR2(4000) := 'WHERE INT.PS_INTERFACE_ID = ' || P_VENDOR_PRODSRV_REC.PS_INTERFACE_ID || ' ';
    --END BUG 18328966
    l_start_pos             NUMBER := 0;
    l_index                 NUMBER := 0;
    l_segment_code          VARCHAR2(4000) := NULL;
    l_segment_count         NUMBER;
    l_segment_concat        VARCHAR2(4000) := NULL;
    l_concatenated_segments VARCHAR2(4000) := NULL;
    l_category_id           VARCHAR2(10);
  BEGIN
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;
    x_prod_valid    := 'Y';

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE VALIDATE_VENDOR_PRODS_SERVICES' ||
                      ' Parameters: ' || ' batch_id: ' || p_batch_id ||
                      ' party_id: ' || p_party_id);

    -- Below API would give the delimiter and the segment definition to be inserted
    pos_product_service_utl_pkg.initialize(x_status        => l_status,
                                           x_error_message => l_error_message);

    pos_product_service_utl_pkg.get_product_meta_data(x_product_segment_definition => l_product_segment_definition,
                                                      x_product_segment_count      => l_product_segment_count,
                                                      x_default_po_category_set_id => l_default_po_category_set_id,
                                                      x_delimiter                  => l_delimiter);

    fnd_file.put_line(fnd_file.log,
                      ' Output from pos_product_service_utl_pkg.get_product_meta_data: ' ||
                      ' product_segment_definition: ' ||
                      l_product_segment_definition ||
                      ' product_segment_count: ' || l_product_segment_count);

    -- Check if the number of segments into which the data has been
    -- inserted is equal to the product segment count
    IF (p_vendor_prodsrv_rec.segment_definition <>
       l_product_segment_definition) THEN
      x_prod_valid    := 'N';
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := 'POS_INVALID_SEGMENT_DEF';
      IF (insert_rejections(p_batch_id,
                            l_request_id,
                            'POS_PRODUCT_SERVICE_INT',
                            p_vendor_prodsrv_rec.ps_interface_id,
                            'POS_INVALID_SEGMENT_DEF',
                            g_user_id,
                            g_login_id,
                            'validate_vendor_prods_services') <> TRUE) THEN

        IF (g_level_procedure >= g_current_runtime_level) THEN
          fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                    p_data  => l_msg_data);
          fnd_log.string(g_level_procedure,
                         g_module_name || l_api_name,
                         'Parameters: ' || ' PS_INTERFACE_ID: ' ||
                         p_vendor_prodsrv_rec.ps_interface_id ||
                         ' Acct Validation Msg: ' || l_msg_data);
        END IF;
      END IF;
      fnd_file.put_line(fnd_file.log,
                        ' Invalid Segment definition for: ' ||
                        ' ps_interface_id: ' ||
                        p_vendor_prodsrv_rec.ps_interface_id ||
                        ', segment_definition: ' ||
                        p_vendor_prodsrv_rec.segment_definition);
      RETURN;
    END IF;

    l_seg_def := p_vendor_prodsrv_rec.segment_definition;

    WHILE (length(l_seg_def)) > l_start_pos LOOP
      l_index := instr(l_seg_def, '.', l_start_pos + 1); --Bug 13399285
      IF (l_index = 0) THEN
        EXIT;
      END IF;
      l_segment_code := l_segment_code || 'segment' ||
                        substr(l_seg_def,
                               l_start_pos + 1,
                               (l_index - l_start_pos - 1)) || '||' || '''' ||
                        l_delimiter || '''' || '||';
	  --BUG 18328966
      L_SEGMENT_INDEX := SUBSTR(L_SEG_DEF, L_START_POS + 1, (L_INDEX - L_START_POS - 1));
      L_CAT_WHERE_CLAUSE := L_CAT_WHERE_CLAUSE || 'AND INT.SEGMENT' || L_SEGMENT_INDEX || ' = CAT.SEGMENT' || L_SEGMENT_INDEX || ' ';
      --END BUG 18328966
      l_start_pos    := l_index;
    END LOOP;

    l_segment_code := l_segment_code || 'segment' ||
                      substr(l_seg_def, l_start_pos + 1);
    --BUG 18328966
    L_SEGMENT_INDEX := substr(l_seg_def, l_start_pos + 1);
    L_CAT_WHERE_CLAUSE := L_CAT_WHERE_CLAUSE ||
                          'AND INT.SEGMENT' || L_SEGMENT_INDEX || ' = CAT.SEGMENT' || L_SEGMENT_INDEX || ' ' ||
                          'AND CAT.category_id IN
                          (SELECT DISTINCT category_id
                          FROM   mtl_category_set_valid_cats
                          WHERE  CATEGORY_SET_ID = ' || L_DEFAULT_PO_CATEGORY_SET_ID || ')';

    --END BUG 18328966

  --Bug 13399285 - ora-00923 error, need to replace the '.' to global flexfield setup l_delimiter
    SELECT nvl2(p_vendor_prodsrv_rec.segment1,
                p_vendor_prodsrv_rec.segment1 || l_delimiter,
                p_vendor_prodsrv_rec.segment1) ||
           nvl2(p_vendor_prodsrv_rec.segment2,
                p_vendor_prodsrv_rec.segment2 || l_delimiter,
                p_vendor_prodsrv_rec.segment2) ||
           nvl2(p_vendor_prodsrv_rec.segment3,
                p_vendor_prodsrv_rec.segment3 || l_delimiter,
                p_vendor_prodsrv_rec.segment3) ||
           nvl2(p_vendor_prodsrv_rec.segment4,
                p_vendor_prodsrv_rec.segment4 || l_delimiter,
                p_vendor_prodsrv_rec.segment4) ||
           nvl2(p_vendor_prodsrv_rec.segment5,
                p_vendor_prodsrv_rec.segment5 || l_delimiter,
                p_vendor_prodsrv_rec.segment5) ||
           nvl2(p_vendor_prodsrv_rec.segment6,
                p_vendor_prodsrv_rec.segment6 || l_delimiter,
                p_vendor_prodsrv_rec.segment6) ||
           nvl2(p_vendor_prodsrv_rec.segment7,
                p_vendor_prodsrv_rec.segment7 || l_delimiter,
                p_vendor_prodsrv_rec.segment7) ||
           nvl2(p_vendor_prodsrv_rec.segment8,
                p_vendor_prodsrv_rec.segment8 || l_delimiter,
                p_vendor_prodsrv_rec.segment8) ||
           nvl2(p_vendor_prodsrv_rec.segment9,
                p_vendor_prodsrv_rec.segment9 || l_delimiter,
                p_vendor_prodsrv_rec.segment9) ||
           nvl2(p_vendor_prodsrv_rec.segment10,
                p_vendor_prodsrv_rec.segment10 || l_delimiter,
                p_vendor_prodsrv_rec.segment10) ||
           nvl2(p_vendor_prodsrv_rec.segment11,
                p_vendor_prodsrv_rec.segment11 || l_delimiter,
                p_vendor_prodsrv_rec.segment11) ||
           nvl2(p_vendor_prodsrv_rec.segment12,
                p_vendor_prodsrv_rec.segment12 || l_delimiter,
                p_vendor_prodsrv_rec.segment12) ||
           nvl2(p_vendor_prodsrv_rec.segment13,
                p_vendor_prodsrv_rec.segment13 || l_delimiter,
                p_vendor_prodsrv_rec.segment13) ||
           nvl2(p_vendor_prodsrv_rec.segment14,
                p_vendor_prodsrv_rec.segment14 || l_delimiter,
                p_vendor_prodsrv_rec.segment14) ||
           nvl2(p_vendor_prodsrv_rec.segment15,
                p_vendor_prodsrv_rec.segment15 || l_delimiter,
                p_vendor_prodsrv_rec.segment15) ||
           nvl2(p_vendor_prodsrv_rec.segment16,
                p_vendor_prodsrv_rec.segment16 || l_delimiter,
                p_vendor_prodsrv_rec.segment16) ||
           nvl2(p_vendor_prodsrv_rec.segment17,
                p_vendor_prodsrv_rec.segment17 || l_delimiter,
                p_vendor_prodsrv_rec.segment17) ||
           nvl2(p_vendor_prodsrv_rec.segment18,
                p_vendor_prodsrv_rec.segment18 || l_delimiter,
                p_vendor_prodsrv_rec.segment18) ||
           nvl2(p_vendor_prodsrv_rec.segment19,
                p_vendor_prodsrv_rec.segment19 || l_delimiter,
                p_vendor_prodsrv_rec.segment19) ||
           nvl2(p_vendor_prodsrv_rec.segment20,
                p_vendor_prodsrv_rec.segment20 || l_delimiter,
                p_vendor_prodsrv_rec.segment20)
    INTO   l_segment_concat
    FROM   dual;

    l_segment_count := (length(l_segment_concat) -
                       length(REPLACE(l_segment_concat, l_delimiter, '')));

    IF (l_segment_count <> l_product_segment_count) THEN
      x_prod_valid    := 'N';
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := 'POS_INVALID_SEGMENT_COUNT';
      IF (insert_rejections(p_batch_id,
                            l_request_id,
                            'POS_PRODUCT_SERVICE_INT',
                            p_vendor_prodsrv_rec.ps_interface_id,
                            'POS_INVALID_SEGMENT_COUNT',
                            g_user_id,
                            g_login_id,
                            'validate_vendor_prods_services') <> TRUE) THEN

        IF (g_level_procedure >= g_current_runtime_level) THEN
          fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                    p_data  => l_msg_data);
          fnd_log.string(g_level_procedure,
                         g_module_name || l_api_name,
                         'Parameters: ' || ' PS_INTERFACE_ID: ' ||
                         p_vendor_prodsrv_rec.ps_interface_id ||
                         ' Acct Validation Msg: ' || l_msg_data);
        END IF;
      END IF;
      fnd_file.put_line(fnd_file.log,
                        ' Invalid Segment count for: ' ||
                        ' ps_interface_id: ' ||
                        p_vendor_prodsrv_rec.ps_interface_id ||
                        ', segment_concat: ' || l_segment_concat);
      RETURN;
    END IF;

    -- If the above is true then concatenate the segments using the delimiter
    l_sql := 'SELECT ' || l_segment_code || '
           FROM POS_PRODUCT_SERVICE_INT
           WHERE PS_INTERFACE_ID = ' ||
             p_vendor_prodsrv_rec.ps_interface_id;

    OPEN l_pscur FOR l_sql;
    FETCH l_pscur
      INTO l_concatenated_segments;
    CLOSE l_pscur;

    --bug 18328966
    L_CAT_QUERY := L_CAT_SELECT_CLAUSE || ' ' || L_CAT_FROM_CLAUSE || ' '  || L_CAT_WHERE_CLAUSE;

    OPEN L_CAT_CURSOR FOR L_CAT_QUERY;
    FETCH L_CAT_CURSOR
      INTO L_CATEGORY_ID;
    CLOSE L_CAT_CURSOR;
    --end bug 18328966

	/*
     * bug 18328966
     *
    BEGIN
      SELECT nvl(category_id, 0)
      INTO   l_category_id
      FROM   mtl_categories_kfv
      WHERE  category_id IN
             (SELECT DISTINCT category_id
              FROM   mtl_category_set_valid_cats
              WHERE  category_set_id = l_default_po_category_set_id)
      AND    concatenated_segments = l_concatenated_segments;

    EXCEPTION
      WHEN no_data_found THEN
        x_prod_valid    := 'N';
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_data      := 'POS_INVALID_CATEGORY_ID';
        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_PRODUCT_SERVICE_INT',
                              p_vendor_prodsrv_rec.ps_interface_id,
                              'POS_INVALID_CATEGORY_ID',
                              g_user_id,
                              g_login_id,
                              'validate_vendor_prods_services') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' PS_INTERFACE_ID: ' ||
                           p_vendor_prodsrv_rec.ps_interface_id ||
                           ' Acct Validation Msg: ' || l_msg_data);
          END IF;
        END IF;
        fnd_file.put_line(fnd_file.log,
                          ' Invalid category id for: ' ||
                          ' ps_interface_id: ' ||
                          p_vendor_prodsrv_rec.ps_interface_id ||
                          ', concatenated_segments: ' ||
                          l_concatenated_segments);
        RETURN;
    END;
    */

    IF (l_category_id = 0) THEN
      x_prod_valid    := 'N';
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := 'POS_INVALID_CATEGORY_ID';
      IF (insert_rejections(p_batch_id,
                            l_request_id,
                            'POS_PRODUCT_SERVICE_INT',
                            p_vendor_prodsrv_rec.ps_interface_id,
                            'POS_INVALID_CATEGORY_ID',
                            g_user_id,
                            g_login_id,
                            'validate_vendor_prods_services') <> TRUE) THEN

        IF (g_level_procedure >= g_current_runtime_level) THEN
          fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                    p_data  => l_msg_data);
          fnd_log.string(g_level_procedure,
                         g_module_name || l_api_name,
                         'Parameters: ' || ' PS_INTERFACE_ID: ' ||
                         p_vendor_prodsrv_rec.ps_interface_id ||
                         ' Acct Validation Msg: ' || l_msg_data);
        END IF;
      END IF;
      fnd_file.put_line(fnd_file.log,
                        ' Invalid category id for: ' ||
                        ' ps_interface_id: ' ||
                        p_vendor_prodsrv_rec.ps_interface_id ||
                        ', category_id: ' || l_category_id);
      RETURN;
    ELSE
      -- x_prod_valid   := 'Y';
      x_segment_code := l_concatenated_segments;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_prod_valid    := 'N';
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside validate_vendor_prods_services EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END VALIDATE_VENDOR_PRODS_SERVICES;

  PROCEDURE create_vendor_prods_services
  (
    p_batch_id           IN NUMBER,
    p_vendor_prodsrv_rec IN pos_product_service_int%ROWTYPE,
    p_party_id           IN hz_parties.party_id%TYPE,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
  ) IS
    l_return_status VARCHAR2(100);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(100);
    l_prod_valid    VARCHAR2(1);

    l_mapping_id    NUMBER;
    l_segment_code  VARCHAR2(4000) := NULL;
    l_req_id        NUMBER;
    l_status        VARCHAR(2000);
    l_error_message VARCHAR(4000);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE CREATE_VENDOR_PRODS_SERVICES' ||
                      ' Parameters: ' || ' batch_id: ' || p_batch_id ||
                      ' party_id: ' || p_party_id);

    -- Call Validate_Vendor_Prods_Services to validate the Products and Services data
    validate_vendor_prods_services(p_batch_id           => p_batch_id,
                                   p_vendor_prodsrv_rec => p_vendor_prodsrv_rec,
                                   p_party_id           => p_party_id,
                                   x_return_status      => l_return_status,
                                   x_msg_count          => l_msg_count,
                                   x_msg_data           => l_msg_data,
                                   x_prod_valid         => l_prod_valid,
                                   x_segment_code       => l_segment_code);

    IF (l_prod_valid = 'Y') THEN
      -- Insert the data into the pos_product_service_requests table using the follwing API
      pos_product_service_utl_pkg.add_new_ps_req(p_vendor_id          => p_vendor_prodsrv_rec.vendor_id,
                                                 p_segment1           => p_vendor_prodsrv_rec.segment1,
                                                 p_segment2           => p_vendor_prodsrv_rec.segment2,
                                                 p_segment3           => p_vendor_prodsrv_rec.segment3,
                                                 p_segment4           => p_vendor_prodsrv_rec.segment4,
                                                 p_segment5           => p_vendor_prodsrv_rec.segment5,
                                                 p_segment6           => p_vendor_prodsrv_rec.segment6,
                                                 p_segment7           => p_vendor_prodsrv_rec.segment7,
                                                 p_segment8           => p_vendor_prodsrv_rec.segment8,
                                                 p_segment9           => p_vendor_prodsrv_rec.segment9,
                                                 p_segment10          => p_vendor_prodsrv_rec.segment10,
                                                 p_segment11          => p_vendor_prodsrv_rec.segment11,
                                                 p_segment12          => p_vendor_prodsrv_rec.segment12,
                                                 p_segment13          => p_vendor_prodsrv_rec.segment13,
                                                 p_segment14          => p_vendor_prodsrv_rec.segment14,
                                                 p_segment15          => p_vendor_prodsrv_rec.segment15,
                                                 p_segment16          => p_vendor_prodsrv_rec.segment16,
                                                 p_segment17          => p_vendor_prodsrv_rec.segment17,
                                                 p_segment18          => p_vendor_prodsrv_rec.segment18,
                                                 p_segment19          => p_vendor_prodsrv_rec.segment19,
                                                 p_segment20          => p_vendor_prodsrv_rec.segment20,
                                                 p_segment_definition => p_vendor_prodsrv_rec.segment_definition,
                                                 x_return_status      => l_return_status,
                                                 x_msg_count          => l_msg_count,
                                                 x_msg_data           => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        x_return_status := l_return_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
        RETURN;
      ELSE
        -- If the request_status is "APPROVED" then do the following
        IF (p_vendor_prodsrv_rec.request_status = 'APPROVED') THEN

          -- Get the mapping_id using the following SQLL
          SELECT mapping_id
          INTO   l_mapping_id
          FROM   pos_supplier_mappings
          WHERE  vendor_id = p_vendor_prodsrv_rec.vendor_id
          AND    party_id = p_party_id;

          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE CREATE_VENDOR_PRODS_SERVICES' ||
                            ' request_status: ' ||
                            p_vendor_prodsrv_rec.request_status ||
                            ' mapping_id: ' || l_mapping_id ||
                            ' segment_code: ' || l_segment_code);

          pos_product_service_utl_pkg.initialize(x_status        => l_status,
                                                 x_error_message => l_error_message);

          -- Using the mapping_id make a call to the following API
          l_req_id := pos_product_service_utl_pkg.get_requestid(x_segment_code => l_segment_code,
                                                                x_mapp_id      => l_mapping_id);

          -- Using the request_id make a call to the following  Api to approve the data and insert it into the
          -- pos_sup_products_services table
          pos_profile_change_request_pkg.approve_ps_req(p_request_id    => l_req_id,
                                                        x_return_status => l_return_status,
                                                        x_msg_count     => l_msg_count,
                                                        x_msg_data      => l_msg_data);

          x_return_status := l_return_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;

        END IF;
      END IF;
    ELSE
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      RETURN;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside create_vendor_prods_services EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside create_vendor_prods_services unexpected EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside create_vendor_prods_services others EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END create_vendor_prods_services;

  PROCEDURE import_vendor_prods_services
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'IMPORT_VENDOR_PRODS_SERVICES';
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_return_status VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);

    l_party_id NUMBER;

    CURSOR vendor_int_prod_srv_cur IS
      SELECT *
      FROM   pos_product_service_int supp
      WHERE  import_request_id = l_request_id
      AND    ps_interface_id IS NOT NULL
      AND    sdh_batch_id = p_batch_id
      AND    nvl(status, 'ACTIVE') NOT IN ('PROCESSED', 'REMOVED')
      AND    NOT EXISTS
       (SELECT 1
              FROM   hz_imp_parties_int party
              WHERE  batch_id = p_batch_id
              AND    supp.sdh_batch_id = party.batch_id
              AND    supp.source_system = party.party_orig_system
              AND    supp.source_system_reference =
                     party.party_orig_system_reference
              AND    party.interface_status = 'R');

    vendor_int_prod_srv_rec vendor_int_prod_srv_cur%ROWTYPE;
    vendor_prod_srv_rec     pos_product_service_int%ROWTYPE;

    l_product_segment_definition VARCHAR2(2000);
    l_product_segment_count      NUMBER;
    l_default_po_category_set_id NUMBER;
    l_delimiter                  VARCHAR2(10);
    l_status                     VARCHAR(2000);
    l_error_message              VARCHAR(4000);
    l_segment_concat             VARCHAR2(4000) := NULL;

    l_mapping_id NUMBER;
    l_req_id     NUMBER := 0;
    l_class_id   NUMBER := 0;

    l_ret_status VARCHAR2(100);
    l_req_id_tab po_tbl_number := po_tbl_number();

  BEGIN
    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_PRODS_SERVICES' ||
                      ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                      ' request_id: ' || l_request_id);

    -- This update statement resets the unprocessed rows so
    -- that they get picked in the current run.
    UPDATE pos_product_service_int api
    SET    import_request_id = NULL
    WHERE  import_request_id IS NOT NULL
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') IN ('ACTIVE', 'REJECTED')
    AND    EXISTS (SELECT 'Request Completed'
            FROM   fnd_concurrent_requests fcr
            WHERE  fcr.request_id = api.import_request_id
            AND    fcr.phase_code = 'C');

    -- Updating Interface Record with request id

    UPDATE pos_product_service_int
    SET    import_request_id = l_request_id
    WHERE  import_request_id IS NULL
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED';

    UPDATE pos_product_service_int supp
    SET    status            = 'REMOVED',
           import_request_id = l_request_id
    WHERE  sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED'
    AND    EXISTS (SELECT 1
            FROM   hz_imp_parties_int party
            WHERE  batch_id = p_batch_id
            AND    supp.sdh_batch_id = party.batch_id
            AND    supp.source_system = party.party_orig_system
            AND    supp.source_system_reference =
                   party.party_orig_system_reference
            AND    party.interface_status = 'R');

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_PRODS_SERVICES' ||
                      ' Not imported(marked REMOVED) : ' || SQL%ROWCOUNT ||
                      ' records. Reason interface_status in hz_imp_parties_int = R');

    INSERT INTO pos_supplier_int_rejections
      (SELECT p_batch_id,
              l_request_id,
              'POS_PRODUCT_SERVICE_INT',
              ps_interface_id,
              'POS_INVALID_PARTY_ORIG_SYSTEM',
              g_user_id,
              SYSDATE,
              g_login_id,
              g_user_id,
              SYSDATE
       FROM   pos_product_service_int
       WHERE  status = 'REMOVED'
       AND    import_request_id = l_request_id
       AND    sdh_batch_id = p_batch_id);

    -- Cursor processing for vendor business clasiification record
    OPEN vendor_int_prod_srv_cur;
    LOOP

      FETCH vendor_int_prod_srv_cur
        INTO vendor_int_prod_srv_rec;
      EXIT WHEN vendor_int_prod_srv_cur%NOTFOUND;

      vendor_prod_srv_rec.sdh_batch_id            := vendor_int_prod_srv_rec.sdh_batch_id;
      vendor_prod_srv_rec.source_system           := vendor_int_prod_srv_rec.source_system;
      vendor_prod_srv_rec.source_system_reference := vendor_int_prod_srv_rec.source_system_reference;
      vendor_prod_srv_rec.vendor_interface_id     := vendor_int_prod_srv_rec.vendor_interface_id;
      vendor_prod_srv_rec.ps_interface_id         := vendor_int_prod_srv_rec.ps_interface_id;

      --vendor_prod_srv_rec.request_id := vendor_int_prod_srv_rec.request_id;

      --vendor_prod_srv_rec.ps_request_id      := vendor_int_prod_srv_rec.ps_request_id;
      vendor_prod_srv_rec.mapping_id         := vendor_int_prod_srv_rec.mapping_id;
      vendor_prod_srv_rec.request_status     := vendor_int_prod_srv_rec.request_status;
      vendor_prod_srv_rec.request_type       := vendor_int_prod_srv_rec.request_type;
      vendor_prod_srv_rec.segment1           := vendor_int_prod_srv_rec.segment1;
      vendor_prod_srv_rec.segment2           := vendor_int_prod_srv_rec.segment2;
      vendor_prod_srv_rec.segment3           := vendor_int_prod_srv_rec.segment3;
      vendor_prod_srv_rec.segment4           := vendor_int_prod_srv_rec.segment4;
      vendor_prod_srv_rec.segment5           := vendor_int_prod_srv_rec.segment5;
      vendor_prod_srv_rec.segment6           := vendor_int_prod_srv_rec.segment6;
      vendor_prod_srv_rec.segment7           := vendor_int_prod_srv_rec.segment7;
      vendor_prod_srv_rec.segment8           := vendor_int_prod_srv_rec.segment8;
      vendor_prod_srv_rec.segment9           := vendor_int_prod_srv_rec.segment9;
      vendor_prod_srv_rec.segment10          := vendor_int_prod_srv_rec.segment10;
      vendor_prod_srv_rec.segment11          := vendor_int_prod_srv_rec.segment11;
      vendor_prod_srv_rec.segment12          := vendor_int_prod_srv_rec.segment12;
      vendor_prod_srv_rec.segment13          := vendor_int_prod_srv_rec.segment13;
      vendor_prod_srv_rec.segment14          := vendor_int_prod_srv_rec.segment14;
      vendor_prod_srv_rec.segment15          := vendor_int_prod_srv_rec.segment15;
      vendor_prod_srv_rec.segment16          := vendor_int_prod_srv_rec.segment16;
      vendor_prod_srv_rec.segment17          := vendor_int_prod_srv_rec.segment17;
      vendor_prod_srv_rec.segment18          := vendor_int_prod_srv_rec.segment18;
      vendor_prod_srv_rec.segment19          := vendor_int_prod_srv_rec.segment19;
      vendor_prod_srv_rec.segment20          := vendor_int_prod_srv_rec.segment20;
      vendor_prod_srv_rec.segment_definition := vendor_int_prod_srv_rec.segment_definition;

      /* Get the party id for orig system and
      orig system reference combination */
      IF (vendor_int_prod_srv_rec.party_id IS NULL) THEN
        l_party_id := get_party_id(vendor_int_prod_srv_rec.source_system,
                                   vendor_int_prod_srv_rec.source_system_reference);
      ELSE
        l_party_id := vendor_int_prod_srv_rec.party_id;
      END IF;

      IF (vendor_int_prod_srv_rec.vendor_id IS NULL) THEN
        BEGIN
          SELECT vendor_id
          INTO   vendor_prod_srv_rec.vendor_id
          FROM   ap_suppliers supp
          WHERE  supp.party_id = l_party_id;

        EXCEPTION
          WHEN OTHERS THEN
            UPDATE pos_product_service_int
            SET    status = 'REJECTED'
            WHERE  ps_interface_id =
                   vendor_int_prod_srv_rec.ps_interface_id
            AND    sdh_batch_id = p_batch_id;

            IF (insert_rejections(p_batch_id,
                                  l_request_id,
                                  'POS_PRODUCT_SERVICE_INT',
                                  vendor_int_prod_srv_rec.ps_interface_id,
                                  'AP_VENDOR_ID_NULL',
                                  g_user_id,
                                  g_login_id,
                                  'import_vendor_prods_services') <> TRUE) THEN

              IF (g_level_procedure >= g_current_runtime_level) THEN
                fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                          p_data  => l_msg_data);
                fnd_log.string(g_level_procedure,
                               g_module_name || l_api_name,
                               'Parameters: ' || ' PS_INTERFACE_ID: ' ||
                               vendor_int_prod_srv_rec.ps_interface_id ||
                               ' Product and Services Validation Msg: ' ||
                               l_msg_data);
              END IF;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_file.put_line(fnd_file.log,
                              ' Vendor ID is null for: ' ||
                              ' PS_INTERFACE_ID: ' ||
                              vendor_int_prod_srv_rec.ps_interface_id);
            GOTO continue_next_record;
        END;
      ELSE
        vendor_prod_srv_rec.vendor_id := vendor_int_prod_srv_rec.vendor_id;
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE IMPORT_VENDOR_PRODS_SERVICES' ||
                        ' ps_interface_id: ' ||
                        vendor_prod_srv_rec.ps_interface_id ||
                        ' party_id: ' || l_party_id || ' vendor_id: ' ||
                        vendor_prod_srv_rec.vendor_id);

      BEGIN
        SELECT mapping_id
        INTO   l_mapping_id
        FROM   pos_supplier_mappings
        WHERE  vendor_id = vendor_prod_srv_rec.vendor_id
        AND    party_id = l_party_id;

      --Bug 13399285 - ora-00923 error, need to replace the '.' to global flexfield setup l_delimiter
        fnd_file.put_line(fnd_file.log, 'l_mapping_id: ' || l_mapping_id);
      --Bug 13704624 - update status for products and services not working, need to get l_delimiter value first
        pos_product_service_utl_pkg.initialize(x_status        => l_status,
                                               x_error_message => l_error_message);

        pos_product_service_utl_pkg.get_product_meta_data(x_product_segment_definition => l_product_segment_definition,
                                                          x_product_segment_count      => l_product_segment_count,
                                                          x_default_po_category_set_id => l_default_po_category_set_id,
                                                          x_delimiter                  => l_delimiter);

        SELECT rtrim(nvl2(vendor_prod_srv_rec.segment1,
                          vendor_prod_srv_rec.segment1 || l_delimiter,
                          vendor_prod_srv_rec.segment1) ||
                     nvl2(vendor_prod_srv_rec.segment2,
                          vendor_prod_srv_rec.segment2 || l_delimiter,
                          vendor_prod_srv_rec.segment2) ||
                     nvl2(vendor_prod_srv_rec.segment3,
                          vendor_prod_srv_rec.segment3 || l_delimiter,
                          vendor_prod_srv_rec.segment3) ||
                     nvl2(vendor_prod_srv_rec.segment4,
                          vendor_prod_srv_rec.segment4 || l_delimiter,
                          vendor_prod_srv_rec.segment4) ||
                     nvl2(vendor_prod_srv_rec.segment5,
                          vendor_prod_srv_rec.segment5 || l_delimiter,
                          vendor_prod_srv_rec.segment5) ||
                     nvl2(vendor_prod_srv_rec.segment6,
                          vendor_prod_srv_rec.segment6 || l_delimiter,
                          vendor_prod_srv_rec.segment6) ||
                     nvl2(vendor_prod_srv_rec.segment7,
                          vendor_prod_srv_rec.segment7 || l_delimiter,
                          vendor_prod_srv_rec.segment7) ||
                     nvl2(vendor_prod_srv_rec.segment8,
                          vendor_prod_srv_rec.segment8 || l_delimiter,
                          vendor_prod_srv_rec.segment8) ||
                     nvl2(vendor_prod_srv_rec.segment9,
                          vendor_prod_srv_rec.segment9 || l_delimiter,
                          vendor_prod_srv_rec.segment9) ||
                     nvl2(vendor_prod_srv_rec.segment10,
                          vendor_prod_srv_rec.segment10 || l_delimiter,
                          vendor_prod_srv_rec.segment10) ||
                     nvl2(vendor_prod_srv_rec.segment11,
                          vendor_prod_srv_rec.segment11 || l_delimiter,
                          vendor_prod_srv_rec.segment11) ||
                     nvl2(vendor_prod_srv_rec.segment12,
                          vendor_prod_srv_rec.segment12 || l_delimiter,
                          vendor_prod_srv_rec.segment12) ||
                     nvl2(vendor_prod_srv_rec.segment13,
                          vendor_prod_srv_rec.segment13 || l_delimiter,
                          vendor_prod_srv_rec.segment13) ||
                     nvl2(vendor_prod_srv_rec.segment14,
                          vendor_prod_srv_rec.segment14 || l_delimiter,
                          vendor_prod_srv_rec.segment14) ||
                     nvl2(vendor_prod_srv_rec.segment15,
                          vendor_prod_srv_rec.segment15 || l_delimiter,
                          vendor_prod_srv_rec.segment15) ||
                     nvl2(vendor_prod_srv_rec.segment16,
                          vendor_prod_srv_rec.segment16 || l_delimiter,
                          vendor_prod_srv_rec.segment16) ||
                     nvl2(vendor_prod_srv_rec.segment17,
                          vendor_prod_srv_rec.segment17 || l_delimiter,
                          vendor_prod_srv_rec.segment17) ||
                     nvl2(vendor_prod_srv_rec.segment18,
                          vendor_prod_srv_rec.segment18 || l_delimiter,
                          vendor_prod_srv_rec.segment18) ||
                     nvl2(vendor_prod_srv_rec.segment19,
                          vendor_prod_srv_rec.segment19 || l_delimiter,
                          vendor_prod_srv_rec.segment19) ||
                     nvl2(vendor_prod_srv_rec.segment20,
                          vendor_prod_srv_rec.segment20 || l_delimiter,
                          vendor_prod_srv_rec.segment20),
                     l_delimiter)
        INTO   l_segment_concat
        FROM   dual;

        fnd_file.put_line(fnd_file.log,
                          'l_segment_concat: ' || l_segment_concat);
        fnd_file.put_line(fnd_file.log,
                        'l_delimiter: ' || l_delimiter);

        l_req_id := pos_product_service_utl_pkg.get_requestid(x_segment_code => l_segment_concat,
                                                              x_mapp_id      => l_mapping_id);
        fnd_file.put_line(fnd_file.log,
                        'l_req_id: ' || l_req_id);

      EXCEPTION
        WHEN OTHERS THEN
          l_req_id := 0;
      END;

      BEGIN
        l_class_id := pos_product_service_utl_pkg.get_classid(x_segment_code => l_segment_concat,
                                                              x_vendor_id    => vendor_prod_srv_rec.vendor_id);
        fnd_file.put_line(fnd_file.log,
                        'l_class_id: ' || l_class_id);
      EXCEPTION
        WHEN OTHERS THEN
          l_class_id := 0;
      END;

      IF (l_class_id = 0 AND l_req_id = 0) THEN
        vendor_int_prod_srv_rec.insert_update_flag := nvl(vendor_int_prod_srv_rec.insert_update_flag,
                                                          'I');
      ELSE
        vendor_int_prod_srv_rec.insert_update_flag := nvl(vendor_int_prod_srv_rec.insert_update_flag,
                                                          'U');
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE IMPORT_VENDOR_PRODS_SERVICES' ||
                        ' ps_interface_id: ' ||
                        vendor_prod_srv_rec.ps_interface_id ||
                        ' classification_id: ' || l_class_id ||
                        ' mapping_id: ' || l_mapping_id || ' req_id: ' ||
                        l_req_id ||
                        ' vendor_int_prod_srv_rec.insert_update_flag: ' ||
                        vendor_int_prod_srv_rec.insert_update_flag);

      IF (vendor_int_prod_srv_rec.insert_update_flag = 'I') THEN
        create_vendor_prods_services(p_batch_id           => p_batch_id,
                                     p_vendor_prodsrv_rec => vendor_prod_srv_rec,
                                     p_party_id           => l_party_id,
                                     x_return_status      => l_return_status,
                                     x_msg_count          => l_msg_count,
                                     x_msg_data           => l_msg_data);

        IF l_return_status = fnd_api.g_ret_sts_success THEN
          UPDATE pos_product_service_int
          SET    status = 'PROCESSED'
          WHERE  ps_interface_id = vendor_int_prod_srv_rec.ps_interface_id
          AND    sdh_batch_id = p_batch_id;

          UPDATE pos_imp_batch_summary
          SET    total_records_imported = total_records_imported + 1,
                 total_inserts          = total_inserts + 1,
                 prod_serv_inserted     = prod_serv_inserted + 1,
                 prod_serv_imported     = prod_serv_imported + 1
          WHERE  batch_id = vendor_int_prod_srv_rec.sdh_batch_id;
        ELSE
          UPDATE pos_product_service_int
          SET    status = 'REJECTED'
          WHERE  ps_interface_id = vendor_int_prod_srv_rec.ps_interface_id
          AND    sdh_batch_id = p_batch_id;

          x_return_status := l_return_status;

          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_PRODUCT_SERVICE_INT',
                                vendor_int_prod_srv_rec.ps_interface_id,
                                'POS_PROD_SERVICES_CREATION',
                                g_user_id,
                                g_login_id,
                                'import_vendor_prods_services') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Parameters: ' || ' PS_INTERFACE_ID: ' ||
                             vendor_int_prod_srv_rec.ps_interface_id ||
                             ' Product and Services Validation Msg: ' ||
                             l_msg_data);
            END IF;
          END IF;

        END IF;
      ELSE
      --Bug 14233640 - pos_product_service_int import flow change(if l_req_id is 0, POS_PRODUCT_SERVICE_REQUESTS no record)
        IF (vendor_int_prod_srv_rec.request_status = 'REJECTED') THEN
          IF (l_req_id <> 0) THEN
            pos_profile_change_request_pkg.reject_ps_req(p_request_id    => l_req_id,
                                                         x_return_status => l_ret_status,
                                                         x_msg_count     => l_msg_count,
                                                         x_msg_data      => l_msg_data);
		 IF (l_class_id <>0) THEN
            l_req_id_tab.extend;
            l_req_id_tab(1) := l_class_id;
            pos_product_service_utl_pkg.update_main_ps_req(p_req_id_tbl    => l_req_id_tab,
                                                           p_status        => 'R',
                                                           x_return_status => l_ret_status,
                                                           x_msg_count     => l_msg_count,
                                                           x_msg_data      => l_msg_data);
		 END IF;
	    ELSE
	         IF (l_class_id <>0) THEN
            l_req_id_tab.extend;
            l_req_id_tab(1) := l_class_id;
            pos_product_service_utl_pkg.update_main_ps_req(p_req_id_tbl    => l_req_id_tab,
                                                           p_status        => 'R',
                                                           x_return_status => l_ret_status,
                                                           x_msg_count     => l_msg_count,
                                                           x_msg_data      => l_msg_data);
		 END IF;

	  END IF;
        ELSIF (vendor_int_prod_srv_rec.request_status) = 'APPROVED' THEN
          IF (l_req_id <> 0) THEN
            pos_profile_change_request_pkg.approve_ps_req(p_request_id    => l_req_id,
                                                          x_return_status => l_ret_status,
                                                          x_msg_count     => l_msg_count,
                                                          x_msg_data      => l_msg_data);
		IF (l_class_id <>0) THEN
            l_req_id_tab.extend;
            l_req_id_tab(1) := l_class_id;
            pos_product_service_utl_pkg.update_main_ps_req(p_req_id_tbl    => l_req_id_tab,
                                                           p_status        => 'A',
                                                           x_return_status => l_ret_status,
                                                           x_msg_count     => l_msg_count,
                                                           x_msg_data      => l_msg_data);
		END IF;
             ELSE
                 IF (l_class_id <>0) THEN
            l_req_id_tab.extend;
            l_req_id_tab(1) := l_class_id;
            pos_product_service_utl_pkg.update_main_ps_req(p_req_id_tbl    => l_req_id_tab,
                                                           p_status        => 'A',
                                                           x_return_status => l_ret_status,
                                                           x_msg_count     => l_msg_count,
                                                           x_msg_data      => l_msg_data);
		END IF;

	  END IF;
        ELSIF (vendor_int_prod_srv_rec.request_status) = 'REMOVED' THEN
	      fnd_file.put_line(fnd_file.log,
                        'l_req_id for removed: ' || l_req_id);
              fnd_file.put_line(fnd_file.log,
                        'l_class_id for removed: ' || l_class_id);
          IF (l_req_id <> 0) THEN
		l_req_id_tab.extend;
	        l_req_id_tab(1) := l_req_id;

		pos_product_service_utl_pkg.remove_mult_ps_reqs(p_req_id_tbl    => l_req_id_tab,
                                                            x_return_status => l_ret_status,
                                                            x_msg_count     => l_msg_count,
                                                            x_msg_data      => l_msg_data);
			IF (l_class_id <>0) THEN
		            l_req_id_tab.extend;
		            l_req_id_tab(1) := l_class_id;
		            pos_product_service_utl_pkg.update_main_ps_req(p_req_id_tbl    => l_req_id_tab,
                                                           p_status        => 'X',
                                                           x_return_status => l_ret_status,
                                                           x_msg_count     => l_msg_count,
                                                           x_msg_data      => l_msg_data);
		       END IF;
		ELSE
		      fnd_file.put_line(fnd_file.log,'l_req_id for removed(l_req_id =0 flow): ' || l_req_id);
	              fnd_file.put_line(fnd_file.log,   'l_class_id for removed(l_req_id =0 flow): ' || l_class_id);
			IF (l_class_id <>0) THEN
		            l_req_id_tab.extend;
		            l_req_id_tab(1) := l_class_id;
		            pos_product_service_utl_pkg.update_main_ps_req(p_req_id_tbl    => l_req_id_tab,
                                                           p_status        => 'X',
                                                           x_return_status => l_ret_status,
                                                           x_msg_count     => l_msg_count,
                                                           x_msg_data      => l_msg_data);
		       END IF;
	  END IF;
        END IF;
        IF l_ret_status = fnd_api.g_ret_sts_success THEN
          UPDATE pos_product_service_int
          SET    status = 'PROCESSED'
          WHERE  ps_interface_id = vendor_int_prod_srv_rec.ps_interface_id
          AND    sdh_batch_id = p_batch_id;

          UPDATE pos_imp_batch_summary
          SET    total_records_imported = total_records_imported + 1,
                 total_updates          = total_updates + 1,
                 prod_serv_updated      = prod_serv_updated + 1,
                 prod_serv_imported     = prod_serv_imported + 1
          WHERE  batch_id = vendor_int_prod_srv_rec.sdh_batch_id;
        ELSE
          UPDATE pos_product_service_int
          SET    status = 'REJECTED'
          WHERE  ps_interface_id = vendor_int_prod_srv_rec.ps_interface_id
          AND    sdh_batch_id = p_batch_id;

          x_return_status := l_ret_status;

          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_PRODUCT_SERVICE_INT',
                                vendor_int_prod_srv_rec.ps_interface_id,
                                'POS_PROD_SERVICES_UPDATION',
                                g_user_id,
                                g_login_id,
                                'import_vendor_prods_services') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Parameters: ' || ' PS_INTERFACE_ID: ' ||
                             vendor_int_prod_srv_rec.ps_interface_id ||
                             ' Product and Services Validation Msg: ' ||
                             l_msg_data);
            END IF;
          END IF;

        END IF;
      END IF;
      <<continue_next_record>>
      NULL;
    END LOOP;

    CLOSE vendor_int_prod_srv_cur;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_prods_services EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_prods_services unexpected EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_prods_services others EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END import_vendor_prods_services;

  PROCEDURE validate_vendor_buss_class
  (
    p_batch_id              IN NUMBER,
    p_vendor_buss_class_rec IN pos_business_class_int%ROWTYPE,
    p_party_id              IN hz_parties.party_id%TYPE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_buss_valid            OUT NOCOPY VARCHAR2
  ) IS
    l_dummy_lookup VARCHAR2(30);

    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_api_name CONSTANT VARCHAR2(30) := 'VALIDATE_VENDOR_BUSS_CLASS';
    l_request_id NUMBER := fnd_global.conc_request_id;
  BEGIN
    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    x_buss_valid := 'Y';

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE VALIDATE_VENDOR_BUSS_CLASS' ||
                      ' Parameters: ' || ' batch_id: ' || p_batch_id ||
                      ' party_id: ' || p_party_id || ' lookup_type: ' ||
                      p_vendor_buss_class_rec.lookup_type ||
                      ' lookup_code: ' ||
                      p_vendor_buss_class_rec.lookup_code ||
                      ' ext_attr_1: ' || p_vendor_buss_class_rec.ext_attr_1);

    -- Validate the classifcation using the following query
    BEGIN
      SELECT lookup_code
      INTO   l_dummy_lookup
      FROM   fnd_lookup_values
      WHERE  lookup_type = p_vendor_buss_class_rec.lookup_type
      AND    lookup_code = p_vendor_buss_class_rec.lookup_code
      AND    enabled_flag = 'Y'
      AND    nvl(end_date_active, SYSDATE + 1) > SYSDATE
      AND    LANGUAGE = 'US';

    EXCEPTION
      WHEN OTHERS THEN
        x_buss_valid    := 'N';
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_data      := 'POS_INVALID_LOOKUP_CODE';
        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_BUSINESS_CLASS_INT',
                              p_vendor_buss_class_rec.business_class_interface_id,
                              'POS_INVALID_LOOKUP_CODE',
                              g_user_id,
                              g_login_id,
                              'Validate_Vendor_Buss_Class') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' ||
                           ' business_class_interface_id: ' ||
                           p_vendor_buss_class_rec.business_class_interface_id ||
                           ' Acct Validation Msg: ' || l_msg_data);
          END IF;
        END IF;
        fnd_file.put_line(fnd_file.log,
                          ' Invalid Lookup Code for: ' ||
                          ' business_class_interface_id: ' ||
                          p_vendor_buss_class_rec.business_class_interface_id ||
                          ' lookup_code: ' ||
                          p_vendor_buss_class_rec.lookup_code);
        RETURN;
    END;

    -- if the lookup_code is "MINORITY_OWNED" validate the minority_type using the following query
    IF (p_vendor_buss_class_rec.lookup_code = 'MINORITY_OWNED') THEN
      BEGIN
        SELECT lookup_code
        INTO   l_dummy_lookup
        FROM   fnd_lookup_values_vl
        WHERE  lookup_type = 'MINORITY GROUP'
        AND    lookup_code = p_vendor_buss_class_rec.ext_attr_1
        AND    enabled_flag = 'Y'
        AND    nvl(end_date_active, SYSDATE + 1) > SYSDATE;

      EXCEPTION
        WHEN OTHERS THEN
          x_buss_valid    := 'N';
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data      := 'POS_INVALID_MINOR_LOOKUP_CODE';
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_BUSINESS_CLASS_INT',
                                p_vendor_buss_class_rec.business_class_interface_id,
                                'POS_INVALID_MINOR_LOOKUP_CODE',
                                g_user_id,
                                g_login_id,
                                'Validate_Vendor_Buss_Class') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Parameters: ' ||
                             ' BUSINESS_CLASS_INTERFACE_ID: ' ||
                             p_vendor_buss_class_rec.business_class_interface_id ||
                             ' Acct Validation Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Invalid Lookup Code for MINORITY_OWNED : ' ||
                            ' business_class_interface_id: ' ||
                            p_vendor_buss_class_rec.business_class_interface_id);
          RETURN;
      END;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_buss_valid    := 'N';
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside validate_vendor_buss_class EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END validate_vendor_buss_class;

  PROCEDURE create_vendor_buss_class
  (
    p_batch_id              IN NUMBER,
    p_vendor_buss_class_rec IN pos_business_class_int%ROWTYPE,
    p_party_id              IN hz_parties.party_id%TYPE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS
    l_return_status VARCHAR2(100);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(100);
    l_buss_valid    VARCHAR2(1);

    l_classification_id NUMBER;
    l_status            VARCHAR2(100);
    l_exception_msg     VARCHAR2(100);
  BEGIN
    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Call Validate_Vendor_Buss_Class to validate the Business Classification data
    BEGIN

      validate_vendor_buss_class(p_batch_id              => p_batch_id,
                                 p_vendor_buss_class_rec => p_vendor_buss_class_rec,
                                 p_party_id              => p_party_id,
                                 x_return_status         => l_return_status,
                                 x_msg_count             => l_msg_count,
                                 x_msg_data              => l_msg_data,
                                 x_buss_valid            => l_buss_valid);
    END;

    IF (l_buss_valid = 'Y') THEN
      --Insert the data using the follwing API
      BEGIN
        pos_supp_classification_pkg.add_bus_class_attr(p_party_id,
                                                       p_vendor_buss_class_rec.vendor_id,
                                                       p_vendor_buss_class_rec.lookup_code,
                                                       p_vendor_buss_class_rec.expiration_date,
                                                       p_vendor_buss_class_rec.certificate_number,
                                                       p_vendor_buss_class_rec.certifying_agency,
                                                       p_vendor_buss_class_rec.ext_attr_1,
                                                       p_vendor_buss_class_rec.class_status,
                                                       '',
                                                       l_classification_id,
                                                       l_status,
                                                       l_exception_msg);
      END;

      -- Call the API to syncronise data with TCA pasing party_id and vendor_id
      BEGIN
        fnd_file.put_line(fnd_file.log,
                          'API to syncronise data with TCA pasing party_id and vendor_id');
        pos_supp_classification_pkg.synchronize_class_tca_to_po(p_party_id,
                                                                p_vendor_buss_class_rec.vendor_id);
      END;
    ELSE
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      RETURN;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside create_vendor_buss_class EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside create_vendor_buss_class unexpected EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside create_vendor_buss_class others EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END create_vendor_buss_class;

  PROCEDURE import_vendor_buss_class
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'IMPORT_VENDOR_BUSS_CLASS';
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_return_status VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);

    l_party_id          NUMBER;
    l_classification_id NUMBER;
    l_mapping_id        NUMBER;
    l_buss_class_req_id NUMBER;

    l_out_classification_id NUMBER;
    l_out_buss_class_req_id NUMBER;

    CURSOR vendor_int_buss_class_cur IS
      SELECT *
      FROM   pos_business_class_int supp
      WHERE  import_request_id = l_request_id
      AND    business_class_interface_id IS NOT NULL
      AND    sdh_batch_id = p_batch_id
      AND    nvl(status, 'ACTIVE') NOT IN ('PROCESSED', 'REMOVED')
      AND    NOT EXISTS
       (SELECT 1
              FROM   hz_imp_parties_int party
              WHERE  batch_id = p_batch_id
              AND    supp.sdh_batch_id = party.batch_id
              AND    supp.source_system = party.party_orig_system
              AND    supp.source_system_reference =
                     party.party_orig_system_reference
              AND    party.interface_status = 'R');

    vendor_int_buss_class_rec vendor_int_buss_class_cur%ROWTYPE;
    vendor_buss_class_rec     pos_business_class_int%ROWTYPE;
  BEGIN
    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_BUSS_CLASS' ||
                      ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                      ' request_id: ' || l_request_id);

    -- This update statement resets the unprocessed rows so
    -- that they get picked in the current run.
    UPDATE pos_business_class_int api
    SET    import_request_id = NULL
    WHERE  import_request_id IS NOT NULL
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') IN ('ACTIVE', 'REJECTED')
    AND    EXISTS (SELECT 'Request Completed'
            FROM   fnd_concurrent_requests fcr
            WHERE  fcr.request_id = api.import_request_id
            AND    fcr.phase_code = 'C');

    -- Updating Interface Record with request id

    UPDATE pos_business_class_int
    SET    import_request_id = l_request_id
    WHERE  import_request_id IS NULL
    AND    sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED';

    UPDATE pos_business_class_int supp
    SET    status            = 'REMOVED',
           import_request_id = l_request_id
    WHERE  sdh_batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED'
    AND    EXISTS (SELECT 1
            FROM   hz_imp_parties_int party
            WHERE  batch_id = p_batch_id
            AND    supp.sdh_batch_id = party.batch_id
            AND    supp.source_system = party.party_orig_system
            AND    supp.source_system_reference =
                   party.party_orig_system_reference
            AND    party.interface_status = 'R');

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_BUSS_CLASS' ||
                      ' Not imported(marked REMOVED) : ' || SQL%ROWCOUNT ||
                      ' records. Reason interface_status in hz_imp_parties_int = R');

    INSERT INTO pos_supplier_int_rejections
      (SELECT p_batch_id,
              l_request_id,
              'POS_BUSINESS_CLASS_INT',
              business_class_interface_id,
              'POS_INVALID_PARTY_ORIG_SYSTEM',
              g_user_id,
              SYSDATE,
              g_login_id,
              g_user_id,
              SYSDATE
       FROM   pos_business_class_int
       WHERE  status = 'REMOVED'
       AND    import_request_id = l_request_id
       AND    sdh_batch_id = p_batch_id);

    -- Cursor processing for vendor business classification record
    OPEN vendor_int_buss_class_cur;
    LOOP

      FETCH vendor_int_buss_class_cur
        INTO vendor_int_buss_class_rec;
      EXIT WHEN vendor_int_buss_class_cur%NOTFOUND;

      vendor_buss_class_rec.sdh_batch_id                := vendor_int_buss_class_rec.sdh_batch_id;
      vendor_buss_class_rec.source_system               := vendor_int_buss_class_rec.source_system;
      vendor_buss_class_rec.source_system_reference     := vendor_int_buss_class_rec.source_system_reference;
      vendor_buss_class_rec.vendor_interface_id         := vendor_int_buss_class_rec.vendor_interface_id;
      vendor_buss_class_rec.business_class_interface_id := vendor_int_buss_class_rec.business_class_interface_id;
      --vendor_buss_class_rec.request_id                  := vendor_int_buss_class_rec.request_id;
      vendor_buss_class_rec.classification_id := vendor_int_buss_class_rec.classification_id;

      vendor_buss_class_rec.lookup_type        := vendor_int_buss_class_rec.lookup_type;
      vendor_buss_class_rec.lookup_code        := vendor_int_buss_class_rec.lookup_code;
      vendor_buss_class_rec.start_date_active  := vendor_int_buss_class_rec.start_date_active;
      vendor_buss_class_rec.end_date_active    := vendor_int_buss_class_rec.end_date_active;
      vendor_buss_class_rec.status             := vendor_int_buss_class_rec.status;
      vendor_buss_class_rec.ext_attr_1         := vendor_int_buss_class_rec.ext_attr_1;
      vendor_buss_class_rec.expiration_date    := vendor_int_buss_class_rec.expiration_date;
      vendor_buss_class_rec.certificate_number := vendor_int_buss_class_rec.certificate_number;
      vendor_buss_class_rec.certifying_agency  := vendor_int_buss_class_rec.certifying_agency;
      vendor_buss_class_rec.class_status       := vendor_int_buss_class_rec.class_status;
      vendor_buss_class_rec.attribute1         := vendor_int_buss_class_rec.attribute1;
      vendor_buss_class_rec.attribute2         := vendor_int_buss_class_rec.attribute2;
      vendor_buss_class_rec.attribute3         := vendor_int_buss_class_rec.attribute3;
      vendor_buss_class_rec.attribute4         := vendor_int_buss_class_rec.attribute4;
      vendor_buss_class_rec.attribute5         := vendor_int_buss_class_rec.attribute5;

      /* Get the party id for orig system and
      orig system reference combination */
      IF (vendor_int_buss_class_rec.party_id IS NULL) THEN
        l_party_id := get_party_id(vendor_int_buss_class_rec.source_system,
                                   vendor_int_buss_class_rec.source_system_reference);
      ELSE
        l_party_id := vendor_int_buss_class_rec.party_id;
      END IF;

      IF (vendor_int_buss_class_rec.vendor_id IS NULL) THEN
        BEGIN
          SELECT vendor_id
          INTO   vendor_buss_class_rec.vendor_id
          FROM   ap_suppliers supp
          WHERE  supp.party_id = l_party_id;

        EXCEPTION
          WHEN OTHERS THEN
            UPDATE pos_business_class_int
            SET    status = 'REJECTED'
            WHERE  business_class_interface_id =
                   vendor_int_buss_class_rec.business_class_interface_id
            AND    sdh_batch_id = p_batch_id;

            IF (insert_rejections(p_batch_id,
                                  l_request_id,
                                  'POS_BUSINESS_CLASS_INT',
                                  vendor_int_buss_class_rec.business_class_interface_id,
                                  'AP_VENDOR_ID_NULL',
                                  g_user_id,
                                  g_login_id,
                                  'import_vendor_buss_class') <> TRUE) THEN

              IF (g_level_procedure >= g_current_runtime_level) THEN
                fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                          p_data  => l_msg_data);
                fnd_log.string(g_level_procedure,
                               g_module_name || l_api_name,
                               'Parameters: ' ||
                               ' BUSINESS_CLASS_INTERFACE_ID: ' ||
                               vendor_int_buss_class_rec.business_class_interface_id ||
                               ' Buss and classification Validation Msg: ' ||
                               l_msg_data);
              END IF;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_file.put_line(fnd_file.log,
                              ' Vendor ID is null for: ' ||
                              ' BUSINESS_CLASS_INTERFACE_ID: ' ||
                              vendor_int_buss_class_rec.business_class_interface_id);
            GOTO continue_next_record;
        END;
      ELSE
        vendor_buss_class_rec.vendor_id := vendor_int_buss_class_rec.vendor_id;
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE IMPORT_VENDOR_BUSS_CLASS' ||
                        ' business_class_interface_id: ' ||
                        vendor_buss_class_rec.business_class_interface_id ||
                        ' party_id: ' || l_party_id || ' vendor_id: ' ||
                        vendor_buss_class_rec.vendor_id);

      BEGIN
        SELECT classification_id
        INTO   l_classification_id
        FROM   pos_bus_class_attr
        WHERE  party_id = l_party_id
        AND    vendor_id = vendor_buss_class_rec.vendor_id
        AND    lookup_code = vendor_buss_class_rec.lookup_code;

      EXCEPTION
        WHEN no_data_found THEN
          l_classification_id := 0;
      END;

      BEGIN
        SELECT mapping_id
        INTO   l_mapping_id
        FROM   pos_supplier_mappings
        WHERE  party_id = l_party_id
        AND    vendor_id = vendor_buss_class_rec.vendor_id;

        SELECT bus_class_request_id
        INTO   l_buss_class_req_id
        FROM   pos_bus_class_reqs
        WHERE  mapping_id = l_mapping_id
        AND    lookup_code = vendor_buss_class_rec.lookup_code;

      EXCEPTION
        WHEN no_data_found THEN
          l_buss_class_req_id := 0;
      END;

      IF (l_classification_id = 0 AND l_buss_class_req_id = 0) THEN
        vendor_int_buss_class_rec.insert_update_flag := nvl(vendor_int_buss_class_rec.insert_update_flag,
                                                            'I');
      ELSE
        vendor_int_buss_class_rec.insert_update_flag := nvl(vendor_int_buss_class_rec.insert_update_flag,
                                                            'U');
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE IMPORT_VENDOR_BUSS_CLASS' ||
                        ' business_class_interface_id: ' ||
                        vendor_buss_class_rec.business_class_interface_id ||
                        ' classification_id: ' || l_classification_id ||
                        ' mapping_id: ' || l_mapping_id ||
                        ' buss_class_req_id: ' || l_buss_class_req_id ||
                        ' insert_update_flag: ' ||
                        vendor_int_buss_class_rec.insert_update_flag);

      IF (vendor_int_buss_class_rec.insert_update_flag = 'I') THEN
        create_vendor_buss_class(p_batch_id              => p_batch_id,
                                 p_vendor_buss_class_rec => vendor_buss_class_rec,
                                 p_party_id              => l_party_id,
                                 x_return_status         => l_return_status,
                                 x_msg_count             => l_msg_count,
                                 x_msg_data              => l_msg_data);

        IF l_return_status = fnd_api.g_ret_sts_success THEN
          UPDATE pos_business_class_int
          SET    status = 'PROCESSED'
          WHERE  business_class_interface_id =
                 vendor_int_buss_class_rec.business_class_interface_id
          AND    sdh_batch_id = p_batch_id;

          UPDATE pos_imp_batch_summary
          SET    total_records_imported = total_records_imported + 1,
                 total_inserts          = total_inserts + 1,
                 buss_class_inserted    = buss_class_inserted + 1,
                 buss_class_imported    = buss_class_imported + 1
          WHERE  batch_id = p_batch_id;

        ELSE
          UPDATE pos_business_class_int
          SET    status = 'REJECTED'
          WHERE  business_class_interface_id =
                 vendor_int_buss_class_rec.business_class_interface_id
          AND    sdh_batch_id = p_batch_id;

          x_return_status := l_return_status;

          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_BUSINESS_CLASS_INT',
                                vendor_int_buss_class_rec.business_class_interface_id,
                                'POS_BUSS_CLASS_CREATION',
                                g_user_id,
                                g_login_id,
                                'import_vendor_buss_class') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Parameters: ' ||
                             ' BUSINESS_CLASS_INTERFACE_ID: ' ||
                             vendor_int_buss_class_rec.business_class_interface_id ||
                             ' Buss and classification Validation Msg: ' ||
                             l_msg_data);
            END IF;
          END IF;
          -- Insert the rejected records into table using Insert_Rejections API

        END IF;

      ELSE
        -- Update the details
        pos_supp_classification_pkg.update_bus_class_attr(p_party_id          => l_party_id,
                                                          p_vendor_id         => vendor_buss_class_rec.vendor_id,
                                                          p_selected          => '',
                                                          p_classification_id => l_classification_id,
                                                          p_request_id        => l_buss_class_req_id,
                                                          p_lookup_code       => vendor_int_buss_class_rec.lookup_code,
                                                          p_exp_date          => vendor_int_buss_class_rec.expiration_date,
                                                          p_cert_num          => vendor_int_buss_class_rec.certificate_number,
                                                          p_cert_agency       => vendor_int_buss_class_rec.certifying_agency,
                                                          p_ext_attr_1        => vendor_int_buss_class_rec.ext_attr_1,
                                                          p_class_status      => vendor_int_buss_class_rec.class_status,
                                                          x_classification_id => l_out_classification_id,
                                                          x_request_id        => l_out_buss_class_req_id,
                                                          x_status            => l_return_status,
                                                          x_exception_msg     => l_msg_data);

        BEGIN
          fnd_file.put_line(fnd_file.log,
                            'API to syncronise data with TCA pasing party_id and vendor_id');
          pos_supp_classification_pkg.synchronize_class_tca_to_po(l_party_id,
                                                                  vendor_buss_class_rec.vendor_id);
        END;

        IF l_return_status = fnd_api.g_ret_sts_success THEN
          UPDATE pos_business_class_int
          SET    status = 'PROCESSED'
          WHERE  business_class_interface_id =
                 vendor_int_buss_class_rec.business_class_interface_id
          AND    sdh_batch_id = p_batch_id;

          UPDATE pos_imp_batch_summary
          SET    total_records_imported = total_records_imported + 1,
                 total_updates          = total_updates + 1,
                 buss_class_updated     = buss_class_updated + 1,
                 buss_class_imported    = buss_class_imported + 1
          WHERE  batch_id = p_batch_id;

        ELSE
          UPDATE pos_business_class_int
          SET    status = 'REJECTED'
          WHERE  business_class_interface_id =
                 vendor_int_buss_class_rec.business_class_interface_id
          AND    sdh_batch_id = p_batch_id;

          x_return_status := l_return_status;

          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_BUSINESS_CLASS_INT',
                                vendor_int_buss_class_rec.business_class_interface_id,
                                'POS_BUSS_CLASS_UPDATION',
                                g_user_id,
                                g_login_id,
                                'import_vendor_buss_class') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Parameters: ' ||
                             ' BUSINESS_CLASS_INTERFACE_ID: ' ||
                             vendor_int_buss_class_rec.business_class_interface_id ||
                             ' Buss and classification Validation Msg: ' ||
                             l_msg_data);
            END IF;
          END IF;

          -- Insert the rejected records into table using Insert_Rejections API
        END IF;

      END IF;

      <<continue_next_record>>
      NULL;
    END LOOP;

    CLOSE vendor_int_buss_class_cur;
    COMMIT;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_buss_class EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_buss_class unexpected EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_buss_class others EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END import_vendor_buss_class;

  PROCEDURE validate_tax_profile
  (
    p_batch_id             IN NUMBER,
    p_tax_profile_rec      IN pos_party_tax_profile_int%ROWTYPE,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    x_tax_prof_valid       OUT NOCOPY VARCHAR2,
    x_party_tax_profile_id OUT NOCOPY NUMBER,
    x_country_code         OUT NOCOPY VARCHAR2
  ) IS
    l_dummy_lookup VARCHAR2(30);
    l_request_id   NUMBER := fnd_global.conc_request_id;

    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_api_name CONSTANT VARCHAR2(50) := 'VALIDATE_VENDOR_PRODS_SERVICES';
  BEGIN
    fnd_file.put_line(fnd_file.log, ' Inside validate_tax_profile');
    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    x_tax_prof_valid := 'Y';

    -- Check if the Tax Profile Id exists
    BEGIN
      SELECT party_tax_profile_id
      INTO   x_party_tax_profile_id
      FROM   zx_party_tax_profile
      WHERE  party_id = p_tax_profile_rec.party_id
      AND    party_type_code = 'THIRD_PARTY';

--      RETURN;    commented in bug 16210521

    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;

    -- Validate the rounding Level using the following query
    IF (p_tax_profile_rec.rounding_level_code IS NOT NULL) THEN
      fnd_file.put_line(fnd_file.log, ' Validating rounding level');
      BEGIN
        SELECT fndlookup.lookup_code
        INTO   l_dummy_lookup
        FROM   fnd_lookups fndlookup
        WHERE  fndlookup.lookup_type LIKE 'ZX_ROUNDING_LEVEL'
        AND    nvl(fndlookup.start_date_active, SYSDATE) <= SYSDATE
        AND    nvl(fndlookup.end_date_active, SYSDATE) >= SYSDATE
        AND    nvl(fndlookup.enabled_flag, 'N') = 'Y'
        AND    lookup_code = p_tax_profile_rec.rounding_level_code
        ORDER  BY fndlookup.lookup_code;

      EXCEPTION
        WHEN OTHERS THEN
          x_tax_prof_valid := 'N';
          x_return_status  := fnd_api.g_ret_sts_error;
          x_msg_data       := 'POS_INVALID_ROUNDING_LEVEL';
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_PARTY_TAX_PROFILE_INT',
                                p_tax_profile_rec.rounding_level_code,
                                'POS_INVALID_ROUNDING_LEVEL',
                                g_user_id,
                                g_login_id,
                                ' Validate_Tax_Profile ') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             ' Acct Validation Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Invalid rounding level for: ' ||
                            ' p_tax_profile_rec.rounding_level_code: ' ||
                            p_tax_profile_rec.rounding_level_code);
          RETURN;
      END;
    END IF;

    IF (p_tax_profile_rec.rounding_rule_code IS NOT NULL) THEN
      -- Validate the rounding Rule using the following query
      fnd_file.put_line(fnd_file.log, ' Validating rounding rule');
      BEGIN
        SELECT fndlookup.lookup_code
        INTO   l_dummy_lookup
        FROM   fnd_lookups fndlookup
        WHERE  fndlookup.lookup_type LIKE 'ZX_ROUNDING_RULE'
        AND    nvl(fndlookup.start_date_active, SYSDATE) <= SYSDATE
        AND    nvl(fndlookup.end_date_active, SYSDATE) >= SYSDATE
        AND    nvl(fndlookup.enabled_flag, 'N') = 'Y'
        AND    lookup_code = p_tax_profile_rec.rounding_rule_code
        ORDER  BY fndlookup.lookup_code;

      EXCEPTION
        WHEN OTHERS THEN
          x_tax_prof_valid := 'N';
          x_return_status  := fnd_api.g_ret_sts_error;
          x_msg_data       := 'POS_INVALID_ROUNDING_RULE';
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_PARTY_TAX_PROFILE_INT',
                                p_tax_profile_rec.rounding_rule_code,
                                'POS_INVALID_ROUNDING_RULE',
                                g_user_id,
                                g_login_id,
                                ' Validate_Tax_Profile ') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Invalid rounding rule for: ' ||
                            ' p_tax_profile_rec.rounding_rule_code: ' ||
                            p_tax_profile_rec.rounding_rule_code);
          RETURN;
      END;
    END IF;

    IF (p_tax_profile_rec.country_name IS NOT NULL) THEN
      -- Validate the Country Name using the following query
      fnd_file.put_line(fnd_file.log, ' Validating Country name');
      BEGIN
        SELECT territory_code
        INTO   x_country_code
        FROM   fnd_territories_vl
        WHERE  territory_short_name = p_tax_profile_rec.country_name;

        -- Update the Interface table with the country code obtained in the prev SQL since the country code would be saved.
      EXCEPTION
        WHEN OTHERS THEN
          x_tax_prof_valid := 'N';
          x_return_status  := fnd_api.g_ret_sts_error;
          x_msg_data       := 'POS_INVALID_COUNTRY_NAME';
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                ' POS_PARTY_TAX_PROFILE_INT',
                                p_tax_profile_rec.country_name,
                                'POS_INVALID_COUNTRY_NAME',
                                g_user_id,
                                g_login_id,
                                ' Validate_Tax_Profile ') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Invalid country name for: ' ||
                            ' p_tax_profile_rec.country_name: ' ||
                            p_tax_profile_rec.country_name);
          RETURN;
      END;
    END IF;

    IF (p_tax_profile_rec.registration_type_code IS NOT NULL) THEN
      -- Validate the Registration Type Code using the following query
      fnd_file.put_line(fnd_file.log, ' Validating registration type');
      BEGIN
        SELECT fndlookup.lookup_code
        INTO   l_dummy_lookup
        FROM   fnd_lookups fndlookup
        WHERE  fndlookup.lookup_type LIKE 'ZX_REGISTRATIONS_TYPE'
        AND    nvl(fndlookup.start_date_active, SYSDATE) <= SYSDATE
        AND    nvl(fndlookup.end_date_active, SYSDATE) >= SYSDATE
        AND    nvl(fndlookup.enabled_flag, 'N') = 'Y'
        AND    lookup_code = p_tax_profile_rec.registration_type_code
        ORDER  BY fndlookup.lookup_code;

      EXCEPTION
        WHEN OTHERS THEN
          x_tax_prof_valid := 'N';
          x_return_status  := fnd_api.g_ret_sts_error;
          x_msg_data       := 'POS_INVALID_REGI_TYPE_CODE';
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_PARTY_TAX_PROFILE_INT',
                                p_tax_profile_rec.registration_type_code,
                                'POS_INVALID_REGI_TYPE_CODE',
                                g_user_id,
                                g_login_id,
                                ' Validate_Tax_Profile ') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Invalid Registration Type Code for: ' ||
                            ' p_tax_profile_rec.registration_type_code: ' ||
                            p_tax_profile_rec.registration_type_code);
          RETURN;
      END;
    END IF;

	    --begin bug 16210521: add validation for tax_classification_code
    IF (p_tax_profile_rec.tax_classification_code IS NOT NULL) THEN
      -- Validate the Tax Classification Code using the following query
      fnd_file.put_line(fnd_file.log, ' Validating tax classification code');
      BEGIN
        SELECT *
        INTO l_dummy_lookup
        FROM
          (SELECT LOOKUP_CODE
          FROM ZX_INPUT_CLASSIFICATIONS_V
          WHERE LOOKUP_TYPE = 'ZX_INPUT_CLASSIFICATIONS'
          AND ENABLED_FLAG  = 'Y'
          AND SYSDATE BETWEEN START_DATE_ACTIVE AND NVL(END_DATE_ACTIVE,SYSDATE)
          UNION
          SELECT LOOKUP_CODE
          FROM ZX_INPUT_CLASSIFICATIONS_V
          WHERE LOOKUP_TYPE = 'ZX_WEB_EXP_TAX_CLASSIFICATIONS'
          AND ENABLED_FLAG  = 'Y'
          AND SYSDATE BETWEEN START_DATE_ACTIVE AND NVL(END_DATE_ACTIVE,SYSDATE)
          UNION
          SELECT LOOKUP_CODE
          FROM ZX_OUTPUT_CLASSIFICATIONS_V
          WHERE LOOKUP_TYPE = 'ZX_OUTPUT_CLASSIFICATIONS'
          AND ENABLED_FLAG  = 'Y'
          AND SYSDATE BETWEEN START_DATE_ACTIVE AND NVL(END_DATE_ACTIVE,SYSDATE)
          ) QRSLT
        WHERE LOOKUP_CODE = p_tax_profile_rec.tax_classification_code
        ORDER BY LOOKUP_CODE;

      EXCEPTION
        WHEN OTHERS THEN
          x_tax_prof_valid := 'N';
          x_return_status  := fnd_api.g_ret_sts_error;
          x_msg_data       := 'POS_INVALID_TAX_CLASSFICATION_CODE';
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_PARTY_TAX_PROFILE_INT',
                                p_tax_profile_rec.registration_type_code,
                                'POS_INVALID_TAX_CLASSFICATION_CODE',
                                g_user_id,
                                g_login_id,
                                ' Validate_Tax_Profile ') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Invalid Tax Classification Code for: ' ||
                            ' p_tax_profile_rec.tax_classification_code: ' ||
                            p_tax_profile_rec.tax_classification_code);
          RETURN;
      END;
    END IF;

    --end bug 16210521

  EXCEPTION
    WHEN OTHERS THEN
      x_tax_prof_valid := 'N';
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside validate_tax_profile EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END validate_tax_profile;

  PROCEDURE create_tax_profile
  (
    p_batch_id        IN NUMBER,
    p_tax_profile_rec IN pos_party_tax_profile_int%ROWTYPE,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2,
    x_tax_profile_id  OUT NOCOPY NUMBER
  ) IS
    l_tax_prof_valid       VARCHAR2(10);
    l_party_tax_profile_id NUMBER;
    l_country_code         VARCHAR2(40);
    l_return_status        VARCHAR2(100);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(4000);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    -- Call Validate_Tax_profile to validate the Tax Profiledata
    validate_tax_profile(p_batch_id             => p_batch_id,
                         p_tax_profile_rec      => p_tax_profile_rec,
                         x_return_status        => l_return_status,
                         x_msg_count            => l_msg_count,
                         x_msg_data             => l_msg_data,
                         x_tax_prof_valid       => l_tax_prof_valid,
                         x_party_tax_profile_id => l_party_tax_profile_id,
                         x_country_code         => l_country_code);

    fnd_file.put_line(fnd_file.log,
                      ' p_rounding_level_code: ' ||
                      p_tax_profile_rec.rounding_level_code ||
                      ' p_rounding_rule_code: ' ||
                      p_tax_profile_rec.rounding_rule_code);

    IF (l_tax_prof_valid = 'Y') THEN

      IF (p_tax_profile_rec.insert_update_flag = 'U') THEN
        fnd_file.put_line(fnd_file.log, ' Updating Tax profile');
        zx_party_tax_profile_pkg.update_row(p_party_tax_profile_id         => l_party_tax_profile_id,
                                            p_collecting_authority_flag    => NULL,
                                            p_provider_type_code           => NULL,
                                            p_create_awt_dists_type_code   => NULL,
                                            p_create_awt_invoices_type_cod => NULL,
                                            p_tax_classification_code      => p_tax_profile_rec.tax_classification_code, -- bug 16210521
                                            p_self_assess_flag             => p_tax_profile_rec.self_assess_flag,  -- bug 16210521
                                            p_allow_offset_tax_flag        => p_tax_profile_rec.allow_offset_tax_flag,  -- bug 16210521
                                            p_rep_registration_number      => p_tax_profile_rec.rep_registration_number,
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
                                            p_party_id                     => p_tax_profile_rec.party_id,
                                            p_program_login_id             => NULL,
                                            p_party_type_code              => 'THIRD_PARTY',
                                            p_supplier_flag                => NULL,
                                            p_customer_flag                => NULL,
                                            p_site_flag                    => NULL,
                                            p_process_for_applicability_fl => p_tax_profile_rec.process_for_applicability_flag,  -- bug 16210521
                                            p_rounding_level_code          => p_tax_profile_rec.rounding_level_code,
                                            p_rounding_rule_code           => p_tax_profile_rec.rounding_rule_code,
                                            p_withholding_start_date       => NULL,
                                            p_inclusive_tax_flag           => p_tax_profile_rec.inclusive_tax_flag,
                                            p_allow_awt_flag               => NULL,
                                            p_use_le_as_subscriber_flag    => NULL,
                                            p_legal_establishment_flag     => NULL,
                                            p_first_party_le_flag          => NULL,
                                            p_reporting_authority_flag     => NULL,
                                            x_return_status                => l_return_status,
                                            p_registration_type_code       => p_tax_profile_rec.registration_type_code,
                                            p_country_code                 => l_country_code);

        x_tax_profile_id := l_party_tax_profile_id;
      ELSE
        -- Insert
        fnd_file.put_line(fnd_file.log, ' Creating Tax profile');
        zx_party_tax_profile_pkg.insert_row(p_collecting_authority_flag    => NULL,
                                            p_provider_type_code           => NULL,
                                            p_create_awt_dists_type_code   => NULL,
                                            p_create_awt_invoices_type_cod => NULL,
                                            p_tax_classification_code      => p_tax_profile_rec.tax_classification_code, -- bug 16210521
                                            p_self_assess_flag             => p_tax_profile_rec.self_assess_flag,  -- bug 16210521
                                            p_allow_offset_tax_flag        => p_tax_profile_rec.allow_offset_tax_flag,  -- bug 16210521
                                            p_rep_registration_number      => p_tax_profile_rec.rep_registration_number,
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
                                            p_party_id                     => p_tax_profile_rec.party_id,
                                            p_program_login_id             => NULL,
                                            p_party_type_code              => 'THIRD_PARTY',
                                            p_supplier_flag                => NULL,
                                            p_customer_flag                => NULL,
                                            p_site_flag                    => NULL,
                                            p_process_for_applicability_fl => p_tax_profile_rec.process_for_applicability_flag,  -- bug 16210521
                                            p_rounding_level_code          => p_tax_profile_rec.rounding_level_code,
                                            p_rounding_rule_code           => p_tax_profile_rec.rounding_rule_code,
                                            p_withholding_start_date       => NULL,
                                            p_inclusive_tax_flag           => p_tax_profile_rec.inclusive_tax_flag,
                                            p_allow_awt_flag               => NULL,
                                            p_use_le_as_subscriber_flag    => NULL,
                                            p_legal_establishment_flag     => NULL,
                                            p_first_party_le_flag          => NULL,
                                            p_reporting_authority_flag     => NULL,
                                            x_return_status                => l_return_status,
                                            p_registration_type_code       => p_tax_profile_rec.registration_type_code,
                                            p_country_code                 => l_country_code);

        -- The ZX API doesn't return the Tax Profile Id that has been created
        -- So re-querying the Tax profile Id using the party Id and the party Type
        --
        IF (l_return_status = 'S') THEN
          SELECT party_tax_profile_id
          INTO   l_party_tax_profile_id
          FROM   zx_party_tax_profile
          WHERE  party_id = p_tax_profile_rec.party_id
          AND    party_type_code = 'THIRD_PARTY';

          x_tax_profile_id := l_party_tax_profile_id;
        END IF;
      END IF;
    ELSE
      x_return_status := l_return_status;
      x_msg_data      := l_msg_data;
      x_msg_count     := l_msg_count;
      fnd_file.put_line(fnd_file.log,
                        ' Tax profile validation failed for: ' ||
                        ' tax_profile_interface_id: ' ||
                        p_tax_profile_rec.tax_profile_interface_id);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside create_tax_profile EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END create_tax_profile;

  /*
  TAX REGISTRATIONS
  */

  PROCEDURE validate_tax_registration
  (
    p_batch_id               IN NUMBER,
    p_tax_reg_rec            IN pos_party_tax_reg_int%ROWTYPE,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_tax_reg_valid          OUT NOCOPY VARCHAR2,
    x_registration_loc_id    OUT NOCOPY NUMBER,
    x_tax_authority_party_id OUT NOCOPY NUMBER
  ) IS
    l_dummy_lookup           VARCHAR2(30);
    l_dummy_location         NUMBER;
    l_tax_authority_party_id NUMBER;

    l_request_id NUMBER := fnd_global.conc_request_id;

    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_api_name CONSTANT VARCHAR2(50) := 'VALIDATE_VENDOR_PRODS_SERVICES';
  BEGIN
    fnd_file.put_line(fnd_file.log, ' Inside validate_tax_registration');
    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    x_tax_reg_valid := 'Y';

    -- Validate the Tax Registration Type using the following query
    IF (p_tax_reg_rec.registration_type_code IS NOT NULL) THEN
      BEGIN
        fnd_file.put_line(fnd_file.log,
                          ' Validating tax registration type');
        SELECT fndlookup.lookup_code
        INTO   l_dummy_lookup
        FROM   fnd_lookups fndlookup
        WHERE  fndlookup.lookup_type LIKE 'ZX_REGISTRATIONS_TYPE'
        AND    nvl(fndlookup.start_date_active, SYSDATE) <= SYSDATE
        AND    nvl(fndlookup.end_date_active, SYSDATE) >= SYSDATE
        AND    nvl(fndlookup.enabled_flag, 'N') = 'Y'
        AND    lookup_code = p_tax_reg_rec.registration_type_code
        ORDER  BY fndlookup.lookup_code;

      EXCEPTION
        WHEN OTHERS THEN
          x_tax_reg_valid := 'N';
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data      := 'POS_INVALID_REGI_TYPE_CODE';
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_PARTY_TAX_REG_INT',
                                p_tax_reg_rec.registration_type_code,
                                'POS_INVALID_REGI_TYPE_CODE',
                                g_user_id,
                                g_login_id,
                                ' Validate_Tax_Registration ') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Invalid Tax Registration Type for: ' ||
                            ' p_tax_reg_rec.registration_type_code: ' ||
                            p_tax_reg_rec.registration_type_code);
          RETURN;
      END;
    END IF;

    -- Validate the Tax Registration Status using the following query
    IF (p_tax_reg_rec.registration_status_code IS NOT NULL) THEN
      fnd_file.put_line(fnd_file.log,
                        ' Validating tax registration status');
      BEGIN
        SELECT fndlookup.lookup_code
        INTO   l_dummy_lookup
        FROM   fnd_lookups fndlookup
        WHERE  fndlookup.lookup_type LIKE 'ZX_REGISTRATIONS_STATUS'
        AND    nvl(fndlookup.start_date_active, SYSDATE) <= SYSDATE
        AND    nvl(fndlookup.end_date_active, SYSDATE) >= SYSDATE
        AND    nvl(fndlookup.enabled_flag, 'N') = 'Y'
        AND    lookup_code = p_tax_reg_rec.registration_status_code
        ORDER  BY fndlookup.lookup_code;

      EXCEPTION
        WHEN OTHERS THEN
          x_tax_reg_valid := 'N';
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data      := 'POS_INVALID_REG_STATUS_CODE';
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_PARTY_TAX_REG_INT',
                                p_tax_reg_rec.registration_status_code,
                                'POS_INVALID_REG_STATUS_CODE',
                                g_user_id,
                                g_login_id,
                                ' Validate_Tax_Registration ') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Invalid Tax Registration Status for: ' ||
                            ' p_tax_reg_rec.registration_status_code: ' ||
                            p_tax_reg_rec.registration_status_code);
          RETURN;
      END;
    END IF;

    IF (p_tax_reg_rec.registration_address IS NOT NULL) THEN
      -- Validate the Local Reg Address using the following query
      fnd_file.put_line(fnd_file.log,
                        ' Validating Tax registration address');
      BEGIN
        SELECT loc.location_id
        INTO   l_dummy_location
        FROM   hr_locations loc
        WHERE  loc.location_code || ':' || ' ' || loc.address_line_1 || ' ' ||
               loc.town_or_city || ' ' || loc.region_1 =
               p_tax_reg_rec.registration_address
        AND    legal_address_flag = 'Y'
        AND    SYSDATE < nvl(inactive_date, SYSDATE + 1);

        x_registration_loc_id := l_dummy_location;

      EXCEPTION
        WHEN OTHERS THEN
          x_tax_reg_valid := 'N';
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data      := 'POS_INVALID_REG_ADDRESS';
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_PARTY_TAX_REG_INT',
                                p_tax_reg_rec.registration_address,
                                'POS_INVALID_REG_ADDRESS',
                                g_user_id,
                                g_login_id,
                                ' Validate_Tax_Registration ') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Invalid Local Reg Address for: ' ||
                            ' p_tax_reg_rec.registration_address: ' ||
                            p_tax_reg_rec.registration_address);
          RETURN;
      END;
    END IF;

    IF (p_tax_reg_rec.registration_reason_code IS NOT NULL) THEN
      -- Validate the Tax Registration Reason using the following query
      fnd_file.put_line(fnd_file.log,
                        ' Validating tax registration reason code');
      BEGIN
        SELECT fndlookup.lookup_code
        INTO   l_dummy_lookup
        FROM   fnd_lookups fndlookup
        WHERE  fndlookup.lookup_type LIKE 'ZX_REGISTRATIONS_REASON'
        AND    nvl(fndlookup.start_date_active, SYSDATE) <= SYSDATE
        AND    nvl(fndlookup.end_date_active, SYSDATE) >= SYSDATE
        AND    nvl(fndlookup.enabled_flag, 'N') = 'Y'
        AND    lookup_code = p_tax_reg_rec.registration_reason_code
        ORDER  BY fndlookup.lookup_code;

      EXCEPTION
        WHEN OTHERS THEN
          x_tax_reg_valid := 'N';
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data      := 'POS_INVALID_REG_REASON_CODE';
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_PARTY_TAX_REG_INT',
                                p_tax_reg_rec.registration_reason_code,
                                'POS_INVALID_REG_REASON_CODE',
                                g_user_id,
                                g_login_id,
                                ' Validate_Tax_Registration ') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Invalid Tax Registration Reason for: ' ||
                            ' p_tax_reg_rec.registration_reason_code: ' ||
                            p_tax_reg_rec.registration_reason_code);
          RETURN;
      END;
    END IF;

    IF (p_tax_reg_rec.registration_source_code IS NOT NULL) THEN
      -- Validate the Tax Registration Source using the following query
      fnd_file.put_line(fnd_file.log,
                        ' Validating tax registration source code');
      BEGIN
        SELECT fndlookup.lookup_code
        INTO   l_dummy_lookup
        FROM   fnd_lookups fndlookup
        WHERE  fndlookup.lookup_type LIKE 'ZX_REGISTRATIONS_SOURCE'
        AND    nvl(fndlookup.start_date_active, SYSDATE) <= SYSDATE
        AND    nvl(fndlookup.end_date_active, SYSDATE) >= SYSDATE
        AND    nvl(fndlookup.enabled_flag, 'N') = 'Y'
        AND    lookup_code = p_tax_reg_rec.registration_source_code
        ORDER  BY fndlookup.lookup_code;

      EXCEPTION
        WHEN OTHERS THEN
          x_tax_reg_valid := 'N';
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data      := 'POS_INVALID_REG_SOURCE_CODE';
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_PARTY_TAX_REG_INT',
                                p_tax_reg_rec.registration_source_code,
                                'POS_INVALID_REG_SOURCE_CODE',
                                g_user_id,
                                g_login_id,
                                ' Validate_Tax_Registration ') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Invalid Tax Registration Source for: ' ||
                            ' p_tax_reg_rec.registration_source_code: ' ||
                            p_tax_reg_rec.registration_source_code);
          RETURN;
      END;
    END IF;

    IF (p_tax_reg_rec.rounding_rule_code IS NOT NULL) THEN
      -- Validate the Tax Registration Rounding rule using the following query
      fnd_file.put_line(fnd_file.log,
                        ' Validating tax registration rounding rule code');
      BEGIN
        SELECT fndlookup.lookup_code
        INTO   l_dummy_lookup
        FROM   fnd_lookups fndlookup
        WHERE  fndlookup.lookup_type LIKE 'ZX_ROUNDING_RULE'
        AND    nvl(fndlookup.start_date_active, SYSDATE) <= SYSDATE
        AND    nvl(fndlookup.end_date_active, SYSDATE) >= SYSDATE
        AND    nvl(fndlookup.enabled_flag, 'N') = 'Y'
        AND    lookup_code = p_tax_reg_rec.rounding_rule_code
        ORDER  BY fndlookup.lookup_code;

      EXCEPTION
        WHEN OTHERS THEN
          x_tax_reg_valid := 'N';
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data      := 'POS_INVALID_ROUND_RULE_CODE';
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_PARTY_TAX_REG_INT',
                                p_tax_reg_rec.rounding_rule_code,
                                'POS_INVALID_ROUND_RULE_CODE',
                                g_user_id,
                                g_login_id,
                                ' Validate_Tax_Registration ') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Invalid Tax Registration Rounding rule for: ' ||
                            ' p_tax_reg_rec.rounding_rule_code: ' ||
                            p_tax_reg_rec.rounding_rule_code);
          RETURN;
      END;
    END IF;

    -- get TAX_AUTHORITY party id
    IF (p_tax_reg_rec.tax_authority_party_id IS NULL AND
       p_tax_reg_rec.tax_authority_name IS NOT NULL) THEN
      fnd_file.put_line(fnd_file.log, ' Getting tax authority party id');
      BEGIN
        SELECT prof.party_id
        INTO   l_tax_authority_party_id
        FROM   zx_party_tax_profile prof,
               hz_parties           hp
        WHERE  hp.party_id = prof.party_id
        AND    prof.party_type_code = 'TAX_AUTHORITY'
        AND    hp.party_name = p_tax_reg_rec.tax_authority_name;

        x_tax_authority_party_id := l_tax_authority_party_id;

      EXCEPTION
        WHEN OTHERS THEN
          x_tax_reg_valid := 'N';
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data      := 'POS_INVALID_TAX_AUTHORITY';
          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_PARTY_TAX_REG_INT',
                                p_tax_reg_rec.rounding_rule_code,
                                'POS_INVALID_TAX_AUTHORITY',
                                g_user_id,
                                g_login_id,
                                ' Validate_Tax_Registration ') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Invalid Tax Authority Name rule for: ' ||
                            ' p_tax_reg_rec.tax_authority_name: ' ||
                            p_tax_reg_rec.tax_authority_name);
          RETURN;
      END;

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_tax_reg_valid := 'N';
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside validate_tax_registration EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END validate_tax_registration;

  PROCEDURE create_tax_registration
  (
    p_batch_id             IN NUMBER,
    p_tax_registration_rec IN pos_party_tax_reg_int%ROWTYPE,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2
  ) IS
    l_location_id            NUMBER;
    l_return_status          VARCHAR2(100);
    l_creation_status        VARCHAR2(100);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(4000);
    l_valid                  VARCHAR2(100);
    l_tax_authority_party_id NUMBER;
    l_request_id             NUMBER := fnd_global.conc_request_id;
  BEGIN
    fnd_file.put_line(fnd_file.log, ' Inside create_tax_registration');
    x_return_status := fnd_api.g_ret_sts_success;

    validate_tax_registration(p_batch_id               => p_batch_id,
                              p_tax_reg_rec            => p_tax_registration_rec,
                              x_return_status          => l_return_status,
                              x_msg_count              => l_msg_count,
                              x_msg_data               => l_msg_data,
                              x_tax_reg_valid          => l_valid,
                              x_registration_loc_id    => l_location_id,
                              x_tax_authority_party_id => l_tax_authority_party_id);

    IF (l_valid = 'Y') THEN
      fnd_file.put_line(fnd_file.log,
                        ' Calling zx_registrations_pkg.insert_row');

      zx_registrations_pkg.insert_row(p_request_id                => NULL,
                                      p_attribute1                => NULL,
                                      p_attribute2                => NULL,
                                      p_attribute3                => NULL,
                                      p_attribute4                => NULL,
                                      p_attribute5                => NULL,
                                      p_attribute6                => NULL,
                                      p_validation_rule           => NULL,
                                      p_rounding_rule_code        => p_tax_registration_rec.rounding_rule_code,
                                      p_tax_jurisdiction_code     => p_tax_registration_rec.tax_jurisdiction_code,
                                      p_self_assess_flag          => NULL,
                                      p_registration_status_code  => p_tax_registration_rec.registration_status_code,
                                      p_registration_source_code  => p_tax_registration_rec.registration_source_code,
                                      p_registration_reason_code  => p_tax_registration_rec.registration_reason_code,
                                      p_tax                       => p_tax_registration_rec.tax,
                                      p_tax_regime_code           => p_tax_registration_rec.tax_regime_code,
                                      p_inclusive_tax_flag        => p_tax_registration_rec.inclusive_tax_flag,
                                      p_effective_from            => p_tax_registration_rec.effective_from,
                                      p_effective_to              => p_tax_registration_rec.effective_to,
                                      p_rep_party_tax_name        => p_tax_registration_rec.rep_party_tax_name,
                                      p_default_registration_flag => p_tax_registration_rec.default_registration_flag,
                                      p_bank_account_num          => NULL,
                                      p_record_type_code          => NULL,
                                      p_legal_location_id         => l_location_id,
                                      p_tax_authority_id          => l_tax_authority_party_id,
                                      p_rep_tax_authority_id      => NULL,
                                      p_coll_tax_authority_id     => NULL,
                                      p_registration_type_code    => p_tax_registration_rec.registration_type_code,
                                      p_registration_number       => p_tax_registration_rec.registration_number,
                                      p_party_tax_profile_id      => p_tax_registration_rec.tax_profile_id,
                                      p_legal_registration_id     => NULL,
                                      p_bank_id                   => NULL,
                                      p_bank_branch_id            => NULL,
                                      p_account_site_id           => NULL,
                                      p_attribute14               => NULL,
                                      p_attribute15               => NULL,
                                      p_attribute_category        => NULL,
                                      p_program_login_id          => NULL,
                                      p_account_id                => NULL,
                                      p_tax_classification_code   => NULL,
                                      p_attribute7                => NULL,
                                      p_attribute8                => NULL,
                                      p_attribute9                => NULL,
                                      p_attribute10               => NULL,
                                      p_attribute11               => NULL,
                                      p_attribute12               => NULL,
                                      p_attribute13               => NULL,
                                      x_return_status             => l_creation_status);

      x_return_status := l_creation_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;

    ELSE
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      -- Read the Error buffer returned from the API
      -- Add the error buffer message to supplier rejections
      -- table
      IF (insert_rejections(p_batch_id,
                            l_request_id,
                            'POS_PARTY_TAX_REG_INT',
                            p_tax_registration_rec.registration_type_code,
                            'POS_INVALID_TAX_REG_INS',
                            g_user_id,
                            g_login_id,
                            ' Create_Tax_Registration ') <> TRUE) THEN

        IF (g_level_procedure >= g_current_runtime_level) THEN
          fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                    p_data  => l_msg_data);
          fnd_log.string(g_level_procedure,
                         g_module_name || 'Create_Tax_Registration',
                         'Msg: ' || l_msg_data);
        END IF;
      END IF;
      fnd_file.put_line(fnd_file.log,
                        ' Tax Registration validation/creation failed for: ' ||
                        ' tax_reg_interface_id: ' ||
                        p_tax_registration_rec.tax_reg_interface_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside create_tax_registration EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END create_tax_registration;

  PROCEDURE update_tax_registration
  (
    p_batch_id             IN NUMBER,
    p_registration_id      IN NUMBER,
    p_tax_registration_rec IN pos_party_tax_reg_int%ROWTYPE,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2
  ) IS
    l_location_id            NUMBER;
    l_return_status          VARCHAR2(100);
    l_creation_status        VARCHAR2(100);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(4000);
    l_valid                  VARCHAR2(100);
    l_tax_authority_party_id NUMBER;
    l_request_id             NUMBER := fnd_global.conc_request_id;
  BEGIN
    fnd_file.put_line(fnd_file.log, ' Inside update_tax_registration');
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    validate_tax_registration(p_batch_id               => p_batch_id,
                              p_tax_reg_rec            => p_tax_registration_rec,
                              x_return_status          => l_return_status,
                              x_msg_count              => l_msg_count,
                              x_msg_data               => l_msg_data,
                              x_tax_reg_valid          => l_valid,
                              x_registration_loc_id    => l_location_id,
                              x_tax_authority_party_id => l_tax_authority_party_id);

    IF (l_valid = 'Y') THEN
      fnd_file.put_line(fnd_file.log,
                        ' Calling zx_registrations_pkg.update_row');

      zx_registrations_pkg.update_row(p_registration_id           => p_registration_id,
                                      p_request_id                => NULL,
                                      p_attribute1                => NULL,
                                      p_attribute2                => NULL,
                                      p_attribute3                => NULL,
                                      p_attribute4                => NULL,
                                      p_attribute5                => NULL,
                                      p_attribute6                => NULL,
                                      p_validation_rule           => NULL,
                                      p_rounding_rule_code        => p_tax_registration_rec.rounding_rule_code,
                                      p_tax_jurisdiction_code     => p_tax_registration_rec.tax_jurisdiction_code,
                                      p_self_assess_flag          => NULL,
                                      p_registration_status_code  => p_tax_registration_rec.registration_status_code,
                                      p_registration_source_code  => p_tax_registration_rec.registration_source_code,
                                      p_registration_reason_code  => p_tax_registration_rec.registration_reason_code,
                                      p_tax                       => p_tax_registration_rec.tax,
                                      p_tax_regime_code           => p_tax_registration_rec.tax_regime_code,
                                      p_inclusive_tax_flag        => p_tax_registration_rec.inclusive_tax_flag,
                                      p_effective_from            => p_tax_registration_rec.effective_from,
                                      p_effective_to              => p_tax_registration_rec.effective_to,
                                      p_rep_party_tax_name        => p_tax_registration_rec.rep_party_tax_name,
                                      p_default_registration_flag => p_tax_registration_rec.default_registration_flag,
                                      p_bank_account_num          => NULL,
                                      p_record_type_code          => NULL,
                                      p_legal_location_id         => l_location_id,
                                      p_tax_authority_id          => l_tax_authority_party_id,
                                      p_rep_tax_authority_id      => NULL,
                                      p_coll_tax_authority_id     => NULL,
                                      p_registration_type_code    => p_tax_registration_rec.registration_type_code,
                                      p_registration_number       => p_tax_registration_rec.registration_number,
                                      p_party_tax_profile_id      => p_tax_registration_rec.tax_profile_id,
                                      p_legal_registration_id     => NULL,
                                      p_bank_id                   => NULL,
                                      p_bank_branch_id            => NULL,
                                      p_account_site_id           => NULL,
                                      p_attribute14               => NULL,
                                      p_attribute15               => NULL,
                                      p_attribute_category        => NULL,
                                      p_program_login_id          => NULL,
                                      p_account_id                => NULL,
                                      p_tax_classification_code   => NULL,
                                      p_attribute7                => NULL,
                                      p_attribute8                => NULL,
                                      p_attribute9                => NULL,
                                      p_attribute10               => NULL,
                                      p_attribute11               => NULL,
                                      p_attribute12               => NULL,
                                      p_attribute13               => NULL,
                                      x_return_status             => l_creation_status);

      x_return_status := l_creation_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;

    ELSE
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      IF (insert_rejections(p_batch_id,
                            l_request_id,
                            'POS_PARTY_TAX_REG_INT',
                            p_tax_registration_rec.registration_type_code,
                            'POS_INVALID_TAX_REG_UPD',
                            g_user_id,
                            g_login_id,
                            ' UPDATE_TAX_REGISTRATION ') <> TRUE) THEN

        IF (g_level_procedure >= g_current_runtime_level) THEN
          fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                    p_data  => l_msg_data);
          fnd_log.string(g_level_procedure,
                         g_module_name || 'UPDATE_TAX_REGISTRATION',
                         'Msg: ' || l_msg_data);
        END IF;
      END IF;
      fnd_file.put_line(fnd_file.log,
                        ' Tax Registration validation/updation failed for: ' ||
                        ' tax_reg_interface_id: ' ||
                        p_tax_registration_rec.tax_reg_interface_id);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside update_tax_registration EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END update_tax_registration;

  /* FISCAL CLASSIFICATION */

  PROCEDURE validate_fiscal_classification
  (
    p_batch_id            IN NUMBER,
    p_fiscal_class_rec    IN pos_fiscal_class_int%ROWTYPE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    x_valid               OUT NOCOPY VARCHAR2,
    x_classification_type OUT NOCOPY VARCHAR2,
    x_classification_code OUT NOCOPY VARCHAR2
  ) IS

    l_classification_code VARCHAR2(50);
    l_classification_type VARCHAR2(50);

    l_request_id NUMBER := fnd_global.conc_request_id;

    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(2000);
    l_api_name CONSTANT VARCHAR2(50) := 'VALIDATE_VENDOR_PRODS_SERVICES';
  BEGIN
    fnd_file.put_line(fnd_file.log,
                      ' Inside validate_fiscal_classification');
    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    x_valid := 'Y';

    -- Validate the Fiscal Classification Type using the following query
    BEGIN
      SELECT owner_id_char
      INTO   l_classification_type
      FROM   zx_fc_types_vl
      WHERE  classification_type_categ_code = 'PARTY_FISCAL_CLASS'
      AND    SYSDATE BETWEEN nvl(effective_from, SYSDATE) AND
             nvl(effective_to, SYSDATE)
      AND    classification_type_code =
             p_fiscal_class_rec.classification_type_code_name;

      x_classification_type := l_classification_type;

    EXCEPTION
      WHEN OTHERS THEN
        x_valid         := 'N';
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_data      := 'POS_INVALID_FISCAL_CLASS_TYPE';
        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_FISCAL_CLASS_INT',
                              p_fiscal_class_rec.classification_type_code_name,
                              'POS_INVALID_FISCAL_CLASS_TYPE',
                              g_user_id,
                              g_login_id,
                              ' Validate_fiscal_classification ') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' ||
                           p_fiscal_class_rec.classification_type_code_name ||
                           ' Acct Validation Msg: ' || l_msg_data);
          END IF;
        END IF;
        fnd_file.put_line(fnd_file.log,
                          ' Invalid Fiscal Classification Type for: ' ||
                          ' p_fiscal_class_rec.classification_type_code_name: ' ||
                          p_fiscal_class_rec.classification_type_code_name);
        RETURN;
    END;

    -- Validate the Fiscal Classification Code using the following query
    BEGIN
      SELECT class_code
      INTO   l_classification_code
      FROM   hz_class_code_denorm
      WHERE  SYSDATE BETWEEN nvl(start_date_active, SYSDATE) AND
             nvl(end_date_active, SYSDATE)
      AND    LANGUAGE = userenv('LANG')
      AND    class_code_meaning = p_fiscal_class_rec.class_code_name
      AND    class_category = l_classification_type;

      x_classification_code := l_classification_code;

    EXCEPTION
      WHEN OTHERS THEN
        x_valid         := 'N';
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_data      := 'POS_INVALID_FISCAL_CLASS_NAME';
        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_FISCAL_CLASS_INT',
                              p_fiscal_class_rec.classification_type_code_name,
                              'POS_INVALID_FISCAL_CLASS_NAME',
                              g_user_id,
                              g_login_id,
                              ' Validate_fiscal_classification ') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' ||
                           p_fiscal_class_rec.classification_type_code_name ||
                           ' Acct Validation Msg: ' || l_msg_data);
          END IF;
        END IF;
        fnd_file.put_line(fnd_file.log,
                          ' Invalid Fiscal Classification Code for: ' ||
                          ' p_fiscal_class_rec.classification_type_code_name: ' ||
                          p_fiscal_class_rec.classification_type_code_name);
        RETURN;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside validate_fiscal_classification EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END validate_fiscal_classification;

  PROCEDURE create_fiscal_classification
  (
    p_batch_id         IN NUMBER,
    p_fiscal_class_rec IN pos_fiscal_class_int%ROWTYPE,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
  ) IS
    l_valid               VARCHAR2(100);
    l_classification_type VARCHAR2(100);
    l_classification_code VARCHAR2(100);
    l_return_status       VARCHAR2(10);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(1000);
    l_code_assignment_id  NUMBER;
  BEGIN
    fnd_file.put_line(fnd_file.log, ' Inside create_fiscal_classification');

    x_return_status := fnd_api.g_ret_sts_success;

    validate_fiscal_classification(p_batch_id            => p_batch_id,
                                   p_fiscal_class_rec    => p_fiscal_class_rec,
                                   x_return_status       => l_return_status,
                                   x_msg_count           => l_msg_count,
                                   x_msg_data            => l_msg_data,
                                   x_valid               => l_valid,
                                   x_classification_type => l_classification_type,
                                   x_classification_code => l_classification_code);

    fnd_file.put_line(fnd_file.log,
                      'validate_fiscal_classification l_valid: ' || l_valid ||
                      'l_return_status' || l_return_status);

    IF (l_valid = 'Y') THEN

      hz_code_assignments_pkg.insert_row(x_code_assignment_id    => l_code_assignment_id,
                                         x_owner_table_name      => 'ZX_PARTY_TAX_PROFILE',
                                         x_owner_table_id        => p_fiscal_class_rec.tax_profile_id,
                                         x_owner_table_key_1     => NULL,
                                         x_owner_table_key_2     => NULL,
                                         x_owner_table_key_3     => NULL,
                                         x_owner_table_key_4     => NULL,
                                         x_owner_table_key_5     => NULL,
                                         x_class_category        => l_classification_type,
                                         x_class_code            => l_classification_code,
                                         x_primary_flag          => 'N',
                                         x_content_source_type   => NULL,
                                         x_start_date_active     => p_fiscal_class_rec.effective_from,
                                         x_end_date_active       => p_fiscal_class_rec.effective_to,
                                         x_status                => NULL,
                                         x_object_version_number => NULL,
                                         x_created_by_module     => NULL,
                                         x_rank                  => NULL,
                                         x_application_id        => NULL,
                                         x_actual_content_source => NULL);

      -- The HZ code is so designed that if the status is passed as NULL
      -- then it is set as 'A' and the VO that shows the data for Fiscal
      -- Classifications on the Supplier Profile page ignores these records
      -- So updating the status to NULL
      UPDATE hz_code_assignments
      SET    status = NULL
      WHERE  code_assignment_id = l_code_assignment_id;

    ELSE
      x_return_status := l_return_status;
      x_msg_data      := l_msg_data;
      x_msg_count     := l_msg_count;
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      -- Read the Error buffer returned from the API
      -- Add the error buffer message to supplier rejections
      -- table
      /*IF (insert_rejections(p_batch_id,
                            l_request_id,
                            'POS_FISCAL_CLASS_INT',
                            p_tax_registration_rec.registration_type_code,
                            'AP_INVALID_TAX_REG_INS',
                            g_user_id,
                            g_login_id,
                            ' Create_Tax_Registration ') <> TRUE) THEN

        IF (g_level_procedure >= g_current_runtime_level) THEN
          fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                    p_data  => l_msg_data);
          fnd_log.string(g_level_procedure,
                         g_module_name || 'Create_Tax_Registration',
                         'Msg: ' || l_msg_data);
        END IF;
      END IF;*/
      fnd_file.put_line(fnd_file.log,
                        ' Fiscal Classification validation/creation failed for: ' ||
                        ' fiscal_class_interface_id: ' ||
                        p_fiscal_class_rec.fiscal_class_interface_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside create_fiscal_classification EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END create_fiscal_classification;

  PROCEDURE update_fiscal_classification
  (
    p_batch_id         IN NUMBER,
    p_fiscal_class_rec IN pos_fiscal_class_int%ROWTYPE,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
  ) IS
    l_valid               VARCHAR2(100);
    l_classification_type VARCHAR2(100);
    l_classification_code VARCHAR2(100);
    l_return_status       VARCHAR2(10);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(1000);
    l_code_assignment_id  NUMBER;
    l_rowid               VARCHAR2(100);
  BEGIN
    fnd_file.put_line(fnd_file.log, ' Inside update_fiscal_classification');
    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    validate_fiscal_classification(p_batch_id            => p_batch_id,
                                   p_fiscal_class_rec    => p_fiscal_class_rec,
                                   x_return_status       => l_return_status,
                                   x_msg_count           => l_msg_count,
                                   x_msg_data            => l_msg_data,
                                   x_valid               => l_valid,
                                   x_classification_type => l_classification_type,
                                   x_classification_code => l_classification_code);

    IF (l_valid = 'Y') THEN
      BEGIN
        SELECT code_assignment_id,
               ROWID
        INTO   l_code_assignment_id,
               l_rowid
        FROM   hz_code_assignments
        WHERE  owner_table_name = 'ZX_PARTY_TAX_PROFILE'
        AND    owner_table_id = p_fiscal_class_rec.tax_profile_id
        AND    class_category = l_classification_type;

      EXCEPTION
        WHEN no_data_found THEN
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data      := 'POS_INVALID_FISCAL_CLASS';
          RETURN;
      END;

      hz_code_assignments_pkg.update_row(x_rowid                 => l_rowid,
                                         x_code_assignment_id    => l_code_assignment_id,
                                         x_owner_table_name      => 'ZX_PARTY_TAX_PROFILE',
                                         x_owner_table_id        => p_fiscal_class_rec.tax_profile_id,
                                         x_owner_table_key_1     => NULL,
                                         x_owner_table_key_2     => NULL,
                                         x_owner_table_key_3     => NULL,
                                         x_owner_table_key_4     => NULL,
                                         x_owner_table_key_5     => NULL,
                                         x_class_category        => l_classification_type,
                                         x_class_code            => l_classification_code,
                                         x_primary_flag          => 'N',
                                         x_content_source_type   => NULL,
                                         x_start_date_active     => p_fiscal_class_rec.effective_from,
                                         x_end_date_active       => p_fiscal_class_rec.effective_to,
                                         x_status                => NULL,
                                         x_object_version_number => NULL,
                                         x_created_by_module     => NULL,
                                         x_rank                  => NULL,
                                         x_application_id        => NULL,
                                         x_actual_content_source => NULL);

      -- The HZ code is so designed that if the status is passed as NULL
      -- then it is set as 'A' and the VO that shows the data for Fiscal
      -- Classifications on the Supplier Profile page ignores these records
      -- So updating the status to NULL
      UPDATE hz_code_assignments
      SET    status = NULL
      WHERE  code_assignment_id = l_code_assignment_id;

    ELSE
      x_return_status := l_return_status;
      x_msg_data      := l_msg_data;
      x_msg_count     := l_msg_count;
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      -- Read the Error buffer returned from the API
      -- Add the error buffer message to supplier rejections
      -- table
      /*IF (insert_rejections(p_batch_id,
                            l_request_id,
                            'POS_FISCAL_CLASS_INT',
                            p_tax_registration_rec.registration_type_code,
                            'AP_INVALID_TAX_REG_INS',
                            g_user_id,
                            g_login_id,
                            ' Create_Tax_Registration ') <> TRUE) THEN

        IF (g_level_procedure >= g_current_runtime_level) THEN
          fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                    p_data  => l_msg_data);
          fnd_log.string(g_level_procedure,
                         g_module_name || 'Create_Tax_Registration',
                         'Msg: ' || l_msg_data);
        END IF;
      END IF;*/
      fnd_file.put_line(fnd_file.log,
                        ' Fiscal Classification validation/updation failed for: ' ||
                        ' fiscal_class_interface_id: ' ||
                        p_fiscal_class_rec.fiscal_class_interface_id);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside update_fiscal_classification EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END update_fiscal_classification;

  PROCEDURE import_vendor_tax_dtls
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) AS
    l_request_id NUMBER := fnd_global.conc_request_id;
    l_api_name CONSTANT VARCHAR2(30) := 'IMPORT_VENDOR_TAX_DTLS';
    l_effective_from_date DATE;

    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(2000);

    CURSOR tax_profile_cur IS
      SELECT *
      FROM   pos_party_tax_profile_int supp
      WHERE  batch_id = p_batch_id
      AND    nvl(status, 'ACTIVE') NOT IN ('PROCESSED', 'REMOVED')
      AND    NOT EXISTS
       (SELECT 1
              FROM   hz_imp_parties_int party
              WHERE  batch_id = p_batch_id
              AND    supp.batch_id = party.batch_id
              AND    supp.source_system = party.party_orig_system
              AND    supp.source_system_reference =
                     party.party_orig_system_reference
              AND    party.interface_status = 'R');

    CURSOR tax_reg_cur IS
      SELECT *
      FROM   pos_party_tax_reg_int supp
      WHERE  batch_id = p_batch_id
      AND    nvl(status, 'ACTIVE') NOT IN ('PROCESSED', 'REMOVED')
      AND    NOT EXISTS
       (SELECT 1
              FROM   hz_imp_parties_int party
              WHERE  batch_id = p_batch_id
              AND    supp.batch_id = party.batch_id
              AND    supp.source_system = party.party_orig_system
              AND    supp.source_system_reference =
                     party.party_orig_system_reference
              AND    party.interface_status = 'R');

    CURSOR fiscal_class_cur IS
      SELECT *
      FROM   pos_fiscal_class_int supp
      WHERE  batch_id = p_batch_id
      AND    nvl(status, 'ACTIVE') NOT IN ('PROCESSED', 'REMOVED')
      AND    NOT EXISTS
       (SELECT 1
              FROM   hz_imp_parties_int party
              WHERE  batch_id = p_batch_id
              AND    supp.batch_id = party.batch_id
              AND    supp.source_system = party.party_orig_system
              AND    supp.source_system_reference =
                     party.party_orig_system_reference
              AND    party.interface_status = 'R');

    l_party_id             NUMBER;
    l_tax_profile_id       NUMBER;
    l_tax_reg_id           NUMBER;
    l_party_tax_profile_id NUMBER;
    l_classification_type  VARCHAR2(50);

    TYPE l_tax_profile_rec_tab_typ IS TABLE OF pos_party_tax_profile_int%ROWTYPE;
    l_tax_profile_rec_tab l_tax_profile_rec_tab_typ;

    TYPE l_tax_reg_rec_tab_typ IS TABLE OF pos_party_tax_reg_int%ROWTYPE;
    l_tax_reg_rec_tab l_tax_reg_rec_tab_typ;

    TYPE l_fiscal_class_rec_tab_typ IS TABLE OF pos_fiscal_class_int%ROWTYPE;
    l_fiscal_class_rec_tab l_fiscal_class_rec_tab_typ;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_TAX_DTLS' ||
                      ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                      ' request_id: ' || l_request_id);

    -- This update statement resets the unprocessed rows so
    -- that they get picked in the current run.
    UPDATE pos_party_tax_profile_int api
    SET    request_id = NULL
    WHERE  request_id IS NOT NULL
    AND    batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') IN ('ACTIVE', 'REJECTED')
    AND    EXISTS (SELECT 'Request Completed'
            FROM   fnd_concurrent_requests fcr
            WHERE  fcr.request_id = api.request_id
            AND    fcr.phase_code = 'C');

    UPDATE pos_party_tax_reg_int api
    SET    request_id = NULL
    WHERE  request_id IS NOT NULL
    AND    batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') IN ('ACTIVE', 'REJECTED')
    AND    EXISTS (SELECT 'Request Completed'
            FROM   fnd_concurrent_requests fcr
            WHERE  fcr.request_id = api.request_id
            AND    fcr.phase_code = 'C');

    UPDATE pos_fiscal_class_int api
    SET    request_id = NULL
    WHERE  request_id IS NOT NULL
    AND    batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') IN ('ACTIVE', 'REJECTED')
    AND    EXISTS (SELECT 'Request Completed'
            FROM   fnd_concurrent_requests fcr
            WHERE  fcr.request_id = api.request_id
            AND    fcr.phase_code = 'C');

    -- Updating Interface Record with request id

    UPDATE pos_party_tax_profile_int
    SET    request_id = l_request_id
    WHERE  request_id IS NULL
    AND    batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED';

    UPDATE pos_party_tax_reg_int
    SET    request_id = l_request_id
    WHERE  request_id IS NULL
    AND    batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED';

    UPDATE pos_fiscal_class_int
    SET    request_id = l_request_id
    WHERE  request_id IS NULL
    AND    batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED';

    UPDATE pos_party_tax_profile_int supp
    SET    status     = 'REMOVED',
           request_id = l_request_id
    WHERE  batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED'
    AND    EXISTS (SELECT 1
            FROM   hz_imp_parties_int party
            WHERE  batch_id = p_batch_id
            AND    supp.batch_id = party.batch_id
            AND    supp.source_system = party.party_orig_system
            AND    supp.source_system_reference =
                   party.party_orig_system_reference
            AND    party.interface_status = 'R');

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_TAX_DTLS' ||
                      ' Not imported(marked REMOVED) : ' || SQL%ROWCOUNT ||
                      ' records from table pos_party_tax_profile_int. Reason interface_status in hz_imp_parties_int = R');

    INSERT INTO pos_supplier_int_rejections
      (SELECT p_batch_id,
              l_request_id,
              'POS_PRODUCT_SERVICE_INT',
              tax_profile_interface_id,
              'POS_INVALID_PARTY_ORIG_SYSTEM',
              g_user_id,
              SYSDATE,
              g_login_id,
              g_user_id,
              SYSDATE
       FROM   pos_party_tax_profile_int
       WHERE  status = 'REMOVED'
       AND    request_id = l_request_id
       AND    batch_id = p_batch_id);

    UPDATE pos_party_tax_reg_int supp
    SET    status     = 'REMOVED',
           request_id = l_request_id
    WHERE  batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED'
    AND    EXISTS (SELECT 1
            FROM   hz_imp_parties_int party
            WHERE  batch_id = p_batch_id
            AND    supp.batch_id = party.batch_id
            AND    supp.source_system = party.party_orig_system
            AND    supp.source_system_reference =
                   party.party_orig_system_reference
            AND    party.interface_status = 'R');

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_TAX_DTLS' ||
                      ' Not imported(marked REMOVED) : ' || SQL%ROWCOUNT ||
                      ' records from table pos_party_tax_reg_int. Reason interface_status in hz_imp_parties_int = R');

    INSERT INTO pos_supplier_int_rejections
      (SELECT p_batch_id,
              l_request_id,
              'POS_PRODUCT_SERVICE_INT',
              tax_reg_interface_id,
              'POS_INVALID_PARTY_ORIG_SYSTEM',
              g_user_id,
              SYSDATE,
              g_login_id,
              g_user_id,
              SYSDATE
       FROM   pos_party_tax_reg_int
       WHERE  status = 'REMOVED'
       AND    request_id = l_request_id
       AND    batch_id = p_batch_id);

    UPDATE pos_fiscal_class_int supp
    SET    status     = 'REMOVED',
           request_id = l_request_id
    WHERE  batch_id = p_batch_id
    AND    nvl(status, 'ACTIVE') <> 'PROCESSED'
    AND    EXISTS (SELECT 1
            FROM   hz_imp_parties_int party
            WHERE  batch_id = p_batch_id
            AND    supp.batch_id = party.batch_id
            AND    supp.source_system = party.party_orig_system
            AND    supp.source_system_reference =
                   party.party_orig_system_reference
            AND    party.interface_status = 'R');

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_TAX_DTLS' ||
                      ' Not imported(marked REMOVED) : ' || SQL%ROWCOUNT ||
                      ' records from table pos_fiscal_class_int. Reason interface_status in hz_imp_parties_int = R');

    INSERT INTO pos_supplier_int_rejections
      (SELECT p_batch_id,
              l_request_id,
              'POS_PRODUCT_SERVICE_INT',
              fiscal_class_interface_id,
              'POS_INVALID_PARTY_ORIG_SYSTEM',
              g_user_id,
              SYSDATE,
              g_login_id,
              g_user_id,
              SYSDATE
       FROM   pos_fiscal_class_int
       WHERE  status = 'REMOVED'
       AND    request_id = l_request_id
       AND    batch_id = p_batch_id);

    -- Process Tax Profile
    OPEN tax_profile_cur;
    FETCH tax_profile_cur BULK COLLECT
      INTO l_tax_profile_rec_tab;
    CLOSE tax_profile_cur;

    FOR cntr IN 1 .. l_tax_profile_rec_tab.count LOOP
      IF (l_tax_profile_rec_tab(cntr).party_id IS NULL) THEN
        l_party_id := get_party_id(l_tax_profile_rec_tab(cntr).source_system,
                                   l_tax_profile_rec_tab(cntr)
                                   .source_system_reference);

        l_tax_profile_rec_tab(cntr).party_id := l_party_id;
      END IF;

      IF (l_tax_profile_rec_tab(cntr).insert_update_flag IS NULL) THEN
        BEGIN
          SELECT 'U'
          INTO   l_tax_profile_rec_tab(cntr).insert_update_flag
          FROM   zx_party_tax_profile
          WHERE  party_id = l_tax_profile_rec_tab(cntr).party_id
          AND    party_type_code = 'THIRD_PARTY';

        EXCEPTION
          WHEN no_data_found THEN
            l_tax_profile_rec_tab(cntr).insert_update_flag := 'I';
        END;
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' l_tax_profile_rec_tab(cntr).insert_update_flag: ' || l_tax_profile_rec_tab(cntr)
                        .insert_update_flag);

      create_tax_profile(p_batch_id        => p_batch_id,
                         p_tax_profile_rec => l_tax_profile_rec_tab(cntr),
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         x_tax_profile_id  => l_tax_profile_id);

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE import_vendor_tax_dtls' ||
                         ' l_tax_profile_id: ' || l_tax_profile_id ||
                         ' for tax_profile_interface_id: ' || l_tax_profile_rec_tab(cntr)
                        .tax_profile_interface_id || ' x_return_status: ' ||
                         x_return_status);

      -- Tax Profile Id in the Tax Registrations Interface table
      UPDATE pos_party_tax_reg_int
      SET    tax_profile_id = l_tax_profile_id
      WHERE  tax_profile_interface_id = l_tax_profile_rec_tab(cntr)
            .tax_profile_interface_id
      AND    batch_id = p_batch_id;

      -- Tax Profile Id in the Fiscal Classifications Interface table
      UPDATE pos_fiscal_class_int
      SET    tax_profile_id = l_tax_profile_id
      WHERE  tax_profile_interface_id = l_tax_profile_rec_tab(cntr)
            .tax_profile_interface_id
      AND    batch_id = p_batch_id;

      IF (x_return_status = 'S') THEN
        UPDATE pos_party_tax_profile_int
        SET    status = 'PROCESSED'
        WHERE  tax_profile_interface_id = l_tax_profile_rec_tab(cntr)
              .tax_profile_interface_id
        AND    batch_id = p_batch_id;

        IF (l_tax_profile_rec_tab(cntr).insert_update_flag = 'I') THEN
          UPDATE pos_imp_batch_summary
          SET    total_records_imported = total_records_imported + 1,
                 total_inserts          = total_inserts + 1,
                 tax_dtls_inserted      = tax_dtls_inserted + 1,
                 tax_dtls_imported      = tax_dtls_imported + 1
          WHERE  batch_id = p_batch_id;
        ELSE
          UPDATE pos_imp_batch_summary
          SET    total_records_imported = total_records_imported + 1,
                 total_updates          = total_updates + 1,
                 tax_dtls_updated       = tax_dtls_updated + 1,
                 tax_dtls_imported      = tax_dtls_imported + 1
          WHERE  batch_id = p_batch_id;
        END IF;

      ELSE
        UPDATE pos_party_tax_profile_int
        SET    status = 'REJECTED'
        WHERE  tax_profile_interface_id = l_tax_profile_rec_tab(cntr)
              .tax_profile_interface_id
        AND    batch_id = p_batch_id;

        x_return_status := fnd_api.g_ret_sts_error;

        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_PARTY_TAX_PROFILE_INT',
                              l_tax_profile_rec_tab(cntr)
                              .tax_profile_interface_id,
                              'POS_TAX_PROFILE_CREATION',
                              g_user_id,
                              g_login_id,
                              'import_vendor_tax_dtls') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Vendor_Interface_Id: ' || l_tax_profile_rec_tab(cntr)
                           .tax_profile_interface_id ||
                            ' Tax Profile Creation Msg: ' || l_msg_data);
          END IF;
        END IF;

      END IF;
    END LOOP;

    -- Process Tax registration
    OPEN tax_reg_cur;
    FETCH tax_reg_cur BULK COLLECT
      INTO l_tax_reg_rec_tab;
    CLOSE tax_reg_cur;

    FOR cntr IN 1 .. l_tax_reg_rec_tab.count LOOP
      IF (l_tax_reg_rec_tab(cntr).party_id IS NULL) THEN
        l_party_id := get_party_id(l_tax_reg_rec_tab(cntr).source_system,
                                   l_tax_reg_rec_tab(cntr)
                                   .source_system_reference);

        l_tax_reg_rec_tab(cntr).party_id := l_party_id;
      ELSE
        l_party_id := l_tax_reg_rec_tab(cntr).party_id;
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' l_tax_reg_rec_tab(cntr).party_id : ' || l_tax_reg_rec_tab(cntr)
                        .party_id);

      IF (l_tax_reg_rec_tab(cntr).tax_profile_id IS NULL) THEN
        BEGIN
          SELECT party_tax_profile_id
          INTO   l_tax_profile_id
          FROM   zx_party_tax_profile
          WHERE  party_id = l_party_id
          AND    party_type_code = 'THIRD_PARTY';

          l_tax_reg_rec_tab(cntr).tax_profile_id := l_tax_profile_id;

          fnd_file.put_line(fnd_file.log,
                            ' l_tax_reg_rec_tab(cntr).tax_profile_id : ' || l_tax_reg_rec_tab(cntr)
                            .tax_profile_id);

        EXCEPTION
          WHEN no_data_found THEN
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_data      := 'POS_INVALID_TAX_PROFILE';
            fnd_file.put_line(fnd_file.log, ' POS_INVALID_TAX_PROFILE ');

            GOTO continue_next_record;
        END;
      END IF;

      IF (l_tax_reg_rec_tab(cntr).insert_update_flag IS NULL) THEN
        BEGIN
          -- get the registration id
          SELECT 'U'
          INTO   l_tax_reg_rec_tab(cntr).insert_update_flag
          FROM   zx_registrations
          WHERE  party_tax_profile_id = l_tax_profile_id
          AND    tax_regime_code = l_tax_reg_rec_tab(cntr).tax_regime_code
          AND    SYSDATE BETWEEN effective_from AND
                 nvl(effective_to, SYSDATE);

        EXCEPTION
          WHEN no_data_found THEN
            l_tax_reg_rec_tab(cntr).insert_update_flag := 'I';
        END;
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' l_tax_reg_rec_tab(cntr).insert_update_flag: ' || l_tax_reg_rec_tab(cntr)
                        .insert_update_flag);

      IF (l_tax_reg_rec_tab(cntr).insert_update_flag = 'U') THEN
        BEGIN
          -- get the registration id
          SELECT registration_id,
                 effective_from
          INTO   l_tax_reg_id,
                 l_effective_from_date
          FROM   zx_registrations
          WHERE  party_tax_profile_id = l_tax_profile_id
          AND    tax_regime_code = l_tax_reg_rec_tab(cntr).tax_regime_code
          AND    SYSDATE BETWEEN effective_from AND
                 nvl(effective_to, SYSDATE);

        EXCEPTION
          WHEN no_data_found THEN
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_data      := 'POS_INVALID_TAX_REG';

            GOTO continue_next_record;
        END;

        -- Setting the default from date
        IF (l_tax_reg_rec_tab(cntr).effective_from IS NULL) THEN
          l_tax_reg_rec_tab(cntr).effective_from := l_effective_from_date;
        END IF;

        update_tax_registration(p_batch_id             => p_batch_id,
                                p_registration_id      => l_tax_reg_id,
                                p_tax_registration_rec => l_tax_reg_rec_tab(cntr),
                                x_return_status        => x_return_status,
                                x_msg_count            => x_msg_count,
                                x_msg_data             => x_msg_data);
        IF (x_return_status = 'S') THEN

          UPDATE pos_party_tax_reg_int
          SET    status = 'PROCESSED'
          WHERE  tax_reg_interface_id = l_tax_reg_rec_tab(cntr)
                .tax_reg_interface_id
          AND    batch_id = p_batch_id;

          UPDATE pos_imp_batch_summary
          SET    total_records_imported = total_records_imported + 1,
                 total_updates          = total_updates + 1,
                 tax_dtls_updated       = tax_dtls_updated + 1,
                 tax_dtls_imported      = tax_dtls_imported + 1
          WHERE  batch_id = p_batch_id;
        END IF;
      ELSE
        create_tax_registration(p_batch_id             => p_batch_id,
                                p_tax_registration_rec => l_tax_reg_rec_tab(cntr),
                                x_return_status        => x_return_status,
                                x_msg_count            => x_msg_count,
                                x_msg_data             => x_msg_data);
        fnd_file.put_line(fnd_file.log,
                          ' create_tax_registration  x_return_status: ' ||
                          x_return_status);

        IF (x_return_status = 'S') THEN

          UPDATE pos_party_tax_reg_int
          SET    status = 'PROCESSED'
          WHERE  tax_reg_interface_id = l_tax_reg_rec_tab(cntr)
                .tax_reg_interface_id
          AND    batch_id = p_batch_id;

          UPDATE pos_imp_batch_summary
          SET    total_records_imported = total_records_imported + 1,
                 total_inserts          = total_inserts + 1,
                 tax_dtls_inserted      = tax_dtls_inserted + 1,
                 tax_dtls_imported      = tax_dtls_imported + 1
          WHERE  batch_id = p_batch_id;
        END IF;
      END IF;

      IF (x_return_status <> 'S') THEN

        UPDATE pos_party_tax_reg_int
        SET    status = 'REJECTED'
        WHERE  tax_reg_interface_id = l_tax_reg_rec_tab(cntr)
              .tax_reg_interface_id
        AND    batch_id = p_batch_id;

        x_return_status := fnd_api.g_ret_sts_error;

        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_PARTY_TAX_REG_INT',
                              l_tax_reg_rec_tab(cntr).tax_reg_interface_id,
                              'POS_TAX_REGISTRATION_CREATION',
                              g_user_id,
                              g_login_id,
                              'import_vendor_tax_dtls') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Vendor_Interface_Id: ' || l_tax_reg_rec_tab(cntr)
                           .tax_reg_interface_id ||
                            ' Tax Registration Creation Msg: ' || l_msg_data);
          END IF;
        END IF;
      END IF;
      <<continue_next_record>>
      NULL;
    END LOOP;

    -- Process Fiscal Classification
    OPEN fiscal_class_cur;
    FETCH fiscal_class_cur BULK COLLECT
      INTO l_fiscal_class_rec_tab;
    CLOSE fiscal_class_cur;

    FOR cntr IN 1 .. l_fiscal_class_rec_tab.count LOOP
      IF (l_fiscal_class_rec_tab(cntr).party_id IS NULL) THEN
        l_party_id := get_party_id(l_fiscal_class_rec_tab(cntr)
                                   .source_system,
                                   l_fiscal_class_rec_tab(cntr)
                                   .source_system_reference);

        l_fiscal_class_rec_tab(cntr).party_id := l_party_id;
      ELSE
        l_party_id := l_fiscal_class_rec_tab(cntr).party_id;
      END IF;

      IF (l_fiscal_class_rec_tab(cntr).tax_profile_id IS NULL) THEN
        BEGIN
          SELECT party_tax_profile_id
          INTO   l_tax_profile_id
          FROM   zx_party_tax_profile
          WHERE  party_id = l_party_id
          AND    party_type_code = 'THIRD_PARTY';

          l_fiscal_class_rec_tab(cntr).tax_profile_id := l_tax_profile_id;
        EXCEPTION
          WHEN no_data_found THEN
            UPDATE pos_fiscal_class_int
            SET    status = 'REJECTED'
            WHERE  fiscal_class_interface_id = l_fiscal_class_rec_tab(cntr)
                  .fiscal_class_interface_id
            AND    batch_id = p_batch_id;

            IF (insert_rejections(p_batch_id,
                                  l_request_id,
                                  'POS_FISCAL_CLASS_INT',
                                  l_fiscal_class_rec_tab(cntr)
                                  .fiscal_class_interface_id,
                                  'POS_INVALID_TAX_PROFILE',
                                  g_user_id,
                                  g_login_id,
                                  'import_vendor_tax_dtls') <> TRUE) THEN

              IF (g_level_procedure >= g_current_runtime_level) THEN
                fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                          p_data  => l_msg_data);
                fnd_log.string(g_level_procedure,
                               g_module_name || l_api_name,
                               'Parameters: ' || ' Vendor_Interface_Id: ' || l_fiscal_class_rec_tab(cntr)
                               .fiscal_class_interface_id ||
                                ' Fiscal Classification Creation Msg: ' ||
                                l_msg_data);
              END IF;
            END IF;

            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_data      := 'POS_INVALID_TAX_PROFILE';

            GOTO continue_next_fiscal_class;
        END;
      END IF;

      IF (l_fiscal_class_rec_tab(cntr).insert_update_flag IS NULL) THEN
        BEGIN

          SELECT owner_id_char
          INTO   l_classification_type
          FROM   zx_fc_types_vl
          WHERE  classification_type_categ_code = 'PARTY_FISCAL_CLASS'
          AND    SYSDATE BETWEEN nvl(effective_from, SYSDATE) AND
                 nvl(effective_to, SYSDATE)
          AND    classification_type_code = l_fiscal_class_rec_tab(cntr)
                .classification_type_code_name;

          SELECT 'U'
          INTO   l_fiscal_class_rec_tab(cntr).insert_update_flag
          FROM   hz_code_assignments
          WHERE  owner_table_name = 'ZX_PARTY_TAX_PROFILE'
          AND    owner_table_id = l_fiscal_class_rec_tab(cntr)
                .tax_profile_id
          AND    class_category = l_classification_type;

        EXCEPTION
          WHEN OTHERS THEN
            l_fiscal_class_rec_tab(cntr).insert_update_flag := 'I';
        END;
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' l_fiscal_class_rec_tab(cntr).insert_update_flag: ' || l_fiscal_class_rec_tab(cntr)
                        .insert_update_flag);

      IF (l_fiscal_class_rec_tab(cntr).insert_update_flag = 'I') THEN

        create_fiscal_classification(p_batch_id         => p_batch_id,
                                     p_fiscal_class_rec => l_fiscal_class_rec_tab(cntr),
                                     x_return_status    => x_return_status,
                                     x_msg_count        => x_msg_count,
                                     x_msg_data         => x_msg_data);

        IF (x_return_status = 'S') THEN
          UPDATE pos_fiscal_class_int
          SET    status = 'PROCESSED'
          WHERE  fiscal_class_interface_id = l_fiscal_class_rec_tab(cntr)
                .fiscal_class_interface_id
          AND    batch_id = p_batch_id;

          UPDATE pos_imp_batch_summary
          SET    total_records_imported = total_records_imported + 1,
                 total_inserts          = total_inserts + 1,
                 tax_dtls_inserted      = tax_dtls_inserted + 1,
                 tax_dtls_imported      = tax_dtls_imported + 1
          WHERE  batch_id = p_batch_id;
        END IF;
      ELSE
        update_fiscal_classification(p_batch_id         => p_batch_id,
                                     p_fiscal_class_rec => l_fiscal_class_rec_tab(cntr),
                                     x_return_status    => x_return_status,
                                     x_msg_count        => x_msg_count,
                                     x_msg_data         => x_msg_data);
        IF (x_return_status = 'S') THEN
          UPDATE pos_fiscal_class_int
          SET    status = 'PROCESSED'
          WHERE  fiscal_class_interface_id = l_fiscal_class_rec_tab(cntr)
                .fiscal_class_interface_id
          AND    batch_id = p_batch_id;

          UPDATE pos_imp_batch_summary
          SET    total_records_imported = total_records_imported + 1,
                 total_updates          = total_updates + 1,
                 tax_dtls_updated       = tax_dtls_updated + 1,
                 tax_dtls_imported      = tax_dtls_imported + 1
          WHERE  batch_id = p_batch_id;
        END IF;

      END IF;

      IF (x_return_status <> 'S') THEN
        UPDATE pos_fiscal_class_int
        SET    status = 'REJECTED'
        WHERE  fiscal_class_interface_id = l_fiscal_class_rec_tab(cntr)
              .fiscal_class_interface_id
        AND    batch_id = p_batch_id;

        x_return_status := fnd_api.g_ret_sts_error;

        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_FISCAL_CLASS_INT',
                              l_fiscal_class_rec_tab(cntr)
                              .fiscal_class_interface_id,
                              'POS_FISCAL_CLASS_CREATION',
                              g_user_id,
                              g_login_id,
                              'import_vendor_tax_dtls') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Vendor_Interface_Id: ' || l_fiscal_class_rec_tab(cntr)
                           .fiscal_class_interface_id ||
                            ' Fiscal Classification Creation Msg: ' ||
                            l_msg_data);
          END IF;
        END IF;
      END IF;
      <<continue_next_fiscal_class>>
      NULL;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_tax_dtls EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END import_vendor_tax_dtls;

  PROCEDURE import_vendor_bank_dtls
  (
    p_batch_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    CURSOR bank_account_dtls_cur IS
      SELECT *
      FROM   pos_bank_account_det_int supp
      WHERE  batch_id = p_batch_id
      AND    nvl(interface_status, 'ACTIVE') NOT IN
             ('PROCESSED', 'REMOVED')
      AND    NOT EXISTS
       (SELECT 1
              FROM   hz_imp_parties_int party
              WHERE  batch_id = p_batch_id
              AND    supp.batch_id = party.batch_id
              AND    supp.source_system = party.party_orig_system
              AND    supp.source_system_reference =
                     party.party_orig_system_reference
              AND    party.interface_status = 'R');

    CURSOR account_owners_cur IS
      SELECT *
      FROM   pos_bank_accnt_owners_int supp
      WHERE  batch_id = p_batch_id
      AND    nvl(interface_status, 'ACTIVE') NOT IN
             ('PROCESSED', 'REMOVED')
      AND    NOT EXISTS
       (SELECT 1
              FROM   hz_imp_parties_int party
              WHERE  batch_id = p_batch_id
              AND    supp.batch_id = party.batch_id
              AND    supp.source_system = party.party_orig_system
              AND    supp.source_system_reference =
                     party.party_orig_system_reference
              AND    party.interface_status = 'R');

    bank_account_dtls_rec bank_account_dtls_cur%ROWTYPE;
    account_owners_rec    pos_bank_accnt_owners_int%ROWTYPE;
    l_party_id            NUMBER;

    l_ret_status VARCHAR2(40);
    l_msg_count  NUMBER;
    l_msg_data   VARCHAR2(2000);

    ---Bug 11819545
    l_assign_id         NUMBER;
    l_payee_context_rec      IBY_DISBURSEMENT_SETUP_PUB.PayeeContext_rec_type;
    l_assign   IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
    l_payment_function  CONSTANT VARCHAR2(30)   :=  'PAYABLES_DISB';
    l_instrument_type   CONSTANT VARCHAR2(30)   :=  'BANKACCOUNT';

    l_supp_site_id      NUMBER;
    l_org_id            NUMBER;
    L_PARTY_SITE_STATUS VARCHAR2(1);
    ---Bug 11819545

    l_bank_id                NUMBER;
    l_branch_id              NUMBER;
    l_account_id             NUMBER;
    l_intermediary1_acct_id  NUMBER;
    l_intermediary2_acct_id  NUMBER;
    l_account_owner_id       NUMBER;
    l_joint_account_owner_id NUMBER;
    l_obj_version            NUMBER;
    l_party_site_id          NUMBER;
    l_vendor_site_id         NUMBER;
    l_org_type               VARCHAR2(100);

    l_bank_end_date      DATE;
    l_branch_end_date    DATE;
    l_account_start_date DATE;
    l_account_end_date   DATE;

    l_bank_rowid   VARCHAR2(100);
    l_branch_rowid VARCHAR2(100);

    l_check_bank_resp    iby_fndcpt_common_pub.result_rec_type;
    l_check_branch_resp  iby_fndcpt_common_pub.result_rec_type;
    l_check_account_resp iby_fndcpt_common_pub.result_rec_type;

    l_create_bank_resp           iby_fndcpt_common_pub.result_rec_type;
    l_create_branch_resp         iby_fndcpt_common_pub.result_rec_type;
    l_create_account_resp        iby_fndcpt_common_pub.result_rec_type;
    l_set_bank_end_date_resp     iby_fndcpt_common_pub.result_rec_type;
    l_set_branch_end_date_resp   iby_fndcpt_common_pub.result_rec_type;
    l_add_intermed_account1_resp iby_fndcpt_common_pub.result_rec_type;

    l_add_account_owner_resp iby_fndcpt_common_pub.result_rec_type;
    l_set_end_date_resp      iby_fndcpt_common_pub.result_rec_type;
    l_set_primary_flag_resp  iby_fndcpt_common_pub.result_rec_type;

    l_new_bank_rec           iby_ext_bankacct_pub.extbank_rec_type;
    l_new_branch_rec         iby_ext_bankacct_pub.extbankbranch_rec_type;
    l_new_account_rec        iby_ext_bankacct_pub.extbankacct_rec_type;
    l_new_intermed_acct1_rec iby_ext_bankacct_pub.intermediaryacct_rec_type;
    l_new_intermed_acct2_rec iby_ext_bankacct_pub.intermediaryacct_rec_type;

    l_association_level VARCHAR2(10);

    l_request_id NUMBER := fnd_global.conc_request_id;
    l_api_name CONSTANT VARCHAR2(30) := 'IMPORT_VENDOR_BANK_DTLS';
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                      ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                      ' request_id: ' || l_request_id);

    -- This update statement resets the unprocessed rows so
    -- that they get picked in the current run.
    UPDATE pos_bank_account_det_int api
    SET    request_id = NULL
    WHERE  request_id IS NOT NULL
    AND    batch_id = p_batch_id
    AND    nvl(interface_status, 'ACTIVE') IN ('ACTIVE', 'REJECTED')
    AND    EXISTS (SELECT 'Request Completed'
            FROM   fnd_concurrent_requests fcr
            WHERE  fcr.request_id = api.request_id
            AND    fcr.phase_code = 'C');

    UPDATE pos_bank_accnt_owners_int api
    SET    request_id = NULL
    WHERE  request_id IS NOT NULL
    AND    batch_id = p_batch_id
    AND    nvl(interface_status, 'ACTIVE') IN ('ACTIVE', 'REJECTED')
    AND    EXISTS (SELECT 'Request Completed'
            FROM   fnd_concurrent_requests fcr
            WHERE  fcr.request_id = api.request_id
            AND    fcr.phase_code = 'C');

    -- Updating Interface Record with request id

    UPDATE pos_bank_account_det_int
    SET    request_id = l_request_id
    WHERE  request_id IS NULL
    AND    batch_id = p_batch_id
    AND    nvl(interface_status, 'ACTIVE') <> 'PROCESSED';

    UPDATE pos_bank_accnt_owners_int
    SET    request_id = l_request_id
    WHERE  request_id IS NULL
    AND    batch_id = p_batch_id
    AND    nvl(interface_status, 'ACTIVE') <> 'PROCESSED';

    UPDATE pos_bank_account_det_int supp
    SET    interface_status = 'REMOVED',
           request_id       = l_request_id
    WHERE  batch_id = p_batch_id
    AND    nvl(interface_status, 'ACTIVE') <> 'PROCESSED'
    AND    EXISTS (SELECT 1
            FROM   hz_imp_parties_int party
            WHERE  batch_id = p_batch_id
            AND    supp.batch_id = party.batch_id
            AND    supp.source_system = party.party_orig_system
            AND    supp.source_system_reference =
                   party.party_orig_system_reference
            AND    party.interface_status = 'R');

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                      ' Not imported(marked REMOVED) : ' || SQL%ROWCOUNT ||
                      ' records from table pos_bank_account_det_int. Reason interface_status in hz_imp_parties_int = R');

    INSERT INTO pos_supplier_int_rejections
      (SELECT p_batch_id,
              l_request_id,
              'POS_BANK_ACCOUNT_DET_INT',
              bank_account_interface_id,
              'POS_INVALID_PARTY_ORIG_SYSTEM',
              g_user_id,
              SYSDATE,
              g_login_id,
              g_user_id,
              SYSDATE
       FROM   pos_bank_account_det_int
       WHERE  interface_status = 'REMOVED'
       AND    request_id = l_request_id
       AND    batch_id = p_batch_id);

    UPDATE pos_bank_accnt_owners_int supp
    SET    interface_status = 'REMOVED',
           request_id       = l_request_id
    WHERE  batch_id = p_batch_id
    AND    nvl(interface_status, 'ACTIVE') <> 'PROCESSED'
    AND    EXISTS (SELECT 1
            FROM   hz_imp_parties_int party
            WHERE  batch_id = p_batch_id
            AND    supp.batch_id = party.batch_id
            AND    supp.source_system = party.party_orig_system
            AND    supp.source_system_reference =
                   party.party_orig_system_reference
            AND    party.interface_status = 'R');

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                      ' Not imported(marked REMOVED) : ' || SQL%ROWCOUNT ||
                      ' records from table pos_bank_accnt_owners_int. Reason interface_status in hz_imp_parties_int = R');

    INSERT INTO pos_supplier_int_rejections
      (SELECT p_batch_id,
              l_request_id,
              'POS_BANK_ACCNT_OWNERS_INT',
              bank_acct_owner_interface_id,
              'POS_INVALID_PARTY_ORIG_SYSTEM',
              g_user_id,
              SYSDATE,
              g_login_id,
              g_user_id,
              SYSDATE
       FROM   pos_bank_accnt_owners_int
       WHERE  interface_status = 'REMOVED'
       AND    request_id = l_request_id
       AND    batch_id = p_batch_id);

    OPEN bank_account_dtls_cur;
    LOOP
      -- Fetch the cursor data into a record
      FETCH bank_account_dtls_cur
        INTO bank_account_dtls_rec;
      EXIT WHEN bank_account_dtls_cur%NOTFOUND;

      -- Initializing the local variables
      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside import_vendor_bank_dtls initializing local variables ');

      l_bank_id                := NULL;
      l_branch_id              := NULL;
      l_account_id             := NULL;
      l_intermediary1_acct_id  := NULL;
      l_intermediary2_acct_id  := NULL;
      l_account_owner_id       := NULL;
      l_joint_account_owner_id := NULL;
      l_obj_version            := NULL;
      l_party_site_id          := NULL;
      l_vendor_site_id         := NULL;
      l_org_type               := NULL;
      l_association_level      := NULL;
      l_bank_end_date          := NULL;
      l_branch_end_date        := NULL;
      l_account_start_date     := NULL;
      l_account_end_date       := NULL;
      l_bank_rowid             := NULL;
      l_branch_rowid           := NULL;

      -- fetch the party id
      IF (bank_account_dtls_rec.party_id IS NULL) THEN
        l_party_id := get_party_id(bank_account_dtls_rec.source_system,
                                   bank_account_dtls_rec.source_system_reference);
      ELSE
        l_party_id := bank_account_dtls_rec.party_id;
      END IF;

      -- Check if the bank exists
      -- This API would return the bank_id
      -- an OUT param
      iby_ext_bankacct_pub.check_bank_exist(p_api_version   => 1,
                                            p_init_msg_list => fnd_api.g_true,
                                            p_country_code  => bank_account_dtls_rec.country_code,
                                            p_bank_name     => bank_account_dtls_rec.bank_name,
                                            p_bank_number   => bank_account_dtls_rec.bank_number,
                                            x_return_status => l_ret_status,
                                            x_msg_count     => l_msg_count,
                                            x_msg_data      => l_msg_data,
                                            x_bank_id       => l_bank_id,
                                            x_end_date      => l_bank_end_date,
                                            x_response      => l_check_bank_resp);

      x_return_status := l_ret_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;

      IF l_ret_status <> fnd_api.g_ret_sts_success THEN
        UPDATE pos_bank_account_det_int
        SET    interface_status = 'REJECTED'
        WHERE  bank_account_interface_id =
               bank_account_dtls_rec.bank_account_interface_id
        AND    batch_id = p_batch_id;

        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_BANK_ACCOUNT_DET_INT',
                              bank_account_dtls_rec.bank_account_interface_id,
                              'POS_INVALID_BANK_INFO',
                              g_user_id,
                              g_login_id,
                              'IMPORT_VENDOR_BANK_DTLS') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Interface_Id: ' ||
                           bank_account_dtls_rec.bank_account_interface_id ||
                           ' Check if the bank exists Msg: ' || l_msg_data);
          END IF;
        END IF;
        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                          ' failed in iby_ext_bankacct_pub.check_bank_exist ' ||
                          ' Interface_Id: ' ||
                          bank_account_dtls_rec.bank_account_interface_id ||
                          ', No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data);
        GOTO continue_next_record;
      END IF;

      l_new_bank_rec.bank_name        := bank_account_dtls_rec.bank_name;
      l_new_bank_rec.bank_number      := bank_account_dtls_rec.bank_number;
      l_new_bank_rec.institution_type := bank_account_dtls_rec.bank_inst_type;
      l_new_bank_rec.country_code     := bank_account_dtls_rec.country_code;
      l_new_bank_rec.bank_alt_name    := bank_account_dtls_rec.alt_bank_name;
      l_new_bank_rec.description      := bank_account_dtls_rec.bank_description;

      fnd_file.put_line(fnd_file.log,
                        ' Message: After check_bank_exist' || ' Bank Id :' ||
                        l_bank_id);

      IF (l_bank_id IS NULL) THEN
        -- bank doesn't exist so CREATE
        fnd_file.put_line(fnd_file.log, ' Going for bank creation');
        iby_ext_bankacct_pub. create_ext_bank(p_api_version   => 1,
                                              p_init_msg_list => fnd_api.g_true,
                                              p_ext_bank_rec  => l_new_bank_rec,
                                              x_bank_id       => l_bank_id,
                                              x_return_status => l_ret_status,
                                              x_msg_count     => l_msg_count,
                                              x_msg_data      => l_msg_data,
                                              x_response      => l_create_bank_resp);

        x_return_status := l_ret_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
      ELSIF (l_bank_id IS NOT NULL) THEN
        -- Update
        fnd_file.put_line(fnd_file.log, ' Going for bank update');
        l_new_bank_rec.bank_id := l_bank_id;

        --getting the object version number
        SELECT object_version_number
        INTO   l_new_bank_rec.object_version_number
        FROM   hz_parties
        WHERE  party_id = l_bank_id;

        iby_ext_bankacct_pub.update_ext_bank(p_api_version   => 1,
                                             p_init_msg_list => fnd_api.g_true,
                                             p_ext_bank_rec  => l_new_bank_rec,
                                             x_return_status => l_ret_status,
                                             x_msg_count     => l_msg_count,
                                             x_msg_data      => l_msg_data,
                                             x_response      => l_create_bank_resp);

        x_return_status := l_ret_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
      ELSE
        l_ret_status := fnd_api.g_ret_sts_error;

        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                          ' failed in iby_ext_bankacct_pub.create/update_ext_bank' ||
                          ' Interface_Id: ' ||
                          bank_account_dtls_rec.bank_account_interface_id ||
                          ', No. of Messages: ' || l_msg_count ||
                          ', Message: Bank doesnt exist');
      END IF;

      -- this would also return the generated bank_id.
      IF l_ret_status <> fnd_api.g_ret_sts_success THEN
        UPDATE pos_bank_account_det_int
        SET    interface_status = 'REJECTED'
        WHERE  bank_account_interface_id =
               bank_account_dtls_rec.bank_account_interface_id
        AND    batch_id = p_batch_id;

        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_BANK_ACCOUNT_DET_INT',
                              bank_account_dtls_rec.bank_account_interface_id,
                              'POS_INVALID_BANK_INFO',
                              g_user_id,
                              g_login_id,
                              'IMPORT_VENDOR_BANK_DTLS') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Interface_Id: ' ||
                           bank_account_dtls_rec.bank_account_interface_id ||
                           ' bank creation Msg: ' || l_msg_data);
          END IF;
        END IF;
        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                          ' failed in iby_ext_bankacct_pub.create/update_ext_bank ' ||
                          ' Interface_Id: ' ||
                          bank_account_dtls_rec.bank_account_interface_id ||
                          ', No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data);
        GOTO continue_next_record;
      END IF;

      IF l_bank_id IS NOT NULL THEN
        fnd_file.put_line(fnd_file.log, ' Message: Bank Id :' || l_bank_id);
        -- Update the interface table with the
        -- bank_id that is obtained
        UPDATE pos_bank_account_det_int
        SET    bank_id = l_bank_id
        WHERE  bank_account_interface_id =
               bank_account_dtls_rec.bank_account_interface_id
        AND    batch_id = p_batch_id;

        SELECT ROWID
        INTO   l_bank_rowid
        FROM   hz_parties
        WHERE  party_id = l_bank_id;

        -- Update the other bank details
        hz_parties_pkg.update_row(x_rowid                      => l_bank_rowid,
                                  x_party_id                   => l_bank_id,
                                  x_party_number               => NULL,
                                  x_party_name                 => NULL,
                                  x_party_type                 => NULL,
                                  x_validated_flag             => NULL,
                                  x_attribute_category         => NULL,
                                  x_attribute1                 => NULL,
                                  x_attribute2                 => NULL,
                                  x_attribute3                 => NULL,
                                  x_attribute4                 => NULL,
                                  x_attribute5                 => NULL,
                                  x_attribute6                 => NULL,
                                  x_attribute7                 => NULL,
                                  x_attribute8                 => NULL,
                                  x_attribute9                 => NULL,
                                  x_attribute10                => NULL,
                                  x_attribute11                => NULL,
                                  x_attribute12                => NULL,
                                  x_attribute13                => NULL,
                                  x_attribute14                => NULL,
                                  x_attribute15                => NULL,
                                  x_attribute16                => NULL,
                                  x_attribute17                => NULL,
                                  x_attribute18                => NULL,
                                  x_attribute19                => NULL,
                                  x_attribute20                => NULL,
                                  x_attribute21                => NULL,
                                  x_attribute22                => NULL,
                                  x_attribute23                => NULL,
                                  x_attribute24                => NULL,
                                  x_orig_system_reference      => NULL,
                                  x_sic_code                   => NULL,
                                  x_hq_branch_ind              => NULL,
                                  x_customer_key               => NULL,
                                  x_tax_reference              => NULL,
                                  x_jgzz_fiscal_code           => NULL,
                                  x_person_pre_name_adjunct    => NULL,
                                  x_person_first_name          => NULL,
                                  x_person_middle_name         => NULL,
                                  x_person_last_name           => NULL,
                                  x_person_name_suffix         => NULL,
                                  x_person_title               => NULL,
                                  x_person_academic_title      => NULL,
                                  x_person_previous_last_name  => NULL,
                                  x_known_as                   => NULL,
                                  x_person_iden_type           => NULL,
                                  x_person_identifier          => NULL,
                                  x_group_type                 => NULL,
                                  x_country                    => NULL,
                                  x_address1                   => bank_account_dtls_rec.bank_address_line1,
                                  x_address2                   => bank_account_dtls_rec.bank_address_line2,
                                  x_address3                   => bank_account_dtls_rec.bank_address_line3,
                                  x_address4                   => NULL,
                                  x_city                       => bank_account_dtls_rec.bank_city,
                                  x_postal_code                => bank_account_dtls_rec.bank_zip,
                                  x_state                      => bank_account_dtls_rec.bank_state,
                                  x_province                   => NULL,
                                  x_status                     => NULL,
                                  x_county                     => NULL,
                                  x_sic_code_type              => NULL,
                                  x_url                        => NULL,
                                  x_email_address              => NULL,
                                  x_analysis_fy                => NULL,
                                  x_fiscal_yearend_month       => NULL,
                                  x_employees_total            => NULL,
                                  x_curr_fy_potential_revenue  => NULL,
                                  x_next_fy_potential_revenue  => NULL,
                                  x_year_established           => NULL,
                                  x_gsa_indicator_flag         => NULL,
                                  x_mission_statement          => NULL,
                                  x_organization_name_phonetic => NULL,
                                  x_person_first_name_phonetic => NULL,
                                  x_person_last_name_phonetic  => NULL,
                                  x_language_name              => NULL,
                                  x_category_code              => NULL,
                                  x_salutation                 => NULL,
                                  x_known_as2                  => NULL,
                                  x_known_as3                  => NULL,
                                  x_known_as4                  => NULL,
                                  x_known_as5                  => NULL,
                                  x_object_version_number      => NULL,
                                  x_duns_number_c              => NULL,
                                  x_created_by_module          => NULL,
                                  x_application_id             => NULL);

        -- Update bank end date
        IF (bank_account_dtls_rec.bank_end_date IS NOT NULL) THEN
          iby_ext_bankacct_pub.set_bank_end_date(p_api_version   => 1.0,
                                                 p_init_msg_list => fnd_api.g_true,
                                                 p_bank_id       => l_bank_id,
                                                 p_end_date      => bank_account_dtls_rec.bank_end_date,
                                                 x_return_status => l_ret_status,
                                                 x_msg_count     => l_msg_count,
                                                 x_msg_data      => l_msg_data,
                                                 x_response      => l_set_bank_end_date_resp);

          x_return_status := l_ret_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;

          IF l_ret_status <> fnd_api.g_ret_sts_success THEN
            UPDATE pos_bank_account_det_int
            SET    interface_status = 'REJECTED'
            WHERE  bank_account_interface_id =
                   bank_account_dtls_rec.bank_account_interface_id
            AND    batch_id = p_batch_id;

            IF (insert_rejections(p_batch_id,
                                  l_request_id,
                                  'POS_BANK_ACCOUNT_DET_INT',
                                  bank_account_dtls_rec.bank_account_interface_id,
                                  'POS_FAILED_BANK_END_DATE',
                                  g_user_id,
                                  g_login_id,
                                  'IMPORT_VENDOR_BANK_DTLS') <> TRUE) THEN

              IF (g_level_procedure >= g_current_runtime_level) THEN
                fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                          p_data  => l_msg_data);
                fnd_log.string(g_level_procedure,
                               g_module_name || l_api_name,
                               'Parameters: ' || ' Interface_Id: ' ||
                               bank_account_dtls_rec.bank_account_interface_id ||
                               ' Update bank end date: ' || l_msg_data);
              END IF;
            END IF;
            fnd_file.put_line(fnd_file.log,
                              ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                              ' failed in iby_ext_bankacct_pub.set_bank_end_date ' ||
                              ' Interface_Id: ' ||
                              bank_account_dtls_rec.bank_account_interface_id ||
                              ', No. of Messages: ' || l_msg_count ||
                              ', Message: ' || l_msg_data);
            GOTO continue_next_record;
          END IF;

        END IF;
      END IF;

      -- Check if the branch exists
      -- This API would return the branch_id an OUT param
      iby_ext_bankacct_pub.check_ext_bank_branch_exist(p_api_version   => 1,
                                                       p_init_msg_list => fnd_api.g_true,
                                                       p_bank_id       => l_bank_id,
                                                       p_branch_name   => bank_account_dtls_rec.branch_name,
                                                       p_branch_number => bank_account_dtls_rec.branch_number,
                                                       x_return_status => l_ret_status,
                                                       x_msg_count     => l_msg_count,
                                                       x_msg_data      => l_msg_data,
                                                       x_branch_id     => l_branch_id,
                                                       x_end_date      => l_branch_end_date,
                                                       x_response      => l_check_branch_resp);

      x_return_status := l_ret_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;

      IF l_ret_status <> fnd_api.g_ret_sts_success THEN
        UPDATE pos_bank_account_det_int
        SET    interface_status = 'REJECTED'
        WHERE  bank_account_interface_id =
               bank_account_dtls_rec.bank_account_interface_id
        AND    batch_id = p_batch_id;

        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_BANK_ACCOUNT_DET_INT',
                              bank_account_dtls_rec.bank_account_interface_id,
                              'POS_INVALID_BRANCH_INFO',
                              g_user_id,
                              g_login_id,
                              'IMPORT_VENDOR_BANK_DTLS') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Interface_Id: ' ||
                           bank_account_dtls_rec.bank_account_interface_id ||
                           ' Update bank end date: ' || l_msg_data);
          END IF;
        END IF;
        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                          ' failed in iby_ext_bankacct_pub.check_ext_bank_branch_exist' ||
                          ' Interface_Id: ' ||
                          bank_account_dtls_rec.bank_account_interface_id ||
                          ', No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data);
        GOTO continue_next_record;
      END IF;

      l_new_branch_rec.branch_name           := bank_account_dtls_rec.branch_name;
      l_new_branch_rec.branch_number         := bank_account_dtls_rec.branch_number;
      l_new_branch_rec.bank_party_id         := l_bank_id;
      l_new_branch_rec.branch_type           := bank_account_dtls_rec.branch_type;
      l_new_branch_rec.alternate_branch_name := bank_account_dtls_rec.alt_branch_name;
      l_new_branch_rec.description           := bank_account_dtls_rec.branch_description;
      l_new_branch_rec.bic                   := bank_account_dtls_rec.bic;
      l_new_branch_rec.rfc_identifier        := bank_account_dtls_rec.branch_rfc_identifier;

      fnd_file.put_line(fnd_file.log,
                        ' Message: After check_branch_exist' ||
                        ' Branch Id :' || l_branch_id);

      IF (l_branch_id IS NULL) THEN
        -- branch doesn't exist so CREATE
        fnd_file.put_line(fnd_file.log,
                          ' Message: Going for branch creation');
        iby_ext_bankacct_pub.create_ext_bank_branch(p_api_version         => 1,
                                                    p_init_msg_list       => fnd_api.g_true,
                                                    p_ext_bank_branch_rec => l_new_branch_rec,
                                                    x_branch_id           => l_branch_id,
                                                    x_return_status       => l_ret_status,
                                                    x_msg_count           => l_msg_count,
                                                    x_msg_data            => l_msg_data,
                                                    x_response            => l_create_branch_resp);

        x_return_status := l_ret_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
      ELSIF (l_branch_id IS NOT NULL) THEN
        l_new_branch_rec.branch_party_id := l_branch_id;

        fnd_file.put_line(fnd_file.log,
                          ' Message: Going for branch update');

        --getting the object version number
        /*SELECT object_version_number
        INTO   l_new_branch_rec.bch_object_version_number
        FROM   iby_ext_bank_branches_v
        WHERE  branch_party_id = l_branch_id;*/

        SELECT object_version_number
        INTO   l_new_branch_rec.bch_object_version_number
        FROM   hz_parties
        WHERE  party_id = l_branch_id;

        --Getting Bank Branch Type Object Version Number
        BEGIN
          SELECT hca.object_version_number
          INTO   l_new_branch_rec.typ_object_version_number
          FROM   hz_code_assignments hca
          WHERE  hca.class_category = 'BANK_BRANCH_TYPE'
          AND    hca.owner_table_name = 'HZ_PARTIES'
          AND    hca.owner_table_id = l_branch_id
                --AND  hca.primary_flag='Y'
          AND    SYSDATE BETWEEN start_date_active AND
                 nvl(end_date_active, SYSDATE + 1)
          AND    hca.status = 'A';

        EXCEPTION
          WHEN no_data_found THEN
            l_new_branch_rec.typ_object_version_number := 1;
        END;

        fnd_file.put_line(fnd_file.log,
                          ' l_new_branch_rec.typ_object_version_number: ' ||
                          l_new_branch_rec.typ_object_version_number);

        fnd_file.put_line(fnd_file.log,
                          ' l_new_branch_rec.bch_object_version_number: ' ||
                          l_new_branch_rec.bch_object_version_number);

        iby_ext_bankacct_pub.update_ext_bank_branch(p_api_version         => 1,
                                                    p_init_msg_list       => fnd_api.g_true,
                                                    p_ext_bank_branch_rec => l_new_branch_rec,
                                                    x_return_status       => l_ret_status,
                                                    x_msg_count           => l_msg_count,
                                                    x_msg_data            => l_msg_data,
                                                    x_response            => l_create_branch_resp);

        x_return_status := l_ret_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
      ELSE
        l_ret_status := fnd_api.g_ret_sts_error;

        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                          ' failed in iby_ext_bankacct_pub.create/update_ext_bank_branch' ||
                          ' Interface_Id: ' ||
                          bank_account_dtls_rec.bank_account_interface_id ||
                          ', No. of Messages: ' || l_msg_count ||
                          ', Message: Branch doesnt exist');
      END IF;
      -- this would also return the generated branch_id.

      IF l_ret_status <> fnd_api.g_ret_sts_success THEN
        UPDATE pos_bank_account_det_int
        SET    interface_status = 'REJECTED'
        WHERE  bank_account_interface_id =
               bank_account_dtls_rec.bank_account_interface_id
        AND    batch_id = p_batch_id;

        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_BANK_ACCOUNT_DET_INT',
                              bank_account_dtls_rec.bank_account_interface_id,
                              'POS_INVALID_BRANCH_INFO',
                              g_user_id,
                              g_login_id,
                              'IMPORT_VENDOR_BANK_DTLS') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Interface_Id: ' ||
                           bank_account_dtls_rec.bank_account_interface_id ||
                           ' Update bank end date: ' || l_msg_data);
          END IF;
        END IF;

        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                          ' failed in iby_ext_bankacct_pub.create/update_ext_bank_branch' ||
                          ' Interface_Id: ' ||
                          bank_account_dtls_rec.bank_account_interface_id ||
                          ', No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data);
        GOTO continue_next_record;
      END IF;

      IF (l_branch_id IS NOT NULL) THEN
        fnd_file.put_line(fnd_file.log,
                          ' Message: Updating branch id ' || ' Branch Id :' ||
                          l_branch_id);
        -- Update the interface table with the branch_id that is obtained
        UPDATE pos_bank_account_det_int
        SET    branch_id = l_branch_id
        WHERE  bank_account_interface_id =
               bank_account_dtls_rec.bank_account_interface_id
        AND    batch_id = p_batch_id;

        SELECT ROWID
        INTO   l_branch_rowid
        FROM   hz_parties
        WHERE  party_id = l_branch_id;

        -- Update the other branch details
        hz_parties_pkg.update_row(x_rowid                      => l_branch_rowid,
                                  x_party_id                   => l_branch_id,
                                  x_party_number               => NULL,
                                  x_party_name                 => NULL,
                                  x_party_type                 => NULL,
                                  x_validated_flag             => NULL,
                                  x_attribute_category         => NULL,
                                  x_attribute1                 => NULL,
                                  x_attribute2                 => NULL,
                                  x_attribute3                 => NULL,
                                  x_attribute4                 => NULL,
                                  x_attribute5                 => NULL,
                                  x_attribute6                 => NULL,
                                  x_attribute7                 => NULL,
                                  x_attribute8                 => NULL,
                                  x_attribute9                 => NULL,
                                  x_attribute10                => NULL,
                                  x_attribute11                => NULL,
                                  x_attribute12                => NULL,
                                  x_attribute13                => NULL,
                                  x_attribute14                => NULL,
                                  x_attribute15                => NULL,
                                  x_attribute16                => NULL,
                                  x_attribute17                => NULL,
                                  x_attribute18                => NULL,
                                  x_attribute19                => NULL,
                                  x_attribute20                => NULL,
                                  x_attribute21                => NULL,
                                  x_attribute22                => NULL,
                                  x_attribute23                => NULL,
                                  x_attribute24                => NULL,
                                  x_orig_system_reference      => NULL,
                                  x_sic_code                   => NULL,
                                  x_hq_branch_ind              => NULL,
                                  x_customer_key               => NULL,
                                  x_tax_reference              => NULL,
                                  x_jgzz_fiscal_code           => NULL,
                                  x_person_pre_name_adjunct    => NULL,
                                  x_person_first_name          => NULL,
                                  x_person_middle_name         => NULL,
                                  x_person_last_name           => NULL,
                                  x_person_name_suffix         => NULL,
                                  x_person_title               => NULL,
                                  x_person_academic_title      => NULL,
                                  x_person_previous_last_name  => NULL,
                                  x_known_as                   => NULL,
                                  x_person_iden_type           => NULL,
                                  x_person_identifier          => NULL,
                                  x_group_type                 => NULL,
                                  x_country                    => NULL,
                                  x_address1                   => bank_account_dtls_rec.branch_address_line1,
                                  x_address2                   => bank_account_dtls_rec.branch_address_line2,
                                  x_address3                   => bank_account_dtls_rec.branch_address_line3,
                                  x_address4                   => NULL,
                                  x_city                       => bank_account_dtls_rec.branch_city,
                                  x_postal_code                => bank_account_dtls_rec.branch_zip,
                                  x_state                      => bank_account_dtls_rec.branch_state,
                                  x_province                   => NULL,
                                  x_status                     => NULL,
                                  x_county                     => NULL,
                                  x_sic_code_type              => NULL,
                                  x_url                        => NULL,
                                  x_email_address              => NULL,
                                  x_analysis_fy                => NULL,
                                  x_fiscal_yearend_month       => NULL,
                                  x_employees_total            => NULL,
                                  x_curr_fy_potential_revenue  => NULL,
                                  x_next_fy_potential_revenue  => NULL,
                                  x_year_established           => NULL,
                                  x_gsa_indicator_flag         => NULL,
                                  x_mission_statement          => NULL,
                                  x_organization_name_phonetic => NULL,
                                  x_person_first_name_phonetic => NULL,
                                  x_person_last_name_phonetic  => NULL,
                                  x_language_name              => NULL,
                                  x_category_code              => NULL,
                                  x_salutation                 => NULL,
                                  x_known_as2                  => NULL,
                                  x_known_as3                  => NULL,
                                  x_known_as4                  => NULL,
                                  x_known_as5                  => NULL,
                                  x_object_version_number      => NULL,
                                  x_duns_number_c              => NULL,
                                  x_created_by_module          => NULL,
                                  x_application_id             => NULL);

        -- Update branch end date
        IF (bank_account_dtls_rec.branch_end_date IS NOT NULL) THEN
          iby_ext_bankacct_pub.set_ext_bank_branch_end_date(p_api_version   => 1.0,
                                                            p_init_msg_list => fnd_api.g_true,
                                                            p_branch_id     => l_branch_id,
                                                            p_end_date      => bank_account_dtls_rec.branch_end_date,
                                                            x_return_status => l_ret_status,
                                                            x_msg_count     => l_msg_count,
                                                            x_msg_data      => l_msg_data,
                                                            x_response      => l_set_branch_end_date_resp);

          x_return_status := l_ret_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;

          IF l_ret_status <> fnd_api.g_ret_sts_success THEN
            UPDATE pos_bank_account_det_int
            SET    interface_status = 'REJECTED'
            WHERE  bank_account_interface_id =
                   bank_account_dtls_rec.bank_account_interface_id
            AND    batch_id = p_batch_id;

            IF (insert_rejections(p_batch_id,
                                  l_request_id,
                                  'POS_BANK_ACCOUNT_DET_INT',
                                  bank_account_dtls_rec.bank_account_interface_id,
                                  'POS_FAILED_BRANCH_END_DATE',
                                  g_user_id,
                                  g_login_id,
                                  'IMPORT_VENDOR_BANK_DTLS') <> TRUE) THEN

              IF (g_level_procedure >= g_current_runtime_level) THEN
                fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                          p_data  => l_msg_data);
                fnd_log.string(g_level_procedure,
                               g_module_name || l_api_name,
                               'Parameters: ' || ' Interface_Id: ' ||
                               bank_account_dtls_rec.bank_account_interface_id ||
                               ' Update bank end date: ' || l_msg_data);
              END IF;
            END IF;
            fnd_file.put_line(fnd_file.log,
                              ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                              ' failed in iby_ext_bankacct_pub.set_ext_bank_branch_end_date' ||
                              ' Interface_Id: ' ||
                              bank_account_dtls_rec.bank_account_interface_id ||
                              ', No. of Messages: ' || l_msg_count ||
                              ', Message: ' || l_msg_data);
            GOTO continue_next_record;
          END IF;

        END IF;
      END IF;

      -- Check if the account exists
      -- This API would return the account_id an OUT param
      iby_ext_bankacct_pub.check_ext_acct_exist(p_api_version   => 1,
                                                p_init_msg_list => fnd_api.g_true,
                                                p_bank_id       => l_bank_id,
                                                p_branch_id     => l_branch_id,
                                                p_acct_number   => bank_account_dtls_rec.bank_account_number,
                                                p_acct_name     => bank_account_dtls_rec.account_name,
                                                p_currency      => bank_account_dtls_rec.account_currency_code,
                                                p_country_code  => bank_account_dtls_rec.country_code,
                                                x_acct_id       => l_account_id,
                                                x_start_date    => l_account_start_date,
                                                x_end_date      => l_account_end_date,
                                                x_return_status => l_ret_status,
                                                x_msg_count     => l_msg_count,
                                                x_msg_data      => l_msg_data,
                                                x_response      => l_check_account_resp);

      fnd_file.put_line(fnd_file.log,
                        ' Message: After check_account_exist' ||
                        ' Account Id :' || l_account_id);

      -- Process account

      -- p_association_level should be 'A', 'SS', 'AO', 'S;' depending on the
      -- level for which the account is being created
      -- A is for the Party site level in which case the party_site_id has to be NOT NULL
      -- AO Addres-Operating unit level. Party_site_id not null and Org_id not null
      -- SS is for Supplier Site level. So Supplier_site_id, Party_site_id and Org_id have to be
      -- NOT NULL
      -- S is for the supplier level

      IF ((bank_account_dtls_rec.party_site_orig_sys IS NOT NULL AND
         bank_account_dtls_rec.party_site_orig_sys_ref IS NOT NULL) OR
         (bank_account_dtls_rec.party_site_name IS NOT NULL)) THEN
        IF (bank_account_dtls_rec.party_site_orig_sys IS NOT NULL AND
           bank_account_dtls_rec.party_site_orig_sys_ref IS NOT NULL) THEN

          fnd_file.put_line(fnd_file.log,
                            ' Message: orig_system' ||
                            bank_account_dtls_rec.party_site_orig_sys ||
                            ' orig_system_reference :' ||
                            bank_account_dtls_rec.party_site_orig_sys_ref);

          -- Get the party site id
          SELECT owner_table_id
          INTO   l_party_site_id
          FROM   hz_orig_sys_references
          WHERE  orig_system = bank_account_dtls_rec.party_site_orig_sys
          AND    orig_system_reference =
                 bank_account_dtls_rec.party_site_orig_sys_ref
          AND    owner_table_name = 'HZ_PARTY_SITES'
          AND    nvl(end_date_active, SYSDATE) >= SYSDATE;
        END IF;

        fnd_file.put_line(fnd_file.log,
                          ' Message: Get the party site id' ||
                          ' party_site_id :' || l_party_site_id);

        IF (l_party_site_id IS NULL OR l_party_site_id = 0) THEN
          SELECT hps.party_site_id
          /*, hps.party_site_name, hzl.address1, hzl.address2, hzl.address3, hzl.address4,
          hzl.state, hzl.province, hzl.county, hzl.country, fvl.territory_short_name as country_name
          , hzl.city , hzl.postal_code*/
          INTO   l_party_site_id
          FROM   hz_party_sites     hps,
                 hz_locations       hzl,
                 fnd_territories_vl fvl
          WHERE  hps.party_id = l_party_id
          AND    hzl.location_id = hps.location_id
          AND    hps.status = 'A'
          AND    fvl.territory_code = hzl.country
          AND    hps.party_site_name =
                 bank_account_dtls_rec.party_site_name;
        END IF;
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Get the party site id from hz_locations' ||
                        ' party_site_id :' || l_party_site_id ||
                        ' l_party_id : ' || l_party_id ||
                        ' vendor_site_code : ' ||
                        bank_account_dtls_rec.vendor_site_code ||
                        ' org_id : ' || bank_account_dtls_rec.org_id);

      -- Bug 12842286: Bank Account Creation/Update Loop Aborted if one record errors out.
      -- Need to handle the exception when vendor_site_id is not found (Failing to create supplier site will cause this issue)
      BEGIN
        IF (bank_account_dtls_rec.vendor_site_code IS NOT NULL) THEN
          SELECT vendor_site_id,
                 party_site_id
          INTO   l_vendor_site_id,
                 l_party_site_id
          FROM   ap_supplier_sites_all site,
                 ap_suppliers          vendor
          WHERE  vendor.vendor_id = site.vendor_id
          AND    (site.inactive_date > SYSDATE OR site.inactive_date IS NULL)
          AND    vendor.party_id = l_party_id
          AND    site.vendor_site_code =
                 bank_account_dtls_rec.vendor_site_code
          AND    site.org_id = bank_account_dtls_rec.org_id;
        END IF;

        fnd_file.put_line(fnd_file.log,
                          ' Message: vendor_site_id :' || l_vendor_site_id);

        IF (l_vendor_site_id IS NOT NULL AND l_party_site_id IS NOT NULL AND
           l_party_site_id <> 0 AND bank_account_dtls_rec.org_id IS NOT NULL) THEN
          l_association_level := 'SS';
          l_org_type          := 'OPERATING_UNIT';

        ELSIF (l_party_site_id IS NOT NULL AND l_party_site_id <> 0 AND
              bank_account_dtls_rec.org_id IS NOT NULL) THEN
          l_association_level := 'AO';
          l_org_type          := 'OPERATING_UNIT';

        ELSIF (l_party_site_id IS NOT NULL AND l_party_site_id <> 0) THEN
          l_association_level := 'A';

        ELSE
          l_association_level := 'S';
        END IF;

        fnd_file.put_line(fnd_file.log,
                          ' Message: Account association level :' ||
                          l_association_level);

      EXCEPTION
      WHEN OTHERS THEN
        UPDATE pos_bank_account_det_int
          SET    interface_status = 'REJECTED'
          WHERE  bank_account_interface_id =
                 bank_account_dtls_rec.bank_account_interface_id
          AND    batch_id = p_batch_id;

        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_BANK_ACCOUNT_DET_INT',
                              bank_account_dtls_rec.bank_account_interface_id,
                              'AP_INVALID_BANK_ACCT_INFO',
                              g_user_id,
                              g_login_id,
                              'IMPORT_VENDOR_BANK_DTLS') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Interface_Id: ' ||
                           bank_account_dtls_rec.bank_account_interface_id ||
                           ' Update bank end date: ' || l_msg_data);
          END IF;
        END IF;
        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                          ' failed to find site id' ||
                          ' Interface_Id: ' ||
                          bank_account_dtls_rec.bank_account_interface_id ||
                          ', No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data);

        GOTO continue_next_record;
      END;
      -- End Bug 12842286

      l_new_account_rec.payment_factor_flag          := l_new_account_rec.payment_factor_flag;
      l_new_account_rec.country_code                 := bank_account_dtls_rec.country_code;
      l_new_account_rec.branch_id                    := l_branch_id;
      l_new_account_rec.bank_id                      := l_bank_id;
      l_new_account_rec.acct_owner_party_id          := l_party_id;
      l_new_account_rec.bank_account_name            := bank_account_dtls_rec.account_name;
      l_new_account_rec.bank_account_num             := bank_account_dtls_rec.bank_account_number;
      l_new_account_rec.currency                     := bank_account_dtls_rec.account_currency_code;
      l_new_account_rec.iban                         := bank_account_dtls_rec.iban;
      l_new_account_rec.check_digits                 := bank_account_dtls_rec.check_digits;
      l_new_account_rec.alternate_acct_name          := bank_account_dtls_rec.alt_account_name;
      l_new_account_rec.acct_type                    := bank_account_dtls_rec.account_type;
      l_new_account_rec.acct_suffix                  := bank_account_dtls_rec.account_suffix;
      l_new_account_rec.description                  := bank_account_dtls_rec.account_description;
      l_new_account_rec.agency_location_code         := bank_account_dtls_rec.agency_location_code;
      l_new_account_rec.foreign_payment_use_flag     := bank_account_dtls_rec.foreign_payment_use_flag;
      l_new_account_rec.exchange_rate_agreement_num  := bank_account_dtls_rec.exchange_rate_agreement_num;
      l_new_account_rec.exchange_rate_agreement_type := bank_account_dtls_rec.exchange_rate_agreement_type;
      l_new_account_rec.exchange_rate                := bank_account_dtls_rec.exchange_rate;
      l_new_account_rec.end_date                     := bank_account_dtls_rec.account_end_date;
      l_new_account_rec.start_date                   := bank_account_dtls_rec.account_start_date;

      IF (l_account_id IS NULL) THEN
        bank_account_dtls_rec.insert_update_flag := nvl(bank_account_dtls_rec.insert_update_flag,
                                                        'I');
      ELSE
        bank_account_dtls_rec.insert_update_flag := nvl(bank_account_dtls_rec.insert_update_flag,
                                                        'U');
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' bank_account_dtls_rec.insert_update_flag: ' ||
                        bank_account_dtls_rec.insert_update_flag ||
                        ' l_new_account_rec.alternate_acct_name : ' ||
                        l_new_account_rec.alternate_acct_name);

      IF (l_account_id IS NULL AND
         bank_account_dtls_rec.insert_update_flag = 'I') THEN
        iby_ext_bankacct_pub.create_ext_bank_acct(p_api_version       => 1,
                                                  p_init_msg_list     => fnd_api.g_true,
                                                  p_ext_bank_acct_rec => l_new_account_rec,
                                                  p_association_level => l_association_level,
                                                  p_supplier_site_id  => l_vendor_site_id,
                                                  p_party_site_id     => l_party_site_id,
                                                  p_org_id            => bank_account_dtls_rec.org_id,
                                                  p_org_type          => l_org_type,
                                                  x_acct_id           => l_account_id,
                                                  x_return_status     => l_ret_status,
                                                  x_msg_count         => l_msg_count,
                                                  x_msg_data          => l_msg_data,
                                                  x_response          => l_create_account_resp);

        x_return_status := l_ret_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
      ELSE
        IF (l_account_id IS NOT NULL AND
           bank_account_dtls_rec.insert_update_flag = 'U') THEN

	  ---Bug 11819545
          --l_new_account_rec.bank_account_id := l_account_id;

	   IF(l_association_level='SS')THEN
		  IF(l_vendor_site_id IS NOT NULL) THEN
		   l_payee_context_rec.Party_Site_id :=l_party_site_id;
		   l_payee_context_rec.Supplier_Site_id:=l_vendor_site_id;
		   l_payee_context_rec.Org_Id:=bank_account_dtls_rec.org_id;
		   l_payee_context_rec.Org_Type:=l_org_type;
		  END IF;
		   fnd_file.put_line(fnd_file.log,
				 ' Message: l_association_level SS and l_vendor_site_id : ' ||
				 l_association_level||l_vendor_site_id);
	      ELSIF(l_association_level='A') THEN
	       IF(l_party_site_id IS NOT NULL) THEN
		   l_payee_context_rec.Party_Site_id :=l_party_site_id;
		   l_payee_context_rec.Supplier_Site_id:=NULL;
		   l_payee_context_rec.Org_Id:=NULL;
		   l_payee_context_rec.Org_Type:=NULL;
	       END IF;
		 fnd_file.put_line(fnd_file.log,
				 ' Message: l_association_level A and l_party_site_id : ' ||
				 l_association_level||l_party_site_id);
	   ELSIF(l_association_level='AO') THEN
	       IF(l_party_site_id IS NOT NULL AND bank_account_dtls_rec.org_id IS NOT NULL) THEN
		 fnd_file.put_line(fnd_file.log,
				 ' Message: l_association_level AO: Party site id, org id is not null' ||
				 l_association_level);

	       END IF;
	       l_payee_context_rec.Party_Site_id :=l_party_site_id;
	       l_payee_context_rec.Org_Id:= bank_account_dtls_rec.org_id;
	       l_payee_context_rec.Org_Type:= l_org_type;
	       l_payee_context_rec.Supplier_Site_id:=NULL;
	       fnd_file.put_line(fnd_file.log,
				 ' Message: l_association_level AO, org_id and l_party_site_id : ' ||
				 l_association_level||bank_account_dtls_rec.org_id||l_party_site_id);
	   ELSIF(l_association_level='S')  THEN
	       l_payee_context_rec.Party_Site_id :=NULL;
	       l_payee_context_rec.Org_Id:= NULL;
	       l_payee_context_rec.Org_Type:= NULL;
	       l_payee_context_rec.Supplier_Site_id:=NULL;
	       fnd_file.put_line(fnd_file.log,
				 ' Message: l_association_level S : ' ||
				 l_association_level);
	   END IF;

		 fnd_file.put_line(fnd_file.log,
				 ' Message: orgid: ' ||
				 l_payee_context_rec.Org_Id);
		  fnd_file.put_line(fnd_file.log,
				 ' Message: org type : ' ||
				 l_payee_context_rec.Org_Type);
		      fnd_file.put_line(fnd_file.log,
				 ' Message: party_site_id : ' ||
				 l_payee_context_rec.Party_Site_id);
		      fnd_file.put_line(fnd_file.log,
				 ' Message: Supplier_site_id : ' ||
				 l_payee_context_rec.Supplier_Site_id);

	       l_payee_context_rec.Payment_Function :=l_payment_function;
	       l_payee_context_rec.Party_Id :=l_party_id;
	       l_assign.Instrument.Instrument_Type := l_instrument_type;
	       L_ASSIGN.INSTRUMENT.INSTRUMENT_ID := L_ACCOUNT_ID;
	       l_joint_account_owner_id := NULL;

		iby_ext_bankacct_pub.add_joint_account_owner(p_api_version         => 1.0,
							    p_init_msg_list       => fnd_api.g_true,
							    p_bank_account_id     => l_account_id,
							    P_ACCT_OWNER_PARTY_ID => L_PARTY_ID,
							    x_joint_acct_owner_id => l_joint_account_owner_id,
							    x_return_status       => l_ret_status,
							    x_msg_count           => l_msg_count,
							    X_MSG_DATA            => L_MSG_DATA,
							    x_response            => l_add_account_owner_resp);

	       IBY_DISBURSEMENT_SETUP_PUB.Set_Payee_Instr_Assignment(
			    p_api_version        => 1,
			    p_init_msg_list      => NULL,
			    p_commit             => NULL,
			    x_return_status      => l_ret_status,
			    x_msg_count          => l_msg_count,
			    x_msg_data           => l_msg_data,
			    p_payee              => l_payee_context_rec,
			    p_assignment_attribs => l_assign,
			    x_assign_id          => l_assign_id,
			    x_response           => l_create_account_resp);

		 x_return_status := l_ret_status;
		 x_msg_count     := l_msg_count;
		 x_msg_data      := l_msg_data;
		 --END IF;

		 ELSIF (l_account_id IS NOT NULL AND
		      bank_account_dtls_rec.insert_update_flag = 'E') THEN

		      l_new_account_rec.bank_account_id := l_account_id;
 	       ---End Bug 11819545

          --getting the object version number
          SELECT object_version_number
          INTO   l_new_account_rec.object_version_number
          FROM   iby_ext_bank_accounts_v
          WHERE  branch_party_id = l_branch_id
          AND    bank_party_id = l_bank_id
          AND    ext_bank_account_id = l_account_id;

          iby_ext_bankacct_pub.update_ext_bank_acct(p_api_version       => 1,
                                                    p_init_msg_list     => fnd_api.g_true,
                                                    p_ext_bank_acct_rec => l_new_account_rec,
                                                    x_return_status     => l_ret_status,
                                                    x_msg_count         => l_msg_count,
                                                    x_msg_data          => l_msg_data,
                                                    x_response          => l_create_account_resp);

          x_return_status := l_ret_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
        ELSE
          IF (l_account_id IS NULL AND
             bank_account_dtls_rec.insert_update_flag = 'U') THEN
            -- Account doesnt exist
            l_ret_status := fnd_api.g_ret_sts_error;

            fnd_file.put_line(fnd_file.log,
                              ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                              ' failed in iby_ext_bankacct_pub.create_ext_bank_acct' ||
                              ' Interface_Id: ' ||
                              bank_account_dtls_rec.bank_account_interface_id ||
                              ', No. of Messages: ' || l_msg_count ||
                              ', Message: Account to be updated, doesnt exist');
          END IF;
        END IF;
      END IF;
      -- this would also return the generated account_id.

      IF l_ret_status <> fnd_api.g_ret_sts_success THEN
        UPDATE pos_bank_account_det_int
        SET    interface_status = 'REJECTED'
        WHERE  bank_account_interface_id =
               bank_account_dtls_rec.bank_account_interface_id
        AND    batch_id = p_batch_id;

        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_BANK_ACCOUNT_DET_INT',
                              bank_account_dtls_rec.bank_account_interface_id,
                              'AP_INVALID_BANK_ACCT_INFO',
                              g_user_id,
                              g_login_id,
                              'IMPORT_VENDOR_BANK_DTLS') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Interface_Id: ' ||
                           bank_account_dtls_rec.bank_account_interface_id ||
                           ' Update bank end date: ' || l_msg_data);
          END IF;
        END IF;
        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                          ' failed in iby_ext_bankacct_pub.create_ext_bank_acct' ||
                          ' Interface_Id: ' ||
                          bank_account_dtls_rec.bank_account_interface_id ||
                          ', No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data);
        GOTO continue_next_record;
      END IF;

      --      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Updating account id :' || l_account_id);
      -- Update the interface table with the
      -- account_id that is obtained
      UPDATE pos_bank_account_det_int
      SET    bank_account_id = l_account_id
      WHERE  bank_account_interface_id =
             bank_account_dtls_rec.bank_account_interface_id
      AND    batch_id = p_batch_id;

      -- Update the interface table with the bank_id and branch_id that are obtained
      UPDATE pos_bank_accnt_owners_int
      SET    bank_id    = l_bank_id,
             branch_id  = l_branch_id,
             account_id = l_account_id
      WHERE  bank_account_interface_id =
             bank_account_dtls_rec.bank_account_interface_id
      AND    batch_id = p_batch_id;

      -- Create the intermediary accounts
      IF (bank_account_dtls_rec.inter_account1_country_code IS NOT NULL OR
         bank_account_dtls_rec.inter_account1_bank_name IS NOT NULL OR
         bank_account_dtls_rec.inter_account1_city IS NOT NULL OR
         bank_account_dtls_rec.inter_account1_bank_code IS NOT NULL OR
         bank_account_dtls_rec.inter_account1_branch_number IS NOT NULL OR
         bank_account_dtls_rec.inter_account1_bic IS NOT NULL OR
         bank_account_dtls_rec.inter_account1_number IS NOT NULL OR
         bank_account_dtls_rec.inter_account1_check_digits IS NOT NULL OR
         bank_account_dtls_rec.inter_account1_iban IS NOT NULL OR
         bank_account_dtls_rec.inter_account1_comments IS NOT NULL) THEN

        l_new_intermed_acct1_rec.bank_account_id := l_account_id;
        l_new_intermed_acct1_rec.country_code    := bank_account_dtls_rec.inter_account1_country_code;
        l_new_intermed_acct1_rec.bank_name       := bank_account_dtls_rec.inter_account1_bank_name;
        l_new_intermed_acct1_rec.city            := bank_account_dtls_rec.inter_account1_city;
        l_new_intermed_acct1_rec.bank_code       := bank_account_dtls_rec.inter_account1_bank_code;
        l_new_intermed_acct1_rec.branch_number   := bank_account_dtls_rec.inter_account1_branch_number;
        l_new_intermed_acct1_rec.bic             := bank_account_dtls_rec.inter_account1_bic;
        l_new_intermed_acct1_rec.account_number  := bank_account_dtls_rec.inter_account1_number;
        l_new_intermed_acct1_rec.check_digits    := bank_account_dtls_rec.inter_account1_check_digits;
        l_new_intermed_acct1_rec.iban            := bank_account_dtls_rec.inter_account1_iban;
        l_new_intermed_acct1_rec.comments        := bank_account_dtls_rec.inter_account1_comments;

        BEGIN
          -- Get the id of the intermediary account 1
          SELECT intermediary_acct_id,
                 country_code,
                 bank_name,
                 city,
                 bank_code,
                 branch_number,
                 bic,
                 account_number,
                 check_digits,
                 iban,
                 object_version_number
          INTO   l_new_intermed_acct1_rec.intermediary_acct_id,
                 l_new_intermed_acct1_rec.country_code,
                 l_new_intermed_acct1_rec.bank_name,
                 l_new_intermed_acct1_rec.city,
                 l_new_intermed_acct1_rec.bank_code,
                 l_new_intermed_acct1_rec.branch_number,
                 l_new_intermed_acct1_rec.bic,
                 l_new_intermed_acct1_rec.account_number,
                 l_new_intermed_acct1_rec.check_digits,
                 l_new_intermed_acct1_rec.iban,
                 l_new_intermed_acct1_rec.object_version_number
          FROM   (SELECT intermediary_acct_id intermediary_acct_id,
                         nvl(l_new_intermed_acct1_rec.country_code,
                             country_code) country_code,
                         nvl(l_new_intermed_acct1_rec.bank_name, bank_name) bank_name,
                         nvl(l_new_intermed_acct1_rec.city, city) city,
                         nvl(l_new_intermed_acct1_rec.bank_code, bank_code) bank_code,
                         nvl(l_new_intermed_acct1_rec.branch_number,
                             branch_number) branch_number,
                         nvl(l_new_intermed_acct1_rec.bic, bic) bic,
                         nvl(l_new_intermed_acct1_rec.account_number,
                             account_number) account_number,
                         nvl(l_new_intermed_acct1_rec.check_digits,
                             check_digits) check_digits,
                         nvl(l_new_intermed_acct1_rec.iban, iban) iban,
                         object_version_number,
                         dense_rank() over(ORDER BY intermediary_acct_id) rnk
                  FROM   iby_intermediary_accts
                  WHERE  bank_acct_id = l_account_id)
          WHERE  rnk = 1;

        EXCEPTION
          WHEN OTHERS THEN
            l_new_intermed_acct1_rec.intermediary_acct_id := NULL;
        END;

        fnd_file.put_line(fnd_file.log,
                          ' Message: Intermediary account id : ' ||
                          l_new_intermed_acct1_rec.intermediary_acct_id ||
                          ' l_new_intermed_acct1_rec.city : ' ||
                          l_new_intermed_acct1_rec.city);

        IF (l_new_intermed_acct1_rec.intermediary_acct_id IS NULL) THEN
          fnd_file.put_line(fnd_file.log,
                            ' Message: Going for intermediary account1 creation ');
          iby_ext_bankacct_pub.create_intermediary_acct(p_api_version          => 1.0,
                                                        p_init_msg_list        => fnd_api.g_true,
                                                        p_intermed_acct_rec    => l_new_intermed_acct1_rec,
                                                        x_intermediary_acct_id => l_intermediary1_acct_id,
                                                        x_return_status        => l_ret_status,
                                                        x_msg_count            => l_msg_count,
                                                        x_msg_data             => l_msg_data,
                                                        x_response             => l_add_intermed_account1_resp);

          x_return_status := l_ret_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
        ELSE
          fnd_file.put_line(fnd_file.log,
                            ' Message: Going for intermediary account1 update ');

          iby_ext_bankacct_pub.update_intermediary_acct(p_api_version       => 1.0,
                                                        p_init_msg_list     => fnd_api.g_true,
                                                        p_intermed_acct_rec => l_new_intermed_acct1_rec,
                                                        x_return_status     => l_ret_status,
                                                        x_msg_count         => l_msg_count,
                                                        x_msg_data          => l_msg_data,
                                                        x_response          => l_add_intermed_account1_resp);

          x_return_status := l_ret_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
        END IF;

        IF l_ret_status <> fnd_api.g_ret_sts_success THEN
          UPDATE pos_bank_account_det_int
          SET    interface_status = 'REJECTED'
          WHERE  bank_account_interface_id =
                 bank_account_dtls_rec.bank_account_interface_id
          AND    batch_id = p_batch_id;

          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_BANK_ACCOUNT_DET_INT',
                                bank_account_dtls_rec.bank_account_interface_id,
                                'POS_FAILED_INTERMEDIARY_ACCT',
                                g_user_id,
                                g_login_id,
                                'IMPORT_VENDOR_BANK_DTLS') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Parameters: ' || ' Interface_Id: ' ||
                             bank_account_dtls_rec.bank_account_interface_id ||
                             ' Update bank end date: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                            ' failed in iby_ext_bankacct_pub.create/update_intermediary_acct 1' ||
                            ' Interface_Id: ' ||
                            bank_account_dtls_rec.bank_account_interface_id ||
                            ', No. of Messages: ' || l_msg_count ||
                            ', Message: ' || l_msg_data);
          GOTO continue_next_record;
        END IF;
      END IF;

      IF (bank_account_dtls_rec.inter_account2_country_code IS NOT NULL OR
         bank_account_dtls_rec.inter_account2_bank_name IS NOT NULL OR
         bank_account_dtls_rec.inter_account2_city IS NOT NULL OR
         bank_account_dtls_rec.inter_account2_bank_code IS NOT NULL OR
         bank_account_dtls_rec.inter_account2_branch_number IS NOT NULL OR
         bank_account_dtls_rec.inter_account2_bic IS NOT NULL OR
         bank_account_dtls_rec.inter_account2_number IS NOT NULL OR
         bank_account_dtls_rec.inter_account2_check_digits IS NOT NULL OR
         bank_account_dtls_rec.inter_account2_iban IS NOT NULL OR
         bank_account_dtls_rec.inter_account2_comments IS NOT NULL) THEN

        l_new_intermed_acct2_rec.bank_account_id := l_account_id;
        l_new_intermed_acct2_rec.country_code    := bank_account_dtls_rec.inter_account2_country_code;
        l_new_intermed_acct2_rec.bank_name       := bank_account_dtls_rec.inter_account2_bank_name;
        l_new_intermed_acct2_rec.city            := bank_account_dtls_rec.inter_account2_city;
        l_new_intermed_acct2_rec.bank_code       := bank_account_dtls_rec.inter_account2_bank_code;
        l_new_intermed_acct2_rec.branch_number   := bank_account_dtls_rec.inter_account2_branch_number;
        l_new_intermed_acct2_rec.bic             := bank_account_dtls_rec.inter_account2_bic;
        l_new_intermed_acct2_rec.account_number  := bank_account_dtls_rec.inter_account2_number;
        l_new_intermed_acct2_rec.check_digits    := bank_account_dtls_rec.inter_account2_check_digits;
        l_new_intermed_acct2_rec.iban            := bank_account_dtls_rec.inter_account2_iban;
        l_new_intermed_acct2_rec.comments        := bank_account_dtls_rec.inter_account2_comments;

        BEGIN
          -- Get the id of the intermediary account 2
          SELECT intermediary_acct_id,
                 country_code,
                 bank_name,
                 city,
                 bank_code,
                 branch_number,
                 bic,
                 account_number,
                 check_digits,
                 iban,
                 object_version_number
          INTO   l_new_intermed_acct2_rec.intermediary_acct_id,
                 l_new_intermed_acct2_rec.country_code,
                 l_new_intermed_acct2_rec.bank_name,
                 l_new_intermed_acct2_rec.city,
                 l_new_intermed_acct2_rec.bank_code,
                 l_new_intermed_acct2_rec.branch_number,
                 l_new_intermed_acct2_rec.bic,
                 l_new_intermed_acct2_rec.account_number,
                 l_new_intermed_acct2_rec.check_digits,
                 l_new_intermed_acct2_rec.iban,
                 l_new_intermed_acct2_rec.object_version_number
          FROM   (SELECT intermediary_acct_id intermediary_acct_id,
                         nvl(l_new_intermed_acct2_rec.country_code,
                             country_code) country_code,
                         nvl(l_new_intermed_acct2_rec.bank_name, bank_name) bank_name,
                         nvl(l_new_intermed_acct2_rec.city, city) city,
                         nvl(l_new_intermed_acct2_rec.bank_code, bank_code) bank_code,
                         nvl(l_new_intermed_acct2_rec.branch_number,
                             branch_number) branch_number,
                         nvl(l_new_intermed_acct2_rec.bic, bic) bic,
                         nvl(l_new_intermed_acct2_rec.account_number,
                             account_number) account_number,
                         nvl(l_new_intermed_acct2_rec.check_digits,
                             check_digits) check_digits,
                         nvl(l_new_intermed_acct2_rec.iban, iban) iban,
                         object_version_number,
                         dense_rank() over(ORDER BY intermediary_acct_id) rnk
                  FROM   iby_intermediary_accts
                  WHERE  bank_acct_id = l_account_id)
          WHERE  rnk = 2;

        EXCEPTION
          WHEN OTHERS THEN
            l_new_intermed_acct2_rec.intermediary_acct_id := NULL;
        END;
        fnd_file.put_line(fnd_file.log,
                          ' Message: Intermediary account id : ' ||
                          l_new_intermed_acct2_rec.intermediary_acct_id);

        IF (l_new_intermed_acct2_rec.intermediary_acct_id IS NULL) THEN
          fnd_file.put_line(fnd_file.log,
                            ' Message: Going for intermediary account2 creation ');
          iby_ext_bankacct_pub.create_intermediary_acct(p_api_version          => 1.0,
                                                        p_init_msg_list        => fnd_api.g_true,
                                                        p_intermed_acct_rec    => l_new_intermed_acct2_rec,
                                                        x_intermediary_acct_id => l_intermediary2_acct_id,
                                                        x_return_status        => l_ret_status,
                                                        x_msg_count            => l_msg_count,
                                                        x_msg_data             => l_msg_data,
                                                        x_response             => l_add_intermed_account1_resp);

          x_return_status := l_ret_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
        ELSE
          fnd_file.put_line(fnd_file.log,
                            ' Message: Going for intermediary account2 update ');

          iby_ext_bankacct_pub.update_intermediary_acct(p_api_version       => 1.0,
                                                        p_init_msg_list     => fnd_api.g_true,
                                                        p_intermed_acct_rec => l_new_intermed_acct2_rec,
                                                        x_return_status     => l_ret_status,
                                                        x_msg_count         => l_msg_count,
                                                        x_msg_data          => l_msg_data,
                                                        x_response          => l_add_intermed_account1_resp);

          x_return_status := l_ret_status;
          x_msg_count     := l_msg_count;
          x_msg_data      := l_msg_data;
        END IF;

        IF l_ret_status <> fnd_api.g_ret_sts_success THEN
          UPDATE pos_bank_account_det_int
          SET    interface_status = 'REJECTED'
          WHERE  bank_account_interface_id =
                 bank_account_dtls_rec.bank_account_interface_id
          AND    batch_id = p_batch_id;

          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_BANK_ACCOUNT_DET_INT',
                                bank_account_dtls_rec.bank_account_interface_id,
                                'POS_FAILED_INTERMEDIARY_ACCT2',
                                g_user_id,
                                g_login_id,
                                'IMPORT_VENDOR_BANK_DTLS') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Parameters: ' || ' Interface_Id: ' ||
                             bank_account_dtls_rec.bank_account_interface_id ||
                             ' Update bank end date: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                            ' failed in iby_ext_bankacct_pub.create/update_intermediary_acct 2' ||
                            ' Interface_Id: ' ||
                            bank_account_dtls_rec.bank_account_interface_id ||
                            ', No. of Messages: ' || l_msg_count ||
                            ', Message: ' || l_msg_data);
          GOTO continue_next_record;
        END IF;
      END IF;

      UPDATE pos_bank_account_det_int
      SET    interface_status = 'PROCESSED'
      WHERE  bank_account_interface_id =
             bank_account_dtls_rec.bank_account_interface_id
      AND    batch_id = p_batch_id;

      IF (bank_account_dtls_rec.insert_update_flag = 'I') THEN
        UPDATE pos_imp_batch_summary
        SET    total_records_imported = total_records_imported + 1,
               total_inserts          = total_inserts + 1,
               bank_detls_inserted    = bank_detls_inserted + 1,
               bank_detls_imported    = bank_detls_imported + 1
        WHERE  batch_id = p_batch_id;
      ELSE
        UPDATE pos_imp_batch_summary
        SET    total_records_imported = total_records_imported + 1,
               total_updates          = total_updates + 1,
               bank_detls_updated     = bank_detls_updated + 1,
               bank_detls_imported    = bank_detls_imported + 1
        WHERE  batch_id = p_batch_id;
      END IF;

      <<continue_next_record>>
      NULL;
    END LOOP;

    CLOSE bank_account_dtls_cur;

    -- now process the account owners
    fnd_file.put_line(fnd_file.log, ' Message: Processing Account owners ');

    OPEN account_owners_cur;
    LOOP
      -- Fetch the cursor data into a record
      FETCH account_owners_cur
        INTO account_owners_rec;
      EXIT WHEN account_owners_cur%NOTFOUND;

      -- Initializing
      fnd_file.put_line(fnd_file.log,
                        ' Message: Initializing local variables ');
      fnd_file.put_line(fnd_file.log,
                        ' account_owners_rec.account_owner_name: ' ||
                        account_owners_rec.account_owner_name);
      l_account_owner_id       := NULL;
      l_account_id             := NULL;
      l_joint_account_owner_id := NULL;

      IF account_owners_rec.account_owner_party_id IS NULL THEN
        IF account_owners_rec.account_owner_name IS NOT NULL THEN
          SELECT party_id
          INTO   l_account_owner_id
          FROM   hz_parties
          WHERE  party_name = account_owners_rec.account_owner_name
          AND    rownum = 1;
        ELSE
          l_account_owner_id := get_party_id(account_owners_rec.source_system,
                                             account_owners_rec.source_system_reference);
        END IF;
      ELSE
        l_account_owner_id := account_owners_rec.account_owner_party_id;
      END IF;

      fnd_file.put_line(fnd_file.log,
                        ' l_account_owner_id: ' || l_account_owner_id);

      -- Bug 12842286: Handle the exception if acount id is not found. Failing to create a bank account will cause this issue.
      BEGIN
        IF (account_owners_rec.account_id IS NULL) THEN
          SELECT ext_bank_account_id
          INTO   l_account_id
          FROM   iby_ext_bank_accounts_v
          WHERE  country_code = account_owners_rec.bank_country_code
          AND    bank_name = account_owners_rec.bank_name
          AND    (bank_number = account_owners_rec.bank_number OR
                account_owners_rec.bank_number IS NULL)
          AND    bank_branch_name = account_owners_rec.branch_name
          AND    (branch_number = account_owners_rec.branch_number OR
                account_owners_rec.branch_number IS NULL)
          AND    bank_account_num_electronic =
                 account_owners_rec.account_number;
        ELSE
          l_account_id := account_owners_rec.account_id;
        END IF;

        fnd_file.put_line(fnd_file.log, ' l_account_id: ' || l_account_id);

     EXCEPTION
        WHEN OTHERS THEN
          UPDATE pos_bank_accnt_owners_int
            SET    interface_status = 'REJECTED'
            WHERE  bank_acct_owner_interface_id =
                   account_owners_rec.bank_acct_owner_interface_id
            AND    batch_id = p_batch_id;

          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_BANK_ACCNT_OWNERS_INT',
                                bank_account_dtls_rec.bank_account_interface_id,
                                'POS_ADD_ACCT_OWNER',
                                g_user_id,
                                g_login_id,
                                'import_vendor_bank_dtls') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Parameters: ' || ' Interface_Id: ' ||
                             bank_account_dtls_rec.bank_account_interface_id ||
                             ' get account owner id Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                            ' failed to find account id' ||
                            ' bank_acct_owner_interface_id: ' ||
                            account_owners_rec.bank_acct_owner_interface_id ||
                            ', No. of Messages: ' || l_msg_count ||
                            ', Message: ' || l_msg_data);
          --fnd_file.put_line(fnd_file.log, ' l_account_id: ' || SQLCODE || ' ' || SQLERRM );
          GOTO continue_next_owner;
      END;
      -- End Bug 12842286

      -- Call the add account owner API
      iby_ext_bankacct_pub.add_joint_account_owner(p_api_version         => 1.0,
                                                   p_init_msg_list       => fnd_api.g_true,
                                                   p_bank_account_id     => l_account_id,
                                                   p_acct_owner_party_id => l_account_owner_id,
                                                   x_joint_acct_owner_id => l_joint_account_owner_id,
                                                   x_return_status       => l_ret_status,
                                                   x_msg_count           => l_msg_count,
                                                   x_msg_data            => l_msg_data,
                                                   x_response            => l_add_account_owner_resp);

      x_return_status := l_ret_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;

      IF l_ret_status <> fnd_api.g_ret_sts_success THEN

        UPDATE pos_bank_accnt_owners_int
        SET    interface_status = 'REJECTED'
        WHERE  bank_acct_owner_interface_id =
               account_owners_rec.bank_acct_owner_interface_id
        AND    batch_id = p_batch_id;

        IF (insert_rejections(p_batch_id,
                              l_request_id,
                              'POS_BANK_ACCNT_OWNERS_INT',
                              bank_account_dtls_rec.bank_account_interface_id,
                              'POS_ADD_ACCT_OWNER',
                              g_user_id,
                              g_login_id,
                              'import_vendor_bank_dtls') <> TRUE) THEN

          IF (g_level_procedure >= g_current_runtime_level) THEN
            fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                      p_data  => l_msg_data);
            fnd_log.string(g_level_procedure,
                           g_module_name || l_api_name,
                           'Parameters: ' || ' Interface_Id: ' ||
                           bank_account_dtls_rec.bank_account_interface_id ||
                           ' add account owner Msg: ' || l_msg_data);
          END IF;
        END IF;
        fnd_file.put_line(fnd_file.log,
                          ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                          ' failed in iby_ext_bankacct_pub.add_joint_account_owner' ||
                          ' bank_acct_owner_interface_id: ' ||
                          account_owners_rec.bank_acct_owner_interface_id ||
                          ', No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data);
        GOTO continue_next_owner;
      END IF;

      -- Set the end date if entered
      IF account_owners_rec.end_date IS NOT NULL THEN

        IF l_joint_account_owner_id IS NULL THEN
          -- get the account owner id
          SELECT account_owner_id,
                 object_version_number
          INTO   l_joint_account_owner_id,
                 l_obj_version
          FROM   iby_account_owners
          WHERE  ext_bank_account_id = l_account_id
          AND    account_owner_party_id = l_account_owner_id;
        ELSE
          SELECT object_version_number
          INTO   l_obj_version
          FROM   iby_account_owners
          WHERE  ext_bank_account_id = l_account_id
          AND    account_owner_party_id = l_account_owner_id;
        END IF;

        iby_ext_bankacct_pub.set_joint_acct_owner_end_date(p_api_version           => 1.0,
                                                           p_init_msg_list         => fnd_api.g_true,
                                                           p_acct_owner_id         => l_joint_account_owner_id,
                                                           p_end_date              => account_owners_rec.end_date,
                                                           p_object_version_number => l_obj_version,
                                                           x_return_status         => l_ret_status,
                                                           x_msg_count             => l_msg_count,
                                                           x_msg_data              => l_msg_data,
                                                           x_response              => l_set_end_date_resp);

        x_return_status := l_ret_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;

        IF l_ret_status <> fnd_api.g_ret_sts_success THEN

          UPDATE pos_bank_accnt_owners_int
          SET    interface_status = 'REJECTED'
          WHERE  bank_acct_owner_interface_id =
                 account_owners_rec.bank_acct_owner_interface_id
          AND    batch_id = p_batch_id;

          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_BANK_ACCNT_OWNERS_INT',
                                bank_account_dtls_rec.bank_account_interface_id,
                                'POS_ADD_ACCT_OWNER',
                                g_user_id,
                                g_login_id,
                                'import_vendor_bank_dtls') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Parameters: ' || ' Interface_Id: ' ||
                             bank_account_dtls_rec.bank_account_interface_id ||
                             ' get account owner id Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                            ' failed in iby_ext_bankacct_pub.set_joint_acct_owner_end_date' ||
                            ' bank_acct_owner_interface_id: ' ||
                            account_owners_rec.bank_acct_owner_interface_id ||
                            ', No. of Messages: ' || l_msg_count ||
                            ', Message: ' || l_msg_data);
          GOTO continue_next_owner;
        END IF;
      END IF;

      -- Set the primary flag
      IF (account_owners_rec.primary_flag IS NOT NULL) THEN
        iby_ext_bankacct_pub.change_primary_acct_owner(p_api_version         => 1.0,
                                                       p_init_msg_list       => fnd_api.g_true,
                                                       p_bank_acct_id        => l_account_id,
                                                       p_acct_owner_party_id => l_account_owner_id,
                                                       x_return_status       => l_ret_status,
                                                       x_msg_count           => l_msg_count,
                                                       x_msg_data            => l_msg_data,
                                                       x_response            => l_set_primary_flag_resp);

        x_return_status := l_ret_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;

        IF l_ret_status <> fnd_api.g_ret_sts_success THEN

          UPDATE pos_bank_accnt_owners_int
          SET    interface_status = 'REJECTED'
          WHERE  bank_acct_owner_interface_id =
                 account_owners_rec.bank_acct_owner_interface_id
          AND    batch_id = p_batch_id;

          IF (insert_rejections(p_batch_id,
                                l_request_id,
                                'POS_BANK_ACCNT_OWNERS_INT',
                                bank_account_dtls_rec.bank_account_interface_id,
                                'POS_PRIMARY_FLAG_NOTSET',
                                g_user_id,
                                g_login_id,
                                'import_vendor_bank_dtls') <> TRUE) THEN

            IF (g_level_procedure >= g_current_runtime_level) THEN
              fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                        p_data  => l_msg_data);
              fnd_log.string(g_level_procedure,
                             g_module_name || l_api_name,
                             'Parameters: ' || ' Interface_Id: ' ||
                             bank_account_dtls_rec.bank_account_interface_id ||
                             ' Set primary flag Msg: ' || l_msg_data);
            END IF;
          END IF;
          fnd_file.put_line(fnd_file.log,
                            ' Message: Inside PROCEDURE IMPORT_VENDOR_BANK_DTLS' ||
                            ' failed in iby_ext_bankacct_pub.change_primary_acct_owner' ||
                            ' bank_acct_owner_interface_id: ' ||
                            account_owners_rec.bank_acct_owner_interface_id ||
                            ', No. of Messages: ' || l_msg_count ||
                            ', Message: ' || l_msg_data);
          GOTO continue_next_owner;
        END IF;

      END IF;

      UPDATE pos_bank_accnt_owners_int
      SET    interface_status = 'PROCESSED'
      WHERE  bank_acct_owner_interface_id =
             account_owners_rec.bank_acct_owner_interface_id
      AND    batch_id = p_batch_id;

      UPDATE pos_imp_batch_summary
      SET    total_records_imported = total_records_imported + 1,
             total_inserts          = total_inserts + 1,
             bank_detls_inserted    = bank_detls_inserted + 1,
             bank_detls_imported    = bank_detls_imported + 1
      WHERE  batch_id = p_batch_id;

      <<continue_next_owner>>
      NULL;
    END LOOP;

    CLOSE account_owners_cur;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_vendor_bank_dtls EXCEPTION ' ||
                        ' Message: ' || SQLCODE || ' ' || SQLERRM);
  END import_vendor_bank_dtls;

  PROCEDURE import_batch
  (
    errbuf                   OUT NOCOPY VARCHAR2,
    retcode                  OUT NOCOPY VARCHAR2,
    p_batch_id               IN NUMBER,
    p_import_run_option      IN VARCHAR2,
    p_run_batch_dedup        IN VARCHAR2,
    p_batch_dedup_rule_id    IN NUMBER,
    p_batch_dedup_action     IN VARCHAR2,
    p_run_addr_val           IN VARCHAR2,
    p_run_registry_dedup     IN VARCHAR2,
    p_registry_dedup_rule_id IN NUMBER,
    p_run_automerge          IN VARCHAR2 := 'N',
    p_generate_fuzzy_key     IN VARCHAR2 := 'Y',
    p_import_uda_only        IN VARCHAR2 := 'N' --Bug 12747017
  ) AS
    l_request_id NUMBER := fnd_global.conc_request_id;

    l_errbuf            VARCHAR2(4000);
    l_retcode           VARCHAR2(10);
    l_batch_status      hz_imp_batch_summary.batch_status%TYPE;
    l_import_status     hz_imp_batch_summary.import_status%TYPE;
    l_main_conc_status  hz_imp_batch_summary.main_conc_status%TYPE;
    l_import_run_option VARCHAR2(20);
    l_what_if_flag      VARCHAR2(10);

    l_return_status VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);

    l_error_count   NUMBER := 0;
    l_tot_err_count NUMBER := 0;
    ---UDA Import
    l_uda_imported_count NUMBER := 0;

    --- Bug 17068732: Business Event
    l_event_status VARCHAR2(40);
    l_event_err_msg VARCHAR2(2000);

  BEGIN
    fnd_msg_pub.initialize;

    fnd_file.put_line(fnd_file.log,
                      ' Message: Inside PROCEDURE IMPORT_BATCH' ||
                      ' Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                      ' p_import_run_option: ' || p_import_run_option ||
                      ' p_run_batch_dedup: ' || p_run_batch_dedup ||
                      ' p_run_registry_dedup: ' || p_run_registry_dedup);

    IF (g_level_procedure >= g_current_runtime_level) THEN
      fnd_log.string(g_level_procedure,
                     g_module_name || 'IMPORT_BATCH',
                     'Parameters: ' || ' p_batch_id: ' || p_batch_id ||
                     ' Message: Inside PROCEDURE import_batch');
    END IF;

    --Bug 12747017
    IF (p_import_uda_only = 'N') THEN

    /*IF (p_import_run_option <> 'CONTINUE') THEN*/
    -- set the processing status appropriately
    UPDATE pos_imp_batch_summary
    SET    import_status    = 'PROCESSING',
           main_conc_status = 'PROCESSING',
           batch_status     = 'PROCESSING',
           import_req_id    = l_request_id
    /*,main_conc_req_id = l_request_id*/
    WHERE  batch_id = p_batch_id;

    pre_processing(p_batch_id      => p_batch_id,
                   x_return_status => l_return_status,
                   x_msg_count     => l_msg_count,
                   x_msg_data      => l_msg_data);

    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      fnd_file.put_line(fnd_file.log,
                        'UIC***** No. of Messages: ' || l_msg_count ||
                        ', Message: ' || l_msg_data ||
                        ' From pre_processing API.');
      errbuf  := 'WARNING****** Unexpected error occured in pre_processing.';
      retcode := 1;

      UPDATE pos_imp_batch_summary
      SET    import_status    = 'COMPL_ERRORS',
             main_conc_status = 'COMPLETED',
             batch_status     = 'ACTION_REQUIRED'
      WHERE  batch_id = p_batch_id;

      UPDATE hz_imp_batch_summary
      SET    what_if_flag = decode(p_import_run_option, 'WHAT_IF', 'Y', 'N')
      WHERE  batch_id = p_batch_id;

      RETURN;
    END IF;
    /*ELSE
      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE IMPORT_BATCH' ||
                        ' p_import_run_option = CONTINUE');

      UPDATE pos_imp_batch_summary
      SET    import_status    = 'PENDING',
             main_conc_status = 'PENDING',
             batch_status     = 'PROCESSING',
             import_req_id    = l_request_id
      WHERE  batch_id = p_batch_id;
    END IF;*/

    IF (p_run_batch_dedup = 'N' AND p_run_registry_dedup = 'N') THEN
      fnd_file.put_line(fnd_file.log,
                        'After pre_processing Validate Supplier before party is created');

      /* Validate Supplier before party is created */
      validate_vendor(p_batch_id      => p_batch_id,
                      x_return_status => l_return_status,
                      x_msg_count     => l_msg_count,
                      x_msg_data      => l_msg_data);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_file.put_line(fnd_file.log,
                          'Error Message Count: ' || l_msg_count ||
                          ' Error Message Data: ' || l_msg_data ||
                          ' From validate_vendor API.');

        UPDATE pos_imp_batch_summary
        SET    import_status    = 'PENDING',
               main_conc_status = 'COMPLETED',
               batch_status     = 'PENDING'
        WHERE  batch_id = p_batch_id;

        UPDATE hz_imp_batch_summary
        SET    import_status    = 'COMPL_ERRORS',
               main_conc_status = 'COMPLETED',
               batch_status     = 'ACTION_REQUIRED'
        WHERE  batch_id = p_batch_id;

        RETURN;
      END IF;

      fnd_file.put_line(fnd_file.log, 'After Validate Supplier');
    ELSE
      fnd_file.put_line(fnd_file.log, 'After pre_processing');
    END IF;

    BEGIN
      SELECT batch_status,
             import_status,
             what_if_flag
      INTO   l_batch_status,
             l_import_status,
             l_what_if_flag
      FROM   hz_imp_batch_summary
      WHERE  batch_id = p_batch_id;

    EXCEPTION
      WHEN no_data_found THEN
        l_batch_status := 'COMPLETED';
    END;

    fnd_file.put_line(fnd_file.log,
                      'l_batch_status : ' || l_batch_status ||
                      ' l_import_status : ' || l_import_status);

    IF (l_batch_status <> 'COMPLETED') THEN
      UPDATE pos_imp_batch_summary
      SET    import_status    = 'PENDING',
             main_conc_status = 'PENDING',
             batch_status     = 'PROCESSING',
             import_req_id    = l_request_id
      WHERE  batch_id = p_batch_id;

      /* If failed because of preprocessing and resubmitted then
      run option should go as COMPLETE */
      IF p_import_run_option = 'CONTINUE' THEN
        IF NOT (nvl(l_import_status, 'X') IN
            ('ACTION_REQUIRED', 'COMPL_ERROR_LIMIT', 'COMPL_ERRORS')) THEN
          IF (l_what_if_flag = 'N') THEN
            l_import_run_option := 'COMPLETE';
          ELSE
            l_import_run_option := 'WHAT_IF';
          END IF;
        ELSE
          l_import_run_option := p_import_run_option;
        END IF;
      ELSE
        l_import_run_option := p_import_run_option;
      END IF;

      fnd_file.put_line(fnd_file.log,
                        'l_import_run_option : ' || l_import_run_option);

      /* Call HZ import API to import a party */
      hz_batch_import_pkg.import_batch(l_errbuf,
                                       l_retcode,
                                       p_batch_id,
                                       l_import_run_option,
                                       p_run_batch_dedup,
                                       p_batch_dedup_rule_id,
                                       p_batch_dedup_action,
                                       p_run_addr_val,
                                       p_run_registry_dedup,
                                       p_registry_dedup_rule_id,
                                       p_run_automerge,
                                       p_generate_fuzzy_key);
      errbuf  := l_errbuf;
      retcode := l_retcode;

      fnd_file.put_line(fnd_file.log,
                        ' Message: Inside PROCEDURE IMPORT_BATCH' ||
                        ' output parameters from hz_batch_import_pkg errbuf : ' ||
                        errbuf || ' retcode : ' || retcode);

      -- ER 17068732: Raise business event if not in preview mode
      IF l_import_run_option <> 'WHAT_IF' THEN
        POS_VENDOR_UTIL_PKG.RAISE_SUPPLIER_EVENT(p_vendor_id => -1,
                                                 p_party_id  => -1,
                                                 p_transaction_type => 'IMPORT',
                                                 p_entity_name => 'IMPORT',
                                                 p_entity_key => p_batch_id,
                                                 x_return_status => l_event_status,
                                                 x_msg_data => l_event_err_msg);
        fnd_file.put_line(fnd_file.log,
                          'Business Event Raised for batch '|| p_batch_id || '; status: ' || l_event_status);
        IF l_event_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          fnd_file.put_line(fnd_file.log,
                            'Error Message: ' || l_event_err_msg);
        END IF;
      END IF;
    END IF;

    BEGIN
      SELECT batch_status,
             import_status,
             main_conc_status
      INTO   l_batch_status,
             l_import_status,
             l_main_conc_status
      FROM   hz_imp_batch_summary
      WHERE  batch_id = p_batch_id;

    EXCEPTION
      WHEN no_data_found THEN
        l_batch_status := 'NOT COMPLETED';
    END;

    fnd_file.put_line(fnd_file.log, 'l_batch_status2 : ' || l_batch_status);

    /*After the party import is completed enable the party
    as supplier and party contact as supplier contact*/

    IF (l_batch_status = 'COMPLETED') THEN
      UPDATE hz_imp_batch_summary
      SET    total_inserts = parties_inserted + addresses_inserted +
                             addressuses_inserted + contactpoints_inserted +
                             contacts_inserted + contactroles_inserted +
                             codeassigns_inserted + relationships_inserted +
                             creditratings_inserted + finreports_inserted +
                             finnumbers_inserted,
             total_updates = parties_updated + addresses_updated +
                             addressuses_updated + contactpoints_updated +
                             contacts_updated + contactroles_updated +
                             codeassigns_updated + relationships_updated +
                             creditratings_updated + finreports_updated +
                             finnumbers_updated
      WHERE  batch_id = p_batch_id;

      -- Set the processing status appropriately
      UPDATE pos_imp_batch_summary
      SET    import_status    = 'PROCESSING',
             main_conc_status = 'PROCESSING',
             batch_status     = 'PROCESSING'
      WHERE  batch_id = p_batch_id;

      enable_party_as_supplier(p_batch_id      => p_batch_id,
                               x_return_status => l_return_status,
                               x_msg_count     => l_msg_count,
                               x_msg_data      => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From enable_party_as_supplier API.');
        errbuf  := 'WARNING****** Unexpected error occured in enabling party as supplier program.';
        retcode := 1;

        UPDATE pos_imp_batch_summary
        SET    import_status    = 'COMPL_ERRORS',
               main_conc_status = 'COMPLETED',
               batch_status     = 'ACTION_REQUIRED'
        WHERE  batch_id = p_batch_id;

        RETURN;
      END IF;

      enable_partycont_as_suppcont(p_batch_id      => p_batch_id,
                                   x_return_status => l_return_status,
                                   x_msg_count     => l_msg_count,
                                   x_msg_data      => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From enable_partycont_as_suppcont API.');
        errbuf  := 'WARNING****** Unexpected error occured in enabling party contact as supplier contact program.';
        retcode := 1;
      END IF;

      update_party_id(p_batch_id      => p_batch_id,
                      x_return_status => l_return_status,
                      x_msg_count     => l_msg_count,
                      x_msg_data      => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From update_party_id API.');
        errbuf  := 'WARNING****** Unexpected error occured in update party id program.';
        retcode := 1;
      END IF;

      import_vendors(p_batch_id      => p_batch_id,
                     x_return_status => l_return_status,
                     x_msg_count     => l_msg_count,
                     x_msg_data      => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        l_tot_err_count := l_tot_err_count + 1;
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From import_vendors API.');
        errbuf  := 'WARNING****** Unexpected error occured in import vendors program.';
        retcode := 1;
      ELSE
        SELECT COUNT(1)
        INTO   l_error_count
        FROM   ap_suppliers_int
        WHERE  sdh_batch_id = p_batch_id
        AND    nvl(status, 'ACTIVE') = 'REJECTED'
        AND    rownum = 1;

        l_tot_err_count := l_tot_err_count + l_error_count;
      END IF;

      update_party_site_id(p_batch_id      => p_batch_id,
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From update_party_id API.');
        errbuf  := 'WARNING****** Unexpected error occured in update party id program.';
        retcode := 1;
      END IF;

      import_vendor_sites(p_batch_id      => p_batch_id,
                          x_return_status => l_return_status,
                          x_msg_count     => l_msg_count,
                          x_msg_data      => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        l_tot_err_count := l_tot_err_count + 1;
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From import_vendor_sites API.');
        errbuf  := 'WARNING****** Unexpected error occured in import vendor sites program.';
        retcode := 1;
      ELSE
        SELECT COUNT(1)
        INTO   l_error_count
        FROM   ap_supplier_sites_int
        WHERE  sdh_batch_id = p_batch_id
        AND    nvl(status, 'ACTIVE') = 'REJECTED'
        AND    rownum = 1;

        l_tot_err_count := l_tot_err_count + l_error_count;
      END IF;

      update_contact_dtls(p_batch_id      => p_batch_id,
                          x_return_status => l_return_status,
                          x_msg_count     => l_msg_count,
                          x_msg_data      => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From update_contact_dtls API.');
        errbuf  := 'WARNING****** Unexpected error occured in update contact details program.';
        retcode := 1;
      END IF;

      import_vendor_contacts(p_batch_id      => p_batch_id,
                             x_return_status => l_return_status,
                             x_msg_count     => l_msg_count,
                             x_msg_data      => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        l_tot_err_count := l_tot_err_count + 1;
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From import_vendor_contacts API.');
        errbuf  := 'WARNING****** Unexpected error occured in import vendor contacts program.';
        retcode := 1;
      ELSE
        SELECT COUNT(1)
        INTO   l_error_count
        FROM   ap_sup_site_contact_int
        WHERE  sdh_batch_id = p_batch_id
        AND    nvl(status, 'ACTIVE') = 'REJECTED'
        AND    rownum = 1;

        l_tot_err_count := l_tot_err_count + l_error_count;
      END IF;

      import_vendor_prods_services(p_batch_id      => p_batch_id,
                                   x_return_status => l_return_status,
                                   x_msg_count     => l_msg_count,
                                   x_msg_data      => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        l_tot_err_count := l_tot_err_count + 1;
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From import_vendor_prods_services API.');
        errbuf  := 'WARNING****** Unexpected error occured in import vendor contacts program.';
        retcode := 1;
      ELSE
        SELECT COUNT(1)
        INTO   l_error_count
        FROM   pos_product_service_int
        WHERE  sdh_batch_id = p_batch_id
        AND    nvl(status, 'ACTIVE') = 'REJECTED'
        AND    rownum = 1;

        l_tot_err_count := l_tot_err_count + l_error_count;
      END IF;

      import_vendor_buss_class(p_batch_id      => p_batch_id,
                               x_return_status => l_return_status,
                               x_msg_count     => l_msg_count,
                               x_msg_data      => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        l_tot_err_count := l_tot_err_count + 1;
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From import_vendor_buss_class API.');
        errbuf  := 'WARNING****** Unexpected error occured in import vendor contacts program.';
        retcode := 1;
      ELSE
        SELECT COUNT(1)
        INTO   l_error_count
        FROM   pos_business_class_int
        WHERE  sdh_batch_id = p_batch_id
        AND    nvl(status, 'ACTIVE') = 'REJECTED'
        AND    rownum = 1;

        l_tot_err_count := l_tot_err_count + l_error_count;
      END IF;

      import_vendor_tax_dtls(p_batch_id      => p_batch_id,
                             x_return_status => l_return_status,
                             x_msg_count     => l_msg_count,
                             x_msg_data      => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        l_tot_err_count := l_tot_err_count + 1;
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From import_vendor_tax_dtls API.');
        errbuf  := 'WARNING****** Unexpected error occured in import vendor contacts program.';
        retcode := 1;
      ELSE
        SELECT COUNT(1)
        INTO   l_error_count
        FROM   pos_party_tax_profile_int
        WHERE  batch_id = p_batch_id
        AND    nvl(status, 'ACTIVE') = 'REJECTED'
        AND    rownum = 1;

        l_tot_err_count := l_tot_err_count + l_error_count;

        SELECT COUNT(1)
        INTO   l_error_count
        FROM   pos_party_tax_reg_int
        WHERE  batch_id = p_batch_id
        AND    nvl(status, 'ACTIVE') = 'REJECTED'
        AND    rownum = 1;

        l_tot_err_count := l_tot_err_count + l_error_count;

        SELECT COUNT(1)
        INTO   l_error_count
        FROM   pos_fiscal_class_int
        WHERE  batch_id = p_batch_id
        AND    nvl(status, 'ACTIVE') = 'REJECTED'
        AND    rownum = 1;

        l_tot_err_count := l_tot_err_count + l_error_count;
      END IF;

      import_vendor_bank_dtls(p_batch_id      => p_batch_id,
                              x_return_status => l_return_status,
                              x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data);

      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
        l_tot_err_count := l_tot_err_count + 1;
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From import_vendor_bank_dtls API.');
        errbuf  := 'WARNING****** Unexpected error occured in import vendor contacts program.';
        retcode := 1;
      ELSE
        SELECT COUNT(1)
        INTO   l_error_count
        FROM   pos_bank_account_det_int
        WHERE  batch_id = p_batch_id
        AND    nvl(interface_status, 'ACTIVE') = 'REJECTED'
        AND    rownum = 1;

        l_tot_err_count := l_tot_err_count + l_error_count;

        SELECT COUNT(1)
        INTO   l_error_count
        FROM   pos_bank_accnt_owners_int
        WHERE  batch_id = p_batch_id
        AND    nvl(interface_status, 'ACTIVE') = 'REJECTED'
        AND    rownum = 1;

        l_tot_err_count := l_tot_err_count + l_error_count;
      END IF;

      ------UDA import
      POS_BULKLOAD_ENTITIES.PROCESS_USER_ATTRS_DATA(p_data_set_id      => p_batch_id,
                              ERRBUF                    =>   l_errbuf,
                              RETCODE                   =>   L_RETCODE,
                              P_PURGE_SUCCESSFUL_LINES  =>   FND_API.G_FALSE);

      IF (L_RETCODE <> FND_API.G_RET_STS_SUCCESS) THEN
        l_tot_err_count := l_tot_err_count + 1;
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || L_RETCODE ||
                          ', Message: ' || l_errbuf ||
                          ' From POS_BULKLOAD_ENTITIES.PROCESS_USER_ATTRS_DATA API.');
        errbuf  := 'WARNING****** Unexpected error occured in import UDA program.';
        retcode := 1;
      ELSE
        SELECT COUNT(1)
        INTO   l_error_count
        FROM   POS_SUPP_PROF_EXT_INTF
        WHERE  BATCH_ID = P_BATCH_ID
        AND    nvl(PROCESS_STATUS, 1) = 3;

        SELECT COUNT(1)
        INTO   l_uda_imported_count
        FROM   POS_SUPP_PROF_EXT_INTF
        WHERE  BATCH_ID = P_BATCH_ID
        AND    NVL(PROCESS_STATUS, 1) = 4;

        l_tot_err_count := l_tot_err_count + l_error_count;
      END IF;
      ----UDA Import


      fnd_file.put_line(fnd_file.log,
                        'Total error count is : ' || l_tot_err_count);

      -- Set the processing status appropriately
      IF (l_tot_err_count = 0) THEN
        UPDATE pos_imp_batch_summary
        SET    import_status    = 'COMPLETED',
               main_conc_status = 'COMPLETED',
               batch_status     = 'COMPLETED',
               total_records_imported = total_records_imported + l_uda_imported_count
        WHERE  batch_id = p_batch_id;
      ELSE
        UPDATE pos_imp_batch_summary
        SET    import_status    = 'COMPL_ERRORS',
               main_conc_status = 'COMPLETED',
               batch_status     = 'ACTION_REQUIRED',
               total_records_imported = total_records_imported + l_uda_imported_count
        WHERE  batch_id = p_batch_id;
      END IF;

    ELSIF (l_batch_status = 'PROCESSING') THEN
      UPDATE pos_imp_batch_summary
      SET    import_status    = 'PENDING',
             main_conc_status = 'PENDING',
             batch_status     = 'PROCESSING',
             total_records_imported = total_records_imported + l_uda_imported_count
      WHERE  batch_id = p_batch_id;

      RETURN;
    ELSIF (l_batch_status = 'ACTION_REQUIRED') THEN

      UPDATE pos_imp_batch_summary
      SET    import_status    = 'PENDING',
             main_conc_status = 'PENDING',
             batch_status     = 'PENDING',
             total_records_imported = total_records_imported + l_uda_imported_count
      WHERE  batch_id = p_batch_id;

    END IF;

  ELSE --IF (p_import_uda_only = 'Y')

              ------UDA import
      POS_BULKLOAD_ENTITIES.PROCESS_USER_ATTRS_DATA(p_data_set_id      => p_batch_id,
                              ERRBUF                    =>   l_errbuf,
                              RETCODE                   =>   L_RETCODE,
                              P_PURGE_SUCCESSFUL_LINES  =>   FND_API.G_FALSE);

      IF (L_RETCODE <> FND_API.G_RET_STS_SUCCESS) THEN
        l_tot_err_count := l_tot_err_count + 1;
        fnd_file.put_line(fnd_file.log,
                          'UIC***** No. of Messages: ' || L_RETCODE ||
                          ', Message: ' || l_errbuf ||
                          ' From POS_BULKLOAD_ENTITIES.PROCESS_USER_ATTRS_DATA API.');
        errbuf  := 'WARNING****** Unexpected error occured in import UDA program.';
        retcode := 1;
      ELSE

	SELECT COUNT(1)
        INTO   l_error_count
        FROM   POS_SUPP_PROF_EXT_INTF
        WHERE  BATCH_ID = P_BATCH_ID
        AND    nvl(PROCESS_STATUS, 1) = 3;

        SELECT COUNT(1)
        INTO   l_uda_imported_count
        FROM   POS_SUPP_PROF_EXT_INTF
        WHERE  BATCH_ID = P_BATCH_ID
        AND    NVL(PROCESS_STATUS, 1) = 4;

        l_tot_err_count := l_tot_err_count + l_error_count;
      END IF;
      ----UDA Import


      fnd_file.put_line(fnd_file.log,
                        'Total Supplier UDA Import error count is : ' || l_tot_err_count);


    END IF;    ---IF (p_import_uda_only = 'N') THEN


  EXCEPTION
    WHEN OTHERS THEN
      errbuf  := fnd_message.get || '     ' || SQLERRM;
      retcode := 2;
      fnd_file.put_line(fnd_file.log,
                        ' Inside import_batch EXCEPTION ' || ' Message: ' ||
                        SQLCODE || ' ' || SQLERRM);
  END import_batch;

END pos_batch_import_pkg;

/
