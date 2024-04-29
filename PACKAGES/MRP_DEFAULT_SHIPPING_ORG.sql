--------------------------------------------------------
--  DDL for Package MRP_DEFAULT_SHIPPING_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_DEFAULT_SHIPPING_ORG" AUTHID CURRENT_USER AS
/* $Header: MRPDSHOS.pls 115.1 99/07/16 12:19:28 porting ship $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_Shipping_Org_rec              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SHIPPING_ORG_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Shipping_Org_rec              OUT MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
);

END MRP_Default_Shipping_Org;

 

/
