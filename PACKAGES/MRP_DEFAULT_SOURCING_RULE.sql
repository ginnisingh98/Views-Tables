--------------------------------------------------------
--  DDL for Package MRP_DEFAULT_SOURCING_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_DEFAULT_SOURCING_RULE" AUTHID CURRENT_USER AS
/* $Header: MRPDSRLS.pls 120.1 2005/06/16 08:19:53 ichoudhu noship $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_Sourcing_Rule_rec             IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SOURCING_RULE_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Sourcing_Rule_rec             OUT NOCOPY MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type --NOCOPY CHANGES
);

END MRP_Default_Sourcing_Rule;

 

/
