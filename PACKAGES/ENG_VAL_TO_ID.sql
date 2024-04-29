--------------------------------------------------------
--  DDL for Package ENG_VAL_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_VAL_TO_ID" AUTHID CURRENT_USER AS
/* $Header: ENGSVIDS.pls 120.1.12010000.2 2011/11/28 09:14:26 rambkond ship $ */

--  Generator will append new prototypes before end generate comment.
FUNCTION Key_Flex
(   p_key_flex_code                 IN  VARCHAR2
,   p_structure_number              IN  NUMBER
,   p_appl_short_name               IN  VARCHAR2
,   p_segment_array                 IN  FND_FLEX_EXT.SegmentArray
) RETURN NUMBER;

FUNCTION Approval_List(p_approval_list IN VARCHAR2, x_err_text OUT NOCOPY VARCHAR2)RETURN NUMBER;
-- changed the signature to get status id :enhancement:5414834
PROCEDURE Change_Order_VID
( p_ECO_rec		   IN Eng_Eco_Pub.ECO_Rec_Type
, p_old_eco_unexp_rec      IN Eng_Eco_Pub.ECO_Unexposed_Rec_Type
, P_eco_unexp_rec          IN OUT NOCOPY Eng_Eco_Pub.ECO_Unexposed_Rec_Type
, x_Mesg_Token_Tbl         OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status          OUT NOCOPY VARCHAR2
);


FUNCTION Responsible_Org(p_responsible_org IN VARCHAR2
                       , p_current_org     IN NUMBER
                       , x_err_text OUT NOCOPY VARCHAR2)
RETURN NUMBER;

FUNCTION Organization(p_organization IN VARCHAR2, x_err_text OUT NOCOPY VARCHAR2)RETURN NUMBER;

/*FUNCTION Requestor(p_requestor IN VARCHAR2, x_err_text OUT NOCOPY VARCHAR2)RETURN NUMBER;
FUNCTION Using_Assembly(p_using_assembly IN VARCHAR2, x_err_text OUT NOCOPY VARCHAR2)RETURN NUMBER;*/

FUNCTION Revised_Item(  p_revised_item_num IN VARCHAR2,
                        p_organization_id IN NUMBER,
                        x_err_text OUT NOCOPY VARCHAR2 ) RETURN NUMBER;

FUNCTION Use_Up_Item(   p_use_up_item_num IN VARCHAR2,
                        p_organization_id IN NUMBER,
                        x_err_text OUT NOCOPY VARCHAR2 ) RETURN NUMBER;

FUNCTION Bill_Sequence(p_assembly_item_id IN NUMBER,
                       p_alternate_bom_designator IN VARCHAR2,
                       p_organization_id IN NUMBER,
                       x_err_text OUT NOCOPY VARCHAR2)RETURN NUMBER;


FUNCTION BillandAssembly( p_revised_item_seq_id         IN      NUMBER,
                          x_bill_sequence_id            OUT NOCOPY     NUMBER,
                          x_assembly_item_id            OUT NOCOPY     NUMBER,
                          x_err_text                    OUT NOCOPY     VARCHAR2) RETURN NUMBER;

FUNCTION AsmblyFromRevItem(p_revised_item_seq_id   IN     NUMBER,
                           x_err_text             OUT NOCOPY     VARCHAR2
                          ) RETURN NUMBER;

FUNCTION Revised_Item_Sequence(  p_revised_item_id      IN   NUMBER
                               , p_change_notice        IN   VARCHAR2
                               , p_organization_id      IN   NUMBER
                               , p_new_item_revision    IN   VARCHAR2
                               ) RETURN NUMBER;

FUNCTION Revision ( p_rev               IN VARCHAR2
                  , p_organization_id   IN NUMBER
                  , p_change_notice     IN VARCHAR2
                  , x_err_text          OUT NOCOPY VARCHAR2
                  ) RETURN NUMBER;

FUNCTION Revised_Item_Code(  p_revised_item_num IN NUMBER,
                        p_organization_id IN NUMBER,
                        p_revison_code  IN   VARCHAR2 )
RETURN  number;


FUNCTION Lifecycle_id
( p_lifecycle_name IN  VARCHAR2
, p_inventory_item_id		IN NUMBER
, p_org_id			IN NUMBER
, x_err_text      OUT NOCOPY VARCHAR2
)
RETURN NUMBER;



/*  11.5.10 Function to return parent_revised_item_sequence_id ,
    given revised_item_id ,schedule_date and alternate_bom_designator
*/

FUNCTION ParentRevSeqId
                  ( parent_item_name       IN VARCHAR2
                  , p_organization_id IN NUMBER
                  , p_alternate_bom_code IN VARCHAR2
		  ,p_schedule_date    DATE
		  ,p_change_id       NUMBER
                  ) RETURN NUMBER;


--  Added by MK on 12/03/00

