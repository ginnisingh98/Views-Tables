--------------------------------------------------------
--  DDL for Package Body CSP_LOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_LOCATION_PKG" AS
/*$Header: cspgtlob.pls 120.1.12010000.2 2013/04/02 22:56:05 hhaugeru ship $*/
--p_location_rec hz_location_pub.location_rec_type;
p_location_rec hz_location_v2pub.location_rec_type;
procedure csp_create_location (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2:= FND_API.G_FALSE,
	x_ADDRESS1                      VARCHAR2:= FND_API.G_FALSE,
    x_ADDRESS2                      VARCHAR2:= FND_API.G_FALSE,
    x_ADDRESS3                      VARCHAR2:= FND_API.G_FALSE,
    x_ADDRESS4                      VARCHAR2:= FND_API.G_FALSE,
    x_CITY                          VARCHAR2:= FND_API.G_FALSE,
    x_POSTAL_CODE                   VARCHAR2:= FND_API.G_FALSE,
    x_STATE                         VARCHAR2:= FND_API.G_FALSE,
    x_PROVINCE                      VARCHAR2:= FND_API.G_FALSE,
    x_ADDRESS_STYLE                 VARCHAR2:= FND_API.G_FALSE,
    x_ADDRESS_LINES_PHONETIC        VARCHAR2:= FND_API.G_FALSE,
    x_COUNTY                        VARCHAR2:= FND_API.G_FALSE,
    x_COUNTRY                       VARCHAR2:= FND_API.G_FALSE,
    x_DESCRIPTION                   VARCHAR2:= FND_API.G_FALSE,
    x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	x_location_id		OUT NOCOPY	NUMBER,
	p_validation_level	IN 	NUMBER:= FND_API.G_VALID_LEVEL_FULL
) Is
l_return_status		VARCHAR2(1):='S';
	l_msg_count			NUMBER;
	l_msg_data			VARCHAR2(240);
	l_location_id			NUMBER;

Begin

       p_location_rec.country                    := x_country;
        p_location_rec.address1                := x_address1;
        p_location_rec.address2                   := x_address2;
        p_location_rec.address3                   := x_address3;
        p_location_rec.address4                   := x_address4;
        p_location_rec.city                    := x_city;
        p_location_rec.postal_code              := x_postal_code;
        p_location_rec.state                    := x_state;
        p_location_rec.province                 := x_province;
        p_location_rec.county                   := x_county;
        p_location_rec.address_style            := x_address_style;
	p_location_rec.address_lines_phonetic  := x_address_lines_phonetic;
        p_location_rec.description := x_description;
        p_location_rec.created_by_module        := 'CSPSHIPAD';

/*hz_location_pub.create_location (
 	p_api_version		,
	p_init_msg_list		,
 	p_commit	,
	p_location_rec	,
	l_return_status		,
	l_msg_count		,
	l_msg_data		,
    l_location_id	,
    p_validation_level
);*/
 hz_location_v2pub.create_location (
	p_init_msg_list		,
	p_location_rec	,
	l_location_id	,
	l_return_status		,
	l_msg_count		,
	l_msg_data
);

    x_return_status	:= l_return_status;
    x_msg_count		:= l_msg_count;
	x_msg_data		:= l_msg_data;
    x_location_id	:= l_location_id;

End;

procedure csp_update_location (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2:= FND_API.G_FALSE,
    x_location_id                   NUMBER,
	x_ADDRESS1                      VARCHAR2:= FND_API.G_FALSE,
    x_ADDRESS2                      VARCHAR2:= FND_API.G_FALSE,
    x_ADDRESS3                      VARCHAR2:= FND_API.G_FALSE,
    x_ADDRESS4                      VARCHAR2:= FND_API.G_FALSE,
    x_CITY                          VARCHAR2:= FND_API.G_FALSE,
    x_POSTAL_CODE                   VARCHAR2:= FND_API.G_FALSE,
    x_STATE                         VARCHAR2:= FND_API.G_FALSE,
    x_PROVINCE                      VARCHAR2:= FND_API.G_FALSE,
    x_ADDRESS_STYLE                 VARCHAR2:= FND_API.G_FALSE,
    x_ADDRESS_LINES_PHONETIC        VARCHAR2:= FND_API.G_FALSE,
    x_COUNTY                        VARCHAR2:= FND_API.G_FALSE,
    x_COUNTRY                       VARCHAR2:= FND_API.G_FALSE,
    x_DESCRIPTION                   VARCHAR2:= FND_API.G_FALSE,
    x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
   p_validation_level	IN 	NUMBER:= FND_API.G_VALID_LEVEL_FULL
) Is
l_return_status		VARCHAR2(1):='S';
	l_msg_count			NUMBER;
	l_msg_data			VARCHAR2(240);
	l_location_id			NUMBER;
    l_last_update_date DATE := trunc(sysdate);
    p_object_version_number NUMBER;
Begin

        p_location_rec.location_id                    := x_location_id;
        p_location_rec.country                    := x_country;
        p_location_rec.address1                := x_address1;
        p_location_rec.address2                   := x_address2;
        p_location_rec.address3                   := x_address3;
        p_location_rec.address4                   := x_address4;
        p_location_rec.city                    := x_city;
        p_location_rec.postal_code              := x_postal_code;
        p_location_rec.state                    := x_state;
        p_location_rec.province                 := x_province;
        p_location_rec.county                   := x_county;
        p_location_rec.address_style            := x_address_style;
	    p_location_rec.address_lines_phonetic  := x_address_lines_phonetic;
        p_location_rec.description            := x_description;
 /* hz_location_pub.update_location (
	p_api_version,
	p_init_msg_list,
	p_commit,
	p_location_rec,
	l_last_update_date,
	l_return_status,
	l_msg_count,
	l_msg_data,
    p_validation_level
);*/
 hz_location_v2pub.update_location (p_init_msg_list,
                                    p_location_rec,
                                    p_object_version_number,
                                    l_return_status,
	l_msg_count,
	l_msg_data);

    x_return_status	:= l_return_status;
    x_msg_count		:= l_msg_count;
	x_msg_data		:= l_msg_data;


        End;

End;

/
