--------------------------------------------------------
--  DDL for Package Body HZ_WORD_REPLACEMENT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_WORD_REPLACEMENT_PUB_W" AS
/*$Header: ARHWRLWB.pls 120.1 2005/06/16 21:16:36 jhuang ship $ */


procedure create_word_replacement (
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2,
        p_commit                IN      VARCHAR2,
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
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        x_original_word         OUT     NOCOPY VARCHAR2,
        x_type                  OUT     NOCOPY VARCHAR2,
        p_validation_level      IN      NUMBER
       )
is
  l_word_replacement_rec   HZ_WORD_REPLACEMENT_PUB.WORD_REPLACEMENT_REC_TYPE;
begin
  -- build the record to be passed to the public api
  l_word_replacement_rec.original_word  := p_original_word ;
  l_word_replacement_rec.replacement_word := p_replacement_word;
  l_word_replacement_rec.type := p_type;
  l_word_replacement_rec.country_code := p_country_code;
  l_word_replacement_rec.attribute_category :=p_attribute_category ;
  l_word_replacement_rec.attribute1 := p_attribute1;
  l_word_replacement_rec.attribute2 := p_attribute2;
  l_word_replacement_rec.attribute3 := p_attribute3;
  l_word_replacement_rec.attribute4 := p_attribute4;
  l_word_replacement_rec.attribute5 := p_attribute5;
  l_word_replacement_rec.attribute6 := p_attribute6;
  l_word_replacement_rec.attribute7 := p_attribute7;
  l_word_replacement_rec.attribute8 := p_attribute8;
  l_word_replacement_rec.attribute9 := p_attribute9;
  l_word_replacement_rec.attribute10 := p_attribute10;
  l_word_replacement_rec.attribute11 := p_attribute11;
  l_word_replacement_rec.attribute12 := p_attribute12;
  l_word_replacement_rec.attribute13 := p_attribute13;
  l_word_replacement_rec.attribute14 := p_attribute14;
  l_word_replacement_rec.attribute15 := p_attribute15;

  -- call the word replacement creation api
  hz_word_replacement_pub.create_word_replacement (
            p_api_version => p_api_version,
            p_init_msg_list => p_init_msg_list,
            p_commit => p_commit,
            p_word_replacement_rec => l_word_replacement_rec,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_original_word => x_original_word,
            x_type => x_type,
            p_validation_level => p_validation_level);

end create_word_replacement;


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
)
is
  l_word_replacement_rec   HZ_WORD_REPLACEMENT_PUB.WORD_REPLACEMENT_REC_TYPE;
  l_last_update_date       date;
begin
  -- build the record to be passed to the public api
  l_word_replacement_rec.original_word  := p_original_word ;
  l_word_replacement_rec.replacement_word := p_replacement_word;
  l_word_replacement_rec.type := p_type;
  l_word_replacement_rec.country_code := p_country_code;
  l_word_replacement_rec.attribute_category :=p_attribute_category ;
  l_word_replacement_rec.attribute1 := p_attribute1;
  l_word_replacement_rec.attribute2 := p_attribute2;
  l_word_replacement_rec.attribute3 := p_attribute3;
  l_word_replacement_rec.attribute4 := p_attribute4;
  l_word_replacement_rec.attribute5 := p_attribute5;
  l_word_replacement_rec.attribute6 := p_attribute6;
  l_word_replacement_rec.attribute7 := p_attribute7;
  l_word_replacement_rec.attribute8 := p_attribute8;
  l_word_replacement_rec.attribute9 := p_attribute9;
  l_word_replacement_rec.attribute10 := p_attribute10;
  l_word_replacement_rec.attribute11 := p_attribute11;
  l_word_replacement_rec.attribute12 := p_attribute12;
  l_word_replacement_rec.attribute13 := p_attribute13;
  l_word_replacement_rec.attribute14 := p_attribute14;
  l_word_replacement_rec.attribute15 := p_attribute15;

  -- call the word replacement update api
  hz_word_replacement_pub.update_word_replacement (
            p_api_version => p_api_version,
            p_init_msg_list => p_init_msg_list,
            p_commit => p_commit,
            p_word_replacement_rec => l_word_replacement_rec,
            p_last_update_date => p_last_update_date,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_validation_level => p_validation_level);
  null;
end update_word_replacement;

END HZ_WORD_REPLACEMENT_PUB_W;

/
