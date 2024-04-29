--------------------------------------------------------
--  DDL for Package WSH_OPM_CONV_MIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_OPM_CONV_MIG_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHOPMDS.pls 120.0 2006/09/15 15:04:13 lgao noship $ */

/*====================================================================
--  PROCEDURE:
--   WSH_LOT_NUMBERS
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to OPM-OM Wdd lot number updates
--
--  PARAMETERS:
--    p_migration_run_id   This is used for message logging.
--    p_commit             Commit flag.
--    x_failure_count      count of the failed lines.An out parameter.
--
--  SYNOPSIS:
--
--    MIGRATE_OPM_OM_OPEN_LINES (  p_migration_run_id  IN NUMBER
--                          	, p_commit IN VARCHAR2
--                          	, x_failure_count OUT NUMBER)
--  HISTORY
--====================================================================*/

PROCEDURE WSH_LOT_NUMBERS( p_migration_run_id  IN NUMBER
                         , p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE
                         , x_failure_count OUT NOCOPY NUMBER
                         ) ;
End WSH_OPM_CONV_MIG_PKG;

 

/
