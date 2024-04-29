--------------------------------------------------------
--  DDL for Package Body RRS_SITE_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_SITE_INFO" as
/* $Header: RRSGSDTB.pls 120.0.12010000.15 2009/09/17 22:47:27 sunarang noship $ */


Procedure Get_complete_site_details(
 p_site_id_num 			IN 		varchar2
,p_site_name   			IN 		varchar2 Default null
,p_page_name			IN 		varchar2 Default null
,x_site_header_tab              OUT NOCOPY      rrs_site_header_tab
,x_site_address_tab             OUT NOCOPY      rrs_site_address_tab
,x_site_uses_tab                OUT NOCOPY      rrs_site_uses_tab
,x_party_site_address_tab       OUT NOCOPY      rrs_site_address_tab
,x_property_tab			OUT NOCOPY	rrs_property_tab
,x_site_cluster_tab             OUT NOCOPY      rrs_site_cluster_tab
,x_site_hierar_tab              OUT NOCOPY      rrs_site_hierar_tab
,x_trade_area_grp_tab           OUT NOCOPY      rrs_trade_area_grp_tab
,x_relationship_tab             OUT NOCOPY      rrs_relationship_tab
,x_site_phone_tab               OUT NOCOPY      rrs_site_phone_tab
,x_site_email_tab               OUT NOCOPY      rrs_site_email_tab
,x_site_url_tab                 OUT NOCOPY      rrs_site_url_tab
,x_site_person_tab              OUT NOCOPY      rrs_site_person_tab
,x_site_attachment_tab          OUT NOCOPY      rrs_site_attachment_tab
,x_site_asset_tab               OUT NOCOPY      rrs_site_asset_tab
,x_site_attrib_row_table        OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_site_attrib_data_table       OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
,x_loc_attrib_row_table         OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_loc_attrib_data_table        OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
,x_tr_area_attrib_row_table     OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_tr_area_attrib_data_table    OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
) is
/*
x_site_header_tab rrs_site_header_tab;
x_site_address_tab rrs_site_address_tab;
x_site_uses_tab rrs_site_uses_tab;
*/

begin

Get_site_details(
		p_site_id_num => p_site_id_num
        	,p_site_name => p_site_name
        	,x_site_header_tab => x_site_header_tab
        	,x_site_address_tab => x_site_address_tab
        	,x_site_uses_tab => x_site_uses_tab
		);


Get_site_attributes(
        p_site_id_num => p_site_id_num
        ,p_site_name => p_site_name
        ,p_page_name => p_page_name
        ,x_site_attrib_data_table => x_site_attrib_data_table
        ,x_site_attrib_row_table => x_site_attrib_row_table
        );

Get_location_attributes(
        p_site_id_num => p_site_id_num
        ,p_site_name => p_site_name
        ,p_page_name => p_page_name
        ,x_loc_attrib_data_table => x_loc_attrib_data_table
        ,x_loc_attrib_row_table => x_loc_attrib_row_table
        );

Get_trade_area_attributes(
        p_site_id_num => p_site_id_num
        ,p_site_name => p_site_name
        ,p_page_name => p_page_name
        ,x_tr_area_attrib_data_table => x_tr_area_attrib_data_table
        ,x_tr_area_attrib_row_table => x_tr_area_attrib_row_table
        );


Get_site_associations(
        p_site_id_num => p_site_id_num
        ,p_site_name => p_site_name
        ,x_property_tab => x_property_tab
        ,x_site_cluster_tab => x_site_cluster_tab
        ,x_site_hierar_tab => x_site_hierar_tab
        ,x_trade_area_grp_tab => x_trade_area_grp_tab
        ,x_relationship_tab => x_relationship_tab
        );

-- if x_site_header_tab(1).le_party_site_id is NOT NULL  then

Get_site_contacts(
        p_site_id_num => p_site_id_num
        ,p_site_name => p_site_name
 	,x_party_site_address_tab => x_party_site_address_tab
        ,x_site_phone_tab => x_site_phone_tab
        ,x_site_email_tab => x_site_email_tab
        ,x_site_url_tab => x_site_url_tab
        ,x_site_person_tab => x_site_person_tab
        );

 -- end if;

Get_site_attachments(
        p_site_id_num => p_site_id_num
        ,p_site_name => p_site_name
        ,x_site_attachment_tab => x_site_attachment_tab
        );


 rrs_site_info.get_site_assets(
        p_site_id_num => p_site_id_num
        ,p_site_name => p_site_name
        ,x_site_asset_tab => x_site_asset_tab
        );



 end;


Procedure Get_site_details(
 p_site_id_num 			IN		varchar2
,p_site_name   			IN		varchar2 Default null
,x_site_header_tab  		OUT NOCOPY 	rrs_site_header_tab
,x_site_address_tab  		OUT NOCOPY 	rrs_site_address_tab
,x_site_uses_tab  		OUT NOCOPY 	rrs_site_uses_tab
) is

l_site_id			number;
l_site_id_num			varchar2(30);
l_site_type_code		Varchar2(30);
l_site_status			varchar2(30);
l_site_brand_name		varchar2(30);
l_site_calendar_code		varchar2(30);
l_location_id			number;
l_site_party_id 		number;
l_party_site_id			number;
l_le_party_id			number;
l_property_location_id		number;
l_start_date			date;
l_end_date			date;
l_site_name			varchar2(150);


l_address1			varchar2(240);
l_address2			varchar2(240);
l_address3			varchar2(240);
l_address4			varchar2(240);
l_city				varchar2(60);
l_state				varchar2(60);
l_postal_code			varchar2(60);
l_country			varchar2(60);

l_complete_address		varchar2(1000);


TYPE local_rrs_site_header_rec is RECORD (
site_id rrs_sites_b.site_id%TYPE,
site_identification_number rrs_sites_b.site_identification_number%TYPE,
site_type_code rrs_sites_b.site_type_code%TYPE,
site_type_code_meaning rrs_lookups_v.meaning%TYPE,
site_status_code rrs_sites_b.site_status_code%TYPE,
site_status_code_meaning rrs_lookups_v.meaning%TYPE,
brandname_code rrs_sites_b.brandname_code%TYPE,
brandname_code_meaning rrs_lookups_v.meaning%TYPE,
calendar_code rrs_sites_b.calendar_code%TYPE,
description bom_calendars.description%Type,
location_id rrs_sites_b.location_id%TYPE,
site_party_id rrs_sites_b.site_party_id%TYPE,
party_site_id rrs_sites_b.party_site_id%TYPE,
le_party_site_id rrs_sites_b.le_party_id%TYPE,
party_name hz_parties.party_name%Type,
property_location_id rrs_sites_b.property_location_id%TYPE,
start_date rrs_sites_b.start_date%TYPE,
end_date rrs_sites_b.end_date%TYPE,
name rrs_sites_tl.name%TYPE
);

TYPE local_rrs_site_header_tab IS TABLE OF local_rrs_site_header_rec;
l_site_header_details local_rrs_site_header_tab;

TYPE local_rrs_site_address_rec is RECORD (
address1 hz_locations.address1%TYPE,
address2 hz_locations.address2%TYPE,
address3 hz_locations.address3%TYPE,
address4 hz_locations.address4%TYPE,
city hz_locations.city%TYPE,
county hz_locations.county%TYPE,
state hz_locations.state%TYPE,
province hz_locations.province%TYPE,
postal_code hz_locations.postal_code%TYPE,
country hz_locations.country%TYPE,
country_name fnd_territories_vl.territory_short_name%Type,
address varchar2(1000),
identifying_address_flag hz_party_sites.identifying_address_flag%Type,
geometry_source hz_locations.geometry_source%Type,
geometry_source_meaning rrs_lookups_v.meaning%Type,
longitude number,
latitude  number
);
TYPE local_rrs_site_address_tab IS TABLE OF local_rrs_site_address_rec;
l_site_address_details local_rrs_site_address_tab;

TYPE local_rrs_site_use_rec is RECORD (
site_id rrs_site_uses.site_id%TYPE,
site_use_id rrs_site_uses.site_use_id%TYPE,
site_use_type_code rrs_site_uses.site_use_type_code%TYPE,
site_use_type_code_meaning ar_lookups.meaning%Type,
status_code rrs_site_uses.status_code%TYPE,
status_code_meaning rrs_lookups_v.meaning%TYPE,
is_primary_flag rrs_site_uses.is_primary_flag%TYPE
-- is_primary_flag_meaning rrs_lookups_v.meaning%Type
);
TYPE local_rrs_site_uses_tab IS TABLE OF local_rrs_site_use_rec;
site_use_rec_details local_rrs_site_uses_tab;

l_site_use_id			number;
l_site_use_type_code		varchar2(30);
l_status_code			varchar2(30);
l_is_primary_flag		varchar2(1);
l_is_primary_flag_selector	varchar2(1);
l_party_site_use_id		number;
l_object_version_number		number;

l_site_type_code_meaning 	rrs_lookups_v.meaning%TYPE;

l_lookup_code			rrs_lookups_v.lookup_code%Type;
l_lookup_type			rrs_lookups_v.lookup_type%Type;

Begin

Begin
Select 	RSB.SITE_ID,
	RSB.SITE_IDENTIFICATION_NUMBER,
	RSB.SITE_TYPE_CODE,
	LKUP1.MEANING AS SITE_TYPE_CODE_MEANING,
	RSB.SITE_STATUS_CODE,
	LKUP2.MEANING AS SITE_STATUS_CODE_MEANING,
	RSB.BRANDNAME_CODE ,
	LKUP3.MEANING AS BRANDNAME_CODE_MEANING,
	RSB.CALENDAR_CODE,
	BC.DESCRIPTION,
	RSB.LOCATION_ID,
	RSB.SITE_PARTY_ID,
	RSB.PARTY_SITE_ID,
	RSB.LE_PARTY_ID,
	HP.PARTY_NAME,
	RSB.PROPERTY_LOCATION_ID,
	RSB.START_DATE,
	RSB.END_DATE,
	RST.NAME
Bulk Collect
INTO 	l_site_header_details
From 	RRS_SITES_B RSB, RRS_SITES_TL RST , rrs_lookups_v lkup1,rrs_lookups_v lkup2
	,rrs_lookups_v lkup3 , BOM_CALENDARS BC, HZ_PARTIES HP
WHERE 	RSB.SITE_IDENTIFICATION_NUMBER = p_site_id_num
and 	RSB.SITE_ID = RST.SITE_ID
and	LKUP1.LOOKUP_TYPE = 'RRS_SITE_TYPE'
and 	LKUP1.LOOKUP_CODE = RSB.SITE_TYPE_CODE
and	LKUP2.LOOKUP_TYPE = 'RRS_SITE_STATUS'
and 	LKUP2.LOOKUP_CODE = RSB.SITE_STATUS_CODE
and	LKUP3.LOOKUP_TYPE (+) = 'RRS_BRAND_NAME'
and 	LKUP3.LOOKUP_CODE (+) = RSB.BRANDNAME_CODE
and 	BC.CALENDAR_CODE (+) = RSB.CALENDAR_CODE
and	DECODE(RSB.SITE_TYPE_CODE,'I',RSB.LE_PARTY_ID,'E',RSB.SITE_PARTY_ID) = HP.PARTY_ID(+)
and 	RST.LANGUAGE = userenv('LANG');
Exception
     When NO_DATA_FOUND Then
	raise_application_error(-20101, ' Check the Site ID please');

end;

x_site_header_tab := rrs_site_header_tab();
x_site_header_tab.Extend();
x_site_header_tab(1) := rrs_site_header_rec(l_site_header_details(1).site_id
						,l_site_header_details(1).site_identification_number
						,l_site_header_details(1).site_type_code
						,l_site_header_details(1).site_type_code_meaning
						,l_site_header_details(1).site_status_code
						,l_site_header_details(1).site_status_code_meaning
						,l_site_header_details(1).brandname_code
						,l_site_header_details(1).brandname_code_meaning
						,l_site_header_details(1).calendar_code
						,l_site_header_details(1).description
						,l_site_header_details(1).location_id
						,l_site_header_details(1).site_party_id
						,l_site_header_details(1).party_site_id
						,l_site_header_details(1).le_party_site_id
						,l_site_header_details(1).party_name
						,l_site_header_details(1).property_location_id
						,l_site_header_details(1).start_date
						,l_site_header_details(1).end_date
						,l_site_header_details(1).name
						);




l_site_id := l_site_header_details(1).site_id;
l_location_id := l_site_header_details(1).location_id;


/*
Commenting this piece to trouble shoot later why Country does not Show up.
SELECT 	ADDRESS1,
	ADDRESS2,
	ADDRESS3,
	ADDRESS4,
	NLS_UPPER(CITY) CITY,
	NLS_UPPER(COUNTY) COUNTY,
  	NLS_UPPER(STATE) STATE,
  	NLS_UPPER(PROVINCE) PROVINCE,
	NLS_UPPER(POSTAL_CODE) POSTAL_CODE,
  	NLS_UPPER(hz_format_pub.get_tl_territory_name(COUNTRY)) COUNTRY,
	FTV.TERRITORY_SHORT_NAME COUNTRY_NAME,
	HZ_FORMAT_PUB.format_address(location_id, null, null, ',' , null) as Address,
	'Y' as IDENTIFYING_ADDRESS_FLAG
Bulk Collect
INTO	l_site_address_details
FROM 	HZ_LOCATIONS
	,FND_TERRITORIES_VL FTV
WHERE 	COUNTRY = FTV.TERRITORY_CODE
AND 	LOCATION_ID = l_location_id;
*/

SELECT 	ADDRESS1,
	ADDRESS2,
	ADDRESS3,
	ADDRESS4,
	NLS_UPPER(CITY) CITY,
	NLS_UPPER(COUNTY) COUNTY,
  	NLS_UPPER(STATE) STATE,
  	NLS_UPPER(PROVINCE) PROVINCE,
	NLS_UPPER(POSTAL_CODE) POSTAL_CODE,
  	COUNTRY,
	FTV.TERRITORY_SHORT_NAME COUNTRY_NAME,
	HZ_FORMAT_PUB.format_address(location_id, null, null, ',' , null) as Address,
	'Y' as IDENTIFYING_ADDRESS_FLAG ,
	GEOMETRY_SOURCE,
	( SELECT rlv.meaning FROM RRS_LOOKUPS_V rlv WHERE rlv.lookup_type = 'RRS_GEO_SOURCE'
    		AND rlv.lookup_code = HL.GEOMETRY_SOURCE ) GEOMETRY_SOURCE_MEANING,
	ROUND(HL.geometry.SDO_POINT.X,8) Longitude,
	ROUND(HL.geometry.SDO_POINT.Y,8) Latitude
Bulk Collect
INTO	l_site_address_details
FROM 	HZ_LOCATIONS  HL
	,FND_TERRITORIES_VL FTV
WHERE 	HL.COUNTRY = FTV.TERRITORY_CODE
AND 	HL.LOCATION_ID = l_location_id;


x_site_address_tab := rrs_site_address_tab();
if l_site_address_details.count > 0 then
FOR  i in l_site_address_details.First..l_site_address_details.Last LOOP
x_site_address_tab.Extend();
x_site_address_tab(i) := rrs_site_address_rec(l_site_address_details(i).address1
						,l_site_address_details(i).address2
						,l_site_address_details(i).address3
						,l_site_address_details(i).address4
						,l_site_address_details(i).city
						,l_site_address_details(i).county
						,l_site_address_details(i).state
						,l_site_address_details(i).province
						,l_site_address_details(i).postal_code
						,l_site_address_details(i).country
						,l_site_address_details(i).country_name
						,l_site_address_details(i).address
						,l_site_address_details(i).identifying_address_flag
						,NULL --Bug 7871825
						,l_site_address_details(i).geometry_source
						,l_site_address_details(i).geometry_source_meaning
						,l_site_address_details(i).longitude
						,l_site_address_details(i).latitude
						);
