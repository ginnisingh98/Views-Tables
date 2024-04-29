--------------------------------------------------------
--  DDL for Package HZ_EXTRACT_PERSON_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTRACT_PERSON_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHEPPVS.pls 120.1.12000000.2 2007/02/23 20:54:25 awu ship $ */
/*
 * This package contains the private APIs for logical person.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname Person
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf Person Get APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_person_bo
  --
  -- DESCRIPTION
  --     Get a logical person.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_person_id          Person ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_obj         Logical person record.
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
The Get Person API Procedure is a retrieval service that returns a full Person business object.
The user identifies a particular Person business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Person business object is returned. The object consists of all data included within
the Person business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Person business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments
Party Site		N	Y		get_party_site_bo
Phone			N	Y		get_phone_bo
Email			N	Y		get_email_bo
Web			N	Y		get_web_bo
SMS			N	Y		get_sms_bo
Employment History	N	Y	Business Structure. Included entities:HZ_EMPLOYMENT_HISTORY, HZ_WORK_CLASS


To retrieve the appropriate embedded entities within the Person business object,
the Get procedure returns all records for the particular person from these TCA entity tables:

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Party,Person Profile	Y		N	HZ_PARTIES, HZ_PERSON_PROFILES
Person Preference	N		Y	HZ_PARTY_PREFERENCES
Relationship		N		Y	HZ_RELATIONSHIPS
Classification		N		Y	HZ_CODE_ASSIGNMENTS
Language		N		Y	HZ_PERSON_LANGUAGE
Education		N		Y	HZ_EDUCATION
Citizenship		N		Y	HZ_CITIZENSHIP
Interest		N		Y	HZ_PERSON_INTEREST
Certification		N		Y	HZ_CERTIFICATIONS
Financial Profile	N		Y	HZ_FINANCIAL_PROFILE
*/



 PROCEDURE get_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_person_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_persons_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Persons created business event and
  --the procedure returns database objects of the type HZ_PERSON_BO for all of
  --the Person business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_obj        One or more created logical person.
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
The Get Persons Created procedure is a service to retrieve all of the Person business objects
whose creations have been captured by a logical business event. Each Persons Created
business event signifies that one or more Person business objects have been created.
The caller provides an identifier for the Persons Created business event and the procedure
returns all of the Person business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_PERSON_BO_PVT.get_person_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_persons_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_objs         OUT NOCOPY    HZ_PERSON_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );



--------------------------------------
  --
  -- PROCEDURE get_persons_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Persons update business event and
  --the procedure returns database objects of the type HZ_PERSON_BO for all of
  --the Person business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_objs        One or more created logical person.
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
The Get Persons Updated procedure is a service to retrieve all of the Person business objects whose updates have been
captured by the logical business event. Each Persons Updated business event signifies that one or more Person business
objects have been updated.
The caller provides an identifier for the Persons Update business event and the procedure returns database objects of
the type HZ_PERSON_BO for all of the Person business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure
and returns them to the caller.
*/

 PROCEDURE get_persons_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_objs         OUT NOCOPY    HZ_PERSON_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

--------------------------------------
  --
  -- PROCEDURE get_person_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Persons update business event and person_id
  --the procedure returns one database object of the type HZ_PERSON_BO

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --     p_person_id          Person identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_objs        One or more created logical person.
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



-- Get only one person object based on p_person_id and event_id

PROCEDURE get_person_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_person_id           IN           NUMBER,
    x_person_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

-- called in hz_extract_person_cust_bo_pvt
procedure set_person_bo_action_type(p_event_id		  IN           	NUMBER,
				    p_root_id  IN NUMBER,
				    px_person_obj IN OUT NOCOPY HZ_PERSON_BO,
				    x_return_status       OUT NOCOPY    VARCHAR2);


END HZ_EXTRACT_PERSON_BO_PVT;

 

/
