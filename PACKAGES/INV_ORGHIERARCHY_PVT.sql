--------------------------------------------------------
--  DDL for Package INV_ORGHIERARCHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ORGHIERARCHY_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVORGS.pls 115.20 2004/04/15 13:11:32 nesoni ship $ */
--+=======================================================================+
--|               Copyright (c) 2001 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVVORGS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec of INV_ORGHIERARCHY_PVT                                       |
--|                                                                       |
--| HISTORY                                                               |
--|     08/28/00 vjavli          Created                                  |
--|     10/29/00 vjavli          updated with Org_Hier_Level_Resp_Access  |
--|     11/01/00 vjavli          updated with parameter business group for|
--|                              the Org_Hier_Level_Resp_Access           |
--|     11/13/00 vjavli          The function Org_Hier_Level_Resp_Access  |
--|                              modified. removed resp_appl_id parameter |
--|     12/11/00 vjavli          removed overloading                      |
--|     05/22/01 vjavli          created api:Org_exists_in_hierarchy      |
--|                              for valid query in the forms             |
--|     11/14/01 vjavli          Created Org_Hier_Origin_Resp_Access      |
--|                              This function is a performance           |
--|                              enhancement of the previous function     |
--|                              Org_Hier_Level_Resp_Access               |
--|     12/11/01 vjavli          insert_hierarchy_index_list created      |
--|     05/03/02 vjavli          dbdrv hint added for the version:115.15  |
--|                              version:115.16 has an issue since this   |
--|                              file got updated with dbdrv hint for the |
--|                              earlier version of the file which does   |
--|                              not contain the performance apis         |
--|     11/22/2002 vma           Added NOCOPY to OUT parameters           |
--|     04/12/2004 nesoni        Bug 3555234. Introduced another log level|
--|                              G_LOG_PRINT which will be printed always |
--|                              irrespective of FND Debug mode.          |
--+======================================================================*/


--===================
-- CONSTANTS
--===================
/* Following debug level G_LOG_PRINT has been added to print summary report
irrespective of FND Debug Enabled profile option. Bug 3555234.
*/
G_LOG_PRINT                   CONSTANT NUMBER := 6;

G_LOG_ERROR                   CONSTANT NUMBER := 5;
G_LOG_EXCEPTION               CONSTANT NUMBER := 4;
G_LOG_EVENT                   CONSTANT NUMBER := 3;
G_LOG_PROCEDURE               CONSTANT NUMBER := 2;
G_LOG_STATEMENT               CONSTANT NUMBER := 1;

--===================
-- GLOBAL VARIABLES
--===================
-- Table type used to hold organization codes
   TYPE OrgID_tbl_type IS TABLE OF hr_all_organization_units.organization_id%TYPE
   INDEX BY BINARY_INTEGER;

-- list to store the index organization list
-- where organization_id is the index of the table
   g_orgid_index_list INV_ORGHIERARCHY_PVT.orgID_tbl_type;
--
--=========================
-- PROCEDURES AND FUNCTIONS
--=========================


--========================================================================
-- FUNCTION  : validate_property  PUBLIC
-- PARAMETERS: p_org_id_tbl       This is a list of organization ids,
--                                typically obtained from a call to
--                                get_organization_list
--             p_property         Returns 'Y' if the property applies to
--                                the list of organizations
--                                p_property can be one of:
--                                'MASTER'
--                                'CALENDAR'
--                                'CHART_OF_ACCOUNTS'
--=========================================================================

FUNCTION validate_property
( p_org_id_tbl   IN   OrgID_Tbl_Type
, p_property     IN   VARCHAR2
)
RETURN VARCHAR2;



