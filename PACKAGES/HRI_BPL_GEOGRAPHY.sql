--------------------------------------------------------
--  DDL for Package HRI_BPL_GEOGRAPHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_GEOGRAPHY" AUTHID CURRENT_USER AS
/* $Header: hribgeog.pkh 115.0 2003/01/07 09:41:06 jrstewar noship $ */
g_region_code VARCHAR2(20);

FUNCTION get_region_code (p_location_id in number)
RETURN  VARCHAR2;

END; -- Package spec

 

/
