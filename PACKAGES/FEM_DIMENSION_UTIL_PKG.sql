--------------------------------------------------------
--  DDL for Package FEM_DIMENSION_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIMENSION_UTIL_PKG" AUTHID CURRENT_USER AS
--$Header: FEMDIMAPS.pls 120.9 2006/08/24 08:32:28 nmartine ship $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    FEMDIMAPS.pls
 |
 | NAME fem_dimension_util_pkg
 |
 | DESCRIPTION
 |
 |   Package Spec for fem_dimension_util_pkg. This package provides functions
 |   and procedures helpful in querying against dimension tables and views.
 |
 | HISTORY
 |
 |    22-APR-04  BugNo#3570753 - changed c_fem_set_of_books
 |                                 to fem_ledger
 |
 |    09-JUL-04  Rflippo
 |               Bug#3755923 added Task and Fin Elem is pop flags to new_ledger
 |               modified new_ledger signature to use DEFAULT 'N' for is pop
 |               flags
 |    10-AUG-04 Rflippo bug#3824427 - added New_Budget API to create budget members
 |    22-NOV-04 gcheng  Bug 4005877 - added Relative_Cal_Period_ID function.
 |    13-JAN-05 gcheng  Bug 3824701 - altered Register_Data_Location signature
 |
 |    21-APR-05 RFlippo  Bug#4303380  Add Global_vs_combo_display_code as parm
 |                       to New_Global_VS_Combo_ID procedure.
 |    15-JUN-05 gcheng  4417618. Created the Get_Default_Dim_Member procedures.
 |    30-JUN-05 gcheng  4143586. Added another version to the overloaded
 |                      Generate_Default_Load_Member procedure.
 |    24-OCT-05 tmoore  4619062. Added Get_Dim_Member_Display_Code
 |    10-FEB-06 gcheng  5011140 (FP:4596447). Added an optional parameter
 |              v120.7  p_table_name to UnRegister_Data_Location.
 |    17-MAR-06 rflippo 5102692 Overload Generate_Member_ID for Cal
 |                      Period dim
 |    24-AUG-06 nmartine Bug 5473131. Added Get_Dim_Member_Name.
 +=========================================================================*/


------------------------
--  Package Constants --
------------------------

c_fem_ledger       CONSTANT  VARCHAR2(30) := 'FEM_LEDGER';
c_false            CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true             CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
c_success          CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
c_error            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
c_unexp            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
c_api_version      CONSTANT  NUMBER       := 1.0;

------------------
--  Subprograms --
------------------
PROCEDURE FEM_INITIALIZE (
   p_ledger_id        IN NUMBER
);

FUNCTION Application_Group_ID
RETURN NUMBER;

