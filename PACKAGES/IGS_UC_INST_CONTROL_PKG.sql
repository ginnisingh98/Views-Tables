--------------------------------------------------------
--  DDL for Package IGS_UC_INST_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_INST_CONTROL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI20S.pls 115.5 2003/07/10 13:39:47 smaddali noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_inst_type                         IN     VARCHAR2,
    x_inst_short_name                   IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_full_name                    IN     VARCHAR2,
    x_switchboard_tel_no                IN     VARCHAR2,
    x_decision_cards                    IN     VARCHAR2,
    x_record_cards                      IN     VARCHAR2,
    x_labels                            IN     VARCHAR2,
    x_weekly_mov_list_seq               IN     VARCHAR2,
    x_weekly_mov_paging                 IN     VARCHAR2,
    x_form_seq                          IN     VARCHAR2,
    x_ebl_required                      IN     VARCHAR2,
    x_ebl_media_1or2                    IN     VARCHAR2,
    x_ebl_media_3                       IN     VARCHAR2,
    x_ebl_1or2_merged                   IN     VARCHAR2,
    x_ebl_1or2_board_group              IN     VARCHAR2,
    x_ebl_3_board_group                 IN     VARCHAR2,
    x_ebl_nc_app                        IN     VARCHAR2,
    x_ebl_major_key1                    IN     VARCHAR2,
    x_ebl_major_key2                    IN     VARCHAR2,
    x_ebl_major_key3                    IN     VARCHAR2,
    x_ebl_minor_key1                    IN     VARCHAR2,
    x_ebl_minor_key2                    IN     VARCHAR2,
    x_ebl_minor_key3                    IN     VARCHAR2,
    x_ebl_final_key                     IN     VARCHAR2,
    x_odl1                              IN     VARCHAR2,
    x_odl1a                             IN     VARCHAR2,
    x_odl2                              IN     VARCHAR2,
    x_odl3                              IN     VARCHAR2,
    x_odl_summer                        IN     VARCHAR2,
    x_odl_route_b                       IN     VARCHAR2,
    x_monthly_seq                       IN     VARCHAR2,
    x_monthly_paper                     IN     VARCHAR2,
    x_monthly_page                      IN     VARCHAR2,
    x_monthly_type                      IN     VARCHAR2,
    x_june_list_seq                     IN     VARCHAR2,
    x_june_labels                       IN     VARCHAR2,
    x_june_num_labels                   IN     VARCHAR2,
    x_course_analysis                   IN     VARCHAR2,
    x_campus_used                       IN     VARCHAR2,
    x_d3_doc_required                   IN     VARCHAR2,
    x_clearing_accept_copy_form         IN     VARCHAR2,
    x_online_message                    IN     VARCHAR2,
    x_ethnic_list_seq                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_starx				IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_inst_type                         IN     VARCHAR2,
    x_inst_short_name                   IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_full_name                    IN     VARCHAR2,
    x_switchboard_tel_no                IN     VARCHAR2,
    x_decision_cards                    IN     VARCHAR2,
    x_record_cards                      IN     VARCHAR2,
    x_labels                            IN     VARCHAR2,
    x_weekly_mov_list_seq               IN     VARCHAR2,
    x_weekly_mov_paging                 IN     VARCHAR2,
    x_form_seq                          IN     VARCHAR2,
    x_ebl_required                      IN     VARCHAR2,
    x_ebl_media_1or2                    IN     VARCHAR2,
    x_ebl_media_3                       IN     VARCHAR2,
    x_ebl_1or2_merged                   IN     VARCHAR2,
    x_ebl_1or2_board_group              IN     VARCHAR2,
    x_ebl_3_board_group                 IN     VARCHAR2,
    x_ebl_nc_app                        IN     VARCHAR2,
    x_ebl_major_key1                    IN     VARCHAR2,
    x_ebl_major_key2                    IN     VARCHAR2,
    x_ebl_major_key3                    IN     VARCHAR2,
    x_ebl_minor_key1                    IN     VARCHAR2,
    x_ebl_minor_key2                    IN     VARCHAR2,
    x_ebl_minor_key3                    IN     VARCHAR2,
    x_ebl_final_key                     IN     VARCHAR2,
    x_odl1                              IN     VARCHAR2,
    x_odl1a                             IN     VARCHAR2,
    x_odl2                              IN     VARCHAR2,
    x_odl3                              IN     VARCHAR2,
    x_odl_summer                        IN     VARCHAR2,
    x_odl_route_b                       IN     VARCHAR2,
    x_monthly_seq                       IN     VARCHAR2,
    x_monthly_paper                     IN     VARCHAR2,
    x_monthly_page                      IN     VARCHAR2,
    x_monthly_type                      IN     VARCHAR2,
    x_june_list_seq                     IN     VARCHAR2,
    x_june_labels                       IN     VARCHAR2,
    x_june_num_labels                   IN     VARCHAR2,
    x_course_analysis                   IN     VARCHAR2,
    x_campus_used                       IN     VARCHAR2,
    x_d3_doc_required                   IN     VARCHAR2,
    x_clearing_accept_copy_form         IN     VARCHAR2,
    x_online_message                    IN     VARCHAR2,
    x_ethnic_list_seq                   IN     VARCHAR2,
    x_starx				IN     VARCHAR2  DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_inst_type                         IN     VARCHAR2,
    x_inst_short_name                   IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_full_name                    IN     VARCHAR2,
    x_switchboard_tel_no                IN     VARCHAR2,
    x_decision_cards                    IN     VARCHAR2,
    x_record_cards                      IN     VARCHAR2,
    x_labels                            IN     VARCHAR2,
    x_weekly_mov_list_seq               IN     VARCHAR2,
    x_weekly_mov_paging                 IN     VARCHAR2,
    x_form_seq                          IN     VARCHAR2,
    x_ebl_required                      IN     VARCHAR2,
    x_ebl_media_1or2                    IN     VARCHAR2,
    x_ebl_media_3                       IN     VARCHAR2,
    x_ebl_1or2_merged                   IN     VARCHAR2,
    x_ebl_1or2_board_group              IN     VARCHAR2,
    x_ebl_3_board_group                 IN     VARCHAR2,
    x_ebl_nc_app                        IN     VARCHAR2,
    x_ebl_major_key1                    IN     VARCHAR2,
    x_ebl_major_key2                    IN     VARCHAR2,
    x_ebl_major_key3                    IN     VARCHAR2,
    x_ebl_minor_key1                    IN     VARCHAR2,
    x_ebl_minor_key2                    IN     VARCHAR2,
    x_ebl_minor_key3                    IN     VARCHAR2,
    x_ebl_final_key                     IN     VARCHAR2,
    x_odl1                              IN     VARCHAR2,
    x_odl1a                             IN     VARCHAR2,
    x_odl2                              IN     VARCHAR2,
    x_odl3                              IN     VARCHAR2,
    x_odl_summer                        IN     VARCHAR2,
    x_odl_route_b                       IN     VARCHAR2,
    x_monthly_seq                       IN     VARCHAR2,
    x_monthly_paper                     IN     VARCHAR2,
    x_monthly_page                      IN     VARCHAR2,
    x_monthly_type                      IN     VARCHAR2,
    x_june_list_seq                     IN     VARCHAR2,
    x_june_labels                       IN     VARCHAR2,
    x_june_num_labels                   IN     VARCHAR2,
    x_course_analysis                   IN     VARCHAR2,
    x_campus_used                       IN     VARCHAR2,
    x_d3_doc_required                   IN     VARCHAR2,
    x_clearing_accept_copy_form         IN     VARCHAR2,
    x_online_message                    IN     VARCHAR2,
    x_ethnic_list_seq                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_starx				IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_updater                           IN     VARCHAR2,
    x_inst_type                         IN     VARCHAR2,
    x_inst_short_name                   IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_inst_full_name                    IN     VARCHAR2,
    x_switchboard_tel_no                IN     VARCHAR2,
    x_decision_cards                    IN     VARCHAR2,
    x_record_cards                      IN     VARCHAR2,
    x_labels                            IN     VARCHAR2,
    x_weekly_mov_list_seq               IN     VARCHAR2,
    x_weekly_mov_paging                 IN     VARCHAR2,
    x_form_seq                          IN     VARCHAR2,
    x_ebl_required                      IN     VARCHAR2,
    x_ebl_media_1or2                    IN     VARCHAR2,
    x_ebl_media_3                       IN     VARCHAR2,
    x_ebl_1or2_merged                   IN     VARCHAR2,
    x_ebl_1or2_board_group              IN     VARCHAR2,
    x_ebl_3_board_group                 IN     VARCHAR2,
    x_ebl_nc_app                        IN     VARCHAR2,
    x_ebl_major_key1                    IN     VARCHAR2,
    x_ebl_major_key2                    IN     VARCHAR2,
    x_ebl_major_key3                    IN     VARCHAR2,
    x_ebl_minor_key1                    IN     VARCHAR2,
    x_ebl_minor_key2                    IN     VARCHAR2,
    x_ebl_minor_key3                    IN     VARCHAR2,
    x_ebl_final_key                     IN     VARCHAR2,
    x_odl1                              IN     VARCHAR2,
    x_odl1a                             IN     VARCHAR2,
    x_odl2                              IN     VARCHAR2,
    x_odl3                              IN     VARCHAR2,
    x_odl_summer                        IN     VARCHAR2,
    x_odl_route_b                       IN     VARCHAR2,
    x_monthly_seq                       IN     VARCHAR2,
    x_monthly_paper                     IN     VARCHAR2,
    x_monthly_page                      IN     VARCHAR2,
    x_monthly_type                      IN     VARCHAR2,
    x_june_list_seq                     IN     VARCHAR2,
    x_june_labels                       IN     VARCHAR2,
    x_june_num_labels                   IN     VARCHAR2,
    x_course_analysis                   IN     VARCHAR2,
    x_campus_used                       IN     VARCHAR2,
    x_d3_doc_required                   IN     VARCHAR2,
    x_clearing_accept_copy_form         IN     VARCHAR2,
    x_online_message                    IN     VARCHAR2,
    x_ethnic_list_seq                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_starx				IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_updater                           IN     VARCHAR2    DEFAULT NULL,
    x_inst_type                         IN     VARCHAR2    DEFAULT NULL,
    x_inst_short_name                   IN     VARCHAR2    DEFAULT NULL,
    x_inst_name                         IN     VARCHAR2    DEFAULT NULL,
    x_inst_full_name                    IN     VARCHAR2    DEFAULT NULL,
    x_switchboard_tel_no                IN     VARCHAR2    DEFAULT NULL,
    x_decision_cards                    IN     VARCHAR2    DEFAULT NULL,
    x_record_cards                      IN     VARCHAR2    DEFAULT NULL,
    x_labels                            IN     VARCHAR2    DEFAULT NULL,
    x_weekly_mov_list_seq               IN     VARCHAR2    DEFAULT NULL,
    x_weekly_mov_paging                 IN     VARCHAR2    DEFAULT NULL,
    x_form_seq                          IN     VARCHAR2    DEFAULT NULL,
    x_ebl_required                      IN     VARCHAR2    DEFAULT NULL,
    x_ebl_media_1or2                    IN     VARCHAR2    DEFAULT NULL,
    x_ebl_media_3                       IN     VARCHAR2    DEFAULT NULL,
    x_ebl_1or2_merged                   IN     VARCHAR2    DEFAULT NULL,
    x_ebl_1or2_board_group              IN     VARCHAR2    DEFAULT NULL,
    x_ebl_3_board_group                 IN     VARCHAR2    DEFAULT NULL,
    x_ebl_nc_app                        IN     VARCHAR2    DEFAULT NULL,
    x_ebl_major_key1                    IN     VARCHAR2    DEFAULT NULL,
    x_ebl_major_key2                    IN     VARCHAR2    DEFAULT NULL,
    x_ebl_major_key3                    IN     VARCHAR2    DEFAULT NULL,
    x_ebl_minor_key1                    IN     VARCHAR2    DEFAULT NULL,
    x_ebl_minor_key2                    IN     VARCHAR2    DEFAULT NULL,
    x_ebl_minor_key3                    IN     VARCHAR2    DEFAULT NULL,
    x_ebl_final_key                     IN     VARCHAR2    DEFAULT NULL,
    x_odl1                              IN     VARCHAR2    DEFAULT NULL,
    x_odl1a                             IN     VARCHAR2    DEFAULT NULL,
    x_odl2                              IN     VARCHAR2    DEFAULT NULL,
    x_odl3                              IN     VARCHAR2    DEFAULT NULL,
    x_odl_summer                        IN     VARCHAR2    DEFAULT NULL,
    x_odl_route_b                       IN     VARCHAR2    DEFAULT NULL,
    x_monthly_seq                       IN     VARCHAR2    DEFAULT NULL,
    x_monthly_paper                     IN     VARCHAR2    DEFAULT NULL,
    x_monthly_page                      IN     VARCHAR2    DEFAULT NULL,
    x_monthly_type                      IN     VARCHAR2    DEFAULT NULL,
    x_june_list_seq                     IN     VARCHAR2    DEFAULT NULL,
    x_june_labels                       IN     VARCHAR2    DEFAULT NULL,
    x_june_num_labels                   IN     VARCHAR2    DEFAULT NULL,
    x_course_analysis                   IN     VARCHAR2    DEFAULT NULL,
    x_campus_used                       IN     VARCHAR2    DEFAULT NULL,
    x_d3_doc_required                   IN     VARCHAR2    DEFAULT NULL,
    x_clearing_accept_copy_form         IN     VARCHAR2    DEFAULT NULL,
    x_online_message                    IN     VARCHAR2    DEFAULT NULL,
    x_ethnic_list_seq                   IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL ,
    x_starx				IN     VARCHAR2    DEFAULT NULL
  );

END igs_uc_inst_control_pkg;

 

/