--------------------------------------------------------
--  DDL for Package PO_VENDORS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VENDORS_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGVENS.pls 120.1 2005/12/14 14:52:12 bao noship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) :=
  NVL (FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- define table type for supplier user list
TYPE external_user_tbl_type IS TABLE OF
  fnd_user.user_name%TYPE
    INDEX BY BINARY_INTEGER;

-- other
g_pkg_name CONSTANT VARCHAR2(30) := 'PO_VENDORS_GRP';
g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.'||g_pkg_name||'.';

---------------------------------------------------------------------------------
-- API to return supplier users for the given PO document.
---------------------------------------------------------------------------------
PROCEDURE get_external_userlist
          (p_api_version               IN NUMBER
          ,p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
          ,p_document_id               IN NUMBER
          ,p_document_type             IN VARCHAR2
          ,p_external_contact_id       IN  NUMBER DEFAULT NULL
          ,x_return_status             OUT NOCOPY VARCHAR2
          ,x_msg_count                 OUT NOCOPY NUMBER
          ,x_msg_data                  OUT NOCOPY VARCHAR2
          ,x_external_user_tbl         OUT NOCOPY external_user_tbl_type);

---------------------------------------------------------------------------------
-- Over loaded version of the procedure to return additional parameters.
---------------------------------------------------------------------------------
PROCEDURE get_external_userlist
          (p_api_version               IN NUMBER
          ,p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
          ,p_document_id               IN NUMBER
          ,p_document_type             IN VARCHAR2
          ,p_external_contact_id       IN  NUMBER DEFAULT NULL
          ,x_return_status             OUT NOCOPY VARCHAR2
          ,x_msg_count                 OUT NOCOPY NUMBER
          ,x_msg_data                  OUT NOCOPY VARCHAR2
          ,x_external_user_tbl         OUT NOCOPY external_user_tbl_type
          ,x_supplier_userlist         OUT NOCOPY VARCHAR2
          ,x_supplier_userlist_for_sql OUT NOCOPY VARCHAR2
          ,x_num_users                 OUT NOCOPY NUMBER
          ,x_vendor_id                 OUT NOCOPY NUMBER);

END PO_VENDORS_GRP;

 

/
