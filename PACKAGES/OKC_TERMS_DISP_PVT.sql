--------------------------------------------------------
--  DDL for Package OKC_TERMS_DISP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_DISP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVTERMSDISPS.pls 120.0 2005/05/25 18:04:56 appldev noship $ */

FUNCTION get_terms_display_order
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,

    p_document_id       IN  NUMBER,
    p_document_type     IN  VARCHAR2,
    p_terms_type        IN  VARCHAR2,
    p_terms_id          IN  NUMBER,
    p_run_id            IN  VARCHAR2
) RETURN VARCHAR2;
FUNCTION get_terms_structure_level
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_document_id       IN  NUMBER,
    p_document_type     IN  VARCHAR2,
    p_terms_type        IN  VARCHAR2,
    p_terms_id          IN  NUMBER,
    p_run_id            IN  VARCHAR2
) RETURN NUMBER;
END OKC_TERMS_DISP_PVT;

 

/
