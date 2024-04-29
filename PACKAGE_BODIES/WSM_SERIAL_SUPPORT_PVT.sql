--------------------------------------------------------
--  DDL for Package Body WSM_SERIAL_SUPPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_SERIAL_SUPPORT_PVT" AS
/* $Header: WSMVSERB.pls 120.26 2006/09/08 00:55:22 nlal noship $ */


type t_contorl_code is table of number index by varchar2(200);
-- We'll store the serial control code information as g_serial_ctl_code('ItemId_Organization_id') := 1;
-- Global table to store the serial control code...

g_serial_ctl_code       t_contorl_code;
g_user_id               NUMBER := FND_GLOBAL.USER_ID;

g_user_name             FND_USER.USER_NAME%TYPE := FND_GLOBAL.USER_NAME;
g_user_login_id         NUMBER := FND_GLOBAL.LOGIN_ID;
g_program_appl_id       NUMBER := FND_GLOBAL.PROG_APPL_ID;
g_request_id            NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
g_program_id            NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
g_wms_installed         NUMBER;

g_log_level_unexpected  NUMBER := FND_LOG.LEVEL_UNEXPECTED ;
g_log_level_error       number := FND_LOG.LEVEL_ERROR      ;
g_log_level_exception   number := FND_LOG.LEVEL_EXCEPTION  ;
g_log_level_event       number := FND_LOG.LEVEL_EVENT      ;
g_log_level_procedure   number := FND_LOG.LEVEL_PROCEDURE  ;
g_log_level_statement   number := FND_LOG.LEVEL_STATEMENT  ;

g_msg_lvl_unexp_error   NUMBER := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR    ;
g_msg_lvl_error         NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR          ;
g_msg_lvl_success       NUMBER := FND_MSG_PUB.G_MSG_LVL_SUCCESS        ;
g_msg_lvl_debug_high    NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH     ;
g_msg_lvl_debug_medium  NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM   ;
g_msg_lvl_debug_low     NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW      ;

g_ret_success           VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
g_ret_error             VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
g_ret_unexpected        VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;


--______________________________________________________________________________________________
-- Forward declaration section....----------------------------------------------------------------

-- Serial Processor for LBJ Interface
Procedure LBJ_serial_processor ( p_calling_mode                 IN              NUMBER,
                                 p_wsm_serial_nums_tbl          IN              WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                 p_wip_entity_id                IN              NUMBER,
                                 p_organization_id              IN              NUMBER,
                                 p_inventory_item_id            IN              NUMBER,
                                 x_return_status                OUT NOCOPY      VARCHAR2,
                                 x_error_msg                    OUT NOCOPY      VARCHAR2,
                                 x_error_count                  OUT NOCOPY      NUMBER
                               );

-- Obtain serial information for a job
Procedure get_serial_track_info (  p_serial_item_id        IN              NUMBER,
                                   p_organization_id       IN              NUMBER,
                                   p_wip_entity_id         IN              NUMBER,
                                   x_serial_start_flag     OUT NOCOPY      NUMBER,
                                   x_serial_ctrl_code      OUT NOCOPY      NUMBER,
                                   x_first_serial_txn_id   OUT NOCOPY      NUMBER,
                                   x_serial_start_op       OUT NOCOPY      NUMBER,
                                   x_return_status         OUT NOCOPY      VARCHAR2,
                                   x_error_msg             OUT NOCOPY      VARCHAR2,
                                   x_error_count           OUT NOCOPY      NUMBER
                                );

-- Handles processing (asscoiating, delinking, updating, generation)
Procedure process_serial_info     (  p_calling_mode        IN            NUMBER,
                                     p_wsm_serial_nums_tbl IN            WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                     p_wip_entity_id       IN            NUMBER,
                                     p_serial_start_flag   IN            NUMBER,
                                     p_organization_id     IN            NUMBER,
                                     p_item_id             IN            NUMBER,
                                     -- Indicates that this call is made for update qty transaction....
                                     p_wlt_upd_qty_txn     IN            NUMBER         DEFAULT NULL,
                                     p_operation_seq_num   IN           NUMBER          DEFAULT NULL,
                                     p_intraoperation_step IN           NUMBER          DEFAULT NULL,
                                     -- This PL/SQL table parameter would return the serial numbers added/generated and added..
                                     -- We need this information to insert into WSM_SERIAL_TRANSACTIONS
                                     x_serial_tbl          OUT NOCOPY    t_varchar2,
                                     x_return_status       OUT NOCOPY    VARCHAR2,
                                     x_error_msg           OUT NOCOPY    VARCHAR2,
                                     x_error_count         OUT NOCOPY    NUMBER
                                   );

-- Generate and associate a serial number or else associate if already exisitng
Procedure add_assoc_serial_number(p_calling_mode                IN              NUMBER,
                                  p_serial_number_rec           IN              WSM_Serial_Support_GRP.WSM_SERIAL_NUM_REC,
                                  p_wip_entity_id               IN              NUMBER,
                                  p_gen_serial_flag             IN              NUMBER,
                                  p_organization_id             IN              NUMBER,
                                  p_inventory_item_id           IN              NUMBER,
                                  p_operation_seq_num           IN              NUMBER          DEFAULT NULL,
                                  p_intraoperation_step         IN              NUMBER          DEFAULT NULL,
                                  x_serial_number               OUT NOCOPY      VARCHAR2,
                                  x_return_status               OUT NOCOPY      VARCHAR2,
                                  x_error_msg                   OUT NOCOPY      VARCHAR2,
                                  x_error_count                 OUT NOCOPY      NUMBER
                                 );

-- Generate and associate a serial number or else associate if already exisitng
Procedure  add_serial_number (    p_assembly_item_id            IN              NUMBER,
                                  p_organization_id             IN              NUMBER,
                                  p_wip_entity_id               IN              NUMBER,
                                  p_new_serial_number           IN              NUMBER DEFAULT NULL,
                                  p_serial_number               IN  OUT NOCOPY  VARCHAR2,
                                  x_return_status               OUT NOCOPY      VARCHAR2,
                                  x_error_msg                   OUT  NOCOPY     VARCHAR2,
                                  x_error_count                 OUT  NOCOPY     NUMBER
                             );


PROCEDURE update_serial_attr ( p_calling_mode           IN         NUMBER,
                               p_serial_number_rec      IN         WSM_Serial_Support_GRP.WSM_SERIAL_NUM_REC,
                               p_inventory_item_id      IN         NUMBER,
                               p_organization_id        IN         NUMBER,
                               p_clear_serial_attr      IN         NUMBER DEFAULT NULL,  -- will be used in case of WLT SpUA to clear the attributes
                               p_wlt_txn_type           IN         NUMBER DEFAULT NULL,
                               -- Pass the serial attribute context corresponding to the inventory item id
                               p_serial_attr_context    IN         VARCHAR2 DEFAULT NULL,
                               p_update_serial_attr     IN         NUMBER,
                               p_update_desc_attr       IN         NUMBER,
                               x_return_status          OUT NOCOPY VARCHAR2,
                               x_error_count            OUT NOCOPY NUMBER,
                               x_error_msg              OUT NOCOPY VARCHAR2
                             );

Procedure wms_installed ( x_return_status   OUT  NOCOPY VARCHAR2,
                          x_error_count     OUT  NOCOPY NUMBER      ,
                          x_err_data        OUT  NOCOPY VARCHAR2
                        );

-- Expected i/p is the header id of the Move Transaction...
-- All the qty information to be passed in the primary UOM only...
Procedure Move_serial_processor ( p_calling_mode                IN              NUMBER,
                                  p_serial_num_tbl              IN              WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                  p_move_txn_type               IN              NUMBER,
                                  p_wip_entity_id               IN              NUMBER,
                                  p_organization_id             IN              NUMBER,
                                  p_inventory_item_id           IN              NUMBER,
                                  p_move_qty                    IN              NUMBER,
                                  p_scrap_qty                   IN              NUMBER,
                                  p_available_qty               IN              NUMBER,
                                  p_curr_job_op_seq_num         IN              NUMBER,
                                  p_curr_job_intraop_step       IN              NUMBER,
                                  p_from_rtg_op_seq_num         IN              NUMBER,
                                  p_to_rtg_op_seq_num           IN              NUMBER,
                                  p_to_intraoperation_step      IN              NUMBER,
                                  p_job_serial_start_op         IN              NUMBER,
                                  p_user_serial_tracking        IN              NUMBER,
                                  p_move_txn_id                 IN              NUMBER,
                                  p_scrap_txn_id                IN              NUMBER,
                                  p_old_move_txn_id             IN              NUMBER,
                                  p_old_scrap_txn_id            IN              NUMBER,
                                  p_jump_flag                   IN              varchar2   DEFAULT  NULL,
                                  p_scrap_at_operation          IN              NUMBER     DEFAULT  NULL,
                                  -- ST : Fix for bug 5140761 Addded the above parameter --
                                  x_serial_track_flag           IN  OUT NOCOPY  NUMBER,
                                  x_return_status               OUT NOCOPY      VARCHAR2,
                                  x_error_msg                   OUT NOCOPY      VARCHAR2,
                                  x_error_count                 OUT NOCOPY      NUMBER
                                );

Procedure check_move_serial_qty( p_calling_mode           IN                     NUMBER,
                                 p_serial_num_tbl         IN                     WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                 p_move_txn_type          IN                     NUMBER,
                                 p_wip_entity_id          IN                     NUMBER,
                                 p_inventory_item_id      IN                     NUMBER,
                                 p_organization_id        IN                     NUMBER,
                                 p_move_qty               IN                     NUMBER,
                                 p_scrap_qty              IN                     NUMBER,
                                 p_available_qty          IN                     NUMBER,
                                 p_curr_job_op_seq_num    IN                     NUMBER,
                                 p_curr_job_intraop_step  IN                     NUMBER,
                                 p_job_serial_start_op    IN                     NUMBER,
                                 p_from_rtg_op_seq_num    IN                     NUMBER,
                                 p_to_rtg_op_seq_num      IN                     NUMBER,
                                 p_to_intraoperation_step IN                     NUMBER,
                                 p_user_serial_tracking   IN                     NUMBER,
                                 p_move_txn_id            IN                     NUMBER,
                                 p_scrap_txn_id           IN                     NUMBER,
                                 p_jump_flag              IN                     varchar2   DEFAULT  NULL,
                                 p_scrap_at_operation           IN              NUMBER     DEFAULT  NULL,
                                 -- ST : Fix for bug 5140761 Addded the above parameter --
                                 x_serial_track_flag      IN OUT NOCOPY          NUMBER,
                                 x_return_status          OUT NOCOPY             VARCHAR2,
                                 x_error_msg              OUT NOCOPY             VARCHAR2,
                                 x_error_count            OUT NOCOPY             NUMBER
                                );

-- Populate serial numbers for undo transactions..
Procedure populate_undo_txn (    p_move_txn_type         IN                     NUMBER,
                                 p_wip_entity_id         IN                     NUMBER,
                                 p_inventory_item_id     IN                     NUMBER,
                                 p_organization_id       IN                     NUMBER,
                                 p_move_qty              IN                     NUMBER,
                                 p_scrap_qty             IN                     NUMBER,
                                 p_new_move_txn_id       IN                     NUMBER,
                                 p_new_scrap_txn_id      IN                     NUMBER,
                                 p_old_move_txn_id       IN                     NUMBER  DEFAULT NULL,
                                 p_old_scrap_txn_id      IN                     NUMBER  DEFAULT NULL,
                                 x_return_status         OUT NOCOPY             VARCHAR2,
                                 x_error_msg             OUT NOCOPY             VARCHAR2,
                                 x_error_count           OUT NOCOPY             NUMBER
                            );

-- Procedure to dump the serial records' data....
Procedure log_serial_data ( p_serial_num_tbl              IN              WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL  ,
                            x_return_status               OUT NOCOPY      VARCHAR2                                   ,
                            x_error_msg                   OUT NOCOPY      VARCHAR2                                   ,
                            x_error_count                 OUT NOCOPY      NUMBER
                          );

/*______________________________________________________________________________________________*/


--------------------------------------------------------------------------------------------------
Procedure LBJ_serial_intf_proc( p_header_id             IN         NUMBER,
                                p_wip_entity_id         IN         NUMBER,
                                p_organization_id       IN         NUMBER,
                                p_inventory_item_id     IN         NUMBER,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_error_count           OUT NOCOPY NUMBER,
                                x_error_msg             OUT NOCOPY VARCHAR2
                               )
IS
        l_miss_char             VARCHAR2(1) := FND_API.G_MISS_CHAR;
        l_null_num              NUMBER      := FND_API.G_NULL_NUM;
        l_null_date             DATE        := FND_API.G_NULL_DATE;
        l_null_char             VARCHAR2(1) := FND_API.G_NULL_CHAR;

        cursor c_lbj_serials is
        select
        wsti.Serial_Number                     ,
        null                                   ,  -- assembly_item_id
        wsti.header_id                         ,  -- header_id
        wsti.Generate_serial_number            ,
        wsti.Generate_for_qty                  ,
        wsti.Action_flag                       ,
        wsti.Current_wip_entity_name           ,
        wsti.Changed_wip_entity_name           ,
        wsti.Current_wip_entity_id             ,
        wsti.Changed_wip_entity_id             ,
        decode(wsti.serial_attribute_category  , l_null_char, null, null, msn.serial_attribute_category, wsti.serial_attribute_category), -- serial_attribute_category
        decode(wsti.territory_code             , l_null_char, null, null, msn.territory_code           , wsti.territory_code           ), -- territory_code
        decode(wsti.origination_date           , l_null_date, null, null, msn.origination_date         , wsti.origination_date         ), -- origination_date
        decode(wsti.c_attribute1               , l_null_char, null, null, msn.c_attribute1             , wsti.c_attribute1             ), -- c_attribute1
        decode(wsti.c_attribute2               , l_null_char, null, null, msn.c_attribute2             , wsti.c_attribute2             ), -- c_attribute2
        decode(wsti.c_attribute3               , l_null_char, null, null, msn.c_attribute3             , wsti.c_attribute3             ), -- c_attribute3
        decode(wsti.c_attribute4               , l_null_char, null, null, msn.c_attribute4             , wsti.c_attribute4             ), -- c_attribute4
        decode(wsti.c_attribute5               , l_null_char, null, null, msn.c_attribute5             , wsti.c_attribute5             ), -- c_attribute5
        decode(wsti.c_attribute6               , l_null_char, null, null, msn.c_attribute6             , wsti.c_attribute6             ), -- c_attribute6
        decode(wsti.c_attribute7               , l_null_char, null, null, msn.c_attribute7             , wsti.c_attribute7             ), -- c_attribute7
        decode(wsti.c_attribute8               , l_null_char, null, null, msn.c_attribute8             , wsti.c_attribute8             ), -- c_attribute8
        decode(wsti.c_attribute9               , l_null_char, null, null, msn.c_attribute9             , wsti.c_attribute9             ), -- c_attribute9
        decode(wsti.c_attribute10              , l_null_char, null, null, msn.c_attribute10            , wsti.c_attribute10            ), -- c_attribute10
        decode(wsti.c_attribute11              , l_null_char, null, null, msn.c_attribute11            , wsti.c_attribute11            ), -- c_attribute11
        decode(wsti.c_attribute12              , l_null_char, null, null, msn.c_attribute12            , wsti.c_attribute12            ), -- c_attribute12
        decode(wsti.c_attribute13              , l_null_char, null, null, msn.c_attribute13            , wsti.c_attribute13            ), -- c_attribute13
        decode(wsti.c_attribute14              , l_null_char, null, null, msn.c_attribute14            , wsti.c_attribute14            ), -- c_attribute14
        decode(wsti.c_attribute15              , l_null_char, null, null, msn.c_attribute15            , wsti.c_attribute15            ), -- c_attribute15
        decode(wsti.c_attribute16              , l_null_char, null, null, msn.c_attribute16            , wsti.c_attribute16            ), -- c_attribute16
        decode(wsti.c_attribute17              , l_null_char, null, null, msn.c_attribute17            , wsti.c_attribute17            ), -- c_attribute17
        decode(wsti.c_attribute18              , l_null_char, null, null, msn.c_attribute18            , wsti.c_attribute18            ), -- c_attribute18
        decode(wsti.c_attribute19              , l_null_char, null, null, msn.c_attribute19            , wsti.c_attribute19            ), -- c_attribute19
        decode(wsti.c_attribute20              , l_null_char, null, null, msn.c_attribute20            , wsti.c_attribute20            ), -- c_attribute20
        decode(wsti.d_attribute1               , l_null_date, null, null, msn.d_attribute1             , wsti.d_attribute1             ), -- d_attribute1
        decode(wsti.d_attribute2               , l_null_date, null, null, msn.d_attribute2             , wsti.d_attribute2             ), -- d_attribute2
        decode(wsti.d_attribute3               , l_null_date, null, null, msn.d_attribute3             , wsti.d_attribute3             ), -- d_attribute3
        decode(wsti.d_attribute4               , l_null_date, null, null, msn.d_attribute4             , wsti.d_attribute4             ), -- d_attribute4
        decode(wsti.d_attribute5               , l_null_date, null, null, msn.d_attribute5             , wsti.d_attribute5             ), -- d_attribute5
        decode(wsti.d_attribute6               , l_null_date, null, null, msn.d_attribute6             , wsti.d_attribute6             ), -- d_attribute6
        decode(wsti.d_attribute7               , l_null_date, null, null, msn.d_attribute7             , wsti.d_attribute7             ), -- d_attribute7
        decode(wsti.d_attribute8               , l_null_date, null, null, msn.d_attribute8             , wsti.d_attribute8             ), -- d_attribute8
        decode(wsti.d_attribute9               , l_null_date, null, null, msn.d_attribute9             , wsti.d_attribute9             ), -- d_attribute9
        decode(wsti.d_attribute10              , l_null_date, null, null, msn.d_attribute10            , wsti.d_attribute10            ), -- d_attribute10
        decode(wsti.n_attribute1               , l_null_num , null, null, msn.n_attribute1             , wsti.n_attribute1             ), -- n_attribute1
        decode(wsti.n_attribute2               , l_null_num , null, null, msn.n_attribute2             , wsti.n_attribute2             ), -- n_attribute2
        decode(wsti.n_attribute3               , l_null_num , null, null, msn.n_attribute3             , wsti.n_attribute3             ), -- n_attribute3
        decode(wsti.n_attribute4               , l_null_num , null, null, msn.n_attribute4             , wsti.n_attribute4             ), -- n_attribute4
        decode(wsti.n_attribute5               , l_null_num , null, null, msn.n_attribute5             , wsti.n_attribute5             ), -- n_attribute5
        decode(wsti.n_attribute6               , l_null_num , null, null, msn.n_attribute6             , wsti.n_attribute6             ), -- n_attribute6
        decode(wsti.n_attribute7               , l_null_num , null, null, msn.n_attribute7             , wsti.n_attribute7             ), -- n_attribute7
        decode(wsti.n_attribute8               , l_null_num , null, null, msn.n_attribute8             , wsti.n_attribute8             ), -- n_attribute8
        decode(wsti.n_attribute9               , l_null_num , null, null, msn.n_attribute9             , wsti.n_attribute9             ), -- n_attribute9
        decode(wsti.n_attribute10              , l_null_num , null, null, msn.n_attribute10            , wsti.n_attribute10            ), -- n_attribute10
        decode(wsti.status_id                  , l_null_num , null, null, msn.status_id                , wsti.status_id                ), -- status_id
        decode(wsti.time_since_new             , l_null_num , null, null, msn.time_since_new           , wsti.time_since_new           ), -- time_since_new
        decode(wsti.cycles_since_new           , l_null_num , null, null, msn.cycles_since_new         , wsti.cycles_since_new         ), -- cycles_since_new
        decode(wsti.time_since_overhaul        , l_null_num , null, null, msn.time_since_overhaul      , wsti.time_since_overhaul      ), -- time_since_overhaul
        decode(wsti.cycles_since_overhaul      , l_null_num , null, null, msn.cycles_since_overhaul    , wsti.cycles_since_overhaul    ), -- cycles_since_overhaul
        decode(wsti.time_since_repair          , l_null_num , null, null, msn.time_since_repair        , wsti.time_since_repair        ), -- time_since_repair
        decode(wsti.cycles_since_repair        , l_null_num , null, null, msn.cycles_since_repair      , wsti.cycles_since_repair      ), -- cycles_since_repair
        decode(wsti.time_since_visit           , l_null_num , null, null, msn.time_since_visit         , wsti.time_since_visit         ), -- time_since_visit
        decode(wsti.cycles_since_visit         , l_null_num , null, null, msn.cycles_since_visit       , wsti.cycles_since_visit       ), -- cycles_since_visit
        decode(wsti.time_since_mark            , l_null_num , null, null, msn.time_since_mark          , wsti.time_since_mark          ), -- time_since_mark
        decode(wsti.cycles_since_mark          , l_null_num , null, null, msn.cycles_since_mark        , wsti.cycles_since_mark        ), -- cycles_since_mark
        decode(wsti.number_of_repairs          , l_null_num , null, null, msn.number_of_repairs        , wsti.number_of_repairs        ), -- number_of_repairs
        decode(wsti.attribute_category         , l_null_char, l_miss_char , null ,msn.attribute_category   ,wsti.attribute_category    ),
        decode(wsti.attribute1                 , l_null_char ,l_miss_char , wsti.attribute1            ),
        decode(wsti.attribute2                 , l_null_char ,l_miss_char , wsti.attribute2            ),
        decode(wsti.attribute3                 , l_null_char ,l_miss_char , wsti.attribute3            ),
        decode(wsti.attribute4                 , l_null_char ,l_miss_char , wsti.attribute4            ),
        decode(wsti.attribute5                 , l_null_char ,l_miss_char , wsti.attribute5            ),
        decode(wsti.attribute6                 , l_null_char ,l_miss_char , wsti.attribute6            ),
        decode(wsti.attribute7                 , l_null_char ,l_miss_char , wsti.attribute7            ),
        decode(wsti.attribute8                 , l_null_char ,l_miss_char , wsti.attribute8            ),
        decode(wsti.attribute9                 , l_null_char ,l_miss_char , wsti.attribute9            ),
        decode(wsti.attribute10                , l_null_char ,l_miss_char , wsti.attribute10           ),
        decode(wsti.attribute11                , l_null_char ,l_miss_char , wsti.attribute11           ),
        decode(wsti.attribute12                , l_null_char ,l_miss_char , wsti.attribute12           ),
        decode(wsti.attribute13                , l_null_char ,l_miss_char , wsti.attribute13           ),
        decode(wsti.attribute14                , l_null_char ,l_miss_char , wsti.attribute14           ),
        decode(wsti.attribute15                , l_null_char ,l_miss_char , wsti.attribute15           )
        from wsm_serial_txn_interface wsti,
             mtl_serial_numbers       msn
        where header_id = p_header_id
        and transaction_type_id = 1
        and  wsti.serial_number = msn.serial_number (+)
        and  msn.inventory_item_id (+) = p_inventory_item_id
        and  msn.current_organization_id (+) = p_organization_id
        order by nvl(wsti.action_flag,0) desc; -- Code review remark
        -- first process Delete and then add

l_wsm_serial_nums_tbl   WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL;
l_status_type           NUMBER;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.LBJ_serial_intf_proc';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...


BEGIN
        l_stmt_num := 10;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN
                l_stmt_num := 15;
                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_wip_entity_id';
                l_param_tbl(1).paramValue := p_wip_entity_id;

                l_param_tbl(2).paramName := 'p_inventory_item_id';
                l_param_tbl(2).paramValue := p_inventory_item_id;

                l_param_tbl(3).paramName := 'p_organization_id';
                l_param_tbl(3).paramValue := p_organization_id;

                l_param_tbl(4).paramName := 'p_header_id';
                l_param_tbl(4).paramValue := p_header_id;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;



        l_stmt_num := 20;
        -- get the data from the interface
        open c_lbj_serials;
        fetch c_lbj_serials
        bulk collect into l_wsm_serial_nums_tbl;
        close c_lbj_serials;

        l_stmt_num := 30;
        IF l_wsm_serial_nums_tbl.count = 0 THEN
                l_stmt_num := 40;
                RETURN;
        END IF;

        -- Get the staus of the job...
        -- has to be only (1,3,6) Unreleased, Released or ONHold..
        select status_type
        into   l_status_type
        from   wip_discrete_jobs
        where  wip_entity_id = p_wip_entity_id
        and    organization_id = p_organization_id;

        -- Fix for Bug 4665172 : Move this code after the code to fetch the data from the intf table.
        -- Error out if not in valid status...
        if l_status_type not in (1,3,6) then
                -- error out..
                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_SERIAL_JOB_INVALID_STATUS',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        l_stmt_num := 50;
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Invoking LBJ_serial_processor',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        -- Invoke the LBJ Serial Processor...
        LBJ_serial_processor ( p_calling_mode                   =>  1,
                               p_wsm_serial_nums_tbl            =>  l_wsm_serial_nums_tbl ,
                               p_wip_entity_id                  =>  p_wip_entity_id       ,
                               p_organization_id                =>  p_organization_id     ,
                               p_inventory_item_id              =>  p_inventory_item_id   ,
                               x_return_status                  =>  x_return_status       ,
                               x_error_msg                      =>  x_error_msg           ,
                               x_error_count                    =>  x_error_count
                             );

        l_stmt_num := 60;

        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
       end if;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
END LBJ_serial_intf_proc;


-- Expected i/p header_id of the WSM_LOT_JOB_INTERFACE
Procedure LBJ_serial_processor ( p_calling_mode                 IN              NUMBER,
                                 p_wsm_serial_nums_tbl          IN              WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                 p_wip_entity_id                IN              NUMBER,
                                 p_organization_id              IN              NUMBER,
                                 p_inventory_item_id            IN              NUMBER,
                                 x_return_status                OUT NOCOPY      VARCHAR2,
                                 x_error_msg                    OUT NOCOPY      VARCHAR2,
                                 x_error_count                  OUT NOCOPY      NUMBER
                               )
IS


l_serial_start_flag     NUMBER;
l_serial_ctrl_code      NUMBER;
l_first_serial_txn_id   NUMBER;
l_serial_start_op       NUMBER;

l_return_status         VARCHAR2(1);
l_error_msg             VARCHAR2(2000);
l_error_count           NUMBER;
l_serial_tbl            t_varchar2;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.LBJ_serial_processor';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
        l_stmt_num := 10;
        SAVEPOINT LBJ_serial_proc;
        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_calling_mode';
                l_param_tbl(1).paramValue := p_calling_mode;

                l_param_tbl(2).paramName := 'p_organization_id';
                l_param_tbl(2).paramValue := p_organization_id;

                l_param_tbl(3).paramName := 'p_wip_entity_id';
                l_param_tbl(3).paramValue := p_wip_entity_id;

                l_param_tbl(4).paramName := 'p_wsm_serial_nums_tbl.count';
                l_param_tbl(4).paramValue := p_wsm_serial_nums_tbl.count;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_stmt_num := 15;
                -- Procedure to dump the serial records' data....
                log_serial_data ( p_serial_num_tbl    => p_wsm_serial_nums_tbl   ,
                                  x_return_status     => x_return_status         ,
                                  x_error_msg         => x_error_msg             ,
                                  x_error_count       => x_error_count
                                );
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        END IF;

        l_stmt_num := 20;
        -- Validate the item_id for serial control..
        get_serial_track_info (p_serial_item_id         => p_inventory_item_id,
                               p_organization_id        => p_organization_id,
                               p_wip_entity_id          => p_wip_entity_id,
                               x_serial_start_flag      => l_serial_start_flag,
                               x_serial_ctrl_code       => l_serial_ctrl_code,
                               x_first_serial_txn_id    => l_first_serial_txn_id,
                               x_serial_start_op        => l_serial_start_op,
                               x_return_status          => x_return_status,
                               x_error_msg              => x_error_msg,
                               x_error_count            => x_error_count
                            );

        l_stmt_num := 30;

        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

        l_stmt_num := 40;
        -- check for serial track...
        -- we dont have to worry about Lot control as the LBJ creation would have failed before this is invoked..
        if l_serial_ctrl_code = 1 then -- No serial control
                if p_wsm_serial_nums_tbl.count > 0 then
                        -- return error as interface rows were updated...
                        l_stmt_num := 50;
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVLAID_SERIAL_INFO',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                else
                        -- return success... as no rows were found as expected..
                        l_stmt_num := 60;
                        return;
                end if;

        else
                l_stmt_num := 70;
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking process_serial_info',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;
                -- invoke process_serial_info
                process_serial_info( p_calling_mode        => p_calling_mode            ,
                                     p_wsm_serial_nums_tbl => p_wsm_serial_nums_tbl     ,
                                     p_wip_entity_id       => p_wip_entity_id           ,
                                     p_serial_start_flag   => l_serial_start_flag       ,
                                     p_organization_id     => p_organization_id         ,
                                     p_item_id             => p_inventory_item_id       ,
                                     x_serial_tbl          => l_serial_tbl              ,
                                     x_return_status       => x_return_status           ,
                                     x_error_msg           => x_error_msg               ,
                                     x_error_count         => x_error_count
                                   );

                l_stmt_num := 80;
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        end if;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO LBJ_serial_proc;
                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO LBJ_serial_proc;
                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN
                 ROLLBACK TO LBJ_serial_proc;
                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
END LBJ_serial_processor;

-- x_serial_ctrl_code --> 1 -- No serial control
-- x_serial_ctrl_code --> 2 -- Predefined... (this is the only one allowed in OSFM..)

Procedure get_serial_track_info (  p_serial_item_id        IN              NUMBER,
                                   p_organization_id       IN              NUMBER,
                                   p_wip_entity_id         IN              NUMBER,
                                   x_serial_start_flag     OUT NOCOPY      NUMBER,
                                   x_serial_ctrl_code      OUT NOCOPY      NUMBER,
                                   x_first_serial_txn_id   OUT NOCOPY      NUMBER,
                                   x_serial_start_op       OUT NOCOPY      NUMBER,
                                   x_return_status         OUT NOCOPY      VARCHAR2,
                                   x_error_msg             OUT NOCOPY      VARCHAR2,
                                   x_error_count                   OUT NOCOPY      NUMBER
                                )

IS

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.get_serial_track_info';
-- Logging variables...

BEGIN
        l_stmt_num := 10;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        -- Query up the MTL_SYSTEM_ITEMS_B to get the serial control code for the item passed..
        -- IF g_serial_ctl_code.exists(p_serial_item_id) THEN
        IF g_serial_ctl_code.exists(p_serial_item_id || '_' || p_organization_id) THEN
                l_stmt_num := 20;
                x_serial_ctrl_code := g_serial_ctl_code(p_serial_item_id || '_' || p_organization_id);
        ELSE
                l_stmt_num := 30;

                BEGIN
                        SELECT  nvl(SERIAL_NUMBER_CONTROL_CODE,1)
                        INTO    x_serial_ctrl_code
                        FROM    MTL_SYSTEM_ITEMS MSI
                        WHERE   MSI.inventory_item_id = p_serial_item_id
                        AND     MSI.organization_id = p_organization_id;

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                --Invalid item id/org id combination
                                --error out..
                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN

                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                                        l_msg_tokens(1).TokenValue := 'Organization Identifdier or Item Identifier';
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_FILED'      ,
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                END;

                l_stmt_num := 40;
                g_serial_ctl_code(p_serial_item_id || '_' || p_organization_id) := x_serial_ctrl_code;

                IF x_serial_ctrl_code = 1 THEN
                        l_stmt_num := 50;
                        RETURN;
                END IF;
        END IF;

        l_stmt_num := 60;
        --
        -- Query up the serial_start_flag from WSM_LOT_BASED_JOBS
        --
        BEGIN
                SELECT WDJ.serialization_start_op,
                       first_serial_txn_id,
                       WLBJ.serialization_start_op
                INTO   x_serial_start_flag,
                       x_first_serial_txn_id,
                       x_serial_start_op
                FROM   WSM_LOT_BASED_JOBS WLBJ,WIP_DISCRETE_JOBS WDJ
                WHERE  WLBJ.wip_entity_id = p_wip_entity_id
                AND    WDJ.wip_entity_id = WLBJ.wip_entity_id
                AND    WLBJ.organization_id = p_organization_id;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        --Invalid wip_entity_id
                        -- error out..
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                l_msg_tokens(1).TokenValue := 'Job Identifier (wip_entity_id)';
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
        END;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

END get_serial_track_info;


Procedure process_serial_info     (  p_calling_mode        IN            NUMBER,
                                     p_wsm_serial_nums_tbl IN            WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                     p_wip_entity_id       IN            NUMBER,
                                     p_serial_start_flag   IN            NUMBER,
                                     p_organization_id     IN            NUMBER,
                                     p_item_id             IN            NUMBER,
                                     -- Indicates that this call is made for update qty transaction....
                                     p_wlt_upd_qty_txn     IN            NUMBER         DEFAULT NULL,
                                     p_operation_seq_num   IN            NUMBER         DEFAULT NULL,
                                     p_intraoperation_step IN            NUMBER         DEFAULT NULL,
                                     -- This PL/SQL table parameter would return the serial numbers added/generated and added..
                                     -- We need this information to insert into WSM_SERIAL_TRANSACTIONS
                                     x_serial_tbl          OUT NOCOPY    t_varchar2,
                                     x_return_status       OUT NOCOPY    VARCHAR2,
                                     x_error_msg           OUT NOCOPY    VARCHAR2,
                                     x_error_count         OUT NOCOPY    NUMBER
                                   )

IS

l_index                 NUMBER;
l_return_status         VARCHAR2(1);
l_error_msg             VARCHAR2(2000);
l_error_count           NUMBER;
l_serial_start_flag     NUMBER;
l_job_qty               NUMBER;
l_serial_num_count      NUMBER;

l_qty_queue             NUMBER;
l_qty_run               NUMBER;
l_qty_tomove            NUMBER;
l_qty                   NUMBER;
l_op_seq_num            NUMBER;
l_serial_number         MTL_SERIAL_NUMBERS.SERIAL_NUMBER%TYPE;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.process_serial_info';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
        l_stmt_num := 10;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_operation_seq_num';
                l_param_tbl(1).paramValue := p_operation_seq_num;

                l_param_tbl(2).paramName := 'p_intraoperation_step';
                l_param_tbl(2).paramValue := p_intraoperation_step;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Inside WSM_SERIAL_SUPPORT_PVT.process_serial_info',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;



        -- Ok the first thing is get the job qty and the number of serial numbers currently attached to the job if it is not
        -- serial tracked..
        l_stmt_num := 20;
        l_index := p_wsm_serial_nums_tbl.first;

        if (p_serial_start_flag IS NULL) THEN

                l_stmt_num := 30;

                SELECT start_quantity
                into l_job_qty
                from wip_discrete_jobs
                where wip_entity_id = p_wip_entity_id
                and organization_id = p_organization_id;

                BEGIN
                        l_stmt_num := 40;

                        SELECT max(operation_seq_num)
                        INTO   l_op_seq_num
                        FROM   wip_operations
                        WHERE  wip_entity_id = p_wip_entity_id
                        AND   ((quantity_in_queue <> 0
                                 OR quantity_running <> 0
                                 OR quantity_waiting_to_move <> 0)
                                 OR (quantity_in_queue = 0
                                     and quantity_running = 0
                                     and quantity_waiting_to_move = 0
                                     and quantity_scrapped = quantity_completed
                                     and quantity_completed > 0));

                        l_stmt_num := 50;

                        SELECT quantity_in_queue,
                               quantity_running,
                               quantity_waiting_to_move
                        INTO   l_qty_queue,
                               l_qty_run,
                               l_qty_tomove
                        FROM   wip_operations
                        WHERE  wip_entity_id = p_wip_entity_id
                        AND    operation_seq_num = l_op_seq_num;

                        l_stmt_num := 60;

                        IF l_qty_queue <> 0 then
                           l_qty := l_qty_queue;
                        elsif l_qty_run <> 0 then
                           l_qty := l_qty_run;
                        elsif l_qty_tomove <> 0 then
                           l_qty := l_qty_tomove;
                        end if;

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                l_stmt_num := 70;
                                l_qty := l_job_qty;
                END;

                l_stmt_num := 80;

                SELECT count(*)
                into l_serial_num_count
                -- ST : Fix for bug 4910758 (remove usage of wsm_job_serial_numbers_v)
                -- from wsm_job_serial_numbers_v
                from mtl_serial_numbers
                where wip_entity_id = p_wip_entity_id
                and   inventory_item_id = p_item_id
                and   current_organization_id = p_organization_id;

        end if;


        WHILE l_index IS NOT NULL LOOP

                l_stmt_num := 90;
                if (p_serial_start_flag IS NOT NULL)  and
                   (p_wlt_upd_qty_txn   IS NULL)      and
                   (p_wsm_serial_nums_tbl(l_index).action_flag <> WSM_UPDATE_SERIAL_NUM)
                then -- Serialization has begun and action is not update...

                        l_stmt_num := 100;
                        -- Error out.. As cannot add/delete/ generate and associate once serialization has begun..
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVLD_OP_JOB_SERIAL_TRACK',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                l_stmt_num := 110;
                if p_wsm_serial_nums_tbl(l_index).action_flag = WSM_ADD_SERIAL_NUM then -- Add a serial number

                        l_stmt_num := 120;
                        IF l_serial_num_count >= l_qty then
                                --error out...
                                -- enough serial numbers reached...
                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_SERIAL_QTY',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        l_stmt_num := 130;
                        add_assoc_serial_number(  p_calling_mode                => p_calling_mode,
                                                  p_serial_number_rec           => p_wsm_serial_nums_tbl(l_index),
                                                  p_wip_entity_id               => p_wip_entity_id,
                                                  p_gen_serial_flag             => 0, -- donot generate
                                                  p_organization_id             => p_organization_id,
                                                  p_inventory_item_id           => p_item_id,
                                                  p_operation_seq_num           => p_operation_seq_num,
                                                  p_intraoperation_step         => p_intraoperation_step,
                                                  x_serial_number               => l_serial_number,
                                                  x_return_status               => x_return_status,
                                                  x_error_msg                   => x_error_msg  ,
                                                  x_error_count                 => x_error_count
                                                 );

                        l_stmt_num := 140;

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;

                        x_serial_tbl(x_serial_tbl.count+1) := p_wsm_serial_nums_tbl(l_index).serial_number;

                        l_serial_num_count := l_serial_num_count + 1;
                        l_stmt_num := 150;

                elsif p_wsm_serial_nums_tbl(l_index).action_flag = WSM_DELINK_SERIAL_NUM then -- Delink a serial number.

                        l_stmt_num := 160;

                        -- Update the serial number,., clear the wip entity id ...
                        update_serial( p_serial_number                  => p_wsm_serial_nums_tbl(l_index).serial_number,
                                       p_inventory_item_id              => p_item_id,
                                       -- p_new_inventory_item_id               => p_inventory_item_id,
                                       p_organization_id                => p_organization_id,
                                       p_wip_entity_id                  => null,
                                       p_operation_seq_num              => null,
                                       p_intraoperation_step_type       => null,
                                       x_return_status                  => x_return_status,
                                       x_error_msg                      => x_error_msg,
                                       x_error_count                    => x_error_count
                                     );

                        l_stmt_num := 170;

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;

                        l_stmt_num := 180;
                        l_serial_num_count := l_serial_num_count - 1;

                elsif p_wsm_serial_nums_tbl(l_index).generate_serial_number = 1 then -- Generate and associate serial numbers.

                        l_stmt_num := 190;

                        IF (nvl(p_wsm_serial_nums_tbl(l_index).generate_for_qty,-1) <= 0)
                           OR
                           (floor(nvl(p_wsm_serial_nums_tbl(l_index).generate_for_qty,-1)) <> nvl(p_wsm_serial_nums_tbl(l_index).generate_for_qty,-1))
                        THEN
                                -- error out...
                                -- as qty cannot be null/negative or non-integer.....
                                l_stmt_num := 200;
                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_GEN_QTY'    ,
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        end if;

                        l_stmt_num := 210;
                        IF l_qty < l_serial_num_count + p_wsm_serial_nums_tbl(l_index).generate_for_qty then
                                --error out...
                                -- enough serial numbers reached...
                                -- enough serial numbers reached...
                                l_stmt_num := 220;
                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_SERIAL_QTY',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        l_stmt_num := 230;
                        for l_cntr in 1..p_wsm_serial_nums_tbl(l_index).generate_for_qty loop

                                l_stmt_num := 240;

                                add_assoc_serial_number ( p_calling_mode                => p_calling_mode,
                                                          p_serial_number_rec           => p_wsm_serial_nums_tbl(l_index),
                                                          p_wip_entity_id               => p_wip_entity_id,
                                                          p_gen_serial_flag             => 1, -- generate serial number
                                                          p_organization_id             => p_organization_id,
                                                          p_inventory_item_id           => p_item_id,
                                                          p_operation_seq_num           => p_operation_seq_num,
                                                          p_intraoperation_step         => p_intraoperation_step,
                                                          x_serial_number               => l_serial_number,
                                                          x_return_status               => x_return_status,
                                                          x_error_msg                   => x_error_msg  ,
                                                          x_error_count                 => x_error_count
                                                         );

                                l_stmt_num := 250;

                                if x_return_status <> G_RET_SUCCESS then
                                        IF x_return_status = G_RET_ERROR THEN
                                                raise FND_API.G_EXC_ERROR;
                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                                end if;

                                x_serial_tbl(x_serial_tbl.count+1) := l_serial_number;

                        end loop;

                        l_stmt_num := 260;
                        l_serial_num_count := l_serial_num_count + p_wsm_serial_nums_tbl(l_index).generate_for_qty;

                elsif p_wsm_serial_nums_tbl(l_index).action_flag = WSM_UPDATE_SERIAL_NUM then

                        l_stmt_num := 270;
                        -- this will basically update only serial attributes.. (No other updates allowed....)
                        update_serial_attr (   p_calling_mode           => p_calling_mode                                ,
                                               p_serial_number_rec      => p_wsm_serial_nums_tbl(l_index)                ,
                                               p_inventory_item_id      => p_item_id                                     ,
                                               p_organization_id        => p_organization_id                             ,
                                               p_clear_serial_attr      => null                                          ,
                                               p_wlt_txn_type           => null                                          ,
                                               p_update_serial_attr     => null                                          ,
                                               p_update_desc_attr       => null                                          ,
                                               x_return_status          => x_return_status                               ,
                                               x_error_count            => x_error_count                                 ,
                                               x_error_msg              => x_error_msg
                                             );

                        l_stmt_num := 280;
                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;
                else
                        -- Invalid action code...
                        -- Error out...
                        l_stmt_num := 290;
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                l_msg_tokens(1).TokenValue := 'Action Flag/Generate Serial Number Flag';
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;
                l_stmt_num := 300;
                l_index := p_wsm_serial_nums_tbl.next(l_index);

        END LOOP;


EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
END process_serial_info;


Procedure add_assoc_serial_number(p_calling_mode                IN              NUMBER,
                                  p_serial_number_rec           IN              WSM_Serial_Support_GRP.WSM_SERIAL_NUM_REC,
                                  p_wip_entity_id               IN              NUMBER,
                                  p_gen_serial_flag             IN              NUMBER,
                                  -- will be equal to the 1 in case (Generation..)
                                  p_organization_id             IN              NUMBER,
                                  p_inventory_item_id           IN              NUMBER,
                                  p_operation_seq_num           IN              NUMBER          DEFAULT NULL,
                                  p_intraoperation_step         IN              NUMBER          DEFAULT NULL,
                                  -- return the generated serial number...
                                  x_serial_number               OUT NOCOPY      VARCHAR2,
                                  x_return_status               OUT NOCOPY      VARCHAR2,
                                  x_error_msg                   OUT NOCOPY      VARCHAR2,
                                  x_error_count                 OUT NOCOPY      NUMBER
                                 )

IS
        l_serial_number         MTL_SERIAL_NUMBERS.SERIAL_NUMBER%TYPE;

        l_return_code           NUMBER;
        l_quantity              NUMBER;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.add_assoc_serial_number';
-- Logging variables...

BEGIN
        l_stmt_num := 10;
        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF p_gen_serial_flag = 1 THEN

                l_stmt_num := 20;
                l_quantity := 1;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking inv_serial_number_pub.generate_serials',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                l_return_code := inv_serial_number_pub.generate_serials(p_org_id                => p_organization_id,
                                                                        p_item_id               => p_inventory_item_id,
                                                                        p_qty                   => l_quantity,
                                                                        p_wip_id                => null,
                                                                        p_group_mark_id         => null,
                                                                        p_line_mark_id          => null,
                                                                        p_rev                   => null,
                                                                        p_lot                   => null,
                                                                        p_skip_serial           => wip_constants.yes,
                                                                        x_start_ser             => l_serial_number,
                                                                        x_end_ser               => l_serial_number,
                                                                        x_proc_msg              => x_error_msg);

                if l_quantity <> 1 or l_return_code <> 0 then
                        -- error out
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'SERIAL_NUM';
                                l_msg_tokens(1).TokenValue := null;

                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_SERIAL_GEN_FAILED'  ,
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                x_serial_number := l_serial_number;

                l_stmt_num := 30;
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoke inv_serial_number_pub.generate_serials Success',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                -- Bug fix 5219922: START.
				l_stmt_num := 35;
                if g_wms_installed IS NULL THEN

                        wms_installed ( x_return_status   =>  x_return_status   ,
                                        x_error_count     =>  x_error_count     ,
                                        x_err_data        =>  x_error_msg
                                      );

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
			            end if;
                end if;

                IF (g_wms_installed=1 AND
                    inv_lot_sel_attr.is_enabled( 'Serial Attributes',
                                                 p_organization_id,
			                                     p_inventory_item_id) >= 2) OR
                   (inv_lot_sel_attr.is_dff_required('MTL_SERIAL_NUMBERS',
                                                     'INV',
                                                     p_organization_id,
                                                     p_inventory_item_id) = 1 ) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_ENT_MAND_SER_ATTR_FLEX',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );


                END IF;
                -- Bug fix 5219922: END.
        ELSE
                -- indicates linking a new/existing serial number...
                -- first is check if the serial number exists...
                -- if not exists , then create the serial number
                l_stmt_num := 40;
                l_serial_number := p_serial_number_rec.serial_number;

                add_serial_number(p_serial_number               => l_serial_number,
                                  p_assembly_item_id            => p_inventory_item_id,
                                  p_organization_id             => p_organization_id,
                                  p_wip_entity_id               => p_wip_entity_id,
                                  x_return_status               => x_return_status,
                                  x_error_msg                   => x_error_msg,
                                  x_error_count                 => x_error_count
                                 );

               if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
               end if;
               l_stmt_num := 50;
       END IF;

       l_stmt_num := 60;
       -- Update the serial number to the job...
       update_serial( p_serial_number                   => l_serial_number,
                      p_inventory_item_id               => p_inventory_item_id,
                      --p_new_inventory_item_id         => p_inventory_item_id,
                      p_organization_id                 => p_organization_id,
                      p_wip_entity_id                   => p_wip_entity_id,
                      p_operation_seq_num               => p_operation_seq_num,
                      p_intraoperation_step_type        => p_intraoperation_step,
                      x_return_status                   => x_return_status,
                      x_error_msg                       => x_error_msg,
                      x_error_count                     => x_error_count
                    );


        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
       end if;

       l_stmt_num := 70;
       IF p_gen_serial_flag = 1 THEN -- Indicates that it is a generation call.. so no updates will be done...
                RETURN;
       END IF;

       l_stmt_num := 80;
       -- call the code to update the serial attributes/dff fields...
       update_serial_attr (   p_calling_mode            => p_calling_mode             ,
                               p_serial_number_rec      => p_serial_number_rec        ,
                               p_inventory_item_id      => p_inventory_item_id        ,
                               p_organization_id        => p_organization_id          ,
                               p_clear_serial_attr      => null                       ,
                               p_wlt_txn_type           => null                       ,
                               p_update_serial_attr     => 1                          ,
                               p_update_desc_attr       => 1                          ,
                               x_return_status          => x_return_status            ,
                               x_error_count            => x_error_count              ,
                               x_error_msg              => x_error_msg
                             );

        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
       end if;

       l_stmt_num := 90;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
END add_assoc_serial_number;


Procedure add_assoc_serial_number(p_wip_entity_id               IN              NUMBER,
                                  p_organization_id             IN              NUMBER,
                                  p_inventory_item_id           IN              NUMBER,
                                  -- will be null in case (Generation..)
                                  p_serial_number               IN  OUT NOCOPY  VARCHAR2,
                                  -- pass 1 if the calling program knows that it is a new serial number
                                  p_new_serial_number           IN              NUMBER          DEFAULT NULL,
                                  p_operation_seq_num           IN              NUMBER          DEFAULT NULL,
                                  p_intraoperation_step         IN              NUMBER          DEFAULT NULL,
                                  x_return_status               OUT NOCOPY      VARCHAR2,
                                  x_error_msg                   OUT NOCOPY      VARCHAR2,
                                  x_error_count                 OUT NOCOPY      NUMBER
                                 )

IS
l_error_msg             VARCHAR2(2000);

l_error_count           NUMBER;
l_return_code           NUMBER;
l_quantity              NUMBER;



-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.add_assoc_serial_number(2)';
-- Logging variables...


BEGIN
        l_stmt_num := 10;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF p_serial_number IS NULL THEN

                l_stmt_num := 20;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking inv_serial_number_pub.generate_serials',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                l_quantity := 1;
                l_return_code := inv_serial_number_pub.generate_serials(p_org_id                => p_organization_id,
                                                                        p_item_id               => p_inventory_item_id,
                                                                        p_qty                   => l_quantity,
                                                                        p_wip_id                => null,
                                                                        p_group_mark_id         => null,
                                                                        p_line_mark_id          => null,
                                                                        p_rev                   => null,
                                                                        p_lot                   => null,
                                                                        p_skip_serial           => wip_constants.yes,
                                                                        x_start_ser             => p_serial_number,
                                                                        x_end_ser               => p_serial_number,
                                                                        x_proc_msg              => x_error_msg);


                l_stmt_num := 30;
                if l_quantity <> 1 OR l_return_code <> 0 then
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN
                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName  := 'SERIAL_NUM';
                                l_msg_tokens(1).TokenValue := null;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_SERIAL_GEN_FAILED'  ,
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

				-- Bug fix 5219922: START.
				l_stmt_num := 35;
                if g_wms_installed IS NULL THEN

                        wms_installed ( x_return_status   =>  x_return_status   ,
                                        x_error_count     =>  x_error_count     ,
                                        x_err_data        =>  x_error_msg
                                      );

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
			            end if;
                end if;

                IF (g_wms_installed=1 AND
                    inv_lot_sel_attr.is_enabled( 'Serial Attributes',
                                                 p_organization_id,
			                                     p_inventory_item_id) >= 2) OR
                   (inv_lot_sel_attr.is_dff_required('MTL_SERIAL_NUMBERS',
                                                     'INV',
                                                     p_organization_id,
                                                     p_inventory_item_id) = 1 ) THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_ENT_MAND_SER_ATTR_FLEX',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );


                END IF;
                -- Bug fix 5219922: END.
        ELSE
                -- indicates linking a new/existing serial number...
                -- first is check if the serial number exists...
                -- if not exists , then create the serial number

                l_stmt_num := 40;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking add_serial_number',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                add_serial_number(p_serial_number               => p_serial_number,
                                  p_assembly_item_id            => p_inventory_item_id,
                                  p_organization_id             => p_organization_id,
                                  p_wip_entity_id               => p_wip_entity_id,
                                  p_new_serial_number           => p_new_serial_number,
                                  x_return_status               => x_return_status,
                                  x_error_msg                   => x_error_msg,
                                  x_error_count                 => x_error_count
                                 );

               l_stmt_num := 50;
               if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
               end if;
       END IF;

       l_stmt_num := 60;

       -- Invoke Updation only if the wip_entity_id is NON-NULL...
       IF p_wip_entity_id IS NOT NULL THEN

               l_stmt_num := 70;

               IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking update_serial',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
               END IF;

               -- Update the serial number to the job...
               update_serial( p_serial_number                   => p_serial_number,
                              p_inventory_item_id               => p_inventory_item_id,
                              --p_new_inventory_item_id         => p_inventory_item_id,
                              p_organization_id                 => p_organization_id,
                              p_wip_entity_id                   => p_wip_entity_id,
                              p_operation_seq_num               => p_operation_seq_num,
                              p_intraoperation_step_type        => p_intraoperation_step,
                              x_return_status                   => x_return_status,
                              x_error_msg                       => x_error_msg,
                              x_error_count                     => x_error_count
                            );

                l_stmt_num := 80;

                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
               end if;

        END IF;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

END add_assoc_serial_number;

Procedure  add_serial_number (    p_assembly_item_id            IN              NUMBER,
                                  p_organization_id             IN              NUMBER,
                                  p_wip_entity_id               IN              NUMBER,
                                  -- pass 1 if the calling program knows that it is a new serial number
                                  p_new_serial_number           IN              NUMBER DEFAULT NULL,
                                  p_serial_number               IN  OUT NOCOPY  VARCHAR2,
                                  x_return_status               OUT  NOCOPY     VARCHAR2,
                                  x_error_msg                   OUT  NOCOPY     VARCHAR2,
                                  x_error_count                 OUT  NOCOPY     NUMBER
                             )

IS
l_wip_entity_id         NUMBER;
l_group_mark_id         NUMBER;
l_line_mark_id          NUMBER;
l_current_status        NUMBER;
l_last_txn_srcid        NUMBER;
l_last_txn_src_typid    NUMBER;

l_quantity              NUMBER;
l_return_code           NUMBER;
l_error_msg             VARCHAR2(2000);
l_serial_number         VARCHAR2(30);
l_exists                NUMBER := 0;
l_gen_object_id         NUMBER;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.add_serial_number';
-- Logging variables...

BEGIN

        l_stmt_num := 10;
        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF p_new_serial_number IS NULL THEN -- calling program doesnt know...

                l_stmt_num := 20;
                BEGIN
                        select  wip_entity_id,
                                group_mark_id,
                                line_mark_id,
                                current_status,
                                last_txn_source_id,
                                last_txn_source_type_id,
                                gen_object_id
                        into    l_wip_entity_id,
                                l_group_mark_id,
                                l_line_mark_id,
                                l_current_status,
                                l_last_txn_srcid,
                                l_last_txn_src_typid,
                                l_gen_object_id
                        from mtl_serial_numbers
                        where inventory_item_id = p_assembly_item_id
                        and current_organization_id = p_organization_id
                        and serial_number = p_serial_number;

                        IF  ( l_current_status in (1,6)
                              and l_wip_entity_id is null
                              and l_group_mark_id is null
                              and l_line_Mark_id is null
                            )
                        THEN
                                --serial number is available...
                                return;
                        ELSIF ( ( l_current_status = 4 and
                                  l_last_txn_srcid = p_wip_entity_id and
                                  l_last_txn_src_typid = 5
                                )
                                and l_wip_entity_id is null
                                and l_group_mark_id is null
                                and l_line_Mark_id is null
                              )
                        THEN
                                     -- The serial is issued to the job .. check that it is not linked to any of the serials of the
                                     -- job.
                                     l_exists := 0;

                                     select count(1)
                                     into l_exists
                                     from mtl_object_genealogy mog,
                                          mtl_serial_numbers   msn
                                     where mog.object_id = l_gen_object_id
                                     and   mog.parent_object_type = 2
                                     and   mog.parent_object_id = msn.gen_object_id
                                     and   msn.inventory_item_id = p_assembly_item_id
                                     and   msn.current_organization_id = p_organization_id
                                     and   msn.wip_entity_id = p_wip_entity_id;

                                     IF l_exists = 1 THEN
                                                IF g_log_level_error >= l_log_level OR
                                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                                THEN
                                                        l_msg_tokens.delete;
                                                        WSM_log_PVT.logMessage(p_module_name        => l_module                       ,
                                                                               p_msg_name           => 'WIP_JDI_INVALID_UNUSED_SERIAL',
                                                                               p_msg_appl_name      => 'WIP'                    ,
                                                                               p_msg_tokens         => l_msg_tokens             ,
                                                                               p_stmt_num           => l_stmt_num               ,
                                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                               p_run_log_level      => l_log_level
                                                                              );
                                                END IF;
                                                RAISE FND_API.G_EXC_ERROR;
                                    END IF;
                        ELSE
                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                       ,
                                                               p_msg_name           => 'WIP_JDI_INVALID_UNUSED_SERIAL',
                                                               p_msg_appl_name      => 'WIP'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;

                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                                null;
                END;

        END IF;

        -- We'll reach here only if the serial number is not found...
        -- or the calling program had passed 1 for new serial number
        -- Invoke the API.. to generate this serial number...

        l_stmt_num := 30;


        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Invoking inv_serial_number_pub.validate_serials',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        l_quantity  := 0;
        l_return_code := inv_serial_number_pub.validate_serials (  p_org_id             => p_organization_id,
                                                                   p_item_id            => p_assembly_item_id,
                                                                   p_qty                => l_quantity,
                                                                   p_wip_entity_id      => null,
                                                                   p_group_mark_id      => null,
                                                                   p_line_mark_id       => null,
                                                                   p_rev                => null,
                                                                   p_lot                => null,
                                                                   p_start_ser          => p_serial_number,
                                                                   p_trx_src_id         => null,
                                                                   p_trx_action_id      => null,
                                                                   p_subinventory_code  => null,
                                                                   p_locator_id         => null,
                                                                   x_end_ser            => p_serial_number,
                                                                   x_proc_msg           => x_error_msg);

        l_stmt_num := 40;

        if l_quantity <> 1 or l_return_code <> 0 then
             RAISE FND_API.G_EXC_ERROR;
        end if;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

END add_serial_number;

--- p_calling_mode = 1 --> Interface
---                = 2 --> Non-Interface..
--- update_serial_attr(1)

PROCEDURE update_serial_attr ( p_calling_mode           IN         NUMBER,
                               p_serial_number_rec      IN         WSM_Serial_Support_GRP.WSM_SERIAL_NUM_REC,
                               p_inventory_item_id      IN         NUMBER,
                               p_organization_id        IN         NUMBER,
                               p_clear_serial_attr      IN         NUMBER   DEFAULT NULL,  -- will be used in case of WLT to clear the attributes
                               p_wlt_txn_type           IN         NUMBER   DEFAULT NULL,
                               -- Pass the serial attribute context corresponding to the inventory item id
                               p_serial_attr_context    IN         VARCHAR2 DEFAULT NULL,
                               p_update_serial_attr     IN         NUMBER,
                               p_update_desc_attr       IN         NUMBER,
                               x_return_status          OUT NOCOPY VARCHAR2,
                               x_error_count            OUT NOCOPY NUMBER,
                               x_error_msg              OUT NOCOPY VARCHAR2
                             )

IS
l_serial_attributes_tbl         inv_lot_sel_attr.lot_sel_attributes_tbl_type;
l_desc_attributes_tbl           inv_serial_number_attr.char_table;

l_miss_char                     VARCHAR2(1) := FND_API.G_MISS_CHAR;
l_attribute_category            VARCHAR2(30);

l_update_serial_attr            NUMBER;
l_update_desc_attr              NUMBER;

l_ser_context                   MTL_SERIAL_NUMBERS.serial_attribute_category%type;


-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.update_serial_attr';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
        l_stmt_num := 10;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_inventory_item_id';
                l_param_tbl(1).paramValue := p_inventory_item_id;

                l_param_tbl(2).paramName := 'p_organization_id';
                l_param_tbl(2).paramValue := p_organization_id;

                l_param_tbl(3).paramName := 'p_serial_attr_context';
                l_param_tbl(3).paramValue := p_serial_attr_context;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;


        l_update_serial_attr := p_update_serial_attr;

        l_stmt_num := 20;

        if l_update_serial_attr is null then -- the calling program hasnt passed on the value..

                -- derive if a context exists...
                -- need an additional check on if WMS is installed or not...
                l_stmt_num := 30;

                if g_wms_installed IS NULL THEN

                        wms_installed ( x_return_status   =>  x_return_status   ,
                                        x_error_count   =>  x_error_count           ,
                                        x_err_data      =>  x_error_msg
                                      );

                        if x_return_status <> g_ret_success  then
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        end if;

                        l_update_serial_attr := g_wms_installed;
                else
                        l_update_serial_attr := g_wms_installed;
                end if;
        end if;

        l_stmt_num := 40;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Value of l_update_serial_attr ' || l_update_serial_attr,
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        l_stmt_num := 41;
        IF p_serial_attr_context IS NULL THEN
                -- The calling program hasnt passed the value...
                INV_LOT_SEL_ATTR.get_context_code ( context_value => l_ser_context,
                                                    org_id        => p_organization_id  ,
                                                    item_id       => p_inventory_item_id,
                                                    flex_name     => 'Serial Attributes'
                                                  );

        ELSE
                l_ser_context := p_serial_attr_context;
        END IF;

        l_stmt_num := 42;
        IF l_ser_context <> p_serial_number_rec.SERIAL_ATTRIBUTE_CATEGORY THEN
                -- error out.. if no context is defined then l_ser_context will be NULL
                -- and the user is free to specify the context..
                -- IF the user has passed NULL the INV API takes care of finding the defined context...
                -- populate a error message saying that the attributes will be cleared...
                IF g_log_level_exception >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_DEBUG_HIGH)
                THEN
                        l_msg_tokens.delete;
                        l_msg_tokens(1).TokenName := 'FLD_NAME';
                        l_msg_tokens(1).TokenValue := 'Serial Attribute Category for Serial Number : ' || p_serial_number_rec.serial_number;

                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_fnd_msg_level      => G_MSG_LVL_SUCCESS        ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level              ,
                                               p_wsm_warning        => 1
                                              );
                END IF;
        END IF;

        -- now construct the PL/SQL tables...
        if l_update_serial_attr = 1 THEN

                l_stmt_num := 50;

                l_serial_attributes_tbl(1).column_name   := 'SERIAL_ATTRIBUTE_CATEGORY';
                l_serial_attributes_tbl(1).column_type   := 'VARCHAR2';
                l_serial_attributes_tbl(2).column_name   := 'ORIGINATION_DATE';
                l_serial_attributes_tbl(2).column_type   := 'DATE';
                l_serial_attributes_tbl(3).column_name   := 'C_ATTRIBUTE1';
                l_serial_attributes_tbl(3).column_type   := 'VARCHAR2';
                l_serial_attributes_tbl(4).column_name   := 'C_ATTRIBUTE2';
                l_serial_attributes_tbl(4).column_type   := 'VARCHAR2';
                l_serial_attributes_tbl(5).column_name   := 'C_ATTRIBUTE3';
                l_serial_attributes_tbl(5).column_type   := 'VARCHAR2';
                l_serial_attributes_tbl(6).column_name   := 'C_ATTRIBUTE4';
                l_serial_attributes_tbl(6).column_type   := 'VARCHAR2';
                l_serial_attributes_tbl(7).column_name   := 'C_ATTRIBUTE5';
                l_serial_attributes_tbl(7).column_type   := 'VARCHAR2';
                l_serial_attributes_tbl(8).column_name   := 'C_ATTRIBUTE6';
                l_serial_attributes_tbl(8).column_type   := 'VARCHAR2';
                l_serial_attributes_tbl(9).column_name   := 'C_ATTRIBUTE7';
                l_serial_attributes_tbl(9).column_type   := 'VARCHAR2';
                l_serial_attributes_tbl(10).column_name  := 'C_ATTRIBUTE8';
                l_serial_attributes_tbl(10).column_type  := 'VARCHAR2';
                l_serial_attributes_tbl(11).column_name  := 'C_ATTRIBUTE9';
                l_serial_attributes_tbl(11).column_type  := 'VARCHAR2';
                l_serial_attributes_tbl(12).column_name  := 'C_ATTRIBUTE10';
                l_serial_attributes_tbl(12).column_type  := 'VARCHAR2';
                l_serial_attributes_tbl(13).column_name  := 'C_ATTRIBUTE11';
                l_serial_attributes_tbl(13).column_type  := 'VARCHAR2';
                l_serial_attributes_tbl(14).column_name  := 'C_ATTRIBUTE12';
                l_serial_attributes_tbl(14).column_type  := 'VARCHAR2';
                l_serial_attributes_tbl(15).column_name  := 'C_ATTRIBUTE13';
                l_serial_attributes_tbl(15).column_type  := 'VARCHAR2';
                l_serial_attributes_tbl(16).column_name  := 'C_ATTRIBUTE14';
                l_serial_attributes_tbl(16).column_type  := 'VARCHAR2';
                l_serial_attributes_tbl(17).column_name  := 'C_ATTRIBUTE15';
                l_serial_attributes_tbl(17).column_type  := 'VARCHAR2';
                l_serial_attributes_tbl(18).column_name  := 'C_ATTRIBUTE16';
                l_serial_attributes_tbl(18).column_type  := 'VARCHAR2';
                l_serial_attributes_tbl(19).column_name  := 'C_ATTRIBUTE17';
                l_serial_attributes_tbl(19).column_type  := 'VARCHAR2';
                l_serial_attributes_tbl(20).column_name  := 'C_ATTRIBUTE18';
                l_serial_attributes_tbl(20).column_type  := 'VARCHAR2';
                l_serial_attributes_tbl(21).column_name  := 'C_ATTRIBUTE19';
                l_serial_attributes_tbl(21).column_type  := 'VARCHAR2';
                l_serial_attributes_tbl(22).column_name  := 'C_ATTRIBUTE20';
                l_serial_attributes_tbl(22).column_type  := 'VARCHAR2';
                l_serial_attributes_tbl(23).column_name  := 'D_ATTRIBUTE1';
                l_serial_attributes_tbl(23).column_type  := 'DATE';
                l_serial_attributes_tbl(24).column_name  := 'D_ATTRIBUTE2';
                l_serial_attributes_tbl(24).column_type  := 'DATE';
                l_serial_attributes_tbl(25).column_name  := 'D_ATTRIBUTE3';
                l_serial_attributes_tbl(25).column_type  := 'DATE';
                l_serial_attributes_tbl(26).column_name  := 'D_ATTRIBUTE4';
                l_serial_attributes_tbl(26).column_type  := 'DATE';
                l_serial_attributes_tbl(27).column_name  := 'D_ATTRIBUTE5';
                l_serial_attributes_tbl(27).column_type  := 'DATE';
                l_serial_attributes_tbl(28).column_name  := 'D_ATTRIBUTE6';
                l_serial_attributes_tbl(28).column_type  := 'DATE';
                l_serial_attributes_tbl(29).column_name  := 'D_ATTRIBUTE7';
                l_serial_attributes_tbl(29).column_type  := 'DATE';
                l_serial_attributes_tbl(30).column_name  := 'D_ATTRIBUTE8';
                l_serial_attributes_tbl(30).column_type  := 'DATE';
                l_serial_attributes_tbl(31).column_name  := 'D_ATTRIBUTE9';
                l_serial_attributes_tbl(31).column_type  := 'DATE';
                l_serial_attributes_tbl(32).column_name  := 'D_ATTRIBUTE10';
                l_serial_attributes_tbl(32).column_type  := 'DATE';
                l_serial_attributes_tbl(33).column_name  := 'N_ATTRIBUTE1';
                l_serial_attributes_tbl(33).column_type  := 'NUMBER';
                l_serial_attributes_tbl(34).column_name  := 'N_ATTRIBUTE2';
                l_serial_attributes_tbl(34).column_type  := 'NUMBER';
                l_serial_attributes_tbl(35).column_name  := 'N_ATTRIBUTE3';
                l_serial_attributes_tbl(35).column_type  := 'NUMBER';
                l_serial_attributes_tbl(36).column_name  := 'N_ATTRIBUTE4';
                l_serial_attributes_tbl(36).column_type  := 'NUMBER';
                l_serial_attributes_tbl(37).column_name  := 'N_ATTRIBUTE5';
                l_serial_attributes_tbl(37).column_type  := 'NUMBER';
                l_serial_attributes_tbl(38).column_name  := 'N_ATTRIBUTE6';
                l_serial_attributes_tbl(38).column_type  := 'NUMBER';
                l_serial_attributes_tbl(39).column_name  := 'N_ATTRIBUTE7';
                l_serial_attributes_tbl(39).column_type  := 'NUMBER';
                l_serial_attributes_tbl(40).column_name  := 'N_ATTRIBUTE8';
                l_serial_attributes_tbl(40).column_type  := 'NUMBER';
                l_serial_attributes_tbl(41).column_name  := 'N_ATTRIBUTE9';
                l_serial_attributes_tbl(41).column_type  := 'NUMBER';
                l_serial_attributes_tbl(42).column_name  := 'N_ATTRIBUTE10';
                l_serial_attributes_tbl(42).column_type  := 'NUMBER';
                l_serial_attributes_tbl(43).column_name  := 'STATUS_ID';
                l_serial_attributes_tbl(43).column_type  := 'NUMBER';
                l_serial_attributes_tbl(44).column_name  := 'TERRITORY_CODE';
                l_serial_attributes_tbl(44).column_type  := 'VARCHAR2';

                IF p_clear_serial_attr IS NOT NULL THEN
                        -- clear all the attributes..
                        -- clear all the attributes..
                        l_stmt_num := 60;
                        for l_counter in 1..44 loop
                                l_serial_attributes_tbl(l_counter).column_value := null;
                        end loop;
                ELSE
                        l_stmt_num := 70;

                        l_serial_attributes_tbl(1).column_value   := p_serial_number_rec.SERIAL_ATTRIBUTE_CATEGORY;
                        l_serial_attributes_tbl(2).column_value   := p_serial_number_rec.ORIGINATION_DATE;
                        l_serial_attributes_tbl(3).column_value   := p_serial_number_rec.C_ATTRIBUTE1;
                        l_serial_attributes_tbl(4).column_value   := p_serial_number_rec.C_ATTRIBUTE2;
                        l_serial_attributes_tbl(5).column_value   := p_serial_number_rec.C_ATTRIBUTE3;
                        l_serial_attributes_tbl(6).column_value   := p_serial_number_rec.C_ATTRIBUTE4;
                        l_serial_attributes_tbl(7).column_value   := p_serial_number_rec.C_ATTRIBUTE5;
                        l_serial_attributes_tbl(8).column_value   := p_serial_number_rec.C_ATTRIBUTE6;
                        l_serial_attributes_tbl(9).column_value   := p_serial_number_rec.C_ATTRIBUTE7;
                        l_serial_attributes_tbl(10).column_value  := p_serial_number_rec.C_ATTRIBUTE8;
                        l_serial_attributes_tbl(11).column_value  := p_serial_number_rec.C_ATTRIBUTE9;
                        l_serial_attributes_tbl(12).column_value  := p_serial_number_rec.C_ATTRIBUTE10;
                        l_serial_attributes_tbl(13).column_value  := p_serial_number_rec.C_ATTRIBUTE11;
                        l_serial_attributes_tbl(14).column_value  := p_serial_number_rec.C_ATTRIBUTE12;
                        l_serial_attributes_tbl(15).column_value  := p_serial_number_rec.C_ATTRIBUTE13;
                        l_serial_attributes_tbl(16).column_value  := p_serial_number_rec.C_ATTRIBUTE14;
                        l_serial_attributes_tbl(17).column_value  := p_serial_number_rec.C_ATTRIBUTE15;
                        l_serial_attributes_tbl(18).column_value  := p_serial_number_rec.C_ATTRIBUTE16;
                        l_serial_attributes_tbl(19).column_value  := p_serial_number_rec.C_ATTRIBUTE17;
                        l_serial_attributes_tbl(20).column_value  := p_serial_number_rec.C_ATTRIBUTE18;
                        l_serial_attributes_tbl(21).column_value  := p_serial_number_rec.C_ATTRIBUTE19;
                        l_serial_attributes_tbl(22).column_value  := p_serial_number_rec.C_ATTRIBUTE20;
                        l_serial_attributes_tbl(23).column_value  := p_serial_number_rec.D_ATTRIBUTE1;
                        l_serial_attributes_tbl(24).column_value  := p_serial_number_rec.D_ATTRIBUTE2;
                        l_serial_attributes_tbl(25).column_value  := p_serial_number_rec.D_ATTRIBUTE3;
                        l_serial_attributes_tbl(26).column_value  := p_serial_number_rec.D_ATTRIBUTE4;
                        l_serial_attributes_tbl(27).column_value  := p_serial_number_rec.D_ATTRIBUTE5;
                        l_serial_attributes_tbl(28).column_value  := p_serial_number_rec.D_ATTRIBUTE6;
                        l_serial_attributes_tbl(29).column_value  := p_serial_number_rec.D_ATTRIBUTE7;
                        l_serial_attributes_tbl(30).column_value  := p_serial_number_rec.D_ATTRIBUTE8;
                        l_serial_attributes_tbl(31).column_value  := p_serial_number_rec.D_ATTRIBUTE9;
                        l_serial_attributes_tbl(32).column_value  := p_serial_number_rec.D_ATTRIBUTE10;
                        l_serial_attributes_tbl(33).column_value  := p_serial_number_rec.N_ATTRIBUTE1;
                        l_serial_attributes_tbl(34).column_value  := p_serial_number_rec.N_ATTRIBUTE2;
                        l_serial_attributes_tbl(35).column_value  := p_serial_number_rec.N_ATTRIBUTE3;
                        l_serial_attributes_tbl(36).column_value  := p_serial_number_rec.N_ATTRIBUTE4;
                        l_serial_attributes_tbl(37).column_value  := p_serial_number_rec.N_ATTRIBUTE5;
                        l_serial_attributes_tbl(38).column_value  := p_serial_number_rec.N_ATTRIBUTE6;
                        l_serial_attributes_tbl(39).column_value  := p_serial_number_rec.N_ATTRIBUTE7;
                        l_serial_attributes_tbl(40).column_value  := p_serial_number_rec.N_ATTRIBUTE8;
                        l_serial_attributes_tbl(41).column_value  := p_serial_number_rec.N_ATTRIBUTE9;
                        l_serial_attributes_tbl(42).column_value  := p_serial_number_rec.N_ATTRIBUTE10;
                        l_serial_attributes_tbl(43).column_value  := p_serial_number_rec.STATUS_ID;
                        l_serial_attributes_tbl(44).column_value  := p_serial_number_rec.TERRITORY_CODE;

                END IF;

        END IF;

        l_stmt_num := 72;
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN

                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Value of p_update_desc_attr ' || p_update_desc_attr,
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        IF nvl(p_update_desc_attr,1) = 1 THEN

                l_stmt_num := 75;

                If p_calling_mode = 1 THEN -- Interface

                        l_stmt_num := 80;

                        l_desc_attributes_tbl(1) := p_serial_number_rec.attribute1;
                        l_desc_attributes_tbl(2) := p_serial_number_rec.attribute2;
                        l_desc_attributes_tbl(3) := p_serial_number_rec.attribute3;
                        l_desc_attributes_tbl(4) := p_serial_number_rec.attribute4;
                        l_desc_attributes_tbl(5) := p_serial_number_rec.attribute5;
                        l_desc_attributes_tbl(6) := p_serial_number_rec.attribute6;
                        l_desc_attributes_tbl(7) := p_serial_number_rec.attribute7;
                        l_desc_attributes_tbl(8) := p_serial_number_rec.attribute8;
                        l_desc_attributes_tbl(9) := p_serial_number_rec.attribute9;
                        l_desc_attributes_tbl(10) := p_serial_number_rec.attribute10;
                        l_desc_attributes_tbl(11) := p_serial_number_rec.attribute11;
                        l_desc_attributes_tbl(12) := p_serial_number_rec.attribute12;
                        l_desc_attributes_tbl(13) := p_serial_number_rec.attribute13;
                        l_desc_attributes_tbl(14) := p_serial_number_rec.attribute14;
                        l_desc_attributes_tbl(15) := p_serial_number_rec.attribute15;

                ELSE
                        l_stmt_num := 90;

                        l_desc_attributes_tbl(1) := NVL(p_serial_number_rec.attribute1,l_miss_char);
                        l_desc_attributes_tbl(2) := NVL(p_serial_number_rec.attribute2,l_miss_char);
                        l_desc_attributes_tbl(3) := NVL(p_serial_number_rec.attribute3,l_miss_char);
                        l_desc_attributes_tbl(4) := NVL(p_serial_number_rec.attribute4,l_miss_char);
                        l_desc_attributes_tbl(5) := NVL(p_serial_number_rec.attribute5,l_miss_char);
                        l_desc_attributes_tbl(6) := NVL(p_serial_number_rec.attribute6,l_miss_char);
                        l_desc_attributes_tbl(7) := NVL(p_serial_number_rec.attribute7,l_miss_char);
                        l_desc_attributes_tbl(8) := NVL(p_serial_number_rec.attribute8,l_miss_char);
                        l_desc_attributes_tbl(9) := NVL(p_serial_number_rec.attribute9,l_miss_char);
                        l_desc_attributes_tbl(10) := NVL(p_serial_number_rec.attribute10,l_miss_char);
                        l_desc_attributes_tbl(11) := NVL(p_serial_number_rec.attribute11,l_miss_char);
                        l_desc_attributes_tbl(12) := NVL(p_serial_number_rec.attribute12,l_miss_char);
                        l_desc_attributes_tbl(13) := NVL(p_serial_number_rec.attribute13,l_miss_char);
                        l_desc_attributes_tbl(14) := NVL(p_serial_number_rec.attribute14,l_miss_char);
                        l_desc_attributes_tbl(15) := NVL(p_serial_number_rec.attribute15,l_miss_char);

                END IF;

        l_attribute_category      :=  p_serial_number_rec.attribute_category;

        END IF;

        l_stmt_num := 100;
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN

                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Invoking the procedure update_serial_attr(2)',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        update_serial_attr( p_job_serial_number       =>  p_serial_number_rec.serial_number  ,
                            p_inventory_item_id       =>  p_inventory_item_id                ,
                            p_organization_id         =>  p_organization_id                  ,
                            p_serial_desc_attr_tbl    =>  l_desc_attributes_tbl              ,
                            p_attribute_category      =>  l_attribute_category               ,
                            p_update_serial_attr      =>  p_update_serial_attr               ,
                            p_update_desc_attr        =>  1                                  ,
                            p_serial_attributes_tbl   =>  l_serial_attributes_tbl            ,
                            x_return_status           =>  x_return_status                    ,
                            x_error_count             =>  x_error_count                      ,
                            x_error_msg               =>  x_error_msg
                          );

        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
END update_serial_attr;


PROCEDURE update_serial_attr( p_job_serial_number     IN   VARCHAR2,
                              p_inventory_item_id     IN   NUMBER,
                              p_organization_id       IN   NUMBER,
                              p_serial_desc_attr_tbl  IN   inv_serial_number_attr.char_table,
                              p_attribute_category    IN   VARCHAR2,
                              p_update_serial_attr    IN   NUMBER DEFAULT NULL,
                              p_update_desc_attr      IN   NUMBER,
                              p_serial_attributes_tbl IN   inv_lot_sel_attr.lot_sel_attributes_tbl_type,
                              x_return_status         OUT  NOCOPY VARCHAR2,
                              x_error_count           OUT  NOCOPY NUMBER,
                              x_error_msg             OUT  NOCOPY VARCHAR2
                            ) IS

l_validation_status  varchar2(10);
l_update_serial_attr NUMBER;
l_update_desc_attr   NUMBER;

l_context_value      MTL_SERIAL_NUMBERS.serial_attribute_category%type;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.update_serial_attr(2)';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
        l_stmt_num  := 10;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_update_serial_attr';
                l_param_tbl(1).paramValue := p_update_serial_attr;

                l_param_tbl(2).paramName := 'p_update_desc_attr';
                l_param_tbl(2).paramValue := p_update_desc_attr;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        l_update_serial_attr := p_update_serial_attr;
        l_update_desc_attr   := nvl(p_update_desc_attr,1);

        l_stmt_num  := 20;

        if l_update_serial_attr is null then -- the calling program hasnt passed on the value..

                l_stmt_num  := 30;
                -- derive if a context exists...
                -- need an additional check on if WMS is installed or not...
                if g_wms_installed IS NULL THEN

                        wms_installed ( x_return_status   =>  x_return_status   ,
                                        x_error_count   =>  x_error_count           ,
                                        x_err_data      =>  x_error_msg
                                      );

                        if x_return_status <> g_ret_success  then
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        end if;

                        l_update_serial_attr := g_wms_installed;
                else
                        l_update_serial_attr := g_wms_installed;
                end if;
        end if;

        l_stmt_num  := 40;
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Value of l_update_serial_attr : ' || l_update_serial_attr,
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        if  (l_update_serial_attr = 1)
        then
                l_stmt_num  := 50;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking INV_SERIAL_NUMBER_PUB.validate_update_serial_att',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                INV_SERIAL_NUMBER_PUB.validate_update_serial_att (x_return_status         =>  x_return_status,
                                                                  x_msg_count             =>  x_error_count    ,
                                                                  x_msg_data              =>  x_error_msg     ,
                                                                  x_validation_status     =>  l_validation_status,
                                                                  p_serial_number         =>  p_job_serial_number,
                                                                  p_organization_id       =>  p_organization_id,
                                                                  p_inventory_item_id     =>  p_inventory_item_id,
                                                                  p_serial_att_tbl        =>  p_serial_attributes_tbl,
                                                                  p_validate_only         =>  false
                                                                 );

                if x_return_status <> g_ret_success or l_validation_status <> 'Y' then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        end if;

        l_stmt_num  := 60;

        IF l_update_desc_attr = 1 then

                l_stmt_num  := 70;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking INV_SERIAL_NUMBER_ATTR.Update_Serial_number_attr',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                -- Call to update the descriptive flex field...
                INV_SERIAL_NUMBER_ATTR.Update_Serial_number_attr(       x_return_status             => x_return_status,
                                                                        x_msg_count                 => x_error_count,
                                                                        x_msg_data                  => x_error_msg,
                                                                        p_serial_number             => p_job_serial_number,
                                                                        p_inventory_item_id         => p_inventory_item_id,
                                                                        p_attribute_category        => p_attribute_category,
                                                                        p_attributes_tbl            => p_serial_desc_attr_tbl
                                                                );

                if x_return_status <> G_RET_SUCCESS then
                        --error out..
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

                end if;
        end if;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

END update_serial_attr;

Procedure wms_installed(x_return_status OUT NOCOPY VARCHAR2     ,
                        x_error_count   OUT  NOCOPY NUMBER    ,
                        x_err_data      OUT  NOCOPY VARCHAR2
                        )

IS

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.wms_installed';
-- Logging variables...
BEGIN

    x_return_status := G_RET_SUCCESS;
    x_error_count   := 0;
    x_err_data      := null;

    l_stmt_num := 5;

    IF inv_install.adv_inv_installed(NULL) = TRUE THEN

        l_stmt_num := 10;
        g_wms_installed := 1;
        return;

    ELSE
        l_stmt_num := 20;
        g_wms_installed := 0;
        return;

    END IF;

    l_stmt_num := 30;

EXCEPTION

        WHEN others THEN
               x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_err_data
                                          );

END;


procedure update_serial( p_serial_number                IN              VARCHAR2,
                         p_inventory_item_id            IN              NUMBER,
                         --p_new_inventory_item_id      IN              NUMBER,
                         p_organization_id              IN              NUMBER,
                         p_wip_entity_id                IN              NUMBER,
                         p_operation_seq_num            IN              NUMBER,
                         p_intraoperation_step_type     IN              NUMBER,
                         x_return_status                OUT NOCOPY      VARCHAR2,
                         x_error_msg                    OUT NOCOPY      VARCHAR2,
                         x_error_count                  OUT NOCOPY      NUMBER
                        ) is
   l_object_id                  NUMBER;

   l_current_status             NUMBER;
   l_initialization_date        DATE;
   l_completion_date            DATE;
   l_ship_date                  DATE;
   l_revision                   VARCHAR2(3);
   l_lot_number                 VARCHAR2(80);   -- Changed for OPM Convergence project
   l_group_mark_id              NUMBER;
   l_lot_line_mark_id           NUMBER;
   l_current_organization_id    NUMBER;
   l_current_locator_id         NUMBER;
   l_current_subinventory_code  VARCHAR2(30);
   l_original_wip_entity_id     NUMBER;
   l_original_unit_vendor_id    NUMBER;
   l_vendor_lot_number          VARCHAR2(80);   -- Changed for OPM Convergence project
   l_vendor_serial_number       VARCHAR2(30);
   l_last_receipt_issue_type    NUMBER;
   l_last_txn_source_id         NUMBER;
   l_last_txn_source_type_id    NUMBER;
   l_last_txn_source_name       VARCHAR2(80);   -- Changed for OPM Convergence project
   l_parent_item_id             NUMBER;
   l_parent_serial_number       VARCHAR2(30);

   l_last_status                NUMBER;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.update_serial';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

begin
        l_stmt_num := 10;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_serial_number';
                l_param_tbl(1).paramValue := p_serial_number;

                l_param_tbl(2).paramName := 'p_wip_entity_id';
                l_param_tbl(2).paramValue := p_wip_entity_id;

                l_param_tbl(3).paramName := 'p_operation_seq_num';
                l_param_tbl(3).paramValue := p_operation_seq_num;

                l_param_tbl(4).paramName := 'p_intraoperation_step_type';
                l_param_tbl(4).paramValue := p_intraoperation_step_type;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        SAVEPOINT update_serial;

        SELECT current_status,
          initialization_date,
          completion_date,
          ship_date,
          revision,
          lot_number,
          group_mark_id,
          lot_line_mark_id,
          current_organization_id,
          current_locator_id,
          current_subinventory_code,
          original_wip_entity_id,
          original_unit_vendor_id,
          vendor_lot_number,
          vendor_serial_number,
          last_receipt_issue_type,
          last_txn_source_id,
          last_txn_source_type_id,
          last_txn_source_name,
          parent_item_id,
          parent_serial_number
        INTO l_current_status,
          l_initialization_date,
          l_completion_date,
          l_ship_date,
          l_revision,
          l_lot_number,
          l_group_mark_id,
          l_lot_line_mark_id,
          l_current_organization_id,
          l_current_locator_id,
          l_current_subinventory_code,
          l_original_wip_entity_id,
          l_original_unit_vendor_id,
          l_vendor_lot_number,
          l_vendor_serial_number,
          l_last_receipt_issue_type,
          l_last_txn_source_id,
          l_last_txn_source_type_id,
          l_last_txn_source_name,
          l_parent_item_id,
          l_parent_serial_number
        FROM mtl_serial_numbers
        WHERE serial_number = p_serial_number
        AND inventory_item_id = p_inventory_item_id
        AND current_organization_id = p_organization_id
        FOR UPDATE NOWAIT;

        l_stmt_num := 20;

        if(l_current_status = 6) then
                l_last_status := 1;
        else
                l_last_status := l_current_status;
        end if;

        l_stmt_num := 30;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Invoking INV_SERIAL_NUMBER_PUB.updateserial',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        inv_serial_number_pub.updateserial (  p_api_version              => 1.0,
                                              p_inventory_item_id        => p_inventory_item_id,
                                              p_organization_id          => p_organization_id,
                                              p_serial_number            => p_serial_number,
                                              p_initialization_date      => l_initialization_date,
                                              p_completion_date          => l_completion_date,
                                              p_ship_date                => l_ship_date,
                                              p_revision                 => l_revision,
                                              p_lot_number               => l_lot_number,
                                              p_current_locator_id       => l_current_locator_id,
                                              p_subinventory_code        => l_current_subinventory_code,
                                              p_trx_src_id               => l_original_wip_entity_id,
                                              p_unit_vendor_id           => l_original_unit_vendor_id,
                                              p_vendor_lot_number        => l_vendor_lot_number,
                                              p_vendor_serial_number     => l_vendor_serial_number,
                                              p_receipt_issue_type       => l_last_receipt_issue_type,
                                              p_txn_src_id               => l_last_txn_source_id,
                                              p_txn_src_name             => l_last_txn_source_name,
                                              p_txn_src_type_id          => l_last_txn_source_type_id,
                                              p_current_status           => l_current_status,
                                              p_parent_item_id           => l_parent_item_id,
                                              p_parent_serial_number     => l_parent_serial_number,
                                              p_serial_temp_id           => null,
                                              p_last_status              => l_last_status,
                                              p_status_id                => null,
                                              x_object_id                => l_object_id,
                                              x_return_status            => x_return_status,
                                              x_msg_count                => x_error_count,
                                              x_msg_data                 => x_error_msg,
                                              p_wip_entity_id            => p_wip_entity_id,
                                              p_operation_seq_num        => p_operation_seq_num,
                                              p_intraoperation_step_type => p_intraoperation_step_type,
                                              p_line_mark_id             => l_lot_line_mark_id
                                           );

        l_stmt_num := 40;

        IF x_return_status = G_RET_ERROR THEN
                raise FND_API.G_EXC_ERROR;
        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

exception

        WHEN FND_API.G_EXC_ERROR THEN
                rollback to update_serial;
                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                rollback to update_serial;
                x_return_status := G_RET_UNEXPECTED;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN
                 rollback to update_serial;
                 x_return_status := G_RET_UNEXPECTED;
                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

end update_serial;

-- The addition/deletion of serial numbers will be handled by this procedure...
-- Then it will invoke the main processor whose activities will be common...
Procedure Move_serial_intf_proc(p_header_id                     IN              NUMBER,
                                p_wsm_serial_nums_tbl           IN              WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                p_move_txn_type                 IN              NUMBER,
                                p_wip_entity_id                 IN              NUMBER,
                                p_organization_id               IN              NUMBER,
                                p_inventory_item_id             IN              NUMBER,
                                p_move_qty                      IN              NUMBER,
                                p_scrap_qty                     IN              NUMBER,
                                p_available_qty                 IN              NUMBER,
                                p_curr_job_op_seq_num           IN              NUMBER,
                                p_curr_job_intraop_step         IN              NUMBER,
                                p_from_rtg_op_seq_num           IN              NUMBER,
                                p_to_rtg_op_seq_num             IN              NUMBER,
                                p_to_intraoperation_step        IN              NUMBER,
                                p_user_serial_tracking          IN              NUMBER,
                                p_move_txn_id                   IN              NUMBER,
                                p_scrap_txn_id                  IN              NUMBER,
                                p_old_move_txn_id               IN              NUMBER,
                                p_old_scrap_txn_id              IN              NUMBER,
                                p_jump_flag                     IN              varchar2   DEFAULT  NULL,
                                p_scrap_at_operation            IN              NUMBER     DEFAULT  NULL,
                                -- ST : Fix for bug 5140761 Addded the above parameter --
                                x_serial_track_flag             OUT NOCOPY      NUMBER,
                                x_return_status                 OUT NOCOPY      VARCHAR2,
                                x_error_msg                     OUT NOCOPY      VARCHAR2,
                                x_error_count                   OUT NOCOPY      NUMBER
                                )

IS

        l_serial_ctrl_code      NUMBER;
        l_serial_start_flag     NUMBER;
        l_first_serial_txn_id   NUMBER;
        l_serial_start_op       NUMBER;

        l_miss_char             VARCHAR2(1) := FND_API.G_MISS_CHAR;
        l_null_num              NUMBER      := FND_API.G_NULL_NUM;
        l_null_date             DATE        := FND_API.G_NULL_DATE;
        l_null_char             VARCHAR2(1) := FND_API.G_NULL_CHAR;

        cursor c_move_serials
        is
        select
        wsti.Serial_Number                     ,
        msn.gen_object_id                      ,
        -- (Gen_object_id --> assembly_item_id No longer used Instead the column will have gen_object_id)
        wsti.header_id                         ,  -- header_id
        wsti.Generate_serial_number            ,
        wsti.Generate_for_qty                  ,
        wsti.Action_flag                       ,
        wsti.Current_wip_entity_name           ,
        wsti.Changed_wip_entity_name           ,
        wsti.Current_wip_entity_id             ,
        wsti.Changed_wip_entity_id             ,
        decode(wsti.serial_attribute_category  , l_null_char, null, null, msn.serial_attribute_category, wsti.serial_attribute_category), -- serial_attribute_category
        decode(wsti.territory_code             , l_null_char, null, null, msn.territory_code           , wsti.territory_code           ), -- territory_code
        decode(wsti.origination_date           , l_null_date, null, null, msn.origination_date         , wsti.origination_date         ), -- origination_date
        decode(wsti.c_attribute1               , l_null_char, null, null, msn.c_attribute1             , wsti.c_attribute1             ), -- c_attribute1
        decode(wsti.c_attribute2               , l_null_char, null, null, msn.c_attribute2             , wsti.c_attribute2             ), -- c_attribute2
        decode(wsti.c_attribute3               , l_null_char, null, null, msn.c_attribute3             , wsti.c_attribute3             ), -- c_attribute3
        decode(wsti.c_attribute4               , l_null_char, null, null, msn.c_attribute4             , wsti.c_attribute4             ), -- c_attribute4
        decode(wsti.c_attribute5               , l_null_char, null, null, msn.c_attribute5             , wsti.c_attribute5             ), -- c_attribute5
        decode(wsti.c_attribute6               , l_null_char, null, null, msn.c_attribute6             , wsti.c_attribute6             ), -- c_attribute6
        decode(wsti.c_attribute7               , l_null_char, null, null, msn.c_attribute7             , wsti.c_attribute7             ), -- c_attribute7
        decode(wsti.c_attribute8               , l_null_char, null, null, msn.c_attribute8             , wsti.c_attribute8             ), -- c_attribute8
        decode(wsti.c_attribute9               , l_null_char, null, null, msn.c_attribute9             , wsti.c_attribute9             ), -- c_attribute9
        decode(wsti.c_attribute10              , l_null_char, null, null, msn.c_attribute10            , wsti.c_attribute10            ), -- c_attribute10
        decode(wsti.c_attribute11              , l_null_char, null, null, msn.c_attribute11            , wsti.c_attribute11            ), -- c_attribute11
        decode(wsti.c_attribute12              , l_null_char, null, null, msn.c_attribute12            , wsti.c_attribute12            ), -- c_attribute12
        decode(wsti.c_attribute13              , l_null_char, null, null, msn.c_attribute13            , wsti.c_attribute13            ), -- c_attribute13
        decode(wsti.c_attribute14              , l_null_char, null, null, msn.c_attribute14            , wsti.c_attribute14            ), -- c_attribute14
        decode(wsti.c_attribute15              , l_null_char, null, null, msn.c_attribute15            , wsti.c_attribute15            ), -- c_attribute15
        decode(wsti.c_attribute16              , l_null_char, null, null, msn.c_attribute16            , wsti.c_attribute16            ), -- c_attribute16
        decode(wsti.c_attribute17              , l_null_char, null, null, msn.c_attribute17            , wsti.c_attribute17            ), -- c_attribute17
        decode(wsti.c_attribute18              , l_null_char, null, null, msn.c_attribute18            , wsti.c_attribute18            ), -- c_attribute18
        decode(wsti.c_attribute19              , l_null_char, null, null, msn.c_attribute19            , wsti.c_attribute19            ), -- c_attribute19
        decode(wsti.c_attribute20              , l_null_char, null, null, msn.c_attribute20            , wsti.c_attribute20            ), -- c_attribute20
        decode(wsti.d_attribute1               , l_null_date, null, null, msn.d_attribute1             , wsti.d_attribute1             ), -- d_attribute1
        decode(wsti.d_attribute2               , l_null_date, null, null, msn.d_attribute2             , wsti.d_attribute2             ), -- d_attribute2
        decode(wsti.d_attribute3               , l_null_date, null, null, msn.d_attribute3             , wsti.d_attribute3             ), -- d_attribute3
        decode(wsti.d_attribute4               , l_null_date, null, null, msn.d_attribute4             , wsti.d_attribute4             ), -- d_attribute4
        decode(wsti.d_attribute5               , l_null_date, null, null, msn.d_attribute5             , wsti.d_attribute5             ), -- d_attribute5
        decode(wsti.d_attribute6               , l_null_date, null, null, msn.d_attribute6             , wsti.d_attribute6             ), -- d_attribute6
        decode(wsti.d_attribute7               , l_null_date, null, null, msn.d_attribute7             , wsti.d_attribute7             ), -- d_attribute7
        decode(wsti.d_attribute8               , l_null_date, null, null, msn.d_attribute8             , wsti.d_attribute8             ), -- d_attribute8
        decode(wsti.d_attribute9               , l_null_date, null, null, msn.d_attribute9             , wsti.d_attribute9             ), -- d_attribute9
        decode(wsti.d_attribute10              , l_null_date, null, null, msn.d_attribute10            , wsti.d_attribute10            ), -- d_attribute10
        decode(wsti.n_attribute1               , l_null_num , null, null, msn.n_attribute1             , wsti.n_attribute1             ), -- n_attribute1
        decode(wsti.n_attribute2               , l_null_num , null, null, msn.n_attribute2             , wsti.n_attribute2             ), -- n_attribute2
        decode(wsti.n_attribute3               , l_null_num , null, null, msn.n_attribute3             , wsti.n_attribute3             ), -- n_attribute3
        decode(wsti.n_attribute4               , l_null_num , null, null, msn.n_attribute4             , wsti.n_attribute4             ), -- n_attribute4
        decode(wsti.n_attribute5               , l_null_num , null, null, msn.n_attribute5             , wsti.n_attribute5             ), -- n_attribute5
        decode(wsti.n_attribute6               , l_null_num , null, null, msn.n_attribute6             , wsti.n_attribute6             ), -- n_attribute6
        decode(wsti.n_attribute7               , l_null_num , null, null, msn.n_attribute7             , wsti.n_attribute7             ), -- n_attribute7
        decode(wsti.n_attribute8               , l_null_num , null, null, msn.n_attribute8             , wsti.n_attribute8             ), -- n_attribute8
        decode(wsti.n_attribute9               , l_null_num , null, null, msn.n_attribute9             , wsti.n_attribute9             ), -- n_attribute9
        decode(wsti.n_attribute10              , l_null_num , null, null, msn.n_attribute10            , wsti.n_attribute10            ), -- n_attribute10
        decode(wsti.status_id                  , l_null_num , null, null, msn.status_id                , wsti.status_id                ), -- status_id
        decode(wsti.time_since_new             , l_null_num , null, null, msn.time_since_new           , wsti.time_since_new           ), -- time_since_new
        decode(wsti.cycles_since_new           , l_null_num , null, null, msn.cycles_since_new         , wsti.cycles_since_new         ), -- cycles_since_new
        decode(wsti.time_since_overhaul        , l_null_num , null, null, msn.time_since_overhaul      , wsti.time_since_overhaul      ), -- time_since_overhaul
        decode(wsti.cycles_since_overhaul      , l_null_num , null, null, msn.cycles_since_overhaul    , wsti.cycles_since_overhaul    ), -- cycles_since_overhaul
        decode(wsti.time_since_repair          , l_null_num , null, null, msn.time_since_repair        , wsti.time_since_repair        ), -- time_since_repair
        decode(wsti.cycles_since_repair        , l_null_num , null, null, msn.cycles_since_repair      , wsti.cycles_since_repair      ), -- cycles_since_repair
        decode(wsti.time_since_visit           , l_null_num , null, null, msn.time_since_visit         , wsti.time_since_visit         ), -- time_since_visit
        decode(wsti.cycles_since_visit         , l_null_num , null, null, msn.cycles_since_visit       , wsti.cycles_since_visit       ), -- cycles_since_visit
        decode(wsti.time_since_mark            , l_null_num , null, null, msn.time_since_mark          , wsti.time_since_mark          ), -- time_since_mark
        decode(wsti.cycles_since_mark          , l_null_num , null, null, msn.cycles_since_mark        , wsti.cycles_since_mark        ), -- cycles_since_mark
        decode(wsti.number_of_repairs          , l_null_num , null, null, msn.number_of_repairs        , wsti.number_of_repairs        ), -- number_of_repairs
        decode(wsti.attribute_category         , l_null_char, l_miss_char , null ,msn.attribute_category   ,wsti.attribute_category    ),
        decode(wsti.attribute1                 , l_null_char ,l_miss_char , wsti.attribute1            ),
        decode(wsti.attribute2                 , l_null_char ,l_miss_char , wsti.attribute2            ),
        decode(wsti.attribute3                 , l_null_char ,l_miss_char , wsti.attribute3            ),
        decode(wsti.attribute4                 , l_null_char ,l_miss_char , wsti.attribute4            ),
        decode(wsti.attribute5                 , l_null_char ,l_miss_char , wsti.attribute5            ),
        decode(wsti.attribute6                 , l_null_char ,l_miss_char , wsti.attribute6            ),
        decode(wsti.attribute7                 , l_null_char ,l_miss_char , wsti.attribute7            ),
        decode(wsti.attribute8                 , l_null_char ,l_miss_char , wsti.attribute8            ),
        decode(wsti.attribute9                 , l_null_char ,l_miss_char , wsti.attribute9            ),
        decode(wsti.attribute10                , l_null_char ,l_miss_char , wsti.attribute10           ),
        decode(wsti.attribute11                , l_null_char ,l_miss_char , wsti.attribute11           ),
        decode(wsti.attribute12                , l_null_char ,l_miss_char , wsti.attribute12           ),
        decode(wsti.attribute13                , l_null_char ,l_miss_char , wsti.attribute13           ),
        decode(wsti.attribute14                , l_null_char ,l_miss_char , wsti.attribute14           ),
        decode(wsti.attribute15                , l_null_char ,l_miss_char , wsti.attribute15           )
        from wsm_serial_txn_interface wsti,
             mtl_serial_numbers       msn
        where wsti.header_id = p_header_id
        and   wsti.transaction_type_id = 2
        and  (wsti.action_flag >= 5 AND wsti.action_flag <= 6) -- select the move/scrap
        and   wsti.serial_number = msn.serial_number (+)
        and   msn.inventory_item_id (+) = p_inventory_item_id
        and   msn.current_organization_id (+) = p_organization_id;

        cursor c_process_move_serials
        is
        select
        wsti.Serial_Number                     ,
        msn.gen_object_id                      ,
        -- (Gen_object_id --> assembly_item_id No longer used Instead the column will have gen_object_id)
        wsti.header_id                         ,  -- header_id
        wsti.Generate_serial_number            ,
        wsti.Generate_for_qty                  ,
        wsti.Action_flag                       ,
        wsti.Current_wip_entity_name           ,
        wsti.Changed_wip_entity_name           ,
        wsti.Current_wip_entity_id             ,
        wsti.Changed_wip_entity_id             ,
        decode(wsti.serial_attribute_category  , l_null_char, null, null, msn.serial_attribute_category, wsti.serial_attribute_category), -- serial_attribute_category
        decode(wsti.territory_code             , l_null_char, null, null, msn.territory_code           , wsti.territory_code           ), -- territory_code
        decode(wsti.origination_date           , l_null_date, null, null, msn.origination_date         , wsti.origination_date         ), -- origination_date
        decode(wsti.c_attribute1               , l_null_char, null, null, msn.c_attribute1             , wsti.c_attribute1             ), -- c_attribute1
        decode(wsti.c_attribute2               , l_null_char, null, null, msn.c_attribute2             , wsti.c_attribute2             ), -- c_attribute2
        decode(wsti.c_attribute3               , l_null_char, null, null, msn.c_attribute3             , wsti.c_attribute3             ), -- c_attribute3
        decode(wsti.c_attribute4               , l_null_char, null, null, msn.c_attribute4             , wsti.c_attribute4             ), -- c_attribute4
        decode(wsti.c_attribute5               , l_null_char, null, null, msn.c_attribute5             , wsti.c_attribute5             ), -- c_attribute5
        decode(wsti.c_attribute6               , l_null_char, null, null, msn.c_attribute6             , wsti.c_attribute6             ), -- c_attribute6
        decode(wsti.c_attribute7               , l_null_char, null, null, msn.c_attribute7             , wsti.c_attribute7             ), -- c_attribute7
        decode(wsti.c_attribute8               , l_null_char, null, null, msn.c_attribute8             , wsti.c_attribute8             ), -- c_attribute8
        decode(wsti.c_attribute9               , l_null_char, null, null, msn.c_attribute9             , wsti.c_attribute9             ), -- c_attribute9
        decode(wsti.c_attribute10              , l_null_char, null, null, msn.c_attribute10            , wsti.c_attribute10            ), -- c_attribute10
        decode(wsti.c_attribute11              , l_null_char, null, null, msn.c_attribute11            , wsti.c_attribute11            ), -- c_attribute11
        decode(wsti.c_attribute12              , l_null_char, null, null, msn.c_attribute12            , wsti.c_attribute12            ), -- c_attribute12
        decode(wsti.c_attribute13              , l_null_char, null, null, msn.c_attribute13            , wsti.c_attribute13            ), -- c_attribute13
        decode(wsti.c_attribute14              , l_null_char, null, null, msn.c_attribute14            , wsti.c_attribute14            ), -- c_attribute14
        decode(wsti.c_attribute15              , l_null_char, null, null, msn.c_attribute15            , wsti.c_attribute15            ), -- c_attribute15
        decode(wsti.c_attribute16              , l_null_char, null, null, msn.c_attribute16            , wsti.c_attribute16            ), -- c_attribute16
        decode(wsti.c_attribute17              , l_null_char, null, null, msn.c_attribute17            , wsti.c_attribute17            ), -- c_attribute17
        decode(wsti.c_attribute18              , l_null_char, null, null, msn.c_attribute18            , wsti.c_attribute18            ), -- c_attribute18
        decode(wsti.c_attribute19              , l_null_char, null, null, msn.c_attribute19            , wsti.c_attribute19            ), -- c_attribute19
        decode(wsti.c_attribute20              , l_null_char, null, null, msn.c_attribute20            , wsti.c_attribute20            ), -- c_attribute20
        decode(wsti.d_attribute1               , l_null_date, null, null, msn.d_attribute1             , wsti.d_attribute1             ), -- d_attribute1
        decode(wsti.d_attribute2               , l_null_date, null, null, msn.d_attribute2             , wsti.d_attribute2             ), -- d_attribute2
        decode(wsti.d_attribute3               , l_null_date, null, null, msn.d_attribute3             , wsti.d_attribute3             ), -- d_attribute3
        decode(wsti.d_attribute4               , l_null_date, null, null, msn.d_attribute4             , wsti.d_attribute4             ), -- d_attribute4
        decode(wsti.d_attribute5               , l_null_date, null, null, msn.d_attribute5             , wsti.d_attribute5             ), -- d_attribute5
        decode(wsti.d_attribute6               , l_null_date, null, null, msn.d_attribute6             , wsti.d_attribute6             ), -- d_attribute6
        decode(wsti.d_attribute7               , l_null_date, null, null, msn.d_attribute7             , wsti.d_attribute7             ), -- d_attribute7
        decode(wsti.d_attribute8               , l_null_date, null, null, msn.d_attribute8             , wsti.d_attribute8             ), -- d_attribute8
        decode(wsti.d_attribute9               , l_null_date, null, null, msn.d_attribute9             , wsti.d_attribute9             ), -- d_attribute9
        decode(wsti.d_attribute10              , l_null_date, null, null, msn.d_attribute10            , wsti.d_attribute10            ), -- d_attribute10
        decode(wsti.n_attribute1               , l_null_num , null, null, msn.n_attribute1             , wsti.n_attribute1             ), -- n_attribute1
        decode(wsti.n_attribute2               , l_null_num , null, null, msn.n_attribute2             , wsti.n_attribute2             ), -- n_attribute2
        decode(wsti.n_attribute3               , l_null_num , null, null, msn.n_attribute3             , wsti.n_attribute3             ), -- n_attribute3
        decode(wsti.n_attribute4               , l_null_num , null, null, msn.n_attribute4             , wsti.n_attribute4             ), -- n_attribute4
        decode(wsti.n_attribute5               , l_null_num , null, null, msn.n_attribute5             , wsti.n_attribute5             ), -- n_attribute5
        decode(wsti.n_attribute6               , l_null_num , null, null, msn.n_attribute6             , wsti.n_attribute6             ), -- n_attribute6
        decode(wsti.n_attribute7               , l_null_num , null, null, msn.n_attribute7             , wsti.n_attribute7             ), -- n_attribute7
        decode(wsti.n_attribute8               , l_null_num , null, null, msn.n_attribute8             , wsti.n_attribute8             ), -- n_attribute8
        decode(wsti.n_attribute9               , l_null_num , null, null, msn.n_attribute9             , wsti.n_attribute9             ), -- n_attribute9
        decode(wsti.n_attribute10              , l_null_num , null, null, msn.n_attribute10            , wsti.n_attribute10            ), -- n_attribute10
        decode(wsti.status_id                  , l_null_num , null, null, msn.status_id                , wsti.status_id                ), -- status_id
        decode(wsti.time_since_new             , l_null_num , null, null, msn.time_since_new           , wsti.time_since_new           ), -- time_since_new
        decode(wsti.cycles_since_new           , l_null_num , null, null, msn.cycles_since_new         , wsti.cycles_since_new         ), -- cycles_since_new
        decode(wsti.time_since_overhaul        , l_null_num , null, null, msn.time_since_overhaul      , wsti.time_since_overhaul      ), -- time_since_overhaul
        decode(wsti.cycles_since_overhaul      , l_null_num , null, null, msn.cycles_since_overhaul    , wsti.cycles_since_overhaul    ), -- cycles_since_overhaul
        decode(wsti.time_since_repair          , l_null_num , null, null, msn.time_since_repair        , wsti.time_since_repair        ), -- time_since_repair
        decode(wsti.cycles_since_repair        , l_null_num , null, null, msn.cycles_since_repair      , wsti.cycles_since_repair      ), -- cycles_since_repair
        decode(wsti.time_since_visit           , l_null_num , null, null, msn.time_since_visit         , wsti.time_since_visit         ), -- time_since_visit
        decode(wsti.cycles_since_visit         , l_null_num , null, null, msn.cycles_since_visit       , wsti.cycles_since_visit       ), -- cycles_since_visit
        decode(wsti.time_since_mark            , l_null_num , null, null, msn.time_since_mark          , wsti.time_since_mark          ), -- time_since_mark
        decode(wsti.cycles_since_mark          , l_null_num , null, null, msn.cycles_since_mark        , wsti.cycles_since_mark        ), -- cycles_since_mark
        decode(wsti.number_of_repairs          , l_null_num , null, null, msn.number_of_repairs        , wsti.number_of_repairs        ), -- number_of_repairs
        decode(wsti.attribute_category         , l_null_char, l_miss_char , null ,msn.attribute_category   ,wsti.attribute_category    ),
        decode(wsti.attribute1                 , l_null_char ,l_miss_char , wsti.attribute1            ),
        decode(wsti.attribute2                 , l_null_char ,l_miss_char , wsti.attribute2            ),
        decode(wsti.attribute3                 , l_null_char ,l_miss_char , wsti.attribute3            ),
        decode(wsti.attribute4                 , l_null_char ,l_miss_char , wsti.attribute4            ),
        decode(wsti.attribute5                 , l_null_char ,l_miss_char , wsti.attribute5            ),
        decode(wsti.attribute6                 , l_null_char ,l_miss_char , wsti.attribute6            ),
        decode(wsti.attribute7                 , l_null_char ,l_miss_char , wsti.attribute7            ),
        decode(wsti.attribute8                 , l_null_char ,l_miss_char , wsti.attribute8            ),
        decode(wsti.attribute9                 , l_null_char ,l_miss_char , wsti.attribute9            ),
        decode(wsti.attribute10                , l_null_char ,l_miss_char , wsti.attribute10           ),
        decode(wsti.attribute11                , l_null_char ,l_miss_char , wsti.attribute11           ),
        decode(wsti.attribute12                , l_null_char ,l_miss_char , wsti.attribute12           ),
        decode(wsti.attribute13                , l_null_char ,l_miss_char , wsti.attribute13           ),
        decode(wsti.attribute14                , l_null_char ,l_miss_char , wsti.attribute14           ),
        decode(wsti.attribute15                , l_null_char ,l_miss_char , wsti.attribute15           )
        from wsm_serial_txn_interface wsti,
             mtl_serial_numbers       msn
        where wsti.header_id = p_header_id
        and   wsti.transaction_type_id = 2
        and  (nvl(wsti.action_flag,wsti.generate_serial_number) >= 1 AND nvl(wsti.action_flag,wsti.generate_serial_number) <= 3) -- select the move/scrap
        and  wsti.serial_number = msn.serial_number (+)
        and  msn.inventory_item_id (+) = p_inventory_item_id
        and  msn.current_organization_id (+) = p_organization_id
        order by nvl(wsti.action_flag,0) desc; -- Code review remark
        -- first process Delete and then add

l_wsm_serial_nums_tbl   WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL;
l_serial_tbl            t_varchar2;
l_row_updated           NUMBER;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.Move_serial_intf_proc';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
        l_stmt_num := 10;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN
                l_stmt_num := 15;
                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_wip_entity_id';
                l_param_tbl(1).paramValue := p_wip_entity_id;

                l_param_tbl(2).paramName := 'p_inventory_item_id';
                l_param_tbl(2).paramValue := p_inventory_item_id;

                l_param_tbl(3).paramName := 'p_organization_id';
                l_param_tbl(3).paramValue := p_organization_id;

                l_param_tbl(4).paramName := 'p_header_id';
                l_param_tbl(4).paramValue := p_header_id;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        -- first get all the serial numbers to be inserted/delinked/updated...
        -- call process_serial_info..
        l_stmt_num := 20;

        -- Validate the item_id/job for serial control..
        get_serial_track_info( p_serial_item_id         => p_inventory_item_id,
                               p_organization_id        => p_organization_id,
                               p_wip_entity_id          => p_wip_entity_id,
                               x_serial_start_flag      => x_serial_track_flag,
                               x_serial_ctrl_code       => l_serial_ctrl_code,
                               x_first_serial_txn_id    => l_first_serial_txn_id,
                               x_serial_start_op        => l_serial_start_op,
                               x_return_status          => x_return_status,
                               x_error_msg              => x_error_msg,
                               x_error_count            => x_error_count
                            );

        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;
        l_stmt_num := 25;

        -- check for serial track...
        -- we dont have to worry about Lot control as the LBJ creation would have failed before this is invoked..
        if l_serial_ctrl_code = 1 then -- No serial control

                l_stmt_num := 30;
                -- issue an update statement to the interface records setting them to errored..
                l_row_updated := 0;
                IF p_wsm_serial_nums_tbl.count = 0 THEN
                        update wsm_serial_txn_interface
                        set process_status = wip_constants.error
                        where header_id = p_header_id
                        and transaction_type_id = 2;

                        l_row_updated := SQL%ROWCOUNT;
                END IF;

                if l_row_updated > 0 OR p_wsm_serial_nums_tbl.count > 0 then
                        -- return error as interface rows were updated...
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVLAID_SERIAL_INFO',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;
                RETURN;

        ELSIF p_wsm_serial_nums_tbl.count = 0 THEN
                -- Fetch the serials only for interface/in case of MES ignore
                l_stmt_num := 40;
                -- Initially process all the serial number addition
                open c_process_move_serials;
                fetch c_process_move_serials
                bulk collect into  l_wsm_serial_nums_tbl;
                close c_process_move_serials;

                -- invoke process_serial_info
                if l_wsm_serial_nums_tbl.count > 0 then

                        l_stmt_num := 50;
                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Inside process_serial_info to process : ' || l_wsm_serial_nums_tbl.count || ' records',
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;
                        process_serial_info (p_calling_mode         => 1,
                                             p_wsm_serial_nums_tbl  => l_wsm_serial_nums_tbl,
                                             p_wip_entity_id        => p_wip_entity_id,
                                             p_serial_start_flag    => l_serial_start_flag,
                                             p_organization_id      => p_organization_id,
                                             p_item_id              => p_inventory_item_id,
                                             x_serial_tbl          => l_serial_tbl,
                                             x_return_status        => x_return_status,
                                             x_error_msg            => x_error_msg,
                                             x_error_count          => x_error_count
                                           );

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;
                end if; -- end invoke process_serial_info

        END IF; -- end check for serial control

        l_stmt_num := 60;
        -- empty the PL/SQL table...
        l_wsm_serial_nums_tbl.delete;

        IF p_move_txn_type IN (3,4) THEN -- Undo/assembly return...

                l_stmt_num := 70;
                l_row_updated := 0;
                IF p_wsm_serial_nums_tbl.count = 0 then
                        update wsm_serial_txn_interface wsti
                        set wsti.process_status = wip_constants.error
                        where wsti.header_id = p_header_id
                        and wsti.transaction_type_id = 2
                        and wsti.action_flag in (5,6);

                        l_row_updated := SQL%ROWCOUNT;
                END IF;

                if l_row_updated > 0 or p_wsm_serial_nums_tbl.count > 0 then
                        -- error.. message....
                        l_stmt_num := 80;
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_NO_FOR_SERIAL_UNDO_ASSYRET',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

        ELSE
                l_stmt_num := 90;

                IF p_wsm_serial_nums_tbl.count = 0 then
                        update wsm_serial_txn_interface wsti
                        set wsti.process_status = wip_constants.error
                        where wsti.header_id = p_header_id
                        and wsti.transaction_type_id = 2
                        and wsti.action_flag in (5,6)
                        and not exists( SELECT MSN.serial_number
                                        FROM  MTL_SERIAL_NUMBERS MSN
                                        WHERE MSN.SERIAL_NUMBER                      = wsti.serial_number
                                        AND   MSN.wip_entity_id                      = p_wip_entity_id
                                        AND   MSN.current_organization_id            = p_organization_id
                                        AND   MSN.inventory_item_id                  = p_inventory_item_id
                                        -- AND   MSN.current_status                  = WIP_CONSTANTS.IN_STORES
                                        -- AND   MSN.operation_seq_num                  = p_curr_job_op_seq_num
                                        --AND   MSN.intraoperation_step_type         = p_curr_job_intraop_step
                                        AND    nvl(MSN.intraoperation_step_type,-1)  <> WIP_CONSTANTS.SCRAP
                                       );

                        if SQL%ROWCOUNT > 0 then
                                -- Error out..
                                l_stmt_num := 100;
                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_SERIALS_SUPPLIED',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        end if;

                        l_stmt_num := 110;
                        open c_move_serials;
                        fetch c_move_serials
                        bulk collect into  l_wsm_serial_nums_tbl;
                        close c_move_serials;
                ELSE
                        l_wsm_serial_nums_tbl := p_wsm_serial_nums_tbl;
                END IF;
                l_stmt_num := 120;
        END IF;

        l_stmt_num := 130;
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Invoking Move_serial_processor',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;
        -- then call the Move Serial Processor..
        Move_serial_processor (   p_calling_mode                => 1                            ,
                                  p_serial_num_tbl              => l_wsm_serial_nums_tbl        ,
                                  p_move_txn_type               => p_move_txn_type              ,
                                  p_wip_entity_id               => p_wip_entity_id              ,
                                  p_organization_id             => p_organization_id            ,
                                  p_inventory_item_id           => p_inventory_item_id          ,
                                  p_move_qty                    => p_move_qty                   ,
                                  p_scrap_qty                   => p_scrap_qty                  ,
                                  p_available_qty               => p_available_qty              ,
                                  p_curr_job_op_seq_num         => p_curr_job_op_seq_num        ,
                                  p_curr_job_intraop_step       => p_curr_job_intraop_step      ,
                                  p_job_serial_start_op         => l_serial_start_op            ,
                                  p_from_rtg_op_seq_num         => p_from_rtg_op_seq_num        ,
                                  p_to_rtg_op_seq_num           => p_to_rtg_op_seq_num          ,
                                  p_to_intraoperation_step      => p_to_intraoperation_step     ,
                                  p_user_serial_tracking        => p_user_serial_tracking       ,
                                  p_move_txn_id                 => p_move_txn_id                ,
                                  p_scrap_txn_id                => p_scrap_txn_id               ,
                                  p_old_move_txn_id             => p_old_move_txn_id            ,
                                  p_old_scrap_txn_id            => p_old_scrap_txn_id           ,
                                  p_jump_flag                   => p_jump_flag                  ,
                                  p_scrap_at_operation          => p_scrap_at_operation         ,
                                  -- ST : Fix for bug 5140761 Addded the above parameter --
                                  x_serial_track_flag           => x_serial_track_flag          ,
                                  x_return_status               => x_return_status              ,
                                  x_error_msg                   => x_error_msg                  ,
                                  x_error_count                 => x_error_count
                              );

        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Move_serial_intf_proc Sucess',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
END Move_serial_intf_proc;

-- Expected i/p is the header id of the Move Transaction...
Procedure Move_serial_processor ( p_calling_mode                IN              NUMBER,
                                  p_serial_num_tbl              IN              WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                  p_move_txn_type               IN              NUMBER,
                                  p_wip_entity_id               IN              NUMBER,
                                  p_organization_id             IN              NUMBER,
                                  p_inventory_item_id           IN              NUMBER,
                                  p_move_qty                    IN              NUMBER,
                                  p_scrap_qty                   IN              NUMBER,
                                  p_available_qty               IN              NUMBER,
                                  p_curr_job_op_seq_num         IN              NUMBER,
                                  p_curr_job_intraop_step       IN              NUMBER,
                                  p_from_rtg_op_seq_num         IN              NUMBER,
                                  p_to_rtg_op_seq_num           IN              NUMBER,
                                  p_to_intraoperation_step      IN              NUMBER,
                                  p_job_serial_start_op         IN              NUMBER,
                                  p_user_serial_tracking        IN              NUMBER,
                                  p_move_txn_id                 IN              NUMBER,
                                  p_scrap_txn_id                IN              NUMBER,
                                  p_old_move_txn_id             IN              NUMBER,
                                  p_old_scrap_txn_id            IN              NUMBER,
                                  p_jump_flag                   IN              varchar2   DEFAULT  NULL,
                                  p_scrap_at_operation          IN              NUMBER     DEFAULT  NULL,
                                  -- ST : Fix for bug 5140761 Addded the above parameter --
                                  x_serial_track_flag           IN  OUT NOCOPY  NUMBER,
                                  x_return_status               OUT NOCOPY      VARCHAR2,
                                  x_error_msg                   OUT NOCOPY      VARCHAR2,
                                  x_error_count                 OUT NOCOPY      NUMBER
                                )

IS

l_old_serial_track_flag NUMBER;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.Move_serial_processor';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
        SAVEPOINT Move_serial_proc;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        l_stmt_num := 10;
        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_calling_mode';
                l_param_tbl(1).paramValue := p_calling_mode;

                l_param_tbl(2).paramName := 'p_organization_id';
                l_param_tbl(2).paramValue := p_organization_id;

                l_param_tbl(3).paramName := 'p_wip_entity_id';
                l_param_tbl(3).paramValue := p_wip_entity_id;

                l_param_tbl(4).paramName := 'p_serial_num_tbl.count';
                l_param_tbl(4).paramValue := p_serial_num_tbl.count;

                l_param_tbl(5).paramName := 'p_move_txn_type';
                l_param_tbl(5).paramValue := p_move_txn_type;

                l_param_tbl(6).paramName := 'p_scrap_at_operation';
                l_param_tbl(6).paramValue := p_scrap_at_operation;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_stmt_num := 15;
                -- Procedure to dump the serial records' data....
                log_serial_data ( p_serial_num_tbl    => p_serial_num_tbl       ,
                                  x_return_status     => x_return_status        ,
                                  x_error_msg         => x_error_msg            ,
                                  x_error_count       => x_error_count
                                );
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        END IF;

        -- check the qty...
        if p_move_txn_type in (1,2) then

                l_stmt_num := 20;
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking WSM_SERIAL_SUPPORT_PVT.check_move_serial_qty',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                l_old_serial_track_flag := x_serial_track_flag;

                -- invoke check_move_txn_qty
                check_move_serial_qty  ( p_calling_mode           => p_calling_mode             ,
                                         p_serial_num_tbl         => p_serial_num_tbl           ,
                                         p_move_txn_type          => p_move_txn_type            ,
                                         p_wip_entity_id          => p_wip_entity_id            ,
                                         p_inventory_item_id      => p_inventory_item_id        ,
                                         p_organization_id        => p_organization_id          ,
                                         p_move_qty               => p_move_qty                 ,
                                         p_scrap_qty              => p_scrap_qty                ,
                                         p_available_qty          => p_available_qty            ,
                                         p_curr_job_op_seq_num    => p_curr_job_op_seq_num      ,
                                         p_curr_job_intraop_step  => p_curr_job_intraop_step    ,
                                         p_job_serial_start_op    => p_job_serial_start_op      ,
                                         p_from_rtg_op_seq_num    => p_from_rtg_op_seq_num      ,
                                         p_to_rtg_op_seq_num      => p_to_rtg_op_seq_num        ,
                                         p_to_intraoperation_step => p_to_intraoperation_step   ,
                                         p_user_serial_tracking   => p_user_serial_tracking     ,
                                         p_move_txn_id            => p_move_txn_id              ,
                                         p_scrap_txn_id           => p_scrap_txn_id             ,
                                         p_jump_flag              => p_jump_flag                ,
                                         p_scrap_at_operation     => p_scrap_at_operation       ,
                                         -- ST : Fix for bug 5140761 Addded the above parameter --
                                         x_serial_track_flag      => x_serial_track_flag        ,
                                         x_return_status          => x_return_status            ,
                                         x_error_msg              => x_error_msg                ,
                                         x_error_count            => x_error_count
                                      );

                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;

                l_stmt_num := 30;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Value of x_serial_track_flag : ' || x_serial_track_flag,
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                -- if serialization begun at this move transaction update the field in  WSM_LOT_BASED_JOBS, WIP_DISCRETE_JOBS
                IF l_old_serial_track_flag IS NULL and x_serial_track_flag IS NOT NULL
                THEN

                        l_stmt_num := 40;
                        -- Update WDJ also...
                        UPDATE WSM_LOT_BASED_JOBS
                        SET first_serial_txn_id = p_move_txn_id
                        WHERE wip_entity_id = p_wip_entity_id;

                        l_stmt_num := 50;
                        UPDATE WIP_DISCRETE_JOBS
                        SET serialization_start_op = 10
                        WHERE wip_entity_id = p_wip_entity_id;

                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Updated WIP_DISCRETE_JOBS to set the serialization_start_op',
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;

                END IF;

        else  -- Undo/Assembly return
                -- invoke populate_undo_serial_nums
                l_stmt_num := 60;

                IF x_serial_track_flag IS NOT NULL THEN

                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Invoking WSM_Serial_support_PVT.populate_undo_txn',
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;

                        populate_undo_txn (  p_move_txn_type            => p_move_txn_type              ,
                                             p_wip_entity_id            => p_wip_entity_id              ,
                                             p_inventory_item_id        => p_inventory_item_id          ,
                                             p_organization_id          => p_organization_id            ,
                                             p_move_qty                 => p_move_qty                   ,
                                             p_scrap_qty                => p_scrap_qty                  ,
                                             p_new_move_txn_id          => p_move_txn_id                ,
                                             p_new_scrap_txn_id         => p_scrap_txn_id               ,
                                             p_old_move_txn_id          => p_old_move_txn_id            ,
                                             p_old_scrap_txn_id         => p_old_scrap_txn_id           ,
                                             x_return_status            => x_return_status              ,
                                             x_error_msg                => x_error_msg                  ,
                                             x_error_count              => x_error_count
                                          );

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;

                        -- if the old txn_id = first serial move transaction id, then clear the fields in
                        -- WSM_LOT_BASED_JOBS
                        l_stmt_num := 70;

                        -- The field in WDJ can be cleared only after the Txn is successful...
                        UPDATE WSM_LOT_BASED_JOBS
                        set    first_serial_txn_id = null
                        WHERE  wip_entity_id = p_wip_entity_id
                        AND    first_serial_txn_id = p_old_move_txn_id;

                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Updated ' || SQL%ROWCOUNT || ' records in WSM_LOT_BASED_JOBS',
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;
                END IF;
        end if;
EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK to Move_serial_proc;
                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK to Move_serial_proc;
                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN
                 ROLLBACK to Move_serial_proc;
                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
END Move_serial_processor;


-- check the move qty and ensure that serial no.s are inserted if inadequate...
Procedure check_move_serial_qty( p_calling_mode           IN                     NUMBER,
                                 p_serial_num_tbl         IN                     WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                 p_move_txn_type          IN                     NUMBER,
                                 p_wip_entity_id          IN                     NUMBER,
                                 p_inventory_item_id      IN                     NUMBER,
                                 p_organization_id        IN                     NUMBER,
                                 p_move_qty               IN                     NUMBER,
                                 p_scrap_qty              IN                     NUMBER,
                                 p_available_qty          IN                     NUMBER,
                                 p_curr_job_op_seq_num    IN                     NUMBER,
                                 p_curr_job_intraop_step  IN                     NUMBER,
                                 p_job_serial_start_op    IN                     NUMBER,
                                 p_from_rtg_op_seq_num    IN                     NUMBER,
                                 p_to_rtg_op_seq_num      IN                     NUMBER,
                                 p_to_intraoperation_step IN                     NUMBER,
                                 p_user_serial_tracking   IN                     NUMBER,
                                 p_move_txn_id            IN                     NUMBER,
                                 p_scrap_txn_id           IN                     NUMBER,
                                 p_jump_flag              IN                     varchar2   DEFAULT  NULL,
                                 p_scrap_at_operation           IN              NUMBER     DEFAULT  NULL,
                                 -- ST : Fix for bug 5140761 Addded the above parameter --
                                 x_serial_track_flag      IN OUT NOCOPY          NUMBER,
                                 x_return_status          OUT NOCOPY             VARCHAR2,
                                 x_error_msg              OUT NOCOPY             VARCHAR2,
                                 x_error_count            OUT NOCOPY             NUMBER
                                )
IS

type t_serial_tbl is table of number index by mtl_serial_numbers.serial_number%type;

l_move_serial_qty       NUMBER;
l_scrap_serial_qty      NUMBER;

l_index                 NUMBER;
l_return_status         NUMBER;
l_error_count           NUMBER;
l_error_msg             VARCHAR2(2000);
l_count                 NUMBER;
l_cntr                  NUMBER;

l_update_serial_attr    NUMBER;
l_context_value         MTL_SERIAL_NUMBERS.serial_attribute_category%type;

l_wip_serial_nums_tbl   t_wip_intf_tbl_type;
l_serial_list           t_serial_tbl;

l_old_serial_track_status   NUMBER;
l_job_serial_count          NUMBER;
l_gen_object_id             NUMBER;

CURSOR c_job_serials is SELECT serial_number
                        FROM   mtl_serial_numbers msn
                        where  msn.inventory_item_id = p_inventory_item_id
                        and    msn.current_organization_id = p_organization_id
                        and    msn.wip_entity_id = p_wip_entity_id;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.check_move_serial_qty';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

l_charge_jump_from_queue        NUMBER;

BEGIN
        l_stmt_num := 10;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_available_qty';
                l_param_tbl(1).paramValue := p_available_qty;

                l_param_tbl(2).paramName := 'p_move_qty';
                l_param_tbl(2).paramValue := p_move_qty;

                l_param_tbl(3).paramName := 'p_to_rtg_op_seq_num';
                l_param_tbl(3).paramValue := p_to_rtg_op_seq_num;

                l_param_tbl(4).paramName := 'p_from_rtg_op_seq_num';
                l_param_tbl(4).paramValue := p_from_rtg_op_seq_num;

                l_param_tbl(5).paramName := 'p_job_serial_start_op';
                l_param_tbl(5).paramValue := p_job_serial_start_op;

                l_param_tbl(6).paramName := 'p_serial_num_tbl (count)';
                l_param_tbl(6).paramValue := p_serial_num_tbl.count;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        l_old_serial_track_status := x_serial_track_flag;

        -- first check for serialization start op...
        if  x_serial_track_flag IS NULL then

                l_stmt_num := 20;
                -- Indicates serial tracking hasnot yet begun
                If p_user_serial_tracking  IS NULL then
                        l_stmt_num := 30;

                        IF p_jump_flag IS NOT NULL THEN
                                select charge_jump_from_queue
                                into   l_charge_jump_from_queue
                                from   wsm_parameters
                                where  organization_id = p_organization_id;
                        END IF;
                        --The user also doesn't want to start serial tracking..
                        -- But if the below conditions satisfy then serial tracking will begin...
                        -- i) To operation is the serial start op and the to intraop step <> QUEUE
                        -- ii) To operation is the serial start op and the intraop atep = queue and scrap qty > 0 and scrap is at to operation
                        -- iii) Completion txn
                        -- iv) From operation is the serial start op and is a jump op and charge current op during jump is Yes
                        If ( p_to_rtg_op_seq_num = p_job_serial_start_op
                             AND
                             (p_to_intraoperation_step <> WIP_CONSTANTS.QUEUE OR
                              (nvl(p_scrap_qty,0) <> 0 AND nvl(p_scrap_at_operation,1) = 2)
                              -- ST : Fix for bug 5140761 Added the above clause --
                             )
                           )
                             OR
                           (p_from_rtg_op_seq_num =  p_job_serial_start_op and NOT(nvl(p_jump_flag,'N') = 'Y' and l_charge_jump_from_queue <> 1))
                             OR
                           (p_move_txn_type = 2)
                           --and p_job_serial_start_op is not Null
                           --IF the move txn type is completion we enforce...
                        THEN
                                l_stmt_num := 40;
                                x_serial_track_flag := 1;
                        end if;
                else
                        -- The User intends to start...
                        x_serial_track_flag := 1;
                end if;
        end if;

        l_stmt_num := 50;
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Serial Tracking for the Job : ' || x_serial_track_flag,
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        -- check for non-needed serial info...
        if x_serial_track_flag IS NULL and p_serial_num_tbl.count>0 then
                -- Set return status to error and return.. we don't expect records
                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_INFO_NOT_TRACKED',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;

        End if;


        l_stmt_num := 60;
        -- get the count of serial numbers present
        SELECT count(*)
        INTO  l_job_serial_count
        FROM  mtl_serial_numbers MSN
        where MSN.wip_entity_id = p_wip_entity_id
        AND   MSN.current_organization_id            = p_organization_id
        AND   MSN.inventory_item_id                  = p_inventory_item_id
        AND   nvl(MSN.intraoperation_step_type,-1)  <> WIP_CONSTANTS.SCRAP;

        -- ST : Fix for bug 5190943 : Added the validation --
        -- Now validate the qty for a non-serial traked job
        IF x_serial_track_flag IS NULL THEN
                -- Validate...
                IF l_job_serial_count > (p_available_qty - p_scrap_qty) THEN
                        -- error out in this case...
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN
                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'JOB';

                                select wip_entity_name
                                into   l_msg_tokens(1).TokenValue
                                from   wip_entities
                                where  wip_entity_id = p_wip_entity_id
                                and    organization_id = p_organization_id;

                                WSM_log_PVT.logMessage(p_module_name        => l_module                   ,
                                                       p_msg_name           => 'WSM_PARTIAL_EXCESS_SERIAL',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                -- return...
                RETURN;
        END IF;

        IF l_job_serial_count <> p_available_qty THEN

                -- Not enough data to start serial tracking...
                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_NO_START_SERTRACK'  ,
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Now get the count of the serial numbers being moved....
        l_move_serial_qty := 0;
        l_scrap_serial_qty := 0;

        l_cntr := p_serial_num_tbl.first;

        while (l_cntr is not null) loop

                if l_serial_list.exists(p_serial_num_tbl(l_cntr).serial_number) then
                        -- error out...
                        -- Duplicate entry...
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN
                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName  := 'SERIAL';
                                l_msg_tokens(1).TokenValue := p_serial_num_tbl(l_cntr).serial_number;

                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_DUPLICATE_TXN_SERIAL',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                if p_serial_num_tbl(l_cntr).action_flag = 5 then
                        l_move_serial_qty := l_move_serial_qty + 1;
                else
                        l_scrap_serial_qty := l_scrap_serial_qty + 1;
                end if;

                l_serial_list(p_serial_num_tbl(l_cntr).serial_number) := 1;
                l_cntr := p_serial_num_tbl.next(l_cntr);

        end loop;

        l_serial_list.delete;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'User provided serials to be moved : ' || l_move_serial_qty || ' : Serials to be scrapped : ' || l_scrap_serial_qty,
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;
        l_stmt_num := 70;
        -- validations...
        IF p_move_qty <> 0 AND p_scrap_qty <> 0 THEN
                -- Move and scrap transaction...
                -- move and scrap txn..
                -- User has to provide either the move qty or scrap qty in full..
                l_stmt_num := 80;
                if l_move_serial_qty <> p_move_qty and l_scrap_serial_qty <> p_scrap_qty then
                        -- error out...
                        -- insufficient info...
                        l_stmt_num := 90;

                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_SUPPLIED_QTY_INVALID',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;

                elsif (l_move_serial_qty = p_move_qty) THEN
                        -- -- all the move serial numbers provided...
                        l_count := 0;
                        l_stmt_num := 100;
                        -- loop theough p_serial_num_tbl and load the local PL/SQl table...
                        for l_serial_counter in p_serial_num_tbl.first..p_serial_num_tbl.last loop

                                l_count := l_count + 1;

                                IF p_serial_num_tbl(l_serial_counter).action_flag = 5 THEN
                                        l_wip_serial_nums_tbl(l_count).TRANSACTION_ID := p_move_txn_id;
                                ELSE
                                        l_wip_serial_nums_tbl(l_count).TRANSACTION_ID := p_scrap_txn_id;
                                END IF;

                                l_wip_serial_nums_tbl(l_count).ASSEMBLY_SERIAL_NUMBER    := p_serial_num_tbl(l_count).serial_number;
                                -- (Gen_object_id --> assembly_item_id No longer used Instead the column will have gen_object_id)
                                -- Column not renamed due to
                                -- i) MES depency through the record defined in the WSM_SERIAL_SUPPORT_GRP package
                                -- ii) The column is not exposed to the user .. It is an internal column
                                l_gen_object_id := p_serial_num_tbl(l_count).assembly_item_id;
                                IF l_gen_object_id IS NULL THEN
                                        -- could be NULL when passed from MES..
                                        select gen_object_id
                                        into   l_gen_object_id
                                        from   mtl_serial_numbers
                                        where  serial_number = p_serial_num_tbl(l_count).serial_number
                                        and    inventory_item_id = p_inventory_item_id
                                        and    current_organization_id   = p_organization_id;
                                END IF;

                                l_wip_serial_nums_tbl(l_count).gen_object_id             := l_gen_object_id;
                                l_wip_serial_nums_tbl(l_count).CREATION_DATE             := sysdate;
                                l_wip_serial_nums_tbl(l_count).CREATED_BY                := g_user_id;
                                l_wip_serial_nums_tbl(l_count).CREATED_BY_NAME           := g_user_name;
                                l_wip_serial_nums_tbl(l_count).LAST_UPDATE_DATE          := sysdate;
                                l_wip_serial_nums_tbl(l_count).LAST_UPDATED_BY           := g_user_id;
                                l_wip_serial_nums_tbl(l_count).LAST_UPDATED_BY_NAME      := g_user_name;
                                l_wip_serial_nums_tbl(l_count).LAST_UPDATE_LOGIN         := g_user_login_id;
                                l_wip_serial_nums_tbl(l_count).REQUEST_ID                := g_request_id;
                                l_wip_serial_nums_tbl(l_count).PROGRAM_APPLICATION_ID    := g_program_appl_id;
                                l_wip_serial_nums_tbl(l_count).PROGRAM_ID                := g_program_id;
                                l_wip_serial_nums_tbl(l_count).PROGRAM_UPDATE_DATE       := sysdate;
                        end loop;

                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Going to Insert ' || l_count || ' user provided records into wip_serial_move_interface for move and scrap',
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;

                        l_stmt_num := 110;
                        -- do a bulk insert...
                        forall l_cntr in l_wip_serial_nums_tbl.first..l_wip_serial_nums_tbl.last
                                insert into wip_serial_move_interface values l_wip_serial_nums_tbl(l_cntr);

                        l_stmt_num := 120;
                        IF l_move_serial_qty + l_scrap_serial_qty <> p_available_qty THEN

                                l_stmt_num := 130;
                                -- Now insert the left over serial numbers for scrap..
                                -- insert the remaining records as scrap records....
                                INSERT INTO WIP_SERIAL_MOVE_INTERFACE
                                (        TRANSACTION_ID,
                                         ASSEMBLY_SERIAL_NUMBER,
                                         GEN_OBJECT_ID,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATED_BY_NAME,
                                         CREATION_DATE,
                                         CREATED_BY,
                                         CREATED_BY_NAME,
                                         LAST_UPDATE_LOGIN,
                                         REQUEST_ID,
                                         PROGRAM_APPLICATION_ID,
                                         PROGRAM_ID,
                                         PROGRAM_UPDATE_DATE
                                )
                                (
                                SELECT
                                         p_scrap_txn_id,
                                         SERIAL_NUMBER,
                                         gen_object_id,
                                         sysdate,
                                         g_user_id,
                                         g_user_name,
                                         sysdate,
                                         g_user_id,
                                         g_user_name,
                                         g_user_login_id,
                                         g_request_id,
                                         g_program_appl_id,
                                         g_program_id,
                                         sysdate
                                FROM  MTL_SERIAL_NUMBERS MSN
                                WHERE MSN.wip_entity_id = p_wip_entity_id
                                AND   MSN.current_organization_id            = p_organization_id
                                AND   MSN.inventory_item_id                  = p_inventory_item_id
                                -- AND   MSN.current_status                  = WIP_CONSTANTS.IN_STORES
                                -- AND   MSN.operation_seq_num               = p_curr_job_op_seq_num
                                AND    nvl(MSN.intraoperation_step_type,-1)  <> WIP_CONSTANTS.SCRAP
                                AND   NOT EXISTS (select 'Serial Already inserted for move'
                                                   from   WIP_SERIAL_MOVE_INTERFACE
                                                   where  TRANSACTION_ID = p_move_txn_id
                                                   AND    ASSEMBLY_SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                  )
                                AND   NOT EXISTS (select 'Serial Already inserted for scrap'
                                                   from   WIP_SERIAL_MOVE_INTERFACE
                                                   where  TRANSACTION_ID = p_scrap_txn_id
                                                   AND    ASSEMBLY_SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                  )
                                );

                                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                                p_msg_text          => 'Inserted  ' || SQL%ROWCOUNT || ' records into wip_serial_move_interface for scrap',
                                                                p_stmt_num          => l_stmt_num               ,
                                                                p_msg_tokens        => l_msg_tokens             ,
                                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                p_run_log_level     => l_log_level
                                                                );
                                END IF;

                                l_stmt_num := 140;
                        END IF;

                elsif l_scrap_serial_qty = p_scrap_qty then  -- -- all the scrap serial numbers provided...
                        -- loop theough p_serial_num_tbl and load the local PL/SQl table...
                        l_count := 0;
                        l_stmt_num := 150;
                        -- loop theough p_serial_num_tbl and load the local PL/SQl table...
                        for l_serial_counter in p_serial_num_tbl.first..p_serial_num_tbl.last loop

                                l_count := l_count + 1;

                                IF p_serial_num_tbl(l_serial_counter).action_flag = 5 THEN
                                        l_wip_serial_nums_tbl(l_count).TRANSACTION_ID := p_move_txn_id;
                                ELSE
                                        l_wip_serial_nums_tbl(l_count).TRANSACTION_ID := p_scrap_txn_id;
                                END IF;

                                l_wip_serial_nums_tbl(l_count).ASSEMBLY_SERIAL_NUMBER    := p_serial_num_tbl(l_count).serial_number;
                                -- (Gen_object_id --> assembly_item_id No longer used Instead the column will have gen_object_id)
                                -- Column not renamed due to
                                -- i) MES depency through the record defined in the WSM_SERIAL_SUPPORT_GRP package
                                -- ii) The column is not exposed to the user .. It is an internal column
                                l_gen_object_id := p_serial_num_tbl(l_count).assembly_item_id;
                                IF l_gen_object_id IS NULL THEN
                                        -- could be NULL when passed from MES..
                                        select gen_object_id
                                        into   l_gen_object_id
                                        from   mtl_serial_numbers
                                        where  serial_number = p_serial_num_tbl(l_count).serial_number
                                        and    inventory_item_id = p_inventory_item_id
                                        and    current_organization_id   = p_organization_id;
                                END IF;

                                l_wip_serial_nums_tbl(l_count).gen_object_id             := l_gen_object_id;
                                l_wip_serial_nums_tbl(l_count).CREATION_DATE             := sysdate;
                                l_wip_serial_nums_tbl(l_count).CREATED_BY                := g_user_id;
                                l_wip_serial_nums_tbl(l_count).CREATED_BY_NAME           := g_user_name;
                                l_wip_serial_nums_tbl(l_count).LAST_UPDATE_DATE          := sysdate;
                                l_wip_serial_nums_tbl(l_count).LAST_UPDATED_BY           := g_user_id;
                                l_wip_serial_nums_tbl(l_count).LAST_UPDATED_BY_NAME      := g_user_name;
                                l_wip_serial_nums_tbl(l_count).LAST_UPDATE_LOGIN         := g_user_login_id;
                                l_wip_serial_nums_tbl(l_count).REQUEST_ID                := g_request_id;
                                l_wip_serial_nums_tbl(l_count).PROGRAM_APPLICATION_ID    := g_program_appl_id;
                                l_wip_serial_nums_tbl(l_count).PROGRAM_ID                := g_program_id;
                                l_wip_serial_nums_tbl(l_count).PROGRAM_UPDATE_DATE       := sysdate;
                        end loop;

                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Going to Insert ' || l_count || ' user provided records into wip_serial_move_interface for move and scrap',
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;

                        l_stmt_num := 160;
                        -- do a bulk insert...
                        forall l_cntr in l_wip_serial_nums_tbl.first..l_wip_serial_nums_tbl.last
                                insert into wip_serial_move_interface values l_wip_serial_nums_tbl(l_cntr);

                        l_stmt_num := 170;
                        IF l_move_serial_qty + l_scrap_serial_qty <> p_available_qty THEN

                                l_stmt_num := 180;
                                -- Now insert the left over serial numbers for scrap..
                                -- insert the remaining records as scrap records....
                                INSERT INTO WIP_SERIAL_MOVE_INTERFACE
                                (        TRANSACTION_ID,
                                         ASSEMBLY_SERIAL_NUMBER,
                                         gen_object_id,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATED_BY_NAME,
                                         CREATION_DATE,
                                         CREATED_BY,
                                         CREATED_BY_NAME,
                                         LAST_UPDATE_LOGIN,
                                         REQUEST_ID,
                                         PROGRAM_APPLICATION_ID,
                                         PROGRAM_ID,
                                         PROGRAM_UPDATE_DATE
                                )
                                (
                                SELECT
                                         p_move_txn_id,
                                         SERIAL_NUMBER,
                                         gen_object_id,
                                         sysdate,
                                         g_user_id,
                                         g_user_name,
                                         sysdate,
                                         g_user_id,
                                         g_user_name,
                                         g_user_login_id,
                                         g_request_id,
                                         g_program_appl_id,
                                         g_program_id,
                                         sysdate
                                FROM  MTL_SERIAL_NUMBERS MSN
                                WHERE MSN.wip_entity_id = p_wip_entity_id
                                AND   MSN.current_organization_id            = p_organization_id
                                AND   MSN.inventory_item_id                  = p_inventory_item_id
                                -- AND   MSN.current_status                  = WIP_CONSTANTS.IN_STORES
                                -- AND   MSN.operation_seq_num               = p_curr_job_op_seq_num
                                AND    nvl(MSN.intraoperation_step_type,-1)  <> WIP_CONSTANTS.SCRAP
                                AND   NOT EXISTS (select 'Serial Already inserted for move'
                                                   from   WIP_SERIAL_MOVE_INTERFACE
                                                   where  TRANSACTION_ID = p_move_txn_id
                                                   AND    ASSEMBLY_SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                  )
                                AND   NOT EXISTS (select 'Serial Already inserted for scrap'
                                                   from   WIP_SERIAL_MOVE_INTERFACE
                                                   where  TRANSACTION_ID = p_scrap_txn_id
                                                   AND    ASSEMBLY_SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                  )
                                );

                                l_stmt_num := 190;
                                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                                p_msg_text          => 'Inserted  ' || SQL%ROWCOUNT || ' records into wip_serial_move_interface for Move',
                                                                p_stmt_num          => l_stmt_num               ,
                                                                p_msg_tokens        => l_msg_tokens             ,
                                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                p_run_log_level     => l_log_level
                                                                );
                                END IF;

                        END IF;
                end if;

        ELSE

                IF p_move_qty = p_available_qty THEN

                        l_stmt_num := 200;
                        -- Move Quantity is equal to the available qty...
                        -- Insert all the serial numbers linked to the job...
                        INSERT INTO WIP_SERIAL_MOVE_INTERFACE
                        (        TRANSACTION_ID,
                                 ASSEMBLY_SERIAL_NUMBER,
                                 gen_object_id,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATED_BY_NAME,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 CREATED_BY_NAME,
                                 LAST_UPDATE_LOGIN,
                                 REQUEST_ID,
                                 PROGRAM_APPLICATION_ID,
                                 PROGRAM_ID,
                                 PROGRAM_UPDATE_DATE
                        )
                        (
                        SELECT
                                 p_move_txn_id,
                                 SERIAL_NUMBER,
                                 gen_object_id,
                                 sysdate,
                                 g_user_id,
                                 g_user_name,
                                 sysdate,
                                 g_user_id,
                                 g_user_name,
                                 g_user_login_id,
                                 g_request_id,
                                 g_program_appl_id,
                                 g_program_id,
                                 sysdate
                        FROM  MTL_SERIAL_NUMBERS MSN
                        WHERE MSN.wip_entity_id = p_wip_entity_id
                        AND   MSN.current_organization_id            = p_organization_id
                        AND   MSN.inventory_item_id                  = p_inventory_item_id
                        -- AND   MSN.current_status                  = WIP_CONSTANTS.IN_STORES
                        -- AND   MSN.operation_seq_num               = p_curr_job_op_seq_num
                        AND    nvl(MSN.intraoperation_step_type,-1)  <> WIP_CONSTANTS.SCRAP
                        );

                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Inserted ' || SQL%ROWCOUNT || ' records into WIP_SERIAL_MOVE_INTERFACE to be moved',
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;

                        l_stmt_num := 210;
                ELSIF p_scrap_qty = p_available_qty THEN

                        l_stmt_num := 220;
                        --  Scrap Quantity is equal to the available qty...
                        -- Insert all the serial numbers linked to the job...
                        INSERT INTO WIP_SERIAL_MOVE_INTERFACE
                        (        TRANSACTION_ID,
                                 ASSEMBLY_SERIAL_NUMBER,
                                 gen_object_id,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATED_BY_NAME,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 CREATED_BY_NAME,
                                 LAST_UPDATE_LOGIN,
                                 REQUEST_ID,
                                 PROGRAM_APPLICATION_ID,
                                 PROGRAM_ID,
                                 PROGRAM_UPDATE_DATE
                        )
                        (
                        SELECT
                                 p_scrap_txn_id,
                                 SERIAL_NUMBER,
                                 gen_object_id,
                                 sysdate,
                                 g_user_id,
                                 g_user_name,
                                 sysdate,
                                 g_user_id,
                                 g_user_name,
                                 g_user_login_id,
                                 g_request_id,
                                 g_program_appl_id,
                                 g_program_id,
                                 sysdate
                        FROM  MTL_SERIAL_NUMBERS MSN
                        WHERE MSN.wip_entity_id = p_wip_entity_id
                        AND   MSN.current_organization_id            = p_organization_id
                        AND   MSN.inventory_item_id                  = p_inventory_item_id
                        -- AND   MSN.current_status                  = WIP_CONSTANTS.IN_STORES
                        -- AND   MSN.operation_seq_num               = p_curr_job_op_seq_num
                        AND    nvl(MSN.intraoperation_step_type,-1)  <> WIP_CONSTANTS.SCRAP
                        );

                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Inserted ' || SQL%ROWCOUNT || ' records into WIP_SERIAL_MOVE_INTERFACE to be scrapped',
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;

                        l_stmt_num := 230;
                ELSE
                        l_stmt_num := 240;
                        -- Partial Scrap txn...
                        --  scrap txn but not all the qty
                        if p_scrap_qty <> l_scrap_serial_qty then
                                -- error out. Insufficient info..
                                l_stmt_num := 250;
                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_SUPPLIED_QTY_INVALID',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        end if;

                        l_stmt_num := 260;
                        -- loop theough p_serial_num_tbl and load the local PL/SQl table...
                        l_count := 0;

                        l_index := p_serial_num_tbl.first;
                        -- loop theough p_serial_num_tbl and load the local PL/SQl table...
                        while l_index is not null loop

                                l_count := l_count + 1;

                                l_wip_serial_nums_tbl(l_count).TRANSACTION_ID            := p_scrap_txn_id;
                                l_wip_serial_nums_tbl(l_count).ASSEMBLY_SERIAL_NUMBER    := p_serial_num_tbl(l_count).serial_number;
                                -- (Gen_object_id --> assembly_item_id No longer used Instead the column will have gen_object_id)
                                -- Column not renamed due to
                                -- i) MES depency through the record defined in the WSM_SERIAL_SUPPORT_GRP package
                                -- ii) The column is not exposed to the user .. It is an internal column
                                l_gen_object_id := p_serial_num_tbl(l_count).assembly_item_id;
                                IF l_gen_object_id IS NULL THEN
                                        -- could be NULL when passed from MES..
                                        select gen_object_id
                                        into   l_gen_object_id
                                        from   mtl_serial_numbers
                                        where  serial_number = p_serial_num_tbl(l_count).serial_number
                                        and    inventory_item_id = p_inventory_item_id
                                        and    current_organization_id   = p_organization_id;
                                END IF;

                                l_wip_serial_nums_tbl(l_count).gen_object_id             := l_gen_object_id;
                                l_wip_serial_nums_tbl(l_count).CREATION_DATE             := sysdate;
                                l_wip_serial_nums_tbl(l_count).CREATED_BY                := g_user_id;
                                l_wip_serial_nums_tbl(l_count).CREATED_BY_NAME           := g_user_name;
                                l_wip_serial_nums_tbl(l_count).LAST_UPDATE_DATE          := sysdate;
                                l_wip_serial_nums_tbl(l_count).LAST_UPDATED_BY           := g_user_id;
                                l_wip_serial_nums_tbl(l_count).LAST_UPDATED_BY_NAME      := g_user_name;
                                l_wip_serial_nums_tbl(l_count).LAST_UPDATE_LOGIN         := g_user_login_id;
                                l_wip_serial_nums_tbl(l_count).REQUEST_ID                := g_request_id;
                                l_wip_serial_nums_tbl(l_count).PROGRAM_APPLICATION_ID    := g_program_appl_id;
                                l_wip_serial_nums_tbl(l_count).PROGRAM_ID                := g_program_id;
                                l_wip_serial_nums_tbl(l_count).PROGRAM_UPDATE_DATE       := sysdate;

                                l_index := p_serial_num_tbl.next(l_index);
                        end loop;

                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Going to insert ' || l_wip_serial_nums_tbl.count || ' records into WIP_SERIAL_MOVE_INTERFACE to be scrapped',
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;

                        l_stmt_num := 270;
                        -- do a bulk insert...
                        forall l_cntr in l_wip_serial_nums_tbl.first..l_wip_serial_nums_tbl.last
                                insert into wip_serial_move_interface values l_wip_serial_nums_tbl(l_cntr);

                        l_stmt_num := 280;
                END IF;
        END IF;

        l_stmt_num := 290;
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Serial Attributes updation start',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        l_cntr := p_serial_num_tbl.first;
        while l_cntr is not null loop

                l_stmt_num := 300;
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking update_serial_attr(1) for ' ||
                                                                       'Serial Attributes updation for serial number '  ||
                                                                       p_serial_num_tbl(l_cntr).serial_number,
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                update_serial_attr (   p_calling_mode           => p_calling_mode,
                                       p_serial_number_rec      => p_serial_num_tbl(l_cntr),
                                       p_inventory_item_id      => p_inventory_item_id,
                                       p_organization_id        => p_organization_id  ,
                                       p_clear_serial_attr      => null,
                                       p_wlt_txn_type           => null,
                                       p_update_serial_attr     => null,
                                       p_update_desc_attr       => 1,
                                       x_return_status          => x_return_status,
                                       x_error_count            => x_error_count,
                                       x_error_msg              => x_error_msg
                                  );

                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;

                l_stmt_num := 310;
                l_cntr := p_serial_num_tbl.next(l_cntr);

        end loop;

        l_stmt_num := 320;
        IF l_old_serial_track_status IS NULL THEN
                -- Indicates that this is the first serial start operation...
                for l_job_serial_rec in c_job_serials loop

                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Invoking update_serial : ' || l_job_serial_rec.serial_number
                                                                                || ' Operation : ' || p_curr_job_op_seq_num
                                                                                || ' Op Step   : ' || p_curr_job_intraop_step,
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;

                        -- Call the API to update the serial number...
                        update_serial( p_serial_number                => l_job_serial_rec.serial_number ,
                                       p_inventory_item_id            => p_inventory_item_id            ,
                                       p_organization_id              => p_organization_id              ,
                                       p_wip_entity_id                => p_wip_entity_id                ,
                                       p_operation_seq_num            => p_curr_job_op_seq_num          ,
                                       p_intraoperation_step_type     => p_curr_job_intraop_step        ,
                                       x_return_status                => x_return_status                ,
                                       x_error_msg                    => x_error_count                  ,
                                       x_error_count                  => x_error_msg
                                     );

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;
                end loop;
        END IF;

        l_stmt_num := 330;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
END check_move_serial_qty;

-- Populate serial numbers for undo/return transactions..
Procedure populate_undo_txn (    p_move_txn_type         IN                     NUMBER,
                                 p_wip_entity_id         IN                     NUMBER,
                                 p_inventory_item_id     IN                     NUMBER,
                                 p_organization_id       IN                     NUMBER,
                                 p_move_qty              IN                     NUMBER,
                                 p_scrap_qty             IN                     NUMBER,
                                 p_new_move_txn_id       IN                     NUMBER,
                                 p_new_scrap_txn_id      IN                     NUMBER,
                                 p_old_move_txn_id       IN                     NUMBER  DEFAULT NULL,
                                 p_old_scrap_txn_id      IN                     NUMBER  DEFAULT NULL,
                                 x_return_status         OUT NOCOPY             VARCHAR2,
                                 x_error_msg             OUT NOCOPY             VARCHAR2,
                                 x_error_count           OUT NOCOPY             NUMBER
                            )


IS

        cursor c_ret_serial_num(v_txn_id IN NUMBER) IS
        SELECT MSN.serial_number,
               MSN.gen_object_id
        FROM   MTL_SERIAL_NUMBERS MSN
        WHERE  MSN.SERIAL_NUMBER IN (select wsmt.assembly_serial_number
                                     FROM   WIP_SERIAL_MOVE_TRANSACTIONS WSMT
                                     WHERE  WSMT.transaction_id = v_txn_id
                                    )
        AND   MSN.current_organization_id            = p_organization_id
        AND   MSN.inventory_item_id                  = p_inventory_item_id
        --AND   MSN.current_status                   = WIP_CONSTANTS.IN_STORES
        FOR   UPDATE NOWAIT;

        cursor c_undo_serial_num(v_txn_id IN NUMBER) IS
        SELECT MSN.serial_number,
               MSN.gen_object_id
        FROM   MTL_SERIAL_NUMBERS MSN
        WHERE  MSN.SERIAL_NUMBER IN (select wsmt.assembly_serial_number
                                     FROM   WIP_SERIAL_MOVE_TRANSACTIONS WSMT
                                     WHERE  WSMT.transaction_id = v_txn_id
                                    )
        AND   MSN.current_organization_id            = p_organization_id
        AND   MSN.inventory_item_id                  = p_inventory_item_id
        --AND   MSN.current_status                   = WIP_CONSTANTS.DEF_NOT_USED
        AND   MSN.wip_entity_id                      = p_wip_entity_id
        FOR   UPDATE NOWAIT;

type t_serial_txn_info_rec is RECORD
(  serial_number        MTL_SERIAL_NUMBERS.serial_number%TYPE,
   gen_object_id        MTL_SERIAL_NUMBERS.gen_object_id%TYPE
);

type t_serial_txn_info_tbl IS table of t_serial_txn_info_rec INDEX BY BINARY_INTEGER;

l_move_serial_num_list  t_serial_txn_info_tbl;
l_scrap_serial_num_list t_serial_txn_info_tbl;

l_wip_serial_rows_tbl   t_wip_intf_tbl_type;
l_index                 NUMBER;
l_pos                   NUMBER;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.populate_undo_txn';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...


BEGIN
        l_stmt_num := 10;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_move_qty';
                l_param_tbl(1).paramValue := p_move_qty;

                l_param_tbl(2).paramName := 'p_scrap_qty';
                l_param_tbl(2).paramValue := p_scrap_qty;

                l_param_tbl(3).paramName := 'p_move_txn_type';
                l_param_tbl(3).paramValue := p_move_txn_type;

                l_param_tbl(4).paramName := 'p_old_move_txn_id';
                l_param_tbl(4).paramValue := p_old_move_txn_id;

                l_param_tbl(5).paramName := 'p_old_scrap_txn_id';
                l_param_tbl(5).paramValue := p_old_scrap_txn_id;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        IF p_move_txn_type = 3 THEN -- assembly return

                l_stmt_num := 20;

                open c_ret_serial_num(p_old_move_txn_id);
                fetch c_ret_serial_num bulk collect into l_move_serial_num_list;
                close c_ret_serial_num;

        ELSIF p_move_txn_type = 4 THEN -- undo txn

                l_stmt_num := 30;

                open c_undo_serial_num(p_old_move_txn_id);
                fetch c_undo_serial_num bulk collect into l_move_serial_num_list;
                close c_undo_serial_num;

        END IF;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Undo Transaction (Move): Serial Records found for p_old_move_txn_id: ' || l_move_serial_num_list.count,
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        l_stmt_num := 50;

        if l_move_serial_num_list.count <> p_move_qty and
           p_move_qty > 0
        then
                l_stmt_num := 60;
                -- some of the serials are not present hence error out....
                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_SERIAL_INSUFFICIENT',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        l_stmt_num := 70;
        IF p_move_qty > 0 THEN
                IF p_move_txn_type = 3 THEN -- assembly return

                        l_stmt_num := 80;
                        open c_ret_serial_num(p_old_scrap_txn_id);
                        fetch c_ret_serial_num bulk collect into l_scrap_serial_num_list;
                        close c_ret_serial_num;

                ELSIF p_move_txn_type = 4 THEN -- undo txn

                        l_stmt_num := 90;
                        open c_undo_serial_num(p_old_scrap_txn_id);
                        fetch c_undo_serial_num bulk collect into l_scrap_serial_num_list;
                        close c_undo_serial_num;

                END IF;
        ELSIF p_move_qty = 0 THEN
                -- Then we would be having only one Txn ID.. Scrap ID would be null..
                -- Basically this is a pure scrap case... -- So just assign the already fetched list..
                l_scrap_serial_num_list := l_move_serial_num_list;
        END IF;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Undo Transaction (Scrap): Serial Records found : ' || l_scrap_serial_num_list.count,
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        l_stmt_num := 100;

        if l_scrap_serial_num_list.count <> p_scrap_qty then
                l_stmt_num := 110;
                -- some of the serials are not present hence error out....
                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_SERIAL_INSUFFICIENT',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        end if;

        l_stmt_num := 120;
        l_pos   := 0;
        IF p_move_qty > 0 THEN
                -- This is to take care of a pure scrap transaction...
                l_index := l_move_serial_num_list.first;

                while l_index is not null loop

                        l_pos := l_pos + 1;

                        l_wip_serial_rows_tbl(l_pos).assembly_serial_number := l_move_serial_num_list(l_index).serial_number;
                        l_wip_serial_rows_tbl(l_pos).gen_object_id          := l_move_serial_num_list(l_index).gen_object_id;
                        l_wip_serial_rows_tbl(l_pos).transaction_id         := p_new_move_txn_id    ;
                        l_wip_serial_rows_tbl(l_pos).LAST_UPDATE_DATE       := sysdate              ;
                        l_wip_serial_rows_tbl(l_pos).LAST_UPDATED_BY        := g_user_id            ;
                        l_wip_serial_rows_tbl(l_pos).CREATION_DATE          := sysdate              ;
                        l_wip_serial_rows_tbl(l_pos).CREATED_BY             := g_user_id            ;
                        l_wip_serial_rows_tbl(l_pos).LAST_UPDATE_LOGIN      := g_user_login_id      ;
                        l_wip_serial_rows_tbl(l_pos).REQUEST_ID             := g_request_id         ;
                        l_wip_serial_rows_tbl(l_pos).PROGRAM_APPLICATION_ID := g_program_appl_id    ;
                        l_wip_serial_rows_tbl(l_pos).PROGRAM_ID             := g_program_id         ;
                        l_wip_serial_rows_tbl(l_pos).PROGRAM_UPDATE_DATE    := sysdate              ;

                        l_index := l_move_serial_num_list.next(l_index);
                end loop;
        END IF;

        l_stmt_num := 130;
        l_index := l_scrap_serial_num_list.first;

        while l_index is not null loop

                l_pos := l_pos + 1;

                l_wip_serial_rows_tbl(l_pos).assembly_serial_number := l_scrap_serial_num_list(l_index).serial_number;
                l_wip_serial_rows_tbl(l_pos).gen_object_id          := l_scrap_serial_num_list(l_index).gen_object_id;
                l_wip_serial_rows_tbl(l_pos).transaction_id         := p_new_scrap_txn_id   ;
                l_wip_serial_rows_tbl(l_pos).LAST_UPDATE_DATE       := sysdate              ;
                l_wip_serial_rows_tbl(l_pos).LAST_UPDATED_BY        := g_user_id            ;
                l_wip_serial_rows_tbl(l_pos).CREATION_DATE          := sysdate              ;
                l_wip_serial_rows_tbl(l_pos).CREATED_BY             := g_user_id            ;
                l_wip_serial_rows_tbl(l_pos).LAST_UPDATE_LOGIN      := g_user_login_id      ;
                l_wip_serial_rows_tbl(l_pos).REQUEST_ID             := g_request_id         ;
                l_wip_serial_rows_tbl(l_pos).PROGRAM_APPLICATION_ID := g_program_appl_id    ;
                l_wip_serial_rows_tbl(l_pos).PROGRAM_ID             := g_program_id         ;
                l_wip_serial_rows_tbl(l_pos).PROGRAM_UPDATE_DATE    := sysdate              ;

                l_index := l_scrap_serial_num_list.next(l_index);
        end loop;

        l_stmt_num := 140;
        -- obtained all the serial numbers...
        -- have to insert all these into wip_serial_txn_interface...
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Undo Transaction : Going to insert : ' || l_wip_serial_rows_tbl.count || ' records',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        forall l_counter in l_wip_serial_rows_tbl.first..l_wip_serial_rows_tbl.last
                insert into wip_serial_move_interface values l_wip_serial_rows_tbl(l_counter);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );


END populate_undo_txn;

-- this procedure will fetch data only for split and update quantity transactions...
Procedure WLT_serial_intf_proc ( p_header_id            IN              NUMBER,
                                 p_wip_entity_id        IN              NUMBER,
                                 p_wip_entity_name      IN              VARCHAR2,
                                 p_wlt_txn_type         IN              NUMBER,
                                 p_organization_id      IN              NUMBER,
                                 x_serial_num_tbl       OUT NOCOPY      WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                 x_return_status        OUT NOCOPY      VARCHAR2,
                                 x_error_msg            OUT NOCOPY      VARCHAR2,
                                 x_error_count          OUT NOCOPY      NUMBER
                               )

IS

        l_wip_entity_id         NUMBER;
        l_inventory_item_id     NUMBER;

        l_miss_char             VARCHAR2(1) := FND_API.G_MISS_CHAR;
        l_null_num              NUMBER      := FND_API.G_NULL_NUM;
        l_null_date             DATE        := FND_API.G_NULL_DATE;
        l_null_char             VARCHAR2(1) := FND_API.G_NULL_CHAR;

        cursor c_wlt_serials
        is
        select
        wsti.Serial_Number                     ,
        null                                   ,
        -- (Gen_object_id --> assembly_item_id No longer used Instead the column will have gen_object_id though the name is assembly_item_id)
        wsti.header_id                         ,  -- header_id
        wsti.Generate_serial_number            ,
        wsti.Generate_for_qty                  ,
        wsti.Action_flag                       ,
        wsti.Current_wip_entity_name           ,
        wsti.Changed_wip_entity_name           ,
        wsti.Current_wip_entity_id             ,
        wsti.Changed_wip_entity_id             ,
        decode(wsti.serial_attribute_category  , l_null_char, null, null, msn.serial_attribute_category, wsti.serial_attribute_category), -- serial_attribute_category
        decode(wsti.territory_code             , l_null_char, null, null, msn.territory_code           , wsti.territory_code           ), -- territory_code
        decode(wsti.origination_date           , l_null_date, null, null, msn.origination_date         , wsti.origination_date         ), -- origination_date
        decode(wsti.c_attribute1               , l_null_char, null, null, msn.c_attribute1             , wsti.c_attribute1             ), -- c_attribute1
        decode(wsti.c_attribute2               , l_null_char, null, null, msn.c_attribute2             , wsti.c_attribute2             ), -- c_attribute2
        decode(wsti.c_attribute3               , l_null_char, null, null, msn.c_attribute3             , wsti.c_attribute3             ), -- c_attribute3
        decode(wsti.c_attribute4               , l_null_char, null, null, msn.c_attribute4             , wsti.c_attribute4             ), -- c_attribute4
        decode(wsti.c_attribute5               , l_null_char, null, null, msn.c_attribute5             , wsti.c_attribute5             ), -- c_attribute5
        decode(wsti.c_attribute6               , l_null_char, null, null, msn.c_attribute6             , wsti.c_attribute6             ), -- c_attribute6
        decode(wsti.c_attribute7               , l_null_char, null, null, msn.c_attribute7             , wsti.c_attribute7             ), -- c_attribute7
        decode(wsti.c_attribute8               , l_null_char, null, null, msn.c_attribute8             , wsti.c_attribute8             ), -- c_attribute8
        decode(wsti.c_attribute9               , l_null_char, null, null, msn.c_attribute9             , wsti.c_attribute9             ), -- c_attribute9
        decode(wsti.c_attribute10              , l_null_char, null, null, msn.c_attribute10            , wsti.c_attribute10            ), -- c_attribute10
        decode(wsti.c_attribute11              , l_null_char, null, null, msn.c_attribute11            , wsti.c_attribute11            ), -- c_attribute11
        decode(wsti.c_attribute12              , l_null_char, null, null, msn.c_attribute12            , wsti.c_attribute12            ), -- c_attribute12
        decode(wsti.c_attribute13              , l_null_char, null, null, msn.c_attribute13            , wsti.c_attribute13            ), -- c_attribute13
        decode(wsti.c_attribute14              , l_null_char, null, null, msn.c_attribute14            , wsti.c_attribute14            ), -- c_attribute14
        decode(wsti.c_attribute15              , l_null_char, null, null, msn.c_attribute15            , wsti.c_attribute15            ), -- c_attribute15
        decode(wsti.c_attribute16              , l_null_char, null, null, msn.c_attribute16            , wsti.c_attribute16            ), -- c_attribute16
        decode(wsti.c_attribute17              , l_null_char, null, null, msn.c_attribute17            , wsti.c_attribute17            ), -- c_attribute17
        decode(wsti.c_attribute18              , l_null_char, null, null, msn.c_attribute18            , wsti.c_attribute18            ), -- c_attribute18
        decode(wsti.c_attribute19              , l_null_char, null, null, msn.c_attribute19            , wsti.c_attribute19            ), -- c_attribute19
        decode(wsti.c_attribute20              , l_null_char, null, null, msn.c_attribute20            , wsti.c_attribute20            ), -- c_attribute20
        decode(wsti.d_attribute1               , l_null_date, null, null, msn.d_attribute1             , wsti.d_attribute1             ), -- d_attribute1
        decode(wsti.d_attribute2               , l_null_date, null, null, msn.d_attribute2             , wsti.d_attribute2             ), -- d_attribute2
        decode(wsti.d_attribute3               , l_null_date, null, null, msn.d_attribute3             , wsti.d_attribute3             ), -- d_attribute3
        decode(wsti.d_attribute4               , l_null_date, null, null, msn.d_attribute4             , wsti.d_attribute4             ), -- d_attribute4
        decode(wsti.d_attribute5               , l_null_date, null, null, msn.d_attribute5             , wsti.d_attribute5             ), -- d_attribute5
        decode(wsti.d_attribute6               , l_null_date, null, null, msn.d_attribute6             , wsti.d_attribute6             ), -- d_attribute6
        decode(wsti.d_attribute7               , l_null_date, null, null, msn.d_attribute7             , wsti.d_attribute7             ), -- d_attribute7
        decode(wsti.d_attribute8               , l_null_date, null, null, msn.d_attribute8             , wsti.d_attribute8             ), -- d_attribute8
        decode(wsti.d_attribute9               , l_null_date, null, null, msn.d_attribute9             , wsti.d_attribute9             ), -- d_attribute9
        decode(wsti.d_attribute10              , l_null_date, null, null, msn.d_attribute10            , wsti.d_attribute10            ), -- d_attribute10
        decode(wsti.n_attribute1               , l_null_num , null, null, msn.n_attribute1             , wsti.n_attribute1             ), -- n_attribute1
        decode(wsti.n_attribute2               , l_null_num , null, null, msn.n_attribute2             , wsti.n_attribute2             ), -- n_attribute2
        decode(wsti.n_attribute3               , l_null_num , null, null, msn.n_attribute3             , wsti.n_attribute3             ), -- n_attribute3
        decode(wsti.n_attribute4               , l_null_num , null, null, msn.n_attribute4             , wsti.n_attribute4             ), -- n_attribute4
        decode(wsti.n_attribute5               , l_null_num , null, null, msn.n_attribute5             , wsti.n_attribute5             ), -- n_attribute5
        decode(wsti.n_attribute6               , l_null_num , null, null, msn.n_attribute6             , wsti.n_attribute6             ), -- n_attribute6
        decode(wsti.n_attribute7               , l_null_num , null, null, msn.n_attribute7             , wsti.n_attribute7             ), -- n_attribute7
        decode(wsti.n_attribute8               , l_null_num , null, null, msn.n_attribute8             , wsti.n_attribute8             ), -- n_attribute8
        decode(wsti.n_attribute9               , l_null_num , null, null, msn.n_attribute9             , wsti.n_attribute9             ), -- n_attribute9
        decode(wsti.n_attribute10              , l_null_num , null, null, msn.n_attribute10            , wsti.n_attribute10            ), -- n_attribute10
        decode(wsti.status_id                  , l_null_num , null, null, msn.status_id                , wsti.status_id                ), -- status_id
        decode(wsti.time_since_new             , l_null_num , null, null, msn.time_since_new           , wsti.time_since_new           ), -- time_since_new
        decode(wsti.cycles_since_new           , l_null_num , null, null, msn.cycles_since_new         , wsti.cycles_since_new         ), -- cycles_since_new
        decode(wsti.time_since_overhaul        , l_null_num , null, null, msn.time_since_overhaul      , wsti.time_since_overhaul      ), -- time_since_overhaul
        decode(wsti.cycles_since_overhaul      , l_null_num , null, null, msn.cycles_since_overhaul    , wsti.cycles_since_overhaul    ), -- cycles_since_overhaul
        decode(wsti.time_since_repair          , l_null_num , null, null, msn.time_since_repair        , wsti.time_since_repair        ), -- time_since_repair
        decode(wsti.cycles_since_repair        , l_null_num , null, null, msn.cycles_since_repair      , wsti.cycles_since_repair      ), -- cycles_since_repair
        decode(wsti.time_since_visit           , l_null_num , null, null, msn.time_since_visit         , wsti.time_since_visit         ), -- time_since_visit
        decode(wsti.cycles_since_visit         , l_null_num , null, null, msn.cycles_since_visit       , wsti.cycles_since_visit       ), -- cycles_since_visit
        decode(wsti.time_since_mark            , l_null_num , null, null, msn.time_since_mark          , wsti.time_since_mark          ), -- time_since_mark
        decode(wsti.cycles_since_mark          , l_null_num , null, null, msn.cycles_since_mark        , wsti.cycles_since_mark        ), -- cycles_since_mark
        decode(wsti.number_of_repairs          , l_null_num , null, null, msn.number_of_repairs        , wsti.number_of_repairs        ), -- number_of_repairs
        decode(wsti.attribute_category         , l_null_char, l_miss_char , null ,msn.attribute_category   ,wsti.attribute_category    ),
        decode(wsti.attribute1                 , l_null_char ,l_miss_char , wsti.attribute1            ),
        decode(wsti.attribute2                 , l_null_char ,l_miss_char , wsti.attribute2            ),
        decode(wsti.attribute3                 , l_null_char ,l_miss_char , wsti.attribute3            ),
        decode(wsti.attribute4                 , l_null_char ,l_miss_char , wsti.attribute4            ),
        decode(wsti.attribute5                 , l_null_char ,l_miss_char , wsti.attribute5            ),
        decode(wsti.attribute6                 , l_null_char ,l_miss_char , wsti.attribute6            ),
        decode(wsti.attribute7                 , l_null_char ,l_miss_char , wsti.attribute7            ),
        decode(wsti.attribute8                 , l_null_char ,l_miss_char , wsti.attribute8            ),
        decode(wsti.attribute9                 , l_null_char ,l_miss_char , wsti.attribute9            ),
        decode(wsti.attribute10                , l_null_char ,l_miss_char , wsti.attribute10           ),
        decode(wsti.attribute11                , l_null_char ,l_miss_char , wsti.attribute11           ),
        decode(wsti.attribute12                , l_null_char ,l_miss_char , wsti.attribute12           ),
        decode(wsti.attribute13                , l_null_char ,l_miss_char , wsti.attribute13           ),
        decode(wsti.attribute14                , l_null_char ,l_miss_char , wsti.attribute14           ),
        decode(wsti.attribute15                , l_null_char ,l_miss_char , wsti.attribute15           )
        from wsm_serial_txn_interface wsti,
             mtl_serial_numbers       msn
        where header_id = p_header_id
        and transaction_type_id = 3
        and  wsti.serial_number = msn.serial_number (+)
        and  msn.inventory_item_id (+) = l_inventory_item_id
        and  msn.current_organization_id (+) = p_organization_id
        order by nvl(wsti.action_flag,0) desc; -- Code review remark
        -- first process Delete and then add

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.WLT_serial_intf_proc';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN

        l_stmt_num := 10;
        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN
                l_stmt_num := 15;
                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_wip_entity_id';
                l_param_tbl(1).paramValue := p_wip_entity_id;

                l_param_tbl(2).paramName := 'p_wip_entity_name';
                l_param_tbl(2).paramValue := p_wip_entity_name;

                l_param_tbl(3).paramName := 'p_organization_id';
                l_param_tbl(3).paramValue := p_organization_id;

                l_param_tbl(4).paramName := 'p_header_id';
                l_param_tbl(4).paramValue := p_header_id;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        if p_wlt_txn_type = (WSMPCNST.SPLIT) THEN -- check for the correctness..

                IF p_wip_entity_id IS NULL THEN
                        l_stmt_num := 20;
                        BEGIN
                                -- These two can cause error...
                                select we.wip_entity_id,wdj.primary_item_id
                                into   l_wip_entity_id,l_inventory_item_id
                                from   wip_entities we,
                                       wip_discrete_jobs wdj
                                where  we.wip_entity_name = p_wip_entity_name
                                and    we.wip_entity_id = wdj.wip_entity_id
                                and    we.organization_id = p_organization_id;

                                -- SELECT max(operation_seq_num)
                                -- INTO   l_op_seq_num
                                -- FROM   wip_operations
                                -- WHERE  wip_entity_id = p_wip_entity_id
                                -- AND   (quantity_in_queue <> 0
                                --         OR quantity_waiting_to_move <> 0
                                --       );

                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                        IF g_log_level_error >= l_log_level OR
                                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                        THEN

                                                l_msg_tokens.delete;
                                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                                l_msg_tokens(1).TokenValue := 'Wip Entity Name';
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_name           => 'WSM_INVALID_FIELD',
                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                        END;
                ELSE
                        l_stmt_num := 30;
                        BEGIN
                                -- These two can cause error...
                                select we.wip_entity_id,wdj.primary_item_id
                                into   l_wip_entity_id,l_inventory_item_id
                                from   wip_entities we,
                                       wip_discrete_jobs wdj
                                where  we.wip_entity_name = nvl(p_wip_entity_name,we.wip_entity_name)
                                and    we.wip_entity_id = wdj.wip_entity_id
                                and    we.wip_entity_id = p_wip_entity_id
                                and    we.organization_id = p_organization_id;

                                l_stmt_num := 35;

                                -- SELECT max(operation_seq_num)
                                -- INTO   l_op_seq_num
                                -- FROM   wip_operations
                                -- WHERE  wip_entity_id = p_wip_entity_id
                                -- AND   (quantity_in_queue <> 0
                                --         OR quantity_waiting_to_move <> 0
                                --       );

                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                        IF g_log_level_error >= l_log_level OR
                                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                        THEN

                                                l_msg_tokens.delete;
                                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                                l_msg_tokens(1).TokenValue := 'Wip Entity Name/Wip entity ID';
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                        END;
                END IF;

                l_stmt_num := 40;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'l_wip_entity_id : ' || l_wip_entity_id || ' l_inventory_item_id : ' || l_inventory_item_id,
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                update wsm_serial_txn_interface wsti
                set wsti.process_status = wip_constants.error
                where wsti.header_id = p_header_id
                and wsti.transaction_type_id = 3
                and serial_number not in ( SELECT MSN.serial_number
                                           FROM  MTL_SERIAL_NUMBERS MSN
                                           WHERE  MSN.wip_entity_id                  = l_wip_entity_id
                                           AND   MSN.current_organization_id         = p_organization_id
                                           AND   MSN.inventory_item_id               = l_inventory_item_id
                                           -- AND   MSN.current_status               = WIP_CONSTANTS.IN_STORES
                                           -- AND   MSN.operation_seq_num            = l_op_seq_num
                                           -- AND   MSN.intraoperation_step_type     = p_curr_job_intraop_step < not required...>
                                           AND    nvl(MSN.intraoperation_step_type,-1)  <> 5
                                         );

                if SQL%ROWCOUNT > 0 then
                        -- Error out..
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_SERIALS_SUPPLIED',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                l_stmt_num := 50;
                open c_wlt_serials;
                fetch c_wlt_serials
                bulk collect into x_serial_num_tbl;
                close c_wlt_serials;

        elsif p_wlt_txn_type = (WSMPCNST.UPDATE_QUANTITY) THEN

                l_stmt_num := 60;
                update wsm_serial_txn_interface wsti
                set wsti.process_status = wip_constants.error
                where wsti.header_id = p_header_id
                and wsti.transaction_type_id = 3
                and action_flag not in (WSM_GASSOC_SERIAL_NUM,WSM_ADD_SERIAL_NUM);


                if SQL%ROWCOUNT > 0 then
                        -- Error out..
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                l_msg_tokens(1).TokenValue := 'Action flag for Update Quantity transaction';
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVALID_JOB_TXN_QTY',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                end if;

                l_stmt_num := 70;
                -- just fetch the data...
                open c_wlt_serials;
                fetch c_wlt_serials
                bulk collect into x_serial_num_tbl;
                close c_wlt_serials;

                l_stmt_num := 80;
        end if;
EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
END WLT_serial_intf_proc;

Procedure fetch_wlt_serials  (  p_new_job_name          IN              VARCHAR2                ,
                                p_split_txn_job_id      IN              NUMBER                  ,
                                p_serial_num_tbl        IN OUT NOCOPY   WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                x_return_status         OUT NOCOPY      VARCHAR2                ,
                                x_error_msg             OUT NOCOPY      VARCHAR2                ,
                                x_error_count           OUT NOCOPY      NUMBER
                             )

IS

CURSOR c_job_serials IS
select serial_number
from   mtl_serial_numbers MSN,
       wip_discrete_jobs WDJ
where  MSN.inventory_item_id = WDJ.primary_item_id
and    MSN.wip_entity_id = p_split_txn_job_id
and    MSN.current_organization_id = WDJ.organization_id
and    WDJ.wip_entity_id = p_split_txn_job_id
and    nvl(MSN.intraoperation_step_type,-1) <> 5;


type t_serial_tbl IS table of number INDEX by MTL_SERIAL_NUMBERS.SERIAL_NUMBER%TYPE;
l_serial_list    t_serial_tbl;

l_job_serials    t_varchar2;
l_index          NUMBER;
l_sindex         NUMBER;
l_new_index      NUMBER;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.fetch_wlt_serials';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...


BEGIN
        l_stmt_num := 10;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Inside fetch_wlt_serials',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        l_stmt_num := 15;

        l_index := p_serial_num_tbl.first;
        while l_index is not null loop
                l_serial_list(p_serial_num_tbl(l_index).serial_number) := 1;
                l_index := p_serial_num_tbl.next(l_index);
        end loop;

        open c_job_serials;
        fetch c_job_serials
        bulk collect into l_job_serials;
        close c_job_serials;

        l_sindex := l_job_serials.first;
        while (l_sindex IS NOT NULL) loop
                IF NOT(l_serial_list.exists(l_job_serials(l_sindex))) THEN
                        -- Add to the list...
                        l_new_index := p_serial_num_tbl.count + 1;
                        p_serial_num_tbl(l_new_index).serial_number := l_job_serials(l_sindex);
                        p_serial_num_tbl(l_new_index).Changed_wip_entity_name := p_new_job_name;
                END IF;
                l_sindex := l_job_serials.next(l_sindex);
        end loop;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Inside fetch_wlt_serials : Serial Numbers count : ' || p_serial_num_tbl.count,
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

EXCEPTION
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

END fetch_wlt_serials;

-- Insert records into WSM_SERIAL_TRANSACTIONS for WIP Lot Transactions...
-- This procedure will be called for all wip lot transactions other than split and merge...
Procedure Insert_into_WST ( p_transaction_id            IN              NUMBER          ,
                            p_transaction_type_id       IN              NUMBER          ,
                            p_old_wip_entity_name       IN              VARCHAR2        ,
                            p_new_wip_entity_name       IN              VARCHAR2        ,
                            p_organization_id           IN              NUMBER          ,
                            p_item_id                   IN              NUMBER          ,
                            p_wip_entity_id             IN              NUMBER          ,
                            x_return_status             OUT NOCOPY      VARCHAR2        ,
                            x_error_msg                 OUT NOCOPY      VARCHAR2        ,
                            x_error_count               OUT NOCOPY      NUMBER
                          )
IS

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.Insert_into_WST';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
        l_stmt_num := 10;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN
                l_stmt_num := 15;
                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_transaction_type_id';
                l_param_tbl(1).paramValue := p_transaction_type_id;

                l_param_tbl(2).paramName := 'p_old_wip_entity_name';
                l_param_tbl(2).paramValue := p_old_wip_entity_name;

                l_param_tbl(3).paramName := 'p_new_wip_entity_name';
                l_param_tbl(3).paramValue := p_new_wip_entity_name;

                l_param_tbl(4).paramName := 'p_transaction_id';
                l_param_tbl(4).paramValue := p_transaction_id;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        l_stmt_num := 20;
        -- Check for the transaction type...
        insert into wsm_serial_transactions
        (transaction_id                         ,
         transaction_type_id                    ,
         serial_number                          ,
         gen_object_id                          ,
         current_wip_entity_name                       ,
         changed_wip_entity_name                       ,
         current_wip_entity_id                  ,
         changed_wip_entity_id                  ,
         created_by                             ,
         last_update_date                       ,
         last_updated_by                        ,
         creation_date                          ,
         last_update_login                      ,
         request_id                             ,
         program_application_id                 ,
         program_id                             ,
         program_update_date                    ,
         original_system_reference
        )
        select
        p_transaction_id                          ,
        3                                         ,
        MSN.serial_number                         ,
        MSN.gen_object_id                         ,
        p_old_wip_entity_name                     ,
        p_new_wip_entity_name                     ,
        p_wip_entity_id                           ,
        p_wip_entity_id                           ,
        g_user_id                                 ,
        sysdate                                   ,
        g_user_id                                 ,
        sysdate                                   ,
        g_user_login_id                           ,
        g_request_id                              ,
        g_program_appl_id                         ,
        g_program_id                              ,
        sysdate                                   ,
        null
        from mtl_serial_numbers MSN
        where MSN.current_organization_id = p_organization_id
        and   MSN.inventory_item_id = p_item_id
        and   MSN.wip_entity_id = p_wip_entity_id
        and   nvl(MSN.intraoperation_step_type,-1) <> 5;


EXCEPTION

        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
END Insert_into_WST;

-- WIP Lot transactions processor...

Procedure WLT_serial_processor  ( p_calling_mode                IN              NUMBER,
                                  p_wlt_txn_type                IN              NUMBER,
                                  p_organization_id             IN              NUMBER,
                                  p_txn_id                      IN              NUMBER,
                                  p_starting_jobs_tbl           IN              WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
                                  p_resulting_jobs_tbl          IN              WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
                                  p_serial_num_tbl              IN OUT NOCOPY   WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL,
                                  x_return_status               OUT NOCOPY      VARCHAR2,
                                  x_error_msg                   OUT NOCOPY      VARCHAR2,
                                  x_error_count                 OUT NOCOPY      NUMBER
                                )

IS

        type t_jser_info_rec_type is record
        (
                l_index_start NUMBER,
                l_count       NUMBER
        );


        type t_jser_info_tbl_type is table of t_jser_info_rec_type index by WIP_ENTITIES.wip_entity_name%type;
        type t_job_name_tbl_type  is table of NUMBER index by WIP_ENTITIES.wip_entity_name%type;

        l_job_ser_info_tbl      t_jser_info_tbl_type;
        l_res_job_tbl           t_job_name_tbl_type;

        l_wip_entity_name       VARCHAR2(80);
        l_wip_entity_id         NUMBER;
        l_inventory_item_id     NUMBER;
        l_curr_job_op_seq_num   NUMBER;
        l_curr_job_op_step      NUMBER;

        -- To be passed to the new INV API...
        l_validation_status     VARCHAR2(10);

        l_index                 NUMBER;
        l_clear_serial_attr     NUMBER;
        l_update_serial_attr    NUMBER;
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_serial_start_flag     NUMBER;
        l_index1                NUMBER;
        l_index2                NUMBER;
        l_serial_ctrl_code      NUMBER;
        l_first_serial_txn_id   NUMBER;
        l_start_quantity        NUMBER;

        l_parent_job_ser_context MTL_SERIAL_NUMBERS.SERIAL_ATTRIBUTE_CATEGORY%type;
        l_child_job_ser_context  MTL_SERIAL_NUMBERS.SERIAL_ATTRIBUTE_CATEGORY%type;
        l_context                MTL_SERIAL_NUMBERS.SERIAL_ATTRIBUTE_CATEGORY%type;

        l_temp_rec              WSM_Serial_Support_GRP.WSM_SERIAL_NUM_REC;
        l_start_as_res_job      NUMBER;
        l_serial_start_op       NUMBER;
        l_serial_num_count      NUMBER;
        l_rep_job_index         NUMBER;
        l_old_start_index       NUMBER;
        l_count                 NUMBER;
        l_serial_tbl            t_varchar2;
        l_op_seq_incr           NUMBER;

        l_temp_op_seq_num       NUMBER;
        l_temp_op_step          NUMBER;

        -- This is the job against which the left over serial numbers of the parent job will be assigned...
        l_filling_job_name      WIP_ENTITIES.wip_entity_name%type := null;
        l_parent_as_resjob      NUMBER := null;
        l_old_count             NUMBER;
        l_new_count             NUMBER;
        l_temp_job              WIP_ENTITIES.wip_entity_name%TYPE; -- Used for debugging..
        l_index_job_name        WIP_ENTITIES.wip_entity_name%TYPE;
        l_move_flag             VARCHAR2(1) := 'N';
        l_curr_job_name         WIP_ENTITIES.wip_entity_name%TYPE;

        CURSOR c_job_serials(v_wip_entity_id IN NUMBER,v_item_id IN NUMBER)
        IS SELECT msn.serial_number
           FROM   MTL_SERIAL_NUMBERS MSN
           WHERE  msn.wip_entity_id = v_wip_entity_id
           AND    msn.inventory_item_id = v_item_id
           AND    nvl(msn.INTRAOPERATION_STEP_TYPE,-1) <> WIP_CONSTANTS.SCRAP
           AND    msn.current_organization_id  = p_organization_id;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.WLT_serial_processor';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
        l_stmt_num := 10;

        SAVEPOINT WLT_serial_proc;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_calling_mode';
                l_param_tbl(1).paramValue := p_calling_mode;

                l_param_tbl(2).paramName := 'p_organization_id';
                l_param_tbl(2).paramValue := p_organization_id;

                l_param_tbl(3).paramName := 'p_txn_id';
                l_param_tbl(3).paramValue := p_txn_id;

                l_param_tbl(4).paramName := 'p_serial_num_tbl.count';
                l_param_tbl(4).paramValue := p_serial_num_tbl.count;

                l_param_tbl(5).paramName := 'p_wlt_txn_type';
                l_param_tbl(5).paramValue := p_wlt_txn_type;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_stmt_num := 15;
                -- Procedure to dump the serial records' data....
                log_serial_data ( p_serial_num_tbl    => p_serial_num_tbl       ,
                                  x_return_status     => x_return_status        ,
                                  x_error_msg         => x_error_msg            ,
                                  x_error_count       => x_error_count
                                );
                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        END IF;

        l_stmt_num := 20;
        IF p_wlt_txn_type = WSMPCNST.MERGE THEN
                l_index := p_starting_jobs_tbl.first;

                l_stmt_num := 25;
                while l_index is not null loop
                        if p_starting_jobs_tbl(l_index).representative_flag = 'Y' then
                                l_rep_job_index := l_index;
                                exit;
                        end if;
                        l_index := p_starting_jobs_tbl.next(l_index);
                end loop;

        ELSIF p_wlt_txn_type = WSMPCNST.BONUS THEN
                return;
        ELSE
                l_rep_job_index := p_starting_jobs_tbl.first;
        END IF;

        l_stmt_num := 30;
        l_wip_entity_id     := p_starting_jobs_tbl(l_rep_job_index).wip_entity_id;
        l_inventory_item_id := p_starting_jobs_tbl(l_rep_job_index).primary_item_id;
        l_wip_entity_name   := p_starting_jobs_tbl(l_rep_job_index).wip_entity_name;

        -- l_curr_job_op_seq_num := p_starting_jobs_tbl(l_rep_job_index).operation_seq_num;
        -- l_curr_job_op_step    := p_starting_jobs_tbl(l_rep_job_index).intraoperation_step;
        l_start_quantity      := p_starting_jobs_tbl(l_rep_job_index).quantity_available;

        get_serial_track_info (  p_serial_item_id          => l_inventory_item_id         ,
                                 p_organization_id         => p_organization_id           ,
                                 p_wip_entity_id           => l_wip_entity_id             ,
                                 x_serial_start_flag       => l_serial_start_flag         ,
                                 x_serial_ctrl_code        => l_serial_ctrl_code          ,
                                 x_first_serial_txn_id     => l_first_serial_txn_id       ,
                                 x_serial_start_op         => l_serial_start_op           ,
                                 x_return_status           => x_return_status             ,
                                 x_error_msg               => x_error_msg                 ,
                                 x_error_count             => x_error_count
                             );

        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

        IF l_serial_start_flag IS NOT NULL THEN

                select nvl(op_seq_num_increment, 10)
                into   l_op_seq_incr
                from   wsm_parameters
                where  organization_id = p_organization_id;

                IF p_wlt_txn_type IN (WSMPCNST.UPDATE_ASSEMBLY,WSMPCNST.UPDATE_ROUTING) THEN
                        l_curr_job_op_seq_num := p_starting_jobs_tbl(l_rep_job_index).operation_seq_num + l_op_seq_incr;
                        l_curr_job_op_step    := WIP_CONSTANTS.QUEUE;
                ELSE
                        l_curr_job_op_seq_num := p_starting_jobs_tbl(l_rep_job_index).operation_seq_num;
                        l_curr_job_op_step    := p_starting_jobs_tbl(l_rep_job_index).intraoperation_step;
                END IF;

        ELSE
                l_curr_job_op_seq_num := null;
                l_curr_job_op_step    := null;
        END IF;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'l_curr_job_op_seq_num : ' || l_curr_job_op_seq_num
                                                                || ' l_curr_job_op_step : ' || l_curr_job_op_step
                                                                || ' p_serial_num_tbl.count ' || p_serial_num_tbl.count,
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        l_stmt_num := 40;
        if l_serial_ctrl_code <> 2 then

                -- Populate a warning message and return...
                IF p_serial_num_tbl.count <> 0 then
                        l_stmt_num := 45;
                        -- error out...
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_INVLAID_SERIAL_INFO',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                RETURN;
        end if;

        l_stmt_num := 50;
        IF p_wlt_txn_type = WSMPCNST.SPLIT THEN --split transaction

                l_stmt_num := 60;
                -- For non-serial tracked jobs, the serial information should be complete...
                -- If the starting job is not a resulting job, then
                -- Total number of serial numbers should equal the job serial qty....
                select count(*)
                into   l_serial_num_count
                -- ST : Fix for bug 4910758 (remove usage of wsm_job_serial_numbers_v)
                -- from wsm_job_serial_numbers_v
                from   mtl_serial_numbers
                where  inventory_item_id = l_inventory_item_id
                and    wip_entity_id = l_wip_entity_id
                and    nvl(intraoperation_step_type,-1) <> 5;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Serial Numbers of Parent Job : ' || l_serial_num_count ||
                                                                       ' Provided Serial Numbers : ' || p_serial_num_tbl.count,
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;
                IF (l_serial_num_count = 0 and p_serial_num_tbl.count = 0) THEN
                        -- Return as no serial processing required...
                        return;
                ELSIF l_serial_num_count = 0 and p_serial_num_tbl.count <> 0 THEN
                        -- error out...
                        -- error out...
                        l_stmt_num := 70;
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_name           => 'WSM_SPLIT_SERIAL_INFO_REQ',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                l_stmt_num := 80;
                -- First thing is sort the serial numbers table based on wip_entity_name
                -- We also ensure that the serial numbers of the starting job if present as a resulting job comes at the end...
                -- This is required to determine the records not specified...
                l_index1 := p_serial_num_tbl.first;
                while(l_index1 IS NOT NULL) loop

                        l_index2 := p_serial_num_tbl.next(l_index1);

                        while(l_index2 IS NOT NULL) loop

                                IF p_serial_num_tbl(l_index2).serial_number = p_serial_num_tbl(l_index1).serial_number THEN
                                        -- Duplicate entry....
                                        -- error out...
                                        l_stmt_num := 85;
                                        IF g_log_level_error >= l_log_level OR
                                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                        THEN
                                                l_msg_tokens.delete;
                                                l_msg_tokens(1).TokenName  := 'SERIAL';
                                                l_msg_tokens(1).TokenValue := p_serial_num_tbl(l_index2).serial_number;

                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_name           => 'WSM_DUPLICATE_TXN_SERIAL',
                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                                END IF;

                                IF (p_serial_num_tbl(l_index2).changed_wip_entity_name < p_serial_num_tbl(l_index1).changed_wip_entity_name)
                                   -- OR (p_serial_num_tbl(l_index2).changed_wip_entity_name <> l_wip_entity_name AND
                                   --     p_serial_num_tbl(l_index1).changed_wip_entity_name = l_wip_entity_name)
                                THEN
                                        -- exchange...
                                        l_temp_rec := p_serial_num_tbl(l_index2);
                                        p_serial_num_tbl(l_index2) := p_serial_num_tbl(l_index1);
                                        p_serial_num_tbl(l_index1) := l_temp_rec;
                                END IF;

                                l_index2 := p_serial_num_tbl.next(l_index2);

                        end loop;

                        l_index1 := p_serial_num_tbl.next(l_index1);

                end loop;

                l_stmt_num := 90;
                -- Now the data is sorted...
                l_index := p_resulting_jobs_tbl.first;
                while l_index is not null loop

                        IF p_resulting_jobs_tbl(l_index).wip_entity_name = l_wip_entity_name then
                                l_parent_as_resjob := l_index;
                        end if;

                        l_res_job_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name) := l_index;

                        l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name).l_index_start := null;
                        l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name).l_count       := 0;

                        l_index := p_resulting_jobs_tbl.next(l_index);

                end loop;

                l_stmt_num := 100;
                -- create a index on the collected serial numbers...
                l_index := p_serial_num_tbl.first;

                while l_index is not null loop

                        -- Info already present...
                        if l_job_ser_info_tbl(p_serial_num_tbl(l_index).changed_wip_entity_name).l_index_start IS NOT NULL then
                                --same job so increment just the count..
                                l_job_ser_info_tbl(p_serial_num_tbl(l_index).changed_wip_entity_name).l_count  := l_job_ser_info_tbl(p_serial_num_tbl(l_index).changed_wip_entity_name).l_count + 1;
                        else
                                if not (l_res_job_tbl.exists(p_serial_num_tbl(l_index).changed_wip_entity_name)) THEN

                                        l_stmt_num := 105;
                                        --error out..
                                        IF g_log_level_error >= l_log_level OR
                                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                        THEN
                                                l_msg_tokens.delete;
                                                l_msg_tokens(1).TokenName := 'FLD_NAME';
                                                l_msg_tokens(1).TokenValue := 'Changed Job Name';
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_name           => 'WSM_INVALID_FIELD'      ,
                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                                end if;

                                l_job_ser_info_tbl(p_serial_num_tbl(l_index).changed_wip_entity_name).l_index_start := l_index;
                                l_job_ser_info_tbl(p_serial_num_tbl(l_index).changed_wip_entity_name).l_count     := 1;
                        end if;

                        l_index := p_serial_num_tbl.next(l_index);

                end loop;

                l_stmt_num := 107;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_temp_job := l_job_ser_info_tbl.first;
                        WHILE l_temp_job IS NOT NULL LOOP
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module                 ,
                                                        p_msg_text          => 'Job Name : ' || l_temp_job ||
                                                                               ' Job Index Start : ' || l_job_ser_info_tbl(l_temp_job).l_index_start ||
                                                                               ' Count : ' || l_job_ser_info_tbl(l_temp_job).l_count ,
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        l_temp_job := l_job_ser_info_tbl.next(l_temp_job);
                        END LOOP;

                END IF;

                l_stmt_num := 110;
                -- Now the main processing part starts...
                if g_wms_installed IS NULL THEN

                        wms_installed ( x_return_status   =>  x_return_status   ,
                                        x_error_count     =>  x_error_count     ,
                                        x_err_data        =>  x_error_msg
                                      );

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;

                        l_update_serial_attr := g_wms_installed;
                else
                        l_update_serial_attr := g_wms_installed;
                end if;

                l_stmt_num := 120;
                IF l_update_serial_attr = 1 then

                        l_parent_job_ser_context := null;

                        INV_LOT_SEL_ATTR.get_context_code ( context_value => l_parent_job_ser_context,
                                                            org_id        => p_organization_id  ,
                                                            item_id       => l_inventory_item_id,
                                                            flex_name     => 'Serial Attributes'
                                                          );
                END IF;

                l_stmt_num := 130;
                l_index := p_resulting_jobs_tbl.first;

                while l_index is not null loop

                        l_stmt_num := 131;
                        if (l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name).l_count >
                            p_resulting_jobs_tbl(l_index).start_quantity)
                        then
                                l_stmt_num := 132;
                                -- error out...
                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN

                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'JOB';
                                        l_msg_tokens(1).TokenValue := p_resulting_jobs_tbl(l_index).wip_entity_name;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_SERIAL_QTY1' ,
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        end if;

                        l_stmt_num := 133;
                        -- first check is on the count...
                        IF (l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name).l_count < p_resulting_jobs_tbl(l_index).start_quantity)
                        THEN

                                l_stmt_num := 134;

                                -- check if already another job has been encountered...
                                -- Serial Numbers can be derived be derived only for one of the resulting jobs and
                                if (l_filling_job_name IS NULL) and
                                   (p_serial_num_tbl.count <> l_serial_num_count) -- try to derive only when complete info is not specified.
                                THEN

                                        l_stmt_num := 135;
                                        -- See if you can derive first of all...
                                        IF p_resulting_jobs_tbl(l_index).start_quantity  <
                                           (l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name).l_count + l_serial_num_count - p_serial_num_tbl.count)
                                        THEN
                                                IF g_log_level_error >= l_log_level OR
                                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                                THEN

                                                        l_msg_tokens.delete;
                                                        l_msg_tokens(1).TokenName := 'JOB';
                                                        l_msg_tokens(1).TokenValue := p_resulting_jobs_tbl(l_index).wip_entity_name;
                                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                               p_msg_name           => 'WSM_SPLIT_SERIAL_INSUFF',
                                                                               p_msg_appl_name      => 'WSM'                    ,
                                                                               p_msg_tokens         => l_msg_tokens             ,
                                                                               p_stmt_num           => l_stmt_num               ,
                                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                               p_run_log_level      => l_log_level
                                                                              );
                                                END IF;
                                                RAISE FND_API.G_EXC_ERROR;
                                        END IF;

                                        -- None encountered so far...
                                        l_filling_job_name := p_resulting_jobs_tbl(l_index).wip_entity_name;

                                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                                        p_msg_text          => 'Deriving serial numbers for the job : ' || l_filling_job_name,
                                                                        p_stmt_num          => l_stmt_num               ,
                                                                        p_msg_tokens        => l_msg_tokens             ,
                                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                        p_run_log_level     => l_log_level
                                                                        );
                                        END IF;

                                        l_move_flag := 'N';
                                        -- l_index1 := p_resulting_jobs_tbl.next(l_index);
                                        -- -- Indices of the later jobs are modified...
                                        -- while l_index1 IS NOT NULL loop
                                        --
                                        --         IF l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index1).wip_entity_name).l_index_start IS NOT NULL THEN
                                        --
                                        --                 l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index1).wip_entity_name).l_index_start
                                        --                 := l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index1).wip_entity_name).l_index_start -
                                        --                 l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name).l_count;
                                        --         END IF;
                                        --
                                        --         l_index1 := p_resulting_jobs_tbl.next(l_index1);
                                        -- end loop;

                                        -- Now decrease the starting index of all the jobs whose index starts after this job's index start...
                                        l_index_job_name := l_job_ser_info_tbl.first;
                                        l_curr_job_name  := p_resulting_jobs_tbl(l_index).wip_entity_name;
                                        -- Indices of the later jobs are modified...
                                        while l_index_job_name IS NOT NULL loop

                                                IF (l_job_ser_info_tbl(l_index_job_name).l_index_start IS NOT NULL) AND
                                                   (l_job_ser_info_tbl(l_index_job_name).l_index_start > l_job_ser_info_tbl(l_curr_job_name).l_index_start)
                                                THEN
                                                        l_job_ser_info_tbl(l_index_job_name).l_index_start := l_job_ser_info_tbl(l_index_job_name).l_index_start
                                                                                                              - l_job_ser_info_tbl(l_curr_job_name).l_count;
                                                        l_move_flag := 'Y';
                                                END IF;

                                                l_index_job_name := l_job_ser_info_tbl.next(l_index_job_name);
                                        end loop;

                                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage (p_module_name       => l_module                 ,
                                                                        p_msg_text          => 'After decrementing all the subsequent indices',
                                                                        p_stmt_num          => l_stmt_num               ,
                                                                        p_msg_tokens        => l_msg_tokens             ,
                                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                        p_run_log_level     => l_log_level
                                                                        );
                                                l_temp_job := l_job_ser_info_tbl.first;
                                                WHILE l_temp_job IS NOT NULL LOOP

                                                        WSM_log_PVT.logMessage (p_module_name       => l_module                 ,
                                                                                p_msg_text          => 'Job Name : ' || l_temp_job ||
                                                                                                       ' Job Index Start : ' || l_job_ser_info_tbl(l_temp_job).l_index_start ||
                                                                                                       ' Count : ' || l_job_ser_info_tbl(l_temp_job).l_count ,
                                                                                p_stmt_num          => l_stmt_num               ,
                                                                                p_msg_tokens        => l_msg_tokens             ,
                                                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                                p_run_log_level     => l_log_level
                                                                                );
                                                l_temp_job := l_job_ser_info_tbl.next(l_temp_job);
                                                END LOOP;

                                                l_index1 := p_serial_num_tbl.first;
                                                while l_index1 IS NOT NULL LOOP
                                                        WSM_log_PVT.logMessage (p_module_name       => l_module                 ,
                                                                                p_msg_text          => 'Index : ' || l_index1 ||
                                                                                                       ' Serial Number : ' || p_serial_num_tbl(l_index1).serial_number ||
                                                                                                       ' Job Name : ' || p_serial_num_tbl(l_index1).changed_wip_entity_name ,
                                                                                p_stmt_num          => l_stmt_num               ,
                                                                                p_msg_tokens        => l_msg_tokens             ,
                                                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                                p_run_log_level     => l_log_level
                                                                                );
                                                        l_index1 := p_serial_num_tbl.next(l_index1);
                                                END LOOP;
                                        END IF;

                                        l_stmt_num := 136;
                                        -- Next.. move the records of this job to the last...
                                        -- We'' do this only when we have some entries for our current job in the dictonary..
                                        IF l_move_flag = 'Y' THEN
                                                -- l_old_start_index  := l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name).l_index_start;
                                                l_old_start_index  := l_job_ser_info_tbl(l_curr_job_name).l_index_start;

                                                l_index1 := l_job_ser_info_tbl(l_curr_job_name).l_index_start;
                                                while (l_index1 IS NOT NULL) and
                                                      (l_index1 < (l_job_ser_info_tbl(l_curr_job_name).l_index_start + l_job_ser_info_tbl(l_curr_job_name).l_count))
                                                loop
                                                        p_serial_num_tbl(p_serial_num_tbl.count+1) := p_serial_num_tbl(l_index1);
                                                        l_index1 := l_index1 + 1;
                                                end loop;

                                                l_stmt_num := 137;
                                                -- Ok .. overwrite the records now...
                                                l_index1 := l_old_start_index;
                                                while (l_index1 IS NOT NULL) AND
                                                      (l_index1 <= (p_serial_num_tbl.count -
                                                                    l_job_ser_info_tbl(l_curr_job_name).l_count))
                                                loop
                                                        p_serial_num_tbl(l_index1) := p_serial_num_tbl(l_index1 + l_job_ser_info_tbl(l_curr_job_name).l_count);
                                                        l_index1 := l_index1 + 1;
                                                end loop;

                                                l_stmt_num := 138;
                                                -- Ok.. done...
                                                -- Delete the last records...
                                                l_index1 := p_serial_num_tbl.count - l_job_ser_info_tbl(l_curr_job_name).l_count + 1;
                                                l_count  := 1;
                                                while (l_count <=  l_job_ser_info_tbl(l_curr_job_name).l_count) loop
                                                        p_serial_num_tbl.delete(l_index1);
                                                        l_index1 := l_index1 + 1;
                                                        l_count  := l_count  + 1;
                                                end loop;

                                        END IF;

                                        l_stmt_num := 139;
                                        -- Update the start index...
                                        l_job_ser_info_tbl(l_curr_job_name).l_index_start := p_serial_num_tbl.count - (l_job_ser_info_tbl(l_curr_job_name).l_count) + 1;

                                        l_stmt_num := 140;
                                        l_old_count := p_serial_num_tbl.count;
                                        -- Fetch the rows,, and fill in the non-present serial numbers...
                                        fetch_wlt_serials(p_new_job_name     => p_resulting_jobs_tbl(l_index).wip_entity_name ,
                                                          p_serial_num_tbl   => p_serial_num_tbl                              ,
                                                          p_split_txn_job_id => l_wip_entity_id                               ,
                                                          x_return_status    => x_return_status                               ,
                                                          x_error_msg        => x_error_msg                                   ,
                                                          x_error_count      => x_error_count
                                                         );

                                        if x_return_status <> G_RET_SUCCESS then
                                                IF x_return_status = G_RET_ERROR THEN
                                                        raise FND_API.G_EXC_ERROR;
                                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                                END IF;
                                        end if;

                                        l_stmt_num := 141;
                                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage (p_module_name       => l_module                 ,
                                                                        p_msg_text          => 'After all operations',
                                                                        p_stmt_num          => l_stmt_num               ,
                                                                        p_msg_tokens        => l_msg_tokens             ,
                                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                        p_run_log_level     => l_log_level
                                                                        );

                                                l_temp_job := l_job_ser_info_tbl.first;
                                                WHILE l_temp_job IS NOT NULL LOOP

                                                        WSM_log_PVT.logMessage (p_module_name       => l_module                 ,
                                                                                p_msg_text          => 'Job Name : ' || l_temp_job ||
                                                                                                       ' Job Index Start : ' || l_job_ser_info_tbl(l_temp_job).l_index_start ||
                                                                                                       ' Count : ' || l_job_ser_info_tbl(l_temp_job).l_count ,
                                                                                p_stmt_num          => l_stmt_num               ,
                                                                                p_msg_tokens        => l_msg_tokens             ,
                                                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                                p_run_log_level     => l_log_level
                                                                                );
                                                        l_temp_job := l_job_ser_info_tbl.next(l_temp_job);
                                                END LOOP;

                                                l_index1 := p_serial_num_tbl.first;
                                                while l_index1 IS NOT NULL LOOP
                                                        WSM_log_PVT.logMessage (p_module_name       => l_module                 ,
                                                                                p_msg_text          => 'Index : ' || l_index1 ||
                                                                                                       ' Serial Number : ' || p_serial_num_tbl(l_index1).serial_number ||
                                                                                                       ' Job Name : ' || p_serial_num_tbl(l_index1).changed_wip_entity_name ,
                                                                                p_stmt_num          => l_stmt_num               ,
                                                                                p_msg_tokens        => l_msg_tokens             ,
                                                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                                p_run_log_level     => l_log_level
                                                                                );
                                                        l_index1 := p_serial_num_tbl.next(l_index1);
                                                END LOOP;
                                        END IF;

                                        l_stmt_num := 142;
                                        l_new_count := p_serial_num_tbl.count;

                                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                                        p_msg_text          => 'Total Serial Numbers : Old count : ' || l_old_count
                                                                                                || ' New Count (After Derivation) : '|| l_new_count,
                                                                        p_stmt_num          => l_stmt_num               ,
                                                                        p_msg_tokens        => l_msg_tokens             ,
                                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                        p_run_log_level     => l_log_level
                                                                        );
                                        END IF;

                                        -- Update the count...
                                        l_job_ser_info_tbl(l_curr_job_name).l_count := l_job_ser_info_tbl(l_curr_job_name).l_count + (l_new_count - l_old_count);

                                ELSIF (l_filling_job_name IS NOT NULL)
                                THEN
                                        -- Already encountered....
                                        -- error out...
                                        l_stmt_num := 142;
                                        IF g_log_level_error >= l_log_level OR
                                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                        THEN
                                                l_msg_tokens.delete;
                                                l_msg_tokens(1).TokenName := 'JOB';
                                                l_msg_tokens(1).TokenValue := p_resulting_jobs_tbl(l_index).wip_entity_name;
                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                       p_msg_name           => 'WSM_SPLIT_SERIAL_INSUFF',
                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                       p_stmt_num           => l_stmt_num               ,
                                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                       p_run_log_level      => l_log_level
                                                                      );
                                        END IF;
                                        RAISE FND_API.G_EXC_ERROR;
                                END IF;

                        END IF;

                        l_index := p_resulting_jobs_tbl.next(l_index);

                end loop;

                l_stmt_num := 143;
                -- ok now validate the total qty..
                IF l_parent_as_resjob IS NOT NULL THEN
                        l_stmt_num := 144;
                        -- Indicates that the starting job is also a res. job...
                        if (l_serial_num_count - p_serial_num_tbl.count) > p_resulting_jobs_tbl(l_parent_as_resjob).start_quantity then

                                l_stmt_num := 145;
                                -- error out...
                                -- Possible that we dont add serial numbers for a parent job that is not serial tracked...
                                -- This happens when the total no. of serial numbers is less than the available qty..
                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN
                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'JOB';
                                        l_msg_tokens(1).TokenValue := p_resulting_jobs_tbl(l_parent_as_resjob).wip_entity_name;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_INVALID_SERIAL_QTY1',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        end if;

                ELSE
                        -- Indicates that the starting job is not a res. job...
                        IF l_serial_num_count <> p_serial_num_tbl.count then
                                l_stmt_num := 146;
                                -- error out...
                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_SPLIT_SERIAL_INFO_REQ',
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        end if;
                end if;

                l_stmt_num := 147;
                -- Now begin the actual processing....
                l_index := p_resulting_jobs_tbl.first;

                while l_index is not null loop

                        IF p_resulting_jobs_tbl(l_index).wip_entity_name = l_wip_entity_name then
                                l_start_as_res_job := 1;
                        ELSE
                                l_start_as_res_job := 0;
                        END IF;

                        l_stmt_num := 148;
                        -- if SpUA then
                        if p_resulting_jobs_tbl(l_index).split_has_update_assy = 1 then

                                -- During split transaction.. user can provide attributes' information...
                                if l_update_serial_attr = 1 then
                                        -- get the context of the new assembly if no context/different from the existing context then
                                        -- populate message about the serial attributes being cleared...
                                        l_stmt_num := 149;
                                        l_child_job_ser_context := null;

                                        INV_LOT_SEL_ATTR.get_context_code ( context_value => l_child_job_ser_context,
                                                                            org_id        => p_organization_id  ,
                                                                            item_id       => p_resulting_jobs_tbl(l_index).primary_item_id,
                                                                            flex_name     => 'Serial Attributes'
                                                                          );

                                        IF nvl(l_child_job_ser_context,'&&##') <> nvl(l_parent_job_ser_context,'&&##') then
                                                -- populate a error message saying that the attributes will be cleared...
                                                IF g_log_level_exception >= l_log_level OR
                                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_DEBUG_HIGH)
                                                THEN

                                                        l_msg_tokens.delete;
                                                        l_msg_tokens(1).TokenName := 'JOB';
                                                        l_msg_tokens(1).TokenValue := p_resulting_jobs_tbl(l_index).wip_entity_name;

                                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                               p_msg_name           => 'WSM_SERIAL_CLEAR_ATTR'  ,
                                                                               p_msg_appl_name      => 'WSM'                    ,
                                                                               p_msg_tokens         => l_msg_tokens             ,
                                                                               p_fnd_msg_level      => G_MSG_LVL_SUCCESS        ,
                                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                               p_run_log_level      => l_log_level              ,
                                                                               p_wsm_warning        => 1
                                                                              );
                                                END IF;
                                                l_clear_serial_attr := 1;
                                        else
                                                l_clear_serial_attr := 0;
                                        end if;
                                end if; -- end l_update_serial_attr = 1

                                l_stmt_num := 150;
                                l_index1 := l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name).l_index_start;

                                IF l_serial_start_flag IS NOT NULL THEN
                                        -- Indicates that serial tracking hasnt begun
                                        l_temp_op_seq_num := l_curr_job_op_seq_num + l_op_seq_incr;
                                        l_temp_op_step    := WIP_CONSTANTS.QUEUE;
                                ELSE
                                        l_temp_op_seq_num := NULL;
                                        l_temp_op_step    := NULL;
                                END IF;


                                while l_index1 < (l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name).l_index_start +
                                                 l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name).l_count)
                                loop
                                        l_stmt_num := 151;

                                        -- call to update the serial number with the new wip_entity_id
                                        if (l_start_as_res_job = 0)
                                        then
                                                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                                        l_msg_tokens.delete;
                                                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                                                p_msg_text          => 'Job Name : ' || p_resulting_jobs_tbl(l_index).wip_entity_name
                                                                                                        || 'Serial number : ' || p_serial_num_tbl(l_index1).serial_number,
                                                                                p_stmt_num          => l_stmt_num               ,
                                                                                p_msg_tokens        => l_msg_tokens             ,
                                                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                                p_run_log_level     => l_log_level
                                                                                );
                                                END IF;

                                                update_serial (  p_serial_number                => p_serial_num_tbl(l_index1).serial_number,
                                                                 p_inventory_item_id            => l_inventory_item_id,
                                                                 p_organization_id              => p_organization_id,
                                                                 p_wip_entity_id                => p_resulting_jobs_tbl(l_index).wip_entity_id,
                                                                 p_operation_seq_num            => l_temp_op_seq_num,
                                                                 p_intraoperation_step_type     => l_temp_op_step,
                                                                 x_return_status                => x_return_status,
                                                                 x_error_msg                    => x_error_msg  ,
                                                                 x_error_count                  => x_error_count
                                                              );

                                                if x_return_status <> G_RET_SUCCESS then
                                                        IF x_return_status = G_RET_ERROR THEN
                                                                raise FND_API.G_EXC_ERROR;
                                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                                        END IF;
                                                end if;

                                        end if;

                                        l_stmt_num := 152;

                                        -- Update the attributes only if they arent going to be cleared by the INV API..
                                        -- and also We'll have to ensure that this procedure gets invoked only for the serials given by the user...
                                        -- For all those records header_id will be populated..
                                        -- But for the records that the code derives, header_id will be NULL :)

                                        IF l_clear_serial_attr = 0 and p_serial_num_tbl(l_index1).header_id IS NOT NULL THEN
                                                update_serial_attr ( p_calling_mode             =>  p_calling_mode              ,
                                                                     p_serial_number_rec        =>  p_serial_num_tbl(l_index1)  ,
                                                                     p_inventory_item_id        =>  l_inventory_item_id         ,
                                                                     p_organization_id          =>  p_organization_id           ,
                                                                     p_clear_serial_attr        =>  l_clear_serial_attr         ,
                                                                     p_wlt_txn_type             =>  WSMPCNST.SPLIT              ,
                                                                     p_update_serial_attr       =>  l_update_serial_attr        ,
                                                                     p_update_desc_attr         =>  1                           ,
                                                                     p_serial_attr_context      =>  l_child_job_ser_context     ,
                                                                     x_return_status            =>  x_return_status             ,
                                                                     x_error_count              =>  x_error_count               ,
                                                                     x_error_msg                =>  x_error_msg
                                                                   );

                                                if x_return_status <> G_RET_SUCCESS then
                                                        IF x_return_status = G_RET_ERROR THEN
                                                                raise FND_API.G_EXC_ERROR;
                                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                                        END IF;
                                                end if;
                                        END IF;

                                        l_index1 := l_index1 + 1;

                                end loop;

                                -- Now call the new API proposed by the INV team that will update all the serial numbers linked
                                -- with a particular job with new inventory item
                                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                                p_msg_text          => 'Invoking INV_LOT_TRX_VALIDATION_PUB.update_item_serial',
                                                                p_stmt_num          => l_stmt_num               ,
                                                                p_msg_tokens        => l_msg_tokens             ,
                                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                p_run_log_level     => l_log_level
                                                                );
                                END IF;

                                INV_LOT_TRX_VALIDATION_PUB.update_item_serial( x_msg_count                      => x_error_count                                    ,
                                                                               x_return_status                  => x_return_status                                  ,
                                                                               x_msg_data                       => x_error_msg                                      ,
                                                                               x_validation_status              => l_validation_status                              ,
                                                                               p_org_id                         => p_organization_id                                ,
                                                                               p_item_id                        => l_inventory_item_id                              ,
                                                                               p_to_item_id                     => p_resulting_jobs_tbl(l_index).primary_item_id  ,
                                                                               p_wip_entity_id                  => p_resulting_jobs_tbl(l_index).wip_entity_id      ,
                                                                               p_to_wip_entity_id               => p_resulting_jobs_tbl(l_index).wip_entity_id      ,
                                                                               p_to_operation_sequence          => l_temp_op_seq_num                                ,
                                                                               p_intraoperation_step_type       => l_temp_op_step
                                                                              );

                                if x_return_status <> G_RET_SUCCESS then
                                        IF x_return_status = G_RET_ERROR THEN
                                                raise FND_API.G_EXC_ERROR;
                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                                end if;

                        else
                                -- No Update of assembly for this job...
                                l_stmt_num := 153;
                                -- update the serial number .. basically just linking it with the new job...
                                -- start_index and count already present .. just loop through...
                                l_index1 := l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name).l_index_start;

                                while l_index1 < (l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name).l_index_start +
                                                 l_job_ser_info_tbl(p_resulting_jobs_tbl(l_index).wip_entity_name).l_count)
                                loop

                                        -- call to update the serial number...
                                        -- call to update the serial number with the new wip_entity_id ...
                                        if l_start_as_res_job = 0 then
                                                l_stmt_num := 154;
                                                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                                        l_msg_tokens.delete;
                                                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                                                p_msg_text          => 'Job Name : ' || p_resulting_jobs_tbl(l_index).wip_entity_name
                                                                                                        || 'Serial number : ' || p_serial_num_tbl(l_index1).serial_number,
                                                                                p_stmt_num          => l_stmt_num               ,
                                                                                p_msg_tokens        => l_msg_tokens             ,
                                                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                                p_run_log_level     => l_log_level
                                                                                );
                                                END IF;

                                                update_serial (  p_serial_number                => p_serial_num_tbl(l_index1).serial_number     ,
                                                                 p_inventory_item_id            => l_inventory_item_id                          ,
                                                                 p_organization_id              => p_organization_id                            ,
                                                                 p_wip_entity_id                => p_resulting_jobs_tbl(l_index).wip_entity_id  ,
                                                                 p_operation_seq_num            => l_curr_job_op_seq_num                        ,
                                                                 p_intraoperation_step_type     => l_curr_job_op_step                           ,
                                                                 x_return_status                => x_return_status                              ,
                                                                 x_error_msg                    => x_error_msg                                  ,
                                                                 x_error_count                  => x_error_count
                                                              );

                                                if x_return_status <> G_RET_SUCCESS then
                                                        IF x_return_status = G_RET_ERROR THEN
                                                                raise FND_API.G_EXC_ERROR;
                                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                                        END IF;
                                                end if;
                                        end if;

                                        -- We'll have to ensure that this procedure gets invoked only for the serials given by the user...
                                        -- For all those records header_id will be populated..
                                        -- But for the records that the code derives, header_id will be NULL :)
                                        IF p_serial_num_tbl(l_index1).header_id IS NOT NULL THEN
                                                l_stmt_num := 156;
                                                update_serial_attr ( p_calling_mode             =>  p_calling_mode              ,
                                                                     p_serial_number_rec        =>  p_serial_num_tbl(l_index1)  ,
                                                                     p_inventory_item_id        =>  l_inventory_item_id         ,
                                                                     p_organization_id          =>  p_organization_id           ,
                                                                     p_clear_serial_attr        =>  l_clear_serial_attr         ,
                                                                     p_wlt_txn_type             =>  WSMPCNST.SPLIT              ,
                                                                     p_update_serial_attr       =>  l_update_serial_attr        ,
                                                                     p_update_desc_attr         =>  1                           ,
                                                                     x_return_status            =>  x_return_status             ,
                                                                     x_error_count              =>  x_error_count               ,
                                                                     x_error_msg                =>  x_error_msg
                                                                   );
                                                if x_return_status <> G_RET_SUCCESS then
                                                        IF x_return_status = G_RET_ERROR THEN
                                                                raise FND_API.G_EXC_ERROR;
                                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                                        END IF;
                                                end if;
                                        END IF;

                                        l_index1 := l_index1 + 1;

                                end loop;
                        end if;

                        l_index := p_resulting_jobs_tbl.next(l_index);

                end loop;

                l_stmt_num := 157;
                -- Insert all the serial numbers present to the WSM_SERIAL_TRANSACTIONS table...
                insert into wsm_serial_transactions
                (transaction_id                          ,
                 transaction_type_id                     ,
                 serial_number                           ,
                 gen_object_id                           ,
                 current_wip_entity_name                 ,
                 changed_wip_entity_name                 ,
                 current_wip_entity_id                   ,
                 changed_wip_entity_id                   ,
                 created_by                              ,
                 last_update_date                        ,
                 last_updated_by                         ,
                 creation_date                           ,
                 last_update_login                       ,
                 request_id                              ,
                 program_application_id                  ,
                 program_id                              ,
                 program_update_date                     ,
                 original_system_reference
                )
                select
                 p_txn_id                                ,
                 3                                       ,
                 MSN.serial_number                       ,
                 MSN.gen_object_id                       ,
                 WSSJ.wip_entity_name                    ,
                 WSRJ.wip_entity_name                    ,
                 WSSJ.wip_entity_id                      ,
                 WSRJ.wip_entity_id                      ,
                 g_user_id                               ,
                 sysdate                                 ,
                 g_user_id                               ,
                 sysdate                                 ,
                 g_user_login_id                         ,
                 g_request_id                            ,
                 g_program_appl_id                       ,
                 g_program_id                            ,
                 sysdate                                 ,
                 null
                from mtl_serial_numbers MSN             ,
                     wsm_sm_starting_jobs WSSJ          ,
                     wsm_sm_resulting_jobs WSRJ
                where MSN.current_organization_id = p_organization_id
                and   MSN.inventory_item_id = WSRJ.primary_item_id
                and   WSSJ.transaction_id = p_txn_id
                and   WSRJ.transaction_id = p_txn_id
                and   MSN.wip_entity_id = WSRJ.wip_entity_id
                and   nvl(MSN.intraoperation_step_type,-1) <> 5;

                -- If the parent is serial tracked then all child jobs will also be serial tracked...
                IF l_serial_start_flag IS NOT NULL THEN
                        update wip_discrete_jobs
                        set    serialization_start_op = 10
                        where  wip_entity_id in (select wip_entity_id
                                                 from wsm_sm_resulting_jobs
                                                 where transaction_id = p_txn_id);

                        -- We set the first_serial_txn_id as a non-NULL value as some code depends on it.. in Move
                        update wsm_lot_based_jobs
                        set    first_serial_txn_id = -1
                        where  wip_entity_id in (select wip_entity_id
                                                 from wsm_sm_resulting_jobs
                                                 where transaction_id = p_txn_id);

                END IF;

        ELSIF p_wlt_txn_type = WSMPCNST.MERGE THEN -- Merge  transaction

                l_stmt_num := 160;
                -- Now the main processing part starts...
                if g_wms_installed IS NULL THEN

                        wms_installed ( x_return_status   =>  x_return_status   ,
                                        x_error_count     =>  x_error_count     ,
                                        x_err_data        =>  x_error_msg
                                      );

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;
                end if;

                l_stmt_num := 165;
                IF g_wms_installed = 1 then

                        l_parent_job_ser_context := null;

                        INV_LOT_SEL_ATTR.get_context_code ( context_value => l_parent_job_ser_context,
                                                            org_id        => p_organization_id  ,
                                                            item_id       => p_starting_jobs_tbl(l_rep_job_index).primary_item_id,
                                                            flex_name     => 'Serial Attributes'
                                                          );
                END IF;

                l_stmt_num := 170;
                -- Insert into the WSM table here itself....
                insert into wsm_serial_transactions
                (transaction_id                          ,
                 transaction_type_id                     ,
                 serial_number                           ,
                 gen_object_id                           ,
                 current_wip_entity_name                        ,
                 changed_wip_entity_name                        ,
                 current_wip_entity_id                   ,
                 changed_wip_entity_id                   ,
                 created_by                              ,
                 last_update_date                        ,
                 last_updated_by                         ,
                 creation_date                           ,
                 last_update_login                       ,
                 request_id                              ,
                 program_application_id                  ,
                 program_id                              ,
                 program_update_date                     ,
                 original_system_reference
                )
                select
                 p_txn_id                                ,
                 3                                       ,
                 MSN.serial_number                       ,
                 MSN.gen_object_id                       ,
                 WSSJ.wip_entity_name                    ,
                 WSRJ.wip_entity_name                    ,
                 WSSJ.wip_entity_id                      ,
                 WSRJ.wip_entity_id                      ,
                 g_user_id                               ,
                 sysdate                                 ,
                 g_user_id                               ,
                 sysdate                                 ,
                 g_user_login_id                         ,
                 g_request_id                            ,
                 g_program_appl_id                       ,
                 g_program_id                            ,
                 sysdate                                 ,
                 null
                from mtl_serial_numbers MSN             ,
                     wsm_sm_starting_jobs WSSJ          ,
                     wsm_sm_resulting_jobs WSRJ
                where MSN.current_organization_id = p_organization_id
                and   MSN.inventory_item_id = WSSJ.primary_item_id
                and   WSSJ.transaction_id = p_txn_id
                and   WSRJ.transaction_id = p_txn_id
                and   MSN.wip_entity_id = WSSJ.wip_entity_id
                and   nvl(MSN.intraoperation_step_type,-1) <> 5;

                l_stmt_num := 180;
                -- Start the processing....
                l_index := p_starting_jobs_tbl.first;

                while l_index is not null loop

                        -- ST : Fix for bug 5161024 --
                        -- Don't l_inventory_item_id as it contains the rep job data...
                        -- l_inventory_item_id   := p_starting_jobs_tbl(l_index).primary_item_id;

                        if l_index <> l_rep_job_index then
                                l_stmt_num := 190;

                                -- ok check the context..
                                IF g_wms_installed = 1 THEN     -- WMS installed,,
                                        -- first check is to see the item id....
                                        if p_starting_jobs_tbl(l_index).primary_item_id <> p_resulting_jobs_tbl(p_resulting_jobs_tbl.first).primary_item_id then
                                                -- have to check the context and populate the warning message...
                                                l_context := null;
                                                INV_LOT_SEL_ATTR.get_context_code ( context_value => l_context                                    ,
                                                                                    org_id        => p_organization_id                            ,
                                                                                    item_id       => p_starting_jobs_tbl(l_index).primary_item_id ,
                                                                                                  -- ST : Fix for bug 5161024 : l_inventory_item_id ,
                                                                                    flex_name     => 'Serial Attributes'
                                                                                  );

                                                if nvl(l_context,'&&##') <> nvl(l_parent_job_ser_context,'&&##') THEN
                                                        -- populate a warning message...
                                                        IF g_log_level_exception >= l_log_level OR
                                                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_DEBUG_HIGH)
                                                        THEN

                                                                l_msg_tokens.delete;
                                                                l_msg_tokens(1).TokenName := 'JOB';
                                                                l_msg_tokens(1).TokenValue := p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_name;

                                                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                                                       p_msg_name           => 'WSM_SERIAL_CLEAR_ATTR'  ,
                                                                                       p_msg_appl_name      => 'WSM'                    ,
                                                                                       p_msg_tokens         => l_msg_tokens             ,
                                                                                       p_fnd_msg_level      => G_MSG_LVL_SUCCESS        ,
                                                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                                                       p_run_log_level      => l_log_level              ,
                                                                                       p_wsm_warning        => 1
                                                                                      );
                                                        END IF;
                                                end if;
                                        end if;
                                END IF;

                                l_stmt_num := 195;
                                --  invoke the mail INV API to update the wip entity id, item and op information....
                                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                                p_msg_text          => 'Invoking INV_LOT_TRX_VALIDATION_PUB.update_item_serial : for Res wip_entity_id ' || p_resulting_jobs_tbl(p_resulting_jobs_tbl.first).wip_entity_id,
                                                                p_stmt_num          => l_stmt_num               ,
                                                                p_msg_tokens        => l_msg_tokens             ,
                                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                p_run_log_level     => l_log_level
                                                                );
                                END IF;

                                INV_LOT_TRX_VALIDATION_PUB.update_item_serial( x_msg_count                      => x_error_count                                    ,
                                                                               x_return_status                  => x_return_status                                  ,
                                                                               x_msg_data                       => x_error_msg                                      ,
                                                                               x_validation_status              => l_validation_status                              ,
                                                                               p_org_id                         => p_organization_id                                ,
                                                                               p_item_id                        => p_starting_jobs_tbl(l_index).primary_item_id     ,
                                                                               p_to_item_id                     => l_inventory_item_id                              ,
                                                                               p_wip_entity_id                  => p_starting_jobs_tbl(l_index).wip_entity_id       ,
                                                                               p_to_wip_entity_id               => p_resulting_jobs_tbl(p_resulting_jobs_tbl.first).wip_entity_id,
                                                                               p_to_operation_sequence          => l_curr_job_op_seq_num                            ,
                                                                               p_intraoperation_step_type       => l_curr_job_op_step
                                                                              );

                                if x_return_status <> G_RET_SUCCESS then
                                        IF x_return_status = G_RET_ERROR THEN
                                                raise FND_API.G_EXC_ERROR;
                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                                END IF;
                        ELSE
                                l_stmt_num := 200;
                                -- ok the rep job..
                                -- Now the important thing is that check for the job name, if different,
                                -- a new job would have been created and will have to link the serial numbers to it,.,
                                -- or else no problems
                                IF p_resulting_jobs_tbl(p_resulting_jobs_tbl.first).wip_entity_name <> p_starting_jobs_tbl(l_rep_job_index).wip_entity_name THEN
                                        -- In this case invoke the new INV API procedure...
                                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                                l_msg_tokens.delete;
                                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                                        p_msg_text          => 'Invoking INV_LOT_TRX_VALIDATION_PUB.update_item_serial',
                                                                        p_stmt_num          => l_stmt_num               ,
                                                                        p_msg_tokens        => l_msg_tokens             ,
                                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                                        p_run_log_level     => l_log_level
                                                                        );
                                        END IF;

                                        INV_LOT_TRX_VALIDATION_PUB.update_item_serial( x_msg_count                      => x_error_count                                    ,
                                                                                       x_return_status                  => x_return_status                                  ,
                                                                                       x_msg_data                       => x_error_msg                                      ,
                                                                                       x_validation_status              => l_validation_status                              ,
                                                                                       p_org_id                         => p_organization_id                                ,
                                                                                       p_item_id                        => l_inventory_item_id                              ,
                                                                                       p_to_item_id                     => l_inventory_item_id                              ,
                                                                                       p_wip_entity_id                  => l_wip_entity_id                                  ,
                                                                                       p_to_wip_entity_id               => p_resulting_jobs_tbl(p_resulting_jobs_tbl.first).wip_entity_id,
                                                                                       p_to_operation_sequence          => l_curr_job_op_seq_num                            ,
                                                                                       p_intraoperation_step_type       => l_curr_job_op_step
                                                                                     );

                                        IF x_return_status <> G_RET_SUCCESS THEN
                                                IF x_return_status = G_RET_ERROR THEN
                                                        raise FND_API.G_EXC_ERROR;
                                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                                END IF;
                                        END IF;

                                        -- If the parent is serial tracked then all child jobs will also be serial tracked...
                                        IF l_serial_start_flag IS NOT NULL THEN
                                                update wip_discrete_jobs
                                                set    serialization_start_op = 10
                                                where  wip_entity_id in (select wip_entity_id
                                                                         from wsm_sm_resulting_jobs
                                                                         where transaction_id = p_txn_id);

                                                -- We set the first_serial_txn_id to NULL as some code depends on it.. in Move
                                                update wsm_lot_based_jobs
                                                set    first_serial_txn_id = -1
                                                where  wip_entity_id in (select wip_entity_id
                                                                         from wsm_sm_resulting_jobs
                                                                         where transaction_id = p_txn_id);
                                        END IF;
                                END IF;

                        END IF;

                        l_index := p_starting_jobs_tbl.next(l_index);

                END LOOP;

        ELSIF p_wlt_txn_type = WSMPCNST.UPDATE_ASSEMBLY THEN -- Update Assembly transaction

                l_stmt_num := 210;
                -- Now the main processing part starts...
                if g_wms_installed IS NULL THEN

                        wms_installed ( x_return_status   =>  x_return_status   ,
                                        x_error_count   =>  x_error_count   ,
                                        x_err_data      =>  x_error_msg
                                      );

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;
                end if;

                l_stmt_num := 220;
                IF g_wms_installed = 1 then

                        l_parent_job_ser_context := null;

                        INV_LOT_SEL_ATTR.get_context_code ( context_value => l_parent_job_ser_context                                      ,
                                                            org_id        => p_organization_id                                             ,
                                                            item_id       => p_starting_jobs_tbl(p_starting_jobs_tbl.first).primary_item_id,
                                                            flex_name     => 'Serial Attributes'
                                                          );
                        l_context := null;

                        INV_LOT_SEL_ATTR.get_context_code ( context_value => l_context          ,
                                                            org_id        => p_organization_id  ,
                                                            item_id       => p_resulting_jobs_tbl(p_resulting_jobs_tbl.first).primary_item_id,
                                                            flex_name     => 'Serial Attributes'
                                                          );

                        --
                        if nvl(l_context,'&&##') <> nvl(l_parent_job_ser_context,'&&##') THEN
                                -- populate a warning message...
                                IF g_log_level_exception >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_DEBUG_HIGH)
                                THEN

                                        l_msg_tokens.delete;
                                        l_msg_tokens(1).TokenName := 'JOB';
                                        l_msg_tokens(1).TokenValue := p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_name;

                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_SERIAL_CLEAR_ATTR'  ,
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_fnd_msg_level      => G_MSG_LVL_SUCCESS        ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level              ,
                                                               p_wsm_warning        => 1
                                                              );
                                END IF;

                                -- Clearing of the serial attributes will be taken care by the INV API being called..
                        end if;
                END IF;

                l_stmt_num := 230;
                -- Invoke the new INV API procedure...
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking INV_LOT_TRX_VALIDATION_PUB.update_item_serial',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                INV_LOT_TRX_VALIDATION_PUB.update_item_serial( x_msg_count                      => x_error_count                                    ,
                                                               x_return_status                  => x_return_status                                  ,
                                                               x_msg_data                       => x_error_msg                                      ,
                                                               x_validation_status              => l_validation_status                              ,
                                                               p_org_id                         => p_organization_id                                ,
                                                               p_item_id                        => l_inventory_item_id                              ,
                                                               p_to_item_id                     => p_resulting_jobs_tbl(p_resulting_jobs_tbl.first).primary_item_id  ,
                                                               p_wip_entity_id                  => l_wip_entity_id                                  ,
                                                               p_to_wip_entity_id               => l_wip_entity_id                                  ,
                                                               p_to_operation_sequence          => l_curr_job_op_seq_num                            ,
                                                               p_intraoperation_step_type       => l_curr_job_op_step
                                                             );

                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;

                l_stmt_num := 240;
                Insert_into_WST (   p_transaction_id             =>  p_txn_id                                                          ,
                                    p_transaction_type_id        =>  WSMPCNST.UPDATE_ASSEMBLY                                          ,
                                    p_old_wip_entity_name        =>  p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_name    ,
                                    p_new_wip_entity_name        =>  p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_name    ,
                                    p_wip_entity_id              =>  p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_id      ,
                                    p_organization_id            =>  p_organization_id                                                 ,
                                    p_item_id                    =>  p_resulting_jobs_tbl(p_resulting_jobs_tbl.first).primary_item_id  ,
                                    x_return_status              =>  x_return_status                                                   ,
                                    x_error_msg                  =>  x_error_msg                                                       ,
                                    x_error_count                =>  x_error_count
                                );

                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;

        ELSIF p_wlt_txn_type = WSMPCNST.UPDATE_ROUTING THEN -- Update Routing transaction

                l_stmt_num := 250;

                -- Invoke the new INV API procedure...
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking INV_LOT_TRX_VALIDATION_PUB.update_item_serial',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                INV_LOT_TRX_VALIDATION_PUB.update_item_serial( x_msg_count                      => x_error_count                                    ,
                                                               x_return_status                  => x_return_status                                  ,
                                                               x_msg_data                       => x_error_msg                                      ,
                                                               x_validation_status              => l_validation_status                              ,
                                                               p_org_id                         => p_organization_id                                ,
                                                               p_item_id                        => l_inventory_item_id                              ,
                                                               p_to_item_id                     => l_inventory_item_id                              ,
                                                               p_wip_entity_id                  => l_wip_entity_id                                  ,
                                                               p_to_wip_entity_id               => l_wip_entity_id                                  ,
                                                               p_to_operation_sequence          => l_curr_job_op_seq_num                            ,
                                                               p_intraoperation_step_type       => l_curr_job_op_step
                                                              );

                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;

                l_stmt_num := 260;
                -- Invoke the call to insert into the new table...
                Insert_into_WST (   p_transaction_id             =>  p_txn_id                                                          ,
                                    p_transaction_type_id        =>  WSMPCNST.UPDATE_ROUTING                                           ,
                                    p_old_wip_entity_name        =>  p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_name    ,
                                    p_new_wip_entity_name        =>  p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_name    ,
                                    p_wip_entity_id              =>  p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_id      ,
                                    p_organization_id            =>  p_organization_id                                                 ,
                                    p_item_id                    =>  l_inventory_item_id                                               ,
                                    x_return_status              =>  x_return_status                                                   ,
                                    x_error_msg                  =>  x_error_msg                                                       ,
                                    x_error_count                =>  x_error_count
                                );

                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;

        ELSIF p_wlt_txn_type = WSMPCNST.UPDATE_LOT_NAME THEN -- Update Lot Name transaction

                l_stmt_num := 270;
                Insert_into_WST (   p_transaction_id             =>  p_txn_id                                                          ,
                                    p_transaction_type_id        =>  WSMPCNST.UPDATE_ROUTING                                           ,
                                    p_old_wip_entity_name        =>  p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_name    ,
                                    p_new_wip_entity_name        =>  p_resulting_jobs_tbl(p_resulting_jobs_tbl.first).wip_entity_name  ,
                                    p_wip_entity_id              =>  p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_id      ,
                                    p_organization_id            =>  p_organization_id                                                 ,
                                    p_item_id                    =>  l_inventory_item_id                                               ,
                                    x_return_status              =>  x_return_status                                                   ,
                                    x_error_msg                  =>  x_error_msg                                                       ,
                                    x_error_count                =>  x_error_count
                                );

                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;

        ELSIF p_wlt_txn_type = WSMPCNST.UPDATE_QUANTITY THEN -- Update Quantity transaction

                l_stmt_num := 280;
                IF l_serial_start_flag IS NULL then

                        l_stmt_num := 290;
                        IF p_serial_num_tbl.count > 0 THEN
                                -- error out...
                                IF g_log_level_error >= l_log_level OR
                                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                                THEN

                                        l_msg_tokens.delete;
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_name           => 'WSM_UPD_QTY_REC_IGNORE' ,
                                                               p_msg_appl_name      => 'WSM'                    ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        ELSE
                                -- ST : Fix for bug 5143373
                                -- Insert the existing serials...
                                Insert_into_WST (   p_transaction_id             =>  p_txn_id                                                          ,
                                                    p_transaction_type_id        =>  WSMPCNST.UPDATE_QUANTITY                                          ,
                                                    p_old_wip_entity_name        =>  p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_name    ,
                                                    p_new_wip_entity_name        =>  p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_name    ,
                                                    p_wip_entity_id              =>  p_starting_jobs_tbl(p_starting_jobs_tbl.first).wip_entity_id      ,
                                                    p_organization_id            =>  p_organization_id                                                 ,
                                                    p_item_id                    =>  p_resulting_jobs_tbl(p_resulting_jobs_tbl.first).primary_item_id  ,
                                                    x_return_status              =>  x_return_status                                                   ,
                                                    x_error_msg                  =>  x_error_msg                                                       ,
                                                    x_error_count                =>  x_error_count
                                                );

                                if x_return_status <> G_RET_SUCCESS then
                                        IF x_return_status = G_RET_ERROR THEN
                                                raise FND_API.G_EXC_ERROR;
                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                                end if;
                                -- ST : Fix for bug 5143373 end --
                                return;
                        END IF;
                END IF;

                l_stmt_num := 300;
                -- You will have records only thru the interface..
                -- Forms will be handled in the code itself ...
                -- Also records will be considered only for a serial tracked job...
                -- invoke process_serial_info
                IF p_serial_num_tbl.count > 0 THEN
                        process_serial_info( p_calling_mode        => p_calling_mode            ,
                                             p_wsm_serial_nums_tbl => p_serial_num_tbl          ,
                                             p_wip_entity_id       => l_wip_entity_id           ,
                                             p_serial_start_flag   => l_serial_start_flag       ,
                                             p_organization_id     => p_organization_id         ,
                                             p_item_id             => l_inventory_item_id       ,
                                             p_wlt_upd_qty_txn     => 1                         ,
                                             p_operation_seq_num   => l_curr_job_op_seq_num     ,
                                             p_intraoperation_step => l_curr_job_op_step        ,
                                             x_serial_tbl          => l_serial_tbl              ,
                                             x_return_status       => x_return_status           ,
                                             x_error_msg           => x_error_msg               ,
                                             x_error_count         => x_error_count
                                           );

                        l_stmt_num := 320;
                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;
                END IF;

                l_stmt_num := 330;
                select count(*)
                into   l_serial_num_count
                -- ST : Fix for bug 4910758 (remove usage of wsm_job_serial_numbers_v)
                -- from wsm_job_serial_numbers_v
                from   mtl_serial_numbers
                where  inventory_item_id = l_inventory_item_id
                and    wip_entity_id = l_wip_entity_id
                and    nvl(intraoperation_step_type,-1) <> 5;

                l_stmt_num := 340;

                IF l_serial_num_count <> p_resulting_jobs_tbl(p_resulting_jobs_tbl.first).start_quantity then
                        -- error out..
                        IF g_log_level_error >= l_log_level OR
                           FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                        THEN

                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage(p_module_name        => l_module                      ,
                                                       p_msg_name           => 'WSM_INVALID_SERIAL_TRACK_QTY',
                                                       p_msg_appl_name      => 'WSM'                    ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                                       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                                       p_run_log_level      => l_log_level
                                                      );
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                l_stmt_num := 350;

                IF l_serial_tbl.count > 0 THEN
                        -- Insert the new serial numbers...
                        forall l_cntr IN l_serial_tbl.first..l_serial_tbl.last
                                insert into wsm_serial_transactions
                                (transaction_id                          ,
                                 transaction_type_id                     ,
                                 serial_number                           ,
                                 gen_object_id                           ,
                                 current_wip_entity_name                 ,
                                 changed_wip_entity_name                 ,
                                 current_wip_entity_id                   ,
                                 changed_wip_entity_id                   ,
                                 created_by                              ,
                                 last_update_date                        ,
                                 last_updated_by                         ,
                                 creation_date                           ,
                                 last_update_login                       ,
                                 request_id                              ,
                                 program_application_id                  ,
                                 program_id                              ,
                                 program_update_date                     ,
                                 original_system_reference
                                )
                                select
                                 p_txn_id                               ,
                                 3                                      ,
                                 l_serial_tbl(l_cntr)                   ,
                                 gen_object_id                          ,
                                 null                                   ,
                                 l_wip_entity_name                      ,
                                 null                                   ,
                                 l_wip_entity_id                        ,
                                 g_user_id                               ,
                                 sysdate                                 ,
                                 g_user_id                               ,
                                 sysdate                                 ,
                                 g_user_login_id                         ,
                                 g_request_id                            ,
                                 g_program_appl_id                       ,
                                 g_program_id                            ,
                                 sysdate                                 ,
                                 null
                                 from mtl_serial_numbers
                                 where serial_number = l_serial_tbl(l_cntr)
                                 and   inventory_item_id = l_inventory_item_id
                                 and   current_organization_id = p_organization_id;
                END IF;

                -- Insert the old serial numbers...
                IF l_serial_num_count > 0 THEN
                        -- Insert...
                        insert into wsm_serial_transactions
                        (transaction_id                          ,
                         transaction_type_id                     ,
                         serial_number                           ,
                         gen_object_id                           ,
                         current_wip_entity_name                 ,
                         current_wip_entity_id                   ,
                         changed_wip_entity_name                 ,
                         changed_wip_entity_id                   ,
                         created_by                              ,
                         last_update_date                        ,
                         last_updated_by                         ,
                         creation_date                           ,
                         last_update_login                       ,
                         request_id                              ,
                         program_application_id                  ,
                         program_id                              ,
                         program_update_date                     ,
                         original_system_reference
                        )
                        select
                         p_txn_id                               ,
                         3                                      ,
                         serial_number                          ,
                         gen_object_id                          ,
                         l_wip_entity_name                      ,
                         l_wip_entity_id                        ,
                         l_wip_entity_name                      ,
                         l_wip_entity_id                        ,
                         g_user_id                              ,
                         sysdate                                ,
                         g_user_id                              ,
                         sysdate                                ,
                         g_user_login_id                        ,
                         g_request_id                           ,
                         g_program_appl_id                      ,
                         g_program_id                           ,
                         sysdate                                ,
                         null
                         from mtl_serial_numbers
                         where inventory_item_id = l_inventory_item_id
                         and   current_organization_id = p_organization_id
                         and   wip_entity_id = l_wip_entity_id
                         and   nvl(intraoperation_step_type,-1) <> 5
                         and   serial_number NOT IN (select serial_number
                                                     from wsm_serial_transactions
                                                     where transaction_type_id = 3
                                                     and   transaction_id = p_txn_id);
                END IF;

        END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK to WLT_serial_proc;
                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK to WLT_serial_proc;
                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN
                 ROLLBACK to WLT_serial_proc;
                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                 THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                 END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

END WLT_serial_processor;

PROCEDURE validate_qty  ( p_primary_item_id           IN        NUMBER,
                          p_organization_id           IN        NUMBER,
                          p_primary_qty               IN        NUMBER,
                          p_net_qty                   IN        NUMBER,
                          p_primary_uom               IN        VARCHAR2,
                          p_transaction_qty           IN        NUMBER  DEFAULT NULL,
                          p_transaction_uom           IN        VARCHAR2 DEFAULT NULL,
                          x_return_status             OUT NOCOPY VARCHAR2,
                          x_error_count               OUT NOCOPY NUMBER,
                          x_error_msg                 OUT NOCOPY VARCHAR2
                        )

IS
        l_serial_cntrl_code NUMBER;
        l_conv_rate         NUMBER;
        l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
        l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

        l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.validate_qty';
        l_stmt_num          NUMBER;

BEGIN
        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        l_stmt_num := 10;

        IF p_primary_item_id IS NULL or p_organization_id IS NULL THEN
                return;
        END IF;

        l_stmt_num := 20;

        SELECT NVL(SERIAL_NUMBER_CONTROL_CODE,1)
        INTO   l_serial_cntrl_code
        FROM   MTL_SYSTEM_ITEMS
        WHERE  inventory_item_id = p_primary_item_id
        AND    organization_id   = p_organization_id;

        IF l_serial_cntrl_code <> 2 THEN
                return;
        END IF;

        l_stmt_num := 30;

        IF (p_primary_qty IS NOT NULL and
            floor(p_primary_qty) <> p_primary_qty)
            OR
            (p_net_qty IS NOT NULL and
             floor(p_net_qty) <> p_net_qty)
        THEN

                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_JOB_TXN_QTY',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;

        END IF;


        l_stmt_num := 50;

        IF p_transaction_qty IS NOT NULL THEN

            IF floor(p_transaction_qty) <> p_transaction_qty THEN

                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_JOB_TXN_QTY',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;

            END IF;

            l_stmt_num := 60;

            -- get the conversion rate....
            l_conv_rate :=  inv_convert.inv_um_convert(item_id          => p_primary_qty,
                                                       precision        => WIP_CONSTANTS.MAX_NUMBER_PRECISION,
                                                       from_quantity    => 1,
                                                       from_unit        => p_transaction_uom,
                                                       to_unit          => p_primary_uom,
                                                       from_name        => NULL,
                                                       to_name          => NULL);

            IF l_conv_rate = -99999 THEN

                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                   ,
                                               p_msg_name           => 'WSM_UOM_CONVERSION_FAILED',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;

            END IF;

            l_stmt_num := 70;

            IF ( floor(round(l_conv_rate * p_transaction_qty, WIP_CONSTANTS.MAX_NUMBER_PRECISION))
                 <>
                round(l_conv_rate * p_transaction_qty, WIP_CONSTANTS.MAX_NUMBER_PRECISION)
               )
            THEN

                IF g_log_level_error >= l_log_level OR
                   FND_MSG_PUB.check_msg_level(G_MSG_LVL_ERROR)
                THEN

                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                               p_msg_name           => 'WSM_INVALID_JOB_TXN_QTY',
                                               p_msg_appl_name      => 'WSM'                    ,
                                               p_msg_tokens         => l_msg_tokens             ,
                                               p_stmt_num           => l_stmt_num               ,
                                               p_fnd_msg_level      => G_MSG_LVL_ERROR          ,
                                               p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
                                               p_run_log_level      => l_log_level
                                              );
                END IF;
                RAISE FND_API.G_EXC_ERROR;

            END IF;
        END IF;

        l_stmt_num := 80;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                x_return_status := G_RET_UNEXPECTED;

                IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)               OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

END validate_qty;

-- group id on wip_move_txn_interface will be passed
Procedure Insert_move_attr ( p_group_id         IN         NUMBER       DEFAULT NULL,
                             p_move_txn_id      IN         NUMBER       DEFAULT NULL,
                             p_scrap_txn_id     IN         NUMBER       DEFAULT NULL,
                             x_return_status    OUT NOCOPY VARCHAR2,
                             x_error_count      OUT NOCOPY NUMBER,
                             x_error_msg        OUT NOCOPY VARCHAR2
                           )

IS
-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.Insert_move_attr';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        l_stmt_num := 10;

        -- This procedure is no longer used....
        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN
                l_stmt_num := 15;
                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_move_txn_id';
                l_param_tbl(1).paramValue := p_move_txn_id;

                l_param_tbl(2).paramName := 'p_scrap_txn_id';
                l_param_tbl(2).paramValue := p_scrap_txn_id;

                l_param_tbl(3).paramName := 'p_group_id';
                l_param_tbl(3).paramValue := p_group_id;


                WSM_Log_PVT.logProcParams(p_module_name         => l_module   ,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        IF p_group_id IS NOT NULL THEN

                l_stmt_num := 20;

                -- We are having a direct insert because
                -- this procedure will be invoked for a batch of move txn records each belonging to a distinct job
                insert into wsm_serial_txn_interface
                (
                 HEADER_ID                              ,
                 TRANSACTION_TYPE_ID                    ,
                 SERIAL_NUMBER                          ,
                 ASSEMBLY_ITEM_ID                       ,
                 GENERATE_SERIAL_NUMBER                 ,
                 GENERATE_FOR_QTY                       ,
                 ACTION_FLAG                            ,
                 CURRENT_WIP_ENTITY_NAME                ,
                 CHANGED_WIP_ENTITY_NAME                ,
                 CURRENT_WIP_ENTITY_ID                  ,
                 CHANGED_WIP_ENTITY_ID                  ,
                 SERIAL_ATTRIBUTE_CATEGORY              ,
                 TERRITORY_CODE                         ,
                 ORIGINATION_DATE                       ,
                 C_ATTRIBUTE1                           ,
                 C_ATTRIBUTE2                           ,
                 C_ATTRIBUTE3                           ,
                 C_ATTRIBUTE4                           ,
                 C_ATTRIBUTE5                           ,
                 C_ATTRIBUTE6                           ,
                 C_ATTRIBUTE7                           ,
                 C_ATTRIBUTE8                           ,
                 C_ATTRIBUTE9                           ,
                 C_ATTRIBUTE10                          ,
                 C_ATTRIBUTE11                          ,
                 C_ATTRIBUTE12                          ,
                 C_ATTRIBUTE13                          ,
                 C_ATTRIBUTE14                          ,
                 C_ATTRIBUTE15                          ,
                 C_ATTRIBUTE16                          ,
                 C_ATTRIBUTE17                          ,
                 C_ATTRIBUTE18                          ,
                 C_ATTRIBUTE19                          ,
                 C_ATTRIBUTE20                          ,
                 D_ATTRIBUTE1                           ,
                 D_ATTRIBUTE2                           ,
                 D_ATTRIBUTE3                           ,
                 D_ATTRIBUTE4                           ,
                 D_ATTRIBUTE5                           ,
                 D_ATTRIBUTE6                           ,
                 D_ATTRIBUTE7                           ,
                 D_ATTRIBUTE8                           ,
                 D_ATTRIBUTE9                           ,
                 D_ATTRIBUTE10                          ,
                 N_ATTRIBUTE1                           ,
                 N_ATTRIBUTE2                           ,
                 N_ATTRIBUTE3                           ,
                 N_ATTRIBUTE4                           ,
                 N_ATTRIBUTE5                           ,
                 N_ATTRIBUTE6                           ,
                 N_ATTRIBUTE7                           ,
                 N_ATTRIBUTE8                           ,
                 N_ATTRIBUTE9                           ,
                 N_ATTRIBUTE10                          ,
                 STATUS_ID                              ,
                 TIME_SINCE_NEW                         ,
                 CYCLES_SINCE_NEW                       ,
                 TIME_SINCE_OVERHAUL                    ,
                 CYCLES_SINCE_OVERHAUL                  ,
                 TIME_SINCE_REPAIR                      ,
                 CYCLES_SINCE_REPAIR                    ,
                 TIME_SINCE_VISIT                       ,
                 CYCLES_SINCE_VISIT                     ,
                 TIME_SINCE_MARK                        ,
                 CYCLES_SINCE_MARK                      ,
                 NUMBER_OF_REPAIRS                      ,
                 ATTRIBUTE_CATEGORY                     ,
                 ATTRIBUTE1                             ,
                 ATTRIBUTE2                             ,
                 ATTRIBUTE3                             ,
                 ATTRIBUTE4                             ,
                 ATTRIBUTE5                             ,
                 ATTRIBUTE6                             ,
                 ATTRIBUTE7                             ,
                 ATTRIBUTE8                             ,
                 ATTRIBUTE9                             ,
                 ATTRIBUTE10                            ,
                 ATTRIBUTE11                            ,
                 ATTRIBUTE12                            ,
                 ATTRIBUTE13                            ,
                 ATTRIBUTE14                            ,
                 ATTRIBUTE15                            ,
                 CREATED_BY                             ,
                 LAST_UPDATE_DATE                       ,
                 LAST_UPDATED_BY                        ,
                 CREATION_DATE                          ,
                 LAST_UPDATE_LOGIN                      ,
                 REQUEST_ID                             ,
                 PROGRAM_APPLICATION_ID                 ,
                 PROGRAM_ID                             ,
                 PROGRAM_UPDATE_DATE                    ,
                 ORIGINAL_SYSTEM_REFERENCE
                )
                Select
                 WMTI.transaction_id                      ,
                 5                                        , -- for internal use... 5 for Attributes updation..
                 MSN.SERIAL_NUMBER                        ,
                 WMTI.primary_item_id                     ,
                 null                                     ,
                 null                                     ,
                 null                                     ,
                 null                                     ,
                 null                                     ,
                 WMTI.WIP_ENTITY_ID                       ,
                 null                                     ,
                 MSN.SERIAL_ATTRIBUTE_CATEGORY            ,
                 MSN.TERRITORY_CODE                       ,
                 MSN.ORIGINATION_DATE                     ,
                 MSN.C_ATTRIBUTE1                         ,
                 MSN.C_ATTRIBUTE2                         ,
                 MSN.C_ATTRIBUTE3                         ,
                 MSN.C_ATTRIBUTE4                         ,
                 MSN.C_ATTRIBUTE5                         ,
                 MSN.C_ATTRIBUTE6                         ,
                 MSN.C_ATTRIBUTE7                         ,
                 MSN.C_ATTRIBUTE8                         ,
                 MSN.C_ATTRIBUTE9                         ,
                 MSN.C_ATTRIBUTE10                        ,
                 MSN.C_ATTRIBUTE11                        ,
                 MSN.C_ATTRIBUTE12                        ,
                 MSN.C_ATTRIBUTE13                        ,
                 MSN.C_ATTRIBUTE14                        ,
                 MSN.C_ATTRIBUTE15                        ,
                 MSN.C_ATTRIBUTE16                        ,
                 MSN.C_ATTRIBUTE17                        ,
                 MSN.C_ATTRIBUTE18                        ,
                 MSN.C_ATTRIBUTE19                        ,
                 MSN.C_ATTRIBUTE20                        ,
                 MSN.D_ATTRIBUTE1                         ,
                 MSN.D_ATTRIBUTE2                         ,
                 MSN.D_ATTRIBUTE3                         ,
                 MSN.D_ATTRIBUTE4                         ,
                 MSN.D_ATTRIBUTE5                         ,
                 MSN.D_ATTRIBUTE6                         ,
                 MSN.D_ATTRIBUTE7                         ,
                 MSN.D_ATTRIBUTE8                         ,
                 MSN.D_ATTRIBUTE9                         ,
                 MSN.D_ATTRIBUTE10                        ,
                 MSN.N_ATTRIBUTE1                         ,
                 MSN.N_ATTRIBUTE2                         ,
                 MSN.N_ATTRIBUTE3                         ,
                 MSN.N_ATTRIBUTE4                         ,
                 MSN.N_ATTRIBUTE5                         ,
                 MSN.N_ATTRIBUTE6                         ,
                 MSN.N_ATTRIBUTE7                         ,
                 MSN.N_ATTRIBUTE8                         ,
                 MSN.N_ATTRIBUTE9                         ,
                 MSN.N_ATTRIBUTE10                        ,
                 MSN.STATUS_ID                            ,
                 MSN.TIME_SINCE_NEW                       ,
                 MSN.CYCLES_SINCE_NEW                     ,
                 MSN.TIME_SINCE_OVERHAUL                  ,
                 MSN.CYCLES_SINCE_OVERHAUL                ,
                 MSN.TIME_SINCE_REPAIR                    ,
                 MSN.CYCLES_SINCE_REPAIR                  ,
                 MSN.TIME_SINCE_VISIT                     ,
                 MSN.CYCLES_SINCE_VISIT                   ,
                 MSN.TIME_SINCE_MARK                      ,
                 MSN.CYCLES_SINCE_MARK                    ,
                 MSN.NUMBER_OF_REPAIRS                    ,
                 MSN.ATTRIBUTE_CATEGORY                   ,
                 MSN.ATTRIBUTE1                           ,
                 MSN.ATTRIBUTE2                           ,
                 MSN.ATTRIBUTE3                           ,
                 MSN.ATTRIBUTE4                           ,
                 MSN.ATTRIBUTE5                           ,
                 MSN.ATTRIBUTE6                           ,
                 MSN.ATTRIBUTE7                           ,
                 MSN.ATTRIBUTE8                           ,
                 MSN.ATTRIBUTE9                           ,
                 MSN.ATTRIBUTE10                          ,
                 MSN.ATTRIBUTE11                          ,
                 MSN.ATTRIBUTE12                          ,
                 MSN.ATTRIBUTE13                          ,
                 MSN.ATTRIBUTE14                          ,
                 MSN.ATTRIBUTE15                          ,
                 g_user_id                                ,
                 SYSDATE                                  ,
                 g_user_id                                ,
                 SYSDATE                                  ,
                 g_user_login_id                          ,
                 g_request_id                             ,
                 g_program_appl_id                        ,
                 g_program_id                             ,
                 sysdate                                  ,
                 null
                from wip_serial_move_interface WSMI,
                     mtl_serial_numbers        MSN,
                     wip_move_txn_interface    WMTI
                where WMTI.group_id = p_group_id
                and   WMTI.transaction_id = WSMI.transaction_id
                and   MSN.serial_number   = WSMI.assembly_serial_number
                and   MSN.current_organization_id = WMTI.organization_id
                and   MSN.inventory_item_id = WMTI.primary_item_id
                -- ST : Commenting it out...
                -- and   MSN.serial_attribute_category IS NOT NULL -- Desc flex fields are not cleared. Only serial attributes
                and   WMTI.transaction_type IN (2,3); -- Completion/Assembly return

                l_stmt_num := 30;
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Total Serial Numbers inserted : ' || SQL%ROWCOUNT,
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;
        ELSE
                l_stmt_num := 40;

                insert into wsm_serial_txn_temp
                (
                 HEADER_ID                              ,
                 TRANSACTION_TYPE_ID                    ,
                 SERIAL_NUMBER                          ,
                 ASSEMBLY_ITEM_ID                       ,
                 GENERATE_SERIAL_NUMBER                 ,
                 GENERATE_FOR_QTY                       ,
                 ACTION_FLAG                            ,
                 CURRENT_WIP_ENTITY_NAME                ,
                 CHANGED_WIP_ENTITY_NAME                ,
                 CURRENT_WIP_ENTITY_ID                  ,
                 CHANGED_WIP_ENTITY_ID                  ,
                 SERIAL_ATTRIBUTE_CATEGORY              ,
                 TERRITORY_CODE                         ,
                 ORIGINATION_DATE                       ,
                 C_ATTRIBUTE1                           ,
                 C_ATTRIBUTE2                           ,
                 C_ATTRIBUTE3                           ,
                 C_ATTRIBUTE4                           ,
                 C_ATTRIBUTE5                           ,
                 C_ATTRIBUTE6                           ,
                 C_ATTRIBUTE7                           ,
                 C_ATTRIBUTE8                           ,
                 C_ATTRIBUTE9                           ,
                 C_ATTRIBUTE10                          ,
                 C_ATTRIBUTE11                          ,
                 C_ATTRIBUTE12                          ,
                 C_ATTRIBUTE13                          ,
                 C_ATTRIBUTE14                          ,
                 C_ATTRIBUTE15                          ,
                 C_ATTRIBUTE16                          ,
                 C_ATTRIBUTE17                          ,
                 C_ATTRIBUTE18                          ,
                 C_ATTRIBUTE19                          ,
                 C_ATTRIBUTE20                          ,
                 D_ATTRIBUTE1                           ,
                 D_ATTRIBUTE2                           ,
                 D_ATTRIBUTE3                           ,
                 D_ATTRIBUTE4                           ,
                 D_ATTRIBUTE5                           ,
                 D_ATTRIBUTE6                           ,
                 D_ATTRIBUTE7                           ,
                 D_ATTRIBUTE8                           ,
                 D_ATTRIBUTE9                           ,
                 D_ATTRIBUTE10                          ,
                 N_ATTRIBUTE1                           ,
                 N_ATTRIBUTE2                           ,
                 N_ATTRIBUTE3                           ,
                 N_ATTRIBUTE4                           ,
                 N_ATTRIBUTE5                           ,
                 N_ATTRIBUTE6                           ,
                 N_ATTRIBUTE7                           ,
                 N_ATTRIBUTE8                           ,
                 N_ATTRIBUTE9                           ,
                 N_ATTRIBUTE10                          ,
                 STATUS_ID                              ,
                 TIME_SINCE_NEW                         ,
                 CYCLES_SINCE_NEW                       ,
                 TIME_SINCE_OVERHAUL                    ,
                 CYCLES_SINCE_OVERHAUL                  ,
                 TIME_SINCE_REPAIR                      ,
                 CYCLES_SINCE_REPAIR                    ,
                 TIME_SINCE_VISIT                       ,
                 CYCLES_SINCE_VISIT                     ,
                 TIME_SINCE_MARK                        ,
                 CYCLES_SINCE_MARK                      ,
                 NUMBER_OF_REPAIRS                      ,
                 ATTRIBUTE_CATEGORY                     ,
                 ATTRIBUTE1                             ,
                 ATTRIBUTE2                             ,
                 ATTRIBUTE3                             ,
                 ATTRIBUTE4                             ,
                 ATTRIBUTE5                             ,
                 ATTRIBUTE6                             ,
                 ATTRIBUTE7                             ,
                 ATTRIBUTE8                             ,
                 ATTRIBUTE9                             ,
                 ATTRIBUTE10                            ,
                 ATTRIBUTE11                            ,
                 ATTRIBUTE12                            ,
                 ATTRIBUTE13                            ,
                 ATTRIBUTE14                            ,
                 ATTRIBUTE15                            ,
                 CREATED_BY                             ,
                 LAST_UPDATE_DATE                       ,
                 LAST_UPDATED_BY                        ,
                 CREATION_DATE                          ,
                 LAST_UPDATE_LOGIN                      ,
                 REQUEST_ID                             ,
                 PROGRAM_APPLICATION_ID                 ,
                 PROGRAM_ID                             ,
                 PROGRAM_UPDATE_DATE                    ,
                 ORIGINAL_SYSTEM_REFERENCE
                )
                Select
                 WMTI.transaction_id                      ,
                 5                                        , -- for internal use... 5 for Attributes updation..
                 MSN.SERIAL_NUMBER                        ,
                 WMTI.primary_item_id                     ,
                 null                                     ,
                 null                                     ,
                 null                                     ,
                 null                                     ,
                 null                                     ,
                 WMTI.WIP_ENTITY_ID                       ,
                 null                                     ,
                 MSN.SERIAL_ATTRIBUTE_CATEGORY            ,
                 MSN.TERRITORY_CODE                       ,
                 MSN.ORIGINATION_DATE                     ,
                 MSN.C_ATTRIBUTE1                         ,
                 MSN.C_ATTRIBUTE2                         ,
                 MSN.C_ATTRIBUTE3                         ,
                 MSN.C_ATTRIBUTE4                         ,
                 MSN.C_ATTRIBUTE5                         ,
                 MSN.C_ATTRIBUTE6                         ,
                 MSN.C_ATTRIBUTE7                         ,
                 MSN.C_ATTRIBUTE8                         ,
                 MSN.C_ATTRIBUTE9                         ,
                 MSN.C_ATTRIBUTE10                        ,
                 MSN.C_ATTRIBUTE11                        ,
                 MSN.C_ATTRIBUTE12                        ,
                 MSN.C_ATTRIBUTE13                        ,
                 MSN.C_ATTRIBUTE14                        ,
                 MSN.C_ATTRIBUTE15                        ,
                 MSN.C_ATTRIBUTE16                        ,
                 MSN.C_ATTRIBUTE17                        ,
                 MSN.C_ATTRIBUTE18                        ,
                 MSN.C_ATTRIBUTE19                        ,
                 MSN.C_ATTRIBUTE20                        ,
                 MSN.D_ATTRIBUTE1                         ,
                 MSN.D_ATTRIBUTE2                         ,
                 MSN.D_ATTRIBUTE3                         ,
                 MSN.D_ATTRIBUTE4                         ,
                 MSN.D_ATTRIBUTE5                         ,
                 MSN.D_ATTRIBUTE6                         ,
                 MSN.D_ATTRIBUTE7                         ,
                 MSN.D_ATTRIBUTE8                         ,
                 MSN.D_ATTRIBUTE9                         ,
                 MSN.D_ATTRIBUTE10                        ,
                 MSN.N_ATTRIBUTE1                         ,
                 MSN.N_ATTRIBUTE2                         ,
                 MSN.N_ATTRIBUTE3                         ,
                 MSN.N_ATTRIBUTE4                         ,
                 MSN.N_ATTRIBUTE5                         ,
                 MSN.N_ATTRIBUTE6                         ,
                 MSN.N_ATTRIBUTE7                         ,
                 MSN.N_ATTRIBUTE8                         ,
                 MSN.N_ATTRIBUTE9                         ,
                 MSN.N_ATTRIBUTE10                        ,
                 MSN.STATUS_ID                            ,
                 MSN.TIME_SINCE_NEW                       ,
                 MSN.CYCLES_SINCE_NEW                     ,
                 MSN.TIME_SINCE_OVERHAUL                  ,
                 MSN.CYCLES_SINCE_OVERHAUL                ,
                 MSN.TIME_SINCE_REPAIR                    ,
                 MSN.CYCLES_SINCE_REPAIR                  ,
                 MSN.TIME_SINCE_VISIT                     ,
                 MSN.CYCLES_SINCE_VISIT                   ,
                 MSN.TIME_SINCE_MARK                      ,
                 MSN.CYCLES_SINCE_MARK                    ,
                 MSN.NUMBER_OF_REPAIRS                    ,
                 MSN.ATTRIBUTE_CATEGORY                   ,
                 MSN.ATTRIBUTE1                           ,
                 MSN.ATTRIBUTE2                           ,
                 MSN.ATTRIBUTE3                           ,
                 MSN.ATTRIBUTE4                           ,
                 MSN.ATTRIBUTE5                           ,
                 MSN.ATTRIBUTE6                           ,
                 MSN.ATTRIBUTE7                           ,
                 MSN.ATTRIBUTE8                           ,
                 MSN.ATTRIBUTE9                           ,
                 MSN.ATTRIBUTE10                          ,
                 MSN.ATTRIBUTE11                          ,
                 MSN.ATTRIBUTE12                          ,
                 MSN.ATTRIBUTE13                          ,
                 MSN.ATTRIBUTE14                          ,
                 MSN.ATTRIBUTE15                          ,
                 g_user_id                                ,
                 SYSDATE                                  ,
                 g_user_id                                ,
                 SYSDATE                                  ,
                 g_user_login_id                          ,
                 g_request_id                             ,
                 g_program_appl_id                        ,
                 g_program_id                             ,
                 sysdate                                  ,
                 null
                from wip_serial_move_interface WSMI,
                     mtl_serial_numbers        MSN,
                     wip_move_txn_interface    WMTI
                where WMTI.transaction_id in (p_move_txn_id,p_scrap_txn_id)
                and   WMTI.transaction_id = WSMI.transaction_id
                and   MSN.serial_number   = WSMI.assembly_serial_number
                and   MSN.current_organization_id = WMTI.organization_id
                and   MSN.inventory_item_id = WMTI.primary_item_id
                -- ST : Commenting it out...
                -- and   MSN.serial_attribute_category IS NOT NULL -- Desc flex fields are not cleared. Only serial attributes
                and   WMTI.transaction_type IN (2,3); -- Completion/Assembly return

                l_stmt_num := 50;
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Total Serial Numbers inserted : ' || SQL%ROWCOUNT,
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;
        END IF;

END Insert_move_attr;

-- Internal group id on wsm_lot_move_txn_interface will be passed
Procedure Update_attr_move ( p_group_id                  IN         NUMBER      DEFAULT NULL,  -- for interface...
                             p_internal_group_id         IN         NUMBER      DEFAULT NULL,  -- for interface...
                             p_move_txn_id               IN         NUMBER      DEFAULT NULL,  -- for forms...
                             p_scrap_txn_id              IN         NUMBER      DEFAULT NULL,  -- for forms...
                             p_organization_id           IN         NUMBER      ,
                             x_return_status             OUT NOCOPY VARCHAR2    ,
                             x_error_count               OUT NOCOPY NUMBER      ,
                             x_error_msg                 OUT NOCOPY VARCHAR2
                           )

IS
        -- This cursor fetches the serials whose op info need to be cleared...but havent been cleared by WIP
        -- Possible when the serial tracking doesnt start with the move tranaction's from op seq num as 10 and step as Queue
        -- This is because we fill the serial start op as 10 always in WDJ
        -- So the reverse doesnt happen (ie) WIP clears the op info when it has to be present as there is
        -- no possible step prior to 10 Queue
        -- Or it is also possible if a pure scrap transaction triggered the serial tracking.
        cursor c_serials_intf is
        select msn.serial_number,
               msn.inventory_item_id,
               msn.current_organization_id,
               wmt.wip_entity_id
        from   mtl_serial_numbers msn,
               wip_move_transactions wmt,
               wsm_lot_move_txn_interface wlmti,
               wsm_lot_based_jobs wlbj
        where  wlmti.group_id = p_group_id
        and    wlmti.internal_group_id = p_internal_group_id
        and    wlmti.wip_entity_id = wmt.wip_entity_id
        and    wmt.group_id = p_internal_group_id
        and    wlmti.status = WIP_CONSTANTS.COMPLETED
        and    wmt.wip_entity_id = wlbj.wip_entity_id
        and    wlbj.first_serial_txn_id IS NULL
        and    msn.inventory_item_id = wmt.primary_item_id
        and    msn.current_organization_id = wmt.organization_id
        and    msn.wip_entity_id = wmt.wip_entity_id
        and    msn.operation_seq_num IS NOT NULL;

        -- This cursor fetches the serials that shouldnt have been cleared..
        cursor c_serials_lot_create_intf is
        select msn.serial_number,
               msn.inventory_item_id,
               msn.current_organization_id,
               wdj.wip_entity_id
        from   mtl_serial_numbers msn,
               wsm_lot_move_txn_interface wlmti,
               wip_discrete_jobs wdj,
               wsm_lot_based_jobs wlbj
        where  wlmti.group_id = p_group_id
        and    wlmti.internal_group_id = p_internal_group_id
        and    wlmti.wip_entity_id = wdj.wip_entity_id
        and    wlmti.status = WIP_CONSTANTS.COMPLETED
        and    wdj.wip_entity_id = wlbj.wip_entity_id
        and    wlbj.first_serial_txn_id = -1 -- It will be set to -1 only for those jobs created through Lot Creation form..
        and    msn.inventory_item_id = wdj.primary_item_id
        and    msn.current_organization_id = wdj.organization_id
        and    msn.wip_entity_id = wdj.wip_entity_id
        and    msn.operation_seq_num IS NULL; -- This will be set when the jobs created Lot Creation reach operation 10..

        -- This cursor fetches the serials whose op info need to be cleared...but havent been cleared by WIP
        -- Possible when the serial tracking doesnt start with the move tranaction's from op seq num as 10 and step as Queue
        -- Also for pure scrap transactions..
        cursor c_serials_form is
        select msn.serial_number,
               msn.inventory_item_id,
               msn.current_organization_id,
               wmt.wip_entity_id
        from   mtl_serial_numbers msn,
               wip_move_transactions wmt,
               wsm_lot_based_jobs wlbj
        where  wmt.transaction_id in (p_move_txn_id, p_scrap_txn_id)
        and    wmt.wip_entity_id = wlbj.wip_entity_id
        and    wlbj.first_serial_txn_id IS NULL
        and    msn.inventory_item_id = wmt.primary_item_id
        and    msn.current_organization_id = wmt.organization_id
        and    msn.wip_entity_id = wmt.wip_entity_id
        and    msn.operation_seq_num IS NOT NULL;

        -- This cursor is for jobs created through Lot Creation which will remain serial tracked throughout...
        cursor c_serials_lot_create_form is
        select msn.serial_number,
               msn.inventory_item_id,
               msn.current_organization_id,
               wmt.wip_entity_id
        from   mtl_serial_numbers msn,
               wip_move_transactions wmt,
               wip_serial_move_transactions wsmt,
               wsm_lot_based_jobs wlbj
        where  wmt.transaction_id in (p_move_txn_id, p_scrap_txn_id)
        and    wmt.wip_entity_id = wlbj.wip_entity_id
        and    wmt.transaction_id = wsmt.transaction_id
        and    wlbj.first_serial_txn_id = -1 -- It will be set to -1 only for those jobs created through Lot Creation form..
        and    msn.serial_number = wsmt.assembly_serial_number
        and    msn.inventory_item_id = wmt.primary_item_id
        and    msn.current_organization_id = wmt.organization_id
        and    msn.wip_entity_id = wmt.wip_entity_id
        and    msn.operation_seq_num IS NULL;

        -- Attributes section...
        cursor c_serials_attr_intf
        is
        select
        Serial_Number                   ,
        assembly_item_id                ,  -- assembly_item_id
        header_id                       ,  -- header_id
        Generate_serial_number          ,
        Generate_for_qty                ,
        Action_flag                     ,
        Current_wip_entity_name         ,
        Changed_wip_entity_name         ,
        Current_wip_entity_id           ,
        Changed_wip_entity_id           ,
        serial_attribute_category       ,
        territory_code                  ,
        origination_date                ,
        c_attribute1                    ,
        c_attribute2                    ,
        c_attribute3                    ,
        c_attribute4                    ,
        c_attribute5                    ,
        c_attribute6                    ,
        c_attribute7                    ,
        c_attribute8                    ,
        c_attribute9                    ,
        c_attribute10                   ,
        c_attribute11                   ,
        c_attribute12                   ,
        c_attribute13                   ,
        c_attribute14                   ,
        c_attribute15                   ,
        c_attribute16                   ,
        c_attribute17                   ,
        c_attribute18                   ,
        c_attribute19                   ,
        c_attribute20                   ,
        d_attribute1                    ,
        d_attribute2                    ,
        d_attribute3                    ,
        d_attribute4                    ,
        d_attribute5                    ,
        d_attribute6                    ,
        d_attribute7                    ,
        d_attribute8                    ,
        d_attribute9                    ,
        d_attribute10                   ,
        n_attribute1                    ,
        n_attribute2                    ,
        n_attribute3                    ,
        n_attribute4                    ,
        n_attribute5                    ,
        n_attribute6                    ,
        n_attribute7                    ,
        n_attribute8                    ,
        n_attribute9                    ,
        n_attribute10                   ,
        status_id                       ,
        time_since_new                  ,
        cycles_since_new                ,
        time_since_overhaul             ,
        cycles_since_overhaul           ,
        time_since_repair               ,
        cycles_since_repair             ,
        time_since_visit                ,
        cycles_since_visit              ,
        time_since_mark                 ,
        cycles_since_mark               ,
        number_of_repairs               ,
        attribute_category              ,
        attribute1                      ,
        attribute2                      ,
        attribute3                      ,
        attribute4                      ,
        attribute5                      ,
        attribute6                      ,
        attribute7                      ,
        attribute8                      ,
        attribute9                      ,
        attribute10                     ,
        attribute11                     ,
        attribute12                     ,
        attribute13                     ,
        attribute14                     ,
        attribute15
        from wsm_serial_txn_interface wsti
        where header_id IN (Select wmt.transaction_id
                            from   wip_move_transactions wmt,
                                   wsm_lot_move_txn_interface wlmti
                            where  wlmti.group_id = p_group_id
                            and    wlmti.internal_group_id = p_internal_group_id
                            and    wlmti.wip_entity_id = wmt.wip_entity_id
                            and    wlmti.status = WIP_CONSTANTS.COMPLETED
                            )
        and transaction_type_id = 5;

        cursor c_serials_attr_form
        is
        select
        Serial_Number                   ,
        assembly_item_id                ,  -- assembly_item_id
        header_id                       ,  -- header_id
        Generate_serial_number          ,
        Generate_for_qty                ,
        Action_flag                     ,
        Current_wip_entity_name         ,
        Changed_wip_entity_name         ,
        Current_wip_entity_id           ,
        Changed_wip_entity_id           ,
        serial_attribute_category       ,
        territory_code                  ,
        origination_date                ,
        c_attribute1                    ,
        c_attribute2                    ,
        c_attribute3                    ,
        c_attribute4                    ,
        c_attribute5                    ,
        c_attribute6                    ,
        c_attribute7                    ,
        c_attribute8                    ,
        c_attribute9                    ,
        c_attribute10                   ,
        c_attribute11                   ,
        c_attribute12                   ,
        c_attribute13                   ,
        c_attribute14                   ,
        c_attribute15                   ,
        c_attribute16                   ,
        c_attribute17                   ,
        c_attribute18                   ,
        c_attribute19                   ,
        c_attribute20                   ,
        d_attribute1                    ,
        d_attribute2                    ,
        d_attribute3                    ,
        d_attribute4                    ,
        d_attribute5                    ,
        d_attribute6                    ,
        d_attribute7                    ,
        d_attribute8                    ,
        d_attribute9                    ,
        d_attribute10                   ,
        n_attribute1                    ,
        n_attribute2                    ,
        n_attribute3                    ,
        n_attribute4                    ,
        n_attribute5                    ,
        n_attribute6                    ,
        n_attribute7                    ,
        n_attribute8                    ,
        n_attribute9                    ,
        n_attribute10                   ,
        status_id                       ,
        time_since_new                  ,
        cycles_since_new                ,
        time_since_overhaul             ,
        cycles_since_overhaul           ,
        time_since_repair               ,
        cycles_since_repair             ,
        time_since_visit                ,
        cycles_since_visit              ,
        time_since_mark                 ,
        cycles_since_mark               ,
        number_of_repairs               ,
        attribute_category              ,
        attribute1                      ,
        attribute2                      ,
        attribute3                      ,
        attribute4                      ,
        attribute5                      ,
        attribute6                      ,
        attribute7                      ,
        attribute8                      ,
        attribute9                      ,
        attribute10                     ,
        attribute11                     ,
        attribute12                     ,
        attribute13                     ,
        attribute14                     ,
        attribute15
        from wsm_serial_txn_temp wsti
        where header_id IN (p_move_txn_id, p_scrap_txn_id)
        and transaction_type_id = 5;


type t_serial_op_info_rec is record
(
   serial_number        MTL_SERIAL_NUMBERS.SERIAL_NUMBER%TYPE,
   inventory_item_id    NUMBER,
   organization_id      NUMBER,
   wip_entity_id        NUMBER
);

type t_serial_op_info_tbl is table of t_serial_op_info_rec index by binary_integer;

l_serial_info_tbl   t_serial_op_info_tbl;
l_cntr              NUMBER;

-- Attributes updation variables...
l_serial_txn_tbl        t_number;
l_wsm_serial_attrs_tbl  WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL;

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.update_attr_move';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
        l_stmt_num      := 10;
        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_move_txn_id';
                l_param_tbl(1).paramValue := p_move_txn_id;

                l_param_tbl(2).paramName := 'p_scrap_txn_id';
                l_param_tbl(2).paramValue := p_scrap_txn_id;

                l_param_tbl(3).paramName := 'p_group_id';
                l_param_tbl(3).paramValue := p_group_id;

                l_param_tbl(4).paramName := 'p_internal_group_id';
                l_param_tbl(4).paramValue := p_internal_group_id;

                l_param_tbl(5).paramName := 'p_organization_id';
                l_param_tbl(5).paramValue := p_organization_id;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        -- This fist part is to clear the serials' op information when serial tracking ends...
        IF (p_group_id IS NOT NULL OR p_internal_group_id IS NOT NULL) THEN
                --
                l_stmt_num := 20;
                loop

                        l_stmt_num := 30;

                        open c_serials_intf;
                        fetch c_serials_intf
                        bulk collect into l_serial_info_tbl
                        limit 1000; -- hard coded this
                        close c_serials_intf;

                        l_stmt_num := 40;
                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Total Serial Numbers : ' || l_serial_info_tbl.count,
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;

                        if l_serial_info_tbl.count = 0 then
                                exit;
                        end if;


                        l_stmt_num := 50;
                        l_cntr := l_serial_info_tbl.first;

                        while l_cntr is not null loop

                                -- Clear the op informatio.....
                                update_serial(   p_serial_number                =>  l_serial_info_tbl(l_cntr).serial_number         ,
                                                 p_inventory_item_id            =>  l_serial_info_tbl(l_cntr).inventory_item_id     ,
                                                 p_organization_id              =>  l_serial_info_tbl(l_cntr).organization_id       ,
                                                 p_wip_entity_id                =>  l_serial_info_tbl(l_cntr).wip_entity_id         ,
                                                 p_operation_seq_num            =>  null                                            ,
                                                 p_intraoperation_step_type     =>  null                                            ,
                                                 x_return_status                =>  x_return_status                                 ,
                                                 x_error_msg                    =>  x_error_msg                                     ,
                                                 x_error_count                  =>  x_error_count
                                              );

                                if x_return_status <> G_RET_SUCCESS then
                                        IF x_return_status = G_RET_ERROR THEN
                                                raise FND_API.G_EXC_ERROR;
                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                                end if;

                                l_cntr := l_serial_info_tbl.next(l_cntr);
                        end loop;

                        l_stmt_num := 70;

                end loop;
        ELSE
                open c_serials_form;
                fetch c_serials_form
                bulk collect into l_serial_info_tbl;
                close c_serials_form;

                l_stmt_num := 80;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Total Serial Numbers : ' || l_serial_info_tbl.count,
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                l_stmt_num := 90;
                l_cntr := l_serial_info_tbl.first;

                while l_cntr is not null loop

                        -- Clear the op informatio.....
                        update_serial(   p_serial_number                =>  l_serial_info_tbl(l_cntr).serial_number         ,
                                         p_inventory_item_id            =>  l_serial_info_tbl(l_cntr).inventory_item_id     ,
                                         p_organization_id              =>  l_serial_info_tbl(l_cntr).organization_id       ,
                                         p_wip_entity_id                =>  l_serial_info_tbl(l_cntr).wip_entity_id         ,
                                         p_operation_seq_num            =>  null                                            ,
                                         p_intraoperation_step_type     =>  null                                            ,
                                         x_return_status                =>  x_return_status                                 ,
                                         x_error_msg                    =>  x_error_msg                                     ,
                                         x_error_count                  =>  x_error_count
                                      );

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;

                        l_cntr := l_serial_info_tbl.next(l_cntr);
                end loop;

                l_stmt_num := 100;

        END IF;

        l_stmt_num := 110;
        -- This second part is meant soley for jobs created through Lot Creation form...
        -- They should always have op information in the serial numbers..
        IF (p_group_id IS NOT NULL OR p_internal_group_id IS NOT NULL) THEN
                --
                l_stmt_num := 120;
                loop

                        l_stmt_num := 130;

                        open c_serials_lot_create_intf;
                        fetch c_serials_lot_create_intf
                        bulk collect into l_serial_info_tbl
                        limit 1000; -- hard coded this
                        close c_serials_lot_create_intf;

                        l_stmt_num := 140;
                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Total Serial Numbers : ' || l_serial_info_tbl.count,
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;

                        if l_serial_info_tbl.count = 0 then
                                exit;
                        end if;


                        l_stmt_num := 150;
                        l_cntr := l_serial_info_tbl.first;

                        while l_cntr is not null loop

                                -- Clear the op informatio.....
                                update_serial(   p_serial_number                =>  l_serial_info_tbl(l_cntr).serial_number         ,
                                                 p_inventory_item_id            =>  l_serial_info_tbl(l_cntr).inventory_item_id     ,
                                                 p_organization_id              =>  l_serial_info_tbl(l_cntr).organization_id       ,
                                                 p_wip_entity_id                =>  l_serial_info_tbl(l_cntr).wip_entity_id         ,
                                                 p_operation_seq_num            =>  10                                              ,
                                                 p_intraoperation_step_type     =>  WIP_CONSTANTS.QUEUE                             ,
                                                 x_return_status                =>  x_return_status                                 ,
                                                 x_error_msg                    =>  x_error_msg                                     ,
                                                 x_error_count                  =>  x_error_count
                                              );

                                if x_return_status <> G_RET_SUCCESS then
                                        IF x_return_status = G_RET_ERROR THEN
                                                raise FND_API.G_EXC_ERROR;
                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                                end if;

                                l_cntr := l_serial_info_tbl.next(l_cntr);
                        end loop;

                        l_stmt_num := 170;

                end loop;
        ELSE
                open c_serials_lot_create_form;
                fetch c_serials_lot_create_form
                bulk collect into l_serial_info_tbl;
                close c_serials_lot_create_form;

                l_stmt_num := 180;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Total Serial Numbers : ' || l_serial_info_tbl.count,
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                l_stmt_num := 190;
                l_cntr := l_serial_info_tbl.first;

                while l_cntr is not null loop

                        -- Clear the op informatio.....
                        update_serial(   p_serial_number                =>  l_serial_info_tbl(l_cntr).serial_number         ,
                                         p_inventory_item_id            =>  l_serial_info_tbl(l_cntr).inventory_item_id     ,
                                         p_organization_id              =>  l_serial_info_tbl(l_cntr).organization_id       ,
                                         p_wip_entity_id                =>  l_serial_info_tbl(l_cntr).wip_entity_id         ,
                                         p_operation_seq_num            =>  10                                              ,
                                         p_intraoperation_step_type     =>  WIP_CONSTANTS.QUEUE                             ,
                                         x_return_status                =>  x_return_status                                 ,
                                         x_error_msg                    =>  x_error_msg                                     ,
                                         x_error_count                  =>  x_error_count
                                      );

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;

                        l_cntr := l_serial_info_tbl.next(l_cntr);
                end loop;

                l_stmt_num := 200;
        END IF;

        -- Attributes section...
        l_stmt_num := 210;
        IF (p_group_id IS NOT NULL OR p_internal_group_id IS NOT NULL) THEN
                l_stmt_num := 220;
                loop

                        l_stmt_num := 230;

                        open c_serials_attr_intf;
                        fetch c_serials_attr_intf
                        bulk collect into l_wsm_serial_attrs_tbl
                        limit 1000; -- hard coded this;
                        close c_serials_attr_intf;

                        l_stmt_num := 240;
                        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                                l_msg_tokens.delete;
                                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                        p_msg_text          => 'Total Serial Numbers : ' || l_wsm_serial_attrs_tbl.count,
                                                        p_stmt_num          => l_stmt_num               ,
                                                        p_msg_tokens        => l_msg_tokens             ,
                                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                        p_run_log_level     => l_log_level
                                                        );
                        END IF;

                        if l_wsm_serial_attrs_tbl.count = 0 then
                                exit;
                        end if;

                        l_stmt_num := 250;
                        l_cntr := l_wsm_serial_attrs_tbl.first;
                        WHILE l_cntr IS NOT NULL LOOP

                                l_stmt_num := 260;
                                -- call the update_serial_attr procedure...
                                update_serial_attr (   p_calling_mode           =>  1                                                                 ,
                                                       p_serial_number_rec      =>  l_wsm_serial_attrs_tbl(l_cntr)                                    ,
                                                       p_inventory_item_id      =>  l_wsm_serial_attrs_tbl(l_cntr).assembly_item_id                   ,
                                                       p_organization_id        =>  nvl(p_organization_id,l_wsm_serial_attrs_tbl(l_cntr).action_flag) ,
                                                       p_clear_serial_attr      =>  null                                                              ,
                                                       p_wlt_txn_type           =>  null                                                              ,
                                                       p_update_serial_attr     =>  1                                                                 ,
                                                       p_update_desc_attr       =>  null                                                              ,
                                                       x_return_status          =>  x_return_status                                                   ,
                                                       x_error_count            =>  x_error_count                                                     ,
                                                       x_error_msg              =>  x_error_msg
                                                   );

                                if x_return_status <> G_RET_SUCCESS then
                                        IF x_return_status = G_RET_ERROR THEN
                                                raise FND_API.G_EXC_ERROR;
                                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
                                end if;

                                IF not (l_serial_txn_tbl.exists(l_wsm_serial_attrs_tbl(l_cntr).header_id)) THEN
                                        l_serial_txn_tbl(l_wsm_serial_attrs_tbl(l_cntr).header_id) := l_wsm_serial_attrs_tbl(l_cntr).header_id;
                                END IF;

                                l_cntr := l_wsm_serial_attrs_tbl.next(l_cntr);
                        end loop;

                        l_stmt_num := 270;

                        forall l_header in indices OF l_serial_txn_tbl
                                delete from wsm_serial_txn_interface
                                where  header_id = l_serial_txn_tbl(l_header)
                                and    transaction_type_id = 5;

                end loop;
        ELSE
                open c_serials_attr_form;
                fetch c_serials_attr_form
                bulk collect into l_wsm_serial_attrs_tbl;
                close c_serials_attr_form;

                l_stmt_num := 280;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Total Serial Numbers for attributes updation : '
                                                                        || l_wsm_serial_attrs_tbl.count,
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;


                l_stmt_num := 290;
                l_cntr := l_wsm_serial_attrs_tbl.first;
                WHILE l_cntr IS NOT NULL LOOP

                        l_stmt_num := 300;
                        -- call the update_serial_attr procedure...
                        update_serial_attr (   p_calling_mode           =>  2                                                  ,
                                               p_serial_number_rec      =>  l_wsm_serial_attrs_tbl(l_cntr)                     ,
                                               p_inventory_item_id      =>  l_wsm_serial_attrs_tbl(l_cntr).assembly_item_id    ,
                                               p_organization_id        =>  p_organization_id                                  ,
                                               p_clear_serial_attr      =>  null                                               ,
                                               p_wlt_txn_type           =>  null                                               ,
                                               p_update_serial_attr     =>  1                                                  ,
                                               p_update_desc_attr       =>  null                                               ,
                                               x_return_status          =>  x_return_status                                    ,
                                               x_error_count            =>  x_error_count                                      ,
                                               x_error_msg              =>  x_error_msg
                                           );

                        if x_return_status <> G_RET_SUCCESS then
                                IF x_return_status = G_RET_ERROR THEN
                                        raise FND_API.G_EXC_ERROR;
                                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                                END IF;
                        end if;

                        l_cntr := l_wsm_serial_attrs_tbl.next(l_cntr);
                END LOOP;

                l_stmt_num := 310;

                delete from wsm_serial_txn_temp
                where  header_id IN (p_move_txn_id,p_scrap_txn_id)
                and    transaction_type_id = 5;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module,
                                                p_msg_text          => 'Deleted ' || SQL%ROWCOUNT || ' records inserted for attributes reason',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;
        END IF;

        l_stmt_num := 320;
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Completed updation of the attributes',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
END Update_attr_move;

-- This procedure will not be invoked for Interface...
-- This procedure is not currently used as if populate_component fails the move transaction will also fail.
-- (Previously this procedure was required to populate the parent serial numbers to be seen in the backflush screen)
Procedure find_undo_ret_serials ( p_header_id            IN                     NUMBER,  -- passed value will be :parameter.move_txn_id
                                  p_wip_entity_id        IN                     NUMBER,
                                  p_move_txn_type        IN                     NUMBER,
                                  p_organization_id      IN                     NUMBER,
                                  p_inventory_item_id    IN                     NUMBER,
                                  p_move_qty             IN                     NUMBER,
                                  p_scrap_qty            IN                     NUMBER,
                                  x_return_status        OUT NOCOPY             VARCHAR2,
                                  x_error_msg            OUT NOCOPY             VARCHAR2,
                                  x_error_count          OUT NOCOPY             NUMBER
                                ) IS

        -- Logging variables.....
        l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
        l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

        l_stmt_num          NUMBER;
        l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.find_undo_ret_serials';
        l_param_tbl         WSM_Log_PVT.param_tbl_type;
        -- Logging variables...

begin

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        -- This procedure is no longer used...
        return;

EXCEPTION

        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

end find_undo_ret_serials;


Procedure Move_forms_serial_proc( p_move_txn_type               IN              NUMBER,
                                  p_wip_entity_id               IN              NUMBER,
                                  p_organization_id             IN              NUMBER,
                                  p_inventory_item_id           IN              NUMBER,
                                  p_move_qty                    IN              NUMBER,
                                  p_scrap_qty                   IN              NUMBER,
                                  p_available_qty               IN              NUMBER,
                                  p_curr_job_op_seq_num         IN              NUMBER,
                                  p_curr_job_intraop_step       IN              NUMBER,
                                  p_from_rtg_op_seq_num         IN              NUMBER,
                                  p_to_rtg_op_seq_num           IN              NUMBER,
                                  p_to_intraoperation_step      IN              NUMBER,
                                  p_user_serial_tracking        IN              NUMBER,
                                  p_move_txn_id                 IN              NUMBER,
                                  p_scrap_txn_id                IN              NUMBER,
                                  x_return_status               OUT NOCOPY      VARCHAR2,
                                  x_error_msg                   OUT NOCOPY      VARCHAR2,
                                  x_error_count                 OUT NOCOPY      NUMBER
                                )

IS
        cursor c_move_serials
        is
        select
        Serial_Number                   ,
        gen_object_id                   ,  -- (Gen_object_id --> assembly_item_id No longer used Instead the column will have gen_object_id)
        header_id                       ,  -- header_id
        Generate_serial_number          ,
        Generate_for_qty                ,
        Action_flag                     ,
        Current_wip_entity_name         ,
        Changed_wip_entity_name         ,
        Current_wip_entity_id           ,
        Changed_wip_entity_id           ,
        serial_attribute_category       ,
        territory_code                  ,
        origination_date                ,
        c_attribute1                    ,
        c_attribute2                    ,
        c_attribute3                    ,
        c_attribute4                    ,
        c_attribute5                    ,
        c_attribute6                    ,
        c_attribute7                    ,
        c_attribute8                    ,
        c_attribute9                    ,
        c_attribute10                   ,
        c_attribute11                   ,
        c_attribute12                   ,
        c_attribute13                   ,
        c_attribute14                   ,
        c_attribute15                   ,
        c_attribute16                   ,
        c_attribute17                   ,
        c_attribute18                   ,
        c_attribute19                   ,
        c_attribute20                   ,
        d_attribute1                    ,
        d_attribute2                    ,
        d_attribute3                    ,
        d_attribute4                    ,
        d_attribute5                    ,
        d_attribute6                    ,
        d_attribute7                    ,
        d_attribute8                    ,
        d_attribute9                    ,
        d_attribute10                   ,
        n_attribute1                    ,
        n_attribute2                    ,
        n_attribute3                    ,
        n_attribute4                    ,
        n_attribute5                    ,
        n_attribute6                    ,
        n_attribute7                    ,
        n_attribute8                    ,
        n_attribute9                    ,
        n_attribute10                   ,
        status_id                       ,
        time_since_new                  ,
        cycles_since_new                ,
        time_since_overhaul             ,
        cycles_since_overhaul           ,
        time_since_repair               ,
        cycles_since_repair             ,
        time_since_visit                ,
        cycles_since_visit              ,
        time_since_mark                 ,
        cycles_since_mark               ,
        number_of_repairs               ,
        attribute_category              ,
        attribute1                      ,
        attribute2                      ,
        attribute3                      ,
        attribute4                      ,
        attribute5                      ,
        attribute6                      ,
        attribute7                      ,
        attribute8                      ,
        attribute9                      ,
        attribute10                     ,
        attribute11                     ,
        attribute12                     ,
        attribute13                     ,
        attribute14                     ,
        attribute15
        from wsm_serial_txn_temp
        where header_id = p_move_txn_id
        and transaction_type_id = 2
        and action_flag IN (5,6); -- select the move/scrap

        l_wsm_serial_num_tbl   WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL;
        l_old_scrap_txn_id     NUMBER;
        l_old_move_txn_id      NUMBER;
        l_serial_start_op      NUMBER;
        l_serial_track_flag    NUMBER;
        l_serial_ctrl_code     NUMBER;
        l_first_serial_txn_id  NUMBER;


-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.Move_forms_serial_proc';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

BEGIN
        l_stmt_num := 10;
        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Entered wsm.plsql.WSM_SERIAL_SUPPORT_PVT.Move_forms_serial_proc',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        -- Validate the item_id/job for serial control..
        get_serial_track_info( p_serial_item_id         => p_inventory_item_id,
                               p_organization_id        => p_organization_id,
                               p_wip_entity_id          => p_wip_entity_id,
                               x_serial_start_flag      => l_serial_track_flag,
                               x_serial_ctrl_code       => l_serial_ctrl_code,
                               x_first_serial_txn_id    => l_first_serial_txn_id,
                               x_serial_start_op        => l_serial_start_op,
                               x_return_status          => x_return_status,
                               x_error_msg              => x_error_msg,
                               x_error_count            => x_error_count
                            );

        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

        IF p_move_txn_type IN (1,2) THEN -- Not undo/assembly return
                -- bulk collect from the cursor...
                open c_move_serials;
                fetch c_move_serials
                bulk collect into l_wsm_serial_num_tbl;
                close c_move_serials;

                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Total Rows : ' || l_wsm_serial_num_tbl.count,
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;
        ELSE
                select  max(wmt.transaction_id)
                into    l_old_move_txn_id
                from    wip_move_transactions wmt
                where   wmt.organization_id = p_organization_id
                and     wmt.wip_entity_id = p_wip_entity_id
                and     wmt.wsm_undo_txn_id IS NULL
                and     wmt.transaction_id = wmt.batch_id;

                BEGIN
                         select max(transaction_id)
                         into   l_old_scrap_txn_id
                         from   wip_move_transactions
                         where  organization_id = p_organization_id
                         and    wip_entity_id = p_wip_entity_id
                         and    batch_id = l_old_move_txn_id
                         and    transaction_id <> batch_id;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                null;
                END;
        END IF;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Invoking WSM_Serial_support_PVT.Move_serial_processor',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

        WSM_Serial_support_PVT.Move_serial_processor ( p_calling_mode           => 2                              ,
                                                       p_serial_num_tbl         => l_wsm_serial_num_tbl           ,
                                                       p_move_txn_type          => p_move_txn_type                ,
                                                       p_wip_entity_id          => p_wip_entity_id                ,
                                                       p_organization_id        => p_organization_id              ,
                                                       p_inventory_item_id      => p_inventory_item_id            ,
                                                       p_move_qty               => p_move_qty                     ,
                                                       p_scrap_qty              => p_scrap_qty                    ,
                                                       p_available_qty          => p_available_qty                ,
                                                       p_curr_job_op_seq_num    => p_curr_job_op_seq_num          ,
                                                       p_curr_job_intraop_step  => p_curr_job_intraop_step        ,
                                                       p_from_rtg_op_seq_num    => p_from_rtg_op_seq_num          ,
                                                       p_to_rtg_op_seq_num      => p_to_rtg_op_seq_num            ,
                                                       p_to_intraoperation_step => p_to_intraoperation_step       ,
                                                       p_job_serial_start_op    => l_serial_start_op              ,
                                                       p_user_serial_tracking   => p_user_serial_tracking         ,
                                                       p_move_txn_id            => p_move_txn_id                  ,
                                                       p_scrap_txn_id           => p_scrap_txn_id                 ,
                                                       p_old_move_txn_id        => l_old_move_txn_id              ,
                                                       p_old_scrap_txn_id       => l_old_scrap_txn_id             ,
                                                       x_serial_track_flag      => l_serial_track_flag            ,
                                                       x_return_status          => x_return_status                ,
                                                       x_error_msg              => x_error_msg                    ,
                                                       x_error_count            => x_error_count
                                        );
        if x_return_status <> G_RET_SUCCESS then
                IF x_return_status = G_RET_ERROR THEN
                        raise FND_API.G_EXC_ERROR;
                ELSIF x_return_status = G_RET_UNEXPECTED THEN
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
        end if;

        IF p_move_txn_type IN (2,3) THEN -- Assembly return and completion transaction...
                IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                        l_msg_tokens.delete;
                        WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                                p_msg_text          => 'Invoking WSM_Serial_support_PVT.Insert_move_attr',
                                                p_stmt_num          => l_stmt_num               ,
                                                p_msg_tokens        => l_msg_tokens             ,
                                                p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                                p_run_log_level     => l_log_level
                                                );
                END IF;

                -- Insert records into the WSM_SERIAL_TXN_TEMP for serial attributes...
                WSM_Serial_support_PVT.Insert_move_attr ( p_group_id            => null                         ,
                                                          p_move_txn_id         => p_move_txn_id                ,
                                                          p_scrap_txn_id        => p_scrap_txn_id               ,
                                                          x_return_status       => x_return_status              ,
                                                          x_error_count         => x_error_count                ,
                                                          x_error_msg           => x_error_msg
                                                         );

                if x_return_status <> G_RET_SUCCESS then
                        IF x_return_status = G_RET_ERROR THEN
                                raise FND_API.G_EXC_ERROR;
                        ELSIF x_return_status = G_RET_UNEXPECTED THEN
                                raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                end if;
        END IF;

        IF (G_LOG_LEVEL_STATEMENT >= l_log_level) THEN
                l_msg_tokens.delete;
                WSM_log_PVT.logMessage (p_module_name       => l_module ,
                                        p_msg_text          => 'Processing in WSM_Serial_support_PVT.Move_forms_serial_proc complete',
                                        p_stmt_num          => l_stmt_num               ,
                                        p_msg_tokens        => l_msg_tokens             ,
                                        p_fnd_log_level     => G_LOG_LEVEL_STATEMENT    ,
                                        p_run_log_level     => l_log_level
                                        );
        END IF;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := G_RET_ERROR;
                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := G_RET_UNEXPECTED;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
END Move_forms_serial_proc;

-- Procedure to dump the serial records' data....
Procedure log_serial_data ( p_serial_num_tbl              IN              WSM_Serial_Support_GRP.WSM_SERIAL_NUM_TBL  ,
                            x_return_status               OUT NOCOPY      VARCHAR2                                   ,
                            x_error_msg                   OUT NOCOPY      VARCHAR2                                   ,
                            x_error_count                 OUT NOCOPY      NUMBER
                          )  IS

-- This assumption is based that each individual column to be logged doesnt exceed 3900 chars... (that's the max...)
type t_log_message_tbl IS table OF varchar2(3900) index by binary_integer;

--  MESSAGE_TEXT column in FND_LOG_MESSAGES is 4000 characters long..
--  WSM_Log_PVT adds the date information in the start,,, so leave 50 characters for that
--  Effective length we would use is 3900

-- Logging variables.....
l_msg_tokens        WSM_Log_PVT.token_rec_tbl;
l_log_level         number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

l_stmt_num          NUMBER;
l_module            VARCHAR2(100) := 'wsm.plsql.WSM_SERIAL_SUPPORT_PVT.log_serial_data';
l_param_tbl         WSM_Log_PVT.param_tbl_type;
-- Logging variables...

l_message_tbl   t_log_message_tbl;
l_log_message   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
l_counter       NUMBER;
l_index         NUMBER;

BEGIN
        l_stmt_num      := 10;
        x_return_status := G_RET_SUCCESS;
        x_error_msg     := NULL;
        x_error_count   := 0;

        IF FND_LOG.LEVEL_PROCEDURE >= l_log_level THEN

                l_param_tbl.delete;
                l_param_tbl(1).paramName := 'p_serial_num_tbl.count';
                l_param_tbl(1).paramValue := p_serial_num_tbl.count;

                WSM_Log_PVT.logProcParams(p_module_name         => l_module,
                                          p_param_tbl           => l_param_tbl,
                                          p_fnd_log_level       => l_log_level
                                          );
        END IF;

        IF( g_log_level_statement   >= l_log_level ) THEN

                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                       p_msg_text           => 'Logging the transaction serial data..',
                                       p_stmt_num           => l_stmt_num               ,
                                       p_msg_tokens         => l_msg_tokens,
                                       p_fnd_log_level      => g_log_level_statement,
                                       p_run_log_level      => l_log_level
                                      );

                l_stmt_num      := 20;
                -- Loop and dump the data...
                l_index := p_serial_num_tbl.first;
                WHILE l_index IS NOT NULL LOOP

                        l_message_tbl.delete;

                        l_message_tbl(l_message_tbl.count+1) := 'serial_Number ['               ||  p_serial_num_tbl(l_index).serial_Number                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'Changed_wip_entity_name ['     ||  p_serial_num_tbl(l_index).Changed_wip_entity_name          || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'Assembly_item_id ['            ||  p_serial_num_tbl(l_index).Assembly_item_id                 || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'header_id ['                   ||  p_serial_num_tbl(l_index).header_id                        || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'Generate_serial_number ['      ||  p_serial_num_tbl(l_index).Generate_serial_number           || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'Generate_for_qty ['            ||  p_serial_num_tbl(l_index).Generate_for_qty                 || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'Action_flag ['                 ||  p_serial_num_tbl(l_index).Action_flag                      || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'Current_wip_entity_name ['     ||  p_serial_num_tbl(l_index).Current_wip_entity_name          || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'Current_wip_entity_id ['       ||  p_serial_num_tbl(l_index).Current_wip_entity_id            || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'Changed_wip_entity_id ['       ||  p_serial_num_tbl(l_index).Changed_wip_entity_id            || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'serial_attribute_category ['   ||  p_serial_num_tbl(l_index).serial_attribute_category        || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'territory_code ['              ||  p_serial_num_tbl(l_index).territory_code                   || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'origination_date ['            ||  p_serial_num_tbl(l_index).origination_date                 || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute1 ['                ||  p_serial_num_tbl(l_index).c_attribute1                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute2 ['                ||  p_serial_num_tbl(l_index).c_attribute2                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute3 ['                ||  p_serial_num_tbl(l_index).c_attribute3                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute4 ['                ||  p_serial_num_tbl(l_index).c_attribute4                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute5 ['                ||  p_serial_num_tbl(l_index).c_attribute5                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute6 ['                ||  p_serial_num_tbl(l_index).c_attribute6                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute7 ['                ||  p_serial_num_tbl(l_index).c_attribute7                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute8 ['                ||  p_serial_num_tbl(l_index).c_attribute8                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute9 ['                ||  p_serial_num_tbl(l_index).c_attribute9                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute10 ['               ||  p_serial_num_tbl(l_index).c_attribute10                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute11 ['               ||  p_serial_num_tbl(l_index).c_attribute11                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute12 ['               ||  p_serial_num_tbl(l_index).c_attribute12                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute13 ['               ||  p_serial_num_tbl(l_index).c_attribute13                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute14 ['               ||  p_serial_num_tbl(l_index).c_attribute14                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute15 ['               ||  p_serial_num_tbl(l_index).c_attribute15                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute16 ['               ||  p_serial_num_tbl(l_index).c_attribute16                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute17 ['               ||  p_serial_num_tbl(l_index).c_attribute17                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute18 ['               ||  p_serial_num_tbl(l_index).c_attribute18                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute19 ['               ||  p_serial_num_tbl(l_index).c_attribute19                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'c_attribute20 ['               ||  p_serial_num_tbl(l_index).c_attribute20                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'd_attribute1 ['                ||  p_serial_num_tbl(l_index).d_attribute1                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'd_attribute2 ['                ||  p_serial_num_tbl(l_index).d_attribute2                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'd_attribute3 ['                ||  p_serial_num_tbl(l_index).d_attribute3                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'd_attribute4 ['                ||  p_serial_num_tbl(l_index).d_attribute4                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'd_attribute5 ['                ||  p_serial_num_tbl(l_index).d_attribute5                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'd_attribute6 ['                ||  p_serial_num_tbl(l_index).d_attribute6                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'd_attribute7 ['                ||  p_serial_num_tbl(l_index).d_attribute7                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'd_attribute8 ['                ||  p_serial_num_tbl(l_index).d_attribute8                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'd_attribute9 ['                ||  p_serial_num_tbl(l_index).d_attribute9                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'd_attribute10 ['               ||  p_serial_num_tbl(l_index).d_attribute10                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'n_attribute1 ['                ||  p_serial_num_tbl(l_index).n_attribute1                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'n_attribute2 ['                ||  p_serial_num_tbl(l_index).n_attribute2                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'n_attribute3 ['                ||  p_serial_num_tbl(l_index).n_attribute3                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'n_attribute4 ['                ||  p_serial_num_tbl(l_index).n_attribute4                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'n_attribute5 ['                ||  p_serial_num_tbl(l_index).n_attribute5                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'n_attribute6 ['                ||  p_serial_num_tbl(l_index).n_attribute6                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'n_attribute7 ['                ||  p_serial_num_tbl(l_index).n_attribute7                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'n_attribute8 ['                ||  p_serial_num_tbl(l_index).n_attribute8                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'n_attribute9 ['                ||  p_serial_num_tbl(l_index).n_attribute9                     || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'n_attribute10 ['               ||  p_serial_num_tbl(l_index).n_attribute10                    || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'status_id ['                   ||  p_serial_num_tbl(l_index).status_id                        || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'time_since_new ['              ||  p_serial_num_tbl(l_index).time_since_new                   || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'cycles_since_new ['            ||  p_serial_num_tbl(l_index).cycles_since_new                 || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'time_since_overhaul ['         ||  p_serial_num_tbl(l_index).time_since_overhaul              || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'cycles_since_overhaul ['       ||  p_serial_num_tbl(l_index).cycles_since_overhaul            || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'time_since_repair ['           ||  p_serial_num_tbl(l_index).time_since_repair                || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'cycles_since_repair ['         ||  p_serial_num_tbl(l_index).cycles_since_repair              || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'time_since_visit ['            ||  p_serial_num_tbl(l_index).time_since_visit                 || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'cycles_since_visit ['          ||  p_serial_num_tbl(l_index).cycles_since_visit               || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'time_since_mark ['             ||  p_serial_num_tbl(l_index).time_since_mark                  || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'cycles_since_mark ['           ||  p_serial_num_tbl(l_index).cycles_since_mark                || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'number_of_repairs ['           ||  p_serial_num_tbl(l_index).number_of_repairs                || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute_category ['          ||  p_serial_num_tbl(l_index).attribute_category               || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute1 ['                  ||  p_serial_num_tbl(l_index).attribute1                       || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute2 ['                  ||  p_serial_num_tbl(l_index).attribute2                       || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute3 ['                  ||  p_serial_num_tbl(l_index).attribute3                       || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute4 ['                  ||  p_serial_num_tbl(l_index).attribute4                       || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute5 ['                  ||  p_serial_num_tbl(l_index).attribute5                       || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute6 ['                  ||  p_serial_num_tbl(l_index).attribute6                       || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute7 ['                  ||  p_serial_num_tbl(l_index).attribute7                       || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute8 ['                  ||  p_serial_num_tbl(l_index).attribute8                       || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute9 ['                  ||  p_serial_num_tbl(l_index).attribute9                       || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute10 ['                 ||  p_serial_num_tbl(l_index).attribute10                      || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute11 ['                 ||  p_serial_num_tbl(l_index).attribute11                      || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute12 ['                 ||  p_serial_num_tbl(l_index).attribute12                      || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute13 ['                 ||  p_serial_num_tbl(l_index).attribute13                      || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute14 ['                 ||  p_serial_num_tbl(l_index).attribute14                      || ']';
                        l_message_tbl(l_message_tbl.count+1) := 'attribute15 ['                 ||  p_serial_num_tbl(l_index).attribute15                      || ']';

                        -- Log the constructed data...
                        l_counter := l_message_tbl.first;
                        l_log_message := null;

                        l_stmt_num      := 30;

                        WHILE l_counter IS NOT NULL LOOP
                                IF length(l_log_message || l_message_tbl(l_counter)) > 3900 THEN
                                        -- Log the data in l_log_message...
                                        WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                               p_msg_text           => l_log_message            ,
                                                               p_stmt_num           => l_stmt_num               ,
                                                               p_msg_tokens         => l_msg_tokens             ,
                                                               p_fnd_log_level      => g_log_level_statement    ,
                                                               p_run_log_level      => l_log_level
                                                              );
                                        l_log_message := null;
                                END IF;

                                l_log_message := l_log_message || l_message_tbl(l_counter);
                                l_counter     := l_message_tbl.next(l_counter);

                        END LOOP;

                        l_stmt_num      := 40;
                        -- Log the remainder data..
                        IF l_log_message IS NOT NULL THEN
                                -- Log the data in l_log_message...
                                WSM_log_PVT.logMessage(p_module_name        => l_module                 ,
                                                       p_msg_text           => l_log_message            ,
                                                       p_stmt_num           => l_stmt_num               ,
                                                       p_msg_tokens         => l_msg_tokens             ,
                                                       p_fnd_log_level      => g_log_level_statement    ,
                                                       p_run_log_level      => l_log_level
                                                      );

                        END IF;

                        l_index := p_serial_num_tbl.next(l_index);
                END LOOP;
        END IF;
        l_stmt_num      := 50;
EXCEPTION
        WHEN OTHERS THEN

                 x_return_status := G_RET_UNEXPECTED;

                 IF (G_LOG_LEVEL_UNEXPECTED >= l_log_level)              OR
                   (FND_MSG_PUB.check_msg_level(G_MSG_LVL_UNEXP_ERROR))
                THEN
                        WSM_log_PVT.handle_others( p_module_name            => l_module                 ,
                                                   p_stmt_num               => l_stmt_num               ,
                                                   p_fnd_log_level          => G_LOG_LEVEL_UNEXPECTED   ,
                                                   p_run_log_level          => l_log_level
                                                 );
                END IF;

                FND_MSG_PUB.Count_And_Get (   p_encoded           =>      'F'                   ,
                                              p_count             =>      x_error_count         ,
                                              p_data              =>      x_error_msg
                                          );
END log_serial_data;

end WSM_Serial_support_PVT;

/
