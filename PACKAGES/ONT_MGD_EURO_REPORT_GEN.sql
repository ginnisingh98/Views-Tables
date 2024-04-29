--------------------------------------------------------
--  DDL for Package ONT_MGD_EURO_REPORT_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_MGD_EURO_REPORT_GEN" AUTHID CURRENT_USER AS
/* $Header: ONTREURS.pls 120.0 2005/06/01 00:53:09 appldev noship $ */

---+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|      ONTREURS.pls                                                     |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Use this package to generate output report for Euro conversion    |
--|                                                                       |
--| HISTORY                                                               |
--|
--| 12-dec-2001 BUG 2138996
--|                                                 |
--+======================================================================


--===================
-- CONSTANTS
--===================

G_OBJECT_TYPE_CUSTOMER   CONSTANT VARCHAR2(100) :=
     FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_OBJECT_CUSTOMER');

G_OBJECT_TYPE_CSITE      CONSTANT VARCHAR2(100) :=
   NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_OBJECT_CSITE'),' ');

G_OBJECT_TYPE_PRICE_LIST CONSTANT VARCHAR2(100) :=
   NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_OBJECT_PRICELIST'),' ');

G_OBJECT_TYPE_MODIFIER   CONSTANT VARCHAR2(100) :=
   NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_OBJECT_MODIFIER'),' ');

G_OBJECT_TYPE_SO         CONSTANT VARCHAR2(100) :=
    NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_OBJECT_SO'),' ');

G_OBJECT_TYPE_FORMULA         CONSTANT VARCHAR2(100) :=
    NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_OBJECT_FORMULA'),' ');

--------------------------
------- Action Codes
--------------------------
G_ACTION_CONV            CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_ACTION_CONV'),' ');

G_ACTION_IGNORE          CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_ACTION_IGNORE'),' ');

G_ACTION_COPY            CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_ACTION_COPY'),' ');

G_ACTION_INCOMPLETE      CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_ACTION_INCOMP'),' ');


--------------------------
--- Reason codes---------
-------------------------

G_REASON_EURO            CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_EURO'),' ');

G_REASON_CL_SHORT            CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_CL_SHORT'),' ');

G_REASON_PARTIAL         CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_PARTIAL'),' ');


G_REASON_PROJECT         CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_PROJECT'),' ');

G_REASON_NOTHING          CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_NOTHING'),' ');


G_REASON_RATE          CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_RATE'),' ');

G_REASON_RMA          CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_RMA'),' ');

G_REASON_USER         CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_USER'),' ');

G_REASON_VALIDATION   CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_VAL'),' ');

G_REASON_PROCESS      CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_PROCESS'),' ');

G_REASON_CANCEL       CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_CANCEL'),' ');

G_REASON_COPY         CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_COPY'),' ');

G_REASON_GET_FAILED   CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_GET'),' ');

G_REASON_NOT_ELIGIBLE      CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_NOT_ELG'),' ');

G_REASON_QUALIFIER   CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_QUALIFIER'),' ');

G_REASON_FORMULA   CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_FORMULA'),' ');

G_REASON_RLTD       CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_RLTD'),' ');

G_REASON_HOLD       CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_HOLD'),' ');

G_REASON_PR           CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_PR'),' ');

G_REASON_NSTD            CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_NSTD'),' ');

G_REASON_SITE           CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_SITE'),' ');

G_REASON_SHIP           CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_SHIP'),' ');

G_REASON_MIXED           CONSTANT VARCHAR2(100) :=
  NVL(FND_MESSAGE.get_string('ONT','OE_EUR_REPORT_REASON_MIXED'),' ');


G_RPT_PAGE_COL           CONSTANT INTEGER  :=130;
G_FORMAT_SPACE           CONSTANT INTEGER  :=2;
--
G_LOG_ERROR              CONSTANT NUMBER := 1;
G_LOG_EXCEPTION          CONSTANT NUMBER := 2;
G_LOG_EVENT              CONSTANT NUMBER := 3;
G_LOG_PROCEDURE          CONSTANT NUMBER := 4;
G_LOG_STATEMENT          CONSTANT NUMBER := 5;

--===================
-- PROCEDURE : Initialize                  PUBLIC
-- PARAMETERS: p_program_type              customer or vendor program
-- COMMENT   : This is the procedure to initialize pls/sql tables
--             for recording action information.
--===================
PROCEDURE Initialize ;


--========================================================================
-- PROCEDURE : Log      PUBLIC
-- PARAMETERS: p_level  IN  priority of the message -
--                      from highest to lowest:
--                      G_LOG_ERROR
--                      G_LOG_EXCEPTION
--                      G_LOG_EVENT
--                      G_LOG_PROCEDURE
--                      G_LOG_STATEMENT
--             p_msg    IN  message to be print on the log file
-- COMMENT   : Add an entry to the log
--=======================================================================--
PROCEDURE Log
( p_priority                    IN  NUMBER := 10
, p_msg                         IN  VARCHAR2
);


--===================
-- PROCEDURE : Add_Item              PUBLIC
-- PARAMETERS: p_object_type         converted object
--             p_action_code         convert,ignore,copy
--             p_object_ref          name of the converted object
--             p_copy_object_ref     name of the new object after convertion
--             p_reason_code         why object wasn't converted
-- COMMENT   : This is the procedure to record action information.
--====================
PROCEDURE Add_Item
( p_object_type        IN VARCHAR2
, p_action_code        IN VARCHAR2
, p_object_ref         IN VARCHAR2
, p_copy_object_ref    IN VARCHAR2 DEFAULT NULL
, p_reason_code        IN VARCHAR2 DEFAULT NULL
);

--====================
-- PROCEDURE : Generate_Report             PUBLIC
-- PARAMETERS: p_customer_num              customer number
--             p_customer_address_id       customer site address
--             p_convert_so_flag           Y/N convert SOs?
--             p_so_conversion_ncu         SO initial currency
--             p_convert_partial_so        Y/N convert SO with partial shipment
--             p_line_invoice_to_org_id    Line level Bill to site
--             p_so_reprice_flag           Reiprice flag

-- COMMENT   : This is the procedure to print action information.
--====================
PROCEDURE Generate_Report
( p_customer_num             IN VARCHAR2
, p_customer_name            IN VARCHAR2
, p_customer_id              IN NUMBER
, p_customer_address_id      IN NUMBER
, p_so_conversion_ncu        IN VARCHAR2
, p_convert_so_flag          IN VARCHAR2
, p_convert_partial_so       IN VARCHAR2
, p_line_invoice_to_org_id   IN NUMBER
, p_so_reprice_flag          IN VARCHAR2
);



END ONT_MGD_EURO_REPORT_GEN ;

 

/
