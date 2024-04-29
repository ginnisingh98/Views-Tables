--------------------------------------------------------
--  DDL for Package IEU_TASKS_UWQM_MIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_TASKS_UWQM_MIG_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUVTUMS.pls 115.6 2003/08/07 19:12:13 ckurian noship $ */


PROCEDURE MIGRATE_NEW_TASKS(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2);

END IEU_TASKS_UWQM_MIG_PVT;

 

/
