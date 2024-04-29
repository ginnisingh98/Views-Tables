--------------------------------------------------------
--  DDL for Package Body OKE_K_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_K_TYPES_PKG" as
/* $Header: OKEOKTXB.pls 115.9 2002/11/21 23:08:26 ybchen ship $ */
procedure INSERT_ROW (
  X_ROWID 			in out NOCOPY VARCHAR2
, X_K_TYPE_CODE 		in 	VARCHAR2
, X_CREATION_DATE 		in 	DATE
, X_CREATED_BY 			in 	NUMBER
, X_LAST_UPDATE_DATE 		in 	DATE
, X_LAST_UPDATED_BY 		in 	NUMBER
, X_LAST_UPDATE_LOGIN 		in 	NUMBER
, X_K_TYPE_NAME 		in 	VARCHAR2
, X_TYPE_CLASS_CODE 		in 	VARCHAR2
, X_INTENT       		in 	VARCHAR2
, X_APPROVAL_PATH_ID            in      NUMBER
, X_DESCRIPTION 		in 	VARCHAR2
, X_START_DATE_ACTIVE 		in 	DATE
, X_END_DATE_ACTIVE   		in 	DATE
, X_ATTRIBUTE_CATEGORY 		in 	VARCHAR2
, X_ATTRIBUTE1 			in 	VARCHAR2
, X_ATTRIBUTE2 			in 	VARCHAR2
, X_ATTRIBUTE3 			in 	VARCHAR2
, X_ATTRIBUTE4 			in 	VARCHAR2
, X_ATTRIBUTE5 			in 	VARCHAR2
, X_ATTRIBUTE6 			in 	VARCHAR2
, X_ATTRIBUTE7 			in 	VARCHAR2
, X_ATTRIBUTE8 			in 	VARCHAR2
, X_ATTRIBUTE9 			in 	VARCHAR2
, X_ATTRIBUTE10 		in 	VARCHAR2
, X_ATTRIBUTE11 		in 	VARCHAR2
, X_ATTRIBUTE12 		in 	VARCHAR2
, X_ATTRIBUTE13 		in 	VARCHAR2
, X_ATTRIBUTE14 		in 	VARCHAR2
, X_ATTRIBUTE15 		in 	VARCHAR2
) is
  cursor C is select ROWID from OKE_K_TYPES_B
    where K_TYPE_CODE = X_K_TYPE_CODE
    ;

  Number_Option_ROWID  ROWID;

begin
  insert into OKE_K_TYPES_B (
  K_TYPE_CODE
, CREATION_DATE
, CREATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, LAST_UPDATE_LOGIN
, TYPE_CLASS_CODE
, INTENT
, APPROVAL_PATH_ID
, START_DATE_ACTIVE
, END_DATE_ACTIVE
, ATTRIBUTE_CATEGORY
, ATTRIBUTE1
, ATTRIBUTE2
, ATTRIBUTE3
, ATTRIBUTE4
, ATTRIBUTE5
, ATTRIBUTE6
, ATTRIBUTE7
, ATTRIBUTE8
, ATTRIBUTE9
, ATTRIBUTE10
, ATTRIBUTE11
, ATTRIBUTE12
, ATTRIBUTE13
, ATTRIBUTE14
, ATTRIBUTE15
  ) values (
  X_K_TYPE_CODE
, X_CREATION_DATE
, X_CREATED_BY
, X_LAST_UPDATE_DATE
, X_LAST_UPDATED_BY
, X_LAST_UPDATE_LOGIN
, X_TYPE_CLASS_CODE
, X_INTENT
, X_APPROVAL_PATH_ID
, X_START_DATE_ACTIVE
, X_END_DATE_ACTIVE
, X_ATTRIBUTE_CATEGORY
, X_ATTRIBUTE1
, X_ATTRIBUTE2
, X_ATTRIBUTE3
, X_ATTRIBUTE4
, X_ATTRIBUTE5
, X_ATTRIBUTE6
, X_ATTRIBUTE7
, X_ATTRIBUTE8
, X_ATTRIBUTE9
, X_ATTRIBUTE10
, X_ATTRIBUTE11
, X_ATTRIBUTE12
, X_ATTRIBUTE13
, X_ATTRIBUTE14
, X_ATTRIBUTE15
);

  insert into OKE_K_TYPES_TL (
  K_TYPE_CODE
, LANGUAGE
, CREATION_DATE
, CREATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, LAST_UPDATE_LOGIN
, K_TYPE_NAME
, DESCRIPTION
, SOURCE_LANG
  ) select
  X_K_TYPE_CODE
