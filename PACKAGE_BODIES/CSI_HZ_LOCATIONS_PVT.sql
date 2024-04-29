--------------------------------------------------------
--  DDL for Package Body CSI_HZ_LOCATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_HZ_LOCATIONS_PVT" AS
/* $Header: csivhzlb.pls 120.2 2005/12/09 16:32:36 rmamidip noship $ */
-- Start of Comments
-- Package name     : CSI_HZ_LOCATIONS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call

g_pkg_name  CONSTANT VARCHAR2(30) := 'csi_hz_locations_pvt';
g_file_name CONSTANT VARCHAR2(12) := 'csivhzlb.pls';

--+=================================================================+
--| Create_location procedure written for calling it from CSI forms |
--| This procedure validates for unique clli_code and calls         |
--| hz_location_v2pub.create_location                                 |
--+=================================================================+

PROCEDURE create_location(
    p_api_version                IN   NUMBER  ,
    p_commit                     IN   VARCHAR2   := fnd_api.g_false,
    p_init_msg_list              IN   VARCHAR2   := fnd_api.g_false,
    p_validation_level           IN   NUMBER     := fnd_api.g_valid_level_full,
    p_country                    IN   VARCHAR2,
    p_address1                   IN   VARCHAR2,
    p_address2                   IN   VARCHAR2,
    p_address3                   IN   VARCHAR2,
    p_address4                   IN   VARCHAR2,
    p_city                       IN   VARCHAR2,
    p_postal_code                IN   VARCHAR2,
    p_state                      IN   VARCHAR2,
    p_province                   IN   VARCHAR2,
    p_county                     IN   VARCHAR2,
    p_clli_code                  IN   VARCHAR2,
    p_description                IN   VARCHAR2,
    p_last_update_date           IN   DATE    ,
    p_last_updated_by            IN   NUMBER  ,
    p_creation_date              IN   DATE    ,
    p_created_by                 IN   NUMBER  ,
    p_created_by_module          IN   VARCHAR2,
    x_location_id                OUT NOCOPY  NUMBER  ,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER  ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    ) IS
l_api_name                   CONSTANT VARCHAR2(30) := 'create_location';
l_api_version                CONSTANT NUMBER       := 1.0;
l_location_rec                        HZ_LOCATION_v2PUB.LOCATION_REC_TYPE;
l_location_id                         NUMBER;
l_debug_level                         NUMBER;
l_dummy                               VARCHAR2(1);

BEGIN
   SAVEPOINT create_location_pvt;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;

      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        -- if debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
         csi_gen_utility_pvt.put_line( 'create_location');
    END IF;

    -- if the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
              csi_gen_utility_pvt.put_line(
                p_api_version             ||'-'||
                p_commit                  ||'-'||
                p_init_msg_list           ||'-'||
                p_validation_level        ||'-'||
                p_country                 ||'-'||
                p_address1                ||'-'||
                p_address2                ||'-'||
                p_address3                ||'-'||
                p_address4                ||'-'||
                p_city                    ||'-'||
                p_postal_code             ||'-'||
                p_state                   ||'-'||
                p_province                ||'-'||
                p_county                  ||'-'||
                p_clli_code               ||'-'||
                p_created_by_module);
    END IF;

  l_location_rec.country             := p_country ;
  l_location_rec.address1            := p_address1;
  l_location_rec.address2            := p_address2;
  l_location_rec.address3            := p_address3;
  l_location_rec.address4            := p_address4;
  l_location_rec.city                := p_city;
  l_location_rec.postal_code         := p_postal_code;
  l_location_rec.state               := p_state;
  l_location_rec.province            := p_province;
  l_location_rec.county              := p_county;
  l_location_rec.content_source_type := 'USER_ENTERED';
  l_location_rec.clli_code           := p_clli_code;
  l_location_rec.description         := p_description;
  l_location_rec.created_by_module   := p_created_by_module;

-- Now call the stored program

       IF l_location_rec.clli_code IS NOT NULL AND
           l_location_rec.clli_code <> FND_API.G_MISS_CHAR THEN
       BEGIN
          SELECT  'x'
          INTO    l_dummy
          FROM    hz_locations
          WHERE   clli_code = l_location_rec.clli_code;

          fnd_message.set_name('CSI', 'CSI_DUPLICATE_CLLI_CODE');
          fnd_message.set_token('PARAMETER',l_location_rec.clli_code);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
       EXCEPTION
         WHEN TOO_MANY_ROWS THEN
           fnd_message.set_name('CSI', 'CSI_DUPLICATE_CLLI_CODE');
           fnd_message.set_token('PARAMETER',l_location_rec.clli_code);
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
         WHEN NO_DATA_FOUND THEN
           NULL;
       END;
       END IF;

      hz_location_v2pub.create_location(p_init_msg_list     => p_init_msg_list
                                  ,p_location_rec      => l_location_rec
                                  ,x_location_id       => x_location_id
                                  ,x_return_status     => x_return_status
                                  ,x_msg_count         => x_msg_count
                                  ,x_msg_data          => x_msg_data);

      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
 WHEN fnd_api.g_exc_error THEN
   ROLLBACK TO create_location_pvt;
     x_return_status := fnd_api.g_ret_sts_error ;
       fnd_msg_pub.count_and_get
            (p_count => x_msg_count ,
             p_data  => x_msg_data
             );
