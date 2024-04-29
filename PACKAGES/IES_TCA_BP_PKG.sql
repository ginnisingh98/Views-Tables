--------------------------------------------------------
--  DDL for Package IES_TCA_BP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_TCA_BP_PKG" AUTHID CURRENT_USER AS
/* $Header: iestcbps.pls 120.1 2005/06/16 11:16:18 appldev  $ */

Procedure create_organization(
 p_api_version number,
 p_user_name varchar2,
 p_org_name varchar2,
 p_content_source_type varchar2,
 x_party_id OUT NOCOPY /* file.sql.39 change */ number,
 x_party_number OUT NOCOPY /* file.sql.39 change */ number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_profile_id OUT NOCOPY /* file.sql.39 change */ number
);


Procedure create_person(
 p_api_version number,
 p_user_name varchar2,
 p_first_name varchar2,
 p_middle_name varchar2 default FND_API.G_MISS_CHAR,
 p_last_name varchar2,
 p_title varchar2 default FND_API.G_MISS_CHAR,
 p_content_source_type varchar2,
 x_party_id OUT NOCOPY /* file.sql.39 change */ number,
 x_party_number OUT NOCOPY /* file.sql.39 change */ number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_profile_id OUT NOCOPY /* file.sql.39 change */ number
);

Procedure create_location (
 p_api_version number,
 p_user_name varchar2,
 p_address1  varchar2,
 p_address2  varchar2 DEFAULT FND_API.G_MISS_CHAR,
 p_address3  varchar2 DEFAULT FND_API.G_MISS_CHAR,
 p_address4  varchar2 DEFAULT FND_API.G_MISS_CHAR,
 p_city      varchar2 DEFAULT FND_API.G_MISS_CHAR,
 p_postal_code      varchar2 DEFAULT FND_API.G_MISS_CHAR,
 p_province      varchar2 DEFAULT FND_API.G_MISS_CHAR,
 p_state      varchar2 DEFAULT FND_API.G_MISS_CHAR,
 p_country   varchar2,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_location_id OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_count  OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2
);

procedure create_party_site(
p_api_version number,
p_user_name varchar2,
p_party_id number,
p_location_id number,
x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
x_msg_count  OUT NOCOPY /* file.sql.39 change */ number,
x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2,
x_party_site_id OUT NOCOPY /* file.sql.39 change */ number,
x_party_site_number OUT NOCOPY /* file.sql.39 change */ number);


Procedure create_org_contact(
 p_api_version number,
 p_user_name varchar2,
 p_org_party_id number,
 p_person_party_id number,
 p_party_relationship_type varchar2,
 p_content_source_type varchar2,
 p_party_site_id number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_org_contact_id OUT NOCOPY /* file.sql.39 change */ number,
 x_party_rel_id OUT NOCOPY /* file.sql.39 change */ number,
 x_party_id OUT NOCOPY /* file.sql.39 change */ number,
 x_party_number OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_count  OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2);


procedure update_org_contact(
 p_api_version number,
 p_user_name varchar2,
 p_org_contact_id number,
 p_party_site_id number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2);

procedure update_party_site(
 p_api_version number,
 p_user_name varchar2,
 p_party_site_id number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2);


END IES_TCA_BP_PKG;

 

/
