--------------------------------------------------------
--  DDL for Package IGS_SC_DATA_SEC_APIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SC_DATA_SEC_APIS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSC02S.pls 120.3 2005/07/18 22:57:05 appldev ship $ */

/******************************************************************

    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.

 Created By         : Don Shellito

 Date Created By    : April 8, 2003

 Purpose            : This package is to be used for the processing and
                      gathering of the security process for Oracle
                      Student System.

 remarks            : None

 Change History

Who             When           What
-----------------------------------------------------------
Don Shellito    08-Apr-2003    New Package created.
prbhardw	Jul 18, 2005   Added one more parameter in Update_Grant_Cond
			       to update condition number

******************************************************************/

-- -----------------------------------------------------------------
-- APIs for the inserting of data into security data model framework
-- -----------------------------------------------------------------
PROCEDURE Insert_Grant (p_api_version       IN NUMBER,
                        p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_grant_id          IN OUT NOCOPY igs_sc_grants.grant_id%TYPE,
                        p_function_id       IN igs_sc_grants.function_id%TYPE,
                        p_user_group_id     IN igs_sc_grants.user_group_id%TYPE,
                        p_obj_group_id      IN igs_sc_grants.obj_group_id%TYPE,
                        p_grant_name        IN igs_sc_grants.grant_name%TYPE,
                        p_grant_text        IN igs_sc_grants.grant_text%TYPE,
                        p_grant_select_flag IN igs_sc_grants.grant_select_flag%TYPE DEFAULT 'N',
                        p_grant_insert_flag IN igs_sc_grants.grant_insert_flag%TYPE DEFAULT 'N',
                        p_grant_update_flag IN igs_sc_grants.grant_update_flag%TYPE DEFAULT 'N',
                        p_grant_delete_flag IN igs_sc_grants.grant_delete_flag%TYPE DEFAULT 'N',
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_return_message    OUT NOCOPY VARCHAR2
                       );

PROCEDURE Insert_Grant_Cond (p_api_version       IN NUMBER,
                             p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_grant_id          IN igs_sc_grant_conds.grant_id%TYPE,
                             p_obj_attrib_id     IN igs_sc_grant_conds.obj_attrib_id%TYPE,
                             p_user_attrib_id    IN igs_sc_grant_conds.user_attrib_id%TYPE,
                             p_condition         IN igs_sc_grant_conds.condition%TYPE,
                             p_text_value        IN igs_sc_grant_conds.text_value%TYPE,
                             p_grant_cond_num    IN igs_sc_grant_conds.grant_cond_num%TYPE,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_return_message    OUT NOCOPY VARCHAR2
                            );

PROCEDURE Insert_Object_Group (p_api_version            IN NUMBER,
                               p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_commit                 IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_obj_group_id           IN OUT NOCOPY igs_sc_obj_groups.obj_group_id%TYPE,
                               p_obj_group_name         IN igs_sc_obj_groups.obj_group_name%TYPE ,
                               p_default_policy_type    IN igs_sc_obj_groups.default_policy_type%TYPE,
                               x_return_status          OUT NOCOPY VARCHAR2,
                               x_return_message         OUT NOCOPY VARCHAR2
                              );

PROCEDURE Insert_Object_Attr (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_obj_attrib_id     IN OUT NOCOPY igs_sc_obj_attribs.obj_attrib_id%TYPE,
                              p_obj_group_id      IN igs_sc_obj_attribs.obj_group_id%TYPE,
                              p_obj_attrib_name   IN igs_sc_obj_attribs.obj_attrib_name%TYPE,
			      p_active_flag       IN VARCHAR2 DEFAULT 'Y',
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
                             );

