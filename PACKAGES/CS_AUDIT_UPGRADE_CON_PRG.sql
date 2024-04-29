--------------------------------------------------------
--  DDL for Package CS_AUDIT_UPGRADE_CON_PRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_AUDIT_UPGRADE_CON_PRG" AUTHID CURRENT_USER AS
/* $Header: csxaucps.pls 120.5 2005/07/25 18:34:44 appldev ship $ */

PROCEDURE Perform_Audit_Upgrade
  (x_errbuf         OUT  NOCOPY VARCHAR2,
   x_retcode        OUT  NOCOPY VARCHAR2,
   p_audit_date            IN   VARCHAR2,
   p_total_workers         IN   NUMBER
  );

PROCEDURE Worker_Audit_Upgrade
  (x_errbuf     OUT NOCOPY VARCHAR2,
   x_retcode    OUT NOCOPY VARCHAR2,
   x_batch_size  IN NUMBER,
   x_worker_id   IN NUMBER,
   x_num_workers IN NUMBER,
   p_audit_date  IN VARCHAR2,
   p_update_date IN VARCHAR2
  );

END CS_AUDIT_UPGRADE_CON_PRG;

 

/
