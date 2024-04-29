--------------------------------------------------------
--  DDL for Package MISC_TRANSACTIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MISC_TRANSACTIONS_UTIL" AUTHID CURRENT_USER AS
/* $Header: INVTXUTS.pls 120.1 2005/06/17 18:13:59 appldev  $*/

PROCEDURE init_misc_transaction_values(p_organization_id IN NUMBER,
                                       p_account_segments IN VARCHAR2 DEFAULT NULL,
                                       x_is_negative_quantity_allowed OUT NOCOPY VARCHAR2,
                                       x_is_wms_purchased OUT NOCOPY VARCHAR2,
                                       x_is_wms_installed OUT NOCOPY VARCHAR2,
                                       x_transaction_header_id OUT NOCOPY NUMBER,
                                       x_account_disposition_id OUT NOCOPY NUMBER,
                                       x_stock_locator_control_code OUT NOCOPY NUMBER,
                                       x_primary_cost_method OUT NOCOPY NUMBER);

END MISC_TRANSACTIONS_UTIL;

 

/