PROCEDURE Insert_Object_Attr_Method (p_api_version       IN NUMBER,
                                     p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     p_object_id         IN igs_sc_obj_att_mths.object_id%TYPE,
                                     p_obj_attrib_id     IN igs_sc_obj_att_mths.obj_attrib_id%TYPE,
                                     p_obj_attrib_type   IN igs_sc_obj_att_mths.obj_attrib_type%TYPE,
                                     p_static_type       IN igs_sc_obj_att_mths.static_type%TYPE,
                                     p_select_text       IN igs_sc_obj_att_mths.select_text%TYPE,
				     p_null_allow_flag   IN VARCHAR2 DEFAULT 'N',
				     p_call_from_lct	 IN VARCHAR2 DEFAULT 'N',
                                     x_return_status     OUT NOCOPY VARCHAR2,
                                     x_return_message    OUT NOCOPY VARCHAR2);

PROCEDURE Insert_Object_Func (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_function_id       IN OUT NOCOPY igs_sc_obj_functns.function_id%TYPE,
                              p_obj_group_id      IN igs_sc_obj_functns.obj_group_id%TYPE,
                              p_function_name     IN igs_sc_obj_functns.function_name%TYPE,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
                             );

PROCEDURE Insert_Object (p_api_version       IN NUMBER,
                         p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_object_id         IN OUT NOCOPY igs_sc_objects.object_id%TYPE,
                         p_obj_group_id      IN igs_sc_objects.obj_group_id%TYPE,
                         p_obj_name          IN fnd_objects.obj_name%TYPE ,
                         p_database_object_name   IN fnd_objects.database_object_name%TYPE ,
                         p_pk1_column_name   IN fnd_objects.pk1_column_name%TYPE ,
                         p_pk2_column_name   IN fnd_objects.pk2_column_name%TYPE ,
                         p_pk3_column_name   IN fnd_objects.pk3_column_name%TYPE ,
                         p_pk4_column_name   IN fnd_objects.pk4_column_name%TYPE ,
                         p_pk5_column_name   IN fnd_objects.pk5_column_name%TYPE ,
                         p_pk1_column_type   IN fnd_objects.pk1_column_type%TYPE ,
                         p_pk2_column_type   IN fnd_objects.pk2_column_type%TYPE ,
                         p_pk3_column_type   IN fnd_objects.pk3_column_type%TYPE ,
                         p_pk4_column_type   IN fnd_objects.pk4_column_type%TYPE ,
                         p_pk5_column_type   IN fnd_objects.pk5_column_type%TYPE ,
			 p_select_flag       IN VARCHAR2 DEFAULT 'Y',
			 p_insert_flag	     IN VARCHAR2 DEFAULT 'Y',
			 p_update_flag       IN VARCHAR2 DEFAULT 'Y',
			 p_delete_flag	     IN VARCHAR2 DEFAULT 'Y',
			 p_enforce_par_sec_flag IN VARCHAR2 DEFAULT 'N',
			 p_active_flag       IN VARCHAR2 DEFAULT 'Y',
                         x_return_status     OUT NOCOPY VARCHAR2,
                         x_return_message    OUT NOCOPY VARCHAR2
                        );


PROCEDURE Insert_User_Attr (p_api_version       IN NUMBER,
                            p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_user_attrib_id    IN OUT NOCOPY igs_sc_usr_attribs.user_attrib_id%TYPE,
                            p_user_attrib_name  IN igs_sc_usr_attribs.user_attrib_name%TYPE,
                            p_user_attrib_type  IN igs_sc_usr_attribs.user_attrib_type%TYPE,
                            p_static_type       IN igs_sc_usr_attribs.static_type%TYPE,
                            p_select_text       IN igs_sc_usr_attribs.select_text%TYPE,
       		            p_active_flag       IN VARCHAR2 DEFAULT 'Y',
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_message    OUT NOCOPY VARCHAR2
                           );

PROCEDURE Insert_Local_Role (
                      p_api_version       IN NUMBER,
                      p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_role_name               IN  VARCHAR2,
                      p_role_display_name       IN  VARCHAR2,
                      p_orig_system             IN  VARCHAR2,
                      p_orig_system_id          IN  NUMBER,
                      p_language                IN  VARCHAR2 DEFAULT NULL,
                      p_territory               IN  VARCHAR2 DEFAULT NULL,
                      p_role_description        IN  VARCHAR2 DEFAULT NULL,
                      p_notification_preference IN  VARCHAR2 DEFAULT 'MAILHTML',
                      p_email_address           IN  VARCHAR2 DEFAULT NULL,
                      p_fax                     IN  VARCHAR2 DEFAULT NULL,
                      p_status                  IN  VARCHAR2 DEFAULT 'ACTIVE',
                      p_expiration_date         IN  DATE DEFAULT NULL,
                      p_start_date              IN  DATE DEFAULT SYSDATE,
                      x_return_status     OUT NOCOPY VARCHAR2,
                      x_return_message    OUT NOCOPY VARCHAR2
) ;

