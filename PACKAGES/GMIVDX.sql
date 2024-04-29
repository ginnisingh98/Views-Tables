--------------------------------------------------------
--  DDL for Package GMIVDX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIVDX" AUTHID CURRENT_USER AS
/* $Header: GMIVDXS.pls 120.1 2005/07/12 14:59:45 jsrivast noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIVDXS.pls                                                           |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIVDX                                                                |
 |                                                                          |
 | TYPE                                                                     |
 |   Private                                                                |
 | DESCRIPTION                                                              |
 |    This package contains the private APIs for Process / Discrete Transfer|
 |                                                                          |
 | CONTENTS                                                                 |
 |    Create_discrete_transfer_pvt                                          |
 |    Validate_transfer                                                     |
 |    construct_post_records                                                |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jalaj Srivastava                                            |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/

/* Record Type Declaration */

TYPE hdr_type IS RECORD
(
 orgn_code	        	gmi_discrete_transfers.orgn_code%TYPE
,co_code                	gmi_discrete_transfers.co_code%TYPE
,transfer_number		gmi_discrete_transfers.transfer_number%TYPE
,transfer_type	        	gmi_discrete_transfers.transfer_type%TYPE
,trans_date	        	gmi_discrete_transfers.trans_date%TYPE
,comments	        	gmi_discrete_transfers.comments%TYPE
,attribute_category		gmi_discrete_transfers.attribute_category%TYPE
,attribute1	        	gmi_discrete_transfers.attribute1%TYPE
,attribute2	        	gmi_discrete_transfers.attribute2%TYPE
,attribute3	        	gmi_discrete_transfers.attribute3%TYPE
,attribute4	        	gmi_discrete_transfers.attribute4%TYPE
,attribute5	        	gmi_discrete_transfers.attribute5%TYPE
,attribute6	        	gmi_discrete_transfers.attribute6%TYPE
,attribute7	        	gmi_discrete_transfers.attribute7%TYPE
,attribute8	        	gmi_discrete_transfers.attribute8%TYPE
,attribute9	        	gmi_discrete_transfers.attribute9%TYPE
,attribute10	        	gmi_discrete_transfers.attribute10%TYPE
,attribute11	        	gmi_discrete_transfers.attribute11%TYPE
,attribute12	        	gmi_discrete_transfers.attribute12%TYPE
,attribute13        		gmi_discrete_transfers.attribute13%TYPE
,attribute14	        	gmi_discrete_transfers.attribute14%TYPE
,attribute15	        	gmi_discrete_transfers.attribute15%TYPE
,attribute16	        	gmi_discrete_transfers.attribute16%TYPE
,attribute17	        	gmi_discrete_transfers.attribute17%TYPE
,attribute18	        	gmi_discrete_transfers.attribute18%TYPE
,attribute19	        	gmi_discrete_transfers.attribute19%TYPE
,attribute20	        	gmi_discrete_transfers.attribute20%TYPE
,attribute21            	gmi_discrete_transfers.attribute21%TYPE
,attribute22            	gmi_discrete_transfers.attribute22%TYPE
,attribute23            	gmi_discrete_transfers.attribute23%TYPE
,attribute24            	gmi_discrete_transfers.attribute24%TYPE
,attribute25            	gmi_discrete_transfers.attribute25%TYPE
,attribute26            	gmi_discrete_transfers.attribute26%TYPE
,attribute27            	gmi_discrete_transfers.attribute27%TYPE
,attribute28            	gmi_discrete_transfers.attribute28%TYPE
,attribute29            	gmi_discrete_transfers.attribute29%TYPE
,attribute30            	gmi_discrete_transfers.attribute30%TYPE
/* ****************************************************************** */
,assignment_type        	sy_docs_seq.assignment_type%TYPE
,transaction_header_id          NUMBER
);

