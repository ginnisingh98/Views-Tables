--------------------------------------------------------
--  DDL for Package WIP_DEFAULT_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DEFAULT_RES" AUTHID CURRENT_USER AS
/* $Header: WIPDRESS.pls 120.0 2005/05/25 08:33:28 appldev noship $ */

--  Procedure Attributes

PROCEDURE Attributes
(   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
,   p_iteration                     IN  NUMBER := NULL
,   x_Res_rec                       IN OUT NOCOPY WIP_Transaction_PUB.Res_Rec_Type
);

END WIP_Default_Res;

 

/
