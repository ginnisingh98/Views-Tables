--------------------------------------------------------
--  DDL for Package MRP_MAP_REG_SITE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_MAP_REG_SITE" AUTHID CURRENT_USER AS -- specification
/* $Header: MRPMTRSS.pls 120.1 2005/09/29 15:11 rawasthi noship $ */

FUNCTION MAP_REGION_TO_SITE(p_last_update_date in DATE) RETURN NUMBER;

END MRP_MAP_REG_SITE;

 

/
