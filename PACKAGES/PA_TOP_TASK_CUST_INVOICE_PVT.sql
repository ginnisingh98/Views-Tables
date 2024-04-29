--------------------------------------------------------
--  DDL for Package PA_TOP_TASK_CUST_INVOICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TOP_TASK_CUST_INVOICE_PVT" AUTHID CURRENT_USER AS
/* $Header: PATOPCIS.pls 120.1 2005/08/19 17:04:44 mwasowic noship $ */

PROCEDURE enbl_disbl_cust_at_top_task(
          p_api_version           IN   NUMBER   := 1.0
        , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only         IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
	   , p_debug_mode            IN   VARCHAR2 := 'N'
        , p_mode		          IN   VARCHAR2
        , p_project_id            IN   NUMBER
	   , p_def_top_task_cust     IN   NUMBER
	   , p_contr_update_cust     IN   NUMBER
        , x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        , x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
        , x_msg_data              OUT  NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
	);

PROCEDURE Get_Highest_Contr_Cust(
          p_api_version           IN   NUMBER   := 1.0
        , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only         IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
        , p_debug_mode            IN   VARCHAR2 := 'N'
        , p_project_id            IN   NUMBER
        , p_exclude_cust_id_tbl   IN   PA_PLSQL_DATATYPES.NumTabTyp
        , x_highst_contr_cust_id  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
        , x_highst_contr_cust_name OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        , x_highst_contr_cust_num  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        , x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        , x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
        , x_msg_data              OUT  NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
	);

PROCEDURE Set_Rev_Acc_At_Top_Task(
          p_api_version           IN   NUMBER   := 1.0
        , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only         IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
        , p_debug_mode            IN   VARCHAR2 := 'N'
        , p_project_id            IN   NUMBER
        , p_rev_acc               IN   VARCHAR2
        , x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        , x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
        , x_msg_data              OUT  NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
	);

PROCEDURE Set_Inv_Mth_At_Top_Task(
          p_api_version           IN   NUMBER   := 1.0
        , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only         IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
        , p_debug_mode            IN   VARCHAR2 := 'N'
        , p_project_id            IN   NUMBER
        , p_inv_mth               IN   VARCHAR2
        , x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        , x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
        , x_msg_data              OUT  NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
	);

PROCEDURE set_top_task_funding_level(
          p_api_version           IN   NUMBER   := 1.0
        , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only         IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
    	   , p_debug_mode            IN   VARCHAR2 := 'N'
        , p_project_id            IN   NUMBER
        , x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        , x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
        , x_msg_data              OUT  NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
	);

PROCEDURE check_delete_customer (
          p_api_version      IN   NUMBER   := 1.0
        , p_init_msg_list    IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit           IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only    IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module   IN   VARCHAR2 := 'SELF_SERVICE'
    	   , p_debug_mode       IN   VARCHAR2 := 'N'
        , p_project_id       IN   NUMBER
        , p_customer_id      IN   NUMBER
        , x_cust_assoc       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        , x_cust_id          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
        , x_cust_name        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        , x_cust_num         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        , x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        , x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
        , x_msg_data         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );

END PA_TOP_TASK_CUST_INVOICE_PVT;

 

/
