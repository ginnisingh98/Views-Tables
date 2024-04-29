--------------------------------------------------------
--  DDL for Package HRI_OLTP_VIEW_GEOGRAPHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_VIEW_GEOGRAPHY" AUTHID CURRENT_USER AS
/* $Header: hriovgeo.pkh 120.1 2006/11/01 11:17:22 smohapat noship $ */

FUNCTION get_region_code (p_location_id in number)
RETURN  varchar2;

FUNCTION get_country_name (p_country_code IN VARCHAR2)
RETURN  varchar2;

END; -- Package spec

/
