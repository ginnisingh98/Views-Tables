--------------------------------------------------------
--  DDL for Package HZ_EXTRACT_CUST_ACCT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTRACT_CUST_ACCT_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHECAVS.pls 120.2 2008/02/06 09:37:16 vsegu ship $ */
/*
 * This package contains the private APIs for logical customer account.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname customer account
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf customer account Get APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_cust_acct_bo
  --
  -- DESCRIPTION
  --     Get a logical customer account.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_cust_acct_id          customer account ID.
  --       p_parent_id	      Parent Id.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_obj         Logical customer account record.
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
  --   8-JUN-2005  AWU                Created.
  --

/*

The Get customer account API Procedure is a retrieval service that returns full customer account business objects.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's
Source System information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels.
This includes the set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments
Customer Account Site		N	Y	get_cust_acct_site_bo
Customer Account Contact	N	Y	get_cust_acct_contact_bo
Customer Profile		Y	N	Business Structure. Included entities:
                                                HZ_CUSTOMER_PROFILES, HZ_CUST_PROFILE_AMTS

To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure returns
all records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer Account	Y		N	HZ_CUST_ACCOUNTS
Account Relationship	N		Y	HZ_CUST_ACCT_RELATE
Bank Account Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/



 PROCEDURE get_cust_acct_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_parent_id           IN            NUMBER,
    p_cust_acct_id        IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_cust_acct_objs          OUT NOCOPY    HZ_CUST_ACCT_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

  --------------------------------------
  --
  -- PROCEDURE get_cust_acct_v2_bo
  --
  -- DESCRIPTION
  --     Get a logical customer account.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_cust_acct_id          customer account ID.
  --       p_parent_id	      Parent Id.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_v2_obj         Logical customer account record.
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
  --   1-FEB-2008  VSEGU                Created.
  --

/*

The Get customer account API Procedure is a retrieval service that returns full customer account business objects.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's
Source System information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels.
This includes the set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments
Customer Account Site		N	Y	get_cust_acct_site_v2_bo
Customer Account Contact	N	Y	get_cust_acct_contact_bo
Customer Profile		Y	N	Business Structure. Included entities:
                                                HZ_CUSTOMER_PROFILES, HZ_CUST_PROFILE_AMTS

To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure returns
all records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer Account	Y		N	HZ_CUST_ACCOUNTS
Account Relationship	N		Y	HZ_CUST_ACCT_RELATE
Bank Account Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/



 PROCEDURE get_cust_acct_v2_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_parent_id           IN            NUMBER,
    p_cust_acct_id        IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_cust_acct_v2_objs          OUT NOCOPY    HZ_CUST_ACCT_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );


END HZ_EXTRACT_CUST_ACCT_BO_PVT;

/
