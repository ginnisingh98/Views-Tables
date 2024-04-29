--------------------------------------------------------
--  DDL for Package IGS_PE_PERSON_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PERSON_ADDR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI12S.pls 120.0 2005/06/01 15:56:10 appldev noship $ */

 procedure INSERT_ROW (
        p_action			IN	  VARCHAR2,
 		p_rowid 			IN OUT NOCOPY  VARCHAR2,
 		p_location_id 			IN OUT NOCOPY  NUMBER,
 		p_start_dt			IN 	igs_pe_hz_pty_sites.start_date%TYPE,
 		p_end_dt 			IN	igs_pe_hz_pty_sites.end_date%TYPE,
  		p_country			IN	VARCHAR2,
 		p_address_style 		IN    VARCHAR2,
		p_addr_line_1			IN    VARCHAR2,
	   	p_addr_line_2			IN    VARCHAR2,
		p_addr_line_3			IN    VARCHAR2,
		p_addr_line_4			IN    VARCHAR2,
 		p_date_last_verified		IN 	DATE,
 		p_correspondence 		IN 	VARCHAR2,
		p_city				IN	VARCHAR2,
		p_state				IN	VARCHAR2,
		p_province			IN	VARCHAR2,
		p_county			IN	VARCHAR2,
		p_postal_code			IN	VARCHAR2,
 		p_address_lines_phonetic	IN  	VARCHAR2,
		p_delivery_point_code		IN        VARCHAR2,
		p_other_details_1		IN    	VARCHAR2,
		p_other_details_2		IN	      VARCHAR2,
		p_other_details_3		IN	      VARCHAR2,
		l_return_status			OUT NOCOPY         VARCHAR2,
   		l_msg_data			OUT NOCOPY   	VARCHAR2,
 		p_party_id 			IN 	      NUMBER,
 		p_party_site_id			IN OUT NOCOPY	NUMBER,
 		p_party_type			IN       	VARCHAR2,
        p_last_update_date		IN OUT NOCOPY DATE,
		p_party_site_ovn		IN OUT NOCOPY hz_party_sites.object_version_number%TYPE,
		p_location_ovn			IN OUT NOCOPY hz_party_sites.object_version_number%TYPE,
		p_status			IN hz_party_sites.status%TYPE DEFAULT 'A'
   );


 procedure UPDATE_ROW (
        p_action			IN	VARCHAR2,
 		p_rowid 			IN OUT NOCOPY  VARCHAR2,
 		p_location_id 			IN OUT NOCOPY  NUMBER,
 		p_start_dt			IN 	igs_pe_hz_pty_sites.start_date%TYPE,
 		p_end_dt 			IN	igs_pe_hz_pty_sites.end_date%TYPE,
   		p_country			IN	VARCHAR2,
 		p_address_style 		IN      VARCHAR2,
		p_addr_line_1			IN      VARCHAR2,
	   	p_addr_line_2			IN      VARCHAR2,
		p_addr_line_3			IN      VARCHAR2,
		p_addr_line_4			IN      VARCHAR2,
 		p_date_last_verified		IN 	DATE,
 		p_correspondence 		IN 	VARCHAR2,
		p_city				IN	VARCHAR2,
		p_state				IN	VARCHAR2,
		p_province			IN	VARCHAR2,
		p_county			IN	VARCHAR2,
		p_postal_code			IN	VARCHAR2,
 		p_address_lines_phonetic 	IN  	VARCHAR2,
		p_delivery_point_code		IN	VARCHAR2,
		p_other_details_1		IN	VARCHAR2,
		p_other_details_2		IN	VARCHAR2,
		p_other_details_3		IN	VARCHAR2,
		l_return_status   	        OUT NOCOPY     VARCHAR2,
        l_msg_data                      OUT NOCOPY  	VARCHAR2,
 		p_party_id 			IN 	NUMBER,
 		p_party_site_id			IN OUT NOCOPY	NUMBER,
 		p_party_type		  	IN	VARCHAR2,
        p_last_update_date		IN  OUT NOCOPY DATE,
		p_party_site_ovn		IN OUT NOCOPY hz_party_sites.object_version_number%TYPE,
		p_location_ovn			IN OUT NOCOPY hz_party_sites.object_version_number%TYPE,
		p_status			IN hz_party_sites.status%TYPE DEFAULT 'A'
  );

END igs_pe_person_addr_pkg;

 

/
