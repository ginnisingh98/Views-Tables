--------------------------------------------------------
--  DDL for Package WSMPUTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPUTIL" AUTHID CURRENT_USER AS
/* $Header: WSMUTILS.pls 120.1.12010000.3 2008/10/22 10:35:57 ybabulal ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name     : wsmutilb.pls                                              |
| Description   : Contains the following procedures :
|       FUNCTION    CHECK_WSM_ORG
|       PROCEDURE   find_routing_start              - overridden
|       PROCEDURE   find_routing_end                - overridden
|       FUNCTION    GET_SCHEDULED_DATE              - overridden
|       FUNCTION    GET_DEF_ACCT_CLASS_CODE
|       PROCEDURE   GET_DEF_COMPLETION_SUB_DTLS     - overridden
|       FUNCTION    primary_loop_test
|       PROCEDURE   GET_DEFAULT_SUB_LOC
|       PROCEDURE   UPDATE_SUB_LOC
|       FUNCTION    CHECK_IF_ORG_IS_VALID
|       PROCEDURE   WRITE_TO_WIE
|       PROCEDURE   find_common_routing
|       FUNCTION    get_routing_start
|       FUNCTION    get_routing_end
|       FUNCTION    CHECK_COPROD_RELATION
|       FUNCTION    CHECK_COPROD_COMP_RELATION
|       FUNCTION    CHECK_COPROD_RELATION
|       FUNCTION    CHECK_100_PERCENT
|       PROCEDURE   AUTONOMOUS_TXN
|       PROCEDURE   OPERATION_IS_STANDARD_REPEATS   - overridden
|       PROCEDURE   validate_non_std_references
|       FUNCTION    WSM_ESA_ENABLED
|       FUNCTION    WSM_CHANGE_ESA_FLAG
|       FUNCTION    network_with_disabled_op
|       FUNCTION    primary_path_is_effective_till
|       FUNCTION    effective_next_op_exists
|       FUNCTION    effective_next_op_exits
|       FUNCTION    wlt_if_costed
|       PROCEDURE   check_charges_exist
|       FUNCTION    replacement_op_seq_id
|       FUNCTION    check_po_move
|       PROCEDURE   validate_lbj_before_close
|       PROCEDURE   get_Kanban_rec_grp_info
|       PROCEDURE   get_max_kanban_asmbly_qty
|       PROCEDURE   return_att_quantity
|       FUNCTION    check_osp_operation
|       FUNCTION    CHECK_WLMTI                     - overridden
|       FUNCTION    CHECK_WMTI                      - overridden
|       FUNCTION    CHECK_WSMT                      - overridden
|       FUNCTION    CHECK_WMT
|       FUNCTION    CHECK_WSMTI
|       FUNCTION    JOBS_WITH_QTY_AT_FROM_OP        - overridden
|       FUNCTION    CREATE_LBJ_COPY_RTG_PROFILE     - overridden
|       FUNCTION    GET_INV_ACCT_PERIOD
|       PROCEDURE   AUTONOMOUS_WRITE_TO_WIE
|       FUNCTION    GET_JOB_BOM_SEQ_ID
|       FUNCTION    replacement_copy_op_seq_id
|       FUNCTION    get_internal_copy_type
|   PROCEDURE   lock_wdj
|                                                                           |
| Revision                                                                  |
|  04/24/00   Anirban Dey       Initial Creation                            |
+==========================================================================*/


 l_debug VARCHAR2(1) := FND_PROFILE.VALUE('MRP_DEBUG');



 FUNCTION CHECK_WSM_ORG (
                p_organization_id   IN  NUMBER,
                x_err_code          OUT NOCOPY NUMBER,
                x_err_msg           OUT NOCOPY VARCHAR2
                ) RETURN INTEGER;


 PROCEDURE find_routing_start (
                p_routing_sequence_id     NUMBER,
        start_op_seq_id       OUT NOCOPY NUMBER,
        x_err_code            OUT NOCOPY NUMBER,
        x_err_msg             OUT NOCOPY VARCHAR2 );

-- BA: CZH.I_OED-1
 PROCEDURE find_routing_start (
                p_routing_sequence_id     NUMBER,
                p_routing_rev_date        DATE,
        start_op_seq_id       OUT NOCOPY NUMBER,
        x_err_code            OUT NOCOPY NUMBER,
        x_err_msg             OUT NOCOPY VARCHAR2 );
