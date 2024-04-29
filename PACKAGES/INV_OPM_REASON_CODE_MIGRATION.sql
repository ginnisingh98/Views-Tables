--------------------------------------------------------
--  DDL for Package INV_OPM_REASON_CODE_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_OPM_REASON_CODE_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: INVRCDSS.pls 120.0 2005/10/06 13:59:53 jgogna noship $ */


PROCEDURE MIGRATE_REASON_CODE (  p_migration_run_id  IN NUMBER
                                 , p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE
                                 , x_failure_count OUT NOCOPY  NUMBER);

END INV_OPM_REASON_CODE_MIGRATION;

 

/
