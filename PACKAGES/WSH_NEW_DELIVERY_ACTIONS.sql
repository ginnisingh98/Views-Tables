--------------------------------------------------------
--  DDL for Package WSH_NEW_DELIVERY_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_NEW_DELIVERY_ACTIONS" AUTHID CURRENT_USER as
/* $Header: WSHDEACS.pls 120.3.12010000.2 2009/12/03 13:52:52 mvudugul ship $ */

G_USER_NAME VARCHAR2(200);
g_error_level VARCHAR2(1);

/********************************************************************************
 *  The following global variables are added as part of Ship Message
 *  Customization Project. These varibles are accessed from WSHDEACB.pls and
 *  WSHDEVLB.pls. Variables ending with _act -> activity and _msg -> message
 ******************************************************************************/
 g_ship_confirm_act     CONSTANT VARCHAR2(200) := 'SHIP_CONFIRM_MESSAGE';
 g_missing_inv_cntl_msg CONSTANT VARCHAR2(200) := 'MISSING_CONTROLS';
 g_break_ship_set_msg   CONSTANT VARCHAR2(200) := 'BREAK_SHIP_SET';
 g_break_smc_msg        CONSTANT VARCHAR2(200) := 'BREAK_SMC';
 g_invalid_material_status_msg CONSTANT VARCHAR2(200) := 'INVALID_MATERIAL_STATUS';

 /*The following variable is checked for count in CONFIRM_DELIVERY Procedure.
   Value for this varibale is set in WSH_DELIVERY_VALIDATIONS.CHECK_CONFIRM Procedure*/
  g_break_ship_set_or_smc    NUMBER := 0;

 /********************* Ship Message Customization Changes End ****************/


TYPE ship_method_type is TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

/* J TP Release */
--
-- Procedure:	FIRM
-- Parameters:	p_del_rows   - Delivery_ids to be firmed
--		x_return_status - status of procedure call
-- Description: This procedure will firm a delivery
--
  PROCEDURE FIRM
  (p_del_rows   IN  wsh_util_core.id_tab_type,
   x_return_status  OUT NOCOPY  VARCHAR2);

--
-- Procedure:	Plan
-- Parameters:	p_del_rows   - Delivery_ids to be planned
--		x_return_status - status of procedure call
-- Description: This procedure will Plan a delivery for shipment
--
  PROCEDURE Plan
		(p_del_rows		IN	wsh_util_core.id_tab_type,
		 x_return_status	OUT NOCOPY 	VARCHAR2,
                 p_called_for_sc        IN BOOLEAN default false);

--
-- Procedure:	Unplan
-- Parameters:	p_del_rows   - Delivery_ids of deliveries to be unplanned
--		x_return_status - status of procedure call
-- Description: This procedure will unplan a delivery
--

  PROCEDURE Unplan
		(p_del_rows		IN	wsh_util_core.id_tab_type,
		 x_return_status	OUT NOCOPY 	VARCHAR2);


-- Bug: 2052963
-- Procedure:	Get_Delivery_Defaults
-- Parameters:	p_del_rows   - Delivery_ids of deliveries to be confirmed
-- Parameters:	p_org_ids    - Organization ids of deliveries to be confirmed
--              x_autocreate_flag - enables/disables trip information
--              x_autointransit_flag - enables/disables setting in-transit for trip
--              x_autoclose_flag - enables/disables setting trip closure
--		x_return_status - status of procedure call
--              x_sc_rule_id - if all deliveries belong to same org and hence
--                             have a common ship confirm rule specified
--              x_ac_bol_flag - along with Ship Confirm Rule,what is the
--              value of BOL flag
--              x_defer_interface_flag - Value for the Ship Confirm Rule
--              x_sc_rule_name - Ship Confirm Rule Name

