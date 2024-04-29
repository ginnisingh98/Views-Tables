--------------------------------------------------------
--  DDL for Package CTO_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_WORKFLOW" AUTHID CURRENT_USER as
/* $Header: CTOWKFLS.pls 120.1 2005/06/03 11:20:30 appldev  $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOWKFLS.pls                                                  |
| DESCRIPTION :                                                               |
|               This file creates package procedures that are called for each |
|               ATO Workflow activity.                                        |
|                                                                             |
|               BOM_CTO_WF_API.match_config_wf                              |
|               Procedure called from the Workflow Engine upon executing the  |
|               Match activity in the ATO process.  It does some preliminary  |
|               checks to verify that the order line is eligible to be        |
|               matched before calling the matching logic in function         |
|               BOM_MATCH_CONFIG.check_config_match.  If a match is found,    |
|               it links the match to the order line and updates the workflow.|
|                                                                             |
                BOM_CTO_WF_API.reserve_config_wf                            |
|                                                                             |
|               BOM_MATCH_CONFIG.create_config_wf                             |
|                                                                             |
|               BOM_CTO_WF_API.create_routing_wf                            |
|                                                                             |
|               BOM_CTO_WF_API.calculate_leadtime_wf                        |
|                                                                             |
|                                                                             |
|                                                                             |
| HISTORY     : 03/26/99      Initial Version                                 |
|
|               06/04/02      bugfix2327972
|                             added a new function node which calls procedure
|                             chk_rsv_after_afas_wf
|                             This nodes checks if any type of reservation
|                             exists. Node has been added in warning path after
|                             autocreate fas node
|
|
|              11/14/2003    Kiran Konada
|                            removed proceduset_parameter_lead_time_wf
|                            bcos of bug#3202825
|
|              06/01/2005    Renga Kannan
|                            Added nocopy hint to all out parameters.
|
=============================================================================*/

procedure create_config_item_wf(
        p_itemtype      in      VARCHAR2, /* workflow item type */
        p_itemkey       in      VARCHAR2, /* sales order line id */
        p_actid         in      number,   /* ID number of WF activity */
        p_funcmode      in      VARCHAR2, /* execution mode of WF activity */
        x_result    out NoCopy  VARCHAR2  /* result of activity */
        );

PROCEDURE CREATE_RESERVATION(
        p_mfg_org_id           in     number ,
        p_top_model_line_id    in     number,
        p_config_id            in     number ,
        p_reservation_uom_code in     varchar2 ,
        p_quantity_to_reserve  in     number,
        p_schedule_ship_date   in     DATE,
        p_mode                 in     varchar2 ,
        x_reserve_status       out NoCopy   varchar2,
        x_msg_count            out NoCopy   number ,
        x_msg_data             out NoCopy   varchar2,
        x_return_status        out NoCopy   varchar2
) ;

procedure check_reservation_status_wf(
        p_itemtype        in      VARCHAR2, /*w workflow item type */
        p_itemkey         in      VARCHAR2, /* config line id */
        p_actid           in      NUMBER,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result    out NoCopy    VARCHAR2  /* result of activity */
        );



-- to be renamed after tested completely
procedure calculate_cost_rollup_wf_ml(
        p_itemtype        in      VARCHAR2, /* internal name for item type */
        p_itemkey         in      VARCHAR2, /* sales order line id  */
        p_actid           in      number,   /* ID number of WF activity  */
        p_funcmode        in      VARCHAR2, /* execution mode of WF act  */
        x_result      out NoCopy  VARCHAR2  /* result of activity */
        );



-- to be renamed after tested completely
procedure set_parameter_lead_time_wf_ml(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity */
        );



PROCEDURE check_supply_type_wf(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity */
        );

/*============================================================================
        Procedure:    create_flow_schedule__wf
        Description:  This procedure gets called when executing the
                      Create Flow Schedule  activity in the CTO workflow.

	Parameters:
=============================================================================*/
PROCEDURE create_flow_schedule_wf(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity */
        );


/*============================================================================
        Procedure:    work_order_set_parameter_wf
        Description:  This procedure gets called when executing the Set
                      Parameter Work Order activity in the ATO workflow.

                      More to come...
	Parameters:
=============================================================================*/
procedure set_parameter_work_order_wf(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity */
        );

