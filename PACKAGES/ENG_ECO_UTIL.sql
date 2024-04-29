--------------------------------------------------------
--  DDL for Package ENG_ECO_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_ECO_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGUECOS.pls 120.3.12010000.3 2009/06/15 15:02:40 vggarg ship $ */


  --========================================================================
-- PROCEDURE : Org_Hierarchy_List      PUBLIC
-- PARAMETERS: p_org_hierarch_name    IN VARCHAR2(30) Organization Hierarchy
--                                                     Name
--             p_org_hier_lvl_id     IN NUMBER  Hierarchy Level Id
--             x_org_cod_list         List of Organizations
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
( p_org_hierarch_name IN  VARCHAR2,
  p_org_hier_lvl_id  IN  NUMBER,
  x_org_cod_list      OUT NOCOPY ego_number_tbl_type);




  /********************************************************************
  * API Type      : Local APIs
  * Purpose       : Those APIs are private
  *********************************************************************/
    /** R12C Changes
   * ENG Change order Proc implementation
   * */


   PROCEDURE Execute_ProcCP
  (
    p_api_version               IN   NUMBER    := 1.0                         --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := '/appslog/bis_top/utl/plm115dv/log'
   ,p_debug_filename            IN   VARCHAR2 := 'engact.implement.log'
   ,x_return_status             OUT NOCOPY  VARCHAR2                    --
   ,x_msg_count                 OUT NOCOPY  NUMBER                      --
   ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
   ,p_change_id                 IN   NUMBER                             --
   ,p_change_notice             IN   VARCHAR2                           --
   ,p_rev_item_seq_id           IN   NUMBER   := NULL
   ,p_org_id                    IN   NUMBER                             --
   ,p_all_org_flag              IN   VARCHAR2
   ,p_hierarchy_name            IN   VARCHAR2
   ,x_request_id                OUT NOCOPY  NUMBER                      --
  );