END LOOP;
END IF;

SELECT 	SiteUseEO.SITE_ID,
 	SiteUseEO.SITE_USE_ID,
       	SiteUseEO.SITE_USE_TYPE_CODE,
	LKUP1.MEANING AS SITE_USE_TYPE_CODE_MEANING,
       	SiteUseEO.STATUS_CODE,
        LKUP3.MEANING AS STATUS_CODE_MEANING,
       	SiteUseEO.IS_PRIMARY_FLAG
	--,LKUP2.MEANING AS IS_PRIMARY_FLAG_MEANING
BULK COLLECT
INTO	site_use_rec_details
FROM 	RRS_SITE_USES SiteUseEO,
     	RRS_SITES_B  RSB,
     	HZ_PARTY_SITE_USES HPSU,
	AR_LOOKUPS LKUP1
--	,RRS_LOOKUPS_V LKUP2
	,RRS_LOOKUPS_V LKUP3
WHERE 	RSB.SITE_ID = SiteUseEO.SITE_ID
AND 	HPSU.PARTY_SITE_ID(+)= RSB.PARTY_SITE_ID
AND 	DECODE(HPSU.PARTY_SITE_ID,null,'-999',SiteUseEO.SITE_USE_TYPE_CODE) = nvl(HPSU.SITE_USE_TYPE,'-999')
and	LKUP1.LOOKUP_TYPE = 'PARTY_SITE_USE_CODE'
and 	LKUP1.LOOKUP_CODE = SiteUseEO.SITE_USE_TYPE_CODE
--and	LKUP2.LOOKUP_TYPE = 'RRS_YES_NO'
--and 	LKUP2.LOOKUP_CODE = SiteUseEO.IS_PRIMARY_FLAG
and     LKUP3.LOOKUP_TYPE = 'RRS_SITE_STATUS'
and     LKUP3.LOOKUP_CODE = SiteUseEO.STATUS_CODE
AND 	RSB.SITE_ID = l_site_id ;


x_site_uses_tab := rrs_site_uses_tab();
if site_use_rec_details.count > 0 then
FOR  i in site_use_rec_details.First..site_use_rec_details.Last LOOP
x_site_uses_tab.Extend();
x_site_uses_tab(i) := rrs_site_uses_rec(site_use_rec_details(i).site_id
						,site_use_rec_details(i).site_use_id
						,site_use_rec_details(i).site_use_type_code
						,site_use_rec_details(i).site_use_type_code_meaning
						,site_use_rec_details(i).status_code
						,site_use_rec_details(i).status_code_meaning
						,site_use_rec_details(i).is_primary_flag
						);
END LOOP;
END IF;





/*
dbms_output.put_line('Printing Basic Site Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Site ID : '||chr(9)||chr(9)||chr(9)||x_site_header_tab(1).site_id);
dbms_output.put_line('Site Identification Number : '||chr(9)||x_site_header_tab(1).site_identification_number);
dbms_output.put_line('Site Type Code : '||chr(9)||chr(9)||x_site_header_tab(1).site_type_code||' ( '||x_site_header_tab(1).site_type_code_meaning||' )');
dbms_output.put_line('Site Status Code : '||chr(9)||chr(9)||x_site_header_tab(1).site_status_code||' ( '||x_site_header_tab(1).site_status_code_meaning||' )');
dbms_output.put_line('Brand Name : '||chr(9)||chr(9)||chr(9)||x_site_header_tab(1).brandname_code||' ( '||x_site_header_tab(1).brandname_code_meaning||' )');
dbms_output.put_line('Calendar Code : '||chr(9)||chr(9)||x_site_header_tab(1).calendar_code||' ( '||x_site_header_tab(1).description||' )');
dbms_output.put_line('Location ID : '||chr(9)||chr(9)||chr(9)||x_site_header_tab(1).location_id);
dbms_output.put_line('Party Site ID : '||chr(9)||chr(9)||x_site_header_tab(1).party_site_id);

if x_site_header_tab(1).site_type_code = 'I' then
dbms_output.put_line('Legal Entity Party ID : '||chr(9)||x_site_header_tab(1).le_party_site_id||' ( '||x_site_header_tab(1).party_name||' )');
elsif x_site_header_tab(1).site_type_code = 'E' then
dbms_output.put_line('Site Party ID : '||chr(9)||chr(9)||x_site_header_tab(1).site_party_id||' ( '||x_site_header_tab(1).party_name||' )');
end if;

dbms_output.put_line('Property Location ID : '||chr(9)||x_site_header_tab(1).property_location_id);
dbms_output.put_line('Start Date of Site : '||chr(9)||x_site_header_tab(1).start_date);
dbms_output.put_line('End Date of Site : '||chr(9)||x_site_header_tab(1).end_date);
dbms_output.put_line('Name of Site : '||chr(9)||chr(9)||chr(9)||x_site_header_tab(1).name);
dbms_output.put_line('Address1  of Site : '||chr(9)||chr(9)||x_site_address_tab(1).address1);
dbms_output.put_line('Address2  of Site : '||chr(9)||chr(9)||x_site_address_tab(1).address2);
dbms_output.put_line('Address3  of Site : '||chr(9)||chr(9)||x_site_address_tab(1).address3);
dbms_output.put_line('Address4  of Site : '||chr(9)||chr(9)||x_site_address_tab(1).address4);
dbms_output.put_line('City  of Site : '||chr(9)||chr(9)||x_site_address_tab(1).city);
dbms_output.put_line('County  of Site : '||chr(9)||chr(9)||x_site_address_tab(1).county);
dbms_output.put_line('State  of Site : '||chr(9)||chr(9)||x_site_address_tab(1).state);
dbms_output.put_line('Province  of Site : '||chr(9)||chr(9)||x_site_address_tab(1).province);
dbms_output.put_line('Postal Code  of Site : '||chr(9)||chr(9)||x_site_address_tab(1).postal_code);
dbms_output.put_line('Country  of Site : '||chr(9)||chr(9)||x_site_address_tab(1).country);
dbms_output.put_line('Complete Address  of Site : '||chr(9)||x_site_address_tab(1).address);
dbms_output.put_line(chr(13) || chr(10));

if site_use_rec_details.count > 0 then
FOR  i in site_use_rec_details.First..site_use_rec_details.Last LOOP
dbms_output.put_line('Site Purpose : '||chr(9)||chr(9)||chr(9)||x_site_uses_tab(i).site_use_type_code||' ( '||x_site_uses_tab(i).site_use_type_code_meaning||' )');
-- dbms_output.put_line('Site Purpose Meaning: '||chr(9)||chr(9)||x_site_uses_tab(i).site_use_type_code_meaning);
dbms_output.put_line('Is this a Primary Site : '||chr(9)||x_site_uses_tab(i).is_primary_flag);
-- dbms_output.put_line('Is this a Primary Site Meaning : '||chr(9)||x_site_uses_tab(i).is_primary_flag_meaning);
dbms_output.put_line('Status of Site Purpose : '||chr(9)||x_site_uses_tab(i).status_code||' ( '||x_site_uses_tab(i).status_code_meaning||' )');
-- dbms_output.put_line('Status of Site Purpose Meaning : '||x_site_uses_tab(i).status_code_meaning);
END LOOP;
end if;

dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Done Printing Basic Site Details  ');
dbms_output.put_line('=================================  ');
*/

end;


Procedure Get_site_complete_attributes(
 p_site_id_num                  IN              varchar2
,p_site_name                    IN              varchar2 Default null
,x_site_attrib_row_table        OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_site_attrib_data_table       OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
,x_loc_attrib_row_table         OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_loc_attrib_data_table        OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
,x_tr_area_attrib_row_table     OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_tr_area_attrib_data_table    OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
) is

p_page_name		varchar2(240);

begin

Get_site_attributes(
        p_site_id_num => p_site_id_num
        ,p_site_name => p_site_name
        ,p_page_name => p_page_name
        ,x_site_attrib_data_table => x_site_attrib_data_table
        ,x_site_attrib_row_table => x_site_attrib_row_table
        );

Get_location_attributes(
        p_site_id_num => p_site_id_num
        ,p_site_name => p_site_name
        ,p_page_name => p_page_name
        ,x_loc_attrib_data_table => x_loc_attrib_data_table
        ,x_loc_attrib_row_table => x_loc_attrib_row_table
        );

Get_trade_area_attributes(
        p_site_id_num => p_site_id_num
        ,p_site_name => p_site_name
        ,p_page_name => p_page_name
        ,x_tr_area_attrib_data_table => x_tr_area_attrib_data_table
        ,x_tr_area_attrib_row_table => x_tr_area_attrib_row_table
        );


end;

Procedure Get_site_attributes(
 p_site_id_num 			IN 		varchar2
,p_site_name   			IN 		varchar2 Default null
,p_page_name 			IN 		varchar2 Default null
,x_site_attrib_row_table   	OUT NOCOPY	EGO_USER_ATTR_ROW_TABLE
,x_site_attrib_data_table  	OUT NOCOPY	EGO_USER_ATTR_DATA_TABLE
) is



l_api_name               	CONSTANT VARCHAR2(30) := 'Get_User_Attrs_For_Item';

l_request_table          	EGO_ATTR_GROUP_REQUEST_TABLE;
l_current_data_obj       	EGO_USER_ATTR_DATA_OBJ;
l_pk_column_values       	EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_user_privileges_on_object 	EGO_VARCHAR_TBL_TYPE;
l_site_id			NUMBER;
l_location_id			NUMBER;

x_attributes_row_table   	EGO_USER_ATTR_ROW_TABLE;
x_attributes_data_table  	EGO_USER_ATTR_DATA_TABLE;
-- x_site_attrib_row_table   	EGO_USER_ATTR_ROW_TABLE;
-- x_site_attrib_data_table  	EGO_USER_ATTR_DATA_TABLE;

x_return_status          	VARCHAR2(1);
x_errorcode              	NUMBER;
x_msg_count              	NUMBER;
x_msg_data               	VARCHAR2(1000);
p_site_id 		 	NUMBER;
l_attributes_data_index  	NUMBER;
l_object_name			varchar2(20);
l_attr_group_type		varchar2(30);
l_data_level_name		varchar2(30);
l_page_id 			number;
l_display_name			varchar2(240);

-- l_attributes_row_table  	x_attributes_row_table;
/*Type site_entity_rec is Record(
attr_grp_id ego_obj_ag_assocs_b.attr_grp_id%Type
);
Type  site_entity_tab is table of site_entity_rec;
l_entity_details site_entity_tab;
*/

Type attr_grp_name  is table of varchar2(30);
l_attr_grp_name  attr_grp_name;

Type trade_area_id  is table of number;
l_trade_area_ids  trade_area_id;

Type rrs_entity_rec is Record(
lookup_code rrs_lookups_v.lookup_code%Type,
meaning rrs_lookups_v.meaning%Type
);
Type  rrs_entity_tab is table of rrs_entity_rec;
l_rrs_entity rrs_entity_tab;

l_rrs_entity_name  rrs_lookups_v.meaning%Type;


  BEGIN

    -----------------------
    -- Get PKs organized --
    -----------------------
begin
Select RSB.SITE_ID
	,RSB.LOCATION_ID
INTO 	l_site_id
	,l_location_id
FROM 	RRS_SITES_B RSB
WHERE 	RSB.SITE_IDENTIFICATION_NUMBER = p_site_id_num;
Exception
     When NO_DATA_FOUND Then
        raise_application_error(-20101, ' Check the Site ID please');

end;

Select  meaning
INTO    l_rrs_entity_name
from    RRS_LOOKUPS_V
where   LOOKUP_TYPE= 'RRS_ENTITY'
and 	LOOKUP_CODE = 'RRS_SITE';


IF (p_page_name is Null) Then

    SELECT  ext.DESCRIPTIVE_FLEX_CONTEXT_CODE
    BULK COLLECT
      INTO l_attr_grp_name
      FROM ego_obj_ag_assocs_b eoab
           ,fnd_objects fo
	   ,EGO_FND_DSC_FLX_CTX_EXT ext
     WHERE eoab.object_id = fo.object_id
       AND fo.obj_name in ( 'RRS_SITE')
	 AND eoab.attr_group_id = ext.attr_group_id
       AND eoab.classification_code IN
           (
                SELECT SITE_USE_TYPE_CODE
                FROM     RRS_SITE_USES
                WHERE   SITE_ID = l_site_id
           );


/*

    SELECT eoab.attr_group_id
	BULK COLLECT
      INTO l_attr_grp_id
      FROM ego_obj_ag_assocs_b eoab
           ,fnd_objects fo
     WHERE eoab.object_id = fo.object_id
       AND fo.obj_name in ( 'RRS_SITE')
       AND eoab.classification_code IN
           (
		SELECT SITE_USE_TYPE_CODE
		FROM	 RRS_SITE_USES
		WHERE 	SITE_ID = l_site_id
           );
*/

elsif (p_page_name is not null) then

Begin

	SELECT 	PAGE_ID,
		DISPLAY_NAME
	INTO 	l_page_id,
		l_display_name
	FROM 	EGO_PAGES_V
	WHERE 	OBJECT_NAME='RRS_SITE'
	AND 	DISPLAY_NAME = p_page_name
	AND 	CLASSIFICATION_CODE IN
           	(
			SELECT SITE_USE_TYPE_CODE
			FROM	 RRS_SITE_USES
			WHERE 	SITE_ID = l_site_id
           	)
	ORDER BY SEQUENCE;
Exception
     When NO_DATA_FOUND Then
        raise_application_error(-20102, ' Page Information does not exist');



End;


	SELECT 	ATTR_GROUP_NAME
	BULK COLLECT
	INTO 	l_attr_grp_name
	FROM 	EGO_PAGE_ENTRIES_V
	WHERE 	PAGE_ID=l_page_id
	ORDER BY SEQUENCE;



end if;


    l_pk_column_values :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY(
        EGO_COL_NAME_VALUE_PAIR_OBJ('SITE_ID', TO_CHAR(l_site_id)));

l_object_name := 'RRS_SITE';
-- l_object_name := l_rrs_entity(k).lookup_code;
l_attr_group_type := 'RRS_SITEMGMT_GROUP';
l_data_level_name := 'SITE_LEVEL';


if l_attr_grp_name.count > 0 Then
 x_site_attrib_row_table :=  EGO_USER_ATTR_ROW_TABLE();
 x_site_attrib_data_table :=  EGO_USER_ATTR_DATA_TABLE();

