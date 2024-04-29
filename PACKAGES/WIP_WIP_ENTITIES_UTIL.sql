--------------------------------------------------------
--  DDL for Package WIP_WIP_ENTITIES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WIP_ENTITIES_UTIL" AUTHID CURRENT_USER AS
/* $Header: WIPUWENS.pls 115.7 2002/12/01 18:13:12 simishra ship $ */

--  Attributes global constants

G_CREATED_BY                  CONSTANT NUMBER := 1;
G_CREATION_DATE               CONSTANT NUMBER := 2;
G_DESCRIPTION                 CONSTANT NUMBER := 3;
G_ENTITY_TYPE                 CONSTANT NUMBER := 4;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 5;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 6;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 7;
G_ORGANIZATION                CONSTANT NUMBER := 8;
G_PRIMARY_ITEM                CONSTANT NUMBER := 9;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 10;
G_PROGRAM                     CONSTANT NUMBER := 11;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 12;
G_REQUEST                     CONSTANT NUMBER := 13;
G_WIP_ENTITY                  CONSTANT NUMBER := 14;
G_WIP_ENTITY_NAME             CONSTANT NUMBER := 15;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 16;


--  Function Complete_Record

FUNCTION Complete_Record
(   p_Wip_Entities_rec              IN  WIP_Work_Order_PUB.Wip_Entities_Rec_Type
,   p_old_Wip_Entities_rec          IN  WIP_Work_Order_PUB.Wip_Entities_Rec_Type
) RETURN WIP_Work_Order_PUB.Wip_Entities_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Wip_Entities_rec              IN  WIP_Work_Order_PUB.Wip_Entities_Rec_Type
) RETURN WIP_Work_Order_PUB.Wip_Entities_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Wip_Entities_rec              IN  WIP_Work_Order_PUB.Wip_Entities_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Wip_Entities_rec              IN  WIP_Work_Order_PUB.Wip_Entities_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_wip_entity_id                 IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_wip_entity_id                 IN  NUMBER
) RETURN WIP_Work_Order_PUB.Wip_Entities_Rec_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Wip_Entities_rec              IN  WIP_Work_Order_PUB.Wip_Entities_Rec_Type
,   x_Wip_Entities_rec              OUT NOCOPY WIP_Work_Order_PUB.Wip_Entities_Rec_Type
);

END WIP_Wip_Entities_Util;

 

/
