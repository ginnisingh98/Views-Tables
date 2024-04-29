--------------------------------------------------------
--  DDL for Package GML_OPM_OM_CONV_MIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_OPM_OM_CONV_MIG_PKG" AUTHID CURRENT_USER AS
/* $Header: GMLCONVS.pls 120.0 2005/10/27 07:34 nchekuri noship $ */


PROCEDURE Migrate_opm_om_open_lines (  p_migration_run_id  IN NUMBER
                                 , p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE
                                 , x_failure_count OUT NOCOPY  NUMBER);

END GML_OPM_OM_CONV_MIG_PKG;

 

/