for i in l_attr_grp_name.First..l_attr_grp_name.Last Loop

 l_request_table := EGO_ATTR_GROUP_REQUEST_TABLE();
 l_request_table.EXTEND();
 l_request_table(l_request_table.LAST) := EGO_ATTR_GROUP_REQUEST_OBJ(
                                               NULL 			--ATTR_GROUP_ID
                                              ,718       		--APPLICATION_ID
                                              ,l_attr_group_type 	--ATTR_GROUP_TYPE
                                              ,l_attr_grp_name(i)  			--ATTR_GROUP_NAME
                                              ,l_data_level_name  	--DATA_LEVEL
                                              ,NULL      		--DATA_LEVEL_1
                                              ,NULL      		--DATA_LEVEL_2
                                              ,NULL      		--DATA_LEVEL_3
                                              ,NULL      		--DATA_LEVEL_4
                                              ,NULL      		--DATA_LEVEL_5
                                              ,NULL      		--ATTR_NAME_LIST
                                             );

              EGO_USER_ATTRS_DATA_PUB.Get_User_Attrs_Data(
                p_api_version                => 1.0
               ,p_object_name                => l_object_name
               ,p_pk_column_name_value_pairs => l_pk_column_values
               ,p_attr_group_request_table   => l_request_table
               ,p_user_privileges_on_object  => NULL
               ,p_entity_id                  => NULL
               ,p_entity_index               => NULL
               ,p_entity_code                => NULL
               ,p_debug_level                => 0
               ,p_init_error_handler         => FND_API.G_FALSE
               ,p_init_fnd_msg_list          => FND_API.G_FALSE
               ,p_add_errors_to_fnd_stack    => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,x_attributes_row_table       => x_attributes_row_table
               ,x_attributes_data_table      => x_attributes_data_table
               ,x_return_status              => x_return_status
               ,x_errorcode                  => x_errorcode
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
              );


IF (x_attributes_row_table IS NOT NULL AND x_attributes_row_table.COUNT > 0 AND
    x_attributes_data_table IS NOT NULL AND x_attributes_data_table.COUNT > 0) THEN


	For n in x_attributes_row_table.First..x_attributes_row_table.Last Loop

		x_site_attrib_row_table.Extend();
		-- z_count := x_site_attrib_row_table.count;
		x_site_attrib_row_table(x_site_attrib_row_table.Last) := x_attributes_row_table(n);

	End Loop;


	For n in x_attributes_data_table.First..x_attributes_data_table.Last Loop

		x_site_attrib_data_table.Extend();
		-- z_count := x_site_attrib_data_table.count;
		x_site_attrib_data_table(x_site_attrib_data_table.Last) := x_attributes_data_table(n);

	End Loop;


End if;


END LOOP;

End if;

/*
      IF (x_attributes_row_table IS NOT NULL AND
          x_attributes_row_table.COUNT > 0 AND
          x_attributes_data_table IS NOT NULL AND
          x_attributes_data_table.COUNT > 0
	  AND l_rrs_entity (k).meaning <> 'Trade Area') THEN

        l_attributes_data_index := x_attributes_data_table.FIRST;
        WHILE l_attributes_data_index <= x_attributes_data_table.LAST
        LOOP

            l_current_data_obj := x_attributes_data_table(l_attributes_data_index);

                dbms_output.put_line('Attribute Name is : ' ||chr(9)||chr(9)|| (l_current_data_obj.ATTR_NAME));
                dbms_output.put_line('String Attribute Value: ' ||chr(9)|| (l_current_data_obj.ATTR_VALUE_STR));
                dbms_output.put_line('Number Attribute Value : ' ||chr(9)|| (l_current_data_obj.ATTR_VALUE_NUM));
                dbms_output.put_line('Date Attribute Value : ' ||chr(9)|| (l_current_data_obj.ATTR_VALUE_DATE));
                dbms_output.put_line('Display Value of Attribute : ' ||chr(9)|| (l_current_data_obj.ATTR_DISP_VALUE));
                dbms_output.put_line('UOM for Attribute : ' ||chr(9)|| (l_current_data_obj.ATTR_UNIT_OF_MEASURE));
		dbms_output.put_line(chr(13) || chr(10));

          l_attributes_data_index := x_attributes_data_table.NEXT(l_attributes_data_index);
        END LOOP;

      END IF;

dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Done Printing ( UDA ) Attribute  Details for Entity : '||l_rrs_entity (k).meaning);
dbms_output.put_line('=============================================================  ');
*/

END;


Procedure Get_location_attributes(
 p_site_id_num                  IN              varchar2
,p_site_name                    IN              varchar2 Default null
,p_page_name                    IN              varchar2 Default null
,x_loc_attrib_row_table        	OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_loc_attrib_data_table       	OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
) is



l_api_name               	CONSTANT VARCHAR2(30) := 'Get_User_Attrs_For_Item';

l_request_table          	EGO_ATTR_GROUP_REQUEST_TABLE;
l_current_data_obj       	EGO_USER_ATTR_DATA_OBJ;
l_pk_column_values       	EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_user_privileges_on_object 	EGO_VARCHAR_TBL_TYPE;
l_site_id			NUMBER;
l_location_id			NUMBER;

x_attributes_row_table   	EGO_USER_ATTR_ROW_TABLE;
x_attributes_data_table  	EGO_USER_ATTR_DATA_TABLE;
x_return_status          	VARCHAR2(1);
x_errorcode              	NUMBER;
x_msg_count              	NUMBER;
x_msg_data               	VARCHAR2(1000);
p_site_id 		 	NUMBER;
l_attributes_data_index  	NUMBER;
l_object_name			varchar2(20);
l_attr_group_type		varchar2(30);
l_data_level_name		varchar2(30);

-- l_attributes_row_table  	x_attributes_row_table;

Type attr_grp_name  is table of varchar2(30);
l_attr_grp_name  attr_grp_name;


Type rrs_entity_rec is Record(
lookup_code rrs_lookups_v.lookup_code%Type,
meaning rrs_lookups_v.meaning%Type
);
Type  rrs_entity_tab is table of rrs_entity_rec;
l_rrs_entity rrs_entity_tab;

l_rrs_entity_name  rrs_lookups_v.meaning%Type;

l_page_id                       number;
l_display_name                  varchar2(240);



  BEGIN

    -----------------------
    -- Get PKs organized --
    -----------------------
begin
Select RSB.SITE_ID
	,RSB.LOCATION_ID
INTO 	l_site_id
	,l_location_id
FROM 	RRS_SITES_B RSB
WHERE 	RSB.SITE_IDENTIFICATION_NUMBER = p_site_id_num;
Exception
     When NO_DATA_FOUND Then
        raise_application_error(-20101, ' Check the Site ID please');

end;

Select  meaning
INTO    l_rrs_entity_name
from    RRS_LOOKUPS_V
where   LOOKUP_TYPE= 'RRS_ENTITY'
and     LOOKUP_CODE = 'RRS_LOCATION';



IF (p_page_name is Null) Then


    SELECT  ext.DESCRIPTIVE_FLEX_CONTEXT_CODE
    BULK COLLECT
      INTO l_attr_grp_name
      FROM ego_obj_ag_assocs_b eoab
           ,fnd_objects fo
           ,EGO_FND_DSC_FLX_CTX_EXT ext
     WHERE eoab.object_id = fo.object_id
       AND fo.obj_name in ( 'RRS_LOCATION')
       AND eoab.attr_group_id = ext.attr_group_id
       AND eoab.classification_code IN
	( select Country
	  from rrs_locations_ext_vl
	  where location_id = l_location_id
	);


elsif (p_page_name is not null) then

Begin

	SELECT  PAGE_ID,
        	DISPLAY_NAME
	INTO    l_page_id,
        	l_display_name
	FROM    EGO_PAGES_V
	WHERE   OBJECT_NAME='RRS_LOCATION'
	AND     DISPLAY_NAME = p_page_name
	AND     CLASSIFICATION_CODE IN
		(
		select 	Country
	  	from 	rrs_locations_ext_vl
	  	where 	location_id = l_location_id
		)
	ORDER BY SEQUENCE;

Exception
     		When NO_DATA_FOUND Then
        	raise_application_error(-20102, ' Page Information does not exist');

End;


	SELECT  ATTR_GROUP_NAME
	BULK COLLECT
	INTO    l_attr_grp_name
	FROM    EGO_PAGE_ENTRIES_V
	WHERE   PAGE_ID=l_page_id
	ORDER BY SEQUENCE;


end if;


    l_pk_column_values :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY(
        EGO_COL_NAME_VALUE_PAIR_OBJ('LOCATION_ID', TO_CHAR(l_location_id)));


l_object_name := 'RRS_LOCATION';
-- l_object_name := l_rrs_entity(k).lookup_code;
l_attr_group_type := 'RRS_LOCATION_GROUP';
l_data_level_name := 'LOCATION_LEVEL';


if l_attr_grp_name.count > 0 Then
 x_loc_attrib_row_table :=  EGO_USER_ATTR_ROW_TABLE();
 x_loc_attrib_data_table :=  EGO_USER_ATTR_DATA_TABLE();


for i in l_attr_grp_name.First..l_attr_grp_name.Last Loop

 l_request_table := EGO_ATTR_GROUP_REQUEST_TABLE();
 l_request_table.EXTEND();
 l_request_table(l_request_table.LAST) := EGO_ATTR_GROUP_REQUEST_OBJ(
                                               NULL 			--ATTR_GROUP_ID
                                              ,718 			--APPLICATION_ID
                                              ,l_attr_group_type 	--ATTR_GROUP_TYPE
                                              ,l_attr_grp_name(i) 	--ATTR_GROUP_NAME
                                              ,l_data_level_name 	--DATA_LEVEL
                                              ,NULL 			--DATA_LEVEL_1
                                              ,NULL 			--DATA_LEVEL_2
                                              ,NULL 			--DATA_LEVEL_3
                                              ,NULL 			--DATA_LEVEL_4
                                              ,NULL 			--DATA_LEVEL_5
                                              ,NULL 			--ATTR_NAME_LIST
                                             );

              EGO_USER_ATTRS_DATA_PUB.Get_User_Attrs_Data(
                p_api_version                => 1.0
               ,p_object_name                => l_object_name
               ,p_pk_column_name_value_pairs => l_pk_column_values
               ,p_attr_group_request_table   => l_request_table
               ,p_user_privileges_on_object  => NULL
               ,p_entity_id                  => NULL
               ,p_entity_index               => NULL
               ,p_entity_code                => NULL
               ,p_debug_level                => 0
               ,p_init_error_handler         => FND_API.G_FALSE
               ,p_init_fnd_msg_list          => FND_API.G_FALSE
               ,p_add_errors_to_fnd_stack    => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,x_attributes_row_table       => x_attributes_row_table
               ,x_attributes_data_table      => x_attributes_data_table
               ,x_return_status              => x_return_status
               ,x_errorcode                  => x_errorcode
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
              );

IF (x_attributes_row_table IS NOT NULL AND x_attributes_row_table.COUNT > 0 AND
    x_attributes_data_table IS NOT NULL AND x_attributes_data_table.COUNT > 0)
THEN


        For n in x_attributes_row_table.First..x_attributes_row_table.Last Loop

                x_loc_attrib_row_table.Extend();
                x_loc_attrib_row_table(x_loc_attrib_row_table.Last) := x_attributes_row_table(n);

        End Loop;


        For n in x_attributes_data_table.First..x_attributes_data_table.Last Loop

                x_loc_attrib_data_table.Extend();
                x_loc_attrib_data_table(x_loc_attrib_data_table.Last) := x_attributes_data_table(n);

        End Loop;


End if;


END LOOP;

End if;


END;


Procedure Get_trade_area_attributes(
 p_site_id_num                  IN              varchar2
,p_site_name                    IN              varchar2 Default null
,p_page_name                    IN              varchar2 Default null
,x_tr_area_attrib_row_table     OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_tr_area_attrib_data_table    OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
) is



l_api_name               	CONSTANT VARCHAR2(30) := 'Get_User_Attrs_For_Item';

l_request_table          	EGO_ATTR_GROUP_REQUEST_TABLE;
l_current_data_obj       	EGO_USER_ATTR_DATA_OBJ;
l_pk_column_values       	EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_user_privileges_on_object 	EGO_VARCHAR_TBL_TYPE;
l_site_id			NUMBER;
l_location_id			NUMBER;

x_attributes_row_table   	EGO_USER_ATTR_ROW_TABLE;
x_attributes_data_table  	EGO_USER_ATTR_DATA_TABLE;
x_return_status          	VARCHAR2(1);
x_errorcode              	NUMBER;
x_msg_count              	NUMBER;
x_msg_data               	VARCHAR2(1000);
p_site_id 		 	NUMBER;
l_attributes_data_index  	NUMBER;
l_object_name			varchar2(20);
l_attr_group_type		varchar2(30);
l_data_level_name		varchar2(30);

-- l_attributes_row_table  	x_attributes_row_table;
Type attr_grp_name  is table of varchar2(30);
l_attr_grp_name  attr_grp_name;


Type trade_area_id  is table of number;
l_trade_area_ids  trade_area_id;

Type rrs_entity_rec is Record(
lookup_code rrs_lookups_v.lookup_code%Type,
meaning rrs_lookups_v.meaning%Type
);
Type  rrs_entity_tab is table of rrs_entity_rec;
l_rrs_entity rrs_entity_tab;

l_rrs_entity_name  rrs_lookups_v.meaning%Type;

l_page_id                       number;
l_display_name                  varchar2(240);



  BEGIN

    -----------------------
    -- Get PKs organized --
    -----------------------
begin
Select RSB.SITE_ID
	,RSB.LOCATION_ID
INTO 	l_site_id
	,l_location_id
FROM 	RRS_SITES_B RSB
WHERE 	RSB.SITE_IDENTIFICATION_NUMBER = p_site_id_num;
Exception
     When NO_DATA_FOUND Then
        raise_application_error(-20101, ' Check the Site ID please');

end;


Select  meaning
INTO    l_rrs_entity_name
from    RRS_LOOKUPS_V
where   LOOKUP_TYPE= 'RRS_ENTITY'
and     LOOKUP_CODE = 'RRS_TRADE_AREA';


IF (p_page_name is Null) Then


    SELECT  distinct ext.DESCRIPTIVE_FLEX_CONTEXT_CODE
    BULK COLLECT
      INTO l_attr_grp_name
      FROM ego_obj_ag_assocs_b eoab
           ,fnd_objects fo
           ,EGO_FND_DSC_FLX_CTX_EXT ext
     WHERE eoab.object_id = fo.object_id
       AND fo.obj_name in ( 'RRS_TRADE_AREA')
       AND eoab.attr_group_id = ext.attr_group_id
       AND eoab.classification_code IN
        ( select b.group_id
          from rrs_trade_areas_ext_vl a,rrs_trade_areas b
          where b.location_id = l_location_id
	   and  a.trade_area_id = b.trade_area_id
        );

	select 	trade_area_id
	BULK COLLECT
	INTO  	l_trade_area_ids
	from 	rrs_trade_areas
	where 	location_id = l_location_id;


elsif (p_page_name is not null) then

Begin

	SELECT  PAGE_ID,
        	DISPLAY_NAME
	INTO    l_page_id,
        	l_display_name
	FROM    EGO_PAGES_V
	WHERE   OBJECT_NAME='RRS_TRADE_AREA'
	AND     DISPLAY_NAME = p_page_name
	AND     CLASSIFICATION_CODE IN
        	(
		select 	b.group_id
          	from 	rrs_trade_areas_ext_vl a
			,rrs_trade_areas b
          	where 	b.location_id = l_location_id
	   	and  	a.trade_area_id = b.trade_area_id
        	)
	ORDER BY SEQUENCE;

Exception
     		When NO_DATA_FOUND Then
        	raise_application_error(-20102, ' Page Information does not exist');

