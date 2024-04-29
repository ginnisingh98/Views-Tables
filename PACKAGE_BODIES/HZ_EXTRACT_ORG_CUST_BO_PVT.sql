--------------------------------------------------------
--  DDL for Package Body HZ_EXTRACT_ORG_CUST_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTRACT_ORG_CUST_BO_PVT" AS
/*$Header: ARHEOAVB.pls 120.9.12010000.2 2009/08/21 01:31:21 awu ship $ */
/*
 * This package contains the private APIs for logical org customer.
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

Organization			Y	N	get_organization_bo
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
  ) is
l_debug_prefix              VARCHAR2(30) := '';

begin
		-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_org_cust_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	x_org_cust_obj := HZ_ORG_CUST_BO(p_action_type, NULL, NULL);

	HZ_EXTRACT_ORGANIZATION_BO_PVT.get_organization_bo(
    		p_init_msg_list   => fnd_api.g_false,
    		p_organization_id => p_organization_id,
    		p_action_type	  => p_action_type,
    		x_organization_obj => x_org_cust_obj.organization_obj,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	HZ_EXTRACT_CUST_ACCT_BO_PVT.get_cust_acct_bos(
    		p_init_msg_list    => fnd_api.g_false,
    		p_parent_id        => p_organization_id,
    		p_cust_acct_id     => NULL,
    		p_action_type	   => p_action_type,
    		x_cust_acct_objs   => x_org_cust_obj.account_objs,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_org_cust_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_cust_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_cust_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_cust_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

function get_org_operation_type(p_event_id in number) return varchar2 is


	cursor check_org_action_type_csr is
		select child_operation_flag
		from hz_bus_obj_tracking
		where event_id = p_event_id
		and child_bo_code = 'ORG'
		and parent_bo_code = 'ORG_CUST';

l_child_operation_flag varchar2(1);
begin

	open  check_org_action_type_csr;
	fetch check_org_action_type_csr into l_child_operation_flag;
	close check_org_action_type_csr;

	return l_child_operation_flag;
end;

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
  ) is

l_obj_root_ids HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL;
l_debug_prefix              VARCHAR2(30) := '';
L_CHILD_OPERATION_FLAG varchar2(1);
l_action_type varchar2(30);

begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_org_cust_created(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => l_obj_root_ids,
   	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

        l_child_operation_flag:= get_org_operation_type(p_event_id);

	if L_CHILD_OPERATION_FLAG = 'I'
	then
		l_action_type := 'CREATED';
	else
		l_action_type := 'UNCHANGED'; -- default to unchanged.
	end if;


  	-- call event API get_org_cust_updated for each id.

  	x_org_cust_objs := HZ_ORG_CUST_BO_TBL();


	for i in 1..l_obj_root_ids.count loop

		x_org_cust_objs.extend;
	/*	get_org_cust_bo(
    		p_init_msg_list => fnd_api.g_false,
                p_organization_id  => l_obj_root_ids(i),
                p_action_type => 'CREATED',
    		x_org_cust_obj  => x_org_cust_objs(i),
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;
*/

		x_org_cust_objs(i) := HZ_ORG_CUST_BO('UNCHANGED', NULL, NULL);

		HZ_EXTRACT_ORGANIZATION_BO_PVT.get_organization_bo(
    		p_init_msg_list   => fnd_api.g_false,
    		p_organization_id => l_obj_root_ids(i),
    		p_action_type	  => l_action_type,
    		x_organization_obj => x_org_cust_objs(i).organization_obj,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;

		if L_CHILD_OPERATION_FLAG = 'U'
		then
			HZ_EXTRACT_ORGANIZATION_BO_PVT.set_org_bo_action_type(p_event_id =>p_event_id,
				p_root_id => l_obj_root_ids(i),
				px_org_obj => x_org_cust_objs(i).organization_obj,
				x_return_status => x_return_status);

		end if;

		HZ_EXTRACT_CUST_ACCT_BO_PVT.get_cust_acct_bos(
    		p_init_msg_list    => fnd_api.g_false,
    		p_parent_id        => l_obj_root_ids(i),
    		p_cust_acct_id     => NULL,
    		p_action_type	   => 'CREATED',
    		x_cust_acct_objs   => x_org_cust_objs(i).account_objs,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;
		if L_CHILD_OPERATION_FLAG = 'I'
		then
			x_org_cust_objs(i).action_type := 'CREATED';
		else
			x_org_cust_objs(i).action_type := 'CHILD_UPDATED';
		end if;

  	end loop;

	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_org_cust_created (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_cust_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_cust_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_cust_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;



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
  --     x_org_cust_objs   One or more updated logical org customer.
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
  ) is

l_obj_root_ids HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL;
l_debug_prefix              VARCHAR2(30) := '';

begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_org_custs_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => l_obj_root_ids,
   	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;



  	x_org_cust_objs := HZ_ORG_CUST_BO_TBL();

	for i in 1..l_obj_root_ids.count loop
		x_org_cust_objs.extend;
		get_org_cust_updated(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
    		p_org_cust_id  => l_obj_root_ids(i),
    		x_org_cust_obj  => x_org_cust_objs(i),
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

  	end loop;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_org_custs_updated (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_custs_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_custs_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_custs_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

procedure set_org_acct_bo_action_type(p_node_path IN       VARCHAR2,
				    p_child_id  IN NUMBER,
				    p_action_type IN VARCHAR2,
				    p_child_entity_name IN VARCHAR2,
				    px_cust_acct_obj IN OUT NOCOPY HZ_CUST_ACCT_BO) is
l_child_upd_flag varchar2(1):='N';
l_cust_acct_relate_id number;

begin

	-- check root level entities
	if p_child_entity_name  = 'HZ_CUST_ACCOUNTS'
	then
		if px_cust_acct_obj.cust_acct_id = p_child_id
		then
			px_cust_acct_obj.action_type := p_action_type;
		        l_child_upd_flag := 'N';
 		end if;
	end if;

	-- check first level objs


	if p_child_entity_name = 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V' then
		for i in 1..PX_CUST_ACCT_OBJ.BANK_ACCT_USE_OBJS.COUNT
		loop
			if PX_CUST_ACCT_OBJ.BANK_ACCT_USE_OBJS(i).BANK_ACCT_USE_ID = p_child_id
			then PX_CUST_ACCT_OBJ.BANK_ACCT_USE_OBJS(i).action_type := p_action_type;
			     l_child_upd_flag := 'Y';
			end if;
		end loop;
	elsif p_child_entity_name = 'HZ_CUST_ACCT_RELATE_ALL' then
		for i in 1..PX_CUST_ACCT_OBJ.ACCT_RELATE_OBJS.COUNT
		loop
			 -- bug 8654754: cust_acct_relate_id is not a attribute in acct relate obj.
			select cust_acct_relate_id into l_cust_acct_relate_id
			from HZ_CUST_ACCT_RELATE_ALL
			where cust_account_id = PX_CUST_ACCT_OBJ.ACCT_RELATE_OBJS(i).cust_acct_id
 			and related_cust_account_id = PX_CUST_ACCT_OBJ.ACCT_RELATE_OBJS(i).related_cust_acct_id
			and relationship_type = PX_CUST_ACCT_OBJ.ACCT_RELATE_OBJS(i).relationship_type
			and org_id = PX_CUST_ACCT_OBJ.ACCT_RELATE_OBJS(i).org_id
			and rownum =1;

			if l_cust_acct_relate_id = p_child_id
			then PX_CUST_ACCT_OBJ.ACCT_RELATE_OBJS(i).action_type := p_action_type;
			     l_child_upd_flag := 'Y';
			end if;

		end loop;
	elsif p_child_entity_name = 'RA_CUST_RECEIPT_METHODS' then

		if PX_CUST_ACCT_OBJ.PAYMENT_METHOD_OBJ.PAYMENT_METHOD_ID = p_child_id
		then PX_CUST_ACCT_OBJ.PAYMENT_METHOD_OBJ.action_type := p_action_type;
	             l_child_upd_flag := 'Y';
		end if;
	end if;
	if px_cust_acct_obj.action_type =  'UNCHANGED'  and l_child_upd_flag =  'Y'
	then
		px_cust_acct_obj.action_type := 'CHILD_UPDATED';
	end if;


	-- check customer porfile obj
	if instr(p_node_path, 'ORG_CUST/CUST_ACCT/CUST_PROFILE') > 0
	then
		if p_child_entity_name = 'HZ_CUSTOMER_PROFILES'
		then
			if PX_CUST_ACCT_OBJ.CUST_PROFILE_OBJ.CUST_ACCT_PROFILE_ID = p_child_id
			then
				PX_CUST_ACCT_OBJ.CUST_PROFILE_OBJ.action_type := p_action_type;
		        	l_child_upd_flag := 'N';
			end if;
		end if;

		if p_child_entity_name = 'HZ_CUST_PROFILE_AMTS'
		then
			for i in 1..PX_CUST_ACCT_OBJ.CUST_PROFILE_OBJ.CUST_PROFILE_AMT_OBJS.COUNT
			loop
				if PX_CUST_ACCT_OBJ.CUST_PROFILE_OBJ.CUST_PROFILE_AMT_OBJS(i).CUST_ACCT_PROFILE_AMT_ID = p_child_id
				then PX_CUST_ACCT_OBJ.CUST_PROFILE_OBJ.CUST_PROFILE_AMT_OBJS(i).action_type := p_action_type;
	     		             l_child_upd_flag := 'Y';
				end if;
			end loop;
		end if;

		if px_cust_acct_obj.CUST_PROFILE_OBJ.action_type =  'UNCHANGED'  and l_child_upd_flag =  'Y'
		then
			px_cust_acct_obj.CUST_PROFILE_OBJ.action_type := 'CHILD_UPDATED';
		end if;

	end if;

	-- check account contact obj

	if instr(p_node_path, 'ORG_CUST/CUST_ACCT/CUST_ACCT_CONTACT') > 0
	then
		for i in 1..PX_CUST_ACCT_OBJ.CUST_ACCT_CONTACT_OBJS.COUNT
		loop
			if p_child_entity_name = 'HZ_CUST_ACCOUNT_ROLES'
			then
			   if PX_CUST_ACCT_OBJ.CUST_ACCT_CONTACT_OBJS(i).CUST_ACCT_CONTACT_ID = p_child_id
		           then
				PX_CUST_ACCT_OBJ.CUST_ACCT_CONTACT_OBJS(i).action_type :=  p_action_type;
				l_child_upd_flag := 'N';
			   end if;
			end if;


			if p_child_entity_name = 'HZ_ROLE_RESPONSIBILITY'
			then
				for j in 1..PX_CUST_ACCT_OBJ.CUST_ACCT_CONTACT_OBJS(i).CONTACT_ROLE_OBJS.COUNT
				loop
					if PX_CUST_ACCT_OBJ.CUST_ACCT_CONTACT_OBJS(i).CONTACT_ROLE_OBJS(j).RESPONSIBILITY_ID = p_child_id
					then PX_CUST_ACCT_OBJ.CUST_ACCT_CONTACT_OBJS(i).CONTACT_ROLE_OBJS(j).action_type := p_action_type;
	     		                     l_child_upd_flag := 'Y';
					end if;
				end loop;
			end if;
			if  PX_CUST_ACCT_OBJ.CUST_ACCT_CONTACT_OBJS(i).action_type =  'UNCHANGED'
			    and l_child_upd_flag = 'Y'
			then PX_CUST_ACCT_OBJ.CUST_ACCT_CONTACT_OBJS(i).action_type := 'CHILD_UPDATED';
			end if;
		end loop;

	end if;

	-- check account site obj

	if instr(p_node_path, 'ORG_CUST/CUST_ACCT/CUST_ACCT_SITE') > 0
	then
		for i in 1..PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS.COUNT
		loop
			if p_child_entity_name = 'HZ_CUST_ACCT_SITES_ALL'
			then
			   if PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).cust_acct_site_id = p_child_id
		           then
				PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).action_type := p_action_type;
				l_child_upd_flag := 'N';
			   end if;
			end if;

			for j in 1..PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS.COUNT
			loop
				if p_child_entity_name = 'HZ_CUST_SITE_USES_ALL'
				then

					if PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).SITE_USE_ID = p_child_id
					then PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).action_type := p_action_type;
					     l_child_upd_flag := 'Y';
					end if;
				end if;

				if p_child_entity_name = 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V' then
					for k in 1..PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).BANK_ACCT_USE_OBJS.COUNT
					loop
						if PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).BANK_ACCT_USE_OBJS(k).BANK_ACCT_USE_ID = p_child_id
						then PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).BANK_ACCT_USE_OBJS(k).action_type := p_action_type;
					            l_child_upd_flag := 'Y';
						end if;
					end loop;
				elsif p_child_entity_name = 'RA_CUST_RECEIPT_METHODS' then

					if PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).PAYMENT_METHOD_OBJ.PAYMENT_METHOD_ID = p_child_id
					then PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).PAYMENT_METHOD_OBJ.action_type := p_action_type;
					     l_child_upd_flag := 'Y';
					end if;

				elsif p_child_entity_name = 'HZ_CUSTOMER_PROFILES' then

					if PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).SITE_USE_PROFILE_OBJ.CUST_ACCT_PROFILE_ID = p_child_id
					then PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).SITE_USE_PROFILE_OBJ.action_type := p_action_type;
					     l_child_upd_flag := 'Y';
					end if;

				end if;

			end loop; -- CUST_ACCT_SITE_USE_OBJS.COUNT

			for j in 1..PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS.COUNT
			loop

				if p_child_entity_name = 'HZ_CUST_ACCOUNT_ROLES'
				then
				   if PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j).CUST_ACCT_CONTACT_ID = p_child_id
				   then
					PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j).action_type := p_action_type;
					l_child_upd_flag := 'N';
				   end if;
				end if;


				if p_child_entity_name = 'HZ_ROLE_RESPONSIBILITY'
				then
					for k in 1..PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j). CONTACT_ROLE_OBJS.COUNT
					loop
						if PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j).CONTACT_ROLE_OBJS(k).RESPONSIBILITY_ID = p_child_id
						then PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j).CONTACT_ROLE_OBJS(k).action_type := p_action_type;
					             l_child_upd_flag := 'Y';
						end if;
					end loop;
				end if;
			if  PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j).action_type =  'UNCHANGED'
			    and l_child_upd_flag = 'Y'
			then PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j).action_type := 'CHILD_UPDATED';
			end if;
			end loop; -- CUST_ACCT_CONTACT_OBJS.COUNT
		if  PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).action_type =  'UNCHANGED'
			           and l_child_upd_flag = 'Y'
		then PX_CUST_ACCT_OBJ.CUST_ACCT_SITE_OBJS(i).action_type := 'CHILD_UPDATED';
		end if;

		if  PX_CUST_ACCT_OBJ.action_type =  'UNCHANGED' and l_child_upd_flag = 'Y'
		then PX_CUST_ACCT_OBJ.action_type := 'CHILD_UPDATED';
		end if;

        end loop; -- acct site obj
    end if;

