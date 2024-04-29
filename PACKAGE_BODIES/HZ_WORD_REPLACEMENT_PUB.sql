--------------------------------------------------------
--  DDL for Package Body HZ_WORD_REPLACEMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_WORD_REPLACEMENT_PUB" AS
/*$Header: ARHWRLSB.pls 120.1 2005/06/16 21:16:30 jhuang ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'HZ_WORD_REPLACEMENT_PUB';

procedure do_create_word_replacement(
        p_word_replacement_rec           IN      WORD_REPLACEMENT_REC_TYPE,
        x_original_word                  OUT     NOCOPY VARCHAR2,
        x_type                           OUT     NOCOPY VARCHAR2,
	x_return_status                  IN OUT  NOCOPY VARCHAR2
);


procedure do_update_word_replacement(
        p_word_replacement_rec           IN      WORD_REPLACEMENT_REC_TYPE,
        p_last_update_date               IN OUT  NOCOPY DATE,
	x_return_status                  IN OUT  NOCOPY VARCHAR2
);

procedure validate_word_replacement(
        p_word_replacement_rec  	 IN      WORD_REPLACEMENT_REC_TYPE,
        create_update_flag               IN      VARCHAR2,
        x_return_status                  IN OUT  NOCOPY VARCHAR2
);

procedure get_current_word_replacement(
        p_original_word                  IN      VARCHAR2,
        p_type                           IN      VARCHAR2,
        x_word_replacement_rec           OUT	 NOCOPY WORD_REPLACEMENT_REC_TYPE
);


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              create_word_replacement                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Creates word replacement record.	                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_api_version                                          |
 |                    p_init_msg_list                                        |
 |                    p_commit                                               |
 |                    p_word_replacement_rec                                 |
 |              OUT:                                                         |
 |                    x_return_status                                        |
 |                    x_msg_count                                            |
 |                    x_msg_data                                             |
 |                    x_original_word                                        |
 |                    x_type                                                 |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   14-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

procedure create_word_replacement (
	p_api_version	        IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2:= FND_API.G_FALSE,
	p_word_replacement_rec	IN	WORD_REPLACEMENT_REC_TYPE,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	x_original_word		OUT	NOCOPY VARCHAR2,
	x_type		        OUT	NOCOPY VARCHAR2,
        p_validation_level      IN      NUMBER:= FND_API.G_VALID_LEVEL_FULL
) IS
	l_api_name              CONSTANT VARCHAR2(30) := 'create_word_replacement';
        l_api_version           CONSTANT  NUMBER       := 1.0;

	l_word_replacement_rec          WORD_REPLACEMENT_REC_TYPE := p_word_replacement_rec;
BEGIN
--Standard start of API savepoint
        SAVEPOINT create_word_replacement_pub;

--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

--Call to business logic.
        do_create_word_replacement(
                        l_word_replacement_rec,
                        x_original_word,
                        x_type,
			x_return_status);

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_word_replacement_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_word_replacement_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO create_word_replacement_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              update_word_replacement                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Updates word replacement.	                             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_api_version                                          |
 |                    p_init_msg_list                                        |
 |                    p_commit                                               |
 |                    p_word_replacement_rec                                 |
 |                    p_last_update_date           	                     |
 |              OUT:                                                         |
 |                    x_return_status                                        |
 |                    x_msg_count                                            |
 |                    x_msg_data                                             |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   14-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

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
) IS
	l_api_name              CONSTANT VARCHAR2(30) := 'update_word_replacement';
        l_api_version           CONSTANT  NUMBER       := 1.0;

	l_word_replacement_rec	        WORD_REPLACEMENT_REC_TYPE := p_word_replacement_rec;
	l_old_word_replacement_rec      WORD_REPLACEMENT_REC_TYPE;
BEGIN
--Standard start of API savepoint
        SAVEPOINT update_word_replacement_pub;

--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

--Get the old record.
	get_current_word_replacement(
        	l_word_replacement_rec.original_word,
        	l_word_replacement_rec.type,
		l_old_word_replacement_rec);

--Call to business logic.
        do_update_word_replacement(
                        l_word_replacement_rec,
                        p_last_update_date,
			x_return_status);

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_word_replacement_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_word_replacement_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO update_word_replacement_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              do_create_word_replacement                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Creates word replacements. 	                             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_word_replacement_rec                                 |
 |              OUT:                                                         |
 |                    x_original_word                                        |
 |                    x_type                                                 |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   14-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

procedure do_create_word_replacement(
        p_word_replacement_rec          IN      WORD_REPLACEMENT_REC_TYPE,
        x_original_word                 OUT     NOCOPY VARCHAR2,
        x_type                          OUT     NOCOPY VARCHAR2,
	x_return_status			IN OUT	NOCOPY VARCHAR2
) IS
        l_rowid         ROWID := NULL;
        l_count         NUMBER;
BEGIN

        validate_word_replacement(p_word_replacement_rec, 'C', x_return_status);

	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
        END IF;

--Call table-handler.

	HZ_WORD_REPLACEMENTS_PKG.INSERT_ROW(
        X_Rowid => l_Rowid,
        X_ORIGINAL_WORD => p_word_replacement_rec.ORIGINAL_WORD,
        X_REPLACEMENT_WORD => p_word_replacement_rec.REPLACEMENT_WORD,
        X_TYPE => p_word_replacement_rec.TYPE,
        X_COUNTRY_CODE => p_word_replacement_rec.COUNTRY_CODE,
        X_LAST_UPDATE_DATE => hz_utility_pub.LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
        X_CREATION_DATE => hz_utility_pub.CREATION_DATE,
        X_CREATED_BY => hz_utility_pub.CREATED_BY,
        X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
        X_ATTRIBUTE_CATEGORY => p_word_replacement_rec.ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => p_word_replacement_rec.ATTRIBUTE1,
        X_ATTRIBUTE2 => p_word_replacement_rec.ATTRIBUTE2,
        X_ATTRIBUTE3 => p_word_replacement_rec.ATTRIBUTE3,
        X_ATTRIBUTE4 => p_word_replacement_rec.ATTRIBUTE4,
        X_ATTRIBUTE5 => p_word_replacement_rec.ATTRIBUTE5,
        X_ATTRIBUTE6 => p_word_replacement_rec.ATTRIBUTE6,
        X_ATTRIBUTE7 => p_word_replacement_rec.ATTRIBUTE7,
        X_ATTRIBUTE8 => p_word_replacement_rec.ATTRIBUTE8,
        X_ATTRIBUTE9 => p_word_replacement_rec.ATTRIBUTE9,
        X_ATTRIBUTE10 => p_word_replacement_rec.ATTRIBUTE10,
        X_ATTRIBUTE11 => p_word_replacement_rec.ATTRIBUTE11,
        X_ATTRIBUTE12 => p_word_replacement_rec.ATTRIBUTE12,
        X_ATTRIBUTE13 => p_word_replacement_rec.ATTRIBUTE13,
	X_ATTRIBUTE14 => p_word_replacement_rec.ATTRIBUTE14,
        X_ATTRIBUTE15 => p_word_replacement_rec.ATTRIBUTE15
	);


END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              do_update_word_replacement                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Updates word replacement. 	                             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_word_replacement_rec                                 |
 |                    p_last_update_date           	                     |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   14-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

procedure do_update_word_replacement(
        p_word_replacement_rec         IN      WORD_REPLACEMENT_REC_TYPE,
        p_last_update_date             IN OUT  NOCOPY DATE,
	x_return_status		       IN OUT  NOCOPY VARCHAR2
) IS
        l_last_update_date              DATE;
        l_rowid                         ROWID;
BEGIN

--Check whether last_update_date has been passed in.
  IF p_last_update_date IS NULL OR
        p_last_update_date = FND_API.G_MISS_DATE THEN

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'word replacement last update date');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
  END IF;


--Call for validations.
  validate_word_replacement(p_word_replacement_rec, 'U', x_return_status);

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;


--Pass back last_update_date.
	p_last_update_date := hz_utility_pub.LAST_UPDATE_DATE;

--Select rowid.
        select rowid INTO l_rowid FROM hz_word_replacements
        WHERE original_word = p_word_replacement_rec.original_word
        AND   type = p_word_replacement_rec.type;

--Call to table-handler.

	HZ_WORD_REPLACEMENTS_PKG.UPDATE_ROW(
        X_Rowid => l_Rowid,
        X_ORIGINAL_WORD => p_word_replacement_rec.ORIGINAL_WORD,
        X_REPLACEMENT_WORD => p_word_replacement_rec.REPLACEMENT_WORD,
        X_TYPE => p_word_replacement_rec.TYPE,
        X_COUNTRY_CODE => p_word_replacement_rec.COUNTRY_CODE,
	X_LAST_UPDATE_DATE => hz_utility_pub.LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
        X_CREATION_DATE => FND_API.G_MISS_DATE,
        X_CREATED_BY => FND_API.G_MISS_NUM,
        X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
        X_ATTRIBUTE_CATEGORY => p_word_replacement_rec.ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => p_word_replacement_rec.ATTRIBUTE1,
        X_ATTRIBUTE2 => p_word_replacement_rec.ATTRIBUTE2,
        X_ATTRIBUTE3 => p_word_replacement_rec.ATTRIBUTE3,
        X_ATTRIBUTE4 => p_word_replacement_rec.ATTRIBUTE4,
        X_ATTRIBUTE5 => p_word_replacement_rec.ATTRIBUTE5,
        X_ATTRIBUTE6 => p_word_replacement_rec.ATTRIBUTE6,
        X_ATTRIBUTE7 => p_word_replacement_rec.ATTRIBUTE7,
        X_ATTRIBUTE8 => p_word_replacement_rec.ATTRIBUTE8,
        X_ATTRIBUTE9 => p_word_replacement_rec.ATTRIBUTE9,
        X_ATTRIBUTE10 => p_word_replacement_rec.ATTRIBUTE10,
        X_ATTRIBUTE11 => p_word_replacement_rec.ATTRIBUTE11,
        X_ATTRIBUTE12 => p_word_replacement_rec.ATTRIBUTE12,
        X_ATTRIBUTE13 => p_word_replacement_rec.ATTRIBUTE13,
        X_ATTRIBUTE14 => p_word_replacement_rec.ATTRIBUTE14,
        X_ATTRIBUTE15 => p_word_replacement_rec.ATTRIBUTE15
	);

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              validate_word_replacement                             	     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Validates word replacements. Checks for:                     |
 |                      uniqueness                                           |
 |                      lookup types                                         |
 |                      mandatory columns                                    |
 |                      non-updateable fields                                |
 |                      foreign key validations                              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                      p_word_replacement_rec                               |
 |                      create_update_flag                                   |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Rashmi Goyal   02-SEP-99  Created                                      |
 |                                                                           |
 +===========================================================================*/

