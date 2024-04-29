--------------------------------------------------------
--  DDL for Package WIP_MTL_ROLLBACK_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MTL_ROLLBACK_CLEANUP" AUTHID CURRENT_USER AS
/* $Header: wipmtrbs.pls 115.6 2002/12/13 08:07:07 rmahidha ship $ */
 PROCEDURE DELETE_ROWS ( trx_header_id NUMBER ) ;
END WIP_MTL_ROLLBACK_CLEANUP;

 

/