end set_org_acct_bo_action_type;

procedure set_org_cust_bo_action_type(p_event_id		  IN           	NUMBER,
				    p_root_id  IN NUMBER,
				    px_org_cust_obj IN OUT NOCOPY HZ_ORG_CUST_BO,
				    x_return_status       OUT NOCOPY    VARCHAR2) is

	cursor c1 is

	   SELECT
  		sys_connect_by_path(CHILD_BO_CODE, '/') node_path,
  		CHILD_OPERATION_FLAG,
  		CHILD_BO_CODE,
  		CHILD_ENTITY_NAME,
  		CHILD_ID,
  		populated_flag
	 FROM HZ_BUS_OBJ_TRACKING
         where event_id = p_event_id
	 START WITH child_id = p_root_id
   		AND child_entity_name = 'HZ_PARTIES'
   		AND  PARENT_BO_CODE IS NULL
   		AND event_id = p_event_id
   		AND CHILD_BO_CODE = 'ORG_CUST' --(or ORG, PERSON_CUST, ORG_CUST).
	CONNECT BY PARENT_ENTITY_NAME = PRIOR CHILD_ENTITY_NAME
    	AND PARENT_ID = PRIOR CHILD_ID
    	AND parent_bo_code = PRIOR child_bo_code
	and event_id = PRIOR event_id;

	cursor  c2 is
    	   select child_event_id,creation_date
	    FROM HZ_BUS_OBJ_TRACKING
	    where event_id = p_event_id
	    and parent_bo_code is null
	    and rownum = 1;

	CURSOR c_get_child_event_id(cp_creation_date DATE) IS

		SELECT event_id
    		FROM HZ_BUS_OBJ_TRACKING
    		WHERE creation_date = cp_creation_date
    		AND child_id = p_root_id
    		AND child_event_id IS NULL
    		and event_id <> p_event_id
		and rownum = 1;

