--------------------------------------------------------
--  DDL for Package CN_SECURITY_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SECURITY_PROFILES_PKG" AUTHID CURRENT_USER AS
/* $Header: cntsecps.pls 115.6 2001/10/29 17:16:51 pkm ship    $ */
--
-- Package Name
--   CN_SECURITY_PROFILES_PKG
-- Purpose
--   Table handler for CN_SECURITY_PROFILES
-- Form
--   CNSPROF
-- Block
--   SECURITY_PROFILES
--
-- History
--   28-Jul-99  Yonghong Mao  Created

--
-- User defined record type
--

TYPE security_profiles_rec_type IS RECORD
  (
   security_profile_id cn_security_profiles.security_profile_id%TYPE,
   profile_user_id     cn_security_profiles.profile_user_id%TYPE,
   attribute_category  cn_security_profiles.attribute_category%TYPE    , -- := FND_API.G_MISS_CHAR,
   attribute1          cn_security_profiles.attribute1%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute2          cn_security_profiles.attribute2%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute3          cn_security_profiles.attribute3%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute4          cn_security_profiles.attribute4%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute5          cn_security_profiles.attribute5%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute6          cn_security_profiles.attribute6%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute7          cn_security_profiles.attribute7%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute8          cn_security_profiles.attribute8%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute9          cn_security_profiles.attribute9%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute10         cn_security_profiles.attribute10%TYPE           , -- := FND_API.G_MISS_CHAR,
   attribute11         cn_security_profiles.attribute11%TYPE           , -- := FND_API.G_MISS_CHAR,
   attribute12         cn_security_profiles.attribute12%TYPE           , -- := FND_API.G_MISS_CHAR,
   attribute13         cn_security_profiles.attribute13%TYPE           , -- := FND_API.G_MISS_CHAR,
   attribute14         cn_security_profiles.attribute14%TYPE           , -- := FND_API.G_MISS_CHAR,
   attribute15         cn_security_profiles.attribute15%TYPE           , -- := FND_API.G_MISS_CHAR,
   created_by          cn_security_profiles.created_by%TYPE            , -- := CN_API.G_MISS_ID,
   creation_date       cn_security_profiles.creation_date%TYPE         , -- := FND_API.G_MISS_DATE,
   last_update_login   cn_security_profiles.last_update_login%TYPE     , -- := CN_API.G_MISS_ID,
   last_update_date    cn_security_profiles.last_update_date%TYPE      , -- := FND_API.G_MISS_DATE,
   last_updated_by     cn_security_profiles.last_updated_by%TYPE         -- := CN_API.G_MISS_ID
  );

--
-- global variables that represent missing values
--

g_last_update_date           DATE   := Sysdate;
g_last_updated_by            NUMBER := fnd_global.user_id;
g_creation_date              DATE   := Sysdate;
g_created_by                 NUMBER := fnd_global.user_id;
g_last_update_login          NUMBER := fnd_global.login_id;

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  Insert_Row
-- Purpose
--  Main insert procedure
-- *--------------------------------------------------------------------------*/
PROCEDURE Insert_Row( x_new_rec IN OUT security_profiles_rec_type);

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  Update_Row
-- Purpose
--  Update the Service Group Assign
-- *--------------------------------------------------------------------------*/
PROCEDURE Update_Row( x_new_rec        security_profiles_rec_type);

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  Lock_Row
-- Purpose
--  Lock DB row after form record is changed
-- *--------------------------------------------------------------------------*/
PROCEDURE Lock_Row(x_rec               security_profiles_rec_type);

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  Delete_Row
-- Purpose
--  Delete the Service Group Assign
-- *--------------------------------------------------------------------------*/
PROCEDURE Delete_Row(x_security_profile_id                NUMBER);

END CN_SECURITY_PROFILES_PKG;

 

/
