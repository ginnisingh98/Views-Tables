--------------------------------------------------------
--  DDL for Package ARP_ETAX_INVAPI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ETAX_INVAPI_UTIL" AUTHID CURRENT_USER AS
/* $Header: AREBTIAS.pls 120.0.12000000.2 2008/01/15 19:52:23 mraymond ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

PROCEDURE calculate_tax(p_request_id IN NUMBER,
                        p_error_count IN OUT NOCOPY NUMBER,
                        p_return_status  OUT NOCOPY NUMBER);

PROCEDURE cleanup_tax(p_trx_id IN NUMBER);

END ARP_ETAX_INVAPI_UTIL;


 

/
