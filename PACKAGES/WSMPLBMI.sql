--------------------------------------------------------
--  DDL for Package WSMPLBMI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPLBMI" AUTHID CURRENT_USER AS
/* $Header: WSMLBMIS.pls 120.5.12000000.1 2007/01/12 05:36:04 appldev ship $ */


l_debug VARCHAR2(1) := FND_PROFILE.VALUE('MRP_DEBUG');

--***VJ Added for Performance Upgrade***--
--bug 3347485
/*
g_prev_org_id           NUMBER := 0;
g_prev_org_code         VARCHAR2(3);
g_prev_cr_user_id       NUMBER := 0;
g_prev_cr_user_name     VARCHAR2(100);
g_prev_upd_user_id      NUMBER := 0;
g_prev_upd_user_name    VARCHAR2(100);
g_prev_last_op          NUMBER := 0;
g_prev_op_seq_incr      NUMBER := 0;
g_acct_period_id        NUMBER := 0;
*/

g_prev_org_id           NUMBER := -9999;
g_prev_org_code         VARCHAR2(3);
g_prev_cr_user_id       NUMBER := -9999;
g_prev_cr_user_name     VARCHAR2(100);
g_prev_upd_user_id      NUMBER := -9999;
g_prev_upd_user_name    VARCHAR2(100);
g_prev_last_op          NUMBER := -9999;
g_prev_op_seq_incr      NUMBER := -9999;
g_acct_period_id        NUMBER := -9999;
--end bug 3347485

g_prev_txn_date         DATE;
g_allow_bkw_move        NUMBER :=0;
g_param_jump_fm_q       NUMBER :=1;
g_miss_num              CONSTANT NUMBER         := FND_API.G_MISS_NUM;
g_miss_char             CONSTANT VARCHAR2(1)    := FND_API.G_MISS_CHAR;
g_miss_date             CONSTANT DATE           := FND_API.G_MISS_DATE;

--***VJ End Additions***--

--move enh
--move enh? change the code below
g_aps_wps_profile VARCHAR2(1);
g_mrp_debug VARCHAR2(1) := FND_PROFILE.VALUE('MRP_DEBUG');
g_request_id    NUMBER   := FND_GLOBAL.CONC_REQUEST_ID;
--  g_program_update_date   DATE     := sysdate;
g_program_application_id    NUMBER   := FND_GLOBAL.PROG_APPL_ID;
g_program_id    NUMBER  := FND_GLOBAL.CONC_PROGRAM_ID;
g_user_id   NUMBER  := fnd_global.USER_ID;
g_resp_id   NUMBER  := fnd_global.RESP_ID;
g_resp_appl_id NUMBER   := fnd_global.RESP_APPL_ID;
g_login_id NUMBER   := FND_GLOBAL.login_id;
g_del_move_txns NUMBER  := FND_PROFILE.VALUE('WSM_DEL_PROCESSED_MOVE_TXNS');
g_fnd_generic_err_msg   VARCHAR2(4000);


--WIP_CONSTANTS
g_error         CONSTANT NUMBER := WIP_CONSTANTS.ERROR;

g_move_proc     CONSTANT NUMBER := WIP_CONSTANTS.MOVE_PROC;
g_move_val      CONSTANT NUMBER := WIP_CONSTANTS.MOVE_VAL;

g_running       CONSTANT NUMBER := WIP_CONSTANTS.RUNNING;
g_pending       CONSTANT NUMBER := WIP_CONSTANTS.PENDING;

g_queue         CONSTANT NUMBER := WIP_CONSTANTS.QUEUE;
g_run           CONSTANT NUMBER := WIP_CONSTANTS.RUN;
g_tomove        CONSTANT NUMBER := WIP_CONSTANTS.TOMOVE;
g_scrap         CONSTANT NUMBER := WIP_CONSTANTS.SCRAP;

g_no_manual     CONSTANT NUMBER := WIP_CONSTANTS.NO_MANUAL;

g_move_txn          CONSTANT NUMBER := WIP_CONSTANTS.MOVE_TXN;
g_comp_txn          CONSTANT NUMBER := WIP_CONSTANTS.COMP_TXN;
g_ret_txn           CONSTANT NUMBER := WIP_CONSTANTS.RET_TXN;
g_undo_txn           CONSTANT NUMBER := 4;
--WIP_CONSTANTS END


--move enh end



