--------------------------------------------------------
--  DDL for Package GMIVTDX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIVTDX" AUTHID CURRENT_USER AS
/* $Header: GMIVTDXS.pls 120.0 2005/05/25 15:57:44 appldev noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIVTDXS.pls                                                          |
 |                                                                          |
 | TYPE                                                                     |
 |   Private                                                                |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIVTDX                                                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the private APIs for Process / Discrete Transfer|
 |    inserting transactions, creating lots in ODM  and updating balances   |
 |    in OPM inventory and Oracle Inventory.                                |
 |                                                                          |
 | Contents                                                                 |
 |    create_txn_update_balances                                            |
 |    create_txn_update_bal_in_opm                                          |
 |    complete_transaction_in_opm                                           |
 |    create_txn_update_bal_in_odm                                          |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jalaj Srivastava                                            |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/

TYPE txn_vars_type IS RECORD
(
  opm_item_um			VARCHAR2(4)
, opm_item_um2			VARCHAR2(4)
, lot_control           	pls_integer
, opm_lot_indivisible       	pls_integer
, odm_lot_number_uniqueness	pls_integer
, opm_qty_line_type		pls_integer
, odm_qty_line_type		pls_integer
);

PROCEDURE create_txn_update_balances
( p_api_version          	IN               NUMBER
, p_init_msg_list        	IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               	IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     	IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        	OUT NOCOPY       VARCHAR2
, x_msg_count            	OUT NOCOPY       NUMBER
, x_msg_data             	OUT NOCOPY       VARCHAR2
, p_transfer_id              	IN               NUMBER
, p_line_id            	        IN               NUMBER
, x_transaction_header_id 	IN OUT NOCOPY    NUMBER
);

PROCEDURE create_txn_update_bal_in_opm
( p_api_version            IN               NUMBER
, p_init_msg_list          IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit                 IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level       IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status          OUT NOCOPY       VARCHAR2
, x_msg_count              OUT NOCOPY       NUMBER
, x_msg_data               OUT NOCOPY       VARCHAR2
, p_hdr_row                IN               gmi_discrete_transfers%ROWTYPE
, p_line_row               IN               gmi_discrete_transfer_lines%ROWTYPE
, p_lot_row_tbl            IN               GMIVDX.lot_row_tbl
, p_txn_vars_rec           IN               txn_vars_type
);

PROCEDURE create_txn_update_bal_in_odm
( p_api_version            IN               NUMBER
, p_init_msg_list          IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit                 IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level       IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status          OUT NOCOPY       VARCHAR2
, x_msg_count              OUT NOCOPY       NUMBER
, x_msg_data               OUT NOCOPY       VARCHAR2
, p_hdr_row                IN               gmi_discrete_transfers%ROWTYPE
, p_line_row               IN               gmi_discrete_transfer_lines%ROWTYPE
, p_lot_row_tbl            IN               GMIVDX.lot_row_tbl
, p_txn_vars_rec           IN               txn_vars_type
, p_odm_txn_type_rec       IN               inv_validate.transaction
, x_transaction_header_id  IN OUT NOCOPY    NUMBER
);

END GMIVTDX;

 

/