END create_location;


--+=================================================================+
--| Update_location procedure written for calling it from CSI forms |
--| This procedure validates for unique clli_code and calls         |
--| hz_location_v2pub.update_location                                 |
--+=================================================================+

PROCEDURE update_location(
    p_api_version                IN   NUMBER,
    p_commit                     IN   VARCHAR2   := fnd_api.g_false,
    p_init_msg_list              IN   VARCHAR2   := fnd_api.g_false,
    p_validation_level           IN   NUMBER     := fnd_api.g_valid_level_full,
    p_location_id                IN   NUMBER,
    p_country                    IN   VARCHAR2,
    p_address1                   IN   VARCHAR2,
    p_address2                   IN   VARCHAR2,
    p_address3                   IN   VARCHAR2,
    p_address4                   IN   VARCHAR2,
    p_city                       IN   VARCHAR2,
    p_postal_code                IN   VARCHAR2,
    p_state                      IN   VARCHAR2,
    p_province                   IN   VARCHAR2,
    p_county                     IN   VARCHAR2,
    p_clli_code                  IN   VARCHAR2,
    p_description                IN   VARCHAR2,
    p_last_update_date           IN   DATE    ,
    p_last_updated_by            IN   NUMBER  ,
    p_creation_date              IN   DATE    ,
    p_created_by                 IN   NUMBER  ,
    p_created_by_module          IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER  ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    ) IS
l_api_name                   CONSTANT VARCHAR2(30) := 'update_location';
l_api_version                CONSTANT NUMBER       := 1.0;
l_location_rec                        HZ_LOCATION_v2PUB.LOCATION_REC_TYPE;
l_location_id                         NUMBER;
l_debug_level                         NUMBER;
l_object_version_number               number;
l_dummy                               VARCHAR2(1);
BEGIN

   SAVEPOINT update_location_pvt;

      -- standard call TO check FOR call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list IF p_init_msg_list IS set TO true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;

      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        -- if debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
         csi_gen_utility_pvt.put_line( 'update_location');
    END IF;

    -- IF the debug level = 2 THEN dump all the parameters values.
    IF (l_debug_level > 1) THEN
              csi_gen_utility_pvt.put_line(
                p_api_version             ||'-'||
                p_commit                  ||'-'||
                p_init_msg_list           ||'-'||
                p_validation_level        ||'-'||
                p_location_id             ||'-'||
                p_country                 ||'-'||
                p_address1                ||'-'||
                p_address2                ||'-'||
                p_address3                ||'-'||
                p_address4                ||'-'||
                p_city                    ||'-'||
                p_postal_code             ||'-'||
                p_state                   ||'-'||
                p_province                ||'-'||
                p_county                  ||'-'||
                p_clli_code               ||'-'||
                p_created_by_module);
    END IF;

  l_location_rec.location_id         := p_location_id;
  l_location_rec.country             := p_country ;
  l_location_rec.address1            := p_address1;
  l_location_rec.address2            := p_address2;
  l_location_rec.address3            := p_address3;
  l_location_rec.address4            := p_address4;
  l_location_rec.city                := p_city;
  l_location_rec.postal_code         := p_postal_code;
  l_location_rec.state               := p_state;
  l_location_rec.province            := p_province;
  l_location_rec.county              := p_county;
  l_location_rec.clli_code           := p_clli_code;
  l_location_rec.description         := p_description;
  l_location_rec.created_by_module   := p_created_by_module;