/*-------------------------------------------------------------+
| CUSTOM_VALIDATION:                                           |
---------------------------------------------------------------*/
FUNCTION custom_validation( p_header_id            IN  NUMBER,
                            p_txn_id               IN  NUMBER,
                            p_txn_qty              IN  NUMBER,
                            p_txn_date             IN  DATE,
                            p_txn_uom              IN  VARCHAR2,
                            p_primary_uom          IN  VARCHAR2,
                            p_txn_type             IN  NUMBER,
                            p_fm_op_seq_num        IN  OUT NOCOPY NUMBER,
                            p_fm_op_code           IN  VARCHAR2,
                            p_fm_intraop_step_type IN  NUMBER,
                            p_to_op_seq_num        IN  NUMBER,
                            p_to_op_code           IN  VARCHAR2,
                            p_to_intraop_step_type IN  NUMBER,
                            p_to_dept_id           IN  NUMBER,
                            p_wip_entity_name      IN  VARCHAR2,
                            p_org_id               IN  NUMBER,
                            p_jump_flag            IN  VARCHAR2,
                -- ST : Serial Support Project --
                x_serial_ctrl_code      OUT NOCOPY NUMBER,
                x_available_qty             OUT NOCOPY NUMBER,
                x_current_job_op_seq_num    OUT NOCOPY NUMBER,
                x_current_intraop_step      OUT NOCOPY NUMBER,
                x_current_rtg_op_seq_num    OUT NOCOPY NUMBER,
                x_old_scrap_transaction_id  OUT NOCOPY NUMBER,
                x_old_move_transaction_id   OUT NOCOPY NUMBER,
                -- ST : Serial Support Project --
                            x_err_buf              OUT NOCOPY VARCHAR2,
                            x_undo_source_code  	OUT NOCOPY VARCHAR2
                          ) RETURN NUMBER;


/*-------------------------------------------------------------+
| validate_lot_txn_for_bk_move:                                |
---------------------------------------------------------------*/
FUNCTION validate_lot_txn_for_bk_move( p_org_id                 IN NUMBER,
                                       p_wip_entity_id          IN NUMBER,
                                       p_txn_qty                IN NUMBER,
                                       p_txn_type               IN NUMBER,
                                       p_from_op_seq_num        IN NUMBER,
                                       p_from_op_code           IN VARCHAR2,
                                       p_from_intraop_step_type IN NUMBER,
                                       p_to_op_seq_num          IN NUMBER,
                                       p_to_op_code             IN VARCHAR2,
                                       p_to_intraop_step_type   IN NUMBER,
                                       p_scrap_acct_id          IN NUMBER,
                                       x_err_buf                OUT NOCOPY VARCHAR2
                                     ) RETURN NUMBER;


-- BA: CZH.JUMPENH
/*-------------------------------------------------------------+
| set_undo_txn_id()                                            |
---------------------------------------------------------------*/
FUNCTION set_undo_txn_id( p_org_id                 IN NUMBER,
                          p_wip_entity_id          IN NUMBER,
                          p_undo_txn_id            IN NUMBER,
                          x_err_buf                OUT NOCOPY VARCHAR2
                         ) RETURN NUMBER;

-- EA: CZH.JUMPENH
FUNCTION set_undo_txn_id( p_org_id                 IN NUMBER,
                          p_wip_entity_id          IN NUMBER,
                          p_undo_txn_id            IN NUMBER,
                          p_to_op_seq_num          IN NUMBER,
                          p_undo_jump_fromq        IN BOOLEAN,
                          x_err_buf                OUT NOCOPY VARCHAR2
                         ) RETURN NUMBER;
/*
Commented this procedure to make it a private procedure

Procedure val_jump_from_queue(p_wip_entity_id   IN  NUMBER,
                              p_org_id          IN  NUMBER,
                              p_fm_op_seq_num   IN  NUMBER,
                              p_wo_op_seq_id    IN  NUMBER,
          -- Removed   --     p_wo_qty_in_scrap IN  NUMBER,
                              x_return_code     OUT NOCOPY NUMBER,
                              x_err_buf         OUT NOCOPY VARCHAR2);
*/

--move enh
        Procedure MoveTransaction(retcode         OUT NOCOPY NUMBER,
                                  errbuf          OUT NOCOPY VARCHAR2,
                                  p_group_id      IN  NUMBER);
--move enh end

--MES skaradib
/*
TYPE t_jobop_secondary_qty_rec is RECORD(
    uom_code            WSM_OP_SECONDARY_QUANTITIES.uom_code%TYPE,
    move_in_quantity    WSM_OP_SECONDARY_QUANTITIES.move_in_quantity%TYPE,
    move_out_quantity   WSM_OP_SECONDARY_QUANTITIES.move_out_quantity%TYPE
);
*/

