--------------------------------------------------------
--  DDL for Package OKC_TERMS_VERSION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_VERSION_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGDVRS.pls 120.0.12010000.2 2011/12/09 13:33:11 serukull ship $ */
/*
-- This API will be used to version terms whenever a document is versioned.
*/
  PROCEDURE Version_Doc     (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_version_number   IN  NUMBER,
    p_clear_amendment  IN  VARCHAR2 default 'Y',
    p_include_gen_attach IN VARCHAR2 DEFAULT 'Y'
  );

/*
--This API will be used to restore a version terms whenever a version of
-- document is restored.It is a very OKS/OKC/OKO specific functionality
*/
  PROCEDURE Restore_Doc_Version (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_version_number   IN  NUMBER
  );

/*
--This API will be used to delete terms whenever a version of document is deleted.
*/
  Procedure Delete_Doc_Version (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_version_number   IN  NUMBER
  );

/* This API will be used to clear amendment related columns */

  Procedure clear_amendment (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_keep_summary     IN VARCHAR2 DEFAULT 'N'
  );

END OKC_TERMS_VERSION_GRP;

/
