--------------------------------------------------------
--  DDL for Package CST_PACEAMCOST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PACEAMCOST_GRP" AUTHID CURRENT_USER AS
/* $Header: CSTPPEAS.pls 120.3 2005/07/12 23:41:51 arathee noship $ */


-- Start of comments
--  Notes       : This PL/SQL table type is used to store WIP_Entity_id's for
--                which estimation is to run.
-- End of comments

TYPE G_WIP_ENTITY_TYP IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


-- Start of comments
--  API name    : Estimate_PAC_WipJobs
--  Type        : Public.
--  Function    : This API is called from SRS to estimate eAM WorkOrders in PAC
--                Flow:
--                |-- Insert into CST_PAC_EAM_WO_EST_STATUSES all WIP entities not yet
--                |   estimated for the given cost type.
--                |-- For the job/Jobs to be estimated for the given cost type.
--                |   |-- Update est flag to a -ve no for the jobs to be processed.
--                |   |-- Call delete_PAC_eamperbal to delete prior estimation columns
--                |   |-- Compute the estimates, call Compute_PAC_JobEstimates API
--                |   |-- Update the est status to 7 if successfull or to 3 if errors out
--                |   End Loop;
--                Update Estimation status of unprocessed jobs to Pending for any other
--                  exception so that they can be processed in the next run.
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   errbuf              OUT NOCOPY  VARCHAR2 Conc req param
--              retcode             OUT NOCOPY  NUMBER Conc req param
--              p_organization_id   IN   NUMBER   Required
--              p_legal_entity_id   IN   NUMBER   Required
--              p_cost_type_id      IN   NUMBER   Required
--              p_period_id         IN   NUMBER   Required
--              p_cost_group_id     IN   NUMBER   Required
--              p_entity_type       IN   NUMBER   Optional  DEFAULT 6
--              p_job_option        IN   NUMBER   Optional  DEFAULT 1
--              p_job_dummy         IN   NUMBER   Optional  DEFAULT NULL
--              p_wip_entity_id     IN   NUMBER   Optional  DEFAULT NULL
--  OUT     :
--  Version : Current version   1.0
--
--  Notes       : This procedure is called as a concurrent program to estiamte work orders
--                p_job_otion :
--                           1:  All Jobs
--                           2:  Specific job
--
--                Estimation Status:
--                           NULL,1:  Pending
--                              -ve:  Running
--                                3:  Error
--                                7:  Complete
--
-- End of comments

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURES/FUNCTIONS                                              |
*----------------------------------------------------------------------------*/

PROCEDURE Estimate_PAC_WipJobs(
                    errbuf                     OUT NOCOPY  VARCHAR2,
                    retcode                    OUT NOCOPY  NUMBER,
                    p_legal_entity_id          IN   NUMBER,
                    p_cost_type_id             IN   NUMBER,
                    p_period_id                IN   NUMBER,
                    p_cost_group_id            IN   NUMBER,
                    p_entity_type              IN   NUMBER   DEFAULT 6,
                    p_job_option               IN   NUMBER   DEFAULT 1,
                    p_job_dummy                IN   NUMBER   DEFAULT NULL,
                    p_wip_entity_id            IN   NUMBER   DEFAULT NULL
);


