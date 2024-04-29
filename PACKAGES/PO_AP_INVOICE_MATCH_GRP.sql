--------------------------------------------------------
--  DDL for Package PO_AP_INVOICE_MATCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AP_INVOICE_MATCH_GRP" AUTHID CURRENT_USER AS
/* $Header: POXAPINS.pls 120.2 2005/07/20 16:17:08 arusingh noship $*/

--<Complex Work R12 START>
-------------------------------------------------------------------------
--Pre-reqs:
--  N/A
--Function:
--  Updates values on the PO line location and distribution due to AP
--  activity (billing, prepayments, recoupment, retainage, etc)
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--IN OUT:
--p_line_loc_changes_rec
--  An object of PO_AP_LINE_LOC_REC_TYPE
--p_dist_changes_rec
--  An object of PO_AP_DIST_REC_TYPE
--OUT:
--x_return_status
--  Apps API param.  Value is VARCHAR2(1)
--  FND_API.G_RET_STS_SUCCESS if update succeeds
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_msg_data
--  Contains the error details in the case of UNEXP_ERROR or ERROR
-------------------------------------------------------------------------
PROCEDURE update_document_ap_values(
  p_api_version			IN		NUMBER
, p_line_loc_changes_rec	IN OUT NOCOPY	PO_AP_LINE_LOC_REC_TYPE
, p_dist_changes_rec		IN OUT NOCOPY	PO_AP_DIST_REC_TYPE
, x_return_status		OUT NOCOPY	VARCHAR2
, x_msg_data			OUT NOCOPY	VARCHAR2
);


---------------------------------------------------------------------------
--Pre-reqs:
--  All line locations must belong to the same PO document
--Function:
--  Calculate how much to retain against particular line locations, based
--  on the contract terms specified on the PO.
--Parameters:
--IN:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_line_location_id_tbl
--  Table of ids from the set of {existing POLL.line_location}
--  All ids must belong to the same PO document
--p_line_loc_match_amt_tbl
--  Each tbl entry corresponds to 1 entry (w/ same index) in
--  p_line_location_id_tbl.  It passes in the amount being matched against
--  each line location in this trxn
--  The amount must be passed in using the PO currency
--OUT:
--x_return_status
--  Apps API Std param.  Value is VARCHAR2(1)
--  FND_API.G_RET_STS_SUCCESS if calculation succeeds
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_msg_data
--  Contains the error details in the case of UNEXP_ERROR or ERROR
--x_amount_to_retain_tbl
--  Each tbl entry corresponds to 1 entry (with same index) in
--  p_line_location_id_tbl.  It returns the calculated amount to retain
--  against each line location
-------------------------------------------------------------------------
PROCEDURE get_amount_to_retain(
  p_api_version			IN		NUMBER
, p_line_location_id_tbl	IN		po_tbl_number
, p_line_loc_match_amt_tbl	IN		po_tbl_number
, x_return_status		OUT NOCOPY	VARCHAR2
, x_msg_data			OUT NOCOPY	VARCHAR2
, x_amount_to_retain_tbl	OUT NOCOPY	po_tbl_number
);
--<Complex Work R12 END>



---------------------------------------------------------------------------------------
--Start of Comments
--Name:         get_po_ship_amounts
--
--Function:     This procedure provides AP with ordered and cancelled amounts on the PO
--              shipments for amount matching purposes
--
--End of Comments
----------------------------------------------------------------------------------------

PROCEDURE get_po_ship_amounts (p_api_version              IN          NUMBER,
                               p_receive_transaction_id   IN          RCV_TRANSACTIONS.transaction_id%TYPE,
                               x_ship_amt_ordered         OUT NOCOPY  PO_LINE_LOCATIONS_ALL.amount%TYPE,
                               x_ship_amt_cancelled       OUT NOCOPY  PO_LINE_LOCATIONS_ALL.amount_cancelled%TYPE,
                               x_ret_status               OUT NOCOPY  VARCHAR2,
                               x_msg_count                OUT NOCOPY  NUMBER,
                               x_msg_data                 OUT NOCOPY  VARCHAR2);


---------------------------------------------------------------------------------------
--Start of Comments
--Name:         get_po_dist_amounts
--
--Function:     This procedure provides AP with ordered and cancelled amounts on the PO
--              distributions for amount matching purposes
--
--End of Comments
----------------------------------------------------------------------------------------

PROCEDURE get_po_dist_amounts (p_api_version              IN          NUMBER,
                               p_po_distribution_id       IN          PO_DISTRIBUTIONS_ALL.po_distribution_id%TYPE,
                               x_dist_amt_ordered         OUT NOCOPY  PO_DISTRIBUTIONS_ALL.amount_ordered%TYPE,
                               x_dist_amt_cancelled       OUT NOCOPY  PO_DISTRIBUTIONS_ALL.amount_cancelled%TYPE,
                               x_ret_status               OUT NOCOPY  VARCHAR2,
                               x_msg_count                OUT NOCOPY  NUMBER,
                               x_msg_data                 OUT NOCOPY  VARCHAR2);

---------------------------------------------------------------------------------------
--Start of Comments
--Name:         update_po_ship_amounts
--
--Function:     This procedure updates the amount billed on po shipments during amount matching
--              process
--
--End of Comments
----------------------------------------------------------------------------------------

PROCEDURE update_po_ship_amounts (p_api_version              IN          NUMBER,
                                  p_po_line_location_id      IN          PO_LINE_LOCATIONS_ALL.line_location_id%TYPE,
                                  p_ship_amt_billed          IN          PO_LINE_LOCATIONS_ALL.amount_billed%TYPE,
                                  x_ret_status               OUT NOCOPY  VARCHAR2,
                                  x_msg_count                OUT NOCOPY  NUMBER,
                                  x_msg_data                 OUT NOCOPY  VARCHAR2);

---------------------------------------------------------------------------------------
--Start of Comments
--Name:         update_po_dist_amounts
--
--Function:     This procedure updates the amount billed on po distributions during amount
--              matching process
--
--End of Comments
----------------------------------------------------------------------------------------

PROCEDURE update_po_dist_amounts (p_api_version              IN          NUMBER,
                                  p_po_distribution_id       IN          PO_DISTRIBUTIONS_ALL.po_distribution_id%TYPE,
                                  p_dist_amt_billed          IN          PO_DISTRIBUTIONS_ALL.amount_billed%TYPE,
                                  x_ret_status               OUT NOCOPY  VARCHAR2,
                                  x_msg_count                OUT NOCOPY  NUMBER,
                                  x_msg_data                 OUT NOCOPY  VARCHAR2);


---------------------------------------------------------------------------------------
--Start of Comments
--Name:         set_final_match_flag
--
--Function:     This procedure updates the final_match_flag on po line locations during
--              invoice final match.
--
--End of Comments
---------------------------------------------------------------------------------------

PROCEDURE set_final_match_flag (p_api_version              IN          	NUMBER					,
                                p_entity_type		   IN          	VARCHAR2				,
                                p_entity_id_tbl            IN          	PO_TBL_NUMBER				,
				p_final_match_flag	   IN          	PO_LINE_LOCATIONS.FINAL_MATCH_FLAG%TYPE	,
				p_init_msg_list		   IN          	VARCHAR2 := FND_API.G_FALSE		,
				p_commit                   IN	       	VARCHAR2 := FND_API.G_FALSE		,
                                x_ret_status               OUT NOCOPY	VARCHAR2				,
                                x_msg_count                OUT NOCOPY  	NUMBER					,
                                x_msg_data                 OUT NOCOPY  	VARCHAR2				);

END PO_AP_INVOICE_MATCH_GRP;

 

/
