--------------------------------------------------------
--  DDL for Package Body CN_REASON_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_REASON_HISTORY_PKG" AS
/* $Header: cnthistb.pls 115.1 2002/04/24 12:04:56 pkm ship       $*/


-- * -------------------------------------------------------------------------*
--   Procedure Name
--	Insert_row
--   Purpose
--      Main insert procedure
--   Note
--      1. Primary key should be populated from sequence before call
--         this procedure. No refernece to sequence in this procedure.
--      2. All paramaters are IN parameter.
-- * -------------------------------------------------------------------------*
PROCEDURE insert_row
    ( p_reason_history_all_rec IN REASON_HISTORY_ALL_REC_TYPE) IS
   --
   l_reason	VARCHAR2(8000);
   --
BEGIN
   l_reason := p_reason_history_all_rec.reason;
   INSERT into CN_REASON_HISTORY_ALL
      ( REASON_HISTORY_ID,
        REASON_ID,
        UPDATED_TABLE,
        UPD_TABLE_ID,
        REASON,
        REASON_CODE,
        DML_FLAG,
	LOOKUP_TYPE,
	UPDATE_FLAG,
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
        ATTRIBUTE15,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
    select
       DECODE(p_reason_history_all_rec.REASON_HISTORY_ID, FND_API.G_MISS_NUM, NULL,
              p_reason_history_all_rec.REASON_HISTORY_ID),
       DECODE(p_reason_history_all_rec.REASON_ID, FND_API.G_MISS_NUM, NULL,
              p_reason_history_all_rec.REASON_ID),
       DECODE(p_reason_history_all_rec.UPDATED_TABLE, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.UPDATED_TABLE),
       DECODE(p_reason_history_all_rec.UPD_TABLE_ID, FND_API.G_MISS_NUM, NULL,
              p_reason_history_all_rec.UPD_TABLE_ID),
       l_reason,
       DECODE(p_reason_history_all_rec.REASON_CODE, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.REASON_CODE),
       DECODE(p_reason_history_all_rec.DML_FLAG, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.DML_FLAG),
       DECODE(p_reason_history_all_rec.LOOKUP_TYPE, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.LOOKUP_TYPE),
       DECODE(p_reason_history_all_rec.UPDATE_FLAG, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.UPDATE_FLAG),
       DECODE(p_reason_history_all_rec.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE_CATEGORY),
       DECODE(p_reason_history_all_rec.ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE1),
       DECODE(p_reason_history_all_rec.ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE2),
       DECODE(p_reason_history_all_rec.ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE3),
       DECODE(p_reason_history_all_rec.ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE4),
       DECODE(p_reason_history_all_rec.ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE5),
       DECODE(p_reason_history_all_rec.ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE6),
       DECODE(p_reason_history_all_rec.ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE7),
       DECODE(p_reason_history_all_rec.ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE8),
       DECODE(p_reason_history_all_rec.ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE9),
       DECODE(p_reason_history_all_rec.ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE10),
       DECODE(p_reason_history_all_rec.ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE11),
       DECODE(p_reason_history_all_rec.ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE12),
       DECODE(p_reason_history_all_rec.ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE13),
       DECODE(p_reason_history_all_rec.ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE14),
       DECODE(p_reason_history_all_rec.ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL,
              p_reason_history_all_rec.ATTRIBUTE15),
        fnd_global.user_id,
        Sysdate,
        Sysdate,
        fnd_global.user_id,
        fnd_global.login_id,
        1
   from dual;
END insert_row;
-- * -------------------------------------------------------------------------*
--   Procedure Name
--	delete_row
--   Purpose
--      Main lcok and update procedure
--   Note
--      1. All paramaters are IN parameter.
--      2. Raise NO_DATA_FOUND exception if no reocrd deleted (??)
-- * -------------------------------------------------------------------------*
PROCEDURE delete_row(
      p_reason_history_id	NUMBER) IS

BEGIN
   DELETE FROM CN_REASON_HISTORY_ALL
     WHERE reason_history_id = p_reason_history_id;
   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;
END Delete_row;
--
END CN_REASON_HISTORY_PKG;

/