--========================================================================
-- FUNCTION  : get_organization_list   PUBLIC
-- PARAMETERS: p_hierarchy_id          IN  NUMBER
--                                           Organization Hierarchy Id
--             p_origin_org_id         IN  NUMBER
--                                           Hierarchy Origin Organization Id
--             org_id_tbl              OUT NOCOPY OrgID_Tbl_Type
--                                           List of Organization Ids
--             p_include_origin        IN  VARCHAR  DEFAULT 'Y'
--                                           Include the origin in list
--
-- COMMENT   : returns a list containing all organizations from the hierarchy
--             below the origin organization to which the user
--             has access.
--             p_include_origin flag determines whether the origin org id is part
--             of the list or not.
--             Both Inventory Organization Security and HR Security Group
--             are enforced, as well as effective date ranges.
--             This api does not return the organizations in the list in any
--             particular order. The order may change between revisions.
--             origin_id:
--=========================================================================

PROCEDURE get_organization_list
( p_hierarchy_id       IN     NUMBER
, p_origin_org_id      IN     NUMBER
, x_org_id_tbl         OUT    NOCOPY OrgID_Tbl_Type
, p_include_origin     IN     VARCHAR2  DEFAULT 'Y'
);



--========================================================================
-- FUNCTION  : contained_in_hierarchy  PUBLIC
-- PARAMETERS: p_org_hierarchy_name    IN VARCHAR2     Organization Hierarchy
--                                                     Name
--             p_org_id                IN NUMBER       Organization Id
--
-- COMMENT   : Returns 'Y' if p_org_id is contained in the current version of
--             the named organization hierarchy
--=========================================================================
FUNCTION contained_in_hierarchy
( p_org_hierarchy_name  IN  VARCHAR2
, p_org_id              IN  NUMBER
)
RETURN VARCHAR2;



--========================================================================
-- FUNCTION  : Org_Hierarchy_Access    PUBLIC
-- PARAMETERS: p_org_hierarchy_name    IN VARCHAR2(30) Organization Hierarchy
--                                                     Name
--
-- COMMENT   : This API accepts the name of an hierarchy and returns Y if the
--             user has access to it, N Otherwise  The API checks whether the
--             user has an access or authorization for the organization
--             hierarchy based on the fact that atleast one of the organization
--             in the organization hierarchy belongs to the security profile
--             which has been assigned thru the responsibility to the user.
--=========================================================================
FUNCTION Org_Hierarchy_Access
(	p_org_hierarchy_name IN	VARCHAR2 ) RETURN VARCHAR2;



--========================================================================
-- FUNCTION  : Org_Hierarchy_Level_Access    PUBLIC
-- PARAMETERS: p_org_hierarchy_name    IN VARCHAR2(30) Organization Hierarchy
--                                                     Name
--             p_org_hier_level_id     IN NUMBER  Organization Hierarchy
--                                                Level Id
--
-- COMMENT   : This API accepts the name of an hierarchy, hierarchy level
--             Id and returns Y if the user has access to it N otherwise
--=========================================================================
FUNCTION ORG_HIERARCHY_LEVEL_ACCESS
(	p_org_hierarchy_name    IN  VARCHAR2,
	p_org_hier_level_id     IN  NUMBER ) RETURN VARCHAR2;



--========================================================================
-- PROCEDURE : Org_Hierarchy_List      PUBLIC
-- PARAMETERS: p_org_hierarchy_name    IN VARCHAR2(30) Organization Hierarchy
--                                                     Name
--             p_org_hier_level_id     IN NUMBER  Hierarchy Level Id
--             x_org_code_list         List of Organizations
--
-- COMMENT   : API accepts the name of an hierarchy, hierarchy level id and
--             returns the list of organizations it contains.
--             p_org_hierarchy_name contains user input organization hierarchy
--             name
--             p_org_hier_level_id contains user input hierarchy level
--             organization id in the hierarchy
--             x_org_code_list contains list of organizations for a given org
--             hierarchy level
--=========================================================================
PROCEDURE Org_Hierarchy_List
( p_org_hierarchy_name IN  VARCHAR2,
  p_org_hier_level_id  IN  NUMBER,
  x_org_code_list      OUT NOCOPY OrgID_tbl_type);



