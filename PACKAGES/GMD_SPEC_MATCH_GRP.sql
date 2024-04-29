--------------------------------------------------------
--  DDL for Package GMD_SPEC_MATCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SPEC_MATCH_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDGSPMS.pls 120.7 2006/03/16 04:28:29 ragsriva ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGSPMS.pls                                        |
--| Package Name       : GMD_SPEC_MATCH_GRP                                  |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Specification Match        |
--|                                                                          |
--| HISTORY                                                                  |
--|    Mahesh Chandak	6-Aug-2002	Created.                             |
--| Saikiran Vankadari  20-May-2005    Convergence Changes                   |
--| Joe DiIorio         19-Jul-2005    Put back lot_id, whse_code, orgn_code,|
--|                                    item_id, location into record TYPEs   |
--|                                    as these are needed by GMDQCMJB.pls.  |
--+==========================================================================+
-- End of comments


-- adding test_id. This is to support production requirement.
-- test_id would be passed only by the production team.
-- note that item_id, lot_id, orgn_code, whse_code, location are obsolete but
-- required for migration.
TYPE INVENTORY_SPEC_REC_TYPE IS RECORD (
 inventory_item_id 		NUMBER
,revision               VARCHAR2(3)
,grade_code       		VARCHAR2(150)
,organization_id   		NUMBER
,subinventory           VARCHAR2(10)
,parent_lot_number      VARCHAR2(80)
,lot_number				VARCHAR2(80)
,locator_id       		NUMBER
,date_effective 		DATE
,exact_match		    VARCHAR2(1)
,test_id			NUMBER
, item_id               NUMBER
, lot_id                NUMBER
, orgn_code             VARCHAR2(4)
, whse_code             VARCHAR2(4)
, location              VARCHAR2(16)
);


-- note that item_id, lot_id, orgn_code, whse_code are obsolete but
-- required for migration.
TYPE CUSTOMER_SPEC_REC_TYPE IS RECORD
(inventory_item_id       NUMBER
,revision                VARCHAR2(3)
,organization_id         NUMBER
,subinventory            VARCHAR2(10)
,grade_code 			 VARCHAR2(150) -- Bug# 4723077
,cust_id 	             NUMBER
,date_effective          DATE
,org_id    	             NUMBER
,ship_to_site_id         NUMBER
,order_id    	         NUMBER
,order_line	             NUMBER
,order_line_id           NUMBER
,look_in_other_orgn      VARCHAR2(1)
,exact_match		     VARCHAR2(1)
,lot_number			     VARCHAR2(80)
,parent_lot_number      VARCHAR2(80)
, item_id               NUMBER
, lot_id                NUMBER
, orgn_code             VARCHAR2(4)
, whse_code             VARCHAR2(4)
) ;

-- note that item_id, lot_id, orgn_code, whse_code are obsolete but
-- required for migration.
TYPE SUPPLIER_SPEC_REC_TYPE IS RECORD
(inventory_item_id           NUMBER
,revision                    VARCHAR2(3)
,organization_id             NUMBER
,subinventory               VARCHAR2(10)
,grade_code		             VARCHAR2(150)  -- Bug# 4723077
,locator_id                  NUMBER
,supplier_id 	             NUMBER
,supplier_site_id            NUMBER
,po_header_id		         NUMBER
,po_line_id		             NUMBER
,date_effective              DATE
,org_id                      NUMBER
,exact_match		         VARCHAR2(1)
,lot_number 			     VARCHAR2(80)
,parent_lot_number      VARCHAR2(80)
, item_id               NUMBER
, lot_id                NUMBER
, orgn_code             VARCHAR2(4)
, whse_code             VARCHAR2(4)
);

