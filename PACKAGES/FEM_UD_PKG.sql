--------------------------------------------------------
--  DDL for Package FEM_UD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_UD_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_ud_eng.pls 120.3.12010000.3 2009/09/01 01:40:51 ghall ship $ */

   type pl_register_record is record (
      object_id                    fem_object_catalog_b.object_id%TYPE,
      request_id                   fem_pl_requests.request_id%TYPE,
      cal_period_id                fem_pl_requests.cal_period_id%TYPE,
      ledger_id                    fem_pl_requests.ledger_id%TYPE,
      dataset_io_obj_def_id        fem_pl_requests.DATASET_IO_OBJ_DEF_ID%TYPE,
      output_dataset_code          fem_pl_requests.output_dataset_code%TYPE,
      source_system_code           fem_pl_requests.source_system_code%TYPE,
      effective_date               fem_pl_requests.effective_date%TYPE,
      rule_set_obj_def_id          fem_pl_requests.rule_set_obj_def_id%TYPE,
      user_id                      fnd_user.user_id%TYPE,
      login_id                     fem_pl_requests.last_update_login%TYPE,
      program_id                   fem_pl_requests.program_id%TYPE,
      program_login_id             fem_pl_requests.program_login_id%TYPE,
      program_application_id       fem_pl_requests.program_application_id%TYPE,
      exec_status_code             fem_pl_requests.exec_status_code%TYPE,
      accurate_eff_dt_flg          VARCHAR2(1)
  );

  TYPE dim_attr_record IS RECORD (
     attr_table                    fem_xdim_dimensions_vl.ATTRIBUTE_TABLE_NAME%TYPE,
     member_col                    fem_xdim_dimensions_vl.MEMBER_COL%TYPE,
     attr_value_col_name           fem_dim_attributes_b.ATTRIBUTE_VALUE_COLUMN_NAME%TYPE
  );


   PROCEDURE Get_Put_Messages              (p_msg_count       IN   NUMBER,
                                            p_msg_data        IN   VARCHAR2,
                                            p_user_msg        IN   VARCHAR2,
                                            p_module          IN   VARCHAR2);

   PROCEDURE create_undo_list              (x_undo_list_obj_id             OUT NOCOPY NUMBER,
                                            x_undo_list_obj_def_id         OUT NOCOPY NUMBER,
                                            x_return_status                OUT NOCOPY VARCHAR2,
                                            x_msg_count                    OUT NOCOPY NUMBER,
                                            x_msg_data                     OUT NOCOPY VARCHAR2,
                                            p_api_version                  IN  NUMBER,
                                            p_commit                       IN  VARCHAR2,
                                            p_undo_list_name               IN  VARCHAR2,
                                            p_folder_id                    IN  NUMBER,
                                            p_include_dependencies_flag    IN  VARCHAR2,
                                            p_ignore_dependency_errs_flag  IN  VARCHAR2,
                                            p_execution_date               IN  DATE);

   PROCEDURE delete_undo_list              (x_return_status                OUT NOCOPY VARCHAR2,
                                            x_msg_count                    OUT NOCOPY NUMBER,
                                            x_msg_data                     OUT NOCOPY VARCHAR2,
                                            p_api_version                  IN  NUMBER,
                                            p_commit                       IN  VARCHAR2,
                                            p_undo_list_obj_id             IN  NUMBER);

   PROCEDURE add_candidate                 (x_return_status                OUT NOCOPY VARCHAR2,
                                            x_msg_count                    OUT NOCOPY NUMBER,
                                            x_msg_data                     OUT NOCOPY VARCHAR2,
                                            p_api_version                  IN  NUMBER,
                                            p_commit                       IN  VARCHAR2,
                                            p_undo_list_obj_def_id         IN  NUMBER,
                                            p_request_id                   IN  NUMBER,
                                            p_object_id                    IN  NUMBER);


   PROCEDURE remove_candidate              (x_return_status                OUT NOCOPY VARCHAR2,
                                            x_msg_count                    OUT NOCOPY NUMBER,
                                            x_msg_data                     OUT NOCOPY VARCHAR2,
                                            p_api_version                  IN  NUMBER,
                                            p_commit                       IN  VARCHAR2,
                                            p_undo_list_obj_def_id         IN  NUMBER,
                                            p_request_id                   IN  NUMBER,
                                            p_object_id                    IN  NUMBER);

   PROCEDURE report_cand_dependents        (x_msg_count                    OUT NOCOPY NUMBER,
                                            x_msg_data                     OUT NOCOPY VARCHAR2,
                                            p_request_id                   IN  NUMBER,
                                            p_object_id                    IN  NUMBER,
                                            p_dependency_type              IN  VARCHAR2);

   PROCEDURE generate_cand_dependents      (x_return_status                OUT NOCOPY VARCHAR2,
                                            x_msg_count                    OUT NOCOPY NUMBER,
                                            x_msg_data                     OUT NOCOPY VARCHAR2,
                                            p_api_version                  IN  NUMBER,
                                            p_commit                       IN  VARCHAR2,
                                            p_undo_list_obj_def_id         IN  NUMBER DEFAULT NULL,
                                            p_request_id                   IN  NUMBER,
                                            p_object_id                    IN  NUMBER,
                                            p_dependency_type              IN  VARCHAR2,
                                            p_ud_session_id                IN  NUMBER DEFAULT NULL,
                                            p_preview_flag                 IN  VARCHAR2 DEFAULT 'N');

   PROCEDURE validate_candidates           (x_return_status                OUT NOCOPY VARCHAR2,
                                            x_msg_count                    OUT NOCOPY NUMBER,
                                            x_msg_data                     OUT NOCOPY VARCHAR2,
                                            p_api_version                  IN  NUMBER,
                                            p_commit                       IN  VARCHAR2,
                                            p_undo_list_obj_def_id         IN  NUMBER DEFAULT NULL,
                                            p_dependency_type              IN  VARCHAR2,
                                            p_ud_session_id                IN  NUMBER DEFAULT NULL,
                                            p_preview_flag                 IN  VARCHAR2 DEFAULT 'N');

   PROCEDURE perform_undo_actions          (x_return_status                OUT NOCOPY VARCHAR2,
                                            p_undo_list_obj_def_id         IN  NUMBER,
                                            p_obj_exec_type                IN  VARCHAR2,
                                            p_request_id                   IN  NUMBER,
                                            p_object_id                    IN  NUMBER);

   PROCEDURE set_process_status            (p_undo_list_obj_id             IN  NUMBER,
                                            p_undo_list_obj_def_id         IN  NUMBER,
                                            p_execution_status             IN  VARCHAR2);

   PROCEDURE execute_undo_list             (errbuf                         OUT NOCOPY VARCHAR2,
                                            retcode                        OUT NOCOPY VARCHAR2,
                                            p_undo_list_obj_id             IN  NUMBER);

   PROCEDURE submit_undo_lists             (errbuf                         OUT NOCOPY VARCHAR2,
                                            retcode                        OUT NOCOPY VARCHAR2);

   PROCEDURE undo_object_execution         (errbuf                         OUT NOCOPY VARCHAR2,
                                            retcode                        OUT NOCOPY VARCHAR2,
                                            p_object_id                    IN  NUMBER,
                                            p_request_id                   IN  NUMBER,
                                            p_folder_id                    IN  NUMBER,
                                            p_include_dependencies_flag    IN  VARCHAR2,
                                            p_ignore_dependency_errs_flag  IN  VARCHAR2);

   PROCEDURE undo_request_by_rule_set      (errbuf                         OUT NOCOPY VARCHAR2,
                                            retcode                        OUT NOCOPY VARCHAR2,
                                            p_rule_set_obj_def_id          IN  NUMBER,
                                            p_ledger_id                    IN  NUMBER,
                                            p_ds_io_obj_def_id             IN  NUMBER,
                                            p_include_dependencies_flag    IN  VARCHAR2,
                                            p_ignore_dependency_errs_flag  IN  VARCHAR2,
                                            p_output_period                IN  NUMBER);

   PROCEDURE undo_all_obj_execs_in_request (errbuf                         OUT NOCOPY VARCHAR2,
                                            retcode                        OUT NOCOPY VARCHAR2,
                                            p_request_id                   IN  NUMBER,
                                            p_folder_id                    IN  NUMBER,
                                            p_include_dependencies_flag    IN  VARCHAR2,
                                            p_ignore_dependency_errs_flag  IN  VARCHAR2);

   PROCEDURE create_and_submit_prview_list (x_request_id                   OUT NOCOPY NUMBER,
                                            x_undo_list_obj_id             OUT NOCOPY NUMBER,
                                            x_undo_list_obj_def_id         OUT NOCOPY NUMBER,
                                            x_return_status                OUT NOCOPY VARCHAR2,
                                            x_msg_count                    OUT NOCOPY NUMBER,
                                            x_msg_data                     OUT NOCOPY VARCHAR2,
                                            p_api_version                  IN  NUMBER,
                                            p_undo_list_name               IN  VARCHAR2,
                                            p_folder_id                    IN  NUMBER,
                                            p_ud_session_id                IN  NUMBER);

   PROCEDURE insert_preview_candidates (x_return_status   OUT NOCOPY VARCHAR2,
                                        x_msg_count       OUT NOCOPY NUMBER,
                                        x_msg_data        OUT NOCOPY VARCHAR2,
                                        p_api_version     IN  NUMBER,
                                        p_ud_session_id   IN  NUMBER,
                                        p_request_ids     IN  FEM_NUMBER_TABLE,
                                        p_object_ids      IN  FEM_NUMBER_TABLE,
                                        p_commit          IN  VARCHAR2);


   PROCEDURE Delete_Balances (
     p_api_version         IN  NUMBER     DEFAULT 1.0,
     p_init_msg_list       IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
     p_commit              IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
     p_encoded             IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_current_request_id  IN  NUMBER,
     p_object_id           IN  NUMBER,
     p_cal_period_id       IN  NUMBER,
     p_ledger_id           IN  NUMBER,
     p_dataset_code        IN  NUMBER);

   PROCEDURE Remove_Process_Locks (
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
     p_commit              IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
     p_encoded             IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_request_id          IN  NUMBER,
     p_object_id           IN  NUMBER);

   PROCEDURE Repair_PL_Request (
     errbuf                          out nocopy varchar2
     ,retcode                        out nocopy varchar2
     ,p_request_id                   in number default null
     ,p_object_id                    in number default null
   );


END fem_ud_pkg;

/
