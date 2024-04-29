--------------------------------------------------------
--  DDL for Package ENG_DEFAULT_REVISED_ITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_DEFAULT_REVISED_ITEM" AUTHID CURRENT_USER AS
/* $Header: ENGDRITS.pls 120.1 2008/01/24 02:15:20 atjen ship $ */

--  Procedure Attributes

G_CREATE_ALTERNATE      BOOLEAN := FALSE;
G_SCHED_DATE_CHANGED    BOOLEAN := FALSE;
G_DEL_UPD_INS_ITEM_REV  NUMBER  := 0;

G_CREATE_RTG_ALTERNATE  BOOLEAN := FALSE;
G_DEL_UPD_INS_RTG_REV   NUMBER  := 0;
-- Added by MK on 09/01/2000

G_ECO_FOR_PROD_CHANGED  BOOLEAN := FALSE;
-- Added by MK on 10/24/2000

G_OLD_SCHED_DATE        DATE := NULL;  -- Bug 6657209


PROCEDURE Attribute_Defaulting
(   p_revised_item_rec          IN  ENG_Eco_PUB.Revised_Item_Rec_Type
,   p_rev_item_unexp_rec        IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
,   x_revised_item_rec          IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Rec_Type
,   x_rev_item_unexp_rec        IN OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_rec_type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);


PROCEDURE Populate_Null_Columns
( p_revised_item_rec           IN  ENG_Eco_PUB.Revised_item_Rec_Type
, p_old_revised_item_rec       IN  Eng_Eco_Pub.Revised_item_Rec_Type
, p_rev_item_unexp_Rec         IN  Eng_Eco_Pub.Rev_item_Unexposed_Rec_Type
, p_Old_rev_item_unexp_Rec     IN  Eng_Eco_Pub.Rev_item_Unexposed_Rec_Type
, x_revised_item_Rec           IN OUT NOCOPY Eng_Eco_Pub.Revised_Item_Rec_Type
, x_rev_item_unexp_Rec         IN OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
);

PROCEDURE Entity_Defaulting
(   p_revised_item_rec          IN  ENG_Eco_PUB.Revised_Item_Rec_Type
,   p_rev_item_unexp_rec        IN  ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type
,   p_old_revised_item_rec      IN  Eng_Eco_Pub.Revised_Item_Rec_Type
,   p_old_rev_item_unexp_rec    IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
,   p_control_rec               IN  BOM_BO_Pub.Control_Rec_Type
                                        := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
,   x_revised_item_rec          IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Rec_Type
,   x_rev_item_unexp_rec        IN OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
);

END ENG_Default_Revised_Item;

/
