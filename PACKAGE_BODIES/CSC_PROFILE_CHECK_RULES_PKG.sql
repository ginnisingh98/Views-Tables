--------------------------------------------------------
--  DDL for Package Body CSC_PROFILE_CHECK_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROFILE_CHECK_RULES_PKG" as
/* $Header: csctpcrb.pls 120.3 2005/09/18 23:46:20 vshastry ship $ */
-- Start of Comments
-- Package name     : CSC_PROFILE_CHECK_RULES_PKG
-- Purpose          :
-- History          :
-- 08-NOV-00  madhavan Added procedures translate_row and load_row. Fix to
--                     bug # 1491205
-- 07 Nov 02   jamose Upgrade table handler changes
-- 18 Nov 02   jamose made changes for the NOCOPY and FND_API.G_MISS*
-- 19 july 2005 tpalaniv Deriving last_updated_by based on FND API for R12 ATG Project - Seed Data Versioning
-- 19-09-2005 vshastry Bug 4596220. Added condition in insert row
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROFILE_CHECK_RULES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctucrb.pls';

G_MISS_CHAR VARCHAR2(1) := FND_API.G_MISS_CHAR;
G_MISS_NUM NUMBER := FND_API.G_MISS_NUM;
G_MISS_DATE DATE := FND_API.G_MISS_DATE;

PROCEDURE Insert_Row(
          p_CHECK_ID   IN NUMBER,
          p_SEQUENCE    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LOGICAL_OPERATOR    VARCHAR2,
          p_LEFT_PAREN    VARCHAR2,
          p_BLOCK_ID    NUMBER,
          p_COMPARISON_OPERATOR    VARCHAR2,
          p_EXPRESSION    VARCHAR2,
          p_EXPR_TO_BLOCK_ID    NUMBER,
          p_RIGHT_PAREN    VARCHAR2,
          p_SEEDED_FLAG    VARCHAR2,
          X_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER )

 IS
 --  CURSOR C2 IS SELECT CSC_PROF_CHECK_RULES_S.nextval FROM sys.dual;
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

