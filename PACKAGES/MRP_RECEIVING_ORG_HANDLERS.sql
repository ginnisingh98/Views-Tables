--------------------------------------------------------
--  DDL for Package MRP_RECEIVING_ORG_HANDLERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_RECEIVING_ORG_HANDLERS" AUTHID CURRENT_USER AS
/* $Header: MRPHRCOS.pls 115.1 99/07/16 12:22:54 porting ship $ */

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Receiving_Org_rec             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Receiving_Org_rec             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_Sr_Receipt_Id                 IN  NUMBER
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   p_Receiving_Org_rec             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
,   x_Receiving_Org_rec             OUT MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
);

--  Function Query_Row

FUNCTION Query_Row
(   p_Sr_Receipt_Id                 IN  NUMBER
) RETURN MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type;

--  Procedure Query_Entity

PROCEDURE Query_Entity
(   p_Sr_Receipt_Id                 IN  NUMBER
,   x_Receiving_Org_rec             OUT MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
,   x_Receiving_Org_val_rec         OUT MRP_Sourcing_Rule_PUB.Receiving_Org_Val_Rec_Type
);

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_Sr_Receipt_Id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_Sourcing_Rule_Id              IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type;

--  Procedure Query_Entities

--

PROCEDURE Query_Entities
(   p_Sr_Receipt_Id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_Sourcing_Rule_Id              IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_Receiving_Org_tbl             OUT MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type
,   x_Receiving_Org_val_tbl         OUT MRP_Sourcing_Rule_PUB.Receiving_Org_Val_Tbl_Type
);

END MRP_Receiving_Org_Handlers;

 

/
