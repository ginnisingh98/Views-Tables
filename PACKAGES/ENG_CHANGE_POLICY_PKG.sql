--------------------------------------------------------
--  DDL for Package ENG_CHANGE_POLICY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_POLICY_PKG" AUTHID CURRENT_USER AS
/* $Header: ENGUCHPS.pls 120.1 2005/06/13 01:03:02 appldev  $ */

PROCEDURE GetChangePolicy
(   p_policy_object_name         IN  VARCHAR2
 ,  p_policy_code                IN  VARCHAR2
 ,  p_policy_pk1_value           IN  VARCHAR2
 ,  p_policy_pk2_value           IN  VARCHAR2
 ,  p_policy_pk3_value           IN  VARCHAR2
 ,  p_policy_pk4_value           IN  VARCHAR2
 ,  p_policy_pk5_value           IN  VARCHAR2
 ,  p_attribute_object_name      IN  VARCHAR2
 ,  p_attribute_code             IN  VARCHAR2
 ,  p_attribute_value            IN  VARCHAR2
 ,  x_policy_value               OUT NOCOPY VARCHAR2
);

-- Start of comments
--      API name        : GET_OPATTR_CHANGEPOLICY
--      Type            : Public
--      Pre-reqs        : None.
--      Function        : Gets the strict-most policy from the comma-delimited
--                        list of operational attribute group ids.
--      Parameters      :
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_catalog_category_id	        IN VARCHAR2     Required
--				p_item_lifecycle_id	        IN VARCHAR2     Required
--				p_lifecycle_phase_id	        IN VARCHAR2     Required
--				p_attribute_grp_ids	        IN VARCHAR2     Required
--	OUT		:	x_return_status		        OUT VARCHAR2(1)
--				x_policy_value                  OUT VARCHAR2(30)
--	Version	: Current version	1.0
--			  Initial version 	1.0
--
--	Notes		: This API is to be called ONLY to get the policies of
--                        operational attribute groups.
--
-- End of comments
PROCEDURE GET_OPATTR_CHANGEPOLICY
(   p_api_version                IN NUMBER
 ,  x_return_status	         OUT NOCOPY VARCHAR2
 ,  p_catalog_category_id        IN  VARCHAR2
 ,  p_item_lifecycle_id          IN  VARCHAR2
 ,  p_lifecycle_phase_id         IN  VARCHAR2
 ,  p_attribute_grp_ids          IN  VARCHAR2
 ,  x_policy_value               OUT NOCOPY VARCHAR2
);

END ENG_CHANGE_POLICY_PKG ;

 

/