procedure validate_word_replacement(
        p_word_replacement_rec 	IN      word_replacement_rec_type,
        create_update_flag      IN      VARCHAR2,
	x_return_status		IN OUT	NOCOPY VARCHAR2
) IS
  CURSOR c_dup_rec (X_Original_Word IN VARCHAR2,
                    X_Type          IN VARCHAR2
                   )
  IS
    SELECT 1
    FROM   hz_word_replacements
    WHERE  original_word = X_Original_Word
    AND    type = X_Type;
  l_dup_rec   c_dup_rec%ROWTYPE;
  l_count                 	NUMBER;
BEGIN

--Check for mandatory, but updateable columns
  IF (create_update_flag = 'C' AND (p_word_replacement_rec.original_word = FND_API.G_MISS_CHAR OR
  p_word_replacement_rec.original_word IS NULL)) OR (create_update_flag = 'U' AND
  p_word_replacement_rec.original_word IS NULL) THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'original_word');
        FND_MSG_PUB.ADD;
	x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (create_update_flag = 'C' AND (p_word_replacement_rec.type = FND_API.G_MISS_CHAR OR
  p_word_replacement_rec.type IS NULL)) OR (create_update_flag = 'U' AND
  p_word_replacement_rec.type IS NULL) THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'type');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


