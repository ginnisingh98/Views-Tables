--------------------------------------------------------
--  DDL for Package CSF_TIMEZONES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_TIMEZONES_PVT" AUTHID CURRENT_USER AS
/*$Header: CSFDCTZS.pls 115.2 2003/09/02 21:15:28 ekerkhov noship $*/

  FUNCTION get_server_tz_code return varchar2;

  FUNCTION get_client_tz_code return varchar2;

  FUNCTION tz_enabled return varchar2;

  FUNCTION date_to_client_tz_chardt
  ( p_dateval in date ) return varchar2;

  FUNCTION date_to_client_tz_chartime
  ( p_dateval in date
  , p_mask    in varchar2 default null ) return varchar2;

  FUNCTION date_to_client_tz_date
  ( p_dateval in date ) return date;

  FUNCTION date_to_server_tz_date
  ( p_dateval in date ) return date;

END csf_timezones_pvt;

 

/