-- Start of comments
--  API name    : Delete_Pac_EamPerBal
--  Type        : Public.
--  Function    : This API is called from Estimate_PAC_WipJobs
--                Flow:
--                |-- Get estimation details of the wip_entity LOOP
--                |   |--Update amount in cst_pac_eam_asset_per_balances
--                |   End Loop;
--                |-- Update estimation columns of cst_pac_eam_period_balances to 0
--                |-- Delete the row in cst_pac_eam_period_balances if estimation and
--                |   actual cost columns are 0 or null
--                |-- Similarly delete the row in cst_pac_eam_asset_per_balances if
--                |   estimation and actual cost columns are 0 or null
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version       IN  NUMBER   Required
--              p_init_msg_list     IN  VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_commit            IN  VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_validation_level  IN  NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--              p_legal_entity_id   IN   NUMBER   Required
--              p_cost_group_id     IN   NUMBER   Required
--              p_cost_type_id      IN   NUMBER   Required
--              p_organization_id   IN  NUMBER   Required
--              p_wip_entity_id_tab IN  CST_PacEamCost_GRP.G_WIP_ENTITY_TYP   Required
--  OUT     :   x_return_status     OUT VARCHAR2(1)
--              x_msg_count         OUT NUMBER
--              x_msg_data          OUT VARCHAR2(2000)
--  Version : Current version   1.0
--
--  Notes       : This procedure does bulk deletes and bulk updates of the prior estimation
--                data for the particular Legal Entity/Cost Group/Cost Type using the PL/SQL table
--
-- End of comments

PROCEDURE Delete_Pac_EamPerBal (
            p_api_version       IN         NUMBER,
            p_init_msg_list     IN         VARCHAR2  := FND_API.G_FALSE,
            p_commit            IN         VARCHAR2  := FND_API.G_FALSE,
            p_validation_level  IN         VARCHAR2  := FND_API.G_VALID_LEVEL_FULL,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_count         OUT NOCOPY NUMBER,
            x_msg_data          OUT NOCOPY VARCHAR2,
            p_legal_entity_id   IN         NUMBER,
            p_cost_group_id     IN         NUMBER,
            p_cost_type_id      IN         NUMBER,
            p_wip_entity_id_tab IN         CST_PacEamCost_GRP.G_WIP_ENTITY_TYP
);


-- Start of comments
--  API name    : Compute_PAC_JobEstimates
--  Type        : Public.
--  Function    : This API is called from Estimate_PAC_WipJobs
--                Flow:
--                |-- Check Entity Type is eAM
--                |-- Get charge asset using API
--                |-- Get the period set name and period name
--                |   |-- if scheduled date is in current PAC period use CST_PAC_PERIODS
--                |   |-- else if its in a future period use GL_PERIODS
--                |   End IF
--                |-- Derive the currency extended precision for the organization
--                |-- Derive valuation rates cost type based on organization's cost method
--                |-- For Resources, open c_wor cursor LOOP
--                |   |-- Get_MaintCostCat (Get category, owning dept and operating dept)
--                |   |-- Get_eamCostElement
--                |   |-- InsertUpdate_PAC_eamPerBal (send asset number, category, wip entity id, eAM cost element, departments etc.)
--                |   |-- For Resource based Overheads open c_rbo cursor LOOP
--                |   |   |-- InsertUpdate_PAC_eamPerBal
--                |   |   END LOOP for c_rbo
--                |   |-- ADD value for the total resource based Overheads for this resource and the resource value
--                |   END LOOP for c_wor
--                |-- Compute Material Costs, open c_wro cursor LOOP
--                |   |--Get_MaintCostCat (Get category, owning dept and operating dept)
--                |   |--Get_eamCostElement
--                |   |--InsertUpdate_PAC_eamPerBal
--                |   END LOOP
--                |-- For 'Non-stockable' Direct Items open c_wrodi cursor LOOP
--                |   |--Get_MaintCostCat (Get category, owning dept and operating dept)
--                |   |--Get_eamCostElement
--                |   |--InsertUpdate_PAC_eamPerBal
--                |   END LOOP
--                |-- For 'Description based' Direct Items open c_wedi cursor LOOP
--                |   |--Get_MaintCostCat (Get category, owning dept and operating dept)
--                |   |--Get Cost Element from CST_CAT_ELE_EXP_ASSOCS table (not from API)
--                |   |--InsertUpdate_PAC_eamPerBal
--                |   END LOOP
--                |-- For PO and REQ open c_pda cursor LOOP
--                |   |--Get_MaintCostCat (Get category, owning dept and operating dept)
--                |   |--Get Cost Element from cst_CAT_ELE_EXP_ASSOCS table (not from API)
--                |   |--InsertUpdate_PAC_eamPerBal
--                |   END LOOP
--
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version      IN   NUMBER   Required
--              p_init_msg_list    IN   VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_commit           IN   VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_validation_level IN   NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--              p_cost_group_id    IN   NUMBER   Required
--              p_legal_entity_id  IN   NUMBER   Required
--              p_Period_id        IN   NUMBER   Required
--              p_wip_entity_id    IN   NUMBER   Required
--              p_user_id          IN   NUMBER   Required
--              p_request_id       IN   NUMBER   Required
--              p_prog_id          IN   NUMBER   Required
--              p_prog_app_id      IN   NUMBER   Required
--              p_login_id         IN   NUMBER   Required
-- OUT      :   x_return_status    OUT  VARCHAR2(1)
--              x_msg_count        OUT  NUMBER
--              x_msg_data         OUT  VARCHAR2(2000)
-- Version  : Current version   1.0
--
-- Notes        : This procedure calculates the estimates for the Work Order for the
--                Legal Entity/Cost Group/Cost Type association
--
-- End of comments


