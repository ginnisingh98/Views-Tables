--------------------------------------------------------
--  DDL for Package OKC_TERMS_VERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_VERSION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVDVRS.pls 120.0 2005/05/25 18:30:39 appldev noship $ */

/* This API will be used to clear amendment related columns */

  Procedure clear_amendment (
    x_return_status    OUT NOCOPY VARCHAR2,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_keep_summary     IN  VARCHAR2 DEFAULT 'N'
  );

/*
-- This API will be used to version terms whenever a document is versioned.
*/
  PROCEDURE Version_Doc     (
    x_return_status    OUT NOCOPY VARCHAR2,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_version_number   IN  NUMBER
  );

/*
--This API will be used to restore a version terms whenever a version of
-- document is restored.It is a very OKS/OKC/OKO specific functionality
*/
  PROCEDURE Restore_Doc_Version (
    x_return_status    OUT NOCOPY VARCHAR2,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_version_number   IN  NUMBER
  );

/*
--This API will be used to delete terms whenever a version of document is deleted.
*/
  Procedure Delete_Doc_Version (
    x_return_status    OUT NOCOPY VARCHAR2,

    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_version_number   IN  NUMBER
  );

END OKC_TERMS_VERSION_PVT;

 

/