PROCEDURE Insert_Local_User_Role (p_api_version         IN NUMBER,
                                  p_init_msg_list       IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                  p_commit              IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                  p_user_name           IN wf_local_user_roles.user_name%TYPE,
                                  p_role_name           IN wf_local_user_roles.role_name%TYPE,
                                  p_user_orig_system    IN wf_local_user_roles.user_orig_system%TYPE,
                                  p_user_orig_system_id IN wf_local_user_roles.user_orig_system_id%TYPE,
                                  p_role_orig_system    IN wf_local_user_roles.role_orig_system%TYPE,
                                  p_role_orig_system_id IN wf_local_user_roles.role_orig_system_id%TYPE,
                                  p_start_date          IN wf_local_user_roles.start_date%TYPE,
                                  p_expiration_date     IN wf_local_user_roles.expiration_date%TYPE,
                                  p_security_group_id   IN wf_local_user_roles.security_group_id%TYPE,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_return_message      OUT NOCOPY VARCHAR2
                                 );

-- -----------------------------------------------------------------
-- APIs for the updating of data into security data model framework
-- -----------------------------------------------------------------
PROCEDURE Update_Local_Role (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_role_name               IN  VARCHAR2,
                              p_role_display_name       IN  VARCHAR2,
                              p_orig_system             IN  VARCHAR2,
                              p_orig_system_id          IN  NUMBER,
                              p_language                IN  VARCHAR2 DEFAULT NULL,
                              p_territory               IN  VARCHAR2 DEFAULT NULL,
                              p_role_description        IN  VARCHAR2 DEFAULT NULL,
                              p_notification_preference IN  VARCHAR2 DEFAULT 'MAILHTML',
                              p_email_address           IN  VARCHAR2 DEFAULT NULL,
                              p_fax                     IN  VARCHAR2 DEFAULT NULL,
                              p_status                  IN  VARCHAR2 DEFAULT 'ACTIVE',
                              p_expiration_date         IN  DATE DEFAULT NULL,
                              p_start_date              IN  DATE DEFAULT SYSDATE,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
                             );

PROCEDURE Update_Local_User_Role (p_api_version       IN NUMBER,
                                   p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                   p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                   p_user_name           IN wf_local_user_roles.user_name%TYPE,
                                   p_role_name           IN wf_local_user_roles.role_name%TYPE,
                                   p_user_orig_system    IN wf_local_user_roles.user_orig_system%TYPE,
                                   p_user_orig_system_id IN wf_local_user_roles.user_orig_system_id%TYPE,
                                   p_role_orig_system    IN wf_local_user_roles.role_orig_system%TYPE,
                                   p_role_orig_system_id IN wf_local_user_roles.role_orig_system_id%TYPE,
                                   p_start_date          IN wf_local_user_roles.start_date%TYPE,
                                   p_expiration_date     IN wf_local_user_roles.expiration_date%TYPE,
                                   p_security_group_id   IN wf_local_user_roles.security_group_id%TYPE,
                                   x_return_status     OUT NOCOPY VARCHAR2,
                                   x_return_message    OUT NOCOPY VARCHAR2
                                  );

