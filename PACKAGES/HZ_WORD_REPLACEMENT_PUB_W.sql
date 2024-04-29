--------------------------------------------------------
--  DDL for Package HZ_WORD_REPLACEMENT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_WORD_REPLACEMENT_PUB_W" AUTHID CURRENT_USER AS
/*$Header: ARHWRLWS.pls 120.1 2005/06/16 21:16:39 jhuang ship $ */


procedure create_word_replacement (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2,
	p_commit		IN	VARCHAR2,
        p_original_word         IN      VARCHAR2,
        p_replacement_word      IN      VARCHAR2,
        p_type                  IN      VARCHAR2,
        p_country_code          IN      VARCHAR2 DEFAULT 'US',
        p_attribute_category    IN      VARCHAR2,
        p_attribute1            IN      VARCHAR2,
        p_attribute2            IN      VARCHAR2,
        p_attribute3            IN      VARCHAR2,
        p_attribute4            IN      VARCHAR2,
        p_attribute5            IN      VARCHAR2,
        p_attribute6            IN      VARCHAR2,
        p_attribute7            IN      VARCHAR2,
        p_attribute8            IN      VARCHAR2,
        p_attribute9            IN      VARCHAR2,
        p_attribute10           IN      VARCHAR2,
        p_attribute11           IN      VARCHAR2,
        p_attribute12           IN      VARCHAR2,
        p_attribute13           IN      VARCHAR2,
        p_attribute14           IN      VARCHAR2,
        p_attribute15           IN      VARCHAR2,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	x_original_word		OUT	NOCOPY VARCHAR2,
	x_type		        OUT	NOCOPY VARCHAR2,
	p_validation_level	IN 	NUMBER
);

procedure update_word_replacement (
	p_api_version	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2,
	p_commit		IN	VARCHAR2,
        p_original_word         IN      VARCHAR2,
        p_replacement_word      IN      VARCHAR2,
        p_type                  IN      VARCHAR2,
        p_country_code          IN      VARCHAR2 DEFAULT 'US',
        p_attribute_category    IN      VARCHAR2,
        p_attribute1            IN      VARCHAR2,
        p_attribute2            IN      VARCHAR2,
        p_attribute3            IN      VARCHAR2,
        p_attribute4            IN      VARCHAR2,
        p_attribute5            IN      VARCHAR2,
        p_attribute6            IN      VARCHAR2,
        p_attribute7            IN      VARCHAR2,
        p_attribute8            IN      VARCHAR2,
        p_attribute9            IN      VARCHAR2,
        p_attribute10           IN      VARCHAR2,
        p_attribute11           IN      VARCHAR2,
        p_attribute12           IN      VARCHAR2,
        p_attribute13           IN      VARCHAR2,
        p_attribute14           IN      VARCHAR2,
        p_attribute15           IN      VARCHAR2,
	p_last_update_date	IN OUT	NOCOPY DATE,
        x_return_status		OUT	NOCOPY VARCHAR2,
        x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        p_validation_level      IN      NUMBER
);

END HZ_WORD_REPLACEMENT_PUB_W;

 

/