-- note that item_id, lot_id, orgn_code are obsolete but
-- required for migration.
-- Bug 4640143: added material detail id
TYPE WIP_SPEC_REC_TYPE IS RECORD
(inventory_item_id           NUMBER
,revision                    VARCHAR2(3)
,grade_code		             VARCHAR2(150) -- Bug# 4723077
,organization_id             NUMBER
,batch_id                    NUMBER
,recipe_id                   NUMBER
,recipe_no                   VARCHAR2(32)
,recipe_version              NUMBER(5)
,formula_id                  NUMBER
,formulaline_id              NUMBER
,material_detail_id          NUMBER
,formula_no                  VARCHAR2(32)
,formula_vers                NUMBER(5)
,routing_id                  NUMBER
,routing_no                  VARCHAR2(32)
,routing_vers                NUMBER(5)
,step_id                     NUMBER
,step_no                     NUMBER
,oprn_id                     NUMBER
,oprn_no                     VARCHAR2(16)
,oprn_vers                   NUMBER(5)
,charge                      NUMBER
,date_effective              DATE
,exact_match   		         VARCHAR2(1)
,lot_number 			     VARCHAR2(80)
,parent_lot_number      VARCHAR2(80)
,find_spec_with_step         VARCHAR2(1)
,item_id                    NUMBER
,lot_id                     NUMBER
,orgn_code                  VARCHAR2(4)
);

--MCHANDAK bug# 2645698
-- created additional paramater find_spec_with_step which will be set to 'Y' when
-- calling from batch step creation workflow.Also changed the main select.

TYPE MATCH_RESULT_LOT_REC_TYPE IS RECORD
( inventory_item_id          NUMBER             -- IN
 ,organization_id            NUMBER             -- IN
 ,lot_number                 VARCHAR2(80)       -- IN
 ,subinventory               VARCHAR2(10)       -- IN
 ,locator_id                 NUMBER             -- IN
 ,sample_id        NUMBER                       -- OUT
 ,spec_match_type  VARCHAR2(1)                  -- OUT
 ,result_type      VARCHAR2(1)                  -- OUT
 ,event_spec_disp_id      NUMBER                -- OUT
 );

TYPE result_lot_match_tbl  IS TABLE OF MATCH_RESULT_LOT_REC_TYPE INDEX BY BINARY_INTEGER;


TYPE LOCATION_SPEC_REC_TYPE IS RECORD (
 locator_organization_id 		NUMBER
,subinventory       		    VARCHAR2(10)
,locator_id       		        NUMBER
,date_effective 		        DATE
);


TYPE RESOURCE_SPEC_REC_TYPE IS RECORD (
 resource_organization_id      	NUMBER
,resources			            VARCHAR2(16)
,resource_instance_id		    NUMBER
,date_effective 		        DATE
);



