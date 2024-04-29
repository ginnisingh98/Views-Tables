--------------------------------------------------------
--  DDL for Package WIP_VALIDATE_SHOPFLOORMOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_VALIDATE_SHOPFLOORMOVE" AUTHID CURRENT_USER AS
/* $Header: WIPLSFMS.pls 115.7 2002/11/28 11:45:19 rmahidha ship $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_validation_level		    IN  NUMBER DEFAULT NULL
,   p_ShopFloorMove_rec             IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
,   p_old_ShopFloorMove_rec         IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_validation_level		    IN  NUMBER DEFAULT NULL
,   p_ShopFloorMove_rec             IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
,   p_old_ShopFloorMove_rec         IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
);

END WIP_Validate_Shopfloormove;

 

/