procedure submit_conc_prog_wf(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result     out  NoCopy  VARCHAR2  /* result of activity */
        );

PROCEDURE submit_and_continue_wf(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity */
        );

/*============================================================================
	Procedure:    validate_line
	Description:  This procedure gets called when executing the Match
                      Configuration activity in the ATO workflow.  The
                      format is follows the standard Workflow API format.

		      More to come...
	Parameters:
=============================================================================*/
FUNCTION validate_line(
        p_line_id   in number
        )
RETURN boolean;

/*============================================================================
	Procedure:    validate_line
	Description:  This procedure gets called when executing the Match
                      Configuration activity in the ATO workflow.  The
                      format is follows the standard Workflow API format.

		      More to come...
	Parameters:
=============================================================================*/
FUNCTION validate_config_line(
        p_config_line_id   in number
        )
RETURN boolean;

/*============================================================================
        Procedure:    config_line_exists
        Description:  This procedure gets called when executing the Match
                      Configuration activity in the ATO workflow.  The
                      format is follows the standard Workflow API format.

                      More to come...

        Parameters:
=============================================================================*/
FUNCTION config_line_exists(
        p_model_line_id   in number
        )
RETURN boolean;

/*============================================================================
        Procedure:    reservation_exists
        Description:  This procedure gets called when executing the Match
                      Configuration activity in the ATO workflow.  The
                      format is follows the standard Workflow API format.

                      More to come...

        Parameters:
=============================================================================*/
FUNCTION reservation_exists(
        p_config_line_id in number,
        x_reserved_qty   out NoCopy number
        )
RETURN boolean;

FUNCTION flow_sch_exists(
        plineid in number
        )
RETURN boolean;

Procedure  check_inv_rsv_exists
 (
         pLineId          in     number    ,
         x_ResultStatus   out  Nocopy  boolean  ,
         x_msg_count      out  Nocopy  number  ,
         x_msg_data       out  Nocopy  varchar2,
         x_return_status  out  Nocopy  varchar2
 );

--begin bugfix 3075105
Procedure  check_rsv_exists
 (
         pLineId          in            number    ,
         x_ResultStatus    out Nocopy   boolean  ,
         x_msg_count     out   Nocopy   number  ,
         x_msg_data       out  NoCopy   varchar2,
         x_return_status out   NoCopy   varchar2
 );
--end bugfix 3075105

PROCEDURE rsv_before_booking_wf (
        p_itemtype        in      VARCHAR2, /* item type */
        p_itemkey         in      VARCHAR2, /* config line id   */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity    */
        );


PROCEDURE Purchase_price_calc_wf(
        p_itemtype        in      VARCHAR2, /* workflow item type */
        p_itemkey         in      VARCHAR2, /* sales order line id */
        p_actid           in      number,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity */

        );

-- bugfix2327972

PROCEDURE chk_rsv_after_afas_wf (
        p_itemtype        in      VARCHAR2, /* item type */
        p_itemkey         in      VARCHAR2, /* config line id   */
        p_actid           in      NUMBER,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result      out NoCopy  VARCHAR2  /* result of activity    */
        );

--This will get called from a new node in create supply subprocess
--added fro DMF-J
--new node is : Check supply creation which befor create supply order
--block activity
--create by KKONADA
PROCEDURE check_supply_creation_wf(
        p_itemtype   in           VARCHAR2, /*item type */
        p_itemkey    in           VARCHAR2, /* config line id    */
        p_actid      in           number,   /* ID number of WF activity  */
        p_funcmode   in           VARCHAR2, /* execution mode of WF activity*/
        x_result     out  NoCopy  VARCHAR2  /* result of activity    */
        );

procedure config_item_created_wf(
        p_itemtype        in      VARCHAR2, /*w workflow item type */
        p_itemkey         in      VARCHAR2, /* config line id */
        p_actid           in      NUMBER,   /* ID number of WF activity */
        p_funcmode        in      VARCHAR2, /* execution mode of WF activity */
        x_result    out NoCopy    VARCHAR2  /* result of activity */
        );

end CTO_WORKFLOW;







 

/