End;


	SELECT  ATTR_GROUP_NAME
	BULK COLLECT
	INTO    l_attr_grp_name
	FROM    EGO_PAGE_ENTRIES_V
	WHERE   PAGE_ID=l_page_id
	ORDER BY SEQUENCE;


        select  trade_area_id
        BULK COLLECT
        INTO    l_trade_area_ids
        from    rrs_trade_areas
        where   location_id = l_location_id
	and	group_id in
		(
		select 	classification_code
		from 	EGO_PAGE_ENTRIES_V
		where 	page_id = l_page_id)
	;

end if;



l_object_name := 'RRS_TRADE_AREA';
-- l_object_name := l_rrs_entity(k).lookup_code;
l_attr_group_type := 'RRS_TRADE_AREA_GROUP';
l_data_level_name := 'TRADE_AREA_LEVEL';


if l_attr_grp_name.count > 0 Then

 x_tr_area_attrib_row_table :=  EGO_USER_ATTR_ROW_TABLE();
 x_tr_area_attrib_data_table :=  EGO_USER_ATTR_DATA_TABLE();

for i in l_attr_grp_name.First..l_attr_grp_name.Last Loop
   	l_request_table := EGO_ATTR_GROUP_REQUEST_TABLE();
        l_request_table.EXTEND();
        l_request_table(l_request_table.LAST) := EGO_ATTR_GROUP_REQUEST_OBJ(
                                               NULL      		--ATTR_GROUP_ID
                                              ,718	 		--APPLICATION_ID
                                              ,l_attr_group_type 	--ATTR_GROUP_TYPE
                                              ,l_attr_grp_name(i)  	--ATTR_GROUP_NAME
                                              ,l_data_level_name  	--DATA_LEVEL
                                              ,NULL      		--DATA_LEVEL_1
                                              ,NULL      		--DATA_LEVEL_2
                                              ,NULL      		--DATA_LEVEL_3
                                              ,NULL      		--DATA_LEVEL_4
                                              ,NULL      		--DATA_LEVEL_5
                                              ,NULL      		--ATTR_NAME_LIST
                                             );




for p in l_trade_area_ids.First..l_trade_area_ids.Last Loop
    l_pk_column_values :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY(
        EGO_COL_NAME_VALUE_PAIR_OBJ('TRADE_AREA_ID', TO_CHAR(l_trade_area_ids(p)))
        );

              EGO_USER_ATTRS_DATA_PUB.Get_User_Attrs_Data(
                p_api_version                => 1.0
               ,p_object_name                => l_object_name
               ,p_pk_column_name_value_pairs => l_pk_column_values
               ,p_attr_group_request_table   => l_request_table
               ,p_user_privileges_on_object  => NULL
               ,p_entity_id                  => NULL
               ,p_entity_index               => NULL
               ,p_entity_code                => NULL
               ,p_debug_level                => 0
               ,p_init_error_handler         => FND_API.G_FALSE
               ,p_init_fnd_msg_list          => FND_API.G_FALSE
               ,p_add_errors_to_fnd_stack    => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,x_attributes_row_table       => x_attributes_row_table
               ,x_attributes_data_table      => x_attributes_data_table
               ,x_return_status              => x_return_status
               ,x_errorcode                  => x_errorcode
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
              );


IF (x_attributes_row_table IS NOT NULL AND x_attributes_row_table.COUNT > 0 AND
    x_attributes_data_table IS NOT NULL AND x_attributes_data_table.COUNT > 0)
THEN


        For n in x_attributes_row_table.First..x_attributes_row_table.Last Loop

                x_tr_area_attrib_row_table.Extend();
                x_tr_area_attrib_row_table(x_tr_area_attrib_row_table.Last) := x_attributes_row_table(n);

        End Loop;


        For n in x_attributes_data_table.First..x_attributes_data_table.Last Loop

                x_tr_area_attrib_data_table.Extend();
                x_tr_area_attrib_data_table(x_tr_area_attrib_data_table.Last) := x_attributes_data_table(n);

        End Loop;


End if;



end loop;


END LOOP;

END IF;

END;


Procedure Get_site_associations(
 p_site_id_num 			IN 		varchar2
,p_site_name   			IN 		varchar2 Default null
,x_property_tab			OUT NOCOPY	rrs_property_tab
,x_site_cluster_tab             OUT NOCOPY      rrs_site_cluster_tab
,x_site_hierar_tab              OUT NOCOPY      rrs_site_hierar_tab
,x_trade_area_grp_tab           OUT NOCOPY      rrs_trade_area_grp_tab
,x_relationship_tab             OUT NOCOPY      rrs_relationship_tab
) is

TYPE local_rrs_site_cluster_rec is RECORD (
cluster_name rrs_site_groups_tl.name%TYPE
);
Type local_rrs_site_cluster_tab is table of local_rrs_site_cluster_rec;
l_cluster_name  local_rrs_site_cluster_tab;


TYPE local_rrs_site_hierar_rec is RECORD (
hierarchy_name rrs_site_groups_tl.name%TYPE,
hierarchy_node_name rrs_site_group_nodes_tl.name%TYPE,
parent_site_name rrs_sites_tl.name%Type
);
Type local_rrs_site_hierar_tab is  table of local_rrs_site_hierar_rec;
l_hierarchy_details  local_rrs_site_hierar_tab;

l_site_id                       NUMBER;
l_location_id                   NUMBER;
l_site_party_id			NUMBER;

TYPE local_rrs_trade_area_grp_rec is RECORD (
group_id rrs_loc_trade_area_grps.group_id%TYPE,
group_name rrs_trade_area_groups_tl.name%TYPE,
group_desc rrs_trade_area_groups_tl.description%TYPE,
is_primary_flag rrs_loc_trade_area_grps.is_primary_flag%TYPE,
status_code rrs_loc_trade_area_grps.status_code%TYPE
);
TYPE local_rrs_trade_area_grp_tab IS TABLE OF local_rrs_trade_area_grp_rec;
l_trade_area_groups_details local_rrs_trade_area_grp_tab;

TYPE local_rrs_relationship_rec is RECORD (
start_date       		hz_relationships.start_date%Type,
end_date       			hz_relationships.end_date%Type,
comments       			hz_relationships.comments%Type,
subject_party_name  		hz_parties.party_name%Type,
object_party_name       	hz_parties.party_name%Type,
relationship_role       	hz_relationship_types.role%Type,
relationship_role_meaning 	fnd_lookup_values.description%Type
);
TYPE local_rrs_relationship_tab IS TABLE OF local_rrs_relationship_rec;
l_relationship_details local_rrs_relationship_tab;


TYPE local_rrs_property_rec is RECORD (
location_name 			pn_locations_all.location_code%TYPE,
property_name 			pn_properties_all.property_name%TYPE,
org_code 			mtl_parameters.organization_code%TYPE,
org_description 		hr_all_organization_units.name%TYPE
);
TYPE local_rrs_property_tab IS TABLE OF local_rrs_property_rec;
l_property_details local_rrs_property_tab;



begin

begin
Select 	RSB.SITE_ID,
	RSB.LOCATION_ID,
	RSB.SITE_PARTY_ID
INTO    l_site_id,
	l_location_id,
	l_site_party_id
FROM    RRS_SITES_B RSB
WHERE   RSB.SITE_IDENTIFICATION_NUMBER = p_site_id_num;
Exception
     When NO_DATA_FOUND Then
        raise_application_error(-20101, ' Check the Site ID please');

end;

-- Entities Details


select RRS_SITE_UTILS.GET_LOCATION_NAME(site.site_id) as location_name,
  RRS_SITE_UTILS.GET_PROPERTY_NAME(site.property_location_id)  as property_name,
  MP.ORGANIZATION_CODE ORGANIZATION_CODE,
  HAOU.NAME ORGANIZATION_DESCRIPTION
BULK Collect
INTO l_property_details
from
 rrs_sites_b site,
 HR_ALL_ORGANIZATION_UNITS HAOU,
 MTL_PARAMETERS MP
where MP.ORGANIZATION_ID = HAOU.ORGANIZATION_ID
and site.ORGANIZATION_ID = HAOU.ORGANIZATION_ID
and site.site_id = l_site_id;

x_property_tab := rrs_property_tab();
if l_property_details.count > 0 then
For i in l_property_details.First..l_property_details.Last Loop
x_property_tab.Extend();
x_property_tab(i) := rrs_property_rec(l_property_details(i).location_name
					,l_property_details(i).property_name
					,l_property_details(i).org_code
					,l_property_details(i).org_description
					);

END LOOP;
END IF;

-- Trade Area Groups

SELECT LocTradeAreaGrpsEO.GROUP_ID,
       VL.NAME,
       VL.DESCRIPTION,
       LocTradeAreaGrpsEO.IS_PRIMARY_FLAG,
       LocTradeAreaGrpsEO.STATUS_CODE
BULK COLLECT
INTO   l_trade_area_groups_details
FROM   RRS_LOC_TRADE_AREA_GRPS LocTradeAreaGrpsEO
      ,RRS_TRADE_AREA_GROUPS_VL VL
WHERE  LocTradeAreaGrpsEO.GROUP_ID = VL.GROUP_ID
AND    LOCATION_ID = l_location_id
ORDER BY NAME;


x_trade_area_grp_tab := rrs_trade_area_grp_tab();
if l_trade_area_groups_details.count > 0 then
FOR  i in l_trade_area_groups_details.First..l_trade_area_groups_details.Last LOOP
x_trade_area_grp_tab.Extend();
x_trade_area_grp_tab(i) := rrs_trade_area_grp_rec(l_trade_area_groups_details(i).group_id
                                                ,l_trade_area_groups_details(i).group_name
                                                ,l_trade_area_groups_details(i).group_desc
                                                ,l_trade_area_groups_details(i).is_primary_flag
                                                ,l_trade_area_groups_details(i).status_code
                                                );
END LOOP;
END IF;

-- Clusters

SELECT 	SiteGroup.NAME
BULK COLLECT
INTO	l_cluster_name
FROM 	RRS_SITE_GROUP_MEMBERS SiteGroupMemberEO ,RRS_SITE_GROUPS_VL SiteGroup
WHERE 	SiteGroupMemberEO.SITE_GROUP_ID = SiteGroup.SITE_GROUP_ID
AND 	SiteGroup.SITE_GROUP_TYPE_CODE = 'C'
AND 	SiteGroupMemberEO.SITE_GROUP_VERSION_ID =
	(SELECT 	MAX(SITE_GROUP_VERSION_ID)
       	FROM 		RRS_SITE_GROUP_VERSIONS curVer
      	WHERE 		curVer.SITE_GROUP_ID = SiteGroupMemberEO.SITE_GROUP_ID)
AND 	SiteGroupMemberEO.CHILD_MEMBER_ID = l_site_id
AND 	DELETED_FLAG = 'N';

x_site_cluster_tab := rrs_site_cluster_tab();
if l_cluster_name.count > 0 then
FOR  i in l_cluster_name.First..l_cluster_name.Last LOOP
x_site_cluster_tab.Extend();
x_site_cluster_tab(i) := rrs_site_cluster_rec(l_cluster_name(i).cluster_name
                                                );
END LOOP;
END IF;

-- Hierarchy

/* This was used in 12.1.1 when hierarchies only had Node to Site relation.

SELECT SiteGroup.NAME,
       SiteGroupNode.NAME SiteGroupNodeName
BULK COLLECT
INTO   l_hierarchy_details
FROM RRS_SITE_GROUP_MEMBERS SiteGroupMemberEO
    ,RRS_SITE_GROUPS_VL SiteGroup
    ,RRS_SITE_GROUP_NODES_VL SiteGroupNode
WHERE SiteGroupMemberEO.SITE_GROUP_ID = SiteGroup.SITE_GROUP_ID
AND SiteGroup.SITE_GROUP_TYPE_CODE = 'H'
AND SiteGroupNode.site_group_node_id = SiteGroupMemberEO.PARENT_MEMBER_ID
AND SiteGroupMemberEO.SITE_GROUP_VERSION_ID = (SELECT MAX(SITE_GROUP_VERSION_ID)
FROM RRS_SITE_GROUP_VERSIONS curVer WHERE curVer.SITE_GROUP_ID =
SiteGroupMemberEO.SITE_GROUP_ID) AND SiteGroupMemberEO.CHILD_MEMBER_ID = l_site_id
AND DELETED_FLAG = 'N';
*/

/* This is the new Query for 12.1.2 because of new Hierarchy project. Now we
 * introduced the concept of Site to Site relations and Site to Node relations
 * alonwith Node to Site Relationship.
 */

Select 	Hierarchy_name,
	SiteGroupNodeName,
	SiteName
BULK COLLECT
INTO   l_hierarchy_details
FROM
(SELECT SiteGroup.NAME Hierarchy_name,
       SiteGroupNode.NAME SiteGroupNodeName,
       NULL SiteName
FROM RRS_SITE_GROUP_MEMBERS SiteGroupMemberEO
    ,RRS_SITE_GROUPS_VL SiteGroup
    ,RRS_SITE_GROUP_NODES_VL SiteGroupNode
WHERE SiteGroupMemberEO.SITE_GROUP_ID = SiteGroup.SITE_GROUP_ID
AND SiteGroup.SITE_GROUP_TYPE_CODE = 'H'
AND SiteGroupNode.site_group_node_id = SiteGroupMemberEO.PARENT_MEMBER_ID
AND SiteGroupMemberEO.SITE_GROUP_VERSION_ID = (SELECT MAX(SITE_GROUP_VERSION_ID)
FROM RRS_SITE_GROUP_VERSIONS curVer WHERE curVer.SITE_GROUP_ID =
SiteGroupMemberEO.SITE_GROUP_ID) AND SiteGroupMemberEO.CHILD_MEMBER_ID =
l_site_id
AND SiteGroupMemberEO.DELETED_FLAG = 'N'
UNION ALL
SELECT
       SiteGroup.NAME Hierarchy_name,
       NULL SiteGroupNodeName,
       SITE.NAME SiteName
FROM RRS_SITE_GROUP_MEMBERS SiteGroupMemberEO
    ,RRS_SITE_GROUPS_VL SiteGroup
    ,RRS_SITES_VL SITE
WHERE SiteGroupMemberEO.SITE_GROUP_ID = SiteGroup.SITE_GROUP_ID
AND SiteGroup.SITE_GROUP_TYPE_CODE = 'H'
AND SITE.SITE_ID =SiteGroupMemberEO.PARENT_MEMBER_ID
AND SiteGroupMemberEO.SITE_GROUP_VERSION_ID = (SELECT MAX(SITE_GROUP_VERSION_ID)
FROM RRS_SITE_GROUP_VERSIONS curVer WHERE curVer.SITE_GROUP_ID =
SiteGroupMemberEO.SITE_GROUP_ID)
AND SiteGroupMemberEO.CHILD_MEMBER_ID = l_site_id
AND SiteGroupMemberEO.deleted_flag='N');




x_site_hierar_tab := rrs_site_hierar_tab();
if l_hierarchy_details.count > 0 then
FOR  i in l_hierarchy_details.First..l_hierarchy_details.Last LOOP
x_site_hierar_tab.Extend();
x_site_hierar_tab(i) := rrs_site_hierar_rec(l_hierarchy_details(i).hierarchy_name
					,l_hierarchy_details(i).hierarchy_node_name
					,l_hierarchy_details(i).parent_site_name
                                                );
END LOOP;
END IF;


-- Relationships


