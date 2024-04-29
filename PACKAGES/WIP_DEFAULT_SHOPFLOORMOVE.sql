--------------------------------------------------------
--  DDL for Package WIP_DEFAULT_SHOPFLOORMOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DEFAULT_SHOPFLOORMOVE" AUTHID CURRENT_USER AS
/* $Header: WIPDSFMS.pls 120.0.12010000.1 2008/07/24 05:18:24 appldev ship $ */

MOVE_BACKWARD                 CONSTANT NUMBER:=0;
MOVE_FORWARD                  CONSTANT NUMBER:=1;
VALID                         CONSTANT NUMBER:=0;

--  Procedure Attributes

PROCEDURE Attributes
(   p_ShopFloorMove_rec             IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
,   p_iteration                     IN  NUMBER := NULL
,   x_ShopFloorMove_rec         IN  OUT NOCOPY WIP_Transaction_PUB.Shopfloormove_Rec_Type
,   p_OSP_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
);

END WIP_Default_Shopfloormove;

/
