--------------------------------------------------------
--  DDL for Package Body MRP_ID_TO_VALUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_ID_TO_VALUE" AS
/* $Header: MRPSIDVB.pls 115.2 1999/12/13 14:38:50 pkm ship     $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Id_To_Value';

--  Procedure Get_Attr_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  Id_To_Value functions.
--
--  DO NOT REMOVE

PROCEDURE Get_Attr_Tbl
IS
I                             NUMBER:=0;
BEGIN

    FND_API.g_attr_tbl.DELETE;

--  START GEN attributes

--  Generator will append new attributes before end generate comment.
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'completion_locator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'organization';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'primary_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'project';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'schedule_group';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'task';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'wip_entity';
--  END GEN attributes

END Get_Attr_Tbl;

--  Prototypes for Id_To_Value functions.

--  START GEN Id_To_Value

--  Generator will append new prototypes before end generate comment.


FUNCTION Completion_Locator
(   p_completion_locator_id         IN  NUMBER
) RETURN VARCHAR2
IS
l_completion_locator          VARCHAR2(240) := NULL;
BEGIN

    IF p_completion_locator_id IS NOT NULL THEN

        --  SELECT  COMPLETION_LOCATOR
        --  INTO    l_completion_locator
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_completion_locator_id;

        NULL;

    END IF;

    RETURN l_completion_locator;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','completion_locator');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Completion_Locator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Completion_Locator;

FUNCTION Line
(   p_line_id                       IN  NUMBER
) RETURN VARCHAR2
IS
l_line                        VARCHAR2(240) := NULL;
BEGIN

    IF p_line_id IS NOT NULL THEN

        SELECT  LINE_CODE
        INTO    l_line
        FROM    WIP_LINES
        WHERE   LINE_ID = p_line_id;

    END IF;

    RETURN l_line;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line;

FUNCTION Organization
(   p_organization_id               IN  NUMBER
) RETURN VARCHAR2
IS
l_organization                VARCHAR2(240) := NULL;
BEGIN

    IF p_organization_id IS NOT NULL THEN

        SELECT  ORGANIZATION_CODE
        INTO    l_organization
        FROM    ORG_ORGANIZATION_DEFINITIONS
        WHERE   ORGANIZATION_ID = p_organization_id;

    END IF;

    RETURN l_organization;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Organization;

FUNCTION Primary_Item
(   p_primary_item_id               IN  NUMBER
) RETURN VARCHAR2
IS
l_primary_item                VARCHAR2(240) := NULL;
BEGIN

    IF p_primary_item_id IS NOT NULL THEN

        --  SELECT  PRIMARY_ITEM
        --  INTO    l_primary_item
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_primary_item_id;

        NULL;

    END IF;

    RETURN l_primary_item;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_item');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Primary_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Primary_Item;

FUNCTION Project
(   p_project_id                    IN  NUMBER
) RETURN VARCHAR2
IS
l_project                     VARCHAR2(240) := NULL;
BEGIN

    IF p_project_id IS NOT NULL THEN

        SELECT  PROJECT_NAME
        INTO    l_project
        FROM    MTL_PROJECT_V
        WHERE   PROJECT_ID = p_project_id;

    END IF;

    RETURN l_project;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','project');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Project'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Project;

FUNCTION Schedule_Group
(   p_schedule_group_id             IN  NUMBER
) RETURN VARCHAR2
IS
l_schedule_group              VARCHAR2(240) := NULL;
BEGIN

    IF p_schedule_group_id IS NOT NULL THEN

        SELECT  SCHEDULE_GROUP_NAME
        INTO    l_schedule_group
        FROM    WIP_SCHEDULE_GROUPS
        WHERE   SCHEDULE_GROUP_ID = p_schedule_group_id;

        NULL;

    END IF;

    RETURN l_schedule_group;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','schedule_group');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_Group'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Schedule_Group;

FUNCTION Task
(   p_task_id                       IN  NUMBER
) RETURN VARCHAR2
IS
l_task                        VARCHAR2(240) := NULL;
BEGIN

    IF p_task_id IS NOT NULL THEN

        --  SELECT  TASK
        --  INTO    l_task
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_task_id;

        NULL;

    END IF;

    RETURN l_task;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','task');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Task'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Task;

FUNCTION Wip_Entity
(   p_wip_entity_id                 IN  NUMBER
) RETURN VARCHAR2
IS
l_wip_entity                  VARCHAR2(240) := NULL;
BEGIN

    IF p_wip_entity_id IS NOT NULL THEN

        --  SELECT  WIP_ENTITY
        --  INTO    l_wip_entity
        --  FROM    DB_TABLE
        --  WHERE   DB_COLUMN = p_wip_entity_id;

        NULL;

    END IF;

    RETURN l_wip_entity;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','wip_entity');
            FND_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Wip_Entity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Wip_Entity;
--  END GEN Id_To_Value

END MRP_Id_To_Value;

/
