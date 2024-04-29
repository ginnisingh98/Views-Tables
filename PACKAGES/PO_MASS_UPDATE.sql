--------------------------------------------------------
--  DDL for Package PO_MASS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_MASS_UPDATE" AUTHID CURRENT_USER AS
/* $Header: POXMUB1S.pls 115.2 2003/08/15 22:31:13 sahegde noship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) :=
  NVL (FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- other
g_pkg_name CONSTANT VARCHAR2(30) := 'PO_MASS_UPDATE';
g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.'||g_pkg_name||'.';
/*================================================================

  PROCEDURE NAME: 	po_update_buyer()

==================================================================*/

PROCEDURE po_update_buyer(x_old_buyer_id  IN NUMBER,
                          x_new_buyer_id  IN NUMBER,
                          x_commit_intrl  IN NUMBER);


END PO_MASS_UPDATE;

 

/
