--------------------------------------------------------
--  DDL for Package Body QA_MOAC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_MOAC_PKG" AS
/* $Header: qamoacb.pls 120.4 2006/05/22 22:02:08 shkalyan noship $ */

-- Global Package Variable for storing Session Context
g_SESSION_ORG_ID org_organization_definitions.organization_id%TYPE;
g_SESSION_ACCESS_MODE VARCHAR2(1);

-- Global Package variable for Application short name
c_APPL_SHORT_NAME CONSTANT VARCHAR2(2) := 'QA';


-- initialize the MOAC context
-- R12 Project MOAC 4637896 redesign.   p_ou_id is currently unused.
PROCEDURE init(p_ou_id NUMBER DEFAULT NULL) IS
BEGIN
    mo_global.init(c_APPL_SHORT_NAME);
END init;


-- initialize the MOAC context to single MOAC  for given Inv Org
PROCEDURE init_single_ou(p_ou_id NUMBER) IS
BEGIN
    -- call MO API to initialize the MOAC context
    mo_global.init(c_APPL_SHORT_NAME);
    mo_global.set_policy_context('S', p_ou_id);

END init_single_ou;


-- Save existing MOAC context into a global package variable.
-- Useful in transaction scenario to save parent context;
-- init context to single;
-- then restoring parent context before returning.
PROCEDURE save_context IS
BEGIN
    -- coming from a transaction, so required to
    -- save the parent MOAC context
    -- get the current org_id and access mode
    -- and save it into session
    g_SESSION_ORG_ID := mo_global.get_current_org_id;
    g_SESSION_ACCESS_MODE := mo_global.get_access_mode;

END save_context;


-- Restore the existing context used prior to returning
-- to parent transaction
PROCEDURE restore_context IS
BEGIN

    -- back to the transaction
    -- set the context back to the original
    mo_global.set_policy_context(g_SESSION_ACCESS_MODE, g_SESSION_ORG_ID);

END restore_context;


-- Derive parent OU given an Inventory Organization ID.
FUNCTION derive_ou_id(p_organization_id NUMBER)
    RETURN NUMBER IS

    -- Define cursor to get Operating Unit for Inventory Org
    -- Bug 5196069. SQL Repository Fix SQL ID 17898437.
    -- Removed usage of inv_organization_info_v and replaced with
    -- call to base table hr_organization_information
    -- to improve performance.
    CURSOR c_org_id IS
      SELECT to_number(org_information3)
      FROM   hr_organization_information
      WHERE  organization_id = p_organization_id
      AND    org_information_context = 'Accounting Information';


/*
    Bug 4958733. SQL Repository Fix SQL ID: 15007810
    CURSOR c_org_id IS
        SELECT operating_unit
        FROM  inv_organization_info_v
        WHERE organization_id = p_organization_id;
*/
/*
        SELECT operating_unit
        FROM org_organization_definitions
        WHERE organization_id = p_organization_id;
*/

    l_org_id NUMBER;

BEGIN

    OPEN c_org_id;
    FETCH c_org_id INTO l_org_id;
    CLOSE c_org_id;

    RETURN l_org_id;

END derive_ou_id;


END QA_MOAC_PKG;

/
