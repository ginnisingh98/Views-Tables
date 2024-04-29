--------------------------------------------------------
--  DDL for Package Body XLE_ASSOCIATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_ASSOCIATION_PKG" AS
/* $Header: xleasstb.pls 120.3 2006/03/09 09:16:58 apbalakr ship $ */

PROCEDURE Insert_Row(
  x_association_id		IN OUT NOCOPY NUMBER,
  p_association_type_id 	IN NUMBER   DEFAULT NULL,
  p_subject_id			IN NUMBER   DEFAULT NULL,
  p_subject_parent_id		IN NUMBER   DEFAULT NULL,
  p_object_id			IN NUMBER   DEFAULT NULL,
  p_effective_from		IN DATE     DEFAULT NULL,
  p_effective_to		IN DATE     DEFAULT NULL,
  p_assoc_information_context   IN VARCHAR2 DEFAULT NULL,
  p_assoc_information1          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information2          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information3          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information4          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information5          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information6          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information7          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information8          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information9          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information10         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information11         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information12         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information13         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information14         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information15         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information16         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information17         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information18         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information19         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information20         IN VARCHAR2 DEFAULT NULL,
  p_object_version_number	IN NUMBER   DEFAULT NULL,
  p_last_update_date 	  	IN DATE     DEFAULT NULL,
  p_last_updated_by	        IN NUMBER   DEFAULT NULL,
  p_creation_date 		IN DATE     DEFAULT NULL,
  p_created_by 			IN NUMBER   DEFAULT NULL,
  p_last_update_login 		IN NUMBER   DEFAULT NULL

) IS
BEGIN



  INSERT INTO xle_associations (
	   association_id
          ,association_type_id
	  ,subject_id
	  ,subject_parent_id
	  ,object_id
	  ,effective_from
	  ,effective_to
          ,assoc_information_context
          ,assoc_information1
          ,assoc_information2
          ,assoc_information3
          ,assoc_information4
          ,assoc_information5
          ,assoc_information6
          ,assoc_information7
          ,assoc_information8
          ,assoc_information9
          ,assoc_information10
          ,assoc_information11
          ,assoc_information12
          ,assoc_information13
          ,assoc_information14
          ,assoc_information15
          ,assoc_information16
          ,assoc_information17
          ,assoc_information18
          ,assoc_information19
          ,assoc_information20
	  ,object_version_number
	  ,last_update_date
	  ,last_updated_by
	  ,creation_date
	  ,created_by
	  ,last_update_login
  )
  VALUES (
     xle_associations_s.NEXTVAL
    ,DECODE(p_association_type_id, FND_API.G_MISS_NUM, NULL, p_association_type_id)
    ,DECODE(p_subject_id, FND_API.G_MISS_NUM, NULL, p_subject_id)
    ,DECODE(p_subject_parent_id, FND_API.G_MISS_NUM, NULL, p_subject_parent_id)
    ,DECODE(p_object_id, FND_API.G_MISS_NUM, NULL, p_object_id)
    ,DECODE(p_association_type_id,10006,SYSDATE,DECODE(p_effective_from, FND_API.G_MISS_DATE, NULL, p_effective_from))
    ,DECODE(p_effective_to, FND_API.G_MISS_DATE, NULL, p_effective_to)
    ,DECODE(p_assoc_information_context, FND_API.G_MISS_CHAR, NULL, p_assoc_information_context)
    ,DECODE(p_assoc_information1, FND_API.G_MISS_CHAR, NULL, p_assoc_information1)
    ,DECODE(p_assoc_information2, FND_API.G_MISS_CHAR, NULL, p_assoc_information2)
    ,DECODE(p_assoc_information3, FND_API.G_MISS_CHAR, NULL, p_assoc_information3)
    ,DECODE(p_assoc_information4, FND_API.G_MISS_CHAR, NULL, p_assoc_information4)
    ,DECODE(p_assoc_information5, FND_API.G_MISS_CHAR, NULL, p_assoc_information5)
    ,DECODE(p_assoc_information6, FND_API.G_MISS_CHAR, NULL, p_assoc_information6)
    ,DECODE(p_assoc_information7, FND_API.G_MISS_CHAR, NULL, p_assoc_information7)
    ,DECODE(p_assoc_information8, FND_API.G_MISS_CHAR, NULL, p_assoc_information8)
    ,DECODE(p_assoc_information9, FND_API.G_MISS_CHAR, NULL, p_assoc_information9)
    ,DECODE(p_assoc_information10, FND_API.G_MISS_CHAR, NULL, p_assoc_information10)
    ,DECODE(p_assoc_information11, FND_API.G_MISS_CHAR, NULL, p_assoc_information11)
    ,DECODE(p_assoc_information12, FND_API.G_MISS_CHAR, NULL, p_assoc_information12)
    ,DECODE(p_assoc_information13, FND_API.G_MISS_CHAR, NULL, p_assoc_information13)
    ,DECODE(p_assoc_information14, FND_API.G_MISS_CHAR, NULL, p_assoc_information14)
    ,DECODE(p_assoc_information15, FND_API.G_MISS_CHAR, NULL, p_assoc_information15)
    ,DECODE(p_assoc_information16, FND_API.G_MISS_CHAR, NULL, p_assoc_information16)
    ,DECODE(p_assoc_information17, FND_API.G_MISS_CHAR, NULL, p_assoc_information17)
    ,DECODE(p_assoc_information18, FND_API.G_MISS_CHAR, NULL, p_assoc_information18)
    ,DECODE(p_assoc_information19, FND_API.G_MISS_CHAR, NULL, p_assoc_information19)
    ,DECODE(p_assoc_information20, FND_API.G_MISS_CHAR, NULL, p_assoc_information20)
    ,DECODE(p_object_version_number, FND_API.G_MISS_NUM, NULL, p_object_version_number)
    ,XLE_UTILITY_PUB.LAST_UPDATE_DATE
    ,XLE_UTILITY_PUB.LAST_UPDATED_BY
    ,XLE_UTILITY_PUB.CREATION_DATE
    ,XLE_UTILITY_PUB.CREATED_BY
    ,XLE_UTILITY_PUB.LAST_UPDATE_LOGIN
    )
  RETURNING
     association_id
  INTO
     x_association_id;