-- EA: CZH.I_OED-1


 PROCEDURE find_routing_end  (
                p_routing_sequence_id     NUMBER,
        end_op_seq_id         OUT NOCOPY NUMBER,
        x_err_code            OUT NOCOPY NUMBER,
        x_err_msg             OUT NOCOPY VARCHAR2 );

-- BA: CZH.I_OED-1
 PROCEDURE find_routing_end (
                p_routing_sequence_id     NUMBER,
                p_routing_rev_date        DATE,
        end_op_seq_id         OUT NOCOPY NUMBER,
        x_err_code            OUT NOCOPY NUMBER,
        x_err_msg             OUT NOCOPY VARCHAR2 );
-- EA: CZH.I_OED-1


 --
 -- This is an over-loaded function which calls the same function
 -- with p_quantity parameter.
 --
 -- This is created to circumvent the dependency issues esp. with forms
 --

 FUNCTION GET_SCHEDULED_DATE
                (
        p_organization_id       IN      NUMBER,
        p_primary_item_id    IN NUMBER,
        p_schedule_method       IN      VARCHAR2,
        p_input_date            IN      DATE,
                x_err_code              OUT NOCOPY     NUMBER,
                x_err_msg               OUT NOCOPY     VARCHAR2
                )
 RETURN DATE;

 --
 -- Since this is an overloaded function, we shouldn't have
 -- DEFAULT clause on p_quantity. Else, you'll get the following error
 -- while calling this function.
 -- PLS-00307: too many declarations of 'GET_SCHEDULED_DATE'
 --            match this call
 --

 FUNCTION GET_SCHEDULED_DATE (
        p_organization_id   IN  NUMBER,
        p_primary_item_id   IN  NUMBER,
            p_schedule_method   IN  VARCHAR2,
            p_input_date        IN  DATE,
        x_err_code   OUT NOCOPY NUMBER,
        x_err_msg    OUT NOCOPY VARCHAR2,
            p_quantity              IN  NUMBER  --Fixed bug #2313574
        ) RETURN DATE;



 FUNCTION GET_DEF_ACCT_CLASS_CODE (
        p_organization_id   IN  NUMBER,
        p_inventory_item_id IN  NUMBER,
        p_subinventory_name IN  VARCHAR2,
                x_err_code              OUT NOCOPY NUMBER,
                x_err_msg               OUT NOCOPY VARCHAR2
                ) RETURN VARCHAR2;


 PROCEDURE GET_DEF_COMPLETION_SUB_DTLS (
        p_organization_id       IN  NUMBER,
                p_routing_sequence_id   IN  NUMBER,
                x_subinventory_code     OUT NOCOPY VARCHAR2,
        x_locator_id     OUT NOCOPY NUMBER,
                x_err_code              OUT NOCOPY NUMBER,
                x_err_msg               OUT NOCOPY VARCHAR2
                );

 -- CZH: overloading function
 PROCEDURE GET_DEF_COMPLETION_SUB_DTLS (
        p_organization_id       IN  NUMBER,
                p_routing_sequence_id   IN  NUMBER,
                p_routing_revision_date IN  DATE,
                x_subinventory_code     OUT NOCOPY VARCHAR2,
        x_locator_id     OUT NOCOPY NUMBER,
                x_err_code              OUT NOCOPY NUMBER,
                x_err_msg               OUT NOCOPY VARCHAR2
                );

 FUNCTION  primary_loop_test(
                p_routing_sequence_id     NUMBER,
        start_id                  NUMBER,
        end_id                    NUMBER,
        x_err_code            OUT NOCOPY NUMBER,
        x_err_msg             OUT NOCOPY VARCHAR2
                ) RETURN NUMBER;


 PROCEDURE GET_DEFAULT_SUB_LOC (
                p_org_id                  IN  NUMBER ,
        p_routing_sequence_id     IN  NUMBER,
        p_end_id                  IN  NUMBER,
        x_completion_subinventory OUT NOCOPY VARCHAR2,
        x_inventory_location_id   OUT NOCOPY NUMBER,
        x_err_code                OUT NOCOPY NUMBER,
        x_err_msg                 OUT NOCOPY VARCHAR2 );


 PROCEDURE UPDATE_SUB_LOC (
                p_routing_sequence_id     IN  NUMBER,
        p_completion_subinventory IN  VARCHAR2,
        p_inventory_location_id   IN  NUMBER,
        x_err_code                OUT NOCOPY NUMBER,
        x_err_msg                 OUT NOCOPY VARCHAR2 );