--TYPE t_jobop_secondary_qty_tbl_type is table of t_jobop_secondary_qty_rec index by binary_integer;
TYPE t_sec_uom_code_tbl_type is table of wsm_op_secondary_quantities.UOM_CODE%TYPE index by binary_integer;
TYPE t_sec_move_out_qty_tbl_type is table of wsm_op_secondary_quantities.MOVE_OUT_QUANTITY%TYPE index by binary_integer;

--TYPE t_jobop_sec_qty_tbls_type is table of t_jobop_secondary_qty_tbl_type index by binary_integer;
TYPE t_sec_uom_code_tbls_type is table of t_sec_uom_code_tbl_type index by binary_integer;
TYPE t_sec_move_out_qty_tbls_type is table of t_sec_move_out_qty_tbl_type index by binary_integer;

/*
Type t_jobop_reason_codes_rec is RECORD(
    reason_code     WSM_OP_REASON_CODES.reason_code%TYPE,
    quantity        WSM_OP_REASON_CODES.quantity%TYPE
);

TYPE t_jobop_scrap_codes_tbl_type is table of t_jobop_reason_codes_rec index by binary_integer;
TYPE t_jobop_scrap_codes_tbls_type is table of t_jobop_scrap_codes_tbl_type index by binary_integer;
*/

--TYPE t_jobop_scrap_codes_tbl_type is table of wsm_op_reason_codes%rowtype index by binary_integer;
TYPE t_scrap_codes_tbl_type is table of wsm_op_reason_codes.REASON_CODE%type index by binary_integer;
TYPE t_scrap_code_qty_tbl_type is table of wsm_op_reason_codes.QUANTITY%type index by binary_integer;

TYPE t_scrap_codes_tbls_type is table of t_scrap_codes_tbl_type index by binary_integer;
TYPE t_scrap_code_qty_tbls_type is table of t_scrap_code_qty_tbl_type index by binary_integer;

/*
TYPE t_jobop_bonus_codes_tbl_type is table of t_jobop_reason_codes_rec index by binary_integer;
TYPE t_jobop_bonus_codes_tbls_type is table of t_jobop_bonus_codes_tbl_type index by binary_integer;
*/
TYPE t_bonus_codes_tbl_type is table of wsm_op_reason_codes.REASON_CODE%type index by binary_integer;
TYPE t_bonus_code_qty_tbl_type is table of wsm_op_reason_codes.QUANTITY%type index by binary_integer;

--TYPE t_jobop_bonus_codes_tbls_type is table of t_jobop_bonus_codes_tbl_type index by binary_integer;
TYPE t_bonus_codes_tbls_type is table of t_bonus_codes_tbl_type index by binary_integer;
TYPE t_bonus_code_qty_tbls_type is table of t_bonus_code_qty_tbl_type index by binary_integer;

/*
Type t_jobop_instances_rec is RECORD(
    RESOURCE_SEQ_NUM    WIP_RESOURCE_ACTUAL_TIMES.RESOURCE_SEQ_NUM%TYPE,
    INSTANCE_ID         WIP_RESOURCE_ACTUAL_TIMES.INSTANCE_ID%TYPE,
    SERIAL_NUMBER       WIP_RESOURCE_ACTUAL_TIMES.SERIAL_NUMBER%TYPE,
    EMPLOYEE_ID         WIP_RESOURCE_ACTUAL_TIMES.EMPLOYEE_ID%TYPE
);

TYPE t_jobop_instances_tbl_type is table of t_jobop_instances_rec index by binary_integer;
TYPE t_jobop_instances_tbls_type is table of t_jobop_instances_tbl_type index by binary_integer;
*/

TYPE t_jobop_res_usages_tbl_type is table of WIP_RESOURCE_ACTUAL_TIMES%ROWTYPE index by binary_integer;
--TYPE t_jobop_res_usages_tbl_type is table of t_jobop_res_usages_rec index by binary_integer;
TYPE t_jobop_res_usages_tbls_type is table of t_jobop_res_usages_tbl_type index by binary_integer;

--TYPE WSM_SERIAL_NUM_TBL is table of WSM_Serial_support_GRP.WSM_SERIAL_NUM_REC index by binary_integer;
--TYPE WSM_SERIAL_NUM_TBL is table of WSM_SERIAL_TXN_INTERFACE%ROWTYPE index by binary_integer;

TYPE t_scrap_serials_tbls_type is table of WSM_Serial_support_GRP.WSM_SERIAL_NUM_TBL index by binary_integer;
TYPE t_bonus_serials_tbls_type is table of WSM_Serial_support_GRP.WSM_SERIAL_NUM_TBL index by binary_integer;

