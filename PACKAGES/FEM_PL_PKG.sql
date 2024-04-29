--------------------------------------------------------
--  DDL for Package FEM_PL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_PL_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_pl_pkh.pls 120.3 2006/03/22 14:02:43 gcheng ship $ */

   PROCEDURE obj_def_data_edit_lock_exists (p_object_definition_id   IN  NUMBER,
                                            x_data_edit_lock_exists  OUT NOCOPY VARCHAR2);

   PROCEDURE effective_date_incl_rslt_data (
      p_api_version              IN  NUMBER,
      p_init_msg_list            IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
      p_encoded                  IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_object_definition_id     IN  NUMBER,
      p_new_effective_start_date IN  DATE,
      p_new_effective_end_date   IN  DATE,
      x_date_incl_rslt_data      OUT NOCOPY VARCHAR2);

   PROCEDURE effective_date_incl_rslt_data (
      p_object_definition_id     IN  NUMBER,
      p_new_effective_start_date IN  DATE,
      p_new_effective_end_date   IN  DATE,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_date_incl_rslt_data      OUT NOCOPY VARCHAR2);

   PROCEDURE obj_def_approval_lock_exists  (p_object_definition_id      IN  NUMBER,
                                            x_approval_edit_lock_exists OUT NOCOPY VARCHAR2);

   PROCEDURE get_object_def_edit_locks     (p_object_definition_id       IN  NUMBER,
                                            x_approval_edit_lock_exists  OUT NOCOPY VARCHAR2,
                                            x_data_edit_lock_exists      OUT NOCOPY VARCHAR2);

   PROCEDURE can_delete_object (
      p_api_version          IN  NUMBER,
      p_init_msg_list        IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
      p_encoded              IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
      x_return_status        OUT NOCOPY VARCHAR2,
      x_msg_count            OUT NOCOPY NUMBER,
      x_msg_data             OUT NOCOPY VARCHAR2,
      p_object_id            IN  NUMBER,
      p_process_type         IN  NUMBER DEFAULT NULL,
      x_can_delete_obj       OUT NOCOPY VARCHAR2);

   PROCEDURE can_delete_object (
      p_object_id            IN  NUMBER,
      p_process_type         IN  NUMBER DEFAULT NULL,
      x_can_delete_obj       OUT NOCOPY VARCHAR2,
      x_msg_count            OUT NOCOPY NUMBER,
      x_msg_data             OUT NOCOPY VARCHAR2);

   PROCEDURE can_delete_object_def (
      p_api_version          IN  NUMBER,
      p_init_msg_list        IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
      p_encoded              IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
      x_return_status        OUT NOCOPY VARCHAR2,
      x_msg_count            OUT NOCOPY NUMBER,
      x_msg_data             OUT NOCOPY VARCHAR2,
      p_object_definition_id IN  NUMBER,
      p_process_type         IN  NUMBER DEFAULT NULL,
      p_calling_program      IN  VARCHAR2 DEFAULT NULL,
      x_can_delete_obj_def   OUT NOCOPY VARCHAR2);

   PROCEDURE can_delete_object_def (
      p_object_definition_id IN  NUMBER,
      x_can_delete_obj_def   OUT NOCOPY VARCHAR2,
      x_msg_count            OUT NOCOPY NUMBER,
      x_msg_data             OUT NOCOPY VARCHAR2,
      p_process_type         IN  NUMBER DEFAULT NULL,
      p_calling_program      IN  VARCHAR2 DEFAULT NULL);

   PROCEDURE obj_execution_lock_exists     (p_object_id            IN  NUMBER,
                                            p_exec_object_definition_id IN NUMBER,
                                            p_ledger_id            IN  NUMBER DEFAULT NULL,
                                            p_cal_period_id        IN  NUMBER DEFAULT NULL,
                                            p_output_dataset_code  IN  NUMBER DEFAULT NULL,
                                            p_source_system_code   IN  NUMBER DEFAULT NULL,
                                            p_exec_mode_code       IN  VARCHAR2 DEFAULT NULL,
                                            p_dimension_id         IN  NUMBER DEFAULT NULL,
                                            p_table_name           IN  VARCHAR2 DEFAULT NULL,
                                            p_hierarchy_name       IN  VARCHAR2 DEFAULT NULL,
                                            p_calling_context      IN  VARCHAR2 DEFAULT 'ENGINE',
                                            x_exec_state           OUT NOCOPY VARCHAR2,
                                            x_prev_request_id      OUT NOCOPY NUMBER,
                                            x_msg_count            OUT NOCOPY NUMBER,
                                            x_msg_data             OUT NOCOPY VARCHAR2,
                                            x_exec_lock_exists     OUT NOCOPY VARCHAR2);

   PROCEDURE register_object_execution     (p_api_version          IN  NUMBER,
                                            p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id           IN  NUMBER,
                                            p_object_id            IN  NUMBER,
                                            p_exec_object_definition_id IN NUMBER,
                                            p_user_id              IN NUMBER,
                                            p_last_update_login    IN NUMBER,
                                            p_exec_mode_code       IN  VARCHAR2 DEFAULT NULL,
                                            x_exec_state           OUT NOCOPY VARCHAR2,
                                            x_prev_request_id      OUT NOCOPY NUMBER,
                                            x_msg_count            OUT NOCOPY NUMBER,
                                            x_msg_data             OUT NOCOPY VARCHAR2,
                                            x_return_status        OUT NOCOPY VARCHAR2);

   PROCEDURE register_request              (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_cal_period_id          IN  NUMBER DEFAULT NULL,
                                            p_ledger_id              IN  NUMBER DEFAULT NULL,
                                            p_dataset_io_obj_def_id  IN  NUMBER DEFAULT NULL,
                                            p_output_dataset_code    IN  NUMBER DEFAULT NULL,
                                            p_source_system_code     IN  NUMBER DEFAULT NULL,
                                            p_effective_date         IN  DATE DEFAULT NULL,
                                            p_rule_set_obj_def_id    IN  NUMBER DEFAULT NULL,
                                            p_rule_set_name          IN  VARCHAR2 DEFAULT NULL,
                                            p_request_id             IN  NUMBER,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            p_program_id             IN  NUMBER,
                                            p_program_login_id       IN  NUMBER,
                                            p_program_application_id IN  NUMBER,
                                            p_exec_mode_code         IN  VARCHAR2 DEFAULT NULL,
                                            p_dimension_id           IN  NUMBER DEFAULT NULL,
                                            p_table_name             IN  VARCHAR2 DEFAULT NULL,
                                            p_hierarchy_name         IN  VARCHAR2 DEFAULT NULL,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE unregister_request            (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE update_request_status         (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_exec_status_code       IN  VARCHAR2,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE update_obj_exec_status        (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            p_exec_status_code       IN  VARCHAR2,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE update_obj_exec_errors        (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            p_errors_reported        IN  NUMBER,
                                            p_errors_reprocessed     IN  NUMBER,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE register_object_def           (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            p_object_definition_id   IN  NUMBER,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE register_dependent_objdefs    (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            p_exec_object_definition_id IN NUMBER,
                                            p_effective_date         IN  DATE,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE register_table                (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            p_table_name             IN  VARCHAR2,
                                            p_statement_type         IN  VARCHAR2,
                                            p_num_of_output_rows     IN  NUMBER,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE update_num_of_output_rows     (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            p_table_name             IN  VARCHAR2,
                                            p_statement_type         IN  VARCHAR2,
                                            p_num_of_output_rows     IN  NUMBER,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE register_updated_column       (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            p_table_name             IN  VARCHAR2,
                                            p_statement_type         IN  VARCHAR2,
                                            p_column_name            IN  VARCHAR2,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE register_chain                (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            p_source_created_by_request_id  IN  NUMBER,
                                            p_source_created_by_object_id   IN  NUMBER,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE register_temp_object          (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            p_object_type            IN  VARCHAR2,
                                            p_object_name            IN  VARCHAR2,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE update_num_of_input_rows      (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            p_num_of_input_rows      IN  NUMBER,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE register_obj_exec_step        (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            p_exec_step              IN  VARCHAR2,
                                            p_exec_status_code       IN  VARCHAR2,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE unregister_obj_exec_step      (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            p_exec_step              IN  VARCHAR2,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE unregister_obj_exec_steps     (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE update_obj_exec_step_status   (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            p_exec_step              IN  VARCHAR2,
                                            p_exec_status_code       IN  VARCHAR2,
                                            p_user_id                IN  NUMBER,
                                            p_last_update_login      IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE set_exec_state                (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            p_object_id              IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2);

   PROCEDURE mapping_exec_lock_exists      (p_object_id                 IN  NUMBER,
                                            p_exec_object_definition_id IN  NUMBER,
                                            p_ledger_id                 IN  NUMBER,
                                            p_cal_period_id             IN  NUMBER,
                                            p_output_dataset_code       IN  NUMBER,
                                            p_calling_context           IN  VARCHAR2 DEFAULT 'ENGINE',
                                            x_exec_state                OUT NOCOPY VARCHAR2,
                                            x_prev_request_id           OUT NOCOPY NUMBER,
                                            x_msg_count                 OUT NOCOPY NUMBER,
                                            x_msg_data                  OUT NOCOPY VARCHAR2,
                                            x_exec_lock_exists          OUT NOCOPY VARCHAR2);

   PROCEDURE dim_mbr_ldr_exec_lock_exists  (p_object_id                 IN  NUMBER,
                                            p_exec_object_definition_id IN  NUMBER,
                                            p_calling_context           IN  VARCHAR2 DEFAULT 'ENGINE',
                                            x_exec_state                OUT NOCOPY VARCHAR2,
                                            x_msg_count                 OUT NOCOPY NUMBER,
                                            x_msg_data                  OUT NOCOPY VARCHAR2,
                                            x_exec_lock_exists          OUT NOCOPY VARCHAR2,
                                            x_prev_request_id           OUT NOCOPY NUMBER);

   PROCEDURE datax_ldr_exec_lock_exists    (p_object_id                 IN  NUMBER,
                                            p_exec_object_definition_id IN  NUMBER,
                                            p_ledger_id                 IN  NUMBER,
                                            p_cal_period_id             IN  NUMBER,
                                            p_output_dataset_code       IN  NUMBER,
                                            p_source_system_code        IN  NUMBER,
                                            p_table_name                IN  VARCHAR2,
                                            p_calling_context           IN  VARCHAR2 DEFAULT 'ENGINE',
                                            x_exec_state                OUT NOCOPY VARCHAR2,
                                            x_prev_request_id           OUT NOCOPY NUMBER,
                                            x_msg_count                 OUT NOCOPY NUMBER,
                                            x_msg_data                  OUT NOCOPY VARCHAR2,
                                            x_exec_lock_exists          OUT NOCOPY VARCHAR2);

   PROCEDURE hier_ldr_exec_lock_exists     (p_object_id                 IN  NUMBER,
                                            p_exec_object_definition_id IN  NUMBER,
                                            p_hierarchy_name            IN  VARCHAR2,
                                            p_calling_context           IN  VARCHAR2 DEFAULT 'ENGINE',
                                            x_exec_state                OUT NOCOPY VARCHAR2,
                                            x_msg_count                 OUT NOCOPY NUMBER,
                                            x_msg_data                  OUT NOCOPY VARCHAR2,
                                            x_exec_lock_exists          OUT NOCOPY VARCHAR2,
                                            x_prev_request_id           OUT NOCOPY NUMBER);

   PROCEDURE rcm_proc_exec_lock_exists     (p_object_id                 IN  NUMBER,
                                            p_exec_object_definition_id IN  NUMBER,
                                            p_ledger_id                 IN  NUMBER,
                                            p_cal_period_id             IN  NUMBER,
                                            p_output_dataset_code       IN  NUMBER,
                                            p_calling_context           IN  VARCHAR2 DEFAULT 'ENGINE',
                                            x_exec_state                OUT NOCOPY VARCHAR2,
                                            x_prev_request_id           OUT NOCOPY NUMBER,
                                            x_msg_count                 OUT NOCOPY NUMBER,
                                            x_msg_data                  OUT NOCOPY VARCHAR2,
                                            x_exec_lock_exists          OUT NOCOPY VARCHAR2);


   PROCEDURE check_chaining (
     p_api_version     IN NUMBER     DEFAULT 1.0,
     p_init_msg_list   IN VARCHAR2   DEFAULT FND_API.G_FALSE,
     p_commit          IN VARCHAR2   DEFAULT FND_API.G_FALSE,
     p_encoded         IN VARCHAR2   DEFAULT FND_API.G_TRUE,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     p_request_id      IN  NUMBER,
     p_object_id       IN  NUMBER,
     x_dep_request_id  OUT NOCOPY NUMBER,
     x_dep_object_id   OUT NOCOPY NUMBER,
     x_chain_exists    OUT NOCOPY VARCHAR2);

  PROCEDURE get_exec_status (
     p_api_version       IN  NUMBER     DEFAULT 1.0,
     p_init_msg_list     IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
     p_commit            IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
     p_encoded           IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
     x_return_status     OUT NOCOPY VARCHAR2,
     x_msg_count         OUT NOCOPY NUMBER,
     x_msg_data          OUT NOCOPY VARCHAR2,
     p_request_id        IN  NUMBER,
     p_object_id         IN  NUMBER,
     x_exec_status_code  OUT NOCOPY VARCHAR2);


END fem_pl_pkg;

 

/
