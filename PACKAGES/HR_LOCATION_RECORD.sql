--------------------------------------------------------
--  DDL for Package HR_LOCATION_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOCATION_RECORD" AUTHID CURRENT_USER AS
/* $Header: hrlocqry.pkh 120.0.12010000.3 2009/01/22 09:45:33 srgnanas noship $ */
/*#
* This is the source file to query location details
* @rep:scope public
* @rep:product per
* @rep:displayname HR_LOCATION
*/

TYPE location_rectype IS RECORD
	(
	location_id hr_locations.location_id%TYPE,
	location_code hr_locations.location_code%TYPE,
	location_use hr_locations.location_use%TYPE,
	business_group_id hr_locations.business_group_id%TYPE,
	description hr_locations.description%TYPE,
	ship_to_location_id hr_locations.ship_to_location_id%TYPE,
	ship_to_site_flag hr_locations.ship_to_site_flag%TYPE,
	receiving_site_flag hr_locations.receiving_site_flag%TYPE,
	bill_to_site_flag hr_locations.bill_to_site_flag%TYPE,
	in_organization_flag hr_locations.in_organization_flag%TYPE,
	office_site_flag hr_locations.office_site_flag%TYPE,
	designated_receiver_id hr_locations.designated_receiver_id%TYPE,
	inventory_organization_id hr_locations.inventory_organization_id%TYPE,
	tax_name hr_locations.tax_name%TYPE,
	inactive_date hr_locations.inactive_date%TYPE,
	style hr_locations.style%TYPE,
	address_line_1 hr_locations.address_line_1%TYPE,
	address_line_2 hr_locations.address_line_2%TYPE,
	address_line_3 hr_locations.address_line_3%TYPE,
	town_or_city hr_locations.town_or_city%TYPE,
	country hr_locations.country%TYPE,
	postal_code hr_locations.postal_code%TYPE,
	region_1 hr_locations.region_1%TYPE,
	region_2 hr_locations.region_2%TYPE,
	region_3 hr_locations.region_3%TYPE,
	telephone_number_1 hr_locations.telephone_number_1%TYPE,
	telephone_number_2 hr_locations.telephone_number_2%TYPE,
	telephone_number_3 hr_locations.telephone_number_3%TYPE,
	loc_information13 hr_locations.loc_information13%TYPE,
	loc_information14 hr_locations.loc_information14%TYPE,
	loc_information15 hr_locations.loc_information15%TYPE,
	loc_information16 hr_locations.loc_information16%TYPE,
	loc_information17 hr_locations.loc_information17%TYPE,
	loc_information18 hr_locations.loc_information18%TYPE,
	loc_information19 hr_locations.loc_information19%TYPE,
	loc_information20 hr_locations.loc_information20%TYPE,
	attribute_category hr_locations.attribute_category%TYPE,
	attribute1 hr_locations.attribute1%TYPE,
	attribute2 hr_locations.attribute2%TYPE,
	attribute3 hr_locations.attribute3%TYPE,
	attribute4 hr_locations.attribute4%TYPE,
	attribute5 hr_locations.attribute5%TYPE,
	attribute6 hr_locations.attribute6%TYPE,
	attribute7 hr_locations.attribute7%TYPE,
	attribute8 hr_locations.attribute8%TYPE,
	attribute9 hr_locations.attribute9%TYPE,
	attribute10 hr_locations.attribute10%TYPE,
	attribute11 hr_locations.attribute11%TYPE,
	attribute12 hr_locations.attribute12%TYPE,
	attribute13 hr_locations.attribute13%TYPE,
	attribute14 hr_locations.attribute14%TYPE,
	attribute15 hr_locations.attribute15%TYPE,
	attribute16 hr_locations.attribute16%TYPE,
	attribute17 hr_locations.attribute17%TYPE,
	attribute18 hr_locations.attribute18%TYPE,
	attribute19 hr_locations.attribute19%TYPE,
	attribute20 hr_locations.attribute20%TYPE,
	global_attribute_category hr_locations.global_attribute_category%TYPE,
	global_attribute1 hr_locations.global_attribute1%TYPE,
	global_attribute2 hr_locations.global_attribute2%TYPE,
	global_attribute3 hr_locations.global_attribute3%TYPE,
	global_attribute4 hr_locations.global_attribute4%TYPE,
	global_attribute5 hr_locations.global_attribute5%TYPE,
	global_attribute6 hr_locations.global_attribute6%TYPE,
	global_attribute7 hr_locations.global_attribute7%TYPE,
	global_attribute8 hr_locations.global_attribute8%TYPE,
	global_attribute9 hr_locations.global_attribute9%TYPE,
	global_attribute10 hr_locations.global_attribute10%TYPE,
	global_attribute11 hr_locations.global_attribute11%TYPE,
	global_attribute12 hr_locations.global_attribute12%TYPE,
	global_attribute13 hr_locations.global_attribute13%TYPE,
	global_attribute14 hr_locations.global_attribute14%TYPE,
	global_attribute15 hr_locations.global_attribute15%TYPE,
	global_attribute16 hr_locations.global_attribute16%TYPE,
	global_attribute17 hr_locations.global_attribute17%TYPE,
	global_attribute18 hr_locations.global_attribute18%TYPE,
	global_attribute19 hr_locations.global_attribute19%TYPE,
	global_attribute20 hr_locations.global_attribute20%TYPE,
	last_update_date hr_locations.last_update_date%TYPE,
	last_updated_by hr_locations.last_updated_by%TYPE,
	last_update_login hr_locations.last_update_login%TYPE,
	created_by hr_locations.created_by%TYPE,
	creation_date hr_locations.creation_date%TYPE,
	entered_by hr_locations.entered_by%TYPE,
	tp_header_id hr_locations.tp_header_id%TYPE,
	ece_tp_location_code hr_locations.ece_tp_location_code%TYPE,
	object_version_number hr_locations.object_version_number%TYPE,
	legal_address_flag hr_locations.legal_address_flag%TYPE,
	timezone_code hr_locations.timezone_code%TYPE
	);

TYPE location_tabletype IS TABLE OF location_rectype NOT NULL;

TYPE location_input_rectype IS RECORD
    (
        location_id               hr_locations.location_id%TYPE DEFAULT NULL,
        start_location_id         hr_locations.location_id%TYPE DEFAULT NULL,
        end_location_id           hr_locations.location_id%TYPE DEFAULT NULL,
        business_group_id         hr_locations.business_group_id%TYPE DEFAULT NULL
    );

/*#
* This is procedure for querying location details.
* @rep:displayname Get Location Details
* @rep:category BUSINESS_ENTITY HR_LOCATION
* @rep:scope public
* @rep:lifecycle active
*/
PROCEDURE get_location_details(p_query_options  IN  location_input_rectype
                              ,p_locations      OUT NOCOPY location_tabletype);
END hr_location_record;

/
