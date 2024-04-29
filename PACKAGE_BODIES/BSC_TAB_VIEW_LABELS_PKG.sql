--------------------------------------------------------
--  DDL for Package Body BSC_TAB_VIEW_LABELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_TAB_VIEW_LABELS_PKG" as
/* $Header: BSCTBVLB.pls 120.0 2005/06/01 16:45:44 appldev noship $ */

PROCEDURE TRANSLATE_ROW
(
    X_TAB_ID            IN      NUMBER,
    X_TAB_VIEW_ID       IN      NUMBER,
    X_LABEL_ID          IN      NUMBER,
    X_NAME              IN      VARCHAR2,
    X_NOTE              IN      VARCHAR2,
    X_LAST_UPDATE_DATE  IN      DATE,
    X_LAST_UPDATED_BY   IN      NUMBER,
    X_LAST_UPDATE_LOGIN IN      NUMBER
) IS
    L_TAB           NUMBER := -1;
BEGIN
    SELECT COUNT(*) INTO L_TAB   FROM   BSC_TAB_VIEW_LABELS_TL WHERE  TAB_ID = X_TAB_ID
                                 AND    TAB_VIEW_ID = X_TAB_VIEW_ID
                                 AND    LABEL_ID    = X_LABEL_ID;
    IF (L_TAB > 0) THEN
        UPDATE  BSC_TAB_VIEW_LABELS_TL SET
                NAME              =   NVL(X_NAME,            NAME),
                NOTE              =   NVL(X_NOTE,            NOTE),
                LAST_UPDATE_DATE  =   NVL(X_LAST_UPDATE_DATE, SYSDATE),
                LAST_UPDATED_BY   =   X_LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN =   X_LAST_UPDATE_LOGIN,
                SOURCE_LANG       =   USERENV('LANG')
        WHERE   USERENV('LANG')   IN  (LANGUAGE, SOURCE_LANG)
        AND     TAB_ID            =   X_TAB_ID
        AND     TAB_VIEW_ID       =   X_TAB_VIEW_ID
        AND     LABEL_ID          =   X_LABEL_ID
        AND     LAST_UPDATE_DATE  <=  X_LAST_UPDATE_DATE;
    ELSE
        RAISE NO_DATA_FOUND;
    END IF;

END TRANSLATE_ROW;


procedure INSERT_ROW (
  X_ROWID 		in out NOCOPY VARCHAR2,
  X_TAB_ID 		in NUMBER,
  X_TAB_VIEW_ID 	in NUMBER,
  X_LABEL_ID 		in NUMBER,
  X_LABEL_TYPE 		in NUMBER,
  X_LINK_ID 		in NUMBER,
  X_NAME 		in VARCHAR2,
  X_NOTE 		in VARCHAR2,
  X_TEXT_FLAG 		in NUMBER,
  X_LEFT_POSITION 	in NUMBER,
  X_TOP_POSITION 	in NUMBER,
  X_WIDTH 		in NUMBER,
  X_HEIGHT 		in NUMBER,
  X_FONT_SIZE 		in NUMBER,
  X_FONT_STYLE 		in NUMBER,
  X_FONT_COLOR 		in NUMBER,
  X_URL 		in VARCHAR2,
  X_FUNCTION_ID in NUMBER,
  X_CREATION_DATE 	in DATE,
  X_CREATED_BY 		in NUMBER,
  X_LAST_UPDATE_DATE 	in DATE,
  X_LAST_UPDATED_BY 	in NUMBER,
  X_LAST_UPDATE_LOGIN 	in NUMBER
) is
  cursor C is select ROWID from BSC_TAB_VIEW_LABELS_B
    where TAB_ID = X_TAB_ID
    and TAB_VIEW_ID = X_TAB_VIEW_ID
    and LABEL_ID = X_LABEL_ID
    ;

