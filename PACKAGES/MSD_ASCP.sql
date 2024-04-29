--------------------------------------------------------
--  DDL for Package MSD_ASCP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_ASCP" AUTHID CURRENT_USER AS
/* $Header: msdascps.pls 115.4 2002/05/10 17:01:32 pkm ship      $ */

  function partner_id(p_level_id  VARCHAR2,
		      p_level_pk  VARCHAR2) RETURN NUMBER;

  function partner_site_id(p_level_id  VARCHAR2,
	                   p_level_pk  VARCHAR2) RETURN NUMBER;

END MSD_ASCP;

 

/
