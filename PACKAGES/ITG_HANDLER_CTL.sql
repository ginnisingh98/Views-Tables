--------------------------------------------------------
--  DDL for Package ITG_HANDLER_CTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_HANDLER_CTL" AUTHID CURRENT_USER AS
/* $Header: itghndls.pls 120.3 2005/09/23 18:50:01 ppsriniv noship $ */
-- IPConnector component file.

  /* Was a Handler Management API.
   */

  FUNCTION add_handler RETURN number;

  PROCEDURE update_handler;

  PROCEDURE delete_handler;

  PROCEDURE sync_handler_effectivities;

  PROCEDURE add_org_to_effectivities;

  PROCEDURE remove_org_from_effectivities;

  PROCEDURE update_effectivity;

  PROCEDURE set_effectivity_active;

END itg_handler_ctl;

 

/
