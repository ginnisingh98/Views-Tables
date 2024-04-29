--------------------------------------------------------
--  DDL for Package Body PO_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_GLOBAL" AS
/* $Header: PO_GLOBAL.plb 120.0.12010000.2 2008/08/04 08:38:11 rramasam ship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_GLOBAL');

-----------------------------------------------------------------------
--Start of Comments
--Name: set_role
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Sets the role of the user for the current database session.
--  Role can have one of the following values:
--    PO_GLOBAL.g_role_BUYER : Buyer
--    PO_GLOBAL.g_role_CAT_ADMIN : Catalog Admin
--    PO_GLOBAL.g_role_SUPPLIER : Supplier
--Parameters:
--IN:
--p_role
--  role to set
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE set_role
( p_role IN VARCHAR2
)
IS
d_api_name CONSTANT VARCHAR2(30) := 'set_role';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';

BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_role', p_role);
  END IF;

  g_role := p_role;
END set_role;

-----------------------------------------------------------------------
--Start of Comments
--Name: role
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Returns the role of the current session
--Parameters:
--IN:
--IN OUT:
--OUT:
--Returns:
--  Role of the current session
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION role RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'role';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'g_role', g_role);
  END IF;

  RETURN g_role;
END role;

END PO_GLOBAL;

/