PROCEDURE Compute_PAC_JobEstimates (
              p_api_version      IN   NUMBER,
              p_init_msg_list    IN   VARCHAR2 := FND_API.G_FALSE,
              p_commit           IN   VARCHAR2 := FND_API.G_FALSE,
              p_validation_level IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
              x_return_status    OUT  NOCOPY  VARCHAR2,
              x_msg_count        OUT  NOCOPY  NUMBER,
              x_msg_data         OUT  NOCOPY  VARCHAR2,
              p_legal_entity_id  IN   NUMBER,
              p_cost_group_id    IN   NUMBER,
              p_cost_type_id     IN   NUMBER,
              p_Period_id        IN   NUMBER,
              p_wip_entity_id    IN   NUMBER,
              p_user_id          IN   NUMBER,
              p_request_id       IN   NUMBER,
              p_prog_id          IN   NUMBER,
              p_prog_app_id      IN   NUMBER,
              p_login_id         IN   NUMBER
);


-- Start of comments
--  API name    : InsertUpdate_pac_eamPerBal
--  Type        : Public.
--  Function    : This API is called from Compute_PAC_JobEstimates and Compute_PAC_JobActuals
--                Flow:
--                |-- Identify column to update value
--                |-- IF p_value_type = 1 THEN           ==> actual_cost
--                |   |-- IF p_eam_cost_element = 1 THEN    --> equipment
--                |   |   |-- l_column := 'actual_eqp_cost';
--                |   |   |-- l_col_type := 11;
--                |   |-- ELSIF p_eam_cost_element = 2 THEN --> labor
--                |   |   |-- l_column := 'actual_lab_cost';
--                |   |   |-- l_col_type := 12;
--                |   |-- ELSE                              --> material
--                |   |   |-- l_column := 'actual_mat_cost';
--                |   |   |-- l_col_type := 13;
--                |   |   END IF;
--                |-- ELSE                                ==> system estimated
--                |   |-- IF p_eam_cost_element = 1 THEN     --> equipment
--                |   |   |-- l_column := 'system_estimated_eqp_cost';
--                |   |   |-- l_col_type := 21;
--                |   |-- ELSIF p_eam_cost_element = 2 THEN  --> labor
--                |   |   |-- l_column := 'system_estimated_lab_cost';
--                |   |   |-- l_col_type := 22;
--                |   |-- ELSE                              --> material
--                |   |   |-- l_column := 'system_estimated_mat_cost';
--                |   |   |-- l_col_type := 23;
--                |   |   END IF;
--                |   END IF;
--                |-- Insert/update CST_PAC_EAM_PERIOD_BALANCES
--                |   |-- Check if txn record already existing CST_PAC_EAM_PERIOD_BALANCES
--                |   |   |-- If yes then UPDATE estimation details
--                |   |   |-- Else Insert estimation details
--                |-- Insert into asset period balances, call InsertUpdate_pac_assetPerBal
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version      IN NUMBER   Required
--              p_init_msg_list    IN VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_commit           IN VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_validation_level IN NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--              p_legal_entity_id  IN NUMBER
--              p_cost_group_id    IN NUMBER
--              p_cost_type_id     IN NUMBER
--              p_period_id        IN NUMBER   Optional Default = null
--              p_period_set_name  IN VARCHAR2 Optional Default = null
--              p_period_name      IN VARCHAR2 Optional Default = null
--              p_organization_id  IN NUMBER   Required
--              p_wip_entity_id    IN NUMBER   Required
--              p_owning_dept_id   IN NUMBER   Required
--              p_dept_id          IN NUMBER   Required
--              p_maint_cost_cat   IN NUMBER   Required
--              p_opseq_num        IN NUMBER   Required
--              p_eam_cost_element IN NUMBER   Required
--              p_asset_group_id   IN NUMBER   Required
--              p_asset_number     IN VARCHAR2 Required
--              p_value_type       IN NUMBER   Required
--              p_value            IN NUMBER   Required
--              p_user_id          IN NUMBER   Required
--              p_request_id       IN NUMBER   Required
--              p_prog_id          IN NUMBER   Required
--              p_prog_app_id      IN NUMBER   Required
--              p_login_id         IN NUMBER   Required
--  OUT     :   x_return_status     OUT VARCHAR2(1)
--              x_msg_count         OUT NUMBER
--              x_msg_data          OUT VARCHAR2(2000)
--  Version : Current version   1.0
--
--  Notes       : This procedure inserts actuals (p_value_type = 1) or estimated (p_value_type = 2)
--                values into CST_PAC_EAM_PERIOD_BALANCES
--
-- End of comments