-- Description: Gets the Default Delivery Parameters
--              Including Document Set(id and Name) for the Org.
--              associated with the Delivery(s).
--

  PROCEDURE Get_Delivery_Defaults
		(p_del_rows		  IN	wsh_util_core.id_tab_type,
		 p_org_ids 		  IN	wsh_util_core.id_tab_type,
                 p_client_ids             IN    wsh_util_core.id_tab_type, --Modified R12.1.1 LSP PROJECT
                 p_ship_method_code_vals  IN    ship_method_type,
                 x_autointransit_flag   OUT NOCOPY      VARCHAR2,
                 x_autoclose_flag       OUT NOCOPY      VARCHAR2,
		 x_report_set_id	OUT NOCOPY 	NUMBER,
		 x_report_set_name      OUT NOCOPY      VARCHAR2,
                 x_ship_method_name     OUT NOCOPY      VARCHAR2,
		 x_return_status	OUT NOCOPY 	VARCHAR2,
                 x_sc_rule_id           OUT NOCOPY      NUMBER,
                 x_ac_bol_flag          OUT NOCOPY      VARCHAR2,
                 x_defer_interface_flag OUT NOCOPY      VARCHAR2,
                 x_sc_rule_name         OUT NOCOPY      VARCHAR2

         );


-- Procedure:	Confirm_Delivery
-- Parameters:	p_del_rows   - Delivery_ids of deliveries to be confirmed
--             p_action_flag   - 'S' for Ship Entered, Ship Unspecified Full
--						   'B' for Ship Entered, Backorder Unspecified
--						   'A' Ship All
--             p_intransit_flag - 'Y' for autocreate_trip closes first stop
--             p_autoclose_flag - 'Y' closes autocreated trip and stops
--             p_stage_del_flag - 'Y' creates a new delivery for the staged lines
--             p_report_set_id - report set for delivery
--             p_ship_method - ship method for autocreated trip
--             p_actual_dep_date - actual departure date for pickup stop on autocreated trip
--             p_defer_interface_flag - 'Y' to skip concurrent program submission, bug 1578251
--             p_send_945_flag - 'Y' to trigger outbound shipment advice for delivery with WSH lines
--		x_return_status - status of procedure call
-- Description: This procedure will update shipped quantities of the details
--              on each delivery and confirms each delivery


  PROCEDURE Confirm_Delivery
		(p_del_rows		IN	wsh_util_core.id_tab_type,
		 p_action_flag		IN	VARCHAR2,
		 p_intransit_flag	IN	VARCHAR2,
		 p_close_flag       IN   VARCHAR2,
		 p_stage_del_flag   IN   VARCHAR2,
		 p_report_set_id    IN   NUMBER,
		 p_ship_method      IN   VARCHAR2,
		 p_actual_dep_date  IN   DATE,
		 p_bol_flag         IN   VARCHAR2,
		 p_mc_bol_flag   IN  VARCHAR2 DEFAULT 'N',
		 p_defer_interface_flag  IN VARCHAR2,
                 p_send_945_flag    IN   VARCHAR2 DEFAULT NULL,
                 p_autocreate_trip_flag  IN   varchar2 default 'Y',
                 x_return_status	OUT NOCOPY 	VARCHAR2,
--tkt
                 p_caller               IN   VARCHAR2 DEFAULT NULL) ;

--
-- Procedure:	Change_Status
-- Parameters:	p_del_rows   - Delivery_ids of deliveries to be planned
--		p_action		 - action to be performed
--        p_actual_date   - date the action is performed
--          NOTE: this is used to populate the initial and ultimate dates
--                always pass NULL if calling directly
--		x_return_status - status of procedure call
-- Description: This procedure will Change Status of deliveries
--              Values for p_action are
--              - PACK
--              - REOPEN
--              - IN-TRANSIT
--              - CLOSE
--  NOTE: For CONFIRM use confirm_delivery procedure
--

  PROCEDURE Change_Status
		(p_del_rows		IN	wsh_util_core.id_tab_type,
		 p_action			IN	VARCHAR2,
		 p_actual_date      IN   DATE DEFAULT NULL,
		 x_return_status	OUT NOCOPY 	VARCHAR2,
--tkt
                 p_caller               IN   VARCHAR2 DEFAULT NULL) ;



