--------------------------------------------------------
--  DDL for Package HZ_EXTRACT_ACCT_SITE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTRACT_ACCT_SITE_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHECSVS.pls 120.2 2008/02/06 10:27:53 vsegu ship $ */
/*
 * This package contains the private APIs for logical customer account site.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname customer account site
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf customer account site Get APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_cust_acct_site_bos
  --
  -- DESCRIPTION
  --     Get logical customer account sites.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_parent_id          parent id.
--       p_cust_acct_site_id          customer account site ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_site_obj         Logical customer account site record.
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
  --   8-JUN-2005   AWU                Created.
  --

/*

The Get customer account site API Procedure is a retrieval service that returns a full customer account site business object.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's Source System
information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels.
This includes the set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments

Party Site			Y	N	get_party_site_bo
Customer Account Site Contact	N	Y	get_cust_acct_contact_bo
Customer Account Site Use	N	Y	Business Structure. Included entities and
						structures:HZ_CUST_SITE_USES_ALL,Customer
						Profile (Business Structure)


To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure returns
all records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer account site	Y		N	HZ_CUST_ACCOUNTS
Bank account site Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/



 PROCEDURE get_cust_acct_site_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_parent_id           IN            NUMBER,
    p_cust_acct_site_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_cust_acct_site_objs          OUT NOCOPY    HZ_CUST_ACCT_SITE_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );


 --------------------------------------
  --
  -- PROCEDURE get_cust_acct_site_v2_bos
  --
  -- DESCRIPTION
  --     Get logical customer account sites.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_parent_id          parent id.
--       p_cust_acct_site_id          customer account site ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_site_v2_obj         Logical customer account site record.
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
  --   31-JAN-2008   VSEGU                Created.
  --

/*

The Get customer account site API Procedure is a retrieval service that returns a full customer account site business object.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's Source System
information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels.
This includes the set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments

Party Site			Y	N	get_party_site_bo
Customer Account Site Contact	N	Y	get_cust_acct_contact_bo
Customer Account Site Use	N	Y	Business Structure. Included entities and
						structures:HZ_CUST_SITE_USES_ALL,Customer
						Profile (Business Structure)


To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure returns
all records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer account site	Y		N	HZ_CUST_ACCOUNTS
Bank account site Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/



 PROCEDURE get_cust_acct_site_v2_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_parent_id           IN            NUMBER,
    p_cust_acct_site_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_cust_acct_site_v2_objs          OUT NOCOPY    HZ_CUST_ACCT_SITE_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );


END HZ_EXTRACT_ACCT_SITE_BO_PVT;

/