PROCEDURE InsertUpdate_PAC_eamPerBal (
              p_api_version      IN          NUMBER,
              p_init_msg_list    IN          VARCHAR2 := FND_API.G_FALSE,
              p_commit           IN          VARCHAR2 := FND_API.G_FALSE,
              p_validation_level IN          VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
              x_return_status    OUT NOCOPY  VARCHAR2,
              x_msg_count        OUT NOCOPY  NUMBER,
              x_msg_data         OUT NOCOPY  VARCHAR2,
              p_legal_entity_id  IN          NUMBER,
              p_cost_group_id    IN          NUMBER,
              p_cost_type_id     IN          NUMBER,
              p_period_id        IN          NUMBER   := null,
              p_period_set_name  IN          VARCHAR2 := null,
              p_period_name      IN          VARCHAR2 := null,
              p_organization_id  IN          NUMBER,
              p_wip_entity_id    IN          NUMBER,
              p_owning_dept_id   IN          NUMBER,
              p_dept_id          IN          NUMBER,
              p_maint_cost_cat   IN          NUMBER,
              p_opseq_num        IN          NUMBER,
              p_eam_cost_element IN          NUMBER,
              p_asset_group_id   IN          NUMBER,
              p_asset_number     IN          VARCHAR2,
              p_value_type       IN          NUMBER,
              p_value            IN          NUMBER,
              p_user_id          IN          NUMBER,
              p_request_id       IN          NUMBER,
              p_prog_id          IN          NUMBER,
              p_prog_app_id      IN          NUMBER,
              p_login_id         IN          NUMBER
);