--
-- Procedure:	Update_Leg_Sequence
-- Parameters:	p_delivery_id   - Delivery_id of delivery to be planned
--		x_return_status - status of procedure call
-- Description: This procedure will update sequence number of delivery legs
--
/* H integration - anxsharm */
  PROCEDURE Update_Leg_Sequence
		(p_delivery_id		IN	NUMBER,
                 p_update_flag          IN      VARCHAR2 DEFAULT 'Y',
		 x_return_status	OUT NOCOPY 	VARCHAR2);


--
-- Procedure:	Set_Load_Tender
-- Parameters:	p_del_rows   - Delivery ids to be tendered
--		x_return_status - status of procedure call
-- Description: This procedure is used to Tender/Cancel loads to carriers. It
--              calls the wsh_delivery_legs_actions API for delivery legs on
--              each delivery
--              p_action - 'TENDER', 'CANCEL'
--
-- COMMENTING OUT AS LOAD TENDER FUNCTIONALITY IS TEMPORARILY REMOVED
/*
  PROCEDURE Set_Load_Tender
		(p_del_rows		IN	wsh_util_core.id_tab_type,
		 p_action           IN   VARCHAR2,
		 x_return_status	OUT NOCOPY VARCHAR2);
*/
--
-- Procedure:	Generate_Loading_Seq
-- Parameters:	p_del_rows   - Delivery ids
--		x_return_status - status of procedure call
-- Description: This procedure is used to generate loading sequence for deliveries
--

  PROCEDURE Generate_Loading_Seq
		(p_del_rows		IN	wsh_util_core.id_tab_type,
		 x_return_status	OUT NOCOPY 	VARCHAR2);


--
-- Procedure:	Assign_Delivery_Update
-- Parameters:	p_delivery_id   - Delivery id
--             p_del_params    - Parameters to update the delivery with
--		x_return_status - status of procedure call
-- Description: This procedure is used to update the delivery with grouping
--              attribute values from lines, while assigning lines to delivery
--

  PROCEDURE Assign_Delivery_Update
		(p_delivery_id		IN	NUMBER,
		 p_del_params       IN   wsh_delivery_autocreate.grp_attr_rec_type,
		 x_return_status	OUT NOCOPY 	VARCHAR2);



-- **************************************************************************
-- PATCHSET H CHANGES FOR FTE INTEGRATION with CARRIER SELECTION
--
-- [AAB]
-- [03/02/2002]
--

TYPE TableNumbers             is TABLE of NUMBER       INDEX BY BINARY_INTEGER; -- table number type
TYPE TableVarchar30           is TABLE of VARCHAR2(30) INDEX BY BINARY_INTEGER; -- table varchar(30) type
TYPE TableVarchar3            is TABLE of VARCHAR2(3)  INDEX BY BINARY_INTEGER; -- table varchar(3) type
TYPE TableDate                is TABLE of DATE         INDEX BY BINARY_INTEGER;


PROCEDURE PROCESS_CARRIER_SELECTION(p_delivery_id_tab        IN OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
                                    p_batch_id               IN  NUMBER,
                                    p_form_flag              IN  VARCHAR2,
				    p_organization_id        IN  NUMBER DEFAULT NULL,
                                     -- csun deliveryMerge
				    p_caller                 IN  VARCHAR2 DEFAULT NULL,
                                    x_return_message         OUT NOCOPY  VARCHAR2,
                                    x_return_status          OUT NOCOPY  VARCHAR2);

-- deliveryMerge
G_NO_APPENDING        VARCHAR2(1) := 'N';
G_START_OF_STAGING    VARCHAR2(1) := 'S';
G_END_OF_STAGING      VARCHAR2(1) := 'E';
G_START_OF_PACKING    VARCHAR2(1) := 'A';
G_START_OF_SHIPPING   VARCHAR2(1) := 'W';

PROCEDURE Adjust_Planned_Flag(
   p_delivery_ids            IN wsh_util_core.id_tab_type,
   p_caller                  IN VARCHAR2,
   p_force_appending_limit   IN VARCHAR2,
   p_call_lcss               IN VARCHAR2  DEFAULT 'N',
   p_event                   IN VARCHAR2  DEFAULT NULL,
   x_return_status           OUT NOCOPY VARCHAR2,
   p_called_for_sc           IN BOOLEAN default false);


