--------------------------------------------------------
--  DDL for Package WIP_DEFAULT_REPSCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DEFAULT_REPSCHEDULE" AUTHID CURRENT_USER AS
/* $Header: WIPDWRSS.pls 115.6 2002/11/28 11:22:19 rmahidha ship $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_RepSchedule_rec               IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
,   p_iteration                     IN  NUMBER DEFAULT NULL
,   p_ReDefault                     IN  BOOLEAN DEFAULT NULL
,   x_RepSchedule_rec               OUT NOCOPY WIP_Work_Order_PUB.Repschedule_Rec_Type
);

END WIP_Default_Repschedule;

 

/
