--------------------------------------------------------
--  DDL for Package INV_CONSUMPTION_TXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CONSUMPTION_TXN_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVRETS.pls 120.1 2006/04/27 14:30:39 rajkrish noship $ */
--+=======================================================================+
--|               Copyright (c) 2003 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVVRETS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Create Records in MTL_CONSUMPTION_TRANSACTIONS                    |
--| HISTORY                                                               |
--|     07/22/2003 David Herring       created                            |
--+========================================================================

--===================
-- CONSTANTS
--===================

G_LOG_PROCEDURE               CONSTANT NUMBER := 2;

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Price Update Insert     PUBLIC
-- PARAMETERS: p_transaction_id            IN unique id and link to mmt
--             p_consumption_po_header_id  IN consumption advice (global)
--             p_consumption_release_id    IN consumption advice (local)
--             p_transaction_quantity      IN quantity retroactively priced
--
-- COMMENT   : This procedure will insert records
--           : into mtl_consumption_transactions
--=========================================================================
PROCEDURE price_update_insert
( p_transaction_id               IN   NUMBER
, p_consumption_po_header_id     IN   NUMBER
, p_consumption_release_id       IN   NUMBER
, p_transaction_quantity         IN   NUMBER
, p_po_distribution_id           IN   NUMBER
, x_msg_count                    OUT  NOCOPY NUMBER
, x_msg_data                     OUT  NOCOPY VARCHAR2
, x_return_status                OUT  NOCOPY VARCHAR2
);

END INV_CONSUMPTION_TXN_PVT;

 

/