PROCEDURE Update_Grant (p_api_version       IN NUMBER,
                        p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_grant_id          IN igs_sc_grants.grant_id%TYPE,
                        p_function_id       IN igs_sc_grants.function_id%TYPE,
                        p_user_group_id     IN igs_sc_grants.user_group_id%TYPE,
                        p_grant_name        IN igs_sc_grants.grant_name%TYPE,
                        p_grant_text        IN igs_sc_grants.grant_text%TYPE,
                        p_grant_select_flag IN igs_sc_grants.grant_select_flag%TYPE DEFAULT 'N',
                        p_grant_insert_flag IN igs_sc_grants.grant_insert_flag%TYPE DEFAULT 'N',
                        p_grant_update_flag IN igs_sc_grants.grant_update_flag%TYPE DEFAULT 'N',
                        p_grant_delete_flag IN igs_sc_grants.grant_delete_flag%TYPE DEFAULT 'N',
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_return_message    OUT NOCOPY VARCHAR2
                       );

PROCEDURE Update_Grant_Cond (p_api_version         IN NUMBER,
                             p_init_msg_list       IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_commit              IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_grant_id            IN igs_sc_grant_conds.grant_id%TYPE,
                             p_obj_attrib_id       IN igs_sc_grant_conds.obj_attrib_id%TYPE,
                             p_user_attrib_id      IN igs_sc_grant_conds.user_attrib_id%TYPE,
                             p_condition           IN igs_sc_grant_conds.condition%TYPE,
                             p_text_value          IN igs_sc_grant_conds.text_value%TYPE,
                             p_grant_cond_num      IN igs_sc_grant_conds.grant_cond_num%TYPE,
			     p_old_grant_cond_num  IN igs_sc_grant_conds.grant_cond_num%TYPE DEFAULT 0,
                             x_return_status       OUT NOCOPY VARCHAR2,
                             x_return_message      OUT NOCOPY VARCHAR2
                            );

PROCEDURE Update_Object_Group (p_api_version            IN NUMBER,
                               p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_commit                 IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_obj_group_id           IN igs_sc_obj_groups.obj_group_id%TYPE,
                               p_obj_group_name         IN igs_sc_obj_groups.obj_group_name%TYPE ,
                               p_default_policy_type    IN igs_sc_obj_groups.default_policy_type%TYPE,
                               x_return_status          OUT NOCOPY VARCHAR2,
                               x_return_message         OUT NOCOPY VARCHAR2
                              );

PROCEDURE Update_Object_Attr_Method (p_api_version       IN NUMBER,
                                     p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     p_object_id         IN igs_sc_obj_att_mths.object_id%TYPE,
                                     p_obj_attrib_id     IN igs_sc_obj_att_mths.obj_attrib_id%TYPE,
                                     p_obj_attrib_type   IN igs_sc_obj_att_mths.obj_attrib_type%TYPE,
                                     p_static_type       IN igs_sc_obj_att_mths.static_type%TYPE,
                                     p_select_text       IN igs_sc_obj_att_mths.select_text%TYPE,
				     p_null_allow_flag   IN VARCHAR2 DEFAULT 'N',
				     p_call_from_lct	 IN VARCHAR2 DEFAULT 'N',
                                     x_return_status     OUT NOCOPY VARCHAR2,
                                     x_return_message    OUT NOCOPY VARCHAR2
                                    );

PROCEDURE Update_Object_Func (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_function_id       IN igs_sc_obj_functns.function_id%TYPE,
                              p_obj_group_id      IN igs_sc_obj_functns.obj_group_id%TYPE,
                              p_function_name     IN igs_sc_obj_functns.function_name%TYPE,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
                             );

PROCEDURE Update_Object_Attr (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_obj_attrib_id     IN igs_sc_obj_attribs.obj_attrib_id%TYPE,
                              p_obj_group_id      IN igs_sc_obj_attribs.obj_group_id%TYPE,
                              p_obj_attrib_name   IN igs_sc_obj_attribs.obj_attrib_name%TYPE,
			      p_active_flag       IN VARCHAR2 DEFAULT 'Y',
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
                             );

