--------------------------------------------------------
--  DDL for Package Body HZ_ADAPTER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ADAPTER_PUB" AS
/*$Header: ARHADPUB.pls 115.1 2003/09/02 21:41:50 acng noship $*/

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
         RETURN VARCHAR2;

PROCEDURE create_adapter (
   p_adapter_rec               IN  adapter_rec_type
  ,x_adapter_id                OUT NOCOPY    NUMBER
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS
  l_rowid         VARCHAR2(64);
  l_adapter_rec   adapter_rec_type;
BEGIN

   savepoint create_adapter_pub;
   FND_MSG_PUB.initialize;

   l_adapter_rec := p_adapter_rec;

   --Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   validate_adapter(
      p_create_update_flag        => 'C'
     ,p_adapter_rec               => l_adapter_rec
     ,x_return_status             => x_return_status );

   IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   ELSIF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   HZ_ADAPTERS_PKG.Insert_Row (
      x_adapter_id                     => l_adapter_rec.adapter_id
     ,x_adapter_content_source         => l_adapter_rec.adapter_content_source
     ,x_enabled_flag                   => l_adapter_rec.enabled_flag
     ,x_synchronous_flag               => l_adapter_rec.synchronous_flag
     ,x_invoke_method_code             => l_adapter_rec.invoke_method_code
     ,x_message_format_code            => l_adapter_rec.message_format_code
     ,x_host_address                   => l_adapter_rec.host_address
     ,x_username                       => l_adapter_rec.username
     ,x_encrypted_password             => l_adapter_rec.encrypted_password
     ,x_maximum_batch_size             => l_adapter_rec.maximum_batch_size
     ,x_default_batch_size             => l_adapter_rec.default_batch_size
     ,x_default_replace_status_level   => l_adapter_rec.default_replace_status_level
     ,x_object_version_number          => 1 );

   x_adapter_id := l_adapter_rec.adapter_id;

   -- insert new lookup code into CONTENT_SOURCE_TYPE
   FND_LOOKUP_VALUES_PKG.INSERT_ROW(
      x_rowid               => l_rowid,
      x_lookup_type         => 'CONTENT_SOURCE_TYPE',
      x_security_group_id   => 0,
      x_view_application_id => 222,
      x_lookup_code         => l_adapter_rec.adapter_content_source,
      x_enabled_flag        => 'Y',
      x_start_date_active   => sysdate,
      x_end_date_active     => null,
      x_territory_code      => null,
      x_tag                 => null,
      x_attribute_category  => null,
      x_attribute1          => null,
      x_attribute2          => null,
      x_attribute3          => null,
      x_attribute4          => null,
      x_attribute5          => null,
      x_attribute6          => null,
      x_attribute7          => null,
      x_attribute8          => null,
      x_attribute9          => null,
      x_attribute10         => null,
      x_attribute11         => null,
      x_attribute12         => null,
      x_attribute13         => null,
      x_attribute14         => null,
      x_attribute15         => sysdate,
      x_meaning             => l_adapter_rec.adapter_meaning,
      x_description         => l_adapter_rec.adapter_description,
      x_creation_date       => hz_utility_v2pub.creation_date,
      x_created_by          => hz_utility_v2pub.created_by,
      x_last_update_date    => hz_utility_v2pub.last_update_date,
      x_last_updated_by     => hz_utility_v2pub.last_updated_by,
      x_last_update_login   => hz_utility_v2pub.last_update_login );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_adapter_pub;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_adapter_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO create_adapter_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
END create_adapter;

-- This procedure create a record in location adapter territory by passing
-- location adapter territory record type
PROCEDURE create_adapter_terr (
   p_adapter_terr_rec          IN adapter_terr_rec_type
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

BEGIN

   savepoint create_adapter_terr_pub;
   FND_MSG_PUB.initialize;

   --Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   validate_adapter_terr(
      p_create_update_flag        => 'C'
     ,p_adapter_terr_rec          => p_adapter_terr_rec
     ,x_return_status             => x_return_status );

   IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   ELSIF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   HZ_ADAPTER_TERRITORIES_PKG.Insert_Row (
      x_adapter_id                     => p_adapter_terr_rec.adapter_id
     ,x_territory_code                 => p_adapter_terr_rec.territory_code
     ,x_enabled_flag                   => p_adapter_terr_rec.enabled_flag
     ,x_default_flag                   => p_adapter_terr_rec.default_flag
     ,x_object_version_number          => 1 );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_adapter_terr_pub;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_adapter_terr_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO create_adapter_terr_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
END create_adapter_terr;

-- This procedure update a record in location adapater
PROCEDURE update_adapter (
   p_adapter_rec               IN adapter_rec_type
  ,px_object_version_number    IN OUT NOCOPY NUMBER
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS
   l_object_version_number     NUMBER;
   l_rowid                     ROWID := NULL;
   l_adapter_content_source    VARCHAR2(30);
   l_adapter_id                NUMBER;
BEGIN

   savepoint update_adapter_pub;
   FND_MSG_PUB.initialize;

   --Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Lock record.
   BEGIN

     l_adapter_id := p_adapter_rec.adapter_id;

     SELECT ROWID, OBJECT_VERSION_NUMBER
     INTO l_rowid, l_object_version_number
     FROM HZ_ADAPTERS
     WHERE ADAPTER_ID = l_adapter_id
     FOR UPDATE NOWAIT;

     IF NOT (
       ( px_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
       ( px_object_version_number IS NOT NULL AND
         l_object_version_number IS NOT NULL AND
         px_object_version_number = l_object_version_number ) )
     THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
       FND_MESSAGE.SET_TOKEN( 'TABLE', 'HZ_ADAPTERS' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     px_object_version_number := NVL(l_object_version_number,1)+1;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
       FND_MESSAGE.SET_TOKEN( 'RECORD', 'Adapter' );
       FND_MESSAGE.SET_TOKEN( 'VALUE', l_adapter_id);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
   END;

   validate_adapter(
      p_create_update_flag        => 'U'
     ,p_adapter_rec               => p_adapter_rec
     ,x_return_status             => x_return_status );

   IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   ELSIF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   HZ_ADAPTERS_PKG.Update_Row(
      x_rowid                          => l_rowid
     ,x_adapter_id                     => p_adapter_rec.adapter_id
     ,x_adapter_content_source         => p_adapter_rec.adapter_content_source
     ,x_enabled_flag                   => p_adapter_rec.enabled_flag
     ,x_synchronous_flag               => p_adapter_rec.synchronous_flag
     ,x_invoke_method_code             => p_adapter_rec.invoke_method_code
     ,x_message_format_code            => p_adapter_rec.message_format_code
     ,x_host_address                   => p_adapter_rec.host_address
     ,x_username                       => p_adapter_rec.username
     ,x_encrypted_password             => p_adapter_rec.encrypted_password
     ,x_maximum_batch_size             => p_adapter_rec.maximum_batch_size
     ,x_default_batch_size             => p_adapter_rec.default_batch_size
     ,x_default_replace_status_level   => p_adapter_rec.default_replace_status_level
     ,x_object_version_number          => px_object_version_number );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO update_adapter_pub;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_adapter_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO update_adapter_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
END update_adapter;

-- This procedure update a record in location adapter territory
PROCEDURE update_adapter_terr (
   p_adapter_terr_rec          IN adapter_terr_rec_type
  ,px_object_version_number    IN OUT NOCOPY NUMBER
  ,x_return_status             OUT NOCOPY  VARCHAR2
  ,x_msg_count                 OUT NOCOPY  NUMBER
  ,x_msg_data                  OUT NOCOPY  VARCHAR2
) IS
   l_rowid                       ROWID := NULL;
   l_object_version_number       NUMBER;
   l_adapter_id                  NUMBER;
   l_territory_code              VARCHAR2(30);
BEGIN

   savepoint update_adapter_terr_pub;
   FND_MSG_PUB.initialize;

   --Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Lock record.
   BEGIN

     l_adapter_id := p_adapter_terr_rec.adapter_id;
     l_territory_code := p_adapter_terr_rec.territory_code;

     SELECT ROWID, OBJECT_VERSION_NUMBER
     INTO l_rowid, l_object_version_number
     FROM HZ_ADAPTER_TERRITORIES
     WHERE ADAPTER_ID = l_adapter_id
     AND TERRITORY_CODE = l_territory_code
     FOR UPDATE NOWAIT;

     IF NOT (
       ( px_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
       ( px_object_version_number IS NOT NULL AND
         l_object_version_number IS NOT NULL AND
         px_object_version_number = l_object_version_number ) )
     THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
       FND_MESSAGE.SET_TOKEN( 'TABLE', 'HZ_ADAPTERS' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     px_object_version_number := NVL(l_object_version_number,1)+1;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
       FND_MESSAGE.SET_TOKEN( 'RECORD', 'Adapter' );
       FND_MESSAGE.SET_TOKEN( 'VALUE', l_adapter_id);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
   END;

   validate_adapter_terr(
      p_create_update_flag        => 'U'
     ,p_adapter_terr_rec          => p_adapter_terr_rec
     ,x_return_status             => x_return_status );

   IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   ELSIF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   HZ_ADAPTER_TERRITORIES_PKG.Update_Row(
      x_rowid                   => l_rowid
     ,x_adapter_id              => p_adapter_terr_rec.adapter_id
     ,x_territory_code          => p_adapter_terr_rec.territory_code
     ,x_enabled_flag            => p_adapter_terr_rec.enabled_flag
     ,x_default_flag            => p_adapter_terr_rec.default_flag
     ,x_object_version_number   => px_object_version_number );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO update_adapter_terr_pub;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_adapter_terr_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO update_adapter_terr_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
END update_adapter_terr;

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE
) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put(fnd_file.log,message);
  END IF;
END log;

/*-----------------------------------------------------------------------
 | Function to fetch messages of the stack and log the error
 | Also returns the error
 |-----------------------------------------------------------------------*/
FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  IF (SQLERRM IS NOT NULL) THEN
    l_msg_data := l_msg_data || SQLERRM;
  END IF;
  log(l_msg_data);
  RETURN l_msg_data;
END logerror;

PROCEDURE validate_adapter(
   p_create_update_flag        IN VARCHAR2,
   p_adapter_rec               IN adapter_rec_type,
   x_return_status             IN OUT NOCOPY VARCHAR2
) IS

   l_dummy                     VARCHAR2(1);
   l_adapter_content_source    VARCHAR2(30);
   l_message_format_code       VARCHAR2(30);
   l_invoke_method_code        VARCHAR2(30);
   l_maximum_batch_size        NUMBER;
   l_default_batch_size        NUMBER;

   CURSOR check_lookup(l_lookup_code VARCHAR2, l_lookup_type VARCHAR2) IS
   select 'X'
   from AR_LOOKUPS
   where lookup_type = l_lookup_type
   and lookup_code = l_lookup_code;

BEGIN

   l_adapter_content_source := p_adapter_rec.adapter_content_source;
   l_message_format_code    := p_adapter_rec.message_format_code;
   l_invoke_method_code     := p_adapter_rec.invoke_method_code;
   l_maximum_batch_size     := p_adapter_rec.maximum_batch_size;
   l_default_batch_size     := p_adapter_rec.default_batch_size;

   -- check not null first
   IF(l_adapter_content_source IS NULL OR l_adapter_content_source = FND_API.G_MISS_CHAR) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'ADAPTER_CONTENT_SOURCE');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(l_message_format_code IS NULL OR l_message_format_code = FND_API.G_MISS_CHAR) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'MESSAGE_FORMAT_CODE');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(l_invoke_method_code IS NULL OR l_invoke_method_code = FND_API.G_MISS_CHAR) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'INVOKE_METHOD_CODE');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(l_maximum_batch_size IS NULL OR l_maximum_batch_size = FND_API.G_MISS_NUM) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'MAXIMUM_BATCH_SIZE');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(l_default_batch_size IS NULL OR l_default_batch_size = FND_API.G_MISS_NUM) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'DEFAULT_BATCH_SIZE');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- check adapter_content_source
   IF(p_create_update_flag = 'C') THEN
     OPEN check_lookup(l_adapter_content_source, 'CONTENT_SOURCE_TYPE');
     FETCH check_lookup INTO l_dummy;
     -- if found, then raise error saying already exist
     IF(check_lookup%FOUND) THEN
       -- error saying that content source already exist
       FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_DUP_ADPT');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE check_lookup;
   ELSIF(p_create_update_flag = 'U') THEN
     OPEN check_lookup(l_adapter_content_source, 'CONTENT_SOURCE_TYPE');
     FETCH check_lookup INTO l_dummy;
     IF(check_lookup%NOTFOUND) THEN
       -- error saying that content source not found
       FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_INVALID_ADAPTER');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE check_lookup;
   END IF;

   -- check message_format_code
   OPEN check_lookup(l_message_format_code, 'HZ_MESSAGE_FORMAT');
   FETCH check_lookup INTO l_dummy;
   IF(check_lookup%NOTFOUND) THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_LOOKUP');
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'MESSAGE_FORMAT_CODE');
     FND_MESSAGE.SET_TOKEN('LOOKUP_TYPE' , 'HZ_MESSAGE_FORMAT');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE check_lookup;

   -- check invoke_method_code
   OPEN check_lookup(l_invoke_method_code, 'HZ_INVOKE_METHOD');
   FETCH check_lookup INTO l_dummy;
   IF(check_lookup%NOTFOUND) THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_LOOKUP');
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'INVOKE_METHOD_CODE');
     FND_MESSAGE.SET_TOKEN('LOOKUP_TYPE' , 'HZ_INVOKE_METHOD');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE check_lookup;

   -- check maximum_batch_size and default_batch_size
   IF((l_maximum_batch_size < 1) OR (l_default_batch_size < 1))THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_INVALID_BATCH_SIZE');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