begin

  insert into BSC_TAB_VIEW_LABELS_B (
	  TAB_ID,
	  TAB_VIEW_ID,
	  LABEL_ID,
	  LABEL_TYPE,
	  LINK_ID,
      FUNCTION_ID,
	  CREATION_DATE ,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY ,
	  LAST_UPDATE_LOGIN
  ) values (
	  X_TAB_ID,
	  X_TAB_VIEW_ID,
  	  X_LABEL_ID,
	  X_LABEL_TYPE,
	  X_LINK_ID,
      X_FUNCTION_ID,
	  NVL(X_CREATION_DATE , SYSDATE),
	  X_CREATED_BY,
	  NVL(X_LAST_UPDATE_DATE, SYSDATE),
	  X_LAST_UPDATED_BY ,
	  X_LAST_UPDATE_LOGIN
  );

  insert into BSC_TAB_VIEW_LABELS_TL (
	TAB_ID,
	TAB_VIEW_ID,
	LABEL_ID,
	NAME,
	NOTE,
	TEXT_FLAG,
	LEFT_POSITION,
	TOP_POSITION,
	WIDTH,
	HEIGHT,
	FONT_SIZE,
	FONT_STYLE,
	FONT_COLOR,
	URL,
	CREATION_DATE ,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY ,
	LAST_UPDATE_LOGIN,
    	LANGUAGE,
	SOURCE_LANG
  ) select
	X_TAB_ID,
	X_TAB_VIEW_ID,
	X_LABEL_ID,
	X_NAME,
	X_NOTE,
	X_TEXT_FLAG,
	X_LEFT_POSITION,
	X_TOP_POSITION,
	X_WIDTH,
	X_HEIGHT,
	X_FONT_SIZE,
	X_FONT_STYLE,
	X_FONT_COLOR,
	X_URL,
	NVL(X_CREATION_DATE, SYSDATE),
	X_CREATED_BY,
	NVL(X_LAST_UPDATE_DATE, SYSDATE),
	X_LAST_UPDATED_BY ,
	X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_TAB_VIEW_LABELS_TL T
    where T.TAB_ID = X_TAB_ID
    and T.TAB_VIEW_ID = X_TAB_VIEW_ID
    and T.LABEL_ID = X_LABEL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_TAB_ID in NUMBER,
  X_TAB_VIEW_ID in NUMBER,
  X_LABEL_ID in NUMBER,
  X_LABEL_TYPE in NUMBER,
  X_LINK_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_NOTE in VARCHAR2,
  X_TEXT_FLAG in NUMBER,
  X_LEFT_POSITION in NUMBER,
  X_TOP_POSITION in NUMBER,
  X_WIDTH in NUMBER,
  X_HEIGHT in NUMBER,
  X_FONT_SIZE in NUMBER,
  X_FONT_STYLE in NUMBER,
  X_FONT_COLOR in NUMBER,
  X_URL in VARCHAR2
) is
  cursor c is select
	LABEL_TYPE,
	LINK_ID
    from BSC_TAB_VIEW_LABELS_B
    where TAB_ID = X_TAB_ID
    and TAB_VIEW_ID = X_TAB_VIEW_ID
    and LABEL_ID = X_LABEL_ID
    for update of TAB_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
  	NAME,
	NOTE,
	TEXT_FLAG,
	LEFT_POSITION,
	TOP_POSITION,
	WIDTH,
	HEIGHT,
	FONT_SIZE,
	FONT_STYLE,
	FONT_COLOR,
	URL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_TAB_VIEW_LABELS_TL
    where TAB_ID = X_TAB_ID
    and TAB_VIEW_ID = X_TAB_VIEW_ID
    and LABEL_ID = X_LABEL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TAB_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.LABEL_TYPE = X_LABEL_TYPE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND (tlinfo.NOTE = X_NOTE)
          AND (tlinfo.TEXT_FLAG = X_TEXT_FLAG)
          AND (tlinfo.LEFT_POSITION =  X_LEFT_POSITION)
          AND (tlinfo.TOP_POSITION = X_TOP_POSITION)
          AND (tlinfo.WIDTH = X_WIDTH)
          AND (tlinfo.HEIGHT = X_HEIGHT)
          AND (tlinfo.FONT_SIZE = X_FONT_SIZE)
          AND (tlinfo.FONT_STYLE = X_FONT_STYLE)
          AND (tlinfo.FONT_COLOR = X_FONT_COLOR)
          AND (tlinfo.URL= X_URL)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_TAB_ID 		in NUMBER,
  X_TAB_VIEW_ID 	in NUMBER,
  X_LABEL_ID 		in NUMBER,
  X_LABEL_TYPE 		in NUMBER,
  X_LINK_ID 		in NUMBER,
  X_NAME 		in VARCHAR2,
  X_NOTE 		in VARCHAR2,
  X_TEXT_FLAG 		in NUMBER,
  X_LEFT_POSITION 	in NUMBER,
  X_TOP_POSITION 	in NUMBER,
  X_WIDTH 		in NUMBER,
  X_HEIGHT 		in NUMBER,
  X_FONT_SIZE 		in NUMBER,
  X_FONT_STYLE 		in NUMBER,
  X_FONT_COLOR 		in NUMBER,
  X_URL 		in VARCHAR2,
  X_FUNCTION_ID     in NUMBER,
  X_CREATION_DATE 	in DATE,
  X_CREATED_BY 		in NUMBER,
  X_LAST_UPDATE_DATE 	in DATE,
  X_LAST_UPDATED_BY 	in NUMBER,
  X_LAST_UPDATE_LOGIN 	in NUMBER
) is

