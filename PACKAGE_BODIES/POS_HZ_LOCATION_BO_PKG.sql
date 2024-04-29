--------------------------------------------------------
--  DDL for Package Body POS_HZ_LOCATION_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_HZ_LOCATION_BO_PKG" AS
/* $Header: POSSPLOCB.pls 120.0.12010000.2 2010/02/08 14:15:19 ntungare noship $ */
    /*#
    * Use this routine to get hz locations bo
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_party_id The party_id
    * @param x_hz_location_bo The pos hz locations bo
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Get HZ Location BO
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
    PROCEDURE get_hz_location_bo(p_api_version    IN NUMBER DEFAULT NULL,
                                 p_init_msg_list  IN VARCHAR2 DEFAULT NULL,
                                 p_party_id       IN NUMBER,
                                 p_orig_system           IN VARCHAR2,
                                 p_orig_system_reference IN VARCHAR2,
                                 x_hz_location_bo OUT NOCOPY pos_hz_location_bo_tbl,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2) IS

        l_pos_hz_location_bo pos_hz_location_bo_tbl;

    BEGIN

        SELECT pos_hz_location_bo(hz.location_id,
                                  hz.last_update_date,
                                  hz.last_updated_by,
                                  hz.creation_date,
                                  hz.created_by,
                                  hz.last_update_login,
                                  hz.request_id,
                                  hz.program_application_id,
                                  hz.program_id,
                                  hz.program_update_date,
                                  hz.wh_update_date,
                                  hz.attribute_category,
                                  hz.attribute1,
                                  hz.attribute2,
                                  hz.attribute3,
                                  hz.attribute4,
                                  hz.attribute5,
                                  hz.attribute6,
                                  hz.attribute7,
                                  hz.attribute8,
                                  hz.attribute9,
                                  hz.attribute10,
                                  hz.attribute11,
                                  hz.attribute12,
                                  hz.attribute13,
                                  hz.attribute14,
                                  hz.attribute15,
                                  hz.attribute16,
                                  hz.attribute17,
                                  hz.attribute18,
                                  hz.attribute19,
                                  hz.attribute20,
                                  hz.global_attribute_category,
                                  hz.global_attribute1,
                                  hz.global_attribute2,
                                  hz.global_attribute3,
                                  hz.global_attribute4,
                                  hz.global_attribute5,
                                  hz.global_attribute6,
                                  hz.global_attribute7,
                                  hz.global_attribute8,
                                  hz.global_attribute9,
                                  hz.global_attribute10,
                                  hz.global_attribute11,
                                  hz.global_attribute12,
                                  hz.global_attribute13,
                                  hz.global_attribute14,
                                  hz.global_attribute15,
                                  hz.global_attribute16,
                                  hz.global_attribute17,
                                  hz.global_attribute18,
                                  hz.global_attribute19,
                                  hz.global_attribute20,
                                  hz.orig_system_reference,
                                  hz.country,
                                  hz.address1,
                                  hz.address2,
                                  hz.address3,
                                  hz.address4,
                                  hz.city,
                                  hz.postal_code,
                                  hz.state,
                                  hz.province,
                                  hz.county,
                                  hz.address_key,
                                  hz.address_style,
                                  hz.validated_flag,
                                  hz.address_lines_phonetic,
                                  hz.apartment_flag,
                                  hz.po_box_number,
                                  hz.house_number,
                                  hz.street_suffix,
                                  hz.apartment_number,
                                  hz.secondary_suffix_element,
                                  hz.street,
                                  hz.rural_route_type,
                                  hz.rural_route_number,
                                  hz.street_number,
                                  hz.building,
                                  hz.floor,
                                  hz.suite,
                                  hz.room,
                                  hz.postal_plus4_code,
                                  hz.time_zone,
                                  hz.overseas_address_flag,
                                  hz.post_office,
                                  hz.position,
                                  hz.delivery_point_code,
                                  hz.location_directions,
                                  hz.address_effective_date,
                                  hz.address_expiration_date,
                                  hz.address_error_code,
                                  hz.clli_code,
                                  hz.dodaac,
                                  hz.trailing_directory_code,
                                  hz.language,
                                  hz.life_cycle_status,
                                  hz.short_description,
                                  hz.description,
                                  hz.content_source_type,
                                  hz.loc_hierarchy_id,
                                  hz.sales_tax_geocode,
                                  hz.sales_tax_inside_city_limits,
                                  hz.fa_location_id,
                                  hz.object_version_number,
                                  hz.created_by_module,
                                  hz.application_id,
                                  hz.timezone_id,
                                  hz.geometry_status_code,
                                  hz.actual_content_source,
                                  hz.validation_status_code,
                                  hz.date_validated,
                                  hz.do_not_validate_flag,
                                  NULL)
        BULK COLLECT INTO   l_pos_hz_location_bo
        FROM   hz_locations          hz,
               ap_suppliers          ap,
               ap_supplier_sites_all ss
        WHERE  ap.party_id = p_party_id
        AND    ss.vendor_id = ap.vendor_id
        AND    hz.location_id = ss.location_id;

        x_hz_location_bo := l_pos_hz_location_bo;

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
    END get_hz_location_bo;
    /*#
    * Use this routine to create hz locations bo
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_location_rec The hz_location_v2pub.location_rec_type
    * @param x_location_id The location id
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create HZ Location BO
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */

    PROCEDURE create_hz_location_bo(p_api_version           IN NUMBER DEFAULT NULL,
                                    p_init_msg_list         IN VARCHAR2 := fnd_api.g_false,
                                    p_orig_system           IN VARCHAR2,
                                    p_orig_system_reference IN VARCHAR2,
                                    p_hz_location_bo        IN pos_hz_location_bo,
                                    p_create_update_flag    IN VARCHAR2,
                                    x_location_id           OUT NOCOPY NUMBER,
                                    x_object_version_number OUT NOCOPY NUMBER,
                                    x_return_status         OUT NOCOPY VARCHAR2,
                                    x_msg_count             OUT NOCOPY NUMBER,
                                    x_msg_data              OUT NOCOPY VARCHAR2) IS
        p_location_rec hz_location_v2pub.location_rec_type;

    BEGIN

        p_location_rec.location_id                  := p_hz_location_bo.location_id;
        p_location_rec.orig_system_reference        := p_orig_system_reference;
        p_location_rec.orig_system                  := p_orig_system;
        p_location_rec.country                      := p_hz_location_bo.country;
        p_location_rec.address1                     := p_hz_location_bo.address1;
        p_location_rec.address2                     := p_hz_location_bo.address2;
        p_location_rec.address3                     := p_hz_location_bo.address3;
        p_location_rec.address4                     := p_hz_location_bo.address4;
        p_location_rec.city                         := p_hz_location_bo.city;
        p_location_rec.postal_code                  := p_hz_location_bo.postal_code;
        p_location_rec.state                        := p_hz_location_bo.state;
        p_location_rec.province                     := p_hz_location_bo.province;
        p_location_rec.county                       := p_hz_location_bo.county;
        p_location_rec.address_key                  := p_hz_location_bo.address_key;
        p_location_rec.address_style                := p_hz_location_bo.address_style;
        p_location_rec.validated_flag               := p_hz_location_bo.validated_flag;
        p_location_rec.address_lines_phonetic       := p_hz_location_bo.address_lines_phonetic;
        p_location_rec.po_box_number                := p_hz_location_bo.po_box_number;
        p_location_rec.house_number                 := p_hz_location_bo.house_number;
        p_location_rec.street_suffix                := p_hz_location_bo.street_suffix;
        p_location_rec.street                       := p_hz_location_bo.street;
        p_location_rec.street_number                := p_hz_location_bo.street_number;
        p_location_rec.floor                        := p_hz_location_bo.floor_name;
        p_location_rec.suite                        := p_hz_location_bo.suite;
        p_location_rec.postal_plus4_code            := p_hz_location_bo.postal_plus4_code;
        p_location_rec.position                     := p_hz_location_bo.position;
        p_location_rec.location_directions          := p_hz_location_bo.location_directions;
        p_location_rec.address_effective_date       := p_hz_location_bo.address_effective_date;
        p_location_rec.address_expiration_date      := p_hz_location_bo.address_expiration_date;
        p_location_rec.clli_code                    := p_hz_location_bo.clli_code;
        p_location_rec.language                     := p_hz_location_bo.language;
        p_location_rec.short_description            := p_hz_location_bo.short_description;
        p_location_rec.description                  := p_hz_location_bo.description;
        p_location_rec.geometry                     := p_hz_location_bo.geometry;
        p_location_rec.geometry_status_code         := p_hz_location_bo.geometry_status_code;
        p_location_rec.loc_hierarchy_id             := p_hz_location_bo.loc_hierarchy_id;
        p_location_rec.sales_tax_geocode            := p_hz_location_bo.sales_tax_geocode;
        p_location_rec.sales_tax_inside_city_limits := p_hz_location_bo.sales_tax_inside_city_limits;
        p_location_rec.fa_location_id               := p_hz_location_bo.fa_location_id;
        p_location_rec.content_source_type          := p_hz_location_bo.content_source_type;
        p_location_rec.attribute_category           := p_hz_location_bo.attribute_category;
        p_location_rec.attribute1                   := p_hz_location_bo.attribute1;
        p_location_rec.attribute2                   := p_hz_location_bo.attribute2;
        p_location_rec.attribute3                   := p_hz_location_bo.attribute3;
        p_location_rec.attribute4                   := p_hz_location_bo.attribute4;
        p_location_rec.attribute5                   := p_hz_location_bo.attribute5;
        p_location_rec.attribute6                   := p_hz_location_bo.attribute6;
        p_location_rec.attribute7                   := p_hz_location_bo.attribute7;
        p_location_rec.attribute8                   := p_hz_location_bo.attribute8;
        p_location_rec.attribute9                   := p_hz_location_bo.attribute9;
        p_location_rec.attribute10                  := p_hz_location_bo.attribute10;
        p_location_rec.attribute11                  := p_hz_location_bo.attribute11;
        p_location_rec.attribute12                  := p_hz_location_bo.attribute12;
        p_location_rec.attribute13                  := p_hz_location_bo.attribute13;
        p_location_rec.attribute14                  := p_hz_location_bo.attribute14;
        p_location_rec.attribute15                  := p_hz_location_bo.attribute15;
        p_location_rec.attribute16                  := p_hz_location_bo.attribute16;
        p_location_rec.attribute17                  := p_hz_location_bo.attribute17;
        p_location_rec.attribute18                  := p_hz_location_bo.attribute18;
        p_location_rec.attribute19                  := p_hz_location_bo.attribute19;
        p_location_rec.attribute20                  := p_hz_location_bo.attribute20;
        p_location_rec.timezone_id                  := p_hz_location_bo.timezone_id;
        p_location_rec.created_by_module            := p_hz_location_bo.created_by_module;
        p_location_rec.application_id               := p_hz_location_bo.application_id;
        p_location_rec.actual_content_source        := p_hz_location_bo.actual_content_source;
        p_location_rec.delivery_point_code          := p_hz_location_bo.delivery_point_code;

        IF p_create_update_flag = 'C' THEN
            hz_location_v2pub.create_location(p_init_msg_list,
                                              p_location_rec,
                                              x_location_id,
                                              x_return_status,
                                              x_msg_count,
                                              x_msg_data);
        ELSIF p_create_update_flag = 'U' THEN
            hz_location_v2pub.update_location(p_init_msg_list,
                                              p_location_rec,
                                              x_object_version_number,
                                              x_return_status,
                                              x_msg_count,
                                              x_msg_data);
        END IF;

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
    END;
    /*#
    * Use this routine to create hz locations bo
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_location_rec The hz_location_v2pub.location_rec_type
    * @param x_object_version_number The object version number
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Update Vendor Contact
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
/*PROCEDURE update_hz_location_bo(p_api_version           IN NUMBER DEFAULT NULL,
                                    p_init_msg_list         IN VARCHAR2 := fnd_api.g_false,
                                    p_location_rec          IN hz_location_v2pub.location_rec_type,
                                    x_object_version_number IN OUT NOCOPY NUMBER,
                                    x_return_status         OUT NOCOPY VARCHAR2,
                                    x_msg_count             OUT NOCOPY NUMBER,
                                    x_msg_data              OUT NOCOPY VARCHAR2) IS

    BEGIN

        hz_location_v2pub.update_location(p_init_msg_list,
                                          p_location_rec,
                                          x_object_version_number,
                                          x_return_status,
                                          x_msg_count,
                                          x_msg_data);

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
    END update_hz_location_bo;
*/
END pos_hz_location_bo_pkg;

/
