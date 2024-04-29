--------------------------------------------------------
--  DDL for Package MRP_DEFAULT_RECEIVING_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_DEFAULT_RECEIVING_ORG" AUTHID CURRENT_USER AS
/* $Header: MRPDRCOS.pls 115.1 99/07/16 12:19:03 porting ship $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_Receiving_Org_rec             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_RECEIVING_ORG_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Receiving_Org_rec             OUT MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
);

END MRP_Default_Receiving_Org;

 

/
