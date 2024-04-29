--------------------------------------------------------
--  DDL for Package Body CSC_PROF_CHECK_RATINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_CHECK_RATINGS_PKG" as
/* $Header: csctprab.pls 120.5 2006/07/21 06:13:23 adhanara ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_CHECK_RATINGS_PKG
-- Purpose          :
-- History          :
--	03 Nov 00 axsubram  Added  load_row (# 1487338)
--	03 Nov 00 axsubram	File name constant corrected to csctprab.pls
-- 07 Nov 02 jamose Upgrade table handler changes
-- 26 Nov 02 jamose made changes for the NOCOPY and FND_API.G_MISS*
-- 19 july 2005 tpalaniv Modified the load_row API to fetch last_updated_by using FND API
-- 19-09-2005 vshastry Bug 4596220. Added condition in insert row
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROF_CHECK_RATINGS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctprab.pls';

G_MISS_CHAR VARCHAR2(1) := FND_API.G_MISS_CHAR;
G_MISS_NUM NUMBER := FND_API.G_MISS_NUM;
G_MISS_DATE DATE := FND_API.G_MISS_DATE;

PROCEDURE Insert_Row(
          px_CHECK_RATING_ID   IN OUT NOCOPY NUMBER,
          p_CHECK_ID             NUMBER,
          p_CHECK_RATING_GRADE   VARCHAR2,
          p_RATING_CODE          VARCHAR2,
          p_COLOR_CODE           VARCHAR2,
          p_RANGE_LOW_VALUE      VARCHAR2,
          p_RANGE_HIGH_VALUE     VARCHAR2,
          p_LAST_UPDATE_DATE     DATE,
          p_LAST_UPDATED_BY      NUMBER,
          p_CREATION_DATE        DATE,
          p_CREATED_BY           NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG          VARCHAR2)

 IS
   CURSOR C2 IS SELECT CSC_PROF_CHECK_RATINGS_S.nextval FROM sys.dual;
   ps_SEEDED_FLAG    Varchar2(3);
BEGIN

   /* added the below 2 lines for bug 4596220 */
   ps_seeded_flag := p_seeded_flag;
   IF NVL(p_seeded_flag, 'N') <> 'Y' THEN

   /* Added This If Condition for Bug 1944040*/
      If p_Created_by=1 then
           ps_seeded_flag:='Y';
      Else
           ps_seeded_flag:='N';
      End If;
   END IF;

   If (px_CHECK_RATING_ID IS NULL) OR (px_CHECK_RATING_ID = G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_CHECK_RATING_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSC_PROF_CHECK_RATINGS(
           CHECK_RATING_ID,
           CHECK_ID,
           CHECK_RATING_GRADE,
           RATING_CODE,
           COLOR_CODE,
           RANGE_LOW_VALUE,
           RANGE_HIGH_VALUE,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           SEEDED_FLAG
          ) VALUES (
           px_CHECK_RATING_ID,
           decode( p_CHECK_ID, G_MISS_NUM, NULL, p_CHECK_ID),
           decode( p_CHECK_RATING_GRADE, G_MISS_CHAR, NULL, p_CHECK_RATING_GRADE),
           decode( p_RATING_CODE, G_MISS_CHAR, NULL, p_RATING_CODE),
           decode( p_COLOR_CODE, G_MISS_CHAR, NULL, p_COLOR_CODE),
           decode( p_RANGE_LOW_VALUE, G_MISS_CHAR, NULL, p_RANGE_LOW_VALUE),
           decode( p_RANGE_HIGH_VALUE,G_MISS_CHAR, NULL, p_RANGE_HIGH_VALUE),
           decode( p_LAST_UPDATE_DATE, G_MISS_DATE, to_date(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY, G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_CREATION_DATE, G_MISS_DATE, to_date(NULL), p_CREATION_DATE),
           decode( p_CREATED_BY, G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_LAST_UPDATE_LOGIN, G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_SEEDED_FLAG, G_MISS_CHAR, NULL, ps_SEEDED_FLAG));
End Insert_Row;

PROCEDURE Update_Row(
          p_CHECK_RATING_ID    NUMBER,
          p_CHECK_ID    NUMBER,
          p_CHECK_RATING_GRADE    VARCHAR2,
          p_RATING_CODE    VARCHAR2,
          p_COLOR_CODE    VARCHAR2,
          p_RANGE_LOW_VALUE    VARCHAR2,
          p_RANGE_HIGH_VALUE    VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG      VARCHAR2)

 IS
 BEGIN
    Update CSC_PROF_CHECK_RATINGS
    SET
              CHECK_ID = p_CHECK_ID,
              CHECK_RATING_GRADE = p_CHECK_RATING_GRADE,
              RATING_CODE = p_RATING_CODE,
              COLOR_CODE = p_COLOR_CODE,
              RANGE_LOW_VALUE = p_RANGE_LOW_VALUE,
              RANGE_HIGH_VALUE = p_RANGE_HIGH_VALUE,
              LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
              LAST_UPDATED_BY = p_LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
              SEEDED_FLAG  = p_SEEDED_FLAG
    where CHECK_RATING_ID = p_CHECK_RATING_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;


PROCEDURE Lock_Row(
          p_CHECK_RATING_ID    NUMBER,
          p_CHECK_ID    NUMBER,
          p_CHECK_RATING_GRADE    VARCHAR2,
          --p_RATING_COLOR_ID    NUMBER,
          p_RATING_CODE    VARCHAR2,
          p_COLOR_CODE    VARCHAR2,
          p_RANGE_LOW_VALUE    VARCHAR2,
          p_RANGE_HIGH_VALUE    VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM CSC_PROF_CHECK_RATINGS
        WHERE CHECK_RATING_ID =  p_CHECK_RATING_ID
        FOR UPDATE of CHECK_RATING_ID NOWAIT;
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
    /* Bug 5245779 Only auditable columns in the table need to be verified */
    if (
           (      Recinfo.CHECK_RATING_ID = p_CHECK_RATING_ID)
       AND (    ( Recinfo.CHECK_ID = p_CHECK_ID)
            OR (    ( Recinfo.CHECK_ID IS NULL )
                AND (  p_CHECK_ID IS NULL )))
       AND (    ( to_char(Recinfo.LAST_UPDATE_DATE,'dd-mon-rrrr') = to_char(p_LAST_UPDATE_DATE,'dd-mon-rrrr'))
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))

       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;




PROCEDURE Delete_Row(
    p_CHECK_RATING_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSC_PROF_CHECK_RATINGS
    WHERE CHECK_RATING_ID = p_CHECK_RATING_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Load_Row(
          p_CHECK_RATING_ID      NUMBER,
          p_CHECK_ID             NUMBER,
          p_CHECK_RATING_GRADE   VARCHAR2,
          p_RATING_CODE          VARCHAR2,
          p_COLOR_CODE           VARCHAR2,
          p_RANGE_LOW_VALUE      VARCHAR2,
          p_RANGE_HIGH_VALUE     VARCHAR2,
          p_LAST_UPDATE_DATE     DATE,
          p_LAST_UPDATED_BY      NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG          VARCHAR2,
		P_Owner			   VARCHAR2)
  IS
	     l_user_id	number := 0;
	     l_check_rating_id	number := G_MISS_NUM;

		/** This is mainly for loading seed data . That is the
		  reason, that l_check_rating_id is being declared here, The
		  check_rating_id returned from insert_row is not used.

		**/
   BEGIN

         l_check_rating_id := p_check_rating_id;

 	 Csc_Prof_Check_Ratings_Pkg.Update_Row(
           	p_CHECK_RATING_ID   	=> p_check_rating_id,
           	p_CHECK_ID    	        => p_check_id,
          	p_CHECK_RATING_GRADE    => p_check_rating_grade,
          	p_RATING_CODE           => p_rating_code,
          	p_COLOR_CODE            => p_color_code,
          	p_RANGE_LOW_VALUE    	=> p_range_low_value,
          	p_RANGE_HIGH_VALUE      => p_range_high_value,
          	p_LAST_UPDATE_DATE   	=> p_last_update_date,
          	p_LAST_UPDATED_BY    	=> p_last_updated_by,
          	p_LAST_UPDATE_LOGIN  	=> 0,
                p_SEEDED_FLAG           => p_seeded_flag);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN

         Csc_Prof_Check_Ratings_Pkg.Insert_Row(
          		px_CHECK_RATING_ID     => l_check_rating_id,
          		p_CHECK_ID    	       => p_check_id,
          		p_CHECK_RATING_GRADE   => p_check_rating_grade,
          		p_RATING_CODE          => p_rating_code,
          		p_COLOR_CODE           => p_color_code,
          		p_RANGE_LOW_VALUE      => p_range_low_value,
          		p_RANGE_HIGH_VALUE     => p_range_high_value,
                        p_LAST_UPDATE_DATE     => p_last_update_date,
          		p_LAST_UPDATED_BY      => p_last_updated_by,
          		p_CREATION_DATE        => p_last_update_date,
          		p_CREATED_BY           => p_last_updated_by,
          		p_LAST_UPDATE_LOGIN    => 0,
                        p_SEEDED_FLAG          => p_seeded_flag);


   End Load_Row;


End CSC_PROF_CHECK_RATINGS_PKG;

/
