--------------------------------------------------------
--  DDL for Package OKC_XPRT_INT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_INT_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCVXIBEEXPS.pls 120.1 2005/06/01 11:21:16 appldev  $ */

---------------------------------------------------
--  Procedure:
---------------------------------------------------

  PROCEDURE get_contract_terms (
    p_api_version               IN            NUMBER,
    p_init_msg_list             IN            VARCHAR2,
    p_document_type             IN            VARCHAR2,
    p_document_id               IN            NUMBER,
    p_template_id               IN            NUMBER,
    p_called_from_ui            IN            VARCHAR2 DEFAULT 'N',
    p_document_number           IN            VARCHAR2 DEFAULT NULL,
    p_run_xprt_flag             IN            VARCHAR2 DEFAULT 'Y',
    x_return_status             OUT  NOCOPY   VARCHAR2,
    x_msg_count                 OUT  NOCOPY   NUMBER,
    x_msg_data                  OUT  NOCOPY   VARCHAR2
  );

  PROCEDURE delete_empty_sections (
      p_api_version               IN            NUMBER,
      p_init_msg_list             IN            VARCHAR2,
      p_document_type             IN            VARCHAR2,
      p_document_id               IN            NUMBER,
      p_template_id               IN            NUMBER,
      p_document_number           IN            VARCHAR2 DEFAULT NULL,
      x_return_status             OUT  NOCOPY   VARCHAR2,
      x_msg_count                 OUT  NOCOPY   NUMBER,
      x_msg_data                  OUT  NOCOPY   VARCHAR2
    );



END OKC_XPRT_INT_GRP ;

 

/