begin

  update BSC_TAB_VIEW_LABELS_B set
	LABEL_TYPE = NVL(X_LABEL_TYPE, LABEL_TYPE),
	LINK_ID = X_LINK_ID,
    FUNCTION_ID = X_FUNCTION_ID,
	LAST_UPDATE_DATE = NVL(X_LAST_UPDATE_DATE, LAST_UPDATE_DATE),
	LAST_UPDATED_BY = NVL(X_LAST_UPDATED_BY, LAST_UPDATED_BY),
	LAST_UPDATE_LOGIN = NVL(X_LAST_UPDATE_LOGIN, LAST_UPDATE_LOGIN)
  where TAB_ID = X_TAB_ID
  and LABEL_ID = X_LABEL_ID
  and TAB_VIEW_ID = X_TAB_VIEW_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BSC_TAB_VIEW_LABELS_TL set
  	NAME = X_NAME,
	NOTE = X_NOTE,
	TEXT_FLAG = X_TEXT_FLAG,
	LEFT_POSITION = X_LEFT_POSITION,
	TOP_POSITION = X_TOP_POSITION,
	WIDTH = X_WIDTH,
	HEIGHT = X_HEIGHT,
	FONT_SIZE = X_FONT_SIZE,
	FONT_STYLE = X_FONT_STYLE,
	FONT_COLOR = X_FONT_COLOR,
	URL = X_URL,
        LAST_UPDATE_DATE    =   NVL(X_LAST_UPDATE_DATE, SYSDATE),
        LAST_UPDATED_BY     =   X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN   =   X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TAB_ID = X_TAB_ID
  and TAB_VIEW_ID = X_TAB_VIEW_ID
  and LABEL_ID = X_LABEL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TAB_ID in NUMBER,
  X_TAB_VIEW_ID in NUMBER,
  X_LABEL_ID in NUMBER
) is
begin
  delete from BSC_TAB_VIEW_LABELS_TL
  where TAB_ID = X_TAB_ID
  and LABEL_ID = X_LABEL_ID
  and TAB_VIEW_ID = X_TAB_VIEW_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BSC_TAB_VIEW_LABELS_B
  where TAB_ID = X_TAB_ID
  and LABEL_ID = X_LABEL_ID
  and TAB_VIEW_ID = X_TAB_VIEW_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE is
