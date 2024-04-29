--------------------------------------------------------
--  DDL for Package PO_CONTERMS_UTL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CONTERMS_UTL_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGCTUS.pls 120.4.12010000.2 2010/03/05 06:18:46 vinnaray ship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) :=
  NVL (FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- Read profile option 'contracts enabled'
g_contracts_enabled CONSTANT VARCHAR2(1) :=
  NVL (FND_PROFILE.VALUE('POC_ENABLED'),'N');

-- <11i10+ Contracts ER Auto Apply terms>
-- Read profile option 'Auto Apply Contracts template'
g_auto_apply_template CONSTANT VARCHAR2(1) :=
  NVL (FND_PROFILE.VALUE('PO_AUTO_APPLY_TEMPLATE'),'N');

-- declare categories table type based on contracts item category type dfn
SUBTYPE item_category_tbl_type IS OKC_TERMS_UTIL_GRP.category_tbl_type;

-- declare items table type based on contracts items table type definition
SUBTYPE item_tbl_type IS OKC_TERMS_UTIL_GRP.item_tbl_type;

-- define table type for supplier user list
SUBTYPE external_user_tbl_type IS PO_VENDORS_GRP.external_user_tbl_type;

-- Contracts variable codes TBL Type
SUBTYPE variable_code_tbl_type IS OKC_TERMS_UTIL_GRP.variable_code_tbl_type;

-- Contracts variable values TBL Type
SUBTYPE variable_value_tbl_type IS OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type;

-- other
g_pkg_name CONSTANT VARCHAR2(30) := 'PO_CONTERMS_UTL_GRP';
g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.'||g_pkg_name||'.';

---------------------------------------------------------------------------------
-- API to indicate if Procurement Contracts has been enabled or not.
---------------------------------------------------------------------------------
FUNCTION is_contracts_enabled RETURN VARCHAR2;

---------------------------------------------------------------------------------
-- Overloaded PROCEDURE to indicate if Contracts has been enabled or not.
---------------------------------------------------------------------------------
PROCEDURE is_contracts_enabled
            (p_api_version               IN NUMBER --bug4028805
            ,p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
            ,x_return_status             OUT NOCOPY VARCHAR2
            ,x_msg_count                 OUT NOCOPY NUMBER
            ,x_msg_data                  OUT NOCOPY VARCHAR2
            ,x_contracts_enabled         OUT NOCOPY VARCHAR2);

---------------------------------------------------------------------------------
-- Returns the Contract document type to be used for a purchase order
---------------------------------------------------------------------------------
FUNCTION Get_Po_Contract_Doctype(p_sub_doc_type IN VARCHAR2) RETURN VARCHAR2;

---------------------------------------------------------------------------------
-- API to return supplier users for the given PO document. Please check cooments
-- body for more details.
---------------------------------------------------------------------------------
PROCEDURE get_external_userlist
          (p_api_version               IN NUMBER      --bug4028805
          ,p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
          ,p_document_id               IN NUMBER
          ,p_document_type             IN VARCHAR2
          ,p_external_contact_id       IN  NUMBER DEFAULT NULL
          ,x_return_status             OUT NOCOPY VARCHAR2
          ,x_msg_count                 OUT NOCOPY NUMBER
          ,x_msg_data                  OUT NOCOPY VARCHAR2
          ,x_external_user_tbl         OUT NOCOPY external_user_tbl_type);


---------------------------------------------------------------------------------
-- Overloaded API to return supplier users for the given PO document.
-- Please check comments section in the body for more details.
---------------------------------------------------------------------------------
PROCEDURE get_external_userlist
          (p_api_version               IN NUMBER      --bug4028805
          ,p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
          ,p_document_id               IN NUMBER
          ,p_document_type             IN VARCHAR2
          ,p_external_contact_id       IN  NUMBER DEFAULT NULL
          ,x_return_status             OUT NOCOPY VARCHAR2
          ,x_msg_count                 OUT NOCOPY NUMBER
          ,x_msg_data                  OUT NOCOPY VARCHAR2
          ,x_external_userlist         OUT NOCOPY VARCHAR2);

---------------------------------------------------------------------------------
-- API to generate the list of distinct item categories used in a PO document.
-- For more details please check the comments section in the body.
---------------------------------------------------------------------------------
PROCEDURE get_item_categorylist
          (p_api_version   IN  NUMBER
          ,p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
          ,p_doc_type      IN VARCHAR2 := NULL  -- CLM Mod project
          ,p_document_id   IN  NUMBER
          ,x_return_status OUT NOCOPY VARCHAR2
          ,x_msg_count     OUT NOCOPY NUMBER
          ,x_msg_data      OUT NOCOPY VARCHAR2
          ,x_category_tbl  OUT NOCOPY item_category_tbl_type
          ,x_item_tbl      OUT NOCOPY item_tbl_type);

---------------------------------------------------------------------------------
-- API to allow saving of changes to contract terms based on PO status
-- For more details on usage and assumptions, please check the comments section
-- in the package body
---------------------------------------------------------------------------------
PROCEDURE IS_Po_Update_Allowed (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_doc_type               IN VARCHAR2 := NULL,  -- CLM Mod project
  p_header_id              IN NUMBER,
  p_callout_string         IN VARCHAR2,
  p_lock_flag              IN VARCHAR2 DEFAULT 'N',
  x_update_allowed         OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER);

----------------------------------------------------------------------------------------
-- API to make changes to Po headers whe template is attached or dropped from a
-- purchase order. For more details on usage and auumptions, please check comments
-- in package body
----------------------------------------------------------------------------------------
PROCEDURE Apply_Template_Change (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_doc_type               IN VARCHAR2 := NULL,  -- CLM Mod project
  p_header_id              IN NUMBER,
  p_callout_string         IN VARCHAR2,
  p_template_changed       IN VARCHAR2 DEFAULT 'N',
  p_commit                 IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_update_allowed         OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER);

----------------------------------------------------------------------------------------
-- API to check which variable values changed since last PO revision
-- For more details on usage and auumptions, please check comments
-- in package body
----------------------------------------------------------------------------------------
PROCEDURE Attribute_Value_Changed (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_doc_type               IN VARCHAR2 := NULL,  -- CLM Mod project
  p_doc_id                 IN NUMBER,
  p_sys_var_tbl            IN OUT NOCOPY VARIABLE_CODE_TBL_TYPE,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER);

----------------------------------------------------------------------------------------
-- API to return value of po attributes reffered in Contract Terms
-- For more details on usage and auumptions, please check comments
-- in package body
----------------------------------------------------------------------------------------
PROCEDURE Get_PO_Attribute_Values(
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_doc_type               IN VARCHAR2 := NULL,  -- CLM Mod project
  p_doc_id                 IN NUMBER,
  p_sys_var_value_tbl      IN OUT NOCOPY VARIABLE_VALUE_TBL_TYPE,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER);

---------------------------------------------------------------------------------
-- API to return last Signed or Approved(no signature required)revision number
-- For more details on usage and assumptions, please check the comments section
-- in the package body
---------------------------------------------------------------------------------
PROCEDURE Get_Last_Signed_Revision (
  p_api_version            IN NUMBER,
  p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_doc_type               IN VARCHAR2 := NULL,  -- CLM Mod project
  p_header_id              IN NUMBER,
  p_revision_num           IN NUMBER,
  x_signed_revision_num    OUT NOCOPY NUMBER,
  x_signed_records         OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_data               OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER);

---------------------------------------------------------------------------------
-- <11i10+ Contracts ER Auto Apply terms>
-- API to apply  the default contract template to a purchasing document
-- For more details on usage and assumptions, please check the comments section
-- in the package body
---------------------------------------------------------------------------------
PROCEDURE  Auto_Apply_ConTerms (
          p_document_id     IN  NUMBER,
          p_template_id     IN  NUMBER,
	  x_return_status   OUT NOCOPY VARCHAR2);

---------------------------------------------------------------------------------
-- <Contracts ER Auto Apply terms>
-- API to get  the default contract template to a purchasing document
-- For more details on usage and assumptions, please check the comments section
-- in the package body
---------------------------------------------------------------------------------
PROCEDURE get_def_proc_contract_info  (
	          p_doc_subtype     IN  VARCHAR2,
	          p_org_id          IN NUMBER,
	          p_conterms_exist_flag IN VARCHAR2,
	          x_template_id     OUT NOCOPY VARCHAR2,
	          x_template_name   OUT NOCOPY VARCHAR2,
                  x_authoring_party OUT NOCOPY VARCHAR2,
	          x_return_status   OUT NOCOPY VARCHAR2);


---------------------------------------------------------------------------------
-- <R12 Procurement Contracts Integration>
-- API to get authoring party and template name from a document.
-- For more details on usage and assumptions, please check the comments section
-- in the package body
---------------------------------------------------------------------------------
Procedure Get_Contract_Details(
    x_return_status         OUT NOCOPY VARCHAR2,
    p_doc_type              IN  VARCHAR2,
    p_doc_subtype           IN  VARCHAR2,
    p_document_id           IN  NUMBER,
    x_authoring_party       OUT NOCOPY VARCHAR2,
    x_template_name         OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------------------
-- FP CU2-R12: Migrate PO
-- Function to check if the last archived version has conterms
---------------------------------------------------------------------------------
FUNCTION get_archive_conterms_flag (p_po_header_id  IN NUMBER)
RETURN VARCHAR2;

END PO_CONTERMS_UTL_GRP;

/
