--------------------------------------------------------
--  DDL for Package MRP_SOURCING_RULE_HANDLERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SOURCING_RULE_HANDLERS" AUTHID CURRENT_USER AS
/* $Header: MRPHSRLS.pls 115.1 99/07/16 12:23:40 porting ship $ */

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Sourcing_Rule_rec             IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Sourcing_Rule_rec             IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_Sourcing_Rule_Id              IN  NUMBER
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   p_Sourcing_Rule_rec             IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
,   x_Sourcing_Rule_rec             OUT MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
);

--  Function Query_Row

FUNCTION Query_Row
(   p_Sourcing_Rule_Id              IN  NUMBER
) RETURN MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type;

--  Procedure Query_Entity

PROCEDURE Query_Entity
(   p_Sourcing_Rule_Id              IN  NUMBER
,   x_Sourcing_Rule_rec             OUT MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
,   x_Sourcing_Rule_val_rec         OUT MRP_Sourcing_Rule_PUB.Sourcing_Rule_Val_Rec_Type
);

END MRP_Sourcing_Rule_Handlers;

 

/
