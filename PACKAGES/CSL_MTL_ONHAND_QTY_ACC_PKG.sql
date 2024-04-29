--------------------------------------------------------
--  DDL for Package CSL_MTL_ONHAND_QTY_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_MTL_ONHAND_QTY_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslo1acs.pls 120.0 2005/08/30 01:37:36 utekumal noship $ */

PROCEDURE REFRESH_ONHAND_QTY;

PROCEDURE PROCESS_ACC( l_current_run_date IN DATE);

PROCEDURE DELETE_ALL_ACC_RECORDS( p_resource_id IN NUMBER
                      , x_return_status OUT NOCOPY VARCHAR2 );

END CSL_MTL_ONHAND_QTY_ACC_PKG;

 

/
