--------------------------------------------------------
--  DDL for Package AS_SALES_ORG_MANAGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_ORG_MANAGER_PVT" AUTHID CURRENT_USER as
/* $Header: asxvsoms.pls 115.7 2002/12/16 05:31:23 nkamble ship $ */

-- Start of Comments
--
-- NAME
--   AS_SALES_ORG_MANAGER_PVT
--
-- PURPOSE
--   This package is a private API for generic commodity api's that is used
--     across OSM.
--
--   Procedures:
--   Get_Sales_groups
--   Get_Salesreps
--   Get_CurrentUser
--

--
-- HISTORY
--   7/31/98        ALHUNG            created
--
-- End of Comments

G_NO_RELATION		CONSTANT NUMBER := 0;
G_FIRSTLINE_MANAGER	CONSTANT NUMBER := 1;
G_HIGHER_MANAGER	CONSTANT NUMBER := 2;
G_IDENTICAL_SALESFORCE	CONSTANT NUMBER := 3;
G_SALESREP		CONSTANT NUMBER := 4;

-- Start of Comments
--
--    API name    : Get_Sales_groups
--    Type        : Private
--    Function    : Return record the sales groups given criteria
--
--    Pre-reqs    : None
--    Paramaeters    :
--    IN        :
--            p_api_version_number                IN NUMBER                    Required
--            p_identity_salesforce_id            IN NUMBER                    Optional
--                Default = NULL
--            p_init_msg_list                     IN VARCHAR2                  Optional
--                Default = FND_API.G_FALSE
--            p_sales_group_rec                   IN AS_SALES_GROUP_PUB.SALES_GROUP_REC_TYPE
--
--    OUT        :
--            x_return_status                     OUT    VARCHAR2(1)
--            x_msg_count                         OUT    NUMBER
--            x_msg_data                          OUT    VARCHAR2(2000)
--            x_sales_group_tbl                   OUT    AS_SALES_GROUP_PUB.SALES_GROUP_TBL_TYPE
--
--    Version    :    Current version    1.0
--                    Initial version    1.0
--
--
--
--    Business Rules:
--
--    Notes:
--    1. Criteria considered: sales_group_id, sales_group_name

PROCEDURE Get_Sales_groups
(   p_api_version_number                   IN     NUMBER,
    p_init_msg_list                        IN     VARCHAR2
                                := FND_API.G_FALSE,
    p_SALES_GROUP_rec                      IN     AS_SALES_GROUP_PUB.SALES_GROUP_rec_Type,

    x_return_status                        OUT NOCOPY    VARCHAR2,
    x_msg_count                            OUT NOCOPY    NUMBER,
    x_msg_data                             OUT NOCOPY    VARCHAR2,
    x_SALES_GROUP_tbl                      OUT NOCOPY    AS_SALES_GROUP_PUB.SALES_GROUP_tbl_Type );

-- Start of Comments
--
--    API name    : Get_CurrentUser
--    Type        : Private
--    Function    : Return salesforce_id of the person who is currently
--                  using the system
--
--    Pre-reqs    : None
--    Paramaeters    :
--    IN        :
--            p_api_version_number                IN NUMBER                    Required
--            p_identity_salesforce_id            IN NUMBER                    Optional
--                Default = NULL
--            p_init_msg_list                     IN VARCHAR2                  Optional
--                Default = FND_API.G_FALSE
--
--    OUT        :
--            x_return_status                     OUT    VARCHAR2(1)
--            x_msg_count                         OUT    NUMBER
--            x_msg_data                          OUT    VARCHAR2(2000)
--            x_salesforce_id                     OUT    NUMBER
--
--    Version    :    Current version    1.0
--                    Initial version    1.0
--
--
--
--    Business Rules: 1. This procedure first use FND_Global.User_Id to identify the user.
--                    If this is not possible, it uses the passed in parameter.
--
--    Notes: 1. Currently, if a user_id happens to map to >1 employee, the first one found
--           is used.

PROCEDURE Get_CurrentUser
(   p_api_version_number                   IN     NUMBER,
    p_init_msg_list                        IN     VARCHAR2
                                := FND_API.G_FALSE,
    p_salesforce_id                        IN     NUMBER,
    p_admin_group_id                        IN    NUMBER,
    x_return_status                        OUT NOCOPY    VARCHAR2,
    x_msg_count                            OUT NOCOPY    NUMBER,
    x_msg_data                             OUT NOCOPY    VARCHAR2,
    x_sales_member_rec                     OUT NOCOPY    AS_SALES_MEMBER_PUB.Sales_member_rec_Type );