SELECT HzPuiRelationshipsEO.start_date,
       decode(to_char(HzPuiRelationshipsEO.end_date,'DD-MM-YYYY') , '31-12-4712', to_date(null), 							HzPuiRelationshipsEO.end_date) end_date,
       HzPuiRelationshipsEO.comments,
       subjectparty.party_name subject_party_name,
       objectparty.party_name object_party_name,
       reltype.role relationship_role,
       relationshiprolelu.description relationship_role_meaning
BULK COLLECT
INTO   l_relationship_details
FROM   hz_relationships HzPuiRelationshipsEO,
       hz_relationship_types reltype,
       hz_parties subjectparty,
       hz_parties objectparty,
       fnd_lookup_values subjectpartytypelu,
       fnd_lookup_values objectpartytypelu,
       fnd_lookup_values relationshiprolelu
WHERE  HzPuiRelationshipsEO.subject_table_name = 'HZ_PARTIES'
AND    HzPuiRelationshipsEO.object_table_name = 'HZ_PARTIES'
AND    HzPuiRelationshipsEO.status IN ('A', 'I')
AND    HzPuiRelationshipsEO.subject_id = subjectparty.party_id
AND    HzPuiRelationshipsEO.object_id = objectparty.party_id
AND    HzPuiRelationshipsEO.relationship_type = reltype.relationship_type
AND    HzPuiRelationshipsEO.relationship_code = reltype.forward_rel_code
AND    HzPuiRelationshipsEO.subject_type = reltype.subject_type
AND    HzPuiRelationshipsEO.object_type = reltype.object_type
AND    subjectpartytypelu.view_application_id = 222
AND    subjectpartytypelu.lookup_type = 'PARTY_TYPE'
AND    subjectpartytypelu.language = userenv('LANG')
AND    subjectpartytypelu.lookup_code = HzPuiRelationshipsEO.subject_type
AND    objectpartytypelu.view_application_id = 222
AND    objectpartytypelu.lookup_type = 'PARTY_TYPE'
AND    objectpartytypelu.language = userenv('LANG')
AND    objectpartytypelu.lookup_code = HzPuiRelationshipsEO.object_type
AND    relationshiprolelu.view_application_id = 222
AND    relationshiprolelu.lookup_type = 'HZ_RELATIONSHIP_ROLE'
AND    relationshiprolelu.language = userenv('LANG')
AND    relationshiprolelu.lookup_code = reltype.role
AND    HzPuiRelationshipsEO.object_type = 'ORGANIZATION'
and    HzPuiRelationshipsEO.object_id = l_site_party_id
and    HzPuiRelationshipsEO.subject_type = 'ORGANIZATION'
and    (HzPuiRelationshipsEO.status = 'A'
and    (HzPuiRelationshipsEO.end_date is null or HzPuiRelationshipsEO.end_date >= trunc(sysdate)) );


x_relationship_tab := rrs_relationship_tab();
if l_relationship_details.count > 0 then
FOR  i in l_relationship_details.First..l_relationship_details.Last LOOP
x_relationship_tab.Extend();
x_relationship_tab(i) := rrs_relationship_rec( l_relationship_details(i).start_date
 						,l_relationship_details(i).end_date
 						,l_relationship_details(i).comments
 						,l_relationship_details(i).subject_party_name
 						,l_relationship_details(i).object_party_name
 						,l_relationship_details(i).relationship_role
 						,l_relationship_details(i).relationship_role_meaning
                                                );
END LOOP;
END IF;

/*
dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Printing  Associations  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));

if l_trade_area_groups_details.count > 0 then
for i in l_trade_area_groups_details.First..l_trade_area_groups_details.Last LOOP
dbms_output.put_line('Trade Area Group : '||chr(9)||chr(9)||chr(9)||x_trade_area_grp_tab(i).group_name);
dbms_output.put_line('Primary Trade Area Group ? : '||chr(9)||chr(9)||x_trade_area_grp_tab(i).is_primary_flag);
dbms_output.put_line('Trade Area Group Status : '||chr(9)||chr(9)||x_trade_area_grp_tab(i).status_code);

END LOOP;
end if;

if l_cluster_name.count > 0 then
for i in l_cluster_name.First..l_cluster_name.Last LOOP
dbms_output.put_line('Site Asociated to Cluster : '||chr(9)||chr(9)||x_site_cluster_tab(i).cluster_name);
END LOOP;
end if;

if l_hierarchy_details.count > 0 then
for i in l_hierarchy_details.First..l_hierarchy_details.Last LOOP

dbms_output.put_line('Hierarchy Name : '||chr(9)||chr(9)||chr(9)||x_site_hierar_tab(i).hierarchy_name);
dbms_output.put_line('Hierarchy Node : '||chr(9)||chr(9)||chr(9)||x_site_hierar_tab(i).hierarchy_node_name);

END LOOP;
end if;

if l_relationship_details.count > 0 then
for i in l_relationship_details.First..l_relationship_details.Last LOOP

dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Customer : '||chr(9)||chr(9)||chr(9)||chr(9)||x_relationship_tab(i).subject_party_name);
dbms_output.put_line('Relationship Role : '||chr(9)||chr(9)||chr(9)||x_relationship_tab(i).relationship_role_meaning);
dbms_output.put_line('Start Date : '||chr(9)||chr(9)||chr(9)||chr(9)||x_relationship_tab(i).start_date);
dbms_output.put_line('End Date : '||chr(9)||chr(9)||chr(9)||chr(9)||x_relationship_tab(i).end_date);
dbms_output.put_line('Comments : '||chr(9)||chr(9)||chr(9)||chr(9)||x_relationship_tab(i).comments);

END LOOP;
end if;
dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Done Printing  Associations  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));
*/

end;



Procedure Get_site_contacts(
 p_site_id_num 			IN 		varchar2
,p_site_name   			IN 		varchar2 Default null
,x_party_site_address_tab       OUT NOCOPY      rrs_site_address_tab
,x_site_phone_tab		OUT NOCOPY 	rrs_site_phone_tab
,x_site_email_tab		OUT NOCOPY 	rrs_site_email_tab
,x_site_url_tab			OUT NOCOPY 	rrs_site_url_tab
,x_site_person_tab		OUT NOCOPY 	rrs_site_person_tab
) is

l_site_id			number;
l_site_party_id			number;


TYPE local_rrs_site_address_rec is RECORD (
address1 hz_locations.address1%TYPE,
address2 hz_locations.address2%TYPE,
address3 hz_locations.address3%TYPE,
address4 hz_locations.address4%TYPE,
city hz_locations.city%TYPE,
county hz_locations.county%TYPE,
state hz_locations.state%TYPE,
province hz_locations.province%TYPE,
postal_code hz_locations.postal_code%TYPE,
country hz_locations.country%TYPE,
country_name fnd_territories_vl.territory_short_name%Type,
address varchar2(1000),
identifying_address_flag hz_party_sites.identifying_address_flag%Type,
site_purpose ar_lookups.meaning%type --Bug 7871825
);
TYPE local_rrs_site_address_tab IS TABLE OF local_rrs_site_address_rec;
l_site_party_dets local_rrs_site_address_tab;


TYPE local_rrs_site_phone_rec is RECORD (
  CONTACT_POINT_ID	  	HZ_CONTACT_POINTS.CONTACT_POINT_ID%Type,
  CONTACT_POINT_TYPE	  	HZ_CONTACT_POINTS.CONTACT_POINT_TYPE%Type,
  STATUS         	  	HZ_CONTACT_POINTS.STATUS%Type,
  OWNER_TABLE_NAME	  	HZ_CONTACT_POINTS.OWNER_TABLE_NAME%Type,
  OWNER_TABLE_ID	  	HZ_CONTACT_POINTS.OWNER_TABLE_ID%Type,
  PRIMARY_FLAG      	  	HZ_CONTACT_POINTS.PRIMARY_FLAG%Type,
  ATTRIBUTE_CATEGORY    	HZ_CONTACT_POINTS.ATTRIBUTE_CATEGORY%Type,
  PHONE_CALLING_CALENDAR	HZ_CONTACT_POINTS.PHONE_CALLING_CALENDAR%Type,
  LAST_CONTACT_DT_TIME 	  	HZ_CONTACT_POINTS.LAST_CONTACT_DT_TIME%Type,
  PHONE_PREFERRED_ORDER	  	HZ_CONTACT_POINTS.PHONE_PREFERRED_ORDER%Type,
  PRIORITY_OF_USE_CODE	  	HZ_CONTACT_POINTS.PRIORITY_OF_USE_CODE%Type,
  TELEPHONE_TYPE	  	HZ_CONTACT_POINTS.TELEPHONE_TYPE%Type,
  TIME_ZONE          	  	HZ_CONTACT_POINTS.TIME_ZONE%Type,
  PHONE_TOUCH_TONE_TYPE_FLAG  	HZ_CONTACT_POINTS.PHONE_TOUCH_TONE_TYPE_FLAG%Type,
  PHONE_AREA_CODE   	  	HZ_CONTACT_POINTS.PHONE_AREA_CODE%Type,
  PHONE_COUNTRY_CODE	  	HZ_CONTACT_POINTS.PHONE_COUNTRY_CODE%Type,
  PHONE_NUMBER   	  	HZ_CONTACT_POINTS.PHONE_NUMBER%Type,
  PHONE_EXTENSION	  	HZ_CONTACT_POINTS.PHONE_EXTENSION%Type,
  PHONE_LINE_TYPE    	  	HZ_CONTACT_POINTS.PHONE_LINE_TYPE%Type,
  CONTENT_SOURCE_TYPE	  	HZ_CONTACT_POINTS.CONTENT_SOURCE_TYPE%Type,
  RAW_PHONE_NUMBER	  	HZ_CONTACT_POINTS.RAW_PHONE_NUMBER%Type,
  TIMEZONE_ID         	  	HZ_CONTACT_POINTS.TIMEZONE_ID%Type,
  TIMEZONE_NAME		  	FND_TIMEZONES_VL.NAME%Type,
  CONTACT_POINT_PURPOSE	  	HZ_CONTACT_POINTS.CONTACT_POINT_PURPOSE%Type,
  PRIMARY_BY_PURPOSE       	HZ_CONTACT_POINTS.PRIMARY_BY_PURPOSE%Type,
  TRANSPOSED_PHONE_NUMBER  	HZ_CONTACT_POINTS.TRANSPOSED_PHONE_NUMBER%Type,
  ACTUAL_CONTENT_SOURCE	  	HZ_CONTACT_POINTS.ACTUAL_CONTENT_SOURCE%Type
);
TYPE local_rrs_site_phone_tab IS TABLE OF local_rrs_site_phone_rec;
l_phone_details local_rrs_site_phone_tab;


TYPE local_rrs_site_email_rec is RECORD (
       CONTACT_POINT_ID	       	HZ_CONTACT_POINTS.CONTACT_POINT_ID%Type,
       CONTACT_POINT_TYPE      	HZ_CONTACT_POINTS.CONTACT_POINT_TYPE%Type,
       STATUS	       		HZ_CONTACT_POINTS.STATUS%Type,
       OWNER_TABLE_NAME	       	HZ_CONTACT_POINTS.OWNER_TABLE_NAME%Type,
       OWNER_TABLE_ID	       	HZ_CONTACT_POINTS.OWNER_TABLE_ID%Type,
       PRIMARY_FLAG	       	HZ_CONTACT_POINTS.PRIMARY_FLAG%Type,
       EMAIL_FORMAT	       	HZ_CONTACT_POINTS.EMAIL_FORMAT%Type,
       EMAIL_ADDRESS	       	HZ_CONTACT_POINTS.EMAIL_ADDRESS%Type,
       CONTACT_POINT_PURPOSE    HZ_CONTACT_POINTS.CONTACT_POINT_PURPOSE%Type,
       PRIMARY_BY_PURPOSE	HZ_CONTACT_POINTS.PRIMARY_BY_PURPOSE%Type,
       MEANING 			FND_LOOKUP_VALUES.MEANING%Type,
       ATTRIBUTE_CATEGORY	HZ_CONTACT_POINTS.ATTRIBUTE_CATEGORY%Type,
       ACTUAL_CONTENT_SOURCE	HZ_CONTACT_POINTS.ACTUAL_CONTENT_SOURCE%Type
);
TYPE local_rrs_site_email_tab IS TABLE OF local_rrs_site_email_rec;
l_email_details local_rrs_site_email_tab;


TYPE local_rrs_site_url_rec is RECORD (
       CONTACT_POINT_ID	       		HZ_CONTACT_POINTS.CONTACT_POINT_ID%Type,
       CONTACT_POINT_TYPE	       	HZ_CONTACT_POINTS.CONTACT_POINT_TYPE%Type,
       STATUS	       			HZ_CONTACT_POINTS.STATUS%Type,
       OWNER_TABLE_NAME	       		HZ_CONTACT_POINTS.OWNER_TABLE_NAME%Type,
       OWNER_TABLE_ID	       		HZ_CONTACT_POINTS.OWNER_TABLE_ID%Type,
       PRIMARY_FLAG	       		HZ_CONTACT_POINTS.PRIMARY_FLAG%Type,
       WEB_TYPE	       			HZ_CONTACT_POINTS.WEB_TYPE%Type,
       URL	       			HZ_CONTACT_POINTS.URL%Type,
       CONTENT_SOURCE_TYPE	       	HZ_CONTACT_POINTS.CONTENT_SOURCE_TYPE%Type,
       APPLICATION_ID	       		HZ_CONTACT_POINTS.APPLICATION_ID%Type,
       CONTACT_POINT_PURPOSE	       	HZ_CONTACT_POINTS.CONTACT_POINT_PURPOSE%Type,
       PRIMARY_BY_PURPOSE	       	HZ_CONTACT_POINTS.PRIMARY_BY_PURPOSE%Type,
       TRANSPOSED_PHONE_NUMBER	       	HZ_CONTACT_POINTS.TRANSPOSED_PHONE_NUMBER%Type,
       ACTUAL_CONTENT_SOURCE	       	HZ_CONTACT_POINTS.ACTUAL_CONTENT_SOURCE%Type,
       MEANING 	       			FND_LOOKUP_VALUES.MEANING%Type,
       ATTRIBUTE_CATEGORY	       	HZ_CONTACT_POINTS.ATTRIBUTE_CATEGORY%Type
);
TYPE local_rrs_site_url_tab IS TABLE OF local_rrs_site_url_rec;
l_url_details local_rrs_site_url_tab;


TYPE local_rrs_site_person_rec is RECORD (
       relationship_id	       		hz_relationships.relationship_id%Type,
       subject_type	       		hz_relationships.subject_type%Type,
       object_id	       		hz_relationships.object_id%Type,
       object_type	       		hz_relationships.object_type%Type,
       object_table_name	       	hz_relationships.object_table_name%Type,
       relationship_party_id	       	hz_relationships.party_id%Type,
       relationship_type	       	hz_relationships.relationship_type%Type,
       relationship_code	       	hz_relationships.relationship_code%Type,
       start_date	       		hz_relationships.start_date%Type,
       end_date	       			hz_relationships.end_date%Type,
       comments       			hz_relationships.comments%Type,
       status	       			hz_relationships.status%Type,
       actual_content_source	       	hz_relationships.actual_content_source%Type,
       subject_party_name	       	hz_parties.party_name%Type,
       subject_party_number	       	hz_parties.party_number%Type,
       subject_party_known_as	       	hz_parties.known_as%Type,
       object_party_name	       	hz_parties.party_name%Type,
       object_party_number	       	hz_parties.party_number%Type,
       object_party_known_as	       	hz_parties.known_as%Type,
       relationship_type_id	       	hz_relationship_types.relationship_type_id%Type,
       relationship_role	       	hz_relationship_types.role%Type,
       subject_type_meaning	       	fnd_lookup_values.meaning%Type,
       object_type_meaning	       	fnd_lookup_values.meaning%Type,
       relationship_role_meaning       	fnd_lookup_values.description%Type
);
TYPE local_rrs_site_person_tab IS TABLE OF local_rrs_site_person_rec;
l_person_details local_rrs_site_person_tab;


