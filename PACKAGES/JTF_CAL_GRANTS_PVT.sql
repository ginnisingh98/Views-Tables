--------------------------------------------------------
--  DDL for Package JTF_CAL_GRANTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CAL_GRANTS_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvcgts.pls 115.5 2002/11/14 22:16:27 jawang ship $ */

/*******************************************************************************
** Record type that holds a resource's GranteeKey, GrantType and Access Level
*******************************************************************************/
TYPE Grantee IS RECORD
( GranteeKey	     fnd_grants.grantee_key%TYPE  /*JTF_RESOURCE resource ID or Username of the logged on user */
 ,GrantType          NUMBER NOT NULL :=1  /* Grant Type, 1 for Insert */
 ,AccessLevel        VARCHAR2(30)
);

/*******************************************************************************
** PL/SQL table TYPE definition for resource lists
*******************************************************************************/
TYPE GranteeTbl IS TABLE OF Grantee INDEX BY BINARY_INTEGER;

CALENDAR_OBJECT         CONSTANT VARCHAR2(30) := 'JTF_TASK_RESOURCE';
CALENDAR_READ_ROLE      CONSTANT VARCHAR2(30) := 'JTF_CAL_READ_ACCESS';
CALENDAR_FULL_ROLE      CONSTANT VARCHAR2(30) := 'JTF_CAL_FULL_ACCESS';
CALENDAR_READ_PRIVILEGE CONSTANT VARCHAR2(30) := 'JTF_CAL_READ_ACCESS';
CALENDAR_FULL_PRIVILEGE CONSTANT VARCHAR2(30) := 'JTF_CAL_FULL_ACCESS';
CALENDAR_INSTANCE_TYPE  CONSTANT VARCHAR2(30) := 'INSTANCE';
CALENDAR_RESOURCE_TYPE  CONSTANT VARCHAR2(30) := 'RS_EMPLOYEE';
GRANTEE_TYPE            CONSTANT VARCHAR2(30) := 'USER';
PROGRAM_NAME            CONSTANT VARCHAR2(30) := 'CALENDAR';
PROGRAM_TAG             CONSTANT VARCHAR2(30) := 'ACCESS LEVEL';

TASK_INSTANCE_TYPE  CONSTANT VARCHAR2(30) := 'SET';

PROCEDURE UpdateGrants
/*******************************************************************************
** Given:
** - the Granter
** - a list of Read Only Grantees
** - a list of Full Access Grantees
** This API will make sure that the proper grants are create/deleted
*******************************************************************************/
( p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit                 IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level       IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status          OUT 	  NOCOPY   VARCHAR2
, x_msg_count              OUT    NOCOPY   NUMBER
, x_msg_data               OUT    NOCOPY   VARCHAR2
, p_GranterID              IN     VARCHAR2
, p_ReadAccess             IN     VARCHAR2
, p_FullAccess             IN     VARCHAR2
);

PROCEDURE RevokeGrants
/*******************************************************************************
** Given:
** - the resource Id
** - the group calendar Id
** This API will revoke the grant to the given group calendar
   for the given resource Id
********************************************************************************/
(
  p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit                 IN     VARCHAR2 DEFAULT fnd_api.g_false
, x_return_status          OUT    NOCOPY   VARCHAR2
, x_msg_count              OUT    NOCOPY   NUMBER
, x_msg_data               OUT    NOCOPY   VARCHAR2
, p_resourceId             IN     VARCHAR2
, p_groupId                IN     VARCHAR2
);

PROCEDURE InvokeGrants
/*******************************************************************************
** Given:
** - the resource Id
** - the group calendar Id
** This API will grant the Administrator Priv. to the given group calendar
   for the given resource Id
********************************************************************************/
(
  p_api_version            IN     NUMBER
, p_init_msg_list          IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit                 IN     VARCHAR2 DEFAULT fnd_api.g_false
, x_return_status          OUT    NOCOPY   VARCHAR2
, x_msg_count              OUT    NOCOPY   NUMBER
, x_msg_data               OUT    NOCOPY   VARCHAR2
, p_resourceId             IN     VARCHAR2
, p_groupId                IN     VARCHAR2
, p_accesslevel            In     VARCHAR2
);

FUNCTION get_grant_guid
/*****************************************************************************
** Given:
** - the resource Id
** - the group calendar Id
** This API return the grant_guid for the given resource Id
   and the group calenar Id
******************************************************************************/
( p_resourceId             IN     VARCHAR2
, p_groupId                IN     VARCHAR2
) RETURN RAW;

FUNCTION has_access_level
/*****************************************************************************
** Given:
** - the resource Id
** - the group calendar Id
** This API returns the boolean value whether the given resource Id already has
** an access level for the given group Id
******************************************************************************/
( p_resourceId              IN     VARCHAR2
, p_groupId                 IN     VARCHAR2
) RETURN BOOLEAN;

END JTF_CAL_GRANTS_PVT;

 

/