-- Start of comments
--  API name    : InsertUpdate_pac_assetPerBal
--  Type        : Public.
--  Function    : This API is called from InsertUpdate_PAC_eamPerBal
--                Flow:
--                Check if records already exist in CST_EAM_PAC_ASSET_PER_BALANCES
--                |-- If yes then Update CST_PAC_EAM_ASSET_PER_BALANCES
--                |-- Else Insert into CST_PAC_EAM_ASSET_PER_BALANCES
--                End if
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version       IN  NUMBER   Required
--              p_init_msg_list     IN  VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_commit            IN  VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_validation_level  IN  NUMBER   Optional Default = FND_API.G_VALID_LEVEL_FULL
--              p_legal_entity_id   IN  NUMBER,
--              p_cost_group_id     IN  NUMBER,
--              p_cost_type_id      IN  NUMBER,
--              p_period_id         IN  NUMBER   Default = null,
--              p_period_set_name   IN  VARCHAR2 Default = null,
--              p_period_name       IN  VARCHAR2 Default = null,
--              p_organization_id   IN  NUMBER,
--              p_maint_cost_cat    IN  NUMBER,
--              p_asset_group_id    IN  NUMBER,
--              p_asset_number      IN  VARCHAR2,
--              p_value             IN  NUMBER,
--              p_column            IN  VARCHAR2,
--              p_col_type          IN  NUMBER,
--              p_period_start_date IN  DATE,
--              p_user_id           IN  NUMBER,
--              p_request_id        IN  NUMBER,
--              p_prog_id           IN  NUMBER,
--              p_prog_app_id       IN  NUMBER,
--              p_login_id          IN  NUMBER,
--              p_maintenance_object_id IN NUMBER, -- Added as part of eam enhancements project - R12
--              p_maintenance_object_type IN NUMBER  -- Added as part of eam enhancements project - R12
--  OUT     :   x_return_status     OUT VARCHAR2(1)
--              x_msg_count         OUT NUMBER
--              x_msg_data          OUT VARCHAR2(2000)
--  Version : Current version   1.0
--
--  Notes       : This procedure insets or Updates Actual/Estimate details at the Asset Group/Serial Number level
--
-- End of comments

PROCEDURE InsertUpdate_PAC_assetPerBal (
              p_api_version          IN         NUMBER,
              p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
              p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
              p_validation_level     IN         VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
              x_return_status        OUT NOCOPY VARCHAR2,
              x_msg_count            OUT NOCOPY NUMBER,
              x_msg_data             OUT NOCOPY VARCHAR2,
              p_legal_entity_id      IN         NUMBER,
              p_cost_group_id        IN         NUMBER,
              p_cost_type_id         IN         NUMBER,
              p_period_id            IN         NUMBER   := null,
              p_period_set_name      IN         VARCHAR2 := null,
              p_period_name          IN         VARCHAR2 := null,
              p_organization_id      IN         NUMBER,
              p_maint_cost_cat       IN         NUMBER,
              p_asset_group_id       IN         NUMBER,
              p_asset_number         IN         VARCHAR2,
              p_value                IN         NUMBER,
              p_column               IN         VARCHAR2,
              p_col_type             IN         NUMBER,
              p_period_start_date    IN         DATE,
              p_maintenance_object_id IN        NUMBER,
              p_maintenance_object_type IN      NUMBER,
              p_user_id              IN         NUMBER,
              p_request_id           IN         NUMBER,
              p_prog_id              IN         NUMBER,
              p_prog_app_id          IN         NUMBER,
              p_login_id             IN         NUMBER
);


-- Start of comments
--  API name    : Compute_PAC_JobActuals
--  Type        : Public.
--  Function    : This API is called from CSTPPWRO.process_wip_resovhd_txns and
--                  CSTPPWMT.charge_wip_material
--                Flow:
--                |-- Get Period set name and Period name from Period ID passed
--                |-- Get asset group, asset number and maint obj for the wip_entity_id
--                |-- Derive the currency extended precision for the organization
--                |-- Get maint cost category
--                |-- Get eAM cost element
--                |   |-- If Direct Items use get_CostEle_for_DirectItem
--                |   |-- Else use Get_eamCostElement
--                |-- End If
--                |-- Call API InsertUpdate_PAC_eamPerBal to update eAM PAC tables.
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version       IN  NUMBER   Required
--              p_init_msg_list     IN  VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_commit            IN  VARCHAR2 Optional Default = FND_API.G_FALSE
--              p_validation_level  IN  NUMBER   Optional Default =
--                                                        FND_API.G_VALID_LEVEL_FULL
--              p_legal_entity_id   IN  NUMBER,
--              p_cost_group_id     IN  NUMBER,
--              p_cost_type_id      IN  NUMBER,
--              p_period_id         IN  NUMBER   Default = null,
--              p_organization_id   IN  NUMBER,
--              p_txn_mode          IN  NUMBER,
--              p_txn_id            IN  NUMBER,
--              p_value             IN  NUMBER,
--              p_entity_id         IN  NUMBER,
--              p_op_seq            IN  NUMBER,
--              p_resource_id       IN  NUMBER,
--              p_resource_seq_num  IN  NUMBER,
--              p_user_id           IN  NUMBER,
--              p_request_id        IN  NUMBER,
--              p_prog_id           IN  NUMBER,
--              p_prog_app_id       IN  NUMBER,
--              p_login_id          IN  NUMBER
--  OUT     :   x_return_status     OUT VARCHAR2(1)
--              x_msg_count         OUT NUMBER
--              x_msg_data          OUT VARCHAR2(2000)
--  Version : Current version   1.0
--
--  Notes       : This procedure gets asset, cost element and category associations
--                for the actual txns and then calls API's to update PAC_EAM tables
--
-- End of comments