END validate_adapter;

PROCEDURE validate_adapter_terr(
   p_create_update_flag        IN VARCHAR2,
   p_adapter_terr_rec          IN adapter_terr_rec_type,
   x_return_status             IN OUT NOCOPY VARCHAR2
) IS

   l_dummy                     VARCHAR2(1);
   l_adapter_id                NUMBER;
   l_territory_code            VARCHAR2(30);
   l_enabled_flag              VARCHAR2(1);
   l_default_flag              VARCHAR2(1);

   CURSOR check_adapter(l_adapter_id NUMBER) IS
   select 'X'
   from HZ_ADAPTERS
   where adapter_id = l_adapter_id;

   CURSOR check_terr(l_territory_code VARCHAR2) IS
   select 'X'
   from FND_TERRITORIES
   where territory_code = l_territory_code;

   CURSOR check_terr_default(l_adapter_id NUMBER, l_territory_code VARCHAR2) IS
   select 'X'
   from HZ_ADAPTERS la, HZ_ADAPTER_TERRITORIES lat
   where la.adapter_id = lat.adapter_id
   and lat.default_flag = 'Y'
   and lat.enabled_flag = 'Y'
   and lat.territory_code = l_territory_code
   and la.adapter_id <> l_adapter_id;

BEGIN

   l_adapter_id             := p_adapter_terr_rec.adapter_id;
   l_territory_code         := p_adapter_terr_rec.territory_code;
   l_enabled_flag           := p_adapter_terr_rec.enabled_flag;
   l_default_flag           := p_adapter_terr_rec.default_flag;

   -- check not null
   IF(l_adapter_id IS NULL OR l_adapter_id = FND_API.G_MISS_NUM) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'ADAPTER_ID');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF(l_territory_code IS NULL OR l_territory_code = FND_API.G_MISS_CHAR) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'TERRITORY_CODE');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- if create a loc adapter territory, it can't be disabled and set to default 'Y'
   -- give message saying that this setting is not allowed
   IF((l_enabled_flag = 'N') AND (l_default_flag = 'Y')) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'TERRITORY_CODE');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- check adapter_content_source
   -- if not found, then raise error saying adapter_content_source not exist
   OPEN check_adapter(l_adapter_id);
   FETCH check_adapter INTO l_dummy;
   IF(check_adapter%NOTFOUND) THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_INVALID_ADAPTER');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE check_adapter;

   -- check territory_code
   -- if not found, then raise error saying territory_code not exist
   OPEN check_terr(l_territory_code);
   FETCH check_terr INTO l_dummy;
   IF(check_terr%NOTFOUND) THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_INVALID_TERRITORY');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE check_terr;

   -- check default flag for this country.  Only one active default adapter for each country
   IF(l_default_flag = 'Y') THEN
     OPEN check_terr_default(l_adapter_id, l_territory_code);
     FETCH check_terr_default INTO l_dummy;
     IF(check_terr_default%FOUND) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_INVALID_DEFAULT');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE check_terr_default;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;

END validate_adapter_terr;

END HZ_ADAPTER_PUB;

/
