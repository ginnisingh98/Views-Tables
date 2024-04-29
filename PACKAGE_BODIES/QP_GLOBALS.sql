--------------------------------------------------------
--  DDL for Package Body QP_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_GLOBALS" AS
/* $Header: QPXSGLBB.pls 120.1 2005/07/15 15:41:02 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Globals';

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
    FND_API.g_entity_tbl(I).name  := 'PRICE_LIST';
    I := I + 1;
    FND_API.g_entity_tbl(I).name  := 'PRICE_LIST_LINE';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'MODIFIER_LIST';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'MODIFIERS';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'QUALIFIERS';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'PRICING_ATTR';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'QUALIFIER_RULES';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'LINE_PRICING_PATTR';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'FORMULA';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'FORMULA_LINES';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'LIMITS';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'LIMIT_ATTRS';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'LIMIT_BALANCES';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'CURR_LISTS';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'CURR_DETAILS';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'CON';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'SEG';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'PTE';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'RQT';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'SSC';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'PSG';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'SOU';
    I := I + 1;
    FND_API.g_entity_tbl(I).name   := 'FNA';
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
        l_control_rec.check_security    :=  FALSE;
        l_control_rec.validate_entity	:=  FALSE;
        l_control_rec.write_to_DB	:=  FALSE;
        l_control_rec.process		:=  p_control_rec.process;
        l_control_rec.process_entity	:=  p_control_rec.process_entity;
        l_control_rec.request_category	:=  p_control_rec.request_category;
        l_control_rec.request_name	:=  p_control_rec.request_name;
        l_control_rec.clear_api_cache	:=  p_control_rec.clear_api_cache;
        l_control_rec.clear_api_requests:=  p_control_rec.clear_api_requests;
        l_control_rec.called_from_ui    :=  p_control_rec.called_from_ui;

    ELSIF p_operation = G_OPR_CREATE THEN

        l_control_rec.default_attributes:=   TRUE;
        l_control_rec.change_attributes :=   FALSE;
        l_control_rec.check_security    :=  TRUE;
        l_control_rec.validate_entity  :=   TRUE;
        l_control_rec.write_to_DB	:=   TRUE;
        l_control_rec.process		:=   TRUE;
        l_control_rec.process_entity	:=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	:=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;
        l_control_rec.called_from_ui    :=  p_control_rec.called_from_ui;

    ELSIF p_operation = G_OPR_UPDATE THEN

        l_control_rec.default_attributes:=   FALSE;
        l_control_rec.change_attributes :=   TRUE;
        l_control_rec.check_security    :=  TRUE;
        l_control_rec.validate_entity	:=   TRUE;
        l_control_rec.write_to_DB	:=   TRUE;
        l_control_rec.process		:=   TRUE;
        l_control_rec.process_entity	:=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	:=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;
        l_control_rec.called_from_ui    :=  p_control_rec.called_from_ui;

    ELSIF p_operation = G_OPR_DELETE THEN

        l_control_rec.default_attributes:=   FALSE;
        l_control_rec.change_attributes :=   FALSE;
        l_control_rec.check_security    :=  TRUE;
        l_control_rec.validate_entity	  :=   TRUE;
        l_control_rec.write_to_DB	  :=   TRUE;
        l_control_rec.process		  :=   TRUE;
        l_control_rec.process_entity	  :=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	  :=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;
        l_control_rec.called_from_ui    :=  p_control_rec.called_from_ui;

    ELSE

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
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

END QP_Globals;

/
