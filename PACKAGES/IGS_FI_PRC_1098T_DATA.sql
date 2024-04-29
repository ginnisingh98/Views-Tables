--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_1098T_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_1098T_DATA" AUTHID CURRENT_USER AS
/* $Header: IGSFI92S.pls 120.0 2005/09/09 19:18:49 appldev noship $ */
/************************************************************************
  Created By :  Umesh Udayaprakash
  Date Created By :  1-May-2005
  Purpose :  Package Used in 1098t pdf file generation and EFT file generation
             java concurrent program.

  Known limitations,enhancements,remarks:
  Change History
  Who                 When                What
*************************************************************************/
 PROCEDURE contactdetails (     p_n_party_site_id	IN  hz_party_sites.party_site_id%type,
                                p_n_relationship_id	IN  hz_relationships.relationship_id%type,
                                p_n_contact_point_id	IN  hz_contact_points.contact_point_id%type,
                                p_v_phone_country_code  OUT NOCOPY hz_contact_points.phone_country_code%type,
                                p_v_phone_area_code     OUT NOCOPY hz_contact_points.phone_area_code%type,
                                p_v_phone_number	OUT NOCOPY hz_contact_points.phone_number%type,
                                p_v_phone_extension     OUT NOCOPY hz_contact_points.phone_extension%type,
                                p_v_con_party_name	OUT NOCOPY hz_parties.party_name%type,
                                p_v_party_name	        OUT NOCOPY hz_parties.party_name%type,
                                p_v_email_address       OUT NOCOPY hz_parties.email_address%type,
                                p_v_country 	        OUT NOCOPY hz_locations.country%type,
                                p_v_address1	        OUT NOCOPY hz_locations.address1%type,
                                p_v_address2	        OUT NOCOPY hz_locations.address2%type,
                                p_v_address3	        OUT NOCOPY hz_locations.address3%type,
                                p_v_address4	        OUT NOCOPY hz_locations.address4%type,
                                p_v_city	        OUT NOCOPY hz_locations.city%type,
                                p_v_postal_code	        OUT NOCOPY hz_locations.postal_code%type,
                                p_v_state	        OUT NOCOPY hz_locations.state%type,
                                p_v_province	        OUT NOCOPY hz_locations.province%type,
                                p_v_county 	        OUT NOCOPY hz_locations.county%type
                  );
END igs_fi_prc_1098t_data;

 

/