l_user NUMBER;
begin
  SELECT VS.USER#
  INTO  l_user
  FROM V$SESSION VS WHERE VS.AUDSID =USERENV('SESSIONID');

  delete from BSC_TAB_VIEW_LABELS_TL T
  where not exists
    (select NULL
    from BSC_TAB_VIEW_LABELS_B B
    where B.TAB_ID = T.TAB_ID
    and B.LABEL_ID = T.LABEL_ID
    and B.TAB_VIEW_ID = T.TAB_VIEW_ID
    );

  update BSC_TAB_VIEW_LABELS_TL T set (
  	NAME,
	NOTE,
	TEXT_FLAG,
	LEFT_POSITION,
	TOP_POSITION,
	WIDTH,
	HEIGHT,
	FONT_SIZE,
	FONT_STYLE,
	FONT_COLOR,
	URL
    ) = (select
  	B.NAME,
	B.NOTE,
	B.TEXT_FLAG,
	B.LEFT_POSITION,
	B.TOP_POSITION,
	B.WIDTH,
	B.HEIGHT,
	B.FONT_SIZE,
	B.FONT_STYLE,
	B.FONT_COLOR,
	B.URL
    from BSC_TAB_VIEW_LABELS_TL B
    where B.TAB_ID = T.TAB_ID
    and B.LABEL_ID = T.LABEL_ID
    and B.TAB_VIEW_ID = T.TAB_VIEW_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAB_ID,
      T.TAB_VIEW_ID,
      T.LABEL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TAB_ID,
      SUBT.TAB_VIEW_ID,
      SUBT.LABEL_ID,
      SUBT.LANGUAGE
    from BSC_TAB_VIEW_LABELS_TL SUBB, BSC_TAB_VIEW_LABELS_TL SUBT
    where SUBB.TAB_ID = SUBT.TAB_ID
    and SUBB.TAB_VIEW_ID = SUBT.TAB_VIEW_ID
    and SUBB.LABEL_ID = SUBT.LABEL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.NOTE <> SUBT.NOTE
      or SUBB.TEXT_FLAG <> SUBT.TEXT_FLAG
      or SUBB.LEFT_POSITION <> SUBT.LEFT_POSITION
      or SUBB.TOP_POSITION <> SUBT.TOP_POSITION
      or SUBB.WIDTH <> SUBT.WIDTH
      or SUBB.HEIGHT <> SUBT.HEIGHT
      or SUBB.FONT_SIZE <> SUBT.FONT_SIZE
      or SUBB.FONT_STYLE <> SUBT.FONT_STYLE
      or SUBB.FONT_COLOR <> SUBT.FONT_COLOR
      or SUBB.URL <> SUBT.URL
  ));

  insert into BSC_TAB_VIEW_LABELS_TL (
	TAB_ID,
	TAB_VIEW_ID,
	LABEL_ID,
	NAME,
	NOTE,
	TEXT_FLAG,
	LEFT_POSITION,
	TOP_POSITION,
	WIDTH,
	HEIGHT,
	FONT_SIZE,
	FONT_STYLE,
	FONT_COLOR,
	URL,
	CREATION_DATE ,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY ,
	LAST_UPDATE_LOGIN,
	LANGUAGE,
	SOURCE_LANG
  ) select
    B.TAB_ID,
    B.TAB_VIEW_ID,
    B.LABEL_ID,
    B.NAME,
    B.NOTE,
    B.TEXT_FLAG,
    B.LEFT_POSITION,
    B.TOP_POSITION,
    B.WIDTH,
    B.HEIGHT,
    B.FONT_SIZE,
    B.FONT_STYLE,
    B.FONT_COLOR,
    B.URL,
    SYSDATE,
    l_user,
    SYSDATE,
    l_user,
    l_user,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_TAB_VIEW_LABELS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_TAB_VIEW_LABELS_TL T
    where T.TAB_ID = B.TAB_ID
    and T.TAB_VIEW_ID = B.TAB_VIEW_ID
    and T.LABEL_ID = B.LABEL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE UPDATE_LINK
(
        X_SHORT_NAME        IN  VARCHAR2,
        X_TAB_VIEW_ID       IN  NUMBER,
        X_LABEL_ID          IN  NUMBER,
        X_MENU_ID           IN  NUMBER,
        X_LAST_UPDATE_DATE  IN  DATE
) IS
    L_SHORT         NUMBER := -1;
BEGIN
    SELECT COUNT(*) INTO L_SHORT FROM BSC_TAB_VIEW_LABELS_B
                                 WHERE  TAB_ID = (SELECT TAB_ID FROM BSC_TABS_B WHERE SHORT_NAME = X_SHORT_NAME)
                                 AND TAB_VIEW_ID = X_TAB_VIEW_ID
                                 AND LABEL_ID    = X_LABEL_ID;
    IF (L_SHORT > 0) THEN
        UPDATE BSC_TAB_VIEW_LABELS_B
        SET    LINK_ID          =   X_MENU_ID
        WHERE  TAB_ID           =   (SELECT TAB_ID FROM BSC_TABS_B WHERE SHORT_NAME = X_SHORT_NAME)
        AND    TAB_VIEW_ID      =   X_TAB_VIEW_ID
        AND    LABEL_ID         =   X_LABEL_ID
        AND    LABEL_TYPE       =   2;
      --  AND    LAST_UPDATE_DATE <=   X_LAST_UPDATE_DATE;
    ELSE
        FND_MESSAGE.SET_NAME('BSC',     'NO DATA FOUND');
        FND_MESSAGE.SET_TOKEN('PACKAGE',  'BSC_TAB_VIEW_LABELS_PKG');
        FND_MESSAGE.SET_TOKEN('TABLE',  'BSC_TAB_VIEW_LABELS_B');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'TAB_ID');
        FND_MESSAGE.SET_TOKEN('VALUE',   X_SHORT_NAME);
        FND_MESSAGE.SET_TOKEN('COLUMN', 'X_TAB_VIEW_ID');
        FND_MESSAGE.SET_TOKEN('VALUE',   X_TAB_VIEW_ID);
        FND_MESSAGE.SET_TOKEN('COLUMN', 'X_LABEL_ID');
        FND_MESSAGE.SET_TOKEN('VALUE',   X_LABEL_ID);
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
END UPDATE_LINK;


end BSC_TAB_VIEW_LABELS_PKG;

/