PROCEDURE Update_User_Attr (p_api_version       IN NUMBER,
                            p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_user_attrib_id    IN igs_sc_usr_attribs.user_attrib_id%TYPE,
                            p_user_attrib_name  IN igs_sc_usr_attribs.user_attrib_name%TYPE,
                            p_user_attrib_type  IN igs_sc_usr_attribs.user_attrib_type%TYPE,
                            p_static_type       IN igs_sc_usr_attribs.static_type%TYPE,
                            p_select_text       IN igs_sc_usr_attribs.select_text%TYPE,
              	            p_active_flag       IN igs_sc_usr_attribs.active_flag%TYPE,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_message    OUT NOCOPY VARCHAR2
                           );

PROCEDURE Update_Object (p_api_version       IN NUMBER,
                         p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_object_id         IN igs_sc_objects.object_id%TYPE,
                         p_obj_group_id      IN igs_sc_objects.obj_group_id%TYPE,
                         p_obj_name          IN fnd_objects.obj_name%TYPE ,
                         p_database_object_name   IN fnd_objects.database_object_name%TYPE ,
                         p_pk1_column_name   IN fnd_objects.pk1_column_name%TYPE ,
                         p_pk2_column_name   IN fnd_objects.pk2_column_name%TYPE ,
                         p_pk3_column_name   IN fnd_objects.pk3_column_name%TYPE ,
                         p_pk4_column_name   IN fnd_objects.pk4_column_name%TYPE ,
                         p_pk5_column_name   IN fnd_objects.pk5_column_name%TYPE ,
                         p_pk1_column_type   IN fnd_objects.pk1_column_type%TYPE ,
                         p_pk2_column_type   IN fnd_objects.pk2_column_type%TYPE ,
                         p_pk3_column_type   IN fnd_objects.pk3_column_type%TYPE ,
                         p_pk4_column_type   IN fnd_objects.pk4_column_type%TYPE ,
                         p_pk5_column_type   IN fnd_objects.pk5_column_type%TYPE ,
			 p_select_flag       IN VARCHAR2 DEFAULT 'Y',
			 p_insert_flag	     IN VARCHAR2 DEFAULT 'Y',
			 p_update_flag       IN VARCHAR2 DEFAULT 'Y',
			 p_delete_flag	     IN VARCHAR2 DEFAULT 'Y',
			 p_enforce_par_sec_flag IN VARCHAR2 DEFAULT 'N',
			 p_active_flag       IN VARCHAR2 DEFAULT 'Y',
                         x_return_status     OUT NOCOPY VARCHAR2,
                         x_return_message    OUT NOCOPY VARCHAR2
                        );
-- -----------------------------------------------------------------
-- APIs for the deleting of data into security data model framework
-- -----------------------------------------------------------------
PROCEDURE Delete_Object_Group (p_api_version       IN NUMBER,
                               p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_obj_group_id      IN igs_sc_obj_groups.obj_group_id%TYPE,
                               x_return_status     OUT NOCOPY VARCHAR2,
                               x_return_message    OUT NOCOPY VARCHAR2
                              );

PROCEDURE Delete_Object (p_api_version       IN NUMBER,
                         p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_obj_group_id      IN igs_sc_objects.obj_group_id%TYPE,
                         p_object_id         IN igs_sc_objects.object_id%TYPE,
                         x_return_status     OUT NOCOPY VARCHAR2,
                         x_return_message    OUT NOCOPY VARCHAR2
                        );

PROCEDURE Delete_Object_Attr (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_obj_attrib_id     IN igs_sc_obj_attribs.obj_attrib_id%TYPE,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
                             );

PROCEDURE Delete_Object_Attr_Method (p_api_version       IN NUMBER,
                                     p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     p_object_id         IN igs_sc_obj_att_mths.object_id%TYPE,
                                     p_obj_attrib_id     IN igs_sc_obj_att_mths.obj_attrib_id%TYPE,
                                     x_return_status     OUT NOCOPY VARCHAR2,
                                     x_return_message    OUT NOCOPY VARCHAR2
                                    );

PROCEDURE Delete_Object_Func (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_function_id       IN igs_sc_obj_functns.function_id%TYPE,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
                             );

