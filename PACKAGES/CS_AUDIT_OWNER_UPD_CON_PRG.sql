--------------------------------------------------------
--  DDL for Package CS_AUDIT_OWNER_UPD_CON_PRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_AUDIT_OWNER_UPD_CON_PRG" AUTHID CURRENT_USER AS
/* $Header: csxaowns.pls 120.1 2005/07/19 01:46:23 appldev noship $ */

PROCEDURE Create_Audit_Gen_Manager
  (x_errbuf         OUT  NOCOPY VARCHAR2,
   x_retcode        OUT  NOCOPY VARCHAR2
  );

PROCEDURE Create_Audit_Gen_Worker
  (x_errbuf       OUT  NOCOPY VARCHAR2,
   x_retcode      OUT  NOCOPY VARCHAR2,
   x_batch_size    IN  NUMBER,
   x_worker_id     IN  NUMBER,
   x_num_workers   IN  NUMBER
  );

END CS_AUDIT_OWNER_UPD_CON_PRG;

 

/