FUNCTION Global_VS_Combo_ID (
   p_ledger_id        IN NUMBER,
   x_err_code        OUT NOCOPY NUMBER,
   x_num_msg         OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION Global_VS_Combo_ID (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_ledger_id       IN NUMBER
) RETURN NUMBER;

FUNCTION Local_VS_Combo_ID (
   p_ledger_id        IN NUMBER,
   x_err_code        OUT NOCOPY NUMBER,
   x_num_msg         OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION Local_VS_Combo_ID (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_ledger_id       IN NUMBER
) RETURN NUMBER;

FUNCTION Dimension_Value_Set_ID (
   p_dimension_id    IN NUMBER,
   p_ledger_id       IN NUMBER DEFAULT NULL
) RETURN NUMBER;

FUNCTION Dimension_Value_Set_ID (
   p_dimension_id    IN NUMBER,
   p_ledger_id       IN NUMBER,
   x_err_code       OUT NOCOPY NUMBER,
   x_num_msg        OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION Dimension_Value_Set_ID (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_dimension_id    IN NUMBER,
   p_ledger_id       IN NUMBER
) RETURN NUMBER;

FUNCTION Is_Rule_Valid_For_Ledger (
   p_object_id        IN NUMBER,
   p_ledger_id        IN NUMBER
) RETURN VARCHAR2;

FUNCTION Relative_Cal_Period_ID (
   p_api_version        IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list      IN VARCHAR2   DEFAULT c_false,
   p_commit             IN VARCHAR2   DEFAULT c_false,
   p_encoded            IN VARCHAR2   DEFAULT c_true,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_per_num_offset     IN NUMBER,
   p_base_cal_period_id IN NUMBER
) RETURN NUMBER;

FUNCTION Effective_Cal_Period_ID (
   p_per_num_offset   IN NUMBER,
   p_rel_dim_grp_id   IN NUMBER,
   p_ledger_id        IN NUMBER,
   p_ref_cal_per_id   IN NUMBER,
   x_err_code        OUT NOCOPY NUMBER,
   x_num_msg         OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION Get_Cal_Period_ID (
   p_ledger_id       IN NUMBER,
   p_dim_grp_dc      IN VARCHAR2,
   p_cal_per_num     IN NUMBER,
   p_fiscal_year     IN NUMBER
) RETURN NUMBER;

FUNCTION Get_Cal_Period_ID (
   p_ledger_id        IN NUMBER,
   p_dim_grp_dc       IN VARCHAR2,
   p_cal_per_num      IN NUMBER,
   p_cal_per_end_date IN DATE
) RETURN NUMBER;

PROCEDURE Register_Data_Location (
   p_request_id      IN NUMBER,
   p_object_id       IN NUMBER,
   p_table_name      IN VARCHAR2,
   p_ledger_id       IN NUMBER,
   p_cal_per_id      IN NUMBER,
   p_dataset_cd      IN NUMBER,
   p_source_cd       IN NUMBER,
   p_load_status     IN VARCHAR2 DEFAULT NULL,
   p_avg_bal_flag    IN VARCHAR2 DEFAULT NULL,
   p_trans_curr      IN VARCHAR2 DEFAULT NULL
);

PROCEDURE UnRegister_Data_Location (
   p_request_id      IN NUMBER,
   p_object_id       IN NUMBER,
   p_table_name      IN VARCHAR2 DEFAULT NULL
);

FUNCTION Generate_Member_ID (
   p_dim_id          IN   NUMBER
) RETURN NUMBER;

FUNCTION Generate_Member_ID (
   p_dim_id          IN NUMBER,
   x_err_code       OUT NOCOPY NUMBER,
   x_num_msg        OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION Generate_Member_ID (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_dim_id          IN NUMBER
) RETURN NUMBER;

FUNCTION Generate_Member_ID (
   p_end_date        IN DATE,
   p_period_num      IN NUMBER,
   p_calendar_id     IN NUMBER,
   p_dim_grp_id      IN NUMBER
) RETURN NUMBER;

FUNCTION Generate_Member_ID (
   p_end_date        IN DATE,
   p_period_num      IN NUMBER,
   p_calendar_dc     IN VARCHAR2,
   p_dim_grp_dc      IN VARCHAR2
) RETURN NUMBER;

FUNCTION Generate_Member_ID (
   p_end_date        IN DATE,
   p_period_num      IN NUMBER,
   p_calendar_id     IN NUMBER,
   p_dim_grp_id      IN NUMBER,
   x_err_code       OUT NOCOPY NUMBER,
   x_num_msg        OUT NOCOPY NUMBER
) RETURN NUMBER;

FUNCTION Generate_Member_ID (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_end_date        IN DATE,
   p_period_num      IN NUMBER,
   p_calendar_id     IN NUMBER,
   p_dim_grp_id      IN NUMBER
) RETURN NUMBER;

FUNCTION Generate_Member_ID (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_end_date        IN DATE,
   p_period_num      IN NUMBER,
   p_calendar_dc     IN VARCHAR2,
   p_dim_grp_dc      IN VARCHAR2
) RETURN NUMBER;

PROCEDURE Generate_Default_Load_Member (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_dim_label       IN VARCHAR2,
   p_vs_id           IN NUMBER     DEFAULT NULL,
   x_member_code    OUT NOCOPY VARCHAR2
);

PROCEDURE Generate_Default_Load_Member (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_vs_id           IN NUMBER
);

PROCEDURE Generate_Default_Load_Member (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2
);

PROCEDURE New_Dataset (
   p_display_code    IN VARCHAR2,
   p_dataset_name    IN VARCHAR2,
   p_bal_type_cd     IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_pft_w_flg       IN VARCHAR2   DEFAULT 'Y',
   p_prod_flg        IN VARCHAR2   DEFAULT 'Y',
   p_budget_id       IN NUMBER,
   p_enc_type_id     IN NUMBER,
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2,
   p_dataset_desc    IN VARCHAR2,
   x_err_code       OUT NOCOPY NUMBER,
   x_num_msg        OUT NOCOPY NUMBER
);

PROCEDURE New_Dataset (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_display_code    IN VARCHAR2,
   p_dataset_name    IN VARCHAR2,
   p_bal_type_cd     IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_pft_w_flg       IN VARCHAR2   DEFAULT 'Y',
   p_prod_flg        IN VARCHAR2   DEFAULT 'Y',
   p_budget_id       IN NUMBER,
   p_enc_type_id     IN NUMBER,
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2,
   p_dataset_desc    IN VARCHAR2
);
-- API for creating a new Budget dimension member
PROCEDURE New_Budget (
   p_api_version             IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list           IN VARCHAR2   DEFAULT c_false,
   p_commit                  IN VARCHAR2   DEFAULT c_false,
   p_encoded                 IN VARCHAR2   DEFAULT c_true,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,
   p_budget_display_code     IN VARCHAR2,
   p_budget_name             IN VARCHAR2,
   p_budget_ledger           IN VARCHAR2,
   p_require_journals_flag   IN VARCHAR2,
   p_budget_status_code      IN VARCHAR2,
   p_budget_latest_open_year IN NUMBER,
   p_budget_source_system    IN VARCHAR2,
   p_first_period_calendar   IN VARCHAR2,
   p_first_period_dimgrp     IN VARCHAR2,
   p_first_period_number     IN VARCHAR2,
   p_first_period_end_date   IN DATE,
   p_last_period_calendar    IN VARCHAR2,
   p_last_period_dimgrp      IN VARCHAR2,
   p_last_period_number      IN VARCHAR2,
   p_last_period_end_date    IN DATE,
   p_ver_name                IN VARCHAR2,
   p_ver_disp_cd             IN VARCHAR2,
   p_budget_desc             IN VARCHAR2
);

PROCEDURE Register_Budget (
   p_api_version             IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list           IN VARCHAR2   DEFAULT c_false,
   p_commit                  IN VARCHAR2   DEFAULT c_false,
   p_encoded                 IN VARCHAR2   DEFAULT c_true,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,
   p_budget_id               IN NUMBER,
   p_budget_display_code     IN VARCHAR2,
   p_budget_name             IN VARCHAR2,
   p_budget_ledger           IN VARCHAR2,
   p_require_journals_flag   IN VARCHAR2,
   p_budget_status_code      IN VARCHAR2,
   p_budget_latest_open_year IN NUMBER,
   p_budget_source_system    IN VARCHAR2,
   p_first_period_calendar   IN VARCHAR2,
   p_first_period_dimgrp     IN VARCHAR2,
   p_first_period_number     IN VARCHAR2,
   p_first_period_end_date   IN DATE,
   p_last_period_calendar    IN VARCHAR2,
   p_last_period_dimgrp      IN VARCHAR2,
   p_last_period_number      IN VARCHAR2,
   p_last_period_end_date    IN DATE,
   p_ver_name                IN VARCHAR2,
   p_ver_disp_cd             IN VARCHAR2,
   p_budget_desc             IN VARCHAR2
);

PROCEDURE New_Ledger (
   p_display_code    IN VARCHAR2,
   p_ledger_name     IN VARCHAR2,
   p_func_curr_cd    IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_cal_per_hid     IN NUMBER,
   p_global_vs_id    IN NUMBER,
   p_epb_def_lg_flg  IN VARCHAR2,
   p_ent_curr_flg    IN VARCHAR2,
   p_avg_bal_flg     IN VARCHAR2,
   p_chan_flg        IN VARCHAR2 DEFAULT 'N',
   p_cctr_flg        IN VARCHAR2 DEFAULT 'N',
   p_cust_flg        IN VARCHAR2 DEFAULT 'N',
   p_geog_flg        IN VARCHAR2 DEFAULT 'N',
   p_ln_item_flg     IN VARCHAR2 DEFAULT 'N',
   p_nat_acct_flg    IN VARCHAR2 DEFAULT 'N',
   p_prod_flg        IN VARCHAR2 DEFAULT 'N',
   p_proj_flg        IN VARCHAR2 DEFAULT 'N',
   p_entity_flg      IN VARCHAR2 DEFAULT 'N',
   p_user1_flg       IN VARCHAR2 DEFAULT 'N',
   p_user2_flg       IN VARCHAR2 DEFAULT 'N',
   p_user3_flg       IN VARCHAR2 DEFAULT 'N',
   p_user4_flg       IN VARCHAR2 DEFAULT 'N',
   p_user5_flg       IN VARCHAR2 DEFAULT 'N',
   p_user6_flg       IN VARCHAR2 DEFAULT 'N',
   p_user7_flg       IN VARCHAR2 DEFAULT 'N',
   p_user8_flg       IN VARCHAR2 DEFAULT 'N',
   p_user9_flg       IN VARCHAR2 DEFAULT 'N',
   p_user10_flg      IN VARCHAR2 DEFAULT 'N',
   p_task_flg        IN VARCHAR2 DEFAULT 'N',
   p_fin_elem_flg    IN VARCHAR2 DEFAULT 'N',
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2,
   p_ledger_desc     IN VARCHAR2,
   x_err_code       OUT NOCOPY NUMBER,
   x_num_msg        OUT NOCOPY NUMBER
);

PROCEDURE New_Ledger (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_display_code    IN VARCHAR2,
   p_ledger_name     IN VARCHAR2,
   p_func_curr_cd    IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_cal_per_hid     IN NUMBER,
   p_global_vs_id    IN NUMBER,
   p_epb_def_lg_flg  IN VARCHAR2,
   p_ent_curr_flg    IN VARCHAR2,
   p_avg_bal_flg     IN VARCHAR2,
   p_chan_flg        IN VARCHAR2 DEFAULT 'N',
   p_cctr_flg        IN VARCHAR2 DEFAULT 'N',
   p_cust_flg        IN VARCHAR2 DEFAULT 'N',
   p_geog_flg        IN VARCHAR2 DEFAULT 'N',
   p_ln_item_flg     IN VARCHAR2 DEFAULT 'N',
   p_nat_acct_flg    IN VARCHAR2 DEFAULT 'N',
   p_prod_flg        IN VARCHAR2 DEFAULT 'N',
   p_proj_flg        IN VARCHAR2 DEFAULT 'N',
   p_entity_flg      IN VARCHAR2 DEFAULT 'N',
   p_user1_flg       IN VARCHAR2 DEFAULT 'N',
   p_user2_flg       IN VARCHAR2 DEFAULT 'N',
   p_user3_flg       IN VARCHAR2 DEFAULT 'N',
   p_user4_flg       IN VARCHAR2 DEFAULT 'N',
   p_user5_flg       IN VARCHAR2 DEFAULT 'N',
   p_user6_flg       IN VARCHAR2 DEFAULT 'N',
   p_user7_flg       IN VARCHAR2 DEFAULT 'N',
   p_user8_flg       IN VARCHAR2 DEFAULT 'N',
   p_user9_flg       IN VARCHAR2 DEFAULT 'N',
   p_user10_flg      IN VARCHAR2 DEFAULT 'N',
   p_task_flg        IN VARCHAR2 DEFAULT 'N',
   p_fin_elem_flg    IN VARCHAR2 DEFAULT 'N',
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2,
   p_ledger_desc     IN VARCHAR2
);

PROCEDURE Register_Ledger (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_ledger_id       IN NUMBER,
   p_display_code    IN VARCHAR2,
   p_ledger_name     IN VARCHAR2,
   p_func_curr_cd    IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_cal_per_hid     IN NUMBER,
   p_global_vs_id    IN NUMBER,
   p_epb_def_lg_flg  IN VARCHAR2,
   p_ent_curr_flg    IN VARCHAR2,
   p_avg_bal_flg     IN VARCHAR2,
   p_chan_flg        IN VARCHAR2 DEFAULT 'N',
   p_cctr_flg        IN VARCHAR2 DEFAULT 'N',
   p_cust_flg        IN VARCHAR2 DEFAULT 'N',
   p_geog_flg        IN VARCHAR2 DEFAULT 'N',
   p_ln_item_flg     IN VARCHAR2 DEFAULT 'N',
   p_nat_acct_flg    IN VARCHAR2 DEFAULT 'N',
   p_prod_flg        IN VARCHAR2 DEFAULT 'N',
   p_proj_flg        IN VARCHAR2 DEFAULT 'N',
   p_entity_flg      IN VARCHAR2 DEFAULT 'N',
   p_user1_flg       IN VARCHAR2 DEFAULT 'N',
   p_user2_flg       IN VARCHAR2 DEFAULT 'N',
   p_user3_flg       IN VARCHAR2 DEFAULT 'N',
   p_user4_flg       IN VARCHAR2 DEFAULT 'N',
   p_user5_flg       IN VARCHAR2 DEFAULT 'N',
   p_user6_flg       IN VARCHAR2 DEFAULT 'N',
   p_user7_flg       IN VARCHAR2 DEFAULT 'N',
   p_user8_flg       IN VARCHAR2 DEFAULT 'N',
   p_user9_flg       IN VARCHAR2 DEFAULT 'N',
   p_user10_flg      IN VARCHAR2 DEFAULT 'N',
   p_task_flg        IN VARCHAR2 DEFAULT 'N',
   p_fin_elem_flg    IN VARCHAR2 DEFAULT 'N',
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2,
   p_ledger_desc     IN VARCHAR2
);

PROCEDURE New_Encumbrance_Type (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_enc_type_id    OUT NOCOPY NUMBER,
   p_enc_type_code   IN VARCHAR2,
   p_enc_type_name   IN VARCHAR2,
   p_enc_type_desc   IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2
);

PROCEDURE Register_Encumbrance_Type (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_enc_type_id     IN NUMBER,
   p_enc_type_code   IN VARCHAR2,
   p_enc_type_name   IN VARCHAR2,
   p_enc_type_desc   IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2
);

PROCEDURE New_Global_VS_Combo (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_global_vs_combo_id  OUT NOCOPY NUMBER,
   p_global_vs_combo_name IN VARCHAR2,
   p_global_vs_combo_desc IN VARCHAR2 DEFAULT NULL,
   p_read_only_flag       IN VARCHAR2 DEFAULT 'N',
   p_enabled_flag         IN VARCHAR2 DEFAULT 'Y',
   p_global_vs_combo_dc   IN VARCHAR2 DEFAULT NULL
);

PROCEDURE Get_Dim_Attr_ID_Ver_ID (
   p_dim_id          IN NUMBER,
   p_attr_label      IN VARCHAR,
   x_attr_id        OUT NOCOPY NUMBER,
   x_ver_id         OUT NOCOPY NUMBER,
   x_err_code       OUT NOCOPY NUMBER
);

FUNCTION Get_Dim_Member_ID (
   p_api_version                 IN  NUMBER     DEFAULT 1.0,
   p_init_msg_list               IN  VARCHAR2   DEFAULT c_false,
   p_commit                      IN  VARCHAR2   DEFAULT c_false,
   p_encoded                     IN  VARCHAR2   DEFAULT c_true,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_dimension_varchar_label     IN  VARCHAR2,
   p_member_display_code         IN  VARCHAR2,
   p_member_vs_display_code      IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Get_Dim_Attr_Name (
   p_attr_id         IN NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Dim_Attr_Name (
   p_dim_id          IN NUMBER,
   p_attr_label      IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Get_Dim_Attr_Name (
   p_dim_label       IN VARCHAR2,
   p_attr_label      IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Get_Dimension_Name (
   p_dim_id          IN NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Dimension_Name (
   p_dim_label       IN VARCHAR2
) RETURN VARCHAR2;

PROCEDURE Validate_OA_Params (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_encoded         IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Default_Dim_Member (
   p_api_version                 IN  NUMBER DEFAULT 1.0,
   p_init_msg_list               IN  VARCHAR2 DEFAULT c_false,
   p_commit                      IN  VARCHAR2 DEFAULT c_false,
   p_encoded                     IN  VARCHAR2 DEFAULT c_true,
   p_dimension_id                IN  NUMBER DEFAULT NULL,
   p_dimension_varchar_label     IN  VARCHAR2 DEFAULT NULL,
   p_ledger_id                   IN  NUMBER DEFAULT NULL,
   x_member_code                 OUT NOCOPY VARCHAR2,
   x_member_data_type            OUT NOCOPY VARCHAR2,
   x_member_display_code         OUT NOCOPY VARCHAR2,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Default_Dim_Member (
   p_api_version                 IN  NUMBER DEFAULT 1.0,
   p_init_msg_list               IN  VARCHAR2 DEFAULT c_false,
   p_commit                      IN  VARCHAR2 DEFAULT c_false,
   p_encoded                     IN  VARCHAR2 DEFAULT c_true,
   p_table_name                  IN  VARCHAR2,
   p_column_name                 IN  VARCHAR2,
   p_ledger_id                   IN  NUMBER DEFAULT NULL,
   x_member_code                 OUT NOCOPY VARCHAR2,
   x_member_data_type            OUT NOCOPY VARCHAR2,
   x_member_display_code         OUT NOCOPY VARCHAR2,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

FUNCTION Get_Dim_Member_Display_Code (
   p_dimension_id                IN  NUMBER,
   p_dimension_member_id         IN  VARCHAR2,
   p_dimension_member_vs_id      IN  NUMBER DEFAULT NULL
) RETURN VARCHAR2;

FUNCTION Get_Dim_Member_Name (
   p_dimension_id                IN  NUMBER,
   p_dimension_member_id         IN  VARCHAR2,
   p_dimension_member_vs_id      IN  NUMBER DEFAULT NULL
) RETURN VARCHAR2;

END FEM_Dimension_Util_Pkg;



 

/