-- Code changes for enhancement 6084027 start
        PROCEDURE Execute_ProcCP
        (
          p_api_version               IN   NUMBER                             --
         ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
         ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
         ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
         ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
         ,p_output_dir                IN   VARCHAR2
         ,p_debug_filename            IN   VARCHAR2
         ,x_return_status             OUT NOCOPY  VARCHAR2                    --
         ,x_msg_count                 OUT NOCOPY  NUMBER                      --
         ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
         ,p_change_id                 IN   NUMBER                             --
         ,p_change_notice             IN   VARCHAR2                           --
         ,p_rev_item_seq_id           IN   NUMBER   := NULL
         ,p_org_id                    IN   NUMBER                             --
         ,x_request_id                OUT NOCOPY  NUMBER                      --
        );
   -- Code changes for enhancement 6084027 end

  /**
   * ENG Change ECO Action
   * @author HaiXin Tie
   */

     /**  R12C Changes
   * ENG Change order Rule invocation implementation.
   * For R12C we have changed this so that for PLM/ERP Change order
   * Implementation first rule CP will get fire if there exist any attribute changes
   * Corresponding to it then Rule validation/assignment will happen.
   * after successfull execution of rule Proc CP will get fire.
   * ENG Change ECO Action.Just executable has been changed all other things are same.
   * @author HaiXin Tie
   */

  PROCEDURE Implement_ECO
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := '/appslog/bis_top/utl/plm115dv/log'
   ,p_debug_filename            IN   VARCHAR2 := 'engact.implement.log'
   ,x_return_status             OUT NOCOPY  VARCHAR2                    --
   ,x_msg_count                 OUT NOCOPY  NUMBER                      --
   ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
   ,p_change_id                 IN   NUMBER                             --
   ,p_change_notice             IN   VARCHAR2                           --
   ,p_rev_item_seq_id           IN   NUMBER   := NULL
   ,p_org_id                    IN   NUMBER                             --
   ,x_request_id                OUT NOCOPY  NUMBER                      --
  );



  /**
   * ENG Change ECO Action
   * @author HaiXin Tie
   */
  PROCEDURE Propagate_ECO
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := '/appslog/bis_top/utl/plm115dv/log'
   ,p_debug_filename            IN   VARCHAR2 := 'engact.propagate.log'
   ,x_return_status             OUT NOCOPY  VARCHAR2                    --
   ,x_msg_count                 OUT NOCOPY  NUMBER                      --
   ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
   ,p_change_id                 IN   NUMBER                             --
   ,p_change_notice             IN   VARCHAR2                           --
   ,p_hierarchy_name            IN   VARCHAR2                           --
   ,p_org_name                  IN   VARCHAR2                           --
   ,x_request_id                OUT NOCOPY  NUMBER                      --
   ,p_local_organization_id     IN NUMBER := NULL -- Added for R12
   ,p_calling_API           IN    VARCHAR2 := NULL --R12

  );


  /**
   * ENG Change ECO Action
   * @author HaiXin Tie
   */
  PROCEDURE Reschedule_ECO
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := '/appslog/bis_top/utl/plm115dv/log'
   ,p_debug_filename            IN   VARCHAR2 := 'engact.reschedule.log'
   ,x_return_status             OUT NOCOPY  VARCHAR2                    --
   ,x_msg_count                 OUT NOCOPY  NUMBER                      --
   ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
   ,p_change_id                 IN   NUMBER                             --
   ,p_effectivity_date          IN   DATE                               --
   ,p_requestor_id              IN   NUMBER                             --
   ,p_comment                   IN   VARCHAR2                           --
  );


  /**
   * ENG Change ECO Action
   * @author HaiXin Tie
   */
  PROCEDURE Change_Effectivity_Date
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := '/appslog/bis_top/utl/plm115dv/log'
   ,p_debug_filename            IN   VARCHAR2 := 'engact.chgEffDate.log'
   ,x_return_status             OUT NOCOPY  VARCHAR2                    --
   ,x_msg_count                 OUT NOCOPY  NUMBER                      --
   ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
   ,p_change_id                 IN   NUMBER                             --
   ,p_effectivity_date          IN   DATE                               --
   ,p_comment                   IN   VARCHAR2                           --
  );

  /**
   * ENG Change Submit action
   * @author biao
   */
  PROCEDURE submit_ECO
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := '/appslog/bis_top/utl/plm115dv/log'
   ,p_debug_filename            IN   VARCHAR2 := 'engact.submitECO.log'
   ,x_return_status             OUT NOCOPY  VARCHAR2                    --
   ,x_msg_count                 OUT NOCOPY  NUMBER                      --
   ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
   ,p_change_id                 IN   NUMBER                             --
  );


--  Attributes global constants

G_ATTRIBUTE7                  CONSTANT NUMBER := 1;
G_ATTRIBUTE8                  CONSTANT NUMBER := 2;
G_ATTRIBUTE9                  CONSTANT NUMBER := 3;
G_ATTRIBUTE10                 CONSTANT NUMBER := 4;
G_ATTRIBUTE11                 CONSTANT NUMBER := 5;
G_ATTRIBUTE12                 CONSTANT NUMBER := 6;
G_ATTRIBUTE13                 CONSTANT NUMBER := 7;
G_ATTRIBUTE14                 CONSTANT NUMBER := 8;
G_ATTRIBUTE15                 CONSTANT NUMBER := 9;
G_REQUEST                     CONSTANT NUMBER := 10;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 11;
G_PROGRAM                     CONSTANT NUMBER := 12;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 13;
G_APPROVAL_STATUS_TYPE        CONSTANT NUMBER := 14;
G_APPROVAL_DATE               CONSTANT NUMBER := 15;
G_APPROVAL_LIST               CONSTANT NUMBER := 16;
G_CHANGE_ORDER_TYPE           CONSTANT NUMBER := 17;
G_RESPONSIBLE_ORG             CONSTANT NUMBER := 18;
G_APPROVAL_REQUEST_DATE       CONSTANT NUMBER := 19;
G_CHANGE_NOTICE               CONSTANT NUMBER := 20;
G_ORGANIZATION                CONSTANT NUMBER := 21;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 22;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 23;
G_CREATION_DATE               CONSTANT NUMBER := 24;
G_CREATED_BY                  CONSTANT NUMBER := 25;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 26;
G_DESCRIPTION                 CONSTANT NUMBER := 27;
G_STATUS_TYPE                 CONSTANT NUMBER := 28;
G_INITIATION_DATE             CONSTANT NUMBER := 29;
G_IMPLEMENTATION_DATE         CONSTANT NUMBER := 30;
G_CANCELLATION_DATE           CONSTANT NUMBER := 31;
G_CANCELLATION_COMMENTS       CONSTANT NUMBER := 32;
G_PRIORITY                    CONSTANT NUMBER := 33;
G_REASON                      CONSTANT NUMBER := 34;
G_ESTIMATED_ENG_COST          CONSTANT NUMBER := 35;
G_ESTIMATED_MFG_COST          CONSTANT NUMBER := 36;
G_REQUESTOR                   CONSTANT NUMBER := 37;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 38;
G_ATTRIBUTE1                  CONSTANT NUMBER := 39;
G_ATTRIBUTE2                  CONSTANT NUMBER := 40;
G_ATTRIBUTE3                  CONSTANT NUMBER := 41;
G_ATTRIBUTE4                  CONSTANT NUMBER := 42;
G_ATTRIBUTE5                  CONSTANT NUMBER := 43;
G_ATTRIBUTE6                  CONSTANT NUMBER := 44;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 45;