L_CHILD_OPERATION_FLAG VARCHAR2(1);
L_CHILD_BO_CODE VARCHAR2(30);
L_CHILD_ENTITY_NAME  VARCHAR2(30);
L_CHILD_ID NUMBER;
l_action_type varchar2(30);
l_node_path varchar2(2000);
l_populated_flag varchar2(1);
l_child_upd_flag varchar2(1);
l_child_event_id number;
l_creation_date date;

begin
	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

	open c2;
        fetch c2 into l_child_event_id, l_creation_date;
	close c2;

	if l_child_event_id is null
	then
		OPEN c_get_child_event_id(l_creation_date);
		FETCH c_get_child_event_id INTO l_child_event_id;
		close c_get_child_event_id;
	end if;
	if l_child_event_id is not null
	then
        	HZ_EXTRACT_ORGANIZATION_BO_PVT.set_org_bo_action_type(p_event_id => l_child_event_id,
				p_root_id => p_root_id,
				px_org_obj =>PX_ORG_CUST_OBJ.ORGANIZATION_OBJ,
				x_return_status => x_return_status);
				l_child_upd_flag := 'Y';

	end if;


	open c1;
	loop
		fetch c1 into L_NODE_PATH, L_CHILD_OPERATION_FLAG,L_CHILD_BO_CODE,
			L_CHILD_ENTITY_NAME, L_CHILD_ID, l_populated_flag;
		exit when c1%NOTFOUND;


 	   if l_populated_flag = 'N'
	   then
		if L_CHILD_OPERATION_FLAG = 'I'
		then l_action_type := 'CREATED';
		elsif  L_CHILD_OPERATION_FLAG = 'U'
		then l_action_type := 'UPDATED';
		end if;

		-- check account  objects
	      if instr(l_node_path, 'ORG_CUST/CUST_ACCT') > 0
              then
		for i in 1..PX_ORG_CUST_OBJ.ACCOUNT_OBJS.COUNT
		loop
			set_org_acct_bo_action_type(p_node_path	=> l_node_path,
				    p_child_id => l_child_id,
				    p_action_type => l_action_type,
				    p_child_entity_name => l_child_entity_name,
				    px_cust_acct_obj => PX_ORG_CUST_OBJ.ACCOUNT_OBJS(i) );
				    l_child_upd_flag := 'Y';
		end loop;
	              end if;
	   end if; -- populated_flag = 'N'
	end loop;
	close c1;
	if  PX_ORG_CUST_OBJ.action_type =  'UNCHANGED'
			   and l_child_upd_flag = 'Y'
	then PX_ORG_CUST_OBJ.action_type := 'CHILD_UPDATED';
	end if;


