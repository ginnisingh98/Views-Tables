--------------------------------------------------------
--  DDL for Package INV_CONSIGNED_DIAGNOSTICS_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CONSIGNED_DIAGNOSTICS_CP" AUTHID CURRENT_USER AS
-- $Header: INVCCIDS.pls 115.0 2003/09/17 03:43:01 rajkrish noship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCCIDS.pls
--|INV_CONSIGNED_INV_PREVAL_CP
--| DESCRIPTION                                                           |
--|     consigned inv Diagnostics/Pre-validation conc pgm
--| HISTORY                                                               |
--|     Jul-28th Rajesh Krishnan Created
--+======================================================================--

------------------
--- constants
-------------------

--===================
-- PROCEDURES AND FUNCTIONS
--===================

/*========================================================================
-- PROCEDURE : Run_Consigned_Diagnostics
-- PARAMETERS: x_retcode            OUT NOCOPY Return status
--             x_errbuff            OUT NOCOPY Return error message
--             p_send_notification  IN VARCHAR2
--              to indicate if workflow notifications needs to be
--               send to the Buyer
--             p_notification_resend_days IN NUMBER
--              to indicate to send notification only if
--             las_notification sent date for the same combination
--             of org/item/supplier/site/error + p_notification_resend_days
--              >= sysdate
--
-- COMMENT   : This is the main concurrent program procedure
--              that is directly invoked by the conc program
--             " INV Consigned Inventory Diagnostics"
--             This program does not accept any specific ORG
--             as Input as the logic is to validate all
--             eligible consigned transactions
--             1) Ownership transfer to regulat stock and
--             2) Consumption Advice pre-validation
--             and insert into a new errors table
--             The results of the concurrent program can be
--             viewed from a separate HTML UI under INV
--=======================================================================*/
PROCEDURE Run_Consigned_Diagnostics
( x_retcode                  OUT NOCOPY VARCHAR2
, x_errbuff                  OUT NOCOPY VARCHAR2
, p_send_notification        IN VARCHAR2
, p_notification_resend_days IN NUMBER
)
;


END INV_CONSIGNED_DIAGNOSTICS_CP ;

 

/
