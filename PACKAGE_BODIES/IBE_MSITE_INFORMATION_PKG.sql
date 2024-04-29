--------------------------------------------------------
--  DDL for Package Body IBE_MSITE_INFORMATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_MSITE_INFORMATION_PKG" AS
/* $Header: IBETMINB.pls 115.2 2002/12/13 13:01:51 schak ship $ */

  -- HISTORY
  --   12/13/02           SCHAK          Modified for NOCOPY (Bug # 2691704) Changes.
  -- *********************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBE_MSITE_INFORMATION_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBETMINB.pls';

PROCEDURE insert_row
  (
   p_msite_information_id               IN NUMBER,
   p_object_version_number              IN NUMBER,
   p_msite_id                           IN NUMBER,
   p_msite_information_context          IN VARCHAR2,
   p_msite_information1                 IN VARCHAR2,
   p_msite_information2                 IN VARCHAR2,
   p_msite_information3                 IN VARCHAR2,
   p_msite_information4                 IN VARCHAR2,
   p_msite_information5                 IN VARCHAR2,
   p_msite_information6                 IN VARCHAR2,
   p_msite_information7                 IN VARCHAR2,
   p_msite_information8                 IN VARCHAR2,
   p_msite_information9                 IN VARCHAR2,
   p_msite_information10                IN VARCHAR2,
   p_msite_information11                IN VARCHAR2,
   p_msite_information12                IN VARCHAR2,
   p_msite_information13                IN VARCHAR2,
   p_msite_information14                IN VARCHAR2,
   p_msite_information15                IN VARCHAR2,
   p_msite_information16                IN VARCHAR2,
   p_msite_information17                IN VARCHAR2,
   p_msite_information18                IN VARCHAR2,
   p_msite_information19                IN VARCHAR2,
   p_msite_information20                IN VARCHAR2,
   p_attribute_category                 IN VARCHAR2,
   p_attribute1                         IN VARCHAR2,
   p_attribute2                         IN VARCHAR2,
   p_attribute3                         IN VARCHAR2,
   p_attribute4                         IN VARCHAR2,
   p_attribute5                         IN VARCHAR2,
   p_attribute6                         IN VARCHAR2,
   p_attribute7                         IN VARCHAR2,
   p_attribute8                         IN VARCHAR2,
   p_attribute9                         IN VARCHAR2,
   p_attribute10                        IN VARCHAR2,
   p_attribute11                        IN VARCHAR2,
   p_attribute12                        IN VARCHAR2,
   p_attribute13                        IN VARCHAR2,
   p_attribute14                        IN VARCHAR2,
   p_attribute15                        IN VARCHAR2,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT NOCOPY VARCHAR2,
   x_msite_information_id               OUT NOCOPY NUMBER
  )
IS
  CURSOR c IS SELECT rowid FROM ibe_msite_information
    WHERE msite_information_id = x_msite_information_id;
  CURSOR c2 IS SELECT ibe_msite_information_s1.nextval FROM dual;

BEGIN

  -- Primary key validation check
  x_msite_information_id := p_msite_information_id;
  IF ((x_msite_information_id IS NULL) OR
      (x_msite_information_id = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO x_msite_information_id;
    CLOSE c2;
  END IF;

  -- insert base
  INSERT INTO ibe_msite_information
    (
    msite_information_id,
    object_version_number,
    msite_id,
    msite_information_context,
    msite_information1,
    msite_information2,
    msite_information3,
    msite_information4,
    msite_information5,
    msite_information6,
    msite_information7,
    msite_information8,
    msite_information9,
    msite_information10,
    msite_information11,
    msite_information12,
    msite_information13,
    msite_information14,
    msite_information15,
    msite_information16,
    msite_information17,
    msite_information18,
    msite_information19,
    msite_information20,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
    )
    VALUES
    (
    x_msite_information_id,
    p_object_version_number,
    p_msite_id,
    p_msite_information_context,
    decode(p_msite_information1,FND_API.G_MISS_CHAR,NULL,p_msite_information1),
    decode(p_msite_information2,FND_API.G_MISS_CHAR,NULL,p_msite_information2),
    decode(p_msite_information3,FND_API.G_MISS_CHAR,NULL,p_msite_information3),
    decode(p_msite_information4,FND_API.G_MISS_CHAR,NULL,p_msite_information4),
    decode(p_msite_information5,FND_API.G_MISS_CHAR,NULL,p_msite_information5),
    decode(p_msite_information6,FND_API.G_MISS_CHAR,NULL,p_msite_information6),
    decode(p_msite_information7,FND_API.G_MISS_CHAR,NULL,p_msite_information7),
    decode(p_msite_information8,FND_API.G_MISS_CHAR,NULL,p_msite_information8),
    decode(p_msite_information9,FND_API.G_MISS_CHAR,NULL,p_msite_information9),
    decode(p_msite_information10,FND_API.G_MISS_CHAR,NULL,
           p_msite_information10),
    decode(p_msite_information11,FND_API.G_MISS_CHAR,NULL,
           p_msite_information11),
    decode(p_msite_information12,FND_API.G_MISS_CHAR,NULL,
           p_msite_information12),
    decode(p_msite_information13,FND_API.G_MISS_CHAR,NULL,
           p_msite_information13),
    decode(p_msite_information14,FND_API.G_MISS_CHAR,NULL,
           p_msite_information14),
    decode(p_msite_information15,FND_API.G_MISS_CHAR,NULL,
           p_msite_information15),
    decode(p_msite_information16,FND_API.G_MISS_CHAR,NULL,
           p_msite_information16),
    decode(p_msite_information17,FND_API.G_MISS_CHAR,NULL,
           p_msite_information17),
    decode(p_msite_information18,FND_API.G_MISS_CHAR,NULL,
           p_msite_information18),
    decode(p_msite_information19,FND_API.G_MISS_CHAR,NULL,
           p_msite_information19),
    decode(p_msite_information20,FND_API.G_MISS_CHAR,NULL,
           p_msite_information20),
    decode(p_attribute_category,FND_API.G_MISS_CHAR,NULL,p_attribute_category),
    decode(p_attribute1, FND_API.G_MISS_CHAR, NULL, p_attribute1),
    decode(p_attribute2, FND_API.G_MISS_CHAR, NULL, p_attribute2),
    decode(p_attribute3, FND_API.G_MISS_CHAR, NULL, p_attribute3),
    decode(p_attribute4, FND_API.G_MISS_CHAR, NULL, p_attribute4),
    decode(p_attribute5, FND_API.G_MISS_CHAR, NULL, p_attribute5),
    decode(p_attribute6, FND_API.G_MISS_CHAR, NULL, p_attribute6),
    decode(p_attribute7, FND_API.G_MISS_CHAR, NULL, p_attribute7),
    decode(p_attribute8, FND_API.G_MISS_CHAR, NULL, p_attribute8),
    decode(p_attribute9, FND_API.G_MISS_CHAR, NULL, p_attribute9),
    decode(p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10),
    decode(p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11),
    decode(p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12),
    decode(p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13),
    decode(p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14),
    decode(p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15),
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
   p_msite_information_id               IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_msite_information1                 IN VARCHAR2,
   p_msite_information2                 IN VARCHAR2,
   p_msite_information3                 IN VARCHAR2,
   p_msite_information4                 IN VARCHAR2,
   p_msite_information5                 IN VARCHAR2,
   p_msite_information6                 IN VARCHAR2,
   p_msite_information7                 IN VARCHAR2,
   p_msite_information8                 IN VARCHAR2,
   p_msite_information9                 IN VARCHAR2,
   p_msite_information10                IN VARCHAR2,
   p_msite_information11                IN VARCHAR2,
   p_msite_information12                IN VARCHAR2,
   p_msite_information13                IN VARCHAR2,
   p_msite_information14                IN VARCHAR2,
   p_msite_information15                IN VARCHAR2,
   p_msite_information16                IN VARCHAR2,
   p_msite_information17                IN VARCHAR2,
   p_msite_information18                IN VARCHAR2,
   p_msite_information19                IN VARCHAR2,
   p_msite_information20                IN VARCHAR2,
   p_attribute_category                 IN VARCHAR2,
   p_attribute1                         IN VARCHAR2,
   p_attribute2                         IN VARCHAR2,
   p_attribute3                         IN VARCHAR2,
   p_attribute4                         IN VARCHAR2,
   p_attribute5                         IN VARCHAR2,
   p_attribute6                         IN VARCHAR2,
   p_attribute7                         IN VARCHAR2,
   p_attribute8                         IN VARCHAR2,
   p_attribute9                         IN VARCHAR2,
   p_attribute10                        IN VARCHAR2,
   p_attribute11                        IN VARCHAR2,
   p_attribute12                        IN VARCHAR2,
   p_attribute13                        IN VARCHAR2,
   p_attribute14                        IN VARCHAR2,
   p_attribute15                        IN VARCHAR2,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER
  )
IS
BEGIN

  -- update base
  UPDATE ibe_msite_information SET
    object_version_number = object_version_number + 1,
    msite_information1 = decode(p_msite_information1, FND_API.G_MISS_CHAR,
                                msite_information1, p_msite_information1),
    msite_information2 = decode(p_msite_information2, FND_API.G_MISS_CHAR,
                                msite_information2, p_msite_information2),
    msite_information3 = decode(p_msite_information3, FND_API.G_MISS_CHAR,
                                msite_information3, p_msite_information3),
    msite_information4 = decode(p_msite_information4, FND_API.G_MISS_CHAR,
                                msite_information4, p_msite_information4),
    msite_information5 = decode(p_msite_information5, FND_API.G_MISS_CHAR,
                                msite_information5, p_msite_information5),
    msite_information6 = decode(p_msite_information6, FND_API.G_MISS_CHAR,
                                msite_information6, p_msite_information6),
    msite_information7 = decode(p_msite_information7, FND_API.G_MISS_CHAR,
                                msite_information7, p_msite_information7),
    msite_information8 = decode(p_msite_information8, FND_API.G_MISS_CHAR,
                                msite_information8, p_msite_information8),
    msite_information9 = decode(p_msite_information9, FND_API.G_MISS_CHAR,
                                msite_information9, p_msite_information9),
    msite_information10 = decode(p_msite_information10, FND_API.G_MISS_CHAR,
                                 msite_information10, p_msite_information10),
    msite_information11 = decode(p_msite_information11, FND_API.G_MISS_CHAR,
                                 msite_information11, p_msite_information11),
    msite_information12 = decode(p_msite_information12, FND_API.G_MISS_CHAR,
                                 msite_information12, p_msite_information12),
    msite_information13 = decode(p_msite_information13, FND_API.G_MISS_CHAR,
                                 msite_information13, p_msite_information13),
    msite_information14 = decode(p_msite_information14, FND_API.G_MISS_CHAR,
                                 msite_information14, p_msite_information14),
    msite_information15 = decode(p_msite_information15, FND_API.G_MISS_CHAR,
                                 msite_information15, p_msite_information15),
    msite_information16 = decode(p_msite_information16, FND_API.G_MISS_CHAR,
                                 msite_information16, p_msite_information16),
    msite_information17 = decode(p_msite_information17, FND_API.G_MISS_CHAR,
                                 msite_information17, p_msite_information17),
    msite_information18 = decode(p_msite_information18, FND_API.G_MISS_CHAR,
                                 msite_information18, p_msite_information18),
    msite_information19 = decode(p_msite_information19, FND_API.G_MISS_CHAR,
                                 msite_information19, p_msite_information19),
    msite_information20 = decode(p_msite_information20, FND_API.G_MISS_CHAR,
                                 msite_information20, p_msite_information20),
    attribute_category = decode(p_attribute_category, FND_API.G_MISS_CHAR,
                                attribute_category, p_attribute_category),
    attribute1 = decode(p_attribute1, FND_API.G_MISS_CHAR,
                        attribute1, p_attribute1),
    attribute2 = decode(p_attribute2, FND_API.G_MISS_CHAR,
                        attribute2, p_attribute2),
    attribute3 = decode(p_attribute3, FND_API.G_MISS_CHAR,
                        attribute3, p_attribute3),
    attribute4 = decode(p_attribute4, FND_API.G_MISS_CHAR,
                        attribute4, p_attribute4),
    attribute5 = decode(p_attribute5, FND_API.G_MISS_CHAR,
                        attribute5, p_attribute5),
    attribute6 = decode(p_attribute6, FND_API.G_MISS_CHAR,
                        attribute6, p_attribute6),
    attribute7 = decode(p_attribute7, FND_API.G_MISS_CHAR,
                        attribute7, p_attribute7),
    attribute8 = decode(p_attribute8, FND_API.G_MISS_CHAR,
                        attribute8, p_attribute8),
    attribute9 = decode(p_attribute9, FND_API.G_MISS_CHAR,
                        attribute9, p_attribute9),
    attribute10 = decode(p_attribute10, FND_API.G_MISS_CHAR,
                         attribute10, p_attribute10),
    attribute11 = decode(p_attribute11, FND_API.G_MISS_CHAR,
                         attribute11, p_attribute11),
    attribute12 = decode(p_attribute12, FND_API.G_MISS_CHAR,
                         attribute12, p_attribute12),
    attribute13 = decode(p_attribute13, FND_API.G_MISS_CHAR,
                         attribute13, p_attribute13),
    attribute14 = decode(p_attribute14, FND_API.G_MISS_CHAR,
                         attribute14, p_attribute14),
    attribute15 = decode(p_attribute15, FND_API.G_MISS_CHAR,
                         attribute15, p_attribute15),
    last_update_date = decode(p_last_update_date, FND_API.G_MISS_DATE, sysdate,
                              NULL, sysdate, p_last_update_date),
    last_updated_by = decode(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = decode(p_last_update_login, FND_API.G_MISS_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login)
    WHERE msite_information_id = p_msite_information_id
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
   p_msite_information_id IN NUMBER
  )
IS
BEGIN

  DELETE FROM ibe_msite_information
    WHERE msite_information_id = p_msite_information_id;

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;

END Ibe_Msite_Information_Pkg;

/
