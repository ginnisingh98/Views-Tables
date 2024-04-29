--------------------------------------------------------
--  DDL for Package Body POS_MERGE_SUPPLIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_MERGE_SUPPLIER_PKG" AS
  /* $Header: POSMRGSUPB.pls 120.0.12010000.9 2014/05/28 23:55:11 dalu noship $ */

  TYPE bank_dtls_rec_type IS RECORD(
    instrument_type  iby_pmt_instr_uses_all.instrument_type%TYPE,
    instrument_id    iby_pmt_instr_uses_all.instrument_id%TYPE,
    payment_function iby_pmt_instr_uses_all.payment_function%TYPE);

  TYPE bank_dtls_tab_type IS TABLE OF bank_dtls_rec_type INDEX BY BINARY_INTEGER;

  TYPE uda_rec_tbl_type IS TABLE OF pos_supp_prof_ext_b%ROWTYPE INDEX BY BINARY_INTEGER;

  TYPE attributes_rec IS RECORD(
    attr_name       ego_attrs_v.attr_name%TYPE,
    database_column ego_attrs_v.database_column%TYPE);

  TYPE attributes_coll_tab IS TABLE OF attributes_rec INDEX BY BINARY_INTEGER;
  attributes_coll attributes_coll_tab;

  PROCEDURE create_bus_attr
  (
    p_buss_class_rec    IN pos_bus_class_attr%ROWTYPE,
    p_party_id          IN hz_parties.party_id%TYPE,
    p_classification_id OUT NOCOPY NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
  ) IS
    l_classification_id NUMBER;
    l_status            VARCHAR2(100);
    l_exception_msg     VARCHAR2(100);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      'Inside POS_MERGE_SUPPLIER_PKG.create_bus_attr ');
    BEGIN
      pos_supp_classification_pkg.add_bus_class_attr(p_party_id,
                                                     p_buss_class_rec.vendor_id,
                                                     p_buss_class_rec.lookup_code,
                                                     p_buss_class_rec.expiration_date,
                                                     p_buss_class_rec.certificate_number,
                                                     p_buss_class_rec.certifying_agency,
                                                     p_buss_class_rec.ext_attr_1,
                                                     p_buss_class_rec.class_status,
                                                     '',
                                                     p_classification_id,
                                                     l_status,
                                                     l_exception_msg);

      fnd_file.put_line(fnd_file.log,
                        'l_exception_msg from pos_supp_classification_pkg.add_bus_class_attr : ' ||
                        l_exception_msg || ' for party id : ' || p_party_id);

    END;

    BEGIN
      pos_supp_classification_pkg.synchronize_class_tca_to_po(p_party_id,
                                                              p_buss_class_rec.vendor_id);
    END;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
  END create_bus_attr;

  PROCEDURE get_bus_attr_rec
  (
    p_party_id          IN hz_parties.party_id%TYPE,
    p_classification_id IN pos_bus_class_attr.classification_id%TYPE,
    x_buss_class_rec    OUT NOCOPY pos_bus_class_attr%ROWTYPE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
  ) IS

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    fnd_file.put_line(fnd_file.log,
                      'Inside POS_MERGE_SUPPLIER_PKG.get_bus_attr_rec ' ||
                      p_party_id);

    SELECT --classification_id,
    --vendor_id,
     lookup_type,
     lookup_code,
     start_date_active,
     end_date_active,
     status,
     ext_attr_1,
     expiration_date,
     certificate_number,
     certifying_agency,
     class_status,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5
    INTO   --x_buss_class_rec.classification_id,
           --x_buss_class_rec.vendor_id,
            x_buss_class_rec.lookup_type,
           x_buss_class_rec.lookup_code,
           x_buss_class_rec.start_date_active,
           x_buss_class_rec.end_date_active,
           x_buss_class_rec.status,
           x_buss_class_rec.ext_attr_1,
           x_buss_class_rec.expiration_date,
           x_buss_class_rec.certificate_number,
           x_buss_class_rec.certifying_agency,
           x_buss_class_rec.class_status,
           x_buss_class_rec.attribute1,
           x_buss_class_rec.attribute2,
           x_buss_class_rec.attribute3,
           x_buss_class_rec.attribute4,
           x_buss_class_rec.attribute5
    FROM   pos_bus_class_attr
    WHERE  party_id = p_party_id
    AND    classification_id = p_classification_id;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
  END get_bus_attr_rec;

  PROCEDURE buss_class_merge
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  ) IS
    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(100);

    l_count        NUMBER;
    buss_class_rec pos_bus_class_attr%ROWTYPE;
    l_to_vendor_id NUMBER;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      'Inside POS_MERGE_SUPPLIER_PKG.Buss_Class_Merge p_to_fk_id: ' ||
                      p_to_fk_id || ' p_from_fk_id: ' || p_from_fk_id ||
                      ' p_from_id: ' || p_from_id);

    /* Set the status to MERGED */
    UPDATE pos_bus_class_attr
    SET    status            = 'M',
           last_update_date  = hz_utility_pub.last_update_date,
           last_updated_by   = hz_utility_pub.user_id,
           last_update_login = hz_utility_pub.last_update_login
    WHERE  party_id = p_from_fk_id
    AND    classification_id = p_from_id;

    fnd_file.put_line(fnd_file.log, 'Rowcount: ' || SQL%ROWCOUNT);

    SELECT vendor_id
    INTO   l_to_vendor_id
    FROM   ap_suppliers
    WHERE  party_id = p_to_fk_id;

    fnd_file.put_line(fnd_file.log,
                      'Inside POS_MERGE_SUPPLIER_PKG.Buss_Class_Merge l_to_vendor_id: ' ||
                      l_to_vendor_id);

    DELETE FROM pos_supplier_mappings a
    WHERE  a.party_id = p_to_fk_id
    AND    a.vendor_id <> l_to_vendor_id
    AND    EXISTS (SELECT 1
            FROM   pos_supplier_mappings b
            WHERE  b.party_id = p_to_fk_id
            AND    vendor_id = l_to_vendor_id);

    UPDATE pos_supplier_mappings
    SET    vendor_id         = l_to_vendor_id,
           last_updated_by   = fnd_global.user_id,
           last_update_date  = SYSDATE,
           last_update_login = fnd_global.login_id
    WHERE  mapping_id IN (SELECT mapping_id
                          FROM   pos_supplier_mappings
                          WHERE  party_id = p_to_fk_id);

    fnd_file.put_line(fnd_file.log, 'Rowcount1: ' || SQL%ROWCOUNT);

    /* Check for the duplicate business classification details */
    SELECT COUNT(1)
    INTO   l_count
    FROM   pos_bus_class_attr attr_from,
           pos_bus_class_attr attr_to
    WHERE  attr_from.lookup_code = attr_to.lookup_code
    AND    attr_from.lookup_type = attr_to.lookup_type
          /*AND    nvl(attr_from.ext_attr_1, ' ') = nvl(attr_to.ext_attr_1, ' ')*/
    AND    attr_from.party_id = p_from_fk_id
    AND    attr_to.party_id = p_to_fk_id
    AND    attr_from.classification_id = p_from_id;
    /*AND    attr_from.classification_id = p_from_fk_id
    AND    attr_to.classification_id = p_to_fk_id;*/

    fnd_file.put_line(fnd_file.log,
                      'Inside POS_MERGE_SUPPLIER_PKG.Buss_Class_Merge l_count: ' ||
                      l_count);

    IF (l_count = 0) THEN
      BEGIN

        /* Get the details for the from party id */
        get_bus_attr_rec(p_party_id          => p_from_fk_id,
                         p_classification_id => p_from_id,
                         x_buss_class_rec    => buss_class_rec,
                         x_return_status     => x_return_status,
                         x_msg_count         => l_msg_count,
                         x_msg_data          => l_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name('AR', 'HZ_MERGE_SQL_ERROR');
          fnd_message.set_token('ERROR',
                                'Cannot get classification ID : ' ||
                                p_from_id);
          fnd_msg_pub.add;

          fnd_file.put_line(fnd_file.log,
                            'No. of Messages: ' || l_msg_count ||
                            ', Message: ' || l_msg_data ||
                            ' From get_bus_attr_rec API.');
          x_return_status := fnd_api.g_ret_sts_error;

          RETURN;
        END IF;

        --buss_class_rec.party_id := p_to_fk_id;
        buss_class_rec.vendor_id := l_to_vendor_id;

        /* Create the details for the to party id */
        create_bus_attr(p_buss_class_rec    => buss_class_rec,
                        p_party_id          => p_to_fk_id,
                        p_classification_id => x_to_id,
                        x_return_status     => x_return_status,
                        x_msg_count         => l_msg_count,
                        x_msg_data          => l_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name('AR', 'HZ_MERGE_SQL_ERROR');
          fnd_message.set_token('ERROR',
                                'Cannot copy classification ID : ' ||
                                p_from_id);
          fnd_msg_pub.add;

          fnd_file.put_line(fnd_file.log,
                            'No. of Messages: ' || l_msg_count ||
                            ', Message: ' || l_msg_data ||
                            ' From create_bus_attr API.');
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
        END IF;
      END;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log, 'In others : ' || SQLERRM);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END buss_class_merge;

  PROCEDURE create_prod_serv
  (
    p_vendor_prodsrv_rec IN pos_sup_products_services%ROWTYPE,
    p_party_id           IN hz_parties.party_id%TYPE,
    p_vendor_id          IN ap_suppliers.vendor_id%TYPE,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
  ) IS
    l_return_status VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);

    l_status         VARCHAR(2000);
    l_error_message  VARCHAR(4000);
    l_segment_concat VARCHAR2(4000) := NULL;

    l_mapping_id NUMBER;
    l_req_id     NUMBER := 0;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

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

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_file.put_line(fnd_file.log,
                        'No. of Messages: ' || l_msg_count || ', Message: ' ||
                        l_msg_data ||
                        ' From pos_product_service_utl_pkg.add_new_ps_req API.');
      RETURN;
    END IF;

    -- If the request_status is "APPROVED" then do the following
    -- IF (p_vendor_prodsrv_rec.request_status = 'APPROVED') THEN

    -- Get the mapping_id using the following SQLL
    SELECT mapping_id
    INTO   l_mapping_id
    FROM   pos_supplier_mappings
    WHERE  vendor_id = p_vendor_prodsrv_rec.vendor_id
    AND    party_id = p_party_id;

    pos_product_service_utl_pkg.initialize(x_status        => l_status,
                                           x_error_message => l_error_message);

    SELECT rtrim(nvl2(p_vendor_prodsrv_rec.segment1,
                      p_vendor_prodsrv_rec.segment1 || '.',
                      p_vendor_prodsrv_rec.segment1) ||
                 nvl2(p_vendor_prodsrv_rec.segment2,
                      p_vendor_prodsrv_rec.segment2 || '.',
                      p_vendor_prodsrv_rec.segment2) ||
                 nvl2(p_vendor_prodsrv_rec.segment3,
                      p_vendor_prodsrv_rec.segment3 || '.',
                      p_vendor_prodsrv_rec.segment3) ||
                 nvl2(p_vendor_prodsrv_rec.segment4,
                      p_vendor_prodsrv_rec.segment4 || '.',
                      p_vendor_prodsrv_rec.segment4) ||
                 nvl2(p_vendor_prodsrv_rec.segment5,
                      p_vendor_prodsrv_rec.segment5 || '.',
                      p_vendor_prodsrv_rec.segment5) ||
                 nvl2(p_vendor_prodsrv_rec.segment6,
                      p_vendor_prodsrv_rec.segment6 || '.',
                      p_vendor_prodsrv_rec.segment6) ||
                 nvl2(p_vendor_prodsrv_rec.segment7,
                      p_vendor_prodsrv_rec.segment7 || '.',
                      p_vendor_prodsrv_rec.segment7) ||
                 nvl2(p_vendor_prodsrv_rec.segment8,
                      p_vendor_prodsrv_rec.segment8 || '.',
                      p_vendor_prodsrv_rec.segment8) ||
                 nvl2(p_vendor_prodsrv_rec.segment9,
                      p_vendor_prodsrv_rec.segment9 || '.',
                      p_vendor_prodsrv_rec.segment9) ||
                 nvl2(p_vendor_prodsrv_rec.segment10,
                      p_vendor_prodsrv_rec.segment10 || '.',
                      p_vendor_prodsrv_rec.segment10) ||
                 nvl2(p_vendor_prodsrv_rec.segment11,
                      p_vendor_prodsrv_rec.segment11 || '.',
                      p_vendor_prodsrv_rec.segment11) ||
                 nvl2(p_vendor_prodsrv_rec.segment12,
                      p_vendor_prodsrv_rec.segment12 || '.',
                      p_vendor_prodsrv_rec.segment12) ||
                 nvl2(p_vendor_prodsrv_rec.segment13,
                      p_vendor_prodsrv_rec.segment13 || '.',
                      p_vendor_prodsrv_rec.segment13) ||
                 nvl2(p_vendor_prodsrv_rec.segment14,
                      p_vendor_prodsrv_rec.segment14 || '.',
                      p_vendor_prodsrv_rec.segment14) ||
                 nvl2(p_vendor_prodsrv_rec.segment15,
                      p_vendor_prodsrv_rec.segment15 || '.',
                      p_vendor_prodsrv_rec.segment15) ||
                 nvl2(p_vendor_prodsrv_rec.segment16,
                      p_vendor_prodsrv_rec.segment16 || '.',
                      p_vendor_prodsrv_rec.segment16) ||
                 nvl2(p_vendor_prodsrv_rec.segment17,
                      p_vendor_prodsrv_rec.segment17 || '.',
                      p_vendor_prodsrv_rec.segment17) ||
                 nvl2(p_vendor_prodsrv_rec.segment18,
                      p_vendor_prodsrv_rec.segment18 || '.',
                      p_vendor_prodsrv_rec.segment18) ||
                 nvl2(p_vendor_prodsrv_rec.segment19,
                      p_vendor_prodsrv_rec.segment19 || '.',
                      p_vendor_prodsrv_rec.segment19) ||
                 nvl2(p_vendor_prodsrv_rec.segment20,
                      p_vendor_prodsrv_rec.segment20 || '.',
                      p_vendor_prodsrv_rec.segment20),
                 '.')
    INTO   l_segment_concat
    FROM   dual;

    l_req_id := pos_product_service_utl_pkg.get_requestid(x_segment_code => l_segment_concat,
                                                          x_mapp_id      => l_mapping_id);

    -- Using the request_id make a call to the following  Api to approve the data and insert it into the
    -- pos_sup_products_services table
    pos_profile_change_request_pkg.approve_ps_req(p_request_id    => l_req_id,
                                                  x_return_status => l_return_status,
                                                  x_msg_count     => l_msg_count,
                                                  x_msg_data      => l_msg_data);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_file.put_line(fnd_file.log,
                        'No. of Messages: ' || l_msg_count || ', Message: ' ||
                        l_msg_data ||
                        ' From pos_profile_change_request_pkg.approve_ps_req API.');
      RETURN;
    END IF;
    --END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
  END create_prod_serv;

  FUNCTION get_prod_serv_rec
  (
    p_from_vendor_id    IN ap_suppliers.vendor_id%TYPE,
    p_to_vendor_id      IN ap_suppliers.vendor_id%TYPE,
    p_classification_id IN pos_bus_class_attr.classification_id%TYPE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_prod_services_rec OUT NOCOPY pos_sup_products_services%ROWTYPE
  ) RETURN NUMBER IS
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SELECT --classification_id,
     p_to_vendor_id,
     segment1,
     segment2,
     segment3,
     segment4,
     segment5,
     segment6,
     segment7,
     segment8,
     segment9,
     segment10,
     segment11,
     segment12,
     segment13,
     segment14,
     segment15,
     segment16,
     segment17,
     segment18,
     segment19,
     segment20,
     status,
     segment_definition
    INTO   --x_prod_services_rec . classification_id,
           x_prod_services_rec.vendor_id,
           x_prod_services_rec.segment1,
           x_prod_services_rec.segment2,
           x_prod_services_rec.segment3,
           x_prod_services_rec.segment4,
           x_prod_services_rec.segment5,
           x_prod_services_rec.segment6,
           x_prod_services_rec.segment7,
           x_prod_services_rec.segment8,
           x_prod_services_rec.segment9,
           x_prod_services_rec.segment10,
           x_prod_services_rec.segment11,
           x_prod_services_rec.segment12,
           x_prod_services_rec.segment13,
           x_prod_services_rec.segment14,
           x_prod_services_rec.segment15,
           x_prod_services_rec.segment16,
           x_prod_services_rec.segment17,
           x_prod_services_rec.segment18,
           x_prod_services_rec.segment19,
           x_prod_services_rec.segment20,
           x_prod_services_rec.status,
           x_prod_services_rec.segment_definition
    FROM   pos_sup_products_services
    WHERE  vendor_id = p_from_vendor_id
    AND    classification_id = p_classification_id
          /* Picking the products and services that are not already
          associated with the To Party*/
    AND    (segment1, segment2, segment3, segment4, segment5, segment6,
           segment7, segment8, segment9, segment10, segment11, segment12,
           segment13, segment14, segment15, segment16, segment17,
           segment18, segment19, segment20, segment_definition) NOT IN
           (SELECT segment1,
                    segment2,
                    segment3,
                    segment4,
                    segment5,
                    segment6,
                    segment7,
                    segment8,
                    segment9,
                    segment10,
                    segment11,
                    segment12,
                    segment13,
                    segment14,
                    segment15,
                    segment16,
                    segment17,
                    segment18,
                    segment19,
                    segment20,
                    segment_definition
             FROM   pos_sup_products_services
             WHERE  vendor_id = p_to_vendor_id);

    RETURN 1;

  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      RETURN 0;
  END get_prod_serv_rec;

  PROCEDURE prod_service_merge
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  ) IS
    l_prod_services_rec pos_sup_products_services%ROWTYPE;
    l_from_vendor_id    NUMBER;
    l_to_vendor_id      NUMBER;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_row_count         NUMBER := 0;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      'Inside POS_MERGE_SUPPLIER_PKG.prod_service_merge p_to_fk_id: ' ||
                      p_to_fk_id || ' p_from_fk_id: ' || p_from_fk_id ||
                      ' p_from_id : ' || p_from_id);

    SELECT vendor_id
    INTO   l_from_vendor_id
    FROM   ap_suppliers
    WHERE  party_id = p_from_fk_id;

    SELECT vendor_id
    INTO   l_to_vendor_id
    FROM   ap_suppliers
    WHERE  party_id = p_to_fk_id;

    /* Set the status to MERGED */
    UPDATE pos_sup_products_services
    SET    status            = 'M',
           last_update_date  = SYSDATE,
           last_updated_by   = hz_utility_pub.user_id,
           last_update_login = hz_utility_pub.last_update_login
    WHERE  vendor_id = l_from_vendor_id
    AND    classification_id = p_from_id;

    DELETE FROM pos_supplier_mappings a
    WHERE  a.party_id = p_to_fk_id
    AND    a.vendor_id <> l_to_vendor_id
    AND    EXISTS (SELECT 1
            FROM   pos_supplier_mappings b
            WHERE  b.party_id = p_to_fk_id
            AND    vendor_id = l_to_vendor_id);

    UPDATE pos_supplier_mappings
    SET    vendor_id         = l_to_vendor_id,
           last_updated_by   = fnd_global.user_id,
           last_update_date  = SYSDATE,
           last_update_login = fnd_global.login_id
    WHERE  mapping_id IN (SELECT mapping_id
                          FROM   pos_supplier_mappings
                          WHERE  party_id = p_to_fk_id);

    /* Get the details for the from party id */

    l_row_count := get_prod_serv_rec(l_from_vendor_id,
                                     l_to_vendor_id,
                                     p_from_id,
                                     x_return_status,
                                     l_msg_count,
                                     l_msg_data,
                                     l_prod_services_rec);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('AR', 'HZ_MERGE_SQL_ERROR');
      fnd_message.set_token('ERROR',
                            'Cannot get classification ID : ' || p_from_id);
      fnd_msg_pub.add;

      fnd_file.put_line(fnd_file.log,
                        'No. of Messages: ' || l_msg_count || ', Message: ' ||
                        l_msg_data || ' From get_prod_serv_rec API.');
      x_return_status := fnd_api.g_ret_sts_error;

      RETURN;
    END IF;

    IF (l_row_count <> 0) THEN
      create_prod_serv(l_prod_services_rec,
                       p_to_fk_id,
                       l_to_vendor_id,
                       x_return_status,
                       l_msg_count,
                       l_msg_data);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('AR', 'HZ_MERGE_SQL_ERROR');
        fnd_message.set_token('ERROR',
                              'Cannot copy classification ID : ' ||
                              p_from_id);
        fnd_msg_pub.add;

        fnd_file.put_line(fnd_file.log,
                          'No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From create_prod_serv API.');
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END prod_service_merge;

  PROCEDURE party_contact_merge
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  ) IS
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    l_party_id                   NUMBER;
    l_party_usg_rec              hz_party_usg_assignment_pvt.party_usg_assignment_rec_type;
    l_party_usg_validation_level NUMBER;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      'Inside POS_MERGE_SUPPLIER_PKG.party_contact_merge p_to_fk_id: ' ||
                      p_to_fk_id || ' p_from_fk_id: ' || p_from_fk_id ||
                      ' p_from_id : ' || p_from_id);

    l_party_id := p_to_fk_id;

    l_party_usg_validation_level      := hz_party_usg_assignment_pvt.g_valid_level_none;
    l_party_usg_rec.party_id          := l_party_id;
    l_party_usg_rec.party_usage_code  := 'SUPPLIER_CONTACT';
    l_party_usg_rec.created_by_module := 'AP_SUPPLIERS_MERGE';

    /* Enable party contact as supplier contact by
    setting usage code as SUPPLIER_CONTACT */
    hz_party_usg_assignment_pvt.assign_party_usage(p_validation_level         => l_party_usg_validation_level,
                                                   p_party_usg_assignment_rec => l_party_usg_rec,
                                                   x_return_status            => x_return_status,
                                                   x_msg_count                => l_msg_count,
                                                   x_msg_data                 => l_msg_data);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_file.put_line(fnd_file.log,
                        'No. of Messages: ' || l_msg_count || ', Message: ' ||
                        l_msg_data ||
                        ' From hz_party_usg_assignment_pvt.assign_party_usage API.');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END party_contact_merge;

  PROCEDURE create_bank_dtls
  (
    p_init_msg_list      IN VARCHAR2 := fnd_api.g_false,
    p_payee              IN iby_disbursement_setup_pub.payeecontext_rec_type,
    p_assignment_attribs IN iby_fndcpt_setup_pub.pmtinstrassignment_rec_type,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
  ) IS
    l_assign_id NUMBER;
    l_response  iby_fndcpt_common_pub.result_rec_type;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    BEGIN
      iby_disbursement_setup_pub.set_payee_instr_assignment(p_api_version        => '1.0',
                                                            x_return_status      => x_return_status,
                                                            x_msg_count          => x_msg_count,
                                                            x_msg_data           => x_msg_data,
                                                            p_payee              => p_payee,
                                                            p_assignment_attribs => p_assignment_attribs,
                                                            x_assign_id          => l_assign_id,
                                                            x_response           => l_response);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_file.put_line(fnd_file.log,
                          'No. of Messages: ' || x_msg_count ||
                          ', Message: ' || x_msg_data ||
                          ' From iby_disbursement_setup_pub.set_payee_instr_assignment API.');
      END IF;
    END;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
  END create_bank_dtls;

  PROCEDURE get_bank_dtls_rec
  (
    p_init_msg_list     IN VARCHAR2 := fnd_api.g_false,
    p_from_party        IN hz_parties.party_id%TYPE,
    p_to_party          IN hz_parties.party_id%TYPE,
    x_bank_dtls_rec_tbl OUT NOCOPY bank_dtls_tab_type,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
  ) IS
   -- Bug 14261475 - merge performance: full table scan on iby_pmt_instr_uses_all
    CURSOR bank_cur IS
      SELECT paymentinstrumentuseseo.instrument_type,
             paymentinstrumentuseseo.instrument_id,
             paymentinstrumentuseseo.payment_function
      FROM   iby_pmt_instr_uses_all  paymentinstrumentuseseo
             --iby_ext_bank_accounts_v ibyextbankaccts
      WHERE  --paymentinstrumentuseseo.instrument_id = ibyextbankaccts.bank_account_id AND
       paymentinstrumentuseseo.instrument_type = 'BANKACCOUNT'
       --Enforce the IBY_PMT_INSTR_USES_ALL_N1 index PAYMENT_FLOW,EXT_PMT_PARTY_ID
      AND    paymentinstrumentuseseo.payment_flow = 'DISBURSEMENTS'  -- Bug 18664901: Get Payee Accounts Only
      AND    ext_pmt_party_id IN
             (SELECT ext_payee_id
               FROM   iby_external_payees_all
               WHERE  payee_party_id = p_from_party
               AND    org_id IS NULL
               AND    party_site_id IS NULL
               AND    supplier_site_id IS NULL)
      AND    /* Excluding the accounts that are already associated*/
             paymentinstrumentuseseo.instrument_id NOT IN
             (SELECT instrument_id
              FROM   iby_external_payees_all extpayee,
                     iby_pmt_instr_uses_all  instr
              WHERE  extpayee.payee_party_id = p_to_party
              AND    extpayee.org_id IS NULL
              AND    extpayee.party_site_id IS NULL
              AND    extpayee.supplier_site_id IS NULL
              AND    extpayee.ext_payee_id = ext_pmt_party_id
              AND    instr.instrument_type = 'BANKACCOUNT');

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN bank_cur;
    FETCH bank_cur BULK COLLECT
      INTO x_bank_dtls_rec_tbl;
    CLOSE bank_cur;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
  END get_bank_dtls_rec;

  PROCEDURE bank_dtls_merge
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  ) IS
    l_return_status VARCHAR2(100);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(100);

    l_bank_dtls_rec_tbl bank_dtls_tab_type;
    l_rec               iby_disbursement_setup_pub.payeecontext_rec_type;
    l_assign            iby_fndcpt_setup_pub.pmtinstrassignment_rec_type;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      'Inside POS_MERGE_SUPPLIER_PKG.bank_dtls_merge p_to_fk_id: ' ||
                      p_to_fk_id || ' p_to_fk_id: ' || p_from_fk_id);

    get_bank_dtls_rec(p_init_msg_list     => 'T',
                      p_from_party        => p_from_fk_id,
                      p_to_party          => p_to_fk_id,
                      x_bank_dtls_rec_tbl => l_bank_dtls_rec_tbl,
                      x_return_status     => x_return_status,
                      x_msg_count         => l_msg_count,
                      x_msg_data          => l_msg_data);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('AR', 'HZ_MERGE_SQL_ERROR');
      fnd_message.set_token('ERROR',
                            'Cannot get Bank Details : ' || p_from_id);
      fnd_msg_pub.add;

      fnd_file.put_line(fnd_file.log,
                        'No. of Messages: ' || l_msg_count || ', Message: ' ||
                        l_msg_data || ' From get_bank_dtls_rec API.');
      x_return_status := fnd_api.g_ret_sts_error;

      RETURN;
    END IF;

    -- Add all the accounts in the collection

    FOR cntr IN 1 .. l_bank_dtls_rec_tbl.count LOOP

      l_rec.party_id         := p_to_fk_id;
      l_rec.payment_function := l_bank_dtls_rec_tbl(cntr).payment_function;
      l_rec.org_type         := NULL;
      l_rec.org_id           := NULL;
      l_rec.party_site_id    := NULL;
      l_rec.supplier_site_id := NULL;

      l_assign.instrument.instrument_type := l_bank_dtls_rec_tbl(cntr)
                                             .instrument_type;
      l_assign.instrument.instrument_id   := l_bank_dtls_rec_tbl(cntr)
                                             .instrument_id;

      create_bank_dtls(p_init_msg_list      => 'T',
                       p_payee              => l_rec,
                       p_assignment_attribs => l_assign,
                       x_return_status      => x_return_status,
                       x_msg_count          => l_msg_count,
                       x_msg_data           => l_msg_data);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('AR', 'HZ_MERGE_SQL_ERROR');
        fnd_message.set_token('ERROR',
                              'Cannot copy Bank Details : ' || p_from_id);
        fnd_msg_pub.add;

        fnd_file.put_line(fnd_file.log,
                          'No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From create_bank_dtls API.');
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END bank_dtls_merge;

  PROCEDURE get_batch_user_attr_data
  (
    p_to_party_id        IN NUMBER,
    p_batch_id           IN NUMBER,
    p_multirow_flag      IN VARCHAR2,
    p_attribute_group_id IN NUMBER,
    p_data_level_id      IN NUMBER,
    x_uda_rec_tbl        OUT NOCOPY uda_rec_tbl_type,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
  ) IS
    CURSOR multirow_cur IS
      SELECT *
      FROM   pos_supp_prof_ext_b
      WHERE  attr_group_id = p_attribute_group_id
      AND    data_level_id = p_data_level_id
      AND    party_id IN ( -- Only from parties
                          SELECT from_party_id
                          FROM   hz_merge_parties
                          WHERE  batch_id = p_batch_id
                                --AND    merge_status = 'DONE'
                          AND    merge_type <> 'SAME_PARTY_MERGE'
                          AND    to_party_id = p_to_party_id)
      ORDER  BY last_update_date;

    CURSOR singlerow_cur IS
      SELECT *
      FROM   (SELECT *
              FROM   pos_supp_prof_ext_b
              WHERE  attr_group_id = p_attribute_group_id
              AND    data_level_id = p_data_level_id
              AND    party_id IN
                     (SELECT from_party_id
                       FROM   hz_merge_parties
                       WHERE  batch_id = p_batch_id
                       AND    merge_type <> 'SAME_PARTY_MERGE'
                       AND    to_party_id = p_to_party_id)
              ORDER  BY last_update_date)
      UNION ALL (SELECT *
                 FROM   pos_supp_prof_ext_b
                 WHERE  attr_group_id = p_attribute_group_id
                 AND    data_level_id = p_data_level_id
                 AND    party_id = p_to_party_id);
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    /* If the attribute group is single row then we have to get the
    data for the from as well as the to party.
    For Multirow attribute we need to get the data only for the
    from parties */

    IF (p_multirow_flag = 'Y') THEN

      /* Multirow processing */
      /* Bulk collect the data into the collection defined as out
      parameter*/
      OPEN multirow_cur;
      FETCH multirow_cur BULK COLLECT
        INTO x_uda_rec_tbl;
      CLOSE multirow_cur;
    ELSE
      /* single Row processing */
      /* Bulk collect the data into the collection defined as out
      parameter*/
      OPEN singlerow_cur;
      FETCH singlerow_cur BULK COLLECT
        INTO x_uda_rec_tbl;
      CLOSE singlerow_cur;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END get_batch_user_attr_data;

  PROCEDURE get_party_site_attr_data
  (
    p_from_party_id      IN NUMBER,
    p_to_party_id        IN NUMBER,
    p_batch_id           IN NUMBER,
    p_multirow_flag      IN VARCHAR2,
    p_attribute_group_id IN NUMBER,
    p_data_level_id      IN NUMBER,
    x_uda_rec_tbl        OUT NOCOPY uda_rec_tbl_type,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
  ) IS

    CURSOR multirow_cur IS
      SELECT *
      FROM   pos_supp_prof_ext_b
      WHERE  attr_group_id = p_attribute_group_id
      AND    data_level_id = p_data_level_id
      AND    (party_id, pk1_value) IN
             (SELECT fromparty.party_id,
                      merge_from_entity_id
               FROM   hz_merge_party_details site,
                      hz_party_sites         fromparty,
                      hz_party_sites         toparty,
                      hz_merge_parties       batch
               WHERE  fromparty.party_site_id = merge_from_entity_id
               AND    toparty.party_site_id = merge_to_entity_id
               AND    batch.batch_id = p_batch_id
               AND    batch.batch_party_id = site.batch_party_id
               AND    merge_to_entity_id IN
                      (SELECT merge_to_entity_id
                        FROM   hz_merge_party_details site2
                        WHERE  site2.batch_party_id = site.batch_party_id
                        AND    merge_from_entity_id = p_from_party_id))
      ORDER  BY last_update_date;

    CURSOR singlerow_cur IS
      SELECT *
      FROM   (SELECT *
              FROM   pos_supp_prof_ext_b
              WHERE  attr_group_id = p_attribute_group_id
              AND    data_level_id = p_data_level_id
              AND    (party_id, pk1_value) IN
                     (SELECT fromparty.party_id,
                              merge_from_entity_id
                       FROM   hz_merge_party_details site,
                              hz_party_sites         fromparty,
                              hz_party_sites         toparty,
                              hz_merge_parties       batch
                       WHERE  fromparty.party_site_id = merge_from_entity_id
                       AND    toparty.party_site_id = merge_to_entity_id
                       AND    batch.batch_id = p_batch_id
                       AND    batch.batch_party_id = site.batch_party_id
                       AND    merge_to_entity_id IN
                              (SELECT merge_to_entity_id
                                FROM   hz_merge_party_details site2
                                WHERE  site2.batch_party_id =
                                       site.batch_party_id
                                AND    merge_from_entity_id = p_from_party_id))
              ORDER  BY last_update_date)
      UNION ALL
      SELECT *
      FROM   pos_supp_prof_ext_b
      WHERE  attr_group_id = p_attribute_group_id
      AND    data_level_id = p_data_level_id
      AND    pk1_value = p_to_party_id;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF (p_multirow_flag = 'Y') THEN
      OPEN multirow_cur;
      FETCH multirow_cur BULK COLLECT
        INTO x_uda_rec_tbl;
      CLOSE multirow_cur;
    ELSE
      OPEN singlerow_cur;
      FETCH singlerow_cur BULK COLLECT
        INTO x_uda_rec_tbl;
      CLOSE singlerow_cur;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END get_party_site_attr_data;

  PROCEDURE get_supp_site_attr_data
  (
    p_from_party_id      IN NUMBER,
    p_to_party_id        IN NUMBER,
    p_multirow_flag      IN VARCHAR2,
    p_attribute_group_id IN NUMBER,
    p_data_level_id      IN NUMBER,
    x_uda_rec_tbl        OUT NOCOPY uda_rec_tbl_type,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
  ) IS

    CURSOR multirow_cur IS
      SELECT *
      FROM   pos_supp_prof_ext_b
      WHERE  attr_group_id = p_attribute_group_id
      AND    data_level_id = p_data_level_id
      AND    pk2_value = p_from_party_id
      ORDER  BY last_update_date;

    CURSOR singlerow_cur IS
      SELECT *
      FROM   pos_supp_prof_ext_b
      WHERE  attr_group_id = p_attribute_group_id
      AND    data_level_id = p_data_level_id
      AND    pk2_value = p_from_party_id
      UNION ALL
      SELECT *
      FROM   pos_supp_prof_ext_b
      WHERE  attr_group_id = p_attribute_group_id
      AND    data_level_id = p_data_level_id
      AND    pk2_value = p_to_party_id;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    IF (p_multirow_flag = 'Y') THEN
      OPEN multirow_cur;
      FETCH multirow_cur BULK COLLECT
        INTO x_uda_rec_tbl;
      CLOSE multirow_cur;
    ELSE
      OPEN singlerow_cur;
      FETCH singlerow_cur BULK COLLECT
        INTO x_uda_rec_tbl;
      CLOSE singlerow_cur;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END get_supp_site_attr_data;

  PROCEDURE build_uda_data_payload
  (
    p_attribute_group_id    IN NUMBER,
    p_attribute_group_type  IN VARCHAR2,
    p_attribute_group_name  IN VARCHAR2,
    p_row_identifier        IN NUMBER,
    p_uda_data_rec          IN pos_supp_prof_ext_b%ROWTYPE,
    x_attributes_data_table IN OUT NOCOPY ego_user_attr_data_table
  ) IS

    CURSOR get_attributes IS
      SELECT attr_name,
             database_column
      FROM   ego_attrs_v
      WHERE  application_id = 177
      AND    attr_group_name = p_attribute_group_name
      AND    attr_group_type = p_attribute_group_type;

  BEGIN

    /* Open the cursor and bulk collect the attributes information into
    a collection */
    OPEN get_attributes;
    FETCH get_attributes BULK COLLECT
      INTO attributes_coll;
    CLOSE get_attributes;

    /* Loop through the attributes collection and traverse the following case structure */

    FOR attrcntr IN 1 .. attributes_coll.count LOOP
      --x_attributes_data_table.extend;
      CASE attributes_coll(attrcntr).database_column

      /* Process Character attributes */

        WHEN 'C_EXT_ATTR1' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr1 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR2' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr2 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR3' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr3 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR4' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr4 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR5' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr5 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR6' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr6 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR7' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr7 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR8' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr8 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);

        WHEN 'C_EXT_ATTR9' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr9 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR10' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr10 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR11' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr11 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR12' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr12 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR13' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr13 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR14' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr14 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR15' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr15 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR16' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr16 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR17' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr17 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR18' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr18 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR19' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr19 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);

        WHEN 'C_EXT_ATTR20' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr20 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR21' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr21 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR22' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr22 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR23' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr23 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR24' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr24 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR25' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr25 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR26' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr26 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR27' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr27 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR28' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr28 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR29' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr29 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR30' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr30 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR31' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr31 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR32' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr32 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR33' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr33 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR34' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr34 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR35' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr35 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR36' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr36 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR37' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr37 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR38' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr38 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR39' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr39 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'C_EXT_ATTR40' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      p_uda_data_rec.c_ext_attr40 --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);

      /* Process Numeric attributes */

        WHEN 'N_EXT_ATTR1' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr1 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR2' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr2 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR3' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr3 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR4' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr4 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR5' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr5 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR6' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr6 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR7' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr7 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR8' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr8 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);

        WHEN 'N_EXT_ATTR9' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr9 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR10' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr10 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR11' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr11 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR12' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr12 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR13' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr13 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR14' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr14 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR15' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr15 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR16' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr16 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR17' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr17 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR18' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr18 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'N_EXT_ATTR19' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr19 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);

        WHEN 'N_EXT_ATTR20' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      p_uda_data_rec.n_ext_attr20 --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);

      /* Process Date attributes */

        WHEN 'D_EXT_ATTR1' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      p_uda_data_rec.d_ext_attr1 --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'D_EXT_ATTR2' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      p_uda_data_rec.d_ext_attr2 --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'D_EXT_ATTR3' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      p_uda_data_rec.d_ext_attr3 --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'D_EXT_ATTR4' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      p_uda_data_rec.d_ext_attr4 --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'D_EXT_ATTR5' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      p_uda_data_rec.d_ext_attr5 --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'D_EXT_ATTR6' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      p_uda_data_rec.d_ext_attr6 --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'D_EXT_ATTR7' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      p_uda_data_rec.d_ext_attr7 --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);
        WHEN 'D_EXT_ATTR8' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      p_uda_data_rec.d_ext_attr8 --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);

        WHEN 'D_EXT_ATTR9' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      p_uda_data_rec.d_ext_attr9 --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);

        WHEN 'D_EXT_ATTR10' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      p_uda_data_rec.d_ext_attr10 --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL --ATTR_UNIT_OF_MEASURE
                                                                     ,
                                                                      NULL);

      /* Process UOM attributes */

        WHEN 'UOM_EXT_ATTR1' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr1,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR2' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr2,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR3' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr3,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR4' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr4,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR5' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr5,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR6' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr6,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR7' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr7,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR8' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr8,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR9' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr9,
                                                                      NULL);

        WHEN 'UOM_EXT_ATTR10' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr10,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR11' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr11,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR12' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr12,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR13' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr13,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR14' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr14,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR15' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr15,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR16' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr16,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR17' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr17,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR18' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr18,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR19' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr19,
                                                                      NULL);
        WHEN 'UOM_EXT_ATTR20' THEN
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      p_uda_data_rec.uom_ext_attr20,
                                                                      NULL);

        ELSE
          x_attributes_data_table(attrcntr) := ego_user_attr_data_obj(p_row_identifier,
                                                                      attributes_coll(attrcntr)
                                                                      .attr_name,
                                                                      NULL --ATTR_VALUE_STR
                                                                     ,
                                                                      NULL --ATTR_VALUE_NUM
                                                                     ,
                                                                      NULL --ATTR_VALUE_DATE
                                                                     ,
                                                                      NULL --ATTR_DISP_VALUE
                                                                     ,
                                                                      NULL,
                                                                      NULL);

      END CASE;
      x_attributes_data_table.extend;
    END LOOP;
    x_attributes_data_table.trim;

    /*EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;*/
  END build_uda_data_payload;

  PROCEDURE do_single_row_uda_merge
  (
    p_uda_rec_tbl   IN OUT NOCOPY uda_rec_tbl_type,
    x_uda_rec       OUT NOCOPY pos_supp_prof_ext_b%ROWTYPE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    /* The collection contains the UDA data in the ascending
    order of the creation date. The idea is to have the
    latest data in the final merged record. So we would
    start with the index 2 in the collection and merge it
    with the index 1 record and repeat the same until we
    reach the last record in the collection. We would use
    NVL on the attributes to ensure that if the any record has a NULL
    value for a n attribute it does not override the attribute
    containing the data even if for an older date*/

    FOR cntr IN 2 .. p_uda_rec_tbl.count LOOP

      /* Merge character extension attributes */

      p_uda_rec_tbl(1).c_ext_attr1 := nvl(p_uda_rec_tbl(cntr).c_ext_attr1,
                                          p_uda_rec_tbl(1).c_ext_attr1);
      p_uda_rec_tbl(1).c_ext_attr2 := nvl(p_uda_rec_tbl(cntr).c_ext_attr2,
                                          p_uda_rec_tbl(1).c_ext_attr2);
      p_uda_rec_tbl(1).c_ext_attr3 := nvl(p_uda_rec_tbl(cntr).c_ext_attr3,
                                          p_uda_rec_tbl(1).c_ext_attr3);
      p_uda_rec_tbl(1).c_ext_attr4 := nvl(p_uda_rec_tbl(cntr).c_ext_attr4,
                                          p_uda_rec_tbl(1).c_ext_attr4);
      p_uda_rec_tbl(1).c_ext_attr5 := nvl(p_uda_rec_tbl(cntr).c_ext_attr5,
                                          p_uda_rec_tbl(1).c_ext_attr5);
      p_uda_rec_tbl(1).c_ext_attr6 := nvl(p_uda_rec_tbl(cntr).c_ext_attr6,
                                          p_uda_rec_tbl(1).c_ext_attr6);
      p_uda_rec_tbl(1).c_ext_attr7 := nvl(p_uda_rec_tbl(cntr).c_ext_attr7,
                                          p_uda_rec_tbl(1).c_ext_attr7);
      p_uda_rec_tbl(1).c_ext_attr8 := nvl(p_uda_rec_tbl(cntr).c_ext_attr8,
                                          p_uda_rec_tbl(1).c_ext_attr8);
      p_uda_rec_tbl(1).c_ext_attr9 := nvl(p_uda_rec_tbl(cntr).c_ext_attr9,
                                          p_uda_rec_tbl(1).c_ext_attr9);
      p_uda_rec_tbl(1).c_ext_attr10 := nvl(p_uda_rec_tbl(cntr).c_ext_attr10,
                                           p_uda_rec_tbl(1).c_ext_attr10);

      p_uda_rec_tbl(1).c_ext_attr11 := nvl(p_uda_rec_tbl(cntr).c_ext_attr11,
                                           p_uda_rec_tbl(1).c_ext_attr11);
      p_uda_rec_tbl(1).c_ext_attr12 := nvl(p_uda_rec_tbl(cntr).c_ext_attr12,
                                           p_uda_rec_tbl(1).c_ext_attr12);
      p_uda_rec_tbl(1).c_ext_attr13 := nvl(p_uda_rec_tbl(cntr).c_ext_attr13,
                                           p_uda_rec_tbl(1).c_ext_attr13);
      p_uda_rec_tbl(1).c_ext_attr14 := nvl(p_uda_rec_tbl(cntr).c_ext_attr14,
                                           p_uda_rec_tbl(1).c_ext_attr14);
      p_uda_rec_tbl(1).c_ext_attr15 := nvl(p_uda_rec_tbl(cntr).c_ext_attr15,
                                           p_uda_rec_tbl(1).c_ext_attr15);
      p_uda_rec_tbl(1).c_ext_attr16 := nvl(p_uda_rec_tbl(cntr).c_ext_attr16,
                                           p_uda_rec_tbl(1).c_ext_attr16);
      p_uda_rec_tbl(1).c_ext_attr17 := nvl(p_uda_rec_tbl(cntr).c_ext_attr17,
                                           p_uda_rec_tbl(1).c_ext_attr17);
      p_uda_rec_tbl(1).c_ext_attr18 := nvl(p_uda_rec_tbl(cntr).c_ext_attr18,
                                           p_uda_rec_tbl(1).c_ext_attr18);
      p_uda_rec_tbl(1).c_ext_attr19 := nvl(p_uda_rec_tbl(cntr).c_ext_attr19,
                                           p_uda_rec_tbl(1).c_ext_attr19);
      p_uda_rec_tbl(1).c_ext_attr20 := nvl(p_uda_rec_tbl(cntr).c_ext_attr20,
                                           p_uda_rec_tbl(1).c_ext_attr20);

      p_uda_rec_tbl(1).c_ext_attr21 := nvl(p_uda_rec_tbl(cntr).c_ext_attr21,
                                           p_uda_rec_tbl(1).c_ext_attr21);
      p_uda_rec_tbl(1).c_ext_attr22 := nvl(p_uda_rec_tbl(cntr).c_ext_attr22,
                                           p_uda_rec_tbl(1).c_ext_attr22);
      p_uda_rec_tbl(1).c_ext_attr23 := nvl(p_uda_rec_tbl(cntr).c_ext_attr23,
                                           p_uda_rec_tbl(1).c_ext_attr23);
      p_uda_rec_tbl(1).c_ext_attr24 := nvl(p_uda_rec_tbl(cntr).c_ext_attr24,
                                           p_uda_rec_tbl(1).c_ext_attr24);
      p_uda_rec_tbl(1).c_ext_attr25 := nvl(p_uda_rec_tbl(cntr).c_ext_attr25,
                                           p_uda_rec_tbl(1).c_ext_attr25);
      p_uda_rec_tbl(1).c_ext_attr26 := nvl(p_uda_rec_tbl(cntr).c_ext_attr26,
                                           p_uda_rec_tbl(1).c_ext_attr26);
      p_uda_rec_tbl(1).c_ext_attr27 := nvl(p_uda_rec_tbl(cntr).c_ext_attr27,
                                           p_uda_rec_tbl(1).c_ext_attr27);
      p_uda_rec_tbl(1).c_ext_attr28 := nvl(p_uda_rec_tbl(cntr).c_ext_attr28,
                                           p_uda_rec_tbl(1).c_ext_attr28);
      p_uda_rec_tbl(1).c_ext_attr29 := nvl(p_uda_rec_tbl(cntr).c_ext_attr29,
                                           p_uda_rec_tbl(1).c_ext_attr29);
      p_uda_rec_tbl(1).c_ext_attr30 := nvl(p_uda_rec_tbl(cntr).c_ext_attr30,
                                           p_uda_rec_tbl(1).c_ext_attr30);

      p_uda_rec_tbl(1).c_ext_attr31 := nvl(p_uda_rec_tbl(cntr).c_ext_attr31,
                                           p_uda_rec_tbl(1).c_ext_attr31);
      p_uda_rec_tbl(1).c_ext_attr32 := nvl(p_uda_rec_tbl(cntr).c_ext_attr32,
                                           p_uda_rec_tbl(1).c_ext_attr32);
      p_uda_rec_tbl(1).c_ext_attr33 := nvl(p_uda_rec_tbl(cntr).c_ext_attr33,
                                           p_uda_rec_tbl(1).c_ext_attr33);
      p_uda_rec_tbl(1).c_ext_attr34 := nvl(p_uda_rec_tbl(cntr).c_ext_attr34,
                                           p_uda_rec_tbl(1).c_ext_attr34);
      p_uda_rec_tbl(1).c_ext_attr35 := nvl(p_uda_rec_tbl(cntr).c_ext_attr35,
                                           p_uda_rec_tbl(1).c_ext_attr35);
      p_uda_rec_tbl(1).c_ext_attr36 := nvl(p_uda_rec_tbl(cntr).c_ext_attr36,
                                           p_uda_rec_tbl(1).c_ext_attr36);
      p_uda_rec_tbl(1).c_ext_attr37 := nvl(p_uda_rec_tbl(cntr).c_ext_attr37,
                                           p_uda_rec_tbl(1).c_ext_attr37);
      p_uda_rec_tbl(1).c_ext_attr38 := nvl(p_uda_rec_tbl(cntr).c_ext_attr38,
                                           p_uda_rec_tbl(1).c_ext_attr38);
      p_uda_rec_tbl(1).c_ext_attr39 := nvl(p_uda_rec_tbl(cntr).c_ext_attr39,
                                           p_uda_rec_tbl(1).c_ext_attr39);
      p_uda_rec_tbl(1).c_ext_attr40 := nvl(p_uda_rec_tbl(cntr).c_ext_attr40,
                                           p_uda_rec_tbl(1).c_ext_attr40);

      /* Merge numeric extension attributes */

      p_uda_rec_tbl(1).n_ext_attr1 := nvl(p_uda_rec_tbl(cntr).n_ext_attr1,
                                          p_uda_rec_tbl(1).n_ext_attr1);
      p_uda_rec_tbl(1).n_ext_attr2 := nvl(p_uda_rec_tbl(cntr).n_ext_attr2,
                                          p_uda_rec_tbl(1).n_ext_attr2);
      p_uda_rec_tbl(1).n_ext_attr3 := nvl(p_uda_rec_tbl(cntr).n_ext_attr3,
                                          p_uda_rec_tbl(1).n_ext_attr3);
      p_uda_rec_tbl(1).n_ext_attr4 := nvl(p_uda_rec_tbl(cntr).n_ext_attr4,
                                          p_uda_rec_tbl(1).n_ext_attr4);
      p_uda_rec_tbl(1).n_ext_attr5 := nvl(p_uda_rec_tbl(cntr).n_ext_attr5,
                                          p_uda_rec_tbl(1).n_ext_attr5);
      p_uda_rec_tbl(1).n_ext_attr6 := nvl(p_uda_rec_tbl(cntr).n_ext_attr6,
                                          p_uda_rec_tbl(1).n_ext_attr6);
      p_uda_rec_tbl(1).n_ext_attr7 := nvl(p_uda_rec_tbl(cntr).n_ext_attr7,
                                          p_uda_rec_tbl(1).n_ext_attr7);
      p_uda_rec_tbl(1).n_ext_attr8 := nvl(p_uda_rec_tbl(cntr).n_ext_attr8,
                                          p_uda_rec_tbl(1).n_ext_attr8);
      p_uda_rec_tbl(1).n_ext_attr9 := nvl(p_uda_rec_tbl(cntr).n_ext_attr9,
                                          p_uda_rec_tbl(1).n_ext_attr9);
      p_uda_rec_tbl(1).n_ext_attr10 := nvl(p_uda_rec_tbl(cntr).n_ext_attr10,
                                           p_uda_rec_tbl(1).n_ext_attr10);

      p_uda_rec_tbl(1).n_ext_attr11 := nvl(p_uda_rec_tbl(cntr).n_ext_attr11,
                                           p_uda_rec_tbl(1).n_ext_attr11);
      p_uda_rec_tbl(1).n_ext_attr12 := nvl(p_uda_rec_tbl(cntr).n_ext_attr12,
                                           p_uda_rec_tbl(1).n_ext_attr12);
      p_uda_rec_tbl(1).n_ext_attr13 := nvl(p_uda_rec_tbl(cntr).n_ext_attr13,
                                           p_uda_rec_tbl(1).n_ext_attr13);
      p_uda_rec_tbl(1).n_ext_attr14 := nvl(p_uda_rec_tbl(cntr).n_ext_attr14,
                                           p_uda_rec_tbl(1).n_ext_attr14);
      p_uda_rec_tbl(1).n_ext_attr15 := nvl(p_uda_rec_tbl(cntr).n_ext_attr15,
                                           p_uda_rec_tbl(1).n_ext_attr15);
      p_uda_rec_tbl(1).n_ext_attr16 := nvl(p_uda_rec_tbl(cntr).n_ext_attr16,
                                           p_uda_rec_tbl(1).n_ext_attr16);
      p_uda_rec_tbl(1).n_ext_attr17 := nvl(p_uda_rec_tbl(cntr).n_ext_attr17,
                                           p_uda_rec_tbl(1).n_ext_attr17);
      p_uda_rec_tbl(1).n_ext_attr18 := nvl(p_uda_rec_tbl(cntr).n_ext_attr18,
                                           p_uda_rec_tbl(1).n_ext_attr18);
      p_uda_rec_tbl(1).n_ext_attr19 := nvl(p_uda_rec_tbl(cntr).n_ext_attr19,
                                           p_uda_rec_tbl(1).n_ext_attr19);
      p_uda_rec_tbl(1).n_ext_attr20 := nvl(p_uda_rec_tbl(cntr).n_ext_attr20,
                                           p_uda_rec_tbl(1).n_ext_attr20);

      /* Merge date extension attributes */

      p_uda_rec_tbl(1).d_ext_attr1 := nvl(p_uda_rec_tbl(cntr).d_ext_attr1,
                                          p_uda_rec_tbl(1).d_ext_attr1);
      p_uda_rec_tbl(1).d_ext_attr2 := nvl(p_uda_rec_tbl(cntr).d_ext_attr2,
                                          p_uda_rec_tbl(1).d_ext_attr2);
      p_uda_rec_tbl(1).d_ext_attr3 := nvl(p_uda_rec_tbl(cntr).d_ext_attr3,
                                          p_uda_rec_tbl(1).d_ext_attr3);
      p_uda_rec_tbl(1).d_ext_attr4 := nvl(p_uda_rec_tbl(cntr).d_ext_attr4,
                                          p_uda_rec_tbl(1).d_ext_attr4);
      p_uda_rec_tbl(1).d_ext_attr5 := nvl(p_uda_rec_tbl(cntr).d_ext_attr5,
                                          p_uda_rec_tbl(1).d_ext_attr5);
      p_uda_rec_tbl(1).d_ext_attr6 := nvl(p_uda_rec_tbl(cntr).d_ext_attr6,
                                          p_uda_rec_tbl(1).d_ext_attr6);
      p_uda_rec_tbl(1).d_ext_attr7 := nvl(p_uda_rec_tbl(cntr).d_ext_attr7,
                                          p_uda_rec_tbl(1).d_ext_attr7);
      p_uda_rec_tbl(1).d_ext_attr8 := nvl(p_uda_rec_tbl(cntr).d_ext_attr8,
                                          p_uda_rec_tbl(1).d_ext_attr8);
      p_uda_rec_tbl(1).d_ext_attr9 := nvl(p_uda_rec_tbl(cntr).d_ext_attr9,
                                          p_uda_rec_tbl(1).d_ext_attr9);
      p_uda_rec_tbl(1).d_ext_attr10 := nvl(p_uda_rec_tbl(cntr).d_ext_attr10,
                                           p_uda_rec_tbl(1).d_ext_attr10);

      /* Merge UOM extension attributes */

      p_uda_rec_tbl(1).uom_ext_attr1 := nvl(p_uda_rec_tbl(cntr)
                                            .uom_ext_attr1,
                                            p_uda_rec_tbl(1).uom_ext_attr1);
      p_uda_rec_tbl(1).uom_ext_attr2 := nvl(p_uda_rec_tbl(cntr)
                                            .uom_ext_attr2,
                                            p_uda_rec_tbl(1).uom_ext_attr2);
      p_uda_rec_tbl(1).uom_ext_attr3 := nvl(p_uda_rec_tbl(cntr)
                                            .uom_ext_attr3,
                                            p_uda_rec_tbl(1).uom_ext_attr3);
      p_uda_rec_tbl(1).uom_ext_attr4 := nvl(p_uda_rec_tbl(cntr)
                                            .uom_ext_attr4,
                                            p_uda_rec_tbl(1).uom_ext_attr4);
      p_uda_rec_tbl(1).uom_ext_attr5 := nvl(p_uda_rec_tbl(cntr)
                                            .uom_ext_attr5,
                                            p_uda_rec_tbl(1).uom_ext_attr5);
      p_uda_rec_tbl(1).uom_ext_attr6 := nvl(p_uda_rec_tbl(cntr)
                                            .uom_ext_attr6,
                                            p_uda_rec_tbl(1).uom_ext_attr6);
      p_uda_rec_tbl(1).uom_ext_attr7 := nvl(p_uda_rec_tbl(cntr)
                                            .uom_ext_attr7,
                                            p_uda_rec_tbl(1).uom_ext_attr7);
      p_uda_rec_tbl(1).uom_ext_attr8 := nvl(p_uda_rec_tbl(cntr)
                                            .uom_ext_attr8,
                                            p_uda_rec_tbl(1).uom_ext_attr8);
      p_uda_rec_tbl(1).uom_ext_attr9 := nvl(p_uda_rec_tbl(cntr)
                                            .uom_ext_attr9,
                                            p_uda_rec_tbl(1).uom_ext_attr9);
      p_uda_rec_tbl(1).uom_ext_attr10 := nvl(p_uda_rec_tbl(cntr)
                                             .uom_ext_attr10,
                                             p_uda_rec_tbl(1).uom_ext_attr10);

      p_uda_rec_tbl(1).uom_ext_attr11 := nvl(p_uda_rec_tbl(cntr)
                                             .uom_ext_attr11,
                                             p_uda_rec_tbl(1).uom_ext_attr11);
      p_uda_rec_tbl(1).uom_ext_attr12 := nvl(p_uda_rec_tbl(cntr)
                                             .uom_ext_attr12,
                                             p_uda_rec_tbl(1).uom_ext_attr12);
      p_uda_rec_tbl(1).uom_ext_attr13 := nvl(p_uda_rec_tbl(cntr)
                                             .uom_ext_attr13,
                                             p_uda_rec_tbl(1).uom_ext_attr13);
      p_uda_rec_tbl(1).uom_ext_attr14 := nvl(p_uda_rec_tbl(cntr)
                                             .uom_ext_attr14,
                                             p_uda_rec_tbl(1).uom_ext_attr14);
      p_uda_rec_tbl(1).uom_ext_attr15 := nvl(p_uda_rec_tbl(cntr)
                                             .uom_ext_attr15,
                                             p_uda_rec_tbl(1).uom_ext_attr15);
      p_uda_rec_tbl(1).uom_ext_attr16 := nvl(p_uda_rec_tbl(cntr)
                                             .uom_ext_attr16,
                                             p_uda_rec_tbl(1).uom_ext_attr16);
      p_uda_rec_tbl(1).uom_ext_attr17 := nvl(p_uda_rec_tbl(cntr)
                                             .uom_ext_attr17,
                                             p_uda_rec_tbl(1).uom_ext_attr17);
      p_uda_rec_tbl(1).uom_ext_attr18 := nvl(p_uda_rec_tbl(cntr)
                                             .uom_ext_attr18,
                                             p_uda_rec_tbl(1).uom_ext_attr18);
      p_uda_rec_tbl(1).uom_ext_attr19 := nvl(p_uda_rec_tbl(cntr)
                                             .uom_ext_attr19,
                                             p_uda_rec_tbl(1).uom_ext_attr19);
      p_uda_rec_tbl(1).uom_ext_attr20 := nvl(p_uda_rec_tbl(cntr)
                                             .uom_ext_attr20,
                                             p_uda_rec_tbl(1).uom_ext_attr20);

    END LOOP;
    x_uda_rec := p_uda_rec_tbl(1);

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END do_single_row_uda_merge;

  PROCEDURE do_uda_row_dml
  (
    p_attribute_group_id   IN NUMBER,
    p_data_level_id        IN NUMBER,
    p_attribute_group_type IN VARCHAR2,
    p_attribute_group_name IN VARCHAR2,
    p_to_party_id          IN NUMBER,
    p_mode                 IN VARCHAR2,
    p_uda_rec_tbl          IN uda_rec_tbl_type,
    p_class_code           IN VARCHAR2,
    p_vendor_id            IN NUMBER DEFAULT NULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2
  ) IS
    l_request_table               ego_attr_group_request_table := ego_attr_group_request_table(NULL);
    l_pk_column_values            ego_col_name_value_pair_array;
    l_class_code_name_value_pairs ego_col_name_value_pair_array := ego_col_name_value_pair_array(NULL);
    l_party_id                    NUMBER;
    l_party_site_id               NUMBER;

    l_attributes_row_table      ego_user_attr_row_table := ego_user_attr_row_table(NULL);
    l_attributes_data_table     ego_user_attr_data_table := ego_user_attr_data_table(NULL);
    l_all_attributes_data_table ego_user_attr_data_table := ego_user_attr_data_table();

    l_attributes_row_table2      ego_user_attr_row_table := ego_user_attr_row_table(NULL);
    l_attributes_data_table2     ego_user_attr_data_table := ego_user_attr_data_table(NULL);
    l_all_attributes_data_table2 ego_user_attr_data_table := ego_user_attr_data_table();

    l_row_identifier NUMBER;
    l_uda_rec_tbl    uda_rec_tbl_type;

    l_uda_data_rec         pos_supp_prof_ext_b%ROWTYPE;
    l_failed_row_id_buffer VARCHAR2(1000);

    l_return_status VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(100);
    l_errorcode     NUMBER;
    l_error_msg_tbl error_handler.error_tbl_type;
    where_clause    VARCHAR2(5000);

    TYPE cursor_ref_type IS REF CURSOR;
    l_pscur cursor_ref_type;
    l_sql   VARCHAR2(4000) := NULL;
    l_ext1  NUMBER;
    l_count NUMBER;

    CURSOR attr_unique_key IS
      SELECT database_column
      FROM   ego_attrs_v
      WHERE  application_id = 177
      AND    attr_group_name = p_attribute_group_name
      AND    attr_group_type = p_attribute_group_type
      AND    unique_key_flag = 'Y';

    TYPE attr_unique_key_tab IS TABLE OF attr_unique_key%ROWTYPE INDEX BY BINARY_INTEGER;
    attr_unique_key_coll attr_unique_key_tab;

    key_vals_str VARCHAR2(2000);
    key_col_val  VARCHAR2(2000);

    TYPE key_cols_array_tab_typ IS TABLE OF VARCHAR2(1000) INDEX BY VARCHAR2(2000);
    key_cols_array_tab key_cols_array_tab_typ;

    key_combination_exists BOOLEAN := FALSE;

  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    l_row_identifier := 1020;

    /* Build the Primary key Name value pairs */
    IF (p_data_level_id = 17701) THEN

      l_pk_column_values := ego_col_name_value_pair_array(ego_col_name_value_pair_obj('PARTY_ID',
                                                                                      to_char(p_to_party_id)));
    ELSIF (p_data_level_id = 17702) THEN
      BEGIN
        SELECT party_id
        INTO   l_party_id
        FROM   hz_party_sites
        WHERE  party_site_id = p_to_party_id;

      EXCEPTION
        WHEN no_data_found THEN
          fnd_file.put_line(fnd_file.log,
                            'No party id found for party site id : ' ||
                            p_to_party_id);
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
      END;
      l_pk_column_values := ego_col_name_value_pair_array(ego_col_name_value_pair_obj('PARTY_ID',
                                                                                      to_char(l_party_id)));

    ELSIF (p_data_level_id = 17703) THEN
      BEGIN
        SELECT party_id
        INTO   l_party_id
        FROM   ap_suppliers
        WHERE  vendor_id = p_vendor_id;

      EXCEPTION
        WHEN no_data_found THEN
          fnd_file.put_line(fnd_file.log,
                            'No party id found for vendor id : ' ||
                            p_vendor_id);
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
      END;

      BEGIN
        SELECT party_site_id
        INTO   l_party_site_id
        FROM   ap_supplier_sites_all
        WHERE  vendor_site_id = p_to_party_id;

      EXCEPTION
        WHEN no_data_found THEN
          fnd_file.put_line(fnd_file.log,
                            'No party site id found for vendor site id : ' ||
                            p_to_party_id);
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
      END;
      l_pk_column_values := ego_col_name_value_pair_array(ego_col_name_value_pair_obj('PARTY_ID',
                                                                                      to_char(l_party_id)));
    END IF;

    /* Build the Attribute group Object */
    l_request_table(l_request_table.last) := ego_attr_group_request_obj(p_attribute_group_id,
                                                                        NULL, -- application id
                                                                        NULL, -- group type
                                                                        NULL, -- group name
                                                                        'SUPP_LEVEL', -- data level
                                                                        '''N''', -- DATA_LEVEL_1
                                                                        NULL, -- DATA_LEVEL_2
                                                                        NULL, -- DATA_LEVEL_3
                                                                        NULL, -- DATA_LEVEL_4
                                                                        NULL, -- DATA_LEVEL_5
                                                                        NULL -- ATTR_NAME_LIST
                                                                        );
    OPEN attr_unique_key;
    FETCH attr_unique_key BULK COLLECT
      INTO attr_unique_key_coll;
    CLOSE attr_unique_key;

    FOR datacntr IN 1 .. p_uda_rec_tbl.count LOOP
      FOR keycntr IN 1 .. attr_unique_key_coll.count LOOP
        where_clause := where_clause || ' AND  pos1.' || attr_unique_key_coll(keycntr)
                       .database_column || ' = pos2.' || attr_unique_key_coll(keycntr)
                       .database_column;

        CASE attr_unique_key_coll(keycntr).database_column

        /* Process Character attributes */

          WHEN 'C_EXT_ATTR1' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr1;

          WHEN 'C_EXT_ATTR2' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr2;
          WHEN 'C_EXT_ATTR3' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr3;
          WHEN 'C_EXT_ATTR4' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr4;
          WHEN 'C_EXT_ATTR5' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr5;
          WHEN 'C_EXT_ATTR6' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr6;
          WHEN 'C_EXT_ATTR7' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr7;
          WHEN 'C_EXT_ATTR8' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr8;
          WHEN 'C_EXT_ATTR9' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr9;
          WHEN 'C_EXT_ATTR10' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr10;
          WHEN 'C_EXT_ATTR11' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr11;
          WHEN 'C_EXT_ATTR12' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr12;
          WHEN 'C_EXT_ATTR13' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr13;
          WHEN 'C_EXT_ATTR14' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr14;
          WHEN 'C_EXT_ATTR15' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr15;
          WHEN 'C_EXT_ATTR16' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr16;
          WHEN 'C_EXT_ATTR17' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr17;
          WHEN 'C_EXT_ATTR18' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr18;
          WHEN 'C_EXT_ATTR19' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr19;
          WHEN 'C_EXT_ATTR20' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr20;
          WHEN 'C_EXT_ATTR21' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr21;
          WHEN 'C_EXT_ATTR22' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr22;
          WHEN 'C_EXT_ATTR23' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr23;
          WHEN 'C_EXT_ATTR24' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr24;
          WHEN 'C_EXT_ATTR25' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr25;
          WHEN 'C_EXT_ATTR26' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr26;
          WHEN 'C_EXT_ATTR27' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr27;
          WHEN 'C_EXT_ATTR28' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr28;
          WHEN 'C_EXT_ATTR29' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr29;
          WHEN 'C_EXT_ATTR30' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr30;
          WHEN 'C_EXT_ATTR31' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr31;
          WHEN 'C_EXT_ATTR32' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr32;
          WHEN 'C_EXT_ATTR33' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr33;
          WHEN 'C_EXT_ATTR34' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr34;
          WHEN 'C_EXT_ATTR35' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr35;
          WHEN 'C_EXT_ATTR36' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr36;
          WHEN 'C_EXT_ATTR37' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr37;
          WHEN 'C_EXT_ATTR38' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr38;
          WHEN 'C_EXT_ATTR39' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr39;
          WHEN 'C_EXT_ATTR40' THEN
            key_col_val := p_uda_rec_tbl(datacntr).c_ext_attr40;

        /* Process Numeric attributes */

          WHEN 'N_EXT_ATTR1' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr1;
          WHEN 'N_EXT_ATTR2' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr2;
          WHEN 'N_EXT_ATTR3' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr3;
          WHEN 'N_EXT_ATTR4' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr4;
          WHEN 'N_EXT_ATTR5' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr5;
          WHEN 'N_EXT_ATTR6' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr6;
          WHEN 'N_EXT_ATTR7' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr7;
          WHEN 'N_EXT_ATTR8' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr8;
          WHEN 'N_EXT_ATTR9' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr9;
          WHEN 'N_EXT_ATTR10' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr10;
          WHEN 'N_EXT_ATTR11' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr11;
          WHEN 'N_EXT_ATTR12' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr12;
          WHEN 'N_EXT_ATTR13' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr13;
          WHEN 'N_EXT_ATTR14' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr14;
          WHEN 'N_EXT_ATTR15' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr15;
          WHEN 'N_EXT_ATTR16' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr16;
          WHEN 'N_EXT_ATTR17' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr17;
          WHEN 'N_EXT_ATTR18' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr18;
          WHEN 'N_EXT_ATTR19' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr19;
          WHEN 'N_EXT_ATTR20' THEN
            key_col_val := p_uda_rec_tbl(datacntr).n_ext_attr20;

        /* Process Date attributes */

          WHEN 'D_EXT_ATTR1' THEN
            key_col_val := p_uda_rec_tbl(datacntr).d_ext_attr1;
          WHEN 'D_EXT_ATTR2' THEN
            key_col_val := p_uda_rec_tbl(datacntr).d_ext_attr2;
          WHEN 'D_EXT_ATTR3' THEN
            key_col_val := p_uda_rec_tbl(datacntr).d_ext_attr3;
          WHEN 'D_EXT_ATTR4' THEN
            key_col_val := p_uda_rec_tbl(datacntr).d_ext_attr4;
          WHEN 'D_EXT_ATTR5' THEN
            key_col_val := p_uda_rec_tbl(datacntr).d_ext_attr5;
          WHEN 'D_EXT_ATTR6' THEN
            key_col_val := p_uda_rec_tbl(datacntr).d_ext_attr6;
          WHEN 'D_EXT_ATTR7' THEN
            key_col_val := p_uda_rec_tbl(datacntr).d_ext_attr7;
          WHEN 'D_EXT_ATTR8' THEN
            key_col_val := p_uda_rec_tbl(datacntr).d_ext_attr8;
          WHEN 'D_EXT_ATTR9' THEN
            key_col_val := p_uda_rec_tbl(datacntr).d_ext_attr9;
          WHEN 'D_EXT_ATTR10' THEN
            key_col_val := p_uda_rec_tbl(datacntr).d_ext_attr10;

        /* Process UOM attributes */

          WHEN 'UOM_EXT_ATTR1' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr1;
          WHEN 'UOM_EXT_ATTR2' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr2;
          WHEN 'UOM_EXT_ATTR3' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr3;
          WHEN 'UOM_EXT_ATTR4' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr4;
          WHEN 'UOM_EXT_ATTR5' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr5;
          WHEN 'UOM_EXT_ATTR6' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr6;
          WHEN 'UOM_EXT_ATTR7' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr7;
          WHEN 'UOM_EXT_ATTR8' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr8;
          WHEN 'UOM_EXT_ATTR9' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr9;
          WHEN 'UOM_EXT_ATTR10' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr10;
          WHEN 'UOM_EXT_ATTR11' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr11;
          WHEN 'UOM_EXT_ATTR12' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr12;
          WHEN 'UOM_EXT_ATTR13' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr13;
          WHEN 'UOM_EXT_ATTR14' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr14;
          WHEN 'UOM_EXT_ATTR15' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr15;
          WHEN 'UOM_EXT_ATTR16' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr16;
          WHEN 'UOM_EXT_ATTR17' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr17;
          WHEN 'UOM_EXT_ATTR18' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr18;
          WHEN 'UOM_EXT_ATTR19' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr19;
          WHEN 'UOM_EXT_ATTR20' THEN
            key_col_val := p_uda_rec_tbl(datacntr).uom_ext_attr20;
          ELSE
            key_col_val := NULL;
        END CASE;

        key_vals_str := key_col_val || '-' || key_vals_str;
      END LOOP;

      IF NOT key_cols_array_tab.exists(key_vals_str) THEN
        key_cols_array_tab(key_vals_str) := 1;
        key_combination_exists := FALSE;
      ELSE
        key_combination_exists := TRUE;
      END IF;
      key_vals_str := NULL;
      key_col_val  := NULL;

      IF (p_data_level_id = 17701) THEN
        l_sql := 'SELECT pos1.extension_id to_ext_id
      FROM   pos_supp_prof_ext_b pos1,
             pos_supp_prof_ext_b pos2
      WHERE  pos1.attr_group_id = ' || p_attribute_group_id ||
                 ' AND    pos1.data_level_id = ' || p_data_level_id ||
                 ' AND    pos1.attr_group_id = pos2.attr_group_id
      AND    pos1.data_level_id = pos2.data_level_id
      AND    pos2.party_id = ' || p_uda_rec_tbl(datacntr)
                .party_id || ' AND  pos2.extension_id = ' || p_uda_rec_tbl(datacntr)
                .extension_id || ' AND    pos1.party_id = ' ||
                 p_to_party_id || where_clause;

      ELSIF (p_data_level_id = 17702) THEN
        l_sql := 'SELECT pos1.extension_id to_ext_id
      FROM   pos_supp_prof_ext_b pos1,
             pos_supp_prof_ext_b pos2
      WHERE  pos1.attr_group_id = ' || p_attribute_group_id ||
                 ' AND    pos1.data_level_id = ' || p_data_level_id ||
                 ' AND    pos1.attr_group_id = pos2.attr_group_id
      AND    pos1.data_level_id = pos2.data_level_id
      AND    pos2.party_id = ' || p_uda_rec_tbl(datacntr)
                .party_id || ' AND  pos2.extension_id = ' || p_uda_rec_tbl(datacntr)
                .extension_id || ' AND pos2.pk1_value = ' || p_uda_rec_tbl(datacntr)
                .pk1_value || ' AND pos1.pk1_value = ' || p_to_party_id ||
                 where_clause;

      ELSIF (p_data_level_id = 17703) THEN
        l_sql := 'SELECT pos1.extension_id to_ext_id
      FROM   pos_supp_prof_ext_b pos1,
             pos_supp_prof_ext_b pos2
      WHERE  pos1.attr_group_id = ' || p_attribute_group_id ||
                 ' AND    pos1.data_level_id = ' || p_data_level_id ||
                 ' AND    pos1.attr_group_id = pos2.attr_group_id
      AND    pos1.data_level_id = pos2.data_level_id
      AND    pos2.party_id = ' || p_uda_rec_tbl(datacntr)
                .party_id || ' AND  pos2.extension_id = ' || p_uda_rec_tbl(datacntr)
                .extension_id || ' AND pos2.pk2_value = ' || p_uda_rec_tbl(datacntr)
                .pk2_value || ' AND pos1.pk2_value = ' || p_to_party_id ||
                 where_clause;
      END IF;

      l_ext1 := NULL;

      OPEN l_pscur FOR l_sql;
      FETCH l_pscur
        INTO l_ext1;
      CLOSE l_pscur;

      IF (l_ext1 IS NOT NULL) THEN
        IF key_combination_exists = FALSE THEN
          -- update multirow suchita
          IF (p_data_level_id = 17701) THEN
            l_sql := 'SELECT *
                       FROM   pos_supp_prof_ext_b
                       WHERE  party_id = ' || p_uda_rec_tbl(datacntr)
                    .party_id || ' AND extension_id = ' || p_uda_rec_tbl(datacntr)
                    .extension_id ||
                     ' UNION ALL
                     SELECT *
                       FROM   pos_supp_prof_ext_b
                       WHERE  party_id = ' ||
                     p_to_party_id || ' AND extension_id = ' || l_ext1;

          ELSIF (p_data_level_id = 17702) THEN
            l_sql := 'SELECT *
                       FROM   pos_supp_prof_ext_b
                       WHERE  pk1_value = ' || p_uda_rec_tbl(datacntr)
                    .pk1_value || ' AND extension_id = ' || p_uda_rec_tbl(datacntr)
                    .extension_id ||
                     ' UNION ALL
                     SELECT *
                       FROM   pos_supp_prof_ext_b
                       WHERE  pk1_value = ' ||
                     p_to_party_id || ' AND extension_id = ' || l_ext1;

          ELSIF (p_data_level_id = 17703) THEN
            l_sql := 'SELECT *
                       FROM   pos_supp_prof_ext_b
                       WHERE  pk2_value = ' || p_uda_rec_tbl(datacntr)
                    .pk2_value || ' AND extension_id = ' || p_uda_rec_tbl(datacntr)
                    .extension_id ||
                     ' UNION ALL
                     SELECT *
                       FROM   pos_supp_prof_ext_b
                       WHERE  pk2_value = ' ||
                     p_to_party_id || ' AND extension_id = ' || l_ext1;
          END IF;
        ELSE
          -- update multirow suchita
          IF (p_data_level_id = 17701) THEN
            l_sql := 'SELECT *
                   FROM   pos_supp_prof_ext_b
                   WHERE  party_id = ' || p_to_party_id ||
                     ' AND extension_id = ' || l_ext1 ||
                     'UNION ALL
                    SELECT *
                   FROM   pos_supp_prof_ext_b
                   WHERE  party_id = ' || p_uda_rec_tbl(datacntr)
                    .party_id || ' AND extension_id = ' || p_uda_rec_tbl(datacntr)
                    .extension_id;

          ELSIF (p_data_level_id = 17702) THEN
            l_sql := 'SELECT *
                   FROM   pos_supp_prof_ext_b
                   WHERE  pk1_value = ' ||
                     p_to_party_id || ' AND extension_id = ' || l_ext1 ||
                     ' UNION ALL
                   SELECT *
                   FROM   pos_supp_prof_ext_b
                   WHERE  pk1_value = ' || p_uda_rec_tbl(datacntr)
                    .pk1_value || ' AND extension_id = ' || p_uda_rec_tbl(datacntr)
                    .extension_id;

          ELSIF (p_data_level_id = 17703) THEN
            l_sql := 'SELECT *
                   FROM   pos_supp_prof_ext_b
                   WHERE  pk2_value = ' ||
                     p_to_party_id || ' AND extension_id = ' || l_ext1 ||
                     ' UNION ALL
                   SELECT *
                   FROM   pos_supp_prof_ext_b
                   WHERE  pk2_value = ' || p_uda_rec_tbl(datacntr)
                    .pk2_value || ' AND extension_id = ' || p_uda_rec_tbl(datacntr)
                    .extension_id;
          END IF;

        END IF;

        OPEN l_pscur FOR l_sql;
        FETCH l_pscur BULK COLLECT
          INTO l_uda_rec_tbl;
        CLOSE l_pscur;

        do_single_row_uda_merge(l_uda_rec_tbl,
                                l_uda_data_rec,
                                l_return_status,
                                l_msg_count,
                                l_msg_data);

        /* Build the Row Object */
        IF (p_data_level_id = 17701) THEN
          l_attributes_row_table(l_attributes_row_table.last) := ego_user_attr_row_obj(l_row_identifier,
                                                                                       p_attribute_group_id,
                                                                                       177,
                                                                                       'POS_SUPP_PROFMGMT_GROUP', --'SDH_SUPP_PROFMGMT_GROUP',
                                                                                       p_attribute_group_name, --p_attribute_group_name,
                                                                                       'SUPP_LEVEL', -- data level
                                                                                       'N',
                                                                                       NULL,
                                                                                       NULL,
                                                                                       NULL,
                                                                                       NULL,
                                                                                       ego_user_attrs_data_pvt.g_update_mode --TRANSACTION_TYPE
                                                                                       );
        ELSIF (p_data_level_id = 17702) THEN
          l_attributes_row_table(l_attributes_row_table.last) := ego_user_attr_row_obj(l_row_identifier,
                                                                                       p_attribute_group_id,
                                                                                       177,
                                                                                       'POS_SUPP_PROFMGMT_GROUP', --'SDH_SUPP_PROFMGMT_GROUP',
                                                                                       p_attribute_group_name, --p_attribute_group_name,
                                                                                       'SUPP_ADDR_LEVEL', -- data level
                                                                                       'N',
                                                                                       p_to_party_id,
                                                                                       NULL,
                                                                                       NULL,
                                                                                       NULL,
                                                                                       ego_user_attrs_data_pvt.g_update_mode --TRANSACTION_TYPE
                                                                                       );
        ELSIF (p_data_level_id = 17703) THEN
          l_attributes_row_table(l_attributes_row_table.last) := ego_user_attr_row_obj(l_row_identifier,
                                                                                       p_attribute_group_id,
                                                                                       177,
                                                                                       'POS_SUPP_PROFMGMT_GROUP', --'SDH_SUPP_PROFMGMT_GROUP',
                                                                                       p_attribute_group_name, --p_attribute_group_name,
                                                                                       'SUPP_ADDR_SITE_LEVEL', -- data level
                                                                                       'N',
                                                                                       l_party_site_id,
                                                                                       p_to_party_id,
                                                                                       NULL,
                                                                                       NULL,
                                                                                       ego_user_attrs_data_pvt.g_update_mode --TRANSACTION_TYPE
                                                                                       );
        END IF;

        /* Build the data payload object */
        l_attributes_data_table := ego_user_attr_data_table(NULL);

        build_uda_data_payload(p_attribute_group_id    => p_attribute_group_id,
                               p_attribute_group_name  => p_attribute_group_name,
                               p_attribute_group_type  => p_attribute_group_type,
                               p_row_identifier        => l_row_identifier,
                               p_uda_data_rec          => l_uda_data_rec,
                               x_attributes_data_table => l_attributes_data_table);

        /*l_all_attributes_data_table := l_all_attributes_data_table MULTISET
                                       UNION l_attributes_data_table;*/

        l_count := l_all_attributes_data_table.count;

        FOR i IN 1 .. l_attributes_data_table.count LOOP
          l_all_attributes_data_table.extend;
          l_all_attributes_data_table(l_count + i) := ego_user_attr_data_obj(l_attributes_data_table(i)
                                                                             .row_identifier,
                                                                             l_attributes_data_table(i)
                                                                             .attr_name,
                                                                             l_attributes_data_table(i)
                                                                             .attr_value_str,
                                                                             l_attributes_data_table(i)
                                                                             .attr_value_num,
                                                                             l_attributes_data_table(i)
                                                                             .attr_value_date,
                                                                             l_attributes_data_table(i)
                                                                             .attr_disp_value,
                                                                             l_attributes_data_table(i)
                                                                             .attr_unit_of_measure,
                                                                             l_attributes_data_table(i)
                                                                             .user_row_identifier);
        END LOOP;

      ELSE
        /* Build the Row Object */
        IF (p_data_level_id = 17701) THEN
          l_attributes_row_table2(l_attributes_row_table2.last) := ego_user_attr_row_obj(l_row_identifier,
                                                                                         p_attribute_group_id,
                                                                                         177,
                                                                                         'POS_SUPP_PROFMGMT_GROUP', --'SDH_SUPP_PROFMGMT_GROUP',
                                                                                         p_attribute_group_name, --p_attribute_group_name,
                                                                                         'SUPP_LEVEL', -- data level
                                                                                         'N',
                                                                                         NULL,
                                                                                         NULL,
                                                                                         NULL,
                                                                                         NULL,
                                                                                         ego_user_attrs_data_pvt.g_create_mode --TRANSACTION_TYPE
                                                                                         );
        ELSIF (p_data_level_id = 17702) THEN
          l_attributes_row_table2(l_attributes_row_table2.last) := ego_user_attr_row_obj(l_row_identifier,
                                                                                         p_attribute_group_id,
                                                                                         177,
                                                                                         'POS_SUPP_PROFMGMT_GROUP', --'SDH_SUPP_PROFMGMT_GROUP',
                                                                                         p_attribute_group_name, --p_attribute_group_name,
                                                                                         'SUPP_ADDR_LEVEL', -- data level
                                                                                         'N',
                                                                                         p_to_party_id,
                                                                                         NULL,
                                                                                         NULL,
                                                                                         NULL,
                                                                                         ego_user_attrs_data_pvt.g_create_mode --TRANSACTION_TYPE
                                                                                         );
        ELSIF (p_data_level_id = 17703) THEN
          l_attributes_row_table2(l_attributes_row_table2.last) := ego_user_attr_row_obj(l_row_identifier,
                                                                                         p_attribute_group_id,
                                                                                         177,
                                                                                         'POS_SUPP_PROFMGMT_GROUP', --'SDH_SUPP_PROFMGMT_GROUP',
                                                                                         p_attribute_group_name, --p_attribute_group_name,
                                                                                         'SUPP_ADDR_SITE_LEVEL', -- data level
                                                                                         'N',
                                                                                         l_party_site_id,
                                                                                         p_to_party_id,
                                                                                         NULL,
                                                                                         NULL,
                                                                                         ego_user_attrs_data_pvt.g_create_mode --TRANSACTION_TYPE
                                                                                         );
        END IF;

        /* Build the Data Object */
        l_uda_data_rec           := p_uda_rec_tbl(datacntr);
        l_attributes_data_table2 := ego_user_attr_data_table(NULL);

        build_uda_data_payload(p_attribute_group_id    => p_attribute_group_id,
                               p_attribute_group_name  => p_attribute_group_name,
                               p_attribute_group_type  => p_attribute_group_type,
                               p_row_identifier        => l_row_identifier,
                               p_uda_data_rec          => l_uda_data_rec,
                               x_attributes_data_table => l_attributes_data_table2);

        /*l_all_attributes_data_table2 := l_all_attributes_data_table2
                                        MULTISET UNION
                                        l_attributes_data_table2;*/

        l_count := l_all_attributes_data_table2.count;

        FOR i IN 1 .. l_attributes_data_table2.count LOOP
          l_all_attributes_data_table2.extend;
          l_all_attributes_data_table2(l_count + i) := ego_user_attr_data_obj(l_attributes_data_table2(i)
                                                                              .row_identifier,
                                                                              l_attributes_data_table2(i)
                                                                              .attr_name,
                                                                              l_attributes_data_table2(i)
                                                                              .attr_value_str,
                                                                              l_attributes_data_table2(i)
                                                                              .attr_value_num,
                                                                              l_attributes_data_table2(i)
                                                                              .attr_value_date,
                                                                              l_attributes_data_table2(i)
                                                                              .attr_disp_value,
                                                                              l_attributes_data_table2(i)
                                                                              .attr_unit_of_measure,
                                                                              l_attributes_data_table2(i)
                                                                              .user_row_identifier);
        END LOOP;

        l_class_code_name_value_pairs := ego_col_name_value_pair_array(ego_col_name_value_pair_obj('CLASSIFICATION_CODE',
                                                                                                   p_class_code));

        ego_user_attrs_data_pub.process_user_attrs_data(p_api_version                 => 1.0,
                                                        p_object_name                 => 'HZ_PARTIES',
                                                        p_attributes_row_table        => l_attributes_row_table2,
                                                        p_attributes_data_table       => l_all_attributes_data_table2,
                                                        p_pk_column_name_value_pairs  => l_pk_column_values,
                                                        p_class_code_name_value_pairs => l_class_code_name_value_pairs,
                                                        p_entity_id                   => NULL,
                                                        p_entity_index                => NULL,
                                                        p_entity_code                 => NULL,
                                                        p_debug_level                 => NULL, --p_debug_level,
                                                        p_commit                      => fnd_api.g_false,
                                                        p_init_error_handler          => 'T',
                                                        p_init_fnd_msg_list           => 'T',
                                                        x_failed_row_id_list          => l_failed_row_id_buffer,
                                                        x_return_status               => l_return_status,
                                                        x_errorcode                   => l_errorcode,
                                                        x_msg_count                   => l_msg_count,
                                                        x_msg_data                    => l_msg_data);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          error_handler.get_message_list(l_error_msg_tbl);
          IF l_error_msg_tbl.first IS NOT NULL THEN
            l_msg_count := l_error_msg_tbl.first;
            WHILE l_msg_count IS NOT NULL LOOP
              fnd_file.put_line(fnd_file.log,
                                'Error Message: ' || l_error_msg_tbl(l_msg_count)
                                .message_text ||
                                 ' From ego_user_attrs_data_pub.process_user_attrs_data API.');
              l_msg_count := l_error_msg_tbl.next(l_msg_count);
            END LOOP;
          END IF;
        END IF;
        l_attributes_row_table2      := ego_user_attr_row_table(NULL);
        l_attributes_data_table2     := ego_user_attr_data_table(NULL);
        l_all_attributes_data_table2 := ego_user_attr_data_table();
        l_attributes_row_table.trim;
      END IF;
      /* Increment the row identifier */
      l_row_identifier := l_row_identifier + 1;
      l_attributes_row_table.extend;
    END LOOP;

    l_attributes_row_table.trim;

    l_class_code_name_value_pairs := ego_col_name_value_pair_array(ego_col_name_value_pair_obj('CLASSIFICATION_CODE',
                                                                                               p_class_code));

    /* Call the EGO API to process the attributes based on the mode */

    ego_user_attrs_data_pub.process_user_attrs_data(p_api_version                 => 1.0,
                                                    p_object_name                 => 'HZ_PARTIES',
                                                    p_attributes_row_table        => l_attributes_row_table,
                                                    p_attributes_data_table       => l_all_attributes_data_table,
                                                    p_pk_column_name_value_pairs  => l_pk_column_values,
                                                    p_class_code_name_value_pairs => l_class_code_name_value_pairs,
                                                    p_entity_id                   => NULL,
                                                    p_entity_index                => NULL,
                                                    p_entity_code                 => NULL,
                                                    p_debug_level                 => NULL, --p_debug_level,
                                                    p_commit                      => fnd_api.g_false,
                                                    p_init_error_handler          => 'T',
                                                    p_init_fnd_msg_list           => 'T',
                                                    x_failed_row_id_list          => l_failed_row_id_buffer,
                                                    x_return_status               => l_return_status,
                                                    x_errorcode                   => l_errorcode,
                                                    x_msg_count                   => l_msg_count,
                                                    x_msg_data                    => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      error_handler.get_message_list(l_error_msg_tbl);
      IF l_error_msg_tbl.first IS NOT NULL THEN
        l_msg_count := l_error_msg_tbl.first;
        WHILE l_msg_count IS NOT NULL LOOP
          fnd_file.put_line(fnd_file.log,
                            'Error Message: ' || l_error_msg_tbl(l_msg_count)
                            .message_text ||
                             ' From ego_user_attrs_data_pub.process_user_attrs_data API.');
          l_msg_count := l_error_msg_tbl.next(l_msg_count);
        END LOOP;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END do_uda_row_dml;

  PROCEDURE do_uda_row_dml
  (
    p_attribute_group_id   IN NUMBER,
    p_data_level_id        IN NUMBER,
    p_attribute_group_type IN VARCHAR2,
    p_attribute_group_name IN VARCHAR2,
    p_to_party_id          IN NUMBER,
    p_mode                 IN VARCHAR2,
    p_uda_rec              IN pos_supp_prof_ext_b%ROWTYPE,
    p_class_code           IN VARCHAR2,
    p_vendor_id            IN NUMBER DEFAULT NULL,
    --p_uda_rec_tbl          IN uda_rec_tbl_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_request_table    ego_attr_group_request_table := ego_attr_group_request_table(NULL);
    l_pk_column_values ego_col_name_value_pair_array;

    l_attributes_row_table  ego_user_attr_row_table := ego_user_attr_row_table(NULL);
    l_attributes_data_table ego_user_attr_data_table := ego_user_attr_data_table(NULL);
    l_row_identifier        NUMBER;
    l_failed_row_id_buffer  VARCHAR2(1000);

    l_return_status VARCHAR2(2000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(100);
    l_errorcode     NUMBER;
    l_error_msg_tbl error_handler.error_tbl_type;

    l_class_code_name_value_pairs ego_col_name_value_pair_array := ego_col_name_value_pair_array(NULL);
    l_party_id                    NUMBER;
    l_party_site_id               NUMBER;
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    l_row_identifier := 1030;
    /* This API works in 2 modes Insert and Update. If run in the update mode then
    it would update the UDA data for the to_party_id that is passed.
    If run in the insert mode, it would insert the data for the party */

    /* Build the Primary key Name value pairs */
    IF (p_data_level_id = 17701) THEN

      l_pk_column_values := ego_col_name_value_pair_array(ego_col_name_value_pair_obj('PARTY_ID',
                                                                                      to_char(p_to_party_id)));
    ELSIF (p_data_level_id = 17702) THEN

      BEGIN
        SELECT party_id
        INTO   l_party_id
        FROM   hz_party_sites
        WHERE  party_site_id = p_to_party_id;

      EXCEPTION
        WHEN no_data_found THEN
          fnd_file.put_line(fnd_file.log,
                            'No party id found for party site id : ' ||
                            p_to_party_id);
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
      END;
      l_pk_column_values := ego_col_name_value_pair_array(ego_col_name_value_pair_obj('PARTY_ID',
                                                                                      to_char(l_party_id)));

    ELSIF (p_data_level_id = 17703) THEN
      BEGIN
        SELECT party_id
        INTO   l_party_id
        FROM   ap_suppliers
        WHERE  vendor_id = p_vendor_id;

      EXCEPTION
        WHEN no_data_found THEN
          fnd_file.put_line(fnd_file.log,
                            'No party id found for vendor id : ' ||
                            p_vendor_id);
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
      END;

      BEGIN
        SELECT party_site_id
        INTO   l_party_site_id
        FROM   ap_supplier_sites_all
        WHERE  vendor_site_id = p_to_party_id;

      EXCEPTION
        WHEN no_data_found THEN
          fnd_file.put_line(fnd_file.log,
                            'No party site id found for vendor site id : ' ||
                            p_to_party_id);
          x_return_status := fnd_api.g_ret_sts_error;
          RETURN;
      END;

      l_pk_column_values := ego_col_name_value_pair_array(ego_col_name_value_pair_obj('PARTY_ID',
                                                                                      to_char(l_party_id)));
    END IF;

    /* Build the Attribute group Object */
    l_request_table(l_request_table.last) := ego_attr_group_request_obj(p_attribute_group_id,
                                                                        NULL, -- application id
                                                                        NULL, -- group type
                                                                        NULL, -- group name
                                                                        'SUPP_LEVEL', -- data level
                                                                        '''N''', -- DATA_LEVEL_1
                                                                        NULL, -- DATA_LEVEL_2
                                                                        NULL, -- DATA_LEVEL_3
                                                                        NULL, -- DATA_LEVEL_4
                                                                        NULL, -- DATA_LEVEL_5
                                                                        NULL -- ATTR_NAME_LIST
                                                                        );

    /* Build the data payload object */

    IF (p_mode = 'UPDATE') THEN

      /* Build the Row Object */
      IF (p_data_level_id = 17701) THEN
        l_attributes_row_table(l_attributes_row_table.last) := ego_user_attr_row_obj(l_row_identifier,
                                                                                     p_attribute_group_id,
                                                                                     177,
                                                                                     'POS_SUPP_PROFMGMT_GROUP', --'SDH_SUPP_PROFMGMT_GROUP',
                                                                                     p_attribute_group_name, --p_attribute_group_name,
                                                                                     'SUPP_LEVEL', -- data level
                                                                                     'N',
                                                                                     NULL,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     ego_user_attrs_data_pvt.g_update_mode --TRANSACTION_TYPE
                                                                                     );
      ELSIF (p_data_level_id = 17702) THEN
        l_attributes_row_table(l_attributes_row_table.last) := ego_user_attr_row_obj(l_row_identifier,
                                                                                     p_attribute_group_id,
                                                                                     177,
                                                                                     'POS_SUPP_PROFMGMT_GROUP', --'SDH_SUPP_PROFMGMT_GROUP',
                                                                                     p_attribute_group_name, --p_attribute_group_name,
                                                                                     'SUPP_ADDR_LEVEL', -- data level
                                                                                     'N',
                                                                                     p_to_party_id,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     ego_user_attrs_data_pvt.g_update_mode --TRANSACTION_TYPE
                                                                                     );
      ELSIF (p_data_level_id = 17703) THEN
        l_attributes_row_table(l_attributes_row_table.last) := ego_user_attr_row_obj(l_row_identifier,
                                                                                     p_attribute_group_id,
                                                                                     177,
                                                                                     'POS_SUPP_PROFMGMT_GROUP', --'SDH_SUPP_PROFMGMT_GROUP',
                                                                                     p_attribute_group_name, --p_attribute_group_name,
                                                                                     'SUPP_ADDR_SITE_LEVEL', -- data level
                                                                                     'N',
                                                                                     l_party_site_id,
                                                                                     p_to_party_id,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     ego_user_attrs_data_pvt.g_update_mode --TRANSACTION_TYPE
                                                                                     );
      END IF;
      /* Build the Data Object */

      build_uda_data_payload(p_attribute_group_id    => p_attribute_group_id,
                             p_attribute_group_name  => p_attribute_group_name,
                             p_attribute_group_type  => p_attribute_group_type,
                             p_row_identifier        => l_row_identifier,
                             p_uda_data_rec          => p_uda_rec,
                             x_attributes_data_table => l_attributes_data_table);

    ELSE
      /* Build the Row Object */
      IF (p_data_level_id = 17701) THEN
        l_attributes_row_table(l_attributes_row_table.last) := ego_user_attr_row_obj(l_row_identifier,
                                                                                     p_attribute_group_id,
                                                                                     177,
                                                                                     'POS_SUPP_PROFMGMT_GROUP', --'SDH_SUPP_PROFMGMT_GROUP',
                                                                                     p_attribute_group_name, --p_attribute_group_name,
                                                                                     'SUPP_LEVEL', -- data level
                                                                                     'N',
                                                                                     NULL,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     ego_user_attrs_data_pvt.g_create_mode --TRANSACTION_TYPE
                                                                                     );
      ELSIF (p_data_level_id = 17702) THEN
        l_attributes_row_table(l_attributes_row_table.last) := ego_user_attr_row_obj(l_row_identifier,
                                                                                     p_attribute_group_id,
                                                                                     177,
                                                                                     'POS_SUPP_PROFMGMT_GROUP', --'SDH_SUPP_PROFMGMT_GROUP',
                                                                                     p_attribute_group_name, --p_attribute_group_name,
                                                                                     'SUPP_ADDR_LEVEL', -- data level
                                                                                     'N',
                                                                                     p_to_party_id,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     ego_user_attrs_data_pvt.g_create_mode --TRANSACTION_TYPE
                                                                                     );
      ELSIF (p_data_level_id = 17703) THEN
        l_attributes_row_table(l_attributes_row_table.last) := ego_user_attr_row_obj(l_row_identifier,
                                                                                     p_attribute_group_id,
                                                                                     177,
                                                                                     'POS_SUPP_PROFMGMT_GROUP', --'SDH_SUPP_PROFMGMT_GROUP',
                                                                                     p_attribute_group_name, --p_attribute_group_name,
                                                                                     'SUPP_ADDR_SITE_LEVEL', -- data level
                                                                                     'N',
                                                                                     l_party_site_id,
                                                                                     p_to_party_id,
                                                                                     NULL,
                                                                                     NULL,
                                                                                     ego_user_attrs_data_pvt.g_create_mode --TRANSACTION_TYPE
                                                                                     );
      END IF;

      /* Build the Data Object */
      build_uda_data_payload(p_attribute_group_id    => p_attribute_group_id,
                             p_attribute_group_name  => p_attribute_group_name,
                             p_attribute_group_type  => p_attribute_group_type,
                             p_row_identifier        => l_row_identifier,
                             p_uda_data_rec          => p_uda_rec,
                             x_attributes_data_table => l_attributes_data_table);
    END IF;

    l_class_code_name_value_pairs := ego_col_name_value_pair_array(ego_col_name_value_pair_obj('CLASSIFICATION_CODE',
                                                                                               p_class_code));

    /* Call the EGO API to process the attributes based on the mode */

    ego_user_attrs_data_pub.process_user_attrs_data(p_api_version                 => 1.0,
                                                    p_object_name                 => 'HZ_PARTIES',
                                                    p_attributes_row_table        => l_attributes_row_table,
                                                    p_attributes_data_table       => l_attributes_data_table,
                                                    p_pk_column_name_value_pairs  => l_pk_column_values,
                                                    p_class_code_name_value_pairs => l_class_code_name_value_pairs,
                                                    p_entity_id                   => NULL,
                                                    p_entity_index                => NULL,
                                                    p_entity_code                 => NULL,
                                                    p_debug_level                 => NULL, --p_debug_level,
                                                    p_commit                      => fnd_api.g_false,
                                                    p_init_error_handler          => 'T',
                                                    p_init_fnd_msg_list           => 'T',
                                                    x_failed_row_id_list          => l_failed_row_id_buffer,
                                                    x_return_status               => l_return_status,
                                                    x_errorcode                   => l_errorcode,
                                                    x_msg_count                   => l_msg_count,
                                                    x_msg_data                    => l_msg_data);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      error_handler.get_message_list(l_error_msg_tbl);
      IF l_error_msg_tbl.first IS NOT NULL THEN
        l_msg_count := l_error_msg_tbl.first;
        WHILE l_msg_count IS NOT NULL LOOP
          fnd_file.put_line(fnd_file.log,
                            'Error Message: ' || l_error_msg_tbl(l_msg_count)
                            .message_text ||
                             ' From ego_user_attrs_data_pub.process_user_attrs_data API.');
          l_msg_count := l_error_msg_tbl.next(l_msg_count);
        END LOOP;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END do_uda_row_dml;

  PROCEDURE supplier_uda_merge
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  ) IS
    l_ret_status VARCHAR2(2000);
    l_msg_count  NUMBER;
    l_msg_data   VARCHAR2(2000);

    l_uda_rec_tbl   uda_rec_tbl_type;
    merged_uda_rec  pos_supp_prof_ext_b%ROWTYPE;
    l_party_count   NUMBER := 0;
    l_to_party_cntr NUMBER := 0;

    CURSOR get_supplier_attribute_groups IS
      SELECT ag.attr_group_id,
             ag.application_id,
             eas.data_level_id,
             ag.multi_row,
             eas.attr_group_type,
             ag.descriptive_flex_context_code,
             ag.descriptive_flexfield_name,
             eas.classification_code
      FROM   ego_fnd_dsc_flx_ctx_ext   ag,
             ego_obj_attr_grp_assocs_v eas
      WHERE  ag.application_id = 177
      AND    ag.attr_group_id = eas.attr_group_id
      AND    eas.application_id = ag.application_id
      AND    eas.data_level_int_name = 'SUPP_LEVEL';

    TYPE attributes_group_tab IS TABLE OF get_supplier_attribute_groups%ROWTYPE INDEX BY BINARY_INTEGER;
    attributes_group_coll attributes_group_tab;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SELECT COUNT(1)
    INTO   l_to_party_cntr
    FROM   pos_supplier_uda_merge_gtt
    WHERE  batch_id = p_batch_id
    AND    to_party_id = p_to_fk_id
    AND    rownum = 1;

    IF (l_to_party_cntr = 0) THEN
      INSERT INTO pos_supplier_uda_merge_gtt
        (batch_id, to_party_id)
      VALUES
        (p_batch_id, p_to_fk_id);
    ELSE
      RETURN;
    END IF;

    fnd_file.put_line(fnd_file.log,
                      'Inside POS_MERGE_SUPPLIER_PKG.supplier_uda_merge p_to_fk_id: ' ||
                      p_to_fk_id || ' p_to_fk_id: ' || p_from_fk_id);

    /* Update the status of all the records in the bath to
    PERFORM_UDA_MERGE*/

    /* Get the attribute group data from the cursor
    get_supplier_attribute_groups*/

    OPEN get_supplier_attribute_groups;
    FETCH get_supplier_attribute_groups BULK COLLECT
      INTO attributes_group_coll;
    CLOSE get_supplier_attribute_groups;

    /* Loop through the attribute group Ids */
    FOR cntr IN 1 .. attributes_group_coll.count LOOP

      /* check if the attribute group is a single row attribute or a
      multirow attribute*/

      /* If the attribute group is single row */
      IF (attributes_group_coll(cntr).multi_row = 'N') THEN

        /* Query the extension table for the to and from parties
        and get the rows in the ascending order of the creation
        date */
        fnd_file.put_line(fnd_file.log,
                          'supplier_uda_merge single row processing for attr group id : ' || attributes_group_coll(cntr)
                          .attr_group_id);

        get_batch_user_attr_data(p_to_fk_id,
                                 p_batch_id,
                                 attributes_group_coll(cntr).multi_row,
                                 attributes_group_coll(cntr).attr_group_id,
                                 attributes_group_coll(cntr).data_level_id,
                                 l_uda_rec_tbl,
                                 l_ret_status,
                                 l_msg_count,
                                 l_msg_data);

        /* Do the merging */
        IF (l_uda_rec_tbl.count <> 0) THEN
          do_single_row_uda_merge(l_uda_rec_tbl,
                                  merged_uda_rec,
                                  l_ret_status,
                                  l_msg_count,
                                  l_msg_data);

          SELECT COUNT(1)
          INTO   l_party_count
          FROM   pos_supp_prof_ext_b
          WHERE  attr_group_id = attributes_group_coll(cntr).attr_group_id
          AND    party_id = p_to_fk_id
          AND    rownum = 1;

          IF (l_party_count = 0) THEN
            /* Do the insert */
            do_uda_row_dml(p_attribute_group_id   => attributes_group_coll(cntr)
                                                     .attr_group_id,
                           p_data_level_id        => attributes_group_coll(cntr)
                                                     .data_level_id,
                           p_attribute_group_type => attributes_group_coll(cntr)
                                                     .attr_group_type,
                           p_attribute_group_name => attributes_group_coll(cntr)
                                                     .descriptive_flex_context_code,
                           p_to_party_id          => p_to_fk_id,
                           p_mode                 => 'INSERT',
                           p_uda_rec              => merged_uda_rec,
                           p_class_code           => attributes_group_coll(cntr)
                                                     .classification_code,
                           x_return_status        => l_ret_status,
                           x_msg_count            => l_msg_count,
                           x_msg_data             => l_msg_data);

          ELSE
            /* Do the update */
            do_uda_row_dml(p_attribute_group_id   => attributes_group_coll(cntr)
                                                     .attr_group_id,
                           p_data_level_id        => attributes_group_coll(cntr)
                                                     .data_level_id,
                           p_attribute_group_type => attributes_group_coll(cntr)
                                                     .attr_group_type,
                           p_attribute_group_name => attributes_group_coll(cntr)
                                                     .descriptive_flex_context_code,
                           p_to_party_id          => p_to_fk_id,
                           p_mode                 => 'UPDATE',
                           p_uda_rec              => merged_uda_rec,
                           p_class_code           => attributes_group_coll(cntr)
                                                     .classification_code,
                           x_return_status        => l_ret_status,
                           x_msg_count            => l_msg_count,
                           x_msg_data             => l_msg_data);
          END IF;
        END IF;
        -- End of single row processing
      ELSE

        /* If the attribute group is multi row */
        -- Multirow processing
        fnd_file.put_line(fnd_file.log,
                          'supplier_uda_merge multi row processing for attr group id : ' || attributes_group_coll(cntr)
                          .attr_group_id);

        get_batch_user_attr_data(p_to_fk_id,
                                 p_batch_id,
                                 attributes_group_coll(cntr).multi_row,
                                 attributes_group_coll(cntr).attr_group_id,
                                 attributes_group_coll(cntr).data_level_id,
                                 l_uda_rec_tbl,
                                 l_ret_status,
                                 l_msg_count,
                                 l_msg_data);

        /* Insert the rows obtained */

        do_uda_row_dml(p_attribute_group_id   => attributes_group_coll(cntr)
                                                 .attr_group_id,
                       p_data_level_id        => attributes_group_coll(cntr)
                                                 .data_level_id,
                       p_attribute_group_type => attributes_group_coll(cntr)
                                                 .attr_group_type,
                       p_attribute_group_name => attributes_group_coll(cntr)
                                                 .descriptive_flex_context_code,
                       p_to_party_id          => p_to_fk_id,
                       p_mode                 => 'INSERT',
                       p_uda_rec_tbl          => l_uda_rec_tbl,
                       p_class_code           => attributes_group_coll(cntr)
                                                 .classification_code,
                       x_return_status        => l_ret_status,
                       x_msg_count            => l_msg_count,
                       x_msg_data             => l_msg_data);
      END IF;

    --END LOOP; -- End of party loop

    END LOOP; -- end of attribute group loop

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END supplier_uda_merge;

  PROCEDURE supplier_site_uda_merge
  (
    p_from_id       IN NUMBER,
    p_from_fk_id    IN NUMBER,
    p_to_fk_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_ret_status VARCHAR2(2000);
    l_msg_count  NUMBER;
    l_msg_data   VARCHAR2(2000);

    l_uda_rec_tbl   uda_rec_tbl_type;
    merged_uda_rec  pos_supp_prof_ext_b%ROWTYPE;
    l_party_count   NUMBER := 0;
    l_to_party_cntr NUMBER := 0;

    CURSOR get_supplier_attribute_groups IS
      SELECT ag.attr_group_id,
             ag.application_id,
             eas.data_level_id,
             ag.multi_row,
             eas.attr_group_type,
             ag.descriptive_flex_context_code,
             ag.descriptive_flexfield_name,
             eas.classification_code
      FROM   ego_fnd_dsc_flx_ctx_ext   ag,
             ego_obj_attr_grp_assocs_v eas
      WHERE  ag.application_id = 177
      AND    ag.attr_group_id = eas.attr_group_id
      AND    eas.application_id = ag.application_id
      AND    eas.data_level_int_name = 'SUPP_ADDR_SITE_LEVEL';

    TYPE attributes_group_tab IS TABLE OF get_supplier_attribute_groups%ROWTYPE INDEX BY BINARY_INTEGER;
    attributes_group_coll attributes_group_tab;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      'Inside POS_MERGE_SUPPLIER_PKG.supplier_site_uda_merge p_to_fk_id: ' ||
                      p_to_fk_id || ' p_to_fk_id: ' || p_from_fk_id ||
                      ' p_from_id : ' || p_from_id);

    /* Update the status of all the records in the bath to
    PERFORM_UDA_MERGE*/

    /* Get the attribute group data from the cursor
    get_supplier_attribute_groups*/

    OPEN get_supplier_attribute_groups;
    FETCH get_supplier_attribute_groups BULK COLLECT
      INTO attributes_group_coll;
    CLOSE get_supplier_attribute_groups;

    /* Loop through the attribute group Ids */
    FOR cntr IN 1 .. attributes_group_coll.count LOOP

      /* check if the attribute group is a single row attribute or a
      multirow attribute*/

      /* If the attribute group is single row */
      IF (attributes_group_coll(cntr).multi_row = 'N') THEN

        /* Query the extension table for the to and from parties
        and get the rows in the ascending order of the creation
        date */
        fnd_file.put_line(fnd_file.log,
                          'supplier_site_uda_merge single row processing for attr group id : ' || attributes_group_coll(cntr)
                          .attr_group_id);

        get_supp_site_attr_data(p_from_fk_id,
                                p_to_fk_id,
                                attributes_group_coll(cntr).multi_row,
                                attributes_group_coll(cntr).attr_group_id,
                                attributes_group_coll(cntr).data_level_id,
                                l_uda_rec_tbl,
                                l_ret_status,
                                l_msg_count,
                                l_msg_data);

        /* Do the merging */
        IF (l_uda_rec_tbl.count <> 0) THEN
          do_single_row_uda_merge(l_uda_rec_tbl,
                                  merged_uda_rec,
                                  l_ret_status,
                                  l_msg_count,
                                  l_msg_data);

          SELECT COUNT(1)
          INTO   l_party_count
          FROM   pos_supp_prof_ext_b
          WHERE  attr_group_id = attributes_group_coll(cntr).attr_group_id
          AND    pk2_value = p_to_fk_id
          AND    rownum = 1;

          IF (l_party_count = 0) THEN
            /* Do the insert */
            do_uda_row_dml(p_attribute_group_id   => attributes_group_coll(cntr)
                                                     .attr_group_id,
                           p_data_level_id        => attributes_group_coll(cntr)
                                                     .data_level_id,
                           p_attribute_group_type => attributes_group_coll(cntr)
                                                     .attr_group_type,
                           p_attribute_group_name => attributes_group_coll(cntr)
                                                     .descriptive_flex_context_code,
                           p_to_party_id          => p_to_fk_id,
                           p_mode                 => 'INSERT',
                           p_uda_rec              => merged_uda_rec,
                           p_class_code           => attributes_group_coll(cntr)
                                                     .classification_code,
                           p_vendor_id            => p_from_id,
                           x_return_status        => l_ret_status,
                           x_msg_count            => l_msg_count,
                           x_msg_data             => l_msg_data);

          ELSE
            /* Do the update */
            do_uda_row_dml(p_attribute_group_id   => attributes_group_coll(cntr)
                                                     .attr_group_id,
                           p_data_level_id        => attributes_group_coll(cntr)
                                                     .data_level_id,
                           p_attribute_group_type => attributes_group_coll(cntr)
                                                     .attr_group_type,
                           p_attribute_group_name => attributes_group_coll(cntr)
                                                     .descriptive_flex_context_code,
                           p_to_party_id          => p_to_fk_id,
                           p_mode                 => 'UPDATE',
                           p_uda_rec              => merged_uda_rec,
                           p_class_code           => attributes_group_coll(cntr)
                                                     .classification_code,
                           p_vendor_id            => p_from_id,
                           x_return_status        => l_ret_status,
                           x_msg_count            => l_msg_count,
                           x_msg_data             => l_msg_data);
          END IF;
        END IF;
        -- End of single row processing
      ELSE

        /* If the attribute group is multi row */
        -- Multirow processing
        fnd_file.put_line(fnd_file.log,
                          'supplier_site_uda_merge multi row processing for attr group id : ' || attributes_group_coll(cntr)
                          .attr_group_id);

        get_supp_site_attr_data(p_from_fk_id,
                                p_to_fk_id,
                                attributes_group_coll(cntr).multi_row,
                                attributes_group_coll(cntr).attr_group_id,
                                attributes_group_coll(cntr).data_level_id,
                                l_uda_rec_tbl,
                                l_ret_status,
                                l_msg_count,
                                l_msg_data);

        /* Insert the rows obtained */

        do_uda_row_dml(p_attribute_group_id   => attributes_group_coll(cntr)
                                                 .attr_group_id,
                       p_data_level_id        => attributes_group_coll(cntr)
                                                 .data_level_id,
                       p_attribute_group_type => attributes_group_coll(cntr)
                                                 .attr_group_type,
                       p_attribute_group_name => attributes_group_coll(cntr)
                                                 .descriptive_flex_context_code,
                       p_to_party_id          => p_to_fk_id,
                       p_mode                 => 'INSERT',
                       p_uda_rec_tbl          => l_uda_rec_tbl,
                       p_class_code           => attributes_group_coll(cntr)
                                                 .classification_code,
                       p_vendor_id            => p_from_id,
                       x_return_status        => l_ret_status,
                       x_msg_count            => l_msg_count,
                       x_msg_data             => l_msg_data);
      END IF;

    --END LOOP; -- End of party loop

    END LOOP; -- end of attribute group loop

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END supplier_site_uda_merge;

  PROCEDURE party_site_uda_merge
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  ) IS
    l_ret_status VARCHAR2(2000);
    l_msg_count  NUMBER;
    l_msg_data   VARCHAR2(2000);

    l_uda_rec_tbl   uda_rec_tbl_type;
    merged_uda_rec  pos_supp_prof_ext_b%ROWTYPE;
    l_party_count   NUMBER := 0;
    l_to_party_cntr NUMBER := 0;

    CURSOR get_supplier_attribute_groups IS
      SELECT ag.attr_group_id,
             ag.application_id,
             eas.data_level_id,
             ag.multi_row,
             eas.attr_group_type,
             ag.descriptive_flex_context_code,
             ag.descriptive_flexfield_name,
             eas.classification_code,
             eas.data_level_int_name
      FROM   ego_fnd_dsc_flx_ctx_ext   ag,
             ego_obj_attr_grp_assocs_v eas
      WHERE  ag.application_id = 177
      AND    ag.attr_group_id = eas.attr_group_id
      AND    eas.application_id = ag.application_id
      AND    eas.data_level_int_name = 'SUPP_ADDR_LEVEL';

    TYPE attributes_group_tab IS TABLE OF get_supplier_attribute_groups%ROWTYPE INDEX BY BINARY_INTEGER;
    attributes_group_coll attributes_group_tab;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    SELECT COUNT(1)
    INTO   l_to_party_cntr
    FROM   pos_supplier_uda_merge_gtt
    WHERE  batch_id = p_batch_id
    AND    to_party_id = p_to_fk_id
    AND    rownum = 1;

    IF (l_to_party_cntr = 0) THEN
      INSERT INTO pos_supplier_uda_merge_gtt
        (batch_id, to_party_id)
      VALUES
        (p_batch_id, p_to_fk_id);
    ELSE
      RETURN;
    END IF;

    fnd_file.put_line(fnd_file.log,
                      'Inside POS_MERGE_SUPPLIER_PKG.party_site_uda_merge p_to_fk_id: ' ||
                      p_to_fk_id || ' p_from_fk_id: ' || p_from_fk_id ||
                      ' p_from_id: ' || p_from_id || ' p_batch_id: ' ||
                      p_batch_id);

    /* Update the status of all the records in the bath to
    PERFORM_UDA_MERGE*/

    /* Get the attribute group data from the cursor
    get_supplier_attribute_groups*/

    OPEN get_supplier_attribute_groups;
    FETCH get_supplier_attribute_groups BULK COLLECT
      INTO attributes_group_coll;
    CLOSE get_supplier_attribute_groups;

    /* Loop through the attribute group Ids */
    FOR cntr IN 1 .. attributes_group_coll.count LOOP

      /* check if the attribute group is a single row attribute or a
      multirow attribute*/

      /* If the attribute group is single row */
      IF (attributes_group_coll(cntr).multi_row = 'N') THEN

        /* Query the extension table for the to and from parties
        and get the rows in the ascending order of the creation
        date */
        fnd_file.put_line(fnd_file.log,
                          'party_site_uda_merge single row processing for attr group id : ' || attributes_group_coll(cntr)
                          .attr_group_id);

        get_party_site_attr_data(p_from_fk_id,
                                 p_to_fk_id,
                                 p_batch_id,
                                 attributes_group_coll(cntr).multi_row,
                                 attributes_group_coll(cntr).attr_group_id,
                                 attributes_group_coll(cntr).data_level_id,
                                 l_uda_rec_tbl,
                                 l_ret_status,
                                 l_msg_count,
                                 l_msg_data);

        /* Do the merging */
        IF (l_uda_rec_tbl.count <> 0) THEN
          do_single_row_uda_merge(l_uda_rec_tbl,
                                  merged_uda_rec,
                                  l_ret_status,
                                  l_msg_count,
                                  l_msg_data);

          SELECT COUNT(1)
          INTO   l_party_count
          FROM   pos_supp_prof_ext_b
          WHERE  attr_group_id = attributes_group_coll(cntr).attr_group_id
          AND    pk1_value = p_to_fk_id
          AND    rownum = 1;

          IF (l_party_count = 0) THEN
            /* Do the insert */
            do_uda_row_dml(p_attribute_group_id   => attributes_group_coll(cntr)
                                                     .attr_group_id,
                           p_data_level_id        => attributes_group_coll(cntr)
                                                     .data_level_id,
                           p_attribute_group_type => attributes_group_coll(cntr)
                                                     .attr_group_type,
                           p_attribute_group_name => attributes_group_coll(cntr)
                                                     .descriptive_flex_context_code,
                           p_to_party_id          => p_to_fk_id,
                           p_mode                 => 'INSERT',
                           p_uda_rec              => merged_uda_rec,
                           p_class_code           => attributes_group_coll(cntr)
                                                     .classification_code,
                           x_return_status        => l_ret_status,
                           x_msg_count            => l_msg_count,
                           x_msg_data             => l_msg_data);

          ELSE
            /* Do the update */
            do_uda_row_dml(p_attribute_group_id   => attributes_group_coll(cntr)
                                                     .attr_group_id,
                           p_data_level_id        => attributes_group_coll(cntr)
                                                     .data_level_id,
                           p_attribute_group_type => attributes_group_coll(cntr)
                                                     .attr_group_type,
                           p_attribute_group_name => attributes_group_coll(cntr)
                                                     .descriptive_flex_context_code,
                           p_to_party_id          => p_to_fk_id,
                           p_mode                 => 'UPDATE',
                           p_uda_rec              => merged_uda_rec,
                           p_class_code           => attributes_group_coll(cntr)
                                                     .classification_code,
                           x_return_status        => l_ret_status,
                           x_msg_count            => l_msg_count,
                           x_msg_data             => l_msg_data);
          END IF;
        END IF;
        -- End of single row processing
      ELSE

        /* If the attribute group is multi row */
        -- Multirow processing
        fnd_file.put_line(fnd_file.log,
                          'party_site_uda_merge multi row processing for attr group id : ' || attributes_group_coll(cntr)
                          .attr_group_id);

        get_party_site_attr_data(p_from_fk_id,
                                 p_to_fk_id,
                                 p_batch_id,
                                 attributes_group_coll(cntr).multi_row,
                                 attributes_group_coll(cntr).attr_group_id,
                                 attributes_group_coll(cntr).data_level_id,
                                 l_uda_rec_tbl,
                                 l_ret_status,
                                 l_msg_count,
                                 l_msg_data);

        /* Insert the rows obtained */

        do_uda_row_dml(p_attribute_group_id   => attributes_group_coll(cntr)
                                                 .attr_group_id,
                       p_data_level_id        => attributes_group_coll(cntr)
                                                 .data_level_id,
                       p_attribute_group_type => attributes_group_coll(cntr)
                                                 .attr_group_type,
                       p_attribute_group_name => attributes_group_coll(cntr)
                                                 .descriptive_flex_context_code,
                       p_to_party_id          => p_to_fk_id,
                       p_mode                 => 'INSERT',
                       p_uda_rec_tbl          => l_uda_rec_tbl,
                       p_class_code           => attributes_group_coll(cntr)
                                                 .classification_code,
                       x_return_status        => l_ret_status,
                       x_msg_count            => l_msg_count,
                       x_msg_data             => l_msg_data);
      END IF;

    --END LOOP; -- End of party loop

    END LOOP; -- end of attribute group loop

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END party_site_uda_merge;

  PROCEDURE enable_party_as_supplier
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  ) IS
    l_msg_count    NUMBER;
    l_msg_data     VARCHAR2(100);
    l_to_vendor_id NUMBER;

    vendor_rec              ap_vendor_pub_pkg.r_vendor_rec_type;
    l_vendor_id             NUMBER;
    l_party_id              NUMBER; /*:= p_to_fk_id*/
    l_ven_num_code          financials_system_parameters.user_defined_vendor_num_code%TYPE;
    l_party_orig_system_ref VARCHAR2(500);

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    fnd_file.put_line(fnd_file.log,
                      'Inside POS_MERGE_SUPPLIER_PKG.enable_party_as_supplier p_to_fk_id: ' ||
                      p_to_fk_id || ' p_to_fk_id: ' || p_from_fk_id);

    UPDATE ap_suppliers
    SET    end_date_active = SYSDATE
    WHERE  party_id = p_from_fk_id;

    SELECT COUNT(vendor_id)
    INTO   l_to_vendor_id
    FROM   ap_suppliers
    WHERE  party_id = p_to_fk_id;

    fnd_file.put_line(fnd_file.log, 'l_to_vendor_id: ' || l_to_vendor_id);

    IF (l_to_vendor_id = 0) THEN
      l_ven_num_code := pos_batch_import_pkg.chk_vendor_num_nmbering_method();

      IF (l_ven_num_code = 'MANUAL') THEN

        SELECT orig_system_reference
        INTO   l_party_orig_system_ref
        FROM   hz_orig_sys_references hr
        WHERE  hr.owner_table_name = 'HZ_PARTIES'
        AND    owner_table_id = p_to_fk_id
        AND    party_id = p_to_fk_id
        AND    hr.status = 'A'
        AND    (hr.reason_code <> 'MERGED' OR hr.reason_code IS NULL)
        AND    nvl(hr.end_date_active, SYSDATE) >= SYSDATE;

        vendor_rec.segment1 := l_party_orig_system_ref;
      END IF;

      vendor_rec.party_id := p_to_fk_id;

      ap_vendor_pub_pkg.create_vendor(1.0,
                                      fnd_api.g_false,
                                      fnd_api.g_false,
                                      fnd_api.g_valid_level_full,
                                      x_return_status,
                                      l_msg_count,
                                      l_msg_data,
                                      vendor_rec,
                                      l_vendor_id,
                                      l_party_id);

      fnd_file.put_line(fnd_file.log,
                        'x_return_status from ap_vendor_pub_pkg.create_vendor: ' ||
                        x_return_status || ' l_vendor_id: ' || l_vendor_id);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_file.put_line(fnd_file.log,
                          'No. of Messages: ' || l_msg_count ||
                          ', Message: ' || l_msg_data ||
                          ' From ap_vendor_pub_pkg.create_vendor API.');
        RETURN;
      ELSE
        x_to_id := l_vendor_id;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END enable_party_as_supplier;

END pos_merge_supplier_pkg;

/
