--------------------------------------------------------
--  DDL for Package INV_LOT_ATTR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOT_ATTR_PUB" AUTHID CURRENT_USER AS
 /* $Header: INVVLOTS.pls 120.0 2005/05/25 05:26:48 appldev noship $ */

   -----------------------------------------------------------------------
   -- Name : validate_grade_code
   -- Desc :
   --          Generic routine to validates a grade code , item
   --          must be grade controlled and grade must exist in
   --          mtl_grades table
   -- I/P params :
   --      grade code, item ID and Org ID
   -----------------------------------------------------------------------

   FUNCTION validate_grade_code( 	p_grade_code  				IN		VARCHAR
                            	  , p_org_id                    IN      NUMBER
  								  , p_inventory_item_id         IN      NUMBER
  								  , p_grade_control_flag        IN      VARCHAR2
                                  , x_return_status 			OUT NOCOPY VARCHAR2
                                  , x_msg_count 				OUT NOCOPY NUMBER
                                  , x_msg_data 					OUT NOCOPY VARCHAR2)
                                  RETURN BOOLEAN;

  -----------------------------------------------------------------------
   -- Name : validate_maturity_date
   -- Desc :
   --          Generic routine to validates maturity date.
   --             Maturity Date must be greater than the Origination Date
   --
   --          This function assumes that validation for origination date
   --          have already taken place
   -- I/P params :
   --      p_maturity_date, p_origination_date (Mandatory)
   -----------------------------------------------------------------------

FUNCTION validate_maturity_date(
  p_maturity_date				IN		DATE
, p_origination_date            IN      DATE
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN  ;

  -----------------------------------------------------------------------
   -- Name : validate_hold_date
   -- Desc :
   --          Generic routine to validates maturity date.
   --             Hold Date must be greater than the Origination Date
   --
   --          This function assumes that validation for origination date
   --          have already taken place
   -- I/P params :
   --      p_maturity_date, p_origination_date (Mandatory)
   -----------------------------------------------------------------------

FUNCTION validate_hold_date(
  p_hold_date				IN		DATE
, p_origination_date            IN      DATE
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN  ;

  -----------------------------------------------------------------------
   -- Name : validate_expiration_action_date
   -- Desc :
   --          Generic routine to validate expiration_action_date
   --             Must be >= expiration date
   --
   --          This function assumes that validation for expiration date
   --          have already taken place
   -- I/P params :
   --      p_expiration_action_date,  p_expiration_date (Mandatory)
   -----------------------------------------------------------------------

FUNCTION validate_exp_action_date(
  p_expiration_action_date		IN		DATE
, p_expiration_date             IN      DATE
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN  ;

 -----------------------------------------------------------------------
   -- Name : validate_retest_date
   -- Desc :
   --          Generic routine to validates retest date.
   --             Hold Date must be greater than the Origination Date
   --
   --          This function assumes that validation for origination date
   --          have already taken place
   -- I/P params :
   --      p_retest_date, p_origination_date (Mandatory)
   -----------------------------------------------------------------------

FUNCTION validate_retest_date(
  p_retest_date 				IN		DATE
, p_origination_date            IN      DATE
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN  ;

  -----------------------------------------------------------------------
   -- Name : validate_exp_action_code
   -- Desc :
   --          Generic routine to validates Expiration Action Code , item
   --          must be shlef life controlled, and Action Code must exist in
   --          mtl_actions table
   -- I/P params :
   --      p_expiration_action_code , item ID and Org ID (Mandatory)
   --      p_shelf_life_code  (optional..)
   -----------------------------------------------------------------------

   FUNCTION validate_exp_action_code( 	p_expiration_action_code  				IN		VARCHAR
                            	  , p_org_id                    IN      NUMBER
  								  , p_inventory_item_id         IN      NUMBER
  								  , p_shelf_life_code           IN      VARCHAR2
                                  , x_return_status 			OUT NOCOPY VARCHAR2
                                  , x_msg_count 				OUT NOCOPY NUMBER
                                  , x_msg_data 					OUT NOCOPY VARCHAR2)
                                  RETURN BOOLEAN;
  -----------------------------------------------------------------------
   -- Name : validate_reason_code
   -- Desc :
   --          Generic routine to validate reason code/ reason id
   --             Must exist in MTL_TRANSACTION_REASONS
   --
   -- I/P params :
   --      p_reason_code OR  p_resson_id  (Mandatory)
   -----------------------------------------------------------------------

FUNCTION validate_reason_code (
  p_reason_code					IN		VARCHAR2
, p_reason_id                   IN      NUMBER
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN  ;

  -----------------------------------------------------------------------
   -- Name : validate_origination_type
   -- Desc :
   --          Generic routine to validate origination type
   --             Must exist in mfg_lookups (lookup_type = 'ORIGINATION_TYPE')
   --
   -- I/P params :
   --      p_origination_id  (Mandatory)
   -----------------------------------------------------------------------

FUNCTION validate_origination_type (
  p_origination_type			IN		NUMBER
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN  ;

  -----------------------------------------------------------------------
   -- Name : validate_child_lot
   -- Desc :
   --          Generic routine to validate lot number
   --          Validation conditions
   --            # child lot is new
   --            # Item must be child lot enable
   --            # Validate naming conventions if child Lot has an associated parent lot
   --            # relations ship between parent/child lot is valid
   --
   -- I/P params :
   --      p_parent_lot_number, p_lot_number , itemid, orgid --> (Mandatory)
   --      p_child_lot_flag (optional)
   -----------------------------------------------------------------------

FUNCTION validate_child_lot (
  p_parent_lot_number			IN		   VARCHAR2
, p_lot_number					IN		   VARCHAR2
, p_org_id                      IN      NUMBER
, p_inventory_item_id           IN      NUMBER
, p_child_lot_flag              IN      VARCHAR2
, x_return_status 			    OUT NOCOPY VARCHAR2
, x_msg_count 				    OUT NOCOPY NUMBER
, x_msg_data 				    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN  ;

 -----------------------------------------------------------------------
   -- Name : create_lot_uom_conv_wrapper
   -- Desc : Uses  by Transaction Manager Java code to create
   -- lot specific conversion
   --
   -- I/P params :

   -----------------------------------------------------------------------

PROCEDURE create_lot_uom_conv_wrapper
( p_commit                IN              VARCHAR2
, p_action_type           IN              VARCHAR2
, p_reason_id             IN              NUMBER
, p_lot_number      	  IN              VARCHAR2
, p_organization_id       IN              NUMBER
, p_inventory_item_id     IN              NUMBER
, p_from_unit_of_measure  IN              VARCHAR2
, p_from_uom_code         IN              VARCHAR2
, p_from_uom_class        IN              VARCHAR2
, p_to_unit_of_measure    IN              VARCHAR2
, p_to_uom_code           IN              VARCHAR2
, p_to_uom_class          IN              VARCHAR2
, p_conversion_rate       IN              NUMBER
, p_disable_date          IN              DATE
, p_event_spec_disp_id    IN              NUMBER
, p_created_by            IN              NUMBER
, p_creation_date         IN              DATE
, p_last_updated_by       IN              NUMBER
, p_last_update_date      IN              DATE
, p_last_update_login     IN              NUMBER
, p_request_id            IN              NUMBER
, p_program_application_id IN             NUMBER
, p_program_id            IN              NUMBER
, p_program_update_date   IN              DATE
, x_return_status         OUT NOCOPY      VARCHAR2
, x_msg_count             OUT NOCOPY      NUMBER
, x_msg_data              OUT NOCOPY      VARCHAR2
 );

END  INV_LOT_ATTR_PUB;



 

/
