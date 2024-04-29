--------------------------------------------------------
--  DDL for Package ENG_REVISED_ITEM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_REVISED_ITEM_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGURITS.pls 120.2.12010000.3 2009/06/17 05:55:17 vggarg ship $ */

--  Attributes global constants

/*G_USING_ASSEMBLY              CONSTANT NUMBER := 1;*/
G_CHANGE_NOTICE               CONSTANT NUMBER := 2;
G_ORGANIZATION                CONSTANT NUMBER := 3;
G_REVISED_ITEM                CONSTANT NUMBER := 4;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 5;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 6;
G_CREATION_DATE               CONSTANT NUMBER := 7;
G_CREATED_BY                  CONSTANT NUMBER := 8;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 9;
G_IMPLEMENTATION_DATE         CONSTANT NUMBER := 10;
G_CANCELLATION_DATE           CONSTANT NUMBER := 11;
G_CANCEL_COMMENTS             CONSTANT NUMBER := 12;
G_DISPOSITION_TYPE            CONSTANT NUMBER := 13;
G_NEW_ITEM_REVISION           CONSTANT NUMBER := 14;
G_EARLY_SCHEDULE_DATE         CONSTANT NUMBER := 15;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 16;
G_ATTRIBUTE2                  CONSTANT NUMBER := 17;
G_ATTRIBUTE3                  CONSTANT NUMBER := 18;
G_ATTRIBUTE4                  CONSTANT NUMBER := 19;
G_ATTRIBUTE5                  CONSTANT NUMBER := 20;
G_ATTRIBUTE7                  CONSTANT NUMBER := 21;
G_ATTRIBUTE8                  CONSTANT NUMBER := 22;
G_ATTRIBUTE9                  CONSTANT NUMBER := 23;
G_ATTRIBUTE11                 CONSTANT NUMBER := 24;
G_ATTRIBUTE12                 CONSTANT NUMBER := 25;
G_ATTRIBUTE13                 CONSTANT NUMBER := 26;
G_ATTRIBUTE14                 CONSTANT NUMBER := 27;
G_ATTRIBUTE15                 CONSTANT NUMBER := 28;
G_STATUS_TYPE                 CONSTANT NUMBER := 29;
G_SCHEDULED_DATE              CONSTANT NUMBER := 30;
G_BILL_SEQUENCE               CONSTANT NUMBER := 31;
G_MRP_ACTIVE                  CONSTANT NUMBER := 32;
G_REQUEST                     CONSTANT NUMBER := 33;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 34;
G_PROGRAM                     CONSTANT NUMBER := 35;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 36;
G_UPDATE_WIP                  CONSTANT NUMBER := 37;
G_USE_UP                      CONSTANT NUMBER := 38;
G_USE_UP_ITEM                 CONSTANT NUMBER := 39;
G_REVISED_ITEM_SEQUENCE       CONSTANT NUMBER := 40;
G_USE_UP_PLAN_NAME            CONSTANT NUMBER := 41;
G_DESCRIPTIVE_TEXT            CONSTANT NUMBER := 42;
G_AUTO_IMPLEMENT_DATE         CONSTANT NUMBER := 43;
G_ATTRIBUTE1                  CONSTANT NUMBER := 44;
G_ATTRIBUTE6                  CONSTANT NUMBER := 45;
G_ATTRIBUTE10                 CONSTANT NUMBER := 46;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 47;

-- Procedure cancel_revised_items
Procedure Cancel_Revised_Item
( rev_item_seq          IN  NUMBER
, bill_seq_id           IN  NUMBER
, routing_seq_id        IN  NUMBER -- Added by MK on 09/01/2000
, user_id               IN  NUMBER
, login                 IN  NUMBER
, change_order          IN  VARCHAR2
, cancel_comments       IN  VARCHAR2
, p_Mesg_Token_Tbl      IN  Error_Handler.Mesg_Token_Tbl_Type
, x_Mesg_Token_Tbl      OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
);

