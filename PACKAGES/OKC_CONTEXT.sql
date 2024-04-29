--------------------------------------------------------
--  DDL for Package OKC_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONTEXT" authid current_user AS
/*$Header: OKCPCTXS.pls 120.1 2006/11/02 00:42:50 anjkumar noship $*/
--GLOBAL VARIABLES
G_OKC_ORG_ID    NUMBER;

FUNCTION  get_okc_org_id RETURN NUMBER;

PROCEDURE set_okc_org_context(p_org_id IN NUMBER DEFAULT NULL,
                              p_organization_id IN NUMBER DEFAULT NULL);

PROCEDURE set_okc_org_context(p_chr_id IN NUMBER);

FUNCTION  get_okc_organization_id RETURN NUMBER;

--new procedure added to save the current OKC and MOAC contexts
--the following contexts are saved
--  OKC_CONTEXT :   ORGANIZATION_ID
--  OKC_CONTEXT :   BUSINESS_GROUP_ID
--  MOAC (via MO_GLOBAL.set_policy_context)
--      MO_GLOBAL.g_access_mode     (MULTI_ORG :    ACCESS_MODE)
--      MO_GLOBAL.g_current_org_id  (MULTI_ORG2 :    CURRENT_ORG_ID)
PROCEDURE save_current_contexts;

--new procedure added to restore the OKC and MOAC contexts saved by
--call to save_current_contexts
PROCEDURE restore_contexts;

END okc_context;

 

/
