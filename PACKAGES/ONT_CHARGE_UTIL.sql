--------------------------------------------------------
--  DDL for Package ONT_CHARGE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_CHARGE_UTIL" AUTHID CURRENT_USER AS
/* $Header: ONTUCHRS.pls 120.0 2005/06/01 00:25:47 appldev noship $ */

-- Procedure to get charge totals at Order Line or Order Header level
-- If the header_id is passed and line_id is NULL then total for charges at
-- Order Header level is returned
-- If header_id and line_id is passed then total for charges at Order line
-- level is returned.

 Function Get_Meaning
 (   p_charge_type_code in VARCHAR2
 ,   p_charge_subtype_code in VARCHAR2 := NULL
 ) RETURN VARCHAR2;

END ONT_CHARGE_UTIL;

 

/