EXCEPTION


    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;


WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

end set_org_cust_bo_action_type;

--------------------------------------
  --
  -- PROCEDURE get_org_cust_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organization customer update business event and organization id
  --the procedure returns one database object of the type HZ_ORG_CUST_BO
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --     p_org_cust_id        Organization customer identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_org_cust_obj       One updated logical organization.
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


 PROCEDURE get_org_cust_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_org_cust_id           IN           NUMBER,
    x_org_cust_obj         OUT NOCOPY    HZ_ORG_CUST_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
l_obj_root_ids HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL;
l_debug_prefix              VARCHAR2(30) := '';
l_org_cust_obj   HZ_ORG_CUST_BO;
begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_org_cust_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

/*   moved to public api
	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => p_org_cust_id,
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;
*/
	-- Set action type to 'UNCHANGED' by default

	get_org_cust_bo(
    		p_init_msg_list => fnd_api.g_false,
    		p_organization_id  => p_org_cust_id,
    		p_action_type => 'UNCHANGED',
    		x_org_cust_obj  => x_org_cust_obj,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);


	-- Based on BOT, for updated branch, set action_type = 'UPDATED'/'CREATED'


	l_org_cust_obj := x_org_cust_obj;
	set_org_cust_bo_action_type(p_event_id  => p_event_id,
				p_root_id     => p_org_cust_id,
				px_org_cust_obj => l_org_cust_obj,
				x_return_status => x_return_status
				);
	x_org_cust_obj := l_org_cust_obj;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_org_cust_updated (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_cust_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_cust_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_cust_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

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
  --   04-FEB-2008   vsegu                Created.
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

Organization			Y	N	get_organization_bo
Customer Account	Y	Y	get_cust_acct_bo	Called for each Customer Account object for the Organization Customer

*/



 PROCEDURE get_org_cust_v2_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_org_cust_v2_obj     OUT NOCOPY    HZ_ORG_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
l_debug_prefix              VARCHAR2(30) := '';

begin
		-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_org_cust_v2_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	x_org_cust_v2_obj := HZ_ORG_CUST_V2_BO(p_action_type, NULL, NULL);

	HZ_EXTRACT_ORGANIZATION_BO_PVT.get_organization_bo(
    		p_init_msg_list   => fnd_api.g_false,
    		p_organization_id => p_organization_id,
    		p_action_type	  => p_action_type,
    		x_organization_obj => x_org_cust_v2_obj.organization_obj,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	HZ_EXTRACT_CUST_ACCT_BO_PVT.get_cust_acct_v2_bos(
    		p_init_msg_list    => fnd_api.g_false,
    		p_parent_id        => p_organization_id,
    		p_cust_acct_id     => NULL,
    		p_action_type	   => p_action_type,
    		x_cust_acct_v2_objs   => x_org_cust_v2_obj.account_objs,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_org_cust_v2_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_cust_v2_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_cust_v2_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_org_cust_v2_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

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
  --   04-FEB-2008    vsegu                Created.
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
  ) is

l_obj_root_ids HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL;
l_debug_prefix              VARCHAR2(30) := '';
L_CHILD_OPERATION_FLAG varchar2(1);
l_action_type varchar2(30);

begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_v2_org_cust_created(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => l_obj_root_ids,
   	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

        l_child_operation_flag:= get_org_operation_type(p_event_id);

	if L_CHILD_OPERATION_FLAG = 'I'
	then
		l_action_type := 'CREATED';
	else
		l_action_type := 'UNCHANGED'; -- default to unchanged.
	end if;


  	-- call event API get_org_cust_updated for each id.

  	x_org_cust_v2_objs := HZ_ORG_CUST_V2_BO_TBL();


	for i in 1..l_obj_root_ids.count loop

		x_org_cust_v2_objs.extend;

		x_org_cust_v2_objs(i) := HZ_ORG_CUST_V2_BO('UNCHANGED', NULL, NULL);

		HZ_EXTRACT_ORGANIZATION_BO_PVT.get_organization_bo(
    		p_init_msg_list   => fnd_api.g_false,
    		p_organization_id => l_obj_root_ids(i),
    		p_action_type	  => l_action_type,
    		x_organization_obj => x_org_cust_v2_objs(i).organization_obj,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;

		if L_CHILD_OPERATION_FLAG = 'U'
		then
			HZ_EXTRACT_ORGANIZATION_BO_PVT.set_org_bo_action_type(p_event_id =>p_event_id,
				p_root_id => l_obj_root_ids(i),
				px_org_obj => x_org_cust_v2_objs(i).organization_obj,
				x_return_status => x_return_status);

		end if;

		HZ_EXTRACT_CUST_ACCT_BO_PVT.get_cust_acct_v2_bos(
    		p_init_msg_list    => fnd_api.g_false,
    		p_parent_id        => l_obj_root_ids(i),
    		p_cust_acct_id     => NULL,
    		p_action_type	   => 'CREATED',
    		x_cust_acct_v2_objs   => x_org_cust_v2_objs(i).account_objs,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;
		if L_CHILD_OPERATION_FLAG = 'I'
		then
			x_org_cust_v2_objs(i).action_type := 'CREATED';
		else
			x_org_cust_v2_objs(i).action_type := 'CHILD_UPDATED';
		end if;

  	end loop;

	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_v2_org_cust_created (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_v2_org_cust_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_v2_org_cust_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_v2_org_cust_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;



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
  --     x_org_cust_v2_objs   One or more updated logical org customer.
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
  --   04-FEB-2008     vsegu                Created.
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
  ) is

l_obj_root_ids HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL;
l_debug_prefix              VARCHAR2(30) := '';

begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_v2_org_custs_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => l_obj_root_ids,
   	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;



  	x_org_cust_v2_objs := HZ_ORG_CUST_V2_BO_TBL();

	for i in 1..l_obj_root_ids.count loop
		x_org_cust_v2_objs.extend;
		get_v2_org_cust_updated(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
    		p_org_cust_id  => l_obj_root_ids(i),
    		x_org_cust_v2_obj  => x_org_cust_v2_objs(i),
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

  	end loop;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_v2_org_custs_updated (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_v2_org_custs_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_v2_org_custs_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_v2_org_custs_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

procedure set_v2_org_acct_bo_action_type(p_node_path IN       VARCHAR2,
				    p_child_id  IN NUMBER,
				    p_action_type IN VARCHAR2,
				    p_child_entity_name IN VARCHAR2,
				    px_cust_acct_v2_obj IN OUT NOCOPY HZ_CUST_ACCT_V2_BO) is
l_child_upd_flag varchar2(1):='N';

begin

	-- check root level entities
	if p_child_entity_name  = 'HZ_CUST_ACCOUNTS'
	then
		if px_cust_acct_v2_obj.cust_acct_id = p_child_id
		then
			px_cust_acct_v2_obj.action_type := p_action_type;
		        l_child_upd_flag := 'N';
 		end if;
	end if;

	-- check first level objs


	if p_child_entity_name = 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V' then
		for i in 1..px_cust_acct_v2_obj.BANK_ACCT_USE_OBJS.COUNT
		loop
			if px_cust_acct_v2_obj.BANK_ACCT_USE_OBJS(i).BANK_ACCT_USE_ID = p_child_id
			then px_cust_acct_v2_obj.BANK_ACCT_USE_OBJS(i).action_type := p_action_type;
			     l_child_upd_flag := 'Y';
			end if;
		end loop;
	elsif p_child_entity_name = 'HZ_CUST_ACCT_RELATE_ALL' then
		for i in 1..px_cust_acct_v2_obj.ACCT_RELATE_OBJS.COUNT
		loop
			if px_cust_acct_v2_obj.ACCT_RELATE_OBJS(i).RELATED_CUST_ACCT_ID = p_child_id
			then px_cust_acct_v2_obj.ACCT_RELATE_OBJS(i).action_type := p_action_type;
			     l_child_upd_flag := 'Y';
			end if;
		end loop;
	elsif p_child_entity_name = 'RA_CUST_RECEIPT_METHODS' then
		for i in 1..px_cust_acct_v2_obj.PAYMENT_METHOD_OBJS.COUNT
		loop
		if px_cust_acct_v2_obj.PAYMENT_METHOD_OBJS(i).PAYMENT_METHOD_ID = p_child_id
		then px_cust_acct_v2_obj.PAYMENT_METHOD_OBJS(i).action_type := p_action_type;
	             l_child_upd_flag := 'Y';
		end if;
		end loop;
	end if;
	if px_cust_acct_v2_obj.action_type =  'UNCHANGED'  and l_child_upd_flag =  'Y'
	then
		px_cust_acct_v2_obj.action_type := 'CHILD_UPDATED';
	end if;


	-- check customer porfile obj
	if instr(p_node_path, 'ORG_CUST/CUST_ACCT/CUST_PROFILE') > 0
	then
		if p_child_entity_name = 'HZ_CUSTOMER_PROFILES'
		then
			if px_cust_acct_v2_obj.CUST_PROFILE_OBJ.CUST_ACCT_PROFILE_ID = p_child_id
			then
				px_cust_acct_v2_obj.CUST_PROFILE_OBJ.action_type := p_action_type;
		        	l_child_upd_flag := 'N';
			end if;
		end if;

		if p_child_entity_name = 'HZ_CUST_PROFILE_AMTS'
		then
			for i in 1..px_cust_acct_v2_obj.CUST_PROFILE_OBJ.CUST_PROFILE_AMT_OBJS.COUNT
			loop
				if px_cust_acct_v2_obj.CUST_PROFILE_OBJ.CUST_PROFILE_AMT_OBJS(i).CUST_ACCT_PROFILE_AMT_ID = p_child_id
				then px_cust_acct_v2_obj.CUST_PROFILE_OBJ.CUST_PROFILE_AMT_OBJS(i).action_type := p_action_type;
	     		             l_child_upd_flag := 'Y';
				end if;
			end loop;
		end if;

		if px_cust_acct_v2_obj.CUST_PROFILE_OBJ.action_type =  'UNCHANGED'  and l_child_upd_flag =  'Y'
		then
			px_cust_acct_v2_obj.CUST_PROFILE_OBJ.action_type := 'CHILD_UPDATED';
		end if;

	end if;

	-- check account contact obj

	if instr(p_node_path, 'ORG_CUST/CUST_ACCT/CUST_ACCT_CONTACT') > 0
	then
		for i in 1..px_cust_acct_v2_obj.CUST_ACCT_CONTACT_OBJS.COUNT
		loop
			if p_child_entity_name = 'HZ_CUST_ACCOUNT_ROLES'
			then
			   if px_cust_acct_v2_obj.CUST_ACCT_CONTACT_OBJS(i).CUST_ACCT_CONTACT_ID = p_child_id
		           then
				px_cust_acct_v2_obj.CUST_ACCT_CONTACT_OBJS(i).action_type :=  p_action_type;
				l_child_upd_flag := 'N';
			   end if;
			end if;


			if p_child_entity_name = 'HZ_ROLE_RESPONSIBILITY'
			then
				for j in 1..px_cust_acct_v2_obj.CUST_ACCT_CONTACT_OBJS(i).CONTACT_ROLE_OBJS.COUNT
				loop
					if px_cust_acct_v2_obj.CUST_ACCT_CONTACT_OBJS(i).CONTACT_ROLE_OBJS(j).RESPONSIBILITY_ID = p_child_id
					then px_cust_acct_v2_obj.CUST_ACCT_CONTACT_OBJS(i).CONTACT_ROLE_OBJS(j).action_type := p_action_type;
	     		                     l_child_upd_flag := 'Y';
					end if;
				end loop;
			end if;
			if  px_cust_acct_v2_obj.CUST_ACCT_CONTACT_OBJS(i).action_type =  'UNCHANGED'
			    and l_child_upd_flag = 'Y'
			then px_cust_acct_v2_obj.CUST_ACCT_CONTACT_OBJS(i).action_type := 'CHILD_UPDATED';
			end if;
		end loop;

	end if;

	-- check account site obj

	if instr(p_node_path, 'ORG_CUST/CUST_ACCT/CUST_ACCT_SITE') > 0
	then
		for i in 1..px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS.COUNT
		loop
			if p_child_entity_name = 'HZ_CUST_ACCT_SITES_ALL'
			then
			   if px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).cust_acct_site_id = p_child_id
		           then
				px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).action_type := p_action_type;
				l_child_upd_flag := 'N';
			   end if;
			end if;

			for j in 1..px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS.COUNT
			loop
				if p_child_entity_name = 'HZ_CUST_SITE_USES_ALL'
				then

					if px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).SITE_USE_ID = p_child_id
					then px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).action_type := p_action_type;
					     l_child_upd_flag := 'Y';
					end if;
				end if;

				if p_child_entity_name = 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V' then
					for k in 1..px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).BANK_ACCT_USE_OBJS.COUNT
					loop
						if px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).BANK_ACCT_USE_OBJS(k).BANK_ACCT_USE_ID = p_child_id
						then px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).BANK_ACCT_USE_OBJS(k).action_type := p_action_type;
					            l_child_upd_flag := 'Y';
						end if;
					end loop;
				elsif p_child_entity_name = 'RA_CUST_RECEIPT_METHODS' then
					for k in 1..px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).PAYMENT_METHOD_OBJS.COUNT
					loop
					if px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).PAYMENT_METHOD_OBJS(k).PAYMENT_METHOD_ID = p_child_id
					then px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).PAYMENT_METHOD_OBJS(k).action_type := p_action_type;
					     l_child_upd_flag := 'Y';
					end if;
					end loop;

				elsif p_child_entity_name = 'HZ_CUSTOMER_PROFILES' then

					if px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).SITE_USE_PROFILE_OBJ.CUST_ACCT_PROFILE_ID = p_child_id
					then px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_SITE_USE_OBJS(j).SITE_USE_PROFILE_OBJ.action_type := p_action_type;
					     l_child_upd_flag := 'Y';
					end if;

				end if;

			end loop; -- CUST_ACCT_SITE_USE_OBJS.COUNT

			for j in 1..px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS.COUNT
			loop

				if p_child_entity_name = 'HZ_CUST_ACCOUNT_ROLES'
				then
				   if px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j).CUST_ACCT_CONTACT_ID = p_child_id
				   then
					px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j).action_type := p_action_type;
					l_child_upd_flag := 'N';
				   end if;
				end if;


				if p_child_entity_name = 'HZ_ROLE_RESPONSIBILITY'
				then
					for k in 1..px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j). CONTACT_ROLE_OBJS.COUNT
					loop
						if px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j).CONTACT_ROLE_OBJS(k).RESPONSIBILITY_ID = p_child_id
						then px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j).CONTACT_ROLE_OBJS(k).action_type := p_action_type;
					             l_child_upd_flag := 'Y';
						end if;
					end loop;
				end if;
			if  px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j).action_type =  'UNCHANGED'
			    and l_child_upd_flag = 'Y'
			then px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).CUST_ACCT_CONTACT_OBJS(j).action_type := 'CHILD_UPDATED';
			end if;
			end loop; -- CUST_ACCT_CONTACT_OBJS.COUNT
		if  px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).action_type =  'UNCHANGED'
			           and l_child_upd_flag = 'Y'
		then px_cust_acct_v2_obj.CUST_ACCT_SITE_OBJS(i).action_type := 'CHILD_UPDATED';
		end if;

		if  px_cust_acct_v2_obj.action_type =  'UNCHANGED' and l_child_upd_flag = 'Y'
		then px_cust_acct_v2_obj.action_type := 'CHILD_UPDATED';
		end if;

        end loop; -- acct site obj
    end if;

