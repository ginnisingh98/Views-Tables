--------------------------------------------------------
--  DDL for Package HZ_EXTRACT_ORGANIZATION_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTRACT_ORGANIZATION_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHEPOVS.pls 120.1.12000000.2 2007/02/23 20:54:05 awu ship $ */
/*
 * This package contains the private APIs for logical organization.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname Organization
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf Organization Get APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_organization_bo
  --
  -- DESCRIPTION
  --     Get a logical organization.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_organization_id          Organization ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_obj         Logical organization record.
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
  --   06-JUN-2005   AWU                Created.
  --

/*
The Get Organization API Procedure is a retrieval service that returns a full Organization business object.
The user identifies a particular Organization business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Organization business object is returned. The object consists of all data included within
the Organization business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Organization business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments
Org Contact	N	Y	get_contact_bo
Party Site	N	Y	get_party_site_bo
Phone	N	Y	get_phone_bo
Telex	N	Y	get_telex_bo
Email	N	Y	get_email_bo
Web	N	Y	get_web_bo
EDI	N	Y	get_edi_bo
EFT	N	Y	get_eft_bo
Financial Report	N	Y		Business Structure. Included entities: HZ_FINANCIAL_REPORTS, HZ_FINANCIAL_NUMBERS


To retrieve the appropriate embedded entities within the Organization business object,
the Get procedure returns all records for the particular organization from these TCA entity tables:

Embedded TCA Entity	Mandatory    Multiple	TCA Table Entities

Party, Org Profile	Y		N	HZ_PARTIES, HZ_ORGANIZATION_PROFILES
Org Preference		N		Y	HZ_PARTY_PREFERENCES
Relationship		N		Y	HZ_RELATIONSHIPS
Classification		N		Y	HZ_CODE_ASSIGNMENTS
Credit Rating		N		Y	HZ_CREDIT_RATINGS
Certification		N		Y	HZ_CERTIFICATIONS
Financial Profile	N		Y	HZ_FINANCIAL_PROFILE

*/


 PROCEDURE get_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_organization_obj          OUT NOCOPY    HZ_ORGANIZATION_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_organizations_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organizations created business event and
  --the procedure returns database objects of the type HZ_ORGANIZATION_BO for all of
  --the Organization business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_objs        One or more created logical organization.
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
  --   06-JUN-2005    AWU                Created.
  --



/*
The Get Organizations Created procedure is a service to retrieve all of the Organization business objects
whose creations have been captured by a logical business event. Each Organizations Created
business event signifies that one or more Organization business objects have been created.
The caller provides an identifier for the Organizations Created business event and the procedure
returns all of the Organization business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_ORGANIZATION_BO_PVT.get_organization_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_organizations_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_organization_objs         OUT NOCOPY    HZ_ORGANIZATION_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );



--------------------------------------
  --
  -- PROCEDURE get_organizations_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organizations update business event and
  --the procedure returns database objects of the type HZ_ORGANIZATION_BO for all of
  --the Organization business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_objs        One or more created logical organization.
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



/*
The Get Organizations Updated procedure is a service to retrieve all of the Organization business objects whose updates
have been captured by the logical business event. Each Organizations Updated business event signifies that one or more
Organization business objects have been updated.
The caller provides an identifier for the Organizations Update business event and the procedure returns database objects
of the type HZ_ORGANIZATION_BO for all of the Organization business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure
and returns them to the caller.
*/

 PROCEDURE get_organizations_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_organization_objs         OUT NOCOPY    HZ_ORGANIZATION_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );


--------------------------------------
  --
  -- PROCEDURE get_organization_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organizations update business event and organization id
  --the procedure returns one database object of the type HZ_ORGANIZATION_BO
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_objs        One or more created logical organization.
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

PROCEDURE get_organization_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_organization_id     IN           NUMBER,
    x_organization_obj    OUT NOCOPY   HZ_ORGANIZATION_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

-- called by set_org_cust_action_type
procedure set_org_bo_action_type(p_event_id		  IN           	NUMBER,
				    p_root_id  IN NUMBER,
				    px_org_obj IN OUT NOCOPY HZ_ORGANIZATION_BO,
				    x_return_status       OUT NOCOPY    VARCHAR2);


END HZ_EXTRACT_ORGANIZATION_BO_PVT;

 

/
