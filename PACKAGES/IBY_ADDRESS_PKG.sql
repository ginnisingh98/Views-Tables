--------------------------------------------------------
--  DDL for Package IBY_ADDRESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_ADDRESS_PKG" AUTHID CURRENT_USER as
/*$Header: ibyadrss.pls 115.3 2002/11/16 00:04:51 jleybovi ship $*/
/*
** Name : iby_address_pkg.
** Purpose : This package creates or deletes addresses that are part of
**           credit cards.
*/
/*
** Procedure Name : createAddress
** Purpose : creates an entry in address table..
**           Returns the id created for the entry.
**
** Parameters:
**
**    In  : i_address1, i_address2, i_address3, i_city, i_county,
**          i_state, i_country, i_postalcode.
**    Out : io_addressid.
**
*/
procedure createAddress( i_address1 hz_locations.address1%type,
                      i_address2 hz_locations.address2%type,
                      i_address3 hz_locations.address3%type,
                      i_city hz_locations.city%type,
                      i_county hz_locations.county%type,
                      i_state hz_locations.state%type,
                      i_country hz_locations.country%type,
                      i_postalcode hz_locations.postal_code%type,
                      o_addressid  out nocopy hz_locations.location_id%type);
/*
** Procedure Name : modAddress
** Purpose : modifies an entry in Back end processor information table.
**
** Parameters:
**
**    In  : i_addressid, i_address1, i_address2, i_address3, i_city,
**          i_county, i_state, i_country, i_postalcode.
**    Out : None.
**
*/
procedure    modAddress(i_addressid hz_locations.location_id%type,
                      i_address1 hz_locations.address1%type,
                      i_address2 hz_locations.address2%type,
                      i_address3 hz_locations.address3%type,
                      i_city hz_locations.city%type,
                      i_county hz_locations.county%type,
                      i_state hz_locations.state%type,
                      i_country hz_locations.country%type,
                      i_postalcode hz_locations.postal_code%type);
end iby_address_pkg;

 

/
