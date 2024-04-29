--------------------------------------------------------
--  DDL for Package QP_RESOLVE_INCOMPATABILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_RESOLVE_INCOMPATABILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVINCS.pls 120.1.12010000.1 2008/07/28 11:58:45 appldev ship $ */

 PROCEDURE Resolve_Incompatability(p_pricing_phase_id 		    NUMBER,
				   		     p_processing_flag  	 	    VARCHAR2,
				               p_list_price	      	    NUMBER,
				               p_line_index		 	    NUMBER,
				               x_return_status	OUT NOCOPY	    VARCHAR2,
				               x_return_status_txt OUT NOCOPY      VARCHAR2);

 FUNCTION  Precedence_For_List_Line(p_list_header_id NUMBER,
                                    p_list_line_id     	    NUMBER,
                                    p_incomp_grp_id             VARCHAR2,
                                    p_line_index                NUMBER,
                                    p_pricing_phase_id          NUMBER)
 RETURN NUMBER;

 TYPE precedence_rec_type IS RECORD
   (created_from_list_line_id   NUMBER:=NULL,
    product_precedence          NUMBER:=NULL,
    original_precedence         NUMBER:=NULL,
    product_uom_code            VARCHAR2(30) := NULL,
    inventory_item_id           VARCHAR2(30) := NULL,
    incompatability_grp_code    VARCHAR2(30) := NULL,
    ask_for_flag                VARCHAR2(1) := NULL);

 TYPE precedence_tbl_type is TABLE OF precedence_rec_type INDEX BY BINARY_INTEGER;


 PROCEDURE Best_Price_For_Phase(p_list_price 			    NUMBER,
					       p_line_index 			    NUMBER,
						  p_pricing_phase_id 		    NUMBER,
	  				       x_return_status	  OUT NOCOPY	    VARCHAR2,
						  x_return_status_txt OUT NOCOPY         VARCHAR2);

 PROCEDURE Determine_Pricing_UOM_And_Qty(p_line_index            NUMBER,
						 p_order_uom_code        VARCHAR2,
						 p_order_qty             NUMBER,
						 p_pricing_phase_id      NUMBER,
                                                 p_call_big_search     BOOLEAN,
						 x_list_line_id	   OUT NOCOPY NUMBER,
						 x_return_status     OUT NOCOPY VARCHAR2,
						 x_return_status_txt OUT NOCOPY VARCHAR2);

 PROCEDURE Delete_Ldets_Complete (p_line_detail_index_tbl      IN QP_PREQ_GRP.NUMBER_TYPE,
                                  p_pricing_status_text IN VARCHAR2,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_return_status_txt   OUT NOCOPY VARCHAR2);

 PRAGMA RESTRICT_REFERENCES (Precedence_For_List_Line , WNDS);

END QP_Resolve_Incompatability_PVT ;

/