-- Start of Comments
--
--    API name    : Get_Salesreps
--    Type        : Private
--    Function    : Return record the person given criteria
--
--    Pre-reqs    : None
--    Paramaeters    :
--    IN        :
--            p_api_version_number                IN NUMBER                    Required
--            p_identity_salesforce_id            IN NUMBER                    Optional
--                Default = NULL
--            p_init_msg_list                     IN VARCHAR2                  Optional
--                Default = FND_API.G_FALSE
--
--    OUT        :
--            x_return_status                     OUT    VARCHAR2(1)
--            x_msg_count                         OUT    NUMBER
--            x_msg_data                          OUT    VARCHAR2(2000)
--            x_salesforce_id                     OUT    NUMBER
--
--    Version    :    Current version    1.0
--                    Initial version    1.0
--
--
--
--    Business Rules:
--
--    Available Criteria: Salesforce_id, Type, Employee_Person_Id, Salesgroup_id
--                        Partner_Address_Id, Partner_Customer_id, Last_name
--                        First_name, Email_Address
--    Notes:
--    1. When using Type as a criteria, supply one of the global variables:
--       G_EMPLOYEE_SALES_MEMBER, G_PARTNER_SALES_MEMBER, G_OTHER_SALES_MEMBER
--       defined in AS_SALES_MEMBER_PUB
--
--
--

PROCEDURE Get_Sales_members
(   p_api_version_number                   IN     NUMBER,
    p_init_msg_list                        IN     VARCHAR2
                                := FND_API.G_FALSE,
    p_sales_member_rec                     IN     AS_SALES_MEMBER_PUB.Sales_member_rec_Type,

    x_return_status                        OUT NOCOPY    VARCHAR2,
    x_msg_count                            OUT NOCOPY    NUMBER,
    x_msg_data                             OUT NOCOPY    VARCHAR2,
    x_sales_member_tbl                     OUT NOCOPY    AS_SALES_MEMBER_PUB.Sales_member_tbl_Type );

-- Start of Comments
--
--    Function name : Get_Sales_Relation
--    Type        : Private
--    Function    : Return relation between two sales: Firstline manager(G_FIRSTLINE_MANAGER)
--		    higher level manager(G_HIGHER_MANAGER) and no relationship between them
--		    (G_NO_RELATION).
--
--    Pre-reqs    : None
--    Paramaeters    :
--	p_identity_salesforce_id	IN NUMBER	Required
--	p_salesrep_salesforce_id	IN NUMBER	Optional
--			DEFAULT FND_API.G_MISS_NUM
--    Version    :
--
--
--    Note :
--	Cases:
--	  1. If p_salesrep_salesforce_id is NULL or FND_API.G_MISS_NUM, this function will
--	     take p_identity_salesforce_id as a root and check all relations under it and
--	     determine if p_identity_salesforce_id is the firstline manager or not.
--	  2. If p_salesrep_salesforce_id is not NULL, the function will only check the
--	     relation between them.
--	Example:
--	  Give the relation map like this:
--				Manager A
--				   |
--				  / \
--			         /   \
--		        Sales rep B  Manager C
--     				      |
--				     Sales rep D
--	 For above example, if you pass in Manager A as p_identity_salesforce_id, and not pass in
--	 p_salesrep_salesforce_id, Manager A will be higher level manager
--	 if you pass in Manager A as p_identity_salesforce_id, and Sales rep B as p_salesrep_salesforce_id
--	 Manager A will be firstline manager.
/*
FUNCTION Get_Sales_Relations
(   p_identity_salesforce_id	IN NUMBER,
    p_salesrep_salesforce_id	IN NUMBER DEFAULT FND_API.G_MISS_NUM
 ) RETURN NUMBER;
*/
-- This function is to fix bug 855326
-- Check what the relation between a salesforce and a sales group
-- The possible return value is
--  E -- The salesforce is a salesrep in this sales group
--  M -- The salesforce is a manager for this sales group
--  A -- The salesforce is a administrator for this sales group
--  N -- The salesforce is no relation with this sales group
FUNCTION Get_Member_Role(p_salesforce_id NUMBER,
			 p_sales_group_id NUMBER) RETURN VARCHAR2;

END AS_SALES_ORG_MANAGER_PVT;

 

/