--========================================================================
-- FUNCTION  : Org_Hier_Level_Property_Access    PUBLIC
-- PARAMETERS: p_org_hierarchy_name  IN VARCHAR2(30) Organization Hierarchy
--                                                   Name
--             p_org_hier_level_id   IN NUMBER Hierarchy Level Id
--
--             p_property_type       IN VARCHAR2(25) Property Type
--
-- COMMENT   : API accepts the name of an hierarchy, hierarchy level id,
--             property and returns Y if the property is satisfied,
--             N otherwise.
--             The supported properties are:
--             MASTER: all the organizations share the same item master
--	         CALENDAR: all the organizations share the same calendar
--             CHART_OF_ACCOUNTS: all the organizations share the same chart of
--             accounts
--=========================================================================
FUNCTION Org_Hier_Level_Property_Access
( p_org_hierarchy_name IN VARCHAR2,
	p_org_hier_level_id  IN NUMBER,
	p_property_type      IN	VARCHAR2 ) RETURN VARCHAR2 ;



--========================================================================
-- FUNCTION  : Org_Hier_Level_Resp_Access    PUBLIC
-- PARAMETERS: p_api_version_number    known api version
--             p_org_id                  IN NUMBER Hierarchy Level Id
--                                           (Organization Id)
--             p_business_id             IN NUMBER Business Group Id
--             p_responsibility_id       IN NUMBER Current Responsibility
--                                          Id
-- COMMENT   : API accepts the Organization Id of an organization
--             hierarchy level(organization name), business group,current
--             responsibility user has signed on and returns Y if the
--             organization is valid(unexpired) and has an access for the
--             responsibility, N otherwise.
--=========================================================================
FUNCTION Org_Hier_Level_Resp_Access
(     p_org_id                   IN   NUMBER,
      p_business_group_id        IN   NUMBER,
      p_responsibility_id        IN   NUMBER )  RETURN VARCHAR2;



--========================================================================
-- FUNCTION  : Org_Hier_Origin_Resp_Access    PUBLIC
-- PARAMETERS: p_api_version_number    known api version
--             p_org_id                  IN NUMBER Hierarchy Level Id
--                                           (Organization Id)
--             p_responsibility_id       IN NUMBER Current Responsibility
--                                          Id
-- COMMENT   : API accepts the Organization Id of an
--             hierarchy origin(organization name), current
--             responsibility user has signed on and returns Y if the
--             organization is valid(unexpired) and has an access for the
--             responsibility, N otherwise.
--=========================================================================
FUNCTION Org_Hier_Origin_Resp_Access
(     p_org_id                   IN   NUMBER,
      p_responsibility_id        IN   NUMBER )  RETURN VARCHAR2;



--========================================================================
-- FUNCTION  : Org_exists_in_hierarchy PUBLIC
-- PARAMETERS: p_organization_id       IN NUMBER  Inventory Organization Id
-- COMMENT   : This API accepts the organization id, name of an hierarchy,
--             hierarchy origin id and returns Y if the organization id exists
--             in the given hierarchy and origin
--=========================================================================
FUNCTION Org_exists_in_hierarchy
( p_organization_id             IN  NUMBER) RETURN VARCHAR2;



--========================================================================
-- PROCEDURE : Insert_hierarchy_index_list PUBLIC
-- PARAMETERS: p_orgid_tbl_list  IN orgID_tbl_type Orgid list of an
--                                                  hierarchy
-- COMMENT   : This API copies the organization list into the global
--             variable organization id index list.  The table index is
--             the organization_id
--             This api is used in the form: Transaction Open Interface

--========================================================================
PROCEDURE Insert_hierarchy_index_list
 ( p_orgid_tbl_list   IN orgID_tbl_type);



--========================================================================
-- PROCEDURE : Log_Initialize             PUBLIC
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--========================================================================
PROCEDURE Log_Initialize;



--========================================================================
-- PROCEDURE : Log                        PUBLIC
-- PARAMETERS: p_level                IN  priority of the message - from
--                                        highest to lowest:
--                                          -- G_LOG_ERROR
--                                          -- G_LOG_EXCEPTION
--                                          -- G_LOG_EVENT
--                                          -- G_LOG_PROCEDURE
--                                          -- G_LOG_STATEMENT
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--=======================================================================
PROCEDURE Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
);


END INV_ORGHIERARCHY_PVT;

 

/
