--------------------------------------------------------
--  DDL for Package HZ_EXTRACT_PERSON_CUST_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTRACT_PERSON_CUST_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHEPAVS.pls 120.2 2008/02/06 10:16:55 vsegu ship $ */
/*
 * This package contains the private APIs for logical person_cust.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname Person Customer
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf Person Customer Get APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_person_cust_bo
  --
  -- DESCRIPTION
  --     Get a logical person customer.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_person_id          Person ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_obj         Logical person customer record.
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
The Get Person Customer API Procedure is a retrieval service that returns a full Person Customer business object.
The user identifies a particular Person Customer business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Person Customer business object is returned. The object consists of all data included within
the Person Customer business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Person Customer business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments

Person			Y	N	get_person_bo
Customer Account	Y	Y	get_cust_acct_bo	Called for each Customer Account object for the Person Customer

*/



 PROCEDURE get_person_cust_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_person_cust_obj     OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

PROCEDURE get_person_cust_v2_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_person_cust_v2_obj     OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_person_custs_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person Customers created business event and
  --the procedure returns database objects of the type HZ_PERSON CUSTOMER_BO for all of
  --the Person Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_objs   One or more created logical person customer.
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
The Get Person customers Created procedure is a service to retrieve all of the Person Customer business objects
whose creations have been captured by a logical business event. Each Person Customers Created
business event signifies that one or more Person Customer business objects have been created.
The caller provides an identifier for the Person Customers Created business event and the procedure
returns all of the Person Customer business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_PERSON_BO_PVT.get_person_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_person_custs_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_cust_objs         OUT NOCOPY    HZ_PERSON_CUST_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );



--------------------------------------
  --
  -- PROCEDURE get_person_custs_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person Customers update business event and
  --the procedure returns database objects of the type HZ_PERSON_CUST_BO for all of
  --the Person Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_objs   One or more created logical person.
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
The Get Person Customers Updated procedure is a service to retrieve all of the Person Customer business objects whose
updates have been captured by the logical business event. Each Person Customers Updated business event signifies that
one or more Person Customer business objects have been updated.
The caller provides an identifier for the Person Customers Update business event and the procedure returns database
objects of the type HZ_PERSON_CUST_BO for all of the Person Customer business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure
and returns them to the caller.
*/

 PROCEDURE get_person_custs_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_cust_objs         OUT NOCOPY    HZ_PERSON_CUST_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

--------------------------------------
  --
  -- PROCEDURE get_person_cust_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person customer update business event and person id
  --the procedure returns one database object of the type HZ_PERSON_CUST_BO
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --     p_person_cust_id        Person customer identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_obj       One updated logical person.
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
  --   06-JUN-2005     AWU                Created.
  --

 PROCEDURE get_person_cust_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_person_cust_id           IN           NUMBER,
    x_person_cust_obj         OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_v2_person_custs_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person Customers created business event and
  --the procedure returns database objects of the type HZ_PERSON CUSTOMER_BO for all of
  --the Person Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_v2_objs   One or more created logical person customer.
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
  --   10-JUN-2005    VSEGU                Created.
  --



/*
The Get Person customers Created procedure is a service to retrieve all of the Person Customer business objects
whose creations have been captured by a logical business event. Each Person Customers Created
business event signifies that one or more Person Customer business objects have been created.
The caller provides an identifier for the Person Customers Created business event and the procedure
returns all of the Person Customer business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_PERSON_BO_PVT.get_person_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_v2_person_custs_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_cust_v2_objs         OUT NOCOPY    HZ_PERSON_CUST_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );



--------------------------------------
  --
  -- PROCEDURE get_v2_person_custs_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person Customers update business event and
  --the procedure returns database objects of the type HZ_PERSON_CUST_V2_BO for all of
  --the Person Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_v2_objs   One or more created logical person.
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
  --   10-JUN-2005     VSEGU                Created.
  --



/*
The Get Person Customers Updated procedure is a service to retrieve all of the Person Customer business objects whose
updates have been captured by the logical business event. Each Person Customers Updated business event signifies that
one or more Person Customer business objects have been updated.
The caller provides an identifier for the Person Customers Update business event and the procedure returns database
objects of the type HZ_PERSON_CUST_V2_BO for all of the Person Customer business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure
and returns them to the caller.
*/

 PROCEDURE get_v2_person_custs_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_cust_v2_objs         OUT NOCOPY    HZ_PERSON_CUST_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

--------------------------------------
  --
  -- PROCEDURE get_v2_person_cust_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person customer update business event and person id
  --the procedure returns one database object of the type HZ_PERSON_CUST_V2_BO
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --     p_person_cust_id        Person customer identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_v2_obj       One updated logical person.
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

 PROCEDURE get_v2_person_cust_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_person_cust_id           IN           NUMBER,
    x_person_cust_v2_obj         OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

END HZ_EXTRACT_PERSON_CUST_BO_PVT;

/
