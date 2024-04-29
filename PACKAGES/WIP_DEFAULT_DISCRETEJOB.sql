--------------------------------------------------------
--  DDL for Package WIP_DEFAULT_DISCRETEJOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DEFAULT_DISCRETEJOB" AUTHID CURRENT_USER AS
/* $Header: WIPDWDJS.pls 120.0 2005/05/25 07:30:02 appldev noship $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_DiscreteJob_rec               IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
,   p_iteration                     IN  NUMBER DEFAULT NULL
,   p_ReDefault                     IN  BOOLEAN DEFAULT NULL
,   x_DiscreteJob_rec               OUT NOCOPY WIP_Work_Order_PUB.Discretejob_Rec_Type
);

END WIP_Default_Discretejob;

 

/
