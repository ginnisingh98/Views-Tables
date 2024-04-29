--------------------------------------------------------
--  DDL for Package CS_CREATE_AUDIT_REC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CREATE_AUDIT_REC_PKG" AUTHID CURRENT_USER AS
/* $Header: csxsraucs.pls 120.1 2005/07/19 01:34:38 appldev noship $ */

PROCEDURE Create_Initial_Audit_Manager
  (x_errbuf         OUT  NOCOPY VARCHAR2,
   x_retcode        OUT  NOCOPY VARCHAR2
  );

PROCEDURE Create_Initial_Audit_Worker
  (x_errbuf         OUT  NOCOPY  VARCHAR2,
   x_retcode        OUT  NOCOPY VARCHAR2,
   x_batch_size      IN  NUMBER,
   x_worker_id       IN  NUMBER,
   x_num_workers     IN  NUMBER
  );

END CS_CREATE_AUDIT_REC_PKG;

 

/