/*BA#1577747*/
/* Given a routing sequence id, this procedure will find the
** root of the common routing sequence id associated with it.
*/

 PROCEDURE find_common_routing (
                p_routing_sequence_id        IN  NUMBER,
        p_common_routing_sequence_id OUT NOCOPY NUMBER,
        x_err_code                   OUT NOCOPY NUMBER,
        x_err_msg                    OUT NOCOPY VARCHAR2 );
/*EA#1577747*/

/*
** Function to check if an Organization is eligible to be a
** WSM Organization. The following checks are done;
** 1. Org should be a standard costing org.
** 2. Org should have the item lot number uniqueness set to NONE.
** 3. Org should have WIP Parameters lotnumber default type set to
** JobName.
*/

 FUNCTION CHECK_IF_ORG_IS_VALID (
                p_organization_id   IN  NUMBER,
                x_err_code          OUT NOCOPY NUMBER,
                x_err_msg           OUT NOCOPY VARCHAR2
                ) RETURN INTEGER;



 PROCEDURE WRITE_TO_WIE (
                p_header_id              IN  NUMBER,
        p_message                IN  VARCHAR2,
        p_request_id             IN  NUMBER,
        p_program_id             IN  NUMBER,
        p_program_application_id IN  NUMBER,
        p_message_type           IN  NUMBER,
        x_err_code               OUT NOCOPY NUMBER,
            x_err_msg                OUT NOCOPY VARCHAR2);


-- BA OSFM-APS integration.
-- Function submitted by Raghav Raghavacharya for OSFM-APS integration.
-- Added to this file by Sadiq

 FUNCTION get_routing_end(
                p_routing_sequence_id IN NUMBER
                ) RETURN NUMBER;


 FUNCTION get_routing_start(
                p_routing_sequence_id IN NUMBER
                ) RETURN NUMBER;
-- EA OSFM-APS integration.


-- Added on 12.29.2000 to fix Bug # 1418785.
-- This procedure checks if a co-product relationship
-- exists for a given bill sequence.
 FUNCTION CHECK_COPROD_RELATION (
                p_bom_bill_seq_id       IN NUMBER,
                x_err_code              OUT NOCOPY NUMBER,
                x_err_msg               OUT NOCOPY VARCHAR2
                ) RETURN BOOLEAN;


-- Function overloaded by BBK for BOM BUg#2046999
 FUNCTION CHECK_COPROD_RELATION (
                p_bom_bill_seq_id       IN NUMBER
                ) RETURN NUMBER;


-- Added for checking that the sum of planning percentages
-- for links originating from each node is exactly 100
 FUNCTION CHECK_100_PERCENT (
                p_routing_sequence_id   IN  NUMBER,
                x_err_code              OUT NOCOPY NUMBER,
                x_err_msg               OUT NOCOPY VARCHAR2
                ) RETURN NUMBER;


 PROCEDURE AUTONOMOUS_TXN (
                p_user                   IN NUMBER,
            p_login                  IN NUMBER,
            p_header_id              IN NUMBER,
                p_message                IN VARCHAR2,
                p_request_id             IN NUMBER,
                p_program_id             IN NUMBER,
                p_program_application_id IN NUMBER,
                p_message_type           IN NUMBER,
        p_txn_id                 IN NUMBER,
                x_err_code               OUT NOCOPY NUMBER,
                x_err_msg                OUT NOCOPY VARCHAR2);

                        -- BA: NSO-WLT
 --
 -- This is an over-loaded function which calls the same function
 -- with p_routing_revision_date parameter.
 --
 -- This is created to circumvent the dependency issues esp. with forms
 --
 PROCEDURE OPERATION_IS_STANDARD_REPEATS (
        p_routing_sequence_id   IN NUMBER,
        p_standard_operation_id IN NUMBER,
        p_operation_code        IN VARCHAR2,
        p_organization_id       IN NUMBER, --BBK
        p_op_is_std_op          OUT NOCOPY NUMBER,
        p_op_repeated_times     OUT NOCOPY NUMBER,
        x_err_code              OUT NOCOPY NUMBER,
                x_err_msg               OUT NOCOPY VARCHAR2);
                        -- BA: NSO-WLT


 PROCEDURE OPERATION_IS_STANDARD_REPEATS (
        p_routing_sequence_id   IN NUMBER,
                p_routing_revision_date IN DATE,   -- ADD: CZH.I_OED-1
        p_standard_operation_id IN NUMBER,
        p_operation_code        IN VARCHAR2,
        p_organization_id       IN NUMBER, --BBK
        p_op_is_std_op          OUT NOCOPY NUMBER,
        p_op_repeated_times     OUT NOCOPY NUMBER,
        x_err_code              OUT NOCOPY NUMBER,
                x_err_msg               OUT NOCOPY VARCHAR2);


