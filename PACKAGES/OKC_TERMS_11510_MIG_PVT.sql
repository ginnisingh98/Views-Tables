--------------------------------------------------------
--  DDL for Package OKC_TERMS_11510_MIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_11510_MIG_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVMIGS.pls 120.0 2005/05/25 19:25:15 appldev noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

PROCEDURE migrate_to_11510(errbuf              OUT NOCOPY VARCHAR2 ,
                           retcode             OUT NOCOPY NUMBER,
                           p_batch_size        IN NUMBER := 1000
                            );

END OKC_TERMS_11510_MIG_PVT;

 

/