-- Procedure Perform_Writes

PROCEDURE Perform_Writes
(   p_ECO_rec			            IN ENG_ECO_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec		        IN ENG_ECO_PUB.ECO_Unexposed_Rec_Type
,   p_old_ECO_rec		          IN ENG_ECO_PUB.Eco_Rec_Type
,   p_control_rec             IN BOM_BO_PUB.Control_Rec_Type
                                 := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
,   x_Mesg_Token_Tbl		      OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status		        OUT NOCOPY VARCHAR
);


--  Procedure Query_Row

PROCEDURE Query_Row
(   p_change_notice           IN  VARCHAR2
,   p_organization_id         IN  NUMBER
,   x_ECO_rec                 OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_ECO_Unexp_Rec           OUT NOCOPY ENG_ECO_PUB.ECO_Unexposed_Rec_Type
,   x_return_status           OUT NOCOPY VARCHAR2
,   x_err_text			          OUT NOCOPY VARCHAR2);



-- Procedure Perform_Approval_Status_Change
-- to centraize business logic for Approval Status change
PROCEDURE Perform_Approval_Status_Change
(   p_change_id               IN  NUMBER
 ,  p_user_id                 IN  NUMBER   := NULL
 ,  p_approval_status_type    IN  NUMBER
 ,  p_caller_type             IN  VARCHAR2 := 'OI'
 ,  x_return_status           OUT NOCOPY VARCHAR2
 ,  x_err_text                OUT NOCOPY VARCHAR2
);

--  Procedure       lock_Row
--

/*PROCEDURE Lock_Row
(   x_return_status           OUT NOCOPY VARCHAR2
,   x_err_text			          OUT NOCOPY VARCHAR2
,   p_ECO_rec                 IN  ENG_Eco_PUB.Eco_Rec_Type
,   x_ECO_rec                 OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
);
*/


PROCEDURE Change_Subjects
( p_eco_rec                    IN     Eng_Eco_Pub.Eco_Rec_Type
, p_ECO_Unexp_Rec              IN     Eng_Eco_Pub.Eco_Unexposed_Rec_Type
, x_change_subject_unexp_rec   IN OUT NOCOPY  Eng_Eco_Pub.Change_Subject_Unexp_Rec_Type
, x_Mesg_Token_Tbl	       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type --bug 3572721
, x_return_status              IN OUT NOCOPY  VARCHAR2
);


 PROCEDURE delete_ECO
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_api_caller                IN   VARCHAR2 := 'UI'
  );

 PROCEDURE is_Reschedule_ECO_Allowed
  (
   p_change_id                 IN   NUMBER                             --
   ,x_is_change_sch_date_allowed    OUT  NOCOPY VARCHAR2
  );

END ENG_Eco_Util;

/