-- Now call the stored program



       IF p_location_id IS NULL OR
          p_location_id = FND_API.G_MISS_NUM THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'location id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

       BEGIN
           SELECT object_version_number
           INTO   l_object_version_number
           FROM   hz_locations
           WHERE  location_id = l_location_rec.location_id;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
              FND_MESSAGE.SET_TOKEN('RECORD', 'location');
              FND_MESSAGE.SET_TOKEN('VALUE', to_char(l_location_rec.location_id));
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
       END;

       IF l_location_rec.clli_code IS NOT NULL AND
           l_location_rec.clli_code <> FND_API.G_MISS_CHAR THEN
       BEGIN
          SELECT  'x'
          INTO    l_dummy
          FROM    hz_locations
          WHERE   clli_code = l_location_rec.clli_code
          AND     location_id <> l_location_rec.location_id;
          fnd_message.set_name('CSI', 'CSI_DUPLICATE_CLLI_CODE');
          fnd_message.set_token('PARAMETER',l_location_rec.clli_code);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
       EXCEPTION
          WHEN TOO_MANY_ROWS THEN
           fnd_message.set_name('CSI', 'CSI_DUPLICATE_CLLI_CODE');
           fnd_message.set_token('PARAMETER',l_location_rec.clli_code);
           fnd_msg_pub.add;
           RAISE fnd_api.g_exc_error;
          WHEN NO_DATA_FOUND THEN
            NULL;
       END;
       END IF;

  -- Now call the stored program

  hz_location_v2pub.update_location(p_init_msg_list     => p_init_msg_list
                                  ,p_location_rec      => l_location_rec
                                  ,p_object_version_number => l_object_version_number
                                  ,x_return_status     => x_return_status
                                  ,x_msg_count         => x_msg_count
                                  ,x_msg_data          => x_msg_data
                                  );



      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
 WHEN fnd_api.g_exc_error THEN
   ROLLBACK TO update_location_pvt;
     x_return_status := fnd_api.g_ret_sts_error ;
       fnd_msg_pub.count_and_get
            (p_count => x_msg_count ,
             p_data  => x_msg_data
             );
END update_location;

--+=================================================================+
--| Lock_location procedure written for calling it from CSI forms   |
--+=================================================================+

PROCEDURE Lock_location(
    p_location_id                   NUMBER  ,
    p_last_update_date              DATE    ,
    p_last_updated_by               NUMBER  ,
    p_creation_date                 DATE    ,
    p_created_by                    NUMBER  ,
    p_country                       VARCHAR2,
    p_address1                      VARCHAR2,
    p_address2                      VARCHAR2,
    p_address3                      VARCHAR2,
    p_address4                      VARCHAR2,
    p_city                          VARCHAR2,
    p_postal_code                   VARCHAR2,
    p_state                         VARCHAR2,
    p_province                      VARCHAR2,
    p_county                        VARCHAR2,
    p_clli_code                     VARCHAR2,
    p_description                   VARCHAR2,
    p_created_by_module             VARCHAR2
    )
   IS
   CURSOR C IS
        SELECT *
          FROM hz_locations
         WHERE location_id = p_location_id
         FOR UPDATE of location_id NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;

    if (
           (    ( recinfo.location_id = p_location_id)
            OR (    ( recinfo.location_id IS NULL )
                AND (  p_location_id IS NULL )))
       AND (    ( recinfo.last_update_date = p_last_update_date)
            OR (    ( recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( recinfo.last_updated_by = p_last_updated_by)
            OR (    ( recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( recinfo.creation_date = p_creation_date)
            OR (    ( recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( recinfo.created_by = p_created_by)
            OR (    ( recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( recinfo.country = p_country)
            OR (    ( recinfo.country IS NULL )
                AND (  p_country IS NULL )))
       AND (    ( recinfo.address1 = p_address1)
            OR (    ( recinfo.address1 IS NULL )
                AND (  p_address1 IS NULL )))
       AND (    ( recinfo.address2 = p_address2)
            OR (    ( recinfo.address2 IS NULL )
                AND (  p_address2 IS NULL )))
       AND (    ( recinfo.address3 = p_address3)
            OR (    ( recinfo.address3 IS NULL )
                AND (  p_address3 IS NULL )))
       AND (    ( recinfo.address4 = p_address4)
            OR (    ( recinfo.address4 IS NULL )
                AND (  p_address4 IS NULL )))
       AND (    ( recinfo.city = p_city)
            OR (    ( recinfo.city IS NULL )
                AND (  p_city IS NULL )))
       AND (    ( recinfo.postal_code = p_postal_code)
            OR (    ( recinfo.postal_code IS NULL )
                AND (  p_postal_code IS NULL )))
       AND (    ( recinfo.state = p_state)
            OR (    ( recinfo.state IS NULL )
                AND (  p_state IS NULL )))
       AND (    ( recinfo.province = p_province)
            OR (    ( recinfo.province IS NULL )
                AND (  p_province IS NULL )))
       AND (    ( recinfo.county = p_county)
            OR (    ( recinfo.county IS NULL )
                AND (  p_county IS NULL )))
       AND (    ( recinfo.clli_code = p_clli_code)
            OR (    ( recinfo.clli_code IS NULL )
                AND (  p_clli_code IS NULL )))
       AND (    ( recinfo.description = p_description)
            OR (    ( recinfo.description IS NULL )
                AND (  p_description IS NULL )))
       AND (    ( recinfo.created_by_module = p_created_by_module)
            OR (    ( recinfo.created_by_module IS NULL )
                AND (  p_created_by_module IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_location;

END CSI_HZ_LOCATIONS_PVT;

/