, L.LANGUAGE_CODE
, X_CREATION_DATE
, X_CREATED_BY
, X_LAST_UPDATE_DATE
, X_LAST_UPDATED_BY
, X_LAST_UPDATE_LOGIN
, X_K_TYPE_NAME
, X_DESCRIPTION
, userenv('LANG')
  from FND_LANGUAGES L
 where L.INSTALLED_FLAG in ('I', 'B')
   and not exists
    (select NULL
    from OKE_K_TYPES_TL T
   where T.K_TYPE_CODE = X_K_TYPE_CODE
     and T.LANGUAGE = L.LANGUAGE_CODE)
;

  --
  -- Creating Default Numbering Options
  --
  IF ( X_INTENT <> 'SELL' ) THEN
    OKE_NUMBER_OPTIONS_PKG.INSERT_ROW
    ( X_ROWID                     => Number_Option_ROWID
    , X_K_TYPE_CODE               => X_K_TYPE_CODE
    , X_BUY_OR_SELL               => 'B'
    , X_CREATION_DATE             => X_CREATION_DATE
    , X_CREATED_BY                => X_CREATED_BY
    , X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
    , X_LAST_UPDATED_BY           => X_LAST_UPDATED_BY
    , X_LAST_UPDATE_LOGIN         => X_LAST_UPDATE_LOGIN
    , X_CONTRACT_NUM_MODE         => 'MANUAL'
    , X_MANUAL_CONTRACT_NUM_TYPE  => 'ALPHANUMERIC'
    , X_NEXT_CONTRACT_NUM         => NULL
    , X_CONTRACT_NUM_INCREMENT    => NULL
    , X_CONTRACT_NUM_WIDTH        => NULL
    , X_CHGREQ_NUM_MODE           => 'MANUAL'
    , X_MANUAL_CHGREQ_NUM_TYPE    => 'ALPHANUMERIC'
    , X_CHGREQ_NUM_START_NUMBER   => NULL
    , X_CHGREQ_NUM_INCREMENT      => NULL
    , X_CHGREQ_NUM_WIDTH          => NULL
    , X_LINE_NUM_START_NUMBER     => 1
    , X_LINE_NUM_INCREMENT        => 1
    , X_LINE_NUM_WIDTH            => NULL
    , X_SUBLINE_NUM_START_NUMBER  => 1
    , X_SUBLINE_NUM_INCREMENT     => 1
    , X_SUBLINE_NUM_WIDTH         => NULL
    , X_DELV_NUM_START_NUMBER     => 1
    , X_DELV_NUM_INCREMENT        => 1
    , X_DELV_NUM_WIDTH            => NULL
    , X_ATTRIBUTE_CATEGORY        => NULL
    , X_ATTRIBUTE1                => NULL
    , X_ATTRIBUTE2                => NULL
    , X_ATTRIBUTE3                => NULL
    , X_ATTRIBUTE4                => NULL
    , X_ATTRIBUTE5                => NULL
    , X_ATTRIBUTE6                => NULL
    , X_ATTRIBUTE7                => NULL
    , X_ATTRIBUTE8                => NULL
    , X_ATTRIBUTE9                => NULL
    , X_ATTRIBUTE10               => NULL
    , X_ATTRIBUTE11               => NULL
    , X_ATTRIBUTE12               => NULL
    , X_ATTRIBUTE13               => NULL
    , X_ATTRIBUTE14               => NULL
    , X_ATTRIBUTE15               => NULL
    );
  END IF;

  IF ( X_INTENT <> 'BUY' ) THEN
    OKE_NUMBER_OPTIONS_PKG.INSERT_ROW
    ( X_ROWID                     => Number_Option_ROWID
    , X_K_TYPE_CODE               => X_K_TYPE_CODE
    , X_BUY_OR_SELL               => 'S'
    , X_CREATION_DATE             => X_CREATION_DATE
    , X_CREATED_BY                => X_CREATED_BY
    , X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
    , X_LAST_UPDATED_BY           => X_LAST_UPDATED_BY
    , X_LAST_UPDATE_LOGIN         => X_LAST_UPDATE_LOGIN
    , X_CONTRACT_NUM_MODE         => 'MANUAL'
    , X_MANUAL_CONTRACT_NUM_TYPE  => 'ALPHANUMERIC'
    , X_NEXT_CONTRACT_NUM         => NULL
    , X_CONTRACT_NUM_INCREMENT    => NULL
    , X_CONTRACT_NUM_WIDTH        => NULL
    , X_CHGREQ_NUM_MODE           => 'MANUAL'
    , X_MANUAL_CHGREQ_NUM_TYPE    => 'ALPHANUMERIC'
    , X_CHGREQ_NUM_START_NUMBER   => NULL
    , X_CHGREQ_NUM_INCREMENT      => NULL
    , X_CHGREQ_NUM_WIDTH          => NULL
    , X_LINE_NUM_START_NUMBER     => 1
    , X_LINE_NUM_INCREMENT        => 1
    , X_LINE_NUM_WIDTH            => NULL
    , X_SUBLINE_NUM_START_NUMBER  => 1
    , X_SUBLINE_NUM_INCREMENT     => 1
    , X_SUBLINE_NUM_WIDTH         => NULL
    , X_DELV_NUM_START_NUMBER     => 1
    , X_DELV_NUM_INCREMENT        => 1
    , X_DELV_NUM_WIDTH            => NULL
    , X_ATTRIBUTE_CATEGORY        => NULL
    , X_ATTRIBUTE1                => NULL
    , X_ATTRIBUTE2                => NULL
    , X_ATTRIBUTE3                => NULL
    , X_ATTRIBUTE4                => NULL
    , X_ATTRIBUTE5                => NULL
    , X_ATTRIBUTE6                => NULL
    , X_ATTRIBUTE7                => NULL
    , X_ATTRIBUTE8                => NULL
    , X_ATTRIBUTE9                => NULL
    , X_ATTRIBUTE10               => NULL
    , X_ATTRIBUTE11               => NULL
    , X_ATTRIBUTE12               => NULL
    , X_ATTRIBUTE13               => NULL
    , X_ATTRIBUTE14               => NULL
    , X_ATTRIBUTE15               => NULL
    );

  END IF;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_K_TYPE_CODE			in 	VARCHAR2