PROCEDURE Query_Row
( p_revised_item_id     IN  NUMBER
, p_organization_id     IN  NUMBER
, p_change_notice       IN  VARCHAR2
, p_start_eff_date      IN  DATE := NULL
, p_new_item_revision   IN  VARCHAR2
, p_new_routing_revision IN  VARCHAR2 -- Added by MK
, p_from_end_item_number IN VARCHAR2 := NULL
, p_alternate_designator IN VARCHAR2 := NULL -- To fix 2869146
, x_revised_item_rec    OUT NOCOPY Eng_Eco_Pub.Revised_Item_Rec_Type
, x_rev_item_unexp_rec  OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
, x_Return_status       OUT NOCOPY VARCHAR2
);



PROCEDURE Perform_Writes( p_revised_item_rec    IN
                                        Eng_Eco_Pub.Revised_Item_Rec_Type
                        , p_rev_item_unexp_rec  IN
                                        Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
                        , p_control_rec         IN  BOM_BO_Pub.Control_Rec_Type
                                        := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
                        , x_Mesg_Token_Tbl      OUT NOCOPY
                                        Error_Handler.Mesg_Token_Tbl_Type
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        );


/********************************************************************
* API Name : Reschedule_Revised_Item
* API Type : Public PROCEDURE
* Purpose  : API to reschedule the revised item.
*            This API is called from the JAVA layer.
* Input    : p_revised_item_sequence_id , p_effectivity_date
* Output   : x_return_status
*********************************************************************/
PROCEDURE Reschedule_Revised_Item
(   p_api_version              IN NUMBER := 1.0                         --
  , p_init_msg_list            IN VARCHAR2 := FND_API.G_FALSE           --
  , p_commit                   IN VARCHAR2 := FND_API.G_FALSE           --
  , p_validation_level         IN NUMBER  := FND_API.G_VALID_LEVEL_FULL --
  , p_debug                    IN VARCHAR2 := 'N'                       --
  , p_output_dir               IN VARCHAR2 := NULL                      --
  , p_debug_filename           IN VARCHAR2 := 'Resch_RevItem.log'       --
  , x_return_status            OUT NOCOPY VARCHAR2                      --
  , x_msg_count                OUT NOCOPY NUMBER                        --
  , x_msg_data                 OUT NOCOPY VARCHAR2                      --
  , p_revised_item_sequence_id IN NUMBER
  , p_effectivity_date         IN DATE
);

------------------------------------------------------------------------
--  API name    : Copy_Revised_Item                             --
--  Type        : Private                                             --
--  Pre-reqs    : None.                                               --
--  Procedure   : Propagates the specified ECO                        --
--  Parameters  :                                                     --
--       IN     : p_old_revised_item_seq_id  NUMBER     Required      --
--                p_effectivity_date         DATE       Required      --
--       OUT    : x_new_revised_item_seq_id  VARCHAR2(1)              --
--                x_return_status            VARCHAR2(30)             --
--  Version     : Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       : This API is invoked only when a common bill has     --
--                pending changes associated for its WIP supply type  --
--                attributes and the common component in the source   --
--                bill is being implemented.                          --
--                This API will create a revised item in the same     --
--                status as the old revised item being passed as an   --
--                input parameter.                                    --
--                A copy of all the destination changes are then made --
--                to this revised item with the effectivity range of  --
--                the component being implemented.                    --
------------------------------------------------------------------------
PROCEDURE Copy_Revised_Item (
    p_old_revised_item_seq_id IN NUMBER
  , p_effectivity_date        IN DATE
  , x_new_revised_item_seq_id OUT NOCOPY NUMBER
--  , x_Mesg_Token_Tbl          OUT NOCOPY  Error_Handler.Mesg_Token_Tbl_Type
  , x_return_status           OUT NOCOPY VARCHAR2
);
-- Code changes for enhancement 6084027 start
  /*****************************************************************************
   * Added by vggarg on 09 Oct 2007
   * Procedure     : update_new_description
   * Parameters IN : p_api_version, p_revised_item_sequence_id, p_new_description
   * Purpose       : Update the new_item_description column of the eng_revised_items table with the given value
   *****************************************************************************/
  PROCEDURE update_new_description
   (
      p_api_version IN NUMBER := 1.0
     ,p_revised_item_sequence_id IN NUMBER
     ,p_new_description mtl_system_items_b.description%TYPE
   );
-- Code changes for enhancement 6084027 end

END ENG_Revised_Item_Util;

/