-- Check for lookup values for type field
  SELECT COUNT(*) INTO l_count
  FROM   ar_lookups
  WHERE  lookup_type = 'HZ_WORD_REPLACEMENT_TYPE'
  AND    lookup_code = p_word_replacement_rec.type;

  IF l_count = 0 THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_LOOKUP');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'type');
                FND_MESSAGE.SET_TOKEN('LOOKUP_TYPE', 'HZ_WORD_REPLACEMENT_TYPE');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


--Check FK validations for country_code.
    IF p_word_replacement_rec.country_code IS NOT NULL
    AND p_word_replacement_rec.country_code <> FND_API.G_MISS_CHAR THEN
      SELECT COUNT(*) INTO l_count
      FROM fnd_territories
      WHERE territory_code = p_word_replacement_rec.country_code;

      IF l_count = 0 THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
                FND_MESSAGE.SET_TOKEN('FK', 'country_code');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'territory_code');
                FND_MESSAGE.SET_TOKEN('TABLE', 'fnd_territories');
                FND_MSG_PUB.ADD;
	        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

-- Check for duplicate record
    IF create_update_flag = 'C'
    THEN
      open c_dup_rec (p_word_replacement_rec.original_word, p_word_replacement_rec.type);
      fetch c_dup_rec into l_dup_rec;
      if c_dup_rec%FOUND then
        fnd_message.set_name ('AR', 'HZ_MATCHING_RULE_EXISTS');
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
    END IF;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              get_current_word_replacement                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Gets current record. 			                     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_original_word					     |
 |                    p_type                                                 |
 |              OUT:                                                         |
 |                    x_word_replacement_rec				     |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Indrajit Sen   14-JUN-00  Created                                      |
 |                                                                           |
 +===========================================================================*/

