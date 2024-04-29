--------------------------------------------------------
--  DDL for Package FEM_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_setup_pkg.pls 120.2 2006/05/18 04:43:27 sshanmug noship $ */

   c_false        CONSTANT  VARCHAR2(1)  := fnd_api.g_false;
   c_true         CONSTANT  VARCHAR2(1)  := fnd_api.g_true;
   c_success      CONSTANT  VARCHAR2(1)  := fnd_api.g_ret_sts_success;
   c_error        CONSTANT  VARCHAR2(1)  := fnd_api.g_ret_sts_error;
   c_unexp        CONSTANT  VARCHAR2(1)  := fnd_api.g_ret_sts_unexp_error;
   c_api_version  CONSTANT  NUMBER       := 1.0;

   g_log_level_1  CONSTANT  NUMBER       := fnd_log.level_statement;
   g_log_level_2  CONSTANT  NUMBER       := fnd_log.level_procedure;
   g_log_level_3  CONSTANT  NUMBER       := fnd_log.level_event;
   g_log_level_4  CONSTANT  NUMBER       := fnd_log.level_exception;
   g_log_level_5  CONSTANT  NUMBER       := fnd_log.level_error;
   g_log_level_6  CONSTANT  NUMBER       := fnd_log.level_unexpected;

   g_block        CONSTANT  VARCHAR2(80) := 'FEM.PLSQL.FEM_SETUP_PKG';

--   TYPE col_list_arr IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

  PROCEDURE register_activity_ff(p_api_version   IN  NUMBER,
                                 p_init_msg_list IN  VARCHAR2,
                                 p_commit        IN  VARCHAR2,
                                 p_encoded       IN  VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2);

  PROCEDURE register_cost_ff(p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2,
                             p_commit        IN  VARCHAR2,
                             p_encoded       IN  VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2);

  PROCEDURE compile_ff(p_api_version    IN  NUMBER,
                       p_init_msg_list  IN  VARCHAR2,
                       p_commit         IN  VARCHAR2,
                       p_encoded        IN  VARCHAR2,
                       x_return_status  OUT NOCOPY VARCHAR2,
                       x_msg_count      OUT NOCOPY NUMBER,
                       x_msg_data       OUT NOCOPY VARCHAR2,
                       p_ff_name        IN  VARCHAR2,
                       p_comdim_ff_rec  IN  fnd_flex_key_api.flexfield_type,
                       p_comdim_str_rec IN  fnd_flex_key_api.structure_type);
/*
 PROCEDURE validate_proc_key(p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2,
                             p_commit        IN  VARCHAR2,
                             p_encoded       IN  VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_col_list_rec  IN  fem_col_list_arr_typ,
                             p_table_name    IN  VARCHAR2);
*/
 PROCEDURE validate_proc_key(p_api_version       IN  NUMBER,
                             p_init_msg_list     IN  VARCHAR2,
                             p_commit            IN  VARCHAR2,
                             p_encoded           IN  VARCHAR2,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_msg_count         OUT NOCOPY NUMBER,
                             x_msg_data          OUT NOCOPY VARCHAR2,
                             p_dimension_varchar_label IN VARCHAR2,
                             p_table_name        IN  VARCHAR2);


 PROCEDURE delete_flexfield (p_api_version     IN  NUMBER,
                             p_init_msg_list   IN  VARCHAR2,
                             p_commit          IN  VARCHAR2,
                             p_encoded         IN  VARCHAR2,
                             x_return_status   OUT NOCOPY VARCHAR2,
                             x_msg_count       OUT NOCOPY NUMBER,
                             x_msg_data        OUT NOCOPY VARCHAR2,
                             p_dimension_varchar_label IN VARCHAR2);



END fem_setup_pkg;
 

/