TYPE line_type IS RECORD
(
 line_no	                gmi_discrete_transfer_lines.line_no%TYPE
,opm_item_id	                gmi_discrete_transfer_lines.opm_item_id%TYPE
,opm_whse_code	                gmi_discrete_transfer_lines.opm_whse_code%TYPE
,opm_location	                gmi_discrete_transfer_lines.opm_location%TYPE
,opm_lot_id	                gmi_discrete_transfer_lines.opm_lot_id%TYPE
,opm_lot_expiration_date	gmi_discrete_transfer_lines.opm_lot_expiration_date%TYPE
,opm_lot_status	                gmi_discrete_transfer_lines.opm_lot_status%TYPE
,opm_grade	                gmi_discrete_transfer_lines.opm_grade%TYPE
,opm_charge_acct_id	        gmi_discrete_transfer_lines.opm_charge_acct_id%TYPE
,opm_charge_au_id	        gmi_discrete_transfer_lines.opm_charge_au_id%TYPE
,opm_reason_code	        gmi_discrete_transfer_lines.opm_reason_code%TYPE
,odm_inv_organization_id	gmi_discrete_transfer_lines.odm_inv_organization_id%TYPE
,odm_item_id	                gmi_discrete_transfer_lines.odm_item_id%TYPE
,odm_item_revision              gmi_discrete_transfer_lines.odm_item_revision%TYPE
,odm_subinventory	        gmi_discrete_transfer_lines.odm_subinventory%TYPE
,odm_locator_id	                gmi_discrete_transfer_lines.odm_locator_id%TYPE
,odm_lot_number	                VARCHAR2(80)
,odm_lot_expiration_date	gmi_discrete_transfer_lines.odm_lot_expiration_date%TYPE
,odm_charge_account_id	        gmi_discrete_transfer_lines.odm_charge_account_id%TYPE
,odm_period_id	                gmi_discrete_transfer_lines.odm_period_id%TYPE
,odm_unit_cost	                gmi_discrete_transfer_lines.odm_unit_cost%TYPE
,odm_reason_id                  gmi_discrete_transfer_lines.odm_reason_id%TYPE
,quantity	                gmi_discrete_transfer_lines.quantity%TYPE
,quantity_um	                gmi_discrete_transfer_lines.quantity_um%TYPE
,quantity2	                gmi_discrete_transfer_lines.quantity2%TYPE
,opm_primary_quantity           gmi_discrete_transfer_lines.opm_primary_quantity%TYPE
,odm_primary_quantity     	gmi_discrete_transfer_lines.odm_primary_quantity%TYPE
,lot_level                      gmi_discrete_transfer_lines.lot_level%TYPE
,attribute_category	        gmi_discrete_transfer_lines.attribute_category%TYPE
,attribute1	                gmi_discrete_transfer_lines.attribute1%TYPE
,attribute2	                gmi_discrete_transfer_lines.attribute2%TYPE
,attribute3	                gmi_discrete_transfer_lines.attribute3%TYPE
,attribute4	                gmi_discrete_transfer_lines.attribute4%TYPE
,attribute5	                gmi_discrete_transfer_lines.attribute5%TYPE
,attribute6	                gmi_discrete_transfer_lines.attribute6%TYPE
,attribute7	                gmi_discrete_transfer_lines.attribute7%TYPE
,attribute8	                gmi_discrete_transfer_lines.attribute8%TYPE
,attribute9	                gmi_discrete_transfer_lines.attribute9%TYPE
,attribute10	                gmi_discrete_transfer_lines.attribute10%TYPE
,attribute11	                gmi_discrete_transfer_lines.attribute11%TYPE
,attribute12	                gmi_discrete_transfer_lines.attribute12%TYPE
,attribute13	                gmi_discrete_transfer_lines.attribute13%TYPE
,attribute14	                gmi_discrete_transfer_lines.attribute14%TYPE
,attribute15	                gmi_discrete_transfer_lines.attribute15%TYPE
,attribute16	                gmi_discrete_transfer_lines.attribute16%TYPE
,attribute17	                gmi_discrete_transfer_lines.attribute17%TYPE
,attribute18	                gmi_discrete_transfer_lines.attribute18%TYPE
,attribute19	                gmi_discrete_transfer_lines.attribute19%TYPE
,attribute20	                gmi_discrete_transfer_lines.attribute20%TYPE
,attribute21                    gmi_discrete_transfer_lines.attribute21%TYPE
,attribute22                    gmi_discrete_transfer_lines.attribute22%TYPE
,attribute23                    gmi_discrete_transfer_lines.attribute23%TYPE
,attribute24                    gmi_discrete_transfer_lines.attribute24%TYPE
,attribute25                    gmi_discrete_transfer_lines.attribute25%TYPE
,attribute26                    gmi_discrete_transfer_lines.attribute26%TYPE
,attribute27                    gmi_discrete_transfer_lines.attribute27%TYPE
,attribute28                    gmi_discrete_transfer_lines.attribute28%TYPE
,attribute29                    gmi_discrete_transfer_lines.attribute29%TYPE
,attribute30                    gmi_discrete_transfer_lines.attribute30%TYPE
/* *********************************************************************** */
,opm_item_no                    ic_item_mst.item_no%TYPE
,lot_control                    NUMBER /* same as OPM item lot control flag */
/* Jalaj Srivastava Bug 3812701 */
,odm_quantity_uom_code          mtl_units_of_measure.uom_code%TYPE
/* *************************************************************************
   these attributes are duplicated at the lot level as the lot may be at line
   or lot record level
   ************************************************************************* */
,opm_lot_no                     ic_lots_mst.lot_no%TYPE
,opm_sublot_no                  ic_lots_mst.sublot_no%TYPE
);

