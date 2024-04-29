--------------------------------------------------------
--  DDL for Package Body JTF_CAL_EXCEPTION_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_EXCEPTION_ASSIGN_PKG" as
/* $Header: jtfcleab.pls 115.18 2002/11/15 14:42:10 sukulkar ship $ */
procedure INSERT_ROW (
  X_ERROR out NOCOPY VARCHAR2,
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_EXCEPTION_ASSIGN_ID in out NOCOPY NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_EXCEPTION_REASON in VARCHAR2,
  X_CALENDAR_ID in NUMBER,
  X_EXCEPTION_ID in NUMBER,
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
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

  cursor C is select ROWID from JTF_CAL_EXCEPTION_ASSIGN
    where CAL_EXCEPTION_ASSIGN_ID = X_CAL_EXCEPTION_ASSIGN_ID;

	v_error CHAR := 'N';
        v_cal_exception_assign_id_s NUMBER;
begin
		fnd_msg_pub.initialize;
	IF JTF_CAL_EXCEPTION_ASSIGN_PKG.duplicate_excep(X_CALENDAR_ID,X_EXCEPTION_ID,
                            X_EXCEPTION_REASON, X_START_DATE_ACTIVE,
                                -- nvl(X_END_DATE_ACTIVE,'31-DEC-4712')) = FALSE THEN
                           --changed this for nls issue inavlid month .. sudarsana 12th Nov 2001
                                 nvl(X_END_DATE_ACTIVE,fnd_api.g_miss_date)) = FALSE THEN
			fnd_message.set_name('JTF','JTF_CAL_EXCEPTION_EXISTS');
		--	fnd_message.set_name('JTF', 'JTF_CAL_ALREADY_EXISTS');
	--		fnd_message.set_token('P_Name', X_EXCEPTION_REASON);
			fnd_msg_pub.add;
			v_error := 'Y';
		END IF;

		/*IF JTF_CAL_EXCEPTION_ASSIGN_PKG.NOT_NULL(X_EXCEPTION_ID) = FALSE THEN
			--fnd_message.set_name('JTF', 'EXCEPTION_ID CANNOT BE NULL');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_REQUIRED');
			fnd_message.set_token('P_Name', X_EXCEPTION_ID);
			fnd_msg_pub.add;
			v_error := 'Y';
		END IF;
		*/

		IF JTF_CAL_EXCEPTION_ASSIGN_PKG.NOT_NULL(X_START_DATE_ACTIVE) = FALSE THEN
			--fnd_message.set_name('JTF', 'START_DATE CANNOT BE NULL');
		        --app_exception.raise_exception;
			fnd_message.set_name('JTF', 'JTF_CAL_START_DATE');
			fnd_msg_pub.add;
			v_error := 'Y';
		END IF;

		IF JTF_CAL_EXCEPTION_ASSIGN_PKG.END_GREATER_THAN_BEGIN(X_START_DATE_ACTIVE, X_END_DATE_ACTIVE) = FALSE 				THEN
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

                      SELECT jtf_cal_exception_assign_s.nextval
                      INTO   v_cal_exception_assign_id_s
                      FROM   dual;
                      X_CAL_EXCEPTION_ASSIGN_ID := v_cal_exception_assign_id_s;

		  insert into JTF_CAL_EXCEPTION_ASSIGN (
		    OBJECT_VERSION_NUMBER,
		    CAL_EXCEPTION_ASSIGN_ID,
		    EXCEPTION_REASON,
		    CALENDAR_ID,
		    EXCEPTION_ID,
		    START_DATE_ACTIVE,
		    END_DATE_ACTIVE,
		    CREATED_BY,
		    CREATION_DATE,
		    LAST_UPDATED_BY,
		    LAST_UPDATE_DATE,
		    LAST_UPDATE_LOGIN,
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
		  ) values
		  ( 1,
		    v_CAL_EXCEPTION_ASSIGN_ID_S,
		    X_EXCEPTION_REASON,
		    X_CALENDAR_ID,
		    X_EXCEPTION_ID,
		    X_START_DATE_ACTIVE,
		    X_END_DATE_ACTIVE,
		    FND_GLOBAL.USER_ID,
	            sysdate,
		    FND_GLOBAL.USER_ID,
		    sysdate,
		    NULL,
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
		    X_ATTRIBUTE_CATEGORY);

--		  open c;
--		  fetch c into X_ROWID;
--		  if (c%notfound) then
--		    close c;
--		    raise no_data_found;
--		  end if;
--		  close c;
		END IF;
end INSERT_ROW;

