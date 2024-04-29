--------------------------------------------------------
--  DDL for Package JTF_TTY_GEO_TERRGP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_GEO_TERRGP" AUTHID CURRENT_USER AS
/* $Header: jtftggps.pls 120.2 2005/09/23 16:24:21 jradhakr ship $ */
--    Start of Comments
--    PURPOSE
--      For handling Geography Territor Groups, like delete,create,update
--
--    NOTES
--      ORACLE INTERNAL USE ONLY: NOT for customer use
--
--    HISTORY
--      06/02/02    SGKUMAR  Created
--      11/09/04    SGKUMAR  Added procedure replace_geo_terr_rsc for 3889970
--    End of Comments
----

PROCEDURE POPULATE_SELF_SRV_SCHEMA (p_terr_id IN NUMBER
                                  , x_return_status     OUT NOCOPY VARCHAR2
                                  , x_msg_count         OUT NOCOPY VARCHAR2
                                  , x_msg_data          OUT NOCOPY VARCHAR2);

PROCEDURE delete_terrgp(p_terr_gp_id IN NUMBER);
PROCEDURE add_geo_to_grp(p_terr_gp_id IN NUMBER,
                         p_geo_id_from IN NUMBER,
                         p_geo_id_to IN NUMBER,
                         p_operator IN VARCHAR2,
                         p_geo_type IN VARCHAR2,
                         p_user_id   IN NUMBER);
PROCEDURE create_grp_geo_terr(p_terr_gp_id IN NUMBER,
                             p_user_id   IN NUMBER);
PROCEDURE delete_geos_from_terrs(p_terr_gp_id IN NUMBER);
PROCEDURE delete_geo_from_grp(p_terr_gp_id IN NUMBER);
PROCEDURE update_geo_grp_assignments (p_terr_gp_id IN NUMBER);
PROCEDURE assign_geo_terr(p_territory_id IN NUMBER,
                               p_resource_id IN NUMBER,
                               p_rsc_group_id IN NUMBER,
                               p_rsc_role_code IN VARCHAR2);
PROCEDURE delete_geo_terr_rsc (p_territory_id IN NUMBER,
                               p_resource_id IN NUMBER,
                               p_rsc_group_id IN NUMBER,
                               p_rsc_role_code IN VARCHAR2);

PROCEDURE replace_geo_terr_rsc(p_territory_id IN NUMBER,
                               p_new_owner_resource_id IN NUMBER,
                               p_rsc_group_id IN NUMBER,
                               p_rsc_role_code IN VARCHAR2,
                               p_replaced_owner_resource_id IN NUMBER);
end JTF_TTY_GEO_TERRGP;

 

/
