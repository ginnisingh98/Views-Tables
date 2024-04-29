--------------------------------------------------------
--  DDL for Package Body POS_PRODUCT_SERVICE_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_PRODUCT_SERVICE_BO_PKG" AS
  /* $Header: POSSPPRSB.pls 120.0.12010000.1 2010/02/02 06:48:31 ntungare noship $ */
  PROCEDURE validate_vendor_prods_services
  (
    p_vendor_prodsrv_rec IN pos_product_service_bo,
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

    -- Below API would give the delimiter and the segment definition to be inserted
    pos_product_service_utl_pkg.initialize(x_status        => l_status,
                                           x_error_message => l_error_message);

    pos_product_service_utl_pkg.get_product_meta_data(x_product_segment_definition => l_product_segment_definition,
                                                      x_product_segment_count      => l_product_segment_count,
                                                      x_default_po_category_set_id => l_default_po_category_set_id,
                                                      x_delimiter                  => l_delimiter);

    -- Check if the number of segments into which the data has been
    -- inserted is equal to the product segment count
    IF (p_vendor_prodsrv_rec.segment_definition <>
       l_product_segment_definition) THEN
      x_prod_valid    := 'N';
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := 'AP_INVALID_SEGMENT_DEF';
      RETURN;
    END IF;

    l_seg_def := p_vendor_prodsrv_rec.segment_definition;

    WHILE (length(l_seg_def)) > l_start_pos LOOP
      l_index := instr(l_seg_def, l_delimiter, l_start_pos + 1);
      IF (l_index = 0) THEN
        EXIT;
      END IF;
      l_segment_code := l_segment_code || 'segment' ||
                        substr(l_seg_def,
                               l_start_pos + 1,
                               (l_index - l_start_pos - 1)) || '||' || '''' ||
                        l_delimiter || '''' || '||';
      l_start_pos    := l_index;
    END LOOP;

    l_segment_code := l_segment_code || 'segment' ||
                      substr(l_seg_def, l_start_pos + 1);

    SELECT nvl2(p_vendor_prodsrv_rec.segment1,
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
                p_vendor_prodsrv_rec.segment20)
    INTO   l_segment_concat
    FROM   dual;

    l_segment_count := (length(l_segment_concat) -
                       length(REPLACE(l_segment_concat, '.', '')));

    IF (l_segment_count <> l_product_segment_count) THEN
      x_prod_valid    := 'N';
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := 'AP_INVALID_SEGMENT_COUNT';
      RETURN;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_prod_valid    := 'N';
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
  END validate_vendor_prods_services;

  /* $Header: POSSPPRSB.pls 120.0.12010000.1 2010/02/02 06:48:31 ntungare noship $ */
  /*#
  * Use this routine to get product service bo
  * @param p_api_version The version of API
  * @param p_init_msg_list The Initialization message list
  * @param p_party_id The Party id
  * @param p_orig_system The Orig System
  * @param p_orig_system_reference The Orig System Reference
  * @param x_pos_product_service_bo_tbl The product service bo list
  * @param x_return_status The return status
  * @param x_msg_count The message count
  * @param x_msg_data The message data
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Supplier Product Service
  * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
  */
  PROCEDURE get_pos_product_service_bo_tbl
  (
    p_api_version                IN NUMBER DEFAULT NULL,
    p_init_msg_list              IN VARCHAR2 DEFAULT NULL,
    p_party_id                   IN NUMBER,
    p_orig_system                IN VARCHAR2,
    p_orig_system_reference      IN VARCHAR2,
    x_pos_product_service_bo_tbl OUT NOCOPY pos_product_service_bo_tbl,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  ) IS

    l_pos_product_service_bo_tbl pos_product_service_bo_tbl := pos_product_service_bo_tbl();
    l_party_id                   NUMBER;

  BEGIN

    IF p_party_id IS NULL OR p_party_id = 0 THEN

      l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                         p_orig_system_reference);
    ELSE
      l_party_id := p_party_id;
    END IF;
    SELECT pos_product_service_bo(ps.classification_id,
                                  ps.vendor_id,
                                  ps.segment1,
                                  ps.segment2,
                                  ps.segment3,
                                  ps.segment4,
                                  ps.segment5,
                                  ps.segment6,
                                  ps.segment7,
                                  ps.segment8,
                                  ps.segment9,
                                  ps.segment10,
                                  ps.segment11,
                                  ps.segment12,
                                  ps.segment13,
                                  ps.segment14,
                                  ps.segment15,
                                  ps.segment16,
                                  ps.segment17,
                                  ps.segment18,
                                  ps.segment19,
                                  ps.segment20,
                                  ps.status,
                                  ps.segment_definition,
                                  ps.created_by,
                                  ps.creation_date,
                                  ps.last_updated_by,
                                  ps.last_update_date,
                                  ps.last_update_login) BULK COLLECT
    INTO   l_pos_product_service_bo_tbl
    FROM   pos_sup_products_services ps,
           ap_suppliers              ap
    WHERE  ap.party_id = l_party_id
    AND    ps.vendor_id = ap.vendor_id;

    x_pos_product_service_bo_tbl := l_pos_product_service_bo_tbl;
    x_return_status              := fnd_api.g_ret_sts_success;
    x_msg_data                   := 'SUCCESS';
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
  END get_pos_product_service_bo_tbl;

  /*#
  * Use this routine to create approved product service
  * @param p_api_version The version of API
  * @param p_init_msg_list The Initialization message list
  * @param p_vendor_prodsrv_rec The product service bo
  * @param p_party_id  The Party Id
  * @param p_orig_system The Orig System
  * @param p_orig_system_reference The Orig System Reference
  * @param x_return_status The return status
  * @param x_msg_count The message count
  * @param x_msg_data The message data
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Create Supplier Product Service
  * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
  */
  PROCEDURE create_pos_product_service
  (
    p_api_version           IN NUMBER DEFAULT NULL,
    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
    p_vendor_prodsrv_rec    IN pos_product_service_bo_tbl,
    p_request_status        IN VARCHAR2,
    p_party_id              IN NUMBER,
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
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
    l_party_id      NUMBER;
    l_vendor_id     NUMBER;
  BEGIN
    IF p_party_id IS NULL OR p_party_id = 0 THEN

      l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                         p_orig_system_reference);
    ELSE
      l_party_id := p_party_id;
    END IF;

    FOR i IN p_vendor_prodsrv_rec.first .. p_vendor_prodsrv_rec.last LOOP
      -- Call Validate_Vendor_Prods_Services to validate the Products and Services data
      validate_vendor_prods_services(p_vendor_prodsrv_rec => p_vendor_prodsrv_rec(i),
                                     p_party_id           => l_party_id,
                                     x_return_status      => l_return_status,
                                     x_msg_count          => l_msg_count,
                                     x_msg_data           => l_msg_data,
                                     x_prod_valid         => l_prod_valid,
                                     x_segment_code       => l_segment_code);

      IF (l_prod_valid = 'Y') THEN
        -- Insert the data into the pos_product_service_requests table using the follwing API
        pos_product_service_utl_pkg.add_new_ps_req(p_vendor_id          => p_vendor_prodsrv_rec(i)
                                                                           .vendor_id,
                                                   p_segment1           => p_vendor_prodsrv_rec(i)
                                                                           .segment1,
                                                   p_segment2           => p_vendor_prodsrv_rec(i)
                                                                           .segment2,
                                                   p_segment3           => p_vendor_prodsrv_rec(i)
                                                                           .segment3,
                                                   p_segment4           => p_vendor_prodsrv_rec(i)
                                                                           .segment4,
                                                   p_segment5           => p_vendor_prodsrv_rec(i)
                                                                           .segment5,
                                                   p_segment6           => p_vendor_prodsrv_rec(i)
                                                                           .segment6,
                                                   p_segment7           => p_vendor_prodsrv_rec(i)
                                                                           .segment7,
                                                   p_segment8           => p_vendor_prodsrv_rec(i)
                                                                           .segment8,
                                                   p_segment9           => p_vendor_prodsrv_rec(i)
                                                                           .segment9,
                                                   p_segment10          => p_vendor_prodsrv_rec(i)
                                                                           .segment10,
                                                   p_segment11          => p_vendor_prodsrv_rec(i)
                                                                           .segment11,
                                                   p_segment12          => p_vendor_prodsrv_rec(i)
                                                                           .segment12,
                                                   p_segment13          => p_vendor_prodsrv_rec(i)
                                                                           .segment13,
                                                   p_segment14          => p_vendor_prodsrv_rec(i)
                                                                           .segment14,
                                                   p_segment15          => p_vendor_prodsrv_rec(i)
                                                                           .segment15,
                                                   p_segment16          => p_vendor_prodsrv_rec(i)
                                                                           .segment16,
                                                   p_segment17          => p_vendor_prodsrv_rec(i)
                                                                           .segment17,
                                                   p_segment18          => p_vendor_prodsrv_rec(i)
                                                                           .segment18,
                                                   p_segment19          => p_vendor_prodsrv_rec(i)
                                                                           .segment19,
                                                   p_segment20          => p_vendor_prodsrv_rec(i)
                                                                           .segment20,
                                                   p_segment_definition => p_vendor_prodsrv_rec(i)
                                                                           .segment_definition,
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
          IF (p_request_status = 'APPROVED') THEN

            -- Get the mapping_id using the following SQLL
            SELECT mapping_id
            INTO   l_mapping_id
            FROM   pos_supplier_mappings
            WHERE  vendor_id = p_vendor_prodsrv_rec(i).vendor_id
            AND    party_id = l_party_id;

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
    END LOOP;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
  END create_pos_product_service;
 /* /*#
  * Use this routine to update status field of  product service table
  * @param p_api_version The version of API
  * @param p_init_msg_list The Initialization message list
  * @param p_req_id The classification id
  * @param p_status The status to be updated with
  * @param x_return_status The return status
  * @param x_msg_count The message count
  * @param x_msg_data The message data
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Create Supplier Contact
  * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
  */
/* PROCEDURE update_pos_prod_service_status(p_req_id        IN NUMBER,
                                             p_status        IN VARCHAR2,
                                             x_return_status OUT NOCOPY VARCHAR2,
                                             x_msg_count     OUT NOCOPY NUMBER,
                                             x_msg_data      OUT NOCOPY VARCHAR2) IS
    BEGIN

        UPDATE pos_sup_products_services
        SET    status            = p_status,
               last_updated_by   = fnd_global.user_id,
               last_update_date  = SYSDATE,
               last_update_login = fnd_global.login_id
        WHERE  classification_id = p_req_id;

        x_return_status := fnd_api.g_ret_sts_success;
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;

            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END update_pos_prod_service_status;
*/
END pos_product_service_bo_pkg;

/
