--------------------------------------------------------
--  DDL for Package Body IES_TCA_BP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_TCA_BP_PKG" AS
/* $Header: iestcbpb.pls 120.2 2005/08/05 14:19:38 appldev noship $ */
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
) IS

  l_msg_count         NUMBER  := 0;
  my_message          VARCHAR2(2000);
  l_msg_data          VARCHAR2(4000) default NULL;
begin
	x_msg_count := 1;
	x_return_status := 'F';
	FND_MESSAGE.SET_NAME('IES', 'IES_TCA_API_OBSOLETE');
	l_msg_data := FND_MESSAGE.GET;
	x_msg_data := l_msg_data;
	x_party_id := 0;
	x_party_number := 0;
	x_profile_id := 0;
	return;

end CREATE_ORGANIZATION;

Procedure create_person(
 p_api_version number,
 p_user_name varchar2,
 p_first_name varchar2,
 p_middle_name varchar2 DEFAULT FND_API.G_MISS_CHAR,
 p_last_name varchar2,
 p_title varchar2 DEFAULT FND_API.G_MISS_CHAR,
 p_content_source_type varchar2,
 x_party_id OUT NOCOPY /* file.sql.39 change */ number,
 x_party_number OUT NOCOPY /* file.sql.39 change */ number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_profile_id OUT NOCOPY /* file.sql.39 change */ number
) IS
  l_msg_count         NUMBER  := 0;
  l_msg_data          VARCHAR2(4000) default NULL;
  l_count			  NUMBER := 0;

begin
	x_msg_count := 1;
	x_return_status := 'F';
	FND_MESSAGE.SET_NAME('IES', 'IES_TCA_API_OBSOLETE');
	l_msg_data := FND_MESSAGE.GET;
	x_msg_data := l_msg_data;
	x_party_id := 0;
	x_party_number := 0;
	x_profile_id := 0;
	return;

end CREATE_PERSON;

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
) IS


l_msg_count number;
l_msg_data varchar2(4000);

begin

 	x_msg_count := 1;
	x_return_status := 'F';
	FND_MESSAGE.SET_NAME('IES', 'IES_TCA_API_OBSOLETE');
	l_msg_data := FND_MESSAGE.GET;
	x_msg_data := l_msg_data;
	x_location_id := 0;
	return;

END CREATE_LOCATION;

procedure create_party_site(
p_api_version number,
p_user_name varchar2,
p_party_id number,
p_location_id number,
x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
x_msg_count  OUT NOCOPY /* file.sql.39 change */ number,
x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2,
x_party_site_id OUT NOCOPY /* file.sql.39 change */ number,
x_party_site_number OUT NOCOPY /* file.sql.39 change */ number)
IS

l_msg_count number;
l_msg_data varchar2(4000);

begin

 	x_msg_count := 1;
	x_return_status := 'F';
	FND_MESSAGE.SET_NAME('IES', 'IES_TCA_API_OBSOLETE');
	l_msg_data := FND_MESSAGE.GET;
	x_msg_data := l_msg_data;
	x_party_site_id := 0;
	x_party_site_number := 0;
	return;

END create_party_site;

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
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2) is

l_msg_count number;
l_msg_data varchar2(4000);

begin
 	x_msg_count := 1;
	x_return_status := 'F';
	FND_MESSAGE.SET_NAME('IES', 'IES_TCA_API_OBSOLETE');
	l_msg_data := FND_MESSAGE.GET;
	x_msg_data := l_msg_data;
	x_party_id := 0;
	x_party_rel_id := 0;
	x_party_number := 0;
	x_org_contact_id := 0;
	return;
end create_org_contact;

procedure update_org_contact(
 p_api_version number,
 p_user_name varchar2,
 p_org_contact_id number,
 p_party_site_id number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2) is

l_msg_count number;
l_msg_data varchar2(4000);


begin
 	x_msg_count := 1;
	x_return_status := 'F';
	FND_MESSAGE.SET_NAME('IES', 'IES_TCA_API_OBSOLETE');
	l_msg_data := FND_MESSAGE.GET;
	x_msg_data := l_msg_data;
	return;

end update_org_contact;

procedure update_party_site(
 p_api_version number,
 p_user_name varchar2,
 p_party_site_id number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2) is


l_msg_count number;
l_msg_data varchar2(4000);


begin
	x_msg_count := 1;
	x_return_status := 'F';
	FND_MESSAGE.SET_NAME('IES', 'IES_TCA_API_OBSOLETE');
	l_msg_data := FND_MESSAGE.GET;
	x_msg_data := l_msg_data;
	return;

end update_party_site;

END IES_TCA_BP_PKG;

/
