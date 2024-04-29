--------------------------------------------------------
--  DDL for Package CS_CONTPNTS_AUDIT_UPD_CON_PRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CONTPNTS_AUDIT_UPD_CON_PRG" AUTHID CURRENT_USER AS
/* $Header: csxacpts.pls 120.2 2005/08/01 18:45:00 allau noship $ */

PROCEDURE Create_Cpt_Audit_Manager
  (x_errbuf         OUT  NOCOPY VARCHAR2,
   x_retcode        OUT  NOCOPY VARCHAR2,
   p_cutoff_date     IN  VARCHAR2         -- <4507823/>
  );
PROCEDURE Create_Cpt_Audit_Worker
  (x_errbuf       OUT  NOCOPY VARCHAR2,
   x_retcode      OUT  NOCOPY VARCHAR2,
   x_batch_size    IN  NUMBER,
   x_worker_id     IN  NUMBER,
   x_num_workers   IN  NUMBER,
   p_cutoff_date   IN  VARCHAR2,          -- <4507823/>
   p_update_date   IN  VARCHAR2           -- <4507823/>
  );

END CS_CONTPNTS_AUDIT_UPD_CON_PRG;

 

/
