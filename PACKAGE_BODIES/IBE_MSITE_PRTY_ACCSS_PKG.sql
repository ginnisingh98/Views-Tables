--------------------------------------------------------
--  DDL for Package Body IBE_MSITE_PRTY_ACCSS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_MSITE_PRTY_ACCSS_PKG" AS
/* $Header: IBETMPRB.pls 115.2 2002/12/13 14:06:57 schak ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBE_MSITE_PRTY_ACCSS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBETMPRB.pls';

  -- HISTORY
  --   12/13/02           SCHAK         Modified for NOCOPY (Bug # 2691704)  Changes.
  -- *********************************************************************************

PROCEDURE insert_row
  (
   p_msite_prty_accss_id                IN NUMBER,
   p_object_version_number              IN NUMBER,
   p_msite_id                           IN NUMBER,
   p_party_id                           IN NUMBER,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT NOCOPY VARCHAR2,
   x_msite_prty_accss_id                OUT NOCOPY NUMBER
  )
IS
  CURSOR c IS SELECT rowid FROM ibe_msite_prty_accss
    WHERE msite_prty_accss_id = x_msite_prty_accss_id;
  CURSOR c2 IS SELECT ibe_msite_prty_accss_s1.nextval FROM dual;

BEGIN

  -- Primary key validation check
  x_msite_prty_accss_id := p_msite_prty_accss_id;
  IF ((x_msite_prty_accss_id IS NULL) OR
      (x_msite_prty_accss_id = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO x_msite_prty_accss_id;
    CLOSE c2;
  END IF;

  -- insert base
  INSERT INTO ibe_msite_prty_accss
    (
    msite_prty_accss_id,
    object_version_number,
    msite_id,
    party_id,
    start_date_active,
    end_date_active,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
    )
    VALUES
    (
    x_msite_prty_accss_id,
    p_object_version_number,
    p_msite_id,
    p_party_id,
    p_start_date_active,
    decode(p_end_date_active, FND_API.G_MISS_DATE, NULL, p_end_date_active),
    decode(p_creation_date, FND_API.G_MISS_DATE, sysdate, NULL, sysdate,
           p_creation_date),
    decode(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_created_by),
    decode(p_last_update_date, FND_API.G_MISS_DATE, sysdate, NULL, sysdate,
           p_last_update_date),
    decode(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_last_updated_by),
    decode(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.login_id,
           NULL, FND_GLOBAL.login_id, p_last_update_login)
    );

  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END insert_row;

PROCEDURE update_row
  (
   p_msite_prty_accss_id                IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER
  )
IS
BEGIN

  -- update base
  UPDATE ibe_msite_prty_accss SET
    object_version_number = object_version_number + 1,
    start_date_active = decode(p_start_date_active, FND_API.G_MISS_DATE,
                               start_date_active, p_start_date_active),
    end_date_active = decode(p_end_date_active, FND_API.G_MISS_DATE,
                             end_date_active, p_end_date_active),
    last_update_date = decode(p_last_update_date, FND_API.G_MISS_DATE, sysdate,
                              NULL, sysdate, p_last_update_date),
    last_updated_by = decode(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = decode(p_last_update_login, FND_API.G_MISS_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login)
    WHERE msite_prty_accss_id = p_msite_prty_accss_id
    AND object_version_number = decode(p_object_version_number,
                                       FND_API.G_MISS_NUM,
                                       object_version_number,
                                       p_object_version_number);
  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END update_row;

-- ****************************************************************************
-- delete row
-- ****************************************************************************
PROCEDURE delete_row
  (
   p_msite_prty_accss_id IN NUMBER
  )
IS
BEGIN

  DELETE FROM ibe_msite_prty_accss
    WHERE msite_prty_accss_id = p_msite_prty_accss_id;

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;

END Ibe_Msite_Prty_Accss_Pkg;

/