end set_v2_org_acct_bo_action_type;

procedure set_v2_org_cust_bo_action_type(p_event_id		  IN           	NUMBER,
				    p_root_id  IN NUMBER,
				    px_org_cust_v2_obj IN OUT NOCOPY HZ_ORG_CUST_V2_BO,
				    x_return_status       OUT NOCOPY    VARCHAR2) is

	cursor c1 is

	   SELECT
  		sys_connect_by_path(CHILD_BO_CODE, '/') node_path,
  		CHILD_OPERATION_FLAG,
  		CHILD_BO_CODE,
  		CHILD_ENTITY_NAME,
  		CHILD_ID,
  		populated_flag
	 FROM HZ_BUS_OBJ_TRACKING
         where event_id = p_event_id
	 START WITH child_id = p_root_id
   		AND child_entity_name = 'HZ_PARTIES'
   		AND  PARENT_BO_CODE IS NULL
   		AND event_id = p_event_id
   		AND CHILD_BO_CODE = 'ORG_CUST' --(or ORG, PERSON_CUST, ORG_CUST).
	CONNECT BY PARENT_ENTITY_NAME = PRIOR CHILD_ENTITY_NAME
    	AND PARENT_ID = PRIOR CHILD_ID
    	AND parent_bo_code = PRIOR child_bo_code
	and event_id = PRIOR event_id;

	cursor  c2 is
    	   select child_event_id,creation_date
	    FROM HZ_BUS_OBJ_TRACKING
	    where event_id = p_event_id
	    and parent_bo_code is null
	    and rownum = 1;

	CURSOR c_get_child_event_id(cp_creation_date DATE) IS

		SELECT event_id
    		FROM HZ_BUS_OBJ_TRACKING
    		WHERE creation_date = cp_creation_date
    		AND child_id = p_root_id
    		AND child_event_id IS NULL
    		and event_id <> p_event_id
		and rownum = 1;

