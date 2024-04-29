--------------------------------------------------------
--  DDL for Package INV_PREPROCESS_SCAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PREPROCESS_SCAN" AUTHID CURRENT_USER AS
/* $Header: INVSCANS.pls 120.1 2005/06/17 15:12:31 appldev  $ */


-- x_return_status, should be S if a success. In this case, it will default
-- the x_processed_value as the result of the scan. If this is set to null
-- or E, then the scan is assumed to be p_scanned_value
-- x_processed_value returns the value that should be used for the scanned
-- value
-- p_current_page_name is the page name in which the scan was performed
-- p_scanned_value is the actual scanned value that has to be pre-processed.
PROCEDURE process_scan(x_return_status     OUT nocopy VARCHAR2,
		       x_processed_value   OUT nocopy VARCHAR2,
		       p_current_page_name IN  VARCHAR2,
		       p_scanned_value     IN  VARCHAR2);

END INV_PREPROCESS_SCAN;

 

/