begin

x_party_site_address_tab := rrs_site_address_tab();

begin
Select  RSB.SITE_ID,
        RSB.SITE_PARTY_ID
INTO    l_site_id,
        l_site_party_id
FROM    RRS_SITES_B RSB
WHERE   RSB.SITE_IDENTIFICATION_NUMBER = p_site_id_num;
Exception
     When NO_DATA_FOUND Then
        raise_application_error(-20101, ' Check the Site ID please');

end;

IF l_site_party_id IS NOT NULL THEN

/*
Commented this code to troubleshoot later as why country does not show up.
SELECT  ADDRESS1,
        ADDRESS2,
        ADDRESS3,
        ADDRESS4,
        NLS_UPPER(CITY) CITY,
        NLS_UPPER(COUNTY) COUNTY,
        NLS_UPPER(STATE) STATE,
        NLS_UPPER(PROVINCE) PROVINCE,
        NLS_UPPER(POSTAL_CODE) POSTAL_CODE,
        NLS_UPPER(hz_format_pub.get_tl_territory_name(COUNTRY)) COUNTRY,
        FTV.TERRITORY_SHORT_NAME COUNTRY_NAME,
        HZ_FORMAT_PUB.format_address(HL.location_id, null, null, ',' , null) as Address,
	HPS.IDENTIFYING_ADDRESS_FLAG
BULK COLLECT
INTO	l_site_party_dets
FROM    HZ_LOCATIONS HL
        ,FND_TERRITORIES_VL FTV
	,HZ_PARTY_SITES HPS
WHERE   COUNTRY = FTV.TERRITORY_CODE
AND     HL.LOCATION_ID = HPS.LOCATION_ID
AND 	HPS.PARTY_ID = l_site_party_id;

*/
SELECT  ADDRESS1,
        ADDRESS2,
        ADDRESS3,
        ADDRESS4,
        NLS_UPPER(CITY) CITY,
        NLS_UPPER(COUNTY) COUNTY,
        NLS_UPPER(STATE) STATE,
        NLS_UPPER(PROVINCE) PROVINCE,
        NLS_UPPER(POSTAL_CODE) POSTAL_CODE,
        COUNTRY,
        FTV.TERRITORY_SHORT_NAME COUNTRY_NAME,
        HZ_FORMAT_PUB.format_address(HL.location_id, null, null, ',' , null) as Address,
	HPS.IDENTIFYING_ADDRESS_FLAG,
       	( 	select 	AL.MEANING
		from 	AR_LOOKUPS AL
		where 	AL.LOOKUP_TYPE = 'PARTY_SITE_USE_CODE'
		AND 	AL.LOOKUP_CODE = PSU.SITE_USE_TYPE ) site_purpose
BULK COLLECT
INTO	l_site_party_dets
FROM    HZ_LOCATIONS HL
        ,FND_TERRITORIES_VL FTV
	,HZ_PARTY_SITES HPS
        , HZ_PARTY_SITE_USES PSU
WHERE   COUNTRY = FTV.TERRITORY_CODE
AND     HL.LOCATION_ID = HPS.LOCATION_ID
AND     PSU.PARTY_SITE_ID(+) = HPS.PARTY_SITE_ID
AND     PSU.STATUS(+) = 'A'
AND 	HPS.PARTY_ID = l_site_party_id;

If l_site_party_dets.count > 0 then


FOR  i in l_site_party_dets.First..l_site_party_dets.Last LOOP
x_party_site_address_tab.Extend();
x_party_site_address_tab(i) := rrs_site_address_rec(l_site_party_dets(i).address1
                                                ,l_site_party_dets(i).address2
                                                ,l_site_party_dets(i).address3
                                                ,l_site_party_dets(i).address4
                                                ,l_site_party_dets(i).city
                                                ,l_site_party_dets(i).county
                                                ,l_site_party_dets(i).state
                                                ,l_site_party_dets(i).province
                                                ,l_site_party_dets(i).postal_code
                                                ,l_site_party_dets(i).country
                                                ,l_site_party_dets(i).country_name
                                                ,l_site_party_dets(i).address
                                                ,l_site_party_dets(i).identifying_address_flag
                                                ,l_site_party_dets(i).site_purpose 	--Bug 7871825
						,NULL   	-- Geometry_source
						,NULL   	-- Geometry_source_meaning
						,NULL   	-- Longitude
						,NULL   	-- Latitude
                                                );
END LOOP;

END IF;

END IF;


-- Fetching the Phone details

SELECT HzPuiContactPointPhoneEO.CONTACT_POINT_ID,
  HzPuiContactPointPhoneEO.CONTACT_POINT_TYPE,
  HzPuiContactPointPhoneEO.STATUS,
  HzPuiContactPointPhoneEO.OWNER_TABLE_NAME,
  HzPuiContactPointPhoneEO.OWNER_TABLE_ID,
  HzPuiContactPointPhoneEO.PRIMARY_FLAG,
  HzPuiContactPointPhoneEO.ATTRIBUTE_CATEGORY,
  HzPuiContactPointPhoneEO.PHONE_CALLING_CALENDAR,
  HzPuiContactPointPhoneEO.LAST_CONTACT_DT_TIME,
  HzPuiContactPointPhoneEO.PHONE_PREFERRED_ORDER,
  HzPuiContactPointPhoneEO.PRIORITY_OF_USE_CODE,
  HzPuiContactPointPhoneEO.TELEPHONE_TYPE,
  HzPuiContactPointPhoneEO.TIME_ZONE,
  HzPuiContactPointPhoneEO.PHONE_TOUCH_TONE_TYPE_FLAG,
  HzPuiContactPointPhoneEO.PHONE_AREA_CODE,
  HzPuiContactPointPhoneEO.PHONE_COUNTRY_CODE,
  HzPuiContactPointPhoneEO.PHONE_NUMBER,
  HzPuiContactPointPhoneEO.PHONE_EXTENSION,
  HzPuiContactPointPhoneEO.PHONE_LINE_TYPE,
  HzPuiContactPointPhoneEO.CONTENT_SOURCE_TYPE,
  HzPuiContactPointPhoneEO.RAW_PHONE_NUMBER,
  HzPuiContactPointPhoneEO.TIMEZONE_ID,
  Ftv.Name AS TIMEZONE_NAME,
  HzPuiContactPointPhoneEO.CONTACT_POINT_PURPOSE,
  HzPuiContactPointPhoneEO.PRIMARY_BY_PURPOSE,
  HzPuiContactPointPhoneEO.TRANSPOSED_PHONE_NUMBER,
  HzPuiContactPointPhoneEO.ACTUAL_CONTENT_SOURCE
BULK COLLECT
INTO l_phone_details
FROM
 HZ_CONTACT_POINTS HzPuiContactPointPhoneEO
,FND_TIMEZONES_VL Ftv
WHERE (CONTACT_POINT_TYPE = 'PHONE' and
OWNER_TABLE_NAME = 'HZ_PARTIES' AND OWNER_TABLE_ID = l_site_party_id
AND Ftv.ENABLED_FLAG(+) = 'Y'
AND HzPuiContactPointPhoneEO.TIMEZONE_ID = Ftv.UPGRADE_TZ_ID(+)
);

x_site_phone_tab := rrs_site_phone_tab();
if l_phone_details.count > 0 then
FOR  i in l_phone_details.First..l_phone_details.Last LOOP
x_site_phone_tab.Extend();
x_site_phone_tab(i) := rrs_site_phone_rec(
					l_phone_details(i).CONTACT_POINT_ID
  					,l_phone_details(i).CONTACT_POINT_TYPE
  					,l_phone_details(i).STATUS
  					,l_phone_details(i).OWNER_TABLE_NAME
  					,l_phone_details(i).OWNER_TABLE_ID
  					,l_phone_details(i).PRIMARY_FLAG
  					,l_phone_details(i).ATTRIBUTE_CATEGORY
  					,l_phone_details(i).PHONE_CALLING_CALENDAR
  					,l_phone_details(i).LAST_CONTACT_DT_TIME
  					,l_phone_details(i).PHONE_PREFERRED_ORDER
  					,l_phone_details(i).PRIORITY_OF_USE_CODE
  					,l_phone_details(i).TELEPHONE_TYPE
  					,l_phone_details(i).TIME_ZONE
  					,l_phone_details(i).PHONE_TOUCH_TONE_TYPE_FLAG
  					,l_phone_details(i).PHONE_AREA_CODE
  					,l_phone_details(i).PHONE_COUNTRY_CODE
  					,l_phone_details(i).PHONE_NUMBER
  					,l_phone_details(i).PHONE_EXTENSION
  					,l_phone_details(i).PHONE_LINE_TYPE
  					,l_phone_details(i).CONTENT_SOURCE_TYPE
  					,l_phone_details(i).RAW_PHONE_NUMBER
  					,l_phone_details(i).TIMEZONE_ID
  					,l_phone_details(i).TIMEZONE_NAME
  					,l_phone_details(i).CONTACT_POINT_PURPOSE
  					,l_phone_details(i).PRIMARY_BY_PURPOSE
  					,l_phone_details(i).TRANSPOSED_PHONE_NUMBER
  					,l_phone_details(i).ACTUAL_CONTENT_SOURCE
                                                );
END LOOP;
END IF;


-- Fetching email details.

SELECT HzPuiContactPointEmailEO.CONTACT_POINT_ID,
       HzPuiContactPointEmailEO.CONTACT_POINT_TYPE,
       HzPuiContactPointEmailEO.STATUS,
       HzPuiContactPointEmailEO.OWNER_TABLE_NAME,
       HzPuiContactPointEmailEO.OWNER_TABLE_ID,
       HzPuiContactPointEmailEO.PRIMARY_FLAG,
       HzPuiContactPointEmailEO.EMAIL_FORMAT,
       HzPuiContactPointEmailEO.EMAIL_ADDRESS,
       HzPuiContactPointEmailEO.CONTACT_POINT_PURPOSE,
       HzPuiContactPointEmailEO.PRIMARY_BY_PURPOSE,
       AL.MEANING USAGE,
       HzPuiContactPointEmailEO.ATTRIBUTE_CATEGORY,
       HzPuiContactPointEmailEO.ACTUAL_CONTENT_SOURCE
BULK COLLECT
INTO  l_email_details
FROM HZ_CONTACT_POINTS HzPuiContactPointEmailEO,
     fnd_lookup_values al
WHERE HzPuiContactPointEmailEO.CONTACT_POINT_TYPE ='EMAIL'
and   HzPuiContactPointEmailEO.STATUS = 'A'
and   al.view_application_id(+) = 222
and   al.language(+) = userenv('LANG')
and   al.lookup_type(+) = 'CONTACT_POINT_PURPOSE'
and   HzPuiContactPointEmailEO.CONTACT_POINT_PURPOSE = al.LOOKUP_CODE(+)
and (HzPuiContactPointEmailEO.OWNER_TABLE_NAME = 'HZ_PARTIES'
AND HzPuiContactPointEmailEO.OWNER_TABLE_ID = l_site_party_id)
ORDER BY HzPuiContactPointEmailEO.PRIMARY_FLAG DESC, USAGE NULLS LAST, HzPuiContactPointEmailEO.PRIMARY_BY_PURPOSE DESC;

x_site_email_tab := rrs_site_email_tab();
if l_email_details.count > 0 then
FOR  i in l_email_details.First..l_email_details.Last LOOP
x_site_email_tab.Extend();
x_site_email_tab(i) := rrs_site_email_rec(
                                        l_email_details(i).CONTACT_POINT_ID
                                        ,l_email_details(i).CONTACT_POINT_TYPE
                                        ,l_email_details(i).STATUS
                                        ,l_email_details(i).OWNER_TABLE_NAME
                                        ,l_email_details(i).OWNER_TABLE_ID
                                        ,l_email_details(i).PRIMARY_FLAG
                                        ,l_email_details(i).EMAIL_FORMAT
                                        ,l_email_details(i).EMAIL_ADDRESS
                                        ,l_email_details(i).CONTACT_POINT_PURPOSE
                                        ,l_email_details(i).PRIMARY_BY_PURPOSE
                                        ,l_email_details(i).MEANING
                                        ,l_email_details(i).ATTRIBUTE_CATEGORY
                                        ,l_email_details(i).ACTUAL_CONTENT_SOURCE
                                                );
END LOOP;
END IF;
-- Fetching URL details.


SELECT HzPuiContactPointUrlEO.CONTACT_POINT_ID,
       HzPuiContactPointUrlEO.CONTACT_POINT_TYPE,
       HzPuiContactPointUrlEO.STATUS,
       HzPuiContactPointUrlEO.OWNER_TABLE_NAME,
       HzPuiContactPointUrlEO.OWNER_TABLE_ID,
       HzPuiContactPointUrlEO.PRIMARY_FLAG,
       HzPuiContactPointUrlEO.WEB_TYPE,
       HzPuiContactPointUrlEO.URL,
       HzPuiContactPointUrlEO.CONTENT_SOURCE_TYPE,
       HzPuiContactPointUrlEO.APPLICATION_ID,
       HzPuiContactPointUrlEO.CONTACT_POINT_PURPOSE,
       HzPuiContactPointUrlEO.PRIMARY_BY_PURPOSE,
       HzPuiContactPointUrlEO.TRANSPOSED_PHONE_NUMBER,
       HzPuiContactPointUrlEO.ACTUAL_CONTENT_SOURCE,
       AL.MEANING USAGE,
       HzPuiContactPointUrlEO.ATTRIBUTE_CATEGORY
BULK COLLECT
INTO   l_url_details
FROM   HZ_CONTACT_POINTS HzPuiContactPointUrlEO,
       fnd_lookup_values al
WHERE  HzPuiContactPointUrlEO.CONTACT_POINT_TYPE ='WEB'
and    HzPuiContactPointUrlEO.STATUS = 'A'
and    al.view_application_id(+) = 222
and    al.language(+) = userenv('LANG')
and    al.lookup_type(+) = 'CONTACT_POINT_PURPOSE_WEB'
and    HzPuiContactPointUrlEO.CONTACT_POINT_PURPOSE = al.LOOKUP_CODE(+)
and   (HzPuiContactPointUrlEO.OWNER_TABLE_NAME = 'HZ_PARTIES'
AND HzPuiContactPointUrlEO.OWNER_TABLE_ID = l_site_party_id)
ORDER BY HzPuiContactPointUrlEO.PRIMARY_FLAG DESC, USAGE NULLS LAST, HzPuiContactPointUrlEO.PRIMARY_BY_PURPOSE DESC;

