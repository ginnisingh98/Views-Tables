--------------------------------------------------------
--  DDL for Package Body ICX_QUESTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_QUESTIONS_PKG" as
/* $Header: ICXQUESB.pls 115.3 1999/11/12 15:35:18 pkm ship  $ */

procedure INSERT_ROW (
  X_ROWID			in out VARCHAR2,
  X_QUESTION_CODE 	in 	VARCHAR2,
  X_APPLICATION_ID 		in	NUMBER,
  X_TYPE			in VARCHAR2,
  X_QUESTION 		in 	VARCHAR2,
  X_CREATION_DATE 		in 	DATE,
  X_CREATED_BY 			in 	NUMBER,
  X_LAST_UPDATE_DATE 		in 	DATE,
  X_LAST_UPDATED_BY 		in 	NUMBER,
  X_LAST_UPDATE_LOGIN 		in 	NUMBER
) is
  cursor C is select ROWID from ICX_QUESTIONS
    where QUESTION_CODE = X_QUESTION_CODE;

begin
  insert into ICX_QUESTIONS (
    QUESTION_CODE,
    APPLICATION_ID,
    TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_QUESTION_CODE,
    X_APPLICATION_ID,
    X_TYPE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into ICX_QUESTIONS_TL (
    QUESTION_CODE,
    QUESTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
	SOURCE_LANG
  ) select
    X_QUESTION_CODE,
    X_QUESTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG IN ('I','B')
  and   not exists
    (select NULL
     from   ICX_QUESTIONS_TL T
     where  T.QUESTION_CODE = X_QUESTION_CODE
     and    T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
	raise no_data_found;
  end if;
  close c;
end INSERT_ROW;

procedure UPDATE_ROW (
  X_QUESTION_CODE		in VARCHAR2,
  X_APPLICATION_ID 			in NUMBER,
  X_TYPE				in VARCHAR2,
  X_QUESTION				in VARCHAR2,
  X_LAST_UPDATE_DATE 		in DATE,
  X_LAST_UPDATED_BY 		in NUMBER,
  X_LAST_UPDATE_LOGIN 		in NUMBER
) is
begin
  update ICX_QUESTIONS set
    APPLICATION_ID = X_APPLICATION_ID,
    TYPE = X_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where QUESTION_CODE = X_QUESTION_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ICX_QUESTIONS_TL set
    QUESTION = X_QUESTION,
    SOURCE_LANG = userenv('LANG'),
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where QUESTION_CODE = X_QUESTION_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure TRANSLATE_ROW (
  X_QUESTION_CODE			in	VARCHAR2,
  X_OWNER				in	VARCHAR2,
  X_QUESTION			in	VARCHAR2) is
begin

  update ICX_QUESTIONS_tl set
    question                 = X_QUESTION,
    SOURCE_LANG		     = userenv('LANG'),
    last_update_date         = sysdate,
    last_updated_by          = decode(X_OWNER, 'SEED', 1, 0),
    last_update_login        = 0
  where question_code = X_QUESTION_CODE
  and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_QUESTION_CODE		in 	VARCHAR2,
  X_OWNER			in	VARCHAR2,
  X_APPLICATION_ID	in 	NUMBER,
  X_TYPE		in	VARCHAR2,
  X_QUESTION	in 	VARCHAR2) is
begin

  declare
     ques_code varchar2(30);
     user_id    number := 0;
     row_id 	varchar2(64);

  begin
     if (X_OWNER = 'SEED') then
       user_id := 1;
     end if;

     select QUESTION_CODE into ques_code
     from   ICX_QUESTIONS
     where  QUESTION_CODE = X_QUESTION_CODE;

     icx_questions_pkg.UPDATE_ROW (
	X_QUESTION_CODE =>		X_QUESTION_CODE,
	X_APPLICATION_ID =>		X_APPLICATION_ID,
	X_TYPE		=>		X_TYPE,
	X_QUESTION =>		X_QUESTION,
	X_LAST_UPDATE_DATE =>		sysdate,
	X_LAST_UPDATED_BY =>		user_id,
	X_LAST_UPDATE_LOGIN =>		0);

  exception
     when NO_DATA_FOUND then

       icx_questions_pkg.INSERT_ROW (
	X_ROWID =>				row_id,
	X_QUESTION_CODE =>		X_QUESTION_CODE,
	X_APPLICATION_ID =>		X_APPLICATION_ID,
	X_TYPE =>			X_TYPE,
	X_QUESTION =>		X_QUESTION,
	X_CREATION_DATE => 		sysdate,
	X_CREATED_BY => 		user_id,
	X_LAST_UPDATE_DATE =>		sysdate,
	X_LAST_UPDATED_BY =>		user_id,
	X_LAST_UPDATE_LOGIN =>		0);
  end;
end LOAD_ROW;

--*****************************************************************************
procedure ADD_LANGUAGE
is
begin
  delete from ICX_QUESTIONS_TL T
  where not exists
    (select NULL
    from ICX_QUESTIONS B
    where B.QUESTION_CODE = T.QUESTION_CODE
    );

  update ICX_QUESTIONS_TL T set (
      QUESTION
    ) = (select
      B.QUESTION
    from ICX_QUESTIONS_TL B
    where B.QUESTION_CODE = T.QUESTION_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.QUESTION_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.QUESTION_CODE,
      SUBT.LANGUAGE
    from ICX_QUESTIONS_TL SUBB, ICX_QUESTIONS_TL SUBT
    where SUBB.QUESTION_CODE = SUBT.QUESTION_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.QUESTION <> SUBT.QUESTION
      or (SUBB.QUESTION is null and SUBT.QUESTION is not null)
  ));

  insert into ICX_QUESTIONS_TL (
    QUESTION_CODE,
    QUESTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.QUESTION_CODE,
    B.QUESTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ICX_QUESTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ICX_QUESTIONS_TL T
    where T.QUESTION_CODE = B.QUESTION_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ICX_QUESTIONS_PKG;

/
