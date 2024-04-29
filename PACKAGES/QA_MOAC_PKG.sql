--------------------------------------------------------
--  DDL for Package QA_MOAC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_MOAC_PKG" AUTHID CURRENT_USER AS
/* $Header: qamoacs.pls 120.1 2005/10/02 03:12 bso noship $ */


-- Initialize the MOAC context for Quality application
-- R12 Project MOAC 4637896 redesign.   p_ou_id is currently unused.
PROCEDURE init(p_ou_id NUMBER DEFAULT NULL);


-- Initialize the MOAC context to single MOAC  for given Inv Org
PROCEDURE init_single_ou(p_ou_id NUMBER);


-- Save existing MOAC context into a global package variable.
-- Useful in transaction scenario to save parent context;
-- init context to single;
-- then restoring parent context before returning.
PROCEDURE save_context;


-- Restore the existing context used prior to returning
-- to parent transaction
PROCEDURE restore_context;


-- Derive parent OU given an Inventory Organization ID.
FUNCTION derive_ou_id(p_organization_id NUMBER) RETURN NUMBER;


END QA_MOAC_PKG;

 

/