-- abb H
 procedure validate_non_std_references (
                p_assembly_item_id        IN NUMBER,
                p_routing_reference_id    IN NUMBER,
                p_bom_reference_id        IN NUMBER,
                p_alt_routing_designator  IN VARCHAR2,
                p_alt_bom_designator      IN VARCHAR2,
                p_organization_id         IN NUMBER,
                p_start_date              IN DATE,
                p_end_date                IN DATE,
                p_start_quantity          IN NUMBER,
                p_mrp_net_quantity        IN OUT NOCOPY  NUMBER,
                p_class_code              IN VARCHAR2,
                p_completion_subinventory IN VARCHAR2,
                p_completion_locator_id   IN NUMBER,
                p_firm_planned_flag       IN OUT NOCOPY NUMBER,
                p_bom_revision            IN OUT NOCOPY VARCHAR2,
                p_bom_revision_date       IN OUT NOCOPY DATE,
                p_routing_revision        IN OUT NOCOPY VARCHAR2,
                p_routing_revision_date   IN OUT NOCOPY DATE,
                x_routing_seq_id          OUT NOCOPY NUMBER,
                x_bom_seq_id              OUT NOCOPY NUMBER,
                validation_level          NUMBER,
                x_error_code              OUT NOCOPY NUMBER,
                x_err_msg                 OUT NOCOPY VARCHAR2);


-- abb H
 FUNCTION WSM_ESA_ENABLED (
                p_wip_entity_id IN  NUMBER DEFAULT NULL,
                err_code        OUT NOCOPY NUMBER,
                err_msg         OUT NOCOPY VARCHAR2,
        p_org_id        IN  NUMBER DEFAULT NULL,
        p_job_type      IN  NUMBER DEFAULT NULL
                ) RETURN INTEGER;


-- abb H
 FUNCTION WSM_CHANGE_ESA_FLAG (
                p_org_id IN  NUMBER,
                err_code OUT NOCOPY NUMBER,
                err_msg  OUT NOCOPY VARCHAR2
                ) RETURN INTEGER;


-- CZH.I_OED-1
--      return 0 if no disabled op is found in the routing
--      return 1 if disabled op's are found in the routing
 FUNCTION network_with_disabled_op (
                p_routing_sequence_id IN  NUMBER,
                p_routing_rev_date    IN  DATE,
                x_err_code            OUT NOCOPY NUMBER,
                x_err_msg             OUT NOCOPY VARCHAR2
                ) RETURN INTEGER;


-- CZH.I_OED-1
--      return 0 if network dose not have effective primary path up to p_op_seq_num
--      return 1 if network has effective primary path up to p_op_seq_num
 FUNCTION primary_path_is_effective_till (
                p_routing_sequence_id IN     NUMBER,
                p_routing_rev_date    IN     DATE,
                p_start_op_seq_id     IN OUT NOCOPY NUMBER,
                p_op_seq_num          IN     NUMBER,
                x_err_code            OUT NOCOPY    NUMBER,
                x_err_msg             OUT NOCOPY    VARCHAR2
                ) RETURN INTEGER;

