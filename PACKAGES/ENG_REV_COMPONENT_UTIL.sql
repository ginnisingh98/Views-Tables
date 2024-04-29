--------------------------------------------------------
--  DDL for Package ENG_REV_COMPONENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_REV_COMPONENT_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGUCMPS.pls 115.12 2002/12/12 18:05:09 akumar ship $ */

--  Attributes global constants

G_SUPPLY_SUBINVENTORY         CONSTANT NUMBER := 1;
G_OP_LEAD_TIME_PERCENT        CONSTANT NUMBER := 2;
G_REVISED_ITEM_SEQUENCE       CONSTANT NUMBER := 3;
G_COST_FACTOR                 CONSTANT NUMBER := 4;
G_REQUIRED_FOR_REVENUE        CONSTANT NUMBER := 5;
G_HIGH_QUANTITY               CONSTANT NUMBER := 6;
G_COMPONENT_SEQUENCE          CONSTANT NUMBER := 7;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 8;
G_WIP_SUPPLY_TYPE             CONSTANT NUMBER := 9;
G_SUPPLY_LOCATOR              CONSTANT NUMBER := 10;
G_BOM_ITEM_TYPE               CONSTANT NUMBER := 11;
G_OPERATION_SEQ_NUM           CONSTANT NUMBER := 12;
G_COMPONENT_ITEM              CONSTANT NUMBER := 13;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 14;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 15;
G_CREATION_DATE               CONSTANT NUMBER := 16;
G_CREATED_BY                  CONSTANT NUMBER := 17;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 18;
G_ITEM_NUM                    CONSTANT NUMBER := 19;
G_COMPONENT_QUANTITY          CONSTANT NUMBER := 20;
G_COMPONENT_YIELD_FACTOR      CONSTANT NUMBER := 21;
G_COMPONENT_REMARKS           CONSTANT NUMBER := 22;
G_EFFECTIVITY_DATE            CONSTANT NUMBER := 23;
G_CHANGE_NOTICE               CONSTANT NUMBER := 24;
G_IMPLEMENTATION_DATE         CONSTANT NUMBER := 25;
G_DISABLE_DATE                CONSTANT NUMBER := 26;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 27;
G_ATTRIBUTE1                  CONSTANT NUMBER := 28;
G_ATTRIBUTE2                  CONSTANT NUMBER := 29;
G_ATTRIBUTE3                  CONSTANT NUMBER := 30;
G_ATTRIBUTE4                  CONSTANT NUMBER := 31;
G_ATTRIBUTE5                  CONSTANT NUMBER := 32;
G_ATTRIBUTE6                  CONSTANT NUMBER := 33;
G_ATTRIBUTE7                  CONSTANT NUMBER := 34;
G_ATTRIBUTE8                  CONSTANT NUMBER := 35;
G_ATTRIBUTE9                  CONSTANT NUMBER := 36;
G_ATTRIBUTE10                 CONSTANT NUMBER := 37;
G_ATTRIBUTE11                 CONSTANT NUMBER := 38;
G_ATTRIBUTE12                 CONSTANT NUMBER := 39;
G_ATTRIBUTE13                 CONSTANT NUMBER := 40;
G_ATTRIBUTE14                 CONSTANT NUMBER := 41;
G_ATTRIBUTE15                 CONSTANT NUMBER := 42;
G_PLANNING_FACTOR             CONSTANT NUMBER := 43;
G_QUANTITY_RELATED            CONSTANT NUMBER := 44;
G_SO_BASIS                    CONSTANT NUMBER := 45;
G_OPTIONAL                    CONSTANT NUMBER := 46;
G_MUTUALLY_EXCLUSIVE_OPT      CONSTANT NUMBER := 47;
G_INCLUDE_IN_COST_ROLLUP      CONSTANT NUMBER := 48;
G_CHECK_ATP                   CONSTANT NUMBER := 49;
G_SHIPPING_ALLOWED            CONSTANT NUMBER := 50;
G_REQUIRED_TO_SHIP            CONSTANT NUMBER := 51;
G_INCLUDE_ON_SHIP_DOCS        CONSTANT NUMBER := 52;
G_INCLUDE_ON_BILL_DOCS        CONSTANT NUMBER := 53;
G_LOW_QUANTITY                CONSTANT NUMBER := 54;
G_ACD_TYPE                    CONSTANT NUMBER := 55;
G_OLD_COMPONENT_SEQUENCE      CONSTANT NUMBER := 56;
G_BILL_SEQUENCE               CONSTANT NUMBER := 57;
G_REQUEST                     CONSTANT NUMBER := 58;
G_PROGRAM                     CONSTANT NUMBER := 59;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 60;
G_PICK_COMPONENTS             CONSTANT NUMBER := 61;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 62;


--  PROCEDURE Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
( p_rev_component_rec		IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec		IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Rev_Component_Rec		IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
, x_Rev_Comp_Unexp_Rec		IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
);

--  Function Query_Row

PROCEDURE Query_Row
( p_Component_Item_Id		IN  NUMBER
, p_Operation_Sequence_Number	IN  NUMBER
, p_Effectivity_Date		IN  DATE
, p_Bill_Sequence_Id		IN  NUMBER
, p_from_end_item_number	IN  VARCHAR2 := NULL
, x_Rev_Component_Rec		OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
, x_Rev_Comp_Unexp_Rec		OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Return_Status		OUT NOCOPY VARCHAR2
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_rev_component_rec             IN  Bom_Bo_Pub.Rev_Component_Rec_Type
,   x_rev_component_rec             IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
,   x_err_text                      OUT NOCOPY VARCHAR2
);


PROCEDURE Create_New_Bill(  p_assembly_item_id           IN NUMBER
                          , p_organization_id            IN NUMBER
                          , p_pending_from_ecn           IN VARCHAR2
                          , p_bill_sequence_id           IN NUMBER
                          , p_common_bill_sequence_id    IN NUMBER
                          , p_assembly_type              IN NUMBER
                          , p_last_update_date           IN DATE
                          , p_last_updated_by            IN NUMBER
                          , p_creation_date              IN DATE
                          , p_created_by                 IN NUMBER
                          , p_revised_item_seq_id        IN NUMBER
			  , p_original_system_reference  IN VARCHAR2
                          );


PROCEDURE Perform_Writes(  p_rev_component_rec	IN
			   Bom_Bo_Pub.Rev_Component_Rec_Type
			 , p_rev_comp_unexp_rec	IN
			   Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
			 , x_Mesg_Token_Tbl	OUT NOCOPY
			   Error_Handler.Mesg_Token_Tbl_Type
			 , x_Return_Status	OUT NOCOPY VARCHAR2
			 );

PROCEDURE Cancel_Component(  p_component_sequence_id    IN  NUMBER
                           , p_cancel_comments          IN  VARCHAR2
                           , p_user_id                  IN  NUMBER
                           , p_login_id                 IN  NUMBER
                           );

END ENG_Rev_Component_Util;

 

/