L_CHILD_OPERATION_FLAG VARCHAR2(1);
L_CHILD_BO_CODE VARCHAR2(30);
L_CHILD_ENTITY_NAME  VARCHAR2(30);
L_CHILD_ID NUMBER;
l_action_type varchar2(30);
l_node_path varchar2(2000);
l_populated_flag varchar2(1);
l_child_upd_flag varchar2(1);
l_child_event_id number;
l_creation_date date;

begin
	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

	open c2;
        fetch c2 into l_child_event_id, l_creation_date;
	close c2;

	if l_child_event_id is null
	then
		OPEN c_get_child_event_id(l_creation_date);
		FETCH c_get_child_event_id INTO l_child_event_id;
		close c_get_child_event_id;
	end if;
	if l_child_event_id is not null
	then
        	HZ_EXTRACT_ORGANIZATION_BO_PVT.set_org_bo_action_type(p_event_id => l_child_event_id,
				p_root_id => p_root_id,
				px_org_obj =>PX_ORG_CUST_V2_OBJ.ORGANIZATION_OBJ,
				x_return_status => x_return_status);
				l_child_upd_flag := 'Y';

	end if;


	open c1;
	loop
		fetch c1 into L_NODE_PATH, L_CHILD_OPERATION_FLAG,L_CHILD_BO_CODE,
			L_CHILD_ENTITY_NAME, L_CHILD_ID, l_populated_flag;
		exit when c1%NOTFOUND;


 	   if l_populated_flag = 'N'
	   then
		if L_CHILD_OPERATION_FLAG = 'I'
		then l_action_type := 'CREATED';
		elsif  L_CHILD_OPERATION_FLAG = 'U'
		then l_action_type := 'UPDATED';
		end if;

		-- check account  objects
	      if instr(l_node_path, 'ORG_CUST/CUST_ACCT') > 0
              then
		for i in 1..PX_ORG_CUST_V2_OBJ.ACCOUNT_OBJS.COUNT
		loop
			set_v2_org_acct_bo_action_type(p_node_path	=> l_node_path,
				    p_child_id => l_child_id,
				    p_action_type => l_action_type,
				    p_child_entity_name => l_child_entity_name,
				    px_cust_acct_v2_obj => PX_ORG_CUST_V2_OBJ.ACCOUNT_OBJS(i) );
				    l_child_upd_flag := 'Y';
		end loop;
	              end if;
	   end if; -- populated_flag = 'N'
	end loop;
	close c1;
	if  PX_ORG_CUST_V2_OBJ.action_type =  'UNCHANGED'
			   and l_child_upd_flag = 'Y'
	then PX_ORG_CUST_V2_OBJ.action_type := 'CHILD_UPDATED';
	end if;