PROCEDURE Compute_PAC_JobActuals(
                    p_api_version      IN NUMBER,
                    p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
                    p_commit           IN VARCHAR2 := FND_API.G_FALSE,
                    p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                    x_return_status    OUT NOCOPY VARCHAR2,
                    x_msg_count        OUT NOCOPY NUMBER,
                    x_msg_data         OUT NOCOPY VARCHAR2,
                    p_legal_entity_id  IN NUMBER,
                    p_cost_group_id    IN NUMBER,
                    p_cost_type_id     IN NUMBER,
                    p_pac_period_id    IN NUMBER,
                    p_pac_ct_id        IN NUMBER,
                    p_organization_id  IN NUMBER,
                    p_txn_mode         IN NUMBER, -- To indicate Resource/Direct Item Txn
                    p_txn_id           IN NUMBER,
                    p_value            IN NUMBER,
                    p_wip_entity_id    IN NUMBER,
                    p_op_seq           IN NUMBER,
                    p_resource_id      IN NUMBER,
                    p_resource_seq_num IN NUMBER,
                    p_user_id          IN NUMBER,
                    p_request_id       IN NUMBER,
                    p_prog_app_id      IN NUMBER,
                    p_prog_id          IN NUMBER,
                    p_login_id         IN NUMBER
);


