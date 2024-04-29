--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_UPGRADE_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVUPGS.pls 120.1 2005/08/09 22:22:02 scolvenk noship $ */


   PROCEDURE PO_UPDATE_MGR(
                  X_errbuf      OUT NOCOPY VARCHAR2,
                  X_retcode     OUT NOCOPY VARCHAR2,
                  p_batch_size  IN NUMBER,
                  p_num_workers IN NUMBER);

   PROCEDURE PO_UPDATE_WKR(
                  X_errbuf      OUT NOCOPY VARCHAR2,
                  X_retcode     OUT NOCOPY VARCHAR2,
                  p_batch_size  IN NUMBER,
                  p_worker_id   IN NUMBER,
                  p_num_workers IN NUMBER);

END PO_DOCUMENT_UPGRADE_PVT;

 

/
