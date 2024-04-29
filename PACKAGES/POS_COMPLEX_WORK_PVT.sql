--------------------------------------------------------
--  DDL for Package POS_COMPLEX_WORK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_COMPLEX_WORK_PVT" AUTHID CURRENT_USER AS
/* $Header: POSVCWOS.pls 120.1 2005/09/01 13:26:20 mji noship $ */

Procedure Get_Po_Amounts (
    	p_api_version     	IN  NUMBER,
    	p_Init_Msg_List		IN  VARCHAR2,
	p_po_header_id		IN  NUMBER,
	x_amt_approved		OUT NOCOPY NUMBER,
	X_amt_billed		OUT NOCOPY NUMBER,
	X_amt_financed		OUT NOCOPY NUMBER,
	X_adv_billed		OUT NOCOPY NUMBER,
	X_progress_pmt		OUT NOCOPY NUMBER,
	X_amt_recouped		OUT NOCOPY NUMBER,
	X_amt_retained		OUT NOCOPY NUMBER,
	X_amt_delivered		OUT NOCOPY NUMBER );


Procedure Get_Po_Line_Amounts (
    	p_api_version     	IN  NUMBER,
    	p_Init_Msg_List		IN  VARCHAR2,
	p_po_line_id		IN  NUMBER,
	X_amt_delivered		OUT NOCOPY NUMBER,
	X_amt_billed 		OUT NOCOPY NUMBER,
	X_advance_amt 		OUT NOCOPY NUMBER,
	X_adv_billed 		OUT NOCOPY NUMBER,
	X_amt_recouped 		OUT NOCOPY NUMBER );


Procedure Get_po_ship_amounts (
    	p_api_version     	IN  NUMBER,
    	p_Init_Msg_List		IN  VARCHAR2,
	p_po_line_location_id	IN  NUMBER,
	X_value_percent		OUT NOCOPY NUMBER,
	X_amt_approved		OUT NOCOPY NUMBER );



END POS_COMPLEX_WORK_PVT;

 

/