-- Start of comments
--  API name    : Insert_PAC_eamBalAcct
--  Type        : Public.
--  Function    : This API is called from CST_PacEamCost_GRP.Estimate_PAC_WipJobs.
--                The procedure inserts/updates data into CST_PAC_EAM_BALANCE_BY_ACCTS
--                table.
--                Flow:
--                |-- Verify if the estimation data already exists for the wip job
--                |   and GL Account for the given cost group and cost type.
--                |   |--If data already exists add the new acct_value to existing
--                |      acct_value
--                |   |--Else insert a new row into the table
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version       IN  NUMBER
--              p_init_msg_list     IN  VARCHAR2
--              p_commit            IN  VARCHAR2
--              p_validation_level  IN  NUMBER
--              p_legal_entity_id   IN  NUMBER,
--              p_cost_group_id     IN  NUMBER,
--              p_cost_type_id      IN  NUMBER,
--              p_period_id         IN  NUMBER,
--              p_period_set_name   IN  VARCHAR2,
--              p_period_name       IN  VARCHAR2,
--              p_org_id            IN  NUMBER,
--              p_wip_entity_id     IN  NUMBER,
--              p_owning_dept_id    IN  NUMBER,
--              p_dept_id           IN  NUMBER,
--              p_maint_cost_cat    IN  NUMBER,
--              p_opseq_num         IN  NUMBER,
--              p_period_start_date IN  DATE,
--              p_account_ccid      IN  NUMBER,
--              p_value             IN  NUMBER,
--              p_txn_type          IN  NUMBER,
--              p_wip_acct_class    IN  VARCHAR2,
--              p_mfg_cost_element_id IN NUMBER,
--              p_user_id           IN  NUMBER,
--              p_request_id        IN  NUMBER,
--              p_prog_id           IN  NUMBER,
--              p_prog_app_id       IN  NUMBER,
--              p_login_id          IN  NUMBER
--  OUT     :   x_return_status     OUT VARCHAR2(1)
--              x_msg_count         OUT NUMBER
--              x_msg_data          OUT VARCHAR2(2000)
--  Version : Current version   1.0
--
-- End of comments
PROCEDURE Insert_PAC_eamBalAcct
(
        p_api_version           IN  NUMBER,
        p_init_msg_list         IN  VARCHAR2,
        p_commit                IN  VARCHAR2,
        p_validation_level      IN  NUMBER,
        x_return_status         OUT NOCOPY  VARCHAR2,
        x_msg_count             OUT NOCOPY  NUMBER,
        x_msg_data              OUT NOCOPY  VARCHAR2,
        p_legal_entity_id       IN  NUMBER,
        p_cost_group_id         IN  NUMBER,
        p_cost_type_id          IN  NUMBER,
        p_period_id             IN      NUMBER,
        p_period_set_name       IN      VARCHAR2,
        p_period_name           IN      VARCHAR2,
        p_org_id                IN      NUMBER,
        p_wip_entity_id         IN      NUMBER,
        p_owning_dept_id        IN      NUMBER,
        p_dept_id               IN      NUMBER,
        p_maint_cost_cat        IN      NUMBER,
        p_opseq_num             IN      NUMBER,
        p_period_start_date     IN      DATE,
        p_account_ccid          IN      NUMBER,
        p_value                 IN      NUMBER,
        p_txn_type              IN      NUMBER,
        p_wip_acct_class        IN      VARCHAR2,
        p_mfg_cost_element_id   IN      NUMBER,
        p_user_id               IN      NUMBER,
        p_request_id            IN      NUMBER,
        p_prog_id               IN      NUMBER,
        p_prog_app_id           IN      NUMBER,
        p_login_id              IN      NUMBER
);


-- Start of comments
--  API name    : Delete_PAC_eamBalAcct
--  Type        : Public.
--  Function    : This API is called from CST_PacEamCost_GRP.Estimate_PAC_WipJobs
--                Flow:
--                |-- Delete estimation data from CST_EAM_BALANCE_BY_ACCTS table for the
--                |   given legal entity id, cost group, cost type and wip job
--
--  Pre-reqs    : None.
--  Parameters  :
--  IN      :   p_api_version       IN  NUMBER
--              p_init_msg_list     IN  VARCHAR2
--              p_commit            IN  VARCHAR2
--              p_validation_level  IN  NUMBER
--
--              p_legal_entity_id   IN  NUMBER,
--              p_cost_group_id     IN  NUMBER,
--              p_cost_type_id      IN  NUMBER,
--              p_organization_id   IN  NUMBER,
--              p_wip_entity_id_tab IN  CST_PacEamCost_GRP.G_WIP_ENTITY_TYP,
--  OUT     :   x_return_status     OUT VARCHAR2(1)
--              x_msg_count         OUT NUMBER
--              x_msg_data          OUT VARCHAR2(2000)
--  Version : Current version   1.0
--
-- End of comments
PROCEDURE Delete_PAC_eamBalAcct
(
        p_api_version       IN        NUMBER,
        p_init_msg_list     IN        VARCHAR2,
        p_commit            IN        VARCHAR2,
        p_validation_level  IN        NUMBER    ,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY VARCHAR2,
        x_msg_data          OUT NOCOPY VARCHAR2,
        p_wip_entity_id_tab IN        CST_PacEamCost_GRP.G_WIP_ENTITY_TYP,
        p_legal_entity_id   IN        NUMBER,
        p_cost_group_id     IN        NUMBER,
        p_cost_type_id      IN        NUMBER

);

END CST_PacEamCost_GRP;


 

/
