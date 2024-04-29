--------------------------------------------------------
--  DDL for Package Body POS_HZ_PARTY_SITE_BO_TBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_HZ_PARTY_SITE_BO_TBL_PKG" AS
    /*$Header: POSSPPASB.pls 120.0.12010000.2 2010/10/11 08:48:20 ntungare noship $ */
    /*
    * This package contains the private APIs for logical party site.
    * @rep:scope private
    * @rep:product HZ
    * @rep:displayname party site
    * @rep:category BUSINESS_ENTITY HZ_PARTIE_SITES
    * @rep:lifecycle active
    * @rep:doccd 115hztig.pdf party site Get APIs
    */

    --------------------------------------
    --
    -- PROCEDURE get_party_site_bo
    --
    -- DESCRIPTION
    --     Get a logical party site.
    --
    -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
    --
    -- ARGUMENTS
    --   IN:
    --     p_init_msg_list      Initialize message stack if it is set to  FND_API.G_TRUE. Default is FND_API.G_FALSE.
    --       p_party_id          party ID.
    --       p_party_site_id     party site ID. If this id is not passed in, multiple site objects will be returned.
    --     p_party_site_os          party site orig system.
    --     p_party_site_osr         party site orig system reference.
    --
    --   OUT:
    --     x_party_site_objs         Logical party site records.
    --     x_return_status      Return status after the call. The status can
    --                          be fnd_api.g_ret_sts_success (success),
    --                          fnd_api.g_ret_sts_error (error),
    --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
    --     x_msg_count          Number of messages in message stack.
    --     x_msg_data           Message text if x_msg_count is 1.
    --
    -- NOTES
    --
    -- MODIFICATION HISTORY
    --
    --
    --   1-JUNE-2005   AWU                Created.
    --

    /*
    The Get party site API Procedure is a retrieval service that returns a full party site business object.
    The user identifies a particular party site business object using the TCA identifier and/or
    the object Source System information. Upon proper validation of the object,
    the full party site business object is returned. The object consists of all data included within
    the party site business object, at all embedded levels. This includes the set of all data stored
    in the TCA tables for each embedded entity.

    To retrieve the appropriate embedded business objects within the party site business object,
    the Get procedure calls the equivalent procedure for the following embedded objects:

    Embedded BO      Mandatory  Multiple Logical API Procedure    Comments
    Phone      N  Y    get_phone_bos
    Telex      N  Y    get_telex_bos
    Email      N  Y    get_email_bos
    Web      N  Y    get_web_bos

    To retrieve the appropriate embedded entities within the party site business object,
    the Get procedure returns all records for the particular party site from these TCA entity tables:

    Embedded TCA Entity  Mandatory  Multiple  TCA Table Entities

    Location    Y    N  HZ_LOCATIONS
    Party Site    Y    N  HZ_PARTY_SITES
    Party Site Use    N    Y  HZ_PARTY_SITE_USES
    Contact Preference  N    Y  HZ_CONTACT_PREFERENCES
    */

    PROCEDURE get_party_site_bos(p_party_id        IN NUMBER,
                                 x_party_site_objs OUT NOCOPY pos_hz_party_site_bo_tbl,
                                 x_return_status   OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2) IS

        l_debug_prefix VARCHAR2(30) := '';
    BEGIN
        SELECT pos_hz_party_site_bo(NULL, -- COMMON_OBJ_ID
                                    ps.party_site_id,
                                    NULL, --PS.ORIG_SYSTEM,
                                    NULL, --PS.ORIG_SYSTEM_REFERENCE,
                                    hz_extract_bo_util_pvt.get_parent_object_type('HZ_PARTIES',
                                                                                  ps.party_id),
                                    ps.party_id,
                                    ps.party_site_number,
                                    ps.mailstop,
                                    ps.identifying_address_flag,
                                    ps.status,
                                    ps.party_site_name,
                                    ps.attribute_category,
                                    ps.attribute1,
                                    ps.attribute2,
                                    ps.attribute3,
                                    ps.attribute4,
                                    ps.attribute5,
                                    ps.attribute6,
                                    ps.attribute7,
                                    ps.attribute8,
                                    ps.attribute9,
                                    ps.attribute10,
                                    ps.attribute11,
                                    ps.attribute12,
                                    ps.attribute13,
                                    ps.attribute14,
                                    ps.attribute15,
                                    ps.attribute16,
                                    ps.attribute17,
                                    ps.attribute18,
                                    ps.attribute19,
                                    ps.attribute20,
                                    ps.language,
                                    ps.addressee,
                                    ps.program_update_date,
                                    ps.created_by_module,
                                    hz_extract_bo_util_pvt.get_user_name(ps.created_by),
                                    ps.creation_date,
                                    ps.last_update_date,
                                    hz_extract_bo_util_pvt.get_user_name(ps.last_updated_by),
                                    ps.actual_content_source,
                                    ps.global_location_number,
                                    pos_supplier_uda_bo_pkg.get_uda_for_supplier_site(p_party_id,
                                                                                      ps.party_site_id,
                                                                                      NULL,
                                                                                      'SUPP_ADDR_LEVEL')) BULK COLLECT
        INTO   x_party_site_objs
        FROM   hz_party_sites ps
        WHERE  party_id = p_party_id;

     --Commented by BVAMSI on 07/Oct/2010 as it is already handled in the above Select query
     /*
	FOR i IN x_party_site_objs.first .. x_party_site_objs.last LOOP
          IF x_party_site_objs(i).party_site_id = 451801 THEN
            NULL;
          END IF;
            x_party_site_objs(i).p_pos_supp_uda_obj_tbl := pos_supplier_uda_bo_pkg.get_uda_for_supplier_site(p_party_id,
                                                                                                             x_party_site_objs(i)
                                                                                                             .party_site_id,
                                                                                                             NULL,
                                                                                                             'SUPP_ADDR_LEVEL');

        END LOOP;
     */
-- Comment by BVAMSI Ends here

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

END pos_hz_party_site_bo_tbl_pkg;

/
