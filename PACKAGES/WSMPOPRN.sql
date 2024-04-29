--------------------------------------------------------
--  DDL for Package WSMPOPRN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPOPRN" AUTHID CURRENT_USER AS
/* $Header: WSMOPRNS.pls 120.3 2006/08/30 04:13:00 skaradib noship $ */

    l_debug VARCHAR2(1) := FND_PROFILE.VALUE('MRP_DEBUG');   -- czh:BUG1995161
    g_aps_wps_profile VARCHAR2(1);


/* EXPLODE_ROUTING

   This package creates operations, operation_resources, and
   operation_instructions for a job.  It does not attempt
   to schedule;  instead it sets all operation and resource
   start and end dates to the date parameters passed to this
   routine.

   You should pass a P_Commit of 1 unless called from the Customized
   Move transaction form
 */

PROCEDURE Add_Operation(
        p_transaction_type_id           IN      NUMBER,
    P_Commit            IN  NUMBER,
    X_Wip_Entity_Id         IN  NUMBER,
    X_Organization_Id       IN  NUMBER,
    X_From_Op           IN  NUMBER,
    X_To_Op             IN  NUMBER,
--NSO Modification by abedajna
    X_Standard_Operation_Id     IN  NUMBER,
    X_Op_Seq_Id                     IN      NUMBER,
    x_error_code                    OUT NOCOPY     NUMBER,
    x_error_msg                     OUT NOCOPY     VARCHAR2);

PROCEDURE Add_Operation(
    p_transaction_type_id           IN      NUMBER,
    P_Commit            IN  NUMBER,
    X_Wip_Entity_Id         IN  NUMBER,
    X_Organization_Id       IN  NUMBER,
    X_From_Op           IN  NUMBER,
    X_To_Op             IN  NUMBER,
--NSO Modification by abedajna
    X_Standard_Operation_Id     IN  NUMBER,
    X_Op_Seq_Id                     IN      NUMBER,
        x_error_code                    OUT NOCOPY     NUMBER,
        x_error_msg                     OUT NOCOPY     VARCHAR2,
    p_txn_quantity          IN  NUMBER,
    p_reco_op_flag          IN  VARCHAR2,
    p_to_rtg_op_seq_num         IN NUMBER,
    p_txn_date          IN  DATE,
    p_dup_val_ignore                IN      VARCHAR2,
    p_jump_flag                         IN  VARCHAR2);


--bug 3595728 added a new parameter p_txn_date
PROCEDURE Disable_operations (
    x_Wip_entity_id     IN  NUMBER,
    x_Organization_id   IN  NUMBER,
    x_From_op           IN  NUMBER,
    x_error_code        OUT NOCOPY NUMBER,
    x_err_msg           OUT NOCOPY VARCHAR2,
    p_txn_date          IN  DATE);


PROCEDURE Delete_Operation(
    X_Wip_Entity_Id     IN  NUMBER,
    X_Organization_id   IN  NUMBER,
--  X_From_Op       IN  NUMBER,
    X_To_Op         IN  NUMBER,
        x_error_code            OUT NOCOPY     NUMBER,
        x_error_msg             OUT NOCOPY     VARCHAR2);

/*  This procedure ensures that WIP_OPERATIONS.previous_operation_seq_num
    and WIP_OPERATIONS.next_operation_seq_num are correct following
    insert or deletion of an operation
 */
PROCEDURE set_prev_next
    (X_wip_entity_Id    IN  NUMBER,
     X_organization_Id  IN  NUMBER,
         x_error_code           OUT NOCOPY     NUMBER,
         x_error_msg            OUT NOCOPY     VARCHAR2);

PROCEDURE create_op_details
    (X_wip_entity_Id    IN  NUMBER,
     X_organization_Id  IN  NUMBER,
     X_op_seq_num       IN  NUMBER,
         x_error_code           OUT NOCOPY     NUMBER,
         x_error_msg            OUT NOCOPY     VARCHAR2);

/*  This procedure selects the operation seq and step that has quantity
    in it for a given Wip Entity Id.  For semicon implementation, there
    is guaranteed to be only one such operation

    The procedure also returns the next mandatory step within the
    operation if there is one.  It will return a value of 0 if there is no
    remaining mandatory step in the operation.

    Possible values returned for steps are:
    WIP_CONSTANTS.QUEUE
    WIP_CONSTANTS.RUN
    WIP_CONSTANTS.TOMOVE
*/

PROCEDURE get_current_op (
    p_wip_entity_id     IN  NUMBER,
    p_current_op_seq  OUT NOCOPY    NUMBER,
    p_current_op_step  OUT NOCOPY   NUMBER,
    p_next_mand_step  OUT NOCOPY    NUMBER,
        x_error_code            OUT NOCOPY     NUMBER,
        x_error_msg             OUT NOCOPY     VARCHAR2);

/* This function returns the next mandatory step in an operation
   given the current step and the mandatory_steps_flag (1-8) which
   indicates what the mandatory steps are within an operation

   Possible return values are:
    WIP_CONSTANTS.QUEUE
    WIP_CONSTANTS.RUN
    WIP_CONSTATNS.TOMOVE
    0   (indicating there is no remaining mandatory step)
 */

