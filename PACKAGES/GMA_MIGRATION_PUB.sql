--------------------------------------------------------
--  DDL for Package GMA_MIGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_MIGRATION_PUB" AUTHID CURRENT_USER AS
/* $Header: GMAPMIGS.pls 120.1 2006/04/10 12:52:44 txdaniel noship $ */

PROCEDURE Check_Organization_Dependents (P_orgn_code VARCHAR2,
                                         P_update VARCHAR2,
                                         X_active_ind OUT NOCOPY NUMBER);


PROCEDURE populate_lot_migration;

FUNCTION get_item_no(p_item_id NUMBER) RETURN VARCHAR2;

FUNCTION get_lot_no(p_lot_id NUMBER) RETURN VARCHAR2;

FUNCTION get_orgn_code (p_whse_code VARCHAR2) RETURN VARCHAR2;


END gma_migration_pub;

 

/
