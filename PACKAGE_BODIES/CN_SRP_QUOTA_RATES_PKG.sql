--------------------------------------------------------
--  DDL for Package Body CN_SRP_QUOTA_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_QUOTA_RATES_PKG" AS
  /*$Header: cntsrqrb.pls 115.3 2002/01/28 20:06:13 pkm ship      $*/

-------------------------------------------------------------------------------+
-- Procedure Name : Insert_Row                                               --+
-- Purpose        : Insert given fields into the cn_srp_quota_rates table;   --+
--                  also do a cascade insert into cn_srp_quota_rates if      --+
--                  required                                                 --+
-- History                                                                   --+
--   06-JUN-2000  mblum         Created                                      --+
-------------------------------------------------------------------------------+
PROCEDURE insert_row
  (SRP_QUOTA_CATE_ID           IN   NUMBER,
   ROLE_QUOTA_RATE_ID          IN   NUMBER,
   SRP_ID                      IN   NUMBER,
   QUOTA_CATEGORY_ID           IN   NUMBER,
   RATE_TIER_ID                IN   NUMBER,
   COMM_RATE                   IN   NUMBER,
   ATTRIBUTE_CATEGORY          IN   VARCHAR2 := NULL,
   ATTRIBUTE1                  IN   VARCHAR2 := NULL,
   ATTRIBUTE2                  IN   VARCHAR2 := NULL,
   ATTRIBUTE3                  IN   VARCHAR2 := NULL,
   ATTRIBUTE4                  IN   VARCHAR2 := NULL,
   ATTRIBUTE5                  IN   VARCHAR2 := NULL,
   ATTRIBUTE6                  IN   VARCHAR2 := NULL,
   ATTRIBUTE7                  IN   VARCHAR2 := NULL,
   ATTRIBUTE8                  IN   VARCHAR2 := NULL,
   ATTRIBUTE9                  IN   VARCHAR2 := NULL,
   ATTRIBUTE10                 IN   VARCHAR2 := NULL,
   ATTRIBUTE11                 IN   VARCHAR2 := NULL,
   ATTRIBUTE12                 IN   VARCHAR2 := NULL,
   ATTRIBUTE13                 IN   VARCHAR2 := NULL,
   ATTRIBUTE14                 IN   VARCHAR2 := NULL,
   ATTRIBUTE15                 IN   VARCHAR2 := NULL) IS

   l_srp_quota_rate_id        number;

BEGIN
   -- Get the next value in sequence
   SELECT cn_srp_quota_rates_s.nextval
     INTO l_srp_quota_rate_id
     FROM dual;

   -- Now insert row
   INSERT INTO cn_srp_quota_rates
     (srp_quota_rate_id, srp_quota_cate_id, role_quota_rate_id, srp_id,
      quota_category_id, rate_tier_id, comm_rate, attribute_category,
      attribute1,  attribute2,  attribute3,  attribute4,  attribute5,
      attribute6,  attribute7,  attribute8,  attribute9,  attribute10,
      attribute11, attribute12, attribute13, attribute14, attribute15,
      last_update_date, last_updated_by, last_update_login, creation_date,
      created_by, object_version_number) VALUES
     (l_srp_quota_rate_id, srp_quota_cate_id, role_quota_rate_id, srp_id,
      quota_category_id, rate_tier_id, comm_rate, attribute_category,
      attribute1,  attribute2,  attribute3,  attribute4,  attribute5,
      attribute6,  attribute7,  attribute8,  attribute9,  attribute10,
      attribute11, attribute12, attribute13, attribute14, attribute15,
      sysdate, fnd_global.user_id, fnd_global.login_id,
      sysdate, fnd_global.user_id, 1);
END Insert_Row;

-------------------------------------------------------------------------------+
-- Procedure Name : Update_Row                                               --+
-- Purpose        : Update given fields in  the cn_srp_quota_rates table;    --+
--                  also do a cascade update into cn_srp_quota_rates if      --+
--                  required                                                 --+
-- History                                                                   --+
--   06-JUN-2000  mblum         Created                                      --+
-------------------------------------------------------------------------------+
PROCEDURE update_row
  (SRP_QUOTA_RATE_ID           IN   NUMBER,
   SRP_QUOTA_CATE_ID           IN   NUMBER   := FND_API.G_MISS_NUM,
   ROLE_QUOTA_RATE_ID          IN   NUMBER   := FND_API.G_MISS_NUM,
   SRP_ID                      IN   NUMBER   := FND_API.G_MISS_NUM,
   QUOTA_CATEGORY_ID           IN   NUMBER   := FND_API.G_MISS_NUM,
   RATE_TIER_ID                IN   NUMBER   := FND_API.G_MISS_NUM,
   COMM_RATE                   IN   NUMBER   := FND_API.G_MISS_NUM,
   ATTRIBUTE_CATEGORY          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE1                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE2                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE3                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE4                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE5                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE6                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE7                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE8                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE9                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE10                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE11                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE12                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE13                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE14                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
   ATTRIBUTE15                 IN   VARCHAR2 := FND_API.G_MISS_CHAR) IS

   l_srp_quota_rate_id         number := srp_quota_rate_id;
   l_srp_quota_cate_id         number;
   l_role_quota_rate_id        number;
   l_quota_category_id         number;
   l_srp_id                    number;
   l_rate_tier_id              number;
   l_comm_rate                 number;
   l_attribute_category        varchar2(150);
   l_attribute1                varchar2(150);
   l_attribute2                varchar2(150);
   l_attribute3                varchar2(150);
   l_attribute4                varchar2(150);
   l_attribute5                varchar2(150);
   l_attribute6                varchar2(150);
   l_attribute7                varchar2(150);
   l_attribute8                varchar2(150);
   l_attribute9                varchar2(150);
   l_attribute10               varchar2(150);
   l_attribute11               varchar2(150);
   l_attribute12               varchar2(150);
   l_attribute13               varchar2(150);
   l_attribute14               varchar2(150);
   l_attribute15               varchar2(150);
   l_object_version_number     number;

   CURSOR l_update_csr IS
     SELECT srp_quota_cate_id, role_quota_rate_id, quota_category_id, srp_id,
       rate_tier_id, comm_rate,  attribute_category, attribute1, attribute2,
       attribute3,  attribute4,  attribute5,  attribute6,  attribute7,
       attribute8,  attribute9,  attribute10, attribute11, attribute12,
       attribute13, attribute14, attribute15, object_version_number
       FROM cn_srp_quota_rates r
       WHERE r.srp_quota_rate_id = l_srp_quota_rate_id;

   MN NUMBER        := FND_API.G_MISS_NUM;
   MC VARCHAR2(150) := FND_API.G_MISS_CHAR;