TYPE lot_type IS RECORD
(
 line_no	                gmi_discrete_transfer_lines.line_no%TYPE
,opm_lot_id	                gmi_discrete_transfer_lots.opm_lot_id%TYPE
,opm_lot_expiration_date	gmi_discrete_transfer_lots.opm_lot_expiration_date%TYPE
,opm_lot_status	                gmi_discrete_transfer_lots.opm_lot_status%TYPE
,opm_grade	                gmi_discrete_transfer_lots.opm_grade%TYPE
,odm_lot_number	                VARCHAR2(80)
,odm_lot_expiration_date	gmi_discrete_transfer_lines.odm_lot_expiration_date%TYPE
,quantity	                gmi_discrete_transfer_lots.quantity%TYPE
,quantity2	                gmi_discrete_transfer_lots.quantity2%TYPE
,opm_primary_quantity           gmi_discrete_transfer_lots.opm_primary_quantity%TYPE
,odm_primary_quantity           gmi_discrete_transfer_lots.odm_primary_quantity%TYPE
/* *********************************************************************** */
,opm_lot_no                     ic_lots_mst.lot_no%TYPE
,opm_sublot_no                  ic_lots_mst.sublot_no%TYPE
);

TYPE line_type_tbl IS TABLE OF line_type           	            INDEX BY BINARY_INTEGER;

TYPE lot_type_tbl  IS TABLE OF lot_type                       	    INDEX BY BINARY_INTEGER;

TYPE line_row_tbl  IS TABLE OF gmi_discrete_transfer_lines%ROWTYPE  INDEX BY BINARY_INTEGER;

TYPE lot_row_tbl   IS TABLE OF gmi_discrete_transfer_lots%ROWTYPE   INDEX BY BINARY_INTEGER;

/* PROCEDURE Declaration */

PROCEDURE Create_transfer_pvt
( p_api_version          IN              NUMBER
, p_init_msg_list        IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN              NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY      VARCHAR2
, x_msg_count            OUT NOCOPY      NUMBER
, x_msg_data             OUT NOCOPY      VARCHAR2
, p_hdr_rec              IN              hdr_type
, p_line_rec_tbl         IN              line_type_tbl
, p_lot_rec_tbl          IN              lot_type_tbl
, x_hdr_row              OUT NOCOPY      gmi_discrete_transfers%ROWTYPE
, x_line_row_tbl         OUT NOCOPY      line_row_tbl
, x_lot_row_tbl          OUT NOCOPY      lot_row_tbl
, x_transaction_set_id   OUT NOCOPY      mtl_material_transactions.transaction_set_id%TYPE
);

PROCEDURE Validate_transfer
( p_api_version          IN              NUMBER
, p_init_msg_list        IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN              NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY      VARCHAR2
, x_msg_count            OUT NOCOPY      NUMBER
, x_msg_data             OUT NOCOPY      VARCHAR2
, p_hdr_rec              IN  OUT NOCOPY  hdr_type
, p_line_rec_tbl         IN  OUT NOCOPY  line_type_tbl
, p_lot_rec_tbl          IN  OUT NOCOPY  lot_type_tbl
);

PROCEDURE construct_post_records
( p_api_version          IN              NUMBER
, p_init_msg_list        IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN              NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY      VARCHAR2
, x_msg_count            OUT NOCOPY      NUMBER
, x_msg_data             OUT NOCOPY      VARCHAR2
, p_hdr_rec              IN OUT NOCOPY   hdr_type
, p_line_rec_tbl         IN OUT NOCOPY   line_type_tbl
, p_lot_rec_tbl          IN OUT NOCOPY   lot_type_tbl
, x_hdr_row              OUT NOCOPY      gmi_discrete_transfers%ROWTYPE
, x_line_row_tbl         OUT NOCOPY      line_row_tbl
, x_lot_row_tbl          OUT NOCOPY      lot_row_tbl
);

GMI_Lot_Sublot_Delimiter                 Varchar2(1);
INV_TRANS_DATE_OPTION                    pls_integer;
INV_OPEN_PAST_PERIOD                     BOOLEAN;
WMS_INSTALLED                            VARCHAR2(5);

END GMIVDX;

 

/