PROCEDURE Delete_Object_Attr_Val (p_api_version       IN NUMBER,
                                  p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                  p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                  p_object_id         IN igs_sc_obj_att_mths.object_id%TYPE,
                                  p_obj_attrib_id     IN igs_sc_obj_att_mths.obj_attrib_id%TYPE,
                                  x_return_status     OUT NOCOPY VARCHAR2,
                                  x_return_message    OUT NOCOPY VARCHAR2
                                 );

PROCEDURE Delete_User_Attr (p_api_version       IN NUMBER,
                            p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_user_attrib_id    IN igs_sc_usr_attribs.user_attrib_id%TYPE,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_message    OUT NOCOPY VARCHAR2
                           );

PROCEDURE Delete_User_Attr_Val (p_api_version       IN NUMBER,
                                p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                p_user_attrib_id    IN igs_sc_usr_attribs.user_attrib_id%TYPE,
                                p_user_id           IN NUMBER,
                                x_return_status     OUT NOCOPY VARCHAR2,
                                x_return_message    OUT NOCOPY VARCHAR2
                               );

PROCEDURE Delete_Grant (p_api_version       IN NUMBER,
                        p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_grant_id          IN igs_sc_grants.grant_id%TYPE,
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_return_message    OUT NOCOPY VARCHAR2
                       );

PROCEDURE Delete_Grant_Cond (p_api_version       IN NUMBER,
                             p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_grant_id          IN igs_sc_grant_conds.grant_id%TYPE,
                             p_grant_cond_num    IN igs_sc_grant_conds.grant_cond_num%TYPE,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_return_message    OUT NOCOPY VARCHAR2
                            );

PROCEDURE Delete_Local_Role (p_api_version       IN NUMBER,
                             p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_return_message    OUT NOCOPY VARCHAR2
                            );

PROCEDURE Delete_Local_User_Role (p_api_version       IN NUMBER,
                                  p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                  p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                  x_return_status     OUT NOCOPY VARCHAR2,
                                  x_return_message    OUT NOCOPY VARCHAR2
                                 );
-- -----------------------------------------------------------------
-- Other APIs to be used for Security purposes.
-- -----------------------------------------------------------------
PROCEDURE Lock_Grant (p_api_version       IN NUMBER,
                      p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_grant_id          IN igs_sc_grants.grant_id%TYPE,
                      x_return_status     OUT NOCOPY VARCHAR2,
                      x_return_message    OUT NOCOPY VARCHAR2
                     );

PROCEDURE Unlock_Grant (p_api_version       IN NUMBER,
                        p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_grant_id          IN igs_sc_grants.grant_id%TYPE,
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_return_message    OUT NOCOPY VARCHAR2
                       );

FUNCTION Is_Grant_Locked (p_grant_id   IN igs_sc_grants.grant_id%TYPE) RETURN VARCHAR2;

PROCEDURE Lock_All_Grants(
   errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
   retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
   p_obj_group_id     IN  igs_sc_obj_groups.obj_group_id%TYPE
) ;
PROCEDURE  Unlock_All_Grants(
   errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
   retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
   p_obj_group_id     IN  igs_sc_obj_groups.obj_group_id%TYPE
) ;

PROCEDURE Populate_User_Attribs(
   errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
   retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
   p_all_attribs      IN  VARCHAR2
) ;

PROCEDURE enable_policy (
  p_database_object_name IN VARCHAR2 );

PROCEDURE enable_upgrade_mode (
  p_api_version       IN NUMBER,
  p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_obj_group_id      IN igs_sc_obj_groups.obj_group_id%TYPE,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_data          OUT NOCOPY VARCHAR2
);


PROCEDURE change_seq ;

PROCEDURE Generate_SQL_file(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  x_return_status     OUT  NOCOPY VARCHAR2,
  x_msg_count         OUT  NOCOPY NUMBER,
  x_msg_data          OUT  NOCOPY VARCHAR2,
  p_dirpath           IN   VARCHAR2,
  p_in_file_name      IN   VARCHAR2,
  p_out_file_name     IN   VARCHAR2
);

FUNCTION get_obj_name (
  p_obj_id IN fnd_objects.object_id%TYPE )
RETURN VARCHAR2;

END IGS_SC_DATA_SEC_APIS_PKG;

 

/