, X_K_TYPE_NAME 		in 	VARCHAR2
, X_TYPE_CLASS_CODE 		in 	VARCHAR2
, X_INTENT       		in 	VARCHAR2
, X_APPROVAL_PATH_ID            in      NUMBER
, X_DESCRIPTION 		in 	VARCHAR2
, X_START_DATE_ACTIVE 		in 	DATE
, X_END_DATE_ACTIVE   		in 	DATE
, X_ATTRIBUTE_CATEGORY 		in 	VARCHAR2
, X_ATTRIBUTE1 			in 	VARCHAR2
, X_ATTRIBUTE2 			in 	VARCHAR2
, X_ATTRIBUTE3 			in 	VARCHAR2
, X_ATTRIBUTE4 			in 	VARCHAR2
, X_ATTRIBUTE5 			in 	VARCHAR2
, X_ATTRIBUTE6 			in 	VARCHAR2
, X_ATTRIBUTE7 			in 	VARCHAR2
, X_ATTRIBUTE8 			in 	VARCHAR2
, X_ATTRIBUTE9 			in 	VARCHAR2
, X_ATTRIBUTE10 		in 	VARCHAR2
, X_ATTRIBUTE11 		in 	VARCHAR2
, X_ATTRIBUTE12 		in 	VARCHAR2
, X_ATTRIBUTE13 		in 	VARCHAR2
, X_ATTRIBUTE14 		in 	VARCHAR2
, X_ATTRIBUTE15 		in 	VARCHAR2
) is
  cursor c is select
       K_TYPE_CODE
     , TYPE_CLASS_CODE
     , INTENT
     , APPROVAL_PATH_ID
     , START_DATE_ACTIVE
     , END_DATE_ACTIVE
     , ATTRIBUTE_CATEGORY
     , ATTRIBUTE1
     , ATTRIBUTE2
     , ATTRIBUTE3
     , ATTRIBUTE4
     , ATTRIBUTE5
     , ATTRIBUTE6
     , ATTRIBUTE7
     , ATTRIBUTE8
     , ATTRIBUTE9
     , ATTRIBUTE10
     , ATTRIBUTE11
     , ATTRIBUTE12
     , ATTRIBUTE13
     , ATTRIBUTE14
     , ATTRIBUTE15
    from OKE_K_TYPES_B
    where K_TYPE_CODE = X_K_TYPE_CODE
    for update of K_TYPE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      K_TYPE_NAME
     ,DESCRIPTION
     ,decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from OKE_K_TYPES_TL
    where K_TYPE_CODE= X_K_TYPE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of K_TYPE_CODE nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (    (recinfo.K_TYPE_CODE = X_K_TYPE_CODE)
      AND ((recinfo.TYPE_CLASS_CODE = X_TYPE_CLASS_CODE)
           OR ((recinfo.TYPE_CLASS_CODE is null) AND (X_TYPE_CLASS_CODE is null)))
      AND ((recinfo.INTENT = X_INTENT)
           OR ((recinfo.INTENT is null) AND (X_INTENT is null)))
      AND ((recinfo.APPROVAL_PATH_ID = X_APPROVAL_PATH_ID)
           OR ((recinfo.APPROVAL_PATH_ID is null) AND (X_APPROVAL_PATH_ID is null)))
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.K_TYPE_NAME = X_K_TYPE_NAME)
               OR ((tlinfo.K_TYPE_NAME is null) AND (X_K_TYPE_NAME is null)))
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_K_TYPE_CODE 		in 	VARCHAR2
, X_LAST_UPDATE_DATE 		in 	DATE
, X_LAST_UPDATED_BY 		in 	NUMBER
, X_LAST_UPDATE_LOGIN 		in 	NUMBER
, X_K_TYPE_NAME 		in 	VARCHAR2
, X_TYPE_CLASS_CODE 		in 	VARCHAR2
, X_INTENT       		in 	VARCHAR2
, X_APPROVAL_PATH_ID            in      NUMBER
, X_DESCRIPTION 		in 	VARCHAR2
, X_START_DATE_ACTIVE 		in 	DATE
, X_END_DATE_ACTIVE   		in 	DATE
, X_ATTRIBUTE_CATEGORY 		in 	VARCHAR2
, X_ATTRIBUTE1 			in 	VARCHAR2
, X_ATTRIBUTE2 			in 	VARCHAR2
, X_ATTRIBUTE3 			in 	VARCHAR2
, X_ATTRIBUTE4 			in 	VARCHAR2
, X_ATTRIBUTE5 			in 	VARCHAR2
, X_ATTRIBUTE6 			in 	VARCHAR2
, X_ATTRIBUTE7 			in 	VARCHAR2
, X_ATTRIBUTE8 			in 	VARCHAR2
, X_ATTRIBUTE9 			in 	VARCHAR2
, X_ATTRIBUTE10 		in 	VARCHAR2
, X_ATTRIBUTE11 		in 	VARCHAR2
, X_ATTRIBUTE12 		in 	VARCHAR2
, X_ATTRIBUTE13 		in 	VARCHAR2
, X_ATTRIBUTE14 		in 	VARCHAR2
, X_ATTRIBUTE15 		in 	VARCHAR2
) is
begin
  update OKE_K_TYPES_B set
  LAST_UPDATE_DATE      	= X_LAST_UPDATE_DATE