x_site_url_tab := rrs_site_url_tab();
if l_url_details.count > 0 then
FOR  i in l_url_details.First..l_url_details.Last LOOP
x_site_url_tab.Extend();
x_site_url_tab(i) := rrs_site_url_rec(
                                        l_url_details(i).CONTACT_POINT_ID
                                        ,l_url_details(i).CONTACT_POINT_TYPE
                                        ,l_url_details(i).STATUS
                                        ,l_url_details(i).OWNER_TABLE_NAME
                                        ,l_url_details(i).OWNER_TABLE_ID
                                        ,l_url_details(i).PRIMARY_FLAG
                                        ,l_url_details(i).WEB_TYPE
                                        ,l_url_details(i).URL
  					,l_url_details(i).CONTENT_SOURCE_TYPE
  					,l_url_details(i).APPLICATION_ID
                                        ,l_url_details(i).CONTACT_POINT_PURPOSE
                                        ,l_url_details(i).PRIMARY_BY_PURPOSE
                                        ,l_url_details(i).TRANSPOSED_PHONE_NUMBER
                                        ,l_url_details(i).ACTUAL_CONTENT_SOURCE
                                        ,l_url_details(i).MEANING
                                        ,l_url_details(i).ATTRIBUTE_CATEGORY
                                                );
END LOOP;
END IF;
-- Fetching the Person details

SELECT HzPuiRelationshipsEO.relationship_id,
       HzPuiRelationshipsEO.subject_type,
       HzPuiRelationshipsEO.object_id,
       HzPuiRelationshipsEO.object_type,
       HzPuiRelationshipsEO.object_table_name,
       HzPuiRelationshipsEO.party_id relationship_party_id,
       HzPuiRelationshipsEO.relationship_type,
       HzPuiRelationshipsEO.relationship_code,
       HzPuiRelationshipsEO.start_date,
       decode(to_char(HzPuiRelationshipsEO.end_date,'DD-MM-YYYY') ,
              '31-12-4712', to_date(null), --to_date to avoid xml.17 issue
              HzPuiRelationshipsEO.end_date) end_date,
       HzPuiRelationshipsEO.comments,
       HzPuiRelationshipsEO.status,
       HzPuiRelationshipsEO.actual_content_source,
       subjectparty.party_name subject_party_name,
       subjectparty.party_number subject_party_number,
       subjectparty.known_as subject_party_known_as,
       objectparty.party_name object_party_name,
       objectparty.party_number object_party_number,
       objectparty.known_as object_party_known_as,
       reltype.relationship_type_id,
       reltype.role relationship_role,
       subjectpartytypelu.meaning subject_type_meaning,
       objectpartytypelu.meaning object_type_meaning,
       relationshiprolelu.description relationship_role_meaning
BULK COLLECT
INTO   l_person_details
FROM   hz_relationships HzPuiRelationshipsEO,
       hz_relationship_types reltype,
       hz_parties subjectparty,
       hz_parties objectparty,
       fnd_lookup_values subjectpartytypelu,
       fnd_lookup_values objectpartytypelu,
       fnd_lookup_values relationshiprolelu
WHERE  HzPuiRelationshipsEO.subject_table_name = 'HZ_PARTIES'
AND    HzPuiRelationshipsEO.object_table_name = 'HZ_PARTIES'
AND    HzPuiRelationshipsEO.status IN ('A', 'I')
AND    HzPuiRelationshipsEO.subject_id = subjectparty.party_id
AND    HzPuiRelationshipsEO.object_id = objectparty.party_id
AND    HzPuiRelationshipsEO.relationship_type = reltype.relationship_type
AND    HzPuiRelationshipsEO.relationship_code = reltype.forward_rel_code
AND    HzPuiRelationshipsEO.subject_type = reltype.subject_type
AND    HzPuiRelationshipsEO.object_type = reltype.object_type
AND    subjectpartytypelu.view_application_id = 222
AND    subjectpartytypelu.lookup_type = 'PARTY_TYPE'
AND    subjectpartytypelu.language = userenv('LANG')
AND    subjectpartytypelu.lookup_code = HzPuiRelationshipsEO.subject_type
AND    objectpartytypelu.view_application_id = 222
AND    objectpartytypelu.lookup_type = 'PARTY_TYPE'
AND    objectpartytypelu.language = userenv('LANG')
AND    objectpartytypelu.lookup_code = HzPuiRelationshipsEO.object_type
AND    relationshiprolelu.view_application_id = 222
AND    relationshiprolelu.lookup_type = 'HZ_RELATIONSHIP_ROLE'
AND    relationshiprolelu.language = userenv('LANG')
AND    relationshiprolelu.lookup_code = reltype.role
AND (HzPuiRelationshipsEO.object_type = 'ORGANIZATION'
and HzPuiRelationshipsEO.object_id = l_site_party_id
and HzPuiRelationshipsEO.subject_type = 'PERSON'
and  (HzPuiRelationshipsEO.status = 'A'
and (end_date is null or end_date >= trunc(sysdate)) ));

x_site_person_tab := rrs_site_person_tab();
if l_person_details.count > 0 then
FOR  i in l_person_details.First..l_person_details.Last LOOP
x_site_person_tab.Extend();

x_site_person_tab(i) := rrs_site_person_rec(
						l_person_details(i).relationship_id
                                                ,l_person_details(i).subject_type
                                                ,l_person_details(i).object_id
                                                ,l_person_details(i).object_type
                                                ,l_person_details(i).object_table_name
                                                ,l_person_details(i).relationship_party_id
                                                ,l_person_details(i).relationship_type
                                                ,l_person_details(i).relationship_code
                                                ,l_person_details(i).start_date
                                                ,l_person_details(i).end_date
                                                ,l_person_details(i).comments
                                                ,l_person_details(i).status
                                                ,l_person_details(i).actual_content_source
                                                ,l_person_details(i).subject_party_name
                                                ,l_person_details(i).subject_party_number
                                                ,l_person_details(i).subject_party_known_as
                                                ,l_person_details(i).object_party_name
                                                ,l_person_details(i).object_party_number
                                                ,l_person_details(i).object_party_known_as
                                                ,l_person_details(i).relationship_type_id
                                                ,l_person_details(i).relationship_role
                                                ,l_person_details(i).subject_type_meaning
                                                ,l_person_details(i).object_type_meaning
                                                ,l_person_details(i).relationship_role_meaning
                                                );

END LOOP;
END IF;
/*
dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Printing  Phone  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));

If l_phone_details.count > 0 then
for i in l_phone_details.First..l_phone_details.Last Loop

dbms_output.put_line('Contact Point ID : '||chr(9)||chr(9)||l_phone_details(i).CONTACT_POINT_ID);
dbms_output.put_line('Contact Point Type : '||chr(9)||chr(9)||l_phone_details(i).CONTACT_POINT_TYPE);
dbms_output.put_line('Status: '||chr(9)||chr(9)||chr(9)||l_phone_details(i).STATUS);
dbms_output.put_line('Owner Table Name : '||chr(9)||chr(9)||l_phone_details(i).OWNER_TABLE_NAME);
dbms_output.put_line('Owner Table ID : '||chr(9)||chr(9)||l_phone_details(i).OWNER_TABLE_ID);
dbms_output.put_line('Is this Primary Phone : '||chr(9)||l_phone_details(i).PRIMARY_FLAG);
dbms_output.put_line('Attribute Category : '||chr(9)||chr(9)||l_phone_details(i).ATTRIBUTE_CATEGORY);
dbms_output.put_line('Phone Calling Calendar : '||chr(9)||chr(9)||l_phone_details(i).PHONE_CALLING_CALENDAR);
dbms_output.put_line('Last Contact Date Time : '||chr(9)||chr(9)||l_phone_details(i).LAST_CONTACT_DT_TIME);
dbms_output.put_line('Phone Preferred Order : '||chr(9)||chr(9)||l_phone_details(i).PHONE_PREFERRED_ORDER);
dbms_output.put_line('Priority of Use Code : '||chr(9)||chr(9)||l_phone_details(i).PRIORITY_OF_USE_CODE);
dbms_output.put_line('Type of Phone : '||chr(9)||chr(9)||chr(9)||l_phone_details(i).TELEPHONE_TYPE);
dbms_output.put_line('Time Zone : '||chr(9)||chr(9)||chr(9)||l_phone_details(i).TIME_ZONE);
dbms_output.put_line('Phone Touch Tone Type Flag : '||chr(9)||l_phone_details(i).PHONE_TOUCH_TONE_TYPE_FLAG);
dbms_output.put_line('Phone Area Code : '||chr(9)||chr(9)||l_phone_details(i).PHONE_AREA_CODE);
dbms_output.put_line('Phone Country Code : '||chr(9)||chr(9)||l_phone_details(i).PHONE_COUNTRY_CODE);
dbms_output.put_line('Phone Number : '||chr(9)||chr(9)||chr(9)||l_phone_details(i).PHONE_NUMBER);
dbms_output.put_line('Extension : '||chr(9)||chr(9)||chr(9)||l_phone_details(i).PHONE_EXTENSION);
dbms_output.put_line('Phone Line Type : '||chr(9)||chr(9)||l_phone_details(i).PHONE_LINE_TYPE);
dbms_output.put_line('Content Source Type '||chr(9)||chr(9)||l_phone_details(i).CONTENT_SOURCE_TYPE);
dbms_output.put_line('Raw Phone Number : '||chr(9)||chr(9)||l_phone_details(i).RAW_PHONE_NUMBER);
dbms_output.put_line('Time zone ID : '||chr(9)||chr(9)||chr(9)||l_phone_details(i).TIMEZONE_ID);
dbms_output.put_line('Purpose of Phone : '||chr(9)||chr(9)||l_phone_details(i).CONTACT_POINT_PURPOSE);
dbms_output.put_line('Primary by Purpose : '||chr(9)||chr(9)||l_phone_details(i).PRIMARY_BY_PURPOSE);
dbms_output.put_line('Transposed Phone Number : '||chr(9)||l_phone_details(i).TRANSPOSED_PHONE_NUMBER);
dbms_output.put_line('Actual Content Source : '||chr(9)||l_phone_details(i).ACTUAL_CONTENT_SOURCE);
dbms_output.put_line(chr(13) || chr(10));

End Loop;
End if;
dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Done Printing  Phone  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));

dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Printing  Email  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));

If l_email_details.count > 0 then
for i in l_email_details.First..l_email_details.Last Loop

dbms_output.put_line('Contact Point ID : '||chr(9)||chr(9)||x_site_email_tab(i).CONTACT_POINT_ID);
dbms_output.put_line('Type of Email : '||chr(9)||chr(9)||x_site_email_tab(i).CONTACT_POINT_TYPE);
dbms_output.put_line('Status : '||chr(9)||chr(9)||chr(9)||x_site_email_tab(i).STATUS);
dbms_output.put_line('Owner Table Name : '||chr(9)||chr(9)||x_site_email_tab(i).OWNER_TABLE_NAME);
dbms_output.put_line('Owner Table Id : '||chr(9)||chr(9)||x_site_email_tab(i).OWNER_TABLE_ID);
dbms_output.put_line('Is this Primary Email : '||chr(9)||x_site_email_tab(i).PRIMARY_FLAG);
dbms_output.put_line('Email Format : '||chr(9)||chr(9)||chr(9)||x_site_email_tab(i).EMAIL_FORMAT);
dbms_output.put_line('Email Address : '||chr(9)||chr(9)||x_site_email_tab(i).EMAIL_ADDRESS);
dbms_output.put_line('Purpose : '||chr(9)||chr(9)||chr(9)||x_site_email_tab(i).CONTACT_POINT_PURPOSE);
dbms_output.put_line('Primary by Purpose : '||chr(9)||chr(9)||x_site_email_tab(i).PRIMARY_BY_PURPOSE);
dbms_output.put_line('Usage : '||chr(9)||chr(9)||chr(9)||x_site_email_tab(i).MEANING);
dbms_output.put_line('Attrbute Category : '||chr(9)||chr(9)||x_site_email_tab(i).ATTRIBUTE_CATEGORY);
dbms_output.put_line('Actual Content Source '||chr(9)||chr(9)||x_site_email_tab(i).ACTUAL_CONTENT_SOURCE);
dbms_output.put_line(chr(13) || chr(10));

End Loop;
end if;
dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Done Printing  Email  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Printing  URL  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));
If l_url_details.count > 0 then
for i in l_url_details.First..l_url_details.Last Loop

dbms_output.put_line('Contact Point ID : '||chr(9)||chr(9)||x_site_url_tab(i).CONTACT_POINT_ID);
dbms_output.put_line('Contact Point Type : '||chr(9)||chr(9)||x_site_url_tab(i).CONTACT_POINT_TYPE);
dbms_output.put_line('Status : '||chr(9)||chr(9)||chr(9)||x_site_url_tab(i).STATUS);
dbms_output.put_line('Owner Table Name : '||chr(9)||chr(9)||x_site_url_tab(i).OWNER_TABLE_NAME);
dbms_output.put_line('Owner Table ID : '||chr(9)||chr(9)||x_site_url_tab(i).OWNER_TABLE_ID);
dbms_output.put_line('Is this Primary URL : '||chr(9)||chr(9)||x_site_url_tab(i).PRIMARY_FLAG);
dbms_output.put_line('Type : '||chr(9)||chr(9)||chr(9)||chr(9)||x_site_url_tab(i).WEB_TYPE);
dbms_output.put_line('URL : '||chr(9)||chr(9)||chr(9)||chr(9)||x_site_url_tab(i).URL);
dbms_output.put_line('CONTENT SOURCE TYPE : '||chr(9)||chr(9)||x_site_url_tab(i).CONTENT_SOURCE_TYPE);
dbms_output.put_line('APPLICATioN ID : '||chr(9)||chr(9)||x_site_url_tab(i).APPLICATION_ID);
dbms_output.put_line('CONTACT POINT PURPOSE : '||chr(9)||x_site_url_tab(i).CONTACT_POINT_PURPOSE);
dbms_output.put_line('PRIMARY BY PURPOSE : '||chr(9)||chr(9)||x_site_url_tab(i).PRIMARY_BY_PURPOSE);
dbms_output.put_line('TRANSPOSED PHONE NUMBER : '||chr(9)||x_site_url_tab(i).TRANSPOSED_PHONE_NUMBER);
dbms_output.put_line('ACTUAL CONTENT SOURCE : '||chr(9)||x_site_url_tab(i).ACTUAL_CONTENT_SOURCE);
dbms_output.put_line('USAGE : '||chr(9)||chr(9)||chr(9)||x_site_url_tab(i).MEANING);
dbms_output.put_line('ATTRIBUTE CATEGORY : '||chr(9)||chr(9)||x_site_url_tab(i).ATTRIBUTE_CATEGORY);
dbms_output.put_line(chr(13) || chr(10));

End Loop;
End If;
dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Done Printing  URL  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));

dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Printing  Person  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));


If l_person_details.count > 0 then
for i in l_person_details.First..l_person_details.Last Loop

dbms_output.put_line('Relation ID : '||chr(9)||chr(9)||chr(9)||x_site_person_tab(i).relationship_id);
dbms_output.put_line('Subject Type : '||chr(9)||chr(9)||chr(9)||x_site_person_tab(i).subject_type);
dbms_output.put_line('Object ID : '||chr(9)||chr(9)||chr(9)||x_site_person_tab(i).object_id);
dbms_output.put_line('Object Type : '||chr(9)||chr(9)||chr(9)||x_site_person_tab(i).object_type);
dbms_output.put_line('Object Table Name : '||chr(9)||chr(9)||x_site_person_tab(i).object_table_name);
dbms_output.put_line('RelationShip Party ID : '||chr(9)||x_site_person_tab(i).relationship_party_id);
dbms_output.put_line('RelationShip Type : '||chr(9)||chr(9)||x_site_person_tab(i).relationship_type);
dbms_output.put_line('RelationShip Code : '||chr(9)||chr(9)||x_site_person_tab(i).relationship_code);
dbms_output.put_line('Start Date : '||chr(9)||chr(9)||chr(9)||x_site_person_tab(i).start_date);
dbms_output.put_line('End Date : '||chr(9)||chr(9)||chr(9)||x_site_person_tab(i).end_date);
dbms_output.put_line('Comments : '||chr(9)||chr(9)||chr(9)||x_site_person_tab(i).comments);
dbms_output.put_line('Status : '||chr(9)||chr(9)||chr(9)||x_site_person_tab(i).status);
dbms_output.put_line('Actual Content Source : '||chr(9)||x_site_person_tab(i).actual_content_source);
dbms_output.put_line('Subject Party Name : '||chr(9)||chr(9)||x_site_person_tab(i).subject_party_name);
dbms_output.put_line('Subject Party Number : '||chr(9)||chr(9)||x_site_person_tab(i).subject_party_number);
dbms_output.put_line('Subject Party Known As : '||chr(9)||chr(9)||x_site_person_tab(i).subject_party_known_as);
dbms_output.put_line('Object Party Name : '||chr(9)||chr(9)||x_site_person_tab(i).object_party_name);
dbms_output.put_line('Object Party Number : '||chr(9)||chr(9)||x_site_person_tab(i).object_party_number);
dbms_output.put_line('Object Party Known As : '||chr(9)||chr(9)||x_site_person_tab(i).object_party_known_as);
dbms_output.put_line('RelationShip Type ID : '||chr(9)||chr(9)||x_site_person_tab(i).relationship_type_id);
dbms_output.put_line('RelationShip Role : '||chr(9)||chr(9)||x_site_person_tab(i).relationship_role);
dbms_output.put_line('Subject Type Meaning : '||chr(9)||chr(9)||x_site_person_tab(i).subject_type_meaning);
dbms_output.put_line('Object Type Meaning : '||chr(9)||chr(9)||x_site_person_tab(i).object_type_meaning);
dbms_output.put_line('RelationShip Role Meaning : '||chr(9)||x_site_person_tab(i).relationship_role_meaning);
dbms_output.put_line(chr(13) || chr(10));

End Loop;
End If;
dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Done Printing  Person  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));
*/
end;

