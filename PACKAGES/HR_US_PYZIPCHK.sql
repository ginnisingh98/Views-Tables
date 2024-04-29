--------------------------------------------------------
--  DDL for Package HR_US_PYZIPCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_US_PYZIPCHK" AUTHID CURRENT_USER AS
/* $Header: pyzipchk.pkh 120.0 2005/05/29 10:37:26 appldev noship $ */
--
--
--
PROCEDURE  inval_per_addr (     p_address_id    in number,
                                p_state_abbrev in varchar2 default null,
                                p_county_name  in varchar2 default null,
                                p_city_name    in varchar2 default null,
                                p_zip_code     in varchar2 default null);

PROCEDURE  inval_hr_addr (p_location_id  in number,
                          p_state_abbrev in varchar2 default null,
                          p_county_name  in varchar2 default null,
                          p_city_name    in varchar2 default null,
                          p_zip_code     in varchar2 default null);
procedure  chkzipcode;

END HR_US_PYZIPCHK;

 

/