-- CZH.I_OED-1
--      return 0 if current operation does not have effective next operation
--      return 1 if current operation has effective next operation
--      return 2 if current operation is the last operation
 FUNCTION effective_next_op_exists (
                p_organization_id     IN     NUMBER,
                p_wip_entity_id       IN     NUMBER,
                p_wo_op_seq_num       IN     NUMBER,
                p_end_op_seq_id       IN     NUMBER,  -- ADD: CZH.I_9999
                x_err_code            OUT NOCOPY    NUMBER,
                x_err_msg             OUT NOCOPY    VARCHAR2
                ) RETURN INTEGER;


--this is to make the UTIL compatible with 1158 + OED-1
--this function is called from Move Txn form/interface on OSFM 1158+OED-1 codeline
 FUNCTION effective_next_op_exits (
                p_organization_id     IN     NUMBER,
                p_wip_entity_id       IN     NUMBER,
                p_wo_op_seq_num       IN     NUMBER,
                x_err_code            OUT NOCOPY   NUMBER,
                x_err_msg             OUT NOCOPY   VARCHAR2
                ) RETURN INTEGER;

--this is to make the UTIL compatible with 1158 and 1157
--added function is specific customer fix.
 FUNCTION wlt_if_costed (
                p_wip_entity_id in number)
 RETURN NUMBER;


--VJ: Start additions for WLTEnh--
--Moved check_charges_exist from WSMPLTOP to here --
/*===========================================================================
  PROCEDURE NAME:       check_charges_exist
  Description: Checks if charges exist for this job 'p_wip_entity_id' at the
                operation 'p_op_seq_num' in the org 'p_organization_id'.

===========================================================================*/
 PROCEDURE check_charges_exist (
                p_wip_entity_id         IN      NUMBER,
                                p_organization_id       IN      NUMBER,
                                p_op_seq_num            IN      NUMBER,
                                p_op_seq_id             IN      NUMBER,
                                p_charges_exist         OUT NOCOPY     NUMBER,
                                p_manually_added_comp   OUT NOCOPY     NUMBER,
                                p_issued_material       OUT NOCOPY     NUMBER,
                                p_manually_added_resource OUT NOCOPY   NUMBER,
                                p_issued_resource       OUT NOCOPY     NUMBER,
                                x_error_code            OUT NOCOPY     NUMBER,
                                x_error_msg             OUT NOCOPY     VARCHAR2);


-- CZH.I_OED-2
--      return NULL if no effective replacement is found
 Function replacement_op_seq_id (
                p_op_seq_id               NUMBER,
                p_routing_rev_date        DATE
                ) RETURN INTEGER;