/*
   If (px_CHECK_ID IS NULL) OR (px_CHECK_ID = CSC_CORE_UTILS_PVT.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_CHECK_ID;
       CLOSE C2;
   End If;
*/
   x_object_version_number := 1;

   INSERT INTO CSC_PROF_CHECK_RULES_B(
           CHECK_ID,
           SEQUENCE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           LOGICAL_OPERATOR,
           LEFT_PAREN,
           BLOCK_ID,
           COMPARISON_OPERATOR,
           --EXPRESSION1,
    	     EXPR_TO_BLOCK_ID,
           RIGHT_PAREN,
           SEEDED_FLAG,
           OBJECT_VERSION_NUMBER
          ) VALUES (
           p_CHECK_ID,
           decode( p_SEQUENCE, G_MISS_NUM, NULL, p_SEQUENCE),
           decode( p_CREATED_BY, G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN,G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_LOGICAL_OPERATOR, G_MISS_CHAR, NULL, p_LOGICAL_OPERATOR),
           decode( p_LEFT_PAREN, G_MISS_CHAR, NULL, p_LEFT_PAREN),
           decode( p_BLOCK_ID, G_MISS_NUM, NULL, p_BLOCK_ID),
           decode( p_COMPARISON_OPERATOR, G_MISS_CHAR, NULL, p_COMPARISON_OPERATOR),
           --decode( p_EXPRESSION, CSC_CORE_UTILS_PVT.G_MISS_CHAR, NULL, p_EXPRESSION),
           decode( p_EXPR_TO_BLOCK_ID, G_MISS_NUM, NULL, p_EXPR_TO_BLOCK_ID),
           decode( p_RIGHT_PAREN, G_MISS_CHAR, NULL, p_RIGHT_PAREN),
           decode( p_SEEDED_FLAG, G_MISS_CHAR, NULL, ps_SEEDED_FLAG),
           x_object_version_number);

   INSERT INTO CSC_PROF_CHECK_RULES_TL(
    	     CHECK_ID,
    	     SEQUENCE,
    	     EXPRESSION,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           LANGUAGE,
           SOURCE_LANG
          )select
           p_CHECK_ID,
           decode( p_SEQUENCE, G_MISS_NUM, NULL, p_SEQUENCE),
           decode( p_EXPRESSION, G_MISS_CHAR, NULL, p_EXPRESSION),
           decode( p_CREATED_BY, G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
    	     L.LANGUAGE_CODE,
    	     userenv('LANG')
      from FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B')
      and not exists
    	 ( select NULL
           from CSC_PROF_CHECK_RULES_TL T
           where T.CHECK_ID = P_CHECK_ID
		 and   t.sequence = p_sequence
           and T.LANGUAGE = L.LANGUAGE_CODE );


End Insert_Row;

PROCEDURE Update_Row(
          p_CHECK_ID    NUMBER,
          p_SEQUENCE    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LOGICAL_OPERATOR    VARCHAR2,
          p_LEFT_PAREN    VARCHAR2,
          p_BLOCK_ID    NUMBER,
          p_COMPARISON_OPERATOR    VARCHAR2,
          p_EXPRESSION    VARCHAR2,
          p_EXPR_TO_BLOCK_ID    NUMBER,
          p_RIGHT_PAREN    VARCHAR2,
          p_SEEDED_FLAG    VARCHAR2,
          px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER)

 IS
 BEGIN
    Update CSC_PROF_CHECK_RULES_B
    SET
              SEQUENCE = p_SEQUENCE,
              LAST_UPDATED_BY = p_LAST_UPDATED_BY,
              LAST_UPDATE_DATE =p_LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
              LOGICAL_OPERATOR = p_LOGICAL_OPERATOR,
              LEFT_PAREN = p_LEFT_PAREN,
              BLOCK_ID = p_BLOCK_ID,
              COMPARISON_OPERATOR = p_COMPARISON_OPERATOR,
              --EXPRESSION1 = decode( p_EXPRESSION1, CSC_CORE_UTILS_PVT.G_MISS_CHAR, EXPRESSION1, p_EXPRESSION1),
              EXPR_TO_BLOCK_ID = p_EXPR_TO_BLOCK_ID,
              RIGHT_PAREN = p_RIGHT_PAREN,
              SEEDED_FLAG = p_SEEDED_FLAG,
              OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
    where CHECK_ID = p_CHECK_ID
     and SEQUENCE = p_SEQUENCE
    returning OBJECT_VERSION_NUMBER INTO px_OBJECT_VERSION_NUMBER;

    update CSC_PROF_CHECK_RULES_TL set
              EXPRESSION = p_EXPRESSION,
              LAST_UPDATED_BY = p_LAST_UPDATED_BY,
              LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
    		  SOURCE_LANG = userenv('LANG')
    where CHECK_ID = P_CHECK_ID
    and SEQUENCE = p_SEQUENCE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

END Update_Row;

procedure LOCK_ROW (
  P_CHECK_ID in NUMBER,
  P_SEQUENCE IN NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      SEQUENCE,
      LOGICAL_OPERATOR,
      LEFT_PAREN,
      BLOCK_ID,
      COMPARISON_OPERATOR,
      EXPR_TO_BLOCK_ID,
      RIGHT_PAREN,
      OBJECT_VERSION_NUMBER
    from CSC_PROF_CHECK_RULES_B
    where CHECK_ID = P_CHECK_ID
    and SEQUENCE = p_SEQUENCE
    and object_version_number = P_OBJECT_VERSION_NUMBER
    for update of CHECK_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      EXPRESSION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CSC_PROF_CHECK_RULES_TL
    where CHECK_ID = P_CHECK_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    and SEQUENCE = p_SEQUENCE
    for update of CHECK_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  close c;
  return;
end LOCK_ROW;

procedure DELETE_ROW (
  P_CHECK_ID    NUMBER,
  P_SEQUENCE    NUMBER,
  P_OBJECT_VERSION_NUMBER NUMBER
) is
begin
  delete from CSC_PROF_CHECK_RULES_TL
  where CHECK_ID = P_CHECK_ID
  and SEQUENCE = p_SEQUENCE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CSC_PROF_CHECK_RULES_B
  where CHECK_ID = P_CHECK_ID
  and SEQUENCE = P_SEQUENCE
  and OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure ADD_LANGUAGE
is
begin
  delete from CSC_PROF_CHECK_RULES_TL T
  where not exists
    (select NULL
    from CSC_PROF_CHECK_RULES_B B
    where B.CHECK_ID = T.CHECK_ID
    and B.SEQUENCE = T.SEQUENCE
    );

  update CSC_PROF_CHECK_RULES_TL T set (
      EXPRESSION
    ) = (select
      B.EXPRESSION
    from CSC_PROF_CHECK_RULES_TL B
    where B.CHECK_ID = T.CHECK_ID
    and B.SEQUENCE = T.SEQUENCE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHECK_ID,
      T.SEQUENCE,
      T.LANGUAGE
  ) in (select
      SUBT.CHECK_ID,
      SUBT.SEQUENCE,
      SUBT.LANGUAGE
    from CSC_PROF_CHECK_RULES_TL SUBB, CSC_PROF_CHECK_RULES_TL SUBT
    where SUBB.CHECK_ID = SUBT.CHECK_ID
    and SUBB.SEQUENCE = SUBT.SEQUENCE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.EXPRESSION <> SUBT.EXPRESSION
      or (SUBB.EXPRESSION is null and SUBT.EXPRESSION is not null)
      or (SUBB.EXPRESSION is not null and SUBT.EXPRESSION is null)
  ));

  insert into CSC_PROF_CHECK_RULES_TL (
    CHECK_ID,
    SEQUENCE,
    EXPRESSION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CHECK_ID,
    B.SEQUENCE,
    B.EXPRESSION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSC_PROF_CHECK_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSC_PROF_CHECK_RULES_TL T
    where T.CHECK_ID = B.CHECK_ID
    and T.SEQUENCE = B.SEQUENCE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

-- Fix for bug #1491205

procedure TRANSLATE_ROW (
  p_check_id    IN   NUMBER,
  p_sequence    IN   NUMBER,
  p_expression  IN   VARCHAR2,
  p_owner       IN   VARCHAR2)
IS
BEGIN
    UPDATE  csc_prof_check_rules_tl
    SET expression        =   NVL(p_expression,expression),
        last_update_date  =   sysdate,
        last_updated_by   =   fnd_load_util.owner_id(p_owner), /* removed the decode logic for R12 mandate DECODE(p_owner, 'SEED', 1, 0),     */
        last_update_login =   0,
        source_lang       =   userenv('LANG')
    WHERE  check_id       =  p_check_id
      AND  sequence       =  p_sequence
      AND  userenv('LANG') IN (language, source_lang) ;
end TRANSLATE_ROW ;


PROCEDURE LOAD_ROW (
            p_CHECK_ID                IN NUMBER,
            p_SEQUENCE                IN NUMBER,
            p_LAST_UPDATED_BY         IN NUMBER,
            p_LAST_UPDATE_DATE        IN DATE,
            p_LAST_UPDATE_LOGIN       IN NUMBER,
            p_LOGICAL_OPERATOR        IN VARCHAR2,
            p_LEFT_PAREN              IN VARCHAR2,
            p_BLOCK_ID                IN NUMBER,
            p_COMPARISON_OPERATOR     IN VARCHAR2,
            p_EXPRESSION              IN VARCHAR2,
            p_EXPR_TO_BLOCK_ID        IN NUMBER,
            p_RIGHT_PAREN             IN VARCHAR2,
            p_SEEDED_FLAG             IN VARCHAR2,
            px_OBJECT_VERSION_NUMBER  IN OUT NOCOPY NUMBER,
            p_OWNER                   IN VARCHAR2)
IS
 l_user_id                NUMBER  := 0;
 l_object_version_number  NUMBER  := 0;
 l_check_id               NUMBER  := p_check_id ;
 l_sequence               NUMBER  := p_sequence ;

BEGIN

         Csc_Profile_Check_Rules_Pkg.Update_Row(
            p_CHECK_ID                => p_check_id,
            p_SEQUENCE                => p_sequence,
            p_LAST_UPDATED_BY         => p_last_updated_by,
            p_LAST_UPDATE_DATE        => p_last_update_date,
            p_LAST_UPDATE_LOGIN       => 0,
            p_LOGICAL_OPERATOR        => p_logical_operator,
            p_LEFT_PAREN              => p_left_paren,
            p_BLOCK_ID                => p_block_id,
            p_COMPARISON_OPERATOR     => p_comparison_operator,
            p_EXPRESSION              => p_expression,
            p_EXPR_TO_BLOCK_ID        => p_expr_to_block_id,
            p_RIGHT_PAREN             => p_right_paren,
            p_SEEDED_FLAG             => p_seeded_flag,
            px_OBJECT_VERSION_NUMBER  => l_object_version_number );

          exception when no_data_found then

              Csc_Profile_Check_Rules_Pkg.Insert_Row(
          	p_CHECK_ID              => l_check_id,
          	p_SEQUENCE              => l_sequence,
          	p_CREATED_BY            => p_last_updated_by,
          	p_CREATION_DATE         => p_last_update_date,
          	p_LAST_UPDATED_BY       => p_last_updated_by,
          	p_LAST_UPDATE_DATE      => p_last_update_date,
          	p_LAST_UPDATE_LOGIN     => 0,
          	p_LOGICAL_OPERATOR      => p_logical_operator,
          	p_LEFT_PAREN            => p_left_paren,
          	p_BLOCK_ID              => p_block_id,
          	p_COMPARISON_OPERATOR   => p_comparison_operator,
          	p_EXPRESSION            => p_expression,
          	p_EXPR_TO_BLOCK_ID      => p_expr_to_block_id,
          	p_RIGHT_PAREN           => p_right_paren,
                p_SEEDED_FLAG           => p_seeded_flag,
          	X_OBJECT_VERSION_NUMBER => px_object_version_number);
END LOAD_ROW;

-- End of fix for bug #1491205

End CSC_PROFILE_CHECK_RULES_PKG;

/
