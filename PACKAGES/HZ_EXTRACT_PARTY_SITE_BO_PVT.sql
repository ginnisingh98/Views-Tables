--------------------------------------------------------
--  DDL for Package HZ_EXTRACT_PARTY_SITE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTRACT_PARTY_SITE_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHEPSVS.pls 120.1 2005/07/13 21:25:04 awu noship $ */
/*
 * This package contains the private APIs for logical party site.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname party site
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
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
  --   15-MAY-2005   AWU                Created.
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

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments
Phone			N	Y		get_phone_bos
Telex			N	Y		get_telex_bos
Email			N	Y		get_email_bos
Web			N	Y		get_web_bos

To retrieve the appropriate embedded entities within the party site business object,
the Get procedure returns all records for the particular party site from these TCA entity tables:

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Location		Y		N	HZ_LOCATIONS
Party Site		Y		N	HZ_PARTY_SITES
Party Site Use		N		Y	HZ_PARTY_SITE_USES
Contact Preference	N		Y	HZ_CONTACT_PREFERENCES
*/


 PROCEDURE get_party_site_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_party_id            IN NUMBER,
    p_party_site_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_party_site_objs          OUT NOCOPY    HZ_PARTY_SITE_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

END;

 

/