procedure LOCK_ROW (
  X_CAL_EXCEPTION_ASSIGN_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_EXCEPTION_REASON in VARCHAR2,
  X_CALENDAR_ID in NUMBER,
  X_EXCEPTION_ID in NUMBER,
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
  X_ATTRIBUTE_CATEGORY in VARCHAR2
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      EXCEPTION_REASON,
      CALENDAR_ID,
      EXCEPTION_ID,
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
      CAL_EXCEPTION_ASSIGN_ID
    from JTF_CAL_EXCEPTION_ASSIGN
    where CAL_EXCEPTION_ASSIGN_ID = X_CAL_EXCEPTION_ASSIGN_ID
    for update of CAL_EXCEPTION_ASSIGN_ID nowait;
begin
  for tlinfo in c1 loop
--    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CAL_EXCEPTION_ASSIGN_ID = X_CAL_EXCEPTION_ASSIGN_ID)
          AND ((tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
               OR ((tlinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
          AND ((tlinfo.EXCEPTION_REASON = X_EXCEPTION_REASON)
               OR ((tlinfo.EXCEPTION_REASON is null) AND (X_EXCEPTION_REASON is null)))
          AND (tlinfo.CALENDAR_ID = X_CALENDAR_ID)
          AND (tlinfo.EXCEPTION_ID = X_EXCEPTION_ID)
          AND ((tlinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
               OR ((tlinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
          AND ((tlinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
               OR ((tlinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
          AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
               OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
          AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
               OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
          AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
               OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
          AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
               OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
          AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
               OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
          AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
               OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
          AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
               OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
          AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
               OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
          AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
               OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
          AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
               OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
          AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
               OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
          AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
               OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
          AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
               OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
          AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
               OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
          AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
               OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
          AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
               OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
--    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ERROR out NOCOPY VARCHAR2,
  X_CAL_EXCEPTION_ASSIGN_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in OUT NOCOPY NUMBER,
  X_EXCEPTION_REASON in VARCHAR2,
  X_CALENDAR_ID in NUMBER,
  X_EXCEPTION_ID in NUMBER,
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
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
	v_error CHAR := 'N';
	v_count NUMBER;
begin
		fnd_msg_pub.initialize;
		-- To check duplication of exception
		SELECT 	count(*)
        	INTO v_count
		FROM   	jtf_cal_exception_assign
		WHERE calendar_id = X_CALENDAR_ID
          	and exception_id = X_EXCEPTION_ID;

        	IF v_count > 1 THEN
          	fnd_message.set_name('JTF','JTF_CAL_EXCEPTION_EXISTS');
          	fnd_msg_pub.add;
		v_error := 'Y';
		END IF;

               /*
		IF JTF_CAL_EXCEPTION_ASSIGN_PKG.duplicate_excep(X_CALENDAR_ID,X_EXCEPTION_ID, X_EXCEPTION_REASON,X_START_DATE_ACTIVE, nvl(X_END_DATE_ACTIVE,'31-DEC-4712')) = FALSE THEN
			fnd_message.set_name('JTF','JTF_CAL_EXCEPTION_EXISTS');
			fnd_msg_pub.add;
			v_error := 'Y';
		END IF;
               */


		IF JTF_CAL_EXCEPTION_ASSIGN_PKG.NOT_NULL(X_START_DATE_ACTIVE) = FALSE THEN
			fnd_message.set_name('JTF', 'JTF_CAL_START_DATE');
			fnd_msg_pub.add;
			v_error := 'Y';
		END IF;

		IF JTF_CAL_EXCEPTION_ASSIGN_PKG.END_GREATER_THAN_BEGIN(X_START_DATE_ACTIVE, X_END_DATE_ACTIVE) = FALSE 				THEN
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

		  update JTF_CAL_EXCEPTION_ASSIGN set
		    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
		    EXCEPTION_REASON = X_EXCEPTION_REASON,
		    CALENDAR_ID = X_CALENDAR_ID,
		    EXCEPTION_ID = X_EXCEPTION_ID,
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
		    CAL_EXCEPTION_ASSIGN_ID = X_CAL_EXCEPTION_ASSIGN_ID,
		    LAST_UPDATE_DATE = sysdate,
		    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
		    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
		  where CAL_EXCEPTION_ASSIGN_ID = X_CAL_EXCEPTION_ASSIGN_ID;

--		  if (sql%notfound) then
--		    raise no_data_found;
--		  end if;
		END IF;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CAL_EXCEPTION_ASSIGN_ID in NUMBER
) is
begin
  delete from JTF_CAL_EXCEPTION_ASSIGN
  where CAL_EXCEPTION_ASSIGN_ID = X_CAL_EXCEPTION_ASSIGN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;
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
/*************************************************************************/
FUNCTION duplicate_excep(X_CALENDAR_ID in NUMBER,X_EXCEPTION_ID IN NUMBER, X_EXCEPTION_REASON IN CHAR, X_START_DATE_ACTIVE IN DATE, X_END_DATE_ACTIVE IN DATE) RETURN boolean IS

	X_FOUND CHAR := 'N';
    -- Just check the duplication by name.
	  cursor dup is
		select 	'x'
		from   	jtf_cal_exception_assign
		where calendar_id = X_CALENDAR_ID
        and exception_id = X_EXCEPTION_ID
--		and exception_reason= X_EXCEPTION_REASON
 --       and (( X_START_DATE_ACTIVE <=  start_date_active and nvl(X_END_DATE_ACTIVE,'31-DEC-4712')  >= end_date_active )
  --      OR  ( X_START_DATE_ACTIVE BETWEEN  start_date_active and end_date_active)
   --     OR  ( nvl(X_END_DATE_ACTIVE,'31-DEC-4712')   BETWEEN  start_date_active and end_date_active)
    --    OR  ((X_START_DATE_ACTIVE <  start_date_active) AND (nvl(X_END_DATE_ACTIVE,'31-DEC-4712') > end_date_active )))
		AND rownum < 2;

	BEGIN
	-- Excep is unique
		open dup;
		  fetch dup into X_FOUND;
		  if (dup%notfound) then
			return(TRUE);
		    close dup;
		  else
			return(FALSE);
		  end if;
		  close dup;

	END;
end JTF_CAL_EXCEPTION_ASSIGN_PKG;

/
