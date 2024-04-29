--------------------------------------------------------
--  DDL for Package Body MRP_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_GLOBALS" AS
/* $Header: MRPSGLBB.pls 115.2 99/07/16 12:37:08 porting ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Globals';

--  Procedure Get_Entities_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  entity constants.
--
--  DO NOT REMOVE

PROCEDURE Get_Entities_Tbl
IS
I                             NUMBER:=0;
BEGIN

    FND_API.g_entity_tbl.DELETE;

--  START GEN entities
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'ALL';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'FLOW_SCHEDULE';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'ASSIGNMENT_SET';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'ASSIGNMENT';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'SOURCING_RULE';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'RECEIVING_ORG';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'SHIPPING_ORG';
--  END GEN entities

END Get_Entities_Tbl;

--  Initialize control record.

FUNCTION Init_Control_Rec
(   p_operation                     IN  VARCHAR2
,   p_control_rec                   IN  Control_Rec_Type
)RETURN Control_Rec_Type
IS
l_control_rec                 Control_Rec_Type;
BEGIN

    IF p_control_rec.controlled_operation THEN

        RETURN p_control_rec;

    ELSIF p_operation = G_OPR_NONE OR p_operation IS NULL THEN

        l_control_rec.default_attributes:=  FALSE;
        l_control_rec.change_attributes :=  FALSE;
        l_control_rec.validate_entity	:=  FALSE;
        l_control_rec.write_to_DB	:=  FALSE;
        l_control_rec.process		:=  p_control_rec.process;
        l_control_rec.process_entity	:=  p_control_rec.process_entity;
        l_control_rec.request_category	:=  p_control_rec.request_category;
        l_control_rec.request_name	:=  p_control_rec.request_name;
        l_control_rec.clear_api_cache	:=  p_control_rec.clear_api_cache;
        l_control_rec.clear_api_requests:=  p_control_rec.clear_api_requests;

    ELSIF p_operation = G_OPR_CREATE THEN

        l_control_rec.default_attributes:=   TRUE;
        l_control_rec.change_attributes :=   FALSE;
        l_control_rec.validate_entity  :=   TRUE;
        l_control_rec.write_to_DB	:=   TRUE;
        l_control_rec.process		:=   TRUE;
        l_control_rec.process_entity	:=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	:=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;

    ELSIF p_operation = G_OPR_UPDATE THEN

        l_control_rec.default_attributes:=   FALSE;
        l_control_rec.change_attributes :=   TRUE;
        l_control_rec.validate_entity	:=   TRUE;
        l_control_rec.write_to_DB	:=   TRUE;
        l_control_rec.process		:=   TRUE;
        l_control_rec.process_entity	:=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	:=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;

    ELSIF p_operation = G_OPR_DELETE THEN

        l_control_rec.default_attributes:=   FALSE;
        l_control_rec.change_attributes :=   FALSE;
        l_control_rec.validate_entity	  :=   TRUE;
        l_control_rec.write_to_DB	  :=   TRUE;
        l_control_rec.process		  :=   TRUE;
        l_control_rec.process_entity	  :=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	  :=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;

    ELSE

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Init_Control_Rec'
            ,   'Invalid operation'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    RETURN l_control_rec;

END Init_Control_Rec;

--  Function Equal
--  Number comparison.

FUNCTION Equal
(   p_attribute1                    IN  NUMBER
,   p_attribute2                    IN  NUMBER
)RETURN BOOLEAN
IS
BEGIN

    RETURN ( p_attribute1 IS NULL AND p_attribute2 IS NULL ) OR
    	( p_attribute1 IS NOT NULL AND
    	  p_attribute2 IS NOT NULL AND
    	  p_attribute1 = p_attribute2 );

END Equal;

--  Varchar2 comparison.

FUNCTION Equal
(   p_attribute1                    IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
)RETURN BOOLEAN
IS
BEGIN

    RETURN ( p_attribute1 IS NULL AND p_attribute2 IS NULL ) OR
    	( p_attribute1 IS NOT NULL AND
    	  p_attribute2 IS NOT NULL AND
    	  p_attribute1 = p_attribute2 );

END Equal;

--  Date comparison.

FUNCTION Equal
(   p_attribute1                    IN  DATE
,   p_attribute2                    IN  DATE
)RETURN BOOLEAN
IS
BEGIN

    RETURN ( p_attribute1 IS NULL AND p_attribute2 IS NULL ) OR
    	( p_attribute1 IS NOT NULL AND
    	  p_attribute2 IS NOT NULL AND
    	  p_attribute1 = p_attribute2 );

END Equal;

END MRP_Globals;

/