-- OSP

 FUNCTION check_po_move (
             p_sequence_id      NUMBER,
             p_sequence_id_type     VARCHAR2,
         p_routing_rev_date     DATE,
         x_err_code             OUT NOCOPY NUMBER,
         x_err_msg              OUT NOCOPY VARCHAR2
 ) RETURN BOOLEAN ;


 --
 -- Bugfix 2617330:
 --
 -- This new procedure will be used by WIP to determine if the lot based jobs
 -- can be closed or not. The API will accept 2 parameters: group_id and orgn_id
 -- Using these parameters, the API would identify all the lot based jobs in
 -- the table WIP_DJ_CLOSE_TEMP and validate these records.
 -- All jobs that fail in validation process would be printed and the value of
 -- column STATUS_TYPE  in wip_dj_close_temp would be updated to 99.
 -- In the end, the status of these jobs in wip_discrete_jobs will be updated to 15 (Failed Close)
 -- and records in wip_dj_close_temp with status 99 will be deleted.
 --
 -- x_err_code will be set to 0 if there are any unprocessed/uncosted txn.
 -- Otherwise, x_err_code will have a value of 1.
 --
 PROCEDURE validate_lbj_before_close (
            p_group_id          in number,
            p_organization_id   in number,
            x_err_code          out nocopy number,
            x_err_msg           out nocopy varchar2,
            x_return_status         out nocopy varchar2 );


 PROCEDURE get_Kanban_rec_grp_info (
                        p_organization_id       IN number,
                        p_kanban_assembly_id    IN number,
                        p_rtg_rev_date          IN date,
                        p_bom_seq_id            OUT NOCOPY number,
                        p_start_seq_num         OUT NOCOPY number,
                        p_error_code            OUT NOCOPY number,
                        p_error_msg             OUT NOCOPY varchar2);


 PROCEDURE get_max_kanban_asmbly_qty (
            p_bill_seq_id           IN  number,
                        p_component_item_id     IN  number,
                        p_bom_revision_date     IN  date,
                        p_start_seq_num         IN  number,
                        p_available_qty         IN  number,
                        p_max_asmbly_qty        OUT NOCOPY number,
                        p_error_code            OUT NOCOPY number,
                        p_error_msg             OUT NOCOPY varchar2);


 PROCEDURE return_att_quantity(
                        p_org_id           IN      number,
                        p_item_id          IN      number,
                        p_rev              IN      varchar2,
                        p_lot_no           IN      varchar2,
                        p_subinv           IN      varchar2,
                        p_locator_id       IN      number,
                        p_qoh              OUT NOCOPY     number,
                        p_atr              OUT NOCOPY     number,
                        p_att              OUT NOCOPY     number,
                        p_err_code         OUT NOCOPY     number,
                        p_err_msg          OUT NOCOPY     varchar2 );


 function  check_osp_operation ( p_wip_entity_id        IN NUMBER,
                p_operation_seq_num IN OUT NOCOPY NUMBER,
                p_organization_id   IN NUMBER )

 return boolean;

 --BA 2731019
 FUNCTION CHECK_COPROD_COMP_RELATION (
        p_bom_bill_seq_id       IN NUMBER,
        p_component_seq_id       IN NUMBER
 )
 RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES(CHECK_COPROD_COMP_RELATION, WNDS);
 --EA 2731019

  -----------------------------------------------------
   --bug fix:7387499 functions that are used in BOM_OPERATION_NETWORKS_V
   -- to fetch operation code and department code
   --of relatively effective operation at particular operation.
   ---------------------------------------------------
   FUNCTION EFFECTIVE_DATE(
                p_oper_seq_num NUMBER,
                p_routing_seq_id NUMBER,
                p_operation_type NUMBER
                ) RETURN DATE;

   FUNCTION get_eff_stdop_id(
                 p_stdop_id NUMBER,
                 p_opseq_id  NUMBER
                )  RETURN NUMBER;

   FUNCTION get_eff_dept_id(
                  p_dept_id NUMBER,
                  p_opseq_id NUMBER
                )  RETURN NUMBER;
   ------------------------------------------------------
   --END bug fix:7387499
   ---------------------------------------------------
 ------------------------------------------------------------
 -- FUNCTIONS THAT CHECK TXN and TXN INTERFACE TABLES
 ------------------------------------------------------------

    FUNCTION CHECK_WLMTI (
                p_wip_entity_id      IN  NUMBER,
                p_wip_entity_name    IN  VARCHAR2,
                p_header_id          IN  NUMBER,
                p_transaction_date   IN  DATE,
                x_err_code           OUT NOCOPY NUMBER,
                x_err_msg            OUT NOCOPY VARCHAR2
                ) RETURN NUMBER;

    --BA: 2804945, org_id messing, overloading function
    FUNCTION CHECK_WLMTI (
                  p_wip_entity_id      IN  NUMBER,
                  p_wip_entity_name    IN  VARCHAR2,
                  p_header_id          IN  NUMBER,
                  p_transaction_date   IN  DATE,
                  x_err_code           OUT NOCOPY NUMBER,
                  x_err_msg            OUT NOCOPY VARCHAR2,
          p_organization_id    IN NUMBER
    )
    RETURN NUMBER;
    --EA: 2804945

 ------------------------------------------------------------

    --Moved CHECK_WMTI from WSMPLOAD to here --
    FUNCTION CHECK_WMTI (
                   p_wip_entity_id      IN  NUMBER,
                   p_wip_entity_name    IN  VARCHAR2,
                   p_transaction_date   IN  DATE,
                   x_err_code           OUT NOCOPY NUMBER,
                   x_err_msg            OUT NOCOPY VARCHAR2
                   )
    RETURN NUMBER;

    --BA: 2804945, org_id messing, overloading function
    FUNCTION CHECK_WMTI (
                   p_wip_entity_id      IN  NUMBER,
                   p_wip_entity_name    IN  VARCHAR2,
                   p_transaction_date   IN  DATE,
                   x_err_code           OUT NOCOPY NUMBER,
                   x_err_msg            OUT NOCOPY VARCHAR2,
           p_organization_id    IN NUMBER
    )
    RETURN NUMBER;
    --EA: 2804945

 ------------------------------------------------------------

    FUNCTION CHECK_WMT (
                   x_err_code         OUT NOCOPY NUMBER,
                   x_err_msg          OUT NOCOPY VARCHAR2,
                   p_wip_entity_id    IN  NUMBER,
                   p_wip_entity_name  IN  VARCHAR2,
                   p_organization_id  IN  NUMBER,
                   p_transaction_date IN  DATE
    )
    RETURN NUMBER;

 ------------------------------------------------------------

    --Moved CHECK_WSMT from WSMPLOAD to here --
    FUNCTION CHECK_WSMT (
                   p_wip_entity_id      IN  NUMBER,
                   p_wip_entity_name    IN  VARCHAR2,
                   p_transaction_id     IN  NUMBER,
                   p_transaction_date   IN  DATE,
                   x_err_code           OUT NOCOPY NUMBER,
                   x_err_msg            OUT NOCOPY VARCHAR2
                   )
    RETURN NUMBER;

    --BA: 2804945, org_id messing, overloading function
    FUNCTION CHECK_WSMT (
                   p_wip_entity_id      IN  NUMBER,
                   p_wip_entity_name    IN  VARCHAR2,
                   p_transaction_id     IN  NUMBER,
                   p_transaction_date   IN  DATE,
                   x_err_code           OUT NOCOPY NUMBER,
                   x_err_msg            OUT NOCOPY VARCHAR2,
           p_organization_id    IN NUMBER
    )
    RETURN NUMBER;
    --EA: 2804945

 ------------------------------------------------------------

    FUNCTION CHECK_WSMTI (
                   x_err_code         OUT NOCOPY NUMBER,
                   x_err_msg          OUT NOCOPY VARCHAR2,
                   p_wip_entity_id    IN  NUMBER,
                   p_wip_entity_name  IN  VARCHAR2,
                   p_organization_id  IN  NUMBER,
                   p_transaction_date IN  DATE
    )
    RETURN NUMBER;

