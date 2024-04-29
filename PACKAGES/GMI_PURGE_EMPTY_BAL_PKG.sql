--------------------------------------------------------
--  DDL for Package GMI_PURGE_EMPTY_BAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_PURGE_EMPTY_BAL_PKG" AUTHID CURRENT_USER AS
/* $Header: GMIPEBLS.pls 120.0 2005/05/25 16:07:45 appldev noship $ */
 PROCEDURE Purge_empty_balance( err_buf      		OUT NOCOPY VARCHAR2,
  	                         ret_code     		OUT NOCOPY VARCHAR2,
  				 p_item_from 		IN  VARCHAR2,            /* Bug 3377672 Start */
                                 p_item_to  		IN  VARCHAR2,
                                 p_whse_from 		IN  VARCHAR2,
                                 p_whse_to 		IN  VARCHAR2,
                                 p_inv_class 		IN  VARCHAR2,
                                 p_lot_ind     		IN  NUMBER DEFAULT 0,   -- 0-No; 1-Yes
                                 p_purge_precision 	IN  NUMBER DEFAULT 9,
	                         p_criteria_id 		IN  NUMBER DEFAULT 0 	 /* Bug 3377672 End */
	                       ) ;
END GMI_PURGE_EMPTY_BAL_PKG;

 

/
