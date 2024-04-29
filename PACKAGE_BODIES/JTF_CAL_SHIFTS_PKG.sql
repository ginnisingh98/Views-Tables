--------------------------------------------------------
--  DDL for Package Body JTF_CAL_SHIFTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_SHIFTS_PKG" as
/* $Header: jtfclshb.pls 115.20 2003/06/09 11:34:24 abraina ship $ */
procedure INSERT_ROW (
  X_ERROR out NOCOPY VARCHAR2,
  X_ROWID in out NOCOPY VARCHAR2,
  X_SHIFT_ID in out NOCOPY NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SHIFT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

	v_error CHAR := 'N';
	v_shift_id NUMBER;
  cursor C is select ROWID from JTF_CAL_SHIFTS_B
    where SHIFT_ID = X_SHIFT_ID;
begin
		fnd_msg_pub.initialize;
		IF JTF_CAL_SHIFTS_PKG.NOT_NULL(X_START_DATE_ACTIVE) = FALSE THEN
			--fnd_message.set_name('JTF', 'START_DATE CANNOT BE NULL');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_START_DATE');
			fnd_msg_pub.add;

			v_error := 'Y';
		END IF;


		IF JTF_CAL_SHIFTS_PKG.END_GREATER_THAN_BEGIN(X_START_DATE_ACTIVE, X_END_DATE_ACTIVE) = FALSE 										THEN
			--fnd_message.set_name('JTF', 'END_DATE IS INCORRECT');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_END_DATE');
			fnd_message.set_token('P_Start_Date', X_START_DATE_ACTIVE);
			fnd_message.set_token('P_End_Date', X_END_DATE_ACTIVE);
			fnd_msg_pub.add;
			v_error := 'Y';
		END IF;

		-- Code Added BY Venkata Putcha for UTF8 Compliance
                -- Update the max length from 80 to 240 for bug # 2863830 By A.Raina
                if Length(X_SHIFT_NAME) > 240 then
                        fnd_message.set_name('JTF', 'JTF_CAL_UTF8_COMP');
                        fnd_message.set_token('P_NAME', X_SHIFT_NAME);
                        fnd_msg_pub.add;
                        v_error := 'Y';
                end if;

                -- Update the max length from 80 to 240 for bug # 2863830 By A.Raina
                if Length(X_DESCRIPTION) > 240 then
                        fnd_message.set_name('JTF', 'JTF_CAL_UTF8_COMP');
                        fnd_message.set_token('P_NAME', X_DESCRIPTION);
                        fnd_msg_pub.add;
                        v_error := 'Y';
                end if;
                -- Up to Here

		IF v_error = 'Y' THEN
			X_ERROR := 'Y';
			return;
		ELSE


		SELECT 	JTF_CAL_SHIFTS_S.nextval
		INTO	v_shift_id
		FROM	dual;

                X_SHIFT_ID := v_shift_id;

  --commented the user hook code as this is not to be implemented
  -- start of comment
/*

              -- Add User Hook Check for INSERT by Jane Wang on 01/25/02
					IF jtf_usr_hks.ok_to_execute(
			  	    	'JTF_CAL_SHIFTS_PKG',
			  	    	'INSERT_ROW',
			  	    	'B',
			  	    	'C')
			        THEN
			              JTF_CAL_SHIFT_CUHK.insert_shift_pre
			              (
			              X_ERROR => X_ERROR,
			              X_ROWID => X_ROWID,
			              X_SHIFT_ID => X_SHIFT_ID,
			              X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
			              X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
			              X_END_DATE_ACTIVE => X_END_DATE_ACTIVE,
			              X_ATTRIBUTE1 => X_ATTRIBUTE1,
			              X_ATTRIBUTE2 => X_ATTRIBUTE2,
			              X_ATTRIBUTE3 => X_ATTRIBUTE3,
			              X_ATTRIBUTE4 => X_ATTRIBUTE4,
			              X_ATTRIBUTE5 => X_ATTRIBUTE5,
			              X_ATTRIBUTE6 => X_ATTRIBUTE6,
			              X_ATTRIBUTE7 => X_ATTRIBUTE7,
			              X_ATTRIBUTE8 => X_ATTRIBUTE8 ,
			              X_ATTRIBUTE9 => X_ATTRIBUTE9,
			              X_ATTRIBUTE10 => X_ATTRIBUTE10,
			              X_ATTRIBUTE11 => X_ATTRIBUTE11,
			              X_ATTRIBUTE12 => X_ATTRIBUTE12 ,
			              X_ATTRIBUTE13 => X_ATTRIBUTE13,
			              X_ATTRIBUTE14 => X_ATTRIBUTE14,
			              X_ATTRIBUTE15 => X_ATTRIBUTE15,
			              X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
			              X_SHIFT_NAME => X_SHIFT_NAME,
			              X_DESCRIPTION => X_DESCRIPTION,
			              X_CREATION_DATE => X_CREATION_DATE,
			              X_CREATED_BY => X_CREATED_BY,
			              X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE,
			              X_LAST_UPDATED_BY => X_LAST_UPDATED_BY,
			              X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN
			              );

			              END IF;  -- End of User Hook Check for INSERT
*/
-- End of Comment

			  insert into JTF_CAL_SHIFTS_B (
			    OBJECT_VERSION_NUMBER,
			    SHIFT_ID,
			    START_DATE_ACTIVE,
			    END_DATE_ACTIVE,
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
			    ATTRIBUTE_CATEGORY,
			    CREATION_DATE,
			    CREATED_BY,
			    LAST_UPDATE_DATE,
			    LAST_UPDATED_BY,
			    LAST_UPDATE_LOGIN
			  ) values (
			    1,
			    v_shift_id,
			    X_START_DATE_ACTIVE,
			    X_END_DATE_ACTIVE,
			    X_ATTRIBUTE1,
			    X_ATTRIBUTE2,
			    X_ATTRIBUTE3,
			    X_ATTRIBUTE4,
			    X_ATTRIBUTE5,
			    X_ATTRIBUTE6,
			    X_ATTRIBUTE7,
			    X_ATTRIBUTE8,
			    X_ATTRIBUTE9,
			    X_ATTRIBUTE10,
			    X_ATTRIBUTE11,
			    X_ATTRIBUTE12,
			    X_ATTRIBUTE13,
			    X_ATTRIBUTE14,
			    X_ATTRIBUTE15,
			    X_ATTRIBUTE_CATEGORY,
			    SYSDATE,
			   FND_GLOBAL.USER_ID,
			    SYSDATE,
			    FND_GLOBAL.USER_ID,
      	                  NULL
			  );

			  insert into JTF_CAL_SHIFTS_TL (
			    SHIFT_ID,
			    SHIFT_NAME,
			    DESCRIPTION,
			    CREATED_BY,
			    CREATION_DATE,
			    LAST_UPDATED_BY,
			    LAST_UPDATE_DATE,
			    LAST_UPDATE_LOGIN,
			    LANGUAGE,
			    SOURCE_LANG
			  ) select
			    v_shift_id,
			    X_SHIFT_NAME,
			    X_DESCRIPTION,
			    FND_GLOBAL.USER_ID,
			    SYSDATE,
			    FND_GLOBAL.USER_ID,
			    SYSDATE,
			    NULL,
			    L.LANGUAGE_CODE,
			    userenv('LANG')
			  from FND_LANGUAGES L
			  where L.INSTALLED_FLAG in ('I', 'B')
			  and not exists
			    (select NULL
			    from JTF_CAL_SHIFTS_TL T
			    where T.SHIFT_ID = X_SHIFT_ID
			    and T.LANGUAGE = L.LANGUAGE_CODE);
/*
			  open c;
			  fetch c into X_ROWID;
			  if (c%notfound) then
			    close c;
			    raise no_data_found;
			  end if;
			  close c;
*/
		END IF;
end INSERT_ROW;

procedure LOCK_ROW (
  X_SHIFT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SHIFT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
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
      ATTRIBUTE_CATEGORY
    from JTF_CAL_SHIFTS_B
    where SHIFT_ID = X_SHIFT_ID
    for update of SHIFT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SHIFT_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_CAL_SHIFTS_TL
    where SHIFT_ID = X_SHIFT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SHIFT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('JTF', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND (recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
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
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
  ) then
    null;
  else
    fnd_message.set_name('JTF', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.SHIFT_NAME = X_SHIFT_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('JTF', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ERROR out NOCOPY VARCHAR2,
  X_SHIFT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in OUT NOCOPY NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SHIFT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

	v_error CHAR := 'N';
begin
		fnd_msg_pub.initialize;
		IF JTF_CAL_SHIFTS_PKG.NOT_NULL(X_START_DATE_ACTIVE) = FALSE THEN
			--fnd_message.set_name('JTF', 'START_DATE CANNOT BE NULL');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_START_DATE');
			fnd_msg_pub.add;

			v_error := 'Y';
		END IF;


		IF JTF_CAL_SHIFTS_PKG.END_GREATER_THAN_BEGIN(X_START_DATE_ACTIVE, X_END_DATE_ACTIVE) = FALSE 										THEN
			--fnd_message.set_name('JTF', 'END_DATE IS INCORRECT');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_END_DATE');
			fnd_message.set_token('P_Start_Date', X_START_DATE_ACTIVE);
			fnd_message.set_token('P_End_Date', X_END_DATE_ACTIVE);
			fnd_msg_pub.add;
			v_error := 'Y';
		END IF;

		IF v_error = 'Y' THEN
			X_ERROR := 'Y';
			return;
		ELSE
		X_ERROR := 'N';
		X_OBJECT_VERSION_NUMBER := X_OBJECT_VERSION_NUMBER + 1;

 --commented the user hook code as this is not to be implemented
 -- start of comment
/*
        	-- Add User Hook Check for UPDATE by Jane Wang on 01/25/02

        	IF jtf_usr_hks.ok_to_execute(
	    		'JTF_CAL_SHIFTS_PKG',
				'UPDATE_ROW',
				'B',
				'C')
			THEN
					JTF_CAL_SHIFT_CUHK.update_shift_pre
		            (X_ERROR => X_ERROR,
		            X_SHIFT_ID => X_SHIFT_ID,
		            X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
		            X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
		            X_END_DATE_ACTIVE => X_END_DATE_ACTIVE,
		            X_ATTRIBUTE1 => X_ATTRIBUTE1,
		            X_ATTRIBUTE2 => X_ATTRIBUTE2,
		            X_ATTRIBUTE3 => X_ATTRIBUTE3,
		            X_ATTRIBUTE4 => X_ATTRIBUTE4,
		            X_ATTRIBUTE5 => X_ATTRIBUTE5,
		            X_ATTRIBUTE6 => X_ATTRIBUTE6,
		            X_ATTRIBUTE7 => X_ATTRIBUTE7,
		            X_ATTRIBUTE8 => X_ATTRIBUTE8,
		            X_ATTRIBUTE9 => X_ATTRIBUTE9,
		            X_ATTRIBUTE10 => X_ATTRIBUTE10,
		            X_ATTRIBUTE11 => X_ATTRIBUTE11,
		            X_ATTRIBUTE12 => X_ATTRIBUTE12,
		            X_ATTRIBUTE13 => X_ATTRIBUTE13,
		            X_ATTRIBUTE14 => X_ATTRIBUTE14,
		            X_ATTRIBUTE15 => X_ATTRIBUTE15,
		            X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
		            X_SHIFT_NAME => X_SHIFT_NAME,
		            X_DESCRIPTION => X_DESCRIPTION,
		            X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE,
		            X_LAST_UPDATED_BY => X_LAST_UPDATED_BY,
		            X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN
		            );

            END IF;  -- End of User Hook Check for UPDATE

*/
-- End of comment

		  update JTF_CAL_SHIFTS_B set
		    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
		    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
		    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
		    ATTRIBUTE1 = X_ATTRIBUTE1,
		    ATTRIBUTE2 = X_ATTRIBUTE2,
		    ATTRIBUTE3 = X_ATTRIBUTE3,
		    ATTRIBUTE4 = X_ATTRIBUTE4,
		    ATTRIBUTE5 = X_ATTRIBUTE5,
		    ATTRIBUTE6 = X_ATTRIBUTE6,
		    ATTRIBUTE7 = X_ATTRIBUTE7,
		    ATTRIBUTE8 = X_ATTRIBUTE8,
		    ATTRIBUTE9 = X_ATTRIBUTE9,
		    ATTRIBUTE10 = X_ATTRIBUTE10,
		    ATTRIBUTE11 = X_ATTRIBUTE11,
		    ATTRIBUTE12 = X_ATTRIBUTE12,
		    ATTRIBUTE13 = X_ATTRIBUTE13,
		    ATTRIBUTE14 = X_ATTRIBUTE14,
		    ATTRIBUTE15 = X_ATTRIBUTE15,
		    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
		    LAST_UPDATE_DATE = SYSDATE,
		    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
		    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
		  where SHIFT_ID = X_SHIFT_ID;

		  if (sql%notfound) then
		    raise no_data_found;
		  end if;

		  update JTF_CAL_SHIFTS_TL set
		    SHIFT_NAME = X_SHIFT_NAME,
		    DESCRIPTION = X_DESCRIPTION,
		    LAST_UPDATE_DATE = SYSDATE,
		    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
		    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
		    SOURCE_LANG = userenv('LANG')
		  where SHIFT_ID = X_SHIFT_ID
		  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

		  if (sql%notfound) then
		    raise no_data_found;
		  end if;
	END IF;
end UPDATE_ROW;

Procedure TRANSLATE_ROW
(X_SHIFT_ID  in number,
 X_SHIFT_NAME in varchar2,
 X_DESCRIPTION in varchar2,
 X_LAST_UPDATE_DATE in date,
 X_LAST_UPDATED_BY in number,
 X_LAST_UPDATE_LOGIN in number)
is
begin

Update JTF_CAL_SHIFTS_TL set
shift_name		= nvl(X_SHIFT_NAME,shift_name),
description		= nvl(X_DESCRIPTION,description),
last_update_date	= nvl(x_last_update_date,sysdate),
last_updated_by		= x_last_updated_by,
last_update_login	= 0,
source_lang		= userenv('LANG')
where shift_id		= X_SHIFT_ID
and userenv('LANG') in (LANGUAGE,SOURCE_LANG);

end TRANSLATE_ROW;

procedure DELETE_ROW (
  X_SHIFT_ID in NUMBER
) is
begin

 --commented the user hook code as this is not to be implemented
 -- start of comment
/*

    --  Add User Hook Check for DELETE by Jane Wang on 01/25/02

     IF jtf_usr_hks.ok_to_execute(
          'JTF_CAL_SHIFTS_PKG',
          'DELETE_ROW',
          'B',
          'C')
     THEN
          JTF_CAL_SHIFT_CUHK.delete_shift_pre
          (
           X_SHIFT_ID => X_SHIFT_ID
          );
    END IF;  -- End of User Hook for DELETE
*/
-- End of comment

  delete from JTF_CAL_SHIFTS_TL
  where SHIFT_ID = X_SHIFT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_CAL_SHIFTS_B
  where SHIFT_ID = X_SHIFT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_CAL_SHIFTS_TL T
  where not exists
    (select NULL
    from JTF_CAL_SHIFTS_B B
    where B.SHIFT_ID = T.SHIFT_ID
    );

  update JTF_CAL_SHIFTS_TL T set (
      SHIFT_NAME,
      DESCRIPTION
    ) = (select
      B.SHIFT_NAME,
      B.DESCRIPTION
    from JTF_CAL_SHIFTS_TL B
    where B.SHIFT_ID = T.SHIFT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SHIFT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SHIFT_ID,
      SUBT.LANGUAGE
    from JTF_CAL_SHIFTS_TL SUBB, JTF_CAL_SHIFTS_TL SUBT
    where SUBB.SHIFT_ID = SUBT.SHIFT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SHIFT_NAME <> SUBT.SHIFT_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into JTF_CAL_SHIFTS_TL (
    SHIFT_ID,
    SHIFT_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SHIFT_ID,
    B.SHIFT_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_CAL_SHIFTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_CAL_SHIFTS_TL T
    where T.SHIFT_ID = B.SHIFT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
/*************************************************************************/
	FUNCTION not_null(column_to_check IN CHAR) RETURN boolean IS
	BEGIN
		IF column_to_check IS NULL THEN
		   return(FALSE);
		ELSE
		   return(TRUE);
		END IF;
	END;
/*************************************************************************/
	FUNCTION end_greater_than_begin(start_date IN DATE, end_date IN DATE) RETURN boolean IS
	BEGIN
		IF start_date > end_date THEN
		   return(FALSE);
		ELSE
		   return(TRUE);
		END IF;
	END;
end JTF_CAL_SHIFTS_PKG;

/