FUNCTION get_intra_operation_value
    (p_std_op_id    IN  NUMBER,
        x_error_code    OUT NOCOPY     NUMBER,
        x_error_msg     OUT NOCOPY     VARCHAR2
    ) RETURN NUMBER;

/* This function returns the value for queue, run and to move
   from mfg_lookups for the standard_operation_id
*/

FUNCTION get_next_mandatory_step(x_step IN NUMBER, x_flag IN NUMBER)
        RETURN NUMBER;

PROCEDURE get_sec_inv_loc(
    p_routing_seq_id        IN  NUMBER,
    x_secondary_invetory_name  OUT NOCOPY   VARCHAR2,
    x_secondary_locator      OUT NOCOPY     NUMBER,
        x_error_code         OUT NOCOPY     NUMBER,
        x_error_msg          OUT NOCOPY     VARCHAR2);

FUNCTION update_job_name (
    p_wip_entity_id IN  NUMBER,
    p_subinventory  IN  VARCHAR2,
    p_org_id    IN  NUMBER,
    p_txn_type  IN  NUMBER,
/*BA#1803065*/
    p_dup_job_name OUT NOCOPY VARCHAR2,
/*EA#1803065*/
        x_error_code    OUT NOCOPY     NUMBER,
        x_error_msg     OUT NOCOPY     VARCHAR2
    ) return VARCHAR2;

FUNCTION update_job_name (
    p_wip_entity_id IN  NUMBER,
    p_subinventory  IN  VARCHAR2,
    p_org_id    IN  NUMBER,
    p_txn_type  IN  NUMBER,
    p_update_flag   IN      BOOLEAN,
/*BA#1803065*/
    p_dup_job_name OUT NOCOPY VARCHAR2,
/*EA#1803065*/
        x_error_code    OUT NOCOPY     NUMBER,
        x_error_msg     OUT NOCOPY     VARCHAR2
    ) return VARCHAR2;

/*BA#1803065*/
PROCEDURE update_job_name1 (
    p_wip_entity_id IN  NUMBER,
    p_org_id    IN  NUMBER,
    p_reentered_job_name    IN OUT NOCOPY   VARCHAR2,
    x_error_code OUT NOCOPY NUMBER,
    x_error_msg OUT NOCOPY VARCHAR2
    );
/*EA#1803065*/

--Bug 2328947
PROCEDURE rollback_before_add_operation;

PROCEDURE copy_plan_to_execution(x_error_code OUT NOCOPY NUMBER
                , x_error_msg OUT NOCOPY VARCHAR2
                , p_org_id IN NUMBER
                , p_wip_entity_id IN NUMBER
                , p_to_job_op_seq_num IN NUMBER
                , p_to_rtg_op_seq_num IN NUMBER
                , p_to_op_seq_id IN NUMBER
                , p_reco_op_flag IN VARCHAR2
                , p_txn_quantity IN NUMBER
                , p_txn_date IN DATE
                , p_user IN NUMBER
                , p_login IN NUMBER
                , p_request_id IN NUMBER
                , p_program_application_id IN NUMBER
                , p_program_id IN NUMBER
                , p_dup_val_ignore IN VARCHAR2
                , p_start_quantity IN NUMBER);

PROCEDURE call_infinite_scheduler(
    x_error_code                OUT NOCOPY NUMBER,
    x_error_msg                 OUT NOCOPY VARCHAR2,
    p_jump_flag                 IN VARCHAR2,
    p_wip_entity_id             IN NUMBER,
    p_org_id                    IN NUMBER,
    p_to_op_seq_id              IN NUMBER,
    p_fm_job_op_seq_num             IN NUMBER,
    p_to_job_op_seq_num         IN NUMBER,
    p_scheQuantity              IN NUMBER);

--mes
Procedure copy_to_op_mes_info(
    p_wip_entity_id             IN NUMBER
    , p_to_job_op_seq_num           IN NUMBER
    , p_to_rtg_op_seq_num           IN NUMBER
    , p_txn_quantity            IN NUMBER
    , p_user                IN NUMBER
    , p_login               IN NUMBER
    , x_return_status                       OUT NOCOPY VARCHAR2
    , x_msg_count                           OUT NOCOPY NUMBER
    , x_msg_data                            OUT NOCOPY VARCHAR2
    );
--mes end

-- Begin Changes Bug 4614970 (FP Bug 4860613)
-- Procedure set_prev_next has been overloaded, two new parameters introduced from the earlier procedure definition

PROCEDURE set_prev_next (
    X_wip_entity_Id        IN      NUMBER,
    X_organization_Id      IN      NUMBER,
    X_from_op               IN  NUMBER,
    X_to_op                 IN  NUMBER,
    X_op_seq_incr      IN  NUMBER,
    x_error_code           OUT NOCOPY     NUMBER,
    x_error_msg            OUT NOCOPY     VARCHAR2
    );

--bug 5337172 intermediate function generated by rosetta
function update_job_name(p_wip_entity_id  NUMBER
    , p_subinventory  VARCHAR2
    , p_org_id  NUMBER
    , p_txn_type  NUMBER
    , p_update_flag  number
    , p_dup_job_name out nocopy  VARCHAR2
    , x_error_code out nocopy  NUMBER
    , x_error_msg out nocopy  VARCHAR2
  ) return varchar2;
--end bug 5337172
END WSMPOPRN;

 

/