, LAST_UPDATED_BY 		= X_LAST_UPDATED_BY
, LAST_UPDATE_LOGIN   		= X_LAST_UPDATE_LOGIN
, TYPE_CLASS_CODE 	        = X_TYPE_CLASS_CODE
, INTENT	        	= X_INTENT
, APPROVAL_PATH_ID              = X_APPROVAL_PATH_ID
, START_DATE_ACTIVE 		= X_START_DATE_ACTIVE
, END_DATE_ACTIVE   		= X_END_DATE_ACTIVE
, ATTRIBUTE_CATEGORY		= X_ATTRIBUTE_CATEGORY
, ATTRIBUTE1            	= X_ATTRIBUTE1
, ATTRIBUTE2			= X_ATTRIBUTE2
, ATTRIBUTE3    		= X_ATTRIBUTE3
, ATTRIBUTE4        		= X_ATTRIBUTE4
, ATTRIBUTE5            	= X_ATTRIBUTE5
, ATTRIBUTE6			= X_ATTRIBUTE6
, ATTRIBUTE7    		= X_ATTRIBUTE7
, ATTRIBUTE8        		= X_ATTRIBUTE8
, ATTRIBUTE9            	= X_ATTRIBUTE9
, ATTRIBUTE10           	= X_ATTRIBUTE10
, ATTRIBUTE11			= X_ATTRIBUTE11
, ATTRIBUTE12    		= X_ATTRIBUTE12
, ATTRIBUTE13        		= X_ATTRIBUTE13
, ATTRIBUTE14           	= X_ATTRIBUTE14
, ATTRIBUTE15           	= X_ATTRIBUTE15
where K_TYPE_CODE 		= X_K_TYPE_CODE
;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update OKE_K_TYPES_TL set
  LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE
