--------------------------------------------------------
--  DDL for Package WIP_OVERCOMPLETION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_OVERCOMPLETION" AUTHID CURRENT_USER AS
/* $Header: wipocmps.pls 120.0.12010000.1 2008/07/24 05:24:28 appldev ship $ */

/*=====================================================================+
 | PROCEDURE
 |   update_wip_req_operations_mmtt
 |
 | PURPOSE
 |  It updates the required quantity columns in WRO. This procedure is for
 | assemblies with Bill but no routing. Otherwise WRO will be updated as
 | part of the Move.
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

   procedure update_wip_req_operations_mmtt
   (
     P_CPL_TXN_ID     IN     NUMBER,
     P_USER_ID  IN     NUMBER default -1,
     P_LOGIN_ID IN     NUMBER default -1,
     P_REQ_ID   IN     NUMBER default -1,
     P_APPL_ID  IN     NUMBER default -1,
     P_PROG_ID  IN     NUMBER default -1
     ) ;

/*=====================================================================+
 | PROCEDURE
 |   update_wip_req_operations
 |
 | PURPOSE
 |  It updates the required quantity columns in WRO.
 |
 | ARGUMENTS
 |   P_GROUP_ID : Group Id.
 |   P_TRANSACTION_DATE
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

 procedure update_wip_req_operations
         ( P_GROUP_ID IN     NUMBER,
           P_TXN_DATE IN     VARCHAR2,
           P_USER_ID  IN     NUMBER default -1,
           P_LOGIN_ID IN     NUMBER default -1,
           P_REQ_ID   IN     NUMBER default -1,
           P_APPL_ID  IN     NUMBER default -1,
           P_PROG_ID  IN     NUMBER default -1
         );

 /*=====================================================================+
 | PROCEDURE
 |   update_wip_operations
 |
 | PURPOSE
 |   Updates the quantity in the queue step of the from operation for
 |   the child move transactions
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
   procedure update_wip_operations
   (
    p_txn_id   IN     NUMBER,    -- must be of the CHILD
    P_GROUP_ID IN     NUMBER,
    P_TXN_DATE IN     VARCHAR2,
    P_USER_ID  IN     NUMBER default -1,
    P_LOGIN_ID IN     NUMBER default -1,
    P_REQ_ID   IN     NUMBER default -1,
    P_APPL_ID  IN     NUMBER default -1,
    P_PROG_ID  IN     NUMBER default -1
    );

/*=====================================================================+
 | PROCEDURE
 |   insert_child_move_txn
 |
 | PURPOSE
 |      Inserts the child WIP Move transaction for an Overcompletion
 | transaction.
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

   PROCEDURE insert_child_move_txn
   (
    p_primary_quantity        IN   NUMBER,
    p_parent_txn_id           IN   NUMBER,
    p_move_profile            IN   NUMBER,
    p_sched_id                IN   NUMBER,
    p_user_id                 IN   NUMBER default -1,
    p_login_id                IN   NUMBER default -1,
    p_req_id                  IN   NUMBER default -1,
    p_appl_id                 IN   NUMBER default -1,
    p_prog_id                 IN   NUMBER default -1,
    p_child_txn_id         IN OUT NOCOPY  NUMBER,
    p_oc_txn_id               OUT NOCOPY  NUMBER,
    p_first_operation_seq_num OUT NOCOPY  NUMBER,
    p_first_operation_code    OUT NOCOPY  VARCHAR2,
    p_first_department_id     OUT NOCOPY  NUMBER,
    p_first_department_code   OUT NOCOPY  VARCHAR2,
    p_err_mesg                OUT NOCOPY  VARCHAR2
    );


/*=====================================================================+
 | PROCEDURE
 |   undo_overcompletion
 |
 | PURPOSE
 |    Resets the "Required quantity" field of wip_requirement_operations
 | during Unrelease of a Job since Overcompletions would have updated it
 | if there were any overcompletions.
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

PROCEDURE undo_overcompletion
                   (p_org_id        IN NUMBER,
                    p_wip_entity_id IN NUMBER,
                    p_rep_id        IN NUMBER DEFAULT NULL);



 /*=====================================================================+
 | PROCEDURE
 |   delete_child_rows
 |
 | PURPOSE
 |      This call would delete the child rows that have the fm_op &
 |      to_op to be the first operation and the step types to be
 |      'Queue'.
 |
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

   PROCEDURE delete_child_records
   (
    p_group_id    IN    NUMBER,
    p_txn_date    IN    VARCHAR2,
    p_outcome     OUT NOCOPY   NUMBER
    );

 /*=====================================================================+
 | PROCEDURE
 |   check_tolerance
 |
 | PURPOSE
 |    This procedure would check if the transaciton primary quantity +
 | total quantity already in the job would still be less than the tolerance.
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |     p_quantity_left = -1 ==> Infinity
 |                     = 0  ==> Not enough
 |
 +=====================================================================*/

   PROCEDURE check_tolerance
   (
    p_organization_id             IN   NUMBER,
    p_wip_entity_id               IN   NUMBER,
    p_repetitive_schedule_id      IN   NUMBER DEFAULT NULL,
    p_primary_quantity            IN   NUMBER,
    p_result                      OUT NOCOPY  NUMBER  -- 1 = yes, 2 = No
    );

 /*=====================================================================+
 | PROCEDURE
 |   get_tolerance_default
 |
 | PURPOSE
 |    This procedure takes as input the assembly item id and returns the
 | tolerance column values.
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

    PROCEDURE get_tolerance_default
   (
    p_primary_item_id             IN      NUMBER,
    p_org_id                      IN      NUMBER,
    p_tolerance_type              OUT NOCOPY     NUMBER,
    p_tolerance_value             OUT NOCOPY     NUMBER
    );

 /*=====================================================================+
 | PROCEDURE
 |   insert_oc_move_txn
 |
 | PURPOSE
 |      Inserts the child WIP Move transaction for an Overcomplete transaction.
 |   This is used for Assembly Completion
 | ARGUMENTS
 |
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/

   PROCEDURE insert_oc_move_txn
   (
    p_primary_quantity        IN   NUMBER,
    p_cpl_profile             IN   NUMBER,
    p_oc_txn_id               IN   NUMBER,
    p_parent_cpl_txn_id       IN   NUMBER,
    p_first_schedule_id       IN   NUMBER,
    p_user_id                 IN   NUMBER default -1,
    p_login_id                IN   NUMBER default -1,
    p_req_id                  IN   NUMBER default -1,
    p_appl_id                 IN   NUMBER default -1,
    p_prog_id                 IN   NUMBER default -1,
    p_child_txn_id            IN OUT NOCOPY  NUMBER,
    p_first_operation_seq_num OUT NOCOPY  NUMBER,
    p_err_mesg                OUT NOCOPY  VARCHAR2
    );

END WIP_OVERCOMPLETION;

/