PROCEDURE BillAndRevitem_UUI_To_UI
(  p_revised_item_name           IN  VARCHAR2
 , p_alternate_bom_code          IN  VARCHAR2 := NULL       -- Bug 2429272
 , p_revised_item_id             IN  NUMBER
 , p_item_revision               IN  VARCHAR2
 , p_effective_date              IN  DATE
 , p_change_notice               IN  VARCHAR2
 , p_organization_id             IN  NUMBER
 , p_new_routing_revision        IN  VARCHAR2 := NULL
 , p_from_end_item_number        IN  VARCHAR2 := NULL
 , p_entity_processed            IN  VARCHAR2 := 'RC'
 , p_component_item_name         IN  VARCHAR2 := NULL
 , p_component_item_id           IN  NUMBER   := NULL
 , p_operation_sequence_number   IN  NUMBER   := NULL
 , p_rfd_sbc_name                IN  VARCHAR2 := NULL
 , p_transaction_type            IN  VARCHAR2 := NULL
 , x_revised_item_sequence_id    OUT NOCOPY NUMBER
 , x_bill_sequence_id            OUT NOCOPY NUMBER
 , x_component_sequence_id       OUT NOCOPY NUMBER
 , x_Mesg_Token_Tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_other_message               OUT NOCOPY VARCHAR2
 , x_other_token_tbl             OUT NOCOPY Error_Handler.Token_Tbl_Type
 , x_return_status               OUT NOCOPY VARCHAR2
) ;


--  Added by MK on 12/03/00
PROCEDURE RtgAndRevitem_UUI_To_UI
(  p_revised_item_name           IN  VARCHAR2
 , p_revised_item_id             IN  NUMBER
 , p_item_revision               IN  VARCHAR2
 , p_effective_date              IN  DATE
 , p_change_notice               IN  VARCHAR2
 , p_organization_id             IN  NUMBER
 , p_new_routing_revision        IN  VARCHAR2 := NULL
 , p_from_end_item_number        IN  VARCHAR2 := NULL
 , p_entity_processed            IN  VARCHAR2 := 'ROP'
 , p_operation_sequence_number   IN  NUMBER   := NULL
 , p_operation_type              IN  NUMBER   := NULL
 , p_resource_sequence_number    IN  NUMBER   := NULL
 , p_sub_resource_code           IN  VARCHAR2 := NULL
 , p_schedule_sequence_number    IN  NUMBER   := NULL
 , p_transaction_type            IN  VARCHAR2 := NULL
 , p_alternate_routing_code      IN  VARCHAR2 := NULL    -- Added for bug 13329115
 , x_revised_item_sequence_id    OUT NOCOPY NUMBER
 , x_routing_sequence_id         OUT NOCOPY NUMBER
 , x_operation_sequence_id       OUT NOCOPY NUMBER
 , x_Mesg_Token_Tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_other_message               OUT NOCOPY VARCHAR2
 , x_other_token_tbl             OUT NOCOPY Error_Handler.Token_Tbl_Type
 , x_return_status               OUT NOCOPY VARCHAR2
) ;



PROCEDURE Revised_Item_VID
(  x_Return_Status       OUT NOCOPY VARCHAR2
 , x_Mesg_Token_Tbl      OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , p_rev_item_unexp_Rec  IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , x_rev_item_unexp_Rec  IN OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , p_revised_item_Rec    IN  Eng_Eco_Pub.Revised_Item_Rec_Type
);

PROCEDURE ECO_Header_VID
(   x_Return_Status              OUT NOCOPY    VARCHAR2
 ,  x_Mesg_Token_Tbl             OUT NOCOPY    Error_Handler.Mesg_Token_Tbl_Type
 ,  p_ECO_Rec                    IN     Eng_Eco_Pub.ECO_Rec_Type
 ,  p_ECO_Unexp_Rec              IN     Eng_Eco_Pub.Eco_Unexposed_Rec_Type
 ,  x_ECO_Unexp_Rec              IN OUT NOCOPY    Eng_Eco_Pub.Eco_Unexposed_Rec_Type
);

PROCEDURE ECO_Header_UUI_To_UI
(  p_eco_rec            IN  Eng_Eco_Pub.Eco_Rec_Type
 , p_eco_unexp_rec      IN  Eng_Eco_Pub.Eco_Unexposed_Rec_Type
 , x_eco_unexp_rec      IN OUT NOCOPY Eng_Eco_Pub.Eco_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      OUT NOCOPY VARCHAR2
);

PROCEDURE ECO_Revision_UUI_To_UI
(  p_eco_revision_rec   IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
 , p_eco_rev_unexp_rec  IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
 , x_eco_rev_unexp_rec  IN OUT NOCOPY Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      OUT NOCOPY VARCHAR2
);

PROCEDURE Revised_Item_UUI_To_UI
(  p_revised_item_rec   IN  Eng_Eco_Pub.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , x_rev_item_unexp_rec IN OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      OUT NOCOPY VARCHAR2
);

PROCEDURE Change_Line_UUI_To_UI
(  p_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_change_line_unexp_rec IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl        OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status         OUT NOCOPY VARCHAR2
);

PROCEDURE Change_Line_VID
(  p_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_change_line_unexp_rec IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl        OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status         OUT NOCOPY VARCHAR2
);


END ENG_Val_To_Id;

/
