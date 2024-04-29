--------------------------------------------------------
--  DDL for Package JTF_TASK_OBJECT_MIGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_OBJECT_MIGRATION_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptkjs.pls 115.0 2003/04/08 23:41:24 cjang noship $ */

    ----------------------------------------------------------------------------------------
    -- PROCEDURE update_object_name():
    -- Disclaimer:
    --    This procedure must be used only when the definition of object code is changed
    --    in JTF_OBJECTS_B table. For all other cases, it is not recommended to use this
    --    procedure.
    -- Description
    --    This procedure updates object_name in JTF_TASKS_B and JTF_TASK_REFERENCES_B
    --    according to the object code passed.
    --    If the object name is greater than 80 bytes, the name is truncated to 80 bytes.
    -- Major Parameter:
    --    p_object_code : The object code of which the definition is changed.
    ----------------------------------------------------------------------------------------
    PROCEDURE update_object_name(p_object_code   IN         VARCHAR2
                                ,p_init_msg_list IN         VARCHAR2 DEFAULT fnd_api.g_false
                                ,p_commit        IN         VARCHAR2 DEFAULT fnd_api.g_false
                                ,x_msg_count     OUT NOCOPY NUMBER
                                ,x_msg_data      OUT NOCOPY VARCHAR2
                                ,x_return_status OUT NOCOPY VARCHAR2);

END JTF_TASK_OBJECT_MIGRATION_PUB;

 

/
