--------------------------------------------------------
--  DDL for Package OKL_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTEXT" AUTHID CURRENT_USER AS
/*$Header: OKLRCTXS.pls 115.10 2003/11/12 21:53:47 avsingh noship $*/
--GLOBAL VARIABLES
G_OKC_ORG_ID    NUMBER;

FUNCTION  get_okc_org_id RETURN NUMBER;

PROCEDURE set_okc_org_context(p_org_id IN NUMBER DEFAULT NULL,
                              p_organization_id IN NUMBER DEFAULT NULL);

PROCEDURE set_okc_org_context(p_chr_id IN NUMBER);

FUNCTION  get_okc_organization_id RETURN NUMBER;

END okl_context;

 

/
