--------------------------------------------------------
--  DDL for Package IGS_AD_LOCATION_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_LOCATION_ADDR_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI45S.pls 115.10 2003/11/28 14:30:13 gmaheswa ship $ */
procedure INSERT_ROW (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_location_venue_addr_id IN OUT NOCOPY NUMBER,
    x_location_id IN OUT NOCOPY NUMBER,
    x_location_venue_cd IN VARCHAR2,
    x_start_dt IN DATE,
    x_end_dt IN DATE,
    x_country IN VARCHAR2,
    x_address_style IN VARCHAR2,
    x_addr_line_1 IN VARCHAR2,
    x_addr_line_2 IN VARCHAR2,
    x_addr_line_3 IN VARCHAR2,
    x_addr_line_4 IN VARCHAR2,
    x_date_last_verified IN DATE,
    x_correspondence IN VARCHAR2,
    x_city IN VARCHAR2,
    x_state IN VARCHAR2,
    x_province IN VARCHAR2,
    x_county IN VARCHAR2,
    x_postal_code IN VARCHAR2,
    x_address_lines_phonetic IN VARCHAR2,
    x_delivery_point_code IN VARCHAR2,
    x_other_details_1 IN VARCHAR2,
    x_other_details_2 IN VARCHAR2,
    x_other_details_3 IN VARCHAR2,
    x_source_type IN VARCHAR2,
    x_contact_person IN VARCHAR2 default NULL,
    x_msg_data OUT NOCOPY VARCHAR2,
    l_return_status OUT NOCOPY VARCHAR2 ,
    x_object_version_number IN OUT NOCOPY NUMBER,
    X_MODE in VARCHAR2 default 'R'
  );

procedure UPDATE_ROW (
    x_rowid IN VARCHAR2,
    x_location_venue_addr_id IN NUMBER,
    x_location_id IN NUMBER,
    x_location_venue_cd IN VARCHAR2,
    x_start_dt IN DATE,
    x_end_dt IN DATE,
    x_country IN VARCHAR2,
    x_address_style IN VARCHAR2,
    x_addr_line_1 IN VARCHAR2,
    x_addr_line_2 IN VARCHAR2,
    x_addr_line_3 IN VARCHAR2,
    x_addr_line_4 IN VARCHAR2,
    x_date_last_verified IN DATE,
    x_correspondence IN VARCHAR2,
    x_city IN VARCHAR2,
    x_state IN VARCHAR2,
    x_province IN VARCHAR2,
    x_county IN VARCHAR2,
    x_postal_code IN VARCHAR2,
    x_address_lines_phonetic IN VARCHAR2,
    x_delivery_point_code IN VARCHAR2,
    x_other_details_1 IN VARCHAR2,
    x_other_details_2 IN VARCHAR2,
    x_other_details_3 IN VARCHAR2,
    x_source_type IN VARCHAR2,
    x_contact_person IN VARCHAR2 default NULL,
    x_msg_data OUT NOCOPY VARCHAR2,
    l_return_status OUT NOCOPY VARCHAR2,
    x_object_version_number IN OUT NOCOPY NUMBER,
    X_MODE in VARCHAR2 default 'R'
  );

end IGS_AD_LOCATION_ADDR_PKG;

 

/
