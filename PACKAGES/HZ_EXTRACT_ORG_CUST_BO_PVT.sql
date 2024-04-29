--------------------------------------------------------
--  DDL for Package HZ_EXTRACT_ORG_CUST_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTRACT_ORG_CUST_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHEOAVS.pls 120.2 2008/02/06 10:33:54 vsegu ship $ */
/*
 * This package contains the private APIs for logical person_cust.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname Organization Customer
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf Organization Customer Get APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_org_cust_bo
  --
  -- DESCRIPTION
  --     Get a logical organization customer.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --       p_organization_id  Organization ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_org_cust_obj         Logical organization customer record.
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
  --   10-JUN-2005   AWU                Created.
  --

/*
The Get Organization Customer API Procedure is a retrieval service that returns a full Organization Customer business object.
The user identifies a particular Organization Customer business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Organization Customer business object is returned. The object consists of all data included within
the Organization Customer business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Organization Customer business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments

Person			Y	N	get_person_bo
Customer Account	Y	Y	get_cust_acct_bo	Called for each Customer Account object for the Organization Customer

*/



 PROCEDURE get_org_cust_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_org_cust_obj     OUT NOCOPY    HZ_ORG_CUST_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_org_custs_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organization Customers created business event and
  --the procedure returns database objects of the type HZ_ORG CUSTOMER_BO for all of
  --the Organization Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_org_cust_objs   One or more created logical organization customer.
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
  --   10-JUN-2005    AWU                Created.
  --



/*
The Get organization customers Created procedure is a service to retrieve all of the Organization Customer business objects
whose creations have been captured by a logical business event. Each Organization Customers Created
business event signifies that one or more Organization Customer business objects have been created.
The caller provides an identifier for the Organization Customers Created business event and the procedure
returns all of the Organization Customer business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_ORG_BO_PVT.get_org_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_org_custs_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_org_cust_objs         OUT NOCOPY    HZ_ORG_CUST_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );



--------------------------------------
  --
  -- PROCEDURE get_org_custs_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organization Customers update business event and
  --the procedure returns database objects of the type HZ_ORG_CUST_BO for all of
  --the Organization Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_org_cust_objs   One or more created logical person.
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
  --   10-JUN-2005     AWU                Created.
  --



/*
The Get Organization Customers Updated procedure is a service to retrieve all of the Organization Customer business
objects whose updates have been captured by the logical business event. Each Organization Customers Updated business
event signifies that one or more Organization Customer business objects have been updated.
The caller provides an identifier for the Organization Customers Update business event and the procedure returns
database objects of the type HZ_ORG_CUST_BO for all of the Organization Customer business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure
and returns them to the caller.
*/

 PROCEDURE get_org_custs_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_org_cust_objs         OUT NOCOPY    HZ_ORG_CUST_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

 PROCEDURE get_org_cust_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_org_cust_id           IN           NUMBER,
    x_org_cust_obj         OUT NOCOPY    HZ_ORG_CUST_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );


  --------------------------------------
  --
  -- PROCEDURE get_org_cust_v2_bo
  --
  -- DESCRIPTION
  --     Get a logical organization customer.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --       p_organization_id  Organization ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_org_cust_v2_obj         Logical organization customer record.
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
  --   04-FEB-2008   VSEGU                Created.
  --

/*
The Get Organization Customer API Procedure is a retrieval service that returns a full Organization Customer business object.
The user identifies a particular Organization Customer business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Organization Customer business object is returned. The object consists of all data included within
the Organization Customer business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Organization Customer business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments

Person			Y	N	get_person_bo
Customer Account	Y	Y	get_cust_acct_v2_bo	Called for each Customer Account object for the Organization Customer

*/



 PROCEDURE get_org_cust_v2_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_org_cust_v2_obj     OUT NOCOPY    HZ_ORG_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_v2_org_custs_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organization Customers created business event and
  --the procedure returns database objects of the type HZ_ORG CUSTOMER_BO for all of
  --the Organization Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_org_cust_v2_objs   One or more created logical organization customer.
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
  --   04-FEB-2008    VSEGU                Created.
  --



/*
The Get organization customers Created procedure is a service to retrieve all of the Organization Customer business objects
whose creations have been captured by a logical business event. Each Organization Customers Created
business event signifies that one or more Organization Customer business objects have been created.
The caller provides an identifier for the Organization Customers Created business event and the procedure
returns all of the Organization Customer business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_ORG_BO_PVT.get_org_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_v2_org_custs_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_org_cust_v2_objs         OUT NOCOPY    HZ_ORG_CUST_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );



--------------------------------------
  --
  -- PROCEDURE get_v2_org_custs_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organization Customers update business event and
  --the procedure returns database objects of the type HZ_ORG_CUST_V2_BO for all of
  --the Organization Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_org_cust_v2_objs   One or more created logical person.
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
  --   04-FEB-2008     VSEGU                Created.
  --



/*
The Get Organization Customers Updated procedure is a service to retrieve all of the Organization Customer business
objects whose updates have been captured by the logical business event. Each Organization Customers Updated business
event signifies that one or more Organization Customer business objects have been updated.
The caller provides an identifier for the Organization Customers Update business event and the procedure returns
database objects of the type HZ_ORG_CUST_V2_BO for all of the Organization Customer business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure
and returns them to the caller.
*/

 PROCEDURE get_v2_org_custs_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_org_cust_v2_objs         OUT NOCOPY    HZ_ORG_CUST_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

 PROCEDURE get_v2_org_cust_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_org_cust_id           IN           NUMBER,
    x_org_cust_v2_obj         OUT NOCOPY    HZ_ORG_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );
END HZ_EXTRACT_ORG_CUST_BO_PVT;

/
