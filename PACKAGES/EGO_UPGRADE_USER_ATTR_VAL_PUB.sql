--------------------------------------------------------
--  DDL for Package EGO_UPGRADE_USER_ATTR_VAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_UPGRADE_USER_ATTR_VAL_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOUPGAS.pls 115.0 2004/03/19 06:49:33 ansubram noship $ */



                          ----------------
                          -- Procedures --
                          ----------------

/*
 * Upgrade_Cat_User_Attrs_Data
 * ----------------------------
 * This procedure defaults the attributes for all the categories
 * in the default category set of a functional area.
 * p_functional_area_id is the functional area whose default
 * category set the activity is for.
 * p_attr_group_type is the attribute group type we process.
 * p_attr_group_name is the specific attribute group that will be
 * processed. If p_attr_group_name is null we process all attribute groups
 * associated with the attribute group type.
 */
PROCEDURE Upgrade_Cat_User_Attrs_Data
(
        p_api_version                   IN  NUMBER DEFAULT 1.0
       ,p_functional_area_id            IN  NUMBER
       ,p_attr_group_name               IN  VARCHAR2 DEFAULT NULL
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);


END EGO_UPGRADE_USER_ATTR_VAL_PUB;


 

/
