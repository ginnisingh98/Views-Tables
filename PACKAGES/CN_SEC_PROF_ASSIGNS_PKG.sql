--------------------------------------------------------
--  DDL for Package CN_SEC_PROF_ASSIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SEC_PROF_ASSIGNS_PKG" AUTHID CURRENT_USER AS
/* $Header: cntspfas.pls 115.5 2001/10/29 17:16:57 pkm ship    $ */
--
-- Package Name
--   CN_SEC_PROF_ASSIGNS_PKG
-- Purpose
--   Table handler for CN_SEC_PROF_ASSIGNS
-- Form
--   CNSPROF
-- Block
--   SEC_PROF_ASSIGNS
--
-- History
--   28-Jul-99  Yonghong Mao  Created

--
-- User defined record type
--

TYPE sec_prof_assign_rec_type IS RECORD
  (
   sec_prof_assign_id  cn_sec_prof_assigns.sec_prof_assign_id%TYPE,
   security_profile_id cn_sec_prof_assigns.security_profile_id%TYPE,
   salesrep_id         cn_sec_prof_assigns.salesrep_id%TYPE,
   start_date          cn_sec_prof_assigns.start_date%TYPE,
   end_date            cn_sec_prof_assigns.end_date%TYPE              , -- := FND_API.G_MISS_DATE,
   attribute_category  cn_sec_prof_assigns.attribute_category%TYPE    , -- := FND_API.G_MISS_CHAR,
   attribute1          cn_sec_prof_assigns.attribute1%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute2          cn_sec_prof_assigns.attribute2%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute3          cn_sec_prof_assigns.attribute3%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute4          cn_sec_prof_assigns.attribute4%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute5          cn_sec_prof_assigns.attribute5%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute6          cn_sec_prof_assigns.attribute6%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute7          cn_sec_prof_assigns.attribute7%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute8          cn_sec_prof_assigns.attribute8%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute9          cn_sec_prof_assigns.attribute9%TYPE            , -- := FND_API.G_MISS_CHAR,
   attribute10         cn_sec_prof_assigns.attribute10%TYPE           , -- := FND_API.G_MISS_CHAR,
   attribute11         cn_sec_prof_assigns.attribute11%TYPE           , -- := FND_API.G_MISS_CHAR,
   attribute12         cn_sec_prof_assigns.attribute12%TYPE           , -- := FND_API.G_MISS_CHAR,
   attribute13         cn_sec_prof_assigns.attribute13%TYPE           , -- := FND_API.G_MISS_CHAR,
   attribute14         cn_sec_prof_assigns.attribute14%TYPE           , -- := FND_API.G_MISS_CHAR,
   attribute15         cn_sec_prof_assigns.attribute15%TYPE           , -- := FND_API.G_MISS_CHAR,
   created_by          cn_sec_prof_assigns.created_by%TYPE            , -- := CN_API.G_MISS_ID,
   creation_date       cn_sec_prof_assigns.creation_date%TYPE         , -- := FND_API.G_MISS_DATE,
   last_update_login   cn_sec_prof_assigns.last_update_login%TYPE     , -- := CN_API.G_MISS_ID,
   last_update_date    cn_sec_prof_assigns.last_update_date%TYPE      , -- := FND_API.G_MISS_DATE,
   last_updated_by     cn_sec_prof_assigns.last_updated_by%TYPE         -- := CN_API.G_MISS_ID
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
PROCEDURE Insert_Row( x_new_rec IN OUT sec_prof_assign_rec_type);

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  Update_Row
-- Purpose
--  Update the Service Group Assign
-- *--------------------------------------------------------------------------*/
PROCEDURE Update_Row( x_new_rec        sec_prof_assign_rec_type);

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  Lock_Row
-- Purpose
--  Lock DB row after form record is changed
-- *--------------------------------------------------------------------------*/
PROCEDURE Lock_Row(x_rec               sec_prof_assign_rec_type);

--/*--------------------------------------------------------------------------*
-- Prodedure Name
--  Delete_Row
-- Purpose
--  Delete the Service Group Assign
-- *--------------------------------------------------------------------------*/
PROCEDURE Delete_Row(x_sec_prof_assign_id                NUMBER);

END CN_SEC_PROF_ASSIGNS_PKG;

 

/