EXCEPTION


    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;


WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

end set_v2_org_cust_bo_action_type;

--------------------------------------
  --
  -- PROCEDURE get_v2_org_cust_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organization customer update business event and organization id
  --the procedure returns one database object of the type HZ_ORG_CUST_V2_BO
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --     p_org_cust_id        Organization customer identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_org_cust_v2_obj       One updated logical organization.
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
  --   06-JUN-2005     vsegu                Created.
  --


 PROCEDURE get_v2_org_cust_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_org_cust_id           IN           NUMBER,
    x_org_cust_v2_obj         OUT NOCOPY    HZ_ORG_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
l_obj_root_ids HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL;
l_debug_prefix              VARCHAR2(30) := '';
l_org_cust_obj   HZ_ORG_CUST_V2_BO;
begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_v2_org_cust_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	-- Set action type to 'UNCHANGED' by default

	get_org_cust_v2_bo(
    		p_init_msg_list => fnd_api.g_false,
    		p_organization_id  => p_org_cust_id,
    		p_action_type => 'UNCHANGED',
    		x_org_cust_v2_obj  => x_org_cust_v2_obj,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);


	-- Based on BOT, for updated branch, set action_type = 'UPDATED'/'CREATED'


	l_org_cust_obj := x_org_cust_v2_obj;
	set_v2_org_cust_bo_action_type(p_event_id  => p_event_id,
				p_root_id     => p_org_cust_id,
				px_org_cust_v2_obj => l_org_cust_obj,
				x_return_status => x_return_status
				);
	x_org_cust_v2_obj := l_org_cust_obj;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_v2_org_cust_updated (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_v2_org_cust_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_v2_org_cust_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_v2_org_cust_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

END HZ_EXTRACT_ORG_CUST_BO_PVT;

/
