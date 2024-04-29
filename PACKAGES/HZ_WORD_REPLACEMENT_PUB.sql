--------------------------------------------------------
--  DDL for Package HZ_WORD_REPLACEMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_WORD_REPLACEMENT_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHWRLSS.pls 120.1 2005/06/16 21:16:33 jhuang ship $ */


TYPE word_replacement_rec_type IS RECORD(
        original_word           VARCHAR2(50) := FND_API.G_MISS_CHAR,
        replacement_word        VARCHAR2(50) := FND_API.G_MISS_CHAR,
        type                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
        country_code            VARCHAR2(30) := FND_API.G_MISS_CHAR,
        attribute_category      VARCHAR2(30)  := FND_API.G_MISS_CHAR,
        attribute1              VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute2              VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute3              VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute4              VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute5              VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute6              VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute7              VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute8              VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute9              VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute10             VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute11             VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute12             VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute13             VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute14             VARCHAR2(150) := FND_API.G_MISS_CHAR,
        attribute15             VARCHAR2(150) := FND_API.G_MISS_CHAR
);


procedure create_word_replacement (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2:= FND_API.G_FALSE,
	p_word_replacement_rec	IN	WORD_REPLACEMENT_REC_TYPE,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	x_original_word		OUT	NOCOPY VARCHAR2,
	x_type		        OUT	NOCOPY VARCHAR2,
	p_validation_level	IN 	NUMBER:= FND_API.G_VALID_LEVEL_FULL
);

procedure update_word_replacement (
	p_api_version	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2:=FND_API.G_FALSE,
	p_commit		IN	VARCHAR2:=FND_API.G_FALSE,
	p_word_replacement_rec	IN	WORD_REPLACEMENT_REC_TYPE,
	p_last_update_date	IN OUT	NOCOPY DATE,
        x_return_status		OUT	NOCOPY VARCHAR2,
        x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        p_validation_level      IN      NUMBER:= FND_API.G_VALID_LEVEL_FULL
);

END HZ_WORD_REPLACEMENT_PUB;

 

/