-- J-IB-NPARIKH-{
-- ----------------------------------------------------------------------
-- Procedure:   update_freight_terms
-- Parameters:  p_delivery_id in  number
--              p_action_code   in varchar2
--                  'ASSIGN'  : Assign lines to delivery
--                  'UNASSIGN' : Unassign lines from delivery
--              p_line_freight_terms_code in varchar2
--                  NULL : Caller did not pass value
--                  'NULL' : Lines assigned/unassigned have mixed/null freight terms
--                  Other value: All lines assigned/unassigned have same freight term , equal to this value
-- Description: This procedure can be called after assign/unassign lines from delivery.
--  ----------------------------------------------------------------------
PROCEDURE update_freight_terms
            (
               p_delivery_id             IN              NUMBER,
               p_action_code             IN              VARCHAR2 DEFAULT 'UNASSIGN',
               p_line_freight_terms_Code IN              VARCHAR2 DEFAULT NULL,
               x_freight_terms_Code      OUT    NOCOPY   VARCHAR2,
               x_return_status           OUT    NOCOPY   VARCHAR2
            ) ;
--
--
PROCEDURE setClose
            (
              p_in_rec             IN          WSH_DELIVERY_VALIDATIONS.ChgStatus_in_rec_type,
              x_return_status      OUT NOCOPY  VARCHAR2
            ) ;
PROCEDURE setInTransit
            (
              p_in_rec             IN          WSH_DELIVERY_VALIDATIONS.ChgStatus_in_rec_type,
              x_return_status      OUT NOCOPY  VARCHAR2
            ) ;


PROCEDURE update_ship_from_location
            (
               p_delivery_id                 IN           NUMBER,
               p_location_id                 IN           NUMBER,
               x_return_status               OUT NOCOPY   VARCHAR2
            ) ;


-- J-IB-NPARIKH-}

-- J-IB-HEALI-{
PROCEDURE Process_Leg_Sequence
      ( p_delivery_id   IN   NUMBER,
        p_update_del_flag    IN VARCHAR2,
        p_update_leg_flag    IN VARCHAR2,
        x_leg_complete  OUT NOCOPY boolean,
        x_return_status OUT NOCOPY   VARCHAR2);
-- J-IB-HEALI-}

/**________________________________________________________________________
--
-- Name:
-- Assign_Del_to_Consol_Del
--
-- Purpose:
-- This API assigns a deliveries to a parent (consolidation)
-- delivery. If the caller is FTE consolidation SRS, we
-- assume that the child deliveries have already been validated
-- as eligible to be assigned to the parent delivery.
-- Parameters:
-- p_del_tab: Table of deliveries that need to be assigned
-- p_parent_del: Parent delivery id that will be assigne to
-- p_caller: Calling entity/action
-- x_return_status: status
**/

Procedure Assign_Del_to_Consol_Del(
          p_del_tab         IN WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
          p_parent_del_id   IN NUMBER,
          p_caller          IN VARCHAR2,
          x_return_status   OUT NOCOPY VARCHAR2);


--
-- Name:
-- Unassign_Dels_from_Consol_Del
--
-- Purpose:
-- This API unassigns deliveries from a parent (consolidation)
-- delivery. If the parent delivery becomes empty we delete the
-- parent delivery. Currently this will be called with
-- assumption that all and only all deliveries in the parent
-- delivery will be unassigned all at the same time.
--
-- Parameters:
-- p_del_tab: Table of deliveries that need to be unassigned
-- p_parent_del_ids: Parent deliveries that will be unassigned from
-- and eventually deleted.
-- p_caller: Calling entity/action
-- x_return_status: status


Procedure Unassign_Dels_from_Consol_Del(
          p_parent_del     IN NUMBER,
          p_caller         IN VARCHAR2,
          p_del_tab        IN OUT NOCOPY wsh_util_core.id_tab_type,
          x_return_status  OUT NOCOPY VARCHAR2);


--OTM R12, function to check if delivery is empty or not
FUNCTION IS_DELIVERY_EMPTY (p_delivery_id	IN NUMBER) RETURN VARCHAR2;
--

END WSH_NEW_DELIVERY_ACTIONS;

/
