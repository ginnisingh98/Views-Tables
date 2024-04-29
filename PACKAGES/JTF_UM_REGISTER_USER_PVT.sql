--------------------------------------------------------
--  DDL for Package JTF_UM_REGISTER_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_REGISTER_USER_PVT" AUTHID CURRENT_USER as
/* $Header: JTFVUURS.pls 115.5 2002/08/27 21:31:13 ssallaka ship $ */
-- Start of Comments
-- Package name     : JTF_UM_REGISTER_USER_PVT
-- Purpose          :
--   This package contains specification for pl/sql records and tables required
--   by the handlers to register users

TYPE Person_rec_type IS RECORD
(
  first_name      hz_parties.person_first_name%type := null,
  last_name       hz_parties.person_last_name%type := null,
  user_name       fnd_user.user_name%type := null,
  password        varchar2(100) := null,
  phone_area_code hz_contact_points.phone_area_code%type := null,
  phone_number    hz_contact_points.phone_number%type := null,
  email_address   fnd_user.email_address%type := null,
  party_id        hz_parties.party_id%type := null,
  user_id       fnd_user.user_id%type := null,
  start_date_active   date := null,
  privacy_preference varchar2(5) := 'NO'
);

G_MISS_Person_Rec	Person_Rec_Type;

TYPE Organization_rec_type IS RECORD
(
  Organization_number  hz_parties.party_number%type := null,
  Organization_name    hz_parties.party_name%type := null,
  Address1             hz_parties.address1%type := null,
  address2             hz_parties.address2%type := null,
  address3             hz_parties.address3%type := null,
  address4             hz_parties.address3%type := null,
  city                 hz_parties.city%type := null,
  state                hz_parties.state%type := null,
  postal_code          hz_parties.postal_code%type := null,
  county               hz_parties.county%type := null,
  province             hz_parties.province%type := null,
  altaddress           hz_locations.address_lines_phonetic%type := null,
  country              hz_parties.country%type := null,
  phone_area_code      hz_contact_points.phone_area_code%type := null,
  phone_number         hz_contact_points.phone_number%type := null,
  fax_area_code        hz_contact_points.phone_area_code%type := null,
  fax_number      varchar2(40) := null,
  org_party_id         hz_parties.party_id%type := null,
  org_contact_party_id hz_parties.party_id%type := null,
  start_date_active            date := null
  --location_id, party_site_id

);

G_MISS_Organization_Rec	Organization_Rec_Type;

end JTF_UM_REGISTER_USER_PVT;

 

/
