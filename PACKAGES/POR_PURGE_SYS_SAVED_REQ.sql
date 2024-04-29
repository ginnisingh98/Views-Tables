--------------------------------------------------------
--  DDL for Package POR_PURGE_SYS_SAVED_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_PURGE_SYS_SAVED_REQ" AUTHID CURRENT_USER AS
/* $Header: PORSSPGS.pls 120.0 2005/06/04 01:44:59 appldev noship $ */

/*================================================================

  PROCEDURE NAME: 	por_purge_req()

==================================================================*/

PROCEDURE purge_req(x_updated_days  IN NUMBER default 1);

end POR_PURGE_SYS_SAVED_REQ;

 

/