BEGIN
   OPEN l_update_csr;
   FETCH l_update_csr INTO l_srp_quota_cate_id, l_quota_category_id,
     l_role_quota_rate_id, l_srp_id, l_rate_tier_id, l_comm_rate,
     l_attribute_category, l_attribute1, l_attribute2, l_attribute3,
     l_attribute4,  l_attribute5 , l_attribute6,  l_attribute7,  l_attribute8,
     l_attribute9,  l_attribute10, l_attribute11, l_attribute12, l_attribute13,
     l_attribute14, l_attribute15, l_object_version_number;
   CLOSE l_update_csr;

   -- copy over and handle g-misses
   IF (srp_quota_cate_id  <> MN) THEN l_srp_quota_cate_id  := srp_quota_cate_id;  END IF;
   IF (quota_category_id  <> MN) THEN l_quota_category_id  := quota_category_id;  END IF;
   IF (role_quota_rate_id <> MN) THEN l_role_quota_rate_id := role_quota_rate_id; END IF;
   IF (srp_id             <> MN) THEN l_srp_id             := srp_id;             END IF;
   IF (rate_tier_id       <> MN) THEN l_rate_tier_id       := rate_tier_id;       END IF;
   IF (comm_rate          <> MN) THEN l_comm_rate          := comm_rate;          END IF;
   IF (attribute_category <> MC) THEN l_attribute_category := attribute_category; END IF;
   IF (attribute1         <> MC) THEN l_attribute1         := attribute1;         END IF;
   IF (attribute2         <> MC) THEN l_attribute2         := attribute2;         END IF;
   IF (attribute3         <> MC) THEN l_attribute3         := attribute3;         END IF;
   IF (attribute4         <> MC) THEN l_attribute4         := attribute4;         END IF;
   IF (attribute5         <> MC) THEN l_attribute5         := attribute5;         END IF;
   IF (attribute6         <> MC) THEN l_attribute6         := attribute6;         END IF;
   IF (attribute7         <> MC) THEN l_attribute7         := attribute7;         END IF;
   IF (attribute8         <> MC) THEN l_attribute8         := attribute8;         END IF;
   IF (attribute9         <> MC) THEN l_attribute9         := attribute9;         END IF;
   IF (attribute10        <> MC) THEN l_attribute10        := attribute10;        END IF;
   IF (attribute11        <> MC) THEN l_attribute11        := attribute11;        END IF;
   IF (attribute12        <> MC) THEN l_attribute12        := attribute12;        END IF;
   IF (attribute13        <> MC) THEN l_attribute13        := attribute13;        END IF;
   IF (attribute14        <> MC) THEN l_attribute14        := attribute14;        END IF;
   IF (attribute15        <> MC) THEN l_attribute15        := attribute15;        END IF;

   UPDATE cn_srp_quota_rates r SET
     srp_quota_cate_id = l_srp_quota_cate_id,
     role_quota_rate_id = l_role_quota_rate_id,
     quota_category_id = l_quota_category_id, srp_id = l_srp_id,
     rate_tier_id = l_rate_tier_id, comm_rate = l_comm_rate,
     attribute_category = l_attribute_category,
     attribute1 = l_attribute1, attribute2 = l_attribute2,
     attribute3 = l_attribute3, attribute4 = l_attribute4,
     attribute5 = l_attribute5, attribute6 = l_attribute6,
     attribute7 = l_attribute7, attribute8 = l_attribute8,
     attribute9 = l_attribute9, attribute10 = l_attribute10,
     attribute11 = l_attribute11, attribute12 = l_attribute12,
     attribute13 = l_attribute13, attribute14 = l_attribute14,
     attribute15 = l_attribute15,
     object_version_number = l_object_version_number + 1,
     last_update_date = sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
     WHERE r.srp_quota_rate_id = l_srp_quota_rate_id;
END Update_Row;

-------------------------------------------------------------------------------+
-- Procedure Name : Delete_Row                                               --+
-- Purpose        : Delete the specified row in the cn_srp_quota_rates table;--+
--                  also cascade delete in cn_srp_quota_rates if required    --+
-- History                                                                   --+
--   06-JUN-2000  mblum         Created                                      --+
-------------------------------------------------------------------------------+
PROCEDURE delete_row
  (SRP_QUOTA_RATE_ID           IN   NUMBER) IS
   l_srp_quota_rate_id         number := srp_quota_rate_id;
BEGIN
   DELETE FROM cn_srp_quota_rates r
     WHERE r.srp_quota_rate_id = l_srp_quota_rate_id;
END Delete_Row;

END cn_srp_quota_rates_pkg;

/
