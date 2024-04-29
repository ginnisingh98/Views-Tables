--------------------------------------------------------
--  DDL for Package GMA_MIGRATION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_MIGRATION_UTILS" AUTHID CURRENT_USER AS
/* $Header: GMAUMIGS.pls 120.1 2005/07/19 02:58:24 kshukla noship $ */

  FUNCTION get_reason_id (p_reason_code IN VARCHAR2) RETURN NUMBER;

  FUNCTION get_organization_id (P_orgn_code IN VARCHAR2) RETURN NUMBER;

  FUNCTION get_uom_code (P_um_code IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE GMA_EDIT_TEXT_MIGRATION (  err_buf OUT NOCOPY varchar2
			             ,   ret_code OUT NOCOPY number
			             ,   migration_var IN varchar2
                                     );
END gma_migration_utils;

 

/
