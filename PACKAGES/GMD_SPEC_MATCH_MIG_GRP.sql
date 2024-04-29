--------------------------------------------------------
--  DDL for Package GMD_SPEC_MATCH_MIG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SPEC_MATCH_MIG_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDGSMMS.pls 120.0 2005/05/25 19:12:36 appldev noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGSMMS.pls                                        |
--| Package Name       : GMD_SPEC_MATCH_MIG_GRP                              |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Specification Match for    |
--|    migration. The spec_status conditions are removed from the WHERE      |
--|    clause, this is the only difference from the spec matching used by    |
--|    QM.                                                                   |
--|                                                                          |
--| HISTORY                                                                  |
--|    B. Stone   13-Oct_2004	Created.  Bug 3934121.                       |
--|                             Removed find_location_spec and               |
--|                             find_resource_spec, these are not used by    |
--|                             migration.                                   |
--|                                                                          |
--+==========================================================================+
-- End of comments


-- adding test_id. This is to support production requirement.
-- test_id would be passed only by the production team.
TYPE INVENTORY_SPEC_REC_TYPE IS RECORD (
 item_id        		NUMBER
,grade          		VARCHAR2(4)
,orgn_code      		VARCHAR2(4)
,lot_id         		NUMBER
,lot_no				VARCHAR2(32)
,sublot_no			VARCHAR2(32)
,whse_code      		VARCHAR2(4)
,location       		VARCHAR2(16)
,date_effective 		DATE
,exact_match		        VARCHAR2(1)
,test_id			NUMBER
);


TYPE CUSTOMER_SPEC_REC_TYPE IS RECORD
(item_id                     NUMBER
,grade 			     VARCHAR2(4)
,orgn_code                   VARCHAR2(4)
,whse_code                   VARCHAR2(4)
,cust_id 	             NUMBER
,date_effective              DATE
,org_id    	             NUMBER
,ship_to_site_id             NUMBER
,order_id    	             NUMBER
,order_line	             NUMBER
,order_line_id               NUMBER
,look_in_other_orgn          VARCHAR2(1)
,exact_match		     VARCHAR2(1)
,lot_id         	     NUMBER
,lot_no			     VARCHAR2(32)
,sublot_no		     VARCHAR2(32)
) ;

TYPE SUPPLIER_SPEC_REC_TYPE IS RECORD
(item_id                     NUMBER
,grade 			     VARCHAR2(4)
,orgn_code                   VARCHAR2(4)
,whse_code                   VARCHAR2(4)
,location                    VARCHAR2(16)
,supplier_id 	             NUMBER
,supplier_site_id            NUMBER
,po_header_id		     NUMBER
,po_line_id		     NUMBER
,date_effective              DATE
,exact_match		     VARCHAR2(1)
,lot_id         	     NUMBER
,lot_no			     VARCHAR2(32)
,sublot_no		     VARCHAR2(32)
);

TYPE WIP_SPEC_REC_TYPE IS RECORD
(item_id                     NUMBER
,grade 			     VARCHAR2(4)
,orgn_code                   VARCHAR2(4)
,batch_id                    NUMBER
,recipe_id                   NUMBER
,recipe_no                   VARCHAR2(32)
,recipe_version              NUMBER(5)
,formula_id                  NUMBER
,formulaline_id              NUMBER
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
,exact_match		     VARCHAR2(1)
,lot_id         	     NUMBER
,lot_no			     VARCHAR2(32)
,sublot_no		     VARCHAR2(32)
,find_spec_with_step         VARCHAR2(1)
);

--MCHANDAK bug# 2645698
-- created additional paramater find_spec_with_step which will be set to 'Y' when
-- calling from batch step creation workflow.Also changed the main select.

TYPE MATCH_RESULT_LOT_REC_TYPE IS RECORD
( item_id          NUMBER                       -- IN
 ,lot_id           NUMBER                       -- IN
 ,whse_code        VARCHAR2(4)                  -- IN
 ,location         VARCHAR2(16)                 -- IN
 ,sample_id        NUMBER                       -- OUT
 ,spec_match_type  VARCHAR2(1)                  -- OUT
 ,result_type      VARCHAR2(1)                  -- OUT
 ,event_spec_disp_id      NUMBER                -- OUT
 );

TYPE result_lot_match_tbl  IS TABLE OF MATCH_RESULT_LOT_REC_TYPE INDEX BY BINARY_INTEGER;


TYPE LOCATION_SPEC_REC_TYPE IS RECORD (
 loct_orgn_code      		VARCHAR2(4)
,whse_code      		VARCHAR2(4)
,location       		VARCHAR2(16)
,date_effective 		DATE
);


TYPE RESOURCE_SPEC_REC_TYPE IS RECORD (
 resource_orgn_code      	VARCHAR2(4)
,resources			VARCHAR2(16)
,resource_instance_id		NUMBER
,date_effective 		DATE
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



END gmd_spec_match_mig_grp;

 

/