, LAST_UPDATED_BY 	= X_LAST_UPDATED_BY
, LAST_UPDATE_LOGIN   	= X_LAST_UPDATE_LOGIN
, K_TYPE_NAME 	        = X_K_TYPE_NAME
, DESCRIPTION       	= X_DESCRIPTION
, SOURCE_LANG 		= userenv('LANG')
where K_TYPE_CODE       = X_K_TYPE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
;

  if (sql%notfound) then
    raise no_data_found;
  end if;


  --
  -- Checking Default Numbering Options
  --
  if X_INTENT = 'BOTH' THEN

    DECLARE
      Number_Option_ROWID  ROWID;
    BEGIN

    OKE_NUMBER_OPTIONS_PKG.INSERT_ROW
    ( X_ROWID                     => Number_Option_ROWID
    , X_K_TYPE_CODE               => X_K_TYPE_CODE
    , X_BUY_OR_SELL               => 'S'
    , X_CREATION_DATE             => X_LAST_UPDATE_DATE
    , X_CREATED_BY                => X_LAST_UPDATED_BY
    , X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
    , X_LAST_UPDATED_BY           => X_LAST_UPDATED_BY
    , X_LAST_UPDATE_LOGIN         => X_LAST_UPDATE_LOGIN
    , X_CONTRACT_NUM_MODE         => 'MANUAL'
    , X_MANUAL_CONTRACT_NUM_TYPE  => 'ALPHANUMERIC'
    , X_NEXT_CONTRACT_NUM         => NULL
    , X_CONTRACT_NUM_INCREMENT    => NULL
    , X_CONTRACT_NUM_WIDTH        => NULL
    , X_CHGREQ_NUM_MODE           => 'MANUAL'
    , X_MANUAL_CHGREQ_NUM_TYPE    => 'ALPHANUMERIC'
    , X_CHGREQ_NUM_START_NUMBER   => NULL
    , X_CHGREQ_NUM_INCREMENT      => NULL
    , X_CHGREQ_NUM_WIDTH          => NULL
    , X_LINE_NUM_START_NUMBER     => 1
    , X_LINE_NUM_INCREMENT        => 1
    , X_LINE_NUM_WIDTH            => NULL
    , X_SUBLINE_NUM_START_NUMBER  => 1
    , X_SUBLINE_NUM_INCREMENT     => 1
    , X_SUBLINE_NUM_WIDTH         => NULL
    , X_DELV_NUM_START_NUMBER     => 1
    , X_DELV_NUM_INCREMENT        => 1
    , X_DELV_NUM_WIDTH            => NULL
    , X_ATTRIBUTE_CATEGORY        => NULL
    , X_ATTRIBUTE1                => NULL
    , X_ATTRIBUTE2                => NULL
    , X_ATTRIBUTE3                => NULL
    , X_ATTRIBUTE4                => NULL
    , X_ATTRIBUTE5                => NULL
    , X_ATTRIBUTE6                => NULL
    , X_ATTRIBUTE7                => NULL
    , X_ATTRIBUTE8                => NULL
    , X_ATTRIBUTE9                => NULL
    , X_ATTRIBUTE10               => NULL
    , X_ATTRIBUTE11               => NULL
    , X_ATTRIBUTE12               => NULL
    , X_ATTRIBUTE13               => NULL
    , X_ATTRIBUTE14               => NULL
    , X_ATTRIBUTE15               => NULL
    );
    END;

    DECLARE
      Number_Option_ROWID  ROWID;
    BEGIN

    OKE_NUMBER_OPTIONS_PKG.INSERT_ROW
    ( X_ROWID                     => Number_Option_ROWID
    , X_K_TYPE_CODE               => X_K_TYPE_CODE
    , X_BUY_OR_SELL               => 'B'
    , X_CREATION_DATE             => X_LAST_UPDATE_DATE
    , X_CREATED_BY                => X_LAST_UPDATED_BY
    , X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
    , X_LAST_UPDATED_BY           => X_LAST_UPDATED_BY
    , X_LAST_UPDATE_LOGIN         => X_LAST_UPDATE_LOGIN
    , X_CONTRACT_NUM_MODE         => 'MANUAL'
    , X_MANUAL_CONTRACT_NUM_TYPE  => 'ALPHANUMERIC'
    , X_NEXT_CONTRACT_NUM         => NULL
    , X_CONTRACT_NUM_INCREMENT    => NULL
    , X_CONTRACT_NUM_WIDTH        => NULL
    , X_CHGREQ_NUM_MODE           => 'MANUAL'
    , X_MANUAL_CHGREQ_NUM_TYPE    => 'ALPHANUMERIC'
    , X_CHGREQ_NUM_START_NUMBER   => NULL
    , X_CHGREQ_NUM_INCREMENT      => NULL
    , X_CHGREQ_NUM_WIDTH          => NULL
    , X_LINE_NUM_START_NUMBER     => 1
    , X_LINE_NUM_INCREMENT        => 1
    , X_LINE_NUM_WIDTH            => NULL
    , X_SUBLINE_NUM_START_NUMBER  => 1
    , X_SUBLINE_NUM_INCREMENT     => 1
    , X_SUBLINE_NUM_WIDTH         => NULL
    , X_DELV_NUM_START_NUMBER     => 1
    , X_DELV_NUM_INCREMENT        => 1
    , X_DELV_NUM_WIDTH            => NULL
    , X_ATTRIBUTE_CATEGORY        => NULL
    , X_ATTRIBUTE1                => NULL
    , X_ATTRIBUTE2                => NULL
    , X_ATTRIBUTE3                => NULL
    , X_ATTRIBUTE4                => NULL
    , X_ATTRIBUTE5                => NULL
    , X_ATTRIBUTE6                => NULL
    , X_ATTRIBUTE7                => NULL
    , X_ATTRIBUTE8                => NULL
    , X_ATTRIBUTE9                => NULL
    , X_ATTRIBUTE10               => NULL
    , X_ATTRIBUTE11               => NULL
    , X_ATTRIBUTE12               => NULL
    , X_ATTRIBUTE13               => NULL
    , X_ATTRIBUTE14               => NULL
    , X_ATTRIBUTE15               => NULL
    );
    END;

  END IF;

  if X_INTENT = 'SELL' THEN

    DECLARE
      Number_Option_ROWID  ROWID;
    BEGIN

    OKE_NUMBER_OPTIONS_PKG.INSERT_ROW
    ( X_ROWID                     => Number_Option_ROWID
    , X_K_TYPE_CODE               => X_K_TYPE_CODE
    , X_BUY_OR_SELL               => 'S'
    , X_CREATION_DATE             => X_LAST_UPDATE_DATE
    , X_CREATED_BY                => X_LAST_UPDATED_BY
    , X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
    , X_LAST_UPDATED_BY           => X_LAST_UPDATED_BY
    , X_LAST_UPDATE_LOGIN         => X_LAST_UPDATE_LOGIN
    , X_CONTRACT_NUM_MODE         => 'MANUAL'
    , X_MANUAL_CONTRACT_NUM_TYPE  => 'ALPHANUMERIC'
    , X_NEXT_CONTRACT_NUM         => NULL
    , X_CONTRACT_NUM_INCREMENT    => NULL
    , X_CONTRACT_NUM_WIDTH        => NULL
    , X_CHGREQ_NUM_MODE           => 'MANUAL'
    , X_MANUAL_CHGREQ_NUM_TYPE    => 'ALPHANUMERIC'
    , X_CHGREQ_NUM_START_NUMBER   => NULL
    , X_CHGREQ_NUM_INCREMENT      => NULL
    , X_CHGREQ_NUM_WIDTH          => NULL
    , X_LINE_NUM_START_NUMBER     => 1
    , X_LINE_NUM_INCREMENT        => 1
    , X_LINE_NUM_WIDTH            => NULL
    , X_SUBLINE_NUM_START_NUMBER  => 1
    , X_SUBLINE_NUM_INCREMENT     => 1
    , X_SUBLINE_NUM_WIDTH         => NULL
    , X_DELV_NUM_START_NUMBER     => 1
    , X_DELV_NUM_INCREMENT        => 1
    , X_DELV_NUM_WIDTH            => NULL
    , X_ATTRIBUTE_CATEGORY        => NULL
    , X_ATTRIBUTE1                => NULL
    , X_ATTRIBUTE2                => NULL
    , X_ATTRIBUTE3                => NULL
    , X_ATTRIBUTE4                => NULL
    , X_ATTRIBUTE5                => NULL
    , X_ATTRIBUTE6                => NULL
    , X_ATTRIBUTE7                => NULL
    , X_ATTRIBUTE8                => NULL
    , X_ATTRIBUTE9                => NULL
    , X_ATTRIBUTE10               => NULL
    , X_ATTRIBUTE11               => NULL
    , X_ATTRIBUTE12               => NULL
    , X_ATTRIBUTE13               => NULL
    , X_ATTRIBUTE14               => NULL
    , X_ATTRIBUTE15               => NULL
    );
    END;
  END IF;

  if X_INTENT='BUY' THEN
    DECLARE
      Number_Option_ROWID  ROWID;
    BEGIN

    OKE_NUMBER_OPTIONS_PKG.INSERT_ROW
    ( X_ROWID                     => Number_Option_ROWID
    , X_K_TYPE_CODE               => X_K_TYPE_CODE
    , X_BUY_OR_SELL               => 'B'
    , X_CREATION_DATE             => X_LAST_UPDATE_DATE
    , X_CREATED_BY                => X_LAST_UPDATED_BY
    , X_LAST_UPDATE_DATE          => X_LAST_UPDATE_DATE
    , X_LAST_UPDATED_BY           => X_LAST_UPDATED_BY
    , X_LAST_UPDATE_LOGIN         => X_LAST_UPDATE_LOGIN
    , X_CONTRACT_NUM_MODE         => 'MANUAL'
    , X_MANUAL_CONTRACT_NUM_TYPE  => 'ALPHANUMERIC'
    , X_NEXT_CONTRACT_NUM         => NULL
    , X_CONTRACT_NUM_INCREMENT    => NULL
    , X_CONTRACT_NUM_WIDTH        => NULL
    , X_CHGREQ_NUM_MODE           => 'MANUAL'
    , X_MANUAL_CHGREQ_NUM_TYPE    => 'ALPHANUMERIC'
    , X_CHGREQ_NUM_START_NUMBER   => NULL
    , X_CHGREQ_NUM_INCREMENT      => NULL
    , X_CHGREQ_NUM_WIDTH          => NULL
    , X_LINE_NUM_START_NUMBER     => 1
    , X_LINE_NUM_INCREMENT        => 1
    , X_LINE_NUM_WIDTH            => NULL
    , X_SUBLINE_NUM_START_NUMBER  => 1
    , X_SUBLINE_NUM_INCREMENT     => 1
    , X_SUBLINE_NUM_WIDTH         => NULL
    , X_DELV_NUM_START_NUMBER     => 1
    , X_DELV_NUM_INCREMENT        => 1
    , X_DELV_NUM_WIDTH            => NULL
    , X_ATTRIBUTE_CATEGORY        => NULL
    , X_ATTRIBUTE1                => NULL
    , X_ATTRIBUTE2                => NULL
    , X_ATTRIBUTE3                => NULL
    , X_ATTRIBUTE4                => NULL
    , X_ATTRIBUTE5                => NULL
    , X_ATTRIBUTE6                => NULL
    , X_ATTRIBUTE7                => NULL
    , X_ATTRIBUTE8                => NULL
    , X_ATTRIBUTE9                => NULL
    , X_ATTRIBUTE10               => NULL
    , X_ATTRIBUTE11               => NULL
    , X_ATTRIBUTE12               => NULL
    , X_ATTRIBUTE13               => NULL
    , X_ATTRIBUTE14               => NULL
    , X_ATTRIBUTE15               => NULL
    );
    END;

  END IF;
end UPDATE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from OKE_K_TYPES_TL T
  where not exists
    (select NULL
    from OKE_K_TYPES_B B
    where B.K_TYPE_CODE = T.K_TYPE_CODE
    );

  update OKE_K_TYPES_TL T set (
      K_TYPE_NAME,
      DESCRIPTION
    ) = (select
      B.K_TYPE_NAME,
      B.DESCRIPTION
    from OKE_K_TYPES_TL B
    where B.K_TYPE_CODE = T.K_TYPE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.K_TYPE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.K_TYPE_CODE,
      SUBT.LANGUAGE
    from OKE_K_TYPES_TL SUBB, OKE_K_TYPES_TL SUBT
    where SUBB.K_TYPE_CODE = SUBT.K_TYPE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.K_TYPE_NAME <> SUBT.K_TYPE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into OKE_K_TYPES_TL (
    K_TYPE_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    K_TYPE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.K_TYPE_CODE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.K_TYPE_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OKE_K_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OKE_K_TYPES_TL T
    where T.K_TYPE_CODE = B.K_TYPE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end OKE_K_TYPES_PKG;

/
