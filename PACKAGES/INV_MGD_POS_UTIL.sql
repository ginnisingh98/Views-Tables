--------------------------------------------------------
--  DDL for Package INV_MGD_POS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_POS_UTIL" AUTHID CURRENT_USER AS
/* $Header: INVUPOSS.pls 115.1 2002/12/24 23:38:35 vjavli ship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVUPOSS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Utilities for Inventory Position View and Export                  |
--| HISTORY                                                               |
--|     09/01/2000 Paolo Juvara      Created                              |
--+======================================================================*/


--===================
-- CONSTANTS
--===================

G_LOG_ERROR                   CONSTANT NUMBER := 5;
G_LOG_EXCEPTION               CONSTANT NUMBER := 4;
G_LOG_EVENT                   CONSTANT NUMBER := 3;
G_LOG_PROCEDURE               CONSTANT NUMBER := 2;
G_LOG_STATEMENT               CONSTANT NUMBER := 1;

--===================
-- DATA TYPES
--===================

TYPE bucket_rec_type IS RECORD
( name                        VARCHAR2(30)
, start_date                  DATE
, end_date                    DATE
, bucket_size                 VARCHAR2(30)
);

TYPE organization_rec_type IS RECORD
( id                          NUMBER
, code                        VARCHAR2(3)
, complete_flag               BOOLEAN := FALSE
);

TYPE item_rec_type IS RECORD
( organization_id             NUMBER
, organization_code           VARCHAR2(3)
, item_id                     NUMBER
, item_code                   VARCHAR2(2000)
);

TYPE bucket_tbl_type IS TABLE OF bucket_rec_type
INDEX BY BINARY_INTEGER;

TYPE organization_tbl_type IS TABLE OF organization_rec_type
INDEX BY BINARY_INTEGER;

TYPE item_tbl_type IS TABLE OF item_rec_type
INDEX BY BINARY_INTEGER;

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Log_Initialize             PUBLIC
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--=======================================================================--
PROCEDURE Log_Initialize;

--========================================================================
-- PROCEDURE : Log                        PUBLIC
-- PARAMETERS: p_level                IN  priority of the message - from
--                                        highest to lowest:
--                                          -- G_LOG_ERROR
--                                          -- G_LOG_EXCEPTION
--                                          -- G_LOG_EVENT
--                                          -- G_LOG_PROCEDURE
--                                          -- G_LOG_STATEMENT
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--=======================================================================--
PROCEDURE Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
);

END INV_MGD_POS_UTIL;

 

/