Procedure MoveTransaction(
    p_group_id                              IN NUMBER,
    p_transaction_id                        IN NUMBER,
    p_source_code                           IN VARCHAR2,
    p_TRANSACTION_TYPE                      IN NUMBER,
    p_ORGANIZATION_ID                       IN NUMBER,
    p_WIP_ENTITY_ID                         IN NUMBER,
    p_WIP_ENTITY_NAME                       IN VARCHAR2,
    p_primary_item_id                       IN NUMBER,
    p_TRANSACTION_DATE                      IN DATE,
    p_FM_OPERATION_SEQ_NUM                  IN NUMBER,
    p_FM_OPERATION_CODE                     IN VARCHAR2,
    p_FM_DEPARTMENT_ID                      IN NUMBER,
    p_FM_DEPARTMENT_CODE                    IN VARCHAR2,
    p_FM_INTRAOPERATION_STEP_TYPE           IN NUMBER,
    p_TO_OPERATION_SEQ_NUM                  IN NUMBER,
    p_TO_OPERATION_CODE                     IN VARCHAR2,
    p_TO_DEPARTMENT_ID                      IN NUMBER,
    p_TO_DEPARTMENT_CODE                    IN VARCHAR2,
    p_TO_INTRAOPERATION_STEP_TYPE           IN NUMBER,
    p_PRIMARY_QUANTITY                      IN NUMBER,
    p_low_yield_trigger_limit               IN NUMBER,
    p_primary_uom                           IN VARCHAR2,
    p_SCRAP_ACCOUNT_ID                      IN NUMBER,
    p_REASON_ID                             IN NUMBER,
    p_REASON_NAME                           IN VARCHAR2,
    p_REFERENCE                             IN VARCHAR2,
    p_QA_COLLECTION_ID                      IN NUMBER,
    p_JUMP_FLAG                             IN VARCHAR2,
    p_HEADER_ID                             IN NUMBER,
    p_PRIMARY_SCRAP_QUANTITY                IN NUMBER,
    p_bonus_quantity                        IN NUMBER,
    p_SCRAP_AT_OPERATION_FLAG               IN NUMBER,
    p_bonus_account_id                      IN NUMBER,
    p_employee_id                           IN NUMBER,
    p_operation_start_date                  IN DATE,
    p_operation_completion_date             IN DATE,
    p_expected_completion_date              IN DATE,
    p_mtl_txn_hdr_id                        IN NUMBER,
    p_sec_uom_code_tbl                     IN t_sec_uom_code_tbl_type,
    p_sec_move_out_qty_tbl                 IN t_sec_move_out_qty_tbl_type,
    p_jobop_scrap_serials_tbl              IN WSM_Serial_support_GRP.WSM_SERIAL_NUM_TBL,
    p_jobop_bonus_serials_tbl              IN WSM_Serial_support_GRP.WSM_SERIAL_NUM_TBL,
    p_scrap_codes_tbl                      IN t_scrap_codes_tbl_type,
    p_scrap_code_qty_tbl                   IN t_scrap_code_qty_tbl_type,
    p_bonus_codes_tbl                      IN t_bonus_codes_tbl_type,
    p_bonus_code_qty_tbl                   IN t_bonus_code_qty_tbl_type,
    p_jobop_resource_usages_tbl            IN t_jobop_res_usages_tbl_type,
    x_wip_move_api_sucess_msg               OUT NOCOPY VARCHAR2
    , x_return_status                       OUT NOCOPY VARCHAR2
    , x_msg_count                           OUT NOCOPY NUMBER
    , x_msg_data                            OUT NOCOPY VARCHAR2
);

Procedure MoveTransaction(
    p_group_id                              IN NUMBER,
    p_bonus_account_id                      IN NUMBER,
    p_employee_id                           IN NUMBER,
    p_operation_start_date                  IN DATE,
    p_operation_completion_date             IN DATE,
    p_expected_completion_date              IN DATE,
    p_bonus_quantity                        IN NUMBER,
    p_low_yield_trigger_limit               IN NUMBER,
    p_source_code                           IN wsm_lot_move_txn_interface.source_code%type,
    p_mtl_txn_hdr_id                        IN NUMBER,
    p_sec_uom_code_tbls                     IN t_sec_uom_code_tbls_type,
    p_sec_move_out_qty_tbls                 IN t_sec_move_out_qty_tbls_type,
    p_jobop_scrap_serials_tbls              IN t_scrap_serials_tbls_type,
    p_jobop_bonus_serials_tbls              IN t_bonus_serials_tbls_type,
    p_scrap_codes_tbls                      IN t_scrap_codes_tbls_type,
    p_scrap_code_qty_tbls                   IN t_scrap_code_qty_tbls_type,
    p_bonus_codes_tbls                      IN t_bonus_codes_tbls_type,
    p_bonus_code_qty_tbls                   IN t_bonus_code_qty_tbls_type,
--    p_jobop_instances_tbls                 IN t_jobop_instances_tbls_type,
    p_jobop_resource_usages_tbls            IN t_jobop_res_usages_tbls_type,
    x_wip_move_api_sucess_msg               OUT NOCOPY VARCHAR2,
    retcode                                 OUT NOCOPY NUMBER,
    errbuf                                  OUT NOCOPY VARCHAR2
);

