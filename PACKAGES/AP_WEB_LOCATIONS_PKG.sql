--------------------------------------------------------
--  DDL for Package AP_WEB_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_LOCATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: apwelocs.pls 115.1 2003/08/29 16:51:55 kmizuta noship $ */

  --
  -- The following record is used by routines in this package to represent
  -- a location
  type location_rec is record (
    location_id number(15),
    address1 varchar2(80),
    address2 varchar2(80),
    address3 varchar2(80),
    address4 varchar2(80),
    city varchar2(80),
    province_state varchar2(80),
    postal_code varchar2(80),
    country varchar2(80),
    geometry_status_code varchar2(30),
    geometry mdsys.sdo_geometry,
    org_id number(15),
    address_key varchar2(660)
  );

  type loc_array is varray(20) of location_rec;
  type cc_trx_array is varray(20) of ap_credit_card_trxns_all%rowtype;

  --
  -- get_location procedure checks to see if an identical address exists
  -- in the AP_EXP_LOCATIONS table. If it exists, it does nothing.
  -- If it doesn't exist, it will populate AP_EXP_LOCATIONS. It will
  -- also call out to eLocations to populate the spatial coordinates
  -- NOTE: AP_EXP_LOCATIONS will only be populated if
  --       MERCHANT_COUNTRY_CODE is non-null.
  procedure get_location(p_cc_trx in out nocopy ap_credit_card_trxns_all%rowtype,
                         x_return_status in out nocopy varchar2,
                         x_msg_count in out nocopy number,
                         x_msg_data in out nocopy varchar2);
  procedure get_location(p_cc_trx in out nocopy cc_trx_array,
                       x_return_status in out nocopy varchar2,
                       x_msg_count in out nocopy number,
                       x_msg_data in out nocopy varchar2);

  --
  -- Uses various information about the card program to default a country.
  -- This includes....
  --    o Supplier Site
  --    o Currency territories
  --    o Organization
  function default_country(p_card_program_id in number)
  return varchar2;

end;

 

/
