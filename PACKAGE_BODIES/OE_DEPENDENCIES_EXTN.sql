--------------------------------------------------------
--  DDL for Package Body OE_DEPENDENCIES_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEPENDENCIES_EXTN" AS
/* $Header: OEXEDEPB.pls 120.1 2006/04/03 11:33:12 chhung noship $ */

--  Global constant holding the package name

G_PKG_NAME      	CONSTANT    VARCHAR2(30):='OE_Dependencies_Extn';


PROCEDURE   Load_Entity_Attributes
(   p_entity_code	IN  VARCHAR2
, x_extn_dep_tbl OUT NOCOPY Dep_Tbl_Type)

IS
l_index             NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    null;

/*
    -- In order to start using the package:
    -- 1)Increase the version number in the header line to a high value
    -- => Header: OEXEDEPB.pls 115.1000. This would prevent patches
    -- from over-writing this package in the future.
    -- 2)Included are some examples on how to enable/disable dependencies
    -- Please use these guidelines to edit dependencies as per your
    -- defaulting rules. Please note that:
    --     i) List of attributes is restricted to those in the earlier
    --        comments in this file.
    --     ii) Source attribute and dependent attribute should belong
    --        to the same entity!
    --        This API does not support dependencies across entities i.e.
    --        changing an attribute on order header will not result in
    --        a change to attributes on order line.
    -- 3)Uncomment this code and compile.

    oe_debug_pub.add('Enter OE_Dependencies_Extn.LOAD_ENTITY_ATTRIBUTES', 1);

    -- Initializing index value for pl/sql table. Ensure that the index
    -- value is incremented after setting each dependency record.
    l_index := 1;

    -- Dependencies for Order Header Entity
    IF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER THEN

       null;

       -- Sample Code for Disabling dependency of Invoice To on Ship To
       -- x_extn_dep_tbl(l_index).source_attribute := OE_HEADER_UTIL.G_SHIP_TO_ORG;
       -- x_extn_dep_tbl(l_index).dependent_attribute := OE_HEADER_UTIL.G_INVOICE_TO_ORG;
       -- x_extn_dep_tbl(l_index).enabled_flag := 'N';
       -- l_index := l_index + 1;

    -- Dependencies for Order Line Entity
    ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE THEN

       null;

       -- Sample Code for Disabling dependency of Invoice To on Ship To
       -- x_extn_dep_tbl(l_index).source_attribute := OE_LINE_UTIL.G_SHIP_TO_ORG;
       -- x_extn_dep_tbl(l_index).dependent_attribute := OE_LINE_UTIL.G_INVOICE_TO_ORG;
       -- x_extn_dep_tbl(l_index).enabled_flag := 'N';
       -- l_index := l_index + 1;

       -- Sample Code for adding dependency of Source Type on Item
       -- x_extn_dep_tbl(l_index).source_attribute := OE_LINE_UTIL.G_INVENTORY_ITEM;
       -- x_extn_dep_tbl(l_index).dependent_attribute := OE_LINE_UTIL.G_SOURCE_TYPE;
       -- x_extn_dep_tbl(l_index).enabled_flag := 'Y';
       -- l_index := l_index + 1;

    END IF;

    oe_debug_pub.add('Exit OE_Dependencies_Extn.LOAD_ENTITY_ATTRIBUTES', 1);
*/

EXCEPTION
        WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Load_Entity_Attributes'
                );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Load_Entity_Attributes;

END OE_Dependencies_Extn;

/