--MES skaradib end

Procedure getMoveOutPageProperties(
      p_organization_id                     IN NUMBER
    , p_wip_entity_id                       IN NUMBER
    , p_operation_seq_num                   IN NUMBER
    , p_routing_operation                   IN NUMBER
    , p_job_type                            IN NUMBER
    , p_current_step                        IN NUMBER
    , p_user_id                             IN NUMBER
    , x_last_operation                      OUT NOCOPY NUMBER
    , x_estimated_scrap_accounting          OUT NOCOPY NUMBER
    , x_show_next_op_by_default             OUT NOCOPY NUMBER
    , x_multiple_res_usage_dates            OUT NOCOPY NUMBER
    , x_show_scrap_codes                    OUT NOCOPY NUMBER
    , x_scrap_codes_defined                 OUT NOCOPY NUMBER
    , x_bonus_codes_defined                 OUT NOCOPY NUMBER
    , x_show_lot_attrib                     OUT NOCOPY NUMBER
    , x_show_scrap_serials                  OUT NOCOPY NUMBER
    , x_show_serial_region                  OUT NOCOPY NUMBER
    , x_show_secondary_quantities           OUT NOCOPY NUMBER
    , x_transaction_type                    OUT NOCOPY NUMBER
    , x_quality_region                      OUT NOCOPY VARCHAR2
    , x_show_scrap_qty                      OUT NOCOPY NUMBER
    , x_show_next_op_choice                 OUT NOCOPY NUMBER
    , x_show_next_op                        OUT NOCOPY NUMBER
    , x_employee_id                         OUT NOCOPY NUMBER
    , x_operator                            OUT NOCOPY VARCHAR2
    , x_default_start_date                  OUT NOCOPY DATE
    , x_default_completion_date             OUT NOCOPY DATE
    , x_return_status                       OUT NOCOPY VARCHAR2
    , x_msg_count                           OUT NOCOPY NUMBER
    , x_msg_data                            OUT NOCOPY VARCHAR2
);

 Procedure getJobOpPageProperties(
       p_organization_id                     IN NUMBER
     , p_wip_entity_id                       IN NUMBER
     , p_operation_seq_num                   IN NUMBER
     , p_routing_operation                   IN NUMBER
     , p_responsibility_id                   IN NUMBER
     , p_standard_op_id                      IN NUMBER
     , p_current_step_type                   IN NUMBER
     , p_status_type                         IN NUMBER
     , x_show_move_in                        OUT NOCOPY NUMBER
     , x_show_move_out                       OUT NOCOPY NUMBER
     , x_show_move_to_next_op                OUT NOCOPY NUMBER
     , x_show_serial_region                  OUT NOCOPY NUMBER
     , x_show_scrap_codes                    OUT NOCOPY NUMBER
     , x_show_bonus_codes                    OUT NOCOPY NUMBER
     , x_show_secondary_quantities           OUT NOCOPY NUMBER
     , x_show_lot_attrib                     OUT NOCOPY NUMBER
     , x_return_status                       OUT NOCOPY VARCHAR2
     , x_msg_count                           OUT NOCOPY NUMBER
     , x_msg_data                            OUT NOCOPY VARCHAR2
    );

Procedure update_costed_qty_compl(
      p_transaction_type        NUMBER
    , p_job_fm_op_seq_num       NUMBER
    , p_job_to_op_seq_num       NUMBER
    , p_wip_entity_id           NUMBER
    , p_fm_intraoperation_step_type NUMBER
    , p_to_intraoperation_step_type NUMBER
    , p_primary_move_qty        NUMBER
    , p_primary_scrap_qty       NUMBER
    , p_scrap_at_op             NUMBER
);

Function convert_uom(
	p_time_hours		IN NUMBER, -- from_quantity
	p_to_uom 		IN VARCHAR2-- to_unit
) RETURN NUMBER;
--pragma restrict_references(convert_uom, WNDS,WNPS, RNPS);

END WSMPLBMI;

 

/
