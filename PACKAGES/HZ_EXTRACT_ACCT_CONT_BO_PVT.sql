--------------------------------------------------------
--  DDL for Package HZ_EXTRACT_ACCT_CONT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTRACT_ACCT_CONT_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHECCVS.pls 120.2 2005/07/13 21:26:54 awu noship $ */
/*
 * This package contains the private APIs for logical customer account contact.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname customer account contact
 * @rep:category BUSINESS_ENTITY
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf customer account contact Get APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_cust_acct_contact_bo
  --
  -- DESCRIPTION
  --     Get a logical customer account contact.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_cust_acct_contact_id          customer account contact ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_contact_objs        Logical customer account contact records.
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

The Get customer account contact API Procedure is a retrieval service that returns a full customer account contact business object.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's Source System
information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels.
This includes the set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments

Org Contact		Y		N	get_org_contact_bo


To retrieve the appropriate embedded entities within the 'Customer Account Contact' business object, the Get procedure returns
all records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer Account Role	N	N	HZ_CUST_ACCOUNT_ROLES
Role Responsibility	N	Y	HZ_ROLE_RESPONSIBILITY

*/



 PROCEDURE get_cust_acct_contact_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_parent_id           IN            NUMBER,
    p_cust_acct_contact_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_cust_acct_contact_objs          OUT NOCOPY    HZ_CUST_ACCT_CONTACT_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );


END HZ_EXTRACT_ACCT_CONT_BO_PVT;

 

/
