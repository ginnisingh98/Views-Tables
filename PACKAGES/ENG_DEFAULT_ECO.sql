--------------------------------------------------------
--  DDL for Package ENG_DEFAULT_ECO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_DEFAULT_ECO" AUTHID CURRENT_USER AS
/* $Header: ENGDECOS.pls 120.0.12010000.1 2008/07/28 06:23:30 appldev ship $ */

--  Procedure Attribute_Defaulting

PROCEDURE Attribute_Defaulting
(   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_Unexp_ECO_rec		    IN OUT NOCOPY ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   x_return_status		    OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
);

--  Procedure Entity_Defaulting

PROCEDURE Entity_Defaulting
(   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   p_Old_ECO_rec	 	    IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Old_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   p_control_rec		    IN  BOM_BO_PUB.Control_Rec_Type :=
					BOM_BO_PUB.G_DEFAULT_CONTROL_REC
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_Unexp_ECO_rec		    IN OUT NOCOPY ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   x_return_status		    OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
);

--  Procedure Populate_NULL_Columns

PROCEDURE Populate_NULL_Columns
(   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   p_Old_ECO_rec	 	    IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Old_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_Unexp_ECO_rec		    IN OUT NOCOPY ENG_Eco_PUB.Eco_unexposed_Rec_Type
);

END ENG_Default_Eco;

/
