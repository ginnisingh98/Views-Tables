--------------------------------------------------------
--  DDL for Package FLM_EXECUTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_EXECUTION_UTIL" AUTHID CURRENT_USER AS
/* $Header: FLMEXUTS.pls 120.8.12010000.2 2009/06/22 09:40:36 adasa ship $  */

  FUNCTION get_view_all_schedules(
                                 p_organization_id IN NUMBER,
                                 p_line_id         IN NUMBER,
                                 p_operation_id    IN NUMBER
                                 ) RETURN VARCHAR2;

  FUNCTION view_all_schedules(i_op_seq_id  IN NUMBER) RETURN VARCHAR2;

FUNCTION workstation_enabled(i_op_seq_id  IN NUMBER) RETURN VARCHAR2;

  /******************************************************************
   * To get workstation_enabled flag for given preference by        *
   * (org_id, line_id, operation_id). If the pref. does not exist,  *
   * retrieve it from its upper-leve; if the upper-level does not   *
   * exist, return the default flag 'Y'                             *
   ******************************************************************/
PROCEDURE get_workstation_enabled(
				 p_organization_id IN NUMBER,
				 p_line_id IN NUMBER,
				 p_operation_id IN NUMBER,
                                 p_init_msg_list IN VARCHAR2,
				 x_workstation_enabled OUT NOCOPY VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY NUMBER,
                                 x_msg_data OUT NOCOPY VARCHAR2
                                 );

/**********************************************
 * This function checks whether an operation  *
 * of a flow schedule is eligible to be worked*
 * on and/or completed.                       *
 **********************************************/
FUNCTION Operation_Eligible(i_org_id	number,
                            i_wip_entity_id 	number,
                            i_std_op_id	number) RETURN VARCHAR2;

PROCEDURE complete_operation(i_org_id number,
				i_wip_entity_id	number,
				i_op_seq_id	number,
				i_next_op_id	number);


G_SUPPLY_TYPE_PHANTOM CONSTANT NUMBER := 6;
G_OP_TYPE_LINEOP CONSTANT NUMBER := 3;
G_OP_TYPE_EVENT CONSTANT NUMBER := 1;
G_INHERIT_PHANTOM_YES NUMBER := 1;
G_INHERIT_PHANTOM_NO NUMBER := 2;
G_REF_DESIG_SEPARATOR VARCHAR2(1) := ',';
G_REF_DESIG_TERMINATOR VARCHAR2(3) := '...';
G_REF_DESIG_MAX_COUNT NUMBER := 3;
G_BFLUSH_OPTION_ACT_PRI NUMBER := 1;
G_BFLUSH_OPTION_ALL NUMBER := 2;

TYPE FLM_CUST_ATTRIBUTE IS RECORD
(
  ATTRIBUTE_NAME         VARCHAR2(240),
  ATTRIBUTE_VALUE        VARCHAR2(2000)
);

TYPE FLM_CUST_ATTRIBUTE_TBL IS TABLE OF FLM_CUST_ATTRIBUTE
  INDEX BY BINARY_INTEGER;

/******************************************************************
 * To get the customized attributes for lineop/event              *
 ******************************************************************/
PROCEDURE get_custom_attributes (p_wip_entity_id IN NUMBER,
                                 p_op_seq_id IN NUMBER,
                                 p_op_type IN NUMBER, --1event,2process,3lineop
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY NUMBER,
                                 x_msg_data OUT NOCOPY VARCHAR2,
                                 x_cust_attrib_tab OUT NOCOPY System.FlmCustomPropRecTab);


