--------------------------------------------------------
--  DDL for Package CN_SRP_QUOTA_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_QUOTA_RATES_PKG" AUTHID CURRENT_USER AS
  /*$Header: cntsrqrs.pls 115.2 2002/01/28 20:06:14 pkm ship      $*/

-------------------------------------------------------------------------------+
-- Procedure Name : Insert_Row                                               --+
-- Purpose        : Insert given fields into the cn_srp_quota_rates table;   --+
--                  also do a cascade insert into cn_srp_quota_rates if      --+
--                  required                                                 --+
-- History                                                                   --+
--   06-JUN-2000  mblum          Created                                     --+
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
   ATTRIBUTE15                 IN   VARCHAR2 := NULL);

-------------------------------------------------------------------------------+
-- Procedure Name : Update_Row                                               --+
-- Purpose        : Update given fields in  the cn_srp_quota_rates table;    --+
--                  also do a cascade update into cn_srp_quota_rates if      --+
--                  required                                                 --+
-- History                                                                   --+
--   06-JUN-2000  mblum          Created                                     --+
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
   ATTRIBUTE15                 IN   VARCHAR2 := FND_API.G_MISS_CHAR);

-------------------------------------------------------------------------------+
-- Procedure Name : Delete_Row                                               --+
-- Purpose        : Delete the specified row in the cn_srp_quota_rates table;--+
--                  also cascade delete in cn_srp_quota_rates if required    --+
-- History                                                                   --+
--   06-JUN-2000  mblum          Created                                     --+
-------------------------------------------------------------------------------+
PROCEDURE delete_row
  (SRP_QUOTA_RATE_ID           IN   NUMBER);

END cn_srp_quota_rates_pkg;

 

/