END Insert_Row;

PROCEDURE Update_Row(
  p_association_id	        IN NUMBER,
  p_association_type_id         IN NUMBER   DEFAULT NULL,
  p_subject_id		        IN NUMBER   DEFAULT NULL,
  p_subject_parent_id	        IN NUMBER   DEFAULT NULL,
  p_object_id		        IN NUMBER   DEFAULT NULL,
  p_effective_from	        IN DATE     DEFAULT NULL,
  p_effective_to	        IN DATE     DEFAULT NULL,
  p_assoc_information_context   IN VARCHAR2 DEFAULT NULL,
  p_assoc_information1          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information2          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information3          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information4          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information5          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information6          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information7          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information8          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information9          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information10         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information11         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information12         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information13         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information14         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information15         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information16         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information17         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information18         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information19         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information20         IN VARCHAR2 DEFAULT NULL,
  p_object_version_number       IN NUMBER   DEFAULT NULL,
  p_last_update_date 	        IN DATE     DEFAULT NULL,
  p_last_updated_by 	        IN NUMBER   DEFAULT NULL,
  p_last_update_login 	        IN NUMBER   DEFAULT NULL
)
IS
BEGIN
  UPDATE xle_associations SET
    association_type_id =   DECODE(p_association_type_id, NULL, association_type_id, FND_API.G_MISS_NUM, NULL, p_association_type_id),
    subject_id          =   DECODE(p_subject_id, NULL, subject_id, FND_API.G_MISS_NUM, NULL, p_subject_id),
    subject_parent_id   =   DECODE(p_subject_parent_id, NULL, subject_parent_id, FND_API.G_MISS_NUM, NULL, p_subject_parent_id),
    object_id           =   DECODE(p_object_id, NULL, object_id, FND_API.G_MISS_NUM, NULL, p_object_id),
    effective_from      =   DECODE(p_effective_from, NULL, effective_from, FND_API.G_MISS_DATE, NULL, p_effective_from),
    effective_to        =   DECODE(association_type_id,10006,SYSDATE-1/86400,DECODE(p_effective_to, NULL, effective_to, FND_API.G_MISS_DATE, NULL, p_effective_to)),
    assoc_information_context = DECODE (p_assoc_information_context, NULL, assoc_information_context, FND_API.G_MISS_CHAR, NULL, p_assoc_information_context),
    assoc_information1  =   DECODE (p_assoc_information1,  NULL, assoc_information1,  FND_API.G_MISS_CHAR, NULL, p_assoc_information1),
    assoc_information2  =   DECODE (p_assoc_information2,  NULL, assoc_information2,  FND_API.G_MISS_CHAR, NULL, p_assoc_information2),
    assoc_information3  =   DECODE (p_assoc_information3,  NULL, assoc_information3,  FND_API.G_MISS_CHAR, NULL, p_assoc_information3),
    assoc_information4  =   DECODE (p_assoc_information4,  NULL, assoc_information4,  FND_API.G_MISS_CHAR, NULL, p_assoc_information4),
    assoc_information5  =   DECODE (p_assoc_information5,  NULL, assoc_information5,  FND_API.G_MISS_CHAR, NULL, p_assoc_information5),
    assoc_information6  =   DECODE (p_assoc_information6,  NULL, assoc_information6,  FND_API.G_MISS_CHAR, NULL, p_assoc_information6),
    assoc_information7  =   DECODE (p_assoc_information7,  NULL, assoc_information7,  FND_API.G_MISS_CHAR, NULL, p_assoc_information7),
    assoc_information8  =   DECODE (p_assoc_information8,  NULL, assoc_information8,  FND_API.G_MISS_CHAR, NULL, p_assoc_information8),
    assoc_information9  =   DECODE (p_assoc_information9,  NULL, assoc_information9,  FND_API.G_MISS_CHAR, NULL, p_assoc_information9),
    assoc_information10 =   DECODE (p_assoc_information10, NULL, assoc_information10, FND_API.G_MISS_CHAR, NULL, p_assoc_information10),
    assoc_information11 =   DECODE (p_assoc_information11, NULL, assoc_information11, FND_API.G_MISS_CHAR, NULL, p_assoc_information11),
    assoc_information12 =   DECODE (p_assoc_information12, NULL, assoc_information12, FND_API.G_MISS_CHAR, NULL, p_assoc_information12),
    assoc_information13 =   DECODE (p_assoc_information13, NULL, assoc_information13, FND_API.G_MISS_CHAR, NULL, p_assoc_information13),
    assoc_information14 =   DECODE (p_assoc_information14, NULL, assoc_information14, FND_API.G_MISS_CHAR, NULL, p_assoc_information14),
    assoc_information15 =   DECODE (p_assoc_information15, NULL, assoc_information15, FND_API.G_MISS_CHAR, NULL, p_assoc_information15),
    assoc_information16 =   DECODE (p_assoc_information16, NULL, assoc_information16, FND_API.G_MISS_CHAR, NULL, p_assoc_information16),
    assoc_information17 =   DECODE (p_assoc_information17, NULL, assoc_information17, FND_API.G_MISS_CHAR, NULL, p_assoc_information17),
    assoc_information18 =   DECODE (p_assoc_information18, NULL, assoc_information18, FND_API.G_MISS_CHAR, NULL, p_assoc_information18),
    assoc_information19 =   DECODE (p_assoc_information19, NULL, assoc_information19, FND_API.G_MISS_CHAR, NULL, p_assoc_information19),
    assoc_information20 =   DECODE (p_assoc_information20, NULL, assoc_information20, FND_API.G_MISS_CHAR, NULL, p_assoc_information20),
    object_version_number = DECODE(p_object_version_number, NULL, object_version_number, FND_API.G_MISS_NUM, NULL, p_object_version_number),
    last_update_date    =   NVL(p_last_update_date, XLE_UTILITY_PUB.LAST_UPDATE_DATE),
    last_updated_by     =   NVL(p_last_updated_by, XLE_UTILITY_PUB.LAST_UPDATED_BY),
    last_update_login   =   NVL(p_last_update_login, XLE_UTILITY_PUB.LAST_UPDATE_LOGIN)

  WHERE  association_id =   p_association_id;

  IF (sql%notfound) THEN
      RAISE no_data_found;
  END IF;
END Update_Row;

PROCEDURE Delete_Row(p_association_id IN NUMBER) IS
BEGIN
    DELETE FROM xle_associations
    WHERE association_id = p_association_id;

    IF (sql%notfound) THEN
        RAISE no_data_found;
    END IF;
END Delete_Row;



PROCEDURE Lock_Row(
  p_association_id		IN NUMBER,
  p_object_version_number	IN NUMBER
) IS
    CURSOR C IS
        SELECT * FROM xle_associations
        WHERE association_id = p_association_id
        FOR UPDATE OF association_id NOWAIT;
    Recinfo C%ROWTYPE;
BEGIN

    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
        CLOSE C;
        FND_MESSAGE.Set_Name('XLE', 'XLE_API_NO_RECORD');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE C;

    IF NOT
    (
     (p_object_version_number IS NULL AND Recinfo.object_version_number IS NULL)
     OR
     (p_object_version_number IS NOT NULL AND Recinfo.object_version_number IS NOT NULL AND
      p_object_version_number = Recinfo.object_version_number)
    )
    THEN
        FND_MESSAGE.Set_Name('XLE', 'XLE_API_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

END Lock_Row;

END XLE_Association_PKG;


/
