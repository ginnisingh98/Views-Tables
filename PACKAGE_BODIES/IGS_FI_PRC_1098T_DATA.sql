--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_1098T_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_1098T_DATA" AS
/* $Header: IGSFI92B.pls 120.0 2005/09/09 19:03:52 appldev noship $ */
/************************************************************************
  Created By :  Umesh Udayaprakash
  Date Created By :  1-May-2005
  Purpose :  Package Used in 1098t pdf file generation and EFT file generation
             java concurrent program.

  Known limitations,enhancements,remarks:
  Change History
  Who                 When                What
*************************************************************************/
PROCEDURE contactdetails ( p_n_party_site_id	  IN  hz_party_sites.party_site_id%type,
                        p_n_relationship_id	    IN  hz_relationships.relationship_id%type,
                        p_n_contact_point_id	  IN  hz_contact_points.contact_point_id%type,
                        p_v_phone_country_code  OUT NOCOPY hz_contact_points.phone_country_code%type,
                        p_v_phone_area_code     OUT NOCOPY hz_contact_points.phone_area_code%type,
                        p_v_phone_number	      OUT NOCOPY hz_contact_points.phone_number%type,
                        p_v_phone_extension     OUT NOCOPY hz_contact_points.phone_extension%type,
                        p_v_con_party_name	    OUT NOCOPY hz_parties.party_name%type,
                        p_v_party_name		      OUT NOCOPY hz_parties.party_name%type,
                        p_v_email_address	      OUT NOCOPY hz_parties.email_address%type,
                        p_v_country 	          OUT NOCOPY hz_locations.country%type,
                        p_v_address1	          OUT NOCOPY hz_locations.address1%type,
                        p_v_address2	          OUT NOCOPY hz_locations.address2%type,
                        p_v_address3	          OUT NOCOPY hz_locations.address3%type,
                        p_v_address4	          OUT NOCOPY hz_locations.address4%type,
                        p_v_city		            OUT NOCOPY hz_locations.city%type,
                        p_v_postal_code	        OUT NOCOPY hz_locations.postal_code%type,
                        p_v_state		            OUT NOCOPY hz_locations.state%type,
                        p_v_province	          OUT NOCOPY hz_locations.province%type,
                        p_v_county 		          OUT NOCOPY hz_locations.county%type
                  ) as
/************************************************************************
  Created By :  Umesh Udayaprakash
  Date Created By :  1-May-2005
  Purpose :  Package Used in 1098t  pdf file generation java concurrent program
  Known limitations,enhancements,remarks:
  Change History
  Who                 When                What
*************************************************************************/
  CURSOR c_party_loc_id (c_n_party_site_id in hz_party_sites.party_site_id%TYPE ) IS
	  SELECT party_id ,location_id
	  FROM hz_party_sites WHERE PARTY_SITE_ID =c_n_PARTY_SITE_ID;
  rec_party_loc_id  c_party_loc_id%rowtype;


  CURSOR c_contact_name (c_n_party_id in hz_parties.party_id%TYPE ) IS
    SELECT party_name FROM
    hz_parties
    WHERE party_id = c_n_party_id;

  CURSOR c_location_details (c_n_LOCATION_ID in HZ_LOCATIONS.LOCATION_ID%TYPE ) IS
	  SELECT country,address1,address2,address3,address4,city,
		 postal_code,state,province,county
	  FROM hz_locations
	  WHERE location_id = c_n_LOCATION_ID;

  CURSOR c_name_mailid IS
    SELECT hp_name.party_name, hp_email.email_address
	  FROM hz_parties hp_name, hz_relationships hr, hz_parties hp_email
	  WHERE hr.relationship_id = p_n_relationship_id
	  AND hr.directional_flag = 'B'
	  AND hp_name.party_id = hr.object_id
    AND hr.party_id = hp_email.party_id;


  CURSOR c_phone_details IS
    SELECT phone_country_code, phone_area_code, phone_number,phone_extension
    FROM hz_contact_points
    WHERE contact_point_id = p_n_contact_point_id;
  BEGIN

    OPEN c_party_loc_id(p_n_party_site_id);
    FETCH c_party_loc_id INTO rec_party_loc_id;

    IF c_party_loc_id%FOUND THEN

	    OPEN c_contact_name(rec_party_loc_id.party_id);
	    FETCH c_contact_name INTO p_v_con_party_name;
	    CLOSE c_contact_name;

	    OPEN c_location_details(rec_party_loc_id.LOCATION_ID);
	    FETCH c_location_details INTO  p_v_country,p_v_address1,p_v_address2,p_v_address3,p_v_address4,p_v_city,p_v_postal_code,p_v_state, p_v_province,p_v_county;
	    CLOSE c_location_details;
    END IF;
    CLOSE c_party_loc_id;
   IF p_n_relationship_id is NOT NULL THEN
     OPEN c_name_mailid;
     FETCH c_name_mailid INTO p_v_party_name,p_v_email_address;
     CLOSE c_name_mailid;
   END IF;

   IF p_n_contact_point_id is NOT NULL THEN
    OPEN c_phone_details;
    FETCH c_phone_details INTO p_v_phone_country_code,p_v_phone_area_code,p_v_phone_number,p_v_phone_extension;
    CLOSE c_phone_details;
   END IF;
  END contactdetails;

END igs_fi_prc_1098t_data;

/
