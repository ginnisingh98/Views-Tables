--------------------------------------------------------
--  DDL for Package PO_VENDORS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VENDORS_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVVENS.pls 115.2 2003/10/31 00:59:16 sahegde noship $ */

-- define the supplier user table type for get_supplier_userlist
SUBTYPE supplier_user_tbl_type IS po_vendors_grp.external_user_tbl_type;

-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) :=
  NVL (FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


-- other
g_pkg_name CONSTANT VARCHAR2(30) := 'PO_VENDORS_PVT';
g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.'||g_pkg_name||'.';

PROCEDURE get_supplier_userlist(p_document_id               IN  NUMBER
                               ,p_document_type             IN  VARCHAR2
			       ,p_external_contact_id       IN  NUMBER DEFAULT NULL
                               ,x_return_status             OUT NOCOPY VARCHAR2
                               ,x_supplier_user_tbl         OUT NOCOPY supplier_user_tbl_type
                               ,x_supplier_userlist         OUT NOCOPY VARCHAR2
                               ,x_supplier_userlist_for_sql OUT NOCOPY VARCHAR2
                               ,x_num_users                 OUT NOCOPY NUMBER
                               ,x_vendor_id                 OUT NOCOPY NUMBER);

END PO_VENDORS_PVT ;

 

/
