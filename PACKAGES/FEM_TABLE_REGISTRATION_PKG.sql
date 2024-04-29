--------------------------------------------------------
--  DDL for Package FEM_TABLE_REGISTRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_TABLE_REGISTRATION_PKG" AUTHID CURRENT_USER AS
/* $Header: FEMTABREGS.pls 120.5 2007/05/08 10:40:16 ugoswami ship $ */

   g_log_level_1     CONSTANT  NUMBER      := fnd_log.level_statement;
   g_log_level_2     CONSTANT  NUMBER      := fnd_log.level_procedure;
   g_log_level_3     CONSTANT  NUMBER      := fnd_log.level_event;
   g_log_level_4     CONSTANT  NUMBER      := fnd_log.level_exception;
   g_log_level_5     CONSTANT  NUMBER      := fnd_log.level_error;
   g_log_level_6     CONSTANT  NUMBER      := fnd_log.level_unexpected;
   g_block         CONSTANT VARCHAR2(30) := 'FEM_TABLE_REGISTRATION_PKG';
   g_table_name    CONSTANT VARCHAR2(10) :='TABLE_NAME';

   c_false           CONSTANT  VARCHAR2(1) := FND_API.G_FALSE;
   c_true            CONSTANT  VARCHAR2(1) := FND_API.G_TRUE;
   c_success         CONSTANT  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   c_error           CONSTANT  VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   c_unexp           CONSTANT  VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
   G_FEM                CONSTANT  VARCHAR2(3) := 'FEM';
   c_api_version     CONSTANT  NUMBER      := 1.0;

   PROCEDURE synchronize(p_api_version      IN NUMBER,
                         p_init_msg_list    IN VARCHAR2,
                         p_commit           IN VARCHAR2,
                         p_encoded          IN VARCHAR2,
                         p_table_name       IN VARCHAR2,
                         p_synchronize_flag OUT NOCOPY VARCHAR2,
                         x_msg_count        OUT NOCOPY NUMBER,
                         x_msg_data         OUT NOCOPY VARCHAR2,
                         x_return_status    OUT NOCOPY VARCHAR2);

   PROCEDURE unregister(p_api_version     IN NUMBER,
                        p_init_msg_list   IN VARCHAR2,
                        p_commit          IN VARCHAR2,
                        p_encoded         IN VARCHAR2,
                        p_table_name      IN VARCHAR2,
                        x_msg_count       OUT NOCOPY NUMBER,
                        x_msg_data        OUT NOCOPY VARCHAR2,
                        x_return_status   OUT NOCOPY VARCHAR2);


   PROCEDURE init(p_api_version     IN NUMBER,
                  p_init_msg_list   IN VARCHAR2,
                  p_commit          IN VARCHAR2,
                  p_encoded         IN VARCHAR2,
                  x_msg_count       OUT NOCOPY NUMBER,
                  x_msg_data        OUT NOCOPY VARCHAR2,
                  x_return_status   OUT NOCOPY VARCHAR2);

   PROCEDURE validateClass( p_api_version     IN NUMBER,
                            p_init_msg_list   IN VARCHAR2,
                            p_commit          IN VARCHAR2,
                            p_encoded         IN VARCHAR2,
                            p_table_name      IN VARCHAR2,
                            x_msg_count       OUT NOCOPY NUMBER,
                            x_msg_data        OUT NOCOPY VARCHAR2,
                            x_return_status   OUT NOCOPY VARCHAR2);

   PROCEDURE populate_tab_col_gt(p_api_version     IN NUMBER default c_api_version,
                                 p_init_msg_list   IN VARCHAR2 default c_false,
                                 p_commit          IN VARCHAR2 default c_false,
                                 p_encoded         IN VARCHAR2 default c_true,
                                 p_mode            IN VARCHAR2,
                                 p_owner           IN VARCHAR2,
                                 p_table_name      IN VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2,
                                 x_return_status   OUT NOCOPY VARCHAR2);

   PROCEDURE populate_tab_col_vl(p_api_version     IN NUMBER default c_api_version,
                                 p_init_msg_list   IN VARCHAR2 default c_false,
                                 p_commit          IN VARCHAR2 default c_false,
                                 p_encoded         IN VARCHAR2 default c_true,
                                 p_table_name      IN VARCHAR2,
                                 p_skip_validation IN VARCHAR2,
                                 p_mode            IN VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2,
                                 x_return_status   OUT NOCOPY VARCHAR2);

   PROCEDURE dump_gt(p_api_version     IN NUMBER default c_api_version,
                     p_init_msg_list   IN VARCHAR2 default c_false,
                     p_commit          IN VARCHAR2 default c_false,
                     p_encoded         IN VARCHAR2 default c_true,
                     x_msg_count       OUT NOCOPY NUMBER,
                     x_msg_data        OUT NOCOPY VARCHAR2,
                     x_return_status   OUT NOCOPY VARCHAR2);

   PROCEDURE raise_proc_key_update_event(p_table_name      IN VARCHAR2,
                                         x_msg_count       OUT NOCOPY NUMBER,
                                         x_msg_data        OUT NOCOPY VARCHAR2,
                                         x_return_status   OUT NOCOPY VARCHAR2);

   FUNCTION is_table_registered(p_table_name IN VARCHAR2) RETURN VARCHAR2;

   FUNCTION is_table_column_registered(p_table_name IN VARCHAR2,
                                       p_column_name IN VARCHAR2) RETURN VARCHAR2;

   FUNCTION is_table_class_code_valid(p_table_name VARCHAR2,
                                      p_table_class_code VARCHAR2) RETURN VARCHAR2;

   FUNCTION is_table_class_list_valid(p_table_name VARCHAR2,
                                      p_table_class_lookup_type VARCHAR2) RETURN VARCHAR2;

   FUNCTION get_schema_name(p_app_id IN NUMBER) RETURN VARCHAR2;

   FUNCTION get_schema_name(p_app_short_name IN VARCHAR2) RETURN VARCHAR2;

   PROCEDURE get_tab_list(p_view_name IN VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                		   x_msg_data      OUT NOCOPY VARCHAR2,
 			               x_return_status OUT NOCOPY VARCHAR2);

   FUNCTION get_Object_Type(p_object_name IN VARCHAR2) RETURN VARCHAR2;
   FUNCTION get_Fem_Object_Type(p_object_name IN VARCHAR2) RETURN VARCHAR2;

   FUNCTION get_di_view_details(p_table_name      IN VARCHAR2) RETURN VARCHAR2;

   PROCEDURE GenerateSysView (  errbuf              OUT  NOCOPY VARCHAR2
                                 ,retcode            OUT  NOCOPY VARCHAR2
								 ,p_tab_name IN VARCHAR
                                 ,p_view_name IN VARCHAR);

   PROCEDURE GenerateAllViews(errbuf          OUT  NOCOPY VARCHAR2
                               ,retcode        OUT  NOCOPY VARCHAR2) ;

END fem_table_registration_pkg;

/