/******************************************************************
 * Public API to get the customized attributes for lineop/event   *
 * User only need to modify this procedure acc to requirments     *
 *                                                                *
 * DESCRIPTION OF PARAMETERS                                      *
 *                                                                *
 *  p_version_number : This stores the version number of the API. *
 *                     It is seeded as 1.0. You can use this to   *
 *                     keep track of the current version.         *
 *  p_wip_entity     : wip entity id of flow schedule             *
 *  p_op_seq_id      : op sequence id of this operation/event     *
 *  p_op_type        : operation type 1=event, 2=process,         *
 *                     3=lineop                                   *
 *  p_cust_attrib_tab : table of records to keep attributes       *
 *                      see definition of FLM_CUST_ATTRIBUTE_TBL  *
 *  x_return_status  : 'S' for success, 'E' for error             *
 *  x_msg_count      : total number of messages                   *
 *  x_msg_data       : return messages                            *
 *                                                                *
 ******************************************************************/
PROCEDURE get_attributes (p_api_version_number IN  NUMBER,
                          p_wip_entity_id      IN  NUMBER,
                          p_op_seq_id          IN  NUMBER,
                          p_op_type            IN  NUMBER,
                          p_cust_attrib_tab    OUT NOCOPY FLM_CUST_ATTRIBUTE_TBL,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2);

/**********************************************
 * This function checks whether a component is*
 * all the way child of any phantom           *
 **********************************************/
FUNCTION check_phantom (p_top_bill_seq_id NUMBER,
                        p_explosion_type VARCHAR2,
                        p_org_id IN NUMBER,
                        p_comp_seq_id IN NUMBER,
                        p_sort_order IN VARCHAR2) RETURN NUMBER;

/**********************************************
 * This function finds out the current rev for*
 * a given component. Used by workstation     *
 * components tab                             *
 **********************************************/
FUNCTION get_current_rev (p_org_id NUMBER,
                          p_component_item_id NUMBER) RETURN VARCHAR2;


/**********************************************
 * This function returns the string of        *
 *  reference designators for a component     *
 **********************************************/
FUNCTION get_reference_designator(p_comp_seq_id NUMBER) RETURN VARCHAR2;


/**********************************************
 * This procedure calls the pick release api  *
 * and return the pass/fail status            *
 * return_status = 'S' for success            *
 * return_status = 'F' for fail               *
 **********************************************/
procedure pick_release(p_wip_entity_id NUMBER,
                       p_org_id NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_data OUT NOCOPY VARCHAR2);


/****************************************************
 * This function  finds out if the current move     *
 * is within from primary path or from feeder line  *
 * return_status = 'Y' for feeder move              *
 * return_status = 'N' for primary path move        *
 ***************************************************/
function is_move_from_feeder(p_from_op_seq_id NUMBER,
                              p_to_op_seq_id NUMBER) return VARCHAR2;



procedure generate_serial_to_record(p_org_id          IN NUMBER,
                                    p_wip_entity_id   IN NUMBER,
                                    p_primary_item_id IN NUMBER,
                                    p_gen_qty         IN NUMBER,
                                    x_ret_code        OUT NOCOPY VARCHAR2,
                                    x_msg_buf         OUT NOCOPY VARCHAR2);



PROCEDURE generate_lot_to_record (p_org_id          IN NUMBER,
                                  p_primary_item_id IN NUMBER,
                                  o_lot_number      OUT NOCOPY VARCHAR2,
                                  x_return_status   OUT NOCOPY VARCHAR2,
                                  x_msg_count       OUT NOCOPY NUMBER,
                                  x_msg_data        OUT NOCOPY VARCHAR2);

TYPE operation_seq_tbl_type IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

PROCEDURE get_eligible_ops (p_org_id        IN NUMBER,
                            p_line_id       IN NUMBER,
                            p_rtg_seq_id    IN NUMBER,
                            p_wip_entity_id IN NUMBER,
                            x_lop_tbl       OUT NOCOPY operation_seq_tbl_type);

FUNCTION get_backflush_option(p_org_id IN NUMBER, p_line_id IN NUMBER) RETURN NUMBER;