procedure get_current_word_replacement(
        p_original_word         IN      VARCHAR2,
        p_type                  IN      VARCHAR2,
        x_word_replacement_rec  OUT     NOCOPY WORD_REPLACEMENT_REC_TYPE
) IS
                LAST_UPDATE_DATE        DATE;
                LAST_UPDATED_BY         NUMBER;
                CREATION_DATE           DATE;
                CREATED_BY              NUMBER;
                LAST_UPDATE_LOGIN       NUMBER;

BEGIN

  SELECT
   ORIGINAL_WORD,
   REPLACEMENT_WORD,
   TYPE,
   COUNTRY_CODE,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_LOGIN,
   ATTRIBUTE_CATEGORY,
   ATTRIBUTE1,
   ATTRIBUTE2,
   ATTRIBUTE3,
   ATTRIBUTE4,
   ATTRIBUTE5,
   ATTRIBUTE6,
   ATTRIBUTE7,
   ATTRIBUTE8,
   ATTRIBUTE9,
   ATTRIBUTE10,
   ATTRIBUTE11,
   ATTRIBUTE12,
   ATTRIBUTE13,
   ATTRIBUTE14,
   ATTRIBUTE15
  INTO
   x_word_replacement_rec.ORIGINAL_WORD,
   x_word_replacement_rec.REPLACEMENT_WORD,
   x_word_replacement_rec.TYPE,
   x_word_replacement_rec.COUNTRY_CODE,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_LOGIN,
   x_word_replacement_rec.ATTRIBUTE_CATEGORY,
   x_word_replacement_rec.ATTRIBUTE1,
   x_word_replacement_rec.ATTRIBUTE2,
   x_word_replacement_rec.ATTRIBUTE3,
   x_word_replacement_rec.ATTRIBUTE4,
   x_word_replacement_rec.ATTRIBUTE5,
   x_word_replacement_rec.ATTRIBUTE6,
   x_word_replacement_rec.ATTRIBUTE7,
   x_word_replacement_rec.ATTRIBUTE8,
   x_word_replacement_rec.ATTRIBUTE9,
   x_word_replacement_rec.ATTRIBUTE10,
   x_word_replacement_rec.ATTRIBUTE11,
   x_word_replacement_rec.ATTRIBUTE12,
   x_word_replacement_rec.ATTRIBUTE13,
   x_word_replacement_rec.ATTRIBUTE14,
   x_word_replacement_rec.ATTRIBUTE15
  FROM hz_word_replacements
  WHERE original_word = p_original_word
  AND   type = p_type;

END;

END HZ_WORD_REPLACEMENT_PUB;

/