-- EA#2804945 - Organization_id missing for check for other txns.

--------------------------------------------------------------------
-- New Procedures/Functions added for DMF_PF.J or 11.5.10 ----------
--------------------------------------------------------------------
-- Import Network Routing Support through BOM Interface   ----------
--------------------------------------------------------------------
-- Bug#/Project: FP.J Import Network Rtg - 3088690
-- New or Overloaded: New
-- Release : 11.5.10.
-- Backward Compatible: YES
-- Modified by: Bala Balakumar.
--------------------------------------------------------------------
FUNCTION JOBS_WITH_QTY_AT_FROM_OP(
        x_err_code OUT NOCOPY NUMBER
        , x_err_msg OUT NOCOPY varchar2
        , p_operation_sequence_id IN NUMBER
        ) RETURN BOOLEAN;

--------------------------------------------------------------------
-- Bug#/Project: FP.J Import Network Rtg - 3088690
-- New or Overloaded: New and Overloaded
-- Release : 11.5.10.
-- Backward Compatible: YES
-- Modified by: Bala Balakumar.
--------------------------------------------------------------------
FUNCTION JOBS_WITH_QTY_AT_FROM_OP(
        x_err_code OUT NOCOPY NUMBER
        , x_err_msg OUT NOCOPY varchar2
        , p_routing_sequence_id IN NUMBER
        , p_operation_seq_num IN NUMBER
        ) RETURN BOOLEAN;
--------------------------------------------------------------------
-- Bug#/Project: FP.J - OSFM/APS P2 Integration.
-- New or Overloaded: New
-- Release : 11.5.10.
-- Backward Compatible: YES
-- Modified by: Bala Balakumar.
--------------------------------------------------------------------
FUNCTION CREATE_LBJ_COPY_RTG_PROFILE RETURN NUMBER;
--------------------------------------------------------------------
-- Bug#/Project: FP.J - OSFM/APS P2 Integration.
-- New or Overloaded: New and Overloaded
-- Release : 11.5.10.
-- Backward Compatible: YES
-- Modified by: Bala Balakumar.
--------------------------------------------------------------------
FUNCTION CREATE_LBJ_COPY_RTG_PROFILE(p_organization_id IN NUMBER) RETURN NUMBER;
--------------------------------------------------------------------