PROCEDURE get_backflush_comps(
  p_wip_ent_id      in  number default NULL,
  p_line_id         in  number default NULL,
  p_assyID          in  number,
  p_orgID           in  number,
  p_qty             in  number,
  p_altBomDesig     in  varchar2,
  p_altOption       in  number,
  p_bomRevDate      in  date default NULL,
  p_txnDate         in  date,
  p_projectID       in  number,
  p_taskID          in  number,
  p_toOpSeqNum      in  number,
  p_altRoutDesig    in  varchar2,
  x_compInfo        in out nocopy system.wip_lot_serial_obj_t,
  x_returnStatus    out nocopy varchar2);


PROCEDURE default_comp_lot_serials(
  p_wip_ent_id      in  number default NULL,
  p_line_id         in  number default NULL,
  p_assyID          in  number,
  p_orgID           in  number,
  p_qty             in  number,
  p_altBomDesig     in  varchar2,
  p_altOption       in  number,
  p_bomRevDate      in  date default NULL,
  p_txnDate         in  date,
  p_projectID       in  number,
  p_taskID          in  number,
  p_toOpSeqNum      in  number,
  p_altRoutDesig    in  varchar2,
  x_compTbl         in out nocopy system.wip_lot_serial_obj_t,
  x_returnStatus    out nocopy varchar2);

PROCEDURE merge_backflush_comps(
  p_wip_ent_id      in  number default NULL,
  p_line_id         in  number default NULL,
  p_assyID          in  number,
  p_orgID           in  number,
  p_qty             in  number,
  p_altBomDesig     in  varchar2,
  p_altOption       in  number,
  p_bomRevDate      in  date default NULL,
  p_txnDate         in  date,
  p_projectID       in  number,
  p_taskID          in  number,
  p_toOpSeqNum      in  number,
  p_rtg_seq_id      in  number,
  x_compTbl         in out nocopy system.wip_lot_serial_obj_t,
  x_returnStatus    out nocopy varchar2);


FUNCTION scheduleRecordedDetailsExist(orgId Number, wipEntId Number)
  return VARCHAR2;

FUNCTION scheduleRecordedDetailsExist(orgId Number, schNum Varchar2)
  return VARCHAR2;

FUNCTION kanban_card_activity_exist(p_wip_entity_id IN NUMBER)
RETURN NUMBER;

PROCEDURE exp_ser_single_op(p_org_id IN NUMBER, p_wip_entity_id NUMBER,
p_operation_seq_num NUMBER);


PROCEDURE exp_ser_single_item(p_org_id IN NUMBER, p_wip_entity_id NUMBER,
p_operation_seq_num NUMBER, p_inventory_item_id NUMBER);

PROCEDURE exp_ser_single_range(p_org_id IN NUMBER, p_wip_entity_id NUMBER,
  p_operation_seq_num NUMBER, p_inventory_item_id NUMBER, p_fm_serial VARCHAR2,
  p_to_serial VARCHAR2, p_parent_serial_number VARCHAR2, p_lot_number VARCHAR2);

FUNCTION get_single_assy_ser(p_org_id IN NUMBER, p_inv_item_id IN NUMBER)
  RETURN VARCHAR2;

FUNCTION get_single_assy_lot(p_org_id IN NUMBER, p_inv_item_id IN NUMBER)
  RETURN VARCHAR2;

FUNCTION get_txn_bfcomp_cnt(txn_intf_id NUMBER)
  RETURN NUMBER;

FUNCTION get_ser_range_cnt(p_fm_serial VARCHAR2, p_to_serial VARCHAR2)
  RETURN NUMBER;

FUNCTION non_txncomp_exist(p_wip_entity_id IN NUMBER, p_org_id IN NUMBER)
  RETURN NUMBER;

/*Added for bugfix 6152984 */
/****************************************************
    * This function  finds out if any event is         *
    * attached to the operation seq based on passed    *
    * std op in the routing for this schedule          *
    * return_status = 'Y' for One or more Event Exist  *
    * return_status = 'N' for No event exist           *
    ***************************************************/
 function event_exist(p_org_id NUMBER,
                      p_wip_entity_id NUMBER,
                      p_std_op_id NUMBER) return VARCHAR2;


END flm_execution_util;






/
