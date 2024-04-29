--------------------------------------------------------
--  DDL for Package WIP_VALIDATE_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_VALIDATE_RES" AUTHID CURRENT_USER AS
/* $Header: WIPLRESS.pls 115.6 2002/11/28 11:39:51 rmahidha ship $ */

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_validation_level		    IN  NUMBER DEFAULT NULL
,   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
,   p_old_Res_rec                   IN  WIP_Transaction_PUB.Res_Rec_Type
);

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_validation_level		    IN  NUMBER DEFAULT NULL
,   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
,   p_old_Res_rec                   IN  WIP_Transaction_PUB.Res_Rec_Type
);

END WIP_Validate_Res;

 

/