--Start of comments
--+========================================================================+
--| API Name    : find_inventory_spec                                      |
--| TYPE        : Group                                                    |
--| Notes       : This function RETURN TRUE if matching inventory          |
--|               spec. is found else it RETURN FALSE.                     |
--|               If matching inventory spec is found,then                 |
--|               it returns matching spec_id  and spec_vr_id              |
--| Calling Program : - Samples form			   		   |
--|                   - Subscriber for the Receiving Event(if              |
--|                     matching supplier spec is not found) (Workflow)    |
--|                   -	Inventory Transaction Event                        |
--|                   - Lot Expiration Transcation Event                   |
--|                   - Lot Retest Transcation Event                       |
--| HISTORY                                                                |
--|    Mahesh Chandak	6-Aug-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION FIND_INVENTORY_SPEC(p_inventory_spec_rec IN  inventory_spec_rec_type,
			     x_spec_id 	  	  OUT NOCOPY NUMBER,
			     x_spec_vr_id	  OUT NOCOPY NUMBER,
			     x_return_status	  OUT NOCOPY VARCHAR2,
			     x_message_data   	  OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;


--Start of comments
--+========================================================================+
--| API Name    : find_customer_spec                                       |
--| TYPE        : Group                                                    |
--| Notes       : This function RETURN TRUE if matching customer           |
--|               spec. is found else it RETURN FALSE.                     |
--|               If matching customer spec is found,then                  |
--|               it returns matching spec_id  and spec_vr_id              |
--| Calling Program : -  Spec matching in Order Management(Pick lots form) |
--|                   -  Shipment screen in OM (in Future )		   |
--| HISTORY                                                                |
--|    Mahesh Chandak	6-Aug-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION FIND_CUSTOMER_SPEC(p_customer_spec_rec IN  customer_spec_rec_type,
		     	    x_spec_id 	  	OUT NOCOPY NUMBER,
			    x_spec_vr_id	OUT NOCOPY NUMBER,
			    x_return_status	OUT NOCOPY VARCHAR2,
			    x_message_data   	OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

--Start of comments
--+========================================================================+
--| API Name    : find_cust_or_inv_spec                                    |
--| TYPE        : Group                                                    |
--| Notes       : This function first looks for a matching customer        |
--|               spec.If found,then returns that spec else looks for a    |
--|               matching inventory spec and returns that spec.           |
--| Calling Program : -  Samples form			   		   |
--|                   -  Quality Migration Script 			   |
--| HISTORY                                                                |
--|    Mahesh Chandak	1-Oct-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION FIND_CUST_OR_INV_SPEC(p_customer_spec_rec IN  customer_spec_rec_type,
		     	    x_spec_id 	  	OUT NOCOPY NUMBER,
			    x_spec_vr_id	OUT NOCOPY NUMBER,
			    x_spec_type		OUT NOCOPY VARCHAR2,
			    x_return_status	OUT NOCOPY VARCHAR2,
			    x_message_data   	OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

--Start of comments
--+========================================================================+
--| API Name    : find_wip_spec                                            |
--| TYPE        : Group                                                    |
--| Notes       : This function RETURN TRUE if matching WIP                |
--|               spec. is found else it RETURN FALSE.                     |
--|               If matching WIP spec is found,then                       |
--|               it returns matching spec_id  and spec_vr_id              |
--| HISTORY                                                                |
--|    Mahesh Chandak	6-Aug-2002	Created.                           |
--|                                                                        |
--|    Calling Program : -  Samples form			  	   |
--|                      -  Batch Creation                                 |
--+========================================================================+
-- End of comments

FUNCTION FIND_WIP_SPEC(p_wip_spec_rec  	IN  wip_spec_rec_type,
		       x_spec_id       	OUT NOCOPY NUMBER,
		       x_spec_vr_id    	OUT NOCOPY NUMBER,
		       x_return_status	OUT NOCOPY VARCHAR2,
		       x_message_data   OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

--Start of comments
--+========================================================================+
--| API Name    : find_wip_or_inv_spec                                     |
--| TYPE        : Group                                                    |
--| Notes       : This function first looks for a matching WIP             |
--|               spec.If found,then returns that spec else looks for a    |
--|               matching inventory spec and returns that spec.           |
--| Calling Program : -  Samples form			   		   |
--|                   -  Quality Migration Script 			   |
--| HISTORY                                                                |
--|    Mahesh Chandak	1-Oct-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION FIND_WIP_OR_INV_SPEC(p_wip_spec_rec  	IN  wip_spec_rec_type,
		       x_spec_id       	OUT NOCOPY NUMBER,
		       x_spec_vr_id    	OUT NOCOPY NUMBER,
		       x_spec_type	OUT NOCOPY VARCHAR2,
		       x_return_status	OUT NOCOPY VARCHAR2,
		       x_message_data   OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;


--Start of comments
--+========================================================================+
--| API Name    : find_supplier_spec                                       |
--| TYPE        : Group                                                    |
--| Notes       : This function RETURN TRUE if matching supplier           |
--|               spec. is found else it RETURN FALSE.                     |
--|               If matching supplier spec is found,then                  |
--|               it returns matching spec_id  and spec_vr_id              |
--| HISTORY                                                                |
--|    Mahesh Chandak	6-Aug-2002	Created.                           |
--|    Calling Program : Samples form					   |
--|                      Receiving Transaction Event(Workflow)	           |
--+========================================================================+
-- End of comments

FUNCTION FIND_SUPPLIER_SPEC(p_supplier_spec_rec  IN  supplier_spec_rec_type,
		     	    x_spec_id 	  	 OUT NOCOPY NUMBER,
			    x_spec_vr_id	 OUT NOCOPY NUMBER,
			    x_return_status	 OUT NOCOPY VARCHAR2,
			    x_message_data   	 OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN ;

--Start of comments
--+========================================================================+
--| API Name    : find_supplier_or_inv_spec                                |
--| TYPE        : Group                                                    |
--| Notes       : This function first looks for a matching supplier        |
--|               spec.If found,then returns that spec else looks for a    |
--|               matching inventory spec and returns that spec.           |
--| Calling Program : -  Samples form			   		   |
--|                   -  Quality Migration Script 			   |
--| HISTORY                                                                |
--|    Mahesh Chandak	1-Oct-2002	Created.                           |
--|    Susan Feinstein  19-Sep-2003     added whse_code and location for   |
--|                                     Bug 3143796                        |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION FIND_SUPPLIER_OR_INV_SPEC(
			    p_supplier_spec_rec  IN  supplier_spec_rec_type,
		     	    x_spec_id 	  	 OUT NOCOPY NUMBER,
			    x_spec_vr_id	 OUT NOCOPY NUMBER,
			    x_spec_type		 OUT NOCOPY VARCHAR2,
			    x_return_status	 OUT NOCOPY VARCHAR2,
			    x_message_data   	 OUT NOCOPY VARCHAR2)

RETURN BOOLEAN ;

PROCEDURE get_result_match_for_spec
                  (  p_spec_id       IN  NUMBER
                   , p_lots 	     IN  OUT NOCOPY result_lot_match_tbl
                   , x_return_status OUT NOCOPY VARCHAR2
		   , x_message_data  OUT NOCOPY VARCHAR2 ) ;


FUNCTION find_location_spec(p_location_spec_rec IN  LOCATION_SPEC_REC_TYPE,
			     x_spec_id 	  	  OUT NOCOPY NUMBER,
			     x_spec_vr_id	  OUT NOCOPY NUMBER,
			     x_return_status	  OUT NOCOPY VARCHAR2,
			     x_message_data   	  OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;


FUNCTION find_resource_spec(p_resource_spec_rec IN  RESOURCE_SPEC_REC_TYPE,
			     x_spec_id 	  	  OUT NOCOPY NUMBER,
			     x_spec_vr_id	  OUT NOCOPY NUMBER,
			     x_return_status	  OUT NOCOPY VARCHAR2,
			     x_message_data   	  OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;


--+========================================================================+
--| API Name    : get_inv_spec_or_vr_id                                    |
--|                                                                        |
--| Notes      Returns spec_id or spec_vr_id depending on parameter 	   |
--|            p_spec_or_vr_ind passed. Returns 0 if not able to get 	   |
--|            the matching spec or p_spec_or_vr_ind is invalid or if      |
--|            GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC raises any error.    |
--|            Pass 'SPECID'   to p_spec_or_vr_ind to get spec_id.         |
--|            Pass 'SPECVRID' to get spec_vr_id.		           |
--|									   |
--|  HISTORY                                                               |
--|  Saikiran Vankadari	25-Nov-2005	Bug 4538523 Created.               |
--|  Calling Program : 	Item/Location Required Analysis Report             |
--+========================================================================+
-- End of comments

FUNCTION GET_INV_SPEC_OR_VR_ID(  p_inventory_item_id IN NUMBER
                                ,p_revision        IN VARCHAR2
                                ,p_grade_code      IN VARCHAR2
                                ,p_organization_id IN VARCHAR2
                                ,p_subinventory    IN VARCHAR2
                                ,p_parent_lot_number IN VARCHAR2
                                ,p_lot_number      IN VARCHAR2
                                ,p_locator_id      IN NUMBER
                                ,p_date_effective  IN DATE
                                ,p_exact_match     IN VARCHAR2
                                ,p_test_id         IN NUMBER
                                ,p_spec_or_vr_ind  IN VARCHAR2 )
RETURN NUMBER;



END gmd_spec_match_grp;

 

/
