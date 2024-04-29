--------------------------------------------------------
--  DDL for Package AP_WEB_UPGRADE_REPORT_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_UPGRADE_REPORT_DIST_PKG" AUTHID CURRENT_USER AS
/* $Header: apwuprds.pls 120.0 2006/06/28 20:46:19 dtong noship $ */

  g_debug_switch              VARCHAR2(1) := 'N';
  g_last_updated_by           NUMBER;
  g_last_update_login         NUMBER;

PROCEDURE Upgrade(errbuf                OUT NOCOPY VARCHAR2,
                  retcode               OUT NOCOPY NUMBER,
		  p_batch_size		IN VARCHAR2,
 		  p_worker_id		IN NUMBER,
   		  p_num_workers		IN NUMBER);

PROCEDURE Parent(errbuf                 OUT NOCOPY VARCHAR2,
                 retcode                OUT NOCOPY NUMBER,
		 p_batch_size		IN VARCHAR2,
 		 p_worker_id		IN NUMBER,
   		 p_num_workers		IN NUMBER);

END AP_WEB_UPGRADE_REPORT_DIST_PKG;

 

/
