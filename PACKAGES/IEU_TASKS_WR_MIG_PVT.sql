--------------------------------------------------------
--  DDL for Package IEU_TASKS_WR_MIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_TASKS_WR_MIG_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUVTWRS.pls 115.0 2003/09/04 18:59:20 fsuthar noship $ */


PROCEDURE IEU_SYNCH_WR_DIST_STATUS(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2);

END IEU_TASKS_WR_MIG_PVT;

 

/
