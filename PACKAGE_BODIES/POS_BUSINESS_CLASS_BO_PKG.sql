--------------------------------------------------------
--  DDL for Package Body POS_BUSINESS_CLASS_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_BUSINESS_CLASS_BO_PKG" AS
/* $Header: POSSPBUCB.pls 120.0.12010000.3 2010/03/03 11:24:53 ntungare noship $ */

    PROCEDURE validate_vendor_buss_class(p_vendor_buss_class_rec IN r_vendor_buss_rec_type,
                                         p_party_id              IN hz_parties.party_id%TYPE,
                                         x_return_status         OUT NOCOPY VARCHAR2,
                                         x_msg_count             OUT NOCOPY NUMBER,
                                         x_msg_data              OUT NOCOPY VARCHAR2,
                                         x_buss_valid            OUT NOCOPY VARCHAR2) IS
        l_dummy_lookup VARCHAR2(30);

        l_msg_count NUMBER;
        l_msg_data  VARCHAR2(2000);
        l_api_name CONSTANT VARCHAR2(30) := 'VALIDATE_VENDOR_BUSS_CLASS';
        l_request_id NUMBER := fnd_global.conc_request_id;
    BEGIN
        --  Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

        x_buss_valid := 'Y';

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
                x_msg_data      := 'AP_INVALID_BUSS_CLASS';
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
                    x_msg_data      := 'AP_INVALID_BUSS_CLASS';
                    RETURN;
            END;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            x_buss_valid    := 'N';
            x_return_status := fnd_api.g_ret_sts_unexp_error;

            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END validate_vendor_buss_class;

    /*#
    * Use this routine to get business class bo tbl
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_party_id The party id
    * @param x_pos_bus_class_bo_tbl The pos_business_class_bo_tbl
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Get POS Business Classification BO Table
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */

    PROCEDURE get_pos_business_class_bo_tbl(p_api_version           IN NUMBER DEFAULT NULL,
                                            p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
                                            p_party_id              IN NUMBER,
                                            p_orig_system           IN VARCHAR2,
                                            p_orig_system_reference IN VARCHAR2,
                                            x_pos_bus_class_bo_tbl  OUT NOCOPY pos_business_class_bo_tbl,
                                            x_return_status         OUT NOCOPY VARCHAR2,
                                            x_msg_count             OUT NOCOPY NUMBER,
                                            x_msg_data              OUT NOCOPY VARCHAR2) IS

        l_pos_bus_class_bo_tbl pos_business_class_bo_tbl := pos_business_class_bo_tbl();
        l_party_id             NUMBER;
    BEGIN
        IF p_party_id IS NULL THEN
            l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                               p_orig_system_reference);
            --l_party_id:=p_party_id;
        ELSE

            l_party_id := p_party_id;
        END IF;
        SELECT pos_business_class_bo(classification_id,
                                     party_id,
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
                                     attribute5,
                                     created_by,
                                     creation_date,
                                     last_updated_by,
                                     last_update_date,
                                     last_update_login,
                                     vendor_id) BULK COLLECT
        INTO   l_pos_bus_class_bo_tbl
        FROM   pos_bus_class_attr
        WHERE  party_id = p_party_id;

        x_pos_bus_class_bo_tbl := l_pos_bus_class_bo_tbl;

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
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
    END get_pos_business_class_bo_tbl;
    /*#
    * Use this routine to get business class bo tbl
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_party_id The party id
    * @param p_vendor_id The vendor id
    * @param p_lookup_code The look up code
    * @param p_exp_date The expiration date
    * @param p_cert_num The certification number
    * @param p_cert_agency The certifying agency
    * @param p_ext_attr_1 The external attribute number
    * @param p_class_status The class status
    * @param p_request_id The request id
    * @param p_lookup_type The Look up type
    * @param x_classification_id The classication id
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Business Classification Attributes
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
    PROCEDURE create_bus_class_attr(p_api_version           IN NUMBER DEFAULT NULL,
                                    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
                                    p_pos_bus_class_bo      IN pos_business_class_bo_tbl,
                                    p_party_id              IN NUMBER,
                                    p_orig_system           IN VARCHAR2,
                                    p_orig_system_reference IN VARCHAR2,
                                    p_create_update_flag    IN VARCHAR2,
                                    x_return_status         OUT NOCOPY VARCHAR2,
                                    x_msg_count             OUT NOCOPY NUMBER,
                                    x_msg_data              OUT NOCOPY VARCHAR2) IS

        l_count                 NUMBER;
        v_row_exists            INTEGER := 0;
        p_vendor_buss_class_rec r_vendor_buss_rec_type;
        l_out_classification_id NUMBER;
        -- p_party_id              NUMBER;
        l_party_id              NUMBER;
        l_buss_valid            VARCHAR2(1) := '';
        l_classification_id     NUMBER;
        l_mapping_id            NUMBER;
        l_buss_class_req_id     NUMBER;
        l_status                VARCHAR2(1);
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(1000);
        l_out_buss_class_req_id NUMBER;

        l_exception_msg VARCHAR2(1000);
    BEGIN

        /* p_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
        p_orig_system_reference);*/
        l_party_id := p_party_id;
        FOR i IN p_pos_bus_class_bo.first .. p_pos_bus_class_bo.last LOOP
            /*BEGIN

                SELECT 1
                INTO   v_row_exists
                FROM   pos_bus_class_attr
                WHERE  party_id = p_party_id
                AND    lookup_code = p_pos_bus_class_bo(I).lookup_code
                AND    lookup_type = p_pos_bus_class_bo(I).lookup_type
                AND    rownum < 2;
            EXCEPTION
                WHEN no_data_found THEN
                    v_row_exists := 0;
                WHEN OTHERS THEN
                    v_row_exists := 1;
            END;*/

            p_vendor_buss_class_rec.batch_id                    := 0;
            p_vendor_buss_class_rec.source_system               := p_orig_system;
            p_vendor_buss_class_rec.source_system_reference     := p_orig_system_reference;
            p_vendor_buss_class_rec.vendor_interface_id         := 0;
            p_vendor_buss_class_rec.business_class_interface_id := 0;
            p_vendor_buss_class_rec.classification_id           := p_pos_bus_class_bo(i).classification_id;
            p_vendor_buss_class_rec.vendor_id                   := p_pos_bus_class_bo(i).vendor_id;
            p_vendor_buss_class_rec.lookup_type                 := p_pos_bus_class_bo(i).lookup_type;
            p_vendor_buss_class_rec.lookup_code                 := p_pos_bus_class_bo(i).lookup_code;
            p_vendor_buss_class_rec.start_date_active           := p_pos_bus_class_bo(i).start_date_active;
            p_vendor_buss_class_rec.end_date_active             := p_pos_bus_class_bo(i).end_date_active;
            p_vendor_buss_class_rec.status                      := p_pos_bus_class_bo(i).status;
            p_vendor_buss_class_rec.ext_attr_1                  := p_pos_bus_class_bo(i).ext_attr_1;
            p_vendor_buss_class_rec.expiration_date             := p_pos_bus_class_bo(i).expiration_date;
            p_vendor_buss_class_rec.certificate_number          := p_pos_bus_class_bo(i).certificate_number;
            p_vendor_buss_class_rec.certifying_agency           := p_pos_bus_class_bo(i).certifying_agency;
            p_vendor_buss_class_rec.class_status                := p_pos_bus_class_bo(i).class_status;
            p_vendor_buss_class_rec.attribute1                  := p_pos_bus_class_bo(i).attribute1;
            p_vendor_buss_class_rec.attribute2                  := p_pos_bus_class_bo(i).attribute2;
            p_vendor_buss_class_rec.attribute3                  := p_pos_bus_class_bo(i).attribute3;
            p_vendor_buss_class_rec.attribute4                  := p_pos_bus_class_bo(i).attribute4;
            p_vendor_buss_class_rec.attribute5                  := p_pos_bus_class_bo(i).attribute5;

            IF p_create_update_flag = 'C' THEN

                validate_vendor_buss_class(p_vendor_buss_class_rec => p_vendor_buss_class_rec,
                                           p_party_id              => p_party_id,
                                           x_return_status         => x_return_status,
                                           x_msg_count             => x_msg_count,
                                           x_msg_data              => x_msg_data,
                                           x_buss_valid            => l_buss_valid);

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

                        pos_supp_classification_pkg.synchronize_class_tca_to_po(p_party_id,
                                                                                p_vendor_buss_class_rec.vendor_id);
                    END;
                ELSE
                    x_return_status := l_return_status;
                    x_msg_count     := l_msg_count;
                    x_msg_data      := l_msg_data;
                    RETURN;
                END IF;
            ELSIF p_create_update_flag = 'U' THEN

                ---Update
                BEGIN

                    SELECT classification_id
                    INTO   l_classification_id
                    FROM   pos_bus_class_attr
                    WHERE  party_id = l_party_id
                    AND    vendor_id = p_vendor_buss_class_rec.vendor_id
                    AND    lookup_code =
                           p_vendor_buss_class_rec.lookup_code;

                EXCEPTION
                    WHEN no_data_found THEN
                        l_classification_id := NULL;
                END;

                BEGIN
                    SELECT mapping_id
                    INTO   l_mapping_id
                    FROM   pos_supplier_mappings
                    WHERE  party_id = l_party_id
                    AND    vendor_id = p_vendor_buss_class_rec.vendor_id;

                    SELECT bus_class_request_id
                    INTO   l_buss_class_req_id
                    FROM   pos_bus_class_reqs
                    WHERE  mapping_id = l_mapping_id
                    AND    lookup_code =
                           p_vendor_buss_class_rec.lookup_code;

                EXCEPTION
                    WHEN no_data_found THEN
                        l_buss_class_req_id := NULL;
                END;

                pos_supp_classification_pkg.update_bus_class_attr(p_party_id          => l_party_id,
                                                                  p_vendor_id         => p_vendor_buss_class_rec.vendor_id,
                                                                  p_selected          => '',
                                                                  p_classification_id => l_classification_id,
                                                                  p_request_id        => l_buss_class_req_id,
                                                                  p_lookup_code       => p_vendor_buss_class_rec.lookup_code,
                                                                  p_exp_date          => p_vendor_buss_class_rec.expiration_date,
                                                                  p_cert_num          => p_vendor_buss_class_rec.certificate_number,
                                                                  p_cert_agency       => p_vendor_buss_class_rec.certifying_agency,
                                                                  p_ext_attr_1        => p_vendor_buss_class_rec.ext_attr_1,
                                                                  p_class_status      => p_vendor_buss_class_rec.class_status,
                                                                  x_classification_id => l_out_classification_id,
                                                                  x_request_id        => l_out_buss_class_req_id,
                                                                  x_status            => l_return_status,
                                                                  x_exception_msg     => l_msg_data);
            END IF;
        END LOOP;
        --end update

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
    END create_bus_class_attr;

END pos_business_class_bo_pkg;

/
