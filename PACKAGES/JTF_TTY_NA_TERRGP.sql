--------------------------------------------------------
--  DDL for Package JTF_TTY_NA_TERRGP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_NA_TERRGP" AUTHID CURRENT_USER AS
/* $Header: jtfttgps.pls 120.2 2005/08/21 23:22:48 spai ship $ */
--    Start of Comments
--    PURPOSE
--      Custom Assignment API
--
--    NOTES
--      ORACLE INTERNAL USE ONLY: NOT for customer use
--
--    HISTORY
--      03/18/02    SGKUMAR  Created
--      03/20/02    SGKUMAR  Created procedure insert_qualifiers
--      03/20/02    SGKUMAR  Created procedure set_winners
--      07/08/03    SGKUMAR  Created procedure log_event
--      04/19/05    JRADHAKR Added procedure create_acct_mappings
--                           to fix bug 3981210
--    End of Comments
----
TYPE mytabletype  IS TABLE OF NUMBER;
TYPE mytabletypev IS TABLE OF VARCHAR2(60);


PROCEDURE delete_terrgp(p_terr_gp_id IN NUMBER);
PROCEDURE delete_terrgp_owners_roles(p_terr_gp_id IN NUMBER);
PROCEDURE terrgp_define_role(p_terr_gp_id IN NUMBER,
                             p_terr_gp_role_id IN NUMBER,
                             p_user_id IN NUMBER,
                             p_role_code IN VARCHAR2);
PROCEDURE terrgp_create_access(p_terr_gp_id IN NUMBER,
                             p_terr_gp_role_id IN NUMBER,
                             p_access_type IN VARCHAR2,
                             p_access_code IN VARCHAR2,
                             p_user_id IN NUMBER);
PROCEDURE terrgp_define_interest(p_terr_gp_role_id IN NUMBER,
                             p_interest_type_id IN NUMBER,
                             p_cat_set_id IN NUMBER,
                             p_cat_enabled_flag IN VARCHAR2,
                             p_user_id IN NUMBER);
PROCEDURE enter_terrgp_details(p_terr_gp_id IN NUMBER,
                             p_terr_gp_name IN VARCHAR2,
                             p_description IN VARCHAR2,
                             p_rank IN NUMBER,
                             p_from_date IN DATE,
                             p_end_date IN DATE,
                             p_terr_id IN NUMBER,
                             p_user_id IN NUMBER,
                             p_matching_rule_code IN VARCHAR2 DEFAULT '1',
                             p_workflow_item_type IN VARCHAR2 DEFAULT NULL,
                             p_action_type IN VARCHAR2 DEFAULT 'INSERT',
                             p_catch_all_user_id IN NUMBER,
                             p_num_winners IN NUMBER,
                             p_generate_na_flag IN VARCHAR2,
                             p_group_type IN VARCHAR2 DEFAULT 'NAMED_ACCOUNT');
PROCEDURE add_orgs_to_terrgp(p_terr_gp_id IN NUMBER,
                             p_party_id IN NUMBER,
                             p_resource_id IN NUMBER,
                             p_role_id IN NUMBER,
                             p_user_id IN NUMBER,
                             p_rsc_group_id IN NUMBER);
PROCEDURE terrgp_define_access(p_terr_gp_id IN NUMBER,
                             p_terr_gp_role_id IN NUMBER,
                             p_role_code IN VARCHAR2,
                             p_access_type IN VARCHAR2,
                             p_user_id IN NUMBER,
                             p_interest_type_id IN NUMBER DEFAULT NULL);
PROCEDURE terrgp_assign_owners(p_terr_gp_id IN NUMBER,
                             p_rsc_gp_id IN NUMBER,
                             p_resource_id IN NUMBER,
                             p_role_code IN VARCHAR2,
                             p_user_id IN NUMBER,
                             p_resource_type IN VARCHAR2 DEFAULT 'RS_EMPLOYEE');
PROCEDURE get_site_type(p_party_id IN NUMBER,
                             x_party_type OUT NOCOPY VARCHAR2);
PROCEDURE create_tgp_named_account(p_terr_gp_id IN NUMBER,
                                p_party_id   IN NUMBER,
                                p_user_id    IN NUMBER,
                                x_gp_acct_id OUT NOCOPY NUMBER);
PROCEDURE delete_tgp_named_account(p_terr_gp_id IN NUMBER,
                                p_party_id   IN NUMBER,
                                p_tga_id    IN NUMBER);
PROCEDURE delete_assign_accts(p_terr_gp_id IN NUMBER,
                               p_resource_id IN NUMBER,
                               p_group_id IN NUMBER,
                               p_role_code IN VARCHAR2);
PROCEDURE assign_accts(p_terr_gp_id IN NUMBER,
                               p_resource_id IN NUMBER,
                               p_group_id IN NUMBER,
                               p_role_code IN VARCHAR2,
                               p_action_type IN VARCHAR2,
                                p_user_id   IN NUMBER);
PROCEDURE assign_acct(p_terr_gp_id IN NUMBER,
                               p_terr_gp_acct_id IN NUMBER,
                               p_resource_id IN NUMBER,
                               p_group_id IN NUMBER,
                               p_role_code IN VARCHAR2,
                               p_action_type IN VARCHAR2,
                               p_user_id   IN NUMBER);

PROCEDURE sum_accts(p_user_id IN NUMBER);
PROCEDURE sum_owner_accts(p_user_id IN NUMBER,
                          p_terr_gp_id IN NUMBER,
                          p_action_type IN VARCHAR2);
PROCEDURE sum_res_gp_accts(p_user_id IN NUMBER,
                           p_resource_id IN NUMBER,
                           p_rsc_group_id IN NUMBER);
PROCEDURE process_assign_accts(p_terr_gp_id IN NUMBER,
                               p_DownerRsc  IN VARCHAR2,
                               p_NownerRsc  IN VARCHAR2,
                               p_DownerGrp  IN VARCHAR2,
                               p_NownerGrp  IN VARCHAR2,
                               p_DownerRole IN VARCHAR2,
                               p_NownerRole IN VARCHAR2
                               );
PROCEDURE generateNumList(
                         SourceStr IN VARCHAR2,
                         TargetTab OUT NOCOPY mytabletype
                       );

 PROCEDURE generateStrList(
                         SourceStr IN VARCHAR2,
                         TargetTab OUT NOCOPY mytabletypev
                       );

PROCEDURE check_hierarchy(x_hierarchy_status OUT NOCOPY VARCHAR2,
                                p_group_id1   IN VARCHAR2,
                                p_group_id2    IN VARCHAR2);
PROCEDURE sum_rm_bin(x_return_status         OUT NOCOPY VARCHAR2,
                          x_error_message         OUT NOCOPY VARCHAR2);

PROCEDURE create_acct_mappings(p_acct_id IN NUMBER,
                               p_party_id   IN NUMBER,
                               p_user_id   IN NUMBER);

PROCEDURE log_event(p_object_id IN NUMBER,
                    p_action_type IN VARCHAR2,
                    p_from_where IN VARCHAR2,
                    p_object_type IN VARCHAR2,
                    p_user_id IN NUMBER);

PROCEDURE delete_bulk_TGA(p_tga_id_str     IN VARCHAR2,
                          p_terr_gp_id_str IN VARCHAR2,
                          p_named_acct_id_str IN VARCHAR2,
                          p_change_type    IN VARCHAR2,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2);

END JTF_TTY_NA_TERRGP;

 

/