-- Bug#/Project: FP.J - Accounting Period consistent API
-- New or Overloaded: New
-- Release : 11.5.10.
-- Backward Compatible: YES
-- Modified by: Bala Balakumar.
-- RETURN value of 0 indicates the date is in a non-open period.
-- Exceptions should be handled by the calling programs.
--------------------------------------------------------------------
FUNCTION GET_INV_ACCT_PERIOD(
        x_err_code OUT NOCOPY NUMBER
        , x_err_msg OUT NOCOPY varchar2
        , p_organization_id IN NUMBER
        , p_date IN DATE) RETURN NUMBER;
--------------------------------------------------------------------


PROCEDURE AUTONOMOUS_WRITE_TO_WIE (
                p_header_id                 IN  NUMBER,
                p_message                   IN  VARCHAR2,
                p_request_id                IN  NUMBER,
                p_program_id                IN  NUMBER,
                p_program_application_id    IN  NUMBER,
                p_message_type              IN  NUMBER,
                x_err_code                  OUT NOCOPY NUMBER,
                x_err_msg                   OUT NOCOPY VARCHAR2);

------------------------------------------------------
-- Added this constant for APS Integration Project for Patchset J.
-- This constant's value will decide Option A/C behavior at site/org level
-- If = 'Y', site level parameter will govern Option A/C behavior for instance
-- If = 'N', wsm_parameters.plan_code will govern Option A/C for that org :
--       if plan_code is NULL,
--             site level profile value will indicate behavior for that org
--       else,
--             plan_code value will indicate behavior for that org
-- For ST onwards and for customers, this should **ALWAYS** be 'Y'
-- For development/support purposes **ONLY**, this can be 'N'

REFER_SITE_LEVEL_PROFILE CONSTANT VARCHAR2(1) := 'Y';


-----------------------------------------------------
-- get bom_sequence_id a given wip_entity_id
FUNCTION GET_JOB_BOM_SEQ_ID(
        p_wip_entity_id     in number
) RETURN NUMBER;


------------------------------------------------------
-- Start : Added to fix bug 3452913 --
FUNCTION replacement_copy_op_seq_id (
                p_job_op_seq_id   NUMBER,
                p_wip_entity_id   NUMBER
                ) RETURN INTEGER;
-- End : Added to fix bug 3452913 --

------------------------------------------------------
-- BA bug 3512105
-- will return WLBJ.internal_copy_type, return -3 if not available
FUNCTION get_internal_copy_type (
         p_wip_entity_id   NUMBER
) RETURN INTEGER;
-- EA bug 3512105

--bug 3754881
PROCEDURE lock_wdj(
      x_err_code                  OUT NOCOPY NUMBER
    , x_err_msg                   OUT NOCOPY VARCHAR2
    , p_wip_entity_id             IN NUMBER
    , p_rollback_flag               IN NUMBER);
--bug 3754881 end
--Bug 5182520:Added the following procedure to handle material status checks.
Function is_status_applicable(p_wms_installed           IN VARCHAR2,
                           p_trx_status_enabled         IN NUMBER,
                           p_trx_type_id                IN NUMBER,
                           p_lot_status_enabled         IN VARCHAR2,
                           p_serial_status_enabled      IN VARCHAR2,
                           p_organization_id            IN NUMBER,
                           p_inventory_item_id          IN NUMBER,
                           p_sub_code                   IN VARCHAR2,
                           p_locator_id                 IN NUMBER,
                           p_lot_number                 IN VARCHAR2,
                           p_serial_number              IN VARCHAR2,
			   x_error_msg                  OUT NOCOPY VARCHAR2)

return varchar2;

 -- This Function is added to support Add operations/links in LBJ Interface.
FUNCTION validate_job_network(
            p_wip_entity_id NUMBER,
            x_err_code OUT NOCOPY NUMBER,
            x_err_msg OUT NOCOPY VARCHAR2)
 RETURN NUMBER;


END WSMPUTIL;

/