Procedure Get_site_attachments(
 p_site_id_num 				IN 		varchar2
,p_site_name   				IN 		varchar2 Default null
,x_site_attachment_tab			OUT NOCOPY	rrs_site_attachment_tab
) is

l_site_id		number;
i 			number;

TYPE local_rrs_site_attachment_rec is RECORD (
Last_update_date fnd_attached_documents.last_update_date%TYPE,
Last_updated_by_name fnd_user.user_name%TYPE,
Entity_name fnd_attached_documents.Entity_name%TYPE,
site_id fnd_attached_documents.pk1_value%TYPE,
datatype_id fnd_documents.datatype_id%TYPE,
datatype_name fnd_document_datatypes.user_name%TYPE,
description fnd_documents_tl.description%TYPE,
file_name fnd_documents_tl.file_name%TYPE,
dm_type fnd_documents.dm_type%TYPE,
dm_node fnd_documents.dm_node%TYPE,
dm_folder_path fnd_documents.dm_folder_path%TYPE,
data_object_code fnd_document_entities.data_object_code%TYPE,
document_entity_id fnd_document_entities.document_entity_id%TYPE,
category_id fnd_attached_documents.category_id%TYPE,
attachment_category_name fnd_document_categories_tl.user_name%TYPE,
status fnd_attached_documents.status%TYPE,
attached_by_name fnd_user.user_name%TYPE,
file_name_sort fnd_documents.URL%TYPE,
usage_type fnd_documents.usage_type%TYPE,
security_type fnd_documents.security_type%TYPE,
publish_flag fnd_documents.publish_flag%TYPE,
cat_id_query fnd_document_categories_tl.category_id%TYPE,
seq_num fnd_attached_documents.seq_num%TYPE,
url fnd_documents.URL%TYPE,
title fnd_documents_tl.title%TYPE
);
TYPE local_rrs_site_attachment_tab IS TABLE OF local_rrs_site_attachment_rec;
l_attachment_details local_rrs_site_attachment_tab;

begin

begin
Select  RSB.SITE_ID
INTO    l_site_id
FROM    RRS_SITES_B RSB
WHERE   RSB.SITE_IDENTIFICATION_NUMBER = p_site_id_num;
Exception
     When NO_DATA_FOUND Then
        raise_application_error(-20101, ' Check the Site ID please');

end;




SELECT distinct
       ad.LAST_UPDATE_DATE,
       u.USER_NAME LAST_UPDATED_BY_NAME,
       ad.ENTITY_NAME,
       ad.pk1_value,
       d.DATATYPE_ID,
       d.DATATYPE_NAME,
       d.DESCRIPTION,
       decode(d.FILE_NAME, null, (select message_text from fnd_new_messages
where message_name = 'FND_UNDEFINED' and application_id = 0
and language_code = userenv('LANG')), d.FILE_NAME) FILE_NAME,
       d.dm_type,
       d.dm_node,
       d.dm_folder_path,
       e.DATA_OBJECT_CODE,
       e.DOCUMENT_ENTITY_ID,
       -- 'ALLOW_ATTACH_UPDATE' ALLOW_ATTACH_UPDATE,
       -- 'ALLOW_ATTACH_DELETE' ALLOW_ATTACH_DELETE,
       ad.category_id category_id,
       cl.user_name attachment_category_name,
       ad.status,
       (select u1.user_name from fnd_user u1 where u1.user_id=ad.CREATED_BY) ATTACHED_BY_NAME,
       decode(d.datatype_id, 5, nvl(d.title,d.description)||'('||substr(d.URL, 1, least(length(d.URL),15))||'...)',
decode(d.datatype_id, 6, nvl(d.title, d.file_name), decode(D.TITLE, null, (select message_text from fnd_new_messages where
message_name = 'FND_UNDEFINED' and application_id = 0 and language_code = userenv('LANG')), D.TITLE))) FILE_NAME_SORT,
       d.usage_type,
       d.security_type,
       d.publish_flag,
       cl.category_id cat_id_query,
       ad.seq_num,
       d.URL,
       d.TITLE
BULK COLLECT
INTO 	l_attachment_details
FROM FND_DOCUMENTS_VL d,
     FND_ATTACHED_DOCUMENTS ad,
     FND_DOCUMENT_ENTITIES e,
     FND_USER u,
     FND_DOCUMENT_CATEGORIES_TL cl,
     FND_DM_NODES node
WHERE ad.DOCUMENT_ID = d.DOCUMENT_ID
  and ad.ENTITY_NAME = e.DATA_OBJECT_CODE(+)
  and ad.LAST_UPDATED_BY = u.USER_ID(+)
  and cl.language = userenv('LANG')
  and cl.category_id = nvl(ad.category_id, d.category_id)
  and d.dm_node = node.node_id(+)
  and ad.entity_name = 'RRS_SITE_ATTACHMENTS'
  and ad.pk1_value = l_site_id
  and cl.category_id in (1,1)
  and d.datatype_id in (6,2,1,5)
  AND (d.SECURITY_TYPE=4 OR d.PUBLISH_FLAG='Y')
ORDER BY seq_num;


x_site_attachment_tab := rrs_site_attachment_tab();
if l_attachment_details.count > 0 then
FOR  i in l_attachment_details.First..l_attachment_details.Last LOOP
x_site_attachment_tab.Extend();
x_site_attachment_tab(i) := rrs_site_attachment_rec(
 						l_attachment_details(i).LAST_UPDATE_DATE
 						,l_attachment_details(i).LAST_UPDATED_BY_NAME
 						,l_attachment_details(i).ENTITY_NAME
 						,l_attachment_details(i).SITE_ID
 						,l_attachment_details(i).DATATYPE_ID
 						,l_attachment_details(i).DATATYPE_NAME
 						,l_attachment_details(i).DESCRIPTION
 						,l_attachment_details(i).FILE_NAME
 						,l_attachment_details(i).DM_TYPE
 						,l_attachment_details(i).DM_NODE
 						,l_attachment_details(i).DM_FOLDER_PATH
 						,l_attachment_details(i).DATA_OBJECT_CODE
 						,l_attachment_details(i).DOCUMENT_ENTITY_ID
 						,l_attachment_details(i).CATEGORY_ID
 						,l_attachment_details(i).ATTACHMENT_CATEGORY_NAME
 						,l_attachment_details(i).STATUS
 						,l_attachment_details(i).ATTACHED_BY_NAME
 						,l_attachment_details(i).FILE_NAME_SORT
 						,l_attachment_details(i).USAGE_TYPE
 						,l_attachment_details(i).SECURITY_TYPE
 						,l_attachment_details(i).PUBLISH_FLAG
 						,l_attachment_details(i).CAT_ID_QUERY
 						,l_attachment_details(i).SEQ_NUM
 						,l_attachment_details(i).URL
 						,l_attachment_details(i).TITLE
                                                );
END LOOP;
END IF;


/*
dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Printing  Attachment  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));

if l_attachment_details.count > 0 then
for i in l_attachment_details.First..l_attachment_details.Last LOOP
dbms_output.put_line('Last Updated : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).Last_update_date);
dbms_output.put_line('Last Updated By : '||chr(9)||chr(9)||x_site_attachment_tab(i).Last_updated_by_name);
dbms_output.put_line('Datatype_id : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).datatype_id);
dbms_output.put_line('Datatype_name : '||chr(9)||chr(9)||x_site_attachment_tab(i).datatype_name);
dbms_output.put_line('Description : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).Description);
dbms_output.put_line('File_name : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).File_name);
dbms_output.put_line('Dm_Type : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).Dm_type);
dbms_output.put_line('Dm_Node : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).Dm_node);
dbms_output.put_line('Dm_folder_path : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).Dm_folder_path);
dbms_output.put_line('data_object_code : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).data_object_code);
dbms_output.put_line('document_entity_id : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).document_entity_id);
dbms_output.put_line('category_id : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).category_id);
dbms_output.put_line('attachment_category_name : '||chr(9)||x_site_attachment_tab(i).attachment_category_name);
dbms_output.put_line('status : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).status);
dbms_output.put_line('attached_by_name : '||chr(9)||chr(9)||x_site_attachment_tab(i).attached_by_name);
dbms_output.put_line('file_name_sort : '||chr(9)||chr(9)||x_site_attachment_tab(i).file_name_sort);
dbms_output.put_line('usage_type : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).usage_type);
dbms_output.put_line('security_type : '||chr(9)||chr(9)||x_site_attachment_tab(i).security_type);
dbms_output.put_line('publish_flag : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).publish_flag);
dbms_output.put_line('cat_id_query : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).cat_id_query);
dbms_output.put_line('seq_num : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).seq_num);
dbms_output.put_line('url : '||chr(9)||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).url);
dbms_output.put_line('title : '||chr(9)||chr(9)||chr(9)||x_site_attachment_tab(i).title);
dbms_output.put_line(chr(13) || chr(10));

end loop;
end if;

dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Done Printing  Attachment  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));
*/

end;

Procedure Get_site_assets(
 p_site_id_num 			IN		varchar2
,p_site_name   			IN		varchar2 Default null
,x_site_asset_tab		OUT NOCOPY 	rrs_site_asset_tab
) is


l_site_id		number;

TYPE local_rrs_site_asset_rec is RECORD (
item_description mtl_system_items_tl.description%TYPE,
Item mtl_system_items_b.segment1%TYPE,
ItemInstance csi_item_instances.instance_number%TYPE,
SerialNumber csi_item_instances.serial_number%TYPE,
Status csi_instance_statuses.name%TYPE,
Quantity csi_item_instances.quantity%TYPE,
StartDate csi_item_instances.active_start_date%TYPE
);
TYPE local_rrs_site_asset_tab IS TABLE OF local_rrs_site_asset_rec;
l_asset_details local_rrs_site_asset_tab;



begin

begin
Select  RSB.SITE_ID
INTO    l_site_id
FROM    RRS_SITES_B RSB
WHERE   RSB.SITE_IDENTIFICATION_NUMBER = p_site_id_num;
Exception
     When NO_DATA_FOUND Then
        raise_application_error(-20101, ' Check the Site ID please');

end;


SELECT
     csiiv.DESCRIPTION ItemDescription
    ,csiiv.CONCATENATED_SEGMENTS Item
    ,csiiv.INSTANCE_NUMBER  ItemInstance
    ,csiiv.SERIAL_NUMBER  SerialNumber
    ,csiiv.INSTANCE_STATUS_NAME  Status
    ,csiiv.QUANTITY  Quantity
    ,csiiv.ACTIVE_START_DATE StartDate
BULK COLLECT
INTO  l_asset_details
FROM  CSI_INSTANCE_SEARCH_V csiiv
        ,RRS_SITES_B sites
WHERE csiiv.LOCATION_TYPE_CODE ='HZ_PARTY_SITES'
  AND   csiiv.LOCATION_ID    = sites.PARTY_SITE_ID
  AND   not (csiiv.INSTANCE_STATUS_ID = 1 )
  AND   nvl(csiiv.ACTIVE_END_DATE, sysdate+1 ) > sysdate
  AND 	sites.site_id = l_site_id
ORDER BY ItemDescription;



x_site_asset_tab := rrs_site_asset_tab();
if l_asset_details.count > 0 then
FOR  i in l_asset_details.First..l_asset_details.Last LOOP
x_site_asset_tab.Extend();
x_site_asset_tab(i) := rrs_site_asset_rec(
                                                l_asset_details(i).ITEM_DESCRIPTION
                                                ,l_asset_details(i).ITEM
                                                ,l_asset_details(i).ITEMINSTANCE
                                                ,l_asset_details(i).SERIALNUMBER
                                                ,l_asset_details(i).STATUS
                                                ,l_asset_details(i).QUANTITY
                                                ,l_asset_details(i).STARTDATE
                                                );
END LOOP;
END IF;

/*
dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Printing  Asset  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));

if l_asset_details.count > 0 then
for i in l_asset_details.First..l_asset_details.Last LOOP
dbms_output.put_line('Item Description : '||chr(9)||chr(9)||chr(9)||x_site_asset_tab(i).Item_description);
dbms_output.put_line('Item Name : '||chr(9)||chr(9)||chr(9)||chr(9)||x_site_asset_tab(i).Item);
dbms_output.put_line('Item Instance : '||chr(9)||chr(9)||chr(9)||x_site_asset_tab(i).ItemInstance);
dbms_output.put_line('Serial Number : '||chr(9)||chr(9)||chr(9)||x_site_asset_tab(i).SerialNumber);
dbms_output.put_line('Status : '||chr(9)||chr(9)||chr(9)||chr(9)||x_site_asset_tab(i).Status);
dbms_output.put_line('Quantity : '||chr(9)||chr(9)||chr(9)||chr(9)||x_site_asset_tab(i).Quantity);
dbms_output.put_line('Start Date : '||chr(9)||chr(9)||chr(9)||chr(9)||x_site_asset_tab(i).Startdate);
END LOOP;

end if;
dbms_output.put_line(chr(13) || chr(10));
dbms_output.put_line('Done Printing  Asset  Details  ');
dbms_output.put_line('==============================  ');
dbms_output.put_line(chr(13) || chr(10));

*/
end;

end RRS_SITE_INFO;

/
