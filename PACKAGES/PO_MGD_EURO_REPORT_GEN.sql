--------------------------------------------------------
--  DDL for Package PO_MGD_EURO_REPORT_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_MGD_EURO_REPORT_GEN" AUTHID CURRENT_USER AS
/* $Header: POXREURS.pls 115.8 2002/11/23 02:06:05 sbull ship $ */

/*+=======================================================================+
--|               Copyright (c) 1999 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|      POXREURS.pls                                                     |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Use this package to generate output report for Euro conversion    |
--|                                                                       |
--| HISTORY                                                               |
--|     10/21/1999 tsimmond        Created                                |
--|     03/14/2000 tsimmond        Updated                                |
--|     10/31/2001 vto             2040015: Modified log message levels   |
--|                                substr FND_MESSAGES to prevent errors  |
--|                                when the message is too long for print |
--|    11/28/2001 tsimmond  updated, added dbrv and set verify off        |
--+======================================================================*/




--===================
-- CONSTANTS
--===================
G_OBJECT_TYPE_VENDOR     CONSTANT VARCHAR2(60):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_OBJECT_VENDOR'),1,60);
G_OBJECT_TYPE_VSITE      CONSTANT VARCHAR2(60):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_OBJECT_SITE'),1,60);
G_OBJECT_TYPE_VBANK      CONSTANT VARCHAR2(60):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_OBJECT_BANK'),1,60);
G_OBJECT_TYPE_PO         CONSTANT VARCHAR2(60):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_OBJECT_PO'),1,60);
--
G_ACTION_CONV            CONSTANT VARCHAR2(15):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_ACTION_CONV'),1,15);
G_ACTION_IGNORE          CONSTANT VARCHAR2(15):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_ACTION_IGNORE'),1,15);
G_ACTION_COPY            CONSTANT VARCHAR2(15):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_ACTION_COPY'),1,15);
--2040015
--Changed length to 40 since this is the max length for the output. NLS value might be too long to
--fit so truncating it.

G_REASON_EURO            CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_EURO'),1,40);
G_REASON_PARTIAL         CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_PARTIAL'),1,40);
G_REASON_MANUAL          CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_MANUAL'),1,40);
G_REASON_CONTRACT        CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_CONTR'),1,40);
G_REASON_IN_PLACE        CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_IN_PLACE'),1,40);
G_REASON_SHORT           CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_SHORT'),1,40);
G_REASON_NOTHING         CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_NOTHING'),1,40);
G_REASON_DIF_CUR         CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_DIF_CUR'),1,40);
G_REASON_EMU             CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_EMU'),1,40);
G_REASON_DR_SHIP         CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_DR_SHIP'),1,40);
G_REASON_ENC_ON          CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_ENC_ON'),1,40);
G_REASON_PROJECT         CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_PROJECT'),1,40);
G_REASON_RATE            CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_RATE'),1,40);
G_REASON_MAN_NUM         CONSTANT VARCHAR2(40):=SUBSTRB(FND_MESSAGE.get_string
                                                           ('PO','PO_EUR_REPORT_REASON_MAN_NUM'),1,40);
--
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
-- PARAMETERS:
-- COMMENT   : This is the procedure to initialize pls/sql tables
--             for recording action information of vendor conversion.
--===================
PROCEDURE Initialize;


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
( p_priority                    IN  NUMBER
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
-- PARAMETERS: p_vendor_id                 Supplier ID
--             p_vendor_site_code          Supplier Site ID
--             p_site_conversion_ncu       supplier site initial currency
--             p_convert_standard_flag     Y/N convert Standard POs?
--             p_convert_blanket_flag      Y/N convert Blanket POs?
--             p_convert_planned_flag      Y/N convert Planned POs?
--             p_convert_contract_flag     Y/N convert Contract POs?
--             p_po_conversion_ncu         PO initial currency
--             p_conv_partial              Indicates if partially transacted
--                                         PO need to be converted
--             p_upd_db_flag               Y/N update db with supplier conversion?
--
-- COMMENT   : This is the procedure to print action information.
--====================
PROCEDURE Generate_Report
( p_vendor_id                 IN NUMBER
, p_vendor_site_id            IN NUMBER   DEFAULT NULL
, p_vsite_conversion_ncu      IN VARCHAR2 DEFAULT NULL
, p_convert_standard_flag     IN VARCHAR2 DEFAULT 'N'
, p_convert_blanket_flag      IN VARCHAR2 DEFAULT 'N'
, p_convert_planned_flag      IN VARCHAR2 DEFAULT 'N'
, p_convert_contract_flag     IN VARCHAR2 DEFAULT 'N'
, p_po_conversion_ncu         IN VARCHAR2 DEFAULT NULL
, p_conv_partial              IN VARCHAR2 DEFAULT 'N'
, p_upd_db_flag               IN VARCHAR2 DEFAULT 'N'
);


END PO_MGD_EURO_REPORT_GEN;

 

/
