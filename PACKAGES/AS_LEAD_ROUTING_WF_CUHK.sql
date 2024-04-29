--------------------------------------------------------
--  DDL for Package AS_LEAD_ROUTING_WF_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_LEAD_ROUTING_WF_CUHK" AUTHID CURRENT_USER AS
/* $Header: asxcldos.pls 120.1 2005/06/05 22:52:11 appldev  $ */

-- Start of Comments
-- Package Name     : AS_LEAD_ROUTING_WF_CUHK
-- Purpose          : If user wants to implement custome routing rules,
--                    create a package body for this spec.
-- Note             :
--                    Please do not commit in this package body, once the
--                    transaction is complete, Oracle Application code
--                    will issue commit.
--
--                    This user hook will be called while creating and updating
--                    lead from OSO leads tab, Telesales leads tab, and lead
--                    import program when routing engine is called.
--                    The calling package: AS_LEAD_ROUTING_WF.GetOwner.
-- History          :
--       07/27/2001   SOLIN   Created
-- End of Comments

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC CONSTANTS
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC DATATYPES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC VARIABLES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC ROUTINES
 |
 *-------------------------------------------------------------------------*/

-- Start of Comments
--
--   API name   : Get_Owner_Pre
--   Parameters :
--   IN         :
--       p_api_version_number: For 11i Oracle Sales application, this is 2.0.
--       p_init_msg_list     : Initialize message stack or not. It's
--                             FND_API.G_FALSE by default.
--       p_validation_level  : Validation level of pass-in value.
--                             It's FND_API.G_VALID_LEVEL_FULL by default.
--       p_commit            : Whether commit the whole API at the end of API.
--                             It's FND_API.G_FALSE by default.
--
--                             The above four parameters are standard input.
--       p_resource_id_tbl   :
--       p_group_id_tbl      :
--       p_person_id_tbl     :
--                             The above three parameters store the available
--                             resources for this customized package to decide
--                             owner of the sales lead. Their datatype is
--                             TABLE of NUMBERs.
--       p_resource_flag_tbl :
--                             This parameter specify the source of the
--                             resource.
--                             'D': This is default resource, comes from the
--                                  profile AS_DEFAULT_RESOURCE_ID, "OS:
--                                  Default Resource ID used for Sales Lead
--                                  Assignment"
--                             'L': This is login user.
--                             'T': This resource comes from territory
--                                  definition.
--
--                             If the sales lead matches any territory, the above
--                             parameters will include all the resources returned
--                             from territory engine and p_resource_flag_tbl will
--                             be all 'T'. If it doesn't match any territory:
--                             1. Profile "OS: Default Resource ID used for Sales
--                                Lead Assignment" is set:
--                               p_resource_id_tbl(1), p_group_id_tbl(1),
--                               p_person_id_tbl(1) is the default resource
--                               defined in this profile.
--                               p_resource_flag_tbl(1)='D'
--                               p_resource_id_tbl(2), p_group_id_tbl(2),
--                               p_person_id_tbl(2) is the login user.
--                               p_resource_flag_tbl(2)='L'
--                             2. Profile "OS: Default Resource ID used for Sales
--                                Lead Assignment" is not set:
--                               p_resource_id_tbl(1), p_group_id_tbl(1),
--                               p_person_id_tbl(1) is the login user.
--                               p_resource_flag_tbl(1)='L'
--
--       p_sales_lead_rec    :
--                             This is the whole definition of the sales lead.
--                             This record is provided to help Oracle customer
--                             decide sales lead owner.
--   OUT NOCOPY /* file.sql.39 change */        :
--       x_resource_id       :
--       x_group_id          :
--       x_person_id         :
--                             The above three parameters store the result
--                             of this user hook. It will be set as sales
--                             lead owner. If x_resource_id is NULL, owner
--                             will be decided based upon Oracle's logic.
--                             For instance, x_resource_id=1001, x_group_id=10,
--                             x_person_id=100, it means the resource with
--                             resource id 1001, group id 10 and person id 100
--                             will be the owner of the sales lead.
--       x_return_status     :
--                             The return status. If your code completes
--                             successfully, then FND_API.G_RET_STS_SUCCESS
--                             should be returned; if you get an expected error,
--                             then return FND_API.G_RET_STS_ERROR; otherwise
--                             return FND_API.G_RET_STS_UNEXP_ERROR.
--       x_msg_count         :
--                             The message count.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--       x_msg_data          :
--                             The messages.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--
--                             The above three parameters are standard output
--                             parameters.
--
PROCEDURE Get_Owner_Pre(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_resource_id_tbl       IN  AS_LEAD_ROUTING_WF.NUMBER_TABLE,
    p_group_id_tbl          IN  AS_LEAD_ROUTING_WF.NUMBER_TABLE,
    p_person_id_tbl         IN  AS_LEAD_ROUTING_WF.NUMBER_TABLE,
    p_resource_flag_tbl     IN  AS_LEAD_ROUTING_WF.FLAG_TABLE,
    p_sales_lead_rec        IN  AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type,
    x_resource_id           OUT NOCOPY /* file.sql.39 change */ NUMBER,
    x_group_id              OUT NOCOPY /* file.sql.39 change */ NUMBER,
    x_person_id             OUT NOCOPY /* file.sql.39 change */ NUMBER,
    x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    x_msg_count             OUT NOCOPY /* file.sql.39 change */ NUMBER,
    x_msg_data              OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


END AS_LEAD_ROUTING_WF_CUHK;


 

/
